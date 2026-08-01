####
# ESO Fake lang code creator
####

Write-Host "This batch is to create ESO user-defined language code(files) from existing lang code."
Write-Host "a user-defined lang code can be used in game. e.g) /script SetCVar('language.2','tw')"
Write-Host "existing files will be overwrittten."
Write-Host "Press any key to continue."
$host.UI.RawUI.ReadKey()

. ".\\ps\globalVariables.ps1"
. ".\\ps\function.ps1"

####
# Main
####

# get Path
$pathInfo = getPathInfo
$esoMnfPath = $pathInfo[0]
$gameMnfPath = $pathInfo[1]

# filename( !!!LANGCODE!!! will be replaced.), Mnf, copt to folder
$langFileDataList = @(
    @( "!!!LANGCODE!!!.lang" , $esoMnfPath, "../gamedata/lang/" ),
    @( "!!!LANGCODE!!!.lang.csv" , $esoMnfPath, "../gamedata/lang/" ),
    @( "!!!LANGCODE!!!_client.lua" , $esoMnfPath, "../EsoUI/lang/" ), # TODO valid in game
    @( "!!!LANGCODE!!!_pregame.lua" , $esoMnfPath, "../EsoUI/lang/" ) # TODO valid in game
)

# Input: base langCode
Write-Host "What is a base language?"
$allLangCodeStr = $langCodes -join " , "
$baseLangCode = Read-Host "Input LangCode. (${allLangCodeStr})"

# Input: new langCode
Write-Host "What is a new lang code you want to create?"
$newLangCode = Read-Host "Input LangCode. (NOT in ${allLangCodeStr})"

# remove existing folder
Remove-Item  -Path .\export2\*.*  -Recurse  -Force  -Exclude ".gitkeep"

# Create Lib files
foreach ($langFileData in $langFileDataList) {
    $fileName = $langFileData[0]
    $mnf = $langFileData[1]
    $copyToPath = $langFileData[2]

    if (-not (Test-Path $copyToPath)) {
        mkdir $copyToPath
    }

    $baseFileName = $fileName -replace "!!!LANGCODE!!!", $baseLangCode
    $newFileName = $fileName -replace "!!!LANGCODE!!!", $newLangCode

    $newFilePath = $copyToPath + $newFileName
    Write-Host "Execute command: ./EsoExtractData/EsoExtractData.exe  ${mnf}  .\export2\  -n ${baseFileName}"
    ./EsoExtractData/EsoExtractData.exe  $mnf  .\export2\  -n $baseFileName
    $baseFilePath = Get-ChildItem -r .\export2\ | Where-Object { $_.Name -eq $baseFileName } | Resolve-Path
    Write-Host "baseFilePath: ${baseFilePath}"
    Write-Host "newFilePath: ${newFilePath}"
    if ($baseFilePath) {
        Copy-Item  $baseFilePath  $newFilePath  -force
        Write-Host "to copy $fileName is finished."
    }
    else {
        Write-Host "not found. file: ${fileName} in mnf:${mnf}"
        die
    }
}

Write-Host "completed."
$host.UI.RawUI.ReadKey()
