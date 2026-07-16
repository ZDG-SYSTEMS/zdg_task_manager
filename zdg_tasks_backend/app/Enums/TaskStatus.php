<?php

namespace App\Enums;

enum TaskStatus: string
{
    case Draft = 'draft';
    case Submitted = 'submitted';
    case PendingApproval = 'pending_approval';
    case Approved = 'approved';
    case PendingReceipt = 'pending_receipt';
    case Completed = 'completed';
    case Rejected = 'rejected';
    case Postponed = 'postponed';
    case Escalated = 'escalated';
}
