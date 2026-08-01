local METER_STATISTIC_WIDTH = 1000
local METER_STATISTIC_HEIGHT = 815

local METER_STATISTIC_COLOR_HEADER_BIG = "#f6b34a"
local METER_STATISTIC_COLOR_HEADER_NORMAL = "#ffffff"
local METER_STATISTIC_COLOR_NORMAL = "#ffffff"
local METER_STATISTIC_COLOR_NO_RECORDS = "#b8b594"
local METER_STATISTIC_ROW_DM_OUT_COLOR = "#46be49"
local METER_STATISTIC_ROW_DM_IN_COLOR = "#ae3333"
local METER_STATISTIC_ROW_HEAL_COLOR = "#4687e1"

local isLoaded = false
local currentSourceUnitId = nil
local currentTargetUnitId = nil
local typeSelectionIndex = 1
local currrentCombatData = nil
local openRecord = nil
local SetRecordsFunc = function() end
local selectedItemType = AUI_COMBAT_DATA_TYPE_DAMAGE_OUT

local columnInfoListLeft = {
	[1] = 	
	{
		["Name"] = "Name",
		["Text"] = "#",
		["Width"] = "60%",
		["Height"] = "100%",
		["AllowSort"] = false,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_WIDTH / 42  .. "|" .. "outline")
	},
	[2] = 	
	{
		["Name"] = "Value",
		["Text"] = AUI.L10n.GetString("value"),
		["Width"] = "40%",
		["Height"] = "100%",
		["AllowSort"] = false,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_WIDTH / 42  .. "|" .. "outline")
	},	
}

local columnInfoListMiddle = {
	[1] = 	
	{
		["Name"] = "Name",
		["Text"] = "#",
		["Width"] = "60%",
		["Height"] = "100%",
		["AllowSort"] = false,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_WIDTH / 42  .. "|" .. "outline")
	},
	[2] = 	
	{
		["Name"] = "Value",
		["Text"] = AUI.L10n.GetString("value"),
		["Width"] = "25%",
		["Height"] = "100%",
		["AllowSort"] = false,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_WIDTH / 42  .. "|" .. "outline")
	},	
	[3] = 	
	{
		["Name"] = "Percent",
		["Text"] = "%",
		["Width"] = "15%",
		["Height"] = "100%",
		["AllowSort"] = false,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_WIDTH / 42  .. "|" .. "outline")
	},		
}

local columnInfoListRight = {
	[1] = 	
	{
		["Name"] = "Name",
		["Text"] = "#",
		["Width"] = "60%",
		["Height"] = "100%",
		["AllowSort"] = false,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_WIDTH / 42  .. "|" .. "outline")
	},
	[2] = 	
	{
		["Name"] = "Value",
		["Text"] = AUI.L10n.GetString("value"),
		["Width"] = "26%",
		["Height"] = "100%",
		["AllowSort"] = false,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_WIDTH / 42  .. "|" .. "outline")
	},			
}

local columnAbilityList = {
	[1] = 	
	{
		["Name"] = "Icon",
		["Text"] = "*",
		["Width"] = "5%",
		["Height"] = "100%",
		["AllowSort"] = false,
	},
	[2] = 	
	{
		["Name"] = "Name",
		["Text"] = AUI.L10n.GetString("ability"),
		["Width"] = "30%",
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_WIDTH / 42  .. "|" .. "outline")
	},
	[3] = 	
	{
		["Name"] = "Total",
		["Text"] = AUI.L10n.GetString("total"),
		["Width"] = "20%",		
		["Height"] = "100%",			
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_WIDTH / 42  .. "|" .. "outline")
	},
	[4] = 	
	{
		["Name"] = "%",
		["Text"] = "%",
		["Width"] = "10%",		
		["Height"] = "100%",			
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_WIDTH / 42  .. "|" .. "outline")
	},	
	[5] = 	
	{
		["Name"] = "Crit",
		["Text"] = AUI.L10n.GetString("crit"),
		["Width"] = "15%",	
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_WIDTH / 42  .. "|" .. "outline")
	},
	[6] = 	
	{
		["Name"] = "Average",
		["Text"] =  AUI.L10n.GetString("dps"),
		["Width"] = "10%",
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_WIDTH / 42  .. "|" .. "outline")
	},
	[7] = 	
	{
		["Name"] = "Hits",
		["Text"] =  AUI.L10n.GetString("hits"),
		["Width"] = "10%",	
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_WIDTH / 42  .. "|" .. "outline")
	}		
}

local function OnMouseDown(_eventCode, _button, _ctrl, _alt, _shift)
	if _button == 1 then
		AUI_MeterStatistic:SetMovable(true)
		AUI_MeterStatistic:StartMoving()
	end
end

local function OnMouseUp(_eventCode, _button, _ctrl, _alt, _shift)
	_, AUI.Settings.Combat.detail_statistic_window_position.point, _, AUI.Settings.Combat.detail_statistic_window_position.relativePoint, AUI.Settings.Combat.detail_statistic_window_position.offsetX, AUI.Settings.Combat.detail_statistic_window_position.offsetY = AUI_MeterStatistic:GetAnchor()

	AUI_MeterStatistic:SetMovable(false)
end

local function UpdateUI(_sourceId, _type, _targetId)
	if not _sourceId or not currrentCombatData then
		return
	end

	local totalValue = 0
	local totalCritValue = 0
	local avarageValue = 0	
	local totalAbilityList = nil
	local endTimeMS = 0
	local endTimeS = 0
	local unitData = nil
	
	local unitData = currrentCombatData.data[_sourceId]
	
	if unitData then
		unitData = unitData[_type]
	end
	
	if _targetId then
		unitData = unitData.targets[_targetId]		
		endTimeMS = unitData.endTimeMS
		totalValue = unitData.total
		normalDamageValue = unitData.damage
		totalCritValue = unitData.crit
		avarageValue = AUI.Combat.CalculateDPS(totalValue, endTimeMS)
		totalAbilityList = AUI.Combat.GetTotalAbilityList({unitData})	
	elseif unitData then
		endTimeMS = unitData.endTimeMS
		totalValue = AUI.Combat.GetTotalValue(unitData.targets, "total", true)
		normalDamageValue = AUI.Combat.GetTotalValue(unitData.targets, "damage", true)
		totalCritValue = AUI.Combat.GetTotalValue(unitData.targets, "crit", true)
		avarageValue = AUI.Combat.CalculateDPS(totalValue, endTimeMS)
		totalAbilityList = AUI.Combat.GetTotalAbilityList(unitData.targets)				
	end	
	
	endTimeS = AUI.Time.MS_To_S(endTimeMS)
	
	local rowColor = "#ffffff"
	
	local combatTime = currrentCombatData.combatTime

	local totalStringName = ""
	local totalStringValue = ""
	
	local averageStringName = ""
	local averageStringValue = ""
	
	local normalStringName = ""
	local normalStringValue = ""
	
	local totalCritStringName = ""
	local totalCritStringValue = ""
	
	local normalPercentValue = ""
	local critPercentValue = ""
	
	local combatTimeStringName = AUI.L10n.GetString("combat_time")
	local combatTimeStringValue = ""
	
	local measuringTimeStringName = AUI.L10n.GetString("measuring_time")
	local measuringTimeStringValue = ""		
	
	if _type == AUI_COMBAT_DATA_TYPE_DAMAGE_OUT then
		totalStringName = AUI.L10n.GetString("total_damage")
		averageStringName = AUI.L10n.GetString("dps")	
		normalStringName = AUI.L10n.GetString("damage")
		totalCritStringName = AUI.L10n.GetString("critical_damage")
		rowColor = METER_STATISTIC_ROW_DM_OUT_COLOR	
	elseif _type == AUI_COMBAT_DATA_TYPE_DAMAGE_IN then
		totalStringName = AUI.L10n.GetString("total_damage")
		averageStringName = AUI.L10n.GetString("dps")
		normalStringName = AUI.L10n.GetString("damage")
		totalCritStringName = AUI.L10n.GetString("critical_damage")
		rowColor = METER_STATISTIC_ROW_DM_IN_COLOR		
	elseif _type == AUI_COMBAT_DATA_TYPE_HEAL_OUT then
		totalStringName = AUI.L10n.GetString("total_healing")
		averageStringName = AUI.L10n.GetString("hps")

		normalStringName = AUI.L10n.GetString("healing")
		totalCritStringName = AUI.L10n.GetString("critical_healing")
		rowColor = METER_STATISTIC_ROW_HEAL_COLOR	
	elseif _type == AUI_COMBAT_DATA_TYPE_HEAL_IN then
		totalStringName = AUI.L10n.GetString("total_healing")
		averageStringName = AUI.L10n.GetString("hps")	
		normalStringName = AUI.L10n.GetString("healing")
		totalCritStringName = AUI.L10n.GetString("critical_healing")
		rowColor = METER_STATISTIC_ROW_HEAL_COLOR			
	end		

	if combatTime and combatTime > 0 then
		combatTimeStringValue = AUI.Time.GetFormatedString(combatTime, 3)
	else
		combatTimeStringValue = "-"
	end		
	
	measuringTimeStringValue = AUI.Time.GetFormatedString(endTimeS, 3)
	
	if endTimeS == 0 then
		measuringTimeStringValue = "-"
	end
	
	if totalValue > 0 then
		totalStringValue = AUI.String.ToFormatedNumber(totalValue)
	else
		totalStringValue = "-"
	end	

	if normalDamageValue > 0 then
		normalStringValue = AUI.String.ToFormatedNumber(normalDamageValue)
		normalPercentValue = AUI.String.GetPercentString(totalValue, normalDamageValue)
	else
		normalStringValue = "-"
		normalPercentValue = "-"
	end		

	if totalCritValue > 0 then
		totalCritStringValue = AUI.String.ToFormatedNumber(totalCritValue)
		critPercentValue = AUI.String.GetPercentString(totalValue, totalCritValue)
	else
		totalCritStringValue = "-"
		critPercentValue = "-"
	end		

	if avarageValue > 0 then
		averageStringValue = AUI.String.ToFormatedNumber(avarageValue)
	else
		averageStringValue = "-"
	end	
	
	local infoTableLeftColumnList = {}
	table.insert(infoTableLeftColumnList, 
	{
		[1] = 
		{
			["ControlType"] = "label",
			["Value"] = totalStringName,
			["SortType"] = "string",			
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,	
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")
		}, 
		[2] = 
		{
			["ControlType"] = "label",
			["Value"] = totalStringValue,
			["SortType"] = "string",
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,	
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")
		},										
	})			

	table.insert(infoTableLeftColumnList, 
	{
		[1] = 
		{
			["ControlType"] = "label",
			["Value"] = averageStringName,
			["SortType"] = "string",
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,	
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")				
			
		}, 
		[2] = 
		{
			["ControlType"] = "label",
			["Value"] = averageStringValue,
			["SortType"] = "string",
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")
		},										
	})			
	
	local infoTableMiddleColumnList = {}
	table.insert(infoTableMiddleColumnList, 
	{
		[1] = 
		{
			["ControlType"] = "label",
			["Value"] = normalStringName,
			["SortType"] = "string",		
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,	
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")
		}, 
		[2] = 
		{
			["ControlType"] = "label",
			["Value"] = normalStringValue,
			["SortType"] = "string",
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")				
		},	
		[3] = 
		{
			["ControlType"] = "label",
			["Value"] = normalPercentValue,
			["SortType"] = "string",
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")				
		},			
	})			

	table.insert(infoTableMiddleColumnList, 
	{
		[1] = 
		{
			["ControlType"] = "label",
			["Value"] = totalCritStringName,
			["SortType"] = "string",
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")				
			
		}, 
		[2] = 
		{
			["ControlType"] = "label",
			["Value"] = totalCritStringValue,
			["SortType"] = "string",
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")
		},	
		[3] = 
		{
			["ControlType"] = "label",
			["Value"] = critPercentValue,
			["SortType"] = "string",
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")				
		},		
	})			
	
	local infoTableRightColumnList = {}
	table.insert(infoTableRightColumnList, 
	{
		[1] = 
		{
			["ControlType"] = "label",
			["Value"] = combatTimeStringName,
			["SortType"] = "string",		
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")
		}, 
		[2] = 
		{
			["ControlType"] = "label",
			["Value"] = combatTimeStringValue,
			["SortType"] = "string",
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")
		},										
	})			

	table.insert(infoTableRightColumnList, 
	{
		[1] = 
		{
			["ControlType"] = "label",
			["Value"] = measuringTimeStringName,
			["SortType"] = "string",
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")				
			
		}, 
		[2] = 
		{
			["ControlType"] = "label",
			["Value"] = measuringTimeStringValue,
			["SortType"] = "string",
			["HorizontalTextAlign"] = TEXT_ALIGN_LEFT,
			["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")
		},										
	})			

	local itemList = {}	
	if totalAbilityList then
		for _, abilityData in pairs(totalAbilityList) do
			local avarageValue = AUI.Combat.CalculateDPS(abilityData.total, endTimeMS)
			local origAbilityName = GetAbilityName(abilityData.abilityId)
			local abilityName = zo_strformat(SI_ABILITY_NAME, origAbilityName)

			table.insert(itemList, 
			{
				[1] = 
				{
					["ControlType"] = "icon",
					["TextureFile"] = abilityData.icon,
					["TextureWidth"] = "Height",					
				}, 
				[2] = 
				{
					["ControlType"] = "label",
					["Value"] = abilityName,
					["SortValue"] = abilityName,
					["SortType"] = "string",
					["Color"] = AUI.Color.ConvertHexToRGBA(rowColor, 1),
					["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")
				},							
				[3] = 
				{
					["ControlType"] = "label",
					["Value"] = AUI.String.ToFormatedNumber(abilityData.total),
					["SortValue"] = abilityData.total,
					["SortType"] = "number",
					["Color"] = AUI.Color.ConvertHexToRGBA(rowColor, 1),
					["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")
				},	
				[4] = 
				{
					["ControlType"] = "label",
					["Value"] = AUI.String.GetPercentString(totalValue, abilityData.total),
					["SortValue"] = abilityData.crit,
					["SortType"] = "number",
					["Color"] = AUI.Color.ConvertHexToRGBA(rowColor, 1),
					["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")
				},					
				[5] = 
				{
					["ControlType"] = "label",
					["Value"] = AUI.String.GetPercentString(abilityData.total, abilityData.crit),
					["SortValue"] = abilityData.crit,
					["SortType"] = "number",
					["Color"] = AUI.Color.ConvertHexToRGBA(rowColor, 1),
					["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")
				},						
				[6] = 
				{
					["ControlType"] = "label",
					["Value"] = AUI.String.ToFormatedNumber(avarageValue),
					["SortValue"] = avarageValue,
					["SortType"] = "number",		
					["Color"] = AUI.Color.ConvertHexToRGBA(rowColor, 1),
					["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60  .. "|" .. "outline")
				},					
				[7] = 
				{
					["ControlType"] = "label",
					["Value"] = abilityData.hitCount,
					["SortValue"] = abilityData.hitCount,
					["SortType"] = "number",			
					["Color"] = AUI.Color.ConvertHexToRGBA(rowColor, 1),
					["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_WIDTH / 60 .. "|" .. "outline")
				},				
			})			
		end			

		AUI_MeterStatistic_Inner_InfoContainer_TableLeft:SetItemList(infoTableLeftColumnList)
		AUI_MeterStatistic_Inner_InfoContainer_TableMiddle:SetItemList(infoTableMiddleColumnList)
		AUI_MeterStatistic_Inner_InfoContainer_TableRight:SetItemList(infoTableRightColumnList)
		AUI_MeterStatistic_Inner_ListBox_Abilities:SetItemList(itemList)	
	
		AUI_MeterStatistic_Inner_InfoContainer_TableLeft:Refresh()
		AUI_MeterStatistic_Inner_InfoContainer_TableMiddle:Refresh()
		AUI_MeterStatistic_Inner_InfoContainer_TableRight:Refresh()
		AUI_MeterStatistic_Inner_ListBox_Abilities:Refresh()
		
		AUI_MeterStatistic_Inner_ListBox_Abilities:SetColumnText(6, averageStringName)
	end
end

local function UpdateDimensions()
	local mainWidth = METER_STATISTIC_WIDTH
	local mainHeight = METER_STATISTIC_HEIGHT
	local innerPadding = 20
	local columnPadding = 20
	local columnCount = 3
	local innerWidth = mainWidth - innerPadding - columnPadding
	local innerHeight = mainHeight - innerPadding - 310
	local infoContainerWidth = (innerWidth / columnCount) - (innerPadding / columnCount) - (columnPadding / (columnCount / 2))
	local infoContainerHeight = 105
	
	AUI_MeterStatistic:ClearAnchors()
	AUI_MeterStatistic:SetAnchor(AUI.Settings.Combat.detail_statistic_window_position.point, GUIROOT, AUI.Settings.Combat.detail_statistic_window_position.relativePoint, AUI.Settings.Combat.detail_statistic_window_position.offsetX, AUI.Settings.Combat.detail_statistic_window_position.offsetY)	
	AUI_MeterStatistic:SetDimensions(mainWidth, mainHeight)	

	AUI_MeterStatistic_HeaderLine:ClearAnchors()
	AUI_MeterStatistic_HeaderLine:SetAnchor(TOP, AUI_MeterStatistic_LabelHeader, BOTTOM, 0, 8)
	AUI_MeterStatistic_HeaderLine:SetDimensions(METER_STATISTIC_WIDTH -(innerPadding * columnCount), 2)
	
	AUI_MeterStatistic_Inner:ClearAnchors()
	AUI_MeterStatistic_Inner:SetAnchor(TOPLEFT, AUI_MeterStatistic_HeaderLine, BOTTOMLEFT, 0, 38)		
	AUI_MeterStatistic_Inner:SetDimensions(innerWidth, innerHeight)		
	
	AUI_MeterStatistic_Inner_ComboBoxSourceSelection:ClearAnchors()
	AUI_MeterStatistic_Inner_ComboBoxSourceSelection:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner, TOPLEFT, 0, 6)	
	AUI_MeterStatistic_Inner_ComboBoxSourceSelection:SetDimensions(infoContainerWidth, 32)
	
	AUI_MeterStatistic_Inner_LabelSourceSelection:ClearAnchors()
	AUI_MeterStatistic_Inner_LabelSourceSelection:SetAnchor(BOTTOM, AUI_MeterStatistic_Inner_ComboBoxSourceSelection, TOP, 0, -4)	
	
	AUI_MeterStatistic_Inner_ComboBoxTypeSelection:ClearAnchors()
	AUI_MeterStatistic_Inner_ComboBoxTypeSelection:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_ComboBoxSourceSelection, TOPRIGHT, columnPadding, 0)
	AUI_MeterStatistic_Inner_ComboBoxTypeSelection:SetDimensions(infoContainerWidth, 32)
	
	AUI_MeterStatistic_Inner_LabelTypeSelection:ClearAnchors()
	AUI_MeterStatistic_Inner_LabelTypeSelection:SetAnchor(BOTTOM, AUI_MeterStatistic_Inner_ComboBoxTypeSelection, TOP, 0, -4)				
	
	AUI_MeterStatistic_Inner_ComboBoxTargetSelection:ClearAnchors()
	AUI_MeterStatistic_Inner_ComboBoxTargetSelection:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_ComboBoxTypeSelection, TOPRIGHT, columnPadding, 0)	
	AUI_MeterStatistic_Inner_ComboBoxTargetSelection:SetDimensions(infoContainerWidth, 32)
	
	AUI_MeterStatistic_Inner_LabelTargetSelection:ClearAnchors()	
	AUI_MeterStatistic_Inner_LabelTargetSelection:SetAnchor(BOTTOM, AUI_MeterStatistic_Inner_ComboBoxTargetSelection, TOP, 0, -4)		
	
	AUI_MeterStatistic_Inner_InfoContainer:ClearAnchors()	
	AUI_MeterStatistic_Inner_InfoContainer:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_ComboBoxSourceSelection, BOTTOMLEFT, 0, 20)	
	AUI_MeterStatistic_Inner_InfoContainer:SetDimensions(innerWidth, 105)	
	
	AUI_MeterStatistic_Inner_InfoContainer_TableLeft:ClearAnchors()
	AUI_MeterStatistic_Inner_InfoContainer_TableLeft:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_InfoContainer, TOPLEFT, 0, 0)
	AUI_MeterStatistic_Inner_InfoContainer_TableLeft:SetDimensions(infoContainerWidth, infoContainerHeight)			
	AUI_MeterStatistic_Inner_InfoContainer_TableLeft:SetRowHeight(METER_STATISTIC_HEIGHT / 34)
	
	AUI_MeterStatistic_Inner_InfoContainer_TableMiddle:ClearAnchors()
	AUI_MeterStatistic_Inner_InfoContainer_TableMiddle:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_InfoContainer_TableLeft, TOPRIGHT, columnPadding, 0)
	AUI_MeterStatistic_Inner_InfoContainer_TableMiddle:SetDimensions(infoContainerWidth, infoContainerHeight)			
	AUI_MeterStatistic_Inner_InfoContainer_TableMiddle:SetRowHeight(METER_STATISTIC_HEIGHT / 34)
	
	AUI_MeterStatistic_Inner_InfoContainer_TableRight:ClearAnchors()
	AUI_MeterStatistic_Inner_InfoContainer_TableRight:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_InfoContainer_TableMiddle, TOPRIGHT, columnPadding, 0)
	AUI_MeterStatistic_Inner_InfoContainer_TableRight:SetDimensions(infoContainerWidth, infoContainerHeight)			
	AUI_MeterStatistic_Inner_InfoContainer_TableRight:SetRowHeight(METER_STATISTIC_HEIGHT / 34)
	
	AUI_MeterStatistic_Inner_ListBox_Abilities:ClearAnchors()
	AUI_MeterStatistic_Inner_ListBox_Abilities:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_InfoContainer_TableLeft, BOTTOMLEFT, 0, 20)
	AUI_MeterStatistic_Inner_ListBox_Abilities:SetDimensions(innerWidth - innerPadding, innerHeight)	
	AUI_MeterStatistic_Inner_ListBox_Abilities:SetRowHeight(METER_STATISTIC_HEIGHT / 20)
end

local function LoadRecord(_rowControl)
	local firstCellData = _rowControl.cellList[1].cellData
	if firstCellData then
		local _combatData = AUI.Settings.Combat.Fights.records[firstCellData.Value]
																																								
		if _combatData then
			_combatData.isSaved = true 
			AUI.Combat.Statistics.UpdateUI(_combatData)	
			openRecord:Close()
		end		
	end
end

local function SaveRecord(_currrentCombatData)
	if _currrentCombatData and _currrentCombatData.dateString then
		AUI.Settings.Combat.Fights.records[_currrentCombatData.dateString] = _currrentCombatData
		_currrentCombatData.isSaved = true
		AUI.Combat.Statistics.UpdateUI(_currrentCombatData)
	end
end
			
local function DeleteRecord(_rowControl)
	local firstCellData = _rowControl.cellList[1].cellData
	
	if firstCellData then
		if AUI.Settings.Combat.Fights.records[firstCellData.Value] then
			AUI.Settings.Combat.Fights.records[firstCellData.Value] = nil	
			SetRecordsFunc()
			
			local _combatData = AUI.Settings.Combat.Fights.records[firstCellData.Value]
			if _combatData then
				_combatData.isSaved = false
			end
		end
	end	
end

local function SetRecords()
	local itemList = {}
	for dateString, recordData in pairs(AUI.Settings.Combat.Fights.records) do
		local unitSourceName = ""	
		local unitTargetName = ""	
		local totalValue = 0
		local endTimeMS = 0
		local dataTypeName = ""
	
		for sourceUnitId, unitData in pairs(recordData.data) do	
			local highestTargetUnitData, type = AUI.Combat.GetHighestTargetData(unitData)
			if highestTargetUnitData and highestTargetUnitData.total then
				if not totalValue or highestTargetUnitData.total > totalValue then
					totalValue = highestTargetUnitData.total
					endTimeMS = highestTargetUnitData.endTimeMS
					unitSourceName = zo_strformat(SI_UNIT_NAME, unitData.unitName)
					unitTargetName = zo_strformat(SI_UNIT_NAME, recordData.data[highestTargetUnitData.targetUnitId].unitName)
									
					if type == AUI_COMBAT_DATA_TYPE_DAMAGE_OUT then
						dataTypeName = AUI.L10n.GetString("damage") .. " (" .. AUI.L10n.GetString("outgoing") .. ")"
					elseif type == AUI_COMBAT_DATA_TYPE_DAMAGE_IN then
						dataTypeName = AUI.L10n.GetString("damage") .. " (" .. AUI.L10n.GetString("incoming") .. ")"
					elseif type == AUI_COMBAT_DATA_TYPE_HEAL_OUT then
						dataTypeName = AUI.L10n.GetString("healing") .. " (" .. AUI.L10n.GetString("outgoing") .. ")"
					elseif type == AUI_COMBAT_DATA_TYPE_HEAL_IN then
						dataTypeName = AUI.L10n.GetString("healing") .. " (" .. AUI.L10n.GetString("incoming") .. ")"
					end
				end
			end
		end

		local average = AUI.Combat.CalculateDPS(totalValue, endTimeMS)
		
		if average == 0 then
			average = totalValue
		end
		
		table.insert(itemList, 
		{
			[1] = 
			{	
				["ControlType"] = "count",
				["Value"] = dateString,			
			}, 
			[2] = 
			{
				["SortType"] = "string",
				["ControlType"] = "label",			
				["Value"] = unitSourceName,			
			}, 			
			[3] = 
			{
				["SortType"] = "string",
				["ControlType"] = "label",
				["Value"] = unitTargetName,			
			}, 
			[4] = 
			{
				["SortType"] = "string",
				["ControlType"] = "label",
				["Value"] = dataTypeName,			
			}, 	
			[5] = 
			{
				["SortType"] = "number",
				["ControlType"] = "label",
				["Value"] = AUI.String.ToFormatedNumber(average),
				["SortValue"] = average,				
			},			
			[6] = 
			{
				["SortType"] = "number",
				["ControlType"] = "label",
				["Value"] = recordData.formatedDate,
				["SortValue"] = dateString,				
			},
			[7] = 
			{
				["ControlType"] = "button",
				["NormalTexture"] = "ESOUI/art/buttons/decline_up.dds",
				["PressedTexture"] = "ESOUI/art/buttons/decline_down.dds",		
				["MouseOverTexture"] = "ESOUI/art/buttons/decline_over.dds",	
				["OnClick"] = 	function(_eventCode, _button, _ctrl, _alt, _shift, _rowControl, _cellControl) 
									DeleteRecord(_rowControl) 
								end,
			}, 					
		})
	end

	openRecord:SetItemList(itemList)	
	openRecord:Refresh()
end

local function OpenRecordWindow()						
	SetRecords()																											
	
	openRecord:SetRowMouseDoubleClickCallback(function(_eventCode, _button, _ctrl, _alt, _shift, _rowControl) LoadRecord(_rowControl) end)	
	openRecord:SetRowMouseUpCallback(
	function(_eventCode, _button, _ctrl, _alt, _shift, _rowControl, _cellControl) 
		if _button == 2 then
			if not _cellControl.isMouseOverButton then
				AUI.ShowMouseMenu(nil, nil, 100)	
				AUI.AddMouseMenuButton("AUI_COMBAT_DELETE_RECORD", AUI.L10n.GetString("delete"), function() DeleteRecord(_rowControl) end)
			end
		end 
	end)	
	
	openRecord:SetLoadButtonCallback(function(_rowControl) LoadRecord(_rowControl) end)	
	openRecord:Show()
end

local function RemoveRecord(_currrentCombatData)
	if _currrentCombatData and _currrentCombatData.dateString then
		AUI.Combat.RemoveCombatData(_currrentCombatData.dateString)
	
		local nextRecordData = AUI.Combat.GetNextData(_currrentCombatData.dateString)
		local previousRecordData = AUI.Combat.GetPreviousData(_currrentCombatData.dateString)
		if nextRecordData then
			AUI.Combat.Statistics.UpdateUI(nextRecordData)	
		elseif previousRecordData then
			AUI.Combat.Statistics.UpdateUI(previousRecordData)
		else
			AUI.Combat.Statistics.UpdateUI()	
		end
	end
end

local function CreateUI()
	AUI_MeterStatistic:SetHandler("OnMouseDown", OnMouseDown)
	AUI_MeterStatistic:SetHandler("OnMouseUp", OnMouseUp)
	
	AUI_MeterStatistic_Inner:ClearAnchors()	
	
	AUI_MeterStatistic_LabelHeader:SetFont("$(MEDIUM_FONT)|" ..  METER_STATISTIC_WIDTH / 40 .. "|" .. "thick-outline")
	AUI_MeterStatistic_LabelHeader:SetText("AUI - " .. AUI.L10n.GetString("meter_statistic"))
	AUI_MeterStatistic_LabelHeader:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_HEADER_BIG, 1):UnpackRGBA())	
	
	AUI_MeterStatistic_LabelDate:SetFont("$(MEDIUM_FONT)|" ..  METER_STATISTIC_WIDTH / 38 .. "|" .. "thick-outline")
	AUI_MeterStatistic_LabelDate:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_HEADER_NORMAL, 1):UnpackRGBA())		
	
	AUI_MeterStatistic_LabelNoData:SetFont("$(MEDIUM_FONT)|" ..  METER_STATISTIC_WIDTH / 32 .. "|" .. "outline")
	AUI_MeterStatistic_LabelNoData:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_NO_RECORDS, 1):UnpackRGBA())

	AUI_MeterStatistic_Inner_LabelTypeSelection:SetFont("$(MEDIUM_FONT)|" ..  METER_STATISTIC_WIDTH / 50 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_LabelTypeSelection:SetText(AUI.L10n.GetString("type"))
	AUI_MeterStatistic_Inner_LabelTypeSelection:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_HEADER_NORMAL, 1):UnpackRGBA())		

	AUI_MeterStatistic_Inner_LabelSourceSelection:SetFont("$(MEDIUM_FONT)|" ..  METER_STATISTIC_WIDTH / 50 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_LabelSourceSelection:SetText(AUI.L10n.GetString("source"))
	AUI_MeterStatistic_Inner_LabelSourceSelection:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_HEADER_NORMAL, 1):UnpackRGBA())		

	AUI_MeterStatistic_Inner_LabelTargetSelection:SetFont("$(MEDIUM_FONT)|" ..  METER_STATISTIC_WIDTH / 50 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_LabelTargetSelection:SetText(AUI.L10n.GetString("target"))
	AUI_MeterStatistic_Inner_LabelTargetSelection:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_HEADER_NORMAL, 1):UnpackRGBA())	

	AUI_MeterStatistic_Inner_ComboBoxSourceSelection.dropdown = ZO_ComboBox_ObjectFromContainer(AUI_MeterStatistic_Inner_ComboBoxSourceSelection)
	local itemPlayerNone = AUI_MeterStatistic_Inner_ComboBoxSourceSelection.dropdown:CreateItemEntry("-", nil)
	AUI_MeterStatistic_Inner_ComboBoxSourceSelection.dropdown:AddItem(itemPlayerNone, ZO_COMBOBOX_SUPRESS_UPDATE)	
	
	AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown = ZO_ComboBox_ObjectFromContainer(AUI_MeterStatistic_Inner_ComboBoxTypeSelection)
	local itemDamageOut = AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:CreateItemEntry("-", nil)
	AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:AddItem(itemDamageOut, ZO_COMBOBOX_SUPRESS_UPDATE)	

	AUI_MeterStatistic_Inner_ComboBoxTargetSelection.dropdown = ZO_ComboBox_ObjectFromContainer(AUI_MeterStatistic_Inner_ComboBoxTargetSelection)	
	local itemTargetNone = AUI_MeterStatistic_Inner_ComboBoxSourceSelection.dropdown:CreateItemEntry("-", nil)	
	AUI_MeterStatistic_Inner_ComboBoxTargetSelection.dropdown:AddItem(itemTargetNone, ZO_COMBOBOX_SUPRESS_UPDATE)			
	
	AUI.CreateListBox("AUI_MeterStatistic_Inner_InfoContainer_TableLeft", AUI_MeterStatistic_Inner_InfoContainer, false, true):SetDrawTier(DT_HIGH)
	AUI.CreateListBox("AUI_MeterStatistic_Inner_InfoContainer_TableMiddle", AUI_MeterStatistic_Inner_InfoContainer, false, true):SetDrawTier(DT_HIGH)
	AUI.CreateListBox("AUI_MeterStatistic_Inner_InfoContainer_TableRight", AUI_MeterStatistic_Inner_InfoContainer, false, true):SetDrawTier(DT_HIGH)

	AUI.CreateListBox("AUI_MeterStatistic_Inner_ListBox_Abilities", AUI_MeterStatistic_Inner, false, true):SetDrawTier(DT_HIGH)
	AUI_MeterStatistic_Inner_ListBox_Abilities:SetSortKey(3)
	
	AUI_MeterStatistic_CloseButton:SetNormalTexture("ESOUI/art/buttons/decline_up.dds")
	AUI_MeterStatistic_CloseButton:SetPressedTexture("ESOUI/art/buttons/decline_down.dds")
	AUI_MeterStatistic_CloseButton:SetMouseOverTexture("ESOUI/art/buttons/decline_over.dds")
	AUI_MeterStatistic_CloseButton:SetHandler("OnClicked", AUI.Combat.Statistics.Hide)	
	
	AUI_MeterStatistic_PreviousRecord:SetNormalTexture("AUI/images/other/arrow_left.dds")
	AUI_MeterStatistic_PreviousRecord:SetPressedTexture("AUI/images/other/arrow_left_pressed.dds")
	AUI_MeterStatistic_PreviousRecord:SetMouseOverTexture("AUI/images/other/arrow_left_hover.dds")	
	AUI_MeterStatistic_PreviousRecord:SetEnabled(false)	
	AUI_MeterStatistic_PreviousRecord:SetHandler("OnMouseEnter", function() AUI.ShowTooltip(AUI.L10n.GetString("previous_record")) end)
	AUI_MeterStatistic_PreviousRecord:SetHandler("OnMouseExit", AUI.HideTooltip)
	
	AUI_MeterStatistic_NextRecord:SetNormalTexture("AUI/images/other/arrow_right.dds")
	AUI_MeterStatistic_NextRecord:SetPressedTexture("AUI/images/other/arrow_right_pressed.dds")
	AUI_MeterStatistic_NextRecord:SetMouseOverTexture("AUI/images/other/arrow_right_hover.dds")
	AUI_MeterStatistic_NextRecord:SetEnabled(false)
	AUI_MeterStatistic_NextRecord:SetHandler("OnMouseEnter", function() AUI.ShowTooltip(AUI.L10n.GetString("next_record")) end)
	AUI_MeterStatistic_NextRecord:SetHandler("OnMouseExit", AUI.HideTooltip)
	
	AUI_MeterStatistic_LoadRecord:SetNormalTexture("AUI/images/other/arrow_expand_top.dds")
	AUI_MeterStatistic_LoadRecord:SetPressedTexture("AUI/images/other/arrow_expand_top_pressed.dds")
	AUI_MeterStatistic_LoadRecord:SetMouseOverTexture("AUI/images/other/arrow_expand_top_hover.dds")
	AUI_MeterStatistic_LoadRecord:SetEnabled(false)
	AUI_MeterStatistic_LoadRecord:SetHandler("OnMouseEnter", function() AUI.ShowTooltip(AUI.L10n.GetString("load_record")) end)
	AUI_MeterStatistic_LoadRecord:SetHandler("OnMouseExit", AUI.HideTooltip)		
	AUI_MeterStatistic_LoadRecord:SetHandler("OnClicked", 
	function()
		OpenRecordWindow()
	end)	
	
	AUI_MeterStatistic_SaveRecord:SetNormalTexture("AUI/images/other/save.dds")
	AUI_MeterStatistic_SaveRecord:SetPressedTexture("AUI/images/other/save_pressed.dds")
	AUI_MeterStatistic_SaveRecord:SetMouseOverTexture("AUI/images/other/save_hover.dds")
	AUI_MeterStatistic_SaveRecord:SetEnabled(false)
	AUI_MeterStatistic_SaveRecord:SetHandler("OnMouseEnter", function() AUI.ShowTooltip(AUI.L10n.GetString("save_record")) end)
	AUI_MeterStatistic_SaveRecord:SetHandler("OnMouseExit", AUI.HideTooltip)	
	AUI_MeterStatistic_SaveRecord:SetHandler("OnClicked", 
	function()
		SaveRecord(currrentCombatData)
	end)		
	
	AUI_MeterStatistic_DeleteRecord:SetNormalTexture("AUI/images/other/recycle.dds")
	AUI_MeterStatistic_DeleteRecord:SetPressedTexture("AUI/images/other/recycle_pressed.dds")
	AUI_MeterStatistic_DeleteRecord:SetMouseOverTexture("AUI/images/other/recycle_hover.dds")
	AUI_MeterStatistic_DeleteRecord:SetEnabled(false)
	AUI_MeterStatistic_DeleteRecord:SetHandler("OnMouseEnter", function() AUI.ShowTooltip(AUI.L10n.GetString("remove_record")) end)
	AUI_MeterStatistic_DeleteRecord:SetHandler("OnMouseExit", AUI.HideTooltip)	
	AUI_MeterStatistic_DeleteRecord:SetHandler("OnClicked", 
	function()
		RemoveRecord(currrentCombatData)
	end)		
	
	AUI_MeterStatistic_Inner_ButtonPostCombatStatic:SetAnchor(CENTER, AUI_MeterStatistic, BOTTOM, 0, -28)
	AUI_MeterStatistic_Inner_ButtonPostCombatStatic:SetDimensions(200, 30)	
	AUI_MeterStatistic_Inner_ButtonPostCombatStatic:SetHandler("OnClicked", function() AUI.Combat.PostCombatStatistics(currentSourceUnitId, currentSelectedViewMode, currentTargetUnitId) end)

	AUI_MeterStatistic_Inner_ButtonPostCombatStatic_Text:SetFont("$(MEDIUM_FONT)|" ..  18 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_ButtonPostCombatStatic_Text:SetText(AUI.L10n.GetString("post_in_chat"))
	AUI_MeterStatistic_Inner_ButtonPostCombatStatic_Text:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_HEADER_NORMAL, 1):UnpackRGBA())	

	UpdateDimensions()
	
	local columnList = {
		[1] = 	
		{
			["Name"] = "Index",
			["Text"] = AUI.L10n.GetString("*"),
			["Width"] = "10%",
			["Height"] = "100%",
			["AllowSort"] = false,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},
		[2] = 	
		{
			["Name"] = "Source",
			["Text"] = AUI.L10n.GetString("source"),
			["Width"] = "20%",
			["Height"] = "100%",
			["AllowSort"] = false,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},		
		[3] = 	
		{
			["Name"] = "Target",
			["Text"] = AUI.L10n.GetString("target"),
			["Width"] = "15%",
			["Height"] = "100%",	
			["AllowSort"] = false,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},		
		[4] = 	
		{
			["Name"] = "SortType",
			["Text"] = AUI.L10n.GetString("SortType"),
			["Width"] = "15%",
			["Height"] = "100%",
			["AllowSort"] = false,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},	
		[5] = 	
		{
			["Name"] = "Average",
			["Text"] = AUI.L10n.GetString("dps"),
			["Width"] = "15%",
			["Height"] = "100%",
			["AllowSort"] = true,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},			
		[6] = 	
		{
			["Name"] = "Date",
			["Text"] = AUI.L10n.GetString("date"),
			["Width"] = "15%",
			["Height"] = "100%",
			["AllowSort"] = true,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},	
		[7] = 	
		{
			["Name"] = "Delete",
			["Text"] = AUI.L10n.GetString("delete"),
			["Width"] = "Height",
			["Height"] = "100%",
			["AllowSort"] = false,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},			
	}	

	AUI_MeterStatistic_Inner_InfoContainer_TableLeft:SetColumnList(columnInfoListLeft)
	AUI_MeterStatistic_Inner_InfoContainer_TableMiddle:SetColumnList(columnInfoListMiddle)
	AUI_MeterStatistic_Inner_InfoContainer_TableRight:SetColumnList(columnInfoListRight)
	AUI_MeterStatistic_Inner_ListBox_Abilities:SetColumnList(columnAbilityList)	
	
	openRecord = AUI.CreateOpenDataDialog("AUI_LOAD_COMBAT_RECORD", AUI_MeterStatistic, AUI.L10n.GetString("records"))
	openRecord:SetSortKey(6)
	openRecord:SetColumnList(columnList)
end

local function SortNameList(list1, list2)
	if list1[AUI_COMBAT_DATA_TYPE_DAMAGE_OUT] and list2[AUI_COMBAT_DATA_TYPE_DAMAGE_OUT] then
		if list1[AUI_COMBAT_DATA_TYPE_DAMAGE_OUT].total > list2[AUI_COMBAT_DATA_TYPE_DAMAGE_OUT].total then
			return true
		end
	end
end

local function SortTargetList(list1, list2)
	if list1.total > list2.total then
		return true
	end	
end

local function UpdateTargetData(_sourceId, _data, _type)
	AUI_MeterStatistic_Inner_ComboBoxTargetSelection.dropdown:ClearItems()	
	
	local mainTargetItem = AUI_MeterStatistic_Inner_ComboBoxTargetSelection.dropdown:CreateItemEntry(AUI.L10n.GetString("all"),
	function(choice, choiceText) 
		currentTargetUnitId = nil
		UpdateUI(_sourceId, _type)
	end)		
	AUI_MeterStatistic_Inner_ComboBoxTargetSelection.dropdown:AddItem(mainTargetItem, ZO_COMBOBOX_SUPRESS_UPDATE)
						
	if _data then
		local targetList = {}
		for _, unitData in pairs(_data.targets) do
			table.insert(targetList, unitData)
		end		
	
		table.sort(targetList, SortTargetList)
		for _, targetData in pairs(targetList) do
			if targetData then
				local combatData = currrentCombatData.data[targetData.targetUnitId]
				if combatData then			
					local targetItem = AUI_MeterStatistic_Inner_ComboBoxTargetSelection.dropdown:CreateItemEntry(zo_strformat(SI_UNIT_NAME, combatData.unitName),	
					function(choice, choiceText)
			
						currentTargetUnitId = targetData.targetUnitId
						UpdateUI(_sourceId, _type, targetData.targetUnitId)
					end)
					AUI_MeterStatistic_Inner_ComboBoxTargetSelection.dropdown:AddItem(targetItem, ZO_COMBOBOX_SUPRESS_UPDATE)				
				end
			end		
		end	
	end
	
	currentSelectedViewMode = _type
end

function AUI.Combat.Statistics.UpdateUI(_combatData)
	if not isLoaded then
		return
	end		

	if not _combatData then
		_combatData = AUI.Combat.GetLastData()
	end
	
	local error, errorMessage  = AUI.Combat.CheckError()
	
	if _combatData and not error or _combatData and _combatData.isSaved then
		local error, errorMessage  = AUI.Combat.CheckError()

		local selectedSourceIndex = 1
		local playerSourceId = AUI.Combat.GetPlayerSourceId()				
	
		currrentCombatData = _combatData
	
		AUI_MeterStatistic_Inner_ComboBoxSourceSelection.dropdown:ClearItems()		
		local nameList = {}
		for _, unitData in pairs(_combatData.data) do
			if unitData.init then		
				table.insert(nameList, unitData)
			end
		end

		table.sort(nameList, SortNameList)
		local itemCount = 1
		local typeSelection = {}
		local allowSelectAssign = false
		for count, unitData in pairs(nameList) do
			if unitData and unitData.init then			
				if playerSourceId and playerSourceId == unitId then
					selectedSourceIndex = count
				end					
				
				local playerItem = AUI_MeterStatistic_Inner_ComboBoxSourceSelection.dropdown:CreateItemEntry(unitData.unitName,	
				function(choice, choiceText)
					AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:ClearItems()				
					
					if unitData[AUI_COMBAT_DATA_TYPE_DAMAGE_OUT] and AUI.Table.HasContent(unitData[AUI_COMBAT_DATA_TYPE_DAMAGE_OUT]) then
						typeSelection[AUI_COMBAT_DATA_TYPE_DAMAGE_OUT] = itemCount
						local itemDamageOut = AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:CreateItemEntry(AUI.L10n.GetString("damage") .. " (" .. AUI.L10n.GetString("outgoing") .. ")", 
						function() 
							UpdateTargetData(unitData.sourceUnitId, unitData[AUI_COMBAT_DATA_TYPE_DAMAGE_OUT], AUI_COMBAT_DATA_TYPE_DAMAGE_OUT)

							if allowSelectAssign then
								selectedItemType = AUI_COMBAT_DATA_TYPE_DAMAGE_OUT
							end
						
							AUI_MeterStatistic_Inner_ComboBoxTargetSelection.dropdown:SelectItemByIndex(1)
						end)						
						AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:AddItem(itemDamageOut, ZO_COMBOBOX_SUPRESS_UPDATE)
						itemCount = itemCount + 1
					end
					
					if unitData[AUI_COMBAT_DATA_TYPE_HEAL_OUT] and AUI.Table.HasContent(unitData[AUI_COMBAT_DATA_TYPE_HEAL_OUT]) then
						typeSelection[AUI_COMBAT_DATA_TYPE_HEAL_OUT] = itemCount				
						local itemDamageOut = AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:CreateItemEntry(AUI.L10n.GetString("healing") .. " (" .. AUI.L10n.GetString("outgoing") .. ")",						
						function() 
							UpdateTargetData(unitData.sourceUnitId, unitData[AUI_COMBAT_DATA_TYPE_HEAL_OUT], AUI_COMBAT_DATA_TYPE_HEAL_OUT)
							
							if allowSelectAssign then
								selectedItemType = AUI_COMBAT_DATA_TYPE_HEAL_OUT
							end
							
							AUI_MeterStatistic_Inner_ComboBoxTargetSelection.dropdown:SelectItemByIndex(1)
						end)						
						AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:AddItem(itemDamageOut, ZO_COMBOBOX_SUPRESS_UPDATE)
						itemCount = itemCount + 1						
					end
					
					if unitData[AUI_COMBAT_DATA_TYPE_DAMAGE_IN] and AUI.Table.HasContent(unitData[AUI_COMBAT_DATA_TYPE_DAMAGE_IN].targets) then
						typeSelection[AUI_COMBAT_DATA_TYPE_DAMAGE_IN] = itemCount
						local itemDamageIn = AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:CreateItemEntry(AUI.L10n.GetString("damage") .. " (" .. AUI.L10n.GetString("incoming") .. ")", 
						function() 
							UpdateTargetData(unitData.sourceUnitId, unitData[AUI_COMBAT_DATA_TYPE_DAMAGE_IN], AUI_COMBAT_DATA_TYPE_DAMAGE_IN)
							
							if allowSelectAssign then
								selectedItemType = AUI_COMBAT_DATA_TYPE_DAMAGE_IN
							end
							
							AUI_MeterStatistic_Inner_ComboBoxTargetSelection.dropdown:SelectItemByIndex(1)
						end)						
						AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:AddItem(itemDamageIn, ZO_COMBOBOX_SUPRESS_UPDATE)
						itemCount = itemCount + 1
					end				
				
					if unitData[AUI_COMBAT_DATA_TYPE_HEAL_IN] and AUI.Table.HasContent(unitData[AUI_COMBAT_DATA_TYPE_HEAL_IN].targets) then
						typeSelection[AUI_COMBAT_DATA_TYPE_HEAL_IN] = itemCount
						local itemDamageIn = AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:CreateItemEntry(AUI.L10n.GetString("healing") .. " (" .. AUI.L10n.GetString("incoming") .. ")", 
						function() 
							UpdateTargetData(unitData.sourceUnitId, unitData[AUI_COMBAT_DATA_TYPE_HEAL_IN], AUI_COMBAT_DATA_TYPE_HEAL_IN)

							if allowSelectAssign then
								selectedItemType = AUI_COMBAT_DATA_TYPE_HEAL_IN
							end
							
							AUI_MeterStatistic_Inner_ComboBoxTargetSelection.dropdown:SelectItemByIndex(1)
						end)						
						AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:AddItem(itemDamageIn, ZO_COMBOBOX_SUPRESS_UPDATE)
					end	
					
					currentSourceUnitId = unitData.sourceUnitId
			
					allowSelectAssign = false
			
					if typeSelection[selectedItemType] and typeSelection[selectedItemType] <= itemCount then
						AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:SelectItemByIndex(typeSelection[selectedItemType])	
					else
						AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:SelectItemByIndex(1)	
					end						

					allowSelectAssign = true
					
					AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:SelectItemByIndex(1)
					AUI_MeterStatistic_Inner_ComboBoxTargetSelection.dropdown:SelectItemByIndex(1)
				end)
				
				AUI_MeterStatistic_Inner_ComboBoxSourceSelection.dropdown:AddItem(playerItem, ZO_COMBOBOX_SUPRESS_UPDATE)
			end
		end	

		AUI_MeterStatistic_Inner_ComboBoxSourceSelection.dropdown:SelectItemByIndex(selectedSourceIndex)		
		AUI_MeterStatistic_Inner_ComboBoxTypeSelection.dropdown:SelectItemByIndex(1)
		AUI_MeterStatistic_Inner_ComboBoxTargetSelection.dropdown:SelectItemByIndex(1)				
		
		AUI_MeterStatistic_Inner:SetHidden(false)
		AUI_MeterStatistic_LabelNoData:SetHidden(true)
		
		local nextRecordData = AUI.Combat.GetNextData(_combatData.dateString)

		if nextRecordData then
			AUI_MeterStatistic_NextRecord:SetEnabled(true)	

			AUI_MeterStatistic_NextRecord:SetHandler("OnClicked", 
			function()
				AUI.Combat.Statistics.UpdateUI(nextRecordData)
			end)
			
			AUI_MeterStatistic_NextRecord:SetHidden(false)
		else
			AUI_MeterStatistic_NextRecord:SetEnabled(false)
			AUI_MeterStatistic_NextRecord:SetHidden(true)
		end		
		
		local previousRecordData = AUI.Combat.GetPreviousData(_combatData.dateString)
		
		if previousRecordData then
			AUI_MeterStatistic_PreviousRecord:SetEnabled(true)	

			AUI_MeterStatistic_PreviousRecord:SetHandler("OnClicked", 
			function()
				AUI.Combat.Statistics.UpdateUI(previousRecordData)		
			end)																							
			
			AUI_MeterStatistic_PreviousRecord:SetHidden(false)
		else
			AUI_MeterStatistic_PreviousRecord:SetEnabled(false)
			AUI_MeterStatistic_PreviousRecord:SetHidden(true)														
		end
		
		if _combatData.isSaved then																				
			AUI_MeterStatistic_SaveRecord:SetEnabled(false)
		else
			AUI_MeterStatistic_SaveRecord:SetEnabled(true)
		end
		
		AUI_MeterStatistic_DeleteRecord:SetEnabled(true)
		
		AUI_MeterStatistic_LabelDate:SetText(_combatData.formatedDate)													
		AUI_MeterStatistic_LabelDate:SetHidden(false)																																									
	else
		AUI_MeterStatistic_LabelNoData:SetText(errorMessage)									
		AUI_MeterStatistic_Inner:SetHidden(true)													
		AUI_MeterStatistic_LabelNoData:SetHidden(false)
		AUI_MeterStatistic_NextRecord:SetHidden(true)
		AUI_MeterStatistic_PreviousRecord:SetHidden(true)			
		AUI_MeterStatistic_LabelDate:SetHidden(true)														
		AUI_MeterStatistic_SaveRecord:SetEnabled(false)
		AUI_MeterStatistic_DeleteRecord:SetEnabled(false)												
		
		currrentCombatData = nil
	end

	if AUI.Settings.Combat.Fights.records then
		AUI_MeterStatistic_LoadRecord:SetEnabled(true)		
	else
		AUI_MeterStatistic_LoadRecord:SetEnabled(false)	
	end	
end

function AUI.Combat.Statistics.IsShow()
	return not AUI_MeterStatistic:IsHidden()
end

function AUI.Combat.Statistics.Show()
	AUI.Combat.Statistics.UpdateUI()
	
	if not AUI.Combat.Statistics.IsShow() then
		SCENE_MANAGER:Show("AUI_METER_STATISTIC_SCENE")
	end	
end

function AUI.Combat.Statistics.Hide()
	if AUI.Combat.Statistics.IsShow() then
		openRecord:Close()
		SCENE_MANAGER:Hide("AUI_METER_STATISTIC_SCENE")
	end
end

function AUI.Combat.Statistics.Toggle()
	if AUI.Combat.IsEnabled() then
		if AUI.Combat.Statistics.IsShow() then
			AUI.Combat.Statistics.Hide()
		else
			AUI.Combat.Statistics.Show()
			SetGameCameraUIMode(true)
		end
	end
end

function AUI.Combat.Statistics.Load()
	if isLoaded then
		return
	end	

	SetRecordsFunc = function(...) SetRecords(...) end
	
	local scene = ZO_Scene:New("AUI_METER_STATISTIC_SCENE", SCENE_MANAGER)
	scene:AddFragment(ZO_HUDFadeSceneFragment:New(AUI_MeterStatistic))
    scene:RegisterCallback("StateChange",
		function(oldState, newState) 
			if newState == SCENE_SHOWING then 
				AUI.Combat.Statistics.UpdateUI() 
			elseif newState == SCENE_HIDING then 
				openRecord:Close() 
			end 
		end)	

	CreateUI()
	
	isLoaded = true	
end