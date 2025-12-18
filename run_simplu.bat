@echo off
REM Asigura ca lucram din folderul in care este acest fisier .bat
cd /d "%~dp0"

REM TOT ce urmeaza este scris DOAR cu caractere ASCII ca sa nu apara probleme in CMD

REM -----------------------------------------------------
REM 1) Creeaza un fisier de log cu data/ora in nume
REM -----------------------------------------------------
set "LOG_FILE=run_simplu_%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%.log"
set "LOG_FILE=%LOG_FILE: =0%"

echo ========================================== > "%LOG_FILE%"
echo LOG START: %DATE% %TIME% >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo ==========================================
echo   PORNIRE SCRIPT AUTOMATIZARE
echo   Log: %LOG_FILE%
echo ==========================================
echo ========================================== >> "%LOG_FILE%"
echo   PORNIRE SCRIPT AUTOMATIZARE >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo [LOG] Director curent: %CD%
echo [LOG] Director curent: %CD% >> "%LOG_FILE%"
echo [LOG] Data/Ora: %DATE% %TIME%
echo [LOG] Data/Ora: %DATE% %TIME% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM -----------------------------------------------------
REM 2) Verifica daca portul 9222 (Chrome debug) raspunde
REM -----------------------------------------------------
echo [STEP 1] Verificare stare Chrome Debug (port 9222)...
echo [STEP 1] Verificare stare Chrome Debug (port 9222)... >> "%LOG_FILE%"

powershell -Command "$result = Test-NetConnection -ComputerName localhost -Port 9222 -InformationLevel Quiet -WarningAction SilentlyContinue; if ($result) { exit 0 } else { exit 1 }" >nul 2>&1

if %errorlevel% equ 0 (
    echo [INFO] Chrome Debug este DEJA PORNIT si asculta pe portul 9222.
    echo [INFO] Chrome Debug este DEJA PORNIT si asculta pe portul 9222. >> "%LOG_FILE%"
    echo [LOG] Verificare procese Chrome... >> "%LOG_FILE%"
    tasklist | findstr /I chrome.exe >> "%LOG_FILE%" 2>&1
    echo Se porneste direct scriptul Python...
    echo Se porneste direct scriptul Python... >> "%LOG_FILE%"
) else (
    echo [INFO] Chrome Debug NU este pornit.
    echo [INFO] Chrome Debug NU este pornit. >> "%LOG_FILE%"
    echo [LOG] Se lanseaza start_chrome_debug.bat...
    echo [LOG] Se lanseaza start_chrome_debug.bat... >> "%LOG_FILE%"
    start "" "start_chrome_debug.bat"

    echo [LOG] Se asteapta 5 secunde pentru initializarea Chrome...
    echo [LOG] Se asteapta 5 secunde pentru initializarea Chrome... >> "%LOG_FILE%"
    timeout /t 5 >nul

    echo [LOG] Verificare dupa asteptare - portul 9222...
    echo [LOG] Verificare dupa asteptare - portul 9222... >> "%LOG_FILE%"
    powershell -Command "$result = Test-NetConnection -ComputerName localhost -Port 9222 -InformationLevel Quiet -WarningAction SilentlyContinue; if ($result) { Write-Host 'Port 9222 activ'; exit 0 } else { Write-Host 'Port 9222 inactiv'; exit 1 }" >> "%LOG_FILE%" 2>&1
)

REM -----------------------------------------------------
REM 3) Porneste scriptul Python si logheaza output-ul
REM -----------------------------------------------------
echo. >> "%LOG_FILE%"
echo [STEP 2] Pornire script Python... >> "%LOG_FILE%"
echo [STEP 2] Pornire script Python...
echo ==========================================
echo   PORNIRE SCRIPT AUTOMATIZARE
echo ==========================================
echo.

REM Fortam UTF-8 pentru Python (diacriticele din mesaje altfel dau UnicodeEncodeError)
set PYTHONIOENCODING=utf-8
set PYTHONUTF8=1

python "+FINAL 3 - asta pornesti SIMPLU.py" >> "%LOG_FILE%" 2>&1
set "PYTHON_EXITCODE=%errorlevel%"

echo. >> "%LOG_FILE%"
echo [LOG] Script Python s-a incheiat cu codul: %PYTHON_EXITCODE% >> "%LOG_FILE%"
echo [LOG] Script Python s-a incheiat cu codul: %PYTHON_EXITCODE%
echo.
echo Script finalizat.
echo ========================================== >> "%LOG_FILE%"
echo LOG END: %DATE% %TIME% >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"
echo.
echo Log-ul a fost salvat in: %LOG_FILE%
pause
