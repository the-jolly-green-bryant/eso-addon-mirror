-- SatchelExchangeState.lua: Pure data initialization
-- Creates the initial state structure (defaults).

local SatchelExchangeState = {}

---@return SatchelExchangeRunState
function SatchelExchangeState.CreateRun()
    return {
        active = false,
        phase = "idle",
        token = 0,
        entryIndex = nil,
        itemLink = nil,
        itemId = nil,
        entryName = nil,
        startedAtMs = 0,
    }
end

---@return SatchelExchangeState
function SatchelExchangeState.Create()
    return {
        savedVars = {
            enabled = true,
            watchdogMs = 4000,
            autoCloseStore = true,
            resumeWindowMs = 300000,
            autoUnbox = false,
            unboxDelayMs = 200,
            unboxMaxAttempts = 10,
        },
        run = SatchelExchangeState.CreateRun(),
        session = {
            resumeItemLink = nil,
            resumeArmedAtMs = 0,
            buysThisSession = 0,
        },
        unbox = {
            active = false,
            itemId = nil,
            attemptsLeft = 0,
        },
    }
end

SatchelExchange.State = SatchelExchangeState
