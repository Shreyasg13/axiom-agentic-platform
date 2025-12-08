# Quick Testing Cheat Sheet

## Step 1: Start Agent (Terminal 1)

```powershell
cd D:\LLM\axiom_gladiator_13
.\start_agent.ps1
```

**Keep this window open!** You should see:
```
🚀 Starting axiom-gladiator-13 Agent
Agent will run on: http://localhost:8000
INFO: Uvicorn running on http://0.0.0.0:8000
INFO: Application startup complete.
```

---

## Step 2: Test Your Agent (Terminal 2 - NEW Window!)

**ONE COMMAND - runs all tests:**
```powershell
cd D:\LLM\axiom_gladiator_13
.\test_agent.ps1
```

**You'll see:**
```
✅ Health check passed!
✅ Message 1: "Hello! Can you hear me?" → Response received
✅ Message 2: "What is your name?" → Response received
✅ Message 3: "Tell me a joke" → Response received
✅ Message 4: "What is 2 + 2?" → Response received
🎉 All tests passed successfully!
```

---

### Or Test Manually (Optional):

```powershell
# Health check
Invoke-RestMethod http://localhost:8000/health

# Send a message
$msg = @{ content = @{ text = "Hello agent!" } } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:8000/messages/send" -Method POST -ContentType "application/json" -Body $msg
```

---

## Step 3: Modify Agent Behavior

Open in VS Code:
```powershell
code D:\LLM\axiom_gladiator_13\start_agent_standalone.py
```

The agent will automatically reload when you save! *(auto-reload enabled)*

---

## Stop Agent

In the window where the agent is running, press: **Ctrl + C**

---

## Troubleshooting

**"Connection refused"** = Agent not running
- Start it using Step 1

**"Port 8000 already in use"** = Agent already running
- Check: `netstat -ano | findstr "8000"`
- Kill it: `taskkill /PID <number> /F`

**"Scripts don't work"** = Make sure you're in the right directory
- Run: `cd D:\LLM\axiom_gladiator_13` first

---

## Quick Reference

| What | How |
|------|-----|
| Start agent | `.\start_agent.ps1` (Terminal 1) |
| Test agent | `.\test_agent.ps1` (Terminal 2 - NEW window!) |
| Stop agent | Press `Ctrl+C` in Terminal 1 |
| View code | `code start_agent_standalone.py` |
| Quick start guide | `.\QUICK_START.ps1` |

---

## What's Happening?

When you test:
1. PowerShell → HTTP POST → http://localhost:8000/messages/send
2. Agent receives message in `start_agent_standalone.py`
3. Agent processes (currently echoes back)
4. Response → JSON → Back to PowerShell

**Edit `start_agent_standalone.py` to change how the agent responds!**
