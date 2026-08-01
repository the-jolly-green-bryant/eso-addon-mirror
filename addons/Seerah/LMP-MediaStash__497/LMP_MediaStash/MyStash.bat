@echo off
echo This script will now prepare the files for using LMP_MediaStash_MyStash

if exist ..\LMP_MediaStash_MyStash goto has_folder
echo Creating the folders...
mkdir ..\LMP_MediaStash_MyStash
mkdir ..\LMP_MediaStash_MyStash\background
mkdir ..\LMP_MediaStash_MyStash\border
mkdir ..\LMP_MediaStash_MyStash\font
mkdir ..\LMP_MediaStash_MyStash\sound
mkdir ..\LMP_MediaStash_MyStash\statusbar
echo You can now put your media files into the subfolders found at -User-\Documents\Elder
Scrolls Online\live\AddOns\LMP_MediaStash_MyStash
goto end_of_file

:has_folder
echo Creating the file...
echo local LMP = LibStub("LibMediaProvider-1.0") > ..\LMP_MediaStash_MyStash\MyStash.lua

echo    BACKGROUND
echo.>> ..\LMP_MediaStash_MyStash\MyStash.lua
echo -- ----- >> ..\LMP_MediaStash_MyStash\MyStash.lua
echo -- BACKGROUND >> ..\LMP_MediaStash_MyStash\MyStash.lua
echo -- ----- >> ..\LMP_MediaStash_MyStash\MyStash.lua
for %%F in (..\LMP_MediaStash_MyStash\background\*.*) do (
echo       %%~nF
echo LMP:Register("background", "%%~nF", [[LMP_MediaStash_MyStash\background\%%~nxF]]^) >> ..\LMP_MediaStash_MyStash\MyStash.lua
)

echo    BORDER
echo.>> ..\LMP_MediaStash_MyStash\MyStash.lua
echo -- ----- >> ..\LMP_MediaStash_MyStash\MyStash.lua
echo --  BORDER >> ..\LMP_MediaStash_MyStash\MyStash.lua
echo -- ---- >> ..\LMP_MediaStash_MyStash\MyStash.lua
for %%F in (..\LMP_MediaStash_MyStash\border\*.*) do (
echo       %%~nF
echo LMP:Register("border", "%%~nF", [[LMP_MediaStash_MyStash\border\%%~nxF]]^) >> ..\LMP_MediaStash_MyStash\MyStash.lua
)

echo    FONT
echo.>> ..\LMP_MediaStash_MyStash\MyStash.lua
echo -- ----->> ..\LMP_MediaStash_MyStash\MyStash.lua
echo --   FONT>> ..\LMP_MediaStash_MyStash\MyStash.lua
echo -- ----->> ..\LMP_MediaStash_MyStash\MyStash.lua
for %%F in (..\LMP_MediaStash_MyStash\font\*.ttf) do (
echo       %%~nF
echo LMP:Register("font", "%%~nF", [[LMP_MediaStash_MyStash\font\%%~nxF]]^) >> ..\LMP_MediaStash_MyStash\MyStash.lua
)

echo    SOUND
echo.>> ..\LMP_MediaStash_MyStash\MyStash.lua
echo -- ----->> ..\LMP_MediaStash_MyStash\MyStash.lua
echo --   SOUND>> ..\LMP_MediaStash_MyStash\MyStash.lua
echo -- ----->> ..\LMP_MediaStash_MyStash\MyStash.lua
for %%F in (..\LMP_MediaStash_MyStash\sound\*.*) do (
echo       %%~nF
echo LMP:Register("sound", "%%~nF", [[LMP_MediaStash_MyStash\sound\%%~nxF]]^) >> ..\LMP_MediaStash_MyStash\MyStash.lua
)

echo    STATUSBAR
echo.>> ..\LMP_MediaStash_MyStash\MyStash.lua
echo -- ----->> ..\LMP_MediaStash_MyStash\MyStash.lua
echo --   STATUSBAR>> ..\LMP_MediaStash_MyStash\MyStash.lua
echo -- ----->> ..\LMP_MediaStash_MyStash\MyStash.lua
for %%F in (..\LMP_MediaStash_MyStash\statusbar\*.*) do (
echo       %%~nF
echo LMP:Register("statusbar", "%%~nF", [[LMP_MediaStash_MyStash\statusbar\%%~nxF]]^) >> ..\LMP_MediaStash_MyStash\MyStash.lua
)

:end_of_file
pause