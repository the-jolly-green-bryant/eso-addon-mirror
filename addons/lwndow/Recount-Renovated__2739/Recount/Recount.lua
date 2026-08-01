--[[==========================================
	Recount
	==========================================
	A damage meter addon.
	Based on Fayn's work
	Updated and maintained by McGuffin since 0.4.0
	Updated by Shadow-Fighter since 0.5.1
	Updated by Ferather since 0.6.4
	Updated by lwndow since 0.6.4
	Ferather branch merged to 0.7.x series
  ]]--

Recount = {}
Recount.name = "Recount"
Recount.command = "/recount"
Recount.versionString = "0.7.6"
Recount.versionSettings = 10
Recount.versionBuild = 25

Recount.time = 0
Recount.refreshThreshold = 250
Recount.inCombat = false
Recount.onExitCombat = false
Recount.lastUpdateUI = 0
Recount.isDebugMode = false
Recount.preMinMode = RC_MODE_COMBAT_LOG
Recount.preCombatMode = RC_MODE_DAMAGE_DONE

Recount.totalMode = false
Recount.topBarId = 1
Recount.maxComputedBars = 32
Recount.UIinMenu = false

Recount.trackedUnits = {}

local EVENT_TYPE_IGNORE = 0
local EVENT_TYPE_DAMAGE = 1
local EVENT_TYPE_HEAL = 2
local EVENT_TYPE_DAMAGE_DEFLECTED = 3

local RC_MODE_DAMAGE_DONE = 0
local RC_MODE_DAMAGE_DONE_TOTAL = 1
local RC_MODE_DAMAGE_TAKEN = 2
local RC_MODE_DAMAGE_TAKEN_TOTAL = 3
local RC_MODE_HEALING_DONE = 4
local RC_MODE_HEALING_DONE_TOTAL = 5
local RC_MODE_HEALING_TAKEN = 6
local RC_MODE_HEALING_TAKEN_TOTAL = 7
local RC_MODE_COMBAT_LOG = 8
local RC_MODE_EOL = 9
local RC_MODE_MINIMIZED = 10


local modeStrings = {
	[RC_MODE_DAMAGE_DONE] = "Damage Done",
	[RC_MODE_DAMAGE_DONE_TOTAL] = "Total Damage Done",
	[RC_MODE_DAMAGE_TAKEN] = "Damage Taken",
	[RC_MODE_DAMAGE_TAKEN_TOTAL] = "Total Damage Taken",
	[RC_MODE_HEALING_DONE] = "Healing Done",
	[RC_MODE_HEALING_DONE_TOTAL] = "Total Healing Done",
	[RC_MODE_HEALING_TAKEN] = "Healing Taken",
	[RC_MODE_HEALING_TAKEN_TOTAL] = "Total Healing Taken",
	[RC_MODE_COMBAT_LOG] = "Combat Log",
	[RC_MODE_MINIMIZED] = "N/A",
}


local UI_STATUSBAR_MAX = 32
local UI_STATUSBAR_HEIGHT = 25
local UI_TITLEBAR_HEIGHT = 25

Recount.settingsDefaults = {
	numberFormat = 1,
	currentMode = RC_MODE_DAMAGE_DONE_TOTAL,
	numStoredSessions = 10,
	autoSwitchMode = false,
	dotTag = "^",
	critTag =  "*",
	minimizeDuringCombat = false,
	showSkillDetails = true,
	hideOutOfCombat = false,
	hideOutOfCombatDelayInSeconds = 15,
	suspendDataCollectionWhileHidden = false,
	onlyUseKey = false,
	minDPSLogValue = 0,
	minHPSLogValue = 0,
	useAccountWide = false,
	damageIgnore = 0,
	healIgnore = 0,

	countDeflectedDmg = false,

	progressBarHeight = 25,
	progressBarFontFace = "Univers 67",
	progressBarFontSize = 13,
	progressBarFontOutline = "soft-shadow-thin",
	progressBarFontColor = { r = 0, g = 0, b = 0, a = 1 },
	progressBarColor = {
		r = 0.8,
		g = 0.8,
		b = 0.5,
		a = 0.85
	},

	wndMain = {
		x = 10,
		y = 10,
		width = 340,
		height = 160,
		isVisible = true,
	},
}

--[[==========================================
	playerUnit
	Prototype for the unit structure
	==========================================]]--
local playerUnit = {
	displayName = zo_strformat("<<C:1>>", GetUnitName( 'player' )),

	sessionList = {},
	sessionCurrent = 1,
	sessionNum = 0,
	session = nil,

	total = {
		damageDone = 0,
		damageTaken = 0,
		healingDone = 0,
		healingTaken = 0,
		
		healingCount = 0,
		critHealingCount = 0,
		damageCount = 0,
		critDamageCount = 0,
		
		dps = 0,
		hps = 0,
		
		timeStart = 0,
		timeSpan = 0,
		
		damagePerAbility = {},
		healPerAbility = {},
	},
}


--[[==========================================
	Initialize
	==========================================]]--
function Recount.Initialize( eventCode, addOnName )
	
	if ( addOnName ~= Recount.name ) then
		return
	end

	Recount.settings = ZO_SavedVars:NewAccountWide( "RecountSettings" , Recount.versionSettings, nil, Recount.settingsDefaults, nil )
	
	if ( not Recount.settings.useAccountWide ) then
		Recount.settings = ZO_SavedVars:NewCharacterNameSettings( "RecountSettings" , Recount.versionSettings, nil, Recount.settingsDefaults, nil )
	end

	EVENT_MANAGER:RegisterForEvent( Recount.name, EVENT_COMBAT_EVENT, Recount.CombatEvent )
	EVENT_MANAGER:RegisterForEvent( Recount.name, EVENT_PLAYER_COMBAT_STATE, Recount.CombatStateEvent )
	EVENT_MANAGER:RegisterForEvent( Recount.name, EVENT_PLAYER_DEAD, Recount.playerExitCombat )

	SLASH_COMMANDS[Recount.command] = Recount.SlashCommands

	local	w = WINDOW_MANAGER:CreateTopLevelWindow()
			w:SetDimensions(1,1)
			w:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
			w:SetHidden(true)
	local ssf = ZO_HUDFadeSceneFragment:New(w)
	local h = SCENE_MANAGER:GetScene("hud")
	local ui = SCENE_MANAGER:GetScene("hudui")
	h:AddFragment(ssf)
	ui:AddFragment(ssf)
	ssf:RegisterCallback("StateChange", Recount.autoToggle)
	--

	Recount.InitUI()

	if ( Recount.settings.currentMode == RC_MODE_MINIMIZED ) then
		Recount.settings.currentMode = RC_MODE_COMBAT_LOG
	end
	Recount.SetMode( Recount.settings.currentMode, true )

	Recount.trackedUnits[1] = playerUnit
	Recount.SettingsMenu.Initialize()

	Recount.CombatLogMsg( string.format( "Recount (%s) loaded.", Recount.versionString ) )
	Recount.CombatLogMsg( "Press the 'M' button in the top right corner to switch between modes." )
	Recount.CombatLogMsg( "Press the 'R' button in the top right corner to reset Recount." )
	Recount.doUpdateUI()
end

EVENT_MANAGER:RegisterForEvent( Recount.name, EVENT_ADD_ON_LOADED, Recount.Initialize )

--[[==========================================
	FormatNumber

	Shortens large integers into ..k or ..m text
	==========================================]]--
function Recount.FormatNumber( number )
	if number then
		if Recount.settings.numberFormat == 1 then
			if number > 999999 then
				return 	("%02.2fM"):format(number / 1000000)
			elseif number > 999 then
				return 	("%02.03fK"):format(number / 1000)
			else
				return "" .. math.floor(number)
			end
		else
			return "" .. math.floor(number)
		end
	else
		return ""
	end
end

local function convertTimeStamp(ms)
	local mn = (ms / (1000 * 60)) % 60
	local s = (ms / 1000) % 60
	local ms = (ms % 1000)
	return string.format(" +%02d:%02d:%03d ", mn, s, ms)
end

local function convertTimeStampS(ms)
	local mn = (ms / (1000 * 60))
	local s = (ms / 1000) % 60
	local ms = (ms % 1000)
	return string.format("%d:%02d:%03d", mn, s, ms)
end

function Recount.InitUI()
	if ( Recount.settings.wndMain.width < 10 ) then
		Recount.settings.wndMain.width = Recount.settingsDefaults.wndMain.width
	end

	if ( Recount.settings.wndMain.x < 0 ) then
		Recount.settings.wndMain.x = 0
	end

	if ( Recount.settings.wndMain.x > GuiRoot:GetWidth() ) then
		Recount.settings.wndMain.x = GuiRoot:GetWidth() - Recount.settings.wndMain.width
	end

	RecountUI:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, Recount.settings.wndMain.x, Recount.settings.wndMain.y )
	RecountUI:SetWidth( Recount.settings.wndMain.width )
	RecountUI:SetHeight( Recount.settings.wndMain.height )

	for i = 1, UI_STATUSBAR_MAX do
		local statusBar = CreateControlFromVirtual( "$(parent)Statusbar", RecountUI, "RecountStatusbarTemplate", i )
		statusBar:SetAnchor( TOPLEFT, RecountUI, TOPLEFT, 0, i * UI_STATUSBAR_HEIGHT )
		statusBar:SetMouseEnabled(true)
		statusBar:SetHandler("OnMouseWheel" , Recount.scrollBars)
	end

	RecountUIDebug:SetHidden( true )

	if Recount.settings.hideOutOfCombat then
		Recount.settings.wndMain.isVisible= false
	end

	if ( Recount.settings.wndMain.isVisible == false ) then
		Recount.Hide()
	end

	Recount.FitUIElements()
end

function Recount.scrollBars(self, delta)
	Recount.topBarId = Recount.topBarId - delta
	local clientHeight = RecountUI:GetHeight() - UI_TITLEBAR_HEIGHT - UI_STATUSBAR_HEIGHT
	local numBars = clientHeight / Recount.settings.progressBarHeight
	if Recount.topBarId > Recount.maxComputedBars - numBars then
		Recount.topBarId = Recount.maxComputedBars - numBars
	end
	if Recount.topBarId < 1 then
		Recount.topBarId = 1
	end
	Recount.FitStatusBars()
end

function Recount.MinimizeWindow()
	if ( Recount.settings.currentMode == RC_MODE_MINIMIZED ) then
		return
	end
	Recount.preMinMode = Recount.settings.currentMode
	Recount.SetMode( RC_MODE_MINIMIZED, true )
end

function Recount.RestoreWindow(doUpdate)
	Recount.SetMode( Recount.preMinMode, doUpdate )
end

function Recount.OnResizeStart( self )
	RecountUI:SetHandler("OnUpdate", Recount.FitUIElements)
end

function Recount.OnMoveStop( self )
	Recount.settings.wndMain.x = self:GetLeft()
	Recount.settings.wndMain.y = self:GetTop()
	Recount.settings.wndMain.width = self:GetWidth()
	Recount.settings.wndMain.height = self:GetHeight()
end

function Recount.OnResizeStop( self )
	RecountUI:SetHandler("OnUpdate", nil)
	Recount.OnMoveStop( self )
	Recount.FitUIElements()
end

function Recount.GetMinWidth()
	return 100 + 25 + 25 + 25
end

function Recount.GetMinHeight()
	return UI_STATUSBAR_HEIGHT + UI_TITLEBAR_HEIGHT + Recount.settings.progressBarHeight
end

function Recount.FitStatusBars()
	local clientHeight = RecountUI:GetHeight() - UI_TITLEBAR_HEIGHT - UI_STATUSBAR_HEIGHT
	local numBars = clientHeight / Recount.settings.progressBarHeight
	local offset = 1
	
	for i = 1, UI_STATUSBAR_MAX do
		local statusBar = GetControl(RecountUI, "Statusbar"..i)
		statusBar:SetHidden( true )
		if (i >= Recount.topBarId) and (offset <= numBars) then
			statusBar:SetAnchor( TOPLEFT, RecountUI, TOPLEFT, 2, ( offset-1) * Recount.settings.progressBarHeight + UI_TITLEBAR_HEIGHT )
			statusBar:SetWidth( Recount.settings.wndMain.width - 4)
			statusBar:SetHeight( Recount.settings.progressBarHeight )
			statusBar:SetColor( Recount.settings.progressBarColor.r, Recount.settings.progressBarColor.g, Recount.settings.progressBarColor.b, Recount.settings.progressBarColor.a )
			GetControl(statusBar, "_lblLeft"):SetFont( Recount.SettingsMenu:GetFont() )
			statusBar:SetHidden( false )
			offset = offset + 1
		end
	end
end

function Recount.FitUIElements()
	local w = RecountUI:GetWidth()
	local h = RecountUI:GetHeight()

	if ( w < Recount.GetMinWidth() ) then
		w = Recount.GetMinWidth()
		RecountUI:SetWidth( w )
	end
	if ( h < Recount.GetMinHeight() ) then
		h = Recount.GetMinHeight()
		RecountUI:SetHeight( h )
	end

	RecountUI_Title:SetWidth( w )
	RecountUI_lblStatus:SetWidth( w )

	RecountUI_lblCombatLogBG:SetWidth( w )
	RecountUI_lblCombatLogBG:SetHeight( h - UI_STATUSBAR_HEIGHT )

	RecountUI_lblCombatLog:SetWidth( w )
	RecountUI_lblCombatLog:SetHeight( h - UI_STATUSBAR_HEIGHT - UI_TITLEBAR_HEIGHT )

	RecountUI_Title_Text:SetFont( Recount.SettingsMenu:GetFont() )
	RecountUI_Title_ButtonReset:SetFont( Recount.SettingsMenu:GetFont() )
	RecountUI_Title_Button:SetFont( Recount.SettingsMenu:GetFont() )
	RecountUI_Title_ButtonHide:SetFont( Recount.SettingsMenu:GetFont() )

	RecountUI_lblCombatLog:SetFont( Recount.SettingsMenu:GetFont() )
	RecountUI_lblStatus:SetFont( Recount.SettingsMenu:GetFont() )

	Recount.FitStatusBars()
end

--[[==========================================
	UpdateUI
	==========================================]]--
local function secureDivide(value1, value2)
	if value2 == 0 then
		return 0
	else
		return (value1 / value2)
	end
end

local function getCritStat(data)
	return  secureDivide(data.critHealingCount, data.healingCount)*100,
	secureDivide(data.critDamageCount, data.damageCount)*100
end

local function getMinTimeSpan(t)
	if t < 1000 then
		return 1
	else
		return t / 1000.0
	end
end

function Recount.UpdateUI(ttimer)
	if (ttimer == 0) or  (Recount.lastUpdateUI <= Recount.time) then
		Recount.lastUpdateUI = Recount.time + ttimer
		Recount.doUpdateUI()
	end
end

function Recount.doUpdateUI()
	if (Recount.totalMode) or (playerUnit.session == nil)   then
		local t = getMinTimeSpan(playerUnit.total.timeSpan)
		playerUnit.total.dps = playerUnit.total.damageDone / t
		playerUnit.total.hps = playerUnit.total.healingDone / t
		local critH, critD = getCritStat(playerUnit.total)
		RecountUI_lblStatus:SetText( zo_strformat( "DPS: |ccccc55 <<1>>|r (|cff5555 <<2>>% |r) | | HPS: |c55cc55 <<3>>|r (|cff5555 <<4>>% |r) | | [<<5>>]", Recount.FormatNumber( playerUnit.total.dps ), critD, Recount.FormatNumber( playerUnit.total.hps ), critH, convertTimeStampS(playerUnit.total.timeSpan)) )
	else
		local t = getMinTimeSpan(playerUnit.session.timeSpan)
		playerUnit.session.dps = playerUnit.session.damageDone / t
		playerUnit.session.hps = playerUnit.session.healingDone / t
		local critH, critD = getCritStat(playerUnit.session)
		RecountUI_lblStatus:SetText( zo_strformat( "DPS: |ccccc55 <<1>>|r (|cff5555 <<2>>% |r) | | HPS: |c55cc55 <<3>>|r (|cff5555 <<4>>% |r) | | [<<5>>]", Recount.FormatNumber( playerUnit.session.dps ), critD, Recount.FormatNumber( playerUnit.session.hps ), critH, convertTimeStampS(playerUnit.session.timeSpan)) )
	end
	Recount.UpdateModeUI()
end

function Recount.OnUpdate( self )

	if ( Recount.isResizing ) then
		Recount.FitUIElements()
	end

end

function Recount.CombatLogMsg( msg )
	local tStamp = " "
	if playerUnit.session then
		tStamp = convertTimeStamp(playerUnit.session.timeSpan)
	end
	RecountUI_lblCombatLog:AddMessage( zo_strformat("|c777777 <<1>> |r  <<2>>", tStamp, msg))
end

function Recount.playerEnterCombat()
	EVENT_MANAGER:UnregisterForUpdate("hideOOC")
	if Recount.onExitCombat == true then
		Recount.onExitCombat = false
		return
	end
	Recount.inCombat = true

	Recount.StartNewSession()

	if playerUnit.total.timeStart == 0 then
		playerUnit.total.timeStart = Recount.time
	else
		playerUnit.total.timeStart = Recount.time - playerUnit.total.timeSpan
	end

	Recount.CombatLogMsg( "+++ Combat +++" )
	if (Recount.settings.onlyUseKey == false)  then
		Recount.Show()
	end
	if ( Recount.settings.autoSwitchMode == true ) then
		Recount.preCombatMode = Recount.settings.currentMode
		Recount.SetMode( RC_MODE_COMBAT_LOG, false )
	end
	if ( Recount.settings.minimizeDuringCombat == true ) then
		Recount.MinimizeWindow()
	end
	Recount.UpdateUI(0)
end

function Recount.doPlayerExitCombat()
	EVENT_MANAGER:UnregisterForUpdate("hideOOC")
	if Recount.onExitCombat == false then
		return
	end
	Recount.time = GetGameTimeMilliseconds()
	if (Recount.settings.hideOutOfCombat ==  true) and (Recount.settings.onlyUseKey == false)  then
		EVENT_MANAGER:RegisterForUpdate("hideOOC", Recount.settings.hideOutOfCombatDelayInSeconds * 1000, Recount.Hide)
	end
	if ( Recount.settings.minimizeDuringCombat == true ) then
		Recount.RestoreWindow(false)
	end
	if ( Recount.settings.autoSwitchMode == true ) then
		Recount.SetMode( RC_MODE_DAMAGE_DONE, true )
	end

	if ( playerUnit.session ~= nil ) then
		Recount.CombatLogMsg( zo_strformat( "--- Combat [<<1>>] ---", convertTimeStampS(playerUnit.session.timeSpan) ) )
		Recount.CombatLogMsg( zo_strformat( "--- out: |ccccc55 <<1>>|r / |c55cc55 <<2>>|r; in: |c883333 <<3>>|r dmg", Recount.FormatNumber( playerUnit.session.damageDone ), Recount.FormatNumber( playerUnit.session.healingDone ), Recount.FormatNumber( playerUnit.session.damageTaken ) ) )
	else
		Recount.CombatLogMsg( "--- Combat [%ds] ---" )
	end
	Recount.inCombat = false
	Recount.onExitCombat = false
	Recount.UpdateUI(0)
end

function Recount.playerExitCombat()
	if (Recount.inCombat == true) and (Recount.onExitCombat == false) then
		Recount.onExitCombat = true
		zo_callLater(Recount.doPlayerExitCombat, 1000)
	end
end

function Recount.CombatStateEvent( eventCode, inCombat )
	Recount.time = GetGameTimeMilliseconds()
	if ( inCombat == true ) then
		if not Recount.inCombat then
			Recount.playerEnterCombat()
		end
	else
		Recount.playerExitCombat()
	end
end


--[[==========================================
	CheckIgnoreCombatEvent

	returns EVENT_TYPE_*
	==========================================]]--
function Recount.CheckIgnoreCombatEvent( result, isError, hitValue, powerType, damageType )

	if ( isError ) then
		return EVENT_TYPE_IGNORE, 0, 0, 0, 0
	end

	if ( hitValue == 0 ) then
		return EVENT_TYPE_IGNORE, 0, 0, 0, 0
	end

	if ( powerType == POWERTYPE_INVALID or powerType == POWERTYPE_MOUNT_STAMINA ) then
		return EVENT_TYPE_IGNORE, 0, 0, 0, 0
	end

	if ( damageType == DAMAGE_TYPE_NONE ) then
		return EVENT_TYPE_IGNORE, 0, 0, 0, 0
	end

	if ( result == ACTION_RESULT_HEAL ) then
		return EVENT_TYPE_HEAL, 1, 0, 0, 0
	end

	if ( result == ACTION_RESULT_CRITICAL_HEAL ) then
		return EVENT_TYPE_HEAL, 1, 1, 0, 0
	end

	if ( result == ACTION_RESULT_HOT_TICK ) then
		return EVENT_TYPE_HEAL, 0, 0, 1, 0
	end

	if ( result == ACTION_RESULT_HOT_TICK_CRITICAL ) then
		return EVENT_TYPE_HEAL, 0, 0, 1, 1
	end

	if ( result == ACTION_RESULT_BLOCKED or
		 result == ACTION_RESULT_DAMAGE_SHIELDED or
		 result == ACTION_RESULT_PARRIED or
		 result == ACTION_RESULT_REFLECTED or
		 result == ACTION_RESULT_IMMUNE ) then
		if ( Recount.settings.countDeflectedDmg ) then
			return EVENT_TYPE_DAMAGE, 0, 0, 0, 0
		end
		return EVENT_TYPE_DAMAGE_DEFLECTED, 0, 0, 0, 0
	end

	if ( result == ACTION_RESULT_ABSORBED or
		 result == ACTION_RESULT_BLOCKED_DAMAGE or
		 result == ACTION_RESULT_FALL_DAMAGE or
		 result == ACTION_RESULT_PARTIAL_RESIST or
		 result == ACTION_RESULT_PRECISE_DAMAGE or
		 result == ACTION_RESULT_WRECKING_DAMAGE ) then
		return EVENT_TYPE_DAMAGE, 0, 0, 0, 0
	end

	if ( result == ACTION_RESULT_DAMAGE) then
		return EVENT_TYPE_DAMAGE, 1, 0, 0, 0
	end

	if ( result == ACTION_RESULT_CRITICAL_DAMAGE) then
		return EVENT_TYPE_DAMAGE, 1, 1, 0, 0
	end

	if ( result == ACTION_RESULT_DOT_TICK) then
		return EVENT_TYPE_DAMAGE, 0, 0, 1, 0
	end

	if ( result == ACTION_RESULT_DOT_TICK_CRITICAL) then
		return EVENT_TYPE_DAMAGE, 0, 0, 1, 1
	end

	return EVENT_TYPE_IGNORE, 0, 0, 0, 0
end

function Recount.DebugStringifyUnitType( unitType )
	if ( unitType == COMBAT_UNIT_TYPE_PLAYER ) then
		return "CUT_PLAYER"
	elseif ( unitType == COMBAT_UNIT_TYPE_PLAYER_PET ) then
		return "CUT_PLAYER_PET"
	elseif ( unitType == COMBAT_UNIT_TYPE_GROUP ) then
		return "CUT_GROUP"
	elseif ( unitType == COMBAT_UNIT_TYPE_OTHER ) then
		return "CUT_OTHER"
	elseif ( unitType == COMBAT_UNIT_TYPE_NONE ) then
		return "CUT_NONE"
	else
		return "CUT_UNKNOWN"
	end
end


local function AddAbilityValue( abilityList, abilityName, Value, c, cc, dc, dcc  )
	if ( abilityList[abilityName] == nil ) then
		abilityList[abilityName] = {hitValue = Value, hitCount = c, critCount = cc, dotCount = dc, dotCritCount = dcc}
	else
		local skill = abilityList[abilityName]
		skill.hitValue = skill.hitValue + Value
		skill.hitCount = skill.hitCount + c
		skill.critCount = skill.critCount +  cc
		skill.dotCount = skill.dotCount + dc
		skill.dotCritCount = skill.dotCritCount + dcc
	end

end

local function getTag(b, tag)
	if b then
		return tag
	else
		return ""
	end
end

--[[==========================================
	UnitDamageDone
	==========================================]]--
local function UnitDamageDone( unitID, abilityName, sourceName, targetName, hitValue, result, hitCount, critCount, dotCount, dotCritCount )
	if hitValue <= Recount.settings.damageIgnore then return end

	local u = Recount.trackedUnits[unitID]

	u.session.damageDone = u.session.damageDone + hitValue
	u.session.damageCount = u.session.damageCount + hitCount + dotCount
	u.session.critDamageCount = u.session.critDamageCount + critCount + dotCritCount
	u.total.damageDone = u.total.damageDone + hitValue
	u.total.damageCount = u.total.damageCount + hitCount + dotCount
	u.total.critDamageCount = u.total.critDamageCount + critCount + dotCritCount

	AddAbilityValue( u.total.damagePerAbility, abilityName, hitValue, hitCount, critCount, dotCount, dotCritCount )
	AddAbilityValue( u.session.damagePerAbility, abilityName, hitValue, hitCount, critCount, dotCount, dotCritCount )

	if hitValue >= Recount.settings.minDPSLogValue then
		local eventString = zo_strformat( "|cCCCC55 <<1>><<2>><<3>>|r -> |c883333 <<4>>|r - <<5>>", getTag(dotCount == 1, Recount.settings.dotTag), hitValue, getTag((critCount == 1 ) or (dotCritCount == 1), Recount.settings.critTag), targetName, abilityName )
		Recount.CombatLogMsg( eventString )
	end
end

--[[==========================================
	UnitDamageTaken
	==========================================]]--
local function UnitDamageTaken( unitID, abilityName, sourceName, targetname, hitValue, result, hitCount, critCount, dotCount, dotCritCount )
	if hitValue <= Recount.settings.damageIgnore then return end

	local u = Recount.trackedUnits[unitID]

	u.session.damageTaken = u.session.damageTaken + hitValue
	u.total.damageTaken = u.total.damageTaken + hitValue
	
	if hitValue >= Recount.settings.minDPSLogValue then
		local eventString = zo_strformat( "|cCC4444 <<1>><<2>><<3>>|r <- |c883333 <<4>>|r - <<5>>", getTag(dotCount == 1, Recount.settings.dotTag), hitValue, getTag((critCount == 1 ) or (dotCritCount == 1), Recount.settings.critTag), sourceName, abilityName )
		Recount.CombatLogMsg( eventString )
	end
end

--[[==========================================
	UnitHealingDone
	==========================================]]--
local function UnitHealingDone( unitID, abilityName, sourceName, targetName, hitValue, result, hitCount, critCount, dotCount, dotCritCount )
	if hitValue <= Recount.settings.healIgnore then return end

	local u = Recount.trackedUnits[unitID]

	u.session.healingDone = u.session.healingDone + hitValue
	u.session.healingCount = u.session.healingCount + hitCount + dotCount
	u.session.critHealingCount = u.session.critHealingCount + critCount + dotCritCount
	u.total.healingDone = u.total.healingDone + hitValue
	u.total.healingCount = u.total.healingCount +  hitCount + dotCount
	u.total.critHealingCount = u.total.critHealingCount + critCount + dotCritCount

	AddAbilityValue( u.total.healPerAbility, abilityName, hitValue, hitCount, critCount, dotCount, dotCritCount )
	AddAbilityValue( u.session.healPerAbility, abilityName, hitValue, hitCount, critCount, dotCount, dotCritCount )

	if sourceUnitId ~= targetUnitId then -- this prevents the double heal log when you heal yourself or a pet does
		if hitValue >= Recount.settings.minHPSLogValue then
			local eventString = zo_strformat( "|c449944 <<1>><<2>><<3>>|r -> |c447744 <<4>>|r - <<5>>", getTag(dotCount > 0, Recount.settings.dotTag), hitValue, getTag((critCount > 0) or (dotCritCount > 0), Recount.settings.critTag), targetName, abilityName )
			Recount.CombatLogMsg( eventString )
		end
	end
end

--[[==========================================
	UnitHealingTaken
	==========================================]]--
local function UnitHealingTaken( unitID, abilityName, sourceName, targetName, hitValue, result, hitCount, critCount, dotCount, dotCritCount )
	if hitValue <= Recount.settings.healIgnore then return end

	local u = Recount.trackedUnits[unitID]

	u.session.healingTaken = u.session.healingTaken + hitValue
	u.session.healingCount = u.session.healingCount + hitCount + dotCount
	u.session.critHealingCount = u.session.critHealingCount + critCount + dotCritCount
	u.total.healingTaken = u.total.healingTaken + hitValue
	u.total.healingCount = u.total.healingCount +  hitCount + dotCount
	u.total.critHealingCount = u.total.critHealingCount + critCount + dotCritCount

	AddAbilityValue( u.total.healPerAbility, abilityName, hitValue, hitCount, critCount, dotCount, dotCritCount )
	AddAbilityValue( u.session.healPerAbility, abilityName, hitValue, hitCount, critCount, dotCount, dotCritCount )

	if hitValue >= Recount.settings.minHPSLogValue then
		local eventString = zo_strformat( "|c449944 <<1>><<2>><<3>>|r <- |c447744 <<4>>|r - <<5>>", getTag(dotCount > 0, Recount.settings.dotTag), hitValue, getTag((critCount > 0 ) or (dotCritCount > 0), Recount.settings.critTag), sourceName, abilityName )
		Recount.CombatLogMsg( eventString )
	end
end

--[[==========================================
	CombatEvent

	Message handler
	==========================================]]--
function Recount.CombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	if ( Recount.settings.suspendDataCollectionWhileHidden and Recount.settings.wndMain.isVisible == false ) then
		return
	end

	Recount.time = GetGameTimeMilliseconds()

	if ( Recount.isDebugMode ) then
		debugString = sourceName .." [".. Recount.DebugStringifyUnitType( sourceType ) .."] <==> ".. targetName.. " [".. Recount.DebugStringifyUnitType( targetType ) .."] == (".. abilityName .."; ".. hitValue ..")<== ".. "; ".. abilityActionSlotType .."; ".. powerType .."; ".. damageType .. "; ".. result
		RecountUIDebug_lblCombatLog:AddMessage( debugString )
	end

	local  eventType, hitCount, critCount, dotCount, dotCritCount = Recount.CheckIgnoreCombatEvent( result, isError, hitValue, powerType, damageType )
	if ( eventType == EVENT_TYPE_IGNORE ) then
		return
	end

	local playerInCombat = (sourceType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER)
	if (Recount.inCombat == false) and (playerInCombat == true) and	(eventType == EVENT_TYPE_DAMAGE) and (sourceType ~= targetType) then
		Recount.playerEnterCombat()
	end

	if Recount.inCombat == true then
		if ( sourceType ~= COMBAT_UNIT_TYPE_PLAYER and targetType ~= COMBAT_UNIT_TYPE_PLAYER and
			 sourceType ~= COMBAT_UNIT_TYPE_PLAYER_PET and targetType ~= COMBAT_UNIT_TYPE_PLAYER_PET and
			 sourceType ~= COMBAT_UNIT_TYPE_GROUP and targetType ~= COMBAT_UNIT_TYPE_GROUP ) then
			return
		end
		
		playerUnit.total.timeSpan = Recount.time - playerUnit.total.timeStart
		playerUnit.session.timeSpan = Recount.time - playerUnit.session.timeStart
		
		if ( targetType == COMBAT_UNIT_TYPE_PLAYER ) then
			if ( eventType == EVENT_TYPE_DAMAGE ) then
				UnitDamageTaken( 1, abilityName, sourceName, targetName, hitValue, result, hitCount, critCount, dotCount, dotCritCount )
			elseif ( eventType == EVENT_TYPE_HEAL ) then
				UnitHealingTaken( 1, abilityName, sourceName, targetName, hitValue, result, hitCount, critCount, dotCount, dotCritCount )
			end
		end
		
		if ( sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET ) then
			if ( eventType == EVENT_TYPE_HEAL ) then
				UnitHealingDone( 1, abilityName, sourceName, targetName, hitValue, result, hitCount, critCount, dotCount, dotCritCount )
			elseif ( eventType == EVENT_TYPE_DAMAGE ) then
				UnitDamageDone( 1, abilityName, sourceName, targetName, hitValue, result, hitCount, critCount, dotCount, dotCritCount )
			end
		end
	end

	Recount.UpdateUI(Recount.refreshThreshold)
end

function Recount.StartNewSession()
	if ( playerUnit.sessionCurrent > Recount.settings.numStoredSessions ) then
		playerUnit.sessionCurrent = 1
	end

	playerUnit.session = {}

	playerUnit.sessionList[ playerUnit.sessionCurrent ] = {
		damageDone = 0,
		damageTaken = 0,
		healingDone = 0,
		healingTaken = 0,
		
		healingCount = 0,
		critHealingCount = 0,
		damageCount = 0,
		critDamageCount = 0,
		
		dps = 0,
		hps = 0,
		
		timeStart = Recount.time,
		timeSpan = 1,
		
		damagePerAbility = {},
		healPerAbility = {},
	}

	playerUnit.session = playerUnit.sessionList[ playerUnit.sessionCurrent ]
	playerUnit.session.timeSpan = 0

	Recount.ClearProgressBars()

end

function Recount.Reset()

	playerUnit.total.timeSpan = 0
	playerUnit.total.timeStart = 0
	playerUnit.total.damageDone = 0
	playerUnit.total.damageTaken = 0
	playerUnit.total.healingTaken = 0
	playerUnit.total.healingDone = 0
	playerUnit.total.damagePerAbility = {}
	playerUnit.total.healPerAbility = {}

	playerUnit.total.healingCount = 0
	playerUnit.total.critHealingCount = 0
	playerUnit.total.damageCount = 0
	playerUnit.total.critDamageCount = 0

	playerUnit.sessionList = {}
	playerUnit.sessionCurrent = 1
	playerUnit.sessionNum = 0

	Recount.time = 0

	Recount.StartNewSession()
	Recount.doUpdateUI()

	Recount.CombatLogMsg( "==== RESET ====" )

end

function Recount.ClearProgressBars()
	for i = 1, UI_STATUSBAR_MAX do
		local statusBar = GetControl(RecountUI, "Statusbar"..i)
		statusBar:SetValue( 0 )
		GetControl(statusBar, "_lblLeft"):SetText( "" )
	end

end


function Recount.FillProgressBars( abilityTable, totalValue )
	if ( abilityTable == nil or totalValue == nil ) then
		return
	end

	local i = 1
	local dMax = 0
	Recount.maxComputedBars = 1

	local keys = {}
	for k,v in pairs(abilityTable) do
		table.insert(keys,{key=k,data=v})
	end

	table.sort(keys,function(a,b) return a.data.hitValue > b.data.hitValue end)

	for i,skill in ipairs(keys) do
		if dMax == 0 then
			dMax = skill.data.hitValue
		end
		
		local abilityName = zo_strformat("<<1>>", skill.key)
		local dmgAbs = skill.data.hitValue
		
		local fbString = ""
		if Recount.settings.showSkillDetails == true then
			if skill.data.hitCount > 0 then
				fbString = zo_strformat("<<1>> |cFF7777 #hits: <<2>>|r |cFF5555 crit: <<3>>%|r", fbString, skill.data.hitCount, secureDivide(skill.data.critCount, skill.data.hitCount) * 100)
			end
			if  skill.data.dotCount > 0 then
				fbString = zo_strformat("<<1>> |cFF7777 #ticks: <<2>>|r |cFF5555 crit: <<3>>%|r", fbString, skill.data.dotCount, secureDivide(skill.data.dotCritCount, skill.data.dotCount) * 100)
			end
		end
		
		local barSize = secureDivide(dmgAbs , dMax) * 100 
		local dmgRel = secureDivide(dmgAbs, totalValue) * 100
		
		if ( i <= UI_STATUSBAR_MAX ) then
			local statusBar = GetControl(RecountUI, "Statusbar"..i)
			statusBar:SetValue( barSize )
			GetControl(statusBar, "_lblLeft"):SetText( ("|caaaaff %02d|r %s |ceeeeee %s|r |c999999 (%d %%) %s"):format(i, abilityName, Recount.FormatNumber( dmgAbs ), dmgRel, fbString ) )
			statusBar:SetColor( 0.8 - i*0.05, 0.8 - i*0.05, 0.3, 0.8 )
			Recount.maxComputedBars = Recount.maxComputedBars + 1
		end
		
		i = i + 1
	end
	keys = {}
	Recount.FitStatusBars()

end

function Recount.FillSingleProgressBar( name, value )
	RecountUIStatusbar1:SetValue( value )
	RecountUIStatusbar1_lblLeft:SetText( zo_strformat("<<1>>: |cEEEEEE <<2>>|r", name, value) )
end

function Recount.UpdateModeUI()

	if ( Recount.settings.currentMode == RC_MODE_DAMAGE_DONE_TOTAL ) then
		Recount.FillProgressBars( playerUnit.total.damagePerAbility, playerUnit.total.damageDone )
	elseif ( Recount.settings.currentMode == RC_MODE_DAMAGE_DONE) then
		if ( playerUnit.session ~= nil ) then
			Recount.FillProgressBars( playerUnit.session.damagePerAbility, playerUnit.session.damageDone )
		end
	elseif ( Recount.settings.currentMode == RC_MODE_DAMAGE_TAKEN) then
		if ( playerUnit.session ~= nil ) and playerUnit.session.damageTaken > 0 then
			Recount.FillSingleProgressBar( "Damage Taken", playerUnit.session.damageTaken )
		end
	elseif ( Recount.settings.currentMode == RC_MODE_DAMAGE_TAKEN_TOTAL) then
		if playerUnit.total.damageTaken > 0 then
			Recount.FillSingleProgressBar( "Damage Taken", playerUnit.total.damageTaken )
		end
	elseif ( Recount.settings.currentMode == RC_MODE_HEALING_DONE) then
		if ( playerUnit.session ~= nil ) then
			Recount.FillProgressBars( playerUnit.session.healPerAbility, playerUnit.session.healingDone )
		end
	elseif ( Recount.settings.currentMode == RC_MODE_HEALING_DONE_TOTAL) then
		Recount.FillProgressBars( playerUnit.total.healPerAbility, playerUnit.total.healingDone )
	elseif ( Recount.settings.currentMode == RC_MODE_HEALING_TAKEN) then
		if ( playerUnit.session ~= nil ) and playerUnit.session.healingTaken > 0 then
			Recount.FillSingleProgressBar( "Healing Taken", playerUnit.session.healingTaken )
		end
	elseif ( Recount.settings.currentMode == RC_MODE_HEALING_TAKEN_TOTAL) then
		if playerUnit.total.healingTaken > 0 then
			Recount.FillSingleProgressBar( "Healing Taken", playerUnit.total.healingTaken )
		end
	end

end

function Recount.SetMode( mode, doUpdate )
	if (mode == -1) then
		mode =  RC_MODE_COMBAT_LOG
	end

	if ( mode == RC_MODE_EOL ) then
		mode = RC_MODE_DAMAGE_DONE
	end
	Recount.settings.currentMode = mode
	Recount.ClearProgressBars()

	RecountUI_Title_Text:SetText( Recount.name .. " - " .. modeStrings[mode] )

	RecountUI_Title:SetHidden( false )
	RecountUI_lblCombatLogBG:SetHidden( false )

	if ( mode == RC_MODE_COMBAT_LOG ) then
		for i = 1, UI_STATUSBAR_MAX do
			local statusBar = GetControl(RecountUI, "Statusbar"..i)
			statusBar:SetHidden( true )
		end
		RecountUI_lblCombatLog:SetHidden( false )
		return
	end

	if ( mode == RC_MODE_MINIMIZED ) then
		for i = 1, UI_STATUSBAR_MAX do
			local statusBar = GetControl(RecountUI, "Statusbar"..i)
			statusBar:SetHidden( true )
		end
		RecountUI_lblCombatLog:SetHidden( true )
		RecountUI_Title:SetHidden( true )
		RecountUI_lblCombatLogBG:SetHidden( true )
		return
	end

	Recount.totalMode = (mode == RC_MODE_DAMAGE_DONE_TOTAL) or (mode == RC_MODE_DAMAGE_TAKEN_TOTAL) or (mode == RC_MODE_HEALING_DONE_TOTAL) or (mode == RC_MODE_HEALING_TAKEN_TOTAL)

	for i = 1, UI_STATUSBAR_MAX do
		local statusBar = GetControl(RecountUI, "Statusbar"..i)
		statusBar:SetHidden( false )
	end
	RecountUI_lblCombatLog:SetHidden( true )
	if doUpdate then
		Recount.UpdateUI(0)
	end

end

function Recount.TestProgressBars()
	Recount.SetMode( RC_MODE_DAMAGE_DONE, true )
	local test = {}
	for i = 1, 25 do
		test["Ability"..i] = {hitValue = math.random(500000), hitCount = math.random(50), critCount = math.random(50), dotCount = math.random(5), dotCritCount = math.random(5)}
	end
	Recount.FillProgressBars( test, 1460000 )
end

function Recount.ToggleNextMode(value)
	if not RecountUI:IsHidden() then
		Recount.SetMode( Recount.settings.currentMode + value, true )
	end
end

function Recount.OnClickedTitleButton( self, button )
	Recount.ToggleNextMode(1)
end

function Recount.OnClickedTitleButtonReset( self, button )
	Recount.Reset()
end

function Recount.OnClickedTitleButtonHide( self, button )
	Recount.Hide()
end

function Recount.autoToggle(oldState, newState)
	if (newState == SCENE_FRAGMENT_SHOWN) then
		Recount.UIinMenu = false
		if (Recount.settings.wndMain.isVisible == true) then
			RecountUI:SetHidden( false )
		end
	elseif (newState == SCENE_FRAGMENT_HIDING) then
		Recount.UIinMenu = true
		RecountUI:SetHidden( true )
	end
end

function Recount.Show()
	RecountUI:SetHidden( false )
	Recount.settings.wndMain.isVisible = true
end

function Recount.Hide()
	EVENT_MANAGER:UnregisterForUpdate("hideOOC")
	RecountUI:SetHidden( true )
	Recount.settings.wndMain.isVisible = false
end

function Recount.toggleShow()
	if Recount.UIinMenu == false then
		if Recount.settings.wndMain.isVisible == true then
			Recount.Hide()
		else
			Recount.Show()
		end
	end
end

function Recount.SlashCommands( text )

	if ( text == "" ) then
		d( "Recount " .. Recount.versionString )
		d( "Command line options: hide; show; min; restore; mode; reset" )
		return
	end

	if ( text == "hide" ) then
		Recount.Hide()
		return
	end

	if ( text == "show" ) then
		Recount.Show()
		return
	end

	if ( text == "min" ) then
		Recount.MinimizeWindow()
		return
	end

	if ( text == "restore" ) then
		Recount.RestoreWindow(true)
		return
	end

	if ( text == "mode" ) then
		Recount.ToggleNextMode()
		return
	end

	if ( text == "reset" ) then
		Recount.Reset()
		return
	end

	if ( text == "debug" ) then
		if ( Recount.isDebugMode ) then
			RecountUIDebug:SetHidden( true )
			Recount.isDebugMode = false
		else
			RecountUIDebug:SetHidden( false )
			Recount.isDebugMode = true
		end
		return
	end

	if ( text == "test" ) then
		Recount.TestProgressBars()
		return
	end
end

ZO_CreateStringId("SI_BINDING_NAME_RECOUNT_SHOW", "Toggle UI on/off")
ZO_CreateStringId("SI_BINDING_NAME_RECOUNT_RESET", "Reset Stats")
ZO_CreateStringId("SI_BINDING_NAME_RECOUNT_TOGGLEMODE", "Toggle Mode (Forward)")
ZO_CreateStringId("SI_BINDING_NAME_RECOUNT_TOGGLEMODE2", "Toggle Mode (Backward")
