<?php

namespace App\Http\Controllers;

use App\Models\UserDeviceToken;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class NotificationController extends Controller
{
    public function send(Request $request)
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:200'],
            'body' => ['required', 'string', 'max:500'],
            'user_id' => ['nullable', 'integer', 'exists:users,id'],
            'user_ids' => ['nullable', 'array'],
            'user_ids.*' => ['integer', 'exists:users,id'],
            'type' => ['nullable', 'string', 'max:100'],
            'data' => ['nullable', 'array'],
        ]);

        $serverKey = config('services.fcm.server_key');
        if (empty($serverKey)) {
            return response()->json([
                'message' => 'FCM server key belum dikonfigurasi. Isi FCM_SERVER_KEY di file .env Anda.',
            ], 500);
        }

        $userIds = [];
        if (!empty($validated['user_id'])) {
            $userIds[] = (int) $validated['user_id'];
        }

        if (!empty($validated['user_ids'])) {
            foreach ($validated['user_ids'] as $userId) {
                $userIds[] = (int) $userId;
            }
        }

        if (empty($userIds)) {
            $userIds[] = (int) $request->user()->id;
        }

        $deviceTokens = UserDeviceToken::whereIn('user_id', array_unique($userIds))
            ->pluck('device_token')
            ->filter(fn ($token) => !empty($token))
            ->unique()
            ->values()
            ->all();

        if (empty($deviceTokens)) {
            return response()->json([
                'message' => 'Tidak ada device token aktif untuk user target.',
                'recipients' => 0,
            ], 404);
        }

        $payload = [
            'notification' => [
                'title' => $validated['title'],
                'body' => $validated['body'],
            ],
            'data' => array_merge([
                'type' => $validated['type'] ?? 'general',
                'sent_at' => now()->toISOString(),
            ], $validated['data'] ?? []),
            'priority' => 'high',
            'content_available' => true,
        ];

        if (count($deviceTokens) === 1) {
            $payload['to'] = $deviceTokens[0];
        } else {
            $payload['registration_ids'] = $deviceTokens;
        }

        $response = Http::withHeaders([
            'Authorization' => 'key=' . $serverKey,
            'Content-Type' => 'application/json',
        ])->post('https://fcm.googleapis.com/fcm/send', $payload);

        $result = $response->json();

        if ($response->failed()) {
            Log::error('FCM notification send failed.', [
                'status' => $response->status(),
                'body' => $result,
            ]);

            return response()->json([
                'message' => 'Gagal mengirim notifikasi ke FCM.',
                'status' => $response->status(),
                'response' => $result,
            ], $response->status());
        }

        return response()->json([
            'message' => 'Notifikasi berhasil dikirim.',
            'recipients' => count($deviceTokens),
            'response' => $result,
        ]);
    }
}
