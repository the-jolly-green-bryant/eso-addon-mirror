local themeName = "LibMapThemer_Core"

_G[themeName] = {
   dependencies = { LibMapThemer_Overrides, LibMapThemer_Pois, LibMapThemer_Renames },
}

--[[
local defaultName = "LibMapThemer_Default"

_G[defaultName] = {
   name = defaultName,
   version = 1.0,
   dependencies = { LibMapThemer_Core, LibMapThemer_Zones },
}
local defaultTheme = LibMapThemer:CreateTheme( _G[defaultName] )
--]]
