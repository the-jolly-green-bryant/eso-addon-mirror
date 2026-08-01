local METER_STATISTIC_WIDTH = 1040
local METER_STATISTIC_HEIGHT = 800

local METER_STATISTIC_FONT_SIZE = 14
local METER_STATISTIC_COLUMN_SIZE = 18
local METER_STATISTIC_ROW_HEIGHT = 24

local METER_STATISTIC_COLOR_HEADER_BIG = "#f6b34a"
local METER_STATISTIC_COLOR_HEADER_NORMAL = "#ffffff"
local METER_STATISTIC_COLOR_NORMAL = "#ffffff"
local METER_STATISTIC_COLOR_NO_RECORDS = "#b8b594"
local METER_STATISTIC_COLOR_VERSION = "#b8b594"
local METER_STATISTIC_COLOR_POST_IN_CHAT = "#b8b594"

local METER_STATISTIC_SAVED_LIMIT_COUNT = 30	
local METER_STATISTIC_COLOR_LIMIT_NOT_REACHED = "#ffffff"
local METER_STATISTIC_COLOR_LIMIT_REACHED = "#ff0000"

local gIsLoaded = false
local gOpenRecordDialog = nil

local gVisbleData = 
{
	sourceUnitId = nil,
	targetUnitId = nil,
	visibleCombatData = nil,
	selectedDamageType = AUI_COMBAT_DATA_TYPE_DAMAGE_OUT,
	numBuffs = 0,
	numDebuffs = 0	
}

local gSetRecordsFunc = nil
local gSelectedItemType = AUI_COMBAT_DATA_TYPE_DAMAGE_OUT

	local loadRecordList = {
		[1] = 	
		{
			["Name"] = "Index",
			["Text"] = AUI.L10n.GetString("*"),
			["Width"] = "5%",
			["Height"] = "100%",
			["AllowSort"] = false,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},
		[2] = 	
		{
			["Name"] = "Icon",
			["Text"] = "*",
			["Width"] = 50,
			["Height"] = "100%",
			["AllowSort"] = false,
		},			
		[3] = 	
		{
			["Name"] = "Target",
			["Text"] = AUI.L10n.GetString("character"),
			["Width"] = "15%",
			["Height"] = "100%",
			["AllowSort"] = false,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},		
		[4] = 	
		{
			["Name"] = "Target",
			["Text"] = AUI.L10n.GetString("target"),
			["Width"] = "30%",
			["Height"] = "100%",
			["AllowSort"] = false,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},				
		[5] = 	
		{
			["Name"] = "SortType",
			["Text"] = AUI.L10n.GetString("type"),
			["Width"] = "10%",
			["Height"] = "100%",
			["AllowSort"] = false,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},	
		[6] = 	
		{
			["Name"] = "Average",
			["Text"] = AUI.L10n.GetString("dps"),
			["Width"] = "10%",
			["Height"] = "100%",
			["AllowSort"] = true,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},			
		[7] = 	
		{
			["Name"] = "Date",
			["Text"] = AUI.L10n.GetString("date"),
			["Width"] = "20%",
			["Height"] = "100%",
			["AllowSort"] = true,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},	
		[8] = 	
		{
			["Name"] = "Delete",
			["Text"] = "X",
			["Width"] = "Height",
			["Height"] = "100%",
			["AllowSort"] = false,
			["Font"] = ("$(BOLD_FONT)|" .. 16  .. "|" .. "outline")
		},			
	}	

local sourceUnitsList = {
	[1] = 	
	{
		["Name"] = "Name",
		["Text"] = AUI.L10n.GetString("source"),
		["Width"] = "74%",
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_COLUMN_SIZE  .. "|" .. "outline")
	},
	[2] = 	
	{
		["Name"] = "DPS",
		["Text"] = AUI.L10n.GetString("dps"),
		["Width"] = "26%",
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_COLUMN_SIZE  .. "|" .. "outline")
	}		
}

local targetUnitsList = {
	[1] = 	
	{
		["Name"] = "Name",
		["Text"] = AUI.L10n.GetString("target"),
		["Width"] = "74%",
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_COLUMN_SIZE  .. "|" .. "outline")
	},
	[2] = 	
	{
		["Name"] = "DPS",
		["Text"] = AUI.L10n.GetString("dps"),
		["Width"] = "26%",
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_COLUMN_SIZE  .. "|" .. "outline")
	}		
}

local columnAbilityList = {
	[1] = 	
	{
		["Name"] = "Icon",
		["Text"] = "*",
		["Width"] = 50,
		["Height"] = "100%",
		["AllowSort"] = false,
	},
	[2] = 	
	{
		["Name"] = "Name",
		["Text"] = AUI.L10n.GetString("ability"),
		["Width"] = "35%",
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_COLUMN_SIZE  .. "|" .. "outline")
	},
	[3] = 	
	{
		["Name"] = "Total",
		["Text"] = AUI.L10n.GetString("total"),
		["Width"] = "20%",		
		["Height"] = "100%",			
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_COLUMN_SIZE .. "|" .. "outline")
	},
	[4] = 	
	{
		["Name"] = "Crit",
		["Text"] = AUI.L10n.GetString("crit"),
		["Width"] = "18%",	
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_COLUMN_SIZE .. "|" .. "outline")
	},
	[5] = 	
	{
		["Name"] = "Average",
		["Text"] =  AUI.L10n.GetString("dps"),
		["Width"] = "10%",
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_COLUMN_SIZE .. "|" .. "outline")
	},
	[6] = 	
	{
		["Name"] = "Hits",
		["Text"] =  "#",
		["Width"] = "10%",	
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_COLUMN_SIZE .. "|" .. "outline")
	}		
}

local columnBuffList = {
	[1] = 	
	{
		["Name"] = "Icon",
		["Text"] = "*",
		["Width"] = 50,
		["Height"] = "100%",
		["AllowSort"] = false,
	},
	[2] = 	
	{
		["Name"] = "Name",
		["Text"] = AUI.L10n.GetString("buff"),
		["Width"] = "35%",
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_COLUMN_SIZE  .. "|" .. "outline")
	},
	[3] = 	
	{
		["Name"] = "Uptime",
		["Text"] = AUI.L10n.GetString("uptime"),
		["Width"] = "20%",	
		["Height"] = "100%",
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_COLUMN_SIZE .. "|" .. "outline")
	},
	[4] = 	
	{
		["Name"] = "Count",
		["Text"] = "#",
		["Width"] = "10%",		
		["Height"] = "100%",			
		["AllowSort"] = true,
		["Font"] = ("$(BOLD_FONT)|" .. METER_STATISTIC_COLUMN_SIZE .. "|" .. "outline")
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

local function SortTargetList(list1, list2)
	if list1.total > list2.total then
		return true
	end	
end

local function GetNumRecords()
	local recordCount = 0
	for i, data in pairs(AUI_FightData.records) do
		recordCount = recordCount + 1
	end
	
	return recordCount
end

local function GetNummBuffs(_unitData, _effectType)
	local totalBuffList = _unitData.buffs[_effectType]				
	if totalBuffList then
		local numBuffs = 0
		for effectName, buffData in pairs(totalBuffList) do
			numBuffs = numBuffs + 1
		end
		
		return numBuffs
	end
	
	return 0
end

local function UpdateBuffList(_unitData, _effectType)
	local buffItemList = {}	
	if _unitData.buffs then
		local totalBuffList = _unitData.buffs[_effectType]				
		if totalBuffList then		
			for effectName, buffData in pairs(totalBuffList) do
				local upTime = AUI.Time.GetFormatedString(AUI.Time.MS_To_S(buffData.totalActiveTimeMS))
				local upTimePercent = AUI.Math.Round(((buffData.totalActiveTimeMS / gVisbleData.visibleCombatData.combatTime) / 1000) * 100)
				local buffNameFormated =  zo_strformat(SI_ABILITY_NAME, effectName)
			
				table.insert(buffItemList, 
				{
					[1] = 
					{
						["ControlType"] = "icon",
						["TextureFile"] = buffData.buffIcon,
						["TextureWidth"] = "Height",					
					}, 
					[2] = 
					{
						["ControlType"] = "label",
						["Value"] = buffNameFormated,
						["SortValue"] = buffNameFormated,
						["SortType"] = "string",
						["Color"] = AUI.Color.ConvertHexToRGBA("#ffffff", 1),
						["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_ROW_HEIGHT / 1.5  .. "|" .. "outline")
					},	
					[3] = 
					{
						["ControlType"] = "label",
						["Value"] =	upTime .. " (" .. upTimePercent .. "%)",
						["SortValue"] = buffData.totalActiveTimeMS,
						["SortType"] = "number",
						["Color"] = AUI.Color.ConvertHexToRGBA("#ffffff", 1),
						["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_ROW_HEIGHT / 1.5 .. "|" .. "outline")
					},						
					[4] = 
					{
						["ControlType"] = "label",
						["Value"] = buffData.count,
						["SortValue"] = buffData.count,
						["SortType"] = "number",
						["Color"] = AUI.Color.ConvertHexToRGBA("#ffffff", 1),
						["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_ROW_HEIGHT / 1.5 .. "|" .. "outline")
					}										
				})			
			end					
		end	
	end
	
	AUI_MeterStatistic_Inner_ListBox_Buffs:SetItemList(buffItemList)
	
	if _effectType == BUFF_EFFECT_TYPE_BUFF then	
		AUI_MeterStatistic_Inner_ListBox_Buffs:SetColumnText(2, "buff")	
	else
		AUI_MeterStatistic_Inner_ListBox_Buffs:SetColumnText(2, "debuff")	
	end
	
	AUI_MeterStatistic_Inner_ListBox_Buffs:Refresh()
	
	gVisbleData.numBuffs = GetNummBuffs(gVisbleData.visibleCombatData.data[gVisbleData.sourceUnitId], BUFF_EFFECT_TYPE_BUFF)
	gVisbleData.numDebuffs = GetNummBuffs(gVisbleData.visibleCombatData.data[gVisbleData.sourceUnitId], BUFF_EFFECT_TYPE_DEBUFF)
	
	if gVisbleData.numBuffs <= 0 then
		AUI_MeterStatistic_Inner_PanelLeft_ButtonShowBuffs:SetState(BSTATE_DISABLED, true)	
	end	

	if gVisbleData.numDebuffs <= 0 then
		AUI_MeterStatistic_Inner_PanelLeft_ButtonShowDebuffs:SetState(BSTATE_DISABLED, true)	
	end		
end

local function UpdateUI(_sourceId, _damageType, _targetId)
	if not _sourceId or not gVisbleData.visibleCombatData then
		return
	end

	gVisbleData.targetUnitId = _targetId

	local unitData = gVisbleData.visibleCombatData.data[_sourceId]	
	
	local unitTypeData = nil
			
	local header1Name = ""
	local statLeft1Name = ""	
	local statLeft2Name = ""
	local statLeft3Name = ""
	local statLeft4Name = ""		
	local statLeft5Name = ""	
	local statLeft6Name = ""	
	local statLeft7Name = AUI.L10n.GetString("combat_time")	
	local statLeft8Name = AUI.L10n.GetString("measuring_time")		

	local averageTypeName = ""

	if gVisbleData.targetUnitId then
		unitTypeData = unitData[_damageType].targets[gVisbleData.targetUnitId]
	else
		unitTypeData = unitData[_damageType]
	end

	if not gVisbleData.targetUnitId then
		local targetNameList = {}	
		local targetUnitData = gVisbleData.visibleCombatData.data[gVisbleData.sourceUnitId][_damageType].targets
		for unitId, unitData in pairs(AUI.Table.Copy(targetUnitData)) do
			unitData.targetUnitId = unitId
			table.insert(targetNameList, unitData)
		end		

		table.sort(targetNameList, SortTargetList)				
		
		local targetItemList = {}			
		for i, unitData in pairs(targetNameList) do
			if unitData then	
				local calculatedUnitData = AUI.Combat.GetCalculatedUnitData(gVisbleData.sourceUnitId, gVisbleData.visibleCombatData.data, _damageType, unitData.targetUnitId)
				
				table.insert(targetItemList, 
				{
					[1] = 
					{
						["ControlType"] = "label",
						["Value"] = zo_strformat(SI_UNIT_NAME, unitData.unitName),
						["SortValue"] = unitData.unitName,
						["SortType"] = "string",
						["Color"] = AUI.Color.ConvertHexToRGBA("#ffffff", 1),
						["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_ROW_HEIGHT / 1.5  .. "|" .. "outline"),
						["CustomData"] = 
						{
							["targetUnitId"] = unitData.targetUnitId
						}
					},
					[2] = 
					{
						["ControlType"] = "label",
						["Value"] = calculatedUnitData.average,
						["SortValue"] = calculatedUnitData.average,
						["SortType"] = "string",
						["Color"] = AUI.Color.ConvertHexToRGBA("#ffffff", 1),
						["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_ROW_HEIGHT / 1.5  .. "|" .. "outline"),
						["CustomData"] = 
						{
							["targetUnitId"] = unitData.targetUnitId
						}
					}				
				})
			end
		end		

		AUI_MeterStatistic_Inner_ListBox_TargetUnits:SetItemList(targetItemList)			
		AUI_MeterStatistic_Inner_ListBox_TargetUnits:Refresh()	
	end

	local statLeft1Value = 0	
	local statLeft2Value = 0
	local statLeft3Value = 0
	local statLeft4Value = 0	
	local statLeft5Value = 0
	local statLeft6Value = 0	

	local statMiddle1Value = 0	
	local statMiddle2Value = 0	
	local statMiddle3Value = 0	
	local statMiddle4Value = 0	
	local statMiddle5Value = 0	
	local statMiddle6Value = 0	
	
	local statRight1Value = 0	
	local statRight2Value = 0	
	local statRight3Value = 0	
	local statRight4Value = 0	
	local statRight5Value = 0	
	local statRight6Value = 0		
	
	if _damageType == AUI_COMBAT_DATA_TYPE_DAMAGE_OUT or _damageType == AUI_COMBAT_DATA_TYPE_DAMAGE_IN then
		statLeft1Name = AUI.L10n.GetString("dps")	
		header1Name = AUI.L10n.GetString("damage")
		statLeft2Name = AUI.L10n.GetString("total")
		statLeft3Name = AUI.L10n.GetString("normal")
		statLeft4Name = AUI.L10n.GetString("critical")
		statLeft5Name = AUI.L10n.GetString("blocked")
		statLeft6Name = AUI.L10n.GetString("shielded")		
		
		statLeft5Value = unitTypeData.blocked
		statLeft6Value = unitTypeData.shielded	

		averageTypeName = "dps"
	elseif _damageType == AUI_COMBAT_DATA_TYPE_HEAL_OUT or _damageType == AUI_COMBAT_DATA_TYPE_HEAL_IN then
		header1Name = AUI.L10n.GetString("healing")
		statLeft1Name = AUI.L10n.GetString("hps")
		statLeft2Name = AUI.L10n.GetString("total")
		statLeft3Name = AUI.L10n.GetString("normal")
		statLeft4Name = AUI.L10n.GetString("critical")
		statLeft5Name = AUI.L10n.GetString("overheal")
		statLeft6Name = AUI.L10n.GetString("absolute")		
		
		statLeft5Value = unitTypeData.overflow
		statLeft6Value = unitTypeData.total + unitTypeData.overflow
		
		averageTypeName = "hps"
	end				

	local calculatedUnitData = AUI.Combat.GetCalculatedUnitData(_sourceId, gVisbleData.visibleCombatData.data, _damageType, gVisbleData.targetUnitId)	
	local groupResultData = AUI.Combat.GetCalculatedGroupUnitData(_sourceId, gVisbleData.visibleCombatData.data, _damageType, gVisbleData.targetUnitId)	
	
	statLeft1Value = calculatedUnitData.average
	statLeft2Value = calculatedUnitData.total
	statLeft3Value = calculatedUnitData.damage
	statLeft4Value = calculatedUnitData.crit		
		
	if groupResultData then
		statMiddle1Value = groupResultData.average
		statMiddle2Value = groupResultData.total
		statMiddle3Value = groupResultData.damage
		statMiddle4Value = groupResultData.crit
		statMiddle5Value = groupResultData.shielded
		statMiddle6Value = groupResultData.blocked
	end		
	
	if statLeft1Value <= 0 or statMiddle1Value <= 0 then
		if statLeft1Value <= 0 and statMiddle1Value ~= 0 then
			statRight1Value = "0%"
		elseif statLeft1Value ~= 0 and statMiddle1Value <= 0 then
			statRight1Value = "100%"
		else
			statRight1Value = "-"
		end
	else
		statRight1Value = AUI.String.GetPercentString(statMiddle1Value + statLeft1Value, statLeft1Value)	
	end			
	
	if not statLeft1Value or statLeft1Value <= 0 then
		statLeft1Value = "-"
	else
		statLeft1Value = AUI.String.ToFormatedNumber(statLeft1Value)
	end	
	
	if not statMiddle1Value or statMiddle1Value <= 0 then
		statMiddle1Value = "-"
	else
		statMiddle1Value = AUI.String.ToFormatedNumber(statMiddle1Value)
	end					
	
	if statLeft2Value <= 0 or statMiddle2Value <= 0 then
		if statLeft2Value <= 0 and statMiddle2Value ~= 0 then
			statRight2Value = "0%"
		elseif statLeft2Value ~= 0 and statMiddle2Value <= 0 then
			statRight2Value = "100%"
		else
			statRight2Value = "-"
		end
	else
		statRight2Value = AUI.String.GetPercentString(statMiddle2Value + statLeft2Value, statLeft2Value)		
	end		
	
	if not statLeft2Value or statLeft2Value <= 0 then
		statLeft2Value = "-"
	else
		statLeft2Value = AUI.String.ToFormatedNumber(statLeft2Value)
	end		

	if not statMiddle2Value or statMiddle2Value <= 0 then
		statMiddle2Value = "-"
	else
		statMiddle2Value = AUI.String.ToFormatedNumber(statMiddle2Value)
	end	


	if statLeft3Value <= 0 or statMiddle3Value <= 0 then
		if statLeft3Value <= 0 and statMiddle3Value ~= 0 then
			statRight2Value = "0%"
		elseif statLeft3Value ~= 0 and statMiddle3Value <= 0 then
			statRight3Value = "100%"
		else
			statRight3Value = "-"
		end
	else
		statRight3Value = AUI.String.GetPercentString(statMiddle3Value + statLeft3Value, statLeft3Value)
	end	

	if not statLeft3Value or statLeft3Value <= 0 then
		statLeft3Value = "-"
	else
		statLeft3Value = AUI.String.ToFormatedNumber(statLeft3Value)
	end		

	if not statMiddle3Value or statMiddle3Value <= 0 then
		statMiddle3Value = "-"
	else
		statMiddle3Value = AUI.String.ToFormatedNumber(statMiddle3Value)
	end	

	if statLeft4Value <= 0 or statMiddle4Value <= 0 then
		if statLeft4Value <= 0 and statMiddle4Value ~= 0 then
			statRight4Value = "0%"
		elseif statLeft4Value ~= 0 and statMiddle4Value <= 0 then
			statRight4Value = "100%"
		else
			statRight4Value = "-"
		end
	else
		statRight4Value = AUI.String.GetPercentString(statMiddle4Value + statLeft4Value, statLeft4Value)
	end	

	if not statLeft4Value or statLeft4Value <= 0 then
		statLeft4Value = "-"
	else
		statLeft4Value = AUI.String.ToFormatedNumber(statLeft4Value)
	end		
	
	if not statMiddle4Value or statMiddle4Value <= 0 then
		statMiddle4Value = "-"
	else
		statMiddle4Value = AUI.String.ToFormatedNumber(statMiddle4Value)
	end			
	
	if statLeft5Value <= 0 or statMiddle5Value <= 0 then
		if statLeft5Value <= 0 and statMiddle5Value ~= 0 then
			statRight5Value = "0%"
		elseif statLeft5Value ~= 0 and statMiddle5Value <= 0 then
			statRight5Value = "100%"
		else
			statRight5Value = "-"
		end
	else
		statRight5Value = AUI.String.GetPercentString(statMiddle5Value + statLeft5Value, statLeft5Value)
	end		
	
	if not statLeft5Value or statLeft5Value <= 0 then
		statLeft5Value = "-"
	else
		statLeft5Value = AUI.String.ToFormatedNumber(statLeft5Value)
	end		
	
	if not statMiddle5Value or statMiddle5Value <= 0 then
		statMiddle5Value = "-"
	else
		statMiddle5Value = AUI.String.ToFormatedNumber(statMiddle5Value)
	end					
	
	if statLeft6Value <= 0 or statMiddle6Value <= 0 then
		if statLeft6Value <= 0 and statMiddle6Value ~= 0 then
			statRight6Value = "0%"
		elseif statLeft6Value ~= 0 and statMiddle6Value <= 0 then
			statRight6Value = "100%"
		else
			statRight6Value = "-"
		end
	else
		statRight6Value = AUI.String.GetPercentString(statMiddle6Value + statLeft6Value, statLeft6Value)
	end		
	
	if not statLeft6Value or statLeft6Value <= 0 then
		statLeft6Value = "-"
	else
		statLeft6Value = AUI.String.ToFormatedNumber(statLeft6Value)
	end	

	if not statMiddle6Value or statMiddle6Value <= 0 then
		statMiddle6Value = "-"
	else
		statMiddle6Value = AUI.String.ToFormatedNumber(statMiddle6Value)
	end		

	AUI_MeterStatistic_Inner_PanelRight_LabelDamageType:SetText(header1Name)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft1Name:SetText(statLeft1Name)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft1Value:SetText(statLeft1Value)		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle1Value:SetText(statMiddle1Value)	
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight1Value:SetText(statRight1Value)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft2Name:SetText(statLeft2Name)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft2Value:SetText(statLeft2Value)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle2Value:SetText(statMiddle2Value)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight2Value:SetText(statRight2Value)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft3Name:SetText(statLeft3Name)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft3Value:SetText(statLeft3Value)	
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle3Value:SetText(statMiddle3Value)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight3Value:SetText(statRight3Value)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft4Name:SetText(statLeft4Name)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft4Value:SetText(statLeft4Value)		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle4Value:SetText(statMiddle4Value)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight4Value:SetText(statRight4Value)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft5Name:SetText(statLeft5Name)	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft5Value:SetText(statLeft5Value)	
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle5Value:SetText(statMiddle5Value)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight5Value:SetText(statRight5Value)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft6Name:SetText(statLeft6Name)	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft6Value:SetText(statLeft6Value)	
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle6Value:SetText(statMiddle6Value)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight6Value:SetText(statRight6Value)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelMeasuringTimeName:SetText(statLeft8Name)
	AUI_MeterStatistic_Inner_PanelRight_LabelMeasuringTimeValue:SetText(AUI.Time.GetFormatedString(AUI.Time.MS_To_S(calculatedUnitData.endTimeMS), AUI_TIME_FORMAT_EXACT))		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelCombatTimeName:SetText(statLeft7Name)
	AUI_MeterStatistic_Inner_PanelRight_LabelCombatTimeValue:SetText(AUI.Time.GetFormatedString(gVisbleData.visibleCombatData.combatTime, AUI_TIME_FORMAT_EXACT))	
	
	local totalAbilityList = AUI.Combat.GetTotalAbilityList(_sourceId, gVisbleData.visibleCombatData.data, _damageType, gVisbleData.targetUnitId)		
		
	local abilityItemList = {}	
	if totalAbilityList then
		for abilityName, abilityData in pairs(totalAbilityList) do
			local avarageValue = AUI.Combat.CalculateDPS(abilityData.total, calculatedUnitData.endTimeMS)

			table.insert(abilityItemList, 
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
					["Value"] = zo_strformat(SI_ABILITY_NAME, abilityName),
					["SortValue"] = abilityName,
					["SortType"] = "string",
					["Color"] = AUI.Color.ConvertHexToRGBA("#ffffff", 1),
					["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_ROW_HEIGHT / 1.5  .. "|" .. "outline")
				},							
				[3] = 
				{
					["ControlType"] = "label",
					["Value"] = AUI.String.ToFormatedNumber(abilityData.total) .. " (" .. AUI.String.GetPercentString(unitTypeData.total, abilityData.total) .. ")",
					["SortValue"] = abilityData.total,
					["SortType"] = "number",
					["Color"] = AUI.Color.ConvertHexToRGBA("#ffffff", 1),
					["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_ROW_HEIGHT / 1.5  .. "|" .. "outline")
				},						
				[4] = 
				{
					["ControlType"] = "label",
					["Value"] =	AUI.String.ToFormatedNumber(abilityData.crit) .. " (" .. AUI.String.GetPercentString(abilityData.total, abilityData.crit) .. ")",
					["SortValue"] = abilityData.crit,
					["SortType"] = "number",
					["Color"] = AUI.Color.ConvertHexToRGBA("#ffffff", 1),
					["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_ROW_HEIGHT / 1.5  .. "|" .. "outline")
				},						
				[5] = 
				{
					["ControlType"] = "label",
					["Value"] = AUI.String.ToFormatedNumber(avarageValue),
					["SortValue"] = avarageValue,
					["SortType"] = "number",		
					["Color"] = AUI.Color.ConvertHexToRGBA("#ffffff", 1),
					["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_ROW_HEIGHT / 1.5  .. "|" .. "outline")
				},					
				[6] = 
				{
					["ControlType"] = "label",
					["Value"] = abilityData.hitCount,
					["SortValue"] = abilityData.hitCount,
					["SortType"] = "number",			
					["Color"] = AUI.Color.ConvertHexToRGBA("#ffffff", 1),
					["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_ROW_HEIGHT / 1.5 .. "|" .. "outline")
				},				
			})			
		end			
	end
	
	AUI_MeterStatistic_Inner_ListBox_Abilities:SetItemList(abilityItemList)			
	AUI_MeterStatistic_Inner_ListBox_Abilities:SetColumnText(5, averageTypeName)	
	AUI_MeterStatistic_Inner_ListBox_Abilities:Refresh()	
	
	UpdateBuffList(unitData, BUFF_EFFECT_TYPE_BUFF)
end

local function LoadRecord(_rowControl)
	local firstCellData = _rowControl.cellList[1].cellData
	if firstCellData then
		local _combatData = AUI_FightData.records[firstCellData.Value]
																																								
		if _combatData then
			_combatData.isSaved = true 
			AUI.Combat.Statistics.UpdateUI(_combatData)	
			gOpenRecordDialog:Close()
		end		
	end
end

local function SaveRecord(_currrentCombatData)
	if _currrentCombatData and _currrentCombatData.dateString then
		if GetNumRecords() <= METER_STATISTIC_SAVED_LIMIT_COUNT then
			AUI_FightData.records[_currrentCombatData.dateString] = _currrentCombatData
			AUI_FightData.records[_currrentCombatData.dateString].esoVersion = GetESOVersionString()
			AUI_FightData.records[_currrentCombatData.dateString].account = GetDisplayName()
			_currrentCombatData.isSaved = true
			AUI.Combat.Statistics.UpdateUI(_currrentCombatData)
		else
			d(AUI.L10n.GetString("record_limit_reached"))
		end
	end
end

local function DeleteRecord(_rowControl)
	local firstCellData = _rowControl.cellList[1].cellData
	
	if firstCellData then
		if AUI_FightData.records[firstCellData.Value] then
			AUI_FightData.records[firstCellData.Value] = nil	
			
			if gSetRecordsFunc then
				gSetRecordsFunc()
			end
			
			local _combatData = AUI_FightData.records[firstCellData.Value]
			if _combatData then
				_combatData.isSaved = false
			end
		end
	end	
end

local function SetRecords()
	local itemList = {}
	for dateString, recordData in pairs(AUI_FightData.records) do
		local unitSourceName = ""	
		local unitTargetName = ""	
		local totalValue = 0
		local endTimeMS = 0
		local dataTypeName = ""
	
		local highestSourceUnitData, sourceType = AUI.Combat.GetHighestPlayerData(recordData.data)
		if not highestSourceUnitData then
			highestSourceUnitData, sourceType = AUI.Combat.GetHighestSourceData(recordData.data)
		end		
		
		if highestSourceUnitData and highestSourceUnitData[sourceType] then
			local highestTargetUnitData, _ = AUI.Combat.GetHighestTargetData(highestSourceUnitData)

			totalValue = highestSourceUnitData[sourceType].total
			endTimeMS = highestSourceUnitData[sourceType].endTimeMS						
			unitTargetName = zo_strformat(SI_UNIT_NAME, highestTargetUnitData.unitName)								
			
			if sourceType == AUI_COMBAT_DATA_TYPE_DAMAGE_OUT then
				dataTypeName = AUI.L10n.GetString("damage")
			elseif sourceType == AUI_COMBAT_DATA_TYPE_HEAL_OUT then
				dataTypeName = AUI.L10n.GetString("healing")
			end	

			local average = AUI.Combat.CalculateDPS(totalValue, endTimeMS)
			
			if average <= 0 then
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
					["ControlType"] = "texture",
					["TextureFile"] = GetClassIcon(recordData.charClassId),
					["TextureWidth"] = "Height",		
				}, 					
				[3] = 
				{
					["SortType"] = "string",
					["ControlType"] = "label",
					["Value"] = recordData.charName,			
				}, 				
				[4] = 
				{
					["SortType"] = "string",
					["ControlType"] = "label",
					["Value"] = unitTargetName,			
				}, 
				[5] = 
				{
					["SortType"] = "string",
					["ControlType"] = "label",
					["Value"] = dataTypeName,			
				}, 	
				[6] = 
				{
					["SortType"] = "number",
					["ControlType"] = "label",
					["Value"] = AUI.String.ToFormatedNumber(average),
					["SortValue"] = average,				
				},			
				[7] = 
				{
					["SortType"] = "number",
					["ControlType"] = "label",
					["Value"] = recordData.formatedDate,
					["SortValue"] = dateString,				
				},
				[8] = 
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
	end

	gOpenRecordDialog:SetItemList(itemList)	
	gOpenRecordDialog:Refresh()
end

local function OpenRecordWindow()						
	SetRecords()																											
	
	gOpenRecordDialog:SetRowMouseDoubleClickCallback(function(_eventCode, _button, _ctrl, _alt, _shift, _rowControl) LoadRecord(_rowControl) end)	
	gOpenRecordDialog:SetRowMouseUpCallback(
	function(_eventCode, _button, _ctrl, _alt, _shift, _rowControl, _cellControl) 
		if _button == 2 then
			if not _cellControl.isMouseOverButton then
				AUI.ShowMouseMenu(nil, nil, 100)	
				AUI.AddMouseMenuButton("AUI_COMBAT_DELETE_RECORD", AUI.L10n.GetString("delete"), function() DeleteRecord(_rowControl) end)
			end
		end 
	end)	
	
	gOpenRecordDialog:SetLoadButtonCallback(function(_rowControl) LoadRecord(_rowControl) end)	
	gOpenRecordDialog:Show()
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
	
	local mainWidth = METER_STATISTIC_WIDTH
	local mainHeight = METER_STATISTIC_HEIGHT
	local innerPadding = 20
	local columnPadding = 20
	local columnCount = 3
	local innerWidth = mainWidth - innerPadding - columnPadding
	local innerHeight = mainHeight - innerPadding - 174
	local infoContainerWidth = (innerWidth / columnCount) - (innerPadding / columnCount) - (columnPadding / (columnCount / 2))
	local infoContainerHeight = 105
	
	AUI_MeterStatistic:ClearAnchors()
	AUI_MeterStatistic:SetAnchor(AUI.Settings.Combat.detail_statistic_window_position.point, GUIROOT, AUI.Settings.Combat.detail_statistic_window_position.relativePoint, AUI.Settings.Combat.detail_statistic_window_position.offsetX, AUI.Settings.Combat.detail_statistic_window_position.offsetY)	
	AUI_MeterStatistic:SetDimensions(mainWidth, mainHeight)	

	AUI_MeterStatistic_HeaderLine:ClearAnchors()
	AUI_MeterStatistic_HeaderLine:SetAnchor(TOP, AUI_MeterStatistic_LabelHeader, BOTTOM, 0, 8)
	AUI_MeterStatistic_HeaderLine:SetDimensions(METER_STATISTIC_WIDTH -(innerPadding * columnCount), 2)
	
	AUI_MeterStatistic_Inner:ClearAnchors()
	AUI_MeterStatistic_Inner:SetAnchor(TOPLEFT, AUI_MeterStatistic_HeaderLine, BOTTOMLEFT, 0, 20)		
	AUI_MeterStatistic_Inner:SetDimensions(innerWidth, innerHeight)		

	AUI_MeterStatistic_Inner_PanelRight_LabelDamageType:SetFont("$(MEDIUM_FONT)|" ..  18 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelDamageType:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_HEADER_BIG, 1):UnpackRGBA())	

	AUI_MeterStatistic_Inner_PanelRight_DamageHeaderLine:SetDimensions(AUI_MeterStatistic_Inner_PanelRight:GetWidth(), 2)	
	
	AUI_MeterStatistic_Inner_PanelRight_StatHeaderLine:SetDimensions(AUI_MeterStatistic_Inner_PanelRight:GetWidth(), 1)	
		
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderUnitName:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderUnitName:SetWidth(150)
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderUnitName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 	
	
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderGroup:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderGroup:SetWidth(150)
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderGroup:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 	
	
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderGroupPercent:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderGroupPercent:SetWidth(150)
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderGroupPercent:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft1Name:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft1Name:SetWidth(150)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft1Name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft1Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft1Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft1Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 	
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle1Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle1Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle1Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight1Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight1Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight1Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft2Name:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft2Name:SetWidth(150)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft2Name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft2Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft2Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft2Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle2Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle2Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle2Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 	
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight2Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight2Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight2Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft3Name:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft3Name:SetWidth(150)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft3Name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle3Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle3Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle3Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight3Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight3Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight3Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft3Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft3Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft3Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 	
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft4Name:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft4Name:SetWidth(150)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft4Name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle4Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle4Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle4Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight4Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight4Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight4Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft4Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft4Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft4Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 				
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft5Name:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft5Name:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft5Name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft5Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft5Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft5Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 	
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight5Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight5Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight5Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle5Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle5Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle5Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft6Name:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft6Name:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft6Name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft6Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft6Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatLeft6Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 	
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight6Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight6Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatRight6Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle6Value:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle6Value:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelStatMiddle6Value:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_Line2:SetDimensions(AUI_MeterStatistic_Inner_PanelRight:GetWidth(), 2)	
	
	AUI_MeterStatistic_Inner_PanelRight_LabelTime:SetFont("$(MEDIUM_FONT)|" ..  18 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelTime:SetText(AUI.L10n.GetString("time"))
	AUI_MeterStatistic_Inner_PanelRight_LabelTime:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_HEADER_BIG, 1):UnpackRGBA())		
		
	AUI_MeterStatistic_Inner_PanelRight_LabelMeasuringTimeName:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelMeasuringTimeName:SetWidth(150)
	AUI_MeterStatistic_Inner_PanelRight_LabelMeasuringTimeName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 
	
	AUI_MeterStatistic_Inner_PanelRight_LabelMeasuringTimeValue:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelMeasuringTimeValue:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelMeasuringTimeValue:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 		
	
	AUI_MeterStatistic_Inner_PanelRight_LabelCombatTimeName:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelCombatTimeName:SetWidth(150)
	AUI_MeterStatistic_Inner_PanelRight_LabelCombatTimeName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 
	
	AUI_MeterStatistic_Inner_PanelRight_LabelCombatTimeValue:SetFont("$(MEDIUM_FONT)|" ..  16 .. "|" .. "outline")
	AUI_MeterStatistic_Inner_PanelRight_LabelCombatTimeValue:SetWidth(100)
	AUI_MeterStatistic_Inner_PanelRight_LabelCombatTimeValue:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) 			

	AUI_MeterStatistic_Inner_InfoContainer:ClearAnchors()	
	AUI_MeterStatistic_Inner_InfoContainer:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_PanelRight_LabelCombatTimeValue, BOTTOMLEFT, 0, 20)	
	AUI_MeterStatistic_Inner_InfoContainer:SetDimensions(innerWidth, 105)	
	
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderUnitName:SetText(AUI.L10n.GetString("player"))
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderUnitName:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_NO_RECORDS, 1):UnpackRGBA())
	
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderGroup:SetText(AUI.L10n.GetString("group"))
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderGroup:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_NO_RECORDS, 1):UnpackRGBA())
	
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderGroupPercent:SetText("%")	
	AUI_MeterStatistic_Inner_PanelRight_LabelHeaderGroupPercent:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_NO_RECORDS, 1):UnpackRGBA())	
	
	AUI_MeterStatistic_LabelHeader:SetFont("$(MEDIUM_FONT)|" ..  METER_STATISTIC_WIDTH / 40 .. "|" .. "thick-outline")
	AUI_MeterStatistic_LabelHeader:SetText("AUI - " .. AUI.L10n.GetString("meter_statistic"))
	AUI_MeterStatistic_LabelHeader:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_HEADER_BIG, 1):UnpackRGBA())	
	
	AUI_MeterStatistic_LabelDate:SetFont("$(MEDIUM_FONT)|" ..  METER_STATISTIC_WIDTH / 38 .. "|" .. "thick-outline")
	AUI_MeterStatistic_LabelDate:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_HEADER_NORMAL, 1):UnpackRGBA())		
	
	AUI_MeterStatistic_LabelNoData:SetFont("$(MEDIUM_FONT)|" ..  METER_STATISTIC_WIDTH / 32 .. "|" .. "outline")
	AUI_MeterStatistic_LabelNoData:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_VERSION, 1):UnpackRGBA())

	AUI_MeterStatistic_LabelAUIVersion:SetFont("$(MEDIUM_FONT)|" ..  METER_STATISTIC_WIDTH / 50 .. "|" .. "outline")
	AUI_MeterStatistic_LabelAUIVersion:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_NO_RECORDS, 1):UnpackRGBA())
	AUI_MeterStatistic_LabelAUIVersion:SetText("Version: " .. AUI_COMBAT_VERSION)	

	AUI_MeterStatistic_LabelESOVersion:SetFont("$(MEDIUM_FONT)|" ..  METER_STATISTIC_WIDTH / 50 .. "|" .. "outline")
	AUI_MeterStatistic_LabelESOVersion:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_NO_RECORDS, 1):UnpackRGBA())

	AUI_MeterStatistic_LabelSaveLimit:SetFont("$(MEDIUM_FONT)|" ..  METER_STATISTIC_WIDTH / 50 .. "|" .. "outline")

	AUI.CreateListBox("AUI_MeterStatistic_Inner_ListBox_SourceUnits", AUI_MeterStatistic_Inner_PanelRight, true, false)
	AUI_MeterStatistic_Inner_ListBox_SourceUnits:ClearAnchors()
	AUI_MeterStatistic_Inner_ListBox_SourceUnits:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_VerticalButtonContainer, TOPRIGHT, 20, 0)
	AUI_MeterStatistic_Inner_ListBox_SourceUnits:SetDimensions(AUI_MeterStatistic_Inner_PanelRight:GetWidth(), 210)	
	AUI_MeterStatistic_Inner_ListBox_SourceUnits:SetRowHeight(METER_STATISTIC_ROW_HEIGHT)		
	AUI_MeterStatistic_Inner_ListBox_SourceUnits:SetSortKey(2)		
	AUI_MeterStatistic_Inner_ListBox_SourceUnits:EnableMouseHover()
	AUI_MeterStatistic_Inner_ListBox_SourceUnits:EnableMouseSelection()	
	AUI_MeterStatistic_Inner_ListBox_SourceUnits:SetSelectedRowCallback(
	function(_eventCode, _button, _ctrl, _alt, _shift, _rowControl) 
		local firstCellData = _rowControl.cellList[1].cellData
		if firstCellData then
			gVisbleData.sourceUnitId = firstCellData.CustomData.sourceUnitId
			UpdateUI(firstCellData.CustomData.sourceUnitId, gVisbleData.selectedDamageType)
		end		
	end)					

	AUI.CreateListBox("AUI_MeterStatistic_Inner_ListBox_TargetUnits", AUI_MeterStatistic_Inner_PanelRight, true, false)
	AUI_MeterStatistic_Inner_ListBox_TargetUnits:ClearAnchors()
	AUI_MeterStatistic_Inner_ListBox_TargetUnits:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_ListBox_SourceUnits, TOPRIGHT, 40, 0)
	AUI_MeterStatistic_Inner_ListBox_TargetUnits:SetDimensions(AUI_MeterStatistic_Inner_PanelRight:GetWidth(), 210)	
	AUI_MeterStatistic_Inner_ListBox_TargetUnits:SetRowHeight(METER_STATISTIC_ROW_HEIGHT)				
	AUI_MeterStatistic_Inner_ListBox_TargetUnits:SetSortKey(2)			
	AUI_MeterStatistic_Inner_ListBox_TargetUnits:EnableMouseHover()
	AUI_MeterStatistic_Inner_ListBox_TargetUnits:EnableMouseSelection()		
	AUI_MeterStatistic_Inner_ListBox_TargetUnits:AllowManualDeselect(true)
	
	AUI_MeterStatistic_Inner_ListBox_TargetUnits:SetSelectedRowCallback(
	function(_eventCode, _button, _ctrl, _alt, _shift, _rowControl) 
		local firstCellData = _rowControl.cellList[1].cellData
		if firstCellData then
			UpdateUI(gVisbleData.sourceUnitId, gVisbleData.selectedDamageType, firstCellData.CustomData.targetUnitId)
		end		
	end)		
	
	AUI_MeterStatistic_Inner_ListBox_TargetUnits:SetDeselectedRowCallback(
	function(_eventCode, _button, _ctrl, _alt, _shift, _rowControl) 
		UpdateUI(gVisbleData.sourceUnitId, gVisbleData.selectedDamageType)		
	end)	
	
	AUI_MeterStatistic_Inner_PanelRight:ClearAnchors()
	AUI_MeterStatistic_Inner_PanelRight:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_ListBox_TargetUnits, TOPRIGHT, 40, 0)
		
	AUI.CreateListBox("AUI_MeterStatistic_Inner_ListBox_Abilities", AUI_MeterStatistic_Inner_PanelRight, false, false)
	AUI_MeterStatistic_Inner_ListBox_Abilities:ClearAnchors()
	AUI_MeterStatistic_Inner_ListBox_Abilities:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_ListBox_SourceUnits, BOTTOMLEFT, 0, 10)
	AUI_MeterStatistic_Inner_ListBox_Abilities:SetDimensions(AUI_MeterStatistic_Inner_PanelLeft:GetWidth(), 210)	
	AUI_MeterStatistic_Inner_ListBox_Abilities:SetRowHeight(METER_STATISTIC_ROW_HEIGHT)	
	AUI_MeterStatistic_Inner_ListBox_Abilities:SetSortKey(3)	
	
	AUI_MeterStatistic_Inner_PanelLeft_BuffListHeaderLine:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_ListBox_Abilities, BOTTOMLEFT, 0, 0)
	AUI_MeterStatistic_Inner_PanelLeft_BuffListHeaderLine:SetDimensions(AUI_MeterStatistic_Inner_PanelLeft:GetWidth(), 2)		

	AUI_MeterStatistic_Inner_PanelLeft_ButtonShowBuffs:SetState(BSTATE_PRESSED, false)
	AUI_MeterStatistic_Inner_PanelLeft_ButtonShowBuffs:SetHandler("OnClicked", 
	function()
		if gVisbleData.numDebuffs > 0 then
			AUI_MeterStatistic_Inner_PanelLeft_ButtonShowDebuffs:SetState(BSTATE_NORMAL, false)		
		end
		
		AUI_MeterStatistic_Inner_PanelLeft_ButtonShowBuffs:SetState(BSTATE_PRESSED, false)
		UpdateBuffList(gVisbleData.visibleCombatData.data[gVisbleData.sourceUnitId], BUFF_EFFECT_TYPE_BUFF)		
	end)			
	
	AUI_MeterStatistic_Inner_PanelLeft_ButtonShowBuffs:SetText("Buffs")

	AUI_MeterStatistic_Inner_PanelLeft_ButtonShowDebuffs:SetHandler("OnClicked", 
	function()
		if gVisbleData.numBuffs > 0 then
			AUI_MeterStatistic_Inner_PanelLeft_ButtonShowBuffs:SetState(BSTATE_NORMAL, false)	
		end	
		
		AUI_MeterStatistic_Inner_PanelLeft_ButtonShowDebuffs:SetState(BSTATE_PRESSED, false)
		UpdateBuffList(gVisbleData.visibleCombatData.data[gVisbleData.sourceUnitId], BUFF_EFFECT_TYPE_DEBUFF)			
	end)	
	
	AUI_MeterStatistic_Inner_PanelLeft_ButtonShowDebuffs:SetText("Debuffs")

	AUI.CreateListBox("AUI_MeterStatistic_Inner_ListBox_Buffs", AUI_MeterStatistic_Inner_PanelLeft, false, false)
	AUI_MeterStatistic_Inner_ListBox_Buffs:ClearAnchors()
	AUI_MeterStatistic_Inner_ListBox_Buffs:SetAnchor(TOPLEFT, AUI_MeterStatistic_Inner_ListBox_Abilities, BOTTOMLEFT, 0, 40)
	AUI_MeterStatistic_Inner_ListBox_Buffs:SetDimensions(AUI_MeterStatistic_Inner_PanelLeft:GetWidth(), 210)	
	AUI_MeterStatistic_Inner_ListBox_Buffs:SetRowHeight(METER_STATISTIC_ROW_HEIGHT)		
	AUI_MeterStatistic_Inner_ListBox_Buffs:SetSortKey(3)	
		
	AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageOutButton:SetHandler("OnClicked", function() 
		AUI.Combat.Statistics.UpdateUI(gVisbleData.visibleCombatData, AUI_COMBAT_DATA_TYPE_DAMAGE_OUT) 
	end)			
		
	AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageOutButton:SetHandler("OnMouseEnter", 
	function()
		local buttonState = AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageOutButton:GetState()
		if buttonState == BSTATE_NORMAL then
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageOutButton_Icon:SetColor(1, 1, 1, 1)
		end
	end)	
	
	AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageOutButton:SetHandler("OnMouseExit", 
	function()
		local buttonState = AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageOutButton:GetState()
		if buttonState == BSTATE_NORMAL then
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageOutButton_Icon:SetColor(1, 1, 1, 0.5)
		end
	end)		
		
	AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealOutButton:SetHandler("OnClicked", function() 
		AUI.Combat.Statistics.UpdateUI(gVisbleData.visibleCombatData, AUI_COMBAT_DATA_TYPE_HEAL_OUT) 
	end)
	
	AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealOutButton:SetHandler("OnMouseEnter", 
	function()
		local buttonState = AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealOutButton:GetState()
		if buttonState == BSTATE_NORMAL then
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealOutButton_Icon:SetColor(1, 1, 1, 1)
		end
	end)	
	
	AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealOutButton:SetHandler("OnMouseExit", 
	function()
		local buttonState = AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealOutButton:GetState()
		if buttonState == BSTATE_NORMAL then
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealOutButton_Icon:SetColor(1, 1, 1, 0.5)
		end
	end)	
	
	AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageInButton:SetHandler("OnClicked", function() 
		AUI.Combat.Statistics.UpdateUI(gVisbleData.visibleCombatData, AUI_COMBAT_DATA_TYPE_DAMAGE_IN) 		
	end)		
	
	AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageInButton:SetHandler("OnMouseEnter", 
	function()
		local buttonState = AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageInButton:GetState()
		if buttonState == BSTATE_NORMAL then
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageInButton_Icon:SetColor(1, 1, 1, 1)
		end
	end)	
	
	AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageInButton:SetHandler("OnMouseExit", 
	function()
		local buttonState = AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageInButton:GetState()
		if buttonState == BSTATE_NORMAL then
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageInButton_Icon:SetColor(1, 1, 1, 0.5)
		end
	end)	
	
	AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealInButton:SetHandler("OnClicked", function() 
		AUI.Combat.Statistics.UpdateUI(gVisbleData.visibleCombatData, AUI_COMBAT_DATA_TYPE_HEAL_IN) 
	end)

	AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealInButton:SetHandler("OnMouseEnter", 
	function()
		local buttonState = AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealInButton:GetState()
		if buttonState == BSTATE_NORMAL then
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealInButton_Icon:SetColor(1, 1, 1, 1)
		end
	end)	
	
	AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealInButton:SetHandler("OnMouseExit", 
	function()
		local buttonState = AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealInButton:GetState()
		if buttonState == BSTATE_NORMAL then
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealInButton_Icon:SetColor(1, 1, 1, 0.5)
		end
	end)	
				
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
	
	AUI_MeterStatistic_SaveRecord:SetNormalTexture("AUI/images/other/save_deactivated.dds")
	AUI_MeterStatistic_SaveRecord:SetPressedTexture("AUI/images/other/save_pressed.dds")
	AUI_MeterStatistic_SaveRecord:SetMouseOverTexture("AUI/images/other/save_hover.dds")
	AUI_MeterStatistic_SaveRecord:SetEnabled(false)
	AUI_MeterStatistic_SaveRecord:SetHandler("OnMouseEnter", function() AUI.ShowTooltip(AUI.L10n.GetString("save_record")) end)
	AUI_MeterStatistic_SaveRecord:SetHandler("OnMouseExit", AUI.HideTooltip)	
	AUI_MeterStatistic_SaveRecord:SetHandler("OnClicked", 
	function()
		SaveRecord(gVisbleData.visibleCombatData)
	end)		
	
	AUI_MeterStatistic_DeleteRecord:SetNormalTexture("AUI/images/other/recycle_deactivated.dds")
	AUI_MeterStatistic_DeleteRecord:SetPressedTexture("AUI/images/other/recycle_pressed.dds")
	AUI_MeterStatistic_DeleteRecord:SetMouseOverTexture("AUI/images/other/recycle_hover.dds")
	AUI_MeterStatistic_DeleteRecord:SetEnabled(false)
	AUI_MeterStatistic_DeleteRecord:SetHandler("OnMouseEnter", function() AUI.ShowTooltip(AUI.L10n.GetString("remove_record")) end)
	AUI_MeterStatistic_DeleteRecord:SetHandler("OnMouseExit", AUI.HideTooltip)	
	AUI_MeterStatistic_DeleteRecord:SetHandler("OnClicked", 
	function()
		RemoveRecord(gVisbleData.visibleCombatData)
	end)			
	
	AUI_MeterStatistic_ButtonPostCombatStatic:SetHandler("OnClicked", function() AUI.Combat.PostCombatStatistics(gVisbleData.sourceUnitId, gVisbleData.selectedDamageType, gVisbleData.targetUnitId) end)
	AUI_MeterStatistic_ButtonPostCombatStatic:SetText(AUI.L10n.GetString("post_in_chat"))

	AUI_MeterStatistic_Inner_ListBox_SourceUnits:SetColumnList(sourceUnitsList)	
	AUI_MeterStatistic_Inner_ListBox_TargetUnits:SetColumnList(targetUnitsList)	
	AUI_MeterStatistic_Inner_ListBox_Abilities:SetColumnList(columnAbilityList)	
	AUI_MeterStatistic_Inner_ListBox_Buffs:SetColumnList(columnBuffList)		
	
	gOpenRecordDialog = AUI.CreateOpenDataDialog("AUI_LOAD_COMBAT_RECORD", GuiRoot, AUI.L10n.GetString("records"))
	gOpenRecordDialog:SetSortKey(7)
	gOpenRecordDialog:SetColumnList(loadRecordList)
end

local function SortNameList(list1, list2)
	if list1[gVisbleData.selectedDamageType] and list2[gVisbleData.selectedDamageType] then
		if list1[gVisbleData.selectedDamageType].total > list2[gVisbleData.selectedDamageType].total then
			return true
		end
	end
end

local function GetHighestDamageType(_combatData)
	local doesDamageOutData = false
	local doesDamageInData = false 
	local doesHealOutData = false 
	local doesHealInData = false 

	local highestCombatData = AUI.Combat.GetHighestSourceData(_combatData)


	local damageType = AUI_COMBAT_DATA_TYPE_DAMAGE_OUT

	for unitId, unitData in pairs(AUI.Table.Copy(_combatData.data)) do
		if not doesDamageOutData and unitData[AUI_COMBAT_DATA_TYPE_DAMAGE_OUT] then
			damageType = AUI_COMBAT_DATA_TYPE_DAMAGE_OUT
		end
		
		if not doesHealOutData and unitData[AUI_COMBAT_DATA_TYPE_HEAL_OUT] then
			damageType = AUI_COMBAT_DATA_TYPE_HEAL_OUT
		end		
		
		if not doesDamageInData and unitData[AUI_COMBAT_DATA_TYPE_DAMAGE_IN] then
			damageType = AUI_COMBAT_DATA_TYPE_DAMAGE_IN
		end			
		
		if not doesHealInData and unitData[AUI_COMBAT_DATA_TYPE_HEAL_IN] then
			damageType = AUI_COMBAT_DATA_TYPE_HEAL_IN		
		end		
	
		if unitData[gVisbleData.selectedDamageType] then		
			unitData.sourceUnitId = unitId

			table.insert(sourceNameList, unitData)
		end
	end
	
	return damageType
end

function AUI.Combat.Statistics.UpdateUI(_combatData, _combatType)
	if not gIsLoaded then
		return
	end		

	if not _combatData then
		_combatData = AUI.Combat.GetLastData()
		
	end

	gVisbleData.sourceUnitId = nil
	gVisbleData.visibleCombatData = nil
	gVisbleData.selectedDamageType = nil
	
	local error, errorMessage  = AUI.Combat.CheckError()
	
	if _combatData and not error or _combatData and _combatData.isSaved then
		if _combatType then
			gVisbleData.selectedDamageType = _combatType
		else
			_, gVisbleData.selectedDamageType = AUI.Combat.GetHighestSourceData(_combatData.data[gVisbleData.sourceUnitId])
		end	
	
		gVisbleData.visibleCombatData = _combatData
	
		local sourceNameList = {}	
		
		local doesDamageOutData = false
		local doesDamageInData = false 
		local doesHealOutData = false 
		local doesHealInData = false 
		
		for unitId, unitData in pairs(AUI.Table.Copy(_combatData.data)) do
			if not doesDamageOutData and unitData[AUI_COMBAT_DATA_TYPE_DAMAGE_OUT] then
				doesDamageOutData = true
			end
			
			if not doesHealOutData and unitData[AUI_COMBAT_DATA_TYPE_HEAL_OUT] then
				doesHealOutData = true
			end		
			
			if not doesDamageInData and unitData[AUI_COMBAT_DATA_TYPE_DAMAGE_IN] then
				doesDamageInData = true
			end			
			
			if not doesHealInData and unitData[AUI_COMBAT_DATA_TYPE_HEAL_IN] then
				doesHealInData = true	
			end		
		
			if unitData[gVisbleData.selectedDamageType] then		
				unitData.sourceUnitId = unitId

				table.insert(sourceNameList, unitData)
			end
		end

		table.sort(sourceNameList, SortNameList)				
		
		local sourceItemList = {}			
		for i, unitData in pairs(sourceNameList) do
			if unitData then	
				local calculatedUnitData = AUI.Combat.GetCalculatedUnitData(unitData.sourceUnitId, gVisbleData.visibleCombatData.data, gVisbleData.selectedDamageType)
			
				table.insert(sourceItemList, 
				{
					[1] = 
					{
						["ControlType"] = "label",
						["Value"] = zo_strformat(SI_UNIT_NAME, unitData.unitName),
						["SortValue"] = unitData.unitName,
						["SortType"] = "string",
						["Color"] = AUI.Color.ConvertHexToRGBA("#ffffff", 1),
						["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_ROW_HEIGHT / 1.5  .. "|" .. "outline"),
						["CustomData"] = 
						{
							["sourceUnitId"] = unitData.sourceUnitId,
						}
					},
					[2] = 
					{
						["ControlType"] = "label",
						["Value"] = calculatedUnitData.average,
						["SortValue"] = calculatedUnitData.average,
						["SortType"] = "number",
						["Color"] = AUI.Color.ConvertHexToRGBA("#ffffff", 1),
						["Font"] = ("$(MEDIUM_FONT)|" .. METER_STATISTIC_ROW_HEIGHT / 1.5  .. "|" .. "outline"),
						["CustomData"] = 
						{
							["sourceUnitId"] = unitData.sourceUnitId,
						}
					}							
				})
			end
		end	
		
		AUI_MeterStatistic_Inner_ListBox_SourceUnits:SelectRowByIndex(0, false)
		AUI_MeterStatistic_Inner_ListBox_SourceUnits:SetItemList(sourceItemList)			
		AUI_MeterStatistic_Inner_ListBox_SourceUnits:Refresh()		

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
			AUI_MeterStatistic_SaveRecord:SetNormalTexture("AUI/images/other/save_deactivated.dds")
			AUI_MeterStatistic_ButtonPostCombatStatic:SetHidden(true)	
		else
			AUI_MeterStatistic_SaveRecord:SetEnabled(true)
			AUI_MeterStatistic_SaveRecord:SetNormalTexture("AUI/images/other/save.dds")
			AUI_MeterStatistic_ButtonPostCombatStatic:SetHidden(false)	
		end
		
		AUI_MeterStatistic_DeleteRecord:SetEnabled(true)
		AUI_MeterStatistic_DeleteRecord:SetNormalTexture("AUI/images/other/recycle.dds")

		AUI_MeterStatistic_LabelDate:SetText(_combatData.formatedDate)													
		AUI_MeterStatistic_LabelDate:SetHidden(false)

		if doesDamageOutData then
			if gVisbleData.selectedDamageType == AUI_COMBAT_DATA_TYPE_DAMAGE_OUT then
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageOutButton:SetState(BSTATE_PRESSED, true)		
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageOutButton_Icon:SetColor(1, 0.5, 0.5, 1)
			else
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageOutButton:SetState(BSTATE_NORMAL, true)
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageOutButton_Icon:SetColor(1, 1, 1, 0.5)
			end
		else
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageOutButton:SetState(BSTATE_DISABLED, true)
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageOutButton_Icon:SetColor(1, 1, 1, 0.2)		
		end
		
		if doesHealOutData then
			if gVisbleData.selectedDamageType == AUI_COMBAT_DATA_TYPE_HEAL_OUT then
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealOutButton:SetState(BSTATE_PRESSED, true)
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealOutButton_Icon:SetColor(1, 0.5, 0.5, 1)
			else
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealOutButton:SetState(BSTATE_NORMAL, true)
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealOutButton_Icon:SetColor(1, 1, 1, 0.5)
			end
		else
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealOutButton:SetState(BSTATE_DISABLED, true)
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealOutButton_Icon:SetColor(1, 1, 1, 0.2)		
		end	
		
		if doesDamageInData then
			if gVisbleData.selectedDamageType == AUI_COMBAT_DATA_TYPE_DAMAGE_IN then
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageInButton:SetState(BSTATE_PRESSED, true)
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageInButton_Icon:SetColor(1, 0.5, 0.5, 1)
			else
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageInButton:SetState(BSTATE_NORMAL, true)
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageInButton_Icon:SetColor(1, 1, 1, 0.5)
			end
		else
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageInButton:SetState(BSTATE_DISABLED, true)	
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectDamageInButton_Icon:SetColor(1, 1, 1, 0.2)
		end	

		if doesHealInData then
			if gVisbleData.selectedDamageType == AUI_COMBAT_DATA_TYPE_HEAL_IN then
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealInButton:SetState(BSTATE_PRESSED, true)
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealInButton_Icon:SetColor(1, 0.5, 0.5, 1)
			else
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealInButton:SetState(BSTATE_NORMAL, true)
				AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealInButton_Icon:SetColor(1, 1, 1, 0.5)
			end
		else
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealInButton:SetState(BSTATE_DISABLED, true)	
			AUI_MeterStatistic_Inner_VerticalButtonContainer_SelectHealInButton_Icon:SetColor(1, 1, 1, 0.2)
		end		
	else
		AUI_MeterStatistic_LabelNoData:SetText(errorMessage)									
		AUI_MeterStatistic_Inner:SetHidden(true)													
		AUI_MeterStatistic_LabelNoData:SetHidden(false)
		AUI_MeterStatistic_NextRecord:SetHidden(true)
		AUI_MeterStatistic_PreviousRecord:SetHidden(true)			
		AUI_MeterStatistic_LabelDate:SetHidden(true)														
		AUI_MeterStatistic_SaveRecord:SetEnabled(false)
		AUI_MeterStatistic_SaveRecord:SetNormalTexture("AUI/images/other/save_deactivated.dds")
		AUI_MeterStatistic_DeleteRecord:SetEnabled(false)												
		AUI_MeterStatistic_DeleteRecord:SetNormalTexture("AUI/images/other/recycle_deactivated.dds")
		AUI_MeterStatistic_ButtonPostCombatStatic:SetHidden(true)	
	end

	if AUI_FightData.records then
		AUI_MeterStatistic_LoadRecord:SetEnabled(true)		
	else
		AUI_MeterStatistic_LoadRecord:SetEnabled(false)	
	end	
	
	if AUI_FightData.esoVersion then
		AUI_MeterStatistic_LabelESOVersion:SetText(AUI_FightData.esoVersion)
	else
		AUI_MeterStatistic_LabelESOVersion:SetText(GetESOVersionString())
	end
	
	AUI_MeterStatistic_Inner_ListBox_SourceUnits:SelectRowByIndex(0, true)
	
	local numRecords = GetNumRecords()
	
	AUI_MeterStatistic_LabelSaveLimit:SetText(AUI.L10n.GetString("record_limit") .. ": " .. numRecords .. " / " .. METER_STATISTIC_SAVED_LIMIT_COUNT)
	
	if numRecords >= METER_STATISTIC_SAVED_LIMIT_COUNT then
		AUI_MeterStatistic_LabelSaveLimit:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_LIMIT_REACHED, 1):UnpackRGBA())
	else
		AUI_MeterStatistic_LabelSaveLimit:SetColor(AUI.Color.ConvertHexToRGBA(METER_STATISTIC_COLOR_LIMIT_NOT_REACHED, 1):UnpackRGBA())
	end
end

function AUI.Combat.Statistics.DoesShow()
	return not AUI_MeterStatistic:IsHidden()
end

function AUI.Combat.Statistics.Show()
	AUI.Combat.Statistics.UpdateUI()
	
	if not AUI.Combat.Statistics.DoesShow() then
		SCENE_MANAGER:Show("AUI_METER_STATISTIC_SCENE")
	end	
end

function AUI.Combat.Statistics.Hide()
	if AUI.Combat.Statistics.DoesShow() then
		gOpenRecordDialog:Close()
		SCENE_MANAGER:Hide("AUI_METER_STATISTIC_SCENE")
	end
end

function AUI.Combat.Statistics.Toggle()
	if AUI.Combat.IsEnabled() then
		if AUI.Combat.Statistics.DoesShow() then
			AUI.Combat.Statistics.Hide()
		else
			AUI.Combat.Statistics.Show()
			SetGameCameraUIMode(true)
		end
	end
end

function AUI.Combat.Statistics.Load()
	if gIsLoaded then
		return
	end	

	gSetRecordsFunc = function(...) SetRecords(...) end
	
	local scene = ZO_Scene:New("AUI_METER_STATISTIC_SCENE", SCENE_MANAGER)
	scene:AddFragment(ZO_HUDFadeSceneFragment:New(AUI_MeterStatistic))
    scene:RegisterCallback("StateChange",
		function(oldState, newState) 
			if newState == SCENE_SHOWING then 
				AUI.Combat.Statistics.UpdateUI() 
			elseif newState == SCENE_HIDING then 
				gOpenRecordDialog:Close() 
			end 
		end)	

	CreateUI()
	
	gIsLoaded = true	
end