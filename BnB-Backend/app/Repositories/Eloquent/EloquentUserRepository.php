<?php

namespace App\Repositories\Eloquent;

use App\Repositories\Contracts\UserRepositoryInterface;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class EloquentUserRepository implements UserRepositoryInterface
{
    public function all(array $filters): LengthAwarePaginator
    {
        $query = User::select('id', 'name', 'email', 'phone', 'role', 'created_at');

        if (!empty($filters['role'])) {
            $query->where('role', $filters['role']);
        }

        return $query->latest()->paginate(10);
    }

    public function findById(int $id): User
    {
        return User::select('id', 'name', 'phone', 'role', 'avatar_url')->findOrFail($id);
    }

    public function delete(int $id): bool
    {
        $user = User::findOrFail($id);
        return (bool) $user->delete();
    }
}
