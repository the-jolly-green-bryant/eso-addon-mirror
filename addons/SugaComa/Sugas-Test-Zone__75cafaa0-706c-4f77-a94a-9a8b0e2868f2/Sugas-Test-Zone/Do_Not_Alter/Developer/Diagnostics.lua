SugasTestZoneProject = SugasTestZoneProject or {}
local Project = SugasTestZoneProject

Project.Diagnostics = Project.Diagnostics or {}
local Diagnostics = Project.Diagnostics

local function IsEnabled()
    return Project.sv
        and Project.sv.settings
        and Project.sv.settings.diagnostics == true
end

function Diagnostics:Log(message, force)
    if not force and not IsEnabled() then return end
    if type(d) == "function" then
        d(string.format("[STZ Project %s] %s", tostring(Project.Config.version), tostring(message)))
    end
end

function Diagnostics:Warn(message)
    self:Log("WARNING: " .. tostring(message), true)
end
