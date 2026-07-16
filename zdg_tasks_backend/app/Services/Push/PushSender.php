<?php

namespace App\Services\Push;

interface PushSender
{
    /** Whether the push channel is available at all. */
    public function isConfigured(): bool;

    /**
     * Deliver a push message to a set of device tokens. Failures are
     * swallowed and logged; push must never break a business action.
     *
     * @param  list<string>  $tokens
     * @param  array<string, string>  $data
     */
    public function send(array $tokens, string $title, string $body, array $data = []): void;
}
