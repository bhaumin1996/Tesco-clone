# Tesco Clone Database

## Local Development Convention

- SQL Server instance: `(localdb)\MSSQLLocalDB`
- Database name: `TescoCloneDb`
- API connection string key: `ConnectionStrings__Default`

The checked-in development connection string uses Windows authentication and does not contain secrets. Production and shared environment connection strings must be supplied through protected environment configuration.

## Folder Purpose

- `migrations/`: versioned, idempotent schema and data migration scripts.
- `stored-procedures/`: stored procedures used by ADO.NET repositories.
- `functions/`: SQL Server scalar or table-valued functions.
- `seed/`: repeat-safe reference data scripts.

Follow `.claude/rules/database.md` for SQL safety, naming, audit logging, transactions, and soft-delete behavior.
