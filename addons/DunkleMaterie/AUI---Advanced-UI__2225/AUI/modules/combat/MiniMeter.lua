local MINIMETER_SCENE_FRAGMENT = nil
local ICON_SIZE = 24

local isLoaded = false

local miniMeter = nil

local MINIMETER_MOUSE_OVER_COLOR = "#e98e22"

function AUI.ResetMiniMeter()
	if not isLoaded then
		return
	end

	AUI_Minimeter_Label_DPS_Out:SetText("-")
	AUI_Minimeter_Label_Total_Damage_Out:SetText("-")	
	
	AUI_Minimeter_Label_HPS_Out:SetText("-")
	AUI_Minimeter_Label_Total_Heal_Out:SetText("-")	
	
	AUI_Minimeter_Label_DPS_In:SetText("-")
	AUI_Minimeter_Label_Total_Damage_In:SetText("-")	
	
	AUI_Minimeter_Label_HPS_In:SetText("-")
	AUI_Minimeter_Label_Total_Heal_In:SetText("-")		
	
	AUI_Minimeter_Label_Time:SetText("-")
end

local function OnMouseEnter()
	if not AUI.Settings.Combat.minimeter_show_background then
		AUI_Minimeter_BG:SetHidden(false)
	end

	AUI_Minimeter_BG:SetEdgeColor(AUI.Color.ConvertHexToRGBA(MINIMETER_MOUSE_OVER_COLOR, 1.0):UnpackRGBA())
end

local function OnMouseExit()
	if not AUI.Settings.Combat.minimeter_show_background then
		AUI_Minimeter_BG:SetHidden(true)
	end

	AUI_Minimeter_BG:SetEdgeColor(1, 1, 1, 1) 
end

local function OnMouseDown(_eventCode, _button, _ctrl, _alt, _shift)
	if _button == 1 and not AUI.Settings.Combat.lock_windows then
		AUI_Minimeter:SetMovable(true)
		AUI_Minimeter:StartMoving()	
	end
end

local function OnMouseUp(_eventCode, _button, _ctrl, _alt, _shift)
	AUI_Minimeter:SetMovable(false)
	
	if _button == 1 then
		AUI.HideMouseMenu()
	elseif _button == 2 then
		if not IsUnitInCombat(AUI_PLAYER_UNIT_TAG) then
			AUI.ShowMouseMenu()		
			AUI.AddMouseMenuButton("AUI_METER_PCT", AUI.L10n.GetString("post_combat_statistic"), function() AUI.Combat.PostPlayerCombatStatistics() end)
			AUI.AddMouseMenuButton("AUI_METER_RCS", AUI.L10n.GetString("reset_combat_statistic"), AUI.ResetMiniMeter)
			if AUI.Combat.Statistics.IsShow() then
				AUI.AddMouseMenuButton("AUI_METER_SCS", AUI.L10n.GetString("hide_combat_statistic"), AUI.Combat.Statistics.Toggle)
			else
				AUI.AddMouseMenuButton("AUI_METER_SCS", AUI.L10n.GetString("show_combat_statistic"), AUI.Combat.Statistics.Toggle)
			end			
		end
	end
	
	if _button == 1 and not AUI.Settings.Combat.lock_windows then
		_, AUI.Settings.Combat.minimeter_position.point, _, AUI.Settings.Combat.minimeter_position.relativePoint, AUI.Settings.Combat.minimeter_position.offsetX, AUI.Settings.Combat.minimeter_position.offsetY = AUI_Minimeter:GetAnchor()
	end
end

local function UpdateLabels(_labelControl1, _labelControl2, _data)
	if _data then
		if _data.total and _data.total > 0 then
			local avarage = AUI.Combat.CalculateDPS(_data.total, _data.endTimeMS)
					
			if avarage > 0 then
				_labelControl2:SetText(AUI.String.ToFormatedNumber(avarage))
			end	
			
			_labelControl1:SetText(AUI.String.ToFormatedNumber(_data.total))
		end
	end
end

local function UpdateCombatTime()
	local combatTime = AUI.Combat.GetCombatTime()

	if combatTime > 0 then
		local _timeString = 0

		if combatTime >= 1 then
			_timeString = AUI.Time.GetFormatedString(combatTime, 1)
		elseif combatTime >= 0.1 then
			_timeString = AUI.Time.GetFormatedString(combatTime, 2)	
		else
			_timeString = AUI.Time.GetFormatedString(combatTime, 3)
		end
		
		AUI_Minimeter_Label_Time:SetText(_timeString)
	end
end

function AUI.Combat.Minimeter.UpdateAll()
	if not isLoaded then
		return
	end

	local playerData = AUI.Combat.GetPlayerData()
	if playerData then
		if AUI.Settings.Combat.minimeter_show_total_damage_out then
			UpdateLabels(AUI_Minimeter_Label_Total_Damage_Out, AUI_Minimeter_Label_DPS_Out, playerData[AUI_COMBAT_DATA_TYPE_DAMAGE_OUT])
		end
		
		if AUI.Settings.Combat.minimeter_show_total_heal_out then
			UpdateLabels(AUI_Minimeter_Label_Total_Heal_Out, AUI_Minimeter_Label_HPS_Out, playerData[AUI_COMBAT_DATA_TYPE_HEAL_OUT])
		end
		
		if AUI.Settings.Combat.minimeter_show_total_damage_in then
			UpdateLabels(AUI_Minimeter_Label_Total_Damage_In, AUI_Minimeter_Label_DPS_In, playerData[AUI_COMBAT_DATA_TYPE_DAMAGE_IN])
		end
		
		if AUI.Settings.Combat.minimeter_show_total_heal_in then
			UpdateLabels(AUI_Minimeter_Label_Total_Heal_In, AUI_Minimeter_Label_HPS_In, playerData[AUI_COMBAT_DATA_TYPE_HEAL_IN])
		end		
	end
	
	if AUI.Settings.Combat.minimeter_show_combat_time then
		UpdateCombatTime()
	end
end

function AUI.Combat.Minimeter.IsShow()
	return not AUI_Minimeter:IsHidden()
end

function AUI.Combat.Minimeter.Show()
	if not isLoaded then
		return
	end

	AUI_Minimeter:SetHidden(false)
end

function AUI.Combat.Minimeter.Hide()
	if not isLoaded then
		return
	end

	AUI_Minimeter:SetHidden(true)
end

function AUI.Combat.Minimeter.ShowPreview()
	if not isLoaded then
		return
	end

	MINIMETER_SCENE_FRAGMENT.hiddenReasons:SetHiddenForReason("ShouldntShow", true)
	AUI.Combat.Minimeter.Show()
end

function AUI.Combat.Minimeter.HidePreview()
	if not isLoaded then
		return
	end

	MINIMETER_SCENE_FRAGMENT.hiddenReasons:SetHiddenForReason("ShouldntShow", false)
	AUI.Combat.Minimeter.Hide()
end

function AUI.Combat.Minimeter.UpdateUI()
	if not isLoaded then
		return
	end

	local top = 4
	local left = 10
	local distance = 70
	local minWidth = 200
	
	if AUI.Settings.Combat.minimeter_show_background then
		AUI_Minimeter_BG:SetHidden(false)			
	else
		AUI_Minimeter_BG:SetHidden(true)
	end

	if AUI.Settings.Combat.minimeter_show_dps_out then
		AUI_Minimeter_Icon_DPS_Out:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)
	
		left = left + ICON_SIZE
	
		AUI_Minimeter_Label_DPS_Out:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)
		
		left = left + distance
		
		AUI_Minimeter_Icon_DPS_Out:SetHidden(false)
		AUI_Minimeter_Label_DPS_Out:SetHidden(false)
	else
		AUI_Minimeter_Icon_DPS_Out:SetHidden(true)
		AUI_Minimeter_Label_DPS_Out:SetHidden(true)
	end		
		
	if AUI.Settings.Combat.minimeter_show_total_damage_out then
		AUI_Minimeter_Icon_Total_Damage_Out:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)
	
		left = left + ICON_SIZE
	
		AUI_Minimeter_Label_Total_Damage_Out:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)
	
		left = left + distance
	
		AUI_Minimeter_Icon_Total_Damage_Out:SetHidden(false)
		AUI_Minimeter_Label_Total_Damage_Out:SetHidden(false)
	else
		AUI_Minimeter_Icon_Total_Damage_Out:SetHidden(true)
		AUI_Minimeter_Label_Total_Damage_Out:SetHidden(true)
	end
	
	if AUI.Settings.Combat.minimeter_show_hps_out then
		AUI_Minimeter_Icon_HPS_Out:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)
	
		left = left + ICON_SIZE
	
		AUI_Minimeter_Label_HPS_Out:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)	
				
		left = left + distance	
				
		AUI_Minimeter_Icon_HPS_Out:SetHidden(false)
		AUI_Minimeter_Label_HPS_Out:SetHidden(false)
	else
		AUI_Minimeter_Icon_HPS_Out:SetHidden(true)
		AUI_Minimeter_Label_HPS_Out:SetHidden(true)
	end
	
	if AUI.Settings.Combat.minimeter_show_total_heal_out then
		AUI_Minimeter_Icon_Total_Heal_Out:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)
	
		left = left + ICON_SIZE
		
		AUI_Minimeter_Label_Total_Heal_Out:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)
		
		left = left + distance
	
		AUI_Minimeter_Icon_Total_Heal_Out:SetHidden(false)
		AUI_Minimeter_Label_Total_Heal_Out:SetHidden(false)
	else
		AUI_Minimeter_Icon_Total_Heal_Out:SetHidden(true)
		AUI_Minimeter_Label_Total_Heal_Out:SetHidden(true)
	end
	
	if AUI.Settings.Combat.minimeter_show_dps_in then
		AUI_Minimeter_Icon_DPS_In:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)
	
		left = left + ICON_SIZE
	
		AUI_Minimeter_Label_DPS_In:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)	
				
		left = left + distance	
				
		AUI_Minimeter_Icon_DPS_In:SetHidden(false)
		AUI_Minimeter_Label_DPS_In:SetHidden(false)
	else
		AUI_Minimeter_Icon_DPS_In:SetHidden(true)
		AUI_Minimeter_Label_DPS_In:SetHidden(true)
	end	
	
	if AUI.Settings.Combat.minimeter_show_total_damage_in then
		AUI_Minimeter_Icon_Total_Damage_In:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)
	
		left = left + ICON_SIZE
	
		AUI_Minimeter_Label_Total_Damage_In:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)	
				
		left = left + distance	
				
		AUI_Minimeter_Icon_Total_Damage_In:SetHidden(false)
		AUI_Minimeter_Label_Total_Damage_In:SetHidden(false)
	else
		AUI_Minimeter_Icon_Total_Damage_In:SetHidden(true)
		AUI_Minimeter_Label_Total_Damage_In:SetHidden(true)
	end	
	
	if AUI.Settings.Combat.minimeter_show_hps_in then
		AUI_Minimeter_Icon_HPS_In:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)
	
		left = left + ICON_SIZE
	
		AUI_Minimeter_Label_HPS_In:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)	
				
		left = left + distance	
				
		AUI_Minimeter_Icon_HPS_In:SetHidden(false)
		AUI_Minimeter_Label_HPS_In:SetHidden(false)
	else
		AUI_Minimeter_Icon_HPS_In:SetHidden(true)
		AUI_Minimeter_Label_HPS_In:SetHidden(true)
	end	
	
	if AUI.Settings.Combat.minimeter_show_total_heal_in then
		AUI_Minimeter_Icon_Total_Heal_In:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)
	
		left = left + ICON_SIZE
	
		AUI_Minimeter_Label_Total_Heal_In:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)	
				
		left = left + distance	
				
		AUI_Minimeter_Icon_Total_Heal_In:SetHidden(false)
		AUI_Minimeter_Label_Total_Heal_In:SetHidden(false)
	else
		AUI_Minimeter_Icon_Total_Heal_In:SetHidden(true)
		AUI_Minimeter_Label_Total_Heal_In:SetHidden(true)
	end	
	
	if AUI.Settings.Combat.minimeter_show_combat_time then
		AUI_Minimeter_Icon_Time:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)
	
		left = left + ICON_SIZE
	
		AUI_Minimeter_Label_Time:SetAnchor(TOPLEFT, miniMeter, TOPLEFT, left, top)
	
		left = left + distance
		
		AUI_Minimeter_Icon_Time:SetHidden(false)
		AUI_Minimeter_Label_Time:SetHidden(false)
	else
		AUI_Minimeter_Icon_Time:SetHidden(true)
		AUI_Minimeter_Label_Time:SetHidden(true)
	end				
		
	if minWidth > left then
		left = minWidth
	end
		
	AUI_Minimeter:ClearAnchors()	
	AUI_Minimeter:SetAnchor(AUI.Settings.Combat.minimeter_position.point, GuiRoot, AUI.Settings.Combat.minimeter_position.relativePoint, AUI.Settings.Combat.minimeter_position.offsetX, AUI.Settings.Combat.minimeter_position.offsetY)		
		
	AUI_Minimeter:SetDimensions(left, ICON_SIZE + 8)	
end

function AUI.Combat.Minimeter.SetToDefaultPosition(defaultSettings)
	if not isLoaded then
		return
	end

	AUI_Minimeter:ClearAnchors()	
	AUI_Minimeter:SetAnchor(defaultSettings.minimeter_position.point, GuiRoot, defaultSettings.minimeter_position.relativePoint, defaultSettings.minimeter_position.offsetX, defaultSettings.minimeter_position.offsetY)
	_, AUI.Settings.Combat.minimeter_position.point, _, AUI.Settings.Combat.minimeter_position.relativePoint, AUI.Settings.Combat.minimeter_position.offsetX, AUI.Settings.Combat.minimeter_position.offsetY = AUI_Minimeter:GetAnchor()
end

local function SetTooltip(_control, _str)
	_control:SetHandler("OnMouseDown", OnFrameMouseDown)
	_control:SetHandler("OnMouseUp", OnFrameMouseUp)	
	_control:SetHandler("OnMouseEnter", 
		function() 
			AUI_Minimeter_BG:SetEdgeColor(AUI.Color.ConvertHexToRGBA(MINIMETER_MOUSE_OVER_COLOR, 1.0):UnpackRGBA())
			AUI.ShowTooltip(_str)
		end)
	_control:SetHandler("OnMouseExit", 
		function()  
			AUI_Minimeter_BG:SetEdgeColor(1, 1, 1, 1)
			AUI.HideTooltip() 
		end)	
end

local function CreateUI()
	AUI_Minimeter:SetHandler("OnMouseDown", OnMouseDown)
	AUI_Minimeter:SetHandler("OnMouseUp", OnMouseUp)	
	AUI_Minimeter:SetHandler("OnMouseEnter", OnMouseEnter)
	AUI_Minimeter:SetHandler("OnMouseExit", OnMouseExit)	
	
	
	AUI_Minimeter_Icon_DPS_Out:SetDimensions(ICON_SIZE, ICON_SIZE)
	AUI_Minimeter_Label_DPS_Out:SetFont("$(MEDIUM_FONT)|" .. 13 .. "|" .. "thick-outline")
	SetTooltip(AUI_Minimeter_Icon_DPS_Out, AUI.L10n.GetString("damage_per_second") .. " (" .. AUI.L10n.GetString("outgoing") .. ")")
	SetTooltip(AUI_Minimeter_Label_DPS_Out, AUI.L10n.GetString("damage_per_second") .. " (" .. AUI.L10n.GetString("outgoing") .. ")")
	
	AUI_Minimeter_Icon_Total_Damage_Out:SetDimensions(ICON_SIZE, ICON_SIZE)
	AUI_Minimeter_Label_Total_Damage_Out:SetFont("$(MEDIUM_FONT)|" .. 13 .. "|" .. "thick-outline")
	SetTooltip(AUI_Minimeter_Icon_Total_Damage_Out, AUI.L10n.GetString("total_damage") .. " (" .. AUI.L10n.GetString("outgoing") .. ")")
	SetTooltip(AUI_Minimeter_Label_Total_Damage_Out, AUI.L10n.GetString("total_damage") .. " (" .. AUI.L10n.GetString("outgoing") .. ")")
	
	AUI_Minimeter_Icon_HPS_Out:SetDimensions(ICON_SIZE, ICON_SIZE)
	AUI_Minimeter_Label_HPS_Out:SetFont("$(MEDIUM_FONT)|" .. 13 .. "|" .. "thick-outline")
	SetTooltip(AUI_Minimeter_Icon_HPS_Out, AUI.L10n.GetString("healing_per_second") .. " (" .. AUI.L10n.GetString("outgoing") .. ")")
	SetTooltip(AUI_Minimeter_Label_HPS_Out, AUI.L10n.GetString("healing_per_second") .. " (" .. AUI.L10n.GetString("outgoing") .. ")")	
	
	AUI_Minimeter_Icon_Total_Heal_Out:SetDimensions(ICON_SIZE, ICON_SIZE)
	AUI_Minimeter_Label_Total_Heal_Out:SetFont("$(MEDIUM_FONT)|" .. 13 .. "|" .. "thick-outline")	
	SetTooltip(AUI_Minimeter_Icon_Total_Heal_Out, AUI.L10n.GetString("total_healing") .. " (" .. AUI.L10n.GetString("outgoing") .. ")")
	SetTooltip(AUI_Minimeter_Label_Total_Heal_Out, AUI.L10n.GetString("total_healing") .. " (" .. AUI.L10n.GetString("outgoing") .. ")")	
		
	AUI_Minimeter_Icon_DPS_In:SetDimensions(ICON_SIZE, ICON_SIZE)
	AUI_Minimeter_Label_DPS_In:SetFont("$(MEDIUM_FONT)|" .. 13 .. "|" .. "thick-outline")
	SetTooltip(AUI_Minimeter_Icon_DPS_In, AUI.L10n.GetString("damage_per_second") .. " (" .. AUI.L10n.GetString("incoming") .. ")")
	SetTooltip(AUI_Minimeter_Label_DPS_In, AUI.L10n.GetString("damage_per_second") .. " (" .. AUI.L10n.GetString("incoming") .. ")")
	
	AUI_Minimeter_Icon_Total_Damage_In:SetDimensions(ICON_SIZE, ICON_SIZE)
	AUI_Minimeter_Label_Total_Damage_In:SetFont("$(MEDIUM_FONT)|" .. 13 .. "|" .. "thick-outline")
	SetTooltip(AUI_Minimeter_Icon_Total_Damage_In, AUI.L10n.GetString("total_damage") .. " (" .. AUI.L10n.GetString("incoming") .. ")")
	SetTooltip(AUI_Minimeter_Label_Total_Damage_In, AUI.L10n.GetString("total_damage") .. " (" .. AUI.L10n.GetString("incoming") .. ")")		
	
	AUI_Minimeter_Icon_HPS_In:SetDimensions(ICON_SIZE, ICON_SIZE)
	AUI_Minimeter_Label_HPS_In:SetFont("$(MEDIUM_FONT)|" .. 13 .. "|" .. "thick-outline")
	SetTooltip(AUI_Minimeter_Icon_HPS_In, AUI.L10n.GetString("healing_per_second") .. " (" .. AUI.L10n.GetString("incoming") .. ")")
	SetTooltip(AUI_Minimeter_Label_HPS_In, AUI.L10n.GetString("healing_per_second") .. " (" .. AUI.L10n.GetString("incoming") .. ")")		
	
	AUI_Minimeter_Icon_Total_Heal_In:SetDimensions(ICON_SIZE, ICON_SIZE)
	AUI_Minimeter_Label_Total_Heal_In:SetFont("$(MEDIUM_FONT)|" .. 13 .. "|" .. "thick-outline")	
	SetTooltip(AUI_Minimeter_Icon_Total_Heal_In, AUI.L10n.GetString("total_healing") .. " (" .. AUI.L10n.GetString("incoming") .. ")")
	SetTooltip(AUI_Minimeter_Label_Total_Heal_In, AUI.L10n.GetString("total_healing") .. " (" .. AUI.L10n.GetString("incoming") .. ")")	
	
	AUI_Minimeter_Icon_Time:SetDimensions(ICON_SIZE, ICON_SIZE)
	AUI_Minimeter_Label_Time:SetFont("$(MEDIUM_FONT)|" .. 13 .. "|" .. "thick-outline")
	SetTooltip(AUI_Minimeter_Icon_Time, AUI.L10n.GetString("combat_time"))
	SetTooltip(AUI_Minimeter_Label_Time, AUI.L10n.GetString("combat_time"))		
end

function AUI.Combat.Minimeter.Load()
	if isLoaded then
		return
	end

	isLoaded = true	
	
	CreateUI()
	
	MINIMETER_SCENE_FRAGMENT = ZO_SimpleSceneFragment:New(AUI_Minimeter)	
	MINIMETER_SCENE_FRAGMENT.hiddenReasons = ZO_HiddenReasons:New()		
    MINIMETER_SCENE_FRAGMENT:SetConditional(function()
        return not MINIMETER_SCENE_FRAGMENT.hiddenReasons:IsHidden()
    end)		

	HUD_SCENE:AddFragment(MINIMETER_SCENE_FRAGMENT)
	HUD_UI_SCENE:AddFragment(MINIMETER_SCENE_FRAGMENT)
	SIEGE_BAR_SCENE:AddFragment(MINIMETER_SCENE_FRAGMENT)
	if SIEGE_BAR_UI_SCENE then
		SIEGE_BAR_UI_SCENE:AddFragment(MINIMETER_SCENE_FRAGMENT)
	end		
	
	AUI.ResetMiniMeter()
	AUI.Combat.Minimeter.UpdateUI()
end