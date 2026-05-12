<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReviewResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'         => $this->id,
            'rating'     => $this->rating,
            'comment'    => $this->comment,
            'user'       => [
                'id'   => $this->user?->id,
                'name' => $this->user?->name,
            ],
            'worker_service' => $this->whenLoaded('workerService', fn () => [
                'id'   => $this->workerService->id,
                'type' => $this->workerService->type,
            ]),
            'created_at' => $this->created_at,
        ];
    }
}
