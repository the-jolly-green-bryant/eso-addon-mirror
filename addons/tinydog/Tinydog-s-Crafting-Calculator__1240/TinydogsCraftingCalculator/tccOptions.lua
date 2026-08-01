-- TinydogsCraftingCalculator Options LUA File
-- Last Updated June 27, 2024
-- Created December 2015 by @tinydog - tinydog1234@hotmail.com

function tcc_RegisterAddonSettingsMenu()
	local panelData = {
		type = "panel",
		name = "Tinydog's Crafting Calculator",
		displayName = "|cFFFF32Tinydog's|r|cFFFFAA Crafting Calculator|r |t32:32:TinydogsCraftingCalculator/dog.dds|t",
		author = "@tinydog",
		version = tcc.Version,
		slashCommand = "/tccoptions",	--(optional) will register a keybind to open to this panel
		registerForRefresh = false,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
		registerForDefaults = false,	--boolean (optional) (will set all options controls back to default values)
	}

	local optionsTable = {
		[1] = {
			type = "header",
			name = "Commands",
		},
		[2] = {
			type = "description",
			text = "|cFFFF00/tcc|r - Show or hide Tinydog's Crafting Calculator.",
		},
		[3] = {
			type = "description",
			text = "|cFFFF00/tccoptions|r - Show this Addon Settings dialog."
		},
		[4] = {
			type = "description",
			text = "|cCFDCBDTo toggle TCC by pressing a single key:\n" .. 
				"From the game menu click |r|cFFFFFFControls|r|cCFDCBD > |r|cFFFFFFAddon Keybinds|r|cCFDCBD > scroll down to |r|cFFFFFFTinydog's Crafting Calculator|r|cCFDCBD > click |r|cFFFFFFFirst Bind|r|cCFDCBD > press a key (e.g., |r|cFFFF00[F8]|r|cCFDCBD)|r",
		},
		[5] = {
			type = "header",
			name = "Global Options",
		},
		[6] = {
			type = "description",
			title = nil,	--(optional)
			text = "|cCFDCBDThese options apply to all of your characters.|r"
		},
		[7] = {
			type = "checkbox",
			name = "Share the same Item Order across all characters",
			tooltip = "If disabled, each character will retain their own Item Order list.",
			getFunc = function() return tcc_GetOption_ShareItemOrder() end,
			setFunc = function(value) tcc_SetOption_ShareItemOrder(value) end,
		},
	}

	local menu = LibAddonMenu2
	menu:RegisterAddonPanel("tccOptions", panelData)
	menu:RegisterOptionControls("tccOptions", optionsTable)
end

function tcc_GetOption_ShareItemOrder()
	return (tcc.SavedVars.Global.Scope.ItemOrder ~= nil and tcc.SavedVars.Global.Scope.ItemOrder == "Global")
end

function tcc_SetOption_ShareItemOrder(isGlobalScope)
	tcc.SavedVars.Global.Scope.ItemOrder = (isGlobalScope and "Global" or "Local")
	if isGlobalScope then 
		if tcc.SavedVars.Local.OrderItemData ~= nil then 
			tcc.SavedVars.Global.OrderItemData = tcc.SavedVars.Local.OrderItemData 
			tcc.SavedVars.Local.OrderItemData = nil
		end
	else
		if tcc.SavedVars.Global.OrderItemData ~= nil then 
			tcc.SavedVars.Local.OrderItemData = tcc.SavedVars.Global.OrderItemData 
			tcc.SavedVars.Global.OrderItemData = nil
		end
	end
end

--function tcc_GetOption_