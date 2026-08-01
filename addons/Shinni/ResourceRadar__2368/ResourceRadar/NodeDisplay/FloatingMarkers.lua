
local Settings, Textures
local Floating = {}
ResourceRadar:RegisterModule("floating", Floating)

function Floating:Initialize()
	Settings = ResourceRadar.settings
	Textures = ResourceRadar.textures
	
	local relatedSettings = {
		--displayNodesInWorld = true,
		worldPinSize = true,
		worldPinPulse = true,
		--worldPinTexture = true,
	}
	
	if Settings.displayNodesInWorld then
		self.texture = Settings.worldPinTexture
	else
		self.texture = Textures.emptyTexture
	end
	
	Settings:RegisterCallback(function(setting, ...)
		if relatedSettings[setting] then
			self:RefreshLayout(setting)
		end
	end)
	
	-- if we set a texture first, then the game crashes
	EVENT_MANAGER:RegisterForEvent("ResourceRadar-FloatingMarker", EVENT_PLAYER_ACTIVATED, function()
		self:RefreshLayout()
	end)
end

function Floating:RefreshLayout(triggeredBySetting)
	SetFloatingMarkerInfo(MAP_PIN_TYPE_HARVEST_NODE,
			Settings.worldPinSize,
			self.texture,
			self.texture,
			Settings.worldPinPulse)
end

