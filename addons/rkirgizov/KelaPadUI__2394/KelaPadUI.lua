KelaPadUI = {}
kpuiSV = {}
KelaPadUI.name = "KelaPadUI";
-- _initialized = false
TRAIT_RESEARCHABLE = 0
TRAIT_KNOWN = 1
TRAIT_RESEARCH_IN_PROGRESS = 2

local colors = kpuiConst.Colors	

kelaResearchPanelNeedRefresh = false

kelaAvailableTraitsIcons = ""

-- Redefined text lines
-- SI_ITEM_FORMAT_STR_SET_NAME = "<<1>> (<<2>>/<<3>>)" --"<<1>> set (<<2>>/<<3>> items)"
SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME, "<<1>> (<<2>>/<<3>>)", 6)


--Сцены KelaPadUI
local kelaSetsScene = SCENE_MANAGER:GetScene("kelaSets")
kelaSetsScene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
kelaSetsScene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD_RIGHT)
kelaSetsScene:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
kelaSetsScene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
kelaSetsScene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
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


function KelaPadUI:GetItemLinkResearchStatus(link)
	local traitType = GetItemLinkTraitInfo(link)
	if kpuiConst.UnknowableTraitTypes[traitType] then
		return nil
	end

	local itemType = GetItemLinkItemType(link)
	local tradeSkill
	local resIndex
	
	if itemType == ITEMTYPE_ARMOR then
		local armorType = GetItemLinkArmorType(link)
		local equipType = GetItemLinkEquipType(link)
		local resLines = kpuiConst.ArmorTypeAndEquipTypeToResearchLineIndex[armorType]
		tradeSkill = kpuiConst.TradeskillForArmorType[armorType]
		resIndex = resLines and resLines[equipType]
	elseif itemType == ITEMTYPE_WEAPON then
		local weaponType = GetItemLinkWeaponType(link)
		tradeSkill = kpuiConst.TradeskillForWeaponType[weaponType]
		resIndex = kpuiConst.WeaponTypeToResearchLineIndex[weaponType]
	end

			
	if not tradeSkill or not resIndex then
		return nil
	end

	self.altsResearchStatus = {
		[TRAIT_RESEARCHABLE] = {},
		[TRAIT_KNOWN] = {},
		[TRAIT_RESEARCH_IN_PROGRESS] = {}
	}
	
	if kpuiSV.showAlts then
		for k,v in pairs(kpuiSV.characters) do
			if k ~= self.unitName and ( kpuiSV[self.unitName][k] == nil or kpuiSV[self.unitName][k] == true ) and kpuiSV.characters[k][tradeSkill] ~= nil then
				table.insert(self.altsResearchStatus[kpuiSV.characters[k][tradeSkill][resIndex][traitType]], k)
			end
		end
	end

	if not (kpuiSV.characters[self.unitName][tradeSkill] and resIndex) then
		return nil
	end
	
	return kpuiSV.characters[self.unitName][tradeSkill][resIndex][traitType]
end
function KelaPadUI:GetTraitTypeResearchStatus(traitType, tradeSkill, resIndex)

	if kpuiConst.UnknowableTraitTypes[traitType] then
		return nil
	end
			
	if not tradeSkill or not resIndex then
		return nil
	end

	self.altsResearchStatus = {
		[TRAIT_RESEARCHABLE] = {},
		[TRAIT_KNOWN] = {},
		[TRAIT_RESEARCH_IN_PROGRESS] = {}
	}
	
	if kpuiSV.showAlts then
		for k,v in pairs(kpuiSV.characters) do
			if k ~= self.unitName and ( kpuiSV[self.unitName][k] == nil or kpuiSV[self.unitName][k] == true ) and kpuiSV.characters[k][tradeSkill] ~= nil then
				table.insert(self.altsResearchStatus[kpuiSV.characters[k][tradeSkill][resIndex][traitType]], k)
			end
		end
	end

	if not (kpuiSV.characters[self.unitName][tradeSkill] and resIndex) then
		return nil
	end
	
	return kpuiSV.characters[self.unitName][tradeSkill][resIndex][traitType]
end

--event handlers обрабатывают изменения в исследованиях
function KelaPadUI_OnResearchCompleted(eventType, craftingSkillType, researchLineIndex, traitIndex)
	if not kpuiSV.characters[KelaPadUI.unitName][craftingSkillType] then
		return
	end
	local traitType = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
	kpuiSV.characters[KelaPadUI.unitName][craftingSkillType][researchLineIndex][traitType] = TRAIT_KNOWN
	-- KelaPostMsg("KelaPadUI_OnResearchCompleted")
	KelaPadUI:InitializeResearchableItems()
	--RefreshInfoTooltipResearchStation()
	kelaInitializeResearchPanel()
end
function KelaPadUI_OnResearchStarted(eventType, craftingSkillType, researchLineIndex, traitIndex)
	if not kpuiSV.characters[KelaPadUI.unitName][craftingSkillType] then
		return
	end
	local traitType = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
	kpuiSV.characters[KelaPadUI.unitName][craftingSkillType][researchLineIndex][traitType] = TRAIT_RESEARCH_IN_PROGRESS
	-- KelaPostMsg("KelaPadUI_OnResearchStarted")
	KelaPadUI:InitializeResearchableItems()
	--RefreshInfoTooltipResearchStation()
	kelaInitializeResearchPanel()
end
function KelaPadUI_OnResearchCanseled(eventType, craftingSkillType, researchLineIndex, traitIndex)
	if not kpuiSV.characters[KelaPadUI.unitName][craftingSkillType] then
		return
	end
	local traitType = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
	kpuiSV.characters[KelaPadUI.unitName][craftingSkillType][researchLineIndex][traitType] = TRAIT_RESEARCHABLE
	-- KelaPostMsg("KelaPadUI_OnResearchCanseled")
	KelaPadUI:InitializeResearchableItems()
	--RefreshInfoTooltipResearchStation(true)
	kelaInitializeResearchPanel()
end

-- function KelaPadUI_RefreshResearchPanel(control)
    -- control.nextAttributeRefreshSeconds = GetFrameTimeSeconds() + ZO_STATS_REFRESH_TIME_SECONDS
    -- for key, attribute in pairs(control.craftingItems) do
        -- attribute:RefreshText()
    -- end
    -- control:RefreshContentHeader(GetString(SI_STATS_ATTRIBUTES))
-- end


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

	-- показываем информационное окно в корне главного меню
	local mainMenuGamepadScene = SCENE_MANAGER.scenes.mainMenuGamepad
	mainMenuGamepadScene:RegisterCallback("StateChange", function(oldState, newState) 
		-- states: hiding, showing, shown, hidden
		if(newState == "showing") then
			kelaAddInfoTooltipMain()
		elseif(newState == "hiding") then
			SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_LEFT_TOOLTIP))
			SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_LEFT_TOOLTIP))
			SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_RIGHT_TOOLTIP))
			SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_RIGHT_TOOLTIP))	
		end
	end) 
end


local function KelaPadUI_OnLoaded(eventType, addonName)

	if(not _initialized) then

		
		if addonName ~= "KelaPadUI" then return end
		-- if(IsInGamepadPreferredMode()) then 
		-- else
			-- return
		-- end
		if kpuiSavedVariables then
			kpuiSV = kpuiSavedVariables
		else
			kpuiSavedVariables = kpuiSV
		end
		

		KelaPadUI.unitName = zo_strformat("<<1>>", GetUnitName("player"))
		
		setValueIfNil(kpuiSV, "showResearchInUpperRightCorner", true)
		setValueIfNil(kpuiSV, "showAlts", true)
		setValueIfNil(kpuiSV, KelaPadUI.unitName, {})	
		setValueIfNil(kpuiSV, "characters", {})

		KelaPadUI:InitializeResearchModul()
		KelaPadUI:InitializeDialogs()		
		
		kelaInitializeResearchPanel()
		
		--kelaInitializeInfoTooltipResearchMain()
		kelaInitializeInfoTooltipCraftingMain()
		kelaInitializeInfoTooltipSetsMain()
		
		
	
		
		--KelaPadUI:InitHooks()
		-- KelaPadUI:InitSettings()
		
		kpuiSV.characters[KelaPadUI.unitName] = {
			[CRAFTING_TYPE_BLACKSMITHING] = {},
			[CRAFTING_TYPE_WOODWORKING] = {},
			[CRAFTING_TYPE_CLOTHIER] = {},
			[CRAFTING_TYPE_JEWELRYCRAFTING] = {},
		}
		
		for k,v in pairs(kpuiSV.characters[KelaPadUI.unitName]) do
			for i=1, GetNumSmithingResearchLines(k) do
				local _,_, numTraits = GetSmithingResearchLineInfo(k, i)
				for t=1, numTraits do
					local traitType, _, known = GetSmithingResearchLineTraitInfo(k, i, t)
					setValueIfNil(kpuiSV.characters[KelaPadUI.unitName][k], i, {})
					if known then
						kpuiSV.characters[KelaPadUI.unitName][k][i][traitType] = TRAIT_KNOWN
					else
						local dur, remainig = GetSmithingResearchLineTraitTimes(k, i, t)
						if dur and remainig then
							kpuiSV.characters[KelaPadUI.unitName][k][i][traitType] = TRAIT_RESEARCH_IN_PROGRESS
						else
							kpuiSV.characters[KelaPadUI.unitName][k][i][traitType] = TRAIT_RESEARCHABLE
						end
					end
				end
			end
		end



		local tooltipLeft = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
		local tooltipRight = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP)	
		local tooltipQuad1 = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_QUAD1_TOOLTIP)	
		local tooltipMove = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP)
		local tooltipLeftDialog = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_DIALOG_TOOLTIP)	
		local tooltipQuad3 = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_QUAD3_TOOLTIP)		

		local tooltipChamp1 =  ZO_ChampionPerksChosenConstellationGamepadLeftTooltipContainerTipScrollScrollChildTooltip
        local tooltipChamp2 =  ZO_ChampionPerksChosenConstellationGamepadRightTooltipContainerTipScrollScrollChildTooltip

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

		kelaTotalRedefineStyles()
			
		-- hide player_progress_bar
		PLAYER_SUBMENU_SCENE:RemoveFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_GAMEPAD_CURRENT)
		GAMEPAD_STATS_ROOT_SCENE:RemoveFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_GAMEPAD_CURRENT)
		MAIN_MENU_GAMEPAD_SCENE:RemoveFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_GAMEPAD_CURRENT)
		
		kelaAddInfoTooltip()

		kelaReplaceTooltips (tooltipLeft)
		kelaReplaceTooltips (tooltipRight)
		kelaReplaceTooltipQuad1 (tooltipQuad1)
		kelaReplaceTooltipChamps (tooltipChamp1)
		kelaReplaceTooltipChamps (tooltipChamp2)
		-- -- kelaReplaceTooltips (GAMEPAD_QUAD3_TOOLTIP)

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

EVENT_MANAGER:RegisterForEvent("KelaPadUIOnLoaded", EVENT_ADD_ON_LOADED, KelaPadUI_OnLoaded)
EVENT_MANAGER:RegisterForEvent("KelaPadUIGamepadModeChanged", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function(code, inGamepad)  OnGamepadPreferredModeChanged(EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, KelaPadUI.name) end)
EVENT_MANAGER:RegisterForEvent("KelaPadUIResearchCompleted", EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, KelaPadUI_OnResearchCompleted)
EVENT_MANAGER:RegisterForEvent("KelaPadUIResearchStarted", EVENT_SMITHING_TRAIT_RESEARCH_STARTED, KelaPadUI_OnResearchStarted)
EVENT_MANAGER:RegisterForEvent("KelaPadUIResearchCanseled", EVENT_SMITHING_TRAIT_RESEARCH_CANCELED, KelaPadUI_OnResearchCanseled)

-- EVENT_MANAGER:RegisterForEvent("testtest", EVENT_ACTION_LAYER_POPPED, testtest)
