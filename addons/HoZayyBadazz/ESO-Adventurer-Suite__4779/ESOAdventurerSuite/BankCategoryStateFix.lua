-- ESO Adventurer Suite
-- v0.29.521 - Bank category collapse/restore stability.
-- InventoryGrid keeps its module table local. This fix discovers that live owner
-- from the Suite category headers once the bank list exists, then preserves the
-- authoritative full bank rows across collapse/expand and ESO bank refreshes.

local EPC = ESOProgressionCoach
if not EPC then return end

local UPDATE_NAME = (EPC.name or "ESOAdventurerSuite") .. "_BankCategoryState029521"
local installedOwner = nil

local function isBankList(list)
    if not list then return false end
    if list == rawget(_G, "ZO_PlayerBankBackpack")
        or list == rawget(_G, "ZO_HouseBankBackpack")
        or list == rawget(_G, "ZO_GuildBankBackpack") then
        return true
    end

    local inv = rawget(_G, "PLAYER_INVENTORY")
    if type(inv) ~= "table" or type(inv.inventories) ~= "table" then return false end
    for _, key in ipairs({
        rawget(_G, "INVENTORY_BANK"),
        rawget(_G, "INVENTORY_HOUSE_BANK"),
        rawget(_G, "INVENTORY_GUILD_BANK"),
    }) do
        local data = key ~= nil and inv.inventories[key] or nil
        if type(data) == "table" and (data.list == list or data.listView == list or data.scrollList == list) then
            return true
        end
    end
    return false
end

local function collectBankLists()
    local out, seen = {}, {}
    local function add(list)
        if not list or seen[list] then return end
        if type(ZO_ScrollList_GetDataList) ~= "function" then return end
        local ok, data = pcall(ZO_ScrollList_GetDataList, list)
        if ok and type(data) == "table" then
            seen[list] = true
            out[#out + 1] = list
        end
    end

    add(rawget(_G, "ZO_PlayerBankBackpack"))
    add(rawget(_G, "ZO_HouseBankBackpack"))
    add(rawget(_G, "ZO_GuildBankBackpack"))

    local inv = rawget(_G, "PLAYER_INVENTORY")
    if type(inv) == "table" and type(inv.inventories) == "table" then
        for _, key in ipairs({
            rawget(_G, "INVENTORY_BANK"),
            rawget(_G, "INVENTORY_HOUSE_BANK"),
            rawget(_G, "INVENTORY_GUILD_BANK"),
        }) do
            local data = key ~= nil and inv.inventories[key] or nil
            if type(data) == "table" then
                add(data.list)
                add(data.listView)
                add(data.scrollList)
            end
        end
    end
    return out
end

local function getEntryData(entry)
    return type(entry) == "table" and (entry.data or entry) or nil
end

local function isSuiteHeader(entry)
    local data = getEntryData(entry)
    return type(data) == "table"
        and (data.easSuiteCategoryHeader029364 == true or data.easSuiteCategoryHeader029376 == true)
end

local function copyEntries(entries)
    local out = {}
    for i, entry in ipairs(entries or {}) do out[i] = entry end
    return out
end

local function findOwner()
    if type(ZO_ScrollList_GetDataList) ~= "function" then return nil end
    for _, list in ipairs(collectBankLists()) do
        local ok, dataList = pcall(ZO_ScrollList_GetDataList, list)
        if ok and type(dataList) == "table" then
            for _, entry in ipairs(dataList) do
                local data = getEntryData(entry)
                if type(data) == "table" and isSuiteHeader(entry)
                    and type(data.owner) == "table"
                    and type(data.owner.ApplyCategoriesToNativeList029364) == "function"
                    and type(data.owner.ToggleNativeCategory029376) == "function" then
                    return data.owner
                end
            end
        end
    end
    return nil
end

local function install(owner)
    if type(owner) ~= "table" or owner._bankStateFixInstalled029521 then return false end
    owner._bankStateFixInstalled029521 = true
    installedOwner = owner

    owner.bankFullBase029521 = owner.bankFullBase029521 or setmetatable({}, {__mode = "k"})
    owner.bankCollapsed029521 = owner.bankCollapsed029521 or setmetatable({}, {__mode = "k"})

    -- Seed the preserved full list from any bank that is currently fully visible.
    if type(ZO_ScrollList_GetDataList) == "function" then
        for _, list in ipairs(collectBankLists()) do
            local ok, dataList = pcall(ZO_ScrollList_GetDataList, list)
            if ok and type(dataList) == "table" then
                local clean, hasHeader = {}, false
                for _, entry in ipairs(dataList) do
                    if isSuiteHeader(entry) then hasHeader = true else clean[#clean + 1] = entry end
                end
                if not hasHeader and #clean > 0 then owner.bankFullBase029521[list] = copyEntries(clean) end
            end
        end
    end

    local baseApply = owner.ApplyCategoriesToNativeList029364
    function owner:ApplyCategoriesToNativeList029364(list, ...)
        if not isBankList(list) or type(ZO_ScrollList_GetDataList) ~= "function" then
            return baseApply(self, list, ...)
        end

        local ok, dataList = pcall(ZO_ScrollList_GetDataList, list)
        if not ok or type(dataList) ~= "table" then return baseApply(self, list, ...) end

        local clean, hasHeader = {}, false
        for _, entry in ipairs(dataList) do
            if isSuiteHeader(entry) then hasHeader = true else clean[#clean + 1] = entry end
        end

        -- A list with Suite headers may be visually collapsed. Never promote that
        -- partial visible set to the authoritative bank source.
        if not hasHeader and #clean > 0 then
            self.bankFullBase029521[list] = copyEntries(clean)
        end

        local full = self.bankFullBase029521[list]
        self.nativeBaseEntries029376 = self.nativeBaseEntries029376 or setmetatable({}, {__mode = "k"})
        self.nativeCollapsed029376 = self.nativeCollapsed029376 or setmetatable({}, {__mode = "k"})

        if full and #full > 0 then self.nativeBaseEntries029376[list] = full end
        if self.bankCollapsed029521[list] then self.nativeCollapsed029376[list] = self.bankCollapsed029521[list] end

        local result = baseApply(self, list, ...)

        -- Reassert after base processing in case ESO refreshed the visible list
        -- while a category was collapsed.
        if full and #full > 0 then self.nativeBaseEntries029376[list] = full end
        if self.nativeCollapsed029376[list] then
            self.bankCollapsed029521[list] = self.nativeCollapsed029376[list]
        end
        return result
    end

    local baseToggle = owner.ToggleNativeCategory029376
    function owner:ToggleNativeCategory029376(list, group, ...)
        if not isBankList(list) then return baseToggle(self, list, group, ...) end

        self.nativeBaseEntries029376 = self.nativeBaseEntries029376 or setmetatable({}, {__mode = "k"})
        self.nativeCollapsed029376 = self.nativeCollapsed029376 or setmetatable({}, {__mode = "k"})

        local full = self.bankFullBase029521[list]
        if full and #full > 0 then self.nativeBaseEntries029376[list] = full end

        local state = self.nativeCollapsed029376[list]
        if not state then
            state = self.bankCollapsed029521[list] or {}
            self.nativeCollapsed029376[list] = state
        end
        self.bankCollapsed029521[list] = state

        local result = baseToggle(self, list, group, ...)
        self.bankCollapsed029521[list] = self.nativeCollapsed029376[list] or state
        return result
    end

    local baseReset = owner.ResetNativeCategorySceneState029451
    if type(baseReset) == "function" then
        function owner:ResetNativeCategorySceneState029451(...)
            local preservedBase = self.bankFullBase029521
            local preservedCollapsed = self.bankCollapsed029521
            local result = baseReset(self, ...)

            self.bankFullBase029521 = preservedBase or setmetatable({}, {__mode = "k"})
            self.bankCollapsed029521 = preservedCollapsed or setmetatable({}, {__mode = "k"})
            self.nativeBaseEntries029376 = self.nativeBaseEntries029376 or setmetatable({}, {__mode = "k"})
            self.nativeCollapsed029376 = self.nativeCollapsed029376 or setmetatable({}, {__mode = "k"})

            for list, full in pairs(self.bankFullBase029521) do
                if isBankList(list) and full and #full > 0 then self.nativeBaseEntries029376[list] = full end
            end
            for list, state in pairs(self.bankCollapsed029521) do
                if isBankList(list) and state then self.nativeCollapsed029376[list] = state end
            end
            return result
        end
    end

    return true
end

local function tryInstall()
    if installedOwner and installedOwner._bankStateFixInstalled029521 then return true end
    local owner = findOwner()
    if owner then return install(owner) end
    return false
end

-- Bank controls and Suite headers are lazy-created. Probe lightly only until the
-- live owner is found, then stop permanently; there is no combat/runtime poll.
if EVENT_MANAGER then
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 250, function()
        if tryInstall() then EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME) end
    end)
end

if type(zo_callLater) == "function" then
    zo_callLater(tryInstall, 100)
    zo_callLater(tryInstall, 600)
else
    tryInstall()
end
