# Tesco Clone — Claude Project Guide

> **Production-level reference for AI-assisted development. Read this before writing any code.**

---

## System Architecture Overview

Tesco Clone is a Clean Architecture monolith — one deployable .NET 8 Web API backed by Microsoft SQL Server, served alongside two Angular 18 single-page applications (customer storefront and admin panel). The backend enforces CQRS via MediatR with FluentValidation pipeline behaviors. All database access is through ADO.NET repositories that call SQL Server stored procedures exclusively.

### Business Modules

| Module | Responsibility |
|---|---|
| Identity | Users, roles, JWT, refresh-token rotation, RBAC, admin 2FA |
| Catalogue | Departments, categories, brands, products, variants, inventory |
| Order | Cart, checkout, orders, payments (Stripe), refunds, invoices |
| Delivery | Stores, slots, zones, Whoosh-style express delivery |
| Loyalty | Clubcard, points earn/redeem, vouchers, eCoupons |
| Promotions | Pricing rules, promotion lifecycle |
| Content | CMS pages, banners, recipes, FAQs |
| Marketplace | Sellers, listings, commissions, disputes |
| Analytics | KPI dashboards, sales reports, CSV exports |
| Notification | Email, SMS, push-notification dispatch |

---

## Technology Stack

| Area | Decision | Version |
|---|---|---|
| Backend runtime | .NET Web API | 8.0 |
| Architecture | Clean Architecture monolith | — |
| Application pattern | CQRS with MediatR | 12.4.1 |
| Validation | FluentValidation pipeline behavior | 11.10.0 |
| Database | Microsoft SQL Server | 2019+ |
| Data access | ADO.NET + stored procedures only | Microsoft.Data.SqlClient 5.2.2 |
| Auth | JWT bearer + refresh-token rotation | — |
| PDF generation | QuestPDF | 2026.5.0 |
| Payment gateway | Stripe | Stripe.net 51.1.0 |
| Frontend | Angular standalone components | 18.2 |
| Storefront state | Angular Signals (local) + NgRx (shared) | — |
| Styling | SCSS with BEM naming | — |
| Stripe frontend | ngx-stripe | 18.1.0 |

---

## Folder Structure

```text
e:\Tesco\Tesco-clone\
├── src/
│   ├── TescoClone.Domain/          # Entities, enums, domain exceptions — zero framework deps
│   ├── TescoClone.Application/     # Commands, queries, validators, DTOs, interfaces, pipeline behaviors
│   ├── TescoClone.Infrastructure/  # Repository impls, SqlHelper, services, external adapters
│   └── TescoClone.API/             # Controllers, middleware, Program.cs, appsettings.json
├── frontend/
│   ├── tesco-storefront/           # Angular 18 customer app (port 8082 local)
│   └── tesco-admin/                # Angular 18 admin panel (port 8083 local)
├── database/
│   ├── migrations/                 # V001–V076 versioned SQL scripts
│   ├── stored-procedures/          # Source-controlled SP definitions
│   ├── functions/                  # SQL scalar/table-valued functions
│   └── seed/                       # Reference and demo seed data
├── tests/
│   ├── TescoClone.UnitTests/       # xUnit — domain + handler isolation tests
│   └── TescoClone.IntegrationTests/# xUnit — API + SP + auth integration tests
├── .claude/
│   ├── rules/                      # api-conventions, code-style, database, testing
│   ├── commands/                   # deploy, fix-issue, review
│   ├── skills/                     # deploy, security-review
│   ├── agents/                     # code-reviewer
│   └── docs/                       # tesco-design.md (brand tokens, UX patterns)
├── CLAUDE.md                       # This file
├── ARCHITECTURE.md                 # Deep system architecture reference
├── DESIGN.md                       # UI/UX design standards and guidelines
└── README.md
```

---

## Layer Responsibilities

| Layer | Project | Rule |
|---|---|---|
| Domain | `TescoClone.Domain` | No references to any other layer, framework, or NuGet package |
| Application | `TescoClone.Application` | References Domain only; defines interfaces; no I/O |
| Infrastructure | `TescoClone.Infrastructure` | Implements Application interfaces; owns all I/O |
| API | `TescoClone.API` | Wires DI, handles HTTP, delegates everything to MediatR |

---

## Existing Features — Full Inventory

### Customer Storefront (tesco-storefront)

#### Authentication & Account
- [x] Register with email + password validation
- [x] Login with JWT + SHA-256 hashed refresh token rotation
- [x] Logout / revoke refresh token
- [x] Forgot password / reset password (token-based, V076)
- [x] Account dashboard
- [x] Profile edit (name, phone)
- [x] Address book (add, update, soft-delete)
- [x] Saved payment cards (Stripe tokenised)
- [x] Clubcard overview (points balance, vouchers)

#### Catalogue & Search
- [x] Department listing page
- [x] Category page with sub-category chip strip, filter accordion, sort/count bar
- [x] Product detail with variant selector, nutritional tabs, Clubcard pricing badge
- [x] Full-text search with filters and pagination
- [x] Offer/promotion badges on product cards
- [x] Brand filtering

#### Cart & Checkout
- [x] Persistent cart (server-side per user)
- [x] Add, update quantity, remove, clear cart
- [x] Quantity stepper component
- [x] Basket sidebar on category page
- [x] Three-step checkout (delivery → payment → review)
- [x] Delivery slot selector integrated in checkout
- [x] Clubcard voucher redemption at checkout
- [x] Stripe payment intent + card element
- [x] Order confirmation with invoice number

#### Orders
- [x] Order list (paginated, filterable by status)
- [x] Order detail with line items, totals, delivery info
- [x] Order cancellation (customer-initiated)
- [x] Invoice PDF download (QuestPDF)

#### Delivery
- [x] Delivery slot search by postcode + date range
- [x] UPDLOCK concurrency guard on slot booking
- [x] Delivery Saver subscription page
- [x] Store locator (map placeholder + list)

#### Loyalty
- [x] Clubcard balance and points history
- [x] Points earn on order completion
- [x] Points redemption at checkout
- [x] Voucher list with expiry dates
- [x] Voucher redemption at checkout

#### Content Pages
- [x] Home page (8 sections: hero, quick-links, featured, offers, Clubcard, recipes, banners, footer promo)
- [x] Recipes listing and detail
- [x] Help / FAQ
- [x] Tesco Magazine stub
- [x] Accessibility statement
- [x] Terms and conditions
- [x] Product terms
- [x] Ratings and reviews policy
- [x] Product recall notice page
- [x] Delivery Saver terms

---

### Admin Panel (tesco-admin)

#### Authentication
- [x] First-factor login (email + password)
- [x] Second-factor 2FA (6-digit SHA-256 OTP, time-limited)
- [x] Admin forgot-password / reset-password flow
- [x] Auto-logout on token expiry via interceptor

#### Dashboard
- [x] KPI tiles: total orders, revenue, new users, pending disputes
- [x] Recent orders table
- [x] Low-stock alerts

#### Catalogue Management
- [x] Products: paginated list, search, create, edit (name, description, images, Clubcard price, brand, category), soft-delete
- [x] Categories: list, create, edit, link to department, soft-delete
- [x] Departments: list, create, edit, soft-delete
- [x] Brands: list, create, edit, soft-delete
- [x] Product variants: manage sizes/colours per product
- [x] Inventory: per-variant stock level, adjustment history

#### Order Management
- [x] All-orders list with status filter and date-range picker
- [x] Order detail with full line items
- [x] Order status update (Pending → Processing → Dispatched → Delivered)
- [x] Initiate refund via Stripe

#### Promotions
- [x] Create promotion (type, discount value/percentage, date range, target scope)
- [x] Edit and soft-delete promotions
- [x] Active/inactive/expired filter

#### User Management
- [x] Customer and admin user list with search
- [x] Lock / unlock accounts
- [x] Assign roles (User / Admin / SuperAdmin)
- [x] View login history (via audit log)

#### Content Management
- [x] CMS pages: create, edit, publish, soft-delete
- [x] Banners: create, edit, set date range, soft-delete
- [x] Preview page slug routing

#### Marketplace
- [x] Seller applications: approve / suspend
- [x] Dispute list with resolution workflow

#### Analytics
- [x] Sales dashboard with date-range selector
- [x] Top products by revenue
- [x] Customer acquisition stats
- [x] CSV export

#### Audit & Logs
- [x] Paginated audit log with actor, action, entity, timestamp filters
- [x] Application error log viewer with severity filter

---

## Missing / Incomplete Features

The following features have routes and service stubs but lack full backend or frontend implementation. These are Phase 6+ targets.

### High Priority (core e-commerce gaps)

| Feature | Missing Component | Notes |
|---|---|---|
| Product image upload | Infrastructure + API endpoint | Need blob/file storage; `wwwroot` placeholder only |
| Email notifications | `EmailService` wired but no templates | Welcome, order-confirm, reset-password, dispatch emails |
| SMS notifications | Interface defined, no provider wired | Delivery slot reminders |
| Push notifications | `INotificationService` stub | Browser push for order updates |
| Payment webhook handler | No Stripe webhook endpoint | Needed for async payment confirmation and refund events |
| eCoupon management | Domain entities exist, no SP or UI | Digital coupons distinct from vouchers |
| Marketplace seller listing CRUD | Dispute UI exists; listing CRUD missing | Sellers can be approved but cannot add products |
| Marketplace commission engine | Interface defined, no implementation | `fn_Marketplace_CalculateCommission` not implemented |
| Delivery zone management | Admin UI missing | Zones exist in DB; no admin CRUD |
| Recipes CRUD (admin) | No admin route | Recipes read from DB seed only |
| Product review / ratings | No tables or endpoints | Policy page exists, feature does not |
| Order tracking (real-time) | No SignalR / polling | Status updates require manual refresh |
| Stock reservation on checkout | No lock on CartItem during checkout | Risk of overselling under concurrency |

### Medium Priority

| Feature | Notes |
|---|---|
| Admin notification centre | Broadcast email/SMS to customers |
| Saved searches / wishlists | No `t.tblWishlist` table |
| Product comparison | UI and service stubs only |
| Recently viewed products | No tracking table |
| Related / recommended products | No recommendation engine |
| Gift cards | Not in domain model |
| Returns and exchanges portal | Refund exists; formal return flow missing |
| Seller portal (separate app) | Marketplace sellers currently managed only through admin |
| GDPR data export / deletion | No `proc_Identity_ExportUserData` |
| Admin report scheduling | Manual CSV export only; no scheduled email reports |
| Multi-currency pricing | `Price` is single decimal; no currency column |

### Infrastructure / DevOps Gaps

| Gap | Notes |
|---|---|
| Background job processor | No Hangfire / Quartz; email and notification are fire-and-forget only |
| Distributed caching | No Redis; SQL-based session only |
| CDN integration | Static assets served from `wwwroot`; no CDN config |
| Health check endpoints | `/health` exists but checks only DB ping |
| Application performance monitoring | No OpenTelemetry / Application Insights wiring |
| Container support | No Dockerfile or docker-compose |
| CI/CD pipeline | No GitHub Actions / Azure DevOps YAML |
| Secret management | Secrets in `appsettings.json`; no Azure Key Vault / AWS Secrets Manager |

---

## API and Backend Features

### Controllers (22 total)

#### Customer-Facing

| Controller | Routes | Auth |
|---|---|---|
| `AuthController` | POST register, login, refresh, revoke, forgot-password, reset-password | Public / Bearer |
| `ProductsController` | GET products/{id}, search | Public |
| `CatalogueController` | GET departments, categories | Public |
| `CartController` | GET cart, POST items, PUT items/{id}, DELETE items/{id}, DELETE clear | Bearer |
| `OrdersController` | GET orders, orders/{id}, POST orders, POST orders/{id}/cancel | Bearer |
| `SlotsController` | GET slots/available, POST slots/{id}/book | Bearer |
| `ClubcardController` | GET balance, POST earn, POST redeem-points, GET vouchers, POST redeem-voucher | Bearer |
| `AddressesController` | GET, POST, PUT, DELETE /addresses | Bearer |
| `PaymentsController` | GET methods, POST methods, DELETE methods/{id}, POST intent | Bearer |
| `PromotionsController` | GET active promotions | Public |
| `ContentController` | GET pages/{slug}, banners | Public |

#### Admin-Only

| Controller | Routes | Auth |
|---|---|---|
| `AdminAuthController` | POST login, verify-2fa, forgot-password, reset-password | Admin policy |
| `AdminCatalogueController` | Full CRUD — products, categories, departments, brands, variants, inventory | Admin |
| `AdminOrdersController` | GET all orders, PUT status, POST refund | Admin |
| `AdminPromotionsController` | Full CRUD promotions | Admin |
| `AdminUsersController` | GET users, PUT lock/unlock, PUT assign-role | SuperAdmin |
| `AdminContentController` | Full CRUD pages, banners | Admin |
| `AdminMarketplaceController` | PUT approve/suspend seller, GET/PUT disputes | Admin |
| `AdminAnalyticsController` | GET dashboard, sales, top-products, export | Admin |
| `AdminAuditController` | GET audit-logs, application-logs | Admin |
| `AdminDashboardController` | GET KPIs | Admin |

### Middleware Pipeline (in order)

1. `CorrelationIdMiddleware` — generates or propagates `X-Correlation-ID` header
2. `SecurityHeadersMiddleware` — HSTS, CSP, CORP, COOP, Permissions-Policy, no-cache for auth/admin routes
3. `ExceptionMiddleware` — catches all unhandled exceptions; returns structured `ApiError` JSON; logs to `t.tblLog`
4. Rate limiting — fixed window (auth 10/min), sliding window (API 100/min), token bucket (public 200/min)
5. Authentication / Authorization — JWT bearer validation, role policies
6. MediatR pipeline — `ValidationBehavior` → `LoggingBehavior` → handler

### MediatR Pipeline Behaviors

| Behavior | Order | Purpose |
|---|---|---|
| `ValidationBehavior<TReq,TRes>` | 1 | Runs all FluentValidation validators; throws `ValidationException` on failure |
| `LoggingBehavior<TReq,TRes>` | 2 | Structured request/response timing log with correlation ID |

---

## Security Considerations

### Implemented

- JWT HS256 tokens with configurable expiry (recommend: 15 min access, 7 day refresh)
- Refresh token stored as SHA-256 hash in `t.tblRefreshToken`; rotation on every use
- Admin requires two-factor OTP (SHA-256 hashed 6-digit code, time-bounded)
- Account lockout after 5 failed login attempts (`LockedUntil` timestamp)
- OWASP security headers via `SecurityHeadersMiddleware`
- Rate limiting on all public and auth endpoints
- Role-based authorization (User / Admin / SuperAdmin) with policy guards
- Correlation ID in every log entry and error response
- No secrets in domain or application layers
- Typed SQL parameters — no dynamic SQL
- Soft deletes prevent data loss from accidental or malicious delete calls
- Stripe tokenisation — no raw card data ever touches the backend

### Required Improvements

- Move JWT secrets and connection strings to Azure Key Vault or environment-level secrets
- Add `SameSite=Strict` cookie policy for refresh token (currently in Authorization header)
- Implement PKCE flow if SPA-to-API auth is ever decoupled
- Add brute-force IP rate limiting at the reverse proxy level (IIS / nginx)
- Enable SQL Server TDE (Transparent Data Encryption) in production
- Add HSTS preload in production `SecurityHeadersMiddleware`
- Rotate JWT signing key on a schedule
- Implement token binding or device fingerprinting for refresh tokens
- Add audit log for every admin password reset
- Validate `Origin` header on WebSocket / SignalR endpoints when added

---

## Performance Considerations

### Implemented

- Async/await throughout the stack — no blocking I/O
- `SqlConnectionFactory` as singleton with connection pooling
- Pagination enforced at SP level; no in-memory pagination
- `ChangeDetectionStrategy.OnPush` on all Angular components
- Lazy-loaded Angular routes

### Required Improvements

- Add Redis distributed cache for: hot catalogue data, department/category tree, active promotions, session tokens
- Add HTTP response caching headers for public catalogue endpoints
- Use `IAsyncEnumerable` in SqlHelper for large result set streaming
- Add database read replicas for analytics queries
- Add composite indexes for multi-column search filters (postcode + date, product + category)
- Bundle and compress Angular production builds with Brotli
- Implement image optimisation pipeline (WebP conversion, responsive `srcset`)
- Add a background job queue (Hangfire) to move email and invoice generation off the request thread

---

## Coding Standards — Quick Reference

### C# (.NET)

```csharp
// Namespace form
namespace TescoClone.Application.Catalogue.Commands;

// DTO — sealed record
public sealed record CreateProductDto(string Name, decimal Price, int CategoryId);

// Command — sealed record
public sealed record CreateProductCommand(CreateProductDto Dto, int CreatedBy) : IRequest<int>;

// Handler — inherits nothing, receives injected repos
public sealed class CreateProductHandler(IProductRepository repo)
    : IRequestHandler<CreateProductCommand, int>
{
    public async Task<int> Handle(CreateProductCommand cmd, CancellationToken ct)
        => await repo.CreateAsync(cmd.Dto, cmd.CreatedBy, ct);
}

// Validator
public sealed class CreateProductCommandValidator : AbstractValidator<CreateProductCommand>
{
    public CreateProductCommandValidator()
    {
        RuleFor(x => x.Dto.Name).NotEmpty().MaximumLength(200);
        RuleFor(x => x.Dto.Price).GreaterThan(0);
    }
}
```

- Private fields: `_camelCase`
- Async methods: `Async` suffix
- Interfaces: `I<Name>` (e.g., `IProductRepository`)
- No business logic in controllers; delegate to `_mediator.Send()`
- Nullable reference types enabled in all projects

### SQL

```sql
CREATE OR ALTER PROCEDURE proc_Catalogue_CreateProduct
    @Name        NVARCHAR(200),
    @Price       DECIMAL(18,4),
    @CategoryId  INT,
    @CreatedBy   INT
AS
SET NOCOUNT ON;
BEGIN TRY
    BEGIN TRANSACTION;

        INSERT INTO m.tblProduct (Name, Price, CategoryId, CreatedBy, CreatedOn)
        VALUES (@Name, @Price, @CategoryId, @CreatedBy, GETUTCDATE());

        DECLARE @NewId INT = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (EntityType, EntityId, Action, CreatedBy, CreatedOn)
        VALUES ('Product', @NewId, 'CREATE', @CreatedBy, GETUTCDATE());

    COMMIT TRANSACTION;
    SELECT @NewId AS ProductId;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Message, StackTrace, CreatedOn)
    VALUES (ERROR_MESSAGE(), ERROR_PROCEDURE(), GETUTCDATE());
    THROW;
END CATCH;
```

- Always `SET NOCOUNT ON`
- Always `BEGIN TRY / BEGIN CATCH`
- Always write to `t.tblAuditLog` on data change
- Always write to `t.tblLog` in CATCH before `THROW`
- Soft delete: `RecordStatusId = 3, IsDeleted = 1`
- Every table needs: `RecordStatusId, CreatedBy, CreatedOn, ModifiedBy, ModifiedOn, IsDeleted`

### Angular

```typescript
@Component({
  selector: 'app-product-card',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [CommonModule, RouterLink],
  templateUrl: './product-card.component.html',
  styleUrl: './product-card.component.scss',
})
export class ProductCardComponent {
  private readonly catalogue = inject(CatalogueService);
  readonly product = input.required<Product>();
}
```

- `inject()` for DI — never constructor injection in Angular
- `ChangeDetectionStrategy.OnPush` on every component
- `standalone: true` on every component
- `takeUntilDestroyed()` for RxJS subscriptions
- Signals for local/component state; NgRx for cross-feature shared state
- BEM SCSS: `block__element--modifier`

### Commit Messages

```text
feat(catalogue): add paginated product search endpoint
fix(order): prevent duplicate delivery-slot booking
db(identity): add refresh-token rotation stored procedure
test(cart): cover quantity-update validation edge cases
chore(deps): bump Stripe.net to 51.1.0
```

Types: `feat | fix | refactor | perf | test | docs | chore | db | ci`

---

## Database Safety Rules

Claude must **never** generate or run:

- `DROP DATABASE` / `DROP SCHEMA` / `DROP TABLE`
- `TRUNCATE TABLE`
- `DELETE FROM <table>` without a narrow `WHERE` clause

All schema changes must be:
1. A new versioned migration: `database/migrations/V<NNN>_<description>.sql`
2. Wrapped in a transaction
3. Idempotent where practical (use `IF NOT EXISTS` guards)
4. Accompanied by a rollback script
5. Applied in version order

---

## Environment Setup

### Prerequisites

- .NET 8 SDK
- Node.js 20 LTS + npm 10
- SQL Server 2019+ (or SQL Server Express / Developer edition locally)
- Angular CLI 18: `npm install -g @angular/cli@18`

### Local Configuration

**`src/TescoClone.API/appsettings.Development.json`** (create if missing):

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=TescoClone;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Jwt": {
    "Secret": "<dev-secret-min-32-chars>",
    "Issuer": "TescoClone",
    "Audience": "TescoCloneClient",
    "AccessTokenExpiryMinutes": 15,
    "RefreshTokenExpiryDays": 7
  },
  "Stripe": {
    "SecretKey": "sk_test_...",
    "PublishableKey": "pk_test_...",
    "WebhookSecret": "whsec_..."
  },
  "Cors": {
    "AllowedOrigins": ["http://localhost:4200", "http://localhost:4201"]
  }
}
```

### Running Locally

```bash
# 1. Apply database migrations (run each in order in SSMS or sqlcmd)
#    database/migrations/V001_*.sql ... V076_*.sql

# 2. Start API
cd src/TescoClone.API
dotnet run

# 3. Start storefront (separate terminal)
cd frontend/tesco-storefront
npm ci
ng serve --port 4200

# 4. Start admin panel (separate terminal)
cd frontend/tesco-admin
npm ci
ng serve --port 4201
```

---

## Deployment Strategy

### Release Flow

1. `git checkout -b release/vX.Y.Z`
2. `dotnet build --configuration Release` — must be 0 errors
3. `dotnet test` — all unit and integration tests must pass
4. Review `database/migrations/` for any new scripts since last release
5. Take a database backup
6. Apply new migrations in order
7. `dotnet publish --configuration Release --output publish/api`
8. `ng build --configuration production` in both frontend apps
9. Deploy `publish/api` to IIS / app server
10. Deploy `dist/` assets to IIS static sites (or CDN)
11. Smoke test: `/health`, login, add to cart, checkout, admin dashboard
12. Monitor `t.tblLog` — watch for Error/Critical rows for 30 minutes post-deploy

### Rollback Plan

- Revert IIS bindings to previous publish folder
- Run rollback migration scripts (each `V<NNN>` should have a corresponding `V<NNN>_rollback.sql`)
- Restore database backup if data was mutated

---

## Testing Strategy

### Layers

| Layer | Project | Framework | Scope |
|---|---|---|---|
| Unit | `TescoClone.UnitTests` | xUnit + Moq | Handlers, validators, domain rules, services |
| Integration | `TescoClone.IntegrationTests` | xUnit + WebApplicationFactory | API endpoints, stored procedures, middleware, auth |
| Angular unit | `tesco-storefront` / `tesco-admin` | Jasmine + Karma | Services, components, guards, interceptors |
| Angular E2E | Not yet configured | Playwright (recommended) | Golden path flows |

### Coverage Priorities

1. Auth: register, login, lockout, refresh rotation, revoke
2. Cart: add, update quantity, remove, clear, concurrency
3. Checkout: slot booking concurrency, payment intent creation, order placement
4. Order status transitions and cancellation
5. Clubcard: earn, redeem, voucher expiry validation
6. Admin: 2FA flow, role assignment, audit log writes
7. FluentValidation: boundary values for all command/query validators
8. SecurityHeadersMiddleware and CorrelationIdMiddleware
9. Exception middleware — correct error shape and log write

### Test Naming Convention

```text
<Action>_Should<Expected>_When<Condition>

Examples:
Login_ShouldReturnTokens_WhenCredentialsAreValid
BookSlot_ShouldReturn409_WhenSlotIsAlreadyTaken
RedeemVoucher_ShouldFail_WhenVoucherIsExpired
```

---

## Maintenance and Scaling Guidelines

### Code Maintenance

- Keep controllers thin — one `_mediator.Send()` per action
- Add new features in dedicated module subfolders; never extend existing handlers
- New SP = new migration; never edit deployed SPs directly without a migration
- All audit trail writes are mandatory — never skip `t.tblAuditLog`
- Run `dotnet test` before every commit to `main`
- Use the code-reviewer agent (`.claude/agents/code-reviewer.md`) before any PR merge

### Scaling Path

1. **Cache hot data**: deploy Redis; cache `GetDepartments`, `GetCategories`, active promotions, and Clubcard balance
2. **Separate read/write**: point analytics and read-heavy queries at a SQL read replica
3. **Offload I/O**: move email, PDF generation, and notification dispatch to a Hangfire background job queue
4. **Container**: Dockerise the API; deploy to AKS or App Service; deploy Angular apps to Azure Static Web Apps with CDN
5. **Feature flags**: add LaunchDarkly or Azure App Configuration flags to gate new features
6. **Module extraction**: if a module (e.g., Marketplace) grows too complex, extract it to a separate service behind the API gateway with a shared `t.tblLog` and `t.tblAuditLog`

### Observability

- Structured logs via `ILogger<T>` (already wired); ship to Application Insights or ELK
- Correlate every log entry to `X-Correlation-ID`
- Alert on `t.tblLog` rows where `Severity = 'Error'` or `'Critical'` within 5 minutes
- Add `/health/ready` and `/health/live` endpoints with DB ping and dependency checks
- Track Stripe webhook delivery and retry failures in `t.tblLog`

---

## Progress Log

| Date | Phase | Summary | Status |
|---|---|---|---|
| 2026-05-12 | Phase 1 | Solution structure, DB conventions, Angular shells | Complete |
| 2026-05-12 | Phase 2 | Domain/Application/Infrastructure/API layers; 12 migrations; 7 tests | Complete |
| 2026-05-13 | Phase 3 | Auth, Catalogue, Cart, Orders, Delivery, Loyalty; V013–V018 | Complete |
| 2026-05-13 | Phase 4 | RBAC, Admin 2FA, Admin CRUD, Audit, Marketplace, Rate Limiting, OWASP headers; V019–V025 | Complete |
| 2026-05-13 | Phase 5 | Full Angular 18 storefront (30+ routes) + admin panel (11 pages); all lazy-loaded | Complete |
| TBD | Phase 6 | Unit test suite expansion, integration tests, CI/CD pipeline, Angular tests | Pending |
| TBD | Phase 7 | Email templates, Stripe webhooks, background jobs, Redis cache, product image upload | Pending |
| TBD | Phase 8 | Marketplace seller portal, E2E tests, container deployment, Key Vault | Pending |
