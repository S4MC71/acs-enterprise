import os
import sqlite3
import subprocess
from functools import wraps
from flask import Flask, render_template_string, request, redirect, url_for, session, jsonify

app = Flask(__name__)
app.secret_key = os.environ.get('FLASK_SECRET_KEY', 'nexus_enterprise_super_secret_session_key_2026')

# ─────────────────────────────────────────────────────────────────────────────
# DATABASE INITIALIZATION
# ─────────────────────────────────────────────────────────────────────────────
def init_db():
    conn = sqlite3.connect('/app/corp_data.db')
    cursor = conn.cursor()

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS tracking_shipments (
            tracking_id TEXT PRIMARY KEY,
            destination TEXT,
            status TEXT,
            estimated_delivery TEXT,
            client_name TEXT,
            customs_clearance TEXT
        )
    ''')
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS portal_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            role TEXT NOT NULL,
            full_name TEXT
        )
    ''')

    # Seed shipments (SQL injection targets — tracking_id field is vulnerable)
    cursor.executemany("INSERT OR IGNORE INTO tracking_shipments VALUES (?,?,?,?,?,?)", [
        ('NX-98231', 'Frankfurt Data Center, Germany',   'In Transit - Customs Cleared',    '2026-08-20', 'Deutsche Cloud Solutions', 'PASSED'),
        ('NX-77142', 'Singapore Regional Hub',           'Delivered to Secure Facility',    '2026-08-14', 'SingaNet Enterprise',      'PASSED'),
        ('NX-11094', 'Dhaka Core IT Hub, Bangladesh',    'Processing at Perimeter Warehouse','2026-08-18', 'Bengal Telecom Ltd',        'UNDER_INSPECTION'),
        ('NX-44801', 'Oslo Logistics Hub, Norway',       'Dispatched - In Flight',          '2026-08-22', 'Nordic Logistics AS',       'PASSED'),
        ('NX-55310', 'London Tier-1 DC, United Kingdom', 'Arrived - Pending Delivery',      '2026-08-19', 'UK FinTech Corp',           'PASSED'),
    ])

    # Portal login credentials (weak passwords for brute-force simulation)
    cursor.executemany("INSERT OR IGNORE INTO portal_users VALUES (NULL,?,?,?,?)", [
        ('admin',   'NexusTechAdmin2026!', 'administrator', 'Portal Administrator'),
        ('logistics','Logistics@2026',     'operator',      'Logistics Operator'),
    ])

    conn.commit()
    conn.close()

# Initialize DB on app startup (works with both direct run and WSGI)
with app.app_context():
    init_db()

# ─────────────────────────────────────────────────────────────────────────────
# AUTH HELPER
# ─────────────────────────────────────────────────────────────────────────────
def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if not session.get('logged_in'):
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated

# ─────────────────────────────────────────────────────────────────────────────
# HTML TEMPLATES
# ─────────────────────────────────────────────────────────────────────────────
LOGIN_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nexus Global Enterprise — Secure Portal Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: #0f172a;
               display: flex; align-items: center; justify-content: center;
               min-height: 100vh; padding: 1rem; }
        .login-box { background: #1e293b; border: 1px solid #334155;
                     border-radius: 1rem; padding: 3rem; width: 100%; max-width: 420px;
                     box-shadow: 0 25px 50px rgba(0,0,0,0.5); }
        .logo { font-size: 1.3rem; font-weight: 800; text-align: center; margin-bottom: 0.5rem;
                background: linear-gradient(135deg, #60a5fa, #a855f7);
                -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .subtitle { text-align: center; color: #64748b; font-size: 0.85rem; margin-bottom: 2rem; }
        label { display: block; color: #94a3b8; font-size: 0.85rem; font-weight: 600;
                margin-bottom: 0.4rem; text-transform: uppercase; letter-spacing: 0.05em; }
        input { width: 100%; padding: 0.85rem 1rem; background: #0f172a; border: 1px solid #475569;
                border-radius: 0.5rem; color: #f8fafc; font-size: 0.95rem;
                margin-bottom: 1.25rem; transition: border-color 0.2s; }
        input:focus { outline: none; border-color: #3b82f6; }
        button { width: 100%; padding: 0.9rem; background: #2563eb; color: #fff; border: none;
                 border-radius: 0.5rem; font-weight: 700; font-size: 1rem; cursor: pointer;
                 transition: background 0.2s; }
        button:hover { background: #1d4ed8; }
        .error { background: #450a0a; border: 1px solid #7f1d1d; color: #fca5a5;
                 padding: 0.75rem 1rem; border-radius: 0.5rem; margin-bottom: 1rem;
                 font-size: 0.9rem; }
        .footer-note { text-align: center; color: #475569; font-size: 0.75rem; margin-top: 1.5rem; }
    </style>
</head>
<body>
    <div class="login-box">
        <div class="logo">⚡ NEXUS GLOBAL ENTERPRISE</div>
        <div class="subtitle">Corporate Supply Chain & Infrastructure Portal<br>Authorized Access Only — Sessions Monitored</div>
        {% if error %}
        <div class="error">⚠️ {{ error }}</div>
        {% endif %}
        <form method="POST" action="/login">
            <label for="username">Domain Username</label>
            <input type="text" id="username" name="username" placeholder="e.g. admin" autocomplete="off" required>
            <label for="password">Password</label>
            <input type="password" id="password" name="password" placeholder="Your portal password" required>
            <button type="submit">Sign In Securely</button>
        </form>
        <div class="footer-note">Nexus Global Enterprise &copy; 2026 | IT Support: it-helpdesk@nexus.internal</div>
    </div>
</body>
</html>
"""

PORTAL_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nexus Global Logistics & Cloud Infrastructure Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #2563eb; --primary-dark: #1d4ed8;
            --dark-bg: #0f172a; --card-bg: #1e293b;
            --text-main: #f8fafc; --text-muted: #94a3b8; --accent: #06b6d4;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background-color: var(--dark-bg); color: var(--text-main); line-height: 1.6; }

        nav { background: rgba(15,23,42,0.95); backdrop-filter: blur(10px);
              border-bottom: 1px solid #334155; padding: 1rem 3rem;
              display: flex; justify-content: space-between; align-items: center;
              position: sticky; top: 0; z-index: 100; }
        .logo { font-size: 1.4rem; font-weight: 700;
                background: linear-gradient(135deg, #60a5fa, #a855f7);
                -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .nav-links { display: flex; gap: 2rem; list-style: none; align-items: center; }
        .nav-links a { color: var(--text-muted); text-decoration: none; font-weight: 500; transition: color 0.2s; }
        .nav-links a:hover { color: #fff; }
        .status-badge { background: #064e3b; color: #34d399; font-size: 0.8rem; padding: 0.25rem 0.75rem; border-radius: 9999px; border: 1px solid #059669; }
        .user-badge { color: #94a3b8; font-size: 0.85rem; margin-right: 1rem; }
        .logout-btn { background: #1e293b; color: #f87171; border: 1px solid #7f1d1d; padding: 0.3rem 0.8rem; border-radius: 6px; text-decoration: none; font-size: 0.8rem; transition: background 0.2s; }
        .logout-btn:hover { background: #450a0a; }

        .hero { padding: 4rem 3rem; text-align: center; max-width: 900px; margin: 0 auto; }
        .hero h1 { font-size: 2.8rem; font-weight: 800; margin-bottom: 1rem; line-height: 1.2; }
        .hero p { font-size: 1.1rem; color: var(--text-muted); margin-bottom: 2.5rem; }

        .search-box { background: var(--card-bg); padding: 2rem; border-radius: 1rem; border: 1px solid #334155; box-shadow: 0 10px 25px rgba(0,0,0,0.3); }
        .search-form { display: flex; gap: 1rem; max-width: 600px; margin: 0 auto; }
        .search-form input { flex: 1; padding: 0.85rem 1.2rem; border-radius: 0.5rem; border: 1px solid #475569; background: #0f172a; color: #fff; font-size: 1rem; }
        .search-form button { padding: 0.85rem 1.8rem; background: var(--primary); color: #fff; border: none; border-radius: 0.5rem; font-weight: 600; cursor: pointer; transition: background 0.2s; }
        .search-form button:hover { background: var(--primary-dark); }
        .result-card { margin-top: 2rem; background: #1e293b; border-left: 4px solid var(--accent); padding: 1.5rem; border-radius: 0.5rem; text-align: left; animation: fadeIn 0.3s ease-in; }

        .features { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 2rem; padding: 3rem; max-width: 1200px; margin: 0 auto; }
        .feature-card { background: var(--card-bg); padding: 2rem; border-radius: 0.75rem; border: 1px solid #334155; }
        .feature-card h3 { margin-bottom: 0.75rem; color: #60a5fa; }

        .network-diag { background: #090d16; border: 1px dashed #475569; border-radius: 0.75rem; padding: 1.5rem; margin-top: 2rem; overflow-x: auto; }
        .network-diag code { font-family: monospace; color: #38bdf8; font-size: 0.85rem; white-space: pre-wrap; word-break: break-all; }
        .diag-section { max-width: 800px; margin: 0 auto 4rem auto; padding: 0 1.5rem; }

        footer { text-align: center; padding: 2.5rem; border-top: 1px solid #1e293b; color: #64748b; font-size: 0.85rem; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

        .flag-hint { background: #1a2a1a; border: 1px solid #166534; color: #86efac; padding: 0.75rem 1rem; border-radius: 6px; font-size: 0.85rem; margin-top: 1rem; font-family: monospace; }
    </style>
</head>
<body>

    <nav>
        <div class="logo">⚡ NEXUS GLOBAL ENTERPRISE</div>
        <ul class="nav-links">
            <li><a href="/">Overview</a></li>
            <li><a href="#tracking">Global Tracking</a></li>
            <li><a href="#diagnostics">Edge Connectivity</a></li>
            <li><a href="http://{{ request.host.split(':')[0] }}:8025" target="_blank">Corporate Webmail</a></li>
        </ul>
        <div style="display:flex; align-items:center;">
            <span class="user-badge">Logged in as: <strong>{{ session.get('username','') }}</strong></span>
            <a href="/logout" class="logout-btn">Sign Out</a>
            <span class="status-badge" style="margin-left:1rem;">● DMZ-01 Operational</span>
        </div>
    </nav>

    <div class="hero">
        <h1>Critical Supply Chain & Hybrid Cloud Backbone</h1>
        <p>Enterprise logistics, mission-critical routing, and global asset management powered by resilient, multi-tiered infrastructure.</p>

        <div class="search-box" id="tracking">
            <h3 style="margin-bottom: 1rem;">Consignment & Hardware Dispatch Tracker</h3>
            <form class="search-form" method="GET" action="/">
                <input type="text" name="track_id" placeholder="Enter Tracking ID (e.g. NX-98231)" value="{{ query|default('', true) }}">
                <button type="submit">Track Asset</button>
            </form>

            {% if shipment %}
            <div class="result-card">
                <h4 style="color: #38bdf8; margin-bottom: 0.5rem;">Shipment Found: {{ shipment[0] }}</h4>
                <p><strong>Destination:</strong> {{ shipment[1] }}</p>
                <p><strong>Status:</strong> <span style="color: #34d399;">{{ shipment[2] }}</span></p>
                <p><strong>Est. Delivery:</strong> {{ shipment[3] }}</p>
                <p><strong>Client Org:</strong> {{ shipment[4] }}</p>
                <p><strong>Customs:</strong> {{ shipment[5] }}</p>
            </div>
            {% elif sqli_result %}
            <div class="result-card" style="border-left-color: #f59e0b;">
                <h4 style="color: #fbbf24;">Database Query Result (Raw Output)</h4>
                {% for row in sqli_result %}
                <p style="font-family: monospace; font-size: 0.85rem; color: #94a3b8;">{{ row }}</p>
                {% endfor %}
                <div class="flag-hint">
                    🚩 FLAG{SQL_1NJ3CT10N_DMZ_W3B_PORTAL_2026} — CTF Flag 1 of 3 — Well done!
                </div>
            </div>
            {% elif query %}
            <div class="result-card" style="border-left-color: #ef4444;">
                <p style="color: #f87171;">No records found for consignment ID: <strong>{{ query }}</strong></p>
            </div>
            {% endif %}
        </div>
    </div>

    <div class="features">
        <div class="feature-card">
            <h3>🔒 Perimeter Security</h3>
            <p>Protected by Next-Gen Edge Firewalls, stateful packet filtering, and zero-trust authentication policies via <code>nexus.internal</code>.</p>
        </div>
        <div class="feature-card">
            <h3>🏢 Active Directory Core</h3>
            <p>Centralized IAM via <code>dc01.nexus.internal</code> (10.0.2.10). SMB shares for SYSVOL, IT scripts, and HR policies.</p>
        </div>
        <div class="feature-card">
            <h3>🗄️ Isolated Data Center</h3>
            <p>Spine-Leaf fabric hosting PostgreSQL (10.0.3.20), ERP intranet (10.0.3.10), and SAN storage (10.0.3.30).</p>
        </div>
    </div>

    <!-- Diagnostic endpoint - intentionally vulnerable command injection -->
    <div class="diag-section" id="diagnostics">
        <div class="feature-card">
            <h3 style="color: #f59e0b;">🛠️ BOC Gateway Ping Diagnostic Tool</h3>
            <p style="color: var(--text-muted); font-size: 0.9rem; margin-bottom: 1rem;">
                Internal network troubleshooting utility for authorized DMZ Edge nodes only.<br>
                <small>Tool v1.2 | Accessible by: <code>srv-waf-proxy</code>, <code>bastion.nexus.internal</code></small>
            </p>
            <form method="POST" action="/api/network/ping" style="display: flex; gap: 0.5rem;">
                <input type="text" name="host" placeholder="Target IP / Hostname (e.g. 10.0.1.1)"
                       style="flex:1; padding: 0.7rem; background: #0f172a; border: 1px solid #475569; color: #fff; border-radius: 4px;">
                <button type="submit" style="padding: 0.7rem 1.2rem; background: #d97706; color: #fff; border: none; border-radius: 4px; font-weight: 600; cursor: pointer;">
                    Send Probe
                </button>
            </form>
            {% if ping_result %}
            <div class="network-diag">
                <code>{{ ping_result }}</code>
            </div>
            {% endif %}
        </div>
    </div>

    <footer>
        <p>&copy; 2026 Nexus Global Logistics & Enterprise Infrastructure. All Rights Reserved.</p>
        <p style="margin-top: 0.5rem; font-size: 0.75rem;">
            DMZ Node: <code>srv-dmz-web01.nexus.internal</code> | Subnet: <code>10.0.1.20</code> |
            WAF: <code>srv-waf-proxy.nexus.internal</code> | Platform: <code>Nexus-Portal v2.4.1</code>
        </p>
    </footer>

</body>
</html>
"""

# ─────────────────────────────────────────────────────────────────────────────
# ROUTES
# ─────────────────────────────────────────────────────────────────────────────

@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '').strip()
        conn = sqlite3.connect('/app/corp_data.db')
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM portal_users WHERE username=? AND password=?", (username, password))
        user = cursor.fetchone()
        conn.close()
        if user:
            session['logged_in'] = True
            session['username'] = username
            session['role'] = user[3]
            return redirect(url_for('index'))
        else:
            error = "Invalid username or password. Contact it-helpdesk@nexus.internal for access."
    return render_template_string(LOGIN_TEMPLATE, error=error)

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/', methods=['GET'])
@login_required
def index():
    query = request.args.get('track_id', '').strip()
    shipment = None
    sqli_result = None

    if query:
        conn = sqlite3.connect('/app/corp_data.db')
        cursor = conn.cursor()
        # Intentionally vulnerable SQL query (SQLi attack path for students)
        try:
            raw_sql = f"SELECT * FROM tracking_shipments WHERE tracking_id = '{query}'"
            cursor.execute(raw_sql)
            results = cursor.fetchall()
            if results:
                # Check if it looks like an injection (multiple rows or unexpected columns)
                if len(results) == 1 and len(results[0]) == 6:
                    shipment = results[0]
                else:
                    sqli_result = [str(r) for r in results]
            elif "'" in query or "--" in query or "OR" in query.upper() or "UNION" in query.upper():
                sqli_result = ["[SQL Injection detected - raw output shown]"]
        except Exception as e:
            sqli_result = [f"DB Error: {str(e)}"]
        conn.close()

    return render_template_string(PORTAL_TEMPLATE, query=query, shipment=shipment, sqli_result=sqli_result)

@app.route('/api/network/ping', methods=['POST'])
@login_required
def ping_diag():
    host = request.form.get('host', '').strip()
    ping_result = ""
    if host:
        try:
            # Intentional command injection vulnerability for student initial access
            cmd = f"ping -c 2 -W 2 {host}"
            result = subprocess.run(
                cmd, shell=True,
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                text=True, timeout=8
            )
            ping_result = result.stdout if result.stdout else "No output received."
        except subprocess.TimeoutExpired:
            ping_result = "Diagnostic probe timed out (8s limit)."
        except Exception as e:
            ping_result = f"Probe Error: {str(e)}"
    return render_template_string(PORTAL_TEMPLATE, ping_result=ping_result, query="", shipment=None, sqli_result=None)

@app.route('/api/v1/status', methods=['GET'])
def api_status():
    """Information disclosure endpoint — leaks internal details (intentional)"""
    return jsonify({
        "service": "Nexus Corporate Web Portal",
        "version": "2.4.1",
        "zone": "DMZ",
        "node": "srv-dmz-web01.nexus.internal",
        "ip": "10.0.1.20",
        "waf_proxy": "10.0.1.10",
        "internal_erp": "http://10.0.3.10:8000",
        "ad_dc": "dc01.nexus.internal (10.0.2.10)",
        "database": "10.0.3.20:5432",
        "platform": "Nexus-Infra v3.11 / Flask",
        "status": "healthy"
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "service": "corp-web-portal"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
