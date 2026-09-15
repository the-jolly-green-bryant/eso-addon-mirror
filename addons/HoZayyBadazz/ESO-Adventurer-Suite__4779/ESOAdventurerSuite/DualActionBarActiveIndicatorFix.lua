-- ESO Adventurer Suite
-- v0.29.651 - zero-heavy-work active weapon-bar indicator synchronization.
-- IMPORTANT: this file must never trigger a full Dual Action Bar refresh on a
-- normal weapon swap. GlobalWeaponSwapPerformanceFix.lua remains the sole owner
-- of expensive/structural weapon-swap work.

local EPC = ESOProgressionCoach
if not EPC or not EPC.DualActionBar or not EVENT_MANAGER then return end

local D = EPC.DualActionBar
local EM = EVENT_MANAGER
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_ActiveBarIndicator029651"

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a
end

local function clamp(v, lo, hi)
    v = tonumber(v) or lo
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function refreshIndicatorOnly()
    local bar = EPC and EPC.DualActionBar
    if not bar or not bar.rows then return end

    local activeCategory = safe(GetActiveHotbarCategory, nil)
    if activeCategory == nil then return end

    bar.lastActiveCategory029311 = activeCategory
    bar._easLiveActiveCategory029638 = activeCategory

    local inactiveAlpha = clamp(((tonumber(EPC.saved and EPC.saved.dualActionBarInactiveAlpha029189) or 45) / 100), 0.10, 1.0)
    local markerMode = type(bar.GetMarkerMode029191) == "function" and bar:GetMarkerMode029191() or "ICON_GLOW"

    for _, row in ipairs(bar.rows) do
        if row then
            local active = row.epcCategory == activeCategory

            if type(row.SetAlpha) == "function" then
                row:SetAlpha(active and 1.0 or inactiveAlpha)
            end

            -- Keep the weapon symbol synchronized without invoking any heavy bar
            -- refresh or ability/cooldown/stack work.
            if type(bar.RefreshMarker029191) == "function" then
                pcall(bar.RefreshMarker029191, bar, row, active)
            end

            -- Keep the marker's gold border/background on the same row as the
            -- active weapon symbol. This mirrors DualActionBar:RefreshRow but is
            -- intentionally visual-only.
            if row.marker and row.marker.SetCenterColor and row.marker.SetEdgeColor then
                if active then
                    if markerMode == "ICON_GLOW" then
                        row.marker:SetCenterColor(0.20, 0.14, 0.03, 0.20)
                        row.marker:SetEdgeColor(1.00, 0.74, 0.18, 0.72)
                    else
                        row.marker:SetCenterColor(0.05, 0.055, 0.08, 0.16)
                        row.marker:SetEdgeColor(0.86, 0.72, 0.30, 0.46)
                    end
                elseif markerMode == "NUMBER" then
                    row.marker:SetCenterColor(0.02, 0.025, 0.04, 0.88)
                    row.marker:SetEdgeColor(0.30, 0.32, 0.38, 0.90)
                else
                    row.marker:SetCenterColor(0, 0, 0, 0)
                    row.marker:SetEdgeColor(0, 0, 0, 0)
                end
            end

            if row.markerText and row.markerText.SetColor then
                if active then
                    row.markerText:SetColor(1.00, 0.86, 0.36, 1)
                else
                    row.markerText:SetColor(0.72, 0.74, 0.80, 1)
                end
            end

            -- The active row's individual ability cells also use a gold border.
            -- Flip those borders here so they cannot remain on the previously
            -- active weapon bar while the symbol has already moved.
            for _, frame in ipairs(row.slots or {}) do
                if frame and frame.epcBG and frame.epcBG.SetEdgeColor then
                    if active then
                        frame.epcBG:SetEdgeColor(0.38, 0.30, 0.12, 0.98)
                    else
                        frame.epcBG:SetEdgeColor(0.16, 0.18, 0.22, 0.90)
                    end
                end
            end
        end
    end
end

-- EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED is the settled hotbar notification.
-- Do visual-state work only: no zo_callLater chain, no static rebuild, no dynamic
-- refresh, no skill/cooldown/stack scan, and no duplicate pair-change listener.
if EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED ~= nil then
    EM:UnregisterForEvent(NAME, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED)
    EM:RegisterForEvent(NAME, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, refreshIndicatorOnly)
end

D.activeBarIndicatorFix029651Installed = true
