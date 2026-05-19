# Tesco Clone TODO

## Status Legend

- `[ ]` Not started
- `[~]` In progress
- `[x]` Complete
- `[!]` Blocked

---

## Phase 1: Foundation and Project Initialization

- `[x]` Create `.claude` project guidance structure.
- `[x]` Create architecture and workflow documentation.
- `[x]` Create coding, testing, API, database, security, and deployment rules.
- `[x]` Confirm final project naming: new `TescoClone.*` solution structure.
- `[x]` Confirm SQL Server local instance name and database name.
- `[x]` Confirm frontend apps should be created under `frontend/tesco-storefront` and `frontend/tesco-admin`.

---

## Phase 2: Core Backend and Data Model

- `[x]` Create or align Clean Architecture projects (Domain, Application, Infrastructure, API).
- `[x]` Add Domain entities for Identity, Catalogue, Order, Delivery, Loyalty, and Promotions.
- `[x]` Add Application commands, queries, validators, DTOs, and repository interfaces.
- `[x]` Add Infrastructure ADO.NET connection factory and SQL helper.
- `[x]` Add API middleware: exceptions, correlation ID, security headers, health check.
- `[x]` Add MediatR pipeline behaviors: ValidationBehavior and LoggingBehavior.
- `[x]` Add FluentValidation for all commands and queries.
- `[x]` Create database migrations V001–V076 for schemas, reference data, identity, catalogue, order, loyalty, delivery, promotions, content, marketplace, and audit tables.
- `[x]` Add `t.tblAuditLog` and `t.tblLog` tables with all required columns.
- `[x]` Add soft-delete columns (`RecordStatusId`, `IsDeleted`, `ModifiedBy`, `ModifiedOn`) to all application tables.

---

## Phase 3: Primary Customer Features — Backend

- `[x]` Implement registration with email + password validation.
- `[x]` Implement login with JWT bearer + SHA-256 hashed refresh token rotation.
- `[x]` Implement logout / refresh token revocation.
- `[x]` Implement forgot password and reset password (token-based, V076).
- `[x]` Implement account lockout after 5 failed login attempts.
- `[x]` Implement profile edit (name, phone).
- `[x]` Implement address book (add, update, soft-delete).
- `[x]` Implement saved payment cards via Stripe tokenisation.
- `[x]` Implement catalogue browsing: departments and categories.
- `[x]` Implement product detail with variant selector and nutritional data.
- `[x]` Implement full-text product search with filters and pagination.
- `[x]` Implement offer and promotion badges on product cards.
- `[x]` Implement brand filtering on catalogue pages.
- `[x]` Implement cart operations: add, update quantity, remove, clear (persistent server-side).
- `[x]` Implement quantity stepper component.
- `[x]` Implement basket sidebar on category page.
- `[x]` Implement three-step checkout (delivery → payment → review).
- `[x]` Implement delivery slot selector integrated in checkout.
- `[x]` Implement Clubcard voucher redemption at checkout.
- `[x]` Implement Stripe payment intent + card element.
- `[x]` Implement order confirmation with invoice number.
- `[x]` Implement delivery slot search by postcode + date range.
- `[x]` Implement UPDLOCK concurrency guard on slot booking.
- `[x]` Implement Delivery Saver subscription page.
- `[x]` Implement store locator (map placeholder + list).
- `[x]` Implement Clubcard balance and points history.
- `[x]` Implement points earn on order completion.
- `[x]` Implement points redemption at checkout.
- `[x]` Implement voucher list with expiry dates.
- `[x]` Implement voucher redemption at checkout.
- `[x]` Implement order list (paginated, filterable by status).
- `[x]` Implement order detail with line items, totals, and delivery info.
- `[x]` Implement order cancellation (customer-initiated).
- `[x]` Implement invoice PDF download via QuestPDF.

---

## Phase 4: Admin, Security, and Operational Features — Backend

- `[x]` Implement admin first-factor login (email + password).
- `[x]` Implement admin second-factor 2FA (6-digit SHA-256 OTP, time-limited).
- `[x]` Implement admin forgot-password / reset-password flow.
- `[x]` Implement role-based authorization (User / Admin / SuperAdmin) with policy guards.
- `[x]` Implement admin product management: paginated list, search, create, edit, soft-delete.
- `[x]` Implement admin category management: list, create, edit, link to department, soft-delete.
- `[x]` Implement admin department management: list, create, edit, soft-delete.
- `[x]` Implement admin brand management: list, create, edit, soft-delete.
- `[x]` Implement admin product variant management: sizes / colours per product.
- `[x]` Implement admin inventory management: per-variant stock levels and adjustment history.
- `[x]` Implement admin order list with status filter and date-range picker.
- `[x]` Implement admin order status update (Pending → Processing → Dispatched → Delivered).
- `[x]` Implement admin refund initiation via Stripe.
- `[x]` Implement admin promotions: create, edit, soft-delete, active/inactive/expired filter.
- `[x]` Implement admin user management: list with search, lock/unlock accounts, assign roles.
- `[x]` Implement view login history via audit log.
- `[x]` Implement CMS pages: create, edit, publish, soft-delete.
- `[x]` Implement banners: create, edit, set date range, soft-delete.
- `[x]` Implement preview page slug routing.
- `[x]` Implement marketplace: seller applications approve / suspend.
- `[x]` Implement marketplace: dispute list with resolution workflow.
- `[x]` Implement analytics: KPI dashboard, sales, top products by revenue, customer acquisition stats, CSV export.
- `[x]` Implement audit log: paginated log with actor, action, entity, and timestamp filters.
- `[x]` Implement application error log viewer with severity filter.
- `[x]` Implement admin dashboard KPI tiles: total orders, revenue, new users, pending disputes.
- `[x]` Implement low-stock alerts on admin dashboard.
- `[x]` Add rate limiting: fixed window (auth), sliding window (API), token bucket (public).
- `[x]` Add OWASP security headers via SecurityHeadersMiddleware.
- `[x]` Add CorrelationIdMiddleware generating and propagating X-Correlation-ID.

---

## Phase 5: Angular Frontend

### Storefront (tesco-storefront)

- `[x]` Set up Angular 18 app with standalone components, lazy loading, and signals-based state.
- `[x]` Configure SCSS design tokens, reset, mixins, and shared component styles.
- `[x]` Implement functional auth interceptor (JWT bearer) and auth guard.
- `[x]` Build core services: AuthService, CartService, CatalogueService, OrderService, DeliveryService, LoyaltyService, NotificationService.
- `[x]` Build shared components: Header, Footer, ProductCard, Spinner, Pagination, Breadcrumb, QuantityStepper, Alert.
- `[x]` Build Home page with announcement ticker, trust bar, hero, department roundels, featured products, offers, Clubcard banner, recipes strip, and footer promo (8+ sections).
- `[x]` Build Login and Register pages with reactive forms and validation.
- `[x]` Build Departments, Category, and Product Detail pages.
- `[x]` Build Category page sub-category chip strip, filter accordion, sort/count bar.
- `[x]` Build Product Detail page with variant selector, nutritional tabs, and Clubcard pricing badge.
- `[x]` Build Full-text Search page with query params, filters, and pagination.
- `[x]` Build Cart page with item management and order summary.
- `[x]` Build Checkout page with 3-step flow: delivery, payment, review.
- `[x]` Build Order list and Order detail pages.
- `[x]` Build Order cancellation flow.
- `[x]` Build Invoice PDF download link on order detail.
- `[x]` Build Account dashboard with hub links.
- `[x]` Build Profile edit page (name, phone).
- `[x]` Build Address book page (add, update, soft-delete).
- `[x]` Build Saved payment cards page.
- `[x]` Build Clubcard page with balance, vouchers, and transaction history.
- `[x]` Build Delivery slots page with postcode search, slot grid, and booking.
- `[x]` Build Delivery Saver subscription page.
- `[x]` Build Store locator page with postcode search and store cards.
- `[x]` Build Recipes listing and detail pages.
- `[x]` Build Help / FAQ page with contact cards and accordion.
- `[x]` Build Tesco Magazine stub page.
- `[x]` Build Accessibility statement page.
- `[x]` Build Terms and conditions page.
- `[x]` Build Product terms page.
- `[x]` Build Ratings and reviews policy page.
- `[x]` Build Product recall notice page.
- `[x]` Build Delivery Saver terms page.
- `[x]` Build BasketSidebarComponent on category page.
- `[x]` Wire up all storefront routes with auth guard on protected paths.
- `[x]` Apply ChangeDetectionStrategy.OnPush to every component.
- `[x]` Use inject() for all Angular dependency injection.

### Admin Panel (tesco-admin)

- `[x]` Set up Angular 18 admin app with standalone components and lazy-loaded routes.
- `[x]` Configure admin SCSS design tokens, layout styles, form styles, and shared utilities.
- `[x]` Implement admin auth interceptor and guard.
- `[x]` Implement auto-logout on token expiry via interceptor.
- `[x]` Build AdminAuthService with two-factor login flow and temp-token handoff.
- `[x]` Build AdminLayout shell with fixed sidebar navigation and sticky topbar.
- `[x]` Build Admin Login page: step-1 email/password and step-2 2FA code entry.
- `[x]` Build Admin forgot-password / reset-password pages.
- `[x]` Build Dashboard with 6 KPI stat cards, recent orders table, and low-stock alerts.
- `[x]` Build Products page with search/filter, status toggle, and pagination.
- `[x]` Build Categories page with inline create/edit form and deactivate action.
- `[x]` Build Departments page with list, create, edit, and deactivate.
- `[x]` Build Brands page with list, create, edit, and deactivate.
- `[x]` Build Product Variants page with sizes/colours management per product.
- `[x]` Build Inventory page with low-stock highlighting and stock adjustment modal.
- `[x]` Build Orders page with status dropdown update, refund action, and pagination.
- `[x]` Build Promotions page with create/edit form (type, discount, date range), active/inactive/expired filter, and deactivate.
- `[x]` Build Marketplace page with sellers approval/suspension and dispute resolution tabs.
- `[x]` Build Users page with role assignment dropdown, lock/unlock, and pagination.
- `[x]` Build Content page with CMS page editor (title, slug, HTML body), banner management, and preview slug routing.
- `[x]` Build Analytics page with date-range filter, KPI stats, top products table, customer acquisition stats, and CSV export.
- `[x]` Build Audit & Logs page with paginated audit trail and application log viewer.
- `[x]` Wire up all admin routes inside the AdminLayout shell with auth guard.
- `[x]` Apply ChangeDetectionStrategy.OnPush to every admin component.

---

## Phase 6: Testing and Production Readiness

- `[ ]` Add unit tests for Domain entities and business rules.
- `[ ]` Add unit tests for Application command and query handlers (Identity, Catalogue, Cart, Order, Delivery, Loyalty, Promotions).
- `[ ]` Add validator unit tests for all FluentValidation rules with boundary values.
- `[ ]` Add unit tests for SecurityHeadersMiddleware and CorrelationIdMiddleware.
- `[ ]` Add unit tests for ExceptionMiddleware (correct error shape and log write).
- `[ ]` Add unit tests for refresh token rotation and admin 2FA OTP logic.
- `[ ]` Add integration tests for auth endpoints: register, login, lockout, refresh rotation, revoke.
- `[ ]` Add integration tests for cart: add, update quantity, remove, clear, concurrency.
- `[ ]` Add integration tests for checkout: slot booking concurrency, payment intent, order placement.
- `[ ]` Add integration tests for order status transitions and cancellation.
- `[ ]` Add integration tests for Clubcard: earn, redeem, voucher expiry validation.
- `[ ]` Add integration tests for admin: 2FA flow, role assignment, audit log writes.
- `[ ]` Add integration tests for soft-deleted records not appearing in reads.
- `[ ]` Add integration tests for stored procedure audit log writes on data-changing operations.
- `[ ]` Add Angular unit tests for storefront services, components, guards, and interceptors.
- `[ ]` Add Angular unit tests for admin services, components, and auth flow.
- `[ ]` Add Angular E2E tests (Playwright): login, search, add to cart, checkout golden path.
- `[ ]` Add Angular E2E tests for admin: login with 2FA, product CRUD, order status update.
- `[ ]` Set up CI pipeline: dotnet restore, build, test, SQL migration validation, npm ci, Angular tests, lint, production build, secret scanning, dependency vulnerability scanning.
- `[ ]` Prepare release checklist and deployment verification document.
- `[ ]` Write rollback scripts for every migration (V001–V076).
- `[ ]` Run final smoke test: login, search, add to cart, checkout, admin login, health check.

---

## Phase 7: Missing Core Features (High Priority)

- `[ ]` Implement product image upload: blob/file storage adapter, API endpoint, Infrastructure implementation.
- `[ ]` Implement email notification templates: welcome, order-confirm, reset-password, dispatch.
- `[ ]` Wire email provider to `EmailService` (SendGrid / SMTP) and trigger on order events.
- `[ ]` Implement SMS notifications: wire provider (Twilio / Vonage) for delivery slot reminders.
- `[ ]` Implement push notifications: wire `INotificationService` for browser push on order updates.
- `[ ]` Implement Stripe payment webhook handler: async payment confirmation and refund events.
- `[ ]` Implement eCoupon management: stored procedures, API endpoints, admin UI, and storefront redemption.
- `[ ]` Implement marketplace seller listing CRUD: sellers can add and manage product listings.
- `[ ]` Implement marketplace commission engine: `fn_Marketplace_CalculateCommission` SP and wiring.
- `[ ]` Implement delivery zone management admin UI: list, create, edit zones (DB tables exist).
- `[ ]` Implement recipes CRUD in admin panel: create, edit, publish, soft-delete.
- `[ ]` Implement product reviews and ratings: tables, stored procedures, API endpoints, storefront UI.
- `[ ]` Implement real-time order tracking: SignalR hub or polling endpoint + storefront status feed.
- `[ ]` Implement stock reservation on checkout: CartItem lock during checkout to prevent overselling.

---

## Phase 8: Medium Priority Features

- `[ ]` Implement admin notification centre: broadcast email/SMS to customer segments.
- `[ ]` Implement saved searches / wishlists: `t.tblWishlist` table, SP, API, storefront UI.
- `[ ]` Implement product comparison: full backend and storefront comparison page.
- `[ ]` Implement recently viewed products: tracking table, SP, and storefront widget.
- `[ ]` Implement related / recommended products: rule-based engine and storefront carousel.
- `[ ]` Implement gift cards: domain model, stored procedures, API endpoints, and redemption at checkout.
- `[ ]` Implement returns and exchanges portal: formal return flow beyond simple refund.
- `[ ]` Build seller portal (separate Angular app): marketplace sellers manage own listings and view commission.
- `[ ]` Implement GDPR data export / deletion: `proc_Identity_ExportUserData`, admin-triggered flow.
- `[ ]` Implement admin report scheduling: scheduled CSV exports delivered by email.
- `[ ]` Implement multi-currency pricing: add currency column to price model, currency selector on storefront.

---

## Phase 9: Infrastructure and DevOps

- `[ ]` Add background job processor: Hangfire for email dispatch, PDF generation, and notification delivery.
- `[ ]` Add distributed cache: Redis for hot catalogue data, department/category tree, active promotions, and session tokens.
- `[ ]` Add CDN integration: configure Azure CDN or CloudFront for Angular static assets and product images.
- `[ ]` Enhance health check endpoints: `/health/ready` and `/health/live` with DB ping and dependency checks.
- `[ ]` Add application performance monitoring: OpenTelemetry or Application Insights wiring.
- `[ ]` Add container support: Dockerfile and docker-compose for API + storefront + admin.
- `[ ]` Add CI/CD pipeline: GitHub Actions or Azure DevOps YAML covering build, test, migrate, and deploy.
- `[ ]` Move secrets to Azure Key Vault or environment-level secrets manager (remove from appsettings.json).
- `[ ]` Enable SQL Server TDE (Transparent Data Encryption) for production.
- `[ ]` Add HSTS preload in production SecurityHeadersMiddleware.
- `[ ]` Implement brute-force IP rate limiting at the reverse proxy level (IIS / nginx).
- `[ ]` Add composite database indexes for multi-column search filters (postcode + date, product + category).
- `[ ]` Add HTTP response caching headers for public catalogue endpoints.
- `[ ]` Bundle and compress Angular production builds with Brotli.
- `[ ]` Implement image optimisation pipeline (WebP conversion, responsive srcset).

---

## Notes

- Database changes must use safe, idempotent, versioned migration scripts (`V<NNN>_description.sql`).
- No destructive SQL is allowed without explicit confirmation and a verified rollback path.
- All data-changing stored procedures must write to `t.tblAuditLog` and `t.tblLog` on error.
- Soft delete standard: `RecordStatusId = 3, IsDeleted = 1`.
- Every new controller must delegate business logic to MediatR — no logic in controllers.
- Run `dotnet test` before every commit to `main`.
