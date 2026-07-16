<?php

namespace App\Http\Controllers;

use App\Models\Company;
use Illuminate\Http\JsonResponse;

class CompanyController extends Controller
{
    /**
     * Public list feeding the registration form's company dropdown.
     * Exposes only code and name.
     */
    public function index(): JsonResponse
    {
        return response()->json([
            'companies' => Company::query()
                ->orderBy('code')
                ->get(['id', 'code', 'name']),
        ]);
    }
}
