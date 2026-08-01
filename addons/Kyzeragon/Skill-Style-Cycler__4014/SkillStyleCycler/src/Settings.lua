SkillStyleCycler = SkillStyleCycler or {}
local SSC = SkillStyleCycler


function SSC.CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Skill Style Cycler",
        author = "Kyzeragon",
        version = SSC.version,
        slashCommand = "/skillstylecycler",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "description",
            title = "|c3bdb5eGeneral Settings|r",
            text = nil,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show styles to be applied",
            tooltip = "Show chat with icons of which styles will be applied",
            default = true,
            getFunc = function() return SSC.savedOptions.printChat end,
            setFunc = function(value)
                SSC.savedOptions.printChat = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Only change if combat occurred",
            tooltip = "Only change styles if you have been in combat since the last time styles were changed, e.g. if your styles were just changed after exiting combat from killing some enemies, and then you enter a door (loadscreen), then styles won't change again. This avoids unnecessary changes, unless you're showing off while not in combat, I guess...",
            default = true,
            getFunc = function() return SSC.savedOptions.onlyTriggerIfCombat end,
            setFunc = function(value)
                SSC.savedOptions.onlyTriggerIfCombat = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Don't change styles in combat",
            tooltip = "Since changing styles requires using collectibles, it can prevent you from casting skills for a second. Turn this ON to prevent weaving issues when a trigger occurs during combat (e.g. leaving the puzzle rooms during the Chimera fight in Sanity's Edge)",
            default = true,
            getFunc = function() return SSC.savedOptions.cancelRetriesInCombat end,
            setFunc = function(value)
                SSC.savedOptions.cancelRetriesInCombat = value
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Throttling",
            tooltip = "The minimum time in seconds from the last success to cycle again, e.g. if you are rapidly entering and exiting combat, this is how many seconds to wait before cycling styles again, to avoid being kicked by the server for spamming",
            min = 0,
            max = 60,
            step = 1,
            default = 10,
            width = "full",
            getFunc = function() return SSC.savedOptions.throttle end,
            setFunc = function(value)
                SSC.savedOptions.throttle = value
            end,
        },
        {
            type = "checkbox",
            name = "Debug",
            tooltip = "Show debug chat",
            default = false,
            getFunc = function() return SSC.savedOptions.debug end,
            setFunc = function(value)
                SSC.savedOptions.debug = value
            end,
            width = "full",
        },
        {
            type = "description",
            title = "|c3bdb5eTriggers|r",
            text = "Do nothing - do not change styles\nRandomize all - randomly choose a style, including the current\nRandomize different - randomly choose a style different from the current\nCycle - choose the next style in the list",
            width = "full",
        },
        {
            type = "dropdown",
            name = "On login",
            tooltip = "Change styles on login",
            choices = {SSC.Modes.DO_NOTHING, SSC.Modes.RANDOMIZE_ALL, SSC.Modes.RANDOMIZE_DIFFERENT, SSC.Modes.CYCLE},
            default = SSC.Modes.DO_NOTHING,
            getFunc = function() return SSC.savedOptions.triggers.login end,
            setFunc = function(value)
                SSC.savedOptions.triggers.login = value
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "On exiting combat",
            tooltip = "Cycle styles on exiting combat",
            choices = {SSC.Modes.DO_NOTHING, SSC.Modes.RANDOMIZE_ALL, SSC.Modes.RANDOMIZE_DIFFERENT, SSC.Modes.CYCLE},
            default = SSC.Modes.DO_NOTHING,
            getFunc = function() return SSC.savedOptions.triggers.exitCombat end,
            setFunc = function(value)
                SSC.savedOptions.triggers.exitCombat = value
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "On loadscreen",
            tooltip = "Cycle styles on loadscreen (player activated)",
            choices = {SSC.Modes.DO_NOTHING, SSC.Modes.RANDOMIZE_ALL, SSC.Modes.RANDOMIZE_DIFFERENT, SSC.Modes.CYCLE},
            default = SSC.Modes.DO_NOTHING,
            getFunc = function() return SSC.savedOptions.triggers.loadscreen end,
            setFunc = function(value)
                SSC.savedOptions.triggers.loadscreen = value
            end,
            width = "full",
        },
        SSC.CreateToggleSettings(),
        {
            type = "description",
            title = "|cFF2222Warning|r",
            text = "Using these buttons too fast may result in being booted for spamming.",
            width = "half",
        },
        {
            type = "button",
            name = "Clear all",
            tooltip = "Clear all (unlocked and purchased) styles now. This is not affected by style filters",
            width = "half",
            func = function() SSC.CycleAll(SSC.Modes.CLEAR, true) end,
        },
        {
            type = "button",
            name = "Randomize all",
            tooltip = "Randomizes all (unlocked, purchased, and enabled in toggles) styles now",
            width = "half",
            func = function() SSC.CycleAll(SSC.Modes.RANDOMIZE_ALL, true) end,
        },
        {
            type = "button",
            name = "Set all",
            tooltip = "Set all (unlocked and purchased) styles now, to the last style in the list. This is not affected by style filters",
            width = "half",
            func = function() SSC.CycleAll(SSC.Modes.LAST, true) end,
        },
    }

    SSC.addonPanel = LAM:RegisterAddonPanel("SkillStyleCyclerOptions", panelData)
    LAM:RegisterOptionControls("SkillStyleCyclerOptions", optionsData)
end