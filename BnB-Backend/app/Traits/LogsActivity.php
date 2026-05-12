<?php

namespace App\Traits;

use App\Models\ActivityLog;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;

trait LogsActivity
{
    public function logActivity(User $user, string $action, $model, Request $request): void
    {
        ActivityLog::create([
            'user_id' => $user->id,
            'action' => $action,
            'model' => get_class($model),
            'model_id' => $model->id,
            'ip_address' => $request->ip(),
            'created_at' => Carbon::now(),
        ]);
    }
}
