<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureWorker
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->role !== 'worker') {
            return response()->json([
                'success' => false,
                'data' => null,
                'message' => 'Forbidden',
                'errors' => ['role' => ['Workers only']],
            ], 403);
        }

        return $next($request);
    }
}
