
if not IsConsoleUI() then return end

PinKiller = PinKiller or {}

function PinKiller:InitializeHAS()
	
	local function getCompassCheckboxWithTextureList(pinType, textureList)
		local pinTypeName = self.strings.PIN_TYPE_NAMES[pinType]
		local textureLabel = ""
		for _, texture in ipairs(textureList) do
			textureLabel = textureLabel .. zo_iconFormat(texture, 40, 40)
		end
		pinTypeName = textureLabel .. "\n" .. pinTypeName
		local checkbox = {
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = pinTypeName,
			getFunction = function() return not self.settings.disabledCompassPinTypes[pinType] end,
			setFunction = function(value)
				self.settings.disabledCompassPinTypes[pinType] = not value
				self:RefreshCompassPinSettings(pinType)
			end,
			default = true,
		}
		return checkbox
	end
	
	local function getCompassCheckbox(pinType)
		local pinTypeName = self.strings.PIN_TYPE_NAMES[pinType]
		if PinKiller.floatingMarkerInfoArguments[pinType] then
			local texture = PinKiller.floatingMarkerInfoArguments[pinType][2] or ""
			pinTypeName = zo_iconFormat(texture, 40, 40) .. pinTypeName
		end
		local checkbox = {
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = pinTypeName,
			getFunction = function() return not self.settings.disabledCompassPinTypes[pinType] end,
			setFunction = function(value)
				self.settings.disabledCompassPinTypes[pinType] = not value
				self:RefreshCompassPinSettings(pinType)
			end,
			default = true,
		}
		return checkbox
	end

	local function getFloatingCheckbox(pinType, isBreadcrumb)
		local texture = PinKiller.floatingMarkerInfoArguments[pinType][2]
		local pinTypeName = self.strings.PIN_TYPE_NAMES[pinType]
		local settingsTable
		if isBreadcrumb then
			settingsTable = self.settings.disabledFloatingMarkerBreadcrumbPinTypes
			texture = PinKiller.floatingMarkerInfoArguments[pinType][3]
		else
			settingsTable = self.settings.disabledFloatingMarkerPinTypes
		end
		
		local checkbox = {
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = zo_iconFormatInheritColor(texture or "", 40, 40) .. pinTypeName,
			getFunction = function() return not settingsTable[pinType] end,
			setFunction = function(value)
				settingsTable[pinType] = not value
				self:RefreshFloatingMarkerInfo(pinType)
			end,
			default = true,
		}
		return checkbox
	end
	
	
	--local settings = LibHarvensAddonSettings:AddAddon("PinKiller: " .. self.strings.MAP_HEADER, options)
	
	local consolePanels = {
		GAMEPAD_WORLD_MAP_FILTERS.pvePanel,
		GAMEPAD_WORLD_MAP_FILTERS.pvpPanel,
		GAMEPAD_WORLD_MAP_FILTERS.imperialPvPPanel}
		
	for _, panel in pairs(consolePanels) do
		SecurePostHook(panel, "PreBuildControls", function(panel)
			panel:AddPinFilterCheckBox(MAP_FILTER_QUESTS, function() WORLD_MAP_QUEST_BREADCRUMBS:RefreshAllQuests() end)
		end)
	end
	
	
	local options = {
		allowDefaults = true,
		allowRefresh = true,
	}
	local settings = LibHarvensAddonSettings:AddAddon("PinKiller: " .. self.strings.COMPASS_HEADER, options)
	settings.author = "Shinni"
	settings.version = self.version
	
	local checkbox = {
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = zo_iconFormat("/esoui/art/mappins/map_areapin_32.dds", 32, 32) .. " " .. self.strings.AREA_ANIMATION,
		getFunction = function() return not self.settings.disableAreaAnimation end,
		setFunction = function(value) self.settings.disableAreaAnimation = not value end,
		default = true,
	}
	settings:AddSetting(checkbox)
	
	local seenPOItextures = {
		"/esoui/art/icons/poi/poi_areaofinterest_incomplete.dds",
		"/esoui/art/icons/poi/poi_delve_incomplete.dds",
		"/esoui/art/icons/poi/poi_town_incomplete.dds",
		"/esoui/art/icons/poi/poi_wayshrine_incomplete.dds",
		"/esoui/art/icons/poi/poi_portal_incomplete.dds",
		"/esoui/art/icons/poi/poi_groupboss_incomplete.dds",
		"/esoui/art/icons/poi/poi_mundus_incomplete.dds",
	}
	local completePOItextures = {
		"/esoui/art/icons/poi/poi_areaofinterest_complete.dds",
		"/esoui/art/icons/poi/poi_delve_complete.dds",
		"/esoui/art/icons/poi/poi_town_complete.dds",
		"/esoui/art/icons/poi/poi_wayshrine_complete.dds",
		"/esoui/art/icons/poi/poi_portal_complete.dds",
		"/esoui/art/icons/poi/poi_groupboss_complete.dds",
		"/esoui/art/icons/poi/poi_mundus_complete.dds",
	}
	settings:AddSetting(getCompassCheckboxWithTextureList(MAP_PIN_TYPE_POI_SEEN, seenPOItextures))
	settings:AddSetting(getCompassCheckboxWithTextureList(MAP_PIN_TYPE_POI_COMPLETE, completePOItextures))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_TIMELY_ESCAPE_NPC))
	--settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_DARK_BROTHERHOOD_TARGET))
	
	local section = {
        type = LibHarvensAddonSettings.ST_SECTION,
        label = self.strings.QUEST_HEADER,
    }
    settings:AddSetting(section)
	
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_QUEST_OFFER))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_ENDING))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_QUEST_CONDITION))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_QUEST_ENDING))
	
	local section = {
        type = LibHarvensAddonSettings.ST_SECTION,
        label = self.strings.ZONE_STORY_QUEST_HEADER,
    }
    settings:AddSetting(section)
	
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_QUEST_OFFER_ZONE_STORY))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING))
	
	local section = {
        type = LibHarvensAddonSettings.ST_SECTION,
        label = self.strings.REPEATABLE_QUEST_HEADER,
    }
    settings:AddSetting(section)
	
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION))
	settings:AddSetting(getCompassCheckbox(MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING))
	
	
	local settings = LibHarvensAddonSettings:AddAddon("PinKiller: " .. self.strings.FLOATING_MARKER_HEADER, options)
	settings.author = "Shinni"
	settings.version = self.version
	
	local isBreadcrumb = true
	local isNotBreadcrumb = false
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_TIMELY_ESCAPE_NPC, isNotBreadcrumb, "full"))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_DARK_BROTHERHOOD_TARGET, isNotBreadcrumb, "full"))
	
	
	local section = {
        type = LibHarvensAddonSettings.ST_SECTION,
        label = self.strings.QUEST_HEADER,
    }
    settings:AddSetting(section)
	
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_OFFER, isNotBreadcrumb, "full"))
	
	--[[
	submenuTable:insert({
		type = "description",
		text = self.strings.FLOATING_NORMAL,
		width = "half",
	})
	
	submenuTable:insert({
		type = "description",
		text = self.strings.FLOATING_BREADCRUMB,
		width = "half",
	})
	--]]
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_ENDING, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_ENDING, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_CONDITION, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_CONDITION, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_ENDING, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_ENDING, isBreadcrumb))
	
	local section = {
        type = LibHarvensAddonSettings.ST_SECTION,
        label = self.strings.ZONE_STORY_QUEST_HEADER,
    }
    settings:AddSetting(section)
	
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_OFFER_ZONE_STORY, isNotBreadcrumb, "full"))
	
	--[[
	submenuTable:insert({
		type = "description",
		text = self.strings.FLOATING_NORMAL,
		width = "half",
	})
	
	submenuTable:insert({
		type = "description",
		text = self.strings.FLOATING_BREADCRUMB,
		width = "half",
	})
	]]--
	
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING, isBreadcrumb))
	
	
	local section = {
        type = LibHarvensAddonSettings.ST_SECTION,
        label = self.strings.REPEATABLE_QUEST_HEADER,
    }
    settings:AddSetting(section)
	
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE, isNotBreadcrumb, "full"))
	--[[
	submenuTable:insert({
		type = "description",
		text = self.strings.FLOATING_NORMAL,
		width = "half",
	})
	
	submenuTable:insert({
		type = "description",
		text = self.strings.FLOATING_BREADCRUMB,
		width = "half",
	})
	]]--
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION, isBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING, isNotBreadcrumb))
	settings:AddSetting(getFloatingCheckbox(MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING, isBreadcrumb))
	
end