local strings = {

	WMWC_TAMRIEL 				= "Hide everything on Tamriel map",
	WMWC_TAMRIEL_TOOLTIP 		= "Don't show any icons on Tamriel map",
	
	WMWC_WAYSHRINES 			= "Hide wayshrines on Tamriel map",
	WMWC_WAYSHRINES_TOOLTIP 	= "Choose the behavior of Tamriel map for discovered Wayshrines",

	WMWC_DUNGEONS 				= "Hide dungeons on Tamriel map",
	WMWC_DUNGEONS_TOOLTIP 		= "Choose the behavior of Tamriel map for discovered Dungeons",
	
	WMWC_TRIALS 				= "Hide trials on Tamriel map",
	WMWC_TRIALS_TOOLTIP 		= "Choose the behavior of Tamriel map for discovered Trials",

	WMWC_UNOWNED_HOUSES 		= "Hide unowned Houses",
	WMWC_UNOWNED_HOUSES_TOOLTIP = "Choose the behavior of maps for unowned Houses",

	WMWC_OWNED_HOUSES 			= "Hide owned Houses",
	WMWC_OWNED_HOUSES_TOOLTIP 	= "Choose the behavior of maps for owned Houses",
	
	WMWC_WAYSHRINE_OPTION_0 	= "OFF",
	WMWC_WAYSHRINE_OPTION_1 	= "ON, except capitals",
	WMWC_WAYSHRINE_OPTION_2		= "ON",

	WMWC_HOUSES_OPTION_0 		= "OFF",
	WMWC_HOUSES_OPTION_1 		= "ON, except on zone map",
	WMWC_HOUSES_OPTION_2 		= "ON",	
	
	WMWC_OVERWRITE 				= "Overwrite Show/Hide",
	
	WMWC_ARENA					= "Arena: ",	
	WMWC_SHOW					= "Show",
	WMWC_HIDE					= "Hide",
	WMWC_WSHonWM				= "Wayshrines on Tamriel map",
	WMWC_DTAonWM				= "Dungeons, Trials & Arenas on Tamriel map",
	WMWC_HonWZM					= "Houses on Tamriel and Zone map",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end