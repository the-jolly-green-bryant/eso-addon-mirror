--[[ CroZone -------------------------------------------------------------------
  Real-time practice feedback for the bash-build necromancer "bash weave":

      Light Attack -> Skill -> Bash -> (slight delay ~100-500ms) -> Bash -> repeat

  Detection model (see manifest):
    * Light/Heavy attacks and Bash are detected from EVENT_COMBAT_EVENT, which
      ONLY fires when a hit lands on something. => practice on a target dummy.
    * Skill presses come from EVENT_ACTION_SLOT_ABILITY_USED (fires on button
      press, before the resulting light-attack damage lands). The grader is
      built to tolerate that out-of-order arrival.

  ESO Lua 5.1, no external libraries.
--------------------------------------------------------------------------------]]

-- Everything is file-local: CroZone exposes no public API, so it leaks no globals.
-- (The only global it relies on is the SavedVariables table named in the manifest.)
local ADDON_NAME = "CroZone"
local SV_NAME    = "CroZoneSV"

-- Configurable bash ability IDs. 21970 is the base Bash. If your build reports a
-- different id (use "/crozone debug" to find it), add it here or it is fine to
-- have several entries - any of them counts as a bash.
--
-- NOTE on skill rank: ability ids change per skill rank (118720 is Pummeling
-- Goliath Bash at rank I). You don't have to chase those, though: bash detection
-- also falls back to matching the ability NAME (sv.bashName = "Bash"), which catches
-- both "Bash" and "Pummeling Goliath Bash" at every rank. The ids below just make
-- detection instant/precise.
local BASH_IDS = {
    [21970]  = true, -- normal (human-form) Bash
    [118720] = true, -- Pummeling Goliath Bash (rank I) -- see note below re: skill rank
}

-- Buff ability IDs for the Bone Goliath Transformation ultimate (all morphs).
-- Detection ALSO falls back to matching the effect NAME (see sv.goliathName), and
-- because every rank/morph name still contains "Goliath", that name-match makes
-- transformation detection rank-proof on an English client even if the id below is
-- for a different rank. The id just makes detection instant/precise.
local GOLIATH_IDS = {
    [118664] = true, -- Pummeling Goliath transformation buff (rank I)
}

-- Light-attack ability IDs for cases the slot-type flag doesn't cover -- chiefly
-- transformation light attacks (Bone Goliath form), which come through as their
-- own ability rather than a normal ACTION_SLOT_TYPE_LIGHT_ATTACK. Fill in via
-- "/crozone debug": light attack once in form and read the id it prints.
local LA_IDS = {
    -- [<goliath light attack id>] = true,
}

-- ---------------------------------------------------------------------------
-- Saved-variable defaults (all thresholds are tunable).
-- ---------------------------------------------------------------------------
local defaults = {
    -- timing thresholds (ms)
    laToSkillGood   = 350,   -- LA -> Skill is "green" at/under this
    skillToBashGood = 450,   -- Skill -> Bash is "green" at/under this
    bashGapMin      = 100,   -- double-bash window lower bound
    bashGapMax      = 500,   -- double-bash window upper bound
    yellowMargin    = 150,   -- ms grace outside the bash window that grades yellow
    laYellowMult    = 1.6,   -- LA gap up to good*mult grades yellow, else red
    skillYellowMult = 1.6,   -- same idea for Skill -> Bash
    lateLAGrace     = 300,   -- wait this long after a skill for a late-landing LA
    idleResetMs     = 2500,  -- silently abandon a half-finished cycle after this
    dedupeMs        = 80,    -- collapse multi-target hits within this window

    -- behaviour / window
    soundsOn        = true,
    perfectSound    = "ACHIEVEMENT_AWARDED", -- chime when a cycle grades PERFECT
    locked          = false,
    hidden          = false,
    compact         = false, -- small single-line readout for use in live content
    posLeft         = 400,
    posTop          = 300,

    -- detection
    bashName        = "Bash",    -- name fallback so bash detection survives rank changes
    laName          = "",        -- optional name fallback for the in-form light attack
    goliathName     = "Goliath", -- effect-name fallback for the transformation buff

    -- Bone Goliath gating
    goliathOnly     = false, -- only track while the Goliath transform is active

    -- Blast Bones availability tracker (standalone movable icon)
    bbShown         = true,        -- show the Blast Bones ready/cooldown icon
    bbLocked        = false,       -- lock the icon's position
    bbGlow          = true,        -- glow + chime the moment it comes off cooldown
    bbSound         = "ABILITY_SLOTTED", -- chime when Blast Bones is recastable
    bbName          = "Blastbones",-- slot-name match (catches both morphs, every rank)
    bbSize          = 56,          -- icon size in px
    bbPosLeft       = 760,
    bbPosTop        = 520,
    bbMaxFlightMs   = 6000,        -- safety: if no detonation lands in this long, assume up

    -- persisted stats
    totalCycles     = 0,
    perfectCount    = 0,
    bestStreak      = 0,
    bashGapSum      = 0,
}

-- Combat results we treat as a "real" landed hit.
local acceptResults = {
    [ACTION_RESULT_DAMAGE]          = true,
    [ACTION_RESULT_CRITICAL_DAMAGE] = true,
    [ACTION_RESULT_BLOCKED_DAMAGE]  = true,
    [ACTION_RESULT_DAMAGE_SHIELDED] = true,
    [ACTION_RESULT_IMMUNE]          = true,
}

-- Colours
local C_GREEN   = {0.30, 1.00, 0.30}
local C_YELLOW  = {1.00, 0.85, 0.20}
local C_RED     = {1.00, 0.30, 0.30}
local C_NEUTRAL = {0.75, 0.75, 0.75}

-- ---------------------------------------------------------------------------
-- Forward declarations (mutual references) + runtime state.
-- ---------------------------------------------------------------------------
local setLabel, updateNext, updateStats, czSound
local breakCycle, completeCycle, onLA, onBash, onSkillUsed, createUI
local createBBUI, updateBB, startBBGlow                  -- Blast Bones module
local findBBTexture, onBBCast, onBBMaybeDetonate, isBBName  -- Blast Bones detection
local applyChrome              -- re-applies window visibility (toggle + menu state)

local sv                       -- saved vars proxy
local tlw                      -- top-level window
local settingsPanel            -- LibAddonMenu panel control (if LAM present)
local applyLayout              -- switches between full and compact layouts
local lblTitle, lblNext, lblLA, lblSkill, lblBash, lblStatus, lblStats
local lblCompact               -- single condensed line shown only in compact mode

-- Blast Bones icon module state
local bbWin, bbIcon, bbGlow    -- standalone icon window + its texture + glow frame
local bbReady     = true       -- is Blast Bones castable right now?
local bbInFlight  = false       -- skeleton summoned, waiting on its detonation
local bbCastTime  = 0          -- when the current skeleton was summoned (ms)
local bbGlowUntil = 0          -- game-time ms the ready glow fades out at
local bbTexCached = nil        -- last icon texture we pushed to bbIcon

-- State machine: "IDLE" -> "AWAIT_BASH1" -> "AWAIT_BASH2" -> (complete) -> IDLE
local state = "IDLE"
local cycle = nil              -- table describing the in-progress cycle

local lastLATime  = 0          -- timestamp of the most recent landed light attack
local laConsumed  = true       -- has that LA already been paired to a skill?

local lastLADedupe = 0
local lastHADedupe = 0
local lastBashDedupe = 0

local lastActivityTime = 0     -- for the idle reset
local currentStreak = 0        -- runtime only (best streak persists)
local goliathActive = false    -- is the Bone Goliath transformation buff up?
local inMenu = false           -- a fullscreen UI scene (inventory/map/menu) is open
local dbg = false              -- debug-to-chat flag (NOT Lua's `debug` library;
                               -- keep these separate so debug.traceback() still works)

-- ---------------------------------------------------------------------------
-- Small helpers
-- ---------------------------------------------------------------------------
local now = GetGameTimeMilliseconds   -- ms clock used for ALL timing

local function df(fmt, ...)
    d(string.format(fmt, ...))
end

-- Should the cycle tracker be live right now? Always, unless the user restricted
-- it to the Bone Goliath transformation and we aren't transformed.
local function trackingActive()
    return (not sv.goliathOnly) or goliathActive
end

-- A combat hit counts as a bash if its ability id is known, OR (rank-proof
-- fallback) its name contains sv.bashName. That catches "Bash" and "Pummeling
-- Goliath Bash" across every skill rank without needing each id. The id changes
-- per rank; the name does not. Set sv.bashName = "" to disable the fallback.
local function isBashHit(abilityId, abilityName)
    if BASH_IDS[abilityId] then return true end
    if sv.bashName ~= "" and abilityName
       and string.find(abilityName, sv.bashName, 1, true) then
        return true
    end
    return false
end

-- A light attack: normally flagged by its slot type, but transformation light
-- attacks (e.g. Bone Goliath form) arrive as their own ability with no light-attack
-- slot type. Fall back to an id list / optional name match for those. (laName is
-- off by default because a careless name match could collide with the Goliath bash,
-- whose name also contains "Goliath".)
local function isLightAttack(slotType, abilityId, abilityName)
    if slotType == ACTION_SLOT_TYPE_LIGHT_ATTACK then return true end
    if LA_IDS[abilityId] then return true end
    if sv.laName ~= "" and abilityName
       and string.find(abilityName, sv.laName, 1, true) then
        return true
    end
    return false
end

czSound = function(key)
    if not sv or not sv.soundsOn then return end
    local s = key and key ~= "" and SOUNDS[key]
    if s then PlaySound(s) end
end

-- Audition a sound regardless of the master toggle (used when picking one in the
-- settings dropdown). "" / unknown keys are silent no-ops.
local function previewSound(key)
    local s = key and key ~= "" and SOUNDS[key]
    if s then PlaySound(s) end
end

-- Curated chime options for the sound dropdowns: a friendly label -> SOUNDS key.
-- buildMenu filters this to whatever actually exists on the client, so it's safe
-- to list keys that may not be present on every game version.
local SOUND_CHOICES = {
    { label = "None (silent)",   key = "" },
    { label = "Achievement",     key = "ACHIEVEMENT_AWARDED" },
    { label = "Ability ready",   key = "ABILITY_SLOTTED" },
    { label = "Quest complete",  key = "QUEST_COMPLETED" },
    { label = "Book acquired",   key = "BOOK_ACQUIRED" },
    { label = "Notification",    key = "NEW_NOTIFICATION" },
    { label = "Champion point",  key = "CHAMPION_POINTS_COMMITTED" },
    { label = "Skill morph",     key = "ABILITY_MORPH_PURCHASED" },
    { label = "Duel start",      key = "DUEL_START" },
    { label = "Group join",      key = "GROUP_JOIN" },
    { label = "Killing blow",    key = "DEATH_RECAP_KILLING_BLOW_SHOWN" },
    { label = "Justice bonus",   key = "JUSTICE_PICKPOCKET_BONUS" },
    { label = "Mail sent",       key = "MAIL_SENT" },
}

-- Build the parallel {labels}, {values} tables for a LAM dropdown, dropping any
-- key whose sound doesn't exist on this client ("None" is always kept).
local function buildSoundDropdown()
    local labels, values = {}, {}
    for _, c in ipairs(SOUND_CHOICES) do
        if c.key == "" or SOUNDS[c.key] then
            labels[#labels + 1] = c.label
            values[#values + 1] = c.key
        end
    end
    return labels, values
end

setLabel = function(lbl, text, color)
    lbl:SetText(text)
    color = color or C_NEUTRAL
    lbl:SetColor(color[1], color[2], color[3], 1)
end

-- For the compact line we pack several differently-coloured pieces into one
-- label using ESO's inline colour escapes (|cRRGGBB ... |r).
local function hex(c)
    return string.format("%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
end

local function colorize(color, text)
    return string.format("|c%s%s|r", hex(color), text)
end

-- Grade an "upper bound" gap (green <= good, yellow <= good*mult, else red).
-- Returns colour, isGreen.
local function gradeMax(value, good, yellowMult)
    if value <= good then return C_GREEN, true end
    if value <= good * yellowMult then return C_YELLOW, false end
    return C_RED, false
end

-- Grade the double-bash gap against a [min,max] window.
-- Returns colour, isGreen, tagText.
local function gradeBash(gap, mn, mx, margin)
    if gap >= mn and gap <= mx then
        return C_GREEN, true, ""
    elseif gap < mn then
        if gap >= mn - margin then return C_YELLOW, false, "slightly fast" end
        return C_RED, false, "too fast"
    else
        if gap <= mx + margin then return C_YELLOW, false, "slightly slow" end
        return C_RED, false, "too slow"
    end
end

-- ---------------------------------------------------------------------------
-- UI
-- ---------------------------------------------------------------------------
local function makeLabel(suffix, y, font, height)
    local l = WINDOW_MANAGER:CreateControl(ADDON_NAME .. suffix, tlw, CT_LABEL)
    l:SetFont(font or "ZoFontGame")
    l:SetAnchor(TOPLEFT, tlw, TOPLEFT, 14, y)
    l:SetWidth(292)
    if height then l:SetHeight(height) end
    l:SetVerticalAlignment(TEXT_ALIGN_TOP)
    return l
end

createUI = function()
    tlw = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "Window")
    tlw:SetDimensions(320, 300)
    tlw:SetClampedToScreen(true)
    tlw:SetMouseEnabled(true)
    tlw:SetMovable(not sv.locked)
    tlw:ClearAnchors()
    tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.posLeft, sv.posTop)
    tlw:SetHandler("OnMoveStop", function()
        sv.posLeft = tlw:GetLeft()
        sv.posTop  = tlw:GetTop()
    end)

    local bg = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "BG", tlw, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, tlw, TOPLEFT, 0, 0)
    bg:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, 0, 0)
    bg:SetCenterColor(0, 0, 0, 0.78)
    bg:SetEdgeColor(0.40, 0.40, 0.40, 1)
    bg:SetEdgeTexture("", 1, 1, 1)

    lblTitle  = makeLabel("Title",  10,  "ZoFontWinH3")
    lblNext   = makeLabel("Next",   42,  "ZoFontWinH4")
    lblLA     = makeLabel("LA",     82,  "ZoFontGame")
    lblSkill  = makeLabel("Skill",  104, "ZoFontGame")
    lblBash   = makeLabel("Bash",   126, "ZoFontGame")
    lblStatus = makeLabel("Status", 156, "ZoFontWinH3")
    lblStatus:SetMaxLineCount(1)
    lblStats  = makeLabel("Stats",  190, "ZoFontGame", 100)

    -- Compact-mode result line (hidden in full layout). Anchored in applyLayout.
    lblCompact = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "Compact", tlw, CT_LABEL)
    lblCompact:SetFont("ZoFontGame")
    lblCompact:SetWidth(224)
    lblCompact:SetVerticalAlignment(TEXT_ALIGN_TOP)

    setLabel(lblTitle, "CroZone Bash Weave", C_NEUTRAL)
end

-- Switch the window between the full training-dummy layout and the compact
-- single-line readout meant for live content. Reads sv.compact.
applyLayout = function()
    if sv.compact then
        tlw:SetDimensions(244, 52)
        lblTitle:SetHidden(true)
        lblLA:SetHidden(true)
        lblSkill:SetHidden(true)
        lblBash:SetHidden(true)
        lblStatus:SetHidden(true)
        lblStats:SetHidden(true)
        lblCompact:SetHidden(false)

        lblNext:SetFont("ZoFontGameSmall")
        lblNext:SetWidth(224)
        lblNext:ClearAnchors()
        lblNext:SetAnchor(TOPLEFT, tlw, TOPLEFT, 10, 6)

        lblCompact:ClearAnchors()
        lblCompact:SetAnchor(TOPLEFT, tlw, TOPLEFT, 10, 24)
    else
        tlw:SetDimensions(320, 300)
        lblTitle:SetHidden(false)
        lblLA:SetHidden(false)
        lblSkill:SetHidden(false)
        lblBash:SetHidden(false)
        lblStatus:SetHidden(false)
        lblStats:SetHidden(false)
        lblCompact:SetHidden(true)

        lblNext:SetFont("ZoFontWinH4")
        lblNext:SetWidth(292)
        lblNext:ClearAnchors()
        lblNext:SetAnchor(TOPLEFT, tlw, TOPLEFT, 14, 42)
    end
end

updateNext = function()
    if sv.goliathOnly and not goliathActive then
        setLabel(lblNext, "Waiting for Bone Goliath...", C_NEUTRAL)
        return
    end
    local map = {
        IDLE        = "LIGHT ATTACK + SKILL",
        AWAIT_BASH1 = "BASH (1st)",
        AWAIT_BASH2 = "BASH (2nd)",
    }
    local prefix = goliathActive and "|cff8800[GOLIATH]|r " or ""
    setLabel(lblNext, prefix .. "Next: " .. (map[state] or "?"), C_NEUTRAL)
end

updateStats = function()
    local pct = (sv.totalCycles > 0) and (sv.perfectCount / sv.totalCycles * 100) or 0
    local avg = (sv.totalCycles > 0) and (sv.bashGapSum / sv.totalCycles) or 0
    setLabel(lblStats, string.format(
        "Cycles: %d\nPerfect: %d  (%.0f%%)\nStreak: %d    Best (all-time): %d\nAvg bash gap: %.0f ms",
        sv.totalCycles, sv.perfectCount, pct, currentStreak, sv.bestStreak, avg), C_NEUTRAL)
end

-- ---------------------------------------------------------------------------
-- Cycle grading
-- ---------------------------------------------------------------------------
completeCycle = function()
    if not cycle then state = "IDLE"; return end

    -- If the LA never resolved (no light attack ever landed for this cycle),
    -- finalise it as "no LA".
    if cycle.awaitingLA then
        cycle.awaitingLA  = false
        cycle.laResolved  = false
    end

    local skillGap = cycle.bash1Time - cycle.skillTime
    local bashGap  = cycle.bash2Time - cycle.bash1Time

    -- LA -> Skill
    local laGreen, laCol, laCompact
    if cycle.laResolved and cycle.laGap ~= nil then
        laCol, laGreen = gradeMax(math.max(0, cycle.laGap), sv.laToSkillGood, sv.laYellowMult)
        setLabel(lblLA, string.format("LA -> Skill: %d ms", cycle.laGap), laCol)
        laCompact = colorize(laCol, tostring(cycle.laGap))
    else
        laGreen = false
        laCol = C_RED
        setLabel(lblLA, "LA -> Skill: no light attack!", C_RED)
        laCompact = colorize(C_RED, "noLA")
    end

    -- Skill -> Bash
    local sCol, sGreen = gradeMax(skillGap, sv.skillToBashGood, sv.skillYellowMult)
    setLabel(lblSkill, string.format("Skill -> Bash: %d ms", skillGap), sCol)

    -- Bash -> Bash
    local bCol, bGreen, bTag = gradeBash(bashGap, sv.bashGapMin, sv.bashGapMax, sv.yellowMargin)
    local bExtra = (bTag ~= "") and (" (" .. bTag .. ")") or ""
    setLabel(lblBash, string.format("Bash -> Bash: %d ms%s", bashGap, bExtra), bCol)

    -- Tally
    sv.totalCycles = sv.totalCycles + 1
    sv.bashGapSum  = sv.bashGapSum + bashGap

    local perfect = laGreen and sGreen and bGreen
    if perfect then
        sv.perfectCount = sv.perfectCount + 1
        currentStreak = currentStreak + 1
        if currentStreak > sv.bestStreak then sv.bestStreak = currentStreak end
        setLabel(lblStatus, "PERFECT!", C_GREEN)
        czSound(sv.perfectSound)
    else
        currentStreak = 0
        setLabel(lblStatus, "", C_NEUTRAL)
    end

    -- Compact line: three colour-graded numbers + a perfect/streak tail.
    local tail = perfect and colorize(C_GREEN, "PERFECT x" .. currentStreak)
                         or  colorize(C_NEUTRAL, "streak " .. currentStreak)
    lblCompact:SetText(string.format("%s %s %s  %s",
        laCompact, colorize(sCol, tostring(skillGap)), colorize(bCol, tostring(bashGap)), tail))

    updateStats()
    state = "IDLE"
    cycle = nil
    updateNext()
end

breakCycle = function(reason)
    currentStreak = 0
    setLabel(lblStatus, "BROKEN: " .. reason, C_RED)
    lblCompact:SetText(colorize(C_RED, "BROKEN: " .. reason))
    czSound("NEGATIVE_CLICK")
    updateStats()
    state = "IDLE"
    cycle = nil
    updateNext()
end

-- ---------------------------------------------------------------------------
-- Event reactions
-- ---------------------------------------------------------------------------

-- A skill button press starts (or restarts) a cycle.
onSkillUsed = function(slot)
    if slot < 3 or slot > 8 then return end
    if not trackingActive() then return end
    local t = now()
    lastActivityTime = t

    -- A new skill while bashes are still pending = broken cycle. We then start a
    -- fresh cycle from this very press.
    if state == "AWAIT_BASH1" or state == "AWAIT_BASH2" then
        breakCycle("skill too early")
    end

    cycle = { skillTime = t }

    -- Grade the LA -> Skill gap. If a fresh, unconsumed LA landed recently, pair
    -- it now. Otherwise the LA may be landing LATE (tight weave: skill press event
    -- beats its own light-attack damage) -- open a short grace window for it.
    if (not laConsumed) and lastLATime > 0 and (t - lastLATime) <= 1500 then
        cycle.laGap      = t - lastLATime
        cycle.laResolved = true
        cycle.awaitingLA = false
        laConsumed       = true
    else
        cycle.laResolved    = false
        cycle.awaitingLA    = true
        cycle.laGraceDeadline = t + sv.lateLAGrace
    end

    state = "AWAIT_BASH1"
    updateNext()
end

onLA = function(t)
    if not trackingActive() then return end
    lastActivityTime = t

    if state == "AWAIT_BASH1" or state == "AWAIT_BASH2" then
        -- Is this the current cycle's own late-landing light attack?
        if cycle and cycle.awaitingLA and t <= cycle.laGraceDeadline then
            cycle.laGap      = math.max(0, t - cycle.skillTime) -- landed on/just after press
            cycle.laResolved = true
            cycle.awaitingLA = false
            lastLATime = t
            laConsumed = true
            return
        end
        -- Otherwise it is a stray light attack inside the cycle => broken.
        breakCycle("extra light attack")
        lastLATime = t
        laConsumed = false
        return
    end

    -- IDLE: arm this LA so the next skill can pair with it.
    lastLATime = t
    laConsumed = false
end

onBash = function(t)
    if not trackingActive() then return end
    lastActivityTime = t

    if state == "AWAIT_BASH1" then
        if not cycle then state = "IDLE"; updateNext(); return end
        cycle.bash1Time = t
        -- If the late-LA grace has expired with nothing, mark "no LA".
        if cycle.awaitingLA and t > cycle.laGraceDeadline then
            cycle.awaitingLA = false
            cycle.laResolved = false
        end
        state = "AWAIT_BASH2"
        updateNext()
    elseif state == "AWAIT_BASH2" then
        if not cycle then state = "IDLE"; updateNext(); return end
        cycle.bash2Time = t
        completeCycle()
    end
    -- IDLE: stray bash, ignore.
end

-- ---------------------------------------------------------------------------
-- Bone Goliath detection
--
-- The double-bash weave is only used while the Necromancer's Bone Goliath
-- Transformation ultimate (e.g. Pummeling Goliath) is active. We watch the
-- player's buffs and flip goliathActive on/off. Detection matches either a known
-- ability id (GOLIATH_IDS) or the effect name containing sv.goliathName.
-- ---------------------------------------------------------------------------
local function isGoliathEffect(abilityId, effectName)
    if GOLIATH_IDS[abilityId] then return true end
    if sv.goliathName ~= "" and effectName
       and string.find(effectName, sv.goliathName, 1, true) then
        return true
    end
    return false
end

local function setGoliath(active)
    if goliathActive == active then return end
    goliathActive = active
    if not active and state ~= "IDLE" then
        -- Transformation ended mid-cycle: abandon it silently.
        state = "IDLE"
        cycle = nil
    end
    updateNext()
end

local function onEffectChanged(_, changeType, _, effectName, _, beginTime, endTime,
                               _, _, _, _, _, _, _, _, abilityId)
    -- In debug, surface longer player buffs so the Goliath id is easy to spot.
    if dbg and changeType == EFFECT_RESULT_GAINED and (endTime - beginTime) >= 5 then
        df("[CroZone] buff id=%s name=%s dur=%.0fs",
            tostring(abilityId), tostring(effectName), endTime - beginTime)
    end

    -- Blast Bones leaves no separate explosion damage event -- the only thing the
    -- game surfaces is its associated effect. We can't be sure whether that effect
    -- is GAINED at detonation (the blast's ground pool) or FADED at detonation (the
    -- skeleton's lifetime ending), so we accept EITHER edge as the detonation marker.
    -- The in-flight + min-flight guards in onBBMaybeDetonate reject the cast-time
    -- edge and any stale copy, so only the real ~travel-time edge marks "ready".
    if isBBName(effectName)
       and (changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_FADED) then
        onBBMaybeDetonate(effectName)
    end

    if not isGoliathEffect(abilityId, effectName) then return end
    if changeType == EFFECT_RESULT_GAINED then
        setGoliath(true)
    elseif changeType == EFFECT_RESULT_FADED then
        setGoliath(false)
    end
end

-- ---------------------------------------------------------------------------
-- Blast Bones availability module
--
-- The catch with Blast Bones: you can't recast it until the summoned skeleton
-- DETONATES, and its travel time is variable (worse in big content), so the slot
-- cooldown frees up after the *cast* and lies about when you can actually recast.
-- The honest signal is the explosion's damage landing. So this is event-driven:
--   * cast detected via EVENT_ACTION_SLOT_ABILITY_USED  -> dim (in flight)
--   * detonation detected via EVENT_COMBAT_EVENT damage  -> bright + glow + chime
-- Detection is by ability NAME ("Blastbones" matches both morphs at every rank).
-- A safety timeout frees the icon if a detonation event is ever missed.
-- ---------------------------------------------------------------------------
local BB_GLOW_MS     = 800   -- how long the off-cooldown glow flash lasts
local BB_MIN_FLIGHT  = 300   -- ignore "detonation" signals this soon after a cast
                             -- (a real skeleton always needs travel time; this
                             --  filters any cast-time copy of the effect firing)

-- Case-insensitive so it survives whatever casing the combat/effect feeds use
-- (the explosion can report as "blighted blastbones" lowercase, etc.).
isBBName = function(name)
    if not name or name == "" or sv.bbName == "" then return false end
    return string.find(string.lower(name), string.lower(sv.bbName), 1, true) ~= nil
end

-- Find Blast Bones on EITHER bar and return its icon texture (so the indicator
-- stays visible while you weave to the back bar mid-flight). nil if not slotted.
findBBTexture = function()
    for _, cat in ipairs({HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP}) do
        for slot = 3, 8 do
            if isBBName(GetSlotName(slot, cat)) then
                local tex = GetSlotTexture(slot, cat)
                if tex and tex ~= "" then return tex end
            end
        end
    end
    return nil
end

-- Drive the short gold "it's up!" flash. Runs its own fast updater so the fade is
-- smooth, then unregisters itself when done.
local function onBBGlowUpdate()
    local left = bbGlowUntil - now()
    if left <= 0 then
        bbGlow:SetHidden(true)
        bbIcon:SetColor(1, 1, 1, 1)
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "BBGlow")
        return
    end
    local a = left / BB_GLOW_MS                 -- 1 -> 0
    bbGlow:SetEdgeColor(1.0, 0.85, 0.30, a)
    bbIcon:SetColor(1, 1, 0.6 + 0.4 * (1 - a), 1)  -- warm gold pulse back to white
end

startBBGlow = function()
    bbGlowUntil = now() + BB_GLOW_MS
    bbGlow:SetHidden(false)
    czSound(sv.bbSound)
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "BBGlow")
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "BBGlow", 33, onBBGlowUpdate)
end

createBBUI = function()
    bbWin = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "BBWindow")
    bbWin:SetDimensions(sv.bbSize, sv.bbSize)
    bbWin:SetClampedToScreen(true)
    bbWin:SetMouseEnabled(true)
    bbWin:SetMovable(not sv.bbLocked)
    bbWin:ClearAnchors()
    bbWin:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.bbPosLeft, sv.bbPosTop)
    bbWin:SetHandler("OnMoveStop", function()
        sv.bbPosLeft = bbWin:GetLeft()
        sv.bbPosTop  = bbWin:GetTop()
    end)

    -- Dark plate behind the icon so a transparent ability icon stays readable.
    local plate = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "BBPlate", bbWin, CT_BACKDROP)
    plate:SetAnchor(TOPLEFT, bbWin, TOPLEFT, 0, 0)
    plate:SetAnchor(BOTTOMRIGHT, bbWin, BOTTOMRIGHT, 0, 0)
    plate:SetCenterColor(0, 0, 0, 0.5)
    plate:SetEdgeColor(0.40, 0.40, 0.40, 1)
    plate:SetEdgeTexture("", 1, 1, 1)

    bbIcon = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "BBIcon", bbWin, CT_TEXTURE)
    bbIcon:SetAnchor(TOPLEFT, bbWin, TOPLEFT, 3, 3)
    bbIcon:SetAnchor(BOTTOMRIGHT, bbWin, BOTTOMRIGHT, -3, -3)

    -- Gold frame that flashes when Blastbones comes back up (created last = on top).
    bbGlow = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "BBGlow", bbWin, CT_BACKDROP)
    bbGlow:SetAnchor(TOPLEFT, bbWin, TOPLEFT, -2, -2)
    bbGlow:SetAnchor(BOTTOMRIGHT, bbWin, BOTTOMRIGHT, 2, 2)
    bbGlow:SetCenterColor(0, 0, 0, 0)
    bbGlow:SetEdgeColor(1.0, 0.85, 0.30, 1)
    bbGlow:SetEdgeTexture("", 1, 1, 4)
    bbGlow:SetHidden(true)
end

local function stopBBGlow()
    if bbGlow and not bbGlow:IsHidden() then
        bbGlow:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "BBGlow")
    end
end

-- A Blastbones was just summoned: it's now in flight and can't be recast until it
-- detonates. Dim immediately for instant feedback.
onBBCast = function()
    if not sv.bbShown then return end
    if dbg then df("[CroZone] BB cast -> in flight (waiting for detonation)") end
    bbInFlight = true
    bbReady    = false
    bbCastTime = now()
    stopBBGlow()
    bbIcon:SetColor(0.35, 0.35, 0.35, 0.9)
end

-- A damage event landed. If it's our in-flight Blastbones detonating, it's now
-- recastable -> brighten, glow and chime. Fast no-op for every other hit.
onBBMaybeDetonate = function(abilityName)
    if not bbInFlight then return end
    if not isBBName(abilityName) then return end
    if now() - bbCastTime < BB_MIN_FLIGHT then
        if dbg then df("[CroZone] BB '%s' ignored (too soon after cast)", tostring(abilityName)) end
        return
    end
    if dbg then
        df("[CroZone] BB detonation '%s' after %dms -> ready",
            tostring(abilityName), now() - bbCastTime)
    end
    bbInFlight = false
    bbReady    = true
    bbIcon:SetColor(1, 1, 1, 1)
    if sv.bbShown and sv.bbGlow then startBBGlow() end
end

-- Polled ~10/sec: keep the icon's texture and visibility synced, and run the
-- safety timeout. Ready/dim colour is driven by the cast/detonation events above;
-- this only re-asserts it (without fighting the glow animation).
updateBB = function()
    if not sv.bbShown or inMenu then
        bbWin:SetHidden(true)   -- off, or a fullscreen menu is covering the screen
        return
    end

    local tex = findBBTexture()
    if not tex then
        bbWin:SetHidden(true)   -- Blastbones isn't in the build on either bar
        return
    end
    if tex ~= bbTexCached then
        bbTexCached = tex
        bbIcon:SetTexture(tex)
    end
    bbWin:SetHidden(false)

    -- Safety net: never stay stuck dim if a detonation event was missed.
    if bbInFlight and (now() - bbCastTime) > sv.bbMaxFlightMs then
        bbInFlight = false
        bbReady    = true
    end

    -- Re-assert colour, but let the glow updater own it while flashing.
    if bbGlow:IsHidden() then
        bbIcon:SetColor(bbReady and 1 or 0.35, bbReady and 1 or 0.35,
                        bbReady and 1 or 0.35, bbReady and 1 or 0.9)
    end
end

-- Re-apply both windows' visibility from the user toggle (sv.hidden) and whether a
-- fullscreen UI scene is open. Called on the /cz toggle, the settings checkbox, and
-- on every HUD scene transition so menus (inventory, map, options) sit on top.
applyChrome = function()
    tlw:SetHidden(sv.hidden or inMenu)
    updateBB()   -- updateBB already accounts for inMenu
end

-- ---------------------------------------------------------------------------
-- Raw event handlers
-- ---------------------------------------------------------------------------
local function onCombatEvent(_, result, isError, abilityName, _, abilityActionSlotType,
                             _, sourceType, _, _, _, _, _, _, _, _, abilityId)
    if isError then return end
    if not acceptResults[result] then return end

    local t = now()

    if dbg then
        df("[CroZone] CE id=%s slotType=%s result=%s name=%s",
            tostring(abilityId), tostring(abilityActionSlotType),
            tostring(result), tostring(abilityName))
    end

    -- Blast Bones detonation (player-sourced). Cheap no-op unless one is in flight.
    onBBMaybeDetonate(abilityName)

    if isLightAttack(abilityActionSlotType, abilityId, abilityName) then
        if t - lastLADedupe < sv.dedupeMs then return end
        lastLADedupe = t
        onLA(t)
    elseif abilityActionSlotType == ACTION_SLOT_TYPE_HEAVY_ATTACK then
        if t - lastHADedupe < sv.dedupeMs then return end
        lastHADedupe = t
        setLabel(lblStatus, "Heavy attack! Use light attacks.", C_YELLOW)
        czSound("NEGATIVE_CLICK")
    elseif isBashHit(abilityId, abilityName) then
        if t - lastBashDedupe < sv.dedupeMs then return end
        lastBashDedupe = t
        onBash(t)
    end
end

-- A second combat-event feed filtered to PLAYER_PET, in case the engine credits
-- the Blastbones explosion to the summoned skeleton rather than the player. The
-- in-flight guard means it never double-fires with the player-sourced feed.
local function onBBPetCombat(_, result, isError, abilityName)
    if isError then return end
    if not acceptResults[result] then return end
    if dbg then df("[CroZone] PET CE result=%s name=%s", tostring(result), tostring(abilityName)) end
    onBBMaybeDetonate(abilityName)
end

local function onSlotUsed(_, slotNum)
    if dbg then df("[CroZone] ability slot used: %d", slotNum) end
    -- Blast Bones cast: a recast isn't possible until the skeleton detonates.
    if slotNum >= 3 and slotNum <= 8 and isBBName(GetSlotName(slotNum)) then
        onBBCast()
    end
    onSkillUsed(slotNum)
end

local function onCombatState(_, inCombat)
    if not inCombat then
        -- Combat ended: abandon any half-finished cycle and zero the per-fight
        -- scoreboard so cycles, perfects, current streak and avg track per-fight
        -- only. Best streak is the ONE all-time stat: it persists across fights
        -- and reloads, and is cleared only by an explicit /cz reset.
        if state ~= "IDLE" then
            state = "IDLE"
            cycle = nil
            updateNext()
        end
        sv.totalCycles  = 0
        sv.perfectCount = 0
        sv.bashGapSum   = 0
        currentStreak   = 0
        updateStats()

        -- Drop any in-flight Blastbones so the icon isn't stuck dim out of combat.
        bbInFlight = false
        bbReady    = true
    end
end

local function onUpdate()
    if state == "IDLE" then return end
    if now() - lastActivityTime > sv.idleResetMs then
        state = "IDLE"
        cycle = nil
        updateNext()
    end
end

-- ---------------------------------------------------------------------------
-- Slash commands  (/crozone, plus the /cz short alias)
-- ---------------------------------------------------------------------------
local function handleSlash(argstr)
    local args = {}
    for w in string.gmatch(argstr or "", "%S+") do args[#args + 1] = w end
    local cmd = (args[1] or "toggle"):lower()

    if cmd == "" or cmd == "toggle" then
        sv.hidden = not sv.hidden
        applyChrome()
        df("[CroZone] window %s", sv.hidden and "hidden" or "shown")

    elseif cmd == "reset" then
        sv.totalCycles  = 0
        sv.perfectCount = 0
        sv.bestStreak   = 0
        sv.bashGapSum   = 0
        currentStreak   = 0
        updateStats()
        df("[CroZone] stats reset")

    elseif cmd == "lock" then
        sv.locked = not sv.locked
        tlw:SetMovable(not sv.locked)
        df("[CroZone] window %s", sv.locked and "locked" or "unlocked")

    elseif cmd == "gap" then
        local mn = tonumber(args[2])
        local mx = tonumber(args[3])
        if mn and mx and mn < mx then
            sv.bashGapMin = mn
            sv.bashGapMax = mx
            df("[CroZone] double-bash window set to %d-%d ms", mn, mx)
        else
            df("[CroZone] usage: /crozone gap <min> <max>   (current %d-%d ms)",
                sv.bashGapMin, sv.bashGapMax)
        end

    elseif cmd == "compact" then
        sv.compact = not sv.compact
        applyLayout()
        df("[CroZone] compact mode %s", sv.compact and "on" or "off")

    elseif cmd == "settings" or cmd == "config" or cmd == "menu" then
        if settingsPanel and LibAddonMenu2 then
            LibAddonMenu2:OpenToPanel(settingsPanel)
        else
            df("[CroZone] settings panel needs LibAddonMenu-2.0 installed and enabled.")
        end

    elseif cmd == "goliath" then
        sv.goliathOnly = not sv.goliathOnly
        updateNext()
        df("[CroZone] only-during-Bone-Goliath %s (currently %s)",
            sv.goliathOnly and "on" or "off", goliathActive and "transformed" or "not transformed")

    elseif cmd == "bb" then
        sv.bbShown = not sv.bbShown
        updateBB()
        df("[CroZone] Blast Bones icon %s", sv.bbShown and "on" or "off")

    elseif cmd == "bblock" then
        sv.bbLocked = not sv.bbLocked
        bbWin:SetMovable(not sv.bbLocked)
        df("[CroZone] Blast Bones icon %s", sv.bbLocked and "locked" or "unlocked")

    elseif cmd == "bbscan" then
        df("[CroZone] current-bar skill slots:")
        for slot = 3, 8 do
            local name = GetSlotName(slot)
            df("  slot %d: %s%s", slot, tostring(name),
                isBBName(name) and "   <- matches Blastbones" or "")
        end
        df("[CroZone] Blast Bones in build: %s", findBBTexture() and "yes" or "no")

    elseif cmd == "sounds" then
        sv.soundsOn = not sv.soundsOn
        df("[CroZone] sounds %s", sv.soundsOn and "on" or "off")

    elseif cmd == "debug" then
        dbg = not dbg
        df("[CroZone] debug %s -- press your bash to read its abilityId", dbg and "on" or "off")

    else
        df("[CroZone] commands: toggle | compact | settings | goliath | bb | bblock | bbscan | reset | lock | gap <min> <max> | sounds | debug")
    end
end

-- ---------------------------------------------------------------------------
-- LibAddonMenu settings panel (optional dependency - guarded if absent)
-- ---------------------------------------------------------------------------
local function buildMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    settingsPanel = LAM:RegisterAddonPanel(ADDON_NAME .. "Panel", {
        type                = "panel",
        name                = "CroZone",
        displayName         = "CroZone Bash Weave",
        author              = "@ObiJovi",
        version             = "1.0.0",
        registerForRefresh  = true,
        registerForDefaults = true,
    })

    -- Shared sound options for the chime dropdowns (filtered to existing sounds).
    local soundLabels, soundValues = buildSoundDropdown()

    local options = {
        { type = "header", name = "Display" },
        {
            type = "checkbox", name = "Compact mode",
            tooltip = "Small single-line readout for use in live content.",
            getFunc = function() return sv.compact end,
            setFunc = function(v) sv.compact = v; applyLayout() end,
            default = defaults.compact,
        },
        {
            type = "checkbox", name = "Show window",
            getFunc = function() return not sv.hidden end,
            setFunc = function(v) sv.hidden = not v; applyChrome() end,
            default = not defaults.hidden,
        },
        {
            type = "checkbox", name = "Lock window position",
            getFunc = function() return sv.locked end,
            setFunc = function(v) sv.locked = v; tlw:SetMovable(not v) end,
            default = defaults.locked,
        },

        { type = "header", name = "Sounds" },
        {
            type = "checkbox", name = "Enable sound effects",
            tooltip = "Master switch for all CroZone sounds. Turn off if you find them distracting.",
            getFunc = function() return sv.soundsOn end,
            setFunc = function(v) sv.soundsOn = v end,
            default = defaults.soundsOn,
        },
        {
            type = "dropdown", name = "PERFECT chime", width = "full",
            tooltip = "Sound played when a cycle grades PERFECT. Picking one plays a preview.",
            choices = soundLabels, choicesValues = soundValues,
            getFunc = function() return sv.perfectSound end,
            setFunc = function(v) sv.perfectSound = v; previewSound(v) end,
            default = defaults.perfectSound,
        },

        { type = "header", name = "Timing thresholds (ms)" },
        {
            type = "slider", name = "LA -> Skill good", min = 100, max = 1000, step = 10,
            tooltip = "LA -> Skill grades green at or under this.",
            getFunc = function() return sv.laToSkillGood end,
            setFunc = function(v) sv.laToSkillGood = v end,
            default = defaults.laToSkillGood,
        },
        {
            type = "slider", name = "Skill -> Bash good", min = 100, max = 1000, step = 10,
            tooltip = "Skill -> Bash grades green at or under this.",
            getFunc = function() return sv.skillToBashGood end,
            setFunc = function(v) sv.skillToBashGood = v end,
            default = defaults.skillToBashGood,
        },
        {
            type = "slider", name = "Bash gap min", min = 0, max = 1000, step = 10,
            tooltip = "Lower bound of the double-bash window.",
            getFunc = function() return sv.bashGapMin end,
            setFunc = function(v) sv.bashGapMin = v end,
            default = defaults.bashGapMin,
        },
        {
            type = "slider", name = "Bash gap max", min = 0, max = 1500, step = 10,
            tooltip = "Upper bound of the double-bash window.",
            getFunc = function() return sv.bashGapMax end,
            setFunc = function(v) sv.bashGapMax = v end,
            default = defaults.bashGapMax,
        },
        {
            type = "slider", name = "Yellow margin", min = 0, max = 500, step = 10,
            tooltip = "How far outside the bash window still grades yellow rather than red.",
            getFunc = function() return sv.yellowMargin end,
            setFunc = function(v) sv.yellowMargin = v end,
            default = defaults.yellowMargin,
        },
        {
            type = "slider", name = "Late-LA grace", min = 0, max = 600, step = 10,
            tooltip = "How long after a skill press to wait for a late-landing light attack before grading 'no LA'.",
            getFunc = function() return sv.lateLAGrace end,
            setFunc = function(v) sv.lateLAGrace = v end,
            default = defaults.lateLAGrace,
        },
        {
            type = "slider", name = "Idle reset", min = 1000, max = 6000, step = 100,
            tooltip = "Silently abandon a half-finished cycle after this much inactivity.",
            getFunc = function() return sv.idleResetMs end,
            setFunc = function(v) sv.idleResetMs = v end,
            default = defaults.idleResetMs,
        },

        { type = "header", name = "Bone Goliath" },
        {
            type = "description",
            text = "Toggling this mode on will only track your double bash weave " ..
                   "while Pummeling Goliath is active. If your bash isn't detected " ..
                   "while transformed, run '/crozone debug', bash once, and add the " ..
                   "reported id to the BASH_IDS table in CroZone.lua.",
        },
        {
            type = "checkbox", name = "Only active during Bone Goliath",
            tooltip = "Pause tracking until the Bone Goliath transformation buff is up.",
            getFunc = function() return sv.goliathOnly end,
            setFunc = function(v) sv.goliathOnly = v; updateNext() end,
            default = defaults.goliathOnly,
        },

        { type = "header", name = "Blast Bones" },
        {
            type = "description",
            text = "A standalone, movable icon for Blast Bones: dim while the skeleton " ..
                   "is in flight, then bright (with a glow + chime) the instant it " ..
                   "detonates and can be recast. It keys off the explosion landing, not " ..
                   "the cast, so it's honest about long travel times in content. Works on " ..
                   "both morphs and across both bars. Drag it where you want it; " ..
                   "'/cz bblock' to lock. Not detecting? Run '/cz bbscan'.",
        },
        {
            type = "checkbox", name = "Show Blast Bones icon",
            tooltip = "A movable icon that lights up when Blast Bones is off cooldown.",
            getFunc = function() return sv.bbShown end,
            setFunc = function(v) sv.bbShown = v; updateBB() end,
            default = defaults.bbShown,
        },
        {
            type = "checkbox", name = "Glow + chime when ready",
            tooltip = "Flash the icon gold and play a chime the instant Blast Bones is castable again.",
            getFunc = function() return sv.bbGlow end,
            setFunc = function(v) sv.bbGlow = v end,
            default = defaults.bbGlow,
        },
        {
            type = "dropdown", name = "Ready chime", width = "full",
            tooltip = "Sound played when Blast Bones is recastable. Picking one plays a preview.",
            choices = soundLabels, choicesValues = soundValues,
            getFunc = function() return sv.bbSound end,
            setFunc = function(v) sv.bbSound = v; previewSound(v) end,
            default = defaults.bbSound,
        },
        {
            type = "checkbox", name = "Lock Blast Bones icon",
            getFunc = function() return sv.bbLocked end,
            setFunc = function(v) sv.bbLocked = v; bbWin:SetMovable(not v) end,
            default = defaults.bbLocked,
        },
        {
            type = "slider", name = "Icon size", min = 32, max = 96, step = 4,
            tooltip = "Size of the Blast Bones icon in pixels.",
            getFunc = function() return sv.bbSize end,
            setFunc = function(v) sv.bbSize = v; bbWin:SetDimensions(v, v) end,
            default = defaults.bbSize,
        },

        { type = "header", name = "Stats" },
        {
            type = "button", name = "Reset stats",
            warning = "Clears all recorded cycles, perfects and streaks.",
            func = function()
                sv.totalCycles  = 0
                sv.perfectCount = 0
                sv.bestStreak   = 0
                sv.bashGapSum   = 0
                currentStreak   = 0
                updateStats()
            end,
        },

        { type = "header", name = "Debug" },
        {
            type = "checkbox", name = "Debug to chat",
            tooltip = "Print incoming abilityId / slot type to chat so you can identify your bash id.",
            getFunc = function() return dbg end,
            setFunc = function(v) dbg = v end,
            default = false,
        },
    }

    LAM:RegisterOptionControls(ADDON_NAME .. "Panel", options)
end

-- ---------------------------------------------------------------------------
-- Bootstrap
-- ---------------------------------------------------------------------------
local function onAddOnLoaded()
    -- The event is filtered to this addon (see registration below), so this only
    -- ever fires for CroZone. Unregister once we've initialised.
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- Per-character saved variables, separated by server (NA/EU/PTS) via the
    -- GetWorldName() profile so settings never bleed across megaservers. Safe to
    -- add up front on a first release -- there is no prior SV layout to migrate.
    sv = ZO_SavedVars:NewCharacterIdSettings(SV_NAME, 1, nil, defaults, GetWorldName())

    createUI()

    updateNext()
    updateStats()
    setLabel(lblLA,    "LA -> Skill: --",    C_NEUTRAL)
    setLabel(lblSkill, "Skill -> Bash: --",  C_NEUTRAL)
    setLabel(lblBash,  "Bash -> Bash: --",   C_NEUTRAL)
    setLabel(lblStatus, "", C_NEUTRAL)
    setLabel(lblCompact, colorize(C_NEUTRAL, "LA / Skill / Bash"), C_NEUTRAL)
    applyLayout()

    createBBUI()

    buildMenu()

    -- Make game menus (inventory, map, options...) sit on top of our windows:
    -- track whether a fullscreen UI scene is open and hide our windows while it is.
    -- The HUD and HUD-UI scenes are normal gameplay; anything else is a menu.
    local function refreshChrome()
        inMenu = not (SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui"))
        applyChrome()
    end
    HUD_SCENE:RegisterCallback("StateChange", refreshChrome)
    HUD_UI_SCENE:RegisterCallback("StateChange", refreshChrome)
    refreshChrome()   -- set initial state + apply visibility now

    -- Combat events, filtered to the player's own non-error hits.
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, onCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
        REGISTER_FILTER_IS_ERROR, false)

    -- Separate feed for pet-credited damage, so the Blastbones detonation is caught
    -- whether the engine attributes the explosion to the player or the skeleton.
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "BBPet", EVENT_COMBAT_EVENT, onBBPetCombat)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "BBPet", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET,
        REGISTER_FILTER_IS_ERROR, false)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTION_SLOT_ABILITY_USED, onSlotUsed)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, onCombatState)
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "Upd", 200, onUpdate)

    -- Blast Bones icon: refresh texture/visibility + safety timeout ~10/sec. The
    -- ready/dim transitions themselves are event-driven (cast + detonation).
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "BB", 100, updateBB)

    -- Bone Goliath transformation buff (player only).
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, onEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player")

    SLASH_COMMANDS["/crozone"] = handleSlash
    SLASH_COMMANDS["/cz"]      = handleSlash

    df("[CroZone] loaded. /crozone for commands. Practice on a target dummy.")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)
EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED,
    REGISTER_FILTER_ADDON_NAME, ADDON_NAME)
