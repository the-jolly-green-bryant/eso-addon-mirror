local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

IH = {}
IH.lastColor = {0, 0, 0, 0}
IH.Default = {
	Toggle = false,
	DepletingHealthBar = true,
	ExecuteBar = true,
	ExecuteBorder = true;
	HealthBarEnemyColor = {0.75, 0, 0, 1},
	HealthBarAllyColor = {0.23, 0.74, 0.36, 1},
	HealthBarNeutralColor = {0.70, 0.68, 0.33, 1},
	HealthBarPlayerColor = {0, 0.72, 0.74, 1},
	ExecutionBarColor = {0.6, 0, 0.74, 1},
	BarWidth = 239,
	BarHeight = 33,
	PercentXPos = -60,
	PercentYPos = 0,
	OffsetX = 1040,
	OffsetY = 534,
	ExecuteBarOffset = 25,
	Names = true,
	Percents = true,
	NameXPos = 0,
	NameYPos = 54,
	TargetMaxDPS = 10000;
	DPSMeterHeight = 15;
	DPSToggle = true;
}
IH.name = "IH"
IH.version = 1.5
IH.UPDATE_INTERVAL = 30 -- in milliseconds
IH.enemyName = ""
IH.fadeMode = 0
IH.barAlpha = 1.0
IH.permaNames = true
IH.ExecuteBarOffset = 25
IH.permaPercents = true
IH.permaUp = false
IH.loaded = false
IH.vibrant = 0
IH.timeFlag = 0;
IH.lastHealthPercent = 1;
IH.inCombat = false;
IH.startedCombatTime = GetGameTimeMilliseconds();
IH.inCombatTotalTime = 0;
IH.inCombatTotalDamage = 0;
IH.DPSMeterWidth = 0;
IH.DPSMeterHeight = 0;

local ExecuteBorder;
 
function IH:Initialize()
	IH.savedVariables = ZO_SavedVars:New("IHVars", IH.version, nil, IH.Default)
	IH.CreateSettingsWindow()

	IH.permaUp = IH.savedVariables.Toggle
	IH.permaPercents = IH.savedVariables.Percents
	IH.targetMaxDPS = IH.savedVariables.TargetMaxDPS
	IH.permaNames = IH.savedVariables.Names
	IH.DPSMeterWidth = IH.savedVariables.DPSMeterWidth;
	IH.DPSMeterHeight = IH.savedVariables.DPSMeterHeight;
	IH.ExecuteBarOffset = IH.savedVariables.ExecuteBarOffset
	ExecuteBorder = IH.savedVariables.ExecuteBorder
	IH.SetBarSize(IH.savedVariables.BarWidth, IH.savedVariables.BarHeight)
	IHWindowLabelP:SetAnchor(BOTTOMLEFT, IHWindowStatusBarGlare, BOTTOMLEFT, IH.savedVariables.PercentXPos, IH.savedVariables.PercentYPos)
	IHWindowLabel:SetAnchor(BOTTOMLEFT, IHWindowStatusBarGlare, BOTTOMLEFT, IH.savedVariables.NameXPos, IH.savedVariables.NameYPos)
	IHWindowStatusBarUnderSlow:SetHidden(not IH.savedVariables.DepletingHealthBar)
	IHWindowExecutionBar:SetHidden(not IH.savedVariables.ExecuteBar)
	IHWindowExecutionBorder:SetHidden(not IH.savedVariables.ExecuteBorder)
	local parentOffsetX = IHWindow:GetLeft()
	local parentOffsetY = IHWindow:GetTop()
	IHWindowExecutionBar:SetAnchor(TOPLEFT, IHWindow, TOPLEFT, ((IH.savedVariables.ExecuteBarOffset) * IH.savedVariables.BarWidth), 0)
	IHWindowExecutionBorder:SetDimensions(IH.savedVariables.BarWidth + 20, IH.savedVariables.BarHeight + 20)
	IHWindowExecutionBorder:SetAnchor(TOPLEFT, IHWindow, TOPLEFT, -10, -10)
	IHWindowLabelDebug:SetText("")

	local ourName = GetUnitName("player")
 
	IHWindowLabel:SetText(ourName)
	IHWindowLabelP:SetText("100%")
	IHWindowDPSLabel:SetScale(0.5)
	
	IH.Update();
	IHWindow:ClearAnchors();
	IHWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, IH.savedVariables.OffsetX, IH.savedVariables.OffsetY);
	IHWindow:SetAlpha(0);
	IHWindowDPSBox:SetDimensions(IH.DPSMeterWidth, IH.DPSMeterHeight);
	IHWindowDPSBox:SetHidden(not IH.savedVariables.DPSToggle);
	IHWindowDPSLabel:SetHidden(not IH.savedVariables.DPSToggle);
	IHWindowDPSBoxLeftEdge:SetHidden(not IH.savedVariables.DPSToggle);
	IHWindowDPSBoxRightEdge:SetHidden(not IH.savedVariables.DPSToggle);
	if(IH.permaUp == true) then
		IHWindow:SetMouseEnabled(true);
		IHWindow:SetMovable(true);
	else
		IHWindow:SetMouseEnabled(false);
		IHWindow:SetMovable(false);
	end
 
	IH.SaveLoc()
	EVENT_MANAGER:UnregisterForEvent(IH.name, EVENT_ADD_ON_LOADED)
	IH.loaded = true

	EVENT_MANAGER:RegisterForEvent(IH.name, EVENT_RETICLE_TARGET_CHANGED, IH.UpdateLook)
	EVENT_MANAGER:RegisterForEvent(IH.name, EVENT_COMBAT_EVENT, IH.CombatEvent)
	EVENT_MANAGER:RegisterForEvent(IH.name, EVENT_PLAYER_COMBAT_STATE, IH.CombatStateHandler)
end

function IH.TickAssignMove()
	IH.TickAssign()
	IHWindowExecutionBar:SetAlpha(0)
end

function IH.SaveLoc()
	IH.savedVariables.OffsetX = IHWindow:GetLeft()
	IH.savedVariables.OffsetY = IHWindow:GetTop()
	IHWindowExecutionBar:SetAnchor(TOPLEFT, IHWindow, TOPLEFT, ((IH.savedVariables.ExecuteBarOffset) * IH.savedVariables.BarWidth), 0)
	IHWindowExecutionBorder:SetDimensions(IH.savedVariables.BarWidth + 20, IH.savedVariables.BarHeight + 20)
	IHWindowExecutionBorder:SetAnchor(TOPLEFT, IHWindow, TOPLEFT, -10, -10)
	IH.TickAssign()
end

function IH.SetBarSize(_width, _height)
	IHWindowDPSBox:SetDimensions(_width, IH.DPSMeterHeight)
	IHWindowStatusBarGlare:SetDimensions(_width, _height / 3)
	IHWindowStatusBarGlareUnder:SetDimensions(_width, _height / 2)
	IHWindowStatusBarUnder:SetDimensions(_width, _height)
	IHWindowStatusBarUnderSlow:SetDimensions(_width, _height)
	IHWindowBackdrop:SetDimensions(_width, _height)
	IHWindowBorder:SetDimensions(_width, _height)
	IHWindow:SetDimensions(_width, _height)
	IHWindowExecutionBar:SetDimensions(5, _height)
	IHWindow2k:SetDimensions(5, _height / 2)
	IHWindow4k:SetDimensions(5, _height / 2)
	IHWindow6k:SetDimensions(5, _height / 2)
	IHWindow8k:SetDimensions(5, _height / 2)
	IHWindow10k:SetDimensions(5, _height / 2)
	IHWindow12k:SetDimensions(5, _height / 2)
	IHWindow14k:SetDimensions(5, _height / 2)
	IHWindow16k:SetDimensions(5, _height / 2)
	IHWindow18k:SetDimensions(5, _height / 2)
	IHWindow20k:SetDimensions(5, _height / 2)
	IHWindow22k:SetDimensions(5, _height / 2)
	IHWindow24k:SetDimensions(5, _height / 2)
	IHWindow26k:SetDimensions(5, _height / 2)
	IHWindow28k:SetDimensions(5, _height / 2)
	IHWindow30k:SetDimensions(5, _height)
	IHWindow60k:SetDimensions(5, _height)
	IHWindow90k:SetDimensions(5, _height)
	IHWindow120k:SetDimensions(5, _height)
	IHWindow150k:SetDimensions(5, _height)
	IHWindow180k:SetDimensions(5, _height)
	IHWindow210k:SetDimensions(5, _height)
	IHWindow240k:SetDimensions(5, _height)
	IHWindow270k:SetDimensions(5, _height)
	IHWindow300k:SetDimensions(5, _height)
	IHWindow330k:SetDimensions(5, _height)
	IHWindow360k:SetDimensions(5, _height)
	IHWindow390k:SetDimensions(5, _height)
	IHWindow420k:SetDimensions(5, _height)
	
end

function IH.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Improvised Healthbar",
		displayName = "Improvised Healthbar",
		author = "XiiDraco",
		version = IH.version,
		slashCommand = "/IH",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Improvised_Healthbar", panelData)
	local optionsData = {
		[1] = {
			type = "header",
			name = "Health Bar Settings",
		},
		[2] = {
			type = "description",
			text = "Adjust settings for target health bar.",
		},
		[3] = {
			type = "checkbox",
			name = "Toggle Permanant Health Bar",
			tooltip = "Turn ON to force the target health bar onto the screen, regardless of target. This is useful for moving the health bar to its desired location.",
			default = false,
			getFunc = function() return IH.savedVariables.Toggle end,
			setFunc = function(newValue) 
				IH.savedVariables.Toggle = newValue
				IH.permaUp = newValue
				if(IH.permaUp == true) then
					IHWindow:SetMouseEnabled(true);
					IHWindow:SetMovable(true);
				else
					IHWindow:SetMouseEnabled(false);
					IHWindow:SetMovable(false);
				end
				if(enemyNameTwo == "") then
					IH.FadeIn()
				end
				IHWindow:SetHidden(false)  end,
		},
		[4] = {
			type = "checkbox",
			name = "Toggle Names",
			tooltip = "Turn on to show player and NPC names above health bar.",
			default = true,
			getFunc = function() return IH.savedVariables.Names end,
			setFunc = function(newValue) 
				IH.savedVariables.Names = newValue
				IH.permaNames = newValue
				IHWindow:SetHidden(false)  end,
		},
		[5] = {
			type = "checkbox",
			name = "Toggle Percentages",
			tooltip = "Turn on to show percentages in the health bar.",
			default = true,
			getFunc = function() return IH.savedVariables.Percents end,
			setFunc = function(newValue) 
				IH.savedVariables.Percents = newValue
				IH.permaPercents = newValue
				IHWindow:SetHidden(false)  end,
		},
		[7] = {
			type = "slider",
			name = "Percentage X Position",
			tooltip = "Adjusts the X Position of the percantage value relative to the Health Bar",
			min = -5000,
			max = 5000,
			step = 1,
			default = -60,
			getFunc = function() return IH.savedVariables.PercentXPos end,
			setFunc = function(newValue) 
						IH.savedVariables.PercentXPos = newValue
						IHWindowLabelP:SetAnchor(BOTTOMLEFT, IHWindowStatusBarGlare, BOTTOMLEFT, IH.savedVariables.PercentXPos, IH.savedVariables.PercentYPos)
						end,
		},
		[8] = {
			type = "slider",
			name = "Percentage Y Position",
			tooltip = "Adjusts the Y Position of the percantage value relative to the Health Bar",
			min = -5000,
			max = 5000,
			step = 1,
			default = 0,
			getFunc = function() return IH.savedVariables.PercentYPos end,
			setFunc = function(newValue) 
						IH.savedVariables.PercentYPos = newValue
						IHWindowLabelP:SetAnchor(BOTTOMLEFT, IHWindowStatusBarGlare, BOTTOMLEFT, IH.savedVariables.PercentXPos, IH.savedVariables.PercentYPos)
						end,
		},
		[9] = {
			type = "slider",
			name = "Name X Position",
			tooltip = "Adjusts the X Position of the percantage value relative to the Health Bar",
			min = -5000,
			max = 5000,
			step = 1,
			default = 0,
			getFunc = function() return IH.savedVariables.NameXPos end,
			setFunc = function(newValue) 
						IH.savedVariables.NameXPos = newValue
						IHWindowLabel:SetAnchor(BOTTOMLEFT, IHWindowStatusBarGlare, BOTTOMLEFT, IH.savedVariables.NameXPos, IH.savedVariables.NameYPos)
						end,
		},
		[10] = {
			type = "slider",
			name = "Name Y Position",
			tooltip = "Adjusts the Y Position of the percantage value relative to the Health Bar",
			min = -5000,
			max = 5000,
			step = 1,
			default = 54,
			getFunc = function() return IH.savedVariables.NameYPos end,
			setFunc = function(newValue) 
						IH.savedVariables.NameYPos = newValue
						IHWindowLabel:SetAnchor(BOTTOMLEFT, IHWindowStatusBarGlare, BOTTOMLEFT, IH.savedVariables.NameXPos, IH.savedVariables.NameYPos)
						end,
		},
		
		[11] = {
			type = "slider",
			name = "Health Bar Width",
			tooltip = "Adjusts the width of the target health bar.",
			min = 100,
			max = 4000,
			step = 1,
			default = 239,
			getFunc = function() return IH.savedVariables.BarWidth end,
			setFunc = function(newValue) 
						IH.savedVariables.BarWidth = newValue
						IH.SetBarSize(newValue, IH.savedVariables.BarHeight)
						IHWindowExecutionBorder:SetDimensions(IH.savedVariables.BarWidth + 20, IH.savedVariables.BarHeight + 20)
						IHWindowExecutionBorder:SetAnchor(TOPLEFT, IHWindow, TOPLEFT, -10, -10)
						end,
		},
		[12] = {
			type = "slider",
			name = "Health Bar Height",
			tooltip = "Adjusts the height of the target health bar.",
			min = 25,
			max = 100,
			step = 1,
			default = 33,
			getFunc = function() return IH.savedVariables.BarHeight end,
			setFunc = function(newValue) 
						IH.savedVariables.BarHeight= newValue
						IH.SetBarSize(IH.savedVariables.BarWidth, newValue)
						IHWindowExecutionBorder:SetDimensions(IH.savedVariables.BarWidth + 20, IH.savedVariables.BarHeight + 20)
						IHWindowExecutionBorder:SetAnchor(TOPLEFT, IHWindow, TOPLEFT, -10, -10)
						end,
		},
		[13] = {
			type = "checkbox",
			name = "Toggle Execution Bar",
			tooltip = "Turn ON to show when a target falls below an execution ability's threshold.",
			default = true,
			getFunc = function() return IH.savedVariables.ExecuteBar end,
			setFunc = function(newValue) 
				IH.savedVariables.ExecuteBar = newValue
				IHWindowExecutionBar:SetHidden(not newValue)  end,
		},
		[14] = {
			type = "slider",
			name = "Execution Bar Percentage",
			tooltip = "Adjusts the percentage where the execution bar will lie.",
			min = 0,
			max = 100,
			step = 1,
			default = 25,
			getFunc = function() return IH.savedVariables.ExecuteBarOffset end,
			setFunc = function(newValue) 
						IH.savedVariables.ExecuteBarOffset = (newValue)
						IH.ExecuteBarOffset = newValue
						local parentOffsetX = IHWindow:GetLeft()
						local parentOffsetY = IHWindow:GetTop()
						IHWindowExecutionBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((newValue / 100) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
						end,
		},
		[15] = {
			type = "checkbox",
			name = "Execution Pop Up",
			tooltip = "Highlights the health bar with flashes when execute is ready.",
			default = true,
			getFunc = function() return IH.savedVariables.ExecuteBorder end,
			setFunc = function(newValue) 
				IH.savedVariables.ExecuteBorder = newValue
				ExecuteBorder = newValue
				IHWindowExecutionBorder:SetHidden(not newValue)  end,
		},
		[16] = {
			type = "colorpicker",
			name = "Enemy Health Bar Color",
			tooltip = "Changes the color of the health bar.",
			getFunc = function() return unpack( IH.savedVariables.HealthBarEnemyColor ) end,
			setFunc = function(r,g,b,a) 
				IH.savedVariables.HealthBarEnemyColor = { r, g, b, a}
				end,
		},
		[17] = {
			type = "colorpicker",
			name = "Ally Health Bar Color",
			tooltip = "Changes the color of the health bar.",
			getFunc = function() return unpack( IH.savedVariables.HealthBarAllyColor ) end,
			setFunc = function(r,g,b,a) 
				IH.savedVariables.HealthBarAllyColor = { r, g, b, a}
				end,
		},
		[18] = {
			type = "colorpicker",
			name = "Neutral Health Bar Color",
			tooltip = "Changes the color of the health bar.",
			getFunc = function() return unpack( IH.savedVariables.HealthBarNeutralColor ) end,
			setFunc = function(r,g,b,a) 
				IH.savedVariables.HealthBarNeutralColor = { r, g, b, a}
				end,
		},
		[19] = {
			type = "colorpicker",
			name = "Player Health Bar Color",
			tooltip = "Changes the color of the health bar.",
			getFunc = function() return unpack( IH.savedVariables.HealthBarPlayerColor ) end,
			setFunc = function(r,g,b,a) 
				IH.savedVariables.HealthBarPlayerColor = { r, g, b, a}
				end,
		},
		[20] = {
			type = "colorpicker",
			name = "Execution Bar Color",
			tooltip = "Changes the color of the execution bar.",
			getFunc = function() return unpack( IH.savedVariables.ExecutionBarColor ) end,
			setFunc = function(r,g,b,a) 
				IH.savedVariables.ExecutionBarColor = { r, g, b, a}
				--d(unpack(IH.savedVariables.ExecutionBarColor))
				end,
		},
		[21] = {
			type = "slider",
			name = "Health Bar  X Position",
			tooltip = "Adjusts the location where the Health Bar is. (It's recommneded to use the arbitrary values and not the slider)",
			min = -4000,
			max = 4000,
			step = 1,
			default = 1040,
			getFunc = function() return IH.savedVariables.OffsetX end,
			setFunc = function(newValue) 
						IH.savedVariables.OffsetX= (newValue)
						IHWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, IH.savedVariables.OffsetX, IH.savedVariables.OffsetY)
						end,
		},
		[22] = {
			type = "slider",
			name = "Health Bar Y Position",
			tooltip = "Adjusts the location where the Health Bar is. (It's recommneded to use the arbitrary values and not the slider)",
			min = -4000,
			max = 4000,
			step = 1,
			default = 534,
			getFunc = function() return IH.savedVariables.OffsetY end,
			setFunc = function(newValue) 
						IH.savedVariables.OffsetY= (newValue)
						IHWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, IH.savedVariables.OffsetX, IH.savedVariables.OffsetY)
						end,
		},
		[23] = {
			type = "checkbox",
			name = "Toggle DPS Meter",
			tooltip = "Turn on to show current damage per second.",
			default = true,
			getFunc = function() return IH.savedVariables.DPSToggle end,
			setFunc = function(newValue)
				IH.savedVariables.DPSToggle = newValue;
				IHWindowDPSBox:SetHidden(not newValue);
				IHWindowDPSLabel:SetHidden(not newValue);
				IHWindowDPSBoxLeftEdge:SetHidden(not newValue);
				IHWindowDPSBoxRightEdge:SetHidden(not newValue);
				end,
		},
		
	}
	LAM2:RegisterOptionControls("Improvised_Healthbar", optionsData)
end

function IH.SaveLoc()
	IH.savedVariables.OffsetX = IHWindow:GetLeft()
	IH.savedVariables.OffsetY = IHWindow:GetTop()
end

local function updateFadeIn()
	IH.barAlpha = IH.barAlpha + (0.06  * (IH.UPDATE_INTERVAL / 10))
	if IH.barAlpha >= 1 then
		IH.barAlpha = 1
		IH.fadeMode = 0
		EVENT_MANAGER:UnregisterForUpdate("updateFadeIn")
		IHWindowStatusBarUnderSlow:SetHidden(false)
	end
	IHWindow:SetAlpha(IH.barAlpha)
	
end

local function updateFadeOut()


	IH.barAlpha = IH.barAlpha - (0.06  * (IH.UPDATE_INTERVAL / 10))
	if IH.barAlpha <= 0 then
		IH.barAlpha = 0
		IH.fadeMode = 0
		EVENT_MANAGER:UnregisterForUpdate("updateFadeOut")
		EVENT_MANAGER:UnregisterForUpdate("updateFlashing");
	end
	IHWindow:SetAlpha(IH.barAlpha)
	IHWindowStatusBarUnderSlow:SetHidden(true)
	
end

local function updateFlashing()
	IH.vibrant = IH.vibrant + (0.2  * (IH.UPDATE_INTERVAL / 10));
	
	IHWindowExecutionBorder:SetAlpha(math.sin(IH.vibrant) + 0.5)
	-- if the bar is set to off force the bar to always be transparent
	if(ExecuteBorder == false) then
		IHWindowExecutionBorder:SetAlpha(0)
	end
	
	-- if the bar is greater than the execute offset set to be transparent --
	if(IH.lastHealthPercent > IH.ExecuteBarOffset) then
		IHWindowExecutionBorder:SetAlpha(0)
	end
	
	-- if the enemy is dead, don't flash
	if(IH.lastHealthPercent < 0.5) then
		IHWindowExecutionBorder:SetAlpha(0)
	end
	
end

local function updateStam()
	local barValSlow = IHWindowStatusBarUnderSlow:GetValue()
	local barVal = IHWindowStatusBarUnder:GetValue();
	
	if barValSlow == barVal then
		
		EVENT_MANAGER:UnregisterForUpdate("updateStam")
		return
	end
	
	if barValSlow < barVal then
		IHWindowStatusBarUnderSlow:SetValue(barVal)
		-- the bar is full, we can stop now
		EVENT_MANAGER:UnregisterForUpdate("updateStam")
		
		return
	end
	
	barValSlow = barValSlow - (30 * (IH.UPDATE_INTERVAL / 10))
	
	IHWindowStatusBarUnderSlow:SetValue(barValSlow)
end

function IH.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log)
	--Kudos to Shadow-Fighter's Recount mod which I took a look at to learn the event code constants
	--update time flag (used elsewhere) to the current time in milliseconds
	IH.timeFlag = GetGameTimeMilliseconds()
	--set exitEarly condition to true if we catch an event we want to ignore
	local exitEarly = IH.IgnoredEvents(isError, hitValue, result, powerType, damageType, sourceType);

	--remove self target sources
	if(sourceType == targetType) then
		exitEarly = true;
	end

	--check for early exit condition, if true send to Update
	if(exitEarly == true) then
		IH.Update();
		return;
	else
		--Add Values to combat info totals
		IH.inCombatTotalTime = GetGameTimeMilliseconds() - IH.startedCombatTime
		IH.inCombatTotalDamage = IH.inCombatTotalDamage + hitValue;
		IH.calculatedDPS = math.floor(IH.inCombatTotalDamage / (IH.inCombatTotalTime / 1000));
		--d(IH.calculatedDPS);

		--print debug for events
		--d(IH.inCombatTotalTime.."  "..hitValue.." -> "..abilityName);
		IHWindowDPSLabel:SetText(IH.calculatedDPS.." DPS");
		IHWindowDPSBox:SetDimensions(IH.savedVariables.BarWidth * math.min(1, IH.calculatedDPS / IH.targetMaxDPS), IH.DPSMeterHeight)
	end
end

function IH.IgnoredEvents(isError, hitValue, result, powerType, damageType, sourceType)
	if(isError
		or hitValue == 0
		or powerType == POWERTYPE_INVALID
		or powerType == POWERTYPE_MOUNT_STAMINA
		or damageType == DAMAGE_TYPE_NONE
		or result == ACTION_RESULT_HEAL
		or result == ACTION_RESULT_CRITICAL_HEAL
		or result == ACTION_RESULT_HOT_TICK
		or result == ACTION_RESULT_HOT_TICK_CRITICAL
		or result == ACTION_RESULT_BLOCKED
		or result == ACTION_RESULT_DAMAGE_SHIELDED
		or result == ACTION_RESULT_PARRIED
		or result == ACTION_RESULT_REFLECTED
		or result == ACTION_RESULT_IMMUNE
		or result == ACTION_RESULT_FALL_DAMAGE
		or (sourceType ~= COMBAT_UNIT_TYPE_PLAYER
			and sourceType ~= COMBAT_UNIT_TYPE_PLAYER_PET
			and sourceType ~= COMBAT_UNIT_TYPE_GROUP)
		) then
		return true;
	else
		return false;
	end
end

function IH.Update()
	if IH.loaded == true then
	
		if(GetUnitName("reticleover") ~= "") then
			if GetUnitReaction("reticleover") == UNIT_REACTION_HOSTILE then
				red, green, blue, alpha = unpack(IH.savedVariables.HealthBarEnemyColor)
				IH.lastColor = IH.savedVariables.HealthBarEnemyColor
			end
			if GetUnitReaction("reticleover") == UNIT_REACTION_FRIENDLY then
				red, green, blue, alpha = unpack(IH.savedVariables.HealthBarAllyColor)
				IH.lastColor = IH.savedVariables.HealthBarAllyColor
			end
			if GetUnitReaction("reticleover") == UNIT_REACTION_NPC_ALLY then
				red, green, blue, alpha = unpack(IH.savedVariables.HealthBarAllyColor)
				IH.lastColor = IH.savedVariables.HealthBarAllyColor
			end
			if GetUnitReaction("reticleover") == UNIT_REACTION_NEUTRAL then
				red, green, blue, alpha = unpack(IH.savedVariables.HealthBarNeutralColor)
				IH.lastColor = IH.savedVariables.HealthBarNeutralColor
			end
			if GetUnitReaction("reticleover") == UNIT_REACTION_PLAYER_ALLY then
				red, green, blue, alpha = unpack(IH.savedVariables.HealthBarPlayerColor)
				IH.lastColor = IH.savedVariables.HealthBarPlayerColor
			end
		else
			red, green, blue, alpha = unpack(IH.lastColor)
		end
		
		
		
		
		IHWindowStatusBarUnder:SetColor(red, green, blue, alpha)
		IHWindowStatusBarGlareUnder:SetColor(red + .2, green + .2, blue + .2, alpha)
		IHWindowStatusBarGlare:SetColor(red + .4, green + .4, blue + .4, alpha)
		IHWindowExecutionBar:SetEdgeColor(unpack(IH.savedVariables.ExecutionBarColor))
		IHWindowExecutionBorder:SetEdgeColor(unpack(IH.savedVariables.ExecutionBarColor))
		
		local enemyNameTwo = GetUnitName("reticleover")
		if(enemyNameTwo ~= "") then
		
			IH.FadeIn()
			local current, max, effectiveMax = GetUnitPower("reticleover", POWERTYPE_HEALTH)

			IH.lastHealthPercent = ((current / max) * 100)
			
			
			IHWindowLabel:SetText(enemyNameTwo)
			if IH.permaNames ~= true then
				IHWindowLabel:SetText("")
			end
			
			if(IH.lastHealthPercent > IH.savedVariables.ExecuteBarOffset) then
				IHWindowExecutionBorder:SetAlpha(0)
			end
			
			if(max ~= 0) then
				IHWindowLabelP:SetText(math.floor((current / max) * 100) .. "%")
			end
			if IH.permaPercents ~= true then
				IHWindowLabelP:SetText("")
			end
			if(IH.lastHealthPercent > IH.savedVariables.ExecuteBarOffset) then
				EVENT_MANAGER:UnregisterForUpdate("updateFlashing")
				IHWindowExecutionBorder:SetAlpha(0)
			else
				EVENT_MANAGER:RegisterForUpdate("updateFlashing", IH.UPDATE_INTERVAL, function() updateFlashing() end)
				IHWindowExecutionBorder:SetAlpha(0)
			end
			
			IHWindowStatusBarGlare:SetMinMax(0, max)
			IHWindowStatusBarGlareUnder:SetMinMax(0, max)
			IHWindowStatusBarUnder:SetMinMax(0, max)
			IHWindowStatusBarUnderSlow:SetMinMax(0, max)
			
			IH.TickAssign()
			
			IHWindowStatusBarGlare:SetValue(current)
			IHWindowStatusBarGlareUnder:SetValue(current)
			IHWindowStatusBarUnder:SetValue(current)
			
			if (enemyNameTwo ~= IH.enemyName) then
				IHWindowStatusBarUnderSlow:SetValue(current)
			end

			IH.enemyName = enemyNameTwo
			
		else
			IH.FadeOut()
			if (IH.permaUp == true) then
				IHWindowStatusBarGlare:SetValue(0)
				IHWindowStatusBarGlareUnder:SetValue(0)
				IHWindowStatusBarUnder:SetValue(0)
				IHWindowStatusBarUnderSlow:SetValue(0)
				IHWindowLabel:SetText("")
				
			end
		end
		
		EVENT_MANAGER:RegisterForUpdate("updateStam", IH.UPDATE_INTERVAL, function() updateStam() end)
		if(IH.barAlpha > 0) then
			if(IH.lastHealthPercent <= IH.savedVariables.ExecuteBarOffset) then
				EVENT_MANAGER:RegisterForUpdate("updateFlashing", IH.UPDATE_INTERVAL / 2, function() updateFlashing() end)
			end
		end
	end
end

function IH.TickAssign()
	local current, max, effectiveMax = GetUnitPower("reticleover", POWERTYPE_HEALTH)
	local parentOffsetX = IHWindow:GetLeft()
	local parentOffsetY = IHWindow:GetTop()
	
	IHWindowExecutionBar:SetAlpha(1)
	IHWindowExecutionBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((IH.savedVariables.ExecuteBarOffset / 100) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		
	
		IHWindow2k:SetHidden(true)
		IHWindow4k:SetHidden(true)
		IHWindow6k:SetHidden(true)
		IHWindow8k:SetHidden(true)
		IHWindow10k:SetHidden(true)
		IHWindow12k:SetHidden(true)
		IHWindow14k:SetHidden(true)
		IHWindow16k:SetHidden(true)
		IHWindow18k:SetHidden(true)
		IHWindow20k:SetHidden(true)
		IHWindow22k:SetHidden(true)
		IHWindow24k:SetHidden(true)
		IHWindow26k:SetHidden(true)
		IHWindow28k:SetHidden(true)
		IHWindow30k:SetHidden(true)
		IHWindow60k:SetHidden(true)
		IHWindow90k:SetHidden(true)
		IHWindow120k:SetHidden(true)
		IHWindow150k:SetHidden(true)
		IHWindow180k:SetHidden(true)
		IHWindow210k:SetHidden(true)
		IHWindow240k:SetHidden(true)
		IHWindow270k:SetHidden(true)
		IHWindow300k:SetHidden(true)
		IHWindow330k:SetHidden(true)
		IHWindow360k:SetHidden(true)
		IHWindow390k:SetHidden(true)
		IHWindow420k:SetHidden(true)
	
	if (max < 45000) then
			
		

			
		if max > 2000 then
			IHWindow2k:SetHidden(false)
		end
			IHWindow2k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((2000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 4000 then
			IHWindow4k:SetHidden(false)
		end
			IHWindow4k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((4000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 6000 then
			IHWindow6k:SetHidden(false)
		end
			IHWindow6k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((6000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 8000 then
			IHWindow8k:SetHidden(false)
		end
			IHWindow8k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((8000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 10000 then
			IHWindow10k:SetHidden(false)
		end
			IHWindow10k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((10000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 12000 then
			IHWindow12k:SetHidden(false)
		end
			IHWindow12k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((12000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 14000 then
			IHWindow14k:SetHidden(false)
		end
			IHWindow14k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((14000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 16000 then
			IHWindow16k:SetHidden(false)
		end
			IHWindow16k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((16000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 18000 then
			IHWindow18k:SetHidden(false)
		end
			IHWindow18k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((18000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 20000 then
			IHWindow20k:SetHidden(false)
		end
			IHWindow20k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((20000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 22000 then
			IHWindow22k:SetHidden(false)
		end
			IHWindow22k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((22000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 24000 then
			IHWindow24k:SetHidden(false)
		end
			IHWindow24k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((24000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 26000 then
			IHWindow26k:SetHidden(false)
		end
			IHWindow26k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((26000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 28000 then
			IHWindow28k:SetHidden(false)
		end
			IHWindow28k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((28000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		if max > 30000 then
			IHWindow30k:SetHidden(false)
		end
			IHWindow30k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((30000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)

	else
		if max < (420000) then
			if max > 30000 then
				IHWindow30k:SetHidden(false)
			end
				IHWindow30k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((30000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
			if max > 60000 then
						IHWindow60k:SetHidden(false)
					end
						IHWindow60k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((60000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
			if max > 90000 then
						IHWindow90k:SetHidden(false)
					end
						IHWindow90k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((90000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
			if max > 120000 then
						IHWindow120k:SetHidden(false)
					end
						IHWindow120k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((120000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
			if max > 150000 then
						IHWindow150k:SetHidden(false)
					end
						IHWindow150k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((150000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
			if max > 180000 then
						IHWindow180k:SetHidden(false)
					end
						IHWindow180k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((180000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
			if max > 210000 then
						IHWindow210k:SetHidden(false)
					end
						IHWindow210k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((210000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
			if max > 240000 then
						IHWindow240k:SetHidden(false)
					end
						IHWindow240k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((240000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
			if max > 270000 then
						IHWindow270k:SetHidden(false)
					end
						IHWindow270k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((270000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
			if max > 300000 then
						IHWindow300k:SetHidden(false)
					end
						IHWindow300k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((300000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
			if max > 330000 then
						IHWindow330k:SetHidden(false)
					end
						IHWindow330k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((330000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
			if max > 360000 then
						IHWindow360k:SetHidden(false)
					end
						IHWindow360k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((360000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
			if max > 390000 then
						IHWindow390k:SetHidden(false)
					end
						IHWindow390k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((390000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
			if max > 420000 then
						IHWindow420k:SetHidden(false)
					end
						IHWindow420k:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ((420000 / max) * IH.savedVariables.BarWidth) + parentOffsetX, parentOffsetY)
		end
			
				
	end

end

function IH.FadeOut()
	if(IH.permaUp == false) then
		if IH.fadeMode == 1 then
			EVENT_MANAGER:UnregisterForUpdate("updateFadeIn")
		end
		EVENT_MANAGER:RegisterForUpdate("updateFadeOut", IH.UPDATE_INTERVAL, function() updateFadeOut() end)
		IH.fadeMode = -1
	end
end

function IH.FadeIn()
	if IH.fadeMode == -1 then
		EVENT_MANAGER:UnregisterForUpdate("updateFadeOut")
	end
	EVENT_MANAGER:RegisterForUpdate("updateFadeIn", IH.UPDATE_INTERVAL, function() updateFadeIn() end)
	IH.fadeMode = 1
end

function IH.UpdateLook()
	IH.Update()
end

function IH.OnAddOnLoaded(event, addonName)
   if addonName == IH.name then
    IH:Initialize()
  end
end

function IH.CombatStateHandler(eventCode, inCombat)
	IH.startedCombatTime = GetGameTimeMilliseconds();
	IH.inCombatTotalTime = 0;
	IH.inCombatTotalDamage = 0;
	if(inCombat) then
		IH.startedCombat();
	else
		IH.endedCombat();
	end
end

function IH.UpdateCombatDPS()
	IH.inCombatTotalTime = GetGameTimeMilliseconds() - IH.startedCombatTime
	IH.calculatedDPS = math.floor(IH.inCombatTotalDamage / (IH.inCombatTotalTime / 1000));

	--d(IH.inCombatTotalTime);
	IHWindowDPSLabel:SetText(IH.calculatedDPS.." DPS");
	IHWindowDPSBox:SetDimensions(IH.savedVariables.BarWidth * math.min(1, IH.calculatedDPS / IH.targetMaxDPS), IH.DPSMeterHeight)
end

function IH.startedCombat()
	--d("Entered Combat");
	IH.inCombat = true;
	EVENT_MANAGER:RegisterForUpdate("updateCombatDPS", IH.UPDATE_INTERVAL * 2, function() IH.UpdateCombatDPS() end)
	IH.combatStartTime = IH.timeFlag;
end

function IH.endedCombat()
	--d("Exited Combat");
	IH.inCombat = false;
	EVENT_MANAGER:UnregisterForUpdate("updateCombatDPS")
	--d("DPS: "..IH.calculatedDPS)
end
 
EVENT_MANAGER:RegisterForEvent(IH.name, EVENT_ADD_ON_LOADED, IH.OnAddOnLoaded)


