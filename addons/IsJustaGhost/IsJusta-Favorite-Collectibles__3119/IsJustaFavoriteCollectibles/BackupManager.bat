@echo off
setlocal enableDelayedExpansion
REM when running the script as admin, the working directory is c:/windows/system32
REM but we want it to be the file's location
cd %~dp0
set "addonPath=%cd%"

REM Dynamically generate the addon name based on the directory.
for /f %%q in ("%~dp1.") do set "addonName=%%~nxq"

REM Change current directory to ..\Elder Scrolls Online\live\.
cd ..\..\

set "esoLive=%cd%"
set "svPath=%esoLive%\SavedVariables"

REM check if we can find the SavedVariables folder.
if exist "%svPath%\" goto exists

REM we were not able to find the SavedVariables!
echo The script could not find your SavedVariables folder.
echo Make sure this script is run from
echo [...]\Elder Scrolls Online\live\AddOns\IsJustaFavoriteCollectibles
echo Currently the script is run from:
echo %cd%

goto quit

REM the SavedVariables folder exists.
:exists
set "svFile=%svPath%\%addonName%.lua"
set "backupFile=%svPath%\%addonName%.Backup"
set "tempFile=%svPath%\%addonName%.txt"

REM Dose the SavedVariables file exists for this addon.
if exist "%svFile%" (
	if exist "%backupFile%" (goto menu)
	goto replace
)

cls
ECHO.
echo There is no SavedVariables file for %addonName%.
goto quit

REM A current backup exists.
:menu
cls
ECHO.
ECHO    .............................................................
ECHO 	PRESS r OR b to select your task, or Enter to EXIT.
ECHO    .............................................................
ECHO.
ECHO 	b - Backup  - Replaces current backup with current data.
ECHO 	r - Restore - Replaces current data with backup.
ECHO.

SET /P choice=Type r, b then press ENTER:
IF %choice%==r GOTO restoreConfirm
IF %choice%==b GOTO replace

REM this is not working for this menu. instead it just exits.
goto quit

:replace
cls
ECHO.
type "%svFile%" > "%backupFile%"
echo Save data was backed up for %addonName%.
goto quit

:restoreConfirm
cls
ECHO.
ECHO    .............................................................
ECHO 	Are you sure you want to restore the current backup.
ECHO    .............................................................
ECHO.
ECHO 	y - Yes  - Replaces current data with backup.
ECHO.

SET /P choice=Type y then press ENTER:
IF %choice%==y GOTO restore
cls
ECHO.
echo Restore was cancled.
goto quit

:restore
cls
ECHO.
type "%backupFile%" > "%svFile%"
echo Save data for %addonName% was restored from backup.
goto quit

:quit
pause
