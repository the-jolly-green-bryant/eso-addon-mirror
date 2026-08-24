-----------------------------------------------------------
-- Crux
-- Arcanist Crux economy tracking for Battle Scrolls
--
-- Counts generator casts made at full Crux (wasted generation)
-- and spender casts made under 3 Crux (undervalued spend), per
-- ability and in aggregate. Uses the pre-cast stack count from
-- state's Crux window tracking (the same burst-window logic
-- weaving uses for Exhausting Fatecarver), because Crux
-- gain/consume effect events can fire before or after the
-- action-slot event within the same frame.
--
-- Also counts Crux consumed OUTSIDE tracked casts: stack drops with no
-- spender cast nearby - natural 30s expiry and death land in this bucket.
--
-- Conditional GENERATION (stack gains outside generator casts) is
-- attributed per source by correlating the gain with observable proc
-- events: gate passes, Spattering Disjunction procs, and Tome-Bearer
-- pulse hits emit EVENT_COMBAT_EVENTs; Class Mastery generation comes
-- with trackable secondary-effect buffs; Scribing's Class Flourish
-- signature casts are paired the same way (all verified in game
-- 2026-08-23). Cruxweaver Armor emits no client event at all, so it is
-- reconstructed: armor buff active + damage taken just before + 5s proc
-- cooldown elapsed. Banner Bearer's in-combat Class Flourish crux pulses
-- are verified to emit nothing observable; they are reclaimed by
-- elimination (gain unexplained for 1s + banner sighted but silent for
-- 5s+). Whatever remains lands in unattributedGains.
--
-- No class gate: Crux is reachable on any class via subclassing, so
-- activity state is created lazily on the first Crux-related event.
-----------------------------------------------------------

if not SemisPlaygroundCheckAccess() then
    return
end

BattleScrolls = BattleScrolls or {}

local MAX_CRUX = 3

-- Same-batch event races - a Crux effect event landing just BEFORE its
-- SLOT event, or a proc combat event pairing with its stack gain - are
-- matched within this window. Client-side ordering jitter only, so short.
local SPENDER_CONSUME_WINDOW_MS = 400

-- SLOT events fire client-side on the button press, but the resulting
-- Crux effect event only comes back with the server response - a full
-- round-trip that dwarfs the race window whenever the server is under
-- load (PvP fights spike well past a second; observed in a battleground
-- as "unknown source" gains and inflated passive loss). A pressed cast
-- therefore stays claimable for this long, as a ONE-SHOT flag consumed
-- by the first effect it explains, so the wide window can't let one cast
-- explain two.
local CAST_EFFECT_WINDOW_MS = 1500

-- Conditional Crux generation sources: proc combat events mapped to a
-- canonical display ability id (used for GetAbilityName/GetAbilityIcon and
-- to merge sub-ids of one source). Verified in game 2026-08-23 on
-- Fleet-Footed Gate and Spattering Disjunction; Tome-Bearer pulse hits are
-- the long-established proc-tracking damage ids from constants.lua.

-- Gate passes: ACTION_RESULT_EFFECT_GAINED, player source AND player
-- target (casting emits enemy/entity-targeted events only, so the
-- self-target filter separates a pass from a cast). Each morph has two
-- sub-ids, one per pass direction. All verified in game 2026-08-23.
---@type table<number, number>
local CRUX_GATE_PASS_SOURCES = {
    [183544] = 183542, [183547] = 183542, -- Apocryphal Gate
    [186212] = 186211, [186214] = 186211, -- Fleet-Footed Gate
    [186221] = 186220, [186223] = 186220, -- Passage Between Worlds
}

-- Enemy-targeted EFFECT_GAINED procs.
---@type table<number, number>
local CRUX_PROC_EFFECT_SOURCES = {
    [227565] = 227381, -- Spattering Disjunction
}

-- Damage hits that generate a Crux (Tome-Bearer line pulse-empowered
-- strikes; same ids SingleTargetDamageProcAbilityIds tracks).
---@type table<number, number>
local CRUX_PROC_DAMAGE_SOURCES = {
    [185843] = 185842, -- Inspired Scholarship
    [186453] = 186452, -- Tome-Bearer's Inspiration
    [183048] = 183047, -- Recuperative Treatise
}

-- Scribing: the Class Flourish signature script makes any scribed cast
-- generate a Crux (ids lifted from a real scribed build in a web share).
-- Such casts are full generators, discipline included - a scribed skill
-- may well be the build's spammable. Banner Bearer is the exception: its
-- Class Flourish pulses every 5s instead (a Crux at 0 stacks, else +3
-- ultimate). Verified 2026-08-23: the in-combat crux pulse emits NO
-- event, the ult pulse energizes as id 252143, and out of combat the
-- timer ticks as ABILITY_ON_COOLDOWN id 227116 (both named "Arcanist's
-- Banner").
local CLASS_FLOURISH_SCRIPT_ID = 31
local BANNER_BEARER_CRAFTED_ID = 12

-- Banner fallback: the silent crux pulse is reclaimed from unattributed
-- by elimination - a gain still unexplained a full second later is
-- reattributed to the banner IF a banner tick has ever been sighted
-- (either id above) but NOT near the gain: the pulse cycle is 5s, so a
-- VISIBLE tick close to the gain means that pulse slot was not a silent
-- crux one. "Near" is 4s before to 1s after the gain - 5s total ending
-- at the nominal settle moment, asymmetric to absorb event jitter.
-- Displayed under the out-of-combat tick id.
local BANNER_TICK_OOC_ID = 227116  -- also the fallback's display id
local BANNER_TICK_ULT_ID = 252143
local BANNER_FALLBACK_AFTER_MS = 1000
local BANNER_TICK_BEFORE_MS = 4000
local BANNER_TICK_AFTER_MS = 1000

-- Cruxweaver Armor: taking damage while the buff is up generates a Crux
-- on a 5s internal cooldown, and the proc emits NO client event (verified
-- with an unfiltered logger). Reconstructed as a SYNTHETIC proc instead:
-- each damage hit past the cooldown parks a proc entry that rides the
-- same attribution queue as real proc events (claimed last, being a
-- guess). The player buff is id 185908 alone (verified in game
-- 2026-08-23); the other Fatewoven morphs don't generate Crux.
local ARMOR_PROC_ICD_MS = 5000
-- Attribute slightly early rather than miss a real proc to timing jitter
local ARMOR_PROC_ICD_GRACE_MS = 300
local CRUX_ARMOR_BUFF_ID = 185908 -- Cruxweaver Armor

-- Class Mastery: subclassed Crux generation emits no proc event of its
-- own, but each mastery's secondary-effect buff on the player is
-- observable (verified in game 2026-08-23). Gaining one of these grants
-- the mapped number of Crux at once.
---@type table<number, number> Buff ability id -> Crux granted on gain
local CRUX_MASTERY_BUFF_GAIN_SOURCES = {
    [263369] = 3, -- Abyssal Emergence
    [268372] = 3, -- Fate Realigned
}

-- Ink-Scribe's Verve (Class Mastery): CONSUMING the buff grants 1 Crux
-- together with Major Force; natural expiry grants nothing. The only
-- observable difference is the simultaneous Major Force grant, so a Verve
-- FADED (specifically, not UPDATED) is paired with a Major Force gain
-- within a short window, in either delivery order. UPDATED is accepted on
-- the Major Force side - the consumption may merely refresh a Major Force
-- an ally already provided.
local VERVE_BUFF_ID = 263419 -- Ink-Scribe's Verve (also the display id)
local MAJOR_FORCE_BUFF_ID = 61747
local VERVE_PAIR_WINDOW_MS = 100

-- Slot 3..8 = skills + ultimate
local SKILL_SLOT_MIN = 3
local SKILL_SLOT_MAX = 8

-- Ability ids of slotted base abilities and morphs that GENERATE 1 Crux
-- directly on cast. Conditional generators are deliberately excluded -
-- recasting them at full Crux is upkeep, not waste: Tome-Bearer's
-- Inspiration line (timed pulse), Cruxweaver Armor (on taking damage),
-- Apocryphal Gate line (on teleport).
-- Many abilities exist under two ids sharing name/icon (slotted id varies),
-- so both members of each known alias pair are listed.
---@type table<number, boolean>
local CRUX_GENERATORS = {
    -- Herald of the Tome
    [185794] = true, [188658] = true, -- Runeblades
    [185803] = true, [188787] = true, -- Writhing Runeblades
    [182977] = true, [188780] = true, -- Escalating Runeblades
    [183006] = true,                  -- Cephaliarch's Flail (Abyssal Impact morph)
    -- Soldier of Apocrypha
    [183165] = true, -- Runic Jolt
    [183430] = true, -- Runic Sunder
    [186531] = true, -- Runic Embrace
    -- Curative Runeforms
    [183261] = true, [198282] = true, -- Runemend
    [186189] = true, [198288] = true, -- Evolving Runemend
    [186191] = true, [198292] = true, -- Audacious Runemend
    [186207] = true, [198564] = true, -- Chakram of Destiny (Chakram Shields morph)
    -- Vengeance Apocryphal Gate teleports immediately on cast and generates
    -- Crux then - a plain slotted generator, unlike the live morphs' passes
    [238545] = true,
}

-- Ability ids of slotted base abilities and morphs that CONSUME all Crux for
-- a bonus effect. Alias pairs and seasonal Vengeance variants included.
---@type table<number, boolean>
local CRUX_SPENDERS = {
    -- Herald of the Tome
    [185805] = true, [193331] = true, -- Fatecarver
    [183122] = true, [193397] = true, -- Exhausting Fatecarver
    [186366] = true, [193398] = true, -- Pragmatic Fatecarver
    [185823] = true,                  -- Tentacular Dread (Abyssal Impact morph)
    -- Soldier of Apocrypha
    [185894] = true, -- Runespite Ward
    [185901] = true, -- Spiteward of the Lucid Mind
    [183241] = true, -- Impervious Runeward
    [186477] = true, -- Unbreakable Fate (Fatewoven Armor morph)
    -- Curative Runeforms
    [183537] = true, [198309] = true, -- Remedy Cascade
    [186193] = true, [198330] = true, -- Cascading Fortune
    [186200] = true, [198537] = true, -- Curative Surge
    [186209] = true, [198567] = true, -- Tidal Chakram (Chakram Shields morph)
    -- Vengeance variants
    [238174] = true, -- Vengeance Fatecarver
    [238249] = true, -- Vengeance Runespite Ward
    [238482] = true, -- Vengeance Remedy Cascade
}

---Per-ability Crux activity
---@class CruxAbilityActivity
---@field casts number Casts of this ability
---@field bad number Wasted-generation casts (generators) or under-3 spends (spenders)

---Live Crux tracking state (attached to BattleScrollsState; nil when not an Arcanist)
---@class CruxActivityState
---@field generatorCasts number
---@field generatorAtFull number Generator casts made at 3 Crux
---@field spenderCasts number
---@field spenderUnder number[] Spender casts by pre-cast Crux count: [1]=at 0, [2]=at 1, [3]=at 2
---@field byAbility table<number, CruxAbilityActivity>
---@field passiveEvents number Stack drops with no spender cast nearby (expiry/death)
---@field passiveStacks number Total Crux consumed in those drops
---@field pendingSpenderCastMs number Game time of a spender SLOT press whose consumption drop hasn't arrived yet (0 = none; consumed by the drop it explains)
---@field pendingDrops { ms: number, stacks: number }[] Recent unattributed drops awaiting a possible late spender SLOT event
---@field conditionalGains table<number, number> Canonical source ability id -> Crux generated by its procs
---@field unattributedGains number Stack gains explained by neither a proc nor a generator cast (Cruxweaver Armor lands here for now)
---@field pendingGeneratorCastMs number Game time of a generator SLOT press whose stack gain hasn't arrived yet (0 = none; consumed by the gain it explains)
---@field pendingProcs { ms: number, id: number, stacks: number, synthetic: boolean|nil }[] Recent proc events awaiting their stack gain (stacks = Crux left to claim; synthetic = armor-proc guess from a damage hit, claimed last)
---@field pendingGains { ms: number, stacks: number }[] Recent unexplained gains awaiting a possible late proc event

---@class BattleScrollsCrux : StateObserver
local crux = {}
BattleScrolls.crux = crux

-- Live armor-buff state (module-local: the buff and the proc cooldown
-- outlive any single combat)
local armorBuffActive = false
local lastArmorAttribMs = 0
-- Verve/Major Force pairing timestamps (a match consumes the matched one,
-- so a later unrelated event can't re-pair with it)
local lastVerveFadedMs = 0
local lastMajorForceMs = 0
-- Last sighted Arcanist's Banner tick, either id (module-local: the
-- out-of-combat ticks that prove the banner is slotted precede combat)
local bannerLastSeenMs = 0

crux.CRUX_GENERATORS = CRUX_GENERATORS
crux.CRUX_SPENDERS = CRUX_SPENDERS

---Creates a fresh CruxActivityState
---@return CruxActivityState
function crux.newState()
    return {
        generatorCasts = 0,
        generatorAtFull = 0,
        spenderCasts = 0,
        spenderUnder = { 0, 0, 0 },
        byAbility = {},
        passiveEvents = 0,
        passiveStacks = 0,
        pendingSpenderCastMs = 0,
        pendingDrops = {},
        conditionalGains = {},
        unattributedGains = 0,
        pendingGeneratorCastMs = 0,
        pendingProcs = {},
        pendingGains = {},
    }
end

---Returns the combat's CruxActivityState, creating it on first use
---@param state BattleScrollsState
---@return CruxActivityState
local function getOrCreateActivity(state)
    local c = state.cruxActivity
    if not c then
        c = crux.newState()
        state.cruxActivity = c
    end
    return c
end

---Folds pending drops older than the spender window into the passive
---counters (a spender cast can no longer claim them)
---@param c CruxActivityState
---@param nowMs number
local function settlePendingDrops(c, nowMs)
    local pending = c.pendingDrops
    local i = 1
    while i <= #pending do
        if (nowMs - pending[i].ms) > SPENDER_CONSUME_WINDOW_MS then
            c.passiveEvents = c.passiveEvents + 1
            c.passiveStacks = c.passiveStacks + pending[i].stacks
            table.remove(pending, i)
        else
            i = i + 1
        end
    end
end

---Discards pending proc events older than the pairing window (their stack
---gain never arrived - e.g. a proc at full Crux)
---@param c CruxActivityState
---@param nowMs number
local function settlePendingProcs(c, nowMs)
    local pending = c.pendingProcs
    local i = 1
    while i <= #pending do
        if (nowMs - pending[i].ms) > SPENDER_CONSUME_WINDOW_MS then
            table.remove(pending, i)
        else
            i = i + 1
        end
    end
end

---Folds pending gains that outlived the fallback window: reattributed to
---the Arcanist's Banner when its silent-pulse conditions hold (sighted
---before, but no visible tick in the last 5s - see the banner comment),
---otherwise into unattributedGains
---@param c CruxActivityState
---@param nowMs number
local function settlePendingGains(c, nowMs)
    local pending = c.pendingGains
    local i = 1
    while i <= #pending do
        local entry = pending[i]
        if (nowMs - entry.ms) > BANNER_FALLBACK_AFTER_MS then
            -- Banner recency is judged against the GAIN's moment: a
            -- visible banner tick from 4s before to 1s after it puts the
            -- gain off the silent pulse's 5s grid
            local sinceSighting = entry.ms - bannerLastSeenMs
            local silentPulse = bannerLastSeenMs > 0
                and (sinceSighting >= BANNER_TICK_BEFORE_MS
                    or -sinceSighting >= BANNER_TICK_AFTER_MS)
            if silentPulse then
                c.conditionalGains[BANNER_TICK_OOC_ID] =
                    (c.conditionalGains[BANNER_TICK_OOC_ID] or 0) + entry.stacks
            else
                c.unattributedGains = c.unattributedGains + entry.stacks
            end
            table.remove(pending, i)
        else
            i = i + 1
        end
    end
end

---Handles a conditional-generation proc worth `stacks` Crux: claims recent
---unexplained stack gains, or parks the remainder for the gain still to
---arrive. Synthetic procs (armor guesses) only park - an armor gain never
---precedes its damage hit.
---@param canonicalId number
---@param stacks number
---@param synthetic boolean|nil
local function onConditionalProc(canonicalId, stacks, synthetic)
    local state = BattleScrolls.state
    if not state or not state.initialized then
        return
    end
    local c = getOrCreateActivity(state)
    local now = GetGameTimeMilliseconds()
    settlePendingGains(c, now)
    local pending = c.pendingGains
    local remaining = stacks
    local i = 1
    while not synthetic and remaining > 0 and i <= #pending do
        -- A stack gain arrived first - claim it. Only gains within the
        -- pairing window are claimable; older ones outlived every real
        -- proc and are just waiting out the banner fallback.
        local gainEntry = pending[i]
        if (now - gainEntry.ms) <= SPENDER_CONSUME_WINDOW_MS then
            local take = zo_min(remaining, gainEntry.stacks)
            c.conditionalGains[canonicalId] = (c.conditionalGains[canonicalId] or 0) + take
            gainEntry.stacks = gainEntry.stacks - take
            remaining = remaining - take
            if gainEntry.stacks <= 0 then
                table.remove(pending, i)
            else
                i = i + 1
            end
        else
            i = i + 1
        end
    end
    if remaining > 0 then
        c.pendingProcs[#c.pendingProcs + 1] =
            { ms = now, id = canonicalId, stacks = remaining, synthetic = synthetic or nil }
    end
end

---Called from state on every damage hit the player takes. While a Fatewoven
---line armor buff is up and its proc cooldown has elapsed, the hit MAY have
---generated a Crux (the real proc emits no event) - park a synthetic proc
---that an otherwise-unexplained stack gain can claim.
function crux.onPlayerDamaged()
    if not armorBuffActive then
        return
    end
    local now = GetGameTimeMilliseconds()
    if (now - lastArmorAttribMs) < (ARMOR_PROC_ICD_MS - ARMOR_PROC_ICD_GRACE_MS) then
        return
    end
    onConditionalProc(CRUX_ARMOR_BUFF_ID, 1, true)
end

---Called from state's Crux effect handler on every stack change.
---Drops not explained by a spender press (in either event order) are
---counted as passive consumption (expiry, death). Gains are attributed in
---order: recent proc events (conditional generation), then a generator
---press still awaiting its server response (one-shot, one stack), and any
---remainder is parked for a late proc before settling into
---unattributedGains (via the banner fallback).
---@param state BattleScrollsState
---@param oldStacks number
---@param newStacks number
function crux.onCruxStacksChanged(state, oldStacks, newStacks)
    if not state.initialized then
        return
    end
    local c = getOrCreateActivity(state)
    local now = GetGameTimeMilliseconds()

    local gain = newStacks - oldStacks
    if gain > 0 then
        settlePendingProcs(c, now)
        -- Also settle expired gains here so they don't sit parked until
        -- the next proc event (keeps banner-fallback timing near-live)
        settlePendingGains(c, now)
        local procs = c.pendingProcs
        -- Phase 1: real proc events (exact attribution)
        local i = 1
        while gain > 0 and i <= #procs do
            local proc = procs[i]
            if not proc.synthetic then
                local take = zo_min(gain, proc.stacks)
                c.conditionalGains[proc.id] = (c.conditionalGains[proc.id] or 0) + take
                gain = gain - take
                proc.stacks = proc.stacks - take
                if proc.stacks <= 0 then
                    table.remove(procs, i)
                else
                    i = i + 1
                end
            else
                i = i + 1
            end
        end
        -- Phase 2: a generator SLOT press awaiting its server response
        -- explains one stack (one-shot: consumed so it can't explain two)
        if gain > 0 and c.pendingGeneratorCastMs > 0
                and (now - c.pendingGeneratorCastMs) <= CAST_EFFECT_WINDOW_MS then
            c.pendingGeneratorCastMs = 0
            gain = gain - 1
        end
        -- Phase 3: synthetic armor procs (guesses, so claimed last; re-check
        -- the cooldown - an earlier claim may have just consumed it)
        i = 1
        while gain > 0 and i <= #procs do
            if procs[i].synthetic
                    and (now - lastArmorAttribMs) >= (ARMOR_PROC_ICD_MS - ARMOR_PROC_ICD_GRACE_MS) then
                local proc = table.remove(procs, i)
                c.conditionalGains[proc.id] = (c.conditionalGains[proc.id] or 0) + 1
                lastArmorAttribMs = now
                gain = gain - 1
            else
                i = i + 1
            end
        end
        if gain > 0 then
            -- The proc combat event may still arrive after the stack gain
            c.pendingGains[#c.pendingGains + 1] = { ms = now, stacks = gain }
        end
        return
    end

    local drop = -gain
    if drop <= 0 then
        return
    end
    settlePendingDrops(c, now)
    if c.pendingSpenderCastMs > 0 and (now - c.pendingSpenderCastMs) <= CAST_EFFECT_WINDOW_MS then
        c.pendingSpenderCastMs = 0
        return -- the drop this spender press was waiting for
    end
    -- The spender SLOT event may still arrive after this drop - park it
    c.pendingDrops[#c.pendingDrops + 1] = { ms = now, stacks = drop }
end

---@param c CruxActivityState
---@param abilityId number
---@return CruxAbilityActivity
local function getOrCreateEntry(c, abilityId)
    local entry = c.byAbility[abilityId]
    if not entry then
        entry = { casts = 0, bad = 0 }
        c.byAbility[abilityId] = entry
    end
    return entry
end

---Handles skill/ultimate slot presses for Crux accounting
---@param actionSlotIndex number
local function onActionSlotUsed(actionSlotIndex)
    if actionSlotIndex < SKILL_SLOT_MIN or actionSlotIndex > SKILL_SLOT_MAX then
        return
    end
    local state = BattleScrolls.state
    if not state or not state.initialized then
        return
    end
    local abilityId
    local craftedId
    if GetSlotType(actionSlotIndex) == ACTION_TYPE_CRAFTED_ABILITY then
        craftedId = GetSlotBoundId(actionSlotIndex)
        abilityId = GetAbilityIdForCraftedAbilityId(craftedId)
    else
        abilityId = GetSlotBoundId(actionSlotIndex)
    end
    if not abilityId or abilityId <= 0 then
        return
    end

    local isGenerator = CRUX_GENERATORS[abilityId]
    local isSpender = CRUX_SPENDERS[abilityId]
    if not isGenerator and not isSpender and craftedId and craftedId ~= BANNER_BEARER_CRAFTED_ID then
        local _, signatureScriptId = GetCraftedAbilityActiveScriptIds(craftedId)
        isGenerator = signatureScriptId == CLASS_FLOURISH_SCRIPT_ID
    end
    if not isGenerator and not isSpender then
        return
    end
    local c = getOrCreateActivity(state)

    -- Pre-cast stacks: Crux effect events race with the SLOT event, so use
    -- the burst-window max the same way weaving does for Fatecarver duration.
    local now = GetGameTimeMilliseconds()
    local stacks = state.cruxStacks
    if (now - state.cruxWindowStartMs) < 100 then
        stacks = zo_max(state.cruxRecentMax, stacks)
    end

    local entry = getOrCreateEntry(c, abilityId)
    entry.casts = entry.casts + 1

    if isGenerator then
        c.generatorCasts = c.generatorCasts + 1
        -- The cast's gain may have landed just before this SLOT event -
        -- claim one parked stack; otherwise arm the one-shot flag for the
        -- gain still in flight from the server
        local claimed = false
        local pending = c.pendingGains
        for i = #pending, 1, -1 do
            if (now - pending[i].ms) <= SPENDER_CONSUME_WINDOW_MS then
                pending[i].stacks = pending[i].stacks - 1
                if pending[i].stacks <= 0 then
                    table.remove(pending, i)
                end
                claimed = true
                break
            end
        end
        if not claimed then
            c.pendingGeneratorCastMs = now
        end
        if stacks >= MAX_CRUX then
            c.generatorAtFull = c.generatorAtFull + 1
            entry.bad = entry.bad + 1
        end
    else
        c.spenderCasts = c.spenderCasts + 1
        -- The consumption drop may have landed just before this SLOT
        -- event - claim it; otherwise arm the one-shot flag for the drop
        -- still in flight from the server
        local claimed = false
        local pending = c.pendingDrops
        for i = #pending, 1, -1 do
            if (now - pending[i].ms) <= SPENDER_CONSUME_WINDOW_MS then
                table.remove(pending, i)
                claimed = true
                break
            end
        end
        if not claimed then
            c.pendingSpenderCastMs = now
        end
        if stacks < MAX_CRUX then
            c.spenderUnder[stacks + 1] = c.spenderUnder[stacks + 1] + 1
            entry.bad = entry.bad + 1
        end
    end
end

---Encounter-ready Crux data (stored per encounter)
---@class CruxData
---@field generatorCasts number
---@field generatorAtFull number
---@field spenderCasts number
---@field spenderUnder number[] [1]=at 0 Crux, [2]=at 1, [3]=at 2
---@field byAbility table<number, CruxAbilityActivity>
---@field passiveEvents number Stack drops outside spender casts (expiry/death)
---@field passiveStacks number Total Crux consumed in those drops
---@field conditionalGains table<number, number> Canonical source ability id -> Crux generated by its procs
---@field unattributedGains number Stack gains with no tracked explanation

---Finalizes crux state into encounter-ready data
---@param c CruxActivityState|nil
---@param endTimeMs number|nil Absolute game time of combat end (settles pending events)
---@return CruxData|nil data Nil when no Crux activity was seen
function crux.finalize(c, endTimeMs)
    if not c then
        return nil
    end
    -- Anything still parked past the longest window is settled by now
    -- (BANNER_FALLBACK_AFTER_MS is the widest hold, covering the spender
    -- window too)
    local settleMs = (endTimeMs or GetGameTimeMilliseconds()) + BANNER_FALLBACK_AFTER_MS + 1
    settlePendingDrops(c, settleMs)
    settlePendingGains(c, settleMs)
    local hasConditional = next(c.conditionalGains) ~= nil or c.unattributedGains > 0
    if c.generatorCasts == 0 and c.spenderCasts == 0 and c.passiveEvents == 0 and not hasConditional then
        return nil
    end
    return {
        generatorCasts = c.generatorCasts,
        generatorAtFull = c.generatorAtFull,
        spenderCasts = c.spenderCasts,
        spenderUnder = c.spenderUnder,
        byAbility = c.byAbility,
        passiveEvents = c.passiveEvents,
        passiveStacks = c.passiveStacks,
        conditionalGains = c.conditionalGains,
        unattributedGains = c.unattributedGains,
    }
end

---Registers one per-ability-id filtered combat event handler for a
---conditional-generation proc source
---@param eventAbilityId number
---@param canonicalId number
---@param isDamageProc boolean True for damage hits, false for EFFECT_GAINED markers
---@param filterTargetPlayer boolean Also filter target = player (gate passes)
local function registerConditionalSource(eventAbilityId, canonicalId, isDamageProc, filterTargetPlayer)
    local namespace = "BattleScrolls_Crux_Cond" .. eventAbilityId
    local damageResults = BattleScrolls.constants.damageResultsSet
    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, function(_, result)
        local matches
        if isDamageProc then
            matches = damageResults[result]
        else
            matches = result == ACTION_RESULT_EFFECT_GAINED
        end
        if matches then
            onConditionalProc(canonicalId, 1)
        end
    end)
    EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_ABILITY_ID, eventAbilityId,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    if filterTargetPlayer then
        EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT,
                REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end
end

---Registers a player-buff EFFECT_CHANGED watcher for a Class Mastery
---secondary effect whose fresh appearance grants Crux
---@param buffAbilityId number
---@param grantedStacks number
local function registerBuffGainSource(buffAbilityId, grantedStacks)
    local namespace = "BattleScrolls_Crux_Buff" .. buffAbilityId
    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_EFFECT_CHANGED, function(_, changeType)
        if changeType == EFFECT_RESULT_GAINED then
            onConditionalProc(buffAbilityId, grantedStacks)
        end
    end)
    EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_ABILITY_ID, buffAbilityId,
            REGISTER_FILTER_UNIT_TAG, "player")
end

---Ink-Scribe's Verve FADED: grants a Crux only if Major Force landed in
---the same instant (otherwise the buff just expired)
local function onVerveFaded()
    local now = GetGameTimeMilliseconds()
    if lastMajorForceMs > 0 and (now - lastMajorForceMs) <= VERVE_PAIR_WINDOW_MS then
        lastMajorForceMs = 0
        onConditionalProc(VERVE_BUFF_ID, 1)
    else
        lastVerveFadedMs = now
    end
end

---Major Force gained/refreshed: completes a Verve consumption pair when
---the Verve buff faded in the same instant
local function onMajorForceGained()
    local now = GetGameTimeMilliseconds()
    if lastVerveFadedMs > 0 and (now - lastVerveFadedMs) <= VERVE_PAIR_WINDOW_MS then
        lastVerveFadedMs = 0
        onConditionalProc(VERVE_BUFF_ID, 1)
    else
        lastMajorForceMs = now
    end
end

---Registers Crux tracking event handlers
function crux:Initialize()
    EVENT_MANAGER:RegisterForEvent("BattleScrolls_Crux_Slot", EVENT_ACTION_SLOT_ABILITY_USED,
            function(_, actionSlotIndex)
                onActionSlotUsed(actionSlotIndex)
            end)
    for eventAbilityId, canonicalId in pairs(CRUX_GATE_PASS_SOURCES) do
        registerConditionalSource(eventAbilityId, canonicalId, false, true)
    end
    for eventAbilityId, canonicalId in pairs(CRUX_PROC_EFFECT_SOURCES) do
        registerConditionalSource(eventAbilityId, canonicalId, false, false)
    end
    for eventAbilityId, canonicalId in pairs(CRUX_PROC_DAMAGE_SOURCES) do
        registerConditionalSource(eventAbilityId, canonicalId, true, false)
    end
    EVENT_MANAGER:RegisterForEvent("BattleScrolls_Crux_Armor", EVENT_EFFECT_CHANGED, function(_, changeType)
        armorBuffActive = changeType ~= EFFECT_RESULT_FADED
    end)
    EVENT_MANAGER:AddFilterForEvent("BattleScrolls_Crux_Armor", EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_ABILITY_ID, CRUX_ARMOR_BUFF_ID,
            REGISTER_FILTER_UNIT_TAG, "player")
    for buffAbilityId, grantedStacks in pairs(CRUX_MASTERY_BUFF_GAIN_SOURCES) do
        registerBuffGainSource(buffAbilityId, grantedStacks)
    end
    EVENT_MANAGER:RegisterForEvent("BattleScrolls_Crux_Verve", EVENT_EFFECT_CHANGED, function(_, changeType)
        if changeType == EFFECT_RESULT_FADED then
            onVerveFaded()
        end
    end)
    EVENT_MANAGER:AddFilterForEvent("BattleScrolls_Crux_Verve", EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_ABILITY_ID, VERVE_BUFF_ID,
            REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent("BattleScrolls_Crux_Force", EVENT_EFFECT_CHANGED, function(_, changeType)
        if changeType ~= EFFECT_RESULT_FADED then
            onMajorForceGained()
        end
    end)
    EVENT_MANAGER:AddFilterForEvent("BattleScrolls_Crux_Force", EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_ABILITY_ID, MAJOR_FORCE_BUFF_ID,
            REGISTER_FILTER_UNIT_TAG, "player")
    -- Arcanist's Banner sightings for the silent-pulse fallback: the OOC
    -- cooldown tick is our own cast (source = player), the ult pulse is an
    -- energize landing on us (target = player)
    EVENT_MANAGER:RegisterForEvent("BattleScrolls_Crux_BannerOoc", EVENT_COMBAT_EVENT, function()
        bannerLastSeenMs = GetGameTimeMilliseconds()
    end)
    EVENT_MANAGER:AddFilterForEvent("BattleScrolls_Crux_BannerOoc", EVENT_COMBAT_EVENT,
            REGISTER_FILTER_ABILITY_ID, BANNER_TICK_OOC_ID,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EVENT_MANAGER:RegisterForEvent("BattleScrolls_Crux_BannerUlt", EVENT_COMBAT_EVENT, function()
        bannerLastSeenMs = GetGameTimeMilliseconds()
    end)
    EVENT_MANAGER:AddFilterForEvent("BattleScrolls_Crux_BannerUlt", EVENT_COMBAT_EVENT,
            REGISTER_FILTER_ABILITY_ID, BANNER_TICK_ULT_ID,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end

---Unregisters all event handlers for cleanup/hot reload
function crux:Cleanup()
    EVENT_MANAGER:UnregisterForEvent("BattleScrolls_Crux_Slot", EVENT_ACTION_SLOT_ABILITY_USED)
    for _, sources in ipairs({ CRUX_GATE_PASS_SOURCES, CRUX_PROC_EFFECT_SOURCES, CRUX_PROC_DAMAGE_SOURCES }) do
        for eventAbilityId in pairs(sources) do
            EVENT_MANAGER:UnregisterForEvent("BattleScrolls_Crux_Cond" .. eventAbilityId, EVENT_COMBAT_EVENT)
        end
    end
    EVENT_MANAGER:UnregisterForEvent("BattleScrolls_Crux_Armor", EVENT_EFFECT_CHANGED)
    for buffAbilityId in pairs(CRUX_MASTERY_BUFF_GAIN_SOURCES) do
        EVENT_MANAGER:UnregisterForEvent("BattleScrolls_Crux_Buff" .. buffAbilityId, EVENT_EFFECT_CHANGED)
    end
    EVENT_MANAGER:UnregisterForEvent("BattleScrolls_Crux_Verve", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("BattleScrolls_Crux_Force", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("BattleScrolls_Crux_BannerOoc", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent("BattleScrolls_Crux_BannerUlt", EVENT_COMBAT_EVENT)
end
