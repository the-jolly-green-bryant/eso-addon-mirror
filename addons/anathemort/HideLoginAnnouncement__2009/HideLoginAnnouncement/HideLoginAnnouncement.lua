HideLoginAnnouncement = {
    name = 'HideLoginAnnouncement'
}

function HideLoginAnnouncement:Initialize()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(...) self:OnPlayerActivated(...) end)

    self.announcementSceneName = 'marketAnnouncement'
    self.scene = nil
end

function HideLoginAnnouncement:OnAddonLoaded(event, addonName)
    if addonName == self.name then
        self:Initialize()
    end
end

function HideLoginAnnouncement:OnPlayerActivated(eventCode, initial)
    if initial then
        self.scene = SCENE_MANAGER:GetScene(self.announcementSceneName)
        self.scene:RegisterCallback('StateChange', self.OnSceneStateChange)

        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_PLAYER_ACTIVATED)
    end
end

function HideLoginAnnouncement.OnSceneStateChange(oldState, newState)
    if newState == SCENE_SHOWN then
        HideLoginAnnouncement.scene:PopStackFragmentGroup()
        HideLoginAnnouncement.scene:UnregisterCallback('StateChange', HideLoginAnnouncement.OnSceneStateChange)
    end
end

EVENT_MANAGER:RegisterForEvent(HideLoginAnnouncement.name, EVENT_ADD_ON_LOADED, function(...) HideLoginAnnouncement:OnAddonLoaded(...) end)
