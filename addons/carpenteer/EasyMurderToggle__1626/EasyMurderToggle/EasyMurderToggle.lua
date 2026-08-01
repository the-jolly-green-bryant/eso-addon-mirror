EASYMURDERTOGGLE = {}
EASYMURDERTOGGLE.version = 1.0

ZO_CreateStringId("SI_BINDING_NAME_EASYMURDERTOGGLE", "Toggle Murder Innocents")

local function EasyMurderToggle()

	local foo = 1 - GetSetting( SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS )
	
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, foo)
	
	if (foo == 1) then
		CHAT_SYSTEM:AddMessage("\"Prevent Attacking Innocents\" is enabled!")
	else
		CHAT_SYSTEM:AddMessage("\"Prevent Attacking Innocents\" is DISABLED!")
	end
end

SLASH_COMMANDS["/murderer"] = EasyMurderToggle
