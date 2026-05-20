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
- `[x]` Implement marketplace seller listing CRUD: sellers can add and manage product listings.
- `[x]` Implement marketplace commission engine: `fn_Marketplace_CalculateCommission` SP and wiring.
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

## Phase 10: Advanced Clubcard & Loyalty Features

### Backend — Clubcard Enhancements

- `[ ]` Add Clubcard number (13-digit) auto-generated and stored on user registration; expose on account profile API.
- `[ ]` Implement Clubcard Challenges engine: `m.tblClubcardChallenge` (type, qualifying category/brand, spend/quantity target, bonus points, start/end date, target segment), `t.tblCustomerChallengeProgress` for per-user tracking, automatic points award via Hangfire job on completion.
- `[ ]` Implement supplier-funded Clubcard Challenges: challenge records linked to a supplier/brand, commission tracking, reporting endpoint for suppliers.
- `[ ]` Implement Personalised "Your Clubcard Prices": `m.tblPersonalisedClubcardPrice` (ProductId, SegmentId, PersonalisedPrice, ValidFrom, ValidTo); surfaced on product search and detail pages for the signed-in Clubcard holder.
- `[ ]` Implement Clubcard Plus subscription: Stripe recurring billing at £7.99/month; entitlement check on account (two 10%-off monthly shop vouchers, enhanced points multiplier); subscription lifecycle (create, cancel, renew, lapse); stored in `t.tblClubcardPlusSubscription`.
- `[ ]` Implement Reward Partners: `m.tblRewardPartner` (name, logo, exchange rate, category, active dates); `proc_Loyalty_RedeemRewardPartner` that converts Clubcard voucher value to partner reward code; API endpoints for partner listing and redemption.
- `[ ]` Implement digital Clubcard barcode: generate EAN-13 or Code 128 barcode (base64 image or SVG) from Clubcard number for in-app scanning; endpoint GET /api/v1/clubcard/barcode.
- `[ ]` Implement on-demand points-to-vouchers conversion: POST /api/v1/clubcard/convert-points — converts eligible accumulated points to voucher balance at any time, not just quarterly.
- `[ ]` Implement automatic quarterly points-to-vouchers conversion: Hangfire scheduled job running in January, April, July, and October; converts all eligible balances and queues welcome-voucher email.
- `[ ]` Implement customer segmentation engine: `m.tblCustomerSegment` (name, rules JSON), `t.tblCustomerSegmentMembership`; nightly Hangfire job re-evaluates segment membership based on purchase history, spend tier, postcode, and registration date.
- `[ ]` Implement "Who Likes" anonymised product discovery: stored function `fn_Loyalty_GetCo购BoughtProducts` returning top co-purchased products for a given SKU; endpoint on product detail API.
- `[ ]` Implement back-in-stock notification: `t.tblStockAlert` (UserId, ProductVariantId, CreatedOn); Hangfire job checks stock levels and dispatches email/push when stock is restored; POST /api/v1/products/{id}/notify-stock and DELETE to cancel.
- `[ ]` Implement points manual adjustment: POST /api/v1/admin/clubcard/adjust-points with UserId, Amount (±), ReasonCode, and AdminId; writes to `t.tblAuditLog`; requires SuperAdmin policy.
- `[ ]` Implement eCoupon management (full): `m.tblECoupon` (code, type, discount, qualifying products/categories, max uses, expiry), `proc_Loyalty_RedeemECoupon`, admin CRUD API, and storefront redemption at checkout distinct from standard vouchers.

### Storefront — Clubcard UI

- `[ ]` Redesign Clubcard hub page: balance tile with digital barcode, quick-action tiles (Challenges, Vouchers, Reward Partners, Clubcard Plus), points-to-vouchers conversion CTA, personalised offers strip.
- `[ ]` Build Clubcard Challenges page (`/account/clubcard/challenges`): active challenge cards with progress bars, days remaining, bonus points on completion, completed/expired tabs, challenge category filter.
- `[ ]` Build Clubcard Plus upgrade page (`/account/clubcard/plus`): plan comparison (standard vs Plus benefits), Stripe subscription sign-up flow, active subscriber view with monthly vouchers, cancellation option.
- `[ ]` Build Reward Partners page (`/account/clubcard/reward-partners`): partner grid by category (travel, dining, entertainment, streaming), voucher exchange calculator (e.g. £1.50 voucher → £3.00 partner credit), partner redemption confirmation and reward code display.
- `[ ]` Build digital barcode component in Clubcard hub: full-width scannable barcode/QR with Clubcard number; "Add to Apple/Google Wallet" CTA.
- `[ ]` Build on-demand voucher conversion UI: amount selector, conversion confirmation modal, updated balance summary.
- `[ ]` Build "Your Clubcard Prices" personalised offers page (`/account/clubcard/your-prices`): grid of personalised discounted products exclusive to the signed-in customer.
- `[ ]` Add Clubcard Prices filter toggle on category and search pages: one-click filter to show only products with active Clubcard or personalised pricing.
- `[ ]` Add challenge progress micro-badge on product cards: when a product contributes to an active challenge, display a mini "Challenge" badge with progress count.
- `[ ]` Add "Notify me" back-in-stock CTA on product detail for out-of-stock variants: confirmation toast and manage-alerts link in account.
- `[ ]` Build Shopping List feature (`/account/lists`): create and rename multiple named lists; add/remove products from any catalogue page; "Add all to basket" action; share list via link.
- `[ ]` Build eCoupons page (`/account/clubcard/ecoupons`): list active digital coupons with expiry, qualifying products; clip-to-account action; auto-applied at checkout when qualifying items are in basket.

### Admin — Clubcard Management

- `[ ]` Build Clubcard Challenges admin page: create/edit challenge form (name, type, qualifying category or brand, spend/quantity target, bonus points, start/end date, target segment, supplier-funded flag); active/upcoming/expired tabs; deactivate action.
- `[ ]` Build Reward Partners admin page: create/edit partner form (name, logo, description, exchange rate, voucher template, redemption URL, active date range); deactivate action; redemption volume stats.
- `[ ]` Build customer segmentation admin: define named segments with rule builder (purchase history, spend tier, postcode district, registration date range); preview estimated segment size; trigger manual re-evaluation.
- `[ ]` Build Clubcard Plus subscription admin: subscriber list with status filter; subscription detail (billing history, next renewal, benefit usage); manual cancel/refund action with audit trail.
- `[ ]` Build personalised Clubcard Prices admin: create per-segment price rules (product scope, discount amount, validity dates); preview rule impact; activate/deactivate.
- `[ ]` Build loyalty analytics dashboard page in admin: KPI tiles — challenges completed (month), vouchers issued, vouchers redeemed, Reward Partner redemptions, Clubcard Plus subscriber count, points issued vs redeemed ratio; trend charts.
- `[ ]` Build points adjustment admin tool: search customer by email; credit/debit points with mandatory reason code dropdown; confirmation step; full write to `t.tblAuditLog`.
- `[ ]` Build eCoupon admin page: create/edit eCoupon (code, discount type/value, qualifying products/categories, per-customer use limit, expiry, active status); distribution CSV upload; usage stats.

---

## Phase 11: Marketplace Full Platform

### Backend — Marketplace Platform

- `[x]` Implement seller account type: extend `m.tblUser` with `IsSeller` flag and `SellerId` FK; add `m.tblSeller` (business name, registration number, VAT number, bank details ref, status, approvedOn, suspendedOn, commissionTierId).
- `[x]` Implement seller onboarding API: multi-step application (business details, bank account, product categories, T&Cs acceptance); document upload endpoint (Companies House number, VAT certificate, public liability insurance); status workflow (Draft → Submitted → Under Review → Approved / Rejected); POST /api/v1/marketplace/sellers/apply.
- `[x]` Implement seller product listing CRUD: sellers create, edit, publish/unpublish, and soft-delete their own listings (`m.tblMarketplaceListing`); listing validation rules (title max length, min 1 image, EAN/barcode required, price > 0, category must be marketplace-eligible); GET/POST/PUT/DELETE /api/v1/marketplace/listings.
- `[x]` Implement marketplace catalogue integration: approved and published seller listings indexed alongside Tesco-own products; visible on customer catalogue with `IsMarketplace = 1` flag and SellerId; inventory and price synced from listing.
- `[x]` Implement commission engine: `m.tblCommissionTier` (categoryId, rate%), `fn_Marketplace_CalculateCommission` computes commission per order line; `proc_Marketplace_RecordCommission` writes to `t.tblSellerCommission` on order placement.
- `[x]` Implement seller order fulfillment workflow: marketplace orders routed to seller via `t.tblSellerOrder`; seller confirms, packs, marks dispatched with carrier name and tracking number; order status updates propagate to customer order detail.
- `[x]` Implement advance shipping notices (ASN): `t.tblSellerASN` (SellerId, ExpectedArrivalDate, SKUs JSON, Status); POST /api/v1/marketplace/asn.
- `[x]` Implement seller performance scoring: nightly Hangfire job computes delivery speed, on-time rate, return rate, cancellation rate, and average customer rating per seller; stores daily snapshot in `t.tblSellerPerformanceScore`; flags sellers below threshold.
- `[x]` Implement marketplace returns workflow: customer raises return on marketplace order line; routed to seller for accept/dispute within SLA (72 hours); resolution triggers Stripe refund; escalate to admin dispute if SLA breached.
- `[x]` Implement seller fee invoicing: monthly Hangfire job generates PDF invoice (QuestPDF) for commissions and platform fees per seller; stored in file storage and linked in `t.tblSellerInvoice`; downloadable via seller portal.
- `[x]` Implement seller payout management: `t.tblSellerPayout` (SellerId, PeriodStart, PeriodEnd, GrossSales, CommissionDeducted, NetPayout, Status, ProcessedOn); admin-triggered payout run endpoint.
- `[x]` Implement seller-to-admin messaging: `t.tblSellerMessage` (thread per SellerId, messages with sender, body, timestamp, readAt); POST /api/v1/marketplace/messages.
- `[x]` Extend product search to support marketplace filter: query param `includeMarketplace=true/false`; filter by SellerId; sort by marketplace delivery speed badge.
- `[x]` Implement Clubcard points on marketplace purchases: points earned at standard 1-per-£1 rate on marketplace order value; integrated into existing loyalty earn flow on order completion.
- `[x]` Implement per-seller configurable delivery options: `m.tblSellerDeliveryOption` (SellerId, Type: Standard/Express, Price, FreeThresholdAmount, EstimatedDays); displayed on product card and cart.

### Storefront — Marketplace Customer UI

- `[x]` Build Marketplace landing page (`/marketplace`): hero banner, featured seller spotlight carousel, top marketplace categories grid, trending products, "Earn Clubcard points" trust badge.
- `[x]` Build Marketplace category browsing (`/marketplace/shop/{category}`): product grid filtered to marketplace listings, seller badge on every card, delivery speed filter, seller filter, price range filter.
- `[x]` Build Seller profile page (`/marketplace/sellers/{id}`): seller logo, name, description, performance rating stars, on-time delivery %, active listing count, return policy, contact support CTA.
- `[x]` Add "Sold by [Seller Name]" badge on marketplace product cards and product detail page with link to seller profile.
- `[x]` Build Marketplace orders section in account (`/account/orders/marketplace`): separate tab listing marketplace orders with per-order seller name, item thumbnails, tracking link, estimated delivery, and return CTA.
- `[x]` Build Marketplace returns portal (`/account/orders/marketplace/{id}/return`): item selector with return reason dropdown; submission confirmation; return status tracker (Requested → Seller Response → Resolved).
- `[x]` Build Marketplace guarantee and FAQs page (`/marketplace/guarantee`): customer-facing explanation of Tesco's fulfilment guarantee, returns policy, dispute escalation process, Clubcard points on marketplace purchases.
- `[x]` Add delivery cost breakdown on cart and checkout: clearly separate Tesco grocery delivery fee from per-seller marketplace delivery fees; "Free delivery" eligibility shown per seller.
- `[x]` Add seller rating display on marketplace product detail: star rating, number of reviews, top 3 recent customer reviews, "See all reviews" link to seller profile.

### Admin — Marketplace Management

- `[x]` Build seller application review page: paginated list of submitted applications with status filter; application detail view with document download; approve/reject action with notes; trigger email notification to applicant.
- `[x]` Build seller performance dashboard: leaderboard table of sellers ranked by composite performance score; flag sellers below threshold; drill into individual seller metrics; suspend action from dashboard.
- `[x]` Build commission configuration admin: category-level commission rate table; create/edit rate entries with effective date; tier assignment per seller; preview commission impact calculator.
- `[x]` Build marketplace analytics page: GMV by date range, top sellers by revenue, category breakdown pie chart, average order value trend, dispute rate, return rate, new seller applications count; CSV export.
- `[x]` Build seller payout run admin: pre-payout summary table (seller, gross, commission, net); confirm payout run; mark individual payouts as processed; download payout file.
- `[x]` Build seller messaging admin: inbox of all open seller threads; reply on behalf of Tesco; assign to admin user; close/escalate thread.
- `[x]` Build marketplace category eligibility config: toggle which Tesco catalogue categories allow marketplace listings; set category-level commission tier; restrict by seller type.
- `[x]` Enhance existing dispute admin page: add marketplace return escalations alongside standard disputes; SLA timer display; auto-refund trigger on admin resolution.

### Seller Portal (`frontend/tesco-seller` Angular app)

- `[x]` Set up `frontend/tesco-seller` Angular 18 app: standalone components, lazy-loaded routes, seller JWT auth guard, Tesco Marketplace brand tokens, port 8084 locally.
- `[x]` Build Seller Login page: email/password auth against seller-scoped JWT; 2FA step (OTP email); temp-token handoff pattern matching admin 2FA flow.
- `[x]` Build Seller Dashboard: KPI tiles (total orders today, GMV this month, pending dispatches, open return requests, performance score), recent orders table, low-stock alerts widget.
- `[x]` Build Seller Listings page: paginated list of own listings with status badges (Draft / Published / Unpublished); inline publish/unpublish toggle; create, edit, soft-delete; bulk CSV upload template download and import.
- `[x]` Build Seller Product Create/Edit form: title, description (rich text), category selector (marketplace-eligible only), EAN/barcode, images (multi-upload), price, compare-at price, stock quantity, weight/dimensions, delivery option selector.
- `[x]` Build Seller Orders page: orders in tabs (Pending Confirmation / Confirmed / Dispatched / Delivered); mark confirmed; mark dispatched with carrier name and tracking number entry; order detail drawer with line items and customer address.
- `[x]` Build Seller Returns page: open return requests with SLA countdown; accept return (trigger refund); dispute return (enter dispute notes); resolved tab with outcome summary.
- `[x]` Build Seller Inventory page: per-SKU stock levels; low-stock threshold setting; stock adjustment modal with reason code; export to CSV.
- `[x]` Build Seller Performance page: score tiles (delivery speed, on-time rate, return rate, cancellation rate, average rating); trend charts; improvement guidance cards; comparison vs marketplace average.
- `[x]` Build Seller Finance page: monthly commission statement table (period, gross sales, commission, net); payout history; downloadable PDF invoice per month.
- `[x]` Build Seller Profile settings page: business name, logo upload, description, return policy text, support contact email, delivery options management.
- `[x]` Build Seller Messages page: threaded conversation list with Tesco marketplace team; compose new message; read/unread indicators.
- `[x]` Build Seller ASN page: submit advance shipping notice (expected arrival date, SKU list, quantities); ASN status tracker (Submitted → Received → Processed).
- `[x]` Wire all seller routes inside a SellerLayout shell with auth guard; apply `ChangeDetectionStrategy.OnPush` to all seller components; use `inject()` for all DI.

---

## Phase 12: Enhanced Shopping Experience

### Backend

- `[ ]` Implement Whoosh (express delivery) slot type: `m.tblSlotType` with `Whoosh` variant; 20–60 minute delivery windows from nearest Whoosh-enabled store; premium delivery fee; availability check by postcode radius; separate slot grid API query param `slotType=whoosh`.
- `[ ]` Implement Click & Collect: collection slot booking at selected store (`m.tblStore.IsClickCollectEnabled`); separate delivery mode (`DeliveryMode = ClickCollect`) in checkout; order-ready push/email notification; collection PIN generation.
- `[ ]` Implement order amendment: allow customers to add/remove items and change delivery slot up to the amendment cutoff shown in the order confirmation; `proc_Order_AmendOrder` with idempotency guard; amendment history in `t.tblOrderAmendment`.
- `[ ]` Implement product substitution preferences: per-account default (AllowSubstitutions BIT) and per-order override; checkout step to set substitution preference; substituted items flagged on order confirmation and delivery notification.
- `[ ]` Implement age-restricted product verification: `m.tblProduct.IsAgeRestricted` and `AgeRestrictionLevel` (18/16); checkout age declaration step; delivery note to driver for ID check; `t.tblAgeVerificationLog`.
- `[ ]` Implement nutritional/dietary filtering: `m.tblProductAttribute` (ProductId, AttributeTypeId: Vegan/Vegetarian/GlutenFree/DairyFree/Halal/Kosher/LowCalorie/etc.); filter parameters on product search and category endpoints; dietary badge rendering on product cards.
- `[ ]` Implement "Buy Again" quick-reorder: query last N distinct products ordered by the customer, excluding discontinued SKUs; GET /api/v1/orders/buy-again; add-to-basket from this endpoint.
- `[ ]` Implement Tesco Delivery Pass tiers: `m.tblDeliveryPassTier` (Anytime, Midweek, Off-Peak); tier benefit check on slot booking (waive delivery fee); upgrade/downgrade endpoint; billing via Stripe subscription; stored in `t.tblDeliveryPassSubscription`.
- `[ ]` Implement meal deal builder: `m.tblMealDealGroup` (name, components, trigger price); `fn_Order_ApplyMealDeal` checks cart for qualifying combinations and applies deal price; indicator returned on cart line items.
- `[ ]` Implement recurring basket / subscription order: `t.tblRecurringOrder` (UserId, BasketSnapshot JSON, Frequency: Weekly/Fortnightly, NextDeliveryDate, Status); Hangfire job creates order on schedule; manage active subscriptions endpoint.

### Storefront

- `[ ]` Build Whoosh slot selector: dedicated express delivery option in checkout delivery step; map view of nearest Whoosh stores; 20–60 min time slot grid; premium fee displayed.
- `[ ]` Build Click & Collect flow: store selector with map and collection hours on checkout delivery step; collection slot grid; confirmation page with collection PIN and QR code.
- `[ ]` Build order amendment page (`/account/orders/{id}/amend`): editable basket for the order with add/remove items; slot change option; amendment cutoff countdown; re-confirm CTA.
- `[ ]` Add substitution preference toggle on checkout review step and account settings: "Allow substitutions" / "No substitutions please" with info tooltip.
- `[ ]` Add dietary attribute filter badges on category and search pages: pill selectors (Vegan, Vegetarian, Gluten Free, Dairy Free, Halal, Kosher) with multi-select support; dietary badges on product cards for matching products.
- `[ ]` Build "Buy Again" section on account dashboard and home page: horizontal scroll carousel of last-purchased products with quantity stepper and add-to-basket.
- `[ ]` Build Delivery Pass management page (`/account/delivery-pass`): current tier display, benefits summary, tier upgrade/downgrade with pricing comparison, next billing date, cancel subscription CTA.
- `[ ]` Add meal deal builder indicator on product cards and cart: "Part of a meal deal" badge; cart highlights completed meal deal combinations with saving amount; incomplete deal prompt showing missing components.
- `[ ]` Build recurring order management page (`/account/subscriptions`): list of active recurring baskets with next delivery date, frequency, item count; pause, edit, cancel actions; upcoming order preview.

### Admin

- `[ ]` Build meal deal admin page: create/edit meal deal groups (name, component products/categories, trigger price, validity dates); active/inactive filter; usage stats.
- `[ ]` Build Delivery Pass tier admin: configure tier names, prices, benefits (slot types allowed, free delivery threshold, monthly cost); subscriber count per tier; manual subscription management.
- `[ ]` Build nutritional attribute admin: manage attribute types and assign attributes to products in bulk; CSV import for product attribute mapping.

---

## Notes

- Database changes must use safe, idempotent, versioned migration scripts (`V<NNN>_description.sql`).
- No destructive SQL is allowed without explicit confirmation and a verified rollback path.
- All data-changing stored procedures must write to `t.tblAuditLog` and `t.tblLog` on error.
- Soft delete standard: `RecordStatusId = 3, IsDeleted = 1`.
- Every new controller must delegate business logic to MediatR — no logic in controllers.
- Run `dotnet test` before every commit to `main`.
