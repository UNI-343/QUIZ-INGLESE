@echo off
setlocal EnableDelayedExpansion

git config --global user.name "UNI-343"
git config --global user.email "eskere343@gmail.com"

REM --- Trova il primo file modificato
set "file="
for /f "delims=" %%f in ('git status --porcelain') do (
    set "file=%%f"
    goto :found
)

:found
if "!file!"=="" (
    echo NON CI SONO STATE MODIFICHE
    goto :end
)

REM --- Prendi solo il nome del file con estensione
for %%a in (!file:~3!) do set "filename=%%~nxa"

REM --- Commit message pulito
set "msg=!filename! modificato"
echo Commit message: !msg!

REM --- Git add
git add .
if %errorlevel% neq 0 (
    echo ERRORE: git add non riuscito
) else (
    echo git add completato con successo
)

REM --- Git commit
git commit -m "!msg!"
if %errorlevel% neq 0 (
    echo ERRORE: git commit non riuscito
) else (
    echo git commit completato con successo
)

REM --- Git push
git push
if %errorlevel% neq 0 (
    echo ERRORE: git push non riuscito
) else (
    echo git push completato con successo
)

:end
endlocal
echo Script completato.
pause