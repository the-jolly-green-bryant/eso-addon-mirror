SIMPLEHELMETTOGGLE = {}
SIMPLEHELMETTOGGLE.version = 0.4 --d

    ZO_CreateStringId("SI_BINDING_NAME_SIMPLEHELMETTOGGLE", "SimpleHelmetToggle")

local function SimpleHelmetToggle()

	local before = GetSetting( SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM )
	SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, 1 - before)
end

ZO_PreHookHandler(ZO_CharacterEquipmentSlotsHead, "OnMouseUp",
        function(self, button, upInside)
            if upInside and button == 1 then
                SimpleHelmetToggle()
            end
        end)

SLASH_COMMANDS["/helmet"] = SimpleHelmetToggle
SLASH_COMMANDS["/helm"] = SimpleHelmetToggle