# Security Review Skill

Use this skill when reviewing or implementing security-sensitive Tesco Clone changes.

## Secret Scanning

Check for committed:

- Connection strings.
- JWT secrets.
- API keys.
- Payment provider keys.
- SMTP credentials.
- Storage account keys.
- Private certificates.
- Real customer data.

Secrets must be supplied through environment variables or a secrets manager.

## Dependency Vulnerability Checks

Review:

- NuGet package vulnerabilities.
- npm audit results.
- Deprecated authentication, JWT, crypto, or serialization packages.
- Transitive dependency risk.
- License constraints for production use.

## OWASP Top 10 Practices

Check for:

- Broken access control.
- Cryptographic failures.
- Injection, especially SQL injection.
- Insecure design.
- Security misconfiguration.
- Vulnerable and outdated components.
- Identification and authentication failures.
- Software and data integrity failures.
- Security logging and monitoring failures.
- Server-side request forgery.

## Authentication and Authorization Checks

- JWT validation must verify issuer, audience, signature, lifetime, and signing key.
- Refresh tokens must rotate on every refresh.
- Revoked refresh tokens must not be accepted.
- Failed login attempts must update lockout metadata.
- Admin roles must require the correct role policy.
- Admin 2FA must be required for sensitive roles.
- Customer resources must be checked against the authenticated user ID.

## Input Validation and Sanitization

- Use FluentValidation for API requests.
- Validate route IDs, pagination, sorting, filters, dates, and enum values.
- Use typed SQL parameters only.
- Never concatenate user input into SQL.
- HTML-encode user-generated content on output.
- Validate file uploads by size, type, extension, and content where applicable.

## Logging and Monitoring Security Events

Log:

- Failed login attempts.
- Account lockouts.
- Token refresh failures.
- Forbidden access attempts.
- Admin data changes.
- Payment or refund state changes.
- Security configuration errors.

Never log:

- Passwords.
- Raw tokens.
- Card numbers.
- Secret keys.
- Full personal data payloads.

Every security log should include correlation ID, timestamp, source, user ID when available, and IP address when available.
