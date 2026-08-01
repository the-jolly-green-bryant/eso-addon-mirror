local ADDON_NAME = "RaggszAttributes"     -- prefix for controls, events, saved vars
local MANIFEST_NAME = "raggsz-attributes" -- folder name EVENT_ADD_ON_LOADED reports

local RA = {} -- shared with settings.lua
_G[ADDON_NAME] = RA

-- Hot-path upvalues for the per-frame loop.
local sin, exp, abs = math.sin, math.exp, math.abs
local TWO_PI = 2 * math.pi
local GetGameTimeMilliseconds = GetGameTimeMilliseconds

-------------------------------------------------------------------------------
-- Data
-------------------------------------------------------------------------------

-- Left-to-right order, matching the ESO default.
RA.ATTRIBUTES = {
    { key = "magicka", powerType = POWERTYPE_MAGICKA },
    { key = "health",  powerType = POWERTYPE_HEALTH  },
    { key = "stamina", powerType = POWERTYPE_STAMINA },
}

-- Form bars under a primary column, shown only in that form. powerType may be nil
-- on a client; those entries are skipped at creation.
RA.SECONDARY = {
    { key = "werewolf", under = "magicka", powerType = POWERTYPE_WEREWOLF,
      event = EVENT_WEREWOLF_STATE_CHANGED, isActive = IsWerewolf },
    { key = "mount", under = "stamina", powerType = POWERTYPE_MOUNT_STAMINA,
      event = EVENT_MOUNTED_STATE_CHANGED, isActive = IsMounted },
}

-- $(BOLD_FONT) is the game's Univers 67. Per-attribute color is the only setting.
local FONT_PATH  = "$(BOLD_FONT)"
local FONT_SIZE  = 30
local FONT_STYLE = "thick-outline"

local function attrDefaults(r, g, b)
    return { color = { r = r, g = g, b = b, a = 1 } }
end

RA.defaults = {
    offsetX = 0,   -- pixels right of screen center (also horizontal nudge when docked)
    offsetY = 350, -- pixels below screen center (free placement only)
    dock = false,  -- anchor above the action bar instead of screen center
    dockGap = 42,  -- pixels the lowest element clears the action bar top
    liftClutter = true, -- lift prompts and the buff bar above the bars (docked only)
    -- raggszDefaults omitted on purpose: nil means first run (Initialize seeds it).
    spacing = 10,  -- gap between bars
    animate = true,
    showNumber = true,
    showBar = true,
    showFormBars = true,
    formBarRatio = 0.40, -- form bar height as a fraction of its column's bar
    barWidth = 120,      -- pixels
    barThickness = 2.0,  -- multiplier on the size-derived bar height
    barOnTop = true,
    showRate = true,
    intensity = 0.60,    -- resting number opacity; ramps to full by half, forced full in combat
    -- Vermillion, not pure red, to stay distinct from stamina's green for colorblindness.
    health  = attrDefaults(1, 90 / 255, 0),
    magicka = attrDefaults(0, 180 / 255, 1),
    stamina = attrDefaults(0, 1, 150 / 255),
    werewolf = { color = { r = 0.62, g = 0.36, b = 0.84, a = 1 } },
    mount    = { color = { r = 0.82, g = 0.69, b = 0.42, a = 1 } },
}

-- The author's layout. Applied for @raggsz on first run and by the "raggsz
-- defaults" toggle.
RA.PRESET = { dock = true, dockGap = 42, liftClutter = true }

function RA.ApplyPreset()
    for k, v in pairs(RA.PRESET) do RA.sv[k] = v end
end

-- @raggsz, with or without the leading @, case-insensitively.
local function IsAuthorAccount()
    local name = (GetDisplayName and GetDisplayName() or ""):gsub("^@", ""):lower()
    return name == "raggsz"
end

-------------------------------------------------------------------------------
-- Core
-------------------------------------------------------------------------------

-- "xx.xk"/"xx.xm": one decimal, two-or-more integer digits. A lone integer digit
-- is space-padded (" 9.5k") so the field width never jitters.
local function abbreviate(value, divisor, suffix)
    local s = string.format("%.1f", value / divisor)
    if #s < 4 then s = " " .. s end
    return s .. suffix
end

local function FormatValue(value)
    if value >= 1000000 then
        return abbreviate(value, 1000000, "m")
    end
    return abbreviate(value, 1000, "k")
end

-- Flash strength: 0 above PULSE_START_FRAC, ramping to full at PULSE_FULL_FRAC
-- (kept above empty so it warns before death).
local PULSE_START_FRAC = 0.50
local PULSE_FULL_FRAC  = 0.12

local function PulseStrength(current, maximum)
    if maximum <= 0 then return 0 end
    local fraction = current / maximum
    if fraction >= PULSE_START_FRAC then return 0 end
    return zo_clamp((PULSE_START_FRAC - fraction) / (PULSE_START_FRAC - PULSE_FULL_FRAC), 0, 1)
end

-- Opacity multiplier in [minProm, 1]: minProm at full, reaching 1 by FULL_OPACITY_FRAC.
local FULL_OPACITY_FRAC = 0.50

local function Prominence(current, maximum, minProm)
    if maximum <= 0 then return 1 end
    local fraction = current / maximum
    if fraction <= FULL_OPACITY_FRAC then return 1 end
    local t = (fraction - FULL_OPACITY_FRAC) / (1 - FULL_OPACITY_FRAC)
    return minProm + (1 - minProm) * (1 - t)
end

local function BuildFontString()
    return string.format("%s|%d|%s", FONT_PATH, FONT_SIZE, FONT_STYLE)
end

-- Flat bar: black backing + hairline edge, colored fill growing left-to-right.
local BAR_INSET         = 2
local BAR_BACKING_ALPHA = 0.6
local BAR_HEIGHT_FACTOR = 0.18 -- bar height per font point (before thickness)

-- Up/down arrows, shown while a regen or drain visual is active on the attribute.
local RATE_ARROW_UP   = "EsoUI/Art/Miscellaneous/list_sortUp.dds"
local RATE_ARROW_DOWN = "EsoUI/Art/Miscellaneous/list_sortDown.dds"

local PULSE_PERIOD  = 850  -- ms per flash cycle
local PULSE_AMP_MAX = 0.60 -- peak oscillation depth

-- Displayed value eases toward the real one (exponential ease-out), faster down than up.
local ANIM_TAU_DOWN  = 80   -- ms time constant falling (~250ms to settle)
local ANIM_TAU_UP    = 160  -- ms time constant rising (~500ms to settle)
local ANIM_SNAP_FRAC = 0.33 -- at/under this fraction, drops are instant


-------------------------------------------------------------------------------
-- Shell
-------------------------------------------------------------------------------

local container
local mover              -- backdrop marking the draggable area while unlocked
local labels = {}        -- key -> label { control, barFrame, barFill, indicator, target, displayed, ... }
local labelsByPower = {} -- powerType -> label
local secondaries = {}   -- key -> form bar
local secondaryUnder = {}-- column key -> its form bar
local inCombat = false

-- Hide the game's bars. Werewolf/mount get re-shown on form change, so this also
-- runs from those handlers.
local DEFAULT_BARS = { "Health", "Magicka", "Stamina", "Werewolf", "MountStamina" }
local function HideDefaultBars()
    for _, name in ipairs(DEFAULT_BARS) do
        local bar = _G["ZO_PlayerAttribute" .. name]
        if bar then bar:SetHidden(true) end
    end
end

local function ApplyAttributeStyle(label)
    local c = label.config.color
    label.control:SetFont(BuildFontString())
    label.barHeight = zo_max(5, zo_round(FONT_SIZE * BAR_HEIGHT_FACTOR * RA.sv.barThickness))
    label.barFrame:SetDimensions(RA.sv.barWidth, label.barHeight)
    local arrow = zo_max(8, zo_round(FONT_SIZE * 0.5))
    label.indicator:SetDimensions(arrow, arrow)
    label.r, label.g, label.b, label.a = c.r, c.g, c.b, c.a
end

-- Drain arrow takes priority over regen; alpha rides prominence.
local function UpdateIndicator(label)
    local dir = 0
    if RA.sv.showRate then
        if label.downCount > 0 then dir = -1
        elseif label.upCount > 0 then dir = 1 end
    end
    if dir == 0 then
        label.indicator:SetHidden(true)
        return
    end
    label.indicator:SetTexture(dir > 0 and RATE_ARROW_UP or RATE_ARROW_DOWN)
    label.indicator:SetColor(label.r, label.g, label.b, label.a * label.prom)
    label.indicator:SetHidden(false)
end

-- Bar outline: dim hairline above half; below half the bar's color, pulsing and
-- crossfading in with strength. `now` is the frame time, or read live when nil.
local function ApplyBarEdge(label, now)
    local s = label.pulseStrength
    if s <= 0 then
        label.barFrame:SetEdgeTexture("", 8, 8, 1)
        label.barFrame:SetEdgeColor(0, 0, 0, BAR_BACKING_ALPHA * label.prom)
        return
    end
    local amp = PULSE_AMP_MAX * s
    local phase = ((now or GetGameTimeMilliseconds()) / PULSE_PERIOD) % 1
    local osc = (1 - amp) + amp * (0.5 + 0.5 * sin(phase * TWO_PI))
    local dim = BAR_BACKING_ALPHA * label.prom
    label.barFrame:SetEdgeTexture("", 8, 8, 2)
    label.barFrame:SetEdgeColor(label.r * s, label.g * s, label.b * s, (dim * (1 - s) + s) * osc)
end

-- Full repaint from the displayed (eased) value.
local function DrawAttribute(label, now)
    local sv = RA.sv
    local shown = label.displayed
    local prom = inCombat and 1 or Prominence(shown, label.maximum, sv.intensity)
    label.prom = prom
    label.pulseStrength = PulseStrength(shown, label.maximum)
    label.control:SetHidden(not sv.showNumber)
    if sv.showNumber then
        label.control:SetText(FormatValue(shown))
        label.control:SetColor(label.r, label.g, label.b, label.a * prom)
    end

    if sv.showBar then
        label.barFrame:SetHidden(false)
        label.barFrame:SetCenterColor(0, 0, 0, BAR_BACKING_ALPHA * prom)
        ApplyBarEdge(label, now)
        local fraction = label.maximum > 0 and zo_clamp(shown / label.maximum, 0, 1) or 0
        local innerW = zo_max(0, sv.barWidth - BAR_INSET * 2)
        local innerH = zo_max(1, label.barHeight - BAR_INSET * 2)
        label.barFill:SetDimensions(innerW * fraction, innerH)
        label.barFill:SetCenterColor(label.r, label.g, label.b, label.a * prom)
    else
        label.barFrame:SetHidden(true)
    end

    UpdateIndicator(label)
end

-- Per-frame loop; registered only while something is easing or pulsing.
local animating = false
local lastFrameMs

local function AnimationUpdate()
    local now = GetGameTimeMilliseconds()
    local dt = now - (lastFrameMs or now)
    lastFrameMs = now
    local active = false
    for _, label in pairs(labels) do
        local moving = label.displayed ~= label.target
        if moving then
            local diff = label.target - label.displayed
            local tau = diff < 0 and ANIM_TAU_DOWN or ANIM_TAU_UP
            label.displayed = label.displayed + diff * (1 - exp(-dt / tau))
            if abs(label.target - label.displayed) <= (label.maximum * 0.002 + 0.5) then
                label.displayed = label.target -- snap and stop
            end
            DrawAttribute(label, now) -- moved: full repaint
        elseif label.pulseStrength > 0 then
            ApplyBarEdge(label, now)  -- only pulsing: edge alone changes
        end
        if label.displayed ~= label.target or label.pulseStrength > 0 then active = true end
    end
    if not active then
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "Anim")
        animating = false
        lastFrameMs = nil
    end
end

local function EnsureAnimating()
    if animating then return end
    animating = true
    lastFrameMs = nil
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "Anim", 0, AnimationUpdate)
end

local function MaybeAnimate()
    for _, label in pairs(labels) do
        if label.displayed ~= label.target or label.pulseStrength > 0 then
            EnsureAnimating()
            return
        end
    end
end

local function DrawSecondary(sec)
    local sv = RA.sv
    if not (sec.active and sv.showFormBars) then
        sec.frame:SetHidden(true)
        return
    end
    sec.frame:SetHidden(false)
    local c = sv[sec.def.key].color
    local frac = sec.maximum > 0 and zo_clamp(sec.current / sec.maximum, 0, 1) or 0
    local innerW = zo_max(0, sv.barWidth - BAR_INSET * 2)
    local innerH = zo_max(1, sec.height - BAR_INSET * 2)
    sec.fill:SetDimensions(innerW * frac, innerH)
    sec.fill:SetCenterColor(c.r, c.g, c.b, c.a)
end

local dockTarget      -- the action bar while docked, else nil; for SavePosition and the lifts
local dockBelowCenter -- distance from the bars (container center) to the lowest drawn element

-- Prompts and the buff bar are pinned to screen bottom, the same band docking
-- puts our bars in. Re-anchor each above the stack; restore the captured original
-- when off. tier stacks them so they don't overlap (prompts share a slot, so sit
-- together; buff bar a row up). The game re-pins on platform change, so this also
-- runs from a SYNERGY:ApplyTextStyle hook and on player-activated.
local LIFT_GAP    = 4
local LIFT_TIER_H = 44 -- vertical step per tier (~one prompt row)
local LIFTS = {
    { control = "ZO_SynergyTopLevelContainer",        tier = 0 }, -- "use synergy"
    { control = "ZO_ActiveCombatTipsTip",             tier = 0 }, -- "hold to block" etc.
    { control = "ZO_BuffDebuffTopLevelSelfContainer", tier = 1 }, -- player buff bar
}
local liftOrig = {} -- control name -> captured original anchor

local function ApplyLifts()
    local lift = RA.sv.dock and RA.sv.liftClutter and dockTarget
    for _, def in ipairs(LIFTS) do
        local c = _G[def.control]
        if c then
            if not liftOrig[def.control] then
                local ok, point, relTo, relPoint, x, y = c:GetAnchor(0)
                if ok then liftOrig[def.control] = { point, relTo, relPoint, x, y } end
            end
            c:ClearAnchors()
            if lift then
                c:SetAnchor(BOTTOM, container, TOP, 0, -(LIFT_GAP + def.tier * LIFT_TIER_H))
            else
                local a = liftOrig[def.control]
                if a then c:SetAnchor(a[1], a[2], a[3], a[4], a[5]) end
            end
        end
    end
end

local function LayoutContainer()
    local sv = RA.sv
    local barH = labels.health.barHeight
    local formH = sv.showFormBars and (zo_round(barH * sv.formBarRatio) + 2) or 0

    -- Distance from the bars (container center) down to the lowest drawn element:
    -- the numbers when below the bars, else the bars/form bars. Docking hugs the
    -- target by this real extent, not the symmetric drag padding, so numbers never
    -- sink into a stacked bar.
    dockBelowCenter = barH / 2 + formH
    if sv.barOnTop then dockBelowCenter = dockBelowCenter + 3 + FONT_SIZE end

    container:ClearAnchors()
    dockTarget = sv.dock and _G["ZO_ActionBar1"] or nil
    if dockTarget then
        -- Lowest element rides dockGap above the action bar's top; offsetX nudges.
        container:SetAnchor(CENTER, dockTarget, TOP, sv.offsetX, -(sv.dockGap + dockBelowCenter))
    else
        container:SetAnchor(CENTER, GuiRoot, CENTER, sv.offsetX, sv.offsetY)
    end

    -- Fixed-width bars drive the layout; each number hangs off its own bar, so
    -- spacing never depends on text width.
    local hb = labels.health.barFrame
    local mb = labels.magicka.barFrame
    local sb = labels.stamina.barFrame
    local gap = sv.spacing

    hb:ClearAnchors()
    mb:ClearAnchors()
    sb:ClearAnchors()
    hb:SetAnchor(CENTER, container, CENTER, 0, 0)
    mb:SetAnchor(RIGHT, hb, LEFT, -gap, 0)
    sb:SetAnchor(LEFT, hb, RIGHT, gap, 0)

    for key, label in pairs(labels) do
        local bottom = label.barFrame -- lowest element this column hangs under
        local sec = secondaryUnder[key]
        if sec then
            sec.height = zo_max(3, zo_round(label.barHeight * sv.formBarRatio))
            sec.frame:SetDimensions(sv.barWidth, sec.height)
            sec.frame:ClearAnchors()
            sec.frame:SetAnchor(TOP, label.barFrame, BOTTOM, 0, 2)
            DrawSecondary(sec)
            if sec.active and sv.showFormBars then bottom = sec.frame end
        end
        label.control:ClearAnchors()
        if sv.barOnTop then
            label.control:SetAnchor(TOP, bottom, BOTTOM, 0, 3)
        else
            label.control:SetAnchor(BOTTOM, label.barFrame, TOP, 0, -3)
        end
    end

    -- Size the container (the drag handle) to the contents. Bars sit at its center,
    -- so the height is symmetric and generous enough to cover the number either side.
    container:SetDimensions(sv.barWidth * 3 + sv.spacing * 2, barH + 2 * (formH + FONT_SIZE + 6))

    ApplyLifts() -- keep lifted prompts/buffs riding above the stack
end

-- Re-read settings and repaint; the settings menu calls this after a change.
function RA.RefreshStyle()
    for _, label in pairs(labels) do
        ApplyAttributeStyle(label)
        if not RA.sv.animate then label.displayed = label.target end
        DrawAttribute(label)
    end
    LayoutContainer()
    MaybeAnimate()
end

local function CreateSecondary(def)
    if not def.powerType then return end -- constant absent on this client
    local frame = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "_" .. def.key .. "Bar", container, CT_BACKDROP)
    frame:SetCenterColor(0, 0, 0, BAR_BACKING_ALPHA)
    frame:SetEdgeColor(0, 0, 0, BAR_BACKING_ALPHA)
    frame:SetEdgeTexture("", 8, 8, 1)
    frame:SetHidden(true)

    local fill = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "_" .. def.key .. "BarFill", frame, CT_BACKDROP)
    fill:SetEdgeTexture("", 1, 1, 0)
    fill:SetEdgeColor(0, 0, 0, 0)
    fill:SetAnchor(LEFT, frame, LEFT, BAR_INSET, 0)

    local sec = { def = def, frame = frame, fill = fill, active = false, current = 0, maximum = 0, height = 4 }
    secondaries[def.key] = sec
    secondaryUnder[def.under] = sec

    local function OnPower(_, _, _, pool, poolMax)
        sec.current, sec.maximum = pool, poolMax
        DrawSecondary(sec)
    end
    local handler = ZO_MostRecentPowerUpdateHandler:New(ADDON_NAME .. "Sec" .. def.key, OnPower)
    handler:AddFilterForEvent(REGISTER_FILTER_POWER_TYPE, def.powerType)
    handler:AddFilterForEvent(REGISTER_FILTER_UNIT_TAG, "player")
end

local function CreateLabel(attr)
    local control = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "_" .. attr.key, container, CT_LABEL)
    control:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    control:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local barFrame = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "_" .. attr.key .. "Bar", container, CT_BACKDROP)
    barFrame:SetEdgeTexture("", 8, 8, 1)

    local barFill = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "_" .. attr.key .. "BarFill", barFrame, CT_BACKDROP)
    barFill:SetEdgeTexture("", 1, 1, 0)
    barFill:SetEdgeColor(0, 0, 0, 0)
    barFill:SetAnchor(LEFT, barFrame, LEFT, BAR_INSET, 0)

    local indicator = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "_" .. attr.key .. "Rate", container, CT_TEXTURE)
    indicator:SetAnchor(RIGHT, control, LEFT, -6, 0)
    indicator:SetHidden(true)

    local label = {
        control   = control,
        barFrame  = barFrame,
        barFill   = barFill,
        indicator = indicator,
        config    = RA.sv[attr.key],
        target    = 0, -- real current power
        displayed = 0, -- eased value drawn
        maximum   = 0,
        upCount   = 0, -- active increased-regen visuals
        downCount = 0, -- active decreased-regen visuals
        prom      = 1,
        pulseStrength = 0,
    }
    labels[attr.key] = label
    labelsByPower[attr.powerType] = label
    ApplyAttributeStyle(label)

    local function OnPowerUpdate(_, _, _, powerPool, powerPoolMax)
        label.target = powerPool
        label.maximum = powerPoolMax

        local dropping = powerPool < label.displayed
        if not RA.sv.animate
            or (dropping and powerPoolMax > 0 and powerPool <= powerPoolMax * ANIM_SNAP_FRAC) then
            label.displayed = powerPool -- instant: animation off, or a drop into low territory
        end
        DrawAttribute(label)
        MaybeAnimate()
    end

    local handler = ZO_MostRecentPowerUpdateHandler:New(ADDON_NAME .. attr.key, OnPowerUpdate)
    handler:AddFilterForEvent(REGISTER_FILTER_POWER_TYPE, attr.powerType)
    handler:AddFilterForEvent(REGISTER_FILTER_UNIT_TAG, "player")

    return label
end

-- Bulk re-sync (login, zone, combat, res); snaps displayed to target, never eases.
local function RefreshAll()
    HideDefaultBars()
    for key, label in pairs(labels) do
        label.target, label.maximum = GetUnitPower("player", RA.ATTRIBUTES_BY_KEY[key].powerType)
        label.displayed = label.target
        DrawAttribute(label)
    end
    -- Re-validate form state: zoning/porting can drop werewolf/mount without firing
    -- the state-changed event (e.g. forced out of form on entering a town).
    local relayout = false
    for _, sec in pairs(secondaries) do
        local active = (sec.def.isActive and sec.def.isActive()) and true or false
        if active ~= sec.active then relayout = true end
        sec.active = active
        if sec.active then sec.current, sec.maximum = GetUnitPower("player", sec.def.powerType) end
        DrawSecondary(sec)
    end
    if relayout then LayoutContainer() end
    MaybeAnimate() -- a synced value may already be below half and want to pulse
end

local function SavePosition()
    local sv = RA.sv
    local cx = container:GetLeft() + container:GetWidth() / 2
    if dockTarget then
        -- Horizontal nudge off the bar's center; vertical drag becomes the clearance
        -- of the lowest drawn element above the action bar's top.
        local cyc = container:GetTop() + container:GetHeight() / 2
        local tx = dockTarget:GetLeft() + dockTarget:GetWidth() / 2
        sv.offsetX = zo_round(cx - tx)
        sv.dockGap = zo_max(0, zo_round(dockTarget:GetTop() - cyc - dockBelowCenter))
    else
        local cy = container:GetTop() + container:GetHeight() / 2
        sv.offsetX = zo_round(cx - GuiRoot:GetWidth() / 2)
        sv.offsetY = zo_round(cy - GuiRoot:GetHeight() / 2)
    end
end

-- SetInUIMode surfaces a cursor so the HUD frame can be grabbed.
function RA.SetUnlocked(unlocked)
    RA.unlocked = unlocked
    container:SetMovable(unlocked)
    container:SetMouseEnabled(unlocked)
    mover:SetHidden(not unlocked)
    SCENE_MANAGER:SetInUIMode(unlocked)
end

local function Initialize()
    RA.sv = ZO_SavedVars:NewAccountWide("RaggszAttributesSavedVars", 1, nil, RA.defaults)

    -- First run: turn the preset on for @raggsz and apply it. Thereafter the saved
    -- choice persists and the settings toggle governs it.
    if RA.sv.raggszDefaults == nil then
        RA.sv.raggszDefaults = IsAuthorAccount()
        if RA.sv.raggszDefaults then RA.ApplyPreset() end
    end

    RA.ATTRIBUTES_BY_KEY = {}
    for _, attr in ipairs(RA.ATTRIBUTES) do
        RA.ATTRIBUTES_BY_KEY[attr.key] = attr
    end

    container = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "Container")
    container:SetHandler("OnMoveStop", SavePosition) -- dimensions set by LayoutContainer

    mover = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "Mover", container, CT_BACKDROP)
    mover:SetAnchorFill(container)
    mover:SetCenterColor(0, 0, 0, 0.4)
    mover:SetEdgeColor(1, 1, 1, 0.4)
    mover:SetEdgeTexture("", 8, 8, 1)
    mover:SetHidden(true)

    for _, attr in ipairs(RA.ATTRIBUTES) do
        CreateLabel(attr)
    end
    for _, def in ipairs(RA.SECONDARY) do
        CreateSecondary(def)
    end

    -- Seed form state and track it; the handler re-hides the game's bar too.
    for _, def in ipairs(RA.SECONDARY) do
        local sec = secondaries[def.key]
        if sec then
            sec.active = (def.isActive and def.isActive()) and true or false
            if sec.active then sec.current, sec.maximum = GetUnitPower("player", def.powerType) end
            if def.event then
                EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. def.key, def.event, function(_, state)
                    sec.active = state and true or false
                    if sec.active then sec.current, sec.maximum = GetUnitPower("player", def.powerType) end
                    HideDefaultBars()
                    LayoutContainer()
                end)
            end
        end
    end

    -- Re-apply the lifts after the game re-pins these controls on platform changes.
    if SYNERGY and ZO_PostHook then
        ZO_PostHook(SYNERGY, "ApplyTextStyle", ApplyLifts)
    end

    LayoutContainer()

    -- Show only on the HUD; the game hides it in menus, dialogs, etc.
    local fragment = ZO_SimpleSceneFragment:New(container)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    SIEGE_BAR_SCENE:AddFragment(fragment)
    SIEGE_BAR_UI_SCENE:AddFragment(fragment)

    HideDefaultBars()

    -- A load screen can tear down regen/drain visuals without firing REMOVED, which
    -- leaves the arrow counters stuck. Clear them on activation; the game re-fires
    -- ADDED for anything still active, and RefreshAll repaints the (now hidden) arrows.
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        for _, label in pairs(labels) do label.upCount, label.downCount = 0, 0 end
        RefreshAll()
        ApplyLifts() -- a load screen can re-pin the lifted controls
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ALIVE, RefreshAll)

    inCombat = IsUnitInCombat("player")
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, function(_, combat)
        inCombat = combat
        RefreshAll()
        ApplyLifts() -- player buffs (automatic mode) first render on combat entry
    end)

    -- Reference-count the game's regen/drain visuals to drive the change arrows.
    local function onVisual(add)
        return function(_, _, visual, _, _, powerType)
            local label = labelsByPower[powerType]
            if not label then return end
            local delta = add and 1 or -1
            if visual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER then
                label.upCount = zo_max(0, label.upCount + delta)
            elseif visual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
                label.downCount = zo_max(0, label.downCount + delta)
            else
                return
            end
            UpdateIndicator(label)
        end
    end
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "VisAdd", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, onVisual(true))
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "VisAdd", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "VisRem", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, onVisual(false))
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "VisRem", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, "player")

    if RA.SetupSettings then
        RA.SetupSettings()
    end

    RefreshAll()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, name)
    if name ~= MANIFEST_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    Initialize()
end)
