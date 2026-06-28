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

function Disable-WindowsDefender {
    Write-Host "[*] Disabling Windows Defender..." -ForegroundColor White
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
        return $true
    } catch {
        Write-Host "  [FAIL] Cannot disable Windows Defender" -ForegroundColor Yellow
        return $false
    }
}

function Disable-ThirdPartyAV {
    param($ServiceName, $DisplayName)
    
    try {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($service -and $service.Status -eq 'Running') {
            Write-Host "[*] Disabling $DisplayName..." -ForegroundColor White
            Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
            Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "  [OK] $DisplayName disabled" -ForegroundColor Green
            return $true
        }
    } catch {
    }
    return $false
}

function Disable-AVProcess {
    param($ProcessName, $DisplayName)
    
    try {
        $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "[*] Terminating $DisplayName process..." -ForegroundColor White
            Stop-Process -Name $ProcessName -Force -ErrorAction SilentlyContinue
            Write-Host "  [OK] $DisplayName process terminated" -ForegroundColor Green
            return $true
        }
    } catch {
    }
    return $false
}

function Write-Centered {
    param([string]$Message, [ConsoleColor]$Color = "White")
    $width = $Host.UI.RawUI.WindowSize.Width
    if ($width -eq 0) { $width = 80 }
    $padding = [math]::Max(0, [math]::Floor(($width - $Message.Length) / 2))
    Write-Host (" " * $padding) -NoNewline
    Write-Host $Message -ForegroundColor $Color
}

Write-Host ""
$question = "    Do you want to disable antivirus? (Y/N): "
Write-Host (" " * [math]::Max(0, [math]::Floor((80 - $question.Length) / 2))) -NoNewline
Write-Host $question -NoNewline -ForegroundColor White
$confirm = Read-Host
$confirm = $confirm.ToUpper()

if ($confirm -eq "N") {
    Write-Host ""
    Write-Centered -Message "Operation cancelled." -Color Yellow
    Write-Centered -Message "Press Enter to exit..." -Color Gray
    Read-Host
    exit
}

do {
    Write-Host ""
    $question2 = "    For how long? (e.g., 30s, 1m, 1h, 2h30m): "
    Write-Host (" " * [math]::Max(0, [math]::Floor((80 - $question2.Length) / 2))) -NoNewline
    Write-Host $question2 -NoNewline -ForegroundColor White
    $timeInput = Read-Host
    
    $totalSeconds = 0
    $timeValid = $false
    
    if ($timeInput -match "(\d+)\s*s") {
        $totalSeconds = [int]$matches[1]
        $timeValid = $true
    }
    elseif ($timeInput -match "(\d+)\s*m") {
        $totalSeconds = [int]$matches[1] * 60
        $timeValid = $true
    }
    elseif ($timeInput -match "(\d+)\s*h") {
        $totalSeconds = [int]$matches[1] * 3600
        $timeValid = $true
    }
    elseif ($timeInput -match "(\d+)\s*h\s*(\d+)\s*m") {
        $totalSeconds = ([int]$matches[1] * 3600) + ([int]$matches[2] * 60)
        $timeValid = $true
    }
    elseif ($timeInput -match "(\d+)\s*m\s*(\d+)\s*s") {
        $totalSeconds = ([int]$matches[1] * 60) + [int]$matches[2]
        $timeValid = $true
    }
    elseif ($timeInput -match "(\d+\.?\d*)\s*h") {
        $hours = [double]$matches[1]
        $totalSeconds = [int]($hours * 3600)
        $timeValid = $true
    }
    elseif ($timeInput -match "(\d+\.?\d*)\s*m") {
        $minutes = [double]$matches[1]
        $totalSeconds = [int]($minutes * 60)
        $timeValid = $true
    }
    
    if (-not $timeValid -or $totalSeconds -le 0) {
        Write-Host ""
        Write-Centered -Message "Invalid format. Use: 30s, 1m, 1h, 2h30m, 1.5h" -Color Red
        $timeValid = $false
    }
} while (-not $timeValid)

$totalMinutes = [math]::Round($totalSeconds / 60, 2)
$endTime = (Get-Date).AddSeconds($totalSeconds)

if ($totalSeconds -ge 3600) {
    $hours = [math]::Floor($totalSeconds / 3600)
    $minutes = [math]::Floor(($totalSeconds % 3600) / 60)
    $timeDisplay = if ($minutes -gt 0) { "$hours h $minutes m" } else { "$hours h" }
} elseif ($totalSeconds -ge 60) {
    $minutes = [math]::Floor($totalSeconds / 60)
    $seconds = $totalSeconds % 60
    $timeDisplay = if ($seconds -gt 0) { "$minutes m $seconds s" } else { "$minutes m" }
} else {
    $timeDisplay = "$totalSeconds s"
}

Write-Host ""
Write-Centered -Message "[*] Starting antivirus disable..." -Color White
Write-Centered -Message "[*] Time selected: $timeDisplay" -Color White
Write-Centered -Message "[*] Expires at: $($endTime.ToString('HH:mm:ss'))" -Color White
Write-Host ""

$disabledCount = 0
$disabledList = @()

if (Disable-WindowsDefender) {
    $disabledCount++
    $disabledList += "Windows Defender"
}

$avServices = @(
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

foreach ($av in $avServices) {
    if (Disable-ThirdPartyAV -ServiceName $av.Service -DisplayName $av.Display) {
        $disabledCount++
        $disabledList += $av.Display
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
    if (Disable-AVProcess -ProcessName $proc.Process -DisplayName $proc.Display) {
        $disabledCount++
        $disabledList += $proc.Display
    }
}

Write-Host ""
Write-Centered -Message "[OK] Disable completed!" -Color Green
if ($disabledCount -gt 0) {
    Write-Centered -Message "[*] Disabled $disabledCount antivirus components:" -Color White
    foreach ($item in $disabledList | Select-Object -Unique) {
        Write-Centered -Message "    - $item" -Color Gray
    }
} else {
    Write-Centered -Message "[*] No antivirus components were found to disable." -Color Yellow
}
Write-Host ""

if ($disabledCount -eq 0) {
    Write-Centered -Message "Operation failed." -Color Red
    Write-Centered -Message "Press Enter to exit..." -Color Gray
    Read-Host
    exit
}

Write-Centered -Message "[*] Re-enable timer started..." -Color White
Write-Centered -Message "[*] Antivirus will be re-enabled in $timeDisplay" -Color White
Write-Host ""

$compassFrames = @("N", "NE", "E", "SE", "S", "SW", "W", "NW")
$frameIndex = 0

$remainingSeconds = $totalSeconds
while ($remainingSeconds -gt 0) {
    if ($remainingSeconds -ge 3600) {
        $hours = [math]::Floor($remainingSeconds / 3600)
        $minutes = [math]::Floor(($remainingSeconds % 3600) / 60)
        $secs = $remainingSeconds % 60
        $timeStr = "$hours h $minutes m $secs s"
    } elseif ($remainingSeconds -ge 60) {
        $minutes = [math]::Floor($remainingSeconds / 60)
        $secs = $remainingSeconds % 60
        $timeStr = "$minutes m $secs s"
    } else {
        $timeStr = "$remainingSeconds s"
    }
    
    $compass = $compassFrames[$frameIndex % $compassFrames.Length]
    $frameIndex++
    
    $fullMsg = "  $compass  [*] Time remaining: $timeStr"
    $padding = [math]::Max(0, [math]::Floor((80 - $fullMsg.Length) / 2))
    Write-Host (" " * $padding) -NoNewline
    Write-Host $fullMsg -ForegroundColor White -NoNewline
    Write-Host (" " * [math]::Max(0, 80 - $fullMsg.Length - $padding)) -NoNewline
    Start-Sleep -Seconds 1
    $remainingSeconds--
    if ($remainingSeconds -gt 0) {
        Write-Host "`r" -NoNewline
    }
}
Write-Host ""

Write-Host ""
Write-Centered -Message "[!] TIME EXPIRED! Re-enabling antivirus..." -Color Red

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
    Write-Centered -Message "[OK] Windows Defender re-enabled" -Color Green
} catch {
    Write-Centered -Message "[FAIL] Error re-enabling Windows Defender" -Color Red
}

foreach ($av in $avServices) {
    try {
        $service = Get-Service -Name $av.Service -ErrorAction SilentlyContinue
        if ($service) {
            Set-Service -Name $av.Service -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name $av.Service -ErrorAction SilentlyContinue
            Write-Centered -Message "[OK] $($av.Display) re-enabled" -Color Green
        }
    } catch {
    }
}

Write-Host ""
Write-Centered -Message "[OK] All antivirus have been re-enabled!" -Color Green
Write-Centered -Message "[*] It is recommended to restart the system to ensure" -Color White
Write-Centered -Message "[*] all services are fully functional." -Color White
Write-Host ""
Write-Centered -Message "  ✨ Antivirus Disabler complete!" -Color White
Write-Host ""
Write-Centered -Message "  👤 Created by: 🌟 Tonynoh" -Color White
Write-Host ""
Write-Centered -Message "  📱 My Socials:" -Color White
Write-Centered -Message "  💬 Discord  : tonyboy90_" -Color White
Write-Centered -Message "  🔗 GitHub   : https://github.com/MeowTonynoh" -Color White
Write-Centered -Message "  🎥 YouTube  : tonynoh-07" -Color White
Write-Host ""

Read-Host "Press Enter to exit"
