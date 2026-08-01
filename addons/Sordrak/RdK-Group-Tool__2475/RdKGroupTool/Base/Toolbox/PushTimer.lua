-- RdK Group Tool Push Timer
-- By @s0rdrak (PC / EU)

RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGToolTB.pt = RdKGToolTB.pt or {}
local RdKGToolPt = RdKGToolTB.pt
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolUtilGroup = RdKGToolUtil.group
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts

RdKGToolPt.constants = RdKGToolPt.constants or {}
RdKGToolPt.constants.TLW_TIMER = "RdKGTool.toolbox.pt.timertlw"
RdKGToolPt.constants.TLW_OVERVIEW = "RdKGTool.toolbox.pt.overviewtlw"
RdKGToolPt.constants.TLW_REACTION = "RdKGTool.toolbox.pt.reactiontlw"
RdKGToolPt.constants.size = {}
RdKGToolPt.constants.size.SMALL = 1
RdKGToolPt.constants.size.BIG = 2
RdKGToolPt.constants.time = {}
RdKGToolPt.constants.time.MIN = 0.0
RdKGToolPt.constants.time.MAX = 8.0

RdKGToolPt.callbackName = RdKGTool.addonName .. "PushTimer"

RdKGToolPt.config = {}
RdKGToolPt.config.updateFeatureInterval = 100
RdKGToolPt.config.updateInterval = 25
RdKGToolPt.config.isClampedToScreen = true
RdKGToolPt.config.ratio = 6.0
RdKGToolPt.config.timerSizes = {}
RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL] = {}
RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].width = 150
RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].height = 30
RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].fontSize = 25
RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.BIG] = {}
RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.BIG].width = 300
RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.BIG].height = 60
RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.BIG].fontSize = 50
RdKGToolPt.config.overviewSizes = {}
RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL] = {}
RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].width = 60
RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].height = 30
RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].fontSize = 25
RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.BIG] = {}
RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.BIG].width = 120
RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.BIG].height = 60
RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.BIG].fontSize = 50
RdKGToolPt.config.reactionSizes = {}
RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL] = {}
RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].width = 200
RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].height = 30
RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].fontSize = 25
RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.BIG] = {}
RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.BIG].width = 400
RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.BIG].height = 60
RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.BIG].fontSize = 50

RdKGToolPt.state = {}
RdKGToolPt.state.initialized = false
RdKGToolPt.state.foreground = true
RdKGToolPt.state.registredConsumers = false
RdKGToolPt.state.activeLayerIndex = 1
RdKGToolPt.state.registredActiveConsumers = false
RdKGToolPt.state.width = RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].width
RdKGToolPt.state.height = RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].height
RdKGToolPt.state.fontSize = RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].fontSize
RdKGToolPt.state.font = nil
RdKGToolPt.state.overviewWidth = RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].width
RdKGToolPt.state.overviewHeight = RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].height
RdKGToolPt.state.overviewFontSize = RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].fontSize
RdKGToolPt.state.overviewFont = nil
RdKGToolPt.state.reactionWidth = RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].width
RdKGToolPt.state.reactionHeight = RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].height
RdKGToolPt.state.reactionFontSize = RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].fontSize
RdKGToolPt.state.reactionFont = nil

RdKGToolPt.controls = {}

local wm = WINDOW_MANAGER

function RdKGToolPt.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolPt.callbackName, RdKGToolPt.OnProfileChanged)
		
	RdKGToolPt.CreateUI()
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolPt.SetPtPositionLocked)
	
	RdKGToolPt.state.initialized = true
	RdKGToolPt.InitializeControlSettings()
end

function RdKGToolPt.InitializeControlSettings()
	RdKGToolPt.SetEnabled(RdKGToolPt.ptVars.enabled)
	RdKGToolPt.SetControlVisibility()
	RdKGToolPt.SetPositionLocked(RdKGToolPt.ptVars.positionLocked)
	RdKGToolPt.AdjustColors()
	RdKGToolPt.AdjustSize()
end

function RdKGToolPt.SetTimerTlwLocation()
	RdKGToolPt.controls.timerTLW:ClearAnchors()
	if RdKGToolPt.ptVars.timerLocation == nil then
		RdKGToolPt.controls.timerTLW:SetAnchor(CENTER, GuiRoot, CENTER, 0, -100)
	else
		RdKGToolPt.controls.timerTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolPt.ptVars.timerLocation.x, RdKGToolPt.ptVars.timerLocation.y)
	end
end

function RdKGToolPt.SetTimerOverviewTlwLocation()
	RdKGToolPt.controls.timerOverviewTLW:ClearAnchors()
	if RdKGToolPt.ptVars.timerOverviewLocation == nil then
		RdKGToolPt.controls.timerOverviewTLW:SetAnchor(CENTER, GuiRoot, CENTER, 50, -150)
	else
		RdKGToolPt.controls.timerOverviewTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolPt.ptVars.timerOverviewLocation.x, RdKGToolPt.ptVars.timerOverviewLocation.y)
	end
end

function RdKGToolPt.SetReactionTlwLocation()
	RdKGToolPt.controls.reactionTLW:ClearAnchors()
	if RdKGToolPt.ptVars.reactionLocation == nil then
		RdKGToolPt.controls.reactionTLW:SetAnchor(CENTER, GuiRoot, CENTER, 200, -100)
	else
		RdKGToolPt.controls.reactionTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolPt.ptVars.reactionLocation.x, RdKGToolPt.ptVars.reactionLocation.y)
	end
end

function RdKGToolPt.CreateUI()
	RdKGToolPt.controls.timerTLW = wm:CreateTopLevelWindow(RdKGToolPt.constants.TLW_TIMER)
	RdKGToolPt.SetTimerTlwLocation()
	
	RdKGToolPt.controls.timerTLW:SetClampedToScreen(RdKGToolPt.config.isClampedToScreen)
	RdKGToolPt.controls.timerTLW:SetHandler("OnMoveStop", RdKGToolPt.SaveTimerWindowLocation)
	
	RdKGToolPt.controls.timerTLW.rootControl = wm:CreateControl(nil, RdKGToolPt.controls.timerTLW, CT_CONTROL)
	local rootControl = RdKGToolPt.controls.timerTLW.rootControl
	
	rootControl:SetAnchor(TOPLEFT, RdKGToolPt.controls.timerTLW, TOPLEFT, 0, 0)
	
	rootControl.movableBackdrop = wm:CreateControl(nil, rootControl, CT_BACKDROP)
	
	rootControl.movableBackdrop:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	
	rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	rootControl.timer = wm:CreateControl(nil, rootControl, CT_CONTROL)
	local timer = rootControl.timer
	
	local sizeIncrease = RdKGToolPt.ptVars.size - RdKGToolPt.constants.size.SMALL
	local height = (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].height + (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.BIG].height - RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].height) * sizeIncrease)
	local width = (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].width + (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.BIG].width - RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].width) * sizeIncrease)
	local fontSize = (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].fontSize + (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.BIG].fontSize - RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].fontSize) * sizeIncrease)
	local font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	RdKGToolPt.state.width = width
	RdKGToolPt.state.height = height
	RdKGToolPt.state.fontSize = fontSize
	RdKGToolPt.state.font = font
	
	timer:SetDimensions(width, height)
	
	timer.edge = wm:CreateControl(nil, timer, CT_BACKDROP)
	timer.edge:SetAnchor(TOPLEFT, timer, TOPLEFT, 0, 0)
	timer.edge:SetDimensions(width, height)
	timer.edge:SetEdgeTexture(nil, 2, 2, 2, 0)
	timer.edge:SetCenterColor(0, 0, 0, 0)
	timer.edge:SetEdgeColor(0, 0, 0, 1)
	
	timer.progress = wm:CreateControl(nil, timer, CT_STATUSBAR)
	timer.progress:SetAnchor(CENTER, timer, CENTER, 0, 0)
	timer.progress:SetDimensions(width - 4, height - 4)
	timer.progress:SetMinMax(0, 100)
	timer.progress:SetValue(0)
	timer.progress:SetDrawTier(DT_LOW)
	
	timer.timeLabel = wm:CreateControl(nil, timer, CT_LABEL)
	timer.timeLabel:SetAnchor(CENTER, timer, CENTER, 0, 0)
	timer.timeLabel:SetFont(font)
	timer.timeLabel:SetWrapMode(ELLIPSIS)
	timer.timeLabel:SetDimensions(width - 6, height)
	timer.timeLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	timer.timeLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	timer.timeLabel:SetColor(RdKGToolPt.ptVars.fontColor.r, RdKGToolPt.ptVars.fontColor.g, RdKGToolPt.ptVars.fontColor.b)
	
	timer.lead, timer.detos, timer.shalks, timer.souls = RdKGToolPt.CreateLines(timer, height)
	
	
	
	
	RdKGToolPt.controls.timerOverviewTLW = wm:CreateTopLevelWindow(RdKGToolPt.constants.TLW_OVERVIEW)
	RdKGToolPt.SetTimerOverviewTlwLocation()
	RdKGToolPt.controls.timerOverviewTLW:SetClampedToScreen(RdKGToolPt.config.isClampedToScreen)
	RdKGToolPt.controls.timerOverviewTLW:SetHandler("OnMoveStop", RdKGToolPt.SaveTimerOverviewWindowLocation)
	RdKGToolPt.controls.timerOverviewTLW.rootControl = wm:CreateControl(nil, RdKGToolPt.controls.timerOverviewTLW, CT_CONTROL)
	rootControl = RdKGToolPt.controls.timerOverviewTLW.rootControl
	rootControl:SetAnchor(TOPLEFT, RdKGToolPt.controls.timerOverviewTLW, TOPLEFT, 0, 0)
	rootControl.movableBackdrop = wm:CreateControl(nil, rootControl, CT_BACKDROP)
	rootControl.movableBackdrop:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	sizeIncrease = RdKGToolPt.ptVars.overviewSize - RdKGToolPt.constants.size.SMALL
	height = (RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].height + (RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.BIG].height - RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].height) * sizeIncrease)
	width = (RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].width + (RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.BIG].width - RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].width) * sizeIncrease)
	fontSize = (RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].fontSize + (RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.BIG].fontSize - RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].fontSize) * sizeIncrease)
	font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)

	
	rootControl.label = wm:CreateControl(nil, rootControl, CT_LABEL)
	local label = rootControl.label
	label:SetAnchor(CENTER, rootControl, CENTER, 0, 0)
	label:SetFont(font)
	label:SetWrapMode(ELLIPSIS)
	label:SetDimensions(width, height)
	label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	label:SetColor(RdKGToolPt.ptVars.overviewFontColor.r, RdKGToolPt.ptVars.overviewFontColor.g, RdKGToolPt.ptVars.overviewFontColor.b)
	
	
	
	
	
	RdKGToolPt.controls.reactionTLW = wm:CreateTopLevelWindow(RdKGToolPt.constants.TLW_REACTION)
	RdKGToolPt.SetReactionTlwLocation()
	RdKGToolPt.controls.reactionTLW:SetClampedToScreen(RdKGToolPt.config.isClampedToScreen)
	RdKGToolPt.controls.reactionTLW:SetHandler("OnMoveStop", RdKGToolPt.SaveReactionWindowLocation)
	RdKGToolPt.controls.reactionTLW.rootControl = wm:CreateControl(nil, RdKGToolPt.controls.reactionTLW, CT_CONTROL)
	rootControl = RdKGToolPt.controls.reactionTLW.rootControl
	rootControl:SetAnchor(TOPLEFT, RdKGToolPt.controls.reactionTLW, TOPLEFT, 0, 0)
	rootControl.movableBackdrop = wm:CreateControl(nil, rootControl, CT_BACKDROP)
	rootControl.movableBackdrop:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	sizeIncrease = RdKGToolPt.ptVars.reactionSize - RdKGToolPt.constants.size.SMALL
	height = (RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].height + (RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.BIG].height - RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].height) * sizeIncrease)
	width = (RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].width + (RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.BIG].width - RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].width) * sizeIncrease)
	fontSize = (RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].fontSize + (RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.BIG].fontSize - RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].fontSize) * sizeIncrease)
	font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)

	rootControl.label = wm:CreateControl(nil, rootControl, CT_LABEL)
	label = rootControl.label
	label:SetAnchor(CENTER, rootControl, CENTER, 0, 0)
	label:SetFont(font)
	label:SetWrapMode(ELLIPSIS)
	label:SetDimensions(width, height)
	label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	label:SetColor(RdKGToolPt.ptVars.reactionFontColor.r, RdKGToolPt.ptVars.reactionFontColor.g, RdKGToolPt.ptVars.reactionFontColor.b)
	
end

function RdKGToolPt.CreateLines(parent, height)
	local detos = {}
	local shalks = {}
	local souls = {}
	
	local lead = wm:CreateControl(nil, parent, CT_BACKDROP)
	lead:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 2)
	lead:SetDimensions(1, height - 4)
	lead:SetEdgeTexture(nil, 1, 1, 1, 0)
	lead:SetCenterColor(RdKGToolPt.ptVars.leadLineColor.r, RdKGToolPt.ptVars.leadLineColor.g, RdKGToolPt.ptVars.leadLineColor.b, 0.5)
	lead:SetEdgeColor(RdKGToolPt.ptVars.leadLineColor.r, RdKGToolPt.ptVars.leadLineColor.g, RdKGToolPt.ptVars.leadLineColor.b, 1)
	lead:SetDrawTier(DT_HIGH)
	lead:SetHidden(true)
	
	
	for i = 1, 12 do
		local item = wm:CreateControl(nil, parent, CT_BACKDROP)
		item:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 2)
		item:SetDimensions(1, height - 4)
		item:SetEdgeTexture(nil, 1, 1, 1, 0)
		item:SetCenterColor(RdKGToolPt.ptVars.detoColor.r, RdKGToolPt.ptVars.detoColor.g, RdKGToolPt.ptVars.detoColor.b, 0.5)
		item:SetEdgeColor(RdKGToolPt.ptVars.detoColor.r, RdKGToolPt.ptVars.detoColor.g, RdKGToolPt.ptVars.detoColor.b, 1)
		item:SetDrawTier(DT_MEDIUM)
		item:SetHidden(true)
		detos[#detos + 1] = item
	end
	for i = 1, 12 do
		local item = wm:CreateControl(nil, parent, CT_BACKDROP)
		item:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 2)
		item:SetDimensions(1, height - 4)
		item:SetEdgeTexture(nil, 1, 1, 1, 0)
		item:SetCenterColor(RdKGToolPt.ptVars.shalkColor.r, RdKGToolPt.ptVars.shalkColor.g, RdKGToolPt.ptVars.shalkColor.b, 0.5)
		item:SetEdgeColor(RdKGToolPt.ptVars.shalkColor.r, RdKGToolPt.ptVars.shalkColor.g, RdKGToolPt.ptVars.shalkColor.b, 1)
		item:SetDrawTier(DT_MEDIUM)
		item:SetHidden(true)
		shalks[#shalks + 1] = item
	end
	for i = 1, 12 do
		local item = wm:CreateControl(nil, parent, CT_BACKDROP)
		item:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 2)
		item:SetDimensions(1, height - 4)
		item:SetEdgeTexture(nil, 1, 1, 1, 0)
		item:SetCenterColor(RdKGToolPt.ptVars.soulColor.r, RdKGToolPt.ptVars.soulColor.g, RdKGToolPt.ptVars.soulColor.b, 0.5)
		item:SetEdgeColor(RdKGToolPt.ptVars.soulColor.r, RdKGToolPt.ptVars.soulColor.g, RdKGToolPt.ptVars.soulColor.b, 1)
		item:SetDrawTier(DT_MEDIUM)
		item:SetHidden(true)
		souls[#souls + 1] = item
	end
	
	return lead, detos, shalks, souls
end

function RdKGToolPt.AdjustSize()
	local sizeIncrease = RdKGToolPt.ptVars.size - RdKGToolPt.constants.size.SMALL
	local height = (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].height + (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.BIG].height - RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].height) * sizeIncrease)
	local width = (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].width + (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.BIG].width - RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].width) * sizeIncrease)
	local fontSize = (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].fontSize + (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.BIG].fontSize - RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].fontSize) * sizeIncrease)
	local font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	RdKGToolPt.state.width = width
	RdKGToolPt.state.height = height
	RdKGToolPt.state.fontSize = fontSize
	RdKGToolPt.state.font = font
	local rootControl = RdKGToolPt.controls.timerTLW.rootControl
	local timer = rootControl.timer
	timer:ClearAnchors()
	timer:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	timer:SetDimensions(width, height)
	
	timer.edge:SetDimensions(width, height)
		
	timer.progress:SetDimensions(width - 4, height - 4)
	
	timer.timeLabel:SetFont(font)
	timer.timeLabel:SetDimensions(width - 6, height)
		
	RdKGToolPt.controls.timerTLW:SetDimensions(width, height)
	RdKGToolPt.controls.timerTLW.rootControl:SetDimensions(width, height)
	RdKGToolPt.controls.timerTLW.rootControl.movableBackdrop:SetDimensions(width, height)
	
	
	--lines
	timer.lead:SetDimensions(2, height - 4)
	for i = 1, 12 do	
		timer.detos[i]:SetDimensions(2, height - 4)
	end
	for i = 1, 12 do
		timer.shalks[i]:SetDimensions(2, height - 4)
	end
	for i = 1, 12 do
		timer.souls[i]:SetDimensions(2, height - 4)
	end
	
	--timer overview
	sizeIncrease = RdKGToolPt.ptVars.overviewSize - RdKGToolPt.constants.size.SMALL
	height = (RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].height + (RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.BIG].height - RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].height) * sizeIncrease)
	width = (RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].width + (RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.BIG].width - RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].width) * sizeIncrease)
	fontSize = (RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].fontSize + (RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.BIG].fontSize - RdKGToolPt.config.overviewSizes[RdKGToolPt.constants.size.SMALL].fontSize) * sizeIncrease)
	font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	RdKGToolPt.state.overviewWidth = width
	RdKGToolPt.state.overviewHeight = height
	RdKGToolPt.state.overviewFontSize = fontSize
	RdKGToolPt.state.overviewFont = font
	local tlw = RdKGToolPt.controls.timerOverviewTLW
	local overview = tlw.rootControl
	local label = overview.label
	tlw:SetDimensions(width, height)
	overview:SetDimensions(width, height)
	overview.movableBackdrop:SetDimensions(width, height)
	label:SetDimensions(width, height)
	label:SetFont(font)
	
	
	
	
	--reaction
	sizeIncrease = RdKGToolPt.ptVars.reactionSize - RdKGToolPt.constants.size.SMALL
	height = (RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].height + (RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.BIG].height - RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].height) * sizeIncrease)
	width = (RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].width + (RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.BIG].width - RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].width) * sizeIncrease)
	fontSize = (RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].fontSize + (RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.BIG].fontSize - RdKGToolPt.config.reactionSizes[RdKGToolPt.constants.size.SMALL].fontSize) * sizeIncrease)
	font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	RdKGToolPt.state.reactionWidth = width
	RdKGToolPt.state.reactionHeight = height
	RdKGToolPt.state.reactionFontSize = fontSize
	RdKGToolPt.state.reactionFont = font
	tlw = RdKGToolPt.controls.reactionTLW
	overview = tlw.rootControl
	label = overview.label
	tlw:SetDimensions(width, height)
	overview:SetDimensions(width, height)
	overview.movableBackdrop:SetDimensions(width, height)
	label:SetDimensions(width, height)
	label:SetFont(font)
	
end

function RdKGToolPt.GetDefaults()
	local defaults = {}
	defaults.enabled = false
	defaults.pvpOnly = true
	defaults.positionLocked = false
	defaults.size = RdKGToolPt.constants.size.SMALL
	defaults.timerEnabled = true
	defaults.timerTextEnabled = true
	defaults.timerShowAllEnabled = true
	defaults.fontColor = {}
	defaults.fontColor.r = 1
	defaults.fontColor.g = 1
	defaults.fontColor.b = 1
	defaults.leadColor = {}
	defaults.leadColor.r = 0.578125
	defaults.leadColor.g = 0.2890625
	defaults.leadColor.b = 0.640625
	defaults.leadLineColor = {}
	defaults.leadLineColor.r = 1.0
	defaults.leadLineColor.g = 0.0
	defaults.leadLineColor.b = 0.0
	defaults.shalkColor = {}
	defaults.shalkColor.r = 0.1
	defaults.shalkColor.g = 0.95
	defaults.shalkColor.b = 0.1
	defaults.detoColor = {}
	defaults.detoColor.r = 1
	defaults.detoColor.g = 0.8
	defaults.detoColor.b = 0.1
	defaults.soulColor = {}
	defaults.soulColor.r = 1
	defaults.soulColor.g = 0.4
	defaults.soulColor.b = 0.0
	defaults.smoothTransition = false
	defaults.overviewEnabled = false
	defaults.overviewFontColor = {}
	defaults.overviewFontColor.r = 1.0
	defaults.overviewFontColor.g = 0.0
	defaults.overviewFontColor.b = 0.0
	defaults.overviewSize = RdKGToolPt.constants.size.SMALL
	defaults.reactionEnabled = false
	defaults.reactionFontColor = {}
	defaults.reactionFontColor.r = 1.0
	defaults.reactionFontColor.g = 0.0
	defaults.reactionFontColor.b = 0.0
	defaults.reactionSize = RdKGToolPt.constants.size.SMALL
	defaults.reactionText = "Push"
	defaults.reactionTime = 2.0
	return defaults
end

function RdKGToolPt.SetControlVisibility()
	local enabled = RdKGToolPt.ptVars.enabled
	local pvpOnly = RdKGToolPt.ptVars.pvpOnly
	local setHidden = true
	if enabled ~= nil and pvpOnly ~= nil then

		if enabled == true and (pvpOnly == false or (pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
			setHidden = false
		end
	end
	if setHidden == false then
		if RdKGToolPt.state.foreground == false then
			RdKGToolPt.controls.timerTLW:SetHidden(RdKGToolPt.state.activeLayerIndex > 2)
			RdKGToolPt.controls.timerOverviewTLW:SetHidden(RdKGToolPt.state.activeLayerIndex > 2)
			RdKGToolPt.controls.reactionTLW:SetHidden(RdKGToolPt.state.activeLayerIndex > 2)
		else
			RdKGToolPt.controls.timerTLW:SetHidden(false)
			RdKGToolPt.controls.timerOverviewTLW:SetHidden(false)
			RdKGToolPt.controls.reactionTLW:SetHidden(false)
		end
		--visible windows and text settings
		RdKGToolPt.controls.timerTLW.rootControl.timer.timeLabel:SetHidden(not RdKGToolPt.ptVars.timerTextEnabled)
		RdKGToolPt.controls.timerTLW.rootControl.timer:SetHidden(not RdKGToolPt.ptVars.timerEnabled)
		--overview
		RdKGToolPt.controls.timerOverviewTLW.rootControl:SetHidden(not RdKGToolPt.ptVars.overviewEnabled)
		RdKGToolPt.controls.reactionTLW.rootControl:SetHidden(not RdKGToolPt.ptVars.reactionEnabled)
		if RdKGToolPt.ptVars.timerShowAllEnabled == false then
			local rootControl = RdKGToolPt.controls.timerTLW.rootControl
			local timer = rootControl.timer
			timer.lead:SetHidden(true)
			for i = 1, 12 do	
				timer.detos[i]:SetHidden(true)
			end
			for i = 1, 12 do
				timer.shalks[i]:SetHidden(true)
			end
			for i = 1, 12 do
				timer.souls[i]:SetHidden(true)
			end
		end
	else
		RdKGToolPt.controls.timerTLW:SetHidden(setHidden)
		RdKGToolPt.controls.timerOverviewTLW:SetHidden(setHidden)
		RdKGToolPt.controls.reactionTLW:SetHidden(setHidden)
	end
end

function RdKGToolPt.SetPositionLocked(value)
	RdKGToolPt.ptVars.positionLocked = value
	RdKGToolPt.controls.timerTLW:SetMovable(not value)
	RdKGToolPt.controls.timerTLW:SetMouseEnabled(not value)
	RdKGToolPt.controls.timerOverviewTLW:SetMovable(not value)
	RdKGToolPt.controls.timerOverviewTLW:SetMouseEnabled(not value)
	RdKGToolPt.controls.reactionTLW:SetMovable(not value)
	RdKGToolPt.controls.reactionTLW:SetMouseEnabled(not value)
	if value == true then
		RdKGToolPt.controls.timerTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolPt.controls.timerTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		RdKGToolPt.controls.timerOverviewTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolPt.controls.timerOverviewTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		RdKGToolPt.controls.reactionTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolPt.controls.reactionTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	else
		RdKGToolPt.controls.timerTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolPt.controls.timerTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		RdKGToolPt.controls.timerOverviewTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolPt.controls.timerOverviewTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		RdKGToolPt.controls.reactionTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolPt.controls.reactionTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	end
end

function RdKGToolPt.AdjustColors()
	local rootControl = RdKGToolPt.controls.timerTLW.rootControl
	local timer = rootControl.timer
	timer.progress:SetColor(RdKGToolPt.ptVars.leadColor.r, RdKGToolPt.ptVars.leadColor.g, RdKGToolPt.ptVars.leadColor.b)
	timer.timeLabel:SetColor(RdKGToolPt.ptVars.fontColor.r, RdKGToolPt.ptVars.fontColor.g, RdKGToolPt.ptVars.fontColor.b)
	
	--lines
	timer.lead:SetCenterColor(RdKGToolPt.ptVars.leadLineColor.r, RdKGToolPt.ptVars.leadLineColor.g, RdKGToolPt.ptVars.leadLineColor.b, 0.5)
	timer.lead:SetEdgeColor(RdKGToolPt.ptVars.leadLineColor.r, RdKGToolPt.ptVars.leadLineColor.g, RdKGToolPt.ptVars.leadLineColor.b, 1)
	for i = 1, 12 do	
		timer.detos[i]:SetCenterColor(RdKGToolPt.ptVars.detoColor.r, RdKGToolPt.ptVars.detoColor.g, RdKGToolPt.ptVars.detoColor.b, 0.5)
		timer.detos[i]:SetEdgeColor(RdKGToolPt.ptVars.detoColor.r, RdKGToolPt.ptVars.detoColor.g, RdKGToolPt.ptVars.detoColor.b, 1)
	end
	for i = 1, 12 do
		timer.shalks[i]:SetCenterColor(RdKGToolPt.ptVars.shalkColor.r, RdKGToolPt.ptVars.shalkColor.g, RdKGToolPt.ptVars.shalkColor.b, 0.5)
		timer.shalks[i]:SetEdgeColor(RdKGToolPt.ptVars.shalkColor.r, RdKGToolPt.ptVars.shalkColor.g, RdKGToolPt.ptVars.shalkColor.b, 1)
	end
	for i = 1, 12 do
		timer.souls[i]:SetCenterColor(RdKGToolPt.ptVars.soulColor.r, RdKGToolPt.ptVars.soulColor.g, RdKGToolPt.ptVars.soulColor.b, 0.5)
		timer.souls[i]:SetEdgeColor(RdKGToolPt.ptVars.soulColor.r, RdKGToolPt.ptVars.soulColor.g, RdKGToolPt.ptVars.soulColor.b, 1)
	end
	
	RdKGToolPt.controls.timerOverviewTLW.rootControl.label:SetColor(RdKGToolPt.ptVars.overviewFontColor.r, RdKGToolPt.ptVars.overviewFontColor.g, RdKGToolPt.ptVars.overviewFontColor.b)
	RdKGToolPt.controls.reactionTLW.rootControl.label:SetColor(RdKGToolPt.ptVars.reactionFontColor.r, RdKGToolPt.ptVars.reactionFontColor.g, RdKGToolPt.ptVars.reactionFontColor.b)
end

function RdKGToolPt.SetEnabled(value)
	if RdKGToolPt.state.initialized == true and value ~= nil then
		RdKGToolPt.ptVars.enabled = value
		if value == true then
			if RdKGToolPt.state.registredConsumers == false then
				
				EVENT_MANAGER:RegisterForEvent(RdKGToolPt.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolPt.OnPlayerActivated)
				
			end
			RdKGToolPt.state.registredConsumers = true
		else
			if RdKGToolPt.state.registredConsumers == true then
				
				EVENT_MANAGER:UnregisterForEvent(RdKGToolPt.callbackName, EVENT_PLAYER_ACTIVATED)
				
			end
			RdKGToolPt.state.registredConsumers = false
		end
		RdKGToolPt.OnPlayerActivated()
	end
end

--callbacks
function RdKGToolPt.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolPt.ptVars = currentProfile.toolbox.pt
		RdKGToolPt.SetEnabled(RdKGToolPt.ptVars.enabled)
		if RdKGToolPt.state.initialized == true then
			RdKGToolPt.InitializeControlSettings()
			RdKGToolPt.SetTimerTlwLocation()
			RdKGToolPt.SetTimerOverviewTlwLocation()
			RdKGToolPt.SetReactionTlwLocation()
		end
	end
end

function RdKGToolPt.SaveTimerWindowLocation()
	if RdKGToolPt.ptVars.positionLocked == false then
		RdKGToolPt.ptVars.timerLocation = RdKGToolPt.ptVars.timerLocation or {}
		RdKGToolPt.ptVars.timerLocation.x = RdKGToolPt.controls.timerTLW:GetLeft()
		RdKGToolPt.ptVars.timerLocation.y = RdKGToolPt.controls.timerTLW:GetTop()
	end
end

function RdKGToolPt.SaveTimerOverviewWindowLocation()
	if RdKGToolPt.ptVars.positionLocked == false then
		RdKGToolPt.ptVars.timerOverviewLocation = RdKGToolPt.ptVars.timerOverviewLocation or {}
		RdKGToolPt.ptVars.timerOverviewLocation.x = RdKGToolPt.controls.timerOverviewTLW:GetLeft()
		RdKGToolPt.ptVars.timerOverviewLocation.y = RdKGToolPt.controls.timerOverviewTLW:GetTop()
	end
end

function RdKGToolPt.SaveReactionWindowLocation()
	if RdKGToolPt.ptVars.positionLocked == false then
		RdKGToolPt.ptVars.reactionLocation = RdKGToolPt.ptVars.reactionLocation or {}
		RdKGToolPt.ptVars.reactionLocation.x = RdKGToolPt.controls.reactionTLW:GetLeft()
		RdKGToolPt.ptVars.reactionLocation.y = RdKGToolPt.controls.reactionTLW:GetTop()
	end
end

function RdKGToolPt.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolPt.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolPt.state.foreground = false
	end
	--hack?
	RdKGToolPt.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolPt.SetControlVisibility()
end

function RdKGToolPt.OnPlayerActivated(eventCode, initial)

	if RdKGToolPt.ptVars.enabled == true and (RdKGToolPt.ptVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true or RdKGToolPt.ptVars.pvpOnly == false) then
		--d("register")
		if RdKGToolPt.state.registredActiveConsumers == false then
			EVENT_MANAGER:RegisterForEvent(RdKGToolPt.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolPt.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForEvent(RdKGToolPt.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolPt.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolPt.callbackName, RdKGToolPt.config.updateInterval, RdKGToolPt.UiLoop)
			RdKGToolUtilGroup.AddFeature(RdKGToolPt.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS, RdKGToolPt.config.updateFeatureInterval)
			RdKGToolPt.state.registredActiveConsumers = true
		end
	else
		--d("unregister")
		if RdKGToolPt.state.registredActiveConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(RdKGToolPt.callbackName, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolPt.callbackName, EVENT_ACTION_LAYER_PUSHED)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolPt.callbackName)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolPt.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS)
			RdKGToolPt.state.registredActiveConsumers = false
		end
	end
	RdKGToolPt.SetControlVisibility()
end

function RdKGToolPt.UiLoop()
	--d("pt-1")
	if RdKGToolPt.ptVars.pvpOnly == false or (RdKGToolPt.ptVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea()) then
		local players = RdKGToolUtilGroup.GetGroupInformation()
		--d("pt0")
		if players ~= nil then
			local timeStamp = GetGameTimeMilliseconds() / 1000
			local tlw = RdKGToolPt.controls.timerTLW
			local label = RdKGToolPt.controls.timerOverviewTLW.rootControl.label
			local reactionLabel = RdKGToolPt.controls.reactionTLW.rootControl.label
			local rootControl = tlw.rootControl
			local timer = rootControl.timer
			local currentShalks = 1
			local currentDetos = 1
			local currentSouls = 1
			local sizeIncrease = RdKGToolPt.ptVars.size - RdKGToolPt.constants.size.SMALL
			local width = (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].width + (RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.BIG].width - RdKGToolPt.config.timerSizes[RdKGToolPt.constants.size.SMALL].width) * sizeIncrease) - 4
			local borderVisible = false
			
	
	
			for i = 1, #players do
				if players[i] ~= nil and players[i].buffs ~= nil and players[i].buffs.specialInformation ~= nil then
					--detos
					--d("pt1")
					if players[i].isLeader == true or #players == 1 then
					--d("pt2")
						if players[i].buffs.specialInformation.proximityDetonation ~= nil and players[i].buffs.specialInformation.proximityDetonation.active == true then
							local ending = players[i].buffs.specialInformation.proximityDetonation.ending
							local started = players[i].buffs.specialInformation.proximityDetonation.started
							local remaining = ending - timeStamp
							local percent = remaining / (ending - started) * 100
							--d(percent)
							if percent < 0 then
								percent = 0
							end
							if remaining < 0 then
								remaining = 0
							end
							--timer:SetHidden(false)
							ZO_StatusBar_SmoothTransition(timer.progress, percent, 100, not RdKGToolPt.ptVars.smoothTransition)
							timer.timeLabel:SetText(string.format("%.1f", remaining))
							label:SetText(string.format("%.1f", remaining))
							
							if RdKGToolPt.ptVars.timerShowAllEnabled == true then
								local location = width / 100 * percent
								timer.lead:SetHidden(false)
								timer.lead:ClearAnchors()
								timer.lead:SetAnchor(TOPLEFT, timer, TOPLEFT, location + 2, 2)
								if remaining > 0 and remaining < RdKGToolPt.ptVars.reactionTime then
									reactionLabel:SetText(RdKGToolPt.ptVars.reactionText)
									reactionLabel:SetHidden(false)
								else
									reactionLabel:SetHidden(true)
								end
							end
							borderVisible = true
						else
							--timer:SetHidden(true)
							label:SetText("")
							timer.progress:SetValue(0)
							timer.timeLabel:SetText("")
							timer.lead:SetHidden(true)
							reactionLabel:SetText("")
							reactionLabel:SetHidden(true)
						end
					else
					--d("pt3")
						if RdKGToolPt.ptVars.timerShowAllEnabled == true then
							if players[i].buffs.specialInformation.proximityDetonation ~= nil and players[i].buffs.specialInformation.proximityDetonation.active == true then
								local ending = players[i].buffs.specialInformation.proximityDetonation.ending
								local started = players[i].buffs.specialInformation.proximityDetonation.started
								local remaining = ending - timeStamp
								local item = timer.detos[currentDetos]
								local percent = remaining / (ending - started) * 100
								if percent < 0 then
									percent = 0
								end
								local location = width / 100 * percent
								item:ClearAnchors()
								
								
								item:SetAnchor(TOPLEFT, timer, TOPLEFT, location + 2, 2)
								item:SetHidden(false)
								currentDetos = currentDetos + 1
								borderVisible = true
							end
						end
						
					end
					if RdKGToolPt.ptVars.timerShowAllEnabled == true then
						for j = currentDetos, 12 do
							timer.detos[j]:SetHidden(true)
						end
					end
					--shalks
					if RdKGToolPt.ptVars.timerShowAllEnabled == true then
						--shalks
						if players[i].buffs.specialInformation.subterraneanAssault ~= nil and players[i].buffs.specialInformation.subterraneanAssault.active == true then
							--6 secs
							local ending = players[i].buffs.specialInformation.subterraneanAssault.ending
							local started = players[i].buffs.specialInformation.subterraneanAssault.started
							local remaining = ending - timeStamp
							if players[i].buffs.specialInformation.subterraneanAssault.waveTwo == false then
								remaining = remaining + 3
							end
							local item = timer.shalks[currentShalks]
							local percent = remaining / 8 * 100 --8secs, not 100% (6/3)
							if percent < 0 then
								percent = 0
							end
							local location = width / 100 * percent
							item:ClearAnchors()						
							item:SetAnchor(TOPLEFT, timer, TOPLEFT, location + 2, 2)
							item:SetHidden(false)
							currentShalks = currentShalks + 1
							borderVisible = true
						end
						if players[i].buffs.specialInformation.deepFissure ~= nil and players[i].buffs.specialInformation.deepFissure.active == true then
							--9 secs
							local ending = players[i].buffs.specialInformation.deepFissure.ending
							local started = players[i].buffs.specialInformation.deepFissure.started
							local remaining = ending - timeStamp
							if players[i].buffs.specialInformation.deepFissure.waveTwo == false then
								remaining = remaining + 6
							end
							if remaining > 8 then
								remaining = 8
							end
							local item = timer.shalks[currentShalks]
							local percent = remaining / 8 * 100 --8secs, not 100% (6/3)
							if percent < 0 then
								percent = 0
							end
							local location = width / 100 * percent
							item:ClearAnchors()
							item:SetAnchor(TOPLEFT, timer, TOPLEFT, location + 2, 2)
							item:SetHidden(false)
							currentShalks = currentShalks + 1
							borderVisible = true
						end
						for j = currentShalks, 12 do
							timer.shalks[j]:SetHidden(true)
						end
						--soul of flame
						if players[i].buffs.specialInformation.soulOfFlame ~= nil and players[i].buffs.specialInformation.soulOfFlame.active == true then
							--4 secs
							local ending = players[i].buffs.specialInformation.soulOfFlame.ending
							local started = players[i].buffs.specialInformation.soulOfFlame.started
							local remaining = ending - timeStamp
							
							if remaining > 8 then
								remaining = 8
							end
							local item = timer.souls[currentSouls]
							local percent = remaining / 8 * 100 --8secs, not 100% (4)
							if percent < 0 then
								percent = 0
							end
							local location = width / 100 * percent
							item:ClearAnchors()
							item:SetAnchor(TOPLEFT, timer, TOPLEFT, location + 2, 2)
							item:SetHidden(false)
							currentSouls = currentSouls + 1
							borderVisible = true
						end
						for j = currentSouls, 12 do
							timer.souls[j]:SetHidden(true)
						end
					end
					
				end
			end
			timer.edge:SetHidden(not borderVisible)
		end
	end
end


--menu interactions
function RdKGToolPt.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.PT_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.PT_ENABLED,
					getFunc = RdKGToolPt.GetPtEnabled,
					setFunc = RdKGToolPt.SetPtEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.PT_POSITION_FIXED,
					getFunc = RdKGToolPt.GetPtPositionLocked,
					setFunc = RdKGToolPt.SetPtPositionLocked
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.PT_PVP_ONLY,
					getFunc = RdKGToolPt.GetPtPvpOnly,
					setFunc = RdKGToolPt.SetPtPvpOnly
				},
				[4] = {
					type = "divider",
					width = "full"
				},
				[5] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.PT_TIMER_ENABLED,
					getFunc = RdKGToolPt.GetPtTimerEnabled,
					setFunc = RdKGToolPt.SetPtTimerEnabled
				},
				[6] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.PT_TIMER_TEXT_ENABLED,
					getFunc = RdKGToolPt.GetPtTimerTextEnabled,
					setFunc = RdKGToolPt.SetPtTimerTextEnabled
				},
				[7] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.PT_TIMER_SHOW_ALL_ENABLED,
					getFunc = RdKGToolPt.GetPtTimerShowAllEnabled,
					setFunc = RdKGToolPt.SetPtTimerShowAllEnabled
				},				
				[8] = {
					type = "slider",
					name = RdKGToolMenu.constants.PT_SIZE,
					min = 1.0,
					max = 2.0,
					step = 0.01,
					getFunc = RdKGToolPt.GetPtSelectedSize,
					setFunc = RdKGToolPt.SetPtSelectedSize,
					width = "full",
					decimals = 2,
					default = 1.0
				},
				[9] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PT_FONT_COLOR,
					getFunc = RdKGToolPt.GetPtFontColor,
					setFunc = RdKGToolPt.SetPtFontColor,
					width = "full"
				},
				[10] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PT_LEAD_COLOR,
					getFunc = RdKGToolPt.GetPtLeadColor,
					setFunc = RdKGToolPt.SetPtLeadColor,
					width = "full"
				},
				[11] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PT_LEAD_LINE_COLOR,
					getFunc = RdKGToolPt.GetPtLeadLineColor,
					setFunc = RdKGToolPt.SetPtLeadLineColor,
					width = "full"
				},
				[12] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PT_SHALK_COLOR,
					getFunc = RdKGToolPt.GetPtShalkColor,
					setFunc = RdKGToolPt.SetPtShalkColor,
					width = "full"
				},
				[13] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PT_DETO_COLOR,
					getFunc = RdKGToolPt.GetPtDetoColor,
					setFunc = RdKGToolPt.SetPtDetoColor,
					width = "full"
				},
				[14] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PT_SOUL_COLOR,
					getFunc = RdKGToolPt.GetPtSoulColor,
					setFunc = RdKGToolPt.SetPtSoulColor,
					width = "full"
				},
				[15] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.PT_SMOOTH_TRANSITION,
					getFunc = RdKGToolPt.GetPtSmoothTransition,
					setFunc = RdKGToolPt.SetPtSmoothTransition
				},
				[16] = {
					type = "divider",
					width = "full"
				},
				[17] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.PT_OVERVIEW_ENABLED,
					getFunc = RdKGToolPt.GetPtOverviewEnabled,
					setFunc = RdKGToolPt.SetPtOverviewEnabled
				},				
				[18] = {
					type = "slider",
					name = RdKGToolMenu.constants.PT_OVERVIEW_SIZE,
					min = 1.0,
					max = 2.0,
					step = 0.01,
					getFunc = RdKGToolPt.GetPtOverviewSize,
					setFunc = RdKGToolPt.SetPtOverviewSize,
					width = "full",
					decimals = 2,
					default = 1.0
				},
				[19] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PT_OVERVIEW_COLOR,
					getFunc = RdKGToolPt.GetPtOverviewColor,
					setFunc = RdKGToolPt.SetPtOverviewColor,
					width = "full"
				},
				[20] = {
					type = "divider",
					width = "full"
				},
				[21] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.PT_REACTION_ENABLED,
					getFunc = RdKGToolPt.GetPtReactionEnabled,
					setFunc = RdKGToolPt.SetPtReactionEnabled
				},				
				[22] = {
					type = "slider",
					name = RdKGToolMenu.constants.PT_REACTION_SIZE,
					min = 1.0,
					max = 2.0,
					step = 0.01,
					getFunc = RdKGToolPt.GetPtReactionSize,
					setFunc = RdKGToolPt.SetPtReactionSize,
					width = "full",
					decimals = 2,
					default = 1.0
				},
				[23] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.PT_REACTION_COLOR,
					getFunc = RdKGToolPt.GetPtReactionColor,
					setFunc = RdKGToolPt.SetPtReactionColor,
					width = "full"
				},
				[24] = {
					type = "editbox",
					name = RdKGToolMenu.constants.PT_REACTION_TEXT,
					getFunc = RdKGToolPt.GetPtReactionText,
					setFunc = RdKGToolPt.SetPtReactionText,
					isMultiline = false,
					width = "full",
					default = ""
				},				
				[25] = {
					type = "slider",
					name = RdKGToolMenu.constants.PT_REACTION_TIME,
					min = 0.0,
					max = 8.0,
					step = 0.01,
					getFunc = RdKGToolPt.GetPtReactionTime,
					setFunc = RdKGToolPt.SetPtReactionTime,
					width = "full",
					decimals = 2,
					default = 2.0
				}
				
			}
		},
	}
	return menu
end

function RdKGToolPt.GetPtEnabled()
	return RdKGToolPt.ptVars.enabled
end

function RdKGToolPt.SetPtEnabled(value)
	RdKGToolPt.SetEnabled(value)
end

function RdKGToolPt.GetPtPositionLocked()
	return RdKGToolPt.ptVars.positionLocked
end

function RdKGToolPt.SetPtPositionLocked(value)
	RdKGToolPt.SetPositionLocked(value)
end

function RdKGToolPt.GetPtPvpOnly()
	return RdKGToolPt.ptVars.pvpOnly
end

function RdKGToolPt.SetPtPvpOnly(value)
	RdKGToolPt.ptVars.pvpOnly = value
	RdKGToolPt.SetEnabled(RdKGToolPt.ptVars.enabled)
end

function RdKGToolPt.GetPtTimerEnabled()
	return RdKGToolPt.ptVars.timerEnabled
end

function RdKGToolPt.SetPtTimerEnabled(value)
	RdKGToolPt.ptVars.timerEnabled = value
	RdKGToolPt.SetEnabled(RdKGToolPt.ptVars.enabled)
end

function RdKGToolPt.GetPtTimerTextEnabled()
	return RdKGToolPt.ptVars.timerTextEnabled
end

function RdKGToolPt.SetPtTimerTextEnabled(value)
	RdKGToolPt.ptVars.timerTextEnabled = value
	RdKGToolPt.SetEnabled(RdKGToolPt.ptVars.enabled)
end

function RdKGToolPt.GetPtTimerShowAllEnabled()
	return RdKGToolPt.ptVars.timerShowAllEnabled
end

function RdKGToolPt.SetPtTimerShowAllEnabled(value)
	RdKGToolPt.ptVars.timerShowAllEnabled = value
	RdKGToolPt.SetEnabled(RdKGToolPt.ptVars.enabled)
end

function RdKGToolPt.GetPtSelectedSize()
	return RdKGToolPt.ptVars.size
end

function RdKGToolPt.SetPtSelectedSize(value)
	if value ~= nil and value >= RdKGToolPt.constants.size.SMALL and value <= RdKGToolPt.constants.size.BIG then
		RdKGToolPt.ptVars.size = value
		RdKGToolPt.AdjustSize()
	end
end

function RdKGToolPt.GetPtFontColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolPt.ptVars.fontColor)
end

function RdKGToolPt.SetPtFontColor(r, g, b)
	RdKGToolPt.ptVars.fontColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPt.AdjustColors()
end

function RdKGToolPt.GetPtLeadColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolPt.ptVars.leadColor)
end

function RdKGToolPt.SetPtLeadColor(r, g, b)
	RdKGToolPt.ptVars.leadColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPt.AdjustColors()
end

function RdKGToolPt.GetPtLeadLineColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolPt.ptVars.leadLineColor)
end

function RdKGToolPt.SetPtLeadLineColor(r, g, b)
	RdKGToolPt.ptVars.leadLineColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPt.AdjustColors()
end

function RdKGToolPt.GetPtShalkColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolPt.ptVars.shalkColor)
end

function RdKGToolPt.SetPtShalkColor(r, g, b)
	RdKGToolPt.ptVars.shalkColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPt.AdjustColors()
end

function RdKGToolPt.GetPtDetoColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolPt.ptVars.detoColor)
end

function RdKGToolPt.SetPtDetoColor(r, g, b)
	RdKGToolPt.ptVars.detoColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPt.AdjustColors()
end

function RdKGToolPt.GetPtSoulColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolPt.ptVars.soulColor)
end

function RdKGToolPt.SetPtSoulColor(r, g, b)
	RdKGToolPt.ptVars.soulColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPt.AdjustColors()
end

function RdKGToolPt.GetPtSmoothTransition()
	return RdKGToolPt.ptVars.smoothTransition
end

function RdKGToolPt.SetPtSmoothTransition(value)
	RdKGToolPt.ptVars.smoothTransition = value
end

function RdKGToolPt.GetPtOverviewEnabled()
	return RdKGToolPt.ptVars.overviewEnabled
end

function RdKGToolPt.SetPtOverviewEnabled(value)
	RdKGToolPt.ptVars.overviewEnabled = value
	RdKGToolPt.SetEnabled(RdKGToolPt.ptVars.enabled)
end

function RdKGToolPt.GetPtOverviewSize()
	return RdKGToolPt.ptVars.overviewSize
end

function RdKGToolPt.SetPtOverviewSize(value)
	if value ~= nil and value >= RdKGToolPt.constants.size.SMALL and value <= RdKGToolPt.constants.size.BIG then
		RdKGToolPt.ptVars.overviewSize = value
		RdKGToolPt.AdjustSize()
	end
end

function RdKGToolPt.GetPtOverviewColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolPt.ptVars.overviewFontColor)
end

function RdKGToolPt.SetPtOverviewColor(r, g, b)
	RdKGToolPt.ptVars.overviewFontColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPt.AdjustColors()
end

function RdKGToolPt.GetPtReactionEnabled()
	return RdKGToolPt.ptVars.reactionEnabled
end

function RdKGToolPt.SetPtReactionEnabled(value)
	RdKGToolPt.ptVars.reactionEnabled = value
	RdKGToolPt.SetEnabled(RdKGToolPt.ptVars.enabled)
end

function RdKGToolPt.GetPtReactionSize()
	return RdKGToolPt.ptVars.reactionSize
end

function RdKGToolPt.SetPtReactionSize(value)
	if value ~= nil and value >= RdKGToolPt.constants.size.SMALL and value <= RdKGToolPt.constants.size.BIG then
		RdKGToolPt.ptVars.reactionSize = value
		RdKGToolPt.AdjustSize()
	end
end

function RdKGToolPt.GetPtReactionColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolPt.ptVars.reactionFontColor)
end

function RdKGToolPt.SetPtReactionColor(r, g, b)
	RdKGToolPt.ptVars.reactionFontColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolPt.AdjustColors()
end

function RdKGToolPt.GetPtReactionText()
	return RdKGToolPt.ptVars.reactionText
end

function RdKGToolPt.SetPtReactionText(value)
	RdKGToolPt.ptVars.reactionText = value
end

function RdKGToolPt.GetPtReactionTime()
	return RdKGToolPt.ptVars.reactionTime
end

function RdKGToolPt.SetPtReactionTime(value)
	if value ~= nil and value >= RdKGToolPt.constants.time.MIN and value <= RdKGToolPt.constants.time.MAX then
		RdKGToolPt.ptVars.reactionTime = value
		RdKGToolPt.AdjustSize()
	end
end