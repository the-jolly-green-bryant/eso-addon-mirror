local LAM 						= LibAddonMenu2

GUILD_AD_BLOCK 					= {}
GUILD_AD_BLOCK.name 			= "GuildAdBlock"
GUILD_AD_BLOCK.version 			= "1.1"
GUILD_AD_BLOCK.filteredCount	= 0
GUILD_AD_BLOCK.playerName		= GetDisplayName()
GUILD_AD_BLOCK.savedVariables	= nil
GUILD_AD_BLOCK.defaults 		= {
	Enable			= true,
	Notify			= true,
}

-------------------------
-- Init
-------------------------
function GUILD_AD_BLOCK:Initialize()
	--Settings
	GUILD_AD_BLOCK.CreateSettingsWindow()

	--Saved Variables
	GUILD_AD_BLOCK.savedVariables 	= ZO_SavedVars:New("GuildAdBlockSavedVars", 1, nil, GUILD_AD_BLOCK.defaults)
	GUILD_AD_BLOCK.Enable 			= GUILD_AD_BLOCK.savedVariables.Enable
	GUILD_AD_BLOCK.Notify 			= GUILD_AD_BLOCK.savedVariables.Notify

	--Chat Pre-Hook
	ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", GUILD_AD_BLOCK.ChatRouter)

	EVENT_MANAGER:UnregisterForEvent(GUILD_AD_BLOCK.name, EVENT_ADD_ON_LOADED)
end

-------------------------
-- Functions
-------------------------
function GUILD_AD_BLOCK.Print(message, ...)
	df("|cb7ff00[%s]|r |cffffff%s|r", GUILD_AD_BLOCK.name, message:format(...))
end

local function slashCommand()
	GUILD_AD_BLOCK.Print("Blocked %i Advertisements Total!", GUILD_AD_BLOCK.filteredCount)
end

local function isSelfMessage(fromDisplayName)
	return GUILD_AD_BLOCK.playerName == fromDisplayName
end

function GUILD_AD_BLOCK.ChatRouter(self, eventKey, ...)
	if eventKey == EVENT_CHAT_MESSAGE_CHANNEL and GUILD_AD_BLOCK.Enable then
		local messageType, _, rawMessageText, _, fromDisplayName = select(1, ...)
		if zo_strfind(rawMessageText, "|H1:guild:") and messageType == CHAT_CHANNEL_ZONE and not isSelfMessage(fromDisplayName) then
			if GUILD_AD_BLOCK.Notify then
				GUILD_AD_BLOCK.Print("Blocked Advertisement!")
			end
			GUILD_AD_BLOCK.filteredCount = GUILD_AD_BLOCK.filteredCount + 1
			return true
		end
	end

	return false
end	

-------------------------
-- Settings Window
-------------------------
function GUILD_AD_BLOCK.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Guild AdBlock",
		displayName = "Scorps Guild AdBlock",
		author = "Scorp",
		version = GUILD_AD_BLOCK.version,
		slashCommand = "",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local cntrlOptionsPanel = LAM:RegisterAddonPanel("GUILD_AD_BLOCK_Settings", panelData)
	
	local optionsData = {
		{
			type = "checkbox",
			name = GetString(SI_GUILD_AD_BLOCK_ENABLE),
			tooltip = GetString(SI_GUILD_AD_BLOCK_ENABLE_TT),
			default = true,
			getFunc = function() return GUILD_AD_BLOCK.savedVariables.Enable end,
			setFunc = function(newValue) 
				GUILD_AD_BLOCK.savedVariables.Enable = newValue
				GUILD_AD_BLOCK.Enable = newValue
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_GUILD_AD_BLOCK_NOTIFY),
			tooltip = GetString(SI_GUILD_AD_BLOCK_NOTIFY_TT),
			default = true,
			getFunc = function() return GUILD_AD_BLOCK.savedVariables.Notify end,
			setFunc = function(newValue) 
				GUILD_AD_BLOCK.savedVariables.Notify = newValue
				GUILD_AD_BLOCK.Notify = newValue
			end,
		},		
	}
	
	LAM:RegisterOptionControls("GUILD_AD_BLOCK_Settings", optionsData)
end

-------------------------
-- Register
-------------------------
EVENT_MANAGER:RegisterForEvent(
	GUILD_AD_BLOCK.name, EVENT_ADD_ON_LOADED,
	function(_, addOnName)
		if(addOnName ~= GUILD_AD_BLOCK.name) then return end
		GUILD_AD_BLOCK:Initialize()
	end
)

SLASH_COMMANDS["/gab"] = slashCommand