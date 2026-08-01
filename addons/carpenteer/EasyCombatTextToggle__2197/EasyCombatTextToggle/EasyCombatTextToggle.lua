EASYCOMBATTEXTTOGGLE = {}
EASYCOMBATTEXTTOGGLE.version = 1.0

ZO_CreateStringId("SI_BINDING_NAME_EASYCOMBATTEXTTOGGLE", "Toggle Scrolling Combat Text")

local function EasyCombatTextToggle()

	local foo = 1 - GetSetting( SETTING_TYPE_COMBAT, COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED )
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED, foo)
	
	if (foo == 1) then
		CHAT_SYSTEM:AddMessage("Floating Combat Text is enabled!")
	else
		CHAT_SYSTEM:AddMessage("Floating Combat Text is DISABLED!")
	end

end

SLASH_COMMANDS["/ecct"] = EasyCombatTextToggle