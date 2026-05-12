<?php

namespace App\Repositories\Eloquent;

use App\Repositories\Contracts\PropertyRepositoryInterface;
use App\Models\Property;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class EloquentPropertyRepository implements PropertyRepositoryInterface
{
    public function all(array $filters): LengthAwarePaginator
    {
        $query = Property::query()->with('images');

        if (!empty($filters['city'])) {
            $query->where('city', $filters['city']);
        }

        if (!empty($filters['status'])) {
            $query->where('status', $filters['status']);
        } else {
            $query->where('status', 'available');
        }

        if (!empty($filters['min_price'])) {
            $query->where('price', '>=', $filters['min_price']);
        }

        if (!empty($filters['max_price'])) {
            $query->where('price', '<=', $filters['max_price']);
        }

        if (!empty($filters['rooms'])) {
            $query->where('rooms', $filters['rooms']);
        }

        return $query->latest()->paginate(10);
    }

    public function findById(int $id): Property
    {
        return Property::with(['images', 'owner:id,name,phone'])->findOrFail($id);
    }

    public function findByOwner(int $ownerId): LengthAwarePaginator
    {
        return Property::where('owner_id', $ownerId)
            ->with('images')
            ->latest()
            ->paginate(10);
    }

    public function create(array $data): Property
    {
        return Property::create($data);
    }

    public function update(Property $property, array $data): bool
    {
        return $property->update($data);
    }

    public function delete(Property $property): bool
    {
        return (bool) $property->delete();
    }
}
