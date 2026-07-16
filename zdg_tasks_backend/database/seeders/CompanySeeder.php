<?php

namespace Database\Seeders;

use App\Models\Company;
use Illuminate\Database\Seeder;

class CompanySeeder extends Seeder
{
    /**
     * The fixed set of five companies. Codes are authoritative
     * (CLAUDE.md); display names come from the supplied brand assets
     * and can be corrected by editing this seeder.
     */
    public function run(): void
    {
        $companies = [
            ['code' => 'ZDG', 'name' => 'Zambezi Diamond Group'],
            ['code' => 'ZDL', 'name' => 'Zambezi Diamond Limited'],
            ['code' => 'ZDC', 'name' => 'Zambezi Diamond Construction'],
            ['code' => 'IBS', 'name' => 'Impact Business Solutions'],
            ['code' => 'BRI', 'name' => 'Blu Reef Investments Ltd'],
        ];

        foreach ($companies as $company) {
            Company::query()->updateOrCreate(
                ['code' => $company['code']],
                ['name' => $company['name']],
            );
        }
    }
}
