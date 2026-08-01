ImperializationSettings = ZO_Object:Subclass()

local addonVersion = "2.5.1.0"
local savedVariablesVersion = 2.4
local settings = nil
local defaults = {
	styles = {},

	["displayResults"] = true,
	["convertOnEquip"] = false,
}

local function getStyles()
	styles = {}

	i = 0
	itemStyleString = GetString("SI_ITEMSTYLE", i)
	while(itemStyleString ~= "") do
		styles[itemStyleString] = false

		i = i + 1
		--there are holes in the set of item style strings, skip them
		if i == 30 or i == 36 then
			i = i + 1
		end

		--get next style
		itemStyleString = GetString("SI_ITEMSTYLE", i)

		--if we hit the unused styles, stop
		if itemStyleString == "Unused 0" then
			itemStyleString = ""
		end
	end

	return styles
end

local function createStyleControlData()
	local styleData = {}
	local function pairsByKeys(t)
		local a = {}
		for n in pairs(t) do table.insert(a, n) end
		table.sort(a)
		local i = 0
		local iter = function()
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
			end
		end
		return iter
	end

	for style, value in pairsByKeys(defaults.styles) do
		local temp = {
			type = "checkbox",
			name = style,
			tooltip = "Check to convert the " .. style .. " style",
			getFunc = function() return settings.styles[style] end,
			setFunc = function(newValue) settings.styles[style] = (newValue) end,
			width = "half",
			default = defaults.styles[style],
		}

		table.insert(styleData, temp)
	end

	return styleData
end

function ImperializationSettings:New()
	local obj = ZO_Object.New(self)
	obj:Initialize()
	return obj
end

function ImperializationSettings:Initialize()
	defaults.styles = getStyles()

	settings = ZO_SavedVars:New("ImperializationVariables",
		savedVariablesVersion, nil, defaults)

	self:CreateSettingsMenu()
end

function ImperializationSettings:CreateSettingsMenu()
	local LAM = LibStub("LibAddonMenu-2.0")
	local addonPanel = {
		type = "panel",
		name = "Imperialization",
		author = "@Randactyl",
		version = addonVersion,
		slashCommand = "/imp",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local optionsData = {
		[1] = {
			type = "submenu",
			name = "Styles",
			tooltip = "Choose styles to convert",
			controls = createStyleControlData(),
		},
		[2] = {
			type = "checkbox",
			name = "Display Results",
			tooltip = "Displays an item link in the chat window for converted items",
			getFunc = function() return settings.displayResults end,
			setFunc = function(newValue) settings.displayResults = (newValue) end,
			default = defaults.displayResults,
		},
		[3] = {
			type = "checkbox",
			name = "Convert on Equip",
			tooltip = "Convert an item on equip rather that on receipt",
			getFunc = function() return settings.convertOnEquip end,
			setFunc = function(newValue) settings.convertOnEquip = (newValue) end,
			default = defaults.convertOnEquip
		},
	}

	LAM:RegisterAddonPanel("ImperializationSettings", addonPanel)
	LAM:RegisterOptionControls("ImperializationSettings", optionsData)
end

function ImperializationSettings:ShouldConvertOnEquip()
	return settings.convertOnEquip
end

function ImperializationSettings:ShouldConvertStyle(itemStyleString)
	return settings[itemStyleString]
end

function ImperializationSettings:ShouldDisplayResults()
	return settings.displayResults
end
