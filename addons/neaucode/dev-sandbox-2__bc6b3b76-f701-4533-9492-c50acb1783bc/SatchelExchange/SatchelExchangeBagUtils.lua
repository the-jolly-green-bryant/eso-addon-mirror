-- SatchelExchangeBagUtils.lua: Pure helpers for backpack inspection.

local SatchelExchangeBagUtils = {}

---Find the first backpack slot holding the given item id
---@param itemId integer
---@return integer|nil slotIndex
function SatchelExchangeBagUtils.FindItemInBackpack(itemId)
    for slotIndex in ZO_IterateBagSlots(BAG_BACKPACK) do
        if GetItemId(BAG_BACKPACK, slotIndex) == itemId then
            return slotIndex
        end
    end
    return nil
end

---Snapshot everything that gates using (unboxing) a backpack item right now
---@param slotIndex integer
---@return SatchelExchangeUseReadiness
function SatchelExchangeBagUtils.GetUseReadiness(slotIndex)
    local usable, usableOnlyFromActionSlot = IsItemUsable(BAG_BACKPACK, slotIndex)
    local cooldownRemainMs = GetItemCooldownInfo(BAG_BACKPACK, slotIndex)
    return {
        usable = usable,
        usableOnlyFromActionSlot = usableOnlyFromActionSlot,
        canInteract = CanInteractWithItem(BAG_BACKPACK, slotIndex),
        cooldownRemainMs = cooldownRemainMs,
    }
end

---@param readiness SatchelExchangeUseReadiness
---@return boolean
function SatchelExchangeBagUtils.IsReadyToUse(readiness)
    return readiness.usable
        and not readiness.usableOnlyFromActionSlot
        and readiness.canInteract
        and readiness.cooldownRemainMs == 0
end

---@param readiness SatchelExchangeUseReadiness
---@return string
function SatchelExchangeBagUtils.FormatUseReadiness(readiness)
    return string.format("usable=%s onlyFromActionSlot=%s canInteract=%s cooldownMs=%d",
        tostring(readiness.usable),
        tostring(readiness.usableOnlyFromActionSlot),
        tostring(readiness.canInteract),
        readiness.cooldownRemainMs)
end

SatchelExchange.BagUtils = SatchelExchangeBagUtils
