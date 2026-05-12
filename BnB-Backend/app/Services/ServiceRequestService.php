<?php

namespace App\Services;

use App\Models\ServiceRequest;
use App\Models\User;
use App\Traits\LogsActivity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ServiceRequestService
{
    use LogsActivity;

    public function create(array $data, User $requester, Request $request): ServiceRequest
    {
        return DB::transaction(function () use ($data, $requester, $request) {
            $serviceRequest = ServiceRequest::create([
                'user_id' => $requester->id,
                'worker_service_id' => $data['worker_service_id'],
                'note' => $data['note'],
                'address' => $data['address'],
            ]);

            $this->logActivity($requester, 'service_request.created', $serviceRequest, $request);

            return $serviceRequest;
        });
    }

    public function updateStatus(ServiceRequest $serviceRequest, string $newStatus, User $actor, Request $request): ServiceRequest
    {
        return DB::transaction(function () use ($serviceRequest, $newStatus, $actor, $request) {
            $workerService = $serviceRequest->workerService;

            if (!$workerService || $workerService->worker_id !== $actor->id) {
                abort(403, 'Only the worker who owns this service may update the request');
            }

            $validTransitions = [
                'pending' => ['accepted', 'cancelled'],
                'accepted' => ['completed', 'cancelled'],
                'completed' => [],
                'cancelled' => [],
            ];

            if (!in_array($newStatus, $validTransitions[$serviceRequest->status] ?? [])) {
                abort(400, 'Invalid status transition');
            }

            $serviceRequest->update(['status' => $newStatus]);

            $this->logActivity($actor, 'service_request.status_changed', $serviceRequest, $request);

            return $serviceRequest;
        });
    }
}
