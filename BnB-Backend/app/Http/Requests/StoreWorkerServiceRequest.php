<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreWorkerServiceRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'type' => 'required|in:plumbing,painting,tiling,electrical,carpentry,finishing',
            'description' => 'required|string',
            'price_per_unit' => 'required|numeric|min:0',
            'unit' => 'required|string|max:50',
        ];
    }
}
