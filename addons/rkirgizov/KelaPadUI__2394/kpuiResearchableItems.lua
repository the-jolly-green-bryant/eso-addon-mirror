-- модуль для отслеживания вещей в инвентаре, с особенностями, доступными для исследования

local colors = kpuiConst.Colors	



function KelaPadUI:InitializeResearchModul()

	KelaPadUI:InitializeResearchableItems(true)

	-- обрабатываем получение и потерю предметов
	local OldZO_SharedInventoryManagerHandleSlotCreationOrUpdate = ZO_SharedInventoryManager.HandleSlotCreationOrUpdate
	ZO_SharedInventoryManager.HandleSlotCreationOrUpdate = function(control, bagCache, bagId, slotIndex, isNewItem) 
		local SHARED_INVENTORY_SLOT_RESULT_REMOVED = 1
		local SHARED_INVENTORY_SLOT_RESULT_ADDED = 2
		local SHARED_INVENTORY_SLOT_RESULT_UPDATED = 3
		local SHARED_INVENTORY_SLOT_RESULT_NO_CHANGE = 4
		local SHARED_INVENTORY_SLOT_RESULT_REMOVE_AND_ADD = 5		
		local existingSlotData = bagCache[slotIndex]
		local slotData, result = control:CreateOrUpdateSlotData(existingSlotData, bagId, slotIndex, isNewItem)
		if result == SHARED_INVENTORY_SLOT_RESULT_REMOVED then
			KelaPadUI:RemoveResearchableItem(existingSlotData.uniqueId, existingSlotData.name)
		elseif result == SHARED_INVENTORY_SLOT_RESULT_ADDED then
			local itemLink = GetItemLink(slotData.bagId, slotData.slotIndex)
			if KelaPadUI:GetItemLinkResearchStatus(itemLink) == TRAIT_RESEARCHABLE then
				KelaPadUI:AddResearchableItem(slotData.bagId, slotData.slotIndex)
			end
		elseif result == SHARED_INVENTORY_SLOT_RESULT_UPDATED then
		elseif result == SHARED_INVENTORY_SLOT_RESULT_REMOVE_AND_ADD then
			KelaPadUI:RemoveResearchableItem(existingSlotData.uniqueId, existingSlotData.name)
			KelaPadUI:AddResearchableItem(slotData.bagId, slotData.slotIndex)			
		end
		local ret = OldZO_SharedInventoryManagerHandleSlotCreationOrUpdate(control, bagCache, bagId, slotIndex, isNewItem) 	
		--return ret	
	end

	-- собираем строку иконок доступных исследований
	local gamepad_smithing_research_Scene = SCENE_MANAGER.scenes.gamepad_smithing_research
	gamepad_smithing_research_Scene:RegisterCallback("StateChange", function(oldState, newState) 
		-- states: hiding, showing, shown, hidden
		

		if(newState == "shown") then


			
		elseif(newState == "showing") then
			local craftingType = GetCraftingInteractionType()
			kelaSetAvailableTraitsIcons(craftingType)
		elseif(newState == "hiding") then
		
			kelaAvailableTraitsIcons = ""
		
		elseif(newState == "hidden") then
		end
	end) 	



	-- перемещение по спискам на станции
	local OldZO_GamepadSmithingResearchRefreshFocusItems = ZO_GamepadSmithingResearch.RefreshFocusItems
	ZO_GamepadSmithingResearch.RefreshFocusItems = function(selfcontrol, focusIndex, ...)
		local function AddEntry(control, highlight, activate, deactivate)
			selfcontrol.focus:AddEntry(
			{
				control = control,
				highlight = highlight,
				activate = activate,
				deactivate = deactivate,
			})
		end

		local ACTIVE = true

		local function UpdateBorderHighlight(focusedControl, active)
			focusedControl.inactiveBG:SetHidden(active)
			focusedControl.activeBG:SetHidden(not active)
		end

		local function ListActivate(control, data)
			control:Activate()
			UpdateBorderHighlight(control:GetControl():GetParent(), ACTIVE)
			
			-- KelaPostMsg("selfcontrol.craftingType "..tostring(selfcontrol.craftingType))
			if kelaAvailableTraitsIcons == "" then 
				local craftingType = GetCraftingInteractionType()
				kelaSetAvailableTraitsIcons(craftingType)
			end
			
			local itemCraftType = kpuiConst.SmithingTypeResearchLineTraitTypeToItemCraftType[selfcontrol.craftingType][selfcontrol.researchLineIndex]
			
			kelaAddInfoTooltipResearchStation(selfcontrol.craftingType, selfcontrol.researchLineIndex, itemCraftType)
		end

		local function ListDeactivate(control, data)
			control:Deactivate()
			UpdateBorderHighlight(control:GetControl():GetParent(), not ACTIVE)
			SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_RIGHT_TOOLTIP))
			SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_RIGHT_TOOLTIP))
		end

		AddEntry(selfcontrol.researchLineList, selfcontrol.control:GetNamedChild("ResearchLineList").focusTexture, ListActivate, ListDeactivate)

		local function Activate(control)
			selfcontrol:OnResearchRowActivate(control)
		end

		local function Deactivate(control)
			selfcontrol:OnResearchRowDeactivate(control)
		end

		local entries = selfcontrol.slotPool:GetActiveObjects()
		for _, v in pairs(entries) do
			AddEntry(v, v:GetNamedChild("Highlight"), Activate, Deactivate)
		end

		if focusIndex then
			selfcontrol.focus:SetFocusByIndex(focusIndex)
		else
			selfcontrol.focus:SetFocusByIndex(1)
		end

		-- local ret = OldZO_GamepadSmithingResearchRefreshFocusItems(control, focusIndex, ...)
		-- return ret	

	end

	-- hook trait list on crafting station for add icons blocked or worned items
	local OldZO_GamepadSmithingResearchSetupTraitDisplay = ZO_GamepadSmithingResearch.SetupTraitDisplay
	ZO_GamepadSmithingResearch.SetupTraitDisplay = function(control, slotControl, researchLine, known, duration, traitIndex, ...)
		
		local tblResearchableItemsWorned, tblResearchableItemsLocked, tblResearchableItemsFree
		if not known and not duration then
			if slotControl.craftingType then
				local itemCraftType
				if slotControl.researchLineIndex then 
					itemCraftType = kpuiConst.SmithingTypeResearchLineTraitTypeToItemCraftType[slotControl.craftingType][slotControl.researchLineIndex] 
					tblResearchableItemsWorned, tblResearchableItemsLocked, tblResearchableItemsFree = KelaPadUI:GetTableResearchableItemsByTrait(slotControl.craftingType, itemCraftType, slotControl.researchLineIndex, slotControl.traitType)
				end
			end			
		end		
		
		local iconControl = GetControl(slotControl, "Icon")
		
		if known then
			slotControl.nameLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
			slotControl.statusLabel:SetText("")
			slotControl.timerIcon:SetHidden(true)
			iconControl:SetDesaturation(0)
			iconControl:SetAlpha(1)
		elseif duration then
			slotControl.nameLabel:SetColor(ZO_SECOND_CONTRAST_TEXT:UnpackRGBA())
			slotControl.statusLabel:SetText(GetString(SI_SMITHING_RESEARCH_IN_PROGRESS))
			slotControl.statusLabel:SetColor(ZO_SECOND_CONTRAST_TEXT:UnpackRGBA())
			slotControl.timerIcon:SetHidden(false)
			slotControl.timerIcon:SetColor(ZO_SECOND_CONTRAST_TEXT:UnpackRGBA())
			iconControl:SetDesaturation(0)
			iconControl:SetAlpha(.3)
		elseif researchLine.itemTraitCounts and researchLine.itemTraitCounts[traitIndex] then
			slotControl.nameLabel:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
			if tblResearchableItemsFree and (tblResearchableItemsWorned or tblResearchableItemsLocked) then
				slotControl.statusLabel:SetText(colors.COLOR_WHITE:Colorize(GetString(KELA_TOOLTIP_CRAFTING_STATION_AVAIL))..colors.COLOR_ORANGE:Colorize(GetString(KELA_TOOLTIP_CRAFTING_STATION_ABLE)))
			elseif tblResearchableItemsFree then
				slotControl.statusLabel:SetText(GetString(SI_SMITHING_RESEARCH_RESEARCHABLE))
			else
				slotControl.statusLabel:SetText(colors.COLOR_ORANGE:Colorize(GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)))
			end
			slotControl.statusLabel:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
			slotControl.timerIcon:SetHidden(true)
			iconControl:SetDesaturation(0)
			iconControl:SetAlpha(1)
			slotControl.researchable = true
		else
			slotControl.nameLabel:SetColor(ZO_DISABLED_TEXT:UnpackRGBA())
			slotControl.statusLabel:SetText(GetString(SI_SMITHING_RESEARCH_UNKNOWN))
			slotControl.statusLabel:SetColor(ZO_DISABLED_TEXT:UnpackRGBA())
			slotControl.timerIcon:SetHidden(true)
			iconControl:SetDesaturation(1)
			iconControl:SetAlpha(1)
			slotControl.researchable = false			
		end
		-- local ret = OldZO_GamepadSmithingResearchSetupTraitDisplay(control, slotControl, researchLine, known, duration, traitIndex, ...)
		-- return ret					
	end	
	
	-- hook trait tooltip on crafting station for adding available items info
	local OldZO_GamepadSmithingResearchSetupTooltip = ZO_GamepadSmithingResearch.SetupTooltip
	ZO_GamepadSmithingResearch.SetupTooltip = function(control, row, ...) 
		--KelaPostMsg ("ZO_GamepadSmithingResearch.SetupTooltip")
		GAMEPAD_TOOLTIPS:LayoutResearchSmithingItem(GAMEPAD_LEFT_TOOLTIP, GetString("SI_ITEMTRAITTYPE", row.traitType), row.traitDescription, row.traitResearchSourceDescription, row.traitMaterialSourceDescription)
		local traitResearchStatus = KelaPadUI:GetTraitTypeResearchStatus(row.traitType, control.craftingType, control.researchLineIndex)
		if traitResearchStatus == 0 then
			-- local tableResearchableItems = KelaPadUI:GetTableResearchableItems(control.craftingType)
			if control.craftingType then
				local itemCraftType
				if control.researchLineIndex then 
					itemCraftType = kpuiConst.SmithingTypeResearchLineTraitTypeToItemCraftType[control.craftingType][control.researchLineIndex] 
					local tblResearchableItemsWorned, tblResearchableItemsLocked, tblResearchableItemsFree = KelaPadUI:GetTableResearchableItemsByTrait(control.craftingType, itemCraftType, control.researchLineIndex, row.traitType)
					if tblResearchableItemsWorned then
						local tooltipInfo = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)	
						local headerItemsAvailabled = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
						headerItemsAvailabled:AddLine(colors.COLOR_RED:Colorize(GetString(KELA_TOOLTIP_CRAFTING_STATION_WORNED)), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatHeader"), {customSpacing = 15})
						tooltipInfo:AddSection(headerItemsAvailabled)	
						for k1,v1 in pairs(tblResearchableItemsWorned[control.craftingType][itemCraftType][control.researchLineIndex][row.traitType]) do
							local iconBag, _, iconLocked = KelaPadUI:GetBagInfo(v1, 24)
							local statItemTypeSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
							local statItemType = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
							statItemType:SetStat(tostring(v1), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatLowercase"))
							statItemType:SetValue(iconLocked.." "..iconBag, tooltipInfo:GetStyle("InfoTooltipStatValuePairValue")) 
							statItemTypeSection:AddStatValuePair(statItemType)
							tooltipInfo:AddSection(statItemTypeSection)							
						end		
					end	
					if tblResearchableItemsLocked then
						local tooltipInfo = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)	
						local headerItemsAvailabled = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
						headerItemsAvailabled:AddLine(colors.COLOR_ORANGE:Colorize(GetString(KELA_TOOLTIP_CRAFTING_STATION_LOCKED)), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatHeader"), {customSpacing = 15})
						tooltipInfo:AddSection(headerItemsAvailabled)	
						for k1,v1 in pairs(tblResearchableItemsLocked[control.craftingType][itemCraftType][control.researchLineIndex][row.traitType]) do
							local iconBag, _, iconLocked = KelaPadUI:GetBagInfo(v1, 24)
							local statItemTypeSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
							local statItemType = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
							statItemType:SetStat(tostring(v1), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatLowercase"))
							statItemType:SetValue(iconLocked.." "..iconBag, tooltipInfo:GetStyle("InfoTooltipStatValuePairValue")) 
							statItemTypeSection:AddStatValuePair(statItemType)
							tooltipInfo:AddSection(statItemTypeSection)							
						end		
					end	
					if tblResearchableItemsFree then
						local tooltipInfo = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)	
						local headerItemsAvailabled = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
						headerItemsAvailabled:AddLine(colors.COLOR_WHITE:Colorize(GetString(KELA_TOOLTIP_CRAFTING_STATION_FREE)), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatHeader"), {customSpacing = 15})
						tooltipInfo:AddSection(headerItemsAvailabled)	
						for k1,v1 in pairs(tblResearchableItemsFree[control.craftingType][itemCraftType][control.researchLineIndex][row.traitType]) do
							local iconBag, _, iconLocked = KelaPadUI:GetBagInfo(v1, 24)
							local statItemTypeSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
							local statItemType = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
							statItemType:SetStat(tostring(v1), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatLowercase"))
							statItemType:SetValue(iconLocked.." "..iconBag, tooltipInfo:GetStyle("InfoTooltipStatValuePairValue")) 
							statItemTypeSection:AddStatValuePair(statItemType)
							tooltipInfo:AddSection(statItemTypeSection)							
						end		
					end						
				end
			end
		end
	-- local ret = OldZO_GamepadSmithingResearchSetupTooltip(control, row, ...)
	-- return ret					
	end

	-- диалог отмены исследования
	local OldZO_GamepadSmithingResearchInitializeConfirmDestroyDialog = ZO_GamepadSmithingResearch.InitializeConfirmDestroyDialog
	ZO_GamepadSmithingResearch.InitializeConfirmDestroyDialog = function(control, ...) 
		local function ReleaseDialog()
			ZO_Dialogs_ReleaseDialogOnButtonPress(ZO_GAMEPAD_CONFIRM_CANCEL_RESEARCH_DIALOG)
		end

		ZO_Dialogs_RegisterCustomDialog(ZO_GAMEPAD_CONFIRM_CANCEL_RESEARCH_DIALOG,
		{
			blockDialogReleaseOnPress = true,
			canQueue = true,

			gamepadInfo = 
			{
				dialogType = GAMEPAD_DIALOGS.BASIC,
				allowRightStickPassThrough = true,
			},

			setup = function(dialog)
				control.destroyConfirmText = nil
				dialog:setupFunc()
			end,

			title =
			{
				text = SI_CRAFTING_CONFIRM_CANCEL_RESEARCH_TITLE,
			},

			mainText = 
			{
				text = SI_GAMEPAD_CRAFTING_CONFIRM_CANCEL_RESEARCH_DESCRIPTION,
			},
		  
			buttons =
			{
				{
					onShowCooldown = 2000,
					keybind = "DIALOG_PRIMARY",
					text = GetString(SI_YES),
					callback = function(dialog)
						-- KelaPostMsg("ZO_GAMEPAD_CONFIRM_CANCEL_RESEARCH_DIALOG")
						local data = dialog.data
						CancelSmithingTraitResearch(data.craftingType, data.researchLineIndex, data.traitIndex)
						KelaPadUI_OnResearchCanseled(EVENT_SMITHING_TRAIT_RESEARCH_CANCELED, data.craftingType, data.researchLineIndex, data.traitIndex)
						ReleaseDialog()
					end,
				},
				{
					keybind = "DIALOG_NEGATIVE",
					text = GetString(SI_NO),
					callback = function()
						ReleaseDialog()
					end,
				},
			}
		})
		
		-- local ret = OldZO_GamepadSmithingResearchInitializeConfirmDestroyDialog(control, ...) 	
		-- return ret	
	end

	-- настройка диалогового окна для заблокированного предмета
	local OldZO_GamepadSmithingResearchInitializeKeybindStripDescriptors = ZO_GamepadSmithingResearch.InitializeKeybindStripDescriptors
	ZO_GamepadSmithingResearch.InitializeKeybindStripDescriptors = function(control, ...) 
		control.keybindStripDescriptor =
		{
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			-- Perform research
			{
				keybind = "UI_SHORTCUT_PRIMARY",
				name = function()
					return GetString(SI_ITEM_ACTION_RESEARCH)
				end,
				callback = function()
					control:Research()
				end,
				enabled = function()
					if not ZO_CraftingUtils_IsPerformingCraftProcess() then
						return control:IsResearchable()
					end
				end
			},
			-- Cancel research
			{
				keybind = "UI_SHORTCUT_SECONDARY",
				name = function()
					return GetString(SI_CRAFTING_CANCEL_RESEARCH)
				end,
				callback = function()
					control:CancelResearch()
				end,
				visible = function()
					if not ZO_CraftingUtils_IsPerformingCraftProcess() then
						return control:CanCancelResearch()
					end
				end
			},
		}
		
		ZO_Gamepad_AddBackNavigationKeybindDescriptors(control.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON)
		ZO_CraftingUtils_ConnectKeybindButtonGroupToCraftingProcess(control.keybindStripDescriptor)
		
		local function ConfirmResearch()
			local targetData = control.confirmList:GetTargetData()
			if targetData then
				local bagId = targetData.bagId
				local slotIndex = targetData.slotIndex
				local _, _, _, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(control.confirmCraftingType, control.confirmResearchLineIndex)
				local formattedTime = ZO_FormatTime(timeRequiredForNextResearchSecs, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
				if IsItemPlayerLocked(bagId, slotIndex)	and GetItemTraitInformation(bagId, slotIndex) ~= ITEM_TRAIT_INFORMATION_RETRAITED then
					ZO_Dialogs_ShowGamepadDialog("KPUI_GAMEPAD_CONFIRM_RESEARCH_BLOCKED_ITEM", { bagId = targetData.bagId, slotIndex = targetData.slotIndex, owner = control }, { mainTextParams = { formattedTime }})
				else
					ZO_Dialogs_ShowGamepadDialog("GAMEPAD_CONFIRM_RESEARCH_ITEM", { bagId = targetData.bagId, slotIndex = targetData.slotIndex, owner = control }, { mainTextParams = { formattedTime }})
				end
			end
		end
		
		-- Confirm research keybind descriptor.
		control.confirmKeybindStripDescriptor =
		{
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			{
				keybind = "UI_SHORTCUT_PRIMARY",
				name = GetString(SI_SMITHING_RESEARCH_DIALOG_CONFIRM),
				callback = ConfirmResearch,
				sound = SOUNDS.SMITHING_START_RESEARCH,
			},
		}
		ZO_Gamepad_AddBackNavigationKeybindDescriptors(control.confirmKeybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON)
		-- local ret = OldZO_GamepadSmithingResearchInitializeKeybindStripDescriptors(control, ...) 	
		-- return ret	 		
	end

	-- add locked icon in confirm research list
	local OldZO_GamepadSmithingResearchInitializeConfirmList = ZO_GamepadSmithingResearch.InitializeConfirmList
	ZO_GamepadSmithingResearch.InitializeConfirmList = function(control, ...) 
		local CONFIRM_TEMPLATE_NAME = "ZO_GamepadSubMenuEntryTemplate"
		control.confirmList = ZO_GamepadVerticalItemParametricScrollList:New(control.panelContent:GetNamedChild("Confirm"):GetNamedChild("List"))
		control.confirmList:SetAlignToScreenCenter(true)
		control.confirmList:AddDataTemplate(CONFIRM_TEMPLATE_NAME, ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "Entry")

		-- add locked icon		
		local function kelaOnTargetDataChanged(list, selectedData)
			local numData = #list.dataList
			for i = 1, numData do
				local dataTypes = ZO_ScrollList_GetDataTypeTable(list, CONFIRM_TEMPLATE_NAME)
				-- KelaPostMsg("dataTypes  "..tostring(dataTypes))					
				if dataTypes then
					local original = dataTypes.setupFunction
					dataTypes.setupFunction = function(control, data, ...)
						original(control, data, ...)
						local c = control:GetNamedChild("kpuiEntryIconV")
						if c then
							c:SetHidden(true)
						end
						if c == nil then
							local label = control:GetNamedChild("Label")
							c = CreateControlFromVirtual("$(parent)kpuiEntryIconV", control, "kpuiEntryIcon")
							c:SetDimensions(32, 32)	
							local w = label:GetWidth()
							--label:SetWidth(w-40)
							c:ClearAnchors() 
							c:SetAnchor(RIGHT, label, LEFT, -71, 0) 
						end
						if c then 
							c:SetHidden(false)
							local tex_locked = c:GetNamedChild("Locked")
							tex_locked:SetHidden(true)
							if IsItemPlayerLocked(data.bagId, data.slotIndex) then
								tex_locked:SetHidden(false)
								tex_locked:SetColor(255, 255, 255)								
							else
								c:SetHidden(true)
							end
						end
					end
				end					
			end	
		end
		
		local function OnEntryChanged(list, selectedData)
			if selectedData then
				GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, selectedData.bagId, selectedData.slotIndex)
				if selectedData.isEquippedInCurrentCategory or selectedData.isEquippedInAnotherCategory then
					GAMEPAD_TOOLTIPS:SetStatusLabelText(GAMEPAD_LEFT_TOOLTIP, GetString(SI_GAMEPAD_EQUIPPED_ITEM_HEADER))
					control:UpdateTooltipEquippedIndicatorText(control.selectedEquippedIndicator, selectedData.slotIndex)
				else
					GAMEPAD_TOOLTIPS:ClearStatusLabel(GAMEPAD_LEFT_TOOLTIP)
				end
			else
				GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
			end
		end
		
		control.confirmList:SetOnTargetDataChangedCallback(kelaOnTargetDataChanged)		
		control.confirmList:SetOnSelectedDataChangedCallback(OnEntryChanged)

		ZO_Gamepad_AddListTriggerKeybindDescriptors(control.confirmKeybindStripDescriptor, control.confirmList)
		-- local ret = OldZO_GamepadSmithingResearchInitializeConfirmList(control, ...)  	
		-- return ret	 
	end

	-- разрешаем разбирать заблокированные предметы 
	local OldZO_SharedSmithingResearchIsResearchableItem = ZO_SharedSmithingResearch.IsResearchableItem
	ZO_SharedSmithingResearch.IsResearchableItem = function(bagId, slotIndex, craftingType, researchLineIndex, traitIndex) 
		return CanItemBeSmithingTraitResearched(bagId, slotIndex, craftingType, researchLineIndex, traitIndex) and GetItemTraitInformation(bagId, slotIndex) ~= ITEM_TRAIT_INFORMATION_RETRAITED
		-- local ret = OldZO_SharedSmithingResearchIsResearchableItem(bagId, slotIndex, craftingType, researchLineIndex, traitIndex) 	
		-- return ret	 
    end

	-- подсчитывает количество доступных для исследования особеностей в линии исследования
	local OldZO_SharedSmithingResearchGenerateResearchTraitCounts = ZO_SharedSmithingResearch.GenerateResearchTraitCounts
	ZO_SharedSmithingResearch.GenerateResearchTraitCounts = function(control, virtualInventoryList, craftingType, researchLineIndex, numTraits, ...) 
		local counts
		local tableTraitIndexes = KelaPadUI:GetTableTraitIndexResearchableItems(craftingType, researchLineIndex)
		if tableTraitIndexes then 
			for k, v in pairs(tableTraitIndexes[craftingType][researchLineIndex]) do
				counts = counts or {}
				counts[k] = (counts[k] or 0) + 1
			end
		end
		return counts
		-- local ret = OldZO_GamepadInventoryRefreshItemList(control, ...) 	
		-- return ret	
	end

end

-- собираем таблицу предметов, возможных к разбору и изучению
function KelaPadUI:InitializeResearchableItems(OnAddonLoaded)
	kpuiSV["ResearchableItemsInBags"] = nil
	kpuiSV["ResearchableItemsInBags"] = {}	
	--if OnAddonLoaded then
	--
	--else
		--KelaPostMsg ("KelaPadUI:InitializeResearchableItems")
		for _,bagId in ipairs(kpuiConst.Bags["ALL_CRAFTING_INVENTORY_BAGS_AND_WORN"]) do
			for slotIndex = 0, GetBagSize(bagId) do
				local itemLink = GetItemLink(bagId, slotIndex)
				if KelaPadUI:GetItemLinkResearchStatus(itemLink) == TRAIT_RESEARCHABLE then
					local _,_,_,_,_, otherEquipType = GetItemInfo(bagId, slotIndex)
					local equipType = GetItemLinkEquipType(itemLink)	
					if otherEquipType == equipType then	
						local uniqueId = GetItemUniqueId(bagId, slotIndex)
						local name = GetItemLinkName(itemLink)
						local smithingType = KelaPadUI:GetSmithingType(bagId, slotIndex)
						local craftItemType = KelaPadUI:GetitemCraftType(itemLink)
						local researchLineIndex = KelaPadUI:ItemToResearchLineIndex(itemLink)
						local traitType = GetItemLinkTraitInfo(itemLink)
						setValueIfNil(kpuiSV["ResearchableItemsInBags"], uniqueId, {})
						kpuiSV["ResearchableItemsInBags"][uniqueId] = {
							["itemSmithingType"] = smithingType, 
							["itemCraftType"] = craftItemType, 
							["itemResearchLineIndex"] = researchLineIndex, 
							["itemTraitType"] = traitType,
							["itembagId"] = bagId,
							["itemSlotIndex"] = slotIndex,
							["itemItemLink"] = itemLink,
							["itemName"] = name,
							}
					end	
				end
			end		
		end	
	--end
end		

-- получаем ступенчатую таблицу
function KelaPadUI:GetTableResearchableItems(smithingType)
	--KelaPostMsg ("KelaPadUI:GetTableResearchableItems, smithingType - "..tostring(smithingType))
	local tblResearchableItems = {}
	for _, uniqueId in pairs(kpuiSV["ResearchableItemsInBags"]) do
		--KelaPostMsg ("uniqueId - "..tostring(uniqueId)..", [uniqueId[itemSmithingType]] - "..tostring(uniqueId["itemSmithingType"]))
		if uniqueId["itemSmithingType"] == smithingType or smithingType == nil then
			setValueIfNil(tblResearchableItems, uniqueId["itemSmithingType"], {})
			setValueIfNil(tblResearchableItems[uniqueId["itemSmithingType"]], uniqueId["itemCraftType"], {})
			setValueIfNil(tblResearchableItems[uniqueId["itemSmithingType"]][uniqueId["itemCraftType"]], uniqueId["itemResearchLineIndex"], {})
			setValueIfNil(tblResearchableItems[uniqueId["itemSmithingType"]][uniqueId["itemCraftType"]][uniqueId["itemResearchLineIndex"]], uniqueId["itemTraitType"], {})
			table.insert(tblResearchableItems[uniqueId["itemSmithingType"]][uniqueId["itemCraftType"]][uniqueId["itemResearchLineIndex"]][uniqueId["itemTraitType"]], uniqueId["itemItemLink"])
		end
	end	
	return tblResearchableItems	
end

-- получаем ступенчатую таблицу с индексами особенностей
function KelaPadUI:GetTableTraitIndexResearchableItems(smithingType, researchLineIndex)
	if smithingType and researchLineIndex then
		local tblTraitIndex = {}
		setValueIfNil(tblTraitIndex, smithingType, {})
		setValueIfNil(tblTraitIndex[smithingType], researchLineIndex, {})
		local count = 0
		for _, uniqueId in pairs(kpuiSV["ResearchableItemsInBags"]) do
			if uniqueId["itemSmithingType"] == smithingType and uniqueId["itemResearchLineIndex"] == researchLineIndex then
				setValueIfNil(tblTraitIndex[smithingType][researchLineIndex], KelaPadUI:ItemToTraitIndex(uniqueId["itemTraitType"]), {})
				count = count + 1
			end
		end
		if count == 0 then tblTraitIndex = nil end
		return tblTraitIndex
	end
	return nil, nil, nil	
end

-- получаем ступенчатую таблицу по сумкам
function KelaPadUI:GetTableResearchableItemsByTrait(smithingType, itemCraftType, researchLineIndex, traitType)
	--KelaPostMsg ("KelaPadUI:GetTableResearchableItems, smithingType - "..tostring(smithingType))
	if smithingType and itemCraftType and researchLineIndex and traitType then
		local tblResearchableItemsWorned = {}
		setValueIfNil(tblResearchableItemsWorned, smithingType, {})
		setValueIfNil(tblResearchableItemsWorned[smithingType], itemCraftType, {})
		setValueIfNil(tblResearchableItemsWorned[smithingType][itemCraftType], researchLineIndex, {})
		setValueIfNil(tblResearchableItemsWorned[smithingType][itemCraftType][researchLineIndex], traitType, {})
		local tblResearchableItemsLocked = {}
		setValueIfNil(tblResearchableItemsLocked, smithingType, {})
		setValueIfNil(tblResearchableItemsLocked[smithingType], itemCraftType, {})
		setValueIfNil(tblResearchableItemsLocked[smithingType][itemCraftType], researchLineIndex, {})
		setValueIfNil(tblResearchableItemsLocked[smithingType][itemCraftType][researchLineIndex], traitType, {})
		local tblResearchableItemsFree = {}
		setValueIfNil(tblResearchableItemsFree, smithingType, {})
		setValueIfNil(tblResearchableItemsFree[smithingType], itemCraftType, {})
		setValueIfNil(tblResearchableItemsFree[smithingType][itemCraftType], researchLineIndex, {})
		setValueIfNil(tblResearchableItemsFree[smithingType][itemCraftType][researchLineIndex], traitType, {})
		local countWorned = 0
		local countLocked = 0
		local countFree = 0
		for _, uniqueId in pairs(kpuiSV["ResearchableItemsInBags"]) do
			if uniqueId["itemSmithingType"] == smithingType and uniqueId["itemCraftType"] == itemCraftType and uniqueId["itemResearchLineIndex"] == researchLineIndex and uniqueId["itemTraitType"] == traitType then
				if uniqueId["itembagId"] == BAG_WORN then
					table.insert(tblResearchableItemsWorned[smithingType][itemCraftType][researchLineIndex][traitType], uniqueId["itemItemLink"])
					countWorned = countWorned + 1
				elseif IsItemPlayerLocked(uniqueId["itembagId"], uniqueId["itemSlotIndex"]) then
					table.insert(tblResearchableItemsLocked[smithingType][itemCraftType][researchLineIndex][traitType], uniqueId["itemItemLink"])
					countLocked = countLocked + 1
				else
					table.insert(tblResearchableItemsFree[smithingType][itemCraftType][researchLineIndex][traitType], uniqueId["itemItemLink"])
					countFree = countFree + 1
				end
			end
		end
		if countWorned == 0 then tblResearchableItemsWorned = nil end
		if countLocked == 0 then tblResearchableItemsLocked = nil end
		if countFree == 0 then tblResearchableItemsFree = nil end
		return tblResearchableItemsWorned, tblResearchableItemsLocked, tblResearchableItemsFree	
	end
	return nil, nil, nil	
end

-- обрабатываем добавление
function KelaPadUI:AddResearchableItem(bagId, slotIndex)
	--KelaPostMsg ("AddResearchableItems - "..tostring(GetItemLink(bagId, slotIndex)))
	local itemLink = GetItemLink(bagId, slotIndex)
	local _,_,_,_,_, otherEquipType = GetItemInfo(bagId, slotIndex)
	local equipType = GetItemLinkEquipType(itemLink)	
	if otherEquipType == equipType then	
		local uniqueId = GetItemUniqueId(bagId, slotIndex)
		local name = GetItemLinkName(itemLink)
		local smithingType = KelaPadUI:GetSmithingType(bagId, slotIndex)
		local craftItemType = KelaPadUI:GetitemCraftType(itemLink)
		local researchLineIndex = KelaPadUI:ItemToResearchLineIndex(itemLink)
		local traitType = GetItemLinkTraitInfo(itemLink)
		setValueIfNil(kpuiSV["ResearchableItemsInBags"], uniqueId, {})
		kpuiSV["ResearchableItemsInBags"][uniqueId] = {
			["itemSmithingType"] = smithingType, 
			["itemCraftType"] = craftItemType, 
			["itemResearchLineIndex"] = researchLineIndex, 
			["itemTraitType"] = traitType,
			["itembagId"] = bagId,
			["itemSlotIndex"] = slotIndex,
			["itemItemLink"] = itemLink,
			["itemName"] = name,
			}
		-- KelaPostMsg ("Added - "..tostring(uniqueId).." - "..tostring(name))
	end	
end		

-- обрабатываем удаление
function KelaPadUI:RemoveResearchableItem(uniqueId, name)
	for k,v in pairs(kpuiSV["ResearchableItemsInBags"]) do
		if uniqueId == k then
			kpuiSV["ResearchableItemsInBags"][uniqueId] = nil
			--KelaPostMsg ("Deleted - "..tostring(uniqueId).." - "..tostring(name))
			break
		end
	end
end	




-- тестовая, ищем трейты в сумках
function KelaPadUI:InitializeTrackedSets()
	kpuiSV["ItemsInBackpack"] = nil
	kpuiSV["ItemsInBackpack"] = {}	
	for _,bagId in ipairs(kpuiConst.Bags["ALL_CRAFTING_INVENTORY_BAGS_AND_WORN"]) do
		for slotIndex = 0, GetBagSize(bagId) do
			local itemLink = GetItemLink(bagId, slotIndex)
			local uniqueId = GetItemUniqueId(bagId, slotIndex)
			local name = GetItemLinkName(itemLink)
			-- local smithingType = KelaPadUI:GetSmithingType(bagId, slotIndex)
			-- local craftItemType = KelaPadUI:GetitemCraftType(itemLink)
			-- local researchLineIndex = KelaPadUI:ItemToResearchLineIndex(itemLink)
			-- local traitType = GetItemLinkTraitInfo(itemLink)
			if uniqueId then
				setValueIfNil(kpuiSV["ItemsInBackpack"], uniqueId, {})
				kpuiSV["ItemsInBackpack"][uniqueId] = {
					-- ["itemSmithingType"] = smithingType, 
					-- ["itemCraftType"] = craftItemType, 
					-- ["itemResearchLineIndex"] = researchLineIndex, 
					-- ["itemTraitType"] = traitType,
					-- ["itembagId"] = bagId,
					-- ["itemSlotIndex"] = slotIndex,
					["itemItemLink"] = itemLink,
					["itemName"] = name,
				}
			end	
		end
	end		
end	







