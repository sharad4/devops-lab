<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\DB;

class HealthController extends Controller
{
    public function __invoke()
    {
        try {
            DB::select('select 1');
        } catch (\Throwable $e) {
            return response()->json(['status' => 'degraded', 'db' => 'down'], 503);
        }

        return response()->json([
            'status' => 'ok',
            'db' => 'up',
            'version' => env('APP_VERSION', 'dev'), // injected at build time (git SHA / tag)
        ]);
    }
}
