-- RdK Group Tool Alliance Color
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.allianceColor = RdKGToolUtil.allianceColor or {}
local RdKGToolAC = RdKGToolUtil.allianceColor
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGToolUtil.math = RdKGToolUtil.math or {}
local RdKGToolMath = RdKGToolUtil.math

RdKGToolAC.callbackName = RdKGTool.addonName .. "UtilAllianceColor"

RdKGToolAC.config = {}

RdKGToolAC.state = {}
RdKGToolAC.state.initialized = false
RdKGToolAC.state.adColor = "FFFFFF"
RdKGToolAC.state.epColor = "FFFFFF"
RdKGToolAC.state.dcColor = "FFFFFF"
RdKGToolAC.state.noAllianceColor = "FFFFFF"

RdKGToolAC.constants = RdKGToolAC.constants or {}

function RdKGToolAC.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolAC.callbackName, RdKGToolAC.OnProfileChanged)
	
	RdKGToolAC.UpdateColors()
end

function RdKGToolAC.GetDefaults()
	local defaults = {}
	defaults.ad = {}
	defaults.ad.r = 0.734375
	defaults.ad.g = 0.64453125
	defaults.ad.b = 0.27734375
	defaults.ep = {}
	defaults.ep.r = 0.8671875
	defaults.ep.g = 0.35546875
	defaults.ep.b = 0.3046875
	defaults.dc = {}
	defaults.dc.r = 0.30859375
	defaults.dc.g = 0.50390625
	defaults.dc.b = 0.73828125
	defaults.noAlliance = {}
	defaults.noAlliance.r = 1
	defaults.noAlliance.g = 1
	defaults.noAlliance.b = 1
	return defaults
end

function RdKGToolAC.UpdateColors()
	RdKGToolAC.state.adColor = RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolAC.acVars.ad.r)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolAC.acVars.ad.g)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolAC.acVars.ad.b))
	RdKGToolAC.state.epColor = RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolAC.acVars.ep.r)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolAC.acVars.ep.g)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolAC.acVars.ep.b))
	RdKGToolAC.state.dcColor = RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolAC.acVars.dc.r)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolAC.acVars.dc.g)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolAC.acVars.dc.b))
	RdKGToolAC.state.noAllianceColor = RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolAC.acVars.noAlliance.r)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolAC.acVars.noAlliance.g)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolAC.acVars.noAlliance.b))
end

function RdKGToolAC.GetColorForAlliance(alliance)
	if alliance == ALLIANCE_ALDMERI_DOMINION then
		return RdKGToolAC.acVars.ad
	elseif alliance == ALLIANCE_EBONHEART_PACT then
		return RdKGToolAC.acVars.ep
	elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then
		return RdKGToolAC.acVars.dc
	else
		return RdKGToolAC.acVars.noAlliance
	end
end

function RdKGToolAC.GetHexColorForAlliance(alliance)
	if alliance == ALLIANCE_ALDMERI_DOMINION then
		return RdKGToolAC.state.adColor
	elseif alliance == ALLIANCE_EBONHEART_PACT then
		return RdKGToolAC.state.epColor
	elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then
		return RdKGToolAC.state.dcColor
	else
		return RdKGToolAC.state.noAllianceColor
	end
end

function RdKGToolAC.GetNoAllianceColor()
	return RdKGToolAC.acVars.noAlliance
end

function RdKGToolAC.GetNoAllianceHexColor()
	return RdKGToolAC.state.noAllianceColor
end

function RdKGToolAC.DyeAllianceString(message, alliance)
	if message ~= nil and alliance ~= nil then
		return string.format("|c%s%s|r", RdKGToolAC.GetHexColorForAlliance(alliance), message)
	end
	return nil
end

--callbacks
function RdKGToolAC.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolAC.acVars = currentProfile.util.allianceColor
		RdKGToolAC.UpdateColors()
	end
end

--menu interaction
function RdKGToolAC.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.AC_HEADER,
			controls = {
				[1] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.AC_DC_COLOR,
					getFunc = RdKGToolAC.GetAcDCColor,
					setFunc = RdKGToolAC.SetAcDCColor,
					width = "full"
				},
				[2] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.AC_EP_COLOR,
					getFunc = RdKGToolAC.GetAcEPColor,
					setFunc = RdKGToolAC.SetAcEPColor,
					width = "full"
				},
				[3] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.AC_AD_COLOR,
					getFunc = RdKGToolAC.GetAcADColor,
					setFunc = RdKGToolAC.SetAcADColor,
					width = "full"
				},
				[4] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.AC_NO_ALLIANCE_COLOR,
					getFunc = RdKGToolAC.GetAcNoAllianceColor,
					setFunc = RdKGToolAC.SetAcNoAllianceColor,
					width = "full"
				}
			}
		}
	}
	return menu
end

function RdKGToolAC.GetAcADColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolAC.acVars.ad)
end

function RdKGToolAC.SetAcADColor(r, g, b)
	RdKGToolAC.acVars.ad = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolAC.UpdateColors()
end

function RdKGToolAC.GetAcEPColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolAC.acVars.ep)
end

function RdKGToolAC.SetAcEPColor(r, g, b)
	RdKGToolAC.acVars.ep = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolAC.UpdateColors()
end

function RdKGToolAC.GetAcDCColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolAC.acVars.dc)
end

function RdKGToolAC.SetAcDCColor(r, g, b)
	RdKGToolAC.acVars.dc = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolAC.UpdateColors()
end

function RdKGToolAC.GetAcNoAllianceColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolAC.acVars.noAlliance)
end

function RdKGToolAC.SetAcNoAllianceColor(r, g, b)
	RdKGToolAC.acVars.noAlliance = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolAC.UpdateColors()
end