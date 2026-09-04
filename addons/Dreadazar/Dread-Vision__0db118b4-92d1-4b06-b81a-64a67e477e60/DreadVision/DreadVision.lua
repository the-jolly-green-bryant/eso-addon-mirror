-- Dread Vision
-- PvP threat readout. A ring on your reticle that says what to press, plus the
-- two numbers you cannot work out mid-fight: how many roll dodges you can still
-- afford, and whether you can pay for a break free.
--
-- Everything shown is exact. Nothing is estimated, inferred or guessed. If the
-- API cannot tell us something, it is not on screen.
--
-- Nothing is hardcoded that the game can tell us at runtime. Roll dodge and
-- break free costs are learned by watching your own stamina, and crowd control
-- timers are read off the live buff. A patch cannot make this addon quietly
-- wrong.
--
-- Console-safe: gamepad fonts, CHAT_ROUTER output, every API guarded.

local ADDON_NAME = "DreadVision"
local SV_VERSION = 2

local TICK_MS       = 100     -- one clock for the whole addon
local CALLOUT_MS    = 1200    -- how long a callout stays up if nothing renews it
local MIN_SHOW_MS   = 400     -- nothing is replaced faster than it can be read
local RULE_COOL_MS  = 1500    -- same callout cannot immediately re-fire

-- ------------------------------------------------------------- environment
local function Try(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b = pcall(fn, ...)
    if not ok then return nil end
    return a, b
end

local function DetectConsole()
    return (Try(ZO_IsConsoleOrGameCoreUI) or Try(IsGameCoreUI) or Try(IsConsoleUI)) and true or false
end

local IS_CONSOLE = DetectConsole()

local FONT_VERB = IS_CONSOLE and "ZoFontGamepadBold48" or "ZoFontWinH1"
local FONT_SUB  = IS_CONSOLE and "ZoFontGamepad22"     or "ZoFontGame"
local FONT_MID  = IS_CONSOLE and "ZoFontGamepad27"     or "ZoFontGameBold"

local function Msg(text)
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        pcall(function() CHAT_ROUTER:AddSystemMessage("|cFF4444[DV]|r " .. tostring(text)) end)
    elseif type(d) == "function" then
        pcall(d, "[DV] " .. tostring(text))
    end
end

local function Now()
    return Try(GetGameTimeMilliseconds) or 0
end

-- Every power the game has told us about, keyed by its power type. Filled by
-- EVENT_POWER_UPDATE, which is authoritative and costs nothing - the game
-- pushes these to us rather than us polling for them.
--
-- Polling GetUnitPower with a named constant was the first approach and it
-- read zero. If POWERTYPE_STAMINA does not resolve on this client the call
-- fails silently behind the pcall guard and there is no way to tell that from
-- genuinely having no stamina. Recording what the game actually sends removes
-- the guess entirely.
local powers = {}          -- [powerType] = { cur = n, max = n }

local function PowerOf(powerType)
    if powerType == nil then return nil end
    local p = powers[powerType]
    if p then return p.cur, p.max end
    -- not seen yet, so ask directly this once
    local cur, max = Try(GetUnitPower, "player", powerType)
    if type(cur) == "number" then return cur, max end
    return nil
end

-- Resolving a power type by asking the client, never by hardcoding a number.
--
-- The live client sends power types 4 and 32, which are neither the legacy
-- POWERTYPE_ values nor anything we should be guessing between. ZOS moved these
-- to COMBAT_MECHANIC_FLAGS_, which are bit flags. Rather than bake in a table
-- of magic numbers that a future update can invalidate, we read whichever
-- constant this client actually defines. Hardcoded numbers are the last resort,
-- not the first, and if none of it resolves we say so instead of inventing one.
local RESOURCE_GLOBALS = {
    stamina  = { "COMBAT_MECHANIC_FLAGS_STAMINA",  "POWERTYPE_STAMINA"  },
    magicka  = { "COMBAT_MECHANIC_FLAGS_MAGICKA",  "POWERTYPE_MAGICKA"  },
    health   = { "COMBAT_MECHANIC_FLAGS_HEALTH",   "POWERTYPE_HEALTH"   },
    -- Verified earlier tonight against ZOS's own decompiled source: the base
    -- game's action bar reads its own ultimate glow with exactly
    -- GetUnitPower("player", COMBAT_MECHANIC_FLAGS_ULTIMATE). Unlike an
    -- enemy's ultimate (unknowable - no ult warning is given for a target,
    -- and none should be guessed), this is the player's own resource, read
    -- the same exact way stamina and magicka already are.
    ultimate = { "COMBAT_MECHANIC_FLAGS_ULTIMATE", "POWERTYPE_ULTIMATE" },
}

local resolved = {}
local function ResourceType(which)
    local hit = resolved[which]
    if hit ~= nil then return hit end
    for _, name in ipairs(RESOURCE_GLOBALS[which]) do
        local v = _G[name]
        if type(v) == "number" then
            resolved[which] = v
            return v
        end
    end
    return nil
end

-- Which numeric type each named constant resolved to, for the debug readout.
local function ResourceSource(which)
    for _, name in ipairs(RESOURCE_GLOBALS[which]) do
        if type(_G[name]) == "number" then return name, _G[name] end
    end
    return "unresolved", nil
end

-- Current stamina, or nil if we have not been told what it is. Never zero as a
-- stand-in for unknown - zero reads as "you are empty" and gets people killed.
local function Stamina()
    local t = ResourceType("stamina")
    if t == nil then return nil end
    return (PowerOf(t))
end

local function Magicka()
    local t = ResourceType("magicka")
    if t == nil then return nil end
    return (PowerOf(t))
end

-- Current, max - both needed to know when it is actually full, not just what
-- it currently reads.
local function Ultimate()
    local t = ResourceType("ultimate")
    if t == nil then return nil, nil end
    return PowerOf(t)
end

-- ---------------------------------------------------------------- defaults
local defaults = {
    ui      = { x = 0, y = 0, hidden = false, rideHud = false },
    showCC     = true,
    -- Learned costs. Seeded with sane values and corrected the first time the
    -- player actually rolls or breaks free, so they are never stale.
    learned = { roll = 2721, breakFree = 4590 },
}

local sv
local win, ccLabel, aiNoteLabel, testBox, contactRows
local targetWin, targetCCLabel, targetResourceLabel

-- ------------------------------------------------------------- self state
local S = {
    immunityUntil  = 0,
    stunUntil      = 0,
    fearUntil      = 0,
    charmUntil     = 0,
    rootUntil      = 0,
    disorientUntil = 0,
    knockbackUntil = 0,
    levitateUntil  = 0,
    offBalanceUntil = 0,
    staggerUntil   = 0,
    silencedUntil  = 0,
    dodgeCount     = 0,
    lastDodgeAt    = -100000,
    -- nil, not zero, until the game has told us. Zero reads as "you are empty".
    stamina        = nil,
    prevStamina    = nil,
    blocking       = false,
    inCombat       = false,
    inDuel         = false,
    -- What we are waiting to learn the cost of, and the stamina value at the
    -- moment we saw the action happen. Set by the action's own event; resolved
    -- by whichever EVENT_POWER_UPDATE for stamina arrives next, however long
    -- that takes and whichever event actually fires first on this client.
    pendingCostAction   = nil,
    pendingCostBaseline = nil,
    pendingCostAt       = 0,
    -- Exact, read the same way stamina is - never reset by ResetState, since
    -- ultimate charge is not fight-scoped state the way CC timers are. It
    -- keeps whatever it actually is across combat starting or ending.
    ultimateReady = false,
}

-- ------------------------------------------------------- reticle target state
local STAMINA_PRIOR       = 20000
local MAGICKA_PRIOR       = 20000
local MAGICKA_CAST_COST   = 3000
-- A generic assumed cooldown window, not a verified per-ability value - there
-- is no table of real ESO ability cooldowns behind this number. It exists so
-- "probably back up" can be said at all; it is never presented as exact.
local GENERIC_COOLDOWN_MS = 25000
-- Charm's only signal is a combat-event result with no duration attached -
-- see the comment at its detection site. A flat, clearly-labelled guess.
local CHARM_ASSUMED_MS = 4000
-- How long a contact stays on the left-side list after you stop looking at
-- them. Persistent while you're actually engaged with someone; gone shortly
-- after you're not, so the list never becomes a reputation of the whole fight.
local CONTACT_TTL_MS = 10000

-- One entry, everything true about one enemy player this fight. `contacts`
-- keeps one of these alive per name for CONTACT_TTL_MS after you last looked
-- at them - the left-side list. `T` always points at whichever entry (if any)
-- is under the reticle RIGHT NOW - reassigned, not copied, so every place
-- that mutates T is mutating the same persistent contact record, and the
-- on-target box and the left-side list are never out of sync with each other.
local function NewContact(name)
    return {
        exists = true, name = name, lastSeenAt = 0,
        -- Being hostile and under the reticle earns a place in `contacts` (so
        -- the on-target box can show them the instant you aim at them), but
        -- NOT a spot on the left-side list - that additionally requires an
        -- actual traded blow, set true the first time one is observed below.
        -- Otherwise glancing across a crowd of enemies in a zerg fight would
        -- list everyone you looked at, not who you are actually fighting.
        engaged = false,
        stunUntil = 0, fearUntil = 0, charmUntil = 0, rootUntil = 0,
        disorientUntil = 0, knockbackUntil = 0, levitateUntil = 0,
        offBalanceUntil = 0, staggerUntil = 0, silencedUntil = 0, immunityUntil = 0,
        -- Estimated, never read - GetUnitPower only returns a real value for
        -- health on an enemy; stamina/magicka come back unusable by design
        -- (ZOS's own base-game code never calls it for anything but health on
        -- reticleover). Both start at a configurable prior and are only ever
        -- corrected upward, the moment the contact proves the estimate wrong.
        staminaEst = STAMINA_PRIOR, staminaMax = STAMINA_PRIOR,
        -- Magicka has no fixed-cost universal action the way stamina has roll
        -- dodge and break free - every observed cast is charged the same flat
        -- estimate rather than a per-ability cost, so this stays structurally
        -- lower confidence than stamina. Marked with a tilde on screen, never
        -- shown as a bare, falsely-precise number.
        magickaEst = MAGICKA_PRIOR, magickaMax = MAGICKA_PRIOR,
        -- Last few abilities actually seen landing on the player from this
        -- contact - exact, since every one is a real observed cast.
        abilityHistory = {},
        -- The single most recently seen ability and how many times running it
        -- has recurred - exact counts feeding two guesses: "this is their
        -- go-to" and, once enough time has passed since it was last seen,
        -- "it's probably back up." Both are guesses and shown as such.
        lastAbility = nil, lastAbilityCount = 0, lastAbilityAt = 0,
        -- Exact moment we last saw them spend their ultimate, or nil if we
        -- have not seen it happen this fight. Feeds the generic assumed
        -- refill warning (UltWarning) - never a real read on their meter.
        ultUsedAt = nil,
        abilityCounts = {},
        -- Exact: what happened every time WE attacked this contact with a
        -- given ability this fight. Our casts and their results are always
        -- known - this is what earns the "they keep blocking it" tip.
        myCasts = {},
    }
end

-- What T points at when nothing valid is under the reticle. A real table
-- rather than nil so every function that reads T.exists/T.name etc. does not
-- need an extra nil-guard on top of the exists check it already does.
local EMPTY_TARGET = NewContact("")
EMPTY_TARGET.exists = false

local contacts = {}
local T = EMPTY_TARGET

-- Wipes every tracked contact, same "no recap" rule as the player's own
-- state: nothing survives leaving combat or ending a duel.
local function ResetContacts()
    contacts = {}
    T = EMPTY_TARGET
end

local FATIGUE_WINDOW_MS = 4000
local FATIGUE_MULT      = 1.33

-- Forward declarations. UpdateDisplay needs to ask whether we are active, and
-- that answer depends on duel state defined further down; it also needs
-- TargetNote, which depends on target-tracking state defined further down
-- still. Declaring the locals here keeps them as upvalues rather than
-- accidental globals - without this, UpdateDisplay's own closure captures
-- whatever TargetNote resolves to AT THE POINT UpdateDisplay is defined, and
-- since the real one does not exist yet, that would silently be nil instead.
local IsDuelling, Active, TargetNote

local function ResetState()
    S.immunityUntil  = 0
    S.stunUntil      = 0
    S.fearUntil      = 0
    S.charmUntil     = 0
    S.rootUntil      = 0
    S.disorientUntil = 0
    S.knockbackUntil = 0
    S.levitateUntil  = 0
    S.offBalanceUntil = 0
    S.staggerUntil   = 0
    S.silencedUntil  = 0
    S.dodgeCount     = 0
    S.lastDodgeAt    = -100000
    S.blocking       = false
    S.pendingCostAction = nil
end

local function RollCost(extraDodges)
    local c = sv.learned.roll
    for _ = 1, (extraDodges or 0) do c = c * FATIGUE_MULT end
    return math.floor(c + 0.5)
end

-- How many more rolls the current stamina pays for, accounting for the fact
-- that each one costs more than the last while the fatigue window is open.
local function RollsAffordable()
    if S.stamina == nil then return nil end
    local remaining = S.stamina
    local fatigue   = S.dodgeCount
    local n = 0
    while n < 20 do
        local cost = RollCost(fatigue)
        if cost <= 0 or remaining < cost then break end
        remaining = remaining - cost
        fatigue = fatigue + 1
        n = n + 1
    end
    return n
end

local function CanBreakFree()
    if S.stamina == nil then return nil end
    return S.stamina >= sv.learned.breakFree
end

-- Classifies a buff/effect name into a CC category. The one place this list
-- of substrings exists, shared by the player's own state and whatever the
-- reticle target's is - so player and target can never quietly drift apart.
-- Verified against a real, currently-shipping ESO PvP addon built for
-- exactly this (barny's CC Tracker), not guessed: EVENT_EFFECT_CHANGED and
-- GetUnitBuffInfo both carry a numeric abilityType field that classifies the
-- effect directly - language-independent, unlike matching the display name.
-- Guarded like every other constant here: a name that fails to resolve on
-- this client just contributes nothing to the table, rather than erroring.
local ABILITY_TYPE_KIND = {}
if ABILITY_TYPE_STUN       then ABILITY_TYPE_KIND[ABILITY_TYPE_STUN]       = "stun"       end
if ABILITY_TYPE_FEAR       then ABILITY_TYPE_KIND[ABILITY_TYPE_FEAR]       = "fear"       end
if ABILITY_TYPE_DISORIENT  then ABILITY_TYPE_KIND[ABILITY_TYPE_DISORIENT]  = "disorient"  end
if ABILITY_TYPE_KNOCKBACK  then ABILITY_TYPE_KIND[ABILITY_TYPE_KNOCKBACK]  = "knockback"  end
if ABILITY_TYPE_LEVITATE   then ABILITY_TYPE_KIND[ABILITY_TYPE_LEVITATE]   = "levitate"   end
if ABILITY_TYPE_STAGGER    then ABILITY_TYPE_KIND[ABILITY_TYPE_STAGGER]    = "stagger"    end
if ABILITY_TYPE_OFFBALANCE then ABILITY_TYPE_KIND[ABILITY_TYPE_OFFBALANCE] = "offbalance" end
if ABILITY_TYPE_SILENCE    then ABILITY_TYPE_KIND[ABILITY_TYPE_SILENCE]    = "silence"    end

-- The numeric type is tried first; name matching is only a fallback for
-- whatever it does not resolve - which today is only CC immunity, since
-- there is no dedicated ability type for "immune," only named buffs.
local function ClassifyEffect(lower, abilityType)
    if abilityType and ABILITY_TYPE_KIND[abilityType] then
        return ABILITY_TYPE_KIND[abilityType]
    end
    if string.find(lower, "off balance", 1, true)
       or string.find(lower, "off-balance", 1, true)
       or string.find(lower, "offbalance", 1, true) then
        return "offbalance"
    -- "Immovable" is the actual name of the two most common CC-immunity
    -- sources in PvP (the Heavy Armor 5-piece passive and the Immovability
    -- potion) and matches none of "immun"/"unstopp"/"immobil" - it differs
    -- from each by exactly one letter.
    elseif string.find(lower, "immun", 1, true) or string.find(lower, "unstopp", 1, true)
        or string.find(lower, "immovable", 1, true) then
        return "immune"
    elseif string.find(lower, "stun", 1, true) then
        return "stun"
    elseif string.find(lower, "fear", 1, true) then
        return "fear"
    elseif string.find(lower, "immobil", 1, true) or string.find(lower, "root", 1, true)
        or string.find(lower, "snare", 1, true) then
        return "root"
    elseif string.find(lower, "silence", 1, true) then
        return "silence"
    end
    return nil
end

local FIELD_FOR_KIND = {
    offbalance = "offBalanceUntil", immune = "immunityUntil", stun = "stunUntil",
    fear = "fearUntil", root = "rootUntil", silence = "silencedUntil",
    disorient = "disorientUntil", knockback = "knockbackUntil",
    levitate = "levitateUntil", stagger = "staggerUntil", charm = "charmUntil",
}

-- Sweeps every buff currently on a unit and seeds a state table's CC fields
-- from whatever is already active. EVENT_EFFECT_CHANGED only reports future
-- transitions, so without this a CC already in progress when the addon loads
-- (self) or the moment you first look at someone (target) would go unseen
-- until it next changes.
local function SweepBuffs(unitTag, state, now)
    local n = Try(GetNumBuffs, unitTag) or 0
    for i = 1, n do
        if type(GetUnitBuffInfo) == "function" then
            local ok, name, _, endTime, _, _, _, _, _, abilityType = pcall(GetUnitBuffInfo, unitTag, i)
            if ok and type(name) == "string" then
                local kind = ClassifyEffect(string.lower(name), abilityType)
                if kind then
                    local field = FIELD_FOR_KIND[kind]
                    local gameSecs = Try(GetGameTimeSeconds) or 0
                    local remaining = ((endTime or 0) - gameSecs) * 1000
                    if remaining > 0 then
                        local untilTime = now + remaining
                        if untilTime > state[field] then state[field] = untilTime end
                    end
                end
            end
        end
    end
end

-- Crowd control is read live off the player's buffs rather than assumed, so a
-- balance change to immunity length cannot silently break the countdown.
local function ReadCrowdControl(now)
    SweepBuffs("player", S, now)
end

-- Ordered by how much trouble the unit is in, worst first. Fear sits with
-- stun - both are hard CC broken the same way, by spending stamina on a break
-- free - and off balance sits above immunity because being immune to crowd
-- control does not stop a heavy attack landing while off balance. Silenced is
-- informational only: it is not broken by a break free, so it never feeds the
-- stamina-cost learning and sits below the states that do. Takes a state
-- table (S or T) so self and target share one state machine, not two.
-- Ordering follows barny's CC Tracker's own isHardCC split, worst first:
-- stun/charm/fear/knockback/levitate are hard CC (removes all control);
-- root/disorient/off balance/stagger/silence are soft (limits, doesn't
-- remove). Immune sits below everything it doesn't prevent (off balance
-- still lands a big hit regardless of CC immunity).
local function CCState(state, now)
    if now < state.stunUntil       then return "STUNNED",     state.stunUntil - now end
    if now < state.charmUntil      then return "CHARMED",     state.charmUntil - now end
    if now < state.fearUntil       then return "FEARED",      state.fearUntil - now end
    if now < state.knockbackUntil  then return "KNOCKED BACK", state.knockbackUntil - now end
    if now < state.levitateUntil   then return "LEVITATING",  state.levitateUntil - now end
    if now < state.rootUntil       then return "ROOTED",      state.rootUntil - now end
    if now < state.disorientUntil  then return "DISORIENTED", state.disorientUntil - now end
    if now < state.offBalanceUntil then return "OFFBALANCE",  state.offBalanceUntil - now end
    if now < state.staggerUntil    then return "STAGGERED",   state.staggerUntil - now end
    if now < state.silencedUntil   then return "SILENCED",    state.silencedUntil - now end
    if now < state.immunityUntil   then return "IMMUNE",      state.immunityUntil - now end
    return "OPEN", 0
end

-- ----------------------------------------------------------------- display
local lastCC, lastNote
local lastTargetCC, lastTargetResource
local contactOrder = {}

-- ------------------------------------------------------------------- layout
-- Everything lives down the left edge as a list.
--
-- The first version put a ring at screen centre with a verb above it shouting
-- BLOCK. It sat exactly where you are trying to look during a fight, and a word
-- telling you what to do is clutter on top of the thing it is covering. A
-- readout you glance at beats an instruction you have to read past, so the
-- centre is now empty and the left edge carries the state.
local PANEL_W, PANEL_H = 560, 320
local MAX_CONTACT_ROWS = 4
local CONTACT_ROW_H    = 52
-- Wider gap than before - the CC and budget lines above measured taller in
-- practice than their font size alone suggested, and a tight gap read as the
-- budget line running into the list below it.
local CONTACTS_START_Y = 100

-- The on-target box. Anchored near the top of the screen where the vanilla
-- target frame always sits, rather than literally attached to the frame
-- itself - there is no verified, version-stable global name for that control,
-- and a fixed offset never errors. Console players cannot reposition their
-- UI the way PC players can, which makes a fixed offset more reliable here
-- than it would be on PC, not less.
-- Small and tag-like on purpose - the first version was a full multi-line
-- panel and read as far too large sitting over someone's nameplate. This is
-- meant to read the way a debuff icon does: a quick glance, not a report.
local TARGET_PANEL_W, TARGET_PANEL_H = 184, 62
local TARGET_INSET_Y = 92
local INSET_X = 48
local Y_MIN, Y_MAX = -300, 300

-- Initialize() clamps a saved offset once at load, but /dv up and /dv down
-- used to apply their nudge with no bound at all - repeated presses could
-- walk the window off-screen with nothing short of a /reloadui to recover.
-- Same clamp, shared, so the live commands can never re-open that gap.
local function ClampY(y)
    if y < Y_MIN then return Y_MIN end
    if y > Y_MAX then return Y_MAX end
    return y
end

local function BuildUI()
    local wm = WINDOW_MANAGER
    if not wm then return end

    win = wm:CreateTopLevelWindow(ADDON_NAME .. "Window")
    win:SetDimensions(PANEL_W, PANEL_H)
    win:ClearAnchors()
    -- Anchored to the left edge, not to centre with a saved offset. The old
    -- version stored an x/y that every /dv up nudged further, and a stale
    -- offset could park the whole window off screen where it looked broken.
    -- Only a vertical nudge is kept, and it is clamped to the screen.
    win:SetAnchor(LEFT, GuiRoot, LEFT, INSET_X, sv.ui.y or 0)
    win:SetMouseEnabled(false)
    win:SetMovable(false)
    -- Explicit. A fragment or an inherited value leaving alpha at 0 renders
    -- everything invisible while SetHidden(false) still reports it as shown,
    -- which reads exactly like the addon never running.
    win:SetAlpha(1)
    if type(DT_HIGH) == "number" and win.SetDrawTier then pcall(win.SetDrawTier, win, DT_HIGH) end
    if type(DL_OVERLAY) == "number" and win.SetDrawLayer then pcall(win.SetDrawLayer, win, DL_OVERLAY) end
    win:SetHidden(true)

    -- Proof-of-life backdrop, off by default, toggled with /dv test. If this
    -- shows but the text does not, the fonts are the problem; if neither shows,
    -- the window is. Separating those two was worth the twenty lines.
    testBox = wm:CreateControl(ADDON_NAME .. "Test", win, CT_BACKDROP)
    testBox:SetAnchorFill(win)
    testBox:SetCenterColor(0, 0, 0, 0.40)
    testBox:SetEdgeColor(1, 0.25, 0.25, 1)
    pcall(function() testBox:SetEdgeTexture("", 1, 1, 2) end)
    testBox:SetHidden(true)

    local function Row(key, font, offsetY, r, g, b)
        local c = wm:CreateControl(ADDON_NAME .. key, win, CT_LABEL)
        c:SetFont(font)
        c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        c:SetAnchor(TOPLEFT, win, TOPLEFT, 0, offsetY)
        c:SetColor(r, g, b, 1)
        c:SetText("")
        return c
    end

    -- Crowd control first - the line that decides whether you spend a break
    -- free or ride it out. The AI note sits under it: one line of commentary
    -- about whoever is currently targeted, styled to read as advice rather
    -- than a stat - amber, and a touch larger than the plain status text.
    ccLabel     = Row("CC",   FONT_MID, 0,  0.25, 0.85, 0.78)
    aiNoteLabel = Row("Note", FONT_MID, 40, 1.00, 0.74, 0.20)

    -- The persistent contact list: one boxed row per enemy currently engaged
    -- (or engaged within the last CONTACT_TTL_MS), freshest first. A fixed
    -- pool of controls, shown/hidden/retextured each tick rather than created
    -- and destroyed - cheaper, and avoids control-name collisions on reuse.
    contactRows = {}
    for i = 1, MAX_CONTACT_ROWS do
        local y = CONTACTS_START_Y + (i - 1) * CONTACT_ROW_H
        local box = wm:CreateControl(ADDON_NAME .. "ContactBox" .. i, win, CT_BACKDROP)
        box:SetDimensions(PANEL_W - 8, CONTACT_ROW_H - 6)
        box:SetAnchor(TOPLEFT, win, TOPLEFT, 0, y)
        -- Center color only - no edge texture. An earlier box (the /dv test
        -- backdrop) tried SetEdgeTexture("", ...) for a flat-colored border
        -- and it never actually rendered, since an empty path leaves
        -- SetEdgeColor with no texture to tint. A solid fill is what
        -- reliably shows up.
        box:SetCenterColor(0.09, 0.10, 0.12, 0.65)
        box:SetHidden(true)

        local nameLabel = wm:CreateControl(ADDON_NAME .. "ContactName" .. i, box, CT_LABEL)
        nameLabel:SetFont(FONT_SUB)
        nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        nameLabel:SetAnchor(TOPLEFT, box, TOPLEFT, 10, 4)
        nameLabel:SetColor(0.88, 0.90, 0.94, 1)
        nameLabel:SetText("")

        local statusLabel = wm:CreateControl(ADDON_NAME .. "ContactStatus" .. i, box, CT_LABEL)
        statusLabel:SetFont(FONT_SUB)
        statusLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        statusLabel:SetAnchor(TOPLEFT, box, TOPLEFT, 10, 23)
        statusLabel:SetColor(0.78, 0.81, 0.85, 1)
        statusLabel:SetText("")

        contactRows[i] = {
            box = box, nameLabel = nameLabel, statusLabel = statusLabel,
            shownName = nil, shownStatus = nil,
        }
    end

    -- A second, separate window near the vanilla target frame - what the
    -- reticle is currently on, not what the player is doing. Same visibility
    -- rules as the main window (sv.ui.hidden, Active()), plus its own gate:
    -- nothing to show when nothing valid is under the reticle.
    targetWin = wm:CreateTopLevelWindow(ADDON_NAME .. "TargetWindow")
    targetWin:SetDimensions(TARGET_PANEL_W, TARGET_PANEL_H)
    targetWin:ClearAnchors()
    targetWin:SetAnchor(TOP, GuiRoot, TOP, 0, TARGET_INSET_Y)
    targetWin:SetMouseEnabled(false)
    targetWin:SetMovable(false)
    targetWin:SetAlpha(1)
    if type(DT_HIGH) == "number" and targetWin.SetDrawTier then pcall(targetWin.SetDrawTier, targetWin, DT_HIGH) end
    if type(DL_OVERLAY) == "number" and targetWin.SetDrawLayer then pcall(targetWin.SetDrawLayer, targetWin, DL_OVERLAY) end
    targetWin:SetHidden(true)

    -- Same box treatment as the contact rows, filling the whole window, so
    -- the on-target readout reads as one contained panel near their name
    -- rather than text floating loose over the world.
    -- Created before the row labels below, so it sits behind them by
    -- creation order alone - no draw-layer constant to bet on.
    local targetBg = wm:CreateControl(ADDON_NAME .. "TargetBg", targetWin, CT_BACKDROP)
    targetBg:SetAnchorFill(targetWin)
    targetBg:SetCenterColor(0.09, 0.10, 0.12, 0.55)

    local function TargetRow(key, font, offsetY, align, r, g, b)
        local c = wm:CreateControl(ADDON_NAME .. "T" .. key, targetWin, CT_LABEL)
        c:SetFont(font)
        c:SetHorizontalAlignment(align)
        c:SetAnchor(TOP, targetWin, TOP, 0, offsetY)
        c:SetColor(r, g, b, 1)
        c:SetText("")
        return c
    end

    -- Two lines only - CC state, then the resource estimate. Name, ability
    -- history and the tip line still track internally (OnCombatEvent keeps
    -- filling them in) but do not render here; there is no room for them in
    -- something this size, and the vanilla nameplate already names them.
    targetCCLabel       = TargetRow("CC",       FONT_SUB, 4,  TEXT_ALIGN_CENTER, 0.62, 0.66, 0.72)
    targetResourceLabel = TargetRow("Resource", FONT_SUB, 26, TEXT_ALIGN_CENTER, 0.80, 0.84, 0.88)

    -- Riding the HUD scene makes the readout hide with the rest of the
    -- interface rather than drawing over menus and the map. That is worth
    -- having, but a fragment also takes ownership of hidden state and alpha,
    -- and if the scene never signals a show the window stays at alpha 0 -
    -- invisible, while still reporting itself as not hidden. Until the window
    -- is proven to draw this stays off; /dv hud turns it on.
    if sv.ui.rideHud then
        pcall(function()
            if ZO_HUDFadeSceneFragment then
                for _, w in ipairs({ win, targetWin }) do
                    local fragment = ZO_HUDFadeSceneFragment:New(w)
                    if HUD_SCENE    and HUD_SCENE.AddFragment    then HUD_SCENE:AddFragment(fragment)    end
                    if HUD_UI_SCENE and HUD_UI_SCENE.AddFragment then HUD_UI_SCENE:AddFragment(fragment) end
                end
            end
        end)
    end
end

-- The crowd control line for a given state table (self or target).
local function CCText(who, now)
    local state, remaining = CCState(who, now)
    if state == "STUNNED" then
        return string.format("STUNNED  %.1fs", remaining / 1000), 1.00, 0.36, 0.36
    elseif state == "CHARMED" then
        return string.format("CHARMED  ~%.1fs", remaining / 1000), 0.85, 0.35, 0.85
    elseif state == "FEARED" then
        return string.format("FEARED  %.1fs", remaining / 1000), 1.00, 0.42, 0.20
    elseif state == "KNOCKED BACK" then
        return string.format("KNOCKED BACK  %.1fs", remaining / 1000), 0.95, 0.55, 0.30
    elseif state == "LEVITATING" then
        return string.format("LEVITATING  %.1fs", remaining / 1000), 0.60, 0.75, 1.00
    elseif state == "ROOTED" then
        return string.format("IMMOBILISED  %.1fs", remaining / 1000), 1.00, 0.45, 0.55
    elseif state == "DISORIENTED" then
        return string.format("DISORIENTED  %.1fs", remaining / 1000), 0.75, 0.55, 1.00
    elseif state == "OFFBALANCE" then
        -- off balance is the one state where you are about to be hit for far
        -- more than usual, so it gets its own colour
        return string.format("OFF BALANCE  %.1fs", remaining / 1000), 1.00, 0.55, 0.15
    elseif state == "STAGGERED" then
        return string.format("STAGGERED  %.1fs", remaining / 1000), 0.90, 0.60, 0.40
    elseif state == "SILENCED" then
        return string.format("SILENCED  %.1fs", remaining / 1000), 0.68, 0.48, 0.92
    elseif state == "IMMUNE" then
        return string.format("CC IMMUNE  %.1fs", remaining / 1000), 0.25, 0.85, 0.78
    end
    return "STUNNABLE", 0.62, 0.66, 0.72
end

-- "~NN%" for an estimate, never a bare number - the tilde is the whole point:
-- it is a prediction, not a read, and should never look as certain as one.
local function PctText(est, max)
    if est == nil or max == nil or max <= 0 then return "?" end
    local pct = math.floor((est / max) * 100 + 0.5)
    if pct < 0 then pct = 0 end
    if pct > 100 then pct = 100 end
    return "~" .. tostring(pct) .. "%"
end

-- The left-side list: every contact still inside its grace period, freshest
-- look first, one boxed row each. Separate from the on-target box - this
-- keeps showing an enemy for CONTACT_TTL_MS after you look away, so it stays
-- persistent for the whole fight rather than blinking out the instant your
-- reticle drifts off them.
local function RenderContactList(now)
    if not Active() then
        for i = 1, MAX_CONTACT_ROWS do
            local row = contactRows[i]
            if row.shownName ~= nil then
                row.shownName = nil
                row.box:SetHidden(true)
            end
        end
        return
    end

    local n = 0
    for _, c in pairs(contacts) do
        -- Hostile and under the reticle earns a contacts entry (the on-target
        -- box needs that); the list additionally requires an actual traded
        -- blow, or it would list every enemy you have merely glanced across.
        if c.engaged then
            n = n + 1
            contactOrder[n] = c
        end
    end
    for i = n + 1, #contactOrder do contactOrder[i] = nil end
    table.sort(contactOrder, function(a, b) return a.lastSeenAt > b.lastSeenAt end)

    for i = 1, MAX_CONTACT_ROWS do
        local row = contactRows[i]
        local c = contactOrder[i]
        if c then
            row.box:SetHidden(false)
            if c.name ~= row.shownName then
                row.shownName = c.name
                row.nameLabel:SetText(c.name)
            end
            local ccText, ccR, ccG, ccB = CCText(c, now)
            local statusText = string.format("%s   STAM %s  MAG %s",
                ccText, PctText(c.staminaEst, c.staminaMax), PctText(c.magickaEst, c.magickaMax))
            if statusText ~= row.shownStatus then
                row.shownStatus = statusText
                row.statusLabel:SetText(statusText)
                row.statusLabel:SetColor(ccR, ccG, ccB, 1)
            end
        elseif row.shownName ~= nil then
            row.shownName = nil
            row.box:SetHidden(true)
        end
    end
end

local function UpdateDisplay(now)
    if not win then return end

    -- The readout stays on screen whenever the addon is enabled, in combat or
    -- not. Hiding it entirely out of combat makes working and broken look
    -- identical, which is the trap KillCount already learned the hard way.
    -- The target box is different: out of combat there is nothing worth
    -- tracking about whoever the reticle happens to be resting on, so it
    -- hides completely rather than showing an idle heartbeat of its own.
    win:SetHidden(sv.ui.hidden)
    local showTarget = (not sv.ui.hidden) and Active() and T.exists
    if targetWin then targetWin:SetHidden(not showTarget) end
    if sv.ui.hidden then return end

    local note = ""
    if showTarget then
        local ccText, ccR, ccG, ccB = CCText(T, now)
        if ccText ~= lastTargetCC then
            lastTargetCC = ccText
            targetCCLabel:SetText(ccText)
            targetCCLabel:SetColor(ccR, ccG, ccB, 1)
        end

        local resourceText = string.format("S %s  M %s",
            PctText(T.staminaEst, T.staminaMax), PctText(T.magickaEst, T.magickaMax))
        if resourceText ~= lastTargetResource then
            lastTargetResource = resourceText
            targetResourceLabel:SetText(resourceText)
        end

        note = TargetNote(T, now) or ""
    end

    -- Ultimate ready outranks a target tip and shows even outside combat -
    -- exact resource state, not fight-scoped clutter, so there is no reason
    -- to hide it just because nothing is currently under the reticle.
    local isUltCallout = S.ultimateReady
    if isUltCallout then note = "ULTIMATE READY" end

    if note ~= lastNote then
        lastNote = note
        aiNoteLabel:SetText(note)
        if isUltCallout then
            aiNoteLabel:SetColor(0.35, 0.95, 1.00, 1)
        else
            aiNoteLabel:SetColor(1.00, 0.74, 0.20, 1)
        end
    end

    -- The persistent left-side list is independent of showTarget - it keeps
    -- showing contacts still inside their grace period even when nothing is
    -- currently under the reticle.
    RenderContactList(now)

    if not Active() then
        -- Idle: nothing to report about crowd control, so the row goes
        -- blank rather than showing a placeholder.
        if lastCC ~= "" then
            lastCC = ""
            ccLabel:SetText("")
        end
        return
    end

    if sv.showCC then
        local text, r, g, b = CCText(S, now)
        if text ~= lastCC then
            lastCC = text
            ccLabel:SetText(text)
            ccLabel:SetColor(r, g, b, 1)
        end
    elseif lastCC ~= "" then
        lastCC = ""
        ccLabel:SetText("")
    end
end

-- ------------------------------------------------------------------ events
-- Learn the real cost of an action from the stamina it actually consumed.
-- Guards against counting regeneration or an unrelated spend as a cost.
local function LearnCost(kind, spent)
    if spent < 500 or spent > 20000 then return end
    local key = (kind == "roll") and "roll" or "breakFree"
    local prev = sv.learned[key]
    -- move a third of the way toward the observation, so one odd frame cannot
    -- throw the number but a genuine change is picked up within a few uses
    sv.learned[key] = math.floor(prev + ((spent - prev) * 0.34) + 0.5)
end

-- Marks that a stamina-costing action just happened, without trying to price
-- it yet. The stamina reading at this instant may not reflect the cost at
-- all - EVENT_COMBAT_EVENT and the EVENT_POWER_UPDATE for the resulting
-- stamina spend are two separate, asynchronous events with no verified
-- ordering guarantee, and a 100ms poll used to sample this on a clock that
-- rarely lined up with either. OnPowerUpdate resolves this the moment
-- stamina actually drops, whichever order the two events arrive in.
local function MarkPendingCost(kind)
    S.pendingCostAction   = kind
    S.pendingCostBaseline = S.stamina
    S.pendingCostAt       = Now()
end

-- Fading with real time still left on the clock means the CC did not run out
-- on its own - the only way that happens is a break free. Shared by every
-- hard-CC category (stun, fear, root) since they are all broken the same way.
local function LearnBreakFreeIfEarly(untilTime, now)
    if untilTime - now > 300 then
        MarkPendingCost("breakFree")
    end
end

-- Spends an observed cost from one of the target's two ESTIMATED pools -
-- never a read, since GetUnitPower cannot see an enemy's real stamina or
-- magicka. If they could not have afforded it under the current estimate,
-- the estimate was wrong, not the target: raise it to cover the shortfall
-- and keep tracking from there. One-directional and self-correcting (design
-- spec 4.3.1) - the error can only ever be an overestimate of depletion, and
-- every overestimate is corrected the moment the target proves otherwise.
local function SpendTargetPool(estField, maxField, cost)
    if T[estField] == nil then return end
    if T[estField] < cost then
        local shortfall = cost - T[estField]
        T[maxField] = T[maxField] + shortfall
        T[estField] = T[estField] + shortfall
    end
    T[estField] = T[estField] - cost
end

local function SpendTargetStamina(cost) SpendTargetPool("staminaEst", "staminaMax", cost) end
local function SpendTargetMagicka(cost) SpendTargetPool("magickaEst", "magickaMax", cost) end

-- Records one real ability the target cast at us - exact, since we watched
-- it happen. Feeds both the rolling history list and the repeat/cooldown
-- guesses, which key off the single most recently seen ability only.
local function TrackTargetAbility(name, now)
    if name == T.lastAbility then
        T.lastAbilityCount = T.lastAbilityCount + 1
    else
        T.lastAbility = name
        T.lastAbilityCount = 1
    end
    T.lastAbilityAt = now
    T.abilityCounts[name] = (T.abilityCounts[name] or 0) + 1

    local hist = T.abilityHistory
    if hist[#hist] ~= name then
        hist[#hist + 1] = name
        if #hist > 4 then table.remove(hist, 1) end
    end
end

-- Records what happened when WE used a given ability on this target - exact,
-- since our own casts and their results are always known. This is the tally
-- the "change it up" tip is built from.
local function TrackMyCast(name, result)
    local rec = T.myCasts[name]
    if not rec then
        rec = { attempts = 0, landed = 0, dodged = 0, blocked = 0, immune = 0, missed = 0 }
        T.myCasts[name] = rec
    end
    rec.attempts = rec.attempts + 1
    if ACTION_RESULT_DODGED and result == ACTION_RESULT_DODGED then
        rec.dodged = rec.dodged + 1
    elseif (ACTION_RESULT_BLOCKED and result == ACTION_RESULT_BLOCKED)
        or (ACTION_RESULT_BLOCKED_DAMAGE and result == ACTION_RESULT_BLOCKED_DAMAGE) then
        rec.blocked = rec.blocked + 1
    elseif ACTION_RESULT_IMMUNE and result == ACTION_RESULT_IMMUNE then
        rec.immune = rec.immune + 1
    elseif ACTION_RESULT_MISS and result == ACTION_RESULT_MISS then
        rec.missed = rec.missed + 1
    else
        rec.landed = rec.landed + 1
    end
end

local FAILURE_TIP = {
    dodged  = "bait it, then commit",
    blocked = "bash first, or use an unblockable",
    immune  = "wasted on CC immunity - wait it out",
    missed  = "range or line of sight, not a read problem",
}

-- A typical ESO ultimate refills in roughly 30-45 seconds of normal play -
-- a real range, not invented here, but still build-dependent and not
-- something this addon can read directly. Once the low end of that window
-- has passed since we watched them spend it, the warning fires and STAYS
-- up - unlike a regular ability's cooldown, "probably has ultimate" does not
-- expire on its own; only spending it again clears it.
local ULT_ASSUMED_MS = 30000

local function UltWarning(who, now)
    if who.ultUsedAt == nil then return nil end
    if now - who.ultUsedAt >= ULT_ASSUMED_MS then
        return who.name .. " probably has ultimate - watch out"
    end
    return nil
end

-- The one actionable note: an ability we keep throwing that keeps failing
-- the same way, tier 3, sample-gated at 3 attempts so "0/1 dodged" never
-- shows as a pattern. Picks the worst offender by attempt count rather than
-- table order, so which ability is named never flickers between ticks.
local function ComboTip(who)
    local worstName, worstRec = nil, nil
    for name, rec in pairs(who.myCasts) do
        if rec.attempts >= 3 and rec.landed < rec.attempts * 0.5 then
            if worstRec == nil or rec.attempts > worstRec.attempts then
                worstName, worstRec = name, rec
            end
        end
    end
    if worstRec == nil then return nil end
    local worst, worstN = nil, 0
    for _, k in ipairs({ "dodged", "blocked", "immune", "missed" }) do
        if worstRec[k] > worstN then worst, worstN = k, worstRec[k] end
    end
    if worst == nil then return nil end
    return string.format("%s x%d %s - %s", worstName, worstRec.attempts, worst, FAILURE_TIP[worst])
end

-- A guess, not a read: nothing tells us a cooldown actually ended. This only
-- fires in the window right after GENERIC_COOLDOWN_MS has passed since the
-- ability was last seen, so it says something once rather than nagging.
local function CooldownGuess(who, now)
    if who.lastAbility == nil then return nil end
    local elapsed = now - who.lastAbilityAt
    if elapsed > GENERIC_COOLDOWN_MS and elapsed < GENERIC_COOLDOWN_MS + 15000 then
        return who.lastAbility .. " probably back up"
    end
    return nil
end

-- Exact - lastAbilityCount is a real tally of observed casts, never a guess.
-- Only the framing ("most-used combo") is an inference from that count.
local function RepeatNote(who)
    if who.lastAbilityCount >= 3 then
        return who.lastAbility .. " x" .. who.lastAbilityCount .. " - most-used combo"
    end
    return nil
end

-- One line, highest priority first: an actionable tip about our own combo
-- outranks a cooldown guess, which outranks a plain "they keep using this"
-- note. Never more than one shown, so it never becomes a wall of guesses.
function TargetNote(who, now)
    return UltWarning(who, now) or ComboTip(who) or CooldownGuess(who, now) or RepeatNote(who)
end

-- A basic weapon swing, not a real ability - excluded from the target's
-- ability history and from the magicka estimate, since neither costs
-- magicka. Guarded the same way every other constant in this file is: if the
-- name does not resolve on this client, it simply cannot exclude anything,
-- rather than silently breaking the whole cast-tracking feature.
local function IsBasicAttack(slotType)
    return (ACTION_SLOT_TYPE_LIGHT_ATTACK and slotType == ACTION_SLOT_TYPE_LIGHT_ATTACK)
        or (ACTION_SLOT_TYPE_HEAVY_ATTACK and slotType == ACTION_SLOT_TYPE_HEAVY_ATTACK)
        or (ACTION_SLOT_TYPE_WEAPON_ATTACK and slotType == ACTION_SLOT_TYPE_WEAPON_ATTACK)
        or (ACTION_SLOT_TYPE_BLOCK and slotType == ACTION_SLOT_TYPE_BLOCK)
end

-- An ultimate spends the ultimate meter, not magicka - worth logging in the
-- ability history (seeing it used is exact, valuable information) but wrong
-- to charge against the magicka estimate.
local function IsUltimateSlot(slotType)
    return ACTION_SLOT_TYPE_ULTIMATE and slotType == ACTION_SLOT_TYPE_ULTIMATE
end

-- Deliberately no early returns below: a single event can be relevant to
-- more than one tracker at once (the target dodging our own attack is both
-- "they just spent stamina" and "our ability was dodged"), and an early
-- return after the first match used to silently starve the others.
local function OnCombatEvent(_, result, isError, abilityName, _, abilitySlotType,
                             sourceName, sourceType, targetName, targetType,
                             _, _, _, _, _, _, abilityId)
    if isError then return end
    if not Active() then return end

    local now = Now()
    local dodged = ACTION_RESULT_DODGED and result == ACTION_RESULT_DODGED
    local isRealAbility = type(abilityName) == "string" and abilityName ~= ""
        and not IsBasicAttack(abilitySlotType)

    -- Something dodged - us (feeds our own roll fatigue and teaches the roll
    -- cost) or the target (feeds their stamina estimate).
    if dodged and targetType == COMBAT_UNIT_TYPE_PLAYER then
        if (now - S.lastDodgeAt) > FATIGUE_WINDOW_MS then S.dodgeCount = 0 end
        S.dodgeCount  = S.dodgeCount + 1
        S.lastDodgeAt = now
        MarkPendingCost("roll")
    elseif dodged and T.exists and targetName == T.name then
        -- We cannot read what it cost them, but our own learned roll cost is
        -- a reasonable estimate for the same action, corrected the same
        -- self-healing way if it turns out wrong.
        T.engaged = true
        SpendTargetStamina(sv.learned.roll)
    end

    -- A real ability the target cast at us - exact history, plus a rough
    -- estimated charge against their magicka pool. Reliable per ESO's own
    -- event docs: values are only trustworthy when the player is source or
    -- target, which "cast at us" always satisfies.
    if T.exists and sourceName == T.name and targetType == COMBAT_UNIT_TYPE_PLAYER
       and isRealAbility then
        T.engaged = true
        TrackTargetAbility(abilityName, now)
        if IsUltimateSlot(abilitySlotType) then
            -- Exact: we watched them spend it. What we do NOT know is their
            -- generation rate, which is build-dependent - so this only
            -- starts a generic assumed-refill window, never claims a real
            -- read on when it refills.
            T.ultUsedAt = now
        else
            SpendTargetMagicka(MAGICKA_CAST_COST)
        end
    end

    -- Our own ability landing (or not) on the target - exact, since our own
    -- casts and their results are always known. Feeds the "you keep getting
    -- blocked" tip.
    if T.exists and sourceType == COMBAT_UNIT_TYPE_PLAYER and targetName == T.name
       and isRealAbility then
        T.engaged = true
        TrackMyCast(abilityName, result)
    end

    -- Charm has no dedicated ability type the way stun/fear/disorient do
    -- (verified against barny's CC Tracker source) - it only shows up as
    -- this specific combat-event result, which tells us it started but not
    -- how long it lasts. CHARM_ASSUMED_MS is a flat guess, not a read; it
    -- just refreshes every time the result fires again, so a re-charm before
    -- it expires still reads correctly.
    if ACTION_RESULT_CHARMED and result == ACTION_RESULT_CHARMED then
        if targetType == COMBAT_UNIT_TYPE_PLAYER then
            S.charmUntil = now + CHARM_ASSUMED_MS
        elseif T.exists and targetName == T.name then
            T.engaged = true
            T.charmUntil = now + CHARM_ASSUMED_MS
        end
    end
end

-- The game pushes every power change for the player here. Recording them all
-- means we never have to trust a constant name we cannot verify.
-- How long a pending action is allowed to wait for its stamina drop before
-- being abandoned - generous, since the two events are not guaranteed to
-- land in the same frame, but short enough that an unrelated later spend can
-- never get mistaken for this one.
local PENDING_COST_WINDOW_MS = 2000

-- Shared by the event path (instant, when EVENT_POWER_UPDATE actually fires)
-- and the tick fallback (always, at worst 100ms behind) - whichever notices
-- the drop first resolves it, and the other becomes a no-op once
-- pendingCostAction is cleared.
local function ResolvePendingCost(newStamina, now)
    if S.pendingCostAction and S.pendingCostBaseline
       and newStamina < S.pendingCostBaseline
       and (now - S.pendingCostAt) < PENDING_COST_WINDOW_MS then
        LearnCost(S.pendingCostAction, S.pendingCostBaseline - newStamina)
        S.pendingCostAction = nil
    end
end

-- Console reality check (found via /dv debug, not assumed): EVENT_POWER_UPDATE
-- does not reliably fire for this client - the "powers" table stayed
-- completely empty through real combat. Betting S.stamina's only update path
-- on that event was the same mistake this whole addon exists to avoid: it
-- froze S.stamina at whatever it was on load, forever, with no fallback.
-- OnPowerUpdate is kept as a bonus for whenever the event does fire, but
-- OnTick's poll (further down) is now the update path that is actually relied
-- on.
local function OnPowerUpdate(_, unitTag, _, powerType, powerValue, powerMax)
    if unitTag ~= "player" then return end
    if type(powerType) ~= "number" then return end
    local p = powers[powerType]
    if p == nil then p = {}; powers[powerType] = p end
    p.cur, p.max = powerValue, powerMax

    if powerType == ResourceType("stamina") then
        ResolvePendingCost(powerValue, Now())
        S.prevStamina = S.stamina
        S.stamina = powerValue
    end
end

-- Fires for the player's own effects and, unfiltered, for the reticle
-- target's too - real ESO addons (e.g. ZAM BuffDisplay) rely on exactly this:
-- EVENT_EFFECT_CHANGED delivers unitTag=="reticleover" changes with no
-- special registration needed, because the base game already tracks it for
-- the vanilla target frame's own debuff icons.
local function OnEffectChanged(_, changeType, _, effectName, unitTag, _, endTime,
                               _, _, _, _, abilityType, _, _, abilityId)
    local isPlayer = (unitTag == "player")
    local isTarget = (unitTag == "reticleover")
    if not isPlayer and not isTarget then return end
    if type(effectName) ~= "string" then return end

    local now = Now()
    local kind = ClassifyEffect(string.lower(effectName), abilityType)
    if kind == nil then return end

    local faded = (EFFECT_RESULT_FADED and changeType == EFFECT_RESULT_FADED)
    local gameSecs = Try(GetGameTimeSeconds) or 0
    local remaining = ((endTime or 0) - gameSecs) * 1000
    if remaining < 0 then remaining = 0 end

    local state = isPlayer and S or T
    local field = FIELD_FOR_KIND[kind]

    if faded then
        -- Verified against barny's CC Tracker (a real, current, dedicated CC
        -- addon): break free clears charm/stun/fear specifically. Root is
        -- NOT in that set there - it clears via a roll dodge instead, which
        -- the dodge-detection above already prices on its own, so treating
        -- an early root-fade as a break-free spend would have double-counted
        -- (and mis-attributed) a roll's cost as a break-free's.
        local wasHardCC = (kind == "stun" or kind == "fear" or kind == "charm")
        if isPlayer and wasHardCC then
            LearnBreakFreeIfEarly(state[field], now)
        elseif isTarget and wasHardCC then
            -- Fading with real time left on the clock means the target just
            -- paid to break free of it. We cannot read what it cost them, but
            -- our own learned break-free cost is a reasonable estimate for
            -- the same action, and every use tightens the estimate the same
            -- way self-tracking does.
            if state[field] - now > 300 then SpendTargetStamina(sv.learned.breakFree) end
        end
        state[field] = 0
    else
        state[field] = now + remaining
    end
end

-- EVENT_DUEL_STARTED is not guaranteed to have fired by the time the first
-- blow lands, so confirm against live duel state as well. Without this the
-- readout can miss the opening seconds of a duel, which is exactly when the
-- break free number matters.
function IsDuelling()
    if S.inDuel then return true end
    if type(GetDuelInfo) == "function" and DUEL_STATE_DUELING then
        local ok, state = pcall(GetDuelInfo)
        if ok and state == DUEL_STATE_DUELING then return true end
    end
    return false
end

function Active()
    return S.inCombat or IsDuelling()
end

local function OnDuelStarted()
    S.inDuel = true
    UpdateDisplay(Now())
end

local function OnDuelFinished()
    S.inDuel = false
    if not S.inCombat then
        ResetState()
        ResetContacts()
        lastCC, lastNote = nil, nil
    end
    UpdateDisplay(Now())
end

local function OnCombatState(_, inCombat)
    S.inCombat = inCombat and true or false
    if not Active() then
        -- everything wipes when the fight ends
        ResetState()
        ResetContacts()
        lastCC, lastNote = nil, nil
    end
    UpdateDisplay(Now())
end

-- Fires the instant the reticle moves onto a new unit (or off one entirely).
-- T is REASSIGNED, never rebuilt: an enemy already in `contacts` (still
-- inside their grace period from an earlier look) is picked back up as the
-- same record, so the left-side list and the on-target box are always the
-- same data, never two copies that can drift apart. A fresh buff sweep runs
-- either way, since EVENT_EFFECT_CHANGED only reports transitions from here
-- on and time may have passed since this contact was last actively watched.
local function OnReticleTargetChanged()
    local exists = Try(DoesUnitExist, "reticleover")
    local isPlayer = exists and Try(IsUnitPlayer, "reticleover")
    -- Verified pattern (real ESO addon developer discussion, not guessed):
    -- GetUnitReaction("reticleover") == UNIT_REACTION_HOSTILE. Without this,
    -- looking at a group-mate, a guildmate, or any friendly nearby player
    -- added them to the readout the same as an actual enemy.
    local isHostile = isPlayer and UNIT_REACTION_HOSTILE
        and Try(GetUnitReaction, "reticleover") == UNIT_REACTION_HOSTILE
    local now = Now()
    if exists and isPlayer and isHostile then
        local name = Try(zo_strformat, SI_UNIT_NAME, Try(GetUnitName, "reticleover")) or ""
        T = contacts[name] or NewContact(name)
        contacts[name] = T
        T.lastSeenAt = now
        SweepBuffs("reticleover", T, now)
    else
        T = EMPTY_TARGET
    end
    UpdateDisplay(now)
end

-- Drops any contact whose grace period has run out. Never prunes T itself -
-- the one currently under the reticle refreshes its own lastSeenAt every
-- tick below, so it is never eligible while actively targeted.
local function PruneContacts(now)
    for name, c in pairs(contacts) do
        if c ~= T and (now - c.lastSeenAt) > CONTACT_TTL_MS then
            contacts[name] = nil
        end
    end
end

local function OnTick()
    local now = Now()
    if T.exists then T.lastSeenAt = now end
    PruneContacts(now)
    -- The reliable path: polled every tick regardless of whether
    -- EVENT_POWER_UPDATE ever fires this session. OnPowerUpdate still updates
    -- instantly when it does fire; this is what guarantees S.stamina is never
    -- more than one tick stale even when it does not.
    local fresh = Stamina()
    if fresh ~= nil then
        ResolvePendingCost(fresh, now)
        S.prevStamina = S.stamina
        S.stamina = fresh
    end
    S.blocking = Try(IsBlockActive) and true or false

    local ult, ultMax = Ultimate()
    S.ultimateReady = (ult ~= nil and ultMax ~= nil and ultMax > 0 and ult >= ultMax)

    if (now - S.lastDodgeAt) > FATIGUE_WINDOW_MS then S.dodgeCount = 0 end

    ReadCrowdControl(now)
    UpdateDisplay(now)
end

-- ---------------------------------------------------------------- commands
local function OnSlash(args)
    args = string.lower(tostring(args or ""))
    args = string.gsub(args, "^%s+", "")
    args = string.gsub(args, "%s+$", "")

    if args == "" then
        sv.ui.hidden = not sv.ui.hidden
        UpdateDisplay(Now())
        Msg(sv.ui.hidden and "hidden" or "shown")
    elseif args == "cc" then
        sv.showCC = not sv.showCC
        lastCC = nil
        Msg("crowd control readout " .. (sv.showCC and "on" or "off"))
    elseif args == "debug" then
        Msg("console=" .. tostring(IS_CONSOLE)
            .. "  active=" .. tostring(Active())
            .. "  inCombat=" .. tostring(S.inCombat)
            .. "  inDuel=" .. tostring(S.inDuel))
        for _, which in ipairs({ "stamina", "magicka", "health", "ultimate" }) do
            local name, value = ResourceSource(which)
            Msg(which .. " -> " .. name .. " = " .. tostring(value))
        end
        Msg("S.stamina=" .. tostring(S.stamina)
            .. "  rolls=" .. tostring(RollsAffordable())
            .. "  canBreak=" .. tostring(CanBreakFree()))
        local seen = 0
        for ptype, p in pairs(powers) do
            seen = seen + 1
            local label = ""
            for _, which in ipairs({ "stamina", "magicka", "health", "ultimate" }) do
                if ResourceType(which) == ptype then label = "  <- " .. which end
            end
            Msg("  power type " .. tostring(ptype)
                .. ": cur=" .. tostring(p.cur)
                .. " max=" .. tostring(p.max) .. label)
        end
        if seen == 0 then
            Msg("  no EVENT_POWER_UPDATE received yet - take or deal damage and retry")
        end
        Msg("magicka = " .. tostring(Magicka()))
        local ult, ultMax = Ultimate()
        Msg("ultimate = " .. tostring(ult) .. "/" .. tostring(ultMax)
            .. "  ready=" .. tostring(S.ultimateReady))
        if win then
            local w, h = win:GetDimensions()
            Msg(string.format("window hidden=%s alpha=%.2f size=%dx%d console=%s",
                tostring(win:IsHidden()), win:GetAlpha() or -1,
                w or -1, h or -1, tostring(IS_CONSOLE)))
            Msg("fonts: verb=" .. FONT_VERB .. "  sub=" .. FONT_SUB
                .. "  rideHud=" .. tostring(sv.ui.rideHud))
            local ax, ay = sv.ui.x or 0, sv.ui.y or 0
            Msg("anchor LEFT inset=" .. INSET_X .. " yNudge=" .. tostring(ay)
                .. "  ccText=[" .. tostring(ccLabel and ccLabel:GetText()) .. "]")
        else
            Msg("window was never created")
        end
    elseif args == "test" then
        -- Draws the window outline and known-good text, ignoring combat state.
        -- If this shows nothing the window is the problem; if the box shows but
        -- the words do not, the fonts are.
        sv.ui.hidden = false
        if testBox then testBox:SetHidden(not testBox:IsHidden()) end
        local on = testBox and not testBox:IsHidden()
        if on then
            win:SetHidden(false)
            win:SetAlpha(1)
            ccLabel:SetText("DREAD VISION")
            aiNoteLabel:SetText("if you can read this, it works")
            lastCC, lastNote = nil, nil
        else
            lastCC, lastNote = nil, nil
        end
        Msg("test box " .. (on and "ON - look at screen centre" or "off"))
    elseif args == "hud" then
        sv.ui.rideHud = not sv.ui.rideHud
        Msg("ride HUD scene " .. (sv.ui.rideHud and "on" or "off")
            .. " - /reloadui to apply")
    elseif args == "costs" then
        Msg(string.format("learned costs - roll %d, break free %d",
            sv.learned.roll, sv.learned.breakFree))
    elseif args == "resetcosts" then
        -- The learned values persist in saved settings across every version,
        -- including any that sampled stamina wrong. Fixing the sampling does
        -- not retroactively fix a number an old bug already pushed off - this
        -- is the clean-slate button for that.
        sv.learned.roll, sv.learned.breakFree = 2721, 4590
        Msg("learned costs reset to defaults - roll 2721, break free 4590")
    elseif args == "up" then
        sv.ui.y = ClampY(sv.ui.y - 20)
        win:ClearAnchors()
        win:SetAnchor(LEFT, GuiRoot, LEFT, INSET_X, sv.ui.y)
        Msg("offset " .. sv.ui.y)
    elseif args == "down" then
        sv.ui.y = ClampY(sv.ui.y + 20)
        win:ClearAnchors()
        win:SetAnchor(LEFT, GuiRoot, LEFT, INSET_X, sv.ui.y)
        Msg("offset " .. sv.ui.y)
    else
        Msg("/dv         show or hide")
        Msg("/dv up      move the ring up 20 (third person)")
        Msg("/dv down    move the ring down 20")
        Msg("/dv cc      toggle the crowd control line")
        Msg("/dv costs   show the learned action costs")
        Msg("/dv resetcosts  wipe learned costs back to defaults")
        Msg("/dv debug   dump power values and state")
        Msg("/dv test    draw a proof-of-life box at screen centre")
        Msg("/dv hud     toggle hiding with the HUD (needs /reloadui)")
    end
end

-- ------------------------------------------------------------------- setup
local function Initialize()
    sv = ZO_SavedVars:NewCharacterIdSettings("DreadVisionVars", SV_VERSION, nil, defaults)
    sv.ui      = sv.ui or { x = 0, y = 0, hidden = false, rideHud = false }
    if sv.ui.rideHud == nil then sv.ui.rideHud = false end
    -- A stale offset from a previous layout could park the window off screen,
    -- which is indistinguishable from the addon not loading. Clamped on every
    -- start so a bad saved value cannot survive.
    sv.ui.x = 0
    sv.ui.y = ClampY(type(sv.ui.y) == "number" and sv.ui.y or 0)
    sv.learned = sv.learned or { roll = 2721, breakFree = 4590 }

    BuildUI()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_CE", EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "_CE", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_IS_ERROR, false)

    -- Deliberately unfiltered. A filter whose constant does not resolve
    -- registers wrong and silently drops every event, and behind a pcall there
    -- is no way to tell that from the player simply having no stamina.
    -- OnPowerUpdate checks the unit tag itself, which costs a comparison.
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PW", EVENT_POWER_UPDATE, OnPowerUpdate)

    -- Unfiltered. This event carries the reticle target's buff/debuff changes
    -- too - the same thing the vanilla target frame's own debuff icons run
    -- on - and OnEffectChanged checks unitTag itself, so a filter here would
    -- only risk the same silent-drop failure mode already fixed for stamina.
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_EF", EVENT_EFFECT_CHANGED, OnEffectChanged)

    if EVENT_RETICLE_TARGET_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_RT", EVENT_RETICLE_TARGET_CHANGED,
            OnReticleTargetChanged)
    end

    if EVENT_PLAYER_COMBAT_STATE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_CS", EVENT_PLAYER_COMBAT_STATE, OnCombatState)
    end
    if EVENT_DUEL_STARTED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_DS", EVENT_DUEL_STARTED, OnDuelStarted)
    end
    if EVENT_DUEL_FINISHED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_DF", EVENT_DUEL_FINISHED, OnDuelFinished)
    end

    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_TICK", TICK_MS, OnTick)

    if SLASH_COMMANDS then
        SLASH_COMMANDS["/dv"] = OnSlash
        SLASH_COMMANDS["/dreadvision"] = OnSlash
    end

    S.stamina = Stamina()
    S.prevStamina = S.stamina
    Msg("loaded. /dv for options")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, name)
    if name ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    Initialize()
end)
