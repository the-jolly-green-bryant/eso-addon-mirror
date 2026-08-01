local SynCool = SynergyCooldown


function SynCool.CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Synergy Cooldown",
        author = "Kyzeragon",
        version = SynCool.version,
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
            name = "Debug",
            tooltip = "Show debug chat",
            default = false,
            getFunc = function() return SynCool.savedOptions.debug end,
            setFunc = function(value)
                SynCool.savedOptions.debug = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Unlock frames",
            tooltip = "Unlock frames to allow re-positioning",
            default = false,
            getFunc = function() return SynCool.unlocked end,
            setFunc = function(value)
                SynCool.unlocked = value

                SynCoolContainer:SetMouseEnabled(value)
                SynCoolContainer:SetMovable(value)
                SynCoolContainerBackdrop:SetHidden(not value)

                SynCoolOthers:SetMouseEnabled(value)
                SynCoolOthers:SetMovable(value)
                SynCoolOthersBackdrop:SetHidden(not value)
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show only in combat",
            tooltip = "Only show the cooldown timers when you are in combat, hiding them upon exiting combat. Note the Test Cooldowns will not work if this is enabled, unless you are in combat",
            default = false,
            getFunc = function() return SynCool.savedOptions.showOnlyInCombat end,
            setFunc = function(value)
                SynCool.savedOptions.showOnlyInCombat = value
                SynCool.OnCombatStateChanged(_, IsUnitInCombat("player"))
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Test Cooldowns",
            tooltip = "Show a couple example synergy cooldown progress bars",
            func = SynCool.Test,
            width = "full",
        },
        {
            type = "description",
            title = "|c3bdb5eYour Cooldowns|r",
            text = "Every time you activate a synergy, you will get a timer with a progress bar for 20 seconds, indicating that you're on cooldown for that synergy.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show your own cooldowns",
            tooltip = "Show your own synergy cooldowns",
            default = true,
            getFunc = function() return SynCool.savedOptions.display.enabled end,
            setFunc = function(value)
                SynCool.savedOptions.display.enabled = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show progress bar",
            tooltip = "Show a progress bar and synergy name on your own cooldowns",
            default = true,
            getFunc = function() return SynCool.savedOptions.display.showBar end,
            setFunc = function(value)
                SynCool.savedOptions.display.showBar = value
            end,
            width = "full",
            disabled = function() return not SynCool.savedOptions.display.enabled end,
        },
        {
            type = "dropdown",
            name = "Growth direction",
            tooltip = "When multiple synergy cooldowns are active, should the next one go up or down?",
            choices = {"up", "down"},
            default = "down",
            getFunc = function()
                return SynCool.savedOptions.display.growth
            end,
            setFunc = function(name)
                SynCool.savedOptions.display.growth = name
                SynCool.ReAnchor()
            end,
            width = "full",
            disabled = function() return not SynCool.savedOptions.display.enabled end,
        },
        {
            type = "description",
            title = "|c3bdb5eOther Players' Cooldowns|r",
            text = "You can see the synergy cooldowns of group members too, but only those marked as tanks.\nIf you want to watch specific players instead, you can use |c99FF99/scwatch @Player1 @Player2|r with their @ names, but this is not saved across reloads.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show other players' cooldowns",
            tooltip = "Show synergy cooldowns for group members",
            default = false,
            getFunc = function() return SynCool.savedOptions.othersDisplay.enabled end,
            setFunc = function(value)
                SynCool.savedOptions.othersDisplay.enabled = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show progress bar",
            tooltip = "Show a progress bar and player name on other players' cooldowns",
            default = true,
            getFunc = function() return SynCool.savedOptions.othersDisplay.showBar end,
            setFunc = function(value)
                SynCool.savedOptions.othersDisplay.showBar = value
            end,
            width = "full",
            disabled = function() return not SynCool.savedOptions.othersDisplay.enabled end,
        },
        {
            type = "dropdown",
            name = "Growth direction",
            tooltip = "When multiple synergy cooldowns are active for other players, should the next one go up or down?",
            choices = {"up", "down"},
            default = "down",
            getFunc = function()
                return SynCool.savedOptions.othersDisplay.growth
            end,
            setFunc = function(name)
                SynCool.savedOptions.othersDisplay.growth = name
                SynCool.ReAnchor()
            end,
            width = "full",
            disabled = function() return not SynCool.savedOptions.othersDisplay.enabled end,
        },
    }

    if (ZO_IsConsoleOrGameCoreUI()) then
        local function UpdateAnchors()
            SynCoolContainer:SetAnchor(CENTER, GuiRoot, CENTER, SynCool.savedOptions.display.x, SynCool.savedOptions.display.y)
            SynCoolOthers:SetAnchor(CENTER, GuiRoot, CENTER, SynCool.savedOptions.othersDisplay.x, SynCool.savedOptions.othersDisplay.y)
            SynCool.Test()
        end

        table.insert(optionsData, 10, {
            type = "slider",
            name = "Position X",
            tooltip = "The horizontal position of your cooldowns",
            min = - GuiRoot:GetWidth() / 2,
            max = GuiRoot:GetWidth() / 2,
            step = GuiRoot:GetWidth() / 64,
            default = GuiRoot:GetWidth() / 5,
            getFunc = function() return SynCool.savedOptions.display.x end,
            setFunc = function(value)
                SynCool.savedOptions.display.x = value
                UpdateAnchors()
            end,
            disabled = function() return not SynCool.savedOptions.display.enabled end,
        })
        table.insert(optionsData, 11, {
            type = "slider",
            name = "Position Y",
            tooltip = "The vertical position of your cooldowns",
            min = - GuiRoot:GetHeight() / 2,
            max = GuiRoot:GetHeight() / 2,
            step = GuiRoot:GetHeight() / 64,
            default = 0,
            getFunc = function() return SynCool.savedOptions.display.y end,
            setFunc = function(value)
                SynCool.savedOptions.display.y = value
                UpdateAnchors()
            end,
            disabled = function() return not SynCool.savedOptions.display.enabled end,
        })
        table.insert(optionsData, {
            type = "slider",
            name = "Position X",
            tooltip = "The horizontal position of other players' cooldowns",
            min = - GuiRoot:GetWidth() / 2,
            max = GuiRoot:GetWidth() / 2,
            step = GuiRoot:GetWidth() / 64,
            default = GuiRoot:GetWidth() / 5,
            getFunc = function() return SynCool.savedOptions.othersDisplay.x end,
            setFunc = function(value)
                SynCool.savedOptions.othersDisplay.x = value
                UpdateAnchors()
            end,
            disabled = function() return not SynCool.savedOptions.othersDisplay.enabled end,
        })
        table.insert(optionsData, {
            type = "slider",
            name = "Position Y",
            tooltip = "The vertical position of other players' cooldowns",
            min = - GuiRoot:GetHeight() / 2,
            max = GuiRoot:GetHeight() / 2,
            step = GuiRoot:GetHeight() / 64,
            default = 0,
            getFunc = function() return SynCool.savedOptions.othersDisplay.y end,
            setFunc = function(value)
                SynCool.savedOptions.othersDisplay.y = value
                UpdateAnchors()
            end,
            disabled = function() return not SynCool.savedOptions.othersDisplay.enabled end,
        })

        table.remove(optionsData, 3)
    end

    SynCool.addonPanel = LAM:RegisterAddonPanel("SynergyCooldownOptions", panelData)
    LAM:RegisterOptionControls("SynergyCooldownOptions", optionsData)
end