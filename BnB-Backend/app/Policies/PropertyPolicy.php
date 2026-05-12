<?php

namespace App\Policies;

use App\Models\Property;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class PropertyPolicy
{
    /**
     * Determine whether the user can update the property.
     */
    public function update(User $user, Property $property): bool
    {
        return $user->id === $property->owner_id;
    }

    /**
     * Determine whether the user can delete the property.
     */
    public function delete(User $user, Property $property): bool
    {
        return $user->id === $property->owner_id;
    }

    /**
     * Determine whether the user can view the property.
     */
    public function view(User $user, Property $property): bool
    {
        return true;
    }
}
