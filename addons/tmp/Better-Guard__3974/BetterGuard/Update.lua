BetterGuardAddon = BetterGuardAddon or {}
local BG = BetterGuardAddon

BG.interval = 7

function BG.OnUpdate()
    BG.OnUpdateLine(BG.unitTag1, BG.unitTag2)
end

function BG.StopPolling()
    EVENT_MANAGER:UnregisterForUpdate( BG.name .. "Update" )
end

function BG.StartPolling()
    EVENT_MANAGER:UnregisterForUpdate( BG.name .. "Update" )
    EVENT_MANAGER:RegisterForUpdate( BG.name .. "Update", BG.interval, BG.OnUpdate )
end
