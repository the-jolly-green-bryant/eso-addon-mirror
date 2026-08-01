-- RdK Group Tool UI Buffs
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.ui = RdKGTool.ui or {}
local RdKGToolUI = RdKGTool.ui
RdKGToolUI.buffs = RdKGToolUI.buffs or {}
local RdKGToolBuffs = RdKGToolUI.buffs
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts

local wm = WINDOW_MANAGER

RdKGToolBuffs.config = {}
RdKGToolBuffs.config.defaults = {}
RdKGToolBuffs.config.defaults.width = 150
RdKGToolBuffs.config.defaults.height = 20

function RdKGToolBuffs.CreateBuffControl(tlw, rLocX, rLocY)
	local control = nil
	if tlw ~= nil then
		local font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolBuffs.config.defaults.height - 4, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
		
		control = wm:CreateControl(nil, tlw, CT_CONTROL)
			
		control:SetDimensions(RdKGToolBuffs.config.defaults.width, RdKGToolBuffs.config.defaults.height)
		control:SetAnchor(TOPLEFT, tlw, TOPLEFT, rLocX, rLocY)
		
		control.backdrop = wm:CreateControl(nil, control, CT_BACKDROP)
		control.backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
		control.backdrop:SetDimensions(RdKGToolBuffs.config.defaults.width, RdKGToolBuffs.config.defaults.height)
		control.backdrop:SetCenterColor(1, 0, 0, 0.0)
		control.backdrop:SetEdgeColor(1, 0, 0, 0.0)
		
		control.edge = wm:CreateControl(nil, control, CT_BACKDROP)
		control.edge:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
		control.edge:SetDimensions(RdKGToolBuffs.config.defaults.width, RdKGToolBuffs.config.defaults.height)
		control.edge:SetEdgeTexture(nil, 1, 1, 1, 0)
		control.edge:SetCenterColor(0, 0, 0, 0)
		control.edge:SetEdgeColor(0, 0, 0, 1)
		
		control.progress = wm:CreateControl(nil, control, CT_STATUSBAR)
		control.progress:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolBuffs.config.defaults.height - 1, 1)
		control.progress:SetDimensions(RdKGToolBuffs.config.defaults.width - RdKGToolBuffs.config.defaults.height, RdKGToolBuffs.config.defaults.height - 2)
		control.progress:SetMinMax(0, 100)
		control.progress:SetValue(0)
		
		control.timeLabel = wm:CreateControl(nil, control, CT_LABEL)
		control.timeLabel:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolBuffs.config.defaults.height, 0)
		control.timeLabel:SetFont(font)
		control.timeLabel:SetWrapMode(ELLIPSIS)
		control.timeLabel:SetDimensions(RdKGToolBuffs.config.defaults.width - RdKGToolBuffs.config.defaults.height, RdKGToolBuffs.config.defaults.height - 2)
		--control.timeLabel:SetText("test")
		control.timeLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		control.timeLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		
		control.texture = wm:CreateControl(nil, control, CT_TEXTURE)
		control.texture:SetAnchor(TOPLEFT, control, TOPLEFT, 1, 1)
		control.texture:SetDimensions(RdKGToolBuffs.config.defaults.height - 2, RdKGToolBuffs.config.defaults.height - 2)
		
	end
	return control
end

