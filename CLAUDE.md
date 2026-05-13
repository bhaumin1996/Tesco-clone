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
| 2026-05-12 | Phase 2 | Added Domain entities/enums/exceptions for all modules; Application layer (MediatR handlers, FluentValidation, pipeline behaviors, repository interfaces, DTOs); Infrastructure (SqlConnectionFactory, SqlHelper, repository stubs, PasswordService, TokenService); API middleware (CorrelationId, SecurityHeaders, Exception); Swagger + JWT auth wiring; 12 versioned SQL migration scripts (V001–V012). All 7 tests pass. | Complete | Stop here for developer review before Phase 3. |
| 2026-05-13 | Phase 3 | Implemented all 6 primary customer features: (1) Auth — register, login, refresh token rotation, revoke, profile, User.Hydrate, SHA-256 refresh token hashing, stored procedures V013; (2) Catalogue — departments, categories, product detail, variants, search; DepartmentRepository, CategoryRepository, stored procedures V014; (3) Cart — get, add, update, remove, clear; stored procedures V015; (4) Orders — place, cancel, get by id, get my orders; OrderRepository, stored procedures V016; (5) Delivery — slot search (postcode+date range), slot booking with UPDLOCK concurrency guard; DeliveryRepository, stored procedures V017; (6) Loyalty — Clubcard points (earn/redeem), vouchers (list/redeem with expiry validation); LoyaltyRepository, VoucherRepository, stored procedures V018. All 7 tests pass, 0 build errors. | Complete | Stop here for developer review before Phase 4. |
| 2026-05-13 | Phase 4 | Implemented all 5 admin/security features: (1) RBAC + Admin 2FA — Admin/SuperAdmin policies, ITwoFactorService (6-digit SHA-256), AdminLoginCommand (first-factor), VerifyTwoFactorCommand (second-factor), IAdminUserRepository, lock/unlock/assign-role commands, V019 migration; (2) Admin Catalogue/Inventory/Promotions/Orders — CRUD for products, categories, departments, inventory adjustment, promotion lifecycle (create/update/delete), admin order list/status update/refund, V020–V022 migrations; (3) Audit + Application Log Review — IAuditLogRepository, IApplicationLogRepository, paginated queries with filters, AdminAuditController, V023 migration; (4) Content + Marketplace — page/banner CRUD (IContentRepository), seller approve/suspend + dispute resolution (IMarketplaceRepository), AdminContentController, AdminMarketplaceController, V024–V025 migrations; (5) Rate Limiting + OWASP — ASP.NET Core RateLimiter (auth=10/min fixed, api=100/min sliding, public=200 token bucket), enhanced SecurityHeadersMiddleware (HSTS, CSP, CORP, COOP, Permissions-Policy, cache-control for auth+admin routes), AuthorizationPolicies constants, full DI wiring in InfrastructureServices. | Complete | Stop here for developer review before Phase 5. |
| 2026-05-13 | Phase 5 | Implemented complete Angular 18 frontend for both apps. Storefront (tesco-storefront): SCSS design system (tokens, reset, mixins, buttons, forms, badges, cards, layout), functional auth interceptor + guard, signal-based services (Auth, Cart, Catalogue, Order, Delivery, Loyalty, Notification), shared components (Header with department nav/account dropdown/cart badge, Footer, ProductCard with Clubcard pricing, Spinner, Pagination, Breadcrumb, QuantityStepper, Alert toasts), and 15+ feature pages (Home, Login, Register, Departments, Category with filters, Product Detail with variants/nutritional tabs, Search, Cart, Checkout 3-step, Order List/Detail, Account Dashboard, Clubcard, Delivery Slots, Store Locator, Recipes, Help/FAQ). Admin panel (tesco-admin): admin SCSS design system with sidebar layout and utility classes, AdminAuthService with 2FA two-step flow, admin auth interceptor + guard, AdminLayout shell (fixed sidebar with grouped nav, sticky topbar, mobile toggle), and 11 admin feature pages (Login/2FA, Dashboard with KPIs, Products, Categories, Inventory, Orders, Promotions, Marketplace with seller/dispute tabs, Users, Content CMS/banners, Analytics with date-range + CSV export, Audit & Logs). All routes lazy-loaded; admin routes protected by adminAuthGuard inside AdminLayout shell. | Complete | Stop here for developer review before Phase 6 (tests + CI). |
