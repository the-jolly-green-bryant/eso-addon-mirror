local colors = kpuiConst.Colors	
local setsCrafting = kpuiConst.SetsCrafting
local setsOverland = kpuiConst.SetsOverland
local setsDungeon = kpuiConst.SetsDungeon
local setsMonster = kpuiConst.SetsMonster

-- Строки списка
KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS = 1
KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS = 2
KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS = 3
KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS = 4

kelaIsInfoTooltipSetsAnchorsSet = false
kelaIsSetsTooltipOpened = false
kelaFocusSetsPanelList = {}
kelaCurrentFocusSetsPanelIndex = nil

kelaCraftingSetsPanelIsInitialize = false
kelaCurrentFocusCraftingSetPanel = nil
kelaIndexCraftingSetPanel = 2
kelaFocusCraftingSetPanel = {}

kelaOverlandSetsPanelIsInitialize = false
kelaCurrentFocusOverlandSetPanel = nil
kelaCountOverlandSetPanel = 0
kelaIndexOverlandSetPanel = 1
kelaFocusOverlandSetPanel = {}

kelaDungeonSetsPanelIsInitialize = false
kelaCurrentFocusDungeonSetPanel = nil
kelaCountDungeonSetPanel = 0
kelaIndexDungeonSetPanel = 1
kelaFocusDungeonSetPanel = {}

kelaMonsterSetsPanelIsInitialize = false
kelaCurrentFocusMonsterSetPanel = nil
kelaCountMonsterSetPanel = 0
kelaIndexMonsterSetPanel = 1
kelaFocusMonsterSetPanel = {}

function KelaPadUI:GetSets(setsType)
	if setsType == KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS then
		return setsCrafting
	elseif	setsType == KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS then
		return setsOverland
	elseif	setsType == KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS then
		return setsDungeon
	elseif	setsType == KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS then
		return setsMonster
	end
end
function KelaPadUI:GetSet(setsType, index)
	if setsType == KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS then
		return setsCrafting[index]
	elseif	setsType == KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS then
		return setsOverland[index]
	elseif	setsType == KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS then
		return setsDungeon[index]
	elseif	setsType == KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS then
		return setsMonster[index]
	end
end
local function SortByName(t, a, b)
	return t[a].name < t[b].name
end

function kelaDeleteSetsPanel()
	kelaFocusSetsPanelList:SetActive(false, false)
	if kelaCurrentFocusCraftingSetPanel then 
		kelaCurrentFocusCraftingSetPanel:SetActive(false, false) 
	end
	if kelaCurrentFocusOverlandSetPanel then 
		kelaCurrentFocusOverlandSetPanel:SetActive(false, false) 
	end
	if kelaCurrentFocusDungeonSetPanel then 
		kelaCurrentFocusDungeonSetPanel:SetActive(false, false) 
	end
	if kelaCurrentFocusMonsterSetPanel then 
		kelaCurrentFocusMonsterSetPanel:SetActive(false, false) 
	end
	kelaIsSetsTooltipOpened = false
	RemoveButtonsSetsPanel()
	RemoveButtonsCraftingSets()
	RemoveButtonsOverlandSets()
	RemoveButtonsDungeonSets()
	RemoveButtonsMonsterSets()
	KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	KPUI_GAMEPAD_TOOLTIPS:ClearContentHeader(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_RIGHT_TOOLTIP))
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_RIGHT_TOOLTIP))
	local targetData = GAMEPAD_STATS.mainList:GetTargetData()
	if targetData.displayMode ~= GAMEPAD_STATS_DISPLAY_MODE.RESEARCH and targetData.displayMode ~= GAMEPAD_STATS_DISPLAY_MODE.CRAFTING and targetData.displayMode ~= GAMEPAD_STATS_DISPLAY_MODE.SETS then			
		KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
	end
end

-- основные кнопки панели сетов 
KelaPadUI.ButtonsSetsPanel = {}
KelaPadUI.ButtonsSetsPanel = {
	{
	name = 	function ()
		local targetData = GAMEPAD_STATS.mainList:GetTargetData()
		if targetData.displayMode == GAMEPAD_STATS_DISPLAY_MODE.SETS then
			return GetString(KELA_STAT_GAMEPAD_SETS_PANEL_BACK)	
		end
	end,
	alignment = KEYBIND_STRIP_ALIGN_CENTER,	
	keybind = "UI_SHORTCUT_INPUT_LEFT",
	visible = function()
		local targetData = GAMEPAD_STATS.mainList:GetTargetData()
		if targetData.displayMode == GAMEPAD_STATS_DISPLAY_MODE.SETS then
			return kelaFocusSetsPanelList:IsActive() or kelaCurrentFocusCraftingSetPanel or kelaCurrentFocusOverlandSetPanel or kelaCurrentFocusDungeonSetPanel or kelaCurrentFocusMonsterSetPanel
		end
	end,
	callback = function()
		local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
		local desc = GetControl(tooltipInfo:GetName().."DescSets"..1)

		if kelaFocusSetsPanelList:GetFocus(true) == KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS then -- активирована кнопка сетов
			if kelaGetCurrentCraftingSetsFocusControl():IsActive() then 
				kelaGetCurrentCraftingSetsFocusControl():SetActive(false, false)
				kelaFocusSetsPanelList:SetActive(false, false)
				kelaFocusSetsPanelList:SetActive(true, false)
			else
				KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
				kelaFocusSetsPanelList:SetActive(false, false)
				desc:SetHidden(false)
			end		
		elseif kelaFocusSetsPanelList:GetFocus(true) == KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS then -- активирована кнопка сетов
			if kelaGetCurrentOverlandSetsFocusControl():IsActive() then 
				kelaGetCurrentOverlandSetsFocusControl():SetActive(false, false)
				kelaFocusSetsPanelList:SetActive(false, false)
				kelaFocusSetsPanelList:SetActive(true, false)
			else
				KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
				kelaFocusSetsPanelList:SetActive(false, false)
				desc:SetHidden(false)
			end			
		elseif kelaFocusSetsPanelList:GetFocus(true) == KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS then -- активирована кнопка сетов
			if kelaGetCurrentDungeonSetsFocusControl():IsActive() then 
				kelaGetCurrentDungeonSetsFocusControl():SetActive(false, false)
				kelaFocusSetsPanelList:SetActive(false, false)
				kelaFocusSetsPanelList:SetActive(true, false)
			else
				KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
				kelaFocusSetsPanelList:SetActive(false, false)
				desc:SetHidden(false)
			end			
		elseif kelaFocusSetsPanelList:GetFocus(true) == KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS then -- активирована кнопка сетов
			if kelaGetCurrentMonsterSetsFocusControl():IsActive() then 
				kelaGetCurrentMonsterSetsFocusControl():SetActive(false, false)
				kelaFocusSetsPanelList:SetActive(false, false)
				kelaFocusSetsPanelList:SetActive(true, false)
			else
				KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
				kelaFocusSetsPanelList:SetActive(false, false)
				desc:SetHidden(false)
			end	
		elseif kelaFocusSetsPanelList:IsActive() then
			KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
			kelaFocusSetsPanelList:SetActive(false, false)
			desc:SetHidden(false)
		end
		RefreshButtonsSetsPanel()
	end,
	sound = SOUNDS.GAMEPAD_MENU_FORWARD,
	},
	{
	name = 	function ()
		local targetData = GAMEPAD_STATS.mainList:GetTargetData()
		if targetData.displayMode == GAMEPAD_STATS_DISPLAY_MODE.SETS then
			if kelaCurrentFocusSetsPanelIndex == KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS then -- активирована кнопка сетов
				if kelaGetCurrentCraftingSetsFocusControl() and not kelaGetCurrentCraftingSetsFocusControl():IsActive() then 
					return GetString(KELA_STAT_GAMEPAD_SETS_PANEL_TO_SETS)
				end	
			elseif kelaCurrentFocusSetsPanelIndex == KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS then -- активирована кнопка сетов
				if kelaGetCurrentOverlandSetsFocusControl() and not kelaGetCurrentOverlandSetsFocusControl():IsActive() then 
					return GetString(KELA_STAT_GAMEPAD_SETS_PANEL_TO_SETS)
				end		
			elseif kelaCurrentFocusSetsPanelIndex == KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS then -- активирована кнопка сетов
				if kelaGetCurrentDungeonSetsFocusControl() and not kelaGetCurrentDungeonSetsFocusControl():IsActive() then 
					return GetString(KELA_STAT_GAMEPAD_SETS_PANEL_TO_SETS)
				end			
			elseif kelaCurrentFocusSetsPanelIndex == KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS then -- активирована кнопка сетов
				if kelaGetCurrentMonsterSetsFocusControl() and not kelaGetCurrentMonsterSetsFocusControl():IsActive() then 
					return GetString(KELA_STAT_GAMEPAD_SETS_PANEL_TO_SETS)
				end		
			elseif kelaFocusSetsPanelList:IsActive() then
				return "Under construction"
			else
				return GetString(KELA_STAT_GAMEPAD_SETS_PANEL_TO_MAINLIST)
			end
		end
	end,
	alignment = KEYBIND_STRIP_ALIGN_CENTER,	
	keybind = "UI_SHORTCUT_INPUT_RIGHT",
	visible = function()
		local targetData = GAMEPAD_STATS.mainList:GetTargetData()
		if targetData.displayMode == GAMEPAD_STATS_DISPLAY_MODE.SETS then
			return not kelaCurrentFocusCraftingSetPanel and not kelaCurrentFocusOverlandSetPanel and not kelaCurrentFocusDungeonSetPanel and not kelaCurrentFocusMonsterSetPanel
		end
	end,
	callback = function()
		local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
		local desc = GetControl(tooltipInfo:GetName().."DescSets"..1)
		
		if kelaFocusSetsPanelList:GetFocus() == KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS then -- активирована кнопка сетов
			if kelaGetCurrentCraftingSetsFocusControl() and not kelaGetCurrentCraftingSetsFocusControl():IsActive() then 
				kelaGetCurrentCraftingSetsFocusControl():SetActive(true, false)
				-- kelaFocusSetsPanelList:SetActive(false, true)
			end		
		elseif kelaFocusSetsPanelList:GetFocus() == KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS then -- активирована кнопка сетов
			if kelaGetCurrentOverlandSetsFocusControl() and not kelaGetCurrentOverlandSetsFocusControl():IsActive() then 
				kelaGetCurrentOverlandSetsFocusControl():SetActive(true, false)
				-- kelaFocusSetsPanelList:SetActive(false, true)
			end		
		elseif kelaFocusSetsPanelList:GetFocus() == KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS then -- активирована кнопка сетов
			if kelaGetCurrentDungeonSetsFocusControl() and not kelaGetCurrentDungeonSetsFocusControl():IsActive() then 
				kelaGetCurrentDungeonSetsFocusControl():SetActive(true, false)
				-- kelaFocusSetsPanelList:SetActive(false, true)
			end		
		elseif kelaFocusSetsPanelList:GetFocus() == KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS then -- активирована кнопка сетов
			if kelaGetCurrentMonsterSetsFocusControl() and not kelaGetCurrentMonsterSetsFocusControl():IsActive() then 
				kelaGetCurrentMonsterSetsFocusControl():SetActive(true, false)
				-- kelaFocusSetsPanelList:SetActive(false, true)
			end				
		elseif kelaFocusSetsPanelList:IsActive() then
		
		else
			kelaFocusSetsPanelList:SetActive(true, false)
			desc:SetHidden(true)
		end
		RefreshButtonsSetsPanel()
	end,
	sound = SOUNDS.GAMEPAD_MENU_FORWARD,
	},
}
function InitializeButtonsSetsPanel()
	KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.ButtonsSetsPanel)
end
function RemoveButtonsSetsPanel()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.ButtonsSetsPanel)
end
function RefreshButtonsSetsPanel()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.ButtonsSetsPanel)
	KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.ButtonsSetsPanel)
end
function kelaInitializeInfoTooltipSetsMainSetAnchors()
	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	local paddingRows = 15
	local numRows = 4
	for i = 1, numRows do
		local row = GetControl(tooltipInfo:GetName().."rowList"..i)
		local rowPrevious = GetControl(tooltipInfo:GetName().."rowList"..(i - 1))
		if rowPrevious then
			row.rowHeader:SetAnchor(TOPLEFT, rowPrevious.rowHeader, BOTTOMLEFT, 0, paddingRows)	
			row.rowHeader:SetAnchor(BOTTOMRIGHT, rowPrevious.rowHeader, BOTTOMRIGHT, 0, paddingRows + 45)	
		else
			row.rowHeader:SetAnchor(TOPLEFT, row.divider, BOTTOMLEFT, 0, paddingRows + 10)	
			row.rowHeader:SetAnchor(BOTTOMRIGHT, row.divider, BOTTOMRIGHT, 0, paddingRows + 55)	
		end		
		rowHighlight = GetControl(tooltipInfo:GetName().."rowListHighlight"..i)
		rowHighlight:SetAnchor(TOPLEFT, row.rowHeader, TOPLEFT, 0, -10)
		rowHighlight:SetAnchor(BOTTOMRIGHT, row.rowHeader, BOTTOMRIGHT, 0, 3)
	end
	
end
function kelaInitializeInfoTooltipSetsMain()

	-- инициализируем таблицу крафтовых сетов
	for i,set in pairs(setsCrafting) do
		local itemLink = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,set.itemId,30,1,0,0,0,0,0,0,0,0,0,0,0,0,ITEMSTYLE_RACIAL_BRETON,0,0,0,10000,0)
		local _, setName, numBonuses, _, _, _ = GetItemLinkSetInfo(itemLink, false)
		set.name = zo_strformat("<<1>>",setName)
		set.numBonuses = numBonuses
		for k,location in pairs(set.locations) do
			location.alliance = kelaGetAlliance(location.zoneId)
		end
	end
	-- инициализируем таблицу сетов локаций
	for i,set in pairs(setsOverland) do
		local itemLink = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,set.itemId,30,1,0,0,0,0,0,0,0,0,0,0,0,0,ITEMSTYLE_RACIAL_BRETON,0,0,0,10000,0)
		local _, setName, numBonuses, _, _, _ = GetItemLinkSetInfo(itemLink, false)
		set.name = zo_strformat("<<1>>",setName)
		set.numBonuses = numBonuses
		for k,location in pairs(set.locations) do
			location.alliance = kelaGetAlliance(location.zoneId)
		end
	end
	-- инициализируем таблицу сетов локаций
	for i,set in pairs(setsDungeon) do
		local itemLink = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,set.itemId,30,1,0,0,0,0,0,0,0,0,0,0,0,0,ITEMSTYLE_RACIAL_BRETON,0,0,0,10000,0)
		local _, setName, numBonuses, _, _, _ = GetItemLinkSetInfo(itemLink, false)
		set.name = zo_strformat("<<1>>",setName)
		set.numBonuses = numBonuses
		for k,location in pairs(set.locations) do
			location.alliance = kelaGetAlliance(location.zoneId)
		end
	end
	-- инициализируем таблицу сетов локаций
	for i,set in pairs(setsMonster) do
		local itemLink = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,set.itemId,30,1,0,0,0,0,0,0,0,0,0,0,0,0,ITEMSTYLE_RACIAL_BRETON,0,0,0,10000,0)
		local _, setName, numBonuses, _, _, _ = GetItemLinkSetInfo(itemLink, false)
		set.name = zo_strformat("<<1>>",setName)
		set.numBonuses = numBonuses
		for k,location in pairs(set.locations) do
			location.alliance = kelaGetAlliance(location.zoneId)
		end
	end

	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)

	kelaFocusSetsPanelList = ZO_GamepadFocus:New(tooltipInfo, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)

	local paddingRows = 15
	local numRows = 4
	for i = 1, numRows do
		local row
		local rowOld = GetControl(tooltipInfo:GetName().."rowList"..i)
		if rowOld then
			row = rowOld
		else
			row  = KPUI_GamepadTooltip:CreateRowMainList(tooltipInfo, nil, i)		
		end
		
		-- local rowPrevious = GetControl(tooltipInfo:GetName().."rowList"..(i - 1))
		-- if rowPrevious then
			-- row.rowHeader:SetAnchor(TOPLEFT, rowPrevious.rowHeader, BOTTOMLEFT, 0, paddingRows)	
			-- row.rowHeader:SetAnchor(BOTTOMRIGHT, rowPrevious.rowHeader, BOTTOMRIGHT, 0, paddingRows + 45)	
		-- else
			-- row.rowHeader:SetAnchor(TOPLEFT, row.divider, BOTTOMLEFT, 0, paddingRows + 10)	
			-- row.rowHeader:SetAnchor(BOTTOMRIGHT, row.divider, BOTTOMRIGHT, 0, paddingRows + 55)	
		-- end		
		
		row.rowHeader:SetText (GetString("KELA_STAT_GAMEPAD_SETS_PANEL_ROW_LIST", i))				
		
		if i == 1 then 
			row.divider:SetHidden(false)
		end

		local rowHighlightOld = GetControl(tooltipInfo:GetName().."rowListHighlight"..i)
		if rowHighlightOld then
			rowHighlight = rowHighlightOld
		else
			rowHighlight = CreateControlFromVirtual("$(parent)rowListHighlight", tooltipInfo, "KPUI_TraitLabelHighlight", i)
			-- rowHighlight:SetAnchor(TOPLEFT, row.rowHeader, TOPLEFT, 0, -10)
			-- rowHighlight:SetAnchor(BOTTOMRIGHT, row.rowHeader, BOTTOMRIGHT, 0, 3)
		end	

		-- KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS = 1
		-- KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS = 2
		-- KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS = 3
		-- KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS = 4	
		local kelaFocusSetsPanelListData = 
		{
			highlight = rowHighlight,
			control = row.rowHeader,
			data = {
				rowIndex = i,
				rowFocusControl = kelaFocusSetsPanelList
			},
			activate = function(control, data)
				if data.rowIndex == 1 then 
					kelaRefreshCraftingSetsPanel(data.rowIndex == KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS)
				elseif data.rowIndex == 2 then
					kelaRefreshOverlandSetsPanel(data.rowIndex == KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS)
				elseif data.rowIndex == 3 then
					kelaRefreshDungeonSetsPanel(data.rowIndex == KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS)
				elseif data.rowIndex == 4 then
					kelaRefreshMonsterSetsPanel(data.rowIndex == KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS)
				end
				KPUI_GAMEPAD_TOOLTIPS:LayoutDescriptionTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP, GetString("KELA_STAT_GAMEPAD_SETS_PANEL_ROW_LIST", data.rowIndex), GetString("KELA_STAT_GAMEPAD_SETS_PANEL_ROW_LIST_DESCRIPTION", data.rowIndex))
				kelaCurrentFocusSetsPanelIndex = data.rowIndex
				RefreshButtonsSetsPanel()
			end,
			deactivate = function(control, data) 
				if data.rowIndex == 1 then 
					kelaRefreshCraftingSetsPanel(false)
				elseif data.rowIndex == 2 then
					kelaRefreshOverlandSetsPanel(false)
				elseif data.rowIndex == 3 then
					kelaRefreshDungeonSetsPanel(false)
				elseif data.rowIndex == 4 then
					kelaRefreshMonsterSetsPanel(false)
				end
				kelaCurrentFocusSetsPanelIndex = nil
				RefreshButtonsSetsPanel()
			end,
		}

		kelaFocusSetsPanelList:AddEntry(kelaFocusSetsPanelListData)	

	end

    -- local bodySection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("bodySection"))	
    -- bodySection:AddLine(GetString(KELA_STAT_GAMEPAD_SETS_SHEET_DESCRIPTIONEXTRA), tooltipInfo:GetStyle("bodyDescription"))
    -- tooltipInfo:AddSection(bodySection)
	local desc
	local descOld = GetControl(tooltipInfo:GetName().."DescSets"..1)
	if descOld then
		desc = descOld
	else
		desc = CreateControlFromVirtual("$(parent)DescSets", tooltipInfo, "KPUI_DescLabel", 1)
		desc:SetAnchor(TOPLEFT, tooltipInfo, TOPLEFT, 330, 27)
		desc:SetAnchor(BOTTOMRIGHT, tooltipInfo, BOTTOMRIGHT, 620, 700)
	end		
	desc:SetText(GetString(KELA_STAT_GAMEPAD_SETS_SHEET_DESCRIPTION_EXTRA))



	if not kelaCraftingSetsPanelIsInitialize then
		for index = 2, 9 do
			kelaInitializeCraftingSetsPanel(index)
			kelaCraftingSetsPanelIsInitialize = true
		end
		kelaIndexCraftingSetPanel = 2
	end
	if not kelaOverlandSetsPanelIsInitialize then
		for index = 1, 8 do
			kelaInitializeOverlandSetsPanel(index)
			kelaOverlandSetsPanelIsInitialize = true
		end
		kelaIndexOverlandSetPanel = 1
	end
	if not kelaDungeonSetsPanelIsInitialize then
		for index = 1, 9 do
			kelaInitializeDungeonSetsPanel(index)
			kelaDungeonSetsPanelIsInitialize = true
		end
		kelaIndexDungeonSetPanel = 1
	end
	if not kelaMonsterSetsPanelIsInitialize then
		for index = 1, 2 do
			kelaInitializeMonsterSetsPanel(index)
			kelaMonsterSetsPanelIsInitialize = true
		end
		kelaIndexMonsterSetPanel = 1
	end
	
end

KelaPadUI.ButtonsCraftingSets = {}
KelaPadUI.ButtonsCraftingSets = {
	{
	keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
	callback = function()
		local currentControl = kelaGetCurrentCraftingSetsFocusControl()
		currentControl:SetActive(false, false)	
		if kelaIndexCraftingSetPanel == 9 then
			kelaIndexCraftingSetPanel = 2
		else
			kelaIndexCraftingSetPanel = kelaIndexCraftingSetPanel + 1
		end
		kelaRefreshCraftingSetsPanel(true)
		local currentControl = kelaGetCurrentCraftingSetsFocusControl()
		currentControl:SetActive(true, false)	
		RefreshButtonsSetsPanel()
	end,
	ethereal = true,
	sound = SOUNDS.GAMEPAD_MENU_FORWARD,
	},
	{
	keybind = "UI_SHORTCUT_LEFT_SHOULDER",
	callback = function()
		local currentControl = kelaGetCurrentCraftingSetsFocusControl()
		currentControl:SetActive(false, false)	
		if kelaIndexCraftingSetPanel == 2 then
			kelaIndexCraftingSetPanel = 9
		else
			kelaIndexCraftingSetPanel = kelaIndexCraftingSetPanel - 1
		end
		kelaRefreshCraftingSetsPanel(true)
		local currentControl = kelaGetCurrentCraftingSetsFocusControl()
		currentControl:SetActive(true, false)	
		RefreshButtonsSetsPanel()
	end,
	ethereal = true,
	sound = SOUNDS.GAMEPAD_MENU_FORWARD,
	},
}
function InitializeButtonsCraftingSets()
	KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.ButtonsCraftingSets)
end
function RemoveButtonsCraftingSets()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.ButtonsCraftingSets)
end
function RefreshButtonsCraftingSets()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.ButtonsCraftingSets)
	KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.ButtonsCraftingSets)
end
function kelaGetCurrentCraftingSetsFocusControl()
	if not kelaFocusCraftingSetPanel.Panel2:IsHidden() then 
		return kelaFocusCraftingSetPanel.Focus2
	elseif not kelaFocusCraftingSetPanel.Panel3:IsHidden() then 
		return kelaFocusCraftingSetPanel.Focus3
	elseif not kelaFocusCraftingSetPanel.Panel4:IsHidden() then 
		return kelaFocusCraftingSetPanel.Focus4
	elseif not kelaFocusCraftingSetPanel.Panel5:IsHidden() then 
		return kelaFocusCraftingSetPanel.Focus5
	elseif not kelaFocusCraftingSetPanel.Panel6:IsHidden() then 
		return kelaFocusCraftingSetPanel.Focus6
	elseif not kelaFocusCraftingSetPanel.Panel7:IsHidden() then 
		return kelaFocusCraftingSetPanel.Focus7
	elseif not kelaFocusCraftingSetPanel.Panel8:IsHidden() then 
		return kelaFocusCraftingSetPanel.Focus8
	elseif not kelaFocusCraftingSetPanel.Panel9:IsHidden() then 
		return kelaFocusCraftingSetPanel.Focus9
	end
	return false
end
function kelaIsCraftingSetsPanelActive()
	if kelaGetCurrentCraftingSetsFocusControl() then 
		return true
	end
	return false
end
function kelaRefreshCraftingSetsPanel(activate)

	

	KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:AddFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:AddFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))	
	
	local title = GetString(KELA_STAT_GAMEPAD_SETS_SHEET_DESCRIPTION)
	local dataHeaderText = ""
	local dataText = ""
	
	KPUI_GAMEPAD_TOOLTIPS:ClearContentHeader(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP)
	KPUI_GAMEPAD_TOOLTIPS:RefreshContentHeader(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP, title, dataHeaderText, dataText)

	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	local controlPanel = GetControl(tooltipInfo:GetName().."CraftingSetsPanel"..1)
	if activate then
		controlPanel.dividerPippedHeader:SetText(GetString("KELA_STAT_GAMEPAD_CRAFTING_PANEL_SETS_TITLE", kelaIndexCraftingSetPanel))
		local PIP_WIDTH = 32 
		local activePipIndex = kelaIndexCraftingSetPanel - 1
		local numPips = 8
		for i = 1, numPips do
			local pip 
			local pipOld = GetControl(tooltipInfo:GetName().."CraftingSetsTabBarPip"..i)
			if pipOld then
				pip = pipOld
			else
				pip = CreateControlFromVirtual("$(parent)CraftingSetsTabBarPip", tooltipInfo, "ZO_GamepadTabBarPip", i)
			end
			pip:SetParent(controlPanel.pipsControl)
			pip:SetAnchor(CENTER, controlPanel.pipsControl, CENTER, (i - 1 - (numPips - 1) / 2) * PIP_WIDTH, 0)
			local active = (activePipIndex == i)
			pip:GetNamedChild("Active"):SetHidden(not active)
			pip:GetNamedChild("Inactive"):SetHidden(active)
		end
		controlPanel.panelPip2:SetHidden(kelaIndexCraftingSetPanel ~= 2)
		controlPanel.panelPip3:SetHidden(kelaIndexCraftingSetPanel ~= 3)
		controlPanel.panelPip4:SetHidden(kelaIndexCraftingSetPanel ~= 4)
		controlPanel.panelPip5:SetHidden(kelaIndexCraftingSetPanel ~= 5)
		controlPanel.panelPip6:SetHidden(kelaIndexCraftingSetPanel ~= 6)
		controlPanel.panelPip7:SetHidden(kelaIndexCraftingSetPanel ~= 7)
		controlPanel.panelPip8:SetHidden(kelaIndexCraftingSetPanel ~= 8)
		controlPanel.panelPip9:SetHidden(kelaIndexCraftingSetPanel ~= 9)
		controlPanel:SetHidden(false)		
		InitializeButtonsCraftingSets()
	else
		controlPanel.panelPip2:SetHidden(true)
		controlPanel.panelPip3:SetHidden(true)
		controlPanel.panelPip4:SetHidden(true)
		controlPanel.panelPip5:SetHidden(true)
		controlPanel.panelPip6:SetHidden(true)
		controlPanel.panelPip7:SetHidden(true)
		controlPanel.panelPip8:SetHidden(true)
		controlPanel.panelPip9:SetHidden(true)	
		controlPanel:SetHidden(true)
		RemoveButtonsCraftingSets()
	end
	
end
function kelaInitializeCraftingSetsPanelSetAnchors(index)

	local craftingSetsPanel, rowSet2, rowSet3, rowSet4, rowSet5, rowSet6, rowSet7, rowSet8, rowSet9
	
	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	
	local controlPanel = GetControl(tooltipInfo:GetName().."CraftingSetsPanel"..1)
	controlPanel.dividerPippedHeader:SetAnchor(TOPLEFT, tooltipInfo, TOPLEFT, 330, -4)
	controlPanel.dividerPippedHeader:SetAnchor(BOTTOMRIGHT, tooltipInfo, BOTTOMRIGHT, 620, 32)	

	local function CreateCraftingSetsList(set, rowSet, panelPip)
		rowSet.rowHeader:SetAnchor(LEFT, rowSet, LEFT, 0)
		rowSet.rowHeader:SetAnchor(RIGHT, rowSet, RIGHT, 0)
		rowSet.rowHeaderValue:SetAnchor(RIGHT, rowSet.rowHeader, RIGHT, 0)		
		local rowSetHighlight = GetControl(tooltipInfo:GetName().."rowSetHighlight"..set.key)
		rowSetHighlight:SetAnchor(TOPLEFT, rowSet.rowHeader, TOPLEFT, -10, -2)
		rowSetHighlight:SetAnchor(BOTTOMRIGHT, rowSet.rowHeader, BOTTOMRIGHT, 10, 0)
	end

	local sets = KelaPadUI:GetSets(KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS)

	for i, set in spairs(sets, SortByName) do
		if set.traits == 2 then
			local rowSet2 = GetControl(tooltipInfo:GetName().."rowSet"..i)
			CreateCraftingSetsList(set, rowSet2, controlPanel.panelPip2)
		elseif set.traits == 3 then
			local rowSet3 = GetControl(tooltipInfo:GetName().."rowSet"..i)
			CreateCraftingSetsList(set, rowSet3, controlPanel.panelPip3)
		elseif set.traits == 4 then
			local rowSet4 = GetControl(tooltipInfo:GetName().."rowSet"..i)
			CreateCraftingSetsList(set, rowSet4, controlPanel.panelPip4)
		elseif set.traits == 5 then
			local rowSet5 = GetControl(tooltipInfo:GetName().."rowSet"..i)
			CreateCraftingSetsList(set, rowSet5, controlPanel.panelPip5)
		elseif set.traits == 6 then
			local rowSet6 = GetControl(tooltipInfo:GetName().."rowSet"..i)
			CreateCraftingSetsList(set, rowSet6, controlPanel.panelPip6)
		elseif set.traits == 7 then
			local rowSet7 = GetControl(tooltipInfo:GetName().."rowSet"..i)
			CreateCraftingSetsList(set, rowSet7, controlPanel.panelPip7)
		elseif set.traits == 8 then
			local rowSet8 = GetControl(tooltipInfo:GetName().."rowSet"..i)
			CreateCraftingSetsList(set, rowSet8, controlPanel.panelPip8)
		elseif set.traits == 9 then
			local rowSet9 = GetControl(tooltipInfo:GetName().."rowSet"..i)
			CreateCraftingSetsList(set, rowSet9, controlPanel.panelPip9)
		end
	end	

end
function kelaInitializeCraftingSetsPanel(index)

	local craftingSetsPanel, rowSet2, rowSet3, rowSet4, rowSet5, rowSet6, rowSet7, rowSet8, rowSet9
	
	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	if index then kelaIndexCraftingSetPanel = index end

	local controlPanel
	local controlPanelOld = GetControl(tooltipInfo:GetName().."CraftingSetsPanel"..1)
	if controlPanelOld then
		controlPanel = controlPanelOld
	else
		controlPanel = KPUI_GamepadTooltip:CreateCraftingSetsPanel(tooltipInfo, nil, 1)		
	end

	-- controlPanel.dividerPippedHeader:SetAnchor(TOPLEFT, tooltipInfo, TOPLEFT, 330, -4)
	-- controlPanel.dividerPippedHeader:SetAnchor(BOTTOMRIGHT, tooltipInfo, BOTTOMRIGHT, 620, 32)	

	controlPanel.panelPip2.focus = ZO_GamepadFocus:New(controlPanel.panelPip2, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip3.focus = ZO_GamepadFocus:New(controlPanel.panelPip3, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip4.focus = ZO_GamepadFocus:New(controlPanel.panelPip4, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip5.focus = ZO_GamepadFocus:New(controlPanel.panelPip5, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip6.focus = ZO_GamepadFocus:New(controlPanel.panelPip6, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip7.focus = ZO_GamepadFocus:New(controlPanel.panelPip7, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip8.focus = ZO_GamepadFocus:New(controlPanel.panelPip8, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip9.focus = ZO_GamepadFocus:New(controlPanel.panelPip9, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	
	controlPanel:SetHidden(true)	
	controlPanel.panelPip2:SetHidden(true)
	controlPanel.panelPip3:SetHidden(true)
	controlPanel.panelPip4:SetHidden(true)
	controlPanel.panelPip5:SetHidden(true)
	controlPanel.panelPip6:SetHidden(true)
	controlPanel.panelPip7:SetHidden(true)
	controlPanel.panelPip8:SetHidden(true)
	controlPanel.panelPip9:SetHidden(true)

	local function CreateCraftingSetsList(set, rowSet, panelPip)
		rowSet:SetParent(panelPip)
		rowSet.rowHeader:SetText (set.name)	
		-- rowSet.rowHeader:SetAnchor(LEFT, rowSet, LEFT, 0)
		-- rowSet.rowHeader:SetAnchor(RIGHT, rowSet, RIGHT, 0)
		local strBuild = ""
		for i, build in ipairs(set.build) do
			local color = nil
			if build == KPUI_SET_BUILD_DDS_STAMINA then 
				color = colors.COLOR_GREEN
			elseif build == KPUI_SET_BUILD_DDS_MAGICKA then 
				color = colors.COLOR_BLUE
			else
				color = colors.COLOR_WHITE
			end
			if strBuild == "" then
				strBuild = color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
			else
				strBuild = strBuild..color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
			end
		end
		if strBuild ~= "" then
			rowSet.rowHeaderValue:SetText (strBuild)
		end
		-- rowSet.rowHeaderValue:SetAnchor(RIGHT, rowSet.rowHeader, RIGHT, 0)		
		
		local rowSetHighlightOld = GetControl(tooltipInfo:GetName().."rowSetHighlight"..set.key)
		if rowSetHighlightOld then
			rowSetHighlight = rowSetHighlightOld
		else
			rowSetHighlight = CreateControlFromVirtual("$(parent)rowSetHighlight", tooltipInfo, "KPUI_TraitLabelHighlight", set.key)
			-- rowSetHighlight:SetAnchor(TOPLEFT, rowSet.rowHeader, TOPLEFT, -10, -2)
			-- rowSetHighlight:SetAnchor(BOTTOMRIGHT, rowSet.rowHeader, BOTTOMRIGHT, 10, 0)
		end	
		rowSetHighlight:SetParent(panelPip)
		
		-- KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS = 1
		-- KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS = 2
		-- KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS = 3
		-- KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS = 4
		local focusData = 
		{
			highlight = rowSetHighlight,
			control = rowSet.rowHeader,
			data = {
				rowFocusControl = panelPip.focus,
				rowSetIndex = set.key,
				rowSetId = set.itemId,
				rowSetName = set.name,
				rowSetBuild = set.build,
				rowSetTraits = set.traits,
				rowNumBonuses = set.numBonuses,
				rowSetLocations = set.locations
			},
			activate = function(control, data)
				kelaReColorDescription(true)
				kelaCurrentFocusCraftingSetPanel = data.rowFocusControl
				KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
				local name = colors.COLOR_WHITE:Colorize(string.upper(data.rowSetName))
				local traits = zo_strformat(SI_SMITHING_SET_ENOUGH_TRAITS,  colors.COLOR_WHITE:Colorize(data.rowSetTraits))
				local strBuild = ""
				if build ~= KPUI_SET_BUILD_NONE then
					for i, build in ipairs(data.rowSetBuild) do
						local color = nil
						if build == KPUI_SET_BUILD_DDS_STAMINA then 
							color = colors.COLOR_GREEN
						elseif build == KPUI_SET_BUILD_DDS_MAGICKA then 
							color = colors.COLOR_BLUE
						else
							color = colors.COLOR_WHITE
						end
						if strBuild == "" then
							strBuild = color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
						else
							strBuild = strBuild..color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
						end
					end
				end
				KPUI_GAMEPAD_TOOLTIPS:LayoutSetTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP, name, strBuild, traits, data)
			end,
			deactivate = function(control, data) 
				kelaReColorDescription(false)
				kelaCurrentFocusCraftingSetPanel = nil
				-- KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
			end,
		}
		
		panelPip.focus:AddEntry(focusData)
	
	end

	local sets = KelaPadUI:GetSets(KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS)

	for i, set in spairs(sets, SortByName) do
		-- local header = tree:AddNode("TB_SetsHeader", {key=i, id=set.id, name=set.name, traits=set.traits}, nil, nil)
		set.key = i
		if set.traits == 2 then
			local rowSet2Old = GetControl(tooltipInfo:GetName().."rowSet"..i)
			if rowSet2Old then
				rowSet2 = rowSet2Old
			else
				if not rowSet2 then
					rowSet2 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowSet")
				else
					rowSet2 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowSet2, i, 40, nil, "rowSet")
				end
			end	
			CreateCraftingSetsList(set, rowSet2, controlPanel.panelPip2)
		elseif set.traits == 3 then
			local rowSet3Old = GetControl(tooltipInfo:GetName().."rowSet"..i)
			if rowSet3Old then
				rowSet3 = rowSet3Old
			else
				if not rowSet3 then
					rowSet3 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowSet")
				else
					rowSet3 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowSet3, i, 40, nil, "rowSet")
				end
			end				
			CreateCraftingSetsList(set, rowSet3, controlPanel.panelPip3)
		elseif set.traits == 4 then
			local rowSet4Old = GetControl(tooltipInfo:GetName().."rowSet"..i)
			if rowSet4Old then
				rowSet4 = rowSet4Old
			else
				if not rowSet4 then
					rowSet4 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowSet")
				else
					rowSet4 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowSet4, i, 40, nil, "rowSet")
				end
			end				
			CreateCraftingSetsList(set, rowSet4, controlPanel.panelPip4)
		elseif set.traits == 5 then
			local rowSet5Old = GetControl(tooltipInfo:GetName().."rowSet"..i)
			if rowSet5Old then
				rowSet5 = rowSet5Old
			else
				if not rowSet5 then
					rowSet5 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowSet")
				else
					rowSet5 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowSet5, i, 40, nil, "rowSet")
				end
			end							
			CreateCraftingSetsList(set, rowSet5, controlPanel.panelPip5)
		elseif set.traits == 6 then
			local rowSet6Old = GetControl(tooltipInfo:GetName().."rowSet"..i)
			if rowSet6Old then
				rowSet6 = rowSet6Old
			else
				if not rowSet6 then
					rowSet6 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowSet")
				else
					rowSet6 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowSet6, i, 40, nil, "rowSet")
				end
			end		
			CreateCraftingSetsList(set, rowSet6, controlPanel.panelPip6)
		elseif set.traits == 7 then
			local rowSet7Old = GetControl(tooltipInfo:GetName().."rowSet"..i)
			if rowSet7Old then
				rowSet7 = rowSet7Old
			else
				if not rowSet7 then
					rowSet7 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowSet")
				else
					rowSet7 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowSet7, i, 40, nil, "rowSet")
				end
			end		
			CreateCraftingSetsList(set, rowSet7, controlPanel.panelPip7)
		elseif set.traits == 8 then
			local rowSet8Old = GetControl(tooltipInfo:GetName().."rowSet"..i)
			if rowSet8Old then
				rowSet8 = rowSet8Old
			else
				if not rowSet8 then
					rowSet8 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowSet")
				else
					rowSet8 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowSet8, i, 40, nil, "rowSet")
				end
			end		
			CreateCraftingSetsList(set, rowSet8, controlPanel.panelPip8)
		elseif set.traits == 9 then
			local rowSet9Old = GetControl(tooltipInfo:GetName().."rowSet"..i)
			if rowSet9Old then
				rowSet9 = rowSet9Old
			else
				if not rowSet9 then
					rowSet9 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowSet")
				else
					rowSet9 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowSet9, i, 40, nil, "rowSet")
				end
			end		
			CreateCraftingSetsList(set, rowSet9, controlPanel.panelPip9)
		end
	end	
	
	if kelaIndexCraftingSetPanel == 2 then
		kelaFocusCraftingSetPanel.Panel2 = controlPanel.panelPip2
		kelaFocusCraftingSetPanel.Focus2 = controlPanel.panelPip2.focus
	end
	if kelaIndexCraftingSetPanel == 3 then
		kelaFocusCraftingSetPanel.Panel3 = controlPanel.panelPip3
		kelaFocusCraftingSetPanel.Focus3 = controlPanel.panelPip3.focus
	end
	if kelaIndexCraftingSetPanel == 4 then
		kelaFocusCraftingSetPanel.Panel4 = controlPanel.panelPip4
		kelaFocusCraftingSetPanel.Focus4 = controlPanel.panelPip4.focus
	end
	if kelaIndexCraftingSetPanel == 5 then
		kelaFocusCraftingSetPanel.Panel5 = controlPanel.panelPip5
		kelaFocusCraftingSetPanel.Focus5 = controlPanel.panelPip5.focus
	end
	if kelaIndexCraftingSetPanel == 6 then
		kelaFocusCraftingSetPanel.Panel6 = controlPanel.panelPip6
		kelaFocusCraftingSetPanel.Focus6 = controlPanel.panelPip6.focus
	end
	if kelaIndexCraftingSetPanel == 7 then
		kelaFocusCraftingSetPanel.Panel7 = controlPanel.panelPip7
		kelaFocusCraftingSetPanel.Focus7 = controlPanel.panelPip7.focus
	end
	if kelaIndexCraftingSetPanel == 8 then
		kelaFocusCraftingSetPanel.Panel8 = controlPanel.panelPip8
		kelaFocusCraftingSetPanel.Focus8 = controlPanel.panelPip8.focus
	end
	if kelaIndexCraftingSetPanel == 9 then
		kelaFocusCraftingSetPanel.Panel9 = controlPanel.panelPip9
		kelaFocusCraftingSetPanel.Focus9 = controlPanel.panelPip9.focus
	end	

end


KelaPadUI.ButtonsOverlandSets = {}
KelaPadUI.ButtonsOverlandSets = {
	{
	keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
	callback = function()
		local currentControl = kelaGetCurrentOverlandSetsFocusControl()
		currentControl:SetActive(false, false)	
		if kelaIndexOverlandSetPanel == kelaCountOverlandSetPanel then
			kelaIndexOverlandSetPanel = 1
		else
			kelaIndexOverlandSetPanel = kelaIndexOverlandSetPanel + 1
		end
		kelaRefreshOverlandSetsPanel(true)
		local currentControl = kelaGetCurrentOverlandSetsFocusControl()
		currentControl:SetActive(true, false)	
		RefreshButtonsSetsPanel()
	end,
	ethereal = true,
	sound = SOUNDS.GAMEPAD_MENU_FORWARD,
	},
	{
	keybind = "UI_SHORTCUT_LEFT_SHOULDER",
	callback = function()
		local currentControl = kelaGetCurrentOverlandSetsFocusControl()
		currentControl:SetActive(false, false)	
		if kelaIndexOverlandSetPanel == 1 then
			kelaIndexOverlandSetPanel = kelaCountOverlandSetPanel
		else
			kelaIndexOverlandSetPanel = kelaIndexOverlandSetPanel - 1
		end
		kelaRefreshOverlandSetsPanel(true)
		local currentControl = kelaGetCurrentOverlandSetsFocusControl()
		currentControl:SetActive(true, false)	
		RefreshButtonsSetsPanel()
	end,
	ethereal = true,
	sound = SOUNDS.GAMEPAD_MENU_FORWARD,
	},
}
function InitializeButtonsOverlandSets()
	KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.ButtonsOverlandSets)
end
function RemoveButtonsOverlandSets()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.ButtonsOverlandSets)
end
function RefreshButtonsOverlandSets()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.ButtonsOverlandSets)
	KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.ButtonsOverlandSets)
end
function kelaGetCurrentOverlandSetsFocusControl()
	if not kelaFocusOverlandSetPanel.Panel1:IsHidden() then 
		return kelaFocusOverlandSetPanel.Focus1
	elseif not kelaFocusOverlandSetPanel.Panel2:IsHidden() then 
		return kelaFocusOverlandSetPanel.Focus2
	elseif not kelaFocusOverlandSetPanel.Panel3:IsHidden() then 
		return kelaFocusOverlandSetPanel.Focus3
	elseif not kelaFocusOverlandSetPanel.Panel4:IsHidden() then 
		return kelaFocusOverlandSetPanel.Focus4
	elseif not kelaFocusOverlandSetPanel.Panel5:IsHidden() then 
		return kelaFocusOverlandSetPanel.Focus5
	elseif not kelaFocusOverlandSetPanel.Panel6:IsHidden() then 
		return kelaFocusOverlandSetPanel.Focus6
	elseif not kelaFocusOverlandSetPanel.Panel7:IsHidden() then 
		return kelaFocusOverlandSetPanel.Focus7
	elseif not kelaFocusOverlandSetPanel.Panel8:IsHidden() then 
		return kelaFocusOverlandSetPanel.Focus8
	end
	return false
end
function kelaIsOverlandSetsPanelActive()
	if kelaGetCurrentOverlandSetsFocusControl() then 
		return true
	end
	return false
end
function kelaRefreshOverlandSetsPanel(activate)

	

	KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:AddFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:AddFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))	
	
	local title = GetString(KELA_STAT_GAMEPAD_SETS_SHEET_DESCRIPTION)
	local dataHeaderText = ""
	local dataText = ""
	
	KPUI_GAMEPAD_TOOLTIPS:ClearContentHeader(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP)
	KPUI_GAMEPAD_TOOLTIPS:RefreshContentHeader(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP, title, dataHeaderText, dataText)

	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	local controlPanel = GetControl(tooltipInfo:GetName().."OverlandSetsPanel"..1)
	if activate then
		controlPanel.dividerPippedHeader:SetText(GetString("KELA_STAT_GAMEPAD_SETS_PANEL_SETS_OVERLAND_TITLE", kelaIndexOverlandSetPanel))
		local PIP_WIDTH = 32 
		local activePipIndex = kelaIndexOverlandSetPanel
		local numPips = kelaCountOverlandSetPanel 
		for i = 1, numPips do
			local pip 
			local pipOld = GetControl(tooltipInfo:GetName().."OverlandSetsTabBarPip"..i)
			if pipOld then
				pip = pipOld
			else
				pip = CreateControlFromVirtual("$(parent)OverlandSetsTabBarPip", tooltipInfo, "ZO_GamepadTabBarPip", i)
			end
			pip:SetParent(controlPanel.pipsControl)
			pip:SetAnchor(CENTER, controlPanel.pipsControl, CENTER, (i - 1 - (numPips - 1) / 2) * PIP_WIDTH, 0)
			local active = (activePipIndex == i)
			pip:GetNamedChild("Active"):SetHidden(not active)
			pip:GetNamedChild("Inactive"):SetHidden(active)
		end
		controlPanel.panelPip1:SetHidden(kelaIndexOverlandSetPanel ~= 1)
		controlPanel.panelPip2:SetHidden(kelaIndexOverlandSetPanel ~= 2)
		controlPanel.panelPip3:SetHidden(kelaIndexOverlandSetPanel ~= 3)
		controlPanel.panelPip4:SetHidden(kelaIndexOverlandSetPanel ~= 4)
		controlPanel.panelPip5:SetHidden(kelaIndexOverlandSetPanel ~= 5)
		controlPanel.panelPip6:SetHidden(kelaIndexOverlandSetPanel ~= 6)
		controlPanel.panelPip7:SetHidden(kelaIndexOverlandSetPanel ~= 7)
		controlPanel.panelPip8:SetHidden(kelaIndexOverlandSetPanel ~= 8)
		controlPanel:SetHidden(false)		
		InitializeButtonsOverlandSets()
	else
		controlPanel.panelPip1:SetHidden(true)
		controlPanel.panelPip2:SetHidden(true)
		controlPanel.panelPip3:SetHidden(true)
		controlPanel.panelPip4:SetHidden(true)
		controlPanel.panelPip5:SetHidden(true)
		controlPanel.panelPip6:SetHidden(true)
		controlPanel.panelPip7:SetHidden(true)
		controlPanel.panelPip8:SetHidden(true)	
		controlPanel:SetHidden(true)
		RemoveButtonsOverlandSets()
	end
	
end
function kelaInitializeOverlandSetsPanelSetAnchors(index)

	local overlandSetsPanel, rowOverlandSet1, rowOverlandSet2, rowOverlandSet3, rowOverlandSet4, rowOverlandSet5, rowOverlandSet6, rowOverlandSet7, rowOverlandSet8
	
	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)

	local controlPanel = GetControl(tooltipInfo:GetName().."OverlandSetsPanel"..1)
	controlPanel.dividerPippedHeader:SetAnchor(TOPLEFT, tooltipInfo, TOPLEFT, 330, -4)
	controlPanel.dividerPippedHeader:SetAnchor(BOTTOMRIGHT, tooltipInfo, BOTTOMRIGHT, 620, 32)	

	local function CreateOverlandSetsList(set, rowOverlandSet, panelPip)
		rowOverlandSet.rowHeader:SetAnchor(LEFT, rowOverlandSet, LEFT, 0)
		rowOverlandSet.rowHeader:SetAnchor(RIGHT, rowOverlandSet, RIGHT, 0)
		rowOverlandSet.rowHeaderValue:SetAnchor(RIGHT, rowOverlandSet.rowHeader, RIGHT, 0)		
		local rowOverlandSetHighlight = GetControl(tooltipInfo:GetName().."rowOverlandSetHighlight"..set.key)
		rowOverlandSetHighlight:SetAnchor(TOPLEFT, rowOverlandSet.rowHeader, TOPLEFT, -10, -2)
		rowOverlandSetHighlight:SetAnchor(BOTTOMRIGHT, rowOverlandSet.rowHeader, BOTTOMRIGHT, 10, 0)
	end

	local sets = KelaPadUI:GetSets(KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS)
	
	local countRowSet = 0
	for i, set in spairs(sets, SortByName) do
		countRowSet = countRowSet + 1
		if countRowSet >= 0 and countRowSet <= 20 then
			local rowOverlandSet1 = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			CreateOverlandSetsList(set, rowOverlandSet1, controlPanel.panelPip1)
		elseif countRowSet > 20 and countRowSet <= 40 then
			local rowOverlandSet2 = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			CreateOverlandSetsList(set, rowOverlandSet2, controlPanel.panelPip2)
		elseif countRowSet > 40 and countRowSet <= 60 then
			local rowOverlandSet3 = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			CreateOverlandSetsList(set, rowOverlandSet3, controlPanel.panelPip3)
		elseif countRowSet > 60 and countRowSet <= 80 then
			local rowOverlandSet4 = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			CreateOverlandSetsList(set, rowOverlandSet4, controlPanel.panelPip4)
		elseif countRowSet > 80 and countRowSet <= 100 then
			local rowOverlandSet5 = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			CreateOverlandSetsList(set, rowOverlandSet5, controlPanel.panelPip5)
		elseif countRowSet > 100 and countRowSet <= 120 then
			local rowOverlandSet6 = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			CreateOverlandSetsList(set, rowOverlandSet6, controlPanel.panelPip6)
		elseif countRowSet > 120 and countRowSet <= 140 then
			local rowOverlandSet7 = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			CreateOverlandSetsList(set, rowOverlandSet7, controlPanel.panelPip7)
		elseif countRowSet > 140 and countRowSet <= 180 then
			local rowOverlandSet8 = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			CreateOverlandSetsList(set, rowOverlandSet8, controlPanel.panelPip8)
		end
	end	

end
function kelaInitializeOverlandSetsPanel(index)

	local overlandSetsPanel, rowOverlandSet1, rowOverlandSet2, rowOverlandSet3, rowOverlandSet4, rowOverlandSet5, rowOverlandSet6, rowOverlandSet7, rowOverlandSet8

	kelaCountOverlandSetPanel = math.ceil(kelaGetCountTable(setsOverland)/20) --math.floor(kelaGetCountTable(setsOverland)/20)
	
	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	if index then kelaIndexOverlandSetPanel = index end

	local controlPanel
	local controlPanelOld = GetControl(tooltipInfo:GetName().."OverlandSetsPanel"..1)
	if controlPanelOld then
		controlPanel = controlPanelOld
	else
		controlPanel = KPUI_GamepadTooltip:CreateOverlandSetsPanel(tooltipInfo, nil, 1)		
	end

	-- controlPanel.dividerPippedHeader:SetAnchor(TOPLEFT, tooltipInfo, TOPLEFT, 330, -4)
	-- controlPanel.dividerPippedHeader:SetAnchor(BOTTOMRIGHT, tooltipInfo, BOTTOMRIGHT, 620, 32)	

	controlPanel.panelPip1.focus = ZO_GamepadFocus:New(controlPanel.panelPip1, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip2.focus = ZO_GamepadFocus:New(controlPanel.panelPip2, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip3.focus = ZO_GamepadFocus:New(controlPanel.panelPip3, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip4.focus = ZO_GamepadFocus:New(controlPanel.panelPip4, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip5.focus = ZO_GamepadFocus:New(controlPanel.panelPip5, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip6.focus = ZO_GamepadFocus:New(controlPanel.panelPip6, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip7.focus = ZO_GamepadFocus:New(controlPanel.panelPip7, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip8.focus = ZO_GamepadFocus:New(controlPanel.panelPip8, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	
	controlPanel:SetHidden(true)	
	controlPanel.panelPip1:SetHidden(true)
	controlPanel.panelPip2:SetHidden(true)
	controlPanel.panelPip3:SetHidden(true)
	controlPanel.panelPip4:SetHidden(true)
	controlPanel.panelPip5:SetHidden(true)
	controlPanel.panelPip6:SetHidden(true)
	controlPanel.panelPip7:SetHidden(true)
	controlPanel.panelPip8:SetHidden(true)
	

	local function CreateOverlandSetsList(set, rowOverlandSet, panelPip)
		rowOverlandSet:SetParent(panelPip)
		rowOverlandSet.rowHeader:SetText (set.name)	
		-- rowOverlandSet.rowHeader:SetAnchor(LEFT, rowOverlandSet, LEFT, 0)
		-- rowOverlandSet.rowHeader:SetAnchor(RIGHT, rowOverlandSet, RIGHT, 0)
		local strBuild = ""
		for i, build in ipairs(set.build) do
			local color = nil
			if build == KPUI_SET_BUILD_DDS_STAMINA then 
				color = colors.COLOR_GREEN
			elseif build == KPUI_SET_BUILD_DDS_MAGICKA then 
				color = colors.COLOR_BLUE
			else
				color = colors.COLOR_WHITE
			end
			if strBuild == "" then
				strBuild = color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
			else
				strBuild = strBuild..color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
			end
		end
		if strBuild ~= "" then
			rowOverlandSet.rowHeaderValue:SetText (strBuild)
		end
		-- rowOverlandSet.rowHeaderValue:SetAnchor(RIGHT, rowOverlandSet.rowHeader, RIGHT, 0)		
		
		local rowOverlandSetHighlightOld = GetControl(tooltipInfo:GetName().."rowOverlandSetHighlight"..set.key)
		if rowOverlandSetHighlightOld then
			rowOverlandSetHighlight = rowOverlandSetHighlightOld
		else
			rowOverlandSetHighlight = CreateControlFromVirtual("$(parent)rowOverlandSetHighlight", tooltipInfo, "KPUI_TraitLabelHighlight", set.key)
			-- rowOverlandSetHighlight:SetAnchor(TOPLEFT, rowOverlandSet.rowHeader, TOPLEFT, -10, -2)
			-- rowOverlandSetHighlight:SetAnchor(BOTTOMRIGHT, rowOverlandSet.rowHeader, BOTTOMRIGHT, 10, 0)
		end	
		rowOverlandSetHighlight:SetParent(panelPip)
		
		-- KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS = 1
		-- KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS = 2
		-- KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS = 3
		-- KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS = 4
		local focusData = 
		{
			highlight = rowOverlandSetHighlight,
			control = rowOverlandSet.rowHeader,
			data = {
				rowFocusControl = panelPip.focus,
				rowSetIndex = set.key,
				rowSetId = set.itemId,
				rowSetName = set.name,
				rowSetBuild = set.build,
				rowSetItems = set.items,
				rowNumBonuses = set.numBonuses,
				rowSetLocations = set.locations
			},
			activate = function(control, data)
				kelaReColorDescription(true)
				kelaCurrentFocusOverlandSetPanel = data.rowFocusControl
				KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
				local name = colors.COLOR_WHITE:Colorize(string.upper(data.rowSetName))
				local strBuild = ""
				for i, build in ipairs(data.rowSetBuild) do
					local color = nil
					if build ~= KPUI_SET_BUILD_NONE then
						if build == KPUI_SET_BUILD_DDS_STAMINA then 
							color = colors.COLOR_GREEN
						elseif build == KPUI_SET_BUILD_DDS_MAGICKA then 
							color = colors.COLOR_BLUE
						else
							color = colors.COLOR_WHITE
						end
						if strBuild == "" then
							strBuild = color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
						else
							strBuild = strBuild..color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
						end
					end
				end
				KPUI_GAMEPAD_TOOLTIPS:LayoutSetTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP, name, strBuild, nil, data)
			end,
			deactivate = function(control, data) 
				kelaReColorDescription(false)
				kelaCurrentFocusOverlandSetPanel = nil
				-- KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
			end,
		}
		
		panelPip.focus:AddEntry(focusData)
	
	end


	local sets = KelaPadUI:GetSets(KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS)
	
	local countRowSet = 0
	for i, set in spairs(sets, SortByName) do
		-- local header = tree:AddNode("TB_SetsHeader", {key=i, id=set.id, name=set.name, traits=set.traits}, nil, nil)
		set.key = i
		
		countRowSet = countRowSet + 1
		
		if countRowSet >= 0 and countRowSet <= 20 then
			local rowOverlandSet1Old = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			if rowOverlandSet1Old then
				rowOverlandSet1 = rowOverlandSet1Old
			else
				if not rowOverlandSet1 then
					rowOverlandSet1 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowOverlandSet")
				else
					rowOverlandSet1 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowOverlandSet1, i, 40, nil, "rowOverlandSet")
				end
			end				
			CreateOverlandSetsList(set, rowOverlandSet1, controlPanel.panelPip1)
		elseif countRowSet > 20 and countRowSet <= 40 then
			local rowOverlandSet2Old = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			if rowOverlandSet2Old then
				rowOverlandSet2 = rowOverlandSet2Old
			else
				if not rowOverlandSet2 then
					rowOverlandSet2 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowOverlandSet")
				else
					rowOverlandSet2 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowOverlandSet2, i, 40, nil, "rowOverlandSet")
				end
			end				
			CreateOverlandSetsList(set, rowOverlandSet2, controlPanel.panelPip2)
		elseif countRowSet > 40 and countRowSet <= 60 then
			local rowOverlandSet3Old = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			if rowOverlandSet3Old then
				rowOverlandSet3 = rowOverlandSet3Old
			else
				if not rowOverlandSet3 then
					rowOverlandSet3 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowOverlandSet")
				else
					rowOverlandSet3 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowOverlandSet3, i, 40, nil, "rowOverlandSet")
				end
			end				
			CreateOverlandSetsList(set, rowOverlandSet3, controlPanel.panelPip3)
		elseif countRowSet > 60 and countRowSet <= 80 then
			local rowOverlandSet4Old = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			if rowOverlandSet4Old then
				rowOverlandSet4 = rowOverlandSet4Old
			else
				if not rowOverlandSet4 then
					rowOverlandSet4 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowOverlandSet")
				else
					rowOverlandSet4 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowOverlandSet4, i, 40, nil, "rowOverlandSet")
				end
			end				
			CreateOverlandSetsList(set, rowOverlandSet4, controlPanel.panelPip4)
		elseif countRowSet > 80 and countRowSet <= 100 then
			local rowOverlandSet5Old = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			if rowOverlandSet5Old then
				rowOverlandSet5 = rowOverlandSet5Old
			else
				if not rowOverlandSet5 then
					rowOverlandSet5 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowOverlandSet")
				else
					rowOverlandSet5 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowOverlandSet5, i, 40, nil, "rowOverlandSet")
				end
			end				
			CreateOverlandSetsList(set, rowOverlandSet5, controlPanel.panelPip5)
		elseif countRowSet > 100 and countRowSet <= 120 then
			local rowOverlandSet6Old = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			if rowOverlandSet6Old then
				rowOverlandSet6 = rowOverlandSet6Old
			else
				if not rowOverlandSet6 then
					rowOverlandSet6 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowOverlandSet")
				else
					rowOverlandSet6 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowOverlandSet6, i, 40, nil, "rowOverlandSet")
				end
			end				
			CreateOverlandSetsList(set, rowOverlandSet6, controlPanel.panelPip6)
		elseif countRowSet > 120 and countRowSet <= 140 then
			local rowOverlandSet7Old = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			if rowOverlandSet7Old then
				rowOverlandSet7 = rowOverlandSet7Old
			else
				if not rowOverlandSet7 then
					rowOverlandSet7 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowOverlandSet")
				else
					rowOverlandSet7 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowOverlandSet7, i, 40, nil, "rowOverlandSet")
				end
			end				
			CreateOverlandSetsList(set, rowOverlandSet7, controlPanel.panelPip7)
		elseif countRowSet > 140 and countRowSet <= 180 then
			local rowOverlandSet8Old = GetControl(tooltipInfo:GetName().."rowOverlandSet"..i)
			if rowOverlandSet8Old then
				rowOverlandSet8 = rowOverlandSet8Old
			else
				if not rowOverlandSet8 then
					rowOverlandSet8 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowOverlandSet")
				else
					rowOverlandSet8 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowOverlandSet8, i, 40, nil, "rowOverlandSet")
				end
			end				
			CreateOverlandSetsList(set, rowOverlandSet8, controlPanel.panelPip8)
		end
	end	
	
	if kelaIndexOverlandSetPanel == 1 then
		kelaFocusOverlandSetPanel.Panel1 = controlPanel.panelPip1
		kelaFocusOverlandSetPanel.Focus1 = controlPanel.panelPip1.focus
	end
	if kelaIndexOverlandSetPanel == 2 then
		kelaFocusOverlandSetPanel.Panel2 = controlPanel.panelPip2
		kelaFocusOverlandSetPanel.Focus2 = controlPanel.panelPip2.focus
	end
	if kelaIndexOverlandSetPanel == 3 then
		kelaFocusOverlandSetPanel.Panel3 = controlPanel.panelPip3
		kelaFocusOverlandSetPanel.Focus3 = controlPanel.panelPip3.focus
	end
	if kelaIndexOverlandSetPanel == 4 then
		kelaFocusOverlandSetPanel.Panel4 = controlPanel.panelPip4
		kelaFocusOverlandSetPanel.Focus4 = controlPanel.panelPip4.focus
	end
	if kelaIndexOverlandSetPanel == 5 then
		kelaFocusOverlandSetPanel.Panel5 = controlPanel.panelPip5
		kelaFocusOverlandSetPanel.Focus5 = controlPanel.panelPip5.focus
	end
	if kelaIndexOverlandSetPanel == 6 then
		kelaFocusOverlandSetPanel.Panel6 = controlPanel.panelPip6
		kelaFocusOverlandSetPanel.Focus6 = controlPanel.panelPip6.focus
	end
	if kelaIndexOverlandSetPanel == 7 then
		kelaFocusOverlandSetPanel.Panel7 = controlPanel.panelPip7
		kelaFocusOverlandSetPanel.Focus7 = controlPanel.panelPip7.focus
	end
	if kelaIndexOverlandSetPanel == 8 then
		kelaFocusOverlandSetPanel.Panel8 = controlPanel.panelPip8
		kelaFocusOverlandSetPanel.Focus8 = controlPanel.panelPip8.focus
	end

end


KelaPadUI.ButtonsDungeonSets = {}
KelaPadUI.ButtonsDungeonSets = {
	{
	keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
	callback = function()
		local currentControl = kelaGetCurrentDungeonSetsFocusControl()
		currentControl:SetActive(false, false)	
		if kelaIndexDungeonSetPanel == kelaCountDungeonSetPanel then
			kelaIndexDungeonSetPanel = 1
		else
			kelaIndexDungeonSetPanel = kelaIndexDungeonSetPanel + 1
		end
		kelaRefreshDungeonSetsPanel(true)
		local currentControl = kelaGetCurrentDungeonSetsFocusControl()
		currentControl:SetActive(true, false)	
		RefreshButtonsSetsPanel()
	end,
	ethereal = true,
	sound = SOUNDS.GAMEPAD_MENU_FORWARD,
	},
	{
	keybind = "UI_SHORTCUT_LEFT_SHOULDER",
	callback = function()
		local currentControl = kelaGetCurrentDungeonSetsFocusControl()
		currentControl:SetActive(false, false)	
		if kelaIndexDungeonSetPanel == 1 then
			kelaIndexDungeonSetPanel = kelaCountDungeonSetPanel
		else
			kelaIndexDungeonSetPanel = kelaIndexDungeonSetPanel - 1
		end
		kelaRefreshDungeonSetsPanel(true)
		local currentControl = kelaGetCurrentDungeonSetsFocusControl()
		currentControl:SetActive(true, false)	
		RefreshButtonsSetsPanel()
	end,
	ethereal = true,
	sound = SOUNDS.GAMEPAD_MENU_FORWARD,
	},
}
function InitializeButtonsDungeonSets()
	KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.ButtonsDungeonSets)
end
function RemoveButtonsDungeonSets()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.ButtonsDungeonSets)
end
function RefreshButtonsDungeonSets()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.ButtonsDungeonSets)
	KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.ButtonsDungeonSets)
end
function kelaGetCurrentDungeonSetsFocusControl()
	if not kelaFocusDungeonSetPanel.Panel1:IsHidden() then 
		return kelaFocusDungeonSetPanel.Focus1
	elseif not kelaFocusDungeonSetPanel.Panel2:IsHidden() then 
		return kelaFocusDungeonSetPanel.Focus2
	elseif not kelaFocusDungeonSetPanel.Panel3:IsHidden() then 
		return kelaFocusDungeonSetPanel.Focus3
	elseif not kelaFocusDungeonSetPanel.Panel4:IsHidden() then 
		return kelaFocusDungeonSetPanel.Focus4
	elseif not kelaFocusDungeonSetPanel.Panel5:IsHidden() then 
		return kelaFocusDungeonSetPanel.Focus5
	elseif not kelaFocusDungeonSetPanel.Panel6:IsHidden() then 
		return kelaFocusDungeonSetPanel.Focus6
	elseif not kelaFocusDungeonSetPanel.Panel7:IsHidden() then 
		return kelaFocusDungeonSetPanel.Focus7
	elseif not kelaFocusDungeonSetPanel.Panel8:IsHidden() then 
		return kelaFocusDungeonSetPanel.Focus8
	elseif not kelaFocusDungeonSetPanel.Panel9:IsHidden() then 
		return kelaFocusDungeonSetPanel.Focus9
	end
	return false
end
function kelaIsDungeonSetsPanelActive()
	if kelaGetCurrentDungeonSetsFocusControl() then 
		return true
	end
	return false
end
function kelaRefreshDungeonSetsPanel(activate)

	KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:AddFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:AddFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))	
	
	local title = GetString(KELA_STAT_GAMEPAD_SETS_SHEET_DESCRIPTION)
	local dataHeaderText = ""
	local dataText = ""
	
	KPUI_GAMEPAD_TOOLTIPS:ClearContentHeader(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP)
	KPUI_GAMEPAD_TOOLTIPS:RefreshContentHeader(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP, title, dataHeaderText, dataText)

	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	local controlPanel = GetControl(tooltipInfo:GetName().."DungeonSetsPanel"..1)
	if activate then
		controlPanel.dividerPippedHeader:SetText(GetString("KELA_STAT_GAMEPAD_SETS_PANEL_SETS_DUNGEON_TITLE", kelaIndexDungeonSetPanel))
		local PIP_WIDTH = 32 
		local activePipIndex = kelaIndexDungeonSetPanel
		local numPips = kelaCountDungeonSetPanel 
		for i = 1, numPips do
			local pip 
			local pipOld = GetControl(tooltipInfo:GetName().."DungeonSetsTabBarPip"..i)
			if pipOld then
				pip = pipOld
			else
				pip = CreateControlFromVirtual("$(parent)DungeonSetsTabBarPip", tooltipInfo, "ZO_GamepadTabBarPip", i)
			end
			pip:SetParent(controlPanel.pipsControl)
			pip:SetAnchor(CENTER, controlPanel.pipsControl, CENTER, (i - 1 - (numPips - 1) / 2) * PIP_WIDTH, 0)
			local active = (activePipIndex == i)
			pip:GetNamedChild("Active"):SetHidden(not active)
			pip:GetNamedChild("Inactive"):SetHidden(active)
		end
		controlPanel.panelPip1:SetHidden(kelaIndexDungeonSetPanel ~= 1)
		controlPanel.panelPip2:SetHidden(kelaIndexDungeonSetPanel ~= 2)
		controlPanel.panelPip3:SetHidden(kelaIndexDungeonSetPanel ~= 3)
		controlPanel.panelPip4:SetHidden(kelaIndexDungeonSetPanel ~= 4)
		controlPanel.panelPip5:SetHidden(kelaIndexDungeonSetPanel ~= 5)
		controlPanel.panelPip6:SetHidden(kelaIndexDungeonSetPanel ~= 6)
		controlPanel.panelPip7:SetHidden(kelaIndexDungeonSetPanel ~= 7)
		controlPanel.panelPip8:SetHidden(kelaIndexDungeonSetPanel ~= 8)
		controlPanel.panelPip9:SetHidden(kelaIndexDungeonSetPanel ~= 9)
		controlPanel:SetHidden(false)		
		InitializeButtonsDungeonSets()
	else
		controlPanel.panelPip1:SetHidden(true)
		controlPanel.panelPip2:SetHidden(true)
		controlPanel.panelPip3:SetHidden(true)
		controlPanel.panelPip4:SetHidden(true)
		controlPanel.panelPip5:SetHidden(true)
		controlPanel.panelPip6:SetHidden(true)
		controlPanel.panelPip7:SetHidden(true)
		controlPanel.panelPip8:SetHidden(true)	
		controlPanel.panelPip9:SetHidden(true)	
		controlPanel:SetHidden(true)
		RemoveButtonsDungeonSets()
	end
	
end
function kelaInitializeDungeonSetsPanelSetAnchors(index)

	local dungeonSetsPanel, rowDungeonSet1, rowDungeonSet2, rowDungeonSet3, rowDungeonSet4, rowDungeonSet5, rowDungeonSet6, rowDungeonSet7, rowDungeonSet8, rowDungeonSet9
	
	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)

	local controlPanel = GetControl(tooltipInfo:GetName().."DungeonSetsPanel"..1)
	controlPanel.dividerPippedHeader:SetAnchor(TOPLEFT, tooltipInfo, TOPLEFT, 330, -4)
	controlPanel.dividerPippedHeader:SetAnchor(BOTTOMRIGHT, tooltipInfo, BOTTOMRIGHT, 620, 32)	

	local function CreateDungeonSetsList(set, rowDungeonSet, panelPip)
		rowDungeonSet.rowHeader:SetAnchor(LEFT, rowDungeonSet, LEFT, 0)
		rowDungeonSet.rowHeader:SetAnchor(RIGHT, rowDungeonSet, RIGHT, 0)
		rowDungeonSet.rowHeaderValue:SetAnchor(RIGHT, rowDungeonSet.rowHeader, RIGHT, 0)		
		local rowDungeonSetHighlight = GetControl(tooltipInfo:GetName().."rowDungeonSetHighlight"..set.key)
		rowDungeonSetHighlight:SetAnchor(TOPLEFT, rowDungeonSet.rowHeader, TOPLEFT, -10, -2)
		rowDungeonSetHighlight:SetAnchor(BOTTOMRIGHT, rowDungeonSet.rowHeader, BOTTOMRIGHT, 10, 0)
	end

	local sets = KelaPadUI:GetSets(KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS)
	
	local countRowSet = 0
	for i, set in spairs(sets, SortByName) do
		countRowSet = countRowSet + 1
		if countRowSet >= 0 and countRowSet <= 20 then
			local rowDungeonSet1 = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			CreateDungeonSetsList(set, rowDungeonSet1, controlPanel.panelPip1)
		elseif countRowSet > 20 and countRowSet <= 40 then
			local rowDungeonSet2 = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			CreateDungeonSetsList(set, rowDungeonSet2, controlPanel.panelPip2)
		elseif countRowSet > 40 and countRowSet <= 60 then
			local rowDungeonSet3 = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			CreateDungeonSetsList(set, rowDungeonSet3, controlPanel.panelPip3)
		elseif countRowSet > 60 and countRowSet <= 80 then
			local rowDungeonSet4 = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			CreateDungeonSetsList(set, rowDungeonSet4, controlPanel.panelPip4)
		elseif countRowSet > 80 and countRowSet <= 100 then
			local rowDungeonSet5 = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			CreateDungeonSetsList(set, rowDungeonSet5, controlPanel.panelPip5)
		elseif countRowSet > 100 and countRowSet <= 120 then
			local rowDungeonSet6 = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			CreateDungeonSetsList(set, rowDungeonSet6, controlPanel.panelPip6)
		elseif countRowSet > 120 and countRowSet <= 140 then
			local rowDungeonSet7 = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			CreateDungeonSetsList(set, rowDungeonSet7, controlPanel.panelPip7)
		elseif countRowSet > 140 and countRowSet <= 160 then
			local rowDungeonSet8 = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			CreateDungeonSetsList(set, rowDungeonSet8, controlPanel.panelPip8)
		elseif countRowSet > 160 and countRowSet <= 180 then
			local rowDungeonSet9 = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			CreateDungeonSetsList(set, rowDungeonSet9, controlPanel.panelPip9)
		end
	end	

end
function kelaInitializeDungeonSetsPanel(index)

	local dungeonSetsPanel, rowDungeonSet1, rowDungeonSet2, rowDungeonSet3, rowDungeonSet4, rowDungeonSet5, rowDungeonSet6, rowDungeonSet7, rowDungeonSet8, rowDungeonSet9

	kelaCountDungeonSetPanel = math.ceil(kelaGetCountTable(setsDungeon)/20) --math.floor(kelaGetCountTable(setsDungeon)/20)
	
	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	if index then kelaIndexDungeonSetPanel = index end

	local controlPanel
	local controlPanelOld = GetControl(tooltipInfo:GetName().."DungeonSetsPanel"..1)
	if controlPanelOld then
		controlPanel = controlPanelOld
	else
		controlPanel = KPUI_GamepadTooltip:CreateDungeonSetsPanel(tooltipInfo, nil, 1)		
	end

	-- controlPanel.dividerPippedHeader:SetAnchor(TOPLEFT, tooltipInfo, TOPLEFT, 330, -4)
	-- controlPanel.dividerPippedHeader:SetAnchor(BOTTOMRIGHT, tooltipInfo, BOTTOMRIGHT, 620, 32)	

	controlPanel.panelPip1.focus = ZO_GamepadFocus:New(controlPanel.panelPip1, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip2.focus = ZO_GamepadFocus:New(controlPanel.panelPip2, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip3.focus = ZO_GamepadFocus:New(controlPanel.panelPip3, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip4.focus = ZO_GamepadFocus:New(controlPanel.panelPip4, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip5.focus = ZO_GamepadFocus:New(controlPanel.panelPip5, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip6.focus = ZO_GamepadFocus:New(controlPanel.panelPip6, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip7.focus = ZO_GamepadFocus:New(controlPanel.panelPip7, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip8.focus = ZO_GamepadFocus:New(controlPanel.panelPip8, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)		
	controlPanel.panelPip9.focus = ZO_GamepadFocus:New(controlPanel.panelPip9, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	
	controlPanel:SetHidden(true)	
	controlPanel.panelPip1:SetHidden(true)
	controlPanel.panelPip2:SetHidden(true)
	controlPanel.panelPip3:SetHidden(true)
	controlPanel.panelPip4:SetHidden(true)
	controlPanel.panelPip5:SetHidden(true)
	controlPanel.panelPip6:SetHidden(true)
	controlPanel.panelPip7:SetHidden(true)
	controlPanel.panelPip8:SetHidden(true)
	controlPanel.panelPip9:SetHidden(true)
	

	local function CreateDungeonSetsList(set, rowDungeonSet, panelPip)
		rowDungeonSet:SetParent(panelPip)
		rowDungeonSet.rowHeader:SetText (set.name)	
		-- rowDungeonSet.rowHeader:SetAnchor(LEFT, rowDungeonSet, LEFT, 0)
		-- rowDungeonSet.rowHeader:SetAnchor(RIGHT, rowDungeonSet, RIGHT, 0)
		local strBuild = ""
		for i, build in ipairs(set.build) do
			local color = nil
			if build == KPUI_SET_BUILD_DDS_STAMINA then 
				color = colors.COLOR_GREEN
			elseif build == KPUI_SET_BUILD_DDS_MAGICKA then 
				color = colors.COLOR_BLUE
			else
				color = colors.COLOR_WHITE
			end
			if strBuild == "" then
				strBuild = color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
			else
				strBuild = strBuild..color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
			end
		end
		if strBuild ~= "" then
			rowDungeonSet.rowHeaderValue:SetText (strBuild)
		end
		-- rowDungeonSet.rowHeaderValue:SetAnchor(RIGHT, rowDungeonSet.rowHeader, RIGHT, 0)		
		
		local rowDungeonSetHighlightOld = GetControl(tooltipInfo:GetName().."rowDungeonSetHighlight"..set.key)
		if rowDungeonSetHighlightOld then
			rowDungeonSetHighlight = rowDungeonSetHighlightOld
		else
			rowDungeonSetHighlight = CreateControlFromVirtual("$(parent)rowDungeonSetHighlight", tooltipInfo, "KPUI_TraitLabelHighlight", set.key)
			-- rowDungeonSetHighlight:SetAnchor(TOPLEFT, rowDungeonSet.rowHeader, TOPLEFT, -10, -2)
			-- rowDungeonSetHighlight:SetAnchor(BOTTOMRIGHT, rowDungeonSet.rowHeader, BOTTOMRIGHT, 10, 0)
		end	
		rowDungeonSetHighlight:SetParent(panelPip)
		
		-- KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS = 1
		-- KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS = 2
		-- KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS = 3
		-- KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS = 4
		local focusData = 
		{
			highlight = rowDungeonSetHighlight,
			control = rowDungeonSet.rowHeader,
			data = {
				rowFocusControl = panelPip.focus,
				rowSetIndex = set.key,
				rowSetId = set.itemId,
				rowSetName = set.name,
				rowSetBuild = set.build,
				rowSetItems = set.items,
				rowNumBonuses = set.numBonuses,
				rowSetLocations = set.locations
			},
			activate = function(control, data)
				kelaReColorDescription(true)
				kelaCurrentFocusDungeonSetPanel = data.rowFocusControl
				KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
				local name = colors.COLOR_WHITE:Colorize(string.upper(data.rowSetName))
				local strBuild = ""
				for i, build in ipairs(data.rowSetBuild) do
					local color = nil
					if build ~= KPUI_SET_BUILD_NONE then
						if build == KPUI_SET_BUILD_DDS_STAMINA then 
							color = colors.COLOR_GREEN
						elseif build == KPUI_SET_BUILD_DDS_MAGICKA then 
							color = colors.COLOR_BLUE
						else
							color = colors.COLOR_WHITE
						end
						if strBuild == "" then
							strBuild = color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
						else
							strBuild = strBuild..color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
						end
					end
				end
				KPUI_GAMEPAD_TOOLTIPS:LayoutSetTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP, name, strBuild, nil, data)
			end,
			deactivate = function(control, data) 
				kelaReColorDescription(false)
				kelaCurrentFocusDungeonSetPanel = nil
				-- KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
			end,
		}
		
		panelPip.focus:AddEntry(focusData)
	
	end


	local sets = KelaPadUI:GetSets(KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS)
	
	local countRowSet = 0
	for i, set in spairs(sets, SortByName) do
		-- local header = tree:AddNode("TB_SetsHeader", {key=i, id=set.id, name=set.name, traits=set.traits}, nil, nil)
		set.key = i
		
		countRowSet = countRowSet + 1
		
		if countRowSet >= 0 and countRowSet <= 20 then
			local rowDungeonSet1Old = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			if rowDungeonSet1Old then
				rowDungeonSet1 = rowDungeonSet1Old
			else
				if not rowDungeonSet1 then
					rowDungeonSet1 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowDungeonSet")
				else
					rowDungeonSet1 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowDungeonSet1, i, 40, nil, "rowDungeonSet")
				end
			end				
			CreateDungeonSetsList(set, rowDungeonSet1, controlPanel.panelPip1)
		elseif countRowSet > 20 and countRowSet <= 40 then
			local rowDungeonSet2Old = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			if rowDungeonSet2Old then
				rowDungeonSet2 = rowDungeonSet2Old
			else
				if not rowDungeonSet2 then
					rowDungeonSet2 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowDungeonSet")
				else
					rowDungeonSet2 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowDungeonSet2, i, 40, nil, "rowDungeonSet")
				end
			end				
			CreateDungeonSetsList(set, rowDungeonSet2, controlPanel.panelPip2)
		elseif countRowSet > 40 and countRowSet <= 60 then
			local rowDungeonSet3Old = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			if rowDungeonSet3Old then
				rowDungeonSet3 = rowDungeonSet3Old
			else
				if not rowDungeonSet3 then
					rowDungeonSet3 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowDungeonSet")
				else
					rowDungeonSet3 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowDungeonSet3, i, 40, nil, "rowDungeonSet")
				end
			end				
			CreateDungeonSetsList(set, rowDungeonSet3, controlPanel.panelPip3)
		elseif countRowSet > 60 and countRowSet <= 80 then
			local rowDungeonSet4Old = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			if rowDungeonSet4Old then
				rowDungeonSet4 = rowDungeonSet4Old
			else
				if not rowDungeonSet4 then
					rowDungeonSet4 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowDungeonSet")
				else
					rowDungeonSet4 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowDungeonSet4, i, 40, nil, "rowDungeonSet")
				end
			end				
			CreateDungeonSetsList(set, rowDungeonSet4, controlPanel.panelPip4)
		elseif countRowSet > 80 and countRowSet <= 100 then
			local rowDungeonSet5Old = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			if rowDungeonSet5Old then
				rowDungeonSet5 = rowDungeonSet5Old
			else
				if not rowDungeonSet5 then
					rowDungeonSet5 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowDungeonSet")
				else
					rowDungeonSet5 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowDungeonSet5, i, 40, nil, "rowDungeonSet")
				end
			end				
			CreateDungeonSetsList(set, rowDungeonSet5, controlPanel.panelPip5)
		elseif countRowSet > 100 and countRowSet <= 120 then
			local rowDungeonSet6Old = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			if rowDungeonSet6Old then
				rowDungeonSet6 = rowDungeonSet6Old
			else
				if not rowDungeonSet6 then
					rowDungeonSet6 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowDungeonSet")
				else
					rowDungeonSet6 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowDungeonSet6, i, 40, nil, "rowDungeonSet")
				end
			end				
			CreateDungeonSetsList(set, rowDungeonSet6, controlPanel.panelPip6)
		elseif countRowSet > 120 and countRowSet <= 140 then
			local rowDungeonSet7Old = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			if rowDungeonSet7Old then
				rowDungeonSet7 = rowDungeonSet7Old
			else
				if not rowDungeonSet7 then
					rowDungeonSet7 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowDungeonSet")
				else
					rowDungeonSet7 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowDungeonSet7, i, 40, nil, "rowDungeonSet")
				end
			end				
			CreateDungeonSetsList(set, rowDungeonSet7, controlPanel.panelPip7)
		elseif countRowSet > 140 and countRowSet <= 160 then
			local rowDungeonSet8Old = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			if rowDungeonSet8Old then
				rowDungeonSet8 = rowDungeonSet8Old
			else
				if not rowDungeonSet8 then
					rowDungeonSet8 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowDungeonSet")
				else
					rowDungeonSet8 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowDungeonSet8, i, 40, nil, "rowDungeonSet")
				end
			end				
			CreateDungeonSetsList(set, rowDungeonSet8, controlPanel.panelPip8)
		elseif countRowSet > 160 and countRowSet <= 180 then
			local rowDungeonSet9Old = GetControl(tooltipInfo:GetName().."rowDungeonSet"..i)
			if rowDungeonSet9Old then
				rowDungeonSet9 = rowDungeonSet9Old
			else
				if not rowDungeonSet9 then
					rowDungeonSet9 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowDungeonSet")
				else
					rowDungeonSet9 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowDungeonSet9, i, 40, nil, "rowDungeonSet")
				end
			end				
			CreateDungeonSetsList(set, rowDungeonSet9, controlPanel.panelPip9)
		end
	end	
	
	if kelaIndexDungeonSetPanel == 1 then
		kelaFocusDungeonSetPanel.Panel1 = controlPanel.panelPip1
		kelaFocusDungeonSetPanel.Focus1 = controlPanel.panelPip1.focus
	end
	if kelaIndexDungeonSetPanel == 2 then
		kelaFocusDungeonSetPanel.Panel2 = controlPanel.panelPip2
		kelaFocusDungeonSetPanel.Focus2 = controlPanel.panelPip2.focus
	end
	if kelaIndexDungeonSetPanel == 3 then
		kelaFocusDungeonSetPanel.Panel3 = controlPanel.panelPip3
		kelaFocusDungeonSetPanel.Focus3 = controlPanel.panelPip3.focus
	end
	if kelaIndexDungeonSetPanel == 4 then
		kelaFocusDungeonSetPanel.Panel4 = controlPanel.panelPip4
		kelaFocusDungeonSetPanel.Focus4 = controlPanel.panelPip4.focus
	end
	if kelaIndexDungeonSetPanel == 5 then
		kelaFocusDungeonSetPanel.Panel5 = controlPanel.panelPip5
		kelaFocusDungeonSetPanel.Focus5 = controlPanel.panelPip5.focus
	end
	if kelaIndexDungeonSetPanel == 6 then
		kelaFocusDungeonSetPanel.Panel6 = controlPanel.panelPip6
		kelaFocusDungeonSetPanel.Focus6 = controlPanel.panelPip6.focus
	end
	if kelaIndexDungeonSetPanel == 7 then
		kelaFocusDungeonSetPanel.Panel7 = controlPanel.panelPip7
		kelaFocusDungeonSetPanel.Focus7 = controlPanel.panelPip7.focus
	end
	if kelaIndexDungeonSetPanel == 8 then
		kelaFocusDungeonSetPanel.Panel8 = controlPanel.panelPip8
		kelaFocusDungeonSetPanel.Focus8 = controlPanel.panelPip8.focus
	end
	if kelaIndexDungeonSetPanel == 9 then
		kelaFocusDungeonSetPanel.Panel9 = controlPanel.panelPip9
		kelaFocusDungeonSetPanel.Focus9 = controlPanel.panelPip9.focus
	end

end

KelaPadUI.ButtonsMonsterSets = {}
KelaPadUI.ButtonsMonsterSets = {
	{
	keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
	callback = function()
		local currentControl = kelaGetCurrentMonsterSetsFocusControl()
		currentControl:SetActive(false, false)	
		if kelaIndexMonsterSetPanel == kelaCountMonsterSetPanel then
			kelaIndexMonsterSetPanel = 1
		else
			kelaIndexMonsterSetPanel = kelaIndexMonsterSetPanel + 1
		end
		kelaRefreshMonsterSetsPanel(true)
		local currentControl = kelaGetCurrentMonsterSetsFocusControl()
		currentControl:SetActive(true, false)	
		RefreshButtonsSetsPanel()
	end,
	ethereal = true,
	sound = SOUNDS.GAMEPAD_MENU_FORWARD,
	},
	{
	keybind = "UI_SHORTCUT_LEFT_SHOULDER",
	callback = function()
		local currentControl = kelaGetCurrentMonsterSetsFocusControl()
		currentControl:SetActive(false, false)	
		if kelaIndexMonsterSetPanel == 1 then
			kelaIndexMonsterSetPanel = kelaCountMonsterSetPanel
		else
			kelaIndexMonsterSetPanel = kelaIndexMonsterSetPanel - 1
		end
		kelaRefreshMonsterSetsPanel(true)
		local currentControl = kelaGetCurrentMonsterSetsFocusControl()
		currentControl:SetActive(true, false)	
		RefreshButtonsSetsPanel()
	end,
	ethereal = true,
	sound = SOUNDS.GAMEPAD_MENU_FORWARD,
	},
}
function InitializeButtonsMonsterSets()
	KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.ButtonsMonsterSets)
end
function RemoveButtonsMonsterSets()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.ButtonsMonsterSets)
end
function RefreshButtonsMonsterSets()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.ButtonsMonsterSets)
	KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.ButtonsMonsterSets)
end
function kelaGetCurrentMonsterSetsFocusControl()
	if kelaFocusMonsterSetPanel.Panel1 and not kelaFocusMonsterSetPanel.Panel1:IsHidden() then 
		return kelaFocusMonsterSetPanel.Focus1
	elseif kelaFocusMonsterSetPanel.Panel2 and not kelaFocusMonsterSetPanel.Panel2:IsHidden() then 
		return kelaFocusMonsterSetPanel.Focus2
	elseif kelaFocusMonsterSetPanel.Panel3 and not kelaFocusMonsterSetPanel.Panel3:IsHidden() then 
		return kelaFocusMonsterSetPanel.Focus3
	end
	return false
end
function kelaIsMonsterSetsPanelActive()
	if kelaGetCurrentMonsterSetsFocusControl() then 
		return true
	end
	return false
end
function kelaRefreshMonsterSetsPanel(activate)

	KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:AddFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))
	SCENE_MANAGER:AddFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP))	
	
	local title = GetString(KELA_STAT_GAMEPAD_SETS_SHEET_DESCRIPTION)
	local dataHeaderText = ""
	local dataText = ""
	
	KPUI_GAMEPAD_TOOLTIPS:ClearContentHeader(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP)
	KPUI_GAMEPAD_TOOLTIPS:RefreshContentHeader(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP, title, dataHeaderText, dataText)

	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	local controlPanel = GetControl(tooltipInfo:GetName().."MonsterSetsPanel"..1)
	if activate then
		controlPanel.dividerPippedHeader:SetText(GetString("KELA_STAT_GAMEPAD_SETS_PANEL_SETS_MONSTER_TITLE", kelaIndexMonsterSetPanel))
		local PIP_WIDTH = 32 
		local activePipIndex = kelaIndexMonsterSetPanel
		local numPips = kelaCountMonsterSetPanel 
		for i = 1, numPips do
			local pip 
			local pipOld = GetControl(tooltipInfo:GetName().."MonsterSetsTabBarPip"..i)
			if pipOld then
				pip = pipOld
			else
				pip = CreateControlFromVirtual("$(parent)MonsterSetsTabBarPip", tooltipInfo, "ZO_GamepadTabBarPip", i)
			end
			pip:SetParent(controlPanel.pipsControl)
			pip:SetAnchor(CENTER, controlPanel.pipsControl, CENTER, (i - 1 - (numPips - 1) / 2) * PIP_WIDTH, 0)
			local active = (activePipIndex == i)
			pip:GetNamedChild("Active"):SetHidden(not active)
			pip:GetNamedChild("Inactive"):SetHidden(active)
		end
		controlPanel.panelPip1:SetHidden(kelaIndexMonsterSetPanel ~= 1)
		controlPanel.panelPip2:SetHidden(kelaIndexMonsterSetPanel ~= 2)
		controlPanel.panelPip3:SetHidden(kelaIndexMonsterSetPanel ~= 3)
		controlPanel:SetHidden(false)		
		InitializeButtonsMonsterSets()
	else
		controlPanel.panelPip1:SetHidden(true)
		controlPanel.panelPip2:SetHidden(true)
		controlPanel.panelPip3:SetHidden(true)
		controlPanel:SetHidden(true)
		RemoveButtonsMonsterSets()
	end
	
end
function kelaInitializeMonsterSetsPanelSetAnchors(index)

	local monsterSetsPanel, rowMonsterSet1, rowMonsterSet2, rowMonsterSet3
	
	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)

	local controlPanel = GetControl(tooltipInfo:GetName().."MonsterSetsPanel"..1)
	controlPanel.dividerPippedHeader:SetAnchor(TOPLEFT, tooltipInfo, TOPLEFT, 330, -4)
	controlPanel.dividerPippedHeader:SetAnchor(BOTTOMRIGHT, tooltipInfo, BOTTOMRIGHT, 620, 32)	

	local function CreateMonsterSetsList(set, rowMonsterSet, panelPip)
		rowMonsterSet.rowHeader:SetAnchor(LEFT, rowMonsterSet, LEFT, 0)
		rowMonsterSet.rowHeader:SetAnchor(RIGHT, rowMonsterSet, RIGHT, 0)
		rowMonsterSet.rowHeaderValue:SetAnchor(RIGHT, rowMonsterSet.rowHeader, RIGHT, 0)		
		local rowMonsterSetHighlight = GetControl(tooltipInfo:GetName().."rowMonsterSetHighlight"..set.key)
		rowMonsterSetHighlight:SetAnchor(TOPLEFT, rowMonsterSet.rowHeader, TOPLEFT, -10, -2)
		rowMonsterSetHighlight:SetAnchor(BOTTOMRIGHT, rowMonsterSet.rowHeader, BOTTOMRIGHT, 10, 0)
	end

	local sets = KelaPadUI:GetSets(KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS)
	
	local countRowSet = 0
	for i, set in spairs(sets, SortByName) do
		countRowSet = countRowSet + 1
		if countRowSet >= 0 and countRowSet <= 20 then
			local rowMonsterSet1 = GetControl(tooltipInfo:GetName().."rowMonsterSet"..i)
			CreateMonsterSetsList(set, rowMonsterSet1, controlPanel.panelPip1)
		elseif countRowSet > 20 and countRowSet <= 40 then
			local rowMonsterSet2 = GetControl(tooltipInfo:GetName().."rowMonsterSet"..i)
			CreateMonsterSetsList(set, rowMonsterSet2, controlPanel.panelPip2)
		elseif countRowSet > 40 and countRowSet <= 60 then
			local rowMonsterSet3 = GetControl(tooltipInfo:GetName().."rowMonsterSet"..i)
			CreateMonsterSetsList(set, rowMonsterSet3, controlPanel.panelPip3)
		end
	end	

end
function kelaInitializeMonsterSetsPanel(index)

	local monsterSetsPanel, rowMonsterSet1, rowMonsterSet2, rowMonsterSet3

	kelaCountMonsterSetPanel = math.ceil(kelaGetCountTable(setsMonster)/20) --math.floor(kelaGetCountTable(setsMonster)/20)
	
	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP)
	if index then kelaIndexMonsterSetPanel = index end

	local controlPanel
	local controlPanelOld = GetControl(tooltipInfo:GetName().."MonsterSetsPanel"..1)
	if controlPanelOld then
		controlPanel = controlPanelOld
	else
		controlPanel = KPUI_GamepadTooltip:CreateMonsterSetsPanel(tooltipInfo, nil, 1)		
	end

	-- controlPanel.dividerPippedHeader:SetAnchor(TOPLEFT, tooltipInfo, TOPLEFT, 330, -4)
	-- controlPanel.dividerPippedHeader:SetAnchor(BOTTOMRIGHT, tooltipInfo, BOTTOMRIGHT, 620, 32)	

	controlPanel.panelPip1.focus = ZO_GamepadFocus:New(controlPanel.panelPip1, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip2.focus = ZO_GamepadFocus:New(controlPanel.panelPip2, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	controlPanel.panelPip3.focus = ZO_GamepadFocus:New(controlPanel.panelPip3, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)	
	
	controlPanel:SetHidden(true)	
	controlPanel.panelPip1:SetHidden(true)
	controlPanel.panelPip2:SetHidden(true)
	controlPanel.panelPip3:SetHidden(true)

	local function CreateMonsterSetsList(set, rowMonsterSet, panelPip)
		rowMonsterSet:SetParent(panelPip)
		rowMonsterSet.rowHeader:SetText (set.name)	
		-- rowMonsterSet.rowHeader:SetAnchor(LEFT, rowMonsterSet, LEFT, 0)
		-- rowMonsterSet.rowHeader:SetAnchor(RIGHT, rowMonsterSet, RIGHT, 0)
		local strBuild = ""
		for i, build in ipairs(set.build) do
			local color = nil
			if build == KPUI_SET_BUILD_DDS_STAMINA then 
				color = colors.COLOR_GREEN
			elseif build == KPUI_SET_BUILD_DDS_MAGICKA then 
				color = colors.COLOR_BLUE
			else
				color = colors.COLOR_WHITE
			end
			if strBuild == "" then
				strBuild = color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
			else
				strBuild = strBuild..color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
			end
		end
		if strBuild ~= "" then
			rowMonsterSet.rowHeaderValue:SetText (strBuild)
		end
		-- rowMonsterSet.rowHeaderValue:SetAnchor(RIGHT, rowMonsterSet.rowHeader, RIGHT, 0)		
		
		local rowMonsterSetHighlightOld = GetControl(tooltipInfo:GetName().."rowMonsterSetHighlight"..set.key)
		if rowMonsterSetHighlightOld then
			rowMonsterSetHighlight = rowMonsterSetHighlightOld
		else
			rowMonsterSetHighlight = CreateControlFromVirtual("$(parent)rowMonsterSetHighlight", tooltipInfo, "KPUI_TraitLabelHighlight", set.key)
			-- rowMonsterSetHighlight:SetAnchor(TOPLEFT, rowMonsterSet.rowHeader, TOPLEFT, -10, -2)
			-- rowMonsterSetHighlight:SetAnchor(BOTTOMRIGHT, rowMonsterSet.rowHeader, BOTTOMRIGHT, 10, 0)
		end	
		rowMonsterSetHighlight:SetParent(panelPip)
		
		-- KPUI_SETS_PANEL_ROW_LIST_CRAFTING_SETS = 1
		-- KPUI_SETS_PANEL_ROW_LIST_OVERLAND_SETS = 2
		-- KPUI_SETS_PANEL_ROW_LIST_DUNGEON_SETS = 3
		-- KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS = 4
		local focusData = 
		{
			highlight = rowMonsterSetHighlight,
			control = rowMonsterSet.rowHeader,
			data = {
				rowFocusControl = panelPip.focus,
				rowSetIndex = set.key,
				rowSetId = set.itemId,
				rowSetName = set.name,
				rowSetBuild = set.build,
				rowSetItems = set.items,
				rowNumBonuses = set.numBonuses,
				rowSetLocations = set.locations
			},
			activate = function(control, data)
				kelaReColorDescription(true)
				kelaCurrentFocusMonsterSetPanel = data.rowFocusControl
				KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
				local name = colors.COLOR_WHITE:Colorize(string.upper(data.rowSetName))
				local strBuild = ""
				for i, build in ipairs(data.rowSetBuild) do
					local color = nil
					if build ~= KPUI_SET_BUILD_NONE then
						if build == KPUI_SET_BUILD_DDS_STAMINA then 
							color = colors.COLOR_GREEN
						elseif build == KPUI_SET_BUILD_DDS_MAGICKA then 
							color = colors.COLOR_BLUE
						else
							color = colors.COLOR_WHITE
						end
						if strBuild == "" then
							strBuild = color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
						else
							strBuild = strBuild..color:Colorize(GetString("KELA_SET_RECOMENDED_BUILD", build))
						end
					end
				end
				KPUI_GAMEPAD_TOOLTIPS:LayoutSetTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP, name, strBuild, nil, data)
			end,
			deactivate = function(control, data) 
				kelaReColorDescription(false)
				kelaCurrentFocusMonsterSetPanel = nil
				-- KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP)
			end,
		}
		
		panelPip.focus:AddEntry(focusData)
	
	end


	local sets = KelaPadUI:GetSets(KPUI_SETS_PANEL_ROW_LIST_MONSTER_SETS)
	
	local countRowSet = 0
	for i, set in spairs(sets, SortByName) do
		-- local header = tree:AddNode("TB_SetsHeader", {key=i, id=set.id, name=set.name, traits=set.traits}, nil, nil)
		set.key = i
		
		countRowSet = countRowSet + 1
		
		if countRowSet >= 0 and countRowSet <= 20 then
			local rowMonsterSet1Old = GetControl(tooltipInfo:GetName().."rowMonsterSet"..i)
			if rowMonsterSet1Old then
				rowMonsterSet1 = rowMonsterSet1Old
			else
				if not rowMonsterSet1 then
					rowMonsterSet1 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowMonsterSet")
				else
					rowMonsterSet1 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowMonsterSet1, i, 40, nil, "rowMonsterSet")
				end
			end				
			CreateMonsterSetsList(set, rowMonsterSet1, controlPanel.panelPip1)
		elseif countRowSet > 20 and countRowSet <= 40 then
			local rowMonsterSet2Old = GetControl(tooltipInfo:GetName().."rowMonsterSet"..i)
			if rowMonsterSet2Old then
				rowMonsterSet2 = rowMonsterSet2Old
			else
				if not rowMonsterSet2 then
					rowMonsterSet2 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowMonsterSet")
				else
					rowMonsterSet2 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowMonsterSet2, i, 40, nil, "rowMonsterSet")
				end
			end				
			CreateMonsterSetsList(set, rowMonsterSet2, controlPanel.panelPip2)
		elseif countRowSet > 40 and countRowSet <= 60 then
			local rowMonsterSet3Old = GetControl(tooltipInfo:GetName().."rowMonsterSet"..i)
			if rowMonsterSet3Old then
				rowMonsterSet3 = rowMonsterSet3Old
			else
				if not rowMonsterSet3 then
					rowMonsterSet3 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, controlPanel.dividerPippedHeader, i, 100, true, "rowMonsterSet")
				else
					rowMonsterSet3 = KPUI_GamepadTooltip:CreateRowSimple(tooltipInfo, rowMonsterSet3, i, 40, nil, "rowMonsterSet")
				end
			end				
			CreateMonsterSetsList(set, rowMonsterSet3, controlPanel.panelPip3)
		end
	end	
	
	if kelaIndexMonsterSetPanel == 1 then
		kelaFocusMonsterSetPanel.Panel1 = controlPanel.panelPip1
		kelaFocusMonsterSetPanel.Focus1 = controlPanel.panelPip1.focus
	end
	if kelaIndexMonsterSetPanel == 2 then
		kelaFocusMonsterSetPanel.Panel2 = controlPanel.panelPip2
		kelaFocusMonsterSetPanel.Focus2 = controlPanel.panelPip2.focus
	end
	if kelaIndexMonsterSetPanel == 3 then
		kelaFocusMonsterSetPanel.Panel3 = controlPanel.panelPip3
		kelaFocusMonsterSetPanel.Focus3 = controlPanel.panelPip3.focus
	end

end

