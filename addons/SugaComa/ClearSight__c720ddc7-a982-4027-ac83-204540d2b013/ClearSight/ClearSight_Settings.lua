local CS = ClearSight

function CS:InitializeSettings()
    if not LibHarvensAddonSettings then
        return
    end

    local panel = LibHarvensAddonSettings:AddAddon("ClearSight", {
        allowDefaults = false,
        allowRefresh = true,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "ClearSight Compass Aid",
        tooltip = "Enable or disable the ClearSight high-visibility compass waypoint aid.",
        getFunction = function()
            return CS.saved.waypoint.enabled
        end,
        setFunction = function(value)
            CS.saved.waypoint.enabled = value
            if CS.UpdateWaypoint then
                CS:UpdateWaypoint()
            end
        end,
        default = true,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "ClearSight Reticle",
        tooltip = "Enable or disable the ClearSight high-visibility reticle.",
        getFunction = function()
            return CS.saved.reticle.enabled
        end,
        setFunction = function(value)
            CS.saved.reticle.enabled = value
            if CS.UpdateReticle then
                CS:UpdateReticle()
            end
        end,
        default = true,
    })
end
