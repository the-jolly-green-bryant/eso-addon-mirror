-----------------------------------------------------------
-- RefinementTracker
-- Displays boosters obtained from refining raw materials
-- @author Kyzeragon
-----------------------------------------------------------

function RefinementTracker:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    --Register the Options panel with LAM
    local panelData = 
    {
        type = "panel",
        name = "RefinementTracker",
        author = "Kyzeragon",
        version = RefinementTracker.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    --Set the actual panel data
    local optionsData = {
        [1] = {
            type = "description",
            title = nil,
            text = "|c99FF99/refined|r to open results window",
            width = "full",
        },
        [2] = {
            type = "checkbox",
            name = "Debug",
            tooltip = "Show lots of spam",
            default = false,
            getFunc = function() return RefinementTracker.SavedOptions.Debug end,
            setFunc = function(value) RefinementTracker.SavedOptions.Debug = value end,
            width = "full",
        },
        [3] = {
            type = "checkbox",
            name = "Chat output",
            tooltip = "Display obtained boosters in chat after exiting crafting station",
            default = true,
            getFunc = function() return RefinementTracker.SavedOptions.Enable end,
            setFunc = function(value) RefinementTracker.SavedOptions.Enable = value end,
            width = "full",
        },
        [4] = {
            type = "checkbox",
            name = "Ignore low extraction level",
            tooltip = "Do not add data to results panel if your craft extraction level is not 3",
            default = true,
            getFunc = function() return RefinementTracker.SavedOptions.IgnoreLowExtraction end,
            setFunc = function(value) RefinementTracker.SavedOptions.IgnoreLowExtraction = value end,
            width = "full",
        },
        [5] = {
            type = "checkbox",
            name = "Auto-show results panel",
            tooltip = "Automatically show results panel when entering relevant crafting station",
            default = true,
            getFunc = function() return RefinementTracker.SavedOptions.AutoShow end,
            setFunc = function(value) RefinementTracker.SavedOptions.AutoShow = value end,
            width = "full",
        },
        [6] = {
            type = "checkbox",
            name = "Don't auto-show low level",
            tooltip = "Do not show results panel if your craft extraction level is not 3",
            default = true,
            getFunc = function() return RefinementTracker.SavedOptions.HideLowExtraction end,
            setFunc = function(value) RefinementTracker.SavedOptions.HideLowExtraction = value end,
            width = "full",
            disabled = function() return not RefinementTracker.SavedOptions.AutoShow end,
        }
        
        -- TODO: open on crafting station enter
    }

    LAM:RegisterAddonPanel("RefinementTrackerOptions", panelData)
    LAM:RegisterOptionControls("RefinementTrackerOptions", optionsData)
end