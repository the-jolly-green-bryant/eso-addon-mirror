---------------------------------------------------------------------
local SLOTTABLE_COOLDOWN = 30000
local lastChange = 0

local lastZoneId = 0

local isOnCooldown = false
local listeners = {} -- {{startFunc = func, updateFunc = func, endFunc = func},}

---------------------------------------------------------------------
function IsOnCooldown()
    return isOnCooldown
end
DynamicCP.IsOnCooldown = IsOnCooldown

local function GetCooldownSeconds()
    if (not isOnCooldown) then return 0 end
    return (SLOTTABLE_COOLDOWN - GetGameTimeMilliseconds() + lastChange) / 1000
end
DynamicCP.GetCooldownSeconds = GetCooldownSeconds

---------------------------------------------------------------------
local function ProcessListeners(event)
    for _, functions in pairs(listeners) do
        local func = functions[event]
        if (func) then
            func()
        end
    end
end

function DynamicCP.RegisterCooldownListener(name, startFunc, updateFunc, endFunc)
    listeners[name] = {startFunc = startFunc, updateFunc = updateFunc, endFunc = endFunc}
end

---------------------------------------------------------------------
-- On purchase, set the cooldown
local function OnCooldownStarted(_, result)
    if (result ~= CHAMPION_PURCHASE_SUCCESS) then return end
    isOnCooldown = true
    lastChange = GetGameTimeMilliseconds()
    ProcessListeners("startFunc")

    -- Update the cooldown label
    EVENT_MANAGER:RegisterForUpdate(DynamicCP.name .. "Cooldown", 1000, function()
        local secondsRemaining = GetCooldownSeconds()
        if (secondsRemaining < 0) then -- Using < instead of <= here just to ensure we're not early by a fraction of a second
            EVENT_MANAGER:UnregisterForUpdate(DynamicCP.name .. "Cooldown")
            isOnCooldown = false
            ProcessListeners("endFunc")
        else
            ProcessListeners("updateFunc")
        end
    end)
end

---------------------------------------------------------------------
-- If we move to a different zone, reset the cooldown
-- It also seems to reset when porting to any player, even in the same instance, but we won't handle that
local function OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if (zoneId ~= lastZoneId and isOnCooldown) then
        DynamicCP.dbg("resetting cooldown because different zone")
        isOnCooldown = false
        ProcessListeners("endFunc")
    end
    lastZoneId = zoneId
end

---------------------------------------------------------------------
function DynamicCP.InitCooldown()
    EVENT_MANAGER:RegisterForEvent(DynamicCP.name .. "CooldownActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(DynamicCP.name .. "CooldownPurchased", EVENT_CHAMPION_PURCHASE_RESULT, OnCooldownStarted)
end
