# axiom-gladiator-13 Agent - How to Use

## 🚀 Quick Start (2 Commands!)

### Terminal 1: Start the Agent
```powershell
cd D:\LLM\axiom_gladiator_13
.\start_agent.ps1
```
**Keep this window open!** The agent runs here.

### Terminal 2: Test the Agent
```powershell
cd D:\LLM\axiom_gladiator_13
.\test_agent.ps1
```
**All tests run automatically!** You'll see 5 tests pass.

---

## 📁 What's in This Directory?

| File | Purpose | When to Use |
|------|---------|-------------|
| `start_agent.ps1` | **Start the agent** | Every time you want to run the agent |
| `test_agent.ps1` | **Test the agent** | After starting the agent (in NEW terminal) |
| `QUICK_START.ps1` | **Interactive guide** | First time using the agent |
| `start_agent_standalone.py` | **Agent code** | To modify how the agent behaves |
| `TESTING_CHEATSHEET.md` | **Quick reference** | When you forget commands |
| `TESTING_GUIDE.md` | **Detailed guide** | For troubleshooting |

---

## ⚡ Common Tasks

### Start Agent for First Time
```powershell
.\QUICK_START.ps1
```
This guides you through the process.

### Start Agent (After First Time)
```powershell
.\start_agent.ps1
```

### Test Agent is Working
```powershell
# In a NEW PowerShell window:
.\test_agent.ps1
```

### Stop Agent
In the terminal where agent is running: **Press Ctrl+C**

### Modify Agent Behavior
```powershell
code start_agent_standalone.py
```
The agent auto-reloads when you save!

### Check if Agent is Running
```powershell
Invoke-RestMethod http://localhost:8000/health
```
If it responds, agent is running.

---

## 🎯 What Does the Agent Do?

**Currently:** Echoes back your messages with a friendly greeting.

**Example:**
- You send: "Hello!"
- Agent responds: "Hello! You said: 'Hello!'. I'm axiom-gladiator-13 running standalone!"

**To make it smarter:** Edit `start_agent_standalone.py` and add LLM integration (OpenAI, etc.)

---

## 🔧 Troubleshooting

### "Connection refused" error
**Problem:** Agent not running  
**Solution:** Run `.\start_agent.ps1` in Terminal 1

### "Port 8000 already in use"
**Problem:** Agent already running  
**Solution:** 
```powershell
# Find the process
netstat -ano | findstr "8000"

# Kill it (replace <PID> with the number)
taskkill /PID <PID> /F
```

### Tests fail
**Problem:** Agent crashed or not running  
**Solution:** 
1. Check Terminal 1 - is agent still running?
2. If not, restart with `.\start_agent.ps1`
3. Run tests again in Terminal 2

### Scripts don't run
**Problem:** Not in correct directory  
**Solution:** 
```powershell
cd D:\LLM\axiom_gladiator_13
```

---

## 💡 Key Concepts

### Why Two Terminals?
- **Terminal 1:** Agent runs here (long-running process)
- **Terminal 2:** You run tests here
- **Why separate?** If you run tests in Terminal 1, it interrupts the agent

### Auto-Reload
The agent uses `uvicorn --reload` which means:
- Edit `start_agent_standalone.py`
- Save the file
- Agent automatically restarts with your changes
- No need to stop and start manually!

### Standalone Mode
This agent runs **without Docker** or Agentex backend:
- ✅ Faster startup
- ✅ Easier debugging
- ✅ No complex dependencies
- ❌ Doesn't use Agentex platform features (yet)

---

## 📚 Next Steps

### 1. Make Agent Intelligent
Add LLM integration to give real answers:
```powershell
# Install OpenAI
cd D:\LLM\axiom_gladiator_13
uv add openai

# Edit agent code
code start_agent_standalone.py
```

### 2. Add More Endpoints
Current endpoints:
- `GET /health` - Check if agent is alive
- `POST /messages/send` - Send messages

You can add more in `start_agent_standalone.py`!

### 3. Connect to Agentex Platform
Use the full Agentex features (requires Docker).

### 4. Deploy to Production
Package agent with Docker for deployment.

---

## 🎓 Learning Resources

- **TESTING_CHEATSHEET.md** - Quick commands reference
- **TESTING_GUIDE.md** - Detailed troubleshooting
- **start_agent_standalone.py** - Simple code, easy to understand
- **Scale Agentex Docs** - https://github.com/scaleapi/scale-agentex

---

## ❓ Still Stuck?

1. Check `TESTING_GUIDE.md` for detailed troubleshooting
2. Look at Terminal 1 (agent terminal) for error messages
3. Verify agent is running: `Invoke-RestMethod http://localhost:8000/health`
4. Restart everything:
   - Press Ctrl+C in Terminal 1
   - Run `.\start_agent.ps1` again
   - Run `.\test_agent.ps1` in Terminal 2

---

**Happy Agent Building! 🤖**
