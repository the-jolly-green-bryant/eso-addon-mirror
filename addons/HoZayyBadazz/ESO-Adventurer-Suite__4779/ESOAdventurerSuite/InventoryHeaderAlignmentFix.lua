-- ESO Adventurer Suite
-- v0.29.510 - align lower inventory filter row and search box.
-- Moves the lower filter row and search box without changing ESO's native
-- filter/list dependency chain.

local EPC = ESOProgressionCoach
if not EPC then return end

EPC.InventoryHeaderAlignmentFix = EPC.InventoryHeaderAlignmentFix or {}
local F = EPC.InventoryHeaderAlignmentFix

local UPDATE_NAME = (EPC.name or "ESOAdventurerSuite") .. "_InventoryHeaderAlignment029510"

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return nil end
    return a, b, c, d
end

function F:IsInventoryOpen()
    if SCENE_MANAGER and type(SCENE_MANAGER.IsShowing) == "function" then
        local ok, showing = pcall(SCENE_MANAGER.IsShowing, SCENE_MANAGER, "inventory")
        if ok and showing == true then return true end
    end
    local inv = rawget(_G, "ZO_PlayerInventory")
    return inv and inv.IsHidden and not inv:IsHidden() or false
end

function F:GetControls()
    local inv = rawget(_G, "ZO_PlayerInventory")
    if not inv then return end
    local tabs = rawget(_G, "ZO_PlayerInventoryTabs") or (inv.GetNamedChild and inv:GetNamedChild("Tabs")) or nil
    local searchFilters = inv.GetNamedChild and inv:GetNamedChild("SearchFilters") or nil
    local textSearch = searchFilters and searchFilters.GetNamedChild and searchFilters:GetNamedChild("TextSearch") or rawget(_G, "ZO_PlayerInventorySearchFiltersTextSearch")
    return inv, tabs, searchFilters, textSearch
end

function F:AlignTopTabs(inv, tabs)
    if not inv or not tabs or not tabs.ClearAnchors or not tabs.SetAnchor then return end

    -- Keep the lower inventory filter row aligned beneath the Suite item icons.
    safeCall(tabs.ClearAnchors, tabs)
    safeCall(tabs.SetAnchor, tabs, TOPRIGHT, inv, TOPRIGHT, -73, 14)

    if type(ZO_MenuBar_UpdateButtons) == "function" then
        safeCall(ZO_MenuBar_UpdateButtons, tabs)
    end
end

function F:AlignSearchBox(searchFilters, textSearch)
    if not searchFilters or not textSearch or not textSearch.ClearAnchors or not textSearch.SetAnchor then return end

    -- Move only the search box farther right. The filter container, sub-tabs,
    -- sort headers and list keep ESO's native anchors to avoid anchor cycles.
    safeCall(textSearch.ClearAnchors, textSearch)
    safeCall(textSearch.SetAnchor, textSearch, TOPRIGHT, searchFilters, TOPRIGHT, 64, 0)
end

function F:RefreshRepairButtonAlignment()
    local repairTab = EPC.InventoryRepairTab
    if repairTab and type(repairTab.AnchorButton) == "function" then
        safeCall(repairTab.AnchorButton, repairTab)
    end
end

function F:Apply()
    local inv, tabs, searchFilters, textSearch = self:GetControls()
    if not inv or not tabs then return end

    self:AlignTopTabs(inv, tabs)
    self:AlignSearchBox(searchFilters, textSearch)
    self:RefreshRepairButtonAlignment()
end

local function Tick()
    if F:IsInventoryOpen() then F:Apply() end
end

EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 250, Tick)

if type(zo_callLater) == "function" then
    zo_callLater(function() F:Apply() end, 300)
    zo_callLater(function() F:Apply() end, 1000)
else
    F:Apply()
end
