-- sentry to make sure BT is declared before use
if BT == nil then BT = {} end

--
-- Register with LibMenu and ESO

local wasMenuCreated = false
--
function BT.CreateMenu()

	if wasMenuCreated then return end

    --local btw = BT.window
	
    -- the panel for the addons menu
	local panel = {
		type = "panel",
		name = "Bite Timers",
		displayName = "Bite Timers",
		author = "Cosh",
        version = "" .. BT.version,
		registerForRefresh = true,
	}

    -- this addons entries in the addon menu
	local options = {
		[1] = {
			type = "header",
			name = "Window Settings",
		},
		[2] = {
			type = "slider",
			name = "Window Background Alpha",
			tooltip = "How transparent or opaque should the window background be?",
			min = 0,
			max = 100,
			step = 5,
			getFunc = function() return activeCharSettings.alpha end,
			setFunc = function(value) 
				activeCharSettings.alpha = value
				btw.bg:SetCenterColor(0, 0, 0, activeCharSettings.alpha / 100)
				btw.bg:SetEdgeColor(0, 0, 0, activeCharSettings.alpha / 100)
			end,
			default = 60,
		},
		[3] = {
			type = "checkbox",
			name = "Show Title",
			tooltip = "Display the add-on title in the window?",
			getFunc = function() return activeCharSettings.showtitle end,
			setFunc = function(value)
				activeCharSettings.showtitle = value
				btw.title:SetHidden(not activeCharSettings.showtitle)

				if activeCharSettings.showtitle then
					btw.entries:SetAnchor(TOP, btw.title, BOTTOM, 0, 0)
				else
					btw.entries:SetAnchor(TOP, btw, TOP, 0, 0)
				end
			end,
		},
		[4] = {
			type = "checkbox",
			name = "Show Window",
			tooltip = "Display the window?",
			reference = "BTMenuControlShowWindow",
			getFunc = function()
				return activeCharSettings.shown
			end,
			setFunc = function(value)
				activeCharSettings.shown = value
			end,
		},
		[5] = {
			type = "checkbox",
			name = "Show Alliance",
			tooltip = "Display character's alliance?",
			reference = "BTMenuControlShowAlliance",
			getFunc = function()
				return btw.showAlliance
			end,
			setFunc = function(value)
				BT.settings.showAlliance = value
				btw.showAlliance = value
			end,
		},
		[6] = {
			type = "checkbox",
			name = "Show Werewolves",
			tooltip = "Display werewolf characters",
			reference = "BTMenuControlShowWerewolves",
			getFunc = function()
				return btw.showWerewolves
			end,
			setFunc = function(value)
				BT.settings.showWerewolves = value
				btw.showWerewolves = value
				BT.ShowOrHideCharacters()
			end,
		},
		[7] = {
			type = "checkbox",
			name = "Show Vampires",
			tooltip = "Display vampire characters",
			reference = "BTMenuControlShowVampires",
			getFunc = function()
				return btw.showVampires
			end,
			setFunc = function(value)
				BT.settings.showVampires = value
				btw.showVampires = value
				BT.ShowOrHideCharacters()
			end,
		},
		[8] = {
			type = "checkbox",
			name = "Show Pure",
			tooltip = "Display characters which aren't werewolf or vampire",
			reference = "BTMenuControlShowPure",
			getFunc = function()
				return btw.showPure
			end,
			setFunc = function(value)
				BT.settings.showPure = value
				btw.showPure = value
				BT.ShowOrHideCharacters()
			end,
		},
		[9] = {
			type = "slider",
			name = "Text Font Size",
			--tooltip = "",
			min = 4,
			max = 72,
			step = 1,
			getFunc = function() return btw.fontSize end,
			setFunc = function(value)
				BT.settings.fontSize = value
				BT.SetFontSize(value)
			end,
			default = 18,
		},
	}

	btSettingsPanel = LibAddonMenu2:RegisterAddonPanel("Bite_Timers", panel)
	LibAddonMenu2:RegisterOptionControls("Bite_Timers", options)
	
	CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", btSettingsPanel)
	
	wasMenuCreated = true
end