<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePropertyRequest extends FormRequest
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
            'title' => 'required|string|min:3|max:200',
            'description' => 'required|string',
            'price' => 'required|numeric|min:0',
            'location' => 'required|string',
            'city' => 'required|string|max:100',
            'area_m2' => 'required|numeric|min:1',
            'rooms' => 'required|integer|min:1|max:20',
            'images' => 'required|array|min:1|max:3',
            'images.*' => 'required|file|mimes:jpg,jpeg,png|max:10240',
        ];
    }
}
