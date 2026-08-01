local panel =  
{
     type = "panel",
     name = "Anti All Caps",
     registerForRefresh = true,
     displayName = "Anti All Caps",
     author = "@Dolgubon",
}
local function shallowCopy (source, destination)
	for k, v in pairs(source) do
		destination[k] = v
	end
end

local options =
{
	{
			type = "dropdown",
			name = "Behaviour",
			tooltip ="Disabled -> Do not affect any messages\nChange all messages to lower case -> All messages will be changed to lower case"..
			"\nUPPER CASE abuse to lower case -> Messages that are more than 60% upper case will be changed to lower case"..
			"\nChange all messages to UPPER CASE -> Change all messages to UPPER CASE",
			choices = {"Disabled", "Change all messages to lower case", "UPPER CASE abuse to lower case", "Change all messages to UPPER CASE"},
			choicesValues = {"disable", "all lower", "anti Caps", "all upper"},
			getFunc = function() return AntiAllCaps.settings.behaviour end,
			setFunc = function(value) 
				AntiAllCaps.settings.behaviour = value
			end,
	},
	{
		type = "checkbox",
		name = "Mark affected messages",
		tooltip = "Adds a small arrow at the start of any message that was affected",
		getFunc = function() return AntiAllCaps.settings.markMessages end,
		setFunc = function(value) 
			AntiAllCaps.settings.markMessages = value
		end,
	},


}

local function addToControlTable(newOption, t)
	t.indexed[#t.indexed + 1 ] = newOption
	t.nameMap[newOption.label] = newOption
	newOption.conversionIndex = #t.indexed
end
local function LAMtoHASDropdownConverter(option, controlTable)
	local newOption = {
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = option.name,
		default = option.default,
		-- setFunction = option.setFunc,
		getFunction = option.getFunc,
		tooltip = option.tooltip,
		disable = option.disabled,
	}

	newOption.setFunction = function(combobox, name, item) option.setFunc(item.data) end
	
	local items = {}
	local labelMap = {}
	for i = 1, # option.choices do
		items[i] = {name = option.choices[i], data = option.choicesValues[i]}
		if option.choicesValues[i] then
			labelMap[items[i].data] = items[i].name
		end
	end
	newOption.items = items
	newOption.getFunction = function() return labelMap[option.getFunc()]  end
	addToControlTable(newOption, controlTable)
end

local function convertlamToHasTable(optionsTable, controlTable)
	local LAMtoHAS = {
		slider = LibHarvensAddonSettings.ST_SLIDER,
		header = LibHarvensAddonSettings.ST_SECTION,
		checkbox = LibHarvensAddonSettings.ST_CHECKBOX,
		colorpicker = LibHarvensAddonSettings.ST_COLOR,
		button = LibHarvensAddonSettings.ST_BUTTON,
		editbox = LibHarvensAddonSettings.ST_EDIT,
	}
	local LAMtoHASSpecial = {
		dropdown = LAMtoHASDropdownConverter,
		submenu = function(option, controlTable) convertlamToHasTable(option.controls, controlTable) end
	}
	local controlTable = controlTable or {
		indexed = {},
		nameMap = {},
	}
	
	-- LAMHASMissing = {}
	
	for i, entry in ipairs(optionsTable) do
		local newType = LAMtoHAS[entry.type]
		if newType and not entry.isPCOnly then
			local newOption = {
				type = newType,
				label = entry.name,
				default = entry.default,
				setFunction = entry.setFunc,
				getFunction = entry.getFunc,
				tooltip = entry.tooltip,
				min = entry.min,
				max = entry.max,
				step = entry.step,
				disable = entry.disabled,
				clickHandler = entry.func,
				buttonText = entry.name,
			}
			addToControlTable(newOption, controlTable)
			-- settings:AddSetting(newOption)
		elseif LAMtoHASSpecial[entry.type] then
			LAMtoHASSpecial[entry.type](entry, controlTable)
		else
			-- LAMHASMissing[entry.type] = entry.type
		end
	end
	return controlTable
end


function AntiAllCaps.initializeSettingsMenu()
	if IsConsoleUI() then
		d("Creating")
		local controlTable = convertlamToHasTable(options)
		local LHA = LibHarvensAddonSettings
		local options = {
			-- allowDefaults = true, --will allow users to reset the settings to default values
			allowRefresh = true, --if this is true, when one of settings is changed, all other settings will be checked for state change (disable/enable)
			defaultsFunction = function() --this function is called when allowDefaults is true and user hit the reset button
			  d("Reset")
			end,
		}

		local settings = LHA:AddAddon("|c8080FFAnti Call Caps|r", options)
		if not settings then
		   return
		end
		AntiAllCaps.consoleSettingsMenu = settings
		for i = 1, #controlTable.indexed do
			settings:AddSetting(controlTable.indexed[i])
		end
	else
		local LAM = LibAddonMenu2
		LAM:RegisterAddonPanel("AntiAllCapsPanel", panel)
		LAM:RegisterOptionControls("AntiAllCapsPanel", options)
	end
end

