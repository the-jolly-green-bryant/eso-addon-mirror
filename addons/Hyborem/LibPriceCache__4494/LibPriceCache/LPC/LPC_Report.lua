-- LPC_Report.lua
LibPriceCache = LibPriceCache or {}
LibPriceCache.Report = LibPriceCache.Report or {}
local R = LibPriceCache.Report

function R:Log(msg)
    local db = LibPriceCache.Core and LibPriceCache.Core.db
    if db and db.DisableStartupLog then return end
    d("|cFFFF00[LibPriceCache]|r " .. tostring(msg))
end

function R:EmergencyLog(ctx, err)
    d("|cFF0000[LibPriceCache ERROR]|r " .. ctx .. ": " .. tostring(err))
end

function R:FlushPendingLogs() end