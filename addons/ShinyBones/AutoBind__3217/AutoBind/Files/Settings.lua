local _savedVariables

local _defaultSettings = {
	BindOnOpenStore = false,
	BindOnCollect = false,
	MaxQuality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT,
	ExcludedTraits = {},
}

local function Update_BindOnOpenStore(value)
	_savedVariables.BindOnOpenStore = value
	AutoBind.SetStoreEventActive(value)
end

local function Update_BindOnCollect(value)
	_savedVariables.BindOnCollect = value
	AutoBind.SetInventorySlotEventActive(value)
end

local function Update_MaxQuality(value)
	_savedVariables.MaxQuality = value
end

local function Update_ExcludedTraits(traitType, value)
	if value == false then
		_savedVariables.ExcludedTraits[traitType] = true
	else
		_savedVariables.ExcludedTraits[traitType] = nil
	end
end

local function GetNewQualityChoices(colorize)
	local qualityChoices = {
		Choices = {},
		Values = {},
	}

	for i = ITEM_FUNCTIONAL_QUALITY_MAX_VALUE, ITEM_FUNCTIONAL_QUALITY_MAGIC, -1 do
		local qualityColor = GetItemQualityColor(i)
		local qualityName = GetString("SI_ITEMQUALITY", i)

		table.insert(qualityChoices.Choices, qualityColor:Colorize(qualityName))
		table.insert(qualityChoices.Values, i)
	end

	return qualityChoices
end

local function CreateTraitSubMenu(categoryName, traits)
	local controls = {}
	local sortedTraits = {}

	for _, traitData in pairs(traits) do
		table.insert(sortedTraits, traitData)
	end

	table.sort(sortedTraits, function(a, b) return a.DisplayName < b.DisplayName end)

	for _, traitData in ipairs(sortedTraits) do
		table.insert(controls, {
			type = "checkbox",
			name = traitData.DisplayName,
			getFunc = function() return not _savedVariables.ExcludedTraits[traitData.TraitType] end,
			setFunc = function(value) Update_ExcludedTraits(traitData.TraitType, value) end,
			default = true,
		})
	end

	return {
		type = "submenu",
		name = categoryName,
		controls = controls,
	}
end

local function CreateSettingsCommands()
	local function ShowSettings()
		local settingsList = {}

		for k,v in pairs(_defaultSettings) do
			table.insert(settingsList, k .. ": " .. tostring(_savedVariables[k]))
		end

		table.sort(settingsList, function(firstValue, secondValue) return firstValue < secondValue end)

		d("AutoBind Settings:")

		for i,v in ipairs(settingsList) do
			d("- " .. v)
		end
	end

	local validArguments = {
		["show"] = function() ShowSettings() end,
		["bindonopenstore true"] = function() Update_BindOnOpenStore(true) end,
		["bindonopenstore false"] = function() Update_BindOnOpenStore(false) end,
		["bindoncollect true"] = function() Update_BindOnCollect(true) end,
		["bindoncollect false"] = function() Update_BindOnCollect(false) end,
	}

	local infoOverride = {}
	local qualityChoices = GetNewQualityChoices()
	local maxQualityName = "maxquality "

	for i,v in ipairs(qualityChoices.Values) do
		local argName = maxQualityName .. string.lower(GetString("SI_ITEMQUALITY", v))

		validArguments[argName] = function() Update_MaxQuality(v) end
		infoOverride[argName] = maxQualityName .. string.lower(qualityChoices.Choices[i])
	end

	AutoBind.AddSlashCommand("/autobindsettings", validArguments, infoOverride)
end

local function CreateSettingsMenu()
	local optionsData = {}

	table.insert(optionsData, {
		type = "header",
		name = GetString(SI_SBAUTOBIND_SETTINGS_HEADER_GENERAL),
	})

	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(SI_SBAUTOBIND_SETTINGS_BIND_ON_VENDOR_TRADE_NAME),
		tooltip = GetString(SI_SBAUTOBIND_SETTINGS_BIND_ON_VENDOR_TRADE_TOOLTIP),
		getFunc = function() return _savedVariables.BindOnOpenStore end,
		setFunc = function(value) Update_BindOnOpenStore(value) end,
		default = _defaultSettings.BindOnOpenStore,
	})

	table.insert(optionsData, {
		type = "checkbox",
		name = GetString(SI_SBAUTOBIND_SETTINGS_BIND_ON_COLLECT_NAME),
		tooltip = GetString(SI_SBAUTOBIND_SETTINGS_BIND_ON_COLLECT_TOOLTIP),
		getFunc = function() return _savedVariables.BindOnCollect end,
		setFunc = function(value) Update_BindOnCollect(value) end,
		default = _defaultSettings.BindOnCollect,
	})

	local qualityChoices = GetNewQualityChoices()

	table.insert(optionsData, {
		type = "dropdown",
		name = GetString(SI_SBAUTOBIND_SETTINGS_BIND_ON_MAX_QUALITY_NAME),
		tooltip = GetString(SI_SBAUTOBIND_SETTINGS_BIND_ON_MAX_QUALITY_TOOLTIP),
		choices = qualityChoices.Choices,
		choicesValues = qualityChoices.Values,
		getFunc = function() return _savedVariables.MaxQuality end,
		setFunc = function(value) Update_MaxQuality(value) end,
		default = _defaultSettings.MaxQuality,
	})

	table.insert(optionsData, {
		type = "header",
		name = GetString(SI_SBAUTOBIND_SETTINGS_HEADER_TRAITS),
	})

	table.insert(optionsData, {
		type = "description",
		text = GetString(SI_SBAUTOBIND_SETTINGS_DESCRIPTION_TRAITS),
	})

	table.insert(optionsData, CreateTraitSubMenu(GetString(SI_SPECIALIZEDITEMTYPE2000), AutoBind.Traits.GetIncludedTraitTypesArmor()))
	table.insert(optionsData, CreateTraitSubMenu(GetString(SI_SPECIALIZEDITEMTYPE2050), AutoBind.Traits.GetIncludedTraitTypesWeapon()))
	table.insert(optionsData, CreateTraitSubMenu(GetString(SI_SPECIALIZEDITEMTYPE2950), AutoBind.Traits.GetIncludedTraitTypesJewelry()))

	local panelData = {
		type = "panel",
		name = AutoBind.AddonName,
		displayName = AutoBind.AddonDisplayName,
		author = "ShinyBones",
		version = AutoBind.Version,
		slashCommand = "/autobindsettings",
		website = "https://www.esoui.com/downloads/info3217-AutoBind.html",
		registerForRefresh = false,
		registerForDefaults = true,
	}

	LibAddonMenu2:RegisterAddonPanel("AutoBindSettings", panelData)
	LibAddonMenu2:RegisterOptionControls("AutoBindSettings", optionsData)
end

function AutoBind.Settings.Initialize()
	_savedVariables = ZO_SavedVars:NewAccountWide("AutoBindVariables", 1, nil, _defaultSettings)
	AutoBind.SavedVariables = _savedVariables

	AutoBind.SetStoreEventActive(_savedVariables.BindOnOpenStore)
	AutoBind.SetInventorySlotEventActive(_savedVariables.BindOnCollect)

	if LibAddonMenu2 then
		CreateSettingsMenu()
	else
		CreateSettingsCommands()
	end

	return _savedVariables
end
