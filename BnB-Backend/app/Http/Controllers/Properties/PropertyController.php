<?php

namespace App\Http\Controllers\Properties;

use App\Http\Controllers\Controller;
use App\Http\Requests\StorePropertyRequest;
use App\Http\Requests\UpdatePropertyRequest;
use App\Http\Requests\UpdatePropertyStatusRequest;
use App\Http\Resources\PropertyCollection;
use App\Http\Resources\PropertyResource;
use App\Models\Property;
use App\Repositories\Contracts\PropertyRepositoryInterface;
use App\Services\PropertyService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class PropertyController extends Controller
{
    public function __construct(
        private PropertyRepositoryInterface $propertyRepository,
        private PropertyService $propertyService,
    ) {}

    public function index(Request $request)
    {
        $properties = $this->propertyRepository->all($request->all());

        return response()->json([
            'success' => true,
            'data'    => new PropertyCollection($properties),
            'message' => 'OK',
            'errors'  => null,
        ]);
    }

    public function show(int $id)
    {
        $property = $this->propertyRepository->findById($id);

        return response()->json([
            'success' => true,
            'data'    => new PropertyResource($property),
            'message' => 'OK',
            'errors'  => null,
        ]);
    }

    public function store(StorePropertyRequest $request)
    {
        $property = $this->propertyService->create(
            $request->validated(),
            $request->file('images'),
            $request->user()->id
        );

        $property->load(['images', 'owner']);

        return response()->json([
            'success' => true,
            'data'    => new PropertyResource($property),
            'message' => 'OK',
            'errors'  => null,
        ], 201);
    }

    public function update(UpdatePropertyRequest $request, Property $property)
    {
        Gate::authorize('update', $property);

        $property = $this->propertyService->update(
            $property,
            $request->validated(),
            $request->file('images'),
            $request->user(),
            $request
        );

        $property->load(['images', 'owner']);

        return response()->json([
            'success' => true,
            'data'    => new PropertyResource($property),
            'message' => 'OK',
            'errors'  => null,
        ]);
    }

    public function updateStatus(UpdatePropertyStatusRequest $request, int $id)
    {
        $property = Property::findOrFail($id);

        Gate::authorize('update', $property);

        $property = $this->propertyService->updateStatus(
            $property,
            $request->validated()['status'],
            $request->user(),
            $request
        );

        return response()->json([
            'success' => true,
            'data'    => new PropertyResource($property),
            'message' => 'OK',
            'errors'  => null,
        ]);
    }

    public function destroy(Request $request, Property $property)
    {
        Gate::authorize('delete', $property);

        $this->propertyService->delete($property, $request->user(), $request);

        return response()->json([
            'success' => true,
            'data'    => null,
            'message' => 'OK',
            'errors'  => null,
        ]);
    }

    public function myProperties(Request $request)
    {
        $properties = $this->propertyRepository->findByOwner($request->user()->id);

        return response()->json([
            'success' => true,
            'data'    => new PropertyCollection($properties),
            'message' => 'OK',
            'errors'  => null,
        ]);
    }
}
