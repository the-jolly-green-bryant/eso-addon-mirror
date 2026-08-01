local ADDON_NAME = "ScootworksUltiPercentFix"
local zo_clamp, math_floor = zo_clamp, math.floor
local SETTINGS_SHOW_PERCENT_VALUES = 1
local SETTINGS_ULTIMATE_STRING_FORMAT = 2
local SLOT_ULTIMATE = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1

local function GetUltiValueInPercent(HOTBAR_CATEGORY)
	local ultimate_type = "player";
	if (HOTBAR_CATEGORY == HOTBAR_CATEGORY_COMPANION) then
		ultimate_type = "companion"
	end

	local slotAbilityCost = GetSlotAbilityCost(SLOT_ULTIMATE, HOTBAR_CATEGORY)
	if slotAbilityCost ~= 0 then
		return math_floor(zo_clamp(GetUnitPower(ultimate_type, POWERTYPE_ULTIMATE) / slotAbilityCost * 100, 0, 100))
	else
		return 0
	end
end


local function OnAddOnLoaded(eventCode, addonName)
	if addonName == ADDON_NAME then		
		local orgUpdateUltimateNumber = ActionButton.UpdateUltimateNumber

		function ActionButton:UpdateUltimateNumber()
			if SCOOTWORKS_ULTI_PERCENT.account[SETTINGS_SHOW_PERCENT_VALUES] then
				return self.countText:SetText(ZO_CachedStrFormat(SCOOTWORKS_ULTI_PERCENT.textFormat, GetUltiValueInPercent(self.button.hotbarCategory)))
			end
			return orgUpdateUltimateNumber(self)
		end

		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)