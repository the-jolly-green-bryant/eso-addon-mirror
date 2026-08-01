
local Menu = {}
TrueExplor = TrueExplor or {}
TrueExplor.menu = Menu

function Menu:LoadAddonInfo(addonName)
	local AddOnManager = GetAddOnManager()
	local displayVersion = ""
	for addonIndex = 1, AddOnManager:GetNumAddOns() do
		local name, title, author = AddOnManager:GetAddOnInfo(addonIndex)
		if name == addonName then
			local versionInt = AddOnManager:GetAddOnVersion(addonIndex)
			local rev = versionInt % 100
			local version = zo_floor(versionInt / 100) % 100
			self.displayVersion = string.format("%d.%d", version, rev)
			self.author = author
			self.displayName = title
		end
	end
end

function Menu:Initialize()
	self:LoadAddonInfo("TrueExploration")
	
	local panelData = {
		type = "panel",
		name = self.displayName,
		author = self.author,
		version = self.displayVersion,
		registerForDefaults = true,
	}
	
	local lang = TrueExplor.lang
	
	local optionsTable = setmetatable({}, { __index = table })
	
	optionsTable:insert({
		type = "header",
		name = lang.radiusSetting,
		width = "full",	--or "half" (optional)
	})
	
	local mapTypes = { "dungeon", "town", "island", "zone", "cyrodiil" }
	local mapSizes = {  768,       1280,   1536,     2048,   5120     }
	for i, mapType in pairs(mapTypes) do
		local size = mapSizes[i]
		optionsTable:insert({
			type = "slider",
			name = lang[mapType .. "Radius"],
			tooltip = lang[mapType .. "RadiusDesc"],
			min = 1,
			max = 7,
			step = 1,
			getFunc = function() return TrueExplor.settings.radiusForMapSize[size]+1 end,
			setFunc = function(value)
				TrueExplor.settings.radiusForMapSize[size] = value-1
				TrueExplor:Refresh()
			end,
			width = "half",
			default = TrueExplor.defaultSettings.radiusForMapSize[size],
		})
	end
	
	optionsTable:insert({
		type = "header",
		name = lang.mapTypes,
		width = "full",	--or "half" (optional)
	})
		
	optionsTable:insert({
		type = "checkbox",
		name = lang.zone,
		--tooltip = lang.zoneDesc,
		getFunc = function() return not TrueExplor.settings.dontHideMapTypes[MAPTYPE_ZONE] end,
		setFunc = function(value)
			TrueExplor.settings.dontHideMapTypes[MAPTYPE_ZONE] = not value
			TrueExplor:Refresh()
		end,
		width = "half",	--or "half" (optional)
		default = true,
	})
	
	optionsTable:insert({
		type = "checkbox",
		name = lang.subzone,
		--tooltip =  lang.subzoneDesc,
		getFunc = function() return not TrueExplor.settings.dontHideMapTypes[MAPTYPE_SUBZONE] end,
		setFunc = function(value)
			TrueExplor.settings.dontHideMapTypes[MAPTYPE_SUBZONE] = not value
			TrueExplor:Refresh()
		end,
		width = "half",	--or "half" (optional)
		default = true,
	})
	optionsTable:insert({
		type = "header",
		name = lang.graphicSettings,
		width = "full",	--or "half" (optional)
	})
	optionsTable:insert({
		type = "slider",
		name = lang.discovered,
		tooltip = lang.discoveredDesc,
		min = 0,
		max = 255,
		step = 1,
		getFunc = function() return zo_round(TrueExplor.settings.discoveredColor[4] * 255) end,
		setFunc = function(value) 
			TrueExplor.settings.discoveredColor[4] = value / 255
			TrueExplor:MarkForRefresh()
		end,
		width = "half",
		default = 0,
	})
	
	optionsTable:insert({
		type = "slider",
		name = lang.undiscovered,
		tooltip = lang.undiscoveredDesc,
		min = 0,
		max = 255,
		step = 1,
		getFunc = function() return zo_round(TrueExplor.settings.undiscoveredColor[4] * 255) end,
		setFunc = function(value) 
			TrueExplor.settings.undiscoveredColor[4] = value / 255
			TrueExplor:MarkForRefresh()
		end,
		width = "half",
		default = 255,
	})
	
	optionsTable:insert({
		type = "header",
		name = lang.init,
		width = "full",	--or "half" (optional)
	})
	
	optionsTable:insert({
		type = "checkbox",
		name = lang.retroactive,
		tooltip = lang.retroactiveDec,
		getFunc = function() return TrueExplor.settings.retroactive end,
		setFunc = function(value)
			TrueExplor.settings.retroactive = value
			TrueExplor:Refresh()
		end,
		width = "half",	--or "half" (optional)
		default = TrueExplor.defaultSettings.retroactive,
	})
	
	optionsTable:insert({
		type = "description",
		title = nil,
		text = lang.resetLabel,
		width = "full"
	})
	
	if false then --not IsConsoleUI() then
		LibAddonMenu2:RegisterAddonPanel("TrueExplorationOptions", panelData)
		LibAddonMenu2:RegisterOptionControls("TrueExplorationOptions", optionsTable)
	else
		local options = {
			allowDefaults = true,
			allowRefresh = true,
		}
		local settings = LibHarvensAddonSettings:AddAddon(panelData.name, options)
		settings.author = panelData.author
		settings.version = panelData.version
		
		local LAMtoHAS = {
			slider = LibHarvensAddonSettings.ST_SLIDER,
			header = LibHarvensAddonSettings.ST_SECTION,
			checkbox = LibHarvensAddonSettings.ST_CHECKBOX,
			description = LibHarvensAddonSettings.ST_LABEL
		}
		
		for i, entry in ipairs(optionsTable) do
			local newType = LAMtoHAS[entry.type]
			if newType then
				local newOption = {
					type = newType,
					label = entry.name or entry.text,
					default = entry.default,
					setFunction = entry.setFunc,
					getFunction = entry.getFunc,
					tooltip = entry.tooltip,
					min = entry.min,
					max = entry.max,
					step = entry.step,
					canSelect = true,
				}
				settings:AddSetting(newOption)
			end
		end
		
	end
end
