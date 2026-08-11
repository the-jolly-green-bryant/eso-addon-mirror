GroupMementos = GroupMementos or {}
local GroupMementos = GroupMementos

function GroupMementos.CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Group Mementos",
        displayName = "Group Mementos",
        author = "|cFF0000P|cFFA500v|cFFFF00P|c00FF00e|c0000FFn|c4B0082n|c800080y|r",
        version = GroupMementos.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = "Show tally panel",
            tooltip = "Show the on-screen panel listing current group members and their memento usage counts. Can also be toggled with |c88FF88/gm|r",
            default = true,
            getFunc = function() return GroupMementos.savedOptions.showPanel end,
            setFunc = function(value)
                GroupMementos.savedOptions.showPanel = value
                GroupMementos.UpdateDisplay()
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Sort tally by",
            tooltip = "Order group members alphabetically by name, or by their highest overall total (summed across tracked mementos) first.",
            choices = { "Name", "Highest Total" },
            choicesValues = { "name", "total" },
            default = "name",
            getFunc = function() return GroupMementos.savedOptions.sortBy end,
            setFunc = function(value)
                GroupMementos.savedOptions.sortBy = value
                GroupMementos.UpdateDisplay()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Lock tally window position",
            tooltip = "Prevent the tally window from being dragged around, so it can't be moved by accident.",
            default = false,
            getFunc = function() return GroupMementos.savedOptions.locked end,
            setFunc = function(value)
                GroupMementos.savedOptions.locked = value
                GroupMementos.ApplyLockState()
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Reset window position",
            tooltip = "Moves the tally window back to its default position, in case it's been dragged off-screen or a resolution change moved it out of view.",
            func = function() GroupMementos.ResetWindowPosition() end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show chat message",
            tooltip = "Announce in chat each time a group member uses a tracked memento. Can also be toggled with |c88FF88/gm chat|r",
            default = true,
            getFunc = function() return GroupMementos.savedOptions.chat end,
            setFunc = function(value) GroupMementos.savedOptions.chat = value end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Leaderboard chat channel",
            tooltip = "Which chat channel |c88FF88/gm leader|r pre-fills the leaderboard message into.",
            choices = { "Group", "Guild", "Say" },
            choicesValues = { "party", "guild", "say" },
            default = "party",
            getFunc = function() return GroupMementos.savedOptions.leaderboardChannel end,
            setFunc = function(value) GroupMementos.savedOptions.leaderboardChannel = value end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Group member display name",
            tooltip = "Show each group member by their character name, or by their ESO user ID (the @Handle account name). Applies to both the tally panel and chat messages.",
            choices = { "Character Name", "ESO User ID" },
            choicesValues = { "character", "userid" },
            default = "character",
            getFunc = function() return GroupMementos.savedOptions.nameDisplay end,
            setFunc = function(value)
                GroupMementos.savedOptions.nameDisplay = value
                GroupMementos.UpdateDisplay()
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Reset session tally",
            tooltip = "Clears the current group's memento tally. This also happens automatically when you leave or disband the group.",
            func = function() GroupMementos.ResetSession() end,
            width = "full",
        },
        {
            type = "header",
            name = "Tracked Mementos/Toys",
        },
    }

    -- One checkbox per memento, in the same order they appear in the tally
    -- panel. Turning one off stops it from being counted at all (not just
    -- hidden) and removes its icon and column from the tally window, with
    -- the remaining ones sliding over to fill the gap.
    for _, mementoType in ipairs(GroupMementos.MEMENTO_ORDER) do
        local data = GroupMementos.MEMENTO_DATA[mementoType]
        table.insert(optionsData, {
            type = "checkbox",
            name = "Track " .. data.label,
            default = true,
            getFunc = function() return GroupMementos.savedOptions.trackMemento[mementoType] end,
            setFunc = function(value)
                GroupMementos.savedOptions.trackMemento[mementoType] = value
                GroupMementos.RefreshLayout()
                GroupMementos.UpdateDisplay() -- re-render names now that their available width may have changed
            end,
            width = "full",
        })
    end

    GroupMementos.addonPanel = LAM:RegisterAddonPanel("GroupMementosOptions", panelData)
    LAM:RegisterOptionControls("GroupMementosOptions", optionsData)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", GroupMementos.InitializeDisplay)
end

function GroupMementos.OpenSettingsMenu()
    LibAddonMenu2:OpenToPanel(GroupMementos.addonPanel)
end
