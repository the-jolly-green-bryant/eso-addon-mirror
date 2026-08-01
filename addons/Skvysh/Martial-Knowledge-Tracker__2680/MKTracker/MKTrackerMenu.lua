MKTracker = MKTracker or { }
local MKT = MKTracker
function MKT.SetupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = MKT.name,
		displayName = "|cFFFF00M|rartial |c008000K|rnowledge |cFF0000T|rracker",
		version = ""..MKT.version,
	}

	LAM:RegisterAddonPanel(MKT.name.."Options", panelData)

	local options = {
    {
			type = "header",
			name = "General Settings"
		},
    {
			type = "checkbox",
			name = "Lock UI",
			tooltip = "Unlock to position timer in desired location.",
			getFunc = function() return true end,
			setFunc = function(value)
				if not value then
					EVENT_MANAGER:UnregisterForEvent(MKT.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
					MKTrackerPanel:SetHidden(false)
					MKTrackerPanel:SetMovable(true)
					MKTrackerPanel:SetMouseEnabled(true)
				else
					EVENT_MANAGER:RegisterForEvent(MKT.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, MKT.HideFrame)
					MKTrackerPanel:SetHidden(IsReticleHidden())
					MKTrackerPanel:SetMovable(false)
					MKTrackerPanel:SetMouseEnabled(false)
				end
			end
		},
    {
			type = "checkbox",
			name = "Gear check",
			tooltip = "Display status panel only if at least 3 pieces of Martial Knowledge are equipped.",
			getFunc = function() return MKT.savedVars.gearCheck end,
			setFunc = function(value)
				MKT.savedVars.gearCheck = value
				MKT.HideFrame()
			end
		},
    {
			type = "checkbox",
			name = "Only Display In Combat",
			tooltip = "Only displays timer when the player is in combat.",
			getFunc = function() return MKT.savedVars.passiveHide end,
			setFunc = function(value)
				MKT.savedVars.passiveHide = value
				MKT.HideOutOfCombat()
			end
		},
    {
      type = "slider",
      name = "Update Interval",
      tooltip = "Rate at which information about cooldown and stamina should be updated.",
      getFunc = function() return MKT.savedVars.updateInterval end,
      setFunc = function(value) MKT.savedVars.updateInterval = value end,
      min = 100,
      max = 1000,
      step = 2,
      default = 200,
      width = "full",
    },
		{
			type = "header",
			name = "MK Proc Options"
		},
    {
			type = "checkbox",
			name = "Change Colour When MK Is Available",
			tooltip = "Change the colour of the proc cooldown only when MK can be procced again (8 seconds). If set to false, it will instead change colour when the debuff ends (after 5 seconds), as the other MK addon did.",
			getFunc = function() return MKT.savedVars.procCooldownType end,
			setFunc = function(value)
				MKT.savedVars.procCooldownType = value
			end
		},
		{
			type = "colorpicker",
			name = "Available Color",
			tooltip = "Color of timer when Martial Knowledge proc is available.",
			getFunc = function() return unpack(MKT.savedVars.colours.up) end,
			setFunc = function(r,g,b,a)
				MKT.savedVars.colours.up = {r,g,b,a}
				MKT.SetColours()
			end,
		},
		{
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "Color of timer when Martial Knowledge proc is unavailable/active.",
			getFunc = function() return unpack(MKT.savedVars.colours.down) end,
			setFunc = function(r,g,b,a)
        MKT.savedVars.colours.down = {r,g,b,a}
        MKT.SetColours()
      end,
		},
    {
      type = "slider",
      name = "MK Cooldown Font Size",
      tooltip = "Font size of the MK cooldown timer.",
      getFunc = function() return MKT.savedVars.procFontSize end,
      setFunc = function(value) MKT.savedVars.procFontSize = value MKT.SetFontSize() end,
      min = 10,
      max = 72,
      step = 2,
      default = 50,
      width = "full",
    },
    {
			type = "header",
			name = "Global MK Debuff Options"
		},
    {
			type = "checkbox",
			name = "Track Group's MK Procs",
			tooltip = "Track the MK procs by anyone in the group and not just you. This will add another timer to the status panel which tracks the Martial Knowledge debuff and not just your own proc cooldown.",
			getFunc = function() return MKT.savedVars.procGroupTracker end,
			setFunc = function(value)
				MKT.savedVars.procGroupTracker = value
        MKT.RegisterProcEventType()
			end
		},
    {
			type = "colorpicker",
			name = "Available Color",
			tooltip = "Color of debuff timer when there is no MK debuff on any target.",
			getFunc = function() return unpack(MKT.savedVars.colours.upGlobal) end,
			setFunc = function(r,g,b,a)
				MKT.savedVars.colours.upGlobal = {r,g,b,a}
				MKT.SetColours()
			end,
		},
		{
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "Color of debuff timer when MK debuff is active on any target.",
			getFunc = function() return unpack(MKT.savedVars.colours.downGlobal) end,
			setFunc = function(r,g,b,a)
        MKT.savedVars.colours.downGlobal = {r,g,b,a}
        MKT.SetColours()
      end,
		},
    {
      type = "slider",
      name = "Global MK Debuff Timer Font Size",
      tooltip = "Font size of the timer when MK is active on any target.",
      getFunc = function() return MKT.savedVars.globalProcFontSize end,
      setFunc = function(value) MKT.savedVars.globalProcFontSize = value MKT.SetFontSize() end,
      min = 10,
      max = 72,
      step = 2,
      default = 35,
      width = "full",
    },
    {
			type = "header",
			name = "Stamina Counter Options"
		},
    {
			type = "checkbox",
			name = "Display Stamina Counter",
			tooltip = "Displays stamina below the MK proc cooldown.",
			getFunc = function() return MKT.savedVars.showStamina end,
			setFunc = function(value)
				MKT.savedVars.showStamina = value
				MKT.HideStaminaPanel(not value)
			end
		},
    {
			type = "colorpicker",
			name = "Above Threshold Color",
			tooltip = "Color of stamina tracker when above 50%.",
			getFunc = function() return unpack(MKT.savedVars.colours.aboveThreshold) end,
			setFunc = function(r,g,b,a)
				MKT.savedVars.colours.aboveThreshold = {r,g,b,a}
				MKT.SetColours()
			end,
		},
		{
			type = "colorpicker",
			name = "Below Threshold Color",
			tooltip = "Color of stamina tracker when below 50%.",
			getFunc = function() return unpack(MKT.savedVars.colours.belowThreshold) end,
			setFunc = function(r,g,b,a)
				MKT.savedVars.colours.belowThreshold = {r,g,b,a}
				MKT.SetColours()
			end,
		},
    {
      type = "slider",
      name = "Stamina Counter Font Size",
      tooltip = "Font size of the stamina counter.",
      getFunc = function() return MKT.savedVars.stamFontSize end,
      setFunc = function(value) MKT.savedVars.stamFontSize = value MKT.SetFontSize() end,
      min = 10,
      max = 72,
      step = 2,
      default = 50,
      width = "full",
    },
    {
			type = "header",
			name = "Offbar Check Options",
		},
    {
			type = "checkbox",
			name = "Off-bar check",
			tooltip = "Allow custom counter colours when on an off-bar.",
			getFunc = function() return MKT.savedVars.offbarCheck end,
			setFunc = function(value)
				MKT.savedVars.offbarCheck = value
				MKT.HideFrame()
			end
		},
		{
			type = "colorpicker",
			name = "Available Color",
			tooltip = "Color of timer when Martial Knowledge proc is available (offbar).",
			getFunc = function() return unpack(MKT.savedVars.colours.upOffbar) end,
			setFunc = function(r,g,b,a)
				MKT.savedVars.colours.upOffbar = {r,g,b,a}
				MKT.SetColours()
			end,
		},
		{
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "Color of timer when Martial Knowledge proc is unavailable/active (offbar).",
			getFunc = function() return unpack(MKT.savedVars.colours.downOffbar) end,
			setFunc = function(r,g,b,a)
        MKT.savedVars.colours.downOffbar = {r,g,b,a}
        MKT.SetColours()
      end,
		},
	}

	LAM:RegisterOptionControls(MKT.name.."Options", options)
end

