# Source https://esodata.uesp.net/current/index.html

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Write-Output "Installing esoui globals."
$installGlobals = "docker  run --rm " `
        + "--volume ${ScriptDir}:/app "`
        + " --volume ${ScriptDir}\..\modules:/globals "`
        + "--workdir /app " `
        + "alpine:3.9 " `
        + " wget -O /globals/globals.txt https://esodata.uesp.net/current/globals.txt"
Invoke-Expression $installGlobals

Write-Output "Installing esoui global functions."
$installGlobals = "docker  run --rm " `
        + "--volume ${ScriptDir}:/app "`
        + " --volume ${ScriptDir}\..\modules:/globals "`
        + "--workdir /app " `
        + "alpine:3.9 " `
        + " wget -O /globals/globalfuncs.txt https://esodata.uesp.net/current/globalfuncs.txt"
Invoke-Expression $installGlobals

Write-Output "Installing esoui local functions."
$installGlobals = "docker  run --rm " `
        + "--volume ${ScriptDir}:/app "`
        + " --volume ${ScriptDir}\..\modules:/globals "`
        + "--workdir /app " `
        + "alpine:3.9 " `
        + " wget -O /globals/localfuncs.txt https://esodata.uesp.net/current/localfuncs.txt"
Invoke-Expression $installGlobals

Write-Output "Installing esoui functioncalls."
$installGlobals = "docker  run --rm " `
        + "--volume ${ScriptDir}:/app "`
        + " --volume ${ScriptDir}\..\modules:/globals "`
        + "--workdir /app " `
        + "alpine:3.9 " `
        + " wget -O /globals/functioncalls.txt https://esodata.uesp.net/current/functioncalls.txt"
Invoke-Expression $installGlobals
