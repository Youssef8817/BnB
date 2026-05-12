<?php

namespace App\Repositories\Contracts;

use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use App\Models\User;

interface UserRepositoryInterface
{
    public function all(array $filters): LengthAwarePaginator;

    public function findById(int $id): User;

    public function delete(int $id): bool;
}
