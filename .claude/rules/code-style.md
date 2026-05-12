# Code Style Rules

## Naming Conventions

C#:

- Namespaces: `TescoClone.<Layer>.<Module>`.
- Classes, records, methods, and public properties: PascalCase.
- Private fields: `_camelCase`.
- Local variables and parameters: camelCase.
- Interfaces: `I<Name>`.
- Async methods: suffix with `Async`.
- DTOs: `<Feature><Purpose>Dto`.
- Commands: `<Action>Command`.
- Queries: `<Action>Query`.
- Validators: `<CommandOrQuery>Validator`.

Angular:

- Components: `feature-name.component.ts`.
- Services: `feature-name.service.ts`.
- Routes: `feature.routes.ts`.
- Store files: `feature.actions.ts`, `feature.effects.ts`, `feature.reducer.ts`, `feature.selectors.ts`.
- CSS classes: BEM-style SCSS names.

SQL:

- Master tables: `m.tbl<Name>`.
- Transaction tables: `t.tbl<Name>`.
- Stored procedures: `proc_<Module>_<Action>`.
- Functions: `fn_<Module>_<Action>`.
- Indexes: `IX_<Table>_<Columns>`.
- Foreign keys: `FK_<Child>_<Parent>`.

## Folder and Project Structure Guidelines

- Keep Clean Architecture projects separated by dependency direction.
- Group Application features by module, then by Commands, Queries, DTOs, and Interfaces.
- Keep API controllers grouped by module.
- Keep Infrastructure repositories grouped by module.
- Keep Angular app-wide singletons in `core`.
- Keep reusable presentational components in `shared`.
- Keep customer and admin feature code lazy-loaded.

## Clean Architecture Principles

- Domain must not reference Application, Infrastructure, API, Angular, MediatR, SQL, or web frameworks.
- Application may reference Domain and common abstractions.
- Infrastructure implements Application interfaces.
- API wires dependencies and handles HTTP only.
- Controllers must not contain business rules or database access.
- Repository interfaces live in Application; implementations live in Infrastructure.

## Commenting Standards

- Prefer self-explanatory code over comments.
- Add comments only when they explain non-obvious business rules, security choices, transaction boundaries, or performance tradeoffs.
- Do not comment obvious assignments or method calls.
- Public APIs should have XML documentation only when consumed outside the immediate project or when behavior is subtle.

## Error Handling Guidelines

- Use domain-specific exceptions for business failures.
- Use FluentValidation for request validation.
- Use centralized exception middleware for API responses.
- Never leak stack traces, connection strings, tokens, or SQL details to clients.
- Include correlation IDs in logs and error responses.
- Log exceptions once at the boundary where enough context exists.

## Logging Standards

- Use structured logging.
- Include correlation ID, user ID when available, source, and operation name.
- Log security-sensitive events: failed login, lockout, token refresh failure, forbidden access, admin changes.
- Do not log passwords, tokens, card data, secrets, or full personal data payloads.
- Database CATCH blocks must write to `t.tblLog` before `THROW`.

## Commit Message Format

Use Conventional Commits:

```text
<type>(<scope>): <short imperative summary>
```

Allowed types:

- `feat`
- `fix`
- `refactor`
- `perf`
- `test`
- `docs`
- `chore`
- `db`
- `ci`

Examples:

```text
feat(catalogue): add paginated product search
fix(order): prevent duplicate delivery slot booking
db(identity): add refresh token rotation procedure
test(cart): cover quantity update validation
```
