<?php

namespace App\Http\Controllers;

use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function show(User $user)
    {
        return response()->json([
            'success' => true,
            'data' => new UserResource($user),
            'message' => 'OK',
            'errors' => null,
        ]);
    }
}
