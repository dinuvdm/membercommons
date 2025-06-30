-- Foreign Key Constraints for SuiteCRM PostgreSQL Schema
-- Based on table_relationships.json
-- Add foreign key constraints to improve data integrity

-- ============================================================================
-- ACCOUNTS TABLE FOREIGN KEYS
-- ============================================================================

-- User-related foreign keys for accounts
ALTER TABLE accounts 
ADD CONSTRAINT fk_accounts_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE accounts 
ADD CONSTRAINT fk_accounts_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE accounts 
ADD CONSTRAINT fk_accounts_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

-- Self-referencing foreign key for parent accounts
ALTER TABLE accounts 
ADD CONSTRAINT fk_accounts_parent 
FOREIGN KEY (parent_id) REFERENCES accounts(id) ON DELETE SET NULL;

-- Campaign relationship
ALTER TABLE accounts 
ADD CONSTRAINT fk_accounts_campaign 
FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE SET NULL;

-- ============================================================================
-- AUDIT TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE accounts_audit 
ADD CONSTRAINT fk_accounts_audit_parent 
FOREIGN KEY (parent_id) REFERENCES accounts(id) ON DELETE CASCADE;

-- ============================================================================
-- RELATIONSHIP/JUNCTION TABLE FOREIGN KEYS
-- ============================================================================

-- accounts_bugs
ALTER TABLE accounts_bugs 
ADD CONSTRAINT fk_accounts_bugs_account 
FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;

ALTER TABLE accounts_bugs 
ADD CONSTRAINT fk_accounts_bugs_bug 
FOREIGN KEY (bug_id) REFERENCES bugs(id) ON DELETE CASCADE;

-- accounts_cases
ALTER TABLE accounts_cases 
ADD CONSTRAINT fk_accounts_cases_account 
FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;

ALTER TABLE accounts_cases 
ADD CONSTRAINT fk_accounts_cases_case 
FOREIGN KEY (case_id) REFERENCES cases(id) ON DELETE CASCADE;

-- accounts_contacts
ALTER TABLE accounts_contacts 
ADD CONSTRAINT fk_accounts_contacts_account 
FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;

ALTER TABLE accounts_contacts 
ADD CONSTRAINT fk_accounts_contacts_contact 
FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE;

-- accounts_opportunities
ALTER TABLE accounts_opportunities 
ADD CONSTRAINT fk_accounts_opportunities_account 
FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;

ALTER TABLE accounts_opportunities 
ADD CONSTRAINT fk_accounts_opportunities_opportunity 
FOREIGN KEY (opportunity_id) REFERENCES opportunities(id) ON DELETE CASCADE;

-- ============================================================================
-- CUSTOM TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE accounts_cstm 
ADD CONSTRAINT fk_accounts_cstm_parent 
FOREIGN KEY (id_c) REFERENCES accounts(id) ON DELETE CASCADE;

-- ============================================================================
-- ACL (ACCESS CONTROL) TABLE FOREIGN KEYS
-- ============================================================================

-- acl_actions
ALTER TABLE acl_actions 
ADD CONSTRAINT fk_acl_actions_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE acl_actions 
ADD CONSTRAINT fk_acl_actions_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

-- acl_roles
ALTER TABLE acl_roles 
ADD CONSTRAINT fk_acl_roles_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE acl_roles 
ADD CONSTRAINT fk_acl_roles_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

-- acl_roles_actions
ALTER TABLE acl_roles_actions 
ADD CONSTRAINT fk_acl_roles_actions_role 
FOREIGN KEY (role_id) REFERENCES acl_roles(id) ON DELETE CASCADE;

ALTER TABLE acl_roles_actions 
ADD CONSTRAINT fk_acl_roles_actions_action 
FOREIGN KEY (action_id) REFERENCES acl_actions(id) ON DELETE CASCADE;

-- acl_roles_users
ALTER TABLE acl_roles_users 
ADD CONSTRAINT fk_acl_roles_users_role 
FOREIGN KEY (role_id) REFERENCES acl_roles(id) ON DELETE CASCADE;

ALTER TABLE acl_roles_users 
ADD CONSTRAINT fk_acl_roles_users_user 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- ============================================================================
-- ALERTS TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE alerts 
ADD CONSTRAINT fk_alerts_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE alerts 
ADD CONSTRAINT fk_alerts_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE alerts 
ADD CONSTRAINT fk_alerts_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE alerts 
ADD CONSTRAINT fk_alerts_reminder 
FOREIGN KEY (reminder_id) REFERENCES reminders(id) ON DELETE CASCADE;

-- ============================================================================
-- CONTACTS TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE contacts 
ADD CONSTRAINT fk_contacts_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE contacts 
ADD CONSTRAINT fk_contacts_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE contacts 
ADD CONSTRAINT fk_contacts_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE contacts 
ADD CONSTRAINT fk_contacts_account 
FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE SET NULL;

ALTER TABLE contacts 
ADD CONSTRAINT fk_contacts_reports_to 
FOREIGN KEY (reports_to_id) REFERENCES contacts(id) ON DELETE SET NULL;

ALTER TABLE contacts 
ADD CONSTRAINT fk_contacts_campaign 
FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE SET NULL;

-- ============================================================================
-- OPPORTUNITIES TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE opportunities 
ADD CONSTRAINT fk_opportunities_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE opportunities 
ADD CONSTRAINT fk_opportunities_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE opportunities 
ADD CONSTRAINT fk_opportunities_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE opportunities 
ADD CONSTRAINT fk_opportunities_campaign 
FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE SET NULL;

-- ============================================================================
-- CASES TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE cases 
ADD CONSTRAINT fk_cases_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE cases 
ADD CONSTRAINT fk_cases_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE cases 
ADD CONSTRAINT fk_cases_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

-- ============================================================================
-- LEADS TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE leads 
ADD CONSTRAINT fk_leads_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE leads 
ADD CONSTRAINT fk_leads_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE leads 
ADD CONSTRAINT fk_leads_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE leads 
ADD CONSTRAINT fk_leads_campaign 
FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE SET NULL;

-- ============================================================================
-- CAMPAIGNS TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE campaigns 
ADD CONSTRAINT fk_campaigns_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE campaigns 
ADD CONSTRAINT fk_campaigns_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE campaigns 
ADD CONSTRAINT fk_campaigns_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

-- ============================================================================
-- NOTES TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE notes 
ADD CONSTRAINT fk_notes_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE notes 
ADD CONSTRAINT fk_notes_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE notes 
ADD CONSTRAINT fk_notes_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE notes 
ADD CONSTRAINT fk_notes_contact 
FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE;

-- ============================================================================
-- TASKS TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE tasks 
ADD CONSTRAINT fk_tasks_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE tasks 
ADD CONSTRAINT fk_tasks_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE tasks 
ADD CONSTRAINT fk_tasks_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE tasks 
ADD CONSTRAINT fk_tasks_contact 
FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL;

-- ============================================================================
-- CALLS TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE calls 
ADD CONSTRAINT fk_calls_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE calls 
ADD CONSTRAINT fk_calls_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE calls 
ADD CONSTRAINT fk_calls_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

-- ============================================================================
-- MEETINGS TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE meetings 
ADD CONSTRAINT fk_meetings_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE meetings 
ADD CONSTRAINT fk_meetings_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE meetings 
ADD CONSTRAINT fk_meetings_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

-- ============================================================================
-- EMAILS TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE emails 
ADD CONSTRAINT fk_emails_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE emails 
ADD CONSTRAINT fk_emails_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE emails 
ADD CONSTRAINT fk_emails_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

-- ============================================================================
-- PROJECT-RELATED TABLE FOREIGN KEYS
-- ============================================================================

-- project
ALTER TABLE project 
ADD CONSTRAINT fk_project_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE project 
ADD CONSTRAINT fk_project_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE project 
ADD CONSTRAINT fk_project_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

-- project_task
ALTER TABLE project_task 
ADD CONSTRAINT fk_project_task_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE project_task 
ADD CONSTRAINT fk_project_task_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE project_task 
ADD CONSTRAINT fk_project_task_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE project_task 
ADD CONSTRAINT fk_project_task_project 
FOREIGN KEY (project_id) REFERENCES project(id) ON DELETE CASCADE;

-- ============================================================================
-- DOCUMENT-RELATED TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE documents 
ADD CONSTRAINT fk_documents_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE documents 
ADD CONSTRAINT fk_documents_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE documents 
ADD CONSTRAINT fk_documents_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

-- ============================================================================
-- USER-RELATED TABLE FOREIGN KEYS
-- ============================================================================

-- users_password_link
ALTER TABLE users_password_link 
ADD CONSTRAINT fk_users_password_link_user 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- users_signatures
ALTER TABLE users_signatures 
ADD CONSTRAINT fk_users_signatures_user 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- vcals
ALTER TABLE vcals 
ADD CONSTRAINT fk_vcals_user 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- ============================================================================
-- EMAIL TEMPLATE TABLE FOREIGN KEYS
-- ============================================================================

ALTER TABLE email_templates 
ADD CONSTRAINT fk_email_templates_modified_user 
FOREIGN KEY (modified_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE email_templates 
ADD CONSTRAINT fk_email_templates_created_by 
FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE email_templates 
ADD CONSTRAINT fk_email_templates_assigned_user 
FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL;

-- ============================================================================
-- NOTES FOR IMPLEMENTATION
-- ============================================================================

-- To apply these foreign keys:
-- 1. Run this script against your PostgreSQL database
-- 2. Some constraints might fail if referential integrity is already violated
-- 3. You may need to clean up orphaned records first
-- 4. Consider running in a transaction to allow rollback if needed

-- Example usage:
-- BEGIN;
-- \i add_foreign_keys.sql
-- COMMIT;

-- To check which constraints were created:
-- SELECT constraint_name, table_name, column_name 
-- FROM information_schema.key_column_usage 
-- WHERE constraint_schema = 'public' 
-- ORDER BY table_name, constraint_name;