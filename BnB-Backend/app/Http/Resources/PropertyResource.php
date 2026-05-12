<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class PropertyResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'owner_id' => $this->owner_id,
            'title' => $this->title,
            'description' => $this->description,
            'price' => number_format($this->price, 2),
            'location' => $this->location,
            'city' => $this->city,
            'area_m2' => $this->area_m2,
            'rooms' => $this->rooms,
            'status' => $this->status,
            'image_urls' => $this->images->map(function ($image) {
                return Storage::url($image->path);
            }),
            'owner' => [
                'id' => $this->owner->id,
                'name' => $this->owner->name,
                'phone' => $this->owner->phone,
            ],
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
