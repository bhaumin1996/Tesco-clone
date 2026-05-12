# Tesco Clone Project Guide

## System Architecture Overview

Tesco Clone is a Clean Architecture monolith built as one deployable .NET 8 Web API with two Angular 18 clients: a customer storefront and an admin panel. The backend uses CQRS with MediatR and FluentValidation, and all database access goes through ADO.NET repositories that execute SQL Server stored procedures.

The system is organized by business module inside the monolith:

- Identity: users, roles, JWT, refresh tokens, RBAC, admin 2FA
- Catalogue: departments, categories, brands, products, variants, inventory
- Order: cart, checkout, orders, payments, refunds
- Delivery: stores, slots, zones, Whoosh-style fast delivery
- Loyalty: Clubcard, points, vouchers, eCoupons
- Promotions: pricing and promotion rules
- Content: CMS pages, banners, recipes, FAQs
- Marketplace: sellers, listings, commissions, disputes
- Analytics: dashboards, reports, exports
- Notification: email, SMS, push notification dispatch

## Technology Stack Decisions

| Area | Decision |
| --- | --- |
| Backend | .NET 8 Web API |
| Architecture | Clean Architecture monolith |
| Application pattern | CQRS with MediatR |
| Validation | FluentValidation pipeline behavior |
| Database | Microsoft SQL Server |
| Data access | ADO.NET only, stored procedures only |
| Authentication | JWT bearer with refresh token rotation |
| Frontend | Angular 18 standalone components |
| State management | Angular Signals for local state, NgRx for shared state |
| Styling | SCSS with BEM-style class naming |
| Testing | Unit tests, integration tests, API tests, Angular tests |
| Deployment | Build, test, database migration, release checklist, rollback-ready |

## Folder Structure Explanation

```text
src/
  TescoClone.Domain/
  TescoClone.Application/
  TescoClone.Infrastructure/
  TescoClone.API/
frontend/
  tesco-storefront/
  tesco-admin/
database/
  migrations/
  stored-procedures/
  functions/
  seed/
tests/
  TescoClone.UnitTests/
  TescoClone.IntegrationTests/
.claude/
  commands/
  rules/
  skills/
```

Domain contains framework-free entities, enums, and domain exceptions. Application contains commands, queries, validators, DTOs, repository interfaces, and pipeline behaviors. Infrastructure implements Application interfaces, including ADO.NET helpers, repositories, token services, password services, and external adapters. API contains controllers, middleware, auth setup, Swagger, and HTTP-only concerns.

## Coding Conventions Summary

- Use namespaces in the form `TescoClone.<Layer>.<Module>`.
- Keep controllers thin; business logic belongs in command/query handlers.
- Use sealed records for DTOs, commands, and queries.
- Keep all I/O methods asynchronous with `Task` or `Task<T>`.
- Enable nullable reference types in all C# projects.
- Use `_camelCase` for private fields.
- Use MediatR pipeline behaviors for validation and logging.
- Use Angular standalone components only.
- Use `ChangeDetectionStrategy.OnPush` on every Angular component.
- Use `inject()` for Angular dependency injection.
- Avoid unmanaged subscriptions; use async pipe, signals, or `takeUntilDestroyed()`.
- Use Conventional Commits.

## Database Safety Rules Summary

Claude must never generate or execute destructive SQL commands such as:

- `DROP DATABASE`
- `DROP SCHEMA`
- `DROP TABLE`
- `TRUNCATE TABLE`
- `DELETE` without a `WHERE` clause

Database changes must be implemented with versioned migration scripts, transactions, audit logging, and rollback planning. Prefer soft deletes using `RecordStatusId = 3` and `IsDeleted = 1`. Every data-modifying stored procedure must write to `t.tblAuditLog`, and every caught database error must write to `t.tblLog` before throwing.

## Deployment Strategy Overview

Deployment follows a release branch flow:

1. Build backend and frontend in release mode.
2. Run all unit, integration, API, and Angular tests.
3. Review database migrations and rollback scripts.
4. Apply migrations in version order.
5. Publish the .NET API.
6. Build Angular storefront and admin assets.
7. Deploy API and frontend assets.
8. Verify `/health`, login, search, cart, checkout, and admin flows.
9. Monitor `t.tblLog` for Error and Critical entries after release.

## Progress Log

| Date | Phase | Summary | Status | Notes |
| --- | --- | --- | --- | --- |
| 2026-05-12 | Phase 1 | Initialized guidance, solution structure, local database convention, and Angular app shells. | Complete | Stop here for developer review before Phase 2. |
