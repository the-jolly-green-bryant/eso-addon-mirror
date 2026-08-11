if not GildedUI then return end

local Addon = GildedUI

function Addon:BuildTrackerColumnMenu(H)
    local sv = self.state.sv
    local limits = self.limits
    local controls = {
        H.Slider(
            "Position Y",
            limits.posY.min,
            limits.posY.max,
            5,
            function() return sv.trackerColumnPosY end,
            function(v)
                sv.trackerColumnPosY = v
                Addon:ApplyTrackerColumn()
            end,
            Addon.defaults.trackerColumnPosY
        ),
        H.Slider(
            "Scale",
            limits.trackerColumnScale.min,
            limits.trackerColumnScale.max,
            0.05,
            function() return sv.trackerColumnScale end,
            function(v)
                sv.trackerColumnScale = v
                Addon:ApplyTrackerColumn()
            end,
            Addon.defaults.trackerColumnScale
        ),
        H.Toggle(
            "Show layout preview",
            function() return sv.trackerColumnShowPreview end,
            function(v)
                sv.trackerColumnShowPreview = v
                Addon:UpdateTrackerColumnPreview()
            end,
            Addon.defaults.trackerColumnShowPreview
        ),
    }

    return {
        type = "submenu",
        name = "Tracker Column",
        tooltip = "Moves and scales the whole right-side tracker stack (Archive through Activity Finder).",
        options = controls,
    }
end
