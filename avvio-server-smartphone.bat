@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

:: ============================================================
:: Avvio automatico server HTTP locale universale
:: - Usa la cartella dove si trova questo BAT
:: - Cerca index.html automaticamente
:: - Se manca usa il primo file .html trovato
:: - Apre automaticamente il browser
:: - Accesso da telefono tramite IP locale
:: - Rimuove la regola firewall alla chiusura
:: ============================================================

cd /d "%~dp0"


echo Controllo se Python e' installato...
echo.

set "PYCMD="

python --version >nul 2>&1
if !errorlevel! equ 0 (
    set "PYCMD=python"
) else (
    py --version >nul 2>&1
    if !errorlevel! equ 0 (
        set "PYCMD=py"
    )
)

if "!PYCMD!"=="" (

    echo Python non risulta installato.
    echo.

    pause
    exit /b 1
)


:: ------------------------------------------------------------
:: Cerca pagina HTML
:: ------------------------------------------------------------

set "STARTPAGE="

if exist "index.html" (
    set "STARTPAGE=index.html"
) else (

    for %%F in (*.html) do (
        set "STARTPAGE=%%F"
        goto :HTMLFOUND
    )

)

:HTMLFOUND

if "!STARTPAGE!"=="" (

    echo.
    echo ERRORE:
    echo Nessun file HTML trovato nella cartella.
    echo.
    echo Cartella:
    echo %CD%
    echo.

    pause
    exit /b 1
)


:: ------------------------------------------------------------
:: Trova IP locale
:: ------------------------------------------------------------

set "LOCAL_IP="

for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /R /C:"IPv4"') do (

    set "LOCAL_IP=%%A"
    goto :IPFOUND

)

:IPFOUND

set "LOCAL_IP=%LOCAL_IP: =%"


:: ------------------------------------------------------------
:: Firewall
:: ------------------------------------------------------------

echo.
echo Configurazione Firewall...


net session >nul 2>&1

if errorlevel 1 (

    echo Richiesta privilegi amministratore...

    powershell -Command "Start-Process '%~f0' -Verb RunAs"

    exit /b

)


netsh advfirewall firewall delete rule name="LocalServer8080" >nul 2>nul


netsh advfirewall firewall add rule ^
name="LocalServer8080" ^
dir=in ^
action=allow ^
protocol=TCP ^
localport=8080 ^
profile=private >nul



:: ------------------------------------------------------------
:: Avvio server
:: ------------------------------------------------------------

echo.
echo Avvio server...

start "LocalServer8080" /min cmd /c "!PYCMD! -m http.server 8080 --bind 0.0.0.0"


timeout /t 2 >nul


:: Apri automaticamente il file trovato

start "" "http://localhost:8080/!STARTPAGE!"



cls

echo.
echo ===============================================================
echo.
echo              SERVER WEB LOCALE
echo.
echo ===============================================================
echo.
echo File aperto:
echo.
echo     !STARTPAGE!
echo.
echo Sul PC:
echo.
echo     http://localhost:8080/!STARTPAGE!
echo.
echo Sul telefono (stessa rete Wi-Fi):
echo.
echo     http://%LOCAL_IP%:8080/!STARTPAGE!
echo.
echo Cartella:
echo.
echo     %CD%
echo.
echo ===============================================================
echo.
echo Lascia aperta questa finestra.
echo.
echo Premi un tasto per chiudere il server...
pause >nul



:: ------------------------------------------------------------
:: Chiusura
:: ------------------------------------------------------------

taskkill /fi "WINDOWTITLE eq LocalServer8080*" /t /f >nul 2>nul


netsh advfirewall firewall delete rule name="LocalServer8080" >nul 2>nul


echo.
echo Server chiuso.

timeout /t 2 >nul