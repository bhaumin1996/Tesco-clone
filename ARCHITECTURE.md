# Tesco Clone — Architecture Reference

> Deep technical reference for the system architecture. Companion to `CLAUDE.md`.

---

## System Architecture Overview

Tesco Clone is a **Clean Architecture monolith** — a single deployable .NET 8 Web API that owns all business logic, served alongside two Angular 18 SPAs. There is no microservices boundary today; the modular folder structure is intentionally migration-ready so that any module can be extracted into a separate service later without rewriting contracts.

```
┌──────────────────────────────────────────────────────────────────────┐
│                         Angular SPAs                                  │
│  ┌─────────────────────────┐   ┌─────────────────────────────────┐   │
│  │   tesco-storefront      │   │       tesco-admin               │   │
│  │   (port 4200 / 8082)    │   │   (port 4201 / 8083)            │   │
│  └────────────┬────────────┘   └──────────────┬──────────────────┘   │
└───────────────┼──────────────────────────────┼──────────────────────┘
                │  HTTPS / JWT Bearer           │
┌───────────────▼──────────────────────────────▼──────────────────────┐
│                    TescoClone.API  (port 443 / 7001 local)            │
│   Middleware: CorrelationId → SecurityHeaders → ExceptionHandler      │
│   Rate limiting  ·  CORS  ·  JWT Auth  ·  Role Policies              │
│   22 Controllers  →  MediatR  →  Application Handlers                │
└──────────────────────────────────┬───────────────────────────────────┘
                                   │ Application interfaces
┌──────────────────────────────────▼───────────────────────────────────┐
│                  TescoClone.Application                               │
│   Commands  ·  Queries  ·  Validators  ·  DTOs  ·  Interfaces        │
│   Pipeline: ValidationBehavior → LoggingBehavior → Handler           │
└──────────────────────────────────┬───────────────────────────────────┘
             ┌────────────────────┤ implements
┌────────────▼──────────┐  ┌──────▼──────────────────────────────────┐
│  TescoClone.Domain    │  │         TescoClone.Infrastructure        │
│  Entities · Enums     │  │  ADO.NET Repos · SqlHelper               │
│  Domain exceptions    │  │  PasswordService · TokenService · 2FA   │
│  Zero dependencies    │  │  StripePaymentService · QuestPDF         │
└───────────────────────┘  │  EmailService · AuditLogRepo             │
                           └──────────────────┬───────────────────────┘
                                              │ Microsoft.Data.SqlClient
                              ┌───────────────▼──────────────┐
                              │    Microsoft SQL Server        │
                              │    m schema (master tables)    │
                              │    t schema (transactional)    │
                              │    76 Stored Procedures        │
                              └──────────────────────────────┘
```

---

## Project Folder Structure (Full)

### Backend

```
src/
├── TescoClone.Domain/
│   ├── Catalogue/          Product, Category, Department, Brand, ProductVariant
│   ├── Identity/           User, Role, RefreshToken
│   ├── Order/              Order, OrderLine, Cart, CartItem
│   ├── Delivery/           DeliverySlot, DeliveryZone, Store
│   ├── Loyalty/            Clubcard, ClubcardPoints, Voucher
│   ├── Promotions/         Promotion, PromotionRule, PricingRule
│   ├── Content/            Page, Banner
│   ├── Marketplace/        Seller, Listing, Dispute
│   ├── Enums/              RecordStatus, OrderStatus, UserRole, DeliveryStatus, PromotionType
│   └── Common/             DomainException, EntityBase (optional)

├── TescoClone.Application/
│   ├── Addresses/
│   │   ├── Commands/       AddAddressCommand, UpdateAddressCommand, DeleteAddressCommand
│   │   ├── Queries/        GetAddressesQuery
│   │   ├── DTOs/           AddressDto
│   │   └── Interfaces/     IAddressRepository
│   ├── Analytics/
│   │   ├── Queries/        GetDashboardStatsQuery, GetSalesAnalyticsQuery, GetTopProductsQuery, GetAnalyticsExportQuery
│   │   ├── DTOs/           DashboardStatsDto, SalesAnalyticsDto
│   │   └── Interfaces/     IAnalyticsRepository
│   ├── Catalogue/
│   │   ├── Commands/       CreateProductCommand, UpdateProductCommand, DeleteProductCommand, CreateCategoryCommand, …
│   │   ├── Queries/        GetProductByIdQuery, SearchProductsQuery, GetDepartmentsQuery, GetCategoriesQuery, …
│   │   ├── DTOs/           ProductDto, CategoryDto, DepartmentDto, BrandDto, SearchResultDto
│   │   └── Interfaces/     IProductRepository, ICategoryRepository, IDepartmentRepository, IBrandRepository, IAdminCatalogueRepository
│   ├── Content/
│   │   ├── Commands/       CreatePageCommand, UpdatePageCommand, DeletePageCommand, CreateBannerCommand, …
│   │   ├── Queries/        GetPageBySlugQuery, GetActiveBannersQuery
│   │   └── Interfaces/     IContentRepository
│   ├── Delivery/
│   │   ├── Commands/       BookSlotCommand
│   │   ├── Queries/        GetAvailableSlotsQuery
│   │   ├── DTOs/           SlotDto
│   │   └── Interfaces/     IDeliveryRepository
│   ├── Identity/
│   │   ├── Commands/       RegisterCommand, LoginCommand, RefreshTokenCommand, RevokeTokenCommand,
│   │   │                   AdminLoginCommand, VerifyTwoFactorCommand, LockUserCommand, UnlockUserCommand,
│   │   │                   AssignRoleCommand, ForgotPasswordCommand, ResetPasswordCommand
│   │   ├── Queries/        GetUserProfileQuery, GetAdminUsersQuery
│   │   ├── DTOs/           AuthDto, UserProfileDto, AdminUserDto
│   │   └── Interfaces/     IUserRepository, IAdminUserRepository, IPasswordService, ITokenService, ITwoFactorService
│   ├── Loyalty/
│   │   ├── Commands/       EarnPointsCommand, RedeemPointsCommand, RedeemVoucherCommand
│   │   ├── Queries/        GetClubcardBalanceQuery, GetVouchersQuery
│   │   ├── DTOs/           ClubcardDto, VoucherDto
│   │   └── Interfaces/     ILoyaltyRepository, IVoucherRepository
│   ├── Marketplace/
│   │   ├── Commands/       ApproveSellerCommand, SuspendSellerCommand, ResolveDisputeCommand
│   │   ├── Queries/        GetSellersQuery, GetDisputesQuery
│   │   └── Interfaces/     IMarketplaceRepository
│   ├── Order/
│   │   ├── Commands/       PlaceOrderCommand, CancelOrderCommand, UpdateOrderStatusCommand, RefundOrderCommand,
│   │   │                   AddToCartCommand, UpdateCartItemCommand, RemoveCartItemCommand, ClearCartCommand
│   │   ├── Queries/        GetCartQuery, GetOrderByIdQuery, GetMyOrdersQuery, GetAllOrdersQuery
│   │   ├── DTOs/           CartDto, OrderDto, OrderLineDto, OrderSummaryDto
│   │   └── Interfaces/     ICartRepository, IOrderRepository, IAdminOrderRepository
│   ├── Promotions/
│   │   ├── Commands/       CreatePromotionCommand, UpdatePromotionCommand, DeletePromotionCommand
│   │   ├── Queries/        GetActivePromotionsQuery, GetAdminPromotionsQuery
│   │   └── Interfaces/     IPromotionRepository
│   └── Common/
│       ├── Behaviors/      ValidationBehavior.cs, LoggingBehavior.cs
│       └── Interfaces/     IEmailService, IPaymentService, IInvoiceService, IAuditLogRepository,
│                           IApplicationLogRepository, IClock, ICurrentUser

├── TescoClone.Infrastructure/
│   ├── Catalogue/          ProductRepository, CategoryRepository, DepartmentRepository, BrandRepository, AdminCatalogueRepository
│   ├── Identity/           UserRepository, AdminUserRepository, PasswordService (BCrypt), TokenService (JWT), TwoFactorService (SHA-256)
│   ├── Order/              CartRepository, OrderRepository, AdminOrderRepository
│   ├── Delivery/           DeliveryRepository
│   ├── Loyalty/            LoyaltyRepository, VoucherRepository
│   ├── Addresses/          AddressRepository
│   ├── Promotions/         PromotionRepository
│   ├── Content/            ContentRepository
│   ├── Marketplace/        MarketplaceRepository
│   ├── Analytics/          AnalyticsRepository
│   └── Common/
│       ├── SqlConnectionFactory.cs   (singleton, manages SQL connections)
│       ├── SqlHelper.cs              (typed parameter helpers, reader mappers)
│       ├── AuditLogRepository.cs
│       ├── ApplicationLogRepository.cs
│       ├── StripePaymentService.cs   (Stripe.net 51.1.0)
│       ├── QuestPdfInvoiceService.cs (QuestPDF 2026.5.0)
│       └── EmailService.cs           (stub — needs SMTP/SendGrid)

└── TescoClone.API/
    ├── Controllers/        (22 controllers — see CLAUDE.md)
    ├── Middleware/         CorrelationIdMiddleware, SecurityHeadersMiddleware, ExceptionMiddleware
    ├── Authorization/      AuthorizationPolicies.cs (Admin, SuperAdmin constants)
    ├── wwwroot/            Static assets, invoice PDFs
    ├── Program.cs          DI wiring, middleware pipeline, CORS, JWT, Swagger, rate limiting
    └── appsettings*.json   Configuration per environment
```

### Frontend

```
frontend/
├── tesco-storefront/
│   └── src/app/
│       ├── core/
│       │   ├── guards/         auth.guard.ts
│       │   ├── interceptors/   auth.interceptor.ts (attaches Bearer; handles 401 refresh)
│       │   ├── models/         address, auth, cart, catalogue, delivery, loyalty, order, promotions
│       │   └── services/       auth, cart, catalogue, content, delivery, loyalty,
│       │                       notification, order, payment, promotions, address
│       ├── features/           (all lazy-loaded)
│       │   ├── home/
│       │   ├── auth/           login, register, forgot-password, reset-password
│       │   ├── catalogue/      departments, category (with filters + basket sidebar), product-detail
│       │   ├── cart/
│       │   ├── checkout/       3-step: delivery → payment → review
│       │   ├── account/        dashboard, orders, order-detail, addresses, profile, cards, clubcard
│       │   ├── search/
│       │   ├── delivery/       delivery-slots, delivery-saver, delivery-saver-terms
│       │   ├── store-locator/
│       │   ├── recipes/
│       │   ├── help/
│       │   ├── offers/
│       │   ├── banners/
│       │   ├── product-recall/
│       │   ├── tesco-magazine/
│       │   ├── accessibility/
│       │   ├── terms-and-conditions/
│       │   ├── product-terms/
│       │   └── ratings-reviews-policy/
│       └── shared/
│           ├── components/     Header, Footer, ProductCard, Spinner, Pagination,
│           │                   Breadcrumb, QuantityStepper, Alert, BasketSidebar
│           └── pipes/

└── tesco-admin/
    └── src/app/
        ├── core/
        │   ├── guards/         admin-auth.guard.ts
        │   ├── interceptors/   admin-auth.interceptor.ts
        │   └── services/       admin-auth.service.ts (2FA two-step)
        ├── features/           (all lazy-loaded, inside AdminLayout shell)
        │   ├── auth/           admin-login (with 2FA modal), forgot-password
        │   ├── dashboard/
        │   ├── catalogue/      products, categories, inventory
        │   ├── orders/         list, order-detail
        │   ├── promotions/
        │   ├── marketplace/    sellers, disputes (tabbed)
        │   ├── users/
        │   ├── content/        pages, banners
        │   ├── analytics/
        │   └── audit/
        └── shared/
            ├── components/     admin-layout (sidebar + topbar shell)
            └── pipes/          image-url.pipe.ts
```

---

## Database Architecture

### Schema Design

Two SQL Server schemas are used:

| Schema | Purpose | Examples |
|---|---|---|
| `m` | Master / reference / catalogue data | `m.tblProduct`, `m.tblCategory`, `m.tblRole` |
| `t` | Transactional, audit, and log data | `t.tblOrder`, `t.tblAuditLog`, `t.tblLog` |

### Core Tables

```
Identity
  t.tblUser              — UserID, Email, PasswordHash, StatusId, FailedLoginAttempts, LockedUntil, StripeCustomerId
  m.tblRole              — RoleID, Name (User=1, Admin=2, SuperAdmin=3)
  t.tblUserRole          — UserId FK, RoleId FK (unique constraint)
  t.tblRefreshToken      — UserId FK, TokenHash (SHA-256), ExpiresAt, IsRevoked
  t.tblAdminTwoFactorCode — UserId FK, CodeHash, ExpiresAt, IsUsed

Catalogue
  m.tblDepartment        — DepartmentID, Name, Slug, ImageUrl
  m.tblCategory          — CategoryID, DepartmentID FK, Name, Slug
  m.tblBrand             — BrandID, Name, LogoUrl
  m.tblProduct           — ProductID, CategoryID FK, BrandID FK, Name, Description, Price, ClubcardPrice
  m.tblProductVariant    — VariantID, ProductID FK, Size, Colour, StockLevel, SKU

Order
  t.tblCart              — CartID, UserID FK
  t.tblCartItem          — CartItemID, CartID FK, VariantID FK, Quantity, UnitPrice
  t.tblOrder             — OrderID, UserID FK, StatusId, TotalAmount, DeliverySlotID FK, StripePaymentIntentId
  t.tblOrderLine         — OrderLineID, OrderID FK, VariantID FK, Quantity, UnitPrice, Subtotal

Delivery
  m.tblDeliveryZone      — ZoneID, Name, PostcodePrefix
  t.tblDeliverySlot      — SlotID, ZoneID FK, SlotDate, StartTime, EndTime, Capacity, BookedCount
  t.tblStore             — StoreID, Name, Address, Lat, Lng

Loyalty
  t.tblClubcard          — ClubcardID, UserID FK, PointsBalance
  t.tblClubcardPoints    — PointsID, ClubcardID FK, OrderID FK, PointsEarned, CreatedOn
  t.tblVoucher           — VoucherID, ClubcardID FK, Code, DiscountAmount, ExpiryDate, IsRedeemed

Promotions
  m.tblPromotionType     — TypeID, Name
  t.tblPromotionRule     — RuleID, TypeID FK, Name, Scope, DiscountValue, StartDate, EndDate

Content
  t.tblPage              — PageID, Title, Slug, Content, IsPublished
  t.tblBanner            — BannerID, ImageUrl, LinkUrl, StartDate, EndDate

Marketplace
  t.tblMarketplaceSeller — SellerID, UserID FK, CompanyName, StatusId
  t.tblDisputeReport     — DisputeID, SellerID FK, OrderID FK, Description, Resolution, StatusId

Customer Data
  t.tblUserAddress       — AddressID, UserID FK, Line1, Line2, City, Postcode, IsDefault
  t.tblUserCard          — CardID, UserID FK, StripePaymentMethodId, Last4, Brand, IsDefault

System
  t.tblAuditLog          — AuditID, EntityType, EntityId, Action, OldValues, NewValues, CreatedBy, CreatedOn
  t.tblLog               — LogID, Severity, Message, StackTrace, Source, CorrelationId, CreatedOn
  m.tblMigration         — Version, Description, AppliedOn (migration tracking)
```

### Standard Columns (every table)

```sql
RecordStatusId  TINYINT        NOT NULL DEFAULT 1,   -- 1=Active, 2=Inactive, 3=Deleted
CreatedBy       INT            NOT NULL,
CreatedOn       DATETIME2      NOT NULL DEFAULT GETUTCDATE(),
ModifiedBy      INT            NULL,
ModifiedOn      DATETIME2      NULL,
IsDeleted       BIT            NOT NULL DEFAULT 0
```

### Soft Delete Convention

```sql
UPDATE m.tblProduct
SET    RecordStatusId = 3,
       IsDeleted      = 1,
       ModifiedBy     = @UserId,
       ModifiedOn     = GETUTCDATE()
WHERE  ProductID = @ProductId;
```

Every customer-facing `SELECT` must include `WHERE IsDeleted = 0`.

### Data Flow — Read Path

```
Angular Component
  → Service.getProducts(filters)
  → HTTP GET /api/v1/products/search?q=...
  → Controller.Search()
  → _mediator.Send(new SearchProductsQuery(...))
  → ValidationBehavior → LoggingBehavior → SearchProductsHandler
  → IProductRepository.SearchAsync(query, ct)
  → SqlHelper.ExecuteReaderAsync("proc_Catalogue_SearchProducts", params)
  → SQL Server → result set
  → mapped to IEnumerable<ProductDto>
  → PagedResult<ProductDto> returned as JSON
```

### Data Flow — Write Path

```
Angular Component
  → Service.addToCart(variantId, qty)
  → HTTP POST /api/v1/cart/items
  → Controller.AddItem()
  → _mediator.Send(new AddToCartCommand(...))
  → ValidationBehavior (validate qty > 0, variantId > 0)
  → LoggingBehavior
  → AddToCartHandler
  → ICartRepository.AddItemAsync(command, ct)
  → SqlHelper.ExecuteNonQueryAsync("proc_Order_AddToCart", params)
  → SQL Server: BEGIN TRANSACTION → INSERT t.tblCartItem → INSERT t.tblAuditLog → COMMIT
  → 201 Created
```

### Migration Versioning

```
database/migrations/
  V001_create_schemas.sql
  V002_create_migration_table.sql
  V003_create_audit_and_log_tables.sql
  V004_create_reference_data.sql
  V005_create_identity_tables.sql
  ...
  V076_add_password_reset_procedures.sql
```

Rules:
- Never modify a migration that has been applied to production
- New changes = new `V<NNN>_description.sql`
- Scripts must be idempotent where possible (`IF NOT EXISTS`, `CREATE OR ALTER PROCEDURE`)
- Each script records itself in `m.tblMigration` at the end

---

## Authentication and Authorization Flow

### Customer JWT Flow

```
1. POST /api/v1/auth/login  {email, password}
2. ExceptionMiddleware → RateLimiter (10/min)
3. LoginCommand → ValidationBehavior → LoginHandler
4. UserRepository.GetByEmailAsync()
5. PasswordService.Verify(plain, hash)   [BCrypt]
6. If invalid: increment FailedLoginAttempts; if >= 5 set LockedUntil + 30min
7. TokenService.GenerateAccessToken()    [JWT HS256, 15min]
8. TokenService.GenerateRefreshToken()   [random 32 bytes → SHA-256 hash stored in t.tblRefreshToken]
9. Response: { accessToken, refreshToken, expiresAt }

Refresh:
1. POST /api/v1/auth/refresh  {refreshToken}
2. UserRepository.GetRefreshTokenAsync(SHA-256(refreshToken))
3. Validate: not revoked, not expired
4. Revoke old token (IsRevoked=1)
5. Issue new access + refresh token pair
6. Return new pair
```

### Admin 2FA Flow

```
Step 1 — First Factor:
1. POST /api/v1/admin/auth/login  {email, password}
2. AdminLoginHandler validates credentials + checks Admin/SuperAdmin role
3. TwoFactorService.GenerateCode() → 6-digit code → SHA-256 → stored in t.tblAdminTwoFactorCode
4. EmailService.SendTwoFactorCode(email, code)
5. Response: { twoFactorRequired: true, userId }

Step 2 — Second Factor:
1. POST /api/v1/admin/auth/verify-2fa  {userId, code}
2. VerifyTwoFactorHandler: SHA-256(code) → compare t.tblAdminTwoFactorCode
3. Validate: not used, not expired
4. Mark code as used
5. Issue JWT with Admin claim
6. Response: { accessToken, refreshToken }
```

### Angular Auth Interceptor

```typescript
// storefront: auth.interceptor.ts
// Attaches Bearer token; on 401 calls AuthService.refreshToken()
// If refresh fails, redirects to /auth/login
```

### Role Policies

```csharp
// AuthorizationPolicies.cs
public const string Admin = "Admin";       // requires Role = Admin OR SuperAdmin
public const string SuperAdmin = "SuperAdmin"; // requires Role = SuperAdmin only

// Usage in controller
[Authorize(Policy = AuthorizationPolicies.Admin)]
[HttpGet("admin/users")]
```

---

## Third-Party Integrations

| Integration | Library | Purpose | Status |
|---|---|---|---|
| Stripe | Stripe.net 51.1.0 | Payment intents, saved payment methods, refunds | Active — no webhook handler yet |
| QuestPDF | QuestPDF 2026.5.0 | Invoice PDF generation | Active |
| BCrypt | BCrypt.Net | Password hashing | Active |
| Email provider | `IEmailService` stub | Welcome, order confirm, reset-password, 2FA emails | Stub — no SMTP/SendGrid wired |
| SMS provider | `INotificationService` interface | Delivery reminders | Not implemented |
| Push notifications | `INotificationService` interface | Browser push | Not implemented |

### Stripe Integration Points

```
POST /api/v1/payments/intent
  → StripePaymentService.CreatePaymentIntentAsync(amount, currency, customerId)
  → returns clientSecret for Angular Stripe Elements

POST /api/v1/payments/methods
  → StripePaymentService.AttachPaymentMethodAsync(customerId, paymentMethodId)

DELETE /api/v1/payments/methods/{id}
  → StripePaymentService.DetachPaymentMethodAsync(paymentMethodId)

MISSING: POST /api/v1/payments/webhook
  → Should handle: payment_intent.succeeded, payment_intent.payment_failed, charge.refunded
```

---

## Background Jobs / Schedulers

### Current State

There is **no background job processor**. Anything that should be async (email, PDF generation, points earn) currently runs synchronously on the request thread.

### Recommended: Hangfire

```
Phase 7 target:
1. Add Hangfire.AspNetCore + Hangfire.SqlServer NuGet packages
2. Register Hangfire with SQL Server storage in Program.cs
3. Move the following to background jobs:
   - EmailService.SendOrderConfirmationAsync()
   - QuestPdfInvoiceService.GenerateInvoiceAsync()
   - LoyaltyService.EarnPointsAsync() (fire-and-forget after order placement)
   - NotificationService.SendPushAsync()
4. Expose /hangfire dashboard, locked to SuperAdmin role
5. Add retry policies for email and SMS (3 retries, exponential backoff)
```

---

## Caching Strategy

### Current State

No distributed cache is in place. SQL Server absorbs all reads.

### Recommended Cache Targets

| Data | TTL | Cache Key Pattern |
|---|---|---|
| Department tree | 1 hour | `catalogue:departments` |
| Category list per department | 1 hour | `catalogue:categories:{deptId}` |
| Active promotions | 5 minutes | `promotions:active` |
| Active banners | 10 minutes | `content:banners:active` |
| Clubcard balance | 30 seconds | `loyalty:balance:{userId}` |
| Product detail | 5 minutes | `catalogue:product:{id}` |

### Implementation Plan (Phase 7)

1. Add `Microsoft.Extensions.Caching.StackExchangeRedis`
2. Register `IDistributedCache` pointing to Redis
3. Wrap repository calls with cache-aside pattern in Application handlers
4. Invalidate on write: `CreateProduct` clears `catalogue:categories:*`
5. Never cache user-specific sensitive data (cart, orders, addresses)

---

## Logging Strategy

### Structured Logging

All log entries flow through `ILogger<T>` (Microsoft.Extensions.Logging). Logs are enriched with:

- `CorrelationId` — from `X-Correlation-ID` header (set by `CorrelationIdMiddleware`)
- `UserId` — from `ICurrentUser` when the request is authenticated
- `RequestPath`, `StatusCode` — added by `LoggingBehavior`

### Log Destinations

| Environment | Destination |
|---|---|
| Development | Console (structured JSON) |
| Production (recommended) | Application Insights or ELK Stack |

### Database Logging (`t.tblLog`)

Every CATCH block in a stored procedure must write to `t.tblLog` before re-throwing:

```sql
BEGIN CATCH
    INSERT INTO t.tblLog (Message, StackTrace, Source, CorrelationId, Severity, CreatedOn)
    VALUES (ERROR_MESSAGE(), ERROR_PROCEDURE(), 'SQL', NULL, 'Error', GETUTCDATE());
    THROW;
END CATCH;
```

The `ExceptionMiddleware` also writes to `t.tblLog` for any unhandled .NET exception.

### Security Event Logging

The following events must always be logged at `Warning` or `Error` level:

- Failed login attempt (with IP, email)
- Account lockout triggered
- Refresh token rotation failure
- Forbidden access attempt
- Admin 2FA code failure
- Admin role assignment change
- Admin password reset

---

## CI/CD Pipeline (Target — Phase 6)

### Recommended Pipeline (GitHub Actions)

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, release/**]
  pull_request:
    branches: [main]

jobs:
  backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
        with: { dotnet-version: '8.0.x' }
      - run: dotnet restore
      - run: dotnet build --configuration Release --no-restore
      - run: dotnet test --no-build --verbosity normal

  database:
    runs-on: ubuntu-latest
    services:
      mssql:
        image: mcr.microsoft.com/mssql/server:2019-latest
        env:
          SA_PASSWORD: TestPass123!
          ACCEPT_EULA: Y
    steps:
      - run: # Apply all migrations V001–V<latest> and verify no errors

  storefront:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: cd frontend/tesco-storefront && npm ci
      - run: cd frontend/tesco-storefront && npm run lint
      - run: cd frontend/tesco-storefront && npm test -- --watch=false --browsers=ChromeHeadless
      - run: cd frontend/tesco-storefront && npm run build -- --configuration production

  admin:
    runs-on: ubuntu-latest
    steps:
      - run: cd frontend/tesco-admin && npm ci
      - run: cd frontend/tesco-admin && npm run lint
      - run: cd frontend/tesco-admin && npm test -- --watch=false --browsers=ChromeHeadless
      - run: cd frontend/tesco-admin && npm run build -- --configuration production

  security:
    runs-on: ubuntu-latest
    steps:
      - run: # gitleaks detect (secret scanning)
      - run: dotnet list package --vulnerable --include-transitive
```

### Deployment Flow

```
main branch push
  → CI passes
  → Create release tag vX.Y.Z
  → GitHub Actions release job:
      1. dotnet publish → upload artifact
      2. ng build (both apps) → upload artifacts
      3. Apply new DB migrations to staging
      4. Deploy to staging IIS / App Service
      5. Run smoke tests (health, login, search)
      6. Manual approval gate
      7. Apply migrations to production
      8. Deploy to production
      9. Monitor t.tblLog for 30 minutes
```

---

## Missing Architecture Components

The following components should be added in future phases:

### Phase 7 — Operational Readiness

| Component | Why Needed |
|---|---|
| Stripe webhook endpoint | Payment confirmation is currently fire-and-forget; failed payments are not re-processed |
| Background job queue (Hangfire) | Email and PDF generation block request threads |
| Redis distributed cache | SQL is hit for every catalogue read; high traffic will bottleneck |
| Health check detail endpoints | `/health/ready` and `/health/live` with DB + Redis + Stripe checks |
| OpenTelemetry tracing | Distributed tracing to correlate requests across the stack |

### Phase 8 — Scale and Resilience

| Component | Why Needed |
|---|---|
| Dockerfile + docker-compose | Reproducible local + CI environments |
| Azure Key Vault / AWS Secrets Manager | JWT secrets and connection strings should not be in appsettings |
| SQL Server read replica | Analytics queries contend with OLTP traffic |
| CDN + image optimisation | Product images served from wwwroot; no optimisation |
| Idempotency keys on cart/order endpoints | Duplicate requests from client retries cause duplicate records |
| Stock reservation lock on checkout | Without a lock, two concurrent checkouts can oversell the same variant |
| Seller portal SPA | Marketplace sellers have no self-service interface |
