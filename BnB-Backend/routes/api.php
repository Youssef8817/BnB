<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Properties\PropertyController;
use App\Http\Controllers\Services\WorkerServiceController;
use App\Http\Controllers\Services\ServiceRequestController;
use App\Http\Controllers\Services\ReviewController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\Admin\AdminController;

Route::middleware('throttle:api')->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
        Route::put('/profile', [AuthController::class, 'updateProfile']);

        Route::post('/properties', [PropertyController::class, 'store']);
        Route::put('/properties/{property}', [PropertyController::class, 'update']);
        Route::put('/properties/{property}/status', [PropertyController::class, 'updateStatus']);
        Route::delete('/properties/{property}', [PropertyController::class, 'destroy']);
        Route::get('/my-properties', [PropertyController::class, 'myProperties']);

        Route::post('/service-requests', [ServiceRequestController::class, 'store']);
        Route::get('/service-requests/mine', [ServiceRequestController::class, 'mine']);
        Route::get('/service-requests/incoming', [ServiceRequestController::class, 'incoming']);
        Route::put('/service-requests/{serviceRequest}/status', [ServiceRequestController::class, 'updateStatus']);

        Route::post('/worker-services/{workerService}/reviews', [ReviewController::class, 'store']);

        Route::middleware('worker')->group(function () {
            Route::get('/my-worker-services', [WorkerServiceController::class, 'myServices']);
            Route::post('/worker-services', [WorkerServiceController::class, 'store']);
            Route::put('/worker-services/{workerService}', [WorkerServiceController::class, 'update']);
            Route::delete('/worker-services/{workerService}', [WorkerServiceController::class, 'destroy']);
        });

        Route::middleware('admin')->group(function () {
            Route::get('/admin/users', [AdminController::class, 'users']);
            Route::get('/admin/stats', [AdminController::class, 'stats']);
            Route::get('/admin/requests', [AdminController::class, 'requests']);
            Route::get('/admin/reviews', [AdminController::class, 'reviews']);
            Route::delete('/admin/reviews/{id}', [AdminController::class, 'deleteReview']);
            Route::put('/admin/properties/{property}', [AdminController::class, 'updateProperty']);
            Route::delete('/admin/users/{id}', [AdminController::class, 'deleteUser']);
            Route::get('/admin/logs', [AdminController::class, 'logs']);
        });
    });

    Route::get('/properties', [PropertyController::class, 'index']);
    Route::get('/properties/{property}', [PropertyController::class, 'show']);
    Route::get('/worker-services', [WorkerServiceController::class, 'index']);
    Route::get('/worker-services/{workerService}', [WorkerServiceController::class, 'show']);
    Route::get('/worker-services/{workerService}/reviews', [ReviewController::class, 'index']);
    Route::get('/users/{user}', [UserController::class, 'show']);
});
