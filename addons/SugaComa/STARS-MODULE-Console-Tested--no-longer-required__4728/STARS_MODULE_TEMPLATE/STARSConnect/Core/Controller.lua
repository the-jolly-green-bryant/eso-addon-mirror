local Bootstrap = STARSModuleBootstrap
local Project = Bootstrap and Bootstrap.current
if not Project then error("STARSConnect: config.lua must load before Controller.lua") end

Project.Controller = Project.Controller or {}
local Controller = Project.Controller

Controller.initialized = false
Controller.modules = Controller.modules or {}
Controller.moduleOrder = Controller.moduleOrder or {}

function Controller:RegisterModule(name, module)
    if type(name) ~= "string" or name == "" or type(module) ~= "table" then
        Project.Diagnostics:Warn("Invalid internal module registration")
        return false
    end
    if self.modules[name] and self.modules[name] ~= module then
        Project.Diagnostics:Warn("Duplicate internal module registration: " .. name)
        return false
    end

    if not self.modules[name] then
        self.moduleOrder[#self.moduleOrder + 1] = name
    end
    self.modules[name] = module
    return true
end

function Controller:CallModules(methodName, ...)
    for _, name in ipairs(self.moduleOrder) do
        local module = self.modules[name]
        local method = module and module[methodName]
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
    Project.sv.data = Project.sv.data or {}
    Project.sv.data.records = Project.sv.data.records or {}
end

function Controller:Initialize()
    if self.initialized then return end

    self:InitializeSavedVariables()
    Project.State:Initialize()
    self:CallModules("Initialize")

    if EVENT_PLAYER_ACTIVATED then
        Project.Events:Register("PlayerActivated", EVENT_PLAYER_ACTIVATED, function(...)
            self:OnPlayerActivated(...)
        end)
    end

    self.initialized = true
    Project.Diagnostics:Log("Initialized")
end

function Controller:OnPlayerActivated(...)
    self:CallModules("OnPlayerActivated", ...)
end

function Controller:Shutdown()
    self:CallModules("Shutdown")
    Project.Events:UnregisterAll()
    Project.State:Reset()
    self.initialized = false
end

function Project:NotifyChanged()
    local moduleId = self.Config and self.Config.module and self.Config.module.id
    if moduleId and LibSTARSConnect and type(LibSTARSConnect.NotifyDataChanged) == "function" then
        LibSTARSConnect:NotifyDataChanged(moduleId)
    end
end
