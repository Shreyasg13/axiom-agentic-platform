# 🏗️ Agent Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     AXIOM-GLADIATOR-13 AGENT                    │
│                      Standalone Architecture                     │
└─────────────────────────────────────────────────────────────────┘

┌────────────────┐         ┌──────────────────┐         ┌─────────────┐
│   Terminal 1   │         │   Terminal 2     │         │   VS Code   │
│                │         │                  │         │             │
│  start_agent   │         │   test_agent     │         │   Edit &    │
│     .ps1       │         │      .ps1        │         │   Save      │
│                │         │                  │         │             │
│  [Keep Open!]  │         │  [Run tests]     │         │  [Auto      │
│                │         │                  │         │   Reload]   │
└────────┬───────┘         └────────┬─────────┘         └──────┬──────┘
         │                          │                           │
         │ Launch                   │ HTTP                      │ Watch
         │                          │ Requests                  │ Changes
         ▼                          ▼                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│               start_agent_standalone.py (Port 8000)              │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐   │
│  │  FastAPI Application                                    │   │
│  │  ┌──────────────────────────────────────────────────┐  │   │
│  │  │  Endpoints:                                       │  │   │
│  │  │                                                    │  │   │
│  │  │  GET  /health                                     │  │   │
│  │  │       → Returns: {"status":"healthy", ...}        │  │   │
│  │  │                                                    │  │   │
│  │  │  POST /messages/send                              │  │   │
│  │  │       ← Receives: {"content":{"text":"..."}}     │  │   │
│  │  │       → Returns: {"author":"agent", ...}         │  │   │
│  │  └──────────────────────────────────────────────────┘  │   │
│  │                                                          │   │
│  │  Uvicorn ASGI Server (--reload enabled)                 │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Request Flow

```
┌──────────────────────────────────────────────────────────────────┐
│  1. Client Sends Request                                          │
└──────────────────────────────────────────────────────────────────┘
                            │
                            │  POST /messages/send
                            │  {"content":{"text":"Hello!"}}
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. FastAPI Receives Request                                      │
│     - Parses JSON body                                            │
│     - Routes to send_message() function                           │
└──────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Agent Processes Message                                       │
│     - Extracts: user_message = "Hello!"                          │
│     - Creates: response_text = "Hello! You said: 'Hello!'..."   │
│     - Builds: response = {"author":"agent", "content":...}       │
└──────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  4. FastAPI Returns Response                                      │
│     - Serializes to JSON                                          │
│     - Sends HTTP 200 OK                                           │
└──────────────────────────────────────────────────────────────────┘
                            │
                            │  Response:
                            │  {"author":"agent", "content":"...", "type":"text"}
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  5. Client Receives Response                                      │
│     - PowerShell displays response object                         │
│     - Test passes ✓                                              │
└──────────────────────────────────────────────────────────────────┘
```

## Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    COMPONENTS                                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────┐
│  start_agent.ps1         │  ← PowerShell script
│  ┌────────────────────┐ │
│  │ Set PATH           │ │
│  │ Navigate to dir    │ │
│  │ Launch uv run      │ │
│  └────────────────────┘ │
└────────────┬────────────┘
             │ Executes
             ▼
┌─────────────────────────┐
│  uv (Package Manager)    │  ← Python environment manager
│  ┌────────────────────┐ │
│  │ Activate .venv     │ │
│  │ Run Python script  │ │
│  └────────────────────┘ │
└────────────┬────────────┘
             │ Starts
             ▼
┌─────────────────────────────────────────┐
│  start_agent_standalone.py               │  ← Main application
│  ┌───────────────────────────────────┐  │
│  │ import FastAPI, Request            │  │
│  │ import uvicorn                     │  │
│  │                                     │  │
│  │ app = FastAPI(...)                 │  │
│  │                                     │  │
│  │ @app.get("/health")                │  │
│  │ async def health(): ...            │  │
│  │                                     │  │
│  │ @app.post("/messages/send")        │  │
│  │ async def send_message(...): ...   │  │
│  │                                     │  │
│  │ uvicorn.run(app, reload=True)      │  │
│  └───────────────────────────────────┘  │
└────────────┬────────────────────────────┘
             │ Runs on
             ▼
┌─────────────────────────┐
│  Uvicorn ASGI Server     │  ← Web server
│  ┌────────────────────┐ │
│  │ Host: 0.0.0.0      │ │
│  │ Port: 8000         │ │
│  │ Reload: True       │ │
│  │ Watch: *.py files  │ │
│  └────────────────────┘ │
└─────────────────────────┘
```

## Test Flow

```
┌─────────────────────────────────────────────────────────────┐
│  test_agent.ps1 Execution Flow                               │
└─────────────────────────────────────────────────────────────┘

Start
  │
  ├─→ Test 1: Health Check
  │   ├─ HTTP GET /health
  │   ├─ Assert: Response received
  │   └─ ✅ Pass
  │
  ├─→ Test 2: Message "Hello! Can you hear me?"
  │   ├─ HTTP POST /messages/send
  │   ├─ Assert: Response contains message
  │   └─ ✅ Pass
  │
  ├─→ Test 3: Message "What is your name?"
  │   ├─ HTTP POST /messages/send
  │   ├─ Assert: Response contains message
  │   └─ ✅ Pass
  │
  ├─→ Test 4: Message "Tell me a joke"
  │   ├─ HTTP POST /messages/send
  │   ├─ Assert: Response contains message
  │   └─ ✅ Pass
  │
  ├─→ Test 5: Message "What is 2 + 2?"
  │   ├─ HTTP POST /messages/send
  │   ├─ Assert: Response contains message
  │   └─ ✅ Pass
  │
  └─→ Summary: 5/5 tests passed 🎉
```

## File Dependencies

```
start_agent.ps1
    │
    ├─→ Requires: uv (installed in PATH)
    ├─→ Executes: start_agent_standalone.py
    └─→ Uses: .venv (Python virtual environment)

start_agent_standalone.py
    │
    ├─→ Imports: fastapi, uvicorn
    ├─→ Reads: (no config files in standalone mode)
    └─→ Listens: Port 8000

test_agent.ps1
    │
    ├─→ Requires: Agent running on port 8000
    ├─→ Uses: Invoke-RestMethod (PowerShell)
    └─→ Tests: GET /health, POST /messages/send

.env (optional)
    │
    ├─→ AGENT_NAME=axiom-gladiator-13
    ├─→ OPENAI_API_KEY=... (for future LLM integration)
    └─→ (Not used in current standalone version)
```

## Deployment Options

```
┌─────────────────────────────────────────────────────────────┐
│  Current: Standalone Mode (What you have now)               │
└─────────────────────────────────────────────────────────────┘

Local Machine
    │
    └─→ start_agent_standalone.py
        └─→ FastAPI + Uvicorn
            └─→ Port 8000
                └─→ No external dependencies

✅ Pros: Simple, fast, easy to debug
❌ Cons: Limited to one machine, manual management


┌─────────────────────────────────────────────────────────────┐
│  Option A: Docker Container (Future)                         │
└─────────────────────────────────────────────────────────────┘

Docker Container
    │
    └─→ Dockerfile
        └─→ Python 3.12 + Dependencies
            └─→ start_agent_standalone.py
                └─→ Exposed Port 8000

✅ Pros: Portable, isolated, easy deployment
❌ Cons: Requires Docker, slightly more complex


┌─────────────────────────────────────────────────────────────┐
│  Option B: Full Agentex Platform (Future)                   │
└─────────────────────────────────────────────────────────────┘

Agentex Backend (Docker Compose)
    │
    ├─→ PostgreSQL (data storage)
    ├─→ Redis (caching)
    ├─→ MongoDB (task storage)
    ├─→ Temporal (workflow orchestration)
    └─→ Agent (project/acp.py with registration)
        └─→ Connected to backend services

✅ Pros: Full platform features, orchestration, UI
❌ Cons: Complex setup, requires all services running
```

## Process Isolation (Critical!)

```
❌ WRONG: Single Terminal
┌────────────────────────┐
│  Terminal              │
│                        │
│  $ .\start_agent.ps1   │
│  Agent running...      │
│                        │
│  $ .\test_agent.ps1    │
│  ← Ctrl+C sent!        │
│  Agent crashed! 💥     │
└────────────────────────┘


✅ RIGHT: Two Terminals
┌────────────────────────┐  ┌────────────────────────┐
│  Terminal 1            │  │  Terminal 2            │
│                        │  │                        │
│  $ .\start_agent.ps1   │  │  $ .\test_agent.ps1    │
│  Agent running...      │  │  Running tests...      │
│  [Keep running! ✓]     │  │  ✅ All tests pass!    │
│                        │  │  $ (can close)         │
└────────────────────────┘  └────────────────────────┘
        │                            │
        │                            │
        └─────────── ✓ ──────────────┘
        Both work independently!
```

## Auto-Reload Mechanism

```
┌─────────────────────────────────────────────────────────────┐
│  Code Change Detection                                       │
└─────────────────────────────────────────────────────────────┘

You edit file
    │
    ▼
start_agent_standalone.py (modified)
    │
    ▼
File System Event
    │
    ▼
Uvicorn Detects Change
    │
    ├─→ Stop current process
    │
    ├─→ Reload code
    │
    └─→ Restart server
        │
        ▼
    Server running with NEW code ✓
        │
        └─→ All connections preserved
            │
            └─→ Tests still work without restart!
```

## Memory Layout

```
┌─────────────────────────────────────────────────────────────┐
│  Running Process: start_agent_standalone.py                  │
└─────────────────────────────────────────────────────────────┘

Memory Segments:
    │
    ├─→ Python Interpreter (3.12.12)
    │   └─→ ~50 MB
    │
    ├─→ FastAPI Framework
    │   └─→ ~20 MB
    │
    ├─→ Uvicorn Server
    │   └─→ ~15 MB
    │
    ├─→ Application Code
    │   └─→ ~1 MB (minimal, no ML models)
    │
    └─→ Network Buffers
        └─→ ~5 MB

Total: ~91 MB (very lightweight!)

(Future with LLM: +500 MB for model loading)
```

## What Makes It "Standalone"?

```
❌ NOT Standalone (Original Agentex)
┌─────────────────────────────────────┐
│  Agent (project/acp.py)              │
│    ├─→ Requires: Agentex Backend   │
│    ├─→ Requires: PostgreSQL         │
│    ├─→ Requires: Redis               │
│    ├─→ Requires: Docker Compose     │
│    └─→ Registration mandatory       │
└─────────────────────────────────────┘


✅ Standalone (Current)
┌─────────────────────────────────────┐
│  Agent (start_agent_standalone.py)   │
│    ├─→ NO Agentex imports           │
│    ├─→ NO registration code         │
│    ├─→ NO database needed           │
│    ├─→ NO Docker needed             │
│    └─→ Pure FastAPI + Uvicorn      │
└─────────────────────────────────────┘
```

## Network Topology

```
┌─────────────────────────────────────────────────────────────┐
│  Localhost Network                                           │
└─────────────────────────────────────────────────────────────┘

127.0.0.1 (localhost)
    │
    ├─→ Port 8000: Agent (start_agent_standalone.py)
    │   └─→ Status: ✅ Active
    │
    ├─→ Port 5003: Agentex Backend (Docker, optional)
    │   └─→ Status: ⚠️  Running but not used
    │
    ├─→ Port 5432: PostgreSQL (Docker, optional)
    │   └─→ Status: ⚠️  Running but not used
    │
    └─→ Port 6379: Redis (Docker, optional)
        └─→ Status: ⚠️  Running but not used

Only Port 8000 is needed for standalone mode!
```

---

**Architecture Summary:**
- **Simple:** Single Python file, no complex dependencies
- **Fast:** Lightweight FastAPI, minimal overhead
- **Flexible:** Easy to modify and extend
- **Reliable:** No external service dependencies
- **Debuggable:** Clear code flow, detailed logs

**Perfect for:** Development, testing, prototyping, learning
**Next Step:** Add LLM integration or deploy to production
