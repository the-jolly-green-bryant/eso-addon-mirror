if not GildedUI then return end

local Addon = GildedUI

function Addon:CreateOverlay()
    self:CreateAnalyticsOverlay()
    self:CreateResourcesOverlay()
    self:CreatePlayerOverlay()
    self:ApplyBackground()
end

function Addon:ApplyFont()
    self:ApplyAnalyticsFont()
    self:ApplyResourcesFont()
end

function Addon:ApplyBackground()
    self:ApplyAnalyticsBackground()
    self:ApplyResourcesBackground()
end

function Addon:UpdateVisibility()
    local sv = self.state.sv
    if not sv then return end

    local showAnalytics = self.state.hudVisible or sv.showInMenu
    local showResources = self.state.hudVisible or sv.showResourcesInMenu
    if showResources and sv.hideResourcesInBattlegrounds and IsActiveWorldBattleground() then
        showResources = false
    end
    local showPlayer = self.state.hudVisible

    if self.state.fpsWindow then
        self.state.fpsWindow:SetHidden(not sv.showFPS or not showAnalytics)
    end
    if self.state.pingWindow then
        self.state.pingWindow:SetHidden(not sv.showPing or not showAnalytics)
    end
    if self.state.memoryWindow then
        self.state.memoryWindow:SetHidden(not sv.showMemory or not showAnalytics)
    end
    if self.state.bagWindow then
        self.state.bagWindow:SetHidden(not sv.showBag or not showResources)
    end
    if self.state.bankWindow then
        self.state.bankWindow:SetHidden(not sv.showBank or not showResources)
    end
    if self.state.combatStatusWindow then
        local showCombat = (sv.showCombatStatus and showPlayer) or self.state.combatStatusMenuPreview
        self.state.combatStatusWindow:SetHidden(not showCombat)
    end
    self:UpdateCurrencyVisibility(showResources)

    self:UpdateResources()
    self:UpdateCombatStatus()
end

function Addon:ResetToDefaults()
    local sv = self.state.sv
    for key, value in pairs(self.defaults) do
        if type(value) == "table" then
            local copy = {}
            for i = 1, #value do
                copy[i] = value[i]
            end
            sv[key] = copy
        else
            sv[key] = value
        end
    end

    self:ApplyAnalyticsDefaults()
    self:ApplyResourcesDefaults()
    self:ApplyPlayerDefaults()
    self:ApplyTrackerColumnDefaults()
    self:ApplyAlertTextDefaults()
    self:RegisterUpdateLoop()
    self:UpdateVisibility()
end
