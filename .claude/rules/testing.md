# Testing Rules

## Unit Testing Standards

- Test Domain rules and Application handlers in isolation.
- Mock repository interfaces and external services.
- Cover validation rules with focused validator tests.
- Use deterministic test data.
- Avoid testing framework internals.
- Use Arrange, Act, Assert structure.

## Integration Testing Standards

- Test API endpoints, middleware, authorization, and repository-to-database behavior.
- Verify stored procedure calls through realistic test data.
- Verify transactions roll back on failure.
- Verify audit log writes for data-changing operations.
- Verify soft-deleted records do not appear in reads.
- Use isolated test databases or disposable schemas.

## Test Naming Conventions

Use descriptive names:

```text
MethodOrScenario_ShouldExpectedBehavior_WhenCondition
```

Examples:

```text
CreateOrder_ShouldCopyCartItems_WhenCartIsValid
SearchProducts_ShouldExcludeDeletedProducts_WhenCustomerQuery
Login_ShouldLockAccount_WhenFiveFailuresOccur
```

## Coverage Expectations

Prioritize coverage for:

- Authentication and refresh token rotation.
- Role-based authorization.
- Cart and checkout.
- Order status transitions.
- Payment and refund boundaries.
- Delivery slot booking concurrency.
- Catalogue search filters and pagination.
- Voucher redemption and Clubcard points.
- Database migrations and stored procedures.
- Security middleware and headers.

## CI Pipeline Testing Requirements

CI must run:

- `dotnet restore`
- `dotnet build`
- `dotnet test`
- SQL migration validation
- Angular install with `npm ci`
- Angular unit tests
- Angular lint
- Angular production build
- Secret scanning
- Dependency vulnerability scanning

## Mocking and Test Data Guidelines

- Mock external providers such as email, SMS, payment gateways, and object storage.
- Do not mock domain logic.
- Use builders or factories for reusable test data.
- Keep personal data fake and minimal.
- Use stable dates and clocks through abstractions.
- Avoid tests that depend on execution order.
