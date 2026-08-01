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
            resumeWindowMs = 60000,
            autoUnbox = true,
            unboxTimeoutMs = 5000,
        },
        run = SatchelExchangeState.CreateRun(),
        session = {
            resumeItemLink = nil,
            resumeArmedAtMs = 0,
            buysThisSession = 0,
        },
        unbox = {
            active = false,
            pendingItemLink = nil,
            itemId = nil,
            startedAtMs = 0,
            deadlineMs = 0,
            seenInBag = false,
            seenAtMs = 0,
            useSent = false,
            useSentAtMs = 0,
            useUniqueId = nil,
            attemptIntervalMs = 0,
            nextAttemptAtMs = 0,
            attemptCount = 0,
            lastBlockReason = nil,
            lootWatchUntilMs = 0,
        },
    }
end

SatchelExchange.State = SatchelExchangeState
