local ExpenseReport = {}
local ER = ExpenseReport

ER.isRunning = false
ER.costs = {}

local function OnCurrencyUpdate(eventCode, currencyType, currencyLocation, newAmount, oldAmount, reason)
    if not ER.isRunning then return end

    -- Wayshrine recall cost (Reason Code 19)
    if reason == 19 then
        local cost = oldAmount - newAmount

        if cost > 0 then
            table.insert(ER.costs, cost)
            d(string.format("|c00FF00Expense Report:|r Wayshrine cost recorded: |cFFFFFF%d|r gold", cost))
        end
    end
end

local function StartEvent()
    if ER.isRunning then
        d("|cFF0000Expense Report:|r Tracking is already running.")
        return
    end

    ER.isRunning = true
    ER.costs = {}
    d("|c00FF00Expense Report:|r Tracking started.")
end

local function StopEvent()
    if not ER.isRunning then
        d("|cFF0000Expense Report:|r Tracking is not currently running.")
        return
    end

    ER.isRunning = false
    d("|c00FF00Expense Report:|r Tracking stopped. Generating report...")

    if #ER.costs == 0 then
        d("|cFFFFFFNo wayshrine costs were recorded.|r")
        return
    end

    d("--------------------------------------------------")
    d("|c00FF00Expense Report - Wayshrine Travel Costs|r")
    d("--------------------------------------------------")

    local total = 0
    for i, cost in ipairs(ER.costs) do
        d(string.format("Trip %d: |cFFFFFF%d|r gold", i, cost))
        total = total + cost
    end

    d("--------------------------------------------------")
    d(string.format("|cFFD700Total Expense: %d gold|r", total))
    d("--------------------------------------------------")
    d("|cAAAAAATake a screenshot and submit to your guild.|r")
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= "ExpenseReport" then return end

    EVENT_MANAGER:UnregisterForEvent("ExpenseReport", EVENT_ADD_ON_LOADED)

    -- Register currency tracking
    EVENT_MANAGER:RegisterForEvent("ExpenseReport", EVENT_CURRENCY_UPDATE, OnCurrencyUpdate)
    EVENT_MANAGER:AddFilterForEvent("ExpenseReport", EVENT_CURRENCY_UPDATE, REGISTER_FILTER_CURRENCY_TYPE, CURT_MONEY)
    EVENT_MANAGER:AddFilterForEvent("ExpenseReport", EVENT_CURRENCY_UPDATE, REGISTER_FILTER_CURRENCY_LOCATION, CURRENCY_LOCATION_CHARACTER)

    -- Slash commands
    SLASH_COMMANDS["/eventstart"] = StartEvent
    SLASH_COMMANDS["/eventstop"]  = StopEvent

    d("|c00FF00Expense Report loaded.|r")
end

EVENT_MANAGER:RegisterForEvent("ExpenseReport", EVENT_ADD_ON_LOADED, OnAddonLoaded)
