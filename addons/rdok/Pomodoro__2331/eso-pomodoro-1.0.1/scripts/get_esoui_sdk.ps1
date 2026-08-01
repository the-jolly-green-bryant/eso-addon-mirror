$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Write-Output "Installing esoui/esoui."
$installEsoui = "docker  run --rm " `
         + " --volume ${ScriptDir}:/app "`
         + " --volume ${ScriptDir}\..\modules:/sdk "`
         + " --workdir /app " `
         + " alpine:3.9 " `
         + " wget -O /sdk/esoui.zip https://codeload.github.com/esoui/esoui/zip/master "
Invoke-Expression $installEsoui

Write-Output "Converting esoui/esoui to modules."
$convertEsouiToSdk = "docker run --rm " `
         + " --volume ${ScriptDir}:/app "`
         + " --volume ${ScriptDir}\..\modules\esoui:/sdk "`
         + " --workdir /app " `
         + " kubeless/unzip " `
         + " /bin/sh -c '" `
         + " unzip -o -q esoui.zip;" `
         + " find esoui-master -name *.lua -exec mv -f {} /sdk \; ;" `
         + " rm -rf esoui-master '"
Invoke-Expression $convertEsouiToSdk
