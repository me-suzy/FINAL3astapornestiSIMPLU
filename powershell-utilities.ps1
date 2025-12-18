# Scripturi PowerShell Utile pentru Debugging
# Data: 2025-11-24
# Scop: Analiza log-uri, verificare procese, debugging Chrome headless

## 1. VERIFICARE PROCESE CHROME
# ================================

# Lista toate procesele Chrome cu detalii
Get-Process chrome -ErrorAction SilentlyContinue | Select-Object Id, ProcessName, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet64/1MB,2)}}

# Verifică dacă Chrome rulează
if (Get-Process chrome -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Chrome rulează"
} else {
    Write-Host "[INFO] Chrome NU rulează"
}

# Număr total procese Chrome
(Get-Process chrome -ErrorAction SilentlyContinue).Count


## 2. VERIFICARE PORTURI
# =======================

# Verifică dacă portul 9222 este ocupat
Test-NetConnection -ComputerName localhost -Port 9222 -InformationLevel Quiet

# Mai detaliat cu timeout
$result = Test-NetConnection -ComputerName localhost -Port 9222 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($result) {
    Write-Host "[OK] Portul 9222 este DESCHIS (Chrome Debug activ)"
} else {
    Write-Host "[INFO] Portul 9222 este ÎNCHIS"
}

# Verifică toate conexiunile pe portul 9222
netstat -an | Select-String ":9222"


## 3. ANALIZA FISIERE LOG
# ========================

# Citește ultimele 100 linii din log
Get-Content 'chrome-headless-log.txt' -Tail 100

# Caută pattern specific în log
Get-Content 'chrome-headless-log.txt' | Select-String -Pattern "Upload #"

# Numără aparițiile unui pattern
(Get-Content 'chrome-headless-log.txt' | Select-String -Pattern "Upload LANSAT cu succes").Count

# Filtrează și afișează doar liniile cu erori
Get-Content 'chrome-headless-log.txt' | Select-String -Pattern "\[EROARE\]"

# Salvează doar erorile într-un fișier separat
Get-Content 'chrome-headless-log.txt' | Select-String -Pattern "\[EROARE\]" | Out-File 'errors-only.txt'


## 4. LISTARE FISIERE
# ====================

# Listează fișiere .bat, .py, .md
Get-ChildItem -Filter *.bat
Get-ChildItem -Filter *.py
Get-ChildItem -Filter *.md

# Listează cu dimensiuni și data modificării
Get-ChildItem -Filter *.bat | Select-Object Name, Length, LastWriteTime

# Mai multe extensii simultan
Get-ChildItem -Include *.bat,*.py,*.md -Recurse


## 5. COPIERE FISIERE
# ====================

# Copiază fișier cu verificare
Copy-Item "source.txt" -Destination "destination.txt" -Force

# Verifică dacă fișierul există înainte de copiere
if (Test-Path "source.txt") {
    Copy-Item "source.txt" -Destination "destination.txt"
    Write-Host "[OK] Fișier copiat"
} else {
    Write-Host "[EROARE] Fișier sursă nu există"
}


## 6. LOGGING CU TEE (Afișare + Salvare simultan)
# ================================================

# Salvează output-ul ȘI îl afișează în consolă
Get-Process | Tee-Object -FilePath "processes.txt"

# Pentru streaming de la Python script
python script.py 2>&1 | ForEach-Object { 
    Write-Host $_
    Add-Content -Path 'output.log' -Value $_
}

# Varianta simplificată cu Tee-Object
python script.py 2>&1 | Tee-Object -FilePath 'output.log' -Append


## 7. VERIFICARE ENCODING
# ========================

# Verifică encoding-ul unui fișier
$bytes = Get-Content 'file.txt' -Encoding Byte -TotalCount 4
[System.Text.Encoding]::Default.GetString($bytes)

# Conversie UTF-8 -> ASCII
Get-Content 'utf8-file.txt' -Encoding UTF8 | Out-File 'ascii-file.txt' -Encoding ASCII


## 8. CLEANUP (Oprire Chrome, ștergere temporare)
# ================================================

# Oprește toate procesele Chrome
Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue

# Verifică dacă s-au oprit
Start-Sleep -Seconds 2
if (Get-Process chrome -ErrorAction SilentlyContinue) {
    Write-Host "[WARNING] Chrome încă rulează"
} else {
    Write-Host "[OK] Chrome oprit complet"
}

# Șterge fișiere temporare Chrome
Remove-Item "$env:TEMP\ChromeHeadlessAutomation" -Recurse -Force -ErrorAction SilentlyContinue


## 9. MONITORIZARE CONTINUA
# ==========================

# Monitorizează un fișier log în timp real (ca tail -f)
Get-Content 'chrome-headless-log.txt' -Wait -Tail 10

# Monitorizează procesele Chrome la fiecare 5 secunde
while ($true) {
    Clear-Host
    Get-Process chrome -ErrorAction SilentlyContinue | Select-Object Id, ProcessName, @{Name="Memory(MB)";Expression={[math]::Round($_.WorkingSet64/1MB,2)}}
    Start-Sleep -Seconds 5
}


## 10. DEBUGGING BATCH SCRIPTS
# =============================

# Rulează batch script și capturează output-ul
$output = & cmd.exe /c "script.bat" 2>&1
$output | Out-File "batch-output.txt"

# Verifică exit code-ul ultimei comenzi
$LASTEXITCODE
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Script terminat cu succes"
} else {
    Write-Host "[EROARE] Script terminat cu eroare: $LASTEXITCODE"
}


## EXEMPLE COMBINATE
# ===================

# Verifică Chrome + Port + Procesează log
Write-Host "=== VERIFICARE SISTEM ==="
Write-Host ""

# 1. Chrome
if (Get-Process chrome -ErrorAction SilentlyContinue) {
    $chromeCount = (Get-Process chrome -ErrorAction SilentlyContinue).Count
    Write-Host "[OK] Chrome rulează: $chromeCount procese"
} else {
    Write-Host "[INFO] Chrome NU rulează"
}

# 2. Port 9222
$portOpen = Test-NetConnection -ComputerName localhost -Port 9222 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($portOpen) {
    Write-Host "[OK] Port 9222: DESCHIS"
} else {
    Write-Host "[INFO] Port 9222: ÎNCHIS"
}

# 3. Log stats
if (Test-Path "chrome-headless-log.txt") {
    $logSize = (Get-Item "chrome-headless-log.txt").Length / 1KB
    Write-Host "[OK] Log size: $([math]::Round($logSize, 2)) KB"
} else {
    Write-Host "[INFO] Log file nu există"
}
