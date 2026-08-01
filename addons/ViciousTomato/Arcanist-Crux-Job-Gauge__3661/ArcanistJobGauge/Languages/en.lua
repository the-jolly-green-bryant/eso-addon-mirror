-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
    -- Keybindings.
    SI_BINDING_NAME_ARCANISTJOBGAUGE_DISPLAY = "Display the ArcanistJobGauge",
}

for stringId, stringValue in pairs(localization_strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
