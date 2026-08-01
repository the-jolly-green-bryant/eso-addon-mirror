OverloadTimer = OverloadTimer or { }
local OverloadTimer = OverloadTimer

function OverloadTimer.setupMenu()
	local LAM = LibStub("LibAddonMenu-2.0")

	local panelData = {
		type = "panel",
		name = OverloadTimer.name,
		displayName = "|cc57affOverload Timer|r",
		author = "Wheels",
		version = ""..OverloadTimer.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(OverloadTimer.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
			type = "checkbox",
			name = "Lock UI",
			tooltip = "Unlock to position timer in desired location",
			getFunc = function() return OverloadTimer.locked end,
			setFunc = function(value)
				if not value then
					EVENT_MANAGER:UnregisterForEvent(OverloadTimer.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
					OverloadTimer.locked = value
					OverloadTimerFrame:SetHidden(false)
					OverloadTimerFrame:SetMovable(true)
					OverloadTimerFrame:SetMouseEnabled(true)
				else
					EVENT_MANAGER:RegisterForEvent(OverloadTimer.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, OverloadTimer.hideFrame)
					OverloadTimer.locked = value
					OverloadTimerFrame:SetHidden(IsReticleHidden())
					OverloadTimerFrame:SetMovable(false)
					OverloadTimerFrame:SetMouseEnabled(false)
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
			getFunc = function() return OverloadTimer.savedVars.timerSize end,
			setFunc = function(value)
				OverloadTimer.savedVars.timerSize = value
				OverloadTimer.setFontSize(value)
			end
		},
		{
			type = "colorpicker",
			name = "Timer Color",
			tooltip = "Color of the timer (wowie)",
			getFunc = function() return unpack(OverloadTimer.savedVars.COLOR) end,
			setFunc = function(r,g,b,a)
				OverloadTimer.savedVars.COLOR = {r,g,b,a}
				OverloadTimerFrameTime:SetColor(unpack(OverloadTimer.savedVars.COLOR))
			end,
		},
	}

	LAM:RegisterOptionControls(OverloadTimer.name.."Options", options)
end
