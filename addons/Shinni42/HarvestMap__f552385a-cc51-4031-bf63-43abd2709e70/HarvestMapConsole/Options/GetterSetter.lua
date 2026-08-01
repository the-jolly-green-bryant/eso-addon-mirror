
local Settings = Harvest.settings

local CallbackManager = Harvest.callbackManager
local Events = Harvest.events


function Harvest.SetMapSpawnFilterEnabled(enabled)
	Settings.savedVars.settings.mapSpawnFilter = enabled
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "mapSpawnFilter", enabled)
end

function Harvest.IsMapSpawnFilterEnabled()
	return LibNodeDetection and Settings.savedVars.settings.mapSpawnFilter
end

function Harvest.SetMinimapSpawnFilterEnabled(enabled)
	Settings.savedVars.settings.minimapSpawnFilter = enabled
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "minimapSpawnFilter", enabled)
end

function Harvest.IsMinimapSpawnFilterEnabled()
	return LibNodeDetection and Settings.savedVars.settings.minimapSpawnFilter
end

function Harvest.SetCompassSpawnFilterEnabled(enabled)
	Settings.savedVars.settings.compassSpawnFilter = enabled
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "compassSpawnFilter", enabled)
end

function Harvest.IsCompassSpawnFilterEnabled()
	return LibNodeDetection and Settings.savedVars.settings.compassSpawnFilter
end

function Harvest.SetWorldSpawnFilterEnabled(enabled)
	Settings.savedVars.settings.worldSpawnFilter = enabled
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldSpawnFilter", enabled)
end

function Harvest.IsWorldSpawnFilterEnabled()
	return LibNodeDetection and Settings.savedVars.settings.worldSpawnFilter
end

function Harvest.AreMinimapPinsVisible()
	return Settings.savedVars.settings.displayMinimapPins
end

function Harvest.SetMinimapPinsVisible( value )
	Settings.savedVars.settings.displayMinimapPins = not not value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "minimapPinsVisible", value)
end

function Harvest.AreMapPinsVisible()
	return Settings.savedVars.settings.displayMapPins
end

function Harvest.SetMapPinsVisible( value )
	Settings.savedVars.settings.displayMapPins = not not value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "mapPinsVisible", value)
end

function Harvest.GetWorldBaseTexture()
	return Settings.savedVars.settings.worldBaseTexture
end

function Harvest.SetWorldBaseTexture(value)
	Settings.savedVars.settings.worldBaseTexture = value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldBaseTexture", value)
end

function Harvest.GetPinTypeTexture(pinTypeId)
	return Settings.savedVars.settings.pinLayouts[pinTypeId].texture
end

function Harvest.SetPinTypeTexture(pinTypeId, value)
	Settings.savedVars.settings.pinLayouts[pinTypeId].texture = value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "mapPinTexture", pinTypeId, value)
end

function Harvest.GetWorldPinHeight()
	return Settings.savedVars.settings.worldPinHeight
end

function Harvest.SetWorldPinHeight(height)
	Settings.savedVars.settings.worldPinHeight = height
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldPinHeight", height)
end

function Harvest.GetWorldPinWidth()
	return Settings.savedVars.settings.worldPinWidth
end

function Harvest.SetWorldPinWidth(width)
	Settings.savedVars.settings.worldPinWidth = width
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldPinHeight", width)
end

function Harvest.IsSeeThroughWallsEnabled()
	return not Harvest.DoWorldPinsUseDepth()
end

function Harvest.SetSeeThroughWallsEnabled(value)
	return Harvest.SetWorldPinsUseDepth(not value)
end

function Harvest.DoWorldPinsUseDepth()
	return Settings.savedVars.settings.worldPinDepth
end

function Harvest.SetWorldPinsUseDepth(value)
	Settings.savedVars.settings.worldPinDepth = not not value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldPinsUseDepth", value)
end

function Harvest.GetCompassDistance()
	return Settings.savedVars.settings.compassDistanceInMeters
end

function Harvest.SetCompassDistance( distance )
	Settings.savedVars.settings.compassDistanceInMeters = distance
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "compassDistance", distance)
end

function Harvest.GetWorldDistance()
	return Settings.savedVars.settings.worldDistanceInMeters
end

function Harvest.SetWorldDistance(distance)
	Settings.savedVars.settings.worldDistanceInMeters = distance
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldDistance", distance)
end

function Harvest.SetWorldPinsVisible(visible)
	Settings.savedVars.settings.displayWorldPins = not not visible
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "worldPinsVisible", visible)
end

function Harvest.AreWorldPinsVisible()
	return Settings.savedVars.settings.displayWorldPins
end

function Harvest.AreSettingsAccountWide()
	return Settings.savedVars.account.accountWideSettings
end

function Harvest.SetSettingsAccountWide( value )
	if Settings.savedVars.account.accountWideSettings ~= value then
		Settings.savedVars.account.accountWideSettings = value
		-- wanted to remove this, but it seems the require reload field in LAM doesn't work
		ReloadUI("ingame")
	end
end

function Harvest.GetMaxTimeDifference()
	return Settings.savedVars.global.maxTimeDifference
end

function Harvest.AreCompassPinsVisible()
	return Settings.savedVars.settings.displayCompassPins
end

function Harvest.SetCompassPinsVisible( value )
	Settings.savedVars.settings.displayCompassPins = not not value
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "compassPinsVisible", value)
end

function Harvest.GetMapPinLayout(pinTypeId)
	return Settings.savedVars.settings.pinLayouts[pinTypeId]
end

function Harvest.SetMapPinSize( pinTypeId, value )
	if pinTypeId == 0 then
		Settings.savedVars.settings.minimapPinSize = value
	else
		Settings.savedVars.settings.pinLayouts[ pinTypeId ].size = value
	end
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "pinTypeSize", pinTypeId, value)
end

function Harvest.SetPinColor( pinTypeId, r, g, b, a )
	Settings.savedVars.settings.pinLayouts[ pinTypeId ].tint:SetRGBA( r, g, b, a )
	CallbackManager:FireCallbacks(Events.SETTING_CHANGED, "pinTypeColor", pinTypeId, r, g, b, a)
end