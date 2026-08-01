####
# ESO Addon Lang Files Reproducer
####

Write-Host "This batch is to create new addon's lang-code(locale) files from addon's original lang-code files."
Write-Host "In other words, the batch is 'cp AddOns/*/(FROM).* AddOns/*/(TO).*' recursively."
Write-Host "existing files will be overwrittten."
Write-Host "the batch can handle files. not directories."
Write-Host "'FROM' and 'TO' phrases are case-sensitive. if 'FROM' is 'TW', you can't catch files starting with 'tw'."
Write-Host "Press any key to continue."
$host.UI.RawUI.ReadKey()

####
# Main
####

$currentPath = Get-Location
$addOnRootPath = Resolve-Path "${currentPath}\..\..\AddOns"

Write-Host "currentPath:${currentPath}"
Write-Host "addOnRootPath:${addOnRootPath}"

$skipPaths = @(
    "LibMultilingualName",
    " - "
)

# Input: FROM
Write-Host "What is 'FROM'?"
$from = Read-Host "Input 'FROM'"

# Input: TO
Write-Host "What is 'TO'?"
$to = Read-Host "Input 'TO'"

# Input: ops
Write-Host "options."
$force = Read-Host "force? (y:force. never prompt.  else:prompt before every AddOn)"

$addOnPaths = Get-ChildItem -Path $addOnRootPath  -Directory -Force
#$allAddOnPaths = $addOnPaths -join "  ,  "
#Write-Host $allAddOnPaths

Write-Host " ---- "
Write-Host " AddonRootPath: ${addOnRootPath} "
Write-Host " From  : ${from} "
Write-Host " To    : ${to} "
Write-Host " force : ${force} "
Write-Host "Are you sure to create 'TO' files from 'FROM' files?"
$go = Read-Host "y/else"
if ( 'y' -ne $go ) {
    Write-Host "terminated by user."
    $host.UI.RawUI.ReadKey()
    exit;
}

foreach ($addOnPath in $addOnPaths) {

    $skip = 0
    foreach ($skipPath in $skipPaths) {
        if ($addOnPath.Name.Contains($skipPath)) {
            #Write-Host "matched: ${skipPath}"
            $skip = 1
        }
    }
    if ($skip -eq 1) {
        Write-Host "${addOnPath} is skipped. (reason: skipPath)"
        continue
    }

    $path = [string]::Concat($addOnRootPath, "\", $addOnPath.Name)
    $fromFiles = Get-ChildItem -Path $path -Force -Recurse -File | Where-Object { $_.Name.StartsWith("${from}.") }

    if ($fromFiles.Length -eq 0) {
        Write-Host "${addOnPath} has none."
        continue
    }

    $allFromFilesStr = $fromFiles -join "  ,  "
    Write-Host "${addOnPath} has : ${allFromFilesStr}"

    if ($force -ne 'y') {
        $confirm = Read-Host "go, or no-go? (y:go else:no-go)"
        
        if ($confirm -ne 'y') {
            Write-Host "${addOnPath} is skipped. (reason: no-go)"
            continue
        }
    }

    foreach ($fromFile in $fromFiles) {
        $fromPath = ([string]$fromFile.FullName)
        $toPath = $fromPath.Replace("${from}.", "${to}.")
        if ($fromPath.ToLower() -eq $toPath.ToLower()) {
            Write-Host "can't cp ${fromPath} ${toPath} (reason: these paths are same.)"
            continue
        }

        Copy-Item $fromPath -Destination $toPath -Force
    }
}

Write-Host "completed."
$host.UI.RawUI.ReadKey()
