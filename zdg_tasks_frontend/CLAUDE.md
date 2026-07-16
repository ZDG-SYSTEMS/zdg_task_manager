# CLAUDE.md — Zambezi Diamond Group Finance Task App

This file is the persistent project context for Claude Code. Read it before every task. The enums, roles, states, and conventions here are authoritative. Do not rename or invent beyond what is written. When something is ambiguous, ask before implementing.

## What this system is

A finance request and tracking system for five companies under Zambezi Diamond Group. Departments raise requests for funds from their company's accounts office. Finance approves, edits, rejects, or postpones. Money is released outside the app; the system tracks authorizations and records, never real money movement. A separate petty cash (imprest) flow issues money first and reconciles receipts afterward.

## Stack

- Backend: Laravel 13, MySQL 8, PHP 8.3. REST API.
- Auth: Laravel Sanctum token auth for the Flutter client.
- Client: Flutter, single codebase for Android, iOS, and web.
- Notifications: Firebase Cloud Messaging (push), email, and in-app records. All three channels fire per event unless a channel is unavailable for that user.

## Hard conventions

- Money is stored as integer minor units (ngwee) in ZMW. Never store money as float. Display as ZMW with two decimals.
- No emojis anywhere: not in code, comments, UI copy, commit messages, or generated documents. If an icon is needed, use a coded SVG or the client's icon set, and only when asked.
- Code comments explain intent and non-obvious logic. No decorative comments, no ASCII art.
- All authorization is enforced server-side. The client hides controls for convenience only; the API is the source of truth for every permission.
- Ask before assuming any field, state, permission, or behavior not specified here or in the phase prompt.

## Companies (seeded, fixed)

ZDG, ZDL, ZDC, IBS, BRI. Every user belongs to exactly one company. Director of Finance and Auditor operate across all companies. Technical is cross-company for maintenance only.

## Roles

`technical`, `director` (Director/Manager), `dof` (Director of Finance), `company_finance`, `dept_head` (Dept Head/Assistant), `auditor`.

Permission summary (enforce server-side; see the RBAC phase for full rules):

- technical: exercises any feature to test and fix. Every technical action except user-account management is tamper-flagged (`via_technical = true`) and re-queued to the correct office. Never funds anything, never produces a real external effect. A technical-flagged action is never a genuine authorization. Full user-account CRUD.
- director: read-only within own company. May create standard requests. No reports, no approvals.
- dof: single account at ZDG. Approves, edits, rejects, postpones, funds across all companies. May approve-and-assign to a company finance user. Reports across all companies. Cannot manage other users' accounts.
- company_finance: approves, edits, rejects, postpones, funds for own company only. Cannot assign. Creates petty cash. Verifies receipts and closes. Reports for own company.
- dept_head: creates standard requests only, views own tasks only, edits own account.
- auditor: read-only across all companies, generates reports across all companies, cannot create anything, edits own account.

Anyone may self-register (dropdown-driven form: company, department, branch, position) but never chooses a role. New accounts start `inactive` with no role and cannot log in. Technical assigns the role, which activates the account. Self-editable fields on one's own account: name, email, password. Only technical creates, fully edits, and deletes accounts.

## User record

Incremental ID in the format `ABC000` (three-letter prefix, zero-padded incrementing number). Fields: name, department, company, branch, position, role, status (`active` / `inactive`), email. Name and position auto-attach to any request the user creates and display to the creator.

## Task model

One `tasks` table, discriminated by `type`: `standard` or `petty_cash`.

States: `draft`, `submitted`, `pending_approval`, `approved`, `pending_receipt`, `completed`, `rejected`, `postponed`, `escalated`. `overdue` is a boolean flag on any live state, driven by due date, not a separate state. Postpone returns the same record to `pending_approval` with a new due date; it never creates a second record.

Every state transition writes an immutable audit entry: actor, actor role, company, from-state, to-state, reason (if any), timestamp, and `via_technical`.

## Funding record (mark-as-funded)

Money is released outside the app. After approval, the funder (dof or company_finance) records the release as a data-only entry: `funded_at`, `funded_reference`, `funded_amount`, `funded_by`, plus a `funded` flag. No money moves in-app. Completion still follows the receipt rule; funding is a recorded overlay, not a blocking state. Cash-released figures in reports are driven by `funded_amount`, never by approved amounts. Who was paid and how much is read from verified receipts; there is no separate supplier field. There is no expense category; task nature lives in the description.

## Budgets (optional)

Budgets are optional and set by finance: company_finance for its own company, dof across all. A budget is scoped to a department within a company for a chosen period. It is drawn down by funded amount (aligned with the funding record above). Where a budget is set, its position (funded-to-date vs budget) is visible to that department's members and to finance. Where no budget is set for a department and period, no budget UI appears at all.

## Priority (approver-visible only)

Computed from days until the next approval window (approvals on Monday and Tuesday; Sunday is not a work day). Recomputed daily by a scheduled job.

- 1 to 2 days away (created Sat/Sun): High
- 3 to 4 days away (created Thu/Fri): Medium
- 5 or more days away (created Wed or early week): Low
- Due today: Urgent (overrides all)

The requester never sees priority. The due date does not otherwise feed priority beyond the due-today Urgent override.

## Expiry and escalation

Daily job. A normal task that passes two full priority cycles without action, or an urgent task overdue for two weeks, escalates to the Director of Finance and sits as `escalated` (overdue) on the DoF queue indefinitely until the DoF accepts or rejects. Escalation is never a silent hard reject.

## Attachments

PNG, JPEG, PDF, Word. Max 5 MB per file. Used for quotations and invoices at request time and receipts after the fact.

## Assets folder convention

Design and brand assets are supplied in the attached assets folder. Files are labelled by a suffix that tells you how to treat them:

- `*_import` — import the asset into the application itself. Copy it into the app asset pipeline (Flutter `assets/`, or backend storage as appropriate) and wire it up in code. Examples: `logo_import.png`, `brand_icon_import.svg`. These ship inside the product.
- `*_copy` — a design reference to copy from, not to ship. Reproduce its layout, spacing, colour, or structure in code. Do not embed the file itself. Examples: `dashboard_mockup_copy.png`, `login_layout_copy.pdf`.

If a file's suffix is missing or ambiguous, ask before using it. Extract brand colours from provided logos programmatically where useful rather than eyeballing hex values.

## Flutter client architecture

Single Flutter codebase for Android, iOS, and web. Use this architecture; do not substitute patterns.

- State management: Riverpod 3.x with code generation (the `@riverpod` annotation with `Notifier` and `AsyncNotifier`). Do not use the legacy providers `StateProvider`, `StateNotifierProvider`, or `ChangeNotifierProvider` (moved to `package:riverpod/legacy.dart` in 3.0). Run `dart run build_runner watch` during development so generated files stay current.
- Navigation: go_router, with declarative routes and role-based redirect guards that read the auth/permission provider. This also gives correct URL handling on the web target.
- HTTP: dio, with an interceptor that attaches the Sanctum bearer token to every request and centralises error handling. Repositories call dio; widgets never call it directly.
- Token storage: flutter_secure_storage on mobile. Web falls back to a less-secure browser store, so treat the web token as lower-trust and keep token lifetimes short.
- Models and serialisation: freezed with json_serializable for immutable models. Enforce money as integer minor units (ngwee) in the model types so it can never become a double. Mirror the server enums exactly: roles, task states, task types, priority bands.
- Async UI: render loading, data, and error from Riverpod `AsyncValue`; do not hand-roll loading booleans.

Layering is feature-first with a thin repository layer. Per feature: `data/` (repositories, DTOs), `application/` (Notifier controllers, permission logic), `presentation/` (screens, widgets). Shared concerns live in `core/` (dio, router, theme, error types) and `shared/` (reusable widgets, money formatting, enum mirrors). Do not introduce a use-case class per action; repository plus Notifier is the intended weight for this app.

```
lib/
  core/
  features/
    auth/         { data, application, presentation }
    requests/
    approvals/
    petty_cash/
    dashboard/
    reports/
  shared/
  main.dart
```

## Build order

Follow the numbered phase prompts in order. Confirm each phase compiles, passes its checks, and is reviewed before starting the next. Do not skip ahead or bundle phases. Authorization (Phase 2) must be correct and tested before any lifecycle work builds on it.