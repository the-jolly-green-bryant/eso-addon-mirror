PowerfulAssault = PowerfulAssault or { }
local PowerfulAssault = PowerfulAssault

function PowerfulAssault.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = "Powerful Assault",
		displayName = "|c77db1aPowerful Assault|r",
		author = "Wheels",
		version = ""..PowerfulAssault.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(PowerfulAssault.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
			type = "checkbox",
			name = "Lock UI",
			tooltip = "Unlock to position timer in desired location",
			getFunc = function() return PowerfulAssault.locked end,
			setFunc = function(value)
				if not value then
					EVENT_MANAGER:UnregisterForEvent(PowerfulAssault.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
					PowerfulAssault.locked = value
					PowerfulAssaultFrame:SetHidden(false)
					PowerfulAssaultFrame:SetMovable(true)
					PowerfulAssaultFrame:SetMouseEnabled(true)
				else
					EVENT_MANAGER:RegisterForEvent(PowerfulAssault.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, PowerfulAssault.hideFrame)
					PowerfulAssault.locked = value
					PowerfulAssaultFrame:SetHidden(IsReticleHidden())
					PowerfulAssaultFrame:SetMovable(false)
					PowerfulAssaultFrame:SetMouseEnabled(false)
				end
			end
		},
		{
			type = "header",
			name = "Options"
		},
		{
			type = "slider",
			name = "Text Size",
			tooltip = "Size of the displayed timer",
			min = 20,
			max = 100,
			getFunc = function() return PowerfulAssault.savedVars.timerSize end,
			setFunc = function(value)
				PowerfulAssault.savedVars.timerSize = value
				PowerfulAssault.setFontSize(value)
			end
		},
		{
			type = "colorpicker",
			name = "Timer Color",
			tooltip = "Color of the timer (wowie)",
			getFunc = function() return unpack(PowerfulAssault.savedVars.COLOR) end,
			setFunc = function(r,g,b,a)
				PowerfulAssault.savedVars.COLOR = {r,g,b,a}
				PowerfulAssaultFrameTime:SetColor(unpack(PowerfulAssault.savedVars.COLOR))
			end,
		},
	}

	LAM:RegisterOptionControls(PowerfulAssault.name.."Options", options)
end
