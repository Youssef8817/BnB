<?php

namespace Tests\Feature;

use App\Models\Property;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class PropertyTest extends TestCase
{
    use RefreshDatabase;

    public function test_anyone_can_list_properties(): void
    {
        Property::factory()->count(5)->create(['status' => 'available']);

        $response = $this->getJson('/api/properties');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'current_page',
                    'data' => [
                        '*' => [
                            'id', 'owner_id', 'title', 'description', 'price',
                            'location', 'city', 'area_m2', 'rooms', 'status',
                            'created_at', 'updated_at', 'image_urls'
                        ]
                    ],
                    'first_page_url',
                    'from',
                    'last_page',
                    'last_page_url',
                    'links',
                    'next_page_url',
                    'path',
                    'per_page',
                    'prev_page_url',
                    'to',
                    'total'
                ],
                'message',
                'errors'
            ])
            ->assertJson(['success' => true, 'message' => 'OK']);
    }

    public function test_authenticated_user_can_create_property_with_images(): void
    {
        Storage::fake('public');

        $user = User::factory()->create(['role' => 'user']);
        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->postJson('/api/properties', [
            'title' => 'Test Property',
            'description' => 'Test description',
            'price' => 500000,
            'location' => '123 Test St',
            'city' => 'Test City',
            'area_m2' => 150,
            'rooms' => 3,
            'images' => [
                UploadedFile::fake()->image('property1.jpg'),
                UploadedFile::fake()->image('property2.jpg'),
            ],
        ]);

        $response->assertStatus(201)
            ->assertJson(['success' => true, 'message' => 'OK']);

        $this->assertDatabaseHas('properties', [
            'title' => 'Test Property',
            'city' => 'Test City',
        ]);

        // Check that at least one image was stored
        $property = Property::where('title', 'Test Property')->first();
        $this->assertNotNull($property);
        $this->assertCount(2, $property->images);
    }

    public function test_property_requires_at_least_1_image(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->postJson('/api/properties', [
            'title' => 'Test Property',
            'description' => 'Test description',
            'price' => 500000,
            'location' => '123 Test St',
            'city' => 'Test City',
            'area_m2' => 150,
            'rooms' => 3,
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['images']);
    }

    public function test_property_cannot_have_more_than_3_images(): void
    {
        Storage::fake('public');

        $user = User::factory()->create(['role' => 'user']);
        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->postJson('/api/properties', [
            'title' => 'Test Property',
            'description' => 'Test description',
            'price' => 500000,
            'location' => '123 Test St',
            'city' => 'Test City',
            'area_m2' => 150,
            'rooms' => 3,
            'images' => [
                UploadedFile::fake()->image('1.jpg'),
                UploadedFile::fake()->image('2.jpg'),
                UploadedFile::fake()->image('3.jpg'),
                UploadedFile::fake()->image('4.jpg'),
            ],
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['images']);
    }

    public function test_owner_can_update_property_status(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        $property = Property::factory()->create(['owner_id' => $user->id, 'status' => 'available']);
        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->putJson('/api/properties/' . $property->id . '/status', [
            'status' => 'pending',
        ]);

        $response->assertStatus(200)
            ->assertJson(['success' => true, 'message' => 'OK']);

        $this->assertDatabaseHas('properties', [
            'id' => $property->id,
            'status' => 'pending',
        ]);
    }

    public function test_non_owner_cannot_update_property_status(): void
    {
        $user1 = User::factory()->create(['role' => 'user']);
        $user2 = User::factory()->create(['role' => 'user']);
        $property = Property::factory()->create(['owner_id' => $user1->id, 'status' => 'available']);
        $token = $user2->createToken('test')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->putJson('/api/properties/' . $property->id . '/status', [
            'status' => 'pending',
        ]);

        $response->assertStatus(403);
    }

    public function test_owner_can_delete_property(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        $property = Property::factory()->create(['owner_id' => $user->id]);
        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->deleteJson('/api/properties/' . $property->id);

        $response->assertStatus(200)
            ->assertJson(['success' => true, 'message' => 'OK']);

        $this->assertDatabaseMissing('properties', ['id' => $property->id]);
    }

    public function test_non_owner_cannot_delete_property(): void
    {
        $user1 = User::factory()->create(['role' => 'user']);
        $user2 = User::factory()->create(['role' => 'user']);
        $property = Property::factory()->create(['owner_id' => $user1->id]);
        $token = $user2->createToken('test')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->deleteJson('/api/properties/' . $property->id);

        $response->assertStatus(403);
    }

    public function test_property_list_filters_by_city(): void
    {
        Property::factory()->count(2)->create(['city' => 'Istanbul', 'status' => 'available']);
        Property::factory()->create(['city' => 'Ankara', 'status' => 'available']);

        $response = $this->getJson('/api/properties?city=Istanbul');

        $response->assertStatus(200);
        $data = $response->json('data.data');
        $this->assertCount(2, $data);
        foreach ($data as $property) {
            $this->assertEquals('Istanbul', $property['city']);
        }
    }

    public function test_property_list_filters_by_status(): void
    {
        Property::factory()->count(2)->create(['status' => 'available']);
        Property::factory()->create(['status' => 'sold']);

        $response = $this->getJson('/api/properties?status=available');

        $response->assertStatus(200);
        $data = $response->json('data.data');
        foreach ($data as $property) {
            $this->assertEquals('available', $property['status']);
        }
    }
}
