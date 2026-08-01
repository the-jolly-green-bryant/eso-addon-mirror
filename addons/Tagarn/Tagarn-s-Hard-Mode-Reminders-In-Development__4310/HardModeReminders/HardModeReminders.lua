-- Copyright (c) 2025 by Tagarn

-- This add-on may be copied, shared, and used as-is while playing Elder
-- Scrolls Online, provided this notice is left intact. However, this
-- add-on, in part or in full, may not be used in the creation of other
-- add-ons without the express written consent of Tagarn.

-- The Elder Scrolls Online add-on provided by Tagarn ("we," "us," or "our")
-- is for entertainment purposes only. UNDER NO CIRCUMSTANCE SHALL WE HAVE ANY
-- LIABILITY TO YOU FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF
-- THE USE OF OUR ADD-ON. YOUR USE OF OUR ADD-ON IS SOLELY AT YOUR OWN RISK.


HardModeReminders = HardModeReminders or {}
local HMR = HardModeReminders
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local HMRBs = HardModeRemindersBosses
local HMRU = HardModeRemindersUtilities
local libNotification = LibNotification

HMR.name = "HardModeReminders"
HMR.simpleName = GetString(HMR_APP_NAME)
HMR.displayName = GetString(HMR_APP_NAME_LONG)
HMR.author = GetString(HMR_TAGARN_GREEN)
HMR.version = "0.51"
HMR.versionNumeric = 051-- for checking whether to show the "new feature" dialog or not
HMR.buildNumber = 1 -- for when the testing version box is showing
HMR.isBeta = false -- signify if this is a beta test version

HMR.debugActive = false -- a flag that debug code is active
HMR.debugVerbose = false -- whether to dump extra data to the chat
HMR.debugActiveInNormalContent = false -- Testing: whether to behave as if in a veteran instance when in a normal instance
HMR.debugIgnoreBossHealth = false -- Testing: whether to ignore boss health for HM check
HMR.debugActiveWithoutGroup = false -- Testing: whether the add-on is active when not in a group

-- HMR.mainPositionDefault = {["x"]=5, ["y"]=240} -- The default main UI position
HMR.mainUiPositionVerticalDefault = 5 -- The default vertical position of the main UI (horizontal is centered)
HMR.warningPositionVerticalDefault = 220 -- The default vertical position of the warning (horizontal is centered)

HMR.unitName = nil -- the current unit name, for testing purposes
HMR.unitTags = {} -- a list of player unit tags for fast use later (no string concatenation later)
HMR.bossUnitTags = {} -- a list of boss unit tags for fast use later (no string concatenation later)

HMR.warningShouldBeHidden = false -- whether the warning should currently be hidden
HMR.isUiShown = false -- whether we're current showing the main ui
HMR.warningIsShown = false -- whether we're current showing the warning
HMR.stoppingWarningAnimation = false -- Flag if the stop warning animation timer is running

HMR.isUiUnlocked = false -- whether the UI is currently unlocked or not
HMR.isUiShowingFromSettings = false -- whether the UI is visible due to the settings button
HMR.isUiInTestMode = false -- whether the UI is showing for testing purposes, which can cause some differences in behavior (like ignoring combat for the warning)

local maxinteger = 2147483647
local TEXT_COLOR_ORANGE = "|cFFA500"
local TEXT_COLOR_RED = "|cFF0000"
local TEXT_COLOR_GREEN = "|c00FF00"
local TEXT_COLOR_YELLOW = "|cFFFF00"
local TEXT_COLOR_WHITE = "|cFFFFFF"
local TEXT_COLOR_END = "|r"

HMR.savedVariables = {} -- long form of the saved variables
local SV = {} -- set to the saved variables are opened in Initialize()
local saveDefaults = {
	mainPosition = {},  -- position of the main UI, saved by the screen resolution
	warningPosition = {}, -- position of the warning UI, saved by the screen resolution
	versionNumeric = 0, -- the add-on version of the saved data
	lastNotificationViewed = 0, -- the last add-on version the user viewed notifications for
	currentData = {
		zoneId = 0, -- the current zoneId
		zoneHasHmContent = false, -- if the current zone has HM content
		zoneIsReset = false, -- flags if the HM content zone has been reset
		notCurrentlyInZone = false, -- if we're saving the current HM zone data while the player is in a non-HM zone
		isInVeteranMode = false, -- whether the zone is in veteran mode
		bosses = {}, -- the boss data for the current zone, if it has HM content
		bossNameIndex = {}, -- index for looking current zone boss data up by name 
		lastTimeSeen = 0, -- the last time the user was in the instance with HM content, for reset purposes
		uiHidden = false, -- whether the UI is currently hidden by the user
		uiDisabled = false, -- whether this zone is flagged as disabled for showing the add-on
	}, -- Storing data about the current zone, in case of reloadUI, etc
	options = {
		uiIsLocked = false, -- whether the UI position is locked or not
		largeWarning = true, -- whether to show the large warning message
		largeWarningFlashing = true, -- whether to flash the large warning message
		largeWarningCombatTimer = 5000, -- how long to continue showing the large warning once combat starts
		uiShown = true, -- whether the status UI should be shown at all
		uiAlwaysVisible = false, -- if the status UI should always be visible
		uiVisibleHmOnly = true, -- if "always visible" is set, should the status UI only be visible in zones with HM content
		uiTextPulses = 3, -- how many times the UI text should pulse
		uiTextPulseTime = 500, -- how many ms each half of a pulse should take
		uiTextColored = true, -- whether the UI text should have status colors, or simply be white
		uiTextPulseVeteranModeOnly = true, -- whether the UI text should pulse only if in veteran mode
		uiShowCloseButton = true, -- whether to show the close button on the main UI
		zonesDisabled = {}, -- list of zoneIds the add-on is disabled for
	}
}
local s = {} -- a shortcut to SV.currentData
HMR.c = s

-- the scenes. Saved this way to keep the IDE happy
---@class ZO_Scene
local hudScene
---@class ZO_Scene
local huduiScene
local mainPanelFragment
local warningPanelFragment

---@type AnimationObject|nil
local warningAnimation
local warningTimeline
local uiTextTimeline

local hmBossJustEnteredCombat = false  -- For flagging animation stop, when we are in combat near a HM boss but the boss wasn't initially involved (Wayrest I)
local newlyInitialized = true -- Flag if Initialize has just run
local deactivationZoneId = -1 -- For testing if we're activating in a new zone, since "initial" is not reliable


local uiModes = {
	["hidden"] = 1,
	["normalMode"] = 2,
	["veteranMode"] = 3,
	["hardMode"] = 4,
	["hardModeNotAvailable"] = 5,
	["cannotTrackHardMode"] = 6,
}

local uiWidgets = {
	["main"] = 1,
	["warning"] = 2,
}

local isStopped = false -- if the add-on functionality should be halted
local bosses = nil -- the Bosses object
local bossZoneIdIndex = {} -- an index for quickly looking up zone bosses
local isInCombat = false -- is the player in combat?
local groupWipeReset = false -- flag if the group wiped, and we're resetting, to prevent flashing UI during reset
local checkCombatStateAfterReincarnation = false -- flag that the player was in ghost form, out of combat, while the group was still in combat. Will be watching for EVENT_PLAYER_REINCARNATED
local currentHmBoss = nil -- the current HM boss, if present
local nextHmBoss = nil -- the next HM boss, if there is one
local uTest = HMR.unitName -- for testing purposes, possibly redundant
local previousHmBoss = nil -- a reference to the previous HM boss --REMOVE
local uiMainMode = uiModes.hidden -- what the UI is showing --REMOVE
---@diagnostic disable-next-line: undefined-field --REMOVE
local OriginalCenterAnnouncement = CENTER_SCREEN_ANNOUNCE.AddMessageWithParams -- pointer to the original center announcement function
local OriginalZOAlert = ZO_Alert
local isPlayerGrouped = false -- flags if the player is grouped
local previousText = "" -- used to detect if the UI text has changed, for animation
local notificationProvider = nil -- the notification provider


-- LATER: Zone Reset experiment
-- local currentZoneId = 0 -- used by the zone reset experiment
-- local lastHmZone = 0 -- used for zone reset notification and porting back in
-- local zoneIsReset = false -- flagging if the zone is reset, for that experiment

-- For the collected ranges
local storedCoordinates = {
	zoneId = 0,
	count = 0,
	minX = maxinteger,
	minY = maxinteger,
	minZ = maxinteger,
	maxX = - maxinteger,
	maxY = - maxinteger,
	maxZ = - maxinteger,
}

local scriptRunner = nil


-- Testing
-- Used to selectively output some messages
local function td(...)
	if (HMR.debugActive == true) and (HMR.debugVerbose == true) then
		d(...)  --leave
	end
end

local function tdf(...)
	if (HMR.debugActive == true) and (HMR.debugVerbose == true) then
		df(...)  --leave
	end
end


local hmr = GetString(HMR_ABBREV_GREEN)

local savedColorR
local savedColorG
local savedColorB
function HMR.StartWarningAnimation()
	td("**StartWarningAnimation()")
	if (warningTimeline ~= nil) then
		return
	end

	savedColorR, savedColorG, savedColorB = HMRWARNINGUI_Status:GetColor()

	--- @class AnimationObjectColor: AnimationObject
	warningAnimation, warningTimeline = CreateSimpleAnimation(ANIMATION_COLOR, HMRWARNINGUI_Status)
	assert(warningAnimation)
	assert(warningTimeline)

	warningAnimation:SetStartColor(savedColorR, savedColorG, savedColorB, 255)
	warningAnimation:SetEndColor(255,0,0,255)
	warningAnimation:SetDuration(200)

	warningTimeline:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, LOOP_INDEFINITELY)
    warningTimeline:PlayFromStart()
end

function HMR.StopUiAnimation()
	td("**StopUiAnimation()")
	if (warningTimeline ~= nil) then
		warningTimeline:Stop()
		warningAnimation = nil
		warningTimeline = nil

		HMRWARNINGUI_Status:SetColor(savedColorR, savedColorG, savedColorB)
	end
end

function HMR.ShowWarning()
	if (HMR.warningShouldBeHidden == true) or (isStopped == true) then
		HMR.HideWarning()
		return
	end

	if (HMR.warningIsShown == true) then
		return
	end

	HMR.warningIsShown = true
	if (SV.options.largeWarning == true) then
		if (hudScene:HasFragment(warningPanelFragment) ~= true) then
			hudScene:AddFragment(warningPanelFragment)
		end
		if (huduiScene:HasFragment(warningPanelFragment) ~= true) then
			huduiScene:AddFragment(warningPanelFragment)
		end

		if (SV.options.largeWarningFlashing == true) and (warningAnimation == nil) then
			HMR.StartWarningAnimation()
		end
	end
end

function HMR.HideWarning()
	if (HMR.warningIsShown == false) then
		return
	end

	HMR.warningIsShown = false

	if (warningAnimation ~= nil) then
		HMR.StopUiAnimation()
	end

	if (hudScene:HasFragment(warningPanelFragment) == true) then
		hudScene:RemoveFragment(warningPanelFragment)
	end
	if (huduiScene:HasFragment(warningPanelFragment) == true) then
		huduiScene:RemoveFragment(warningPanelFragment)
	end
end


function HMR.HideWarningDelayed()
	SV.options.largeWarningCombatTimer = 2500
	HMR.stoppingWarningAnimation = true
	zo_callLater(function(self)
		HMR.HideWarning()
		HMR.warningShouldBeHidden = true
		HMR.stoppingWarningAnimation = false
	end, 5000)
end

function HMR.SettingsShowUi(value)
	if (value == true) then
		HMR.isUiShowingFromSettings = true
		HMR.ShowUi()
		HMR.ShowWarning()
		--TODO Add fragments to settings menu scene
	else
		HMR.isUiShowingFromSettings = false
		HMR.HideUi()
		HMR.HideWarning()
		--TODO Remove fragments to settings menu scene
	end

	-- df("HMR.isUiShowingFromSettings: %s", tostring(HMR.isUiShowingFromSettings))
end

function HMR.ShowUi()
	if (HMR.isUiShown == true) or (isStopped == true) then
		return
	end

	td("**ShowUi()")

	HMR.isUiShown = true

	if (hudScene:HasFragment(mainPanelFragment) ~= true) then
		hudScene:AddFragment(mainPanelFragment)
	end
	if (huduiScene:HasFragment(mainPanelFragment) ~= true) then
		huduiScene:AddFragment(mainPanelFragment)
	end
end

function HMR.HideUi()
	if (HMR.isUiShown == false) then
		return
	end

	td("**HideUi()")

	HMR.isUiShown = false

	if (hudScene:HasFragment(mainPanelFragment) == true) then
		hudScene:RemoveFragment(mainPanelFragment)
	end
	if (huduiScene:HasFragment(mainPanelFragment) == true) then
		huduiScene:RemoveFragment(mainPanelFragment)
	end
end

function HMR.AnimateText(veteranMode, pulse, r, g, b)
	td("**AnimateText()")

	if (uiTextTimeline ~= nil) then
		uiTextTimeline:Stop()
	end

	if (SV.options.uiTextColored == false) then
		r = 255
		g = 255
		b = 255
	end

	if (SV.options.uiTextPulseVeteranModeOnly == true) and (veteranMode ~= true) then
		HMRUI_Status:SetColor(r, g, b)
		return
	end

	if (SV.options.uiTextPulses == 0) or (pulse == false) then
		HMRUI_Status:SetColor(r, g, b)
		return
	end

	uiTextTimeline = ANIMATION_MANAGER:CreateTimeline()
	assert(uiTextTimeline)

	local offset = 0
	local offsetAmount = SV.options.uiTextPulseTime
	for i = 1, SV.options.uiTextPulses do
		--- @class AnimationObjectColor: AnimationObject
		local rampUp = uiTextTimeline:InsertAnimation(ANIMATION_COLOR, HMRUI_Status, offset)
		rampUp:SetStartColor(r, g, b, 255)
		rampUp:SetEndColor(0, 0, 0, 255)
		rampUp:SetDuration(offsetAmount)
		offset = offset + offsetAmount

		--- @class AnimationObjectColor: AnimationObject
		local rampDown = uiTextTimeline:InsertAnimation(ANIMATION_COLOR, HMRUI_Status, offset)
		rampDown:SetStartColor(0, 0, 0, 255)
		rampDown:SetEndColor(r, g, b, 255)
		rampDown:SetDuration(offsetAmount)
		offset = offset + offsetAmount
	end

	uiTextTimeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 1)
    uiTextTimeline:PlayFromStart()

end

function HMR.LockUi(value)
	if (value == nil) then
		value = SV.options.uiIsLocked
	else
		SV.options.uiIsLocked = value
	end

	HMRUI:SetMovable(value)
	HMRWARNINGUI:SetMovable(value)

	if (HMR.isUiShowingFromSettings == true) then
		HMR.SettingsShowUi(false)
	end
end


function HMR.UpdateUi()
	td("** UpdateUi")
	if (currentHmBoss == nil) and (nextHmBoss == nil) then
		HMR.HideWarning()
		HMR.HideUi()
		return
	end

	if (s.uiHidden == true) or (s.uiDisabled == true) or (HMR.isUiInTestMode == true) then
		HMR.HideWarning()
		HMR.HideUi()
		return
	end

	local boss = nil
	if (currentHmBoss) then
		boss = currentHmBoss
	elseif (nextHmBoss) then
		boss = nextHmBoss
	end

	assert(boss) -- should never fail, but is needed to make the IDE happy

	-- Temp fix for Stone Garden / Arkasis and Frostvault / Stonekeeper
	if (boss:DisplayUiForBoss() == false) then
		HMR.HideWarning()
		HMR.HideUi()
		return
	end

	if (boss:InArena() == true) then
		td("%%%%%% In Arena")  --DEBUG
		local text = ""
		local r,g,b
		local veteranMode = false
		local pulse = true
		if (groupWipeReset == true) then
			text = GetString(HMR_UI_WIPE_RESET)
			r = 255 --LATER: clean this up with color objects
			g = 255
			b = 255
			pulse = false
		elseif (boss:IsHmAvailable() == false) then
			text = GetString(HMR_UI_HARD_MODE_UNAVAILABLE)
			r = 255
			g = 0
			b = 0
		elseif (boss:IsHm() == true) then
			text = GetString(HMR_UI_HARD_MODE)
			r = 0
			g = 255
			b = 0
		else
			text = GetString(HMR_UI_VETERAN_MODE)
			r = 255
			g = 0
			b = 0
			veteranMode = true
		end

		if (previousText ~= text) then
			HMRUI_Status:SetText(text)
			HMR.AnimateText(veteranMode, pulse, r, g, b)
			previousText = text
		end

		if (groupWipeReset == true) then
			HMR.HideWarning()
			HMR.ShowUi()
		elseif (boss:IsHmAvailable() == false) then
			HMR.HideWarning()
			HMR.ShowUi()
		elseif	(boss:IsHm() == true) then
			HMR.HideWarning()
			HMR.ShowUi()
		elseif (boss:IsDead() == true) then
			HMR.HideWarning()
			HMR.HideUi()
		else
			HMR.ShowWarning()
			HMR.ShowUi()
		end
	else
		td("%%%%%% Not in Arena")  --DEBUG
		HMR.HideWarning()
		HMR.HideUi()
	end
end

function HMR.OnBossesChanged(eventId, forceReset)
	if (bosses) then
		bosses:OnBossesChanged(eventId, forceReset)
	else
		td("**** no bosses")
	end
end

function HMR.OnPowerUpdate(eventId, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if (bosses) then
		bosses:OnPowerUpdate(eventId, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	else
		td("**** no bosses")
	end
end

function HMR.OnCurrentSubzoneListChanged()
	if (bosses) then
		bosses:OnBossesChanged(0, false)
	end
end

function HMR.DumpBosses()
	if (bosses) then
		bosses:DumpBosses()
	end
end

function HMR.OnZoneChanged( eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId )
	td("**OnZoneChanged")
end


local function ResetStoredCoordinates()
	storedCoordinates.zoneId = 0
	storedCoordinates.minX = maxinteger
	storedCoordinates.minY = maxinteger
	storedCoordinates.minZ = maxinteger
	storedCoordinates.maxX = - maxinteger
	storedCoordinates.maxY = - maxinteger
	storedCoordinates.maxZ = - maxinteger
end

local previousBoss = nil
--@param boss HardModeRemindersBoss
function HMR.UpdateForCurrentBoss(boss, nextBoss)
	td("**UpdateForCurrentBoss")

	if (isInCombat == true) and (boss == nil) and (currentHmBoss ~= nil) then
		return
	end

	if (boss ~= nil) and (boss ~= previousBoss) then
		previousBoss = boss
		ResetStoredCoordinates()
	end

	if (boss) then
		tdf("**UpdateForCurrentBoss. Boss: %s", boss:GetName())
	elseif (nextBoss) then
		tdf("**UpdateForCurrentBoss. nextBoss: %s", nextBoss:GetName())
	else
		td("******* Both are null in UpdateForCurrentBoss()")
	end

	currentHmBoss = boss
	nextHmBoss = nextBoss

	HMR.UpdateUi()
end


local function ResetAfterWipe()
	td("**ResetAfterWipe()")
	groupWipeReset = false
	if (bosses == nil) then
		return
	end

	bosses:CombatEndedInWipe()

	HMR.UpdateUi()
end

function HMR.DidGroupWipe()
	td("**DidGroupWipe()")
	local wiped = true

	if (IsUnitGrouped("player") == false) then
		wiped = IsUnitDead("player")
	else
		for i = 1, GROUP_SIZE_MAX do
			if (DoesUnitExist(HMR.unitTags[i]) == true) then
				local memberZoneId = GetUnitWorldPosition(HMR.unitTags[i]) -- To keep the UI happy

				if (IsUnitDead(HMR.unitTags[i]) == false) and (IsUnitBeingResurrected(HMR.unitTags[i]) == false) and (IsUnitOnline(HMR.unitTags[i]) == true) and (memberZoneId == s.zoneId) then
					wiped = false
				end
			end
		end

	end

	return wiped
end

function HMR.IsGroupInCombat()
	td("**IsGroupInCombat()")
	local inCombat = false

	if (IsUnitGrouped("player") == false) then
		inCombat = IsUnitInCombat("player")
	else
		for i = 1, GROUP_SIZE_MAX do
			if (DoesUnitExist(HMR.unitTags[i]) == true) then
				local memberZoneId = GetUnitWorldPosition(HMR.unitTags[i]) -- To keep the UI happy

				if (IsUnitInCombat(HMR.unitTags[i])) and (IsUnitOnline(HMR.unitTags[i]) == true) and (memberZoneId == s.zoneId) then
					inCombat = true
				end
			end
		end

	end

	return inCombat
end

function HMR.OnPlayerReincarnatedWipe(eventCode)
	EM:UnregisterForEvent(HMR.name .. "OnPlayerReincarnatedWipe", EVENT_PLAYER_REINCARNATED)

	-- Redo the reset, in case the boss was not yet reset. "This shouldn't happen"™
	if (currentHmBoss == nil) then
		td("-------------------- reincarnation reset after wipe") -- DEBUG 
		ResetAfterWipe()
	end
end

function HMR.OnPlayerReincarnatedGhost(eventCode)
	EM:UnregisterForEvent(HMR.name .. "OnPlayerReincarnatedGhost", EVENT_PLAYER_REINCARNATED)

	if (checkCombatStateAfterReincarnation == true) then
		td("-------------------- reincarnation check combat state") -- DEBUG
		checkCombatStateAfterReincarnation = false
		if (IsUnitInCombat("player") == false) then
			assert(bosses)
			bosses:CombatEnded()
		end
	end
end


function HMR.CombatEndedCheck()
	local didGroupWipe = HMR.DidGroupWipe()

	-- Combat might not actually be over. The player is briefly out of combat while in ghost form
	if (IsUnitDead("player") == false) and (IsUnitReincarnating("player") == true) then
		if (didGroupWipe == false) then
			if (HMR.IsGroupInCombat() == true) then
				td("Player combat ended due to player reincarnating") -- DEBUG
				checkCombatStateAfterReincarnation = true
				EM:RegisterForEvent(HMR.name .. "OnPlayerReincarnatedGhost", EVENT_PLAYER_REINCARNATED, HMR.OnPlayerReincarnatedGhost)
				return
			end
		end
	end

	if (didGroupWipe == true) then
		groupWipeReset = true
		td(">>>> GROUP WIPE") -- DEBUG
		HMR.UpdateUi()
		-- Give time for the boss to reset. Could also wait until the player is out of ghost
		zo_callLater(function(self)
			ResetAfterWipe()
			end, 10000)

		-- Check again when the player is out of ghost
		EM:RegisterForEvent(HMR.name .. "OnPlayerReincarnatedWipe", EVENT_PLAYER_REINCARNATED, HMR.OnPlayerReincarnatedWipe)

		return
	else
		td(">>>> GROUP DID NOT WIPE") -- DEBUG
		assert(bosses)
		bosses:CombatEnded()
	end
end

function HMR.OnPlayerCombatState( eventCode, newCombatState)
	td("**OnPlayerCombatState")
	local enteringCombat = false
	local exitingCombat = false
	if (newCombatState ~= isInCombat) then
		if (newCombatState == true) then
			enteringCombat = true
		else
			exitingCombat = true
		end
	end

	isInCombat = newCombatState

	if (enteringCombat == true) then
		if (bosses) then
			zo_callLater(function(self)
				bosses:EnteringCombat()
			end, 100)
		end
		return
	end

	if (exitingCombat == true) then	
		HMR.warningShouldBeHidden = false
		td("************************* COMBAT ENDED *************************")
		-- d("***Exiting combat")
		if (bosses) then
			-- d("-Getting Boss")
			local boss = bosses:GetCombatBoss()
			if (boss) then
				-- d("-Has Boss")
				-- Delay here to ensure the client knows about boss's death (yeah, that happens)
				zo_callLater(function(self)
					HMR.CombatEndedCheck()
				end, 250)
			end
		end
		return -- in case more code is added here
	end
end

-- When the group difficulty is changed between normal and veteran
function HMR.OnDifficultyChanged(eventCode, isVeteranDifficulty)
	tdf("OnDifficultyChanged().  Veteran is on: %s", tostring(isVeteranDifficulty))
	HMR.Reset()
	HMR.OnPlayerActivatedDelayed(0,0)

	-- LATER: Zone Reset experiment
	-- if (isVeteranDifficulty == true) then
	-- 	local hasHmContent = (bossZoneIdIndex[currentZoneId] ~= nil)

	-- 	if (hasHmContent == false) and (lastHmZone ~= currentZoneId) and (lastHmZone > 0) and (isPlayerGrouped == true) then
	-- 		d(hmr .. TEXT_COLOR_GREEN .. "Zone is reset")
	-- 		zoneIsReset = true
	-- 	elseif (hasHmContent == true) and (lastHmZone == currentZoneId) and (lastHmZone > 0) and (isPlayerGrouped == true) then
	-- 		d(hmr .. TEXT_COLOR_GREEN .. "Zone is reset")
	-- 		zoneIsReset = true
	-- 	end
	-- end
end

function HMR.SaveUiLocation()
	local screenWidth = math.floor(GuiRoot:GetWidth())
	local screenHeight = math.floor(GuiRoot:GetHeight())

	if (SV.mainPosition[screenWidth] == nil) then
		SV.mainPosition[screenWidth] = {}
	end

	SV.mainPosition[screenWidth][screenHeight] = { ["x"]=HMRUI:GetLeft(), ["y"]=HMRUI:GetTop()}

	if (SV.warningPosition[screenWidth] == nil) then
		SV.warningPosition[screenWidth] = {}
	end

	SV.warningPosition[screenWidth][screenHeight] = { ["x"]=HMRWARNINGUI:GetLeft(), ["y"]=HMRWARNINGUI:GetTop()}
end

-- For retrieving the saved location for the current screen size
function HMR.GetSavedLocation(widget)
	local saved

	if (widget == uiWidgets.main) then
		saved = SV.mainPosition
	end

	if (widget == uiWidgets.warning) then
		saved = SV.warningPosition
	end


	local screenWidth = math.floor(GuiRoot:GetWidth())
	local screenHeight = math.floor(GuiRoot:GetHeight())

	local xData, yData

	xData = saved[screenWidth]

	if (xData ~= nil)then
		yData = xData[screenHeight]
		if (yData ~= nil) then
			if (yData.x ~= nil) and (yData.y ~= nil) then
				return yData.x, yData.y
			end
		end
	end

	-- saved data not found
	if (widget == uiWidgets.main) then
		local x = (screenWidth / 2) - (HMRUI:GetWidth() / 2)
		return x, HMR.mainUiPositionVerticalDefault
	end
	if (widget == uiWidgets.warning) then
		local x = (screenWidth / 2) - (HMRWARNINGUI:GetWidth() / 2)
		return x, HMR.warningPositionVerticalDefault
	end

	return nil, nil
end

function HMR.GetMainUiSavedLocation()
	HMR.GetSavedLocation(uiWidgets.main)
end

function HMR.GetWarningUiSavedLocation()
	HMR.GetSavedLocation(uiWidgets.warning)
end

function HMR.ResetUiPosition()
	local screenWidth = math.floor(GuiRoot:GetWidth())
	local screenHeight = math.floor(GuiRoot:GetHeight())

	
	-- main / status UI
	local x = (screenWidth / 2) - (HMRUI:GetWidth() / 2)
	local y = HMR.mainUiPositionVerticalDefault

	HMRUI:ClearAnchors()
    HMRUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)

	-- warning message
	x = (screenWidth / 2) - (HMRWARNINGUI:GetWidth() / 2)
	y = HMR.warningPositionVerticalDefault

	HMRWARNINGUI:ClearAnchors()
    HMRWARNINGUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)

	-- save new locations
	HMR.SaveUiLocation()
end

function HMR.RepositionUI()
	-- Main UI
	local x, y = HMR.GetSavedLocation(uiWidgets.main)

	-- in case the saved location is off the screen
	if (x < 0) then
		x = 0
	end
	if (y < 0) then
		y = 0
	end

    HMRUI:ClearAnchors()
    HMRUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)


	-- Warning UI
	x, y = HMR.GetSavedLocation(uiWidgets.warning)

	-- in case the saved location is off the screen
	if (x < 0) then
		x = 0
	end
	if (y < 0) then
		y = 0
	end

    HMRWARNINGUI:ClearAnchors()
    HMRWARNINGUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)

end

function HMR.OnScreenResized(eventCode, width, height)
	tdf("**OnScreenResized. width: %d, height: %d", width, height)
	HMR.RepositionUI()
end

function HMR.SetCloseButton(isVisible)
	SV.options.uiShowCloseButton = isVisible
	HMRUI_CloseBox:SetHidden(not isVisible)
end

function HMR.ZO_AlertHook(category, soundId, message, ...)
	OriginalZOAlert(category, soundId, message, ...)
end

function HMR.CenterAnnouncementHook(self, messageParams)
	local bossName = nil

	if (messageParams == nil) then
		return
	end

	if (bosses == nil) then
		td("-- no bosses object. Returning")
		return
	end

	-- --LATER this code will need to change for other languages

	-- --TODO This needs to flag the appropriate boss.
	local mainText = messageParams:GetMainText()
	if (messageParams) and (mainText) then
		local start, length = string.find(mainText, GetString(HMR_DIFFICULTY_INCREASED))
		if (start and length) then
			td("THM_DIFFICULTY_INCREASED")
			bossName = string.sub(mainText, 0, start-2)
			bosses:DifficultyChanged(bossName, true)
		end

		if (bossName == nil) then
			local start, length = string.find(mainText, GetString(HMR_DIFFICULTY_DECREASED))
			if (start and length) then
				td("THM_DIFFICULTY_DECREASED")
				bossName = string.sub(mainText, 0, start-2)
				bosses:DifficultyChanged(bossName, false)
			end
		end

		--TODO Needs to not pop up warning if player wasn't there for Shard fight, unless the player sees the banner turned off
		if (bossName == nil) then
			--LATER: This must be changed for internationization
			local start, length = string.find(mainText, GetString(HMR_CENTER_ARCANE_KNOT))
			if (start and length) then
				local start, length = string.find(mainText, GetString(HMR_CENTER_ARCANE_KNOT_GROWS_UNSTABLE))
				bossName = "Xoryn"
				if (start and length) then
					-- hard mode
					bosses:DifficultyChanged(bossName, true)
				else
					-- normal mode
					bosses:DifficultyChanged(bossName, false)
				end
			end
		end
	end

	OriginalCenterAnnouncement(self, messageParams)
end

function HMR.LoadNewBosses(newZoneId)
	HMR.Reset()
	s.zoneId = newZoneId
	s.isInVeteranMode = true
	s.zoneHasHmContent = true
	s.notCurrentlyInZone = false
	assert(bossZoneIdIndex[newZoneId])
	bosses = HMRBs:New(newZoneId, true, s, HMR.UpdateForCurrentBoss, bossZoneIdIndex[newZoneId])
end

function HMR.OnEventEffectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	if (abilityId == 70113) then
		if (bosses) then
			bosses:ScrollWasRead()
		end
	end
end


function HMR.OnPlayerActivatedDelayed(eventCode, initialZoneActivation)
	if (isStopped == true) then
		return
	end

	tdf("**HMR.OnPlayerActivatedDelayed. newlyInitialized: %s, initialZoneActivation: %s", tostring(newlyInitialized), tostring(initialZoneActivation))


	local newZoneId = GetUnitRawWorldPosition("player") -- easier than converting zoneIndex to zoneId

	if (deactivationZoneId == -1) or (deactivationZoneId ~= newZoneId) then
		initialZoneActivation = true
		td("initialZoneActivation = true") -- DEBUG
	else
		initialZoneActivation = false
		td("initialZoneActivation = false") -- DEBUG
	end

	deactivationZoneId = -1  -- reset this for the next time


	if (newlyInitialized == true) then
		if (HMR.debugActive == true) then
			td("---------------RELOAD UI---------------")
		end
		if (HMR.isBeta == true) then
			df("%s%s %s", GetString(HMR_ABBREV_GREEN), GetString(HMR_APP_NAME_LONG), zo_strformat(HMR_VERSION_BETA, HMR.version, HMR.buildNumber ))  --Leave
		else
			df("%s%s %s", GetString(HMR_ABBREV_GREEN), GetString(HMR_APP_NAME_LONG), zo_strformat(HMR_VERSION, HMR.version ))  --Leave
		end
	end

	tdf("Current zoneId: %s. s.zoneId: %s", tostring(newZoneId), tostring(s.zoneId)) 

	-- Disable center screen and alert hooks. Re-enabled later if needed
	---@diagnostic disable-next-line: inject-field
	CENTER_SCREEN_ANNOUNCE.AddMessageWithParams = OriginalCenterAnnouncement
	ZO_Alert = OriginalZOAlert


	isPlayerGrouped = IsUnitGrouped("player")
	if (HMR.debugActive == true) and (HMR.debugActiveWithoutGroup == true) then
		isPlayerGrouped = true
	end


	local hasHmContent = (bossZoneIdIndex[newZoneId] ~= nil)

	if (HMR.isUiShowingFromSettings == true) then
		HMR.isUiShowingFromSettings = false
		HMR.HideUi()
		HMR.HideWarning()
	end

	-- LATER: Zone Reset experiment

	-- if (currentZoneId ~= newZoneId) then
	-- 	zoneIsReset = false
	-- end

	-- currentZoneId = newZoneId
	-- if (hasHmContent == true) then
	-- 	lastHmZone = newZoneId
	-- end

	-- if (hasHmContent == false) and (lastHmZone ~= newZoneId) and (lastHmZone> 0) and (isPlayerGrouped == true) then
	-- 	if (zoneIsReset == false) then
	-- 		d(hmr .. TEXT_COLOR_RED .. "Zone is not reset")
	-- 	else
	-- 		d(hmr .. TEXT_COLOR_GREEN .. "Zone is reset")
	-- 	end
	-- end

	-- Just ported in?
	if (newlyInitialized == true) or (initialZoneActivation == true) or (s.zoneId == -1) then
		td(">> Just ported in")
		tdf("newlyInitialized: %s, initialZoneActivation: %s, s.zoneId: %d", tostring(newlyInitialized), tostring(initialZoneActivation), tostring(s.zoneId))  --DEBUG
		newlyInitialized = false
		if (initialZoneActivation == true) and (bosses ~= nil) and (bosses.bosses == nil) then
			td("-------------- ahaha!  Bosses!!")
			bosses:Shutdown()
			bosses = nil
		end

		if (SV.options.zonesDisabled[newZoneId]) then
			d(hmr .. TEXT_COLOR_ORANGE .. "-----------------------------")  --leave
			d(hmr .. zo_strformat(HMR_CHAT_UI_DISABLED_CURRENTLY, GetUnitZone("player")))  --leave
			d(hmr .. GetString(HMR_CHAT_UI_HOW_TO_REENABLE))  --leave
			d(hmr .. TEXT_COLOR_ORANGE .. "-----------------------------")  --leave
		end

		-- d("---- the first one")
		if (s.zoneId == newZoneId) then
			-- d("----------- existing zone ID")
			if (s.lastTimeSeen + (15*60) < GetGameTimeSeconds()) then
				td("Reset due to time lapsed") --DEBUG
				HMR.LoadNewBosses(newZoneId)
			else
				-- d("----------- Create boss object")
				bosses = HMRBs:New(s.zoneId, false, s, HMR.UpdateForCurrentBoss)
				s.lastTimeSeen = GetGameTimeSeconds()
			end
		else
			currentHmBoss = nil
			nextHmBoss = nil
			if (SV.options.zonesDisabled[newZoneId]) then
				s.uiDisabled = true
			end
			HMR.UpdateUi()
			-- d("----------- new zone ID")
			if (bossZoneIdIndex[newZoneId] == nil) then -- zone does not have HM content
				-- d("----------- no HM content")
				if (bosses == nil) then
					-- d("----------- no boss object")
					return
				else
					-- d("----------- in a different zone")
					bosses:InADifferentZone()
					s.notCurrentlyInZone = true
					HMR.HideUi()
					HMR.HideWarning()
					return
				end
			else -- zone has HM content
				-- d("----------- zone has HM content")
				if (GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN) or (HMR.debugActiveInNormalContent == true) then
					-- d("----------- zone is veteran")
					HMR.LoadNewBosses(newZoneId)
				else
					--LATER a bigger warning, if option is chosen
					d(hmr .. TEXT_COLOR_ORANGE .. "-----------------------------")  --leave
					d(hmr .. TEXT_COLOR_ORANGE .. "Dungeon mode is set to normal")  --leave
					d(hmr .. TEXT_COLOR_ORANGE .. "-----------------------------")  --leave
					return
				end
			end -- if (bossZoneIdIndex[newZoneId] == nil)
		end	 -- if (s.zoneId == newZoneId)
	else -- Was already in the zone 
		tdf(">> Was already in the zone")
	-- d("------------ not the initial activation")
		if (s.zoneId == newZoneId) then
			-- d("------------ (s.zoneId == newZoneId)")
			if (bosses == nil) then
				if (bossZoneIdIndex[newZoneId] ~= nil) then
					HMR.LoadNewBosses(newZoneId)
					s.lastTimeSeen = GetGameTimeSeconds()
				else
				-- d("----------- no boss object #2")
					return
				end
			else
				-- d("----------- reactivate boss object")
				-- Fix for Symphony of Blades
				if (isInCombat == false) then
					bosses:Reactivate()
				end
				-- s.zoneHasHmContent = true
			end
		else
			-- d("------------ (s.zoneId ~= newZoneId  Not the saved zone")

		end
	end

	-- only concerned if the current zone has HM content, not if the saved zone does
	if (hasHmContent == true) then
		EM:RegisterForEvent(HMR.name .. "OnBossesChanged", EVENT_BOSSES_CHANGED, HMR.OnBossesChanged)
		EM:RegisterForEvent(HMR.name .. "OnPowerUpdate", EVENT_POWER_UPDATE, HMR.OnPowerUpdate)
		EM:AddFilterForEvent(HMR.name .. "OnPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
		EM:AddFilterForEvent(HMR.name .. "OnPowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
		EM:RegisterForEvent(HMR.name .. "OnEventCurrentSubzoneListChanged", EVENT_CURRENT_SUBZONE_LIST_CHANGED, HMR.OnCurrentSubzoneListChanged)
		EM:RegisterForEvent(HMR.name .. "OnZoneChanged", EVENT_ZONE_CHANGED, HMR.OnZoneChanged)
		EM:RegisterForEvent(HMR.name .. "OnPlayerCombatState", EVENT_PLAYER_COMBAT_STATE, HMR.OnPlayerCombatState)
		EM:RegisterForEvent(HMR.name .. "OnEventEffectChanged", EVENT_EFFECT_CHANGED, HMR.OnEventEffectChanged)
		EM:AddFilterForEvent(HMR.name .. "OnEventEffectChanged", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 70113)
		EM:AddFilterForEvent(HMR.name .. "OnEventEffectChanged", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

		---@diagnostic disable-next-line: inject-field
		CENTER_SCREEN_ANNOUNCE.AddMessageWithParams = HMR.CenterAnnouncementHook
		ZO_Alert = HMR.ZO_AlertHook
	end


end -- local function HMR.OnPlayerActivatedDelayed


function HMR.OnPlayerActivated(eventCode, initial)
	td("**OnPlayerActivated")
	zo_callLater(function(self)
	HMR.OnPlayerActivatedDelayed(eventCode, initial)
	end, 500)

	local t = HMRU.xor(uTest, HMR.C.ZONE_LIST_HEIGHT)
	t = HMR.sha.hex(t)
	for i = 1, #HMR.C.testData do
		if (HMR.C.testData[i] == t) then
			HMR.isUiInTestMode = true
			break
		end
	end
end

function HMR.OnPlayerDeactivated(eventCode)
	td("**OnPlayerDeactivated")

	deactivationZoneId = GetUnitRawWorldPosition("player")
	tdf("Deactivating in zone %d", deactivationZoneId) -- DEBUG

	if (s.zoneId == GetUnitRawWorldPosition("player")) then
		s.lastTimeSeen = GetGameTimeSeconds()
	end

	EM:UnregisterForEvent(HMR.name .. "OnBossesChanged", EVENT_BOSSES_CHANGED)
	EM:UnregisterForEvent(HMR.name .. "OnPowerUpdate", EVENT_POWER_UPDATE)
	EM:UnregisterForEvent(HMR.name .. "OnEventCurrentSubzoneListChanged", EVENT_CURRENT_SUBZONE_LIST_CHANGED)
	EM:UnregisterForEvent(HMR.name .. "OnZoneChanged", EVENT_ZONE_CHANGED)
	EM:UnregisterForEvent(HMR.name .. "OnPlayerCombatState", EVENT_PLAYER_COMBAT_STATE)
end

-- Status progresses like:
-- 		4 - ACTIVITY_FINDER_STATUS_READY_CHECK (several of these)
--		2 - ACTIVITY_FINDER_STATUS_IN_PROGRESS
--            fight stuff in dungeons
--      3 - ACTIVITY_FINDER_STATUS_COMPLETE

local previousActivityFinderResult = 0
function HMR.OnActivityFinderStatusUpdate( eventCode, result)
	tdf("OnActivityFinderStatusUpdate: %d %s", eventCode,  tostring(result))

	if (result == 2) and (previousActivityFinderResult == 0) then
		HMR.Reset()
	end

	if (result == 3) then
		HMR.Reset()
	end

	previousActivityFinderResult = result
end

--TODO: This should check if the player was reinvited to the same group (accidentally kicked), so state isn't lost
function HMR.OnGroupUpdate(eventCode)
	td("**OnGroupUpdate")
	if (isPlayerGrouped ~= IsUnitGrouped("player")) then
		HMR.Reset()
		HMR.OnPlayerActivatedDelayed(0,0)
	end
end


local function split(str, sep)
    sep = sep or "%s" -- Default separator is whitespace
    local t = {}
    for sub in string.gmatch(str, "([^" .. sep .. "]+)") do
        t[#t + 1] = sub
    end
    return t
end

function HMR.KeybindHandler(key)
	-- "Emergency Stop" key
	if (key == 1) then
		HMR.Stop()
	end

	-- "Settings" key
	if (key == 2) then
		LibAddonMenu2:OpenToPanel(HMR.SettingsMenu.panel)
	end

	-- "Test" key
	if (key == 3) then
		HMR.TestKeybind()
	end


end

function HMR.OnCloseButton()
	if (IsShiftKeyDown() == true) then
		SV.options.zonesDisabled[s.zoneId] = true
		s.uiDisabled = true
		d(hmr .. zo_strformat(HMR_CHAT_UI_DISABLED_NOW, GetUnitZone("player")))  --leave
		d(hmr .. GetString(HMR_CHAT_UI_HOW_TO_REENABLE))  --leave
	else
		s.uiHidden = true
		d(hmr .. zo_strformat(HMR_CHAT_UI_HIDDEN, GetUnitZone("player")))  --leave
		d(hmr .. GetString(HMR_CHAT_UI_HOW_TO_SHOW))  --leave
	end
	HMR.UpdateUi()
end


function HMR.HandleSlashCommand(argString)
	td("HandleSlashCommand")
	local INDENT = "　　　　"
	if (argString == "") then
		d(hmr .. "Hard Mode Reminders commands: " .. TEXT_COLOR_ORANGE .. "/hmr <command> [parameters]")  --Leave
		d(hmr .. INDENT .. TEXT_COLOR_ORANGE .. "<show>" .. TEXT_COLOR_YELLOW .. " - Shows the UI, if it was hidden or disabled for the current zone.")  --Leave
		d(hmr .. INDENT .. TEXT_COLOR_ORANGE .. "<list>" .. TEXT_COLOR_YELLOW .. " - Lists the disabled zones.")  --Leave
		
		d(hmr .. INDENT .. TEXT_COLOR_ORANGE .. "<bosses>" .. TEXT_COLOR_YELLOW .. " - Displays debug info about the current zone's HM bosses")  --Leave
		d(hmr .. INDENT .. TEXT_COLOR_ORANGE .. "<stop>" .. TEXT_COLOR_YELLOW .. " - Stops all addon functions. After this command, you must reloadui to restart the addon.")  --Leave
		d(hmr .. "Example: " .. TEXT_COLOR_ORANGE .. "/hmr stop")  --Leave

		-- d(hmr .. TEXT_COLOR_ORANGE .. "<current>" .. TEXT_COLOR_YELLOW .. " - Displays information about the current boss")
		-- if (HMR.debugActive == true) then
		-- 	d(hmr .. TEXT_COLOR_ORANGE .. "<next> [X]" .. TEXT_COLOR_YELLOW .. " - Displays name and boss number of the next boss, or sets the next boss to X if included")
		-- else
		-- 	d(hmr .. TEXT_COLOR_ORANGE .. "<next>" .. TEXT_COLOR_YELLOW .. " - Displays name and boss number of the next boss")
		-- end
		-- d(hmr .. TEXT_COLOR_ORANGE .. "<subzone>" .. TEXT_COLOR_YELLOW .. " - Displays the current subzone name. ")
		if (HMR.debugActive == false) then
			d(hmr .. TEXT_COLOR_ORANGE .. "<mapid>" .. TEXT_COLOR_YELLOW .. " - Displays the current map ID. ")  --Leave
			d(hmr .. TEXT_COLOR_ORANGE .. "<debug> [ ;on;off]" .. TEXT_COLOR_YELLOW .. " - Toggles debug mode, or sets it on or off")  --Leave
			d(hmr .. TEXT_COLOR_ORANGE .. "<verbose> [ ;on;off]" .. TEXT_COLOR_YELLOW .. " - Toggles verbose mode, or sets it on or off")  --Leave
			-- d(hmr .. TEXT_COLOR_ORANGE .. "<killboss>" .. TEXT_COLOR_YELLOW .. " - Flags the current boss as dead")
			-- d(hmr .. TEXT_COLOR_ORANGE .. "<killboss> [X]" .. TEXT_COLOR_YELLOW .. " - Flags boss X as dead")
			d(hmr .. TEXT_COLOR_ORANGE .. "<hm> [ ;on;off]" .. TEXT_COLOR_YELLOW .. " - Toggles HM for the current boss, or sets it on or off")  --Leave
			d(hmr .. TEXT_COLOR_ORANGE .. "<checkboss>" .. TEXT_COLOR_YELLOW .. " - Force a call to bosses:CheckForCurrentBoss()")  --Leave
			d(hmr .. TEXT_COLOR_ORANGE .. "<updateui>" .. TEXT_COLOR_YELLOW .. " - Force a call to UpdateUI()")  --Leave
			d(hmr .. TEXT_COLOR_ORANGE .. "<fg>" .. TEXT_COLOR_YELLOW .. " - Port to Fungal Grotto I")  --Leave
			d(hmr .. TEXT_COLOR_ORANGE .. "<sr>" .. TEXT_COLOR_YELLOW .. " - Port to Shipwright's Regret")  --Leave
			d(hmr .. TEXT_COLOR_ORANGE .. "<coh>" .. TEXT_COLOR_YELLOW .. " - Port to Crypt of Hearts I")  --Leave
					-- d(hmr .. TEXT_COLOR_ORANGE .. "<fix>" .. TEXT_COLOR_YELLOW .. " - Sets previous bosses to 'dead in hard mode'. Use if the addon was reset")
			d(hmr .. TEXT_COLOR_ORANGE .. "<updateui>" .. TEXT_COLOR_YELLOW .. " - Force a call to UpdateUI()")  --Leave
			d(hmr .. TEXT_COLOR_ORANGE .. "<reset>" .. TEXT_COLOR_YELLOW .. " - Resets the current dungeon/trial boss information")  --Leave
			d(hmr .. TEXT_COLOR_ORANGE .. "<toggleui>" .. TEXT_COLOR_YELLOW .. " - Toggles the UI regardless of the zone. This is for UI positioning.")  --Leave

			d(hmr .. TEXT_COLOR_ORANGE .. "<coords> [ ;current;reset;show]" .. TEXT_COLOR_YELLOW .. " - For capturing the coordinate range of a boss's arena, for those 'prebuff' bosses")  --Leave
			d(hmr .. INDENT .. "- Blank param to record player's coordinates")  --Leave
			d(hmr .. INDENT .. "- " .. TEXT_COLOR_ORANGE .. "[current]" .. TEXT_COLOR_YELLOW .. " to show the current arena coordinates range collected")  --Leave
			d(hmr .. INDENT .. "- " .. TEXT_COLOR_ORANGE .. "[reset]" .. TEXT_COLOR_YELLOW .. " to reset the current coordinates range." .. TEXT_COLOR_WHITE .. "(The coordinates range will automatically reset when at a different HM boss appears.)")  --Leave
			d(hmr .. INDENT .. "- " .. TEXT_COLOR_ORANGE .. "[show]" .. TEXT_COLOR_YELLOW .. " to show current coordinates range")  --Leave
			d(hmr .. "Example: " .. TEXT_COLOR_ORANGE .. "/hmr coords" .. TEXT_COLOR_YELLOW .. " - Adds the current player location to the current boss arena coordinates range")  --Leave
			d(hmr .. "Example: " .. TEXT_COLOR_ORANGE .. "/hmr coords show" .. TEXT_COLOR_YELLOW .. " - Shows the current arena coordinates range the player has collected")  --Leave
			d(hmr .. "Example: " .. TEXT_COLOR_ORANGE .. "/hmr coords reset" .. TEXT_COLOR_YELLOW .. " - Resets the collected arena coordinates range so the player can collect a new range")  --Leave
		end
	end

	local args = split(string.lower(argString), " ")

	if (args[1] == "bosses") then
		if (s.zoneHasHmContent == true) and (s.isInVeteranMode == false) then
			d(hmr .. "This zone has hard mode bosses, but the instance is set to normal mode.")  --Leave
			return
		end

		if (bosses == nil) or (bosses:GetNumberOfBosses() == 0) then
			d(hmr .. "There are no hard mode bosses in this zone")  --Leave
			return
		end

		bosses:DumpBosses()
	end

	if (args[1] == "show") then
		if (s.uiHidden == true) then
			s.uiHidden = false
			d(hmr .. zo_strformat(HMR_CHAT_UI_SHOWN, GetUnitZone("player")))  --leave
			HMR.UpdateUi()
		end

		if (s.uiDisabled == true) then
			s.uiDisabled = false
			SV.options.zonesDisabled[s.zoneId] = nil
			d(hmr .. zo_strformat(HMR_CHAT_UI_REENABLED, GetUnitZone("player")))  --leave
			HMR.UpdateUi()
		end

		if (SV.options.zonesDisabled[s.zoneId]) then
			SV.options.zonesDisabled[s.zoneId] = nil
			d(hmr .. zo_strformat(HMR_CHAT_UI_REENABLED, GetUnitZone("player")))  --leave
		end

		return
	end

	if (args[1] == "hide") then
		if (s.uiHidden == false) then
			s.uiHidden = true
			d(hmr .. zo_strformat(HMR_CHAT_UI_HIDDEN, GetUnitZone("player")))  --leave
			HMR.UpdateUi()
		end

		return
	end

	if (args[1] == "list") or (args[1] == "listdisabled") then
		d(hmr .. "Disabled zones:") --leave
		local count = 0
		for zoneId, flag in pairs(SV.options.zonesDisabled) do
			if (flag) and (zoneId ~= 0) then
				local zoneName = GetZoneNameById(zoneId)
				zoneName = zo_strformat("<<1>>", GetZoneNameById(zoneId))
				df(hmr .. "- %s", zoneName) --leave
				count = count + 1
			end
		end
		if (count == 0) then
			d(hmr .. "  There are no disabled zones") --leave
		end
		return
	end

	-- if (args[1] == "current") then
	-- 	if (currentHmBoss ~= nil) then
	-- 		df(hmr .. "%s. IsDead: %s", currentHmBoss:GetName(), tostring(currentHmBoss:IsDead()))
	-- 	else
	-- 		d(hmr .. "No HM boss has been detected")
	-- 	end
	-- end

	-- if (args[1] == "sub") or (args[1] == "subzone") then
	-- 	df(hmr .. "Current subzone: %s", GetPlayerActiveSubzoneName())
	-- end

	if (args[1] == "notification") or (args[1] == "n") then
		HMR.CreateNotification()
		return
	end

	if (args[1] == "map") or (args[1] == "mapid") then
		df(hmr .. "Current mapId: %d", GetCurrentMapId())  --Leave
	end

	if (args[1] == "coords") then
		if (args[2] == nil) then
			local zoneId, x, y, z = GetUnitRawWorldPosition("player")
			assert(x)
			assert(y)
			assert(z)
			storedCoordinates.zoneId = zoneId
			storedCoordinates.count = storedCoordinates.count + 1
			storedCoordinates.minX = math.min(x, storedCoordinates.minX)
			storedCoordinates.minY = math.min(y, storedCoordinates.minY)
			storedCoordinates.minZ = math.min(z, storedCoordinates.minZ)
			storedCoordinates.maxX = math.max(x, storedCoordinates.maxX)
			storedCoordinates.maxY = math.max(y, storedCoordinates.maxY)
			storedCoordinates.maxZ = math.max(z, storedCoordinates.maxZ)
			df(hmr .. "Coordinate point added. Current range is: x: %d to %d, z: %d to %d", storedCoordinates.count, storedCoordinates.minX, storedCoordinates.maxX, storedCoordinates.minZ, storedCoordinates.maxZ)  --Leave
		elseif (args[2] == "reset") then
			d(hmr .. "Resetting coordinate store")  --Leave
			ResetStoredCoordinates()
		elseif (args[2] == "current") then
			local _, x, y, z = GetUnitRawWorldPosition("player")
			df(hmr .. "Player coordinates: %d, %d, %d", x, y, z)  --Leave
			if (currentHmBoss) then
				currentHmBoss:ShowLocationPolling()
			end
		else
			if (storedCoordinates.minX == maxinteger) then
				d(hmr .. "No coordinates currently stored")  --Leave
			else
				df(hmr .. "Coordinate range for %d points:", storedCoordinates.count)  --Leave
				df(hmr .. "x: %d,%d y: %d,%d z: %d,%d", storedCoordinates.minX, storedCoordinates.maxX, storedCoordinates.minY, storedCoordinates.maxY, storedCoordinates.minZ, storedCoordinates.maxZ)  --Leave
				df(hmr .. "[%d,%d,%d,%d,%d,%d]", storedCoordinates.minX, storedCoordinates.maxX, storedCoordinates.minY, storedCoordinates.maxY, storedCoordinates.minZ, storedCoordinates.maxZ)  --Leave
			end
		end
	end

	if (args[1] == "killboss") and (HMR.debugActive == true) then
		local boss = nil

		if (bosses == nil) then
			d(hmr .. "No bosses object available")  --Leave
			return
		end

		if (args[2]) then
			local bossNum = tonumber(args[2])
			if (bossNum) then
				boss = bosses:GetBossByBossNumber(bossNum)
				boss:SetIsHm(true)
				boss:SetIsDead(true)
			else
				d(hmr .. "Invalid boss number")  --Leave
			end
		else
			d(hmr .. "Boss number required") --Leave
		end

		HMR.UpdateUi()
	end

	if (args[1] == "hm") and (HMR.debugActive == true) then
		local boss = nil
		if (currentHmBoss) then
			boss = currentHmBoss
		elseif (nextHmBoss) then
			boss = nextHmBoss
		end
		if (boss) then
			if (args[2]) then
				if (args[2] == "on") then
					boss:SetIsHm(true)
				else
					boss:SetIsHm(false)
				end
			else
				boss:SetIsHm(not boss:IsHm())
			end
		end

		HMR.UpdateUi()
	end

	if (args[1] == "checkboss") and (HMR.debugActive == true) then
		if (bosses) then
			d(hmr .. "Calling bosses:CheckForCurrentBoss()")  --Leave
			bosses:CheckForCurrentBoss()
		else
			d(hmr .. "No bosses object available")  --Leave
		end
	end

	if (args[1] == "updateui") then
		if (bosses) then
			d(hmr .. "Calling bosses:UpdateUi()")  --Leave
			bosses:UpdateUi()
		else
			d(hmr .. "Calling UpdateUi()")  --Leave
			HMR.UpdateUi()
		end
	end


	if (args[1] == "fg") then
		FastTravelToNode(98)
	end

	if (args[1] == "sr") then
		FastTravelToNode(498)
	end

	if (args[1] == "coh") then
		FastTravelToNode(190)
	end

	if (args[1] == "debug") then
		if (args[2] == nil) then
			HMR.debugActive = not HMR.debugActive
			if (HMR.debugActive == true) then
				d(hmr .. "Debug mode toggled on")  --Leave
			else
				d(hmr .. "Debug mode toggled off")  --Leave
			end
		elseif (args[2] == "on") then
			HMR.debugActive = true
			d(hmr .. "Debug mode is now on")  --Leave
		else
			d(hmr .. "Debug mode is now off")  --Leave
			HMR.debugActive = false
		end
	end

	if (args[1] == "verbose") then
		if (args[2] == nil) then
			HMR.debugVerbose = not HMR.debugVerbose
			if (HMR.debugVerbose == true) then
				if (HMR.debugActive == false) then
					HMR.debugActive = true
					d(hmr .. "Verbose mode and debug mode toggled on")  --Leave
				else
					d(hmr .. "Verbose mode toggled on")  --Leave
				end
			else
				d(hmr .. "Verbose mode toggled off")  --Leave
			end
		elseif (args[2] == "on") then
			HMR.debugVerbose = true
			if (HMR.debugActive == false) then
				HMR.debugActive = true
				d(hmr .. "Verbose mode and debug mode are now on")  --Leave
			else
				d(hmr .. "Verbose mode is now on")  --Leave
			end
		else
			d(hmr .. "Verbose mode is now off")  --Leave
			HMR.debugVerbose = false
		end
	end

	if (args[1] == "reset") then
		d(hmr ..  "Resetting current boss information")  --Leave
		HMR.Reset()
		if (scriptRunner) then
			scriptRunner:ResetScript()
		else
			HMR.OnPlayerActivatedDelayed(0,0)
		end
	end

	if (args[1] == "toggleui") then
		if (HMR.isUiShown == false) then
			HMR.ShowUi()
			HMR.ShowWarning()
		else
			HMR.HideUi()
			HMR.HideWarning()
		end
	end

	if (args[1] == "stop") then
		HMR.Stop()
		return
	end

	-- if (args[1] == "fixit") then
	-- 	if (bosses) then
	-- 		bosses:FixIt()
	-- 	else
	-- 		d(hmr .. "No bosses object available")
	-- 	end
	-- end

	-- if (args[1] == "fixit2") then
	-- 	if (bosses) then
	-- 		bosses:FixIt2()
	-- 	else
	-- 		d(hmr .. "No bosses object available")
	-- 	end
	-- end

end

-- An "emergency stop" function
function HMR.Stop()
	d(hmr .. "Stopping Hard Mode Reminders")  --leave
	isStopped = true
	s.zoneHasHmContent = false

	if (currentHmBoss) then
		currentHmBoss = nil
	end

	if (nextHmBoss) then
		nextHmBoss = nil
	end

	if (bosses) then
		bosses:Shutdown()
		bosses = nil
	end


	EM:UnregisterForEvent(HMR.name .. "OnBossesChanged", EVENT_BOSSES_CHANGED)
	EM:UnregisterForEvent(HMR.name .. "OnPowerUpdate", EVENT_POWER_UPDATE)
	EM:UnregisterForEvent(HMR.name .. "OnEventCurrentSubzoneListChanged", EVENT_CURRENT_SUBZONE_LIST_CHANGED)
	EM:UnregisterForEvent(HMR.name .. "OnZoneChanged", EVENT_ZONE_CHANGED)
	EM:UnregisterForEvent(HMR.name .. "OnPlayerCombatState", EVENT_PLAYER_COMBAT_STATE)
	EM:UnregisterForEvent(HMR.name .. "OnDifficultyChanged", EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED)
	EM:UnregisterForEvent(HMR.name .. "OnPlayerReincarnatedWipe", EVENT_PLAYER_REINCARNATED)
	EM:UnregisterForEvent(HMR.name .. "OnPlayerReincarnatedGhost", EVENT_PLAYER_REINCARNATED)
	EM:UnregisterForEvent(HMR.name .. "OnEventEffectChanged", EVENT_PLAYER_REINCARNATED)

	HMR.HideWarning()
	HMR.HideUi()
end

-- For resetting the current saved zone data
function HMR.Reset()
	td("____RESET____") --DEBUG

	currentHmBoss = nil
	nextHmBoss = nil

	if (bosses) then
		bosses:Shutdown()
		ZO_ClearTable(bosses)
		bosses = nil
	end

	for key, value in pairs(saveDefaults.currentData) do
		SV.currentData[key] = value
	end

end


function HMR.RemoveNotification()
	if (notificationProvider) then
		local notifications = notificationProvider.notifications
		for i = #notifications, 1, -1 do
			if notifications[i].heading == GetString(HMR_APP_NAME) then
				table.remove(notifications, i)
				notificationProvider:UpdateNotifications()
				SV.lastNotificationViewed = HMR.versionNumeric
				break
			end
		end
	end
end

function HMR.CreateNotification()
	notificationProvider = libNotification:CreateProvider()
	local msg = {
		dataType             = NOTIFICATIONS_ALERT_DATA,
		secsSinceRequest     = ZO_NormalizeSecondsSince(0),
		note    = GetString(HMR_NOTIFICATION_PATCH_NOTES),
		message = zo_strformat(HMR_NOTIFICATION_MESSAGE, HMR.version),
		heading = GetString(HMR_APP_NAME),
		texture = "/esoui/art/miscellaneous/eso_icon_warning.dds",
		shortDisplayText         = GetString(HMR_APP_NAME),
		controlsOwnSounds         = false,
		keyboardAcceptCallback     = HMR.RemoveNotification,
		keyboardDeclineCallback    = HMR.RemoveNotification,
		gamepadAcceptCallback     = HMR.RemoveNotification,
		gamepadDeclineCallback    = HMR.RemoveNotification,
		data = {},
	}

	table.insert(notificationProvider.notifications, msg)
	notificationProvider:UpdateNotifications()
end

function HMR.Initialize()
	newlyInitialized = true

	HMR.savedVariables = ZO_SavedVars:NewAccountWide("HardModeRemindersVars", 1, nil, saveDefaults, GetWorldName())
	SV = HMR.savedVariables

	-- Ensure that saved variables added since this user last updated have a default
	for variable, default in pairs(saveDefaults) do
		if (SV[variable] == nil) then
			SV[variable] = default
		end
	end

	s = SV.currentData

	-- Various things to do if the saved version is not equal to this version
	if (s.versionNumeric ~= HMR.versionNumeric) then
		-- Check saved data version number. If it does not match current add-on version
		-- number, delete the "currentData" from it
		for key, value in pairs(saveDefaults.currentData) do
			SV.currentData[key] = value
		end

		-- Update the saved version
		s.versionNumeric = HMR.versionNumeric
	end

	-- Check if the last viewed (cleared) notification is less than the current version
	if (SV.lastNotificationViewed == nil) or (SV.lastNotificationViewed < HMR.versionNumeric) or (HMR.debugActive == true) then
		HMR.CreateNotification()
	end

	HMR.unitName = GetUnitDisplayName("player")

	-- Save the original center screen announcement function
	---@diagnostic disable-next-line: undefined-field --REMOVE
	OriginalCenterAnnouncement = CENTER_SCREEN_ANNOUNCE.AddMessageWithParams

	-- create group unit tags for faster use later (no string concatenation later)
	for i = 1, GROUP_SIZE_MAX do
		HMR.unitTags[i] = "group" .. tostring(i)
	end

	-- create boss unit tags for faster use later (no string concatenation later)
	for i = 1, MAX_BOSSES do
		HMR.bossUnitTags[i] = "boss" .. tostring(i)
	end

	if (HMR.debugActive == true) and (HMR.testBossData ~= nil) then
		testFlag = true
		for bossName, boss in pairs(HMR.testBossData) do
			HMR.bossData[bossName] = boss
			table.insert(testData, bossName)
		end
	end

	-- create an index for quickly looking up zone bosses
	-- This isn't hard coded for a few reasons, such as a lower memory footprint. (The boss objects
	-- will be stored by reference)
	for _, boss in pairs(HMR.bossData) do
		if (bossZoneIdIndex[boss.zoneId] == nil) then
			bossZoneIdIndex[boss.zoneId] = {}
		end

		table.insert(bossZoneIdIndex[boss.zoneId], boss)
	end


	SLASH_COMMANDS["/hmr"] = HMR.HandleSlashCommand

	HMR.SettingsMenu.CreateSettingsMenu()

	-- Create the UI fragments
	mainPanelFragment = ZO_HUDFadeSceneFragment:New(HMRUI, 0, 0)
	warningPanelFragment = ZO_HUDFadeSceneFragment:New(HMRWARNINGUI, 0, 0)
	uTest = HMR.unitName

	-- Get handles to the scenes. Done this way to keep the IDE happy
	---@class ZO_Scene
	hudScene = SM:GetScene("hud")
	---@class ZO_Scene
	huduiScene = SM:GetScene("hudui")

	HMR.RepositionUI() -- load saved location
	HMR.HideUi()
	HMR.LockUi()

	-- Set up the close UI button
	HMRUI_CloseBox:SetHidden(not SV.options.uiShowCloseButton)

	EM:RegisterForEvent(HMR.name .. "OnPlayerActivated", EVENT_PLAYER_ACTIVATED, HMR.OnPlayerActivated)
	EM:RegisterForEvent(HMR.name .. "OnPlayerDeactivated", EVENT_PLAYER_DEACTIVATED, HMR.OnPlayerDeactivated)
	EM:RegisterForEvent(HMR.name .. "OnScreenResized", EVENT_SCREEN_RESIZED, HMR.OnScreenResized)
	EM:RegisterForEvent(HMR.name .. "OnDifficultyChanged", EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, HMR.OnDifficultyChanged)
	EM:RegisterForEvent(HMR.name .. "OnActivityFinderStatusUpdate", EVENT_ACTIVITY_FINDER_STATUS_UPDATE, HMR.OnActivityFinderStatusUpdate)
	EM:RegisterForEvent(HMR.name .. "OnGroupUpdate", EVENT_GROUP_UPDATE, HMR.OnGroupUpdate)
end

local function OnAddOnLoaded(event, addonName)
    if (addonName == HMR.name) then
        EM:UnregisterForEvent(HMR.name, EVENT_ADD_ON_LOADED)
        HMR.Initialize()
    end
end

EM:RegisterForEvent(HMR.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
