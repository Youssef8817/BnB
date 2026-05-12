<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class WorkerServiceFactory extends Factory
{
    protected $model = \App\Models\WorkerService::class;

    public function definition(): array
    {
        return [
            'worker_id' => User::factory()->state(['role' => 'worker']),
            'type' => $this->faker->randomElement(['plumbing', 'painting', 'tiling', 'electrical', 'carpentry', 'finishing']),
            'description' => $this->faker->paragraph,
            'price_per_unit' => $this->faker->randomFloat(2, 50, 500),
            'unit' => 'hour',
            'is_available' => true,
        ];
    }
}
