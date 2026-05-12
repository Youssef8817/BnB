<?php

namespace Database\Factories;

use App\Models\ActivityLog;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class ActivityLogFactory extends Factory
{
    protected $model = ActivityLog::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'action' => $this->faker->randomElement(['property.status_changed', 'service_request.status_changed']),
            'model' => $this->faker->randomElement(['Property', 'ServiceRequest']),
            'model_id' => $this->faker->numberBetween(1, 100),
            'ip_address' => $this->faker->ipv4,
            'created_at' => $this->faker->dateTimeThisYear(),
        ];
    }
}
