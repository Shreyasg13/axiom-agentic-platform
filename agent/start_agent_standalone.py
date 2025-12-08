"""
Pure standalone ACP server - NO REGISTRATION
Directly serves the FastAPI app without any Agentex backend connection
"""
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import uvicorn

# Create a simple FastAPI app
app = FastAPI(title="axiom-gladiator-13")

@app.get("/health")
async def health():
    return {"status": "healthy", "agent": "axiom-gladiator-13"}

@app.post("/messages/send")
async def send_message(request: Request):
    """Handle incoming messages"""
    body = await request.json()
    user_message = body.get("content", {}).get("text", "")
    
    response_text = f"Hello! You said: '{user_message}'. I'm axiom-gladiator-13 running standalone!"
    
    return {
        "author": "agent",
        "content": response_text,
        "type": "text"
    }

@app.get("/")
async def root():
    return {
        "agent": "axiom-gladiator-13",
        "status": "running",
        "mode": "standalone",
        "endpoints": ["/health", "/messages/send"]
    }

if __name__ == "__main__":
    print("="*60)
    print("🚀 axiom-gladiator-13 Agent - PURE STANDALONE MODE")
    print("="*60)
    print("✅ NO registration - NO Docker - NO Agentex backend needed!")
    print("🌐 Running on: http://localhost:8000")
    print("📡 Test: Invoke-RestMethod http://localhost:8000/health")
    print("🛑 Stop: Press Ctrl+C")
    print("="*60)
    
    uvicorn.run(
        "start_agent_standalone:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
