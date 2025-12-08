# MASTER ORCHESTRATOR - Complete System Startup
# Handles: Docker → Backend → UI → Agent with proper sequencing

Write-Host "`n" -NoNewline
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "║         AXIOM GLADIATOR - MASTER ORCHESTRATOR                  ║" -ForegroundColor Cyan
Write-Host "║         Complete System Startup & Management                   ║" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Configuration
$AGENT_DIR = "D:\LLM\axiom-agentic-platform\agent"
$BACKEND_DIR = "D:\LLM\scale-agentex\agentex"
$UI_DIR = "D:\LLM\scale-agentex\agentex-ui"
$OPENAI_KEY = $env:OPENAI_API_KEY  # Set via environment variable
$LOG_DIR = "D:\LLM\axiom-agentic-platform\logs"

# Create logs directory
if (-not (Test-Path $LOG_DIR)) {
    New-Item -ItemType Directory -Path $LOG_DIR | Out-Null
}

function Write-Log {
    param($Message, $Color = "White")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
    Add-Content -Path "$LOG_DIR\orchestrator.log" -Value "[$timestamp] $Message"
}

function Test-Port {
    param($Port)
    $test = Test-NetConnection -ComputerName localhost -Port $Port -WarningAction SilentlyContinue -InformationLevel Quiet
    return $test
}

function Wait-ForDocker {
    Write-Log "🐳 Checking Docker Desktop..." "Cyan"
    
    # Check if Docker is running
    $dockerTest = docker ps 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Log "⚠️  Docker not running. Starting Docker Desktop..." "Yellow"
        
        # Kill any stuck Docker processes first
        Get-Process "Docker Desktop" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Get-Process "com.docker.*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 5
        
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        Write-Log "⏳ Waiting 60 seconds for Docker to fully initialize..." "Yellow"
        Start-Sleep -Seconds 60
    } else {
        Write-Log "✅ Docker is already running" "Green"
        return $true
    }
    
    # Wait for Docker daemon to be ready with more retries
    Write-Log "⏳ Checking Docker daemon..." "Yellow"
    for ($i = 1; $i -le 30; $i++) {
        try {
            $testResult = docker ps 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Log "✅ Docker daemon is ready!" "Green"
                # Extra verification - try to list containers
                Start-Sleep -Seconds 3
                $verify = docker ps 2>&1
                if ($LASTEXITCODE -eq 0) {
                    return $true
                }
            }
        } catch {}
        
        if ($i % 5 -eq 0) {
            Write-Host " (attempt $i/30)" -ForegroundColor Gray
        } else {
            Write-Host "." -NoNewline
        }
        Start-Sleep -Seconds 3
    }
    
    Write-Log "❌ Docker daemon did not start in time" "Red"
    return $false
}

function Start-BackendServices {
    Write-Log "`n🔧 Starting Backend Services (Docker Compose)..." "Cyan"
    
    Set-Location $BACKEND_DIR
    
    # Verify Docker is still responsive before starting containers
    $dockerCheck = docker ps 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Log "❌ Docker daemon not responding" "Red"
        return $false
    }
    
    # Start containers
    Write-Log "   Starting containers with docker compose..." "Gray"
    $composeOutput = docker compose up -d 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "❌ Failed to start backend containers" "Red"
        Write-Log "   Error: $composeOutput" "Red"
        return $false
    }
    
    Write-Log "⏳ Waiting for backend to be healthy (20 seconds)..." "Yellow"
    Start-Sleep -Seconds 20
    
    # Check containers are actually running
    $runningContainers = docker ps --filter "status=running" --format "{{.Names}}" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $agentexContainers = $runningContainers | Where-Object { $_ -match "agentex" }
        Write-Log "   Found $($agentexContainers.Count) agentex containers running" "Gray"
    }
    
    # Check if backend port is responding
    $maxAttempts = 10
    for ($i = 1; $i -le $maxAttempts; $i++) {
        if (Test-Port 5003) {
            Write-Log "✅ Backend is UP on port 5003" "Green"
            Write-Log "   Running containers: 9" "Gray"
            return $true
        }
        if ($i -lt $maxAttempts) {
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 3
        }
    }
    
    Write-Log "⚠️  Backend port 5003 not responding after $($maxAttempts * 3) seconds" "Yellow"
    return $false
}

function Start-UIService {
    Write-Log "`n🎨 Starting UI Service (Next.js)..." "Cyan"
    
    $uiScript = @"
Set-Location '$UI_DIR'
Write-Host '🎨 Starting Next.js UI...' -ForegroundColor Cyan
npm run dev
"@
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $uiScript
    
    Write-Log "⏳ Waiting for UI to start (20 seconds)..." "Yellow"
    Start-Sleep -Seconds 20
    
    if (Test-Port 3000) {
        Write-Log "✅ UI is UP on port 3000" "Green"
        return $true
    } else {
        Write-Log "⚠️  UI not responding on port 3000 (may need more time)" "Yellow"
        return $false
    }
}

function Start-AgentService {
    Write-Log "`n🤖 Starting Agent Service..." "Cyan"
    
    # Clean up any existing processes on port 8000
    Write-Log "🧹 Cleaning up port 8000..." "Gray"
    $existingProcs = netstat -ano | Select-String ":8000" | ForEach-Object { 
        ($_ -split '\s+')[-1] 
    } | Select-Object -Unique | Where-Object { $_ -match '^\d+$' }
    
    foreach ($procId in $existingProcs) {
        try {
            Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
            Write-Log "   Killed process $procId" "Gray"
        } catch {}
    }
    Start-Sleep -Seconds 2
    
    # Start agent with proper encoding
    $agentScript = @"
# Set console to UTF-8
`$env:PYTHONIOENCODING = 'utf-8'
`$env:OPENAI_API_KEY = '$OPENAI_KEY'
chcp 65001 | Out-Null

# Change to agent directory
Set-Location '$AGENT_DIR'

# Start agent
Write-Host ''
Write-Host '╔════════════════════════════════════════════╗' -ForegroundColor Magenta
Write-Host '║   AGENT: AXIOM GLADIATOR 13               ║' -ForegroundColor Magenta
Write-Host '║   Custom OpenAI Handler Active            ║' -ForegroundColor Magenta
Write-Host '╚════════════════════════════════════════════╝' -ForegroundColor Magenta
Write-Host ''

agentex agents run --manifest manifest.yaml
"@
    
    Start-Process powershell -ArgumentList "-NoExit", "-NoLogo", "-Command", $agentScript -WorkingDirectory $AGENT_DIR
    
    Write-Log "⏳ Waiting for agent to start (30 seconds)..." "Yellow"
    $maxAttempts = 15
    for ($i = 1; $i -le $maxAttempts; $i++) {
        Start-Sleep -Seconds 2
        if (Test-Port 8000) {
            Write-Log "✅ Agent is UP on port 8000" "Green"
            return $true
        }
        Write-Host "." -NoNewline
    }
    
    Write-Log "⚠️  Agent may still be starting (check agent window)" "Yellow"
    return $false
}

function Show-SystemStatus {
    Write-Host "`n"
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                    SYSTEM STATUS                               ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    $services = @(
        @{Name="Backend"; Port=5003; URL="http://localhost:5003"}
        @{Name="UI"; Port=3000; URL="http://localhost:3000"}
        @{Name="Agent"; Port=8000; URL="http://localhost:8000"}
    )
    
    foreach ($service in $services) {
        $status = if (Test-Port $service.Port) { "✅ UP  " } else { "❌ DOWN" }
        $color = if (Test-Port $service.Port) { "Green" } else { "Red" }
        Write-Host "  $($service.Name.PadRight(10)) [$status]  $($service.URL)" -ForegroundColor $color
    }
    
    Write-Host ""
    Write-Host "📋 Logs: $LOG_DIR" -ForegroundColor Gray
    Write-Host ""
}

# MAIN EXECUTION
try {
    Write-Log "🚀 Starting complete system orchestration..." "Cyan"
    Write-Log "============================================" "Cyan"
    
    # Step 1: Ensure Docker is ready
    if (-not (Wait-ForDocker)) {
        Write-Log "❌ Docker failed to start. Cannot proceed." "Red"
        exit 1
    }
    
    # Step 2: Start Backend
    if (-not (Start-BackendServices)) {
        Write-Log "⚠️  Backend may have issues, but continuing..." "Yellow"
    }
    
    # Step 3: Start UI
    Start-UIService | Out-Null
    
    # Step 4: Start Agent
    Start-AgentService | Out-Null
    
    # Final Status
    Write-Host "`n"
    Write-Log "============================================" "Cyan"
    Write-Log "🎉 Orchestration complete!" "Green"
    Write-Log "============================================" "Cyan"
    
    Start-Sleep -Seconds 5
    Show-SystemStatus
    
    # Open browser
    Write-Log "🌐 Opening UI in browser..." "Cyan"
    Start-Sleep -Seconds 3
    Start-Process "http://localhost:3000"
    
    Write-Host "`n"
    Write-Host "Press any key to exit orchestrator..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} catch {
    Write-Log "❌ ERROR: $_" "Red"
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
