from flask import Flask, request, jsonify, render_template_string

app = Flask(__name__)

NAC_HTML = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Nexus NAC — Network Access Control</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
<style>
* { box-sizing: border-box; margin:0; padding:0; }
body { font-family:'Inter',sans-serif; background:#0a0f1e; color:#e2e8f0; padding:2rem; }
.header { background:#0f172a; border:1px solid #1e3a8a; border-radius:8px; padding:1.5rem; margin-bottom:2rem; }
.brand { color:#60a5fa; font-size:1.2rem; font-weight:700; }
table { width:100%; border-collapse:collapse; background:#0f172a; border-radius:8px; overflow:hidden; }
th,td { padding:0.75rem 1rem; text-align:left; font-size:0.85rem; border-bottom:1px solid #1e293b; }
th { background:#1e293b; color:#94a3b8; font-weight:600; text-transform:uppercase; letter-spacing:0.05em; }
.badge { padding:0.2rem 0.5rem; border-radius:4px; font-size:0.75rem; font-weight:600; }
.allow { background:#064e3b; color:#34d399; }
.deny  { background:#450a0a; color:#f87171; }
.pending { background:#451a03; color:#fbbf24; }
code { font-family:monospace; color:#a78bfa; background:#0f172a; padding:0.1rem 0.3rem; border-radius:3px; }
</style>
</head>
<body>
<div class="header">
  <div class="brand">🛡️ NEXUS NAC — Cisco ISE/ClearPass Network Access Control</div>
  <p style="color:#475569;font-size:0.85rem;margin-top:0.4rem;">Node: nac-ise-01.nexus.internal (10.0.2.15) | 802.1X Enforcement Active</p>
</div>
<table>
<thead><tr><th>MAC Address</th><th>IP Address</th><th>Hostname</th><th>User</th><th>Auth Method</th><th>VLAN</th><th>Policy</th></tr></thead>
<tbody>
{% for d in devices %}
<tr>
  <td><code>{{d.mac}}</code></td><td>{{d.ip}}</td><td><code>{{d.hostname}}</code></td>
  <td>{{d.user}}</td><td>{{d.auth}}</td><td>VLAN-{{d.vlan}}</td>
  <td><span class="badge {{d.policy_class}}">{{d.policy}}</span></td>
</tr>
{% endfor %}
</tbody>
</table>
<p style="color:#334155;font-size:0.75rem;margin-top:1rem;">
  API: <code>GET /api/devices</code> | <code>POST /api/bypass?mac=XX:XX:XX:XX:XX:XX</code> (admin only)
</p>
</body>
</html>"""

REGISTERED_DEVICES = [
    {"mac":"00:50:56:A1:B2:C3","ip":"10.0.4.20","hostname":"dev-workstation-01","user":"tahmed",   "auth":"802.1X EAP-TLS","vlan":40,"policy":"ALLOW",   "policy_class":"allow"},
    {"mac":"00:50:56:A1:B2:D4","ip":"10.0.4.10","hostname":"hr-workstation-01", "user":"sjenkins", "auth":"802.1X EAP-TLS","vlan":40,"policy":"ALLOW",   "policy_class":"allow"},
    {"mac":"00:50:56:A1:B3:E5","ip":"10.0.5.10","hostname":"branch-pc-01",      "user":"ibrahim",  "auth":"MAB (bypass)",  "vlan":50,"policy":"ALLOW",   "policy_class":"allow"},
    {"mac":"00:50:56:AA:BB:CC","ip":"10.0.4.70","hostname":"iot-device-01",     "user":"N/A",      "auth":"MAB",           "vlan":40,"policy":"RESTRICT","policy_class":"pending"},
    {"mac":"00:50:56:FF:AA:01","ip":"10.0.4.99","hostname":"UNKNOWN",           "user":"N/A",      "auth":"FAILED",        "vlan":99,"policy":"QUARANTINE","policy_class":"deny"},
]

@app.route('/')
def index():
    return render_template_string(NAC_HTML, devices=REGISTERED_DEVICES)

@app.route('/api/devices')
def api_devices():
    return jsonify({"nac_node":"nac-ise-01.nexus.internal","devices": REGISTERED_DEVICES, "total": len(REGISTERED_DEVICES)})

@app.route('/api/bypass', methods=['POST','GET'])
def mac_bypass():
    """MAC Authentication Bypass (MAB) — intentionally exploitable for lab"""
    mac = request.args.get('mac') or (request.get_json(silent=True) or {}).get('mac','')
    if mac:
        return jsonify({
            "result": "BYPASS_GRANTED",
            "mac": mac,
            "vlan": 10,
            "policy": "ALLOW (MAB bypass — no 802.1X required)",
            "flag": "FLAG{NAC_M4C_BYPA55_802_1X_C1RC_UMVENT3D_2026}",
            "warning": "MAB bypass issued — device granted network access without authentication"
        })
    return jsonify({"error": "mac parameter required", "hint": "POST /api/bypass?mac=XX:XX:XX:XX:XX:XX"})

@app.route('/health')
def health():
    return jsonify({"status":"healthy","service":"nexus-nac-ise","version":"3.3"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8100, debug=False)
