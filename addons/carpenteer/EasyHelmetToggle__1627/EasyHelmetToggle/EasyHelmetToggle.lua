EASYHELMETTOGGLE = {}
EASYHELMETTOGGLE.version = 1.0

ZO_CreateStringId("SI_BINDING_NAME_EASYHELMETTOGGLE", "Toggle Helmet Visibility")

local function EasyHelmetToggle()

	local foo = 1 - GetSetting( SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM )
	SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, foo)
end

SLASH_COMMANDS["/helm"] = EasyHelmetToggle