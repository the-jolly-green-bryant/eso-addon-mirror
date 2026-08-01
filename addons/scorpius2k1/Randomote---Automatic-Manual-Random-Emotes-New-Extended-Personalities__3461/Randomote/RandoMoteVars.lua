RANDOMOTE                   = {}
RANDOMOTE.name              = "RandoMote"
RANDOMOTE.version           = "1.3"
RANDOMOTE.playerName        = GetDisplayName()
RANDOMOTE.variableVersion   = 1
RANDOMOTE.savedVariables    = {}
RANDOMOTE.language 			= GetCVar("language.2")
RANDOMOTE.languageSupport 	= { "en", "de", "fr", "ru"}
RANDOMOTE.delayID			= {}
RANDOMOTE.emoteData			= {}
RANDOMOTE.idleCount    		= 0
RANDOMOTE.delayCount    	= 0
RANDOMOTE.delayMax		   	= 0
RANDOMOTE.idleMax     		= 0
RANDOMOTE.inEmote			= false
RANDOMOTE.isFastTraveling 	= false
RANDOMOTE.useStandard		= true
RANDOMOTE.useCollectible	= true
RANDOMOTE.chatOutput		= false
RANDOMOTE.maxTime			= 0
RANDOMOTE.minTime			= 0
RANDOMOTE.enable            = true
RANDOMOTE.useEmote			= {}
RANDOMOTE.defaults = {
	enable          = true,
	useStandard		= true,
	useCollectible	= true,
	chatOutput		= false,
	idleMax         = 15,
	maxTime 		= 30,
	minTime         = 10,
	useEmote		= {}
}
RANDOMOTE.slashCommand = {
	emote			= "/rm",
	settings		= "/randomote",
	list			= "/randomotelist",
}

local function isLanguageSupported()
	for _, lang in pairs(RANDOMOTE.languageSupport) do
		if RANDOMOTE.language == lang then return true end
	end
	return false
end

if not isLanguageSupported() then RANDOMOTE.language = "en" end

--/script SetCVar("language.2", "en")