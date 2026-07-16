<?php

namespace App\Services;

use App\Enums\NotificationEvent;
use App\Enums\Role;
use App\Enums\UserStatus;
use App\Mail\TaskEventMail;
use App\Models\Notification;
use App\Models\Task;
use App\Models\User;
use App\Services\Push\PushSender;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Throwable;

/**
 * Fires every notification event through all channels available to
 * each recipient: an in-app record always, email when the user has an
 * address, FCM push when the user has registered device tokens and the
 * push channel is configured.
 *
 * Rules enforced here:
 * - The actor is never notified about their own action.
 * - A technical action never notifies anyone: it is not a genuine
 *   authorization, so downstream users must not be told anything
 *   happened.
 * - Chain-end rule: requesters (dept heads and directors) are only
 *   addressed by events that end a chain or need their input, which is
 *   guaranteed by recipient selection at the call sites.
 */
class TaskNotifier
{
    public function __construct(private readonly PushSender $push) {}

    /**
     * @param  User|Collection<int, User>|array<int, User>  $recipients
     * @param  array<string, mixed>  $context
     */
    public function notify(
        Task $task,
        NotificationEvent $event,
        User|Collection|array $recipients,
        ?User $actor,
        array $context = [],
    ): void {
        if ($actor?->role === Role::Technical) {
            return;
        }

        $recipients = Collection::wrap($recipients)
            ->filter(fn (User $user): bool => $user->status === UserStatus::Active)
            ->reject(fn (User $user): bool => $actor !== null && $user->is($actor))
            ->unique('id');

        foreach ($recipients as $recipient) {
            $this->deliver($task, $event, $recipient, $context);
        }
    }

    /** All active company finance users of the task's company. */
    public function financeOffice(Task $task): Collection
    {
        return User::query()
            ->where('role', Role::CompanyFinance)
            ->where('company_id', $task->company_id)
            ->where('status', UserStatus::Active)
            ->get();
    }

    /** The Director of Finance (single account at ZDG). */
    public function dof(): Collection
    {
        return User::query()
            ->where('role', Role::Dof)
            ->where('status', UserStatus::Active)
            ->get();
    }

    /** @param array<string, mixed> $context */
    private function deliver(Task $task, NotificationEvent $event, User $recipient, array $context): void
    {
        $channels = ['in_app'];

        if ($recipient->email !== null) {
            $channels[] = 'email';
        }

        $tokens = $recipient->deviceTokens()->pluck('token')->all();
        $pushAvailable = $tokens !== [] && $this->push->isConfigured();
        if ($pushAvailable) {
            $channels[] = 'push';
        }

        Notification::query()->create([
            'user_id' => $recipient->id,
            'task_id' => $task->id,
            'event' => $event->value,
            'channels_sent' => $channels,
        ]);

        try {
            Mail::to($recipient->email)->send(new TaskEventMail($task, $event, $context));
        } catch (Throwable $exception) {
            Log::warning('Notification email failed: '.$exception->getMessage());
        }

        if ($pushAvailable) {
            $this->push->send(
                $tokens,
                $event->title(),
                $task->title,
                ['task_id' => (string) $task->id, 'event' => $event->value],
            );
        }
    }
}
