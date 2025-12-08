# Screenshots

Visual demonstration of Axiom Agentic Platform in action.

## 📸 How to Capture Screenshots

### Prerequisites
- Platform running (execute `.\orchestration\ORCHESTRATOR_MASTER.ps1`)
- All services UP (Backend, UI, Agent)
- Browser open to `http://localhost:3000`

### Screenshot Checklist

#### 1. **Orchestrator Startup** (`01-orchestrator-startup.png`)
**What to capture:**
- PowerShell terminal showing ORCHESTRATOR_MASTER.ps1 execution
- Include ASCII art header
- Show Docker check, Backend start, UI start, Agent start phases
- Final "System Status" dashboard with all ✅ UP

**How to capture:**
```powershell
# Press Win + Shift + S (Windows Snipping Tool)
# Select rectangular area covering full terminal output
# Save as: 01-orchestrator-startup.png
```

---

#### 2. **System Status Dashboard** (`02-system-status.png`)
**What to capture:**
- Run CHECK_STATUS.ps1 output
- Show all three services with green UP status
- Include registered agent name

**Command:**
```powershell
.\orchestration\CHECK_STATUS.ps1
# Capture terminal output
```

---

#### 3. **UI with Custom Branding** (`03-ui-branding.png`)
**What to capture:**
- Browser window at `http://localhost:3000`
- Custom header with "Axiom Agentic Platform" branding
- "Powered by Scale AI Agentex" link visible
- Agent dropdown visible
- Full window including browser tabs showing "Axiom Agentic Platform | Scale AI Agentex"

**Tips:**
- Zoom browser to 90% for better full-page view
- Make sure custom header is clearly visible

---

#### 4. **Agent Selection** (`04-agent-selection.png`)
**What to capture:**
- Agent dropdown menu open
- "axiom-agentic-agent" visible in list
- Shows agent is registered and ready

**How:**
- Click on agent dropdown
- Capture while menu is open

---

#### 5. **OpenAI Response** (`05-openai-response.png`)
**What to capture:**
- Full conversation showing:
  - Your test message: "What is 6 x 11? Explain step by step."
  - OpenAI's detailed mathematical response with reasoning
  - Streaming completion indicator
- Shows successful AI integration

**Tips:**
- Wait for full response before capturing
- Include both user message and AI response in frame

---

#### 6. **Docker Containers** (`06-docker-containers.png`)
**What to capture:**
- Terminal output of `docker ps`
- Show all 9 agentex containers running
- Include container names, status, ports

**Command:**
```powershell
docker ps
# Capture terminal output
```

---

#### 7. **Agent Terminal** (`07-agent-terminal.png`) [OPTIONAL]
**What to capture:**
- Agent PowerShell window
- Debug output showing:
  - "LOADING CUSTOM ACP.PY"
  - "REGISTERING CUSTOM HANDLER"
  - "Successfully registered agent"
  - "CUSTOM HANDLER CALLED!" during message processing

---

## 📁 File Naming Convention

Use this exact naming:
```
01-orchestrator-startup.png
02-system-status.png
03-ui-branding.png
04-agent-selection.png
05-openai-response.png
06-docker-containers.png
07-agent-terminal.png (optional)
```

## 🎨 Screenshot Best Practices

1. **Resolution**: 1920x1080 or higher
2. **Format**: PNG (better quality than JPG)
3. **Size**: Under 2MB per image (use compression if needed)
4. **Clarity**: Ensure text is readable
5. **Privacy**: Redact any sensitive info (API keys, IPs if public)

## 🚀 Adding to Repository

After capturing screenshots:

```powershell
cd D:\LLM\axiom-agentic-platform

# Add screenshots
git add screenshots/

# Commit
git commit -m "docs: Add platform screenshots demonstrating working system

- Orchestrator startup and system status
- UI with custom branding and Scale AI attribution
- Agent selection and OpenAI integration
- Docker containers running successfully"

# Push
git push origin main
```

## 📝 Updating README

Screenshots will be automatically referenced in the main README.md with:

```markdown
![Orchestrator Startup](screenshots/01-orchestrator-startup.png)
![System Status](screenshots/02-system-status.png)
![UI Branding](screenshots/03-ui-branding.png)
```

---

**Pro Tip:** Take all screenshots in one session to ensure consistent state across images!
