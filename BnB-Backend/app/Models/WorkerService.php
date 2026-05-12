<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['worker_id', 'type', 'description', 'price_per_unit', 'unit', 'is_available'])]
class WorkerService extends Model
{
    use HasFactory;

    protected $casts = [
        'is_available' => 'boolean',
    ];

    public function worker()
    {
        return $this->belongsTo(User::class, 'worker_id')->select(['id', 'name', 'phone']);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class, 'worker_service_id');
    }
}
