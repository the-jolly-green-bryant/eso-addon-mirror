PillarOfNirn = PillarOfNirn or { }
local PillarOfNirn = PillarOfNirn

function PillarOfNirn.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = GetString(PON_PANEL_NAME),
		displayName = GetString(PON_PANEL_DISPLAYNAME),
		author = "|c215895Lykeion|r",
		version = "|ccc922f"..PillarOfNirn.version.."|r",
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(PillarOfNirn.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
			type = "checkbox",
			name = GetString(PON_LOCK_UI),
			getFunc = function() return true end,
			setFunc = function(value)
				if not value then
					EVENT_MANAGER:UnregisterForEvent(PillarOfNirn.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
					PillarOfNirnFrame:SetHidden(false)
					PillarOfNirnFrame:SetMovable(true)
					PillarOfNirnFrame:SetMouseEnabled(true)
				else
					EVENT_MANAGER:RegisterForEvent(PillarOfNirn.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, PillarOfNirn.hideFrame)
					PillarOfNirnFrame:SetHidden(IsReticleHidden())
					PillarOfNirnFrame:SetMovable(false)
					PillarOfNirnFrame:SetMouseEnabled(false)
				end
			end
		},
		{
			type = "header",
			name = "Options"
		},
		{
			type = "slider",
			name = GetString(PON_TEXT_SIZE),
			min = 20,
			max = 100,
			getFunc = function() return PillarOfNirn.savedVars.timerSize end,
			setFunc = function(value)
				PillarOfNirn.savedVars.timerSize = value
				PillarOfNirn.setFontSize(value)
			end
		},
		{
			type = "checkbox",
			name = GetString(PON_ONLY_DISPLAY_IN_COMBAT),
			getFunc = function() return PillarOfNirn.savedVars.passiveHide end,
			setFunc = function(value)
				PillarOfNirn.savedVars.passiveHide = value
				PillarOfNirn.hideOutOfCombat()
			end
		},
		{
			type = "colorpicker",
			name = GetString(PON_AVAILABLE_COLOR),
			warning = GetString(PON_COLOR_WARNING),
			getFunc = function() return unpack(PillarOfNirn.savedVars.COLORS.UP) end,
			setFunc = function(r,g,b,a) PillarOfNirn.savedVars.COLORS.UP = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = GetString(PON_WARNING_COLOR),
			warning = GetString(PON_COLOR_WARNING),
			getFunc = function() return unpack(PillarOfNirn.savedVars.COLORS.WARNING) end,
			setFunc = function(r,g,b,a) PillarOfNirn.savedVars.COLORS.WARNING = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = GetString(PON_COOLDOWN_COLOR),
			warning = GetString(PON_COLOR_WARNING),
			getFunc = function() return unpack(PillarOfNirn.savedVars.COLORS.DOWN) end,
			setFunc = function(r,g,b,a) PillarOfNirn.savedVars.COLORS.DOWN = {r,g,b,a} end,
		},
	}

	LAM:RegisterOptionControls(PillarOfNirn.name.."Options", options)
end
