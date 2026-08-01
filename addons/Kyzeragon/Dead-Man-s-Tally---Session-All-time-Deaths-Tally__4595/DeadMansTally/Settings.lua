local DMT = DeadMansTally


function DMT.CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelData = {
        type = "panel",
        name = "Dead Man's Tally",
        author = "Kyzeragon",
        version = DMT.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local currSVs = DMT.packedSVs[GetWorldName()][GetUnitDisplayName("player")]
    local optionsData = {
        {
            type = "description",
            title = nil,
            text = "See |c99FF99/dmt|r for more commands and functions.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Lock UI",
            tooltip = "Lock panel to prevent re-positioning",
            default = false,
            getFunc = function() return currSVs.locked end,
            setFunc = function(value)
                if (value) then
                    DMT.Lock()
                else
                    DMT.Unlock()
                end
            end,
            width = "full",
        },
        {
            type = "slider",
            name = "Scale %",
            tooltip = "The scale % of the window. Note: this is just a simple scaling, so larger scale values may look blurry",
            min = 0,
            max = 200,
            step = 5,
            default = 100,
            getFunc = function() return currSVs.scale * 100 end,
            setFunc = function(value)
                currSVs.scale = value / 100
                DMT.UpdateAll()
                DMTContainer:SetHidden(false)
                DMT.Show()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Include this account in all-time",
            tooltip = string.format("Include the current account + server (%s, %s) in the all-time multi-account tally", GetUnitDisplayName("player"), GetWorldName()),
            default = true,
            getFunc = function() return currSVs.includeInAll end,
            setFunc = function(value)
                currSVs.includeInAll = value
                DMT.UpdateAll()
            end,
            width = "full",
            requiresReload = true,
        },
    }

    LAM:RegisterAddonPanel("DeadMansTallyOptions", panelData)
    LAM:RegisterOptionControls("DeadMansTallyOptions", optionsData)
end