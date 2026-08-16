import os
import psycopg2
from flask import Flask, render_template_string, request, redirect, url_for, session, jsonify

app = Flask(__name__)
app.secret_key = os.environ.get('ERP_SECRET_KEY', 'nexus_core_dc_master_secret_2026')

DB_HOST = os.environ.get('DB_HOST', '10.0.3.20')
DB_NAME = os.environ.get('DB_NAME', 'nexus_prod')
DB_USER = os.environ.get('DB_USER', 'nexus_admin')
DB_PASS = os.environ.get('DB_PASSWORD', 'Nexu$Prod2026!Sec')

def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            connect_timeout=3
        )
        return conn
    except Exception as e:
        return None

ERP_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nexus Enterprise ERP & Data Center Intranet</title>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg: #090d16;
            --panel: #111827;
            --border: #1f2937;
            --accent: #6366f1;
            --accent-glow: #818cf8;
            --text: #e5e7eb;
            --muted: #9ca3af;
            --success: #10b981;
            --danger: #ef4444;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background-color: var(--bg); color: var(--text); }

        .top-bar { background: #030712; border-bottom: 1px solid var(--border); padding: 0.75rem 2rem; display: flex; justify-content: space-between; align-items: center; }
        .brand { font-family: 'JetBrains Mono', monospace; font-size: 1.1rem; font-weight: 700; color: var(--accent-glow); }
        .sec-level { background: #371b22; color: #f87171; border: 1px solid #7f1d1d; font-size: 0.75rem; padding: 0.2rem 0.6rem; border-radius: 4px; font-weight: 600; }

        .container { max-width: 1300px; margin: 2rem auto; padding: 0 1.5rem; }
        .grid { display: grid; grid-template-columns: 280px 1fr; gap: 1.5rem; }

        .sidebar { background: var(--panel); border: 1px solid var(--border); border-radius: 8px; padding: 1.5rem; }
        .sidebar h4 { color: var(--muted); text-transform: uppercase; font-size: 0.75rem; letter-spacing: 0.05em; margin-bottom: 1rem; }
        .nav-item { display: block; padding: 0.6rem 0.8rem; color: var(--text); text-decoration: none; border-radius: 6px; font-size: 0.9rem; margin-bottom: 0.3rem; transition: background 0.2s; }
        .nav-item:hover, .nav-item.active { background: #1f2937; color: var(--accent-glow); }

        .main-content { background: var(--panel); border: 1px solid var(--border); border-radius: 8px; padding: 2rem; }
        .page-header { margin-bottom: 1.5rem; border-bottom: 1px solid var(--border); padding-bottom: 1rem; display: flex; justify-content: space-between; align-items: center; }
        
        table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
        th, td { padding: 0.75rem 1rem; text-align: left; border-bottom: 1px solid #1f2937; font-size: 0.9rem; }
        th { background: #0f172a; color: var(--muted); font-weight: 600; }
        tr:hover td { background: rgba(255, 255, 255, 0.02); }

        .badge { display: inline-block; padding: 0.2rem 0.5rem; border-radius: 4px; font-size: 0.75rem; font-weight: 600; }
        .badge-admin { background: #451a03; color: #fbbf24; border: 1px solid #78350f; }
        .badge-user { background: #064e3b; color: #34d399; border: 1px solid #065f46; }

        .alert-box { background: #1e1b4b; border: 1px solid #3730a3; padding: 1rem; border-radius: 6px; margin-bottom: 1.5rem; font-size: 0.9rem; }
        code { font-family: 'JetBrains Mono', monospace; background: #030712; padding: 0.2rem 0.4rem; border-radius: 4px; color: #38bdf8; }
    </style>
</head>
<body>

    <div class="top-bar">
        <div class="brand">🔒 NEXUS INTERNAL INTRANET [DC-TIER-0]</div>
        <div>
            <span class="sec-level">RESTRICTED DC PRODUCTION ACCESS</span>
            <span style="font-size: 0.85rem; margin-left: 1rem; color: var(--muted);">Node: <code>10.0.3.10</code></span>
        </div>
    </div>

    <div class="container">
        <div class="grid">
            <div class="sidebar">
                <h4>Data Center Navigation</h4>
                <a href="/employees" class="nav-item {% if view == 'employees' %}active{% endif %}">👥 Employee Directory</a>
                <a href="/payroll" class="nav-item {% if view == 'payroll' %}active{% endif %}">💳 Payroll & Compensation</a>
                <a href="/servers" class="nav-item {% if view == 'servers' %}active{% endif %}">🖥️ Core DC Server Assets</a>
                <a href="/api/v1/tokens" class="nav-item {% if view == 'tokens' %}active{% endif %}">🔑 Master API & Vault Keys</a>
            </div>

            <div class="main-content">
                {% if view == 'employees' %}
                <div class="page-header">
                    <h2>Global Workforce & IAM Directory</h2>
                    <span style="color: var(--muted); font-size: 0.9rem;">Synced with <code>nexus.internal</code> AD-DC</span>
                </div>
                <div class="alert-box">
                    💡 <strong>LDAP Sync Status:</strong> All accounts synchronized with Active Directory Primary Domain Controller (<code>10.0.2.10</code>).
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>EMP ID</th>
                            <th>Full Name</th>
                            <th>AD Username</th>
                            <th>Role / Department</th>
                            <th>Email</th>
                            <th>Privilege Level</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for emp in data %}
                        <tr>
                            <td><code>{{ emp[0] }}</code></td>
                            <td><strong>{{ emp[1] }}</strong></td>
                            <td><code>{{ emp[2] }}</code></td>
                            <td>{{ emp[3] }}</td>
                            <td>{{ emp[4] }}</td>
                            <td><span class="badge {% if emp[5] == 'Domain Admin' %}badge-admin{% else %}badge-user{% endif %}">{{ emp[5] }}</span></td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>

                {% elif view == 'payroll' %}
                <div class="page-header">
                    <h2>Executive & Staff Payroll Ledger</h2>
                    <span style="color: #ef4444; font-size: 0.9rem;">CONFIDENTIAL - LEVEL 4 CLEARANCE</span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Account #</th>
                            <th>Beneficiary</th>
                            <th>Monthly Salary</th>
                            <th>Bank Routing</th>
                            <th>SWIFT Code</th>
                            <th>Payment Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for pay in data %}
                        <tr>
                            <td><code>{{ pay[0] }}</code></td>
                            <td>{{ pay[1] }}</td>
                            <td style="color: #34d399; font-weight: 600;">{{ pay[2] }}</td>
                            <td><code>{{ pay[3] }}</code></td>
                            <td><code>{{ pay[4] }}</code></td>
                            <td><span style="color: #60a5fa;">{{ pay[5] }}</span></td>
                        </tr>
                        {% endfor %}
                    </tbody>
                </table>

                {% elif view == 'servers' %}
                <div class="page-header">
                    <h2>Core Data Center Asset Inventory</h2>
                    <span style="color: var(--muted); font-size: 0.9rem;">Data Center Spine-Leaf Fabric</span>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Hostname</th>
                            <th>Internal IP</th>
                            <th>Subnet Zone</th>
                            <th>Role / OS</th>
                            <th>Service Ports</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr><td><code>edge-gw-01</code></td><td>198.51.100.1 / 10.0.1.1</td><td>WAN / DMZ Gateway</td><td>BGP / Edge Router</td><td>22, 179</td></tr>
                        <tr><td><code>fw-perimeter-01</code></td><td>10.0.1.254 / 10.0.2.1</td><td>DMZ / Core Firewall</td><td>Next-Gen Firewall</td><td>N/A</td></tr>
                        <tr><td><code>srv-waf-proxy</code></td><td>10.0.1.10</td><td>DMZ Public Web</td><td>Nginx WAF Proxy</td><td>80, 443</td></tr>
                        <tr><td><code>srv-mail-01</code></td><td>10.0.1.30</td><td>DMZ Mail Gateway</td><td>SMTP & Webmail</td><td>25, 8025</td></tr>
                        <tr><td><code>dc01.nexus.internal</code></td><td>10.0.2.10</td><td>Core Backbone</td><td>Samba4 Active Directory DC</td><td>53, 88, 389, 445</td></tr>
                        <tr><td><code>siem-soc-01</code></td><td>10.0.2.99</td><td>Core Security</td><td>Wazuh / Syslog SOC</td><td>514, 9200</td></tr>
                        <tr><td><code>db-prod-01</code></td><td>10.0.3.20</td><td>Data Center</td><td>PostgreSQL 15 Cluster</td><td>5432</td></tr>
                        <tr><td><code>san-backup-01</code></td><td>10.0.3.30</td><td>Data Center Storage</td><td>MinIO S3 / SMB SAN Storage</td><td>9000, 445</td></tr>
                        <tr><td><code>pc-hr-01</code></td><td>10.0.4.10</td><td>Campus Workstation</td><td>Linux Client (HR Department)</td><td>22</td></tr>
                        <tr><td><code>pc-dev-01</code></td><td>10.0.4.20</td><td>Campus Workstation</td><td>Linux Client (DevOps Engineering)</td><td>22</td></tr>
                    </tbody>
                </table>

                {% elif view == 'tokens' %}
                <div class="page-header">
                    <h2>Infrastructure Master Secrets & API Keys</h2>
                    <span style="color: #f59e0b; font-size: 0.9rem;">RESTRICTED TO DOMAIN & CLOUD ADMINS</span>
                </div>
                <div class="alert-box" style="border-color: #d97706; background: #451a03;">
                    ⚠️ <strong>CRITICAL CROWN JEWELS:</strong> Target for Red Team assessment validation.
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Key Identifier</th>
                            <th>Scope / Service</th>
                            <th>Secret Value</th>
                            <th>Assigned Lead</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr><td><code>AWS_DC_TRANSIT_GATEWAY_KEY</code></td><td>AWS Cloud Peering</td><td><code>AKIA-NEXUS-PROD-9812448109-SECKEY-ALPHA</code></td><td>Cloud Ops Lead</td></tr>
                        <tr><td><code>SWIFT_INTERBANK_API_TOKEN</code></td><td>Financial Clearing API</td><td><code>jwt_live_nexus_swift_bank_tx_881920194012948102</code></td><td>CFO / Finance Admin</td></tr>
                        <tr><td><code>SAN_MASTER_ROOT_ACCESS</code></td><td>MinIO SAN Backup SAN-01</td><td><code>nexus_san_root:SuperS3cUr3_B4ckup_Vault_Pass_2026!</code></td><td>Systems Architect</td></tr>
                        <tr><td><code>FLAG_CROWN_JEWELS_DC</code></td><td>CTF / Lab Validation Flag</td><td><code>FLAG{N3XUS_ENT3RPR1S3_D4T4C3NT3R_C0MPR0M1S3D_2026}</code></td><td>Instructor Root</td></tr>
                    </tbody>
                </table>
                {% endif %}
            </div>
        </div>
    </div>

</body>
</html>
"""

@app.route('/')
def home():
    return redirect(url_for('view_employees'))

@app.route('/employees')
def view_employees():
    conn = get_db_connection()
    employees = []
    if conn:
        cursor = conn.cursor()
        cursor.execute("SELECT emp_id, full_name, username, department, email, privilege_level FROM employees ORDER BY id ASC")
        employees = cursor.fetchall()
        conn.close()
    else:
        # Fallback if DB initializing
        employees = [
            ("EMP-001", "Marcus Vance", "mvance", "Chief Information Security Officer", "mvance@nexus.internal", "Domain Admin"),
            ("EMP-002", "Elena Rostova", "erostova", "Lead Systems Architect", "erostova@nexus.internal", "Domain Admin"),
            ("EMP-003", "Tanvir Ahmed", "tahmed", "Senior DevOps Engineer", "tahmed@nexus.internal", "Domain User"),
            ("EMP-004", "Sarah Jenkins", "sjenkins", "HR Director", "sjenkins@nexus.internal", "Domain User"),
            ("EMP-005", "Service Account SQL", "svc_sqlprod", "Database Service Agent", "svc_sql@nexus.internal", "Service Account (Kerberoastable)")
        ]
    return render_template_string(ERP_HTML, view='employees', data=employees)

@app.route('/payroll')
def view_payroll():
    conn = get_db_connection()
    payroll_records = []
    if conn:
        cursor = conn.cursor()
        cursor.execute("SELECT account_num, beneficiary, monthly_salary, bank_routing, swift_code, status FROM payroll ORDER BY id ASC")
        payroll_records = cursor.fetchall()
        conn.close()
    else:
        payroll_records = [
            ("ACC-889102-USD", "Marcus Vance (CISO)", "$18,500.00", "021000021", "CHASUS33", "PAID"),
            ("ACC-551928-EUR", "Elena Rostova (Lead Arch)", "€14,200.00", "050000000", "DEUTDEDB", "PAID"),
            ("ACC-221940-BDT", "Tanvir Ahmed (DevOps)", "৳3,20,000.00", "010271638", "EBLDBDDH", "PAID"),
            ("ACC-119482-USD", "Sarah Jenkins (HR Dir)", "$11,800.00", "021000021", "CHASUS33", "PAID")
        ]
    return render_template_string(ERP_HTML, view='payroll', data=payroll_records)

@app.route('/servers')
def view_servers():
    return render_template_string(ERP_HTML, view='servers', data=[])

@app.route('/api/v1/tokens')
def view_tokens():
    return render_template_string(ERP_HTML, view='tokens', data=[])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=False)
