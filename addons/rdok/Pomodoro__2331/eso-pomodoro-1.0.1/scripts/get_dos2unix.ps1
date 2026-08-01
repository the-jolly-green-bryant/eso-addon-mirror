$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Write-Output "Fetching dos2unix.zip."
$fetchDos2Unix = "docker  run --rm " `
      + "--volume ${ScriptDir}:/app "`
      + "--workdir /app " `
      + "alpine:3.9 " `
      + " wget -O dos2unix.zip https://sourceforge.net/projects/dos2unix/files/dos2unix/7.4.0/dos2unix-7.4.0-win64.zip/download "
Invoke-Expression $fetchDos2Unix

Write-Output "Unzipping dos2unix.zip."
$unzipDos2Unix = "docker  run --rm " `
      + "--volume ${ScriptDir}:/app "`
      + "--workdir /app " `
      + "kubeless/unzip  unzip -o -q dos2unix.zip -d dos2unix  "
Invoke-Expression $unzipDos2Unix

Write-Output "Cleaning Up"
$unzipDos2Unix = "docker  run --rm " `
      + "--volume ${ScriptDir}:/app "`
      + "--workdir /app " `
      + "alpine:3.9 rm dos2unix.zip"
Invoke-Expression $unzipDos2Unix
