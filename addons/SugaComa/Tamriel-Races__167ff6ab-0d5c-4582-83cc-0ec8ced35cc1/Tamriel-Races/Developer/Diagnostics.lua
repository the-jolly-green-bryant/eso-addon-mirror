TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.Diagnostics = TR.Diagnostics or {}
local Diagnostics = TR.Diagnostics

local function IsEnabled()
    return TR.sv
        and TR.sv.settings
        and TR.sv.settings.diagnostics == true
end

function Diagnostics:Log(message, force)
    if not force and not IsEnabled() then return end
    if d then
        d(string.format("[Tamriel Races %s] %s", tostring(TR.Config.version), tostring(message)))
    end
end

function Diagnostics:Warn(message)
    self:Log("WARNING: " .. tostring(message), true)
end
