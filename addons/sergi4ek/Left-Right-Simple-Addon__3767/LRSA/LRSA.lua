--[[
-------------------------------------------------------------------------------
LRSA, by @Sergi4ek
-------------------------------------------------------------------------------

A simple addon to display the directions of the left and right sides. Created for educational purposes

You can use e-mail for communication: 
seppo.ranta@ya.ru
]]

-- Main

LRSA = {
	name = "LRSA",
	version = "1.2.2",
	author = "@Sergi4ek",
	description = "LRSA",
	url = "https://www.esoui.com/downloads/info3767-LeftRightSimpleAddon.html"
}
LRSA.defaults = 
{
	fontSize = 40,
	font = "GAMEPAD_LIGHT_FONT",
	fontColor = {
		r = 0,
		g = 255,
		b = 255,
		a = 255,
	},
	visibileLabels = true,
	XCoor = 600,
	YCoor = 300,
}
LRSA.savedVariables = {}

-- Local variables

local EVENT_MANAGER = GetEventManager()

-- Sets the text of LRSALeftLabel and LRSARightLabel to leftstr and rightstr respectively

local function showLRLabels()
	if (os.date("%d")=="01") and (os.date("%m")=="04") then
		LRSALeftLabel:SetText("← " .. GetString(LRSA_RIGHT_STR))
		LRSARightLabel:SetText(GetString(LRSA_LEFT_STR) .. " →")
	else
		LRSALeftLabel:SetText("← " .. GetString(LRSA_LEFT_STR))
		LRSARightLabel:SetText(GetString(LRSA_RIGHT_STR) .. " →")
	end
end

local function ShowLR()
	LRSALeftLabel:SetHidden(false)
	LRSARightLabel:SetHidden(false)
	LRSA.savedVariables.visibileLabels = true
end

local function HiddenLR()
	LRSALeftLabel:SetHidden(true)
	LRSARightLabel:SetHidden(true)
	LRSA.savedVariables.visibileLabels = false
end

-- Functions of Settings

local function getVisibility()
	return LRSA.savedVariables.visibileLabels
end

local function setVisibility(v)
	if (v == true) then
		ShowLR()
	else
		HiddenLR()
	end
end

local function setFont(font)
	--LRSALeftLabel:SetFont("$(".. font .. ")|$(KB_" .. getFontSize() .. ")|soft-shadow-thick")
	--LRSARightLabel:SetFont("$(".. font .. ")|$(KB_" .. getFontSize() .. ")|soft-shadow-thick")
	LRSA.savedVariables.font = font
end

local function getFont()
	return LRSA.savedVariables.font
end

local function getFontSize()
	return LRSA.savedVariables.fontSize
end

local function setFontSize(v)
	local value = v

	local case = {
		[27] = function ()
			value = 26
		end,
		[29] = function ()
			value = 28
		end,
		[31] = function ()
			value = 30
		end,
		[33] = function ()
			value = 32
		end,
		[35] = function ()
			value = 34
		end,
		[37] = function ()
			value = 36
		end,
		[38] = function ()
			value = 36
		end,
		[39] = function ()
			value = 40
		end,
	}

	if case[value] then
		case[value]()
	end

	LRSALeftLabel:SetFont("$(" .. LRSA.savedVariables.font .. ")|$(KB_" .. value .. ")|soft-shadow-thick")
	LRSARightLabel:SetFont("$(" .. LRSA.savedVariables.font .. ")|$(KB_" .. value .. ")|soft-shadow-thick")
	LRSA.savedVariables.fontSize = value
end

local function getXCoor()
	return LRSA.savedVariables.XCoor
end

local function setXCoor(x)
	local valueX = x
	local valueY = LRSA.savedVariables.YCoor

	LRSALeft:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, valueX, valueY)
	LRSARight:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -valueX, valueY)

	LRSA.savedVariables.XCoor = valueX
end

local function getYCoor()
	return LRSA.savedVariables.YCoor
end

local function setYCoor(y)
	local valueX = LRSA.savedVariables.XCoor
	local valueY = y

	LRSALeft:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, valueX, valueY)
	LRSARight:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -valueX, valueY)

	LRSA.savedVariables.YCoor = valueY
end

local function getFontColor()
	return LRSA.savedVariables.fontColor.r, LRSA.savedVariables.fontColor.g, LRSA.savedVariables.fontColor.b, LRSA.savedVariables.fontColor.a
end

local function setFontColor(r, g, b, a)
	LRSALeftLabel:SetColor(r, g, b, a)
	LRSARightLabel:SetColor(r, g, b, a)
	LRSA.savedVariables.fontColor.r = r
	LRSA.savedVariables.fontColor.g = g
	LRSA.savedVariables.fontColor.b = b
	LRSA.savedVariables.fontColor.a = a
end

-- Initialize
---@return table panel

local function initializeLRSA()
	setVisibility(LRSA.savedVariables.visibileLabels)
	setFontSize(LRSA.savedVariables.fontSize)
	setFont(LRSA.savedVariables.font)
	setFontColor(
		LRSA.savedVariables.fontColor.r,
		LRSA.savedVariables.fontColor.g,
		LRSA.savedVariables.fontColor.b,
		LRSA.savedVariables.fontColor.a
	)
	setXCoor(LRSA.savedVariables.XCoor)
	setYCoor(LRSA.savedVariables.YCoor)

	local LAM = LibAddonMenu2
	local panelName = "LRSAOptions"
	local panelData = {
		type = "panel",
		name = "Left Right Simple Addon",
		author = "@Sergi4ek",
	}

	local optionsData = {
		[1] =
		{
			type = "checkbox",
			name = GetString(LRSA_CHECKBOX1_NAME),
			tooltip = GetString(LRSA_CHECKBOX1_TOOLTIP),
			getFunc = function () return getVisibility() end,
			setFunc = function (value) setVisibility(value) end,
		},
		[2] =
		{
			type = "slider",
			name = GetString(LRSA_SLIDER1_NAME),
			tooltip = GetString(LRSA_SLIDER1_TOOLTIP),
			getFunc = function () return getFontSize() end,
			setFunc = function (value) setFontSize(value) end,
			min = 8,
			max = 40,
		},
		[3] =
		{
			type = "colorpicker",
			name = GetString(LRSA_COLORPICKER1_NAME),
			tooltip = GetString(LRSA_COLORPICKER1_TOOLTIP),
			getFunc = function () return getFontColor() end,
			setFunc = function (r, g, b, a) setFontColor(r, g, b, a) end,
		},
		[4] =
		{
			type = "slider",
			name = GetString(LRSA_SLIDER2_NAME),
			tooltip = GetString(LRSA_SLIDER2_TOOLTIP),
			getFunc = function () return getXCoor() end,
			setFunc = function (value) setXCoor(value) end,
			min = 0,
			max = 1800,
		},
		[5] =
		{
			type = "slider",
			name = GetString(LRSA_SLIDER3_NAME),
			tooltip = GetString(LRSA_SLIDER3_TOOLTIP),
			getFunc = function () return getYCoor() end,
			setFunc = function (value) setYCoor(value) end,
			min = 0,
			max = 1800,
		},

	}
	local panel = LAM:RegisterAddonPanel(panelName, panelData)
	LAM:RegisterOptionControls(panelName, optionsData)
	return panel
end

LRSA.OnAddOnLoaded = function (event, name)
	if name ~= "LRSA" then
		EVENT_MANAGER:UnregisterForEvent("LRSA", EVENT_ADD_ON_LOADED)
		LRSA.savedVariables = ZO_SavedVars:NewAccountWide("LRSAVars", 1, nil, LRSA.defaults)
		initializeLRSA()
		showLRLabels()
		SLASH_COMMANDS["/showlr"] = ShowLR
		SLASH_COMMANDS["/hiddenlr"] = HiddenLR
	end
end

EVENT_MANAGER:RegisterForEvent(LRSA.name, EVENT_ADD_ON_LOADED, LRSA.OnAddOnLoaded)
