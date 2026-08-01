-------------------------------------------------------------------------------------------------------------------------------------------------
-- Base of CODE => Bandits User Interface by Hoft 
-------------------------------------------------------------------------------------------------------------------------------------------------

DsR	={
    name		        	= "DsRGuildRoster",
	DisplayName	        	= "|c00CDCDDsR |cFEFEFEGuildRoster|r",
	ShortName	        	= "|c00CDCDDsR|r GuildRoster",
	URL			        	= "https://www.esoui.com/downloads/info3776-DsRGuildRoster.html",
	Version					= 0,
	language				= tostring(GetCVar("language.2")),
	API						= GetAPIVersion(),
	GamepadMode				= IsInGamepadPreferredMode(),
	ESOVersion				= string.match(GetESOVersionString(), "eso.([%w%-]+.[%w%-]+.[%w%-]+.[%w%-])"),
	Menu					= {},
	Frame					= {},

	init={
		Menu				= false,
		inMenu				= false,
	},
	Localization = {},
	Loc	= function(var) return DsR.Localization[DsR.language] and DsR.Localization[DsR.language][var] or DsR.Localization.en[var] or var end
}
