-- PostgreSQL conversion of CRM database schema
-- Converted from MySQL/MariaDB to PostgreSQL
-- All DROP TABLE statements removed
-- Changed to CREATE TABLE IF NOT EXISTS

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--
-- Table structure for table `accounts`
--

CREATE TABLE IF NOT EXISTS accounts (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(150) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  account_type VARCHAR(50) DEFAULT NULL,
  industry VARCHAR(50) DEFAULT NULL,
  annual_revenue VARCHAR(100) DEFAULT NULL,
  phone_fax VARCHAR(100) DEFAULT NULL,
  billing_address_street VARCHAR(150) DEFAULT NULL,
  billing_address_city VARCHAR(100) DEFAULT NULL,
  billing_address_state VARCHAR(100) DEFAULT NULL,
  billing_address_postalcode VARCHAR(20) DEFAULT NULL,
  billing_address_country VARCHAR(255) DEFAULT NULL,
  rating VARCHAR(100) DEFAULT NULL,
  phone_office VARCHAR(100) DEFAULT NULL,
  phone_alternate VARCHAR(100) DEFAULT NULL,
  website VARCHAR(255) DEFAULT NULL,
  ownership VARCHAR(100) DEFAULT NULL,
  employees VARCHAR(10) DEFAULT NULL,
  ticker_symbol VARCHAR(10) DEFAULT NULL,
  shipping_address_street VARCHAR(150) DEFAULT NULL,
  shipping_address_city VARCHAR(100) DEFAULT NULL,
  shipping_address_state VARCHAR(100) DEFAULT NULL,
  shipping_address_postalcode VARCHAR(20) DEFAULT NULL,
  shipping_address_country VARCHAR(255) DEFAULT NULL,
  parent_id UUID DEFAULT NULL,
  sic_code VARCHAR(10) DEFAULT NULL,
  campaign_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_accnt_id_del ON accounts (id, deleted);
CREATE INDEX IF NOT EXISTS idx_accnt_name_del ON accounts (name, deleted);
CREATE INDEX IF NOT EXISTS idx_accnt_assigned_del ON accounts (deleted, assigned_user_id);
CREATE INDEX IF NOT EXISTS idx_accnt_parent_id ON accounts (parent_id);

--
-- Table structure for table `accounts_audit`
--

CREATE TABLE IF NOT EXISTS accounts_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_accounts_parent_id ON accounts_audit (parent_id);

--
-- Table structure for table `accounts_bugs`
--

CREATE TABLE IF NOT EXISTS accounts_bugs (
  id VARCHAR(36) NOT NULL,
  account_id VARCHAR(36) DEFAULT NULL,
  bug_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_acc_bug_acc ON accounts_bugs (account_id);
CREATE INDEX IF NOT EXISTS idx_acc_bug_bug ON accounts_bugs (bug_id);
CREATE INDEX IF NOT EXISTS idx_account_bug ON accounts_bugs (account_id, bug_id);

--
-- Table structure for table `accounts_cases`
--

CREATE TABLE IF NOT EXISTS accounts_cases (
  id VARCHAR(36) NOT NULL,
  account_id VARCHAR(36) DEFAULT NULL,
  case_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_acc_case_acc ON accounts_cases (account_id);
CREATE INDEX IF NOT EXISTS idx_acc_acc_case ON accounts_cases (case_id);

--
-- Table structure for table `accounts_contacts`
--

CREATE TABLE IF NOT EXISTS accounts_contacts (
  id VARCHAR(36) NOT NULL,
  contact_id VARCHAR(36) DEFAULT NULL,
  account_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_account_contact ON accounts_contacts (account_id, contact_id);
CREATE INDEX IF NOT EXISTS idx_contid_del_accid ON accounts_contacts (contact_id, deleted, account_id);

--
-- Table structure for table `accounts_cstm`
--

CREATE TABLE IF NOT EXISTS accounts_cstm (
  id_c UUID NOT NULL,
  jjwg_maps_lng_c REAL DEFAULT 0.00000000,
  jjwg_maps_lat_c REAL DEFAULT 0.00000000,
  jjwg_maps_geocode_status_c VARCHAR(255) DEFAULT NULL,
  jjwg_maps_address_c VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id_c)
);

--
-- Table structure for table `accounts_opportunities`
--

CREATE TABLE IF NOT EXISTS accounts_opportunities (
  id VARCHAR(36) NOT NULL,
  opportunity_id VARCHAR(36) DEFAULT NULL,
  account_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_account_opportunity ON accounts_opportunities (account_id, opportunity_id);
CREATE INDEX IF NOT EXISTS idx_oppid_del_accid ON accounts_opportunities (opportunity_id, deleted, account_id);

--
-- Table structure for table `acl_actions`
--

CREATE TABLE IF NOT EXISTS acl_actions (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  name VARCHAR(150) DEFAULT NULL,
  category VARCHAR(100) DEFAULT NULL,
  acltype VARCHAR(100) DEFAULT NULL,
  aclaccess INTEGER DEFAULT NULL,
  deleted BOOLEAN DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aclaction_id_del ON acl_actions (id, deleted);
CREATE INDEX IF NOT EXISTS idx_category_name ON acl_actions (category, name);

--
-- Table structure for table `acl_roles`
--

CREATE TABLE IF NOT EXISTS acl_roles (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  name VARCHAR(150) DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aclrole_id_del ON acl_roles (id, deleted);

--
-- Table structure for table `acl_roles_actions`
--

CREATE TABLE IF NOT EXISTS acl_roles_actions (
  id VARCHAR(36) NOT NULL,
  role_id VARCHAR(36) DEFAULT NULL,
  action_id VARCHAR(36) DEFAULT NULL,
  access_override INTEGER DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_acl_role_id ON acl_roles_actions (role_id);
CREATE INDEX IF NOT EXISTS idx_acl_action_id ON acl_roles_actions (action_id);
CREATE INDEX IF NOT EXISTS idx_aclrole_action ON acl_roles_actions (role_id, action_id);

--
-- Table structure for table `acl_roles_users`
--

CREATE TABLE IF NOT EXISTS acl_roles_users (
  id VARCHAR(36) NOT NULL,
  role_id VARCHAR(36) DEFAULT NULL,
  user_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aclrole_id ON acl_roles_users (role_id);
CREATE INDEX IF NOT EXISTS idx_acluser_id ON acl_roles_users (user_id);
CREATE INDEX IF NOT EXISTS idx_aclrole_user ON acl_roles_users (role_id, user_id);

--
-- Table structure for table `address_book`
--

CREATE TABLE IF NOT EXISTS address_book (
  assigned_user_id UUID NOT NULL,
  bean VARCHAR(50) DEFAULT NULL,
  bean_id UUID NOT NULL
);

CREATE INDEX IF NOT EXISTS ab_user_bean_idx ON address_book (assigned_user_id, bean);

--
-- Table structure for table `alerts`
--

CREATE TABLE IF NOT EXISTS alerts (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  is_read BOOLEAN DEFAULT NULL,
  target_module VARCHAR(255) DEFAULT NULL,
  type VARCHAR(255) DEFAULT NULL,
  url_redirect VARCHAR(255) DEFAULT NULL,
  reminder_id UUID DEFAULT NULL,
  snooze TIMESTAMP DEFAULT NULL,
  date_start TIMESTAMP DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `am_projecttemplates`
--

CREATE TABLE IF NOT EXISTS am_projecttemplates (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  status VARCHAR(100) DEFAULT 'Draft',
  priority VARCHAR(100) DEFAULT 'High',
  override_business_hours BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

--
-- Table structure for table `am_projecttemplates_audit`
--

CREATE TABLE IF NOT EXISTS am_projecttemplates_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_am_projecttemplates_parent_id ON am_projecttemplates_audit (parent_id);

--
-- Table structure for table `am_projecttemplates_contacts_1_c`
--

CREATE TABLE IF NOT EXISTS am_projecttemplates_contacts_1_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  am_projecttemplates_ida VARCHAR(36) DEFAULT NULL,
  contacts_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS am_projecttemplates_contacts_1_alt ON am_projecttemplates_contacts_1_c (am_projecttemplates_ida, contacts_idb);

--
-- Table structure for table `am_projecttemplates_project_1_c`
--

CREATE TABLE IF NOT EXISTS am_projecttemplates_project_1_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  am_projecttemplates_project_1am_projecttemplates_ida VARCHAR(36) DEFAULT NULL,
  am_projecttemplates_project_1project_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS am_projecttemplates_project_1_ida1 ON am_projecttemplates_project_1_c (am_projecttemplates_project_1am_projecttemplates_ida);
CREATE INDEX IF NOT EXISTS am_projecttemplates_project_1_alt ON am_projecttemplates_project_1_c (am_projecttemplates_project_1project_idb);

--
-- Table structure for table `am_projecttemplates_users_1_c`
--

CREATE TABLE IF NOT EXISTS am_projecttemplates_users_1_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  am_projecttemplates_ida VARCHAR(36) DEFAULT NULL,
  users_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS am_projecttemplates_users_1_alt ON am_projecttemplates_users_1_c (am_projecttemplates_ida, users_idb);

--
-- Table structure for table `am_tasktemplates`
--

CREATE TABLE IF NOT EXISTS am_tasktemplates (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  status VARCHAR(100) DEFAULT 'Not Started',
  priority VARCHAR(100) DEFAULT 'High',
  percent_complete INTEGER DEFAULT 0,
  predecessors INTEGER DEFAULT NULL,
  milestone_flag BOOLEAN DEFAULT FALSE,
  relationship_type VARCHAR(100) DEFAULT 'FS',
  task_number INTEGER DEFAULT NULL,
  order_number INTEGER DEFAULT NULL,
  estimated_effort INTEGER DEFAULT NULL,
  utilization VARCHAR(100) DEFAULT '0',
  duration INTEGER DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `am_tasktemplates_am_projecttemplates_c`
--

CREATE TABLE IF NOT EXISTS am_tasktemplates_am_projecttemplates_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  am_tasktemplates_am_projecttemplatesam_projecttemplates_ida VARCHAR(36) DEFAULT NULL,
  am_tasktemplates_am_projecttemplatesam_tasktemplates_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS am_tasktemplates_am_projecttemplates_ida1 ON am_tasktemplates_am_projecttemplates_c (am_tasktemplates_am_projecttemplatesam_projecttemplates_ida);
CREATE INDEX IF NOT EXISTS am_tasktemplates_am_projecttemplates_alt ON am_tasktemplates_am_projecttemplates_c (am_tasktemplates_am_projecttemplatesam_tasktemplates_idb);

--
-- Table structure for table `am_tasktemplates_audit`
--

CREATE TABLE IF NOT EXISTS am_tasktemplates_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_am_tasktemplates_parent_id ON am_tasktemplates_audit (parent_id);

--
-- Table structure for table `aobh_businesshours`
--

CREATE TABLE IF NOT EXISTS aobh_businesshours (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  opening_hours VARCHAR(100) DEFAULT '1',
  closing_hours VARCHAR(100) DEFAULT '1',
  open_status BOOLEAN DEFAULT NULL,
  day VARCHAR(100) DEFAULT 'monday',
  PRIMARY KEY (id)
);

--
-- Table structure for table `aok_knowledge_base_categories`
--

CREATE TABLE IF NOT EXISTS aok_knowledge_base_categories (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aok_knowledge_base_categories_audit`
--

CREATE TABLE IF NOT EXISTS aok_knowledge_base_categories_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aok_knowledge_base_categories_parent_id ON aok_knowledge_base_categories_audit (parent_id);

--
-- Table structure for table `aok_knowledgebase`
--

CREATE TABLE IF NOT EXISTS aok_knowledgebase (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  status VARCHAR(100) DEFAULT 'Draft',
  revision VARCHAR(255) DEFAULT NULL,
  additional_info TEXT DEFAULT NULL,
  user_id_c UUID DEFAULT NULL,
  user_id1_c UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aok_knowledgebase_audit`
--

CREATE TABLE IF NOT EXISTS aok_knowledgebase_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aok_knowledgebase_parent_id ON aok_knowledgebase_audit (parent_id);

--
-- Table structure for table `aok_knowledgebase_categories`
--

CREATE TABLE IF NOT EXISTS aok_knowledgebase_categories (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  aok_knowledgebase_id VARCHAR(36) DEFAULT NULL,
  aok_knowledge_base_categories_id VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS aok_knowledgebase_categories_alt ON aok_knowledgebase_categories (aok_knowledgebase_id, aok_knowledge_base_categories_id);

--
-- Table structure for table `aop_case_events`
--

CREATE TABLE IF NOT EXISTS aop_case_events (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  case_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aop_case_events_audit`
--

CREATE TABLE IF NOT EXISTS aop_case_events_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aop_case_events_parent_id ON aop_case_events_audit (parent_id);

--
-- Table structure for table `aop_case_updates`
--

CREATE TABLE IF NOT EXISTS aop_case_updates (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  case_id UUID DEFAULT NULL,
  contact_id UUID DEFAULT NULL,
  internal BOOLEAN DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aop_case_updates_audit`
--

CREATE TABLE IF NOT EXISTS aop_case_updates_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aop_case_updates_parent_id ON aop_case_updates_audit (parent_id);

--
-- Table structure for table `aor_charts`
--

CREATE TABLE IF NOT EXISTS aor_charts (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  aor_report_id UUID DEFAULT NULL,
  type VARCHAR(100) DEFAULT NULL,
  x_field INTEGER DEFAULT NULL,
  y_field INTEGER DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aor_conditions`
--

CREATE TABLE IF NOT EXISTS aor_conditions (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  aor_report_id UUID DEFAULT NULL,
  condition_order INTEGER DEFAULT NULL,
  logic_op VARCHAR(255) DEFAULT NULL,
  parenthesis VARCHAR(255) DEFAULT NULL,
  module_path TEXT DEFAULT NULL,
  field VARCHAR(100) DEFAULT NULL,
  operator VARCHAR(100) DEFAULT NULL,
  value_type VARCHAR(100) DEFAULT NULL,
  value VARCHAR(255) DEFAULT NULL,
  parameter BOOLEAN DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS aor_conditions_index_report_id ON aor_conditions (aor_report_id);

--
-- Table structure for table `aor_fields`
--

CREATE TABLE IF NOT EXISTS aor_fields (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  aor_report_id UUID DEFAULT NULL,
  field_order INTEGER DEFAULT NULL,
  module_path TEXT DEFAULT NULL,
  field VARCHAR(100) DEFAULT NULL,
  display BOOLEAN DEFAULT NULL,
  link BOOLEAN DEFAULT NULL,
  label VARCHAR(255) DEFAULT NULL,
  field_function VARCHAR(100) DEFAULT NULL,
  sort_by VARCHAR(100) DEFAULT NULL,
  format VARCHAR(100) DEFAULT NULL,
  total VARCHAR(100) DEFAULT NULL,
  sort_order VARCHAR(100) DEFAULT NULL,
  group_by BOOLEAN DEFAULT NULL,
  group_order VARCHAR(100) DEFAULT NULL,
  group_display INTEGER DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS aor_fields_index_report_id ON aor_fields (aor_report_id);

--
-- Table structure for table `aor_reports`
--

CREATE TABLE IF NOT EXISTS aor_reports (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  report_module VARCHAR(100) DEFAULT NULL,
  graphs_per_row INTEGER DEFAULT 2,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aor_reports_audit`
--

CREATE TABLE IF NOT EXISTS aor_reports_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aor_reports_parent_id ON aor_reports_audit (parent_id);

--
-- Table structure for table `aor_scheduled_reports`
--

CREATE TABLE IF NOT EXISTS aor_scheduled_reports (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  schedule VARCHAR(100) DEFAULT NULL,
  last_run TIMESTAMP DEFAULT NULL,
  status VARCHAR(100) DEFAULT NULL,
  email_recipients TEXT DEFAULT NULL,
  aor_report_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aos_contracts`
--

CREATE TABLE IF NOT EXISTS aos_contracts (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  reference_code VARCHAR(255) DEFAULT NULL,
  start_date DATE DEFAULT NULL,
  end_date DATE DEFAULT NULL,
  total_contract_value NUMERIC(26,6) DEFAULT NULL,
  total_contract_value_usdollar NUMERIC(26,6) DEFAULT NULL,
  currency_id UUID DEFAULT NULL,
  status VARCHAR(100) DEFAULT 'Not Started',
  customer_signed_date DATE DEFAULT NULL,
  company_signed_date DATE DEFAULT NULL,
  renewal_reminder_date TIMESTAMP DEFAULT NULL,
  contract_type VARCHAR(100) DEFAULT 'Type',
  contract_account_id UUID DEFAULT NULL,
  opportunity_id UUID DEFAULT NULL,
  contact_id UUID DEFAULT NULL,
  call_id UUID DEFAULT NULL,
  total_amt NUMERIC(26,6) DEFAULT NULL,
  total_amt_usdollar NUMERIC(26,6) DEFAULT NULL,
  subtotal_amount NUMERIC(26,6) DEFAULT NULL,
  subtotal_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  discount_amount NUMERIC(26,6) DEFAULT NULL,
  discount_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  tax_amount NUMERIC(26,6) DEFAULT NULL,
  tax_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  shipping_amount NUMERIC(26,6) DEFAULT NULL,
  shipping_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  shipping_tax VARCHAR(100) DEFAULT NULL,
  shipping_tax_amt NUMERIC(26,6) DEFAULT NULL,
  shipping_tax_amt_usdollar NUMERIC(26,6) DEFAULT NULL,
  total_amount NUMERIC(26,6) DEFAULT NULL,
  total_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aos_contracts_audit`
--

CREATE TABLE IF NOT EXISTS aos_contracts_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aos_contracts_parent_id ON aos_contracts_audit (parent_id);

--
-- Table structure for table `aos_contracts_documents`
--

CREATE TABLE IF NOT EXISTS aos_contracts_documents (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  aos_contracts_id VARCHAR(36) DEFAULT NULL,
  documents_id VARCHAR(36) DEFAULT NULL,
  document_revision_id VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS aos_contracts_documents_alt ON aos_contracts_documents (aos_contracts_id, documents_id);

--
-- Table structure for table `aos_invoices`
--

CREATE TABLE IF NOT EXISTS aos_invoices (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  billing_account_id UUID DEFAULT NULL,
  billing_contact_id UUID DEFAULT NULL,
  billing_address_street VARCHAR(150) DEFAULT NULL,
  billing_address_city VARCHAR(100) DEFAULT NULL,
  billing_address_state VARCHAR(100) DEFAULT NULL,
  billing_address_postalcode VARCHAR(20) DEFAULT NULL,
  billing_address_country VARCHAR(255) DEFAULT NULL,
  shipping_address_street VARCHAR(150) DEFAULT NULL,
  shipping_address_city VARCHAR(100) DEFAULT NULL,
  shipping_address_state VARCHAR(100) DEFAULT NULL,
  shipping_address_postalcode VARCHAR(20) DEFAULT NULL,
  shipping_address_country VARCHAR(255) DEFAULT NULL,
  number INTEGER NOT NULL,
  total_amt NUMERIC(26,6) DEFAULT NULL,
  total_amt_usdollar NUMERIC(26,6) DEFAULT NULL,
  subtotal_amount NUMERIC(26,6) DEFAULT NULL,
  subtotal_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  discount_amount NUMERIC(26,6) DEFAULT NULL,
  discount_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  tax_amount NUMERIC(26,6) DEFAULT NULL,
  tax_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  shipping_amount NUMERIC(26,6) DEFAULT NULL,
  shipping_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  shipping_tax VARCHAR(100) DEFAULT NULL,
  shipping_tax_amt NUMERIC(26,6) DEFAULT NULL,
  shipping_tax_amt_usdollar NUMERIC(26,6) DEFAULT NULL,
  total_amount NUMERIC(26,6) DEFAULT NULL,
  total_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  currency_id UUID DEFAULT NULL,
  quote_number INTEGER DEFAULT NULL,
  quote_date DATE DEFAULT NULL,
  invoice_date DATE DEFAULT NULL,
  due_date DATE DEFAULT NULL,
  status VARCHAR(100) DEFAULT NULL,
  template_ddown_c TEXT DEFAULT NULL,
  subtotal_tax_amount NUMERIC(26,6) DEFAULT NULL,
  subtotal_tax_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aos_invoices_audit`
--

CREATE TABLE IF NOT EXISTS aos_invoices_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aos_invoices_parent_id ON aos_invoices_audit (parent_id);

--
-- Table structure for table `aos_line_item_groups`
--

CREATE TABLE IF NOT EXISTS aos_line_item_groups (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  total_amt NUMERIC(26,6) DEFAULT NULL,
  total_amt_usdollar NUMERIC(26,6) DEFAULT NULL,
  discount_amount NUMERIC(26,6) DEFAULT NULL,
  discount_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  subtotal_amount NUMERIC(26,6) DEFAULT NULL,
  subtotal_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  tax_amount NUMERIC(26,6) DEFAULT NULL,
  tax_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  subtotal_tax_amount NUMERIC(26,6) DEFAULT NULL,
  subtotal_tax_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  total_amount NUMERIC(26,6) DEFAULT NULL,
  total_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  parent_type VARCHAR(100) DEFAULT NULL,
  parent_id UUID DEFAULT NULL,
  number INTEGER DEFAULT NULL,
  currency_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aos_line_item_groups_audit`
--

CREATE TABLE IF NOT EXISTS aos_line_item_groups_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aos_line_item_groups_parent_id ON aos_line_item_groups_audit (parent_id);

--
-- Table structure for table `aos_pdf_templates`
--

CREATE TABLE IF NOT EXISTS aos_pdf_templates (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  active BOOLEAN DEFAULT TRUE,
  type VARCHAR(100) DEFAULT NULL,
  pdfheader TEXT DEFAULT NULL,
  pdffooter TEXT DEFAULT NULL,
  margin_left INTEGER DEFAULT 15,
  margin_right INTEGER DEFAULT 15,
  margin_top INTEGER DEFAULT 16,
  margin_bottom INTEGER DEFAULT 16,
  margin_header INTEGER DEFAULT 9,
  margin_footer INTEGER DEFAULT 9,
  page_size VARCHAR(100) DEFAULT NULL,
  orientation VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aos_pdf_templates_audit`
--

CREATE TABLE IF NOT EXISTS aos_pdf_templates_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aos_pdf_templates_parent_id ON aos_pdf_templates_audit (parent_id);

--
-- Table structure for table `aos_product_categories`
--

CREATE TABLE IF NOT EXISTS aos_product_categories (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  is_parent BOOLEAN DEFAULT FALSE,
  parent_category_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aos_product_categories_audit`
--

CREATE TABLE IF NOT EXISTS aos_product_categories_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aos_product_categories_parent_id ON aos_product_categories_audit (parent_id);

--
-- Table structure for table `aos_products`
--

CREATE TABLE IF NOT EXISTS aos_products (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  maincode VARCHAR(100) DEFAULT 'XXXX',
  part_number VARCHAR(25) DEFAULT NULL,
  category VARCHAR(100) DEFAULT NULL,
  type VARCHAR(100) DEFAULT 'Good',
  cost NUMERIC(26,6) DEFAULT NULL,
  cost_usdollar NUMERIC(26,6) DEFAULT NULL,
  currency_id UUID DEFAULT NULL,
  price NUMERIC(26,6) DEFAULT NULL,
  price_usdollar NUMERIC(26,6) DEFAULT NULL,
  url VARCHAR(255) DEFAULT NULL,
  contact_id UUID DEFAULT NULL,
  product_image VARCHAR(255) DEFAULT NULL,
  aos_product_category_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aos_products_audit`
--

CREATE TABLE IF NOT EXISTS aos_products_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aos_products_parent_id ON aos_products_audit (parent_id);

--
-- Table structure for table `aos_products_quotes`
--

CREATE TABLE IF NOT EXISTS aos_products_quotes (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name TEXT DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  currency_id UUID DEFAULT NULL,
  part_number VARCHAR(255) DEFAULT NULL,
  item_description TEXT DEFAULT NULL,
  number INTEGER DEFAULT NULL,
  product_qty NUMERIC(18,4) DEFAULT NULL,
  product_cost_price NUMERIC(26,6) DEFAULT NULL,
  product_cost_price_usdollar NUMERIC(26,6) DEFAULT NULL,
  product_list_price NUMERIC(26,6) DEFAULT NULL,
  product_list_price_usdollar NUMERIC(26,6) DEFAULT NULL,
  product_discount NUMERIC(26,6) DEFAULT NULL,
  product_discount_usdollar NUMERIC(26,6) DEFAULT NULL,
  product_discount_amount NUMERIC(26,6) DEFAULT NULL,
  product_discount_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  discount VARCHAR(255) DEFAULT 'Percentage',
  product_unit_price NUMERIC(26,6) DEFAULT NULL,
  product_unit_price_usdollar NUMERIC(26,6) DEFAULT NULL,
  vat_amt NUMERIC(26,6) DEFAULT NULL,
  vat_amt_usdollar NUMERIC(26,6) DEFAULT NULL,
  product_total_price NUMERIC(26,6) DEFAULT NULL,
  product_total_price_usdollar NUMERIC(26,6) DEFAULT NULL,
  vat VARCHAR(100) DEFAULT '5.0',
  parent_type VARCHAR(100) DEFAULT NULL,
  parent_id UUID DEFAULT NULL,
  product_id UUID DEFAULT NULL,
  group_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aospq_par_del ON aos_products_quotes (parent_id, parent_type, deleted);

--
-- Table structure for table `aos_products_quotes_audit`
--

CREATE TABLE IF NOT EXISTS aos_products_quotes_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aos_products_quotes_parent_id ON aos_products_quotes_audit (parent_id);

--
-- Table structure for table `aos_quotes`
--

CREATE TABLE IF NOT EXISTS aos_quotes (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  approval_issue TEXT DEFAULT NULL,
  billing_account_id UUID DEFAULT NULL,
  billing_contact_id UUID DEFAULT NULL,
  billing_address_street VARCHAR(150) DEFAULT NULL,
  billing_address_city VARCHAR(100) DEFAULT NULL,
  billing_address_state VARCHAR(100) DEFAULT NULL,
  billing_address_postalcode VARCHAR(20) DEFAULT NULL,
  billing_address_country VARCHAR(255) DEFAULT NULL,
  shipping_address_street VARCHAR(150) DEFAULT NULL,
  shipping_address_city VARCHAR(100) DEFAULT NULL,
  shipping_address_state VARCHAR(100) DEFAULT NULL,
  shipping_address_postalcode VARCHAR(20) DEFAULT NULL,
  shipping_address_country VARCHAR(255) DEFAULT NULL,
  expiration DATE DEFAULT NULL,
  number INTEGER DEFAULT NULL,
  opportunity_id UUID DEFAULT NULL,
  template_ddown_c TEXT DEFAULT NULL,
  total_amt NUMERIC(26,6) DEFAULT NULL,
  total_amt_usdollar NUMERIC(26,6) DEFAULT NULL,
  subtotal_amount NUMERIC(26,6) DEFAULT NULL,
  subtotal_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  discount_amount NUMERIC(26,6) DEFAULT NULL,
  discount_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  tax_amount NUMERIC(26,6) DEFAULT NULL,
  tax_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  shipping_amount NUMERIC(26,6) DEFAULT NULL,
  shipping_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  shipping_tax VARCHAR(100) DEFAULT NULL,
  shipping_tax_amt NUMERIC(26,6) DEFAULT NULL,
  shipping_tax_amt_usdollar NUMERIC(26,6) DEFAULT NULL,
  total_amount NUMERIC(26,6) DEFAULT NULL,
  total_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  currency_id UUID DEFAULT NULL,
  stage VARCHAR(100) DEFAULT 'Draft',
  term VARCHAR(100) DEFAULT NULL,
  terms_c TEXT DEFAULT NULL,
  approval_status VARCHAR(100) DEFAULT NULL,
  invoice_status VARCHAR(100) DEFAULT 'Not Invoiced',
  subtotal_tax_amount NUMERIC(26,6) DEFAULT NULL,
  subtotal_tax_amount_usdollar NUMERIC(26,6) DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `aos_quotes_aos_invoices_c`
--

CREATE TABLE IF NOT EXISTS aos_quotes_aos_invoices_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  aos_quotes77d9_quotes_ida VARCHAR(36) DEFAULT NULL,
  aos_quotes6b83nvoices_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS aos_quotes_aos_invoices_alt ON aos_quotes_aos_invoices_c (aos_quotes77d9_quotes_ida, aos_quotes6b83nvoices_idb);

--
-- Table structure for table `aos_quotes_audit`
--

CREATE TABLE IF NOT EXISTS aos_quotes_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aos_quotes_parent_id ON aos_quotes_audit (parent_id);

--
-- Table structure for table `aos_quotes_os_contracts_c`
--

CREATE TABLE IF NOT EXISTS aos_quotes_os_contracts_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  aos_quotese81e_quotes_ida VARCHAR(36) DEFAULT NULL,
  aos_quotes4dc0ntracts_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS aos_quotes_aos_contracts_alt ON aos_quotes_os_contracts_c (aos_quotese81e_quotes_ida, aos_quotes4dc0ntracts_idb);

--
-- Table structure for table `aos_quotes_project_c`
--

CREATE TABLE IF NOT EXISTS aos_quotes_project_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  aos_quotes1112_quotes_ida VARCHAR(36) DEFAULT NULL,
  aos_quotes7207project_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS aos_quotes_project_alt ON aos_quotes_project_c (aos_quotes1112_quotes_ida, aos_quotes7207project_idb);

--
-- Table structure for table `aow_actions`
--

CREATE TABLE IF NOT EXISTS aow_actions (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  aow_workflow_id UUID DEFAULT NULL,
  action_order INTEGER DEFAULT NULL,
  action VARCHAR(100) DEFAULT NULL,
  parameters TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS aow_action_index_workflow_id ON aow_actions (aow_workflow_id);

--
-- Table structure for table `aow_conditions`
--

CREATE TABLE IF NOT EXISTS aow_conditions (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  aow_workflow_id UUID DEFAULT NULL,
  condition_order INTEGER DEFAULT NULL,
  module_path TEXT DEFAULT NULL,
  field VARCHAR(100) DEFAULT NULL,
  operator VARCHAR(100) DEFAULT NULL,
  value_type VARCHAR(255) DEFAULT NULL,
  value VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS aow_conditions_index_workflow_id ON aow_conditions (aow_workflow_id);

--
-- Table structure for table `aow_processed`
--

CREATE TABLE IF NOT EXISTS aow_processed (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  aow_workflow_id UUID DEFAULT NULL,
  parent_id UUID DEFAULT NULL,
  parent_type VARCHAR(100) DEFAULT NULL,
  status VARCHAR(100) DEFAULT 'Pending',
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS aow_processed_index_workflow ON aow_processed (aow_workflow_id, status, parent_id, deleted);
CREATE INDEX IF NOT EXISTS aow_processed_index_status ON aow_processed (status);
CREATE INDEX IF NOT EXISTS aow_processed_index_workflow_id ON aow_processed (aow_workflow_id);

--
-- Table structure for table `aow_processed_aow_actions`
--

CREATE TABLE IF NOT EXISTS aow_processed_aow_actions (
  id VARCHAR(36) NOT NULL,
  aow_processed_id VARCHAR(36) DEFAULT NULL,
  aow_action_id VARCHAR(36) DEFAULT NULL,
  status VARCHAR(36) DEFAULT 'Pending',
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aow_processed_aow_actions ON aow_processed_aow_actions (aow_processed_id, aow_action_id);
CREATE INDEX IF NOT EXISTS idx_actid_del_freid ON aow_processed_aow_actions (aow_action_id, deleted, aow_processed_id);

--
-- Table structure for table `aow_workflow`
--

CREATE TABLE IF NOT EXISTS aow_workflow (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  flow_module VARCHAR(100) DEFAULT NULL,
  flow_run_on VARCHAR(100) DEFAULT '0',
  status VARCHAR(100) DEFAULT 'Active',
  run_when VARCHAR(100) DEFAULT 'Always',
  multiple_runs BOOLEAN DEFAULT FALSE,
  run_on_import BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS aow_workflow_index_status ON aow_workflow (status);

--
-- Table structure for table `aow_workflow_audit`
--

CREATE TABLE IF NOT EXISTS aow_workflow_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_aow_workflow_parent_id ON aow_workflow_audit (parent_id);

--
-- Table structure for table `bugs`
--

CREATE TABLE IF NOT EXISTS bugs (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  bug_number SERIAL,
  type VARCHAR(255) DEFAULT NULL,
  status VARCHAR(100) DEFAULT NULL,
  priority VARCHAR(100) DEFAULT NULL,
  resolution VARCHAR(255) DEFAULT NULL,
  work_log TEXT DEFAULT NULL,
  found_in_release VARCHAR(255) DEFAULT NULL,
  fixed_in_release VARCHAR(255) DEFAULT NULL,
  source VARCHAR(255) DEFAULT NULL,
  product_category VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE (bug_number)
);

CREATE INDEX IF NOT EXISTS bug_number_idx ON bugs (bug_number);
CREATE INDEX IF NOT EXISTS idx_bug_name ON bugs (name);
CREATE INDEX IF NOT EXISTS idx_bugs_assigned_user ON bugs (assigned_user_id);

--
-- Table structure for table `bugs_audit`
--

CREATE TABLE IF NOT EXISTS bugs_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_bugs_parent_id ON bugs_audit (parent_id);

--
-- Table structure for table `cache_rebuild`
--

CREATE TABLE IF NOT EXISTS cache_rebuild (
  cache_key VARCHAR(255) DEFAULT NULL,
  rebuild BOOLEAN DEFAULT NULL
);

--
-- Table structure for table `calls`
--

CREATE TABLE IF NOT EXISTS calls (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(50) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  duration_hours INTEGER DEFAULT NULL,
  duration_minutes INTEGER DEFAULT NULL,
  date_start TIMESTAMP DEFAULT NULL,
  date_end TIMESTAMP DEFAULT NULL,
  parent_type VARCHAR(255) DEFAULT NULL,
  status VARCHAR(100) DEFAULT 'Planned',
  direction VARCHAR(100) DEFAULT NULL,
  parent_id UUID DEFAULT NULL,
  reminder_time INTEGER DEFAULT -1,
  email_reminder_time INTEGER DEFAULT -1,
  email_reminder_sent BOOLEAN DEFAULT FALSE,
  outlook_id VARCHAR(255) DEFAULT NULL,
  repeat_type VARCHAR(36) DEFAULT NULL,
  repeat_interval INTEGER DEFAULT 1,
  repeat_dow VARCHAR(7) DEFAULT NULL,
  repeat_until DATE DEFAULT NULL,
  repeat_count INTEGER DEFAULT NULL,
  repeat_parent_id UUID DEFAULT NULL,
  recurring_source VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_call_name ON calls (name);
CREATE INDEX IF NOT EXISTS idx_status ON calls (status);
CREATE INDEX IF NOT EXISTS idx_calls_date_start ON calls (date_start);
CREATE INDEX IF NOT EXISTS idx_calls_par_del ON calls (parent_id, parent_type, deleted);
CREATE INDEX IF NOT EXISTS idx_calls_assigned_del ON calls (deleted, assigned_user_id);

--
-- Table structure for table `calls_contacts`
--

CREATE TABLE IF NOT EXISTS calls_contacts (
  id VARCHAR(36) NOT NULL,
  call_id VARCHAR(36) DEFAULT NULL,
  contact_id VARCHAR(36) DEFAULT NULL,
  required VARCHAR(1) DEFAULT '1',
  accept_status VARCHAR(25) DEFAULT 'none',
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_con_call_call ON calls_contacts (call_id);
CREATE INDEX IF NOT EXISTS idx_con_call_con ON calls_contacts (contact_id);
CREATE INDEX IF NOT EXISTS idx_call_contact ON calls_contacts (call_id, contact_id);

--
-- Table structure for table `calls_leads`
--

CREATE TABLE IF NOT EXISTS calls_leads (
  id VARCHAR(36) NOT NULL,
  call_id VARCHAR(36) DEFAULT NULL,
  lead_id VARCHAR(36) DEFAULT NULL,
  required VARCHAR(1) DEFAULT '1',
  accept_status VARCHAR(25) DEFAULT 'none',
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_lead_call_call ON calls_leads (call_id);
CREATE INDEX IF NOT EXISTS idx_lead_call_lead ON calls_leads (lead_id);
CREATE INDEX IF NOT EXISTS idx_call_lead ON calls_leads (call_id, lead_id);

--
-- Table structure for table `calls_reschedule`
--

CREATE TABLE IF NOT EXISTS calls_reschedule (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  reason VARCHAR(100) DEFAULT NULL,
  call_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `calls_reschedule_audit`
--

CREATE TABLE IF NOT EXISTS calls_reschedule_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_calls_reschedule_parent_id ON calls_reschedule_audit (parent_id);

--
-- Table structure for table `calls_users`
--

CREATE TABLE IF NOT EXISTS calls_users (
  id VARCHAR(36) NOT NULL,
  call_id VARCHAR(36) DEFAULT NULL,
  user_id VARCHAR(36) DEFAULT NULL,
  required VARCHAR(1) DEFAULT '1',
  accept_status VARCHAR(25) DEFAULT 'none',
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_usr_call_call ON calls_users (call_id);
CREATE INDEX IF NOT EXISTS idx_usr_call_usr ON calls_users (user_id);
CREATE INDEX IF NOT EXISTS idx_call_users ON calls_users (call_id, user_id);

--
-- Table structure for table `campaign_log`
--

CREATE TABLE IF NOT EXISTS campaign_log (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  campaign_id UUID DEFAULT NULL,
  target_tracker_key VARCHAR(36) DEFAULT NULL,
  target_id VARCHAR(36) DEFAULT NULL,
  target_type VARCHAR(100) DEFAULT NULL,
  activity_type VARCHAR(100) DEFAULT NULL,
  activity_date TIMESTAMP DEFAULT NULL,
  related_id VARCHAR(36) DEFAULT NULL,
  related_type VARCHAR(100) DEFAULT NULL,
  archived BOOLEAN DEFAULT FALSE,
  hits INTEGER DEFAULT 0,
  list_id UUID DEFAULT NULL,
  deleted BOOLEAN DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  more_information VARCHAR(100) DEFAULT NULL,
  marketing_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_camp_tracker ON campaign_log (target_tracker_key);
CREATE INDEX IF NOT EXISTS idx_camp_campaign_id ON campaign_log (campaign_id);
CREATE INDEX IF NOT EXISTS idx_camp_more_info ON campaign_log (more_information);
CREATE INDEX IF NOT EXISTS idx_target_id ON campaign_log (target_id);
CREATE INDEX IF NOT EXISTS idx_target_id_deleted ON campaign_log (target_id, deleted);

--
-- Table structure for table `campaign_trkrs`
--

CREATE TABLE IF NOT EXISTS campaign_trkrs (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  tracker_name VARCHAR(255) DEFAULT NULL,
  tracker_url VARCHAR(255) DEFAULT 'http://',
  tracker_key SERIAL,
  campaign_id UUID DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  is_optout BOOLEAN DEFAULT FALSE,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS campaign_tracker_key_idx ON campaign_trkrs (tracker_key);

--
-- Table structure for table `campaigns`
--

CREATE TABLE IF NOT EXISTS campaigns (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  tracker_key SERIAL,
  tracker_count INTEGER DEFAULT 0,
  refer_url VARCHAR(255) DEFAULT 'http://',
  tracker_text VARCHAR(255) DEFAULT NULL,
  start_date DATE DEFAULT NULL,
  end_date DATE DEFAULT NULL,
  status VARCHAR(100) DEFAULT NULL,
  impressions INTEGER DEFAULT 0,
  currency_id UUID DEFAULT NULL,
  budget DOUBLE PRECISION DEFAULT NULL,
  expected_cost DOUBLE PRECISION DEFAULT NULL,
  actual_cost DOUBLE PRECISION DEFAULT NULL,
  expected_revenue DOUBLE PRECISION DEFAULT NULL,
  campaign_type VARCHAR(100) DEFAULT NULL,
  objective TEXT DEFAULT NULL,
  content TEXT DEFAULT NULL,
  frequency VARCHAR(100) DEFAULT NULL,
  survey_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS camp_auto_tracker_key ON campaigns (tracker_key);
CREATE INDEX IF NOT EXISTS idx_campaign_name ON campaigns (name);
CREATE INDEX IF NOT EXISTS idx_survey_id ON campaigns (survey_id);

--
-- Table structure for table `campaigns_audit`
--

CREATE TABLE IF NOT EXISTS campaigns_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_campaigns_parent_id ON campaigns_audit (parent_id);

--
-- Table structure for table `cases`
--

CREATE TABLE IF NOT EXISTS cases (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  case_number SERIAL,
  type VARCHAR(255) DEFAULT NULL,
  status VARCHAR(100) DEFAULT NULL,
  priority VARCHAR(100) DEFAULT NULL,
  resolution TEXT DEFAULT NULL,
  work_log TEXT DEFAULT NULL,
  account_id UUID DEFAULT NULL,
  state VARCHAR(100) DEFAULT 'Open',
  contact_created_by_id UUID DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE (case_number)
);

CREATE INDEX IF NOT EXISTS case_number_idx ON cases (case_number);
CREATE INDEX IF NOT EXISTS idx_case_name ON cases (name);
CREATE INDEX IF NOT EXISTS idx_account_id ON cases (account_id);
CREATE INDEX IF NOT EXISTS idx_cases_stat_del ON cases (assigned_user_id, status, deleted);

--
-- Table structure for table `cases_audit`
--

CREATE TABLE IF NOT EXISTS cases_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_cases_parent_id ON cases_audit (parent_id);

--
-- Table structure for table `cases_bugs`
--

CREATE TABLE IF NOT EXISTS cases_bugs (
  id VARCHAR(36) NOT NULL,
  case_id VARCHAR(36) DEFAULT NULL,
  bug_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_cas_bug_cas ON cases_bugs (case_id);
CREATE INDEX IF NOT EXISTS idx_cas_bug_bug ON cases_bugs (bug_id);
CREATE INDEX IF NOT EXISTS idx_case_bug ON cases_bugs (case_id, bug_id);

--
-- Table structure for table `cases_cstm`
--

CREATE TABLE IF NOT EXISTS cases_cstm (
  id_c UUID NOT NULL,
  jjwg_maps_lng_c REAL DEFAULT 0.00000000,
  jjwg_maps_lat_c REAL DEFAULT 0.00000000,
  jjwg_maps_geocode_status_c VARCHAR(255) DEFAULT NULL,
  jjwg_maps_address_c VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id_c)
);

--
-- Table structure for table `config`
--

CREATE TABLE IF NOT EXISTS config (
  category VARCHAR(32) DEFAULT NULL,
  name VARCHAR(32) DEFAULT NULL,
  value TEXT DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_config_cat ON config (category);

--
-- Table structure for table `contacts`
--

CREATE TABLE IF NOT EXISTS contacts (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  salutation VARCHAR(255) DEFAULT NULL,
  first_name VARCHAR(100) DEFAULT NULL,
  last_name VARCHAR(100) DEFAULT NULL,
  title VARCHAR(100) DEFAULT NULL,
  photo VARCHAR(255) DEFAULT NULL,
  department VARCHAR(255) DEFAULT NULL,
  do_not_call BOOLEAN DEFAULT FALSE,
  phone_home VARCHAR(100) DEFAULT NULL,
  phone_mobile VARCHAR(100) DEFAULT NULL,
  phone_work VARCHAR(100) DEFAULT NULL,
  phone_other VARCHAR(100) DEFAULT NULL,
  phone_fax VARCHAR(100) DEFAULT NULL,
  lawful_basis TEXT DEFAULT NULL,
  date_reviewed DATE DEFAULT NULL,
  lawful_basis_source VARCHAR(100) DEFAULT NULL,
  primary_address_street VARCHAR(150) DEFAULT NULL,
  primary_address_city VARCHAR(100) DEFAULT NULL,
  primary_address_state VARCHAR(100) DEFAULT NULL,
  primary_address_postalcode VARCHAR(20) DEFAULT NULL,
  primary_address_country VARCHAR(255) DEFAULT NULL,
  alt_address_street VARCHAR(150) DEFAULT NULL,
  alt_address_city VARCHAR(100) DEFAULT NULL,
  alt_address_state VARCHAR(100) DEFAULT NULL,
  alt_address_postalcode VARCHAR(20) DEFAULT NULL,
  alt_address_country VARCHAR(255) DEFAULT NULL,
  assistant VARCHAR(75) DEFAULT NULL,
  assistant_phone VARCHAR(100) DEFAULT NULL,
  lead_source VARCHAR(255) DEFAULT NULL,
  reports_to_id UUID DEFAULT NULL,
  birthdate DATE DEFAULT NULL,
  campaign_id UUID DEFAULT NULL,
  joomla_account_id VARCHAR(255) DEFAULT NULL,
  portal_account_disabled BOOLEAN DEFAULT NULL,
  portal_user_type VARCHAR(100) DEFAULT 'Single',
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_cont_last_first ON contacts (last_name, first_name, deleted);
CREATE INDEX IF NOT EXISTS idx_contacts_del_last ON contacts (deleted, last_name);
CREATE INDEX IF NOT EXISTS idx_cont_del_reports ON contacts (deleted, reports_to_id, last_name);
CREATE INDEX IF NOT EXISTS idx_reports_to_id ON contacts (reports_to_id);
CREATE INDEX IF NOT EXISTS idx_del_id_user ON contacts (deleted, id, assigned_user_id);
CREATE INDEX IF NOT EXISTS idx_cont_assigned ON contacts (assigned_user_id);

--
-- Table structure for table `contacts_audit`
--

CREATE TABLE IF NOT EXISTS contacts_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_contacts_parent_id ON contacts_audit (parent_id);

--
-- Table structure for table `contacts_bugs`
--

CREATE TABLE IF NOT EXISTS contacts_bugs (
  id VARCHAR(36) NOT NULL,
  contact_id VARCHAR(36) DEFAULT NULL,
  bug_id VARCHAR(36) DEFAULT NULL,
  contact_role VARCHAR(50) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_con_bug_con ON contacts_bugs (contact_id);
CREATE INDEX IF NOT EXISTS idx_con_bug_bug ON contacts_bugs (bug_id);
CREATE INDEX IF NOT EXISTS idx_contact_bug ON contacts_bugs (contact_id, bug_id);

--
-- Table structure for table `contacts_cases`
--

CREATE TABLE IF NOT EXISTS contacts_cases (
  id VARCHAR(36) NOT NULL,
  contact_id VARCHAR(36) DEFAULT NULL,
  case_id VARCHAR(36) DEFAULT NULL,
  contact_role VARCHAR(50) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_con_case_con ON contacts_cases (contact_id);
CREATE INDEX IF NOT EXISTS idx_con_case_case ON contacts_cases (case_id);
CREATE INDEX IF NOT EXISTS idx_contacts_cases ON contacts_cases (contact_id, case_id);

--
-- Table structure for table `contacts_cstm`
--

CREATE TABLE IF NOT EXISTS contacts_cstm (
  id_c UUID NOT NULL,
  jjwg_maps_lng_c REAL DEFAULT 0.00000000,
  jjwg_maps_lat_c REAL DEFAULT 0.00000000,
  jjwg_maps_geocode_status_c VARCHAR(255) DEFAULT NULL,
  jjwg_maps_address_c VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id_c)
);

--
-- Table structure for table `contacts_users`
--

CREATE TABLE IF NOT EXISTS contacts_users (
  id VARCHAR(36) NOT NULL,
  contact_id VARCHAR(36) DEFAULT NULL,
  user_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_con_users_con ON contacts_users (contact_id);
CREATE INDEX IF NOT EXISTS idx_con_users_user ON contacts_users (user_id);
CREATE INDEX IF NOT EXISTS idx_contacts_users ON contacts_users (contact_id, user_id);

--
-- Table structure for table `cron_remove_documents`
--

CREATE TABLE IF NOT EXISTS cron_remove_documents (
  id VARCHAR(36) NOT NULL,
  bean_id VARCHAR(36) DEFAULT NULL,
  module VARCHAR(25) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_cron_remove_document_bean_id ON cron_remove_documents (bean_id);
CREATE INDEX IF NOT EXISTS idx_cron_remove_document_stamp ON cron_remove_documents (date_modified);

--
-- Table structure for table `currencies`
--

CREATE TABLE IF NOT EXISTS currencies (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(36) DEFAULT NULL,
  symbol VARCHAR(36) DEFAULT NULL,
  iso4217 VARCHAR(3) DEFAULT NULL,
  conversion_rate DOUBLE PRECISION DEFAULT 0,
  status VARCHAR(100) DEFAULT NULL,
  deleted BOOLEAN DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  created_by UUID NOT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_currency_name ON currencies (name, deleted);

--
-- Table structure for table `custom_fields`
--

CREATE TABLE IF NOT EXISTS custom_fields (
  bean_id VARCHAR(36) DEFAULT NULL,
  set_num INTEGER DEFAULT 0,
  field0 VARCHAR(255) DEFAULT NULL,
  field1 VARCHAR(255) DEFAULT NULL,
  field2 VARCHAR(255) DEFAULT NULL,
  field3 VARCHAR(255) DEFAULT NULL,
  field4 VARCHAR(255) DEFAULT NULL,
  field5 VARCHAR(255) DEFAULT NULL,
  field6 VARCHAR(255) DEFAULT NULL,
  field7 VARCHAR(255) DEFAULT NULL,
  field8 VARCHAR(255) DEFAULT NULL,
  field9 VARCHAR(255) DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_beanid_set_num ON custom_fields (bean_id, set_num);

--
-- Table structure for table `document_revisions`
--

CREATE TABLE IF NOT EXISTS document_revisions (
  id VARCHAR(36) NOT NULL,
  change_log VARCHAR(255) DEFAULT NULL,
  document_id VARCHAR(36) DEFAULT NULL,
  doc_id VARCHAR(100) DEFAULT NULL,
  doc_type VARCHAR(100) DEFAULT NULL,
  doc_url VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  filename VARCHAR(255) DEFAULT NULL,
  file_ext VARCHAR(100) DEFAULT NULL,
  file_mime_type VARCHAR(100) DEFAULT NULL,
  revision VARCHAR(100) DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  date_modified TIMESTAMP DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS documentrevision_mimetype ON document_revisions (file_mime_type);

--
-- Table structure for table `documents`
--

CREATE TABLE IF NOT EXISTS documents (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  document_name VARCHAR(255) DEFAULT NULL,
  doc_id VARCHAR(100) DEFAULT NULL,
  doc_type VARCHAR(100) DEFAULT 'Sugar',
  doc_url VARCHAR(255) DEFAULT NULL,
  active_date DATE DEFAULT NULL,
  exp_date DATE DEFAULT NULL,
  category_id VARCHAR(100) DEFAULT NULL,
  subcategory_id VARCHAR(100) DEFAULT NULL,
  status_id VARCHAR(100) DEFAULT NULL,
  document_revision_id VARCHAR(36) DEFAULT NULL,
  related_doc_id UUID DEFAULT NULL,
  related_doc_rev_id UUID DEFAULT NULL,
  is_template BOOLEAN DEFAULT FALSE,
  template_type VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_doc_cat ON documents (category_id, subcategory_id);

--
-- Table structure for table `documents_accounts`
--

CREATE TABLE IF NOT EXISTS documents_accounts (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  document_id VARCHAR(36) DEFAULT NULL,
  account_id VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS documents_accounts_account_id ON documents_accounts (account_id, document_id);
CREATE INDEX IF NOT EXISTS documents_accounts_document_id ON documents_accounts (document_id, account_id);

--
-- Table structure for table `documents_bugs`
--

CREATE TABLE IF NOT EXISTS documents_bugs (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  document_id VARCHAR(36) DEFAULT NULL,
  bug_id VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS documents_bugs_bug_id ON documents_bugs (bug_id, document_id);
CREATE INDEX IF NOT EXISTS documents_bugs_document_id ON documents_bugs (document_id, bug_id);

--
-- Table structure for table `documents_cases`
--

CREATE TABLE IF NOT EXISTS documents_cases (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  document_id VARCHAR(36) DEFAULT NULL,
  case_id VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS documents_cases_case_id ON documents_cases (case_id, document_id);
CREATE INDEX IF NOT EXISTS documents_cases_document_id ON documents_cases (document_id, case_id);

--
-- Table structure for table `documents_contacts`
--

CREATE TABLE IF NOT EXISTS documents_contacts (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  document_id VARCHAR(36) DEFAULT NULL,
  contact_id VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS documents_contacts_contact_id ON documents_contacts (contact_id, document_id);
CREATE INDEX IF NOT EXISTS documents_contacts_document_id ON documents_contacts (document_id, contact_id);

--
-- Table structure for table `documents_opportunities`
--

CREATE TABLE IF NOT EXISTS documents_opportunities (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  document_id VARCHAR(36) DEFAULT NULL,
  opportunity_id VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_docu_opps_oppo_id ON documents_opportunities (opportunity_id, document_id);
CREATE INDEX IF NOT EXISTS idx_docu_oppo_docu_id ON documents_opportunities (document_id, opportunity_id);

--
-- Table structure for table `eapm`
--

CREATE TABLE IF NOT EXISTS eapm (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  password VARCHAR(255) DEFAULT NULL,
  url VARCHAR(255) DEFAULT NULL,
  application VARCHAR(100) DEFAULT 'webex',
  api_data TEXT DEFAULT NULL,
  consumer_key VARCHAR(255) DEFAULT NULL,
  consumer_secret VARCHAR(255) DEFAULT NULL,
  oauth_token VARCHAR(255) DEFAULT NULL,
  oauth_secret VARCHAR(255) DEFAULT NULL,
  validated BOOLEAN DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_app_active ON eapm (assigned_user_id, application, validated);

--
-- Table structure for table `email_addr_bean_rel`
--

CREATE TABLE IF NOT EXISTS email_addr_bean_rel (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  email_address_id UUID NOT NULL,
  bean_id UUID NOT NULL,
  bean_module VARCHAR(100) DEFAULT NULL,
  primary_address BOOLEAN DEFAULT FALSE,
  reply_to_address BOOLEAN DEFAULT FALSE,
  date_created TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_email_address_id ON email_addr_bean_rel (email_address_id);
CREATE INDEX IF NOT EXISTS idx_bean_id ON email_addr_bean_rel (bean_id, bean_module);

--
-- Table structure for table `email_addresses`
--

CREATE TABLE IF NOT EXISTS email_addresses (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  email_address VARCHAR(255) DEFAULT NULL,
  email_address_caps VARCHAR(255) DEFAULT NULL,
  invalid_email BOOLEAN DEFAULT FALSE,
  opt_out BOOLEAN DEFAULT FALSE,
  confirm_opt_in VARCHAR(255) DEFAULT 'not-opt-in',
  confirm_opt_in_date TIMESTAMP DEFAULT NULL,
  confirm_opt_in_sent_date TIMESTAMP DEFAULT NULL,
  confirm_opt_in_fail_date TIMESTAMP DEFAULT NULL,
  confirm_opt_in_token VARCHAR(255) DEFAULT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_ea_caps_opt_out_invalid ON email_addresses (email_address_caps, opt_out, invalid_email);
CREATE INDEX IF NOT EXISTS idx_ea_opt_out_invalid ON email_addresses (email_address, opt_out, invalid_email);

--
-- Table structure for table `email_addresses_audit`
--

CREATE TABLE IF NOT EXISTS email_addresses_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_email_addresses_parent_id ON email_addresses_audit (parent_id);

--
-- Table structure for table `email_cache`
--

CREATE TABLE IF NOT EXISTS email_cache (
  ie_id UUID DEFAULT NULL,
  mbox VARCHAR(60) DEFAULT NULL,
  subject VARCHAR(255) DEFAULT NULL,
  fromaddr VARCHAR(100) DEFAULT NULL,
  toaddr VARCHAR(255) DEFAULT NULL,
  senddate TIMESTAMP DEFAULT NULL,
  message_id VARCHAR(255) DEFAULT NULL,
  mailsize INTEGER DEFAULT NULL,
  imap_uid INTEGER DEFAULT NULL,
  msgno INTEGER DEFAULT NULL,
  recent SMALLINT DEFAULT NULL,
  flagged SMALLINT DEFAULT NULL,
  answered SMALLINT DEFAULT NULL,
  deleted SMALLINT DEFAULT NULL,
  seen SMALLINT DEFAULT NULL,
  draft SMALLINT DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_ie_id ON email_cache (ie_id);
CREATE INDEX IF NOT EXISTS idx_mail_date ON email_cache (ie_id, mbox, senddate);
CREATE INDEX IF NOT EXISTS idx_mail_from ON email_cache (ie_id, mbox, fromaddr);
CREATE INDEX IF NOT EXISTS idx_mail_subj ON email_cache (subject);
CREATE INDEX IF NOT EXISTS idx_mail_to ON email_cache (toaddr);

--
-- Table structure for table `email_marketing`
--

CREATE TABLE IF NOT EXISTS email_marketing (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  deleted BOOLEAN DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  name VARCHAR(255) DEFAULT NULL,
  from_name VARCHAR(100) DEFAULT NULL,
  from_addr VARCHAR(100) DEFAULT NULL,
  reply_to_name VARCHAR(100) DEFAULT NULL,
  reply_to_addr VARCHAR(100) DEFAULT NULL,
  inbound_email_id VARCHAR(36) DEFAULT NULL,
  date_start TIMESTAMP DEFAULT NULL,
  template_id UUID NOT NULL,
  status VARCHAR(100) DEFAULT NULL,
  campaign_id UUID DEFAULT NULL,
  outbound_email_id UUID DEFAULT NULL,
  all_prospect_lists BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_emmkt_name ON email_marketing (name);
CREATE INDEX IF NOT EXISTS idx_emmkit_del ON email_marketing (deleted);

--
-- Table structure for table `email_marketing_prospect_lists`
--

CREATE TABLE IF NOT EXISTS email_marketing_prospect_lists (
  id VARCHAR(36) NOT NULL,
  prospect_list_id VARCHAR(36) DEFAULT NULL,
  email_marketing_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS email_mp_prospects ON email_marketing_prospect_lists (email_marketing_id, prospect_list_id);

--
-- Table structure for table `email_templates`
--

CREATE TABLE IF NOT EXISTS email_templates (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  published VARCHAR(3) DEFAULT NULL,
  name VARCHAR(255) DEFAULT NULL,
  description TEXT DEFAULT NULL,
  subject VARCHAR(255) DEFAULT NULL,
  body TEXT DEFAULT NULL,
  body_html TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT NULL,
  assigned_user_id UUID DEFAULT NULL,
  text_only BOOLEAN DEFAULT NULL,
  type VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_email_template_name ON email_templates (name);

--
-- Table structure for table `emailman`
--

CREATE TABLE IF NOT EXISTS emailman (
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  user_id UUID DEFAULT NULL,
  id SERIAL,
  campaign_id UUID DEFAULT NULL,
  marketing_id UUID DEFAULT NULL,
  list_id UUID DEFAULT NULL,
  send_date_time TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  in_queue BOOLEAN DEFAULT FALSE,
  in_queue_date TIMESTAMP DEFAULT NULL,
  send_attempts INTEGER DEFAULT 0,
  deleted BOOLEAN DEFAULT FALSE,
  related_id UUID DEFAULT NULL,
  related_type VARCHAR(100) DEFAULT NULL,
  related_confirm_opt_in BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_eman_list ON emailman (list_id, user_id, deleted);
CREATE INDEX IF NOT EXISTS idx_eman_campaign_id ON emailman (campaign_id);
CREATE INDEX IF NOT EXISTS idx_eman_relid_reltype_id ON emailman (related_id, related_type, campaign_id);

--
-- Table structure for table `emails`
--

CREATE TABLE IF NOT EXISTS emails (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  orphaned BOOLEAN DEFAULT NULL,
  last_synced TIMESTAMP DEFAULT NULL,
  date_sent_received TIMESTAMP DEFAULT NULL,
  message_id VARCHAR(255) DEFAULT NULL,
  type VARCHAR(100) DEFAULT NULL,
  status VARCHAR(100) DEFAULT NULL,
  flagged BOOLEAN DEFAULT NULL,
  reply_to_status BOOLEAN DEFAULT NULL,
  intent VARCHAR(100) DEFAULT 'pick',
  mailbox_id UUID DEFAULT NULL,
  parent_type VARCHAR(100) DEFAULT NULL,
  parent_id UUID DEFAULT NULL,
  uid VARCHAR(255) DEFAULT NULL,
  category_id VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_email_name ON emails (name);
CREATE INDEX IF NOT EXISTS idx_message_id ON emails (message_id);
CREATE INDEX IF NOT EXISTS idx_email_parent_id ON emails (parent_id);
CREATE INDEX IF NOT EXISTS idx_email_assigned ON emails (assigned_user_id, type, status);
CREATE INDEX IF NOT EXISTS idx_email_cat ON emails (category_id);
CREATE INDEX IF NOT EXISTS idx_email_uid ON emails (uid);

--
-- Table structure for table `emails_beans`
--

CREATE TABLE IF NOT EXISTS emails_beans (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  email_id UUID DEFAULT NULL,
  bean_id UUID DEFAULT NULL,
  bean_module VARCHAR(100) DEFAULT NULL,
  campaign_data TEXT DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_emails_beans_bean_id ON emails_beans (bean_id);
CREATE INDEX IF NOT EXISTS idx_emails_beans_email_bean ON emails_beans (email_id, bean_id, deleted);

--
-- Table structure for table `emails_email_addr_rel`
--

CREATE TABLE IF NOT EXISTS emails_email_addr_rel (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  email_id UUID NOT NULL,
  address_type VARCHAR(4) DEFAULT NULL,
  email_address_id UUID NOT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_eearl_email_id ON emails_email_addr_rel (email_id, address_type);
CREATE INDEX IF NOT EXISTS idx_eearl_address_id ON emails_email_addr_rel (email_address_id);

--
-- Table structure for table `emails_text`
--

CREATE TABLE IF NOT EXISTS emails_text (
  email_id UUID NOT NULL,
  from_addr VARCHAR(255) DEFAULT NULL,
  reply_to_addr VARCHAR(255) DEFAULT NULL,
  to_addrs TEXT DEFAULT NULL,
  cc_addrs TEXT DEFAULT NULL,
  bcc_addrs TEXT DEFAULT NULL,
  description TEXT DEFAULT NULL,
  description_html TEXT DEFAULT NULL,
  raw_source TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (email_id)
);

CREATE INDEX IF NOT EXISTS emails_textfromaddr ON emails_text (from_addr);

--
-- Table structure for table `external_oauth_connections`
--

CREATE TABLE IF NOT EXISTS external_oauth_connections (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  type VARCHAR(255) DEFAULT NULL,
  client_id VARCHAR(32) DEFAULT NULL,
  client_secret VARCHAR(32) DEFAULT NULL,
  token_type VARCHAR(32) DEFAULT NULL,
  expires_in VARCHAR(32) DEFAULT NULL,
  access_token TEXT DEFAULT NULL,
  refresh_token TEXT DEFAULT NULL,
  external_oauth_provider_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `external_oauth_providers`
--

CREATE TABLE IF NOT EXISTS external_oauth_providers (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  type VARCHAR(255) DEFAULT NULL,
  connector VARCHAR(255) DEFAULT NULL,
  client_id VARCHAR(255) DEFAULT NULL,
  client_secret VARCHAR(255) DEFAULT NULL,
  scope TEXT DEFAULT NULL,
  url_authorize VARCHAR(255) DEFAULT NULL,
  authorize_url_options TEXT DEFAULT NULL,
  url_access_token VARCHAR(255) DEFAULT NULL,
  extra_provider_params TEXT DEFAULT NULL,
  get_token_request_grant VARCHAR(255) DEFAULT 'authorization_code',
  get_token_request_options TEXT DEFAULT NULL,
  refresh_token_request_grant VARCHAR(255) DEFAULT 'refresh_token',
  refresh_token_request_options TEXT DEFAULT NULL,
  access_token_mapping VARCHAR(255) DEFAULT 'access_token',
  expires_in_mapping VARCHAR(255) DEFAULT 'expires_in',
  refresh_token_mapping VARCHAR(255) DEFAULT 'refresh_token',
  token_type_mapping VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `favorites`
--

CREATE TABLE IF NOT EXISTS favorites (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  parent_id UUID DEFAULT NULL,
  parent_type VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `fields_meta_data`
--

CREATE TABLE IF NOT EXISTS fields_meta_data (
  id VARCHAR(255) NOT NULL,
  name VARCHAR(255) DEFAULT NULL,
  vname VARCHAR(255) DEFAULT NULL,
  comments VARCHAR(255) DEFAULT NULL,
  help VARCHAR(255) DEFAULT NULL,
  custom_module VARCHAR(255) DEFAULT NULL,
  type VARCHAR(255) DEFAULT NULL,
  len INTEGER DEFAULT NULL,
  required BOOLEAN DEFAULT FALSE,
  default_value VARCHAR(255) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  audited BOOLEAN DEFAULT FALSE,
  massupdate BOOLEAN DEFAULT FALSE,
  duplicate_merge SMALLINT DEFAULT 0,
  reportable BOOLEAN DEFAULT TRUE,
  importable VARCHAR(255) DEFAULT NULL,
  ext1 VARCHAR(255) DEFAULT NULL,
  ext2 VARCHAR(255) DEFAULT NULL,
  ext3 VARCHAR(255) DEFAULT NULL,
  ext4 TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_meta_id_del ON fields_meta_data (id, deleted);
CREATE INDEX IF NOT EXISTS idx_meta_cm_del ON fields_meta_data (custom_module, deleted);

--
-- Table structure for table `folders`
--

CREATE TABLE IF NOT EXISTS folders (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  folder_type VARCHAR(25) DEFAULT NULL,
  parent_folder UUID DEFAULT NULL,
  has_child BOOLEAN DEFAULT FALSE,
  is_group BOOLEAN DEFAULT FALSE,
  is_dynamic BOOLEAN DEFAULT FALSE,
  dynamic_query TEXT DEFAULT NULL,
  assign_to_id UUID DEFAULT NULL,
  created_by UUID NOT NULL,
  modified_by UUID NOT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_parent_folder ON folders (parent_folder);

--
-- Table structure for table `folders_rel`
--

CREATE TABLE IF NOT EXISTS folders_rel (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  folder_id UUID NOT NULL,
  polymorphic_module VARCHAR(25) DEFAULT NULL,
  polymorphic_id UUID NOT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_poly_module_poly_id ON folders_rel (polymorphic_module, polymorphic_id);
CREATE INDEX IF NOT EXISTS idx_fr_id_deleted_poly ON folders_rel (folder_id, deleted, polymorphic_id);

--
-- Table structure for table `folders_subscriptions`
--

CREATE TABLE IF NOT EXISTS folders_subscriptions (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  folder_id UUID NOT NULL,
  assigned_user_id UUID NOT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_folder_id_assigned_user_id ON folders_subscriptions (folder_id, assigned_user_id);

--
-- Table structure for table `fp_event_locations`
--

CREATE TABLE IF NOT EXISTS fp_event_locations (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  address VARCHAR(255) DEFAULT NULL,
  address_city VARCHAR(100) DEFAULT NULL,
  address_country VARCHAR(100) DEFAULT NULL,
  address_postalcode VARCHAR(20) DEFAULT NULL,
  address_state VARCHAR(100) DEFAULT NULL,
  capacity VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `fp_event_locations_audit`
--

CREATE TABLE IF NOT EXISTS fp_event_locations_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_fp_event_locations_parent_id ON fp_event_locations_audit (parent_id);

--
-- Table structure for table `fp_event_locations_fp_events_1_c`
--

CREATE TABLE IF NOT EXISTS fp_event_locations_fp_events_1_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  fp_event_locations_fp_events_1fp_event_locations_ida VARCHAR(36) DEFAULT NULL,
  fp_event_locations_fp_events_1fp_events_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS fp_event_locations_fp_events_1_ida1 ON fp_event_locations_fp_events_1_c (fp_event_locations_fp_events_1fp_event_locations_ida);
CREATE INDEX IF NOT EXISTS fp_event_locations_fp_events_1_alt ON fp_event_locations_fp_events_1_c (fp_event_locations_fp_events_1fp_events_idb);

--
-- Table structure for table `fp_events`
--

CREATE TABLE IF NOT EXISTS fp_events (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  duration_hours INTEGER DEFAULT NULL,
  duration_minutes INTEGER DEFAULT NULL,
  date_start TIMESTAMP DEFAULT NULL,
  date_end TIMESTAMP DEFAULT NULL,
  budget NUMERIC(26,6) DEFAULT NULL,
  currency_id UUID DEFAULT NULL,
  invite_templates VARCHAR(100) DEFAULT NULL,
  accept_redirect VARCHAR(255) DEFAULT NULL,
  decline_redirect VARCHAR(255) DEFAULT NULL,
  activity_status_type VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `fp_events_audit`
--

CREATE TABLE IF NOT EXISTS fp_events_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_fp_events_parent_id ON fp_events_audit (parent_id);

--
-- Table structure for table `fp_events_contacts_c`
--

CREATE TABLE IF NOT EXISTS fp_events_contacts_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  fp_events_contactsfp_events_ida VARCHAR(36) DEFAULT NULL,
  fp_events_contactscontacts_idb VARCHAR(36) DEFAULT NULL,
  invite_status VARCHAR(25) DEFAULT 'Not Invited',
  accept_status VARCHAR(25) DEFAULT 'No Response',
  email_responded INTEGER DEFAULT 0,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS fp_events_contacts_alt ON fp_events_contacts_c (fp_events_contactsfp_events_ida, fp_events_contactscontacts_idb);

--
-- Table structure for table `fp_events_fp_event_delegates_1_c`
--

CREATE TABLE IF NOT EXISTS fp_events_fp_event_delegates_1_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  fp_events_fp_event_delegates_1fp_events_ida VARCHAR(36) DEFAULT NULL,
  fp_events_fp_event_delegates_1fp_event_delegates_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS fp_events_fp_event_delegates_1_ida1 ON fp_events_fp_event_delegates_1_c (fp_events_fp_event_delegates_1fp_events_ida);
CREATE INDEX IF NOT EXISTS fp_events_fp_event_delegates_1_alt ON fp_events_fp_event_delegates_1_c (fp_events_fp_event_delegates_1fp_event_delegates_idb);

--
-- Table structure for table `fp_events_fp_event_locations_1_c`
--

CREATE TABLE IF NOT EXISTS fp_events_fp_event_locations_1_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  fp_events_fp_event_locations_1fp_events_ida VARCHAR(36) DEFAULT NULL,
  fp_events_fp_event_locations_1fp_event_locations_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS fp_events_fp_event_locations_1_alt ON fp_events_fp_event_locations_1_c (fp_events_fp_event_locations_1fp_events_ida, fp_events_fp_event_locations_1fp_event_locations_idb);

--
-- Table structure for table `fp_events_leads_1_c`
--

CREATE TABLE IF NOT EXISTS fp_events_leads_1_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  fp_events_leads_1fp_events_ida VARCHAR(36) DEFAULT NULL,
  fp_events_leads_1leads_idb VARCHAR(36) DEFAULT NULL,
  invite_status VARCHAR(25) DEFAULT 'Not Invited',
  accept_status VARCHAR(25) DEFAULT 'No Response',
  email_responded INTEGER DEFAULT 0,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS fp_events_leads_1_alt ON fp_events_leads_1_c (fp_events_leads_1fp_events_ida, fp_events_leads_1leads_idb);

--
-- Table structure for table `fp_events_prospects_1_c`
--

CREATE TABLE IF NOT EXISTS fp_events_prospects_1_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  fp_events_prospects_1fp_events_ida VARCHAR(36) DEFAULT NULL,
  fp_events_prospects_1prospects_idb VARCHAR(36) DEFAULT NULL,
  invite_status VARCHAR(25) DEFAULT 'Not Invited',
  accept_status VARCHAR(25) DEFAULT 'No Response',
  email_responded INTEGER DEFAULT 0,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS fp_events_prospects_1_alt ON fp_events_prospects_1_c (fp_events_prospects_1fp_events_ida, fp_events_prospects_1prospects_idb);

--
-- Table structure for table `import_maps`
--

CREATE TABLE IF NOT EXISTS import_maps (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(254) DEFAULT NULL,
  source VARCHAR(36) DEFAULT NULL,
  enclosure VARCHAR(1) DEFAULT ' ',
  delimiter VARCHAR(1) DEFAULT ',',
  module VARCHAR(36) DEFAULT NULL,
  content TEXT DEFAULT NULL,
  default_values TEXT DEFAULT NULL,
  has_header BOOLEAN DEFAULT TRUE,
  deleted BOOLEAN DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  assigned_user_id UUID DEFAULT NULL,
  is_published VARCHAR(3) DEFAULT 'no',
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_owner_module_name ON import_maps (assigned_user_id, module, name, deleted);

--
-- Table structure for table `inbound_email`
--

CREATE TABLE IF NOT EXISTS inbound_email (
  id VARCHAR(36) NOT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  name VARCHAR(255) DEFAULT NULL,
  status VARCHAR(100) DEFAULT 'Active',
  email_body_filtering VARCHAR(255) DEFAULT 'multi',
  server_url VARCHAR(100) DEFAULT NULL,
  connection_string VARCHAR(255) DEFAULT NULL,
  email_user VARCHAR(100) DEFAULT NULL,
  email_password VARCHAR(100) DEFAULT NULL,
  port INTEGER DEFAULT 143,
  service VARCHAR(50) DEFAULT NULL,
  mailbox TEXT DEFAULT NULL,
  sentFolder VARCHAR(255) DEFAULT NULL,
  trashFolder VARCHAR(255) DEFAULT NULL,
  delete_seen BOOLEAN DEFAULT FALSE,
  move_messages_to_trash_after_import BOOLEAN DEFAULT FALSE,
  mailbox_type VARCHAR(10) DEFAULT NULL,
  template_id UUID DEFAULT NULL,
  stored_options TEXT DEFAULT NULL,
  group_id UUID DEFAULT NULL,
  is_personal BOOLEAN DEFAULT FALSE,
  groupfolder_id UUID DEFAULT NULL,
  type VARCHAR(255) DEFAULT NULL,
  auth_type VARCHAR(255) DEFAULT 'basic',
  protocol VARCHAR(255) DEFAULT 'imap',
  is_ssl BOOLEAN DEFAULT FALSE,
  distribution_user_id UUID DEFAULT NULL,
  outbound_email_id UUID DEFAULT NULL,
  create_case_template_id UUID DEFAULT NULL,
  external_oauth_connection_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `inbound_email_autoreply`
--

CREATE TABLE IF NOT EXISTS inbound_email_autoreply (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  deleted BOOLEAN DEFAULT FALSE,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  autoreplied_to VARCHAR(100) DEFAULT NULL,
  ie_id UUID NOT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_ie_autoreplied_to ON inbound_email_autoreply (autoreplied_to);

--
-- Table structure for table `inbound_email_cache_ts`
--

CREATE TABLE IF NOT EXISTS inbound_email_cache_ts (
  id VARCHAR(255) NOT NULL,
  ie_timestamp INTEGER DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `jjwg_address_cache`
--

CREATE TABLE IF NOT EXISTS jjwg_address_cache (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  lat REAL DEFAULT NULL,
  lng REAL DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `jjwg_address_cache_audit`
--

CREATE TABLE IF NOT EXISTS jjwg_address_cache_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_jjwg_address_cache_parent_id ON jjwg_address_cache_audit (parent_id);

--
-- Table structure for table `jjwg_areas`
--

CREATE TABLE IF NOT EXISTS jjwg_areas (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  city VARCHAR(255) DEFAULT NULL,
  state VARCHAR(255) DEFAULT NULL,
  country VARCHAR(255) DEFAULT NULL,
  coordinates TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `jjwg_areas_audit`
--

CREATE TABLE IF NOT EXISTS jjwg_areas_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_jjwg_areas_parent_id ON jjwg_areas_audit (parent_id);

--
-- Table structure for table `jjwg_maps`
--

CREATE TABLE IF NOT EXISTS jjwg_maps (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  distance REAL DEFAULT NULL,
  unit_type VARCHAR(100) DEFAULT 'mi',
  module_type VARCHAR(100) DEFAULT 'Accounts',
  parent_type VARCHAR(255) DEFAULT NULL,
  parent_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `jjwg_maps_audit`
--

CREATE TABLE IF NOT EXISTS jjwg_maps_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_jjwg_maps_parent_id ON jjwg_maps_audit (parent_id);

--
-- Table structure for table `jjwg_maps_jjwg_areas_c`
--

CREATE TABLE IF NOT EXISTS jjwg_maps_jjwg_areas_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  jjwg_maps_5304wg_maps_ida VARCHAR(36) DEFAULT NULL,
  jjwg_maps_41f2g_areas_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS jjwg_maps_jjwg_areas_alt ON jjwg_maps_jjwg_areas_c (jjwg_maps_5304wg_maps_ida, jjwg_maps_41f2g_areas_idb);

--
-- Table structure for table `jjwg_maps_jjwg_markers_c`
--

CREATE TABLE IF NOT EXISTS jjwg_maps_jjwg_markers_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  jjwg_maps_b229wg_maps_ida VARCHAR(36) DEFAULT NULL,
  jjwg_maps_2e31markers_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS jjwg_maps_jjwg_markers_alt ON jjwg_maps_jjwg_markers_c (jjwg_maps_b229wg_maps_ida, jjwg_maps_2e31markers_idb);

--
-- Table structure for table `jjwg_markers`
--

CREATE TABLE IF NOT EXISTS jjwg_markers (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  city VARCHAR(255) DEFAULT NULL,
  state VARCHAR(255) DEFAULT NULL,
  country VARCHAR(255) DEFAULT NULL,
  jjwg_maps_lat REAL DEFAULT 0.00000000,
  jjwg_maps_lng REAL DEFAULT 0.00000000,
  marker_image VARCHAR(100) DEFAULT 'company',
  PRIMARY KEY (id)
);

--
-- Table structure for table `jjwg_markers_audit`
--

CREATE TABLE IF NOT EXISTS jjwg_markers_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_jjwg_markers_parent_id ON jjwg_markers_audit (parent_id);

--
-- Table structure for table `job_queue`
--

CREATE TABLE IF NOT EXISTS job_queue (
  assigned_user_id UUID DEFAULT NULL,
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  scheduler_id UUID DEFAULT NULL,
  execute_time TIMESTAMP DEFAULT NULL,
  status VARCHAR(20) DEFAULT NULL,
  resolution VARCHAR(20) DEFAULT NULL,
  message TEXT DEFAULT NULL,
  target VARCHAR(255) DEFAULT NULL,
  data TEXT DEFAULT NULL,
  requeue BOOLEAN DEFAULT FALSE,
  retry_count SMALLINT DEFAULT NULL,
  failure_count SMALLINT DEFAULT NULL,
  job_delay INTEGER DEFAULT NULL,
  client VARCHAR(255) DEFAULT NULL,
  percent_complete INTEGER DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_status_scheduler ON job_queue (status, scheduler_id);
CREATE INDEX IF NOT EXISTS idx_status_time ON job_queue (status, execute_time, date_entered);
CREATE INDEX IF NOT EXISTS idx_status_entered ON job_queue (status, date_entered);
CREATE INDEX IF NOT EXISTS idx_status_modified ON job_queue (status, date_modified);

--
-- Table structure for table `leads`
--

CREATE TABLE IF NOT EXISTS leads (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  salutation VARCHAR(255) DEFAULT NULL,
  first_name VARCHAR(100) DEFAULT NULL,
  last_name VARCHAR(100) DEFAULT NULL,
  title VARCHAR(100) DEFAULT NULL,
  photo VARCHAR(255) DEFAULT NULL,
  department VARCHAR(100) DEFAULT NULL,
  do_not_call BOOLEAN DEFAULT FALSE,
  phone_home VARCHAR(100) DEFAULT NULL,
  phone_mobile VARCHAR(100) DEFAULT NULL,
  phone_work VARCHAR(100) DEFAULT NULL,
  phone_other VARCHAR(100) DEFAULT NULL,
  phone_fax VARCHAR(100) DEFAULT NULL,
  lawful_basis TEXT DEFAULT NULL,
  date_reviewed DATE DEFAULT NULL,
  lawful_basis_source VARCHAR(100) DEFAULT NULL,
  primary_address_street VARCHAR(150) DEFAULT NULL,
  primary_address_city VARCHAR(100) DEFAULT NULL,
  primary_address_state VARCHAR(100) DEFAULT NULL,
  primary_address_postalcode VARCHAR(20) DEFAULT NULL,
  primary_address_country VARCHAR(255) DEFAULT NULL,
  alt_address_street VARCHAR(150) DEFAULT NULL,
  alt_address_city VARCHAR(100) DEFAULT NULL,
  alt_address_state VARCHAR(100) DEFAULT NULL,
  alt_address_postalcode VARCHAR(20) DEFAULT NULL,
  alt_address_country VARCHAR(255) DEFAULT NULL,
  assistant VARCHAR(75) DEFAULT NULL,
  assistant_phone VARCHAR(100) DEFAULT NULL,
  converted BOOLEAN DEFAULT FALSE,
  refered_by VARCHAR(100) DEFAULT NULL,
  lead_source VARCHAR(100) DEFAULT NULL,
  lead_source_description TEXT DEFAULT NULL,
  status VARCHAR(100) DEFAULT NULL,
  status_description TEXT DEFAULT NULL,
  reports_to_id UUID DEFAULT NULL,
  account_name VARCHAR(255) DEFAULT NULL,
  account_description TEXT DEFAULT NULL,
  contact_id UUID DEFAULT NULL,
  account_id UUID DEFAULT NULL,
  opportunity_id UUID DEFAULT NULL,
  opportunity_name VARCHAR(255) DEFAULT NULL,
  opportunity_amount VARCHAR(50) DEFAULT NULL,
  campaign_id UUID DEFAULT NULL,
  birthdate DATE DEFAULT NULL,
  portal_name VARCHAR(255) DEFAULT NULL,
  portal_app VARCHAR(255) DEFAULT NULL,
  website VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_lead_acct_name_first ON leads (account_name, deleted);
CREATE INDEX IF NOT EXISTS idx_lead_last_first ON leads (last_name, first_name, deleted);
CREATE INDEX IF NOT EXISTS idx_lead_del_stat ON leads (last_name, status, deleted, first_name);
CREATE INDEX IF NOT EXISTS idx_lead_opp_del ON leads (opportunity_id, deleted);
CREATE INDEX IF NOT EXISTS idx_leads_acct_del ON leads (account_id, deleted);
CREATE INDEX IF NOT EXISTS idx_del_user ON leads (deleted, assigned_user_id);
CREATE INDEX IF NOT EXISTS idx_lead_assigned ON leads (assigned_user_id);
CREATE INDEX IF NOT EXISTS idx_lead_contact ON leads (contact_id);
CREATE INDEX IF NOT EXISTS idx_reports_to ON leads (reports_to_id);
CREATE INDEX IF NOT EXISTS idx_lead_phone_work ON leads (phone_work);
CREATE INDEX IF NOT EXISTS idx_leads_id_del ON leads (id, deleted);

--
-- Table structure for table `leads_audit`
--

CREATE TABLE IF NOT EXISTS leads_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_leads_parent_id ON leads_audit (parent_id);

--
-- Table structure for table `leads_cstm`
--

CREATE TABLE IF NOT EXISTS leads_cstm (
  id_c UUID NOT NULL,
  jjwg_maps_lng_c REAL DEFAULT 0.00000000,
  jjwg_maps_lat_c REAL DEFAULT 0.00000000,
  jjwg_maps_geocode_status_c VARCHAR(255) DEFAULT NULL,
  jjwg_maps_address_c VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id_c)
);

--
-- Table structure for table `linked_documents`
--

CREATE TABLE IF NOT EXISTS linked_documents (
  id VARCHAR(36) NOT NULL,
  parent_id VARCHAR(36) DEFAULT NULL,
  parent_type VARCHAR(25) DEFAULT NULL,
  document_id VARCHAR(36) DEFAULT NULL,
  document_revision_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_parent_document ON linked_documents (parent_type, parent_id, document_id);

--
-- Table structure for table `meetings`
--

CREATE TABLE IF NOT EXISTS meetings (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(50) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  location VARCHAR(50) DEFAULT NULL,
  password VARCHAR(50) DEFAULT NULL,
  join_url VARCHAR(200) DEFAULT NULL,
  host_url VARCHAR(400) DEFAULT NULL,
  displayed_url VARCHAR(400) DEFAULT NULL,
  creator VARCHAR(50) DEFAULT NULL,
  external_id VARCHAR(50) DEFAULT NULL,
  duration_hours INTEGER DEFAULT NULL,
  duration_minutes INTEGER DEFAULT NULL,
  date_start TIMESTAMP DEFAULT NULL,
  date_end TIMESTAMP DEFAULT NULL,
  parent_type VARCHAR(100) DEFAULT NULL,
  status VARCHAR(100) DEFAULT 'Planned',
  type VARCHAR(255) DEFAULT 'Sugar',
  parent_id UUID DEFAULT NULL,
  reminder_time INTEGER DEFAULT -1,
  email_reminder_time INTEGER DEFAULT -1,
  email_reminder_sent BOOLEAN DEFAULT FALSE,
  outlook_id VARCHAR(255) DEFAULT NULL,
  sequence INTEGER DEFAULT 0,
  repeat_type VARCHAR(36) DEFAULT NULL,
  repeat_interval INTEGER DEFAULT 1,
  repeat_dow VARCHAR(7) DEFAULT NULL,
  repeat_until DATE DEFAULT NULL,
  repeat_count INTEGER DEFAULT NULL,
  repeat_parent_id UUID DEFAULT NULL,
  recurring_source VARCHAR(36) DEFAULT NULL,
  gsync_id VARCHAR(1024) DEFAULT NULL,
  gsync_lastsync INTEGER DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_mtg_name ON meetings (name);
CREATE INDEX IF NOT EXISTS idx_meet_par_del ON meetings (parent_id, parent_type, deleted);
CREATE INDEX IF NOT EXISTS idx_meet_stat_del ON meetings (assigned_user_id, status, deleted);
CREATE INDEX IF NOT EXISTS idx_meet_date_start ON meetings (date_start);

--
-- Table structure for table `meetings_contacts`
--

CREATE TABLE IF NOT EXISTS meetings_contacts (
  id VARCHAR(36) NOT NULL,
  meeting_id VARCHAR(36) DEFAULT NULL,
  contact_id VARCHAR(36) DEFAULT NULL,
  required VARCHAR(1) DEFAULT '1',
  accept_status VARCHAR(25) DEFAULT 'none',
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_con_mtg_mtg ON meetings_contacts (meeting_id);
CREATE INDEX IF NOT EXISTS idx_con_mtg_con ON meetings_contacts (contact_id);
CREATE INDEX IF NOT EXISTS idx_meeting_contact ON meetings_contacts (meeting_id, contact_id);

--
-- Table structure for table `meetings_cstm`
--

CREATE TABLE IF NOT EXISTS meetings_cstm (
  id_c UUID NOT NULL,
  jjwg_maps_lng_c REAL DEFAULT 0.00000000,
  jjwg_maps_lat_c REAL DEFAULT 0.00000000,
  jjwg_maps_geocode_status_c VARCHAR(255) DEFAULT NULL,
  jjwg_maps_address_c VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id_c)
);

--
-- Table structure for table `meetings_leads`
--

CREATE TABLE IF NOT EXISTS meetings_leads (
  id VARCHAR(36) NOT NULL,
  meeting_id VARCHAR(36) DEFAULT NULL,
  lead_id VARCHAR(36) DEFAULT NULL,
  required VARCHAR(1) DEFAULT '1',
  accept_status VARCHAR(25) DEFAULT 'none',
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_lead_meeting_meeting ON meetings_leads (meeting_id);
CREATE INDEX IF NOT EXISTS idx_lead_meeting_lead ON meetings_leads (lead_id);
CREATE INDEX IF NOT EXISTS idx_meeting_lead ON meetings_leads (meeting_id, lead_id);

--
-- Table structure for table `meetings_users`
--

CREATE TABLE IF NOT EXISTS meetings_users (
  id VARCHAR(36) NOT NULL,
  meeting_id VARCHAR(36) DEFAULT NULL,
  user_id VARCHAR(36) DEFAULT NULL,
  required VARCHAR(1) DEFAULT '1',
  accept_status VARCHAR(25) DEFAULT 'none',
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_usr_mtg_mtg ON meetings_users (meeting_id);
CREATE INDEX IF NOT EXISTS idx_usr_mtg_usr ON meetings_users (user_id);
CREATE INDEX IF NOT EXISTS idx_meeting_users ON meetings_users (meeting_id, user_id);

--
-- Table structure for table `notes`
--

CREATE TABLE IF NOT EXISTS notes (
  assigned_user_id UUID DEFAULT NULL,
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  name VARCHAR(255) DEFAULT NULL,
  file_mime_type VARCHAR(100) DEFAULT NULL,
  filename VARCHAR(255) DEFAULT NULL,
  parent_type VARCHAR(255) DEFAULT NULL,
  parent_id UUID DEFAULT NULL,
  contact_id UUID DEFAULT NULL,
  portal_flag BOOLEAN DEFAULT NULL,
  embed_flag BOOLEAN DEFAULT FALSE,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_note_name ON notes (name);
CREATE INDEX IF NOT EXISTS idx_notes_parent ON notes (parent_id, parent_type);
CREATE INDEX IF NOT EXISTS idx_note_contact ON notes (contact_id);
CREATE INDEX IF NOT EXISTS idx_notes_assigned_del ON notes (deleted, assigned_user_id);

--
-- Table structure for table `oauth2clients`
--

CREATE TABLE IF NOT EXISTS oauth2clients (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  secret VARCHAR(4000) DEFAULT NULL,
  redirect_url VARCHAR(255) DEFAULT NULL,
  is_confidential BOOLEAN DEFAULT TRUE,
  allowed_grant_type VARCHAR(255) DEFAULT 'password',
  duration_value INTEGER DEFAULT NULL,
  duration_amount INTEGER DEFAULT NULL,
  duration_unit VARCHAR(255) DEFAULT 'Duration Unit',
  assigned_user_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `oauth2tokens`
--

CREATE TABLE IF NOT EXISTS oauth2tokens (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  token_is_revoked BOOLEAN DEFAULT NULL,
  token_type VARCHAR(255) DEFAULT NULL,
  access_token_expires TIMESTAMP DEFAULT NULL,
  access_token VARCHAR(4000) DEFAULT NULL,
  refresh_token VARCHAR(4000) DEFAULT NULL,
  refresh_token_expires TIMESTAMP DEFAULT NULL,
  grant_type VARCHAR(255) DEFAULT NULL,
  state VARCHAR(1024) DEFAULT NULL,
  client UUID DEFAULT NULL,
  assigned_user_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `oauth_consumer`
--

CREATE TABLE IF NOT EXISTS oauth_consumer (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  c_key VARCHAR(255) DEFAULT NULL,
  c_secret VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE (c_key)
);

--
-- Table structure for table `oauth_nonce`
--

CREATE TABLE IF NOT EXISTS oauth_nonce (
  conskey VARCHAR(32) NOT NULL,
  nonce VARCHAR(32) NOT NULL,
  nonce_ts BIGINT DEFAULT NULL,
  PRIMARY KEY (conskey, nonce)
);

CREATE INDEX IF NOT EXISTS oauth_nonce_keyts ON oauth_nonce (conskey, nonce_ts);

--
-- Table structure for table `oauth_tokens`
--

CREATE TABLE IF NOT EXISTS oauth_tokens (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  secret VARCHAR(32) DEFAULT NULL,
  tstate VARCHAR(1) DEFAULT NULL,
  consumer UUID NOT NULL,
  token_ts BIGINT DEFAULT NULL,
  verify VARCHAR(32) DEFAULT NULL,
  deleted BOOLEAN NOT NULL DEFAULT FALSE,
  callback_url VARCHAR(255) DEFAULT NULL,
  assigned_user_id UUID DEFAULT NULL,
  PRIMARY KEY (id, deleted)
);

CREATE INDEX IF NOT EXISTS oauth_state_ts ON oauth_tokens (tstate, token_ts);
CREATE INDEX IF NOT EXISTS constoken_key ON oauth_tokens (consumer);

--
-- Table structure for table `opportunities`
--

CREATE TABLE IF NOT EXISTS opportunities (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(50) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  opportunity_type VARCHAR(255) DEFAULT NULL,
  campaign_id UUID DEFAULT NULL,
  lead_source VARCHAR(50) DEFAULT NULL,
  amount DOUBLE PRECISION DEFAULT NULL,
  amount_usdollar DOUBLE PRECISION DEFAULT NULL,
  currency_id UUID DEFAULT NULL,
  date_closed DATE DEFAULT NULL,
  next_step VARCHAR(100) DEFAULT NULL,
  sales_stage VARCHAR(255) DEFAULT NULL,
  probability DOUBLE PRECISION DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_opp_name ON opportunities (name);
CREATE INDEX IF NOT EXISTS idx_opp_assigned ON opportunities (assigned_user_id);
CREATE INDEX IF NOT EXISTS idx_opp_id_deleted ON opportunities (id, deleted);

--
-- Table structure for table `opportunities_audit`
--

CREATE TABLE IF NOT EXISTS opportunities_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_opportunities_parent_id ON opportunities_audit (parent_id);

--
-- Table structure for table `opportunities_contacts`
--

CREATE TABLE IF NOT EXISTS opportunities_contacts (
  id VARCHAR(36) NOT NULL,
  contact_id VARCHAR(36) DEFAULT NULL,
  opportunity_id VARCHAR(36) DEFAULT NULL,
  contact_role VARCHAR(50) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_con_opp_con ON opportunities_contacts (contact_id);
CREATE INDEX IF NOT EXISTS idx_con_opp_opp ON opportunities_contacts (opportunity_id);
CREATE INDEX IF NOT EXISTS idx_opportunities_contacts ON opportunities_contacts (opportunity_id, contact_id);

--
-- Table structure for table `opportunities_cstm`
--

CREATE TABLE IF NOT EXISTS opportunities_cstm (
  id_c UUID NOT NULL,
  jjwg_maps_lng_c REAL DEFAULT 0.00000000,
  jjwg_maps_lat_c REAL DEFAULT 0.00000000,
  jjwg_maps_geocode_status_c VARCHAR(255) DEFAULT NULL,
  jjwg_maps_address_c VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id_c)
);

--
-- Table structure for table `outbound_email`
--

CREATE TABLE IF NOT EXISTS outbound_email (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  type VARCHAR(15) DEFAULT 'user',
  user_id UUID DEFAULT NULL,
  smtp_from_name VARCHAR(255) DEFAULT NULL,
  smtp_from_addr VARCHAR(255) DEFAULT NULL,
  reply_to_name VARCHAR(255) DEFAULT NULL,
  reply_to_addr VARCHAR(255) DEFAULT NULL,
  signature TEXT DEFAULT NULL,
  mail_sendtype VARCHAR(8) DEFAULT 'SMTP',
  mail_smtptype VARCHAR(20) DEFAULT 'other',
  mail_smtpserver VARCHAR(100) DEFAULT NULL,
  mail_smtpport VARCHAR(5) DEFAULT '25',
  mail_smtpuser VARCHAR(100) DEFAULT NULL,
  mail_smtppass VARCHAR(100) DEFAULT NULL,
  mail_smtpauth_req BOOLEAN DEFAULT FALSE,
  mail_smtpssl VARCHAR(1) DEFAULT '0',
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `outbound_email_audit`
--

CREATE TABLE IF NOT EXISTS outbound_email_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_outbound_email_parent_id ON outbound_email_audit (parent_id);

--
-- Table structure for table `project`
--

CREATE TABLE IF NOT EXISTS project (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  assigned_user_id UUID DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  name VARCHAR(50) DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  estimated_start_date DATE DEFAULT NULL,
  estimated_end_date DATE DEFAULT NULL,
  status VARCHAR(255) DEFAULT NULL,
  priority VARCHAR(255) DEFAULT NULL,
  override_business_hours BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

--
-- Table structure for table `project_contacts_1_c`
--

CREATE TABLE IF NOT EXISTS project_contacts_1_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  project_contacts_1project_ida VARCHAR(36) DEFAULT NULL,
  project_contacts_1contacts_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS project_contacts_1_alt ON project_contacts_1_c (project_contacts_1project_ida, project_contacts_1contacts_idb);

--
-- Table structure for table `project_cstm`
--

CREATE TABLE IF NOT EXISTS project_cstm (
  id_c UUID NOT NULL,
  jjwg_maps_lng_c REAL DEFAULT 0.00000000,
  jjwg_maps_lat_c REAL DEFAULT 0.00000000,
  jjwg_maps_geocode_status_c VARCHAR(255) DEFAULT NULL,
  jjwg_maps_address_c VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id_c)
);

--
-- Table structure for table `project_task`
--

CREATE TABLE IF NOT EXISTS project_task (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  project_id UUID NOT NULL,
  project_task_id INTEGER DEFAULT NULL,
  name VARCHAR(50) DEFAULT NULL,
  status VARCHAR(255) DEFAULT NULL,
  relationship_type VARCHAR(255) DEFAULT NULL,
  description TEXT DEFAULT NULL,
  predecessors TEXT DEFAULT NULL,
  date_start DATE DEFAULT NULL,
  time_start INTEGER DEFAULT NULL,
  time_finish INTEGER DEFAULT NULL,
  date_finish DATE DEFAULT NULL,
  duration INTEGER DEFAULT NULL,
  duration_unit TEXT DEFAULT NULL,
  actual_duration INTEGER DEFAULT NULL,
  percent_complete INTEGER DEFAULT NULL,
  date_due DATE DEFAULT NULL,
  time_due TIME DEFAULT NULL,
  parent_task_id INTEGER DEFAULT NULL,
  assigned_user_id UUID DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  priority VARCHAR(255) DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  milestone_flag BOOLEAN DEFAULT NULL,
  order_number INTEGER DEFAULT 1,
  task_number INTEGER DEFAULT NULL,
  estimated_effort INTEGER DEFAULT NULL,
  actual_effort INTEGER DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  utilization INTEGER DEFAULT 100,
  PRIMARY KEY (id)
);

--
-- Table structure for table `project_task_audit`
--

CREATE TABLE IF NOT EXISTS project_task_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_project_task_parent_id ON project_task_audit (parent_id);

--
-- Table structure for table `project_users_1_c`
--

CREATE TABLE IF NOT EXISTS project_users_1_c (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  project_users_1project_ida VARCHAR(36) DEFAULT NULL,
  project_users_1users_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS project_users_1_alt ON project_users_1_c (project_users_1project_ida, project_users_1users_idb);

--
-- Table structure for table `projects_accounts`
--

CREATE TABLE IF NOT EXISTS projects_accounts (
  id VARCHAR(36) NOT NULL,
  account_id VARCHAR(36) DEFAULT NULL,
  project_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_proj_acct_proj ON projects_accounts (project_id);
CREATE INDEX IF NOT EXISTS idx_proj_acct_acct ON projects_accounts (account_id);
CREATE INDEX IF NOT EXISTS projects_accounts_alt ON projects_accounts (project_id, account_id);

--
-- Table structure for table `projects_bugs`
--

CREATE TABLE IF NOT EXISTS projects_bugs (
  id VARCHAR(36) NOT NULL,
  bug_id VARCHAR(36) DEFAULT NULL,
  project_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_proj_bug_proj ON projects_bugs (project_id);
CREATE INDEX IF NOT EXISTS idx_proj_bug_bug ON projects_bugs (bug_id);
CREATE INDEX IF NOT EXISTS projects_bugs_alt ON projects_bugs (project_id, bug_id);

--
-- Table structure for table `projects_cases`
--

CREATE TABLE IF NOT EXISTS projects_cases (
  id VARCHAR(36) NOT NULL,
  case_id VARCHAR(36) DEFAULT NULL,
  project_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_proj_case_proj ON projects_cases (project_id);
CREATE INDEX IF NOT EXISTS idx_proj_case_case ON projects_cases (case_id);
CREATE INDEX IF NOT EXISTS projects_cases_alt ON projects_cases (project_id, case_id);

--
-- Table structure for table `projects_contacts`
--

CREATE TABLE IF NOT EXISTS projects_contacts (
  id VARCHAR(36) NOT NULL,
  contact_id VARCHAR(36) DEFAULT NULL,
  project_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_proj_con_proj ON projects_contacts (project_id);
CREATE INDEX IF NOT EXISTS idx_proj_con_con ON projects_contacts (contact_id);
CREATE INDEX IF NOT EXISTS projects_contacts_alt ON projects_contacts (project_id, contact_id);

--
-- Table structure for table `projects_opportunities`
--

CREATE TABLE IF NOT EXISTS projects_opportunities (
  id VARCHAR(36) NOT NULL,
  opportunity_id VARCHAR(36) DEFAULT NULL,
  project_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_proj_opp_proj ON projects_opportunities (project_id);
CREATE INDEX IF NOT EXISTS idx_proj_opp_opp ON projects_opportunities (opportunity_id);
CREATE INDEX IF NOT EXISTS projects_opportunities_alt ON projects_opportunities (project_id, opportunity_id);

--
-- Table structure for table `projects_products`
--

CREATE TABLE IF NOT EXISTS projects_products (
  id VARCHAR(36) NOT NULL,
  product_id VARCHAR(36) DEFAULT NULL,
  project_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_proj_prod_project ON projects_products (project_id);
CREATE INDEX IF NOT EXISTS idx_proj_prod_product ON projects_products (product_id);
CREATE INDEX IF NOT EXISTS projects_products_alt ON projects_products (project_id, product_id);

--
-- Table structure for table `prospect_list_campaigns`
--

CREATE TABLE IF NOT EXISTS prospect_list_campaigns (
  id VARCHAR(36) NOT NULL,
  prospect_list_id VARCHAR(36) DEFAULT NULL,
  campaign_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_pro_id ON prospect_list_campaigns (prospect_list_id);
CREATE INDEX IF NOT EXISTS idx_cam_id ON prospect_list_campaigns (campaign_id);
CREATE INDEX IF NOT EXISTS idx_prospect_list_campaigns ON prospect_list_campaigns (prospect_list_id, campaign_id);

--
-- Table structure for table `prospect_lists`
--

CREATE TABLE IF NOT EXISTS prospect_lists (
  assigned_user_id UUID DEFAULT NULL,
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  list_type VARCHAR(100) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  deleted BOOLEAN DEFAULT NULL,
  description TEXT DEFAULT NULL,
  domain_name VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_prospect_list_name ON prospect_lists (name);

--
-- Table structure for table `prospect_lists_prospects`
--

CREATE TABLE IF NOT EXISTS prospect_lists_prospects (
  id VARCHAR(36) NOT NULL,
  prospect_list_id VARCHAR(36) DEFAULT NULL,
  related_id VARCHAR(36) DEFAULT NULL,
  related_type VARCHAR(25) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_plp_pro_id ON prospect_lists_prospects (prospect_list_id, deleted);
CREATE INDEX IF NOT EXISTS idx_plp_rel_id ON prospect_lists_prospects (related_id, related_type, prospect_list_id);

--
-- Table structure for table `prospects`
--

CREATE TABLE IF NOT EXISTS prospects (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  salutation VARCHAR(255) DEFAULT NULL,
  first_name VARCHAR(100) DEFAULT NULL,
  last_name VARCHAR(100) DEFAULT NULL,
  title VARCHAR(100) DEFAULT NULL,
  photo VARCHAR(255) DEFAULT NULL,
  department VARCHAR(255) DEFAULT NULL,
  do_not_call BOOLEAN DEFAULT FALSE,
  phone_home VARCHAR(100) DEFAULT NULL,
  phone_mobile VARCHAR(100) DEFAULT NULL,
  phone_work VARCHAR(100) DEFAULT NULL,
  phone_other VARCHAR(100) DEFAULT NULL,
  phone_fax VARCHAR(100) DEFAULT NULL,
  lawful_basis TEXT DEFAULT NULL,
  date_reviewed DATE DEFAULT NULL,
  lawful_basis_source VARCHAR(100) DEFAULT NULL,
  primary_address_street VARCHAR(150) DEFAULT NULL,
  primary_address_city VARCHAR(100) DEFAULT NULL,
  primary_address_state VARCHAR(100) DEFAULT NULL,
  primary_address_postalcode VARCHAR(20) DEFAULT NULL,
  primary_address_country VARCHAR(255) DEFAULT NULL,
  alt_address_street VARCHAR(150) DEFAULT NULL,
  alt_address_city VARCHAR(100) DEFAULT NULL,
  alt_address_state VARCHAR(100) DEFAULT NULL,
  alt_address_postalcode VARCHAR(20) DEFAULT NULL,
  alt_address_country VARCHAR(255) DEFAULT NULL,
  assistant VARCHAR(75) DEFAULT NULL,
  assistant_phone VARCHAR(100) DEFAULT NULL,
  tracker_key SERIAL,
  birthdate DATE DEFAULT NULL,
  lead_id UUID DEFAULT NULL,
  account_name VARCHAR(150) DEFAULT NULL,
  campaign_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS prospect_auto_tracker_key ON prospects (tracker_key);
CREATE INDEX IF NOT EXISTS idx_prospects_last_first ON prospects (last_name, first_name, deleted);
CREATE INDEX IF NOT EXISTS idx_prospecs_del_last ON prospects (last_name, deleted);
CREATE INDEX IF NOT EXISTS idx_prospects_id_del ON prospects (id, deleted);
CREATE INDEX IF NOT EXISTS idx_prospects_assigned ON prospects (assigned_user_id);

--
-- Table structure for table `prospects_cstm`
--

CREATE TABLE IF NOT EXISTS prospects_cstm (
  id_c UUID NOT NULL,
  jjwg_maps_lng_c REAL DEFAULT 0.00000000,
  jjwg_maps_lat_c REAL DEFAULT 0.00000000,
  jjwg_maps_geocode_status_c VARCHAR(255) DEFAULT NULL,
  jjwg_maps_address_c VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id_c)
);

--
-- Table structure for table `relationships`
--

CREATE TABLE IF NOT EXISTS relationships (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  relationship_name VARCHAR(150) DEFAULT NULL,
  lhs_module VARCHAR(100) DEFAULT NULL,
  lhs_table VARCHAR(64) DEFAULT NULL,
  lhs_key VARCHAR(64) DEFAULT NULL,
  rhs_module VARCHAR(100) DEFAULT NULL,
  rhs_table VARCHAR(64) DEFAULT NULL,
  rhs_key VARCHAR(64) DEFAULT NULL,
  join_table VARCHAR(64) DEFAULT NULL,
  join_key_lhs VARCHAR(64) DEFAULT NULL,
  join_key_rhs VARCHAR(64) DEFAULT NULL,
  relationship_type VARCHAR(64) DEFAULT NULL,
  relationship_role_column VARCHAR(64) DEFAULT NULL,
  relationship_role_column_value VARCHAR(50) DEFAULT NULL,
  reverse BOOLEAN DEFAULT FALSE,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_rel_name ON relationships (relationship_name);

--
-- Table structure for table `releases`
--

CREATE TABLE IF NOT EXISTS releases (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  deleted BOOLEAN DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  name VARCHAR(50) DEFAULT NULL,
  list_order INTEGER DEFAULT NULL,
  status VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_releases ON releases (name, deleted);

--
-- Table structure for table `reminders`
--

CREATE TABLE IF NOT EXISTS reminders (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  popup BOOLEAN DEFAULT NULL,
  email BOOLEAN DEFAULT NULL,
  email_sent BOOLEAN DEFAULT NULL,
  timer_popup VARCHAR(32) DEFAULT NULL,
  timer_email VARCHAR(32) DEFAULT NULL,
  related_event_module VARCHAR(32) DEFAULT NULL,
  related_event_module_id UUID NOT NULL,
  date_willexecute INTEGER DEFAULT -1,
  popup_viewed BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_reminder_name ON reminders (name);
CREATE INDEX IF NOT EXISTS idx_reminder_deleted ON reminders (deleted);
CREATE INDEX IF NOT EXISTS idx_reminder_related_event_module ON reminders (related_event_module);
CREATE INDEX IF NOT EXISTS idx_reminder_related_event_module_id ON reminders (related_event_module_id);

--
-- Table structure for table `reminders_invitees`
--

CREATE TABLE IF NOT EXISTS reminders_invitees (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  reminder_id UUID NOT NULL,
  related_invitee_module VARCHAR(32) DEFAULT NULL,
  related_invitee_module_id UUID NOT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_reminder_invitee_name ON reminders_invitees (name);
CREATE INDEX IF NOT EXISTS idx_reminder_invitee_assigned_user_id ON reminders_invitees (assigned_user_id);
CREATE INDEX IF NOT EXISTS idx_reminder_invitee_reminder_id ON reminders_invitees (reminder_id);
CREATE INDEX IF NOT EXISTS idx_reminder_invitee_related_invitee_module ON reminders_invitees (related_invitee_module);
CREATE INDEX IF NOT EXISTS idx_reminder_invitee_related_invitee_module_id ON reminders_invitees (related_invitee_module_id);

--
-- Table structure for table `roles`
--

CREATE TABLE IF NOT EXISTS roles (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  name VARCHAR(150) DEFAULT NULL,
  description TEXT DEFAULT NULL,
  modules TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_role_id_del ON roles (id, deleted);

--
-- Table structure for table `roles_modules`
--

CREATE TABLE IF NOT EXISTS roles_modules (
  id VARCHAR(36) NOT NULL,
  role_id VARCHAR(36) DEFAULT NULL,
  module_id VARCHAR(36) DEFAULT NULL,
  allow BOOLEAN DEFAULT FALSE,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_role_id ON roles_modules (role_id);
CREATE INDEX IF NOT EXISTS idx_module_id ON roles_modules (module_id);

--
-- Table structure for table `roles_users`
--

CREATE TABLE IF NOT EXISTS roles_users (
  id VARCHAR(36) NOT NULL,
  role_id VARCHAR(36) DEFAULT NULL,
  user_id VARCHAR(36) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_ru_role_id ON roles_users (role_id);
CREATE INDEX IF NOT EXISTS idx_ru_user_id ON roles_users (user_id);

--
-- Table structure for table `saved_search`
--

CREATE TABLE IF NOT EXISTS saved_search (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(150) DEFAULT NULL,
  search_module VARCHAR(150) DEFAULT NULL,
  quick_filter BOOLEAN DEFAULT NULL,
  deleted BOOLEAN DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  assigned_user_id UUID DEFAULT NULL,
  contents TEXT DEFAULT NULL,
  description TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_desc ON saved_search (name, deleted);

--
-- Table structure for table `schedulers`
--

CREATE TABLE IF NOT EXISTS schedulers (
  id VARCHAR(36) NOT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  name VARCHAR(255) DEFAULT NULL,
  job VARCHAR(255) DEFAULT NULL,
  date_time_start TIMESTAMP DEFAULT NULL,
  date_time_end TIMESTAMP DEFAULT NULL,
  job_interval VARCHAR(100) DEFAULT NULL,
  time_from TIME DEFAULT NULL,
  time_to TIME DEFAULT NULL,
  last_run TIMESTAMP DEFAULT NULL,
  status VARCHAR(100) DEFAULT NULL,
  catch_up BOOLEAN DEFAULT TRUE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_schedule ON schedulers (date_time_start, deleted);

--
-- Table structure for table `securitygroups`
--

CREATE TABLE IF NOT EXISTS securitygroups (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  noninheritable BOOLEAN DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `securitygroups_acl_roles`
--

CREATE TABLE IF NOT EXISTS securitygroups_acl_roles (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  securitygroup_id UUID DEFAULT NULL,
  role_id UUID DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

--
-- Table structure for table `securitygroups_audit`
--

CREATE TABLE IF NOT EXISTS securitygroups_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_securitygroups_parent_id ON securitygroups_audit (parent_id);

--
-- Table structure for table `securitygroups_default`
--

CREATE TABLE IF NOT EXISTS securitygroups_default (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  securitygroup_id UUID DEFAULT NULL,
  module VARCHAR(50) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

--
-- Table structure for table `securitygroups_records`
--

CREATE TABLE IF NOT EXISTS securitygroups_records (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  securitygroup_id UUID DEFAULT NULL,
  record_id UUID DEFAULT NULL,
  module VARCHAR(100) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_securitygroups_records_mod ON securitygroups_records (module, deleted, record_id, securitygroup_id);
CREATE INDEX IF NOT EXISTS idx_securitygroups_records_del ON securitygroups_records (deleted, record_id, module, securitygroup_id);

--
-- Table structure for table `securitygroups_users`
--

CREATE TABLE IF NOT EXISTS securitygroups_users (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  securitygroup_id VARCHAR(36) DEFAULT NULL,
  user_id VARCHAR(36) DEFAULT NULL,
  primary_group BOOLEAN DEFAULT NULL,
  noninheritable BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS securitygroups_users_idxa ON securitygroups_users (securitygroup_id);
CREATE INDEX IF NOT EXISTS securitygroups_users_idxb ON securitygroups_users (user_id);
CREATE INDEX IF NOT EXISTS securitygroups_users_idxc ON securitygroups_users (user_id, deleted, securitygroup_id, id);
CREATE INDEX IF NOT EXISTS securitygroups_users_idxd ON securitygroups_users (user_id, deleted, securitygroup_id);

--
-- Table structure for table `sugarfeed`
--

CREATE TABLE IF NOT EXISTS sugarfeed (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  related_module VARCHAR(100) DEFAULT NULL,
  related_id UUID DEFAULT NULL,
  link_url VARCHAR(255) DEFAULT NULL,
  link_type VARCHAR(30) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS sgrfeed_date ON sugarfeed (date_entered, deleted);

--
-- Table structure for table `surveyquestionoptions`
--

CREATE TABLE IF NOT EXISTS surveyquestionoptions (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  sort_order INTEGER DEFAULT NULL,
  survey_question_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `surveyquestionoptions_audit`
--

CREATE TABLE IF NOT EXISTS surveyquestionoptions_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_surveyquestionoptions_parent_id ON surveyquestionoptions_audit (parent_id);

--
-- Table structure for table `surveyquestionoptions_surveyquestionresponses`
--

CREATE TABLE IF NOT EXISTS surveyquestionoptions_surveyquestionresponses (
  id VARCHAR(36) NOT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  surveyq72c7options_ida VARCHAR(36) DEFAULT NULL,
  surveyq10d4sponses_idb VARCHAR(36) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS surveyquestionoptions_surveyquestionresponses_alt ON surveyquestionoptions_surveyquestionresponses (surveyq72c7options_ida, surveyq10d4sponses_idb);

--
-- Table structure for table `surveyquestionresponses`
--

CREATE TABLE IF NOT EXISTS surveyquestionresponses (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  answer TEXT DEFAULT NULL,
  answer_bool BOOLEAN DEFAULT NULL,
  answer_datetime TIMESTAMP DEFAULT NULL,
  surveyquestion_id UUID DEFAULT NULL,
  surveyresponse_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `surveyquestionresponses_audit`
--

CREATE TABLE IF NOT EXISTS surveyquestionresponses_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_surveyquestionresponses_parent_id ON surveyquestionresponses_audit (parent_id);

--
-- Table structure for table `surveyquestions`
--

CREATE TABLE IF NOT EXISTS surveyquestions (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  sort_order INTEGER DEFAULT NULL,
  type VARCHAR(100) DEFAULT NULL,
  happiness_question BOOLEAN DEFAULT NULL,
  survey_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `surveyquestions_audit`
--

CREATE TABLE IF NOT EXISTS surveyquestions_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_surveyquestions_parent_id ON surveyquestions_audit (parent_id);

--
-- Table structure for table `surveyresponses`
--

CREATE TABLE IF NOT EXISTS surveyresponses (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  happiness INTEGER DEFAULT NULL,
  email_response_sent BOOLEAN DEFAULT NULL,
  account_id UUID DEFAULT NULL,
  campaign_id UUID DEFAULT NULL,
  contact_id UUID DEFAULT NULL,
  survey_id UUID DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `surveyresponses_audit`
--

CREATE TABLE IF NOT EXISTS surveyresponses_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_surveyresponses_parent_id ON surveyresponses_audit (parent_id);

--
-- Table structure for table `surveys`
--

CREATE TABLE IF NOT EXISTS surveys (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  status VARCHAR(100) DEFAULT 'LBL_DRAFT',
  submit_text VARCHAR(255) DEFAULT 'Submit',
  satisfied_text VARCHAR(255) DEFAULT 'Satisfied',
  neither_text VARCHAR(255) DEFAULT 'Neither Satisfied nor Dissatisfied',
  dissatisfied_text VARCHAR(255) DEFAULT 'Dissatisfied',
  PRIMARY KEY (id)
);

--
-- Table structure for table `surveys_audit`
--

CREATE TABLE IF NOT EXISTS surveys_audit (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  parent_id UUID NOT NULL,
  date_created TIMESTAMP DEFAULT NULL,
  created_by VARCHAR(36) DEFAULT NULL,
  field_name VARCHAR(100) DEFAULT NULL,
  data_type VARCHAR(100) DEFAULT NULL,
  before_value_string VARCHAR(255) DEFAULT NULL,
  after_value_string VARCHAR(255) DEFAULT NULL,
  before_value_text TEXT DEFAULT NULL,
  after_value_text TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_surveys_parent_id ON surveys_audit (parent_id);

--
-- Table structure for table `tasks`
--

CREATE TABLE IF NOT EXISTS tasks (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(50) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  assigned_user_id UUID DEFAULT NULL,
  status VARCHAR(100) DEFAULT 'Not Started',
  date_due_flag BOOLEAN DEFAULT FALSE,
  date_due TIMESTAMP DEFAULT NULL,
  date_start_flag BOOLEAN DEFAULT FALSE,
  date_start TIMESTAMP DEFAULT NULL,
  parent_type VARCHAR(255) DEFAULT NULL,
  parent_id UUID DEFAULT NULL,
  contact_id UUID DEFAULT NULL,
  priority VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_tsk_name ON tasks (name);
CREATE INDEX IF NOT EXISTS idx_task_con_del ON tasks (contact_id, deleted);
CREATE INDEX IF NOT EXISTS idx_task_par_del ON tasks (parent_id, parent_type, deleted);
CREATE INDEX IF NOT EXISTS idx_task_assigned ON tasks (assigned_user_id);
CREATE INDEX IF NOT EXISTS idx_task_status ON tasks (status);

--
-- Table structure for table `templatesectionline`
--

CREATE TABLE IF NOT EXISTS templatesectionline (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  name VARCHAR(255) DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  description TEXT DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  thumbnail VARCHAR(255) DEFAULT NULL,
  grp VARCHAR(255) DEFAULT NULL,
  ord INTEGER DEFAULT NULL,
  PRIMARY KEY (id)
);

--
-- Table structure for table `tracker`
--

CREATE TABLE IF NOT EXISTS tracker (
  id SERIAL,
  monitor_id UUID NOT NULL,
  user_id VARCHAR(36) DEFAULT NULL,
  module_name VARCHAR(255) DEFAULT NULL,
  item_id VARCHAR(36) DEFAULT NULL,
  item_summary VARCHAR(255) DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  action VARCHAR(255) DEFAULT NULL,
  session_id VARCHAR(36) DEFAULT NULL,
  visible BOOLEAN DEFAULT FALSE,
  deleted BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_tracker_iid ON tracker (item_id);
CREATE INDEX IF NOT EXISTS idx_tracker_userid_vis_id ON tracker (user_id, visible, id);
CREATE INDEX IF NOT EXISTS idx_tracker_userid_itemid_vis ON tracker (user_id, item_id, visible);
CREATE INDEX IF NOT EXISTS idx_tracker_monitor_id ON tracker (monitor_id);
CREATE INDEX IF NOT EXISTS idx_tracker_date_modified ON tracker (date_modified);

--
-- Table structure for table `upgrade_history`
--

CREATE TABLE IF NOT EXISTS upgrade_history (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  filename VARCHAR(255) DEFAULT NULL,
  md5sum VARCHAR(32) DEFAULT NULL,
  type VARCHAR(30) DEFAULT NULL,
  status VARCHAR(50) DEFAULT NULL,
  version VARCHAR(64) DEFAULT NULL,
  name VARCHAR(255) DEFAULT NULL,
  description TEXT DEFAULT NULL,
  id_name VARCHAR(255) DEFAULT NULL,
  manifest TEXT DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  enabled BOOLEAN DEFAULT TRUE,
  PRIMARY KEY (id),
  UNIQUE (md5sum)
);

--
-- Table structure for table `user_preferences`
--

CREATE TABLE IF NOT EXISTS user_preferences (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  category VARCHAR(50) DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  assigned_user_id UUID DEFAULT NULL,
  contents TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_userprefnamecat ON user_preferences (assigned_user_id, category);

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS users (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  user_name VARCHAR(60) DEFAULT NULL,
  user_hash VARCHAR(255) DEFAULT NULL,
  system_generated_password BOOLEAN DEFAULT NULL,
  pwd_last_changed TIMESTAMP DEFAULT NULL,
  authenticate_id VARCHAR(100) DEFAULT NULL,
  sugar_login BOOLEAN DEFAULT TRUE,
  first_name VARCHAR(255) DEFAULT NULL,
  last_name VARCHAR(255) DEFAULT NULL,
  is_admin BOOLEAN DEFAULT FALSE,
  external_auth_only BOOLEAN DEFAULT FALSE,
  receive_notifications BOOLEAN DEFAULT TRUE,
  description TEXT DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  modified_user_id UUID DEFAULT NULL,
  created_by UUID DEFAULT NULL,
  title VARCHAR(50) DEFAULT NULL,
  photo VARCHAR(255) DEFAULT NULL,
  department VARCHAR(50) DEFAULT NULL,
  phone_home VARCHAR(50) DEFAULT NULL,
  phone_mobile VARCHAR(50) DEFAULT NULL,
  phone_work VARCHAR(50) DEFAULT NULL,
  phone_other VARCHAR(50) DEFAULT NULL,
  phone_fax VARCHAR(50) DEFAULT NULL,
  status VARCHAR(100) DEFAULT NULL,
  address_street VARCHAR(150) DEFAULT NULL,
  address_city VARCHAR(100) DEFAULT NULL,
  address_state VARCHAR(100) DEFAULT NULL,
  address_country VARCHAR(100) DEFAULT NULL,
  address_postalcode VARCHAR(20) DEFAULT NULL,
  deleted BOOLEAN DEFAULT NULL,
  portal_only BOOLEAN DEFAULT FALSE,
  show_on_employees BOOLEAN DEFAULT TRUE,
  employee_status VARCHAR(100) DEFAULT NULL,
  messenger_id VARCHAR(100) DEFAULT NULL,
  messenger_type VARCHAR(100) DEFAULT NULL,
  reports_to_id UUID DEFAULT NULL,
  is_group BOOLEAN DEFAULT NULL,
  factor_auth BOOLEAN DEFAULT NULL,
  factor_auth_interface VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_user_name ON users (user_name, is_group, status, last_name, first_name, id);

--
-- Table structure for table `users_feeds`
--

CREATE TABLE IF NOT EXISTS users_feeds (
  user_id VARCHAR(36) DEFAULT NULL,
  feed_id VARCHAR(36) DEFAULT NULL,
  rank INTEGER DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_ud_user_id ON users_feeds (user_id, feed_id);

--
-- Table structure for table `users_last_import`
--

CREATE TABLE IF NOT EXISTS users_last_import (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  assigned_user_id UUID DEFAULT NULL,
  import_module VARCHAR(36) DEFAULT NULL,
  bean_type VARCHAR(36) DEFAULT NULL,
  bean_id UUID DEFAULT NULL,
  deleted BOOLEAN DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_user_id ON users_last_import (assigned_user_id);

--
-- Table structure for table `users_password_link`
--

CREATE TABLE IF NOT EXISTS users_password_link (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  keyhash VARCHAR(255) DEFAULT NULL,
  user_id VARCHAR(36) DEFAULT NULL,
  username VARCHAR(36) DEFAULT NULL,
  date_generated TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_username ON users_password_link (username);

--
-- Table structure for table `users_signatures`
--

CREATE TABLE IF NOT EXISTS users_signatures (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  deleted BOOLEAN DEFAULT NULL,
  user_id VARCHAR(36) DEFAULT NULL,
  name VARCHAR(255) DEFAULT NULL,
  signature TEXT DEFAULT NULL,
  signature_html TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_usersig_uid ON users_signatures (user_id);

--
-- Table structure for table `vcals`
--

CREATE TABLE IF NOT EXISTS vcals (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  deleted BOOLEAN DEFAULT NULL,
  date_entered TIMESTAMP DEFAULT NULL,
  date_modified TIMESTAMP DEFAULT NULL,
  user_id UUID NOT NULL,
  type VARCHAR(100) DEFAULT NULL,
  source VARCHAR(100) DEFAULT NULL,
  content TEXT DEFAULT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_vcal ON vcals (type, user_id);