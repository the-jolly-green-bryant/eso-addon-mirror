BlockItemUsage = BlockItemUsage or {} 
BlockItemUsageSavedVars = BlockItemUsageSavedVars or {}
BlockItemUsage.name = "BlockItemUsage"

local panel =  
{
     type = "panel",
     name = "Block Item Usage",
     registerForRefresh = true,
     displayName = "Block Item Usage",
     author = "@Dolgubon",
}

local doNotUseCharacter = {

}
local shouldBlock = BlockItemUsageSavedVars[GetDisplayName()] or BlockItemUsageSavedVars[GetUnitName('player')]

if shouldBlock then
	UseItem = function(b, s)
		if shouldBlock then
			ZO_Alert(nil,nil,"Item usage blocked by Block Item Usage")
			return
		end
		CallSecureProtected("UseItem",b,s)
	end
end


local options =
{
	{
		type = "checkbox",
		name = "Block item usage for account",
		tooltip = "Block item use for all characters on this account (Requires reloading the UI to properly take effect)",
		getFunc = function() 
			return BlockItemUsageSavedVars[GetDisplayName()] end,
			-- return BlockItemUsage.settings.markMessages end,
		setFunc = function(value)
			BlockItemUsageSavedVars[GetDisplayName()] = value
			shouldBlock = BlockItemUsageSavedVars[GetDisplayName()] or BlockItemUsageSavedVars[GetUnitName('player')]
			if IsConsoleUI() then
				ReloadUI()
			end
		end,
		requiresReload = true,
	},
	{
		type = "checkbox",
		name = "Block item usage for character",
		tooltip = "Only block item usage for the current character (Requires reloading the UI to properly take effect)",
		getFunc = function() 
			return BlockItemUsageSavedVars[GetUnitName("player")] end,
			-- return BlockItemUsage.settings.markMessages end,
		setFunc = function(value)
			BlockItemUsageSavedVars[GetUnitName("player")] = value
			shouldBlock = BlockItemUsageSavedVars[GetDisplayName()] or BlockItemUsageSavedVars[GetUnitName('player')]
			if IsConsoleUI() then
				ReloadUI()
			end
		end,
		requiresReload = true,
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


function BlockItemUsage.initializeSettingsMenu()
	if IsConsoleUI() then
		local controlTable = convertlamToHasTable(options)
		local LHA = LibHarvensAddonSettings
		local options = {
			-- allowDefaults = true, --will allow users to reset the settings to default values
			allowRefresh = true, --if this is true, when one of settings is changed, all other settings will be checked for state change (disable/enable)
			defaultsFunction = function() --this function is called when allowDefaults is true and user hit the reset button
			  d("Reset")
			end,
		}

		local settings = LHA:AddAddon("|c8080FFBlock Item Usage|r", options)
		if not settings then
		   return
		end
		BlockItemUsage.consoleSettingsMenu = settings
		for i = 1, #controlTable.indexed do
			settings:AddSetting(controlTable.indexed[i])
		end
		
	else
		local LAM = LibAddonMenu2
		LAM:RegisterAddonPanel("BlockItemUsagePanel", panel)
		LAM:RegisterOptionControls("BlockItemUsagePanel", options)
	end
end


function BlockItemUsage:Initialize()
	BlockItemUsage.initializeSettingsMenu()

end

 
function BlockItemUsage.OnAddOnLoaded(event, addonName)
	if addonName == BlockItemUsage.name then
		BlockItemUsage:Initialize()
	end
end
 
EVENT_MANAGER:RegisterForEvent(BlockItemUsage.name, EVENT_PLAYER_ACTIVATED , BlockItemUsage.Initialize)