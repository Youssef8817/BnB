<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('worker_services', function (Blueprint $table) {
            $table->id();
            $table->foreignId('worker_id')->constrained('users');
            $table->enum('type', ['plumbing', 'painting', 'tiling', 'electrical', 'carpentry', 'finishing']);
            $table->text('description');
            $table->decimal('price_per_unit', 10, 2);
            $table->string('unit', 50);
            $table->boolean('is_available')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('worker_services');
    }
};
