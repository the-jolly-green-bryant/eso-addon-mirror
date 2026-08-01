-- LibPriceCache - starter
LibPriceCache = LibPriceCache or {}
LibPriceCache.name = "LibPriceCache"
LibPriceCache.version = "1.1.2"

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(LibPriceCache.name, EVENT_PLAYER_ACTIVATED)
    if LibPriceCache.Report and LibPriceCache.Report.Log then
        LibPriceCache.Report:Log("|c00FF00LibPriceCache v" .. LibPriceCache.version .. " initialized.|r")
    else
        d("|cFFFF00[LibPriceCache]|r |c00FF00LibPriceCache v" .. LibPriceCache.version .. " initialized.|r")
    end
end

EVENT_MANAGER:RegisterForEvent(LibPriceCache.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)