# REST API Conventions

## Naming Conventions

- Base route: `/api/v1`.
- Resource names are plural nouns.
- Use kebab-case only when a route segment contains multiple words.
- Use route IDs for resource identity.
- Use query string parameters for filters, sorting, and pagination.

Examples:

```text
GET    /api/v1/products/{id}
GET    /api/v1/products/search
POST   /api/v1/cart/items
DELETE /api/v1/cart/items/{id}
POST   /api/v1/orders/{id}/cancel
GET    /api/v1/slots/available
```

## Versioning Strategy

- Use URL versioning: `/api/v1`.
- Do not introduce breaking changes within the same API version.
- Additive response fields are allowed.
- Breaking request or response contract changes require a new version.

## HTTP Status Code Usage

| Status | Usage |
| --- | --- |
| 200 | Successful query or update with response body |
| 201 | Resource created |
| 204 | Successful command with no response body |
| 400 | Malformed request |
| 401 | Missing or invalid authentication |
| 403 | Authenticated but not authorized |
| 404 | Resource not found or not visible |
| 409 | Conflict, invalid state transition, or concurrency issue |
| 422 | Validation failure |
| 429 | Rate limit exceeded |
| 500 | Unexpected server error |

## Pagination and Filtering

Use:

```text
pageNumber=1
pageSize=20
sortBy=name
sortDirection=asc
```

Responses should include:

```json
{
  "items": [],
  "pageNumber": 1,
  "pageSize": 20,
  "totalCount": 0,
  "totalPages": 0
}
```

Filters must be explicit, validated, and translated into typed stored procedure parameters.

## Error Response Format

Use a consistent error body:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "One or more validation errors occurred.",
    "details": [
      {
        "field": "email",
        "message": "Email is required."
      }
    ],
    "correlationId": "..."
  }
}
```

Do not expose stack traces, SQL, secrets, tokens, or internal server paths.

## Validation Standards

- Validate commands and queries with FluentValidation.
- Validate route IDs are positive integers where applicable.
- Validate pagination bounds.
- Validate enum values.
- Validate date ranges.
- Validate user-owned resources against the authenticated user.

## Authentication and Authorization Best Practices

- Use JWT bearer authentication.
- Rotate refresh tokens after each refresh.
- Store refresh token state in `t.tblRefreshToken`.
- Use role policies for admin operations.
- Enforce ownership checks for customer resources.
- Apply rate limiting to public and auth endpoints.
- Return 404 instead of disclosing unauthorized resource existence when appropriate.
