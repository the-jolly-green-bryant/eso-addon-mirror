function SyliranasNewLifeTravel.DefaultSettings()
	if SyliranasNewLifeTravel.savedVars.automaticTraveling == nil then
		SyliranasNewLifeTravel.savedVars.automaticTraveling = true
	end
	if SyliranasNewLifeTravel.savedVars.chatOutput == nil then
		SyliranasNewLifeTravel.savedVars.chatOutput = false
	end
	if SyliranasNewLifeTravel.savedVars.warOrphanWayshrine == nil then
		SyliranasNewLifeTravel.savedVars.warOrphanWayshrine = 21
	end
	if SyliranasNewLifeTravel.savedVars.signalFireWayshrine == nil then
		SyliranasNewLifeTravel.savedVars.signalFireWayshrine = 44
	end
end

function SyliranasNewLifeTravel.LoadSettings()
	SyliranasNewLifeTravel.DefaultSettings()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = SyliranasNewLifeTravel.menuName,
        displayName = SyliranasNewLifeTravel.Colorize(SyliranasNewLifeTravel.menuName),
        author = SyliranasNewLifeTravel.Colorize(SyliranasNewLifeTravel.author, "3366FF"),
        slashCommand = "/snlt",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(SyliranasNewLifeTravel.menuName, panelData)
    local optionsTable = {}
    table.insert(
        optionsTable,
        {
            type = "checkbox",
            name = "Automatic Fast Travel",
            tooltip = "Automatically fast travel to the nearest Wayshrine for your current new life quest step when accessing a wayshrine.",
            getFunc = function()
                return SyliranasNewLifeTravel.savedVars.automaticTraveling
            end,
            setFunc = function(v)
                SyliranasNewLifeTravel.savedVars.automaticTraveling = v
            end,
            width = "full",
            default = true
        }
    )
    table.insert(
        optionsTable,
        {
            type = "checkbox",
            name = "Chat Messages",
            tooltip = "Display chat messages when fast traveling.",
            disabled = function()
                return not SyliranasNewLifeTravel.savedVars.automaticTraveling
            end,
            getFunc = function()
                return SyliranasNewLifeTravel.savedVars.chatOutput
            end,
            setFunc = function(v)
                SyliranasNewLifeTravel.savedVars.chatOutput = v
            end,
            width = "full",
            default = false
        }
	)
    table.insert(
        optionsTable,
        {
            type = "dropdown",
            name = "Wayshrine for The War Orphan's Soujourn",
            tooltip = "Some players prefer to use different wayshrines for The War Orphan's Soujourn. Here you can select which one you'd like the addon to use.",
			choices = {
				"Elden Root",
				"Elden Root Temple",
				"Gil-Var-Delle"
			},
			choicesValues = {
				214,
				21,
				164
			},
            disabled = function()
                return not SyliranasNewLifeTravel.savedVars.automaticTraveling
            end,
            getFunc = function()
                return SyliranasNewLifeTravel.savedVars.warOrphanWayshrine
            end,
            setFunc = function(v)
                SyliranasNewLifeTravel.savedVars.warOrphanWayshrine = v
            end,
            width = "full",
            default = 21
        }
    )
    table.insert(
        optionsTable,
        {
            type = "dropdown",
            name = "Wayshrine for Signal Fire Sprint",
            tooltip = "Some players prefer to use different wayshrines for Signal Fire Sprint. Here you can select which one you'd like the addon to use.",
			choices = {
				"Bergama",
				"Divad's Chagrin Mine"
			},
			choicesValues = {
				44,
				57
			},
            disabled = function()
                return not SyliranasNewLifeTravel.savedVars.automaticTraveling
            end,
            getFunc = function()
                return SyliranasNewLifeTravel.savedVars.signalFireWayshrine
            end,
            setFunc = function(v)
                SyliranasNewLifeTravel.savedVars.signalFireWayshrine = v
            end,
            width = "full",
            default = 44
        }
    )
    table.insert(
        optionsTable,
        {
            type = "divider",
			width = "full"
        }
    )
    table.insert(
        optionsTable,
        {
            type = "description",
			text = "Hey, Sylirana here! o/\nThis is my first addon for ESO. If you have feedback or comments, send me a message on PC-EU or leave a comment on this addon's ESOUI page.\nIf this addons helps you, please consider donating.\nI wish you a happy New Life Festival, don't forget your XP boost memento and may the RNG be on your side! :3"
        }
    )
    table.insert(
        optionsTable,
        {
            type = "divider",
			width = "full"
        }
    )
    table.insert(
        optionsTable,
        {
            type = "description",
			text = "This addon is based on Red's Countess Travel by redeven, go check it out as well!"
        }
    )
    LAM:RegisterOptionControls(SyliranasNewLifeTravel.menuName, optionsTable)
end