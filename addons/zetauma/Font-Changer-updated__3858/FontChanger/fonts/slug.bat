@echo off
setlocal EnableDelayedExpansion

set slugfont_exe_file=slugfont.exe

:: Check if the slugfont.exe is present
if exist "%slugfont_exe_file%" (
	echo slugfont executable found: %slugfont_exe_file%
) else (
	echo Warning: the slugfont executable is not present - %slugfont_exe_file%
	echo You can locate %slugfont_exe_file% in your installation of ESO.
	echo.
	echo Some common paths are:
	echo 	C:\Program Files ^(x86^)\Zenimax Online\The Elder Scrolls Online\game\client\%slugfont_exe_file%
	echo 	C:\Program File\Zenimax Online\The Elder Scrolls Online\game\client\%slugfont_exe_file%
	echo 	C:\Steam\steamapps\common\Zenimax Online\The Elder Scrolls Online\game\client\%slugfont_exe_file%
	echo.
	echo Copy %slugfont_exe_file% into C:\Users\^%%username^%%\Documents\Elder Scrolls Online\live\AddOns\FontChanger\Fonts
	echo then re-run this script
	echo.
	:: Exit the script
	pause
	exit /b
)

for %%f in (ttfs\*) do (
	@REM echo "fullname: %%f"
	@REM echo "name: %%~nf"
	echo Generating %%~nf.slug
	slugfont.exe "%%f" -o "slugs\%%~nf.slug"
)
echo.
echo Fonts have been converted to slugs!

:: Output file
set output_file=..\CustomFontOptions.lua

:: Clear the output file in case it exists
if exist %output_file% del %output_file%

:: String builder
set list="-- DON'T EDIT THIS FILE DIRECTLY --"
set list=%list%;"-- technically you can, but you should really place your"
set list=%list%;"-- font files in the fonts/ttfs directory and re-run fonts/slug.bat (Windows)"
set list=%list%;"-- or fonts/slug.sh (Linux)"
set list=%list%;"local FC = FontChanger or {}"
set list=%list%;"FC.CUSTOM_FONT_CHOICES = {"

for %%f in (slugs\*) do (
	set list=!list!;"	"%%~nf","
)
set list=%list%;"}"
set list=%list%;"FC.CUSTOM_FONT_VALUES = {"
for %%f in (slugs\*) do (
	set list=!list!;"	"FontChanger/fonts/slugs/%%~nf.slug","
)
set list=%list%;"}"

:: Loop through the list and write each item to a new line in the output file
for %%i in (%list%) do (
	echo %%~i >> %output_file%
)

echo Updated %output_file%.
echo.

endlocal

echo Window will close in 10 seconds.
timeout /t 10 /nobreak
echo closing...
@REM pause
