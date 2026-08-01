
if IsConsoleUI() then return end

PinKiller = PinKiller or {}

function PinKiller:InitializeLAM()
	
	local function addCompassCheckboxWithTextureList(menuTable, pinType, textureList)
		local pinTypeName = self.strings.PIN_TYPE_NAMES[pinType]
		local textureLabel = ""
		for _, texture in ipairs(textureList) do
			textureLabel = textureLabel .. zo_iconFormat(texture, 32, 32)
		end
		pinTypeName = textureLabel .. pinTypeName
		menuTable:insert({
			type = "checkbox",
			name = pinTypeName,
			tooltip = zo_strformat(self.strings.COMPASS_CHECKBOX_TOOLTIP, pinTypeName),
			getFunc = function() return not self.settings.disabledCompassPinTypes[pinType] end,
			setFunc = function(value)
				self.settings.disabledCompassPinTypes[pinType] = not value
				self:RefreshCompassPinSettings(pinType)
			end,
			width = "full",
			default = true,
		})
	end
	
	local function addCompassCheckbox(menuTable, pinType)
		local pinTypeName = self.strings.PIN_TYPE_NAMES[pinType]
		if PinKiller.floatingMarkerInfoArguments[pinType] then
			local texture = PinKiller.floatingMarkerInfoArguments[pinType][1] or ""
			pinTypeName = zo_iconFormat(texture, 40, 40) .. pinTypeName
		end
		menuTable:insert({
			type = "checkbox",
			name = pinTypeName,
			tooltip = zo_strformat(self.strings.COMPASS_CHECKBOX_TOOLTIP, pinTypeName),
			getFunc = function() return not self.settings.disabledCompassPinTypes[pinType] end,
			setFunc = function(value)
				self.settings.disabledCompassPinTypes[pinType] = not value
				self:RefreshCompassPinSettings(pinType)
			end,
			width = "full",
			default = true,
		})
	end

	local function addFloatingCheckbox(menuTable, pinType, isBreadcrumb, width)
		width = width or "half"	
		local texture = PinKiller.floatingMarkerInfoArguments[pinType][1]
		local pinTypeName = self.strings.PIN_TYPE_NAMES[pinType]
		local tooltip, settingsTable
		if isBreadcrumb then
			tooltip = self.strings.FLOATING_MARKER_BREADCRUMB_CHECKBOX_TOOLTIP
			settingsTable = self.settings.disabledFloatingMarkerBreadcrumbPinTypes
			texture = PinKiller.floatingMarkerInfoArguments[pinType][2]
		else
			tooltip = self.strings.FLOATING_MARKER_CHECKBOX_TOOLTIP
			settingsTable = self.settings.disabledFloatingMarkerPinTypes
		end
		
		menuTable:insert({
			type = "checkbox",
			name = zo_iconFormat(texture or "", 40, 40) .. pinTypeName,
			tooltip = zo_strformat(tooltip, pinTypeName),
			getFunc = function() return not settingsTable[pinType] end,
			setFunc = function(value)
				settingsTable[pinType] = not value
				self:RefreshFloatingMarkerInfo(pinType)
			end,
			width = width,
			default = true,
		})
	end

	local panelData = {
		type = "panel",
		name = "PinKiller",
		displayName = ZO_HIGHLIGHT_TEXT:Colorize("PinKiller"),
		author = "Shinni",
		version = self.version,
		registerForRefresh = false,
		registerForDefaults = true,
	}
	local optionsTable = setmetatable({}, { __index = table })
	
	optionsTable:insert({
		type = "header",
		name = self.strings.COMPASS_HEADER,
	})
	
	optionsTable:insert({
		type = "checkbox",
		name = zo_iconFormat("/esoui/art/mappins/map_areapin_32.dds", 32, 32) .. " " .. self.strings.AREA_ANIMATION,
		tooltip = self.strings.AREA_ANIMATION_TOOLTIP,
		getFunc = function() return not self.settings.disableAreaAnimation end,
		setFunc = function(value) self.settings.disableAreaAnimation = not value end,
		width = "full",
		default = true,
	})
	
	local seenPOItextures = {
		--"/esoui/art/icons/poi/poi_areaofinterest_incomplete.dds",
		"/esoui/art/icons/poi/poi_delve_incomplete.dds",
		"/esoui/art/icons/poi/poi_town_incomplete.dds",
		"/esoui/art/icons/poi/poi_wayshrine_incomplete.dds",
		"/esoui/art/icons/poi/poi_portal_incomplete.dds",
		"/esoui/art/icons/poi/poi_groupboss_incomplete.dds",
		"/esoui/art/icons/poi/poi_mundus_incomplete.dds",
	}
	local completePOItextures = {
		--"/esoui/art/icons/poi/poi_areaofinterest_complete.dds",
		"/esoui/art/icons/poi/poi_delve_complete.dds",
		"/esoui/art/icons/poi/poi_town_complete.dds",
		"/esoui/art/icons/poi/poi_wayshrine_complete.dds",
		"/esoui/art/icons/poi/poi_portal_complete.dds",
		"/esoui/art/icons/poi/poi_groupboss_complete.dds",
		"/esoui/art/icons/poi/poi_mundus_complete.dds",
	}
	addCompassCheckboxWithTextureList(optionsTable, MAP_PIN_TYPE_POI_SEEN, seenPOItextures)
	addCompassCheckboxWithTextureList(optionsTable, MAP_PIN_TYPE_POI_COMPLETE, completePOItextures)
	addCompassCheckbox(optionsTable, MAP_PIN_TYPE_TIMELY_ESCAPE_NPC)
	--addCompassCheckbox(optionsTable, MAP_PIN_TYPE_DARK_BROTHERHOOD_TARGET)
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = self.strings.QUEST_HEADER,
		controls = submenuTable,
	})
	
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_OFFER)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ENDING)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_ENDING)
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = self.strings.ZONE_STORY_QUEST_HEADER,
		controls = submenuTable,
	})
	
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_OFFER_ZONE_STORY)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING)
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = self.strings.REPEATABLE_QUEST_HEADER,
		controls = submenuTable,
	})
	
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING)
	
	optionsTable:insert({
		type = "header",
		name = self.strings.MAP_HEADER,
	})
	
	optionsTable:insert({
		type = "checkbox",
		name = self.strings.QUEST_PINS,
		tooltip = self.strings.QUEST_PINS_TOOLTIP,
		getFunc = function() return not self.settings.disabledMapPinGroups[MAP_FILTER_QUESTS] end,
		setFunc = function(value)
			self.settings.disabledMapPinGroups[MAP_FILTER_QUESTS] = not value
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
		end,
		width = "full",
		default = true,
	})
	
	optionsTable:insert({
		type = "header",
		name = self.strings.FLOATING_MARKER_HEADER,
	})
	
	local isBreadcrumb = true
	local isNotBreadcrumb = false
	addFloatingCheckbox(optionsTable, MAP_PIN_TYPE_TIMELY_ESCAPE_NPC, isNotBreadcrumb, "full")
	addFloatingCheckbox(optionsTable, MAP_PIN_TYPE_DARK_BROTHERHOOD_TARGET, isNotBreadcrumb, "full")
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = self.strings.QUEST_HEADER,
		controls = submenuTable,
	})
	
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_OFFER, isNotBreadcrumb, "full")
	
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
	
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ENDING, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ENDING, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_ENDING, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_ENDING, isBreadcrumb)
	
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = self.strings.ZONE_STORY_QUEST_HEADER,
		controls = submenuTable,
	})
	
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_OFFER_ZONE_STORY, isNotBreadcrumb, "full")
	
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
	
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING, isBreadcrumb)
	
	
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = self.strings.REPEATABLE_QUEST_HEADER,
		controls = submenuTable,
	})
	
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE, isNotBreadcrumb, "full")
	
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
	
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING, isBreadcrumb)
	
	LibAddonMenu2:RegisterAddonPanel("PinKillerControl", panelData)
	LibAddonMenu2:RegisterOptionControls("PinKillerControl", optionsTable)
end