-- Settings menu.
function EchoesOfLore.LoadSettings()
    local LAM = LibStub("LibAddonMenu-2.0")

    local panelData = {
        type = "panel",
        name = EchoesOfLore.menuDisplayName,
        displayName = EchoesOfLore.Colorize(EchoesOfLore.menuName),
        author  = EchoesOfLore.Colorize(EchoesOfLore.author, "AAF0BB"),
        version = EchoesOfLore.Colorize(EchoesOfLore.version, "AA00FF"),
        slashCommand = "/EchoesOfLore",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(EchoesOfLore.menuName, panelData)

    local optionsTable = {
        [1] = {
            type = "header",
            name = "",
            width = "full",	--or "half" (optional)
        },
        [2] = {
            type = "header",
            title = nil,	--(optional)
            text = "EchoesOfLore Options",
            name = "EchoesOfLore Options",
            width = "full",	--or "half" (optional)
        }
    }
    LAM:RegisterOptionControls(EchoesOfLore.menuName, optionsTable)
end