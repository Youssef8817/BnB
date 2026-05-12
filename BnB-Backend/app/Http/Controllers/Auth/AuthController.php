<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'phone' => "required|string|max:20",
            'role' => "required|in:user,worker",
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'phone' => $validated['phone'],
            'role' => $validated['role'],
        ]);

        $token = $user->createToken('auth')->plainTextToken;

        return response()->json([
            'success' => true,
            'data' => ['user' => new UserResource($user), 'token' => $token],
            'message' => 'OK',
            'errors' => null,
        ], 201);
    }

    public function login(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if (!Auth::attempt($validated)) {
            return response()->json([
                'success' => false,
                'data' => null,
                'message' => 'Unauthorized',
                'errors' => ['email' => ['Invalid credentials']],
            ], 401);
        }

        $user = $request->user();
        $token = $user->createToken('auth')->plainTextToken;

        return response()->json([
            'success' => true,
            'data' => ['user' => new UserResource($user), 'token' => $token],
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'data' => null,
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => new UserResource($request->user()),
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function updateProfile(Request $request)
    {
        $validated = $request->validate([
            'name'  => 'sometimes|string|max:100',
            'phone' => 'sometimes|string|max:20',
        ]);

        $user = $request->user();
        $user->update($validated);

        return response()->json([
            'success' => true,
            'data'    => new UserResource($user->fresh()),
            'message' => 'OK',
            'errors'  => null,
        ]);
    }
}
