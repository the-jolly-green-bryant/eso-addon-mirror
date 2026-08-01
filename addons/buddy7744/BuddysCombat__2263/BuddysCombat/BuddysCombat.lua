BuddysCombat = {
	name = "BuddysCombat",
	version = "7.0",
	playerLoaded = false,
	DefaultSettings = {
		fontColor = ZO_ColorDef:New("FF0000"),
		fontScale = 1,
		showing = false,
		transparency = 0,
		text = "Fighting!"
	},
}

function BuddysCombat:Initialize()
	self.inCombat = IsUnitInCombat("player")
	BuddysCombatIndicator:SetHidden(not inCombat)
	self.savedVariables = ZO_SavedVars:New("BuddysCombatSavedVariables", 1, nil, {})
	self:RestorePosition()
	self:CheckDefaultSettingsAreApplied()
	self:CreateSettingsWindow()
end

function BuddysCombat:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
  BuddysCombatIndicator:ClearAnchors()
  BuddysCombatIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function BuddysCombat:HideCombatMessage() BuddysCombatIndicator:SetHidden(not self.savedVariables.showing) end
function BuddysCombat:SetFont() BuddysCombatIndicator:SetScale(self.savedVariables.fontScale) end
function BuddysCombat:SetText() BuddysCombatIndicatorLabel:SetText(self.savedVariables.text) end
function BuddysCombat:SetColor() BuddysCombatIndicatorLabel:SetColor(self.savedVariables.fontColor.r, self.savedVariables.fontColor.g, self.savedVariables.fontColor.b) end

function BuddysCombat.OnIndicatorMoveStop()
	BuddysCombat.savedVariables.left = BuddysCombatIndicator:GetLeft()
	BuddysCombat.savedVariables.top = BuddysCombatIndicator:GetTop()
end

function BuddysCombat.OnPlayerCombatState(event, inCombat)
    -- The player's state has changed. Update the stored state...
    BuddysCombat.inCombat = inCombat
	-- Set the GUI Element visible or hide it, depending on inCombat
    BuddysCombatIndicator:SetHidden(not inCombat)
	BuddysCombat.savedVariables.showing = inCombat
end

function BuddysCombat.OnAddOnLoaded(event, addonName)
	if addonName == BuddysCombat.name then BuddysCombat:Initialize() end
end


-- Event area
EVENT_MANAGER:RegisterForEvent(BuddysCombat.name, EVENT_PLAYER_COMBAT_STATE, BuddysCombat.OnPlayerCombatState)
EVENT_MANAGER:RegisterForEvent(BuddysCombat.name, EVENT_ADD_ON_LOADED, BuddysCombat.OnAddOnLoaded)