# QUICK START - Axiom Gladiator Platform
# Use this for fast restarts when Docker is already running

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      AXIOM GLADIATOR - QUICK RESTART                           ║" -ForegroundColor Cyan
Write-Host "║      (Use when Docker is already running)                      ║" -ForegroundColor Cyan  
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$AGENT_DIR = "D:\LLM\axiom-agentic-platform\agent"
$BACKEND_DIR = "D:\LLM\scale-agentex\agentex"
$UI_DIR = "D:\LLM\scale-agentex\agentex-ui"
$OPENAI_KEY = $env:OPENAI_API_KEY  # Set via environment variable

# Step 1: Check Docker
Write-Host "[1/4] 🐳 Checking Docker..." -ForegroundColor Cyan
$dockerTest = docker ps 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker daemon not ready. Please wait or run ORCHESTRATOR_MASTER.ps1" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker is ready" -ForegroundColor Green

# Step 2: Start Backend
Write-Host "`n[2/4] 🔧 Starting Backend..." -ForegroundColor Cyan
Set-Location $BACKEND_DIR
docker compose up -d | Out-Null
Start-Sleep -Seconds 12
$backendUp = Test-NetConnection localhost -Port 5003 -WarningAction SilentlyContinue -InformationLevel Quiet
if ($backendUp) {
    Write-Host "✅ Backend is UP on port 5003" -ForegroundColor Green
} 
else {
    Write-Host "⚠️  Backend may need more time..." -ForegroundColor Yellow
}

# Step 3: Start UI
Write-Host "`n[3/4] 🎨 Starting UI..." -ForegroundColor Cyan
$uiScript = @"
Set-Location '$UI_DIR'
Write-Host '🎨 UI Server Starting...' -ForegroundColor Cyan
npm run dev
"@
Start-Process powershell -ArgumentList "-NoExit", "-Command", $uiScript
Start-Sleep -Seconds 15
$uiUp = Test-NetConnection localhost -Port 3000 -WarningAction SilentlyContinue -InformationLevel Quiet
if ($uiUp) {
    Write-Host "✅ UI is UP on port 3000" -ForegroundColor Green
} 
else {
    Write-Host "⚠️  UI may need more time..." -ForegroundColor Yellow
}

# Step 4: Start Agent
Write-Host "`n[4/4] 🤖 Starting Agent..." -ForegroundColor Cyan

# Clean port 8000
$existingProcs = netstat -ano | Select-String ":8000" | ForEach-Object { ($_ -split '\s+')[-1] } | Select-Object -Unique | Where-Object { $_ -match '^\d+$' }
foreach ($procId in $existingProcs) {
    try {
        Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue | Out-Null
    } catch {}
}
Start-Sleep -Seconds 2

# Start agent
$agentScript = @"
Set-Location '$AGENT_DIR'
`$env:PYTHONIOENCODING = 'utf-8'
`$env:OPENAI_API_KEY = '$OPENAI_KEY'
chcp 65001 | Out-Null

Write-Host ''
Write-Host '╔════════════════════════════════════════════╗' -ForegroundColor Magenta
Write-Host '║   AGENT: AXIOM GLADIATOR 13               ║' -ForegroundColor Magenta
Write-Host '║   OpenAI GPT-4o-mini Active               ║' -ForegroundColor Magenta
Write-Host '╚════════════════════════════════════════════╝' -ForegroundColor Magenta
Write-Host ''

agentex agents run --manifest manifest.yaml
"@
Start-Process powershell -ArgumentList "-NoExit", "-NoLogo", "-Command", $agentScript
Start-Sleep -Seconds 10
$agentUp = Test-NetConnection localhost -Port 8000 -WarningAction SilentlyContinue -InformationLevel Quiet
if ($agentUp) {
    Write-Host "✅ Agent is UP on port 8000" -ForegroundColor Green
} 
else {
    Write-Host "⚠️  Agent may need more time..." -ForegroundColor Yellow
}

# Final Status
Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    STARTUP COMPLETE                            ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Backend: http://localhost:5003" -ForegroundColor Cyan
Write-Host "  UI:      http://localhost:3000" -ForegroundColor Cyan
Write-Host "  Agent:   http://localhost:8000" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 Opening browser..." -ForegroundColor Cyan
Start-Sleep -Seconds 3
Start-Process "http://localhost:3000"
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
