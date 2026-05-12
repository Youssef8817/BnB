<?php

namespace Tests\Feature;

use App\Models\Property;
use App\Models\ServiceRequest;
use App\Models\User;
use App\Models\WorkerService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_list_users(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('test')->plainTextToken;

        User::factory()->count(5)->create(['role' => 'user']);
        User::factory()->count(3)->create(['role' => 'worker']);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/admin/users');

        $response->assertStatus(200)
            ->assertJson(['success' => true, 'message' => 'OK'])
            ->assertJsonStructure([
                'success',
                'data' => [
                    'current_page',
                    'data' => [
                        '*' => ['id', 'name', 'email', 'phone', 'role', 'created_at']
                    ],
                ],
                'message',
                'errors',
            ]);

        $data = $response->json('data');
        $this->assertCount(9, $data['data']); // 5 users + 3 workers + 1 admin
    }

    public function test_non_admin_cannot_access_admin_routes(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/admin/users');

        $response->assertStatus(403);

        $worker = User::factory()->create(['role' => 'worker']);
        $workerToken = $worker->createToken('test')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $workerToken,
        ])->getJson('/api/admin/stats');

        $response->assertStatus(403);
    }

    public function test_admin_can_see_stats(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('test')->plainTextToken;

        // Create some test data
        User::factory()->count(5)->create(['role' => 'user']);
        User::factory()->count(3)->create(['role' => 'worker']);
        Property::factory()->count(7)->create();
        ServiceRequest::factory()->count(4)->create(['status' => 'pending']);
        ServiceRequest::factory()->count(2)->create(['status' => 'accepted']);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/admin/stats');

        $response->assertStatus(200)
            ->assertJson(['success' => true, 'message' => 'OK'])
            ->assertJsonStructure([
                'success',
                'data' => [
                    'total_users',
                    'total_workers',
                    'total_properties',
                    'total_requests',
                    'pending_requests',
                ],
                'message',
                'errors',
            ]);

        $data = $response->json('data');
        $this->assertEquals(9, $data['total_users']); // 1 admin + 5 users + 3 workers
        $this->assertEquals(3, $data['total_workers']);
        $this->assertEquals(7, $data['total_properties']);
        $this->assertEquals(6, $data['total_requests']);
        $this->assertEquals(4, $data['pending_requests']);
    }

    public function test_admin_can_delete_review(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('test')->plainTextToken;

        $review = \App\Models\Review::factory()->create();

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->deleteJson('/api/admin/reviews/' . $review->id);

        $response->assertStatus(200)
            ->assertJson(['success' => true, 'message' => 'OK']);

        $this->assertDatabaseMissing('reviews', ['id' => $review->id]);
    }

    public function test_admin_can_view_activity_logs(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('test')->plainTextToken;

        \App\Models\ActivityLog::factory()->count(5)->create();

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/admin/logs');

        $response->assertStatus(200)
            ->assertJson(['success' => true, 'message' => 'OK'])
            ->assertJsonStructure([
                'success',
                'data' => [
                    'current_page',
                    'data' => [
                        '*' => [
                            'id', 'action', 'model', 'model_id',
                            'ip_address', 'created_at',
                            'user' => ['id', 'name', 'phone'],
                        ]
                    ],
                ],
                'message',
                'errors',
            ]);
    }

    public function test_admin_can_update_property_status(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('test')->plainTextToken;

        $property = Property::factory()->create(['status' => 'available']);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->putJson('/api/admin/properties/' . $property->id, [
            'status' => 'sold',
        ]);

        $response->assertStatus(200)
            ->assertJson(['success' => true, 'message' => 'OK']);

        $this->assertDatabaseHas('properties', [
            'id' => $property->id,
            'status' => 'sold',
        ]);
    }

    public function test_admin_can_delete_user(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('test')->plainTextToken;

        $user = User::factory()->create(['role' => 'user']);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->deleteJson('/api/admin/users/' . $user->id);

        $response->assertStatus(200)
            ->assertJson(['success' => true, 'message' => 'OK']);

        $this->assertDatabaseMissing('users', ['id' => $user->id]);
    }

    public function test_admin_can_filter_requests_by_status(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $token = $admin->createToken('test')->plainTextToken;

        ServiceRequest::factory()->count(3)->create(['status' => 'pending']);
        ServiceRequest::factory()->count(2)->create(['status' => 'completed']);

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->getJson('/api/admin/requests?status=pending');

        $response->assertStatus(200);

        $data = $response->json('data');
        $this->assertCount(3, $data['data']);

        foreach ($data['data'] as $request) {
            $this->assertEquals('pending', $request['status']);
        }
    }
}
