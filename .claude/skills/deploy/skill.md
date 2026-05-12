# Deployment Skill

Use this skill when preparing, reviewing, or executing Tesco Clone deployment work.

## CI/CD Pipeline Structure

Recommended stages:

1. Restore dependencies.
2. Build backend.
3. Run backend unit and integration tests.
4. Validate database migration scripts.
5. Install frontend dependencies with `npm ci`.
6. Run Angular tests and lint.
7. Build storefront and admin apps.
8. Run secret and dependency scans.
9. Publish release artifacts.
10. Deploy to target environment.
11. Run post-deployment smoke tests.

## Environment Configuration Strategy

Configuration must be environment-specific:

- Development: local SQL Server, local frontend ports, verbose logging.
- Test: isolated database, test secrets, CI-friendly logging.
- Staging: production-like data shape, restricted credentials.
- Production: secrets manager or protected environment variables.

Required environment values:

- `ASPNETCORE_ENVIRONMENT`
- `ConnectionStrings__Default`
- `Jwt__SecretKey`
- `Jwt__Issuer`
- `Jwt__Audience`
- Payment provider configuration
- Email and SMS provider configuration

## Secrets Management

- Do not commit secrets.
- Do not store production secrets in appsettings files.
- Use environment variables or a secrets manager.
- Rotate secrets after accidental exposure.
- Restrict production secret access to release owners.
- Mask secrets in CI logs.

## Monitoring and Logging

Monitor:

- API health endpoint.
- HTTP 5xx rate.
- Authentication failures.
- Order creation failures.
- Payment and refund failures.
- Delivery slot booking conflicts.
- SQL timeout and deadlock errors.
- `t.tblLog` Error and Critical entries.

Logs must include:

- Correlation ID.
- Source.
- User ID when available.
- Operation name.
- Exception detail in secure server logs only.

## Rollback Strategy

Before deployment:

- Keep previous API artifact available.
- Keep previous frontend artifacts available.
- Prepare database rollback scripts.
- Take a database backup before schema changes.
- Define rollback owner and decision point.

Rollback if:

- Health check fails.
- Login fails.
- Checkout or order creation fails.
- Database migration fails.
- Error or Critical log volume spikes.
- Security incident is detected.

## Production Readiness Checklist

- `[ ]` Release branch and version confirmed.
- `[ ]` Changelog prepared.
- `[ ]` Backend build passes.
- `[ ]` Backend tests pass.
- `[ ]` Storefront build passes.
- `[ ]` Admin build passes.
- `[ ]` Database migrations reviewed.
- `[ ]` Rollback scripts reviewed.
- `[ ]` Secret scan passes.
- `[ ]` Dependency scan passes.
- `[ ]` Environment variables configured.
- `[ ]` Database backup completed.
- `[ ]` `/health` verified after deployment.
- `[ ]` Login, search, cart, checkout, delivery slot, Clubcard, and admin smoke tests pass.
- `[ ]` Logs monitored for at least 30 minutes.
