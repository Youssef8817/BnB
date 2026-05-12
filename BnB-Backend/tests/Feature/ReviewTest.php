<?php

namespace Tests\Feature;

use App\Models\Property;
use App\Models\Review;
use App\Models\ServiceRequest;
use App\Models\User;
use App\Models\WorkerService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ReviewTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_review_after_completed_request(): void
    {
        Storage::fake('public');

        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);

        $user = User::factory()->create(['role' => 'user']);
        $token = $user->createToken('test')->plainTextToken;

        $request = ServiceRequest::factory()->create([
            'user_id' => $user->id,
            'worker_service_id' => $service->id,
            'status' => 'completed',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->postJson('/api/worker-services/' . $service->id . '/reviews', [
            'rating' => 5,
            'comment' => 'Excellent service, highly recommended!',
        ]);

        $response->assertStatus(201)
            ->assertJson(['success' => true, 'message' => 'OK'])
            ->assertJsonStructure([
                'success',
                'data' => [
                    'id', 'rating', 'comment',
                    'user' => ['id', 'name', 'phone'],
                    'created_at',
                ],
                'message',
                'errors',
            ]);

        $this->assertDatabaseHas('reviews', [
            'user_id' => $user->id,
            'worker_service_id' => $service->id,
            'rating' => 5,
        ]);
    }

    public function test_user_cannot_review_without_completed_request(): void
    {
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);

        $user = User::factory()->create(['role' => 'user']);
        $token = $user->createToken('test')->plainTextToken;

        // Create a pending request, not completed
        ServiceRequest::factory()->create([
            'user_id' => $user->id,
            'worker_service_id' => $service->id,
            'status' => 'pending',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->postJson('/api/worker-services/' . $service->id . '/reviews', [
            'rating' => 5,
            'comment' => 'Great service!',
        ]);

        $response->assertStatus(403)
            ->assertJson(['success' => false]);
    }

    public function test_user_cannot_review_same_service_twice(): void
    {
        Storage::fake('public');

        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);

        $user = User::factory()->create(['role' => 'user']);
        $token = $user->createToken('test')->plainTextToken;

        $request = ServiceRequest::factory()->create([
            'user_id' => $user->id,
            'worker_service_id' => $service->id,
            'status' => 'completed',
        ]);

        // First review
        $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->postJson('/api/worker-services/' . $service->id . '/reviews', [
                'rating' => 5,
                'comment' => 'Great service!',
            ]);

        // Second review - should fail
        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->postJson('/api/worker-services/' . $service->id . '/reviews', [
            'rating' => 4,
            'comment' => 'Good service.',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['review']);
    }

    public function test_review_rating_must_be_between_1_and_5(): void
    {
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);

        $user = User::factory()->create(['role' => 'user']);
        $token = $user->createToken('test')->plainTextToken;

        ServiceRequest::factory()->create([
            'user_id' => $user->id,
            'worker_service_id' => $service->id,
            'status' => 'completed',
        ]);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->postJson('/api/worker-services/' . $service->id . '/reviews', [
            'rating' => 6,
            'comment' => 'Good service.',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['rating']);
    }

    public function test_get_reviews_for_service(): void
    {
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);

        $user1 = User::factory()->create(['role' => 'user']);
        $user2 = User::factory()->create(['role' => 'user']);

        Review::factory()->create([
            'user_id' => $user1->id,
            'worker_service_id' => $service->id,
            'rating' => 5,
            'comment' => 'Excellent!',
        ]);
        Review::factory()->create([
            'user_id' => $user2->id,
            'worker_service_id' => $service->id,
            'rating' => 4,
            'comment' => 'Very good',
        ]);

        $response = $this->getJson('/api/worker-services/' . $service->id . '/reviews');

        $response->assertStatus(200)
            ->assertJson(['success' => true, 'message' => 'OK'])
            ->assertJsonStructure([
                'success',
                'data' => [
                    'current_page',
                    'data' => [
                        '*' => [
                            'id', 'rating', 'comment',
                            'user' => ['id', 'name', 'phone'],
                            'created_at',
                        ]
                    ],
                ],
                'message',
                'errors',
                'meta' => ['avg_rating', 'total_reviews'],
            ]);

        $responseData = $response->json('data');
        $meta = $response->json('meta');

        $this->assertCount(2, $responseData['data']);
        $this->assertEquals(4.5, $meta['avg_rating']);
        $this->assertEquals(2, $meta['total_reviews']);
    }

    public function test_worker_service_resource_includes_avg_rating(): void
    {
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);

        Review::factory()->count(3)->create([
            'worker_service_id' => $service->id,
            'rating' => 5,
        ]);

        $response = $this->getJson('/api/worker-services');

        $response->assertStatus(200);

        $services = $response->json('data');
        $serviceData = collect($services)->firstWhere('id', $service->id);

        $this->assertNotNull($serviceData);
        $this->assertEquals(5.0, $serviceData['avg_rating']);
    }
}
