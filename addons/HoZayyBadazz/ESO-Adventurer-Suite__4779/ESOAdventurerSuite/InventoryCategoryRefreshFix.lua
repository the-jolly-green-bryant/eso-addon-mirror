-- ESO Adventurer Suite
-- v0.29.654 - keep Suite inventory categories synchronized with ESO's hidden lists.
-- The Suite mirrors ESO's native filtered inventory data. When a top-level
-- category changes while the native list is hidden, force one immediate native
-- list rebuild and one Suite refresh so categories such as Materials/Jewelry do
-- not appear empty until another unrelated UI update occurs.

local EPC = ESOProgressionCoach
if not EPC or not EVENT_MANAGER then return end

local EM = EVENT_MANAGER
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_InventoryCategoryRefresh029654"
local UPDATE = NAME .. "_Deferred"

local function scheduleGridRefresh()
    EM:UnregisterForUpdate(UPDATE)
    EM:RegisterForUpdate(UPDATE, 1, function()
        EM:UnregisterForUpdate(UPDATE)
        local grid = EPC.InventoryGrid or rawget(_G, "EASInventoryGrid")
        if type(grid) ~= "table" then return end
        if grid.visible ~= true then return end
        if type(grid.UpdateNativeList) == "function" then pcall(grid.UpdateNativeList, grid, true) end
        if type(grid.Refresh) == "function" then pcall(grid.Refresh, grid, false) end
    end)
end

local manager = rawget(_G, "PLAYER_INVENTORY")
if type(manager) == "table" and type(manager.ChangeFilter) == "function" and not manager._easInventoryCategoryRefresh029654 then
    manager._easInventoryCategoryRefresh029654 = true
    local baseChangeFilter = manager.ChangeFilter
    manager.ChangeFilter = function(self, filterTab, ...)
        local results = { baseChangeFilter(self, filterTab, ...) }
        scheduleGridRefresh()
        return unpack(results)
    end
end

-- Rebuild on ESO inventory filter changes that do not pass through ChangeFilter
-- on some API revisions/subfilter paths.
for _, eventName in ipairs({
    "EVENT_INVENTORY_FULL_UPDATE",
    "EVENT_INVENTORY_SINGLE_SLOT_UPDATE",
}) do
    local eventCode = rawget(_G, eventName)
    if eventCode ~= nil then EM:RegisterForEvent(NAME .. "_" .. eventName, eventCode, scheduleGridRefresh) end
end

EPC.inventoryCategoryRefresh029654 = true
