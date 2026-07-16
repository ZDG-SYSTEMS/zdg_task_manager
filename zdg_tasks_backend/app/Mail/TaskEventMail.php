<?php

namespace App\Mail;

use App\Enums\NotificationEvent;
use App\Models\Task;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class TaskEventMail extends Mailable
{
    use Queueable, SerializesModels;

    /** @param array<string, mixed> $context */
    public function __construct(
        public readonly Task $task,
        public readonly NotificationEvent $event,
        public readonly array $context = [],
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: '[ZDG Tasks] '.$this->event->title().': '.$this->task->title,
        );
    }

    public function content(): Content
    {
        return new Content(text: 'mail.task-event');
    }
}
