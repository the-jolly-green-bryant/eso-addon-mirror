SmartCombatAlertsPS5 = SmartCombatAlertsPS5 or {}
local SCA = SmartCombatAlertsPS5

SCA.name = "SmartCombatAlertsPS5"
SCA.version = "3.0.0"

SCA.defaults = {
    enabled = true,
    durationMs = 1500,
    throttleMs = 1200,
    damageThreshold = 12000,
    startupMessage = true,
}

SCA.saved = nil
SCA.lastAlertAt = 0
SCA.inCombat = false

-- Use built-in ESO string helpers for better performance on console
local function SafeLower(text)
    return text and zo_strlower(text) or ""
end

function SCA:GetNow()
    return GetGameTimeMilliseconds()
end

function SCA:CanShowAlert()
    return (self:GetNow() - self.lastAlertAt) >= (self.saved.throttleMs or self.defaults.throttleMs)
end

function SCA:HideAlert()
    if SmartCombatAlertsPS5_Label then
        SmartCombatAlertsPS5_Label:SetHidden(true)
        SmartCombatAlertsPS5_Label:SetAlpha(0)
    end
end

function SCA:ShowAlert(message, alertType)
    if not self:CanShowAlert() then return end
    
    local label = SmartCombatAlertsPS5_Label
    if not label then return end

    self.lastAlertAt = self:GetNow()
    
    label:SetText(message)
    
    -- Color coding: Red for danger, Gold for heavy attacks
    if alertType == "danger" then
        label:SetColor(1, 0.1, 0.1, 1) -- Red
    else
        label:SetColor(1, 0.8, 0, 1)   -- Gold
    end

    label:SetHidden(false)
    label:SetAlpha(1)

    -- Auto-hide after the duration
    zo_callLater(function() self:HideAlert() end, self.saved.durationMs or self.defaults.durationMs)
end

function SCA:ClassifyAndAlert(result, abilityName, hitValue)
    local name = SafeLower(abilityName)
    
    -- Alert for Heavy Attacks
    if string.find(name, "heavy") or result == ACTION_RESULT_BEGIN then
        self:ShowAlert("BLOCK / DODGE!", "heavy")
        return
    end

    -- Alert for high damage hits
    if hitValue and hitValue >= (self.saved.damageThreshold or self.defaults.damageThreshold) then
        self:ShowAlert("BIG HIT!", "danger")
    end
end

function SCA.OnCombatEvent(_, result, isError, abilityName, _, _, _, _, _, _, hitValue)
    if isError or not SCA.saved or not SCA.saved.enabled or not SCA.inCombat then return end
    SCA:ClassifyAndAlert(result, abilityName, hitValue)
end

function SCA.OnCombatState(_, inCombat)
    SCA.inCombat = inCombat
    if not inCombat then SCA:HideAlert() end
end

function SCA:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnCombatState)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, self.OnCombatEvent)

    -- Filter to only track events hitting the player to save console CPU
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end

function SCA:Initialize()
    self.saved = ZO_SavedVars:NewAccountWide("SmartCombatAlertsPS5_SavedVariables", 1, nil, self.defaults)
    self:RegisterEvents()
    self:HideAlert()
    
    if self.saved.startupMessage then
        zo_callLater(function() 
            d("|cFF0000Smart Combat Alerts|r: Ready for PS5") 
        end, 2000)
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName == SCA.name then
        SCA:Initialize()
        EVENT_MANAGER:UnregisterForEvent(SCA.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(SCA.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)