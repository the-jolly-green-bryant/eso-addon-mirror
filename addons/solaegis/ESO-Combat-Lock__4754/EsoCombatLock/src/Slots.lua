-- EsoCombatLock - quickslot classification and target resolution

local ECL = EsoCombatLock
ECL.Slots = ECL.Slots or {}
local Slots = ECL.Slots

local HOTBAR = HOTBAR_CATEGORY_QUICKSLOT_WHEEL

------------------------------------------------------------
-- Index helpers
------------------------------------------------------------

function Slots.GetWheelSize()
    return ACTION_BAR_UTILITY_BAR_SIZE or 8
end

function Slots.GetCurrent()
    return GetCurrentQuickslot()
end

function Slots.SetCurrent(slotIndex)
    if slotIndex == nil then
        return false
    end
    SetCurrentQuickslot(slotIndex)
    return true
end

function Slots.ForEachSlot(callback)
    local size = Slots.GetWheelSize()
    for i = 1, size do
        callback(i)
    end
end

------------------------------------------------------------
-- Slot inspection
------------------------------------------------------------

function Slots.GetType(slotIndex)
    return GetSlotType(slotIndex, HOTBAR)
end

function Slots.GetBoundId(slotIndex)
    return GetSlotBoundId(slotIndex, HOTBAR)
end

function Slots.GetName(slotIndex)
    local name = GetSlotName(slotIndex, HOTBAR)
    if name and name ~= "" then
        return name
    end
    return nil
end

function Slots.IsEmpty(slotIndex)
    local slotType = Slots.GetType(slotIndex)
    return slotType == nil or slotType == ACTION_TYPE_NOTHING
end

function Slots.IsUsable(slotIndex)
    if Slots.IsEmpty(slotIndex) then
        return false
    end
    local count = GetSlotItemCount(slotIndex, HOTBAR)
    -- Collectibles / emotes return nil count; items return a stack.
    if count ~= nil and count <= 0 then
        return false
    end
    if IsSlotUsable and not IsSlotUsable(slotIndex, HOTBAR) then
        return false
    end
    return true
end

function Slots.IsRiskyCategory(categoryType)
    if categoryType == COLLECTIBLE_CATEGORY_TYPE_COMPANION then
        return true
    end
    if categoryType == COLLECTIBLE_CATEGORY_TYPE_ASSISTANT then
        return true
    end
    if ECL.IncludeVanityPets() and categoryType == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET then
        return true
    end
    return false
end

function Slots.IsRisky(slotIndex)
    if Slots.IsEmpty(slotIndex) then
        return false
    end
    local slotType = Slots.GetType(slotIndex)
    if slotType ~= ACTION_TYPE_COLLECTIBLE then
        return false
    end
    local collectibleId = Slots.GetBoundId(slotIndex)
    if not collectibleId or collectibleId == 0 then
        return false
    end
    local categoryType = GetCollectibleCategoryType(collectibleId)
    return Slots.IsRiskyCategory(categoryType)
end

function Slots.IsSafe(slotIndex)
    return not Slots.IsRisky(slotIndex)
end

--- A slotted memento that will not actually activate (blocked in combat).
--- Pressing the quickslot key still fires EVENT_COLLECTIBLE_USE_RESULT.
function Slots.IsNoOpCollectible(slotIndex)
    if not Slots.IsMementoSlot(slotIndex) then
        return false
    end
    local collectibleId = Slots.GetBoundId(slotIndex)
    -- If the collectible would actually fire, it is not a no-op park.
    if IsCollectibleUsable and IsCollectibleUsable(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
        return false
    end
    return true
end

--- Presses are inferred from cooldown / collectible-use events, never from the
--- raw key, so a slot that produces no observable signal cannot be announced.
--- @return boolean detectable, string|nil reason when not detectable
function Slots.IsPressDetectable(slotIndex)
    if Slots.IsNoOpCollectible(slotIndex) then
        return true, nil
    end
    if Slots.IsEmpty(slotIndex) then
        return false, "parked on an empty no-op slot — pressing the key fires no event"
    end
    if not Slots.IsUsable(slotIndex) then
        return false, "slot is not usable (out of stock or blocked)"
    end
    return true, nil
end

------------------------------------------------------------
-- Resource key / resolution
------------------------------------------------------------

function Slots.MakeKey(actionType, actionId)
    return tostring(actionType) .. ":" .. tostring(actionId)
end

function Slots.ParseKey(key)
    if not key or key == ECL.NONE_KEY then
        return nil, nil
    end
    local actionType, actionId = key:match("^(%d+):(%d+)$")
    if not actionType then
        return nil, nil
    end
    return tonumber(actionType), tonumber(actionId)
end

function Slots.FindSlotForResource(actionType, actionId)
    if actionType == nil or actionId == nil then
        return nil
    end
    local found = FindActionSlotMatchingSimpleAction(actionType, actionId, HOTBAR)
    if found and found > 0 then
        return found
    end
    -- Fallback linear scan in case the finder misses wheel slots.
    local match = nil
    Slots.ForEachSlot(function(i)
        if match then
            return
        end
        if Slots.GetType(i) == actionType and Slots.GetBoundId(i) == actionId then
            match = i
        end
    end)
    return match
end

function Slots.FindEmptySlot()
    local empty = nil
    Slots.ForEachSlot(function(i)
        if empty then
            return
        end
        if Slots.IsEmpty(i) then
            empty = i
        end
    end)
    return empty
end

function Slots.IsMementoSlot(slotIndex)
    if Slots.IsEmpty(slotIndex) or Slots.IsRisky(slotIndex) then
        return false
    end
    if Slots.GetType(slotIndex) ~= ACTION_TYPE_COLLECTIBLE then
        return false
    end
    local collectibleId = Slots.GetBoundId(slotIndex)
    if not collectibleId or collectibleId == 0 then
        return false
    end
    return GetCollectibleCategoryType(collectibleId) == COLLECTIBLE_CATEGORY_TYPE_MEMENTO
end

function Slots.FindMementoSlot()
    local found = nil
    Slots.ForEachSlot(function(i)
        if found then
            return
        end
        if Slots.IsMementoSlot(i) then
            found = i
        end
    end)
    return found
end

function Slots.FindNoOpCollectibleSlot()
    local found = nil
    Slots.ForEachSlot(function(i)
        if found then
            return
        end
        if Slots.IsNoOpCollectible(i) then
            found = i
        end
    end)
    return found
end

function Slots.FindAnyMementoSlot()
    local found = nil
    Slots.ForEachSlot(function(i)
        if found then
            return
        end
        if Slots.IsMementoSlot(i) then
            found = i
        end
    end)
    return found
end

--- Non-risky slot that is filled but not currently usable (out of stock / blocked).
function Slots.FindUnusableSafeSlot()
    local found = nil
    Slots.ForEachSlot(function(i)
        if found then
            return
        end
        if not Slots.IsEmpty(i) and Slots.IsSafe(i) and not Slots.IsUsable(i) then
            found = i
        end
    end)
    return found
end

--- Any non-risky filled slot (last resort before all slots are risky).
function Slots.FindAnySafeFilledSlot()
    local found = nil
    Slots.ForEachSlot(function(i)
        if found then
            return
        end
        if not Slots.IsEmpty(i) and Slots.IsSafe(i) then
            found = i
        end
    end)
    return found
end

--- True when a slotted risky collectible (companion / assistant / vanity pet) is active.
function Slots.HasActiveRiskyCollectible()
    local active = nil
    Slots.ForEachSlot(function(i)
        if active then
            return
        end
        if not Slots.IsRisky(i) then
            return
        end
        local collectibleId = Slots.GetBoundId(i)
        if collectibleId and collectibleId > 0 and IsCollectibleActive then
            if IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
                active = collectibleId
            end
        end
    end)
    return active ~= nil, active
end

--- Ordered park cascade; only returns nil when every slot is risky.
--- @return number|nil slotIndex, string tier
function Slots.FindParkTarget()
    local preferMemento = ECL.PreferDetectableNoOp and ECL.PreferDetectableNoOp()

    local function tryMementos()
        local blocked = Slots.FindNoOpCollectibleSlot()
        if blocked then
            return blocked, "blocked_memento"
        end
        local memento = Slots.FindAnyMementoSlot()
        if memento then
            return memento, "memento"
        end
        return nil, nil
    end

    if preferMemento then
        local slot, tier = tryMementos()
        if slot then
            return slot, tier
        end
    end

    if ECL.db and ECL.db.emptySlotsSelectable ~= false then
        local empty = Slots.FindEmptySlot()
        if empty then
            return empty, "empty"
        end
    end

    if not preferMemento then
        local slot, tier = tryMementos()
        if slot then
            return slot, tier
        end
    end

    local unusable = Slots.FindUnusableSafeSlot()
    if unusable then
        return unusable, "unusable_safe"
    end

    local filled = Slots.FindAnySafeFilledSlot()
    if filled then
        return filled, "consumable_safe"
    end

    return nil, "none"
end

--- Build dropdown choices from currently slotted non-risky resources.
--- @return choices table, values table, tooltips table
function Slots.BuildSubstituteChoices()
    local choices = { "(None — revert to last safe slot)" }
    local values = { ECL.NONE_KEY }
    local tooltips = {
        "Default. Risky slots are still blocked; selection returns to your last safe quickslot.",
    }

    local seen = {}
    Slots.ForEachSlot(function(i)
        if Slots.IsEmpty(i) or Slots.IsRisky(i) then
            return
        end
        local actionType = Slots.GetType(i)
        local actionId = Slots.GetBoundId(i)
        if not actionType or not actionId or actionId == 0 then
            return
        end
        local key = Slots.MakeKey(actionType, actionId)
        if seen[key] then
            return
        end
        seen[key] = true

        local name = Slots.GetName(i) or ("Slot " .. tostring(i))
        local count = GetSlotItemCount(i, HOTBAR)
        local label = name
        if count ~= nil then
            label = string.format("%s  (x%d)", name, count)
        end
        table.insert(choices, label)
        table.insert(values, key)
        table.insert(tooltips, string.format("Wheel slot %d — actionType %s id %s", i, tostring(actionType), tostring(actionId)))
    end)

    return choices, values, tooltips
end

------------------------------------------------------------
-- Target resolution (see plan)
------------------------------------------------------------

--- Resolve the slot the guard should force when a risky selection is blocked.
--- @param lastSafeSlot number|nil
--- @return number|nil slotIndex
function Slots.ResolveTarget(lastSafeSlot)
    local slot = select(1, Slots.ResolveTargetWithTier(lastSafeSlot))
    return slot
end

--- Like ResolveTarget but also returns which park cascade tier supplied the slot.
--- @param lastSafeSlot number|nil
--- @return number|nil slotIndex, string tier
function Slots.ResolveTargetWithTier(lastSafeSlot)
    local sub = ECL.GetSubstitute()
    if sub then
        local slot = Slots.FindSlotForResource(sub.actionType, sub.actionId)
        if slot and Slots.IsUsable(slot) and not Slots.IsRisky(slot) then
            return slot, "substitute"
        end
        local park, tier = Slots.FindParkTarget()
        if park then
            return park, tier
        end
        if lastSafeSlot and Slots.IsSafe(lastSafeSlot) then
            return lastSafeSlot, "last_safe"
        end
        return nil, "none"
    end

    if lastSafeSlot and Slots.IsSafe(lastSafeSlot) then
        return lastSafeSlot, "last_safe"
    end

    return Slots.FindParkTarget()
end

------------------------------------------------------------
-- Companion helpers
------------------------------------------------------------

function Slots.GetActiveCompanionCollectibleId()
    if not HasActiveCompanion or not HasActiveCompanion() then
        return nil
    end
    local defId = GetActiveCompanionDefId and GetActiveCompanionDefId()
    if not defId or defId == 0 then
        return nil
    end
    local collectibleId = GetCompanionCollectibleId and GetCompanionCollectibleId(defId)
    if not collectibleId or collectibleId == 0 then
        return nil
    end
    return collectibleId, defId
end

function Slots.DescribeSlot(slotIndex)
    if slotIndex == nil then
        return "nil"
    end
    local slotType = Slots.GetType(slotIndex)
    local boundId = Slots.GetBoundId(slotIndex)
    local name = Slots.GetName(slotIndex) or "(unnamed)"
    local risky = Slots.IsRisky(slotIndex) and "RISKY" or "safe"
    local empty = Slots.IsEmpty(slotIndex) and "empty" or "filled"
    return string.format(
        "#%s type=%s id=%s name=%q [%s/%s]",
        tostring(slotIndex),
        tostring(slotType),
        tostring(boundId),
        name,
        empty,
        risky
    )
end
