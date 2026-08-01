--
-- Calamath's Shortcut Pie Menu [CSPM]
--
-- Copyright (c) 2021 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not CShortcutPieMenu then return end
local CSPM = CShortcutPieMenu:SetSharedEnvironment()
-- ---------------------------------------------------------------------------------------
local L = GetString
local LAM = LibAddonMenu2

-- ---------------------------------------------------------------------------------------
-- Helper Functions
-- ---------------------------------------------------------------------------------------
local function ClearTable(luaTable)
	luaTable = luaTable or {}
	ZO_ClearTable(luaTable)
end

-- ---------------------------------------------------------------------------------------
-- PieMenuEditor Panel Class
-- ---------------------------------------------------------------------------------------
local CSPM_PieMenuEditorPanel = CT_LAMSettingPanelController:Subclass()
function CSPM_PieMenuEditorPanel:Initialize(panelId, currentSavedVars, accountWideSavedVars, defaults)
	CT_LAMSettingPanelController.Initialize(self, panelId)	-- Note: Inherit template class but not use as an initializing object.
	self.pieMenuDataManager = GetPieMenuDataManager()
	self.shortcutDataManager = GetShortcutDataManager()
	self.db = accountWideSavedVars or currentSavedVars or {}
	self.DB_DEFAULT = defaults or {}

	self.currentPresetId = 1
	self.currentSlotId = 1

	self.categoryChoices = {}
	self.categoryChoicesValues = {}
	self.actionValueChoices = {}
	self.actionValueChoicesValues = {}

	self:RebuildUserPieMenuPresetSelectionChoices()	-- presetChoices, actionValueChoices[CATEGORY_P_OPEN_USER_PIE_MENU]

	self.slotDisplayNameCache = {}
	self:RebuildSlotSelectionChoices(MENU_ITEMS_COUNT_DEFAULT)	-- slotChoices

	self.actionTypeChoices = {
		L(SI_CSPM_COMMON_UNSELECTED), 
		L(SI_CSPM_COMMON_COLLECTIBLE), 
		L(SI_CSPM_COMMON_APPEARANCE), 
		L(SI_CSPM_COMMON_EMOTE), 
		L(SI_CSPM_COMMON_CHAT_COMMAND), 
		L(SI_CSPM_COMMON_TRAVEL_TO_HOUSE), 
		L(SI_CSPM_COMMON_PIE_MENU), 
		L(SI_CSPM_COMMON_SHORTCUT), 
		L(SI_CSPM_COMMON_ADDON), 
	} 
	self.actionTypeChoicesValues = {
		ACTION_TYPE_NOTHING, 
		ACTION_TYPE_COLLECTIBLE, 
		ACTION_TYPE_COLLECTIBLE_APPEARANCE, 
		ACTION_TYPE_EMOTE, 
		ACTION_TYPE_CHAT_COMMAND, 
		ACTION_TYPE_TRAVEL_TO_HOUSE, 
		ACTION_TYPE_PIE_MENU, 
		ACTION_TYPE_SHORTCUT, 
		ACTION_TYPE_SHORTCUT_ADDON, 
	}
	self.actionTypeChoicesTooltips = {
		L(SI_CSPM_UI_ACTION_TYPE_NOTHING_TIPS), 
		L(SI_CSPM_UI_ACTION_TYPE_COLLECTIBLE_TIPS), 
		L(SI_CSPM_UI_ACTION_TYPE_COLLECTIBLE_APPEARANCE_TIPS), 
		L(SI_CSPM_UI_ACTION_TYPE_EMOTE_TIPS), 
		L(SI_CSPM_UI_ACTION_TYPE_CHAT_COMMAND_TIPS), 
		L(SI_CSPM_UI_ACTION_TYPE_TRAVEL_TO_HOUSE_TIPS), 
		L(SI_CSPM_UI_ACTION_TYPE_PIE_MENU_TIPS), 
		L(SI_CSPM_UI_ACTION_TYPE_SHORTCUT_TIPS), 
		L(SI_CSPM_UI_ACTION_TYPE_SHORTCUT_ADDON_TIPS), 
	}

	self.categoryChoices[ACTION_TYPE_NOTHING], self.categoryChoicesValues[ACTION_TYPE_NOTHING] = {}, {}
	self.categoryChoices[ACTION_TYPE_COLLECTIBLE] = {
		L(SI_CSPM_COMMON_UNSELECTED), 
		L(SI_CSPM_COMMON_IMMEDIATE_VALUE), 
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_ASSISTANT), 		-- "Assistant", 
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_COMPANION), 		-- "Companion", 
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_MEMENTO), 		-- "Memento", 
		GetCollectibleCategoryNameByCategoryId(CategoryId_To_CollectibleCategoryId[CATEGORY_C_TOOL]), -- "Tools", 
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_VANITY_PET), 		-- "Non-combat-pet", 
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_MOUNT), 			-- "Mount", 
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_PERSONALITY), 	-- "Personality", 
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_ABILITY_SKIN), 	-- "Ability Skin", 
	}
	self.categoryChoicesValues[ACTION_TYPE_COLLECTIBLE] = {
		CATEGORY_NOTHING, 
		CATEGORY_IMMEDIATE_VALUE, 
		CATEGORY_C_ASSISTANT, 
		CATEGORY_C_COMPANION, 
		CATEGORY_C_MEMENTO, 
		CATEGORY_C_TOOL, 
		CATEGORY_C_VANITY_PET, 
		CATEGORY_C_MOUNT, 
		CATEGORY_C_PERSONALITY, 
		CATEGORY_C_ABILITY_SKIN, 
	}
	self.categoryChoices[ACTION_TYPE_COLLECTIBLE_APPEARANCE] = {
		L(SI_CSPM_COMMON_UNSELECTED), 
		L(SI_CSPM_COMMON_IMMEDIATE_VALUE), 
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_HAT), 				-- "Hat" 
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_HAIR), 				-- "Hair"
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING), 		-- "Head Marking"
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS), 	-- "Facial Hair / Horns"
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY), 	-- "Major Adornment"
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY), 	-- "Minor Adornment"
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_COSTUME), 			-- "Costume"
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING), 		-- "Body Marking"
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_SKIN), 				-- "Skin"
		L("SI_COLLECTIBLECATEGORYTYPE", COLLECTIBLE_CATEGORY_TYPE_POLYMORPH), 			-- "Polymorph"
	}
	self.categoryChoicesValues[ACTION_TYPE_COLLECTIBLE_APPEARANCE] = {
		CATEGORY_NOTHING, 
		CATEGORY_IMMEDIATE_VALUE, 
		CATEGORY_C_HAT, 
		CATEGORY_C_HAIR, 
		CATEGORY_C_HEAD_MARKING, 
		CATEGORY_C_FACIAL_HAIR_HORNS, 
		CATEGORY_C_FACIAL_ACCESSORY, 
		CATEGORY_C_PIERCING_JEWELRY, 
		CATEGORY_C_COSTUME, 
		CATEGORY_C_BODY_MARKING, 
		CATEGORY_C_SKIN, 
		CATEGORY_C_POLYMORPH, 
	}
	self.categoryChoices[ACTION_TYPE_EMOTE] = {
		L(SI_CSPM_COMMON_UNSELECTED), 
		L(SI_CSPM_COMMON_IMMEDIATE_VALUE), 
		L("SI_EMOTECATEGORY", EMOTE_CATEGORY_CEREMONIAL), 			-- "Ceremonial"
		L("SI_EMOTECATEGORY", EMOTE_CATEGORY_CHEERS_AND_JEERS), 	-- "Cheers and Jeers"
		L("SI_EMOTECATEGORY", EMOTE_CATEGORY_EMOTION), 				-- "Emotion"
		L("SI_EMOTECATEGORY", EMOTE_CATEGORY_ENTERTAINMENT), 		-- "Entertainment"
		L("SI_EMOTECATEGORY", EMOTE_CATEGORY_FOOD_AND_DRINK), 		-- "Food and Drink"
		L("SI_EMOTECATEGORY", EMOTE_CATEGORY_GIVE_DIRECTIONS), 		-- "Give Directions"
		L("SI_EMOTECATEGORY", EMOTE_CATEGORY_PHYSICAL), 			-- "Physical"
		L("SI_EMOTECATEGORY", EMOTE_CATEGORY_POSES_AND_FIDGETS), 	-- "Poses and Fidgets"
		L("SI_EMOTECATEGORY", EMOTE_CATEGORY_PROP), 				-- "Prop"
		L("SI_EMOTECATEGORY", EMOTE_CATEGORY_SOCIAL), 				-- "Social"
		L("SI_EMOTECATEGORY", EMOTE_CATEGORY_COLLECTED), 			-- "Collected"
	}
	self.categoryChoicesValues[ACTION_TYPE_EMOTE] = {
		CATEGORY_NOTHING, 
		CATEGORY_IMMEDIATE_VALUE, 
		CATEGORY_E_CEREMONIAL, 
		CATEGORY_E_CHEERS_AND_JEERS, 
		CATEGORY_E_EMOTION, 
		CATEGORY_E_ENTERTAINMENT, 
		CATEGORY_E_FOOD_AND_DRINK, 
		CATEGORY_E_GIVE_DIRECTIONS, 
		CATEGORY_E_PHYSICAL, 
		CATEGORY_E_POSES_AND_FIDGETS, 
		CATEGORY_E_PROP, 
		CATEGORY_E_SOCIAL, 
		CATEGORY_E_COLLECTED, 
	}
	self.categoryChoices[ACTION_TYPE_CHAT_COMMAND] = {
		L(SI_CSPM_COMMON_UNSELECTED), 
		L(SI_CSPM_COMMON_IMMEDIATE_VALUE), 
	}
	self.categoryChoicesValues[ACTION_TYPE_CHAT_COMMAND] = {
		CATEGORY_NOTHING, 
		CATEGORY_IMMEDIATE_VALUE, 
	}
	self.categoryChoices[ACTION_TYPE_TRAVEL_TO_HOUSE] = {
		L(SI_CSPM_COMMON_UNSELECTED), 
		L(SI_CSPM_COMMON_MY_HOUSE_INSIDE), 
		L(SI_CSPM_COMMON_MY_HOUSE_OUTSIDE), 
	}
	self.categoryChoicesValues[ACTION_TYPE_TRAVEL_TO_HOUSE] = {
		CATEGORY_NOTHING, 
		CATEGORY_H_UNLOCKED_HOUSE_INSIDE, 
		CATEGORY_H_UNLOCKED_HOUSE_OUTSIDE, 
	}
	self.categoryChoices[ACTION_TYPE_PIE_MENU] = {
		L(SI_CSPM_COMMON_UNSELECTED), 
		zo_strformat(L("SI_CSPM_COMMON_UI_ACTION", UI_OPEN), L(SI_CSPM_COMMON_USER_PIE_MENU)), 
		zo_strformat(L("SI_CSPM_COMMON_UI_ACTION", UI_OPEN), L(SI_CSPM_COMMON_EXTERNAL_PIE_MENU)), 
	}
	self.categoryChoicesValues[ACTION_TYPE_PIE_MENU] = {
		CATEGORY_NOTHING, 
		CATEGORY_P_OPEN_USER_PIE_MENU, 
		CATEGORY_P_OPEN_EXTERNAL_PIE_MENU, 
	}
	self.categoryChoices[ACTION_TYPE_SHORTCUT] = {
		L(SI_CSPM_COMMON_UNSELECTED), 
		CSPM.name, 
		L(SI_CSPM_COMMON_MAIN_MENU), 
		L(SI_CSPM_COMMON_SYSTEM_MENU), 
		L(SI_CSPM_UI_CATEGORY_S_USEFUL_SHORTCUT_NAME), 
	}
	self.categoryChoicesValues[ACTION_TYPE_SHORTCUT] = {
		CATEGORY_NOTHING, 
		CATEGORY_S_PIE_MENU_ADDON, 
		CATEGORY_S_MAIN_MENU, 
		CATEGORY_S_SYSTEM_MENU, 
		CATEGORY_S_USEFUL_SHORTCUT, 
	}
	self:RebuildExternalShortcutCategorySelectionChoices()	-- categoryChoices[ACTION_TYPE_SHORTCUT_ADDON]

	self.actionValueChoices[CATEGORY_NOTHING], self.actionValueChoicesValues[CATEGORY_NOTHING] = {}, {}
	self.actionValueChoices[CATEGORY_IMMEDIATE_VALUE], self.actionValueChoicesValues[CATEGORY_IMMEDIATE_VALUE] = {}, {}
	self:InitializeCollectibleSelectionChoices()	-- actionValueChoices[CATEGORY_C_xxx]
	self:InitializeEmoteSelectionChoices()	-- actionValueChoices[CATEGORY_E_xxx]
	self:RebuildHouseSelectionChoices(true, true)	-- actionValueChoices[CATEGORY_H_UNLOCKED_HOUSE_INSIDE], actionValueChoices[CATEGORY_H_UNLOCKED_HOUSE_OUTSIDE]
--	(self:RebuildUserPieMenuPresetSelectionChoices())	-- actionValueChoices[CATEGORY_P_OPEN_USER_PIE_MENU]
	self:RebuildExternalPieMenuPresetSelectionChoices()	-- actionValueChoices[CATEGORY_P_OPEN_EXTERNAL_PIE_MENU]
	self:RebuildShortcutSelectionChoicesByCategoryId(CATEGORY_S_PIE_MENU_ADDON)	-- actionValueChoices[CATEGORY_S_PIE_MENU_ADDON]
	self:RebuildShortcutSelectionChoicesByCategoryId(CATEGORY_S_MAIN_MENU)	-- actionValueChoices[CATEGORY_S_MAIN_MENU]
	self:RebuildShortcutSelectionChoicesByCategoryId(CATEGORY_S_SYSTEM_MENU)	-- actionValueChoices[CATEGORY_S_SYSTEM_MENU]
	self:RebuildShortcutSelectionChoicesByCategoryId(CATEGORY_S_USEFUL_SHORTCUT)	-- actionValueChoices[CATEGORY_S_USEFUL_SHORTCUT]
	self.externalShortcutIsDirty = {}
	for _, categoryId in pairs(self.shortcutDataManager:GetShortcutCategoryList()) do
		self:RebuildShortcutSelectionChoicesByCategoryId(categoryId)
	end

	CSPM:RegisterCallback("CSPM-UserPieMenuInfoUpdated", function(presetId)
		self:OnUserPieMenuInfoUpdated(presetId)
	end)
	ZO_COLLECTIBLE_DATA_MANAGER:RegisterCallback("OnCollectionUpdated", function(collectionUpdateType, collectiblesByNewUnlockState)
		self:OnCollectionUpdated(collectionUpdateType, collectiblesByNewUnlockState)
	end)
	CSPM:RegisterCallback("LCPM-ShortcutRegistered", function(shortcutId, categoryId)
		if categoryId == CATEGORY_NOTHING then return end
		if self.externalShortcutIsDirty[categoryId] == nil then
			self.externalShortcutCategoryIsDirty = true
		end
		self.externalShortcutIsDirty[categoryId] = true
	end)

	CSPM:RegisterCallback("LCPM-PieMenuRegistered", function(presetId)
		self.externalPieMenuIsDirty = true
	end)
end

function CSPM_PieMenuEditorPanel:GetDefaultPresetData()
	return self.DB_DEFAULT.preset[1]
end

function CSPM_PieMenuEditorPanel:GetDefaultSlotData()
	return self.DB_DEFAULT.preset[1].slot[1]
end

function CSPM_PieMenuEditorPanel:ResetCurrentPresetDataToDefault()
end

function CSPM_PieMenuEditorPanel:GetPresetDisplayNameByPresetId(presetId)
	local name
	local pieMenuName = GetPieMenuInfo(presetId)
	if IsUserPieMenu(presetId) then
		if DoesPieMenuDataExist(presetId) then
			if pieMenuName ~= "" then
				name = zo_strformat(L(SI_CSPM_PRESET_NAME_FORMATTER), presetId, pieMenuName)
			else
				name = zo_strformat(L(SI_CSPM_PRESET_NO_NAME_FORMATTER), presetId)
			end
		else
			name = zo_strformat(L(SI_CSPM_PRESET_NAME_FORMATTER), presetId, L(SI_CSPM_COMMON_UNREGISTERED))
		end
	else
		name = pieMenuName
	end
	return name
end

function CSPM_PieMenuEditorPanel:GetSlotDisplayNameBySlotId(slotId)
	local slotName = ""
	local savedSlotData = self.db.preset[self.currentPresetId].slot[slotId]
	if savedSlotData then
		if type(savedSlotData.name) == "string" and savedSlotData.name ~= "" then
			slotName = savedSlotData.name
		else
			slotName = GetDefaultSlotName(savedSlotData.type, savedSlotData.category, savedSlotData.value)
		end
	end
	if slotName == "" then
		slotName = L(SI_CSPM_COMMON_UNREGISTERED)
	end
	return slotName
end

function CSPM_PieMenuEditorPanel:OnCollectionUpdated(collectionUpdateType, collectiblesByNewUnlockState)
	if collectionUpdateType ~= ZO_COLLECTION_UPDATE_TYPE.UNLOCK_STATE_CHANGED then return end
	if collectiblesByNewUnlockState[COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED] then
		CSPM.LDL:Debug("COLLECTIBLE_DATA_MANAGER-OnCollectionUpdated (UnlockStateChanged)")
		local isDirty = {}
		for index, collectibleData in pairs(collectiblesByNewUnlockState[COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED]) do
--			CSPM.LDL:Debug("[%s] : id=%s", tostring(index), tostring(collectibleData:GetId()))
			isDirty[collectibleData:GetCategoryType()] = true
		end
		-- update collectible choices if needed
		for categoryId, categoryType in pairs(CategoryId_To_CollectibleCategoryType) do
			if isDirty[categoryType] then
				self:RebuildCollectibleSelectionChoicesByCategoryId(categoryId, true)
			end
		end
		for _, categoryType in pairs(CategoryId_To_CollectibleCategoryType) do
			isDirty[categoryType] = false
		end
		-- update emote choices if needed
		if isDirty[COLLECTIBLE_CATEGORY_TYPE_EMOTE] then
			self:RebuildEmoteSelectionChoicesByCategoryId(CATEGORY_E_COLLECTED)
			isDirty[COLLECTIBLE_CATEGORY_TYPE_EMOTE] = false
		end
		-- update player house choices if needed
		if isDirty[COLLECTIBLE_CATEGORY_TYPE_HOUSE] then
			self:RebuildHouseSelectionChoices(true, true)	-- actionValueChoices[CATEGORY_H_UNLOCKED_HOUSE_INSIDE], actionValueChoices[CATEGORY_H_UNLOCKED_HOUSE_OUTSIDE]
			isDirty[COLLECTIBLE_CATEGORY_TYPE_HOUSE] = false
		end
		-- update MenuEditorUI panel
		if self:IsPanelInitialized() then
			self:ChangePanelSlotState(self.currentSlotId)
		end
	end
end

function CSPM_PieMenuEditorPanel:OnUserPieMenuInfoUpdated(presetId)
-- This function assumes that the preset attribute information in the user pie menu has just changed.
	if not IsUserPieMenu(presetId) then return end
	CSPM.LDL:Debug("OnUserPieMenuInfoUpdated : ", presetId)

	-- NOTE : the user preset selection choices and the preset name submenu header for the user pie menu will also be updated here.
	self.presetChoices[presetId] = self:GetPresetDisplayNameByPresetId(presetId)
	self.actionValueChoices[CATEGORY_P_OPEN_USER_PIE_MENU][presetId] = self.presetChoices[presetId]
	if self:IsPanelInitialized() then
		CSPM_UI_PresetSelectMenu:UpdateChoices(self.presetChoices, self.presetChoicesValues)
		CSPM_UI_PresetSelectMenu:UpdateValue()		-- Note : When called with no arguments, getFunc will be called, and setFunc will NOT be called.

		CSPM_UI_PresetSubmenu.data.name = self.presetChoices[self.currentPresetId]
		CSPM_UI_PresetSubmenu:UpdateValue()		-- Note : When called with no arguments, getFunc will be called, and setFunc will NOT be called.

		if self.db.preset[self.currentPresetId].slot[self.currentSlotId].type == ACTION_TYPE_PIE_MENU then
			local categoryId = self.db.preset[self.currentPresetId].slot[self.currentSlotId].category
			if categoryId == CATEGORY_P_OPEN_USER_PIE_MENU then
				CSPM_UI_ActionValueMenu:UpdateChoices(self.actionValueChoices[CATEGORY_P_OPEN_USER_PIE_MENU], self.actionValueChoicesValues[CATEGORY_P_OPEN_USER_PIE_MENU])
				CSPM_UI_ActionValueMenu:UpdateValue()		-- Note : When called with no arguments, getFunc will be called, and setFunc will NOT be called.
			end
		end
	end
end

function CSPM_PieMenuEditorPanel:GetUserPieMenuPresetSelectionChoices()
	local choices = {}
	local choicesValues = {}
	for i = 1, MAX_USER_PRESET do
		choices[i] = self:GetPresetDisplayNameByPresetId(i)
		choicesValues[i] = i
	end
	return choices, choicesValues
end
function CSPM_PieMenuEditorPanel:RebuildUserPieMenuPresetSelectionChoices()
	local choices, choicesValues = self:GetUserPieMenuPresetSelectionChoices()
	ClearTable(self.presetChoices)
	ClearTable(self.presetChoicesValues)
	ClearTable(self.actionValueChoices[CATEGORY_P_OPEN_USER_PIE_MENU])
	ClearTable(self.actionValueChoicesValues[CATEGORY_P_OPEN_USER_PIE_MENU])
	self.presetChoices, self.presetChoicesValues = choices, choicesValues
	self.actionValueChoices[CATEGORY_P_OPEN_USER_PIE_MENU], self.actionValueChoicesValues[CATEGORY_P_OPEN_USER_PIE_MENU] = choices, choicesValues
end

function CSPM_PieMenuEditorPanel:GetExternalPieMenuPresetSelectionChoices()
	local choices = {}
	local choicesValues = {}
	local externalPieMenuPresetIdList = self.pieMenuDataManager:GetExternalPieMenuPresetIdList()
	for _, presetId in pairs(externalPieMenuPresetIdList) do
		table.insert(choices, self:GetPresetDisplayNameByPresetId(presetId))
		table.insert(choicesValues, presetId)
	end
	return choices, choicesValues
end
function CSPM_PieMenuEditorPanel:RebuildExternalPieMenuPresetSelectionChoices()
	ClearTable(self.actionValueChoices[CATEGORY_P_OPEN_EXTERNAL_PIE_MENU])
	ClearTable(self.actionValueChoicesValues[CATEGORY_P_OPEN_EXTERNAL_PIE_MENU])
	self.actionValueChoices[CATEGORY_P_OPEN_EXTERNAL_PIE_MENU], self.actionValueChoicesValues[CATEGORY_P_OPEN_EXTERNAL_PIE_MENU] = self:GetExternalPieMenuPresetSelectionChoices()
	self.externalPieMenuIsDirty = false
end

function CSPM_PieMenuEditorPanel:RebuildSlotDisplayNameCache(presetId)
	if not self.db.preset[presetId] then return end
	ClearTable(self.slotDisplayNameCache)
	local displayNameCache = {}
	for i = 1, self.db.preset[presetId].menuItemsCount do
		self.slotDisplayNameCache[i] = self:GetSlotDisplayNameBySlotId(i)
	end
end

function CSPM_PieMenuEditorPanel:GetSlotSelectionChoices(menuItemsCount)
	local choices = {}
	local choicesValues = {}
	for i = 1, menuItemsCount do
		choices[i] = zo_strformat(L(SI_CSPM_SLOT_NAME_FORMATTER), i, self.slotDisplayNameCache[i] or L(SI_CSPM_COMMON_UNREGISTERED))
		choicesValues[i] = i
	end
	return choices, choicesValues
end
function CSPM_PieMenuEditorPanel:RebuildSlotSelectionChoices(menuItemsCount)
	ClearTable(self.slotChoices)
	ClearTable(self.slotChoicesValues)
	self.slotChoices, self.slotChoicesValues = self:GetSlotSelectionChoices(menuItemsCount)
end

function CSPM_PieMenuEditorPanel:GetExternalShortcutCategorySelectionChoices()
	local choices = {
		L(SI_CSPM_COMMON_UNSELECTED), 
	}
	local choicesValues = {
		CATEGORY_NOTHING, 
	}
	for _, categoryId in pairs(self.shortcutDataManager:GetShortcutCategoryList()) do
		table.insert(choices, categoryId)
		table.insert(choicesValues, categoryId)
	end
	return choices, choicesValues
end
function CSPM_PieMenuEditorPanel:RebuildExternalShortcutCategorySelectionChoices()
	ClearTable(self.categoryChoices[ACTION_TYPE_SHORTCUT_ADDON])
	ClearTable(self.categoryChoicesValues[ACTION_TYPE_SHORTCUT_ADDON])
	self.categoryChoices[ACTION_TYPE_SHORTCUT_ADDON], self.categoryChoicesValues[ACTION_TYPE_SHORTCUT_ADDON] = self:GetExternalShortcutCategorySelectionChoices()
	self.externalShortcutCategoryIsDirty = false
end

function CSPM_PieMenuEditorPanel:GetCollectibleSelectionChoicesByCollectibleCategoryId(collectibleCategoryId, unlockedOnly)
--	collectibleCategoryId : ZOS CollectibleCategoryId
--	unlockedOnly : return only the unlocked ones or the whole set
	local choices = {}
	local choicesValues = {}
	unlockedOnly = unlockedOnly or false
	if collectibleCategoryId then
		local categoryIndex, subcategoryIndex = GetCategoryInfoFromCollectibleCategoryId(collectibleCategoryId)
		local categoryData = ZO_COLLECTIBLE_DATA_MANAGER:GetCategoryDataByIndicies(categoryIndex, subcategoryIndex)
		if categoryData then
			for index = 1, categoryData:GetNumCollectibles() do
				local collectibleId = categoryData:GetCollectibleDataByIndex(index):GetId()
				if not unlockedOnly or IsCollectibleUnlocked(collectibleId) then
					table.insert(choices, zo_strformat(L(SI_CSPM_COMMON_FORMATTER), GetCollectibleName(collectibleId)))
					table.insert(choicesValues, collectibleId)
				end
			end
		end
	end
	return choices, choicesValues
end
function CSPM_PieMenuEditorPanel:GetCollectibleSelectionChoicesByCategoryType(categoryType, unlockedOnly)
--	categoryType : ZOS CollectibleCategoryType
--	unlockedOnly : return only the unlocked ones or the whole set
	local choices = {}
	local choicesValues = {}
	unlockedOnly = unlockedOnly or false
	if categoryType then
		for index = 1, GetTotalCollectiblesByCategoryType(categoryType) do
			local collectibleId = GetCollectibleIdFromType(categoryType, index)
			if not unlockedOnly or IsCollectibleUnlocked(collectibleId) then
				table.insert(choices, zo_strformat(L(SI_CSPM_COMMON_FORMATTER), GetCollectibleName(collectibleId)))
				table.insert(choicesValues, collectibleId)
			end
		end
	end
	return choices, choicesValues
end
function CSPM_PieMenuEditorPanel:GetCollectibleSelectionChoicesByCategoryId(categoryId, unlockedOnly)
--	categoryId : CSPM category id
	if categoryId == CATEGORY_C_TOOL then
		return self:GetCollectibleSelectionChoicesByCollectibleCategoryId(CategoryId_To_CollectibleCategoryId[categoryId], unlockedOnly)
	else
		return self:GetCollectibleSelectionChoicesByCategoryType(CategoryId_To_CollectibleCategoryType[categoryId], unlockedOnly)
	end
end
function CSPM_PieMenuEditorPanel:RebuildCollectibleSelectionChoicesByCategoryId(categoryId, unlockedOnly)
	ClearTable(self.actionValueChoices[categoryId])
	ClearTable(self.actionValueChoicesValues[categoryId])
	self.actionValueChoices[categoryId], self.actionValueChoicesValues[categoryId] = self:GetCollectibleSelectionChoicesByCategoryId(categoryId, unlockedOnly)
end
function CSPM_PieMenuEditorPanel:InitializeCollectibleSelectionChoices()
	for categoryId, _ in pairs(CategoryId_To_CollectibleCategoryType) do
		self:RebuildCollectibleSelectionChoicesByCategoryId(categoryId, true)
	end
end

function CSPM_PieMenuEditorPanel:GetEmoteSelectionChoicesByEmoteCategory(emoteCategory)
	local choices = {}
	local choicesValues = PLAYER_EMOTE_MANAGER:GetEmoteListForType(emoteCategory) or {}
	for k, emoteId in pairs(choicesValues) do
		table.insert(choices, zo_strformat(L(SI_CSPM_COMMON_FORMATTER), PLAYER_EMOTE_MANAGER:GetEmoteItemInfo(emoteId).displayName))
	end
	return choices, choicesValues
end
function CSPM_PieMenuEditorPanel:GetEmoteSelectionChoicesByCategoryId(categoryId)
--	categoryId : CSPM category id
	return self:GetEmoteSelectionChoicesByEmoteCategory(CategoryId_To_EmoteCategory[categoryId])
end
function CSPM_PieMenuEditorPanel:RebuildEmoteSelectionChoicesByCategoryId(categoryId)
	ClearTable(self.actionValueChoices[categoryId])
	ClearTable(self.actionValueChoicesValues[categoryId])
	self.actionValueChoices[categoryId], self.actionValueChoicesValues[categoryId] = self:GetEmoteSelectionChoicesByCategoryId(categoryId) 
end
function CSPM_PieMenuEditorPanel:InitializeEmoteSelectionChoices()
	for categoryId, _ in pairs(CategoryId_To_EmoteCategory) do
		self:RebuildEmoteSelectionChoicesByCategoryId(categoryId) 
	end
end

function CSPM_PieMenuEditorPanel:GetHouseSelectionChoices(unlockedOnly, includePrimaryHouse)
--	unlockedOnly : return only the unlocked ones or the whole set
--	includePrimaryHouse : whether to include the primary house
	local choices = {}
	local choicesValues = {}
	unlockedOnly = unlockedOnly or false	-- nil should be false
	includePrimaryHouse = includePrimaryHouse ~= false	-- nil should be true

	if includePrimaryHouse then
		table.insert(choices, zo_strformat(L(SI_CSPM_PARENTHESES_FORMATTER), L(SI_HOUSING_FURNITURE_SETTINGS_GENERAL_PRIMARY_RESIDENCE_TEXT)))	-- Primary Residence
		table.insert(choicesValues, ACTION_VALUE_PRIMARY_HOUSE_ID)
	end
	for index = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_HOUSE) do
		local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_HOUSE, index)
		if not unlockedOnly or IsCollectibleUnlocked(collectibleId) then
			table.insert(choices, zo_strformat(L(SI_CSPM_COMMON_FORMATTER), GetCollectibleName(collectibleId)))
			table.insert(choicesValues, GetCollectibleReferenceId(collectibleId))
		end
	end
	return choices, choicesValues
end
function CSPM_PieMenuEditorPanel:RebuildHouseSelectionChoicesByCategoryId(categoryId, unlockedOnly, includePrimaryHouse)
	ClearTable(self.actionValueChoices[categoryId])
	ClearTable(self.actionValueChoicesValues[categoryId])
	self.actionValueChoices[categoryId], self.actionValueChoicesValues[categoryId] = self:GetHouseSelectionChoices(unlockedOnly, includePrimaryHouse)
end
function CSPM_PieMenuEditorPanel:RebuildHouseSelectionChoices(unlockedOnly, includePrimaryHouse)
	local choices, choicesValues = self:GetHouseSelectionChoices(unlockedOnly, includePrimaryHouse)
	ClearTable(self.actionValueChoices[CATEGORY_H_UNLOCKED_HOUSE_INSIDE])
	ClearTable(self.actionValueChoicesValues[CATEGORY_H_UNLOCKED_HOUSE_INSIDE])
	ClearTable(self.actionValueChoices[CATEGORY_H_UNLOCKED_HOUSE_OUTSIDE])
	ClearTable(self.actionValueChoicesValues[CATEGORY_H_UNLOCKED_HOUSE_OUTSIDE])
	self.actionValueChoices[CATEGORY_H_UNLOCKED_HOUSE_INSIDE], self.actionValueChoicesValues[CATEGORY_H_UNLOCKED_HOUSE_INSIDE] = choices, choicesValues
	self.actionValueChoices[CATEGORY_H_UNLOCKED_HOUSE_OUTSIDE], self.actionValueChoicesValues[CATEGORY_H_UNLOCKED_HOUSE_OUTSIDE] = choices, choicesValues
end

function CSPM_PieMenuEditorPanel:GetShortcutSelectionChoicesByCategoryId(categoryId)
	local choices = {}
	local choicesValues = self.shortcutDataManager:GetShortcutListByCategory(categoryId) or {}
	for k, v in ipairs(choicesValues) do
		local name = GetShortcutInfo(v)
		choices[k] = name or ""
	end
	return choices, choicesValues
end
function CSPM_PieMenuEditorPanel:RebuildShortcutSelectionChoicesByCategoryId(categoryId)
	ClearTable(self.actionValueChoices[categoryId])
	ClearTable(self.actionValueChoicesValues[categoryId])
	self.actionValueChoices[categoryId], self.actionValueChoicesValues[categoryId] = self:GetShortcutSelectionChoicesByCategoryId(categoryId)
	if self.shortcutDataManager:IsExternalShortcutCategory(categoryId) then
		self.externalShortcutIsDirty[categoryId] = false
	end
end


function CSPM_PieMenuEditorPanel:ChangePanelSlotState(slotId)
--	CSPM.LDL:Debug("ChangePanelSlotState : %s", slotId)
	-- Here, we need to call the setFunc callback of CSPM_UI_SlotSelectMenu.
	CSPM_UI_SlotSelectMenu:UpdateValue(false, slotId)	-- Note : When called with arguments, setFunc will be called.
end

function CSPM_PieMenuEditorPanel:ChangePanelPresetState(presetId)
--	CSPM.LDL:Debug("ChangePanelPresetState : %s", presetId)
	-- Here, we need to call the setFunc callback of CSPM_UI_PresetSelectMenu.
	CSPM_UI_PresetSelectMenu:UpdateValue(false, presetId)	-- Note : When called with arguments, setFunc will be called.
end

function CSPM_PieMenuEditorPanel:DoTestButton()
end

function CSPM_PieMenuEditorPanel:OnSlotDisplayNameChanged()
-- This function assumes that the slot display name of the currently open preset and slot has just changed.
	CSPM.LDL:Debug("OnSlotDisplayNameChanged : ")
	
	-- NOTE : Since the slot display name has been changed, the slot selection choices and the slot name tab header will also be updated here.
	self.slotChoices[self.currentSlotId] = zo_strformat(L(SI_CSPM_SLOT_NAME_FORMATTER), self.currentSlotId, self.slotDisplayNameCache[self.currentSlotId] or L(SI_CSPM_COMMON_UNREGISTERED))
	CSPM_UI_SlotSelectMenu:UpdateChoices(self.slotChoices, self.slotChoicesValues)
	CSPM_UI_SlotSelectMenu:UpdateValue()		-- Note : When called with no arguments, getFunc will be called, and setFunc will NOT be called.

	CSPM_UI_TabHeader.data.name = self.slotChoices[self.currentSlotId]
	CSPM_UI_TabHeader:UpdateValue()
end

function CSPM_PieMenuEditorPanel:UpdateSlotDisplayNameCacheForSpecificSlot(slotId)
	self.slotDisplayNameCache[slotId] = self:GetSlotDisplayNameBySlotId(slotId)
	if slotId == self.currentSlotId then
		self:OnSlotDisplayNameChanged()
	end
end

function CSPM_PieMenuEditorPanel:OnLAMPanelOpened(panel)
--	CSPM.LDL:Debug("OnLAMPanelOpened: PieMenu Editor")

	-- update external shortcut category selection choices if needed.
	if self.externalShortcutCategoryIsDirty then
		CSPM.LDL:Debug("uiExternalShortcutCategoryChoices Updated:")
		self:RebuildExternalShortcutCategorySelectionChoices()	-- categoryChoices[ACTION_TYPE_SHORTCUT_ADDON]
		if self.db.preset[self.currentPresetId].slot[self.currentSlotId].type == ACTION_TYPE_SHORTCUT_ADDON then
			CSPM_UI_CategoryMenu:UpdateChoices(self.categoryChoices[ACTION_TYPE_SHORTCUT_ADDON], self.categoryChoicesValues[ACTION_TYPE_SHORTCUT_ADDON])
			CSPM_UI_CategoryMenu:UpdateValue()
		end
	end
	-- update external shortcut selection choices if needed.
	-- NOTE : If an external shortcut is added by an external add-on after the previous construction of the choice, the corresponding shortcut choice should be rebuilt.
	for categoryId, isDirty in pairs(self.externalShortcutIsDirty) do
		if isDirty then
			CSPM.LDL:Debug("uiExternalShortcutChoices Updated: ", tostring(categoryId))
			self:RebuildShortcutSelectionChoicesByCategoryId(categoryId)
			if self.db.preset[self.currentPresetId].slot[self.currentSlotId].category == categoryId then
				CSPM_UI_ActionValueMenu:UpdateChoices(self.actionValueChoices[categoryId], self.actionValueChoicesValues[categoryId])
				CSPM_UI_ActionValueMenu:UpdateValue()		-- Note : When called with no arguments, getFunc will be called, and setFunc will NOT be called.
			end
		end
	end
	-- update external pie menu selection choices if needed.
	-- NOTE : If an external pie menu is added by an external add-on after the previous construction of the choice, the external pie menu choice should be rebuilt.
	if self.externalPieMenuIsDirty then
		CSPM.LDL:Debug("uiExternalPieMenuChoices Updated:")
		self:RebuildExternalPieMenuPresetSelectionChoices()	-- actionValueChoices[CATEGORY_P_OPEN_EXTERNAL_PIE_MENU]
		if self.db.preset[self.currentPresetId].slot[self.currentSlotId].type == ACTION_TYPE_PIE_MENU then
			if self.db.preset[self.currentPresetId].slot[self.currentSlotId].category == CATEGORY_P_OPEN_EXTERNAL_PIE_MENU then
				CSPM_UI_ActionValueMenu:UpdateChoices(self.actionValueChoices[CATEGORY_P_OPEN_EXTERNAL_PIE_MENU], self.actionValueChoicesValues[CATEGORY_P_OPEN_EXTERNAL_PIE_MENU])
				CSPM_UI_ActionValueMenu:UpdateValue()		-- Note : When called with no arguments, getFunc will be called, and setFunc will NOT be called.
			end
		end
	end
end

function CSPM_PieMenuEditorPanel:OnLAMPanelClosed(panel)
--	CSPM.LDL:Debug("OnLAMPanelClosed: PieMenu Editor")
end

function CSPM_PieMenuEditorPanel:CreateSettingPanel()
	local panelData = {
		type = "panel", 
		name = "Shortcut PieMenu", 
		displayName = "Calamath's Shortcut Pie Menu (Editor)", 
		author = CSPM.author, 
		version = CSPM.version, 
		website = "https://www.esoui.com/downloads/info3088-CalamathsShortcutPieMenu.html", 
		feedback = "https://www.esoui.com/downloads/info3088-CalamathsShortcutPieMenu.html#comments", 
		donation = "https://www.esoui.com/downloads/info3088-CalamathsShortcutPieMenu.html#donate", 
		slashCommand = "/cspm.settings", 
		registerForRefresh = true, 
--		registerForDefaults = true, 
--		resetFunc = function() self:ResetCurrentPresetDataToDefault() end, 
	}
	LAM:RegisterAddonPanel(self.panelId, panelData)

	local submenuPieVisual = {}
	submenuPieVisual[#submenuPieVisual + 1] = {
		type = "editbox", 
		name = L(SI_CSPM_UI_VISUAL_PRESET_NAME_OVERRIDE_NAME), 
		tooltip = L(SI_CSPM_UI_VISUAL_PRESET_NAME_OVERRIDE_TIPS), 
		getFunc = function() return self.db.preset[self.currentPresetId].name end, 
		setFunc = function(newPresetName)
			self.db.preset[self.currentPresetId].name = newPresetName
			CSPM:FireCallbacks("CSPM-UserPieMenuInfoUpdated", self.currentPresetId)
		end, 
		isMultiline = false, 
		isExtraWide = false, 
		maxChars = 1999, 
		width = "full", 
--		disabled = true, 
		default = self.DB_DEFAULT.preset[1].name, 
	}
	submenuPieVisual[#submenuPieVisual + 1] = {
		type = "editbox", 
		name = L(SI_CSPM_UI_VISUAL_PRESET_NOTE_NAME), 
		tooltip = L(SI_CSPM_UI_VISUAL_PRESET_NOTE_TIPS), 
		getFunc = function() return self.db.preset[self.currentPresetId].tooltip or "" end, 
		setFunc = function(newPresetNote)
			self.db.preset[self.currentPresetId].tooltip = newPresetNote
			CSPM:FireCallbacks("CSPM-UserPieMenuInfoUpdated", self.currentPresetId)
		end, 
		isMultiline = false, 
		isExtraWide = false, 
		maxChars = 1999, 
		width = "full", 
--		disabled = true, 
		default = self.DB_DEFAULT.preset[1].tooltip or "", 
	}
	submenuPieVisual[#submenuPieVisual + 1] = {
		type = "header", 
		name = L(SI_CSPM_UI_VISUAL_HEADER1_TEXT), -- "Visual Design Options"
	}
	submenuPieVisual[#submenuPieVisual + 1] = {
		type = "checkbox",
		name = L(SI_CSPM_UI_VISUAL_QUICKSLOT_STYLE_OP_NAME), 
		getFunc = function() return self.db.preset[self.currentPresetId].visual.style == "quickslot" end, 
		setFunc = function(newValue)
			self.db.preset[self.currentPresetId].visual.style = newValue and "quickslot" or "gamepad"
		end, 
		tooltip = L(SI_CSPM_UI_VISUAL_QUICKSLOT_STYLE_OP_TIPS), 
		width = "full", 
		default = self.DB_DEFAULT.preset[1].visual.style == "quickslot", 
	}
	submenuPieVisual[#submenuPieVisual + 1] = {
		type = "checkbox",
		name = L(SI_CSPM_UI_VISUAL_GAMEPAD_STYLE_OP_NAME), 
		getFunc = function() return self.db.preset[self.currentPresetId].visual.style == "gamepad" end, 
		setFunc = function(newValue)
			self.db.preset[self.currentPresetId].visual.style = newValue and "gamepad" or "quickslot"
		end, 
		tooltip = L(SI_CSPM_UI_VISUAL_GAMEPAD_STYLE_OP_TIPS), 
		width = "full", 
		default = self.DB_DEFAULT.preset[1].visual.style == "gamepad", 
	}
	submenuPieVisual[#submenuPieVisual + 1] = {
		type = "divider", 
		width = "full", 
		height = 10, 
		alpha = 0.5, 
	}
	submenuPieVisual[#submenuPieVisual + 1] = {
		type = "checkbox",
		name = L(SI_CSPM_UI_VISUAL_SHOW_PRESET_NAME_OP_NAME), 
		getFunc = function() return self.db.preset[self.currentPresetId].visual.showPresetName end, 
		setFunc = function(newValue) self.db.preset[self.currentPresetId].visual.showPresetName = newValue end, 
		tooltip = L(SI_CSPM_UI_VISUAL_SHOW_PRESET_NAME_OP_TIPS), 
		width = "full", 
		default = self.DB_DEFAULT.preset[1].visual.showPresetName, 
	}
	submenuPieVisual[#submenuPieVisual + 1] = {
		type = "checkbox",
		name = L(SI_CSPM_UI_VISUAL_SHOW_SLOT_NAME_OP_NAME), 
		getFunc = function() return self.db.preset[self.currentPresetId].visual.showSlotLabel end, 
		setFunc = function(newValue) self.db.preset[self.currentPresetId].visual.showSlotLabel = newValue end, 
		tooltip = L(SI_CSPM_UI_VISUAL_SHOW_SLOT_NAME_OP_TIPS), 
		width = "full", 
		default = self.DB_DEFAULT.preset[1].visual.showSlotLabel, 
	}
	submenuPieVisual[#submenuPieVisual + 1] = {
		type = "checkbox",
		name = L(SI_CSPM_UI_VISUAL_SHOW_ICON_FRAME_OP_NAME), 
		getFunc = function() return self.db.preset[self.currentPresetId].visual.showIconFrame end, 
		setFunc = function(newValue) self.db.preset[self.currentPresetId].visual.showIconFrame = newValue end, 
		tooltip = L(SI_CSPM_UI_VISUAL_SHOW_ICON_FRAME_OP_TIPS), 
		width = "full", 
		default = self.DB_DEFAULT.preset[1].visual.showIconFrame, 
	}

	local optionsData = {}
--[[
	optionsData[#optionsData + 1] = {
		type = "divider", 
		width = "full", 
		height = 10, 
		alpha = 0.5, 
	}
]]
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = "", 
		text = L(SI_CSPM_UI_PANEL_HEADER2_TEXT), 
	}
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = self.presetChoices[self.currentPresetId], 
		tooltip = L(SI_CSPM_UI_PRESET_VISUAL_SUBMENU_TIPS), 
		reference = "CSPM_UI_PresetSubmenu" ,
		controls = submenuPieVisual, 
	}
	optionsData[#optionsData + 1] = {
		type = "slider", 
		name = L(SI_CSPM_UI_MENU_ITEMS_COUNT_OP_NAME), 
		tooltip = L(SI_CSPM_UI_MENU_ITEMS_COUNT_OP_TIPS), 
		min = 2,
		max = 11,
		step = 1, 
		getFunc = function() return self.db.preset[self.currentPresetId].menuItemsCount end, 
		setFunc = function(newMenuItemsCount)
			CSPM.LDL:Debug("OnMenuItemCountChanged : %s", newMenuItemsCount)
			self.db.preset[self.currentPresetId].menuItemsCount = newMenuItemsCount
			if not self.db.preset[self.currentPresetId].slot[newMenuItemsCount] then
				CSPM.LDL:Debug("Error : slot data not found, so extend !")
				for i = 1, newMenuItemsCount do
					if not self.db.preset[self.currentPresetId].slot[i] then
						self.db.preset[self.currentPresetId].slot[i] = ZO_ShallowTableCopy(self:GetDefaultSlotData())
					end
				end
			end
			self:RebuildSlotSelectionChoices(newMenuItemsCount)
			CSPM_UI_SlotSelectMenu:UpdateChoices(self.slotChoices, self.slotChoicesValues)
			CSPM_UI_SlotSelectMenu:UpdateValue()		-- Note : When called with no arguments, getFunc will be called, and setFunc will NOT be called.

			if self.currentSlotId > newMenuItemsCount then
				self:ChangePanelSlotState(newMenuItemsCount)
			end
		end, 
		clampInput = false, 
		default = self.DB_DEFAULT.preset[1].menuItemsCount, 
		reference = "CSPM_UI_MenuItemsCountSlider", 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CSPM_UI_SLOT_SELECT_MENU_NAME), 
		tooltip = L(SI_CSPM_UI_SLOT_SELECT_MENU_TIPS), 
		choices = self.slotChoices, 	-- If choicesValue is defined, choices table is only used for UI display!
		choicesValues = self.slotChoicesValues, 
--		choicesTooltips = self.slotChoicesTooltips, 
		getFunc = function() return self.currentSlotId end, 
		setFunc = function(newSlotId)
			CSPM.LDL:Debug("OnSlotIdSelectionChanged : %s", newSlotId)
			if not self.db.preset[self.currentPresetId].slot[newSlotId] then
				CSPM.LDL:Debug("Error : slot data not found, so extend !")
				for i = 1, self.db.preset[self.currentPresetId].menuItemsCount do
					if not self.db.preset[self.currentPresetId].slot[i] then
						self.db.preset[self.currentPresetId].slot[i] = ZO_ShallowTableCopy(self:GetDefaultSlotData())
					end
				end
			end
			local savedSlotData = self.db.preset[self.currentPresetId].slot[newSlotId]
			if not savedSlotData then d("[CSPM] fatal error : slot data not found") return end

			-- update slot tab
			self.currentSlotId = newSlotId
			-- Since the only purpose here is to reflect the saved data to the panel(slot tab), we will make sure NOT to call setFunc for each widget.
			local uiActionTypeId = savedSlotData.type or ACTION_TYPE_NOTHING
			local uiCategoryId = savedSlotData.category or CATEGORY_NOTHING
--			local uiActionValue = savedSlotData.value or 0

			CSPM_UI_TabHeader.data.name = self.slotChoices[self.currentSlotId]
			CSPM_UI_TabHeader:UpdateValue()		-- Note : When called with no arguments, getFunc will be called, and setFunc will NOT be called.

			CSPM_UI_ActionTypeMenu:UpdateValue()
			CSPM_UI_CategoryMenu:UpdateChoices(self.categoryChoices[uiActionTypeId], self.categoryChoicesValues[uiActionTypeId])
			CSPM_UI_CategoryMenu:UpdateValue()
			CSPM_UI_ActionValueMenu:UpdateChoices(self.actionValueChoices[uiCategoryId], self.actionValueChoicesValues[uiCategoryId])
			CSPM_UI_ActionValueMenu:UpdateValue()
			CSPM_UI_ActionValueEditbox:UpdateValue()
			CSPM_UI_ActionValueEditbox:UpdateDisabled()
			CSPM_UI_SlotNameEditbox:UpdateValue()
			CSPM_UI_SlotIconEditbox:UpdateValue()
		end, 
		width = "half", 
--		scrollable = true, 
		default = 1, 
		reference = "CSPM_UI_SlotSelectMenu", 
	}
	optionsData[#optionsData + 1] = {
		type = "description", 
		title = " ", 
		text = " ", 
		width = "half", 
	}
	optionsData[#optionsData + 1] = {
		type = "header", 
		name = self.slotChoices[self.currentSlotId], 
		reference = "CSPM_UI_TabHeader", 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CSPM_UI_ACTION_TYPE_MENU_NAME), 
		tooltip = L(SI_CSPM_UI_ACTION_TYPE_MENU_TIPS), 
		choices = self.actionTypeChoices, 	-- If choicesValue is defined, choices table is only used for UI display!
		choicesValues = self.actionTypeChoicesValues, 
		choicesTooltips = self.actionTypeChoicesTooltips, 
		getFunc = function() return self.db.preset[self.currentPresetId].slot[self.currentSlotId].type end, 
		setFunc = function(newActionTypeId)
			CSPM.LDL:Debug("OnActionTypeSelectionChanged : %s", newActionTypeId)
			self.db.preset[self.currentPresetId].slot[self.currentSlotId].type = newActionTypeId

			CSPM_UI_CategoryMenu:UpdateChoices(self.categoryChoices[newActionTypeId], self.categoryChoicesValues[newActionTypeId])

			-- The meaning of ActionValue is different for each ActionType, and they are not mutually compatible.
			-- Therefore, when a user changes the ActionType selection, the category id and ActionValue should be initialized．
			CSPM_UI_CategoryMenu:UpdateValue(true)
			CSPM_UI_ActionValueMenu:UpdateValue(true)
			-- According to the design policy, the slot name override setting is also initialized.
			CSPM_UI_SlotNameEditbox:UpdateValue(true)
			-- According to the design policy, the slot icon override setting is only initialized when the action type is set to 'unselected'.
			if newActionTypeId == ACTION_TYPE_NOTHING then
				CSPM_UI_SlotIconEditbox:UpdateValue(true)
			end
		end, 
		width = "full", 
--		scrollable = true, 
		default = self.DB_DEFAULT.preset[1].slot[1].type, 
		reference = "CSPM_UI_ActionTypeMenu", 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CSPM_UI_CATEGORY_MENU_NAME), 
--		tooltip = L(SI_CSPM_UI_CATEGORY_MENU_TIPS), 
		choices = self.categoryChoices[self.db.preset[self.currentPresetId].slot[self.currentSlotId].type], 	-- If choicesValue is defined, choices table is only used for UI display!
		choicesValues = self.categoryChoicesValues[self.db.preset[self.currentPresetId].slot[self.currentSlotId].type], 
		getFunc = function() return self.db.preset[self.currentPresetId].slot[self.currentSlotId].category end, 
		setFunc = function(newCategoryId)
			CSPM.LDL:Debug("OnCategorySelectionChanged : %s", newCategoryId)
			self.db.preset[self.currentPresetId].slot[self.currentSlotId].category = newCategoryId
			CSPM_UI_ActionValueMenu:UpdateChoices(self.actionValueChoices[newCategoryId], self.actionValueChoicesValues[newCategoryId])

			-- To prevent a mismatch between the category id and the ActionValue,
			-- the ActionValue should be initialized when the user changes the category selection.
			CSPM_UI_ActionValueMenu:UpdateValue(true)
			-- According to the design policy, the slot name override setting is also initialized.
			CSPM_UI_SlotNameEditbox:UpdateValue(true)
			-- According to the design policy, the slot icon override setting will not be initialized when the category is changed.
			-- CSPM_UI_SlotIconEditbox:UpdateValue(true)
		end, 
		width = "full", 
--		scrollable = true, 
		default = self.DB_DEFAULT.preset[1].slot[1].category, 
		reference = "CSPM_UI_CategoryMenu", 
	}
	optionsData[#optionsData + 1] = {
		type = "dropdown", 
		name = L(SI_CSPM_UI_ACTION_VALUE_MENU_NAME), 
--		tooltip = L(SI_CSPM_UI_ACTION_VALUE_MENU_TIPS), 
		choices = self.actionValueChoices[self.db.preset[self.currentPresetId].slot[self.currentSlotId].category], 	-- If choicesValue is defined, choices table is only used for UI display!
		choicesValues = self.actionValueChoicesValues[self.db.preset[self.currentPresetId].slot[self.currentSlotId].category], 
		getFunc = function() return self.db.preset[self.currentPresetId].slot[self.currentSlotId].value end, 
		setFunc = function(newActionValue)
			CSPM.LDL:Debug("OnActionValueSelectionChanged : %s", newActionValue)
			self.db.preset[self.currentPresetId].slot[self.currentSlotId].value = newActionValue
			-- According to the design policy, the slot name override setting is initialized.
			CSPM_UI_SlotNameEditbox:UpdateValue(true)
			-- According to the design policy, the slot icon override setting will not be initialized when the action value is changed.
			-- CSPM_UI_SlotIconEditbox:UpdateValue(true)
		end, 
		sort = "name-up", 
		width = "full", 
		scrollable = 15, 
		default = self.DB_DEFAULT.preset[1].slot[1].value, 
		reference = "CSPM_UI_ActionValueMenu", 
	}
	optionsData[#optionsData + 1] = {
		type = "editbox", 
		name = "", 
		tooltip = L(SI_CSPM_UI_ACTION_VALUE_EDITBOX_TIPS), 
		getFunc = function() return self.db.preset[self.currentPresetId].slot[self.currentSlotId].value end, 
		setFunc = function(newActionValueString)
			CSPM.LDL:Debug("OnActionValueEditboxChanged : %s", newActionValueString)
			local uiActionTypeId = self.db.preset[self.currentPresetId].slot[self.currentSlotId].type
			-- NOTE : the meaning of ActionValue is different for each ActionType, and they are not mutually compatible.
			if uiActionTypeId == ACTION_TYPE_CHAT_COMMAND then 
				self.db.preset[self.currentPresetId].slot[self.currentSlotId].value = newActionValueString
			else
				self.db.preset[self.currentPresetId].slot[self.currentSlotId].value = tonumber(newActionValueString)
			end

			-- The slot display name will be changed and the UI panel will be updated here.
			-- When the ActionValue selection is changed, this edit box will be initialized, so the slot display name will be updated here as well.
			self:UpdateSlotDisplayNameCacheForSpecificSlot(self.currentSlotId)
		end, 
		isMultiline = false, 
		isExtraWide = false, 
		maxChars = 1999, 
		width = "full", 
		disabled = function()
			local uiCategoryId = self.db.preset[self.currentPresetId].slot[self.currentSlotId].category
			return uiCategoryId ~= CATEGORY_IMMEDIATE_VALUE
		end, 
		default = self.DB_DEFAULT.preset[1].slot[1].value, 
		reference = "CSPM_UI_ActionValueEditbox", 
	}
	optionsData[#optionsData + 1] = {
		type = "divider", 
		width = "full", 
		height = 10, 
		alpha = 0.25, 
	}
	optionsData[#optionsData + 1] = {
		type = "editbox", 
		name = L(SI_CSPM_UI_VISUAL_SLOT_NAME_OVERRIDE_NAME), 
		tooltip = L(SI_CSPM_UI_VISUAL_SLOT_NAME_OVERRIDE_TIPS), 
		getFunc = function() return self.db.preset[self.currentPresetId].slot[self.currentSlotId].name end, 
		setFunc = function(newSlotName)
			CSPM.LDL:Debug("OnSlotNameEditboxChanged : %s", newSlotName)
			if newSlotName == "" then
				self.db.preset[self.currentPresetId].slot[self.currentSlotId].name = nil
			else
				self.db.preset[self.currentPresetId].slot[self.currentSlotId].name = newSlotName
			end

			self:UpdateSlotDisplayNameCacheForSpecificSlot(self.currentSlotId)
		end, 
		isMultiline = false, 
		isExtraWide = false, 
		maxChars = 1999, 
		width = "full", 
--		disabled = true, 
		default = self.DB_DEFAULT.preset[1].slot[1].name or "", 
		reference = "CSPM_UI_SlotNameEditbox", 
	}
	optionsData[#optionsData + 1] = {
		type = "button", 
		name = L(SI_CSPM_UI_DEFAULT_SLOT_NAME_BUTTON_NAME), 
		tooltip = L(SI_CSPM_UI_DEFAULT_SLOT_NAME_BUTTON_TIPS), 
		func = function()
			local actionTypeId = self.db.preset[self.currentPresetId].slot[self.currentSlotId].type
			local categoryId = self.db.preset[self.currentPresetId].slot[self.currentSlotId].category
			local actionValue = self.db.preset[self.currentPresetId].slot[self.currentSlotId].value
			local newSlotName = GetDefaultSlotName(actionTypeId, categoryId, actionValue) 
			CSPM_UI_SlotNameEditbox:UpdateValue(false, newSlotName)
		end, 
		width = "full", 
		disabled = function()
			local uiActionTypeId = self.db.preset[self.currentPresetId].slot[self.currentSlotId].type
			if uiActionTypeId == ACTION_TYPE_COLLECTIBLE or uiActionTypeId == ACTION_TYPE_COLLECTIBLE_APPEARANCE or uiActionTypeId == ACTION_TYPE_EMOTE or uiActionTypeId == ACTION_TYPE_TRAVEL_TO_HOUSE or uiActionTypeId == ACTION_TYPE_PIE_MENU then
				return false
			else
				return true
			end
		end, 
--		reference = "CSPM_UI_GetSlotNameButton", 
	}
	optionsData[#optionsData + 1] = {
		type = "editbox", 
		name = L(SI_CSPM_UI_VISUAL_SLOT_ICON_OVERRIDE_NAME), 
		tooltip = L(SI_CSPM_UI_VISUAL_SLOT_ICON_OVERRIDE_TIPS), 
		getFunc = function() return self.db.preset[self.currentPresetId].slot[self.currentSlotId].icon end, 
		setFunc = function(newSlotIcon)
			CSPM.LDL:Debug("OnSlotIconEditboxChanged : %s", newSlotIcon)
			if newSlotIcon == "" then
				self.db.preset[self.currentPresetId].slot[self.currentSlotId].icon = nil
			else
				self.db.preset[self.currentPresetId].slot[self.currentSlotId].icon = newSlotIcon
			end
		end, 
		isMultiline = false, 
		isExtraWide = false, 
		maxChars = 1999, 
		width = "full", 
--		disabled = true, 
		default = self.DB_DEFAULT.preset[1].slot[1].icon or "", 
		reference = "CSPM_UI_SlotIconEditbox", 
	}
--[[
	optionsData[#optionsData + 1] = {
		type = "button", 
		name = "Test", 
		func = function()
			self:DoTestButton()
, 		end, 
--		width = "half", 
	}
]]
	LAM:RegisterOptionControls(self.panelId, optionsData)
end

function CSPM_PieMenuEditorPanel:OnLAMPanelControlsCreated(panel)
	-- Set up a custom tooltip for CSPM_UI_ActionValueMenu, a dropdown widget.
	local function ActionValueMenu_OnMouseEnter(comboBox, entryControl)
		local uiActionTypeId = self.db.preset[self.currentPresetId].slot[self.currentSlotId].type or ACTION_TYPE_NOTHING
		LayoutSlotActionTooltip(uiActionTypeId, self.db.preset[self.currentPresetId].slot[self.currentSlotId].category or CATEGORY_NOTHING, entryControl.m_data.value)
		ShowSlotActionTooltip(entryControl, TOPLEFT, 0, 0, BOTTOMRIGHT)
	end
	local function ActionValueMenu_OnMouseExit(comboBox, entryControl)
		HideSlotActionTooltip()
	end
	local comboBox = self.GetComboBoxObject_FromDropdownWidget(CSPM_UI_ActionValueMenu)
	if comboBox then
		comboBox:SetEntryMouseOverCallbacks(ActionValueMenu_OnMouseEnter, ActionValueMenu_OnMouseExit)
	end

	-- Create a widget for the Preset Selection dropdown menu
	local dropdownPresetSelectMenu = {
		type = "dropdown", 
		name = "", 
--		name = L(SI_CSPM_UI_PRESET_SELECT_MENU_NAME), 
		tooltip = L(SI_CSPM_UI_PRESET_SELECT_MENU_TIPS), 
		choices = self.presetChoices, 	-- If choicesValue is defined, choices table is only used for UI display!
		choicesValues = self.presetChoicesValues, 
		getFunc = function() return self.currentPresetId end, 
		setFunc = function(newPresetId)
			CSPM.LDL:Debug("OnPresetIdSelectionChanged : %s", newPresetId)
			if not self.db.preset[newPresetId] then
				CSPM.LDL:Debug("Error : preset data not found, so extend !")
				self.db.preset[newPresetId] = ZO_DeepTableCopy(self:GetDefaultPresetData())
				self.db.preset[newPresetId].id = newPresetId
				CSPM:FireCallbacks("CSPM-UserPieMenuInfoUpdated", newPresetId)
			end

			-- update preset tab
			self.currentPresetId = newPresetId

			if CSPM_UI_PresetSubmenu.open then
				CSPM_UI_PresetSubmenu.open = false
				CSPM_UI_PresetSubmenu.animation:PlayFromStart()
			end
			CSPM_UI_PresetSubmenu.data.name = self.presetChoices[self.currentPresetId]
			CSPM_UI_PresetSubmenu:UpdateValue()		-- Note : When called with no arguments, getFunc will be called, and setFunc will NOT be called.

			self:RebuildSlotDisplayNameCache(self.currentPresetId)	-- slotDisplayNameCache
			CSPM_UI_MenuItemsCountSlider:UpdateValue(false, self.db.preset[self.currentPresetId].menuItemsCount)
			self:ChangePanelSlotState(1)
		end, 
		width = "full", 
		scrollable = true, 
		default = 1, 
	}
	CSPM_UI_PresetSelectMenu = LAMCreateControl.dropdown(self.panel, dropdownPresetSelectMenu)
	CSPM_UI_PresetSelectMenu.combobox:SetWidth(300)	-- default : panelWidth(585) / 3
	CSPM_UI_PresetSelectMenu:SetAnchor(BOTTOMLEFT, CSPM_UI_PresetSubmenu, TOPLEFT)
	CSPM_UI_PresetSelectMenu:SetAnchor(BOTTOMRIGHT, CSPM_UI_PresetSubmenu, TOPRIGHT, -112, -4)

	-- Set up a custom tooltip for CSPM_UI_PresetSelectMenu, a dropdown widget.
	local function PresetSelectMenu_OnMouseEnter(comboBox, entryControl)
		LayoutSlotActionTooltip(ACTION_TYPE_PIE_MENU, CATEGORY_NOTHING, entryControl.m_data.value, UI_NONE)
		ShowSlotActionTooltip(entryControl, TOPLEFT, 0, 0, BOTTOMRIGHT)
	end
	local function PresetSelectMenu_OnMouseExit(comboBox, entryControl)
		HideSlotActionTooltip()
	end
	comboBox = self.GetComboBoxObject_FromDropdownWidget(CSPM_UI_PresetSelectMenu)
	if comboBox then
		comboBox:SetEntryMouseOverCallbacks(PresetSelectMenu_OnMouseEnter, PresetSelectMenu_OnMouseExit)
	end

	self:ChangePanelPresetState(1)
end

function CSPM_PieMenuEditorPanel:OpenSettingPanel(presetId, slotId)
	CT_LAMSettingPanelController.OpenSettingPanel(self)
	if self.panel then
		if presetId and IsUserPieMenu(presetId) then
			if self:IsPanelInitialized() then
				self:ChangePanelPresetState(presetId)
				if slotId then
					self:ChangePanelSlotState(slotId)
				end
			else
				zo_callLater(function()
					self:ChangePanelPresetState(presetId)
					if slotId then
						self:ChangePanelSlotState(slotId)
					end
				end, 1000)
			end
		end
	end
end

CShortcutPieMenu:RegisterClassObject("PieMenuEditorPanel", CSPM_PieMenuEditorPanel)
