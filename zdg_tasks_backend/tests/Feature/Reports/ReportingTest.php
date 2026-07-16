<?php

namespace Tests\Feature\Reports;

use App\Enums\Role;
use App\Models\Company;
use App\Models\ReportFieldConfig;
use App\Models\Task;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ReportingTest extends TestCase
{
    use RefreshDatabase;

    private User $deptHead;

    private User $ibsFinance;

    private User $dof;

    private User $auditor;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
        Storage::fake();

        $this->deptHead = User::query()->where('role', Role::DeptHead)->sole();
        $this->dof = User::query()->where('role', Role::Dof)->sole();
        $this->auditor = User::query()->where('role', Role::Auditor)->sole();
        $this->ibsFinance = User::factory()
            ->role(Role::CompanyFinance)
            ->inCompany($this->deptHead->company)
            ->create();
    }

    /**
     * Drive a request through the real lifecycle so audit entries and
     * amounts exist: submitted, approved with an edit, funded.
     */
    private function approvedAndFundedTask(): Task
    {
        $create = $this->actingAs($this->deptHead, 'sanctum')->postJson('/api/tasks', [
            'title' => 'Report fixture request',
            'description' => 'Fixture for report figures.',
            'amount_requested' => 500000,
            'due_date' => now()->addWeek()->toDateString(),
            'beneficiary_type' => 'self',
        ]);
        $task = Task::query()->findOrFail($create->json('task.id'));
        $this->actingAs($this->deptHead, 'sanctum')->postJson("/api/tasks/{$task->id}/submit")->assertOk();
        $this->actingAs($this->ibsFinance, 'sanctum')->postJson("/api/tasks/{$task->id}/approve", [
            'amount_approved' => 450000,
            'amount_edit_reason' => 'Negotiated discount.',
            'receipt_required' => false,
        ])->assertOk();
        $this->actingAs($this->ibsFinance, 'sanctum')->postJson("/api/tasks/{$task->id}/fund", [
            'funded_amount' => 450000,
            'funded_reference' => 'CHQ-REP-1',
        ])->assertOk();

        return $task->refresh();
    }

    public function test_reports_are_denied_to_directors_and_dept_heads(): void
    {
        $director = User::query()->where('role', Role::Director)->sole();

        foreach (['general', 'comparison', 'in-depth'] as $tier) {
            $this->actingAs($this->deptHead, 'sanctum')
                ->getJson("/api/reports/{$tier}")
                ->assertForbidden();
            $this->actingAs($director, 'sanctum')
                ->getJson("/api/reports/{$tier}")
                ->assertForbidden();
        }
    }

    public function test_general_report_figures_are_correct(): void
    {
        $this->approvedAndFundedTask();

        // A rejected request in the same window.
        $rejected = $this->actingAs($this->deptHead, 'sanctum')->postJson('/api/tasks', [
            'title' => 'Rejected fixture',
            'description' => 'Will be rejected.',
            'amount_requested' => 200000,
            'due_date' => now()->addWeek()->toDateString(),
            'beneficiary_type' => 'self',
        ]);
        $rejectedId = $rejected->json('task.id');
        $this->actingAs($this->deptHead, 'sanctum')->postJson("/api/tasks/{$rejectedId}/submit");
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$rejectedId}/reject", ['reason' => 'Not budgeted.']);

        // Petty cash issued this window, partially accounted.
        $petty = $this->actingAs($this->ibsFinance, 'sanctum')->postJson('/api/petty-cash', [
            'recipient_id' => $this->deptHead->id,
            'amount_issued' => 100000,
            'purpose' => 'Report fixture imprest.',
        ]);
        $pettyId = $petty->json('task.id');
        $upload = $this->actingAs($this->deptHead, 'sanctum')->postJson("/api/tasks/{$pettyId}/receipts", [
            'file' => UploadedFile::fake()->create('r.pdf', 10, 'application/pdf'),
            'amount' => 40000,
        ]);
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->postJson("/api/tasks/{$pettyId}/receipts/{$upload->json('receipt.id')}/verify")
            ->assertOk();

        $report = $this->actingAs($this->ibsFinance, 'sanctum')
            ->getJson('/api/reports/general')
            ->assertOk()
            ->json('report');

        $this->assertSame(2, $report['requests_raised']);
        $this->assertSame(700000, $report['total_requested']);
        $this->assertSame(450000, $report['total_approved']);
        $this->assertSame(450000, $report['total_funded']);
        $this->assertSame(1, $report['rejected_count']);
        $this->assertSame(200000, $report['rejected_value']);
        $this->assertSame(1, $report['completed_count']);
        $this->assertSame(450000, $report['completed_value']);
        $this->assertSame(1, $report['petty_cash_issued_count']);
        $this->assertSame(100000, $report['petty_cash_issued_value']);
        $this->assertSame(40000, $report['petty_cash_accounted']);
        $this->assertSame(60000, $report['petty_cash_outstanding']);
        // One approval, one rejection. JSON collapses 50.0 to 50.
        $this->assertEquals(50, $report['approval_rate']);
        $this->assertSame(['IBS'], $report['company_scope']);
    }

    public function test_company_finance_is_scoped_and_dof_sees_everything(): void
    {
        $this->approvedAndFundedTask();

        // The seeded ZDC finance user sees no IBS activity.
        $zdcFinance = User::query()
            ->where('role', Role::CompanyFinance)
            ->where('company_id', '!=', $this->deptHead->company_id)
            ->sole();

        $zdcReport = $this->actingAs($zdcFinance, 'sanctum')
            ->getJson('/api/reports/general')
            ->assertOk()
            ->json('report');
        $this->assertSame(0, $zdcReport['requests_raised']);
        // Even asking for another company explicitly stays scoped.
        $ibsId = $this->deptHead->company_id;
        $forced = $this->actingAs($zdcFinance, 'sanctum')
            ->getJson("/api/reports/general?company_id={$ibsId}")
            ->assertOk()
            ->json('report');
        $this->assertSame(0, $forced['requests_raised']);

        // dof and auditor report across all companies.
        foreach ([$this->dof, $this->auditor] as $viewer) {
            $report = $this->actingAs($viewer, 'sanctum')
                ->getJson('/api/reports/general')
                ->assertOk()
                ->json('report');
            $this->assertSame(1, $report['requests_raised']);
            $this->assertCount(5, $report['company_scope']);
        }
    }

    public function test_disabled_registry_field_disappears_without_a_rebuild(): void
    {
        $this->approvedAndFundedTask();

        $field = ReportFieldConfig::query()
            ->where('report_tier', 'general')
            ->where('field_key', 'total_funded')
            ->sole();

        // Only dof or technical may edit the registry.
        $this->actingAs($this->ibsFinance, 'sanctum')
            ->patchJson("/api/report-fields/{$field->id}", ['enabled' => false])
            ->assertForbidden();

        $this->actingAs($this->dof, 'sanctum')
            ->patchJson("/api/report-fields/{$field->id}", ['enabled' => false])
            ->assertOk();

        $report = $this->actingAs($this->ibsFinance, 'sanctum')
            ->getJson('/api/reports/general')
            ->assertOk()
            ->json('report');

        $this->assertArrayNotHasKey('total_funded', $report);
        $this->assertArrayHasKey('total_requested', $report);
    }

    public function test_comparison_report_computes_variance_between_periods(): void
    {
        $this->approvedAndFundedTask();

        $report = $this->actingAs($this->dof, 'sanctum')
            ->getJson('/api/reports/comparison')
            ->assertOk()
            ->json('report');

        $requested = $report['requested_vs_approved_vs_funded']['requested'];
        $this->assertSame(500000, $requested['current']);
        $this->assertSame(0, $requested['previous']);
        $this->assertSame(500000, $requested['variance']);

        $byCompany = collect($report['cost_distribution']['by_company']);
        $this->assertSame('IBS', $byCompany->first()['company']);
        $this->assertEquals(100, $byCompany->first()['share_percent']);
    }

    public function test_in_depth_report_carries_rows_and_exception_sets(): void
    {
        $funded = $this->approvedAndFundedTask();

        // An approved-but-not-funded task for the exception set.
        $unfunded = $this->actingAs($this->deptHead, 'sanctum')->postJson('/api/tasks', [
            'title' => 'Approved unfunded fixture',
            'description' => 'Approved but never funded.',
            'amount_requested' => 300000,
            'due_date' => now()->addWeek()->toDateString(),
            'beneficiary_type' => 'self',
        ]);
        $unfundedId = $unfunded->json('task.id');
        $this->actingAs($this->deptHead, 'sanctum')->postJson("/api/tasks/{$unfundedId}/submit");
        $this->actingAs($this->ibsFinance, 'sanctum')->postJson("/api/tasks/{$unfundedId}/approve", [
            'receipt_required' => false,
        ]);

        $report = $this->actingAs($this->ibsFinance, 'sanctum')
            ->getJson('/api/reports/in-depth')
            ->assertOk()
            ->json('report');

        $this->assertCount(2, $report['tasks']);

        $row = collect($report['tasks'])->firstWhere('task_id', $funded->id);
        $this->assertSame('IBS', $row['company']);
        $this->assertSame($this->deptHead->name, $row['requester']['name']);
        $this->assertSame(-50000, $row['edit_delta_and_reason']['delta']);
        $this->assertSame('CHQ-REP-1', $row['funded_reference']);
        $this->assertSame($this->ibsFinance->name, $row['approver']['name']);
        $this->assertNotEmpty($row['audit_trail']);
        $this->assertArrayHasKey('per_state_aging', $row);

        $exceptionIds = array_column($report['exceptions']['approved_not_funded'], 'id');
        $this->assertContains($unfundedId, $exceptionIds);
        $this->assertNotContains($funded->id, $exceptionIds);

        $edited = collect($report['exceptions']['edited_amounts'])->firstWhere('task_id', $funded->id);
        $this->assertSame('Negotiated discount.', $edited['reason']);
    }

    public function test_reports_export_as_csv(): void
    {
        $this->approvedAndFundedTask();

        $response = $this->actingAs($this->dof, 'sanctum')
            ->get('/api/reports/general?format=csv');

        $response->assertOk();
        $this->assertStringContainsString('text/csv', $response->headers->get('Content-Type'));
        $content = $response->streamedContent();
        $this->assertStringContainsString('total_funded,450000', $content);

        $inDepth = $this->actingAs($this->dof, 'sanctum')
            ->get('/api/reports/in-depth?format=csv');
        $inDepth->assertOk();
        $this->assertStringContainsString('Report fixture request', $inDepth->streamedContent());
    }

    public function test_weekly_period_windows_the_figures(): void
    {
        $this->approvedAndFundedTask();

        // A weekly report anchored two weeks ago excludes this week's
        // activity entirely.
        $report = $this->actingAs($this->dof, 'sanctum')
            ->getJson('/api/reports/general?period=weekly&date='.now()->subWeeks(2)->toDateString())
            ->assertOk()
            ->json('report');

        $this->assertSame(0, $report['requests_raised']);
        $this->assertSame(0, $report['total_funded']);
    }
}
