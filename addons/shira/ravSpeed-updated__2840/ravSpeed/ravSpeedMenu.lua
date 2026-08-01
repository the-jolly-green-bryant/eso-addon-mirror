------------------------
-- ravSpeed
-- original addon by rav
-- https://www.esoui.com/downloads/info423-ravSpeed.html
--
-- Menu.lua




ravSpeed.panelData = {
	type = "panel",
	name = "ravSpeed",
	author = "rav",
	registerForDefaults = true,
}


-----------------------

ravSpeed.generalPanel = {
	{
		type = "dropdown",
		name = "display style",
		choices = {
			"UPS %", "% UPS", "%", "UPS"
		},
		default = "UPS %",
		getFunc = function() return ravSpeed.SV.displayStyle end,
		setFunc = function(value)
			ravSpeed.SV.displayStyle = tostring(value)
			ravSpeed.SV.showPct = value ~= "UPS"
			ravSpeed.SV.showUps = value ~= "%"
			ravSpeed.setDisplay()
		end
	},
	{
		type = "slider",
		name = "reference speed",
		tooltip = "in UPS",
		min = 1,
		max = 500,
		default = 250,
		clampInput = true,
		getFunc = function() return ravSpeed.SV.referenceSpeed end,
		setFunc = function(value) 
			ravSpeed.SV.referenceSpeed = value
		end
	},
	{
		type = "checkbox",
		name = "lock position",
		default = false,
		getFunc = function() return ravSpeed.SV.isLocked end,
		setFunc = function(value) 
			ravSpeed.SV.isLocked = value
			ravSpeed.setLock()
		end
	},
	{
		type = "checkbox",
		name = "force show",
		default = false,
		getFunc = function() return ravSpeed.SV.forceShow end,
		setFunc = function(value) 
			ravSpeed.SV.forceShow = value
			ravSpeedCtrl:SetHidden(not value)
		end
	},
}


-----------------------

ravSpeed.customPanel = {
	{
		type = "dropdown",
		name = "font name",
		choices = {
			"MEDIUM_FONT", 
			"BOLD_FONT", 
			"CHAT_FONT", 
			"GAMEPAD_LIGHT_FONT", 
			"GAMEPAD_MEDIUM_FONT",
			"GAMEPAD_BOLD_FONT"
		},
		default = "BOLD_FONT",
		getFunc = function() return ravSpeed.SV.fontName end,
		setFunc = function(value)
			ravSpeed.SV.fontName = value 
			ravSpeed.setFont()
		end
	},
	{
		type = "slider",
		name = "font size",
		min = 8,
		max = 26,
		default = 18,
		clampInput = true,
		getFunc = function() return ravSpeed.SV.fontSize end,
		setFunc = function(value) 
			ravSpeed.SV.fontSize = value
			ravSpeed.setFont()
			ravSpeed.setPosition()
		end
	},
	{
		type = "dropdown",
		name = "font style",
		choices = {
			"soft-shadow-thin", 
			"soft-shadow-thick", 
			"thick-outline", 
			"none"
		},
		default = "soft-shadow-thick",
		getFunc = function()
			if ravSpeed.SV.fontStyle == "" then return "none" 
			else return ravSpeed.SV.fontStyle end
		end,
		setFunc = function(value)
			if value == "none" then ravSpeed.SV.fontStyle = ""
			else ravSpeed.SV.fontStyle = value end
			ravSpeed.setFont()
		end
	},
	{
		type = "colorpicker",
		name = "font color",
		default = {r=0.8, g=0.86, b=0.74, a=1},
		getFunc = function() return unpack(ravSpeed.SV.fontColor) end,
		setFunc = function(r, g, b, a)
			ravSpeed.SV.fontColor = {r, g, b, a}
			ravSpeed.setFont()
		end
	}
}


-----------------------

ravSpeed.advGen = {

	{
		type = "description",
		text = "Higher values will result in less calculations at the expense of precision. For lower than 25, enable use OnUpdate under Old behavior."
	},
	{
		type = "slider",
		name = "refresh tick",
		tooltip = "Recommended ~[50-200]",
		clampInput = true,
		min = 25,
		max = 500,
		default = 100,
		getFunc = function() return ravSpeed.SV.refreshRate end,
		setFunc = function(value) 
			ravSpeed.SV.refreshRate = value
			EVENT_MANAGER:UnregisterForUpdate("ravSpeedRefresh")
			EVENT_MANAGER:RegisterForUpdate("ravSpeedRefresh", value, ravSpeed.update)
			ravSpeed.adjustArray()
		end
	},
	{
		type = "checkbox",
		name = "Automatically adjust speed array size",
		tooltip = "Will automatically lower the array size as the refresh interval grows. Disable for custom size below.",
		default = true,
		getFunc = function() return ravSpeed.SV.autoAdjustArray end,
		setFunc = function(value) 
			ravSpeed.SV.autoAdjustArray = value
			ravSpeed.adjustArray()
		end
	},
	{
		type = "slider",
		name = "array size",
		tooltip = "From how many values the average should be calculated. Higher array size means a more stable average speed, lower means quicker to catch up to variations",
		clampInput = true,
		min = 1,
		max = 20,
		default = 10,
		getFunc = function() return ravSpeed.SV.customArraySize end,
		setFunc = function(value)
			ravSpeed.SV.customArraySize = value
			ravSpeed.adjustArray()
		end
	},
}


ravSpeed.advOld = {

	{
		type = "description",
		text = "Enables the original addon behavior, which is to update on every tick of OnUpdate.",
	},
	{
		type = "checkbox",
		name = "use OnUpdate",
		requiresReload = true,
		default = false,
		getFunc = function() return ravSpeed.SV.forceOnUpdate end,
		setFunc = function(value) 
			ravSpeed.SV.forceOnUpdate = value
		end
	},
	{
		type = "checkbox",
		name = "custom array size for OnUpdate",
		tooltip = "will use the specified size under advanced/general/",
		default = false,
		getFunc = function() return ravSpeed.SV.customArrayForOnUpdate end,
		setFunc = function(value) 
			ravSpeed.SV.customArrayForOnUpdate = value
			ravSpeed.queueArrayUpdate = true
			ravSpeed.initDone = false
		end
	},
}


ravSpeed.advDebug = {

	{
		type = "description",
		text = "If you encounter weird speeds across several different zones on flat ground, you can enable this to try to adjust the speed to better values",
	},
	{
		type = "checkbox",
		name = "Enable magic value override",
		tooltip = "won't affect the old behavior",
		default = false,
		getFunc = function() return ravSpeed.SV.overrideMagicValue end,
		setFunc = function(value) 
			ravSpeed.SV.overrideMagicValue = value
			ravSpeed.adjustMagic()
		end
	},
	{
		type = "checkbox",
		name = "Override for old behavior",
		tooltip = "does not require the above to be on",
		default = false,
		getFunc = function() return ravSpeed.SV.overrideforOnUpdate end,
		setFunc = function(value) 
			ravSpeed.SV.overrideforOnUpdate = value
			ravSpeed.adjustMagic()
		end
	},
	{
		type = "slider",
		name = "custom scale",
		tooltip = "value which is used to scale the speed. Default is ~370-375 for ~250ups",
		clampInput = true,
		min = 1,
		max = 1000,
		default = 373,
		getFunc = function() return ravSpeed.SV.customMagicValue end,
		setFunc = function(value) 
			ravSpeed.SV.customMagicValue = value
			ravSpeed.adjustMagic()
		end
	},
}


ravSpeed.advancedPanel = {

	{
		type = "submenu",
		name = "General",
		controls = ravSpeed.advGen
	},
	{
		type = "submenu",
		name = "Old behavior",
		controls = ravSpeed.advOld
	},
	{
		type = "submenu",
		name = "Debug",
		controls = ravSpeed.advDebug
	},

}


-----------------------

ravSpeed.optionsTable = {

	{
		type = "submenu",
		name = "General",
		controls = ravSpeed.generalPanel
	},
	{
		type = "submenu",
		name = "Custom",
		controls = ravSpeed.customPanel
	},
	{
		type = "submenu",
		name = "Advanced",
		controls = ravSpeed.advancedPanel
	},
}


-----------------------

function ravSpeed:settingsMenu()

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel("ravSpeedSettings", ravSpeed.panelData)
	LAM:RegisterOptionControls("ravSpeedSettings", ravSpeed.optionsTable)

end