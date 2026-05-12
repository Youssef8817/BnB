<?php

namespace App\Http\Controllers\Services;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreReviewRequest;
use App\Http\Resources\ReviewResource;
use App\Models\Review;
use App\Models\ServiceRequest;
use App\Models\WorkerService;

class ReviewController extends Controller
{
    public function store(StoreReviewRequest $request, int $workerService)
    {
        $service = WorkerService::findOrFail($workerService);

        $hasCompleted = ServiceRequest::where('user_id', $request->user()->id)
            ->where('worker_service_id', $workerService)
            ->where('status', 'completed')
            ->exists();

        if (!$hasCompleted) {
            return response()->json([
                'success' => false,
                'data' => null,
                'message' => 'Forbidden',
                'errors' => ['status' => ['You can only review after a completed service request']],
            ], 403);
        }

        $alreadyReviewed = Review::where('user_id', $request->user()->id)
            ->where('worker_service_id', $workerService)
            ->exists();

        if ($alreadyReviewed) {
            return response()->json([
                'success' => false,
                'data' => null,
                'message' => 'Validation failed',
                'errors' => ['review' => ['You have already reviewed this service']],
            ], 422);
        }

        $review = Review::create([
            'user_id'           => $request->user()->id,
            'worker_service_id' => $workerService,
            'rating'            => $request->validated()['rating'],
            'comment'           => $request->validated()['comment'],
        ]);

        $review->load('user:id,name', 'workerService:id,type');

        return response()->json([
            'success' => true,
            'data' => new ReviewResource($review),
            'message' => 'OK',
            'errors' => null,
        ], 201);
    }

    public function index(int $workerService)
    {
        $service = WorkerService::findOrFail($workerService);

        $reviews = Review::where('worker_service_id', $workerService)
            ->with('user:id,name')
            ->latest()
            ->paginate(10);

        $avgRating = round((float) ($service->reviews()->avg('rating') ?? 0), 1);

        return response()->json([
            'success' => true,
            'data' => ReviewResource::collection($reviews),
            'message' => 'OK',
            'errors' => null,
            'meta' => [
                'avg_rating'    => $avgRating,
                'total_reviews' => $service->reviews()->count(),
            ],
        ]);
    }
}
