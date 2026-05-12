<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePropertyRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'title'       => 'sometimes|string|min:3|max:200',
            'description' => 'sometimes|string',
            'price'       => 'sometimes|numeric|min:0',
            'location'    => 'sometimes|string',
            'city'        => 'sometimes|string|max:100',
            'area_m2'     => 'sometimes|numeric|min:1',
            'rooms'       => 'sometimes|integer|min:1|max:20',
            'images'      => 'sometimes|array|min:1|max:3',
            'images.*'    => 'required_with:images|file|mimes:jpg,jpeg,png|max:10240',
        ];
    }
}
