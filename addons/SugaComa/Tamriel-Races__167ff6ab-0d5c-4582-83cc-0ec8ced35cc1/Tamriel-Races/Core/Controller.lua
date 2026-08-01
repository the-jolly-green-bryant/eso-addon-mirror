TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.Controller = TR.Controller or {}
local Controller = TR.Controller

Controller.initialized = false
Controller.modules = Controller.modules or {}

function Controller:RegisterModule(name, module)
    if type(name) ~= "string" or type(module) ~= "table" then
        TR.Diagnostics:Warn("Invalid module registration")
        return false
    end
    if self.modules[name] then
        TR.Diagnostics:Warn("Duplicate module registration: " .. name)
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
                TR.Diagnostics:Warn(string.format("%s.%s failed: %s", name, methodName, tostring(err)))
            end
        end
    end
end

function Controller:InitializeSavedVariables()
    TR.sv = ZO_SavedVars:NewAccountWide(
        TR.Config.savedVariablesName,
        TR.Config.savedVariablesVersion,
        nil,
        TR.Defaults
    )

    TR.sv.loaded = (tonumber(TR.sv.loaded) or 0) + 1
    TR.sv.settings = TR.sv.settings or {}
    if TR.sv.settings.diagnostics == nil then
        TR.sv.settings.diagnostics = false
    end
end

function Controller:Initialize()
    if self.initialized then return end

    self:InitializeSavedVariables()
    TR.State:Initialize()

    math.randomseed(GetTimeStamp and GetTimeStamp() or 1)

    self:CallModules("Initialize")
    self.initialized = true
    TR.Diagnostics:Log("Core framework initialized", true)
end

function Controller:ShutdownRace(reason)
    self:CallModules("ShutdownRace", reason)
    TR.State:ResetTransient()
    TR.Diagnostics:Log("Race state cleared: " .. tostring(reason or "unspecified"))
end

function Controller:OnPlayerActivated()
    self:CallModules("OnPlayerActivated")
end
