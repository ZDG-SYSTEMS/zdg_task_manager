<?php

namespace App\Exceptions;

use App\Enums\TaskStatus;
use Symfony\Component\HttpKernel\Exception\HttpException;

class InvalidTransitionException extends HttpException
{
    public function __construct(TaskStatus $from, TaskStatus $to)
    {
        parent::__construct(
            409,
            "A task cannot move from {$from->value} to {$to->value}.",
        );
    }
}
