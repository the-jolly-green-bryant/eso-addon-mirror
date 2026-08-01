-- =============================================================================
-- Under Pressure -- UI/Indicator.lua
-- =============================================================================
-- Drives the on-screen indicator.
--
-- The indicator is either a single "base" shape (green square, yellow ring,
-- yellow filled circle) or a vertical stack of 1, 2, or 3 same-size red
-- triangles. The base shape and triangle stack are pinned to the BOTTOM of
-- the root, so the column grows UPWARD as more triangles are added while
-- the bottom edge stays fixed on screen.
--
-- Counter: a single attacker count is drawn centered on the bottom indicator
-- tile. NPC/PLR split was removed in 0.2.6 because ESO console runtime does
-- not expose attacker source type.
--
-- Visibility: by default the indicator is hidden when the player is OUT of
-- combat or DEAD. The "Always show indicator" setting overrides both.
-- =============================================================================

UP = UP or {}
UP.UI = UP.UI or {}

local TEXTURE_PATH = "UnderPressure/UI/Textures/"

local TILE = 80
local ROOT_WIDTH = TILE

local MIN_COUNTER_SIZE = 14
local MAX_COUNTER_SIZE = 36
local DEFAULT_COUNTER_SIZE = 24

local BASE_TEXTURE = {
    green_square   = TEXTURE_PATH .. "green_square.dds",
    yellow_empty   = TEXTURE_PATH .. "yellow_empty.dds",
    yellow_filled  = TEXTURE_PATH .. "yellow_filled.dds",
}

local TRIANGLE_COUNT = {
    green_square   = 0,
    yellow_empty   = 0,
    yellow_filled  = 0,
    red_one        = 1,
    red_two        = 2,
    red_three      = 3,
}

local STATE_SEVERITY = {
    green_square   = 0,
    yellow_empty   = 1,
    yellow_filled  = 2,
    red_one        = 3,
    red_two        = 4,
    red_three      = 5,
}

local root, base, tris, counterLabel
local currentState = "green_square"
-- Latest known combat / alive state from the engine + event handlers, used
-- by UpdateVisibility() to decide whether to show the indicator.
local lastInCombat = false
local lastDead     = false

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function fontDescriptor(sizePx, withShadow)
    local size = math.floor(clamp(tonumber(sizePx) or DEFAULT_COUNTER_SIZE,
                                   MIN_COUNTER_SIZE, MAX_COUNTER_SIZE))
    local shadow = withShadow and "|soft-shadow-thick" or "|soft-shadow-thin"
    return ("$(MEDIUM_FONT)|%d%s"):format(size, shadow)
end

local function setHidden(ctrl, hidden)
    if ctrl and ctrl.SetHidden then ctrl:SetHidden(hidden) end
end

-- ---------------------------------------------------------------------------
-- State application (declared before Init so Init can call it)
-- ---------------------------------------------------------------------------
local function applyState(newState, force)
    if not force and newState == currentState then return end
    local triCount = TRIANGLE_COUNT[newState] or 0
    local baseTex  = BASE_TEXTURE[newState]

    if base then
        if baseTex then
            base:SetTexture(baseTex)
            base:SetHidden(false)
        else
            base:SetHidden(true)
        end
    end

    for i = 1, 3 do
        local t = tris[i]
        if t then t:SetHidden(i > triCount) end
    end

    local h = (triCount > 0) and (triCount * TILE) or TILE
    if root then root:SetDimensions(ROOT_WIDTH, h) end

    currentState = newState
end

-- ---------------------------------------------------------------------------
-- Visibility
-- ---------------------------------------------------------------------------
-- Decide whether the indicator should be visible right now.
--   * If "Always show" is on, show it (subject to manual hide setting).
--   * Otherwise show only when in combat AND alive.
local function shouldShow(sv)
    if sv.hidden == true then return false end  -- manual hide wins everything
    if sv.always_show == true then return true end
    if lastDead then return false end
    if not lastInCombat then return false end
    return true
end

function UP.UI.UpdateVisibility()
    if not root then return end
    local sv = UnderPressureSavedVars or {}
    root:SetHidden(not shouldShow(sv))
end

-- Inputs from the rest of the addon. Each updates the cache and re-evaluates.
function UP.UI.SetInCombat(inCombat)
    lastInCombat = inCombat == true
    UP.UI.UpdateVisibility()
end

function UP.UI.SetDead(isDead)
    lastDead = isDead == true
    UP.UI.UpdateVisibility()
end

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------
function UP.UI.Init()
    root = UP_IndicatorRoot
    if not root then
        d("[Under Pressure] Indicator root control missing.")
        return false
    end
    base = root:GetNamedChild("Base")
    tris = {
        root:GetNamedChild("Tri1"),
        root:GetNamedChild("Tri2"),
        root:GetNamedChild("Tri3"),
    }
    counterLabel = root:GetNamedChild("Counter")

    if base and base.SetColor then base:SetColor(1, 1, 1, 0.92) end
    for _, t in ipairs(tris) do
        if t then
            if t.SetColor then t:SetColor(1, 1, 1, 0.92) end
            t:SetHidden(true)
        end
    end
    if counterLabel then
        if counterLabel.SetColor then counterLabel:SetColor(1, 1, 1, 0.95) end
        counterLabel:SetText("0")
        counterLabel:SetHidden(true)
    end

    local sv = UnderPressureSavedVars or {}
    local x = sv.offset_x or 0
    local y = sv.offset_y or -140
    local scale = sv.scale or 1.0
    root:ClearAnchors()
    root:SetAnchor(BOTTOM, GuiRoot, CENTER, x, y)
    root:SetScale(scale)

    UP.UI.ApplyCounterFontSize(sv.counter_font_size or DEFAULT_COUNTER_SIZE)

    applyState("green_square", true)

    -- Seed alive state from the API if available; combat state will arrive
    -- via EVENT_PLAYER_COMBAT_STATE shortly after load.
    if type(IsUnitDead) == "function" then
        local ok, dead = pcall(IsUnitDead, "player")
        if ok then lastDead = dead == true end
    end
    UP.UI.UpdateVisibility()
    return true
end

-- ---------------------------------------------------------------------------
-- Counter
-- ---------------------------------------------------------------------------
-- Set the single attacker count. Hides the label when count is 0 or when
-- show_counter is off.
function UP.UI.SetCounter(count)
    if not counterLabel then return end
    local sv = UnderPressureSavedVars or {}
    if sv.show_counter == false then
        counterLabel:SetHidden(true)
        return
    end
    local n = tonumber(count) or 0
    if n == 0 then
        counterLabel:SetHidden(true)
        return
    end
    counterLabel:SetText(tostring(n))
    counterLabel:SetHidden(false)
end

function UP.UI.ApplyCounterFontSize(sizePx)
    local size = math.floor(clamp(tonumber(sizePx) or DEFAULT_COUNTER_SIZE,
                                   MIN_COUNTER_SIZE, MAX_COUNTER_SIZE))
    if counterLabel and counterLabel.SetFont then
        counterLabel:SetFont(fontDescriptor(size, true))
    end
    if counterLabel and counterLabel.SetDimensions then
        counterLabel:SetDimensions(math.max(60, size * 3), math.floor(size * 1.6))
    end
end

-- ---------------------------------------------------------------------------
-- State change with animation
-- ---------------------------------------------------------------------------
local function eachVisible(fn)
    if base and not base:IsHidden() then fn(base) end
    for _, t in ipairs(tris) do
        if t and not t:IsHidden() then fn(t) end
    end
end

local function pulseBrighten()
    eachVisible(function(c) c:SetColor(1, 1, 1, 1.0) end)
    zo_callLater(function()
        eachVisible(function(c) c:SetColor(1, 1, 1, 0.92) end)
    end, 180)
end

local function settleFade()
    eachVisible(function(c) c:SetColor(1, 1, 1, 0.70) end)
    zo_callLater(function()
        eachVisible(function(c) c:SetColor(1, 1, 1, 0.92) end)
    end, 220)
end

function UP.UI.SetState(newState)
    if newState == currentState then return end
    if not (BASE_TEXTURE[newState] or TRIANGLE_COUNT[newState]) then return end

    local oldSev = STATE_SEVERITY[currentState] or 0
    local newSev = STATE_SEVERITY[newState] or 0

    applyState(newState, false)

    if newSev > oldSev then
        pulseBrighten()
    elseif newSev < oldSev then
        settleFade()
    end
end

function UP.UI.SetVisible(visible)
    if root then root:SetHidden(not visible) end
end

function UP.UI.ApplyAnchor(offsetX, offsetY, scale)
    if not root then return end
    root:ClearAnchors()
    root:SetAnchor(BOTTOM, GuiRoot, CENTER, offsetX or 0, offsetY or -140)
    if scale then root:SetScale(scale) end
end
