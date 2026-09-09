-- Integrated into ESO Adventurer Suite; original data/marker architecture retained and namespaced.

local FilterMenu = {}
EASLoreLibrary:RegisterModule("filterMenu", FilterMenu)

--[[
Adds a checkbox for each pin type (Lore Books / Eidetic Memory) to the world
map's keyboard "Filter" menu so the player can
turn either kind of pin on/off. EASLoreLibrary.settings holds the actual on/off
state; these checkboxes just read/write it.
]]--

local PIN_TYPE_LABELS = EASLoreLibrary.pinTypeLabels

-- returns "|t<size>:<size>:<texture>:inheritcolor|t" wrapped in the pin's
-- tint color, i.e. the inline icon markup shown before each label, colored to
-- match that pin type's map/compass/world icon (same technique the reference map system's
-- filter menu uses)
local function GetColoredIcon(pinTypeId, size)
	local layout = EASLoreLibrary.mapPinLayout[pinTypeId]
	local tint = layout.tint or ZO_ColorDef:New(1, 1, 1)
	return tint:Colorize(zo_iconFormatInheritColor(layout.texture, size, size))
end

-- ZO_CheckButton recolors its label on hover by calling label:SetColor(r, g,
-- b, a), which would otherwise wipe out our icon markup (SetText isn't
-- called again). Overriding SetColor on the label instance lets us rebuild
-- "icon (fixed tint) + label text (hover color)" every time it's recolored.
local function SetLabelColorWithIcon(label, r, g, b, a)
	local coloredText = string.format("|c%.2x%.2x%.2x%s|r", zo_round(r * 255), zo_round(g * 255), zo_round(b * 255), label.loreLabelText)
	local size = 20 -- keyboard size
	label:SetText(GetColoredIcon(label.lorePinTypeId, size) .. " " .. coloredText)
end

function FilterMenu:Initialize()
	self:InitializeKeyboard()
end

-- the keyboard filter panel builds its checkboxes once and never rebuilds the
-- list, so we can just append our own checkboxes to it a single time.
-- Keyboard-only: WORLD_MAP_FILTERS doesn't exist when the keyboard UI isn't
-- loaded (i.e. on console); ZO_IsConsoleOrGameCoreUI() is true there.
function FilterMenu:InitializeKeyboard()
	if ZO_IsConsoleOrGameCoreUI() then return end

	local panel = WORLD_MAP_FILTERS and WORLD_MAP_FILTERS.pvePanel
	if not panel then return end

	if not panel.checkBoxPool then
		panel.checkBoxPool = ZO_ControlPool:New("ZO_CheckButton", panel.control, "CheckBox")
	end

	for _, pinTypeId in ipairs(EASLoreLibrary.PINTYPES) do
		local checkBox = panel.checkBoxPool:AcquireObject()
		checkBox.lorePinTypeId = pinTypeId
		ZO_CheckButton_SetLabelText(checkBox, PIN_TYPE_LABELS[pinTypeId])

		local label = checkBox.label
		label.lorePinTypeId = pinTypeId
		label.loreLabelText = PIN_TYPE_LABELS[pinTypeId]
		label.SetColor = SetLabelColorWithIcon
		ZO_CheckButtonLabel_ColorText(label, false)

		ZO_CheckButton_SetCheckState(checkBox, EASLoreLibrary.settings:IsPinTypeEnabled(pinTypeId))
		ZO_CheckButton_SetToggleFunction(checkBox, function(_, checked)
			EASLoreLibrary.settings:SetPinTypeEnabled(pinTypeId, checked)
		end)
		panel:AnchorControl(checkBox)
	end

	EASLoreLibrary.settings:RegisterCallback("FilterChanged", function(pinTypeId, enabled)
		self:RefreshKeyboardCheckBoxes()
	end)
end

function FilterMenu:RefreshKeyboardCheckBoxes()
	local panel = WORLD_MAP_FILTERS and WORLD_MAP_FILTERS.pvePanel
	if not panel or not panel.checkBoxPool then return end

	for _, control in panel.checkBoxPool:ActiveObjectIterator() do
		local pinTypeId = control.lorePinTypeId
		if pinTypeId then
			ZO_CheckButton_SetCheckState(control, EASLoreLibrary.settings:IsPinTypeEnabled(pinTypeId))
		end
	end
end

