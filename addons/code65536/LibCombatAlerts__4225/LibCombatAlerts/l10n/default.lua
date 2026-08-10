local Register = LibCodesCommonCode.RegisterString
local Localize = LibCodesCommonCode.GetLocalizedData

Register("SI_LCA_INCOMING"				, zo_strformat("<<C:1>>", GetString(SI_INTERFACE_OPTIONS_COMBAT_SCT_INCOMING_ENABLED)))
Register("SI_LCA_ACTIVE"				, zo_strformat("<<C:1>>", GetString(SI_MARKET_SUBSCRIPTION_PAGE_SUBSCRIPTION_STATUS_ACTIVE)))
Register("SI_LCA_SUCCESS"				, zo_strformat("<<C:1>>", GetString("SI_UPDATEGUILDMETADATARESPONSE", UPDATE_GUILD_META_DATA_SUCCESS)))
Register("SI_LCA_FAIL"					, zo_strformat("<<C:1>>", GetString("SI_UPDATEGUILDMETADATARESPONSE", UPDATE_GUILD_META_DATA_FAIL)))

Register("SI_LCA_CW"					, "Clockwise")
Register("SI_LCA_CCW"					, "Counter-Clockwise")

Register("SI_LCA_TIME_REMAINING"		, "<<1>> remaining")
Register("SI_LCA_TIME_SINCE_PREVIOUS"	, "<<1>> since previous")

Register("SI_LCA_COLOR_BG"				, "Background color")
Register("SI_LCA_COLOR_FG"				, "Foreground color")
Register("SI_LCA_LEFT"					, "Left")
Register("SI_LCA_TOP"					, "Top")

SI_LCA_BLOCK							= SI_BINDING_NAME_SPECIAL_MOVE_BLOCK
SI_LCA_INTERRUPT						= SI_BINDING_NAME_SPECIAL_MOVE_INTERRUPT
SI_LCA_ROLL_DODGE						= SI_BINDING_NAME_ROLL_DODGE
SI_LCA_COLOR							= SI_GUILD_HERALDRY_COLOR

-- Adapted from SI_GUILD_KEEP_ATTACK_UPDATE
Register("SI_LCA_PLAYERS_COUNT"			, Localize({ default = "<<1>> <<1[player/players]>>", de = "<<1>> <<1[Spieler/Spielern]>>", es = "<<1>> <<1[jugador/jugadores]>>", fr = "<<1>> <<1[joueur/joueurs]>>", jp = "<<1>> プレイヤー", ru = "<<1>> <<1[игрок/игрока/игроков]>>", zh = "<<1>> 位玩家" }))
