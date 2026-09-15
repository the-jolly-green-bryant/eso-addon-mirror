-- ESO Adventurer Suite
-- v0.29.646 - cast-time UI performance guard + hard weapon-swap bypass fix.
-- Coalesces duplicate action-bar/advisor refreshes that can arrive together
-- when an ability is used. Keeps gameplay totals and ESO input untouched.
-- Delayed closures are explicitly swap-aware so they cannot bypass the later
-- RuntimePerformanceCoreOwnership outer gate by calling a captured base method.

local EPC = ESOProgressionCoach
if not EPC then return end

local function nowMS()
    if type(GetFrameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetFrameTimeMilliseconds)
        if ok then return tonumber(value) or 0 end
    end
    if type(GetGameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetGameTimeMilliseconds)
        if ok then return tonumber(value) or 0 end
    end
    return 0
end

local function inCombat()
    if type(IsUnitInCombat) ~= "function" then return false end
    local ok, value = pcall(IsUnitInCombat, "player")
    return ok and value == true
end

local function weaponSwapBlocked()
    local now = nowMS()
    local untilMs = tonumber(EPC.weaponSwapBroadRefreshUntil029636)
        or tonumber(EPC.weaponSwapSettlingUntil029636)
        or tonumber(EPC.weaponSwapSettlingUntil029635)
        or 0
    return now > 0 and now < untilMs
end

local function wrapRefresh(object, methodName, stateKey, minGap)
    if type(object) ~= "table" or type(object[methodName]) ~= "function" then return end
    local wrappedKey = "_easCastPerfWrapped_" .. stateKey
    if object[wrappedKey] then return end
    object[wrappedKey] = true

    local base = object[methodName]
    local lastKey = "_easCastPerfLast_" .. stateKey
    local pendingKey = "_easCastPerfPending_" .. stateKey

    object[methodName] = function(self, ...)
        -- Layout/editing actions should remain immediate.
        if self and self.layoutMode == true then
            self[lastKey] = nowMS()
            self[pendingKey] = false
            return base(self, ...)
        end

        -- Critical: a normal Primary/Backup swap owns this frame. Drop all
        -- cast/proc/advisor presentation work. Controlled timers reconcile later.
        if weaponSwapBlocked() then
            if self then self[pendingKey] = false end
            return nil
        end

        if not inCombat() then
            self[lastKey] = nowMS()
            self[pendingKey] = false
            return base(self, ...)
        end

        local now = nowMS()
        local last = tonumber(self[lastKey]) or 0
        local gap = now - last
        if last == 0 or gap >= minGap then
            self[lastKey] = now
            self[pendingKey] = false
            return base(self, ...)
        end

        -- One pending refresh is enough for a burst of slot/cooldown/proc events.
        if self[pendingKey] ~= true and type(zo_callLater) == "function" then
            self[pendingKey] = true
            local delay = math.max(1, math.floor(minGap - gap + 0.5))
            zo_callLater(function()
                if not self then return end
                self[pendingKey] = false

                -- base is a captured pre-wrapper method. Without this explicit
                -- guard it bypasses every later outer weapon-swap wrapper.
                if self.layoutMode ~= true and weaponSwapBlocked() then return end

                self[lastKey] = nowMS()
                base(self)
            end, delay)
        end
        return nil
    end
end

-- AbilityOverlays already has a periodic live tick. Slot-updated events can
-- otherwise force the same six-widget rebuild several times around one cast.
wrapRefresh(EPC.AbilityOverlays, "Refresh", "AbilityOverlays029513", 100)

-- Smart Combat Advisor can receive slot updates at the same time as its own
-- timer tick. Keep recommendation response fast but never rebuild repeatedly in
-- the same cast burst.
wrapRefresh(EPC.RotationAssistant, "Refresh", "RotationAssistant029513", 120)

-- Static Dual Action Bar data only needs prompt/event-scale responsiveness;
-- dynamic cooldown/effect values continue through its lightweight live path.
wrapRefresh(EPC.DualActionBar, "RefreshStatic029311", "DualStatic029513", 140)
