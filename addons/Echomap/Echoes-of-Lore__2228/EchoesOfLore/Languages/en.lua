-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
    SI_EOL_MESSAGE_P  = " player is loaded",
    SI_EOL_MESSAGE_A  = " addon is loaded",
    -- Keybindings.
    SI_BINDING_NAME_EOL_DISPLAY  = "Display EchoesOfLore",
    EchoesOfLore_EOL_DISPLAY     = "Display EchoesOfLore",
    EchoesOfLore_EOL_DISPLAY2     = "Display EchoesOfLore",
    SI_EOL_ENTERED_ZONE   = "Entered Zone: <<1>>",
    SI_EOL_IN_ZONE        = "In Zone: <<1>>",
    SI_EOL_REENTERED_ZONE = "Rentered Zone: <<1>>",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end