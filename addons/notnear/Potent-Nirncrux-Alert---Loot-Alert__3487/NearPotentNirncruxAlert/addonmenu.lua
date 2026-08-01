local addon = NEAR_PNA

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon settings panel
-------------------------------------------------------------------------------------------------------------------------------------------------
function NEAR_PNA.SetupSettings()
	local LAM2 = LibAddonMenu2
	local sv = addon.ASV

	local panelData = {
		type				= "panel",
		name 				= addon.title,
		displayName 		= addon.title,
		author 				= addon.author,
		version				= addon.version,
		slashCommand 		= "/pna",
		registerForRefresh	= true,
		registerForDefaults	= true,
	}
	LAM2:RegisterAddonPanel(addon.name, panelData)

	-------------------------------------------------------------------------

	local enableCustomItemEditor = false
	local choice
	local disableCustom
	local disableDropdownEditbox
	local choices

	local function updateDisableCustom()
		if next(sv.customItems) == nil then
			sv.toggleCustom = false
			disableCustom = true
		else
			disableCustom = false
		end
	end

	local function updateDisableDropdownEditbox()
        disableDropdownEditbox = choice == "" or not enableCustomItemEditor
	end

	local function rearrangeIndexes()
		local newCustomItems = {}
		local newIndex = 1
		local maxIndex = 0
		for index, _ in pairs(sv.customItems) do
			if type(index) == "number" and index > maxIndex then
				maxIndex = index
			end
		end
		for i = 1, maxIndex do
			if sv.customItems[i] ~= nil then
				newCustomItems[newIndex] = sv.customItems[i]
				newIndex = newIndex + 1
			end
		end
		sv.customItems = newCustomItems -- Update customItems with the rearranged values
	end

	---@param create boolean
	local function updateList(create)
		choices = {}
		if next(sv.customItems) ~= nil then
			rearrangeIndexes()
			for index, value in ipairs(sv.customItems) do
				choices[index] = value
			end
		end
		if not create then
			NPNA_am_dopdown_CustomItem:UpdateChoices(choices)
		end
	end

	local function createItem()
        local newName = "newitem".. #sv.customItems + 1
		sv.customItems[#sv.customItems + 1] = newName
		choice = newName
		updateList(false)
		updateDisableDropdownEditbox()
		updateDisableCustom()
	end

	local function updateItem(newName)
		for index, value in ipairs(sv.customItems) do
			if value == choice then
				sv.customItems[index] = newName
				break
			end
		end
		updateList(false)
		choice = (newName ~= nil) and newName or (sv.customItems[1] ~= nil and sv.customItems[1] or "")
		updateDisableDropdownEditbox()
		updateDisableCustom()
	end

	-------------------------------------------------------------------------

	if next(sv.customItems) ~= nil then rearrangeIndexes() end
	choice = sv.customItems[1] ~= nil and sv.customItems[1] or ""
	updateList(true)
	updateDisableCustom()
	updateDisableDropdownEditbox()

	-------------------------------------------------------------------------

	local optionsTable = {}

	optionsTable[#optionsTable + 1] = {
		type = "checkbox",
		name = GetString(NPNA_am_EnablePotentNirnAlert_name),
		getFunc = function() return sv.togglePotent end,
		setFunc = function(v) sv.togglePotent = v end,
		default = addon.defaults.togglePotent,
	}

	optionsTable[#optionsTable + 1] = {
		type = "header",
		name = GetString(NPNA_am_CustomItemAlert_name),
	}

	optionsTable[#optionsTable + 1] = {
		type = "checkbox",
		name = GetString(NPNA_am_EnableCustomItemAlert_name),
		getFunc = function() return sv.toggleCustom end,
		setFunc = function(v) sv.toggleCustom = v end,
		default = addon.defaults.toggleCustom,
		disabled = function() return disableCustom end
	}

	optionsTable[#optionsTable + 1] = {
		type = "checkbox",
		name = GetString(NPNA_am_EnableCustomItemEditor_name),
		getFunc = function() return enableCustomItemEditor end,
		setFunc = function(v)
			enableCustomItemEditor = v
			updateDisableDropdownEditbox()
		end,
	}

	optionsTable[#optionsTable + 1] = {
		type = "dropdown",
		reference = 'NPNA_am_dopdown_CustomItem',
		name = GetString(NPNA_am_CustomItem_name),
		choices = choices,
		getFunc = function() return choice end,
		setFunc = function(v) choice = v end,
		width = "half",
		scrollable = true,
		disabled = function() return disableDropdownEditbox end,
	}

	optionsTable[#optionsTable + 1] = {
		type = "editbox",
		name = GetString(NPNA_am_SetItemName_name),
		warning = GetString(NPNA_am_SetItemName_warning),
		getFunc = function() return choice end,
		setFunc = function(text) updateItem(text:lower()) end,
		isMultiline = false,
		width = "half",
		disabled = function() return disableDropdownEditbox end,
	}

	optionsTable[#optionsTable + 1] = {
		type = "button",
		name = GetString(NPNA_am_button_create_name),
		func = function() createItem() end,
		disabled = function() return not enableCustomItemEditor end,
	}

	optionsTable[#optionsTable + 1] = {
		type = "button",
		name = GetString(NPNA_am_button_delete_name),
		func = function() updateItem(nil) end,
		isDangerous = true,
		disabled = function() return not enableCustomItemEditor end,
	}

	optionsTable[#optionsTable + 1] = {
		type = "colorpicker",
		name = GetString(NPNA_am_ColorPicker_name),
		tooltip = GetString(NPNA_am_ColorPicker_tooltip),
		getFunc = function() return sv.customColor.r, sv.customColor.g, sv.customColor.b end,
		setFunc = function(r,g,b) sv.customColor = { r = r, g = g, b = b } end,
		disabled = function() return not enableCustomItemEditor end,
	}

	optionsTable[#optionsTable + 1] = {
		type = "divider",
	}
	optionsTable[#optionsTable + 1] = {
		type = "description",
		text = GetString(NPNA_am_cmd_text),
	}

	LAM2:RegisterOptionControls(addon.name, optionsTable)
end