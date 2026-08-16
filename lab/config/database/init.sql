-- ============================================================
-- Nexus Global Enterprise — Production Database Seed Script
-- Target:  db-prod-01.dc.nexus.internal (10.0.3.20:5432)
-- DB Name: nexus_prod
-- ============================================================

-- Core Identity & Access tables
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    emp_id VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    department VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    privilege_level VARCHAR(60) NOT NULL,
    account_status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payroll (
    id SERIAL PRIMARY KEY,
    account_num VARCHAR(50) NOT NULL,
    beneficiary VARCHAR(100) NOT NULL,
    monthly_salary VARCHAR(50) NOT NULL,
    bank_routing VARCHAR(50) NOT NULL,
    swift_code VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'PAID'
);

CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    customer_code VARCHAR(30) UNIQUE NOT NULL,
    company_name VARCHAR(150) NOT NULL,
    contact_person VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    billing_card_masked VARCHAR(30) NOT NULL,
    service_tier VARCHAR(30) NOT NULL,
    annual_contract_value VARCHAR(30) NOT NULL
);

-- Crown Jewels: Infrastructure vault secrets and CTF flags
CREATE TABLE IF NOT EXISTS system_vault_keys (
    id SERIAL PRIMARY KEY,
    key_name VARCHAR(100) NOT NULL,
    service_scope VARCHAR(100) NOT NULL,
    encrypted_secret TEXT NOT NULL,
    assigned_to VARCHAR(100),
    last_rotated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- API Key registry (realistic cloud/service keys)
CREATE TABLE IF NOT EXISTS api_keys (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    environment VARCHAR(20) NOT NULL,
    api_key TEXT NOT NULL,
    secret TEXT NOT NULL,
    owner VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at VARCHAR(30)
);

-- Audit log — realistic authentication and access events for Blue-Team/White-Box analysis
CREATE TABLE IF NOT EXISTS audit_log (
    id SERIAL PRIMARY KEY,
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_type VARCHAR(50) NOT NULL,
    username VARCHAR(100) NOT NULL,
    source_ip VARCHAR(45),
    target_resource VARCHAR(200),
    result VARCHAR(20),
    details TEXT
);

-- Network configuration table — infrastructure asset register
CREATE TABLE IF NOT EXISTS network_configs (
    id SERIAL PRIMARY KEY,
    hostname VARCHAR(100) NOT NULL,
    management_ip VARCHAR(45),
    zone VARCHAR(30),
    device_role VARCHAR(100),
    os_version VARCHAR(100),
    management_password TEXT,
    last_audit TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Incident reports — historical security incidents for Blue-Team context
CREATE TABLE IF NOT EXISTS incident_reports (
    id SERIAL PRIMARY KEY,
    incident_id VARCHAR(30) NOT NULL,
    date_reported TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    severity VARCHAR(20) NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    affected_systems TEXT,
    remediation TEXT,
    status VARCHAR(30) DEFAULT 'CLOSED',
    reported_by VARCHAR(100)
);

-- ──────────────────────────────────────────────────────────────
-- SEED DATA
-- ──────────────────────────────────────────────────────────────

-- Employees
INSERT INTO employees (emp_id, full_name, username, department, email, privilege_level, account_status) VALUES
('EMP-001', 'Marcus Vance',      'mvance',      'Executive InfoSec',           'mvance@nexus.internal',   'Domain Admin',                   'ACTIVE'),
('EMP-002', 'Elena Rostova',     'erostova',    'Infrastructure Architecture',  'erostova@nexus.internal', 'Domain Admin',                   'ACTIVE'),
('EMP-003', 'Tanvir Ahmed',      'tahmed',      'DevOps & Site Reliability',    'tahmed@nexus.internal',   'Domain User',                    'ACTIVE'),
('EMP-004', 'Sarah Jenkins',     'sjenkins',    'Human Resources',              'sjenkins@nexus.internal', 'Domain User',                    'ACTIVE'),
('EMP-005', 'Amina Rahman',      'arahman',     'Financial Audit',              'arahman@nexus.internal',  'Domain User',                    'ACTIVE'),
('SVC-001', 'SQL Service Agent', 'svc_sqlprod', 'Automation Service Principal', 'svc_sql@nexus.internal',  'Service Account (Kerberoastable)', 'ACTIVE'),
('SVC-002', 'Backup Service',    'svc_backup',  'Storage Automation',           'svc_bkp@nexus.internal',  'Service Account (Kerberoastable)', 'ACTIVE');

-- Payroll
INSERT INTO payroll (account_num, beneficiary, monthly_salary, bank_routing, swift_code, status) VALUES
('ACC-889102-USD', 'Marcus Vance (CISO)',            '$18,500.00',   '021000021', 'CHASUS33',  'PAID'),
('ACC-551928-EUR', 'Elena Rostova (Lead Arch)',       '€14,200.00',  '050000000', 'DEUTDEDB',  'PAID'),
('ACC-221940-BDT', 'Tanvir Ahmed (DevOps)',           '৳3,20,000.00','010271638', 'EBLDBDDH',  'PAID'),
('ACC-119482-USD', 'Sarah Jenkins (HR Dir)',          '$11,800.00',   '021000021', 'CHASUS33',  'PAID'),
('ACC-339180-BDT', 'Amina Rahman (Fin Audit)',        '৳2,40,000.00','010271638', 'EBLDBDDH',  'PAID');

-- Enterprise Customers
INSERT INTO customers (customer_code, company_name, contact_person, email, billing_card_masked, service_tier, annual_contract_value) VALUES
('CUST-88102', 'Deutsche Cloud Solutions GmbH',  'Klaus Weber',   'k.weber@deutsche-cloud.de',   '4532-XXXX-XXXX-9912', 'Enterprise Platinum', '$1,200,000'),
('CUST-77192', 'SingaNet Enterprise Corp',        'Wei Ling Chen', 'chen.wl@singanet.sg',         '5105-XXXX-XXXX-4481', 'Enterprise Gold',     '$850,000'),
('CUST-44180', 'Bengal Telecom International',    'Rafiqul Islam', 'rafiq@bengaltelecom.com',     '4111-XXXX-XXXX-3321', 'Enterprise Platinum', '$2,100,000'),
('CUST-99012', 'Nordic Logistics AS',             'Astrid Lind',   'astrid@nordiclog.no',         '4024-XXXX-XXXX-7719', 'Enterprise Standard', '$450,000'),
('CUST-33891', 'UK FinTech Corp Ltd',             'James Harlow',  'j.harlow@ukfintech.co.uk',    '4539-XXXX-XXXX-2281', 'Enterprise Gold',     '$720,000');

-- System Vault (Crown Jewels — primary target for final CTF flag)
INSERT INTO system_vault_keys (key_name, service_scope, encrypted_secret, assigned_to) VALUES
('AWS_TRANSIT_GATEWAY_KEY',  'Cloud DC Bridge (AWS HQ)',         'AKIA-NEXUS-PROD-9812448109-SECKEY-ALPHA',               'Cloud Ops Lead (erostova)'),
('SWIFT_CLEARING_API_TOKEN', 'Interbank Wire Gateway (SWIFT)',   'jwt_live_nexus_swift_bank_tx_881920194012948102',        'CFO / Finance (arahman)'),
('SAN_MASTER_ROOT_ACCESS',   'MinIO Backup SAN (10.0.3.30)',     'nexus_san_root:SuperS3cUr3_B4ckup_Vault_Pass_2026!',     'Systems Architect (erostova)'),
('AZURE_SERVICE_PRINCIPAL',  'Azure AD B2B Peering',             'nexus-sp-prod:AzureServicePrincipal#Nexus_2026@DC!',     'Cloud Ops Lead (erostova)'),
('CTF_FLAG_DATABASE_ROOT',   'Red Team Proof of Compromise',     'FLAG{CR0WN_J3W3LS_DC_D4T4B4S3_C0MPR0M1S3D_2026!}',      'Instructor Root Only');

-- API Keys
INSERT INTO api_keys (service_name, environment, api_key, secret, owner, expires_at) VALUES
('AWS S3 Storage (us-east-1)',       'production', 'AKIANEXUSPROD88120312',    'wJalrXUtnFEMI/K7MDENG/bPxRfiCYNEXUSPRODKEY',  'erostova',   '2027-01-01'),
('Stripe Payment Gateway',           'production', 'sk_live_nexus_8812049201', 'pk_live_nexus_201049812_stripe_secret_key_v3', 'arahman',    '2026-12-31'),
('Twilio SMS Alerts',                'production', 'ACnexus0812094810248801',  'nexus_twilio_auth_token_8120498102981029',     'tahmed',     'Never'),
('SendGrid Transactional Email',     'staging',    'SG.nexusstaging.8810249', 'SG.nexus_sendgrid_api_secret_2026_staging',    'tahmed',     '2027-06-01');

-- Audit Log (realistic events for Blue-Team analysis)
INSERT INTO audit_log (event_time, event_type, username, source_ip, target_resource, result, details) VALUES
('2026-08-15 02:14:32', 'LOGIN_SUCCESS',     'tahmed',    '10.0.4.20',     'nexus_prod DB',           'SUCCESS', 'Routine nightly sync script'),
('2026-08-15 03:00:01', 'DB_QUERY',          'svc_backup', '10.0.3.20',    'pg_dump nexus_prod',      'SUCCESS', 'Automated backup job'),
('2026-08-14 11:23:10', 'LOGIN_FAILURE',     'unknown',   '198.51.100.50', 'corp-web-portal /login',  'FAILED',  'Brute-force attempt detected - 34 failures'),
('2026-08-14 11:24:55', 'WAF_BLOCK',         'unknown',   '198.51.100.50', '/admin-console/',         'BLOCKED', 'Unauthorized path probe - blocked by WAF'),
('2026-08-13 18:42:11', 'SMB_SHARE_ACCESS',  'arahman',   '10.0.4.30',     'IT-Backups share',        'SUCCESS', 'Accessed via authenticated SMB session'),
('2026-08-12 09:15:00', 'PRIVILEGE_CHANGE',  'mvance',    '10.0.2.10',     'svc_sqlprod SPN',         'SUCCESS', 'SPN updated: MSSQLSvc/db-prod-01.nexus.internal:5432'),
('2026-08-10 14:30:22', 'CONFIG_CHANGE',     'erostova',  '10.0.2.10',     'LDAP anonymous bind',     'SUCCESS', 'WARNING: LDAP anonymous bind re-enabled for monitoring tool compatibility');

-- Network Configuration (sensitive device credentials — target for network lateral movement)
INSERT INTO network_configs (hostname, management_ip, zone, device_role, os_version, management_password) VALUES
('edge-gw-01',        '198.51.100.1', 'WAN/DMZ',      'BGP Edge Gateway',      'Alpine Linux 3.19 / FRR 9.0',      'EdgeGW_N3xus@2026!'),
('fw-perimeter-01',   '10.0.1.254',   'DMZ/Core FW',  'Stateful NGFW',         'Alpine Linux 3.19 / iptables',     'Firewall_P3rim3t3r#2026'),
('srv-waf-proxy',     '10.0.1.10',    'DMZ',           'WAF Reverse Proxy',    'Nginx 1.25 Enterprise',            'W4F-Proxy_Admin@2026'),
('dc01',              '10.0.2.10',    'Core Backbone', 'Samba AD Domain Ctrl',  'Samba 4.18 / Alpine 3.19',         'NexusDC_Admin_S3cur3!'),
('san-backup-01',     '10.0.3.30',    'Data Center',  'MinIO S3 SAN Storage',  'MinIO RELEASE.2023-09-30',         'SuperS3cUr3_B4ckup_Vault_Pass_2026!');

-- Security Incident Reports (historical context for Blue-Team analysis)
INSERT INTO incident_reports (incident_id, date_reported, severity, title, description, affected_systems, remediation, status, reported_by) VALUES
('INC-2026-0041', '2026-08-14 12:00:00', 'HIGH',   'External Brute-Force on Corp Web Portal',
  'Automated brute-force attack detected from IP 198.51.100.50. 34 failed login attempts in 2 minutes.',
  'corp-web-portal (10.0.1.20), WAF (10.0.1.10)',
  'IP temporarily blocked at WAF. Rate limiting added to login endpoint.',
  'CLOSED', 'SOC Analyst'),
('INC-2026-0039', '2026-07-22 09:15:00', 'MEDIUM', 'LDAP Anonymous Bind Re-enabled',
  'LDAP anonymous bind was re-enabled on dc01 for monitoring tool compatibility. This allows unauthenticated LDAP enumeration of the directory.',
  'dc01.nexus.internal (10.0.2.10)',
  'Accepted risk - monitoring tool requires it. Compensating control: SIEM alerting on excessive LDAP queries.',
  'ACCEPTED_RISK', 'erostova'),
('INC-2026-0031', '2026-06-10 16:30:00', 'CRITICAL','Hardcoded Credentials Found in IT-Backups Share',
  'Audit discovered sync_prod_db.sh on IT-Backups SMB share contains plaintext DB credentials. Share is readable by all domain users.',
  'IT-Backups SMB Share, sync_prod_db.sh',
  'Ticket raised to DevOps (tahmed) to move credentials to vault. PENDING implementation.',
  'OPEN', 'mvance');
