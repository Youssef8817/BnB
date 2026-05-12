<?php

namespace Database\Factories;

use App\Models\Property;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class PropertyFactory extends Factory
{
    protected $model = Property::class;

    public function definition(): array
    {
        return [
            'owner_id' => User::factory(),
            'title' => $this->faker->sentence,
            'description' => $this->faker->paragraph,
            'price' => $this->faker->randomFloat(2, 50000, 1000000),
            'location' => $this->faker->address,
            'city' => $this->faker->city,
            'area_m2' => $this->faker->randomFloat(2, 30, 300),
            'rooms' => $this->faker->numberBetween(1, 10),
            'status' => $this->faker->randomElement(['available', 'sold', 'pending']),
        ];
    }
}
