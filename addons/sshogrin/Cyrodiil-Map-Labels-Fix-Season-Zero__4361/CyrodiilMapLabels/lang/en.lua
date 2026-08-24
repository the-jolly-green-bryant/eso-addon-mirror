-- English

local localization_strings = {
    title = "|c2046e5Cyrodiil Map Labels|r",
    nameDropdown = "Select Map Names",
    descDropdown = "Choose which labels to show on the Cyrodiil map.",
    choiceLong = "Long Names",
    choiceShort = "Short Names",
    nameCheckbox = "Use Faction Alliance Colors",
    descCheckbox = "Toggle to display text names color-coded to the owning alliance (AD=Yellow, DC=Blue, EP=Red) instead of your custom color.",
    nameColor = "Custom Label Color",
    descColor = "Choose your custom text color for the map labels used when alliance tracking is disabled.",
    nameSlider = "Label Font Size Scale",
    descSlider = "Slide to adjust the text magnification size factor scaling maps globally.",
}

for key, strValue in pairs(localization_strings) do
    local stringIdName = "SI_CYRODIILMAPLABELS_" .. key
    _G[stringIdName] = stringIdName
    ZO_CreateStringId(stringIdName, strValue)
end

