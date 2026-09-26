-- Main file for the active STZ project.
-- When the experiment becomes standalone, this is the file that is renamed
-- and becomes the project's normal addon-loaded bootstrap.

SugasTestZoneBBTCadence = SugasTestZoneBBTCadence or {}
local Project = SugasTestZoneBBTCadence

local function EnsureSlotSettings(name)
    Project.sv[name] = Project.sv[name] or {}
    for slot = Project.Config.firstSlot, Project.Config.lastSlot do
        if Project.sv[name][slot] == nil then Project.sv[name][slot] = true end
    end
end

function Project:Initialize()
    if self.initialized then return true end
    local host = SUGAS_TEST_ZONE
    if not host or type(host.CanLoadProject) ~= "function" then return false end

    local allowed = host:CanLoadProject(self.Config.displayName)
    if allowed ~= true then return false end

    self.sv = ZO_SavedVars:NewAccountWide(
        self.Config.savedVariablesName,
        self.Config.savedVariablesVersion,
        nil,
        self.Defaults
    )
    EnsureSlotSettings("frontSlots")
    EnsureSlotSettings("backSlots")
    if (tonumber(self.sv.layoutVersion) or 0) < 3 then
        self.sv.hudScale = 1.0
        self.sv.layoutVersion = 3
    end

    self.State:Reset()
    self.HUD:Initialize()
    self.Menu:Initialize()
    self.Tracker:Initialize()
    self.initialized = true
    self:Log("Authorized STZ experiment loaded", true)
    return true
end

local EVENT_NAME = "Sugas-Test-Zone_ActiveProjectLoaded"
local function OnHostLoaded(_, addonName)
    if addonName ~= Project.Config.addonName then return end
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAME, EVENT_ADD_ON_LOADED)

    -- Defer until the current addon-loaded dispatch has finished so STZ_Main
    -- has restored its saved access configuration before the project asks for
    -- authorization.
    if type(zo_callLater) == "function" then
        zo_callLater(function() Project:Initialize() end, 0)
    else
        Project:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_ADD_ON_LOADED, OnHostLoaded)
