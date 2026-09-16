-- Common Works — 3D world pins for uncollected Mages Guild lore books
--
-- Project uncollected Shalidor's Library books from LoreBooks' 2D data into
-- CrutchAlerts world icons. Both add-ons are required.
-- Pins follow player elevation: direction/distance are exact, height approximate.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

local EM = EVENT_MANAGER

-- NS_EVT stays enabled for rebuild triggers; NS_TICK stops when there is nothing to draw.
local NS_EVT  = CW.name .. "LoreBookPins"
local NS_TICK = CW.name .. "LoreBookPinsTick"

-- Eidetic Memory (category 3) is out of scope: thousands of books, most behind quests,
-- and LoreBooks stores it in a different shape.
local CATEGORY_SHALIDOR = 1

-- World units are centimetres; every setting the player sees is in metres.
local CM_PER_M = 100

-- One position read plus a squared-distance compare per book in the zone.
local TICK_MS = 100

-- Release pins 10m beyond the acquire radius to avoid texture churn at the boundary.
local RELEASE_MARGIN_M = 10

-- How far the player must move along an axis before two samples solve it. Normalized
-- coordinates run 0..1 across the map, so this is a few metres.
local CALIBRATION_DELTA = 0.005

-- World-unit tolerance for detecting a different coordinate space, not measuring precision.
local VALIDATION_TOLERANCE = 500

-- Fade nearby pins to avoid filling the screen; precompute for ~100 draws/second per pin.
local NEAR_FADE_M  = 3
local NEAR_FADE_CM = NEAR_FADE_M * CM_PER_M
local NEAR_FADE_SQ = NEAR_FADE_CM * NEAR_FADE_CM

-- Outside the near fade, so it reads as "you are here" while the pin is still opaque.
-- abs(sin) so the pin hops off the plane rather than sinking through the ground.
local ARRIVE_M    = 8
local ARRIVE_CM   = ARRIVE_M * CM_PER_M
local ARRIVE_SQ   = ARRIVE_CM * ARRIVE_CM
local BOUNCE_CM   = 40                      -- peak height of the hop
local BOUNCE_RATE = 2 * math.pi / 1400      -- radians per ms: about 1.4 hops a second

-- ESO multiplies texture color, so white takes the tint and black lines stay black.
-- These are white masks; "icon" instead uses each book's own untinted art.
local PIN_STYLES = {
    book    = "/esoui/art/zonestories/completiontypeicon_lorebooks.dds",
    diamond = "CrutchAlerts/assets/shape/diamond.dds",
}

-- In current-map units. LoreBooks lists a city's books on the city map and again, at
-- coarser precision, on the zone map; a zone point this close to the same book is that copy.
local SAME_SPOT = 0.02

-- State

-- Each pin: { nx, ny, collectionIndex, bookIndex, worldX, worldZ, iconKey, update }.
-- worldX/worldZ are nil until the transform is solved; iconKey is nil out of range.
local pins = {}
local pinMapId = nil

-- Two independent affine axes: worldX = ax * nx + bx, worldZ = az * ny + bz.
local ax, bx, az, bz

-- Anchor sample for the fallback calibration.
local anchorNx, anchorNy, anchorWx, anchorWz

-- Read height per frame: caching at 100ms made pins climb in steps on uneven ground.
-- GetFrameTimeMilliseconds is frame-constant, so all pins share the first read.
local frameStamp = -1
local fpX, fpY, fpZ = 0, 0, 0
local frameY, frameAlpha, frameBounce = 0, 1, 0

-- Refresh tint on the tick to update live pins without rebuilding or per-draw lookups.
local tintR, tintG, tintB
local arriveR, arriveG, arriveB

local ticking = false
local rebuildQueued = false

-- Validate host entry points for partial loads; return named diagnostic failures.
local function AvailabilityFaults()
    local faults = {}

    -- Check the data-loading global; the LoreBooks table exists before its data.
    if type(LoreBooks_GetLocalData) ~= "function" then
        faults[#faults + 1] = "LoreBooks missing"
    end

    if type(CrutchAlerts) ~= "table" then
        faults[#faults + 1] = "CrutchAlerts missing"
    elseif type(CrutchAlerts.Drawing) ~= "table" then
        faults[#faults + 1] = "CrutchAlerts.Drawing missing"
    elseif type(CrutchAlerts.Drawing.CreatePlacedIcon) ~= "function"
        or type(CrutchAlerts.Drawing.RemovePlacedIcon) ~= "function" then
        faults[#faults + 1] = "CrutchAlerts.Drawing API changed"
    end

    return faults
end

function CW.LoreBookPinsAvailable()
    return #AvailabilityFaults() == 0
end

-- GetCurrentMapId reports the displayed map. While it is open, decline to answer:
-- SetMapToPlayerLocation errors there and disturbs other pin add-ons.
local function CurrentMapId()
    if ZO_WorldMap_IsWorldMapShowing() then
        return nil
    end
    return GetCurrentMapId()
end

-- Solve from two GetRawNormalizedWorldPosition samples; its zone coordinates can differ
-- from LoreBooks' map coordinates in delves, towns and instances.
-- Validate against the player, falling back to movement samples.

local function Project()
    if not ax then return end
    for _, pin in ipairs(pins) do
        pin.worldX = ax * pin.nx + bx
        pin.worldZ = az * pin.ny + bz
    end
end

local function TryPrimaryTransform()
    local zone, pX, pY, pZ = GetUnitRawWorldPosition("player")
    if zone == 0 then return false end

    local n0x, n0y = GetRawNormalizedWorldPosition(zone, pX, pY, pZ)
    local n1x, n1y = GetRawNormalizedWorldPosition(zone, pX + CM_PER_M, pY, pZ + CM_PER_M)
    if not n0x or not n1x then return false end

    local dx, dy = n1x - n0x, n1y - n0y
    if dx == 0 or dy == 0 then return false end

    local cax = CM_PER_M / dx
    local cbx = pX - n0x * cax
    local caz = CM_PER_M / dy
    local cbz = pZ - n0y * caz

    -- Against the CURRENT MAP's normalized player position, the space LoreBooks'
    -- numbers actually live in.
    local mx, my = GetMapPlayerPosition("player")
    if math.abs((cax * mx + cbx) - pX) > VALIDATION_TOLERANCE then return false end
    if math.abs((caz * my + cbz) - pZ) > VALIDATION_TOLERANCE then return false end

    ax, bx, az, bz = cax, cbx, caz, cbz
    Project()
    return true
end

-- Called from the tick while the transform is unsolved.
local function StepCalibration()
    local mx, my = GetMapPlayerPosition("player")
    if mx == 0 and my == 0 then return end
    local _, pX, _, pZ = GetUnitRawWorldPosition("player")

    if not anchorNx then
        anchorNx, anchorNy, anchorWx, anchorWz = mx, my, pX, pZ
        return
    end

    -- Axes solve independently, so walking mostly north then mostly east works.
    if not ax and math.abs(mx - anchorNx) > CALIBRATION_DELTA then
        ax = (pX - anchorWx) / (mx - anchorNx)
        bx = pX - mx * ax
    end
    if not az and math.abs(my - anchorNy) > CALIBRATION_DELTA then
        az = (pZ - anchorWz) / (my - anchorNy)
        bz = pZ - my * az
    end

    if ax and az then
        Project()
    end
end

local function ResetTransform()
    ax, bx, az, bz = nil, nil, nil, nil
    anchorNx, anchorNy, anchorWx, anchorWz = nil, nil, nil, nil
end

-- Icons

local function ReleaseIcon(pin)
    if not pin.iconKey then return end
    CrutchAlerts.Drawing.RemovePlacedIcon(pin.iconKey)
    pin.iconKey = nil
end

local function ReleaseAll()
    for _, pin in ipairs(pins) do ReleaseIcon(pin) end
end

-- At most once per frame, hoisting the settings lookups out of the per-pin draws.
local function RefreshFrame()
    local t = GetFrameTimeMilliseconds()
    if t == frameStamp then return end
    frameStamp = t

    local _, x, y, z = GetUnitRawWorldPosition("player")
    fpX, fpY, fpZ = x, y, z
    frameY     = y + CW.SavedVars.loreBookPinHeight * CM_PER_M
    -- CrutchAlerts has a global opacity for placed icons; take it as the ceiling.
    local opts = CrutchAlerts.savedOptions
    local placed = opts and opts.drawing and opts.drawing.placedIcon
    frameAlpha = placed and tonumber(placed.opacity) or 1

    -- One sine for every arrived pin: they hop in unison and the cost does not scale.
    frameBounce = BOUNCE_CM * math.abs(math.sin(t * BOUNCE_RATE))
end

-- CrutchAlerts calls this ~100 times a second per pin, so it allocates nothing: no
-- tables, no varargs, no strings.
local function MakeUpdater(pin)
    return function(icon)
        RefreshFrame()

        -- Recomputed rather than reused from the tick, so the fade and bounce ramp as
        -- smoothly as the movement.
        local dx, dz = fpX - pin.worldX, fpZ - pin.worldZ
        local d2 = dx * dx + dz * dz

        local a = frameAlpha
        local y = frameY
        local r, g, b
        if pin.tinted then
            r, g, b = tintR, tintG, tintB
        else
            r, g, b = 1, 1, 1
        end

        if d2 < ARRIVE_SQ then
            -- Replace the tint outright so arrival color remains distinct.
            r, g, b = arriveR, arriveG, arriveB
            y = y + frameBounce

            if d2 < NEAR_FADE_SQ then
                a = a * (math.sqrt(d2) / NEAR_FADE_CM)
            end
        end

        icon:SetPosition(pin.worldX, y, pin.worldZ)
        icon:SetColor(r, g, b, a)
    end
end

local function TakeIcon(pin)
    if pin.iconKey then return end
    pin.iconKey = CrutchAlerts.Drawing.CreatePlacedIcon(
        pin.texture, pin.worldX, fpY, pin.worldZ, CW.SavedVars.loreBookPinSize, nil, pin.update)
end

-- Out-of-range books keep no texture/control; cost is one squared-distance comparison.
local QueueRebuild   -- forward declaration; defined below

local function Tick()
    -- Shares the draw path's cache, so the tick and the pins never disagree about
    -- where the player is. Acquire/release stays at 10Hz.
    RefreshFrame()
    local pX, pZ = fpX, fpZ

    tintR, tintG, tintB = unpack(CW.SavedVars.loreBookPinColor)
    arriveR, arriveG, arriveB = unpack(CW.SavedVars.loreBookPinArriveColor)

    -- Map open: nothing to see, and calibrating would read the browsed map.
    local mapId = CurrentMapId()
    if not mapId then ReleaseAll() return end
    -- Also catches a rebuild that ran while the map was open.
    if mapId ~= pinMapId then QueueRebuild() return end

    -- Walking due east solves X alone, so keep calibrating until both exist.
    if not (ax and az) then
        StepCalibration()
        if not (ax and az) then return end
    end

    local acquireM = CW.SavedVars.loreBookPinDistance * CM_PER_M
    local releaseM = (CW.SavedVars.loreBookPinDistance + RELEASE_MARGIN_M) * CM_PER_M
    local acquire2, release2 = acquireM * acquireM, releaseM * releaseM

    for _, pin in ipairs(pins) do
        if pin.worldX then
            local dx, dz = pX - pin.worldX, pZ - pin.worldZ
            local d2 = dx * dx + dz * dz
            if pin.iconKey then
                if d2 > release2 then ReleaseIcon(pin) end
            elseif d2 <= acquire2 then
                TakeIcon(pin)
            end
        end
    end
end

local function StartTicking()
    if ticking then return end
    ticking = true
    EM:RegisterForUpdate(NS_TICK, TICK_MS, Tick)
end

local function StopTicking()
    if not ticking then return end
    ticking = false
    EM:UnregisterForUpdate(NS_TICK)
end

-- Building the pin list

local function Rebuild()
    ReleaseAll()
    pins = {}
    pinMapId = nil
    ResetTransform()

    if not (CW.SavedVars.loreBookPins and CW.LoreBookPinsAvailable()) then
        StopTicking()
        return
    end

    local mapId = CurrentMapId()
    if not mapId then
        -- World map open, so the player's map is unknown. Keep ticking empty:
        -- pinMapId stays nil, so the tick's map check rebuilds when it closes.
        StartTicking()
        return
    end
    pinMapId = mapId

    -- A style in PIN_STYLES is a mask and gets the tint; anything else is the book's
    -- own coloured art, left alone.
    local styleTexture = PIN_STYLES[CW.SavedVars.loreBookPinStyle]

    local function AddPin(nx, ny, collectionIndex, bookIndex)
        if not (collectionIndex and bookIndex) then return end
        local _, icon, known = GetLoreBookInfo(CATEGORY_SHALIDOR, collectionIndex, bookIndex)
        if known then return end
        local pin = {
            nx              = nx,
            ny              = ny,
            collectionIndex = collectionIndex,
            bookIndex       = bookIndex,
            texture         = styleTexture
                              or (icon and icon ~= "" and icon)
                              or "/esoui/art/icons/quest_book_001.dds",
            tinted          = styleTexture ~= nil,
        }
        pin.update = MakeUpdater(pin)
        pins[#pins + 1] = pin
    end

    -- LoreBooks hands back its live internal tables. Read them, never write to them.
    for _, e in ipairs(LoreBooks_GetLocalData(mapId) or {}) do
        AddPin(e[1], e[2], e[3], e[4])
    end

    -- Inside a city the current map is the city's, so also take the surrounding zone's
    -- books, moved into city coordinates through the shared world space. Not
    -- GetParentZoneId: that would drop overland books into delves.
    local zoneMapId = GetMapIdByZoneId(GetZoneId(GetCurrentMapZoneIndex()))
    local zoneEntries = zoneMapId ~= mapId and LoreBooks_GetLocalData(zoneMapId)
    if zoneEntries then
        local cx, cy, cw, ch = GetUniversallyNormalizedMapInfo(mapId)
        local zx, zy, zw, zh = GetUniversallyNormalizedMapInfo(zoneMapId)
        local cityPins = #pins
        for _, e in ipairs(zoneEntries) do
            local nx, ny = (zx + e[1] * zw - cx) / cw, (zy + e[2] * zh - cy) / ch
            local copy = false
            for i = 1, cityPins do
                local p = pins[i]
                if p.bookIndex == e[4] and p.collectionIndex == e[3]
                    and math.abs(p.nx - nx) < SAME_SPOT and math.abs(p.ny - ny) < SAME_SPOT then
                    copy = true
                    break
                end
            end
            if not copy then AddPin(nx, ny, e[3], e[4]) end
        end
    end

    if #pins == 0 then
        StopTicking()
        return
    end

    -- Try for pins now; the tick falls back to walking calibration.
    TryPrimaryTransform()
    StartTicking()
end

-- Coalesced like CW.RedrawSoon: a zone transition fires several triggers at once
-- and should rebuild once.
QueueRebuild = function()
    if rebuildQueued then return end
    rebuildQueued = true
    zo_callLater(function()
        rebuildQueued = false
        Rebuild()
    end, 50)
end
CW.QueueLoreBookPinRebuild = QueueRebuild

-- Unregister first so load, activation and settings calls cannot accumulate listeners.
function CW.UpdateLoreBookPins()
    EM:UnregisterForEvent(NS_EVT, EVENT_PLAYER_ACTIVATED)
    EM:UnregisterForEvent(NS_EVT, EVENT_ZONE_CHANGED)
    EM:UnregisterForEvent(NS_EVT, EVENT_CURRENT_SUBZONE_LIST_CHANGED)
    EM:UnregisterForEvent(NS_EVT, EVENT_LORE_BOOK_LEARNED)

    if not (CW.SavedVars.loreBookPins and CW.LoreBookPinsAvailable()) then
        ReleaseAll()
        pins = {}
        pinMapId = nil
        StopTicking()
        return
    end

    EM:RegisterForEvent(NS_EVT, EVENT_PLAYER_ACTIVATED, QueueRebuild)
    EM:RegisterForEvent(NS_EVT, EVENT_ZONE_CHANGED,     QueueRebuild)
    EM:RegisterForEvent(NS_EVT, EVENT_CURRENT_SUBZONE_LIST_CHANGED, QueueRebuild)
    -- Reading a book drops its pin without a reload.
    EM:RegisterForEvent(NS_EVT, EVENT_LORE_BOOK_LEARNED, QueueRebuild)
    -- Queued, so activation's own EVENT_PLAYER_ACTIVATED rebuild merges with this one.
    QueueRebuild()
end
