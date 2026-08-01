@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Complete TamrielTradeCentre Ukrainian Setup
echo ========================================
echo.

:: Get the script's directory and navigate to TamrielTradeCentre
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"
cd ..\..\..\TamrielTradeCentre

:: Check if TamrielTradeCentre exists
if not exist "." (
    echo ERROR: TamrielTradeCentre addon not found.
    echo Please make sure TamrielTradeCentre is installed in the same AddOns directory as DovahMova.
    pause
    exit /b 1
)

:: Get absolute paths for display
for %%i in (.) do set "TTC_PATH=%%~fi"
cd /d "%SCRIPT_DIR%"
cd ..\..\..
for %%i in (.) do set "DOVAHMOVA_PATH=%%~fi\DovahMova"

echo Detected paths:
echo TamrielTradeCentre: %TTC_PATH%
echo DovahMova: %DOVAHMOVA_PATH%
echo.

echo Paths verified successfully!
echo.

:: Navigate back to TamrielTradeCentre for operations
cd /d "%TTC_PATH%"

:: Create backup directory
set "BACKUP_DIR=backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "BACKUP_DIR=%BACKUP_DIR: =0%"
echo Creating backup at: %BACKUP_DIR%
mkdir "%BACKUP_DIR%"

:: Backup original files
echo Creating backups...
if exist "TamrielTradeCentre.lua" (
    copy "TamrielTradeCentre.lua" "%BACKUP_DIR%\TamrielTradeCentre.lua.backup" >nul
    echo ✓ TamrielTradeCentre.lua backed up
)
if exist "TamrielTradeCentreInit.lua" (
    copy "TamrielTradeCentreInit.lua" "%BACKUP_DIR%\TamrielTradeCentreInit.lua.backup" >nul
    echo ✓ TamrielTradeCentreInit.lua backed up
)
if exist "TamrielTradeCentre.txt" (
    copy "TamrielTradeCentre.txt" "%BACKUP_DIR%\TamrielTradeCentre.txt.backup" >nul
    echo ✓ TamrielTradeCentre.txt backed up
)
echo Backup completed.
echo.

:: Step 1: Create Ukrainian language file
echo Step 1: Creating Ukrainian language file...
if not exist "lang" mkdir "lang"
if exist "%DOVAHMOVA_PATH%\integration\TamrielTradeCentreUA\ua.lua" (
    copy "%DOVAHMOVA_PATH%\integration\TamrielTradeCentreUA\ua.lua" "lang\ua.lua" >nul
    echo ✓ Ukrainian language file created: lang\ua.lua
) else (
    echo Creating Ukrainian language file content...
    echo -- Ukrainian language file for TamrielTradeCentre > "lang\ua.lua"
    echo TTC_PRICE_PRICETOCHAT_UA = "Ціна в чат" >> "lang\ua.lua"
    echo TTC_SEARCHONLINE_UA = "Пошук онлайн" >> "lang\ua.lua"
    echo TTC_PRICEHISTORYONLINE_UA = "Історія цін онлайн" >> "lang\ua.lua"
    echo TTC_ERROR_UNSUPPORTED_LANGUAGE_UA = "Tamriel Trade Centre підтримує українську мову" >> "lang\ua.lua"
    echo TTC_ERROR_NO_PRICE_DATA_UA = "Немає даних про ціни" >> "lang\ua.lua"
    echo TTC_ERROR_ITEM_NOT_FOUND_UA = "Предмет не знайдено" >> "lang\ua.lua"
    echo TTC_MENU_PRICE_INFO_UA = "Інформація про ціну" >> "lang\ua.lua"
    echo TTC_MENU_SEARCH_UA = "Пошук" >> "lang\ua.lua"
    echo TTC_MENU_HISTORY_UA = "Історія" >> "lang\ua.lua"
    echo TTC_PRICE_AVERAGE_UA = "Середня ціна" >> "lang\ua.lua"
    echo TTC_PRICE_MIN_UA = "Мін. ціна" >> "lang\ua.lua"
    echo TTC_PRICE_MAX_UA = "Макс. ціна" >> "lang\ua.lua"
    echo TTC_PRICE_SUGGESTED_UA = "Рекомендована ціна" >> "lang\ua.lua"
    echo TTC_PRICE_LAST_UPDATE_UA = "Останнє оновлення" >> "lang\ua.lua"
    echo TTC_TIME_DAYS_UA = "днів" >> "lang\ua.lua"
    echo TTC_TIME_HOURS_UA = "годин" >> "lang\ua.lua"
    echo TTC_TIME_MINUTES_UA = "хвилин" >> "lang\ua.lua"
    echo TTC_CURRENCY_GOLD_UA = "золото" >> "lang\ua.lua"
    echo TTC_CURRENCY_K_UA = "K" >> "lang\ua.lua"
    echo TTC_CURRENCY_M_UA = "M" >> "lang\ua.lua"
    echo ✓ Ukrainian language file created: lang\ua.lua
)
echo.

:: Step 2: Create Ukrainian ItemLookUpTable
echo Step 2: Creating Ukrainian ItemLookUpTable...
if exist "ItemLookUpTable_EN.lua" (
    copy "ItemLookUpTable_EN.lua" "ItemLookUpTable_UA.lua" >nul
    echo ✓ Ukrainian ItemLookUpTable created from English version
) else (
    echo ✗ ERROR: English ItemLookUpTable not found
    echo Cannot create Ukrainian version without English base file.
)
echo.

:: Step 3: Copy Ukrainian ItemLookUpTable generator
echo Step 3: Installing Ukrainian ItemLookUpTable generator...
if exist "%DOVAHMOVA_PATH%\integration\TamrielTradeCentreUA\generate_ua_itemlookup.lua" (
    copy "%DOVAHMOVA_PATH%\integration\TamrielTradeCentreUA\generate_ua_itemlookup.lua" "generate_ua_itemlookup.lua" >nul
    echo ✓ Ukrainian ItemLookUpTable generator installed
) else (
    echo ✗ WARNING: Ukrainian ItemLookUpTable generator not found
)
echo.

:: Step 5: Update TamrielTradeCentre.txt to include generator
echo Step 5: Updating TamrielTradeCentre.txt...
if exist "TamrielTradeCentre.txt" (
    :: Check if the generator is already included
    findstr /C:"generate_ua_itemlookup.lua" "TamrielTradeCentre.txt" >nul
    if errorlevel 1 (
        :: Insert the generator line right after TamrielTradeCentreInit.lua
        powershell -Command "$content = Get-Content 'TamrielTradeCentre.txt'; $newContent = @(); foreach($line in $content) { $newContent += $line; if($line -eq 'TamrielTradeCentreInit.lua') { $newContent += 'generate_ua_itemlookup.lua'; } }; $newContent | Set-Content 'TamrielTradeCentre.txt'"
        echo ✓ TamrielTradeCentre.txt updated to include generator and debug script
    ) else (
        echo ✓ Generator already included in TamrielTradeCentre.txt
    )
) else (
    echo ✗ ERROR: TamrielTradeCentre.txt not found
)
echo.

:: Step 6: Patch TamrielTradeCentre.lua for Ukrainian language support
echo Step 6: Patching TamrielTradeCentre.lua for Ukrainian support...
if exist "TamrielTradeCentre.lua" (
    echo Checking current language check line...
    findstr /C:"clientCulture" "TamrielTradeCentre.lua"
    echo.
    echo Attempting to patch language support...
    
    :: Try multiple patterns to handle different versions
    powershell -Command "$content = Get-Content 'TamrielTradeCentre.lua' -Raw; $patched = $false; if ($content -match 'if \(clientCulture~= \"en\" and clientCulture ~= \"de\" and clientCulture ~= \"fr\" and clientCulture ~= \"zh\" and clientCulture ~= \"ru\" and clientCulture ~= \"es\" and clientCulture ~= \"jp\"\) then') { $content = $content -replace 'if \(clientCulture~= \"en\" and clientCulture ~= \"de\" and clientCulture ~= \"fr\" and clientCulture ~= \"zh\" and clientCulture ~= \"ru\" and clientCulture ~= \"es\" and clientCulture ~= \"jp\"\) then', 'if (clientCulture~= \"en\" and clientCulture ~= \"de\" and clientCulture ~= \"fr\" and clientCulture ~= \"zh\" and clientCulture ~= \"ru\" and clientCulture ~= \"es\" and clientCulture ~= \"jp\" and clientCulture ~= \"ua\") then'; $patched = $true; Write-Host 'Pattern 1 applied successfully' } elseif ($content -match 'if \(clientCulture ~= \"en\" and clientCulture ~= \"de\" and clientCulture ~= \"fr\" and clientCulture ~= \"zh\" and clientCulture ~= \"ru\" and clientCulture ~= \"es\" and clientCulture ~= \"jp\"\) then') { $content = $content -replace 'if \(clientCulture ~= \"en\" and clientCulture ~= \"de\" and clientCulture ~= \"fr\" and clientCulture ~= \"zh\" and clientCulture ~= \"ru\" and clientCulture ~= \"es\" and clientCulture ~= \"jp\"\) then', 'if (clientCulture ~= \"en\" and clientCulture ~= \"de\" and clientCulture ~= \"fr\" and clientCulture ~= \"zh\" and clientCulture ~= \"ru\" and clientCulture ~= \"es\" and clientCulture ~= \"jp\" and clientCulture ~= \"ua\") then'; $patched = $true; Write-Host 'Pattern 2 applied successfully' } elseif ($content -match 'if \(clientCulture~= \"en\" and clientCulture ~= \"de\" and clientCulture ~= \"fr\" and clientCulture ~= \"zh\" and clientCulture ~= \"ru\" and clientCulture ~= \"es\" and clientCulture ~= \"jp\" and clientCulture ~= \"ua\"\) then') { Write-Host 'Ukrainian language already supported!' } else { Write-Host 'No matching pattern found - manual patch required' }; if ($patched) { Set-Content 'TamrielTradeCentre.lua' $content }"
    
    echo.
    echo Checking if patch was successful...
    findstr /C:"clientCulture.*ua" "TamrielTradeCentre.lua"
    
    if errorlevel 1 (
        echo.
        echo ✗ WARNING: Automatic patch may have failed
        echo MANUAL PATCH REQUIRED - see instructions below
    ) else (
        echo ✓ TamrielTradeCentre.lua patched successfully
    )
) else (
    echo ✗ ERROR: TamrielTradeCentre.lua not found
)
echo.

:: Step 7: Patch TamrielTradeCentreInit.lua to ensure Ukrainian language enum is properly defined
echo Step 7: Verifying Ukrainian language enum in TamrielTradeCentreInit.lua...
if exist "TamrielTradeCentreInit.lua" (
    findstr /C:"UA = 8" "TamrielTradeCentreInit.lua" >nul
    if errorlevel 1 (
        echo ✗ WARNING: Ukrainian language enum may not be properly defined
        echo This might cause issues with language detection
    ) else (
        echo ✓ Ukrainian language enum found in TamrielTradeCentreInit.lua
    )
) else (
    echo ✗ ERROR: TamrielTradeCentreInit.lua not found
)
echo.

:: Step 8: Final verification
echo Step 8: Final verification...
echo.
echo ========================================
echo Setup Summary
echo ========================================
echo.
echo ✓ Backup created at: %BACKUP_DIR%
echo ✓ Ukrainian language file: lang\ua.lua
echo ✓ Ukrainian ItemLookUpTable: ItemLookUpTable_UA.lua
echo ✓ Ukrainian ItemLookUpTable generator: generate_ua_itemlookup.lua
echo ✓ TamrielTradeCentre.txt updated
echo ✓ TamrielTradeCentre.lua patched for Ukrainian support
echo.
echo ========================================
echo Next Steps
echo ========================================
echo.
echo 1. If the automatic patch failed, manually edit TamrielTradeCentre.lua:
echo    - Find the line with clientCulture language check
echo    - Add " and clientCulture ~= \"ua\"" before the closing parenthesis
echo.
echo 2. Restart ESO completely
echo 3. Make sure your ESO client is set to Ukrainian language
echo 4. Load into the game
echo 5. Check if TamrielTradeCentre loads without the "unsupported language" error
echo 6. Use /generateua in-game to create proper Ukrainian item mappings
echo.
echo ========================================
echo Troubleshooting
echo ========================================
echo.
echo If you still get "unsupported language" error:
echo 1. Check that your ESO client language is set to Ukrainian
echo 2. Verify the language check line in TamrielTradeCentre.lua includes "ua"
echo 3. Make sure lang\ua.lua exists and contains Ukrainian strings
echo 4. Check the backup folder for original files if needed
echo.
echo To restore original files, copy from: %BACKUP_DIR%
echo.

pause
