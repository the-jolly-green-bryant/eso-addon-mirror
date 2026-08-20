local Bootstrap = STARSModuleBootstrap
local Project = Bootstrap and Bootstrap.current
if not Project then error("STARSConnect: config.lua must load before Presentations.lua") end

Project.Presentations = Project.Presentations or {}
local Presentations = Project.Presentations

local ModuleConfig = Project.Config.module

local connectedModule = {
    id = ModuleConfig.id,
    name = ModuleConfig.name,
    version = Project.Config.version,
    apiVersion = ModuleConfig.apiVersion,
    presentationType = ModuleConfig.presentationType,
    description = ModuleConfig.description,
    defaultActive = ModuleConfig.defaultActive,
}

function connectedModule:GetEntryCount()
    if type(Project.GetEntryCount) == "function" then
        return math.max(1, tonumber(Project:GetEntryCount()) or 1)
    end
    return 1
end

function connectedModule:ChangeEntry(delta)
    if type(Project.ChangeEntry) ~= "function" then return false end
    return Project:ChangeEntry(tonumber(delta) or 0) ~= false
end

function connectedModule:GetActions()
    if type(Project.GetActions) ~= "function" then return {} end
    local actions = Project:GetActions()
    return type(actions) == "table" and actions or {}
end

function connectedModule:GetPresentationData()
    if type(Project.GetPresentationData) == "function" then
        local data = Project:GetPresentationData()
        if type(data) == "table" then return data end
    end

    local fallback = Project.Config.presentation or {}
    return {
        title = fallback.title or Project.Config.displayName,
        subtitle = fallback.subtitle or "STARS CONNECTED MODULE",
        lines = { fallback.emptyMessage or "No presentation data is available." },
    }
end

function Presentations:Initialize()
    if not LibSTARSConnect or type(LibSTARSConnect.RegisterModule) ~= "function" then
        Project.Diagnostics:Warn("LibSTARSConnect is unavailable; module was not registered")
        return
    end

    local ok, err = LibSTARSConnect:RegisterModule(connectedModule)
    if not ok then
        Project.Diagnostics:Warn("STARS registration failed: " .. tostring(err))
        return
    end

    self.registered = true
    Project.Diagnostics:Log("Registered with STARS")
end

function Presentations:Shutdown()
    if not self.registered then return end
    if LibSTARSConnect and type(LibSTARSConnect.UnregisterModule) == "function" then
        LibSTARSConnect:UnregisterModule(ModuleConfig.id)
    end
    self.registered = false
end

Project.Controller:RegisterModule("Presentations", Presentations)
