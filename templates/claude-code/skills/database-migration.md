---
description: Database migration safety patterns. Use when changing database schema.
---

# Database Migration Skill

## Golden Rules

1. **Migrations must be reversible** — always include a rollback/down migration
2. **Backward compatible** — new schema must work with current AND previous code version
3. **No data loss** — never drop columns/tables without confirming data is migrated or backed up
4. **Small steps** — one logical change per migration (add column, then backfill, then add constraint)

## Safe Migration Patterns

### Adding a column
```sql
ALTER TABLE users ADD COLUMN phone VARCHAR(20) NULL;  -- nullable first
-- Deploy code that writes to new column
-- Backfill existing rows
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;  -- then add constraint
```

### Renaming a column (3-step)
```
Step 1: Add new column, write to both
Step 2: Migrate data, read from new column
Step 3: Drop old column (after all code uses new name)
```

### Removing a column (2-step)
```
Step 1: Stop reading from column in code, deploy
Step 2: Drop column in migration
```

## Pre-Migration Checklist

- [ ] Migration has a rollback/down step
- [ ] Tested on a copy of production data (or staging)
- [ ] No data loss (confirmed with SELECT COUNT before/after)
- [ ] Performance impact assessed (large tables may lock during ALTER)
- [ ] Code handles both old and new schema during rollout
