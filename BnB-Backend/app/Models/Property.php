<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['owner_id', 'title', 'description', 'price', 'location', 'city', 'area_m2', 'rooms', 'status'])]
class Property extends Model
{
    use \Illuminate\Database\Eloquent\Factories\HasFactory;

    protected $casts = [
        'price' => 'decimal:2',
    ];

    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function images()
    {
        return $this->hasMany(PropertyImage::class);
    }
}
