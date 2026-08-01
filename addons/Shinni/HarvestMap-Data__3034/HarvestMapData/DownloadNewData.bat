
@echo off

REM when running the script as admin, the working directory is c:/windows/system32
REM but we want it to be the file's location
cd %~dp0

echo .
echo .

REM check if we can find the save files
if exist ..\..\SavedVariables goto exists

REM we were not able to find the files!
echo The script could not find your SavedVariables folder.
echo Make sure this script is run from
echo [...]\Elder Scrolls Online\live\AddOns\HarvestMapData
echo Currently the script is run from:
echo %cd%

echo Press any key to close this window.
pause
exit

REM the save files folder exists, so we can try to execute the upload script
:exists
echo You are about to upload and merge your HarvestMap savefiles with the global database.
pause

echo .
echo Creating backup copy of your data

move /Y ..\..\SavedVariables\HarvestMapAD.lua ..\..\SavedVariables\HarvestMapAD-backup.lua"
move /Y ..\..\SavedVariables\HarvestMapEP.lua ..\..\SavedVariables\HarvestMapEP-backup.lua"
move /Y ..\..\SavedVariables\HarvestMapDC.lua ..\..\SavedVariables\HarvestMapDC-backup.lua"
move /Y ..\..\SavedVariables\HarvestMapDLC.lua ..\..\SavedVariables\HarvestMapDLC-backup.lua"
move /Y ..\..\SavedVariables\HarvestMapNF.lua ..\..\SavedVariables\HarvestMapNF-backup.lua"

echo Connecting to database...

%SystemRoot%\System32\cscript.exe //E:jscript //T:0 //nologo Main\upload.js

echo Press any key to close this window.
pause
