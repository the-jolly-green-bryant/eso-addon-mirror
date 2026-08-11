ShowCP = ShowCP or {}
local SC = ShowCP

SC.name = "ShowCP"
SC.displayName = "Show CP"
SC.version = "0.0.04"
SC.savedVersion = 1
SC.refreshToken = 0
SC.initialized = false

SC.defaults = {
    enabled = true,
    blue = {
        enabled = true,
        x = -500,
        y = -140,
        scale = 1.0,
    },
    red = {
        enabled = true,
        x = -500,
        y = 20,
        scale = 1.0,
    },
    green = {
        enabled = true,
        x = -500,
        y = 180,
        scale = 1.0,
    },
}

local function OnAddOnLoaded(_, addonName)
    if addonName ~= SC.name then return end
    EVENT_MANAGER:UnregisterForEvent(SC.name, EVENT_ADD_ON_LOADED)

    SC.saved = ZO_SavedVars:NewAccountWide("ShowCPSavedVariables", SC.savedVersion, nil, SC.defaults)

    if SC.Display then
        SC.Display:Initialize()
    end

    if SC.Scanner then
        SC.Scanner:Initialize()
    end

    if SC.Settings then
        SC.Settings:Initialize()
    end

    SC.initialized = true
    SC:RefreshNow()
end

function SC:RefreshNow()
    if not self.initialized or not self.Scanner then return end
    self.Scanner:Refresh()
end

function SC:QueueRefresh(delayMs)
    self.refreshToken = self.refreshToken + 1
    local token = self.refreshToken
    zo_callLater(function()
        if token ~= SC.refreshToken then return end
        SC:RefreshNow()
    end, delayMs or 100)
end

function SC:SetEnabled(enabled)
    self.saved.enabled = enabled and true or false
    if self.Display then
        self.Display:RefreshVisibility()
    end
end

function SC:SetModuleEnabled(moduleKey, enabled)
    local moduleSaved = self.saved[moduleKey]
    if not moduleSaved then return end
    moduleSaved.enabled = enabled and true or false
    if self.Display then
        self.Display:RefreshVisibility(moduleKey)
    end
end

function SC:SetModuleScale(moduleKey, scale)
    local moduleSaved = self.saved[moduleKey]
    if not moduleSaved then return end
    moduleSaved.scale = zo_clamp(scale or 1, 0.6, 1.6)
    if self.Display then
        self.Display:ApplyPlacement(moduleKey)
    end
end

function SC:MoveModule(moduleKey, dx, dy)
    local moduleSaved = self.saved[moduleKey]
    if not moduleSaved then return end
    moduleSaved.x = (moduleSaved.x or 0) + (dx or 0)
    moduleSaved.y = (moduleSaved.y or 0) + (dy or 0)
    if self.Display then
        self.Display:ApplyPlacement(moduleKey)
    end
end

function SC:ResetModulePosition(moduleKey)
    local moduleSaved = self.saved[moduleKey]
    local defaults = self.defaults[moduleKey]
    if not moduleSaved or not defaults then return end
    moduleSaved.x = defaults.x
    moduleSaved.y = defaults.y
    moduleSaved.scale = defaults.scale
    if self.Display then
        self.Display:ApplyPlacement(moduleKey)
    end
end

local function OnPlayerActivated()
    if SC.initialized and SC.Display then
        SC.Display:RefreshVisibility()
    end
end

EVENT_MANAGER:RegisterForEvent(SC.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(SC.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
