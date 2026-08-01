#$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

$installLuarocksPackages = "docker-compose  run --rm " `
        + " luarocks " `
        + " install busted"
Invoke-Expression $installLuarocksPackages

#Write-Output "Installing luarocks packages"
#$installLuarocksPackages = "docker  run --rm " `
#        + "--volume ${ScriptDir}:/app "`
#        + " --volume ${ScriptDir}\..\modules:/modules "`
#        + "--workdir /app " `
#        + "luarocks:5.1 " `
#        + " install --tree /modules inspect"
#Invoke-Expression $installLuarocksPackages

#$installLuaFileSystem = "docker  run --rm " `
#        + "--volume ${ScriptDir}:/app "`
#        + " --volume ${ScriptDir}\..\modules:/modules "`
#        + "--workdir /app " `
#        + "luarocks:5.1 " `
#        + " install --tree /modules luafilesystem"
#Invoke-Expression $installLuaFileSystem
#
#$installLuarocksPackages = "docker  run --rm " `
#        + "--volume ${ScriptDir}:/app "`
#        + " --volume ${ScriptDir}\..\modules:/modules "`
#        + "--workdir /app " `
#        + "luarocks:5.1 " `
#        + " install --tree /modules luassert"
#Invoke-Expression $installLuarocksPackages
