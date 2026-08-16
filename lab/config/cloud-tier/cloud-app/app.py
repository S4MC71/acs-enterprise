import os, json, requests
import jwt as pyjwt
from flask import Flask, request, jsonify, render_template_string

app = Flask(__name__)

# INTENTIONALLY WEAK JWT secret (for lab Kerberoasting/JWT cracking demo)
JWT_SECRET = "nexus-cloud-jwt-secret-2026"
JWT_ALGORITHM = "HS256"

CLOUD_HTML = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Nexus Cloud Platform — API Gateway</title>
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600&family=Inter:wght@400;600&display=swap" rel="stylesheet">
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Inter', sans-serif; background: #020817; color: #e2e8f0; padding: 2rem; }
.header { background: #0c1929; border: 1px solid #1e40af; border-radius: 8px; padding: 1.5rem; margin-bottom: 2rem; }
.brand { font-family: 'JetBrains Mono', monospace; font-size: 1.2rem; color: #60a5fa; font-weight: 700; }
.badge { background: #1e3a8a; color: #93c5fd; border: 1px solid #1d4ed8; padding: 0.2rem 0.6rem; border-radius: 4px; font-size: 0.75rem; margin-left: 0.75rem; }
.endpoints { display: grid; grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); gap: 1.5rem; }
.card { background: #0f172a; border: 1px solid #1e293b; border-radius: 8px; padding: 1.5rem; }
.card h3 { color: #38bdf8; margin-bottom: 0.75rem; font-size: 0.95rem; font-family: 'JetBrains Mono', monospace; }
.card p { color: #94a3b8; font-size: 0.85rem; line-height: 1.5; }
.method { display: inline-block; padding: 0.15rem 0.5rem; border-radius: 4px; font-size: 0.75rem; font-weight: 700; margin-right: 0.5rem; }
.get { background: #064e3b; color: #34d399; }
.post { background: #451a03; color: #fbbf24; }
code { font-family: 'JetBrains Mono', monospace; background: #0f172a; padding: 0.2rem 0.4rem; border-radius: 3px; color: #a78bfa; font-size: 0.8rem; }
.meta { color: #475569; font-size: 0.75rem; margin-top: 1rem; }
</style>
</head>
<body>
<div class="header">
  <div class="brand">☁️ NEXUS CLOUD PLATFORM <span class="badge">AWS us-east-1</span> <span class="badge">prod</span></div>
  <p style="color:#64748b; font-size:0.85rem; margin-top:0.5rem;">Cloud Application Gateway — Kubernetes Microservice Cluster | Node: cloud-app-01.nexus-cloud.internal</p>
</div>
<div class="endpoints">
  <div class="card">
    <h3><span class="method get">GET</span>/api/v1/health</h3>
    <p>Service health check. Returns cluster node status and version.</p>
  </div>
  <div class="card">
    <h3><span class="method get">GET</span>/api/v1/users</h3>
    <p>Cloud IAM user directory. Requires Bearer JWT token.</p>
  </div>
  <div class="card">
    <h3><span class="method post">POST</span>/api/v1/auth</h3>
    <p>Authenticate and receive JWT access token. Body: <code>{"user":"...", "pass":"..."}</code></p>
  </div>
  <div class="card">
    <h3><span class="method get">GET</span>/api/v1/fetch?url=...</h3>
    <p>⚠️ Internal URL fetcher (SSRF vulnerable). Used by monitoring service.</p>
  </div>
  <div class="card">
    <h3><span class="method get">GET</span>/api/v1/config</h3>
    <p>Cloud environment config dump. Returns instance metadata.</p>
  </div>
  <div class="card">
    <h3><span class="method get">GET</span>/api/v1/db-status</h3>
    <p>Cloud DB connectivity check. Returns RDS connection info.</p>
  </div>
</div>
<div class="meta">
  <p>Platform: Nexus Cloud v3.4 | Runtime: Python/Flask on K8s | JWT: HS256 | Region: us-east-1</p>
</div>
</body>
</html>"""

# Fake cloud users
CLOUD_USERS = [
    {"id": "CLOUD-USR-001", "username": "cloud-admin",  "password": "CloudAdmin@Nexus2026!", "role": "cloud-admin",    "email": "cloud-admin@nexus-cloud.internal"},
    {"id": "CLOUD-USR-002", "username": "k8s-deployer", "password": "K8sDeploy#2026",        "role": "devops",         "email": "k8s@nexus-cloud.internal"},
    {"id": "CLOUD-USR-003", "username": "svc-monitor",  "password": "Monitor$vc2026",         "role": "service-account","email": "monitor@nexus-cloud.internal"},
]

# Cloud secrets (crown jewels reachable after SSRF/cloud compromise)
CLOUD_SECRETS = {
    "rds_endpoint":      "nexus-prod-db.cluster-xyz.us-east-1.rds.amazonaws.com",
    "rds_user":          "nexus_rds_admin",
    "rds_password":      "RdsNexusProd@2026!Cloud",
    "s3_bucket":         "nexus-prod-data-us-east-1",
    "s3_access_key":     "AKIANEXUSCLOUD881209",
    "s3_secret":         "CloudS3cret+NexusProd/2026/us-east-1",
    "internal_api_key":  "nexus-internal-svc-api-key-9182049810293",
    "flag":              "FLAG{CL0UD_T13R_C0MPR0M1S3D_AWS_NEXUS_2026!}"
}

@app.route('/')
def index():
    return render_template_string(CLOUD_HTML)

@app.route('/api/v1/health')
def health():
    return jsonify({
        "status": "healthy",
        "service": "nexus-cloud-app",
        "version": "3.4.1",
        "node": "cloud-app-01.nexus-cloud.internal",
        "cluster": "nexus-prod-k8s-us-east-1",
        "region": "us-east-1",
        "internal_ip": "172.16.0.20",
        "cloud_db": "172.16.0.30",
        "transit_gw": "172.16.0.1"
    })

@app.route('/api/v1/auth', methods=['POST'])
def auth():
    data = request.get_json(silent=True) or {}
    username = data.get('user', '')
    password = data.get('pass', '')
    for u in CLOUD_USERS:
        if u['username'] == username and u['password'] == password:
            token = pyjwt.encode({"user": username, "role": u['role'], "exp": 9999999999}, JWT_SECRET, algorithm=JWT_ALGORITHM)
            return jsonify({"token": token, "user": username, "role": u['role']})
    return jsonify({"error": "Invalid credentials"}), 401

@app.route('/api/v1/users')
def users():
    auth_header = request.headers.get('Authorization', '')
    if not auth_header.startswith('Bearer '):
        return jsonify({"error": "Unauthorized", "hint": "Provide: Authorization: Bearer <jwt>"}), 401
    try:
        # Intentionally accepts weak tokens — JWT secret is brute-forceable
        token = auth_header[7:]
        pyjwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
    except Exception as e:
        return jsonify({"error": f"Token invalid: {str(e)}"}), 401
    return jsonify({"cloud_users": CLOUD_USERS})

@app.route('/api/v1/fetch')
def ssrf_fetch():
    """INTENTIONALLY VULNERABLE SSRF endpoint — simulates cloud metadata leak"""
    url = request.args.get('url', '')
    if not url:
        return jsonify({"error": "url parameter required", "example": "/api/v1/fetch?url=http://172.16.0.30/health"})
    try:
        # SSRF: fetch any internal URL — key attack: fetch http://172.16.0.30/secrets or http://10.0.3.20/...
        resp = requests.get(url, timeout=5)
        return jsonify({
            "url": url,
            "status_code": resp.status_code,
            "content": resp.text[:2000],
            "headers": dict(resp.headers)
        })
    except Exception as e:
        return jsonify({"error": str(e), "url": url})

@app.route('/api/v1/config')
def config():
    """Instance metadata — leaks internal cloud topology"""
    return jsonify({
        "instance_id": "i-nexus-cloud-app-01",
        "region": "us-east-1",
        "vpc_id": "vpc-nexus-prod-0xa1b2c3",
        "private_ip": "172.16.0.20",
        "cloud_db_host": "172.16.0.30",
        "cloud_db_port": 5432,
        "cloud_db_name": "nexus_cloud_prod",
        "transit_gateway": "172.16.0.1",
        "on_prem_vpn": "10.0.3.0/24",
        "jwt_algorithm": "HS256",
        "note": "JWT secret in /run/secrets/jwt_secret — hint: check env vars"
    })

@app.route('/api/v1/db-status')
def db_status():
    return jsonify({
        "rds_endpoint": "172.16.0.30",
        "port": 5432,
        "database": "nexus_cloud_prod",
        "user": "nexus_rds_admin",
        "status": "connected",
        "tables": ["cloud_users", "cloud_api_keys", "cloud_secrets", "cloud_audit"]
    })

@app.route('/api/v1/secrets')
def secrets():
    """Only accessible via SSRF from inside cloud tier — not directly from outside"""
    client_ip = request.remote_addr
    if not (client_ip.startswith('172.16.') or client_ip.startswith('10.0.')):
        return jsonify({"error": "Access from internal cloud subnet only"}), 403
    return jsonify(CLOUD_SECRETS)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)
