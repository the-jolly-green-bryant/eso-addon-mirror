KelaPadUI = {
	name = "KelaPadUI",	
	displayName = "|cFF00FF" .. "KelaPadUI interface for Gamepad UI" .. "|r",
	webSite 		    = "https://www.esoui.com/downloads/info2740-KelaPadUI.html",
	donations 			= "https://www.esoui.com/downloads/info2740-KelaPadUI.html#donate",
}

local _initialized = false

--Сцены KelaPadUI
local kelaSetsScene = SCENE_MANAGER:GetScene("kelaSets")
GAMEPAD_SETS_LIST_FRAGMENT = ZO_FadeSceneFragment:New(Kela_Sets_List_Gamepad)
kelaSetsScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
kelaSetsScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD_RIGHT)
kelaSetsScene:AddFragment(GAMEPAD_SETS_LIST_FRAGMENT)
kelaSetsScene:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
kelaSetsScene:AddFragment(GAMEPAD_NAV_QUADRANT_2_3_4_BACKGROUND_FRAGMENT)
kelaSetsScene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
kelaSetsScene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
GAMEPAD_TOOLTIPS:AddTooltipInstantScene(GAMEPAD_RIGHT_TOOLTIP, kelaSetsScene)
local kelaResearchScene = SCENE_MANAGER:GetScene("kelaResearch")
kelaResearchScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
kelaResearchScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD_RIGHT)
kelaResearchScene:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
kelaResearchScene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
kelaResearchScene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
local kelaUndauntedScene = SCENE_MANAGER:GetScene("kelaUndaunted")
kelaUndauntedScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
kelaUndauntedScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD_RIGHT)
kelaUndauntedScene:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
kelaUndauntedScene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
kelaUndauntedScene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
local kelaQuickAccessScene = SCENE_MANAGER:GetScene("kelaQuickAccess")
kelaQuickAccessScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
kelaQuickAccessScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD_RIGHT)
kelaQuickAccessScene:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
kelaQuickAccessScene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
kelaQuickAccessScene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
-----------------------
--Options Root Scene
-----------------------
KELA_OPTIONS_ROOT_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
KELA_OPTIONS_ROOT_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD_OPTIONS)
KELA_OPTIONS_ROOT_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_SYSTEM)
KELA_OPTIONS_ROOT_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
KELA_OPTIONS_ROOT_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
KELA_OPTIONS_ROOT_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
KELA_OPTIONS_ROOT_SCENE:AddFragment(KELA_OPTIONS_FRAGMENT)
KELA_OPTIONS_ROOT_SCENE:AddFragment(KELA_OPTIONS:GetHeaderFragment())
-----------------------
--Options Panel Scene
-----------------------
KELA_OPTIONS_PANEL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
KELA_OPTIONS_PANEL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD_OPTIONS)
KELA_OPTIONS_PANEL_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_SYSTEM)
KELA_OPTIONS_PANEL_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
KELA_OPTIONS_PANEL_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
KELA_OPTIONS_PANEL_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
KELA_OPTIONS_PANEL_SCENE:AddFragment(KELA_OPTIONS_FRAGMENT)
KELA_OPTIONS_PANEL_SCENE:AddFragment(KELA_OPTIONS:GetHeaderFragment())

	-- show info tooltip
function kelaAddInfoTooltip()

	-- enable isResearchable icon for itemslot in inventory
	local OldZO_GamepadInventoryRefreshItemList = ZO_GamepadInventory.RefreshItemList
	ZO_GamepadInventory.RefreshItemList = function(control, ...) 

		local function GetItemDataFilterComparator(filteredEquipSlot, nonEquipableFilterType)
			return function(itemData)
				if filteredEquipSlot then
					return ZO_Character_DoesEquipSlotUseEquipType(filteredEquipSlot, itemData.equipType)
				end
				if nonEquipableFilterType then
					return ZO_InventoryUtils_DoesNewItemMatchFilterType(itemData, nonEquipableFilterType)
				end
				return ZO_InventoryUtils_DoesNewItemMatchSupplies(itemData)
			end
		end
		local function GetCategoryTypeFromWeaponType(bagId, slotIndex)
			local weaponType = GetItemWeaponType(bagId, slotIndex)
			if weaponType == WEAPONTYPE_AXE or weaponType == WEAPONTYPE_HAMMER or weaponType == WEAPONTYPE_SWORD or weaponType == WEAPONTYPE_DAGGER then
				return GAMEPAD_WEAPON_CATEGORY_ONE_HANDED_MELEE
			elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD or weaponType == WEAPONTYPE_TWO_HANDED_AXE or weaponType == WEAPONTYPE_TWO_HANDED_HAMMER then
				return GAMEPAD_WEAPON_CATEGORY_TWO_HANDED_MELEE
			elseif weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF or weaponType == WEAPONTYPE_LIGHTNING_STAFF then
				return GAMEPAD_WEAPON_CATEGORY_DESTRUCTION_STAFF
			elseif weaponType == WEAPONTYPE_HEALING_STAFF then
				return GAMEPAD_WEAPON_CATEGORY_RESTORATION_STAFF
			elseif weaponType == WEAPONTYPE_BOW then
				return GAMEPAD_WEAPON_CATEGORY_TWO_HANDED_BOW
			elseif weaponType ~= WEAPONTYPE_NONE then
				return GAMEPAD_WEAPON_CATEGORY_UNCATEGORIZED
			end
		end
		local function GetBestQuestItemCategoryDescription(questItemData)
			local questItemCategory = GAMEPAD_QUEST_ITEM_CATEGORY_NOT_SLOTTABLE
			if CanQuickslotQuestItemById(questItemData.questItemId) then
				questItemCategory = GAMEPAD_QUEST_ITEM_CATEGORY_SLOTTABLE
			end
			return GetString("SI_GAMEPADQUESTITEMCATEGORY", questItemCategory)
		end		
		local function GetBestItemCategoryDescription(itemData)
			if itemData.itemType == ITEMTYPE_FURNISHING then
				local furnitureDataId = GetItemFurnitureDataId(itemData.bagId, itemData.slotIndex)
				if furnitureDataId ~= 0 then
					local categoryId, subcategoryId = GetFurnitureDataCategoryInfo(furnitureDataId)
					if categoryId then
						local categoryName = GetFurnitureCategoryInfo(categoryId)
						if categoryName ~= "" then
							return categoryName
						end
					end
				end
			end
			local categoryType = GetCategoryTypeFromWeaponType(itemData.bagId, itemData.slotIndex)
			if categoryType ==  GAMEPAD_WEAPON_CATEGORY_UNCATEGORIZED then
				local weaponType = GetItemWeaponType(itemData.bagId, itemData.slotIndex)
				return GetString("SI_WEAPONTYPE", weaponType)
			elseif categoryType then
				return GetString("SI_GAMEPADWEAPONCATEGORY", categoryType)
			end
			local armorType = GetItemArmorType(itemData.bagId, itemData.slotIndex)
			if armorType ~= ARMORTYPE_NONE then
				return GetString("SI_ARMORTYPE", armorType)
			end
			return ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription(itemData)
		end

		control.itemList:Clear()
		if control.categoryList:IsEmpty() then return end

		local targetCategoryData = control.categoryList:GetTargetData()
		local filteredEquipSlot = targetCategoryData.equipSlot
		local nonEquipableFilterType = targetCategoryData.filterType
		local filteredDataTable

		local isQuestItemFilter = nonEquipableFilterType == ITEMFILTERTYPE_QUEST
		--special case for quest items
		if isQuestItemFilter then
			filteredDataTable = {}
			local questCache = SHARED_INVENTORY:GenerateFullQuestCache()
			for _, questItems in pairs(questCache) do
				for _, questItem in pairs(questItems) do
					table.insert(filteredDataTable, questItem)
					questItem.bestItemCategoryName = zo_strformat(SI_INVENTORY_HEADER, GetBestQuestItemCategoryDescription(questItem))
				end
			end
			table.sort(filteredDataTable, ZO_GamepadInventory_QuestItemSortComparator)
		else
			local comparator = GetItemDataFilterComparator(filteredEquipSlot, nonEquipableFilterType)

			filteredDataTable = SHARED_INVENTORY:GenerateFullSlotData(comparator, BAG_BACKPACK, BAG_WORN)
			for _, itemData in pairs(filteredDataTable) do
				itemData.bestItemCategoryName = zo_strformat(SI_INVENTORY_HEADER, GetBestItemCategoryDescription(itemData))
			end
			table.sort(filteredDataTable, ZO_GamepadInventory_DefaultItemSortComparator)
		end

		local lastBestItemCategoryName
		for i, itemData in ipairs(filteredDataTable) do
			
			
			local CHECKED_ICON1 = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_inventory.dds"
			local CHECKED_ICON2 = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_equipped.dds"
			
			local nextItemData = filteredDataTable[i + 1]

			local entryData = ZO_GamepadEntryData:New(itemData.name, itemData.iconFile)
			entryData:InitializeInventoryVisualData(itemData)

			if itemData.bagId == BAG_WORN then
				entryData.isEquippedInCurrentCategory = itemData.slotIndex == filteredEquipSlot
				entryData.isEquippedInAnotherCategory = itemData.slotIndex ~= filteredEquipSlot
				entryData.isHiddenByWardrobe = WouldEquipmentBeHidden(itemData.slotIndex or EQUIP_SLOT_NONE)
			elseif isQuestItemFilter then
				local slotIndex = FindActionSlotMatchingSimpleAction(ACTION_TYPE_QUEST_ITEM, itemData.questItemId)
				entryData.isEquippedInCurrentCategory = slotIndex ~= nil
			else
				local slotIndex = FindActionSlotMatchingItem(itemData.bagId, itemData.slotIndex)
				entryData.isEquippedInCurrentCategory = slotIndex ~= nil
			end

			local remaining, duration
			if isQuestItemFilter then
				if itemData.toolIndex then
					remaining, duration = GetQuestToolCooldownInfo(itemData.questIndex, itemData.toolIndex)
				elseif itemData.stepIndex and itemData.conditionIndex then
					remaining, duration = GetQuestItemCooldownInfo(itemData.questIndex, itemData.stepIndex, itemData.conditionIndex)
				end

				ZO_InventorySlot_SetType(entryData, SLOT_TYPE_QUEST_ITEM)
			else
				remaining, duration = GetItemCooldownInfo(itemData.bagId, itemData.slotIndex)

				ZO_InventorySlot_SetType(entryData, SLOT_TYPE_GAMEPAD_INVENTORY_ITEM)
			end
			if remaining > 0 and duration > 0 then
				entryData:SetCooldown(remaining, duration)
			end
			-- enable isresearchable icon for itemslot (ZO_SharedGamepadEntryStatusIndicatorSetup)
			--entryData:SetIgnoreTraitInformation(true)
			entryData:SetIgnoreTraitInformation(false)
			if itemData.bestItemCategoryName ~= lastBestItemCategoryName then
				lastBestItemCategoryName = itemData.bestItemCategoryName

				entryData:SetHeader(lastBestItemCategoryName)
				control.itemList:AddEntry("ZO_GamepadItemSubEntryTemplateWithHeader", entryData)
			else
				control.itemList:AddEntry("ZO_GamepadItemSubEntryTemplate", entryData)
			end
		end
		control.itemList:Commit()
		
		
		
		-- local ret = OldZO_GamepadInventoryRefreshItemList(control, ...) 	
		-- return ret	
	end



	-- Переключение квестов в главном меню
	local function moveToNextQuest (right)
		local questIndex = QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex()
		local index
		if QUEST_JOURNAL_MANAGER.quests then
			for i, quest in ipairs(QUEST_JOURNAL_MANAGER.quests) do
				if quest.questIndex == questIndex then
					local nextQuest 
					if right then
						nextQuest = (i == #QUEST_JOURNAL_MANAGER.quests) and 1 or (i + 1)
					else
						nextQuest = (i == 1) and #QUEST_JOURNAL_MANAGER.quests or (i - 1)
					end
					index = QUEST_JOURNAL_MANAGER.quests[nextQuest].questIndex
					break
				end
			end
		end		
		QUEST_JOURNAL_GAMEPAD:FireCallbacks("QuestSelected", index)
		ZO_ZoneStories_Manager.StopZoneStoryTracking()
		FOCUSED_QUEST_TRACKER:ForceAssist(index)
		QUEST_JOURNAL_GAMEPAD:RefreshQuestList()
	end
	
	KelaPadUI.kelaMainMenuKeybindStripDescriptor =
		{
			{
				alignment = KEYBIND_STRIP_ALIGN_CENTER,	
				name = GetString(KELA_SETSKEY_VIEW),
				keybind = "UI_SHORTCUT_INPUT_LEFT",
				ethereal = true,
				visible = function()
						return KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_MAININFO_ENABLED) and KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_MAININFO_QUEST) 
					end,
				callback = function()
						if KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_MAININFO_ENABLED) and KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_MAININFO_QUEST)  then 
							moveToNextQuest(false)
							kelaAddInfoTooltipMain()
						end
					end,
			},
			{
				alignment = KEYBIND_STRIP_ALIGN_CENTER,	
				name = GetString(KELA_SETSKEY_VIEW),
				keybind = "UI_SHORTCUT_INPUT_RIGHT",
				ethereal = true,
				visible = function()
						return KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_MAININFO_ENABLED) and KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_MAININFO_QUEST) 
					end,
				callback = function()
						if KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_MAININFO_ENABLED) and KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_MAININFO_QUEST)  then 
							moveToNextQuest(true)
							kelaAddInfoTooltipMain()
						end
					end,
			},
			{
			alignment = function()		
						if KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_MAININFO_ENABLED) then
							return KEYBIND_STRIP_ALIGN_RIGHT
						else
							return KEYBIND_STRIP_ALIGN_CENTER
						end
				end,
			name = GetString(KELA_MAINMENU_QUICKACCESS),
			keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
				visible = function()
						return KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_QUICKACCESS_ENABLED) and (KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_QUICKACCESS_QUEST) or KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_QUICKACCESS_MAIL))
					end,
			callback = function()		
						MAIN_MENU_GAMEPAD:ShowScene("kelaQuickAccess")
				end,
			},
			
			-- кнопка отслеживания достижений
			{
				alignment = KEYBIND_STRIP_ALIGN_CENTER,	
				name = GetString(KELA_SETSKEY_CLEARSEARCH),
				keybind = "UI_SHORTCUT_SECONDARY",
				visible = function()
						return KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_MAININFO_ACHIVTRACK) and ACHIEVEMENTS_GAMEPAD.visibleCategoryId ~= nil
					end,
				callback = function()
						CHAT_SYSTEM:AddMessage(GetString(KELA_SETSKEY_CLEARSEARCH))
					end,
			}
			-- table.insert(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor, keybind)
		}
 

	-- показываем информационное окно в корне главного меню, добавляем кнопки
	local mainMenuGamepadScene = SCENE_MANAGER.scenes.mainMenuGamepad
	mainMenuGamepadScene:RegisterCallback("StateChange", function(oldState, newState) 
		-- states: hiding, showing, shown, hidden
		if(newState == "showing") then
			--кнопки
			KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.kelaMainMenuKeybindStripDescriptor)
			if KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_MAININFO_ENABLED) then
				kelaAddInfoTooltipMain()
				--Скрываем прогресс бар в подвале
				PLAYER_SUBMENU_SCENE:RemoveFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_GAMEPAD_CURRENT)
				GAMEPAD_STATS_ROOT_SCENE:RemoveFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_GAMEPAD_CURRENT)
				MAIN_MENU_GAMEPAD_SCENE:RemoveFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_GAMEPAD_CURRENT)
			else
				--показываем прогресс бар в подвале
				PLAYER_SUBMENU_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_GAMEPAD_CURRENT)
				GAMEPAD_STATS_ROOT_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_GAMEPAD_CURRENT)
				MAIN_MENU_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_GAMEPAD_CURRENT)
			end
		elseif(newState == "hiding") then
			KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.kelaMainMenuKeybindStripDescriptor)
			KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_LEFT_TOOLTIP, false)
			KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP, false)
			SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_LEFT_TOOLTIP))
			SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_LEFT_TOOLTIP))
			SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_RIGHT_TOOLTIP))
			SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_RIGHT_TOOLTIP))	
		end
	end) 

end
	
local function setupTooltips()
	local tooltipLeft = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
	local tooltipRight = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP)	
	local tooltipQuad1 = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_QUAD1_TOOLTIP)	
	local tooltipMove = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP)
	local tooltipLeftDialog = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_DIALOG_TOOLTIP)	
	local tooltipQuad3 = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_QUAD3_TOOLTIP)		

	local tooltipChamp1 =  ZO_ChampionPerksChosenConstellationGamepadLeftTooltipContainerTipScrollScrollChildTooltip
	local tooltipChamp2 =  ZO_ChampionPerksChosenConstellationGamepadRightTooltipContainerTipScrollScrollChildTooltip

	kelaTotalRedefineStyles()

	KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_LEFT_TOOLTIP.control:SetWidth(KELA_TOOLTIPS_WIDTH)	
	KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_WIDE_SETS_TOOLTIP.control:SetWidth(KELA_TOOLTIPS_WIDE_WIDTH)
	KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_WIDE_CRAFTING_TOOLTIP.control:SetWidth(KELA_TOOLTIPS_WIDE_WIDTH)
	KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP.control:SetWidth(KELA_TOOLTIPS_WIDE_WIDTH)
		
	GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_LEFT_TOOLTIP.control:ClearAnchors()
	GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_LEFT_TOOLTIP.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 535, 53) 
	GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_LEFT_TOOLTIP.control:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 535, -125) 
	GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_LEFT_TOOLTIP.control:SetWidth(KELA_TOOLTIPS_WIDTH)

	GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_RIGHT_TOOLTIP.control:ClearAnchors()
	GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_RIGHT_TOOLTIP.control:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -10, 53) 
	GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_RIGHT_TOOLTIP.control:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -10, -125) 
	GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_RIGHT_TOOLTIP.control:SetWidth(KELA_TOOLTIPS_WIDTH)
	
	KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_RIGHT_TOOLTIP.control:ClearAnchors()
	KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_RIGHT_TOOLTIP.control:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -10, 53) 
	KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_RIGHT_TOOLTIP.control:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -10, -125) 		
	KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_RIGHT_TOOLTIP.control:SetWidth(KELA_TOOLTIPS_WIDTH)		
	
	KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_MAIN_TOOLTIP.control:ClearAnchors()
	KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_MAIN_TOOLTIP.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 56, 53) 
	KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_MAIN_TOOLTIP.control:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 56, -125) 		
	KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_MAIN_TOOLTIP.control:SetWidth(KELA_TOOLTIPS_WIDTH)		

	-- GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_MOVABLE_TOOLTIP.control:SetWidth(KELA_TOOLTIPS_WIDTH)
	-- GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_LEFT_DIALOG_TOOLTIP.control:SetWidth(KELA_TOOLTIPS_WIDTH)
	-- GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_QUAD3_TOOLTIP.control:SetWidth(KELA_TOOLTIPS_WIDTH)	

	LOOT_WINDOW_GAMEPAD.control:ClearAnchors()
	LOOT_WINDOW_GAMEPAD.control:SetAnchor(TOPRIGHT, GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_RIGHT_TOOLTIP.control, TOPLEFT, -5, 0) 
	LOOT_WINDOW_GAMEPAD.control:SetAnchor(BOTTOMRIGHT, GAMEPAD_TOOLTIPS.tooltips.GAMEPAD_RIGHT_TOOLTIP.control, BOTTOMLEFT, -5, 0) 
	LOOT_WINDOW_GAMEPAD.control:SetWidth(520)		
	
	kelaAddInfoTooltip()


	kelaReplaceTooltips (tooltipLeft)
	kelaReplaceTooltips (tooltipRight)
	kelaReplaceTooltipQuad1 (tooltipQuad1)
	-- kelaReplaceTooltipChamps (tooltipChamp1)
	-- kelaReplaceTooltipChamps (tooltipChamp2)
	-- kelaReplaceTooltips (GAMEPAD_QUAD3_TOOLTIP)


	ZO_CRAFTING_TOOLTIP_STYLES = ZO_DeepTableCopy(ZO_TOOLTIP_STYLES)
	for key,value in pairs(ZO_CRAFTING_TOOLTIP_STYLES) do
		value["horizontalAlignment"] = TEXT_ALIGN_CENTER

		if key ~= "topSection" then
			value["layoutPrimaryDirectionCentered"] = true
		end
	end

end	
	
	
local function KelaPadUI_OnLoaded(eventType, addonName)
	if not _initialized then
		if addonName ~= "KelaPadUI" then return end
		KelaPadUI.unitName = zo_strformat("<<1>>", GetUnitName("player"))
		KelaInitializeSettings()
		KELA_RESEARCH:InitializeResearchModul()
		KELA_SETS_LIST:SetMasterSetsList()
		KelaSetupAchievements()
		if TamrielTradeCentre ~= nil and ArkadiusTradeTools ~= nil then
			-- KELA_TRADE_ENABLED = true
			-- KELA_TRADE_ENABLED_TOOLTIP_INDEX = 1
			KelaSetupTradingHouse()
			KelaSetupCraftingStation()
		else
			-- KELA_TRADE_ENABLED = false
			-- KELA_TRADE_ENABLED_TOOLTIP_INDEX = 0
			KelaSetSetting(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ENABLED, false)
		end
		setupTooltips()
		CHAT_SYSTEM:AddMessage("KelaPadUI has been loaded")		
		_initialized = true
	end	
end 	

local function OnGamepadPreferredModeChanged(eventType, addonName)
	--_initialized = false
	if IsInGamepadPreferredMode() then
		KelaPadUI_OnLoaded (eventType, addonName)
	end		
end

EVENT_MANAGER:RegisterForEvent("KelaPadUI", EVENT_ADD_ON_LOADED, KelaPadUI_OnLoaded)
EVENT_MANAGER:RegisterForEvent("KelaPadUI", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function(code, inGamepad)  OnGamepadPreferredModeChanged(EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, KelaPadUI.name) end)
EVENT_MANAGER:RegisterForEvent("KelaPadUI", EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, KelaPadUI_OnResearchCompleted)
EVENT_MANAGER:RegisterForEvent("KelaPadUI", EVENT_SMITHING_TRAIT_RESEARCH_STARTED, KelaPadUI_OnResearchStarted)
EVENT_MANAGER:RegisterForEvent("KelaPadUI", EVENT_SMITHING_TRAIT_RESEARCH_CANCELED, KelaPadUI_OnResearchCanceled)

-- EVENT_MANAGER:RegisterForEvent("testtest", EVENT_ACTION_LAYER_POPPED, testtest)
