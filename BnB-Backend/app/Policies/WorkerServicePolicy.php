<?php

namespace App\Policies;

use App\Models\User;
use App\Models\WorkerService;

class WorkerServicePolicy
{
    public function update(User $user, WorkerService $service): bool
    {
        return $user->id === $service->worker_id;
    }

    public function delete(User $user, WorkerService $service): bool
    {
        return $user->id === $service->worker_id;
    }
}
