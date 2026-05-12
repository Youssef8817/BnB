<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\PropertyResource;
use App\Http\Resources\ReviewResource;
use App\Http\Resources\ServiceRequestResource;
use App\Http\Resources\UserResource;
use App\Http\Requests\AdminUpdatePropertyRequest;
use App\Models\ActivityLog;
use App\Models\Property;
use App\Models\Review;
use App\Models\ServiceRequest;
use App\Models\User;
use App\Repositories\Contracts\UserRepositoryInterface;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    private UserRepositoryInterface $userRepository;

    public function __construct(UserRepositoryInterface $userRepository)
    {
        $this->userRepository = $userRepository;
    }

    public function users(Request $request)
    {
        $users = $this->userRepository->all($request->all());

        return response()->json([
            'success' => true,
            'data' => UserResource::collection($users),
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function stats()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'total_users'      => User::count(),
                'total_workers'    => User::where('role', 'worker')->count(),
                'total_properties' => Property::count(),
                'total_requests'   => ServiceRequest::count(),
                'pending_requests' => ServiceRequest::where('status', 'pending')->count(),
            ],
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function requests(Request $request)
    {
        $query = ServiceRequest::with([
            'user:id,name,phone',
            'workerService:id,type,worker_id',
            'workerService.worker:id,name,phone',
        ]);

        if ($request->filled('status')) {
            $query->where('status', $request->string('status'));
        }

        $serviceRequests = $query->latest()->paginate(10);

        return response()->json([
            'success' => true,
            'data' => ServiceRequestResource::collection($serviceRequests),
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function reviews(Request $request)
    {
        $reviews = Review::with([
            'user:id,name',
            'workerService:id,type',
        ])->latest()->paginate(10);

        return response()->json([
            'success' => true,
            'data' => ReviewResource::collection($reviews),
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function deleteReview(int $id)
    {
        $review = Review::findOrFail($id);
        $review->forceDelete();

        return response()->json([
            'success' => true,
            'data' => null,
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function updateProperty(AdminUpdatePropertyRequest $request, int $id)
    {
        $property = Property::findOrFail($id);

        $property->update(['status' => $request->validated()['status']]);

        return response()->json([
            'success' => true,
            'data' => new PropertyResource($property->load(['images', 'owner'])),
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function deleteUser(int $id)
    {
        $this->userRepository->delete($id);

        return response()->json([
            'success' => true,
            'data' => null,
            'message' => 'OK',
            'errors' => null,
        ]);
    }

    public function logs(Request $request)
    {
        $query = ActivityLog::with('user:id,name,phone');

        if ($request->filled('from')) {
            $query->whereDate('created_at', '>=', $request->string('from'));
        }

        if ($request->filled('to')) {
            $query->whereDate('created_at', '<=', $request->string('to'));
        }

        $logs = $query->latest('created_at')->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $logs,
            'message' => 'OK',
            'errors' => null,
        ]);
    }
}
