local CMA = CraftMaterialAssistant

-- Initialize Engine Hook
function CMA:Initialize(_, addOnName)
    if addOnName ~= self.name then return end 
    
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

    self.db = ZO_SavedVars:NewAccountWide(self.savedVarsName, self.variableVersion, nil, self.savedVarsDefaults)
    self:CreateSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(
        self.name,
        EVENT_OPEN_BANK,
        function(...)
            self:OnBankOpen(...)
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.name,
        EVENT_CLOSE_BANK,
        function(...)
            self:OnBankClosed(...)
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.name,
        EVENT_OPEN_STORE,
        function(...)
            self:OnStoreOpen(...)
        end
    )
end

EVENT_MANAGER:RegisterForEvent(
    CraftMaterialAssistant.name,
    EVENT_ADD_ON_LOADED,
    function(...)
        CraftMaterialAssistant:Initialize(...)
    end
)
