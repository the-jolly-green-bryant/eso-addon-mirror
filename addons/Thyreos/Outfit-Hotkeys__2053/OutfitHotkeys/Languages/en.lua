-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
    SI_OUTFITHOTKEYS_MENU_MEMENTO_SECTION_DESCRIPTION = "Select a memento to trigger with a given outfit.",
    SI_OUTFITHOTKEYS_MENU_NO_MOMENTO_CHOICE = "-- NONE --",
    SI_OUTFITHOTKEYS_MENU_MEMENTO_UNEQUIP_OUTFIT = "When Unequipping Outfits:",
    SI_OUTFITHOTKEYS_MENU_MEMENTO_OUTFIT01 = "When Equipping Outfit 1:",
    SI_OUTFITHOTKEYS_MENU_MEMENTO_OUTFIT02 = "When Equipping Outfit 2:",
    SI_OUTFITHOTKEYS_MENU_MEMENTO_OUTFIT03 = "When Equipping Outfit 3:",
    SI_OUTFITHOTKEYS_MENU_MEMENTO_OUTFIT04 = "When Equipping Outfit 4:",
    SI_OUTFITHOTKEYS_MENU_MEMENTO_OUTFIT05 = "When Equipping Outfit 5:",
    SI_OUTFITHOTKEYS_MENU_MEMENTO_OUTFIT06 = "When Equipping Outfit 6:",

    -- Keybindings.
    SI_BINDING_NAME_OUTFITHOTKEYS_OUTFIT00 = "Unequip Outfit",
    SI_BINDING_NAME_OUTFITHOTKEYS_OUTFIT01 = "Outfit 1",
    SI_BINDING_NAME_OUTFITHOTKEYS_OUTFIT02 = "Outfit 2",
    SI_BINDING_NAME_OUTFITHOTKEYS_OUTFIT03 = "Outfit 3",
    SI_BINDING_NAME_OUTFITHOTKEYS_OUTFIT04 = "Outfit 4",
    SI_BINDING_NAME_OUTFITHOTKEYS_OUTFIT05 = "Outfit 5",
    SI_BINDING_NAME_OUTFITHOTKEYS_OUTFIT06 = "Outfit 6",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end