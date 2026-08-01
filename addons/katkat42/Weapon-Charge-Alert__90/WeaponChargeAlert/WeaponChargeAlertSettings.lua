WeaponChargeAlertSettings = ZO_Object:Subclass()

local LAM = LibStub("LibAddonMenu-2.0")
local settings = nil

-----------------------------
--UTIL FUNCTIONS
-----------------------------

local function RGBAToHex( r, g, b, a )
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x%02x", r * 255, g * 255, b * 255, a * 255)
end

local function HexToRGBA( hex )
    local rhex, ghex, bhex, ahex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end

------------------------------
--OBJECT FUNCTIONS
------------------------------

function WeaponChargeAlertSettings:New()
	local obj = ZO_Object.New(self)
	obj:Initialize()
	return obj
end

function WeaponChargeAlertSettings:Initialize()
	local defaults = {
		offsetX = 0.625,
		offsetY = 0.125,

		firstAlert = false,
		lowAlert = true,
		emptyAlert = true,

		firstThreshold = 0.5,
		lowThreshold = 0.2,

		firstColor = "ffff00ff",
		lowColor = "ff4000ff",
		emptyColor = "ff0000ff",

		locked = true,
		alpha = 0.9,
		scale = 1,
		direction = "horizontal",
		
		apiVersion = GetAPIVersion()
	}

	settings = ZO_SavedVars:NewAccountWide("WeaponChargeAlert_Settings", 1, nil, defaults)

	self.WCAControl = nil
    self:CreateOptionsMenu()
end

function WeaponChargeAlertSettings:SetMainWindow(window)
	self.WCAControl = window
end

function WeaponChargeAlertSettings:GetOffsetX()
	return GuiRoot:GetWidth() * settings.offsetX
end

function WeaponChargeAlertSettings:SetOffsetX( offsetX )
	settings.offsetX = offsetX / GuiRoot:GetWidth()
end

function WeaponChargeAlertSettings:GetOffsetY()
	return GuiRoot:GetHeight() * settings.offsetY
end

function WeaponChargeAlertSettings:SetOffsetY( offsetY )
	settings.offsetY = offsetY / GuiRoot:GetHeight()
end

function WeaponChargeAlertSettings:IsFirstAlert()
	return settings.firstAlert
end

function WeaponChargeAlertSettings:IsLowAlert()
	return settings.lowAlert
end

function WeaponChargeAlertSettings:IsEmptyAlert()
	return settings.emptyAlert
end

function WeaponChargeAlertSettings:GetFirstThreshold()
	return settings.firstThreshold
end

function WeaponChargeAlertSettings:GetLowThreshold()
	return settings.lowThreshold
end

function WeaponChargeAlertSettings:GetFirstColor()
	return HexToRGBA(settings.firstColor)
end

function WeaponChargeAlertSettings:GetLowColor()
	return HexToRGBA(settings.lowColor)
end

function WeaponChargeAlertSettings:GetEmptyColor()
	return HexToRGBA(settings.emptyColor)
end

function WeaponChargeAlertSettings:IsLocked()
	return settings.locked
end

function WeaponChargeAlertSettings:SetLocked( isLocked )
	settings.locked = isLocked
	if(self.WCAControl) then
		self.WCAControl:SetMovable(not isLocked)
		self.WCAControl:SetHidden(isLocked)
		self.WCAControl.MOVE_SPACER:SetHidden(isLocked)
	end
	WeaponChargeAlert_UpdateAllAlerts()
end

function WeaponChargeAlertSettings:GetAlpha()
	return settings.alpha
end

function WeaponChargeAlertSettings:GetScale()
	return settings.scale
end

function WeaponChargeAlertSettings:GetOrientation()
	return settings.direction
end

function WeaponChargeAlertSettings:CreateOptionsMenu()
	local str = WeaponChargeAlert_Strings[self:GetLanguage()]

	local lowMin = .01
	local lowMax = .60
	local firstMin = .02
	local firstMax = .90

	local panel = {
		type = "panel",
		name = "Weapon Charge Alert",
		author = "ingeniousclown, katkat42 and Harven",
		version = "1.1.24",
		slashCommand = "/weaponchargealertsettings",
		registerForRefresh = true
	}

	local optionsData = { }
	table.insert(optionsData,  {
		type = "header",
		name = str.HEADER_GENERAL,
	})

	table.insert(optionsData, {
		type = "checkbox",
		name = str.LOCK_LABEL,
		tooltip = str.LOCK_TOOLTIP,
		getFunc = function() return settings.locked end,
		setFunc = function(value)
			self:SetLocked(value)
		end
	})

	table.insert(optionsData, {
		type = "slider",
		name = str.ALPHA_LABEL,
		tooltip = str.ALPHA_TOOLTIP,
		min = 5,
		max = 100,
		step = 1,
		getFunc = function() return settings.alpha * 100 end,
		setFunc = function(value)
			settings.alpha = value / 100
			self.WCAControl:SetAlpha(value / 100)
		end
	})

	table.insert(optionsData, {
		type = "slider",
		name = str.SCALE_LABEL,
		tooltip = str.SCALE_TOOLTIP,
		min = 25,
		max = 200,
		step = 5,
		getFunc = function() return settings.scale * 100 end,
		setFunc = function(value)
			settings.scale = value / 100
			self.WCAControl:SetScale(value / 100)
		end
	})

	table.insert(optionsData, {
		type = "dropdown",
		name = str.DIRECTION_LABEL,
		tooltip = str.DIRECTION_TOOLTIP,
		choices = { str.DIRECTION_HORIZONTAL, str.DIRECTION_VERTICAL },
		getFunc = function() 
			if settings.direction == "horizontal" then return str.DIRECTION_HORIZONTAL end
			if settings.direction == "vertical" then return str.DIRECTION_VERTICAL end
			d("Error in Weapon Charge Alert menu direction getter: possible corrupted save file?")
			return str.DIRECTION_HORIZONTAL -- can't happen
		end,
		setFunc = function(value)
			if value == str.DIRECTION_VERTICAL then 
				settings.direction = "vertical"
				self.WCAControl.CONTAINER.MAIN_WEAPON:ClearAnchors()
				self.WCAControl.CONTAINER.MAIN_WEAPON:SetAnchor(TOP, self.WCAControl.CONTAINER, TOP)
				WeaponChargeAlert_UpdateAllAlerts()
			else
				settings.direction = "horizontal"
				self.WCAControl.CONTAINER.MAIN_WEAPON:ClearAnchors()
				self.WCAControl.CONTAINER.MAIN_WEAPON:SetAnchor(LEFT, self.WCAControl.CONTAINER, LEFT)
				WeaponChargeAlert_UpdateAllAlerts()
			end
		end
	})

	table.insert(optionsData, {
		type = "header",
		name = str.HEADER_ALERT,
	})

	table.insert(optionsData, {
		type = "checkbox",
		name = str.FIRST_TOGGLE_LABEL,
		tooltip = str.FIRST_TOGGLE_TOOLTIP,
		getFunc = function() return settings.firstAlert end,
		setFunc = function(value)
			settings.firstAlert = value
			WeaponChargeAlert_UpdateAllAlerts()
		end
	})

	table.insert(optionsData, {
		type = "slider",
		name = str.FIRST_SLIDER_LABEL,
		tooltip = str.FIRST_SLIDER_TOOLTIP,
		min = firstMin * 100,
		max = firstMax * 100,
		step = 1,
		getFunc = function() return settings.firstThreshold * 100 end,
		setFunc = function(value)
			settings.firstThreshold = value / 100
			WeaponChargeAlert_UpdateAllAlerts()
			if (settings.lowThreshold >= settings.firstThreshold) then
				settings.lowThreshold = settings.firstThreshold - 0.01
				local ls = WeaponChargeAlert_Low_Slider["slidervalue"]
				ls:SetText((settings.lowThreshold - lowMin) / (lowMax - lowMin))
			end
		end,
		reference = "WeaponChargeAlert_First_Slider",
		disabled = function() return not settings.firstAlert end
	})

	table.insert(optionsData, {
		type = "colorpicker",
		name = str.FIRST_COLOR_LABEL,
		tooltip = str.FIRST_COLOR_TOOLTIP,
		getFunc = function()
			local r, g, b, a = HexToRGBA(settings.firstColor)
			return r, g, b
		end,
		setFunc = function(r, g, b)
			settings.firstColor = RGBAToHex(r, g, b, 1)
			WeaponChargeAlert_UpdateAllAlerts()
		end,
		disabled = function() return not settings.firstAlert end
	})

	table.insert(optionsData, {
		type = "checkbox",
		name = str.LOW_TOGGLE_LABEL,
		tooltip = str.LOW_TOGGLE_TOOLTIP,
		getFunc = function() return settings.lowAlert end,
		setFunc = function(value)
			settings.lowAlert = value
			WeaponChargeAlert_UpdateAllAlerts()
		end
	})

	table.insert(optionsData, {
		type = "slider",
		name = str.LOW_SLIDER_LABEL,
		tooltip = str.LOW_SLIDER_TOOLTIP,
		min = lowMin * 100,
		max = lowMax * 100, 
		step = 1,
		getFunc = function() return settings.lowThreshold * 100 end,
		setFunc = function(value)
			settings.lowThreshold = value / 100
			WeaponChargeAlert_UpdateAllAlerts()
			if (settings.lowThreshold >= settings.firstThreshold) then
				settings.firstThreshold = settings.lowThreshold + 0.01
				local fs = WeaponChargeAlert_First_Slider["slidervalue"]
				fs:SetText((settings.firstThreshold - firstMin) / (firstMax - firstMin))
			end
		end,
		reference = "WeaponChargeAlert_Low_Slider",
		disabled = function() return not settings.lowAlert end
	})

	table.insert(optionsData, {
		type = "colorpicker",
		name = str.LOW_COLOR_LABEL,
		tooltip = str.LOW_COLOR_TOOLTIP,
		getFunc = function()
			local r, g, b, a = HexToRGBA(settings.lowColor)
			return r, g, b
		end,
		setFunc = function(r, g, b)
			settings.lowColor = RGBAToHex(r, g, b, 1)
			WeaponChargeAlert_UpdateAllAlerts()
		end,
		disabled = function() return not settings.lowAlert end
	})

	table.insert(optionsData, {
		type = "checkbox",
		name = str.EMPTY_TOGGLE_LABEL,
		tooltip = str.EMPTY_TOGGLE_TOOLTIP,
		getFunc = function() return settings.emptyAlert end,
		setFunc = function(value)
			settings.emptyAlert = value
			WeaponChargeAlert_UpdateAllAlerts()
		end
	})

	table.insert(optionsData, {
		type = "colorpicker",
		name = str.EMPTY_COLOR_LABEL,
		tooltip = str.EMPTY_COLOR_TOOLTIP,
		getFunc = function()
			local r, g, b, a = HexToRGBA(settings.emptyColor)
			return r, g, b
		end,
		setFunc = function(r, g, b)
			settings.emptyColor = RGBAToHex(r, g, b, 1)
			WeaponChargeAlert_UpdateAllAlerts()
		end,
		disabled = function() return not settings.emptyAlert end
	})

	LAM:RegisterAddonPanel("WeaponChargeAlertSettingsPanel", panel)
	LAM:RegisterOptionControls("WeaponChargeAlertSettingsPanel", optionsData)
end

function WeaponChargeAlertSettings:GetLanguage()
	local lang = GetCVar("language.2")

	--check for supported languages
	if(lang == "en") then return lang end

	--return english if not supported
	return "en"
end