function die {
    Write-Host "failure."
    $host.UI.RawUI.ReadKey()
    exit 1
}

function echoToFile($str, $toFile, $clear = "APPEND") {
    if ($clear -eq "NEW") {
        "" | Out-File  -FilePath $toFile  -Force  -NoNewline  -Encoding UTF8
    }
    $str | Out-File  -FilePath $toFile  -Append  -Encoding UTF8
    Out-Host
}

function createRawDataFile($langCode, $esoMasterFileCsvPath, $methodNameBase, $baseId) {

    $toFile = "LibMultilingualName_${langCode}\${methodNameBase}_${langCode}.lua"
    $tempFile = $toFile + ".temp"

    Write-Host "Now loading Csv file..."

    $lines = Import-Csv $esoMasterFileCsvPath  -Delimiter ","   -Header "ID", "Unknown", "Index", "Offset", "Text"  -Encoding UTF8  |  Where-Object { $_.ID -eq $baseId }

    echoToFile ("${libName}_${methodNameBase}_Data = ${libName}_${methodNameBase}_Data or {}") $tempFile "NEW"
    echoToFile ("${libName}_${methodNameBase}_Data[`"${langCode}`"] = {") $tempFile

    $cnt = 0
    foreach ($lineData in $lines) {

        $cnt2 = $cnt % 1000
        if ($cnt2 -eq 0) {
            $currentPercent = 100 * ($cnt / $lines.Length)
            Write-Progress  ("file:${tempFile}  Total lines:" + $lines.Length)   -PercentComplete $currentPercent  -CurrentOperation $cnt
        }

        echoToFile ("[" + $lineData.Index + "]=`"" + $lineData.Text.Replace('"', '\"') + "`",") $tempFile
        $cnt++
    }
    
    echoToFile ("}") $tempFile

    Move-Item  $tempFile  $toFile  -force
    
    Write-Progress  ("file:${tempFile}  Total lines:" + $lines.Length)   -PercentComplete 100
}

function createCsvFile($langCode, $esoMasterFileCsvPath, $methodNameBase, $baseId) {

    $toFile = "Raw\${methodNameBase}_${langCode}.csv"
    $tempFile = $toFile + ".temp"

    Write-Host "Now loading Csv file..."

    $lines = Import-Csv $esoMasterFileCsvPath  -Delimiter ","   -Header "ID", "Unknown", "Index", "Offset", "Text"  -Encoding UTF8  |  Where-Object { $_.ID -eq $baseId }

    echoToFile ("key,value") $tempFile "NEW"

    $cnt = 0
    foreach ($lineData in $lines) {

        $cnt2 = $cnt % 1000
        if ($cnt2 -eq 0) {
            $currentPercent = 100 * ($cnt / $lines.Length)
            Write-Progress  ("file:${tempFile}  Total lines:" + $lines.Length)   -PercentComplete $currentPercent  -CurrentOperation $cnt
        }

        echoToFile ($lineData.Index + ",`"" + $lineData.Text.Replace('"', '\"') + "`"") $tempFile
        $cnt++
    }

    Move-Item  $tempFile  $toFile  -force
    
    Write-Progress  ("file:${tempFile}  Total lines:" + $lines.Length)   -PercentComplete 100
}

function getPathInfo() {
    # Zenimax_Online Launcher's full path. write constant path if you need.
    $zoPath = ""

    if (!$zoPath) {
        $pathChecks = @()
        
        # registry
        $esoPathReg = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Zenimax_Online\Launcher"
        if (Get-Item -Path "Registry::${esoPathReg}") {
            $pathChecks += (Get-ItemProperty -Path "Registry::${esoPathReg}")."InstallPath"
        }
        # Steam Default
        $pathChecks += "C:\Program Files (x86)\Steam\steamapps\common\Zenimax Online"
        # DMM Default
        # C:\Users\(UserName)\eso\The Elder Scrolls Online
        # Official downloaded
        # C:\Program Files (x86)\Zenimax Online\The Elder Scrolls Online\game\client
        $pathChecks += "C:\Program Files (x86)\Zenimax Online"
        
        
        foreach ($zoPath in $pathChecks) {
            if (Test-Path $zoPath -PathType Container) {
                break
            }
        }
    }
    if (Test-Path $zoPath -PathType Container) {
        Write-Host "zoPath:         ${zoPath}"
    }
    else {
        Write-Host "zoPath:         ${zoPath}  (Not Found)"
        $zoPath = Read-Host "Input Path manually (e.g. C:\Program Files (x86)\Zenimax Online , C:\Users\(UserName)\eso\The Elder Scrolls Online "
        if (Test-Path $zoPath -PathType Container) {
            Write-Host "zoPath:         ${zoPath}"
        }
        else {
            die
        }
    }

    $esoPath = "${zoPath}\The Elder Scrolls Online"
    if (Test-Path $esoPath -PathType Container) {
        Write-Host "esoPath:        ${esoPath}"
    }
    else {
        Write-Host "esoPath:        ${esoPath}  (Not Found)"
        die
    }

    $esoMnfPath = "${esoPath}\depot\eso.mnf"
    if (Test-Path $esoMnfPath -PathType Leaf) {
        Write-Host "esoMnfPath:     ${esoMnfPath}"
    }
    else {
        Write-Host "esoMnfPath:     ${esoMnfPath}  (Not Found)"
        die
    }

    $gameMnfPath = "${esoPath}\game\client\game.mnf";
    if (Test-Path $gameMnfPath -PathType Leaf) {
        Write-Host "gameMnfPath:    ${gameMnfPath}"
    }
    else {
        Write-Host "gameMnfPath:    ${gameMnfPath}  (Not Found)"
        die
    }

    return $esoMnfPath, $gameMnfPath
}
