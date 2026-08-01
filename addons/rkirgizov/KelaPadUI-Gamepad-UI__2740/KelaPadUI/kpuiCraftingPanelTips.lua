local colors = kpuiConst.Colors	

-- Строки списка
KPUI_CRAFTING_PANEL_ROW_LIST_CRAFTING_SETS = 1
KPUI_CRAFTING_PANEL_ROW_LIST_ALCHEMY_RECIPES = 2
KPUI_CRAFTING_PANEL_ROW_LIST_ENCHANTING = 3

kelaIsCraftingTooltipOpened = false

kelaFocusCraftingPanelList = {}

kelaCurrentFocusCraftingPanelIndex = nil

function kelaDeleteCraftingPanel()
	kelaFocusCraftingPanelList:SetActive(false, false)
	kelaIsCraftingTooltipOpened = false
	RemoveButtonsCraftingPanel()
	KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_WIDE_CRAFTING_TOOLTIP)
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_WIDE_CRAFTING_TOOLTIP))
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_WIDE_CRAFTING_TOOLTIP))
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_RIGHT_TOOLTIP))
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_RIGHT_TOOLTIP))
	local targetData = GAMEPAD_STATS.mainList:GetTargetData()
	if targetData.displayMode ~= GAMEPAD_STATS_DISPLAY_MODE.RESEARCH and targetData.displayMode ~= GAMEPAD_STATS_DISPLAY_MODE.CRAFTING then
		KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
	end
end

-- кнопки панели ремёсел
KelaPadUI.ButtonsCraftingPanel = {}
KelaPadUI.ButtonsCraftingPanel = {
	{
	name = 	function ()
		local targetData = GAMEPAD_STATS.mainList:GetTargetData()
		if targetData.displayMode == GAMEPAD_STATS_DISPLAY_MODE.CRAFTING then
			return GetString(KELA_STAT_GAMEPAD_CRAFTING_PANEL_BACK)	
		end
	end,
	alignment = KEYBIND_STRIP_ALIGN_CENTER,	
	keybind = "UI_SHORTCUT_INPUT_LEFT",
	visible = function()
		local targetData = GAMEPAD_STATS.mainList:GetTargetData()
		if targetData.displayMode == GAMEPAD_STATS_DISPLAY_MODE.CRAFTING then
			return kelaFocusCraftingPanelList:IsActive()
		end
	end,
	callback = function()
		if kelaFocusCraftingPanelList:GetFocus() == KPUI_CRAFTING_PANEL_ROW_LIST_CRAFTING_SETS then -- активирована кнопка сетов
				kelaFocusCraftingPanelList:SetActive(false, false)
					
		elseif kelaFocusCraftingPanelList:IsActive() then
			kelaFocusCraftingPanelList:SetActive(false, false)
		end
		RefreshButtonsCraftingPanel()
	end,
	sound = SOUNDS.GAMEPAD_MENU_FORWARD,
	},
	{
	name = 	function ()
		local targetData = GAMEPAD_STATS.mainList:GetTargetData()
		if targetData.displayMode == GAMEPAD_STATS_DISPLAY_MODE.CRAFTING then
			if kelaCurrentFocusCraftingPanelIndex == KPUI_CRAFTING_PANEL_ROW_LIST_CRAFTING_SETS then -- активирована кнопка сетов

			elseif kelaFocusCraftingPanelList:IsActive() then
				return "Under construction"
			else
				return GetString(KELA_STAT_GAMEPAD_CRAFTING_PANEL_TO_MAINLIST)
			end
		end
	end,
	alignment = KEYBIND_STRIP_ALIGN_CENTER,	
	keybind = "UI_SHORTCUT_INPUT_RIGHT",
	visible = function()
		local targetData = GAMEPAD_STATS.mainList:GetTargetData()
		if targetData.displayMode == GAMEPAD_STATS_DISPLAY_MODE.CRAFTING then
		end
	end,
	callback = function()
		if kelaFocusCraftingPanelList:GetFocus() == KPUI_CRAFTING_PANEL_ROW_LIST_CRAFTING_SETS then -- активирована кнопка сетов

		elseif kelaFocusCraftingPanelList:IsActive() then
		
		else
			kelaFocusCraftingPanelList:SetActive(true, false)
		end
		RefreshButtonsCraftingPanel()
	end,
	sound = SOUNDS.GAMEPAD_MENU_FORWARD,
	},
}
function InitializeButtonsCraftingPanel()
	KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.ButtonsCraftingPanel)
end
function RemoveButtonsCraftingPanel()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.ButtonsCraftingPanel)
end
function RefreshButtonsCraftingPanel()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.ButtonsCraftingPanel)
	KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.ButtonsCraftingPanel)
end






function kelaInitializeInfoTooltipCraftingMain()

	-- инициализируем таблицу сетов

	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_CRAFTING_TOOLTIP)

	kelaFocusCraftingPanelList = ZO_GamepadFocus:New(tooltipInfo, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)

	local paddingRows = 15
	local numRows = 3
	for i = 1, numRows do
		local row
		local rowOld = GetControl(tooltipInfo:GetName().."rowList"..i)
		if rowOld then
			row = rowOld
		else
			row  = KPUI_GamepadTooltip:CreateRowMainList(tooltipInfo, nil, i)		
		end
		
		local rowPrevious = GetControl(tooltipInfo:GetName().."rowList"..(i - 1))
		if rowPrevious then
			row.rowHeader:SetAnchor(TOPLEFT, rowPrevious.rowHeader, BOTTOMLEFT, 0, paddingRows)	
			row.rowHeader:SetAnchor(BOTTOMRIGHT, rowPrevious.rowHeader, BOTTOMRIGHT, 0, paddingRows + 45)	
		else
			row.rowHeader:SetAnchor(TOPLEFT, row.divider, BOTTOMLEFT, 0, paddingRows + 10)	
			row.rowHeader:SetAnchor(BOTTOMRIGHT, row.divider, BOTTOMRIGHT, 0, paddingRows + 55)	
		end		
		
		row.rowHeader:SetText (GetString("KELA_STAT_GAMEPAD_CRAFTING_PANEL_ROW_LIST", i))				
		
		if i == 1 then 
			row.divider:SetHidden(false)
		end

		local rowHighlightOld = GetControl(tooltipInfo:GetName().."rowListHighlight"..i)
		if rowHighlightOld then
			rowHighlight = rowHighlightOld
		else
			rowHighlight = CreateControlFromVirtual("$(parent)rowListHighlight", tooltipInfo, "KPUI_TraitLabelHighlight", i)
			rowHighlight:SetAnchor(TOPLEFT, row.rowHeader, TOPLEFT, 0, -10)
			rowHighlight:SetAnchor(BOTTOMRIGHT, row.rowHeader, BOTTOMRIGHT, 0, 3)
		end	

		-- KPUI_CRAFTING_PANEL_ROW_LIST_CRAFTING_SETS = 1
		-- KPUI_CRAFTING_PANEL_ROW_LIST_ALCHEMY_RECIPES = 2
		-- KPUI_CRAFTING_PANEL_ROW_LIST_ENCHANTING = 3		
		local kelaFocusCraftingPanelListData = 
		{
			highlight = rowHighlight,
			control = row.rowHeader,
			data = {
				rowIndex = i,
				rowFocusControl = kelaFocusCraftingPanelList
			},
			activate = function(control, data)
				kelaCurrentFocusCraftingPanelIndex = data.rowIndex
				RefreshButtonsCraftingPanel()
			end,
			deactivate = function(control, data) 
				kelaCurrentFocusCraftingPanelIndex = nil
				RefreshButtonsCraftingPanel()
			end,
		}

		kelaFocusCraftingPanelList:AddEntry(kelaFocusCraftingPanelListData)	

	end
	
end



