@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Installazione Italiana TamrielTradeCentre
echo ========================================
echo.

:: Rileva cartella dello script e naviga a TamrielTradeCentre
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"
cd ..\..\..\TamrielTradeCentre

:: Verifica che TamrielTradeCentre esista
if not exist "." (
    echo [ERRORE] TamrielTradeCentre non trovato.
    echo Assicurati che TamrielTradeCentre sia installato nella stessa cartella AddOns di traduzioneitaeso.
    pause
    exit /b 1
)

:: Ottieni percorsi assoluti
for %%i in (.) do set "TTC_PATH=%%~fi"
cd /d "%SCRIPT_DIR%"
cd ..\..
for %%i in (.) do set "TRADITA_PATH=%%~fi"

echo Percorsi rilevati:
echo TamrielTradeCentre: %TTC_PATH%
echo traduzioneitaeso:   %TRADITA_PATH%
echo.
echo Percorsi verificati con successo!
echo.

:: Naviga in TamrielTradeCentre per le operazioni
cd /d "%TTC_PATH%"

:: Crea cartella di backup dentro TamrielTradeCentre
set "BACKUP_DIR=backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "BACKUP_DIR=%BACKUP_DIR: =0%"
echo Creazione backup in: %BACKUP_DIR%
mkdir "%BACKUP_DIR%"

:: Backup file originali
echo Creazione backup...
if exist "TamrielTradeCentre.lua" (
    copy "TamrielTradeCentre.lua" "%BACKUP_DIR%\TamrielTradeCentre.lua.backup" >nul
    echo [OK] TamrielTradeCentre.lua salvato
)
if exist "TamrielTradeCentreInit.lua" (
    copy "TamrielTradeCentreInit.lua" "%BACKUP_DIR%\TamrielTradeCentreInit.lua.backup" >nul
    echo [OK] TamrielTradeCentreInit.lua salvato
)
if exist "TamrielTradeCentre.txt" (
    copy "TamrielTradeCentre.txt" "%BACKUP_DIR%\TamrielTradeCentre.txt.backup" >nul
    echo [OK] TamrielTradeCentre.txt salvato
)
echo Backup completato.
echo.

:: Step 1: Crea ItemLookUpTable italiana
echo Step 1: Creazione ItemLookUpTable italiana...
if exist "ItemLookUpTable_EN.lua" (
    copy "ItemLookUpTable_EN.lua" "ItemLookUpTable_IT.lua" >nul
    echo [OK] ItemLookUpTable_IT.lua creato dalla versione inglese
) else (
    echo [ERRORE] ItemLookUpTable_EN.lua non trovato
    echo Impossibile creare la versione italiana senza il file base inglese.
)
echo.

:: Step 2: Copia generatore ItemLookUpTable italiano
echo Step 2: Installazione generatore ItemLookUpTable italiano...
if exist "%TRADITA_PATH%\addon\TamrielTradeCentreIT\generate_it_itemlookup.lua" (
    copy "%TRADITA_PATH%\addon\TamrielTradeCentreIT\generate_it_itemlookup.lua" "generate_it_itemlookup.lua" >nul
    echo [OK] Generatore ItemLookUpTable italiano installato
) else (
    echo [AVVISO] Generatore ItemLookUpTable italiano non trovato
)
echo.

:: Step 3: Aggiorna TamrielTradeCentre.txt
echo Step 3: Aggiornamento TamrielTradeCentre.txt...
if exist "TamrielTradeCentre.txt" (
    findstr /C:"generate_it_itemlookup.lua" "TamrielTradeCentre.txt" >nul
    if errorlevel 1 (
        powershell -Command "$content = Get-Content 'TamrielTradeCentre.txt'; $newContent = @(); foreach($line in $content) { $newContent += $line; if($line -eq 'TamrielTradeCentreInit.lua') { $newContent += 'generate_it_itemlookup.lua'; } }; $newContent | Set-Content 'TamrielTradeCentre.txt'"
        echo [OK] TamrielTradeCentre.txt aggiornato con il generatore
    ) else (
        echo [OK] Generatore gia incluso in TamrielTradeCentre.txt
    )
) else (
    echo [ERRORE] TamrielTradeCentre.txt non trovato
)
echo.

:: Step 4: Patch TamrielTradeCentre.lua per supporto italiano
echo Step 4: Patch TamrielTradeCentre.lua per supporto italiano...
if exist "TamrielTradeCentre.lua" (
    echo Controllo riga clientCulture attuale...
    findstr /C:"clientCulture" "TamrielTradeCentre.lua"
    echo.
    echo Tentativo di patch...

    powershell -Command "$q=[char]34; $f='TamrielTradeCentre.lua'; $c=[System.IO.File]::ReadAllText($f); $o='clientCulture~= '+$q+'en'+$q+' and clientCulture ~= '+$q+'de'+$q+' and clientCulture ~= '+$q+'fr'+$q+' and clientCulture ~= '+$q+'zh'+$q+' and clientCulture ~= '+$q+'ru'+$q+' and clientCulture ~= '+$q+'es'+$q+' and clientCulture ~= '+$q+'jp'+$q+') then'; $n='clientCulture~= '+$q+'en'+$q+' and clientCulture ~= '+$q+'de'+$q+' and clientCulture ~= '+$q+'fr'+$q+' and clientCulture ~= '+$q+'zh'+$q+' and clientCulture ~= '+$q+'ru'+$q+' and clientCulture ~= '+$q+'es'+$q+' and clientCulture ~= '+$q+'jp'+$q+' and clientCulture ~= '+$q+'it'+$q+') then'; if($c.Contains('clientCulture ~= '+$q+'it'+$q)){Write-Host 'Supporto italiano gia presente'}elseif($c.Contains($o)){$c=$c.Replace($o,$n);[System.IO.File]::WriteAllText($f,$c);Write-Host 'Patch applicata con successo'}else{Write-Host 'Pattern non trovato - patch manuale richiesta'}"

    echo.
    echo Verifica patch...
    findstr /C:"clientCulture ~= " "TamrielTradeCentre.lua" | findstr /C:"it"
    if errorlevel 1 (
        echo [AVVISO] La patch automatica potrebbe non aver funzionato
        echo PATCH MANUALE RICHIESTA - vedi istruzioni sotto
    ) else (
        echo [OK] TamrielTradeCentre.lua patchato con successo
    )
) else (
    echo [ERRORE] TamrielTradeCentre.lua non trovato
)
echo.

:: Step 5: Patch TamrielTradeCentreInit.lua - aggiungi enum IT
echo Step 5: Patch TamrielTradeCentreInit.lua per enum lingua italiana...
if exist "TamrielTradeCentreInit.lua" (
    findstr /C:"IT = 8" "TamrielTradeCentreInit.lua" >nul
    if errorlevel 1 (
        powershell -Command "$content = [System.IO.File]::ReadAllText('TamrielTradeCentreInit.lua'); $content = $content.Replace('JP = 7', 'JP = 7,' + [char]13 + [char]10 + [char]9 + 'IT = 8'); [System.IO.File]::WriteAllText('TamrielTradeCentreInit.lua', $content); Write-Host '[OK] IT = 8 aggiunto'"
    ) else (
        echo [OK] IT = 8 gia presente
    )

    findstr /C:"Italiano" "TamrielTradeCentreInit.lua" >nul
    if errorlevel 1 (
        powershell -Command "$content = [System.IO.File]::ReadAllText('TamrielTradeCentreInit.lua'); $old = '[TamrielTradeCentreLangEnum.JP] = ' + [char]34 + [char]26085 + [char]26412 + [char]35486 + [char]34; $new = '[TamrielTradeCentreLangEnum.JP] = ' + [char]34 + [char]26085 + [char]26412 + [char]35486 + [char]34 + ',' + [char]13 + [char]10 + [char]9 + '[TamrielTradeCentreLangEnum.IT] = ' + [char]34 + 'Italiano' + [char]34; if($content.Contains($old)){$content=$content.Replace($old,$new);[System.IO.File]::WriteAllText('TamrielTradeCentreInit.lua',$content);Write-Host '[OK] Nome Italiano aggiunto'}else{Write-Host '[AVVISO] Riga JP non trovata - aggiunta manuale richiesta'}"
    ) else (
        echo [OK] Nome Italiano gia presente
    )

    echo.
    echo Verifica enum...
    findstr /C:"IT = 8" "TamrielTradeCentreInit.lua" >nul
    if errorlevel 1 (echo [ERRORE] IT = 8 mancante) else (echo [OK] IT = 8 presente)
    findstr /C:"Italiano" "TamrielTradeCentreInit.lua" >nul
    if errorlevel 1 (echo [ERRORE] Nome Italiano mancante) else (echo [OK] Nome Italiano presente)
) else (
    echo [ERRORE] TamrielTradeCentreInit.lua non trovato
)
echo.

:: Step 6: Verifica finale
echo Step 6: Verifica finale...
echo.
echo ========================================
echo Riepilogo Installazione
echo ========================================
echo.
echo [OK] Backup creato in: %BACKUP_DIR%
echo [OK] ItemLookUpTable italiana: ItemLookUpTable_IT.lua
echo [OK] Generatore ItemLookUpTable: generate_it_itemlookup.lua
echo [OK] TamrielTradeCentre.txt aggiornato
echo [OK] TamrielTradeCentre.lua patchato per il supporto italiano
echo [OK] TamrielTradeCentreInit.lua aggiornato con enum italiano
echo.
echo ========================================
echo Prossimi Passi
echo ========================================
echo.
echo 1. Se la patch automatica non ha funzionato, modifica manualmente TamrielTradeCentre.lua:
echo    - Trova la riga con il controllo clientCulture (riga 697 circa)
echo    - Aggiungi " and clientCulture ~= \"it\"" prima della parentesi di chiusura
echo.
echo 2. Riavvia ESO completamente
echo 3. Assicurati che il client ESO sia impostato in italiano
echo 4. Entra nel gioco
echo 5. Verifica che TamrielTradeCentre si carichi senza errori di lingua non supportata
echo 6. Usa /generateit in gioco per creare le mappature degli oggetti in italiano
echo.
echo ========================================
echo Risoluzione Problemi
echo ========================================
echo.
echo Se ricevi ancora l'errore "lingua non supportata":
echo 1. Verifica che il client ESO sia impostato in italiano
echo 2. Controlla che la riga clientCulture in TamrielTradeCentre.lua includa "it"
echo 3. Controlla la cartella backup per i file originali se necessario
echo.
echo Per ripristinare i file originali, copia da: %BACKUP_DIR%
echo.

pause