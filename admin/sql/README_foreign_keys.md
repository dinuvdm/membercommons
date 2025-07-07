# Foreign Key Implementation for SuiteCRM PostgreSQL Schema

This directory contains scripts to add foreign key constraints to the SuiteCRM PostgreSQL database schema, improving data integrity and relationship enforcement.

## Files Overview

- `suitecrm-postgres.sql` - Original schema without foreign keys
- `table_relationships.json` - Relationship definitions extracted from SuiteCRM
- `add_foreign_keys.sql` - Script to add foreign key constraints
- `cleanup_orphaned_records.sql` - Script to identify and clean orphaned data
- `README_foreign_keys.md` - This documentation file

## Why Add Foreign Keys?

The original SuiteCRM schema lacks foreign key constraints, which can lead to:
- **Data integrity issues** - Orphaned records with invalid references
- **Application errors** - Broken relationships causing runtime failures  
- **Performance problems** - Inefficient queries due to missing relationships
- **Maintenance difficulties** - No automatic cleanup of related data

Foreign keys provide:
- ✅ **Referential integrity** - Prevents invalid relationships
- ✅ **Cascading operations** - Automatic cleanup of related records
- ✅ **Query optimization** - Database can use relationships for better execution plans
- ✅ **Documentation** - Schema clearly shows relationships
- ✅ **Data consistency** - Enforces business rules at database level

## Implementation Process

### Step 1: Backup Your Database

```bash
pg_dump -h localhost -U username -d database_name > backup_before_foreign_keys.sql
```

### Step 2: Check for Orphaned Records

```bash
psql -d your_database -f cleanup_orphaned_records.sql
```

This will show counts of orphaned records like:
```
       issue                     | count 
---------------------------------+-------
accounts with invalid created_by |    15
accounts with invalid parent_id  |     3
```

### Step 3: Clean Up Orphaned Data (Optional)

If orphaned records exist, you have two options:

**Option A: Fix the data** - Manually correct invalid references
**Option B: Clean up automatically** - Uncomment cleanup commands in `cleanup_orphaned_records.sql`

```sql
-- Example: Remove invalid user references
UPDATE accounts SET created_by = NULL 
WHERE created_by IS NOT NULL 
AND created_by NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
```

### Step 4: Apply Foreign Keys

```bash
psql -d your_database -f add_foreign_keys.sql
```

### Step 5: Verify Implementation

```sql
-- Check which foreign keys were created
SELECT 
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.constraint_schema = 'public'
ORDER BY tc.table_name, tc.constraint_name;
```

## Foreign Key Patterns Implemented

### 1. User Relationships
Most tables have standard user references:
- `modified_user_id` → `users(id)` - Who last modified the record
- `created_by` → `users(id)` - Who created the record  
- `assigned_user_id` → `users(id)` - Who is assigned to the record

### 2. Parent-Child Relationships
- `accounts.parent_id` → `accounts(id)` - Account hierarchy
- `contacts.reports_to_id` → `contacts(id)` - Contact hierarchy
- `project_task.project_id` → `project(id)` - Tasks belong to projects

### 3. Junction Table Relationships
Many-to-many relationships via junction tables:
- `accounts_contacts` - Links accounts to contacts
- `accounts_bugs` - Links accounts to bugs  
- `accounts_cases` - Links accounts to cases
- `accounts_opportunities` - Links accounts to opportunities

### 4. Campaign Relationships
Marketing campaign tracking:
- `accounts.campaign_id` → `campaigns(id)`
- `contacts.campaign_id` → `campaigns(id)`
- `leads.campaign_id` → `campaigns(id)`

### 5. Custom Table Relationships
Custom field tables link to parent entities:
- `accounts_cstm.id_c` → `accounts(id)`
- Custom tables follow `{table}_cstm` naming pattern

## Cascade Behavior

Foreign keys use appropriate cascade behaviors:

- **SET NULL** for optional references (user assignments, campaigns)
  ```sql
  ON DELETE SET NULL
  ```
  
- **CASCADE** for dependent records (audit logs, junction tables)
  ```sql  
  ON DELETE CASCADE
  ```

## Testing the Implementation

### Test Referential Integrity
```sql
-- This should fail after foreign keys are added
INSERT INTO accounts (id, created_by) 
VALUES (uuid_generate_v4(), 'invalid-user-id');
```

### Test Cascade Deletion
```sql
-- Create test records
INSERT INTO users (id, user_name) VALUES (uuid_generate_v4(), 'test_user');
INSERT INTO accounts (id, name, created_by) VALUES (uuid_generate_v4(), 'Test Account', (SELECT id FROM users WHERE user_name = 'test_user'));

-- Delete user - should cascade appropriately
DELETE FROM users WHERE user_name = 'test_user';
```

## Troubleshooting

### Foreign Key Creation Fails

**Error**: `violates foreign key constraint`
**Solution**: Run cleanup script to fix orphaned records first

**Error**: `column "xyz" referenced in foreign key constraint does not exist`
**Solution**: Verify table structure matches expected schema

### Performance Impact

Foreign keys may initially impact performance:
- **Insert/Update operations** - Slightly slower due to integrity checks
- **Delete operations** - May be slower due to cascade checks
- **Query performance** - Generally improves due to better optimization

Monitor performance and adjust as needed:
```sql
-- Check constraint check time
SELECT schemaname, tablename, attname, inherited, n_distinct, correlation
FROM pg_stats 
WHERE tablename IN ('accounts', 'contacts', 'opportunities')
ORDER BY tablename, attname;
```

## Rollback Plan

To remove foreign keys if needed:
```sql
-- List all foreign key constraints
SELECT constraint_name, table_name 
FROM information_schema.table_constraints 
WHERE constraint_type = 'FOREIGN KEY' 
AND constraint_schema = 'public';

-- Drop specific constraint
ALTER TABLE accounts DROP CONSTRAINT fk_accounts_created_by;

-- Drop all foreign keys (nuclear option)
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT constraint_name, table_name FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY' AND constraint_schema = 'public')
    LOOP
        EXECUTE 'ALTER TABLE ' || r.table_name || ' DROP CONSTRAINT ' || r.constraint_name;
    END LOOP;
END $$;
```

## Best Practices

1. **Always backup** before making schema changes
2. **Test in development** environment first
3. **Monitor performance** after implementation
4. **Document changes** for your team
5. **Plan maintenance windows** for production deployment
6. **Verify data integrity** after implementation

## Support

If you encounter issues:
1. Check PostgreSQL logs for detailed error messages
2. Verify your PostgreSQL version supports used features
3. Review the `table_relationships.json` for relationship definitions
4. Test with a subset of constraints first

Remember: Foreign keys improve data integrity but require careful planning and testing for existing databases with potentially inconsistent data.