local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
function GRT.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Group Regen Tracker",
		displayName = "Group Regen Tracker",
		author = "@Naaa",
		version = "6.0",
		slashCommand = "/grt setting",	--(optional) will register a keybind to open to this panel
		registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
		registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("GroupRegenTracker", panelData)
	local d = GRT.SavedVar.Default
	local s = GRT.SavedVar.savedVariables
	local optionsData = {
		[1] = {
			type = "slider",
			name = "Update interval(MilliSec)",
			min = 100,
			max = 1000,
			step = 50,	--(optional)
			getFunc = function() s.barfreq = s.barfreq or d.barfreq return s.barfreq end,
			setFunc = function(value)
			  s.barfreq = value
			  GRT.EventRegisterUpdate()
			end,
		},
		[2] = {
			type = "slider",
			name = "Bar Height",
			min = 1,
			max = 18,
			step = 1,	--(optional)
			getFunc = function() s.barHeight = s.barHeight or d.barHeight return s.barHeight end,
			setFunc = function(value)
			  s.barHeight = value
			  GRT.UI.ReflectSetting()
			end,
		},
		[3] = {
			type = "slider",
			name = "OffsetX",
			min = -15,
			max = 15,
			step = 1,	--(optional)
			getFunc = function() s.barOffsetX = s.barOffsetX or d.barOffsetX return s.barOffsetX end,
			setFunc = function(value)
			  s.barOffsetX = value
			  GRT.UI.ReflectSetting()
			end,
		},
		[4] = {
			type = "slider",
			name = "OffsetY",
			min = -20,
			max = 20,
			step = 1,	--(optional)
			getFunc = function() s.barOffsetY = s.barOffsetY or d.barOffsetY return s.barOffsetY end,
			setFunc = function(value)
			  s.barOffsetY = value
			  GRT.UI.ReflectSetting()
			end,
		},
		[5] = {
			type = "slider",
			name = "After 2nd Bar OffsetY",
			min = -20,
			max = 20,
			step = 1,	--(optional)
			getFunc = function() s.after2ndBarOffsetY = s.after2ndBarOffsetY or d.after2ndBarOffsetY return s.after2ndBarOffsetY end,
			setFunc = function(value)
			  s.after2ndBarOffsetY = value
			  GRT.UI.ReflectSetting()
			end,
		},
	--Color
		[6] = {
			type = "submenu",
			name = "Color",
			controls = {
				{	--"RegenBar GradientColor1 "
					type = "colorpicker",
					name = "RegenBar GradientColor1 ",
					getFunc = function() return unpack(s.bar["Regen"].color1 or d.bar["Regen"].color1) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["Regen"].color1 = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"RegenBar GradientColor2 "
					type = "colorpicker",
					name = "RegenBar GradientColor2",
					getFunc = function() return unpack(s.bar["Regen"].color2 or d.bar["Regen"].color2) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["Regen"].color2 = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"RegenBar Gloss GradientColor1 "
					type = "colorpicker",
					name = "RegenBar Gloss GradientColor1",
					getFunc = function() return unpack(s.bar["Regen"].color1gloss or d.bar["Regen"].color1gloss) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["Regen"].color1gloss = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"RegenBar Gloss GradientColor2 "
					type = "colorpicker",
					name = "RegenBar Gloss GradientColor2",
					getFunc = function() return unpack(s.bar["Regen"].color2gloss or d.bar["Regen"].color2gloss) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["Regen"].color2gloss = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
--
				{	--"Shield GradientColor1 "
					type = "colorpicker",
					name = "Shield GradientColor1 ",
					getFunc = function() return unpack(s.bar["Shield"].color1 or d.bar["Shield"].color1) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["Shield"].color1 = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"Shield GradientColor2 "
					type = "colorpicker",
					name = "Shield GradientColor2",
					getFunc = function() return unpack(s.bar["Shield"].color2 or d.bar["Shield"].color2) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["Shield"].color2 = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"Shield Gloss GradientColor1 "
					type = "colorpicker",
					name = "Shield Gloss GradientColor1",
					getFunc = function() return unpack(s.bar["Shield"].color1gloss or d.bar["Shield"].color1gloss) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["Shield"].color1gloss = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"Shield Gloss GradientColor2 "
					type = "colorpicker",
					name = "Shield Gloss GradientColor2",
					getFunc = function() return unpack(s.bar["Shield"].color2gloss or d.bar["Shield"].color2gloss) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["Shield"].color2gloss = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
--
				{	--"CombatPlayer GradientColor1 "
					type = "colorpicker",
					name = "CombatPlayer GradientColor1 ",
					getFunc = function() return unpack(s.bar["CP"].color1 or d.bar["CP"].color1) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["CP"].color1 = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"CombatPlayer GradientColor2 "
					type = "colorpicker",
					name = "CombatPlayer GradientColor2",
					getFunc = function() return unpack(s.bar["CP"].color2 or d.bar["CP"].color2) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["CP"].color2 = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"CombatPlayer Gloss GradientColor1 "
					type = "colorpicker",
					name = "CombatPlayer Gloss GradientColor1",
					getFunc = function() return unpack(s.bar["CP"].color1gloss or d.bar["CP"].color1gloss) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["CP"].color1gloss = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"CombatPlayer Gloss GradientColor2 "
					type = "colorpicker",
					name = "CombatPlayer Gloss GradientColor2",
					getFunc = function() return unpack(s.bar["CP"].color2gloss or d.bar["CP"].color2gloss) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["CP"].color2gloss = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
--
				{	--"SpellPowerCure GradientColor1 "
					type = "colorpicker",
					name = "SpellPowerCure GradientColor1 ",
					getFunc = function() return unpack(s.bar["SPC"].color1 or d.bar["SPC"].color1) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["SPC"].color1 = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"SpellPowerCure GradientColor2 "
					type = "colorpicker",
					name = "SpellPowerCure GradientColor2",
					getFunc = function() return unpack(s.bar["SPC"].color2 or d.bar["SPC"].color2) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["SPC"].color2 = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"SpellPowerCure Gloss GradientColor1 "
					type = "colorpicker",
					name = "SpellPowerCure Gloss GradientColor1",
					getFunc = function() return unpack(s.bar["SPC"].color1gloss or d.bar["SPC"].color1gloss) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["SPC"].color1gloss = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"SpellPowerCure Gloss GradientColor2 "
					type = "colorpicker",
					name = "SpellPowerCure Gloss GradientColor2",
					getFunc = function() return unpack(s.bar["SPC"].color2gloss or d.bar["SPC"].color2gloss) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["SPC"].color2gloss = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
--
				{	--"Spear GradientColor1 "
					type = "colorpicker",
					name = "Spear GradientColor1 ",
					getFunc = function() return unpack(s.bar["Spear"].color1 or d.bar["Spear"].color1) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["Spear"].color1 = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"Spear GradientColor2 "
					type = "colorpicker",
					name = "Spear GradientColor2",
					getFunc = function() return unpack(s.bar["Spear"].color2 or d.bar["Spear"].color2) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["Spear"].color2 = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"Spear Gloss GradientColor1 "
					type = "colorpicker",
					name = "Spear Gloss GradientColor1",
					getFunc = function() return unpack(s.bar["Spear"].color1gloss or d.bar["Spear"].color1gloss) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["Spear"].color1gloss = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
				{	--"Spear Gloss GradientColor2 "
					type = "colorpicker",
					name = "Spear Gloss GradientColor2",
					getFunc = function() return unpack(s.bar["Spear"].color2gloss or d.bar["Spear"].color2gloss) end,	--(alpha is optional)
					setFunc = function(r,g,b,a)
						s.bar["Spear"].color2gloss = {r,g,b,a}
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
					width = "half"
				},
			},
		},
		[7] = {
			type = "submenu",
			name = "Bars",
			controls = {
				{
				type = "checkbox",
				name = "Shield(beta)",
				getFunc = function() return s.bar["Shield"].enable or d.bar["Shield"].enable end,	--(alpha is optional)
				setFunc = function(value)
					s.bar["Shield"].enable = value
					GRT.UI.ReflectSetting()
				end,	--(alpha is optional)
				},
				{
					type = "checkbox",
					name = "CombatPlayer",
					getFunc = function() return s.bar["CP"].enable or d.bar["CP"].enable end,	--(alpha is optional)
					setFunc = function(value)
						s.bar["CP"].enable = value
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
				},
				{
					type = "checkbox",
					name = "SpellPowerCure",
					getFunc = function() return s.bar["SPC"].enable or d.bar["SPC"].enable end,	--(alpha is optional)
					setFunc = function(value)
						s.bar["SPC"].enable = value
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
				},
				--[[
				{
					type = "checkbox",
					name = "Spear",
					getFunc = function() return s.bar["Spear"].enable or d.bar["Spear"].enable end,	--(alpha is optional)
					setFunc = function(value)
						s.bar["Spear"].enable = value
						GRT.UI.ReflectSetting()
					end,	--(alpha is optional)
				},
				--]]
			},
		},

	}
	LAM2:RegisterOptionControls("GroupRegenTracker", optionsData)
end
