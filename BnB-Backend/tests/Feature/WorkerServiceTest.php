<?php

namespace Tests\Feature;

use App\Models\ServiceRequest;
use App\Models\User;
use App\Models\WorkerService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WorkerServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_anyone_can_list_worker_services(): void
    {
        $worker = User::factory()->create(['role' => 'worker']);
        WorkerService::factory()->count(3)->create(['worker_id' => $worker->id, 'is_available' => true]);

        $response = $this->getJson('/api/worker-services');

        $response->assertStatus(200)
            ->assertJson(['success' => true])
            ->assertJsonStructure(['success', 'data', 'message', 'errors']);
    }

    public function test_worker_can_create_service(): void
    {
        $worker = User::factory()->create(['role' => 'worker']);
        $token = $worker->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->postJson('/api/worker-services', [
                'type'           => 'plumbing',
                'description'    => 'Professional plumbing service',
                'price_per_unit' => 50.00,
                'unit'           => 'hour',
            ]);

        $response->assertStatus(201)
            ->assertJson(['success' => true])
            ->assertJsonPath('data.type', 'plumbing');

        $this->assertDatabaseHas('worker_services', [
            'worker_id' => $worker->id,
            'type'      => 'plumbing',
        ]);
    }

    public function test_regular_user_cannot_create_service(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->postJson('/api/worker-services', [
                'type'           => 'plumbing',
                'description'    => 'Professional plumbing service',
                'price_per_unit' => 50.00,
                'unit'           => 'hour',
            ]);

        $response->assertStatus(403);
    }

    public function test_unauthenticated_user_cannot_create_service(): void
    {
        $response = $this->postJson('/api/worker-services', [
            'type'           => 'plumbing',
            'description'    => 'Professional plumbing service',
            'price_per_unit' => 50.00,
            'unit'           => 'hour',
        ]);

        $response->assertStatus(401);
    }

    public function test_worker_can_update_own_service(): void
    {
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);
        $token = $worker->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->putJson("/api/worker-services/{$service->id}", [
                'price_per_unit' => 75.00,
                'is_available'   => false,
            ]);

        $response->assertStatus(200)
            ->assertJson(['success' => true]);

        $this->assertDatabaseHas('worker_services', [
            'id'             => $service->id,
            'price_per_unit' => 75.00,
            'is_available'   => false,
        ]);
    }

    public function test_worker_cannot_update_others_service(): void
    {
        $worker1 = User::factory()->create(['role' => 'worker']);
        $worker2 = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker1->id]);
        $token = $worker2->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->putJson("/api/worker-services/{$service->id}", [
                'price_per_unit' => 75.00,
            ]);

        $response->assertStatus(403);
    }

    public function test_worker_can_delete_own_service(): void
    {
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);
        $token = $worker->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->deleteJson("/api/worker-services/{$service->id}");

        $response->assertStatus(200)
            ->assertJson(['success' => true]);

        $this->assertDatabaseMissing('worker_services', ['id' => $service->id]);
    }

    public function test_worker_cannot_delete_service_with_pending_requests(): void
    {
        $worker = User::factory()->create(['role' => 'worker']);
        $user = User::factory()->create(['role' => 'user']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);
        ServiceRequest::factory()->create([
            'worker_service_id' => $service->id,
            'user_id'           => $user->id,
            'status'            => 'pending',
        ]);
        $token = $worker->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->deleteJson("/api/worker-services/{$service->id}");

        $response->assertStatus(403);
    }

    public function test_worker_cannot_delete_others_service(): void
    {
        $worker1 = User::factory()->create(['role' => 'worker']);
        $worker2 = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker1->id]);
        $token = $worker2->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->deleteJson("/api/worker-services/{$service->id}");

        $response->assertStatus(403);
    }
}
