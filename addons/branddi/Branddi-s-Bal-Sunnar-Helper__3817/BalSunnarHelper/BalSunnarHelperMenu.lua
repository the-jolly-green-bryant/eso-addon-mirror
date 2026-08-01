BalSunnarHelper = BalSunnarHelper or { }
local BalSunnarHelper = BalSunnarHelper

function BalSunnarHelper.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = BalSunnarHelper.name,
		displayName = "|cff2424B|r|cff4949r|r|cff6d6da|r|cff9292n|r|cffb6b6d|r|cffdbdbd|r|cffffffi|r's Bal Sunnar Helper",
		author = "Branddi",
		version = ""..BalSunnarHelper.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(BalSunnarHelper.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
			type = "checkbox",
			name = "Lock UI",
			tooltip = "Unlock to position timer in desired location",
			getFunc = function() return true end,
			setFunc = function(value)
				if not value then
					EVENT_MANAGER:UnregisterForEvent(BalSunnarHelper.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
					BalSunnarHelperFrame:SetHidden(false)
					BalSunnarHelperFrame:SetMovable(true)
					BalSunnarHelperFrame:SetMouseEnabled(true)
				else
					EVENT_MANAGER:RegisterForEvent(BalSunnarHelper.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, BalSunnarHelper.hideFrame)
					BalSunnarHelperFrame:SetHidden(false)
					BalSunnarHelperFrame:SetMovable(false)
					BalSunnarHelperFrame:SetMouseEnabled(false)
				end
			end
		},

--[[
		{
			type = "checkbox",
			name = "Show spider spawn ",
			tooltip = "warning Scriviner's Hall Spider spawn",
			getFunc = function() return BalSunnarHelper.savedVars.spiderSpawn end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.spiderSpawn = false
				else
					BalSunnarHelper.savedVars.spiderSpawn = true
				end
			end
		},--]]

		{
			type = "header",
			name = "Kovan Jumps"
		},

		{
			type = "checkbox",
			name = "Show Kovan Jump",
			tooltip = "warning when kovan is going to jump",
			getFunc = function() return BalSunnarHelper.savedVars.kovanJump end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.kovanJump = false
				else
					BalSunnarHelper.savedVars.kovanJump = true
				end
			end
		},

		{
			type = "header",
			name = "Spread Icons"
		},

        {
			type = "checkbox",
			name = "Show Entrance Spread Location",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showEntranceSpread end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showEntranceSpread = false
				else
					BalSunnarHelper.savedVars.showEntranceSpread = true
				end
			end
		},

		{
			type = "checkbox",
			name = "Show Exit Spread Location",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showExitSpread end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showExitSpread = false
				else
					BalSunnarHelper.savedVars.showExitSpread = true
				end
			end
		},
		{
			type = "checkbox",
			name = "Show Left Spread Location",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showLeftSpread end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showLeftSpread = false
				else
					BalSunnarHelper.savedVars.showLeftSpread = true
				end
			end
		},


		{
			type = "checkbox",
			name = "Show Right Spread Location",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showRightSpread end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showRightSpread = false
				else
					BalSunnarHelper.savedVars.showRightSpread = true
				end
			end
		},


--[[]

		{
			type = "header",
			name = "Stack Icons"
		},





		{
			type = "checkbox",
			name = "Show Ground Heal Centre",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showGroundHealCentre end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showGroundHealCentre = false
				else
					BalSunnarHelper.savedVars.showGroundHealCentre = true
				end
			end
		},




		{
			type = "checkbox",
			name = "Show Healer Stack Location",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showHealerStack end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showHealerStack = false
				else
					BalSunnarHelper.savedVars.showHealerStack = true
				end
			end
		},
		{
			type = "checkbox",
			name = "Show Dps 1 Stack Location",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showDps1Stack end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showDps1Stack = false
				else
					BalSunnarHelper.savedVars.showDps1Stack = true
				end
			end
		},

		{
			type = "checkbox",
			name = "Show Dps 2 Stack Location",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showDps2Stack end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showDps2Stack = false
				else
					BalSunnarHelper.savedVars.showDps2Stack = true
				end
			end
		},

		{
			type = "checkbox",
			name = "Show Tank Stack Location",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showTankStack end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showTankStack = false
				else
					BalSunnarHelper.savedVars.showTankStack = true
				end
			end
		},



		{
			type = "header",
			name = "Stack Directions"
		},

		{
			type = "checkbox",
			name = "Show Entrance Left Stack Location",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showEntranceLeft end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showEntranceLeft = false
				else
					BalSunnarHelper.savedVars.showEntranceLeft = true
				end
			end
		},

		{
			type = "checkbox",
			name = "Show Entrance Right Stack Location",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showEntranceRight end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showEntranceRight = false
				else
					BalSunnarHelper.savedVars.showEntranceRight = true
				end
			end
		},
		{
			type = "checkbox",
			name = "Show Exit Left Stack Location",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showExitLeft end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showExitLeft = false
				else
					BalSunnarHelper.savedVars.showExitLeft = true
				end
			end
		},
		{
			type = "checkbox",
			name = "Show Exit Right Stack Location",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showExitRight end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showExitRight = false
				else
					BalSunnarHelper.savedVars.showExitRight = true
				end
			end
		},
		--]]

--[[
		{
			type = "header",
			name = "Development Only"
		},
--]]
--[[

		{
			type = "checkbox",
			name = "Show Beam Icons",
			tooltip = "",
			getFunc = function() return BalSunnarHelper.savedVars.showBeamIcons end,
			setFunc = function(value)
				if not value then
					BalSunnarHelper.savedVars.showBeamIcons = false
				else
					BalSunnarHelper.savedVars.showBeamIcons = true
				end
			end
		},
--]]
	}




	LAM:RegisterOptionControls(BalSunnarHelper.name.."Options", options)
end
