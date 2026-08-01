ClearSight = ClearSight or {}
local CS = ClearSight

CS.name = "ClearSight"
CS.version = "1.0.3"
CS.updateIntervalMs = 100

CS.defaults = {
    reticle = {
        enabled = true,
        size = 64,
        thickness = 5,
        gap = 7,
        outline = 2,
        normalColor = { 1.00, 1.00, 1.00, 1.00 },
        friendlyColor = { 0.10, 1.00, 0.20, 1.00 },
        deadColor = { 1.00, 0.82, 0.10, 1.00 },
        hostileColor = { 1.00, 0.15, 0.10, 1.00 },
        showAcquiredBrackets = true,
    },
    waypoint = {
        enabled = true,
        baseSize = 20,
        amberSize = 28,
        redSize = 38,
        greenThresholdDegrees = 8,
        amberThresholdDegrees = 35,
        greenColor = { 0.10, 1.00, 0.20, 1.00 },
        amberColor = { 1.00, 0.65, 0.05, 1.00 },
        redColor = { 1.00, 0.10, 0.10, 1.00 },
        arrivalColor = { 1.00, 1.00, 1.00, 1.00 },
        arrivalSize = 16,
        -- Approximate normalized map-distance handoff thresholds, calibrated from
        -- console testing: match the player's waypoint colour near ~300m, then
        -- hide ClearSight near ~150m so only ESO's stock waypoint remains.
        waypointColorDistance = 0.0180,
        hideOverlayDistance = 0.0090,
        opacity = 1.0,
    },
}

local function DeepCopy(source)
    local result = {}
    for key, value in pairs(source) do
        result[key] = type(value) == "table" and DeepCopy(value) or value
    end
    return result
end

function CS:Initialize()
    self.saved = ZO_SavedVars:NewAccountWide("ClearSight_SavedVariables", 1, nil, DeepCopy(self.defaults))

    -- 1.0.2 tightens the original green guidance cone. There is no user-facing
    -- setting for this value, so safely migrate existing 1.0.1 SavedVariables.
    if self.saved.waypoint and self.saved.waypoint.greenThresholdDegrees == 10 then
        self.saved.waypoint.greenThresholdDegrees = 8
    end

    -- 1.0.3 gives the reticle a simple accessibility colour language:
    -- white = neutral/no target, green = friendly, red = live hostile, yellow = dead.
    -- These colours were not user-configurable in earlier builds, so migrate the
    -- previous cyan normal colour and add the two new state colours safely.
    if self.saved.reticle then
        local normal = self.saved.reticle.normalColor
        if normal and normal[1] == 0.10 and normal[2] == 0.90 and normal[3] == 1.00 then
            self.saved.reticle.normalColor = { 1.00, 1.00, 1.00, 1.00 }
        end
        self.saved.reticle.friendlyColor = self.saved.reticle.friendlyColor or { 0.10, 1.00, 0.20, 1.00 }
        self.saved.reticle.deadColor = self.saved.reticle.deadColor or { 1.00, 0.82, 0.10, 1.00 }
    end

    if self.InitializeReticle then
        self:InitializeReticle()
    end

    if self.InitializeWaypoint then
        self:InitializeWaypoint()
    end

    if self.InitializeSettings then
        self:InitializeSettings()
    end

    EVENT_MANAGER:RegisterForUpdate(self.name .. "_Update", self.updateIntervalMs, function()
        if self.UpdateReticle then self:UpdateReticle() end
        if self.UpdateWaypoint then self:UpdateWaypoint() end
    end)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= CS.name then return end
    EVENT_MANAGER:UnregisterForEvent(CS.name, EVENT_ADD_ON_LOADED)
    CS:Initialize()
end

EVENT_MANAGER:RegisterForEvent(CS.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
