local MAJOR, MINOR = "LibAddonMenu-1.0-to-2.0", 1
local lam, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lam then return end	--the same or newer version of this lib is already loaded into memory 

local lam2 = LibStub("LibAddonMenu-2.0")

lam.optionControls = {}
function lam:CreateControlPanel(controlPanelID, controlPanelName)
	local data = {
		type = "panel",
		--Remove coloring from the name for addon list
		name = controlPanelName:gsub("%|[Cc]......",""):gsub("%|[Rr]",""),
		displayName = text
	}
	lam2:RegisterAddonPanel(controlPanelName, data)
	lam.optionControls[controlPanelName] = {}
	return controlPanelName
end

function lam:AddHeader(panelID, controlName, text)
	local data = {
		type = "header",
		name = text
	}
	table.insert(lam.optionControls[panelID], data)
	lam2:RegisterOptionControls(panelID, lam.optionControls[panelID])	
end

function lam:AddSlider(panelID, controlName, text, tooltip, minValue, maxValue, step, getFunc, setFunc, warning, warningText)
	local data = {
		type = "slider",
		name = text,
		tooltip = tooltip,
		min = minValue,
		max = maxValue,
		step = step,
		getFunc = getFunc,
		setFunc = setFunc,
		warning = warningText
	}
	table.insert(lam.optionControls[panelID], data)
end

function lam:AddDropdown(panelID, controlName, text, tooltip, validChoices, getFunc, setFunc, warning, warningText)
	local data = {
		type = "dropdown",
		name = text,
		tooltip = tooltip,
		choices = validChoices,
		getFunc = getFunc,
		setFunc = setFunc,
		warning = warningText
	}
	table.insert(lam.optionControls[panelID], data)
end

function lam:AddCheckbox(panelID, controlName, text, tooltip, getFunc, setFunc, warning, warningText)
	local data = {
		type = "checkbox",
		name = text,
		tooltip = tooltip,
		getFunc = getFunc,
		setFunc = setFunc,
		warning = warningText
	}
	table.insert(lam.optionControls[panelID], data)
end

function lam:AddColorPicker(panelID, controlName, text, tooltip, getFunc, setFunc, warning, warningText)
	local data = {
		type = "colorpicker",
		name = text,
		tooltip = tooltip,
		getFunc = getFunc,
		setFunc = setFunc,
		warning = warningText
	}
	table.insert(lam.optionControls[panelID], data)
end

function lam:AddEditBox(panelID, controlName, text, tooltip, isMultiLine, getFunc, setFunc, warning, warningText)
	local data = {
		type = "editbox",
		name = text,
		tooltip = tooltip,
		getFunc = getFunc,
		setFunc = setFunc,
		isMultiLine = isMultiLine,
		warning = warningText
	}
	table.insert(lam.optionControls[panelID], data)
end

function lam:AddButton(panelID, controlName, text, tooltip, onClick, warning, warningText)
	local data = {
		type = "button",
		name = text,
		tooltip = tooltip,
		func = onClick,
		warning = warningText
	}
	table.insert(lam.optionControls[panelID], data)
end

function lam:AddDescription(panelID, controlName, text, titleText)
	local data = {
		type = "description",
		title = titleText,
		text = text
	}
	table.insert(lam.optionControls[panelID], data)
end

function lam:AddSubMenu(panelID, controlName, text, tooltip)
	local subName = panelID .. "-" .. controlName
	lam.optionControls[subName] = {}

	local data = {
		type = "submenu",
		name = text,
		tooltip = tooltip,
		controls = lam.optionControls[subName]
	}
	table.insert(lam.optionControls[panelID], data)
	
	return subName
end