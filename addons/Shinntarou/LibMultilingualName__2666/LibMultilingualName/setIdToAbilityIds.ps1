####
# SearchSetItemBonus
####

Write-Host "build files for SearchSetItemBonus method."
Write-Host "Press any key to continue."
$host.UI.RawUI.ReadKey()

. ".\\ps\globalVariables.ps1"
. ".\\ps\function.ps1"


####
# Vals
####

$libMethodDataList = @(
    #methodName, baseId
    @("GetRawSkillName", 198758357),
    @("GetRawAbilityDescription", 132143172),
    @("GetRawSetItemName", 38727365)
)

#force.  write set id and its reasons.
$forceReplaseDataList = @{}
$lines = Import-Csv "setIdToAbilityIds_force.csv" `
    -Delimiter "," -Encoding UTF8 `
    -Header "deleted", "setId", "abilityIds", "setName", "dumpedAbilityIds", "devTag", "comment" `
| Select-Object -Skip 1 `
| Where-Object { $_.deleted -ne 1 }
foreach ($lineData in $lines) {
    $tmpData = @{
        "abilityIds"       = $lineData.abilityIds
        "dumpedAbilityIds" = $lineData.dumpedAbilityIds
    }
    $forceReplaseDataList.Add($lineData.setId.PadLeft(4, "0"), $tmpData)
}

$luaFileVariableName = "SetItemIdToAbilityIds"
$langCode = "en"

####
# Main
####

# get Path
$pathInfo = getPathInfo
$esoMnfPath = $pathInfo[0]
#$gameMnfPath = $pathInfo[1]

# create CSVs if not exists

# Input: ops
Write-Host "options."
$force = Read-Host "force to craete csv? (y:force. else: use existing csv)"

$csvFilePaths = @()
$csvNotExists = 0
foreach ($libMethodData in $libMethodDataList) {
    $libMethodName = $libMethodData[0]
    $toFile = "Raw\${libMethodName}_${langCode}.csv"

    $csvFilePaths += $toFile
    
    if (Test-Path $toFile) {
        Write-Host "${toFile} exists."
    }
    else {
        Write-Host "${toFile} NOT exists."
        $csvNotExists = 1
    }
}

if (($csvNotExists -eq 1) -Or ($force -eq "y")) {

    $esoMasterFile = $langCode + ".lang"
    $esoMasterFileCsvPath = "export3\esoMnfPath\gamedata\lang\" + $esoMasterFile + ".csv"
    ./EsoExtractData/EsoExtractData.exe  $esoMnfPath  .\export3\esoMnfPath\  -n $esoMasterFile   --pocsv
    
    $methodNum = 0
    foreach ($libMethodData in $libMethodDataList) {
        $methodNum ++
    
        $libMethodName = $libMethodData[0]
        $baseId = $libMethodData[1]
        
        Write-Host "Num:${methodNum}    libMethodName:    ${libMethodName}"
    
        createCsvFile  $langCode  $esoMasterFileCsvPath  $libMethodName  $baseId
    }
}

# create SetItemIdToAbilityIdList from CSV

# prepare array
$skillNames = @{}
$lines = Import-Csv $csvFilePaths[0]  -Delimiter ","   -Header "key", "value"  -Encoding UTF8 | Select-Object -Skip 1
foreach ($lineData in $lines) {
    $skillNames.Add($lineData.key, $lineData.value)
}

$abilityDescriptions = @{}
$lines = Import-Csv $csvFilePaths[1]  -Delimiter ","   -Header "key", "value"  -Encoding UTF8 | Select-Object -Skip 1
foreach ($lineData in $lines) {
    $abilityDescriptions.Add($lineData.key, $lineData.value)
}

$setItemNames = @{}
$lines = Import-Csv $csvFilePaths[2]  -Delimiter ","   -Header "key", "value"  -Encoding UTF8 | Select-Object -Skip 1 
foreach ($lineData in $lines) {
    $setItemNames.Add($lineData.key.PadLeft(4, "0"), $lineData.value)
}

$toFile = "Raw\${luaFileVariableName}.lua"
$tempFile = $toFile + ".temp"

Write-Host "Now creating lua file."

echoToFile ("${libName} = ${libName} or {}") $tempFile "NEW"
echoToFile ("${libName}.${luaFileVariableName} = ${libName}.${luaFileVariableName} or {}") $tempFile
echoToFile ("${libName}.${luaFileVariableName} = {") $tempFile

$cnt = 0
$setItemIds = $setItemNames.Keys | Sort-Object
foreach ($setItemId in $setItemIds) {
    $originalSetItemName = $setItemNames[$setItemId]
    $setItemName = $originalSetItemName.Replace('Perfected ', '')

    $cnt2 = $cnt % 10
    if ($cnt2 -eq 0) {
        $currentPercent = 100 * ($cnt / $setItemNames.Count)
        Write-Progress  ("file:${tempFile}  Total set items:" + $setItemNames.Count)   -PercentComplete $currentPercent  -CurrentOperation $cnt
    }

    $abilityIds = @()
    foreach ($abilityId in $skillNames.Keys) {
        $abilityName = $skillNames[$abilityId]

        if (($abilityName -eq $setItemName) -And ($abilityDescriptions.ContainsKey($abilityId) -eq $true)) {
            
            $alreadyAdded = 0
            foreach ($addedAbilityId in $abilityIds) {
                if ($abilityDescriptions[$addedAbilityId] -eq $abilityDescriptions[$abilityId]) {
                    $alreadyAdded = 1
                }
            }
            if ($alreadyAdded -eq 0) {
                $abilityIds += $abilityId 
            }
        }
    }
    $abilityIdsStr = ""
    foreach ($abilityId in $abilityIds) {
        if ($abilityIdsStr.Length -gt 0) {
            $abilityIdsStr = $abilityIdsStr + ","
        }
        $abilityIdsStr = $abilityIdsStr + $abilityId
    }

    if ($forceReplaseDataList.ContainsKey($setItemId)) {
        $forcedAbilityIdsStr = $forceReplaseDataList[$setItemId]["abilityIds"]
        $dumpedAbilityIdsStr = $forceReplaseDataList[$setItemId]["dumpedAbilityIds"]
        
        echoToFile ("--[" + [int]::Parse($setItemId) + "]={ " + $abilityIdsStr + " },--  " + $originalSetItemName) $tempFile
        echoToFile ("[" + [int]::Parse($setItemId) + "]={" + $forcedAbilityIdsStr + "},--  previousDumpedIds: " + $dumpedAbilityIdsStr) $tempFile
    }
    else {
        echoToFile ("[" + [int]::Parse($setItemId) + "]={" + $abilityIdsStr + "},--" + $originalSetItemName) $tempFile

    }

    $cnt++
}

echoToFile ("}") $tempFile

Move-Item  $tempFile  $toFile  -force

Write-Progress  ("file:${tempFile}  Total lines:" + $lines.Length)   -PercentComplete 100

Write-Host "completed."
$host.UI.RawUI.ReadKey()
