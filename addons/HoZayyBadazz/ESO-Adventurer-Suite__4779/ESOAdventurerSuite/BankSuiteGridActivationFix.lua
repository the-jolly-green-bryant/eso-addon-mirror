-- ESO Adventurer Suite
-- v0.29.523 - Bank Suite grid activation fix.
-- BankSuiteGridFix v0.29.522 referenced GetCurrentInventoryType/IsAtBank,
-- which are not guaranteed ESO globals. Provide narrow compatibility shims
-- backed by ESO's real PLAYER_INVENTORY state so Withdraw/Deposit can activate.

local EPC = ESOProgressionCoach
if not EPC then return end

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function isVisible(control)
    return control and type(control.IsHidden) == "function" and safe(control.IsHidden, true, control) == false
end

local function playerInventoryIsBanking()
    local inv = rawget(_G, "PLAYER_INVENTORY")
    if type(inv) ~= "table" then return false end
    if type(inv.IsBanking) == "function" then
        local ok, value = pcall(inv.IsBanking, inv)
        if ok and value == true then return true end
    end
    if type(inv.IsGuildBanking) == "function" then
        local ok, value = pcall(inv.IsGuildBanking, inv)
        if ok and value == true then return true end
    end
    return false
end

-- Compatibility only. Do not replace an API supplied by ESO/another addon.
if type(rawget(_G, "IsAtBank")) ~= "function" then
    _G.IsAtBank = function()
        if playerInventoryIsBanking() then return true end
        local bankList = rawget(_G, "ZO_PlayerBankBackpack")
        if isVisible(bankList) then return true end
        if SCENE_MANAGER and type(SCENE_MANAGER.IsShowing) == "function" then
            for _, sceneName in ipairs({"bank", "banking"}) do
                local ok, shown = pcall(SCENE_MANAGER.IsShowing, SCENE_MANAGER, sceneName)
                if ok and shown == true then return true end
            end
        end
        return false
    end
end

if type(rawget(_G, "GetCurrentInventoryType")) ~= "function" then
    _G.GetCurrentInventoryType = function()
        local inv = rawget(_G, "PLAYER_INVENTORY")
        if type(inv) == "table" and playerInventoryIsBanking() then
            local selected = tonumber(inv.selectedTabType)
            if selected == rawget(_G, "INVENTORY_BANK")
                or selected == rawget(_G, "INVENTORY_HOUSE_BANK")
                or selected == rawget(_G, "INVENTORY_GUILD_BANK") then
                return selected
            end
            if selected == rawget(_G, "INVENTORY_BACKPACK") then
                return selected
            end
        end

        -- ESO keyboard bank shows one of these two list views for the active
        -- Withdraw/Deposit side. Visibility is a reliable fallback if an addon
        -- changes the normal selectedTabType flow.
        if isVisible(rawget(_G, "ZO_PlayerBankBackpack")) then
            return rawget(_G, "INVENTORY_BANK")
        end
        if playerInventoryIsBanking() and isVisible(rawget(_G, "ZO_PlayerInventoryList")) then
            return rawget(_G, "INVENTORY_BACKPACK")
        end
        return nil
    end
end

-- Force the already-loaded bank grid to evaluate again immediately now that the
-- compatibility state exists. Its existing 150 ms bank-only refresh stays active.
local grid = EPC.BankSuiteGridFix
if grid and type(grid.Refresh) == "function" then
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            if EPC and EPC.BankSuiteGridFix and type(EPC.BankSuiteGridFix.Refresh) == "function" then
                EPC.BankSuiteGridFix:Refresh(true)
            end
        end, 50)
        zo_callLater(function()
            if EPC and EPC.BankSuiteGridFix and type(EPC.BankSuiteGridFix.Refresh) == "function" then
                EPC.BankSuiteGridFix:Refresh(true)
            end
        end, 400)
    else
        grid:Refresh(true)
    end
end
