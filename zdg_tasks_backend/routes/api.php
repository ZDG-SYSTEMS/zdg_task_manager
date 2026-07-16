<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BudgetController;
use App\Http\Controllers\CompanyController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\DeviceTokenController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\PettyCashController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\ReportFieldController;
use App\Http\Controllers\TaskApprovalController;
use App\Http\Controllers\TaskAttachmentController;
use App\Http\Controllers\TaskController;
use App\Http\Controllers\TaskReceiptController;
use App\Http\Controllers\UserController;
use App\Http\Middleware\EnsureUserIsActive;
use Illuminate\Support\Facades\Route;

Route::get('/companies', [CompanyController::class, 'index']);

Route::prefix('auth')->group(function (): void {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
});

Route::middleware(['auth:sanctum', EnsureUserIsActive::class])->group(function (): void {
    Route::prefix('auth')->group(function (): void {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
        Route::patch('/me', [AuthController::class, 'updateMe']);
    });

    Route::apiResource('users', UserController::class);

    Route::apiResource('tasks', TaskController::class)->only(['index', 'store', 'show', 'update']);
    Route::post('/tasks/{task}/submit', [TaskController::class, 'submit']);
    Route::post('/tasks/{task}/resubmit', [TaskController::class, 'resubmit']);
    Route::post('/tasks/{task}/attachments', [TaskAttachmentController::class, 'store']);

    Route::get('/tasks/{task}/assignable-funders', [TaskApprovalController::class, 'assignableFunders']);
    Route::post('/tasks/{task}/approve', [TaskApprovalController::class, 'approve']);
    Route::post('/tasks/{task}/reject', [TaskApprovalController::class, 'reject']);
    Route::post('/tasks/{task}/postpone', [TaskApprovalController::class, 'postpone']);
    Route::post('/tasks/{task}/fund', [TaskApprovalController::class, 'fund']);
    Route::post('/tasks/{task}/receipts', [TaskReceiptController::class, 'store']);

    Route::get('/dashboard', [DashboardController::class, 'index']);

    Route::get('/reports/general', [ReportController::class, 'general']);
    Route::get('/reports/comparison', [ReportController::class, 'comparison']);
    Route::get('/reports/in-depth', [ReportController::class, 'inDepth']);
    Route::get('/report-fields', [ReportFieldController::class, 'index']);
    Route::patch('/report-fields/{reportField}', [ReportFieldController::class, 'update']);
    Route::apiResource('budgets', BudgetController::class)->only(['index', 'store', 'update', 'destroy']);

    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{notification}/read', [NotificationController::class, 'markRead']);
    Route::post('/device-tokens', [DeviceTokenController::class, 'store']);
    Route::delete('/device-tokens', [DeviceTokenController::class, 'destroy']);

    Route::post('/petty-cash', [PettyCashController::class, 'store']);
    Route::post('/tasks/{task}/receipts/{receipt}/verify', [PettyCashController::class, 'verifyReceipt'])
        ->scopeBindings();
    Route::post('/tasks/{task}/return-balance', [PettyCashController::class, 'returnBalance']);
    Route::post('/tasks/{task}/close', [PettyCashController::class, 'close']);
});
