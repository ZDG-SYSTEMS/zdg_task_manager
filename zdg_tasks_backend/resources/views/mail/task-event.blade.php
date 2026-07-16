{{ $event->title() }}

Task: {{ $task->title }} ({{ $task->company->code }})
Status: {{ $task->status->value }}
@if ($task->amount_requested !== null)
Amount requested: ZMW {{ number_format($task->amount_requested / 100, 2) }}
@endif
@if ($task->amount_approved !== null)
Amount approved: ZMW {{ number_format($task->amount_approved / 100, 2) }}
@endif
@if ($task->amount_issued !== null)
Amount issued: ZMW {{ number_format($task->amount_issued / 100, 2) }}
@endif
@if (($context['reason'] ?? null) !== null)
Reason: {{ $context['reason'] }}
@endif
@if (($context['due_date'] ?? null) !== null)
Due date: {{ $context['due_date'] }}
@endif

Sign in to ZDG Tasks to view the full request.
