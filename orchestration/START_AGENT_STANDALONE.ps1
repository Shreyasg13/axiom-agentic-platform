# STANDALONE AGENT START
# Starts ONLY the agent with proper UTF-8 encoding
# Use this after Backend and UI are already running

param(
    [switch]$SkipChecks
)

Write-Host "`n================================================================================" -ForegroundColor Cyan
Write-Host "AXIOM GLADIATOR 13 - STANDALONE AGENT START" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

$AGENT_DIR = "D:\LLM\axiom-agentic-platform\agent"
$OPENAI_KEY = $env:OPENAI_API_KEY  # Set via environment variable

# Check prerequisites
if (-not $SkipChecks) {
    Write-Host "`nChecking prerequisites..." -ForegroundColor Yellow
    
    # Check Backend
    try {
        $backendTest = Test-NetConnection -ComputerName localhost -Port 5003 -WarningAction SilentlyContinue
        if ($backendTest.TcpTestSucceeded) {
            Write-Host "✅ Backend is running on port 5003" -ForegroundColor Green
        } else {
            Write-Host "❌ Backend is NOT running on port 5003!" -ForegroundColor Red
            Write-Host "   Please start backend first: cd D:\LLM\scale-agentex\agentex; docker compose up -d" -ForegroundColor Yellow
            exit 1
        }
    } catch {
        Write-Host "❌ Cannot check backend status" -ForegroundColor Red
        exit 1
    }
    
    # Check UI
    try {
        $uiTest = Test-NetConnection -ComputerName localhost -Port 3000 -WarningAction SilentlyContinue
        if ($uiTest.TcpTestSucceeded) {
            Write-Host "✅ UI is running on port 3000" -ForegroundColor Green
        } else {
            Write-Host "⚠️  UI is NOT running on port 3000 (optional)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠️  Cannot check UI status" -ForegroundColor Yellow
    }
}

# Kill any existing agent on port 8000
Write-Host "`nCleaning up port 8000..." -ForegroundColor Yellow
$existingProcs = netstat -ano | Select-String ":8000" | ForEach-Object { 
    ($_ -split '\s+')[-1] 
} | Select-Object -Unique | Where-Object { $_ -match '^\d+$' }

foreach ($procId in $existingProcs) {
    try {
        Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
        Write-Host "  Killed process $procId on port 8000" -ForegroundColor Gray
    } catch {
        Write-Host "  Could not kill process $procId" -ForegroundColor Gray
    }
}
Start-Sleep -Seconds 2

# Create the agent start script with proper encoding
Write-Host "`nStarting agent with UTF-8 encoding..." -ForegroundColor Yellow

$agentScript = @"
# Set console to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
`$OutputEncoding = [System.Text.Encoding]::UTF8

# Set environment variables
`$env:PYTHONIOENCODING = 'utf-8'
`$env:OPENAI_API_KEY = '$OPENAI_KEY'

# Change to agent directory
Set-Location '$AGENT_DIR'

# Start agent
Write-Host "Starting agent..." -ForegroundColor Cyan
agentex agents run --manifest manifest.yaml
"@

# Start the agent in a new window
Start-Process powershell -ArgumentList @(
    "-NoExit"
    "-NoLogo"
    "-Command"
    $agentScript
) -WorkingDirectory $AGENT_DIR

Write-Host "✅ Agent process started" -ForegroundColor Green

# Wait for agent to be ready
Write-Host "`nWaiting for agent to start on port 8000..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0

while ($attempt -lt $maxAttempts) {
    $attempt++
    try {
        $test = Test-NetConnection -ComputerName localhost -Port 8000 -WarningAction SilentlyContinue
        if ($test.TcpTestSucceeded) {
            Write-Host "✅ Agent is UP and running on port 8000!" -ForegroundColor Green
            Write-Host "`n================================================================================" -ForegroundColor Cyan
            Write-Host "AGENT STARTED SUCCESSFULLY!" -ForegroundColor Green
            Write-Host "================================================================================" -ForegroundColor Cyan
            Write-Host "
Agent:   http://localhost:8000
Backend: http://localhost:5003
UI:      http://localhost:3000
" -ForegroundColor White
            exit 0
        }
    } catch {
        # Continue waiting
    }
    
    Write-Host "  Attempt $attempt/$maxAttempts..." -ForegroundColor Gray
    Start-Sleep -Seconds 2
}

Write-Host "`n❌ Agent did not start within 60 seconds" -ForegroundColor Red
Write-Host "   Check the agent window for errors" -ForegroundColor Yellow
exit 1
