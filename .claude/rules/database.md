# Database Rules

## Mandatory Safety Rule

Claude must never generate or execute destructive SQL commands such as:

```sql
DROP DATABASE
DROP SCHEMA
DROP TABLE
TRUNCATE TABLE
DELETE FROM <table>
```

`DELETE` is prohibited unless it has an explicit, narrow `WHERE` clause and the developer has confirmed the action. Prefer soft deletes in all normal application flows.

## Safe Database Practices

- Always use transactions for data changes.
- Always recommend a backup before schema changes.
- Prefer soft deletes over hard deletes.
- Provide migration scripts instead of destructive changes.
- Use idempotent scripts where practical.
- Require confirmation before any destructive action.
- Write rollback guidance for every production migration.
- Use stored procedures for application data access.
- Use typed SQL parameters only.
- Do not use dynamic SQL unless explicitly justified and reviewed.

## SQL Server Stored Procedure Standards

Every stored procedure must:

- Start with `SET NOCOUNT ON;`.
- Use typed parameters.
- Use `BEGIN TRY` and `BEGIN CATCH`.
- Use transactions for data-changing operations.
- Write database errors to `t.tblLog`.
- Re-throw with `THROW`.
- Return predictable result sets or output parameters.
- Filter soft-deleted records with `IsDeleted = 0`.

Data-changing stored procedures must:

- Write to `t.tblAuditLog`.
- Include `CreatedBy`, `CreatedOn`, `ModifiedBy`, and `ModifiedOn` handling.
- Use UTC timestamps through `GETUTCDATE()` or `SYSUTCDATETIME()`.

## Required System Columns

Every application table must include:

```sql
RecordStatusId TINYINT NOT NULL DEFAULT 1,
CreatedBy INT NOT NULL,
CreatedOn DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
ModifiedBy INT NULL,
ModifiedOn DATETIME2 NULL,
IsDeleted BIT NOT NULL DEFAULT 0
```

## Soft Delete Standard

Soft delete records by setting:

```sql
RecordStatusId = 3,
IsDeleted = 1,
ModifiedBy = @UserId,
ModifiedOn = GETUTCDATE()
```

Every SELECT used by customer-facing or standard admin reads must include the correct visibility filter.

## Schema Conventions

- `m`: master and reference tables.
- `t`: transactional, audit, and log tables.

## Naming Conventions

| Object | Convention | Example |
| --- | --- | --- |
| Master table | `m.tbl<Name>` | `m.tblProduct` |
| Transaction table | `t.tbl<Name>` | `t.tblOrder` |
| Stored procedure | `proc_<Module>_<Action>` | `proc_Catalogue_GetProductById` |
| Function | `fn_<Module>_<Action>` | `fn_Order_CalculateDeliveryCharge` |
| Index | `IX_<Table>_<Columns>` | `IX_tblProduct_CategoryId` |
| Foreign key | `FK_<Child>_<Parent>` | `FK_tblOrderLine_tblProduct` |

## Indexing and Performance Guidelines

- Index foreign keys.
- Index frequently filtered columns.
- Use composite indexes for common multi-column filters.
- Avoid indexing every column.
- Review execution plans for high-volume procedures.
- Keep pagination in the database for large result sets.
- Avoid SELECT `*` in stored procedures.
- Keep result sets intentionally shaped for API DTOs.

## Migration Guidelines

- Use versioned files: `V001_description.sql`.
- Include author, date, description, and dependency comments.
- Make scripts repeat-safe where practical.
- Record applied migrations in a migration table.
- Run DDL in transactions where SQL Server supports it.
- Never mix unrelated module changes in one migration.
