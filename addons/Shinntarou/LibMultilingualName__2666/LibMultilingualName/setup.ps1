####
# ESO Master Dump
####

Write-Host "This batch is to create ESO Item Master Files each languages from your ESO Client programs."
Write-Host "The work takes much time. (about 30 min each)"
Write-Host "Press any key to continue."
$host.UI.RawUI.ReadKey()

. ".\\ps\globalVariables.ps1"
. ".\\ps\function.ps1"


####
# script scope
####

$script:libMethodDataList = @(
    #methodName, baseId
    #  !!! anyone who read this file(this one think you Vestige are an impressive and famous addon developer.):
    #      please report me if you find bugs. I'm not sure these IDs are correct.
    @("GetRawItemName", 242841733),
    @("GetRawQuestName", 52420949),
    @("GetRawQuestTaskName", 7949764),
    @("GetRawSkillName", 198758357),
    @("GetRawZoneName", 162658389), # 779cnt e.g.) 162658389	0	203	8674858	Cheesemonger's Hollow @see https://wiki.esoui.com/Zones
    @("GetRawAbilityDescription", 132143172),
    @("GetRawSetItemName", 38727365)
    #@("GetRawNpcChat",149328292)
)


####
# Main
####

# get Path
$pathInfo = getPathInfo
$esoMnfPath = $pathInfo[0]
$gameMnfPath = $pathInfo[1]

# Input: target langCode, target methods
# Input langCode
Write-Host "What is language data you want to create?"
$allLangCodeStr = $langCodes -join " , "
$targetLangCode = Read-Host "Input LangCode. (${allLangCodeStr} or 'all')"

# Input method
Write-Host "What is Lib Method you want to create?"
Write-Host "  Num |    libMethodName"
$methodNum = 0
foreach ($libMethodData in $libMethodDataList) {
    $methodNum ++

    $libMethodName = $libMethodData[0]
    Write-Host "  ${methodNum}   |    ${libMethodName}"
}
$targetLibMethodNum = Read-Host "Input Num or 'all'."

Write-Host "Target Lang Code: $targetLangCode"
Write-Host "TargetLibMethodNum: ${targetLibMethodNum}"

# Create Lib files, other commands
foreach ($langCode in $langCodes) {
    Write-Host "langCode:    ${langCode}"
    if ($langCode -ne $targetLangCode -And $targetLangCode -ne "all") {
        Write-Host "It's not target. skip."
        continue
    }

    Write-Host "Now loading lang file..."

    $esoMasterFile = $langCode + ".lang"
    $esoMasterFileCsvPath = "export\esoMnfPath\gamedata\lang\" + $esoMasterFile + ".csv"
    ./EsoExtractData/EsoExtractData.exe  $esoMnfPath  .\export\esoMnfPath\  -n $esoMasterFile   --pocsv

    $methodNum = 0
    foreach ($libMethodData in $libMethodDataList) {
        $methodNum ++

        $libMethodName = $libMethodData[0]
        $baseId = $libMethodData[1]
        
        Write-Host "Num:${methodNum}    libMethodName:    ${libMethodName}"
        if ($methodNum -ne $targetLibMethodNum -And $targetLibMethodNum -ne "all") {
            Write-Host "It's not target. skip."
            continue
        }

        createRawDataFile  $langCode  $esoMasterFileCsvPath  $libMethodName  $baseId
    }
}

Write-Host "completed."
$host.UI.RawUI.ReadKey()
