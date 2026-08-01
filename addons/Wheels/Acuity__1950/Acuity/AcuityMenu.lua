Acuity = Acuity or { }
local Acuity = Acuity

function Acuity.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = Acuity.name,
		displayName = "|c42BCF4A|rcuity",
		author = "Wheels",
		version = ""..Acuity.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(Acuity.name.."Options", panelData)

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
					EVENT_MANAGER:UnregisterForEvent(Acuity.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
					AcuityFrame:SetHidden(false)
					AcuityFrame:SetMovable(true)
					AcuityFrame:SetMouseEnabled(true)
				else
					AcuityFrame:SetHidden(IsReticleHidden())
					AcuityFrame:SetMovable(false)
					AcuityFrame:SetMouseEnabled(false)
					Acuity.gearUpdate()
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
			getFunc = function() return Acuity.savedVars.timerSize end,
			setFunc = function(value)
				Acuity.savedVars.timerSize = value
				Acuity.setFontSize(value)
			end
		},
		{
			type = "checkbox",
			name = "Only Display In Combat",
			tooltip = "Only displays timer when the player is in combat",
			getFunc = function() return Acuity.savedVars.passiveHide end,
			setFunc = function(value)
				Acuity.savedVars.passiveHide = value
				Acuity.hideOutOfCombat()
			end
		},
		{
			type = "colorpicker",
			name = "Available Color",
			tooltip = "Color of timer when Acuity proc is available",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(Acuity.savedVars.COLORS.UP) end,
			setFunc = function(r,g,b,a) Acuity.savedVars.COLORS.UP = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Active Color",
			tooltip = "Color of timer when Acuity proc is currently active",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(Acuity.savedVars.COLORS.PROC) end,
			setFunc = function(r,g,b,a) Acuity.savedVars.COLORS.PROC = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "Color of timer when Acuity proc is currently on cooldown",
			warning = "Color changes go into effect next time timer changes color",
			getFunc = function() return unpack(Acuity.savedVars.COLORS.DOWN) end,
			setFunc = function(r,g,b,a) Acuity.savedVars.COLORS.DOWN = {r,g,b,a} end,
		},
	}

	LAM:RegisterOptionControls(Acuity.name.."Options", options)
end
