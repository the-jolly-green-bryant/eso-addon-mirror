--
-- CPieMenuManager [LCPM] : (LibCPieMenu)
--
-- Copyright (c) 2022 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not LibCPieMenu then return end
local LCPM = LibCPieMenu:SetSharedEnvironment()
-- ---------------------------------------------------------------------------------------
local L = GetString

-- ---------------------------------------------------------------------------------------
-- Lookup tables
-- ---------------------------------------------------------------------------------------

CategoryId_To_CollectibleCategoryType = {
	[CATEGORY_C_ASSISTANT]				= COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, 
	[CATEGORY_C_COMPANION]				= COLLECTIBLE_CATEGORY_TYPE_COMPANION, 
	[CATEGORY_C_MEMENTO]				= COLLECTIBLE_CATEGORY_TYPE_MEMENTO, 
	[CATEGORY_C_VANITY_PET]				= COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, 
	[CATEGORY_C_MOUNT]					= COLLECTIBLE_CATEGORY_TYPE_MOUNT, 
	[CATEGORY_C_PERSONALITY]			= COLLECTIBLE_CATEGORY_TYPE_PERSONALITY, 
	[CATEGORY_C_ABILITY_SKIN]			= COLLECTIBLE_CATEGORY_TYPE_ABILITY_SKIN, 
	[CATEGORY_C_TOOL]					= COLLECTIBLE_CATEGORY_TYPE_MEMENTO, 
	[CATEGORY_C_HAT]					= COLLECTIBLE_CATEGORY_TYPE_HAT, 
	[CATEGORY_C_HAIR]					= COLLECTIBLE_CATEGORY_TYPE_HAIR, 
	[CATEGORY_C_HEAD_MARKING]			= COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING, 
	[CATEGORY_C_FACIAL_HAIR_HORNS]		= COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS, 
	[CATEGORY_C_FACIAL_ACCESSORY]		= COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY, 
	[CATEGORY_C_PIERCING_JEWELRY]		= COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY, 
	[CATEGORY_C_COSTUME]				= COLLECTIBLE_CATEGORY_TYPE_COSTUME, 
	[CATEGORY_C_BODY_MARKING]			= COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING, 
	[CATEGORY_C_SKIN]					= COLLECTIBLE_CATEGORY_TYPE_SKIN, 
	[CATEGORY_C_POLYMORPH]				= COLLECTIBLE_CATEGORY_TYPE_POLYMORPH, 
}
CategoryId_To_CollectibleCategoryId = {
	[CATEGORY_C_ASSISTANT]				= 8, 
	[CATEGORY_C_COMPANION]				= 92, 
	[CATEGORY_C_MEMENTO]				= 5, 
	[CATEGORY_C_VANITY_PET]				= 3, 
	[CATEGORY_C_MOUNT]					= 4, 
	[CATEGORY_C_PERSONALITY]			= 12, 
	[CATEGORY_C_ABILITY_SKIN]			= 29, 
	[CATEGORY_C_TOOL]					= 66, 
	[CATEGORY_C_HAT]					= 9, 
	[CATEGORY_C_HAIR]					= 14, 
	[CATEGORY_C_HEAD_MARKING]			= 17, 
	[CATEGORY_C_FACIAL_HAIR_HORNS]		= 15, 
	[CATEGORY_C_FACIAL_ACCESSORY]		= 18, 
	[CATEGORY_C_PIERCING_JEWELRY]		= 19, 
	[CATEGORY_C_COSTUME]				= 2, 
	[CATEGORY_C_BODY_MARKING]			= 16, 
	[CATEGORY_C_SKIN]					= 10, 
	[CATEGORY_C_POLYMORPH]				= 11, 
}
CategoryId_To_EmoteCategory = {
	[CATEGORY_E_CEREMONIAL]				= EMOTE_CATEGORY_CEREMONIAL, 
	[CATEGORY_E_CHEERS_AND_JEERS]		= EMOTE_CATEGORY_CHEERS_AND_JEERS, 
	[CATEGORY_E_EMOTION]				= EMOTE_CATEGORY_EMOTION, 
	[CATEGORY_E_ENTERTAINMENT]			= EMOTE_CATEGORY_ENTERTAINMENT, 
	[CATEGORY_E_FOOD_AND_DRINK]			= EMOTE_CATEGORY_FOOD_AND_DRINK, 
	[CATEGORY_E_GIVE_DIRECTIONS]		= EMOTE_CATEGORY_GIVE_DIRECTIONS, 
	[CATEGORY_E_PHYSICAL]				= EMOTE_CATEGORY_PHYSICAL, 
	[CATEGORY_E_POSES_AND_FIDGETS]		= EMOTE_CATEGORY_POSES_AND_FIDGETS, 
	[CATEGORY_E_PROP]					= EMOTE_CATEGORY_PROP, 
	[CATEGORY_E_SOCIAL]					= EMOTE_CATEGORY_SOCIAL, 
	[CATEGORY_E_COLLECTED] 				= EMOTE_CATEGORY_COLLECTED, 
}
CategoryId_To_Icon = {
	[CATEGORY_NOTHING]					= "EsoUI/Art/Inventory/inventory_tabIcon_quickslot_up.dds", 
	[CATEGORY_IMMEDIATE_VALUE]			= "EsoUI/Art/Icons/Emotes/emotecategoryicon_common.dds", 
	[CATEGORY_E_CEREMONIAL]				= GetSharedEmoteIconForCategory(EMOTE_CATEGORY_CEREMONIAL), 
	[CATEGORY_E_CHEERS_AND_JEERS]		= GetSharedEmoteIconForCategory(EMOTE_CATEGORY_CHEERS_AND_JEERS), 
	[CATEGORY_E_EMOTION]				= GetSharedEmoteIconForCategory(EMOTE_CATEGORY_EMOTION), 
	[CATEGORY_E_ENTERTAINMENT]			= GetSharedEmoteIconForCategory(EMOTE_CATEGORY_ENTERTAINMENT), 
	[CATEGORY_E_FOOD_AND_DRINK]			= GetSharedEmoteIconForCategory(EMOTE_CATEGORY_FOOD_AND_DRINK), 
	[CATEGORY_E_GIVE_DIRECTIONS]		= GetSharedEmoteIconForCategory(EMOTE_CATEGORY_GIVE_DIRECTIONS), 
	[CATEGORY_E_PHYSICAL]				= GetSharedEmoteIconForCategory(EMOTE_CATEGORY_PHYSICAL), 
	[CATEGORY_E_POSES_AND_FIDGETS]		= GetSharedEmoteIconForCategory(EMOTE_CATEGORY_POSES_AND_FIDGETS), 
	[CATEGORY_E_PROP]					= GetSharedEmoteIconForCategory(EMOTE_CATEGORY_PROP), 
	[CATEGORY_E_SOCIAL]					= GetSharedEmoteIconForCategory(EMOTE_CATEGORY_SOCIAL), 
	[CATEGORY_E_COLLECTED] 				= GetSharedEmoteIconForCategory(EMOTE_CATEGORY_COLLECTED), 
}
ActionTypeApiStrings = {
	["collectible"] 		= ACTION_TYPE_COLLECTIBLE, 
	["emote"] 				= ACTION_TYPE_EMOTE, 
	["chat_command"] 		= ACTION_TYPE_CHAT_COMMAND, 
	["travel_to_house"] 	= ACTION_TYPE_TRAVEL_TO_HOUSE, 
	["pie_menu"] 			= ACTION_TYPE_PIE_MENU, 
	["shortcut"] 			= ACTION_TYPE_SHORTCUT, 
}
ActionTypeAlias = {
	[ACTION_TYPE_COLLECTIBLE_APPEARANCE]		= ACTION_TYPE_COLLECTIBLE, 
	[ACTION_TYPE_SHORTCUT_ADDON]				= ACTION_TYPE_SHORTCUT, 
}
UI_Color = {
	["NORMAL"]				= { 1, 1, 1, }, 
	["ACTIVE"]				= { 0.6, 1, 0, }, 
	["BLOCKED"]				= { 1, 0.3, 0, }, 
}
UI_Icon = {
	["CHECK"]				= "EsoUI/Art/Miscellaneous/check_icon_32.dds", 
	["LOCKED"]				= "EsoUI/Art/Miscellaneous/status_locked.dds", 
	["UNLOCKED"]			= "EsoUI/Art/Miscellaneous/Gamepad/gp_icon_unlocked32.dds", 
	["BLOCKED"]				= "EsoUI/Art/Mappins/hostile_pin.dds", 
	["HELP"]				= "EsoUI/Art/Miscellaneous/help_icon.dds", 
	["NEW"]					= "EsoUI/Art/Miscellaneous/new_icon.dds", 
	["WARNING"]				= "EsoUI/Art/Miscellaneous/eso_icon_warning.dds", 
	["MOUSE_LMB"]			= GetMouseIconPathForKeyCode(KEY_MOUSE_LEFT), 
	["MOUSE_RMB"]			= GetMouseIconPathForKeyCode(KEY_MOUSE_RIGHT), 
	["GAMEPAD_1"]			= GetGamepadIconPathForKeyCode(KEY_GAMEPAD_BUTTON_1), 
	["GAMEPAD_2"]			= GetGamepadIconPathForKeyCode(KEY_GAMEPAD_BUTTON_2), 
}

-- ---------------------------------------------------------------------------------------
-- Shared Utilities
-- ---------------------------------------------------------------------------------------
function GetValue(value, ...)
	if type(value) == "function" then
		return value(...)
	else
		return value
	end
end

function GetActionType(value)
	local value = GetValue(value)
	local actionType = type(value) == "string" and ActionTypeApiStrings[zo_strlower(value)] or value or ACTION_TYPE_NOTHING
	return ActionTypeAlias[actionType] or actionType
end

local GetDefaultSlotNameT = {		-- you cannot use 'self' within this block.
	[ACTION_TYPE_NOTHING] = function(actionType, categoryId, actionValue)
		return ""
	end, 
	[ACTION_TYPE_COLLECTIBLE] = function(_, _, actionValue)
		local name = zo_strformat(L(SI_CSPM_COMMON_FORMATTER), GetCollectibleName(actionValue))
		local nameColor
		if IsCollectibleActive(actionValue, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then 
			nameColor = UI_Color.ACTIVE
		elseif GetCollectibleBlockReason(actionValue) ~= COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
			nameColor = UI_Color.BLOCKED
		end
		return name, nameColor
	end, 
	[ACTION_TYPE_EMOTE] = function(_, _, actionValue)
		local emoteItemInfo = PLAYER_EMOTE_MANAGER:GetEmoteItemInfo(actionValue)
		local name = zo_strformat(L(SI_CSPM_COMMON_FORMATTER), emoteItemInfo and emoteItemInfo.displayName or "")
		local nameColor = emoteItemInfo and emoteItemInfo.isOverriddenByPersonality and { ZO_PERSONALITY_EMOTES_COLOR:UnpackRGB() }
		return name, nameColor
	end, 
	[ACTION_TYPE_CHAT_COMMAND] = function(_, _, actionValue)
		return tostring(actionValue)
	end, 
	[ACTION_TYPE_TRAVEL_TO_HOUSE] = function(_, categoryId, actionValue)
		local name = ""
		if actionValue == ACTION_VALUE_PRIMARY_HOUSE_ID then
			name = L(SI_HOUSING_FURNITURE_SETTINGS_GENERAL_PRIMARY_RESIDENCE_TEXT)		-- "Primary Residence"
		else
			name = zo_strformat(L(SI_CSPM_COMMON_FORMATTER), GetCollectibleName(GetCollectibleIdForHouse(actionValue)))
		end
		if actionValue ~= 0 then
			if categoryId == CATEGORY_H_UNLOCKED_HOUSE_INSIDE then
				name = zo_strformat(L(SI_GAMEPAD_WORLD_MAP_TRAVEL_TO_HOUSE_INSIDE), name)		-- "<<1>> (inside)"
			elseif categoryId == CATEGORY_H_UNLOCKED_HOUSE_OUTSIDE then
				name = zo_strformat(L(SI_GAMEPAD_WORLD_MAP_TRAVEL_TO_HOUSE_OUTSIDE), name)	-- "<<1>> (outside)"
			end
		end
		return name
	end, 
	[ACTION_TYPE_PIE_MENU] = function(_, _, actionValue)
		local name = ""
		if IsUserPieMenu(actionValue) and actionValue ~= 0 then
			name = zo_strformat(L(SI_CSPM_PRESET_NO_NAME_FORMATTER), actionValue)
		elseif IsExternalPieMenu(actionValue) and actionValue ~= "" then
			name = zo_strformat(L(SI_CSPM_COMMON_FORMATTER), GetPieMenuInfo(actionValue) or "")
		end
		return name
	end, 
	[ACTION_TYPE_SHORTCUT] = function(_, _, actionValue)
		local name, _, _, _, nameColor = GetShortcutInfo(actionValue)	-- actionValue: shortcutData or shortcutId
		return name or "", nameColor
	end, 
}
setmetatable(GetDefaultSlotNameT, { __index = function(self, key) return rawget(self, ACTION_TYPE_NOTHING) end, })

function GetDefaultSlotName(actionType, categoryId, actionValue)
	local actionType = GetActionType(actionType)
	local categoryId = GetValue(categoryId)
	local actionValue = GetValue(actionValue)
	return GetDefaultSlotNameT[actionType](actionType, categoryId, actionValue)
end



local GetDefaultSlotIconT = {		-- you cannot use 'self' within this block.
	[ACTION_TYPE_NOTHING] = function(actionType, categoryId, actionValue)
		return ""
	end, 
	[ACTION_TYPE_COLLECTIBLE] = function(_, _, actionValue)
		return GetCollectibleIcon(actionValue)
	end, 
	[ACTION_TYPE_EMOTE] = function(_, categoryId, actionValue)
		local icon = ""
		local emoteItemInfo = PLAYER_EMOTE_MANAGER:GetEmoteItemInfo(actionValue)
		if emoteItemInfo then
			local emoteCollectibleId = GetEmoteCollectibleId(emoteItemInfo.emoteIndex)
			if emoteCollectibleId then
				icon = GetCollectibleIcon(emoteCollectibleId)
			else
				icon = CategoryId_To_Icon[categoryId] or CategoryId_To_Icon[CATEGORY_NOTHING]
			end
		end
		return icon
	end, 
	[ACTION_TYPE_CHAT_COMMAND] = function(_, _, _)
		return "EsoUI/Art/Icons/crafting_dwemer_shiny_cog.dds"
	end, 
	[ACTION_TYPE_TRAVEL_TO_HOUSE] = function(_, _, actionValue)
		local icon
		if actionValue == ACTION_VALUE_PRIMARY_HOUSE_ID then
			icon = "EsoUI/Art/Worldmap/map_indexicon_housing_up.dds"
		else
			icon = GetCollectibleIcon(GetCollectibleIdForHouse(actionValue))
		end
		return icon
	end, 
	[ACTION_TYPE_PIE_MENU] = function(_, _, actionValue)
		local icon
		if IsUserPieMenu(actionValue) then
			icon = "EsoUI/Art/Icons/crafting_tart_006.dds"
		else
			icon = (select(3, GetPieMenuInfo(actionValue))) or "EsoUI/Art/Icons/crafting_tart_006.dds"
		end
		return icon
	end, 
	[ACTION_TYPE_SHORTCUT] = function(_, _, actionValue)
		return (select(3, GetShortcutInfo(actionValue))) or "EsoUI/Art/Icons/crafting_dwemer_shiny_gear.dds"	-- actionValue: shortcutData or shortcutId
	end, 
}
setmetatable(GetDefaultSlotIconT, { __index = function(self, key) return rawget(self, ACTION_TYPE_NOTHING) end, })

function GetDefaultSlotIcon(actionType, categoryId, actionValue)
	local actionType = GetActionType(actionType)
	local categoryId = GetValue(categoryId)
	local actionValue = GetValue(actionValue)
	return GetDefaultSlotIconT[actionType](actionType, categoryId, actionValue)
end


local FULL_WIDTH = true
function GetSlotActionTooltip()
	return ItemTooltip
end

function LayoutBasicSlotActionTooltip(tooltip, title, body, icon, leftSideHeader, rightSideHeader)
	InitializeTooltip(tooltip)
	local r, g, b = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
	if icon then
		ZO_ItemIconTooltip_OnAddGameData(tooltip, TOOLTIP_GAME_DATA_ITEM_ICON, GetValue(icon))
	end
	if leftSideHeader and leftSideHeader ~= "" then
		tooltip:AddHeaderLine(GetValue(leftSideHeader), "ZoFontWinH5", 1, TOOLTIP_HEADER_SIDE_LEFT, r, g, b)
	end
	if rightSideHeader and rightSideHeader ~= "" then
		tooltip:AddHeaderLine(GetValue(rightSideHeader), "ZoFontWinH5", 1, TOOLTIP_HEADER_SIDE_RIGHT, r, g, b)
	end
	if not leftSideHeader and not rightSideHeader then
		tooltip:AddVerticalPadding(18)
	end
	r, g, b = ZO_SELECTED_TEXT:UnpackRGB()
	if title and title ~= "" then
		tooltip:AddLine(GetValue(title), "ZoFontWinH2", r, g, b, TOPLEFT, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, FULL_WIDTH)
		ZO_Tooltip_AddDivider(tooltip)
	end
	if body and body ~= "" then
		tooltip:AddLine(GetValue(body), "ZoFontGameMedium", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
	end
end



local LayoutSlotActionTooltipT = {		-- you cannot use 'self' within this block.
	[ACTION_TYPE_NOTHING] = function(actionType, categoryId, actionValue, uiActionId)
		ClearTooltip(ItemTooltip)
		return false
	end, 
	[ACTION_TYPE_COLLECTIBLE] = function(actionType, _, actionValue)
		local name, description, icon, _, _, _, isActive, collectibleCategoryType = GetCollectibleInfo(actionValue)
		if name ~= "" then
			name = zo_strformat(L(SI_CSPM_COMMON_FORMATTER), name)
			LayoutBasicSlotActionTooltip(ItemTooltip, name, description, icon, L("SI_COLLECTIBLECATEGORYTYPE", collectibleCategoryType), isActive and "Active" or "Inactive")
			ItemTooltip:AddLine(zo_strformat(L("SI_CSPM_SLOT_ACTION_TOOLTIP", actionType), name), "ZoFontWinH4", ZO_SELECTED_TEXT:UnpackRGB())
			if collectibleCategoryType == COLLECTIBLE_CATEGORY_TYPE_PERSONALITY then
				local overridenEmoteNames = { GetCollectiblePersonalityOverridenEmoteDisplayNames(actionValue) }
				local overridenEmoteSlashCommands = { GetCollectiblePersonalityOverridenEmoteSlashCommandNames(actionValue) }
				if #overridenEmoteSlashCommands > 0 then
					ItemTooltip:AddLine(zo_strformat(SI_COLLECTIBLE_TOOLTIP_PERSONALITY_OVERRIDES_DISPLAY_NAMES_FORMATTER, ZO_GenerateCommaSeparatedList(overridenEmoteSlashCommands), #overridenEmoteSlashCommands), "ZoFontWinH5", ZO_PERSONALITY_EMOTES_COLOR:UnpackRGB())
				end
			end
			return true
		else
			return false
		end
	end, 
	[ACTION_TYPE_EMOTE] = function(actionType, categoryId, actionValue)
		local emoteItemInfo = PLAYER_EMOTE_MANAGER:GetEmoteItemInfo(actionValue)
		if emoteItemInfo then
			local name = zo_strformat(L(SI_CSPM_COMMON_FORMATTER), emoteItemInfo.displayName)
			local emoteCollectibleId = GetEmoteCollectibleId(emoteItemInfo.emoteIndex)
			if emoteCollectibleId then
				local _, description, icon, _, _, _, _, collectibleCategoryType = GetCollectibleInfo(emoteCollectibleId)
				LayoutBasicSlotActionTooltip(ItemTooltip, name, description, icon, L("SI_COLLECTIBLECATEGORYTYPE", collectibleCategoryType))
			else
				LayoutBasicSlotActionTooltip(ItemTooltip, name, nil, CategoryId_To_Icon[categoryId] or CategoryId_To_Icon[CATEGORY_NOTHING], L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_EMOTE))
			end
			ItemTooltip:AddLine(zo_strformat(L("SI_CSPM_SLOT_ACTION_TOOLTIP", actionType), emoteItemInfo.emoteSlashName), "ZoFontWinH4", ZO_SELECTED_TEXT:UnpackRGB())
			return true
		else
			return false
		end
	end, 
	[ACTION_TYPE_CHAT_COMMAND] = function(actionType, categoryId, actionValue)
		local name = GetDefaultSlotName(actionType, categoryId, actionValue)
		local icon = GetDefaultSlotIcon(actionType, categoryId, actionValue)
		LayoutBasicSlotActionTooltip(ItemTooltip, name, nil, icon, L(SI_CSPM_COMMON_CHAT_COMMAND))
		ItemTooltip:AddLine(zo_strformat(L("SI_CSPM_SLOT_ACTION_TOOLTIP", actionType), name), "ZoFontWinH4", ZO_SELECTED_TEXT:UnpackRGB())
		return true
	end, 
	[ACTION_TYPE_TRAVEL_TO_HOUSE] = function(actionType, categoryId, actionValue)
		local name = GetDefaultSlotName(actionType, categoryId, actionValue)
		local icon = GetDefaultSlotIcon(actionType, categoryId, actionValue)
		local houseCollectibleId, description
		if actionValue == ACTION_VALUE_PRIMARY_HOUSE_ID then
			houseCollectibleId = GetHousingPrimaryHouse()
			_, description = GetHelpInfo(GetHelpIndicesFromHelpLink("|H1:help:278|h|h"))	-- Tutorial: Housing - Permissions
		else
			if actionValue == 0 then return false end
			houseCollectibleId = GetCollectibleIdForHouse(actionValue)
			description = GetCollectibleDescription(houseCollectibleId)
		end
		LayoutBasicSlotActionTooltip(ItemTooltip, name, description, icon, L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_HOUSE))
		ItemTooltip:AddLine(zo_strformat(L("SI_CSPM_SLOT_ACTION_TOOLTIP", actionType), name), "ZoFontWinH4", ZO_SELECTED_TEXT:UnpackRGB())
--		ItemTooltip:AddLine(zo_strformat(L(SI_HOUSING_BOOK_HOUSE_TYPE_FORMATTER), L("SI_HOUSECATEGORYTYPE", GetHouseCategoryType(actionValue))), "ZoFontWinH5", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
		ItemTooltip:AddLine(zo_strformat(L(SI_HOUSING_BOOK_LOCATION_FORMATTER), GetZoneNameById(GetHouseFoundInZoneId(actionValue))), "ZoFontWinH5", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
		return true
	end, 
	[ACTION_TYPE_PIE_MENU] = function(actionType, categoryId, actionValue, uiActionId)
		if not DoesPieMenuDataExist(actionValue) then return false end
		local name = GetDefaultSlotName(actionType, categoryId, actionValue)
		local tooltipTitle = name
		local pieMenuName, description, icon = GetPieMenuInfo(actionValue)
		if IsUserPieMenu(actionValue) and pieMenuName and pieMenuName ~= "" then
			tooltipTitle = zo_strformat(L(SI_CSPM_PRESET_NAME_FORMATTER), actionValue, pieMenuName)
		end
		LayoutBasicSlotActionTooltip(ItemTooltip, tooltipTitle, description, icon or GetDefaultSlotIcon(actionType, categoryId, actionValue), L(SI_CSPM_COMMON_PIE_MENU))
		if uiActionId ~= UI_NONE then
			ItemTooltip:AddLine(zo_strformat(L("SI_CSPM_SLOT_ACTION_TOOLTIP", actionType), name), "ZoFontWinH4", ZO_SELECTED_TEXT:UnpackRGB())
		end
		return true
	end, 
	[ACTION_TYPE_SHORTCUT] = function(actionType, categoryId, actionValue)
		local name, description, icon = GetShortcutInfo(actionValue)	-- actionValue: shortcutData or shortcutId
		if not name or name == "" then return false end
		LayoutBasicSlotActionTooltip(ItemTooltip, name, description, icon or GetDefaultSlotIcon(actionType, categoryId, actionValue), L(SI_CSPM_COMMON_SHORTCUT))
		ItemTooltip:AddLine(zo_strformat(L("SI_CSPM_SLOT_ACTION_TOOLTIP", actionType), name), "ZoFontWinH4", ZO_SELECTED_TEXT:UnpackRGB())
		return true
	end, 
}
setmetatable(LayoutSlotActionTooltipT, { __index = function(self, key) return rawget(self, ACTION_TYPE_NOTHING) end, })

function LayoutSlotActionTooltip(actionType, categoryId, actionValue, uiActionId)
	local actionType = GetActionType(actionType)
	local categoryId = GetValue(categoryId)
	local actionValue = GetValue(actionValue)
	return LayoutSlotActionTooltipT[actionType](actionType, categoryId, actionValue, uiActionId)
end


function ShowSlotActionTooltip(owner, point, offsetX, offsetY, relativePoint)
	GetSlotActionTooltip():SetOwner(owner, point, offsetX, offsetY, relativePoint)
	GetSlotActionTooltip():GetOwningWindow():BringWindowToTop()
end

function HideSlotActionTooltip()
    ClearTooltip(GetSlotActionTooltip())
end
