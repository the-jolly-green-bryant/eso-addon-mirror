
local Settings = Harvest.settings
local CallbackManager = Harvest.callbackManager
local Events = Harvest.events

local FilterProfiles = {}
Harvest:RegisterModule("filterProfiles", FilterProfiles)

function FilterProfiles:Initialize()
	self.filterProfiles = Settings.savedVars.settings.filterProfiles
	-- sanity check. in case the chosen profile doesn't exist
	for _, displayType in pairs({"map", "compass", "world"}) do
		local tag = displayType .. "FilterProfile"
		if not self.filterProfiles[Settings.savedVars.settings[tag]] then
			self:Error("%s profile %d does not exist", displayType, Settings.savedVars.settings[tag])
			Settings.savedVars.settings[tag] = 1
		end
	end
	
	if not self.filterProfiles[1] then
		self:Error("there exists no default profile")
		self.filterProfiles[1] = self:ConstructNewProfile("default")
	end
end

function FilterProfiles:GetMapProfile()
	return self.filterProfiles[Settings.savedVars.settings.mapFilterProfile] 
end

function FilterProfiles:SetMapProfile(profile)
	for index, filterProfile in pairs(self.filterProfiles) do
		if filterProfile == profile then
			Settings.savedVars.settings.mapFilterProfile = index
			CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "mapFilterProfile", index)
			return
		end
	end
end

function FilterProfiles:GetCompassProfile()
	return self.filterProfiles[Settings.savedVars.settings.compassFilterProfile] 
end

function FilterProfiles:SetCompassProfile(profile)
	for index, filterProfile in pairs(self.filterProfiles) do
		if filterProfile == profile then
			Settings.savedVars.settings.compassFilterProfile = index
			CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "compassFilterProfile", index)
			return
		end
	end
end

function FilterProfiles:GetWorldProfile()
	return self.filterProfiles[Settings.savedVars.settings.worldFilterProfile] 
end

function FilterProfiles:SetWorldProfile(profile)
	for index, filterProfile in pairs(self.filterProfiles) do
		if filterProfile == profile then
			Settings.savedVars.settings.worldFilterProfile = index
			CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldFilterProfile", index)
			return
		end
	end
end

function FilterProfiles:ConstructNewProfile(newName)
	local newProfile = {}
	Harvest.CopyMissingDefaultValues(newProfile, Settings.defaultFilterProfile)
	newProfile.name = newName or "Unnamed Profile"
	return newProfile
end

function FilterProfiles:FindProfileWithName(name)
	for index, filterProfile in pairs(self.filterProfiles) do
		if filterProfile.name == name then
			return filterProfile
		end
	end
end
