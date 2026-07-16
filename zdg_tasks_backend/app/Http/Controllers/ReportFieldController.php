<?php

namespace App\Http\Controllers;

use App\Enums\Role;
use App\Models\ReportFieldConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class ReportFieldController extends Controller
{
    /** The registry, grouped by tier, for report viewers. */
    public function index(Request $request): JsonResponse
    {
        Gate::authorize('generate-reports');

        return response()->json([
            'fields' => ReportFieldConfig::query()
                ->orderBy('report_tier')
                ->orderBy('sort_order')
                ->get()
                ->groupBy('report_tier'),
        ]);
    }

    /**
     * Accounts finalise fields here: toggle, relabel, reorder. Global
     * configuration, so restricted to the dof and technical.
     */
    public function update(Request $request, ReportFieldConfig $reportField): JsonResponse
    {
        if (! in_array($request->user()->role, [Role::Dof, Role::Technical], true)) {
            abort(403);
        }

        $data = $request->validate([
            'label' => ['sometimes', 'string', 'max:255'],
            'enabled' => ['sometimes', 'boolean'],
            'sort_order' => ['sometimes', 'integer', 'min:0'],
        ]);

        $reportField->update($data);

        return response()->json(['field' => $reportField]);
    }
}
