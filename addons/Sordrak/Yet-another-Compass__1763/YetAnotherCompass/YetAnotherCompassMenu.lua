-- YetAnotherCompass - Menu
-- By @s0rdrak, @schorse4044 (PC / EU)

--local LAM = LibStub("LibAddonMenu-2.0")
local LAM = LibAddonMenu2

local YACS = _G['YACS']
local YACSMenu = YACS.menu


YACSMenu.lam = {}
YACSMenu.lam.panel = nil
YACSMenu.lam.panelData = {}
YACSMenu.lam.panelData.type = "panel"
YACSMenu.lam.panelData.name = "|c4592FFYet Another Compass|r"
YACSMenu.lam.panelData.displayName = "|c4592FFYet Another Compass Configuration|r"
YACSMenu.lam.panelData.author = string.format("|cFF8174%s|r\r\nThanks to: |cFF8174%s|r\r\n", YACS.author, YACS.credits)
YACSMenu.lam.panelData.version = string.format("|cFF8174%s|r", YACS.versionString)
YACSMenu.lam.panelData.registerForRefresh = true
YACSMenu.lam.panelData.registerForDefaults = false
YACSMenu.constants = {}
YACSMenu.constants.references = {}
YACSMenu.constants.references.CHECKBOX_ENABLE_ADDON = "YACS_ENABLE_ADDON_CHECKBOX_CONTROL"
YACSMenu.constants.references.CHECKBOX_PVP = "YACS_CHECKBOX_PVP"
YACSMenu.constants.references.CHECKBOX_PVE = "YACS_CHECKBOX_PVE"
YACSMenu.constants.references.CHECKBOX_COMBAT = "YACS_CHECKBOX_COMBAT"
YACSMenu.constants.references.CHECKBOX_MOVABLE = "YACS_CHECKBOX_MOVABLE"
YACSMenu.constants.references.DROPDOWN_COMPASS_STYLES = "YACS_DROPDOWN_COMPASS_STYLE"


local wm = GetWindowManager()

function YACSMenu.OpenMenu()
	LAM:OpenToPanel(YACSMenu.lam.panel)
end

function YACSMenu.UpdateCheckbox(checkbox)
	if checkbox ~= nil and checkbox.data ~= nil then
		checkbox:UpdateValue()
	end
end

function YACSMenu.UpdateAddonState()
	YACSMenu.UpdateCheckbox(wm:GetControlByName(YACSMenu.constants.references.CHECKBOX_ENABLE_ADDON))
	YACSMenu.UpdateCheckbox(wm:GetControlByName(YACSMenu.constants.references.CHECKBOX_PVP))
	YACSMenu.UpdateCheckbox(wm:GetControlByName(YACSMenu.constants.references.CHECKBOX_PVE))
	YACSMenu.UpdateCheckbox(wm:GetControlByName(YACSMenu.constants.references.CHECKBOX_COMBAT))
end

function YACSMenu.GetCompassColor()
	local color = YACS.GetCompassColor()
	return color.R, color.G, color.B, color.A
end

function YACSMenu.SetCompassColor(R, G, B, A)
	local color = {}
	color.R = R
	color.G = G
	color.B = B
	color.A = A
	YACS.SetCompassColor(color)
end

function YACSMenu.GetCompassSize()
	return YACS.GetCompassSize()
end

function YACSMenu.SetCompassSize(value)
	YACS.SetCompassSize(value)
end

function YACSMenu.GetAddonState()
	return YACS.GetEnabled()
end

function YACSMenu.SetAddonState(value)
	YACS.SetEnabled(value)
end

function YACSMenu.GetCompassStyles()
	return YACS.GetCompassStyles()
end

function YACSMenu.GetCurrentCompassStyle()
	return YACS.GetCurrentCompassStyle()
end

function YACSMenu.SetCurrentCompassStyle(value)
	YACS.SetCurrentCompassStyle(value)
end

function YACSMenu.GetPvpState()
	return YACS.GetPvpState()
end

function YACSMenu.SetPvpState(value)
	YACS.SetPvpState(value)
end

function YACSMenu.GetPveState()
	return YACS.GetPveState()
end

function YACSMenu.SetPveState(value)
	YACS.SetPveState(value)
end

function YACSMenu.GetCombatState()
	return YACS.GetCombatState()
end

function YACSMenu.GetMovableState()
	return YACS.GetMovableState()
end

function YACSMenu.SetMovableState(value)
	YACS.SetMovableState(value)
end

function YACSMenu.SetCombatState(value)
	YACS.SetCombatState(value)
end

function YACSMenu.RestoreDefaults()
	YACS.RestoreDefaults()
end

function YACSMenu.CreateOptionsDate()
	return { 
		[1] = {
			type = "checkbox",
			name = YACS.menu.constants.CHK_ADDON_ENABLED,
			getFunc = YACSMenu.GetAddonState,
			setFunc = YACSMenu.SetAddonState,
			reference = YACSMenu.constants.references.CHECKBOX_ENABLE_ADDON
		},
		[2] = {
			type = "checkbox",
			name = YACS.menu.constants.CHK_PVP,
			getFunc = YACSMenu.GetPvpState,
			setFunc = YACSMenu.SetPvpState,
			reference = YACSMenu.constants.references.CHECKBOX_PVP
		},
		[3] = {
			type = "checkbox",
			name = YACS.menu.constants.CHK_PVE,
			getFunc = YACSMenu.GetPveState,
			setFunc = YACSMenu.SetPveState,
			reference = YACSMenu.constants.references.CHECKBOX_PVE
		},
		[4] = {
			type = "checkbox",
			name = YACS.menu.constants.CHK_COMBAT,
			getFunc = YACSMenu.GetCombatState,
			setFunc = YACSMenu.SetCombatState,
			reference = YACSMenu.constants.references.CHECKBOX_COMBAT
		},
		[5] = {
			type = "checkbox",
			name = YACS.menu.constants.CHK_MOVABLE,
			getFunc = YACSMenu.GetMovableState,
			setFunc = YACSMenu.SetMovableState,
			reference = YACSMenu.constants.references.CHECKBOX_MOVABLE
		},
		[6] = {
			type = "colorpicker",
			name = YACS.menu.constants.COLOR_COMPASS,
			getFunc = YACSMenu.GetCompassColor,
			setFunc = YACSMenu.SetCompassColor,
			width = "full"
		},
		[7] = {
			type = "slider",
			name = YACS.menu.constants.COMPASS_SIZE,
			tooltip = YACS.menu.constants.COMPASS_SIZE_TOOLTIPE,
			min = 10,
			max = 500,
			step = 1,
			getFunc = YACSMenu.GetCompassSize,
			setFunc = YACSMenu.SetCompassSize,
			width = "full",
			default = YACSMenu.GetCompassSize()
		},
		[8] = {
			type = "dropdown",
			name = YACS.menu.constants.COMPASS_STYLE,
			tooltip = YACS.menu.constants.COMPASS_STYLE_TOOLTIP,
			choices = YACSMenu.GetCompassStyles(),
			getFunc = YACSMenu.GetCurrentCompassStyle,
			setFunc = YACSMenu.SetCurrentCompassStyle,
			reference = YACSMenu.constants.references.DROPDOWN_COMPASS_STYLES
		},
		[9] = {
			type = "button",
			name = YACS.menu.constants.RESTORE_DEFAULTS,
			func = YACSMenu.RestoreDefaults,
			width = "full"
		},
	}
end

function YACSMenu.Initialize()
	YACSMenu.lam.optionsData = YACSMenu.CreateOptionsDate()
	YACSMenu.lam.panel = LAM:RegisterAddonPanel(YACSMenu.name, YACSMenu.lam.panelData)
	LAM:RegisterOptionControls(YACSMenu.name, YACSMenu.lam.optionsData)
end