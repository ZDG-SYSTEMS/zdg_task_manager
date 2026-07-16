<?php

namespace App\Http\Controllers;

use App\Services\ReportService;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    public function __construct(private readonly ReportService $reports) {}

    public function general(Request $request): JsonResponse|StreamedResponse
    {
        [$start, $end, $companyId] = $this->window($request);

        $report = $this->reports->general($request->user(), $start, $end, $companyId);

        if ($request->query('format') === 'csv') {
            return $this->csv('general-report', $this->flatten($report));
        }

        return response()->json(['report' => $report]);
    }

    public function comparison(Request $request): JsonResponse|StreamedResponse
    {
        [$start, $end, $companyId] = $this->window($request);

        $report = $this->reports->comparison($request->user(), $start, $end, $companyId);

        if ($request->query('format') === 'csv') {
            return $this->csv('comparison-report', $this->flatten($report));
        }

        return response()->json(['report' => $report]);
    }

    public function inDepth(Request $request): JsonResponse|StreamedResponse
    {
        [$start, $end, $companyId] = $this->window($request);

        $report = $this->reports->inDepth($request->user(), $start, $end, $companyId);

        if ($request->query('format') === 'csv') {
            $rows = collect($report['tasks'])->map(fn (array $row) => $this->flattenRow($row));

            return $this->csvRows('in-depth-report', $rows->all());
        }

        return response()->json(['report' => $report]);
    }

    /**
     * Weekly or monthly window around a reference date. Authorization
     * is checked here for every tier.
     *
     * @return array{0: CarbonImmutable, 1: CarbonImmutable, 2: ?int}
     */
    private function window(Request $request): array
    {
        Gate::authorize('generate-reports');

        $validated = $request->validate([
            'period' => ['nullable', 'in:weekly,monthly'],
            'date' => ['nullable', 'date'],
            'company_id' => ['nullable', 'integer', 'exists:companies,id'],
            'format' => ['nullable', 'in:csv'],
        ]);

        $reference = CarbonImmutable::parse($validated['date'] ?? today());

        [$start, $end] = ($validated['period'] ?? 'monthly') === 'weekly'
            ? [$reference->startOfWeek(), $reference->endOfWeek()]
            : [$reference->startOfMonth(), $reference->endOfMonth()];

        return [$start, $end, isset($validated['company_id']) ? (int) $validated['company_id'] : null];
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, string>
     */
    private function flatten(array $data, string $prefix = ''): array
    {
        $flat = [];
        foreach ($data as $key => $value) {
            $path = $prefix === '' ? (string) $key : "{$prefix}.{$key}";
            if (is_array($value) || is_object($value)) {
                $encoded = json_decode(json_encode($value), true);
                if (is_array($encoded) && $encoded !== [] && ! array_is_list($encoded)) {
                    $flat = [...$flat, ...$this->flatten($encoded, $path)];
                } else {
                    $flat[$path] = json_encode($encoded);
                }
            } else {
                $flat[$path] = $value instanceof \BackedEnum ? $value->value : (string) $value;
            }
        }

        return $flat;
    }

    /** @param array<string, mixed> $row */
    private function flattenRow(array $row): array
    {
        return array_map(
            fn ($value) => is_scalar($value) || $value === null
                ? $value
                : json_encode($value),
            $row,
        );
    }

    /** @param array<string, string> $pairs */
    private function csv(string $name, array $pairs): StreamedResponse
    {
        return response()->streamDownload(function () use ($pairs): void {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, ['field', 'value']);
            foreach ($pairs as $key => $value) {
                fputcsv($handle, [$key, $value]);
            }
            fclose($handle);
        }, "{$name}.csv", ['Content-Type' => 'text/csv']);
    }

    /** @param list<array<string, mixed>> $rows */
    private function csvRows(string $name, array $rows): StreamedResponse
    {
        return response()->streamDownload(function () use ($rows): void {
            $handle = fopen('php://output', 'w');
            if ($rows !== []) {
                fputcsv($handle, array_keys($rows[0]));
                foreach ($rows as $row) {
                    fputcsv($handle, array_values($row));
                }
            }
            fclose($handle);
        }, "{$name}.csv", ['Content-Type' => 'text/csv']);
    }
}
