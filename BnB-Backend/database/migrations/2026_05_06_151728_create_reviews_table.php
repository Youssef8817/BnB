<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('worker_service_id')->constrained('worker_services');
            $table->tinyInteger('rating')->unsigned();
            $table->text('comment');
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('activity_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users');
            $table->string('action', 100);
            $table->string('model', 100);
            $table->unsignedBigInteger('model_id');
            $table->string('ip_address', 45);
            $table->timestamp('created_at');
        });

        Schema::table('properties', function (Blueprint $table) {
            $table->index('city');
            $table->index('status');
            $table->index('owner_id');
        });

        Schema::table('worker_services', function (Blueprint $table) {
            $table->index('worker_id');
            $table->index('is_available');
        });

        Schema::table('service_requests', function (Blueprint $table) {
            $table->index('user_id');
            $table->index('worker_service_id');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
