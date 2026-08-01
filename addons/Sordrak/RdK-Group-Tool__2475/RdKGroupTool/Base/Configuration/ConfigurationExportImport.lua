-- RdK Group Tool Configuration Export Import
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.cfg = RdKGTool.cfg or {}
local RdKGToolConfig = RdKGTool.cfg
RdKGTool.profile = RdKGTool.profile or {}
local RdKGToolProfile = RdKGTool.profile
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem

RdKGToolConfig.constants = RdKGToolConfig.constants or {}
RdKGToolConfig.constants.TLW_CONFIG_WINDOW = "RdKGTool.cfg.config_TLW"
RdKGToolConfig.constants.HEADER_BACKDROP_NAME = "RdKGTool.cfg.config_TLW_Header_Backdrop"
RdKGToolConfig.constants.BODY_BACKDROP_NAME = "RdKGTool.cfg.config_TLW_Body_Backdrop"
RdKGToolConfig.constants.EXPORT_DROPDOWN = "RdKGTool.cfg.config_TLW_Export_Dropdown"
RdKGToolConfig.constants.IMPORT_CHECKBOX_ADD_ALL = "RdKGTool.cfg.config_TLW_Import_Add_All"

RdKGToolConfig.constants.TAB_EXPORT = 1
RdKGToolConfig.constants.TAB_IMPORT = 2

RdKGToolConfig.constants.syntax = {}
RdKGToolConfig.constants.syntax.LAYER_1_START = "["
RdKGToolConfig.constants.syntax.LAYER_1_END = "]"
RdKGToolConfig.constants.syntax.LAYER_2_START = "{"
RdKGToolConfig.constants.syntax.LAYER_2_END = "}"
RdKGToolConfig.constants.syntax.LAYER_X_START = "("
RdKGToolConfig.constants.syntax.LAYER_X_END = ")"
RdKGToolConfig.constants.syntax.LAYER_X_SEPERATOR = "."
RdKGToolConfig.constants.syntax.types = {}
RdKGToolConfig.constants.syntax.types.NUMBER = "n"
RdKGToolConfig.constants.syntax.types.BOOLEAN = "b"
RdKGToolConfig.constants.syntax.types.STRING = "s"
RdKGToolConfig.constants.syntax.identifiers = {}
RdKGToolConfig.constants.syntax.identifiers.VERSION = "Version"

RdKGToolConfig.constants.PREFIX = "CFG"

RdKGToolConfig.callbackName = RdKGTool.addonName .. "Config"

RdKGToolConfig.controls = {}

RdKGToolConfig.config = {}
RdKGToolConfig.config.width = 800
RdKGToolConfig.config.height = 600
RdKGToolConfig.config.headerHeight = 33
RdKGToolConfig.config.headerOffset = 3
RdKGToolConfig.config.isMovable = true
RdKGToolConfig.config.isMouseEnabled = true
RdKGToolConfig.config.isClampedToScreen = true
RdKGToolConfig.config.headerFont = "$(BOLD_FONT)|$(KB_20)soft-shadow-thick"
RdKGToolConfig.config.color = {}
RdKGToolConfig.config.color.default = {}
RdKGToolConfig.config.color.default.r = 0.85
RdKGToolConfig.config.color.default.g = 0.83
RdKGToolConfig.config.color.default.b = 0.7
RdKGToolConfig.config.color.backdrop = {}
RdKGToolConfig.config.color.backdrop.r = 0.0
RdKGToolConfig.config.color.backdrop.g = 0.0
RdKGToolConfig.config.color.backdrop.b = 0.0
RdKGToolConfig.config.color.backdrop.a = 0.7
RdKGToolConfig.config.color.backdropEdge = {}
RdKGToolConfig.config.color.backdropEdge.r = 1.0
RdKGToolConfig.config.color.backdropEdge.g = 1.0
RdKGToolConfig.config.color.backdropEdge.b = 1.0
RdKGToolConfig.config.color.backdropEdge.a = 0.7
RdKGToolConfig.config.color.tabSelected = {}
RdKGToolConfig.config.color.tabSelected.r = 0.5
RdKGToolConfig.config.color.tabSelected.g = 0.5
RdKGToolConfig.config.color.tabSelected.b = 0.5
RdKGToolConfig.config.color.tabSelected.a = 0.7
RdKGToolConfig.config.color.tabNotSelected = {}
RdKGToolConfig.config.color.tabNotSelected.r = 0.3
RdKGToolConfig.config.color.tabNotSelected.g = 0.3
RdKGToolConfig.config.color.tabNotSelected.b = 0.3
RdKGToolConfig.config.color.tabNotSelected.a = 0.7
RdKGToolConfig.config.color.tabMouseOver = {}
RdKGToolConfig.config.color.tabMouseOver.r = 0.2
RdKGToolConfig.config.color.tabMouseOver.g = 0.6
RdKGToolConfig.config.color.tabMouseOver.b = 0.8
RdKGToolConfig.config.color.tabMouseOver.a = 0.7
RdKGToolConfig.config.color.edgeColor = {}
RdKGToolConfig.config.color.edgeColor.r = 0.8
RdKGToolConfig.config.color.edgeColor.g = 0.8
RdKGToolConfig.config.color.edgeColor.b = 0.8
RdKGToolConfig.config.color.edgeColor.a = 0.7
RdKGToolConfig.config.tabHeight = 50
RdKGToolConfig.config.tabOffset = 8
RdKGToolConfig.config.controlHeight = RdKGToolConfig.config.height - RdKGToolConfig.config.tabHeight - RdKGToolConfig.config.tabOffset
RdKGToolConfig.config.tabWidth = 200
RdKGToolConfig.config.controlOffset = 2
RdKGToolConfig.config.controlWidth = RdKGToolConfig.config.width - RdKGToolConfig.config.controlOffset * 2

RdKGToolConfig.state = {}
RdKGToolConfig.state.initialized = false
RdKGToolConfig.state.selectedTab = RdKGToolConfig.constants.TAB_EXPORT
RdKGToolConfig.state.selectedExportProfile = ""

local wm = WINDOW_MANAGER

function RdKGToolConfig.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolConfig.callbackName, RdKGToolConfig.OnProfileChanged)
	ZO_CreateStringId("SI_BINDING_NAME_RDKGTOOL_CONFIG_OPEN", RdKGToolConfig.constants.TOGGLE_CONFIG)
	
	RdKGToolConfig.CreateUI()
	
	RdKGToolConfig.state.initialized = true
end

function RdKGToolConfig.GetDefaults()
	local defaults = {}
	return defaults
end

function RdKGToolConfig.CreateUI()
	--TLW
	RdKGToolConfig.controls.TLW = wm:CreateTopLevelWindow(RdKGToolConfig.constants.TLW_ADMIN_WINDOW)
	
	RdKGToolConfig.controls.TLW:SetDimensions(RdKGToolConfig.config.width, RdKGToolConfig.config.headerHeight)
	RdKGToolConfig.SetTlwLocation()
	
	RdKGToolConfig.controls.TLW:SetMovable(RdKGToolConfig.config.isMovable)
	RdKGToolConfig.controls.TLW:SetMouseEnabled(RdKGToolConfig.config.isMouseEnabled)
	
	RdKGToolConfig.controls.TLW:SetClampedToScreen(RdKGToolConfig.config.isClampedToScreen)
	RdKGToolConfig.controls.TLW:SetHandler("OnMoveStop", RdKGToolConfig.SaveWindowLocation)
	RdKGToolConfig.controls.TLW:SetHidden(true)
	
	--Header
	RdKGToolConfig.controls.TLW.header= wm:CreateControl(nil, RdKGToolConfig.controls.TLW, CT_CONTROL)
	RdKGToolConfig.controls.TLW.header:SetDimensions(RdKGToolConfig.config.width, RdKGToolConfig.config.headerHeight)
	RdKGToolConfig.controls.TLW.header:SetAnchor(TOPLEFT, RdKGToolConfig.controls.TLW, TOPLEFT, 0, 0)
	
	
	RdKGToolConfig.controls.TLW.header.label = wm:CreateControl(nil, RdKGToolConfig.controls.TLW.header, CT_LABEL)
	RdKGToolConfig.controls.TLW.header.label:SetAnchor(TOP, RdKGToolConfig.controls.TLW.header, TOP ,0 , 3)
	RdKGToolConfig.controls.TLW.header.label:SetFont(RdKGToolConfig.config.headerFont)
	RdKGToolConfig.controls.TLW.header.label:SetWrapMode(ELLIPSIS)
	RdKGToolConfig.controls.TLW.header.label:SetColor(RdKGToolConfig.config.color.default.r, RdKGToolConfig.config.color.default.g, RdKGToolConfig.config.color.default.b)
	RdKGToolConfig.controls.TLW.header.label:SetText(RdKGToolConfig.constants.HEADER_TITLE)
		
		
	RdKGToolConfig.controls.TLW.header.backdrop = CreateControlFromVirtual(RdKGToolConfig.constants.HEADER_BACKDROP_NAME, RdKGToolConfig.controls.TLW.header, "ZO_SliderBackdrop")
	RdKGToolConfig.controls.TLW.header.backdrop:SetCenterColor(RdKGToolConfig.config.color.backdrop.r, RdKGToolConfig.config.color.backdrop.g, RdKGToolConfig.config.color.backdrop.b, RdKGToolConfig.config.color.backdrop.a)
	RdKGToolConfig.controls.TLW.header.backdrop:SetEdgeColor(RdKGToolConfig.config.color.backdropEdge.r, RdKGToolConfig.config.color.backdropEdge.g, RdKGToolConfig.config.color.backdropEdge.b, RdKGToolConfig.config.color.backdropEdge.a)
		
	RdKGToolConfig.controls.TLW.header.button = wm:CreateControl(nil, RdKGToolConfig.controls.TLW.header, CT_BUTTON)
	RdKGToolConfig.controls.TLW.header.button:SetAnchor(TOPRIGHT, RdKGToolConfig.controls.TLW.header, TOPRIGHT, -3, 7)
	RdKGToolConfig.controls.TLW.header.button:SetDimensions(20, 20)
	RdKGToolConfig.controls.TLW.header.button:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
	RdKGToolConfig.controls.TLW.header.button:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
	RdKGToolConfig.controls.TLW.header.button:SetHandler("OnClicked", RdKGToolConfig.CloseWindow)
	
	--Body	
	RdKGToolConfig.controls.TLW.body = wm:CreateControl(nil, RdKGToolConfig.controls.TLW, CT_CONTROL)
	RdKGToolConfig.controls.TLW.body:SetDimensions(RdKGToolConfig.config.width, RdKGToolConfig.config.height)
	RdKGToolConfig.controls.TLW.body:SetAnchor(TOPLEFT, RdKGToolConfig.controls.TLW, TOPLEFT, 0, RdKGToolConfig.config.headerOffset + RdKGToolConfig.config.headerHeight)
	
	RdKGToolConfig.controls.TLW.body.backdrop = CreateControlFromVirtual(RdKGToolConfig.constants.BODY_BACKDROP_NAME, RdKGToolConfig.controls.TLW.body, "ZO_SliderBackdrop")
	RdKGToolConfig.controls.TLW.body.backdrop:SetCenterColor(RdKGToolConfig.config.color.backdrop.r, RdKGToolConfig.config.color.backdrop.g, RdKGToolConfig.config.color.backdrop.b, RdKGToolConfig.config.color.backdrop.a)
	RdKGToolConfig.controls.TLW.body.backdrop:SetEdgeColor(RdKGToolConfig.config.color.backdropEdge.r, RdKGToolConfig.config.color.backdropEdge.g, RdKGToolConfig.config.color.backdropEdge.b, RdKGToolConfig.config.color.backdropEdge.a)
	
	--Body Tabs
	RdKGToolConfig.controls.TLW.body.tabControl = wm:CreateControl(nil, RdKGToolConfig.controls.TLW.body, CT_CONTROL)
	RdKGToolConfig.controls.TLW.body.tabControl:SetDimensions(RdKGToolConfig.config.width, RdKGToolConfig.config.tabHeight - RdKGToolConfig.config.tabOffset)
	RdKGToolConfig.controls.TLW.body.tabControl:SetAnchor(TOPLEFT, RdKGToolConfig.controls.TLW.body, TOPLEFT, 0, RdKGToolConfig.config.tabOffset)
	
	RdKGToolConfig.controls.TLW.body.tabControl.exportTab = RdKGToolConfig.CreateTabControl(RdKGToolConfig.controls.TLW.body.tabControl, RdKGToolConfig.config.controlOffset * 2, RdKGToolConfig.constants.TAB_EXPORT,RdKGToolConfig.constants.TAB_EXPORT_TITLE)
	RdKGToolConfig.controls.TLW.body.tabControl.importTab = RdKGToolConfig.CreateTabControl(RdKGToolConfig.controls.TLW.body.tabControl, RdKGToolConfig.config.controlOffset * 2 + RdKGToolConfig.config.tabWidth, RdKGToolConfig.constants.TAB_IMPORT, RdKGToolConfig.constants.TAB_IMPORT_TITLE)
	
	--Body Control
	RdKGToolConfig.controls.TLW.body.rootControl = wm:CreateControl(nil, RdKGToolConfig.controls.TLW.body, CT_CONTROL)
	RdKGToolConfig.controls.TLW.body.rootControl:SetDimensions(RdKGToolConfig.config.controlWidth, RdKGToolConfig.config.controlHeight)
	RdKGToolConfig.controls.TLW.body.rootControl:SetAnchor(TOPLEFT, RdKGToolConfig.controls.TLW.body, TOPLEFT, RdKGToolConfig.config.controlOffset, RdKGToolConfig.config.tabHeight + RdKGToolConfig.config.tabOffset - 2)
	
	RdKGToolConfig.controls.TLW.body.edge = wm:CreateControl(nil, RdKGToolConfig.controls.TLW.body.rootControl, CT_BACKDROP)
	RdKGToolConfig.controls.TLW.body.edge:SetAnchor(TOPLEFT, RdKGToolConfig.controls.TLW.body.rootControl, TOPLEFT, 0, 0)
	RdKGToolConfig.controls.TLW.body.edge:SetDimensions(RdKGToolConfig.config.controlWidth, RdKGToolConfig.config.controlHeight)
	RdKGToolConfig.controls.TLW.body.edge:SetEdgeTexture(nil, 1, 1, 2, 0)
	RdKGToolConfig.controls.TLW.body.edge:SetCenterColor(0, 0, 0, 0)
	RdKGToolConfig.controls.TLW.body.edge:SetEdgeColor(RdKGToolConfig.config.color.edgeColor.r, RdKGToolConfig.config.color.edgeColor.g, RdKGToolConfig.config.color.edgeColor.b, RdKGToolConfig.config.color.edgeColor.a)
	
	
	--Export Control
	RdKGToolConfig.controls.TLW.body.rootControl.exportControl = RdKGToolConfig.CreateExportControl(RdKGToolConfig.controls.TLW.body.rootControl)
	
	--Import Control
	RdKGToolConfig.controls.TLW.body.rootControl.importControl = RdKGToolConfig.CreateImportControl(RdKGToolConfig.controls.TLW.body.rootControl)
	
	RdKGToolConfig.TabSelected(RdKGToolConfig.constants.TAB_EXPORT)
end

function RdKGToolConfig.CreateTabControl(rootControl, offset, index, title)
	local control = wm:CreateControl(nil, rootControl, CT_CONTROL)
	control:SetDimensions(RdKGToolConfig.config.tabWidth, RdKGToolConfig.config.tabHeight)
	control:SetAnchor(TOPLEFT, rootControl, TOPLEFT, offset, 0)
	
	--control.backdrop2 = CreateControlFromVirtual(backdropName, control, "ZO_SliderBackdrop")
	--control.backdrop2:SetCenterColor(RdKGToolConfig.config.color.backdrop.r, RdKGToolConfig.config.color.backdrop.g, RdKGToolConfig.config.color.backdrop.b, RdKGToolConfig.config.color.backdrop.a)
	--control.backdrop2:SetEdgeColor(RdKGToolConfig.config.color.backdropEdge.r, RdKGToolConfig.config.color.backdropEdge.g, RdKGToolConfig.config.color.backdropEdge.b, RdKGToolConfig.config.color.backdropEdge.a)
	
	control.backdrop = wm:CreateControl(nil, control, CT_BACKDROP)
	control.backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.backdrop:SetDimensions(RdKGToolConfig.config.tabWidth, RdKGToolConfig.config.tabHeight)
	--control.backdrop:SetDrawTier(0)
	control.backdrop:SetCenterColor(RdKGToolConfig.config.color.tabNotSelected.r, RdKGToolConfig.config.color.tabNotSelected.g, RdKGToolConfig.config.color.tabNotSelected.b, RdKGToolConfig.config.color.tabNotSelected.a)
	control.backdrop:SetEdgeColor(0,0,0,0)
	
	control.edge = wm:CreateControl(nil, control, CT_BACKDROP)
	control.edge:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.edge:SetDimensions(RdKGToolConfig.config.tabWidth, RdKGToolConfig.config.tabHeight)
	control.edge:SetEdgeTexture(nil, 1, 1, 2, 0)
	control.edge:SetCenterColor(0, 0, 0, 0)
	control.edge:SetEdgeColor(RdKGToolConfig.config.color.edgeColor.r, RdKGToolConfig.config.color.edgeColor.g, RdKGToolConfig.config.color.edgeColor.b, RdKGToolConfig.config.color.edgeColor.a)
	
	control.label = wm:CreateControl(nil, control, CT_LABEL)
	control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.label:SetFont(RdKGToolConfig.config.headerFont)
	control.label:SetWrapMode(ELLIPSIS)
	control.label:SetColor(RdKGToolConfig.config.color.default.r, RdKGToolConfig.config.color.default.g, RdKGToolConfig.config.color.default.b)
	control.label:SetText(title)
	control.label:SetDimensions(RdKGToolConfig.config.tabWidth, RdKGToolConfig.config.tabHeight)
	control.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	control.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	
	control.button = wm:CreateControl(nil, control, CT_BUTTON)
	local button = control.button
	button:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	button:SetDimensions(RdKGToolConfig.config.tabWidth, RdKGToolConfig.config.tabHeight)
	--button:SetNormalTexture("/esoui/art/actionbar/abilityframe64_up.dds")
	--button:SetPressedTexture("/esoui/art/actionbar/abilityframe64_down.dds")
	--button:SetMouseOverTexture("EsoUI/Art/ActionBar/actionBar_mouseOver.dds")
	button:SetHandler("OnClicked", function () RdKGToolConfig.TabSelected(index) end)
	button:SetHandler("OnMouseEnter", function() RdKGToolConfig.TabOnMouseEnter(index) end)
	button:SetHandler("OnMouseExit", function() RdKGToolConfig.TabOnMouseExit(index) end)
	--button:SetDrawTier(1)
	
	
	return control
end

function RdKGToolConfig.CreateExportControl(rootControl)
	local control = wm:CreateControl(nil, rootControl, CT_CONTROL)
	control:SetDimensions(RdKGToolConfig.config.controlWidth, RdKGToolConfig.config.controlHeight)
	control:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	
	control.profileLabel = wm:CreateControl(nil, control, CT_LABEL)
	control.profileLabel:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolConfig.config.controlOffset, 10)
	control.profileLabel:SetFont(RdKGToolConfig.config.headerFont)
	control.profileLabel:SetWrapMode(ELLIPSIS)
	control.profileLabel:SetColor(RdKGToolConfig.config.color.default.r, RdKGToolConfig.config.color.default.g, RdKGToolConfig.config.color.default.b)
	control.profileLabel:SetText(RdKGToolConfig.constants.EXPORT_PROFILE)
	control.profileLabel:SetDimensions(100, 25)
	control.profileLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	control.profileLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	
	control.combobox = wm:CreateControlFromVirtual(RdKGToolConfig.constants.EXPORT_DROPDOWN, control, "ZO_ScrollableComboBox")
	control.combobox:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolConfig.config.controlOffset + 100, 10)
	control.combobox:SetDimensions(325, 25)
	control.dropdown = ZO_ComboBox_ObjectFromContainer(control.combobox)
	
	control.config = RdKGToolConfig.CreateEditControl(control, RdKGToolConfig.config.controlWidth - RdKGToolConfig.config.controlOffset * 2, RdKGToolConfig.config.controlHeight - 40 - RdKGToolConfig.config.controlOffset * 3, 100000, true)
	control.config:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolConfig.config.controlOffset, 40)

	control.selectAllButton = CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
	control.selectAllButton:SetAnchor(TOPLEFT, control, TOPLEFT, 450, 10)
	control.selectAllButton:SetDimensions(175, 25)
	control.selectAllButton:SetText(RdKGToolConfig.constants.EXPORT_SELECT_ALL)
	control.selectAllButton:SetClickSound("Click")
	control.selectAllButton:SetHandler("OnClicked", RdKGToolConfig.SelectAllExportText)
	
	
	
	RdKGToolConfig.CreateExportDropdownEntries(control.dropdown)
	
	return control
end

function RdKGToolConfig.CreateImportControl(rootControl)
	local control = wm:CreateControl(nil, rootControl, CT_CONTROL)
	control:SetDimensions(RdKGToolConfig.config.controlWidth, RdKGToolConfig.config.controlHeight)
	control:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	
	control.profileLabel = wm:CreateControl(nil, control, CT_LABEL)
	control.profileLabel:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolConfig.config.controlOffset, 10)
	control.profileLabel:SetFont(RdKGToolConfig.config.headerFont)
	control.profileLabel:SetWrapMode(ELLIPSIS)
	control.profileLabel:SetColor(RdKGToolConfig.config.color.default.r, RdKGToolConfig.config.color.default.g, RdKGToolConfig.config.color.default.b)
	control.profileLabel:SetText(RdKGToolConfig.constants.IMPORT_PROFILE)
	control.profileLabel:SetDimensions(180, 25)
	control.profileLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	control.profileLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	
	control.name = RdKGToolConfig.CreateEditControl(control, 250, 25, 100, false)
	control.name:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolConfig.config.controlOffset + 180, 10)
	
	control.config = RdKGToolConfig.CreateEditControl(control, RdKGToolConfig.config.controlWidth - RdKGToolConfig.config.controlOffset * 2, RdKGToolConfig.config.controlHeight - 40 - RdKGToolConfig.config.controlOffset * 3 - 25 * 2, 100000, true)
	control.config:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolConfig.config.controlOffset, 40)
	
	control.import = CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
	control.import:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolConfig.config.controlOffset + 250 + 180, 10)
	control.import:SetDimensions(175, 25)
	control.import:SetText(RdKGToolConfig.constants.IMPORT)
	control.import:SetClickSound("Click")
	control.import:SetHandler("OnClicked", RdKGToolConfig.Import)
	
	control.chkAddAllValues = CreateControlFromVirtual(RdKGToolConfig.constants.IMPORT_CHECKBOX_ADD_ALL, control, "ZO_CheckButton")
	control.chkAddAllValues:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolConfig.config.controlOffset, RdKGToolConfig.config.controlHeight - 40 - RdKGToolConfig.config.controlOffset * 4)
	--control.chkAddAllValues:SetDimensions(100, 25)
	ZO_CheckButton_SetChecked(control.chkAddAllValues)
	ZO_CheckButton_SetLabelText(control.chkAddAllValues, RdKGToolConfig.constants.IMPORT_ADD_ALL)
	ZO_CheckButton_SetLabelWidth(control.chkAddAllValues, 390)
	control.chkAddAllValues.label:SetFont(RdKGToolConfig.config.headerFont)
	
	control.statusDescriptionLabel = wm:CreateControl(nil, control, CT_LABEL)
	control.statusDescriptionLabel:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolConfig.config.controlOffset, RdKGToolConfig.config.controlHeight - 40 - RdKGToolConfig.config.controlOffset * 3 - 25 + 40)
	control.statusDescriptionLabel:SetFont(RdKGToolConfig.config.headerFont)
	control.statusDescriptionLabel:SetWrapMode(ELLIPSIS)
	control.statusDescriptionLabel:SetColor(RdKGToolConfig.config.color.default.r, RdKGToolConfig.config.color.default.g, RdKGToolConfig.config.color.default.b)
	control.statusDescriptionLabel:SetText(RdKGToolConfig.constants.IMPORT_STATUS)
	control.statusDescriptionLabel:SetDimensions(75, 25)
	control.statusDescriptionLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	control.statusDescriptionLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	
	control.statusLabel = wm:CreateControl(nil, control, CT_LABEL)
	control.statusLabel:SetAnchor(TOPLEFT, control, TOPLEFT, 110, RdKGToolConfig.config.controlHeight - 40 - RdKGToolConfig.config.controlOffset * 3 - 25 + 40)
	control.statusLabel:SetFont(RdKGToolConfig.config.headerFont)
	control.statusLabel:SetWrapMode(ELLIPSIS)
	control.statusLabel:SetColor(RdKGToolConfig.config.color.default.r, RdKGToolConfig.config.color.default.g, RdKGToolConfig.config.color.default.b)
	control.statusLabel:SetText()
	control.statusLabel:SetDimensions(RdKGToolConfig.config.controlWidth - RdKGToolConfig.config.controlOffset * 2 - 75, 25)
	control.statusLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	control.statusLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	
	return control
end

function RdKGToolConfig.CreateEditControl(rootControl, width, height, maxChars, isMultiLine)
	control = wm:CreateControl(nil, rootControl, CT_CONTROL)
	control:SetDimensions(width, height)
	control:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	
	control.bd = wm:CreateControlFromVirtual(nil, control, "ZO_EditBackdrop")
	if isMultiLine == true then
		control.editbox = wm:CreateControlFromVirtual(nil, control.bd, "ZO_DefaultEditMultiLineForBackdrop")
	else
		control.editbox = wm:CreateControlFromVirtual(nil, control.bd, "ZO_DefaultEditForBackdrop")
	end
	
	
	control.bd:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.bd:SetDimensions(width, height)
	
	control.editbox:SetMaxInputChars(maxChars)

	
	control.editbox:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.editbox:SetDimensions(width, height)

	
	control.edge = wm:CreateControl(nil, control, CT_BACKDROP)
	control.edge:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.edge:SetDimensions(width, height)
	control.edge:SetEdgeTexture(nil, 1, 1, 1, 0)
	control.edge:SetCenterColor(0, 0, 0, 0)
	control.edge:SetEdgeColor(RdKGToolConfig.config.color.edgeColor.r, RdKGToolConfig.config.color.edgeColor.g, RdKGToolConfig.config.color.edgeColor.b, RdKGToolConfig.config.color.edgeColor.a)
	
	return control
end

function RdKGToolConfig.SetTlwLocation()
	if RdKGToolConfig.configVars == nil or RdKGToolConfig.configVars.position == nil then
		RdKGToolConfig.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, 0, -RdKGToolConfig.config.height / 2)
	else
		RdKGToolConfig.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolConfig.configVars.position.x , RdKGToolConfig.configVars.position.y)
	end
end

function RdKGToolConfig.SlashCmd(param)
	if param ~= nil then
		if param[1] == "config" then
			RdKGToolConfig.ToggleConfigInterface()
		end
	end
end

function RdKGToolConfig.ToggleConfigInterface()
	RdKGToolConfig.controls.TLW:SetHidden(not RdKGToolConfig.controls.TLW:IsHidden())
	if RdKGToolConfig.controls.TLW:IsHidden() == false then
		
	else
		
	end
	SetGameCameraUIMode(not RdKGToolConfig.controls.TLW:IsHidden())
end

function RdKGToolConfig.UpdateExportControl()
	RdKGToolConfig.UpdateExportDropdownEntries()
	
end

function RdKGToolConfig.UpdateImportControl()

end

function RdKGToolConfig.UpdateExportDropdownEntries()
	RdKGToolConfig.CreateExportDropdownEntries(RdKGToolConfig.controls.TLW.body.rootControl.exportControl.dropdown)
end

function RdKGToolConfig.CreateExportDropdownEntries(dropdown)
	dropdown:SetSortsItems(false)
	dropdown:ClearItems()
	local profiles = RdKGToolProfile.GetAvailableProfiles()
	for i = 1, #profiles do
		if profiles[i] ~= nil then
			local entry = dropdown:CreateItemEntry(profiles[i], RdKGToolConfig.SelectedExportProfileChanged)
			dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
			if profiles[i] == RdKGToolConfig.state.selectedExportProfile then
				dropdown:SetSelected(i)
			end
		end
    end
end

function RdKGToolConfig.GetLayerXData(rootLayer, prefix)
	local layerData = {}
	local layerString = ""
	for key, value in pairs(rootLayer) do
		local kType = RdKGToolConfig.constants.syntax.types.STRING
		if type(key) == "number" then
			kType = RdKGToolConfig.constants.syntax.types.NUMBER
		end
		if type(value) == "table" then
			local keyType = "s:"
			if type(key) == "number" then
				keyType = "n:"
			end
			local newPrefix = prefix
			if newPrefix == nil then
				newPrefix = keyType .. key
			else
				newPrefix = newPrefix .. RdKGToolConfig.constants.syntax.LAYER_X_SEPERATOR .. keyType .. key
			end
			val = RdKGToolConfig.constants.syntax.LAYER_X_START .. newPrefix .. RdKGToolConfig.constants.syntax.LAYER_X_END .. "\r\n"
			val = val .. RdKGToolConfig.GetLayerXData(value, newPrefix)
			table.insert(layerData, val)
		elseif type(value) == "number" then
			val = kType .. ":" .. key .. ":" .. RdKGToolConfig.constants.syntax.types.NUMBER  .. ":" .. value .."\r\n"
			table.insert(layerData, 1, val)
		elseif type(value) == "boolean" then
			local bool = "true"
			if value == false then
				bool = "false"
			end
			val = kType .. ":" .. key .. ":".. RdKGToolConfig.constants.syntax.types.BOOLEAN .. ":" .. bool .."\r\n"
			table.insert(layerData, 1, val)
		elseif type(value) == "string" then
			val = kType .. ":" .. key .. ":".. RdKGToolConfig.constants.syntax.types.STRING .. ":" .. value .."\r\n"
			table.insert(layerData, 1, val)
		end
	end
	for i = 1, #layerData do
		layerString = layerString .. layerData[i]
	end
	return layerString
end

function RdKGToolConfig.SplitConfigLines(config)
	local configList = nil
	if config ~= nil and type(config) == "string" then
		configList = {}
		local startIndex = 1
		for i = 1, string.len(config) - 1 do
			local sequence = string.sub(config, i, i + 1)
			if sequence == "\r\n" then
				local entry = string.sub(config, startIndex, i - 1)
				if entry ~= nil and entry ~= "" then
					table.insert(configList, entry)
				end
				startIndex = i + 2
			end
		end
		if startIndex ~= string.len(config) then
			local entry = string.sub(config, startIndex, string.len(config))
			if entry ~= nil and entry ~= "" then
				table.insert(configList, entry)
			end
		end
	end
	return configList
end

function RdKGToolConfig.GetConfigList(config)
	local validConfig = false
	local configList = {}
	local version = nil
	local tempList = RdKGToolConfig.SplitConfigLines(config)
	if tempList ~= nil and #tempList > 0 then
		RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_LINE_COUNT, #tempList), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
		local currentLayer1 = nil
		local currentLayer2 = nil
		local currentLayerX = nil
		local workingLayer = nil
		for i = 1, #tempList do 
			if string.sub(tempList[i],1,1) == "#" then
				RdKGToolChat.SendChatMessage("Comment", RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
				local tmp = string.sub(tempList[i], 2, string.len(tempList[i]))
				local key, value = zo_strsplit(":",tmp)
				key = zo_strtrim(key)
				value = zo_strtrim(value)
				if key == RdKGToolConfig.constants.syntax.identifiers.VERSION then
					version = value
				end
			else
				RdKGToolChat.SendChatMessage("Entry Handling", RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
				local cType = ""
				local firstSymbol = string.sub(tempList[i], 1, 1)
				if firstSymbol == RdKGToolConfig.constants.syntax.LAYER_1_START then
					RdKGToolChat.SendChatMessage("Layer 1", RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
					currentLayer1 = string.sub(tempList[i], 2, string.len(tempList[i]) - 1)
					if currentLayer1 == nil or string.len(currentLayer1) == 0 then
						RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_1_INVALID), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
						return nil, version, false
					end
					cType, currentLayer1 = zo_strsplit(":", currentLayer1)
					if cType == nil or currentLayer1 == nil or cType == "" or currentLayer1 == "" then
						RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_1_INVALID), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
						return nil, version, false
					end
					if cType == "n" then
						currentLayer1 = tonumber(currentLayer1)
						if currentLayer1 == nil then
							RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_NUMBER), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
							return nil, version, false
						end
					end
					configList[currentLayer1] = configList[currentLayer1] or {}
					currentLayer2 = nil
					workingLayer = nil
				elseif firstSymbol == RdKGToolConfig.constants.syntax.LAYER_2_START then
					RdKGToolChat.SendChatMessage("Layer 2", RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
					currentLayer2 = string.sub(tempList[i], 2, string.len(tempList[i]) - 1)
					if currentLayer2 == nil or string.len(currentLayer2) == 0 then
						RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_2_INVALID), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
						return nil, version, false
					end
					cType, currentLayer2 = zo_strsplit(":", currentLayer2)
					if cType == nil or currentLayer2 == nil or cType == "" or currentLayer2 == "" then
						RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_2_INVALID), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
						return nil, version, false
					end
					if configList[currentLayer1] == nil then
						RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_1_INVALID), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
						return nil, version, false
					end
					if cType == "n" then
						currentLayer2 = tonumber(currentLayer2)
						if currentLayer2 == nil then
							RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_NUMBER), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
							return nil, version, false
						end
					end
					configList[currentLayer1][currentLayer2] = configList[currentLayer1][currentLayer2] or {}
					workingLayer = nil
				elseif firstSymbol == RdKGToolConfig.constants.syntax.LAYER_X_START then
					RdKGToolChat.SendChatMessage("Layer X", RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
					currentLayerX = string.sub(tempList[i], 2, string.len(tempList[i]) - 1)
					if currentLayerX == nil or string.len(currentLayerX) == 0 then
						RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_X_INVALID), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
						return nil, version, false
					end
					--d("1")
					if configList[currentLayer1] == nil or configList[currentLayer1][currentLayer2] == nil then
						RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_1_2_INVALID), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
						return nil, version, false
					end
					--d("2")
					local xLayers = {zo_strsplit(".", currentLayerX)}
					
					if xLayers == nil or #xLayers == 0 then
						RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_X_INVALID), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
						return nil, version, false
					end
					--d("3")
					local tempLayer = configList[currentLayer1][currentLayer2]
					for j = 1, #xLayers do
						local layer = nil
						cType, layer = zo_strsplit(":", xLayers[j])
						--d("---------")
						--d(cType)
						--d(layer)
						if cType == nil or layer == nil or cType == "" or layer == "" then
							RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_INVALID), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
							return nil, version, false
						end
						if cType == "n" then
							layer = tonumber(layer)
							if layer == nil then
								RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_NUMBER), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
								return nil, version, false
							end
						end
						tempLayer[layer] = tempLayer[layer] or {}
						tempLayer = tempLayer[layer]
					end
					--d("4")
					workingLayer = tempLayer
				else
					RdKGToolChat.SendChatMessage("Entry", RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
					if currentLayer1 == nil or currentLayer1 == "" or configList[currentLayer1] == nil then
						RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_LAYER_1_INVALID), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
						return nil, version, false
					end
					--d("1")
					local kType, key, vType, value = zo_strsplit(":", tempList[i])
					if kType == nil or key == nil or vType == nil --[[or value == nil]] then
						RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_NIL), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
						return nil, version, false
					end
					--d("2")
					if kType ~= RdKGToolConfig.constants.syntax.types.NUMBER and kType ~= RdKGToolConfig.constants.syntax.types.STRING then
						RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_INVALID), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
						return nil, version, false
					else
						if kType == RdKGToolConfig.constants.syntax.types.NUMBER then
							key = tonumber(key)
							if key == nil then
								RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_NUMBER), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
								return nil, version, false
							end
						end
					end
					--d("3")
					if vType ~= RdKGToolConfig.constants.syntax.types.NUMBER and vType ~= RdKGToolConfig.constants.syntax.types.STRING and vType ~= RdKGToolConfig.constants.syntax.types.BOOLEAN then
						RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_INVALID), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
						return nil, version, false
					else
						if vType == RdKGToolConfig.constants.syntax.types.NUMBER then
							value = tonumber(value)
							if value == nil then
								RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_NIL), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
								return nil, version, false
							end
						elseif vType == RdKGToolConfig.constants.syntax.types.BOOLEAN then
							if value == "true" then
								value = true
							elseif value == "false" then
								value = false
							else
								RdKGToolChat.SendChatMessage(string.format(RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON, i, RdKGToolConfig.constants.IMPORT_CONFIG_FAILED_REASON_TYPE_BOOLEAN), RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
								return nil, version, false
							end
						else
							if value == nil then
								value = ""
							end
						end
					end
					--d("4")
					if currentLayer2 == nil then
						configList[currentLayer1][key] = value
					else
						if workingLayer == nil then
							configList[currentLayer1][currentLayer2][key] = value
						else
							workingLayer[key] = value
						end
					end					
				end
			end
		end
		validConfig = true
	end
	return configList, version, validConfig
end

function RdKGToolConfig.UpdateProfile(target, origin, addValues)
	if target ~= nil and origin ~= nil and addValues ~= nil then
		for key, value in pairs(origin) do
			if target[key] == nil then
				if addValues == true then
					if type(origin[key]) == "table" then
						target[key] = {}
						RdKGToolConfig.UpdateProfile(target[key], origin[key], addValues)
					else
						target[key] = value
					end
				end
			else
				if type(origin[key]) == "table" then
					if type(target[key]) ~= "table" then
						target[key] = {}
					end
					RdKGToolConfig.UpdateProfile(target[key], origin[key], addValues)
				else
					if type(target[key]) == type(origin[key]) then
						target[key] = origin[key]
					end
				end
			end
			
		end
	end
end

--[[
function RdKGToolConfig.Test(configList, profile)
	local matches = 0
	local fails = 0
	if configList ~= nil and profile == nil or configList == nil and profile ~= nil then
		if configList == nil then
			d("emtpy configList")
		else
			d("emtpy profile")
		end
		return 0, 1
	end
	for key, value in pairs(profile) do
		if type(value) == "table" then
			local retM, retF = RdKGToolConfig.Test(configList[key], profile[key])
		else
			if configList[key] == profile[key] then
				matches = matches + 1
			else
				fails = fails + 1
				d(key)
			end
		end
	end
	
	return matches, fails
end
]]

--callbacks
function RdKGToolConfig.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolConfig.configVars = currentProfile.cfg
		if RdKGToolConfig.state.initialized == true then
			RdKGToolConfig.SetTlwLocation()
		end
	end
end

function RdKGToolConfig.SaveWindowLocation()
	RdKGToolConfig.configVars.position = RdKGToolConfig.configVars.position or {}
	RdKGToolConfig.configVars.position.x = RdKGToolConfig.controls.TLW:GetLeft()
	RdKGToolConfig.configVars.position.y = RdKGToolConfig.controls.TLW:GetTop()
end

function RdKGToolConfig.CloseWindow()
	RdKGToolConfig.controls.TLW:SetHidden(true)
	SetGameCameraUIMode(not RdKGToolConfig.controls.TLW:IsHidden())
end

function RdKGToolConfig.OnKeyBinding()
	RdKGToolConfig.ToggleConfigInterface()
end

function RdKGToolConfig.SelectedExportProfileChanged(control, text, choice)
	local profile = RdKGToolProfile.GetSpecificAccProfile(text)
	RdKGToolConfig.state.selectedExportProfile = text
	--d(text)
	local config = "" 
	if profile ~= nil then
		config = config .. "#".. RdKGToolConfig.constants.syntax.identifiers.VERSION .. ": " .. RdKGTool.versionString .. "\r\n"
		config = config .. "#Account: ".. GetDisplayName("player") .. "\r\n"
		config = config .. "#Profile: " .. text .. "\r\n"
		config = config .. "\r\n"
		
		--layer 1
		local layer1 = {}
		for key, value in pairs(profile) do
			if key ~= "name" then
				local kType = RdKGToolConfig.constants.syntax.types.STRING
				if type(key) == "number" then
					kType = RdKGToolConfig.constants.syntax.types.NUMBER
				end
				local val = ""
				if type(value) == "table" then
					local keyType = "s:"
					if type(key) == "number" then
						keyType = "n:"
					end
					val = RdKGToolConfig.constants.syntax.LAYER_1_START .. keyType .. key .. RdKGToolConfig.constants.syntax.LAYER_1_END .. "\r\n"
					local layer2 = {}
						
					for key2, value2 in pairs(value) do
						local kType2 = RdKGToolConfig.constants.syntax.types.STRING
						if type(key2) == "number" then
							kType2 = RdKGToolConfig.constants.syntax.types.NUMBER
						end
						local val2 = ""
						if type(value2) == "table" then
							local keyType2 = "s:"
							if type(key2) == "number" then
								keyType2 = "n:"
							end
							val2 = RdKGToolConfig.constants.syntax.LAYER_2_START .. keyType2 .. key2 .. RdKGToolConfig.constants.syntax.LAYER_2_END .. "\r\n"
							local layerX = RdKGToolConfig.GetLayerXData(value2)
							if layerX ~= nil then
								val2 = val2 .. layerX
							end
							table.insert(layer2, val2)
						elseif type(value2) == "number" then
							val2 = kType2 .. ":" .. key2 .. ":" .. RdKGToolConfig.constants.syntax.types.NUMBER .. ":" .. value2 .."\r\n"
							table.insert(layer2, 1, val2)
						elseif type(value2) == "boolean" then
							local bool = "true"
							if value2 == false then
								bool = "false"
							end
							val2 = kType2 .. ":" .. key2 .. ":" .. RdKGToolConfig.constants.syntax.types.BOOLEAN .. ":" .. bool .."\r\n"
							table.insert(layer2, 1, val2)
						elseif type(value2) == "string" then
							val2 = kType2 .. ":" .. key2 .. ":" .. RdKGToolConfig.constants.syntax.types.STRING .. ":" .. value2 .."\r\n"
							table.insert(layer2, 1, val2)
						end
						
						
					end
					for i = 1, #layer2 do
						val = val .. layer2[i]
					end
					table.insert(layer1, val)
				elseif type(value) == "number" then
					val = kType .. ":" .. key .. ":" .. RdKGToolConfig.constants.syntax.types.NUMBER .. ":" .. value .."\r\n"
					table.insert(layer1, 1, val)
				elseif type(value) == "boolean" then
					local bool = "true"
					if value == false then
						bool = "false"
					end
					val = kType .. ":" .. key .. ":" .. RdKGToolConfig.constants.syntax.types.BOOLEAN .. ":" .. bool .."\r\n"
					table.insert(layer1, 1, val)
				elseif type(value) == "string" then
					val = kType .. ":" .. key .. ":" .. RdKGToolConfig.constants.syntax.types.STRING .. ":" .. value .."\r\n"
					table.insert(layer1, 1, val)
				end
				
			end
		end
		
		for i = 1, #layer1 do
			config = config .. layer1[i]
		end
	end
	if string.len(config) > 29903 then
		RdKGToolChat.SendChatMessage(RdKGToolConfig.constants.EXPORT_STRING_LENGTH_ERROR, RdKGToolConfig.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
	end
	RdKGToolConfig.controls.TLW.body.rootControl.exportControl.config.editbox:SetText(config)
end

function RdKGToolConfig.TabSelected(index)
	local control = RdKGToolConfig.controls.TLW.body.tabControl.exportTab.backdrop
	local controlUnselected = RdKGToolConfig.controls.TLW.body.tabControl.importTab.backdrop
	RdKGToolConfig.state.selectedTab = RdKGToolConfig.constants.TAB_EXPORT
	if index == RdKGToolConfig.constants.TAB_IMPORT then
		control = RdKGToolConfig.controls.TLW.body.tabControl.importTab.backdrop
		controlUnselected = RdKGToolConfig.controls.TLW.body.tabControl.exportTab.backdrop
		RdKGToolConfig.state.selectedTab = RdKGToolConfig.constants.TAB_IMPORT
	end
	control:SetCenterColor(RdKGToolConfig.config.color.tabSelected.r, RdKGToolConfig.config.color.tabSelected.g, RdKGToolConfig.config.color.tabSelected.b, RdKGToolConfig.config.color.tabSelected.a)
	controlUnselected:SetCenterColor(RdKGToolConfig.config.color.tabNotSelected.r, RdKGToolConfig.config.color.tabNotSelected.g, RdKGToolConfig.config.color.tabNotSelected.b, RdKGToolConfig.config.color.tabNotSelected.a)

	if index == RdKGToolConfig.constants.TAB_IMPORT then
		RdKGToolConfig.controls.TLW.body.rootControl.exportControl:SetHidden(true)
		RdKGToolConfig.controls.TLW.body.rootControl.importControl:SetHidden(false)
		RdKGToolConfig.UpdateImportControl()
	else
		RdKGToolConfig.controls.TLW.body.rootControl.exportControl:SetHidden(false)
		RdKGToolConfig.controls.TLW.body.rootControl.importControl:SetHidden(true)
		RdKGToolConfig.UpdateExportControl()
	end
end

function RdKGToolConfig.TabOnMouseEnter(index)
	local control = RdKGToolConfig.controls.TLW.body.tabControl.exportTab.backdrop
	if index == RdKGToolConfig.constants.TAB_IMPORT then
		control = RdKGToolConfig.controls.TLW.body.tabControl.importTab.backdrop
	end
	control:SetCenterColor(RdKGToolConfig.config.color.tabMouseOver.r, RdKGToolConfig.config.color.tabMouseOver.g, RdKGToolConfig.config.color.tabMouseOver.b, RdKGToolConfig.config.color.tabMouseOver.a)
end

function RdKGToolConfig.TabOnMouseExit(index)
	local control = RdKGToolConfig.controls.TLW.body.tabControl.exportTab.backdrop
	if index == RdKGToolConfig.constants.TAB_IMPORT then
		control = RdKGToolConfig.controls.TLW.body.tabControl.importTab.backdrop
	end
	local color = RdKGToolConfig.config.color.tabSelected
	if index ~= RdKGToolConfig.state.selectedTab then
		color = RdKGToolConfig.config.color.tabNotSelected
	end
	control:SetCenterColor(color.r, color.g, color.b, color.a)
end

function RdKGToolConfig.SelectAllExportText()
	RdKGToolConfig.controls.TLW.body.rootControl.exportControl.config.editbox:SelectAll()
	RdKGToolConfig.controls.TLW.body.rootControl.exportControl.config.editbox:TakeFocus()
end

function RdKGToolConfig.Import()
	local statusLabel = RdKGToolConfig.controls.TLW.body.rootControl.importControl.statusLabel
	statusLabel:SetText(RdKGToolConfig.constants.IMPORT_STATUS_STARTED)
	local profileName = RdKGToolConfig.controls.TLW.body.rootControl.importControl.name.editbox:GetText()
	if profileName ~= nil then
		profileName = zo_strtrim(profileName)
	end
	if profileName == nil or profileName == "" then
		statusLabel:SetText(RdKGToolConfig.constants.IMPORT_STATUS_PROFILE_INVALID_NAME)
		return
	end
	if RdKGToolProfile.ProfileExists(profileName) == true then
		statusLabel:SetText(RdKGToolConfig.constants.IMPORT_STATUS_PROFILE_DUPLICATE)
		return
	end
	local config = RdKGToolConfig.controls.TLW.body.rootControl.importControl.config.editbox:GetText()
	if config ~= nil then
		config = zo_strtrim(config)
	end
	if config == nil or config == "" then
		statusLabel:SetText(RdKGToolConfig.constants.IMPORT_STATUS_NO_CONTENT)
		return
	end
	local configList, version, validConfig = RdKGToolConfig.GetConfigList(config)
	
	if validConfig == true then
		local localVersion = RdKGTool.versionString
		--d(version)
		--[[
		local m, f = RdKGToolConfig.Test(configList, RdKGToolProfile.GetSpecificAccProfile("Default"))
		d(m)
		d(f)
		m, f = RdKGToolConfig.Test(RdKGToolProfile.GetSpecificAccProfile("Default"), configList)
		d(m)
		d(f)
		]]
		
		local newProfile = RdKGTool.CreateCleanProfile()
		newProfile.name = profileName
		
		RdKGToolConfig.UpdateProfile(newProfile, configList, ZO_CheckButton_IsChecked(RdKGToolConfig.controls.TLW.body.rootControl.importControl.chkAddAllValues))
		
		RdKGToolProfile.AddNewProfileData(newProfile)
		if localVersion == version then
			statusLabel:SetText(RdKGToolConfig.constants.IMPORT_STATUS_FINISHED)
		else
			statusLabel:SetText(RdKGToolConfig.constants.IMPORT_STATUS_FINISHED_DIFFERENT_VERSION)
		end
	else
		statusLabel:SetText(RdKGToolConfig.constants.IMPORT_STATUS_FAILED)
	end
	
end

--menu
function RdKGToolConfig.GetMenu()
	local menu = nil
	return menu
end