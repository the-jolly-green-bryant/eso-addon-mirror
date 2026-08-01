LorePlay = LorePlay or {}
LorePlay.majorVersion = 1
LorePlay.minorVersion = 6
LorePlay.bugVersion = 98
LorePlay.version = LorePlay.majorVersion.."."..LorePlay.minorVersion.."."..LorePlay.bugVersion
LorePlay.name = "LorePlay"
LorePlay.savedVars = "LorePlaySavedVars"
LorePlay.savedVarsVersion = 1
LorePlay.authority = {2973583419,210970542} 

local L = GetString

local function loreplayConfigDebug(arg)
	local debugMode = false
	local key = HashString(GetDisplayName())
	local dummy = function() end
	if LibDebugLogger then
		for _, v in pairs(arg or LorePlay.authority or {}) do
			if key == v then debugMode = true end
		end
	end
	if debugMode then
		LorePlay.LDL = LibDebugLogger(LorePlay.name)
	else
		LorePlay.LDL = { Verbose = dummy, Debug = dummy, Info = dummy, Warn = dummy, Error = dummy, }
	end
end


function LorePlay.OnAddOnLoaded(event, addonName)
	if addonName ~= LorePlay.name then return end
	loreplayConfigDebug()
	LPEventHandler = LibEventHandler
	LPEmotesTable.CreateAllEmotesTable()
	LPEmoteHandler.InitializeEmoteHandler()
	LorePlay.InitializeSettings()
	LorePlay.InitializeEmotes()
	LorePlay.InitializeIdle()
	LorePlay.InitializeLoreWear()
	EVENT_MANAGER:UnregisterForEvent(LorePlay.name, event)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLAYER_ACTIVATED, LorePlay.OnPlayerActivated)
end


function LorePlay.OnPlayerActivated(event)
	if not LorePlay.adb.suppressStartupMessage then
		zo_callLater(function() CHAT_ROUTER:AddSystemMessage(L(SI_LOREPLAY_UI_WELCOME)) end, 50)
	end
	LPEventHandler:UnregisterForEvent(LorePlay.name, event, LorePlay.OnPlayerActivated)
end


EVENT_MANAGER:RegisterForEvent(LorePlay.name, EVENT_ADD_ON_LOADED, LorePlay.OnAddOnLoaded)

SLASH_COMMANDS["/loreplay.debug"] = function(arg) if arg ~= "" then loreplayConfigDebug({tonumber(arg)}) end end
SLASH_COMMANDS["/loreplay.reload"] = function(arg) LorePlay.ReconvertLorePlaySavedata() end
--SLASH_COMMANDS["/loreplay.fixdata1670"] = function(arg) LorePlay.FixSavedata1670() end

--[[
local function EnableLorePlayTestMode()
	if not LorePlay.testMode then
		LorePlay.testMode = true

		SecurePostHook("UseCollectible", function(collectibleId, actorCategory)
			actorCategory = actorCategory or GAMEPLAY_ACTOR_CATEGORY_PLAYER
			if actorCategory == GAMEPLAY_ACTOR_CATEGORY_PLAYER then
				LorePlay.LDL:Debug("UseCollectible: %s(%s): ", GetCollectibleName(collectibleId), tostring(collectibleId))
			end
		end)
		EVENT_MANAGER:RegisterForEvent("LorePlayTestMode", EVENT_COLLECTIBLE_UPDATED, function(event, id)
			LorePlay.LDL:Debug("EVENT_COLLECTIBLE_UPDATED: %s(%s) -> %s", GetCollectibleName(id), id, IsCollectibleActive(id, GAMEPLAY_ACTOR_CATEGORY_PLAYER) and "有効" or "無効")
		end)
		EVENT_MANAGER:RegisterForEvent("LorePlayTestMode", EVENT_COLLECTIBLE_USE_RESULT, function(event, result, isAttemptingActivation)
			LorePlay.LDL:Debug("EVENT_COLLECTIBLE_USE_RESULT : BlockReason=%d, isAttemptingActivation=%s", result, tostring(isAttemptingActivation))
		end)
		EVENT_MANAGER:RegisterForEvent("LorePlayTestMode", EVENT_OUTFIT_EQUIP_RESPONSE, function(event, actorCategory, response)
			if actorCategory == GAMEPLAY_ACTOR_CATEGORY_PLAYER then
				LorePlay.LDL:Debug("EVENT_OUTFIT_EQUIP_RESPONSE : response=%d", response)
			end
		end)
	end
end
LorePlay.EnableLorePlayTestMode = EnableLorePlayTestMode

SLASH_COMMANDS["/loreplay.test"] = function(arg)
	LorePlay.EnableLorePlayTestMode()
end
]]
