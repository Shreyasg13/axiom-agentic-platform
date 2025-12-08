# Testing Guide for axiom-gladiator-13 Agent

## Quick Start - Local Testing (No Docker Required)

Your agent can run **standalone** without Docker! This is the simplest way to test locally.

### 1. Start the Agent (Standalone Mode)

```powershell
# Option A: Use the helper script
cd D:\LLM\axiom_gladiator_13
.\start_agent.ps1

# Option B: Manual command
cd D:\LLM\axiom_gladiator_13
$env:Path = "C:\Users\$env:USERNAME\.local\bin;$env:Path"
agentex agents run --manifest manifest.yaml
```

The agent will start on **http://localhost:8000**

### 2. Test the Agent - Simple curl Commands

Open a **NEW PowerShell terminal** (keep the agent running in the first one):

```powershell
# Test 1: Health check
curl http://localhost:8000/health

# Test 2: Get agent info
curl http://localhost:8000/agent-info

# Test 3: Send a message (ACP protocol)
$body = @{
    content = @{
        type = "text"
        text = "Hello agent! What can you do?"
    }
} | ConvertTo-Json

curl -Method POST `
  -Uri "http://localhost:8000/messages/send" `
  -ContentType "application/json" `
  -Body $body
```

### 3. Interactive Python Testing

```powershell
cd D:\LLM\axiom_gladiator_13
$env:Path = "C:\Users\$env:USERNAME\.local\bin;$env:Path"
uv run python interactive_test.py
```

This will:
- Check if agent is running
- Send test messages
- Let you chat interactively

### 4. Run Automated Tests

```powershell
cd D:\LLM\axiom_gladiator_13
.\test_agent.ps1
```

---

## Full Stack Testing (With Docker)

For the complete Agentex platform experience with UI, task management, and Temporal workflows.

### 1. Start Docker Desktop

**Important:** Make sure Docker Desktop is running!
- Open Docker Desktop application
- Wait for it to fully start (whale icon in system tray)
- Verify: `docker ps` should work

### 2. Start Agentex Services

```powershell
cd D:\LLM\scale-agentex
docker compose up -d
```

Wait for all containers to be healthy (~15-30 seconds):
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### 3. Start Your Agent

```powershell
cd D:\LLM\axiom_gladiator_13
.\start_agent.ps1
```

The agent will:
- Start on port 8000
- Automatically register with Agentex backend
- Be available for task creation

### 4. Access the Web Interfaces

- **Temporal UI**: http://localhost:8080 (workflow monitoring)
- **Agentex Backend API**: http://localhost:5003/docs (Swagger UI)

### 5. Create Tasks via API

```powershell
# Create a task
$taskBody = @{
    input = @{
        messages = @(
            @{
                role = "user"
                content = "Explain quantum computing in simple terms"
            }
        )
    }
} | ConvertTo-Json -Depth 3

$response = Invoke-RestMethod `
  -Uri "http://localhost:5003/api/agents/axiom-gladiator-13/tasks" `
  -Method POST `
  -Body $taskBody `
  -ContentType "application/json"

Write-Host "Task ID: $($response.task_id)"

# Get task result
$taskId = $response.task_id
Invoke-RestMethod `
  -Uri "http://localhost:5003/api/agents/axiom-gladiator-13/tasks/$taskId" `
  -Method GET
```

---

## Modify Your Agent

### Edit the Agent Code

```powershell
# Open in VS Code
code D:\LLM\axiom_gladiator_13\project\acp.py
```

The agent automatically reloads when you save changes!

### Example: Add LLM Integration

Update `project/acp.py`:

```python
from typing import AsyncGenerator
from agentex.lib.sdk.fastacp.fastacp import FastACP
from agentex.lib.types.acp import SendMessageParams
from agentex.types.task_message_update import TaskMessageUpdate
from agentex.types.task_message_content import TaskMessageContent
from agentex.types.text_content import TextContent
from agentex.lib.utils.logging import make_logger

# Add OpenAI client
import openai
import os

logger = make_logger(__name__)

# Initialize OpenAI (make sure OPENAI_API_KEY is in .env)
openai.api_key = os.getenv("OPENAI_API_KEY")

acp = FastACP.create(acp_type="sync")

@acp.on_message_send
async def handle_message_send(
    params: SendMessageParams
) -> TaskMessageContent:
    """Handle message with OpenAI"""
    
    user_message = params.content.content
    logger.info(f"Received message: {user_message}")
    
    try:
        # Call OpenAI
        response = openai.chat.completions.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": user_message}
            ]
        )
        
        ai_response = response.choices[0].message.content
        
        return TextContent(
            author="agent",
            content=ai_response
        )
    except Exception as e:
        logger.error(f"Error calling OpenAI: {e}")
        return TextContent(
            author="agent",
            content=f"Sorry, I encountered an error: {str(e)}"
        )
```

Then add your API key:
```powershell
cd D:\LLM\axiom_gladiator_13
notepad .env
# Add: OPENAI_API_KEY=sk-your-actual-key-here
```

---

## Troubleshooting

### Agent Not Starting

**Problem:** `Manifest file not found`
```powershell
# Make sure you're in the agent directory
cd D:\LLM\axiom_gladiator_13
ls manifest.yaml  # Should exist
```

**Problem:** `agentex: The term 'agentex' is not recognized`
```powershell
# Add uv to PATH
$env:Path = "C:\Users\$env:USERNAME\.local\bin;$env:Path"
```

### Connection Errors

**Problem:** `All connection attempts failed`
- This means Agentex backend (Docker) is not running
- For standalone testing, you can **ignore this** - the agent still works!
- For full stack, start Docker: `docker compose up -d`

### Port Already in Use

```powershell
# Check what's using port 8000
netstat -ano | findstr "8000"

# Kill the process
taskkill /PID <process-id> /F
```

### Docker Not Running

```powershell
# Check if Docker Desktop is running
docker ps

# If it fails, open Docker Desktop application
```

---

## Testing Checklist

### Standalone Mode (No Docker)
- [ ] Agent starts on port 8000
- [ ] Health endpoint responds: `curl http://localhost:8000/health`
- [ ] Can send messages via curl
- [ ] Python interactive test works
- [ ] Agent reloads when code changes

### Full Stack Mode (With Docker)
- [ ] Docker Desktop running
- [ ] All 9 containers healthy
- [ ] Agent registers with backend
- [ ] Can create tasks via API
- [ ] Temporal UI shows workflows
- [ ] Backend API docs accessible

---

## Next Steps

1. **Test Standalone** - Start with simple local testing
2. **Add LLM Integration** - Connect OpenAI or another provider
3. **Install Node.js** - For the Agentex UI (http://localhost:3000)
4. **Create Complex Workflows** - Use Temporal for multi-step tasks
5. **Deploy to Production** - Use Docker to deploy your agent

---

## Quick Reference

### Ports
- **8000** - Your agent (ACP server)
- **5003** - Agentex backend
- **5432** - PostgreSQL
- **6379** - Redis
- **7233** - Temporal
- **8080** - Temporal UI
- **27017** - MongoDB

### Important Files
- `project/acp.py` - Your agent code (edit this!)
- `manifest.yaml` - Agent configuration
- `.env` - API keys and secrets
- `start_agent.ps1` - Helper script to start agent
- `test_agent.ps1` - Automated tests

### Useful Commands
```powershell
# Start agent
.\start_agent.ps1

# Run tests
.\test_agent.ps1

# Interactive testing
uv run python interactive_test.py

# Check Docker
docker ps

# View agent logs
# (logs appear in terminal where agent is running)

# Stop Docker services
cd D:\LLM\scale-agentex
docker compose down
```
