-- ESO Adventurer Suite
-- v0.29.618 - specialized storage ownership boundary.
-- Personal Bank keeps the Suite bank grid. Guild Bank keeps ESO's native
-- presentation. House Storage and Furnishing Vault are reserved exclusively for
-- their dedicated Suite renderers and must never be restored/rendered here.

local EPC = ESOProgressionCoach
if not EPC or not EPC.BankGridUnifiedV2 then return end

local U = EPC.BankGridUnifiedV2

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function isShown(control)
    if not control or type(control.IsHidden) ~= "function" then return false end
    return first(control.IsHidden, true, control) == false
end

local function inventoryList(invType)
    local manager = rawget(_G, "PLAYER_INVENTORY")
    if type(manager) ~= "table" or type(manager.inventories) ~= "table" or invType == nil then return nil end
    local data = manager.inventories[invType]
    if type(data) ~= "table" then return nil end
    for _, key in ipairs({ "list", "listView", "scrollList" }) do
        local control = data[key]
        if control then return control end
    end
    return nil
end

local function furnishingVaultVisible029583()
    if isShown(rawget(_G, "ZO_FurnitureVaultTabs"))
        or isShown(rawget(_G, "ZO_FurnitureVaultSearchFilters"))
        or isShown(rawget(_G, "ZO_FurnitureVaultSearchFiltersTextSearchBox"))
        or isShown(rawget(_G, "ZO_FurnitureVaultInfoBar"))
        or isShown(rawget(_G, "ZO_FurnitureVaultList")) then
        return true
    end

    local function fragmentShown(fragment)
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

    if fragmentShown(rawget(_G, "BACKPACK_FURNITURE_VAULT_LAYOUT_FRAGMENT")) then return true end
    if fragmentShown(rawget(_G, "FURNITURE_VAULT_FRAGMENT")) then return true end

    local manager = rawget(_G, "PLAYER_INVENTORY")
    if type(manager) == "table" and type(manager.inventories) == "table" then
        for _, inventoryType in ipairs({ rawget(_G, "INVENTORY_BACKPACK"), rawget(_G, "INVENTORY_FURNITURE_VAULT") }) do
            local data = inventoryType ~= nil and manager.inventories[inventoryType] or nil
            if type(data) == "table" and tostring(data.currentContext or "") == "furnitureVaultTextSearch" then
                return true
            end
        end
    end

    local sm = rawget(_G, "SCENE_MANAGER")
    if sm and type(sm.IsShowing) == "function" then
        local ok, shown = pcall(sm.IsShowing, sm, "furnitureVault")
        if ok and shown == true then return true end
    end
    return false
end

local function houseStorageActive029608()
    local function fragmentShown(fragment)
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

    if fragmentShown(rawget(_G, "BACKPACK_HOUSE_BANK_LAYOUT_FRAGMENT")) then return true end
    if fragmentShown(rawget(_G, "HOUSE_BANK_FRAGMENT")) then return true end
    if fragmentShown(rawget(_G, "HOUSE_BANK_MENU_FRAGMENT")) then return true end

    local sm = rawget(_G, "SCENE_MANAGER")
    if sm and type(sm.IsShowing) == "function" then
        local ok, shown = pcall(sm.IsShowing, sm, "houseBank")
        if ok and shown == true then return true end
    end
    return false
end

local function activeSpecialInventoryType()
    local manager = rawget(_G, "PLAYER_INVENTORY")
    if type(manager) ~= "table" then return nil end

    local GUILD = rawget(_G, "INVENTORY_GUILD_BANK")
    local HOUSE = rawget(_G, "INVENTORY_HOUSE_BANK")
    local FURNITURE = rawget(_G, "INVENTORY_FURNITURE_VAULT")

    -- Dedicated Suite storage renderers are detected before selectedTabType because
    -- their Deposit sides use INVENTORY_BACKPACK while the special scene is live.
    if HOUSE ~= nil and houseStorageActive029608() then return HOUSE end
    if FURNITURE ~= nil and furnishingVaultVisible029583() then return FURNITURE end

    if type(manager.IsGuildBanking) == "function" and first(manager.IsGuildBanking, false, manager) == true then
        return GUILD
    end

    local selected = tonumber(manager.selectedTabType)
    if selected ~= nil and (selected == GUILD or selected == HOUSE) then
        return selected
    end

    if type(manager.GetBankInventoryType) == "function" then
        local bankType = tonumber(first(manager.GetBankInventoryType, nil, manager))
        if bankType ~= nil and (bankType == GUILD or bankType == HOUSE) then
            return bankType
        end
    end

    local houseList = inventoryList(HOUSE) or rawget(_G, "ZO_HouseBankBackpack")
    if HOUSE ~= nil and isShown(houseList) and houseStorageActive029608() then return HOUSE end

    return nil
end

local function restore(control)
    if not control then return end
    if type(control.SetAlpha) == "function" then pcall(control.SetAlpha, control, 1) end
    if type(control.SetMouseEnabled) == "function" then pcall(control.SetMouseEnabled, control, true) end
end

local function hideGenericBankGrid()
    if U.root and type(U.root.SetHidden) == "function" then
        pcall(U.root.SetHidden, U.root, true)
    end
    U._suiteBankActive029539 = false
end

local function reserveHouseStorage()
    -- Do not restore or suppress House Storage controls here. Its dedicated
    -- renderer needs the live native data list and owns native-row suppression.
    hideGenericBankGrid()
    U.specialStorageNative029558 = rawget(_G, "INVENTORY_HOUSE_BANK")
end

local function reserveFurnishingVault()
    -- Same ownership rule as House Storage: only disable the generic bank overlay.
    -- FurnishingVaultPureNativeFix.lua owns row suppression, grid layout and input.
    hideGenericBankGrid()
    U.specialStorageNative029558 = rawget(_G, "INVENTORY_FURNITURE_VAULT")
    U.furnishingVaultSuiteExclusive029617 = true
    U.furnishingVaultSuiteGrid029577 = false
    U.furnishingVaultDeposit029576 = false
end

local function restoreSpecialInventory(invType)
    restore(inventoryList(invType))
    restore(inventoryList(rawget(_G, "INVENTORY_BACKPACK")))
    restore(rawget(_G, "ZO_PlayerInventoryList"))

    if invType == rawget(_G, "INVENTORY_GUILD_BANK") then
        restore(rawget(_G, "ZO_GuildBankBackpack"))
    end

    hideGenericBankGrid()
    U.specialStorageNative029558 = invType
end

local BaseRefresh029558 = U.Refresh
function U:Refresh(...)
    local specialType = activeSpecialInventoryType()
    if specialType == rawget(_G, "INVENTORY_HOUSE_BANK") then
        reserveHouseStorage()
        return
    end
    if specialType == rawget(_G, "INVENTORY_FURNITURE_VAULT") then
        reserveFurnishingVault()
        return
    end
    if specialType ~= nil then
        restoreSpecialInventory(specialType)
        return
    end
    self.specialStorageNative029558 = nil
    self.furnishingVaultSuiteExclusive029617 = false
    if type(BaseRefresh029558) == "function" then
        return BaseRefresh029558(self, ...)
    end
end

local BaseCollect029558 = U.Collect
function U:Collect(mode, ...)
    local specialType = activeSpecialInventoryType()
    if specialType == rawget(_G, "INVENTORY_HOUSE_BANK") then
        reserveHouseStorage()
        return {}
    end
    if specialType == rawget(_G, "INVENTORY_FURNITURE_VAULT") then
        reserveFurnishingVault()
        return {}
    end
    if specialType ~= nil then
        restoreSpecialInventory(specialType)
        return {}
    end
    if type(BaseCollect029558) == "function" then
        return BaseCollect029558(self, mode, ...)
    end
    return {}
end

local BaseMove029558 = U.Move
function U:Move(item, ...)
    local specialType = activeSpecialInventoryType()
    if specialType == rawget(_G, "INVENTORY_HOUSE_BANK") then
        reserveHouseStorage()
        return
    end
    if specialType == rawget(_G, "INVENTORY_FURNITURE_VAULT") then
        reserveFurnishingVault()
        return
    end
    if specialType ~= nil then
        restoreSpecialInventory(specialType)
        return
    end
    if type(BaseMove029558) == "function" then
        return BaseMove029558(self, item, ...)
    end
end

if EVENT_MANAGER then
    local prefix = (EPC.name or "ESOAdventurerSuite") .. "_SpecialStorageNative029618"
    local pending = false
    local function scheduleRefresh()
        if pending then return end
        pending = true
        local function run()
            pending = false
            if U and U.Refresh then U:Refresh() end
        end
        if type(zo_callLater) == "function" then zo_callLater(run, 0) else run() end
    end

    for _, eventName in ipairs({
        "EVENT_OPEN_GUILD_BANK",
        "EVENT_CLOSE_GUILD_BANK",
        "EVENT_OPEN_BANK",
        "EVENT_CLOSE_BANK",
        "EVENT_INVENTORY_FULL_UPDATE",
        "EVENT_INVENTORY_SINGLE_SLOT_UPDATE",
    }) do
        local eventCode = rawget(_G, eventName)
        if eventCode ~= nil then
            EVENT_MANAGER:RegisterForEvent(prefix .. "_" .. eventName, eventCode, scheduleRefresh)
        end
    end
end
