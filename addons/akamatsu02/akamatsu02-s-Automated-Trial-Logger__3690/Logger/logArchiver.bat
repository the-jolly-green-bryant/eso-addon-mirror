@echo off

:: Find Documents folder
FOR /F "tokens=3 " %%G IN ('REG QUERY "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal"') DO (SET docsdir=%%G)

:: Navigate to the Logs directory
cd "%docsdir%\Elder Scrolls Online\live\Logs"

echo Running in %docsdir%\Elder Scrolls Online\live\Logs
timeout /t 10 /nobreak

:: Create esologsarchive folder inside Logs folder
if not exist "esologsarchive" (
    mkdir esologsarchive
)
goto WAITFILE

:WAITFILE
:: Loop until Encounter.log file exists
CLS
echo Wait for Encounter.log
if exist "Encounter.log" (
    goto FINDRAID
) else (
	timeout /t 5 /nobreak>nul
    goto WAITFILE
)

:FINDRAID
:: Find Raid name by zoneId
CLS
echo Searching Raid
>nul findstr /c:"ZONE_CHANGED,975" "Encounter.log" && (
    set Raid=HoF
	goto FINDDIFFICULTY
) || (
>nul findstr /c:"ZONE_CHANGED,1196" "Encounter.log" && (
    set Raid=KA
	goto FINDDIFFICULTY
) || (
>nul findstr /c:"ZONE_CHANGED,639" "Encounter.log" && (
    set Raid=SO
	goto FINDDIFFICULTY
) || (
>nul findstr /c:"ZONE_CHANGED,638" "Encounter.log" && (
    set Raid=AA
	goto FINDDIFFICULTY
) || (
>nul findstr /c:"ZONE_CHANGED,636" "Encounter.log" && (
    set Raid=HRC
	goto FINDDIFFICULTY
) || (
>nul findstr /c:"ZONE_CHANGED,725" "Encounter.log" && (
    set Raid=MoL
	goto FINDDIFFICULTY
) || (
>nul findstr /c:"ZONE_CHANGED,1121" "Encounter.log" && (
    set Raid=SS
	goto FINDDIFFICULTY
) || (
>nul findstr /c:"ZONE_CHANGED,1344" "Encounter.log" && (
    set Raid=DSR
	goto FINDDIFFICULTY
) || (
>nul findstr /c:"ZONE_CHANGED,1051" "Encounter.log" && (
    set Raid=CR
	goto FINDDIFFICULTY
) || (
>nul findstr /c:"ZONE_CHANGED,1263" "Encounter.log" && (
    set Raid=RG
	goto FINDDIFFICULTY
) || (
>nul findstr /c:"ZONE_CHANGED,1427" "Encounter.log" && (
    set Raid=SE
	goto FINDDIFFICULTY
) || (
>nul findstr /c:"ZONE_CHANGED,1000" "Encounter.log" && (
    set Raid=AS
	goto FINDDIFFICULTY
) || (
>nul findstr /c:"ZONE_CHANGED,1478" "Encounter.log" && (
    set Raid=LC
	goto FINDDIFFICULTY
) || (
	:: Retry if no Raid was found
	echo No Raid found
	timeout /t 10 /nobreak>nul
	goto FINDRAID
))))))))))))
goto FINDRAID

:FINDDIFFICULTY
:: Get the difficulty of the Raid
>nul findstr /c:"VETERAN" "Encounter.log" && (
    set Difficulty=v
	goto DATETIME
) || (
	set Difficulty=n
	goto DATETIME
)

:MOVEFILE
:: Loop until log is finished (if file still exists after move, then it is still used by another process -> aka ESO still writes something in the log -> log not finished yet)
move /Y "Encounter.log" "esologsarchive\Encounter_%dateFormatted%_%Difficulty%%Raid%.log"
CLS
echo %Difficulty%%Raid% found
if exist "Encounter.log" (
	echo Waiting until the log is finished
    timeout /t 5 /nobreak>nul
    goto MOVEFILE
) else (
    goto WAITFILE
)

:DATETIME
set dateFormatted=%date:~0,2%.%date:~3,2%.%date:~8,2%_%time:~0,2%;%time:~3,2%
goto MOVEFILE