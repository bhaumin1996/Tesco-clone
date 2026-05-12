# Tesco Clone TODO

## Status Legend

- `[ ]` Not started
- `[~]` In progress
- `[x]` Complete
- `[!]` Blocked

## Phase 1: Foundation and Project Initialization

- `[x]` Create `.claude` project guidance structure.
- `[x]` Create architecture and workflow documentation.
- `[x]` Create coding, testing, API, database, security, and deployment rules.
- `[x]` Confirm final project naming: new `TescoClone.*` solution structure.
- `[x]` Confirm SQL Server local instance name and database name.
- `[x]` Confirm frontend apps should be created under `frontend/tesco-storefront` and `frontend/tesco-admin`.

## Phase 2: Core Backend and Data Model

- `[ ]` Create or align Clean Architecture projects.
- `[ ]` Add Domain entities for Identity, Catalogue, Order, Delivery, Loyalty, and Promotions.
- `[ ]` Add Application commands, queries, validators, DTOs, and repository interfaces.
- `[ ]` Add Infrastructure ADO.NET connection factory and SQL helper.
- `[ ]` Add API middleware for exceptions, correlation ID, audit logging, security headers, and health checks.
- `[ ]` Create initial database migrations for schemas, reference data, identity, catalogue, order, loyalty, delivery, promotions, content, marketplace, and audit tables.

## Phase 3: Primary Customer Features

- `[ ]` Implement authentication, registration, login, refresh token rotation, and lockout.
- `[ ]` Implement catalogue browsing, product detail, and product search.
- `[ ]` Implement cart operations.
- `[ ]` Implement checkout and order creation.
- `[ ]` Implement delivery slot search and booking.
- `[ ]` Implement Clubcard points and voucher flows.

## Phase 4: Admin, Security, and Operational Features

- `[ ]` Implement admin product, category, inventory, promotion, and order management.
- `[ ]` Implement role-based authorization and admin 2FA.
- `[ ]` Implement audit log and application log review workflows.
- `[ ]` Implement content and marketplace administration.
- `[ ]` Add rate limiting, security headers, and OWASP checks.

## Phase 5: Production Readiness

- `[ ]` Add unit and integration test coverage for critical flows.
- `[ ]` Add API tests for auth, catalogue, cart, checkout, delivery, and admin endpoints.
- `[ ]` Add Angular storefront and admin tests.
- `[ ]` Add CI build, test, lint, and migration validation.
- `[ ]` Prepare release checklist, rollback scripts, and deployment verification.
- `[ ]` Run final smoke test: login, search, add to cart, checkout, admin login, health check.

## Notes

- Implementation must stop after each phase and wait for developer review before continuing.
- Database changes must use safe, idempotent, versioned scripts.
- No destructive SQL is allowed without explicit confirmation and a verified rollback path.
