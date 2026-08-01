-- SortByQuantity by @PacificOshie.  Have fun!

SortByQuantity = {}
SortByQuantity.name = "SortByQuantity"

-- The SortByQuantity header is added to these header controls.
SortByQuantity.controlList = {
    [ZO_PlayerInventorySortBy] = INVENTORY_BACKPACK,
    [ZO_PlayerBankSortBy] = INVENTORY_BANK,
    [ZO_GuildBankSortBy] = INVENTORY_GUILD_BANK,
    [ZO_HouseBankSortBy] = INVENTORY_HOUSE_BANK,
    [ZO_CraftBagSortBy] = INVENTORY_CRAFT_BAG,
    [ZO_SmithingTopLevelRefinementPanelInventorySortBy] = false,
    [ZO_AlchemyTopLevelInventorySortBy] = false,
    [ZO_EnchantingTopLevelInventorySortBy] = false,
}

function SortByQuantity.AddSortByQuantityHeader(zoSortByControl, inventoryType)
    -- Get the "Name" header from the inventory's sort-by control.
    local nameHeader = zoSortByControl:GetNamedChild("Name")

    -- Create the SortByQuantity header next to the "Name" header.
    local quantityHeader = CreateControlFromVirtual("$(parent)Quantity", zoSortByControl, "ZO_SortHeader")
    quantityHeader:SetAnchor(RIGHT, nameHeader, LEFT, -30, 0)
    quantityHeader:SetDimensions(40, 20)

    -- Initialize the SortByQuantity header to compare by stackCount (item quantity).
    ZO_SortHeader_Initialize(quantityHeader, "Qty", "stackCount", ZO_SORT_ORDER_DOWN, TEXT_ALIGN_RIGHT, "ZoFontHeader")

    -- Add the SortByQuantity header to the inventory.
    if inventoryType then
        local inventory = PLAYER_INVENTORY.inventories[inventoryType]
        inventory.sortHeaders:AddHeader(quantityHeader)
    else
        local inventory = zoSortByControl:GetParent().owner
        inventory.sortHeaders:AddHeader(quantityHeader)
    end
end

function SortByQuantity.OnAddOnLoaded(eventCode, addOnName)
    -- Only initialize our own addon.
    if (SortByQuantity.name ~= addOnName) then return end

    EVENT_MANAGER:UnregisterForEvent(SortByQuantity.name, EVENT_ADD_ON_LOADED)

    -- NOTICE, the tiebreaker for name cannot be stackCount if the tiebreaker for stackCount is by name,
    -- because that would cause an infinite loop having the tiebreaker with a circular reference to each other.
    -- THE SIDE EFFECT of changing the tiebreaker for name is that multiple items of the same name,
    -- such as having stacks of 200 of the same item, will no longer sort by the stackCount (item quantity).
    local sortKeys = ZO_Inventory_GetDefaultHeaderSortKeys()
    -- Change the tiebreaker for name to be sorted by slotIndex instead of by stackCount.
    sortKeys["name"]["tiebreaker"] = "slotIndex"
    -- Change the tiebreaker for stackCount to be sorted by name instead of by slotIndex.
    sortKeys["stackCount"]["tiebreaker"] = "name"

    -- Add the SortByQuantity header to each header control.
    for zoSortByControl,inventoryType in pairs(SortByQuantity.controlList) do
        SortByQuantity.AddSortByQuantityHeader(zoSortByControl, inventoryType)
    end
end

EVENT_MANAGER:RegisterForEvent(SortByQuantity.name, EVENT_ADD_ON_LOADED, SortByQuantity.OnAddOnLoaded)