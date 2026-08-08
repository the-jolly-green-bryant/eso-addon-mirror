NODE_RUNNER = NODE_RUNNER or {}
local Project = NODE_RUNNER

Project.Controller = Project.Controller or {}
local Controller = Project.Controller

Controller.initialized = false
Controller.modules = Controller.modules or {}

function Controller:RegisterModule(name, module)
    if type(name) ~= "string" or type(module) ~= "table" then
        Project.Diagnostics:Warn("Invalid module registration")
        return false
    end
    if self.modules[name] then
        Project.Diagnostics:Warn("Duplicate module registration: " .. name)
        return false
    end

    self.modules[name] = module
    return true
end

function Controller:CallModules(methodName, ...)
    for name, module in pairs(self.modules) do
        local method = module[methodName]
        if type(method) == "function" then
            local ok, err = pcall(method, module, ...)
            if not ok then
                Project.Diagnostics:Warn(string.format("%s.%s failed: %s", name, methodName, tostring(err)))
            end
        end
    end
end

function Controller:InitializeSavedVariables()
    Project.sv = ZO_SavedVars:NewAccountWide(
        Project.Config.savedVariablesName,
        Project.Config.savedVariablesVersion,
        nil,
        Project.Defaults
    )

    Project.sv.loaded = (tonumber(Project.sv.loaded) or 0) + 1
    Project.sv.settings = Project.sv.settings or {}
    if Project.sv.settings.diagnostics == nil then
        Project.sv.settings.diagnostics = false
    end
    Project.sv.projectData = Project.sv.projectData or {}
end

function Controller:Initialize()
    if self.initialized then return end

    self:InitializeSavedVariables()
    Project.State:Initialize()
    self:CallModules("Initialize")

    if EVENT_PLAYER_ACTIVATED then
        Project.Events:Register("PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
            self:CallModules("OnPlayerActivated")
        end)
    end

    self.initialized = true
    Project.Diagnostics:Log("Node Runner initialized", true)
end

function Controller:Shutdown()
    self:CallModules("Shutdown")
    Project.Events:UnregisterAll()
    Project.State:Reset()
    self.initialized = false
end
