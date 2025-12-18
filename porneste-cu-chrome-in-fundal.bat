@echo off
chcp 65001 >nul
cd /d "%~dp0"

REM Creare fisier log cu timestamp
set LOG_FILE=chrome-headless-log.txt
echo. >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"
echo LOG START: %DATE% %TIME% >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"

echo ==========================================
echo   PORNIRE AUTOMATA cu CHROME IN FUNDAL
echo ==========================================
echo ========================================== >> "%LOG_FILE%"
echo   PORNIRE AUTOMATA cu CHROME IN FUNDAL >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"
echo.
echo Chrome va rula in background (headless mode)
echo - fara interfata vizuala
echo - consum redus de resurse
echo - log salvat in: %LOG_FILE%
echo Chrome va rula in background (headless mode) >> "%LOG_FILE%"
echo - fara interfata vizuala >> "%LOG_FILE%"
echo - consum redus de resurse >> "%LOG_FILE%"
echo.
echo [DEBUG] Director curent: %CD%
echo [DEBUG] Data/Ora: %DATE% %TIME%
echo [DEBUG] Director curent: %CD% >> "%LOG_FILE%"
echo [DEBUG] Data/Ora: %DATE% %TIME% >> "%LOG_FILE%"
echo.

REM Verificare Python
echo [STEP 0] Verificare instalare Python...
echo [STEP 0] Verificare instalare Python... >> "%LOG_FILE%"
python --version >nul 2>&1
if errorlevel 1 (
    echo [EROARE] Python NU este instalat sau NU este in PATH
    echo [EROARE] Python NU este instalat sau NU este in PATH >> "%LOG_FILE%"
    goto END_SCRIPT
)
python --version
python --version >> "%LOG_FILE%" 2>&1
echo [OK] Python este instalat
echo [OK] Python este instalat >> "%LOG_FILE%"
echo.

echo [STEP 1] Verificare daca exista Chrome deschis...
echo [STEP 1] Verificare daca exista Chrome deschis... >> "%LOG_FILE%"
netstat -an | find ":9222" >nul 2>&1

if errorlevel 1 (
    echo [INFO] Niciun Chrome pe portul 9222
    echo [INFO] Niciun Chrome pe portul 9222 >> "%LOG_FILE%"
    echo [STEP 2] Se porneste Chrome COMPLET HEADLESS (fara interfata)
    echo [STEP 2] Se porneste Chrome COMPLET HEADLESS (fara interfata) >> "%LOG_FILE%"
    
    set "CHROME_PATH=C:\Program Files\Google\Chrome\Application\chrome.exe"
    set "PROFILE_DIR=%TEMP%\ChromeHeadlessAutomation"
    
    echo [DEBUG] Chrome Path: %CHROME_PATH%
    echo [DEBUG] Profile Dir: %PROFILE_DIR%
    echo [DEBUG] Mod: HEADLESS (zero interfata vizuala)
    echo [DEBUG] Chrome Path: %CHROME_PATH% >> "%LOG_FILE%"
    echo [DEBUG] Profile Dir: %PROFILE_DIR% >> "%LOG_FILE%"
    echo [DEBUG] Mod: HEADLESS (zero interfata vizuala) >> "%LOG_FILE%"
    echo.
    
    if not exist "%CHROME_PATH%" (
        echo [EROARE] Chrome nu a fost gasit
        echo [EROARE] Cale cautata: %CHROME_PATH%
        echo [EROARE] Chrome nu a fost gasit >> "%LOG_FILE%"
        echo [EROARE] Cale cautata: %CHROME_PATH% >> "%LOG_FILE%"
        goto END_SCRIPT
    )
    
    echo [INFO] Lansare Chrome in mod HEADLESS complet...
    echo [INFO] Lansare Chrome in mod HEADLESS complet... >> "%LOG_FILE%"
    start "" "%CHROME_PATH%" --headless --disable-gpu --remote-debugging-port=9222 --user-data-dir="%PROFILE_DIR%" --no-sandbox --disable-dev-shm-usage --disable-software-rasterizer
    
    echo [INFO] Chrome lansat in fundal (complet invizibil)
    echo [INFO] Chrome lansat in fundal (complet invizibil) >> "%LOG_FILE%"
    echo [STEP 3] Se asteapta 5 secunde pentru initializarea Chrome...
    echo [STEP 3] Se asteapta 5 secunde pentru initializarea Chrome... >> "%LOG_FILE%"
    timeout /t 5 /nobreak
    echo.
) else (
    echo [INFO] Chrome Debug este DEJA PORNIT pe portul 9222
    echo [INFO] Se sare peste lansarea Chrome
    echo [INFO] Chrome Debug este DEJA PORNIT pe portul 9222 >> "%LOG_FILE%"
    echo [INFO] Se sare peste lansarea Chrome >> "%LOG_FILE%"
    echo.
)

echo [STEP 4] Verificare existenta script Python...
echo [STEP 4] Verificare existenta script Python... >> "%LOG_FILE%"
if not exist "+FINAL 3 - asta pornesti SIMPLU.py" (
    echo [EROARE] Scriptul Python nu a fost gasit
    echo [EROARE] Caut: +FINAL 3 - asta pornesti SIMPLU.py
    echo [EROARE] In director: %CD%
    echo [EROARE] Scriptul Python nu a fost gasit >> "%LOG_FILE%"
    echo [EROARE] Caut: +FINAL 3 - asta pornesti SIMPLU.py >> "%LOG_FILE%"
    echo [EROARE] In director: %CD% >> "%LOG_FILE%"
    echo.
    echo Fisiere Python din director:
    dir "*.py" /b
    dir "*.py" /b >> "%LOG_FILE%"
    goto END_SCRIPT
)
echo [OK] Script Python gasit
echo [OK] Script Python gasit >> "%LOG_FILE%"
echo.

echo ==========================================
echo   PORNIRE SCRIPT AUTOMATIZARE
echo ==========================================
echo ========================================== >> "%LOG_FILE%"
echo   PORNIRE SCRIPT AUTOMATIZARE >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"
echo [INFO] Lansez scriptul Python...
echo [INFO] Output-ul Python va aparea mai jos...
echo [INFO] Lansez scriptul Python... >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM CRITICAL: Setare encoding UTF-8 pentru Python pentru a afisa emoji-uri
set PYTHONIOENCODING=utf-8

REM Ruleaza Python - output-ul afisat in CMD si salvat in log
python "+FINAL 3 - asta pornesti SIMPLU.py" 2>&1 | powershell -NoProfile -Command "$OutputEncoding = [System.Text.Encoding]::UTF8; $input | ForEach-Object { Write-Host $_; try { $_ | Out-File -FilePath '%LOG_FILE%' -Append -Encoding UTF8 } catch {} }"

set EXITCODE=%errorlevel%

echo.
echo ==========================================
echo LOG END: %DATE% %TIME%
echo ==========================================
echo. >> "%LOG_FILE%"
echo LOG END: %DATE% %TIME% >> "%LOG_FILE%"
if errorlevel 1 (
    echo [EROARE] Scriptul Python s-a incheiat cu eroare
    echo [EROARE] Exit Code: %EXITCODE%
    echo [EROARE] Scriptul Python s-a incheiat cu eroare >> "%LOG_FILE%"
    echo [EROARE] Exit Code: %EXITCODE% >> "%LOG_FILE%"
) else (
    echo [OK] Script finalizat cu succes
    echo [OK] Script finalizat cu succes >> "%LOG_FILE%"
)

:END_SCRIPT
echo.
echo ==========================================
echo.
echo Apasa orice tasta pentru a inchide fereastra...
pause >nul
