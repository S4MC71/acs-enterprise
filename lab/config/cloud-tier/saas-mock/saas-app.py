import os, base64, hashlib
from flask import Flask, request, redirect, session, jsonify, render_template_string

app = Flask(__name__)
app.secret_key = "nexus-saas-sso-session-secret-2026"

SAAS_LOGIN_HTML = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Nexus SSO — Corporate Identity Provider</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Inter', sans-serif; background: linear-gradient(135deg, #0a0f1e 0%, #0d1b3e 100%);
       min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 2rem; }
.card { background: rgba(15,23,42,0.95); border: 1px solid #1e3a8a; border-radius: 16px;
        padding: 3rem; width: 100%; max-width: 440px; box-shadow: 0 25px 60px rgba(0,0,40,0.6); }
.sso-logo { text-align: center; margin-bottom: 2rem; }
.sso-logo-icon { font-size: 3rem; display: block; margin-bottom: 0.75rem; }
.brand { font-size: 1.4rem; font-weight: 700; color: #60a5fa; }
.subtitle { color: #475569; font-size: 0.85rem; margin-top: 0.4rem; }
.provider-buttons { display: flex; flex-direction: column; gap: 0.75rem; margin-bottom: 2rem; }
.sso-btn { display: flex; align-items: center; gap: 1rem; padding: 0.85rem 1.2rem;
           border: 1px solid #334155; border-radius: 8px; background: #1e293b;
           color: #e2e8f0; cursor: pointer; font-size: 0.9rem; font-weight: 500;
           text-decoration: none; transition: border-color 0.2s, background 0.2s; }
.sso-btn:hover { border-color: #3b82f6; background: #1e3a8a; }
.divider { display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem; color: #334155; font-size: 0.8rem; }
.divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: #334155; }
label { display: block; color: #94a3b8; font-size: 0.8rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 0.35rem; }
input { width: 100%; padding: 0.8rem 1rem; background: #0f172a; border: 1px solid #334155;
        border-radius: 6px; color: #f8fafc; font-size: 0.9rem; margin-bottom: 1rem; transition: border-color 0.2s; }
input:focus { outline: none; border-color: #3b82f6; }
.btn-primary { width: 100%; padding: 0.9rem; background: #2563eb; color: #fff; border: none;
               border-radius: 6px; font-weight: 700; cursor: pointer; font-size: 0.95rem; transition: background 0.2s; }
.btn-primary:hover { background: #1d4ed8; }
.error { background: #450a0a; border: 1px solid #7f1d1d; color: #fca5a5; padding: 0.75rem;
         border-radius: 6px; margin-bottom: 1rem; font-size: 0.85rem; }
.footer { text-align: center; color: #334155; font-size: 0.75rem; margin-top: 1.5rem; }
</style>
</head>
<body>
<div class="card">
  <div class="sso-logo">
    <span class="sso-logo-icon">🔐</span>
    <div class="brand">Nexus Identity Platform</div>
    <div class="subtitle">Corporate SSO — Powered by Nexus Cloud IdP v2.4</div>
  </div>

  <div class="provider-buttons">
    <a href="/saml/init?provider=microsoft365" class="sso-btn">
      🪟 &nbsp;Sign in with Microsoft 365 (Nexus Tenant)
    </a>
    <a href="/saml/init?provider=google" class="sso-btn">
      🔵 &nbsp;Sign in with Google Workspace
    </a>
  </div>

  <div class="divider">or use domain credentials</div>

  {% if error %}<div class="error">⚠️ {{ error }}</div>{% endif %}

  <form method="POST" action="/login">
    <label>Domain Username (user@nexus.internal)</label>
    <input type="text" name="username" placeholder="e.g. tahmed@nexus.internal" autocomplete="off">
    <label>Password</label>
    <input type="password" name="password" placeholder="Domain password">
    <button type="submit" class="btn-primary">Sign In</button>
  </form>

  <div class="footer">
    Nexus Global Enterprise &copy; 2026 | SSO Portal v2.4 | <a href="/oauth2/token" style="color:#334155;">OAuth2 Token Endpoint</a>
  </div>
</div>
</body>
</html>"""

# Domain users (linked to on-prem AD credentials)
SSO_USERS = {
    "mvance@nexus.internal":   "NexusCISO_Mv@2026#",
    "erostova@nexus.internal": "DevOpsP@ss2026!",
    "tahmed@nexus.internal":   "DevOpsP@ss2026!",
    "sjenkins@nexus.internal": "HrDirector9921!",
    "admin@nexus.internal":    "NexusTechAdmin2026!",
}

@app.route('/')
def index():
    return render_template_string(SAAS_LOGIN_HTML, error=None)

@app.route('/login', methods=['POST'])
def login():
    username = request.form.get('username', '')
    password = request.form.get('password', '')
    if SSO_USERS.get(username) == password:
        session['user'] = username
        return redirect('/dashboard')
    return render_template_string(SAAS_LOGIN_HTML, error="Authentication failed. Check credentials.")

@app.route('/dashboard')
def dashboard():
    if not session.get('user'):
        return redirect('/')
    return jsonify({
        "status": "authenticated",
        "user": session['user'],
        "apps": ["Office 365", "Salesforce CRM", "Nexus ERP", "Jira", "Confluence"],
        "sso_token": f"nexus-sso-{hashlib.md5(session['user'].encode()).hexdigest()}",
        "flag": "FLAG{SAAS_SS0_C0RPO_ID3NT1TY_BYPASSD_2026}"
    })

@app.route('/saml/init')
def saml_init():
    provider = request.args.get('provider', 'microsoft365')
    return jsonify({
        "saml_request": "PHNhbWxwOkF1dGhOUmVxdWVzdA...(base64 SAML)",
        "redirect_url": f"https://login.microsoftonline.com/nexus.internal/saml2/{provider}",
        "relay_state": "nexus-sso-relay-001",
        "note": "SAML endpoint — try credential stuffing with /login for direct auth bypass"
    })

@app.route('/oauth2/token', methods=['GET', 'POST'])
def oauth2_token():
    """OAuth2 token endpoint — accepts password grant (intentionally insecure)"""
    username = request.form.get('username') or request.args.get('username', '')
    password = request.form.get('password') or request.args.get('password', '')
    if SSO_USERS.get(username) == password:
        token = base64.b64encode(f"{username}:nexus-oauth2-access-{hashlib.md5(password.encode()).hexdigest()}".encode()).decode()
        return jsonify({
            "access_token": token,
            "token_type": "Bearer",
            "expires_in": 3600,
            "scope": "openid profile email nexus.internal"
        })
    return jsonify({"error": "invalid_grant", "hint": "Try NEXUS domain credentials"}), 401

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "service": "nexus-saas-sso", "version": "2.4"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8443, debug=False)
