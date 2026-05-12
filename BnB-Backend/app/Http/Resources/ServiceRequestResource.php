<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ServiceRequestResource extends JsonResource
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
            'user' => [
                'id' => $this->user->id,
                'name' => $this->user->name,
                'phone' => $this->user->phone,
            ],
            'worker_service' => [
                'id' => $this->workerService->id,
                'type' => $this->workerService->type,
                'description' => $this->workerService->description,
                'worker' => [
                    'id' => $this->workerService->worker->id,
                    'name' => $this->workerService->worker->name,
                    'phone' => $this->workerService->worker->phone,
                ],
            ],
            'note' => $this->note,
            'address' => $this->address,
            'status' => $this->status,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
