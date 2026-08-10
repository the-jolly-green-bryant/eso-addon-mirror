---------------------------------------------------------------
-- CritMarker
-- Customizable FPS-style hitmarker for critical hits, PvP killing
-- blows and duel wins. Final public release 1.0.16
--
-- 1.0.16 vs 1.0.15:
--   * real fix for the reset slider refresh: the panel is now
--     registered with registerForRefresh = true, the flag LAM
--     requires before it tracks controls and fires the
--     LAM-RefreshPanel callback (LibAddonMenu-2.0.lua:253/263)
--   * without it panel:RefreshPanel() silently no-op'd - that's
--     why the slider kept showing its stale value
--   * style picker rebuilt as clickable texture galleries (now 24
--     styles, spread across the full menu width): LAM2 dropdowns
--     cannot show icons, so thumbnails were the only visual option;
--     the selected style is at full opacity, the rest are dimmed
--   * settings menu restructured: on/off switch on top of each
--     section, Test buttons at the bottom, Test Render section gone
--   * gallery hover tooltips and marker preview on pick removed
--   * announcer pops in larger on every streak (bigger pops for
--     higher multipliers, KILLIONAIRE the biggest pop) and shows a
--     live countdown of the chain time left under the text (green,
--     red in the last second)
-- 1.0.15 vs 1.0.14:
--   * Reset Announcer Position now refreshes the LAM panel the right
--     way (panel:RefreshPanel -> UpdateValue on all controls), so
--     the font-size slider visibly snaps back to 44
--   * announcer text stays up for the full 4 s streak window:
--     when it disappears you know the chain has expired
-- 1.0.14 vs 1.0.13:
--   * Reset Announcer Position now refreshes the LAM panel
--     (LAM:OpenToPanel) so the font-size slider shows the restored
--     default instead of a stale value
-- 1.0.13 vs 1.0.12:
--   * announcer rebuilt on the proven CombatStatus pattern:
--     native SetMovable dragging + OnMoveStop position save
--     (no custom cursor code), label auto-sized to the text so
--     nothing can clip at any font size, $(BOLD_FONT) glyphs
--   * Show While Configuring now directly locks/unlocks dragging
--     via SetMovable
-- 1.0.12 vs 1.0.11:
--   * fixed drag error: CursorX/CursorY are not ESO functions;
--     positions now come from ZO_CURSOR converted to GuiRoot
--     (scaled) space so dragging tracks the mouse correctly
-- 1.0.11 vs 1.0.10:
--   * announcer window re-fits itself whenever the font size changes,
--     so large text can no longer get clipped
--   * dragging is manual and locked: only movable while Show While
--     Configuring is on, position saved on release (locked after)
--   * Reset Announcer Position also restores the default font size
-- 1.0.10 vs 1.0.9:
--   * fixed load error: SetLayerLevel is not an ESO API method
--     (removed; SetDrawLayer(2) keeps the announcer on top alone)
--   * announcer text now prefixes the streak: "2x Double Kill!",
--     "3x Triple Kill!" ... "10x KILLIONAIRE!!"
-- 1.0.9 vs 1.0.8:
--   * announcer text is now its own top-level window: drag it
--     anywhere (position auto-saved), font size slider, custom
--     color wheel + per-tier colors, show-while-configuring and
--     reset-position helpers
--   * rendered on its own layer so the text can never be covered
-- 1.0.8 vs 1.0.7:
--   * MLG test button announces on every press: it jumps straight to
--     Double Kill instead of a silent first kill, so the tiers are
--     visible immediately; real kills keep the silent single-kill
-- 1.0.7 vs 1.0.6:
--   * MLG Test Kill button: simulates killing blows (flash + sound +
--     one streak step) to preview tiers by spamming
--   * streak restarts at one after KILLIONAIRE instead of repeating
-- 1.0.6 vs 1.0.5:
--   * MLG Announcer mode: Halo-style kill streak text (Double Kill
--     .. KILLIONAIRE), chained on kills within 4 s; resets on timeout
--     or death; off by default
-- 1.0.5 vs 1.0.4:
--   * kill dedup no longer rate-limits distinct kills: every kill
--     flashes (burst kills stack their sounds into one boosted blast;
--     spaced-out kills flash per kill); same-victim spam still capped
--   * duel wins no longer double-flash from the shared kill events
-- 1.0.4 vs 1.0.3:
--   * unified kill dedup: kill feed + combat event + duel finish all
--     gate on one track so each kill flashes the marker exactly once
--   * distinct kills still flash (250 ms min spacing, 1.5 s same-victim)
-- 1.0.3 vs 1.0.2:
--   * Sound Boost replays the sound simultaneously so the layered
--     copies stack and sound louder (previously staggered 35 ms)
-- 1.0.2 vs 1.0.1:
--   * fixed: kill-color migration erased its own value (old/new key
--     were identical) leaving the kill marker tinted like the crit one
--   * ApplyModeColor falls back to each marker's own default color if
--     the stored value is ever missing/invalid
-- 1.0.1 vs 1.0.0:
--   * Test buttons fire a live marker (full animation + sound)
--   * style dropdowns preview statically, silently
--   * color dropdowns replaced by color wheels + Rainbow toggles
--     (old named-color settings migrate automatically)
-- 1.0.0 (refactor, no behaviour changes):
--   * texture style tables generated in a loop
--   * hot globals cached in upvalues (PlaySound, GetRawUnitName ...)
--   * prettified settings panel; /critmarker slash command
--   * release-ready metadata in CritMarker.txt
---------------------------------------------------------------
local EM = EVENT_MANAGER

local ADDON_NAME = "CritMarker"
local PANEL_ID   = "CritMarker_Settings"
local SV_NAME    = "CritMarker_SV"
local SV_VERSION = 1 -- keep: color migration is manual, a version bump would wipe user settings
local VERSION    = "1.0.16"

local zo_callLater                = zo_callLater
local zo_removeCallLater          = zo_removeCallLater
local PlaySoundFn                 = PlaySound
local GetRawUnitNameFn            = GetRawUnitName
local GetUnitNameFn               = GetUnitName
local GetDisplayNameFn            = GetDisplayName
local GetFrameTimeMillisecondsFn  = GetFrameTimeMilliseconds

local CritMarker = {
    name    = ADDON_NAME,
    version = VERSION,
    SV      = nil,
    ui      = nil,
}

local CRIT = "Crit"
local KILL = "Kill"

-- Halo-style announcer tiers: streak count -> text + color.
local MLG_4S = 4000
local MLG_TIERS = {
    [2]  = { "Double Kill!",   { 0.35, 1,    0.45 } },
    [3]  = { "Triple Kill!",   { 0.3,  0.95, 1    } },
    [4]  = { "Overkill!",      { 1,    0.75, 0.25 } },
    [5]  = { "Killtacular!",   { 1,    0.45, 0.2  } },
    [6]  = { "Killtrocity!",   { 1,    0.35, 0.6  } },
    [7]  = { "Killamanjaro!",  { 0.8,  0.3,  1    } },
    [8]  = { "Killtastrophe!", { 1,    0.2,  0.2  } },
    [9]  = { "Killpocalypse!", { 1,    0.9,  0.15 } },
    [10] = { "KILLIONAIRE!!",  { 1,    0.1,  0.1  } },
}

CritMarker.defaults = {
    critTexture    = "Style1",
    killTexture    = "Style1",
    critEnabled    = true,
    killEnabled    = true,
    critColor      = { 1, 1, 1 },
    killColor      = { 1, 0.2, 0.2 },
    critRainbow    = false,
    killRainbow    = false,
    critSize       = 32,
    killSize       = 32,
    critSound      = "Hard Hit",
    killSound      = "Crunch",
    critSoundBoost = 1,
    killSoundBoost = 1,
}

---------------------------------------------------------------
-- Texture styles: "StyleN" selects hitmarker(N).dds. The first one
-- matches the unnumbered hitmarker.dds.
---------------------------------------------------------------
local NUM_TEXTURES = 24
CritMarker.TEXTURE_OPTIONS = {}
CritMarker.texLookup = {}
for i = 1, NUM_TEXTURES do
    CritMarker.TEXTURE_OPTIONS[i] = "Style" .. i
    CritMarker.texLookup["Style" .. i] =
        (i == 1) and "hitmarker.dds" or ("hitmarker" .. i .. ".dds")
end

CritMarker.SOUND_OPTIONS = { "None", "Soft Hit", "Hard Hit", "Bleed", "Crunch" }
CritMarker.soundLookup = {
    ["Soft Hit"] = SOUNDS.DEFAULT_CLICK,
    ["Hard Hit"] = SOUNDS.ABILITY_PICKED_UP,
    ["Bleed"]    = SOUNDS.BOOK_OPEN,
    ["Crunch"]   = SOUNDS.LOCKPICKING_UNLOCKED,
}

CritMarker.colorLookup = {
    White  = { 1,     1,     1 },
    Black  = { 0,     0,     0 },
    Red    = { 1,     0.2,   0.2 },
    Orange = { 1,     0.5,   0.1 },
    Yellow = { 1,     0.9,   0.2 },
    Green  = { 0.2,   1,     0.3 },
    Blue   = { 0.2,   0.6,   1 },
    Purple = { 0.7,   0.3,   1 },
    Pink   = { 1,     0.4,   0.7 },
}

CritMarker.rainbowColors = {
    { 1, 1, 1 },      -- white
    { 1, 0.2, 0.2 },  -- red
    { 1, 0.9, 0.2 },  -- yellow
    { 0.2, 1, 0.3 },  -- green
    { 0.2, 0.6, 1 },  -- blue
    { 0.7, 0.3, 1 },  -- purple
    { 1, 0.5, 0.1 },  -- orange
    { 1, 0.4, 0.7 },  -- pink
}

---------------------------------------------------------------
-- Marker engine
---------------------------------------------------------------
local Marker = {}
Marker.__index = Marker

function Marker:New(owner)
    local o = setmetatable({}, self)
    o.owner            = owner
    o.window           = nil
    o.texture          = nil
    o.hideTimer        = nil
    o.scaleTimer       = nil
    o.fadeTimer        = nil
    o.rainbowIndex     = 1
    o.lastKillTime     = 0
    o.lastKillTag      = nil
    o:CreateWindow()
    return o
end

function Marker:CreateWindow()
    local SV = self.owner.SV
    self.window = WINDOW_MANAGER:CreateTopLevelWindow("CritMarker_UI")
    self.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    self.window:SetDimensions(SV.critSize, SV.critSize)
    self.window:SetHidden(true)

    self.texture = WINDOW_MANAGER:CreateControl(nil, self.window, CT_TEXTURE)
    self.texture:SetAnchorFill(self.window)
    self.texture:SetBlendMode(TEX_BLEND_MODE_ALPHA)

    self:SetTexture(CRIT)
end

function Marker:ClearTimer(field)
    local id = self[field]
    if id then
        zo_removeCallLater(id)
        self[field] = nil
    end
end

-- Assign the correct texture file for the given render mode.
function Marker:SetTexture(mode)
    local key = (mode == KILL) and self.owner.SV.killTexture or self.owner.SV.critTexture
    local file = self.owner.texLookup[key]
    if file then
        self.texture:SetTexture("CritMarker/" .. file)
    end
end

function Marker:ApplySize(mode)
    local size = (mode == KILL) and self.owner.SV.killSize or self.owner.SV.critSize
    self.window:SetDimensions(size, size)
end

-- Apply the color for the given marker mode: rainbow cycle when enabled,
-- otherwise the color-wheel value. Falls back to that mode's own default
-- so the two markers can never tint each other.
function Marker:ApplyModeColor(mode)
    local SV = self.owner.SV
    local rainbow = (mode == KILL) and SV.killRainbow or SV.critRainbow
    if rainbow then
        local c = self.owner.rainbowColors[self.rainbowIndex]
        self.texture:SetColor(c[1], c[2], c[3], 1)
        self.rainbowIndex = (self.rainbowIndex % #self.owner.rainbowColors) + 1
        return
    end
    local c = (mode == KILL) and SV.killColor or SV.critColor
    if not c or not c[1] then
        c = self.owner.defaults[(mode == KILL) and "killColor" or "critColor"]
    end
    if c then
        self.texture:SetColor(c[1], c[2], c[3], 1)
    end
end

function Marker:PlaySelectedSound(mode)
    local SV = self.owner.SV
    local soundName = (mode == KILL) and SV.killSound or SV.critSound
    local boost     = (mode == KILL) and SV.killSoundBoost or SV.critSoundBoost
    if not soundName or soundName == "None" then return end

    local id = self.owner.soundLookup[soundName]
    if not id then return end

    if not boost or boost <= 1 then
        PlaySoundFn(id)
        return
    end
    -- Replay the sound `boost` times in the same frame: the layered
    -- copies play simultaneously and stack into a louder hit.
    for i = 1, boost do
        PlaySoundFn(id)
    end
end

function Marker:ResetTimers()
    self:ClearTimer("scaleTimer")
    self:ClearTimer("fadeTimer")
    self:ClearTimer("hideTimer")
end

-- Spawn animation: scale overshoot, dim, then hide.
function Marker:RunAnimation(mode, preview, duration)
    duration = duration or 140
    self.texture:SetAlpha(1)
    self.window:SetHidden(false)
    if preview then
        self.window:SetScale(1)
    else
        self.window:SetScale((mode == KILL) and 1.75 or 1.5)
        self.scaleTimer = zo_callLater(function()
            if self.window then self.window:SetScale(1) end
            self.scaleTimer = nil
        end, 75)
        self.fadeTimer = zo_callLater(function()
            if self.texture then self.texture:SetAlpha(0.4) end
            self.fadeTimer = nil
        end, 60)
    end
    self.hideTimer = zo_callLater(function()
        if self.window then
            self.window:SetHidden(true)
            self.window:SetScale(1)
            if self.texture then self.texture:SetAlpha(1) end
        end
        self.hideTimer = nil
    end, duration)
end

function Marker:Show(mode, force, duration, preview, playSound)
    if not force then
        local enabled = (mode == KILL) and self.owner.SV.killEnabled
                                         or self.owner.SV.critEnabled
        if not enabled then return end
    end
    self:ApplySize(mode)
    self:SetTexture(mode)
    self:ResetTimers()
    self:ApplyModeColor(mode)
    if playSound ~= false then self:PlaySelectedSound(mode) end
    self:RunAnimation(mode, preview, duration)
end

---------------------------------------------------------------
-- Combat handlers (live in the marker object like pre-1.0)
---------------------------------------------------------------
function Marker:HandleCombatCrit()
    self:Show(CRIT)
end

-- Unified kill-show gate. A single kill can arrive through several
-- events (combat killing blow, zone kill feed); same-victim repeats
-- within 1.5 s are suppressed, but every distinct kill flashes, no
-- matter how quickly they follow each other.
function Marker:ShouldShowKill(tag)
    local now = GetFrameTimeMillisecondsFn()
    local dt  = now - self.lastKillTime
    if dt < 1500 and tag == self.lastKillTag then return false end
    self.lastKillTag  = tag
    self.lastKillTime = now
    self:HandleAnnouncer()
    return true
end

-- MLG streak logic: every distinct kill chains if it lands within 4 s
-- of the previous one, otherwise the chain restarts at 1. Chains of
-- 2+ announce; reaching KILLIONAIRE (10) restarts the counter at 1 so
-- the next kill begins a fresh chain.
function Marker:HandleAnnouncer(force)
    if not force and not self.owner.SV.mlgEnabled then return end
    local now = GetFrameTimeMillisecondsFn()
    if now > self.owner.mlgDeadline then
        self.owner.mlgStreak = 0
    end
    self.owner.mlgStreak = self.owner.mlgStreak + 1
    -- In test mode every press announces: a chain's first kill is
    -- silent in real play, but the preview button jumps straight to
    -- Double Kill so the tiers are visible immediately.
    if force and self.owner.mlgStreak == 1 then
        self.owner.mlgStreak = 2
    end
    self.owner.mlgDeadline = now + MLG_4S
    if self.owner.mlgStreak >= 10 then
        self.owner:Announce(10)
        self.owner.mlgStreak = 0
        return
    end
    if self.owner.mlgStreak >= 2 then
        self.owner:Announce(self.owner.mlgStreak)
    end
end

function Marker:HandlePvPKill(_, killerPlayerDisplayName, killerCharacterName,
                              _, _, victimPlayerDisplayName, victimCharacterName)
    local myChar = GetRawUnitNameFn(GetUnitNameFn("player"))
    local myAcc  = GetDisplayNameFn()
    if killerCharacterName ~= myChar and killerPlayerDisplayName ~= myAcc then return end
    if victimCharacterName == myChar or victimPlayerDisplayName == myAcc then return end
    if self:ShouldShowKill(victimCharacterName) then self:Show(KILL) end
end

function Marker:HandleDuelWin()
    local now = GetFrameTimeMillisecondsFn()
    if (now - self.lastKillTime) < 1500 then return end
    if self:ShouldShowKill("duel") then self:Show(KILL) end
end

-- Combat-event fallback for kills the kill feed may not report.
function Marker:HandleUniversalKill(targetName)
    local tag = (targetName == nil or targetName == "") and "unknown" or targetName
    if self:ShouldShowKill(tag) then self:Show(KILL) end
end

---------------------------------------------------------------
-- Saved vars
---------------------------------------------------------------
local function EnsureDefault(key, value)
    if CritMarker.SV[key] == nil then CritMarker.SV[key] = value end
end

function CritMarker:InitSavedVars()
    self.SV = ZO_SavedVars:NewAccountWide(SV_NAME, SV_VERSION, nil, self.defaults)

    -- One-time migration from the pre-1.0 single-texture field.
    if self.SV.texture and self.texLookup[self.SV.texture] then
        EnsureDefault("critTexture", self.SV.texture)
        EnsureDefault("killTexture", self.SV.texture)
        self.SV.texture = nil
    end
    EnsureDefault("critTexture",    "Style1")
    EnsureDefault("killTexture",    "Style1")
    EnsureDefault("critSound",      "Hard Hit")
    EnsureDefault("killSound",      "Crunch")
    EnsureDefault("critSize",       32)
    EnsureDefault("killSize",       32)
    EnsureDefault("critSoundBoost", 1)
    EnsureDefault("killSoundBoost", 1)
    EnsureDefault("critEnabled",    true)
    EnsureDefault("killEnabled",    true)
    EnsureDefault("critColor",      { 1, 1, 1 })
    EnsureDefault("killColor",      { 1, 0.2, 0.2 })
    EnsureDefault("critRainbow",    false)
    EnsureDefault("killRainbow",    false)
    EnsureDefault("mlgEnabled",     false)
    EnsureDefault("mlgX",               0)
    EnsureDefault("mlgY",               -170)
    EnsureDefault("mlgFontSize",        44)
    EnsureDefault("announcerColor",     { 1, 1, 1 })
    EnsureDefault("announcerUseTierColors", true)
    EnsureDefault("mlgShowAlways",      false)

    -- One-time migration from named color strings ("Red", "Rainbow" ...)
    -- to the color-wheel RGBA values + rainbow toggles of 1.0.1.
    -- Note: for the kill color the old and new key are the same, so the
    -- cleanup below must NOT run after the assignment (it would erase the
    -- value we just wrote).
    local function MigrateNamedColor(oldKey, newKey, rainbowKey)
        local named = self.SV[oldKey]
        if type(named) ~= "string" then return end
        if named == "Rainbow" then
            self.SV[rainbowKey] = true
            self.SV[newKey] = { 1, 1, 1 }
        else
            local c = self.colorLookup[named]
            if c then self.SV[newKey] = { c[1], c[2], c[3] } end
        end
        if oldKey ~= newKey then
            self.SV[oldKey] = nil
        end
    end
    MigrateNamedColor("color",    "critColor", "critRainbow")
    MigrateNamedColor("killColor", "killColor", "killRainbow")
end

---------------------------------------------------------------
-- Settings menu
---------------------------------------------------------------
local function BuildMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local addon = CritMarker
    local SV    = addon.SV
    local ui    = addon.ui
    local wm    = WINDOW_MANAGER

    -- LAM2's dropdown renders plain text only (r43 has no icon/entry
    -- template support), so the 24 texture styles are picked from a
    -- clickable thumbnail gallery instead: one cell per style, the
    -- selected one at full opacity (rest dimmed).
    local GALLERY_COLS  = 6
    local GALLERY_CELL  = 44
    local GALLERY_PITCH = 50
    local GALLERY_PAD   = 8
    local GALLERY_ROWS  = math.ceil(NUM_TEXTURES / GALLERY_COLS)
    local GALLERY_H     = 24 + GALLERY_ROWS * GALLERY_PITCH

    local function CreateStyleGallery(parent, targetKey, title)
        local label = wm:CreateControl(nil, parent, CT_LABEL)
        label:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 2)
        label:SetFont("ZoFontGameSmall")
        label:SetText(("|cBFC2D6%s — click a style to select it|r"):format(title))

        -- Distribute the cells evenly over the full menu width so the
        -- gallery fills the row instead of leaving dead space on the
        -- right; falls back to the fixed pitch if the width is not
        -- known yet.
        local panelW = parent:GetWidth()
        local useFullWidth = panelW and panelW > GALLERY_COLS * GALLERY_PITCH
        local pitchX = useFullWidth and ((panelW - 2 * GALLERY_PAD) / GALLERY_COLS) or GALLERY_PITCH
        local gridW  = useFullWidth and panelW or (GALLERY_COLS * GALLERY_PITCH)

        local grid = wm:CreateControl(nil, parent, CT_CONTROL)
        grid:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 22)
        grid:SetDimensions(gridW, GALLERY_ROWS * GALLERY_PITCH)

        local cells = {}
        local function Refresh()
            local current = SV[targetKey]
            for i = 1, NUM_TEXTURES do
                cells[i]:SetAlpha(current == addon.TEXTURE_OPTIONS[i] and 1 or 0.55)
            end
        end

        for i = 1, NUM_TEXTURES do
            local cellX = GALLERY_PAD + ((i - 1) % GALLERY_COLS) * pitchX
            if useFullWidth then
                cellX = cellX + (pitchX - GALLERY_CELL) / 2
            end
            local cell = wm:CreateControl(nil, grid, CT_CONTROL)
            cell:SetAnchor(TOPLEFT, grid, TOPLEFT, cellX,
                math.floor((i - 1) / GALLERY_COLS) * GALLERY_PITCH)
            cell:SetDimensions(GALLERY_CELL, GALLERY_CELL)
            cell:SetMouseEnabled(true)

            local img = wm:CreateControl(nil, cell, CT_TEXTURE)
            img:SetAnchor(CENTER, cell, CENTER, 0, 0)
            img:SetDimensions(GALLERY_CELL - 8, GALLERY_CELL - 8)
            img:SetTexture("CritMarker/" .. addon.texLookup[addon.TEXTURE_OPTIONS[i]])

            local name = addon.TEXTURE_OPTIONS[i]
            cell:SetHandler("OnMouseUp", function()
                SV[targetKey] = name
                Refresh()
            end)

            cells[i] = img
        end

        Refresh()
    end

    local panel = LAM:RegisterAddonPanel(PANEL_ID, {
        type         = "panel",
        name         = "CritMarker",
        displayName  = "|cFF3B3BCritMarker|r",
        author       = "|cADFF2F@Ruptxre|r & |c00FFFF@Sikma|r",
        version      = addon.version,
        slashCommand = "/critmarker",
        -- Required for panel:RefreshPanel() to work: without this flag
        -- LAM never registers the refresh callback nor tracks controls
        -- (LibAddonMenu-2.0.lua:253, 263; controls/panel.lua:161).
        registerForRefresh = true,
    })

    local options = {
        { type = "header", name = "|cFF3B3BGeneral|r" },
        { type = "divider" },
        {
            type = "description",
            text = "|cBFC2D6Fight-style hitmarker: spawns in the center of the " ..
                   "screen on critical hits and player-killing blows, marquee-" ..
                   "style, with an optional layered sound. The Test buttons fire " ..
                   "a live marker (full animation + sound); the style galleries " ..
                   "show every texture side by side — click one to pick it|r",
        },

        { type = "header", name = "|cFF3B3BCrit Hitmarker|r" },
        { type = "divider" },
        {
            type = "checkbox",
            name = "Enable Crit Hitmarker",
            tooltip = "Show the marker whenever you land a critical hit.",
            getFunc = function() return SV.critEnabled end,
            setFunc = function(v) SV.critEnabled = v end,
        },
        {
            type = "custom",
            minHeight = GALLERY_H,
            createFunc = function(control)
                CreateStyleGallery(control, "critTexture", "Critmarker Style")
            end,
        },
        {
            type = "colorpicker",
            name = "Critmarker Color",
            tooltip = "Color wheel for the crit marker tint.",
            getFunc = function()
                return SV.critColor[1], SV.critColor[2], SV.critColor[3], 1
            end,
            setFunc = function(r, g, b, a)
                SV.critColor = { r, g, b }
            end,
        },
        {
            type = "checkbox",
            name = "Critmarker Rainbow Mode",
            tooltip = "Cycle through rainbow colors on every crit marker; " ..
                      "overrides the wheel color while on.",
            getFunc = function() return SV.critRainbow end,
            setFunc = function(v) SV.critRainbow = v end,
        },
        {
            type = "slider",
            name = "Critmarker Size",
            tooltip = "Pixel size of the crit hitmarker.",
            min = 24, max = 128, step = 2,
            getFunc = function() return SV.critSize end,
            setFunc = function(v)
                SV.critSize = v
                ui:ApplySize(CRIT)
            end,
        },
        {
            type = "dropdown",
            name = "Critmarker Sound",
            tooltip = "Sound effect played on a critical hit.",
            choices = addon.SOUND_OPTIONS,
            getFunc = function() return SV.critSound end,
            setFunc = function(v) SV.critSound = v end,
        },
        {
            type = "slider",
            name = "Critmarker Sound Boost",
            tooltip = "Repeat the hit sound this many times, played simultaneously so it stacks louder.",
            min = 1, max = 10, step = 1,
            getFunc = function() return SV.critSoundBoost end,
            setFunc = function(v) SV.critSoundBoost = v end,
        },
        {
            type = "button",
            name = "Test Crit Hitmarker",
            tooltip = "Fire a live crit marker with its full animation and sound.",
            func  = function() ui:Show(CRIT, true) end,
        },

        { type = "header", name = "|cFF3B3BPvP Killmarker|r" },
        { type = "divider" },
        {
            type = "checkbox",
            name = "Enable PvP Killmarker",
            tooltip = "Show the kill marker on player killing blows, " ..
                      "including duel wins.",
            getFunc = function() return SV.killEnabled end,
            setFunc = function(v) SV.killEnabled = v end,
        },
        {
            type = "custom",
            minHeight = GALLERY_H,
            createFunc = function(control)
                CreateStyleGallery(control, "killTexture", "Killmarker Style")
            end,
        },
        {
            type = "colorpicker",
            name = "Killmarker Color",
            tooltip = "Color wheel for the kill marker tint.",
            getFunc = function()
                return SV.killColor[1], SV.killColor[2], SV.killColor[3], 1
            end,
            setFunc = function(r, g, b, a)
                SV.killColor = { r, g, b }
            end,
        },
        {
            type = "checkbox",
            name = "Killmarker Rainbow Mode",
            tooltip = "Cycle through rainbow colors on every kill marker; " ..
                      "overrides the wheel color while on.",
            getFunc = function() return SV.killRainbow end,
            setFunc = function(v) SV.killRainbow = v end,
        },
        {
            type = "slider",
            name = "Killmarker Size",
            tooltip = "Pixel size of the kill hitmarker.",
            min = 24, max = 128, step = 2,
            getFunc = function() return SV.killSize end,
            setFunc = function(v)
                SV.killSize = v
                ui:ApplySize(KILL)
            end,
        },
        {
            type = "dropdown",
            name = "Killmarker Sound",
            tooltip = "Sound effect played on a player-killing blow.",
            choices = addon.SOUND_OPTIONS,
            getFunc = function() return SV.killSound end,
            setFunc = function(v) SV.killSound = v end,
        },
        {
            type = "slider",
            name = "Killmarker Sound Boost",
            tooltip = "Repeat the kill sound this many times, played simultaneously so it stacks louder.",
            min = 1, max = 10, step = 1,
            getFunc = function() return SV.killSoundBoost end,
            setFunc = function(v) SV.killSoundBoost = v end,
        },
        {
            type = "button",
            name = "Test PvP Killmarker",
            tooltip = "Fire a live kill marker with its full animation and sound.",
            func  = function() ui:Show(KILL, true) end,
        },

        { type = "header", name = "|cFFFF00MLG Announcer|r" },
        { type = "divider" },
        {
            type = "checkbox",
            name = "Enable MLG Announcer",
            tooltip = "Announce 2+ kill streaks with Halo-style text above " ..
                      "the hitmarker.",
            getFunc = function() return SV.mlgEnabled end,
            setFunc = function(v) SV.mlgEnabled = v end,
        },
        {
            type = "description",
            text = "|cFFE88AHalo-style kill streak announcer. Each player kill " ..
                   "starts a 4 second chain window; another kill inside it " ..
                   "bumps the streak: Double Kill, Triple Kill, Overkill, " ..
                   "Killtacular, Killtrocity, Killamanjaro, Killtastrophe, " ..
                   "Killpocalypse and finally KILLIONAIRE, after which the " ..
                   "counter restarts at one. The chain resets when 4 seconds " ..
                   "pass without a kill, or when you die; a countdown under " ..
                   "the text shows the time left, and each new streak pops " ..
                   "in larger — higher multipliers pop harder, KILLIONAIRE " ..
                   "the hardest. The Test button simulates kills so you can " ..
                   "preview the tiers.|r",
        },
        {
            type = "button",
            name = "Test MLG Kill",
            tooltip = "Simulate one killing blow: fires the kill marker, its " ..
                      "sound, and steps the announcer chain. Spam it within " ..
                      "4 seconds to walk through the tiers (works even with " ..
                      "the announcer toggled off).",
            func = function() addon:TestMLG() end,
        },

        { type = "header", name = "|cFFFFFFAnnouncer Display|r" },
        { type = "divider" },
        {
            type = "description",
            text = "|cBFC2D6The announcer is its own window. Drag the text " ..
                   "anywhere on screen (position saves automatically), size " ..
                   "it with the slider, tint it or keep the per-tier colors. " ..
                   "A small countdown under the text ticks down the time " ..
                   "left before the chain falls off (green, red in the " ..
                   "last second).|r",
        },
        {
            type = "checkbox",
            name = "Show While Configuring",
            tooltip = "Keep the announcer text visible and unlock it for " ..
                      "dragging. Turn it off after you placed it to lock " ..
                      "its position.",
            getFunc = function() return SV.mlgShowAlways end,
            setFunc = function(v)
                SV.mlgShowAlways = v
                if addon.announcerWnd then addon.announcerWnd:SetMovable(v) end
                if v then
                    addon:Announce(2, true)
                elseif addon.announcerWnd then
                    addon.announcerWnd:SetHidden(true)
                end
            end,
        },
        {
            type = "slider",
            name = "Announcer Font Size",
            tooltip = "Size of the announcer text (pixels).",
            min = 16, max = 120, step = 2,
            getFunc = function() return SV.mlgFontSize end,
            setFunc = function(v)
                SV.mlgFontSize = v
                addon:ApplyAnnouncerStyle()
            end,
        },
        {
            type = "colorpicker",
            name = "Announcer Text Color",
            tooltip = "Custom color used when tier colors are off.",
            getFunc = function()
                return SV.announcerColor[1], SV.announcerColor[2], SV.announcerColor[3], 1
            end,
            setFunc = function(r, g, b, a)
                SV.announcerColor = { r, g, b }
                addon:ApplyAnnouncerStyle()
            end,
        },
        {
            type = "checkbox",
            name = "Use Tier Colors",
            tooltip = "Color each streak tier Halo-style (green Double Kill, " ..
                      "red KILLIONAIRE). Off uses your custom color.",
            getFunc = function() return SV.announcerUseTierColors end,
            setFunc = function(v)
                SV.announcerUseTierColors = v
                addon:ApplyAnnouncerStyle()
            end,
        },
        {
            type = "button",
            name = "Reset Announcer Position",
            tooltip = "Snap the announcer window back above the hitmarker " ..
                      "and restore the default font size.",
            func = function()
                addon:ResetAnnouncerPosition()
                -- LAM sliders only re-read their value on a panel
                -- refresh, so tell the panel to UpdateValue all of
                -- its controls (shows the restored size).
                if panel then panel:RefreshPanel() end
            end,
        },
    }

    LAM:RegisterOptionControls(PANEL_ID, options)
end

---------------------------------------------------------------
-- Life cycle
---------------------------------------------------------------
-- Test hook: simulate one killing blow (marker flash + sound + one
-- announcer step) so the MLG tiers can be previewed by spamming.
function CritMarker:TestMLG()
    self.ui:Show(KILL, true)
    self.ui:HandleAnnouncer(true)
end

function CritMarker:CreateModules()
    self.ui = Marker:New(self)
    self.ui:ApplySize(CRIT)
    self:CreateAnnouncer()
end

function CritMarker:CreateAnnouncer()
    local SV = self.SV
    local wnd = WINDOW_MANAGER:CreateTopLevelWindow("CritMarker_MLG_Announcer")
    wnd:SetDimensions(320, 90)
    wnd:SetAnchor(CENTER, GuiRoot, CENTER, SV.mlgX, SV.mlgY)
    wnd:SetMovable(SV.mlgShowAlways)
    wnd:SetMouseEnabled(true)
    wnd:SetHidden(true)
    wnd:SetDrawTier(DT_MEDIUM)
    wnd:SetDrawLayer(DL_CONTROLS)
    wnd:SetDrawLevel(1)

    -- Native move + save, exactly like the CombatStatus windows:
    -- dragging is built in (SetMovable) and OnMoveStop stores the
    -- position relative to screen center.
    wnd:SetHandler("OnMoveStop", function(self)
        local cx, cy = GuiRoot:GetCenter()
        local wx, wy = self:GetCenter()
        SV.mlgX = wx - cx
        SV.mlgY = wy - cy
        self:ClearAnchors()
        self:SetAnchor(CENTER, GuiRoot, CENTER, SV.mlgX, SV.mlgY)
    end)

    local lbl = WINDOW_MANAGER:CreateControl(nil, wnd, CT_LABEL)
    lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- Countdown under the streak text: how much of the 4 s chain
    -- window is left before the multiplier falls off.
    local timerLbl = WINDOW_MANAGER:CreateControl(nil, wnd, CT_LABEL)
    timerLbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    timerLbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    timerLbl:SetFont("ZoFontGameSmall")
    timerLbl:SetColor(1, 1, 1, 0.8)
    timerLbl:SetText("0.0s")

    self.announcerWnd  = wnd
    self.announcerLbl  = lbl
    self.announcerTimerLbl = timerLbl
    self.announceTimer = nil
    self.mlgStreak     = 0
    self.mlgDeadline   = 0
    self:ApplyAnnouncerStyle()
end

-- Size the window to the text with font-proportional padding and
-- center the auto-sized labels (CombatStatus pattern), so nothing
-- can clip no matter the font size. The countdown sits directly
-- below the streak text.
function CritMarker:FitAnnouncerWindow()
    local wnd    = self.announcerWnd
    local lbl    = self.announcerLbl
    local tLbl   = self.announcerTimerLbl
    if not wnd or not lbl or lbl:GetTextWidth() <= 0 then return end
    local tW = tLbl and tLbl:GetTextWidth() or 0
    local tH = tLbl and tLbl:GetTextHeight() or 0
    local size = self.SV.mlgFontSize
    wnd:SetDimensions(math.max(lbl:GetTextWidth(), tW) + size * 1.4,
                      lbl:GetTextHeight() + tH + size * 1.0)
    lbl:ClearAnchors()
    lbl:SetAnchor(CENTER, wnd, CENTER, 0, -(tH / 2) - 1)
    if tLbl then
        tLbl:ClearAnchors()
        tLbl:SetAnchor(CENTER, wnd, CENTER, 0, lbl:GetTextHeight() / 2 + 1)
    end
end

-- Re-apply font size / custom color from the settings.
function CritMarker:ApplyAnnouncerStyle()
    if not self.announcerLbl then return end
    self.announcerLbl:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", self.SV.mlgFontSize))
    if not self.SV.announcerUseTierColors then
        self.announcerLbl:SetColor(self.SV.announcerColor[1],
            self.SV.announcerColor[2], self.SV.announcerColor[3], 1)
    end
    self:FitAnnouncerWindow()
end

-- Flash an MLG streak tier for the full 4 s chain window: when the
-- text disappears, the streak has expired. Every new streak "pops"
-- in bigger than the configured size — higher multipliers pop
-- harder, KILLIONAIRE hardest — and a small countdown under the
-- text shows how long the chain still has before it falls off.
function CritMarker:Announce(streak, keepVisible)
    local tier = MLG_TIERS[math.min(streak, 10)]
    if not tier then return end
    local streakShown = math.min(streak, 10)
    local SV       = self.SV
    local wnd      = self.announcerWnd
    local lbl      = self.announcerLbl
    local timerLbl = self.announcerTimerLbl
    if SV.announcerUseTierColors then
        lbl:SetColor(tier[2][1], tier[2][2], tier[2][3], 1)
    end
    lbl:SetText(("%dx %s"):format(streakShown, tier[1]))
    lbl:SetAlpha(1)
    self:FitAnnouncerWindow()
    wnd:SetHidden(false)

    -- Pop-in: one big overshoot then a fast settle (two quick steps,
    -- under 100 ms) so it reads as a single punchy pop; higher
    -- multipliers pop harder. Stale steps from a previously
    -- interrupted announcement are ignored via the sequence counter.
    self.announceSeq = (self.announceSeq or 0) + 1
    local seq      = self.announceSeq
    local popScale = 1 + (streakShown - 1) * 0.08
    local function PopStep(delay, scale)
        zo_callLater(function()
            if wnd and seq == self.announceSeq then
                wnd:SetScale(scale)
            end
        end, delay)
    end
    wnd:SetScale(popScale)
    PopStep(35, 1 + (popScale - 1) * 0.4)
    PopStep(90, 1)

    -- Live countdown under the text: ticks every 100 ms, green while
    -- the chain holds, red in the last second, then clears itself
    -- when the window expires. The label is only re-rendered when the
    -- text or colour actually changes.
    local timerName = self.name .. "_MLG_TIMER"
    if timerLbl then
        local function ShowCountdown()
            local remaining = self.mlgDeadline - GetFrameTimeMillisecondsFn()
            if remaining <= 0 then
                timerLbl:SetText("")
                self:FitAnnouncerWindow()
                EM:UnregisterForUpdate(timerName)
                return
            end
            local seconds = ("%.1f s"):format(remaining / 1000)
            if timerLbl:GetText() ~= seconds then
                if remaining < 1000 then
                    timerLbl:SetColor(1, 0.2, 0.2, 0.8)
                else
                    timerLbl:SetColor(0.2, 1, 0.3, 0.8)
                end
                timerLbl:SetText(seconds)
                self:FitAnnouncerWindow()
            end
        end
        ShowCountdown()
        EM:RegisterForUpdate(timerName, 100, ShowCountdown)
    end

    if self.announceTimer then
        zo_removeCallLater(self.announceTimer)
        self.announceTimer = nil
    end
    self.announceTimer = zo_callLater(function()
        EM:UnregisterForUpdate(timerName)
        if not SV.mlgShowAlways then
            wnd:SetHidden(true)
            wnd:SetScale(1)
        end
        self.announceTimer = nil
    end, keepVisible and 999999 or MLG_4S)
end

-- Snap the announcer window back above the hitmarker and restore
-- the default font size.
function CritMarker:ResetAnnouncerPosition()
    local SV = self.SV
    SV.mlgX = 0
    SV.mlgY = -170
    SV.mlgFontSize = 44
    self:ApplyAnnouncerStyle()
    if self.announcerWnd then
        self.announcerWnd:SetAnchor(CENTER, GuiRoot, CENTER, SV.mlgX, SV.mlgY)
    end
end

function CritMarker:RegisterEvents()
    EM:RegisterForEvent(self.name .. "_COMBAT", EVENT_COMBAT_EVENT, function(...)
        local result = select(2, ...)
        if result ~= ACTION_RESULT_CRITICAL_DAMAGE then return end
        self.ui:HandleCombatCrit()
    end)
    EM:AddFilterForEvent(self.name .. "_COMBAT", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EM:AddFilterForEvent(self.name .. "_COMBAT", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_CRITICAL_DAMAGE)

    EM:RegisterForEvent(self.name .. "_PVP_KILL", EVENT_PVP_KILL_FEED_DEATH, function(
        _, killLocation, killerPlayerDisplayName, killerCharacterName,
        killerAlliance, killerRank, victimPlayerDisplayName, victimCharacterName)
        self.ui:HandlePvPKill(killLocation, killerPlayerDisplayName, killerCharacterName,
            killerAlliance, killerRank, victimPlayerDisplayName, victimCharacterName)
    end)

    EM:RegisterForEvent(self.name .. "_DUEL_FINISHED", EVENT_DUEL_FINISHED, function(_, duelResult, wasLocalPlayersResult)
        if duelResult == DUEL_RESULT_WON and wasLocalPlayersResult then
            self.ui:HandleDuelWin()
        end
    end)

    EM:RegisterForEvent(self.name .. "_UNIVERSAL_KILL", EVENT_COMBAT_EVENT, function(_, result,
        isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName,
        sourceType, targetName, targetType, hitValue, powerType, damageType,
        log, sourceUnitId, targetUnitId)
        if result ~= ACTION_RESULT_DIED and result ~= ACTION_RESULT_DIED_XP
           and result ~= ACTION_RESULT_KILLING_BLOW then return end
        local rawSource = GetRawUnitNameFn(sourceName)
        local rawTarget = GetRawUnitNameFn(targetName)
        local myName    = GetRawUnitNameFn(GetUnitNameFn("player"))
        if rawSource ~= myName and not AreUnitsEqual("player", sourceUnitId) then return end
        if rawTarget == myName or rawTarget == "" then return end
        self.ui:HandleUniversalKill(rawTarget)
    end)
    EM:AddFilterForEvent(self.name .. "_UNIVERSAL_KILL", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EM:RegisterForEvent(self.name .. "_PLAYER_DEAD", EVENT_PLAYER_DEAD, function()
        self.mlgStreak = 0
    end)
end

function CritMarker:OnLoaded(_, addonName)
    if addonName ~= self.name then return end
    EM:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

    self:InitSavedVars()
    self:CreateModules()
    BuildMenu()
    self:RegisterEvents()
end

EM:RegisterForEvent(CritMarker.name, EVENT_ADD_ON_LOADED, function(...)
    CritMarker:OnLoaded(...)
end)