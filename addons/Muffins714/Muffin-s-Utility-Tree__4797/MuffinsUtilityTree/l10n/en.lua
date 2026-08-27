local strings = {
    -- MUT Menu
    MUT_HEADER_RELOAD_UI               = "RELOAD UI SETTINGS",
    MUT_HEADER_MULTI_SPLITTER          = "MULTI SPLITTER SETTING",
    MUT_HEADER_QUALITY_SORTER          = "QUALITY SORTER SETTING",

    -- Reload UI
    MUT_RELOAD_UI                      = "Reload UI Button",
    MUT_RELOAD_UI_TOOLTIP              = "Add a Reload UI Button for Gamepad",
    MUT_RELOAD_UI_BIND                 = "Pick your button",
    MUT_RELOAD_UI_BIND_TOOLTIP         = "This is used to bypass the keybind limit",
    MUT_RELOAD_UI_SCENE                = "Scene list",
    MUT_RELOAD_UI_SCENE_TOOLTIP        = "Pick where you want the button to show",

    -- Multi Splitter
    MUT_MULTI_SPLITTER_ENABLED         = "Use Multi Splitter?",

    -- Multi Split action + dialog
    MUT_MULTI_SPLITTER_ACTION_NAME     = "Multi Split",
    MUT_MULTI_SPLITTER_TITLE           = "Multi Split",
    MUT_MULTI_SPLITTER_PROMPT          = "Choose the size of each new stack",
    MUT_MULTI_SPLITTER_ERROR           = "Multi Split: only %d free slots available, need %d, splitting what can fit.",

    -- Quality Sorter
    MUT_QUALITY_SORTER_ENABLED         = "Sort Craft Bag by Quality?",
    MUT_QUALITY_SORTER_ENABLED_TOOLTIP =
    "Adds a button to Craft Bag. Cycle sorting by item quality (Highest first / Lowest first / default order).",

    -- Quality Sorter keybind (cycles: default -> high-to-low -> low-to-high -> default)
    MUT_QUALITY_SORTER_KEYBIND_OFF     = "Sort by Quality",
    MUT_QUALITY_SORTER_KEYBIND_DESC    = "Sort: Highest First",
    MUT_QUALITY_SORTER_KEYBIND_ASC     = "Sort: Lowest First",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
