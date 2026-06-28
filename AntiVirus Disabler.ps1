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

Write-Host ""
Write-Host "Do you want to disable antivirus? (Y/N): " -NoNewline -ForegroundColor White
$confirm = Read-Host
$confirm = $confirm.ToUpper()

if ($confirm -eq "N") {
    Write-Host ""
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    Write-Host "Press Enter to exit..." -ForegroundColor Gray
    Read-Host
    exit
}

do {
    Write-Host ""
    Write-Host "For how long? (es. 30s, 1m, 2m, 1h, 1.5h): " -NoNewline -ForegroundColor White
    $timeInput = Read-Host
    
    if ($timeInput -match "(\d+\.?\d*)\s*s") {
        $totalSeconds = [double]$matches[1]
        $timeValid = $true
    } elseif ($timeInput -match "(\d+\.?\d*)\s*m") {
        $totalSeconds = [double]$matches[1] * 60
        $timeValid = $true
    } elseif ($timeInput -match "(\d+\.?\d*)\s*h") {
        $totalSeconds = [double]$matches[1] * 3600
        $timeValid = $true
    } else {
        Write-Host "Invalid format. Usa: 30s, 1m, 2h, 1.5h" -ForegroundColor Red
        $timeValid = $false
    }
} while (-not $timeValid)

$totalMinutes = $totalSeconds / 60
$endTime = (Get-Date).AddSeconds($totalSeconds)

Write-Host ""
Write-Host "[*] Starting antivirus disable..." -ForegroundColor White
Write-Host "[*] Time selected: $totalSeconds seconds ($($totalMinutes.ToString('F1')) minutes)" -ForegroundColor White
Write-Host "[*] Expires at: $($endTime.ToString('HH:mm:ss'))" -ForegroundColor White
Write-Host ""

$disabledCount = 0
$disabledList = @()
$disabledServices = @()  # Nomi dei servizi disabilitati (per riattivarli)

if (Disable-WindowsDefender) {
    $disabledCount++
    $disabledList += "Windows Defender"
    # Windows Defender non ha un servizio specifico, lo riattiviamo con i comandi appositi
    $disabledServices += "WindowsDefender"  # marcatore speciale
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
        $disabledServices += $av.Service  # Salva il nome del servizio per riattivarlo
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
        # I processi non hanno un servizio da riavviare, quindi non li aggiungiamo
    }
}

Write-Host ""
Write-Host "[OK] Disable completed!" -ForegroundColor Green
if ($disabledCount -gt 0) {
    Write-Host "[*] Disabled $disabledCount antivirus components:" -ForegroundColor White
    foreach ($item in $disabledList | Select-Object -Unique) {
        Write-Host "  - $item" -ForegroundColor Gray
    }
} else {
    Write-Host "[*] No antivirus components were found to disable." -ForegroundColor Yellow
}
Write-Host ""

if ($disabledCount -eq 0) {
    Write-Host "Operation failed." -ForegroundColor Red
    Write-Host "Press Enter to exit..." -ForegroundColor Gray
    Read-Host
    exit
}

Write-Host "[*] Re-enable timer started..." -ForegroundColor White
Write-Host "[*] Antivirus will be re-enabled in $totalSeconds seconds" -ForegroundColor White
Write-Host ""

# === TIMER CON BARRA DI AVANZAMENTO ROBUSTA ===
$remaining = $totalSeconds
$barLength = 30

while ($remaining -gt 0) {
    $progress = ($totalSeconds - $remaining) / $totalSeconds
    $filled = [math]::Floor($progress * $barLength)
    $empty = $barLength - $filled
    # Usa caratteri semplici per massima compatibilità
    $bar = ("=" * $filled) + ("-" * $empty)
    $percent = [math]::Round($progress * 100, 1)
    
    $minutes = [math]::Floor($remaining / 60)
    $seconds = $remaining % 60
    $hours = [math]::Floor($minutes / 60)
    $minutes = $minutes % 60
    
    if ($hours -gt 0) {
        $timeStr = "$hours`h $minutes`m $seconds`s"
    } elseif ($minutes -gt 0) {
        $timeStr = "$minutes`m $seconds`s"
    } else {
        $timeStr = "$seconds`s"
    }
    
    # Sovrascrivi la riga (funziona con \r)
    Write-Host "`r  [$bar]  $timeStr  ($percent%)  " -ForegroundColor White -NoNewline
    Start-Sleep -Seconds 1
    $remaining--
}

# Timer scaduto
Write-Host "`r  [$bar]  Completed!  (100%)  " -ForegroundColor Green
Write-Host ""

Write-Host ""
Write-Host "[!] TIME EXPIRED! Re-enabling antivirus..." -ForegroundColor Red

# Riattiva solo i servizi che sono stati effettivamente disabilitati
if ($disabledServices -contains "WindowsDefender") {
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
}

# Riattiva i servizi di terze parti disabilitati
foreach ($svcName in $disabledServices) {
    if ($svcName -eq "WindowsDefender") { continue }  # già gestito sopra
    try {
        $service = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if ($service) {
            Set-Service -Name $svcName -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name $svcName -ErrorAction SilentlyContinue
            # Recupera il nome visualizzato dalla lista (opzionale)
            $display = ($avServices | Where-Object { $_.Service -eq $svcName }).Display
            if (-not $display) { $display = $svcName }
            Write-Host "[OK] $display re-enabled" -ForegroundColor Green
        }
    } catch {
    }
}

Write-Host ""
Write-Host "✨ Antivirus Disabler Complete! ✨" -ForegroundColor White
Write-Host ""
Write-Host "👤 Created by: 🐾 Tonynoh" -ForegroundColor White
Write-Host ""
Write-Host "📱 My Socials:" -ForegroundColor White
Write-Host "  💬 Discord   : tonyboy90_" -ForegroundColor White
Write-Host "  🔗 GitHub    : MeowTonynoh" -ForegroundColor White
Write-Host "  🎥 YouTube   : tonynoh-07" -ForegroundColor White
Write-Host ""
Write-Host "🌟 Thanks for using Antivirus Disabler!" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to exit"
