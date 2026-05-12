# Release and Deployment Prompt

Use this prompt to prepare, verify, and execute a Tesco Clone release.

## Input

- Release version:
- Source branch:
- Target environment:
- Database migration list:
- Backend build artifact:
- Storefront build artifact:
- Admin build artifact:
- Rollback owner:

## Versioning Strategy

Use semantic versioning:

- MAJOR: breaking API, database, or client contract changes
- MINOR: backwards-compatible features
- PATCH: bug fixes, security fixes, or operational fixes

Tag releases as `vMAJOR.MINOR.PATCH`.

## Changelog Creation

Group changes by:

- Features
- Fixes
- Database changes
- Security changes
- Operational changes
- Breaking changes
- Migration and rollback notes

## Build Steps

Backend:

```text
dotnet restore TescoClone.sln
dotnet build TescoClone.sln -c Release
dotnet test TescoClone.sln -c Release --no-build
dotnet publish src/TescoClone.API -c Release -o ./publish/api --no-build
```

Frontend:

```text
cd frontend/tesco-storefront
npm ci
npm run build:prod

cd ../tesco-admin
npm ci
npm run build:prod
```

## Testing Requirements Before Release

- Backend unit tests pass.
- Backend integration tests pass.
- API smoke tests pass.
- Angular storefront tests pass.
- Angular admin tests pass.
- Database migrations apply cleanly in order.
- Rollback scripts are reviewed and ready.
- Security checks pass: no secrets, unsafe CORS, dynamic SQL, or missing auth.
- `/health` returns healthy in the release candidate environment.

## Rollback Plan

Prepare:

- Previous API artifact.
- Previous frontend artifacts.
- Database rollback scripts for all release migrations.
- Backup or snapshot before schema changes.
- Owner and communication channel.

Rollback steps:

1. Stop traffic or switch traffic away from the release.
2. Restore previous API artifact.
3. Restore previous storefront and admin artifacts.
4. Execute database rollback only if required and approved.
5. Verify `/health`.
6. Smoke test login, search, cart, checkout, and admin login.
7. Monitor logs for 30 minutes.

## Production Release Checklist

- `[ ]` Release branch created from `develop`.
- `[ ]` Version numbers updated.
- `[ ]` CHANGELOG updated.
- `[ ]` Database scripts reviewed by senior engineer.
- `[ ]` Rollback scripts reviewed.
- `[ ]` All tests passed.
- `[ ]` Security scan passed.
- `[ ]` Release PR approved.
- `[ ]` Release tag created.
- `[ ]` Environment variables configured.
- `[ ]` Database backup completed.
- `[ ]` API deployed.
- `[ ]` Storefront deployed.
- `[ ]` Admin app deployed.

## Post-Deployment Verification

- `[ ]` `/health` returns 200.
- `[ ]` Swagger loads in non-production environments.
- `[ ]` Customer login works.
- `[ ]` Product search works.
- `[ ]` Product detail loads.
- `[ ]` Cart add/update/remove works.
- `[ ]` Checkout creates an order.
- `[ ]` Delivery slot booking works.
- `[ ]` Clubcard data loads.
- `[ ]` Admin login works.
- `[ ]` `t.tblLog` has no new Error or Critical entries.
- `[ ]` Monitoring and alerts are healthy.
