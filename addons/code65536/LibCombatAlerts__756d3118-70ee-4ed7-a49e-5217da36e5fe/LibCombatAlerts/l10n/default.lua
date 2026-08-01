local Register = LibCodesCommonCode.RegisterString

SI_LCA_BLOCK      = SI_BINDING_NAME_SPECIAL_MOVE_BLOCK
SI_LCA_INTERRUPT  = SI_BINDING_NAME_SPECIAL_MOVE_INTERRUPT
SI_LCA_ROLL_DODGE = SI_BINDING_NAME_ROLL_DODGE

Register("SI_LCA_INCOMING" , zo_strformat("<<C:1>>", GetString(SI_INTERFACE_OPTIONS_COMBAT_SCT_INCOMING_ENABLED)))
Register("SI_LCA_ACTIVE"   , zo_strformat("<<C:1>>", GetString(SI_MARKET_SUBSCRIPTION_PAGE_SUBSCRIPTION_STATUS_ACTIVE)))
Register("SI_LCA_SUCCESS"  , zo_strformat("<<C:1>>", GetString("SI_UPDATEGUILDMETADATARESPONSE", UPDATE_GUILD_META_DATA_SUCCESS)))
Register("SI_LCA_FAIL"     , zo_strformat("<<C:1>>", GetString("SI_UPDATEGUILDMETADATARESPONSE", UPDATE_GUILD_META_DATA_FAIL)))

Register("SI_LCA_CW"       , "Clockwise")
Register("SI_LCA_CCW"      , "Counter-Clockwise")

SI_LCA_COLOR = SI_GUILD_HERALDRY_COLOR
Register("SI_LCA_COLOR_BG" , "Background color")
Register("SI_LCA_COLOR_FG" , "Foreground color")
Register("SI_LCA_LEFT"     , "Left")
Register("SI_LCA_TOP"      , "Top")
