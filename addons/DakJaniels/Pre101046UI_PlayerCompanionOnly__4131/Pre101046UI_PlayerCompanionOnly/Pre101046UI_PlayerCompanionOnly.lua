local eventManager = GetEventManager()

local Pre101046UI_PlayerCompanionOnly =
{
    AddonName = "Pre101046UI_PlayerCompanionOnly",
    AddonVersion = "3",
    isInitialized = false,
}

function Pre101046UI_PlayerCompanionOnly:TexturePlayerCompanionFrameOnly()
    if not HasActiveCompanion() and not HasPendingCompanion() then
        return
    end
    local ZO_CompanionUnitFramecompanionBackground = GetControl("ZO_CompanionUnitFramecompanion", "Background1")
    if ZO_CompanionUnitFramecompanionBackground == nil then
        return
    end
    local Right = ZO_CompanionUnitFramecompanionBackground:GetNamedChild("Right")
    local Left = ZO_CompanionUnitFramecompanionBackground:GetNamedChild("Left")
    if Right and Left then
        Right:SetTexture("Pre101046UI_PlayerCompanionOnly/unitframe_group_right.dds")
        Left:SetTexture("Pre101046UI_PlayerCompanionOnly/unitframe_group_left.dds")
    end
end

function Pre101046UI_PlayerCompanionOnly:Initialize()
    if self.isInitialized then
        return
    end

    --- @param eventId integer
    --- @param newState CompanionState
    --- @param oldState CompanionState
    eventManager:RegisterForEvent(self.AddonName, EVENT_ACTIVE_COMPANION_STATE_CHANGED, function (eventId, newState, oldState)
        self:TexturePlayerCompanionFrameOnly()
    end)


    self.isInitialized = true
end

function Pre101046UI_PlayerCompanionOnly:OnPlayerActivated()
    eventManager:UnregisterForEvent(self.AddonName, EVENT_PLAYER_ACTIVATED)
    self:Initialize()
end

function Pre101046UI_PlayerCompanionOnly:OnAddOnLoaded(eventId, addonName)
    if addonName ~= self.AddonName then
        return
    end

    eventManager:UnregisterForEvent(self.AddonName, EVENT_ADD_ON_LOADED)
    eventManager:RegisterForEvent(self.AddonName, EVENT_PLAYER_ACTIVATED, function ()
        self:OnPlayerActivated()
    end)
end

return eventManager:RegisterForEvent(Pre101046UI_PlayerCompanionOnly.AddonName, EVENT_ADD_ON_LOADED, function (...)
    Pre101046UI_PlayerCompanionOnly:OnAddOnLoaded(...)
end)
