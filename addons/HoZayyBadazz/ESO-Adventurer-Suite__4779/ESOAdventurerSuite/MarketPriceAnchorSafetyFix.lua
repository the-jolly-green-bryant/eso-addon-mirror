-- ESO Adventurer Suite
-- Market Price Checker anchor safety.
-- The live ESO ItemTooltip must never own, size against, or be the relative anchor
-- for Suite-created controls. Interactive market actions live in the right-click
-- menu and persistent Market Details panel instead.

local EPC = ESOProgressionCoach
if not EPC or not EPC.MarketPriceChecker then return end
local M = EPC.MarketPriceChecker
if M._marketPriceAnchorSafety029686 then return end
M._marketPriceAnchorSafety029686 = true

local function detachControl(control)
    if not control then return end
    if type(control.ClearAnchors) == "function" then pcall(control.ClearAnchors, control) end
    if type(control.SetHidden) == "function" then pcall(control.SetHidden, control, true) end
end

local function detachLegacyTooltipControls()
    local button = M.travelButton or rawget(_G, "EASMarketTravelButton029683")
    if button then
        local backdrop = button._easMarketBackdrop or rawget(_G, "EASMarketTravelButtonBackdrop029683")
        detachControl(backdrop)
        detachControl(button)
    end

    local tooltips = {
        rawget(_G, "ItemTooltip"),
        rawget(_G, "PopupTooltip"),
        rawget(_G, "InformationTooltip"),
    }
    for i = 1, #tooltips do
        local tooltip = tooltips[i]
        if tooltip and tooltip._easMarketShade029685 then
            detachControl(tooltip._easMarketShade029685)
            tooltip._easMarketShade029685 = nil
        end
    end
end

-- Override the original hide helper so any legacy hover button left alive in the
-- current UI session is detached, not merely hidden while retaining its anchor.
function M:HideTravelButton029683()
    detachLegacyTooltipControls()
    self.activeLocatedListing = nil
end

-- Hover tooltips are text-only from this point forward. Travel remains available
-- through the Guild Trader right-click menu and persistent Market Details panel.
function M:UpdateTravelButton029683(tooltip, record)
    detachLegacyTooltipControls()
end

-- v0.29.685 added a nearly opaque backdrop as a tooltip child for readability.
-- ESO's ItemTooltip has native background/munge controls and dynamic sizing; adding
-- another anchored child can participate in the same anchor traversal. Disable it.
function M:EnsureMarketTooltipShade029685(tooltip)
    if tooltip and tooltip._easMarketShade029685 then
        detachControl(tooltip._easMarketShade029685)
        tooltip._easMarketShade029685 = nil
    end
    return nil
end

-- Detach immediately in case another market file created controls earlier during
-- this same UI load. No OnUpdate or polling is needed.
detachLegacyTooltipControls()

EPC.marketPriceAnchorSafety029686 = true
