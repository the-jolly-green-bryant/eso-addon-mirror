--[[widgetData = {
	type = "fontblock",
	name = "My Control",
	tooltip = "Control's tooltip",
	getFace = function() return face end,
	getSize = function() return size end,
	getOutline = function() return outline end,
	getColor = function() return r, g, b, a end,
	setFace = function(face) end,
	setSize = function(size) end,
	setOutline = function(outline) end,
	setColor = function(r, g, b, a) end,
	width = "full", --or "half" (optional)
	disabled = function() return boolean end, --(optional) boolean or function which returns boolean
	warning = "Some warning text", --(optional)
	default = { --(optional)
		face = "Univers 67",
		size = "22",
		outline = "soft-shadow-thin",
		color = { r = val1, g = val2, b = val3, a = val4 }, -- table (or ZO_ColorDef object) with default color values
	},
	reference = "MyControlReference", --(optional) unique global reference
}
]]

local widgetVersion = 3
local LAM = LibAddonMenu2
local LMP = LibMediaProvider
if (not LAM or not LMP) then return end -- need both libs to function
if not LAM:RegisterWidget("fontblock", widgetVersion) then return end

--UPVALUES--
local wm = GetWindowManager()
local cm = CALLBACK_MANAGER
local tinsert = table.insert
local strformat = string.format
local tostring = tostring
local round = zo_round

local fontOutlineChoices = {"none", "outline", "thin-outline", "thick-outline", "shadow", "soft-shadow-thin", "soft-shadow-thick"}
local fontSizeChoices = {}

for x = 1, 25 do
	fontSizeChoices[x] = tostring(x + 7)
end

local function UpdateDisabled(control)
	local disable
	if type(control.data.disabled) == "function" then
		disable = control.data.disabled()
	else
		disable = control.data.disabled
	end

	if disable then
		control.label:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
	else
		control.label:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
	end

	control.isDisabled = disable
end

local function UpdateValue(control, forceDefault, face, size, outline, colorR, colorG, colorB, colorA)
	local data = control.data
	local isUpdated = false

	if forceDefault then
		face = data.default.face
		size = data.default.size
		outline = data.default.outline
		colorR = data.default.color.r
		colorG = data.default.color.g
		colorB = data.default.color.b
		colorA = data.default.color.a
	end

	if face then
		data.setFace(face)
		isUpdated = true
	else
		face = data.getFace()
	end

	if size then
		data.setSize(size)
		isUpdated = true
	else
		size = data.getSize()
	end

	if outline then
		data.setOutline(outline)
		isUpdated = true
	else
		outline = data.getOutline()
	end

	if colorR and colorG and colorB then
		data.setColor(colorR, colorG, colorB, colorA or 1)
		isUpdated = true
	else
		colorR, colorG, colorB, colorA = data.getColor()
	end

	if isUpdated then
		if control.panel.data.registerForRefresh then
			cm:FireCallbacks("LAM-RefreshPanel", control)
		end
	end

	control.size.dropdown:SetSelectedItem(size)
	control.face.dropdown:SetSelectedItem(face)
	control.outline.dropdown:SetSelectedItem(outline)
	control.color.thumb:SetColor(colorR, colorG, colorB, colorA or 1)
end

function LAMCreateControl.fontblock(parent, widgetData, controlName)
	local panel = parent.panel or parent
	if not panel.fbCounter then
		panel.fbCounter = 0
	end
	panel.fbCounter = panel.fbCounter + 1
	controlName = controlName or widgetData.reference or (panel:GetName() .. "Fontblock" .. tostring(panel.fbCounter))
	local fb = wm:CreateControl(controlName, parent.scroll or parent, CT_CONTROL)
	fb:SetMouseEnabled(true)
	fb:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	fb:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	fb.label = wm:CreateControl(nil, fb, CT_LABEL)
	fb.label:SetAnchor(TOPLEFT)
	fb.label:SetFont("ZoFontWinH4")
	fb.label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
	fb.label:SetText(widgetData.name)

	-- font face
	local face = wm:CreateControlFromVirtual(controlName .. "Face", fb, "ZO_ComboBox")
	fb.face = face
	face:SetDimensions(169, 26)
	face:SetHandler("OnMouseEnter", function() ZO_Options_OnMouseEnter(fb) end)
	face:SetHandler("OnMouseExit", function() ZO_Options_OnMouseExit(fb) end)

	face.dropdown = ZO_ComboBox_ObjectFromContainer(face)
	face.dropdown:ClearItems()

	local fontFaceChoices = LMP:List("font")

	local function FaceDropdownCallback(self, choiceText, choice)
		fb:UpdateValue(false, choiceText)
	end

	for i = 1, #fontFaceChoices do
		local entry = face.dropdown:CreateItemEntry(fontFaceChoices[i], FaceDropdownCallback)
		face.dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
	end

	-- color picker
	local color = wm:CreateControl(nil, fb, CT_CONTROL)
	fb.color = color
	color:SetDimensions(28, 25)
	color:SetMouseEnabled(true)
	color:SetHandler("OnMouseEnter", function() ZO_Options_OnMouseEnter(fb) end)
	color:SetHandler("OnMouseExit", function() ZO_Options_OnMouseExit(fb) end)

	local thumb = wm:CreateControl(nil, color, CT_TEXTURE)
	fb.color.thumb = thumb
	thumb:SetDimensions(24, 20)
	thumb:SetAnchor(LEFT, color, LEFT, 4, 0)
	local border = wm:CreateControl(nil, color, CT_TEXTURE)
	border:SetAnchor(CENTER, thumb, CENTER, 0, 0)
	border:SetDimensions(28, 25)
	border:SetTexture("EsoUI/Art/ChatWindow/chatOptions_bgColSwatch_frame.dds")
	border:SetTextureCoords(0, .625, 0, .8125)

	local function ColorPickerCallback(r, g, b, a)
		fb:UpdateValue(false, nil, nil, nil, r, g, b, a)
	end

	fb.color:SetHandler("OnMouseUp", function(self, btn, upInside)
		if (upInside) then
			local r, g, b, a = widgetData.getColor()
			COLOR_PICKER:Show(ColorPickerCallback, r, g, b, a, widgetData.name)
		end
	end)

	-- outline
	local outline = wm:CreateControlFromVirtual(controlName .. "Outline", fb, "ZO_ComboBox")
	fb.outline = outline
	outline:SetDimensions(143, 26)
	outline:SetHandler("OnMouseEnter", function() ZO_Options_OnMouseEnter(fb) end)
	outline:SetHandler("OnMouseExit", function() ZO_Options_OnMouseExit(fb) end)

	outline.dropdown = ZO_ComboBox_ObjectFromContainer(outline)
	outline.dropdown:ClearItems()

	local function OutlineDropdownCallback(self, choiceText, choice)
		fb:UpdateValue(false, nil, nil, choiceText)
	end

	for i = 1, #fontOutlineChoices do
		local entry = outline.dropdown:CreateItemEntry(fontOutlineChoices[i], OutlineDropdownCallback)
		outline.dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
	end

	--size
	local size = wm:CreateControlFromVirtual(controlName .. "Size", fb, "ZO_ComboBox")
	fb.size = size
	size:SetDimensions(54, 26)
	size:SetHandler("OnMouseEnter", function() ZO_Options_OnMouseEnter(fb) end)
	size:SetHandler("OnMouseExit", function() ZO_Options_OnMouseExit(fb) end)

	size.dropdown = ZO_ComboBox_ObjectFromContainer(size)
	size.dropdown:ClearItems()

	local function SizeDropdownCallback(self, choiceText, choice)
		fb:UpdateValue(false, nil, choiceText)
	end

	for i = 1, #fontSizeChoices do
		local entry = size.dropdown:CreateItemEntry(fontSizeChoices[i], SizeDropdownCallback)
		size.dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
	end


	local isHalfWidth = widgetData.width == "half"
	if isHalfWidth then
		fb:SetDimensions(250, 80)
		fb.label:SetDimensions(250, 26)
		face:SetAnchor(TOPLEFT, fb, TOPLEFT, 50, 26)
		color:SetAnchor(TOPLEFT, fb, TOPLEFT, 220, 26)
		outline:SetAnchor(BOTTOMLEFT, fb, BOTTOMLEFT, 50, 0)
		size:SetAnchor(BOTTOMLEFT, fb, BOTTOMLEFT, 196, 0)
	else
		fb:SetDimensions(510, 54)
		fb.label:SetDimensions(300, 26)
		face:SetAnchor(TOPLEFT, fb, TOPLEFT, 310, 0)
		color:SetAnchor(TOPLEFT, fb, TOPLEFT, 480, 0)
		outline:SetAnchor(BOTTOMLEFT, fb, BOTTOMLEFT, 310, 0)
		size:SetAnchor(BOTTOMLEFT, fb, BOTTOMLEFT, 456, 0)
	end


	if (widgetData.warning) then
		fb.warning = wm:CreateControlFromVirtual(nil, fb, "ZO_Options_WarningIcon")
		fb.warning:SetAnchor(RIGHT, face, LEFT, -5, 0)
		fb.warning.data = { tooltipText = widgetData.warning }
	end

	fb.panel = parent.panel or parent	 --if this is in a submenu, panel is its parent
	fb.data = widgetData
	fb.data.tooltipText = widgetData.tooltip

	if widgetData.disabled then
		fb.UpdateDisabled = UpdateDisabled
		fb:UpdateDisabled()
	end

	fb.UpdateValue = UpdateValue
	fb:UpdateValue()

	if fb.panel.data.registerForRefresh or fb.panel.data.registerForDefaults then	 --if our parent window wants to refresh controls, then add this to the list
		tinsert(fb.panel.controlsToRefresh, fb)
	end

	return fb
end
