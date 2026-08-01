local LIB_IDENTIFIER = "LibResurrection"
local lib = LibStub:NewLibrary(LIB_IDENTIFIER, 2)

if not lib then
	return	-- already loaded and no upgrade necessary
end

--- PlayerResurrectionCancelledReason
--- These specify why the resurrection was cancelled before it could get to the second stage.
--- The resurrection was cancelled for an unknown reason
lib.PLAYER_RESURRECTION_CANCELLED_REASON_UNKNOWN = 0
--- Another player finished faster than us
lib.PLAYER_RESURRECTION_CANCELLED_REASON_ALREADY_CONSIDERING = 1
--- There is still a resurrection pending on a different target
lib.PLAYER_RESURRECTION_CANCELLED_REASON_SOUL_GEM_IN_USE = 2
--- There are no valid soul gems available
lib.PLAYER_RESURRECTION_CANCELLED_REASON_NO_SOUL_GEM = 3
--- New ingame reason added with 100014. No idea what it is yet
lib.PLAYER_RESURRECTION_CANCELLED_REASON_IN_KILLZONE = 4
--- Resurrection was stopped voluntarily
lib.PLAYER_RESURRECTION_CANCELLED_REASON_PLAYER = 5 -- TODO not detected for now
--- An enemy interrupted the resurrection with an attack
lib.PLAYER_RESURRECTION_CANCELLED_REASON_INTERRUPTED = 6 -- TODO not detected for now
--- The target player respawned by himself
lib.PLAYER_RESURRECTION_CANCELLED_REASON_RESPAWNED = 7 -- TODO not detected for now
--- The target player disconnected
lib.PLAYER_RESURRECTION_CANCELLED_REASON_DISCONNECTED = 8 -- TODO not detected for now

--- PlayerResurrectionFailedReason
--- These specify why the resurrection failed in the second stage.
--- The resurrection failed for an unknown reason
lib.PLAYER_RESURRECTION_FAILED_REASON_UNKNOWN = 0
--- The target player declined the resurrection
lib.PLAYER_RESURRECTION_FAILED_REASON_DECLINED = 1
--- The target player waited to long and the resurrection timed out
lib.PLAYER_RESURRECTION_FAILED_REASON_TIMEOUT = 2
--- The target player respawned by himself
lib.PLAYER_RESURRECTION_FAILED_REASON_RESPAWNED = 3 -- TODO not detected for now
--- The target player disconnected
lib.PLAYER_RESURRECTION_FAILED_REASON_DISCONNECTED = 4 -- TODO not detected for now

local INGAME_REASON_TO_CANCEL_REASON = {
	[RESURRECT_RESULT_ALREADY_CONSIDERING] = lib.PLAYER_RESURRECTION_CANCELLED_REASON_ALREADY_CONSIDERING,
	[RESURRECT_RESULT_NO_SOUL_GEM] = lib.PLAYER_RESURRECTION_CANCELLED_REASON_NO_SOUL_GEM,
	[RESURRECT_RESULT_SOUL_GEM_IN_USE] = lib.PLAYER_RESURRECTION_CANCELLED_REASON_SOUL_GEM_IN_USE,
	[RESURRECT_RESULT_IN_KILLZONE] = lib.PLAYER_RESURRECTION_CANCELLED_REASON_IN_KILLZONE,
}

local P2P_UNIT_TAG = "reticleoverplayer"
local RESURRECT_TRIGGER_ABILITY_ID = 55406
local EVENT_MANAGER = EVENT_MANAGER

local originalAcceptResurrect, originalDeclineResurrect

local function ResetTimeout(callback, duration)
	if(lib.timeoutId ~= nil) then
		EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction" .. lib.timeoutId)
	end
	lib.timeoutId = zo_callLater(callback, duration)
end

local function ClearOutgoingResurrect()
	lib.outgoingStartTime = nil
	lib.outgoingEndTime = nil
	lib.outgoingDuration = nil
	lib.outgoingTriggerGained = false
	lib.outgoingCharacterName = nil
	lib.outgoingPlayerName = nil
	if(lib.timeoutId ~= nil) then
		EVENT_MANAGER:UnregisterForUpdate("CallLaterFunction" .. lib.timeoutId)
		lib.timeoutId = nil
	end
end

local function OnSoulGemResurrectionStart(_, duration)
	lib.lastTargetCharacterName = GetUnitName(P2P_UNIT_TAG)
	lib.lastTargetPlayerName = GetUnitDisplayName(P2P_UNIT_TAG)
	lib.cm:FireCallbacks("TargetResurrectionStarted", lib.lastTargetCharacterName, lib.lastTargetPlayerName, duration)
	lib.outgoingStartTime = GetFrameTimeMilliseconds()
	lib.outgoingEndTime = nil
	lib.outgoingTriggerGained = false
end

local function OnResurrectionTimedOut()
	if(lib.outgoingCharacterName) then
		lib.cm:FireCallbacks("TargetResurrectionFailed", lib.lastTargetCharacterName, lib.lastTargetPlayerName, lib.PLAYER_RESURRECTION_FAILED_REASON_UNKNOWN)
	end
	ClearOutgoingResurrect()
end

local function OnResurrectionApplied()
	if(lib.outgoingTriggerGained and lib.outgoingEndTime) then
		lib.outgoingCharacterName, lib.outgoingPlayerName, lib.outgoingStartTime = lib.lastTargetCharacterName, lib.lastTargetPlayerName, GetFrameTimeMilliseconds()
		-- fallback in case we do not get an accepted or failed event (e.g. player respawned on his own)
		ResetTimeout(OnResurrectionTimedOut, lib.outgoingDuration + 1000)
		lib.cm:FireCallbacks("TargetResurrectionPending", lib.lastTargetCharacterName, lib.lastTargetPlayerName, lib.outgoingDuration)
	else -- this does not get called when there is a known reason, because the timeout will get cleared in that case
		lib.cm:FireCallbacks("TargetResurrectionCancelled", lib.lastTargetCharacterName, lib.lastTargetPlayerName, lib.PLAYER_RESURRECTION_CANCELLED_REASON_UNKNOWN)
		ClearOutgoingResurrect()
	end
end

local function OnSoulGemResurrectionEnd()
	if(not lib.outgoingStartTime) then return end
	lib.outgoingEndTime = GetFrameTimeMilliseconds()
	ResetTimeout(OnResurrectionApplied, 1) -- wait until both events have fired
end

local function OnResurrectTriggerChanged(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
	if(lib.outgoingEndTime and (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED)) then
		lib.outgoingTriggerGained = true
		lib.outgoingDuration = (endTime - beginTime) * 1000
		ResetTimeout(OnResurrectionApplied, 1) -- wait until both events have fired
	end
end

local function OnResurrectResult(_, targetChar, reason, targetDisplayName)
	local characterName, playerName, timeLeftToAcceptMs = lib:GetOutgoingPendingResurrectInfo()
	local cancelReason = INGAME_REASON_TO_CANCEL_REASON[reason]
	if(reason == RESURRECT_RESULT_SUCCESS) then
		lib.cm:FireCallbacks("TargetResurrectionAccepted", characterName, playerName)
	elseif(cancelReason) then
		lib.cm:FireCallbacks("TargetResurrectionCancelled", characterName, playerName, cancelReason)
	else
		if(timeLeftToAcceptMs == 0) then
			reason = lib.PLAYER_RESURRECTION_FAILED_REASON_TIMEOUT
		elseif(reason == RESURRECT_RESULT_DECLINED) then
			reason = lib.PLAYER_RESURRECTION_FAILED_REASON_DECLINED
		else
			reason = lib.PLAYER_RESURRECTION_FAILED_REASON_UNKNOWN
		end
		lib.cm:FireCallbacks("TargetResurrectionFailed", characterName, playerName, reason)
	end
	ClearOutgoingResurrect()
end

local function OnResurrectRequest()
	local characterName, playerName, timeLeft = lib:GetIncomingPendingResurrectInfo()
	lib.cm:FireCallbacks("PlayerResurrectionPending", characterName, playerName, timeLeft)
	lib.lastIncomingCharacterName = characterName
	lib.lastIncomingPlayerName = playerName
	lib.lastIncomingWasAccepted = nil
end

local function OnResurrectRequestRemoved()
	if(not lib.lastIncomingCharacterName) then return end -- otherwise we fire the failed callback twice
	if(lib.lastIncomingWasAccepted) then
		lib.cm:FireCallbacks("PlayerResurrectionAccepted", lib.lastIncomingCharacterName, lib.lastIncomingPlayerName)
	else
		local reason = (lib.lastIncomingWasAccepted == false) and lib.PLAYER_RESURRECTION_FAILED_REASON_DECLINED or lib.PLAYER_RESURRECTION_FAILED_REASON_TIMEOUT
		lib.cm:FireCallbacks("PlayerResurrectionFailed", lib.lastIncomingCharacterName, lib.lastIncomingPlayerName, reason)
	end
	lib.lastIncomingCharacterName = nil
	lib.lastIncomingPlayerName = nil
end

local function CustomAcceptResurrect()
	lib.lastIncomingWasAccepted = true
	originalAcceptResurrect()
end

local function CustomDeclineResurrect()
	lib.lastIncomingWasAccepted = false
	originalDeclineResurrect()
end

--- Returns the character name, display name and time remaining on an incoming resurrection.
function lib:GetIncomingPendingResurrectInfo()
	local characterName, timeLeft, displayName = GetPendingResurrectInfo()
	return characterName, displayName, timeLeft
end

--- Returns the character name, display name and time remaining on an outgoing resurrection.
function lib:GetOutgoingPendingResurrectInfo()
	if(lib.outgoingCharacterName) then
		return lib.outgoingCharacterName, lib.outgoingPlayerName, math.max(0, GetFrameTimeMilliseconds() - lib.outgoingStartTime)
	end
	return "", "", 0
end

--- Register to callbacks from the library.
--- Valid callbacks are PlayerResurrectionPending, PlayerResurrectionPending and PlayerResurrectionFailed for incoming resurrections
--- and TargetResurrectionStarted, TargetResurrectionCancelled, TargetResurrectionPending, TargetResurrectionAccepted and TargetResurrectionFailed for outgoing resurrections.
---
--- They provide the player name and some additional information about the progress:
--- PlayerResurrectionPending(string incomingCharacterName, string incomingPlayerName, number timeLeft) - fired when the first stage succeeded
--- PlayerResurrectionAccepted(string incomingCharacterName, string incomingPlayerName) - fired when we accept the resurrection
--- PlayerResurrectionFailed(string incomingCharacterName, string incomingPlayerName, PlayerResurrectionFailedReason reason) - fired when the resurrection failed after completing the first stage
---
--- TargetResurrectionStarted(string targetCharacterName, string targetPlayerName, number duration) - fired when the player starts resurrecting another player
--- TargetResurrectionCancelled(string targetCharacterName, string targetPlayerName, PlayerResurrectionCancelledReason reason) - fired when the resurrecting stopped before reaching the second stage
--- TargetResurrectionPending(string targetCharacterName, string targetPlayerName, number timeLeft) - fired when the first stage succeeded
--- TargetResurrectionAccepted(string targetCharacterName, string targetPlayerName) - fired when the target player accepts the resurrection
--- TargetResurrectionFailed(string targetCharacterName, string targetPlayerName, PlayerResurrectionFailedReason reason) - fired when the resurrection failed after completing the first stage
function lib:RegisterCallback(...)
	lib.cm:RegisterCallback(...)
end

--- Unregister from callbacks. See lib:RegisterCallback.
function lib:UnregisterCallback(...)
	lib.cm:UnregisterCallback(...)
end

local function Unload()
	EVENT_MANAGER:UnregisterForEvent(LIB_IDENTIFIER, EVENT_EFFECT_CHANGED)
	EVENT_MANAGER:UnregisterForEvent(LIB_IDENTIFIER, EVENT_RESURRECT_REQUEST_REMOVED)
	EVENT_MANAGER:UnregisterForEvent(LIB_IDENTIFIER, EVENT_RESURRECT_REQUEST)
	EVENT_MANAGER:UnregisterForEvent(LIB_IDENTIFIER, EVENT_RESURRECT_RESULT)
	EVENT_MANAGER:UnregisterForEvent(LIB_IDENTIFIER, EVENT_END_SOUL_GEM_RESURRECTION)
	EVENT_MANAGER:UnregisterForEvent(LIB_IDENTIFIER, EVENT_START_SOUL_GEM_RESURRECTION)

	AcceptResurrect = originalAcceptResurrect
	DeclineResurrect = originalDeclineResurrect
end

local function Load()
	if(not lib.cm) then
		lib.cm = ZO_CallbackObject:New()
	end

	originalAcceptResurrect = AcceptResurrect
	originalDeclineResurrect = DeclineResurrect

	AcceptResurrect = CustomAcceptResurrect
	DeclineResurrect = CustomDeclineResurrect

	EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_START_SOUL_GEM_RESURRECTION, OnSoulGemResurrectionStart)
	EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_END_SOUL_GEM_RESURRECTION, OnSoulGemResurrectionEnd)
	EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_RESURRECT_RESULT, OnResurrectResult)
	EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_RESURRECT_REQUEST, OnResurrectRequest)
	EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_RESURRECT_REQUEST_REMOVED, OnResurrectRequestRemoved)
	EVENT_MANAGER:RegisterForEvent(LIB_IDENTIFIER, EVENT_EFFECT_CHANGED, OnResurrectTriggerChanged)
	EVENT_MANAGER:AddFilterForEvent(LIB_IDENTIFIER, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, P2P_UNIT_TAG, REGISTER_FILTER_ABILITY_ID, RESURRECT_TRIGGER_ABILITY_ID)

	lib.Unload = Unload
end

if(lib.Unload) then Unload() end
Load()
