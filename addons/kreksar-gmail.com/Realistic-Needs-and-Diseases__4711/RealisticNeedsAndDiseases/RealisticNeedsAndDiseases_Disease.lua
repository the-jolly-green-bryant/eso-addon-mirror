-- RealisticNeedsAndDiseases_Disease.lua
-- Manages contraction, progression, and curing of the 6 independent diseases.

RealisticNeeds = RealisticNeeds or {}
local RN = RealisticNeeds

local Disease = {}
RN.Disease = Disease

-- State shape: sv.diseaseState[diseaseId] = {
--   severity = 1|2|3, onsetTime = epoch, careCureProgress = 0
-- }

local exposureSeconds = {
    sustainedCold = 0,  -- frostbite
    sustainedHeat = 0,  -- heatstroke
}

-- Frostbite/Heatstroke: minimum sustained exposure to extreme cold/heat
-- before there's even a CHANCE to roll the disease (the actual roll still
-- only fires sv.settings.diseaseChances.frostbite/.heatstroke of the time
-- once this elapses — this is the wait, not the odds). Originally 90s, then
-- bumped to 600s (10 minutes) per the "at least 10 minutes of un-managed
-- exposure" spec, then reduced to 300s (5 minutes) per request.
Disease.EXPOSURE_THRESHOLD_SECONDS = 300

-- Per-disease cooldown between successful tier-1 ("cheap") ingredient cures.
-- Eating a tier-1 ingredient is never blocked — the game's own item-use/
-- consumption still happens normally — this only gates whether it ALSO
-- triggers the curative effect. Doesn't apply to tier 2/3 ingredients
-- (those already can't fire below their own severity requirement anyway,
-- via GetIngredientTier/AttemptCureDisease's tier >= state.severity check).
Disease.TIER1_CURE_COOLDOWN_SECONDS = 60

-- ─────────────────────────────────────────────────────────────────────────────
-- Contraction / progression
-- ─────────────────────────────────────────────────────────────────────────────
function Disease.ContractOrEscalate(sv, diseaseId)
    local def = RN.Diseases[diseaseId]
    if not def then return nil end

    local state = sv.diseaseState[diseaseId]
    if not state then
        sv.diseaseState[diseaseId] = { severity = RN.SEVERITY_MILD, onsetTime = GetTimeStamp(), careCureProgress = 0 }
        Disease.OnDiseaseChanged(diseaseId, RN.SEVERITY_MILD)
        local hint = RN.Feedback.GetCureHintText(diseaseId, RN.SEVERITY_MILD)
        RN.Feedback.Notify(string.format(
            "You have contracted %s.%s", def.name, hint and (" " .. hint) or ""
        ))
        return RN.SEVERITY_MILD
    else
        local newSeverity = math.min(RN.SEVERITY_SEVERE, state.severity + 1)
        if newSeverity ~= state.severity then
            state.severity = newSeverity
            state.careCureProgress = 0
            Disease.OnDiseaseChanged(diseaseId, newSeverity)
            local severityName = ({ "Mild", "Moderate", "Severe" })[newSeverity] or "?"
            local hint = RN.Feedback.GetCureHintText(diseaseId, newSeverity)
            RN.Feedback.Notify(string.format(
                "Your %s has worsened to %s.%s", def.name, severityName, hint and (" " .. hint) or ""
            ))
        end
        return state.severity
    end
end

-- Directly sets a disease's severity, bypassing normal contraction rolls.
-- Used by /rnd debug disease <index> <severity>. severity must be 1-3; pass
-- nil/0 to clear the disease entirely instead.
function Disease.SetSeverityDirect(sv, diseaseId, severity)
    local def = RN.Diseases[diseaseId]
    if not def then return false end

    if not severity or severity < 1 then
        if sv.diseaseState[diseaseId] then
            sv.diseaseState[diseaseId] = nil
            Disease.OnDiseaseCured(diseaseId)
            RN.Feedback.Notify(string.format("[debug] %s cleared.", def.name))
        end
        return true
    end

    severity = math.max(1, math.min(3, severity))
    sv.diseaseState[diseaseId] = { severity = severity, onsetTime = GetTimeStamp(), careCureProgress = 0 }
    Disease.OnDiseaseChanged(diseaseId, severity)
    local severityName = ({ "Mild", "Moderate", "Severe" })[severity] or "?"
    RN.Feedback.Notify(string.format("[debug] %s set to %s.", def.name, severityName))
    return true
end

-- Downgrades severity by 1 (or cures entirely if already Mild). Resets
-- careCureProgress either way.
local function DowngradeOrCure(sv, diseaseId)
    local state = sv.diseaseState[diseaseId]
    if not state then return end
    if state.severity <= RN.SEVERITY_MILD then
        sv.diseaseState[diseaseId] = nil
        Disease.OnDiseaseCured(diseaseId)
    else
        state.severity = state.severity - 1
        state.careCureProgress = 0
        Disease.OnDiseaseChanged(diseaseId, state.severity)
    end
end

-- Returns the lowest ingredient tier (1/2/3) that itemId is registered under
-- for the given disease, or nil. Each tier is now a LIST of one-or-more
-- interchangeable ingredients (e.g. Frostbite/Heatstroke's tier 3 accepts
-- either Vile Coagulant or Powdered Mother of Pearl) — any match in the list
-- counts.
function Disease.GetIngredientTier(diseaseId, itemId)
    local def = RN.Diseases[diseaseId]
    if not def then return nil end
    for tier = 1, 3 do
        local entries = def.remedyIngredients[tier]
        if entries then
            for _, entry in ipairs(entries) do
                if entry.itemId and entry.itemId == itemId then
                    return tier
                end
            end
        end
    end
    return nil
end

-- Direct cure: itemId's ingredient tier must be >= the disease's current
-- severity. Returns true if cured.
-- Direct cure: itemId's ingredient tier must be >= the disease's current
-- severity. Returns true if cured. Tier-1 cures additionally respect a
-- per-disease cooldown (Disease.TIER1_CURE_COOLDOWN_SECONDS) so a Mild case
-- can't be insta-recured over and over by spamming the cheap ingredient —
-- eating it is never blocked, this just silently skips the cure while on
-- cooldown, same as eating it while not actually diseased at all would.
function Disease.AttemptCureDisease(sv, diseaseId, itemId)
    local state = sv.diseaseState[diseaseId]
    if not state then return false end
    local tier = Disease.GetIngredientTier(diseaseId, itemId)
    if not tier or tier < state.severity then return false end

    if tier == 1 then
        sv.tier1CureCooldowns = sv.tier1CureCooldowns or {}
        local now = GetTimeStamp()
        local cooldownUntil = sv.tier1CureCooldowns[diseaseId]
        if cooldownUntil and now < cooldownUntil then
            return false  -- on cooldown — eaten, but no curative effect this time
        end
        sv.tier1CureCooldowns[diseaseId] = now + Disease.TIER1_CURE_COOLDOWN_SECONDS
    end

    sv.diseaseState[diseaseId] = nil
    Disease.OnDiseaseCured(diseaseId)
    return true
end

function Disease.AttemptCureAny(sv, itemId)
    local cured = {}
    for diseaseId in pairs(sv.diseaseState) do
        if Disease.AttemptCureDisease(sv, diseaseId, itemId) then
            table.insert(cured, diseaseId)
        end
    end
    return cured
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Care-cure: the alternative path for curing stronger afflictions. Eating the
-- disease's TIER-1 (cheapest) ingredient while hunger/thirst/fatigue are ALL
-- above sv.settings.careCureWellFedThreshold builds careCureProgress; once it
-- reaches sv.settings.careCureDosesRequired, the disease downgrades one
-- severity tier (Severe -> Moderate -> Mild -> cured), resetting progress
-- each step. This lets a Severe case eventually be cured with only the cheap
-- ingredient, at the cost of needing several doses AND staying well cared for
-- throughout — slower than the direct tier-matched cure, but cheaper.
-- ─────────────────────────────────────────────────────────────────────────────
local function IsPlayerWellCaredFor(sv)
    local threshold = 70  -- hardcoded; was sv.settings.careCureWellFedThreshold
    return sv.needs.hunger >= threshold and sv.needs.thirst >= threshold and sv.needs.fatigue >= threshold
end

function Disease.OnCareCureProgress(sv, itemId)
    if not IsPlayerWellCaredFor(sv) then return end

    for diseaseId, state in pairs(sv.diseaseState) do
        local def = RN.Diseases[diseaseId]
        local tier1Entries = def and def.remedyIngredients[1]
        local matchedEntry = nil
        if tier1Entries then
            for _, entry in ipairs(tier1Entries) do
                if entry.itemId and entry.itemId == itemId then
                    matchedEntry = entry
                    break
                end
            end
        end
        if matchedEntry then
            state.careCureProgress = (state.careCureProgress or 0) + 1
            local required = 1  -- hardcoded; was sv.settings.careCureDosesRequired
            if state.careCureProgress >= required then
                RN.Feedback.Notify(string.format(
                    "Staying well fed, watered, and rested while eating %s eases your %s.",
                    matchedEntry.name, def.name
                ))
                DowngradeOrCure(sv, diseaseId)
            end
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Per-tick trigger checks (cold/swimming/low-health)
-- ─────────────────────────────────────────────────────────────────────────────
function Disease.OnTick(sv, tickSeconds)
    Disease.CheckSustainedCold(sv, tickSeconds)
    Disease.CheckSustainedHeat(sv, tickSeconds)
end

local function RollContraction(sv, diseaseId)
    -- Single choke point for BOTH contraction paths (exposure re-rolls via
    -- CheckSustainedExposure below, and combat-hit rolls via OnCombatEvent
    -- further down this file) — gating it here covers new contraction and
    -- severity escalation (ContractOrEscalate handles both) for either path
    -- with one check, rather than needing to gate each caller separately.
    if sv.settings.diseaseSystemEnabled == false then return end

    local chance = sv.settings.diseaseChances[diseaseId]
    if chance and math.random() < chance then
        Disease.ContractOrEscalate(sv, diseaseId)
    end
end

-- REVISED PER REQUEST: the contraction roll now REPEATS every
-- EXPOSURE_REROLL_INTERVAL_SECONDS (60s) once the initial
-- EXPOSURE_THRESHOLD_SECONDS (600s) exposure window is met, continuing for
-- as long as the player stays in the qualifying temperature range — not
-- just a single roll at the 600s mark. It stops repeating, per request,
-- the moment EITHER condition is met: the player contracts the disease
-- (sv.diseaseState[diseaseId] becomes non-nil), OR they leave the
-- qualifying temperature range (at which point both timers reset to 0, so
-- re-entering starts the full 600s wait over from scratch).
Disease.EXPOSURE_REROLL_INTERVAL_SECONDS = 60

local rollTimerSeconds = { sustainedCold = 0, sustainedHeat = 0 }

-- Shared by CheckSustainedCold/CheckSustainedHeat below — kind is
-- "sustainedCold" or "sustainedHeat" (matches the exposureSeconds/
-- rollTimerSeconds table keys), diseaseId is "frostbite"/"heatstroke".
local function CheckSustainedExposure(sv, tickSeconds, kind, diseaseId, isExposed)
    if not isExposed then
        exposureSeconds[kind] = 0
        rollTimerSeconds[kind] = 0
        return
    end

    exposureSeconds[kind] = exposureSeconds[kind] + tickSeconds

    if exposureSeconds[kind] < Disease.EXPOSURE_THRESHOLD_SECONDS then
        return  -- still waiting out the initial 600s exposure window
    end

    if sv.diseaseState[diseaseId] then
        -- Already contracted — per request, stop rolling once contracted.
        -- (Doesn't reset exposureSeconds here; see the reset-on-contraction
        -- comment below for why that happens at the moment of contraction
        -- instead, not on every subsequent already-contracted tick.)
        return
    end

    rollTimerSeconds[kind] = rollTimerSeconds[kind] + tickSeconds
    if rollTimerSeconds[kind] >= Disease.EXPOSURE_REROLL_INTERVAL_SECONDS then
        rollTimerSeconds[kind] = 0
        RollContraction(sv, diseaseId)
        if sv.diseaseState[diseaseId] then
            -- Just contracted on this roll: reset the long exposure timer
            -- too, so that if this gets cured later while the player is
            -- STILL standing in the same cold/heat, it takes a full fresh
            -- 600s wait before any new roll can happen again, rather than
            -- immediately resuming 60s re-rolls right after a cure.
            exposureSeconds[kind] = 0
        end
    end
end

-- Frostbite: see the long comment on the frostbite entry in Data.lua for why
-- GetCurrentTemperature()'s existing Frostfall-preferred/LibZoneTemp-fallback
-- priority already satisfies the "optional Frostfall" requirement with no
-- extra branching needed here.
function Disease.CheckSustainedCold(sv, tickSeconds)
    local temp = RN.Calculator.GetCurrentTemperature()
    local isExposed = temp ~= nil and temp < RN.Calculator.COMFORT_MIN
    CheckSustainedExposure(sv, tickSeconds, "sustainedCold", "frostbite", isExposed)
end

-- Heatstroke: mirrors CheckSustainedCold exactly, just the hot side of the
-- same comfort band and same temperature source priority.
function Disease.CheckSustainedHeat(sv, tickSeconds)
    local temp = RN.Calculator.GetCurrentTemperature()
    local isExposed = temp ~= nil and temp > RN.Calculator.COMFORT_MAX
    CheckSustainedExposure(sv, tickSeconds, "sustainedHeat", "heatstroke", isExposed)
end

-- Read-only status for the /rnd debug frostbitetimer / heatstroketimer
-- commands (RealisticNeedsAndDiseases.lua). kind is "cold" or "heat" —
-- returns nil for anything else. sv is required now (to check whether the
-- disease is already contracted, which changes what's actually happening).
-- This reads the EXACT SAME exposureSeconds/rollTimerSeconds counters
-- CheckSustainedCold/CheckSustainedHeat themselves use — a live view of the
-- real state, not a parallel estimate that could drift out of sync with it.
function Disease.GetSustainedExposureStatus(kind, sv)
    local temp = RN.Calculator.GetCurrentTemperature()
    local exposed, key, diseaseId
    if kind == "cold" then
        exposed = temp ~= nil and temp < RN.Calculator.COMFORT_MIN
        key, diseaseId = "sustainedCold", "frostbite"
    elseif kind == "heat" then
        exposed = temp ~= nil and temp > RN.Calculator.COMFORT_MAX
        key, diseaseId = "sustainedHeat", "heatstroke"
    else
        return nil
    end

    local elapsed = exposureSeconds[key]
    local pastThreshold = elapsed >= Disease.EXPOSURE_THRESHOLD_SECONDS
    local contracted = sv and sv.diseaseState[diseaseId] ~= nil or false

    local remaining
    if not pastThreshold then
        remaining = math.max(0, Disease.EXPOSURE_THRESHOLD_SECONDS - elapsed)
    else
        remaining = math.max(0, Disease.EXPOSURE_REROLL_INTERVAL_SECONDS - rollTimerSeconds[key])
    end

    return {
        exposed = exposed,
        temp = temp,
        contracted = contracted,
        elapsedSeconds = elapsed,
        thresholdSeconds = Disease.EXPOSURE_THRESHOLD_SECONDS,
        pastThreshold = pastThreshold,
        rerollIntervalSeconds = Disease.EXPOSURE_REROLL_INTERVAL_SECONDS,
        rollTimerSeconds = rollTimerSeconds[key],
        remainingSeconds = remaining,
    }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Mage's Bane, Fighter's Bane, and Thief's Bane: all three triggered by
-- taking real typed combat damage, each with its own very slim default
-- chance per hit (sv.settings.diseaseChances.<id>). Each entry below is a
-- LIST, not a single id — DAMAGE_TYPE_DISEASE, for instance, feeds
-- thiefsBane, rolling independently off its own diseaseChances value (see
-- RollContraction).
--
-- DAMAGE_TYPE_DISEASE and DAMAGE_TYPE_MAGIC carry over unchanged from the
-- earlier wormwoodPlague/magicBlight implementation and are confirmed-real
-- globals (already in production use). The rest — DAMAGE_TYPE_FIRE,
-- DAMAGE_TYPE_SHOCK, DAMAGE_TYPE_COLD (mageBane's widened trigger), and
-- DAMAGE_TYPE_POISON, DAMAGE_TYPE_PHYSICAL (fightersBane/thiefsBane's new
-- triggers) — are believed-real but NOT individually confirmed against a
-- live client.
--
-- A PREVIOUS VERSION OF THIS TABLE HARD-CRASHED ON LOAD: it used
-- DAMAGE_TYPE_FROST as a literal table key, but that global doesn't exist
-- (the real ESO constant is DAMAGE_TYPE_COLD — "Frost Damage" is flavor
-- text, the engine kept the older "Cold" name). A nonexistent global
-- resolves to nil, and Lua throws "table index is nil" the moment a literal
-- constructor tries to use nil as a key — at FILE LOAD time, so the whole
-- addon failed to load, not just this one trigger.
--
-- To make sure a wrong/renamed constant can NEVER do that again, this table
-- is now built defensively at runtime via AddDiseaseTrigger below: any
-- damage-type global that doesn't currently exist is silently skipped
-- (printed once to chat instead of crashing) rather than used as a literal
-- key. Also dropped DAMAGE_TYPE_BLEED entirely — "Bleed" appears to be a
-- status effect carried under Physical damage rather than its own distinct
-- DamageType in ESO's combat model, not a separate constant — so
-- Fighter's Bane is wired to DAMAGE_TYPE_PHYSICAL only for now. If a real
-- distinct Bleed damage-type constant is later confirmed, add it the same
-- way (AddDiseaseTrigger("fightersBane", "DAMAGE_TYPE_BLEED")).
--
-- PARAMETER ORDER UNVERIFIED IN A LIVE CLIENT: matches the commonly
-- documented EVENT_COMBAT_EVENT signature — confirm against
-- https://wiki.esoui.com/EVENT_COMBAT_EVENT before trusting it blindly.
-- ─────────────────────────────────────────────────────────────────────────────
local DAMAGE_TYPE_TO_DISEASES = {}
local _unresolvedDamageTypeGlobals = {}

-- globalName is passed as a STRING (e.g. "DAMAGE_TYPE_FIRE") precisely so a
-- nonexistent global never has to appear as a literal, eagerly-evaluated
-- table key — _G[globalName] resolving to nil is just a normal nil value
-- here, not an indexing error.
local function AddDiseaseTrigger(diseaseId, globalName)
    local damageType = _G[globalName]
    if damageType == nil then
        table.insert(_unresolvedDamageTypeGlobals, globalName)
        return
    end
    DAMAGE_TYPE_TO_DISEASES[damageType] = DAMAGE_TYPE_TO_DISEASES[damageType] or {}
    table.insert(DAMAGE_TYPE_TO_DISEASES[damageType], diseaseId)
end

AddDiseaseTrigger("thiefsBane",   "DAMAGE_TYPE_DISEASE")
AddDiseaseTrigger("thiefsBane",   "DAMAGE_TYPE_POISON")
AddDiseaseTrigger("mageBane",     "DAMAGE_TYPE_MAGIC")
AddDiseaseTrigger("mageBane",     "DAMAGE_TYPE_FIRE")
AddDiseaseTrigger("mageBane",     "DAMAGE_TYPE_COLD")
AddDiseaseTrigger("mageBane",     "DAMAGE_TYPE_SHOCK")
AddDiseaseTrigger("fightersBane", "DAMAGE_TYPE_PHYSICAL")

if #_unresolvedDamageTypeGlobals > 0 then
    CHAT_SYSTEM:AddMessage(string.format(
        "|c88CCFF[Realistic Needs and Diseases]|r Some disease damage-type triggers didn't resolve and were skipped (no contraction chance from them until fixed): %s",
        table.concat(_unresolvedDamageTypeGlobals, ", ")
    ))
end

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
                              abilityActionSlotType, sourceName, sourceType, targetName, targetType,
                              hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId,
                              overflow)
    if targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    if sourceType == COMBAT_UNIT_TYPE_PLAYER then return end

    local isDamage = (result == ACTION_RESULT_DAMAGE) or (result == ACTION_RESULT_CRITICAL_DAMAGE)
                      or (result == ACTION_RESULT_DOT_TICK) or (result == ACTION_RESULT_DOT_TICK_CRITICAL)
    if not isDamage then return end

    local diseaseIds = DAMAGE_TYPE_TO_DISEASES[damageType]
    if not diseaseIds then return end

    local sv = RN.SavedVars
    for _, diseaseId in ipairs(diseaseIds) do
        RollContraction(sv, diseaseId)
    end
end

-- Registered from Disease.Initialize(), called by OnAddOnLoaded in the main
-- file — not here at file scope, so RN.SavedVars is guaranteed to exist
-- before this can fire.
function Disease.Initialize()
    EVENT_MANAGER:RegisterForEvent("RealisticNeeds_CombatEvent", EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent("RealisticNeeds_CombatEvent", EVENT_COMBAT_EVENT,
        REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    -- Filtered to BAG_BACKPACK (remedies are eaten from the carried backpack)
    -- AND to INVENTORY_UPDATE_REASON_DEFAULT (excluding durability/charge-type
    -- updates this event also fires for). See https://wiki.esoui.com/AddFilterForEvent.
    EVENT_MANAGER:RegisterForEvent("RealisticNeeds_RemedyInventory", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        Disease.OnRemedyInventoryChange)
    EVENT_MANAGER:AddFilterForEvent("RealisticNeeds_RemedyInventory", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID, BAG_BACKPACK,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Remedy ingredient consumption detection. Mirrors Frostfall's
-- OnReagentInventoryChange pattern exactly: stackCountChange < 0 is the
-- consumption signal, with prevLink cached per-slot to recover the item link
-- for slots that empty completely (no live link available after the last unit
-- is consumed). Gated off during trade windows via RN.IsTradeWindowOpen().
--
-- The previous implementation used a full snapshot approach (same as the
-- food/drink handler in RealisticNeedsAndDiseases.lua) with a local
-- _lastSlotState that was NEVER seeded at load — so the first ingredient
-- consumed in any session always had prevState == nil and was silently
-- dropped. Frostfall's simpler stackCountChange < 0 path avoids that
-- entirely, and is the right tool for reagents: unlike food/drink, there is
-- no LibFoodDrinkBuff timing race to guard against, so the extra snapshot
-- machinery added no value while introducing the seeding failure.
--
-- On every reagent consumed, checks BOTH the direct tier-matched cure AND
-- the care-cure progress path (a tier-1 ingredient can directly cure a Mild
-- case OR contribute progress toward downgrading a more severe one).
-- ─────────────────────────────────────────────────────────────────────────────
local _lastRemedyLinkBySlot = {}

function Disease.OnRemedyInventoryChange(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason, stackCountChange)
    if bagId ~= BAG_BACKPACK then return end

    local key         = bagId .. ":" .. slotId
    local prevLink    = _lastRemedyLinkBySlot[key]
    local currentLink = GetItemLink(bagId, slotId)
    local itemLink    = (currentLink ~= "" and currentLink) or prevLink
    _lastRemedyLinkBySlot[key] = (currentLink ~= "" and currentLink) or nil

    if stackCountChange >= 0 then return end
    if not itemLink or itemLink == "" then return end
    if RN.IsTradeWindowOpen() then return end

    local itemType = GetItemLinkItemType(itemLink)
    if itemType ~= ITEMTYPE_REAGENT then return end

    local sv       = RN.SavedVars
    local itemId   = GetItemLinkItemId(itemLink)
    local itemName = GetItemLinkName(itemLink) or "the ingredient"

    local cured = Disease.AttemptCureAny(sv, itemId)
    for _, diseaseId in ipairs(cured) do
        local def = RN.Diseases[diseaseId]
        RN.Feedback.Notify(string.format(
            "Eating %s cures your %s.",
            itemName, def and def.name or diseaseId
        ))
    end

    Disease.OnCareCureProgress(sv, itemId)
end

-- (registered above, inside Disease.Initialize())

-- ─────────────────────────────────────────────────────────────────────────────
-- Overlay hooks
-- ─────────────────────────────────────────────────────────────────────────────
function Disease.OnDiseaseChanged(diseaseId, newSeverity)
    if RN.Overlay and RN.Overlay.RefreshDisease then
        RN.Overlay.RefreshDisease(diseaseId, newSeverity)
    end
    if RN.Feedback and RN.Feedback.PlayCategoryEmote then
        if not RN.Feedback.CanPlayEmotesNow or RN.Feedback.CanPlayEmotesNow(RN.SavedVars) then
            RN.Feedback.PlayCategoryEmote(RN.SavedVars, "disease")
            RN.Feedback.NoteImmediateEmote("disease")
        end
    end
end

function Disease.OnDiseaseCured(diseaseId)
    if RN.Overlay and RN.Overlay.ClearDisease then
        RN.Overlay.ClearDisease(diseaseId)
    end
end
