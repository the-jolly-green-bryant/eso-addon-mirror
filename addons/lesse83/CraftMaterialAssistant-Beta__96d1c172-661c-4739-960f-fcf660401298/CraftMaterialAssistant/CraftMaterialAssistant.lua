local CMA = CraftMaterialAssistant

-- Initialize Engine Hook
function CMA:Initialize(_, addOnName)
    if addOnName ~= self.name then return end 
    
    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

    -- load character-specific data
    self.dbCharSpecific = ZO_SavedVars:NewCharacterIdSettings(self.savedVarsName, self.variableVersion, nil, self.savedVarsDefaults)
    -- load account-wide data per default
    self.db = ZO_SavedVars:NewAccountWide(self.savedVarsName, self.variableVersion, nil, self.savedVarsDefaults)
    
    -- check if character has opted for individual settings
    if self.dbCharSpecific and self.dbCharSpecific.useCharacterSettings then
        -- opted for character settings - use them
		self.db = self.dbCharSpecific
	end

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
