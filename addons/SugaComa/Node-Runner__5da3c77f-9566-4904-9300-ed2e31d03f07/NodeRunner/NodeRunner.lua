NODE_RUNNER = NODE_RUNNER or {}
local Project = NODE_RUNNER

function Project:Initialize()
    if self.initialized then return true end
    if not self.Controller then return false end

    self.Controller:Initialize()
    self.initialized = true
    return true
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= Project.Config.addonName then return end

    EVENT_MANAGER:UnregisterForEvent(Project.Config.addonName, EVENT_ADD_ON_LOADED)
    Project:Initialize()
end

EVENT_MANAGER:RegisterForEvent(Project.Config.addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
