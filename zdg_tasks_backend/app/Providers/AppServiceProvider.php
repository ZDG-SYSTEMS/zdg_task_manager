<?php

namespace App\Providers;

use App\Enums\Role;
use App\Models\User;
use App\Services\Push\FcmPushSender;
use App\Services\Push\PushSender;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->singleton(PushSender::class, FcmPushSender::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Reports: company_finance for its own company, dof, technical,
        // and auditor across all companies. Directors and dept heads get
        // none. Company scoping is applied by the report queries.
        Gate::define('generate-reports', fn (User $user): bool => in_array(
            $user->role,
            [Role::Technical, Role::Dof, Role::CompanyFinance, Role::Auditor],
            true,
        ));
    }
}
