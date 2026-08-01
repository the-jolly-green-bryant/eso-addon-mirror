$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
#
#Write-Output "Installing busted sdk."
#$installGlobals = "docker  run --rm " `
#        + "--volume ${ScriptDir}:/app "`
#         + " --volume ${ScriptDir}\..\modules:/busted "`
#        + "--workdir /app " `
#        + "alpine:3.9 " `
#        + " wget -O /busted/busted_sdk.zip https://github.com/Olivine-Labs/busted/archive/master.zip "
#Invoke-Expression $installGlobals

Write-Output "Converting busted sdk zip to modules."
$convertEsouiToSdk = "docker run --rm " `
         + " --volume ${ScriptDir}\..\modules:/modules "`
         + " --workdir /modules " `
         + " kubeless/unzip " `
         + " /bin/sh -c '" `
         + " unzip -o -q busted_sdk.zip;" `
         + " find busted-master -name *.lua -exec mv -f {} /modules/busted \; ;" `
         + " rm -rf busted-master '"
Invoke-Expression $convertEsouiToSdk
