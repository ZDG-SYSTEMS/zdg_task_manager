<?php

namespace App\Enums;

enum NotificationEvent: string
{
    case SubmissionReceived = 'submission_received';
    case Approved = 'approved';
    case AmountEdited = 'amount_edited';
    case Assigned = 'assigned';
    case Rejected = 'rejected';
    case Postponed = 'postponed';
    case ReceiptRequested = 'receipt_requested';
    case Completed = 'completed';
    case Escalated = 'escalated';

    public function title(): string
    {
        return match ($this) {
            self::SubmissionReceived => 'New request awaiting approval',
            self::Approved => 'Request approved',
            self::AmountEdited => 'Approved amount was edited',
            self::Assigned => 'Request assigned to you for funding',
            self::Rejected => 'Request rejected',
            self::Postponed => 'Request postponed',
            self::ReceiptRequested => 'Proof of purchase required',
            self::Completed => 'Task completed',
            self::Escalated => 'Task escalated to you',
        };
    }
}
