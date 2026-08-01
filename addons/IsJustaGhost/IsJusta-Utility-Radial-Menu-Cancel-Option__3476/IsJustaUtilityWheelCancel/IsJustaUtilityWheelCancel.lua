--[[


- - - 1.2
○ added cancel option to Target icon radial

- - - 1.0.3
○ removed Cancel from Quick slots category since it doesn't really need it.

- - - 1.0.2
○ stooped "Cancel" from showing cooldown
○ added game mode based cancel icon

- - - 1.0.1
○ fixed error: Attempt to access a private function 'OnSlotUp' 

- - - 1
○ Initial


]]

local addonData = {
	displayName = "|cFF00FFIsJusta|r |cffffffUtility Radial Menu Cancel Option|r",
	name = "IsJustaUtilityWheelCancel",
	prefix = "IJA_UWC",
	version = "1.2",
}

-------------------
-- Initialize
-------------------
-- Set the First Bar slot to 9 to free up 1 to use for cancel
local slotNum = ACTION_BAR_UTILITY_BAR_SIZE + 1

local VAR_UTILITY_SLOT_CANCEL_STRING = GetString(SI_CANCEL)
local function getPlatformIcon()
	return IsInGamepadPreferredMode() and "EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds"
		or "EsoUI/Art/HUD/radialIcon_cancel_up.dds"
end

SecurePostHook(ZO_UtilityWheel_Shared, 'PopulateMenu', function(self)
    local hotbarCategory = self:GetHotbarCategory()
	if hotbarCategory ~= HOTBAR_CATEGORY_QUICKSLOT_WHEEL then
		local icon = getPlatformIcon()
		self.menu:AddEntry(VAR_UTILITY_SLOT_CANCEL_STRING, icon, icon, function() end, { slotNum = slotNum })
	end
end)

SecurePostHook(ZO_TargetMarkerWheel_Shared, 'PopulateMenu', function(self)
	local iconPath = getPlatformIcon()
	self.menu:AddEntry("", iconPath, iconPath, function() end, #self.menu.entries + 1)
end)



--[[

	#self.entries
function ZO_TargetMarkerWheel_Shared:PopulateMenu()
    local icons = IsInGamepadPreferredMode() and TARGET_MARKER_ICONS_GAMEPAD or TARGET_MARKER_ICONS_KEYBOARD
    for iconIndex, iconPath in ipairs(GetPlatformTargetMarkerIconTable()) do
        self.menu:AddEntry("", iconPath, iconPath, function() AssignTargetMarkerToReticleTarget(iconIndex) end, iconIndex)
    end
end



]]