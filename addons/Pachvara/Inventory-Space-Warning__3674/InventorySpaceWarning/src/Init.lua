-- Initializing a global namespace for all addon's data/functions.
InventorySpaceWarning = {}
InventorySpaceWarning.name = "InventorySpaceWarning"
InventorySpaceWarning.logger = LibDebugLogger(InventorySpaceWarning.name)

local function _onAddOnLoaded(_, addonName)
    if addonName == InventorySpaceWarning.name then
        InventorySpaceWarning.Initialize()
        EVENT_MANAGER:UnregisterForEvent(InventorySpaceWarning.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(InventorySpaceWarning.name, EVENT_ADD_ON_LOADED, _onAddOnLoaded)