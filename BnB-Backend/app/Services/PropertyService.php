<?php

namespace App\Services;

use App\Models\Property;
use App\Models\User;
use App\Traits\LogsActivity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class PropertyService
{
    use LogsActivity;

    public function create(array $data, array $imageFiles, int $ownerId): Property
    {
        return DB::transaction(function () use ($data, $imageFiles, $ownerId) {
            $property = Property::create([
                'owner_id' => $ownerId,
                'title' => $data['title'],
                'description' => $data['description'],
                'price' => $data['price'],
                'location' => $data['location'],
                'city' => $data['city'],
                'area_m2' => $data['area_m2'],
                'rooms' => $data['rooms'],
            ]);

            foreach ($imageFiles as $index => $image) {
                $path = $image->store('properties', 'public');
                $property->images()->create([
                    'path' => $path,
                    'display_order' => $index,
                ]);
            }

            return $property;
        });
    }

    public function update(Property $property, array $data, ?array $imageFiles, User $actor, Request $request): Property
    {
        return DB::transaction(function () use ($property, $data, $imageFiles, $actor, $request) {
            $property->update(array_intersect_key($data, array_flip([
                'title', 'description', 'price', 'location', 'city', 'area_m2', 'rooms',
            ])));

            if (!empty($imageFiles)) {
                foreach ($property->images as $image) {
                    Storage::disk('public')->delete($image->path);
                }
                $property->images()->delete();

                foreach ($imageFiles as $index => $image) {
                    $path = $image->store('properties', 'public');
                    $property->images()->create([
                        'path' => $path,
                        'display_order' => $index,
                    ]);
                }
            }

            $this->logActivity($actor, 'property.updated', $property, $request);

            return $property->fresh('images');
        });
    }

    public function delete(Property $property, ?User $actor = null, ?Request $request = null): void
    {
        DB::transaction(function () use ($property, $actor, $request) {
            foreach ($property->images as $image) {
                Storage::disk('public')->delete($image->path);
            }

            $property->images()->delete();
            $property->delete();

            if ($actor && $request) {
                $this->logActivity($actor, 'property.deleted', $property, $request);
            }
        });
    }

    public function updateStatus(Property $property, string $newStatus, User $actor, Request $request): Property
    {
        return DB::transaction(function () use ($property, $newStatus, $actor, $request) {
            $validTransitions = [
                'available' => ['pending', 'sold'],
                'pending' => ['available', 'sold'],
                'sold' => [],
            ];

            $currentStatus = $property->status;
            if (!in_array($newStatus, $validTransitions[$currentStatus] ?? [])) {
                abort(400, 'Invalid status transition');
            }

            $property->update(['status' => $newStatus]);

            $this->logActivity($actor, 'property.status_changed', $property, $request);

            return $property;
        });
    }
}
