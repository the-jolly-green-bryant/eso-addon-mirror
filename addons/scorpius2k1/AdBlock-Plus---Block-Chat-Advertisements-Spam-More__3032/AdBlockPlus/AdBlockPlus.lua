-------------------------
-- Init
-------------------------
local function Initialize()

	--Saved Variables
	AD_BLOCK_PLUS.savedVariables 	= ZO_SavedVars:NewAccountWide("AdBlockPlusSavedVars", AD_BLOCK_PLUS.variableVersion, nil, AD_BLOCK_PLUS.defaults, GetWorldName()) --ZO_SavedVars:New("AdBlockPlusSavedVars", 1, nil, AD_BLOCK_PLUS.defaults)
	AD_BLOCK_PLUS.enable 			= AD_BLOCK_PLUS.savedVariables.enable
	AD_BLOCK_PLUS.notify 			= AD_BLOCK_PLUS.savedVariables.notify
	AD_BLOCK_PLUS.friend 			= AD_BLOCK_PLUS.savedVariables.friend
	AD_BLOCK_PLUS.blocked 			= AD_BLOCK_PLUS.savedVariables.blocked
	AD_BLOCK_PLUS.history 			= AD_BLOCK_PLUS.savedVariables.history
	AD_BLOCK_PLUS.historyIndex 		= AD_BLOCK_PLUS.savedVariables.historyIndex
	AD_BLOCK_PLUS.block 			= AD_BLOCK_PLUS.savedVariables.block
	AD_BLOCK_PLUS.firstrun			= AD_BLOCK_PLUS.savedVariables.firstrun

	--Settings
	AD_BLOCK_PLUS.CreateSettingsWindow()

	--History
	AD_BLOCK_PLUS.IntializeHistory()
	--AD_BLOCK_PLUS.ShowHistoryWindow()

	--Custom Word Table
	AD_BLOCK_PLUS.chatStringsCustom.custom.primary = AD_BLOCK_PLUS.SetCustomWords(AD_BLOCK_PLUS.savedVariables.block.customWords, ";")

	--Friend Status Change
	CHAT_ROUTER:RegisterMessageFormatter(EVENT_FRIEND_PLAYER_STATUS_CHANGED, AD_BLOCK_PLUS.OnFriendPlayerStatusChanged)

	--Chat Pre-Hook
	ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", AD_BLOCK_PLUS.ChatRouter)
end

-------------------------
-- Register
-------------------------
EVENT_MANAGER:RegisterForEvent(
	AD_BLOCK_PLUS.name.."_OnAddonLoaded", EVENT_ADD_ON_LOADED,
	function(_, addOnName)
		if(addOnName ~= AD_BLOCK_PLUS.name) then return end
		Initialize()
		EVENT_MANAGER:UnregisterForEvent(AD_BLOCK_PLUS.name.."_OnAddonLoaded", EVENT_ADD_ON_LOADED)
	end
)

EVENT_MANAGER:RegisterForEvent(
	AD_BLOCK_PLUS.name.."_OnPlayerActivated", EVENT_PLAYER_ACTIVATED,
	function ()
		if not AD_BLOCK_PLUS.firstrun then
			df("|cffffff%s|r", GetString(SI_AD_BLOCK_PLUS_WELCOME_FIRSTRUN))
			df("|cb7ff00/abp|r |cffffff%s|r", GetString(SI_AD_BLOCK_PLUS_DESCRIPTION_HISTORY))
			df("|cb7ff00/abps|r |cffffff%s|r", GetString(SI_AD_BLOCK_PLUS_DESCRIPTION_SETTINGS))
			DoCommand(AD_BLOCK_PLUS.slashCommand.settings)
			AD_BLOCK_PLUS.firstrun = true
			AD_BLOCK_PLUS.savedVariables.firstrun = true			
		end
		EVENT_MANAGER:UnregisterForEvent(AD_BLOCK_PLUS.name.."_OnPlayerActivated", EVENT_PLAYER_ACTIVATED)	
	end
)

SLASH_COMMANDS[AD_BLOCK_PLUS.slashCommand.history] = AD_BLOCK_PLUS.ShowHistoryWindow