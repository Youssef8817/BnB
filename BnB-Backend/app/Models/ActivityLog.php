<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['user_id', 'action', 'model', 'model_id', 'ip_address', 'created_at'])]
class ActivityLog extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $casts = [
        'created_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class)->select(['id', 'name', 'phone']);
    }
}
