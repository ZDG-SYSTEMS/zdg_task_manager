<?php

namespace Tests\Feature\Tasks;

use App\Enums\Role;
use App\Enums\TaskStatus;
use App\Models\Task;
use App\Models\User;
use Database\Seeders\DatabaseSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class AttachmentUploadTest extends TestCase
{
    use RefreshDatabase;

    private User $deptHead;

    private Task $draft;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(DatabaseSeeder::class);
        Storage::fake();

        $this->deptHead = User::query()->where('role', Role::DeptHead)->sole();
        $this->draft = Task::factory()->createdBy($this->deptHead)->create([
            'status' => TaskStatus::Draft,
        ]);
    }

    public function test_creator_uploads_a_quotation_to_their_draft(): void
    {
        $response = $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$this->draft->id}/attachments", [
                'file' => UploadedFile::fake()->create('quote.pdf', 512, 'application/pdf'),
                'kind' => 'quotation',
            ])
            ->assertCreated();

        $attachment = $this->draft->attachments()->sole();
        $this->assertSame('quotation', $attachment->kind->value);
        $this->assertSame('quote.pdf', $attachment->original_name);
        $this->assertSame($this->deptHead->id, $attachment->uploaded_by);
        Storage::assertExists($attachment->path);

        $response->assertJsonPath('attachment.original_name', 'quote.pdf');
    }

    public function test_file_over_5mb_is_rejected(): void
    {
        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$this->draft->id}/attachments", [
                'file' => UploadedFile::fake()->create('big.pdf', 5121, 'application/pdf'),
                'kind' => 'quotation',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('file');
    }

    public function test_disallowed_file_type_is_rejected(): void
    {
        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$this->draft->id}/attachments", [
                'file' => UploadedFile::fake()->create('macro.xlsm', 100, 'application/vnd.ms-excel'),
                'kind' => 'invoice',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('file');
    }

    public function test_receipt_kind_is_not_accepted_at_request_time(): void
    {
        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$this->draft->id}/attachments", [
                'file' => UploadedFile::fake()->create('receipt.pdf', 100, 'application/pdf'),
                'kind' => 'receipt',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('kind');
    }

    public function test_only_the_creator_attaches_to_a_draft(): void
    {
        $director = User::query()->where('role', Role::Director)->sole();

        $this->actingAs($director, 'sanctum')
            ->postJson("/api/tasks/{$this->draft->id}/attachments", [
                'file' => UploadedFile::fake()->create('quote.pdf', 100, 'application/pdf'),
                'kind' => 'quotation',
            ])
            ->assertForbidden();
    }

    public function test_attachments_are_locked_once_submitted(): void
    {
        $this->draft->update(['status' => TaskStatus::PendingApproval]);

        $this->actingAs($this->deptHead, 'sanctum')
            ->postJson("/api/tasks/{$this->draft->id}/attachments", [
                'file' => UploadedFile::fake()->create('late.pdf', 100, 'application/pdf'),
                'kind' => 'invoice',
            ])
            ->assertForbidden();
    }
}
