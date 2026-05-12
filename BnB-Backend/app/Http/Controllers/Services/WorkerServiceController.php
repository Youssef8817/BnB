<?php

namespace App\Http\Controllers\Services;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreWorkerServiceRequest;
use App\Http\Requests\UpdateWorkerServiceRequest;
use App\Http\Resources\WorkerServiceResource;
use App\Models\ServiceRequest;
use App\Models\User;
use App\Models\WorkerService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class WorkerServiceController extends Controller
{
    public function index(Request $request)
    {
        $query = WorkerService::where('is_available', true)
            ->with('worker:id,name,phone')
            ->withAvg('reviews', 'rating')
            ->withCount('reviews');

        if ($request->filled('type')) {
            $query->where('type', $request->string('type'));
        }

        $services = $query->latest()->get();

        return response()->json([
            'success' => true,
            'data' => WorkerServiceResource::collection($services),
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function show(WorkerService $workerService)
    {
        $workerService->load('worker:id,name,phone')
            ->loadAvg('reviews', 'rating')
            ->loadCount('reviews');

        return response()->json([
            'success' => true,
            'data' => new WorkerServiceResource($workerService),
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function store(StoreWorkerServiceRequest $request)
    {
        $validated = $request->validated();

        $service = WorkerService::create([
            'worker_id' => $request->user()->id,
            'type' => $validated['type'],
            'description' => $validated['description'],
            'price_per_unit' => $validated['price_per_unit'],
            'unit' => $validated['unit'],
        ]);

        return response()->json([
            'success' => true,
            'data' => new WorkerServiceResource($service),
            'message' => 'OK',
            'errors' => null,
        ], 201);
    }

    public function update(WorkerService $workerService, UpdateWorkerServiceRequest $request)
    {
        Gate::authorize('update', $workerService);

        $validated = $request->validated();

        $workerService->update($validated);

        return response()->json([
            'success' => true,
            'data' => new WorkerServiceResource($workerService),
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function destroy(WorkerService $workerService)
    {
        Gate::authorize('delete', $workerService);

        if (ServiceRequest::where('worker_service_id', $workerService->id)
            ->where('status', 'pending')
            ->exists()) {
            return response()->json([
                'success' => false,
                'data' => null,
                'message' => 'Forbidden',
                'errors' => ['status' => ['Cannot delete service with pending requests']],
            ], 403);
        }

        $workerService->delete();

        return response()->json([
            'success' => true,
            'data' => null,
            'message' => 'OK',
            'errors' => null,
        ]);
    }
}
