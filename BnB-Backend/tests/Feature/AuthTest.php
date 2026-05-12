<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_as_user(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'password123',
            'phone' => '+1234567890',
            'role' => 'user',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'user' => [
                        'id', 'name', 'email', 'phone', 'role', 'avatar_url'
                    ],
                    'token'
                ],
                'message',
                'errors'
            ])
            ->assertJson(['success' => true, 'message' => 'OK']);

        $this->assertDatabaseHas('users', [
            'email' => 'test@example.com',
            'role' => 'user'
        ]);
    }

    public function test_user_can_register_as_worker(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Test Worker',
            'email' => 'worker@example.com',
            'password' => 'password123',
            'phone' => '+1234567890',
            'role' => 'worker',
        ]);

        $response->assertStatus(201)
            ->assertJson(['success' => true, 'message' => 'OK']);

        $this->assertDatabaseHas('users', [
            'email' => 'worker@example.com',
            'role' => 'worker'
        ]);
    }

    public function test_user_cannot_register_as_admin(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Test Admin',
            'email' => 'admin@example.com',
            'password' => 'password123',
            'phone' => '+1234567890',
            'role' => 'admin',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['role']);
    }

    public function test_user_can_login_with_correct_credentials(): void
    {
        User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password123'),
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'user',
                    'token'
                ],
                'message',
                'errors'
            ])
            ->assertJson(['success' => true, 'message' => 'OK']);
    }

    public function test_login_fails_with_wrong_password(): void
    {
        User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password123'),
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401)
            ->assertJson(['success' => false]);
    }

    public function test_user_can_logout(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test-token')->plainTextToken;

        $response = $this->withHeaders([
            'Authorization' => 'Bearer ' . $token,
        ])->postJson('/api/auth/logout');

        $response->assertStatus(200)
            ->assertJson(['success' => true, 'message' => 'OK']);

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }
}
