<?php

namespace App\Console\Commands;

use App\Services\EscalationService;
use Illuminate\Console\Command;

class EscalateStaleTasks extends Command
{
    protected $signature = 'tasks:escalate';

    protected $description = 'Escalate neglected approval-queue tasks to the Director of Finance';

    public function handle(EscalationService $escalations): int
    {
        $escalated = $escalations->escalateStale();

        $this->info("{$escalated} task(s) escalated to the Director of Finance.");

        return self::SUCCESS;
    }
}
