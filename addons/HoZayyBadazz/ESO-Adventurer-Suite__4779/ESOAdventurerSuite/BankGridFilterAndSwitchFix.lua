-- ESO Adventurer Suite
-- v0.29.654 - exact bank top-category filtering without double-filter false negatives.
-- Bank Withdraw and Deposit use ESO's selected top display category as the one
-- authoritative category predicate. Do not run ShouldAddSlotToList a second time
-- against the Suite's separately collected bag items; that could incorrectly hide
-- valid Materials, Jewelry, and other categories.

local EPC = ESOProgressionCoach
if not EPC then return end
local U = EPC.BankGridUnifiedV2
if not U then return end

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function inventoryList(invType)
    local manager = rawget(_G, "PLAYER_INVENTORY")
    if type(manager) ~= "table" or type(manager.inventories) ~= "table" or invType == nil then return nil end
    local data = manager.inventories[invType]
    if type(data) ~= "table" then return nil end
    for _, key in ipairs({ "list", "listView", "scrollList" }) do
        local control = data[key]
        if control and type(control.GetLeft) == "function" then return control end
    end
    return nil
end

local function candidates()
    local out, seen = {}, {}
    local function add(mode, control, invType)
        if not control or seen[control] or type(control.GetLeft) ~= "function" then return end
        seen[control] = true
        out[#out + 1] = { mode = mode, control = control, invType = invType }
    end

    local BACKPACK = rawget(_G, "INVENTORY_BACKPACK")
    local BANK = rawget(_G, "INVENTORY_BANK")
    local HOUSE = rawget(_G, "INVENTORY_HOUSE_BANK")
    local GUILD = rawget(_G, "INVENTORY_GUILD_BANK")

    add("WITHDRAW", rawget(_G, "ZO_PlayerBankBackpack"), BANK)
    add("DEPOSIT", rawget(_G, "ZO_PlayerInventoryList"), BACKPACK)
    add("WITHDRAW", inventoryList(BANK), BANK)
    add("WITHDRAW", inventoryList(HOUSE), HOUSE)
    add("WITHDRAW", inventoryList(GUILD), GUILD)
    add("DEPOSIT", inventoryList(BACKPACK), BACKPACK)
    return out
end

local function bankInventoryType(mode)
    if mode == "DEPOSIT" then return rawget(_G, "INVENTORY_BACKPACK") end
    local manager = rawget(_G, "PLAYER_INVENTORY")
    if type(manager) == "table" then
        if type(manager.GetBankInventoryType) == "function" then
            local ok, value = pcall(manager.GetBankInventoryType, manager)
            if ok and value ~= nil then return value end
        end
        if type(manager.IsGuildBanking) == "function" then
            local ok, value = pcall(manager.IsGuildBanking, manager)
            if ok and value == true then return rawget(_G, "INVENTORY_GUILD_BANK") end
        end
    end
    return rawget(_G, "INVENTORY_BANK")
end

local function nativeInventoryForMode(mode)
    local manager = rawget(_G, "PLAYER_INVENTORY")
    if type(manager) ~= "table" or type(manager.inventories) ~= "table" then return nil, nil, nil end
    local invType = bankInventoryType(mode)
    local inventory = invType ~= nil and manager.inventories[invType] or nil
    if type(inventory) ~= "table" then return manager, nil, invType end
    return manager, inventory, invType
end

local function nativeSlotData(inventory, item)
    if type(item) ~= "table" then return nil end
    if type(inventory) == "table" and type(inventory.slots) == "table" then
        local bagSlots = inventory.slots[item.bag]
        if type(bagSlots) == "table" then
            local direct = bagSlots[item.slot]
            if type(direct) == "table" then return direct end
            for _, slotData in pairs(bagSlots) do
                if type(slotData) == "table" and slotData.bagId == item.bag and slotData.slotIndex == item.slot then
                    return slotData
                end
            end
        end
    end
    local shared = rawget(_G, "SHARED_INVENTORY")
    if type(shared) == "table" and type(shared.GenerateSingleSlotData) == "function" then
        local ok, data = pcall(shared.GenerateSingleSlotData, shared, item.bag, item.slot)
        if ok and type(data) == "table" then return data end
    end
    return nil
end

U._easBankTopFilter029542 = U._easBankTopFilter029542 or {}

local manager = rawget(_G, "PLAYER_INVENTORY")
if type(manager) == "table" and type(manager.ChangeFilter) == "function" and not manager._easBankExactFilterHook029542 then
    manager._easBankExactFilterHook029542 = true
    local baseChangeFilter = manager.ChangeFilter
    manager.ChangeFilter = function(self, filterTab, ...)
        local results = { baseChangeFilter(self, filterTab, ...) }
        if type(filterTab) == "table" and not filterTab.isSubFilter then
            local invType = filterTab.inventoryType
            local filterType = filterTab.filterType or filterTab.descriptor
            if invType ~= nil and filterType ~= nil then U._easBankTopFilter029542[invType] = filterType end
        end
        U.scroll = 0
        U.dirty = true
        if type(zo_callLater) == "function" then
            zo_callLater(function() if U and type(U.Refresh) == "function" then U:Refresh() end end, 0)
        elseif type(U.Refresh) == "function" then U:Refresh() end
        return unpack(results)
    end
end

local function activeTopFilter(inventory, invType)
    local captured = U._easBankTopFilter029542 and U._easBankTopFilter029542[invType]
    if captured ~= nil then return captured end
    return type(inventory) == "table" and inventory.currentFilter or rawget(_G, "ITEM_TYPE_DISPLAY_CATEGORY_ALL")
end

local function topCategoryPass(slotData, filter)
    local ALL = rawget(_G, "ITEM_TYPE_DISPLAY_CATEGORY_ALL")
    if filter == nil or filter == ALL then return true end
    local utils = rawget(_G, "ZO_ItemFilterUtils")
    if type(utils) == "table" and type(utils.IsSlotInItemTypeDisplayCategory) == "function" and type(slotData) == "table" then
        local ok, allowed = pcall(utils.IsSlotInItemTypeDisplayCategory, slotData, filter)
        if ok then return allowed == true end
    end
    -- If ESO cannot classify the generated slot data, fail open rather than
    -- hiding a real item the player can clearly see in the source bag.
    return true
end

local baseCollect = U.Collect
function U:Collect(mode)
    local items = type(baseCollect) == "function" and baseCollect(self, mode) or {}
    if type(items) ~= "table" then return {} end

    local _, inventory, invType = nativeInventoryForMode(mode)
    if type(inventory) ~= "table" then return items end

    local filter = activeTopFilter(inventory, invType)
    local ALL = rawget(_G, "ITEM_TYPE_DISPLAY_CATEGORY_ALL")
    if filter == nil or filter == ALL then return items end

    local filtered = {}
    for _, item in ipairs(items) do
        local slotData = nativeSlotData(inventory, item)
        if topCategoryPass(slotData, filter) then filtered[#filtered + 1] = item end
    end
    return filtered
end

local function selectedMode()
    local mgr = rawget(_G, "PLAYER_INVENTORY")
    local selected = type(mgr) == "table" and tonumber(mgr.selectedTabType) or nil
    if selected == rawget(_G, "INVENTORY_BACKPACK") then return "DEPOSIT" end
    if selected == rawget(_G, "INVENTORY_BANK") or selected == rawget(_G, "INVENTORY_HOUSE_BANK") or selected == rawget(_G, "INVENTORY_GUILD_BANK") then return "WITHDRAW" end
    return nil
end

local function resolvePane()
    local preferred = selectedMode()
    local best
    for _, entry in ipairs(candidates()) do
        local c = entry.control
        if c and type(c.IsHidden) == "function" and first(c.IsHidden, true, c) == false then
            local l = tonumber(first(c.GetLeft, nil, c)); local t = tonumber(first(c.GetTop, nil, c))
            local r = tonumber(first(c.GetRight, nil, c)); local b = tonumber(first(c.GetBottom, nil, c))
            if l and t and r and b then
                local w, h = r - l, b - t
                if w > 250 and h > 150 then
                    local score = w * h + ((preferred == entry.mode) and 100000000 or 0)
                    if not best or score > best.score then best = { mode=entry.mode, control=c, invType=entry.invType, w=w, h=h, score=score } end
                end
            end
        end
    end
    return best
end

local function restore(control)
    if not control then return end
    if type(control.SetAlpha) == "function" then pcall(control.SetAlpha, control, 1) end
    if type(control.SetMouseEnabled) == "function" then pcall(control.SetMouseEnabled, control, true) end
end

local function suppress(control)
    if not control then return end
    if type(control.SetAlpha) == "function" then pcall(control.SetAlpha, control, 0) end
    if type(control.SetMouseEnabled) == "function" then pcall(control.SetMouseEnabled, control, false) end
end

local function bankOpen()
    if U.open == true then return true end
    local mgr = rawget(_G, "PLAYER_INVENTORY")
    if type(mgr) == "table" then
        if type(mgr.IsBanking) == "function" then local ok,v=pcall(mgr.IsBanking,mgr); if ok and v==true then return true end end
        if type(mgr.IsGuildBanking) == "function" then local ok,v=pcall(mgr.IsGuildBanking,mgr); if ok and v==true then return true end end
    end
    return false
end

function U:Refresh()
    if not bankOpen() then
        for _, entry in ipairs(candidates()) do restore(entry.control) end
        if self.root and type(self.root.SetHidden) == "function" then pcall(self.root.SetHidden, self.root, true) end
        self._suiteBankActive029539 = false
        return
    end
    local info = resolvePane()
    if not info or type(self.Render) ~= "function" then
        if self._suiteBankActive029539 then for _, entry in ipairs(candidates()) do suppress(entry.control) end end
        return
    end
    local ok, shown = pcall(self.Render, self, info)
    if ok and shown == true then
        self._suiteBankActive029539 = true
        for _, entry in ipairs(candidates()) do suppress(entry.control) end
        if self.root and type(self.root.SetHidden) == "function" then pcall(self.root.SetHidden, self.root, false) end
        return
    end
    if not self._suiteBankActive029539 then
        for _, entry in ipairs(candidates()) do restore(entry.control) end
        if self.root and type(self.root.SetHidden) == "function" then pcall(self.root.SetHidden, self.root, true) end
    else
        for _, entry in ipairs(candidates()) do suppress(entry.control) end
    end
end

U.dirty = true
