Courage = Courage or { }
local Courage = Courage

function Courage.setupMenu()
	local LAM = LibStub("LibAddonMenu-2.0")

	local panelData = {
		type = "panel",
		name = Courage.name,
		displayName = "|cff9beaC|rourage",
		author = "Jonno, Eymix, Wheels",
		version = ""..Courage.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(Courage.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
			type = "checkbox",
			name = "Lock UI",
			tooltip = "Unlock to position timer in desired location",
			getFunc = function() return Courage.locked end,
			setFunc = function(value)
				if not value then
					Courage.locked = value
					Courage.UI.Frame:SetHidden(false)
					Courage.UI.Frame:SetMovable(true)
					Courage.UI.Frame:SetMouseEnabled(true)
				else
					Courage.locked = value
					Courage.UI.Frame:SetHidden(IsReticleHidden())
					Courage.UI.Frame:SetMovable(false)
					Courage.UI.Frame:SetMouseEnabled(false)
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
			getFunc = function() return Courage.savedVars.timerSize end,
			setFunc = function(value)
				Courage.savedVars.timerSize = value
				Courage.UI.Frame:SetScale(value)
			end
		},
		{
			type = "colorpicker",
			name = "Timer Color",
			tooltip = "Color of the timer text",
			getFunc = function() return unpack(Courage.savedVars.COLOR) end,
			setFunc = function(r,g,b,a)
				Courage.savedVars.COLOR = {r,g,b,a}
				Courage.UI.Time:SetColor(unpack(Courage.savedVars.COLOR))
			end,
		},
		{
			type = "colorpicker",
			name = "Border Color 1",
			tooltip = "First border color",
			getFunc = function() return unpack(Courage.savedVars.Alert_Colors[1]) end,
			setFunc = function(r,g,b,a)
				Courage.savedVars.Alert_Colors[1] = {r,g,b,a}
				Courage.UI.BG:SetEdgeColor(unpack(Courage.savedVars.Alert_Colors[1]))
			end,
		},
		{
			type = "colorpicker",
			name = "Border Color 2",
			tooltip = "Second border color",
			getFunc = function() return unpack(Courage.savedVars.Alert_Colors[2]) end,
			setFunc = function(r,g,b,a)
				Courage.savedVars.Alert_Colors[2] = {r,g,b,a}
			end,
		},
		{
			type = "colorpicker",
			name = "Border Color 3",
			tooltip = "Second border color",
			getFunc = function() return unpack(Courage.savedVars.Alert_Colors[3]) end,
			setFunc = function(r,g,b,a)
				Courage.savedVars.Alert_Colors[3] = {r,g,b,a}
			end,
		},
	}

	LAM:RegisterOptionControls(Courage.name.."Options", options)
end
