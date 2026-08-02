-- ============================================================
-- MyCombatText.Combat.lua
-- Main combat event processing pipeline.
-- Registers LibCombat2 and EVENT_COMBAT_EVENT callbacks, parses
-- raw ESO event payloads into a normalized form, classifies each
-- event as damage/heal/CC, applies per-feature filters, and
-- dispatches to the merge queue (MCT.Tracking) for display.
-- Also handles resource restore events and the resource display.
-- ============================================================

MyCombatText = MyCombatText or {}
local MCT = MyCombatText
local LC = LibCombat2          -- LibCombat2 library handle; provides higher-level combat callbacks.
local RF = MCT.Result           -- Combat result classifier namespace from ResultFilter.lua.

-- Local alias for frequently called timer function.
local GetGameTimeMs = GetGameTimeMilliseconds

-- ---------------------------------------------------------------
-- IsHealingResult: extended heal classifier that falls back to a
-- power-type heuristic when the ESO ACTION_RESULT_* constant does
-- not match any known heal result. This handles API version drift
-- where new result IDs appear that our result table hasn't been
-- updated to include yet.
--
-- Logic:
--   1. Check RF.IsHeal() first (explicit ACTION_RESULT match).
--   2. Fallback: if powerType == POWERTYPE_HEALTH and there is a
--      non-zero hit/overflow value and the result is NOT classified
--      as damage, treat it as healing.
--
-- Parameters:
--   result    : ACTION_RESULT_* integer from the combat event
--   powerType : POWERTYPE_* integer (HEALTH, MAGICKA, STAMINA)
--   hitValue  : raw hit amount from the event
--   overflow  : overflow (overheal) amount from the event
-- Returns: true when the event should be treated as healing.
-- ---------------------------------------------------------------
local function IsHealingResult(result, powerType, hitValue, overflow)
    -- Primary check: known heal result constant.
    if RF.IsHeal(result) then
        return true
    end

    -- Fallback for API/result-id drift: health gain with no damage flag is healing.
    local value = tonumber(hitValue) or 0
    local over = tonumber(overflow) or 0
    local isHealthPower = (powerType == POWERTYPE_HEALTH)
    if isHealthPower and (value > 0 or over > 0) and not RF.IsDamage(result) then
        return true
    end

    return false
end

-- ---------------------------------------------------------------
-- ParseLibCombatPayload: normalizes a raw LibCombat2 callback
-- vararg into a consistent table with named fields.
--
-- Problem: LibCombat can deliver events in multiple argument
-- layouts ("shapes") depending on the event type and library
-- version. Rather than hard-coding one layout, we produce multiple
-- candidate interpretations and score each one to pick the most
-- plausible one for the current player.
--
-- Scoring weights (applied by scoreCandidate):
--   +4  one of source/target matches the player's unit ID
--   +3  hitValue or overflow is > 0 (the event actually did something)
--   +2  result maps to a recognized damage or heal constant
--
-- Shape A (compact LibCombat callback, <=16 args):
--   ec, [timeMs?], result, sourceUnitId, targetUnitId,
--   abilityId, hitValue, damageType, overflow
--
-- Shape B (full combat-event mirror, 17+ args):
--   ec, result, _, _, _, _, _, _, _, _, hitValue, _,
--   damageType, _, sourceUnitId, targetUnitId, abilityId, overflow
--
-- Parameters:
--   playerId : the player's unit ID string from LC.GetPlayerUnitId()
--   ...      : raw callback varargs
-- Returns: the best-scoring candidate table, or candidates[1] as fallback.
-- ---------------------------------------------------------------
local function ParseLibCombatPayload(playerId, ...)
    local argc = select("#", ...)

    -- pickCandidate: evaluates all candidate interpretations and returns
    -- the one with the highest relevance score for the current player.
    local function pickCandidate(candidates)
        local bestCandidate = nil
        local bestScore = -1

        -- scoreCandidate: assigns an integer score to a single candidate
        -- interpretation based on how well it matches expected event fields.
        local function scoreCandidate(c)
            local score = 0
            local sourceUnitId = c and c.sourceUnitId
            local targetUnitId = c and c.targetUnitId
            local hitValue = tonumber(c and c.hitValue) or 0
            local overflow = tonumber(c and c.overflow) or 0
            local result = c and c.result

            -- Highest weight: at least one unit ID is the player.
            if sourceUnitId == playerId or targetUnitId == playerId then
                score = score + 4
            end

            -- Mid weight: the event actually has a non-zero value to display.
            if hitValue > 0 or overflow > 0 then
                score = score + 3
            end

            -- Lower weight: result maps to a known damage or heal constant.
            if RF.IsDamage(result) or RF.IsHeal(result) then
                score = score + 2
            end

            return score
        end

        for i = 1, #candidates do
            local c = candidates[i]
            if c then
                local score = scoreCandidate(c)
                if score > bestScore then
                    bestScore = score
                    bestCandidate = c
                end
            end
        end

        return bestCandidate or candidates[1]
    end

    -- ----- Shape B: 17+ args — full combat-event-like callback -----
    -- Shape A (compact callback):  ec, timeMs, result, src, tgt, abilityId, hitValue, dmgType, overflow
    -- Shape B (combat-event-like): ec, result, _, _, _, _, _, _, _, _, hitValue, _, dmgType, _, src, tgt, abilityId, overflow
    if argc >= 17 then
        return pickCandidate({
            {
                -- Interpret as Shape B: result at arg 2, unitIds at 15/16.
                ec = select(1, ...),
                result = select(2, ...),
                sourceUnitId = select(15, ...),
                targetUnitId = select(16, ...),
                abilityId = select(17, ...),
                hitValue = select(11, ...),
                damageType = select(13, ...),
                overflow = select(18, ...),
            },
            {
                -- Interpret as Shape A (compact) but with a time offset.
                ec = select(1, ...),
                result = select(3, ...),
                sourceUnitId = select(4, ...),
                targetUnitId = select(5, ...),
                abilityId = select(6, ...),
                hitValue = select(7, ...),
                damageType = select(8, ...),
                overflow = select(9, ...),
            },
        })
    end

    local ec = select(1, ...)
    local arg2 = select(2, ...)
    local arg3 = select(3, ...)

    -- ----- Shape A variant: arg2 is a number (timestamp offset) -----
    -- When arg2 is numeric it is a timestamp in the compact layout, so
    -- the result starts at arg3 and unit IDs shift by one position.
    if type(arg2) == "number" then
        return pickCandidate({
            {
                -- result at arg3, unitIds at 4/5.
                ec = ec,
                result = arg3,
                sourceUnitId = select(4, ...),
                targetUnitId = select(5, ...),
                abilityId = select(6, ...),
                hitValue = select(7, ...),
                damageType = select(8, ...),
                overflow = select(9, ...),
            },
            {
                -- Alternate: result at arg2 (numeric could be a result ID).
                ec = ec,
                result = arg2,
                sourceUnitId = select(3, ...),
                targetUnitId = select(4, ...),
                abilityId = select(5, ...),
                hitValue = select(6, ...),
                damageType = select(7, ...),
                overflow = select(8, ...),
            },
        })
    end

    -- ----- Default shape: result at arg2, unitIds at 3/4 -----
    return pickCandidate({
        {
            ec = ec,
            result = arg2,
            sourceUnitId = select(3, ...),
            targetUnitId = select(4, ...),
            abilityId = select(5, ...),
            hitValue = select(6, ...),
            damageType = select(7, ...),
            overflow = select(8, ...),
        },
        {
            -- Alternate with one-position shift in case layout differs.
            ec = ec,
            result = arg3,
            sourceUnitId = select(4, ...),
            targetUnitId = select(5, ...),
            abilityId = select(6, ...),
            hitValue = select(7, ...),
            damageType = select(8, ...),
            overflow = select(9, ...),
        },
    })
end

-- ---------------------------------------------------------------
-- OnLibCombatEventDone: handles raw EVENT_COMBAT_EVENT callbacks.
-- This is the primary heal/HoT handler and the CC display handler.
-- It uses the full named-parameter ESO combat event signature so
-- there is no payload shape ambiguity — all fields are explicit.
--
-- Heal routing: if the result classifies as healing, it is queued
-- via MCT:QueueHit directly from here, bypassing LibCombat entirely.
-- This makes self-heals, incoming heals, and HoT ticks reliable
-- even when the LibCombat payload parser picks the wrong shape.
--
-- CC routing: dodge and crowd-control results on a target that is
-- NOT the player are shown as status labels. Damage results on the
-- player (damageTaken) are also dispatched from here for the simple
-- direct-display path (no merge window, shown immediately).
--
-- Parameters (all from ESO EVENT_COMBAT_EVENT):
--   ec           : event code constant
--   result       : ACTION_RESULT_* integer
--   ABILITYNAME  : display name of the ability (unused, for reference)
--   slotType     : action slot type enum
--   sourceName   : display name of the source unit
--   sourceType   : COMBAT_UNIT_TYPE_* of the source
--   targetName   : display name of the target unit
--   targetType   : COMBAT_UNIT_TYPE_* of the target
--   hitValue     : raw damage or healing amount
--   powerType    : POWERTYPE_* involved in the event
--   damageType   : DAMAGE_TYPE_* (fire, physical, etc.)
--   log          : whether this event appears in the combat log
--   sourceUnitId : unit ID string of the source
--   targetUnitId : unit ID string of the target
--   abilityId    : ESO ability integer ID
--   overflow     : overheal or over-shield amount
-- ---------------------------------------------------------------
function OnLibCombatEventDone(ec, result, _, ABILITYNAME, _, slotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not MCT.sv.enabled then return end

    local playerId = LC.GetPlayerUnitId()

    -- Determine player involvement using both unit IDs and unit type enums.
    -- The type enum fallback handles events where unit IDs arrive as 0 or nil.
    local sourceIsPlayer = (sourceUnitId == playerId) or (sourceType == COMBAT_UNIT_TYPE_PLAYER)
    local targetIsPlayer = (targetUnitId == playerId) or (targetType == COMBAT_UNIT_TYPE_PLAYER)

    -- Skip events that involve neither the player as source nor target.
    if not sourceIsPlayer and not targetIsPlayer then return end

    -- Patch missing/zero unit IDs using the type-based detection above
    -- so downstream code can safely compare against playerId.
    if sourceUnitId == nil or sourceUnitId == 0 then
        sourceUnitId = sourceIsPlayer and playerId or sourceUnitId
    end
    if targetUnitId == nil or targetUnitId == 0 then
        targetUnitId = targetIsPlayer and playerId or targetUnitId
    end

    if MCT.sv.pvpOnly and not IsUnitPvPFlagged("player") then return end

    -- Classify event direction relative to the player.
    local outgoing = sourceIsPlayer and not targetIsPlayer  -- player acted on another unit
    local incoming = not sourceIsPlayer and targetIsPlayer  -- another unit acted on the player
    local selfEvent = sourceIsPlayer and targetIsPlayer     -- player acted on themselves

    -- ---- Healing / HoT branch ----
    -- Checked before the CC/damage branches so heals are never misrouted.
    local isHeal = IsHealingResult(result, powerType, hitValue, overflow)
    if isHeal then
        local value = tonumber(hitValue) or 0
        local over = tonumber(overflow) or 0
        local crit = RF.IsCrit(result)

        if MCT.sv.showHealing and (not MCT.sv.critOnly or crit) then
            if value > 0 then
                -- Choose merge group based on direction so labels appear in
                -- the correct screen position and aggregate correctly.
                local mergeGroup = "healing:self"
                if incoming then
                    mergeGroup = "healing:incoming"   -- healed by someone else
                elseif outgoing then
                    mergeGroup = "healing:outgoing"   -- player healed another target
                elseif selfEvent then
                    mergeGroup = "healing:self"        -- self-cast heal or HoT tick
                end

                MCT:QueueHit(value, crit, true, sourceUnitId, targetUnitId, false, abilityId, mergeGroup)
            end

            -- Show overheal separately if it is configured and present.
            if MCT.sv.showOverhealing and over > 0 then
                MCT:QueueOverhealing(over, crit, sourceUnitId, targetUnitId, abilityId)
            end
        end

        -- Healing is fully handled here; return before the CC/damage section.
        return
    end

    -- ---- CC on other units (outgoing CC the player applied) ----
    -- When the target is NOT the player, this event may be a CC the player
    -- applied to an enemy. Only CC results are shown for other targets;
    -- damage to other targets is handled by OnLibCombatEvent instead.
    if targetUnitId ~= playerId then
        local dodge     = RF.IsDodged(result)
        local charm     = RF.IsCharmed(result)
        local stun      = RF.IsStunned(result)
        local fear      = RF.IsFeared(result)
        local silence   = RF.IsSilenced(result)
        local disorient = RF.IsDisoriented(result)
        local offbalance  = RF.IsOffbalanced(result)
        local immobilized = RF.IsImmobilized(result)

        -- If not any recognized CC type, skip the event entirely.
        if not (dodge or charm or stun or fear or silence or disorient or offbalance or immobilized) then return end

        -- Display the appropriate CC label for the target.
        if dodge then
            MCT:ShowText(nil, false, false, "dodged", sourceUnitId, targetUnitId, false, abilityId)
        elseif charm then
            MCT:ShowText(nil, false, false, "charmed", sourceUnitId, targetUnitId, false, abilityId)
        elseif stun then
            MCT:ShowText(nil, false, false, "stunned", sourceUnitId, targetUnitId, false, abilityId)
        elseif fear then
            MCT:ShowText(nil, false, false, "feared", sourceUnitId, targetUnitId, false, abilityId)
        elseif silence then
            MCT:ShowText(nil, false, false, "silenced", sourceUnitId, targetUnitId, false, abilityId)
        elseif disorient then
            MCT:ShowText(nil, false, false, "disoriented", sourceUnitId, targetUnitId, false, abilityId)
        elseif offbalance then
            MCT:ShowText(nil, false, false, "offbalanced", sourceUnitId, targetUnitId, false, abilityId)
        elseif immobilized then
            MCT:ShowText(nil, false, false, "immobilized", sourceUnitId, targetUnitId, false, abilityId)
        end
        return
    end

    -- ---- Damage taken / CC received by the player ----
    -- At this point targetUnitId == playerId, so all remaining events are
    -- things that happened TO the player: damage taken and CC received.
    local crit        = RF.IsCrit(result)
    local damageTaken = RF.IsDamageTaken(result)
    local dodge       = RF.IsDodged(result)
    local charm       = RF.IsCharmed(result)
    local stun        = RF.IsStunned(result)
    local fear        = RF.IsFeared(result)
    local silence     = RF.IsSilenced(result)
    local disorient   = RF.IsDisoriented(result)
    local offbalance  = RF.IsOffbalanced(result)
    local immobilized = RF.IsImmobilized(result)

    -- Skip if the result is not one we handle.
    if not (damageTaken or dodge or charm or stun or fear or silence or disorient or offbalance or immobilized) then return end

    -- Display the matching label for whatever happened to the player.
    if dodge then
        MCT:ShowText(nil, false, false, "dodged", sourceUnitId, targetUnitId, false, abilityId)
    elseif damageTaken and crit then
        -- Critical incoming damage: show with crit styling.
        MCT:ShowText(hitValue, true, false, nil, sourceUnitId, targetUnitId, false, abilityId)
    elseif damageTaken then
        -- Regular incoming damage.
        MCT:ShowText(hitValue, false, false, nil, sourceUnitId, targetUnitId, false, abilityId)
    elseif charm then
        MCT:ShowText(nil, false, false, "charmed", sourceUnitId, targetUnitId, false, abilityId)
    elseif stun then
        MCT:ShowText(nil, false, false, "stunned", sourceUnitId, targetUnitId, false, abilityId)
    elseif fear then
        MCT:ShowText(nil, false, false, "feared", sourceUnitId, targetUnitId, false, abilityId)
    elseif silence then
        MCT:ShowText(nil, false, false, "silenced", sourceUnitId, targetUnitId, false, abilityId)
    elseif disorient then
        MCT:ShowText(nil, false, false, "disoriented", sourceUnitId, targetUnitId, false, abilityId)
    elseif offbalance then
        MCT:ShowText(nil, false, false, "offbalanced", sourceUnitId, targetUnitId, false, abilityId)
    elseif immobilized then
        MCT:ShowText(nil, false, false, "immobilized", sourceUnitId, targetUnitId, false, abilityId)
    end
end

-- ---------------------------------------------------------------
-- OnLibCombatEvent: handles LibCombat2 damage callbacks.
-- LibCombat2 provides pre-processed callbacks with a more
-- consistent payload than raw ESO events, but the argument layout
-- can still vary. ParseLibCombatPayload normalizes it.
--
-- This function handles outgoing damage (player -> target) only;
-- heal routing has been moved to OnLibCombatEventDone to use the
-- explicit named-argument ESO signature instead.
--
-- Parameters:
--   forcedKind : "damage" or "heal" string injected by the callback
--                registration so the event type is always unambiguous
--   ...        : raw LibCombat2 callback varargs
-- ---------------------------------------------------------------
function OnLibCombatEvent(forcedKind, ...)
    if not MCT.sv.enabled then return end

    local playerId = LC.GetPlayerUnitId()
    -- Normalize the vararg payload into a named-field table.
    local payload = ParseLibCombatPayload(playerId, ...)
    local ec = payload.ec
    local result = payload.result
    local sourceUnitId = payload.sourceUnitId
    local targetUnitId = payload.targetUnitId
    local abilityId = payload.abilityId
    local hitValue = payload.hitValue
    local overflow = payload.overflow

    -- Ensure numeric types; discard events with no meaningful value.
    hitValue = tonumber(hitValue) or 0
    overflow = tonumber(overflow) or 0
    if hitValue <= 0 and overflow <= 0 then return end

    if MCT.sv.pvpOnly and not IsUnitPvPFlagged("player") then return end

    -- Opportunistic tracking table cleanup every 5 seconds.
    MCT:PruneTrackingTables(GetGameTimeMs())

    -- Classify event direction relative to the player.
    local playerHealing    = targetUnitId == playerId                                    -- Player is being healed.
    local playerHeals      = sourceUnitId == playerId and targetUnitId ~= playerId       -- Player is healing another.
    local playerDamaging   = sourceUnitId == playerId and targetUnitId ~= playerId       -- Player is dealing damage.
    local playerDamageTaken = sourceUnitId ~= playerId and targetUnitId == playerId      -- Player is taking damage.
    local outgoing = sourceUnitId == playerId and targetUnitId ~= playerId               -- Any outgoing event.
    local incoming = sourceUnitId ~= playerId and targetUnitId == playerId               -- Any incoming event.

    -- Skip events that are entirely unrelated to the player.
    if not (outgoing or incoming or playerHealing or (sourceUnitId == playerId and targetUnitId == playerId)) then return end

    -- Determine event category using both the forcedKind hint and the
    -- result constant. forcedKind wins when it is explicitly set because
    -- LibCombat2 already classified the event before calling us.
    local isDamageEvent = (forcedKind == "damage") or (ec == LIBCOMBAT_LOG_EVENT_DAMAGE)
    local isHealEvent   = (forcedKind == "heal")   or (ec == LIBCOMBAT_LOG_EVENT_HEAL)
    local dmg  = RF.IsDamage(result) or isDamageEvent
    local heal = RF.IsHeal(result)   or isHealEvent

    -- If the callback explicitly declares the kind, override ambiguous result lookups.
    if isHealEvent then
        dmg  = false
        heal = true
    elseif isDamageEvent then
        dmg  = true
        heal = false
    end

    local crit    = RF.IsCrit(result)
    local dot     = RF.IsDot(result)     -- damage-over-time tick result
    local blocked = RF.IsBlocked(result) -- attack was blocked by the target

    -- Global display filters: skip categories disabled in settings.
    if MCT.sv.critOnly and not crit then return end          -- critOnly mode: ignore all non-crits
    if dmg  and not MCT.sv.showDamage  then return end       -- damage display disabled
    if heal and not MCT.sv.showHealing then return end       -- healing display disabled
    if dot  and not MCT.sv.showDots    then return end       -- DoT tick display disabled

    -- ---- Outgoing events (player acted on another target) ----
    if outgoing then
        if dmg then
            if hitValue > 0 then
                -- Queue the outgoing damage hit for display.
                MCT:QueueHit(hitValue, crit, false, sourceUnitId, targetUnitId, blocked, abilityId, "damage:outgoing")
                -- Feed the hit into the rolling DPS tracker.
                MCT:AddDps(targetUnitId, hitValue)
                -- Check if this hit, combined with recent hits, triggers a burst alert.
                MCT:TrackBurst(targetUnitId, hitValue, crit)
                -- Check if hitting a shielded unit signals a shield-break opportunity.
                MCT:TrackShieldbreak(targetUnitId, hitValue, RF.IsShielded(result))
                -- Apply the "pressure" priority marker for sustained offensive pressure.
                MCT:ApplyMarkerRule(targetUnitId, "pressure")
            end
        elseif heal then
            -- Outgoing heal: player healed another unit (e.g. healing ally).
            if hitValue > 0 then
                MCT:QueueHit(hitValue, crit, true, sourceUnitId, targetUnitId, false, abilityId, "healing:outgoing")
            end
            -- Also queue any overflow as overhealing.
            if MCT.sv.showOverhealing and overflow > 0 then
                MCT:QueueOverhealing(overflow, crit, sourceUnitId, targetUnitId, abilityId)
            end
        end
        return  -- Outgoing events are fully handled above.
    end

    -- ---- Incoming / self events (player is the target or self-cast) ----
    if dmg then
        if hitValue > 0 then
            -- Select the merge group based on whether this is incoming or self-damage.
            local mergeGroup = "damage:self"
            if incoming then
                -- Incoming damage from another unit: show as damageTaken.
                mergeGroup = blocked and "damageTaken:blocked" or "damageTaken"
            end
            MCT:QueueHit(hitValue, crit, false, sourceUnitId, targetUnitId, blocked, abilityId, mergeGroup)
        end
    elseif heal then
        -- Incoming or self heal (HoT ticks, received heals).
        if hitValue > 0 then
            local mergeGroup = incoming and "healing:incoming" or "healing:self"
            MCT:QueueHit(hitValue, crit, true, sourceUnitId, targetUnitId, false, abilityId, mergeGroup)
        end
        -- Also queue overflow as overhealing.
        if MCT.sv.showOverhealing and overflow > 0 then
            MCT:QueueOverhealing(overflow, crit, sourceUnitId, targetUnitId, abilityId)
        end
    end
end

-- ---------------------------------------------------------------
-- MCT:RegisterCombat: registers all combat and power update event
-- listeners. Called once during addon initialization.
--
-- LibCombat "Damage" callback: handles all outgoing damage events
-- via OnLibCombatEvent("damage"). LibCombat pre-processes these
-- into a cleaner format than raw ESO events.
--
-- EVENT_COMBAT_EVENT (CCDone): ESO's raw combat event. Used here
-- as the primary heal/HoT handler (OnLibCombatEventDone) because
-- it exposes all fields by name, making heal routing reliable
-- without depending on LibCombat payload shape.
--
-- EVENT_POWER_UPDATE (ResourceRestore): fires whenever the player's
-- power pool changes. Used to detect magicka/stamina/health regen.
-- ---------------------------------------------------------------
function MCT:RegisterCombat()
    -- Register LibCombat2 damage callback. forcedKind="damage" is injected
    -- so OnLibCombatEvent always knows it is processing a damage event.
    LC:RegisterCallbackType(LIBCOMBAT_LOG_EVENT_DAMAGE, function(...)
        OnLibCombatEvent("damage", ...)
    end, MCT.name .. "Damage")

    -- Raw ESO combat event: used for heals (primary path) and CC labels.
    EVENT_MANAGER:RegisterForEvent(MCT.name .. "CCDone", EVENT_COMBAT_EVENT, OnLibCombatEventDone)

    -- Power update: detect resource restoration (magicka, stamina, health).
    EVENT_MANAGER:RegisterForEvent(MCT.name .. "ResourceRestore", EVENT_POWER_UPDATE, OnResourceRestore)
end

-- ---------------------------------------------------------------
-- MCT.lastResourceAmounts: stores the last known power value for
-- each resource type so OnResourceRestore can calculate the delta.
-- Initialized to 0 so the first real value is always an increase.
-- ---------------------------------------------------------------
-- Track resource restoration (magicka, stamina, health recovery)
MCT.lastResourceAmounts = { POWERTYPE_MAGICKA = 0, POWERTYPE_STAMINA = 0, POWERTYPE_HEALTH = 0 }

-- ---------------------------------------------------------------
-- OnResourceRestore: ESO EVENT_POWER_UPDATE handler.
-- Fires every time a unit's power pool value changes. We listen
-- only for the player and only for increases (restores).
-- A minimum threshold of 50 prevents spam from natural 1-point
-- regen ticks and floating-point differences.
--
-- Parameters (from ESO):
--   eventCode : EVENT_POWER_UPDATE constant
--   unitTag   : unit tag string ("player", "group1", etc.)
--   powerType : POWERTYPE_* constant (MAGICKA, STAMINA, HEALTH)
--   powerIndex: power index (reserved / unused here)
-- ---------------------------------------------------------------
function OnResourceRestore(eventCode, unitTag, powerType, powerIndex)
    if not MCT.sv.enabled or not MCT.sv.showResourceRestore then return end
    -- Only track the local player's resource pools.
    if unitTag ~= "player" then return end
    if MCT.sv.pvpOnly and not IsUnitPvPFlagged("player") then return end
    
    -- GetUnitPower returns the current value; maxPower is retrieved but
    -- not used beyond the pattern — kept as documentation of what is available.
    local maxPower = GetUnitPower("player", powerType)
    local currentPower = GetUnitPower("player", powerType)
    local lastAmount = MCT.lastResourceAmounts[powerType] or 0
    
    -- Only show if the current value is higher than it was before this event.
    if currentPower > lastAmount then
        local restoreAmount = currentPower - lastAmount
        local playerId = LibCombat2.GetPlayerUnitId()
        
        -- Apply a minimum threshold to suppress trivial 1-point regen ticks.
        if restoreAmount > 50 then
            MCT:QueueResourceRestore(restoreAmount, powerType, playerId)
        end
    end
    
    -- Record the current power value for comparison on the next event.
    MCT.lastResourceAmounts[powerType] = currentPower
end

-- ---------------------------------------------------------------
-- MCT:ShowResourceRestore: constructs and immediately animates a
-- floating label for a magicka/stamina/health restoration event.
-- Unlike combat hit labels, resource restore labels bypass the
-- merge queue and are shown directly from QueueResourceRestore.
--
-- Parameters:
--   amount    : the numeric restore amount (already above threshold)
--   powerType : POWERTYPE_MAGICKA, POWERTYPE_STAMINA, or POWERTYPE_HEALTH
--   playerId  : the player's unit ID (carried through from the event)
-- ---------------------------------------------------------------
function MCT:ShowResourceRestore(amount, powerType, playerId)
    -- Acquire a recycled label control from the label pool.
    local label, key = MCT.pool:AcquireObject()
    label:SetHidden(false)
    label:SetAlpha(1)

    -- Map the power type to a human-readable display name shown in the label.
    local resourceName = "RESOURCE"   -- Fallback for unknown power types.
    if powerType == POWERTYPE_MAGICKA then
        resourceName = "✦ Magicka"
    elseif powerType == POWERTYPE_STAMINA then
        resourceName = "✦ Stamina"
    elseif powerType == POWERTYPE_HEALTH then
        resourceName = "✦ Health"
    end

    -- Map the power type to a texture code used by MCT.Formatting.EventTextures
    -- to select the icon displayed alongside the label text.
    local textureCode = "resource"    -- Generic fallback icon.
    if powerType == POWERTYPE_MAGICKA then
        textureCode = "magicka"       -- Blue magic icon.
    elseif powerType == POWERTYPE_STAMINA then
        textureCode = "stamina"       -- Green stamina icon.
    end
    -- NOTE: POWERTYPE_HEALTH uses the generic "resource" code (no special icon).

    -- Tag the label so the animation system can look up its icon later.
    label.mctAbilityId = nil          -- Not tied to a specific ability.
    label.mctEventCode = textureCode  -- Used by MCT:Animate for icon selection.

    -- Apply font, anchor, formatted text, and scale before playing the animation.
    label:SetFont(MCT:GetCachedFTNFont(MCT.sv.resourceRestoreFontSize))
    label:SetAnchor(MCT:GetAnchor("resource"))  -- Screen position for resource lane.
    label:SetText(MCT:StylizeDisplayText(
        string.format("|c%s+%s (%s)|r",
            MCT.sv.resourceRestoreColor,
            MCT:FormatShortNumber(amount),
            resourceName
        ),
        "resource"
    ))
    label:SetScale(1.6)  -- Slightly enlarged so resource labels stand out from damage.

    -- Hand the label to the animation system; it will release it back to
    -- the pool when the "resourceRestore" animation sequence completes.
    MCT:Animate(label, "resourceRestore", key)
end

