# Fix Issue Prompt

Use this prompt to debug and fix a Tesco Clone issue with a clear root-cause trail, minimal code changes, and regression coverage.

## Input

- Issue title:
- Expected behavior:
- Actual behavior:
- Steps to reproduce:
- Environment:
- Logs, screenshots, or traces:
- Related files or modules:

## Debugging Workflow

1. Reproduce the issue locally when possible.
2. Identify the failing layer: Angular, API, Application, Infrastructure, stored procedure, or data.
3. Trace the request through controller, command/query handler, repository, stored procedure, and response mapping.
4. Check validation, authorization, soft-delete filters, transaction boundaries, and audit logging.
5. Form a root-cause hypothesis.
6. Make the smallest production-quality fix.
7. Add or update tests that fail before the fix and pass after it.
8. Run relevant validation commands.

## Root-Cause Analysis Method

Document:

- Trigger: what starts the failure.
- Fault: the incorrect code, query, state, or assumption.
- Impact: user-visible or operational consequence.
- Scope: modules, endpoints, tables, or UI routes affected.
- Prevention: test, validation rule, guard, logging, or monitoring.

## Solution Proposal Format

```text
Root cause:

Fix:

Files changed:

Validation:

Regression risk:

Follow-up:
```

## Validation and Regression Checks

Backend:

- `dotnet build`
- `dotnet test`
- Endpoint smoke test through Swagger or HTTP client
- Verify logs contain correlation IDs
- Verify no sensitive details leak in errors

Database:

- Run migration or stored procedure script in a transaction.
- Verify `SET NOCOUNT ON`, `TRY/CATCH`, `THROW`, and audit logging.
- Verify `WHERE IsDeleted = 0` for reads.
- Verify no destructive SQL is present.

Angular:

- `npm test`
- `npm run lint`
- `npm run build`
- Verify no unmanaged subscriptions.
- Verify standalone component and OnPush usage.

## Example Output Structure

```text
Fixed the cart quantity update bug.

Root cause:
The repository passed `CartItemId` instead of `ProductId` to `proc_Order_UpdateCartItemQuantity`, causing updates to miss rows for newly added items.

Changed:
- Updated parameter mapping in `OrderRepository`.
- Added integration coverage for updating an existing cart line.

Validated:
- `dotnet test tests/TescoClone.IntegrationTests`
- Manual API check: add item, update quantity, fetch cart

Remaining risk:
None known.
```
