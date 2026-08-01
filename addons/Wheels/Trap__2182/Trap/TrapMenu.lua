Trap = Trap or { }
local Trap = Trap

function Trap.setupMenu()
	local LAM = LibStub("LibAddonMenu-2.0")

	local panelData = {
		type = "panel",
		name = Trap.name,
		displayName = "|c42edbfT|rrap",
		author = "Wheels",
		version = ""..Trap.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(Trap.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
			type = "checkbox",
			name = "Lock UI",
			tooltip = "Unlock to position timer in desired location",
			getFunc = function() return Trap.locked end,
			setFunc = function(value)
				if not value then
					Trap.locked = value
					Trap.UI.Frame:SetHidden(false)
					Trap.UI.Frame:SetMovable(true)
					Trap.UI.Frame:SetMouseEnabled(true)
				else
					Trap.locked = value
					Trap.UI.Frame:SetHidden(IsReticleHidden())
					Trap.UI.Frame:SetMovable(false)
					Trap.UI.Frame:SetMouseEnabled(false)
				end
			end
		},
		{
			type = "header",
			name = "Options"
		},
		{
			type = "slider",
			name = "Timer Scale",
			tooltip = "Size of the displayed timer",
			min = 0.5,
			max = 2,
			step = 0.1,
			getFunc = function() return Trap.savedVars.timerSize end,
			setFunc = function(value)
				Trap.savedVars.timerSize = value
				Trap.UI.Frame:SetScale(value)
			end
		},
		{
			type = "colorpicker",
			name = "Timer Color",
			tooltip = "Color of the timer text",
			getFunc = function() return unpack(Trap.savedVars.COLOR) end,
			setFunc = function(r,g,b,a)
				Trap.savedVars.COLOR = {r,g,b,a}
				Trap.UI.Time:SetColor(unpack(Trap.savedVars.COLOR))
			end,
		},
		{
			type = "colorpicker",
			name = "Border Color 1",
			tooltip = "First border color",
			getFunc = function() return unpack(Trap.savedVars.Alert_Colors[1]) end,
			setFunc = function(r,g,b,a)
				Trap.savedVars.Alert_Colors[1] = {r,g,b,a}
				Trap.UI.BG:SetEdgeColor(unpack(Trap.savedVars.Alert_Colors[1]))
			end,
		},
		{
			type = "colorpicker",
			name = "Border Color 2",
			tooltip = "Second border color",
			getFunc = function() return unpack(Trap.savedVars.Alert_Colors[2]) end,
			setFunc = function(r,g,b,a)
				Trap.savedVars.Alert_Colors[2] = {r,g,b,a}
			end,
		},
		{
			type = "colorpicker",
			name = "Border Color 3",
			tooltip = "Second border color",
			getFunc = function() return unpack(Trap.savedVars.Alert_Colors[3]) end,
			setFunc = function(r,g,b,a)
				Trap.savedVars.Alert_Colors[3] = {r,g,b,a}
			end,
		},
	}

	LAM:RegisterOptionControls(Trap.name.."Options", options)
end
