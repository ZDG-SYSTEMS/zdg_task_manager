<?php

namespace App\Console\Commands;

use App\Services\PriorityService;
use Illuminate\Console\Command;

class RefreshTaskPriorities extends Command
{
    protected $signature = 'tasks:refresh-priorities';

    protected $description = 'Recompute approver-visible priorities and overdue flags for live tasks';

    public function handle(PriorityService $priorities): int
    {
        $updated = $priorities->refresh();

        $this->info("Priorities refreshed; {$updated} task(s) changed.");

        return self::SUCCESS;
    }
}
