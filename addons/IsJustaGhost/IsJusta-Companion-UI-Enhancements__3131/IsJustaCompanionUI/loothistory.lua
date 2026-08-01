---------------------------------------------------------------------------------------------------------------
-- modify loot history companion rapport
---------------------------------------------------------------------------------------------------------------
local COMPANION_NAME_COLOR = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_COMPANION))
local RAPPORT_INCREASE_BACKGROUND_COLOR = ZO_ColorDef:New("102d0b")
local RAPPORT_DECREASE_BACKGROUND_COLOR = ZO_ColorDef:New("3f0a0a")

local function modify_LootHisoryUpdate(object)

	function object:AddCompanionRapportEntry(companionId, isIncrease, adjustmentAmountType, adjustmentAmount)
		local colorizedCompanionName = COMPANION_NAME_COLOR:Colorize(GetCompanionName(companionId))
        local iconFormatter = isIncrease and LOOT_RAPPORT_INCREASE_ICON_FORMATTER or LOOT_RAPPORT_DECREASE_ICON_FORMATTER
		
		local lootData = {
			text = ZO_CachedStrFormat("<<C:1>>", colorizedCompanionName),
			icon = string.format(iconFormatter, adjustmentAmountType),
			color = ZO_SELECTED_TEXT,
			stackCount = adjustmentAmount,
			backgroundColor = isIncrease and RAPPORT_INCREASE_BACKGROUND_COLOR or RAPPORT_DECREASE_BACKGROUND_COLOR,
			companionId = companionId,
			companionName = colorizedCompanionName,
			entryType = LOOT_ENTRY_TYPE_COMPANION_RAPPORT,
			iconOverlayText = ZO_LootHistory_Shared.GetStackCountStringFromData,
			showIconOverlayText = true
		}
		
		local lootEntry = self:CreateLootEntry(lootData)
		lootEntry.isPersistent = true
		self:InsertOrQueue(lootEntry)
	end
	
	function object:OnCompanionRapportUpdate(companionId, previousRapport, currentRapport, adjustmentAmountType)
		if currentRapport ~= previousRapport then
			local adjustmentAmount = math.abs(previousRapport - currentRapport)
			self:AddCompanionRapportEntry(companionId, currentRapport > previousRapport, adjustmentAmountType, adjustmentAmount)
		end
	end
end

	modify_LootHisoryUpdate(LOOT_HISTORY_KEYBOARD)
	modify_LootHisoryUpdate(LOOT_HISTORY_GAMEPAD)
--[[


for _, object in pairs(LOOT_HISTORY_KEYBOARD, LOOT_HISTORY_GAMEPAD) do
	modify_LootHisoryUpdate(object)
end

]]

--	/script LOOT_HISTORY_KEYBOARD:OnCompanionRapportUpdate(GetActiveCompanionDefId(), 200, 213, 1)
--	/script LOOT_HISTORY_GAMEPAD:OnCompanionRapportUpdate(GetActiveCompanionDefId(), 200, 213, 1)
--	/script LOOT_HISTORY_GAMEPAD:OnCompanionRapportUpdate(GetActiveCompanionDefId(), 213,  200, 1)