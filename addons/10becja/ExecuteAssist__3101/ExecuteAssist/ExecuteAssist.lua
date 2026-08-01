-------------------------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------------------------

ExAs = {}
 
ExAs.name = "ExecuteAssist"
ExAs.version = 1.0
ExAs.executeText = "Execute!"
ExAs.executeText2 = "Execute!"

-------------------------------------------------------------------------------------------------
-- Libraries
-------------------------------------------------------------------------------------------------
local LAM2 = LibAddonMenu2

-------------------------------------------------------------------------------------------------
-- Help functions
-------------------------------------------------------------------------------------------------

function GetExecuteThreshold()
	local unitClassId = GetUnitClassId("player")
	if unitClassId == 2 then -- Sorc
		ExAs.executeText = "Start the zapping!"
		ExAs.executeText2 = "Zap Zap Zap!"
		return(0.2)
	end
	if unitClassId == 3 then -- Nightblade
		ExAs.executeText = "Commence Shlinking!"
		ExAs.executeText2 = "Shlink Shlink Shlink!"
		return(0.25)
	end
	return(0)
end

-------------------------------------------------------------------------------------------------
-- UI Elements
-------------------------------------------------------------------------------------------------

ExAs.Alert = {}

ExAs.Alert.Show = false

ExAs.Alert.Default = {
	left = 800,
	top = 300,
	MinimumHitpointsThreshold = 3,
	Enabled = true,
}

function ExAs.OnIndicatorMoveStop()
	ExAs.Alert.Settings.left = ExAsAlert:GetLeft()
	ExAs.Alert.Settings.top = ExAsAlert:GetTop()
end

function ExAs.RestorePosition()
	local left = ExAs.Alert.Settings.left
	local top = ExAs.Alert.Settings.top
	ExAsAlert:ClearAnchors()
	ExAsAlert:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

-------------------------------------------------------------------------------------------------
-- Main Functions
-------------------------------------------------------------------------------------------------

function ExAs.CalcExecutability(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if not IsUnitAttackable("reticleover") then
		ExAsAlert:SetHidden(true)
		return
	end

	local currentTargetHP, maxTargetHP = GetUnitPower("reticleover", POWERTYPE_HEALTH)
	local targetPercent = currentTargetHP / maxTargetHP
	local healthThreshold = ExAs.Alert.Settings.MinimumHitpointsThreshold * 1000000

	if maxTargetHP > healthThreshold and currentTargetHP > 0 and targetPercent < ExAs.executeThreshold then

		if targetPercent < .05 then
			ExAsAlert_Label:SetText("FINISH THEM!")
		elseif targetPercent < ExAs.executeThreshold / 2 then
			ExAsAlert_Label:SetText(ExAs.executeText2)
		else
			ExAsAlert_Label:SetText(ExAs.executeText)
		end

		ExAsAlert:SetHidden(false)
	else
		ExAsAlert:SetHidden(true)
	end
end

function ExAs.OnPlayerCombatState(eventCode, inCombat)
	if not ExAs.Alert.Settings.Enabled then return end

	if inCombat then
		EVENT_MANAGER:RegisterForUpdate(ExAs.name, 500, ExAs.CalcExecutability)
		EVENT_MANAGER:RegisterForEvent(ExAs.name, EVENT_RETICLE_TARGET_CHANGED, ExAs.CalcExecutability)
	else
		ExAsAlert:SetHidden(true)
		EVENT_MANAGER:UnregisterForUpdate(ExAs.name)
		EVENT_MANAGER:UnregisterForEvent(ExAs.name, EVENT_RETICLE_TARGET_CHANGED)
	end
end


-------------------------------------------------------------------------------------------------
-- Settings
-------------------------------------------------------------------------------------------------

function ExAs.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Execute Assist",
		displayName = "Execute Assist",
		author = "becja",
		version = tostring(ExAs.version),
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("ExecuteAssistControl", panelData)
	local optionsData = {
		{
			type = "checkbox",
			name = "Enable",
			getFunc = function() return ExAs.Alert.Settings.Enabled end,
			setFunc = function(newValue) ExAs.Alert.Settings.Enabled = newValue end,
		},
		{
			type = "header",
			name = "Test",
			width = "full",
		},
		{
			type = "button",
			name = function() if ExAs.Alert.Show then return "Hide" else return "Show" end end,
			tooltip = "When ON the execute alert will be displayed. Use this to preview and change the position.",
			func = function(control)
					ExAs.Alert.Show = not ExAs.Alert.Show
					ExAsAlert:SetHidden(not ExAs.Alert.Show)
				end,
		},
		{
			type = "header",
			name = "Settings",
			width = "full",
		},
		{
			type = "slider",
			name = "Health Threshold",
			tooltip = "How much health (in millions) should a target have before an alert is shown?",
			min = 0,
			max = 20,
			step = 1,
			default = 3,
			getFunc = function() return ExAs.Alert.Settings.MinimumHitpointsThreshold end,
			setFunc = function(newValue) ExAs.Alert.Settings.MinimumHitpointsThreshold = newValue end,
		},
	}
	LAM2:RegisterOptionControls("ExecuteAssistControl", optionsData)
end

-------------------------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------------------------

function ExAs:Initialize()
	-- UI
	ExAs.Alert.Settings = ZO_SavedVars:NewAccountWide("ExecuteAssistVariables", 1, nil, ExAs.Alert.Default)
	ExAs.RestorePosition()
	-- Settings
	ExAs.CreateSettingsWindow()
	-- Main
	ExAs.executeThreshold = GetExecuteThreshold()
	if ExAs.executeThreshold > 0 then
		EVENT_MANAGER:RegisterForEvent(ExAs.name, EVENT_PLAYER_COMBAT_STATE, ExAs.OnPlayerCombatState)
	end
	EVENT_MANAGER:UnregisterForEvent(ExAs.name, EVENT_ADD_ON_LOADED)
end

function ExAs.OnAddOnLoaded(event, addonName)
	if addonName == ExAs.name then
		ExAs:Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(ExAs.name, EVENT_ADD_ON_LOADED, ExAs.OnAddOnLoaded)
