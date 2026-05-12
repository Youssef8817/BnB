<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

#[Fillable(['user_id', 'worker_service_id', 'rating', 'comment'])]
class Review extends Model
{
    use HasFactory, SoftDeletes;

    public function user()
    {
        return $this->belongsTo(User::class)->select(['id', 'name', 'phone']);
    }

    public function workerService()
    {
        return $this->belongsTo(WorkerService::class);
    }
}
