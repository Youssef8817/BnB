<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['user_id', 'worker_service_id', 'note', 'address', 'status'])]
class ServiceRequest extends Model
{
    use \Illuminate\Database\Eloquent\Factories\HasFactory;

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function workerService()
    {
        return $this->belongsTo(WorkerService::class);
    }
}
