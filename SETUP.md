# Axiom Agentic Platform - Setup Guide

Complete installation and configuration guide for Windows.

---

## 📋 Prerequisites

### Required Software
- **Windows 10/11** (64-bit)
- **PowerShell 5.1+** (included with Windows)
- **Docker Desktop 4.x+** ([Download](https://www.docker.com/products/docker-desktop))
- **Python 3.10+** ([Download](https://www.python.org/downloads/))
- **Node.js 18+** ([Download](https://nodejs.org/))
- **Git** ([Download](https://git-scm.com/download/win))

### Required Accounts
- **OpenAI API Key** (for GPT-4 integration) - [Get one](https://platform.openai.com/api-keys)
- **GitHub Account** (optional, for cloning)

---

## 🚀 Installation

### Step 1: Install Prerequisites

**Install Docker Desktop:**
```powershell
# Download and install Docker Desktop from:
# https://www.docker.com/products/docker-desktop

# After installation, start Docker Desktop
# Wait for green status icon in system tray (2-3 minutes)
```

**Install UV Package Manager (for Python):**
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Restart terminal after installation
```

**Verify installations:**
```powershell
docker --version          # Docker version 29.0.0+
python --version          # Python 3.10.0+
node --version            # v18.0.0+
uv --version              # uv 0.5.0+
```

---

### Step 2: Clone Scale AI Agentex (Required Dependency)

This platform extends Scale AI's Agentex framework. You need to clone it:

```powershell
cd D:\LLM  # Or your preferred directory

# Clone Scale AI Agentex
git clone https://github.com/scaleapi/scale-agentex.git

# Install Agentex backend dependencies
cd scale-agentex
uv pip install -e .

# Install Agentex UI dependencies
cd agentex-ui
npm install
```

---

### Step 3: Clone Axiom Agentic Platform

```powershell
cd D:\LLM  # Same parent directory as scale-agentex

# Clone this repository
git clone https://github.com/Shreyasg13/axiom-agentic-platform.git
cd axiom-agentic-platform
```

**Expected directory structure:**
```
D:\LLM\
├── scale-agentex/          # Scale AI's framework (required)
├── axiom-agentic-platform/ # This repository (your orchestration)
```

---

### Step 4: Install Agentex SDK Tools

```powershell
cd D:\LLM\axiom-agentic-platform

# Install agentex SDK globally via UV tools
uv tool install agentex-sdk

# Install openai-agents in the UV tools Python environment
$uvToolsPython = "C:\Users\$env:USERNAME\AppData\Roaming\uv\tools\agentex-sdk\Scripts\python.exe"
& $uvToolsPython -m pip install openai-agents
```

**Verify installation:**
```powershell
agentex --version  # Should show agentex version
```

---

### Step 5: Configure OpenAI API Key

**Option A: Environment Variable (Recommended)**
```powershell
# Set permanently for your user
[System.Environment]::SetEnvironmentVariable('OPENAI_API_KEY', 'sk-your-api-key-here', 'User')

# Restart terminal for changes to take effect
```

**Option B: .env File**
```powershell
cd D:\LLM\axiom-agentic-platform\agent

# Create .env file
@"
OPENAI_API_KEY=sk-your-api-key-here
"@ | Out-File -FilePath .env -Encoding UTF8
```

---

## ▶️ Running the Platform

### Quick Start (Automated)

```powershell
cd D:\LLM\axiom-agentic-platform

# Run the master orchestrator
.\orchestration\ORCHESTRATOR_MASTER.ps1
```

**What happens:**
1. ✅ Checks Docker Desktop (starts if needed, ~60s)
2. ✅ Starts backend services (9 Docker containers, ~20s)
3. ✅ Starts UI (Next.js dev server, ~20s)
4. ✅ Starts agent (registers with backend, ~30s)
5. 🌐 Opens browser to `http://localhost:3000`

**Total time:** ~2 minutes first run, ~40 seconds subsequent runs

---

### Manual Start (Step-by-Step)

**Start Docker Desktop:**
```powershell
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
# Wait 2-3 minutes for green icon in system tray
```

**Start Backend:**
```powershell
cd D:\LLM\scale-agentex
docker compose up -d
# Wait 30 seconds for containers to initialize
```

**Start UI:**
```powershell
cd D:\LLM\scale-agentex\agentex-ui
npm run dev
# UI available at http://localhost:3000
```

**Start Agent:**
```powershell
cd D:\LLM\axiom-agentic-platform\agent
$env:OPENAI_API_KEY = "sk-your-key-here"
agentex agents run --manifest manifest.yaml
# Agent registers on port 8000
```

---

## ✅ Verification

### Check All Services

```powershell
cd D:\LLM\axiom-agentic-platform
.\orchestration\CHECK_STATUS.ps1
```

**Expected output:**
```
Backend    [✅ UP  ]  http://localhost:5003
UI         [✅ UP  ]  http://localhost:3000
Agent      [✅ UP  ]  http://localhost:8000

Registered Agents: axiom-agentic-agent
```

### Test Agent Integration

1. Open browser: `http://localhost:3000`
2. Select **axiom-agentic-agent** from dropdown
3. Send test message: `"What is 6 x 11? Explain step by step."`
4. Verify OpenAI response with mathematical reasoning

---

## 🔧 Troubleshooting

### Docker Desktop Not Starting

**Symptom:** Orchestrator hangs on "Checking Docker Desktop..."

**Solution:**
```powershell
# Kill Docker processes
Get-Process "Docker Desktop","com.docker*" | Stop-Process -Force

# Restart Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Wait 3-5 minutes for full initialization
```

### Backend Fails to Start

**Symptom:** "Backend is DOWN on port 5003"

**Solution:**
```powershell
# Check Docker containers
docker ps -a

# Restart backend
cd D:\LLM\scale-agentex
docker compose down
docker compose up -d
```

### Agent Not Showing in UI

**Symptom:** UI shows "No agents found"

**Solution:**
```powershell
# Verify openai-agents module
$uvPython = "C:\Users\$env:USERNAME\AppData\Roaming\uv\tools\agentex-sdk\Scripts\python.exe"
& $uvPython -c "from agents import Agent; print('OK')"

# If error, reinstall:
& $uvPython -m pip install openai-agents --force-reinstall

# Restart agent
.\orchestration\START_AGENT_STANDALONE.ps1
```

### Port Already in Use

**Symptom:** "Address already in use" errors

**Solution:**
```powershell
# Find and kill processes on specific ports
Get-Process -Id (Get-NetTCPConnection -LocalPort 5003 -ErrorAction SilentlyContinue).OwningProcess | Stop-Process -Force
Get-Process -Id (Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue).OwningProcess | Stop-Process -Force
Get-Process -Id (Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue).OwningProcess | Stop-Process -Force
```

---

## 📚 Next Steps

- **[Architecture Overview](docs/ARCHITECTURE.md)** - Understand system design
- **[How to Use](docs/HOW_TO_USE.md)** - Detailed usage guide
- **[Testing Guide](docs/TESTING_GUIDE.md)** - Testing scenarios
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues

---

## 🆘 Getting Help

- **Issues**: [GitHub Issues](https://github.com/Shreyasg13/axiom-agentic-platform/issues)
- **Scale AI Agentex Docs**: https://github.com/scaleapi/scale-agentex
- **OpenAI API Docs**: https://platform.openai.com/docs
