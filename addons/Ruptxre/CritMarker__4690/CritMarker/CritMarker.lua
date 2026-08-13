---------------------------------------------------------------
-- CritMarker
-- Customizable FPS-style hitmarker for critical hits, PvP killing
-- blows and duel wins. Final public release 1.0.21
--
-- 1.0.21 vs 1.0.20:
--   * Cyrodiil guards can no longer count as kills: the combat-event
--     kill fallback only filtered the SOURCE as a player, so killing
--     a guard (an NPC target) fired KILLING_BLOW / DIED and bumped
--     the MLG streak, the per-life spree counter and the kill marker.
--     The event now also filters TARGETS to players
--     (REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE), and the kill-feed
--     path rejects victims without an @ account display name — every
--     register path is player-kills-only now, like the killmarker
-- 1.0.20 vs 1.0.19:
--   * the announcer countdown now scales with the Announcer Scale
--     slider (it was hardcoded to ZoFontGameSmall at creation); its
--     base font is 24 px at scale 1.0
--   * new "Spree Medal Sound" toggle (on by default): plays the
--     built-in achievement chime whenever a total-kill spree medal is
--     awarded (Killing Spree at 5, Killing Frenzy at 10, ... Invincible
--     at 30) — built-in ESO sounds only, custom audio is impossible
-- 1.0.19 vs 1.0.18:
--   * Show While Configuring unlocks the banner for dragging again:
--     the in-1.0.19 manual cursor-drag rework crashed on every grab —
--     it scaled ZO_CURSOR by GuiRoot:GetEffectiveScale(), an API that
--     does not exist ("function expected instead of nil"). Dragging
--     is back on the proven 1.0.13+ native SetMovable + OnMoveStop
--     pattern (CombatStatus style), gated on Show While Configuring,
--     with the position saved relative to screen center
--   * the medal window is now natively movable and re-syncs the text
--     window to where the medal lands on release (inverting its BOTTOM
--     anchor math in screen space): the icon is grabbable in BOTH
--     modes — a passthrough medal window left Icon Only Mode dead,
--     its texture swallowed the click and the text (invisible) below
--     was unreachable
--   * Show Medal Icons option removed: its off->on cycle could never
--     revive the icon without a full UI reload (the OFF branch hid
--     the medal texture and both toggle directions were out of sync
--     with the render path). Every banner always shows its medal now;
--     text is turned on/off with Icon Only Mode instead
--   * default Announcer Scale is 0.5x now (smaller banner out of the
--     box; Reset Announcer Position also snaps back to 0.5), and the
--     medal-to-text gap BASE is fixed at 6 px (the Icon to Text Gap
--     slider was removed again — the gap scales with the banner as
--     before)
--   * Announcer Scale slider no longer explodes into garbage values:
--     the LAM value box is an editable field that echoes every
--     keystroke back through OnTextChanged, so a laid-over SetText
--     interleaved typed digits into 4186-style junk; the box is now
--     read-only, everything rounds to 0.1 decimals, and the slider
--     get/set clamp + snap to the 0.5-3.0 grid so the SV can never
--     hold an out-of-range value
--   * medal icons popped toward the upper-left corner mid-animation:
--     the old anchor-pull compensation double-shifted against ESO's
--     center-based SetScale, so the icon swept off its resting spot
--   * the medal now lives in its own top-level window, parked above
--     the text with one fixed gap: SetScale alone grows it about its
--     own center (1 -> 1.5 -> 1.1 -> 1), so the icon's center never
--     moves and the pop can never touch the text window
--   * the pop is a fixed 150% for every banner (no more per-tier
--     growth), and the text window only ever fits the text itself —
--     same size, same spot, every tier
--     (gotcha: SetScale is silently ignored on controls whose size
--     comes from SetAnchorFill — the medal's size must come from
--     SetDimensions or the pop renders static; the medal is therefore
--     CENTER-anchored for position only)
--   * all announcer anchors are FIXED constants now — the countdown
--     used to pull the streak label up by half its height, so chain
--     banners sat ~7 px higher than life banners; now the label,
--     countdown and medal use the same anchor offsets for every
--     banner type, so life kill renders at the exact same spot as an
--     MLG kill (the countdown only grows the invisible window rect)
--   * new sliders: Medal to Text Gap (default 18 px) and Countdown
--     to Text Gap (default 6 px) let the spacing be tuned in-game —
--     the countdown is anchored to the main label's bottom edge so
--     both gaps are exact pixels, identical for every banner type
--   * pop tamed from 150 % to 125 % so the peak dip (12.5 % of the
--     medal size) clears the text at the default 18 px gap
--   * Announcer Display simplified: the separate Font Size / Medal
--     Size / Medal Gap / Countdown Gap sliders are gone — one
--     Announcer Scale slider (0.5-2.0) scales the whole banner as a
--     unit (font, medal and both gaps are base values * scale)
--   * Icon Only Mode is the text on/off switch now (the old text-only
--     mode is gone, the medal always shows): toggling it hides the
--     streak text and countdown, showing just the popping medal at
--     its usual spot
--   * Announcer Scale slider range widened to 0.5-3.0 (clean 0.1
--     steps); dragging in Show While Configuring no longer fights the
--     100 ms countdown re-fits (re-fits stand down while the window
--     is being dragged, via OnMoveStart/OnMoveStop); disabling Show
--     While Configuring also hides the medal window so the icon can
--     no longer linger after the text
--   * medal window anchored to the announcer window (top-level to
--     top-level, so it still follows drags) at the label's fixed
--     offset — a top-level window anchored to an auto-sized nested
--     label does not track its rect, which was the original cause of
--     the medal-to-text gap drifting between banner types
-- 1.0.18 vs 1.0.17:
--   * hitmarker textures moved into their own Hitmarkers/ folder and
--     renumbered 1..24 (no more special unnumbered hitmarker.dds)
--   * MLG Announcer pops the matching Halo medal icon with each tier
--     (DoubleKill.dds .. Killionaire.dds from the Medals/ folder)
--   * per-life total-kill medals: Killing Spree (5), Killing Frenzy
--     (10), Running Riot (15), Rampage (20), Untouchable (25) and
--     Invincible (30) pop once per life as your kill count grows,
--     entirely separate from the 4 s chain; the counter resets on
--     death (toggleable via Show Total-Kill Medals)
--   * chains still reset at KILLIONAIRE as before
--   * KILLJOY medal pops on native PvP revenge/avenge kills (ESO's
--     own EVENT_REVENGE_KILL / EVENT_AVENGE_KILL): killing your last
--     killer, or a player who killed a teammate — toggleable via Show
--     Killjoy Medal
--   * test tools: Test Life Kill simulates one per-life kill for the
--     spree-medal sequence — it auto-resets after 6 s without presses
--     (simulated death) so the sequence can be re-walked — and the
--     Preview Announcer Banner dropdown renders any chain tier, spree
--     medal or revenge/avenge banner on demand for placement testing
-- 1.0.17 vs 1.0.16:
--   * kill dedup hardened: the same death can arrive through several
--     events (combat killing blow + zone kill feed), and in Cyrodiil
--     the two paths could disagree on the victim string (@account /
--     server suffix, case or empty-name formatting), letting ONE kill
--     flash the marker twice
--   * every kill path now dedups on one normalized victim key
--     (lowercase, @suffix stripped, empty -> "unknown") plus a
--     victim-unit-id guard on the combat path (KILLING_BLOW / DIED /
--     DIED_XP echoes of the same death share the unit)
--   * distinct kills still flash no matter how tight the gap; the
--     1.5 s same-victim window is unchanged
--   * side fix: a duplicated kill event no longer bumps the MLG
--     streak twice, so chains can no longer be mislabeled
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
local VERSION    = "1.0.21"

local zo_callLater                = zo_callLater
local zo_removeCallLater          = zo_removeCallLater
local PlaySoundFn                 = PlaySound
local GetRawUnitNameFn            = GetRawUnitName
local GetUnitNameFn               = GetUnitName
local GetDisplayNameFn            = GetDisplayName
local GetFrameTimeMillisecondsFn  = GetFrameTimeMilliseconds

-- Test-only: how long a paused Test Life Kill streak lives before the
-- counter simulates death and resets, so the spree sequence can be
-- re-walked. Slightly longer than the 4 s chain window by design.
local LIFE_RESET_MS = 6000

-- Guarded chat output (DEFAULT_CHAT_FRAME may be absent in odd states).
local function ChatPrint(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|c00FF88[CritMarker]|r " .. msg)
    end
end

local CritMarker = {
    name    = ADDON_NAME,
    version = VERSION,
    SV      = nil,
    ui      = nil,
}

local CRIT = "Crit"
local KILL = "Kill"

-- Halo-style announcer tiers: streak count -> text + color + medal
-- texture (Medals/ folder). The medal pops with every announcement.
-- Reaching KILLIONAIRE (10) restarts
-- the chain at 1, so the next kill begins a fresh chain.
local MLG_4S = 4000
-- Base announcer dimensions at scale 1.0: the single Announcer Scale
-- slider multiplies ALL of these together (streak text font, countdown
-- font, medal size and both gaps) so the whole banner scales as one
-- unit.
local ANN_BASE_FONT      = 44
local ANN_BASE_TIMER_FONT = 24
local ANN_BASE_MEDAL     = 90
local ANN_BASE_MEDAL_GAP = 6
local ANN_BASE_TIMER_GAP = 6
local HM_DIR    = "CritMarker/Hitmarkers/"
local MEDAL_DIR = "CritMarker/Medals/"
local MLG_TIERS = {
    [2]  = { "Double Kill!",   { 0.35, 1,    0.45 }, "DoubleKill.dds" },
    [3]  = { "Triple Kill!",   { 0.3,  0.95, 1    }, "TripleKill.dds" },
    [4]  = { "Overkill!",      { 1,    0.75, 0.25 }, "OverKill.dds" },
    [5]  = { "Killtacular!",   { 1,    0.45, 0.2  }, "Killtacular.dds" },
    [6]  = { "Killtrocity!",   { 1,    0.35, 0.6  }, "Killtrocity.dds" },
    [7]  = { "Killamanjaro!",  { 0.8,  0.3,  1    }, "Killimanjaro.dds" },
    [8]  = { "Killtastrophe!", { 1,    0.2,  0.2  }, "Killtastrophe.dds" },
    [9]  = { "Killpocalypse!", { 1,    0.9,  0.15 }, "Killpocalpse.dds" },
    [10] = { "KILLIONAIRE!!",  { 1,    0.1,  0.1  }, "Killionaire.dds" },
}

-- Per-life total-kill medals (Halo style): pop once when your kill
-- count in a single life reaches the threshold; the counter resets
-- when you die. Not chained — just how many kills you have banked.
local MLG_LIFE_MEDALS = {
    [5]  = { "Killing Spree!",  { 0.4,  0.9, 0.5 }, "KillingSpree.dds" },
    [10] = { "Killing Frenzy!", { 1,    0.6, 0.2 }, "KillingFrenzy.dds" },
    [15] = { "Running Riot!",   { 0.3,  0.85, 1  }, "RunningRiot.dds" },
    [20] = { "Rampage!",        { 1,    0.25, 0.1 }, "Rampage.dds" },
    [25] = { "Untouchable!",    { 1,    0.85, 0.2 }, "Untouchable.dds" },
    [30] = { "Invincible!",     { 0.8,  0.3,  1  }, "Invincible.dds" },
}

local MLG_KILLJOY_COLOR = { 0.3, 0.85, 1 }

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
-- Texture styles: "StyleN" selects Hitmarkers/hitmarker(N).dds.
-- The files live in the Hitmarkers/ folder, renumbered 1..24.
---------------------------------------------------------------
local NUM_TEXTURES = 24
CritMarker.TEXTURE_OPTIONS = {}
CritMarker.texLookup = {}
for i = 1, NUM_TEXTURES do
    CritMarker.TEXTURE_OPTIONS[i] = "Style" .. i
    CritMarker.texLookup["Style" .. i] = "hitmarker" .. i .. ".dds"
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
    o.lastKillUnitId   = 0
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
        self.texture:SetTexture(HM_DIR .. file)
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

-- One normalized victim key shared by every kill path: lowercase,
-- @account / server suffix stripped, empty -> "unknown", so the kill
-- feed's character name and the combat event's raw name always match.
local function NormalizeKillTag(tag)
    if not tag or tag == "" then return "unknown" end
    local t = zo_strlower(tag:gsub("@.*$", ""))
    if t == "" then return "unknown" end
    return t
end

-- Unified kill-show gate. A single kill can arrive through several
-- events (combat killing blow, zone kill feed); the same death must
-- flash exactly once. Dedup keys:
--   * victim tag, normalized (lowercase, @account/server suffix
--     stripped, empty -> "unknown") so the kill feed's character name
--     and the combat event's raw name always agree on the same victim;
--   * victim unit id (combat path only): the same death echo from
--     two events shares the id, catching name-formatting edge cases.
-- Distinct kills always flash, no matter how quickly they follow.
function Marker:ShouldShowKill(tag, unitId)
    local now = GetFrameTimeMillisecondsFn()
    local dt  = now - self.lastKillTime
    if dt < 1500 and (tag == self.lastKillTag
                      or (unitId and unitId ~= 0 and unitId == self.lastKillUnitId)) then
        return false
    end
    self.lastKillTag  = tag
    self.lastKillTime = now
    self.lastKillUnitId = unitId or 0
    self:HandleAnnouncer()
    -- Per-life kill counter drives the spree medals; the count resets
    -- on death (EVENT_PLAYER_DEAD).
    self.owner.lifeKills = self.owner.lifeKills + 1
    self.owner:AnnounceLifeMedal(self.owner.lifeKills)
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
    -- Guards and other NPCs have no player account: a real victim always
    -- carries an @ display name in the feed, so a victim without one is
    -- not a player kill (Cyrodiil guards must never count).
    if not victimPlayerDisplayName or not zo_strfind(victimPlayerDisplayName, "@") then return end
    if self:ShouldShowKill(NormalizeKillTag(victimCharacterName)) then self:Show(KILL) end
end

function Marker:HandleDuelWin()
    local now = GetFrameTimeMillisecondsFn()
    if (now - self.lastKillTime) < 1500 then return end
    if self:ShouldShowKill("duel") then self:Show(KILL) end
end

-- Combat-event fallback for kills the kill feed may not report. The
-- unit id rides along: the same death echoing through multiple combat
-- results (KILLING_BLOW / DIED / DIED_XP) is deduped by it even if
-- the name formatting ever disagrees.
function Marker:HandleUniversalKill(targetName, targetUnitId)
    if self:ShouldShowKill(NormalizeKillTag(targetName), targetUnitId) then self:Show(KILL) end
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
    EnsureDefault("mlgMedalSize",           90)
    EnsureDefault("mlgMedalGap",            ANN_BASE_MEDAL_GAP)
    EnsureDefault("mlgTimerGap",            6)
    EnsureDefault("mlgTimerFontSize",        24)
    EnsureDefault("announcerScale",         0.5)
    EnsureDefault("mlgIconOnly",            false)
    EnsureDefault("mlgLifeMedals",          true)
    EnsureDefault("mlgSpreeSound",           true)
    EnsureDefault("mlgKilljoy",             true)
    EnsureDefault("mlgShowAlways",          false)

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
            img:SetTexture(HM_DIR .. addon.texLookup[addon.TEXTURE_OPTIONS[i]])

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

    -- Preview banner list for the announcer test dropdown: every chain
    -- tier, every per-life medal and the two native revenge/avenge
    -- banners, each rendering exactly like the real thing so it can be
    -- eyeballed and placed before shipping. Counts derive from the
    -- source tables, never hardcoded.
    local previews = {}
    local previewChoices = {}
    local function AddPreview(label, text, color, medal, countdown)
        previews[label] = { text = text, color = color, medal = medal,
                            countdown = countdown }
        previewChoices[#previewChoices + 1] = label
    end
    for level = 2, 10 do
        local tier = MLG_TIERS[level]
        AddPreview(("%dx %s"):format(level, tier[1]),
                   ("%dx %s"):format(level, tier[1]),
                   tier[2], tier[3], true)
    end
    local lifeKeys = {}
    for k in pairs(MLG_LIFE_MEDALS) do lifeKeys[#lifeKeys + 1] = k end
    table.sort(lifeKeys)
    for _, kills in ipairs(lifeKeys) do
        local m = MLG_LIFE_MEDALS[kills]
        AddPreview(m[1], m[1], m[2], m[3], false)
    end
    AddPreview("REVENGE!", "REVENGE!", MLG_KILLJOY_COLOR, "Killjoy.dds", false)
    AddPreview("AVENGED!", "AVENGED!", MLG_KILLJOY_COLOR, "Killjoy.dds", false)

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
                   "counter restarts at one. The matching Halo medal pops " ..
                   "next to each announcement. Separate from the chain, " ..
                   "your per-life kill count also earns spree medals — " ..
                   "Killing Spree (5), Killing Frenzy (10), Running Riot " ..
                   "(15), Rampage (20), Untouchable (25), Invincible (30) — " ..
                   "which reset when you die. A KILLJOY medal pops on revenge and " ..
                   "avenge kills: killing the player who last killed " ..
                   "you, or killing a player who killed a teammate. " ..
                   "The chain resets when 4 " ..
                   "seconds pass without a kill, or when you die; a " ..
                   "countdown under the text shows the time left, and the " ..
                   "matching medal pops above it — growing to 125 % " ..
                   "from its own center and settling back, so the " ..
                   "text itself never moves. The Test buttons " ..
                   "simulate kills so you can preview the tiers, and the " ..
                   "Preview Announcer Banner dropdown renders any banner " ..
                   "on demand for placement testing.|r",
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
        {
            type = "button",
            name = "Test Life Kill",
            tooltip = "Simulate one per-life kill: bumps the life kill counter " ..
                      "and fires its spree medal at each threshold (5 Killing " ..
                      "Spree, 10 Killing Frenzy, 15 Running Riot, 20 Rampage, " ..
                      "25 Untouchable, 30 Invincible). Stop pressing for 6 " ..
                      "seconds and the life resets, simulating death, so the " ..
                      "sequence can be re-tested.",
            func = function() addon:TestLifeKill() end,
        },
        {
            type = "dropdown",
            name = "Preview Announcer Banner",
            tooltip = "Render any announcer banner exactly as it appears in " ..
                      "combat — every chain tier, spree medal and the " ..
                      "revenge/avenge banners. Enable Show While Configuring " ..
                      "below and drag the window while checking each one.",
            choices = previewChoices,
            getFunc = function() return previewChoices[1] end,
            setFunc = function(label)
                local p = previews[label]
                if not p then return end
                -- A live chain deadline so the preview countdown ticks.
                addon.mlgDeadline = GetFrameTimeMillisecondsFn() + MLG_4S
                addon:ShowAnnouncerBanner(p.text, p.color, p.medal, nil, p.countdown)
            end,
        },

        { type = "header", name = "|cFFFFFFAnnouncer Display|r" },
        { type = "divider" },
        {
            type = "description",
            text = "|cBFC2D6The announcer is its own window. Drag the text " ..
                   "anywhere on screen (position saves automatically), scale " ..
                   "the whole banner (text, medal and spacing) with the one " ..
                   "scale slider (default 0.5x), tint it or keep the " ..
                   "per-tier colors. " ..
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
                if addon.announcerMedalWnd then addon.announcerMedalWnd:SetMovable(v) end
                if v then
                    addon:Announce(2, true)
                elseif addon.announcerWnd then
                    addon.announcerWnd:SetHidden(true)
                    -- The medal lives in its own window — it must be
                    -- hidden too, or the icon lingers after the text
                    -- disappears.
                    if addon.announcerMedalWnd then
                        addon.announcerMedalWnd:SetHidden(true)
                    end
                    if addon.announcerMedal then
                        addon.announcerMedal:SetScale(1)
                    end
                end
            end,
        },
        {
            type = "slider",
            name = "Announcer Scale",
            tooltip = "Scale the whole announcer together: streak text, " ..
                      "medal icon and both gaps grow and shrink as one " ..
                      "unit (1.0 = defaults, 0.5 = half, 3.0 = triple).",
            min = 0.5, max = 3, step = 0.1,
            -- Read-only value box + rounded decimals: the LAM slider's
            -- editable text field echoes each keystroke back into the
            -- control and laid-over SetText calls interleave typed
            -- digits into garbage values (a single click could grow a
            -- 0.5 into 4186); with readOnly the field only displays,
            -- and decimals keeps every echo/display on the 0.1 grid.
            readOnly = true,
            decimals = 1,
            getFunc = function()
                local v = tonumber(SV.announcerScale) or 1
                return math.max(0.5, math.min(3, v))
            end,
            setFunc = function(v)
                v = tonumber(v) or 1
                v = math.max(0.5, math.min(3, v))
                v = math.floor(v * 10 + 0.5) / 10
                SV.announcerScale = v
                addon:ApplyAnnouncerScale()
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
            type = "checkbox",
            name = "Icon Only Mode",
            tooltip = "Hide the streak text and countdown, leaving just " ..
                      "the popping medal icon (the medal itself always " ..
                      "shows with each announcement — there is no " ..
                      "text-only mode).",
            getFunc = function() return SV.mlgIconOnly end,
            setFunc = function(v)
                SV.mlgIconOnly = v
                if addon.announcerWnd then
                    addon:Announce(2, true)
                end
            end,
        },
        {
            type = "checkbox",
            name = "Show Total-Kill Medals",
            tooltip = "Pop Halo spree medals as your per-life kill count " ..
                      "grows, independent of the 4 second chain: Killing " ..
                      "Spree (5 kills), Killing Frenzy (10), Running Riot " ..
                      "(15), Rampage (20), Untouchable (25), Invincible " ..
                      "(30). The counter resets when you die.",
            getFunc = function() return SV.mlgLifeMedals end,
            setFunc = function(v) SV.mlgLifeMedals = v end,
        },
        {
            type = "checkbox",
            name = "Spree Medal Sound",
            tooltip = "Play the achievement chime whenever a total-kill " ..
                      "spree medal is awarded (Killing Spree, Killing " ..
                      "Frenzy, Running Riot, Rampage, Untouchable, " ..
                      "Invincible). Built-in ESO sounds only — custom " ..
                      "audio files are impossible in ESO.",
            getFunc = function() return SV.mlgSpreeSound end,
            setFunc = function(v) SV.mlgSpreeSound = v end,
        },
        {
            type = "checkbox",
            name = "Show Killjoy Medal",
            tooltip = "Pop the KILLJOY medal on native PvP revenge/avenge " ..
                      "kills: killing the player who last killed you " ..
                      "(REVENGE) or a player who killed a teammate " ..
                      "(AVENGED).",
            getFunc = function() return SV.mlgKilljoy end,
            setFunc = function(v) SV.mlgKilljoy = v end,
        },
        {
            type = "button",
            name = "Reset Announcer Position",
            tooltip = "Snap the announcer window back above the hitmarker " ..
                      "and restore the default scale (0.5).",
            func = function()
                addon:ResetAnnouncerPosition()
                -- LAM sliders only re-read their value on a panel
                -- refresh, so tell the panel to UpdateValue all of
                -- its controls (shows the restored scale).
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
    wnd:SetMouseEnabled(true)
    wnd:SetHidden(true)
    wnd:SetDrawTier(DT_MEDIUM)
    wnd:SetDrawLayer(DL_CONTROLS)
    wnd:SetDrawLevel(1)

    -- Native drag (CombatStatus pattern, proven in 1.0.13-1.0.18): the
    -- manual cursor approach crashed on grab — it scaled ZO_CURSOR by
    -- GuiRoot:GetEffectiveScale(), an API that does not exist in ESO
    -- ("function expected instead of nil" on every OnMouseDown).
    -- SetMovable gates on Show While Configuring; OnMoveStop persists
    -- the position relative to screen center and re-anchors. The
    -- medal window is mouse-DISABLED, so grabs on the medal pass
    -- through to this window and drag the whole banner. The
    -- isDragging flag makes FitAnnouncerWindow stand down while the
    -- user drags — the 100 ms countdown re-fits would otherwise snap
    -- the window back mid-drag.
    wnd:SetMovable(SV.mlgShowAlways)
    wnd:SetHandler("OnMoveStart", function()
        self.isDragging = true
    end)
    wnd:SetHandler("OnMoveStop", function()
        self.isDragging = false
        local cx, cy = GuiRoot:GetCenter()
        local wx, wy = self.announcerWnd:GetCenter()
        SV.mlgX = wx - cx
        SV.mlgY = wy - cy
        self.announcerWnd:ClearAnchors()
        self.announcerWnd:SetAnchor(CENTER, GuiRoot, CENTER, SV.mlgX, SV.mlgY)
    end)

    local lbl = WINDOW_MANAGER:CreateControl(nil, wnd, CT_LABEL)
    lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- Countdown under the streak text: how much of the 4 s chain
    -- window is left before the multiplier falls off.
    local timerLbl = WINDOW_MANAGER:CreateControl(nil, wnd, CT_LABEL)
    timerLbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    timerLbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    timerLbl:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", ANN_BASE_TIMER_FONT))
    timerLbl:SetColor(1, 1, 1, 0.8)
    timerLbl:SetText("0.0s")

    -- Halo medal icon: its OWN top-level window, so the icon can pop
    -- (scale about its own center) without ever touching the text.
    -- Parked above the announcer window with one fixed gap (see
    -- FitAnnouncerWindow); this window just carries the texture.
    local mWnd = WINDOW_MANAGER:CreateTopLevelWindow("CritMarker_MLG_Medal")
    mWnd:SetHidden(true)
    mWnd:SetDrawTier(DT_MEDIUM)
    mWnd:SetDrawLayer(DL_CONTROLS)
    mWnd:SetDrawLevel(2)
    -- The medal window is itself natively movable: in Icon Only Mode
    -- the medal is the ONLY thing on screen to grab — a passthrough
    -- medal window left nothing to drag (its texture swallowed the
    -- click and the invisible text window below was unreachable).
    -- On release the text window is re-synced to the medal's position
    -- and FitAnnouncerWindow snaps the medal back to its locked spot.
    mWnd:SetMouseEnabled(true)
    mWnd:SetMovable(SV.mlgShowAlways)
    mWnd:SetHandler("OnMoveStart", function()
        self.isDragging = true
    end)
    mWnd:SetHandler("OnMoveStop", function()
        self.isDragging = false
        local mWnd, wnd, lbl = self.announcerMedalWnd, self.announcerWnd, self.announcerLbl
        if not mWnd or not wnd or not lbl then return end
        -- The medal's BOTTOM edge is anchored to the text window's
        -- CENTER at offset (0, labelTop - medalGap), horizontally
        -- centered — invert that to find where the text window must
        -- sit for the medal to rest where the user dropped it.
        local mx, my = mWnd:GetCenter()
        local gcx, gcy = GuiRoot:GetCenter()
        local labelTop = -1 - lbl:GetTextHeight() / 2
        local wcy = my + mWnd:GetHeight() / 2 - (labelTop - self.SV.mlgMedalGap)
        SV.mlgX = mx - gcx
        SV.mlgY = wcy - gcy
        wnd:ClearAnchors()
        wnd:SetAnchor(CENTER, GuiRoot, CENTER, SV.mlgX, SV.mlgY)
        self:FitAnnouncerWindow()
    end)
    local medal = WINDOW_MANAGER:CreateControl(nil, mWnd, CT_TEXTURE)
    medal:SetAnchor(CENTER, mWnd, CENTER, 0, 0)
    medal:SetBlendMode(TEX_BLEND_MODE_ALPHA)

    self.announcerWnd  = wnd
    self.announcerLbl  = lbl
    self.announcerTimerLbl = timerLbl
    self.announcerMedalWnd = mWnd
    self.announcerMedal = medal
    self.announceTimer = nil
    self.mlgTimerActive = false
    self.refitTimerA = nil
    self.refitTimerB = nil
    self.mlgStreak     = 0
    self.mlgDeadline   = 0
    self.lifeKills     = 0
    self.lifeKillResetTimer = nil
    self:ApplyAnnouncerScale()
end

-- Size the announcer window to the TEXT ONLY (CombatStatus pattern):
-- the label auto-fits, the countdown tucks under it, and the whole
-- block stays dead-center of the window — so the text sits at the
-- SAME spot for every tier, at the window's fixed screen anchor. The
-- medal no longer participates in this layout: it has its own
-- top-level window, parked above this one with one fixed gap sized
-- for the biggest pop (125 %), so it can never touch the text and no
-- per-tier spacing exists.
function CritMarker:FitAnnouncerWindow()
    local wnd   = self.announcerWnd
    local lbl   = self.announcerLbl
    local tLbl  = self.announcerTimerLbl
    local mWnd  = self.announcerMedalWnd
    if not wnd or not lbl or lbl:GetTextWidth() <= 0 then
        if mWnd then mWnd:SetHidden(true) end
        return
    end
    -- Stand down while the user drags the window: the periodic
    -- countdown re-fits would snap it back to its anchor mid-drag.
    if self.isDragging then return end
    local tW = tLbl and tLbl:GetTextWidth() or 0
    local tH = tLbl and tLbl:GetTextHeight() or 0
    local size = self.SV.mlgFontSize
    local textW = math.max(lbl:GetTextWidth(), tW)
    local textH = lbl:GetTextHeight() + tH
    wnd:SetDimensions(textW + size * 1.4, textH + size * 1.0)
    -- FIXED anchor offsets for every banner: the label always sits at
    -- wndCenter - 1, the countdown hangs below it at the user-tuned
    -- gap (mlgTimerGap). Neither gap depends on the countdown's own
    -- height, so chain, life and killjoy banners render at the EXACT
    -- same spot — the window is CENTER-anchored to the screen at
    -- mlgX/mlgY and only the content differs.
    lbl:ClearAnchors()
    lbl:SetAnchor(CENTER, wnd, CENTER, 0, -1)
    if tLbl then
        tLbl:ClearAnchors()
        tLbl:SetAnchor(TOP, lbl, BOTTOM, 0, self.SV.mlgTimerGap)
    end

    -- The medal window: own top-level element, its BOTTOM edge pinned
    -- above the STREAK LABEL's top edge at the user-tuned gap
    -- (mlgMedalGap, px). The medal cannot be anchored to the label
    -- itself (a top-level window anchored to an auto-sized nested
    -- control does not track its rect reliably), so it anchors to
    -- the announcer window with the label's fixed, constant offset —
    -- the medal-to-text gap is IDENTICAL for chain, life and killjoy
    -- banners because the countdown plays no part in any anchor. The
    -- medal texture is CENTER-anchored (position-only) with its SIZE
    -- set via SetDimensions — ESO's SetScale is ignored on controls
    -- whose size comes from anchors (SetAnchorFill), so the size must
    -- be explicit for the pop to render at all. SetScale then grows
    -- the texture about its own center: pure in-place size increase,
    -- NO anchor compensation. Default gap is 20 % of the size: the
    -- 125 % peak dips 12.5 % of the size below the resting bottom —
    -- well clear of the text at the default gap.
    if mWnd and self.announcerMedal then
        local mSize = self.SV.mlgMedalSize
        self.announcerMedal:SetDimensions(mSize, mSize)
        mWnd:SetDimensions(mSize, mSize)
        -- Label's top edge, relative to the announcer window's
        -- CENTER — a fixed constant (label center at -1, minus
        -- half its height), identical for every banner type.
        local labelTop = -1 - lbl:GetTextHeight() / 2
        mWnd:ClearAnchors()
        mWnd:SetAnchor(BOTTOM, wnd, CENTER, 0, labelTop - self.SV.mlgMedalGap)
        -- A banner is live (the label has text), so the medal shows —
        -- the medal always renders with the text unless Icon Only Mode
        -- hides the text side; there is no text-only announcer anymore.
        mWnd:SetHidden(false)
    end
end

-- The one scale slider drives the whole announcer as one unit:
-- text font, medal size and both gaps are the base values times the
-- scale. Derived values are written back into the legacy SV fields
-- so the rest of the layout code reads them unchanged.
function CritMarker:ApplyAnnouncerScale()
    local s = self.SV.announcerScale or 0.5
    self.SV.mlgFontSize   = math.max(8,  math.floor(ANN_BASE_FONT * s))
    self.SV.mlgMedalSize  = math.max(24, math.floor(ANN_BASE_MEDAL * s))
    self.SV.mlgMedalGap   = math.max(0,  math.floor(ANN_BASE_MEDAL_GAP * s))
    self.SV.mlgTimerGap   = math.max(0,  math.floor(ANN_BASE_TIMER_GAP * s))
    self.SV.mlgTimerFontSize = math.max(8, math.floor(ANN_BASE_TIMER_FONT * s))
    self:ApplyAnnouncerStyle()
end

-- Re-apply font size / custom color from the settings.
function CritMarker:ApplyAnnouncerStyle()
    if not self.announcerLbl then return end
    self.announcerLbl:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", self.SV.mlgFontSize))
    if self.announcerTimerLbl then
        self.announcerTimerLbl:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", self.SV.mlgTimerFontSize))
    end
    if not self.SV.announcerUseTierColors then
        self.announcerLbl:SetColor(self.SV.announcerColor[1],
            self.SV.announcerColor[2], self.SV.announcerColor[3], 1)
    end
    self:FitAnnouncerWindow()
end

-- Flash an MLG streak tier for the full 4 s chain window: when the
-- text disappears, the streak has expired. The matching Halo medal
-- pops above the text, and a small countdown underneath shows how
-- long the chain still has before it falls off.
function CritMarker:Announce(streak, keepVisible)
    local tier = MLG_TIERS[math.min(streak, 10)]
    if not tier then return end
    local streakShown = math.min(streak, 10)
    self:ShowAnnouncerBanner(("%dx %s"):format(streakShown, tier[1]),
        tier[2], tier[3], keepVisible, true)
end

-- Per-life total-kill medal: pops once when the kill count of the
-- current life hits a spree threshold (5/10/15/20/25/30), separate
-- from the 4 s chain and from KILLIONAIRE. The counter resets on
-- death (EVENT_PLAYER_DEAD).
function CritMarker:AnnounceLifeMedal(kills)
    local m = MLG_LIFE_MEDALS[kills]
    if not m or not self.SV.mlgLifeMedals then return end
    if self.SV.mlgSpreeSound then
        PlaySound(SOUNDS.ACHIEVEMENT_AWARDED)
    end
    self:ShowAnnouncerBanner(m[1], m[2], m[3], nil, false)
end

-- KILLJOY medal: pops on native PvP revenge/avenge kills — killing
-- the player who last killed you (REVENGE) or a player who killed a
-- teammate (AVENGED), from EVENT_REVENGE_KILL / EVENT_AVENGE_KILL.
-- A short delay lets the kill's own chain banner pop first, then the
-- medal takes the window on top.
function CritMarker:AnnounceKilljoy(kind)
    if not self.SV.mlgKilljoy then return end
    local text = (kind == "avenge") and "AVENGED!" or "REVENGE!"
    zo_callLater(function()
        self:ShowAnnouncerBanner(text, MLG_KILLJOY_COLOR, "Killjoy.dds", nil, false)
    end, 250)
end

-- Test hook: simulate one per-life kill so the spree-medal sequence
-- can be previewed (5x -> Killing Spree, 10x -> Killing Frenzy ...)
-- without real PvP kills. With no further presses for LIFE_RESET_MS
-- the counter simulates death and resets, so the whole sequence can
-- be re-walked for placement testing.
function CritMarker:TestLifeKill()
    self.lifeKills = self.lifeKills + 1
    if self.lifeKillResetTimer then
        zo_removeCallLater(self.lifeKillResetTimer)
        self.lifeKillResetTimer = nil
    end
    self.lifeKillResetTimer = zo_callLater(function()
        self.lifeKillResetTimer = nil
        if self.lifeKills > 0 then
            self.lifeKills = 0
            ChatPrint("Life reset (simulated death) — spree medals back to 0, " ..
                      "test again from kills 1-5.")
        end
    end, LIFE_RESET_MS)
    self:AnnounceLifeMedal(self.lifeKills)
end

-- Shared banner renderer: text + optional Halo medal + pop + auto
-- hide. Chain announcements pass withCountdown = true so the 4 s
-- chain countdown and hide timing apply; life-medal banners use a
-- fixed 3.5 s hold with no countdown.
function CritMarker:ShowAnnouncerBanner(text, color, medalFile, keepVisible, withCountdown)
    local SV       = self.SV
    local wnd      = self.announcerWnd
    local lbl      = self.announcerLbl
    local timerLbl = self.announcerTimerLbl
    local medal    = self.announcerMedal
    if not wnd or not lbl then return end

    -- Cancel any previous cycle (chain timer / countdown) before a
    -- new announcement takes over the window.
    if self.announceTimer then
        zo_removeCallLater(self.announceTimer)
        self.announceTimer = nil
    end
    if self.refitTimerA then
        zo_removeCallLater(self.refitTimerA)
        self.refitTimerA = nil
    end
    if self.refitTimerB then
        zo_removeCallLater(self.refitTimerB)
        self.refitTimerB = nil
    end
    if self.mlgTimerActive then
        EM:UnregisterForUpdate(self.name .. "_MLG_TIMER")
        self.mlgTimerActive = false
    end
    if timerLbl then timerLbl:SetText("") end

    if SV.announcerUseTierColors and color then
        lbl:SetColor(color[1], color[2], color[3], 1)
    end
    lbl:SetText(text)
    -- Icon Only Mode: text and countdown turned off (alpha 0 keeps
    -- the label metrics live so the window still lays out the icon
    -- at its usual spot); the medal still pops above, alone.
    local iconOnly = SV.mlgIconOnly
    lbl:SetAlpha(iconOnly and 0 or 1)
    if timerLbl then
        timerLbl:SetHidden(iconOnly)
        if iconOnly then timerLbl:SetText("") end
    end

    -- Halo medal (its own window, sized/placed by FitAnnouncerWindow):
    -- swapped per banner; every banner carries a medal (there is no
    -- text-only mode anymore), so the texture is explicitly unhidden
    -- here — a stale hidden state would otherwise keep the icon dead
    -- until a full UI reload.
    if medal then
        if medalFile then
            medal:SetHidden(false)
            medal:SetTexture(MEDAL_DIR .. medalFile)
        else
            medal:SetHidden(true)
            medal:SetScale(1)
        end
    end
    self:FitAnnouncerWindow()
    -- The pop animation keeps both medians, but the LABEL metrics
    -- (GetTextWidth/GetTextHeight) only settle one frame after
    -- SetText, so this first fit can lay out with stale sizes.
    -- Chain banners self-correct through the 100 ms countdown ticks;
    -- life-medal / killjoy banners hold with no countdown, so re-fit
    -- twice to snap the window to the real text size there too.
    self.refitTimerA = zo_callLater(function()
        self.refitTimerA = nil
        self:FitAnnouncerWindow()
    end, 50)
    self.refitTimerB = zo_callLater(function()
        self.refitTimerB = nil
        self:FitAnnouncerWindow()
    end, 200)
    wnd:SetHidden(false)

    -- Pop-in: ONLY the medal bounces, and only by scaling — SetScale
    -- grows a control about its own center, so the icon doubles in
    -- place and its center never moves: 1 -> 1.25, settle through 1.1,
    -- back to 1. The text window is a completely different element
    -- and is never scaled, moved or re-fitted by the pop. Stale steps
    -- from a previously interrupted announcement are ignored via the
    -- sequence counter.
    self.announceSeq = (self.announceSeq or 0) + 1
    local seq = self.announceSeq
    local function ApplyPop(delay, s)
        zo_callLater(function()
            if seq ~= self.announceSeq then return end
            if medal and not medal:IsHidden() then
                medal:SetScale(s)
            end
        end, delay)
    end
    ApplyPop(0, 1.25)
    ApplyPop(35, 1.1)
    ApplyPop(90, 1)

    -- Live countdown under the text: ticks every 100 ms, green while
    -- the chain holds, red in the last second, then clears itself
    -- when the window expires. The label is only re-rendered when the
    -- text or colour actually changes.
    local timerName = self.name .. "_MLG_TIMER"
    if withCountdown and timerLbl and not iconOnly then
        local function ShowCountdown()
            local remaining = self.mlgDeadline - GetFrameTimeMillisecondsFn()
            if remaining <= 0 then
                timerLbl:SetText("")
                self:FitAnnouncerWindow()
                EM:UnregisterForUpdate(timerName)
                self.mlgTimerActive = false
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
        self.mlgTimerActive = true
    end

    self.announceTimer = zo_callLater(function()
        if self.mlgTimerActive then
            EM:UnregisterForUpdate(timerName)
            self.mlgTimerActive = false
        end
        if not SV.mlgShowAlways then
            wnd:SetHidden(true)
            wnd:SetScale(1)
            if self.announcerMedalWnd then self.announcerMedalWnd:SetHidden(true) end
            if medal then medal:SetScale(1) end
        end
        self.announceTimer = nil
    end, keepVisible and 999999 or (withCountdown and MLG_4S or 3500))
end

-- Snap the announcer window back above the hitmarker and restore
-- the default scale.
function CritMarker:ResetAnnouncerPosition()
    local SV = self.SV
    SV.mlgX = 0
    SV.mlgY = -170
    SV.announcerScale = 0.5
    self:ApplyAnnouncerScale()
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
        self.ui:HandleUniversalKill(rawTarget, targetUnitId)
    end)
    EM:AddFilterForEvent(self.name .. "_UNIVERSAL_KILL", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    -- Guards must never count as kills: the fallback is player-on-player
    -- only, so the TARGET has to be a player too (killing a Cyrodiil
    -- guard fired KILLING_BLOW / DIED with an NPC target and bumped the
    -- MLG streak and the per-life counter).
    EM:AddFilterForEvent(self.name .. "_UNIVERSAL_KILL", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    -- Native PvP revenge/avenge kills (the same events the game's own
    -- "REVENGE" / "AVENGED" center-screen announces use): fires when
    -- our kill is a revenge (killed our last killer) or an avenge
    -- (killed someone who killed a teammate). Pops the KILLJOY medal.
    EM:RegisterForEvent(self.name .. "_REVENGE", EVENT_REVENGE_KILL, function()
        self:AnnounceKilljoy("revenge")
    end)
    EM:RegisterForEvent(self.name .. "_AVENGE", EVENT_AVENGE_KILL, function()
        self:AnnounceKilljoy("avenge")
    end)

    EM:RegisterForEvent(self.name .. "_PLAYER_DEAD", EVENT_PLAYER_DEAD, function()
        self.mlgStreak = 0
        self.lifeKills = 0
        if self.lifeKillResetTimer then
            zo_removeCallLater(self.lifeKillResetTimer)
            self.lifeKillResetTimer = nil
        end
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