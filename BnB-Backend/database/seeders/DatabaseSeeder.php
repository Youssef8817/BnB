<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Property;
use App\Models\PropertyImage;
use App\Models\WorkerService;
use App\Models\ServiceRequest;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Seed 1 admin user
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@bb.com',
            'password' => Hash::make('password'),
            'phone' => '+1234567890',
            'role' => 'admin',
            'avatar_url' => null,
        ]);

        // Seed 5 normal users
        for ($i = 1; $i <= 5; $i++) {
            User::create([
                'name' => 'User ' . $i,
                'email' => 'user' . $i . '@bb.com',
                'password' => Hash::make('password'),
                'phone' => '+123456789' . $i,
                'role' => 'user',
                'avatar_url' => null,
            ]);
        }

        // Seed 3 workers
        for ($i = 1; $i <= 3; $i++) {
            User::create([
                'name' => 'Worker ' . $i,
                'email' => 'worker' . $i . '@bb.com',
                'password' => Hash::make('password'),
                'phone' => '+198765432' . $i,
                'role' => 'worker',
                'avatar_url' => null,
            ]);
        }

        // Seed 10 properties
        $users = User::whereIn('role', ['user', 'worker'])->pluck('id')->toArray();
        for ($i = 1; $i <= 10; $i++) {
            $property = Property::create([
                'owner_id' => $users[array_rand($users)],
                'title' => 'Property ' . $i,
                'description' => 'This is a nice property located in a great area.',
                'price' => rand(100000, 500000),
                'location' => '123 Main St, City ' . $i,
                'city' => 'City ' . (($i % 3) + 1),
                'area_m2' => rand(50, 200),
                'rooms' => rand(1, 5),
                'status' => 'available',
            ]);

            // Add 2-3 images per property
            $numImages = rand(2, 3);
            for ($j = 0; $j < $numImages; $j++) {
                PropertyImage::create([
                    'property_id' => $property->id,
                    'path' => 'placeholder_' . $i . '_' . $j . '.jpg',
                    'display_order' => $j,
                ]);
            }
        }

        // Seed 5 worker services
        $workerIds = User::where('role', 'worker')->pluck('id')->toArray();
        $types = ['plumbing', 'painting', 'tiling', 'electrical', 'carpentry', 'finishing'];
        for ($i = 1; $i <= 5; $i++) {
            WorkerService::create([
                'worker_id' => $workerIds[array_rand($workerIds)],
                'type' => $types[array_rand($types)],
                'description' => 'Professional service provided by experienced worker ' . $i,
                'price_per_unit' => rand(50, 500),
                'unit' => 'hour',
                'is_available' => true,
            ]);
        }

        // Seed 4 service requests
        $userIds = User::where('role', 'user')->pluck('id')->toArray();
        $serviceIds = WorkerService::pluck('id')->toArray();
        for ($i = 1; $i <= 4; $i++) {
            ServiceRequest::create([
                'user_id' => $userIds[array_rand($userIds)],
                'worker_service_id' => $serviceIds[array_rand($serviceIds)],
                'note' => 'Service request note ' . $i,
                'address' => '456 Request St, City ' . $i,
                'status' => 'pending',
            ]);
        }
    }
}
