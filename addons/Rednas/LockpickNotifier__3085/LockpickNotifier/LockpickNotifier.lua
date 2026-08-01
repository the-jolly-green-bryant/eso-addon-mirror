LPN = LPN or {}

LPN.name = "LockpickNotifier"
LPN.author = "Rednas"
LPN.version = "1.6"
LPN.LastLockpick = nil
LPN.VariableVersion = 2
LPN.savedVars = {}
LPN.savedVarsDefaults = {
	["messageText"] = "Chest found, quality: %s",
	["activeInGroupDungeons"] = true,
	["activeInTrials"] = false,
	["chestDifficultyName"] = {[1] = "Simple", [2] = "Intermediate", [3] = "Advanced", [4] = "Master"}
}
LPN.trialZoneNames = {
	[1] = "Hel Ra Citadel", --
	[2] = "Aetherian Archive", --
	[3] = "Sanctum Ophidia", --
	[4] = "Dragonstar Arena", --No group or chests, but to complete the list from the leaderboards
	[5] = "Maw of Lorkhaj", --
	[6] = "Halls of Fabrication", --
	[7] = "Asylum Sanctorium", --No chests just for completion sake
	[8] = "Cloudrest", --No chests just for completion sake
	[9] = "Blackrose Prison", --No group or chests, but to complete the list from the leaderboards
	[10] = "Sunspire", --
	[11] = "Kyne's Aegis", --
	[12] = "Rockgrove", --
	[13] = "Dreadsail Reef", --
	[14] = "Sanity's Edge", --
}

LPN.ChestNames = {
 ["en"] = "Chest",
 ["de"] = "Truhe",
 ["fr"] = "Coffre",
 ["ru"] = "Сундук",
 ["jp"] = "宝箱",
}
LPN.ChestName = ""

local interactionData = {}

SecurePostHook(FISHING_MANAGER or INTERACTIVE_WHEEL_MANAGER, "StartInteraction", function(...)
		interactionData = {}
		interactionData.action, interactionData.name, interactionData.blockedNode, interactionData.isOwned = GetGameCameraInteractableActionInfo()
	end
)

function LPN.IsPlayerInTrialZone()
	--check trials based on zone name, since IsPlayerInRaid() doesn't work for normal trials
	local currentZone = GetPlayerActiveZoneName()
	for i, trialZone in ipairs(LPN.trialZoneNames) do
		if trialZone == currentZone then return true end
	end
	return false
end

function LPN.CheckEnabled()
	if not IsUnitInDungeon("player") then return false end --Only need to continue when you are in a dungeon
	if GetCurrentZoneDungeonDifficulty() == 0 then return false end --When you are in a delve or group dungeon, return
	
	--IF you are here, you are in a dungeon or trial.
	local IsPlayerInTrialZone = LPN.IsPlayerInTrialZone()
	if IsPlayerInTrialZone and not LPN.savedVars.activeInTrials then 
		return false
	elseif not IsPlayerInTrialZone and not LPN.savedVars.activeInGroupDungeons then 
		return false
	end
	
	return true
end

function LPN.StartLockpick(event)
	
	if LPN.CheckEnabled() == false then return end
	
	if interactionData.name ~= LPN.ChestName then --Check if its a chest, not a door or something!
		interactionData = {}
		return
	end
	
	if LPN.LastLockpick ~= nil then
		exp_sec = LPN.LastLockpick + 90 --90 second CD when lockpicking.. or else it would happen even after breaking a lockpick.
	end

	if LPN.LastLockpick == nil or exp_sec <= os.time() then --If outside of the timer
		LockQuality = GetLockQuality()
		local messageTextFormatted = string.format(LPN.savedVars.messageText, LPN.savedVars.chestDifficultyName[LockQuality])
		
		
		CHAT_SYSTEM:StartTextEntry(messageTextFormatted, CHAT_CHANNEL_PARTY)
		
		LPN.LastLockpick = os.time() --Set CD timer
	end
end

function LPN.LockpickSuccess(event)
	if LPN.LastLockpick ~= nil then
		LPN.LastLockpick = nil	
	end
end

--------------------------------------------------------------------------------------

function LPN.loadSavedVars()
	LPN.savedVars = ZO_SavedVars:NewAccountWide("LPNSavedVars", LPN.VariableVersion, nil, LPN.savedVarsDefaults, GetWorldName())

end

function LPN:Initialize()
	local clientLang = GetCVar("language.2")
	LPN.ChestName = LPN.ChestNames[clientLang] or ""
	
	LPN.loadSavedVars()
	LPN.SetupMenu()
	
	EVENT_MANAGER:RegisterForEvent(LPN.name, EVENT_BEGIN_LOCKPICK, LPN.StartLockpick)
	EVENT_MANAGER:RegisterForEvent(LPN.name, EVENT_LOCKPICK_SUCCESS, LPN.LockpickSuccess)
end
 

function LPN.OnAddOnLoaded(event, addonName)
  if addonName == LPN.name then
    EVENT_MANAGER:UnregisterForEvent(LPN.name, EVENT_ADD_ON_LOADED)
    LPN:Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(LPN.name, EVENT_ADD_ON_LOADED, LPN.OnAddOnLoaded)