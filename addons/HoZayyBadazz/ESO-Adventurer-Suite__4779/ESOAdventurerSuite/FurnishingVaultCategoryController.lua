-- ESO Adventurer Suite
-- v0.29.591 - authoritative Furnishing Vault native-row category controller.
-- ESO uses FURNITURE_VAULT_FRAGMENT for Withdraw and INVENTORY_FRAGMENT for
-- Deposit. BACKPACK_FURNITURE_VAULT_LAYOUT_FRAGMENT is shared by BOTH modes,
-- so it is the authoritative lifetime boundary for this interaction.

local EPC = ESOProgressionCoach
if not EPC then return end

local manager = rawget(_G, "PLAYER_INVENTORY")
local wm = rawget(_G, "WINDOW_MANAGER")
if type(manager) ~= "table" or not wm then return end

local HEADER_TYPE = 989591
local registered = setmetatable({}, { __mode = "k" })
local baseEntries = setmetatable({}, { __mode = "k" })
local collapsed = setmetatable({}, { __mode = "k" })
local generation = 0
local applying = false

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a, b, c
end

local function fragmentShowing(fragment)
    if not fragment then return false end
    if type(fragment.IsShowing) == "function" then
        local ok, shown = pcall(fragment.IsShowing, fragment)
        if ok and shown == true then return true end
    end
    if type(fragment.GetState) == "function" then
        local ok, state = pcall(fragment.GetState, fragment)
        if ok then
            return state == rawget(_G, "SCENE_FRAGMENT_SHOWING")
                or state == rawget(_G, "SCENE_FRAGMENT_SHOWN")
        end
    end
    return false
end

local function vaultContextActive()
    -- This layout fragment is present for BOTH Withdraw and Deposit in ESO.
    if fragmentShowing(rawget(_G, "BACKPACK_FURNITURE_VAULT_LAYOUT_FRAGMENT")) then return true end

    -- Context is a second native truth source and remains furnitureVaultTextSearch
    -- while Deposit is displaying INVENTORY_BACKPACK.
    if type(manager.inventories) == "table" then
        for _, inventoryType in ipairs({ rawget(_G, "INVENTORY_BACKPACK"), rawget(_G, "INVENTORY_FURNITURE_VAULT") }) do
            local inv = inventoryType ~= nil and manager.inventories[inventoryType] or nil
            if type(inv) == "table" and tostring(inv.currentContext or "") == "furnitureVaultTextSearch" then
                return true
            end
        end
    end

    if rawget(_G, "SCENE_MANAGER") and type(SCENE_MANAGER.IsShowing) == "function" then
        local ok, shown = pcall(SCENE_MANAGER.IsShowing, SCENE_MANAGER, "furnitureVault")
        if ok and shown == true then return true end
    end
    return false
end

local function listFor(inventoryType)
    local data = type(manager.inventories) == "table" and inventoryType ~= nil and manager.inventories[inventoryType] or nil
    if type(data) == "table" then return data.listView or data.list or data.scrollList end
    if inventoryType == rawget(_G, "INVENTORY_FURNITURE_VAULT") then return rawget(_G, "ZO_FurnitureVaultList") end
    if inventoryType == rawget(_G, "INVENTORY_BACKPACK") then return rawget(_G, "ZO_PlayerInventoryList") end
end

local function currentInventoryType()
    if fragmentShowing(rawget(_G, "FURNITURE_VAULT_FRAGMENT")) then
        return rawget(_G, "INVENTORY_FURNITURE_VAULT")
    end
    if vaultContextActive() and fragmentShowing(rawget(_G, "INVENTORY_FRAGMENT")) then
        return rawget(_G, "INVENTORY_BACKPACK")
    end

    local selected = tonumber(manager.selectedTabType)
    local backpack = tonumber(rawget(_G, "INVENTORY_BACKPACK"))
    local vault = tonumber(rawget(_G, "INVENTORY_FURNITURE_VAULT"))
    if selected ~= nil and selected == backpack then return rawget(_G, "INVENTORY_BACKPACK") end
    if selected ~= nil and selected == vault then return rawget(_G, "INVENTORY_FURNITURE_VAULT") end
    return nil
end

local function isHeader(entry)
    local data = type(entry) == "table" and (entry.data or entry) or nil
    return type(data) == "table" and (
        data.easSuiteFurnitureVaultHeader029591 == true
        or data.easSuiteFurnitureVaultHeader029588 == true
        or data.easSuiteCategoryHeader029364 == true
        or data.easSuiteCategoryHeader029376 == true
    )
end

local function entryLink(entry)
    local grid = rawget(_G, "EASInventoryGrid")
    if grid and type(grid.GetNativeEntryLink029364) == "function" then
        local ok, link = pcall(grid.GetNativeEntryLink029364, grid, entry)
        if ok and tostring(link or "") ~= "" then return tostring(link) end
    end

    local data = type(entry) == "table" and (entry.data or entry) or nil
    if type(data) ~= "table" then return "" end
    local direct = data.itemLink or data.link or data.itemLinkString
    if tostring(direct or "") ~= "" then return tostring(direct) end
    local bag = tonumber(data.bagId or data.bag)
    local slot = tonumber(data.slotIndex or data.slot)
    if bag ~= nil and slot ~= nil and type(rawget(_G, "GetItemLink")) == "function" then
        return tostring(safe(GetItemLink, "", bag, slot, rawget(_G, "LINK_STYLE_DEFAULT") or 0) or "")
    end
    return ""
end

local function categoryForLink(link)
    link = tostring(link or "")
    if link == "" then return "Other" end

    local furnitureDataId = tonumber(safe(rawget(_G, "GetItemLinkFurnitureDataId"), 0, link)) or 0
    if furnitureDataId > 0 and type(rawget(_G, "GetFurnitureDataCategoryInfo")) == "function" then
        local ok, categoryId, subcategoryId = pcall(GetFurnitureDataCategoryInfo, furnitureDataId)
        if ok and type(rawget(_G, "GetFurnitureCategoryName")) == "function" then
            local category = categoryId ~= nil and tostring(safe(GetFurnitureCategoryName, "", categoryId) or "") or ""
            if category ~= "" then return category end
            local subcategory = subcategoryId ~= nil and tostring(safe(GetFurnitureCategoryName, "", subcategoryId) or "") or ""
            if subcategory ~= "" then return subcategory end
        end
    end

    -- Deposit uses ESO's backpack list. If a native filter produces a non-furniture
    -- row, retain useful Suite organization rather than putting everything in Other.
    local grid = rawget(_G, "EASInventoryGrid")
    if grid and type(grid.GetExternalGroupName029364) == "function" then
        local ok, group = pcall(grid.GetExternalGroupName029364, grid, link)
        if ok and tostring(group or "") ~= "" then return tostring(group) end
    end
    return "Other"
end

local applyCategories

local function registerHeader(list)
    if not list then return false end
    if registered[list] then return true end
    if type(rawget(_G, "ZO_ScrollList_AddDataType")) ~= "function" then return false end

    local ok = pcall(ZO_ScrollList_AddDataType, list, HEADER_TYPE, "ZO_SelectableLabel", 30, function(control, data)
        if not control then return end
        local closed = data and data.collapsed == true
        local text = tostring(data and data.text or "Other")
        local count = tonumber(data and data.count) or 0
        if type(control.SetText) == "function" then
            control:SetText((closed and "+  " or "-  ") .. text .. "  (" .. tostring(count) .. ")")
        end
        if type(control.SetFont) == "function" then control:SetFont("ZoFontWinH4") end
        if type(control.SetColor) == "function" then control:SetColor(0.90, 0.94, 0.98, 1) end
        if type(control.SetMaxLineCount) == "function" then control:SetMaxLineCount(1) end
        if type(control.SetMouseEnabled) == "function" then control:SetMouseEnabled(true) end

        if not control.easFurnitureVaultCategoryBG029591 then
            local bg = wm:CreateControl(nil, control, CT_BACKDROP)
            bg:SetAnchorFill(control)
            bg:SetCenterColor(0.035, 0.055, 0.075, 0.98)
            bg:SetEdgeColor(0.28, 0.48, 0.62, 0.95)
            bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 1)
            bg:SetMouseEnabled(false)
            control.easFurnitureVaultCategoryBG029591 = bg
        end

        control:SetHandler("OnMouseEnter", function(c)
            if c.easFurnitureVaultCategoryBG029591 then c.easFurnitureVaultCategoryBG029591:SetCenterColor(0.07, 0.10, 0.14, 1) end
        end)
        control:SetHandler("OnMouseExit", function(c)
            if c.easFurnitureVaultCategoryBG029591 then c.easFurnitureVaultCategoryBG029591:SetCenterColor(0.035, 0.055, 0.075, 0.98) end
        end)
        control:SetHandler("OnMouseUp", function(_, button, inside)
            if inside == false then return end
            local left = rawget(_G, "MOUSE_BUTTON_INDEX_LEFT")
            if left ~= nil and button ~= left then return end
            local target, group = data and data.list, data and data.group
            if not target or not group then return end
            local state = collapsed[target]
            if not state then state = {}; collapsed[target] = state end
            state[group] = not (state[group] == true)
            applyCategories(target, true)
        end)
    end)
    if ok then registered[list] = true end
    return ok
end

local function replaceData(list, entries)
    if not list or type(rawget(_G, "ZO_ScrollList_GetDataList")) ~= "function" then return false end
    local ok, dataList = pcall(ZO_ScrollList_GetDataList, list)
    if not ok or type(dataList) ~= "table" then return false end
    for i = #dataList, 1, -1 do dataList[i] = nil end
    for i, entry in ipairs(entries or {}) do dataList[i] = entry end
    if type(rawget(_G, "ZO_ScrollList_Commit")) == "function" then pcall(ZO_ScrollList_Commit, list) end
    return true
end

local function stripHeaders(list, clearCache)
    if not list or type(rawget(_G, "ZO_ScrollList_GetDataList")) ~= "function" then return end
    local ok, dataList = pcall(ZO_ScrollList_GetDataList, list)
    if not ok or type(dataList) ~= "table" then return end
    local clean, changed = {}, false
    for _, entry in ipairs(dataList) do
        if isHeader(entry) then changed = true else clean[#clean + 1] = entry end
    end
    if changed then replaceData(list, clean) end
    if clearCache then
        baseEntries[list] = nil
        collapsed[list] = nil
    end
end

applyCategories = function(list, useCachedBase)
    if applying or not vaultContextActive() or not list then return false end
    local saved = EPC.saved
    if saved and saved.inventoryGridCategoriesEnabled029365 == false then
        stripHeaders(list, false)
        return false
    end
    if type(rawget(_G, "ZO_ScrollList_GetDataList")) ~= "function" then return false end

    local ok, dataList = pcall(ZO_ScrollList_GetDataList, list)
    if not ok or type(dataList) ~= "table" then return false end
    if not registerHeader(list) then return false end

    local stripped, hadHeader = {}, false
    for _, entry in ipairs(dataList) do
        if isHeader(entry) then hadHeader = true else stripped[#stripped + 1] = entry end
    end

    -- Whenever ESO rebuilt the list there are no Suite headers. That exact native
    -- filtered/sorted list becomes the new base, so Weapons/Jewelry/etc never reuse
    -- stale entries from a previous native filter.
    if not hadHeader or not useCachedBase or not baseEntries[list] then baseEntries[list] = stripped end
    local base = baseEntries[list] or stripped

    local prefix, suffix, groups, order = {}, {}, {}, {}
    local seenItem = false
    for _, entry in ipairs(base) do
        local link = entryLink(entry)
        if link ~= "" then
            seenItem = true
            local group = categoryForLink(link)
            if not groups[group] then groups[group] = {}; order[#order + 1] = group end
            groups[group][#groups[group] + 1] = entry
        elseif not seenItem then
            prefix[#prefix + 1] = entry
        else
            suffix[#suffix + 1] = entry
        end
    end
    if #order == 0 then return false end
    table.sort(order, function(a, b) return string.lower(tostring(a)) < string.lower(tostring(b)) end)

    local state = collapsed[list]
    if not state then state = {}; collapsed[list] = state end
    local rebuilt = {}
    for _, entry in ipairs(prefix) do rebuilt[#rebuilt + 1] = entry end
    for _, group in ipairs(order) do
        local closed = state[group] == true
        local hd = {
            easSuiteFurnitureVaultHeader029591 = true,
            text = group, group = group, count = #groups[group], collapsed = closed, list = list,
        }
        local header = type(rawget(_G, "ZO_ScrollList_CreateDataEntry")) == "function"
            and ZO_ScrollList_CreateDataEntry(HEADER_TYPE, hd)
            or { typeId = HEADER_TYPE, data = hd }
        rebuilt[#rebuilt + 1] = header
        if not closed then
            for _, entry in ipairs(groups[group]) do rebuilt[#rebuilt + 1] = entry end
        end
    end
    for _, entry in ipairs(suffix) do rebuilt[#rebuilt + 1] = entry end

    applying = true
    local changed = replaceData(list, rebuilt)
    applying = false
    return changed
end

local function disableSuiteBankGrid()
    local U = EPC.BankGridUnifiedV2
    if not U or not vaultContextActive() then return end
    U.furnishingVaultDeposit029576 = false
    U.furnishingVaultSuiteGrid029577 = false
    U._suiteBankActive029539 = false
    U.specialStorageNative029558 = rawget(_G, "INVENTORY_FURNITURE_VAULT")
    if U.root and type(U.root.SetHidden) == "function" then pcall(U.root.SetHidden, U.root, true) end
end

local function applyInventoryType(inventoryType, useCachedBase)
    if not vaultContextActive() then return false end
    local backpack = rawget(_G, "INVENTORY_BACKPACK")
    local vault = rawget(_G, "INVENTORY_FURNITURE_VAULT")
    if inventoryType ~= backpack and inventoryType ~= vault then return false end
    disableSuiteBankGrid()
    return applyCategories(listFor(inventoryType), useCachedBase == true)
end

local function applyCurrent()
    local inventoryType = currentInventoryType()
    if inventoryType ~= nil then return applyInventoryType(inventoryType, false) end
    return false
end

local function scheduleCurrent()
    if not vaultContextActive() then return end
    generation = generation + 1
    local mine = generation
    if type(rawget(_G, "zo_callLater")) ~= "function" then applyCurrent(); return end
    for _, delay in ipairs({ 0, 30, 80, 160, 300 }) do
        zo_callLater(function()
            if mine == generation and vaultContextActive() then applyCurrent() end
        end, delay)
    end
end

-- Protect our intentionally injected native rows from InventoryGrid's generic
-- player-inventory safety purge while the Furniture Vault layout is active.
local grid = rawget(_G, "EASInventoryGrid")
if type(grid) == "table" and type(grid.PurgeUnsafePlayerInventoryHeaders029475) == "function" then
    local basePurge = grid.PurgeUnsafePlayerInventoryHeaders029475
    function grid:PurgeUnsafePlayerInventoryHeaders029475(...)
        if vaultContextActive() then return end
        return basePurge(self, ...)
    end
end

-- UpdateList is ESO's authoritative filtered-list rebuild. Reapply immediately
-- after ESO finishes building the exact inventoryType it just changed.
if type(rawget(_G, "ZO_PostHook")) == "function" and type(manager.UpdateList) == "function" then
    ZO_PostHook(manager, "UpdateList", function(_, inventoryType)
        if not vaultContextActive() then return end
        local backpack = rawget(_G, "INVENTORY_BACKPACK")
        local vault = rawget(_G, "INVENTORY_FURNITURE_VAULT")
        if inventoryType == backpack or inventoryType == vault then
            applyInventoryType(inventoryType, false)
            if type(rawget(_G, "zo_callLater")) == "function" then
                zo_callLater(function()
                    if vaultContextActive() then applyInventoryType(inventoryType, false) end
                end, 0)
            end
        end
    end)
end

-- ChangeFilter covers Weapons/Armor/Jewelry/etc. ESO normally calls UpdateList
-- from here; the delayed pass is a fallback for revisions that defer that rebuild.
if type(rawget(_G, "ZO_PostHook")) == "function" and type(manager.ChangeFilter) == "function" then
    ZO_PostHook(manager, "ChangeFilter", function(_, filterTab)
        if not vaultContextActive() then return end
        local inventoryType = type(filterTab) == "table" and filterTab.inventoryType or currentInventoryType()
        if type(rawget(_G, "zo_callLater")) == "function" then
            zo_callLater(function()
                if vaultContextActive() and inventoryType ~= nil then applyInventoryType(inventoryType, false) end
            end, 0)
        end
    end)
end

for _, fragmentName in ipairs({
    "BACKPACK_FURNITURE_VAULT_LAYOUT_FRAGMENT",
    "FURNITURE_VAULT_FRAGMENT",
    "INVENTORY_FRAGMENT",
}) do
    local fragment = rawget(_G, fragmentName)
    if fragment and type(fragment.RegisterCallback) == "function" then
        fragment:RegisterCallback("StateChange", function(_, newState)
            if newState == rawget(_G, "SCENE_FRAGMENT_SHOWING") or newState == rawget(_G, "SCENE_FRAGMENT_SHOWN") then
                if vaultContextActive() then scheduleCurrent() end
            elseif fragmentName == "BACKPACK_FURNITURE_VAULT_LAYOUT_FRAGMENT"
                and (newState == rawget(_G, "SCENE_FRAGMENT_HIDING") or newState == rawget(_G, "SCENE_FRAGMENT_HIDDEN")) then
                generation = generation + 1
                stripHeaders(listFor(rawget(_G, "INVENTORY_FURNITURE_VAULT")), true)
                stripHeaders(listFor(rawget(_G, "INVENTORY_BACKPACK")), true)
            end
        end)
    end
end

if EVENT_MANAGER then
    local prefix = (EPC.name or "ESOAdventurerSuite") .. "_FurnishingVaultCategoryController029591"
    for _, eventName in ipairs({ "EVENT_INVENTORY_FULL_UPDATE", "EVENT_INVENTORY_SINGLE_SLOT_UPDATE" }) do
        local eventCode = rawget(_G, eventName)
        if eventCode ~= nil then
            EVENT_MANAGER:RegisterForEvent(prefix .. eventName, eventCode, function()
                if vaultContextActive() then scheduleCurrent() end
            end)
        end
    end
end

disableSuiteBankGrid()
scheduleCurrent()
