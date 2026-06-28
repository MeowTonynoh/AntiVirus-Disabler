if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Restart PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit
}

function Disable-WindowsDefender {
    Write-Host "Disabling Windows Defender..." -ForegroundColor Cyan
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableBlockAtFirstSeen $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisablePrivacyMode $true -ErrorAction SilentlyContinue
        Set-MpPreference -SignatureDisableUpdateOnStartupWithoutEngine $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableArchiveScanning $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableIntrusionPreventionSystem $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
        Set-MpPreference -SubmitSamplesConsent 2 -ErrorAction SilentlyContinue
        Write-Host "  [OK] Windows Defender disabled" -ForegroundColor Green
    } catch {
        Write-Host "  [FAIL] Cannot disable Windows Defender" -ForegroundColor Yellow
    }
}

function Disable-ThirdPartyAV {
    param($ServiceName, $DisplayName)
    
    Write-Host "Searching $DisplayName..." -ForegroundColor Cyan
    try {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($service) {
            if ($service.Status -eq 'Running') {
                Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
                Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction SilentlyContinue
                Write-Host "  [OK] $DisplayName disabled" -ForegroundColor Green
                return $true
            } else {
                Write-Host "  [INFO] $DisplayName not running" -ForegroundColor Gray
            }
        }
    } catch {
        Write-Host "  [INFO] $DisplayName not found" -ForegroundColor Gray
    }
    return $false
}

function Disable-AVProcess {
    param($ProcessName, $DisplayName)
    
    try {
        $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        if ($process) {
            Stop-Process -Name $ProcessName -Force -ErrorAction SilentlyContinue
            Write-Host "  [OK] $DisplayName process terminated" -ForegroundColor Green
            return $true
        }
    } catch {
    }
    return $false
}

Clear-Host
Write-Host "====================================================" -ForegroundColor Magenta
Write-Host "    TEMPORARY ANTIVIRUS DISABLER" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Magenta
Write-Host ""

do {
    $confirm = Read-Host "Do you want to disable antivirus? (Y/N)"
    $confirm = $confirm.ToUpper()
} while ($confirm -ne "Y" -and $confirm -ne "N")

if ($confirm -eq "N") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit
}

do {
    $timeInput = Read-Host "For how long? (e.g., 1h, 30m, 2h, 1.5h)"
    
    if ($timeInput -match "(\d+\.?\d*)\s*h") {
        $hours = [double]$matches[1]
        $totalMinutes = $hours * 60
        $timeValid = $true
    } elseif ($timeInput -match "(\d+\.?\d*)\s*m") {
        $totalMinutes = [double]$matches[1]
        $timeValid = $true
    } else {
        Write-Host "Invalid format. Use: 1h, 30m, 2h, 1.5h" -ForegroundColor Red
        $timeValid = $false
    }
} while (-not $timeValid)

$totalSeconds = $totalMinutes * 60
$endTime = (Get-Date).AddMinutes($totalMinutes)

Write-Host ""
Write-Host "Starting antivirus disable..." -ForegroundColor Cyan
Write-Host "Time selected: $totalMinutes minutes" -ForegroundColor Cyan
Write-Host "Expires at: $($endTime.ToString('HH:mm:ss'))" -ForegroundColor Cyan
Write-Host ""

$disabledCount = 0

Disable-WindowsDefender
$disabledCount++

$avList = @(
    @{Service="avast"; Display="Avast"},
    @{Service="avastAntivirus"; Display="Avast Antivirus"},
    @{Service="bdredline"; Display="Bitdefender"},
    @{Service="bdservicehost"; Display="Bitdefender"},
    @{Service="BDESVC"; Display="Bitdefender"},
    @{Service="360AntiHacker"; Display="360 Total Security"},
    @{Service="360rp"; Display="360 Total Security"},
    @{Service="McAfeeEngineService"; Display="McAfee"},
    @{Service="McShield"; Display="McAfee"},
    @{Service="mfefire"; Display="McAfee Firewall"},
    @{Service="mfemms"; Display="McAfee"},
    @{Service="NortonSecurity"; Display="Norton"},
    @{Service="NortonAntiVirus"; Display="Norton"},
    @{Service="ccSvcHst"; Display="Norton"},
    @{Service="kavsvc"; Display="Kaspersky"},
    @{Service="avp"; Display="Kaspersky"},
    @{Service="AVGSvc"; Display="AVG"},
    @{Service="avgAntivirus"; Display="AVG"},
    @{Service="MBAMService"; Display="Malwarebytes"},
    @{Service="MBEndpointAgent"; Display="Malwarebytes"},
    @{Service="SophosVirusProtection"; Display="Sophos"},
    @{Service="SophosMCS"; Display="Sophos"},
    @{Service="ESETService"; Display="ESET"},
    @{Service="ekrn"; Display="ESET"},
    @{Service="PandaAVEngine"; Display="Panda"},
    @{Service="PSUNMain"; Display="Panda"},
    @{Service="F-Secure"; Display="F-Secure"},
    @{Service="fsgk32"; Display="F-Secure"},
    @{Service="TrendMicro"; Display="Trend Micro"},
    @{Service="tmproxy"; Display="Trend Micro"},
    @{Service="Webroot"; Display="Webroot"},
    @{Service="WRSA"; Display="Webroot"},
    @{Service="GData"; Display="G Data"}
)

foreach ($av in $avList) {
    if (Disable-ThirdPartyAV -ServiceName $av.Service -DisplayName $av.Display) {
        $disabledCount++
    }
}

$processList = @(
    @{Process="avastui"; Display="Avast UI"},
    @{Process="AvastSvc"; Display="Avast Service"},
    @{Process="bdagent"; Display="Bitdefender Agent"},
    @{Process="vsserv"; Display="Bitdefender"},
    @{Process="360tray"; Display="360 Total Security"},
    @{Process="McAfeeAP"; Display="McAfee"},
    @{Process="mfevtps"; Display="McAfee"},
    @{Process="ccApp"; Display="Norton"},
    @{Process="ccSvcHst"; Display="Norton"},
    @{Process="avpui"; Display="Kaspersky"},
    @{Process="avgui"; Display="AVG"},
    @{Process="avgwdsvc"; Display="AVG"},
    @{Process="MBAM"; Display="Malwarebytes"},
    @{Process="SophosUI"; Display="Sophos"},
    @{Process="egui"; Display="ESET"},
    @{Process="pavsrv"; Display="Panda"},
    @{Process="fsavui"; Display="F-Secure"},
    @{Process="tmcc"; Display="Trend Micro"},
    @{Process="WRSA"; Display="Webroot"}
)

foreach ($proc in $processList) {
    Disable-AVProcess -ProcessName $proc.Process -DisplayName $proc.Display
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor Magenta
Write-Host "[OK] Disable completed!" -ForegroundColor Green
Write-Host "Antivirus disabled: $disabledCount" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Magenta
Write-Host ""

Write-Host "Re-enable timer started..." -ForegroundColor Cyan
Write-Host "Antivirus will be re-enabled in $totalMinutes minutes" -ForegroundColor Cyan
Write-Host ""

$remainingMinutes = $totalMinutes
while ($remainingMinutes -gt 0) {
    $percent = [math]::Round(($remainingMinutes / $totalMinutes) * 100, 0)
    Write-Progress -Activity "Time remaining until antivirus re-enable" -Status "$remainingMinutes minutes remaining" -PercentComplete (100 - $percent)
    Start-Sleep -Seconds 60
    $remainingMinutes--
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor Magenta
Write-Host "TIME EXPIRED! Re-enabling antivirus..." -ForegroundColor Red
Write-Host "====================================================" -ForegroundColor Magenta

try {
    Set-MpPreference -DisableRealtimeMonitoring $false
    Set-MpPreference -DisableBehaviorMonitoring $false
    Set-MpPreference -DisableBlockAtFirstSeen $false
    Set-MpPreference -DisableIOAVProtection $false
    Set-MpPreference -DisablePrivacyMode $false
    Set-MpPreference -SignatureDisableUpdateOnStartupWithoutEngine $false
    Set-MpPreference -DisableArchiveScanning $false
    Set-MpPreference -DisableIntrusionPreventionSystem $false
    Set-MpPreference -DisableScriptScanning $false
    Set-MpPreference -SubmitSamplesConsent 1
    Write-Host "[OK] Windows Defender re-enabled" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Error re-enabling Windows Defender" -ForegroundColor Red
}

foreach ($av in $avList) {
    try {
        $service = Get-Service -Name $av.Service -ErrorAction SilentlyContinue
        if ($service) {
            Set-Service -Name $av.Service -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name $av.Service -ErrorAction SilentlyContinue
            Write-Host "[OK] $($av.Display) re-enabled" -ForegroundColor Green
        }
    } catch {
    }
}

Write-Host ""
Write-Host "[OK] All antivirus have been re-enabled!" -ForegroundColor Green
Write-Host "It is recommended to restart the system to ensure" -ForegroundColor Yellow
Write-Host "all services are fully functional." -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to exit"