<?php

namespace App\Http\Requests;

use App\Models\User;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ProfileUpdateRequest extends FormRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => [
                'required',
                'string',
                'lowercase',
                'email',
                'max:255',
                Rule::unique(User::class)->ignore($this->user()->id),
            ],
            'profile_photo' => ['nullable', 'image', 'mimes:jpg,jpeg,png', 'max:2048'],
            'public_email'   => ['nullable', 'email', 'max:255'],
            'soundcloud_url' => ['nullable', 'url', 'max:255', 'starts_with:https://soundcloud.com'], 
            'youtube_url'    => ['nullable', 'url', 'max:255'],
            'daw_info'       => ['nullable', 'string', 'max:100'],
            'bio'            => ['nullable', 'string', 'max:500'],
            'donation_info'  => ['nullable', 'string', 'max:1000'],
        ];
    }
}
