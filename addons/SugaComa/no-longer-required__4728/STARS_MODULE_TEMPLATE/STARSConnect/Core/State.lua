local Bootstrap = STARSModuleBootstrap
local Project = Bootstrap and Bootstrap.current
if not Project then error("STARSConnect: config.lua must load before State.lua") end

Project.State = Project.State or {}
local State = Project.State

function State:Initialize()
    self.runtime = self.runtime or {}
    self.initialized = true
end

function State:Reset()
    self.runtime = {}
end

function State:Get(key, fallback)
    local value = self.runtime and self.runtime[key]
    if value == nil then return fallback end
    return value
end

function State:Set(key, value)
    self.runtime = self.runtime or {}
    self.runtime[key] = value
    return value
end
