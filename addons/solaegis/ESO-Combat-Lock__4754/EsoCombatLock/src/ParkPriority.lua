-- EsoCombatLock - park target priority list (settings + migration)

local ECL = EsoCombatLock

--- Fixed tier ids tried by ResolveTargetWithTier in parkPriority order.
ECL.PARK_TIER_SUBSTITUTE = "substitute"
ECL.PARK_TIER_LAST_SAFE = "last_safe"
ECL.PARK_TIER_BLOCKED_MEMENTO = "blocked_memento"
ECL.PARK_TIER_MEMENTO = "memento"
ECL.PARK_TIER_EMPTY = "empty"
ECL.PARK_TIER_UNUSABLE_SAFE = "unusable_safe"
ECL.PARK_TIER_CONSUMABLE_SAFE = "consumable_safe"

--- Cascade-only tiers (excludes substitute / last_safe); used by FindParkTarget.
ECL.PARK_CASCADE_TIERS = {
    ECL.PARK_TIER_BLOCKED_MEMENTO,
    ECL.PARK_TIER_MEMENTO,
    ECL.PARK_TIER_EMPTY,
    ECL.PARK_TIER_UNUSABLE_SAFE,
    ECL.PARK_TIER_CONSUMABLE_SAFE,
}

--- Default order: last-safe first (substitute=None path); substitute last (inert until set).
ECL.DEFAULT_PARK_PRIORITY = {
    ECL.PARK_TIER_LAST_SAFE,
    ECL.PARK_TIER_BLOCKED_MEMENTO,
    ECL.PARK_TIER_MEMENTO,
    ECL.PARK_TIER_EMPTY,
    ECL.PARK_TIER_UNUSABLE_SAFE,
    ECL.PARK_TIER_CONSUMABLE_SAFE,
    ECL.PARK_TIER_SUBSTITUTE,
}

local TIER_LABELS = {
    substitute = "Substitute resource",
    last_safe = "Last safe slot",
    blocked_memento = "Blocked memento",
    memento = "Any memento",
    empty = "Empty slot",
    unusable_safe = "Unusable safe slot",
    consumable_safe = "Consumable safe slot",
}

local TIER_TOOLTIPS = {
    substitute = "Configured combat substitute (skipped when None or unavailable).",
    last_safe = "The non-risky quickslot you had selected before a risky one.",
    blocked_memento = "Slotted memento that will not fire in combat (detectable no-op).",
    memento = "Any slotted memento collectible.",
    empty = "An empty quickslot (no-op; presses are not detectable).",
    unusable_safe = "A safe filled slot that is not currently usable.",
    consumable_safe = "Any safe filled slot (e.g. a potion) — last resort.",
}

local KNOWN_TIERS = {}
for _, id in ipairs(ECL.DEFAULT_PARK_PRIORITY) do
    KNOWN_TIERS[id] = true
end

local CASCADE_SET = {}
for _, id in ipairs(ECL.PARK_CASCADE_TIERS) do
    CASCADE_SET[id] = true
end

local function copyList(list)
    local out = {}
    if type(list) ~= "table" then
        return out
    end
    for i, v in ipairs(list) do
        out[i] = v
    end
    return out
end

function ECL.CopyParkPriorityDefaults()
    return copyList(ECL.DEFAULT_PARK_PRIORITY)
end

function ECL.GetParkTierLabel(tierId)
    return TIER_LABELS[tierId] or tostring(tierId)
end

function ECL.GetParkTierTooltip(tierId)
    return TIER_TOOLTIPS[tierId] or ""
end

--- Build LAM dropdown choices/values/tooltips for all known tiers.
function ECL.BuildParkTierChoices()
    local choices = {}
    local values = {}
    local tooltips = {}
    for _, id in ipairs(ECL.DEFAULT_PARK_PRIORITY) do
        table.insert(choices, TIER_LABELS[id])
        table.insert(values, id)
        table.insert(tooltips, TIER_TOOLTIPS[id])
    end
    return choices, values, tooltips
end

function ECL.IsParkCascadeTier(tierId)
    return CASCADE_SET[tierId] == true
end

function ECL.IsKnownParkTier(tierId)
    return KNOWN_TIERS[tierId] == true
end

--- Deep-copy helper for an existing priority list (or defaults if nil/invalid).
function ECL.CopyParkPriority(list)
    if type(list) ~= "table" or #list == 0 then
        return ECL.CopyParkPriorityDefaults()
    end
    return copyList(list)
end

function ECL.GetParkPriority()
    if ECL.db and type(ECL.db.parkPriority) == "table" and #ECL.db.parkPriority > 0 then
        return ECL.db.parkPriority
    end
    return ECL.DEFAULT_PARK_PRIORITY
end

function ECL.SetParkPriority(list)
    if not ECL.db then
        return
    end
    ECL.db.parkPriority = ECL.CopyParkPriority(list)
    ECL.OnParkSettingsChanged()
end

function ECL.ResetParkPriority()
    if not ECL.db then
        return
    end
    ECL.db.parkPriority = ECL.CopyParkPriorityDefaults()
    ECL.db.parkPriorityMigrated = true
    ECL.OnParkSettingsChanged()
end

--- Ensure db.parkPriority is exactly the 7 known keys, no duplicates.
--- @return boolean repaired True when the list was replaced or rewritten.
function ECL.ValidateAndRepairParkPriority(db)
    db = db or ECL.db
    if not db then
        return false
    end

    local list = db.parkPriority
    if type(list) ~= "table" then
        db.parkPriority = ECL.CopyParkPriorityDefaults()
        return true
    end

    local seen = {}
    local cleaned = {}
    for _, id in ipairs(list) do
        if KNOWN_TIERS[id] and not seen[id] then
            seen[id] = true
            table.insert(cleaned, id)
        end
    end

    local missing = false
    for _, id in ipairs(ECL.DEFAULT_PARK_PRIORITY) do
        if not seen[id] then
            missing = true
            table.insert(cleaned, id)
        end
    end

    local repaired = missing or (#cleaned ~= #ECL.DEFAULT_PARK_PRIORITY) or (#list ~= #cleaned)
    if repaired then
        -- If we had to append missing keys or drop junk, rebuild to a valid permutation.
        -- Prefer cleaned order for known keys; append any still-missing at end.
        if #cleaned ~= #ECL.DEFAULT_PARK_PRIORITY or missing then
            db.parkPriority = cleaned
            -- Re-check: if still incomplete somehow, fall back to defaults.
            if #cleaned ~= #ECL.DEFAULT_PARK_PRIORITY then
                db.parkPriority = ECL.CopyParkPriorityDefaults()
            end
        else
            db.parkPriority = cleaned
        end
        return true
    end

    -- Ensure we own a mutable copy (not the shared defaults table).
    if list == ECL.DEFAULT_PARK_PRIORITY or list == ECL.defaults.parkPriority then
        db.parkPriority = copyList(list)
        return true
    end

    return false
end

local function indexOf(list, tierId)
    for i, id in ipairs(list) do
        if id == tierId then
            return i
        end
    end
    return nil
end

local function swap(list, i, j)
    list[i], list[j] = list[j], list[i]
end

--- Move tierId by delta (-1 = up / earlier, +1 = down / later). Bounds-safe.
--- @return boolean moved
function ECL.MoveParkTier(tierId, delta)
    if not ECL.db or not KNOWN_TIERS[tierId] or not delta or delta == 0 then
        return false
    end
    ECL.ValidateAndRepairParkPriority(ECL.db)
    local list = ECL.db.parkPriority
    local i = indexOf(list, tierId)
    if not i then
        return false
    end
    local j = i + delta
    if j < 1 or j > #list then
        return false
    end
    swap(list, i, j)
    ECL.OnParkSettingsChanged()
    return true
end

--- Move substitute to index 1 when not already first.
--- @return boolean moved
function ECL.PromoteSubstituteToFront()
    if not ECL.db then
        return false
    end
    ECL.ValidateAndRepairParkPriority(ECL.db)
    local list = ECL.db.parkPriority
    local i = indexOf(list, ECL.PARK_TIER_SUBSTITUTE)
    if not i or i == 1 then
        return false
    end
    table.remove(list, i)
    table.insert(list, 1, ECL.PARK_TIER_SUBSTITUTE)
    -- Caller (SetSubstitute) invokes OnParkSettingsChanged; migration does not need HUD refresh.
    return true
end

--- Build initial parkPriority from legacy preferDetectableNoOp + substitute.
--- ZO_SavedVars may already have filled parkPriority from defaults, so we use
--- parkPriorityMigrated as the one-time gate (not "key missing").
--- @return boolean migrated
function ECL.MigrateParkPriorityFromLegacy(db)
    db = db or ECL.db
    if not db then
        return false
    end
    if db.parkPriorityMigrated then
        return false
    end

    -- preferDetectableNoOp=false used empty before blocked_memento/memento.
    local list
    if db.preferDetectableNoOp == false then
        list = {
            ECL.PARK_TIER_LAST_SAFE,
            ECL.PARK_TIER_EMPTY,
            ECL.PARK_TIER_BLOCKED_MEMENTO,
            ECL.PARK_TIER_MEMENTO,
            ECL.PARK_TIER_UNUSABLE_SAFE,
            ECL.PARK_TIER_CONSUMABLE_SAFE,
            ECL.PARK_TIER_SUBSTITUTE,
        }
    else
        list = ECL.CopyParkPriorityDefaults()
    end

    local sub = db.substitute
    if sub and sub.actionType and sub.actionId then
        local i = indexOf(list, ECL.PARK_TIER_SUBSTITUTE)
        if i and i ~= 1 then
            table.remove(list, i)
            table.insert(list, 1, ECL.PARK_TIER_SUBSTITUTE)
        end
    end

    db.parkPriority = list
    db.parkPriorityMigrated = true
    return true
end

--- Numbered multiline string for LAM description and /ecl.
function ECL.FormatParkPriorityList()
    local list = ECL.GetParkPriority()
    local lines = {}
    for i, id in ipairs(list) do
        table.insert(lines, string.format("%d. %s", i, ECL.GetParkTierLabel(id)))
    end
    return table.concat(lines, "\n")
end
