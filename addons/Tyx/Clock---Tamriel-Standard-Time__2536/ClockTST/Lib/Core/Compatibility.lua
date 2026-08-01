--[[--------------------------------------------
    Project:    Clock - Tamriel Standard Time
    Author:     Arne Rantzen (Tyx) & Phinix
    Created:    2020-01-22
    Updated:    2020-02-11
    License:    GPL-3.0
--------------------------------------------]]--

--- a global function to get the current Tamriel Standard Time
-- Deprecated: Use the LibClockTST library instead to subscribe to TST updates
-- @usage local hour, minute, second = unpack(GetTST())
-- @return[1] hour in 24h format
-- @return[2] minute
-- @return[3] second
function GetTST()
    local t = LibClockTST:Instance():GetTime()
    return { t.hour, t.minute, t.second }
end