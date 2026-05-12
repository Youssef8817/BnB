<?php

namespace App\Repositories\Contracts;

use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use App\Models\Property;

interface PropertyRepositoryInterface
{
    public function all(array $filters): LengthAwarePaginator;

    public function findById(int $id): Property;

    public function findByOwner(int $ownerId): LengthAwarePaginator;

    public function create(array $data): Property;

    public function update(Property $property, array $data): bool;

    public function delete(Property $property): bool;
}
