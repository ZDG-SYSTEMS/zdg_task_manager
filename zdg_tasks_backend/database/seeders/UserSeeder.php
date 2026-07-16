<?php

namespace Database\Seeders;

use App\Enums\Role;
use App\Enums\UserStatus;
use App\Models\Company;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class UserSeeder extends Seeder
{
    /**
     * One test user per role. The dof lives at ZDG per CLAUDE.md
     * (single account based at ZDG). Every user belongs to exactly one
     * company even when the role operates cross-company.
     */
    public function run(): void
    {
        $users = [
            [
                'role' => Role::Technical,
                'company' => 'ZDG',
                'name' => 'Test Technical',
                'email' => 'technical@zdg.test',
                'department' => 'IT',
                'position' => 'Systems Administrator',
            ],
            [
                'role' => Role::Director,
                'company' => 'ZDL',
                'name' => 'Test Director',
                'email' => 'director@zdg.test',
                'department' => 'Management',
                'position' => 'Director',
            ],
            [
                'role' => Role::Dof,
                'company' => 'ZDG',
                'name' => 'Test Director of Finance',
                'email' => 'dof@zdg.test',
                'department' => 'Finance',
                'position' => 'Director of Finance',
            ],
            [
                'role' => Role::CompanyFinance,
                'company' => 'ZDC',
                'name' => 'Test Company Finance',
                'email' => 'finance@zdg.test',
                'department' => 'Finance',
                'position' => 'Accounts Officer',
            ],
            [
                'role' => Role::DeptHead,
                'company' => 'IBS',
                'name' => 'Test Department Head',
                'email' => 'depthead@zdg.test',
                'department' => 'Operations',
                'position' => 'Department Head',
            ],
            [
                'role' => Role::Auditor,
                'company' => 'ZDG',
                'name' => 'Test Auditor',
                'email' => 'auditor@zdg.test',
                'department' => 'Audit',
                'position' => 'Auditor',
            ],
        ];

        foreach ($users as $data) {
            $company = Company::query()->where('code', $data['company'])->firstOrFail();

            DB::transaction(function () use ($company, $data): void {
                if (User::query()->where('email', $data['email'])->exists()) {
                    return;
                }

                User::query()->create([
                    'code' => User::nextCodeFor($company),
                    'name' => $data['name'],
                    'email' => $data['email'],
                    'password' => 'password',
                    'company_id' => $company->id,
                    'department' => $data['department'],
                    'branch' => null,
                    'position' => $data['position'],
                    'role' => $data['role'],
                    'status' => UserStatus::Active,
                ]);
            });
        }
    }
}
