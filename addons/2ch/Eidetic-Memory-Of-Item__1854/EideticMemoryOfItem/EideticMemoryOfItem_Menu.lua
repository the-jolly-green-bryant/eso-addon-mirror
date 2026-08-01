local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
function EMOI.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Eidetic Memory Of Item",
		displayName = "Eidetic Memory Of Item",
		author = "@Naaa",
		version = "1.0",
		slashCommand = "/emoi setting",	--(optional) will register a keybind to open to this panel
		registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
		registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Eidetic Memory Of Item", panelData)
	local d = EMOI.SavedVar.Default
	local s = EMOI.SavedVar.savedVariables
	local optionsData = {
		[1] = {
			type = "slider",
			name = "FontSize",
			min = 6,
			max = 25,
			step = 1,	--(optional)
			getFunc = function() s.fontSize = s.fontSize or d.fontSize return s.fontSize end,
			setFunc = function(value)
			  s.fontSize = value
			  EMOI.UI.ReflectSetting()
			end,
		},
		[2] = {
			type = "slider",
			name = "page lines",
			min = 10,
			max = 100,
			step = 5,	--(optional)
			getFunc = function() s.pageLines = s.pageLines or d.pageLines return s.pageLines end,
			setFunc = function(value)
			  s.pageLines = value
			  EMOI.UI.ReflectSetting()
			end,
		},
		[3] = {
			type = "checkbox",
			name = "Added message",
			getFunc = function() s.addedLog = s.addedLog or d.addedLog return s.addedLog end,
			setFunc = function(value)
			  s.addedLog = value
			end,
		},
		[4] = {
			type = "checkbox",
			name = "Automatically add",
			getFunc = function() s.auto = s.auto or d.auto return s.auto end,
			setFunc = function(value)
			  s.auto = value
			end,
		},
	}
	LAM2:RegisterOptionControls("Eidetic Memory Of Item", optionsData)
end
