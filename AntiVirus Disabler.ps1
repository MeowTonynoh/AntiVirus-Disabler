if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Restart PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
Clear-Host

$Banner = @"

 ▄▄▄       ███▄    █ ▄▄▄█████▓ ██▓ ██▒   █▓ ██▓ ██▀███   █    ██   ██████    
▒████▄     ██ ▀█   █ ▓  ██▒ ▓▒▓██▒▓██░   █▒▓██▒▓██ ▒ ██▒ ██  ▓██▒▒██    ▒    
▒██  ▀█▄  ▓██  ▀█ ██▒▒ ▓██░ ▒░▒██▒ ▓██  █▒░▒██▒▓██ ░▄█ ▒▓██  ▒██░░ ▓██▄      
░██▄▄▄▄██ ▓██▒  ▐▌██▒░ ▓██▓ ░ ░██░  ▒██ █░░░██░▒██▀▀█▄  ▓▓█  ░██░  ▒   ██▒   
 ▓█   ▓██▒▒██░   ▓██░  ▒██▒ ░ ░██░   ▒▀█░  ░██░░██▓ ▒██▒▒▒█████▓ ▒██████▒▒   
 ▒▒   ▓▒█░░ ▒░   ▒ ▒   ▒ ░░   ░▓     ░ ▐░  ░▓  ░ ▒▓ ░▒▓░░▒▓▒ ▒ ▒ ▒ ▒▓▒ ▒ ░   
  ▒   ▒▒ ░░ ░░   ░ ▒░    ░     ▒ ░   ░ ░░   ▒ ░  ░▒ ░ ▒░░░▒░ ░ ░ ░ ░▒  ░ ░   
  ░   ▒      ░   ░ ░   ░       ▒ ░     ░░   ▒ ░  ░░   ░  ░░░ ░ ░ ░  ░  ░     
      ░  ░         ░           ░        ░   ░     ░        ░           ░     
                                       ░                                     
      ▓█████▄  ██▓  ██████  ▄▄▄       ▄▄▄▄    ██▓    ▓█████  ██▀███          
      ▒██▀ ██▌▓██▒▒██    ▒ ▒████▄    ▓█████▄ ▓██▒    ▓█   ▀ ▓██ ▒ ██▒        
      ░██   █▌▒██▒░ ▓██▄   ▒██  ▀█▄  ▒██▒ ▄██▒██░    ▒███   ▓██ ░▄█ ▒        
      ░▓█▄   ▌░██░  ▒   ██▒░██▄▄▄▄██ ▒██░█▀  ▒██░    ▒▓█  ▄ ▒██▀▀█▄          
      ░▒████▓ ░██░▒██████▒▒ ▓█   ▓██▒░▓█  ▀█▓░██████▒░▒████▒░██▓ ▒██▒        
       ▒▒▓  ▒ ░▓  ▒ ▒▓▒ ▒ ░ ▒▒   ▓▒█░░▒▓███▀▒░ ▒░▓  ░░░ ▒░ ░░ ▒▓ ░▒▓░        
       ░ ▒  ▒  ▒ ░░ ░▒  ░ ░  ▒   ▒▒ ░▒░▒   ░ ░ ░ ▒  ░ ░ ░  ░  ░▒ ░ ▒░        
       ░ ░  ░  ▒ ░░  ░  ░    ░   ▒    ░    ░   ░ ░      ░     ░░   ░         
         ░     ░        ░        ░  ░ ░          ░  ░   ░  ░   ░             
       ░                                   ░
"@

Write-Host $Banner -ForegroundColor White
Write-Host ""
Write-Host "                Made with " -NoNewline
Write-Host "♥ " -ForegroundColor Red -NoNewline
Write-Host "by " -NoNewline
Write-Host "MeowTonynoh" -ForegroundColor White
Write-Host ""
Write-Host ("━" * 76) -ForegroundColor White
Write-Host ""

function Disable-WindowsDefender {
    Write-Host "Disabling Windows Defender..." -ForegroundColor White
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
    
    Write-Host "Searching $DisplayName..." -ForegroundColor White
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

Write-Host "====================================================" -ForegroundColor White
Write-Host "    ANTIVIRUS DISABLER" -ForegroundColor White
Write-Host "====================================================" -ForegroundColor White
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
Write-Host "Starting antivirus disable..." -ForegroundColor White
Write-Host "Time selected: $totalMinutes minutes" -ForegroundColor White
Write-Host "Expires at: $($endTime.ToString('HH:mm:ss'))" -ForegroundColor White
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
Write-Host "====================================================" -ForegroundColor White
Write-Host "[OK] Disable completed!" -ForegroundColor Green
Write-Host "Antivirus disabled: $disabledCount" -ForegroundColor White
Write-Host "====================================================" -ForegroundColor White
Write-Host ""

Write-Host "Re-enable timer started..." -ForegroundColor White
Write-Host "Antivirus will be re-enabled in $totalMinutes minutes" -ForegroundColor White
Write-Host ""

$remainingMinutes = $totalMinutes
while ($remainingMinutes -gt 0) {
    $percent = [math]::Round(($remainingMinutes / $totalMinutes) * 100, 0)
    Write-Progress -Activity "Time remaining until antivirus re-enable" -Status "$remainingMinutes minutes remaining" -PercentComplete (100 - $percent)
    Start-Sleep -Seconds 60
    $remainingMinutes--
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor White
Write-Host "TIME EXPIRED! Re-enabling antivirus..." -ForegroundColor Red
Write-Host "====================================================" -ForegroundColor White

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
Write-Host "It is recommended to restart the system to ensure" -ForegroundColor White
Write-Host "all services are fully functional." -ForegroundColor White
Write-Host ""
Write-Host ("━" * 76) -ForegroundColor White
Write-Host ""
Write-Host "  ✨ Antivirus Disabler complete!" -ForegroundColor White
Write-Host ""
Write-Host "  👤 Created by: " -NoNewline
Write-Host "🌟 " -ForegroundColor Cyan -NoNewline
Write-Host "Tonynoh" -ForegroundColor White
Write-Host "  📱 My Socials: " -NoNewline
Write-Host "💬 " -ForegroundColor Blue -NoNewline
Write-Host "Discord  : " -ForegroundColor Blue -NoNewline
Write-Host "tonyboy90_" -ForegroundColor Blue
Write-Host "                 " -NoNewline
Write-Host "🔗 " -ForegroundColor DarkGray -NoNewline
Write-Host "GitHub   : " -ForegroundColor DarkGray -NoNewline
Write-Host "https://github.com/MeowTonynoh" -ForegroundColor DarkGray
Write-Host "                 " -NoNewline
Write-Host "🎥 " -ForegroundColor Red -NoNewline
Write-Host "YouTube  : " -ForegroundColor Red -NoNewline
Write-Host "tonynoh-07" -ForegroundColor Red
Write-Host ""
Write-Host ("━" * 76) -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to exit"
