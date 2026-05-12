<?php

namespace Database\Factories;

use App\Models\Review;
use App\Models\User;
use App\Models\WorkerService;
use Illuminate\Database\Eloquent\Factories\Factory;

class ReviewFactory extends Factory
{
    protected $model = Review::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'worker_service_id' => WorkerService::factory(),
            'rating' => $this->faker->numberBetween(1, 5),
            'comment' => $this->faker->paragraph,
        ];
    }
}
