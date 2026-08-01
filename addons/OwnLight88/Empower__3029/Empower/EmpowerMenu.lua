Empower = Empower or { }
local Empower = Empower

function Empower.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = "Empower",
		displayName = "|c8b4dffEmpower|r",
		author = "Own|c50cddcLight|r",
		version = ""..Empower.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(Empower.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
			type = "checkbox",
			name = "Lock UI",
			tooltip = "Unlock the position of the timer",
			getFunc = function() return Empower.locked end,
			setFunc = function(value)
				if not value then
					EVENT_MANAGER:UnregisterForEvent(Empower.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
					Empower.locked = value
					EmpowerFrame:SetHidden(false)
					EmpowerFrame:SetMovable(true)
					EmpowerFrame:SetMouseEnabled(true)
				else
					EVENT_MANAGER:RegisterForEvent(Empower.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, Empower.hideFrame)
					Empower.locked = value
					EmpowerFrame:SetHidden(IsReticleHidden())
					EmpowerFrame:SetMovable(false)
					EmpowerFrame:SetMouseEnabled(false)
				end
			end
		},
		{
			type = "header",
			name = "Options"
		},
		{
			type = "checkbox",
			name = "Only Show in Combat",
			tooltip = "Show the time when in Combat",
			getFunc = function() return Empower.savedVars.passiveHide end,
			setFunc = function(value)
				Empower.savedVars.passiveHide = value
				Empower.hideOutOfCombat()
			end
		},
		{
			type = "slider",
			name = "Text Size",
			tooltip = "Size of the timer",
			min = 20,
			max = 100,
			getFunc = function() return Empower.savedVars.timerSize end,
			setFunc = function(value)
				Empower.savedVars.timerSize = value
				Empower.setFontSize(value)
			end
		},
		{
			type = "colorpicker",
			name = "Timer Color",
			tooltip = "Color of Empower Tracker",
			getFunc = function() return unpack(Empower.savedVars.COLOR) end,
			setFunc = function(r,g,b,a)
				Empower.savedVars.COLOR = {r,g,b,a}
				EmpowerFrameTime:SetColor(unpack(Empower.savedVars.COLOR))
			end,
		},
	}

	LAM:RegisterOptionControls(Empower.name.."Options", options)
end
