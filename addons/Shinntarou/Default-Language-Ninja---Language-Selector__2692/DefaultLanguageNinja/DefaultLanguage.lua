local ADDON = DefaultLanguageNinja

-- DEFAULT LANGUAGE

local DEFAULT_LANGUAGE = {
	-- preset
	["ENGLISH"] = {
		["VALUE"] = 1,
		["CHOICE"] = "en"
	},
	["JAPANESE"] = {
		["VALUE"] = 2,
		["CHOICE"] = "jp"
	},
	["GERMAN"] = {
		["VALUE"] = 3,
		["CHOICE"] = "de"
	},
	["FRENCH"] = {
		["VALUE"] = 4,
		["CHOICE"] = "fr"
	},
	["RUSSIAN"] = {
		["VALUE"] = 5,
		["CHOICE"] = "ru"
	},
	-- other
	["USER_DEFINED_0"] = {
		["VALUE"] = 100,
		["CHOICE"] = "User Defined Code 0"
	},
	["USER_DEFINED_1"] = {
		["VALUE"] = 101,
		["CHOICE"] = "User Defined Code 1"
	},
	["USER_DEFINED_2"] = {
		["VALUE"] = 102,
		["CHOICE"] = "User Defined Code 2"
	},
	["LAST"] = {
		["VALUE"] = 110,
		["CHOICE"] = "Last Code"
	},
	["DISABLED"] = {
		["VALUE"] = 999,
		["CHOICE"] = "Disabled"
	}
}

DEFAULT_LANGUAGE.GetValues = function()
	local data = {
		-- preset
		DEFAULT_LANGUAGE.ENGLISH.VALUE,
		DEFAULT_LANGUAGE.JAPANESE.VALUE,
		DEFAULT_LANGUAGE.GERMAN.VALUE,
		DEFAULT_LANGUAGE.FRENCH.VALUE,
		DEFAULT_LANGUAGE.RUSSIAN.VALUE,
		-- other
		DEFAULT_LANGUAGE.USER_DEFINED_0.VALUE,
		DEFAULT_LANGUAGE.USER_DEFINED_1.VALUE,
		DEFAULT_LANGUAGE.USER_DEFINED_2.VALUE,
		DEFAULT_LANGUAGE.LAST.VALUE,
		DEFAULT_LANGUAGE.DISABLED.VALUE
	}

	return data
end

DEFAULT_LANGUAGE.GetChoices = function()
	local data = {
		-- preset (must be lang code)
		DEFAULT_LANGUAGE.ENGLISH.CHOICE,
		DEFAULT_LANGUAGE.JAPANESE.CHOICE,
		DEFAULT_LANGUAGE.GERMAN.CHOICE,
		DEFAULT_LANGUAGE.FRENCH.CHOICE,
		DEFAULT_LANGUAGE.RUSSIAN.CHOICE,
		-- other
		DEFAULT_LANGUAGE.USER_DEFINED_0.CHOICE,
		DEFAULT_LANGUAGE.USER_DEFINED_1.CHOICE,
		DEFAULT_LANGUAGE.USER_DEFINED_2.CHOICE,
		DEFAULT_LANGUAGE.LAST.CHOICE,
		DEFAULT_LANGUAGE.DISABLED.CHOICE
	}

	return data
end

DEFAULT_LANGUAGE.GetValue = function(choice)
	local data = DEFAULT_LANGUAGE.GetValues()
	for key, var in ipairs(DEFAULT_LANGUAGE.GetChoices()) do
		if (choice == var) then
			return data[key]
		end
	end
	return false
end

DEFAULT_LANGUAGE.GetChoice = function(value)
	local data = DEFAULT_LANGUAGE.GetChoices()
	for key, var in ipairs(DEFAULT_LANGUAGE.GetValues()) do
		if (value == var) then
			return data[key]
		end
	end
	return false
end

--------
-- in this ADDON use, protected
--------

ADDON.DEFAULT_LANGUAGE = DEFAULT_LANGUAGE
