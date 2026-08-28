-- ─────────────────────────────────────────────────────────────────
--  monitoring_db  |  Nexus Global Enterprise Infrastructure DB
--  User: monitor / monitor123
--  INTENTIONALLY VULNERABLE: Contains internal network topology
-- ─────────────────────────────────────────────────────────────────

-- Network inventory table
CREATE TABLE IF NOT EXISTS network_inventory (
    id          SERIAL PRIMARY KEY,
    hostname    VARCHAR(100) NOT NULL,
    ip_address  VARCHAR(20)  NOT NULL,
    subnet      VARCHAR(20),
    zone        VARCHAR(50),
    role        VARCHAR(150),
    os_info     VARCHAR(100),
    last_seen   TIMESTAMP DEFAULT NOW(),
    notes       TEXT
);

INSERT INTO network_inventory (hostname, ip_address, subnet, zone, role, os_info, notes) VALUES
('edge-gw-01.nexus.internal',       '10.0.1.1',    '10.0.1.0/24', 'DMZ',       'BGP Edge Router (ISP1 primary)',      'Linux/Alpine',  'BGP AS65001 - upstream ISP1'),
('srv-waf-proxy.nexus.internal',    '10.0.1.10',   '10.0.1.0/24', 'DMZ',       'Nginx WAF / Reverse Proxy',           'Linux/Alpine',  'Port 80 - proxies to 10.0.1.20'),
('srv-dmz-web01.nexus.internal',    '10.0.1.20',   '10.0.1.0/24', 'DMZ',       'Corporate Web Portal (Flask)',        'Linux/Alpine',  'Port 5000 internal - Flask app'),
('srv-mail-01.nexus.internal',      '10.0.1.30',   '10.0.1.0/24', 'DMZ',       'Corporate Mail Server (MailHog)',     'Linux/Alpine',  'SMTP:1025, Webmail:8025'),
('bastion.nexus.internal',          '10.0.1.40',   '10.0.1.0/24', 'DMZ',       'SSH Bastion Jump Host (multi-homed)', 'Linux/Alpine',  'SSH port 22 (host-mapped: 2222). Reaches 10.0.2.x 10.0.4.x'),
('dc01.nexus.internal',             '10.0.2.10',   '10.0.2.0/24', 'Core',      'Active Directory Domain Controller',  'Linux/Samba4',  'SMB:445 LDAP:389 Kerberos:88 - anonymous SMB noted in Q2 audit'),
('nac-ise-01.nexus.internal',       '10.0.2.15',   '10.0.2.0/24', 'Core',      'NAC / 802.1X Access Control',        'Linux/Alpine',  'API port 8100 - MAC bypass vuln in audit report REF#NAC-2026-03'),
('siem-soc-01.nexus.internal',      '10.0.2.99',   '10.0.2.0/24', 'Core',      'SIEM Syslog Collector (rsyslog)',     'Linux/Alpine',  'UDP 514 syslog'),
('srv-erp-01.nexus.internal',       '10.0.3.10',   '10.0.3.0/24', 'DC',        'Internal ERP Intranet (Flask)',       'Linux/Alpine',  'HTTP port 8000 - internal only'),
('db-prod-01.nexus.internal',       '10.0.3.20',   '10.0.3.0/24', 'DC',        'Production PostgreSQL Database',      'Linux/Alpine',  'Port 5432 - CROWN JEWELS. Creds: see IT-Backups SMB share on DC01'),
('san-backup-01.nexus.internal',    '10.0.3.30',   '10.0.3.0/24', 'DC',        'MinIO SAN Backup Storage',           'Linux/Alpine',  'S3-API:9000 Console:9001'),
('hr-workstation-01.nexus.internal','10.0.4.10',   '10.0.4.0/24', 'Campus',    'HR Workstation (sjenkins)',           'Linux/Alpine',  'SSH:22 - user: sjenkins'),
('dev-workstation-01.nexus.internal','10.0.4.20',  '10.0.4.0/24', 'Campus',    'DevOps Workstation (tahmed)',         'Linux/Alpine',  'SSH:22 - user: tahmed. Has db_creds.env'),
('voip-pbx-01.nexus.internal',      '10.0.4.50',   '10.0.4.0/24', 'Campus',    'VoIP PBX - Asterisk',                'Linux/Alpine',  'SIP UDP/TCP:5060 - brute-force risk noted'),
('ipcam-01.nexus.internal',         '10.0.4.60',   '10.0.4.0/24', 'Campus',    'IP Camera RTSP Server',              'Linux/Alpine',  'RTSP:8554 HLS:8888 - no auth'),
('iot-campus-01.nexus.internal',     '10.0.4.70',   '10.0.4.0/24', 'Campus',    'IoT MQTT Sensor Broker',             'Linux/Alpine',  'MQTT:1883 - unauthenticated broker!');

-- Service endpoint table
CREATE TABLE IF NOT EXISTS service_endpoints (
    id            SERIAL PRIMARY KEY,
    host_ip       VARCHAR(20),
    port          INTEGER,
    protocol      VARCHAR(10),
    service_name  VARCHAR(100),
    auth_required BOOLEAN,
    status        VARCHAR(20) DEFAULT 'UP',
    audit_notes   TEXT
);

INSERT INTO service_endpoints (host_ip, port, protocol, service_name, auth_required, audit_notes) VALUES
('10.0.2.10', 445,  'TCP', 'SMB File Sharing',     FALSE, 'CRITICAL: Anonymous access allowed. IT-Backups share readable without creds.'),
('10.0.2.10', 389,  'TCP', 'LDAP Directory',        FALSE, 'Anonymous bind enabled. Full directory enumerable.'),
('10.0.3.20', 5432, 'TCP', 'PostgreSQL Prod DB',    TRUE,  'Credentials stored in IT-Backups\\sync_prod_db.sh on dc01'),
('10.0.4.70', 1883, 'TCP', 'MQTT Broker',           FALSE, 'NO AUTHENTICATION. Subscribe to # for all topics.'),
('10.0.4.50', 5060, 'UDP', 'SIP VoIP',              TRUE,  'Weak PINs. Use svcrack against extensions 1001-1005.'),
('10.0.2.15', 8100, 'TCP', 'NAC API',               FALSE, 'MAC bypass: POST /api/bypass?mac=XX:XX:XX:XX:XX:XX');

-- Grant access to monitor user
GRANT SELECT ON ALL TABLES IN SCHEMA public TO monitor;
