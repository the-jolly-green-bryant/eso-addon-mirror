-- TamrielSkyDial
-- A movable, scalable in-game time-of-day widget for The Elder Scrolls Online.
-- The dial shows an animated sun / moon / sky sprite for the current in-game
-- time, cross-fading between moods as the day turns. Time is read from
-- LibClockTST, the community's calibrated Tamriel Standard Time engine, so it
-- matches the actual sky. No weather (the ESO API does not expose it).
--
-- Built with AI assistance.

local ADDON = "TamrielSkyDial"
local TSD = {}
TSD.name = ADDON
_G[ADDON] = TSD

-- ---------------------------------------------------------------------------
-- Configuration
-- ---------------------------------------------------------------------------

-- Where the sliced .dds sprites live (relative to the ESO AddOns folder).
local TEX = "TamrielSkyDial/textures/"

-- Time bands, in 24h in-game hours. Edit here if you want different cutoffs.
-- night wraps midnight (>= NIGHT_START or < DAWN_START).
local DAWN_START = 4   -- 04:00 sunrise begins
local DAY_START  = 8   -- 08:00 full day
local DUSK_START = 18  -- 18:00 sunset begins
local NIGHT_START = 22 -- 22:00 night begins

-- Sprite files for the daytime bands.
local BAND_TEX = {
    dawn = TEX .. "dawn.dds",
    day  = TEX .. "day.dds",
    dusk = TEX .. "dusk.dds",
}

-- Night uses the moon. LibClockTST gives us the live phase; we map each phase
-- to one of the moon sprites you have art for. Unmapped phases fall back to
-- the nearest. Keys are lower-cased phase names.
local MOON_TEX = {
    ["new"]            = TEX .. "moon_crescent.dds",
    ["waxingcrescent"] = TEX .. "moon_crescent.dds",
    ["firstquarter"]   = TEX .. "moon_crescent.dds",
    ["waxinggibbous"]  = TEX .. "moon_full.dds",
    ["full"]           = TEX .. "moon_full.dds",
    ["waninggibbous"]  = TEX .. "moon_full.dds",
    ["lastquarter"]    = TEX .. "moon_crescent.dds",
    ["thirdquarter"]   = TEX .. "moon_crescent.dds",
    ["waningcrescent"] = TEX .. "moon_crescent.dds",
}
local MOON_FALLBACK = TEX .. "moon_full.dds"
-- Optional: swap this in for full-moon nights if you want the blood moon look.
-- local MOON_TEX["full"] = TEX .. "moon_blood.dds"

local BAR_TEX = TEX .. "bar.dds"

-- Bar is a 256x64 texture; keep it 4:1 on screen so the framed window stays square.
local BASE_BAR_W  = 184  -- on-screen bar width at scale 1.0
local BASE_BAR_H  = 46   -- 184 / 4, matches the bar texture aspect
local FADE_MS     = 1200 -- cross-fade duration in ms (raise = slower, lower = snappier)

-- The gold-framed window in bar.dds, as fractions of the 256x64 texture
-- (measured from the art). The dial fills this and sits BEHIND the frame.
local WIN_L, WIN_R  = 0.750, 0.992  -- window left / right edge
local WIN_T, WIN_B  = 0.031, 0.969  -- window top / bottom edge
local PLATE_CX      = 0.36          -- horizontal centre of the left text plate
local DIAL_OVERFLOW = 1.06          -- dial overspills the window slightly, tucked under the border

-- ---------------------------------------------------------------------------
-- Saved variables (defaults)
-- ---------------------------------------------------------------------------

local defaults = {
    posX = 40,
    posY = 40,
    scale = 1.0,
    opacity = 1.0,
    locked = false,
    timeFormat = "12h",   -- "12h" | "24h"
    showSeconds = false,
    subLabel = "dayNight", -- "none" | "dayNight" | "moonPhase" | "date"
    textX = 0,             -- time text horizontal offset (px at scale 1)
    textY = 0,             -- time text vertical offset (px at scale 1)
}
local sv

-- ---------------------------------------------------------------------------
-- Time helpers
-- ---------------------------------------------------------------------------

local function GetTST()
    -- LibClockTST is a hard dependency; Instance() gives the singleton.
    return LibClockTST and LibClockTST:Instance() or nil
end

local function CurrentBand(hour)
    if hour >= NIGHT_START or hour < DAWN_START then return "night" end
    if hour < DAY_START  then return "dawn" end
    if hour < DUSK_START then return "day"  end
    return "dusk"
end

local function MoonTextureFor(moon)
    if not moon then return MOON_FALLBACK end
    if moon.isFull then return MOON_TEX["full"] end
    local name = moon.currentPhaseName and string.lower(tostring(moon.currentPhaseName)) or ""
    name = name:gsub("%s+", "")
    return MOON_TEX[name] or MOON_FALLBACK
end

-- Which sprite should be showing right now, and a friendly label for it.
local function DesiredSprite(time, moon)
    local hour = time and time.hour or 0
    local band = CurrentBand(hour)
    if band == "night" then
        return MoonTextureFor(moon), "night"
    end
    return BAND_TEX[band], band
end

local PHASE_PRETTY = {
    ["new"]="New Moon", ["waxingcrescent"]="Waxing Crescent", ["firstquarter"]="First Quarter",
    ["waxinggibbous"]="Waxing Gibbous", ["full"]="Full Moon", ["waninggibbous"]="Waning Gibbous",
    ["lastquarter"]="Last Quarter", ["thirdquarter"]="Third Quarter", ["waningcrescent"]="Waning Crescent",
}

local function FormatTime(time)
    if not time then return "--:--" end
    local h, m, s = time.hour or 0, time.minute or 0, time.second or 0
    if sv.timeFormat == "24h" then
        if sv.showSeconds then return string.format("%02d:%02d:%02d", h, m, s) end
        return string.format("%02d:%02d", h, m)
    else
        local ampm = h < 12 and "AM" or "PM"
        local h12 = h % 12
        if h12 == 0 then h12 = 12 end
        if sv.showSeconds then return string.format("%d:%02d:%02d %s", h12, m, s, ampm) end
        return string.format("%d:%02d %s", h12, m, ampm)
    end
end

local MONTHS = {
    "Morning Star","Sun's Dawn","First Seed","Rain's Hand","Second Seed","Midyear",
    "Sun's Height","Last Seed","Hearthfire","Frostfall","Sun's Dusk","Evening Star",
}

local function SubLabelText(band, time, moon, date)
    if sv.subLabel == "none" then return "" end
    if sv.subLabel == "dayNight" then
        return band == "night" and "NIGHT" or "DAY"
    elseif sv.subLabel == "moonPhase" then
        if moon and moon.currentPhaseName then
            local key = string.lower(tostring(moon.currentPhaseName)):gsub("%s+","")
            return string.upper(PHASE_PRETTY[key] or tostring(moon.currentPhaseName))
        end
        return ""
    elseif sv.subLabel == "date" then
        if date and date.month and date.day then
            return string.format("%s %d", MONTHS[date.month] or "", date.day)
        end
        return ""
    end
    return ""
end

-- ---------------------------------------------------------------------------
-- UI
-- ---------------------------------------------------------------------------

local wm = WINDOW_MANAGER
local frame, bar, dialA, dialB, timeLabel, subLabel
local activeDial          -- the currently-visible dial texture
local currentTexFile      -- sprite path currently shown
local fadeStart, fadeFrom, fadeTo -- crossfade state

local function ApplyLayout()
    local scale = sv.scale
    local barW  = BASE_BAR_W * scale
    local barH  = BASE_BAR_H * scale

    frame:SetDimensions(barW, barH)
    frame:SetAlpha(sv.opacity)

    bar:SetDimensions(barW, barH)
    bar:ClearAnchors()
    bar:SetAnchor(TOPLEFT, frame, TOPLEFT, 0, 0)

    -- Dial fills the framed window (behind the bar) so the gold border contains it.
    local winCX = ((WIN_L + WIN_R) * 0.5) * barW
    local winCY = ((WIN_T + WIN_B) * 0.5) * barH
    local winW  = (WIN_R - WIN_L) * barW
    local winH  = (WIN_B - WIN_T) * barH
    local dialD = math.max(winW, winH) * DIAL_OVERFLOW
    for _, d in ipairs({dialA, dialB}) do
        d:SetDimensions(dialD, dialD)
        d:ClearAnchors()
        d:SetAnchor(CENTER, frame, TOPLEFT, winCX, winCY)
    end

    -- Time text: base left-offset position, plus your adjustable slider offsets.
    local baseY = (sv.subLabel == "none") and 0 or -(barH * 0.13)
    timeLabel:ClearAnchors()
    timeLabel:SetAnchor(LEFT, frame, LEFT,
        barH * 0.35 + sv.textX * scale,
        baseY + sv.textY * scale)
    subLabel:ClearAnchors()
    subLabel:SetAnchor(TOPLEFT, timeLabel, BOTTOMLEFT, 0, -2)
    subLabel:SetHidden(sv.subLabel == "none")
end

local function BuildUI()
    frame = wm:CreateTopLevelWindow(ADDON .. "Frame")
    frame:SetMouseEnabled(true)
    frame:SetMovable(not sv.locked)
    frame:SetClampedToScreen(true)
    frame:SetDimensions(BASE_BAR_W, BASE_BAR_H)
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.posX, sv.posY)
    frame:SetHandler("OnMoveStop", function()
        sv.posX = frame:GetLeft()
        sv.posY = frame:GetTop()
    end)

    -- Draw order, back to front: dial -> bar frame -> text. The dial sits BEHIND
    -- the bar and shows through its transparent window, so the border frames it.
    dialA = wm:CreateControl(ADDON .. "DialA", frame, CT_TEXTURE)
    dialB = wm:CreateControl(ADDON .. "DialB", frame, CT_TEXTURE)
    for _, d in ipairs({dialA, dialB}) do
        d:SetDrawLayer(DL_BACKGROUND)
        d:SetAlpha(0)
    end
    activeDial = dialA

    bar = wm:CreateControl(ADDON .. "Bar", frame, CT_TEXTURE)
    bar:SetTexture(BAR_TEX)
    bar:SetDrawLayer(DL_CONTROLS)   -- in front of the dial

    timeLabel = wm:CreateControl(ADDON .. "Time", frame, CT_LABEL)
    timeLabel:SetFont("ZoFontGameLargeBold")
    timeLabel:SetColor(1, 1, 1, 1)
    timeLabel:SetDrawLayer(DL_OVERLAY) -- on top of the plate
    timeLabel:SetText("--:--")

    subLabel = wm:CreateControl(ADDON .. "Sub", frame, CT_LABEL)
    subLabel:SetFont("ZoFontGameSmall")
    subLabel:SetColor(0.82, 0.74, 0.45, 1) -- soft gold, like the reference word
    subLabel:SetDrawLayer(DL_OVERLAY)
    subLabel:SetText("")

    ApplyLayout()
end

-- Instantly show a sprite (no fade), used on first load.
local function SetSpriteInstant(file)
    currentTexFile = file
    activeDial:SetTexture(file)
    activeDial:SetAlpha(1)
    local other = (activeDial == dialA) and dialB or dialA
    other:SetAlpha(0)
end

local FADE_KEY = ADDON .. "Fade"

-- Per-frame fade tick. Registered only while a fade is running (~60fps) so the
-- blend is smooth, instead of stepping in time with the once-a-second clock poll.
local function FadeTick()
    if not fadeTo then
        EVENT_MANAGER:UnregisterForUpdate(FADE_KEY)
        return
    end
    local t = (GetGameTimeMilliseconds() - fadeStart) / FADE_MS
    if t >= 1 then
        fadeTo:SetAlpha(1)
        fadeFrom:SetAlpha(0)
        activeDial = fadeTo
        fadeTo, fadeFrom = nil, nil
        EVENT_MANAGER:UnregisterForUpdate(FADE_KEY)
        return
    end
    local e = t * t * (3 - 2 * t)   -- smoothstep easing for a soft transition
    fadeTo:SetAlpha(e)
    fadeFrom:SetAlpha(1 - e)
end

-- Begin a cross-fade to a new sprite.
local function CrossfadeTo(file)
    if file == currentTexFile then return end
    -- If a previous fade is still mid-flight, snap it to its end first.
    if fadeTo then
        fadeTo:SetAlpha(1)
        fadeFrom:SetAlpha(0)
        activeDial = fadeTo
    end
    local incoming = (activeDial == dialA) and dialB or dialA
    incoming:SetTexture(file)
    incoming:SetAlpha(0)
    fadeFrom = activeDial
    fadeTo = incoming
    fadeStart = GetGameTimeMilliseconds()
    currentTexFile = file
    EVENT_MANAGER:UnregisterForUpdate(FADE_KEY)
    EVENT_MANAGER:RegisterForUpdate(FADE_KEY, 16, FadeTick) -- ~60fps while fading
end

-- ---------------------------------------------------------------------------
-- Main loop
-- ---------------------------------------------------------------------------

local function OnUpdate()
    local tst = GetTST()
    if not tst then return end

    local time = tst.GetTime and tst:GetTime() or nil
    local moon = tst.GetMoon and tst:GetMoon() or nil
    local date = tst.GetDate and tst:GetDate() or nil

    local file, band = DesiredSprite(time, moon)
    if file ~= currentTexFile then CrossfadeTo(file) end

    timeLabel:SetText(FormatTime(time))
    if sv.subLabel ~= "none" then
        subLabel:SetText(SubLabelText(band, time, moon, date))
    end
end

-- ---------------------------------------------------------------------------
-- Settings panel (LibAddonMenu-2.0)
-- ---------------------------------------------------------------------------

local function BuildSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panel = {
        type = "panel",
        name = "Tamriel Sky Dial",
        author = "You (art) + AI-assisted code",
        version = "1.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(ADDON .. "Panel", panel)

    local options = {
        { type = "header", name = "Appearance" },
        {
            type = "slider", name = "Scale", min = 50, max = 300, step = 5,
            getFunc = function() return sv.scale * 100 end,
            setFunc = function(v) sv.scale = v / 100 ApplyLayout() end,
            default = 100,
        },
        {
            type = "slider", name = "Opacity", min = 10, max = 100, step = 5,
            getFunc = function() return sv.opacity * 100 end,
            setFunc = function(v) sv.opacity = v / 100 frame:SetAlpha(v/100) end,
            default = 100,
        },
        {
            type = "slider", name = "Text offset X", min = -60, max = 60, step = 1,
            tooltip = "Move the time text left or right.",
            getFunc = function() return sv.textX end,
            setFunc = function(v) sv.textX = v ApplyLayout() end,
            default = 0,
        },
        {
            type = "slider", name = "Text offset Y", min = -30, max = 30, step = 1,
            tooltip = "Move the time text up or down.",
            getFunc = function() return sv.textY end,
            setFunc = function(v) sv.textY = v ApplyLayout() end,
            default = 0,
        },
        {
            type = "checkbox", name = "Lock position",
            tooltip = "Stops you dragging it by accident.",
            getFunc = function() return sv.locked end,
            setFunc = function(b) sv.locked = b frame:SetMovable(not b) end,
        },
        {
            type = "button", name = "Reset position",
            func = function()
                sv.posX, sv.posY = 40, 40
                frame:ClearAnchors()
                frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.posX, sv.posY)
            end,
        },
        { type = "header", name = "Readout" },
        {
            type = "dropdown", name = "Time format", choices = { "12 hour", "24 hour" },
            getFunc = function() return sv.timeFormat == "24h" and "24 hour" or "12 hour" end,
            setFunc = function(v) sv.timeFormat = (v == "24 hour") and "24h" or "12h" end,
        },
        {
            type = "checkbox", name = "Show seconds",
            getFunc = function() return sv.showSeconds end,
            setFunc = function(b) sv.showSeconds = b end,
        },
        {
            type = "dropdown", name = "Second line",
            tooltip = "The small line under the time (the reference showed weather here; ESO can't give weather, so pick what you like).",
            choices = { "Off", "Day / Night", "Moon phase", "Tamriel date" },
            getFunc = function()
                return ({ none = "Off", dayNight = "Day / Night", moonPhase = "Moon phase", date = "Tamriel date" })[sv.subLabel]
            end,
            setFunc = function(v)
                sv.subLabel = ({ ["Off"]="none", ["Day / Night"]="dayNight", ["Moon phase"]="moonPhase", ["Tamriel date"]="date" })[v]
                ApplyLayout()
            end,
        },
    }
    LAM:RegisterOptionControls(ADDON .. "Panel", options)
end

-- ---------------------------------------------------------------------------
-- Bootstrap
-- ---------------------------------------------------------------------------

local function OnLoaded(_, name)
    if name ~= ADDON then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide("TamrielSkyDial_SV", 1, nil, defaults)

    BuildUI()
    BuildSettings()

    -- Prime the first sprite instantly so there is no fade-in from nothing.
    local tst = GetTST()
    if tst then
        local file = DesiredSprite(tst.GetTime and tst:GetTime() or nil,
                                   tst.GetMoon and tst:GetMoon() or nil)
        SetSpriteInstant(file)
    end

    -- ~4 fps is plenty for a clock and keeps the fade smooth enough.
    EVENT_MANAGER:RegisterForUpdate(ADDON, 250, OnUpdate)

    SLASH_COMMANDS["/skydial"] = function()
        if LibAddonMenu2 then LibAddonMenu2:OpenToPanel(_G[ADDON .. "Panel"]) end
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, OnLoaded)
