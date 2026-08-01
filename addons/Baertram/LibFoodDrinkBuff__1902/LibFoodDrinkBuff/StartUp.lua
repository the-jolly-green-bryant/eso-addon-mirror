local lib =
{
	data = { },
	collector = { },
	chat = { },
	eventList = { },
	version = 0,
	savedVarsName = "LibFoodDrinkBuff_Save",
	async = LibAsync, -- can be nil
}

local libIdentifier = LFDB_LIB_IDENTIFIER

-- Chat
if LibChatMessage ~= nil then
	lib.chat = LibChatMessage(libIdentifier, LFDB_LIB_IDENTIFIER_SHORT)
end
if not lib.chat.Print then
	function lib.chat:Print(message)
		CHAT_ROUTER:AddDebugMessage(ZO_CachedStrFormat(SI_CONVERSATION_OPTION_SPEECHCRAFT_FORMAT, libIdentifier, message))
	end
end

-- Debug
if LibDebugLogger ~= nil then
	local logger = LibDebugLogger(libIdentifier)
	lib.logger = function(...)
		logger:Debug(...)
	end
else
	lib.logger = function(...)
		lib.chat:Print(...)
	end
end

-- Version
local function GetAddonVersion()
	-- Reads the addon version from the addon's txt manifest file tag ##AddOnVersion
	local AddOnManager = GetAddOnManager()
	local numAddOns = AddOnManager:GetNumAddOns()
	for i = 1, numAddOns do
		if AddOnManager:GetAddOnInfo(i) == libIdentifier then
			return AddOnManager:GetAddOnVersion(i)
		end
	end
end
lib.version = GetAddonVersion()

-- Supported Languages
lib.LANGUAGES_SUPPORTED = ZO_CreateSetFromArguments(LFDB_LANGUAGE_ENGLISH, LFDB_LANGUAGE_GERMAN, LFDB_LANGUAGE_FRENCH)

local language = GetCVar("language.2")
lib.clientLanguage = lib.LANGUAGES_SUPPORTED[language] and language or LFDB_LANGUAGE_ENGLISH

-- Global pointers
LIB_FOOD_DRINK_BUFF = lib
LibFoodDrinkBuff 	= lib
