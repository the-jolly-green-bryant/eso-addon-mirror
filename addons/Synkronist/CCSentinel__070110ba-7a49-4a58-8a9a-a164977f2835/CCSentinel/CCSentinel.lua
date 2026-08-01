CCSentinel = {}
CCSentinel.name = "CCSentinel"
CCSentinel.version = "2.0" -- Updated for fixed duration
CCSentinel.timerActive = false
CCSentinel.checkInterval = 20 -- Check every 20ms

function CCSentinel:StartCCTimer()
    if self.timerActive then return end
    self.timerActive = true
    local totalMs = 6950 -- Fixed 6.95 seconds in milliseconds
    local warningMs = totalMs - 3950 -- 3 seconds before end

    -- Schedule initial message
    if CHAT_ROUTER then
        CHAT_ROUTER:AddSystemMessage("")
    end

    -- Schedule 3 seconds left message
    if warningMs > 0 then
        zo_callLater(function()
            if CHAT_ROUTER and self.timerActive then
                CHAT_ROUTER:AddSystemMessage("")
            end
        end, warningMs)
    end

    -- Schedule end message and loop restart
    zo_callLater(function()
        if CHAT_ROUTER and self.timerActive then
            CHAT_ROUTER:AddSystemMessage("")
        end
        self.timerActive = false
        -- Ensure the check loop continues
        zo_callLater(function() self:CheckBuffs() end, 0)
    end, totalMs)
end

function CCSentinel:CheckBuffs()
    if not self.timerActive then
        local numBuffs = GetNumBuffs("player")
        for i = 1, numBuffs do
            local name = select(1, GetUnitBuffInfo("player", i))
            if name == "Crowd Control Immunity" then
                self:StartCCTimer()
                return -- Exit after starting timer
            end
        end
    end
    -- Schedule next check
    zo_callLater(function() self:CheckBuffs() end, self.checkInterval)
end

function CCSentinel:Initialize()
    -- Start periodic buff checking
    zo_callLater(function() self:CheckBuffs() end, self.checkInterval)
    -- Initialize floating icon module
    CCSentinelFloats:Initialize()
    zo_callLater(function()
        if CHAT_ROUTER then
            CHAT_ROUTER:AddSystemMessage("")
        end
    end, 2000)
end

function CCSentinel:OnAddOnLoaded(eventCode, addonName)
    if addonName == self.name then
        self:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(CCSentinel.name, EVENT_ADD_ON_LOADED, function(...) CCSentinel:OnAddOnLoaded(...) end)
