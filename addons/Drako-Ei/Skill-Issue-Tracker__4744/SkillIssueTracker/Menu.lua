local SIT = SkillIssueTracker
local menu = SIT.menu
local LAM = LibAddonMenu2

local MARK_SQUARE = TARGET_MARKER_TYPE_ONE
local MARK_STAR = TARGET_MARKER_TYPE_TWO
local MARK_CIRCLE = TARGET_MARKER_TYPE_THREE
local MARK_TRIANGLE = TARGET_MARKER_TYPE_FOUR
local MARK_MOON = TARGET_MARKER_TYPE_FIVE
local MARK_OBLIVION = TARGET_MARKER_TYPE_SIX
local MARK_SWORDS = TARGET_MARKER_TYPE_SEVEN
local MARK_SKULL = TARGET_MARKER_TYPE_EIGHT

menu.initialize = function()
    local panelData = {
        type = "panel",
        name = SIT.menuName,
        displayName = SIT.menuName,
        author = SIT.author,
        version = SIT.version,
        slashCommand = SIT.command,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type = "description",
            text = "SkillIssueTracker is a simple addon that automatically marks enemies in battlegrounds.",
        },
        {
            type = "checkbox",
            name = "Enable Addon",
            tooltip = "Turn SkillIssueTracker on or off.",
            getFunc = function() return SIT.savedVars.enabled end,
            setFunc = function(value)
                SIT.savedVars.enabled = value
                SIT.events.OnPlayerActivated()
            end,
            default = function() return SIT.defaultVars.enabled end,
        },
        {
            type = "dropdown",
            name = "Target Marker Type",
            tooltip = "Select the target marker type to use for marking enemies.",
            choices = {
                "Square",
                "Star",
                "Circle",
                "Triangle",
                "Moon",
                "Oblivion",
                "Swords",
                "Skull"
            },
            getFunc = function()
                local markerType = SIT.savedVars.markerType
                if markerType == MARK_SQUARE then return "Square"
                elseif markerType == MARK_STAR then return "Star"
                elseif markerType == MARK_CIRCLE then return "Circle"
                elseif markerType == MARK_TRIANGLE then return "Triangle"
                elseif markerType == MARK_MOON then return "Moon"
                elseif markerType == MARK_OBLIVION then return "Oblivion"
                elseif markerType == MARK_SWORDS then return "Swords"
                else return "Skull" end
            end,
            setFunc = function(value)
                if value == "Square" then SIT.savedVars.markerType = MARK_SQUARE
                elseif value == "Star" then SIT.savedVars.markerType = MARK_STAR
                elseif value == "Circle" then SIT.savedVars.markerType = MARK_CIRCLE
                elseif value == "Triangle" then SIT.savedVars.markerType = MARK_TRIANGLE
                elseif value == "Moon" then SIT.savedVars.markerType = MARK_MOON
                elseif value == "Oblivion" then SIT.savedVars.markerType = MARK_OBLIVION
                elseif value == "Swords" then SIT.savedVars.markerType = MARK_SWORDS
                elseif value == "Skull" then SIT.savedVars.markerType = MARK_SKULL end
            end,
            default = function() return SIT.defaultVars.markerType end,
        },
    }

    LAM:RegisterAddonPanel(SIT.name .. "_Menu", panelData)
    LAM:RegisterOptionControls(SIT.name .. "_Menu", optionsTable)
end