local Bootstrap = STARSModuleBootstrap
local Project = Bootstrap and Bootstrap.current
if not Project then error("STARS module: config.lua must load before Main.lua") end

local function OnAddonLoaded(_, addonName)
    if addonName ~= Project.Config.addonName then return end

    EVENT_MANAGER:UnregisterForEvent(Project.Config.addonName, EVENT_ADD_ON_LOADED)
    Project.Controller:Initialize()
end

EVENT_MANAGER:RegisterForEvent(Project.Config.addonName, EVENT_ADD_ON_LOADED, OnAddonLoaded)

-- All files have now captured their own local Project reference. Clearing this
-- transient alias prevents a later addon from accidentally reusing it.
Bootstrap.current = nil
