function CountessTravel.LoadSettings()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = CountessTravel.menuName,
        displayName = CountessTravel.Colorize(CountessTravel.menuName),
        author = CountessTravel.Colorize(CountessTravel.author, "FF0000"),
        slashCommand = "/rct",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(CountessTravel.menuName, panelData)
    local optionsTable = {}
    table.insert(
        optionsTable,
        {
            type = "checkbox",
            name = "Tip Board Filter",
            tooltip = "Prevent accepting Tip Board quests that aren't 'The Covetous Countess'",
            getFunc = function()
                return CountessTravel.savedVars.questFiltering
            end,
            setFunc = function(v)
                CountessTravel.savedVars.questFiltering = v
            end,
            width = "full",
            default = true,
        }
    )
    table.insert(
        optionsTable,
        {
            type = "checkbox",
            name = "Automatic Fast Travel",
            tooltip = "Automatically fast travel to the nearest Wayshrine for your current quest step",
            getFunc = function()
                return CountessTravel.savedVars.automaticTraveling
            end,
            setFunc = function(v)
                CountessTravel.savedVars.automaticTraveling = v
            end,
            width = "full",
            default = true,
        }
    )
    table.insert(
        optionsTable,
        {
            type = "checkbox",
            name = "Chat Messages",
            tooltip = "Display chat messages when fast traveling",
            disabled = function()
                return not CountessTravel.savedVars.automaticTraveling
            end,
            getFunc = function()
                return CountessTravel.savedVars.chatOutput
            end,
            setFunc = function(v)
                CountessTravel.savedVars.chatOutput = v
            end,
            width = "full",
            default = false,
        }
    )
    LAM:RegisterOptionControls(CountessTravel.menuName, optionsTable)
end