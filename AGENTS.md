# Stark VMS — Agent Guidelines

Stark VMS is a Flutter Web fleet-management frontend backed by a Java Spring Boot REST API and PostgreSQL. This repository contains the Flutter application.

## Assignment 2 source of truth

Read [`feature_overview.md`](feature_overview.md) before starting frontend work. It defines the current Assignment 2 scope and supersedes older Assignment 1 notes and the previous backend-focused feature overview. Preserve the useful architecture and implementation conventions in this file.

The overview is a product and scope brief, not an API contract. Before adding or changing network features, inspect the current Flutter implementation and the latest backend source or API documentation. Follow the actual backend contract for routes, fields, validation, uploads, pagination, and errors. Report mismatches; do not invent endpoints, assume examples from older docs are current, or present mock data as backend data.

## Scope and baseline

- Preserve and extend the existing login, sign-up, dashboard, vehicle list, and vehicle CRUD flows. Inspect what already works before rebuilding anything.
- Keep the JWT access-token-only session. There is no refresh-token flow. Handle unauthorized sessions by clearing auth state and returning to login with a clear message.
- Keep the instructor demo-login path if present. Demo credentials are backend-managed; never hardcode passwords, tokens, or service secrets in Flutter.
- Assignment 2 adds vehicle documents and expiry history, vehicle maintenance history, driver CRUD, driver assignment, enhanced server-side vehicle listing, and API-backed dashboard metrics. Follow [`feature_overview.md`](feature_overview.md) for details and acceptance criteria.
- Vehicle statuses are **Active**, **Inactive**, and **Maintenance**. Do not display or submit **In Service**. Adding a maintenance record must not change vehicle status.
- Primary navigation is Dashboard, Vehicles, and Drivers. Put Documents and Maintenance inside Vehicle Details. Do not add deferred admin, settings, dispatch, GPS, fuel, scheduling, or refresh-token features.

## Architecture

Use the existing Clean Architecture and feature-sliced layout:

```text
lib/
├── app.dart
├── main.dart
└── src/
    ├── core/                  # Bootstrap, extensions, logging, utilities
    ├── data/                   # DTOs, repository implementations, services
    ├── domain/                 # Entities and repository contracts
    └── presentation/
        ├── core/                # App state, routing, theme, shared widgets
        └── feature/<feature>/   # view/, view_model/, feature widgets
```

Keep network calls in repositories/services and business rules in domain or view-model code, not screen widgets. Reuse existing providers, repositories, router, theme, localization, and widgets. Extend the current app; do not re-scaffold it.

## Flutter implementation rules

### Design and localization

- Use theme extensions: `context.color`, `context.spacing`, `context.sizes`, `context.radius`, and `context.textStyle`.
- Do not add raw colors, fixed spacing values, or ad hoc radii to presentation features when a theme token exists.
- Check `lib/src/presentation/core/widgets/` before creating inputs, dropdowns, loading UI, toasts, images, empty states, or not-found UI. Existing shared widgets include `AppTextField`, `AppDropdown`, `MultiSelectDropdown`, `CustomToast`, `CustomLoadingIndicator`, `CustomNetworkImage`, `EmptyStateWidget`, and `NotFoundScreen`.
- Keep English and Bangla complete and persistent. Localize labels, validation, API errors, statuses, dates, and loading/empty states. Check Bangla glyph support and narrow-screen overflow.
- Convey status and expiry with text as well as color; calculate expiry relative to the current date.

### State and navigation

- Use Riverpod `NotifierProvider` or `AsyncNotifierProvider` for feature state. Represent loading, error, empty, and success states explicitly; use `AsyncValue.guard` for async operations where appropriate.
- Keep redirects state-driven. Put route gating in `RedirectGate`; do not call `context.go()` from a redirect callback.
- Add paths to `lib/src/presentation/core/router/routes.dart` and organize route branches under `lib/src/presentation/core/router/parts/`.
- Keep details workflows within Vehicle Details where the overview calls for it; avoid duplicate primary actions or unnecessary screens.

### Networking and security

- Define endpoint constants in `lib/src/data/services/network/endpoints.dart` and Retrofit methods in `rest_client.dart`.
- Route API requests through `Api.call` in repositories. Map response/error shapes from the actual backend contract.
- After changing Retrofit interfaces or generated models, run `dart run build_runner build --delete-conflicting-outputs` and review generated changes.
- Attach only the documented access token to protected API calls. Do not add refresh-token behavior.
- Vehicle documents use the backend's documented upload/download API. Never place Supabase service credentials in Flutter or call privileged Supabase APIs directly.

## Before handing off

Summarize the current implementation and any backend/API gaps before a substantial feature build. At completion, list what changed, the API contracts used, remaining backend prerequisites, and checks run with their results. Do not claim an end-to-end workflow is complete when its backend endpoint is unavailable.

Detailed project rules and skills are in [`.agents/rules/`](.agents/rules/) and [`.agents/skills/`](.agents/skills/).
