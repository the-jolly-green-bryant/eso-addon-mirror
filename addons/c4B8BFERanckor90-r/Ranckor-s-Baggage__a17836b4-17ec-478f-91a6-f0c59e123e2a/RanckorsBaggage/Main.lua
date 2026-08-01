local RB = RanckorsBaggage

function RB:RegisterSlashCommands()
    SLASH_COMMANDS["/rb"] = function()
        self:ToggleWindow()
    end

    SLASH_COMMANDS["/rbclear"] = function()
        self:SetBackgroundStyle("clear")
    end

    SLASH_COMMANDS["/rbdark"] = function()
        self:SetBackgroundStyle("dark")
    end
end

function RB:Initialize()
    self:CreateUI()
    self:RegisterEvents()
    self:RegisterSlashCommands()
    self:CreateSettings()
end

function RB:OnRanckorsBaggageLoaded(_, addonName)
    if addonName ~= self.name then return end

    EVENT_MANAGER:UnregisterForEvent(self.namespace, EVENT_ADD_ON_LOADED)

    self:InitializeSavedVars()
    self:Initialize()
end

EVENT_MANAGER:RegisterForEvent(RanckorsBaggage.namespace, EVENT_ADD_ON_LOADED, function(...)
    RanckorsBaggage:OnRanckorsBaggageLoaded(...)
end)