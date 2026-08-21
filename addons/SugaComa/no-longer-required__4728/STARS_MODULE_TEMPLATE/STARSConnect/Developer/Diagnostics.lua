local Bootstrap = STARSModuleBootstrap
local Project = Bootstrap and Bootstrap.current
if not Project then error("STARSConnect: config.lua must load before Diagnostics.lua") end

Project.Diagnostics = Project.Diagnostics or {}
local Diagnostics = Project.Diagnostics

local function IsEnabled()
    return Project.sv
        and Project.sv.settings
        and Project.sv.settings.diagnostics == true
end

local function Prefix()
    local config = Project.Config or {}
    return tostring(config.diagnosticsPrefix or config.displayName or config.addonName or "STARS Module")
end

function Diagnostics:Log(message, force)
    if not force and not IsEnabled() then return end
    if type(d) == "function" then
        d(string.format("[%s %s] %s", Prefix(), tostring(Project.Config.version or "?"), tostring(message)))
    end
end

function Diagnostics:Warn(message)
    self:Log("WARNING: " .. tostring(message), true)
end
