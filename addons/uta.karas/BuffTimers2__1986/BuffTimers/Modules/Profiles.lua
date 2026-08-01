BuffTimers.defaultProfile = 'Default'

function BuffTimers:ProfileCreate(profileName, templateName)
  if (profileName ~= '') and (templateName ~= '') then
    local profileCreatable = true
    for k, v in pairs(self.profiles.profileNames) do
      if v == profileName then profileCreatable = false end
    end
    if profileCreatable then
      table.insert(self.profiles.profileNames, profileName)
      self.profiles.profileData[profileName] = {}
      ZO_DeepTableCopy(self.profiles.profileData[templateName], self.profiles.profileData[profileName])
      self:ProfileSort()
    end
  end
end

function BuffTimers:ProfileDelete(profileName)
  if profileName ~= BuffTimers.defaultProfile then
    local profileId = nil
    for k, v in pairs(self.profiles.profileNames) do
      if v == profileName then profileId = k end
    end
    if profileId then
      table.remove(self.profiles.profileNames, profileId)
      self.profiles.profileData[profileName] = nil
    end
    self:ProfileSort()
  end
end

function BuffTimers:ProfileLoad(profileName)
  if profileName then
    self.player.activeProfile = profileName
  end
  self.settings = self.profiles.profileData[self.player.activeProfile]
  if self.settings == nil then
    self.player.activeProfile = self.defaultProfile
    self.settings = self.profiles.profileData[self.player.activeProfile]
  end
end

function BuffTimers:ProfileSort()
  table.sort(self.profiles.profileNames)
end
