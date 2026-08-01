------------------------------------------------------------------
--FCOAccessibility.lua
--Author: Baertram
------------------------------------------------------------------

--Global addon variable
FCOAB = {}
local FCOAB = FCOAB

--Addon variables
FCOAB.addonVars                            = {}
FCOAB.addonVars.gAddonName                 = "FCOAccessibility"
FCOAB.addonVars.addonNameMenu              = "FCO Accessibility"
FCOAB.addonVars.addonNameMenuDisplay       = "|c00FF00FCO |cFFFF00Accessibility|r"
FCOAB.addonVars.addonAuthor                = '|cFFFF00Baertram|r'
FCOAB.addonVars.addonVersionOptions        = '2.3' -- version shown in the settings panel
FCOAB.addonVars.addonSavedVariablesName    = "FCOAccessibility_Settings"
FCOAB.addonVars.addonSavedVariablesVersion = 0.02 -- Changing this will reset SavedVariables!
FCOAB.addonVars.gAddonLoaded               = false
local addonVars                            = FCOAB.addonVars
local addonName                            = addonVars.gAddonName

--Libraries
-- Create the addon settings menu
local LAM = LibAddonMenu2
local FCOABSettingsPrefixStr = addonName .. " setting %q changed to: "
local GPS = LibGPS3

--ESO game variables
local myDisplayName = GetDisplayName()

--local lua and game functions
local tos = tostring
local tins = table.insert
local tsort = table.sort
local strfor = string.format

local atan2 = math.atan2
local deg = math.deg
local pi = math.pi


--Local game global speed up variables
local CM = CALLBACK_MANAGER
local EM = EVENT_MANAGER
local soundsRef = SOUNDS

--local game functions
--local iigpm = IsInGamepadPreferredMode
local gmpw = GetMapPlayerWaypoint
local gmrp = GetMapRallyPoint

local CON_NONE       = "NONE"
local CON_SOUND_NONE = soundsRef[CON_NONE]

local CON_PLAYER = "player"
local CON_RETICLE = "reticleover"
local CON_RETICLE_PLAYER = "reticleoverplayer"
local CON_COMPANION = "companion"

local CON_CRITTER_MAX_HEALTH = 1

local CON_NUM_TARGET_MARKERS = TARGET_MARKER_TYPE_EIGHT
local mapSceneKeyboard = WORLD_MAP_SCENE
local mapSceneGamepad  = GAMEPAD_WORLD_MAP_SCENE

--Chat output priroties. Hgher values will be shown more early
--[[
local CON_PRIO_CHAT_LOW = 					1
local CON_PRIO_CHAT_MEDIUM = 				2
local CON_PRIO_CHAT_HIGH = 					3
local CON_PRIO_CHAT_COMBAT_ENEMY_HEALTH =	50
local CON_PRIO_CHAT_COMBAT_YOUR_HEALTH =	51
local CON_PRIO_CHAT_COMBAT_TIP =			59
local possibleChatPriorities = {
	CON_PRIO_CHAT_LOW,
	CON_PRIO_CHAT_MEDIUM,
	CON_PRIO_CHAT_HIGH,
	CON_PRIO_CHAT_COMBAT_ENEMY_HEALTH,
	CON_PRIO_CHAT_COMBAT_YOUR_HEALTH,
	CON_PRIO_CHAT_COMBAT_TIP,
}
local chatPriorityToDelay    = {
	[CON_PRIO_CHAT_LOW]					= 20, --chat high delay
	[CON_PRIO_CHAT_MEDIUM]				= 10, --chat medium delay
	[CON_PRIO_CHAT_HIGH]				= 5, --chat small delay
	[CON_PRIO_CHAT_COMBAT_ENEMY_HEALTH]	= 1, --very small delay
	[CON_PRIO_CHAT_COMBAT_YOUR_HEALTH]	= 2, --really small delay
	[CON_PRIO_CHAT_COMBAT_TIP] 			= 0, --no delay
}
local chatOutputQueue        = {}
]]


--Control names of ZO* standard controls etc.
FCOAB.zosVars                              = {}
local zosVars = FCOAB.zosVars
zosVars.compass = COMPASS
local compass = zosVars.compass
zosVars.compassCenterOverPinLabel = compass.centerOverPinLabel
local compassCenterOverPinLabel = zosVars.compassCenterOverPinLabel


--Settings
FCOAB.settingsVars					= {}
FCOAB.settingsVars.settings 		= {}
FCOAB.settingsVars.defaultSettings	= {}

--Prevention booleans
FCOAB.preventerVars = {}

--Constants
local soundNames = {}
local soundNamesInternal = {}
for soundName, _ in pairs(soundsRef) do
    if soundName ~= CON_NONE then
        tins(soundNames, soundName)
    end
end
tsort(soundNames)
if #soundNames <= 0 then
    d("[".. FCOAB.addonVars.addonNameMenuDisplay .. "] ERROR No sounds could be found - AddOn won't work properly!")
    return
end
--Insert "NONE" as first sound
tins(soundNames, 1, CON_NONE)
--Build the lookup table of the internal soundNames to the sound KEY value
for soundIndex, soundName in ipairs(soundNames) do
	soundNamesInternal[soundsRef[soundName]] = soundName
end

local playerWaypointPinTypes = {
	[MAP_PIN_TYPE_PLAYER_WAYPOINT] = true,
}
local groupRallyPointPinTypes = {
	[MAP_PIN_TYPE_RALLY_POINT] = true,
}
local trackedQuestPinTypes = {
	[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = true, --19
	[MAP_PIN_TYPE_TRACKED_QUEST_ENDING]= true, --21
	[MAP_PIN_TYPE_TRACKED_QUEST_OFFER_ZONE_STORY] = true, --37
	[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = true, --20
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION] = true, --22
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING] = true, --24
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = true, --23
	[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_CONDITION] = true, --25
	[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_ENDING] = true, --27
	[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = true, --26
}
local assistedQuestPinTypes  = {
	[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = true, --10
	[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = true, --12
	[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = true, --11
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION] = true, --13
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING] = true, --15
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = true, --14
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION] = true, --16
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING] = true, --18
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = true, --17
}
local companionPinTypes = {
	[MAP_PIN_TYPE_ACTIVE_COMPANION] = true,
}
local groupPinTypes = {
	[MAP_PIN_TYPE_GROUP] = true
}
local groupLeaderPinTypes = {
	[MAP_PIN_TYPE_GROUP_LEADER] = true
}
local rallyPointPinTypes = {
	[MAP_PIN_TYPE_RALLY_POINT] = true
}
local mapPinTypeToCompassText = {
	[MAP_PIN_TYPE_QUEST_COMPLETE] = "Quest complete",
	[MAP_PIN_TYPE_QUEST_CONDITION] = "Quest condition",
	[MAP_PIN_TYPE_QUEST_ENDING] = "Quest ending",
	--[MAP_PIN_TYPE_QUEST_GIVE_ITEM] = "Quest item",
	[MAP_PIN_TYPE_QUEST_INTERACT] = "Quest interact",
	[MAP_PIN_TYPE_QUEST_OFFER] = "Quest offer",
	[MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE] = "Quest offer repeatable",
	[MAP_PIN_TYPE_QUEST_OFFER_ZONE_STORY] = "Quest offer zone story",
	[MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION] = "Optional quest condition",
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION] = "Quest zone story condition",
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING] = "Quest zone story ending",
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = "Quest zone story optional condition",
	[MAP_PIN_TYPE_QUEST_TALK_TO] = "Quest talk to",
}
local targetMarkerPinTypes = {
	[MAP_PIN_TYPE_TARGET_MARKER_TYPE_ONE] = true,
	[MAP_PIN_TYPE_TARGET_MARKER_TYPE_TWO] = true,
	[MAP_PIN_TYPE_TARGET_MARKER_TYPE_THREE] = true,
	[MAP_PIN_TYPE_TARGET_MARKER_TYPE_FOUR] = true,
	[MAP_PIN_TYPE_TARGET_MARKER_TYPE_FIVE] = true,
	[MAP_PIN_TYPE_TARGET_MARKER_TYPE_SIX] = true,
	[MAP_PIN_TYPE_TARGET_MARKER_TYPE_SEVEN] = true,
	[MAP_PIN_TYPE_TARGET_MARKER_TYPE_EIGHT] = true,
}

local autoRemoveWaypointEventName = addonName .. "_AutoRemoveWaypoint"
local groupLeaderPosEventName = addonName .. "_GroupLeaderPos"
local autoRemovePlayerMovingEventName = addonName .. "_IsPlayerMoving"

--Sring comparison variables
--[[
SafeAddString(SI_TOOLTIP_UNIT_MAP_PING, "Kartensignal: <<C:1>>", 0)
SafeAddString(SI_TOOLTIP_UNIT_MAP_PLAYER_WAYPOINT, "Euer gesetztes Ziel", 0)
SafeAddString(SI_TOOLTIP_UNIT_MAP_RALLY_POINT, "Gruppentreffpunkt", 0)
]]
local compassbaseStr = "Compass"
local yourPlayersWaypointStr = GetString(SI_TOOLTIP_UNIT_MAP_PLAYER_WAYPOINT) -- Player waypoint text at the compass
local rallyPointStr = GetString(SI_TOOLTIP_UNIT_MAP_RALLY_POINT) --Group rally point
local groupStr = GetString(SI_PLAYERS_MET_TITLE_GROUP) -- Group
local groupLeaderStr = GetString(SI_GROUP_LEADER_TOOLTIP) --Group leader
local companionStr = GetString(SI_UNIT_FRAME_NAME_COMPANION)

--Variables for the compass checks
--local lastCompassCenterOverPinLabeltext
local CreateCompassHooks
local noCompassPinSelected = true
local lastTrackedQuestIndex, lastTrackedQuestName, lastTrackedQuestBackgroundText, lastTrackedQuestActiveStepText
local lastPlayed = {
	--Sounds
	waypoint = 0,
	rallyPoint = 0,
	quest = 0,
	groupLeader = 0,
	groupLeaderClockPosition = 0,
	playerNotMoving = 0,

	--Chat
	compass2Chat = 0,
	reticle2Chat = 0,
	reticleInteraction2Chat = 0,
}
local lastDistanceToGroupLeader = 0
local lastGroupLeaderClockPosition = 0

local lastAddedToChat
local compassToChatDelay = 250

local lastAddedReticleToChat = {
	name = nil,
	caption = nil,
}
local lastAddedInteractionReticleToChat = {
	action = nil,
	interactableName = nil,
	interactionBlocked = nil,
	isOwned = nil,
	additionalInteractInfo = nil,
	context = nil,
	contextLink = nil,
	isCriminalInteract = nil,
	chatText = nil,
}

local reticleToChatDelay = 500
local reticleInteractionToChatDelay = 500

FCOAB.groupLeaderData = {}
local groupLeaderData = FCOAB.groupLeaderData

local combatTips = {
		--The table key is the tipId
		-- Priority: BLOCK -> OFF BALANCE -> INTERRUPT -> DODGE
		[1] = {key = "block", 		tipId = 1, label = "BLOCK"},
		[2] = {key = "offBalance", 	tipId = 2, label = "OFF BALANCE"},
		[3] = {key = "interrupt", 	tipId = 3, label = "INTERRUPT"},
		[4] = {key = "dodge", 		tipId = 4, label = "DODGE"}
}

local alreadyInteractedNPCNames    = {}
local reticleOverLastHealthPercent = 0
local reticleOverChangedEventRegistered = false
local reticleOverPlayerChangedEventRegistered = false
local combatEventRegistered = false

local hitTargetsUnitIds = {}
local hitTargetsNames = {}
local targetMarkersApplied = {}
local targetMarkersNumbersApplied = {}
--FCOAB._hitTargetsUnitIds = hitTargetsUnitIds
--FCOAB._hitTargetsNames = hitTargetsNames
--FCOAB._targetMarkersApplied = targetMarkersApplied
--FCOAB._targetMarkersNumbersApplied = targetMarkersNumbersApplied

local hadLastCombatAnyChatMessage = false
local wasNarrationQueueCleared = false

local fcoabGamepadMapActionLayerFragment


--===================== FUNCTIONS ==============================================
--[[
local function startsWith(strToSearch, searchFor)
	if string.find(strToSearch, searchFor, 1, true) ~= nil then
		return true
	end
	return false
end
]]

local function getPercent(powerValue, powerMax)
	return zo_round((powerValue / powerMax) * 100)
end

local function getClockPositionByAngle(angle_degrees)
	if angle_degrees == nil or angle_degrees > 360 then return end
	local clockHand = (360 - angle_degrees) / 30 --each hour relates to 30°
	clockHand = zo_clamp(clockHand, 1, 12)
	return zo_round(clockHand)
end

local function getDirectionQuarterByAngle(angle_degrees)
	if angle_degrees == nil or angle_degrees > 360 then return end
	local clockHand = (360 - angle_degrees) / 30 --each hour relates to 30°
	local groupLeaderClockPos = zo_clamp(clockHand, 1, 12)
	if groupLeaderClockPos == nil then return end
	local directionQuarter
	if groupLeaderClockPos >= 7.5 and groupLeaderClockPos < 10.5 then
		directionQuarter = "west"
	elseif (groupLeaderClockPos >= 1 and groupLeaderClockPos < 1.5) or (groupLeaderClockPos >= 10.5 and groupLeaderClockPos <= 12) then
		directionQuarter = "north"
	elseif groupLeaderClockPos >= 1.5 and groupLeaderClockPos < 4.5 then
		directionQuarter = "east"
	elseif groupLeaderClockPos >= 4.5 and groupLeaderClockPos < 7.5 then
		directionQuarter = "south"
	end
--d("[FCOAB]getDirectionQuarterByAngle: " .. tos(groupLeaderClockPos) .. "; directionQuarter: " ..tos(directionQuarter))
	return directionQuarter
end


--[[
local function getPrioChatTextsAndOutputSorted(priority)
	if priority == nil then return end

	FCOAB._chatOutputByPrioSorted = {}
	FCOAB._chatOutputQueue = chatOutputQueue
	FCOAB._chatOutputResults = {}


	local chatOutputByPrio = chatOutputQueue[priority]
	if chatOutputByPrio ~= nil and NonContiguousCount(chatOutputByPrio) > 0 then
		local chatOutputByPrioSorted = {}
		for timeStamp, _ in pairs(chatOutputByPrio) do
			chatOutputByPrioSorted[#chatOutputByPrioSorted + 1] = timeStamp
		end
		table.sort(chatOutputByPrioSorted)
		if chatOutputByPrioSorted ~= nil and #chatOutputByPrioSorted > 0 then
			for _, timeStamp in ipairs(chatOutputByPrioSorted) do
				--d(chatOutputByPrio[timeStamp])
				--chatOutputByPrio[timeStamp] = nil
				tins(FCOAB._chatOutputResults, chatOutputByPrio[timeStamp])
			end
		end
		FCOAB._chatOutputByPrioSorted[priority] = chatOutputByPrioSorted
	end
end

local function doPriorizedChatOutput()
	for _, priorityForOutput in ipairs(possibleChatPriorities) do
		getPrioChatTextsAndOutputSorted(priorityForOutput)
	end
end
FCOAB.DoPriorizedChatOutput = doPriorizedChatOutput


local function priorizeChatOutput(chatMessage, priority)
	chatOutputQueue[priority] = chatOutputQueue[priority] or {}
	chatOutputQueue[priority][GetGameTimeMilliseconds()] = chatMessage
end

local function addToChatWithPrefix(chatMsg, prefixText, priority, adHoc)
	if chatMsg == nil or chatMsg == "" then return end
	prefixText = prefixText or FCOAB.settingsVars.settings.chatAddonPrefix
	priority = priority or CON_PRIO_CHAT_LOW
	adHoc = adHoc or false
	if priority == CON_PRIO_CHAT_COMBAT_TIP then adHoc = true end

	--if prefixText ~= nil and prefixText ~= "" then
	if adHoc == true then
		d(prefixText .. chatMsg)
	else
		local delay = chatPriorityToDelay[priority]
		zo_callLater(function()
			priorizeChatOutput(prefixText .. chatMsg, priority)
		end, delay)
	end
	--end
end
]]

local function addToChatWithPrefix(chatMsg, prefixText, forceNoPrefix)
	if chatMsg == nil or chatMsg == "" then return end
	forceNoPrefix = forceNoPrefix or false
	if not forceNoPrefix then
		prefixText = prefixText or FCOAB.settingsVars.settings.chatAddonPrefix
	else
		prefixText = ""
	end
	--if priority == CON_PRIO_CHAT_COMBAT_TIP then adHoc = true end

	--if prefixText ~= nil and prefixText ~= "" then
	--ClearActiveNarration() --stop current narration

	ClearNarrationQueue(NARRATION_TYPE_TEXT_CHAT)

	d(prefixText .. chatMsg)
	--end
end

local function outputLAMSettingsChangeToChat(chatMsg, prefixText, doOverride)
	doOverride = doOverride or false
	if FCOAB.settingsVars.settings.thisAddonLAMSettingsSetFuncToChat == false and not doOverride then return end
	addToChatWithPrefix(chatMsg, strfor(FCOABSettingsPrefixStr, prefixText))
end

local function enableActiveCombatTipsIfDisabled()
	--Activate combat tips. Set them to "Always show"
	SetSetting(SETTING_TYPE_ACTIVE_COMBAT_TIP, 0, ACT_SETTING_ALWAYS)
end

local function isAccessibilitySettingEnabled(settingId)
	return GetSetting_Bool(SETTING_TYPE_ACCESSIBILITY, settingId)
end

local function getAccessibilitySetting(settingId)
	return GetSetting(SETTING_TYPE_ACCESSIBILITY, settingId)
end

local function changeAccessibilitSettingTo(newState, settingId)
	SetSetting(SETTING_TYPE_ACCESSIBILITY, settingId, newState)
end

local function isAccessibilityModeEnabled()
	return isAccessibilitySettingEnabled(ACCESSIBILITY_SETTING_ACCESSIBILITY_MODE)
end

local function getAccessibilityNarrationVolume()
	if isAccessibilityModeEnabled() then
		return getAccessibilitySetting(ACCESSIBILITY_SETTING_NARRATION_VOLUME)
	end
	return nil
end

local function updateCurrentAccesibilityNarrationVolume()
	local currentNarrationVolume = getAccessibilityNarrationVolume()
	if currentNarrationVolume ~= nil then
		FCOAB.settingsVars.settings.ESOaccessibilityFix_LastNarrationVolume = currentNarrationVolume
	end
end

--[[
local function directlyReadOrAddToChat(msgText, prio)
	--Directly play the message so there is no delay!
	if isAccessibilityModeEnabled() and isAccessibilitySettingEnabled(ACCESSIBILITY_SETTING_TEXT_CHAT_NARRATION) then
		--Using this somehow makes the chat reader stop all of sudden in fight
		RequestReadTextChatToClient(msgText)
	else
		addToChatWithPrefix(msgText, nil, prio)
	end
end
]]

local function playSoundLoopNow(soundToPlay, soundRepeats)
	local soundName = soundNamesInternal[soundToPlay]
--d("[FCOAB]PlaySound: " ..tos(soundName) .. ", volumeIncrease: " ..tos(soundRepeats))
	if not soundToPlay or not soundsRef[soundName] then return false end
	soundRepeats = soundRepeats or 1
	local wasPlayed = false
    for i=1, soundRepeats, 1 do
		--Play the sound (multiple times will play it louder)
		PlaySound(soundsRef[soundName])
        wasPlayed = true
	end
--d("<wasPlayed: " ..tos(wasPlayed))
    return wasPlayed
end

local function showCombatTipInChat(tipId)
	if tipId == nil or tipId <= 0 or
		not FCOAB.settingsVars.settings.combatTipToChat then return end
	--Hide ZOs alert? -->Should not be needed for visibly impaired players
	--ZO_ActiveCombatTips:SetHidden(true)
	local tipData = combatTips[tipId]
	if tipData == nil then return end
	hadLastCombatAnyChatMessage = true

	--directlyReadOrAddToChat(tipData.label, CON_PRIO_CHAT_COMBAT_TIP)
	addToChatWithPrefix(tipData.label, nil)

	local settings = FCOAB.settingsVars.settings
	if settings.combatTipSound == true then
		local soundToPlay = settings.combatTipSoundName[tipId]
		local soundRepeats = settings.combatTipSoundRepeat[tipId]
		if soundToPlay ~= nil and soundRepeats ~= nil then
			playSoundLoopNow(soundToPlay, soundRepeats)
		end
	end
end

local function getCompassChatText(newText)
	local compassStr = compassbaseStr

	--Checks with the pintype
	local bestPinType = FCOAB._bestPinType
	if bestPinType ~= nil then
		if IsUnitGrouped(CON_PLAYER) then
			if groupLeaderPinTypes[bestPinType] then
				return compassStr .. " " .. groupLeaderStr .. ": "
			elseif groupPinTypes[bestPinType] then
				return compassStr .. " " .. groupStr .. ": "
			end
		end
		if companionPinTypes[bestPinType] then
			return compassStr .. " " .. companionStr .. ": "
		elseif rallyPointPinTypes[bestPinType] then
			return compassStr .. ": "
		end

		local questCompassText = mapPinTypeToCompassText[bestPinType]
		if questCompassText ~= nil then
			return compassStr .. " " .. questCompassText .. ": "
		end
	end

	--Checks without the pinType
	if IsUnitGrouped(CON_PLAYER) then
		--RallyPoint of group?
		if newText == rallyPointStr then
			--Do nothing, the "Rally point" string will be added automatically from the compass pin's text
		elseif newText == ZO_CachedStrFormat(SI_UNIT_NAME, GetUnitName(GetGroupLeaderUnitTag())) then
			compassStr = compassStr .. " " .. groupLeaderStr
		end
	end
	return compassStr .. ": "
end


local function hasWaypoint()
	local offsetX, offsetY = gmpw()
	return offsetX ~= 0 or offsetY ~= 0
end

local function hasRallyPoint()
	local offsetX, offsetY = gmrp()
	return offsetX ~= 0 or offsetY ~= 0
end

local function calculateLayerInformedDistance(drawLayer, drawLevel)
	return (1.0 - (drawLevel / 0xFFFFFFFF)) - drawLayer
end

local function isWayPointItAutoRemoveWaypointEnabled()
	if WAYPOINTIT == nil or (WAYPOINTIT ~= nil and WAYPOINTIT.sv == nil) then return false end
	if not WAYPOINTIT.sv["AUTO_REMOVE_WAYPOINT"] then return false end
	return true
end

local function isWaypointSetAndShouldBeRemovedAutomaticallyByFCOAB()
	return (FCOAB.settingsVars.settings.autoRemoveWaypoint and not IsUnitDead(CON_PLAYER) and not isWayPointItAutoRemoveWaypointEnabled()) and hasWaypoint()
end

local function checkUnitIsOnlineAndInSameIniAndWorld(unitTag)
	local isUnitOnlineAndInSameWorldEtc = false
	if unitTag == nil or unitTag == "" or unitTag == CON_PLAYER then return false end

	local doesUnitExist = DoesUnitExist(unitTag)
	local isOnline = IsUnitOnline(unitTag)
	local inSameInstance = IsGroupMemberInSameInstanceAsPlayer(unitTag)
	local inSameWorld = IsGroupMemberInSameWorldAsPlayer(unitTag)
	local inSameLayer = IsGroupMemberInSameLayerAsPlayer(unitTag)
	isUnitOnlineAndInSameWorldEtc = (doesUnitExist and isOnline and inSameInstance and inSameWorld and inSameLayer and true) or false
	if isUnitOnlineAndInSameWorldEtc == false then
		if not inSameWorld and not inSameLayer and doesUnitExist and isOnline then
			--Check if the group leader is in the same parent zone (inside a delve of the zone e.g.)
			local zoneIndexOfUnit = GetUnitZoneIndex(unitTag)
			local parentZoneId = GetParentZoneId(zoneIndexOfUnit)
			local zoneIndexOfPlayer    = GetCurrentMapZoneIndex()
			local parentZoneIdOfPlayer = GetParentZoneId(zoneIndexOfPlayer)
			if zoneIndexOfPlayer == zoneIndexOfUnit or (parentZoneIdOfPlayer > 0 and parentZoneId > 0 and parentZoneIdOfPlayer == parentZoneId) then
				isUnitOnlineAndInSameWorldEtc = true
			end
		end
	end
--d("[FCOAB]checkIfUnitOnlineEtc - unitTag: " ..tos(unitTag) .. ", result: " ..tos(isUnitOnlineAndInSameWorldEtc))
	return isUnitOnlineAndInSameWorldEtc
end

local function isGroupedAndGroupLeaderGivenAndShouldSoundPlayByFCOAB()
	if FCOAB.settingsVars.settings.groupLeaderSound == false then return false end

	groupLeaderData = {}
	local isNotDeadAndIsGrouped = (not IsUnitDead(CON_PLAYER) and IsUnitGrouped(CON_PLAYER) and true) or false
	local groupLeaderNotMeAndGivenAndOnlineAndInZone = false
	if isNotDeadAndIsGrouped == true then
		local groupLeaderUnitTag = GetGroupLeaderUnitTag()
		if groupLeaderUnitTag ~= nil and groupLeaderUnitTag ~= "" then
			--Check that we arent't the group leader
			local groupLeaderDisplayName = GetUnitDisplayName(groupLeaderUnitTag)
			if myDisplayName ~= groupLeaderDisplayName then
				groupLeaderNotMeAndGivenAndOnlineAndInZone = checkUnitIsOnlineAndInSameIniAndWorld(groupLeaderUnitTag)
				if groupLeaderNotMeAndGivenAndOnlineAndInZone == true then
					groupLeaderData = {
						unitTag = groupLeaderUnitTag
					}
				end
			end
		end
	end
--d("[FCOAB]isGroupedEtc - notDead&Grouped: " ..tos(isNotDeadAndIsGrouped) ..", leaderInZone: " ..tos(groupLeaderNotMeAndGivenAndOnlineAndInZone))
	return isNotDeadAndIsGrouped and groupLeaderNotMeAndGivenAndOnlineAndInZone
end

--Code exmaples taken from Circonian's WayPointIt: Many thanks!
local function canProcessMap()
	if GPS:IsMeasuring() then
		return false
	end
	-- cant get coordinates from the cosmic map
	--if GetMapType() == MAPTYPE_COSMIC then
	if ZO_WorldMap_IsWorldMapShowing() then
		return true
	end
	if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
		CM:FireCallbacks("OnWorldMapChanged")
	end
	--end
	return DoesUnitExist(CON_PLAYER)
end


local function getDistanceToLocalCoords(locX, locY, playerOffsetX, playerOffsetY)
	-- if not on cosmic map or we reset it to player location
	if not canProcessMap() then
		return 0, false
	end

	local locX, locY = GPS:LocalToGlobal(locX, locY)
	if not playerOffsetX then
		playerOffsetX, playerOffsetY = GPS:LocalToGlobal(GetMapPlayerPosition(CON_PLAYER))
	end

	local gameUnitDistance = GPS:GetGlobalDistanceInMeters(locX, locY, playerOffsetX, playerOffsetY)

	-- 11,000 steps per unit, stride length 3.5 feet per step -- No longer calculated this way
	-- Strike that, changing calculations to match ability grey out distance/range
	-- 15000 * 5.6 = 84000 and feet to meters: 84000 * 0.3048 = 25603.2
	return math.floor(gameUnitDistance * 1) --distance in meters, in feet the multiplier would be: 3.28084
end

local function isWaypointOutsideOfRemovalDistance(xLoc, yLoc)
	local settings = FCOAB.settingsVars.settings
	local pinDeltaMin, pinDeltaMax, distToCoords = settings.WAYPOINT_DELTA_SCALE, settings.WAYPOINT_DELTA_SCALE_MAX, getDistanceToLocalCoords(xLoc, yLoc)

	return distToCoords > pinDeltaMin and distToCoords < pinDeltaMax
end

-- RegisterUpdate function to check current loc vs waypoint loc
-- Used for Automatically removing waypoints local function CheckWaypointLoc()
local isWaypointRemoveUpdateEventActive = false
local isGroupLeaderUpdateEventActive = false
local isTryingToMoveButBlockedUpdateEventActive = false

local runWaypointRemoveUpdates, runGroupLeaderUpdates, runTryingToMoveButBlockedUpdates

local function checkWaypointLoc()
	-- if not on cosmic map or we reset it to player location
	if not canProcessMap() then
		return
	end

	--[[ If somehow the waypoint no longer exists...but it was not caught in the OnMapPing remove event, remove it now & stop the updates.
	There was a particular instance when this was happening, which is why I added it...but I don't remember what it was now. Maybe it was just a bug...better safe than sorry though.
	--]]
	local waypointOffsetX, waypointOffsetY = gmpw()
	if waypointOffsetX == 0 and waypointOffsetY == 0 then
		runWaypointRemoveUpdates(false, nil)
		--runHeadingUpdates(false)
		FCOAB.settingsVars.settings.currentWaypoint = nil
		return
	end

	-- coordinates get converted to global, so distances are consistent
	-- accross all maps.
	if not isWaypointOutsideOfRemovalDistance(waypointOffsetX, waypointOffsetY) then
		--[[
		local waypoint = settings.currentWaypoint
		local setBy = (waypoint and waypoint.setBy) or "n/a"

		if (setBy == "rowClick" and self.sv["WAYPOINT_MESSAGES_USER_DEFINED"]) or (setBy == "autoQuest" and self.sv["WAYPOINT_MESSAGES_AUTO_QUEST"]) then
			CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATECORY_SMALL_TEXT, SOUNDS.ACHIEVEMENT_AWARDED, GetString(SI_WAYPOINTIT_WAYPOINT_REACHED))
		end
		]]

		--Remove the waypoint
		ZO_WorldMap_RemovePlayerWaypoint() --use this to remove the pin on the worldmap too! will internally call RemovePlayerWaypoint()
	end
end

runWaypointRemoveUpdates = function (doEnable, forced)
	--d("[FCOAB]runWaypointRemoveUpdates - doEnable: " ..tos(doEnable) .. ", forced: " ..tos(forced))
	if doEnable and (forced or FCOAB.settingsVars.settings.autoRemoveWaypoint) then
		isWaypointRemoveUpdateEventActive = true
		EM:RegisterForUpdate(autoRemoveWaypointEventName, 50,
				function() checkWaypointLoc() end
		)
	else
		isWaypointRemoveUpdateEventActive = false
		EM:UnregisterForUpdate(autoRemoveWaypointEventName)
	end
end

local function checkIsPlayerTryingToMove()
	--Is the player dead? Disable checks -> Handled via event_player_dead and event_player_alive
	--Player is actually not moving but it's tried to move? -> We are stuck (most probably)
	local isPlayerMoving = IsPlayerMoving()
--d(">>>>>IsPlayerTryingToMove-moving: " ..tos(isPlayerMoving) .. ", trying: " ..tos(IsPlayerTryingToMove()) .. ", stunned: " .. tos(IsPlayerStunned()))
	if isPlayerMoving == false and IsPlayerTryingToMove() == true then
		--Player is stunned?
		if IsPlayerStunned() == true then
			lastPlayed.playerNotMoving = 0
		else
			--Are we interacting somehow?
			if IsInteracting() == true then
				lastPlayed.playerNotMoving = 0
			else
				local settings = FCOAB.settingsVars.settings
				--Play the trying to move but blocked sound
				local now = GetGameTimeMilliseconds()
				local lastPlayedPlayerNotMoving = lastPlayed.playerNotMoving
				local waitTime = 3000 --settings.tryingToMoveButBlockedSoundDelay * 1000

				if lastPlayedPlayerNotMoving == 0 or now >= (lastPlayedPlayerNotMoving + waitTime) then
					lastPlayed.playerNotMoving = now
					playSoundLoopNow(settings.tryingToMoveButBlockedSoundName, settings.tryingToMoveButBlockedSoundRepeat)
				end
			end
		end
	elseif isPlayerMoving then
		lastPlayed.playerNotMoving = 0
	end
end

runTryingToMoveButBlockedUpdates = function(doEnable, forced)
--d("[FCOAB]runTryingToMoveButBlockedUpdates - doEnable: " ..tos(doEnable) .. ", forced: " ..tos(forced))
	if doEnable and (forced or FCOAB.settingsVars.settings.tryingToMoveButBlockedSound) then
		isTryingToMoveButBlockedUpdateEventActive = true
		EM:RegisterForUpdate(autoRemovePlayerMovingEventName, 3000,
				function() checkIsPlayerTryingToMove() end
		)
	else
		isTryingToMoveButBlockedUpdateEventActive = false
		EM:UnregisterForUpdate(autoRemovePlayerMovingEventName)
	end
end


local function OnTryHandlingInteraction(reticleObj, interactionPossible, currentFrameTimeSeconds)
	if not interactionPossible then return false end
	local settings = FCOAB.settingsVars.settings
	if settings.reticleInteractionToChatText == false then return false end

	local reticleToChatInCombat = settings.reticleToChatInCombat
	local isInCombat = IsUnitInCombat(CON_PLAYER)
	if isInCombat == true and reticleToChatInCombat == false then return end

	local reticleToChatInteractionDisableInGroup = settings.reticleToChatInteractionDisableInGroup
	local isGrouped = IsUnitGrouped(CON_PLAYER)
	if isGrouped == true and reticleToChatInteractionDisableInGroup == true then return end

	local now = GetGameTimeMilliseconds()
	local lastReticleInteraction2Chat = lastPlayed.reticleInteraction2Chat
	if lastReticleInteraction2Chat == 0 or now >= (lastReticleInteraction2Chat + reticleInteractionToChatDelay) then
		lastPlayed.reticleInteraction2Chat = now

		local action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract = GetGameCameraInteractableActionInfo()
		if interactionBlocked == true then
			lastPlayed.reticleInteraction2Chat = 0
			return
		end --Do not show BLOCKED messages

		--if additionalInteractInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE and not interactionBlocked then
		if action == nil then
			lastAddedInteractionReticleToChat = {
				action = nil,
				interactableName = nil,
				interactionBlocked = nil,
				isOwned = nil,
				additionalInteractInfo = nil,
				context = nil,
				contextLink = nil,
				isCriminalInteract = nil,
				chatText = nil,
			}
			return
		end
		--d(">action: " ..tos(action) .. ", additionalInteractInfo: " .. tos(additionalInteractInfo) .. ", interactableName: " ..tos(interactableName) .. ", interactionBlocked: " .. tos(interactionBlocked) .. ", isOwned: " .. tos(isOwned) .. ", context: " ..tos(context) .. ", contextLink: " ..tos(contextLink) .. ", isCriminal: " ..tos(isCriminalInteract))

		if action ~= lastAddedInteractionReticleToChat.action
				or interactableName ~= lastAddedInteractionReticleToChat.interactableName
				or interactionBlocked ~= lastAddedInteractionReticleToChat.interactionBlocked
				or isOwned ~= lastAddedInteractionReticleToChat.isOwned
				or additionalInteractInfo ~= lastAddedInteractionReticleToChat.additionalInteractInfo
				or context ~= lastAddedInteractionReticleToChat.context
				or contextLink ~= lastAddedInteractionReticleToChat.contextLink
				or isCriminalInteract ~= lastAddedInteractionReticleToChat.isCriminalInteract
		then
			lastAddedInteractionReticleToChat = {
				action = action,
				interactableName = interactableName,
				interactionBlocked = interactionBlocked,
				isOwned = isOwned,
				additionalInteractInfo = additionalInteractInfo,
				context = context,
				contextLink = contextLink,
				isCriminalInteract = isCriminalInteract,
			}
			local newText
			if action ~= "" then
				newText = action
				if interactionBlocked == true or isCriminalInteract == true then
					newText = newText .. " !"
					if interactionBlocked == true then
						newText = newText .. "BLOCKED"
					end
					if isCriminalInteract == true then
						if interactionBlocked == true then
							newText = newText .. ", "
						end
						newText = newText .. "CRIMINAL"
					end
					newText = newText .. "!"
				end
			end
			if interactableName ~= nil and interactableName ~= "" then
				newText = (newText == nil and "'" .. interactableName .. "'") or newText .. "'" .. interactableName .. "'"
			end
			if newText ~= nil and newText ~= "" and newText ~= lastAddedInteractionReticleToChat.chatText then
				lastAddedInteractionReticleToChat.chatText = newText
				addToChatWithPrefix("Interaction: " .. newText)
			end
		end
	end
end

local interactionPostHookDone = false
local function interactionData()
	local settings = FCOAB.settingsVars.settings
	if not interactionPostHookDone and settings.reticleInteractionToChatText == true then
		--SecurePostHook(FISHING_MANAGER, "StartInteraction", OnStartInteraction)
		ZO_PreHook(RETICLE, "TryHandlingInteraction", OnTryHandlingInteraction)

		interactionPostHookDone = true
	end
end


local function buildUnitChatOutputAndAddToChat(unitPrefix, unitSuffix, unitName, unitDisplayName, unitCaption, isReticle)
	isReticle = isReticle or false
	local newText = unitPrefix
	if unitDisplayName ~= nil and unitDisplayName ~= "" then
		newText = (newText == nil and "'" .. unitDisplayName .. '"') or newText .. " '" .. unitDisplayName .. "'"
	end
	if unitName ~= nil and unitName ~= "" then
		if unitDisplayName == nil then
			newText = (newText == nil and "'" .. unitName .. '"') or newText .. " '" .. unitName .. '"'
		else
			newText = (newText == nil and unitName) or newText .. " " .. unitName
		end
	end
	if unitCaption ~= nil and unitCaption ~= "" then
		newText = (newText == nil and ("<" .. unitCaption .. ">")) or newText .. " <" .. unitCaption ..">"
	end
	if unitSuffix ~= nil and unitSuffix ~= "" then
		newText = newText .. " " .. unitSuffix
	end
	if newText ~= nil and newText ~= "" then
		if isReticle == true then
			newText = "Reticle: " .. newText
		end
		addToChatWithPrefix(newText)
	end
end

local function getReticleOverUnitDataAndPrepareChatText(healthCurrent, healthMax, isPlayer)
	isPlayer = isPlayer or false
	local unitPrefix, unitSuffix, unitHealth
	local unitDisplayName
	local reticleVar = (isPlayer == true and CON_RETICLE_PLAYER) or  CON_RETICLE

	if DoesUnitExist(reticleVar) == false then return end

	local unitName = zo_strformat(SI_UNIT_NAME, GetUnitName(reticleVar))
	local unitCaption = zo_strformat(SI_UNIT_NAME, GetUnitCaption(reticleVar))
	local isDead = IsUnitDead(reticleVar)
	local isAttackable = IsUnitAttackable(reticleVar)
	local difficulty = GetUnitDifficulty(reticleVar)
	local unitReaction = GetUnitReaction(reticleVar)
	local unitReactionColortype = GetUnitReactionColorType(reticleVar)
	local currentHealth, maxHealth = healthCurrent, healthMax
	if currentHealth == nil or maxHealth == nil then
		currentHealth, maxHealth = GetUnitPower(reticleVar, COMBAT_MECHANIC_FLAGS_HEALTH)
	end

	local isInteractableMonster = IsGameCameraInteractableUnitMonster()

	--[[
		UNIT_TYPE_PLAYER	1
		UNIT_TYPE_MONSTER 	2
	]]
	local unitType = GetUnitType(reticleVar)
	local isOtherPlayer, isNPC, isCritter, isMonster = false, false, false, false

	--Player characters
	if isPlayer == true and unitType == UNIT_TYPE_PLAYER then
		isOtherPlayer = true
		unitDisplayName = GetUnitDisplayName(reticleVar)
		local isFriend = IsUnitFriend(reticleVar)
		if isFriend  then
			unitPrefix = "Friend"
		else
			local isGuildMate = false
			local guildIndex
			for idx=1, GetNumGuilds(), 1 do
				if guildIndex == nil and isGuildMate == false then
					local guildId = GetGuildId(idx)
					if guildId ~= nil then
						local guildMemberIndex = GetGuildMemberIndexFromDisplayName(guildId, unitDisplayName)
						if guildMemberIndex ~= nil and guildMemberIndex > 0 then
							guildIndex = idx
							isGuildMate = true
							break
						end
					end
				end
			end
			if isGuildMate == true then
				unitPrefix = strfor("Guild %s member", tos(guildIndex))
			else
				unitPrefix = "Player"
			end
		end

		local isGrouped = IsUnitGrouped(reticleVar)
		local settings = FCOAB.settingsVars.settings
		local class
		local race
		local gender
		local alliance
		local level
		local cp

		if settings.reticlePlayerClass == true then
			class = ZO_CachedStrFormat(SI_UNIT_NAME, GetUnitClass(reticleVar))
		end
		if settings.reticlePlayerRace == true then
			race = GetUnitRaceId(reticleVar)
			gender = GetUnitGender(reticleVar)

--d(">race: " ..tos(race) ..", gender: " ..tos(gender))
		end
		if settings.reticlePlayerLevel == true then
			alliance = GetUnitAlliance(reticleVar)
		end
		if settings.reticlePlayerAlliance == true then
			level = GetUnitLevel(reticleVar)
			cp = GetUnitEffectiveChampionPoints(reticleVar)
		end

		if isDead == true then
			if IsUnitBeingResurrected(reticleVar) == true then
				unitPrefix = unitPrefix .. " (actively ressurrected)"
			else
				unitPrefix = unitPrefix .. " (dead)"
			end
		end
		if isGrouped == true then
			unitPrefix = unitPrefix .. " (in a group)"
		end
		if class ~= nil then
			unitSuffix = unitSuffix or ""
			unitSuffix = unitSuffix .. ", class: " .. class
		end
		if race ~= nil and gender ~= nil then
			local raceName = ZO_CachedStrFormat(SI_UNIT_NAME, GetRaceName(gender, race))
			unitSuffix = unitSuffix or ""
			unitSuffix = unitSuffix .. ", race: " .. raceName
		end
		if level ~= nil then
			unitSuffix = unitSuffix or ""
			if cp and cp > 0 then
				unitSuffix = unitSuffix .. ", CP: " .. tos(cp)
			else
				unitSuffix = unitSuffix .. ", level: " .. tos(level)
			end
		end
		if alliance ~= nil and type(alliance) == "number" then
			unitSuffix = unitSuffix or ""
			local allianceName = ZO_CachedStrFormat(SI_UNIT_NAME, GetAllianceName(alliance))
			unitSuffix = unitSuffix .. ", alliance: " .. allianceName
		end


	--Monsters and NPCs
	elseif isPlayer == false and unitType == UNIT_TYPE_MONSTER then
		isOtherPlayer= false
		local isEngaged = IsUnitActivelyEngaged(reticleVar)
--d(">unitReactColor: " ..tos(unitReactionColortype))
		--local companionName = ZO_CachedStrFormat(SI_UNIT_NAME, GetUnitName(CON_COMPANION))
		--local isMyCompanion = (unitName == companionName and true) or false
		local isMyCompanion = AreUnitsEqual(CON_COMPANION, reticleVar)
		if isMyCompanion == true then
			unitPrefix = "My companion"
		else
			local isInvulnerableGuard = IsUnitInvulnerableGuard(reticleVar)
			if isInvulnerableGuard == true then
				unitPrefix = "Invulnerable GUARD"
			else
				local isJusticeGuard = IsUnitJusticeGuard(reticleVar)
				if isJusticeGuard == true then
					unitPrefix = "Justice GUARD"
				else
					local isFriendlyFollower = IsUnitFriendlyFollower(reticleVar)
					if isFriendlyFollower == true then
						unitPrefix = "Friendly follower"
					else
						local isLiveStock = IsUnitLivestock(reticleVar)
						if isLiveStock == true then
							unitPrefix = "Livestock"
						else
							--[[
							UNIT_REACTION_DEFAULT = 0
							UNIT_REACTION_HOSTILE = 1
							UNIT_REACTION_NEUTRAL = 2
							UNIT_REACTION_FRIENDLY = 3
							UNIT_REACTION_PLAYER_ALLY = 4
							UNIT_REACTION_NPC_ALLY = 5
							UNIT_REACTION_COMPANION = 6
							]]
							if unitReaction == UNIT_REACTION_FRIENDLY or unitReaction == UNIT_REACTION_PLAYER_ALLY then
	--d(">friendly")
								if alreadyInteractedNPCNames[unitName] == true or isInteractableMonster == true or unitReactionColortype == UNIT_REACTION_COLOR_NEUTRAL then
									isNPC = true
								else
									--currentHealth, maxHealth = GetUnitPower(reticleVar, COMBAT_MECHANIC_FLAGS_HEALTH)
									if maxHealth <= CON_CRITTER_MAX_HEALTH or unitReactionColortype == UNIT_REACTION_COLOR_NEUTRAL then

	--d(">max health below 1000 - Critter?1")
										isNPC = false
										isCritter = true
									else
										isAttackable = (currentHealth < maxHealth and true) or false
										if isAttackable == false and (unitCaption ~= nil or unitReactionColortype == UNIT_REACTION_COLOR_FRIENDLY) then
	--d(">not attackable - NPC?1")
											isNPC = true
										end
									end
								end
							elseif UNIT_REACTION_HOSTILE and isAttackable == false then
	--d(">hostile")
								if isAttackable == false and not isDead then
	--d(">not attackable - NPC?2")
									isNPC = true
								end
							elseif UNIT_REACTION_NPC_ALLY then
	--d(">NPC ally")

								isNPC = false
								if isAttackable == true then
									--currentHealth, maxHealth = GetUnitPower(reticleVar, COMBAT_MECHANIC_FLAGS_HEALTH)
									if maxHealth <= CON_CRITTER_MAX_HEALTH then
	--d("<attackable, max health < 1000 - Critter?2")
										isCritter = true
									else
										if unitReactionColortype == UNIT_REACTION_COLOR_HOSTILE then
											isNPC = false --it's a monster/enemy
											isCritter = false
											--[[
											* UNIT_REACTION_COLOR_DEFAULT 		0
											* UNIT_REACTION_COLOR_HOSTILE 		1
											* UNIT_REACTION_COLOR_NEUTRAL 		2
											* UNIT_REACTION_COLOR_FRIENDLY 		3
											* UNIT_REACTION_COLOR_PLAYER_ALLY 	4
											* UNIT_REACTION_COLOR_NPC_ALLY 		5
											* UNIT_REACTION_COLOR_DEAD 			6
											* UNIT_REACTION_COLOR_INTERACT 		7
											* UNIT_REACTION_COLOR_COMPANION 	8
											]]
										end
									end
								else
									isNPC = true
								end
							elseif UNIT_REACTION_NEUTRAL then
	--d(">neutral")
								isAttackable = false
								if isNPC == false and (alreadyInteractedNPCNames[unitName] == true or isInteractableMonster == true) then
	--d(">>isInteractMonster")
									isNPC = true
								end
							end

							if isNPC == true then
								alreadyInteractedNPCNames[unitName] = true
								unitPrefix = "NPC"
							else
								--[[
								* MONSTER_DIFFICULTY_DEADLY
								* MONSTER_DIFFICULTY_EASY
								* MONSTER_DIFFICULTY_HARD
								* MONSTER_DIFFICULTY_NONE
								* MONSTER_DIFFICULTY_NORMAL
								]]
								isMonster = true
								if isCritter == true or difficulty == MONSTER_DIFFICULTY_NONE then
									if FCOAB.settingsVars.settings.reticleUnitIgnoreCritter == true then
										return nil, nil, nil, nil, nil
									end

									unitPrefix = "Critter"
									isMonster = false
								elseif difficulty >= MONSTER_DIFFICULTY_EASY and difficulty <= MONSTER_DIFFICULTY_NORMAL then
									unitPrefix = ""
								elseif difficulty == MONSTER_DIFFICULTY_HARD then
									unitPrefix = "HARD"
								elseif difficulty == MONSTER_DIFFICULTY_DEADLY then
									unitPrefix = "DEADLY"
								end
							end
						end
					end
				end
			end
		end
		--Show monster's health current in %, and max in values?
		--Died meanwhile?
		isDead = IsUnitDead(reticleVar)
		if isMonster == true and isDead == false then
			local currentHealthPercent = 100
			if healthCurrent == nil and healthMax == nil then
				currentHealth, maxHealth = GetUnitPower(reticleVar, COMBAT_MECHANIC_FLAGS_HEALTH)
			end
			if(maxHealth and maxHealth > 0) then
				currentHealthPercent = getPercent(currentHealth, maxHealth)
			else
				currentHealthPercent = 0
			end
			unitHealth = "[" .. tos(currentHealthPercent) .. "%/" ..tos(ZO_CommaDelimitDecimalNumber(maxHealth)) .. "]"
			--[[
			if unitPrefix == "" then
				if unitSuffix ~= nil and unitSuffix ~= "" then
					unitSuffix = unitHealth .. " " .. unitSuffix
				else
					unitSuffix = unitHealth
				end
			else
				unitPrefix = unitPrefix .. " " .. unitHealth
			end
			]]
			if unitSuffix ~= nil and unitSuffix ~= "" then
				unitSuffix = unitHealth .. " " .. unitSuffix
			else
				unitSuffix = unitHealth
			end
		end
		if isEngaged == true then
			if isDead == true then
				unitPrefix = unitPrefix .. " (dead)"
			else
				unitPrefix = unitPrefix .. " (in combat)"
			end
		end
	end
	return unitPrefix, unitSuffix, unitName, unitDisplayName, unitCaption
end

------------------------------------------------------------------------------------------------------------------------

local function groupUnitTagChecksForTargetMarkers()
	if IsUnitGrouped(CON_RETICLE) then return true end
	if IsUnitGrouped(CON_PLAYER) then
		local playerGroupIndex = GetGroupIndexByUnitTag(CON_PLAYER)
		for i=1, GetGroupSize(), 1 do
			if i ~= playerGroupIndex then
				local groupUnitTag = GetGroupUnitTagByIndex(1)
				if AreUnitsEqual(groupUnitTag, CON_RETICLE) then
--d("<reticle: group unit " .. tos(groupUnitTag))
					return true
				end
			end
		end
	end
	return false
end

local function removeActualTargetMarkerAtReticleUnit()
	local rawUnitName = GetRawUnitName(CON_RETICLE)
	local activeTargetMarkerType = GetUnitTargetMarkerType(CON_RETICLE)
	--d(">target = reticle, Marker: " ..tos(activeTargetMarkerType))
	if activeTargetMarkerType ~= 0 then
		--No grouped units
		if groupUnitTagChecksForTargetMarkers() == true then return end

		--Remove the marker
		local rawUnitNameNow = GetRawUnitName(CON_RETICLE)
		--Target changed!
		if rawUnitName ~= rawUnitNameNow then return end

		AssignTargetMarkerToReticleTarget(activeTargetMarkerType)
		local activeTargetMarkerTypeNow = GetUnitTargetMarkerType(CON_RETICLE)
		if activeTargetMarkerTypeNow == 0 then
			--d("<marker removed: " ..tos(activeTargetMarkerType))
			targetMarkersNumbersApplied[activeTargetMarkerType] = nil
		end
	end
	--FCOAB._targetMarkersApplied = targetMarkersApplied
	--FCOAB._targetMarkersNumbersApplied = targetMarkersNumbersApplied
end

local combatTargetTypesFiltered = {
	[COMBAT_UNIT_TYPE_OTHER] = false,
	[COMBAT_UNIT_TYPE_NONE] = false,
	--Filter the below targets
	[COMBAT_UNIT_TYPE_PLAYER] = true,
	[COMBAT_UNIT_TYPE_PLAYER_PET] = true,
	[COMBAT_UNIT_TYPE_GROUP] = true,
	[COMBAT_UNIT_TYPE_TARGET_DUMMY] = true,
	[COMBAT_UNIT_TYPE_PLAYER_COMPANION] = true,
}
local actionResultsTracked = {
	[ACTION_RESULT_ABILITY_ON_COOLDOWN] = false, -- 2080
	[ACTION_RESULT_ABSORBED] = true, -- 2120
	[ACTION_RESULT_BAD_TARGET] = false, -- 2040
	[ACTION_RESULT_BLADETURN] = true, -- 2360
	[ACTION_RESULT_BLOCKED] = true, -- 2150
	[ACTION_RESULT_BLOCKED_DAMAGE] = true, -- 2151
	[ACTION_RESULT_BUSY] = false, -- 2030
	[ACTION_RESULT_CANNOT_USE] = false, -- 2290
	[ACTION_RESULT_CANT_SEE_TARGET] = false, -- 2330
	[ACTION_RESULT_CANT_SWAP_HOTBAR_IS_OVERRIDDEN] = false, -- 3450
	[ACTION_RESULT_CANT_SWAP_WHILE_CHANGING_GEAR] = false, -- 3410
	[ACTION_RESULT_CASTER_DEAD] = false, -- 2060
	[ACTION_RESULT_CHARMED] = false, -- 3510
	[ACTION_RESULT_CRITICAL_DAMAGE] = true, -- 2
	[ACTION_RESULT_CRITICAL_HEAL] = false, -- 32
	[ACTION_RESULT_DAMAGE] = true, -- 1
	[ACTION_RESULT_DAMAGE_SHIELDED] = true, -- 2460
	[ACTION_RESULT_DEFENDED] = true, -- 2190
	[ACTION_RESULT_DIED] = false, -- 2260
	[ACTION_RESULT_DIED_COMPANION_XP] = false, -- 3480
	[ACTION_RESULT_DIED_XP] = false, -- 2262
	[ACTION_RESULT_DISARMED] = true, -- 2430
	[ACTION_RESULT_DISORIENTED] = true, -- 2340
	[ACTION_RESULT_DODGED] = true, -- 2140
	[ACTION_RESULT_DOT_TICK] = true, -- 1073741825
	[ACTION_RESULT_DOT_TICK_CRITICAL] = true, -- 1073741826
	[ACTION_RESULT_FAILED] = false, -- 2110
	[ACTION_RESULT_FAILED_REQUIREMENTS] = false, -- 2310
	[ACTION_RESULT_FAILED_SIEGE_CREATION_REQUIREMENTS] = false, -- 3100
	[ACTION_RESULT_FALLING] = false, -- 2500
	[ACTION_RESULT_FALL_DAMAGE] = false, -- 2420
	[ACTION_RESULT_FEARED] = true, -- 2320
	[ACTION_RESULT_GRAVEYARD_DISALLOWED_IN_INSTANCE] = false, -- 3080
	[ACTION_RESULT_GRAVEYARD_TOO_CLOSE] = false, -- 3030
	[ACTION_RESULT_HEAL] = false, -- 16
	[ACTION_RESULT_HEAL_ABSORBED] = false, -- 3470
	[ACTION_RESULT_HOT_TICK] = false, -- 1073741840
	[ACTION_RESULT_HOT_TICK_CRITICAL] = false, -- 1073741856
	[ACTION_RESULT_IMMUNE] = true, -- 2000
	[ACTION_RESULT_INSUFFICIENT_RESOURCE] = false, -- 2090
	[ACTION_RESULT_INTERCEPTED] = true, -- 2410
	[ACTION_RESULT_INTERRUPT] = true, -- 2230
	[ACTION_RESULT_INVALID] = false, -- -1
	[ACTION_RESULT_INVALID_FIXTURE] = false, -- 2810
	[ACTION_RESULT_INVALID_JUSTICE_TARGET] = false, -- 3420
	[ACTION_RESULT_INVALID_TERRAIN] = false, -- 2800
	[ACTION_RESULT_IN_AIR] = false, -- 2510
	[ACTION_RESULT_IN_COMBAT] = false, -- 2300
	[ACTION_RESULT_IN_ENEMY_KEEP] = false, -- 2610
	[ACTION_RESULT_IN_ENEMY_OUTPOST] = false, -- 2613
	[ACTION_RESULT_IN_ENEMY_RESOURCE] = false, -- 2612
	[ACTION_RESULT_IN_ENEMY_TOWN] = false, -- 2611
	[ACTION_RESULT_IN_HIDEYHOLE] = false, -- 3440
	[ACTION_RESULT_KILLED_BY_DAEDRIC_WEAPON] = false, -- 3461
	[ACTION_RESULT_KILLED_BY_SUBZONE] = false, -- 3130
	[ACTION_RESULT_KILLING_BLOW] = false, -- 2265
	[ACTION_RESULT_KNOCKBACK] = true, -- 2475
	[ACTION_RESULT_LEVITATED] = true, -- 2400
	[ACTION_RESULT_MERCENARY_LIMIT] = false, -- 3140
	[ACTION_RESULT_MISS] = true, -- 2180
	[ACTION_RESULT_MISSING_EMPTY_SOUL_GEM] = false, -- 3040
	[ACTION_RESULT_MISSING_FILLED_SOUL_GEM] = false, -- 3060
	[ACTION_RESULT_MOBILE_GRAVEYARD_LIMIT] = false, -- 3150
	[ACTION_RESULT_MOUNTED] = false, -- 3070
	[ACTION_RESULT_MUST_BE_IN_OWN_KEEP] = false, -- 2630
	[ACTION_RESULT_NOT_ENOUGH_INVENTORY_SPACE] = false, -- 3430
	[ACTION_RESULT_NOT_ENOUGH_INVENTORY_SPACE_SOUL_GEM] = false, -- 3050
	[ACTION_RESULT_NOT_ENOUGH_SPACE_FOR_SIEGE] = false, -- 3090
	[ACTION_RESULT_NO_LOCATION_FOUND] = false, -- 2700
	[ACTION_RESULT_NO_RAM_ATTACKABLE_TARGET_WITHIN_RANGE] = false, -- 2910
	[ACTION_RESULT_NO_WEAPONS_TO_SWAP_TO] = false, -- 3400
	[ACTION_RESULT_NPC_TOO_CLOSE] = false, -- 2640
	[ACTION_RESULT_OFFBALANCE] = true, -- 2440
	[ACTION_RESULT_PACIFIED] = true, -- 2390
	[ACTION_RESULT_PARRIED] = true, -- 2130
	[ACTION_RESULT_PARTIAL_RESIST] = true, -- 2170
	[ACTION_RESULT_POWER_DRAIN] = true, -- 64
	[ACTION_RESULT_POWER_ENERGIZE] = true, -- 128
	[ACTION_RESULT_PRECISE_DAMAGE] = true, -- 4
	[ACTION_RESULT_QUEUED] = false, -- 2350
	[ACTION_RESULT_RAM_ATTACKABLE_TARGETS_ALL_DESTROYED] = false, -- 3120
	[ACTION_RESULT_RAM_ATTACKABLE_TARGETS_ALL_OCCUPIED] = false, -- 3110
	[ACTION_RESULT_RECALLING] = false, -- 2520
	[ACTION_RESULT_REFLECTED] = true, -- 2111
	[ACTION_RESULT_REINCARNATING] = false, -- 3020
	[ACTION_RESULT_RESIST] = true, -- 2160
	[ACTION_RESULT_RESURRECT] = false, -- 2490
	[ACTION_RESULT_ROOTED] = true, -- 2480
	[ACTION_RESULT_SELF_PLAYING_TRIBUTE] = false, -- 3490
	[ACTION_RESULT_SIEGE_LIMIT] = false, -- 2620
	[ACTION_RESULT_SIEGE_NOT_ALLOWED_IN_ZONE] = false, -- 2605
	[ACTION_RESULT_SIEGE_TOO_CLOSE] = false, -- 2600
	[ACTION_RESULT_SILENCED] = true, -- 2010
	[ACTION_RESULT_SNARED] = true, -- 2025
	[ACTION_RESULT_SOUL_GEM_RESURRECTION_ACCEPTED] = false, -- 3460
	[ACTION_RESULT_SPRINTING] = false, -- 3000
	[ACTION_RESULT_STAGGERED] = true, -- 2470
	[ACTION_RESULT_STUNNED] = true, -- 2020
	[ACTION_RESULT_SWIMMING] = false, -- 3010
	[ACTION_RESULT_TARGET_DEAD] = true, -- 2050
	[ACTION_RESULT_TARGET_NOT_IN_VIEW] = false, -- 2070
	[ACTION_RESULT_TARGET_NOT_PVP_FLAGGED] = false, -- 2391
	[ACTION_RESULT_TARGET_OUT_OF_RANGE] = false, -- 2100
	[ACTION_RESULT_TARGET_PLAYING_TRIBUTE] = false, -- 3500
	[ACTION_RESULT_TARGET_TOO_CLOSE] = false, -- 2370
	[ACTION_RESULT_UNEVEN_TERRAIN] = false, -- 2900
	[ACTION_RESULT_WEAPONSWAP] = false, -- 2450
	[ACTION_RESULT_WRECKING_DAMAGE] = true, -- 8
	[ACTION_RESULT_WRONG_WEAPON] = false, -- 2380
}
local allowedSourceTypes = {
	[COMBAT_UNIT_TYPE_PLAYER] = true,
	[COMBAT_UNIT_TYPE_PLAYER_PET] = true,
	[COMBAT_UNIT_TYPE_PLAYER_COMPANION] = true,
}
local enemyNumberToTargetMarkerType = {
	[1] = TARGET_MARKER_TYPE_ONE,
	[2] = TARGET_MARKER_TYPE_TWO,
	[3] = TARGET_MARKER_TYPE_THREE,
	[4] = TARGET_MARKER_TYPE_FOUR,
	[5] = TARGET_MARKER_TYPE_FIVE,
	[6] = TARGET_MARKER_TYPE_SIX,
	[7] = TARGET_MARKER_TYPE_SEVEN,
	[8] = TARGET_MARKER_TYPE_EIGHT,
}

local function onCombatEvent(eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
	--Which source? Only for player (pets/companions)

	--Only in combat, for non filtered targetTypes, for tracked actionResults, and if the targetUnitId wasn't added before already
	--and if there is no target unit marker on the enemy yet
	if IsUnitInCombat(CON_PLAYER) == false
			or combatTargetTypesFiltered[targetType] == true
			or not actionResultsTracked[result]
			or not allowedSourceTypes[sourceType]
			or targetUnitId == nil
			or targetMarkersApplied[targetUnitId] ~= nil
			or targetName == nil or targetName == ""
	--or hitTargetsUnitIds[targetUnitId] ~= nil
	then
		return
	end

	local unitNameBelowReticle = GetRawUnitName(CON_RETICLE)

	--local targetNameClean = zo_strformat(SI_UNIT_NAME, targetName)
	hitTargetsUnitIds[targetUnitId] = targetName
	hitTargetsNames[targetName] = hitTargetsNames[targetName] or {}
	hitTargetsNames[targetName][targetUnitId] = true

	--for debugging
	--FCOAB._hitTargetsUnitIds = hitTargetsUnitIds
	--FCOAB._hitTargetsNames = hitTargetsNames

	--d("[FCOAB]OnCombatEvent-source: player, target: " .. tos(targetName) .. "/" .. tos(unitNameBelowReticle) .. " ("..tos(targetUnitId).."-type: " ..tos(targetType).."), result: " ..tos(result) ..", ability: " ..tos(abilityName) .. ", powerType: " ..tos(powerType) .. ", enemyNumber: " ..tos(enemyNumber))

	--Unit died!
	if result == ACTION_RESULT_TARGET_DEAD then
		--Remove the actual target marker if needed
		removeActualTargetMarkerAtReticleUnit()
		return
	end

	--Exclude group members!
	if groupUnitTagChecksForTargetMarkers() == true then return end


	--Automatically apply the target marker to the enemy, if the same enemy of the combatevent here is below the reticle
	--d(">activelyEngaged: " ..tos(IsUnitActivelyEngaged(CON_RETICLE))) --may not work for targets of aoe?
	local companionActive = HasActiveCompanion()
	if (IsUnitInCombat(CON_RETICLE) and (not companionActive or (companionActive == true and not AreUnitsEqual(CON_COMPANION, CON_RETICLE)))
			and unitNameBelowReticle == targetName) then

		local unitNameNow = GetRawUnitName(CON_RETICLE)
		--Unit below reticle changed!
		if unitNameNow ~= unitNameBelowReticle then return end

		local activeTargetMarkerType = GetUnitTargetMarkerType(CON_RETICLE)
		--d(">combat target = reticle, Marker: " ..tos(activeTargetMarkerType))
		if activeTargetMarkerType == nil or activeTargetMarkerType == 0 then
			--Get next free target marker
			local targetMarkerType
			for targetMarkerTypeLoop=1, CON_NUM_TARGET_MARKERS, 1 do
				if targetMarkerType == nil and targetMarkersNumbersApplied[targetMarkerTypeLoop] == nil then
					targetMarkerType = targetMarkerTypeLoop
					break
				end
			end

			if targetMarkerType == nil or targetMarkerType == 0 then return end

			unitNameNow = GetRawUnitName(CON_RETICLE)
			--Unit below reticle changed!
			if unitNameNow ~= unitNameBelowReticle then return end

			targetMarkersApplied[targetUnitId] = targetMarkerType
			AssignTargetMarkerToReticleTarget(targetMarkerType)
			local activeTargetMarkerTypeNow = GetUnitTargetMarkerType(CON_RETICLE)
			if activeTargetMarkerTypeNow ~= 0 then
				--d(">applied target marker: " ..tos(activeTargetMarkerTypeNow))
				targetMarkersNumbersApplied[activeTargetMarkerTypeNow] = true
			end
		else
			--d("<target marker was applied! " ..tos(activeTargetMarkerType))
			targetMarkersNumbersApplied[activeTargetMarkerType] = true
		end
	end
	--FCOAB._targetMarkersApplied = targetMarkersApplied
	--FCOAB._targetMarkersNumbersApplied = targetMarkersNumbersApplied

end

local function onUnitDeathStateChanged(eventId, unitTag, isDead)
	--d("[FCOAB]Unit death: " ..tos(isDead) .. ", tag: " ..tos(unitTag))
	--Remove the actual target marker if needed
	removeActualTargetMarkerAtReticleUnit()
end

local function onPowerUpdate(eventId, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	local unitName = zo_strformat(SI_UNIT_NAME, GetUnitName(CON_RETICLE))

--d("[FCOAB]OnPowerUpdate-unit: " ..tos(unitName) ..", health: " .. tos(powerValue) .. ", max: " ..tos(powerMax))

	--Only in combat, if unit exists, is not dead, is no critter (health == 1) and if the unit exists
	-->and if the settings to show the health in combat are enabled
	if FCOAB.settingsVars.settings.showReticleOverUnitHealthInChat == false
			or DoesUnitExist(CON_RETICLE) == false or IsUnitInCombat(CON_PLAYER) == false or IsUnitDead(CON_RETICLE) or powerValue <= 0 or powerMax == CON_CRITTER_MAX_HEALTH then
		return
	end

	--Check if the active reticleOver unit is the same as we saved in the OnReticleChanged callback
	--local unitName = zo_strformat(SI_UNIT_NAME, GetUnitName(CON_RETICLE))
--d(">lastReticle: " ..tos(lastAddedReticleToChat.name) .. ", name: " ..tos(unitName))
	--Only works if settings got the reticle change enabled, and enabled in combat too
	--[[
	if lastAddedReticleToChat.name ~= unitName then
		reticleOverLastHealthPercent = 0
		return
	end
	--Only update to chat in 10% steps

	local healthPercent = 0
	if reticleOverLastHealthPercent == 0 then
d("<lastPercent is 0")
		return
	else
	]]
	local healthPercent = 0
	if reticleOverLastHealthPercent ~= 0 then
		healthPercent = getPercent(powerValue, powerMax)
		local healthDiff = reticleOverLastHealthPercent - healthPercent
		--d(">health%: " ..tos(healthPercent) .. ", diff: " ..tos(healthDiff))
		if healthDiff > 0 then
			if healthPercent >= 30 then
				if healthDiff < 10 then
					return
				end
			else
				if healthDiff < 5 then
					return
				end
			end
		else
			if healthPercent >= 30 then
				if healthDiff > -10 then
					return
				end
			else
				if healthDiff > -5 then
					return
				end
			end
		end
		--end
		reticleOverLastHealthPercent = healthPercent
	else
		reticleOverLastHealthPercent = getPercent(powerValue, powerMax)
		healthPercent = reticleOverLastHealthPercent
	end

	--Output the current reticleOver unit's health to chat
	--local unitPrefix, unitSuffix, unitName, unitDisplayName, unitCaption = getReticleOverUnitDataAndPrepareChatText(nil, powerValue, powerMax)
	local unitPrefix = "\'" .. tos(unitName) .. "\' " ..tos(healthPercent) .. "%" -- .. "/" .. tos(ZO_CommaDelimitDecimalNumber(powerMax))
	--directlyReadOrAddToChat(unitPrefix, CON_PRIO_CHAT_COMBAT_TIP)
	buildUnitChatOutputAndAddToChat(unitPrefix, nil, nil, nil, nil, false)
	hadLastCombatAnyChatMessage = true
	--end
end



local function checkIfTargetMarkersShouldBeEnabled()
	--Is player grouped and is the player the group leader? Else target markers would be done by multiple players in group and thus changed to wrong values
	local isPlayerGrouped = IsUnitGrouped(CON_PLAYER)
	local isPlayerGroupLeader = IsUnitGroupLeader(CON_PLAYER)

	if combatEventRegistered == false and FCOAB.settingsVars.settings.targetMarkersSetInCombatToEnemies == true and (not isPlayerGrouped or (isPlayerGrouped and isPlayerGroupLeader)) then
		EM:RegisterForEvent(addonName .. "_EVENT_COMBAT_EVENT", 			EVENT_COMBAT_EVENT, 		onCombatEvent)
		EM:AddFilterForEvent(addonName .. "_EVENT_COMBAT_EVENT", 			EVENT_COMBAT_EVENT, 		REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
		EM:RegisterForEvent(addonName .. "_EVENT_COMBAT_EVENT_PET", 		EVENT_COMBAT_EVENT, 		onCombatEvent)
		EM:AddFilterForEvent(addonName .. "_EVENT_COMBAT_EVENT_PET", 		EVENT_COMBAT_EVENT, 		REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET)
		EM:RegisterForEvent(addonName .. "_EVENT_COMBAT_EVENT_COMPANION", 	EVENT_COMBAT_EVENT, 		onCombatEvent)
		EM:AddFilterForEvent(addonName .. "_EVENT_COMBAT_EVENT_COMPANION",	EVENT_COMBAT_EVENT, 		REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_COMPANION)

		EM:RegisterForEvent(addonName .. "_EVENT_UNIT_DEATH_STATE_CHANGED",	EVENT_UNIT_DEATH_STATE_CHANGED, 	onUnitDeathStateChanged)
		EM:AddFilterForEvent(addonName .. "_EVENT_UNIT_DEATH_STATE_CHANGED",EVENT_UNIT_DEATH_STATE_CHANGED, 	REGISTER_FILTER_UNIT_TAG, CON_RETICLE)
		combatEventRegistered = true
	else
		if combatEventRegistered == true then
			EM:UnregisterForEvent(addonName .. "_EVENT_COMBAT_EVENT", 			EVENT_COMBAT_EVENT)
			EM:UnregisterForEvent(addonName .. "_EVENT_COMBAT_EVENT_PET", 		EVENT_COMBAT_EVENT)
			EM:UnregisterForEvent(addonName .. "_EVENT_COMBAT_EVENT_COMPANION", EVENT_COMBAT_EVENT)

			EM:UnregisterForEvent(addonName .. "_EVENT_UNIT_DEATH_STATE_CHANGED",	EVENT_UNIT_DEATH_STATE_CHANGED)
			combatEventRegistered = false
		end
	end
end

local function reticleUnitData()
	local settings = FCOAB.settingsVars.settings
	local reticleUnitToChatText = settings.reticleUnitToChatText
	local reticlePlayerToChatText = settings.reticlePlayerToChatText
	local showReticleOverUnitHealthInChat = settings.showReticleOverUnitHealthInChat

	--Unit
	if reticleOverChangedEventRegistered == false and (reticleUnitToChatText == true or showReticleOverUnitHealthInChat == true) then
		reticleOverLastHealthPercent = 0
		EM:RegisterForEvent(addonName .. "_EVENT_RETICLE_TARGET_CHANGED", EVENT_RETICLE_TARGET_CHANGED, function(eventId)
			--d("[FOCAB]EVENT_RETICLE_TARGET_CHANGED-"..tos(GetUnitName(CON_RETICLE)))
			local unitName = GetUnitName(CON_RETICLE)
			if unitName == nil or unitName == "" then return end

			settings = FCOAB.settingsVars.settings
			reticleUnitToChatText = settings.reticleUnitToChatText
			reticlePlayerToChatText = settings.reticlePlayerToChatText
			showReticleOverUnitHealthInChat = settings.showReticleOverUnitHealthInChat

			local reticleToChatUnitDisableInGroup = settings.reticleToChatUnitDisableInGroup
			local isGrouped = IsUnitGrouped(CON_PLAYER)

			local reticleToChatInCombat = settings.reticleToChatInCombat
			local isInCombat = IsUnitInCombat(CON_PLAYER)

			if isInCombat == true then
				--[[
				if targetMarkersSetInCombatToEnemies == true then

				end
				]]

				if showReticleOverUnitHealthInChat == true and DoesUnitExist(CON_RETICLE) and IsUnitDead(CON_RETICLE) == false then
					--Update the last saved health value of the target below the reticle, as %
					local health, maxHealth = GetUnitPower(CON_RETICLE, COMBAT_MECHANIC_FLAGS_HEALTH)
					if health > 0 and maxHealth > 0 then
						reticleOverLastHealthPercent = getPercent(health, maxHealth)
					else
						reticleOverLastHealthPercent = 0
					end
				end
			else
				reticleOverLastHealthPercent = 0
			end

			--Do not update in combat, unless enabled at the settings
			if (reticleUnitToChatText == true and
					(isInCombat == false or (reticleToChatInCombat == true and isInCombat == true)) and
					(isGrouped == false or (reticleToChatUnitDisableInGroup == false and isGrouped == true))
			) then
				local now = GetGameTimeMilliseconds()
				local lastReticle2Chat = lastPlayed.reticle2Chat

				if lastReticle2Chat == 0 or now >= (lastReticle2Chat + reticleToChatDelay) then
					lastPlayed.reticle2Chat = now

					local unitType = GetUnitType(CON_RETICLE)
					--Player data with the own event -> EVENT_RETICLE_TARGET_PLAYER_CHANGED
					if unitType == UNIT_TYPE_PLAYER then return end

					local unitPrefix, unitSuffix, unitName, unitDisplayName, unitCaption = getReticleOverUnitDataAndPrepareChatText(nil, nil, false)
					if unitPrefix == nil and unitName == nil then return end

					local lastAddedUnitName = lastAddedReticleToChat.name
					if lastAddedReticleToChat == nil or lastAddedUnitName == nil
							or (	(unitName ~= nil and lastAddedUnitName ~= unitName)
							or 	(unitDisplayName ~= nil and lastAddedUnitName ~= unitDisplayName)
					)
					then
						lastAddedReticleToChat.name = unitName or unitDisplayName
						lastAddedReticleToChat.caption = unitCaption

						buildUnitChatOutputAndAddToChat(unitPrefix, unitSuffix, unitName, unitDisplayName, unitCaption, true)
						hadLastCombatAnyChatMessage = true
					end
				end
			end
		end)

		--Reticle power update (health, magicka, stamina)
		EM:RegisterForEvent(addonName .. "_EVENT_POWER_UPDATE_HEALTH", 		EVENT_POWER_UPDATE, 		onPowerUpdate)
		EM:AddFilterForEvent(addonName .. "_EVENT_POWER_UPDATE_HEALTH", 	EVENT_POWER_UPDATE, 		REGISTER_FILTER_UNIT_TAG, CON_RETICLE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)
		--[[
		EM:RegisterForEvent(addonName .. "_EVENT_POWER_UPDATE_STAMINA", 	EVENT_POWER_UPDATE, 		onPowerUpdate)
		EM:AddFilterForEvent(addonName .. "_EVENT_POWER_UPDATE_STAMINA", 	EVENT_POWER_UPDATE, 		REGISTER_FILTER_UNIT_TAG, CON_RETICLE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_STAMINA)
		EM:RegisterForEvent(addonName .. "_EVENT_POWER_UPDATE_MAGICKA", 	EVENT_POWER_UPDATE, 		onPowerUpdate)
		EM:AddFilterForEvent(addonName .. "_EVENT_POWER_UPDATE_MAGICKA", 	EVENT_POWER_UPDATE, 		REGISTER_FILTER_UNIT_TAG, CON_RETICLE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_MAGICKA)
		]]
		reticleOverChangedEventRegistered = true
	else
		if reticleOverChangedEventRegistered == true and (reticleUnitToChatText == false and showReticleOverUnitHealthInChat == false) then
			reticleOverLastHealthPercent = 0
			EM:UnregisterForEvent(addonName .. "_EVENT_RETICLE_TARGET_CHANGED",	EVENT_RETICLE_TARGET_CHANGED)
			EM:UnregisterForEvent(addonName .. "_EVENT_POWER_UPDATE_HEALTH",	EVENT_POWER_UPDATE)
			reticleOverChangedEventRegistered = false
		end
	end

	--Player
	if reticleOverPlayerChangedEventRegistered == false and reticlePlayerToChatText == true then
		EM:RegisterForEvent(addonName .. "_EVENT_RETICLE_TARGET_PLAYER_CHANGED", EVENT_RETICLE_TARGET_PLAYER_CHANGED, function(eventId)
--d("[FCOAB]EVENT_RETICLE_TARGET_PLAYER_CHANGED-name: " .. tos(GetUnitName(CON_RETICLE_PLAYER)))
			local unitName = GetUnitName(CON_RETICLE_PLAYER)
			if unitName == nil or unitName == "" then return end


			settings = FCOAB.settingsVars.settings
			reticlePlayerToChatText = settings.reticlePlayerToChatText

			local reticleToChatPlayerDisableInGroup = settings.reticleToChatPlayerDisableInGroup
			local isGrouped = IsUnitGrouped(CON_PLAYER)

			local reticleToChatInCombat = settings.reticleToChatInCombat
			local isInCombat = IsUnitInCombat(CON_PLAYER)

			--Do not update in combat, unless enabled at the settings
			if (reticlePlayerToChatText == true and
					(isInCombat == false or (reticleToChatInCombat == true and isInCombat == true)) and
					(isGrouped == false or (reticleToChatPlayerDisableInGroup == false and isGrouped == true))
			) then
				local now = GetGameTimeMilliseconds()
				local lastReticle2Chat = lastPlayed.reticle2Chat

				if lastReticle2Chat == 0 or now >= (lastReticle2Chat + reticleToChatDelay) then
					lastPlayed.reticle2Chat = now

					local unitPrefix, unitSuffix, unitName, unitDisplayName, unitCaption = getReticleOverUnitDataAndPrepareChatText(nil, nil, true)
					if unitPrefix == nil and unitName == nil then return end

					local lastAddedUnitName = lastAddedReticleToChat.name
					if lastAddedReticleToChat == nil or lastAddedUnitName == nil
							or (	(unitName ~= nil and lastAddedUnitName ~= unitName)
							or 	(unitDisplayName ~= nil and lastAddedUnitName ~= unitDisplayName)
					)
					then
						lastAddedReticleToChat.name = unitName or unitDisplayName
						lastAddedReticleToChat.caption = unitCaption

						buildUnitChatOutputAndAddToChat(unitPrefix, unitSuffix, unitName, unitDisplayName, unitCaption, true)
					end
				end
			end
		end)

		reticleOverPlayerChangedEventRegistered = true
	else
		if reticleOverPlayerChangedEventRegistered == true and reticlePlayerToChatText == false then
			EM:UnregisterForEvent(addonName .. "_EVENT_RETICLE_TARGET_PLAYER_CHANGED",	EVENT_RETICLE_TARGET_PLAYER_CHANGED)
			reticleOverPlayerChangedEventRegistered = false
		end
	end

	--Target markers
	checkIfTargetMarkersShouldBeEnabled()
end

local function onGroupStatusChange(hasLeft, hasJoined, onUpdate, onUpdateEventPlayerActivated)
	--d("[FCOAB]onGroupStatus-left: " .. tos(hasLeft) .. ", joined: " ..tos(hasJoined) .. ", update: " ..tos(onUpdate) .. ", eventPlayerActivated. " .. tos(onUpdateEventPlayerActivated))
	--Check that the group leader sound should be played,  player is not dead, in a group, group leader exists and is not the player
	--or No group leader data but event is currently active? Deactivate
	if isGroupedAndGroupLeaderGivenAndShouldSoundPlayByFCOAB() == false or (groupLeaderData.unitTag == nil and isGroupLeaderUpdateEventActive) then
		--Disable the sound checks and the updater
		runGroupLeaderUpdates(false, true)
		return
	end

	--Enable the sound checks for the group leader, if not already active
	if not isGroupLeaderUpdateEventActive then
		runGroupLeaderUpdates(true, true)
	end
end

local function isPlayerLookingAtUnit(destNormX, destNormY)
	if not destNormX or not destNormY or (destNormX == 0 and destNormY == 0) then return nil end
	-- player position
	local playerNormX, playerNormY, playerNormZ, isInCurrentMap = GetMapPlayerPosition(CON_PLAYER)
	--[[
	--using vectors here does not really work, maybe some values need to be normalized or values below 0 needs to be recaclulated etc.

	-- target position
	-- player view direction vector
	local heading = GetPlayerCameraHeading()
	--Get vector vx and vy by heading, using cos and sin
	local vx = math.cos(heading)
	local vy = math.sin(heading)
	-- calculate direction vector from player to target
	local dx = destNormX - playerNormX
	local dy = destNormY - playerNormY
	-- calculate dot product of direction vector and view direction vector
	local dot_product = vx * dx + vy * dy
	-- calculate magnitudes of vectors
	local v_magnitude = math.sqrt(vx^2 + vy^2)
	local d_magnitude = math.sqrt(dx^2 + dy^2)
d(">>====================>>")
d(">destX: " ..tos(destNormX) .. ", destY: " ..tos(destNormY) .. ", isInMap: " ..tos(isInCurrentMap))
d("heading: " ..tos(heading) .. "/vx: " ..tos(vx) .. ", vy: " ..tos(vy) .. "/dx: " ..tos(dx) .. ", dy: " ..tos(dy))
d(">dotProduct: " ..tos(dot_product) .. "/v_magni: " ..tos(v_magnitude) .. ", d_magni: " ..tos(d_magnitude))

	-- calculate angle between vectors in radians
	local angle_radians = math.acos(dot_product / (v_magnitude * d_magnitude))
	if angle_radians < 0 then
		angle_radians = angle_radians + 2 * pi
	end

	-- convert angle to degrees
	local angle_degrees = math.deg(angle_radians)
d(">angle: " .. tos(angle_degrees) .. ", radians: " ..tos(angle_radians))
d("<<====================<<")
	]]

	--using radian values and changing it to degrees in the end. if value is above 360° it will be subtracted by 360 again
	local opp = playerNormY - destNormY
	local adj = destNormX - playerNormX
	local angle_radians = atan2(opp, adj)
	angle_radians = angle_radians - pi / 2
	if angle_radians < 0 then
		angle_radians = angle_radians + 2 * pi
	end

	local heading = GetPlayerCameraHeading()
	local rotateHeading = angle_radians + ((2 * pi) - heading)

	local angle_degrees = deg(rotateHeading)
	if angle_degrees > 360 then angle_degrees = angle_degrees - 360 end

	-- check if angle is smaller than threshold 20°
	--todo check if the settings angle (groupLeaderAngle) matches
	local groupLeaderAngle = FCOAB.settingsVars.settings.groupLeaderSoundAngle
	local groupLeaderAngleHalf = groupLeaderAngle / 2
--d(">angle_degrees: " ..tos(angle_degrees) .. " (" ..tos(360 - groupLeaderAngleHalf) .. "/" .. tos(groupLeaderAngleHalf) ..")")
	if angle_degrees >= (360 - groupLeaderAngleHalf) or angle_degrees <= groupLeaderAngleHalf then
--d("<Looking at unit!")
		return true, angle_degrees
	else
		--reset the last played group leader sound so next time we look at the group leader again it will be played directly
		lastPlayed.groupLeader = 0
		return false, angle_degrees
	end
end


local function getGroupLeaderDistance()
	if IsUnitGrouped(CON_PLAYER) == true then
		local unitTagOfGroupLeader = GetGroupLeaderUnitTag()
		if AreUnitsEqual(CON_PLAYER, unitTagOfGroupLeader) then return end
		local isUnitOnlineAndInSameWorldEtc = checkUnitIsOnlineAndInSameIniAndWorld(unitTagOfGroupLeader)
		if isUnitOnlineAndInSameWorldEtc == true then
			local normXGroupLeader, normYGroupLeader = GetMapPlayerPosition(unitTagOfGroupLeader)
			return getDistanceToLocalCoords(normXGroupLeader, normYGroupLeader)
		end
	end
	return
end

local function checkGroupLeaderPos()
	--d("[FCOAB]checkGroupLeaderPos")
	local unitTagOfGroupLeader = groupLeaderData.unitTag
	if unitTagOfGroupLeader == nil or unitTagOfGroupLeader == "" then
		--Do a new "is unit in group check + get group leader" by simulating a member has left the group
		onGroupStatusChange(true, false, false, false)
		return
	end

	local isUnitOnlineAndInSameWorldEtc = checkUnitIsOnlineAndInSameIniAndWorld(unitTagOfGroupLeader)
	local isUnitStillGroupLeader = (IsUnitGrouped(CON_PLAYER) and isUnitOnlineAndInSameWorldEtc == true and GetGroupLeaderUnitTag() == unitTagOfGroupLeader and true) or false
	if not isUnitStillGroupLeader then
		--Do a new "is unit in group check + get group leader" by simulating a group update
		-->and if the player is dead or the player is the group leader: Disable the sound notifications
		onGroupStatusChange(false, false, true, false)
		return
	end

	local settings = FCOAB.settingsVars.settings

	--Get the x & y coordinates of the group leader
	local normX, normY = GetMapPlayerPosition(unitTagOfGroupLeader)

	--get the distance to the group leader
	local distToGroupLeader = getDistanceToLocalCoords(normX, normY)
	local distToGroupleaderCheckValue = settings.groupLeaderSoundDistance
	--is the player more than x meters away from the groupLeader
	if distToGroupLeader <= distToGroupleaderCheckValue then
		--We are near enough, no sound needs to be played
		--Reset the last played sound time so the next time we looka t the group leader and are not near enough anymore, the sound will be played again
		lastPlayed.groupLeader = 0
		return
	end

	--Check if the player is looking into the group leader's direction
	local isPlayerLookingAtGroupLeader, angle_degrees = isPlayerLookingAtUnit(normX, normY)
	if angle_degrees == nil then return end

	--d(">lookingAtGroupLead: " ..tos(isPlayerLookingAtGroupLeader) .. ", angle: " ..tos(angle_degrees))

	--[[
	FCOAB._rads = {
		groupLeader = {
			x = normX,
			y = normY,
		},
		player = {
			x = playerNormX,
			y = playerNormY,
		},
		opp = opp,
		adj = adj,
		rads = rads,
		rotateHeading = rotateHeading,
		distance = distToGroupLeader,
	}
	]]
	--is the player more than 3 meters away from the groupLeader
	local now = GetGameTimeMilliseconds()

	local groupLeaderLookingAtAngleSoundPlayed = false
	if isPlayerLookingAtGroupLeader == true then
		local lastPlayedGroupLeader = lastPlayed.groupLeader
		local waitTime = settings.groupLeaderSoundDelay * 1000

		if lastPlayedGroupLeader == 0 or now >= (lastPlayedGroupLeader + waitTime) then
			lastPlayed.groupLeader = now
			playSoundLoopNow(settings.groupLeaderSoundName, settings.groupLeaderSoundRepeat)
			groupLeaderLookingAtAngleSoundPlayed = true

			if settings.groupLeaderDistanceToChat == true and (lastDistanceToGroupLeader == 0 or lastDistanceToGroupLeader ~= distToGroupLeader) then
				addToChatWithPrefix("Distance to group leader: " .. tos(distToGroupLeader))
			end
		end
	end

	--is the clock position of the group leader enabled?
	local groupLeaderDirectionPosition = settings.groupLeaderDirectionPosition
	if settings.groupLeaderClockPosition == true or groupLeaderDirectionPosition == true then
		if settings.groupLeaderClockPositionIfLookingAtGroupLeader == false then
			lastPlayed.groupLeaderClockPosition = 0
			return
		end
	else
		local groupLeaderAngle = settings.groupLeaderSoundAngle
		local groupLeaderAngleHalf = groupLeaderAngle / 2
		if angle_degrees >= (360 - groupLeaderAngleHalf) or angle_degrees <= groupLeaderAngleHalf then
			lastPlayed.groupLeaderClockPosition = 0
			return
		end
	end


	local lastPlayedGroupLeaderClockPosition = lastPlayed.groupLeaderClockPosition
	local waitTime = settings.groupLeaderClockPositionDelay * 1000

	if lastPlayedGroupLeaderClockPosition == 0 or now >= (lastPlayedGroupLeaderClockPosition + waitTime) then
		lastPlayed.groupLeaderClockPosition = now

		local groupLeaderClockPos = getClockPositionByAngle(angle_degrees)
		if lastGroupLeaderClockPosition == 0 or lastGroupLeaderClockPosition ~= groupLeaderClockPos or (lastGroupLeaderClockPosition == groupLeaderClockPos and settings.groupLeaderClockPositionRepeatSame == true) then
			lastGroupLeaderClockPosition = groupLeaderClockPos

			local chatGroupLeaderText = tos(groupLeaderClockPos)
			--is the direction / quarter position of the group leader enabled?
			if groupLeaderDirectionPosition == true then
				chatGroupLeaderText = nil
				local chatGroupLeaderDirectionPosition = settings.chatGroupLeaderDirectionPosition
				local directionQuarter = getDirectionQuarterByAngle(angle_degrees)
				--Get the direction based on the determined clock position
				if directionQuarter ~= nil then
					chatGroupLeaderText = chatGroupLeaderDirectionPosition[directionQuarter]
				end
			end
			addToChatWithPrefix(chatGroupLeaderText, settings.chatGroupLeaderClockPositionPrefix, false)
		end
	end
end

runGroupLeaderUpdates = function (doEnable, forced)
--d("[FCOAB]runGroupLeaderUpdates - doEnable: " ..tos(doEnable) .. ", forced: " ..tos(forced))
	if doEnable and (forced or FCOAB.settingsVars.settings.groupLeaderSound) then
		--Check every 1000ms = 1 second for the position of the group leader
		isGroupLeaderUpdateEventActive = true
		EM:RegisterForUpdate(groupLeaderPosEventName, 1000,
				function() checkGroupLeaderPos() end
		)
	else
		isGroupLeaderUpdateEventActive = false
		--Reset the GroupLeader data
		groupLeaderData = {}
		EM:UnregisterForUpdate(groupLeaderPosEventName)
	end
end


local function onPlayerCombatState(eventId, inCombat)
--d("[FCOAB]PlayerCombat: " ..tos(inCombat))
	--New combat: Reset the last hit target names and unitIds
	local settings = FCOAB.settingsVars.settings
	if inCombat == true then
		--Leave the target markers for an easier find until the despawn of the unit (which should happen automatically as they are dead!)
		--[[
		--Reset the target markers again
		if enemyNumber > 0 or NonContiguousCount(targetMarkersApplied) > 0 then
			for _, targetMarkerApplied in pairs(targetMarkersApplied) do
				--Try to assign all the target markers which have been applied to the enemeies before, to the current
				--unit below the reticle (so they get removed on the old one). If no unit is below the reticle the markers will be assigned to myself
				--Add
				AssignTargetMarkerToReticleTarget(targetMarkerApplied)
				--Remove again
				AssignTargetMarkerToReticleTarget(targetMarkerApplied)
			end
		end
		]]


		hitTargetsUnitIds = {}
		hitTargetsNames = {}

		targetMarkersApplied = {}
		targetMarkersNumbersApplied = {}

		hadLastCombatAnyChatMessage = false
		wasNarrationQueueCleared = false
	else
		--Delete open chat text messages about combat (might delete other chat messages too)
		if isAccessibilityModeEnabled() and isAccessibilitySettingEnabled(ACCESSIBILITY_SETTING_TEXT_CHAT_NARRATION) == true then
			if not wasNarrationQueueCleared and hadLastCombatAnyChatMessage == true and (settings.showReticleOverUnitHealthInChat == true or settings.combatTipToChat == true) then
				ClearNarrationQueue(NARRATION_TYPE_TEXT_CHAT)
				wasNarrationQueueCleared = true
			end
		end
	end

	if inCombat == true then
		if settings.combatStartSound then
			playSoundLoopNow(settings.combatStartSoundName, settings.combatStartSoundRepeat)
		end
	else
		--Player left combat
		if settings.combatEndSound then
			playSoundLoopNow(settings.combatEndSoundName, settings.combatEndSoundRepeat)
		end
	end

	local combatStartEndInfo = settings.combatStartEndInfo
	if combatStartEndInfo == true then
		local yourHealth, healthMax = 					GetUnitPower(CON_PLAYER, 	COMBAT_MECHANIC_FLAGS_HEALTH)
		local yourMagicka, magickaMax = 				GetUnitPower(CON_PLAYER, 	COMBAT_MECHANIC_FLAGS_MAGICKA)
		local yourStamina, staminaMax = 				GetUnitPower(CON_PLAYER, 	COMBAT_MECHANIC_FLAGS_STAMINA)
		local yourUltimate, ultimateMax = 				GetUnitPower(CON_PLAYER, 	COMBAT_MECHANIC_FLAGS_ULTIMATE, HOTBAR_CATEGORY_PRIMARY)
		local yourUltimateBackbar, ultimateMaxBackbar = GetUnitPower(CON_PLAYER, 	COMBAT_MECHANIC_FLAGS_ULTIMATE, HOTBAR_CATEGORY_BACKUP)
		--Player got into combat
		if inCombat == true then
			addToChatWithPrefix("COMBAT START!")
		else
			addToChatWithPrefix("COMBAT END!")
		end
		local healthPercent = 	getPercent(yourHealth, healthMax)
		local magickaPercent = 	getPercent(yourMagicka, magickaMax)
		local staminaPercent = 	getPercent(yourStamina, staminaMax)
		local ultimatePrimaryPercent = 	getPercent(yourUltimate, ultimateMax)
		local ultimateBackupPercent = 	getPercent(yourUltimateBackbar, ultimateMaxBackbar)

		addToChatWithPrefix(strfor("Your health %s%%, magicka %s%%, stamina %s%%, ultimate %s/%s%%", tos(healthPercent), tos(magickaPercent), tos(staminaPercent), tos(ultimatePrimaryPercent), tos(ultimateBackupPercent)), nil)
	end
end

local mapPinsWithAnimation = {}
local function applyPingPongAnimationToMapPin(mapPin, scaling)
--d("[FCOAB]applyPingPongAnimationToMapPin - mapPin: " ..tos(mapPin) .. "; scaling: " ..tos(scaling))
	if mapPin == nil  or type(mapPin) ~= "userdata" then return end

	scaling = scaling or 4
	if MAP_MODE_VOTANS_MINIMAP ~= nil and ZO_WorldMap_GetMode() == MAP_MODE_VOTANS_MINIMAP then
		scaling=2
	end
	local animation, timeline
	local mapPinAnimationData = mapPinsWithAnimation[mapPin]
	if mapPinAnimationData ~= nil then
		animation, timeline = mapPinAnimationData.animation, mapPinAnimationData.timeline
--d(">animation and timeline found")
	end
	if animation == nil or timeline == nil then
		animation, timeline = CreateSimpleAnimation(ANIMATION_SCALE, mapPin, 250)
--d(">animation and timeline created new!")
	end
	if animation ~= nil and timeline ~= nil then
--d(">animation and timeline added to mapPin lookup table")
		mapPinsWithAnimation[mapPin] = { animation=animation, timeline = timeline }

		animation:SetScaleValues(1, scaling)
		animation:SetDuration(150)
		timeline:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, 3)
		timeline:PlayFromStart()
	end
end

local function checkGroupTagIsVisibleAndGetMapPin(groupTagCheck)
--d("[FCOAB]checkGroupTagIsVisibleAndGetMapPin - groupTagCheck: " .. tos(groupTagCheck))
	if IsUnitGrouped(CON_PLAYER) and ZO_WorldMap_IsPinGroupShown(MAP_FILTER_GROUP_MEMBERS) then
		if not groupTagCheck == "groupLeader" then return end --currently only the groupleader pin is supported

		local isInDungeon = GetMapContentType() == MAP_CONTENT_DUNGEON
		local isInHouse = GetCurrentZoneHouseId() ~= 0
		for i = 1, MAX_GROUP_SIZE_THRESHOLD do
			local doSkip = false
			local groupTag = ZO_Group_GetUnitTagForGroupIndex(i)
			local isLeader = IsUnitGroupLeader(groupTag)
			if groupTagCheck == "groupLeader" then
				if not isLeader then
--d("<skipping groupTag: " ..tos(groupTag))
					doSkip = true
				end
			end
			if not doSkip then
				local isBreadcrumbed = IsUnitWorldMapPositionBreadcrumbed(groupTag)
--d(">checking groupTag: " ..tos(groupTag) .. ", isBreadcrumbed: " ..tos(isBreadcrumbed))
				if DoesUnitExist(groupTag) and IsUnitOnline(groupTag) then --and not AreUnitsEqual("player", groupTag) then
					local isGroupMemberHiddenByInstance = false
					-- If we're in an instance and it has its own map, it's going to be a dungeon map or house. Don't show on the map if we're on different instances/layers
					-- If it doesn't have its own map, we're okay to show the group member regardless of instance
					if DoesCurrentMapMatchMapForPlayerLocation() and IsGroupMemberInSameWorldAsPlayer(groupTag) and (isInDungeon or isInHouse) then
						if not IsGroupMemberInSameInstanceAsPlayer(groupTag) then
							-- We're in the same world as the group member, but a different instance
							isGroupMemberHiddenByInstance = true
						elseif not IsGroupMemberInSameLayerAsPlayer(groupTag) then
							-- We're in the same instance as the group member, but a different layer
							isGroupMemberHiddenByInstance = not isBreadcrumbed
						end
					end

					if not isGroupMemberHiddenByInstance then
						local _, _, _, isInCurrentMap, _ = GetMapPlayerPosition(groupTag)
--d(">groupMember is NOT hidden by instance, isInCurrentMap: " .. tos(isInCurrentMap))
						if isInCurrentMap then
							if not isBreadcrumbed or (isBreadcrumbed and FCOAB.settingsVars.settings.groupLeaderPinPingPongBreadcrumbed) then
								--self:CreatePin(isLeader and MAP_PIN_TYPE_GROUP_LEADER or MAP_PIN_TYPE_GROUP, tagData, x, y, NO_RADIUS, NO_BORDER_INFO, isSymbolicLocation)
								local groupLeaderPin = ZO_WorldMap_GetPinManager():FindPin("group", MAP_PIN_TYPE_GROUP_LEADER, nil)
								if groupLeaderPin ~= nil then
									local groupLeaderTag = groupLeaderPin:GetUnitTag()
--(">found group member tag on current map - key: " ..tos(groupLeaderPin) .. "; groupLeaderTag: " ..tos(groupLeaderTag))
									return groupLeaderPin:GetControl()
								end
							end
						end
					end
				end
			end
		end
	end
end


--Play an animation on the player pin: PingPong -> To easily see the arrow on the map
local function playerMapPinPingPong(fromKeybind)
	local myPin = ZO_WorldMap_GetPinManager():GetPlayerPin():GetControl()
	if myPin then
		local playerPinScaling = FCOAB.settingsVars.settings.playerPinPingPongScaling
		--Votan's MiniMap is shown: Scale only with a fixed multiplier 2, else the pin will be too big
		if MAP_MODE_VOTANS_MINIMAP ~= nil and ZO_WorldMap_GetMode() == MAP_MODE_VOTANS_MINIMAP then
			playerPinScaling = 2
		end
		local animation, timeline = CreateSimpleAnimation(ANIMATION_SCALE, myPin, 150)
		animation:SetScaleValues(1, playerPinScaling)
		animation:SetDuration(150)
		timeline:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, 3)
		timeline:PlayFromStart()
	end
end

local function mapPinPingPong(whichMapPin, fromKeybind)
--d("[FCOAB]mapPinPingPong - whichMapPin: " ..tos(whichMapPin) .. "; fromKeybind: " ..tos(fromKeybind))
	if whichMapPin == nil then return end
	fromKeybind = fromKeybind or false

	--Group leader map pin ping pong effect, if we are grouped and aren't the group leader outself
	if whichMapPin == "groupleader" and IsUnitGrouped(CON_PLAYER) then --and not IsUnitGroupLeader(CON_PLAYER) then
		if not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_GROUP_MEMBERS) then
			--d("<abort: not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_GROUP_MEMBERS)")
			return
		end --No group pins shown on the map? Then do not add any ping pong effect

		local settings = FCOAB.settingsVars.settings
		if not settings.groupLeaderPinPingPong and not fromKeybind then
			--d("<abort: settings.groupLeaderPinPingPong DISABLED")
			return false
		end

		--local player = ZO_WorldMap_GetPinManager():GetPlayerPin():GetControl()
		--local group = ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_GROUP]
		--local leader = ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_GROUP_LEADER]

		local leaderPin = checkGroupTagIsVisibleAndGetMapPin("groupLeader")
		applyPingPongAnimationToMapPin(leaderPin, settings.groupLeaderPinPingPongScaling)

	elseif whichMapPin == "player" then
		playerMapPinPingPong(fromKeybind)
	end
end

local mapSceneChangeCallBackRegistered
local function registerGroupLeaderMapPinPingPong()
--d("[FCOAB]registerGroupLeaderMapPinPingPong - setting group leader: " ..tos(FCOAB.settingsVars.settings.groupLeaderPinPingPong))
	if FCOAB.settingsVars.settings.groupLeaderPinPingPong == true then
        if not mapSceneChangeCallBackRegistered then
			local function mapSceneCallBack(p_oldState, p_newState)
				if p_newState == SCENE_SHOWN then
					mapPinPingPong("groupleader", false)
				end
			end
            --Register a callback function for the wolrd map scene
            --as we are in accessibilitymode we only need to register the callback for the gamepad map
			mapSceneKeyboard:RegisterCallback("StateChange", function(oldState, newState)
                mapSceneCallBack(oldState, newState)
            end)
            mapSceneGamepad:RegisterCallback("StateChange", function(oldState, newState)
                mapSceneCallBack(oldState, newState)
            end)


			CM:RegisterCallback("OnWorldMapChanged", function()
--d("[FCOAB]WorldMapChanged")
				zo_callLater(function() --delay a bit so the internal key/index of the map pin properly updates to the groups -> ZO_WorldMapPins_Manager:RefreshGroupPins
					mapPinPingPong("groupleader", false)
				end, 10)

			end)

            mapSceneChangeCallBackRegistered = true
        end
	end
end

-- gamepad_worldMap uses GamepadUIMode (allowFallthrough false), which blocks General-layer addon keybinds.
-- Push a dedicated fallthrough layer above UI shortcuts via ZO_ActionLayerFragment on GAMEPAD_WORLD_MAP_SCENE.
local function registerGamepadWorldMapActionLayerFragment()
	--Only register the fragment for the gamepad map scecne once
	if fcoabGamepadMapActionLayerFragment ~= nil or GAMEPAD_WORLD_MAP_SCENE == nil then return end
	fcoabGamepadMapActionLayerFragment = ZO_ActionLayerFragment:New(GetString(SI_KEYBINDINGS_LAYER_FCOAB_GAMEPAD_MAP))
	GAMEPAD_WORLD_MAP_SCENE:AddFragment(fcoabGamepadMapActionLayerFragment)
end

------------------------------------------------------------------------------------------------------------------------
-- Keybindings
------------------------------------------------------------------------------------------------------------------------
function FCOAB.ToggleLAMSetting(settingId, settingIdOther)
	local settings = FCOAB.settingsVars.settings
	if settings == nil or settings[settingId] == nil then return end

	local currentValue = settings[settingId]

	---Toggle between 2 setting values: 1 off, other on, and vice versa
	if settingIdOther ~= nil then
		if settings[settingIdOther] == nil then return end
		local currentValueOther = settings[settingIdOther]

		local newValue = not currentValue
		if newValue ~= nil then
			FCOAB.settingsVars.settings[settingId] = newValue
			outputLAMSettingsChangeToChat(tos(newValue), tos(settingId), true)
		end
		local newValueOther = not currentValueOther
		if newValueOther ~= nil then
			FCOAB.settingsVars.settings[settingIdOther] = newValueOther
			outputLAMSettingsChangeToChat(tos(newValueOther), tos(settingIdOther), true)
		end
	else
		---Only toggle the 1 setting value
		local newValue = not currentValue
		if newValue ~= nil then
			FCOAB.settingsVars.settings[settingId] = newValue
			outputLAMSettingsChangeToChat(tos(newValue), tos(settingId), true)
		end
	end
end

local function addFluffielsPanicBeamToMultiRiderMount(name)
	if not FLUFFIELS_PANICBEAMS or not FLUFFIELS_PANICBEAMS.SetBFF then return end
	FLUFFIELS_PANICBEAMS.SetBFF((name ~= nil and FCOAB.settingsVars.settings.preferredGroupMountDisplayNameFluffielsPanicBeam == true and name) or nil)
end

function FCOAB.SavedPreferredPlayerForPassengerMount()
	local settings = FCOAB.settingsVars.settings
	--Get the old displayName
	local preferredGroupMountDisplayName = settings.preferredGroupMountDisplayName
	local oldPreferredGroupMountDisplayName = preferredGroupMountDisplayName
	if oldPreferredGroupMountDisplayName == nil or oldPreferredGroupMountDisplayName == "" then oldPreferredGroupMountDisplayName = "n/a" end

	--Get the new displayName below the reticle
	local newDisplayName = GetUnitDisplayName(CON_RETICLE_PLAYER)
	if newDisplayName ~= nil and newDisplayName ~= "" and newDisplayName ~= myDisplayName and newDisplayName ~= oldPreferredGroupMountDisplayName then
		FCOAB.settingsVars.settings.preferredGroupMountDisplayName = newDisplayName
		outputLAMSettingsChangeToChat("\'" .. tos(newDisplayName) .. "\' (before: " .. tos(oldPreferredGroupMountDisplayName) .. ")", "Preferred passenger mount accountName", true)

		addFluffielsPanicBeamToMultiRiderMount(newDisplayName)
	end
end

function FCOAB.PassengerMountWithPreferredPlayer()
	--Check if we are grouped
	if not IsUnitGrouped(CON_PLAYER) then
		addToChatWithPrefix("You need to be grouped to use the passenger mount!")
		return
	end

	local settings = FCOAB.settingsVars.settings
	local preferredGroupMountDisplayName = settings.preferredGroupMountDisplayName
	if preferredGroupMountDisplayName == nil then
		addToChatWithPrefix("You have not set a preferred AccountName for the passenger mount yet!")
		addToChatWithPrefix("You can either change the account name at the addon settings, or use the keybind to save the current player below the reticle.")
		return
	end

	--Check if preferred player is in our group
	local foundInGroup = false
	local unitOfPrefferedPlayer
	for unitIndexOfGroup=1, GetGroupSize(), 1 do
		if foundInGroup == false then
			local unitTagOfGroup = GetGroupUnitTagByIndex(unitIndexOfGroup)
			if unitTagOfGroup ~= nil then
				--The group member is online and alive and not n combat
				if IsUnitOnline(unitTagOfGroup) == true and IsUnitDead(unitTagOfGroup) == false and IsUnitInCombat(unitTagOfGroup) == false then
					local unitDisplayNameOfGroupMember = GetUnitDisplayName(unitTagOfGroup)
					--We are not checking ourself
					if unitDisplayNameOfGroupMember ~= myDisplayName and unitDisplayNameOfGroupMember == preferredGroupMountDisplayName then
						unitOfPrefferedPlayer = unitTagOfGroup
						foundInGroup = true
						break
					end
				end
			end
		end
	end
	if foundInGroup == true and unitOfPrefferedPlayer ~= nil then
		--Check if grouped player is near enough and in our zone
		if IsUnitInGroupSupportRange(unitOfPrefferedPlayer) then
			--Mount with the grouped player now
			UseMountAsPassenger(preferredGroupMountDisplayName)
		end
	end
end


--Gamepad mode -> Keyboard mode
--Keyboard mode -> Gamepad mode + Accessibility mode on
function FCOAB.ToggleAccessibilityMode()
	--Check if Accessibility mode is enabled
	local isAccessiModeEnabled = isAccessibilityModeEnabled()

	--Toggle the Accessibility mode
	local newState = (isAccessiModeEnabled == true and '0') or '1'
	local accessibilityModeStr = (newState == '0' and "Off") or 'On'

	outputLAMSettingsChangeToChat("\'" .. tos(accessibilityModeStr) .. "\'", "- Accessibility Mode", true)
	changeAccessibilitSettingTo(newState, ACCESSIBILITY_SETTING_ACCESSIBILITY_MODE)
end

function FCOAB.ToggleAccessibilityChatReader()
	--Check if Accessibility mode is enabled
	if not isAccessibilityModeEnabled() then return end

	local isAccessiModeSettingEnabled = isAccessibilitySettingEnabled(ACCESSIBILITY_SETTING_TEXT_CHAT_NARRATION)
	local newState = (isAccessiModeSettingEnabled == true and '0') or '1'
	local accessibilityModeStr = (newState == '0' and "Off") or 'On'

	outputLAMSettingsChangeToChat("\'" .. tos(accessibilityModeStr) .. "\'", "- Chat Reader of Accessibility Mode", true)
	changeAccessibilitSettingTo(newState, ACCESSIBILITY_SETTING_TEXT_CHAT_NARRATION)
end

function FCOAB.ToggleAccessibilityMenuReader()
	--Check if Accessibility mode is enabled
	if not isAccessibilityModeEnabled() then return end

	local isAccessiModeSettingEnabled = isAccessibilitySettingEnabled(ACCESSIBILITY_SETTING_SCREEN_NARRATION)
	local newState = (isAccessiModeSettingEnabled == true and '0') or '1'
	local accessibilityModeStr = (newState == '0' and "Off") or 'On'

	outputLAMSettingsChangeToChat("\'" .. tos(accessibilityModeStr) .. "\'", "- Menu reader of Accessibility Mode", true)
	changeAccessibilitSettingTo(newState, ACCESSIBILITY_SETTING_SCREEN_NARRATION)
end

function FCOAB.ClearAccessibilityChatReaderQueue()
	--Check if Accessibility mode is enabled
	if not isAccessibilityModeEnabled() then return end
	if isAccessibilitySettingEnabled(ACCESSIBILITY_SETTING_TEXT_CHAT_NARRATION) == true then
		ClearNarrationQueue(NARRATION_TYPE_TEXT_CHAT)
	end
end

function FCOAB.LetMeHearCurrentValue(valueToPlay)
	if type(valueToPlay) ~= "string" or valueToPlay == "" then return end
	local readThisText
	--Play the actual group leader distance as Narration
	if valueToPlay == "groupLeaderDistance" and IsUnitGrouped(CON_PLAYER) == true then
		local actualGroupLeaderDistance = getGroupLeaderDistance()
		if actualGroupLeaderDistance ~= nil and actualGroupLeaderDistance >= 0 then
			readThisText = "Distance to group leader: " ..tos(actualGroupLeaderDistance)
		end
	end


	if readThisText ~= nil and readThisText ~= "" then
		addToChatWithPrefix(readThisText, nil, true) --no prefix, only text!
	end
end

function FCOAB.MapPinPingPong(mapPinType)
	mapPinPingPong(mapPinType, true)
end

local function onMountStateChange(eventId, mounted)
	local settings = FCOAB.settingsVars.settings
	--Onyl if Fluffiels Panic Beams is enabled
	if not settings.preferredGroupMountDisplayNameFluffielsPanicBeam == true or not FLUFFIELS_PANICBEAMS then
		return
	end

	if mounted == true then
		if settings.preferredGroupMountDisplayNameFluffielsPanicBeamDisableWhileMounted == true then
			--Disable the Fluffiels Panic Beam if you are mounted
			addFluffielsPanicBeamToMultiRiderMount(nil)
		end
	else
		--Enable the Fluffiels Panic Beam if you get unmounted
		addFluffielsPanicBeamToMultiRiderMount(settings.preferredGroupMountDisplayName)
	end
end

--===================== SLASH COMMANDS ==============================================
--Show a help inside the chat
local function help()
	addToChatWithPrefix(FCOAB.addonVars.addonNameMenuDisplay)
end

--Check the commands ppl type to the chat
local function command_handler(args)
    --Parse the arguments string
	local options = {}
    local searchResult = { string.match(args, "^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end

	if #options == 0 or options[1] == "" or options[1] == "help" or options[1] == "hilfe" or options[1] == "aide" or options[1] == "list" then
		help()
	else
	end
end

--returns the table  playSoundData = {number repeats, milliseconds delay, number playMultipleTimesToIncreaseVolume}
local function getPreviewDataTab(soundType, playCount, index)
	local settings = FCOAB.settingsVars.settings
	playCount      = playCount or 1
	--{number playCount, number delayInMS, number increaseVolume}, -- table or function returning a table. If this table is provided the chosen sound will be played playCount (default is 1) times after each other, with a delayInMS (default is 0) in milliseconds in between, and each played sound will be played increaseVolume times (directly at the same time) to increase the volume (default is 1, max is 10) (optional)
	if soundType == "CompassTrackedQuest" then
		return {
			playCount = playCount,
			delayInMS = settings.compassTrackedQuestSoundDelay * 1000, --transfer seconds to milliseconds
			increaseVolume = settings.compassTrackedQuestSoundRepeat,
		}
	elseif soundType == "CompassPlayerWaypoint" then
		return {
			playCount = playCount,
			delayInMS = settings.compassPlayerWaypointSoundDelay * 1000, --transfer seconds to milliseconds
			increaseVolume = settings.compassPlayerWaypointSoundRepeat,
		}
	elseif soundType == "CompassGroupRallyPoint" then
		return {
			playCount = playCount,
			delayInMS = settings.compassGroupRallyPointSoundDelay * 1000, --transfer seconds to milliseconds
			increaseVolume = settings.compassGroupRallyPointSoundRepeat,
		}
	elseif soundType == "GroupLeader" then
		return {
			playCount = playCount,
			delayInMS = settings.groupLeaderSoundDelay * 1000, --transfer seconds to milliseconds
			increaseVolume = settings.groupLeaderSoundRepeat,
		}
	elseif soundType == "CombatStart" then
		return {
			playCount = playCount,
			delayInMS = 0,
			increaseVolume = settings.combatStartSoundRepeat,
		}
	elseif soundType == "CombatEnd" then
		return {
			playCount = playCount,
			delayInMS = 0,
			increaseVolume = settings.combatEndSoundRepeat,
		}
	elseif soundType == "CombatTip" then
		return {
			playCount = playCount,
			delayInMS = 0,
			increaseVolume = settings.combatTipSoundRepeat[index],
		}
	elseif soundType == "MovementBlocked" then
		return {
			playCount = playCount,
			delayInMS = 0,
			increaseVolume = settings.tryingToMoveButBlockedSoundRepeat,
		}
	end
end

-- Build the options menu
local function BuildAddonMenu()
	local panelData = {
		type 				= 'panel',
		name 				= addonVars.addonNameMenu,
		displayName 		= addonVars.addonNameMenuDisplay,
		author 				= addonVars.addonAuthor,
		version 			= addonVars.addonVersionOptions,
		registerForRefresh 	= true,
		registerForDefaults = true,
		slashCommand 		= "/FCOABs",
	}

	local savedVariablesOptions = {
		[1] = "Per character",
		[2] = "Account wide",
	}
	local savedVariablesOptionsValues = {
		[1] = 1,
		[2] = 2,
	}

	local settings = FCOAB.settingsVars.settings
	local defaultSettings = FCOAB.settingsVars.defaults

	FCOAB.SettingsPanel = LAM:RegisterAddonPanel(addonName, panelData)


	--LAM 2.0 callback function if the panel was created
	local passenderMountEditBoxAutoCompleteCreated = false
	local FCOABLAMPanelCreated = function(panel)
        if panel ~= FCOAB.SettingsPanel then return end
--d("[FCOAB]FCOABLAMPanelCreated")
		if FCOAB_PREFERRED_PASSENGER_MOUNT_EDITBOX ~= nil and passenderMountEditBoxAutoCompleteCreated == false then
--d(">found FCOAB_PREFERRED_PASSENGER_MOUNT_EDITBOX")
			local refCtrl = FCOAB_PREFERRED_PASSENGER_MOUNT_EDITBOX
			local editControlGroup = ZO_EditControlGroup:New()
			FCOAB.passengerMountDisplayNameEditControlGroup = editControlGroup
			local autoComplete = ZO_AutoComplete:New(refCtrl.editbox, { AUTO_COMPLETE_FLAG_ALL }, { AUTO_COMPLETE_FLAG_GUILD_NAMES }, AUTO_COMPLETION_ONLINE_OR_OFFLINE, MAX_AUTO_COMPLETION_RESULTS)
			FCOAB.passengerMountDisplayNameAutoComplete = autoComplete
			editControlGroup:AddEditControl(refCtrl.editbox, autoComplete)

			passenderMountEditBoxAutoCompleteCreated = true
		end
    end

	local optionsTable = {    -- BEGIN OF OPTIONS TABLE

		{
			type = 'description',
			text = "This AddOn provides little helpers for blind players",
		},
		--==============================================================================
		{
			type = 'header',
			name = "Settings to chat",
		},
		{
			type = "checkbox",
			name = "Changed setting value: To chat",
			tooltip = "Output the currently changed value of this addon to the chat, including the name of the changed setting",
			getFunc = function() return settings.thisAddonLAMSettingsSetFuncToChat end,
			setFunc = function(value)
				settings.thisAddonLAMSettingsSetFuncToChat = value
				outputLAMSettingsChangeToChat(tos(value), "Changed setting value: To chat")
			end,
			default = defaultSettings.thisAddonLAMSettingsSetFuncToChat,
			--disabled = function() false end,
		},
		--==============================================================================
		{
			type = 'header',
			name = "Settings save mode",
		},
		{
			type          = 'dropdown',
			name          = "SavedVariables save mode",
			tooltip       = "Chose how your settings will be saved",
			choices       = savedVariablesOptions,
			choicesValues = savedVariablesOptionsValues,
			getFunc       = function() return FCOAB.settingsVars.defaultSettings.saveMode end,
			setFunc       = function(value)
				FCOAB.settingsVars.defaultSettings.saveMode = value
				ReloadUI()
			end,
			warning       = "Changing this setting will reload your UI!",
		},
		--==============================================================================
		{
			type = 'header',
			name = "Chat",
		},
		{
			type = "editbox",
			name = "Chat reader prefix text, of this addon",
			tooltip = "Choose a prefix which should be printed in front of all chat messages which this addon writes to chat, so that the Accessibility screen reader reads it loud to you, and you notice the text is coming from this addon.\nThe default value is ´",
			getFunc = function() return settings.chatAddonPrefix end,
			setFunc = function(value)
				settings.chatAddonPrefix = value
				outputLAMSettingsChangeToChat(tos(value), "Chat reader prefix text, of this addon")
			end,
			isMultiline = false, -- boolean (optional)
			isExtraWide = false, -- boolean (optional)
			maxChars = 200, -- number (optional)
			--textType = TEXT_TYPE_NUMERIC, -- number (optional) or function returning a number. Valid TextType numbers: TEXT_TYPE_ALL, TEXT_TYPE_ALPHABETIC, TEXT_TYPE_ALPHABETIC_NO_FULLWIDTH_LATIN, TEXT_TYPE_NUMERIC, TEXT_TYPE_NUMERIC_UNSIGNED_INT, TEXT_TYPE_PASSWORD
			width = "full", -- or "half" (optional)
			--disabled = function() return false end, -- or boolean (optional)
			default = defaultSettings.chatAddonPrefix, -- default value or function that returns the default value (optional)
		},

		--==============================================================================
		{
			type = 'header',
			name = "Compass",
		},
		{
			type = "checkbox",
			name = "Show compass data in chat",
			tooltip = "Show the currently looked at compass data in the chat",
			getFunc = function() return settings.compassToChatText end,
			setFunc = function(value)
				settings.compassToChatText = value
				outputLAMSettingsChangeToChat(tos(value), "Show compass data in chat")
				CreateCompassHooks()
			end,
			default = defaultSettings.compassToChatText,
			--disabled = function() false end,
		},
		{
			type = "checkbox",
			name = "Compass to chat: Hide group leader",
			tooltip = "Hide the group leader's text in chat if you look at it and the compass shows the name at the center.",
			getFunc = function() return settings.compassToChatTextSkipGroupLeader end,
			setFunc = function(value)
				settings.compassToChatTextSkipGroupLeader = value
				outputLAMSettingsChangeToChat(tos(value), "Compass to chat: Hide groupleader")
			end,
			disabled = function() return not settings.compassToChatText  end,
			default = defaultSettings.compassToChatTextSkipGroupLeader,
			--disabled = function() false end,
		},
		{
			type = "checkbox",
			name = "Compass to chat: Hide group members",
			tooltip = "Hide the group members text in chat if you look at it and the compass shows the name at the center.",
			getFunc = function() return settings.compassToChatTextSkipGroupMember end,
			setFunc = function(value)
				settings.compassToChatTextSkipGroupMember = value
				outputLAMSettingsChangeToChat(tos(value), "Compass to chat: Hide groupleader")
			end,
			disabled = function() return not settings.compassToChatText  end,
			default = defaultSettings.compassToChatTextSkipGroupMember,
			--disabled = function() false end,
		},

		{
			type    = "checkbox",
			name    = "Compass: Tracked quest - Play sound",
			tooltip = "Plays a sound repetively if your compass' center is heading into the direction of the currently tracked quest.\nAttention: If there are multiple quest objects shown at the compass, for the same quest, this addon is not able to differ them and will play the sound for all of these shown compass pins!",
			getFunc = function() return settings.compassTrackedQuestSound end,
			setFunc = function(value)
				settings.compassTrackedQuestSound = value
				outputLAMSettingsChangeToChat(tos(value), "Compass: Tracked quest - Play sound")
				CreateCompassHooks()
			end,
			default = defaultSettings.compassTrackedQuestSound,
			requiresReload = false,
		},
		{
			type = "soundslider",
			name = "Compass: Choose tracked quest sound", -- or string id or function returning a string
			tooltip = "Choose the sound to play for the compass tracked quest at this horizontal slider. Changing the slider will play the sound as a preview 3 times, using the chosen delay too.", -- or string id or function returning a string (optional)
			getFunc = function() return settings.compassTrackedQuestSoundName end,
			setFunc = function(value)
				settings.compassTrackedQuestSoundName = value
				outputLAMSettingsChangeToChat(tos(value), "Compass: Choose tracked quest sound")
			end,
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			saveSoundIndex = false, -- or function returning a boolean (optional) If set to false (default) the internal soundName will be saved. If set to true the selected sound's index will be saved to the SavedVariables (the index might change if sounds get inserted later!).
			showSoundName = true, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be shown at the label of the slider, and at the tooltip too
			playSound = false, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be played via function PlaySound
			playSoundData = function() return getPreviewDataTab("CompassTrackedQuest", 3) end, --{number playCount, number delayInMS, number increaseVolume}, -- table or function returning a table. If this table is provided the chosen sound will be played playCount (default is 1) times after each other, with a delayInMS (default is 0) in milliseconds in between, and each played sound will be played increaseVolume times (directly at the same time) to increase the volume (default is 1, max is 10) (optional)
			showPlaySoundButton = true,
			noAutomaticSoundPreview = false,
			readOnly = false, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			disabled = function() return not settings.compassTrackedQuestSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.compassTrackedQuestSoundName, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			reference = "FCOAB_LAM_COMPASS_TRACKED_QUEST_SOUNDSLIDER", -- unique global reference to control (optional)
			width = "full",
		},
		{
			type = "slider",
			name = "Compass: Choose tracked quest delay (s)", -- or string id or function returning a string
			tooltip = "Choose the delay in seconds between each repetively played sound for the compass tracked quest at this horizontal slider", -- or string id or function returning a string (optional)
			getFunc = function() return settings.compassTrackedQuestSoundDelay end,
			setFunc = function(value)
				settings.compassTrackedQuestSoundDelay = value
				outputLAMSettingsChangeToChat(tos(value), "Compass: Choose tracked quest delay (s)")
			end,
			min = 0,
			max = 30,
			step = 0.25, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 2, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.compassTrackedQuestSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.compassTrackedQuestSoundDelay, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},
		{
			type = "slider",
			name = "Compass: Volume tracked quest sound", -- or string id or function returning a string
			tooltip = "Playing the same sound multiple times increases the volume. Choose how often you want to repeat the played sound for the compass tracked quest to increase the volume with this slider.",
			getFunc = function() return settings.compassTrackedQuestSoundRepeat end,
			setFunc = function(value)
				settings.compassTrackedQuestSoundRepeat = value
				outputLAMSettingsChangeToChat(tos(value), "Compass: Volume tracked quest sound")
			end,
			min = 1,
			max = 10,
			step = 1, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.compassTrackedQuestSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.compassTrackedQuestSoundRepeat, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},


		{
			type    = "checkbox",
			name    = "Compass: Player waypoint - Play sound",
			tooltip = "Plays a sound repetively if your compass' center is heading into the direction of your set player waypoint.",
			getFunc = function() return settings.compassPlayerWaypointSound end,
			setFunc = function(value)
				settings.compassPlayerWaypointSound = value
				outputLAMSettingsChangeToChat(tos(value), "Compass: Player waypoint - Play sound")
				CreateCompassHooks()
			end,
			default = defaultSettings.compassPlayerWaypointSound,
			requiresReload = false,
		},
		{
			type = "soundslider",
			name = "Compass: Choose player waypoint sound", -- or string id or function returning a string
			tooltip = "Choose the sound to play for the compass player waypoint at this horizontal slider. Changing the slider will play the sound as a preview 3 times, using the chosen delay too.", -- or string id or function returning a string (optional)
			getFunc = function() return settings.compassPlayerWaypointSoundName end,
			setFunc = function(value)
				settings.compassPlayerWaypointSoundName = value
				outputLAMSettingsChangeToChat(tos(value), "Compass: Choose player waypoint sound")
			end,
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			saveSoundIndex = false, -- or function returning a boolean (optional) If set to false (default) the internal soundName will be saved. If set to true the selected sound's index will be saved to the SavedVariables (the index might change if sounds get inserted later!).
			showSoundName = true, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be shown at the label of the slider, and at the tooltip too
			playSound = false, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be played via function PlaySound
			playSoundData = function() return getPreviewDataTab("CompassPlayerWaypoint", 3) end, --{number playCount, number delayInMS, number increaseVolume}, -- table or function returning a table. If this table is provided the chosen sound will be played playCount (default is 1) times after each other, with a delayInMS (default is 0) in milliseconds in between, and each played sound will be played increaseVolume times (directly at the same time) to increase the volume (default is 1, max is 10) (optional)
			showPlaySoundButton = true,
			noAutomaticSoundPreview = false,
			readOnly = false, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.compassPlayerWaypointSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.compassPlayerWaypointSoundName, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			reference = "FCOAB_LAM_COMPASS_PLAYER_WAYPOINT_SOUNDSLIDER" -- unique global reference to control (optional)
		},
		{
			type = "slider",
			name = "Compass: Choose player waypoint delay (s)", -- or string id or function returning a string
			tooltip = "Choose the delay in seconds between each repetively played sound for the compass player waypoint at this horizontal slider", -- or string id or function returning a string (optional)
			getFunc = function() return settings.compassPlayerWaypointSoundDelay end,
			setFunc = function(value)
				settings.compassPlayerWaypointSoundDelay = value
				outputLAMSettingsChangeToChat(tos(value), "Compass: Choose player waypoint delay (s)")
			end,
			min = 0,
			max = 30,
			step = 0.25, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 2, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.compassPlayerWaypointSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.compassPlayerWaypointSoundDelay, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},
		{
			type = "slider",
			name = "Compass: Volume player waypoint sound", -- or string id or function returning a string
			tooltip = "Playing the same sound multiple times increases the volume. Choose how often you want to repeat the played sound for the compass player waypoint to increase the volume with this slider.",
			getFunc = function() return settings.compassPlayerWaypointSoundRepeat end,
			setFunc = function(value)
				settings.compassPlayerWaypointSoundRepeat = value
				outputLAMSettingsChangeToChat(tos(value), "Compass: Volume player waypoint sound")
			end,
			min = 1,
			max = 10,
			step = 1, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.compassPlayerWaypointSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.compassPlayerWaypointSoundRepeat, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},

		{
			type    = "checkbox",
			name    = "Compass: Group rally point - Play sound",
			tooltip = "Plays a sound repetively if your compass' center is heading into the direction of your set group rally point.",
			getFunc = function() return settings.compassGroupRallyPointSound end,
			setFunc = function(value)
				settings.compassGroupRallyPointSound = value
				outputLAMSettingsChangeToChat(tos(value), "Compass: Group rally point - Play sound")
				CreateCompassHooks()
			end,
			default = defaultSettings.compassGroupRallyPointSound,
			requiresReload = false,
		},
		{
			type = "soundslider",
			name = "Compass: Choose group rally point sound", -- or string id or function returning a string
			tooltip = "Choose the sound to play for the compass group rally point at this horizontal slider. Changing the slider will play the sound as a preview 3 times, using the chosen delay too.", -- or string id or function returning a string (optional)
			getFunc = function() return settings.compassGroupRallyPointSoundName end,
			setFunc = function(value)
				settings.compassGroupRallyPointSoundName = value
				outputLAMSettingsChangeToChat(tos(value), "Compass: Choose group rally point sound")
			end,
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			saveSoundIndex = false, -- or function returning a boolean (optional) If set to false (default) the internal soundName will be saved. If set to true the selected sound's index will be saved to the SavedVariables (the index might change if sounds get inserted later!).
			showSoundName = true, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be shown at the label of the slider, and at the tooltip too
			playSound = false, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be played via function PlaySound
			playSoundData = function() return getPreviewDataTab("CompassGroupRallyPoint", 3) end, --{number playCount, number delayInMS, number increaseVolume}, -- table or function returning a table. If this table is provided the chosen sound will be played playCount (default is 1) times after each other, with a delayInMS (default is 0) in milliseconds in between, and each played sound will be played increaseVolume times (directly at the same time) to increase the volume (default is 1, max is 10) (optional)
			showPlaySoundButton = true,
			noAutomaticSoundPreview = false,
			readOnly = false, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.compassGroupRallyPointSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.compassGroupRallyPointSoundName, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			reference = "FCOAB_LAM_COMPASS_GROUP_RALLY_POINT_SOUNDSLIDER" -- unique global reference to control (optional)
		},
		{
			type = "slider",
			name = "Compass: Choose group rally point delay (s)", -- or string id or function returning a string
			tooltip = "Choose the delay in seconds between each repetively played sound for the compass group rally point at this horizontal slider", -- or string id or function returning a string (optional)
			getFunc = function() return settings.compassGroupRallyPointSoundDelay end,
			setFunc = function(value)
				settings.compassGroupRallyPointSoundDelay = value
				outputLAMSettingsChangeToChat(tos(value), "Compass: Choose group rally point delay (s)")
			end,
			min = 0,
			max = 30,
			step = 0.25, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 2, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.compassGroupRallyPointSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.compassGroupRallyPointSoundDelay, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},
		{
			type = "slider",
			name = "Compass: Volume group rally point sound", -- or string id or function returning a string
			tooltip = "Playing the same sound multiple times increases the volume. Choose how often you want to repeat the played sound for the compass group rally point to increase the volume with this slider.",
			getFunc = function() return settings.compassGroupRallyPointSoundRepeat end,
			setFunc = function(value)
				settings.compassGroupRallyPointSoundRepeat = value
				outputLAMSettingsChangeToChat(tos(value), "Compass: Volume group rally point sound")
			end,
			min = 1,
			max = 10,
			step = 1, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.compassGroupRallyPointSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.compassGroupRallyPointSoundRepeat, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},
		--==============================================================================
		{
			type = 'header',
			name = "Waypoints",
		},
		{
			type = "checkbox",
			name = "Auto-Remove Waypoints",
			tooltip = "Automatically removes waypoints once you have reached them.\n\nIf the addon \'WaypointIt\' is active and it's setting to auto-remove waypoints is enabled, this setting here will be disabled",
			getFunc = function() return settings.autoRemoveWaypoint end,
			setFunc = function(value)
				settings.autoRemoveWaypoint = value
				outputLAMSettingsChangeToChat(tos(value), "Auto-Remove Waypoints")
				runWaypointRemoveUpdates(value, true)
			end,
			default = defaultSettings.autoRemoveWaypoint,
			disabled = function() return isWayPointItAutoRemoveWaypointEnabled() end,
		},

		--==============================================================================
		{
			type = 'header',
			name = "Reticle: Unit/NPCs/Enemies",
		},

		{
			type = "checkbox",
			name = "Reticle to chat: In Combat too",
			tooltip = "Show the current reticle data in chat if you are in combat too. If this option is disabled you won't see any unit/enemy/player or interaction data during combat. Check the combat settings for enemy health output to chat during combat!",
			getFunc = function() return settings.reticleToChatInCombat end,
			setFunc = function(value)
				settings.reticleToChatInCombat = value
				outputLAMSettingsChangeToChat(tos(value), "Reticle to chat: Only in Combat")
			end,
			default = defaultSettings.reticleToChatInCombat,
			disabled = function() return not settings.reticleUnitToChatText and not settings.reticlePlayerToChatText and not settings.reticleInteractionToChatText end
			--disabled = function() false end,
		},

		{
			type = "checkbox",
			name = "Show unit data (enemy, NPC, critter, ...) in chat",
			tooltip = "Show the currently looked at unit data in the chat",
			getFunc = function() return settings.reticleUnitToChatText end,
			setFunc = function(value)
				settings.reticleUnitToChatText = value
				outputLAMSettingsChangeToChat(tos(value), "Show unit data (enemy, NPC, critter, ...) in chat")
				reticleUnitData()
			end,
			default = defaultSettings.reticleUnitToChatText,
			--disabled = function() false end,
		},
		{
			type = "checkbox",
			name = "Unit to chat: Hide critters",
			tooltip = "Do not show any critters (with 1 health) in the chat",
			getFunc = function() return settings.reticleUnitIgnoreCritter end,
			setFunc = function(value)
				settings.reticleUnitIgnoreCritter = value
				outputLAMSettingsChangeToChat(tos(value), "Unit to chat: Hide critters")
			end,
			disabled = function() return not settings.reticleUnitToChatText end,
			default = defaultSettings.reticleUnitIgnoreCritter,
			--disabled = function() false end,
		},
		{
			type = "checkbox",
			name = "Unit to chat: Disable in group",
			tooltip = "Disable the \'Reticle: Unit data to chat\' feature automatically if you are in a group",
			getFunc = function() return settings.reticleToChatUnitDisableInGroup end,
			setFunc = function(value)
				settings.reticleToChatUnitDisableInGroup = value
				outputLAMSettingsChangeToChat(tos(value), "Unit to chat: Disable in group")
			end,
			default = defaultSettings.reticleToChatUnitDisableInGroup,
			disabled = function() return not settings.reticleUnitToChatText end
			--disabled = function() false end,
		},

		--==============================================================================
		{
			type = 'header',
			name = "Reticle: Player",
		},
		{
			type = "checkbox",
			name = "Show other player data in chat",
			tooltip = "Show the currently looked at other player data in the chat",
			getFunc = function() return settings.reticlePlayerToChatText end,
			setFunc = function(value)
				settings.reticlePlayerToChatText = value
				outputLAMSettingsChangeToChat(tos(value), "Show other player data in chat")
				reticleUnitData()
			end,
			default = defaultSettings.reticlePlayerToChatText,
			--disabled = function() false end,
		},
		{
			type = "checkbox",
			name = "Other player's race to chat",
			tooltip = "Show the currently looked at other player's race in the chat too",
			getFunc = function() return settings.reticlePlayerRace end,
			setFunc = function(value)
				settings.reticlePlayerRace = value
				outputLAMSettingsChangeToChat(tos(value), "Other player's race to chat")
			end,
			default = defaultSettings.reticlePlayerRace,
			disabled = function() return not settings.reticlePlayerToChatText end,
		},
		{
			type = "checkbox",
			name = "Other player's class to chat",
			tooltip = "Show the currently looked at other player's class in the chat too",
			getFunc = function() return settings.reticlePlayerClass end,
			setFunc = function(value)
				settings.reticlePlayerClass = value
				outputLAMSettingsChangeToChat(tos(value), "Other player's class to chat")
			end,
			default = defaultSettings.reticlePlayerClass,
			disabled = function() return not settings.reticlePlayerToChatText end,
		},
		{
			type = "checkbox",
			name = "Other player's level or CP to chat",
			tooltip = "Show the currently looked at other player's level, or Champion Points, in the chat too",
			getFunc = function() return settings.reticlePlayerLevel end,
			setFunc = function(value)
				settings.reticlePlayerLevel = value
				outputLAMSettingsChangeToChat(tos(value), "Other player's level or CP to chat")
			end,
			default = defaultSettings.reticlePlayerLevel,
			disabled = function() return not settings.reticlePlayerToChatText end,
		},
		{
			type = "checkbox",
			name = "Other player's alliance to chat",
			tooltip = "Show the currently looked at other player's alliance in the chat too",
			getFunc = function() return settings.reticlePlayerAlliance end,
			setFunc = function(value)
				settings.reticlePlayerAlliance = value
				outputLAMSettingsChangeToChat(tos(value), "Other player's alliance to chat")
			end,
			default = defaultSettings.reticlePlayerAlliance,
			disabled = function() return not settings.reticlePlayerToChatText end,
		},
		{
			type = "checkbox",
			name = "Player to chat: Disable in group",
			tooltip = "Disable the \'Reticle: Player data to chat\' feature automatically if you are in a group",
			getFunc = function() return settings.reticleToChatPlayerDisableInGroup end,
			setFunc = function(value)
				settings.reticleToChatPlayerDisableInGroup = value
				outputLAMSettingsChangeToChat(tos(value), "Player to chat: Disable in group")
			end,
			default = defaultSettings.reticleToChatPlayerDisableInGroup,
			disabled = function() return not settings.reticlePlayerToChatText end
			--disabled = function() false end,
		},


		--==============================================================================
		{
			type = 'header',
			name = "Reticle: Interactable objects",
		},
		{
			type = "checkbox",
			name = "Show interaction (NPCs, doors, boxes, chests, ...) data in chat",
			tooltip = "Show the currently looked at interaction data in the chat and show if they are blocked, if it's criminal to use/open them, etc.",
			getFunc = function() return settings.reticleInteractionToChatText end,
			setFunc = function(value)
				settings.reticleInteractionToChatText = value
				outputLAMSettingsChangeToChat(tos(value), "Show interaction (doors, boxes, ...) data in chat")
				interactionData()
			end,
			default = defaultSettings.reticleInteractionToChatText,
			--disabled = function() false end,
		},
		{
			type = "checkbox",
			name = "Interaction to chat: Disable in group",
			tooltip = "Disable the \'Reticle: Interaction data to chat\' feature automatically if you are in a group",
			getFunc = function() return settings.reticleToChatInteractionDisableInGroup end,
			setFunc = function(value)
				settings.reticleToChatInteractionDisableInGroup = value
				outputLAMSettingsChangeToChat(tos(value), "Interaction to chat: Disable in group")
			end,
			default = defaultSettings.reticleToChatInteractionDisableInGroup,
			disabled = function() return not settings.reticleInteractionToChatText end
			--disabled = function() false end,
		},

		--==============================================================================
		{
			type = 'header',
			name = "Map",
		},
		{
			type = "slider",
			name = "Player pin - Ping pong scaling",
			tooltip = "Set the scaling of the player's map pin ping pong effect (for they keybind)",
			min = 1,
			max = 100,
			decimals = 0,
			autoSelect = true,
			getFunc = function() return settings.playerPinPingPongScaling end,
			setFunc = function(volumeLevel)
				settings.playerPinPingPongScaling = volumeLevel
				outputLAMSettingsChangeToChat(tos(volumeLevel), "Player: Ping-pong scaling (keybind)")
			end,
			default = defaultSettings.playerPinPingPongScaling,
			width="half",
			--disabled = function() return not settings.playerPinPingPong end,
		},

		--==============================================================================
		{
			type = 'header',
			name = "Group",
		},
		{
			type = "checkbox",
			name    = "Group leader - Map pin ping-pong",
			tooltip = "Shows a ping-pong (big-normal size) effect at the group leader map pin, as you open the map",
			getFunc = function() return settings.groupLeaderPinPingPong end,
			setFunc = function(value)
				settings.groupLeaderPinPingPong = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Map pin ping-pong")
				registerGroupLeaderMapPinPingPong()
			end,
			default = defaultSettings.groupLeaderPinPingPong,
			--disabled = function() return false end,
		},
        {
            type = "slider",
            name = "Group leader - Ping pong scaling",
            tooltip = "Set the scaling of the group leader's map pin ping pong effect",
            min = 1,
            max = 100,
            decimals = 0,
            autoSelect = true,
            getFunc = function() return settings.groupLeaderPinPingPongScaling end,
            setFunc = function(volumeLevel)
                settings.groupLeaderPinPingPongScaling = volumeLevel
				outputLAMSettingsChangeToChat(tos(volumeLevel), "Group leader: Ping-pong scaling")
            end,
            default = defaultSettings.groupLeaderPinPingPongScaling,
            width="half",
            disabled = function() return not settings.groupLeaderPinPingPong end,
        },
		{
			type = "checkbox",
			name    = "Group leader - Map pin ping-pong breadcrumbed",
			tooltip = "Show the group leader ping-pong effect if the group leader is at other instances/breadcrumbed (if you disable this setting the group leader's icon won't ping-pong e.g. if he/she is in a delve or dungeon etc.)",
			getFunc = function() return settings.groupLeaderPinPingPongBreadcrumbed end,
			setFunc = function(value)
				settings.groupLeaderPinPingPongBreadcrumbed = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Map pin ping-pong for other instances/breadcrumbed")
			end,
			default = defaultSettings.groupLeaderPinPingPongBreadcrumbed,
            disabled = function() return not settings.groupLeaderPinPingPong end,
        },

		{
			type = "checkbox",
			name    = "Group leader - Play sound",
			tooltip = "Plays a sound repetively if you are looking into the direction of your group leader.",
			getFunc = function() return settings.groupLeaderSound end,
			setFunc = function(value)
				settings.groupLeaderSound = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Play sound")
				runGroupLeaderUpdates(value, true)
			end,
			default = defaultSettings.groupLeaderSound,
			--disabled = function() return false end,
		},
		{
			type = "soundslider",
			name = "Group leader: Choose sound", -- or string id or function returning a string
			tooltip = "Choose the sound to play if you look into the group leader's direction. Changing the slider will play the sound as a preview 3 times, using the chosen delay too.", -- or string id or function returning a string (optional)
			getFunc = function() return settings.groupLeaderSoundName end,
			setFunc = function(value)
				settings.groupLeaderSoundName = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Choose sound")
			end,
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			saveSoundIndex = false, -- or function returning a boolean (optional) If set to false (default) the internal soundName will be saved. If set to true the selected sound's index will be saved to the SavedVariables (the index might change if sounds get inserted later!).
			showSoundName = true, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be shown at the label of the slider, and at the tooltip too
			playSound = false, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be played via function PlaySound
			playSoundData = function() return getPreviewDataTab("GroupLeader", 3) end, --{number playCount, number delayInMS, number increaseVolume}, -- table or function returning a table. If this table is provided the chosen sound will be played playCount (default is 1) times after each other, with a delayInMS (default is 0) in milliseconds in between, and each played sound will be played increaseVolume times (directly at the same time) to increase the volume (default is 1, max is 10) (optional)
			showPlaySoundButton = true,
			noAutomaticSoundPreview = false,
			readOnly = false, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.groupLeaderSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.groupLeaderSoundName, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			reference = "FCOAB_LAM_GROUP_LEADER_SOUNDSLIDER" -- unique global reference to control (optional)
		},
		{
			type = "slider",
			name = "Group leader: Choose delay (s)", -- or string id or function returning a string
			tooltip = "Choose the delay in seconds between each repetively played sound for the Group leader sound at this horizontal slider", -- or string id or function returning a string (optional)
			getFunc = function() return settings.groupLeaderSoundDelay end,
			setFunc = function(value)
				settings.groupLeaderSoundDelay = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Choose delay (s)")
			end,
			min = 0,
			max = 30,
			step = 0.25, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 2, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.groupLeaderSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.groupLeaderSoundDelay, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},
		{
			type = "slider",
			name = "Group leader: Volume", -- or string id or function returning a string
			tooltip = "Playing the same sound multiple times increases the volume. Choose how often you want to repeat the played sound if you are looking into the group leader's direction to increase the volume with this slider.",
			getFunc = function() return settings.groupLeaderSoundRepeat end,
			setFunc = function(value)
				settings.groupLeaderSoundRepeat = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Volume")
			end,
			min = 1,
			max = 10,
			step = 1, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.groupLeaderSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.groupLeaderSoundRepeat, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},
		{
			type = "slider",
			name = "Group leader: Sound min distance", -- or string id or function returning a string
			tooltip = "Choose the distance in meters around the group leader where the sound will not play. If you move away from the group leader more than this choosen meters the sound will play again.",
			getFunc = function() return settings.groupLeaderSoundDistance end,
			setFunc = function(value)
				settings.groupLeaderSoundDistance = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Sound distance")
			end,
			min = 1,
			max = 100,
			step = 1, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.groupLeaderSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.groupLeaderSoundDistance, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},
		{
			type = "checkbox",
			name    = "Group leader: Distance to chat",
			tooltip = "Shows the distance to the group leader, in meters, in the chat so that the chat reader can read it out to you.",
			getFunc = function() return settings.groupLeaderDistanceToChat end,
			setFunc = function(value)
				settings.groupLeaderDistanceToChat = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Distance to chat")
			end,
			default = defaultSettings.groupLeaderDistanceToChat,
			disabled = function() return not settings.groupLeaderSound end,
		},
		{
			type = "slider",
			name = "Group leader: Sound angle", -- or string id or function returning a string
			tooltip = "Choose the angle in degrees where the sound still should be played if you look at the group leader direction. The default value is 20°. That means: if you look at the group leader and you are aiming 10° to the left or to the right the sound will still be played.",
			getFunc = function() return settings.groupLeaderSoundAngle end,
			setFunc = function(value)
				settings.groupLeaderSoundAngle = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Sound angle")
			end,
			min = 1,
			max = 90,
			step = 1, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.groupLeaderSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.groupLeaderSoundAngle, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},
		{
			type = "checkbox",
			name    = "Group leader: Clock position",
			tooltip = "Shows the clock position (12 in front, 3 right, 6 behind, 9 left of you) of the group leader in the chat so that the chat reader can read it out to you.",
			getFunc = function() return settings.groupLeaderClockPosition end,
			setFunc = function(value)
				settings.groupLeaderClockPosition = value
				if value == true then
					settings.groupLeaderDirectionPosition = false
				end
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Clock position")
			end,
			default = defaultSettings.groupLeaderClockPosition,
			disabled = function() return not settings.groupLeaderSound or settings.groupLeaderDirectionPosition end,
		},
		{
			type = "checkbox",
			name    = "Group leader: Direction position",
			tooltip = "Shows the direction position (your 4 defined quarters) of the group leader in the chat so that the chat reader can read it out to you. You can define the 4 quartes of the directions yourself in the 4 editboxes below. Default values are: West, Nort, East, and South.",
			getFunc = function() return settings.groupLeaderDirectionPosition end,
			setFunc = function(value)
				settings.groupLeaderDirectionPosition = value
				if value == true then
					settings.groupLeaderClockPosition = false
				end
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Direction position")
			end,
			default = defaultSettings.groupLeaderDirectionPosition,
			disabled = function() return not settings.groupLeaderSound or settings.groupLeaderClockPosition end,
		},
		{
			type = "editbox",
			name = "Group leader: Diretion quarter - West",
			tooltip = "Choose the direction quarter to print in chat if the group leader is west of you. The Accessibility screen reader reads it loud to you.\nThe default value is 'west'",
			getFunc = function() return settings.chatGroupLeaderDirectionPosition["west"] end,
			setFunc = function(value)
				settings.chatGroupLeaderDirectionPosition["west"] = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Direction position - Quarter for West")
			end,
			isMultiline = false, -- boolean (optional)
			isExtraWide = false, -- boolean (optional)
			maxChars = 200, -- number (optional)
			--textType = TEXT_TYPE_NUMERIC, -- number (optional) or function returning a number. Valid TextType numbers: TEXT_TYPE_ALL, TEXT_TYPE_ALPHABETIC, TEXT_TYPE_ALPHABETIC_NO_FULLWIDTH_LATIN, TEXT_TYPE_NUMERIC, TEXT_TYPE_NUMERIC_UNSIGNED_INT, TEXT_TYPE_PASSWORD
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.groupLeaderSound or not settings.groupLeaderDirectionPosition end, -- or boolean (optional)
			default = defaultSettings.chatGroupLeaderDirectionPosition["west"], -- default value or function that returns the default value (optional)
		},
		{
			type = "editbox",
			name = "Group leader: Diretion quarter - North",
			tooltip = "Choose the direction quarter to print in chat if the group leader is west of you. The Accessibility screen reader reads it loud to you.\nThe default value is 'north'",
			getFunc = function() return settings.chatGroupLeaderDirectionPosition["north"] end,
			setFunc = function(value)
				settings.chatGroupLeaderDirectionPosition["north"] = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Direction position - Quarter for North")
			end,
			isMultiline = false, -- boolean (optional)
			isExtraWide = false, -- boolean (optional)
			maxChars = 200, -- number (optional)
			--textType = TEXT_TYPE_NUMERIC, -- number (optional) or function returning a number. Valid TextType numbers: TEXT_TYPE_ALL, TEXT_TYPE_ALPHABETIC, TEXT_TYPE_ALPHABETIC_NO_FULLWIDTH_LATIN, TEXT_TYPE_NUMERIC, TEXT_TYPE_NUMERIC_UNSIGNED_INT, TEXT_TYPE_PASSWORD
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.groupLeaderSound or not settings.groupLeaderDirectionPosition end, -- or boolean (optional)
			default = defaultSettings.chatGroupLeaderDirectionPosition["north"], -- default value or function that returns the default value (optional)
		},
		{
			type = "editbox",
			name = "Group leader: Diretion quarter - East",
			tooltip = "Choose the direction quarter to print in chat if the group leader is west of you. The Accessibility screen reader reads it loud to you.\nThe default value is 'east'",
			getFunc = function() return settings.chatGroupLeaderDirectionPosition["east"] end,
			setFunc = function(value)
				settings.chatGroupLeaderDirectionPosition["east"] = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Direction position - Quarter for East")
			end,
			isMultiline = false, -- boolean (optional)
			isExtraWide = false, -- boolean (optional)
			maxChars = 200, -- number (optional)
			--textType = TEXT_TYPE_NUMERIC, -- number (optional) or function returning a number. Valid TextType numbers: TEXT_TYPE_ALL, TEXT_TYPE_ALPHABETIC, TEXT_TYPE_ALPHABETIC_NO_FULLWIDTH_LATIN, TEXT_TYPE_NUMERIC, TEXT_TYPE_NUMERIC_UNSIGNED_INT, TEXT_TYPE_PASSWORD
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.groupLeaderSound or not settings.groupLeaderDirectionPosition end, -- or boolean (optional)
			default = defaultSettings.chatGroupLeaderDirectionPosition["east"], -- default value or function that returns the default value (optional)
		},
		{
			type = "editbox",
			name = "Group leader: Diretion quarter - South",
			tooltip = "Choose the direction quarter to print in chat if the group leader is west of you. The Accessibility screen reader reads it loud to you.\nThe default value is 'south'",
			getFunc = function() return settings.chatGroupLeaderDirectionPosition["south"] end,
			setFunc = function(value)
				settings.chatGroupLeaderDirectionPosition["south"] = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Direction position - Quarter for South")
			end,
			isMultiline = false, -- boolean (optional)
			isExtraWide = false, -- boolean (optional)
			maxChars = 200, -- number (optional)
			--textType = TEXT_TYPE_NUMERIC, -- number (optional) or function returning a number. Valid TextType numbers: TEXT_TYPE_ALL, TEXT_TYPE_ALPHABETIC, TEXT_TYPE_ALPHABETIC_NO_FULLWIDTH_LATIN, TEXT_TYPE_NUMERIC, TEXT_TYPE_NUMERIC_UNSIGNED_INT, TEXT_TYPE_PASSWORD
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.groupLeaderSound or not settings.groupLeaderDirectionPosition end, -- or boolean (optional)
			default = defaultSettings.chatGroupLeaderDirectionPosition["south"], -- default value or function that returns the default value (optional)
		},


		{
			type = "editbox",
			name = "Group leader: Clock / diretion pos. - Chat prefix",
			tooltip = "Choose a prefix which should be printed in front of all chat messages related to the group leader position (for an easier distinguish between other read texts and the group leader position). The Accessibility screen reader reads it loud to you.\nThe default value is 'no prefix'",
			getFunc = function() return settings.chatGroupLeaderClockPositionPrefix end,
			setFunc = function(value)
				settings.chatGroupLeaderClockPositionPrefix = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Clock / direction position - Chat reader prefix text")
			end,
			isMultiline = false, -- boolean (optional)
			isExtraWide = false, -- boolean (optional)
			maxChars = 200, -- number (optional)
			--textType = TEXT_TYPE_NUMERIC, -- number (optional) or function returning a number. Valid TextType numbers: TEXT_TYPE_ALL, TEXT_TYPE_ALPHABETIC, TEXT_TYPE_ALPHABETIC_NO_FULLWIDTH_LATIN, TEXT_TYPE_NUMERIC, TEXT_TYPE_NUMERIC_UNSIGNED_INT, TEXT_TYPE_PASSWORD
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.groupLeaderSound or ( not settings.groupLeaderClockPosition and not settings.groupLeaderDirectionPosition ) end, -- or boolean (optional)
			default = defaultSettings.chatGroupLeaderClockPositionPrefix, -- default value or function that returns the default value (optional)
		},
		{
			type = "checkbox",
			name    = "Group leader: Clock /direction position - Repeat same",
			tooltip = "Repeat the same clock / direction position to get a constant group leader clock / direction position? If disabled the same clock / direction position won't be added to the chat again.",
			getFunc = function() return settings.groupLeaderClockPositionRepeatSame end,
			setFunc = function(value)
				settings.groupLeaderClockPositionRepeatSame = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Clock / direction position - Repeat same")
			end,
			default = defaultSettings.groupLeaderClockPositionRepeatSame,
			disabled = function() return not settings.groupLeaderSound or ( not settings.groupLeaderClockPosition and not settings.groupLeaderDirectionPosition ) end,
		},
		{
			type = "checkbox",
			name    = "Group leader: Clock /direction position - Lookin at leader",
			tooltip = "Add the clock / direction position to the chat if you are looking at the group leader (using the defined angle).",
			getFunc = function() return settings.groupLeaderClockPositionIfLookingAtGroupLeader end,
			setFunc = function(value)
				settings.groupLeaderClockPositionIfLookingAtGroupLeader = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Clock position - Looking at leader")
			end,
			default = defaultSettings.groupLeaderClockPositionIfLookingAtGroupLeader,
			disabled = function() return not settings.groupLeaderSound or ( not settings.groupLeaderClockPosition and not settings.groupLeaderDirectionPosition ) end,
		},
		{
			type = "slider",
			name = "Group leader: Clock / direction position delay", -- or string id or function returning a string
			tooltip = "Choose the delay in seconds that the group leader clock / direction position will use between the chat outputs.",
			getFunc = function() return settings.groupLeaderClockPositionDelay end,
			setFunc = function(value)
				settings.groupLeaderClockPositionDelay = value
				outputLAMSettingsChangeToChat(tos(value), "Group leader: Clock position delay")
			end,
			min = 0,
			max = 30,
			step = 0.25, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 2, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.groupLeaderSound or ( not settings.groupLeaderClockPosition and not settings.groupLeaderDirectionPosition ) end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.groupLeaderSoundAngle, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},

		--==============================================================================
		{
			type = 'header',
			name = "Combat",
		},
		{
			type = "checkbox",
			name = "Combat: Start & end info to chat",
			tooltip = "If you get into combat, or leave combat, the chat will show you some information about your health, magicka and stamina",
			getFunc = function() return settings.combatStartEndInfo end,
			setFunc = function(value)
				settings.combatStartEndInfo = value
				outputLAMSettingsChangeToChat(tos(value), "Combat: Start & end info to chat")
			end,
			default = defaultSettings.combatStartEndInfo,
			--disabled = function() false end,
		},

		{
			type = "checkbox",
			name = "Combat: Active enemy health to chat",
			tooltip = "Show the actually engaged enemy's health in chat, as %/maximum Health. This will be updated by 10% steps",
			getFunc = function() return settings.showReticleOverUnitHealthInChat end,
			setFunc = function(value)
				settings.showReticleOverUnitHealthInChat = value
				outputLAMSettingsChangeToChat(tos(value), "Combat: Active enemy health to chat")
				reticleUnitData()
			end,
			default = defaultSettings.showReticleOverUnitHealthInChat,
			--disabled = function() false end,
		},

		----------------------------------------------------------------------------------------------------------------
		{
			type = "checkbox",
			name = "Combat: Tip to chat",
			tooltip = "If you get a tip in combat, like \'Block\' or \'Dodge\' or \'Interrupt\', the tip will be written to the chat so that the accessibility chat reader can read it to you",
			getFunc = function() return settings.combatTipToChat end,
			setFunc = function(value)
				settings.combatTipToChat = value
				outputLAMSettingsChangeToChat(tos(value), "Combat: Tip to chat")
				if value == true then
					enableActiveCombatTipsIfDisabled()
				end
			end,
			default = defaultSettings.combatTipToChat,
			--disabled = function() false end,
		},

				{
			type = "checkbox",
			name    = "Combat Tip - Play sound",
			tooltip = "Plays a sound once if a combat tip is triggered. Choose the different combat tip sounds below at the respective sound slider.",
			getFunc = function() return settings.combatTipSound end,
			setFunc = function(value)
				settings.combatTipSound = value
				outputLAMSettingsChangeToChat(tos(value), "Combat Tip - Play sound")
			end,
			default = defaultSettings.combatTipSound,
			--disabled = function() return false end,
		},
		{
			type = "soundslider",
			name = "Combat Tip \'Block\': Choose sound", -- or string id or function returning a string
			tooltip = "Choose the sound to play if a combat \'Block\' tip is triggered. Changing the slider will play the sound once as a preview.", -- or string id or function returning a string (optional)
			getFunc = function() return settings.combatTipSoundName[1] end,
			setFunc = function(value)
				settings.combatTipSoundName[1] = value
				outputLAMSettingsChangeToChat(tos(value), "Combat Tip \'Block\': Choose sound")
			end,
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			saveSoundIndex = false, -- or function returning a boolean (optional) If set to false (default) the internal soundName will be saved. If set to true the selected sound's index will be saved to the SavedVariables (the index might change if sounds get inserted later!).
			showSoundName = true, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be shown at the label of the slider, and at the tooltip too
			playSound = false, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be played via function PlaySound
			playSoundData = function() return getPreviewDataTab("CombatTip", 1, 1) end, --{number playCount, number delayInMS, number increaseVolume}, -- table or function returning a table. If this table is provided the chosen sound will be played playCount (default is 1) times after each other, with a delayInMS (default is 0) in milliseconds in between, and each played sound will be played increaseVolume times (directly at the same time) to increase the volume (default is 1, max is 10) (optional)
			showPlaySoundButton = true,
			noAutomaticSoundPreview = false,
			readOnly = false, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.combatTipSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.combatTipSoundName[1], -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			reference = "FCOAB_LAM_COMBAT_TIP_BLOCK_SOUNDSLIDER" -- unique global reference to control (optional)
		},
		{
			type = "slider",
			name = "Combat Tip \'Block\': Volume", -- or string id or function returning a string
			tooltip = "Playing the same sound multiple times increases the volume. Choose how often you want to repeat the played sound for a combat tip to increase the volume with this slider.",
			getFunc = function() return settings.combatTipSoundRepeat[1] end,
			setFunc = function(value)
				settings.combatTipSoundRepeat[1] = value
				outputLAMSettingsChangeToChat(tos(value), "Combat Tip \'Block\': Volume")
			end,
			min = 1,
			max = 10,
			step = 1, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.combatTipSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.combatTipSoundRepeat[1], -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},

		{
			type = "soundslider",
			name = "Combat Tip \'Off Balance\': Choose sound", -- or string id or function returning a string
			tooltip = "Choose the sound to play if a combat \'Off Balance\' tip is triggered. Changing the slider will play the sound once as a preview.", -- or string id or function returning a string (optional)
			getFunc = function() return settings.combatTipSoundName[2] end,
			setFunc = function(value)
				settings.combatTipSoundName[2] = value
				outputLAMSettingsChangeToChat(tos(value), "Combat Tip \'Off Balance\': Choose sound")
			end,
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			saveSoundIndex = false, -- or function returning a boolean (optional) If set to false (default) the internal soundName will be saved. If set to true the selected sound's index will be saved to the SavedVariables (the index might change if sounds get inserted later!).
			showSoundName = true, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be shown at the label of the slider, and at the tooltip too
			playSound = false, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be played via function PlaySound
			playSoundData = function() return getPreviewDataTab("CombatTip", 1, 2) end, --{number playCount, number delayInMS, number increaseVolume}, -- table or function returning a table. If this table is provided the chosen sound will be played playCount (default is 1) times after each other, with a delayInMS (default is 0) in milliseconds in between, and each played sound will be played increaseVolume times (directly at the same time) to increase the volume (default is 1, max is 10) (optional)
			showPlaySoundButton = true,
			noAutomaticSoundPreview = false,
			readOnly = false, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.combatTipSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.combatTipSoundName[2], -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			reference = "FCOAB_LAM_COMBAT_TIP_OFFBALANCE_SOUNDSLIDER" -- unique global reference to control (optional)
		},
		{
			type = "slider",
			name = "Combat Tip \'Off Balance\': Volume", -- or string id or function returning a string
			tooltip = "Playing the same sound multiple times increases the volume. Choose how often you want to repeat the played sound for a combat tip to increase the volume with this slider.",
			getFunc = function() return settings.combatTipSoundRepeat[2] end,
			setFunc = function(value)
				settings.combatTipSoundRepeat[2] = value
				outputLAMSettingsChangeToChat(tos(value), "Combat Tip \'Off Balance\': Volume")
			end,
			min = 1,
			max = 10,
			step = 1, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.combatTipSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.combatTipSoundRepeat[2], -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},

		{
			type = "soundslider",
			name = "Combat Tip \'Interrupt\': Choose sound", -- or string id or function returning a string
			tooltip = "Choose the sound to play if a combat \'Interrupt\' tip is triggered. Changing the slider will play the sound once as a preview.", -- or string id or function returning a string (optional)
			getFunc = function() return settings.combatTipSoundName[3] end,
			setFunc = function(value)
				settings.combatTipSoundName[3] = value
				outputLAMSettingsChangeToChat(tos(value), "Combat Tip \'Interrupt\': Choose sound")
			end,
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			saveSoundIndex = false, -- or function returning a boolean (optional) If set to false (default) the internal soundName will be saved. If set to true the selected sound's index will be saved to the SavedVariables (the index might change if sounds get inserted later!).
			showSoundName = true, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be shown at the label of the slider, and at the tooltip too
			playSound = false, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be played via function PlaySound
			playSoundData = function() return getPreviewDataTab("CombatTip", 1, 3) end, --{number playCount, number delayInMS, number increaseVolume}, -- table or function returning a table. If this table is provided the chosen sound will be played playCount (default is 1) times after each other, with a delayInMS (default is 0) in milliseconds in between, and each played sound will be played increaseVolume times (directly at the same time) to increase the volume (default is 1, max is 10) (optional)
			showPlaySoundButton = true,
			noAutomaticSoundPreview = false,
			readOnly = false, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.combatTipSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.combatTipSoundName[3], -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			reference = "FCOAB_LAM_COMBAT_TIP_INTERRUPT_SOUNDSLIDER" -- unique global reference to control (optional)
		},
		{
			type = "slider",
			name = "Combat Tip \'Interrupt\': Volume", -- or string id or function returning a string
			tooltip = "Playing the same sound multiple times increases the volume. Choose how often you want to repeat the played sound for a combat tip to increase the volume with this slider.",
			getFunc = function() return settings.combatTipSoundRepeat[3] end,
			setFunc = function(value)
				settings.combatTipSoundRepeat[3] = value
				outputLAMSettingsChangeToChat(tos(value), "Combat Tip \'Interrupt\': Volume")
			end,
			min = 1,
			max = 10,
			step = 1, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.combatTipSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.combatTipSoundRepeat[3], -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},

				{
			type = "soundslider",
			name = "Combat Tip \'Dodge\': Choose sound", -- or string id or function returning a string
			tooltip = "Choose the sound to play if a combat \'Dodge\' tip is triggered. Changing the slider will play the sound once as a preview.", -- or string id or function returning a string (optional)
			getFunc = function() return settings.combatTipSoundName[4] end,
			setFunc = function(value)
				settings.combatTipSoundName[4] = value
				outputLAMSettingsChangeToChat(tos(value), "Combat Tip \'Dodge\': Choose sound")
			end,
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			saveSoundIndex = false, -- or function returning a boolean (optional) If set to false (default) the internal soundName will be saved. If set to true the selected sound's index will be saved to the SavedVariables (the index might change if sounds get inserted later!).
			showSoundName = true, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be shown at the label of the slider, and at the tooltip too
			playSound = false, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be played via function PlaySound
			playSoundData = function() return getPreviewDataTab("CombatTip", 1, 4) end, --{number playCount, number delayInMS, number increaseVolume}, -- table or function returning a table. If this table is provided the chosen sound will be played playCount (default is 1) times after each other, with a delayInMS (default is 0) in milliseconds in between, and each played sound will be played increaseVolume times (directly at the same time) to increase the volume (default is 1, max is 10) (optional)
			showPlaySoundButton = true,
			noAutomaticSoundPreview = false,
			readOnly = false, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.combatTipSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.combatTipSoundName[1], -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			reference = "FCOAB_LAM_COMBAT_TIP_DODGE_SOUNDSLIDER" -- unique global reference to control (optional)
		},
		{
			type = "slider",
			name = "Combat Tip \'Dodge\': Volume", -- or string id or function returning a string
			tooltip = "Playing the same sound multiple times increases the volume. Choose how often you want to repeat the played sound for a combat tip to increase the volume with this slider.",
			getFunc = function() return settings.combatTipSoundRepeat[4] end,
			setFunc = function(value)
				settings.combatTipSoundRepeat[4] = value
				outputLAMSettingsChangeToChat(tos(value), "Combat Tip \'Dodge\': Volume")
			end,
			min = 1,
			max = 10,
			step = 1, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.combatTipSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.combatTipSoundRepeat[4], -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},
		----------------------------------------------------------------------------------------------------------------

		{
			type = "checkbox",
			name    = "Combat start - Play sound",
			tooltip = "Plays a sound once if you get into combat.",
			getFunc = function() return settings.combatStartSound end,
			setFunc = function(value)
				settings.combatStartSound = value
				outputLAMSettingsChangeToChat(tos(value), "Combat start - Play sound")
			end,
			default = defaultSettings.combatStartSound,
			--disabled = function() return false end,
		},
		{
			type = "soundslider",
			name = "Combat start: Choose sound", -- or string id or function returning a string
			tooltip = "Choose the sound to play if combat starts. Changing the slider will play the sound once as a preview.", -- or string id or function returning a string (optional)
			getFunc = function() return settings.combatStartSoundName end,
			setFunc = function(value)
				settings.combatStartSoundName = value
				outputLAMSettingsChangeToChat(tos(value), "Combat start: Choose sound")
			end,
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			saveSoundIndex = false, -- or function returning a boolean (optional) If set to false (default) the internal soundName will be saved. If set to true the selected sound's index will be saved to the SavedVariables (the index might change if sounds get inserted later!).
			showSoundName = true, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be shown at the label of the slider, and at the tooltip too
			playSound = false, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be played via function PlaySound
			playSoundData = function() return getPreviewDataTab("CombatStart", 1) end, --{number playCount, number delayInMS, number increaseVolume}, -- table or function returning a table. If this table is provided the chosen sound will be played playCount (default is 1) times after each other, with a delayInMS (default is 0) in milliseconds in between, and each played sound will be played increaseVolume times (directly at the same time) to increase the volume (default is 1, max is 10) (optional)
			showPlaySoundButton = true,
			noAutomaticSoundPreview = false,
			readOnly = false, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.combatStartSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.combatStartSoundName, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			reference = "FCOAB_LAM_COMBAT_START_SOUNDSLIDER" -- unique global reference to control (optional)
		},
		{
			type = "slider",
			name = "Combat start: Volume", -- or string id or function returning a string
			tooltip = "Playing the same sound multiple times increases the volume. Choose how often you want to repeat the played sound if combat is started to increase the volume with this slider.",
			getFunc = function() return settings.combatStartSoundRepeat end,
			setFunc = function(value)
				settings.combatStartSoundRepeat = value
				outputLAMSettingsChangeToChat(tos(value), "Combat start: Volume")
			end,
			min = 1,
			max = 10,
			step = 1, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.combatStartSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.combatStartSoundRepeat, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},

		{
			type = "checkbox",
			name    = "Combat end - Play sound",
			tooltip = "Plays a sound once if you leave combat.",
			getFunc = function() return settings.combatEndSound end,
			setFunc = function(value)
				settings.combatEndSound = value
				outputLAMSettingsChangeToChat(tos(value), "Combat end - Play sound")
			end,
			default = defaultSettings.combatEndSound,
			--disabled = function() return false end,
		},
		{
			type = "soundslider",
			name = "Combat end: Choose sound", -- or string id or function returning a string
			tooltip = "Choose the sound to play if combat ends. Changing the slider will play the sound once as a preview.", -- or string id or function returning a string (optional)
			getFunc = function() return settings.combatEndSoundName end,
			setFunc = function(value)
				settings.combatEndSoundName = value
				outputLAMSettingsChangeToChat(tos(value), "Combat end: Choose sound")
			end,
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			saveSoundIndex = false, -- or function returning a boolean (optional) If set to false (default) the internal soundName will be saved. If set to true the selected sound's index will be saved to the SavedVariables (the index might change if sounds get inserted later!).
			showSoundName = true, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be shown at the label of the slider, and at the tooltip too
			playSound = false, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be played via function PlaySound
			playSoundData = function() return getPreviewDataTab("CombatEnd", 1) end, --{number playCount, number delayInMS, number increaseVolume}, -- table or function returning a table. If this table is provided the chosen sound will be played playCount (default is 1) times after each other, with a delayInMS (default is 0) in milliseconds in between, and each played sound will be played increaseVolume times (directly at the same time) to increase the volume (default is 1, max is 10) (optional)
			showPlaySoundButton = true,
			noAutomaticSoundPreview = false,
			readOnly = false, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.combatEndSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.combatEndSoundName, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			reference = "FCOAB_LAM_COMBAT_END_SOUNDSLIDER" -- unique global reference to control (optional)
		},
		{
			type = "slider",
			name = "Combat end: Volume", -- or string id or function returning a string
			tooltip = "Playing the same sound multiple times increases the volume. Choose how often you want to repeat the played sound if combat ends to increase the volume with this slider.",
			getFunc = function() return settings.combatEndSoundRepeat end,
			setFunc = function(value)
				settings.combatEndSoundRepeat = value
				outputLAMSettingsChangeToChat(tos(value), "Combat end: Volume")
			end,
			min = 1,
			max = 10,
			step = 1, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.combatEndSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.combatEndSoundRepeat, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},

		--==============================================================================
		{
			type = 'header',
			name = "Combat: Target markers",
		},
		{
			type = "checkbox",
			name    = "Combat Target markers - Automatically apply",
			tooltip = "Apply up to 8 different target markers to the actively engaged enemies, below your crosshair. Each new enemy below your crosshair will get a new target marker until the end of the combat, which show at the compass too. At the end of the combat all target markers will be removed again.",
			getFunc = function() return settings.targetMarkersSetInCombatToEnemies end,
			setFunc = function(value)
				settings.targetMarkersSetInCombatToEnemies = value
				outputLAMSettingsChangeToChat(tos(value), "Combat Target markers - Automatically apply")
				reticleUnitData()
			end,
			default = defaultSettings.targetMarkersSetInCombatToEnemies,
			--disabled = function() return false end,
		},

		--==============================================================================
		{
			type = 'header',
			name = "Passenger mount",
		},
		{
			type = "editbox",
			name = "Passenger mount: Preferred account name", -- or string id or function returning a string
			tooltip = "Enter the @AccountName for the account that you prefer to ride as a passender with. The AccountName must start with a @! If you start to type an auto completion will show you the valid @AccountNames of your friends list, group and guilds you are a member of. Complete a possible name with the tabulator key. If more than 1 possibl entries exist you can use the up/down keys to switch between the possible names.", -- or string id or function returning a string (optional)
			getFunc = function() return settings.preferredGroupMountDisplayName end,
			setFunc = function(value)
				--[[
				if value ~= "" then
					if startsWith(value, "@") == false then value = "@" .. value end
				end
				if value == myDisplayName then value = "" end
				if value == "@" then value = "" end
				]]
				settings.preferredGroupMountDisplayName = value
				outputLAMSettingsChangeToChat(tos(value), "Passenger mount: Preferred account name")
			end,
			isMultiline = false, -- boolean (optional)
			isExtraWide = false, -- boolean (optional)
			maxChars = 50, -- number (optional)
			--textType = TEXT_TYPE_ALL, -- number (optional) or function returning a number. Valid TextType numbers: TEXT_TYPE_ALL, TEXT_TYPE_ALPHABETIC, TEXT_TYPE_ALPHABETIC_NO_FULLWIDTH_LATIN, TEXT_TYPE_NUMERIC, TEXT_TYPE_NUMERIC_UNSIGNED_INT, TEXT_TYPE_PASSWORD
			width = "full", -- or "half" (optional)
			--disabled = function() return false end, -- or boolean (optional)
			--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = "", -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			reference = "FCOAB_PREFERRED_PASSENGER_MOUNT_EDITBOX" -- unique global reference to control (optional)
		},
		{
			type = "checkbox",
			name    = "Preferred multi-rider: Fluffiels Panic Beam",
			tooltip = "Enable the Fluffiels' Panic Beam feature \'BFF\' beam on your preferred multi-rider player\nNeeds the addon \'Fluffiels Panic Beams\' to be enabled!",
			getFunc = function() return settings.preferredGroupMountDisplayNameFluffielsPanicBeam end,
			setFunc = function(value)
				settings.preferredGroupMountDisplayNameFluffielsPanicBeam = value
				addFluffielsPanicBeamToMultiRiderMount((value == true and settings.preferredGroupMountDisplayName) or nil)
			end,
			default = defaultSettings.preferredGroupMountDisplayNameFluffielsPanicBeam,
			disabled = function() return FLUFFIELS_PANICBEAMS == nil or FLUFFIELS_PANICBEAMS.SetBFF == nil or settings.preferredGroupMountDisplayName == nil or settings.preferredGroupMountDisplayName == "" end,
		},
		{
			type = "checkbox",
			name    = "Fluffiels Panic Beam: Disable while mounted",
			tooltip = "Disable the Fluffiels' Panic Beam feature \'BFF\' beam on your preferred multi-rider player if you are already mounted",
			getFunc = function() return settings.preferredGroupMountDisplayNameFluffielsPanicBeamDisableWhileMounted end,
			setFunc = function(value)
				settings.preferredGroupMountDisplayNameFluffielsPanicBeamDisableWhileMounted = value
			end,
			default = defaultSettings.preferredGroupMountDisplayNameFluffielsPanicBeamDisableWhileMounted,
			disabled = function() return FLUFFIELS_PANICBEAMS == nil or FLUFFIELS_PANICBEAMS.SetBFF == nil or not settings.preferredGroupMountDisplayNameFluffielsPanicBeam end,
		},

		--==============================================================================
		{
			type = 'header',
			name = "Movement",
		},
		{
			type = "checkbox",
			name    = "Movement blocked - Play sound",
			tooltip = "Plays a sound once as you try to move but you are not really moving (running against a wall for example). The sound will be played once every 3 seconds.",
			getFunc = function() return settings.tryingToMoveButBlockedSound end,
			setFunc = function(value)
				settings.tryingToMoveButBlockedSound = value
				outputLAMSettingsChangeToChat(tos(value), "Movement blocked - Play sound")
			end,
			default = defaultSettings.tryingToMoveButBlockedSound,
			--disabled = function() return false end,
		},
		{
			type = "soundslider",
			name = "Movement blocked: Choose sound", -- or string id or function returning a string
			tooltip = "Choose the sound to play if your movement is blocked. Changing the slider will play the sound once as a preview.", -- or string id or function returning a string (optional)
			getFunc = function() return settings.tryingToMoveButBlockedSoundName end,
			setFunc = function(value)
				settings.tryingToMoveButBlockedSoundName = value
				outputLAMSettingsChangeToChat(tos(value), "Movement blocked: Choose sound")
				runTryingToMoveButBlockedUpdates(value, true)
			end,
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			saveSoundIndex = false, -- or function returning a boolean (optional) If set to false (default) the internal soundName will be saved. If set to true the selected sound's index will be saved to the SavedVariables (the index might change if sounds get inserted later!).
			showSoundName = true, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be shown at the label of the slider, and at the tooltip too
			playSound = false, -- or function returning a boolean (optional) If set to true (default) the selected sound name will be played via function PlaySound
			playSoundData = function() return getPreviewDataTab("MovementBlocked", 1) end, --{number playCount, number delayInMS, number increaseVolume}, -- table or function returning a table. If this table is provided the chosen sound will be played playCount (default is 1) times after each other, with a delayInMS (default is 0) in milliseconds in between, and each played sound will be played increaseVolume times (directly at the same time) to increase the volume (default is 1, max is 10) (optional)
			showPlaySoundButton = true,
			noAutomaticSoundPreview = false,
			readOnly = false, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.tryingToMoveButBlockedSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			--requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.tryingToMoveButBlockedSoundName, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			reference = "FCOAB_LAM_MOVEMENT_TRYING_TO_MOVE_BUT_BLOCKED_SOUNDSLIDER" -- unique global reference to control (optional)
		},
		{
			type = "slider",
			name = "Movement blocked: Volume", -- or string id or function returning a string
			tooltip = "Playing the same sound multiple times increases the volume. Choose how often you want to repeat the played sound if your movement is blocked to increase the volume with this slider.",
			getFunc = function() return settings.tryingToMoveButBlockedSoundRepeat end,
			setFunc = function(value)
				settings.tryingToMoveButBlockedSoundRepeat = value
				outputLAMSettingsChangeToChat(tos(value), "Movement blocked: Volume")
			end,
			min = 1,
			max = 10,
			step = 1, -- (optional)
			clampInput = true, -- boolean, if set to false the input won't clamp to min and max and allow any number instead (optional)
			--clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end, -- function that is called to clamp the value (optional)
			decimals = 0, -- when specified the input value is rounded to the specified number of decimals (optional)
			autoSelect = false, -- boolean, automatically select everything in the text input field when it gains focus (optional)
			inputLocation = "below", -- or "right", determines where the input field is shown. This should not be used within the addon menu and is for custom sliders (optional)
			--readOnly = true, -- boolean, you can use the slider, but you can't insert a value manually (optional)
			width = "full", -- or "half" (optional)
			disabled = function() return not settings.tryingToMoveButBlockedSound end, --or boolean (optional)
			--warning = "May cause permanent awesomeness.", -- or string id or function returning a string (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			default = defaultSettings.tryingToMoveButBlockedSoundRepeat, -- default value or function that returns the default value (optional)
			--helpUrl = "https://www.esoui.com/portal.php?id=218&a=faq", -- a string URL or a function that returns the string URL (optional)
			--reference = "MyAddonSlider", -- unique global reference to control (optional)
			--resetFunc = function(sliderControl) d("defaults reset") end, -- custom function to run after the control is reset to defaults (optional)
		},
	}

	LAM:RegisterOptionControls(addonName, optionsTable)
	CM:RegisterCallback("LAM-PanelControlsCreated", FCOABLAMPanelCreated)
end


--==============================================================================
--============================== END SETTINGS ==================================
--==============================================================================

--Check for other addons and react on them
--[[
local function CheckIfOtherAddonsActive()
	return false
end
]]






function FCOAB.GetCompassCenterPins()
	local bestPinIndices = {}
	local bestPinDistances = {}
	local bestPinDescription, bestPinType

	if not COMPASS_FRAME:GetBossBarActive() then
		ZO_ClearNumericallyIndexedTable(bestPinIndices)
		ZO_ClearNumericallyIndexedTable(bestPinDistances)
		for i = 1, compass.container:GetNumCenterOveredPins() do
			if not compass.container:IsCenterOveredPinSuppressed(i) then
				local drawLayer, drawLevel = compass.container:GetCenterOveredPinLayerAndLevel(i)
				local layerInformedDistance = calculateLayerInformedDistance(drawLayer, drawLevel)
				local insertIndex
				for bestPinIndex = 1, #bestPinIndices do
					if layerInformedDistance < bestPinDistances[bestPinIndex] then
						insertIndex = bestPinIndex
						break
					end
				end
				if not insertIndex then
					insertIndex = #bestPinIndices + 1
				end

				table.insert(bestPinIndices, insertIndex, i)
				table.insert(bestPinDistances, insertIndex, layerInformedDistance)
			end
		end

		for i, centeredPinIndex in ipairs(bestPinIndices) do
			local description = compass.container:GetCenterOveredPinDescription(centeredPinIndex)
			if description ~= "" then
				bestPinDescription = description
				bestPinType = compass.container:GetCenterOveredPinType(centeredPinIndex)
				break
			end
		end
	end

	return bestPinIndices, bestPinDistances, bestPinDescription, bestPinType
end




--==============================================================================
--===== HOOKS BEGIN ============================================================
--==============================================================================
local compassPreHooksDone = false
local compassQuestPreHooksDone = false
CreateCompassHooks = function()
	--Update compass variables
	zosVars.compass = COMPASS
	compass = zosVars.compass
	zosVars.compassCenterOverPinLabel = compass.centerOverPinLabel
	compassCenterOverPinLabel = zosVars.compassCenterOverPinLabel

	local settings = FCOAB.settingsVars.settings
	local compassTrackedQuestSound = settings.compassTrackedQuestSound
	local compassPlayerWaypointSound = settings.compassPlayerWaypointSound
	local compassGroupRallyPointSound = settings.compassGroupRallyPointSound
	local compassToChatText = settings.compassToChatText

	if compassTrackedQuestSound == true or compassPlayerWaypointSound == true or compassGroupRallyPointSound == true or compassToChatText == true then
		if compassCenterOverPinLabel ~= nil then
			--Hooks were already loaded?
			if not compassPreHooksDone then
			--This will be called way too often, multiple times a second...
				ZO_PreHook(compassCenterOverPinLabel, "SetText", function(ctrl, newText)
					settings = FCOAB.settingsVars.settings
					compassTrackedQuestSound = settings.compassTrackedQuestSound
					compassPlayerWaypointSound = settings.compassPlayerWaypointSound
					compassGroupRallyPointSound = settings.compassGroupRallyPointSound
					compassToChatText = settings.compassToChatText

					--Hook is still active?
					if not not compassToChatText and not compassPlayerWaypointSound and not compassGroupRallyPointSound and not compassTrackedQuestSound then return end

					--Get current timestam
					local now = GetGameTimeMilliseconds()

					--Current compass' pinType and pinDescription text
					local compassPinType = FCOAB._bestPinType
					local compassPinDescription = FCOAB._bestPinDescription

					--Compass to chat
					if compassToChatText == true and newText and newText ~= "" then
						local lastCommpass2Chat = lastPlayed.compass2Chat
						if lastCommpass2Chat == 0 or now >= (lastCommpass2Chat + compassToChatDelay) then
							local doCompassTextOutput = true
							--Check if the compassPin is the group leader and skip the chat output?
							if settings.compassToChatTextSkipGroupLeader == true and (compassPinType ~= nil and groupLeaderPinTypes[compassPinType]) then
								doCompassTextOutput = false
								--Check if the compassPin is a group member and skip the chat output?
							elseif settings.compassToChatTextSkipGroupMember == true and (compassPinType ~= nil and groupPinTypes[compassPinType]) then
								doCompassTextOutput = false
							end

							if doCompassTextOutput == true then
								if lastAddedToChat == nil or lastAddedToChat == "" or lastAddedToChat ~= newText then
									lastAddedToChat = newText
									local compassStr = getCompassChatText(newText)
									--Check if compass text is a group member, or the leader, or a group ralley point
									addToChatWithPrefix(compassStr .. newText)
								end
							end
						end
					end

					--Player waypoint sound
					if compassPlayerWaypointSound == true and settings.compassPlayerWaypointSoundName ~= CON_SOUND_NONE and hasWaypoint() then
						--Your waypoint is currently in the middle
						local normX, normY = gmpw()
						if normX ~= nil and normY ~= nil and ((compassPinType ~= nil and playerWaypointPinTypes[compassPinType]) or (newText and newText == yourPlayersWaypointStr)) then
							local lastPlayedWaypoint = lastPlayed.waypoint
							local waitTime = settings.compassPlayerWaypointSoundDelay * 1000

							--d("[FCOAB]ZO_CompassCenterOverPinLabel - Waypoint - waitTime: " ..tos(waitTime) .. ", " ..tos(newText) .. ", x: " ..tos(normX) .. ", y: " ..tos(normY))
							if lastPlayedWaypoint == 0 or now >= (lastPlayedWaypoint + waitTime) then
								lastPlayed.waypoint = now
								playSoundLoopNow(settings.compassPlayerWaypointSoundName, settings.compassPlayerWaypointSoundRepeat)
							end
						end
					end

					--Group rally point sound
					if compassGroupRallyPointSound == true and settings.compassGroupRallyPointSoundName ~= CON_SOUND_NONE and IsUnitGrouped(CON_PLAYER) and hasRallyPoint() then
						--Your rallypoint is currently in the middle
						local normX, normY = gmrp()
						if normX ~= nil and normY ~= nil and ((compassPinType ~= nil and groupRallyPointPinTypes[compassPinType]) or (newText and newText == rallyPointStr)) then
							local lastPlayedRallyPoint = lastPlayed.rallyPoint
							local waitTime = settings.compassGroupRallyPointSoundDelay * 1000

							if lastPlayedRallyPoint == 0 or now >= (lastPlayedRallyPoint + waitTime) then
								lastPlayed.rallyPoint = now
								playSoundLoopNow(settings.compassGroupRallyPointSoundName, settings.compassGroupRallyPointSoundRepeat)
							end
						end
					end

					--Active quest found?
					if compassTrackedQuestSound == true and settings.compassTrackedQuestSoundName ~= CON_SOUND_NONE and lastTrackedQuestIndex ~= nil and lastTrackedQuestIndex ~= 0 then
						if compassPinType ~= nil and (trackedQuestPinTypes[compassPinType] or assistedQuestPinTypes[compassPinType]) and compassPinDescription ~= nil and newText and compassPinDescription == newText then
							local lastPlayedQuest = lastPlayed.quest
							local waitTime = settings.compassTrackedQuestSoundDelay * 1000

							--d("[FCOAB]ZO_CompassCenterOverPinLabel - Quest - waitTime: " ..tos(waitTime) .. ", questPinType: " ..tos(questPinType) .. ", questPinDescription: " .. tos(questPinDescription) ..", newText: " ..tos(newText) .. ", lastTrackedQuestIndex: " ..tos(lastTrackedQuestIndex))
							if lastPlayedQuest == 0 or now >= (lastPlayedQuest + waitTime) then
								lastPlayed.quest = now
								playSoundLoopNow(settings.compassTrackedQuestSoundName, settings.compassTrackedQuestSoundRepeat)
							end
						end
					end
				end)
				compassPreHooksDone = true
			end
		end
	end


	--Quest tracker
	if compassTrackedQuestSound == true and not compassQuestPreHooksDone then
		local function onQuestTrackerTrackingStateChanged(questTracker, tracked, trackType, arg1, arg2)
			--d("[FCOAB]onQuestTrackerTrackingStateChanged-tracked: " ..tos(tracked) .. ", type: " ..tos(trackType) .. ", arg1: " ..tos(arg1) .. ", arg2: " ..tos(arg2))
			if trackType == TRACK_TYPE_QUEST and tracked == true then
				lastTrackedQuestIndex = arg1
				--Update the SavedVariables
				FCOAB.settingsVars.settings.lastTrackedQuestIndex = lastTrackedQuestIndex
				--local trackingLevel = GetTrackingLevel(TRACK_TYPE_QUEST, lastTrackedQuestIndex)

				-- @return questName string, backgroundText string, activeStepText string, activeStepType integer, activeStepTrackerOverrideText string, completed bool, tracked bool, questLevel integer, pushed bool, questType integer, instanceDisplayType [InstanceDisplayType|#InstanceDisplayType]
				lastTrackedQuestName, lastTrackedQuestBackgroundText, lastTrackedQuestActiveStepText = GetJournalQuestInfo(lastTrackedQuestIndex)
				--d(">index: " ..tos(lastTrackedQuestIndex) .. ", name: " ..tos(lastTrackedQuestName) .. ", backgroundText: " ..tos(lastTrackedQuestBackgroundText) .. ", activeStepText: " ..tos(lastTrackedQuestActiveStepText))
			end
		end
		FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerTrackingStateChanged", onQuestTrackerTrackingStateChanged)


		--Compass:OnUpdate call hooks
		local TIME_BETWEEN_LABEL_UPDATES_MS = 100

		local bestPinIndices = {}
		local bestPinDistances = {}

		local pinTypeToFormatId =
		{
			[MAP_PIN_TYPE_POI_SEEN] = SI_COMPASS_LOCATION_NAME_FORMAT,
			[MAP_PIN_TYPE_POI_COMPLETE] = SI_COMPASS_LOCATION_NAME_FORMAT,
		}

		function COMPASS:OnUpdate()
			local self = compass
			if self.areaOverrideAnimation:IsPlaying() then
				self.centerOverPinLabelAnimation:PlayBackward()
			elseif not self.centerOverPinLabelAnimation:IsPlaying() or not self.centerOverPinLabelAnimation:IsPlayingBackward() then
				local now = GetFrameTimeMilliseconds()
				if now < self.nextLabelUpdateTime then
					return
				end
				self.nextLabelUpdateTime = now + TIME_BETWEEN_LABEL_UPDATES_MS

				local bestPinDescription
				local bestPinType
				if not COMPASS_FRAME:GetBossBarActive() then
					ZO_ClearNumericallyIndexedTable(bestPinIndices)
					ZO_ClearNumericallyIndexedTable(bestPinDistances)
					for i = 1, self.container:GetNumCenterOveredPins() do
						if not self.container:IsCenterOveredPinSuppressed(i) then
							local drawLayer, drawLevel = self.container:GetCenterOveredPinLayerAndLevel(i)
							local layerInformedDistance = calculateLayerInformedDistance(drawLayer, drawLevel)
							local insertIndex
							for bestPinIndex = 1, #bestPinIndices do
								if layerInformedDistance < bestPinDistances[bestPinIndex] then
									insertIndex = bestPinIndex
									break
								end
							end
							if not insertIndex then
								insertIndex = #bestPinIndices + 1
							end

							table.insert(bestPinIndices, insertIndex, i)
							table.insert(bestPinDistances, insertIndex, layerInformedDistance)
						end
					end

					for i, centeredPinIndex in ipairs(bestPinIndices) do
						local description = self.container:GetCenterOveredPinDescription(centeredPinIndex)
						if description ~= "" then
							bestPinDescription = description
							bestPinType = self.container:GetCenterOveredPinType(centeredPinIndex)
							break
						end
					end

					--For debugging
					FCOAB._bestPinIndices = 	ZO_ShallowTableCopy(bestPinIndices)
					FCOAB._bestPinDistances = 	ZO_ShallowTableCopy(bestPinDistances)
					FCOAB._bestPinDescription = bestPinDescription
					FCOAB._bestPinType = 		bestPinType
				end

				if bestPinDescription then
					noCompassPinSelected = false
					local formatId = pinTypeToFormatId[bestPinType]
					--The first 3 types are the player pins (self, group, leader)
					if bestPinType < 3 then
						bestPinDescription = ZO_FormatUserFacingCharacterOrDisplayName(bestPinDescription)
					end
					if formatId then
						self.centerOverPinLabel:SetText(ZO_CachedStrFormat(formatId, bestPinDescription))
					else
						self.centerOverPinLabel:SetText(bestPinDescription)
					end

					self.centerOverPinLabelAnimation:PlayForward()
				else
					noCompassPinSelected = true
					--reset the last played sound time of waypoint, qeust etc. so that the next selected compass pin plays a sound directly again
					lastPlayed.waypoint = 0
					lastPlayed.rallyPoint = 0
					lastPlayed.quest = 0

					self.centerOverPinLabelAnimation:PlayBackward()
				end
			end
		end

		compassQuestPreHooksDone = true
	end
end

local function CreateWaypointHooks()
	SecurePostHook("SetMapPlayerWaypoint", function() --why isn't this called properly as a new waypoint is set?
--d("[FCOAB]PostHook SetMapPlayerWaypoint")
		--Auto remove wayshines update handler: Enable/or disable
		runWaypointRemoveUpdates(isWaypointSetAndShouldBeRemovedAutomaticallyByFCOAB(), true)
	end)

	--Gamepad map keybind for "Set waypoint" / "Ziel setzen"
	--[[
	local x, y = NormalizePreferredMousePositionToMap()
	if ZO_WorldMap_IsNormalizedPointInsideMapBounds(x, y) then
		PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, x, y)
		g_keybindStrips.gamepad:DoMouseEnterForPinType(MAP_PIN_TYPE_PLAYER_WAYPOINT) -- this should have been called by the mouseover update, but it's not getting called
	end
	]]
	SecurePostHook("PingMap", function(mapPinType, mapTypeLocation, x, y)
		if mapPinType == MAP_PIN_TYPE_PLAYER_WAYPOINT and mapTypeLocation == MAP_TYPE_LOCATION_CENTERED and ZO_WorldMap_IsNormalizedPointInsideMapBounds(x, y) then
--d("[FCOAB]PingMap MAP_PIN_TYPE_PLAYER_WAYPOINT - x: " ..tos(x) .. ", y: " ..tos(y))
			--Auto remove wayshines update handler: Enable/or disable
			runWaypointRemoveUpdates(isWaypointSetAndShouldBeRemovedAutomaticallyByFCOAB(), true)
		end
	end)


	--[[
	SecurePostHook("SetPlayerWaypointByWorldLocation", function() --only used for furniture/houses?
d("[FCOAB]PostHook SetPlayerWaypointByWorldLocation")
		--Auto remove wayshines update handler: Enable/or disable
		runWaypointRemoveUpdates(FCOAB.settingsVars.settings.autoRemoveWaypoint and hasWaypoint(), true)
	end)
	]]

	SecurePostHook("RemovePlayerWaypoint", function() --alos called from within ZO_WorldMap_RemovePlayerWaypoint
--d("[FCOAB]PostHook RemovePlayerWaypoint")
		--Auto remove wayshines update handler: Enable/or disable
		runWaypointRemoveUpdates(false, true)
	end)
end

local function loadESOAccessibilityFixes()
	--ESO Accessibility narration volume
	local ESOaccessibilityFix_LastNarrationVolume = FCOAB.settingsVars.settings.ESOaccessibilityFix_LastNarrationVolume
	--Set current narration volue slider to that value
	--SETTING_TYPE_ACCESSIBILITY, ACCESSIBILITY_SETTING_NARRATION_VOLUME  (SETTING_PANEL_ACCESSIBILITY)
	if isAccessibilityModeEnabled() then
		changeAccessibilitSettingTo(ESOaccessibilityFix_LastNarrationVolume, ACCESSIBILITY_SETTING_NARRATION_VOLUME)
	end
end

local function onPlayerActivated()
	--ESO accessibility fixes
	loadESOAccessibilityFixes()

	if FCOAB.settingsVars.settings.combatTipsToChat == true then
		enableActiveCombatTipsIfDisabled()
		--Is the addon AccountSettings enabled?
		if AccountSettings ~= nil then
			--AccountSettings will switch the settings to other account settings, but starting after 5seconds.
			--So we wait another +2 after that and change this setting again then
			local delay = 7000
			zo_callLater(function() enableActiveCombatTipsIfDisabled() end, delay)
		end
	end

	--Auto remove waypoints if reached?
	runWaypointRemoveUpdates(isWaypointSetAndShouldBeRemovedAutomaticallyByFCOAB(), true)

	--Play sound for group leader handler: Enable/or disable
	if isGroupedAndGroupLeaderGivenAndShouldSoundPlayByFCOAB() then
		onGroupStatusChange(false, false, false, true)
	end

	--Play sound is player is trying to move but cannot move (and is not stunned)
	runTryingToMoveButBlockedUpdates(true, nil)
end

local function onPlayerDead(eventId)
	onGroupStatusChange(false, false, true, false)

	runTryingToMoveButBlockedUpdates(false, true)
end

------------------------------------------------------------------------------------------------------------------------
local function CreateReticleHooks()
	reticleUnitData()
	interactionData()
end

local function CreateGroupHooks()
	--Player is promoting someone else to the leader? EVENT_GROUP_UPDATE won't fire then...
	-->So simulate it
	SecurePostHook("GroupPromote", function(unitTag)
		--Delay a bit to let group update happen
		zo_callLater(function()
			if isGroupedAndGroupLeaderGivenAndShouldSoundPlayByFCOAB() then
				onGroupStatusChange(false, false, false, true)
			end
		end, 1000)
	end)

	registerGroupLeaderMapPinPingPong()
end


local function CreateESOHooks()
	--Add an own ActionLayer fragment for the Gamepad WorldMap keybinds
	registerGamepadWorldMapActionLayerFragment()

	-- PreHook ReloadUI, SetCVar, LogOut & Quit to handle current accesibility mode narration volume
    ZO_PreHook("ReloadUI", function()
		updateCurrentAccesibilityNarrationVolume()
		return false
    end)

    ZO_PreHook("Logout", function()
		updateCurrentAccesibilityNarrationVolume()
		return false
    end)

    ZO_PreHook("Quit", function()
		updateCurrentAccesibilityNarrationVolume()
		return false
	end)
end


--Create the hooks & pre-hooks
local function CreateHooks()
	CreateESOHooks()

	--other compass hooks
	CreateCompassHooks()

	--other player waypoint related hooks
	CreateWaypointHooks()

	--other hooks for the reticle
	CreateReticleHooks()

	--Group hooks
	CreateGroupHooks()

	--React on an input mode change keyboard->gamepad->keyboard and register the needed hooks
	--EM:RegisterForEvent(addonName .. "_EVENT_INPUT_TYPE_CHANGED", EVENT_INPUT_TYPE_CHANGED, onEventInputTypeChanged)
end

--Register the slash commands
local function RegisterSlashCommands()
    -- Register slash commands
	SLASH_COMMANDS["/FCOAccessibility"] 	= command_handler
	SLASH_COMMANDS["/fcna"] 				= command_handler
end

--Load the SavedVariables
local function LoadUserSettings()
--The default values for the language and save mode
    FCOAB.settingsVars.firstRunSettings = {
        --language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide FCOAB.settingsVars.settings
    }

    --Pre-set the deafult values
    FCOAB.settingsVars.defaults = {
		["WAYPOINT_DELTA_SCALE"] = 3,
		["WAYPOINT_DELTA_SCALE_MAX"] = 5000,

		["autoRemoveWaypoint"] = true,

		["chatAddonPrefix"] = "",

		["combatEndSound"] = true,
		["combatEndSoundName"] = "Tribute_Summary_ProgressBarDecrease",
		["combatEndSoundRepeat"] = 4,
		["combatStartEndInfo"] = false,
		["combatStartSound"] = true,
		["combatStartSoundName"] = "Tribute_Summary_ProgressBarIncrease",
		["combatStartSoundRepeat"] = 4,

		["combatTipSound"] = true,
		["combatTipSoundName"] =
		{
			[1] = "Duel_Forfeit",
			[2] = "Champion_PointGained",
			[3] = "Duel_Forfeit",
			[4] = "Champion_PointsCommitted",
		},
		["combatTipSoundRepeat"] =
		{
			[1] = 5,
			[2] = 5,
			[3] = 4,
			[4] = 3,
		},
		["combatTipToChat"] = true,

		["compassGroupRallyPointSound"] = false,
		["compassGroupRallyPointSoundDelay"] = 2,
		["compassGroupRallyPointSoundName"] = "GroupElection_ResultLost",
		["compassGroupRallyPointSoundRepeat"] = 1,

		["compassPlayerWaypointSound"] = true,
		["compassPlayerWaypointSoundDelay"] = 0.3500000000,
		["compassPlayerWaypointSoundName"] = "Lock_Value",
		["compassPlayerWaypointSoundRepeat"] = 1,

		["compassTrackedQuestSound"] = true,
		["compassTrackedQuestSoundDelay"] = 2,
		["compassTrackedQuestSoundName"] = "New_NotificationTimed",
		["compassTrackedQuestSoundRepeat"] = 1,
		["compassToChatText"] = true,
		["compassToChatTextSkipGroupLeader"] = true,
		["compassToChatTextSkipGroupMember"] = false,

		["groupLeaderDistanceToChat"] = false,
		["groupLeaderSound"] = true,
		["groupLeaderSoundAngle"] = 70,
		["groupLeaderSoundDelay"] = 2.1000000000,
		["groupLeaderSoundDistance"] = 7,
		["groupLeaderSoundName"] = "Champion_StarSlotted",
		["groupLeaderSoundRepeat"] = 1,

		["groupLeaderClockPosition"] = true,
		["groupLeaderClockPositionRepeatSame"] = false,
		["groupLeaderClockPositionDelay"] = 4,
		["groupLeaderClockPositionIfLookingAtGroupLeader"] = false,
		["chatGroupLeaderClockPositionPrefix"] = ".",
		["groupLeaderPinPingPong"] = false,
		["groupLeaderPinPingPongScaling"] = 3,
		["groupLeaderPinPingPongBreadcrumbed"] = true,

		["playerPinPingPongScaling"] = 3,

		["preferredGroupMountDisplayName"] = "",
		["preferredGroupMountDisplayNameFluffielsPanicBeam"] = false,
		["preferredGroupMountDisplayNameFluffielsPanicBeamDisableWhileMounted"] = false,

		["reticleInteractionToChatText"] = true,
		["reticleToChatInteractionDisableInGroup"] = false,

		["reticlePlayerToChatText"] = true,
		["reticlePlayerAlliance"] = false,
		["reticlePlayerClass"] = true,
		["reticlePlayerLevel"] = false,
		["reticlePlayerRace"] = false,
		["reticleToChatPlayerDisableInGroup"] = true,
		["reticleToChatUnitDisableInGroup"] = false,
		["reticleUnitToChatText"] = true,
		["reticleUnitIgnoreCritter"] = true,

		["reticleToChatInCombat"] = true,

		["showReticleOverUnitHealthInChat"] = true,

		["thisAddonLAMSettingsSetFuncToChat"] = true,

		["tryingToMoveButBlockedSound"] = true,
		["tryingToMoveButBlockedSoundName"] = "Enchanting_EssenceRune_Placed",
		["tryingToMoveButBlockedSoundRepeat"] = 4,

		["lastTrackedQuestIndex"] = 1,

		["targetMarkersSetInCombatToEnemies"] = true,

		["groupLeaderDirectionPosition"] = false,
		["chatGroupLeaderDirectionPosition"] = {
			["west"] =	"west",
			["north"] = "north",
			["east"] = 	"east",
			["south"] =	"south",
		},

		--ESO workarounds
		--Accessibility mode settings: Narration volume (not saving properly for the game as it seems. So save it at logout/exit and
		--load at event_player_activated each time
		["ESOaccessibilityFix_LastNarrationVolume"] = "13.00000000",
    }
	local defaults = FCOAB.settingsVars.defaults

	local worldName = GetWorldName()
	local addonSavedVariablesName = addonVars.addonSavedVariablesName
	local addonSavedVariablesVersion = addonVars.addonSavedVariablesVersion

--=============================================================================================================
--	LOAD USER SETTINGS
--=============================================================================================================
    --Load the user's FCOAB.settingsVars.settings from SavedVariables file -> Account wide of basic version 999 at first
	FCOAB.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(addonSavedVariablesName, 999, "SettingsForAll", FCOAB.settingsVars.firstRunSettings, worldName)

	--Check, by help of basic version 999 FCOAB.settingsVars.settings, if the FCOAB.settingsVars.settings should be loaded for each character or account wide
    --Use the current addon version to read the FCOAB.settingsVars.settings now
	if (FCOAB.settingsVars.defaultSettings.saveMode == 1) then
    	FCOAB.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(addonSavedVariablesName, addonSavedVariablesVersion, "Settings", defaults, worldName)
	else
		FCOAB.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonSavedVariablesName, addonSavedVariablesVersion, "Settings", defaults, worldName, nil)
	end
--=============================================================================================================

	--Update the last tracked questInded
	if FCOAB.settingsVars.settings.lastTrackedQuestIndex ~= 0 then
		lastTrackedQuestIndex = FCOAB.settingsVars.settings.lastTrackedQuestIndex
		lastTrackedQuestName, lastTrackedQuestBackgroundText, lastTrackedQuestActiveStepText = GetJournalQuestInfo(lastTrackedQuestIndex)
	end

	--Fix if group leader clock and direction are both enabled
	if FCOAB.settingsVars.settings.groupLeaderClockPosition == true then
		FCOAB.settingsVars.settings.groupLeaderDirectionPosition = false
	end
end


--Addon loads up
local function FCOAccessibility_Loaded(eventCode, addOnNameOfEachAddonLoaded)
	--Is this addon found?
	if addOnNameOfEachAddonLoaded ~= addonName then return end
	--Unregister this event again so it isn't fired again after this addon has beend reckognized
	EM:UnregisterForEvent(addonName .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)

	addonVars.gAddonLoaded = false

	LAM = LibAddonMenu2
	GPS = LibGPS3

	--esoui\ingame\keybindings\keyboard\keybindings.lua
	function KEYBINDING_MANAGER:IsChordingAlwaysEnabled() return true end

	--SavedVariables
	LoadUserSettings()

	--Show the menu
	BuildAddonMenu()

	--Create the hooks
	CreateHooks()

	-- Register slash commands
	--RegisterSlashCommands()

	--Events
	--Player Activated/Zone change with laoding screen (e.g. after Port to Group Leader)
	EM:RegisterForEvent(addonName .. "_EVENT_PLAYER_ACTIVATED",			EVENT_PLAYER_ACTIVATED,		onPlayerActivated)

	--Death
	EM:RegisterForEvent(addonName .. "_EVENT_PLAYER_ALIVE",				EVENT_PLAYER_ALIVE,			onPlayerActivated)
	EM:RegisterForEvent(addonName .. "_EVENT_PLAYER_DEAD",				EVENT_PLAYER_DEAD,			onPlayerDead)

	--Group
	EM:RegisterForEvent(addonName .. "_EVENT_GROUP_MEMBER_LEFT", 		EVENT_GROUP_MEMBER_LEFT, 	function() onGroupStatusChange(true, false, false, false) end)
	EM:RegisterForEvent(addonName .. "_EVENT_GROUP_MEMBER_JOINED", 		EVENT_GROUP_MEMBER_JOINED, 	function() onGroupStatusChange(false, true, false, false) end)
	EM:RegisterForEvent(addonName .. "_EVENT_GROUP_UPDATE", 			EVENT_GROUP_UPDATE, 		function() onGroupStatusChange(false, false, true, false) end)

	--Mount
	EM:RegisterForEvent(addonName .. "_EVENT_MOUNTED_STATE_CHANGED", 	EVENT_MOUNTED_STATE_CHANGED, onMountStateChange)


	--Combat
	EM:RegisterForEvent(addonName .. "_EVENT_PLAYER_COMBAT_STATE", 		EVENT_PLAYER_COMBAT_STATE, 	onPlayerCombatState)
	EM:RegisterForEvent(addonName .. "_EVENT_DISPLAY_ACTIVE_COMBAT_TIP", EVENT_DISPLAY_ACTIVE_COMBAT_TIP, function(_, tipId)
		--Chat output for the combat tipId
		showCombatTipInChat(tipId)
	end)
	--[[
	EM:RegisterForEvent(addonName .. "_EVENT_REMOVE_ACTIVE_COMBAT_TIP", EVENT_REMOVE_ACTIVE_COMBAT_TIP, function(_, tipId)
	end)
	]]

	addonVars.gAddonLoaded = true

	--Enable Fluffiels Panic Beam BFF feature to preferred multi-rider mount
	addFluffielsPanicBeamToMultiRiderMount(FCOAB.settingsVars.settings.preferredGroupMountDisplayName)
end

-- Register the event "addon loaded" for this addon
local function FCOAccessibility_Initialized()
	EM:RegisterForEvent(addonName .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, 					FCOAccessibility_Loaded)
end

--------------------------------------------------------------------------------
--- Call the start function for this addon to register events etc.
--------------------------------------------------------------------------------
FCOAccessibility_Initialized()

