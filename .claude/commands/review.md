# Pull Request Review Prompt

Use this prompt to review a Tesco Clone pull request as a senior engineer. Focus on correctness, maintainability, security, architecture boundaries, and production risk.

## Input

- PR title:
- PR description:
- Changed files:
- Relevant requirement or issue:
- Test evidence:

## Review Goals

Review the change against the Tesco Clone architecture:

- .NET 8 Clean Architecture monolith
- CQRS with MediatR and FluentValidation
- ADO.NET repositories using stored procedures only
- SQL Server schemas `m` for master data and `t` for transactional data
- Angular 18 standalone components with OnPush change detection
- JWT authentication, RBAC, refresh token rotation, and audit logging

## Code Quality Checklist

- Code is readable, cohesive, and scoped to the PR goal.
- Controllers contain HTTP concerns only.
- Business logic lives in Application handlers or Domain services.
- Infrastructure implements Application interfaces without leaking outward.
- DTOs, commands, and queries are sealed records.
- Async methods are used for I/O.
- Nullability is handled intentionally.
- No duplicate logic that should be centralized.
- No unrelated refactors or formatting churn.

## Bug Detection Guidance

Check for:

- Missing validation or inconsistent validation between frontend and backend.
- Incorrect authorization rules or missing role checks.
- Race conditions in cart, inventory, delivery slot, payment, and order flows.
- Incorrect soft-delete filtering.
- Missing transaction handling around multi-table writes.
- Incorrect status transitions for orders, refunds, vouchers, or inventory.
- Pagination, filtering, or sorting bugs.
- Error responses that leak sensitive details.

## Performance Review Guidance

Check for:

- N+1 API calls or database calls.
- Stored procedures missing useful filters or pagination.
- Missing indexes for high-volume lookup columns.
- Inefficient frontend subscriptions or repeated signal computations.
- Oversized API responses.
- Missing cancellation token usage where appropriate.
- Expensive operations in request middleware.

## Security Review Guidance

Check for:

- Secrets, connection strings, tokens, or passwords committed to source.
- SQL injection risk; dynamic SQL is not allowed.
- Missing typed SQL parameters.
- Missing authentication or authorization attributes.
- Insecure password or token handling.
- Missing refresh token revocation.
- Missing audit log for data-modifying operations.
- XSS, CSRF, open redirect, insecure CORS, and unsafe file upload risks.
- Missing rate limiting for public and auth endpoints.

## Architecture and Clean Code Validation

Verify:

- Domain has no dependency on Application, Infrastructure, API, UI, or framework-specific packages.
- Application depends on Domain but not Infrastructure or API.
- Infrastructure depends on Application and Domain to implement interfaces.
- API depends on Application and Infrastructure registration but contains no business logic.
- Feature folders are grouped by module.
- Angular features are lazy-loaded and use shared/core boundaries correctly.

## Suggestions and Improvement Format

Return findings first, ordered by severity:

- `P0`: release blocker or data/security incident risk
- `P1`: correctness, security, or production reliability bug
- `P2`: maintainability, test gap, performance, or edge case
- `P3`: small cleanup or optional improvement

Each finding must include:

- File and line reference
- Why it matters
- Suggested fix
- Validation needed

## Example Output

```text
Findings

P1 - Missing transaction around order creation
File: src/TescoClone.Infrastructure/Repositories/Order/OrderRepository.cs:88
The handler creates an order and updates cart state in separate calls. A failure between calls can leave an active cart with a created order.
Suggested fix: wrap the stored procedure logic in a single SQL transaction and write audit entries inside the same transaction.
Validation: add integration test for failure during voucher redemption.

Open Questions

- Should cancelled orders release delivery slots immediately or through a background job?

Summary

The PR is close, but order creation needs transactional safety before merge.
```
