import os

# --- PART 1: Create the Clean Markdown File (For GitHub Repo) ---
md_path = os.path.join("docs", "INSTALL.md")
BLOCK = "`" * 3

md_content = f"""# 🛠️ Installation & Sovereign Deployment

This guide covers the deployment of the **Nexus Brain (Backend)** and **Nexus Body (Frontend)**. For Phase 1.3.1, the system is optimized for a "Sovereign Node" configuration on Linux.

## 🏗️ Deployment Architecture

{BLOCK}mermaid
graph LR
    User((User)) -->|Port 8000| Sentry[🛡️ Sentry Guard]
    subgraph Sovereign_Node [Linux Server]
        Sentry -->|Internal Route| Brain[🧠 Nexus Brain]
        Brain -->|Query| Vault[(Nexus Vault)]
        Brain -->|Gateway Proxy| Body[🖥️ Flutter Body :8080]
    end
{BLOCK}

---

## 1. Prerequisites

* **Hardware:** 1 vCPU, 2GB RAM (Minimum).
* **OS:** Ubuntu 22.04+ or Debian 11+.
* **Software:**
    * Python 3.11+
    * Flutter SDK (Stable)
    * SQLite3

## 2. Backend Deployment (The Brain)

### 2.1 Clone and Setup Environment

{BLOCK}bash
git clone https://github.com/arhantbarmate/nexus-core
cd nexus-core/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
{BLOCK}

### 2.2 Configure Security (Sentry)
Create a `.env` file in the `backend/` directory:

{BLOCK}env
# Required for production environments
BOT_TOKEN=your_telegram_bot_token

# Environment Toggle (defaults to 'dev' if unset)
NEXUS_ENV=production
{BLOCK}

### 2.3 Initialize the Vault & Start
{BLOCK}bash
# The Brain automatically initializes the SQLite schema on first run
uvicorn main:app --host 0.0.0.0 --port 8000
{BLOCK}

---

## 3. Frontend Deployment (The Body)

### 3.1 Build & Serve Flutter Web
The Body is designed to run as an independent service that the Brain proxies.
{BLOCK}bash
cd ../client
flutter pub get
flutter build web --release
# Serve locally on port 8080
python3 -m http.server 8080 --directory build/web
{BLOCK}

---

## 4. Verification

To ensure your installation is "Hardened", run the full test suite:

{BLOCK}bash
cd ../backend
pytest tests/test_main.py
pytest tests/test_gateway.py
{BLOCK}

---

© 2026 Nexus Protocol · v1.3.1
"""

with open(md_path, "w", encoding="utf-8") as f:
    f.write(md_content)
print("✅ Generated clean INSTALL.md (For GitHub Repo)")


# --- PART 2: Create the Static HTML File (For Website Button) ---
html_path = os.path.join("docs", "install.html")

html_content = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nexus Protocol - Installation</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; line-height: 1.6; color: #333; }
        h1, h2, h3 { color: #111; border-bottom: 1px solid #eee; padding-bottom: 10px; }
        code { background: #f4f4f4; padding: 2px 5px; border-radius: 3px; font-family: monospace; }
        pre { background: #2d2d2d; color: #f8f8f2; padding: 15px; border-radius: 5px; overflow-x: auto; }
        .mermaid { margin: 20px 0; text-align: center; }
        .back-link { display: inline-block; margin-bottom: 20px; text-decoration: none; color: #0066cc; font-weight: bold; }
        .back-link:hover { text-decoration: underline; }
    </style>
</head>
<body>

<a href="index.html" class="back-link">← Back to Home</a>

<h1>🛠️ Installation & Sovereign Deployment</h1>
<p>This guide covers the deployment of the <strong>Nexus Brain (Backend)</strong> and <strong>Nexus Body (Frontend)</strong>.</p>

<h2>🏗️ Deployment Architecture</h2>
<div class="mermaid">
graph LR
    User((User)) -->|Port 8000| Sentry[🛡️ Sentry Guard]
    subgraph Sovereign_Node [Linux Server]
        Sentry -->|Internal Route| Brain[🧠 Nexus Brain]
        Brain -->|Query| Vault[(Nexus Vault)]
        Brain -->|Gateway Proxy| Body[🖥️ Flutter Body :8080]
    end
</div>

<h2>1. Prerequisites</h2>
<ul>
    <li><strong>Hardware:</strong> 1 vCPU, 2GB RAM.</li>
    <li><strong>OS:</strong> Ubuntu 22.04+ or Debian 11+.</li>
    <li><strong>Software:</strong> Python 3.11+, Flutter SDK, SQLite3.</li>
</ul>

<h2>2. Backend Deployment</h2>
<h3>2.1 Clone and Setup</h3>
<pre>git clone https://github.com/arhantbarmate/nexus-core
cd nexus-core/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt</pre>

<h3>2.2 Configure Security</h3>
<pre># .env file
BOT_TOKEN=your_telegram_bot_token
NEXUS_ENV=production</pre>

<h3>2.3 Initialize & Start</h3>
<pre>uvicorn main:app --host 0.0.0.0 --port 8000</pre>

<h2>3. Frontend Deployment</h2>
<pre>cd ../client
flutter pub get
flutter build web --release
python3 -m http.server 8080 --directory build/web</pre>

<hr>
<p>© 2026 Nexus Protocol · v1.3.1</p>

<script type="module">
import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
mermaid.initialize({ startOnLoad: true });
</script>

</body>
</html>
"""

with open(html_path, "w", encoding="utf-8") as f:
    f.write(html_content)
print("✅ Generated install.html (For Website)")


# --- PART 3: Update the Landing Page Button ---
index_path = os.path.join("docs", "index.html")
if os.path.exists(index_path):
    with open(index_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # Point the button to the HTML file
    new_content = content.replace('href="INSTALL.md"', 'href="install.html"')
    new_content = new_content.replace('href="./install/"', 'href="install.html"')
    
    with open(index_path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print("✅ Linked Landing Page to install.html")