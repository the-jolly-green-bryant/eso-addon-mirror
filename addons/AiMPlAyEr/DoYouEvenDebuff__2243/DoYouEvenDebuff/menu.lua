-- Settings menu.
function MU.LoadSettings()
    local LAM = LibStub("LibAddonMenu-2.0")

    local panelData = {
        type = "panel",
        name = MU.name,
        displayName = MU.name,
        author = "|cfd6a02AiMPlAyEr[EU]|r",
        version = MU.version,
        slashCommand = "/mumenu",
        website = MU.website,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(MU.name, panelData)

    local optionsTable = {
        [1] = {
            type = "header",
            name = "Window Settings",
            width = "full",
        },
        [2] = {
            type = "description",
            text = [[Shows you a couple of debuffs on enemies (e.g. Alkosh, Crusher, Engulfing Flames and Taunt/Major Fracture)]]
        },
        [3] = {
            type = "checkbox",
            name = "Track Bosses Only",
            tooltip = "The timer only starts when you have a Dungeon/Trial Boss in your sights.",
            getFunc = function() return MU.SV.bossesonly end,
            setFunc = function(value) 
                MU.SV.bossesonly = value 
            end,
            width = "full"
        },
        [4] = {
            type = "checkbox",
            name = "Track Boss Immunity",
            tooltip = "Checks if the target is immune",
            getFunc = function() return MU.SV.immune end,
            setFunc = function(value) 
                MU.SV.immune = value 
                MU.BuildAddon()
            end,
            width = "full"
        },
        [5] = {
            type = "checkbox",
            name = "Hide UI When Out Of Combat",
            tooltip = "Hide UI When Out Of Combat",
            getFunc = function() return MU.SV.outofcombat end,
            setFunc = function(value) 
                if value then
                    MUGrid:SetHidden(true)
                else
                    MUGrid:SetHidden(false)
                end
                MU.SV.outofcombat = value
            end,
            width = "full"
        },
        [6] = {
            type = "dropdown",
            name = "Alignment",
            tooltip = "Arranges the elements according to the setting",
            choices = {"leftside", "splitted", "rightside"},
            getFunc = function() return MU.SV.mode end,
            setFunc = function(var) 
                MU.SV.mode = var 
                MU.BuildAddon()
            end,
            width = "full"
        },
        [7] = {
            type = "checkbox",
            name = "Disable Decimals",
            tooltip = "Displays only whole numbers",
            getFunc = function() return MU.SV.disabledecimal end,
            setFunc = function(value) 
                MU.SV.disabledecimal = value 
            end,
            width = "full"
        },
        [8] = {
            type = "header",
            name = "Tracker Settings",
            width = "full",
        },
        [9] = {
            type = "checkbox",
            name = "Taunt",
            tooltip = "",
            getFunc = function() return MU.SV.taunt end,
            setFunc = function(value) 
                MU.SV.taunt = value
                MU.BuildAddon()
            end,
            width = "full"
        },
        [10] = {
            type = "checkbox",
            name = "Engulfing Flames",
            tooltip = "",
            getFunc = function() return MU.SV.engulfing end,
            setFunc = function(value) 
                MU.SV.engulfing = value 
                MU.BuildAddon()
            end,
            width = "full"
        },
        [11] = {
            type = "checkbox",
            name = "Alkosh",
            tooltip = "",
            getFunc = function() return MU.SV.alkosh end,
            setFunc = function(value) 
                MU.SV.alkosh = value 
                MU.BuildAddon()
            end,
            width = "full"
        },
        [12] = {
            type = "checkbox",
            name = "Crusher",
            tooltip = "",
            getFunc = function() return MU.SV.crusher end,
            setFunc = function(value) 
                MU.SV.crusher = value 
                MU.BuildAddon()
            end,
            width = "full"
        },
        [13] = {
            type = "checkbox",
            name = "Major Fracture",
            tooltip = "",
            getFunc = function() return MU.SV.majorfracture end,
            setFunc = function(value) 
                MU.SV.majorfracture = value
                MU.BuildAddon() 
            end,
            width = "full"
        },
        [14] = {
            type = "checkbox",
            name = "Minor Fracture",
            tooltip = "",
            getFunc = function() return MU.SV.minorfracture end,
            setFunc = function(value) 
                MU.SV.minorfracture = value 
                MU.BuildAddon()
            end,
            width = "full"
        },
        [15] = {
            type = "checkbox",
            name = "Minor Vulnerability",
            tooltip = "",
            getFunc = function() return MU.SV.minorvulnerability end,
            setFunc = function(value) 
                MU.SV.minorvulnerability = value 
                MU.BuildAddon()
            end,
            width = "full"
        },
        [16] = {
            type = "checkbox",
            name = "Major Breach",
            tooltip = "",
            getFunc = function() return MU.SV.majorbreach end,
            setFunc = function(value) 
                MU.SV.majorbreach = value 
                MU.BuildAddon()
            end,
            width = "full"
        },
        [17] = {
            type = "checkbox",
            name = "Minor Breach",
            tooltip = "",
            getFunc = function() return MU.SV.minorbreach end,
            setFunc = function(value) 
                MU.SV.minorbreach = value 
                MU.BuildAddon()
            end,
            width = "full"
        },
        [18] = {
            type = "checkbox",
            name = "Minor Magicka Steal",
            tooltip = "",
            getFunc = function() return MU.SV.minormagickasteal end,
            setFunc = function(value) 
                MU.SV.minormagickasteal = value 
                MU.BuildAddon()
            end,
            width = "full"
        },
        [19] = {
            type = "checkbox",
            name = "Weakening",
            tooltip = "",
            getFunc = function() return MU.SV.weakening end,
            setFunc = function(value) 
                MU.SV.weakening = value 
                MU.BuildAddon()
            end,
            width = "full"
        }
    }
    LAM:RegisterOptionControls(MU.name, optionsTable)
end