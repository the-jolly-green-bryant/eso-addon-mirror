local TT = TamrielicTongues

function TT:Initialize()
    self.SavedVariables:Initialize()
    self.Registry:Finalize()
    self.SavedVariables:InitializeKnowledge()
    self.Chat:Initialize()
    self.Commands:Initialize()
    self.Settings:Initialize()

    self:Print(TT.Locale:Get("LOADED", self.VERSION))
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= TT.ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(TT.ADDON_NAME, EVENT_ADD_ON_LOADED)
    TT:Initialize()
end

EVENT_MANAGER:RegisterForEvent(TT.ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
