function onLootUpdated(eventCode)
    if IsLooting() then
        local _, targetType = GetLootTargetInfo()
        if targetType == INTERACT_TARGET_TYPE_OBJECT or targetType == INTERACT_TARGET_TYPE_NONE then
            for i = 1, GetNumLootItems() do
                local lootId, _, _, _, _, _, _, stolen = GetLootItemInfo(i)
                if not stolen and CanItemLinkBeVirtual(GetLootItemLink(lootId, LINK_STYLE_DEFAULT)) then
                    LootItemById(lootId)
                end
            end
        end
    end
end

EVENT_MANAGER:RegisterForEvent("AutoLootCraftingMaterialsOnLootUpdated", EVENT_LOOT_UPDATED, onLootUpdated)
