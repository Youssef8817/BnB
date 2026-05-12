<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('properties', function (Blueprint $table) {
            $table->id();
            $table->foreignId('owner_id')->constrained('users');
            $table->string('title', 200);
            $table->text('description');
            $table->decimal('price', 15, 2);
            $table->text('location');
            $table->string('city', 100);
            $table->decimal('area_m2', 8, 2);
            $table->tinyInteger('rooms')->unsigned();
            $table->enum('status', ['available', 'sold', 'pending'])->default('available');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('properties');
    }
};
