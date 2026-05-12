<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['property_id', 'path', 'display_order'])]
class PropertyImage extends Model
{
    use \Illuminate\Database\Eloquent\Factories\HasFactory;

    public function property()
    {
        return $this->belongsTo(Property::class);
    }
}
