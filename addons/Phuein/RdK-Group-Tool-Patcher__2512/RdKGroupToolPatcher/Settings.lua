-- Settings menu.
function RdKGroupToolPatcher.LoadSettings()
    local LAM = LibStub("LibAddonMenu-2.0")

    local panelData = {
        type = "panel",
        name = RdKGroupToolPatcher.menuName,
        displayName = RdKGroupToolPatcher.Colorize(RdKGroupToolPatcher.menuName),
        author = RdKGroupToolPatcher.Colorize(RdKGroupToolPatcher.author, "AAF0BB"),
        -- version = RdKGroupToolPatcher.Colorize(RdKGroupToolPatcher.version, "AA00FF"),
        -- slashCommand = "/RdKGroupToolPatcher",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(RdKGroupToolPatcher.menuName, panelData)

    local optionsTable = {}

    table.insert(optionsTable, {
        type = "editbox",
        name = "Secondary Crowns",
        getFunc = RdKGroupToolPatcher.GetSecondaryCrowns,
        setFunc = RdKGroupToolPatcher.SetSecondaryCrowns,
        isMultiline = false,
        width = "full",
        default = "",
        tooltip = "Give group leadership on death, by order. Example: @bob, @mike, @jim",
    })

    LAM:RegisterOptionControls(RdKGroupToolPatcher.menuName, optionsTable)
end