if not GildedUI then return end

local Addon = GildedUI

Addon.COMBAT_STATUS_ICON = "/esoui/art/addons/gamepad/gp_mod_listing_category_combat.dds"
Addon.COMBAT_STATUS_ICON_SIZE = 32

Addon:RegisterDefaults({
    showCombatStatus = false,
    combatStatusPosX = 50,
    combatStatusPosY = 50,
    combatStatusInCombatColor = { 1, 0.25, 0.2, 1 },
    combatStatusOutOfCombatColor = { 0.65, 0.65, 0.65, 0.55 },
})

function Addon:SanitizeCombatStatus()
    local limits = self.limits
    self:ClampSavedNumber("combatStatusPosX", limits.posX)
    self:ClampSavedNumber("combatStatusPosY", limits.posY)
    self:SanitizeSavedBoolean("showCombatStatus")
    self:SanitizeSavedColor("combatStatusInCombatColor", true)
    self:SanitizeSavedColor("combatStatusOutOfCombatColor", true)
end

function Addon:SetCombatStatusMenuPreview(enabled)
    self.state.combatStatusMenuPreview = enabled == true
    self:UpdateVisibility()
end

function Addon:ApplyCombatStatusPosition()
    local sv = self.state.sv
    if not sv then return end
    self:ApplyReadoutPosition(self.state.combatStatusWindow, sv.combatStatusPosX, sv.combatStatusPosY)
end

function Addon:ApplyCombatStatusColor()
    local icon = self.state.combatStatusIcon
    local sv = self.state.sv
    if not icon or not sv then return end

    local color = IsUnitInCombat("player") and sv.combatStatusInCombatColor or sv.combatStatusOutOfCombatColor
    icon:SetColor(color[1], color[2], color[3], color[4] or 1)
end

function Addon:UpdateCombatStatus()
    local window = self.state.combatStatusWindow
    if not window or window:IsHidden() then return end
    self:ApplyCombatStatusColor()
end

function Addon:SetCombatStatusEnabled(enabled)
    self.state.sv.showCombatStatus = enabled
    self:UpdateVisibility()
    if enabled then
        self:UpdateCombatStatus()
    end
end

function Addon:CreateCombatStatusOverlay(wm)
    local sv = self.state.sv
    local window = wm:CreateTopLevelWindow(self.name .. "_CombatStatus_Window")
    self:ConfigureReadoutWindow(window)
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.combatStatusPosX, sv.combatStatusPosY)

    local icon = wm:CreateControl(self.name .. "_CombatStatus_Icon", window, CT_TEXTURE)
    icon:SetDimensions(self.COMBAT_STATUS_ICON_SIZE, self.COMBAT_STATUS_ICON_SIZE)
    icon:SetTexture(self.COMBAT_STATUS_ICON)
    icon:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)

    window:SetDimensions(self.COMBAT_STATUS_ICON_SIZE, self.COMBAT_STATUS_ICON_SIZE)

    self.state.combatStatusWindow = window
    self.state.combatStatusIcon = icon
    self:ApplyCombatStatusColor()
end

function Addon:RegisterCombatStatusEvents()
    if self.state.combatStatusEventsRegistered then return end
    self.state.combatStatusEventsRegistered = true

    local eventName = self.name .. "_CombatStatus"
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_PLAYER_COMBAT_STATE, function()
        Addon:UpdateCombatStatus()
    end)
end
