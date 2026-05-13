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

- `[x]` Create or align Clean Architecture projects.
- `[x]` Add Domain entities for Identity, Catalogue, Order, Delivery, Loyalty, and Promotions.
- `[x]` Add Application commands, queries, validators, DTOs, and repository interfaces.
- `[x]` Add Infrastructure ADO.NET connection factory and SQL helper.
- `[x]` Add API middleware for exceptions, correlation ID, audit logging, security headers, and health checks.
- `[x]` Create initial database migrations for schemas, reference data, identity, catalogue, order, loyalty, delivery, promotions, content, marketplace, and audit tables.

## Phase 3: Primary Customer Features

- `[x]` Implement authentication, registration, login, refresh token rotation, and lockout.
- `[x]` Implement catalogue browsing, product detail, and product search.
- `[x]` Implement cart operations.
- `[x]` Implement checkout and order creation.
- `[x]` Implement delivery slot search and booking.
- `[x]` Implement Clubcard points and voucher flows.

## Phase 4: Admin, Security, and Operational Features

- `[x]` Implement admin product, category, inventory, promotion, and order management.
- `[x]` Implement role-based authorization and admin 2FA.
- `[x]` Implement audit log and application log review workflows.
- `[x]` Implement content and marketplace administration.
- `[x]` Add rate limiting, security headers, and OWASP checks.

## Phase 5: Angular Frontend

### Storefront (tesco-storefront)

- `[x]` Set up Angular 18 app with standalone components, lazy loading, and signals-based state.
- `[x]` Configure SCSS design tokens, reset, mixins, and shared component styles.
- `[x]` Implement functional auth interceptor (JWT bearer) and auth guard.
- `[x]` Build core services: AuthService, CartService, CatalogueService, OrderService, DeliveryService, LoyaltyService, NotificationService.
- `[x]` Build shared components: Header, Footer, ProductCard, Spinner, Pagination, Breadcrumb, QuantityStepper, Alert.
- `[x]` Build Home page with department roundels, hero grid, promo tiles, and Clubcard banner.
- `[x]` Build Login and Register pages with reactive forms and validation.
- `[x]` Build Departments, Category, and Product Detail pages with filters, variants, and nutritional data.
- `[x]` Build Search page with query params, filters, and pagination.
- `[x]` Build Cart page with item management and order summary.
- `[x]` Build Checkout page with 3-step flow: address, payment, review.
- `[x]` Build Order list and Order detail pages.
- `[x]` Build Account dashboard with hub links.
- `[x]` Build Clubcard page with balance, vouchers, and transaction history.
- `[x]` Build Delivery slots page with postcode search, slot grid, and booking.
- `[x]` Build Store locator page with postcode search and store cards.
- `[x]` Build Recipes page with filter pills and recipe grid.
- `[x]` Build Help/FAQ page with contact cards and accordion.
- `[x]` Wire up all storefront routes with auth guard on protected paths.

### Admin Panel (tesco-admin)

- `[x]` Set up Angular 18 admin app with standalone components and lazy-loaded routes.
- `[x]` Configure admin SCSS design tokens, layout styles, form styles, and shared utilities.
- `[x]` Implement admin auth interceptor and guard.
- `[x]` Build AdminAuthService with two-factor login flow and temp-token handoff.
- `[x]` Build AdminLayout shell with fixed sidebar navigation and sticky topbar.
- `[x]` Build Admin Login page with step-1 email/password and step-2 2FA code entry.
- `[x]` Build Dashboard with 6 KPI stat cards and recent orders table.
- `[x]` Build Products page with search/filter, status toggle, and pagination.
- `[x]` Build Categories page with inline create/edit form and deactivate action.
- `[x]` Build Inventory page with low-stock highlighting and stock adjustment modal.
- `[x]` Build Orders page with status dropdown update, refund action, and pagination.
- `[x]` Build Promotions page with create/edit form (type, discount, date range) and deactivate action.
- `[x]` Build Marketplace page with sellers approval/suspension and dispute resolution tabs.
- `[x]` Build Users page with role assignment dropdown, lock/unlock, and pagination.
- `[x]` Build Content page with CMS page editor (title, slug, HTML body) and banner management.
- `[x]` Build Analytics page with date-range filter, KPI stats, top products table, and CSV export.
- `[x]` Build Audit & Logs page with paginated audit trail and application log viewer.
- `[x]` Wire up all admin routes inside the AdminLayout shell with auth guard.

## Phase 6: Production Readiness

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
