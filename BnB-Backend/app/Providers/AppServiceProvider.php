<?php

namespace App\Providers;

use App\Models\Property;
use App\Models\WorkerService;
use App\Policies\PropertyPolicy;
use App\Policies\WorkerServicePolicy;
use App\Repositories\Contracts\PropertyRepositoryInterface;
use App\Repositories\Contracts\UserRepositoryInterface;
use App\Repositories\Eloquent\EloquentPropertyRepository;
use App\Repositories\Eloquent\EloquentUserRepository;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(PropertyRepositoryInterface::class, EloquentPropertyRepository::class);
        $this->app->bind(UserRepositoryInterface::class, EloquentUserRepository::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Gate::policy(Property::class, PropertyPolicy::class);
        Gate::policy(WorkerService::class, WorkerServicePolicy::class);

        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute($request->user() ? 200 : 60)
                ->by($request->user()?->id ?: $request->ip());
        });
    }
}
