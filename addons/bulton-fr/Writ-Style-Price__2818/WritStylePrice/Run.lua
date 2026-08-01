EVENT_MANAGER:RegisterForEvent("WritStylePriceInit", EVENT_ADD_ON_LOADED, WritStylePrice.Events.onLoaded)
EVENT_MANAGER:RegisterForEvent("WritStylePriceLoadMap", EVENT_PLAYER_ACTIVATED, WritStylePrice.Events.onLoadScreen)

-- When player open its personal bank
EVENT_MANAGER:RegisterForEvent("WritStylePriceOpenBank", EVENT_OPEN_BANK, WritStylePrice.Events.onOpenBank)

-- when item comes into inventory
EVENT_MANAGER:RegisterForEvent("WritStylePriceMoveItem", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, WritStylePrice.Events.onMoveItem)
EVENT_MANAGER:AddFilterForEvent("WritStylePriceMoveItem", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

-- Define slash commands to show/hide the gui
if SLASH_COMMANDS["/wsp"] == nil then
    SLASH_COMMANDS["/wsp"] = WritStylePrice.Events.toggleGUI
end

SLASH_COMMANDS["/writstyleprice"] = WritStylePrice.Events.toggleGUI
