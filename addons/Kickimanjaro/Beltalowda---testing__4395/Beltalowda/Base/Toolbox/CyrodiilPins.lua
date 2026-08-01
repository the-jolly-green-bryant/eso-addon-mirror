-- Beltalowda Cyrodiil Map Pins
-- Adds map pins for Volendrung spawn locations and Ayleid Wells on the
-- Cyrodiil world map. Volendrung spawns are classified as confirmed,
-- suspected, or unconfirmed (visible in tooltips only — all pins share
-- the same visual style). Ayleid Wells show fixed locations and track
-- respawn timers when a well buff is gained.
--
-- Requires LibMapPins-1.0 (optional dependency). The module silently
-- disables itself when the library is not installed.

Beltalowda = Beltalowda or {}
Beltalowda.Toolbox = Beltalowda.Toolbox or {}
Beltalowda.Toolbox.CyrodiilPins = Beltalowda.Toolbox.CyrodiilPins or {}

local CP = Beltalowda.Toolbox.CyrodiilPins

-- ============================================================================
-- Constants
-- ============================================================================

local CALLBACK_NAME = "BeltalowdaCyrodiilPins"

local PIN_TYPE_VOLENDRUNG = "BeltalowdaVolendrungSpawnPin"
local PIN_TYPE_WELL       = "BeltalowdaAyleidWellPin"

-- Ayleid Well buff ability ID (Fortified Ayleid Health Bonus)
local WELL_BUFF_ID = 100862

-- Alliance constants for labeling
local ALLIANCE_AD = 1 -- Aldmeri Dominion
local ALLIANCE_EP = 2 -- Ebonheart Pact
local ALLIANCE_DC = 3 -- Daggerfall Covenant

local ALLIANCE_NAMES = {
    [ALLIANCE_AD] = "Aldmeri Dominion",
    [ALLIANCE_EP] = "Ebonheart Pact",
    [ALLIANCE_DC] = "Daggerfall Covenant",
}

local ALLIANCE_COLORS = {
    [ALLIANCE_AD] = "|cFFD700",   -- gold
    [ALLIANCE_EP] = "|cDD2222",   -- red
    [ALLIANCE_DC] = "|c2266FF",   -- blue
}

-- Confirmation status constants
local STATUS_CONFIRMED   = "confirmed"
local STATUS_SUSPECTED   = "suspected"
local STATUS_UNCONFIRMED = "unconfirmed"

local STATUS_LABELS = {
    [STATUS_CONFIRMED]   = "|c00FF00Confirmed|r",
    [STATUS_SUSPECTED]   = "|cFFFF00Suspected|r",
    [STATUS_UNCONFIRMED] = "|cFF6600Unconfirmed|r",
}

-- ============================================================================
-- Coordinate data
-- ============================================================================

--[[
    Volendrung spawn locations on the Cyrodiil world map.
    Coordinates are normalized (0–1) for the ava_whole map.
    Source: MapPins addon (esoui.com info1881) with confirmation from
    in-game observation.
]]--
local VOLENDRUNG_SPAWNS = {
    -- Aldmeri Dominion territory
    { x = 0.483, y = 0.791, alliance = ALLIANCE_AD, status = STATUS_CONFIRMED   },
    { x = 0.641, y = 0.769, alliance = ALLIANCE_AD, status = STATUS_CONFIRMED   },
    { x = 0.408, y = 0.636, alliance = ALLIANCE_AD, status = STATUS_UNCONFIRMED },
    { x = 0.340, y = 0.709, alliance = ALLIANCE_AD, status = STATUS_UNCONFIRMED },
    { x = 0.531, y = 0.876, alliance = ALLIANCE_AD, status = STATUS_SUSPECTED   },
    { x = 0.525, y = 0.619, alliance = ALLIANCE_AD, status = STATUS_UNCONFIRMED },

    -- Ebonheart Pact territory
    { x = 0.752, y = 0.486, alliance = ALLIANCE_EP, status = STATUS_UNCONFIRMED },
    { x = 0.685, y = 0.532, alliance = ALLIANCE_EP, status = STATUS_UNCONFIRMED },
    { x = 0.711, y = 0.143, alliance = ALLIANCE_EP, status = STATUS_CONFIRMED   },
    { x = 0.631, y = 0.302, alliance = ALLIANCE_EP, status = STATUS_UNCONFIRMED },
    { x = 0.776, y = 0.278, alliance = ALLIANCE_EP, status = STATUS_SUSPECTED   },
    { x = 0.484, y = 0.546, alliance = ALLIANCE_EP, status = STATUS_UNCONFIRMED },
    { x = 0.711, y = 0.393, alliance = ALLIANCE_EP, status = STATUS_UNCONFIRMED },
    { x = 0.595, y = 0.382, alliance = ALLIANCE_EP, status = STATUS_UNCONFIRMED },
    { x = 0.844, y = 0.166, alliance = ALLIANCE_EP, status = STATUS_CONFIRMED   },

    -- Daggerfall Covenant territory
    { x = 0.199, y = 0.372, alliance = ALLIANCE_DC, status = STATUS_UNCONFIRMED },
    { x = 0.349, y = 0.164, alliance = ALLIANCE_DC, status = STATUS_UNCONFIRMED },
    { x = 0.209, y = 0.224, alliance = ALLIANCE_DC, status = STATUS_CONFIRMED   },
    { x = 0.108, y = 0.231, alliance = ALLIANCE_DC, status = STATUS_CONFIRMED   },
    { x = 0.302, y = 0.351, alliance = ALLIANCE_DC, status = STATUS_SUSPECTED   },
    { x = 0.392, y = 0.361, alliance = ALLIANCE_DC, status = STATUS_UNCONFIRMED },
    { x = 0.483, y = 0.220, alliance = ALLIANCE_DC, status = STATUS_UNCONFIRMED },
}

--[[
    Ayleid Well locations on the Cyrodiil world map.
    Coordinates are normalized (0–1) for the ava_whole map.
    Source: Destinations addon (esoui.com info667).
    Wells restore Health, Magicka, and Stamina and respawn every 20 minutes.
]]--
local AYLEID_WELLS = {
    { x = 0.1854, y = 0.4076 },
    { x = 0.2614, y = 0.6707 },
    { x = 0.3325, y = 0.7289 },
    { x = 0.3610, y = 0.3613 },
    { x = 0.3832, y = 0.5302 },
    { x = 0.3923, y = 0.6916 },
    { x = 0.4380, y = 0.2109 },
    { x = 0.4610, y = 0.2394 },
    { x = 0.4658, y = 0.7643 },
    { x = 0.5054, y = 0.7613 },
    { x = 0.6215, y = 0.7929 },
    { x = 0.6253, y = 0.5077 },
    { x = 0.6277, y = 0.4447 },
    { x = 0.6383, y = 0.6508 },
    { x = 0.6585, y = 0.6944 },
    { x = 0.7062, y = 0.5809 },
}

-- ============================================================================
-- Volendrung artifact state
-- ============================================================================

-- Tracks whether Volendrung is currently spawned but not yet revealed.
-- When true, spawn location pins are shown (unless overridden by the
-- "always show" setting).
local volendrungSpawnedNotRevealed = false

-- ============================================================================
-- Pin layout data
-- ============================================================================

-- Volendrung pins — uniform greyscale style; confirmation is tooltip-only
local VOLENDRUNG_LAYOUT = {
    level = 55,
    texture = "EsoUI/Art/MapPins/AvA_daedricArtifact_volendrung_neutral.dds",
    size = 32,
    grayscale = true,
    tint = ZO_ColorDef:New(0.6, 0.6, 0.6, 0.6),
}

local WELL_LAYOUT = {
    level = 55,
    texture = "/esoui/art/icons/quest_spirit_001.dds",
    size = 28,
}

-- ============================================================================
-- Well timer state
-- ============================================================================

-- Maps well index → GetTimeStamp() epoch when taken.
-- Populated from saved variables on init and updated on well pickup.
-- Using GetTimeStamp() (Unix epoch seconds) so values survive /reloadui.
local wellTakenTimestamps = {}

-- LGB protocol handle for broadcasting well pickups
local wellProtocol = nil

-- Distance threshold (normalized) for matching player position to a well
local WELL_MATCH_DISTANCE = 0.03

--[[
    Find the nearest well to the given normalized map coordinates.
    Returns the well index (1-based) or nil if none within threshold.
]]--
local function FindNearestWell(px, py)
    local bestIndex, bestDistSq = nil, WELL_MATCH_DISTANCE * WELL_MATCH_DISTANCE
    for i, well in ipairs(AYLEID_WELLS) do
        local dx = well.x - px
        local dy = well.y - py
        local distSq = dx * dx + dy * dy
        if distSq < bestDistSq then
            bestDistSq = distSq
            bestIndex = i
        end
    end
    return bestIndex
end

--[[
    Format elapsed seconds into M:SS or H:MM:SS.
]]--
local function FormatElapsed(seconds)
    local s = math.floor(seconds)
    if s < 3600 then
        return string.format("%d:%02d", math.floor(s / 60), s % 60)
    end
    return string.format("%d:%02d:%02d", math.floor(s / 3600), math.floor(s / 60) % 60, s % 60)
end

-- ============================================================================
-- Tooltip creators
-- ============================================================================

local VOLENDRUNG_TOOLTIP = {
    creator = function(pin)
        local _, pinTag = pin:GetPinTypeAndTag()
        if not pinTag then return end

        local allianceColor = ALLIANCE_COLORS[pinTag.alliance] or "|cFFFFFF"
        local allianceName  = ALLIANCE_NAMES[pinTag.alliance] or "Unknown"
        local statusLabel   = STATUS_LABELS[pinTag.status] or pinTag.status

        if IsInGamepadPreferredMode() then
            local tooltip = ZO_MapLocationTooltip_Gamepad
            local baseSection = tooltip.tooltip
            tooltip:LayoutIconStringLine(baseSection, nil,
                "Volendrung Spawn", baseSection:GetStyle("mapLocationTooltipContentName"))
            tooltip:LayoutIconStringLine(baseSection, nil,
                statusLabel, baseSection:GetStyle("mapLocationTooltipContentName"))
            tooltip:LayoutIconStringLine(baseSection, nil,
                allianceColor .. allianceName .. "|r" .. " territory",
                baseSection:GetStyle("mapLocationTooltipContentName"))
        else
            InformationTooltip:AddLine("Volendrung Spawn")
            InformationTooltip:AddLine(statusLabel)
            InformationTooltip:AddLine(allianceColor .. allianceName .. "|r" .. " territory")
        end
    end,
    tooltip = 1, -- ZO_MAP_TOOLTIP_MODE.INFORMATION
}

local WELL_TOOLTIP = {
    creator = function(pin)
        local _, pinTag = pin:GetPinTypeAndTag()
        -- Compute elapsed time if this well has been taken
        local timerLine = nil
        if pinTag then
            for i, well in ipairs(AYLEID_WELLS) do
                if well == pinTag and wellTakenTimestamps[i] then
                    local elapsed = GetTimeStamp() - wellTakenTimestamps[i]
                    timerLine = "|cFFD700Taken " .. FormatElapsed(elapsed) .. " ago|r"
                    break
                end
            end
        end

        if IsInGamepadPreferredMode() then
            local tooltip = ZO_MapLocationTooltip_Gamepad
            local baseSection = tooltip.tooltip
            tooltip:LayoutIconStringLine(baseSection, nil,
                "Ayleid Well", baseSection:GetStyle("mapLocationTooltipContentName"))
            if timerLine then
                tooltip:LayoutIconStringLine(baseSection, nil,
                    timerLine, baseSection:GetStyle("mapLocationTooltipContentName"))
            end
        else
            InformationTooltip:AddLine("Ayleid Well")
            if timerLine then
                InformationTooltip:AddLine(timerLine)
            end
        end
    end,
    tooltip = 1, -- ZO_MAP_TOOLTIP_MODE.INFORMATION
}

-- ============================================================================
-- Pin creation callbacks
-- ============================================================================

--[[
    Called by LibMapPins every time the map changes. Creates Volendrung spawn
    pins only when viewing the Cyrodiil world map.

    By default, pins only appear while the artifact is spawned but not yet
    revealed (the most useful moment — players know the hammer is out but
    don't know where). The "Always show" setting overrides this gate.
]]--
local function VolendrungPinCallback(pinManager)
    local LMP = LibMapPins
    if not LMP then return end
    if not LMP:IsEnabled(PIN_TYPE_VOLENDRUNG) then return end

    -- Only show on the Cyrodiil map
    local cyroIndex = GetCyrodiilMapIndex()
    if not cyroIndex or GetCurrentMapIndex() ~= cyroIndex then return end

    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.cyrodiilPins
    if not vars or not vars.volendrungEnabled then return end

    -- Gate on artifact state unless always-show is enabled
    if not vars.volendrungAlwaysShow and not volendrungSpawnedNotRevealed then return end

    for _, spawn in ipairs(VOLENDRUNG_SPAWNS) do
        LMP:CreatePin(PIN_TYPE_VOLENDRUNG, spawn, spawn.x, spawn.y)
    end
end

--[[
    Called by LibMapPins every time the map changes. Creates Ayleid Well pins
    only when viewing the Cyrodiil world map.
]]--
local function WellPinCallback(pinManager)
    local LMP = LibMapPins
    if not LMP then return end
    if not LMP:IsEnabled(PIN_TYPE_WELL) then return end

    -- Only show on the Cyrodiil map
    local cyroIndex = GetCyrodiilMapIndex()
    if not cyroIndex or GetCurrentMapIndex() ~= cyroIndex then return end

    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.cyrodiilPins
    if not vars or not vars.wellsEnabled then return end

    for _, well in ipairs(AYLEID_WELLS) do
        LMP:CreatePin(PIN_TYPE_WELL, well, well.x, well.y)
    end
end

-- ============================================================================
-- Module lifecycle
-- ============================================================================

--[[
    Initialize the module. Registers custom pin types and map filter entries.
    Silently returns if LibMapPins is not loaded.
]]--
function CP.Initialize()
    if CP.initialized then return end

    local LMP = LibMapPins
    if not LMP then return end

    -- Register pin types
    LMP:AddPinType(PIN_TYPE_VOLENDRUNG, VolendrungPinCallback, nil, VOLENDRUNG_LAYOUT, VOLENDRUNG_TOOLTIP)
    LMP:AddPinType(PIN_TYPE_WELL,       WellPinCallback,       nil, WELL_LAYOUT,       WELL_TOOLTIP)

    -- Add map filter checkboxes (visible only on the Cyrodiil map)
    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.cyrodiilPins
    LMP:AddPinFilter(PIN_TYPE_VOLENDRUNG, "Volendrung Spawns", true,
        vars, "volendrungFilterPve", "volendrungFilterPvp")
    LMP:AddPinFilter(PIN_TYPE_WELL, "Ayleid Wells", true,
        vars, "wellsFilterPve", "wellsFilterPvp")

    -- Hide filters in non-PvP contexts — these are Cyrodiil-only features
    LMP:SetPinFilterHidden(PIN_TYPE_VOLENDRUNG, "pve", true)
    LMP:SetPinFilterHidden(PIN_TYPE_VOLENDRUNG, "imperialPvP", true)
    LMP:SetPinFilterHidden(PIN_TYPE_VOLENDRUNG, "battleground", true)

    LMP:SetPinFilterHidden(PIN_TYPE_WELL, "pve", true)
    LMP:SetPinFilterHidden(PIN_TYPE_WELL, "imperialPvP", true)
    LMP:SetPinFilterHidden(PIN_TYPE_WELL, "battleground", true)

    CP.initialized = true

    -- Restore well timestamps from saved variables
    CP.RestoreWellTimestamps()

    -- Register for Volendrung artifact state changes
    CP.RegisterVolendrungTracking()

    -- Register for well buff gained to start respawn timers
    CP.RegisterWellTracking()

    -- Register LGB broadcast protocol for well pickups
    CP.RegisterWellBroadcast()
end

--[[
    Restore well pickup timestamps from saved variables.
    Called during Initialize() to survive /reloadui.
]]--
function CP.RestoreWellTimestamps()
    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.cyrodiilPins
    if not vars or not vars.wellTimestamps then return end

    local now = GetTimeStamp()
    local restored = 0
    for indexStr, ts in pairs(vars.wellTimestamps) do
        local i = tonumber(indexStr)
        -- Only restore timestamps from the last 2 hours (stale data is unhelpful)
        if i and ts and (now - ts) < 7200 then
            wellTakenTimestamps[i] = ts
            restored = restored + 1
        end
    end
    if restored > 0 then
        d("|c4592FF[Beltalowda]|r Restored " .. restored .. " well timer(s) from saved data.")
    end
end

--[[
    Persist a well timestamp to saved variables.
]]--
local function SaveWellTimestamp(wellIndex, timestamp)
    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.cyrodiilPins
    if not vars then return end
    if not vars.wellTimestamps then vars.wellTimestamps = {} end
    vars.wellTimestamps[tostring(wellIndex)] = timestamp
end

-- ============================================================================
-- Volendrung artifact tracking
-- ============================================================================

--[[
    Track the Volendrung lifecycle via two events:
    - EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED
      Fires when the hammer materializes somewhere in Cyrodiil but
      nobody has found it yet.  This is when spawn pins are most useful.
    - EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED
      Fires on every state transition.  When the state moves away from
      UNKNOWN (revealed / picked up) or back to UNKNOWN (despawned),
      we clear the spawned-not-revealed flag.
]]--
function CP.RegisterVolendrungTracking()
    local cbName = CALLBACK_NAME .. ".Volendrung"

    -- Hammer has spawned but nobody found it yet
    EVENT_MANAGER:RegisterForEvent(cbName .. ".Spawned",
        EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED,
        function(_, daedricArtifactId)
            volendrungSpawnedNotRevealed = true
            if LibMapPins then
                LibMapPins:RefreshPins(PIN_TYPE_VOLENDRUNG)
            end
        end)

    -- Any state transition — revealed, picked up, dropped, or despawned
    EVENT_MANAGER:RegisterForEvent(cbName .. ".StateChanged",
        EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED,
        function(_, objectiveKeepId, objectiveObjectiveId, battlegroundContext,
                 objectiveControlEvent, objectiveControlState, holderAlliance,
                 lastHolderAlliance, pinType, daedricArtifactId, lastObjectiveControlState)
            -- Once the artifact is revealed, picked up, or despawned it is
            -- no longer in the "spawned but not revealed" window
            volendrungSpawnedNotRevealed = false
            if LibMapPins then
                LibMapPins:RefreshPins(PIN_TYPE_VOLENDRUNG)
            end
        end)
end

-- ============================================================================
-- Well buff tracking
-- ============================================================================

--[[
    Listen for the Fortified Ayleid Health Bonus buff to detect when the
    player picks up a well. Records the timestamp against the nearest well
    so the tooltip can show elapsed time.
]]--
function CP.RegisterWellTracking()
    EVENT_MANAGER:RegisterForEvent(CALLBACK_NAME, EVENT_EFFECT_CHANGED,
        function(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime,
                 stackCount, iconName, buffType, effectType, abilityType,
                 statusEffectType, unitName, unitId, abilityId, sourceType)
            if abilityId ~= WELL_BUFF_ID then return end

            -- Accept both initial gain and duration refresh (re-drinking a well
            -- while the buff is already active fires UPDATED, not GAINED)
            if changeType ~= EFFECT_RESULT_GAINED and changeType ~= EFFECT_RESULT_UPDATED then return end

            -- Must be in Cyrodiil to match well locations
            if not IsInCyrodiil() then return end

            -- Temporarily set the map to the Cyrodiil world map so
            -- GetMapPlayerPosition returns coordinates in the same
            -- frame as our well data (ava_whole normalized 0-1).
            local cyroIndex = GetCyrodiilMapIndex()
            if not cyroIndex then return end
            SetMapToMapListIndex(cyroIndex)

            local px, py = GetMapPlayerPosition("player")
            local wellIndex = FindNearestWell(px, py)

            -- Restore map to player location so the UI stays correct
            SetMapToPlayerLocation()

            if wellIndex then
                local ts = GetTimeStamp()
                wellTakenTimestamps[wellIndex] = ts
                SaveWellTimestamp(wellIndex, ts)
                CP.BroadcastWellPickup(wellIndex, ts)
                d("|c4592FF[Beltalowda]|r Ayleid Well taken — timer started for well #" .. wellIndex)
            else
                d("|c4592FF[Beltalowda]|r Ayleid Well buff detected but no nearby well matched (px=" ..
                    string.format("%.4f", px) .. " py=" .. string.format("%.4f", py) .. ")")
            end
        end)
    -- Filter to player unit tag only for performance
    -- (REGISTER_FILTER_ABILITY_ID does not exist; abilityId is checked in the callback)
    EVENT_MANAGER:AddFilterForEvent(CALLBACK_NAME, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player")
end

-- ============================================================================
-- Well pickup broadcast (LibGroupBroadcast)
-- ============================================================================

--[[
    Register a LibGroupBroadcast protocol for sharing well pickups with the
    group.  Each send contains the well index (0-15) and elapsed minutes
    since pickup (0-127), so receivers can reconstruct the timestamp.
    Protocol 220: 11 bits total (4 + 7).
]]--
function CP.RegisterWellBroadcast()
    -- Guard against re-registration on subsequent EVENT_PLAYER_ACTIVATED calls
    if wellProtocol then return end

    local LGB = LibGroupBroadcast or (LibStub and LibStub:GetLibrary("LibGroupBroadcast", true))
    if not LGB then
        d("|c4592FF[Beltalowda]|r Well broadcast: LibGroupBroadcast not available")
        return
    end

    -- BeltalowdaNetwork is a local inside GroupBroadcast.lua, so we must
    -- access the network table via the Beltalowda global.
    local net = Beltalowda and Beltalowda.network
    local handler = net and net.lgbHandler
    if not handler then
        d("|c4592FF[Beltalowda]|r Well broadcast: lgbHandler not available")
        return
    end

    local WELL_PICKUP_ID = net.MESSAGE_IDS and net.MESSAGE_IDS.WELL_PICKUP
    if not WELL_PICKUP_ID then
        d("|c4592FF[Beltalowda]|r Well broadcast: MESSAGE_IDS.WELL_PICKUP not defined")
        return
    end

    local success, err = pcall(function()
        wellProtocol = handler:DeclareProtocol(
            WELL_PICKUP_ID,
            "BeltalowdaWellPickup"
        )

        -- Well index: 0-15 (4 bits)
        wellProtocol:AddField(
            LGB.CreateNumericField("wellIndex", { minValue = 0, maxValue = 15 })
        )

        -- Elapsed minutes since pickup: 0-127 (7 bits)
        wellProtocol:AddField(
            LGB.CreateNumericField("elapsedMin", { minValue = 0, maxValue = 127, trimValues = true })
        )

        -- On receive: reconstruct the timestamp and store it
        wellProtocol:OnData(function(unitTag, data)
            if not data or not data.wellIndex then return end

            local wellIdx = data.wellIndex + 1  -- protocol uses 0-based, table is 1-based
            local elapsedSec = (data.elapsedMin or 0) * 60
            local ts = GetTimeStamp() - elapsedSec

            -- Only accept if this is newer than what we already have
            local existing = wellTakenTimestamps[wellIdx]
            if not existing or ts > existing then
                wellTakenTimestamps[wellIdx] = ts
                SaveWellTimestamp(wellIdx, ts)

                local unitName = GetUnitName(unitTag) or unitTag
                d("|c4592FF[Beltalowda]|r Well #" .. wellIdx ..
                    " taken by " .. unitName ..
                    " (" .. data.elapsedMin .. "m ago)")
            end
        end)

        wellProtocol:Finalize({ replaceQueuedMessages = true })
    end)

    if not success then
        wellProtocol = nil  -- ensure it stays nil on failure so retry is possible
        d("|c4592FF[Beltalowda]|r Well broadcast registration failed: " .. tostring(err))
    else
        d("|c4592FF[Beltalowda]|r Well broadcast protocol 220 registered OK")
        -- Broadcast any restored timestamps so group members get our saved data.
        -- Stagger sends so replaceQueuedMessages doesn't discard earlier ones.
        CP.BroadcastRestoredTimestamps()
    end
end

--[[
    Broadcast all currently-known well timestamps to the group.
    Called once after protocol registration so restored saved-var data
    reaches other group members.  Each send is staggered by 2 seconds
    because the protocol uses replaceQueuedMessages = true which would
    discard unsent messages if queued too fast.
]]--
function CP.BroadcastRestoredTimestamps()
    if not wellProtocol then return end

    local queue = {}
    for idx, ts in pairs(wellTakenTimestamps) do
        table.insert(queue, { idx = idx, ts = ts })
    end
    if #queue == 0 then return end

    for i, entry in ipairs(queue) do
        zo_callLater(function()
            CP.BroadcastWellPickup(entry.idx, entry.ts)
        end, i * 2000)  -- 2s apart so each message is sent before the next replaces it
    end
end

--[[
    Broadcast a well pickup to the group.
    @param wellIndex  1-based well index
    @param timestamp  GetTimeStamp() value when the well was taken
]]--
function CP.BroadcastWellPickup(wellIndex, timestamp)
    if not wellProtocol then
        d("|c4592FF[Beltalowda]|r BroadcastWellPickup: wellProtocol is nil, cannot send")
        return
    end

    local elapsedMin = math.floor((GetTimeStamp() - timestamp) / 60)
    local ok = wellProtocol:Send({
        wellIndex = wellIndex - 1,  -- protocol uses 0-based
        elapsedMin = elapsedMin,
    })
    d("|c4592FF[Beltalowda]|r BroadcastWellPickup: well #" .. wellIndex
        .. " elapsed=" .. elapsedMin .. "m  sendOk=" .. tostring(ok))
end

-- ============================================================================
-- Settings controls
-- ============================================================================

function CP.GetSettingsControls()
    -- If LibMapPins isn't available, show an informational message instead
    if not LibMapPins then
        return {
            {
                type = "submenu",
                name = "|c4592FFCyrodiil Map Pins|r",
                tooltip = "Show Volendrung spawn locations and Ayleid Wells on the Cyrodiil map.",
                controls = {
                    {
                        type = "description",
                        text = "|cFF6600LibMapPins-1.0 is not installed.|r Install it from ESOUI.com to enable Cyrodiil map pin features (Volendrung spawns and Ayleid Wells).",
                        width = "full",
                    },
                },
            },
        }
    end

    return {
        {
            type = "submenu",
            name = "|c4592FFCyrodiil Map Pins|r",
            tooltip = "Show Volendrung spawn locations and Ayleid Wells on the Cyrodiil map.",
            controls = {
                {
                    type = "description",
                    text = "Adds custom pins to the Cyrodiil world map showing potential Volendrung spawn locations and Ayleid Well positions. Pins are also toggleable via the map's built-in filter panel.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Volendrung Spawns",
                    tooltip = "Display pins on the Cyrodiil map for known Volendrung spawn locations. By default, pins only appear while the artifact is spawned but not yet revealed — the brief window when the center-screen alert tells you the hammer has materialized but its location is still unknown. Hover a pin to see whether the location is confirmed, suspected, or unconfirmed.",
                    getFunc = function()
                        return BeltalowdaVars.toolbox.cyrodiilPins.volendrungEnabled
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.cyrodiilPins.volendrungEnabled = value
                        if LibMapPins then
                            LibMapPins:SetEnabled(PIN_TYPE_VOLENDRUNG, value)
                            LibMapPins:RefreshPins(PIN_TYPE_VOLENDRUNG)
                        end
                    end,
                    width = "full",
                    default = true,
                },
                {
                    type = "checkbox",
                    name = "Always Show Spawn Pins",
                    tooltip = "When enabled, Volendrung spawn pins are visible at all times on the Cyrodiil map regardless of the artifact's current state. When disabled (default), pins only appear during the brief window after the hammer spawns but before it is revealed on the map.",
                    getFunc = function()
                        return BeltalowdaVars.toolbox.cyrodiilPins.volendrungAlwaysShow
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.cyrodiilPins.volendrungAlwaysShow = value
                        if LibMapPins then
                            LibMapPins:RefreshPins(PIN_TYPE_VOLENDRUNG)
                        end
                    end,
                    width = "full",
                    default = false,
                    disabled = function()
                        return not BeltalowdaVars.toolbox.cyrodiilPins.volendrungEnabled
                    end,
                },
                {
                    type = "checkbox",
                    name = "Show Ayleid Wells",
                    tooltip = "Display pins on the Cyrodiil map for Ayleid Well locations. Wells grant 'Fortified Ayleid Well' (10% Health bonus for 30 minutes). A timer is shown in the tooltip after you pick one up.",
                    getFunc = function()
                        return BeltalowdaVars.toolbox.cyrodiilPins.wellsEnabled
                    end,
                    setFunc = function(value)
                        BeltalowdaVars.toolbox.cyrodiilPins.wellsEnabled = value
                        if LibMapPins then
                            LibMapPins:SetEnabled(PIN_TYPE_WELL, value)
                            LibMapPins:RefreshPins(PIN_TYPE_WELL)
                        end
                    end,
                    width = "full",
                    default = true,
                },
            },
        },
    }
end
