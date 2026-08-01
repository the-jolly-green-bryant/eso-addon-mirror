-- SatchelExchangeBagUtils.lua: Pure helpers for backpack and item-use
-- readiness inspection.

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

---Whether the player is back on the plain HUD. The game silently drops
---UseItem requests sent while any other scene (store, loot, a menu) is still
---up or fading out -- the reference autoloot addon gates on exactly this.
---@return boolean
function SatchelExchangeBagUtils.IsHudSceneShowing()
    local scene = SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene()
    local sceneName = scene and scene:GetName()
    return sceneName == "hud" or sceneName == "hudui"
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
        hudScene = SatchelExchangeBagUtils.IsHudSceneShowing(),
        interactionType = GetInteractionType(),
    }
end

---@param readiness SatchelExchangeUseReadiness
---@return boolean
function SatchelExchangeBagUtils.IsReadyToUse(readiness)
    return readiness.usable
        and not readiness.usableOnlyFromActionSlot
        and readiness.canInteract
        and readiness.cooldownRemainMs == 0
        and readiness.hudScene
        and readiness.interactionType == INTERACTION_NONE
end

---@param readiness SatchelExchangeUseReadiness
---@return string
function SatchelExchangeBagUtils.FormatUseReadiness(readiness)
    return string.format("usable=%s onlyFromActionSlot=%s canInteract=%s cooldownMs=%d hudScene=%s interaction=%d",
        tostring(readiness.usable),
        tostring(readiness.usableOnlyFromActionSlot),
        tostring(readiness.canInteract),
        readiness.cooldownRemainMs,
        tostring(readiness.hudScene),
        readiness.interactionType)
end

SatchelExchange.BagUtils = SatchelExchangeBagUtils
