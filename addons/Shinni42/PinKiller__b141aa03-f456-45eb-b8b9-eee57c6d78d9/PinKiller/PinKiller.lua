
PinKiller = PinKiller or {}

function PinKiller:IsFloatingMarkerEnabled(pinType)
	return not self.settings.disabledFloatingMarkerPinTypes[pinType]
end

function PinKiller:IsFloatingMarkerBreadcrumbEnabled(pinType)
	return not self.settings.disabledFloatingMarkerBreadcrumbPinTypes[pinType]
end

function PinKiller:IsCompassPinTypeEnabled(pinType)
	return not self.settings.disabledCompassPinTypes[pinType]
end

function PinKiller:IsMapPinGroupEnabled(pinTag)
	return not self.settings.disabledMapPinGroups[pinTag]
end

function PinKiller:IsAreaPinAnimationEnabled()
	return not self.settings.disableAreaAnimation
end

function PinKiller:LoadSettings()
	
	local defaultSettings = {
		disabledCompassPinTypes = {},
		disabledFloatingMarkerPinTypes = {},
		disabledFloatingMarkerBreadcrumbPinTypes = {},
		disabledMapPinGroups = {},
		disableAreaAnimation = false,
	}
	self.settings = ZO_SavedVars:New("PinKiller_SavedVariables", 3, "settings", defaultSettings)
	
	self:LoadVersion()
	if self.InitializeLAM then self:InitializeLAM() end
	if self.InitializeHAS then self:InitializeHAS() end
end

function PinKiller:LoadVersion()
	local AddOnManager = GetAddOnManager()
	PinKiller.version = ""
	for addonIndex = 1, AddOnManager:GetNumAddOns() do
		local name = AddOnManager:GetAddOnInfo(addonIndex)
		if name == "PinKiller" then
			local versionInt = AddOnManager:GetAddOnVersion(addonIndex)
			local rev = versionInt % 1000
			local version = zo_floor(versionInt / 1000) % 100
			local major = zo_floor(versionInt / 100000) % 100
			PinKiller.version = string.format("%d.%d", major, rev)
		end
	end
end

function OnAddonLoaded( _, addon )
	if addon ~= "PinKiller" then
		return
	end
	
	PinKiller:LoadSettings()
	PinKiller:InitializeCompassPins()
	PinKiller:InitializeMapPins()
end

EVENT_MANAGER:RegisterForEvent("PinKiller", EVENT_ADD_ON_LOADED , OnAddonLoaded)
