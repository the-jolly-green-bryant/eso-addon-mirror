local Settings = {}
DQT.Settings = Settings

Settings.panelData = {
	type = "panel",
	name = "Pollox's Daily Quest Tracker",
	author = "Pollox, maintained by |cCC99FFnotnear|r",
	website = "https://www.esoui.com/downloads/info2192-PolloxsDailyQuestTracker.html"
}

-- Section name -> should show section
Settings.sectionsToShow = {}

--[[

	@param savedSettings settings table that gets saved to disk
]]
function Settings:initialize(savedSettings, windowProperties)
	self.settings = savedSettings
	self.windowProperties = windowProperties
	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(DQT.Main.name, self.panelData)

	local optionsData = {}

	optionsData[#optionsData + 1] = {
		type = "header",
		name = GetString(DQT_SETTINGS_HEADER)
	}

	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = GetString(DQT_CURSOR_TOGGLE_NAME),
		tooltip = GetString(DQT_CURSOR_TOGGLE_TOOLTIP),
		getFunc = function() return self.settings.showCursor end,
		setFunc = function(value) self.settings.showCursor = value end,
	}

	optionsData[#optionsData + 1] = {
		type = "slider",
		name = GetString(DQT_SCALE_NAME),
		tooltip = GetString(DQT_SCALE_TOOLTIP),
		getFunc = function() return self.windowProperties.scale end,
		setFunc = function(value)
			self.windowProperties.scale = value
		end,
		min = 0.4,
		max = 1.2,
		step = 0.01,
		decimals = 2,
		requiresReload = true,
	}

	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = GetString(DQT_COLOR_TOGGLE_NAME),
		getFunc = function() return self.settings.customColors.toggle end,
		setFunc = function(value) self.settings.customColors.toggle = value end,
	}

	optionsData[#optionsData + 1] = {
		type = "colorpicker",
		name = GetString(DQT_COLOR_CHECKED_NAME),
		getFunc = function() return self.settings.customColors.colorChecked.r, self.settings.customColors.colorChecked.g, self.settings.customColors.colorChecked.b end,
		setFunc = function(r,g,b) self.settings.customColors.colorChecked = { r = r, g = g, b = b } end,
	}

	optionsData[#optionsData + 1] = {
		type = "colorpicker",
		name = GetString(DQT_COLOR_UNCHECKED_NAME),
		getFunc = function() return self.settings.customColors.colorUnchecked.r, self.settings.customColors.colorUnchecked.g, self.settings.customColors.colorUnchecked.b end,
		setFunc = function(r,g,b) self.settings.customColors.colorUnchecked = { r = r, g = g, b = b } end,
	}

	optionsData[#optionsData + 1] = {
		type = "colorpicker",
		name = GetString(DQT_COLOR_DISABLED_NAME),
		getFunc = function() return self.settings.customColors.colorDisabled.r, self.settings.customColors.colorDisabled.g, self.settings.customColors.colorDisabled.b end,
		setFunc = function(r,g,b) self.settings.customColors.colorDisabled = { r = r, g = g, b = b } end,
	}

	-- options to filter by character
	local characterHeader = {
		type = "header",
		name = GetString(DQT_CHARACTERS_HEADER)
	}

	optionsData[#optionsData + 1] = characterHeader

	for _, character in ipairs(DQT.Utils:getCharacters()) do
		local checkbox = {
			type = "checkbox",
			name = character.name,
			getFunc = function() return self.settings.charactersToShow[character.id] end,
			setFunc = function(value) self.settings.charactersToShow[character.id] = value end,
			requiresReload = true
		}

		optionsData[#optionsData + 1] = checkbox
	end

	-- options to filter by section
	local sectionHeader = {
		type = "header",
		name = GetString(DQT_SECTION_HEADER)
	}

	optionsData[#optionsData + 1] = sectionHeader

	for _, section in ipairs(DQT.Info.QuestSections) do
		local checkbox = {
			type = "checkbox",
			name = section:getName(),
			getFunc = function() return self:shouldShowSection(section) end,
			setFunc = function(value) self.settings.sectionsToShow[section:getName()] = value end,
			requiresReload = true
		}

		optionsData[#optionsData + 1] = checkbox
	end

	LAM:RegisterOptionControls(DQT.Main.name, optionsData)
end

--[[

	@param section quest section or timer section
]]
function Settings:shouldShowSection(section)
	return self.settings.sectionsToShow[section:getName()]
end

function Settings:shouldShowCharacter(characterId)
	return self.settings.charactersToShow[characterId]
end
