<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WorkerServiceResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $avg = $this->reviews_avg_rating ?? $this->reviews()->avg('rating');

        return [
            'id' => $this->id,
            'worker_id' => $this->worker_id,
            'worker' => [
                'id' => $this->worker->id,
                'name' => $this->worker->name,
                'phone' => $this->worker->phone,
            ],
            'type' => $this->type,
            'description' => $this->description,
            'price_per_unit' => number_format($this->price_per_unit, 2),
            'unit' => $this->unit,
            'is_available' => $this->is_available,
            'avg_rating' => round((float) ($avg ?? 0), 1),
            'reviews_count' => $this->reviews_count ?? null,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
