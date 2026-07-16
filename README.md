# ZDG Tasks - Zambezi Diamond Group Finance Task App

A finance request and tracking system for the five ZDG companies (ZDG, ZDL,
ZDC, IBS, BRI). Departments raise fund requests; finance approves, edits,
rejects, or postpones; money is released outside the app and recorded as a
funding entry. A separate petty cash (imprest) flow issues money first and
reconciles receipts afterwards. The system tracks authorizations and records;
it never moves real money.

The authoritative specification lives in `zdg_tasks_frontend/CLAUDE.md`,
`Phases.md`, and `tasks_prompt.md`.

## Layout

Two-folder monorepo:

- `zdg_tasks_backend/` - Laravel 13 REST API (PHP 8.4, MySQL 8, Sanctum).
- `zdg_tasks_frontend/` - Flutter client (Android, iOS, web); Riverpod 3 with
  code generation, go_router, dio, freezed.
- `scripts/` - repo tooling, including the no-emoji check enforced by the
  pre-commit hook (`git config core.hooksPath .githooks`).

## Backend

```
cd zdg_tasks_backend
composer install
cp .env.example .env        # fill DB_* and (optionally) FIREBASE_CREDENTIALS
php artisan key:generate
php artisan migrate:fresh --seed
php artisan test
```

Seeded test accounts (password `password`): technical@zdg.test,
director@zdg.test, dof@zdg.test, finance@zdg.test, depthead@zdg.test,
auditor@zdg.test.

Local dev server (use the built-in server with the index router; on this
machine `artisan serve` spawns workers without TMP and breaks uploads):

```
php -S 127.0.0.1:8000 -t public public/index.php
```

Daily jobs (priority recompute, overdue flags, escalation) run from the
scheduler: `php artisan schedule:work` in development, a cron entry for
`php artisan schedule:run` in production.

## Frontend

```
cd zdg_tasks_frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

`API_BASE_URL` defaults to `http://localhost:8000/api`; point it at the
staging or production API per target.

## Push notifications (FCM)

The backend sends FCM over the HTTP v1 API once `FIREBASE_CREDENTIALS` in
`.env` points at a Firebase service-account JSON. The Android app is wired
through `android/app/google-services.json`; web and iOS need
`flutterfire configure` to generate `lib/firebase_options.dart`. Until
configured, push quietly reports itself unavailable and email plus in-app
records carry every event.

## Conventions

- Money is integer minor units (ngwee) end to end; never floats.
- All authorization is enforced server-side; the client only hides controls.
- Every state transition writes an immutable audit entry; technical actions
  are tamper-flagged (`via_technical`) and never count as genuine
  authorizations.
- No emojis anywhere in code, copy, or documents (enforced by the pre-commit
  hook).
