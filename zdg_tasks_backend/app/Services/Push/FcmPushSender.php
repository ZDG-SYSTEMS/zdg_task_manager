<?php

namespace App\Services\Push;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Throwable;

/**
 * Firebase Cloud Messaging over the HTTP v1 API, authenticated with a
 * service-account JSON file (FIREBASE_CREDENTIALS env). When the file
 * is absent the channel simply reports itself unavailable.
 */
class FcmPushSender implements PushSender
{
    /** @var array<string, mixed>|null */
    private ?array $credentials = null;

    public function isConfigured(): bool
    {
        return $this->loadCredentials() !== null;
    }

    public function send(array $tokens, string $title, string $body, array $data = []): void
    {
        $credentials = $this->loadCredentials();
        if ($credentials === null || $tokens === []) {
            return;
        }

        try {
            $accessToken = $this->accessToken($credentials);
            $endpoint = sprintf(
                'https://fcm.googleapis.com/v1/projects/%s/messages:send',
                $credentials['project_id'],
            );

            foreach ($tokens as $token) {
                $response = Http::withToken($accessToken)->post($endpoint, [
                    'message' => [
                        'token' => $token,
                        'notification' => ['title' => $title, 'body' => $body],
                        'data' => array_map('strval', $data),
                    ],
                ]);

                if ($response->failed()) {
                    Log::warning('FCM send failed', [
                        'status' => $response->status(),
                        'body' => $response->json(),
                    ]);
                }
            }
        } catch (Throwable $exception) {
            Log::warning('FCM channel error: '.$exception->getMessage());
        }
    }

    /** @return array<string, mixed>|null */
    private function loadCredentials(): ?array
    {
        if ($this->credentials !== null) {
            return $this->credentials;
        }

        $path = config('services.fcm.credentials');
        if (! is_string($path) || $path === '' || ! is_file($path)) {
            return null;
        }

        $decoded = json_decode((string) file_get_contents($path), true);
        if (! is_array($decoded) || ! isset($decoded['project_id'], $decoded['client_email'], $decoded['private_key'])) {
            return null;
        }

        return $this->credentials = $decoded;
    }

    /**
     * Exchange a signed service-account JWT for an OAuth access token,
     * cached until shortly before expiry.
     *
     * @param  array<string, mixed>  $credentials
     */
    private function accessToken(array $credentials): string
    {
        return Cache::remember('fcm_access_token', now()->addMinutes(50), function () use ($credentials): string {
            $now = time();
            $header = $this->base64UrlEncode((string) json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
            $claims = $this->base64UrlEncode((string) json_encode([
                'iss' => $credentials['client_email'],
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud' => $credentials['token_uri'] ?? 'https://oauth2.googleapis.com/token',
                'iat' => $now,
                'exp' => $now + 3600,
            ]));

            openssl_sign("{$header}.{$claims}", $signature, $credentials['private_key'], OPENSSL_ALGO_SHA256);
            $jwt = "{$header}.{$claims}.".$this->base64UrlEncode($signature);

            $response = Http::asForm()->post(
                $credentials['token_uri'] ?? 'https://oauth2.googleapis.com/token',
                [
                    'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                    'assertion' => $jwt,
                ],
            )->throw();

            return $response->json('access_token');
        });
    }

    private function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
