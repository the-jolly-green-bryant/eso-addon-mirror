GCDBar = GCDBar or { }
local gb = GCDBar

local lockUI = true

function gb.buildMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = "GCD Bar",
		displayName = "|cff0c4dG|rCD Bar",
		author = "Wheels",
		version = ""..gb.version,
		registerForRefresh = true,
	}

	LAM:RegisterAddonPanel(gb.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Display Options",
		},
		{
			type = "checkbox",
			name = "Lock UI",
			tooltip = "Enable repositioning and resizing of the cooldown bar",
			getFunc = function() return lockUI end,
			setFunc = function(value)
				gb.UI.setHudToggle(value and not gb.savedVars.hideFrame or false)
				gb.UI.gbFrame:SetMouseEnabled(not value)
				gb.UI.gbFrame:SetMovable(not value)
				gb.UI.gbFrame:SetHidden(value)
				lockUI = value
			end,
		},
		{
			type = "checkbox",
			name = "Hide Bar",
			tooltip = "Hides the GCD 'bar' itself, in case you just want the skill icon cooldowns",
			getFunc = function() return gb.savedVars.hideFrame end,
			setFunc = function(value)
					gb.savedVars.hideFrame = value
				if value then
					gb.UI.setHudToggle(false)
					gb.UI.gbFrame:SetHidden(true)
				else
					gb.UI.setHudToggle(true)
					gb.UI.gbFrame:SetHidden(false)
				end
			end,
		},
		{
			type = "checkbox",
			name = "Toggle Action Bar Cooldowns",
			tooltip = "Toggles radial cooldowns on the action bar",
			getFunc = function() return gb.savedVars.abCooldown end,
			setFunc = function(value)
				ZO_ActionButtons_ToggleShowGlobalCooldown()
				gb.savedVars.abCooldown = value
			end,
		},
		{
			type = "checkbox",
			name = "Reverse Bar Direction",
			tooltip = "Reverses the direction that the bar counts down in",
			getFunc = function() return gb.savedVars.reverse end,
			setFunc = function(value)
				gb.savedVars.reverse = value
				gb.UI.setProperties()
			end,
		},
		{
			type = "colorpicker",
			name = "Bar Color",
			tooltip = "Color of the GCD Bar (what did you think it was?)",
			getFunc = function() return unpack(gb.savedVars.color) end,
			setFunc = function(r,g,b,a)
				gb.savedVars.color = {r,g,b,a}
				gb.UI.setProperties()
			end,
		},
		--{
		--	type = "checkbox",
		--	name = "Fast GCD",
		--	tooltip = "Simulates a 900ms GCD to help with queuing skills at the correct time (slighly visually buggy but it works)",
		--	getFunc = function() return gb.savedVars.fastGCD end,
		--	setFunc = function(value) gb.savedVars.fastGCD = value end,
		--},
		--{
		--	type = "slider",
		--	name = "Advanced Fast GCD",
		--	tooltip = "The number selected here will determine how early the GCD timer ends. If 150 is selected, the timer will end 150 ms early, simulating a 850 ms GCD.",
		--	min = 0,
		--	max = 200,
		--	step = 1,
		--	getFunc = function() return gb.savedVars.advTime end,
		--	setFunc = function(value) gb.savedVars.advTime = value end,
		--},
	}

	LAM:RegisterOptionControls(gb.name.."Options", options)
end
