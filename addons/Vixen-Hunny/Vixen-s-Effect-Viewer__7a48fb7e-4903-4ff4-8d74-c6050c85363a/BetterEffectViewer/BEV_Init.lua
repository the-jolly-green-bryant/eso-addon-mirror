local BEV = BetterEffectViewer

function BEV:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide("BetterEffectViewer_SV", 3, nil, self.defaults)
    self:EnsureSavedVarSchema()

    self.reticleHoldDuration = self.sv.reticleHoldDuration
    self.targetSwitchDelay = self.sv.targetSwitchDelay

    self.lockedPlayerName = nil
    self.lockedIsActive = false
    self.needsRedraw = false
    self.currentReticleKey = nil
    self.visibleBuffSlotCount = 0
    self.visibleDebuffSlotCount = 0
    self.lastLayoutKey = nil
    self.nextMaintenanceAt = 0
    self.nextVisualUpdateAt = 0
    self.nextFallbackRescanAt = 0

    self:ApplyRuntimePlatformTuning()
    self:ApplyCurrentLayout()

    self:CreateUI()
    self:CreateSettingsMenu()
    self:ResetEffects()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED, function()
        self:OnReticleTargetChanged()
    end)

    self:RegisterEffectEvents()

    EVENT_MANAGER:RegisterForEvent(self.name .. "_Zone", EVENT_PLAYER_ACTIVATED, function()
        self:ApplyCurrentLayout()
    end)

    EVENT_MANAGER:RegisterForUpdate(self.name .. "_Update", 100, function()
        self:OnUpdate()
    end)

    self:RescanReticleBuffs()
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= BetterEffectViewer.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(BetterEffectViewer.name, EVENT_ADD_ON_LOADED)
    BEV:Initialize()
end

EVENT_MANAGER:RegisterForEvent(BetterEffectViewer.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
