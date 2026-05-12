<?php

namespace Database\Factories;

use App\Models\ServiceRequest;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class ServiceRequestFactory extends Factory
{
    protected $model = ServiceRequest::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory()->state(['role' => 'user']),
            'worker_service_id' => \App\Models\WorkerService::factory(),
            'note' => $this->faker->paragraph,
            'address' => $this->faker->address,
            'status' => 'pending',
        ];
    }
}
