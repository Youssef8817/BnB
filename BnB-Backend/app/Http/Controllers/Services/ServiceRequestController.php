<?php

namespace App\Http\Controllers\Services;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreServiceRequestRequest;
use App\Http\Requests\UpdateServiceRequestStatusRequest;
use App\Http\Resources\ServiceRequestResource;
use App\Models\ServiceRequest;
use App\Services\ServiceRequestService;
use Illuminate\Http\Request;

class ServiceRequestController extends Controller
{
    private ServiceRequestService $serviceRequestService;

    public function __construct(ServiceRequestService $serviceRequestService)
    {
        $this->serviceRequestService = $serviceRequestService;
    }

    public function store(StoreServiceRequestRequest $request)
    {
        $validated = $request->validated();

        $serviceRequest = $this->serviceRequestService->create(
            $validated,
            $request->user(),
            $request
        );
        $serviceRequest->load(['user:id,name,phone', 'workerService.worker:id,name,phone']);

        return response()->json([
            'success' => true,
            'data' => new ServiceRequestResource($serviceRequest),
            'message' => 'OK',
            'errors' => null,
        ], 201);
    }

    public function mine(Request $request)
    {
        $requests = ServiceRequest::where('user_id', $request->user()->id)
            ->with(['user:id,name,phone', 'workerService.worker:id,name,phone'])
            ->latest()
            ->paginate(10);

        return response()->json([
            'success' => true,
            'data' => ServiceRequestResource::collection($requests),
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function incoming(Request $request)
    {
        $serviceIds = $request->user()->workerServices()->pluck('id');

        $requests = ServiceRequest::whereIn('worker_service_id', $serviceIds)
            ->with(['user:id,name,phone', 'workerService.worker:id,name,phone'])
            ->latest()
            ->paginate(10);

        return response()->json([
            'success' => true,
            'data' => ServiceRequestResource::collection($requests),
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function updateStatus(ServiceRequest $serviceRequest, UpdateServiceRequestStatusRequest $request)
    {
        $validated = $request->validated();

        $serviceRequest = $this->serviceRequestService->updateStatus(
            $serviceRequest,
            $validated['status'],
            $request->user(),
            $request
        );
        $serviceRequest->load(['user:id,name,phone', 'workerService.worker:id,name,phone']);

        return response()->json([
            'success' => true,
            'data' => new ServiceRequestResource($serviceRequest),
            'message' => 'OK',
            'errors' => null,
        ]);
    }
}
