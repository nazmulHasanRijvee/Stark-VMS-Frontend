---
title: Stark VMS Frontend Overview
tags:
  - stark-vms
  - flutter
  - assignment-2
---

# Stark VMS — Frontend Project Overview

> Current implementation brief for coding agents working in the Flutter project. Read this before making changes. It updates the original Assignment 1 scope for Assignment 2.

## Product and stack

- Product name and visible branding: **Stark VMS**.
- Frontend: Flutter Web. The existing project uses Riverpod, GoRouter, Dio/Retrofit, and a Clean Architecture structure.
- Backend: Java Spring Boot REST API with PostgreSQL. The backend owns persistence, authentication, authorization, validation, and business rules.
- File storage: Supabase Storage is configured for vehicle documents. Flutter must use the backend's documented upload/download API. Do not put Supabase service credentials in the app or call privileged storage APIs directly.

## Source of truth and outdated notes

Older Assignment 1 notes and the previous backend-focused feature overview may say that drivers, maintenance, documents, or Assignment 2 are out of scope. Those scope statements are superseded by this overview and the current Assignment 2 requirements.

Keep the useful coding conventions from `AGENTS.md`: architecture, design tokens, Riverpod, routing, Retrofit, and shared widgets. Before implementing network features, inspect the current backend source and its latest API contract. Do not assume endpoints, field names, or the `In Service` status from older documentation are still valid. If frontend code, backend code, and this brief disagree about an API detail, report the exact mismatch and follow the actual backend contract. Do not invent requests or silently use mock data.

## Assignment 1 baseline to preserve

Assignment 1 established the Stark VMS shell and core vehicle workflow. Preserve and extend the existing implementation rather than re-scaffolding it. First inspect the app to see which items below are already complete:

- Login and sign-up screens. Sign-up does not require email verification for this assignment.
- JWT **access-token-only** session. There is no refresh-token flow. On an expired or unauthorized session, clear auth state and return the user to login with a clear message.
- Keep the demo-login path available for instructor evaluation. The demo account is managed by the backend; do not hardcode its password or other secrets in Flutter.
- Database-backed vehicle list and vehicle create, view, edit, and delete.
- Duplicate vehicle-number validation, with backend responses displayed clearly.
- Search, filtering, sorting, and pagination must follow the backend's actual server-side contract where provided.
- Dashboard and vehicle-list data should come from API-backed state, not pretend production data or stale mock records.
- Keep the existing responsive Stark VMS visual language and app architecture.

## What changed for Assignment 2

Assignment 2 extends the existing VMS. The old three-state vehicle model is replaced: use **Active**, **Inactive**, and **Maintenance** everywhere. Do not show or submit **In Service**. Status changes are explicit; adding a maintenance record must not change a vehicle's status.

Add these feature areas, matching the latest Stitch design and the actual backend capabilities:

1. **Vehicle documents:** upload Registration, Tax Token, Insurance, Fitness Certificate, or Other. Show the latest upload and retain previous uploads in document history when a document is renewed.
2. **Expiry tracking:** support optional expiry dates and clear Valid, Expiring Soon, Expired, and No Expiry Date states. Expiring Soon means an expiry within the next 30 days. Calculate from the current date; do not hard-code example dates.
3. **Maintenance history:** view and add dated records with maintenance type, cost, workshop/vendor, and notes. Show history for the selected vehicle.
4. **Driver management:** driver CRUD with name, phone, license number, license expiry, and Active/Inactive status.
5. **Driver assignment:** each vehicle has at most one current driver; each driver may be assigned to at most one vehicle at a time. Make inactive or otherwise unavailable drivers ineligible. Provide an assign/change/unassign flow supported by the backend API.
6. **Vehicle list enhancements:** server-side search (prioritize vehicle number and support other fields exposed by the backend), filtering, sorting, and pagination, with accurate loading, error, and empty states.
7. **Dashboard:** connect total vehicles, Active vehicles, vehicles in Maintenance, document-expiry attention, and maintenance-this-month statistics to real backend data. Do not calculate fleet totals from only one page of a paginated list.

Keep navigation simple: **Dashboard**, **Vehicles**, and **Drivers** are primary destinations. Documents and Maintenance belong inside Vehicle Details. Settings and user-management screens remain deferred; keep only an existing future Settings placeholder if it is already part of the design. Roles and fine-grained permission management are deferred, while the backend remains responsible for authorization.

## Theme and language

- Make the shared theme control work across every page, dialog, form, table, and status indicator in light and dark modes. Persist the preference using the existing app preference pattern.
- Make English and Bangla switching functional and persistent. Localize all user-facing text, validation and error states, statuses, empty/loading states, dates, and actions. Check Bangla glyph support and text overflow.
- Keep the same information hierarchy in both themes and languages. Status and expiry meaning must use text as well as color.

## Implementation guidance

1. Inspect the current Flutter source, `AGENTS.md`, localization/theme setup, API client, and latest backend implementation/API docs. Identify what is already complete before editing.
2. Preserve existing Assignment 1 screens and flows. Reuse the current architecture, repositories, Riverpod providers, router, theme tokens, localization ARBs, and shared widgets.
3. Extend Vehicle Details with Overview, Documents, and Maintenance sections. Add Drivers and driver assignment without duplicating actions or creating unnecessary screens.
4. Implement loading, success, validation, empty, and API-error states for every new workflow. Keep network calls in repositories/services, not widgets.
5. Use the actual backend API contract for field names, routes, multipart upload shape, pagination, and error mapping. Never ship fake records as if they came from the server.
6. Keep Supabase credentials and privileged storage operations on the backend. Flutter should call only documented authenticated backend endpoints and use documented download access.
7. Keep role administration, settings screens, email verification, refresh tokens, dispatch/trips, GPS/telematics, fuel tracking, and maintenance scheduling out of scope.

## Acceptance checklist

- Existing login, sign-up, demo login, and vehicle CRUD continue to work with backend data and access-token-only authentication.
- The app uses only Active, Inactive, and Maintenance for vehicle status.
- Search/filter/sort/pagination and dashboard totals agree with backend response semantics.
- Documents can be uploaded and viewed with expiry state and prior-version history; no storage secret is present in Flutter.
- Maintenance records can be created and viewed without automatically changing vehicle status.
- Drivers can be created, edited, listed, and deleted; assignment rules prevent a driver from being assigned to multiple vehicles at once.
- Dashboard summaries and document alerts reflect backend data and current dates.
- Supported screens work in light/dark mode and English/Bangla at desktop and narrow viewport sizes.
- No duplicate primary actions, clipped tables/forms, unreadable status labels, or unintended duplicate screens are introduced.

## Handoff

Before implementation, summarize the current state and any backend/API gaps found. After implementation, list the features completed, the API contracts used, any remaining backend prerequisites, and the Flutter checks run with their results. Do not claim an end-to-end feature is complete when its backend endpoint is unavailable.
