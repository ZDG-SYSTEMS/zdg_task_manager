<?php

namespace Database\Seeders;

use App\Models\ReportFieldConfig;
use Illuminate\Database\Seeder;

class ReportFieldConfigSeeder extends Seeder
{
    /**
     * Default field registry for the three report tiers. Accounts
     * finalise reports by toggling enabled flags and editing labels
     * through the API; no rebuild required.
     */
    public function run(): void
    {
        $fields = [
            'general' => [
                'reporting_period' => 'Reporting period',
                'company_scope' => 'Company scope',
                'requests_raised' => 'Requests raised',
                'total_requested' => 'Total requested',
                'total_approved' => 'Total approved',
                'total_funded' => 'Total funded (cash released)',
                'rejected_count' => 'Rejected (count)',
                'rejected_value' => 'Rejected (value)',
                'completed_count' => 'Completed (count)',
                'completed_value' => 'Completed (value)',
                'pending_count' => 'Pending',
                'in_progress_count' => 'In progress',
                'overdue_count' => 'Overdue',
                'petty_cash_issued_count' => 'Petty cash issued (count)',
                'petty_cash_issued_value' => 'Petty cash issued (value)',
                'petty_cash_accounted' => 'Petty cash accounted for',
                'petty_cash_outstanding' => 'Petty cash outstanding',
                'budget_vs_funded' => 'Budget vs funded',
                'approval_rate' => 'Approval rate',
                'average_approval_turnaround_days' => 'Average approval turnaround (days)',
            ],
            'comparison' => [
                'requested_vs_approved_vs_funded' => 'Requested vs approved vs funded vs accounted',
                'budget_vs_funded_by_department' => 'Budget vs funded by department',
                'cost_distribution' => 'Cost distribution',
                'rejection_rate_trend' => 'Rejection rate trend',
                'overdue_rate_trend' => 'Overdue rate trend',
                'outstanding_imprest_trend' => 'Outstanding imprest trend',
            ],
            'in_depth' => [
                'task_id' => 'Task ID',
                'type' => 'Type',
                'title' => 'Title',
                'company' => 'Company',
                'department' => 'Department',
                'branch' => 'Branch',
                'requester' => 'Requester',
                'beneficiary' => 'Beneficiary',
                'dates' => 'Dates',
                'priority_at_resolution' => 'Priority at resolution',
                'amount_requested' => 'Amount requested',
                'amount_approved' => 'Amount approved',
                'edit_delta_and_reason' => 'Edit delta and reason',
                'funded_amount' => 'Funded amount',
                'funded_reference' => 'Funded reference',
                'funded_by' => 'Funded by',
                'receipt_required' => 'Receipt required',
                'amount_accounted' => 'Amount accounted for',
                'balance_returned' => 'Balance returned',
                'balance_outstanding' => 'Balance outstanding',
                'approver' => 'Approver',
                'assigned_funder' => 'Assigned funder',
                'via_technical' => 'Via technical',
                'status' => 'Status',
                'audit_trail' => 'State transition audit trail',
                'attachment_counts' => 'Attachment counts',
                'per_state_aging' => 'Per-state aging (days)',
            ],
        ];

        foreach ($fields as $tier => $tierFields) {
            $order = 0;
            foreach ($tierFields as $key => $label) {
                ReportFieldConfig::query()->updateOrCreate(
                    ['report_tier' => $tier, 'field_key' => $key],
                    ['label' => $label, 'enabled' => true, 'sort_order' => $order++],
                );
            }
        }
    }
}
