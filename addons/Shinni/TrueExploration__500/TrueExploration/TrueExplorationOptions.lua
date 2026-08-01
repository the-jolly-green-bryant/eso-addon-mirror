function TrueExplor.setupOptions()
	
	local AddOnManager = GetAddOnManager()
	local displayVersion = ""
	for addonIndex = 1, AddOnManager:GetNumAddOns() do
		local name = AddOnManager:GetAddOnInfo(addonIndex)
		if name == "TrueExploration" then
			local versionInt = AddOnManager:GetAddOnVersion(addonIndex)
			local rev = versionInt % 100
			local version = zo_floor(versionInt / 100) % 100
			displayVersion = string.format("%d.%d", version, rev)
		end
	end
	
	local panelData = {
		type = "panel",
		name = "TrueExploration",
		author = "Shinni",
		version = displayVersion,
		registerForDefaults = true,
	}
	
	local lang = TrueExplor.lang
	
	local optionsTable = {
		--{
		--	type = "button",
		--	name = "Replace with pre 1.3 data",
		--	tooltip = "Resets the Addon with the data from before the 1.3 patch.",
		--	func = function()
		--		TE_SavedVars["Default"][GetDisplayName()] = TE_SavedVars["Default"][""]
		--		ReloadUI("ingame")
		--	end,
		--	width = "full",	--or "half" (optional)
		--	warning = "Will Reload UI. This process will replace the data and is irreversible!",	--(optional)
		--},
		{
			type = "description",
			title = lang.chatCommands,
			text = lang.chatCommandsDesc,
			width = "full"
		},
		{
			type = "header",
			name = lang.radiusSetting,
			width = "full",	--or "half" (optional)
		},
		--[[
		[2] = {
			type = "dropdown",
			name = "Number of tiles",
			tooltip = "Number of divisions in with and height direction of the map.",
			choices = {16, 24, 48, 72, 96},
			getFunc = function() return TrueExplor.units end,
			setFunc = function(var) TrueExplor.units = var end,
			width = "full",
			warning = "You already discovered data is only compatible to its own 'Number of Tiles' setting.\n"..
			"Changing this value will clear the maps, but changing it back to the previous setting will show your previous discoveries again.\n"..
			"This value greatly influences the filesize and the performance while the map is viewed!",
		default = 48,
		},
		--]]
		{
			type = "slider",
			name = lang.dungeonRadius,
			tooltip = lang.dungeonRadiusDesc,
			min = 1,
			max = 16,
			step = 1,
			getFunc = function() return TrueExplor.radius[768] end,
			setFunc = function(value) TrueExplor.radius[768] = value end,
			width = "half",
			default = 4,
		},
		{
			type = "slider",
			name = lang.townRadius,
			tooltip = lang.townRadiusDesc,
			min = 1,
			max = 16,
			step = 1,
			getFunc = function() return TrueExplor.radius[1280] end,
			setFunc = function(value) TrueExplor.radius[1280] = value end,
			width = "half",
			default = 3,
		},
		{
			type = "slider",
			name = lang.islandRadius,
			tooltip = lang.islandRadiusDesc,
			min = 1,
			max = 16,
			step = 1,
			getFunc = function() return TrueExplor.radius[1536] end,
			setFunc = function(value) TrueExplor.radius[1536] = value end,
			width = "half",
			default = 2,
		},
		{
			type = "slider",
			name = lang.zoneRadius,
			tooltip = lang.zoneRadiusDesc,
			min = 1,
			max = 16,
			step = 1,
			getFunc = function() return TrueExplor.radius[2048] end,
			setFunc = function(value) TrueExplor.radius[2048] = value end,
			width = "half",
			default = 1,
		},
		{
			type = "slider",
			name = lang.cyrodiilRadius,
			tooltip = lang.cyrodiilRadiusDesc,
			min = 1,
			max = 16,
			step = 1,
			getFunc = function() return TrueExplor.radius[5120] end,
			setFunc = function(value) TrueExplor.radius[5120] = value end,
			width = "half",
			default = 1,
		},
		{
			type = "header",
			name = lang.mapTypes,
			width = "full",	--or "half" (optional)
		},
		{
			type = "checkbox",
			name = lang.zone,
			tooltip = lang.zoneDesc,
			getFunc = function() return not TrueExplor.contains(TrueExplor.dontHideMapTypes, MAPTYPE_ZONE) end,
			setFunc = function(value)
				local key = TrueExplor.contains(TrueExplor.dontHideMapTypes, MAPTYPE_ZONE)
				if value and key then
				table.remove(TrueExplor.dontHideMapTypes, key)
				elseif not key then
				table.insert(TrueExplor.dontHideMapTypes, MAPTYPE_ZONE)
				end
			end,
			width = "half",	--or "half" (optional)
			default = true,
		},
		{
		type = "checkbox",
			name = lang.subzone,
			tooltip =  lang.subzoneDesc,
			getFunc = function() return not TrueExplor.contains(TrueExplor.dontHideMapTypes, MAPTYPE_SUBZONE) end,
			setFunc = function(value)
				local key = TrueExplor.contains(TrueExplor.dontHideMapTypes, MAPTYPE_SUBZONE)
				if value and key then
				table.remove(TrueExplor.dontHideMapTypes, key)
				elseif not key then
				table.insert(TrueExplor.dontHideMapTypes, MAPTYPE_SUBZONE)
				end
			end,
			width = "half",	--or "half" (optional)
			default = true,
		},
		{
			type = "header",
			name = lang.graphicSettings,
			width = "full",	--or "half" (optional)
		},
		{
			type = "slider",
			name = lang.discovered,
			tooltip = lang.discoveredDesc,
			min = 0,
			max = 255,
			step = 1,
			getFunc = function() return zo_round(TrueExplor.discoveredColor[4] * 255) end,
			setFunc = function(value) TrueExplor.discoveredColor[4] = value / 255 end,
			width = "half",
			default = 0,
		},
		{
			type = "slider",
			name = lang.undiscovered,
			tooltip = lang.undiscoveredDesc,
			min = 0,
			max = 255,
			step = 1,
			getFunc = function() return zo_round(TrueExplor.undiscoveredColor[4] * 255) end,
			setFunc = function(value) TrueExplor.undiscoveredColor[4] = value / 255 end,
			width = "half",
			default = 255,
		},
	}

	LibAddonMenu2:RegisterAddonPanel("TrueExplorationOptions", panelData)
	LibAddonMenu2:RegisterOptionControls("TrueExplorationOptions", optionsTable)
end
