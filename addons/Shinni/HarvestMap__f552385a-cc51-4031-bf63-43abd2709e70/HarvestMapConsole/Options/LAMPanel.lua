
local Settings = Harvest.settings
local CallbackManager = Harvest.callbackManager
local Events = Harvest.events
local FilterProfiles = Harvest.filterProfiles

local function CreateFilter(pinTypeId)
	local checkbox = {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = GetString(SI_ADDON_MANAGER_ENABLED),
        default = Harvest.settings.defaultFilterProfile[pinTypeId],
        setFunction = function(enabled)
			local filterProfile = Harvest.mapFilterPanel.filterProfile
			filterProfile[pinTypeId] = enabled
			CallbackManager:FireCallbacks(Events.FILTER_PROFILE_CHANGED, filterProfile, pinTypeId, filterProfile[pinTypeId])
		end,
        getFunction = function() return Harvest.mapFilterPanel.filterProfile[pinTypeId] end,
    }
    return checkbox
end

local function getIndex(tbl, entry)
	for index, value in pairs(tbl) do
		if value == entry then return index end
	end
end

local function CreateIconPicker( pinTypeId )
	-- breaks when using "reset to defaults"
	local pinTypeId = pinTypeId
	local default = getIndex(Harvest.settings.availableTextures,
			Harvest.settings.defaultSettings.pinLayouts[pinTypeId].texture)
	assert(default)
	local filter = {
		type = LibHarvensAddonSettings.ST_ICONPICKER,
		label = Harvest.GetLocalization("pintexture"),
		getFunction = function()
			local index = getIndex(Harvest.settings.availableTextures,
				Harvest.GetPinTypeTexture(pinTypeId) )
			return index or default
		end,
		setFunction = function(control, index, icon)
			Harvest.SetPinTypeTexture(pinTypeId, icon)
		end,
		items = Harvest.settings.availableTextures,
		default = default,
	}
	return filter
end

local function CreateSizeSlider( pinTypeId )
	local pinTypeId = pinTypeId
	local slider = {
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = Harvest.GetLocalization("pinsize"),
        --tooltip = Harvest.GetLocalization("pinsizetooltip"),
        setFunction = function(newSize)
			Harvest.SetMapPinSize(pinTypeId, newSize)
		end,
        getFunction = function()
			return Harvest.GetMapPinLayout(pinTypeId).size
		end,
        default = Harvest.settings.defaultSettings.pinLayouts[pinTypeId].size,
        min = 8,
		max = 64,
        step = 1,
        format = "%d", --value format
    }
    return slider
end

local function CreateColorPicker(pinTypeId)
	local pinTypeId = pinTypeId
	local color = {
        type = LibHarvensAddonSettings.ST_COLOR,
        label = Harvest.GetLocalization("pincolor"),
        --tooltip = zo_strformat(Harvest.GetLocalization( "pincolortooltip" ), Harvest.GetLocalization( "pintype" .. pinTypeId)),
        setFunction = function(r, g, b, a) Harvest.SetPinColor(pinTypeId, r, g, b, a) end,
        getFunction = function() return Harvest.GetMapPinLayout(pinTypeId).tint:UnpackRGBA() end,
        default = {Harvest.settings.defaultSettings.pinLayouts[ pinTypeId ].tint:UnpackRGBA()},
    }
	return color
end

function Settings:InitializeLAM()
	-- first LAM stuff, at the end of this function we will also create
	-- a custom checkbox in the map's filter menu for the heat map
	local options = {
		allowDefaults = true,
		allowRefresh = true,
	}
	
	local settings = LibHarvensAddonSettings:AddAddon("HarvestMap", options)
	settings.author = "Shinni"
	settings.version = "Console version " .. Harvest.displayVersion
	
	local checkbox = {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = Harvest.GetLocalization("mappins"),
        default = Harvest.settings.defaultSettings.displayMapPins,
		setFunction = Harvest.SetMapPinsVisible,
        getFunction = Harvest.AreMapPinsVisible,
    }
	settings:AddSetting(checkbox)
	
	local checkbox = {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = Harvest.GetLocalization("minimappins"),
        default = Harvest.settings.defaultSettings.displayMinimapPins,
		setFunction = Harvest.SetMinimapPinsVisible,
        getFunction = Harvest.AreMinimapPinsVisible,
		tooltip = Harvest.GetLocalization("minimappinstooltip2"),
    }
	settings:AddSetting(checkbox)
	
	local checkbox = {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = Harvest.GetLocalization("compass"),
        default = Harvest.settings.defaultSettings.displayCompassPins,
		setFunction = Harvest.SetCompassPinsVisible,
        getFunction = Harvest.AreCompassPinsVisible,
    }
	settings:AddSetting(checkbox)
	
	local checkbox = {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = Harvest.GetLocalization("worldpins"),
        default = Harvest.settings.defaultSettings.displayWorldPins,
		setFunction = Harvest.SetWorldPinsVisible,
        getFunction = Harvest.AreWorldPinsVisible,
    }
	settings:AddSetting(checkbox)
	
	--[[
	local checkbox = {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = Harvest.GetLocalization("seethroughwalls"),
        tooltip = Harvest.GetLocalization("seethroughwallstooltip"),
        default = not Harvest.settings.defaultSettings.worldPinDepth,
        setFunction = Harvest.SetSeeThroughWallsEnabled,
        getFunction = Harvest.IsSeeThroughWallsEnabled,
        disable = IsWorldDisabled,
    }
    settings:AddSetting(checkbox)
	]]--
	local section = {
        type = LibHarvensAddonSettings.ST_SECTION,
        label = Harvest.GetLocalization("spawnfilter"),
    }
    settings:AddSetting(section)
	
	if not LibNodeDetection then
		local label = {
			type = LibHarvensAddonSettings.ST_LABEL,
			label = ZO_ERROR_COLOR:Colorize(Harvest.GetLocalization("nodedetectionmissing")),
		}
		settings:AddSetting(label)
	end
	
	local checkbox = {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = Harvest.GetLocalization("spawnfilter_map"),
        default = Harvest.settings.defaultSettings.mapSpawnFilter,
        setFunction = Harvest.SetMapSpawnFilterEnabled,
        getFunction = Harvest.IsMapSpawnFilterEnabled,
		tooltip = Harvest.GetLocalization("spawnfilterdescription"),
        disable = function() return (LibNodeDetection == nil) end,
    }
    settings:AddSetting(checkbox)
	
	local checkbox = {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = Harvest.GetLocalization("spawnfilter_minimap"),
        default = Harvest.settings.defaultSettings.minimapSpawnFilter,
        setFunction = Harvest.SetMinimapSpawnFilterEnabled,
        getFunction = Harvest.IsMinimapSpawnFilterEnabled,
		tooltip = Harvest.GetLocalization("spawnfilterdescription"),
        disable = function() return (LibNodeDetection == nil) end,
    }
    settings:AddSetting(checkbox)
	
	local checkbox = {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = Harvest.GetLocalization("spawnfilter_compass"),
        default = Harvest.settings.defaultSettings.compassSpawnFilter,
        setFunction = Harvest.SetCompassSpawnFilterEnabled,
        getFunction = Harvest.IsCompassSpawnFilterEnabled,
		tooltip = Harvest.GetLocalization("spawnfilterdescription"),
        disable = function() return (LibNodeDetection == nil) end,
    }
    settings:AddSetting(checkbox)
	
	local checkbox = {
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = Harvest.GetLocalization("spawnfilter_world"),
        default = Harvest.settings.defaultSettings.worldSpawnFilter,
        setFunction = Harvest.SetWorldSpawnFilterEnabled,
        getFunction = Harvest.IsWorldSpawnFilterEnabled,
		tooltip = Harvest.GetLocalization("spawnfilterdescription"),
        disable = function() return (LibNodeDetection == nil) end,
    }
    settings:AddSetting(checkbox)
	
	--[[
	#####
	#####  PIN OPTIONS
	#####
	--]]
	local options = {
		allowDefaults = true,
		allowRefresh = true,
	}
	local settings = LibHarvensAddonSettings:AddAddon("HarvestMap " .. Harvest.GetLocalization("pinoptions"), options)
	
	
	local defaultBaseTexture = getIndex(Harvest.settings.availableWorldBaseTextures,
			Harvest.settings.defaultSettings.worldBaseTexture)
	assert(defaultBaseTexture)
	local texturePicker = {
		type = LibHarvensAddonSettings.ST_ICONPICKER,
		label = Harvest.GetLocalization("worldBaseTexture"),
		getFunction = function()
			local index = getIndex(Harvest.settings.availableWorldBaseTextures,
				Harvest.GetWorldBaseTexture() )
			return index or defaultBaseTexture
		end,
		setFunction = function(control, index, icon)
			Harvest.SetWorldBaseTexture(icon)
		end,
		items = Harvest.settings.availableWorldBaseTextures,
		default = defaultBaseTexture,
	}
	settings:AddSetting(texturePicker)
	
	for _, pinTypeId in ipairs(Harvest.PINTYPES) do
		if not Harvest.HIDDEN_PINTYPES[pinTypeId] then
			local section = {
				type = LibHarvensAddonSettings.ST_SECTION,
				label = Harvest.GetLocalization( "pintype" .. pinTypeId )
			}
			settings:AddSetting(section)
			settings:AddSetting(CreateFilter(pinTypeId))
			settings:AddSetting(CreateColorPicker(pinTypeId))
			--settings:AddSetting(CreateIconPicker(pinTypeId))
			--settings:AddSetting(CreateSizeSlider(pinTypeId))
		end
	end
	
end
