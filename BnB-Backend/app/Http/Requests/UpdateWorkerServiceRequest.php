<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateWorkerServiceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'type'           => 'sometimes|in:plumbing,painting,tiling,electrical,carpentry,finishing',
            'description'    => 'sometimes|string',
            'price_per_unit' => 'sometimes|numeric|min:0',
            'unit'           => 'sometimes|string|max:50',
            'is_available'   => 'sometimes|boolean',
        ];
    }
}
