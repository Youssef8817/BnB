<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['name', 'email', 'password', 'phone', 'role', 'avatar_url'])]
class User extends Authenticatable
{
    use HasApiTokens, \Illuminate\Database\Eloquent\Factories\HasFactory, Notifiable;

    /**
     * The accessors to append to the model's array form.
     *
     * @var array
     */
    protected $appends = ['avatar_url'];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Get the user's avatar URL.
     *
     * @return string|null
     */
    public function getAvatarUrlAttribute($value)
    {
        return $value;
    }

    public function properties()
    {
        return $this->hasMany(Property::class, 'owner_id');
    }

    public function workerServices()
    {
        return $this->hasMany(WorkerService::class, 'worker_id');
    }

    public function reviews()
    {
        return $this->hasMany(Review::class, 'user_id');
    }

    public function activityLogs()
    {
        return $this->hasMany(ActivityLog::class, 'user_id');
    }
}

