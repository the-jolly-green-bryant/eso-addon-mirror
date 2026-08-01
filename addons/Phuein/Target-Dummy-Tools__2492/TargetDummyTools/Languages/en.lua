-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
    -- Keybindings.
    SI_BINDING_NAME_TARGETDUMMYTOOLS_RESETDUMMY = "Reset Dummy",
    SI_BINDING_NAME_TARGETDUMMYTOOLS_RESETALLDUMMIES = "Reset All Dummies",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end