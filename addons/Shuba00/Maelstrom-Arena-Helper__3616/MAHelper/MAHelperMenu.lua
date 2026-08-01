local MAH = MAHelper

function MAH.Menu(savedVars)

	local panelInfo = {
        type = 'panel',
        name = 'Maelstrom Arena Helper',
        displayName = 'Maelstrom Arena Helper',
        author = "|c9684B1Shuba00|r",
        version = MAH.Versione,
        registerForRefresh = true
    }
	
    LibAddonMenu2:RegisterAddonPanel(MAH.name .. "Options", panelInfo)
	
	local optionsData = {
			 [1] = {
			type = "submenu",
			name = "Arrow Options",
			tooltip = "Arrow SubMenu",	--(optional)
			controls = {
				[1] = {
					type = "checkbox",
					name = "Arrow CheckBox",
					getFunc = function() return savedVars.ArrowV end,
					setFunc = function(value) savedVars.ArrowV = value end,
				},
				[2] = {
					type = "colorpicker",
					name = "Trash Color Picker",
					tooltip = "Color Picker's trash add.",
					getFunc = function() return unpack(savedVars.arrowColorArr[1]) end,	--(alpha is optional)
					setFunc = function(r,g,b,a) MAHelper.UpdateArrowColor(r,g,b,a,1) end,	--(alpha is optional)
				},
				[3] = {
					type = "colorpicker",
					name = "Big Add Color Picker",
					tooltip = "Color Picker's big Mob.",
					getFunc = function() return unpack(savedVars.arrowColorArr[2]) end,	--(alpha is optional)
					setFunc = function(r,g,b,a) MAHelper.UpdateArrowColor(r,g,b,a,2) end,	--(alpha is optional)
				},
				[4] = {
					type = "colorpicker",
					name = "Boss Color Picker",
					tooltip = "Color Picker's Boss.",
					getFunc = function() return unpack(savedVars.arrowColorArr[3]) end,	--(alpha is optional)
					setFunc = function(r,g,b,a) MAHelper.UpdateArrowColor(r,g,b,a,3) end,	--(alpha is optional)
				},
				[5] = {
					type = "slider",
					name = "Arrow Size",
					getFunc = function()  return savedVars.arrowScale * 100 end,
					setFunc = function(value) MAHelper.UpdateArrowScale(value)  end,
					default = savedVars.arrowScale * 100,
					min = 50,
					max = 120,
					reference = "MyAddonSlider"
				},
				[6] = {
					type = "slider",
					name = "Arrow Timer",
					getFunc = function()  return savedVars.arrowTime /1000 end,
					setFunc = function(value) MAHelper.UpdateArrowTime(value)  end,
					default = savedVars.arrowTime/ 1000,
					min = 2,
					max = 10,
				},
			},
		},
		[2] = {
        type = "submenu",
			name = "Icon Options",
			tooltip = "Icon SubMenu",	--(optional)
			controls = {
				[1] = {
					type = "checkbox",
					name = "Icon CheckBox",
					getFunc = function() return savedVars.vIcon end,
					setFunc = function(value) savedVars.vIcon = value end,
				},
				[2] = {
					type = "slider",
					name = "Slider Icon",
					getFunc = function()  return savedVars.size end,
					setFunc = function(value) MAHelper.UpdateIconSize(value)  end,
					default = savedVars.size,
					min = 70,
					max = 150,
					reference = "SliderIconMAH"
				},
			},
		},
	 	[3] = {
        	type = "submenu",
			name = "Text Options",
			controls = {
				[1] ={
					type = "checkbox",
					name = "Change Text Position",
					getFunc = function() return savedVars.tv end,
					setFunc = function(value) MAHelper.ChangeVisText(value) end,
					default = false,
					width = "half",	--or "full" (optional)
				},
				[2] ={
					type = "checkbox",
					name = "Change Text Visibility",
					getFunc = function() return savedVars.TextVis end,
					setFunc = function(value) savedVars.TextVis = value end,
					default = false,
					width = "half",	--or "full" (optional)
				},
				[3] = 	 {
					type = "button",
					name = "Restore Position",
					tooltip = "Restore Text Position",
					func = function() MAHelper.RestorePos() end,
					width = "half",	--or "full" (optional)
				},
			},
		},

		[4] = 	 {
				 type = "button",
				 name = "Try me!",
				 tooltip = "Try arrow and icon.",
				 func = function() MAHelper.ButtonTry() end,
				 width = "half",	--or "full" (optional)
			 },
	 }
    

	LibAddonMenu2:RegisterOptionControls(MAH.name .. "Options", optionsData)
end 