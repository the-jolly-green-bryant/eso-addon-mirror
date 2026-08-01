if not KBLT then KBLT = {} end

function KBLT.MakeMenu()
	local menu = LibAddonMenu2
	local set = KBLT.settings
	local strings = KBLT.strings[KBLT.lang]
	
	local panel = {
		type = "panel",
		name = KBLT.name,
		displayName = KBLT.name,
		author = KBLT.author,
		version = KBLT.version,
	}
	menu:RegisterAddonPanel("KBLTMenu", panel)
	
	local options = {}
	table.insert(options, {
		type = "header",
		name = strings.MENU_WINDOW_HEADER,
	})
	table.insert(options, {
		type = "slider",
		name = strings.MENU_WINDOW_ALPHA,
		tooltip = strings.MENU_WINDOW_ALPHA_TOOLTIP,
		min = 0,
		max = 100,
		step = 5,
		getFunc = function() return set.alpha end,
		setFunc = function(value)
			set.alpha = value
			KBLT.window.bg:SetCenterColor(0, 0, 0, set.alpha / 100)
			KBLT.window.bg:SetEdgeColor(0, 0, 0, set.alpha / 100)
		end,
		default = 50,
	})
	table.insert(options, {
		type = "dropdown",
		name = strings.MENU_WINDOW_HIGHLIGHT,
		tooltip = strings.MENU_WINDOW_HIGHLIGHT_TOOLTIP,
		choices = {strings.HIGHLIGHT_COMPLETE, strings.HIGHLIGHT_INCOMPLETE},
		getFunc = function() return set.highlight end,
		setFunc = function(value)
			if value == strings.HIGHLIGHT_COMPLETE then
				set.highlight = "Completed"
			elseif value == strings.HIGHLIGHT_INCOMPLETE then
				set.highlight = "Incomplete"
			end
			KBLT.UpdateZone()
		end,
	})
	
	menu:RegisterOptionControls("KBLTMenu", options)
end