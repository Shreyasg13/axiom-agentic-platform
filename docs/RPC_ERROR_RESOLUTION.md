# 🎯 ISSUE RESOLVED: RPC Error -32603

## Problem Statement
After starting all services (Backend on 5003, UI on 3000, Agent on 8000), the UI displayed:
```
Failed to send message
RPC error: {'code': -32603, 'message': 'AGENT', 'data': None}
```

## Root Cause Analysis

### What Happened
The agent **appeared** to be running (port 8000 showed as UP) but was actually **crashed** during startup. The port was held by a ghost process from a previous failed startup attempt.

### Why It Happened
1. **Unicode Encoding Error:** The Agentex SDK uses UTF-8 characters (emojis like 🚀) in its output
2. **Windows Default Encoding:** PowerShell uses cp1252 encoding by default
3. **Startup Crash:** Agent crashed immediately with `UnicodeEncodeError: 'charmap' codec can't encode character '\U0001f680'`
4. **Port Ghost:** Port 8000 remained occupied by the crashed process
5. **RPC Error:** When UI tried to communicate with the agent, it got error -32603 because the agent wasn't actually processing requests

### Evidence from Logs
```
D:\LLM\axiom_gladiator_13\logs\agent.log:

UnicodeEncodeError: 'charmap' codec can't encode character '\U0001f680' in position 0: character maps to <undefined>

RuntimeError: Failed to run agent: 'charmap' codec can't encode character '\U0001f680' in position 0: character maps to <undefined>
```

## Solution Implemented

### 1. Created START_AGENT_STANDALONE.ps1
A dedicated script that properly starts the agent with:
- ✅ UTF-8 encoding configuration
- ✅ Pre-flight checks (Backend and UI running)
- ✅ Port cleanup (kills ghost processes)
- ✅ Proper environment variable setup
- ✅ Health monitoring (waits for agent to be ready)

### 2. Key Fix: UTF-8 Encoding
The script sets encoding **before** starting the agent:

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = 'utf-8'
```

### 3. Updated START_SIMPLE.ps1
Modified the all-in-one startup script to include UTF-8 encoding when starting the agent.

### 4. Updated START_PLATFORM.ps1
Modified the orchestrator to include UTF-8 encoding in the agent startup command.

## How to Use

### Quick Start (Recommended)
If Backend and UI are already running:
```powershell
cd D:\LLM\axiom_gladiator_13
.\START_AGENT_STANDALONE.ps1
```

### Start Everything Together
```powershell
cd D:\LLM\axiom_gladiator_13
.\START_SIMPLE.ps1
```

## Verification Steps

After starting the agent, verify it's working:

1. **Check Ports:**
   ```powershell
   Test-NetConnection localhost -Port 8000
   # Should show: TcpTestSucceeded : True
   ```

2. **Check Agent Window:**
   Should see:
   ```
   ================================================================================
   LOADING CUSTOM ACP.PY - THIS SHOULD APPEAR IN LOGS
   ================================================================================
   REGISTERING CUSTOM HANDLER - handle_message_send
   Successfully registered agent 'axiom-gladiator-13' with Agentex server
   ```

3. **Test in UI:**
   - Open http://localhost:3000
   - Send a message like "What is 5 x 7?"
   - Should get OpenAI-powered response
   - Should NOT get "RPC error: -32603"

## Files Modified/Created

1. **D:\LLM\axiom_gladiator_13\START_AGENT_STANDALONE.ps1** - NEW
   - Standalone agent starter with UTF-8 encoding
   - Pre-flight checks
   - Port cleanup
   - Health monitoring

2. **D:\LLM\axiom_gladiator_13\START_SIMPLE.ps1** - MODIFIED
   - Added UTF-8 encoding to agent startup command

3. **D:\LLM\axiom_gladiator_13\START_PLATFORM.ps1** - MODIFIED
   - Added UTF-8 encoding to agent startup command in orchestrator

## Lessons Learned

### 1. Port UP ≠ Service Healthy
Just because a port responds doesn't mean the service is functioning. Always check actual service logs and behavior.

### 2. Windows Encoding Issues
Windows PowerShell default encoding (cp1252) is incompatible with UTF-8 emojis. Always set UTF-8 encoding when working with modern Python tools.

### 3. Ghost Processes
Failed startups can leave ports occupied. Always clean up ports before restarting services.

### 4. Proper Startup Sequence
Backend → UI → Agent (with proper encoding)

## Prevention Checklist

To avoid this issue in the future:

- [ ] Always use START_AGENT_STANDALONE.ps1 or START_SIMPLE.ps1
- [ ] Never start agent directly with `agentex agents run` without encoding setup
- [ ] Check agent window for actual startup messages, not just port status
- [ ] Clean up ports before restarting: Kill processes on 8000 if needed
- [ ] Verify agent logs show successful registration
- [ ] Test with actual message in UI, not just port checks

## Status: ✅ RESOLVED

The agent is now running properly with:
- ✅ Correct UTF-8 encoding
- ✅ Successfully registered with backend
- ✅ Custom handler code loading
- ✅ Ready to process messages via UI

**Date:** December 7, 2025
**Resolution Time:** ~30 minutes
**Impact:** Agent now fully functional without RPC errors
