-- Cleanup Script for Orphaned Records
-- Run this BEFORE applying foreign key constraints
-- This will identify and optionally clean up orphaned records

-- ============================================================================
-- ORPHANED RECORD IDENTIFICATION QUERIES
-- ============================================================================

-- Check for orphaned user references in accounts table
SELECT 'accounts with invalid modified_user_id' as issue, count(*) as count
FROM accounts a 
LEFT JOIN users u ON a.modified_user_id = u.id 
WHERE a.modified_user_id IS NOT NULL AND u.id IS NULL;

SELECT 'accounts with invalid created_by' as issue, count(*) as count
FROM accounts a 
LEFT JOIN users u ON a.created_by = u.id 
WHERE a.created_by IS NOT NULL AND u.id IS NULL;

SELECT 'accounts with invalid assigned_user_id' as issue, count(*) as count
FROM accounts a 
LEFT JOIN users u ON a.assigned_user_id = u.id 
WHERE a.assigned_user_id IS NOT NULL AND u.id IS NULL;

-- Check for orphaned parent account references
SELECT 'accounts with invalid parent_id' as issue, count(*) as count
FROM accounts a 
LEFT JOIN accounts p ON a.parent_id = p.id 
WHERE a.parent_id IS NOT NULL AND p.id IS NULL;

-- Check for orphaned campaign references
SELECT 'accounts with invalid campaign_id' as issue, count(*) as count
FROM accounts a 
LEFT JOIN campaigns c ON a.campaign_id = c.id 
WHERE a.campaign_id IS NOT NULL AND c.id IS NULL;

-- Check orphaned records in junction tables
SELECT 'accounts_bugs with invalid account_id' as issue, count(*) as count
FROM accounts_bugs ab 
LEFT JOIN accounts a ON ab.account_id = a.id 
WHERE ab.account_id IS NOT NULL AND a.id IS NULL;

SELECT 'accounts_bugs with invalid bug_id' as issue, count(*) as count
FROM accounts_bugs ab 
LEFT JOIN bugs b ON ab.bug_id = b.id 
WHERE ab.bug_id IS NOT NULL AND b.id IS NULL;

SELECT 'accounts_cases with invalid account_id' as issue, count(*) as count
FROM accounts_cases ac 
LEFT JOIN accounts a ON ac.account_id = a.id 
WHERE ac.account_id IS NOT NULL AND a.id IS NULL;

SELECT 'accounts_cases with invalid case_id' as issue, count(*) as count
FROM accounts_cases ac 
LEFT JOIN cases c ON ac.case_id = c.id 
WHERE ac.case_id IS NOT NULL AND c.id IS NULL;

SELECT 'accounts_contacts with invalid account_id' as issue, count(*) as count
FROM accounts_contacts ac 
LEFT JOIN accounts a ON ac.account_id = a.id 
WHERE ac.account_id IS NOT NULL AND a.id IS NULL;

SELECT 'accounts_contacts with invalid contact_id' as issue, count(*) as count
FROM accounts_contacts ac 
LEFT JOIN contacts c ON ac.contact_id = c.id 
WHERE ac.contact_id IS NOT NULL AND c.id IS NULL;

-- ============================================================================
-- CLEANUP COMMANDS (UNCOMMENT TO EXECUTE)
-- ============================================================================

-- WARNING: These commands will DELETE data. Make sure you have backups!
-- Only uncomment and run these if you want to clean up orphaned records

-- Clean up orphaned user references in accounts
-- UPDATE accounts SET modified_user_id = NULL 
-- WHERE modified_user_id IS NOT NULL 
-- AND modified_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);

-- UPDATE accounts SET created_by = NULL 
-- WHERE created_by IS NOT NULL 
-- AND created_by NOT IN (SELECT id FROM users WHERE id IS NOT NULL);

-- UPDATE accounts SET assigned_user_id = NULL 
-- WHERE assigned_user_id IS NOT NULL 
-- AND assigned_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);

-- Clean up orphaned parent account references
-- UPDATE accounts SET parent_id = NULL 
-- WHERE parent_id IS NOT NULL 
-- AND parent_id NOT IN (SELECT id FROM accounts WHERE id IS NOT NULL);

-- Clean up orphaned campaign references
-- UPDATE accounts SET campaign_id = NULL 
-- WHERE campaign_id IS NOT NULL 
-- AND campaign_id NOT IN (SELECT id FROM campaigns WHERE id IS NOT NULL);

-- Clean up orphaned junction table records
-- DELETE FROM accounts_bugs 
-- WHERE account_id IS NOT NULL 
-- AND account_id NOT IN (SELECT id FROM accounts WHERE id IS NOT NULL);

-- DELETE FROM accounts_bugs 
-- WHERE bug_id IS NOT NULL 
-- AND bug_id NOT IN (SELECT id FROM bugs WHERE id IS NOT NULL);

-- DELETE FROM accounts_cases 
-- WHERE account_id IS NOT NULL 
-- AND account_id NOT IN (SELECT id FROM accounts WHERE id IS NOT NULL);

-- DELETE FROM accounts_cases 
-- WHERE case_id IS NOT NULL 
-- AND case_id NOT IN (SELECT id FROM cases WHERE id IS NOT NULL);

-- DELETE FROM accounts_contacts 
-- WHERE account_id IS NOT NULL 
-- AND account_id NOT IN (SELECT id FROM accounts WHERE id IS NOT NULL);

-- DELETE FROM accounts_contacts 
-- WHERE contact_id IS NOT NULL 
-- AND contact_id NOT IN (SELECT id FROM contacts WHERE id IS NOT NULL);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Run these AFTER cleanup to verify orphaned records are gone

-- Verify no orphaned user references remain
-- SELECT 'accounts with invalid user references after cleanup' as verification,
--        COUNT(*) as remaining_issues
-- FROM accounts a 
-- WHERE (a.modified_user_id IS NOT NULL AND a.modified_user_id NOT IN (SELECT id FROM users))
--    OR (a.created_by IS NOT NULL AND a.created_by NOT IN (SELECT id FROM users))
--    OR (a.assigned_user_id IS NOT NULL AND a.assigned_user_id NOT IN (SELECT id FROM users));

-- ============================================================================
-- COMPLETE CLEANUP SCRIPT FOR ALL MAJOR TABLES
-- ============================================================================

-- This section provides cleanup for other major entity tables
-- Uncomment as needed based on your data integrity requirements

-- CONTACTS cleanup
-- UPDATE contacts SET modified_user_id = NULL WHERE modified_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE contacts SET created_by = NULL WHERE created_by NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE contacts SET assigned_user_id = NULL WHERE assigned_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE contacts SET account_id = NULL WHERE account_id IS NOT NULL AND account_id NOT IN (SELECT id FROM accounts WHERE id IS NOT NULL);
-- UPDATE contacts SET reports_to_id = NULL WHERE reports_to_id IS NOT NULL AND reports_to_id NOT IN (SELECT id FROM contacts WHERE id IS NOT NULL);

-- OPPORTUNITIES cleanup  
-- UPDATE opportunities SET modified_user_id = NULL WHERE modified_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE opportunities SET created_by = NULL WHERE created_by NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE opportunities SET assigned_user_id = NULL WHERE assigned_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);

-- LEADS cleanup
-- UPDATE leads SET modified_user_id = NULL WHERE modified_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE leads SET created_by = NULL WHERE created_by NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE leads SET assigned_user_id = NULL WHERE assigned_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);

-- CASES cleanup
-- UPDATE cases SET modified_user_id = NULL WHERE modified_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE cases SET created_by = NULL WHERE created_by NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE cases SET assigned_user_id = NULL WHERE assigned_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);

-- TASKS cleanup
-- UPDATE tasks SET modified_user_id = NULL WHERE modified_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE tasks SET created_by = NULL WHERE created_by NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE tasks SET assigned_user_id = NULL WHERE assigned_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE tasks SET contact_id = NULL WHERE contact_id IS NOT NULL AND contact_id NOT IN (SELECT id FROM contacts WHERE id IS NOT NULL);

-- PROJECT cleanup
-- UPDATE project SET modified_user_id = NULL WHERE modified_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE project SET created_by = NULL WHERE created_by NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE project SET assigned_user_id = NULL WHERE assigned_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);

-- PROJECT_TASK cleanup
-- UPDATE project_task SET modified_user_id = NULL WHERE modified_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE project_task SET created_by = NULL WHERE created_by NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE project_task SET assigned_user_id = NULL WHERE assigned_user_id NOT IN (SELECT id FROM users WHERE id IS NOT NULL);
-- UPDATE project_task SET project_id = NULL WHERE project_id IS NOT NULL AND project_id NOT IN (SELECT id FROM project WHERE id IS NOT NULL);

-- ============================================================================
-- USAGE INSTRUCTIONS
-- ============================================================================

-- 1. First run the identification queries to see what orphaned data exists
-- 2. Review the counts and decide what to clean up
-- 3. Uncomment and run specific cleanup commands as needed
-- 4. Run verification queries to confirm cleanup
-- 5. After cleanup is complete, run add_foreign_keys.sql

-- Example workflow:
-- psql -d your_database -f cleanup_orphaned_records.sql
-- -- Review results, then uncomment cleanup commands and re-run
-- psql -d your_database -f add_foreign_keys.sql