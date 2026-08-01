-- RdK Group Tool Admin
-- By @s0rdrak (PC / EU)

RdKGTool.admin = RdKGTool.admin or {}
local RdKGToolAdmin = RdKGTool.admin
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts
RdKGToolUtil.roster = RdKGToolUtil.roster or {}
local RdKGToolRoster = RdKGToolUtil.roster
RdKGToolUtil.versioning = RdKGToolUtil.versioning or {}
local RdKGToolVersioning = RdKGToolUtil.versioning
RdKGToolUtil.networking = RdKGToolUtil.networking or {}
local RdKGToolNetworking = RdKGToolUtil.networking
RdKGToolUtil.equipment = RdKGToolUtil.equipment or {}
local RdKGToolEquip = RdKGToolUtil.equipment
RdKGToolUtil.cp = RdKGToolUtil.cp or {}
local RdKGToolCP = RdKGToolUtil.cp
RdKGToolUtil.sb = RdKGToolUtil.sb or {}
local RdKGToolSB = RdKGToolUtil.sb
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolGroup = RdKGToolUtil.group
RdKGToolUtil.math = RdKGToolUtil.math or {}
local RdKGToolMath = RdKGToolUtil.math
RdKGToolUtil.beams = RdKGToolUtil.beams or {}
local RdKGToolBeams = RdKGToolUtil.beams
RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolToolbox = RdKGTool.toolbox
RdKGToolToolbox.sp = RdKGToolToolbox.sp or {}
local RdKGToolSP = RdKGToolToolbox.sp


RdKGToolAdmin.constants = RdKGToolAdmin.constants or {}
RdKGToolAdmin.constants.TLW_ADMIN_WINDOW = "RdKGTool.admin.admin_TLW"
RdKGToolAdmin.constants.HEADER_BACKDROP_NAME = "RdKGTool.admin.admin_TLW_Header_Backdrop"
RdKGToolAdmin.constants.PLAYER_BACKDROP_NAME = "RdKGTool.admin.admin_TLW_Player_Backdrop"
RdKGToolAdmin.constants.CONFIG_BACKDROP_NAME = "RdKGTool.admin.admin_TLW_Config_Backdrop"
RdKGToolAdmin.constants.SCROLL_CONTROL = "RdKGTool.admin.admin_TLW_Config_ScrollBarControl"

RdKGToolAdmin.constants.requests = {}
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_CLIENT_CONFIGURATION = 1
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_ADDON_CONFIGURATION = 2
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_STATS_INFORMATION = 4
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_SKILLS_INFORMATION = 8
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_EQUIPMENT_INFORMATION = 16
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_CHAMPION_INFORMATION = 32
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_QUICKSLOT_INFORMATION = 64
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_PLACEHOLDER = 128

RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B3_PLACEHOLDER = 1
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B3_PLACEHOLDER = 2
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B3_PLACEHOLDER = 4
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B3_PLACEHOLDER = 8
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B3_PLACEHOLDER = 16
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B3_PLACEHOLDER = 32
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B3_PLACEHOLDER = 64
RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B3_PLACEHOLDER = 128

RdKGToolAdmin.constants.player = {}
RdKGToolAdmin.constants.config = {}
RdKGToolAdmin.constants.equipmentType = {}
RdKGToolAdmin.constants.equipmentType.ARMOR = 1
RdKGToolAdmin.constants.equipmentType.WEAPON = 2
RdKGToolAdmin.constants.equipmentType.ACCESSORIES = 3
RdKGToolAdmin.constants.equipment = {}
RdKGToolAdmin.constants.equipment[1] = {}
RdKGToolAdmin.constants.equipment[1].slotId = 0
RdKGToolAdmin.constants.equipment[1].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.HEAD
RdKGToolAdmin.constants.equipment[1].eType = RdKGToolAdmin.constants.equipmentType.ARMOR
RdKGToolAdmin.constants.equipment[1].texture = "esoui/art/characterwindow/gearslot_head.dds"
RdKGToolAdmin.constants.equipment[2] = {}
RdKGToolAdmin.constants.equipment[2].slotId = 3
RdKGToolAdmin.constants.equipment[2].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.SHOULDERS
RdKGToolAdmin.constants.equipment[2].eType = RdKGToolAdmin.constants.equipmentType.ARMOR
RdKGToolAdmin.constants.equipment[2].texture = "esoui/art/characterwindow/gearslot_shoulders.dds"
RdKGToolAdmin.constants.equipment[3] = {}
RdKGToolAdmin.constants.equipment[3].slotId = 2
RdKGToolAdmin.constants.equipment[3].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.CHEST
RdKGToolAdmin.constants.equipment[3].eType = RdKGToolAdmin.constants.equipmentType.ARMOR
RdKGToolAdmin.constants.equipment[3].texture = "esoui/art/characterwindow/gearslot_chest.dds"
RdKGToolAdmin.constants.equipment[4] = {}
RdKGToolAdmin.constants.equipment[4].slotId = 16
RdKGToolAdmin.constants.equipment[4].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.HANDS
RdKGToolAdmin.constants.equipment[4].eType = RdKGToolAdmin.constants.equipmentType.ARMOR
RdKGToolAdmin.constants.equipment[4].texture = "esoui/art/characterwindow/gearslot_hands.dds"
RdKGToolAdmin.constants.equipment[5] = {}
RdKGToolAdmin.constants.equipment[5].slotId = 6
RdKGToolAdmin.constants.equipment[5].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.WAIST
RdKGToolAdmin.constants.equipment[5].eType = RdKGToolAdmin.constants.equipmentType.ARMOR
RdKGToolAdmin.constants.equipment[5].texture = "esoui/art/characterwindow/gearslot_belt.dds"
RdKGToolAdmin.constants.equipment[6] = {}
RdKGToolAdmin.constants.equipment[6].slotId = 8
RdKGToolAdmin.constants.equipment[6].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.LEGS
RdKGToolAdmin.constants.equipment[6].eType = RdKGToolAdmin.constants.equipmentType.ARMOR
RdKGToolAdmin.constants.equipment[6].texture = "esoui/art/characterwindow/gearslot_legs.dds"
RdKGToolAdmin.constants.equipment[7] = {}
RdKGToolAdmin.constants.equipment[7].slotId = 9
RdKGToolAdmin.constants.equipment[7].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.FEET
RdKGToolAdmin.constants.equipment[7].eType = RdKGToolAdmin.constants.equipmentType.ARMOR
RdKGToolAdmin.constants.equipment[7].texture = "esoui/art/characterwindow/gearslot_feet.dds"
RdKGToolAdmin.constants.equipment[8] = {}
RdKGToolAdmin.constants.equipment[8].slotId = 1
RdKGToolAdmin.constants.equipment[8].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.NECKLACE
RdKGToolAdmin.constants.equipment[8].eType = RdKGToolAdmin.constants.equipmentType.ACCESSORIES
RdKGToolAdmin.constants.equipment[8].texture = "esoui/art/characterwindow/gearslot_neck.dds"
RdKGToolAdmin.constants.equipment[9] = {}
RdKGToolAdmin.constants.equipment[9].slotId = 11
RdKGToolAdmin.constants.equipment[9].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.RING_1
RdKGToolAdmin.constants.equipment[9].eType = RdKGToolAdmin.constants.equipmentType.ACCESSORIES
RdKGToolAdmin.constants.equipment[9].texture = "esoui/art/characterwindow/gearslot_ring.dds"
RdKGToolAdmin.constants.equipment[10] = {}
RdKGToolAdmin.constants.equipment[10].slotId = 12
RdKGToolAdmin.constants.equipment[10].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.RING_2
RdKGToolAdmin.constants.equipment[10].eType = RdKGToolAdmin.constants.equipmentType.ACCESSORIES
RdKGToolAdmin.constants.equipment[10].texture = "esoui/art/characterwindow/gearslot_ring.dds"
RdKGToolAdmin.constants.equipment[11] = {}
RdKGToolAdmin.constants.equipment[11].slotId = 4
RdKGToolAdmin.constants.equipment[11].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.WEAPON_1_1
RdKGToolAdmin.constants.equipment[11].eType = RdKGToolAdmin.constants.equipmentType.WEAPON
RdKGToolAdmin.constants.equipment[11].texture = "esoui/art/characterwindow/gearslot_mainhand.dds"
RdKGToolAdmin.constants.equipment[12] = {}
RdKGToolAdmin.constants.equipment[12].slotId = 5
RdKGToolAdmin.constants.equipment[12].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.WEAPON_1_2
RdKGToolAdmin.constants.equipment[12].eType = RdKGToolAdmin.constants.equipmentType.WEAPON
RdKGToolAdmin.constants.equipment[12].texture = "esoui/art/characterwindow/gearslot_offhand.dds"
RdKGToolAdmin.constants.equipment[13] = {}
RdKGToolAdmin.constants.equipment[13].slotId = 20
RdKGToolAdmin.constants.equipment[13].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.WEAPON_2_1
RdKGToolAdmin.constants.equipment[13].eType = RdKGToolAdmin.constants.equipmentType.WEAPON
RdKGToolAdmin.constants.equipment[13].texture = "esoui/art/characterwindow/gearslot_mainhand.dds"
RdKGToolAdmin.constants.equipment[14] = {}
RdKGToolAdmin.constants.equipment[14].slotId = 21
RdKGToolAdmin.constants.equipment[14].messagePrefix = RdKGToolEquip.constants.networking.messagePrefix.WEAPON_2_2
RdKGToolAdmin.constants.equipment[14].eType = RdKGToolAdmin.constants.equipmentType.WEAPON
RdKGToolAdmin.constants.equipment[14].texture = "esoui/art/characterwindow/gearslot_offhand.dds"
--poison at 13 (weapon 4) and 14 (weapon 20)

RdKGToolAdmin.constants.cpDisciplines = {}
RdKGToolAdmin.constants.cpDisciplines[1] = {}
RdKGToolAdmin.constants.cpDisciplines[1].id = 4
RdKGToolAdmin.constants.cpDisciplines[2] = {}
RdKGToolAdmin.constants.cpDisciplines[2].id = 1
RdKGToolAdmin.constants.cpDisciplines[3] = {}
RdKGToolAdmin.constants.cpDisciplines[3].id = 7
RdKGToolAdmin.constants.cpDisciplines[4] = {}
RdKGToolAdmin.constants.cpDisciplines[4].id = 3
RdKGToolAdmin.constants.cpDisciplines[5] = {}
RdKGToolAdmin.constants.cpDisciplines[5].id = 9
RdKGToolAdmin.constants.cpDisciplines[6] = {}
RdKGToolAdmin.constants.cpDisciplines[6].id = 6
RdKGToolAdmin.constants.cpDisciplines[7] = {}
RdKGToolAdmin.constants.cpDisciplines[7].id = 2
RdKGToolAdmin.constants.cpDisciplines[8] = {}
RdKGToolAdmin.constants.cpDisciplines[8].id = 8
RdKGToolAdmin.constants.cpDisciplines[9] = {}
RdKGToolAdmin.constants.cpDisciplines[9].id = 5


RdKGToolAdmin.callbackName = RdKGTool.addonName .. "Admin"
RdKGToolAdmin.requestCallbackName = RdKGTool.addonName .. "AdminRequestCallback"
RdKGToolAdmin.responseCallbackName = RdKGTool.addonName .. "AdminResponseCallback"

RdKGToolAdmin.controls = {}

RdKGToolAdmin.config = {}
RdKGToolAdmin.config.playerWidth = 200
RdKGToolAdmin.config.configWidth = 600
RdKGToolAdmin.config.configOffset = 10
RdKGToolAdmin.config.width = RdKGToolAdmin.config.playerWidth + RdKGToolAdmin.config.configWidth + RdKGToolAdmin.config.configOffset
RdKGToolAdmin.config.playerBlockHeight = 20
RdKGToolAdmin.config.height = RdKGToolAdmin.config.playerBlockHeight * 25 + 10
RdKGToolAdmin.config.headerHeight = 33
RdKGToolAdmin.config.headerOffset = 3
RdKGToolAdmin.config.isMovable = true
RdKGToolAdmin.config.isMouseEnabled = true
RdKGToolAdmin.config.isClampedToScreen = true
RdKGToolAdmin.config.headerFont = "$(BOLD_FONT)|$(KB_20)soft-shadow-thick"
RdKGToolAdmin.config.configEntrySize = 20
RdKGToolAdmin.config.color = {}
RdKGToolAdmin.config.color.default = {}
RdKGToolAdmin.config.color.default.r = 0.85
RdKGToolAdmin.config.color.default.g = 0.83
RdKGToolAdmin.config.color.default.b = 0.7
RdKGToolAdmin.config.color.player = {}
RdKGToolAdmin.config.color.player.r = 0.85
RdKGToolAdmin.config.color.player.g = 0.83
RdKGToolAdmin.config.color.player.b = 0.7
RdKGToolAdmin.config.color.backdrop = {}
RdKGToolAdmin.config.color.backdrop.r = 0.0
RdKGToolAdmin.config.color.backdrop.g = 0.0
RdKGToolAdmin.config.color.backdrop.b = 0.0
RdKGToolAdmin.config.color.backdrop.a = 0.7
RdKGToolAdmin.config.color.backdropEdge = {}
RdKGToolAdmin.config.color.backdropEdge.r = 1.0
RdKGToolAdmin.config.color.backdropEdge.g = 1.0
RdKGToolAdmin.config.color.backdropEdge.b = 1.0
RdKGToolAdmin.config.color.backdropEdge.a = 0.7
RdKGToolAdmin.config.color.playerEntryColorSelected = {}
RdKGToolAdmin.config.color.playerEntryColorSelected.r = 0.8
RdKGToolAdmin.config.color.playerEntryColorSelected.g = 0.6
RdKGToolAdmin.config.color.playerEntryColorSelected.b = 0.4
RdKGToolAdmin.config.color.playerEntryColorSelected.a = 0.3
RdKGToolAdmin.config.color.playerEntryColorSelectedHover = {}
RdKGToolAdmin.config.color.playerEntryColorSelectedHover.r = 0.4
RdKGToolAdmin.config.color.playerEntryColorSelectedHover.g = 0.6
RdKGToolAdmin.config.color.playerEntryColorSelectedHover.b = 1.0
RdKGToolAdmin.config.color.playerEntryColorSelectedHover.a = 0.7
RdKGToolAdmin.config.color.playerEntryColorHover = {}
RdKGToolAdmin.config.color.playerEntryColorHover.r = 0.4
RdKGToolAdmin.config.color.playerEntryColorHover.g = 0.6
RdKGToolAdmin.config.color.playerEntryColorHover.b = 1.0
RdKGToolAdmin.config.color.playerEntryColorHover.a = 0.3
RdKGToolAdmin.config.color.titleColor = {}
RdKGToolAdmin.config.color.titleColor.r = 1
RdKGToolAdmin.config.color.titleColor.g = 0.35
RdKGToolAdmin.config.color.titleColor.b = 0.35
RdKGToolAdmin.config.color.subtitleColor = {}
RdKGToolAdmin.config.color.subtitleColor.r = 0.35
RdKGToolAdmin.config.color.subtitleColor.g = 0.35
RdKGToolAdmin.config.color.subtitleColor.b = 1
RdKGToolAdmin.config.color.equipmentDescription = {}
RdKGToolAdmin.config.color.equipmentDescription.r = 0.85
RdKGToolAdmin.config.color.equipmentDescription.g = 0.83
RdKGToolAdmin.config.color.equipmentDescription.b = 0.7
RdKGToolAdmin.config.color.equipmentHover = {}
RdKGToolAdmin.config.color.equipmentHover.r = 0.4
RdKGToolAdmin.config.color.equipmentHover.g = 0.6
RdKGToolAdmin.config.color.equipmentHover.b = 1.0
RdKGToolAdmin.config.color.equipmentHover.a = 0.7
RdKGToolAdmin.config.color.cpText = {}
RdKGToolAdmin.config.color.cpText.r = 0.85
RdKGToolAdmin.config.color.cpText.g = 0.83
RdKGToolAdmin.config.color.cpText.b = 0.7
RdKGToolAdmin.config.color.cpValue = {}
RdKGToolAdmin.config.color.cpValue.r = 1
RdKGToolAdmin.config.color.cpValue.g = 1
RdKGToolAdmin.config.color.cpValue.b = 1
RdKGToolAdmin.config.color.cpRed = {}
RdKGToolAdmin.config.color.cpRed.r = 0.83203125
RdKGToolAdmin.config.color.cpRed.g = 0.3515625
RdKGToolAdmin.config.color.cpRed.b = 0.171875
RdKGToolAdmin.config.color.cpGreen = {}
RdKGToolAdmin.config.color.cpGreen.r = 0.5
RdKGToolAdmin.config.color.cpGreen.g = 0.91796875
RdKGToolAdmin.config.color.cpGreen.b = 0.5
RdKGToolAdmin.config.color.cpBlue = {}
RdKGToolAdmin.config.color.cpBlue.r = 0.5
RdKGToolAdmin.config.color.cpBlue.g = 0.85546875
RdKGToolAdmin.config.color.cpBlue.b = 1.0

RdKGToolAdmin.config.configWindow = {}
RdKGToolAdmin.config.configWindow.rating = {}
RdKGToolAdmin.config.configWindow.rating.neutral = "FFFFFF"
RdKGToolAdmin.config.configWindow.rating.ok = "00FF00"
RdKGToolAdmin.config.configWindow.rating.fail = "FF0000"
RdKGToolAdmin.config.configWindow.equipmentValue = "FFFFFF"

RdKGToolAdmin.state = {}
RdKGToolAdmin.state.size = 0
RdKGToolAdmin.state.selectedIndex = 0
RdKGToolAdmin.state.playerList = {}
RdKGToolAdmin.state.initialized = false

local wm = WINDOW_MANAGER

function RdKGToolAdmin.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolAdmin.callbackName, RdKGToolAdmin.OnProfileChanged)
	ZO_CreateStringId("SI_BINDING_NAME_RDKGTOOL_ADMIN_OPEN", RdKGToolAdmin.constants.TOGGLE_ADMIN)
	for i = 1, #RdKGToolAdmin.constants.equipment do
		RdKGToolAdmin.constants.equipment[i].name = RdKGToolEquip.GetEquipmentNameFromMessagePrefix(RdKGToolAdmin.constants.equipment[i].messagePrefix)
	end
	for i = 1, #RdKGToolAdmin.constants.cpDisciplines do
		RdKGToolAdmin.constants.cpDisciplines[i].text = RdKGToolCP.GetDisciplineText(RdKGToolAdmin.constants.cpDisciplines[i].id)
		RdKGToolAdmin.constants.cpDisciplines[i].cp = RdKGToolCP.CreateCPStructureForDiscipline(RdKGToolAdmin.constants.cpDisciplines[i].id)
	end
	RdKGToolAdmin.CreateUI()
	RdKGToolNetworking.AddRawMessageHandler(RdKGToolAdmin.requestCallbackName, RdKGToolAdmin.HandleRawAdminNetworkMessage)
	--if RdKGToolRoster.IsRdKAdmin(GetUnitDisplayName("player")) then
	RdKGToolNetworking.AddRawMessageHandler(RdKGToolAdmin.responseCallbackName, RdKGToolGroup.HandleRawAdminNetworkMessage)
	--end
	RdKGToolAdmin.state.initialized = true
end

function RdKGToolAdmin.SetTlwLocation()
	if RdKGToolAdmin.adminVars == nil or RdKGToolAdmin.adminVars.position == nil then
		RdKGToolAdmin.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, 0, -RdKGToolAdmin.config.height / 2)
	else
		RdKGToolAdmin.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolAdmin.adminVars.position.x , RdKGToolAdmin.adminVars.position.y)
	end
end

function RdKGToolAdmin.GetDefaults()
	local defaults = {}
	defaults.enabled = false
	defaults.allowClientConfiguration = false
	defaults.allowAddonConfiguration = true
	defaults.allowStats = true
	defaults.allowSkills = true
	defaults.allowEquipment = true
	defaults.allowCp = true
	return defaults
end

function RdKGToolAdmin.CreateUI()
	--TLW
	RdKGToolAdmin.controls.TLW = wm:CreateTopLevelWindow(RdKGToolAdmin.constants.TLW_ADMIN_WINDOW)
	
	RdKGToolAdmin.controls.TLW:SetDimensions(RdKGToolAdmin.config.width, RdKGToolAdmin.config.headerHeight)
	RdKGToolAdmin.SetTlwLocation()
	
	RdKGToolAdmin.controls.TLW:SetMovable(RdKGToolAdmin.config.isMovable)
	RdKGToolAdmin.controls.TLW:SetMouseEnabled(RdKGToolAdmin.config.isMouseEnabled)
	
	RdKGToolAdmin.controls.TLW:SetClampedToScreen(RdKGToolAdmin.config.isClampedToScreen)
	RdKGToolAdmin.controls.TLW:SetHandler("OnMoveStop", RdKGToolAdmin.SaveWindowLocation)
	RdKGToolAdmin.controls.TLW:SetHidden(true)
	
	--Header
	
	RdKGToolAdmin.controls.TLW.header= wm:CreateControl(nil, RdKGToolAdmin.controls.TLW, CT_CONTROL)
	RdKGToolAdmin.controls.TLW.header:SetDimensions(RdKGToolAdmin.config.width, RdKGToolAdmin.config.headerHeight)
	RdKGToolAdmin.controls.TLW.header:SetAnchor(TOPLEFT, RdKGToolAdmin.controls.TLW, TOPLEFT, 0, 0)
	
	
	RdKGToolAdmin.controls.TLW.header.label = wm:CreateControl(nil, RdKGToolAdmin.controls.TLW.header, CT_LABEL)
	RdKGToolAdmin.controls.TLW.header.label:SetAnchor(TOP, RdKGToolAdmin.controls.TLW.header, TOP ,0 , 3)
	RdKGToolAdmin.controls.TLW.header.label:SetFont(RdKGToolAdmin.config.headerFont)
	RdKGToolAdmin.controls.TLW.header.label:SetWrapMode(ELLIPSIS)
	RdKGToolAdmin.controls.TLW.header.label:SetColor(RdKGToolAdmin.config.color.default.r, RdKGToolAdmin.config.color.default.g, RdKGToolAdmin.config.color.default.b)
	RdKGToolAdmin.controls.TLW.header.label:SetText(RdKGToolAdmin.constants.HEADER_TITLE)
		
		
	RdKGToolAdmin.controls.TLW.header.backdrop = CreateControlFromVirtual(RdKGToolAdmin.constants.HEADER_BACKDROP_NAME, RdKGToolAdmin.controls.TLW.header, "ZO_SliderBackdrop")
	RdKGToolAdmin.controls.TLW.header.backdrop:SetCenterColor(RdKGToolAdmin.config.color.backdrop.r, RdKGToolAdmin.config.color.backdrop.g, RdKGToolAdmin.config.color.backdrop.b, RdKGToolAdmin.config.color.backdrop.a)
	RdKGToolAdmin.controls.TLW.header.backdrop:SetEdgeColor(RdKGToolAdmin.config.color.backdropEdge.r, RdKGToolAdmin.config.color.backdropEdge.g, RdKGToolAdmin.config.color.backdropEdge.b, RdKGToolAdmin.config.color.backdropEdge.a)
		
	RdKGToolAdmin.controls.TLW.header.button = wm:CreateControl(nil, RdKGToolAdmin.controls.TLW.header, CT_BUTTON)
	RdKGToolAdmin.controls.TLW.header.button:SetAnchor(TOPRIGHT, RdKGToolAdmin.controls.TLW.header, TOPRIGHT, -3, 7)
	RdKGToolAdmin.controls.TLW.header.button:SetDimensions(20, 20)
	RdKGToolAdmin.controls.TLW.header.button:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
	RdKGToolAdmin.controls.TLW.header.button:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
	RdKGToolAdmin.controls.TLW.header.button:SetHandler("OnClicked", RdKGToolAdmin.CloseWindow)
	
	
	--Player Window
	
	RdKGToolAdmin.controls.TLW.player = wm:CreateControl(nil, RdKGToolAdmin.controls.TLW, CT_CONTROL)
	RdKGToolAdmin.controls.TLW.player:SetDimensions(RdKGToolAdmin.config.playerWidth, RdKGToolAdmin.config.height)
	RdKGToolAdmin.controls.TLW.player:SetAnchor(TOPLEFT, RdKGToolAdmin.controls.TLW, TOPLEFT, 0, RdKGToolAdmin.config.headerOffset + RdKGToolAdmin.config.headerHeight)
	
	RdKGToolAdmin.controls.TLW.player.backdrop = CreateControlFromVirtual(RdKGToolAdmin.constants.PLAYER_BACKDROP_NAME, RdKGToolAdmin.controls.TLW.player, "ZO_SliderBackdrop")
	RdKGToolAdmin.controls.TLW.player.backdrop:SetCenterColor(RdKGToolAdmin.config.color.backdrop.r, RdKGToolAdmin.config.color.backdrop.g, RdKGToolAdmin.config.color.backdrop.b, RdKGToolAdmin.config.color.backdrop.a)
	RdKGToolAdmin.controls.TLW.player.backdrop:SetEdgeColor(RdKGToolAdmin.config.color.backdropEdge.r, RdKGToolAdmin.config.color.backdropEdge.g, RdKGToolAdmin.config.color.backdropEdge.b, RdKGToolAdmin.config.color.backdropEdge.a)
	
	local blockFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolAdmin.config.playerBlockHeight - 2, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	RdKGToolAdmin.controls.TLW.player.blocks = {}
	
	for i = 1, 25 do
		local backdrop = wm:CreateControl(nil, RdKGToolAdmin.controls.TLW.player, CT_BACKDROP)
		
		RdKGToolAdmin.controls.TLW.player.blocks[i] = wm:CreateControl(nil, RdKGToolAdmin.controls.TLW.player, CT_BUTTON)
		RdKGToolAdmin.controls.TLW.player.blocks[i]:EnableMouseButton(MOUSE_BUTTON_INDEX_RIGHT, true)
		RdKGToolAdmin.controls.TLW.player.blocks[i]:SetFont(blockFont)
		RdKGToolAdmin.controls.TLW.player.blocks[i]:SetMouseEnabled(true)
		RdKGToolAdmin.controls.TLW.player.blocks[i]:SetAnchor(TOPLEFT, RdKGToolAdmin.controls.TLW.player, TOPLEFT ,5 , 7 + ((i - 1) * RdKGToolAdmin.config.playerBlockHeight))
		RdKGToolAdmin.controls.TLW.player.blocks[i]:SetDimensions(RdKGToolAdmin.config.playerWidth - 6, RdKGToolAdmin.config.playerBlockHeight)
		RdKGToolAdmin.controls.TLW.player.blocks[i]:SetNormalFontColor(RdKGToolAdmin.config.color.player.r, RdKGToolAdmin.config.color.player.g, RdKGToolAdmin.config.color.player.b, 1)
		RdKGToolAdmin.controls.TLW.player.blocks[i]:SetPressedFontColor(RdKGToolAdmin.config.color.player.r, RdKGToolAdmin.config.color.player.g, RdKGToolAdmin.config.color.player.b, 1)
		RdKGToolAdmin.controls.TLW.player.blocks[i]:SetMouseOverFontColor(RdKGToolAdmin.config.color.player.r, RdKGToolAdmin.config.color.player.g, RdKGToolAdmin.config.color.player.b, 1)
		RdKGToolAdmin.controls.TLW.player.blocks[i]:SetHandler("OnMouseEnter", function() RdKGToolAdmin.PlayerEntryOnMouseEnter(i) end)
		RdKGToolAdmin.controls.TLW.player.blocks[i]:SetHandler("OnMouseExit", function() RdKGToolAdmin.PlayerEntryOnMouseExit(i) end)
		RdKGToolAdmin.controls.TLW.player.blocks[i]:SetHandler("OnClicked", function(idk, button) if button == MOUSE_BUTTON_INDEX_LEFT then RdKGToolAdmin.PlayerEntryOnClick(i) elseif button == MOUSE_BUTTON_INDEX_RIGHT then RdKGToolAdmin.PlayerEntryOnClick(i) RdKGToolAdmin.CreatePlayerContextMenu(i) end end)
		RdKGToolAdmin.controls.TLW.player.blocks[i]:SetVerticalAlignment(TEXT_ALIGN_TOP)
		RdKGToolAdmin.controls.TLW.player.blocks[i]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		--RdKGToolAdmin.controls.TLW.player.blocks[i]:SetText("test")
		RdKGToolAdmin.controls.TLW.player.blocks[i].backdrop = backdrop
		
		RdKGToolAdmin.controls.TLW.player.blocks[i].backdrop:SetAlpha(1)
		RdKGToolAdmin.controls.TLW.player.blocks[i].backdrop:SetAnchor(TOPLEFT, RdKGToolAdmin.controls.TLW.player, TOPLEFT ,5 , 7 + ((i - 1) * RdKGToolAdmin.config.playerBlockHeight))
		RdKGToolAdmin.controls.TLW.player.blocks[i].backdrop:SetDimensions(RdKGToolAdmin.config.playerWidth - 6, RdKGToolAdmin.config.playerBlockHeight)
		RdKGToolAdmin.controls.TLW.player.blocks[i].backdrop:SetCenterColor(RdKGToolAdmin.config.color.playerEntryColorHover.r, RdKGToolAdmin.config.color.playerEntryColorHover.g, RdKGToolAdmin.config.color.playerEntryColorHover.b, 0.0)
		RdKGToolAdmin.controls.TLW.player.blocks[i].backdrop:SetEdgeColor(RdKGToolAdmin.config.color.playerEntryColorHover.r, RdKGToolAdmin.config.color.playerEntryColorHover.g, RdKGToolAdmin.config.color.playerEntryColorHover.b, 0.0)	
	end	
	
	RdKGToolAdmin.controls.TLW.player.blocks[1]:SetText(RdKGToolAdmin.constants.PLAYERS_ALL)
	
	--Config Window
	
	RdKGToolAdmin.controls.TLW.config = wm:CreateControl(nil, RdKGToolAdmin.controls.TLW, CT_CONTROL)
	RdKGToolAdmin.controls.TLW.config:SetDimensions(RdKGToolAdmin.config.configWidth, RdKGToolAdmin.config.height)
	RdKGToolAdmin.controls.TLW.config:SetAnchor(TOPLEFT, RdKGToolAdmin.controls.TLW, TOPLEFT, RdKGToolAdmin.config.playerWidth + RdKGToolAdmin.config.configOffset, RdKGToolAdmin.config.headerOffset + RdKGToolAdmin.config.headerHeight)
	
	RdKGToolAdmin.controls.TLW.config.backdrop = CreateControlFromVirtual(RdKGToolAdmin.constants.CONFIG_BACKDROP_NAME, RdKGToolAdmin.controls.TLW.config, "ZO_SliderBackdrop")
	RdKGToolAdmin.controls.TLW.config.backdrop:SetCenterColor(RdKGToolAdmin.config.color.backdrop.r, RdKGToolAdmin.config.color.backdrop.g, RdKGToolAdmin.config.color.backdrop.b, RdKGToolAdmin.config.color.backdrop.a)
	RdKGToolAdmin.controls.TLW.config.backdrop:SetEdgeColor(RdKGToolAdmin.config.color.backdropEdge.r, RdKGToolAdmin.config.color.backdropEdge.g, RdKGToolAdmin.config.color.backdropEdge.b, RdKGToolAdmin.config.color.backdropEdge.a)
	
	RdKGToolAdmin.controls.TLW.config.scrollControl = wm:CreateControl(RdKGToolAdmin.constants.SCROLL_CONTROL, RdKGToolAdmin.controls.TLW.config, CT_SCROLL)
	RdKGToolAdmin.controls.TLW.config.scrollControl:SetDimensions(RdKGToolAdmin.config.configWidth, RdKGToolAdmin.config.height - 15)
	RdKGToolAdmin.controls.TLW.config.scrollControl:SetAnchor(TOPLEFT, RdKGToolAdmin.controls.TLW.config, TOPLEFT, 0, 8)
	RdKGToolAdmin.controls.TLW.config.scrollControl:SetScrollBounding(SCROLL_BOUNDING_CONTAINED)
	
	
	RdKGToolAdmin.controls.TLW.config.scrollPanel = wm:CreateControl(nil, RdKGToolAdmin.controls.TLW.config.scrollControl, CT_CONTROL)
	
	RdKGToolAdmin.controls.TLW.config.scrollPanel:SetAnchor(TOPLEFT, RdKGToolAdmin.controls.TLW.config.scrollControl, TOPLEFT, 0, 0)
	RdKGToolAdmin.controls.TLW.config.scrollPanel:SetMouseEnabled(true)
	RdKGToolAdmin.controls.TLW.config.scrollPanel:SetHandler("OnMouseWheel", RdKGToolAdmin.ConfigPanelOnMouseWheel);
	
	RdKGToolAdmin.controls.TLW.config.slider = wm:CreateControl(nil, RdKGToolAdmin.controls.TLW.config, CT_SLIDER)
	RdKGToolAdmin.controls.TLW.config.slider:SetDimensions(25, RdKGToolAdmin.config.height)
	RdKGToolAdmin.controls.TLW.config.slider:SetAnchor(TOPRIGHT, RdKGToolAdmin.controls.TLW.config, TOPRIGHT, 0, 0)
	RdKGToolAdmin.controls.TLW.config.slider:SetOrientation(ORIENTATION_VERTICAL)
	RdKGToolAdmin.controls.TLW.config.slider:SetMouseEnabled(true)
	RdKGToolAdmin.controls.TLW.config.slider:SetMinMax(0, 100)
	RdKGToolAdmin.controls.TLW.config.slider:SetThumbTexture("esoui/art/buttons/smoothsliderbutton_up.dds", nil, nil, 25, 50)
	RdKGToolAdmin.controls.TLW.config.slider:SetValueStep(1)
	RdKGToolAdmin.controls.TLW.config.slider:SetHandler("OnValueChanged", RdKGToolAdmin.AdjustConfigSlider)
	
	RdKGToolAdmin.CreateConfigUI(RdKGToolAdmin.controls.TLW.config.scrollPanel)
	RdKGToolAdmin.controls.TLW.config.scrollPanel:SetDimensions(RdKGToolAdmin.config.configWidth - 10, RdKGToolAdmin.state.size)
	RdKGToolAdmin.PopulateConfigPanel(RdKGToolAdmin.CreateConfigPanelData(0))
end

function RdKGToolAdmin.CreateConfigUI(rootControl)
	local controlFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolAdmin.config.configEntrySize - 2, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	local tempSize = 0
	
	rootControl.player = {}
	rootControl.player.title, tempSize = RdKGToolAdmin.CreateTitleControl(rootControl, RdKGToolAdmin.constants.config.PLAYER_TITLE)
	rootControl.player.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.player.displayName, rootControl.player.charName = RdKGToolAdmin.CreateDoubleLabel(rootControl, controlFont)
	rootControl.player.version = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	--rootControl.player.version:SetText(string.format(RdKGToolAdmin.constants.config.PLAYER_VERSION_STRING, RdKGToolAdmin.config.configWindow.rating.neutral, 0, 0, 0))
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.client = {}
	rootControl.client.title, tempSize = RdKGToolAdmin.CreateTitleControl(rootControl, RdKGToolAdmin.constants.config.CLIENT_TITLE)
	rootControl.client.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.client.aoe = {}
	rootControl.client.aoe.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.CLIENT_AOE_SUBTITLE)
	rootControl.client.aoe.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.client.aoe.tellsEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.aoe.customColorsEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.aoe.friendlyBrightness = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.aoe.enemyBrightness = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.client.sound = {}
	rootControl.client.sound.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.CLIENT_SOUND_SUBTITLE)
	rootControl.client.sound.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.client.sound.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.sound.audioVolume = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.sound.uiVolume = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.sound.sfxVolume = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.client.graphics = {}
	rootControl.client.graphics.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_SUBTITLE)
	rootControl.client.graphics.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.client.graphics.resolution = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.windowMode = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.vsync = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.antiAliasing = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.ambient = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.bloom = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.depthOfField = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.distortion = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.sunlight = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.allyEffects = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.viewDistance = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.particleMaximum = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.particleSupress = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.reflectionQuality = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.shadowQuality = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.subSamplingQuality = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.client.graphics.graphicPresets = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon = {}
	rootControl.addon.title, tempSize = RdKGToolAdmin.CreateTitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_TITLE)
	rootControl.addon.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.crown = {}
	rootControl.addon.crown.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_CROWN_SUBTITLE)
	rootControl.addon.crown.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.crown.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.crown.size = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.crown.selectedCrown = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.ftcv = {}
	rootControl.addon.ftcv.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_FTCV_SUBTITLE)
	rootControl.addon.ftcv.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.ftcv.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftcv.sizeFar = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftcv.sizeClose = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftcv.opacityFar = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftcv.opacityClose = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftcv.minDistance = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftcv.maxDistance = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.ftcw = {}
	rootControl.addon.ftcw.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_FTCW_SUBTITLE)
	rootControl.addon.ftcw.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.ftcw.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftcw.distanceEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftcw.warningsEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftcw.maxDistance = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.ftca = {}
	rootControl.addon.ftca.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_FTCA_SUBTITLE)
	rootControl.addon.ftca.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.ftca.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftca.maxDistance = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftca.interval = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftca.threshold = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.ftcb = {}
	rootControl.addon.ftcb.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_FTCB_SUBTITLE)
	rootControl.addon.ftcb.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.ftcb.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftcb.selectedBeam = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ftcb.alpha = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.dbo = {}
	rootControl.addon.dbo.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_DBO_SUBTITLE)
	rootControl.addon.dbo.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.dbo.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.rt = {}
	rootControl.addon.rt.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_RT_SUBTITLE)
	rootControl.addon.rt.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.rt.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.ro = {}
	rootControl.addon.ro.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_RO_SUBTITLE)
	rootControl.addon.ro.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.ro.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.ultimateOverviewEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.clientGroupEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.groupUltimateEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.showSoftResources = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.soundEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.maxDistance = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.groupSizeDestro = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.groupSizeStorm = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.groupSizeNorthernStorm = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.groupSizePermafrost = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.groupSizeNegate = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.groupSizeNegateOffensive = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.groupSizeNegateCounter = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.groupSizeNova = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ro.groupsEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.hdm = {}
	rootControl.addon.hdm.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_HDM_SUBTITLE)
	rootControl.addon.hdm.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.hdm.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.hdm.windowEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.hdm.viewMode = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.po = {}
	rootControl.addon.po.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_PO_SUBTITLE)
	rootControl.addon.po.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.po.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.po.soundEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.dt = {}
	rootControl.addon.dt.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_DT_SUBTITLE)
	rootControl.addon.dt.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.dt.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.gb = {}
	rootControl.addon.gb.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_GB_SUBTITLE)
	rootControl.addon.gb.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.gb.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.isdp = {}
	rootControl.addon.isdp.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_ISDP_SUBTITLE)
	rootControl.addon.isdp.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.isdp.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.yacs = {}
	rootControl.addon.yacs.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_YACS_SUBTITLE)
	rootControl.addon.yacs.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.yacs.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.yacs.pvpEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.yacs.combatEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.sc = {}
	rootControl.addon.sc.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_SC_SUBTITLE)
	rootControl.addon.sc.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.sc.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.sm = {}
	rootControl.addon.sm.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_SM_SUBTITLE)
	rootControl.addon.sm.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.sm.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.recharger = {}
	rootControl.addon.recharger.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_RECHARGER_SUBTITLE)
	rootControl.addon.recharger.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.recharger.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	if RdKGToolRoster.IsRdKMember(GetUnitDisplayName("player")) == true then
		rootControl.addon.kc = {}
		rootControl.addon.kc.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_KC_SUBTITLE)
		rootControl.addon.kc.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
		
		RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
		
		rootControl.addon.kc.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
		
		RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	end
	rootControl.addon.bft = {}
	rootControl.addon.bft.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_BFT_SUBTITLE)
	rootControl.addon.bft.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.bft.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.bft.soundEnabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.bft.size = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.cl = {}
	rootControl.addon.cl.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_CL_SUBTITLE)
	rootControl.addon.cl.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.cl.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.cs = {}
	rootControl.addon.cs.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_CS_SUBTITLE)
	rootControl.addon.cs.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.cs.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.respawner = {}
	rootControl.addon.respawner.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_RESPAWNER_SUBTITLE)
	rootControl.addon.respawner.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.respawner.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.camp = {}
	rootControl.addon.camp.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_CAMP_SUBTITLE)
	rootControl.addon.camp.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.camp.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.sp = {}
	rootControl.addon.sp.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_SP_SUBTITLE)
	rootControl.addon.sp.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.sp.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.mode = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventCombustionShards = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventTalons = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventNova = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventAltar = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventStandard = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventRitual = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventBoneShield = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventConduit = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventAtronach = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventTrappingWebs = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventRadiate = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventConsumingDarkness = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventSoulLeech = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventHealingSeed = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventGraveRobber = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.sp.preventPureAgony = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.so = {}
	rootControl.addon.so.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_SO_SUBTITLE)
	rootControl.addon.so.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.so.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.so.tableMode = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.so.displayMode = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.ra = {}
	rootControl.addon.ra.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_RA_SUBTITLE)
	rootControl.addon.ra.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.ra.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.addon.ra.allowOverride = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.caj = {}
	rootControl.addon.caj.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_CAJ_SUBTITLE)
	rootControl.addon.caj.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.caj.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.addon.crBgTp = {}
	rootControl.addon.crBgTp.title, tempSize = RdKGToolAdmin.CreateSubtitleControl(rootControl, RdKGToolAdmin.constants.config.ADDON_CRBGTP_SUBTITLE)
	rootControl.addon.crBgTp.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.addon.crBgTp.enabled = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	--stats
	rootControl.stats = {}
	rootControl.stats.title, tempSize = RdKGToolAdmin.CreateTitleControl(rootControl, RdKGToolAdmin.constants.config.STATS_TITLE)
	rootControl.stats.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.stats.magicka, rootControl.stats.magickaRecovery = RdKGToolAdmin.CreateDoubleLabel(rootControl, controlFont)
	rootControl.stats.health, rootControl.stats.healthRecovery = RdKGToolAdmin.CreateDoubleLabel(rootControl, controlFont)
	rootControl.stats.stamina, rootControl.stats.staminaRecovery = RdKGToolAdmin.CreateDoubleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	rootControl.stats.spellDamage, rootControl.stats.weaponDamage = RdKGToolAdmin.CreateDoubleLabel(rootControl, controlFont)
	rootControl.stats.spellPenetration, rootControl.stats.weaponPenetration = RdKGToolAdmin.CreateDoubleLabel(rootControl, controlFont)
	rootControl.stats.spellCritical, rootControl.stats.weaponCritical = RdKGToolAdmin.CreateDoubleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
		
	rootControl.stats.spellResistance, rootControl.stats.physicalResistance = RdKGToolAdmin.CreateDoubleLabel(rootControl, controlFont)
	rootControl.stats.criticalResistance = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)

	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	--Mundus
	rootControl.mundus = {}
	rootControl.mundus.title, tempSize = RdKGToolAdmin.CreateTitleControl(rootControl, RdKGToolAdmin.constants.config.MUNDUS_TITLE)
	rootControl.mundus.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.mundus.stone1 = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	rootControl.mundus.stone2 = RdKGToolAdmin.CreateSimpleLabel(rootControl, controlFont)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	--skills
	rootControl.skills = {}
	rootControl.skills.title, tempSize = RdKGToolAdmin.CreateTitleControl(rootControl, RdKGToolAdmin.constants.config.SKILLS_TITLE)
	rootControl.skills.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.skills.bar1, tempSize = RdKGToolAdmin.CreateSkillBarControl(rootControl)
	rootControl.skills.bar1:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.skills.bar2, tempSize = RdKGToolAdmin.CreateSkillBarControl(rootControl)
	rootControl.skills.bar2:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize + RdKGToolAdmin.config.configEntrySize
	
	--equipment
	rootControl.equipment = {}
	rootControl.equipment.title, tempSize = RdKGToolAdmin.CreateTitleControl(rootControl, RdKGToolAdmin.constants.config.EQUIPMENT_TITLE)
	rootControl.equipment.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	for i = 1, #RdKGToolAdmin.constants.equipment do
		rootControl.equipment[RdKGToolAdmin.constants.equipment[i].name], tempSize = RdKGToolAdmin.CreateEquipmentControl(rootControl, RdKGToolAdmin.constants.equipment[i], i)
		rootControl.equipment[RdKGToolAdmin.constants.equipment[i].name]:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
		RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	end
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	--champion points cp
	rootControl.cp = {}
	rootControl.cp.title, tempSize = RdKGToolAdmin.CreateTitleControl(rootControl, RdKGToolAdmin.constants.config.CHAMPION_TITLE)
	rootControl.cp.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	
	rootControl.cp.cpBlocks = {}
	rootControl.cp.cpValues = {}
	for i = 1, 3 do
		local cpNames = {}
		local width = RdKGToolAdmin.config.configWidth / 3 - 10
		rootControl.cp.cpBlocks[1 + ((i - 1) * 3)], cpNames, tempSize = RdKGToolAdmin.CreateCPBlock(rootControl, RdKGToolAdmin.constants.cpDisciplines[1 + ((i - 1) * 3)], width)
		rootControl.cp.cpBlocks[1 + ((i - 1) * 3)]:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
		rootControl.cp.cpBlocks[1 + ((i - 1) * 3)].title:SetColor(RdKGToolAdmin.config.color.cpRed.r, RdKGToolAdmin.config.color.cpRed.g, RdKGToolAdmin.config.color.cpRed.b)
		rootControl.cp.cpValues[cpNames[1].name] = cpNames[1].control
		rootControl.cp.cpValues[cpNames[2].name] = cpNames[2].control
		rootControl.cp.cpValues[cpNames[3].name] = cpNames[3].control
		rootControl.cp.cpValues[cpNames[4].name] = cpNames[4].control
		
		rootControl.cp.cpBlocks[2 + ((i - 1) * 3)], cpNames, tempSize = RdKGToolAdmin.CreateCPBlock(rootControl, RdKGToolAdmin.constants.cpDisciplines[2 + ((i - 1) * 3)], width)
		rootControl.cp.cpBlocks[2 + ((i - 1) * 3)]:SetAnchor(TOPLEFT, rootControl, TOPLEFT, width, RdKGToolAdmin.state.size)
		rootControl.cp.cpBlocks[2 + ((i - 1) * 3)].title:SetColor(RdKGToolAdmin.config.color.cpGreen.r, RdKGToolAdmin.config.color.cpGreen.g, RdKGToolAdmin.config.color.cpGreen.b)
		rootControl.cp.cpValues[cpNames[1].name] = cpNames[1].control
		rootControl.cp.cpValues[cpNames[2].name] = cpNames[2].control
		rootControl.cp.cpValues[cpNames[3].name] = cpNames[3].control
		rootControl.cp.cpValues[cpNames[4].name] = cpNames[4].control
		
		rootControl.cp.cpBlocks[3 + ((i - 1) * 3)], cpNames, tempSize = RdKGToolAdmin.CreateCPBlock(rootControl, RdKGToolAdmin.constants.cpDisciplines[3 + ((i - 1) * 3)], width)
		rootControl.cp.cpBlocks[3 + ((i - 1) * 3)]:SetAnchor(TOPLEFT, rootControl, TOPLEFT, width * 2, RdKGToolAdmin.state.size)
		rootControl.cp.cpBlocks[3 + ((i - 1) * 3)].title:SetColor(RdKGToolAdmin.config.color.cpBlue.r, RdKGToolAdmin.config.color.cpBlue.g, RdKGToolAdmin.config.color.cpBlue.b)
		rootControl.cp.cpValues[cpNames[1].name] = cpNames[1].control
		rootControl.cp.cpValues[cpNames[2].name] = cpNames[2].control
		rootControl.cp.cpValues[cpNames[3].name] = cpNames[3].control
		rootControl.cp.cpValues[cpNames[4].name] = cpNames[4].control
		
		RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize
	end
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	--[[
	--quickslots
	rootControl.quickslots = {}
	rootControl.quickslots.title, tempSize = RdKGToolAdmin.CreateTitleControl(rootControl, RdKGToolAdmin.constants.config.QUICKSLOT_TITLE)
	rootControl.quickslots.title:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolAdmin.state.size)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + tempSize + RdKGToolAdmin.config.configEntrySize
	]]
end

function RdKGToolAdmin.CreateSimpleLabel(parent, controlFont)
	local control = wm:CreateControl(nil, parent, CT_LABEL)
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, 3, RdKGToolAdmin.state.size)
	control:SetDimensions(400, RdKGToolAdmin.config.configEntrySize)
	control:SetFont(controlFont)
	control:SetWrapMode(ELLIPSIS)
	control:SetColor(RdKGToolAdmin.config.color.default.r, RdKGToolAdmin.config.color.default.g, RdKGToolAdmin.config.color.default.b)
	control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize
	
	return control
end

function RdKGToolAdmin.CreateDoubleLabel(parent, controlFont)
	local control1 = wm:CreateControl(nil, parent, CT_LABEL)
	control1:SetAnchor(TOPLEFT, parent, TOPLEFT, 3, RdKGToolAdmin.state.size)
	control1:SetDimensions(300, RdKGToolAdmin.config.configEntrySize)
	control1:SetFont(controlFont)
	control1:SetWrapMode(ELLIPSIS)
	control1:SetColor(RdKGToolAdmin.config.color.default.r, RdKGToolAdmin.config.color.default.g, RdKGToolAdmin.config.color.default.b)
	control1:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	
	local control2 = wm:CreateControl(nil, parent, CT_LABEL)
	control2:SetAnchor(TOPLEFT, parent, TOPLEFT, 303, RdKGToolAdmin.state.size)
	control2:SetDimensions(300, RdKGToolAdmin.config.configEntrySize)
	control2:SetFont(controlFont)
	control2:SetWrapMode(ELLIPSIS)
	control2:SetColor(RdKGToolAdmin.config.color.default.r, RdKGToolAdmin.config.color.default.g, RdKGToolAdmin.config.color.default.b)
	control2:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	
	RdKGToolAdmin.state.size = RdKGToolAdmin.state.size + RdKGToolAdmin.config.configEntrySize

	return control1, control2
end

function RdKGToolAdmin.CreateTitleControl(parent, title)
	local titleFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolAdmin.config.configEntrySize * 2 - 5, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	local control = wm:CreateControl(nil, parent, CT_CONTROL)
	control:SetDimensions(RdKGToolAdmin.config.configWidth, RdKGToolAdmin.config.configEntrySize * 2)
	
	control.title = wm:CreateControl(nil, control, CT_LABEL)
	control.title:SetAnchor(TOPLEFT, control, TOPLEFT, 5, 0)
	control.title:SetDimensions(RdKGToolAdmin.config.configWidth, RdKGToolAdmin.config.configEntrySize * 2 - 5)
	control.title:SetFont(titleFont)
	control.title:SetWrapMode(ELLIPSIS)
	control.title:SetColor(RdKGToolAdmin.config.color.titleColor.r, RdKGToolAdmin.config.color.titleColor.g, RdKGToolAdmin.config.color.titleColor.b)
	control.title:SetText(title)
	control.title:SetVerticalAlignment(TEXT_ALIGN_TOP)
	control.title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	
	
	control.texture = wm:CreateControl(nil, control, CT_TEXTURE)
	control.texture:SetAnchor(TOPLEFT, control, TOPLEFT, -100, RdKGToolAdmin.config.configEntrySize * 2 - 5) 
	control.texture:SetDimensions(800, 15) 
	control.texture:SetTexture("/esoui/art/miscellaneous/horizontaldivider.dds")
	return control, RdKGToolAdmin.config.configEntrySize * 2 + 10
end

function RdKGToolAdmin.CreateSubtitleControl(parent, title)
	local subtitleFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolAdmin.config.configEntrySize * 2 - 5, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	local control = wm:CreateControl(nil, parent, CT_CONTROL)
	control:SetDimensions(RdKGToolAdmin.config.configWidth, RdKGToolAdmin.config.configEntrySize * 2)
	
	control.title = wm:CreateControl(nil, control, CT_LABEL)
	control.title:SetAnchor(TOPLEFT, control, TOPLEFT, 5, 0)
	control.title:SetDimensions(RdKGToolAdmin.config.configWidth, RdKGToolAdmin.config.configEntrySize * 2 - 5)
	control.title:SetFont(subtitleFont)
	control.title:SetWrapMode(ELLIPSIS)
	control.title:SetColor(RdKGToolAdmin.config.color.subtitleColor.r, RdKGToolAdmin.config.color.subtitleColor.g, RdKGToolAdmin.config.color.subtitleColor.b)
	control.title:SetText(title)
	control.title:SetVerticalAlignment(TEXT_ALIGN_TOP)
	control.title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	
	
	control.texture = wm:CreateControl(nil, control, CT_TEXTURE)
	control.texture:SetAnchor(TOPLEFT, control, TOPLEFT, -100, RdKGToolAdmin.config.configEntrySize * 2 - 5) 
	control.texture:SetDimensions(800, 5) 
	control.texture:SetTexture("/esoui/art/miscellaneous/horizontaldivider.dds")
	return control, RdKGToolAdmin.config.configEntrySize * 2
end

function RdKGToolAdmin.CreateEquipmentControl(rootControl, equipment, index)
	local size = 0
	if equipment ~= nil then
		size = RdKGToolAdmin.config.configEntrySize * 4
		local infoSize = RdKGToolAdmin.config.configEntrySize * 3
		local infoWidth = RdKGToolAdmin.config.configWidth - size - 2 - 50
		local control = wm:CreateControl(nil, rootControl, CT_CONTROL)
		local controlFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolAdmin.config.configEntrySize - 2, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
		
		control:SetDimensions(RdKGToolAdmin.config.configWidth - 50, size)
		control.eType = equipment.eType
		control.defaultTexture = equipment.texture
		
		control.mainEdge = wm:CreateControl(nil, control, CT_BACKDROP)
		control.mainEdge:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
		control.mainEdge:SetDimensions(RdKGToolAdmin.config.configWidth - 50, size)
		control.mainEdge:SetEdgeTexture(nil, 2, 2, 2, 0)
		control.mainEdge:SetCenterColor(0, 0, 0, 0)
		control.mainEdge:SetEdgeColor(0, 0, 0, 1)
		
		control.imageEdge = wm:CreateControl(nil, control, CT_BACKDROP)
		control.imageEdge:SetAnchor(TOPLEFT, control, TOPLEFT, 6, 6)
		control.imageEdge:SetDimensions(size - 12, size - 12)
		control.imageEdge:SetEdgeTexture(nil, 2, 2, 2, 0)
		control.imageEdge:SetCenterColor(0, 0, 0, 0)
		control.imageEdge:SetEdgeColor(0, 0, 0, 1)
		
		control.textureBackdrop = wm:CreateControl(nil, control, CT_BACKDROP)
		control.textureBackdrop:SetAlpha(1)
		control.textureBackdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 7, 7)
		control.textureBackdrop:SetDimensions(size - 14, size - 14)
		control.textureBackdrop:SetCenterColor(RdKGToolAdmin.config.color.equipmentHover.r, RdKGToolAdmin.config.color.equipmentHover.g, RdKGToolAdmin.config.color.equipmentHover.b, 0.0)
		control.textureBackdrop:SetEdgeColor(RdKGToolAdmin.config.color.equipmentHover.r, RdKGToolAdmin.config.color.equipmentHover.g, RdKGToolAdmin.config.color.equipmentHover.b, 0.0)	
				
		control.texture = wm:CreateControl(nil, control, CT_TEXTURE)
		control.texture:SetAnchor(TOPLEFT, control, TOPLEFT, 7, 7) 
		control.texture:SetDimensions(size - 14, size - 14)
		control.texture:SetTexture(control.defaultTexture)
		
		control.button = wm:CreateControl(nil, control, CT_BUTTON)
		control.button:EnableMouseButton(MOUSE_BUTTON_INDEX_RIGHT, true)
		control.button:SetMouseEnabled(true)
		control.button:SetAnchor(TOPLEFT, control, TOPLEFT, 7, 7)
		control.button:SetDimensions(size - 14, size - 14)
		control.button:SetHandler("OnMouseEnter", function() RdKGToolAdmin.EquipmentEntryOnMouseEnter(index) end)
		control.button:SetHandler("OnMouseExit", function() RdKGToolAdmin.EquipmentEntryOnMouseExit(index) end)
		control.button:SetHandler("OnClicked", function() RdKGToolAdmin.EquipmentEntryOnClick(index) end)
				
		control.link = wm:CreateControl(nil, control, CT_LABEL)
		control.link:SetAnchor(TOPLEFT, control, TOPLEFT, 2 + (size - 4), 2) 
		control.link:SetDimensions(infoWidth, RdKGToolAdmin.config.configEntrySize)
		control.link:SetColor(RdKGToolAdmin.config.color.equipmentDescription.r, RdKGToolAdmin.config.color.equipmentDescription.g, RdKGToolAdmin.config.color.equipmentDescription.b)
		control.link:SetFont(controlFont)
		control.link:SetMouseEnabled(true)
		control.link.link = nil
		control.link:SetHandler('OnMouseEnter', function() RdKGToolAdmin.ShowItemLinkToolTip(control.link, control.link) end)
		control.link:SetHandler('OnMouseExit', function() ClearTooltip(ItemTooltip) end)
		
		control.infoWindow = wm:CreateControl(nil, rootControl, CT_CONTROL)
		control.infoWindow:SetAnchor(TOPLEFT, control, TOPLEFT, 2 + (size - 4), 2)
		control.infoWindow:SetDimensions(infoWidth, infoSize)
		
		control.infoWindow.line1 = wm:CreateControl(nil, control, CT_LABEL)
		control.infoWindow.line1:SetAnchor(TOPLEFT, control, TOPLEFT, 2 + (size - 4), 2 + RdKGToolAdmin.config.configEntrySize) 
		control.infoWindow.line1:SetDimensions(infoWidth, RdKGToolAdmin.config.configEntrySize)
		control.infoWindow.line1:SetColor(RdKGToolAdmin.config.color.equipmentDescription.r, RdKGToolAdmin.config.color.equipmentDescription.g, RdKGToolAdmin.config.color.equipmentDescription.b)
		control.infoWindow.line1:SetFont(controlFont)

		control.infoWindow.line2 = wm:CreateControl(nil, control, CT_LABEL)
		control.infoWindow.line2:SetAnchor(TOPLEFT, control, TOPLEFT, 2 + (size - 4), 2 + RdKGToolAdmin.config.configEntrySize * 2) 
		control.infoWindow.line2:SetDimensions(infoWidth, RdKGToolAdmin.config.configEntrySize * 2)
		control.infoWindow.line2:SetColor(RdKGToolAdmin.config.color.equipmentDescription.r, RdKGToolAdmin.config.color.equipmentDescription.g, RdKGToolAdmin.config.color.equipmentDescription.b)
		control.infoWindow.line2:SetFont(controlFont)
		
		return control, size
	end
	return nil, size
end

function RdKGToolAdmin.CreateCPBlock(parent, discipline, width)
	local cpNames = {}
	local size = RdKGToolAdmin.config.configEntrySize * 5.5
	local titleFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolAdmin.config.configEntrySize * 1.5 - 2, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	local controlFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolAdmin.config.configEntrySize - 6, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	
	local control = wm:CreateControl(nil, parent, CT_CONTROL)
	control:SetDimensions(width, size)
	
	control.title = wm:CreateControl(nil, control, CT_LABEL)
	control.title:SetAnchor(TOPLEFT, control, TOPLEFT, 2, 0) 
	control.title:SetDimensions(width, RdKGToolAdmin.config.configEntrySize * 1.5)
	control.title:SetFont(titleFont)
	control.title:SetText(discipline.text)
	
	control.cpEntries = {}
	control.cpValues = {}
	for i = 1, 4 do
		control.cpEntries[i] = wm:CreateControl(nil, control, CT_LABEL)
		control.cpEntries[i]:SetAnchor(TOPLEFT, control, TOPLEFT, 2, RdKGToolAdmin.config.configEntrySize * 1.5 + RdKGToolAdmin.config.configEntrySize * (i - 1))
		control.cpEntries[i]:SetDimensions(width, RdKGToolAdmin.config.configEntrySize)
		control.cpEntries[i]:SetColor(RdKGToolAdmin.config.color.cpText.r, RdKGToolAdmin.config.color.cpText.g, RdKGToolAdmin.config.color.cpText.b)
		control.cpEntries[i]:SetFont(controlFont)
		control.cpEntries[i]:SetText(discipline.cp[i].text)
		control.cpEntries[i]:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		control.cpEntries[i]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		
		control.cpValues[i] = wm:CreateControl(nil, control, CT_LABEL)
		control.cpValues[i]:SetAnchor(TOPLEFT, control, TOPLEFT, 2, RdKGToolAdmin.config.configEntrySize * 1.5 + RdKGToolAdmin.config.configEntrySize * (i - 1))
		control.cpValues[i]:SetDimensions(width - 10, RdKGToolAdmin.config.configEntrySize)
		control.cpValues[i]:SetColor(RdKGToolAdmin.config.color.cpValue.r, RdKGToolAdmin.config.color.cpValue.g, RdKGToolAdmin.config.color.cpValue.b)
		control.cpValues[i]:SetFont(controlFont)
		control.cpValues[i]:SetText("0")
		control.cpValues[i]:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		control.cpValues[i]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		
		cpNames[i] = {}
		cpNames[i].name = RdKGToolCP.GetCPControlName(discipline.id, i)
		cpNames[i].control = control.cpValues[i]
	end
	
	return control, cpNames, size
end

function RdKGToolAdmin.CreateSkillControl(parent, size)
	local control = wm:CreateControl(nil, parent, CT_CONTROL)
	control:SetDimensions(size, size)
	
	control.imageEdge = wm:CreateControl(nil, control, CT_BACKDROP)
	control.imageEdge:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.imageEdge:SetDimensions(size, size)
	control.imageEdge:SetEdgeTexture(nil, 2, 2, 2, 0)
	control.imageEdge:SetCenterColor(0, 0, 0, 0)
	control.imageEdge:SetEdgeColor(0, 0, 0, 1)
	
	control.texture = wm:CreateControl(nil, control, CT_TEXTURE)
	control.texture:SetAnchor(TOPLEFT, control, TOPLEFT, 1, 1) 
	control.texture:SetDimensions(size - 2, size - 2)
	control.texture:SetTexture("esoui/art/mainmenu/menubar_skills_disabled.dds")
	control.texture:SetMouseEnabled(true)
	control.id = 0
	control.texture:SetHandler('OnMouseEnter', function() RdKGToolAdmin.ShowSkillToolTip(control.texture) end)
	control.texture:SetHandler('OnMouseExit', function() ClearTooltip(SkillTooltip) end)
	
	return control
end

function RdKGToolAdmin.ShowSkillToolTip(control)
	--d("show tooltip")
	if control.id ~= nil and control.id ~= 0 then
		InitializeTooltip(SkillTooltip, control, TOPLEFT, -20, 0)
		local skillType, skillIndex, abilityIndex = GetSpecificSkillAbilityKeysByAbilityId(control.id)
		if skillType ~= 0 then
			SkillTooltip:SetSkillAbility(skillType, skillIndex, abilityIndex)
		else
			SkillTooltip:SetSkillLineAbilityId(control.id)
		end
	end
end


function RdKGToolAdmin.CreateSkillBarControl(parent)
	local size = RdKGToolAdmin.config.configEntrySize * 4
	local width = size * 6 + 30
	

	local control = wm:CreateControl(nil, parent, CT_CONTROL)
	control:SetDimensions(width, size)
	
	control.mainEdge = wm:CreateControl(nil, control, CT_BACKDROP)
	control.mainEdge:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.mainEdge:SetDimensions(width, size)
	control.mainEdge:SetEdgeTexture(nil, 2, 2, 2, 0)
	control.mainEdge:SetCenterColor(0, 0, 0, 0)
	control.mainEdge:SetEdgeColor(0, 0, 0, 1)
	
	local names = {}
	names[1] = "skill1"
	names[2] = "skill2"
	names[3] = "skill3"
	names[4] = "skill4"
	names[5] = "skill5"
	
	for i = 1, #names do
		control[names[i]] = RdKGToolAdmin.CreateSkillControl(control, size - 12)
		control[names[i]]:SetAnchor(TOPLEFT, control, TOPLEFT, 6 + ((i - 1) * size), 6)
	end
	control.ultimate = RdKGToolAdmin.CreateSkillControl(control, size - 12)
	control.ultimate:SetAnchor(TOPLEFT, control, TOPLEFT, 6 + 30 + 5 * size, 6)

	
	
	return control, size
end

function RdKGToolAdmin.AdjustPlayerList()
	local selectedEntry = nil
	if RdKGToolAdmin.state.selectedIndex ~= nil and RdKGToolAdmin.state.selectedIndex ~= 0 then
		if RdKGToolAdmin.state.playerList ~= nil and RdKGToolAdmin.state.playerList[RdKGToolAdmin.state.selectedIndex] ~= nil then
			selectedEntry = RdKGToolAdmin.state.playerList[RdKGToolAdmin.state.selectedIndex]
		end
	end
	local playerList = RdKGToolGroup.GetGroupInformation()
	RdKGToolAdmin.state.selectedIndex = 0
	RdKGToolAdmin.state.playerList = RdKGToolAdmin.state.playerList or {}
	RdKGToolAdmin.state.playerList[1] = {}
	RdKGToolAdmin.state.playerList[1].displayName = ""
	RdKGToolAdmin.state.playerList[1].charName = ""
	RdKGToolAdmin.state.playerList[1].unitTag = ""
	if playerList ~= nil then
		for i = 2, #playerList + 1 do
			RdKGToolAdmin.controls.TLW.player.blocks[i]:SetHidden(false)
			RdKGToolAdmin.controls.TLW.player.blocks[i]:SetText(playerList[i - 1].name)
			RdKGToolAdmin.PlayerEntryOnMouseExit(i)
			if selectedEntry ~= nil and selectedEntry.displayName == playerList[i - 1].displayName and selectedEntry.charName == playerList[i - 1].charName then
				RdKGToolAdmin.PlayerEntryOnClick(i)
			end
			RdKGToolAdmin.state.playerList[i] = {}
			RdKGToolAdmin.state.playerList[i].displayName = playerList[i - 1].displayName
			RdKGToolAdmin.state.playerList[i].charName = playerList[i - 1].charName
			RdKGToolAdmin.state.playerList[i].unitTag = playerList[i - 1].unitTag
		end
		for i = #playerList + 2, 25 do
			RdKGToolAdmin.controls.TLW.player.blocks[i]:SetHidden(true)
			RdKGToolAdmin.PlayerEntryOnMouseExit(i)
			RdKGToolAdmin.state.playerList[i] = nil
		end
	else
		for i = 2, 25 do
			RdKGToolAdmin.controls.TLW.player.blocks[i]:SetHidden(true)
			RdKGToolAdmin.PlayerEntryOnMouseExit(i)
			RdKGToolAdmin.state.playerList[i] = nil
		end
	end
end

function RdKGToolAdmin.LinkInChat(link)
	link = RdKGToolEquip.ChangeBrackets(link)
	if link ~= nil then
		local chat = CHAT_SYSTEM.textEntry.editControl
		if chat:HasFocus() == false then 
			StartChatInput() 
		end
		chat:InsertText(link)
	end
end

function RdKGToolAdmin.ShowItemLinkToolTip(linkControl, control)
	if control.link ~= nil and link ~= "" then
		InitializeTooltip(ItemTooltip, control, TOPLEFT, -468, 0)
		ItemTooltip:SetLink(linkControl.link)
	end
end

function RdKGToolAdmin.SlashCmd(param)
	if param ~= nil then
		if param[1] == "admin" then
			RdKGToolAdmin.ToggleAdminInterface()
		end
	end
end

function RdKGToolAdmin.CreatePlayerContextMenu(index)
	if index ~= nil and index >= 1 and index <= #RdKGToolAdmin.state.playerList then
		ClearMenu()

		AddCustomMenuItem(RdKGToolAdmin.constants.player.REQUEST_ALL, function() RdKGToolAdmin.RequestAll(index) end)
		AddCustomMenuItem(RdKGToolAdmin.constants.player.REQUEST_VERSION, function() RdKGToolAdmin.RequestVersion(index) end)
		AddCustomMenuItem(RdKGToolAdmin.constants.player.REQUEST_CLIENT_CONFIGURATION, function() RdKGToolAdmin.RequestClientConfiguration(index) end)
		AddCustomMenuItem(RdKGToolAdmin.constants.player.REQUEST_ADDON_CONFIGURATION, function() RdKGToolAdmin.RequestAddOnConfiguration(index) end)
		AddCustomMenuItem(RdKGToolAdmin.constants.player.REQUEST_STATS_INFORMATION, function() RdKGToolAdmin.RequestStatsInformation(index) end)
		AddCustomMenuItem(RdKGToolAdmin.constants.player.REQUEST_MUNDUS_INFORMATION, function() RdKGToolAdmin.RequestMundusInformation(index) end)
		AddCustomMenuItem(RdKGToolAdmin.constants.player.REQUEST_SKILLS_INFORMATION, function() RdKGToolAdmin.RequestSkillsInformation(index) end)
		AddCustomMenuItem(RdKGToolAdmin.constants.player.REQUEST_EQUIPMENT_INFORMATION, function() RdKGToolAdmin.RequestEquipmentInformation(index) end)
		AddCustomMenuItem(RdKGToolAdmin.constants.player.REQUEST_CHAMPION_INFORMATION, function() RdKGToolAdmin.RequestChampionInformation(index) end)
		--AddCustomMenuItem(RdKGToolAdmin.constants.player.REQUEST_QUICKSLOTS_INFORMATION, function() RdKGToolAdmin.RequestQuicksloInformation(index) end)
		
		ShowMenu(RdKGToolAdmin.controls.TLW.player.blocks[index])
	end
end

function RdKGToolAdmin.SendAdminRequest(b2, b3, index)
	if b2 ~= nil and b3 ~= nil and index ~= nil and index >= 1 and index <= #RdKGToolAdmin.state.playerList then
		local message = {}
		message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_REQUEST
		message.b1 = RdKGToolAdmin.GetSelectedPlayerId(index)
		message.b2 = b2
		message.b3 = b3
		message.sent = false

		RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	end
end

function RdKGToolAdmin.GetSelectedPlayerId(index)
	local id = 25
	local players = RdKGToolGroup.GetGroupInformation()
	if players ~= nil and index ~= nil then
		local player = players[index - 1]
		if player ~= nil then
			id = index - 1
		end
	end
	return id
end



function RdKGToolAdmin.RequestAll(index)
	RdKGToolAdmin.RequestVersion(index)
	RdKGToolGroup.RetrieveAdminMundusInformation(RdKGToolAdmin.GetSelectedPlayerId(index))
	RdKGToolAdmin.SendAdminRequest(255, 255, index)
end

function RdKGToolAdmin.RequestEquipmentItem(itemIndex, playerIndex)
	local entry = RdKGToolAdmin.constants.equipment[itemIndex]
	if entry ~= nil and entry.messagePrefix ~= nil then
		local message = {}
		message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_REQUEST_EQUIPMENT_INFORMATION
		message.b1 = RdKGToolAdmin.GetSelectedPlayerId(index)
		message.b2 = 0
		message.b3 = entry.messagePrefix
		message.sent = false
		
		RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	end
end

function RdKGToolAdmin.RequestVersion(index)
	if index ~= nil and index >= 1 and index <= #RdKGToolAdmin.state.playerList then
		if RdKGToolAdmin.state.playerList ~= nil and RdKGToolAdmin.state.playerList[index] ~= nil then
			--d("Requesting Version Information")
			RdKGToolVersioning.RequestVersionInformation(RdKGToolAdmin.state.playerList[index].unitTag)
		else
			RdKGToolVersioning.RequestVersionInformation(nil) --25
		end
	end
end

function RdKGToolAdmin.RequestClientConfiguration(index)
	RdKGToolAdmin.SendAdminRequest(RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_CLIENT_CONFIGURATION, 0, index)
end

function RdKGToolAdmin.RequestAddOnConfiguration(index)
	RdKGToolAdmin.SendAdminRequest(RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_ADDON_CONFIGURATION, 0, index)
end

function RdKGToolAdmin.RequestEquipmentInformation(index)
	RdKGToolAdmin.SendAdminRequest(RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_EQUIPMENT_INFORMATION, 0, index)
end

function RdKGToolAdmin.RequestChampionInformation(index)
	RdKGToolAdmin.SendAdminRequest(RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_CHAMPION_INFORMATION, 0, index)
end

function RdKGToolAdmin.RequestStatsInformation(index)
	--d("requesting stats for " .. index)
	RdKGToolAdmin.SendAdminRequest(RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_STATS_INFORMATION, 0, index)
end

function RdKGToolAdmin.RequestMundusInformation(index)
	RdKGToolGroup.RetrieveAdminMundusInformation(RdKGToolAdmin.GetSelectedPlayerId(index))
end

function RdKGToolAdmin.RequestSkillsInformation(index)
	RdKGToolAdmin.SendAdminRequest(RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_SKILLS_INFORMATION, 0, index)
end

function RdKGToolAdmin.RequestQuicksloInformation(index)
	RdKGToolAdmin.SendAdminRequest(RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_QUICKSLOT_INFORMATION, 0, index)
end

function RdKGToolAdmin.HandleAdminClientConfigurationRequest(senderTag)
	if RdKGToolAdmin.adminVars.enabled == false then
		if RdKGToolRoster.IsRdKMember(GetUnitDisplayName("player")) == true and RdKGToolRoster.IsRdKAdmin(GetUnitDisplayName(senderTag)) then
		else
			return
		end
	end
	--d("Client Configuration Requested")
	--AOE Configuration
	local cvarTellsEnabled = tonumber(GetCVar("MonsterTellsEnabled"))
	local cvarCustomEnabled = tonumber(GetCVar("MonsterTellsColorSwapEnabled"))
	local cvarEnemyBrightness = tonumber(string.format("%d",GetCVar("MonsterTellsEnemyBrightness")))
	local cvarFriendlyBrightness = tonumber(string.format("%d",GetCVar("MonsterTellsFriendlyBrightness")))
	local cvarB2 = cvarEnemyBrightness
	local cvarB3 = RdKGToolMath.DecodeBitArrayHelper(cvarFriendlyBrightness)
	cvarB3[7] = cvarTellsEnabled
	cvarB3[8] = cvarCustomEnabled
	cvarB3 = RdKGToolMath.EncodeBitArrayHelper(cvarB3, 0)
	local message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CLIENT_CONFIGURATION_AOE
	message.b1 = 0
	message.b2 = cvarB2
	message.b3 = cvarB3
	message.sent = false
	
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	--Sound Configuration
	local cvarSoundEnable = tonumber(GetCVar("SOUND_ENABLED"))
	local cvarAudioVolume = tonumber(string.format("%d",GetCVar("AUDIO_VOLUME")))
	local cvarUiVolume = tonumber(string.format("%d",GetCVar("UI_VOLUME")))
	local cvarSfxVolume = tonumber(string.format("%d",GetCVar("SFX_VOLUME")))
	local cvarB1 = RdKGToolMath.DecodeBitArrayHelper(cvarAudioVolume)
	cvarB1[8] = cvarSoundEnable
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CLIENT_CONFIGURATION_SOUND
	message.b1 = RdKGToolMath.EncodeBitArrayHelper(cvarB1, 0)
	message.b2 = cvarUiVolume
	message.b3 = cvarSfxVolume
	message.sent = false
	--d(message)
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	
	--Graphics Configuration
	local windowMode = RdKGToolMath.DecodeBitArrayHelper(tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_FULLSCREEN))) --2bit
	local vsync = tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_VSYNC)) --1bit
	local antiAliasing = tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_ANTI_ALIASING)) --1bit
	local ambient = tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_AMBIENT_OCCLUSION)) --1bit
	local bloom = tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_BLOOM)) --1bit
	local depthOfField = tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_DEPTH_OF_FIELD)) --1bit
	local distortion = tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_DISTORTION)) --1bit
	local sunlight = tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_GOD_RAYS)) --1bit
	local allyEffects = tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_SHOW_ADDITIONAL_ALLY_EFFECTS)) --1bit
	local viewDistance = RdKGToolMath.Int24ToArray(tonumber(string.format("%d",(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_VIEW_DISTANCE) * 50)))) --7bit
	local resWidth, resHeight = zo_strsplit("x", GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_RESOLUTION)) --2x 18bit
	resWidth = RdKGToolMath.Int24ToArray(tonumber(resWidth))
	resHeight = RdKGToolMath.Int24ToArray(tonumber(resHeight))
	local particleSupressDistance = RdKGToolMath.DecodeBitArrayHelper(tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_PFX_SUPPRESS_DISTANCE))) --7bit
	local particleMaximum = RdKGToolMath.Int24ToArray(tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_PFX_GLOBAL_MAXIMUM) - 768)) --11bit
	local reflectionQuality = RdKGToolMath.DecodeBitArrayHelper(tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_REFLECTION_QUALITY))) --2bit -- Water Reflection
	local shadowQuality = RdKGToolMath.DecodeBitArrayHelper(tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_SHADOWS))) --3bit
	local subSamplingQuality = RdKGToolMath.DecodeBitArrayHelper(tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_SUB_SAMPLING))) --2bit
	local graphicPresets = RdKGToolMath.DecodeBitArrayHelper(tonumber(GetSetting(SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_PRESETS))) --3bit
	
	--81bit => ~4 Messages 
	--Message #1 width (18)
	--Message #2 height (18)
	--Message #3 particleMax (11) + particleSupress (7)
	--Message #4 viewDistance (7) + quality (10)
	
	--message 1
	local messageIdentifier = RdKGToolMath.DecodeBitArrayHelper(RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_1)
	local bitfield = resWidth
	bitfield = RdKGToolMath.CopyBitfieldRange(messageIdentifier, bitfield, 3, 1, 22)
	bitfield[19] = windowMode[1]
	bitfield[20] = windowMode[2]
	bitfield[21] = vsync
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CLIENT_CONFIGURATION_GRAPHICS
	message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
	message.sent = false
	
	--d(bitfield)
	--d(message)
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	--message 2
	messageIdentifier = RdKGToolMath.DecodeBitArrayHelper(RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_2)
	bitfield = resHeight
	bitfield = RdKGToolMath.CopyBitfieldRange(messageIdentifier, bitfield, 3, 1, 22)
	bitfield[19] = antiAliasing
	bitfield[20] = ambient
	bitfield[21] = bloom
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CLIENT_CONFIGURATION_GRAPHICS
	message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
	message.sent = false
	
	--d(bitfield)
	--d(message)
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	--message 3
	messageIdentifier = RdKGToolMath.DecodeBitArrayHelper(RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_3)
	bitfield = particleMaximum
	bitfield = RdKGToolMath.CopyBitfieldRange(messageIdentifier, bitfield, 3, 1, 22)
	bitfield = RdKGToolMath.CopyBitfieldRange(particleSupressDistance, bitfield, 7, 1, 12)
	bitfield[19] = depthOfField
	bitfield[20] = distortion
	bitfield[21] = sunlight
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CLIENT_CONFIGURATION_GRAPHICS
	message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
	message.sent = false
	
	--d(bitfield)
	--d(message)
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	--message 4
	messageIdentifier = RdKGToolMath.DecodeBitArrayHelper(RdKGToolNetworking.messageIdentifiers.adminResponse.graphics.MESSAGE_4)
	bitfield = viewDistance
	bitfield = RdKGToolMath.CopyBitfieldRange(messageIdentifier, bitfield, 3, 1, 22)
	bitfield = RdKGToolMath.CopyBitfieldRange(reflectionQuality, bitfield, 2, 1, 8)
	bitfield = RdKGToolMath.CopyBitfieldRange(shadowQuality, bitfield, 3, 1, 10)
	bitfield = RdKGToolMath.CopyBitfieldRange(reflectionQuality, bitfield, 2, 1, 13)
	bitfield = RdKGToolMath.CopyBitfieldRange(graphicPresets, bitfield, 3, 1, 15)
	bitfield[18] = allyEffects
	bitfield[19] = subSamplingQuality[1]
	bitfield[20] = subSamplingQuality[2]
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CLIENT_CONFIGURATION_GRAPHICS
	message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
	message.sent = false
	
	--d(bitfield)
	--d(message)
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)	
end

function RdKGToolAdmin.HandleAdminAddonConfigurationRequest(senderTag)
	if RdKGToolAdmin.adminVars.enabled == false then
		if RdKGToolRoster.IsRdKMember(GetUnitDisplayName("player")) == true and RdKGToolRoster.IsRdKAdmin(GetUnitDisplayName(senderTag)) then
		else
			return
		end
	end
	--d("Addon Configuration Requested")
	--Crown / debuff overview / rapid tracker / health, damage overview / potion overview
	local crownEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.crown.enabled) -- 1bit
	local crownSize = RdKGToolMath.Int24ToArray(RdKGToolAdmin.vars.group.crown.size) --10bit
	local selectedCrown = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.group.crown.selectedCrown) --5bit
	
	local debuffOverviewEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.dbo.enabled) --1bit
	local rapidTrackerEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.rt.enabled) --1bit
	local hdmEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.hdm.enabled) --1bit
	local hdmWindowEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.hdm.windowEnabled) --1bit
	local hdmViewMode = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.group.hdm.viewMode) --2bit
	local poEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.po.enabled) --1bit
	local poSoundEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.po.soundEnabled) --1bit
	
	--d(crownSize)
	
	local bitfield = RdKGToolMath.CreateEmptyBitfield(24)
	bitfield = RdKGToolMath.CopyBitfieldRange(crownSize, bitfield, 10, 1, 9)
	bitfield = RdKGToolMath.CopyBitfieldRange(selectedCrown, bitfield, 5, 1, 19)
	bitfield[24] = crownEnabled
	bitfield[1] = hdmViewMode[1]
	bitfield[2] = hdmViewMode[2]
	bitfield[3] = hdmWindowEnabled
	bitfield[4] = hdmEnabled
	bitfield[5] = debuffOverviewEnabled
	bitfield[6] = rapidTrackerEnabled
	bitfield[7] = poSoundEnabled
	bitfield[8] = poEnabled
	
	
	local message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_1
	message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
	message.sent = false
	
	--d(message)
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	--ftcv pt.1
	local ftcvEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.ftcv.enabled) --1bit
	local ftcvMinDistance = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.group.ftcv.minDistance) --3bit
	local ftcvMaxDistance = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.group.ftcv.maxDistance) --5bit
	local ftcvSizeClose = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.group.ftcv.size.close) --7bit
	local ftcvSizeFar = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.group.ftcv.size.far) --7bit
	
	bitfield = RdKGToolMath.CreateEmptyBitfield(24)
	bitfield = RdKGToolMath.CopyBitfieldRange(ftcvMinDistance, bitfield, 3, 1, 22)
	bitfield = RdKGToolMath.CopyBitfieldRange(ftcvMaxDistance, bitfield, 5, 1, 17)
	bitfield = RdKGToolMath.CopyBitfieldRange(ftcvSizeClose, bitfield, 7, 1, 9)
	bitfield = RdKGToolMath.CopyBitfieldRange(ftcvSizeFar, bitfield, 7, 1, 1)
	bitfield[8] = ftcvEnabled
	
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_2
	message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
	message.sent = false
	
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	
	--ftcv pt.2 / ftcw
	local ftcvOpacityFar = RdKGToolAdmin.vars.group.ftcv.opacity.far --7bit
	local ftcvOpacityClose = RdKGToolAdmin.vars.group.ftcv.opacity.close --7bit
	
	local ftcwEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.ftcw.enabled) --1bit
	local ftcwDistanceEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.ftcw.distanceEnabled) --1bit
	local ftcwWarningsEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.ftcw.warningsEnabled) --1bit
	local ftcwMaxDistance = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.group.ftcw.maxDistance) --5bit
	
	bitfield = ftcwMaxDistance
	bitfield[6] = ftcwWarningsEnabled
	bitfield[7] = ftcwDistanceEnabled
	bitfield[8] = ftcwEnabled
	
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_3
	message.b1 = ftcvOpacityFar
	message.b2 = ftcvOpacityClose
	message.b3 = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
	message.sent = false
	
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	
	--ftca
	local ftcaEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.ftca.enabled) --1bit
	local ftcaMaxDistance =  RdKGToolAdmin.vars.group.ftca.maxDistance --5bit
	local ftcaInterval = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.group.ftca.interval) --4bit
	local ftcaThreshold = RdKGToolAdmin.vars.group.ftca.threshold --5bit
	
	bitfield = ftcaInterval
	bitfield[8] = ftcaEnabled
	
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_4
	message.b1 = ftcaMaxDistance
	message.b2 = ftcaThreshold
	message.b3 = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
	message.sent = false
	
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	
	
	
	--Resource Overview pt.1 
	local roEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.ro.enabled) --1bit
	local roUltimateOverviewEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.ro.ultimateOverviewSettings.enabled) --1bit
	local roClientUltimateEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.ro.clientUltimateSettings.enabled) --1bit
	local roGroupUltimatesEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.ro.groupUltimatesSettings.enabled) --1bit
	local roShowSoftResources = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.ro.showSoftResources) --1bit
	local roSoundEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.ro.soundEnabled) --1bit
	local roGroupSizeDestro = RdKGToolAdmin.vars.group.ro.ultimates.groupSizeDestro --5bit
	local roGroupSizeStorm = RdKGToolAdmin.vars.group.ro.ultimates.groupSizeStorm --5bit
	
	bitfield = RdKGToolMath.CreateEmptyBitfield(8)
	bitfield[1] = roEnabled
	bitfield[2] = roUltimateOverviewEnabled
	bitfield[3] = roClientUltimateEnabled
	bitfield[4] = roGroupUltimatesEnabled
	bitfield[5] = roShowSoftResources
	bitfield[6] = roSoundEnabled
		
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_5
	message.b1 = roGroupSizeDestro
	message.b2 = roGroupSizeStorm
	message.b3 = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
	message.sent = false
	
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	
	--Resource Overview pt.2 
	local roGroupSizeNegate = RdKGToolAdmin.vars.group.ro.ultimates.groupSizeNegate --5bit
	local roGroupSizeNova = RdKGToolAdmin.vars.group.ro.ultimates.groupSizeNova --5bit
	local roGroupMaxDistance = RdKGToolAdmin.vars.group.ro.ultimates.maxDistance --5bit
	
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_6
	message.b1 = roGroupSizeNegate
	message.b2 = roGroupSizeNova
	message.b3 = roGroupMaxDistance
	message.sent = false
	
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	--yacs, bft, kc, recharger, sm
	local yacsEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.compass.yacs.enabled) --1bit
	local yacsPvpEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.compass.yacs.pvpEnabled) --1bit
	local yacsCombatEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.compass.yacs.combatEnabled) --1bit
	local bftEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.bft.enabled) --1bit
	local bftSoundEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.bft.soundEnabled) --1bit
	local bftSize = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.toolbox.bft.size) --6bit
	local kcEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.kc.enabled) --1bit
	local rechargerEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.recharger.enabled) --1bit
	local smEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sm.enabled) --1bit
	local dtEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.dt.enabled) --1bit
	local clEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.cl.enabled) --1bit
	local csEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.cs.enabled) --1bit
	local gbEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.gb.enabled) --1bit
	local isdpEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.isdp.enabled) --1bit
	local respawnerEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.respawner.enabled) --1bit
	local campEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.camp.enabled) --1bit
	local spEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.enabled) --1bit
	local spMode = RdKGToolAdmin.vars.toolbox.sp.mode - 1--1bit
	local soEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.so.enabled) --1bit

	bitfield = RdKGToolMath.CreateEmptyBitfield(24)
	bitfield = RdKGToolMath.CopyBitfieldRange(bftSize, bitfield, 6, 1, 1)
	bitfield[7] = bftSoundEnabled
	bitfield[8] = bftEnabled
	bitfield[9] = yacsCombatEnabled
	bitfield[10] = yacsPvpEnabled
	bitfield[11] = yacsEnabled
	bitfield[12] = kcEnabled
	bitfield[13] = rechargerEnabled
	bitfield[14] = smEnabled
	bitfield[15] = dtEnabled
	bitfield[16] = clEnabled
	bitfield[17] = csEnabled
	bitfield[18] = gbEnabled
	bitfield[19] = isdpEnabled
	bitfield[20] = respawnerEnabled
	bitfield[21] = campEnabled
	bitfield[22] = spEnabled
	bitfield[23] = spMode
	bitfield[24] = soEnabled
	
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_7
	message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
	message.sent = false
	
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	--ftcb / ra / caj
	local ftcbEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.ftcb.enabled) --1bit
	local ftcbColor = tonumber(string.format("%d",RdKGToolAdmin.vars.group.ftcb.color.a * 255)) --8bit
	local ftcbSelectedBeam = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.group.ftcb.selectedTexture)--4bit
	local raEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.ra.enabled) --1bit
	local raAllowOverride = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.ra.allowOverride) --1bit
	local cajEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.caj.enabled) --1bit
	
		
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_8
	message.b1 = RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_1
	message.b2 = ftcbColor
	ftcbSelectedBeam[5] = raEnabled
	ftcbSelectedBeam[6] = raAllowOverride
	ftcbSelectedBeam[7] = cajEnabled
	ftcbSelectedBeam[8] = ftcbEnabled
	message.b3 = RdKGToolMath.EncodeBitArrayHelper(ftcbSelectedBeam, 0)
	message.sent = false
	
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	-- crBgTp, sc, Resource Overview pt.3
	local crBgTpEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.charVars.crBgTp.enabled) --1bit
	local scEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.compass.sc.enabled) --1bit
	local roGroupSizeNegateOffensive = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.group.ro.ultimates.groupSizeNegateOffensive) --5bit
	local roGroupSizeNegateCounter = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.group.ro.ultimates.groupSizeNegateCounter) --5bit
	local roGroupsEnabled = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.group.ro.groups.enabled) --1bit
	
	bitfield = RdKGToolMath.CreateEmptyBitfield(8)
	bitfield[1] = crBgTpEnabled
	bitfield[2] = scEnabled
	bitfield[3] = roGroupSizeNegateOffensive[1]
	bitfield[4] = roGroupSizeNegateOffensive[2]
	bitfield[5] = roGroupSizeNegateOffensive[3]
	bitfield[6] = roGroupSizeNegateOffensive[4]
	bitfield[7] = roGroupSizeNegateOffensive[5]
	bitfield[8] = roGroupsEnabled
	
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_8
	message.b1 = RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_2
	message.b2 = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
	bitfield = roGroupSizeNegateCounter
	bitfield[6] = 0
	bitfield[7] = 0
	bitfield[8] = 0
	message.b3 = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
	message.sent = false
	
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	--Resource Overview pt.4, so modes (pt2)
	local roGroupSizeNorthernStorm = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.group.ro.ultimates.groupSizeNorthernStorm) --5bit
	local roGroupSizePermafrost = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.group.ro.ultimates.groupSizePermafrost) --5bit
	local soDisplayMode = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.toolbox.so.displayMode - 1) --3bit
	local soTableMode = RdKGToolMath.DecodeBitArrayHelper(RdKGToolAdmin.vars.toolbox.so.tableMode - 1) --3bit
	
	bitfield = roGroupSizeNorthernStorm
	bitfield[6] = soDisplayMode[1]
	bitfield[7] = soDisplayMode[2]
	bitfield[8] = soDisplayMode[3]
	
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_8
	message.b1 = RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_3
	message.b2 = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
	bitfield = roGroupSizePermafrost
	bitfield[6] = soTableMode[1]
	bitfield[7] = soTableMode[2]
	bitfield[8] = soTableMode[3]
	message.b3 = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
	message.sent = false
	
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	--sp pt.2
	message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_ADDON_CONFIGURATION_8
	message.b1 = RdKGToolNetworking.messageIdentifiers.adminResponse.admin.MESSAGE_4
	
	bitfield = RdKGToolMath.CreateEmptyBitfield(8)
	bitfield[1] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.COMBUSTION_SHARD]) --1bit
	bitfield[2] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.TALONS]) --1bit
	bitfield[3] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.NOVA]) --1bit
	bitfield[4] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.BLOOD_ALTAR]) --1bit
	bitfield[5] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.STANDARD]) --1bit
	bitfield[6] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.PURGE]) --1bit
	bitfield[7] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.BONE_SHIELD]) --1bit
	bitfield[8] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.FLOOD_CONDUIT]) --1bit
	message.b2 = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
	bitfield = RdKGToolMath.CreateEmptyBitfield(8)
	bitfield[1] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.ATRONACH]) --1bit
	bitfield[2] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.TRAPPING_WEBS]) --1bit
	bitfield[3] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.RADIATE]) --1bit
	bitfield[4] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.CONSUMING_DARKNESS]) --1bit
	bitfield[5] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.SOUL_LEECH]) --1bit
	bitfield[6] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.WARDEN_HEALING]) --1bit
	bitfield[7] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.GRAVE_ROBBER]) --1bit
	bitfield[8] = RdKGToolMath.BooleanToBit(RdKGToolAdmin.vars.toolbox.sp.blacklist[RdKGToolSP.constants.SYNERGY_ID.PURE_AGONY]) --1bit
	message.b3 = RdKGToolMath.EncodeBitArrayHelper(bitfield, 0)
	message.sent = false
	
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
end

function RdKGToolAdmin.SendEquipmentInformationResponse(messagePrefix, slotId, senderTag)
	if RdKGToolAdmin.adminVars.enabled == false then
		if RdKGToolRoster.IsRdKMember(GetUnitDisplayName("player")) == true and RdKGToolRoster.IsRdKAdmin(GetUnitDisplayName(senderTag)) then
		else
			return
		end
	end
	if messagePrefix ~= nil and slotId ~= nil then
		local link = GetItemLink(BAG_WORN, slotId)
		local bitfield = RdKGToolMath.CreateEmptyBitfield(24)
		local messagePrefix = RdKGToolMath.DecodeBitArrayHelper(messagePrefix)
		bitfield = RdKGToolMath.CopyBitfieldRange(messagePrefix, bitfield, 4, 1, 21)
		if link ~= nil and link ~= "" then
			local value = GetItemLinkItemId(link)
			value = RdKGToolMath.Int24ToArray(value)
			bitfield = RdKGToolMath.CopyBitfieldRange(value, bitfield, 20, 1, 1)
		end
		
		local message = {}
		message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_1
		message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
		message.sent = false
		
		RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
		
		bitfield = RdKGToolMath.CreateEmptyBitfield(24)
		bitfield = RdKGToolMath.CopyBitfieldRange(messagePrefix, bitfield, 4, 1, 21)
		if link ~= nil and link ~= "" then
			local value = RdKGToolEquip.GetItemLinkEnchantmentId(link)
			value = RdKGToolMath.Int24ToArray(value)
			bitfield = RdKGToolMath.CopyBitfieldRange(value, bitfield, 20, 1, 1)
		end
		
		local message = {}
		message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_2
		message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
		message.sent = false
		
		RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
		
		bitfield = RdKGToolMath.CreateEmptyBitfield(24)
		bitfield = RdKGToolMath.CopyBitfieldRange(messagePrefix, bitfield, 4, 1, 21)
		if link ~= nil and link ~= "" then
			local value = RdKGToolEquip.GetItemLinkItemQuality(link)
			value = RdKGToolMath.Int24ToArray(value)
			bitfield = RdKGToolMath.CopyBitfieldRange(value, bitfield, 10, 1, 1)
			value = RdKGToolEquip.GetItemLinkEnchantmentQuality(link)
			value = RdKGToolMath.Int24ToArray(value)
			bitfield = RdKGToolMath.CopyBitfieldRange(value, bitfield, 10, 1, 11)
		end
		
		local message = {}
		message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_3
		message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
		message.sent = false
		
		RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
		
		bitfield = RdKGToolMath.CreateEmptyBitfield(24)
		bitfield = RdKGToolMath.CopyBitfieldRange(messagePrefix, bitfield, 4, 1, 21)
		if link ~= nil and link ~= "" then
			local value = RdKGToolEquip.GetItemLinkItemLevel(link)
			value = RdKGToolMath.Int24ToArray(value)
			bitfield = RdKGToolMath.CopyBitfieldRange(value, bitfield, 10, 1, 1)
			value = RdKGToolEquip.GetItemLinkEnchantmentLevel(link)
			value = RdKGToolMath.Int24ToArray(value)
			bitfield = RdKGToolMath.CopyBitfieldRange(value, bitfield, 10, 1, 11)
		end
		
		local message = {}
		message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_4
		message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
		message.sent = false
		
		RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
		
		bitfield = RdKGToolMath.CreateEmptyBitfield(24)
		bitfield = RdKGToolMath.CopyBitfieldRange(messagePrefix, bitfield, 4, 1, 21)
		if link ~= nil and link ~= "" then
			local value = RdKGToolEquip.GetItemLinkTransmutationId(link)
			value = RdKGToolMath.Int24ToArray(value)
			bitfield = RdKGToolMath.CopyBitfieldRange(value, bitfield, 10, 1, 1)
			value = RdKGToolEquip.GetItemLinkStyleId(link)
			value = RdKGToolMath.Int24ToArray(value)
			bitfield = RdKGToolMath.CopyBitfieldRange(value, bitfield, 10, 1, 11)
		end
		
		local message = {}
		message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_EQUIPMENT_INFORMATION_5
		message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
		message.sent = false
		
		RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	end
end

function RdKGToolAdmin.HandleAdminEquipmentInformationRequest(senderTag)
	--armor
	--[[
	--Networking
	--Armor
	idemId: 524288 --20bit
	quality (inc cp): 512 --10bit
	level: 64 --7bit
	entchantment: 524288 --20bit
	quality (inc cp): 512 --10bit
	level: 64 --7bit
	transmutation: 64 --7bit
	--irrelevant stats
	boud: 2
	style: 128
	crafted: 2
	redBorder: 2
	itemHealth: 16384
	
	4 messages
	00000000 00000000 00000000 00000000
	[MESSAGE_TYPE:8bit] [PACKET_ID:4bit] [MESSAGE:20bit]
	MESSAGE_1: [itemid] itemId
	MESSAGE_2: [itemid] enchantmentId
	MESSAGE_3: [itemid] quality | quality
	MESSAGE_4: [itemid] level | level
	MESSAGE_5: [itemid] transmutation
	
	|H1:item:100269:363:50:26588:370:50:0:0:0:0:0:0:0:0:1:5:0:1:0:3040:0|h|h
	]]
	--head, message 1
	for i = 1, #RdKGToolAdmin.constants.equipment do
		RdKGToolAdmin.SendEquipmentInformationResponse(RdKGToolAdmin.constants.equipment[i].messagePrefix, RdKGToolAdmin.constants.equipment[i].slotId, senderTag)
	end
end

function RdKGToolAdmin.HandleAdminChampionInformationRequest(senderTag)
	if RdKGToolAdmin.adminVars.enabled == false then
		if RdKGToolRoster.IsRdKMember(GetUnitDisplayName("player")) == true and RdKGToolRoster.IsRdKAdmin(GetUnitDisplayName(senderTag)) then
		else
			return
		end
	end
	for i = 1, #RdKGToolAdmin.constants.cpDisciplines do
		local prefix, index = RdKGToolCP.GetPrefixAndIndex(RdKGToolAdmin.constants.cpDisciplines[i].id, 1)		
		
		local message = {}
		message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CHAMPION_INFORMATION
		message.b1 = prefix
		message.b2 = GetNumPointsSpentOnChampionSkill(RdKGToolAdmin.constants.cpDisciplines[i].id, 1)
		message.b3 = GetNumPointsSpentOnChampionSkill(RdKGToolAdmin.constants.cpDisciplines[i].id, 2)
		message.sent = false
		
		RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
		
		prefix, index = RdKGToolCP.GetPrefixAndIndex(RdKGToolAdmin.constants.cpDisciplines[i].id, 3)
		message = {}
		message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_CHAMPION_INFORMATION
		message.b1 = prefix
		message.b2 = GetNumPointsSpentOnChampionSkill(RdKGToolAdmin.constants.cpDisciplines[i].id, 3)
		message.b3 = GetNumPointsSpentOnChampionSkill(RdKGToolAdmin.constants.cpDisciplines[i].id, 4)
		message.sent = false
		
		RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
		
	end
end

function RdKGToolAdmin.SendSimpleStatsInformationResponse(prefix, value)
	local bitfield = RdKGToolMath.CreateEmptyBitfield(24)
	bitfield = RdKGToolMath.CopyBitfieldRange(RdKGToolMath.Int24ToArray(value), bitfield, 20, 1, 1)
	bitfield = RdKGToolMath.CopyBitfieldRange(RdKGToolMath.DecodeBitArrayHelper(prefix), bitfield, 4, 1, 21)
	local message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_STATS_INFORMATION
	message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
	message.sent = false
	--d(message)
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
end

function RdKGToolAdmin.HandleAdminStatsInformationRequest(senderTag)
	if RdKGToolAdmin.adminVars.enabled == false then
		if RdKGToolRoster.IsRdKMember(GetUnitDisplayName("player")) == true and RdKGToolRoster.IsRdKAdmin(GetUnitDisplayName(senderTag)) then
		else
			return
		end
	end
	local magicka = GetPlayerStat(STAT_MAGICKA_MAX, STAT_BONUS_OPTION_APPLY_BONUS) --17bit
	local health = GetPlayerStat(STAT_HEALTH_MAX, STAT_BONUS_OPTION_APPLY_BONUS) --17bit
	local stamina = GetPlayerStat(STAT_STAMINA_MAX, STAT_BONUS_OPTION_APPLY_BONUS) --17bit
	local magickaRecovery = GetPlayerStat(STAT_MAGICKA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS) --14bit
	local healthRecovery = GetPlayerStat(STAT_HEALTH_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS) --14bit
	local staminaRecovery = GetPlayerStat(STAT_STAMINA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS) --14bit
	
	local spellDamage = GetPlayerStat(STAT_SPELL_POWER, STAT_BONUS_OPTION_APPLY_BONUS) --14bit
	local weaponDamage = GetPlayerStat(STAT_POWER, STAT_BONUS_OPTION_APPLY_BONUS) --14bit
	local spellPenetration = GetPlayerStat(STAT_SPELL_PENETRATION, STAT_BONUS_OPTION_APPLY_BONUS) --16bit
	local weaponPenetration = GetPlayerStat(STAT_PHYSICAL_PENETRATION, STAT_BONUS_OPTION_APPLY_BONUS) --16bit
	local spellCritical = tonumber(string.format("%.1f", GetCriticalStrikeChance(GetPlayerStat(STAT_SPELL_CRITICAL, STAT_BONUS_OPTION_APPLY_BONUS)))) * 10 --10bit
	local weaponCritical = tonumber(string.format("%.1f", GetCriticalStrikeChance(GetPlayerStat(STAT_CRITICAL_STRIKE, STAT_BONUS_OPTION_APPLY_BONUS)))) * 10 --10bit
	
	local spellResistance = GetPlayerStat(STAT_SPELL_RESIST, STAT_BONUS_OPTION_APPLY_BONUS) --16bit
	local physicalResistance = GetPlayerStat(STAT_PHYSICAL_RESIST, STAT_BONUS_OPTION_APPLY_BONUS) --16bit
	local criticalResistance = GetPlayerStat(STAT_CRITICAL_RESISTANCE, STAT_BONUS_OPTION_APPLY_BONUS) --13bit
	
	--
	
	RdKGToolAdmin.SendSimpleStatsInformationResponse(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_MAGICKA, magicka)
	RdKGToolAdmin.SendSimpleStatsInformationResponse(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_HEALTH, health)
	RdKGToolAdmin.SendSimpleStatsInformationResponse(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_STAMINA, stamina)
	RdKGToolAdmin.SendSimpleStatsInformationResponse(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_MAGICKA_RECOVERY, magickaRecovery)
	RdKGToolAdmin.SendSimpleStatsInformationResponse(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_HEALTH_RECOVERY, healthRecovery)
	RdKGToolAdmin.SendSimpleStatsInformationResponse(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_STAMINA_RECOVERY, staminaRecovery)
	RdKGToolAdmin.SendSimpleStatsInformationResponse(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_SPELL_DAMAGE, spellDamage)
	RdKGToolAdmin.SendSimpleStatsInformationResponse(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_WEAPON_DAMAGE, weaponDamage)
	RdKGToolAdmin.SendSimpleStatsInformationResponse(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_SPELL_PENETRATION, spellPenetration)
	RdKGToolAdmin.SendSimpleStatsInformationResponse(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_WEAPON_PENETRATION, weaponPenetration)
	
	local bitfield = RdKGToolMath.CreateEmptyBitfield(24)
	bitfield = RdKGToolMath.CopyBitfieldRange(RdKGToolMath.Int24ToArray(spellCritical), bitfield, 10, 1, 1)
	bitfield = RdKGToolMath.CopyBitfieldRange(RdKGToolMath.Int24ToArray(weaponCritical), bitfield, 10, 1, 11)
	bitfield = RdKGToolMath.CopyBitfieldRange(RdKGToolMath.DecodeBitArrayHelper(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_CRITICAL), bitfield, 4, 1, 21)
	local message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_STATS_INFORMATION
	message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
	message.sent = false
		
	RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	
	RdKGToolAdmin.SendSimpleStatsInformationResponse(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_SPELL_RESISTANCE, spellResistance)
	RdKGToolAdmin.SendSimpleStatsInformationResponse(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_PHYSICAL_RESISTANCE, physicalResistance)
	RdKGToolAdmin.SendSimpleStatsInformationResponse(RdKGToolNetworking.messageIdentifiers.adminResponse.stats.MESSAGE_CRITICAL_RESISTANCE, criticalResistance)

end

function RdKGToolAdmin.SendAdminSkillsInformationResponse(prefix, value)
	if prefix ~= nil and value ~= nil then
		local bitfield = RdKGToolMath.CreateEmptyBitfield(24)
		bitfield = RdKGToolMath.CopyBitfieldRange(RdKGToolMath.Int24ToArray(prefix), bitfield, 4, 1, 21)
		bitfield = RdKGToolMath.CopyBitfieldRange(RdKGToolMath.Int24ToArray(value), bitfield, 20, 1, 1)
		local message = {}
		message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_RESPONSE_SKILLS_INFORMATION
		message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(bitfield)
		message.sent = false
			
		RdKGToolNetworking.SendAdminMessage(message, RdKGToolNetworking.constants.priorities.HIGH)
	end
end

function RdKGToolAdmin.HandleAdminSkillsInformationRequest(senderTag)
	if RdKGToolAdmin.adminVars.enabled == false then
		if RdKGToolRoster.IsRdKMember(GetUnitDisplayName("player")) == true and RdKGToolRoster.IsRdKAdmin(GetUnitDisplayName(senderTag)) then
		else
			return
		end
	end
	local bars = RdKGToolSB.GetSkillBars()
	if bars[1] ~= nil then
		RdKGToolAdmin.SendAdminSkillsInformationResponse(RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_1, bars[1][1])
		RdKGToolAdmin.SendAdminSkillsInformationResponse(RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_2, bars[1][2])
		RdKGToolAdmin.SendAdminSkillsInformationResponse(RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_3, bars[1][3])
		RdKGToolAdmin.SendAdminSkillsInformationResponse(RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_4, bars[1][4])
		RdKGToolAdmin.SendAdminSkillsInformationResponse(RdKGToolSB.constants.networking.messagePrefix.BAR_1_SKILL_5, bars[1][5])
		RdKGToolAdmin.SendAdminSkillsInformationResponse(RdKGToolSB.constants.networking.messagePrefix.BAR_1_ULTIMATE, bars[1][6])
	end
	if bars[2] ~= nil then
		RdKGToolAdmin.SendAdminSkillsInformationResponse(RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_1, bars[2][1])
		RdKGToolAdmin.SendAdminSkillsInformationResponse(RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_2, bars[2][2])
		RdKGToolAdmin.SendAdminSkillsInformationResponse(RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_3, bars[2][3])
		RdKGToolAdmin.SendAdminSkillsInformationResponse(RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_4, bars[2][4])
		RdKGToolAdmin.SendAdminSkillsInformationResponse(RdKGToolSB.constants.networking.messagePrefix.BAR_2_SKILL_5, bars[2][5])
		RdKGToolAdmin.SendAdminSkillsInformationResponse(RdKGToolSB.constants.networking.messagePrefix.BAR_2_ULTIMATE, bars[2][6])
	end
end

function RdKGToolAdmin.HandleAdminQuickslotInformationRequest(senderTag)
	if RdKGToolAdmin.adminVars.enabled == false then
		if RdKGToolRoster.IsRdKMember(GetUnitDisplayName("player")) == true and RdKGToolRoster.IsRdKAdmin(GetUnitDisplayName(senderTag)) then
		else
			return
		end
	end
end

function RdKGToolAdmin.HandleAdminRequest(b2, b3, senderTag)
	if b2 ~= nil and b3 ~= nil then
		--d(b2)
		if RdKGToolMath.IsBitFieldPresent(b2, RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_CLIENT_CONFIGURATION) then
			RdKGToolAdmin.HandleAdminClientConfigurationRequest(senderTag)
		end
		if RdKGToolMath.IsBitFieldPresent(b2, RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_ADDON_CONFIGURATION) then
			RdKGToolAdmin.HandleAdminAddonConfigurationRequest(senderTag)
		end
		if RdKGToolMath.IsBitFieldPresent(b2, RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_STATS_INFORMATION) then
			RdKGToolAdmin.HandleAdminStatsInformationRequest(senderTag)
		end
		if RdKGToolMath.IsBitFieldPresent(b2, RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_SKILLS_INFORMATION) then
			RdKGToolAdmin.HandleAdminSkillsInformationRequest(senderTag)
		end
		if RdKGToolMath.IsBitFieldPresent(b2, RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_EQUIPMENT_INFORMATION) then
			RdKGToolAdmin.HandleAdminEquipmentInformationRequest(senderTag)
		end
		if RdKGToolMath.IsBitFieldPresent(b2, RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_CHAMPION_INFORMATION) then
			RdKGToolAdmin.HandleAdminChampionInformationRequest(senderTag)
		end
		if RdKGToolMath.IsBitFieldPresent(b2, RdKGToolAdmin.constants.requests.ADMIN_REQUEST_B2_QUICKSLOT_INFORMATION) then
			RdKGToolAdmin.HandleAdminQuickslotInformationRequest(senderTag)
		end
	end
end

function RdKGToolAdmin.HandleEquipmentRequest(messagePrefix, senderTag)
	if messagePrefix ~= nil then
		for i = 1, #RdKGToolAdmin.constants.equipment do
			if RdKGToolAdmin.constants.equipment[i].messagePrefix == messagePrefix then
				local slotId = RdKGToolAdmin.constants.equipment[i].slotId
				RdKGToolAdmin.SendEquipmentInformationResponse(messagePrefix, slotId, senderTag)
				break
			end
		end
	end
end

function RdKGToolAdmin.ToggleAdminInterface()
	if RdKGToolRoster.IsGuildOfficer(GetUnitDisplayName("player")) then
		RdKGToolAdmin.controls.TLW:SetHidden(not RdKGToolAdmin.controls.TLW:IsHidden())
		if RdKGToolAdmin.controls.TLW:IsHidden() == false then
			RdKGToolGroup.AddGroupChangedCallback(RdKGToolAdmin.callbackName, RdKGToolAdmin.AdjustPlayerList)
			RdKGToolGroup.AddAdminInformationChangedCallback(RdKGToolAdmin.callbackName, RdKGToolAdmin.AdjustAdminInformation)
		else
			RdKGToolGroup.RemoveGroupChangedCallback(RdKGToolAdmin.callbackName)
			RdKGToolGroup.RemoveAdminInformationChangedCallback(RdKGToolAdmin.callbackName)
		end
		SetGameCameraUIMode(not RdKGToolAdmin.controls.TLW:IsHidden())
		RdKGToolAdmin.AdjustPlayerList()
	end
end

function RdKGToolAdmin.PopulateConfigPanel(configData)
	local rootControl = RdKGToolAdmin.controls.TLW.config.scrollPanel
	
	--player
	local player = rootControl.player
	
	player.displayName:SetText(string.format(RdKGToolAdmin.constants.config.PLAYER_DISPLAYNAME_STRING, configData.player.displayNameColor, configData.player.displayName))
	player.charName:SetText(string.format(RdKGToolAdmin.constants.config.PLAYER_CHARNAME_STRING, configData.player.charNameColor, configData.player.charName))
	player.version:SetText(string.format(RdKGToolAdmin.constants.config.PLAYER_VERSION_STRING, configData.player.versionColor, configData.player.version.major, configData.player.version.minor, configData.player.version.revision))

	--client
	local client = rootControl.client
	---aoe
	local aoe = client.aoe
	aoe.tellsEnabled:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_AOE_TELLS_ENABLED_STRING, configData.client.aoe.tellsEnabledColor, configData.client.aoe.tellsEnabled))
	aoe.customColorsEnabled:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_AOE_CUSTOM_COLOR_ENABLED_STRING, configData.client.aoe.customEnabledColor, configData.client.aoe.customEnabled))
	aoe.friendlyBrightness:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_AOE_CUSTOM_COLOR_FRIENDLY_BRIGHTNESS, configData.client.aoe.friendlyBrightnessColor, configData.client.aoe.friendlyBrightness))
	aoe.enemyBrightness:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_AOE_CUSTOM_COLOR_ENEMY_BRIGHTNESS, configData.client.aoe.enemyBrightnessColor, configData.client.aoe.enemyBrightness))
	
	---sound
	local sound = client.sound
	sound.enabled:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_SOUND_ENABLED_STRING, configData.client.sound.enabledColor, configData.client.sound.enabled))
	sound.audioVolume:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_SOUND_AUDIO_VOLUME, configData.client.sound.audioVolumeColor, configData.client.sound.audioVolume))
	sound.uiVolume:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_UI_AUDIO_VOLUME, configData.client.sound.uiVolumeColor, configData.client.sound.uiVolume))
	sound.sfxVolume:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_SFX_AUDIO_VOLUME, configData.client.sound.sfxVolumeColor, configData.client.sound.sfxVolume))
	
	---graphics
	local graphics = client.graphics
	graphics.resolution:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_RESOLUTION_STRING, configData.client.graphics.resolutionColor, configData.client.graphics.resWidth, configData.client.graphics.resHeight))
	graphics.windowMode:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_WINDOW_MODE_STRING, configData.client.graphics.windowModeColor, configData.client.graphics.windowMode))
	graphics.vsync:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_VSYNC_STRING, configData.client.graphics.vsyncColor, configData.client.graphics.vsync))
	graphics.antiAliasing:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_ANTI_ALIASING_STRING, configData.client.graphics.antiAliasingColor, configData.client.graphics.antiAliasing))
	graphics.ambient:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_AMBIENT_STRING, configData.client.graphics.ambientColor, configData.client.graphics.ambient))
	graphics.bloom:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_BLOOM_STRING, configData.client.graphics.bloomColor, configData.client.graphics.bloom))
	graphics.depthOfField:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_DEPTH_OF_FIELD_STRING, configData.client.graphics.depthOfFieldColor, configData.client.graphics.depthOfField))
	graphics.distortion:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_DISTORTION_STRING, configData.client.graphics.distortionColor, configData.client.graphics.distortion))
	graphics.sunlight:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_SUNLIGHT_STRING, configData.client.graphics.sunlightColor, configData.client.graphics.sunlight))
	graphics.allyEffects:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_ALLY_EFFECTS_STRING, configData.client.graphics.allyEffectsColor, configData.client.graphics.allyEffects))
	graphics.viewDistance:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_VIEW_DISTANCE_STRING, configData.client.graphics.viewDistanceColor, configData.client.graphics.viewDistance))
	graphics.particleMaximum:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_PARTICLE_MAXIMUM_STRING, configData.client.graphics.particleMaximumColor, configData.client.graphics.particleMaximum))
	graphics.particleSupress:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_PARTICLE_SUPRESSION_DISTANCE_STRING, configData.client.graphics.particleSupressDistanceColor, configData.client.graphics.particleSupressDistance))
	graphics.reflectionQuality:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_REFLECTION_QUALITY_STRING, configData.client.graphics.reflectionQualityColor, configData.client.graphics.reflectionQuality))
	graphics.shadowQuality:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_SHADOW_QUALITY_STRING, configData.client.graphics.shadowQualityColor, configData.client.graphics.shadowQuality))
	graphics.subSamplingQuality:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_SUBSAMPLING_QUALITY_STRING, configData.client.graphics.subSamplingQualityColor, configData.client.graphics.subSamplingQuality))
	graphics.graphicPresets:SetText(string.format(RdKGToolAdmin.constants.config.CLIENT_GRAPHICS_GRAPHIC_PRESETS_STRING, configData.client.graphics.graphicPresetsColor, configData.client.graphics.graphicPresets))
	
	--addon
	local addon = rootControl.addon
	---crown
	local crown = addon.crown
	crown.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_CROWN_ENABLED_STRING, configData.addon.crown.enabledColor, configData.addon.crown.enabled))
	crown.size:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_CROWN_SIZE_STRING, configData.addon.crown.sizeColor, configData.addon.crown.size))
	crown.selectedCrown:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_CROWN_SELECTED_CROWN_STRING, configData.addon.crown.selectedCrownColor, configData.addon.crown.selectedCrown))
	
	---ftcv
	local ftcv = addon.ftcv
	ftcv.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCV_ENABLED_STRING, configData.addon.ftcv.enabledColor, configData.addon.ftcv.enabled))
	ftcv.sizeFar:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCV_SIZE_FAR_STRING, configData.addon.ftcv.sizeFarColor, configData.addon.ftcv.sizeFar))
	ftcv.sizeClose:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCV_SIZE_CLOSE_STRING, configData.addon.ftcv.sizeCloseColor, configData.addon.ftcv.sizeClose))
	ftcv.opacityFar:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCV_OPACITY_FAR_STRING, configData.addon.ftcv.opacityFarColor, configData.addon.ftcv.opacityFar))
	ftcv.opacityClose:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCV_OPACITY_CLOSE_STRING, configData.addon.ftcv.opacityCloseColor, configData.addon.ftcv.opacityClose))
	ftcv.minDistance:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCV_MIN_DISTANCE_STRING, configData.addon.ftcv.minDistanceColor, configData.addon.ftcv.minDistance))
	ftcv.maxDistance:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCV_MAX_DISTANCE_STRING, configData.addon.ftcv.maxDistanceColor, configData.addon.ftcv.maxDistance))
	
	---ftcw
	local ftcw = addon.ftcw
	ftcw.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCW_ENABLED_STRING, configData.addon.ftcw.enabledColor, configData.addon.ftcw.enabled))
	ftcw.distanceEnabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCW_DISTANCE_ENABLED_STRING, configData.addon.ftcw.distanceEnabledColor, configData.addon.ftcw.distanceEnabled))
	ftcw.warningsEnabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCW_WARNINGS_ENABLED_STRING, configData.addon.ftcw.warningEnabledColor, configData.addon.ftcw.warningEnabled))
	ftcw.maxDistance:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCW_MAX_DISTANCE_STRING, configData.addon.ftcw.maxDistanceColor, configData.addon.ftcw.maxDistance))
	
	---ftca
	local ftca = addon.ftca
	ftca.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCA_ENABLED_STRING, configData.addon.ftca.enabledColor, configData.addon.ftca.enabled))
	ftca.maxDistance:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCA_MAX_DISTANCE_STRING, configData.addon.ftca.maxDistanceColor, configData.addon.ftca.maxDistance))
	ftca.interval:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCA_INTERVAL_STRING, configData.addon.ftca.intervalColor, configData.addon.ftca.interval))
	ftca.threshold:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCA_THRESHOLD_STRING, configData.addon.ftca.thresholdColor, configData.addon.ftca.threshold))
	
	--ftcb
	local ftcb = addon.ftcb
	ftcb.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCB_ENABLED_STRING, configData.addon.ftcb.enabledColor, configData.addon.ftcb.enabled))
	ftcb.selectedBeam:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCB_SELECTED_BEAM_STRING, configData.addon.ftcb.selectedBeamColor, configData.addon.ftcb.selectedBeam))
	ftcb.alpha:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_FTCB_ALPHA_STRING, configData.addon.ftcb.alphaColor, configData.addon.ftcb.alpha))
	
	
	---dbo
	local dbo = addon.dbo
	dbo.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_DBO_ENABLED_STRING, configData.addon.dbo.enabledColor, configData.addon.dbo.enabled))
	
	---rt
	local rt = addon.rt
	rt.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RT_ENABLED_STRING, configData.addon.rt.enabledColor, configData.addon.rt.enabled))
		
	---ro
	local ro = addon.ro
	ro.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_ENABLED_STRING, configData.addon.ro.enabledColor, configData.addon.ro.enabled))
	ro.ultimateOverviewEnabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_ULTIMATE_OVERVIEW_ENABLED_STRING, configData.addon.ro.ultimateOverviewEnabledColor, configData.addon.ro.ultimateOverviewEnabled))
	ro.clientGroupEnabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_CLIENT_GROUP_ENABLED_STRING, configData.addon.ro.clientUltimateEnabledColor, configData.addon.ro.clientUltimateEnabled))
	ro.groupUltimateEnabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_GROUP_ULTIMATE_ENABLED_STRING, configData.addon.ro.groupUltimatesEnabledColor, configData.addon.ro.groupUltimatesEnabled))
	ro.showSoftResources:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_SHOW_SOFT_RESOURCES_STRING, configData.addon.ro.showSoftResourcesColor, configData.addon.ro.showSoftResources))
	ro.soundEnabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_SOUND_ENABLED_STRING, configData.addon.ro.soundEnabledColor, configData.addon.ro.soundEnabled))
	ro.maxDistance:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_MAX_DISTANCE_STRING, configData.addon.ro.maxDistanceColor, configData.addon.ro.maxDistance))
	ro.groupSizeDestro:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_DESTRO_STRING, configData.addon.ro.groupSizeDestroColor, configData.addon.ro.groupSizeDestro))
	ro.groupSizeStorm:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_STORM_STRING, configData.addon.ro.groupSizeStormColor, configData.addon.ro.groupSizeStorm))
	ro.groupSizeNorthernStorm:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NORTHERNSTORM_STRING, configData.addon.ro.groupSizeNorthernStormColor, configData.addon.ro.groupSizeNorthernStorm))
	ro.groupSizePermafrost:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_PERMAFROST_STRING, configData.addon.ro.groupSizePermafrostColor, configData.addon.ro.groupSizePermafrost))
	ro.groupSizeNegate:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NEGATE_STRING, configData.addon.ro.groupSizeNegateColor, configData.addon.ro.groupSizeNegate))
	ro.groupSizeNegateOffensive:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NEGATE_OFFENSIVE_STRING, configData.addon.ro.groupSizeNegateOffensiveColor, configData.addon.ro.groupSizeNegateOffensive))
	ro.groupSizeNegateCounter:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NEGATE_COUNTER_STRING, configData.addon.ro.groupSizeNegateCounterColor, configData.addon.ro.groupSizeNegateCounter))
	ro.groupSizeNova:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_GROUP_SIZE_NOVA_STRING, configData.addon.ro.groupSizeNovaColor, configData.addon.ro.groupSizeNova))
	ro.groupsEnabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RO_GROUPS_ENABLED_STRING, configData.addon.ro.groupsEnabledColor, configData.addon.ro.groupsEnabled))
	
	---hdm
	local hdm = addon.hdm
	hdm.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_HDM_ENABLED_STRING, configData.addon.hdm.enabledColor, configData.addon.hdm.enabled))
	hdm.windowEnabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_HDM_WINDOW_ENABLED_STRING, configData.addon.hdm.windowEnabledColor, configData.addon.hdm.windowEnabled))
	hdm.viewMode:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_HDM_VIEW_MODE_STRING, configData.addon.hdm.viewModeColor, configData.addon.hdm.viewMode))
		
	---po
	local po = addon.po
	po.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_PO_ENABLED_STRING, configData.addon.po.enabledColor, configData.addon.po.enabled))
	po.soundEnabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_PO_SOUND_ENABLED_STRING, configData.addon.po.soundEnabledColor, configData.addon.po.soundEnabled))
	
	---dt
	local dt = addon.dt
	dt.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_DT_ENABLED_STRING, configData.addon.dt.enabledColor, configData.addon.dt.enabled))
	
	---gb
	local gb = addon.gb
	gb.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_GB_ENABLED_STRING, configData.addon.gb.enabledColor, configData.addon.gb.enabled))
	
	---isdp
	local isdp = addon.isdp
	isdp.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_DT_ENABLED_STRING, configData.addon.isdp.enabledColor, configData.addon.isdp.enabled))
	
	
	---yacs
	local yacs = addon.yacs
	yacs.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_YACS_ENABLED_STRING, configData.addon.yacs.enabledColor, configData.addon.yacs.enabled))
	yacs.pvpEnabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_YACS_PVP_ENABLED_STRING, configData.addon.yacs.pvpEnabledColor, configData.addon.yacs.pvpEnabled))
	yacs.combatEnabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_YACS_COMBAT_ENABLED_STRING, configData.addon.yacs.combatEnabledColor, configData.addon.yacs.combatEnabled))
	
	---sc
	local sc = addon.sc
	sc.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SC_ENABLED_STRING, configData.addon.sc.enabledColor, configData.addon.sc.enabled))
	
	---sm
	local sm = addon.sm
	sm.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SM_ENABLED_STRING, configData.addon.sm.enabledColor, configData.addon.sm.enabled))
	
	---recharger
	local recharger = addon.recharger
	recharger.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RECHARGER_ENABLED_STRING, configData.addon.recharger.enabledColor, configData.addon.recharger.enabled))
	
	---kc
	if RdKGToolRoster.IsRdKMember(GetUnitDisplayName("player")) == true then
		local kc = addon.kc
		kc.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_KC_ENABLED_STRING, configData.addon.kc.enabledColor, configData.addon.kc.enabled))
	end
	
	---bft
	local bft = addon.bft
	bft.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_BFT_ENABLED_STRING, configData.addon.bft.enabledColor, configData.addon.bft.enabled))
	bft.soundEnabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_BFT_SOUND_ENABLED_STRING, configData.addon.bft.soundEnabledColor, configData.addon.bft.soundEnabled))
	bft.size:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_BFT_SIZE_STRING, configData.addon.bft.sizeColor, configData.addon.bft.size))
	
	--cl
	local cl = addon.cl
	cl.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_CL_ENABLED_STRING, configData.addon.cl.enabledColor, configData.addon.cl.enabled))
	
	--cs
	local cs = addon.cs
	cs.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_CS_ENABLED_STRING, configData.addon.cs.enabledColor, configData.addon.cs.enabled))
	
	--respawner
	local respawner = addon.respawner
	respawner.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_CS_ENABLED_STRING, configData.addon.respawner.enabledColor, configData.addon.respawner.enabled))
	
	--camp
	local camp = addon.camp
	camp.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_CS_ENABLED_STRING, configData.addon.camp.enabledColor, configData.addon.camp.enabled))
	
	--sp
	local sp = addon.sp
	sp.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_ENABLED_STRING, configData.addon.sp.enabledColor, configData.addon.sp.enabled))
	sp.mode:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_MODE_STRING, configData.addon.sp.modeColor, configData.addon.sp.mode))
	sp.preventCombustionShards:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_COMBUSTION_SHARD, configData.addon.sp.preventCombustionShardsColor, configData.addon.sp.preventCombustionShards))
	sp.preventTalons:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_TALONS, configData.addon.sp.preventTalonsColor, configData.addon.sp.preventTalons))
	sp.preventNova:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_NOVA, configData.addon.sp.preventNovaColor, configData.addon.sp.preventNova))
	sp.preventAltar:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_BLOOD_ALTAR, configData.addon.sp.preventAltarColor, configData.addon.sp.preventAltar))
	sp.preventStandard:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_STANDARD, configData.addon.sp.preventStandardColor, configData.addon.sp.preventStandard))
	sp.preventRitual:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_PURGE, configData.addon.sp.preventRitualColor, configData.addon.sp.preventRitual))
	sp.preventBoneShield:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_BONE_SHIELD, configData.addon.sp.preventBoneShieldColor, configData.addon.sp.preventBoneShield))
	sp.preventConduit:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_FLOOD_CONDUIT, configData.addon.sp.preventConduitColor, configData.addon.sp.preventConduit))
	sp.preventAtronach:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_ATRONACH, configData.addon.sp.preventAtronachColor, configData.addon.sp.preventAtronach))
	sp.preventTrappingWebs:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_TRAPPING_WEBS, configData.addon.sp.preventTrappingWebsColor, configData.addon.sp.preventTrappingWebs))
	sp.preventRadiate:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_RADIATE, configData.addon.sp.preventRadiateColor, configData.addon.sp.preventRadiate))
	sp.preventConsumingDarkness:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_CONSUMING_DARKNESS, configData.addon.sp.preventConsumingDarknessColor, configData.addon.sp.preventConsumingDarkness))
	sp.preventSoulLeech:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_SOUL_LEECH, configData.addon.sp.preventSoulLeechColor, configData.addon.sp.preventSoulLeech))
	sp.preventHealingSeed:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_WARDEN_HEALING, configData.addon.sp.preventHealingSeedColor, configData.addon.sp.preventHealingSeed))
	sp.preventGraveRobber:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_GRAVE_ROBBER, configData.addon.sp.preventGraveRobberColor, configData.addon.sp.preventGraveRobber))
	sp.preventPureAgony:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SP_PREVENT_STRING, RdKGToolMenu.constants.SP_SYNERGY_PURE_AGONY, configData.addon.sp.preventPureAgonyColor, configData.addon.sp.preventPureAgony))
	
	--so
	local so = addon.so
	so.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SO_ENABLED_STRING, configData.addon.so.enabledColor, configData.addon.so.enabled))
	so.tableMode:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SO_TABLE_MODE_STRING, configData.addon.so.tableModeColor, configData.addon.so.tableMode))
	so.displayMode:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_SO_DISPLAY_MODE_STRING, configData.addon.so.displayModeColor, configData.addon.so.displayMode))
	
	--ra
	local ra = addon.ra
	ra.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RA_ENABLED_STRING, configData.addon.ra.enabledColor, configData.addon.ra.enabled))
	ra.allowOverride:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_RA_ALLOW_OVERRIDE_STRING, configData.addon.ra.allowOverrideColor, configData.addon.ra.allowOverride))
	
	--caj
	local caj = addon.caj
	caj.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_CAJ_ENABLED_STRING, configData.addon.caj.enabledColor, configData.addon.caj.enabled))
	
	--crBgTp
	local crBgTp = addon.crBgTp
	crBgTp.enabled:SetText(string.format(RdKGToolAdmin.constants.config.ADDON_CRBGTP_ENABLED_STRING, configData.addon.crBgTp.enabledColor, configData.addon.crBgTp.enabled))
	
	
	--stats
	local stats = rootControl.stats
	stats.magicka:SetText(string.format(RdKGToolAdmin.constants.config.STATS_MAGICKA_STRING, configData.stats.magickaColor, configData.stats.magicka))
	stats.health:SetText(string.format(RdKGToolAdmin.constants.config.STATS_HEALTH_STRING, configData.stats.healthColor, configData.stats.health))
	stats.stamina:SetText(string.format(RdKGToolAdmin.constants.config.STATS_STAMINA_STRING, configData.stats.staminaColor, configData.stats.stamina))
	stats.magickaRecovery:SetText(string.format(RdKGToolAdmin.constants.config.STATS_MAGICKA_RECOVERY_STRING, configData.stats.magickaRecoveryColor, configData.stats.magickaRecovery))
	stats.healthRecovery:SetText(string.format(RdKGToolAdmin.constants.config.STATS_HEALTH_RECOVERY_STRING, configData.stats.healthRecoveryColor, configData.stats.healthRecovery))
	stats.staminaRecovery:SetText(string.format(RdKGToolAdmin.constants.config.STATS_STAMINA_RECOVERY_STRING, configData.stats.staminaRecoveryColor, configData.stats.staminaRecovery))
	stats.spellDamage:SetText(string.format(RdKGToolAdmin.constants.config.STATS_SPELL_DAMAGE_STRING, configData.stats.spellDamageColor, configData.stats.spellDamage))
	stats.weaponDamage:SetText(string.format(RdKGToolAdmin.constants.config.STATS_WEAPON_DAMAGE_STRING, configData.stats.weaponDamageColor, configData.stats.weaponDamage))
	stats.spellPenetration:SetText(string.format(RdKGToolAdmin.constants.config.STATS_SPELL_PENETRATION_STRING, configData.stats.spellPenetrationColor, configData.stats.spellPenetration))
	stats.weaponPenetration:SetText(string.format(RdKGToolAdmin.constants.config.STATS_WEAPON_PENETRATION_STRING, configData.stats.weaponPenetrationColor, configData.stats.weaponPenetration))
	stats.spellCritical:SetText(string.format(RdKGToolAdmin.constants.config.STATS_SPELL_CRITICAL_STRING, configData.stats.spellCriticalColor, configData.stats.spellCritical))
	stats.weaponCritical:SetText(string.format(RdKGToolAdmin.constants.config.STATS_WEAPON_CRITICAL_STRING, configData.stats.weaponCriticalColor, configData.stats.weaponCritical))
	stats.spellResistance:SetText(string.format(RdKGToolAdmin.constants.config.STATS_SPELL_RESISTANCE_STRING, configData.stats.spellResistanceColor, configData.stats.spellResistance))
	stats.physicalResistance:SetText(string.format(RdKGToolAdmin.constants.config.STATS_PHYSICAL_RESISTANCE_STRING, configData.stats.physicalResistanceColor, configData.stats.physicalResistance))
	stats.criticalResistance:SetText(string.format(RdKGToolAdmin.constants.config.STATS_CRITICAL_RESISTANCE_STRING, configData.stats.criticalResistanceColor, configData.stats.criticalResistance))
	
	--mundus
	local mundus = rootControl.mundus
	mundus.stone1:SetText(string.format(RdKGToolAdmin.constants.config.MUNDUS_STONE_1_STRING, configData.mundus.stone1Color, configData.mundus.stone1))
	mundus.stone2:SetText(string.format(RdKGToolAdmin.constants.config.MUNDUS_STONE_2_STRING, configData.mundus.stone2Color, configData.mundus.stone2))
	
	--cp
	local cpControl = rootControl.cp.cpValues
	for key, value in pairs(configData.cp) do 
		cpControl[key]:SetText(value)
	end

	--skills
	local bar1 = rootControl.skills.bar1
	local bar2 = rootControl.skills.bar2
	bar1.skill1.texture:SetTexture(configData.skills[1].texture)
	bar1.skill1.texture.id = configData.skills[1].id
	bar1.skill2.texture:SetTexture(configData.skills[2].texture)
	bar1.skill2.texture.id = configData.skills[2].id
	bar1.skill3.texture:SetTexture(configData.skills[3].texture)
	bar1.skill3.texture.id = configData.skills[3].id
	bar1.skill4.texture:SetTexture(configData.skills[4].texture)
	bar1.skill4.texture.id = configData.skills[4].id
	bar1.skill5.texture:SetTexture(configData.skills[5].texture)
	bar1.skill5.texture.id = configData.skills[5].id
	bar1.ultimate.texture:SetTexture(configData.skills[6].texture)
	bar1.ultimate.texture.id = configData.skills[6].id
	bar2.skill1.texture:SetTexture(configData.skills[7].texture)
	bar2.skill1.texture.id = configData.skills[7].id
	bar2.skill2.texture:SetTexture(configData.skills[8].texture)
	bar2.skill2.texture.id = configData.skills[8].id
	bar2.skill3.texture:SetTexture(configData.skills[9].texture)
	bar2.skill3.texture.id = configData.skills[9].id
	bar2.skill4.texture:SetTexture(configData.skills[10].texture)
	bar2.skill4.texture.id = configData.skills[10].id
	bar2.skill5.texture:SetTexture(configData.skills[11].texture)
	bar2.skill5.texture.id = configData.skills[11].id
	bar2.ultimate.texture:SetTexture(configData.skills[12].texture)
	bar2.ultimate.texture.id = configData.skills[12].id
	
	--equipment
	local equipment = rootControl.equipment
	for i = 1, #RdKGToolAdmin.constants.equipment do
		local name = RdKGToolAdmin.constants.equipment[i].name
		local equipmentControl = equipment[name]
		if name ~= nil and equipmentControl ~= nil then
			equipmentControl.texture:SetTexture(configData.equipment[name].texture)
			equipmentControl.link:SetText(configData.equipment[name].link)
			equipmentControl.link.link = configData.equipment[name].link
			equipmentControl.infoWindow.line1:SetText(configData.equipment[name].line1)
			equipmentControl.infoWindow.line2:SetText(configData.equipment[name].line2)
		else
			equipmentControl.link.link = nil
		end
	end
end

function RdKGToolAdmin.CreateDefaultDataTemplate()
	local template = {}
	
	--player
	template.player = {}
	template.player.displayName = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.player.displayNameColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.player.charName = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.player.charNameColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.player.version = {}
	template.player.version.minor = RdKGToolAdmin.constants.defaults.UNDEFINED_LINE
	template.player.version.major = RdKGToolAdmin.constants.defaults.UNDEFINED_LINE
	template.player.version.revision = RdKGToolAdmin.constants.defaults.UNDEFINED_LINE
	template.player.versionColor = RdKGToolAdmin.config.configWindow.rating.fail
	
	--client
	template.client = {}
	---aoe
	template.client.aoe = {}
	template.client.aoe.tellsEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.aoe.tellsEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.aoe.customEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.aoe.customEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.aoe.friendlyBrightness = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.aoe.friendlyBrightnessColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.aoe.enemyBrightness = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.aoe.enemyBrightnessColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	---sounds
	template.client.sound = {}
	template.client.sound.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.sound.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.sound.audioVolume = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.sound.audioVolumeColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.sound.uiVolume = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.sound.uiVolumeColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.sound.sfxVolume = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.sound.sfxVolumeColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	---graphics
	template.client.graphics = {}
	template.client.graphics.windowMode = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.windowModeColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.vsync = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.vsyncColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.antiAliasing = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.antiAliasingColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.ambient = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.ambientColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.bloom = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.bloomColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.depthOfField = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.depthOfFieldColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.distortion = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.distortionColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.sunlight = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.sunlightColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.allyEffects = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.allyEffectsColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.viewDistance = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.viewDistanceColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.resWidth = RdKGToolAdmin.constants.defaults.UNDEFINED_LINE
	template.client.graphics.resHeight = RdKGToolAdmin.constants.defaults.UNDEFINED_LINE
	template.client.graphics.resolutionColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.particleSupressDistance = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.particleSupressDistanceColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.particleMaximum = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.particleMaximumColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.reflectionQuality = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.reflectionQualityColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.shadowQuality = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.shadowQualityColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.subSamplingQuality = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.subSamplingQualityColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.client.graphics.graphicPresets = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.client.graphics.graphicPresetsColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--addon
	template.addon = {}
	--crown
	template.addon.crown = {}
	template.addon.crown.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.crown.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.crown.size = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.crown.sizeColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.crown.selectedCrown = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.crown.selectedCrownColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--ftcv
	template.addon.ftcv = {}
	template.addon.ftcv.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcv.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftcv.minDistance = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcv.minDistanceColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftcv.maxDistance = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcv.maxDistanceColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftcv.sizeClose = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcv.sizeCloseColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftcv.sizeFar = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcv.sizeFarColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftcv.opacityClose = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcv.opacityCloseColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftcv.opacityFar = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcv.opacityFarColor = RdKGToolAdmin.config.configWindow.rating.neutral
		
	--ftcw
	template.addon.ftcw = {}
	template.addon.ftcw.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcw.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftcw.distanceEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcw.distanceEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftcw.warningEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcw.warningEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftcw.maxDistance = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcw.maxDistanceColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--ftca
	template.addon.ftca = {}
	template.addon.ftca.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftca.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftca.maxDistance = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftca.maxDistanceColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftca.interval = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftca.intervalColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftca.threshold = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftca.thresholdColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--ftca
	template.addon.ftcb = {}
	template.addon.ftcb.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcb.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftcb.selectedBeam = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcb.selectedBeamColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ftcb.alpha = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ftcb.alphaColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--dbo
	template.addon.dbo = {}
	template.addon.dbo.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.dbo.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--rt
	template.addon.rt = {}
	template.addon.rt.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.rt.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--ro
	template.addon.ro = {}
	template.addon.ro.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.ultimateOverviewEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.ultimateOverviewEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.clientUltimateEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.clientUltimateEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.groupUltimatesEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.groupUltimatesEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.showSoftResources = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.showSoftResourcesColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.soundEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.soundEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.groupSizeDestro = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.groupSizeDestroColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.groupSizeStorm = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.groupSizeStormColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.groupSizeNorthernStorm = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.groupSizeNorthernStormColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.groupSizePermafrost = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.groupSizePermafrostColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.groupSizeNegate = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.groupSizeNegateColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.groupSizeNegateOffensive = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.groupSizeNegateOffensiveColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.groupSizeNegateCounter = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.groupSizeNegateCounterColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.groupSizeNova = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.groupSizeNovaColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.maxDistance = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.maxDistanceColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ro.groupsEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ro.groupsEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--hdm
	template.addon.hdm = {}
	template.addon.hdm.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.hdm.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.hdm.windowEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.hdm.windowEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.hdm.viewMode = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.hdm.viewModeColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--po
	template.addon.po = {}
	template.addon.po.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.po.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.po.soundEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.po.soundEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--dt
	template.addon.dt = {}
	template.addon.dt.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.dt.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--gb
	template.addon.gb = {}
	template.addon.gb.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.gb.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--isdp
	template.addon.isdp = {}
	template.addon.isdp.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.isdp.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral

	--yacs
	template.addon.yacs = {}
	template.addon.yacs.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.yacs.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.yacs.pvpEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.yacs.pvpEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.yacs.combatEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.yacs.combatEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--sc
	template.addon.sc = {}
	template.addon.sc.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sc.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--sm
	template.addon.sm = {}
	template.addon.sm.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sm.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--recharger
	template.addon.recharger = {}
	template.addon.recharger.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.recharger.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--kc
	template.addon.kc = {}
	template.addon.kc.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.kc.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--bft
	template.addon.bft = {}
	template.addon.bft.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.bft.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.bft.soundEnabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.bft.soundEnabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.bft.size = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.bft.sizeColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--cl
	template.addon.cl = {}
	template.addon.cl.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.cl.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--cs
	template.addon.cs = {}
	template.addon.cs.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.cs.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--respawner
	template.addon.respawner = {}
	template.addon.respawner.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.respawner.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--camp
	template.addon.camp = {}
	template.addon.camp.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.camp.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--sp
	template.addon.sp = {}
	template.addon.sp.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.mode = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.modeColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventCombustionShards = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventCombustionShardsColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventTalons = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventTalonsColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventNova = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventNovaColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventAltar = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventAltarColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventStandard = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventStandardColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventRitual = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventRitualColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventBoneShield = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventBoneShieldColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventConduit = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventConduitColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventAtronach = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventAtronachColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventTrappingWebs = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventTrappingWebsColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventRadiate = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventRadiateColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventConsumingDarkness = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventConsumingDarknessColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventSoulLeech = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventSoulLeechColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventHealingSeed = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventHealingSeedColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventGraveRobber = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventGraveRobberColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.sp.preventPureAgony = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.sp.preventPureAgonyColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--so
	template.addon.so = {}
	template.addon.so.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.so.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.so.tableMode = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.so.tableModeColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.so.displayMode = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.so.displayModeColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--ra
	template.addon.ra = {}
	template.addon.ra.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ra.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.addon.ra.allowOverride = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.ra.allowOverrideColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--caj
	template.addon.caj = {}
	template.addon.caj.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.caj.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--caj
	template.addon.crBgTp = {}
	template.addon.crBgTp.enabled = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.addon.crBgTp.enabledColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--stats
	template.stats = {}
	template.stats.magicka = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.magickaColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.health = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.healthColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.stamina = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.staminaColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.magickaRecovery = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.magickaRecoveryColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.healthRecovery = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.healthRecoveryColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.staminaRecovery = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.staminaRecoveryColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.spellDamage = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.spellDamageColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.weaponDamage = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.weaponDamageColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.spellPenetration = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.spellPenetrationColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.weaponPenetration = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.weaponPenetrationColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.spellCritical = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.spellCriticalColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.weaponCritical = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.weaponCriticalColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.spellResistance = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.spellResistanceColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.physicalResistance = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.physicalResistanceColor = RdKGToolAdmin.config.configWindow.rating.neutral
	template.stats.criticalResistance = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.stats.criticalResistanceColor = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--mundus
	template.mundus = {}
	template.mundus.stone1 = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.mundus.stone1Color = RdKGToolAdmin.config.configWindow.rating.neutral
	template.mundus.stone2 = RdKGToolAdmin.constants.defaults.UNDEFINED
	template.mundus.stone2Color = RdKGToolAdmin.config.configWindow.rating.neutral
	
	--cp
	template.cp = {}
	for i = 1, #RdKGToolAdmin.constants.cpDisciplines do
		for j = 1, #RdKGToolAdmin.constants.cpDisciplines[i].cp do
			template.cp[RdKGToolCP.GetCPControlName(i, j)] = RdKGToolAdmin.constants.defaults.UNDEFINED
		end
	end
	--skills
	template.skills = {}
	for i = 1, 12 do
		template.skills[i] = {}
		template.skills[i].id = 0
		template.skills[i].texture = "esoui/art/mainmenu/menubar_skills_disabled.dds"
	end
	--equipment
	template.equipment = {}
	for i = 1, #RdKGToolAdmin.constants.equipment do
		local name = RdKGToolAdmin.constants.equipment[i].name
		if name ~= nil then
			template.equipment[name] = {}
			template.equipment[name].texture = RdKGToolAdmin.constants.equipment[i].texture
			template.equipment[name].link = nil
			template.equipment[name].line1 = ""
			template.equipment[name].line2 = ""
		end
	end
	
	return template
end

function RdKGToolAdmin.GetOnOffValuesVersionDependant(bool, clientVersion, requiredVersion, defaultValue)
	requiredVersion = RdKGToolVersioning.GetVersionArray(requiredVersion)
	if bool == true then
		return RdKGToolAdmin.constants.defaults.ENABLED
	else
		if clientVersion == nil then
			if defaultValue == nil then
				return RdKGToolAdmin.constants.defaults.UNDEFINED
			else
				return defaultValue
			end
		else
			if RdKGToolVersioning.VersionLesserThan(clientVersion, requiredVersion) == true then
				if clientVersion.major ~= 0 and clientVersion.minor ~= 0 and clientVersion.revision ~= 0 then
					return RdKGToolAdmin.constants.defaults.UNDEFINED_VERSION
				else
					return RdKGToolAdmin.constants.defaults.UNDEFINED
				end
			else
				if bool == false then
					return RdKGToolAdmin.constants.defaults.DISABLED
				else
					if defaultValue == nil then
						return RdKGToolAdmin.constants.defaults.UNDEFINED
					else
						return defaultValue
					end
				end
			end
		end
	end
end

function RdKGToolAdmin.GetOnOffValues(bool, defaultValue)
	if bool == true then
		return RdKGToolAdmin.constants.defaults.ENABLED
	elseif bool == false then
		return RdKGToolAdmin.constants.defaults.DISABLED
	else
		if defaultValue == nil then
			return RdKGToolAdmin.constants.defaults.UNDEFINED
		else
			return defaultValue
		end
	end
end

function RdKGToolAdmin.GetFailOkColor(bool)
	if bool == true then
		return RdKGToolAdmin.config.configWindow.rating.ok
	elseif bool == false then
		return RdKGToolAdmin.config.configWindow.rating.fail
	else
		return RdKGToolAdmin.config.configWindow.rating.neutral
	end
end

function RdKGToolAdmin.SetValueIfPresent(origin, target, attribute)
	--d(origin)
	--d(target)
	--d(attribute)
	if origin ~= nil and target ~= nil and attribute ~= nil and origin[attribute] ~= nil then
		target[attribute] = origin[attribute]
	end
end

function RdKGToolAdmin.PopulateConfigPanelData(data, player)

	--player
	data.player.displayName = player.displayName
	data.player.charName = player.charName
	
	if player.clientVersion ~= nil and player.clientVersion.major ~= nil and player.clientVersion.minor ~= nil and player.clientVersion.revision ~= nil then
		local highestVersion = RdKGToolVersioning.GetHighestKnownVersionNumber()
		if RdKGToolVersioning.VersionLesserThan(player.clientVersion, highestVersion) == true then
			data.player.versionColor = RdKGToolAdmin.config.configWindow.rating.fail
		else
			data.player.versionColor = RdKGToolAdmin.config.configWindow.rating.ok
		end
		data.player.version.major = player.clientVersion.major
		data.player.version.minor = player.clientVersion.minor
		data.player.version.revision = player.clientVersion.revision
	end
	
	if player.admin ~= nil then
		--client
		if player.admin.client ~= nil then
			---aoe
			if player.admin.client.aoe ~= nil then
				data.client.aoe.tellsEnabled = RdKGToolAdmin.GetOnOffValues(player.admin.client.aoe.tellsEnabled)
				data.client.aoe.tellsEnabledColor = RdKGToolAdmin.GetFailOkColor(player.admin.client.aoe.tellsEnabled)
				data.client.aoe.customEnabled = RdKGToolAdmin.GetOnOffValues(player.admin.client.aoe.customColorEnabled)
				data.client.aoe.customEnabledColor = RdKGToolAdmin.GetFailOkColor(player.admin.client.aoe.customColorEnabled)
				data.client.aoe.friendlyBrightness = player.admin.client.aoe.friendlyBrightness or RdKGToolAdmin.constants.defaults.UNDEFINED
				if player.admin.client.aoe.friendlyBrightness ~= nil then 
					if player.admin.client.aoe.friendlyBrightness < 10 then
						data.client.aoe.friendlyBrightnessColor = RdKGToolAdmin.config.configWindow.rating.fail
					else
						data.client.aoe.friendlyBrightnessColor = RdKGToolAdmin.config.configWindow.rating.ok
					end
				end
				data.client.aoe.enemyBrightness = player.admin.client.aoe.enemyBrightness or RdKGToolAdmin.constants.defaults.UNDEFINED
				if player.admin.client.aoe.enemyBrightness ~= nil then 
					if player.admin.client.aoe.enemyBrightness < 10 then
						data.client.aoe.enemyBrightnessColor = RdKGToolAdmin.config.configWindow.rating.fail
					else
						data.client.aoe.enemyBrightnessColor = RdKGToolAdmin.config.configWindow.rating.ok
					end
				end
			end
			---sounds
			if player.admin.client.sound ~= nil then
				data.client.sound.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.client.sound.soundEnabled)
				data.client.sound.enabledColor = RdKGToolAdmin.GetFailOkColor(player.admin.client.sound.soundEnabled)
				data.client.sound.audioVolume = player.admin.client.sound.audioVolume or RdKGToolAdmin.constants.defaults.UNDEFINED
				if player.admin.client.sound.audioVolume ~= nil then 
					if player.admin.client.sound.audioVolume == 0 then
						data.client.sound.audioVolumeColor = RdKGToolAdmin.config.configWindow.rating.fail
					else
						data.client.sound.audioVolumeColor = RdKGToolAdmin.config.configWindow.rating.ok
					end
				end
				data.client.sound.uiVolume = player.admin.client.sound.uiVolume or RdKGToolAdmin.constants.defaults.UNDEFINED
				if player.admin.client.sound.uiVolume ~= nil then 
					if player.admin.client.sound.uiVolume == 0 then
						data.client.sound.uiVolumeColor = RdKGToolAdmin.config.configWindow.rating.fail
					else
						data.client.sound.uiVolumeColor = RdKGToolAdmin.config.configWindow.rating.ok
					end
				end
				data.client.sound.sfxVolume = player.admin.client.sound.sfxVolume or RdKGToolAdmin.constants.defaults.UNDEFINED
				
				
			end
			---graphics
			if player.admin.client.graphics ~= nil then
				data.client.graphics.windowMode = RdKGToolAdmin.GetWindowMode(player.admin.client.graphics.windowMode)
				data.client.graphics.vsync = RdKGToolAdmin.GetOnOffValues(player.admin.client.graphics.vsync)
				data.client.graphics.antiAliasing = RdKGToolAdmin.GetOnOffValues(player.admin.client.graphics.antiAliasing)
				data.client.graphics.ambient = RdKGToolAdmin.GetOnOffValues(player.admin.client.graphics.ambient)
				data.client.graphics.bloom = RdKGToolAdmin.GetOnOffValues(player.admin.client.graphics.bloom)
				data.client.graphics.depthOfField = RdKGToolAdmin.GetOnOffValues(player.admin.client.graphics.depthOfField)
				data.client.graphics.distortion = RdKGToolAdmin.GetOnOffValues(player.admin.client.graphics.distortion)
				data.client.graphics.sunlight = RdKGToolAdmin.GetOnOffValues(player.admin.client.graphics.sunlight)
				data.client.graphics.allyEffects = RdKGToolAdmin.GetOnOffValues(player.admin.client.graphics.allyEffects)
				data.client.graphics.viewDistance = player.admin.client.graphics.viewDistance or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.client.graphics.resWidth = player.admin.client.graphics.resWidth or RdKGToolAdmin.constants.defaults.UNDEFINED_LINE
				data.client.graphics.resHeight = player.admin.client.graphics.resHeight or RdKGToolAdmin.constants.defaults.UNDEFINED_LINE
				data.client.graphics.particleSupressDistance = player.admin.client.graphics.particleSupressDistance or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.client.graphics.particleMaximum = player.admin.client.graphics.particleMaximum or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.client.graphics.reflectionQuality = RdKGToolAdmin.GetGraphicsQuality(player.admin.client.graphics.reflectionQuality)
				data.client.graphics.shadowQuality = RdKGToolAdmin.GetGraphicsQuality(player.admin.client.graphics.shadowQuality)
				data.client.graphics.subSamplingQuality = RdKGToolAdmin.GetGraphicsQuality(player.admin.client.graphics.subsamplingQuality, 1)
				data.client.graphics.graphicPresets = RdKGToolAdmin.GetGraphicsPresets(player.admin.client.graphics.graphicPresets)
			
			
			
			end
		end
		--addon
		if player.admin.addon ~= nil then
			---crown
			if player.admin.addon.crown ~= nil then
				data.addon.crown.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.crown.enabled)
				if player.admin.addon.crown.enabled == true then
					data.addon.crown.enabledColor = RdKGToolAdmin.config.configWindow.rating.ok
				elseif player.admin.addon.crown.enabled == false then
					data.addon.crown.enabledColor = RdKGToolAdmin.config.configWindow.rating.fail
				end
				data.addon.crown.size = player.admin.addon.crown.size or RdKGToolAdmin.constants.defaults.UNDEFINED
				if data.addon.crown.size ~= nil then
					if data.addon.crown.size >= 64 then
						data.addon.crown.sizeColor = RdKGToolAdmin.config.configWindow.rating.ok
					else
						data.addon.crown.sizeColor = RdKGToolAdmin.config.configWindow.rating.fail
					end
				end
				if player.admin.addon.crown.selectedCrown ~= nil and RdKGTool.group.crown.config.crowns ~= nil and RdKGTool.group.crown.config.crowns[player.admin.addon.crown.selectedCrown] ~= nil then
					data.addon.crown.selectedCrown = RdKGTool.group.crown.config.crowns[player.admin.addon.crown.selectedCrown].name or RdKGToolAdmin.constants.defaults.UNDEFINED
				end
			end
			---ftcv
			if player.admin.addon.ftcv ~= nil then
				data.addon.ftcv.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.ftcv.enabled)
				if player.admin.addon.ftcv.enabled == true then
					data.addon.ftcv.enabledColor = RdKGToolAdmin.config.configWindow.rating.ok
				elseif player.admin.addon.ftcv.enabled == false then
					data.addon.ftcv.enabledColor =  RdKGToolAdmin.config.configWindow.rating.fail
				end
				data.addon.ftcv.sizeClose = player.admin.addon.ftcv.sizeClose or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ftcv.sizeFar = player.admin.addon.ftcv.sizeFar or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ftcv.opacityClose = player.admin.addon.ftcv.opacityClose or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ftcv.opacityFar = player.admin.addon.ftcv.opacityFar or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ftcv.minDistance = player.admin.addon.ftcv.minDistance or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ftcv.maxDistance = player.admin.addon.ftcv.maxDistance or RdKGToolAdmin.constants.defaults.UNDEFINED
				if player.admin.addon.ftcv.maxDistance ~= nil then
					if player.admin.addon.ftcv.maxDistance > 10 then
						data.addon.ftcv.maxDistanceColor = RdKGToolAdmin.config.configWindow.rating.fail
					else
						data.addon.ftcv.maxDistanceColor = RdKGToolAdmin.config.configWindow.rating.ok
					end
				end
				if player.admin.addon.ftcv.opacityFar ~= nil then
					if player.admin.addon.ftcv.opacityFar <= 50 then
						data.addon.ftcv.opacityFarColor = RdKGToolAdmin.config.configWindow.rating.fail
					else
						data.addon.ftcv.opacityFarColor = RdKGToolAdmin.config.configWindow.rating.ok
					end
				end
				if player.admin.addon.ftcv.sizeFar ~= nil then
					if player.admin.addon.ftcv.sizeFar <= 25 then
						data.addon.ftcv.sizeFarColor = RdKGToolAdmin.config.configWindow.rating.fail
					else
						data.addon.ftcv.sizeFarColor = RdKGToolAdmin.config.configWindow.rating.ok
					end
				end
				
			end
			---ftcw
			if player.admin.addon.ftcw ~= nil then
				data.addon.ftcw.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.ftcw.enabled)
				if player.admin.addon.ftcw.enabled == true then
					data.addon.ftcw.enabledColor = RdKGToolAdmin.config.configWindow.rating.ok
				elseif player.admin.addon.ftcw.enabled == false then
					data.addon.ftcw.enabledColor =  RdKGToolAdmin.config.configWindow.rating.fail
				end
				data.addon.ftcw.warningEnabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.ftcw.warningsEnabled)
				if player.admin.addon.ftcw.warningsEnabled == true then
					data.addon.ftcw.warningEnabledColor = RdKGToolAdmin.config.configWindow.rating.ok
				elseif player.admin.addon.ftcw.warningsEnabled == false then
					data.addon.ftcw.warningEnabledColor =  RdKGToolAdmin.config.configWindow.rating.fail
				end
				data.addon.ftcw.distanceEnabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.ftcw.distanceEnabled)
				data.addon.ftcw.maxDistance = player.admin.addon.ftcw.maxDistance or RdKGToolAdmin.constants.defaults.UNDEFINED
				if player.admin.addon.ftcw.maxDistance ~= nil then
					if player.admin.addon.ftcw.maxDistance <= 10 then
						data.addon.ftcw.maxDistanceColor = RdKGToolAdmin.config.configWindow.rating.ok
					else
						data.addon.ftcw.maxDistanceColor =  RdKGToolAdmin.config.configWindow.rating.fail
					end
				end
			end
			---ftca
			if player.admin.addon.ftca ~= nil then
				data.addon.ftca.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.ftca.enabled)
				data.addon.ftca.maxDistance = player.admin.addon.ftca.maxDistance or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ftca.threshold = player.admin.addon.ftca.threshold or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ftca.interval = player.admin.addon.ftca.interval or RdKGToolAdmin.constants.defaults.UNDEFINED
			end
			--ftcb
			if player.admin.addon.ftcb ~= nil then
				data.addon.ftcb.enabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.ftcb.enabled, player.clientVersion, "1.4.0")
				if player.admin.addon.ftcb.enabled == true then
					data.addon.ftcb.enabledColor = RdKGToolAdmin.config.configWindow.rating.ok
				else
					data.addon.ftcb.enabledColor = RdKGToolAdmin.config.configWindow.rating.fail
				end
				if RdKGToolBeams.constants.BEAM[player.admin.addon.ftcb.selectedBeam] ~= nil then
					data.addon.ftcb.selectedBeam = RdKGToolBeams.constants.BEAM[player.admin.addon.ftcb.selectedBeam].name or RdKGToolAdmin.constants.defaults.UNDEFINED
				else
					data.addon.ftcb.selectedBeam = RdKGToolAdmin.constants.defaults.UNDEFINED
				end
				data.addon.ftcb.alpha = player.admin.addon.ftcb.alpha or RdKGToolAdmin.constants.defaults.UNDEFINED
				if player.admin.addon.ftcb.alpha ~= nil then
					if player.admin.addon.ftcb.alpha >= 100 then
						data.addon.ftcb.alphaColor = RdKGToolAdmin.config.configWindow.rating.ok
					else
						data.addon.ftcb.alphaColor = RdKGToolAdmin.config.configWindow.rating.fail
					end
				end
			end
			---dbo
			if player.admin.addon.dbo ~= nil then
				data.addon.dbo.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.dbo.enabled)
			end
			---rt
			if player.admin.addon.rt ~= nil then
				data.addon.rt.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.rt.enabled)
			end
			---ro
			if player.admin.addon.ro ~= nil then
				data.addon.ro.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.ro.enabled)
				if player.admin.addon.ro.enabled == true then
					data.addon.ro.enabledColor = RdKGToolAdmin.config.configWindow.rating.ok
				elseif player.admin.addon.ro.enabled == false then
					data.addon.ro.enabledColor =  RdKGToolAdmin.config.configWindow.rating.fail
				end
				data.addon.ro.ultimateOverviewEnabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.ro.ultimateOverviewEnabled)
				data.addon.ro.clientUltimateEnabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.ro.clientUltimateEnabled)
				data.addon.ro.groupUltimatesEnabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.ro.groupUltimatesEnabled)
				data.addon.ro.showSoftResources = RdKGToolAdmin.GetOnOffValues(player.admin.addon.ro.showSoftResources)
				data.addon.ro.soundEnabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.ro.soundEnabled)
				data.addon.ro.maxDistance = player.admin.addon.ro.maxDistance or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ro.groupSizeDestro = player.admin.addon.ro.groupSizeDestro or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ro.groupSizeStorm = player.admin.addon.ro.groupSizeStorm or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ro.groupSizeNorthernStorm = player.admin.addon.ro.groupSizeNorthernStorm or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ro.groupSizePermafrost = player.admin.addon.ro.groupSizePermafrost or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ro.groupSizeNegate = player.admin.addon.ro.groupSizeNegate or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ro.groupSizeNegateOffensive = player.admin.addon.ro.groupSizeNegateOffensive or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ro.groupSizeNegateCounter = player.admin.addon.ro.groupSizeNegateCounter or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ro.groupSizeNova = player.admin.addon.ro.groupSizeNova or RdKGToolAdmin.constants.defaults.UNDEFINED
				data.addon.ro.groupsEnabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.ro.groupsEnabled, player.clientVersion, "1.16.0")
			end
			---hdm
			if player.admin.addon.hdm ~= nil then
				data.addon.hdm.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.hdm.enabled)
				if player.admin.addon.hdm.enabled == true then
					data.addon.hdm.enabledColor = RdKGToolAdmin.config.configWindow.rating.ok
				elseif player.admin.addon.hdm.enabled == false then
					data.addon.hdm.enabledColor =  RdKGToolAdmin.config.configWindow.rating.fail
				end
				data.addon.hdm.windowEnabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.hdm.windowEnabled)
				data.addon.hdm.viewMode = RdKGToolAdmin.GetSelectedHdmMode(player.admin.addon.hdm.viewMode)
			end
			---po
			if player.admin.addon.po ~= nil then
				data.addon.po.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.po.enabled)
				data.addon.po.soundEnabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.po.soundEnabled)
			end
			---dt
			if player.admin.addon.dt ~= nil then
				data.addon.dt.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.dt.enabled)
			end
			---gb
			if player.admin.addon.gb ~= nil then
				data.addon.gb.enabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.gb.enabled, player.clientVersion, "1.8.0")
			end
			---isdp
			if player.admin.addon.isdp ~= nil then
				data.addon.isdp.enabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.isdp.enabled, player.clientVersion, "1.8.0")
			end
			---yacs
			if player.admin.addon.yacs ~= nil then
				data.addon.yacs.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.yacs.enabled)
				if player.admin.addon.yacs.enabled == true then
					data.addon.yacs.enabledColor = RdKGToolAdmin.config.configWindow.rating.ok
				elseif player.admin.addon.yacs.enabled == false then
					data.addon.yacs.enabledColor = RdKGToolAdmin.config.configWindow.rating.fail
				end
				data.addon.yacs.pvpEnabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.yacs.pvpEnabled)
				if player.admin.addon.yacs.pvpEnabled == true then
					data.addon.yacs.pvpEnabledColor = RdKGToolAdmin.config.configWindow.rating.ok
				elseif player.admin.addon.yacs.pvpEnabled == false then
					data.addon.yacs.pvpEnabledColor = RdKGToolAdmin.config.configWindow.rating.fail
				end
				data.addon.yacs.combatEnabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.yacs.combatEnabled)
				if player.admin.addon.yacs.combatEnabled == true then
					data.addon.yacs.combatEnabledColor = RdKGToolAdmin.config.configWindow.rating.ok
				elseif player.admin.addon.yacs.combatEnabled == false then
					data.addon.yacs.combatEnabledColor = RdKGToolAdmin.config.configWindow.rating.fail
				end
			end
			---sc
			if player.admin.addon.sc ~= nil then
				data.addon.sc.enabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sc.enabled, player.clientVersion, "1.15.2")
			end
			---sm
			if player.admin.addon.sm ~= nil then
				data.addon.sm.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.sm.enabled)
				if player.admin.addon.sm.enabled == true then
					data.addon.sm.enabledColor = RdKGToolAdmin.config.configWindow.rating.ok
				elseif player.admin.addon.sm.enabled == false then
					data.addon.sm.enabledColor = RdKGToolAdmin.config.configWindow.rating.fail
				end
			end
			---recharger
			if player.admin.addon.recharger ~= nil then
				data.addon.recharger.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.recharger.enabled)
				if player.admin.addon.recharger.enabled == true then
					data.addon.recharger.enabledColor = RdKGToolAdmin.config.configWindow.rating.ok
				elseif player.admin.addon.recharger.enabled == false then
					data.addon.recharger.enabledColor = RdKGToolAdmin.config.configWindow.rating.fail
				end
			end
			---kc
			if RdKGToolRoster.IsRdKMember(GetUnitDisplayName("player")) == true then
				if player.admin.addon.kc ~= nil then
					data.addon.kc.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.kc.enabled)
				end
			end
			---bft
			if player.admin.addon.bft ~= nil then
				data.addon.bft.enabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.bft.enabled)
				if player.admin.addon.bft.enabled == true then
					data.addon.bft.enabledColor = RdKGToolAdmin.config.configWindow.rating.ok
				elseif player.admin.addon.bft.enabled == false then
					data.addon.bft.enabledColor = RdKGToolAdmin.config.configWindow.rating.fail
				end
				data.addon.bft.soundEnabled = RdKGToolAdmin.GetOnOffValues(player.admin.addon.bft.soundEnabled)
				data.addon.bft.size = player.admin.addon.bft.size or RdKGToolAdmin.constants.defaults.UNDEFINED
			end
			--cl
			if player.admin.addon.cl ~= nil then
				data.addon.cl.enabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.cl.enabled, player.clientVersion, "1.5.0")
			end
			--cs
			if player.admin.addon.cs ~= nil then
				data.addon.cs.enabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.cs.enabled, player.clientVersion, "1.5.0")
			end
			--respawner
			if player.admin.addon.respawner ~= nil then
				data.addon.respawner.enabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.respawner.enabled, player.clientVersion, "1.8.0")
			end
			--camp
			if player.admin.addon.camp ~= nil then
				data.addon.camp.enabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.camp.enabled, player.clientVersion, "1.8.0")
			end
			--sp
			if player.admin.addon.sp ~= nil then
				data.addon.sp.enabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.enabled, player.clientVersion, "1.9.1")
				if player.admin.addon.sp.mode ~= nil then
					data.addon.sp.mode = RdKGTool.toolbox.sp.constants.MODES[player.admin.addon.sp.mode]
				end
				data.addon.sp.preventCombustionShards = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventCombustionShards, player.clientVersion, "1.16.0")
				data.addon.sp.preventTalons = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventTalons, player.clientVersion, "1.16.0")
				data.addon.sp.preventNova = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventNova, player.clientVersion, "1.16.0")
				data.addon.sp.preventAltar = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventAltar, player.clientVersion, "1.16.0")
				data.addon.sp.preventStandard = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventStandard, player.clientVersion, "1.16.0")
				data.addon.sp.preventRitual = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventRitual, player.clientVersion, "1.16.0")
				data.addon.sp.preventBoneShield = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventBoneShield, player.clientVersion, "1.16.0")
				data.addon.sp.preventConduit = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventConduit, player.clientVersion, "1.16.0")
				data.addon.sp.preventAtronach = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventAtronach, player.clientVersion, "1.16.0")
				data.addon.sp.preventTrappingWebs = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventTrappingWebs, player.clientVersion, "1.16.0")
				data.addon.sp.preventRadiate = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventRadiate, player.clientVersion, "1.16.0")
				data.addon.sp.preventConsumingDarkness = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventConsumingDarkness, player.clientVersion, "1.16.0")
				data.addon.sp.preventSoulLeech = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventSoulLeech, player.clientVersion, "1.16.0")
				data.addon.sp.preventHealingSeed = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventHealingSeed, player.clientVersion, "1.16.0")
				data.addon.sp.preventGraveRobber = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventGraveRobber, player.clientVersion, "1.16.0")
				data.addon.sp.preventPureAgony = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.sp.preventPureAgony, player.clientVersion, "1.16.0")
			end
			--so
			if player.admin.addon.so ~= nil then
				data.addon.so.enabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.so.enabled, player.clientVersion, "1.12.0")
				if player.admin.addon.so.tableMode ~= nil then
					data.addon.so.tableMode = RdKGTool.toolbox.so.constants.TABLE_MODES[player.admin.addon.so.tableMode]
				end
				if player.admin.addon.so.displayMode ~= nil then
					data.addon.so.displayMode = RdKGTool.toolbox.so.constants.DISPLAY_MODES[player.admin.addon.so.displayMode]
				end
			end
			--ra
			if player.admin.addon.ra ~= nil then
				data.addon.ra.enabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.ra.enabled, player.clientVersion, "1.12.0")
				data.addon.ra.allowOverride = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.ra.allowOverride, player.clientVersion, "1.12.0")
			end
			--caj
			if player.admin.addon.caj ~= nil then
				data.addon.caj.enabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.caj.enabled, player.clientVersion, "1.12.0")
			end
			--crBgTp
			if player.admin.addon.crBgTp ~= nil then
				data.addon.crBgTp.enabled = RdKGToolAdmin.GetOnOffValuesVersionDependant(player.admin.addon.crBgTp.enabled, player.clientVersion, "1.14.0")
			end
		end
		--stats
		if player.admin.stats ~= nil then
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "magicka")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "health")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "stamina")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "magickaRecovery")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "healthRecovery")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "staminaRecovery")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "spellDamage")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "weaponDamage")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "spellPenetration")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "weaponPenetration")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "spellCritical")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "weaponCritical")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "spellResistance")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "physicalResistance")
			RdKGToolAdmin.SetValueIfPresent(player.admin.stats, data.stats, "criticalResistance")
			if player.admin.stats.criticalResistance ~= nil then
				if player.admin.stats.criticalResistance <= 1700 then
					data.stats.criticalResistanceColor = RdKGToolAdmin.config.configWindow.rating.fail
				else
					data.stats.criticalResistanceColor = RdKGToolAdmin.config.configWindow.rating.ok
				end			
			end
			if data.stats.spellCritical ~= RdKGToolAdmin.constants.defaults.UNDEFINED then
				data.stats.spellCritical = data.stats.spellCritical .. "%"
			end
			if data.stats.weaponCritical ~= RdKGToolAdmin.constants.defaults.UNDEFINED then
				data.stats.weaponCritical = data.stats.weaponCritical .. "%"
			end
		end
		--mundus
		if player.admin.mundus ~= nil then
			RdKGToolAdmin.SetValueIfPresent(player.admin.mundus, data.mundus, "stone1")
			RdKGToolAdmin.SetValueIfPresent(player.admin.mundus, data.mundus, "stone2")
		end
		--cp
		if player.admin.cp ~= nil then
			for key, value in pairs(player.admin.cp) do 
				data.cp[key] = value
			end
		end
		--skills
		if player.admin.skills ~= nil and player.admin.skills.bars ~=nil then
			if player.admin.skills.bars[1] ~= nil then
				for i = 1, 6 do
					if player.admin.skills.bars[1][i] ~= nil and player.admin.skills.bars[1][i] ~= 0 then
						data.skills[i].id = player.admin.skills.bars[1][i]
						data.skills[i].texture = GetAbilityIcon(data.skills[i].id)
					end
				end
			end
			if player.admin.skills.bars[2] ~= nil then
				for i = 1, 6 do
					if player.admin.skills.bars[2][i] ~= nil and player.admin.skills.bars[2][i] ~= 0 then
						data.skills[i + 6].id = player.admin.skills.bars[2][i]
						data.skills[i + 6].texture = GetAbilityIcon(data.skills[i + 6].id)
					end
				end
			end
		end
		
		--equipment
		if player.admin.equipment ~= nil then
			for i = 1, #RdKGToolAdmin.constants.equipment do
				local name = RdKGToolAdmin.constants.equipment[i].name
				if name ~= nil and player.admin.equipment[name] ~= nil and player.admin.equipment[name].link ~= nil then
					local entry = data.equipment[name]
					entry.link = player.admin.equipment[name].link
					entry.texture = GetItemLinkIcon(player.admin.equipment[name].link)
					local line1 = ""
					local line2 = ""
					local level = GetItemLinkRequiredChampionPoints(entry.link)
					if level ~= 0 then
						level = "cp|c" .. RdKGToolAdmin.config.configWindow.equipmentValue .. level .. "|r"
					else
						level = "lv|c" .. RdKGToolAdmin.config.configWindow.equipmentValue .. GetItemLinkRequiredLevel(entry.link) .. "|r"
					end
					local _, enchant = GetItemLinkEnchantInfo(entry.link)
					if RdKGToolAdmin.constants.equipment[i].eType == RdKGToolAdmin.constants.equipmentType.ARMOR then
						line1 = zo_strformat("<<C:1>> <<2>>", GetString("SI_ARMORTYPE", GetItemLinkArmorType(entry.link)), GetString(SI_ITEM_FORMAT_STR_ARMOR))
						line1 = line1 .. " - |c"  .. RdKGToolAdmin.config.configWindow.equipmentValue .. GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo(entry.link)) .. "|r"
						line1 = line1 .. " - " .. level
						
						
						line2 = zo_strformat("<<1>>: |c" .. RdKGToolAdmin.config.configWindow.equipmentValue .. "<<2>>|r", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetItemLinkArmorRating(entry.link))
						line2 = line2 .. " - |c" .. RdKGToolAdmin.config.configWindow.equipmentValue .. enchant .. "|r"
					elseif RdKGToolAdmin.constants.equipment[i].eType == RdKGToolAdmin.constants.equipmentType.WEAPON then
						line1 = zo_strformat("|c" .. RdKGToolAdmin.config.configWindow.equipmentValue .. "<<1>> |r<<C:2>>", GetString("SI_WEAPONTYPE", GetItemLinkWeaponType(entry.link)), GetString("SI_EQUIPTYPE", GetItemLinkEquipType(entry.link)))
						line1 = line1 .. " - |c"  .. RdKGToolAdmin.config.configWindow.equipmentValue .. GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo(entry.link)) .. "|r"
						line1 = line1 .. " - " .. level
						
						line2 = zo_strformat("|c" .. RdKGToolAdmin.config.configWindow.equipmentValue .. "<<1>>|r <<C:2>>", GetString("SI_WEAPONTYPE", GetItemLinkWeaponType(entry.link)), GetString("SI_EQUIPTYPE", GetItemLinkEquipType(entry.link)))
				
						if GetItemLinkWeaponType(entry.link) == WEAPONTYPE_SHIELD then
							line2 = zo_strformat("<<1>>: |c" .. RdKGToolAdmin.config.configWindow.equipmentValue .. "<<2>>|r", GetString(SI_ITEM_FORMAT_STR_ARMOR), GetItemLinkArmorRating(entry.link))
						else 
							line2 = zo_strformat("<<1>>: |c" .. RdKGToolAdmin.config.configWindow.equipmentValue .. "<<2>>|r", GetString(SI_ITEM_FORMAT_STR_DAMAGE), GetItemLinkWeaponPower(entry.link)) 
						end
						line2 = line2 .. " - |c" .. RdKGToolAdmin.config.configWindow.equipmentValue .. enchant .. "|r"
					elseif RdKGToolAdmin.constants.equipment[i].eType == RdKGToolAdmin.constants.equipmentType.ACCESSORIES then
						line1 = zo_strformat("|c" .. RdKGToolAdmin.config.configWindow.equipmentValue .. "<<1>>|r", GetString("SI_EQUIPTYPE", GetItemLinkEquipType(entry.link)))
						line1 = line1 .. " - |c" .. RdKGToolAdmin.config.configWindow.equipmentValue .. GetString("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo(entry.link)) .. "|r"
						line1 = line1 .. " - " .. level
						line2 = "|c" .. RdKGToolAdmin.config.configWindow.equipmentValue .. enchant .. "|r"
					end
					
					entry.line1 = line1
					entry.line2 = line2
				end
			end		
		end
	end
	return data
end

function RdKGToolAdmin.GetGraphicsQuality(value, offset)
	if value ~= nil and offset ~= nil then
		value = value + offset
	end
	local quality = RdKGToolAdmin.constants.defaults.qualitySelection[value]
	if quality == nil then
		quality = RdKGToolAdmin.constants.defaults.UNDEFINED
	end
	return quality
end

function RdKGToolAdmin.GetGraphicsPresets(value)
	local preset = RdKGToolAdmin.constants.defaults.graphicPresets[value]
	if preset == nil then
		preset = RdKGToolAdmin.constants.defaults.UNDEFINED
	end
	return preset
end

function RdKGToolAdmin.GetWindowMode(value)
	local windowMode = RdKGToolAdmin.constants.defaults.viewModes[value]
	if windowMode == nil then
		windowMode = RdKGToolAdmin.constants.defaults.UNDEFINED
	end
	return windowMode
end

function RdKGToolAdmin.GetSelectedHdmMode(value)
	local viewMode = RdKGTool.group.hdm.constants.viewModes[value]
	if viewMode == nil then
		viewMode = RdKGToolAdmin.constants.defaults.UNDEFINED
	end
	return viewMode
end

function RdKGToolAdmin.CreateConfigPanelData(index)
	local data = RdKGToolAdmin.CreateDefaultDataTemplate()
	local playerEntry = RdKGToolAdmin.state.playerList[index]
	local players = RdKGToolGroup.GetGroupInformation()
	if playerEntry ~= nil and players ~= nil then
		local player = nil
		for i = 1, #players do
			if players[i].unitTag == playerEntry.unitTag then
				player = players[i]
				break
			end
		end
		--d(player.unitTag)
		if player ~= nil then
			--Populate Default Panel
			data = RdKGToolAdmin.PopulateConfigPanelData(data, player)
		end
	end
	return data
end

--callbacks
function RdKGToolAdmin.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolAdmin.adminVars = currentProfile.admin
		RdKGToolAdmin.vars = currentProfile
		RdKGToolAdmin.charVars = RdKGTool.profile.GetCharacterVars()
		if RdKGToolAdmin.state.initialized == true then
			RdKGToolAdmin.SetTlwLocation()
		end
	end
end

function RdKGToolAdmin.SaveWindowLocation()
	RdKGToolAdmin.adminVars.position = RdKGToolAdmin.adminVars.position or {}
	RdKGToolAdmin.adminVars.position.x = RdKGToolAdmin.controls.TLW:GetLeft()
	RdKGToolAdmin.adminVars.position.y = RdKGToolAdmin.controls.TLW:GetTop()
end

function RdKGToolAdmin.CloseWindow()
	RdKGToolAdmin.controls.TLW:SetHidden(true)
	RdKGToolGroup.RemoveGroupChangedCallback(RdKGToolAdmin.callbackName)
	SetGameCameraUIMode(not RdKGToolAdmin.controls.TLW:IsHidden())
end

function RdKGToolAdmin.OnKeyBinding()
	RdKGToolAdmin.ToggleAdminInterface()
end

function RdKGToolAdmin.AdjustAdminInformation(unitTag)
	if RdKGToolAdmin.state.selectedIndex > 0 then
		local player = RdKGToolAdmin.state.playerList[RdKGToolAdmin.state.selectedIndex]
		if player ~= nil then
			if player.unitTag == unitTag then
				RdKGToolAdmin.PopulateConfigPanel(RdKGToolAdmin.CreateConfigPanelData(RdKGToolAdmin.state.selectedIndex))
			end
		end
	end
end

function RdKGToolAdmin.HandleRawAdminNetworkMessage(message)
	if RdKGToolAdmin.adminVars.enabled == false then
		if RdKGToolRoster.IsRdKMember(GetUnitDisplayName("player")) == true and RdKGToolRoster.IsRdKAdmin(GetUnitDisplayName(message.pingTag)) then
		else
			return
		end
	end
	if message ~= nil and message.b0 ~= nil and (message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_REQUEST or message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_REQUEST_EQUIPMENT_INFORMATION) and message.b1 ~= nil and message.b2 ~= nil and message.b3 ~= nil and RdKGToolRoster.IsGuildOfficerOf(GetUnitDisplayName("player"),GetUnitDisplayName(message.pingTag)) then
		
		local respondToMessage = false
		if message.b1 == 25 then
			respondToMessage = true
		else
			local players = RdKGToolGroup.GetGroupInformation()
			if players ~= nil and players[message.b1] ~= nil and players[message.b1].displayName == GetUnitDisplayName("player") and players[message.b1].charName == GetUnitName("player") then
				respondToMessage = true
			end
		end
		if respondToMessage == true then
			if message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_REQUEST then
				RdKGToolAdmin.HandleAdminRequest(message.b2, message.b3, message.pingTag)
			elseif message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_ADMIN_REQUEST_EQUIPMENT_INFORMATION then
				RdKGToolAdmin.HandleEquipmentRequest(message.b3, message.pingTag)
			end
		end
	end
end

function RdKGToolAdmin.ConfigPanelOnMouseWheel(control, delta)
	
	if RdKGToolAdmin.controls.TLW.config.slider:IsHidden() == false then
		local size = 100 / 100 --fix later
		if size < 1 then
			size = 1
		end
		local position = -delta * size * 2 + RdKGToolAdmin.controls.TLW.config.slider:GetValue()
		
		if position < 0 then
			position = 0
		end
		if position > 100 then
			position = 100
		end
		RdKGToolAdmin.controls.TLW.config.slider:SetValue(position)
	end
end

function RdKGToolAdmin.AdjustConfigSlider()
	local size = (RdKGToolAdmin.state.size - RdKGToolAdmin.config.height)
	if size < 0 then
		size = 0
	end
	
	local slide = size / 100 * RdKGToolAdmin.controls.TLW.config.slider:GetValue()
	
	RdKGToolAdmin.controls.TLW.config.scrollPanel:SetSimpleAnchor(RdKGToolAdmin.controls.TLW.config.scrollControl, 0, -slide)
end

function RdKGToolAdmin.PlayerEntryOnMouseEnter(index)
	if index ~= nil and index >= 1 and index <= 25 then
		if RdKGToolAdmin.state.selectedIndex == index then
			RdKGToolAdmin.controls.TLW.player.blocks[index].backdrop:SetCenterColor(RdKGToolAdmin.config.color.playerEntryColorSelectedHover.r, RdKGToolAdmin.config.color.playerEntryColorSelectedHover.g, RdKGToolAdmin.config.color.playerEntryColorSelectedHover.b, RdKGToolAdmin.config.color.playerEntryColorSelectedHover.a)
			RdKGToolAdmin.controls.TLW.player.blocks[index].backdrop:SetEdgeColor(RdKGToolAdmin.config.color.playerEntryColorSelectedHover.r, RdKGToolAdmin.config.color.playerEntryColorSelectedHover.g, RdKGToolAdmin.config.color.playerEntryColorSelectedHover.b, 0.0)		
		else
			RdKGToolAdmin.controls.TLW.player.blocks[index].backdrop:SetCenterColor(RdKGToolAdmin.config.color.playerEntryColorHover.r, RdKGToolAdmin.config.color.playerEntryColorHover.g, RdKGToolAdmin.config.color.playerEntryColorHover.b, RdKGToolAdmin.config.color.playerEntryColorHover.a)
			RdKGToolAdmin.controls.TLW.player.blocks[index].backdrop:SetEdgeColor(RdKGToolAdmin.config.color.playerEntryColorHover.r, RdKGToolAdmin.config.color.playerEntryColorHover.g, RdKGToolAdmin.config.color.playerEntryColorHover.b, 0.0)		
		end
	end
end

function RdKGToolAdmin.PlayerEntryOnMouseExit(index)
	if index ~= nil and index >= 1 and index <= 25 then
			if RdKGToolAdmin.state.selectedIndex == index then
			RdKGToolAdmin.controls.TLW.player.blocks[index].backdrop:SetCenterColor(RdKGToolAdmin.config.color.playerEntryColorSelected.r, RdKGToolAdmin.config.color.playerEntryColorSelected.g, RdKGToolAdmin.config.color.playerEntryColorSelected.b, RdKGToolAdmin.config.color.playerEntryColorSelected.a)
			RdKGToolAdmin.controls.TLW.player.blocks[index].backdrop:SetEdgeColor(RdKGToolAdmin.config.color.playerEntryColorSelected.r, RdKGToolAdmin.config.color.playerEntryColorSelected.g, RdKGToolAdmin.config.color.playerEntryColorSelected.b, 0.0)		
		else
			RdKGToolAdmin.controls.TLW.player.blocks[index].backdrop:SetCenterColor(RdKGToolAdmin.config.color.playerEntryColorHover.r, RdKGToolAdmin.config.color.playerEntryColorHover.g, RdKGToolAdmin.config.color.playerEntryColorHover.b, 0.0)
			RdKGToolAdmin.controls.TLW.player.blocks[index].backdrop:SetEdgeColor(RdKGToolAdmin.config.color.playerEntryColorHover.r, RdKGToolAdmin.config.color.playerEntryColorHover.g, RdKGToolAdmin.config.color.playerEntryColorHover.b, 0.0)		
		end
	end
end

function RdKGToolAdmin.PlayerEntryOnClick(index)
	if index ~= nil and index >= 1 and index <= #RdKGToolAdmin.state.playerList then
		RdKGToolAdmin.state.selectedIndex = index
		for i = 1, 25 do
			RdKGToolAdmin.PlayerEntryOnMouseExit(i)
		end
		RdKGToolAdmin.PlayerEntryOnMouseEnter(index)
		--d(index)
		RdKGToolAdmin.PopulateConfigPanel(RdKGToolAdmin.CreateConfigPanelData(index))
		
	end
end

function RdKGToolAdmin.EquipmentEntryOnMouseEnter(index)
	local entry = RdKGToolAdmin.constants.equipment[index]
	if entry ~= nil and entry.name ~= nil and RdKGToolAdmin.controls.TLW.config.scrollPanel.equipment[entry.name] ~= nil and RdKGToolAdmin.controls.TLW.config.scrollPanel.equipment[entry.name].textureBackdrop ~= nil then
		local name = entry.name
		RdKGToolAdmin.controls.TLW.config.scrollPanel.equipment[name].textureBackdrop:SetCenterColor(RdKGToolAdmin.config.color.equipmentHover.r, RdKGToolAdmin.config.color.equipmentHover.g, RdKGToolAdmin.config.color.equipmentHover.b, RdKGToolAdmin.config.color.equipmentHover.a)
		RdKGToolAdmin.controls.TLW.config.scrollPanel.equipment[name].textureBackdrop:SetEdgeColor(RdKGToolAdmin.config.color.equipmentHover.r, RdKGToolAdmin.config.color.equipmentHover.g, RdKGToolAdmin.config.color.equipmentHover.b, 0.0)
	end
end
			
function RdKGToolAdmin.EquipmentEntryOnMouseExit(index)
	local entry = RdKGToolAdmin.constants.equipment[index]
	if entry ~= nil and entry.name ~= nil and RdKGToolAdmin.controls.TLW.config.scrollPanel.equipment[entry.name] ~= nil and RdKGToolAdmin.controls.TLW.config.scrollPanel.equipment[entry.name].textureBackdrop ~= nil then
		local name = entry.name
		RdKGToolAdmin.controls.TLW.config.scrollPanel.equipment[name].textureBackdrop:SetCenterColor(RdKGToolAdmin.config.color.equipmentHover.r, RdKGToolAdmin.config.color.equipmentHover.g, RdKGToolAdmin.config.color.equipmentHover.b, 0.0)
		RdKGToolAdmin.controls.TLW.config.scrollPanel.equipment[name].textureBackdrop:SetEdgeColor(RdKGToolAdmin.config.color.equipmentHover.r, RdKGToolAdmin.config.color.equipmentHover.g, RdKGToolAdmin.config.color.equipmentHover.b, 0.0)
	end
end

function RdKGToolAdmin.EquipmentEntryOnClick(index)
	local entry = RdKGToolAdmin.constants.equipment[index]
	if entry ~= nil and entry.name ~= nil and RdKGToolAdmin.controls.TLW.config.scrollPanel.equipment[entry.name] ~= nil and RdKGToolAdmin.controls.TLW.config.scrollPanel.equipment[entry.name].textureBackdrop ~= nil then
		ClearMenu()
		if RdKGToolAdmin.controls.TLW.config.scrollPanel.equipment[entry.name].link.link ~= nil then
			AddCustomMenuItem(RdKGToolAdmin.constants.config.EQUIPMENT_CONTEXT_LINK_IN_CHAT, function() RdKGToolAdmin.LinkInChat(RdKGToolAdmin.controls.TLW.config.scrollPanel.equipment[entry.name].link.link) end)
		end
		AddCustomMenuItem(RdKGToolAdmin.constants.config.EQUIPMENT_CONTEXT_REQUEST, function() RdKGToolAdmin.RequestEquipmentItem(index, RdKGToolAdmin.state.selectedIndex) end)

		ShowMenu(RdKGToolAdmin.controls.TLW.config.scrollPanel.equipment[entry.name].textureBackdrop)
	end
end


--menu interaction
function RdKGToolAdmin.GetMenu()
	local menu = {
		[1] = {
			type = "header",
			name = RdKGToolMenu.constants.ADMIN_HEADER,
			width = "full",
		},
		[2] = {
			type = "submenu",
			name = RdKGToolMenu.constants.ADMIN_GROUP_SHARE_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ENABLED,
					getFunc = RdKGToolAdmin.GetAdminEnabled,
					setFunc = RdKGToolAdmin.SetAdminEnabled
				},
				[2] = {
					type = "description",
					title = nil,
					text = RdKGToolMenu.constants.ADMIN_GROUP_SHARE_WARNING,
					width = "full"
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_CLIENT_CONFIGURATION,
					getFunc = RdKGToolAdmin.GetAdminAllowClientConfiguration,
					setFunc = RdKGToolAdmin.SetAdminAllowClientConfiguration
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_ADDON_CONFIGURATION,
					getFunc = RdKGToolAdmin.GetAdminAllowAddOnConfiguration,
					setFunc = RdKGToolAdmin.SetAdminAllowAddOnConfiguration
				},
				[5] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_STATS,
					getFunc = RdKGToolAdmin.GetAdminAllowStats,
					setFunc = RdKGToolAdmin.SetAdminAllowStats
				},
				[6] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_SKILLS,
					getFunc = RdKGToolAdmin.GetAdminAllowSkills,
					setFunc = RdKGToolAdmin.SetAdminAllowSkills
				},
				[7] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_EQUIPMENT,
					getFunc = RdKGToolAdmin.GetAdminAllowEquipment,
					setFunc = RdKGToolAdmin.SetAdminAllowEquipment
				},
				[8] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.ADMIN_GROUP_SHARE_ALLOW_CP,
					getFunc = RdKGToolAdmin.GetAdminAllowCp,
					setFunc = RdKGToolAdmin.SetAdminAllowCp
				},
			}
		}
	}
	return menu
end

function RdKGToolAdmin.GetAdminEnabled()
	return RdKGToolAdmin.adminVars.enabled
end

function RdKGToolAdmin.SetAdminEnabled(value)
	RdKGToolAdmin.adminVars.enabled = value
end

function RdKGToolAdmin.GetAdminAllowClientConfiguration()
	return RdKGToolAdmin.adminVars.allowClientConfiguration
end

function RdKGToolAdmin.SetAdminAllowClientConfiguration(value)
	RdKGToolAdmin.adminVars.allowClientConfiguration = value
end

function RdKGToolAdmin.GetAdminAllowAddOnConfiguration()
	return RdKGToolAdmin.adminVars.allowAddonConfiguration
end

function RdKGToolAdmin.SetAdminAllowAddOnConfiguration(value)
	RdKGToolAdmin.adminVars.allowAddonConfiguration = value
end

function RdKGToolAdmin.GetAdminAllowStats()
	return RdKGToolAdmin.adminVars.allowStats
end

function RdKGToolAdmin.SetAdminAllowStats(value)
	RdKGToolAdmin.adminVars.allowStats = value
end

function RdKGToolAdmin.GetAdminAllowSkills()
	return RdKGToolAdmin.adminVars.allowSkills
end

function RdKGToolAdmin.SetAdminAllowSkills(value)
	RdKGToolAdmin.adminVars.allowSkills = value
end

function RdKGToolAdmin.GetAdminAllowEquipment()
	return RdKGToolAdmin.adminVars.allowEquipment
end

function RdKGToolAdmin.SetAdminAllowEquipment(value)
	RdKGToolAdmin.adminVars.allowEquipment = value
end

function RdKGToolAdmin.GetAdminAllowCp()
	return RdKGToolAdmin.adminVars.allowCp
end

function RdKGToolAdmin.SetAdminAllowCp(value)
	RdKGToolAdmin.adminVars.allowCp = value
end