# Quick Status Checker for Axiom Gladiator Platform
# Run this anytime to check if all services are ready

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         AXIOM GLADIATOR - STATUS CHECK                        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

function Test-ServicePort {
    param($Port, $Name)
    $test = Test-NetConnection localhost -Port $Port -WarningAction SilentlyContinue -InformationLevel Quiet
    $status = if ($test) { "✅ UP  " } else { "❌ DOWN" }
    $color = if ($test) { "Green" } else { "Red" }
    Write-Host "  $Name (Port $Port): $status" -ForegroundColor $color
    return $test
}

# Check services
$backendUp = Test-ServicePort 5003 "Backend   "
$uiUp = Test-ServicePort 3000 "UI        "
$agentUp = Test-ServicePort 8000 "Agent     "

Write-Host ""

# Check agents registered
if ($backendUp) {
    Write-Host "📋 Checking registered agents..." -ForegroundColor Cyan
    try {
        $agents = Invoke-RestMethod -Uri "http://localhost:5003/api/agents" -ErrorAction Stop
        if ($agents.Count -gt 0) {
            Write-Host "  ✅ Found $($agents.Count) agent(s):" -ForegroundColor Green
            foreach ($agent in $agents) {
                Write-Host "     - $($agent.name) [$($agent.status)]" -ForegroundColor Gray
            }
        } 
        else {
            Write-Host "  ⚠️  No agents registered yet" -ForegroundColor Yellow
            Write-Host "     Agent may still be starting up..." -ForegroundColor Gray
        }
    } 
    catch {
        Write-Host "  ⚠️  Backend API not responding yet" -ForegroundColor Yellow
    }
}

Write-Host ""

# Summary
$allUp = $backendUp -and $uiUp -and $agentUp
if ($allUp) {
    Write-Host "🎉 All services are UP! Open http://localhost:3000" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some services are down. Run ORCHESTRATOR_MASTER.ps1 to start them." -ForegroundColor Yellow
}

Write-Host ""
