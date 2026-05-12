<?php

namespace Tests\Feature;

use App\Models\ServiceRequest;
use App\Models\User;
use App\Models\WorkerService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ServiceRequestTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_create_service_request(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);
        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->postJson('/api/service-requests', [
                'worker_service_id' => $service->id,
                'note'              => 'Please fix my sink',
                'address'           => '123 Main St',
            ]);

        $response->assertStatus(201)
            ->assertJson(['success' => true]);

        $this->assertDatabaseHas('service_requests', [
            'user_id'           => $user->id,
            'worker_service_id' => $service->id,
            'status'            => 'pending',
        ]);
    }

    public function test_unauthenticated_user_cannot_create_service_request(): void
    {
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);

        $response = $this->postJson('/api/service-requests', [
            'worker_service_id' => $service->id,
            'note'              => 'Please fix my sink',
            'address'           => '123 Main St',
        ]);

        $response->assertStatus(401);
    }

    public function test_user_can_see_own_service_requests(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);
        ServiceRequest::factory()->count(3)->create([
            'user_id'           => $user->id,
            'worker_service_id' => $service->id,
        ]);
        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->getJson('/api/service-requests/mine');

        $response->assertStatus(200)
            ->assertJson(['success' => true]);
    }

    public function test_worker_can_see_incoming_requests(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);
        ServiceRequest::factory()->count(2)->create([
            'user_id'           => $user->id,
            'worker_service_id' => $service->id,
        ]);
        $token = $worker->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->getJson('/api/service-requests/incoming');

        $response->assertStatus(200)
            ->assertJson(['success' => true]);
    }

    public function test_worker_can_accept_pending_request(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);
        $request = ServiceRequest::factory()->create([
            'user_id'           => $user->id,
            'worker_service_id' => $service->id,
            'status'            => 'pending',
        ]);
        $token = $worker->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->putJson("/api/service-requests/{$request->id}/status", ['status' => 'accepted']);

        $response->assertStatus(200)
            ->assertJson(['success' => true]);

        $this->assertDatabaseHas('service_requests', [
            'id'     => $request->id,
            'status' => 'accepted',
        ]);
    }

    public function test_worker_can_complete_accepted_request(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);
        $request = ServiceRequest::factory()->create([
            'user_id'           => $user->id,
            'worker_service_id' => $service->id,
            'status'            => 'accepted',
        ]);
        $token = $worker->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->putJson("/api/service-requests/{$request->id}/status", ['status' => 'completed']);

        $response->assertStatus(200)
            ->assertJson(['success' => true]);
    }

    public function test_wrong_worker_cannot_update_others_request(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        $worker1 = User::factory()->create(['role' => 'worker']);
        $worker2 = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker1->id]);
        $request = ServiceRequest::factory()->create([
            'user_id'           => $user->id,
            'worker_service_id' => $service->id,
            'status'            => 'pending',
        ]);
        $token = $worker2->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->putJson("/api/service-requests/{$request->id}/status", ['status' => 'accepted']);

        $response->assertStatus(403);
    }

    public function test_non_worker_cannot_update_request_status(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);
        $request = ServiceRequest::factory()->create([
            'user_id'           => $user->id,
            'worker_service_id' => $service->id,
            'status'            => 'pending',
        ]);
        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->putJson("/api/service-requests/{$request->id}/status", ['status' => 'accepted']);

        $response->assertStatus(403);
    }

    public function test_invalid_status_transition_is_rejected(): void
    {
        $user = User::factory()->create(['role' => 'user']);
        $worker = User::factory()->create(['role' => 'worker']);
        $service = WorkerService::factory()->create(['worker_id' => $worker->id]);
        $request = ServiceRequest::factory()->create([
            'user_id'           => $user->id,
            'worker_service_id' => $service->id,
            'status'            => 'completed',
        ]);
        $token = $worker->createToken('test')->plainTextToken;

        $response = $this->withHeaders(['Authorization' => 'Bearer ' . $token])
            ->putJson("/api/service-requests/{$request->id}/status", ['status' => 'accepted']);

        $response->assertStatus(400);
    }
}
