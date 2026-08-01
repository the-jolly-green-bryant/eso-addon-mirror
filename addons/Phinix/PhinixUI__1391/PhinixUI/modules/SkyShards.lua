
function PUIAddon.SkyShards()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = SkyS_SavedVariables.Default[GetDisplayName()][tostring(GetCurrentCharacterId())]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	db.filters = {
		SkySMapPin_collected = false,
		SkySMapPin_unknown = true,
		SkySCompassPin_unknown = true,
	}
	db.pinTexture = {
		level = 200,
		size = 28,
		type = 1,
	}
	db.skillPanelDisplay = 1
	db.immersiveMode = 1
	db.mainworldSkyshards = "ffffff"
	db.compassMaxDistance = 0.0500000000

end
