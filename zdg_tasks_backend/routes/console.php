<?php

use Illuminate\Support\Facades\Schedule;

// Daily maintenance: recompute approver-visible priorities and overdue
// flags first, then escalate anything the queue has neglected.
Schedule::command('tasks:refresh-priorities')->dailyAt('00:05');
Schedule::command('tasks:escalate')->dailyAt('00:15');
