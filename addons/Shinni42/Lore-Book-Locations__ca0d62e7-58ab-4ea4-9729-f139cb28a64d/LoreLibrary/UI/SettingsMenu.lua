
local SettingsMenu = {}
LoreLibrary:RegisterModule("settingsMenu", SettingsMenu)

--[[
Addon settings panel (keyboard and gamepad) via LibHarvensAddonSettings,
modeled on HarvestMapConsole's Options/LAMPanel.lua. Optional: if the library
isn't installed, this module simply does nothing.
]]--

function SettingsMenu:Initialize()
	if not LibHarvensAddonSettings then return end

	local options = {
		allowDefaults = true,
		allowRefresh = true,
	}
	local settings = LibHarvensAddonSettings:AddAddon("Lore Book Locations", options)
	settings.author = "Shinni"

	local worldEnabled = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "3D World Pins",
		default = true,
		setFunction = function(enabled) LoreLibrary.settings:Set("worldPinsEnabled", enabled) end,
		getFunction = function() return LoreLibrary.settings:Get("worldPinsEnabled") end,
	}
	settings:AddSetting(worldEnabled)

	local worldDistance = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "3D World Pin Distance",
		default = 250,
		min = 100,
		max = 1000,
		step = 50,
		format = "%d",
		unit = "m",
		setFunction = function(value) LoreLibrary.settings:Set("worldPinsDistance", value) end,
		getFunction = function() return LoreLibrary.settings:Get("worldPinsDistance") end,
	}
	settings:AddSetting(worldDistance)

	local compassEnabled = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = "Compass Pins",
		default = true,
		setFunction = function(enabled) LoreLibrary.settings:Set("compassPinsEnabled", enabled) end,
		getFunction = function() return LoreLibrary.settings:Get("compassPinsEnabled") end,
	}
	settings:AddSetting(compassEnabled)

	local compassDistance = {
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = "Compass Pin Distance",
		default = 300,
		min = 100,
		max = 2000,
		step = 100,
		format = "%d",
		unit = "m",
		setFunction = function(value) LoreLibrary.settings:Set("compassPinsDistance", value) end,
		getFunction = function() return LoreLibrary.settings:Get("compassPinsDistance") end,
	}
	settings:AddSetting(compassDistance)

	-- additional way to toggle the same per-pin-type filters as the map's own
	-- filter panel (see FilterMenu.lua); both read/write LoreLibrary.settings
	for _, pinTypeId in ipairs(LoreLibrary.PINTYPES) do
		local pinTypeFilter = {
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = LoreLibrary.pinTypeLabels[pinTypeId],
			default = true,
			setFunction = function(enabled) LoreLibrary.settings:SetPinTypeEnabled(pinTypeId, enabled) end,
			getFunction = function() return LoreLibrary.settings:IsPinTypeEnabled(pinTypeId) end,
		}
		settings:AddSetting(pinTypeFilter)
	end
end
