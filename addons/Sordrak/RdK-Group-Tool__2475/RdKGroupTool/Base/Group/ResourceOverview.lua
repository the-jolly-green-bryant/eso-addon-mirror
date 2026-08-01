-- RdK Group Tool Resource Overview
-- By @s0rdrak (PC / EU)

RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGTool.group = RdKGTool.group or {}
local RdKGToolGroup = RdKGTool.group
RdKGToolGroup.ro = RdKGToolGroup.ro or {}
local RdKGToolOverview = RdKGToolGroup.ro
RdKGToolGroup.dbo = RdKGToolGroup.dbo or {}
local RdKGToolDbo = RdKGToolGroup.dbo
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGToolUtil.ultimates = RdKGToolUtil.ultimates or {}
local RdKGToolUltimates = RdKGToolUtil.ultimates
RdKGToolUtil.networking = RdKGToolUtil.networking or {}
local RdKGToolNetworking = RdKGToolUtil.networking
RdKGToolUtil.group = RdKGToolUtil.group or {}
local RdKGToolUtilGroup = RdKGToolUtil.group
RdKGToolUtil.sound = RdKGToolUtil.sound or {}
local RdKGToolSound = RdKGToolUtil.sound
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts
RdKGToolUtil.math = RdKGToolUtil.math or {}
local RdKGToolMath = RdKGToolUtil.math

RdKGToolOverview.constants = RdKGToolOverview.constants or {}
RdKGToolOverview.constants.TLW_CLIENT_ULTIMATE_NAME = "RdKGTool.group.ro.client_ultimate_TLW"
RdKGToolOverview.constants.TLW_GROUP_ULTIMATES_NAME = "RdKGTool.group.ro.group_ultimates_TLW"
RdKGToolOverview.constants.TLW_GROUP_ASSIGNMENT_NAME = "RdKGTool.group.ro.group_assignment_TLW"
RdKGToolOverview.constants.TLW_ULTIMATE_OVERVIEW_NAME = "RdKGTool.group.ro.ultimate_overview_TLW"
RdKGToolOverview.constants.TLW_GROUPS_GROUP = {}
RdKGToolOverview.constants.TLW_GROUPS_GROUP[1] = "RdKGTool.group.ro.groups_group_1_TLW"
RdKGToolOverview.constants.TLW_GROUPS_GROUP[2] = "RdKGTool.group.ro.groups_group_2_TLW"
RdKGToolOverview.constants.TLW_GROUPS_GROUP[3] = "RdKGTool.group.ro.groups_group_3_TLW"
RdKGToolOverview.constants.TLW_GROUPS_GROUP[4] = "RdKGTool.group.ro.groups_group_4_TLW"
RdKGToolOverview.constants.TLW_GROUPS_GROUP[5] = "RdKGTool.group.ro.groups_group_5_TLW"
RdKGToolOverview.constants.TLW_GROUPS_EMPTY = "RdKGTool.group.ro.groups_group_EMPTY"

RdKGToolOverview.constants.groupsModes = {}
RdKGToolOverview.constants.groupsModes.MODE_PRIORITY_NAME = 1
RdKGToolOverview.constants.groupsModes.MODE_PRIORITY_PERCENT = 2
RdKGToolOverview.constants.groupsModes.MODE_PERCENT = 3

RdKGToolOverview.constants.ultimateModes = {}
RdKGToolOverview.constants.ultimateModes.ORDER_BY_READINESS = 1
RdKGToolOverview.constants.ultimateModes.ORDER_BY_NAME = 2
RdKGToolOverview.constants.ultimateModes.ORDER_BY_GROUP = 3

RdKGToolOverview.constants.displayModes = {}
RdKGToolOverview.constants.displayModes.CLASSIC = 1
RdKGToolOverview.constants.displayModes.SWIMLANES = 2

RdKGToolOverview.constants.OFFLINE_TRESHOLD = 30000

RdKGToolOverview.constants.ULTIMATE_OVERVIEW_STRING = "%d/%d %s:"

RdKGToolOverview.constants.references = RdKGToolOverview.constants.references or {}
RdKGToolOverview.constants.references.GROUPS_DROPDOWN = "RdKGTool.group.ro.groups.assignment."

RdKGToolOverview.constants.size = {}
RdKGToolOverview.constants.size.SMALL = 1
RdKGToolOverview.constants.size.BIG = 2

RdKGToolOverview.callbackName = RdKGTool.addonName .. "ResourceOverview"
RdKGToolOverview.uiCallbackName = RdKGTool.addonName .. "ResourceOverviewUI"
RdKGToolOverview.groupsUiCallbackName = RdKGTool.addonName .. "ResourceOverviewGroupsUI"
RdKGToolOverview.networkingCallbackName = RdKGTool.addonName .. "ResourceOverviewNetworking"
RdKGToolOverview.messageCallbackName = RdKGTool.addonName .. "ResourceOverviewMessageUpdate"

RdKGToolOverview.config = {}
RdKGToolOverview.config.networkUpdateInterval = 2000
RdKGToolOverview.config.messageUpdateInterval = 1000 -- 100
RdKGToolOverview.config.uiUpdateInterval = 100
RdKGToolOverview.config.groupsUiUpdateInterval = 100
RdKGToolOverview.config.buffUpdateInterval = 100
RdKGToolOverview.config.clientUltimate = {}
RdKGToolOverview.config.clientUltimate.isClampedToScreen = true
RdKGToolOverview.config.groupUltimates = {}
RdKGToolOverview.config.groupUltimates.isClampedToScreen = true
RdKGToolOverview.config.groupAssignments = {}
RdKGToolOverview.config.groupAssignments.isClampedToScreen = true
RdKGToolOverview.config.ultimateOverview = {}
RdKGToolOverview.config.ultimateOverview.isClampedToScreen = true
RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL] = {}
RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].blockHeight = 30
RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].width = 160
RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].height = RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].blockHeight * 4
RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].fontSize = 26
RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.BIG] = {}
RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.BIG].blockHeight = 40
RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.BIG].width = 210
RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.BIG].height = RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.BIG].blockHeight * 4
RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.BIG].fontSize = 34
RdKGToolOverview.config.font = "ZoFontGameSmall"
RdKGToolOverview.config.sizes = {}
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL] = {}
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset = 12
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth = 50
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight = 50
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockWidth = RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockHeight = 25
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockStaminaHeight = 5
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockMagickaHeight = 5
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockGroupWidth = 10
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].fontSize = 13
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].spacingRatio = 1.0
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].border = 2
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG] = {}
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].offset = 12
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].ultiIconWidth = 70
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].ultiIconHeight = 70
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockWidth = RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].ultiIconWidth
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockHeight = 35
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockStaminaHeight = 7
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockMagickaHeight = 7
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockGroupWidth = 15
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].fontSize = 18
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].spacingRatio = 1.3
RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].border = 3
RdKGToolOverview.config.swimLaneSizes = {}
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL] = {}
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].offset = 12
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth = 20
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight = 20
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockWidth = 75
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockHeight = 25
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockStaminaHeight = 5
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockMagickaHeight = 5
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockGroupWidth = 10
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].fontSizePlayer = 13
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].fontSizeHeader = 16
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].spacingRatio = 1.0
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG] = {}
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].offset = 12
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].ultiIconWidth = 40
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].ultiIconHeight = 40
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].playerBlockWidth = 150
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].playerBlockHeight = 35
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].playerBlockStaminaHeight = 7
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].playerBlockMagickaHeight = 7
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].playerBlockGroupWidth = 20
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].fontSizePlayer = 26
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].fontSizeHeader = 36
RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].spacingRatio = 2.0

RdKGToolOverview.config.ultimateModes = {}
RdKGToolOverview.config.groupsModes = {}
RdKGToolOverview.config.displayModes = {}
RdKGToolOverview.config.groups = {}
--RdKGToolOverview.config.groups.width = 175
--RdKGToolOverview.config.groups.height = 100
--RdKGToolOverview.config.groups.entryWidth = 175
--RdKGToolOverview.config.groups.entryHeight = 25
--RdKGToolOverview.config.groups.entryPercentWidth = 50
--RdKGToolOverview.config.groups.softHeight = 3
RdKGToolOverview.config.groups.isClampedToScreen = true
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL] = {}
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].width = 175
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].height = 100
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth = 175
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight = 25
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryPercentWidth = 50
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].softHeight = 3
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].captionFontSize = RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - 8
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].fontSizeWithResources = RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - 13
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].fontSizeWithoutResources = RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - 13
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].edgeSize = 2 --not used and not working properly
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG] = {}
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].width = 225
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].height = 130
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].entryWidth = 225
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].entryHeight = 32
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].entryPercentWidth = 66
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].softHeight = 4
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].captionFontSize = RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].entryHeight - 10
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].fontSizeWithResources = RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].entryHeight - 20
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].fontSizeWithoutResources = RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].entryHeight - 14
RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].edgeSize = 2 --not used and not working properly

RdKGToolOverview.state = {}
RdKGToolOverview.state.initialized = false
RdKGToolOverview.state.foreground = true
RdKGToolOverview.state.registredConsumers = false
RdKGToolOverview.state.registredActiveConsumers = false
RdKGToolOverview.state.registredGroupsConsumers = false
RdKGToolOverview.state.registredGlobalConsumers = false
RdKGToolOverview.state.lastMessage = nil
RdKGToolOverview.state.groupUltimateStacks = {}
RdKGToolOverview.state.groupUltimateAssignments = {}
RdKGToolOverview.state.useUltimateCommandReceived = false
RdKGToolOverview.state.useUltimateCommandTimeStamp = 0
RdKGToolOverview.state.sentUltimateCommandTimeStamp = 0
RdKGToolOverview.state.lastBoom = 0
RdKGToolOverview.state.lastUrgentMessage = nil
RdKGToolOverview.state.references = {}
RdKGToolOverview.state.groupsEntryHeight = RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight
RdKGToolOverview.state.playerBlockWidth = RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockWidth
RdKGToolOverview.state.playerBlockHeight = RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockHeight
RdKGToolOverview.state.ultiIconHeight = RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight
RdKGToolOverview.state.offset = RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset
RdKGToolOverview.state.spacing = 0
RdKGToolOverview.state.cominedFontNormal = nil
RdKGToolOverview.state.cominedFontStealth = nil
RdKGToolOverview.state.splitFontNormal = nil
RdKGToolOverview.state.splitFontStealth = nil

RdKGToolOverview.controls = {}

local wm = WINDOW_MANAGER

function RdKGToolOverview.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolOverview.callbackName, RdKGToolOverview.OnProfileChanged)
	ZO_CreateStringId("SI_BINDING_NAME_RDKGTOOL_RESOURCEOVERVIEW_BOOM", RdKGToolOverview.constants.TOGGLE_BOOM)
	RdKGToolOverview.state.sounds = RdKGToolSound.GetRestrictedSounds()
	
	RdKGToolOverview.CreateDefaultUI()
	RdKGToolOverview.CreateGroupsUI()
	--[[
		Finalisation
	]]
	RdKGToolOverview.SetTlwLocation()
	RdKGToolOverview.SetPositionLocked(RdKGToolOverview.roVars.positionLocked)
	RdKGToolOverview.SetDisplayedUltimates(RdKGToolOverview.roVars.groupUltimatesSettings.displayedUltimates)
	RdKGToolOverview.SetControlVisibility()
	RdKGToolOverview.AdjustGroupsShowSoftResources()
	RdKGToolOverview.AdjustGroupsColor()
	RdKGToolOverview.AdjustInCombatSettings()
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolOverview.SetRoPositionLocked)
		
	RdKGToolOverview.state.initialized = true
	RdKGToolOverview.InitializeControlSettings()
end

function RdKGToolOverview.InitializeControlSettings()
	--RdKGToolOverview.AdjustStaminaMagickaBarVisibility()
	RdKGToolOverview.AdjustColors()
	RdKGToolOverview.SetEnabled(RdKGToolOverview.roVars.enabled)
	RdKGToolOverview.AdjustGroupNames()

	RdKGToolOverview.AdjustSize()
	RdKGToolOverview.AdjustStaminaMagickaBarVisibility()
end

function RdKGToolOverview.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.pvpOnly = true
	defaults.positionLocked = false
	defaults.ultimateOverviewSettings = {}
	defaults.ultimateOverviewSettings.enabled = false
	
	defaults.clientUltimateSettings = {}
	defaults.clientUltimateSettings.enabled = true
	
	defaults.size = RdKGToolOverview.constants.size.SMALL
	
	defaults.groupUltimatesSettings = {}
	defaults.groupUltimatesSettings.enabled = true
	defaults.groupUltimatesSettings.displayedUltimates = 6
	defaults.groupUltimatesSettings.ultimates = {}
	defaults.groupUltimatesSettings.ultimates[1] = 15
	defaults.groupUltimatesSettings.ultimates[2] = 1
	defaults.groupUltimatesSettings.ultimates[3] = 13
	defaults.groupUltimatesSettings.ultimates[4] = 24
	defaults.groupUltimatesSettings.ultimates[5] = 6
	defaults.groupUltimatesSettings.ultimates[6] = 12
	defaults.groupUltimatesSettings.ultimates[7] = 5
	defaults.groupUltimatesSettings.ultimates[8] = 7
	defaults.groupUltimatesSettings.ultimates[9] = 14
	defaults.groupUltimatesSettings.ultimates[10] = 16
	defaults.groupUltimatesSettings.ultimates[11] = 8
	defaults.groupUltimatesSettings.ultimates[12] = 27
	defaults.spacing = 0
	
	defaults.groupAssignmentSettings = {}
	
	defaults.playerBlockColors = {}
	defaults.playerBlockColors.defaultBackground = {}
	defaults.playerBlockColors.defaultBackground.r = 0.23828125
	defaults.playerBlockColors.defaultBackground.g = 0.23828125
	defaults.playerBlockColors.defaultBackground.b = 0.23828125
	defaults.playerBlockColors.magicka = {}
	defaults.playerBlockColors.magicka.r = 0.0
	defaults.playerBlockColors.magicka.g = 0.0703125
	defaults.playerBlockColors.magicka.b = 0.9453125
	defaults.playerBlockColors.stamina = {}
	defaults.playerBlockColors.stamina.r = 0.0859375
	defaults.playerBlockColors.stamina.g = 0.5703125
	defaults.playerBlockColors.stamina.b = 0.1953125
	defaults.playerBlockColors.outOfRange = {}
	defaults.playerBlockColors.outOfRange.r = 0.23828125
	defaults.playerBlockColors.outOfRange.g = 0.23828125
	defaults.playerBlockColors.outOfRange.b = 0.23828125
	defaults.playerBlockColors.dead = {}
	defaults.playerBlockColors.dead.r = 1.0
	defaults.playerBlockColors.dead.g = 0.0
	defaults.playerBlockColors.dead.b = 0.0
	defaults.playerBlockColors.progressNotFull = {}
	defaults.playerBlockColors.progressNotFull.r = 0.359375
	defaults.playerBlockColors.progressNotFull.g = 0.54296875
	defaults.playerBlockColors.progressNotFull.b = 0.84375
	defaults.playerBlockColors.progressFull = {}
	defaults.playerBlockColors.progressFull.r = 0.30078125
	defaults.playerBlockColors.progressFull.g = 0.98046875
	defaults.playerBlockColors.progressFull.b = 0.22265625
	defaults.playerBlockColors.labelFull = {}
	defaults.playerBlockColors.labelFull.r = 0.8046875
	defaults.playerBlockColors.labelFull.g = 0.015625
	defaults.playerBlockColors.labelFull.b = 0.015625
	defaults.playerBlockColors.labelNotFull = {}
	defaults.playerBlockColors.labelNotFull.r = 0.28515625
	defaults.playerBlockColors.labelNotFull.g = 0.8828125
	defaults.playerBlockColors.labelNotFull.b = 0.02734375
	defaults.playerBlockColors.labelGroup = {}
	defaults.playerBlockColors.labelGroup.r = 0.8046875
	defaults.playerBlockColors.labelGroup.g = 0.015625
	defaults.playerBlockColors.labelGroup.b = 0.015625
	defaults.playerBlockColors.borderOutOfCombat = {}
	defaults.playerBlockColors.borderOutOfCombat.r = 0.0
	defaults.playerBlockColors.borderOutOfCombat.g = 0.0
	defaults.playerBlockColors.borderOutOfCombat.b = 0.0
	defaults.playerBlockColors.borderInCombat = {}
	defaults.playerBlockColors.borderInCombat.r = 1.0
	defaults.playerBlockColors.borderInCombat.g = 0.0
	defaults.playerBlockColors.borderInCombat.b = 0.0
	defaults.playerBlockColors.inCombatEnabled = false

	
	defaults.assignmentColor = {}
	defaults.assignmentColor.r = 0
	defaults.assignmentColor.g = 0
	defaults.assignmentColor.b = 1
	
	defaults.assignmentSize = 50
	
	defaults.displayMode = RdKGToolOverview.constants.displayModes.CLASSIC
	
	defaults.ultimates = {}
	defaults.ultimates.enabled = true
	defaults.ultimates.sortingMode = RdKGToolOverview.constants.ultimateModes.ORDER_BY_READINESS
	defaults.ultimates.groupSizeDestro = 2
	defaults.ultimates.groupSizeStorm = 1
	defaults.ultimates.groupSizeNorthernStorm = 1
	defaults.ultimates.groupSizePermafrost = 1
	defaults.ultimates.groupSizeNegate = 1
	defaults.ultimates.groupSizeNegateOffensive = 1
	defaults.ultimates.groupSizeNegateCounter = 1
	defaults.ultimates.groupSizeNova = 1	
	defaults.ultimates.maxDistance = 25
	
	defaults.showSoftResources = true
	defaults.soundEnabled = true
	defaults.selectedSound = "CrownCrates_Purchased_With_Gems"
	
	defaults.groups = {}
	defaults.groups.enabled = false
	defaults.groups.mode = RdKGToolOverview.constants.groupsModes.MODE_PRIORITY_NAME
	defaults.groups.group1 = {}
	defaults.groups.group1.name = RdKGToolMenu.constants.RO_GROUPS_1_DEFAULT -- Damage
	defaults.groups.group1.enabled = true
	defaults.groups.group2 = {}
	defaults.groups.group2.name = RdKGToolMenu.constants.RO_GROUPS_2_DEFAULT -- Support
	defaults.groups.group2.enabled = true
	defaults.groups.group3 = {}
	defaults.groups.group3.name = RdKGToolMenu.constants.RO_GROUPS_3_DEFAULT -- Healing
	defaults.groups.group3.enabled = true
	defaults.groups.group4 = {}
	defaults.groups.group4.name = RdKGToolMenu.constants.RO_GROUPS_4_DEFAULT -- Synergies
	defaults.groups.group4.enabled = true
	defaults.groups.group5 = {}
	defaults.groups.group5.name = RdKGToolMenu.constants.RO_GROUPS_5_DEFAULT -- Undefined
	defaults.groups.group5.enabled = false
	
	
	defaults.groups.ultimateGroups = {}
	defaults.groups.ultimateGroups[1] = {} 
	defaults.groups.ultimateGroups[1].group = 2
	defaults.groups.ultimateGroups[1].priority = 2
	defaults.groups.ultimateGroups[2]  = {}
	defaults.groups.ultimateGroups[2].group = 2
	defaults.groups.ultimateGroups[2].priority = 3
	defaults.groups.ultimateGroups[3]  = {}
	defaults.groups.ultimateGroups[3].group = 2
	defaults.groups.ultimateGroups[3].priority = 4
	defaults.groups.ultimateGroups[4]  = {}
	defaults.groups.ultimateGroups[4].group = 1
	defaults.groups.ultimateGroups[4].priority = 30
	defaults.groups.ultimateGroups[5]  = {}
	defaults.groups.ultimateGroups[5].group = 1
	defaults.groups.ultimateGroups[5].priority = 30
	defaults.groups.ultimateGroups[6]  = {}
	defaults.groups.ultimateGroups[6].group = 1
	defaults.groups.ultimateGroups[6].priority = 30
	defaults.groups.ultimateGroups[7]  = {}
	defaults.groups.ultimateGroups[7].group = 4
	defaults.groups.ultimateGroups[7].priority = 1
	defaults.groups.ultimateGroups[8]  = {}
	defaults.groups.ultimateGroups[8].group = 3
	defaults.groups.ultimateGroups[8].priority = 1
	defaults.groups.ultimateGroups[9] = {}
	defaults.groups.ultimateGroups[9].group = 4
	defaults.groups.ultimateGroups[9].priority = 2
	defaults.groups.ultimateGroups[10] = {}
	defaults.groups.ultimateGroups[10].group = 1
	defaults.groups.ultimateGroups[10].priority = 30
	defaults.groups.ultimateGroups[11] = {}
	defaults.groups.ultimateGroups[11].group = 2
	defaults.groups.ultimateGroups[11].priority = 30
	defaults.groups.ultimateGroups[12] = {}
	defaults.groups.ultimateGroups[12].group = 1
	defaults.groups.ultimateGroups[12].priority = 30
	defaults.groups.ultimateGroups[13] = {}
	defaults.groups.ultimateGroups[13].group = 1
	defaults.groups.ultimateGroups[13].priority = 30
	defaults.groups.ultimateGroups[14] = {}
	defaults.groups.ultimateGroups[14].group = 1
	defaults.groups.ultimateGroups[14].priority = 5
	defaults.groups.ultimateGroups[15] = {}
	defaults.groups.ultimateGroups[15].group = 3
	defaults.groups.ultimateGroups[15].priority = 3
	defaults.groups.ultimateGroups[16] = {}
	defaults.groups.ultimateGroups[16].group = 1
	defaults.groups.ultimateGroups[16].priority = 6
	defaults.groups.ultimateGroups[17] = {}
	defaults.groups.ultimateGroups[17].group = 1
	defaults.groups.ultimateGroups[17].priority = 2
	defaults.groups.ultimateGroups[18] = {}
	defaults.groups.ultimateGroups[18].group = 1
	defaults.groups.ultimateGroups[18].priority = 3
	defaults.groups.ultimateGroups[19] = {}
	defaults.groups.ultimateGroups[19].group = 1
	defaults.groups.ultimateGroups[19].priority = 4
	defaults.groups.ultimateGroups[20] = {}
	defaults.groups.ultimateGroups[20].group = 3
	defaults.groups.ultimateGroups[20].priority = 2
	defaults.groups.ultimateGroups[21] = {}
	defaults.groups.ultimateGroups[21].group = 1
	defaults.groups.ultimateGroups[21].priority = 30
	defaults.groups.ultimateGroups[22] = {}
	defaults.groups.ultimateGroups[22].group = 1
	defaults.groups.ultimateGroups[22].priority = 7
	defaults.groups.ultimateGroups[23] = {}
	defaults.groups.ultimateGroups[23].group = 1
	defaults.groups.ultimateGroups[23].priority = 8
	defaults.groups.ultimateGroups[24] = {}
	defaults.groups.ultimateGroups[24].group = 2
	defaults.groups.ultimateGroups[24].priority = 1
	
	defaults.groups.ultimateGroups[25] = {}
	defaults.groups.ultimateGroups[25].group = 1
	defaults.groups.ultimateGroups[25].priority = 20
	defaults.groups.ultimateGroups[26] = {}
	defaults.groups.ultimateGroups[26].group = 3
	defaults.groups.ultimateGroups[26].priority = 20
	defaults.groups.ultimateGroups[27] = {}
	defaults.groups.ultimateGroups[27].group = 3
	defaults.groups.ultimateGroups[27].priority = 30
	
	
	defaults.groups.ultimateGroups[28] = {}
	defaults.groups.ultimateGroups[28].group = 1
	defaults.groups.ultimateGroups[28].priority = 1
	defaults.groups.ultimateGroups[29] = {}
	defaults.groups.ultimateGroups[29].group = 3
	defaults.groups.ultimateGroups[29].priority = 30
	defaults.groups.ultimateGroups[30] = {}
	defaults.groups.ultimateGroups[30].group = 1
	defaults.groups.ultimateGroups[30].priority = 30
	defaults.groups.ultimateGroups[31] = {}
	defaults.groups.ultimateGroups[31].group = 2
	defaults.groups.ultimateGroups[31].priority = 30
	defaults.groups.ultimateGroups[32] = {}
	defaults.groups.ultimateGroups[32].group = 1
	defaults.groups.ultimateGroups[32].priority = 30
	defaults.groups.ultimateGroups[33] = {}
	defaults.groups.ultimateGroups[33].group = 1
	defaults.groups.ultimateGroups[33].priority = 30
	defaults.groups.ultimateGroups[34] = {}
	defaults.groups.ultimateGroups[34].group = 1
	defaults.groups.ultimateGroups[34].priority = 30
	defaults.groups.ultimateGroups[35] = {}
	defaults.groups.ultimateGroups[35].group = 1
	defaults.groups.ultimateGroups[35].priority = 30
	defaults.groups.ultimateGroups[36] = {}
	defaults.groups.ultimateGroups[36].group = 1
	defaults.groups.ultimateGroups[36].priority = 30
	defaults.groups.ultimateGroups[37] = {}
	defaults.groups.ultimateGroups[37].group = 1
	defaults.groups.ultimateGroups[37].priority = 9
	defaults.groups.ultimateGroups[38] = {}
	defaults.groups.ultimateGroups[38].group = 1
	defaults.groups.ultimateGroups[38].priority = 10
	defaults.groups.ultimateGroups[39] = {}
	defaults.groups.ultimateGroups[39].group = 2
	defaults.groups.ultimateGroups[39].priority = 30
	defaults.groups.ultimateGroups[40] = {}
	defaults.groups.ultimateGroups[40].group = 2
	defaults.groups.ultimateGroups[40].priority = 30
	defaults.groups.ultimateGroups[41] = {}
	defaults.groups.ultimateGroups[41].group = 2
	defaults.groups.ultimateGroups[41].priority = 30
	
	defaults.groups.showSoftResources = true
	defaults.groups.size = RdKGToolOverview.constants.size.SMALL
	defaults.groups.maxDistance = 25
	defaults.groups.backdropColor = {}
	defaults.groups.backdropColor.r = 0.2
	defaults.groups.backdropColor.g = 0.2
	defaults.groups.backdropColor.b = 0.2
	defaults.groups.backdropColor.a = 0.5
	defaults.groups.progressNotFull = {}
	defaults.groups.progressNotFull.r = 0.8
	defaults.groups.progressNotFull.g = 0.1
	defaults.groups.progressNotFull.b = 0.1
	defaults.groups.progressNotFull.a = 0.8
	defaults.groups.progressFull = {}
	defaults.groups.progressFull.r = 0.1
	defaults.groups.progressFull.g = 0.8
	defaults.groups.progressFull.b = 0.1
	defaults.groups.progressFull.a = 0.8
	defaults.groups.labelFull = {}
	defaults.groups.labelFull.r = 0.8046875
	defaults.groups.labelFull.g = 0.015625
	defaults.groups.labelFull.b = 0.015625
	defaults.groups.labelNotFull = {}
	defaults.groups.labelNotFull.r = 0.28515625
	defaults.groups.labelNotFull.g = 0.8828125
	defaults.groups.labelNotFull.b = 0.02734375
	defaults.groups.magicka = {}
	defaults.groups.magicka.r = 0.0
	defaults.groups.magicka.g = 0.0703125
	defaults.groups.magicka.b = 0.9453125
	defaults.groups.magicka.a = 0.8
	defaults.groups.stamina = {}
	defaults.groups.stamina.r = 0.0859375
	defaults.groups.stamina.g = 0.5703125
	defaults.groups.stamina.b = 0.1953125
	defaults.groups.stamina.a = 0.8
	defaults.groups.outOfRange = {}
	defaults.groups.outOfRange.r = 0.23828125
	defaults.groups.outOfRange.g = 0.23828125
	defaults.groups.outOfRange.b = 0.23828125
	defaults.groups.outOfRange.a = 0.8
	defaults.groups.dead = {}
	defaults.groups.dead.r = 1.0
	defaults.groups.dead.g = 0.0
	defaults.groups.dead.b = 0.0
	defaults.groups.dead.a = 0.8
	defaults.groups.borderOutOfCombat = {}
	defaults.groups.borderOutOfCombat.r = 0.0
	defaults.groups.borderOutOfCombat.g = 0.0
	defaults.groups.borderOutOfCombat.b = 0.0
	defaults.groups.borderInCombat = {}
	defaults.groups.borderInCombat.r = 1.0
	defaults.groups.borderInCombat.g = 0.0
	defaults.groups.borderInCombat.b = 0.0
	
	defaults.combinedInStealthEnabled = false
	defaults.splitInStealthEnabled = false
	
	return defaults
end

function RdKGToolOverview.SetEnabled(value)
	if RdKGToolOverview.state.initialized == true and value ~= nil then
		RdKGToolOverview.roVars.enabled = value
		if value == true then
			if RdKGToolOverview.state.registredConsumers == false then
				EVENT_MANAGER:RegisterForEvent(RdKGToolOverview.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolOverview.SetForegroundVisibility)
				EVENT_MANAGER:RegisterForEvent(RdKGToolOverview.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolOverview.SetForegroundVisibility)
				EVENT_MANAGER:RegisterForEvent(RdKGToolOverview.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolOverview.OnPlayerActivated)

			end
			RdKGToolOverview.state.registredConsumers = true
		else
			if RdKGToolOverview.state.registredConsumers == true then
				EVENT_MANAGER:UnregisterForEvent(RdKGToolOverview.callbackName, EVENT_ACTION_LAYER_POPPED)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolOverview.callbackName, EVENT_ACTION_LAYER_PUSHED)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolOverview.callbackName, EVENT_PLAYER_ACTIVATED)
			end
			RdKGToolOverview.state.registredConsumers = false
		end
		RdKGToolOverview.OnPlayerActivated()
		--RdKGToolOverview.SetGroupsEnabled(RdKGToolOverview.roVars.groups.enabled)
	end
end

function RdKGToolOverview.SetGroupsEnabled(value)
	if RdKGToolOverview.state.initialized == true and value ~= nil then
		RdKGToolOverview.roVars.groups.enabled = value
		RdKGToolOverview.OnPlayerActivated()
	end
end

function RdKGToolOverview.AdjustGroupNames()
	local state = RdKGToolOverview.GetRoAvailableGroupsGroups()
	for i = 1, #RdKGToolOverview.state.references do
		local control = GetWindowManager():GetControlByName(RdKGToolOverview.state.references[i])
		if control ~= nil then
			control:UpdateChoices(state)
		end
	end
	for i = 1, #RdKGToolOverview.controls.groupsTLW do
		RdKGToolOverview.controls.groupsTLW[i].rootControl.caption:SetText(RdKGToolOverview.roVars.groups["group" .. i].name)
	end
end

function RdKGToolOverview.SetTlwLocation()
	RdKGToolOverview.controls.clientUltimateTLW:ClearAnchors()
	if RdKGToolOverview.roVars.clientUltimateSettings.location == nil then
		RdKGToolOverview.controls.clientUltimateTLW:SetAnchor(CENTER, GuiRoot, CENTER, -250, -150)
	else
		RdKGToolOverview.controls.clientUltimateTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolOverview.roVars.clientUltimateSettings.location.x, RdKGToolOverview.roVars.clientUltimateSettings.location.y)
	end
	RdKGToolOverview.controls.groupUltimatesTLW:ClearAnchors()
	if RdKGToolOverview.roVars.groupUltimatesSettings.location == nil then
		RdKGToolOverview.controls.groupUltimatesTLW:SetAnchor(CENTER, GuiRoot, CENTER, 125, -150)
	else
		RdKGToolOverview.controls.groupUltimatesTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolOverview.roVars.groupUltimatesSettings.location.x, RdKGToolOverview.roVars.groupUltimatesSettings.location.y)
	end
	RdKGToolOverview.controls.ultimateOverviewTLW:ClearAnchors()
	if RdKGToolOverview.roVars.ultimateOverviewSettings.location == nil then
		RdKGToolOverview.controls.ultimateOverviewTLW:SetAnchor(CENTER, GuiRoot, CENTER, 150, 0)
	else
		RdKGToolOverview.controls.ultimateOverviewTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolOverview.roVars.ultimateOverviewSettings.location.x, RdKGToolOverview.roVars.ultimateOverviewSettings.location.y)
	end
	for i = 1, #RdKGToolOverview.controls.groupsTLW do
		RdKGToolOverview.controls.groupsTLW[i]:ClearAnchors()
		if RdKGToolOverview.roVars.groups.location == nil or RdKGToolOverview.roVars.groups.location[i] == nil then
			RdKGToolOverview.controls.groupsTLW[i]:SetAnchor(CENTER, GuiRoot, CENTER, -150, -150)
		else
			RdKGToolOverview.controls.groupsTLW[i]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolOverview.roVars.groups.location[i].x, RdKGToolOverview.roVars.groups.location[i].y)
		end
	end
	
end

function RdKGToolOverview.CreateDefaultUI()
	--[[
		Client Ultimate
	]]
	RdKGToolOverview.controls.clientUltimateTLW = wm:CreateTopLevelWindow(RdKGToolOverview.constants.TLW_CLIENT_ULTIMATE_NAME)
	
			
	RdKGToolOverview.controls.clientUltimateTLW:SetClampedToScreen(RdKGToolOverview.config.clientUltimate.isClampedToScreen)
	RdKGToolOverview.controls.clientUltimateTLW:SetDrawLayer(0)
	RdKGToolOverview.controls.clientUltimateTLW:SetDrawLevel(0)
	RdKGToolOverview.controls.clientUltimateTLW:SetHandler("OnMoveStop", RdKGToolOverview.SaveClientUltimateWindowLocation)
	RdKGToolOverview.controls.clientUltimateTLW:SetDimensions(RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth + RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset * 2, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight + RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset * 2)
	
	RdKGToolOverview.controls.clientUltimateTLW.rootControl = wm:CreateControl(nil, RdKGToolOverview.controls.clientUltimateTLW, CT_CONTROL)
	local clientRootControl = RdKGToolOverview.controls.clientUltimateTLW.rootControl
	
	clientRootControl:SetDimensions(RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth + RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset * 2, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight + RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset * 2)
	clientRootControl:SetAnchor(TOPLEFT, RdKGToolOverview.controls.clientUltimateTLW, TOPLEFT, 0, 0)
	
	clientRootControl.movableBackdrop = wm:CreateControl(nil, clientRootControl, CT_BACKDROP)
	
	clientRootControl.movableBackdrop:SetAnchor(TOPLEFT, clientRootControl, TOPLEFT, 0, 0)
	clientRootControl.movableBackdrop:SetDimensions(RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth + RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset * 2, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight + RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset * 2)
	
	clientRootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	clientRootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	clientRootControl.ultimateSelector = RdKGToolOverview.CreateUltimateSelectorControl(clientRootControl, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset, RdKGToolOverview.config.clientUltimate.isClampedToScreen, RdKGToolUltimates.SetClientUltimate)
	
	local selectedIndex = 1
	if RdKGToolOverview.charVars.ro ~= nil then
		selectedIndex = RdKGToolUltimates.GetUltimateIndexFromUltimateId(RdKGToolOverview.charVars.ro.selectedUltimateId)
		if selectedIndex == nil then
			selectedIndex = 1
		end
	end
	RdKGToolUltimates.SetClientUltimate(clientRootControl.ultimateSelector, selectedIndex)
	--[[
		Group Ultimates
	]]
	RdKGToolOverview.controls.groupUltimatesTLW = wm:CreateTopLevelWindow(RdKGToolOverview.constants.TLW_GROUP_ULTIMATES_NAME)
		
	RdKGToolOverview.controls.groupUltimatesTLW:SetClampedToScreen(RdKGToolOverview.config.groupUltimates.isClampedToScreen)
	RdKGToolOverview.controls.groupUltimatesTLW:SetDrawLayer(0)
	RdKGToolOverview.controls.groupUltimatesTLW:SetDrawLevel(0)
	RdKGToolOverview.controls.groupUltimatesTLW:SetHandler("OnMoveStop", RdKGToolOverview.SaveGroupUltimatesWindowLocation)
	RdKGToolOverview.controls.groupUltimatesTLW:SetDimensions(RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth * 12 + RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset * 2, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight + RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset * 2)
	
	
	RdKGToolOverview.controls.groupUltimatesTLW.rootControl = wm:CreateControl(nil, RdKGToolOverview.controls.groupUltimatesTLW, CT_CONTROL)
	local groupsRootControl = RdKGToolOverview.controls.groupUltimatesTLW.rootControl
	
	groupsRootControl:SetDimensions(RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth * 12 + RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset * 2, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight + RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset * 2)
	groupsRootControl:SetAnchor(TOPLEFT, RdKGToolOverview.controls.groupUltimatesTLW, TOPLEFT, 0, 0)
	
	groupsRootControl.movableBackdrop = wm:CreateControl(nil, groupsRootControl, CT_BACKDROP)
	
	groupsRootControl.movableBackdrop:SetAnchor(TOPLEFT, groupsRootControl, TOPLEFT, 0, 0)
	groupsRootControl.movableBackdrop:SetDimensions(RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth * 12 + RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset * 2, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight + RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset * 2)
	
	groupsRootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	groupsRootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	groupsRootControl.ultimateSelector = {}
	for i = 1, 12 do
		groupsRootControl.ultimateSelector[i] = RdKGToolOverview.CreateUltimateSelectorControl(groupsRootControl, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth * (i - 1)), RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset, RdKGToolOverview.config.groupUltimates.isClampedToScreen, RdKGToolUltimates.SetGroupUltimate)
		groupsRootControl.ultimateSelector[i].controlIndex = i
		groupsRootControl.ultimateSelector[i].label = wm:CreateControl(nil, groupsRootControl.ultimateSelector[i], CT_LABEL)
		groupsRootControl.ultimateSelector[i].label:SetHidden(true)
		groupsRootControl.ultimateSelector[i].label:SetText("")
		groupsRootControl.ultimateSelector[i].label:SetWrapMode(ELLIPSIS)
		groupsRootControl.ultimateSelector[i].label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		RdKGToolUltimates.SetGroupUltimate(groupsRootControl.ultimateSelector[i], RdKGToolUltimates.GetUltimateIndexFromUltimateId(RdKGToolOverview.roVars.groupUltimatesSettings.ultimates[i]))
	end
	
	--[[
		Group Selector Player Blocks
	]]
	groupsRootControl.playerBlocks = {}
	for i = 1, 24 do
		groupsRootControl.playerBlocks[i] = RdKGToolOverview.CreatePlayerBlock(groupsRootControl, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockWidth, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockHeight, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockGroupWidth, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockMagickaHeight, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockStaminaHeight)
	end
	
	
	--[[
		Group Assignment Window
	]]
	RdKGToolOverview.controls.groupAssignmentTLW = wm:CreateTopLevelWindow(RdKGToolOverview.constants.TLW_GROUP_ASSIGNMENT_NAME)
	
	if RdKGToolOverview.roVars.groupAssignmentSettings.location == nil then
		RdKGToolOverview.controls.groupAssignmentTLW:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	else
		RdKGToolOverview.controls.groupAssignmentTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolOverview.roVars.groupAssignmentSettings.location.x, RdKGToolOverview.roVars.groupAssignmentSettings.location.y)
	end
		
	RdKGToolOverview.controls.groupAssignmentTLW:SetClampedToScreen(RdKGToolOverview.config.groupAssignments.isClampedToScreen)
	RdKGToolOverview.controls.groupAssignmentTLW:SetDrawLayer(0)
	RdKGToolOverview.controls.groupAssignmentTLW:SetDrawLevel(0)
	RdKGToolOverview.controls.groupAssignmentTLW:SetHandler("OnMoveStop", RdKGToolOverview.SaveGroupAssignmentWindowLocation)
		
	RdKGToolOverview.controls.groupAssignmentTLW.rootControl = wm:CreateControl(nil, RdKGToolOverview.controls.groupAssignmentTLW, CT_CONTROL)
	local assignmentRootControl = RdKGToolOverview.controls.groupAssignmentTLW.rootControl
	
	
	assignmentRootControl:SetAnchor(TOPLEFT, RdKGToolOverview.controls.groupAssignmentTLW, TOPLEFT, 0, 0)
	
	assignmentRootControl.movableBackdrop = wm:CreateControl(nil, assignmentRootControl, CT_BACKDROP)
	
	assignmentRootControl.movableBackdrop:SetAnchor(TOPLEFT, assignmentRootControl, TOPLEFT, 0, 0)
		
	assignmentRootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	assignmentRootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	assignmentRootControl.label = wm:CreateControl(nil, assignmentRootControl, CT_LABEL)
	assignmentRootControl.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	assignmentRootControl.label:SetWrapMode(ELLIPSIS)
	
	
	assignmentRootControl.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	assignmentRootControl.label:SetColor(RdKGToolOverview.roVars.assignmentColor.r, RdKGToolOverview.roVars.assignmentColor.g, RdKGToolOverview.roVars.assignmentColor.b, 1)
	RdKGToolOverview.AdjustAssignmentControlSize()
	
	--[[
		Group Overview Window
	]]
	RdKGToolOverview.controls.ultimateOverviewTLW = wm:CreateTopLevelWindow(RdKGToolOverview.constants.TLW_ULTIMATE_OVERVIEW_NAME)

	
	RdKGToolOverview.controls.ultimateOverviewTLW:SetClampedToScreen(RdKGToolOverview.config.ultimateOverview.isClampedToScreen)
	RdKGToolOverview.controls.ultimateOverviewTLW:SetDrawLayer(0)
	RdKGToolOverview.controls.ultimateOverviewTLW:SetDrawLevel(0)
	RdKGToolOverview.controls.ultimateOverviewTLW:SetHandler("OnMoveStop", RdKGToolOverview.SaveUltimateOverviewLocation)
	RdKGToolOverview.controls.ultimateOverviewTLW:SetDimensions(RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].width, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].height)
	
	RdKGToolOverview.controls.ultimateOverviewTLW.rootControl = wm:CreateControl(nil, RdKGToolOverview.controls.ultimateOverviewTLW, CT_CONTROL)
	
	local ultimateOverviewControl = RdKGToolOverview.controls.ultimateOverviewTLW.rootControl
	ultimateOverviewControl:SetAnchor(TOPLEFT, RdKGToolOverview.controls.ultimateOverviewTLW, TOPLEFT, 0, 0)
	ultimateOverviewControl:SetDimensions(RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].width, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].height)
	
	ultimateOverviewControl.movableBackdrop = wm:CreateControl(nil, ultimateOverviewControl, CT_BACKDROP)
	ultimateOverviewControl.movableBackdrop:SetDimensions(RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].width, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].height)
	ultimateOverviewControl.movableBackdrop:SetAnchor(TOPLEFT, ultimateOverviewControl, TOPLEFT, 0, 0)
		
	ultimateOverviewControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	ultimateOverviewControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	ultimateOverviewControl.destructionLabel = RdKGToolOverview.CreateUltimateOverviewLabel(ultimateOverviewControl, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].width, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].blockHeight, 0, RdKGToolOverview.constants.IDENENTIFIER_DESTRUCTION)
	ultimateOverviewControl.stormLabel = RdKGToolOverview.CreateUltimateOverviewLabel(ultimateOverviewControl, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].width, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].blockHeight, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].blockHeight, RdKGToolOverview.constants.IDENENTIFIER_STORM)
	ultimateOverviewControl.negateLabel = RdKGToolOverview.CreateUltimateOverviewLabel(ultimateOverviewControl, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].width, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].blockHeight, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].blockHeight * 2, RdKGToolOverview.constants.IDENENTIFIER_NEGATE)
	ultimateOverviewControl.novaLabel = RdKGToolOverview.CreateUltimateOverviewLabel(ultimateOverviewControl, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].width, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].blockHeight, RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].blockHeight * 3, RdKGToolOverview.constants.IDENENTIFIER_NOVA)
		
	
end

function RdKGToolOverview.CreateUltimateOverviewLabel(parent, width, height, offset, text)
	local control = wm:CreateControl(nil, parent, CT_LABEL)
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, 5, offset)
	control:SetFont(RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, height - 4, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THICK))
	control:SetWrapMode(ELLIPSIS)
	control:SetDimensions(width - 20, height)
	control:SetText(string.format(RdKGToolOverview.constants.ULTIMATE_OVERVIEW_STRING, 0, 0, text))
	control.currentBoomLabel = wm:CreateControl(nil, parent, CT_LABEL)
	control.currentBoomLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, width - 20, offset)
	control.currentBoomLabel:SetFont(RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, height - 4, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THICK))
	control.currentBoomLabel:SetWrapMode(ELLIPSIS)
	control.currentBoomLabel:SetDimensions(20, height)
	control.currentBoomLabel:SetText("0")
	return control
end

function RdKGToolOverview.CreateUltimateSelectorControl(parent, width, height, offsetX, offsetY, isClampedToScreen, clickFunction)
	local control = wm:CreateControl(nil, parent, CT_CONTROL)
	control:SetDimensions(width, height)
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, offsetX, offsetY)
	control:SetClampedToScreen(isClampedToScreen)
	control.clickFunction = clickFunction
	
	control.button = wm:CreateControl(nil, control, CT_BUTTON)
	local button = control.button
	button:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	button:SetDimensions(width, height)
	button:SetNormalTexture("/esoui/art/actionbar/abilityframe64_up.dds")
	button:SetPressedTexture("/esoui/art/actionbar/abilityframe64_down.dds")
	button:SetMouseOverTexture("EsoUI/Art/ActionBar/actionBar_mouseOver.dds")
	button:SetHandler("OnClicked", function () RdKGToolOverview.ShowUltimateControlOptions(control) end)
	button:SetDrawTier(1)
	
	control.texture = wm:CreateControl(nil, parent, CT_TEXTURE)
	local texture = control.texture
	texture:SetAnchor(TOPLEFT, control, TOPLEFT, 2, 2)
	texture:SetDimensions(width - 4, height - 4)
	texture:SetTexture("/esoui/art/icons/icon_missing.dds")
	texture:SetDrawTier(0)
	return control
end

function RdKGToolOverview.CreatePlayerBlock(parent, width, height, blockGroupWidth, blockMagickaHeight, blockStaminaHeight)
	local control = wm:CreateControl(nil, parent, CT_CONTROL)
	control:SetDimensions(width, height)
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
	
	control.backdrop = wm:CreateControl(nil, control, CT_BACKDROP)
	control.backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.backdrop:SetDimensions(width, height)
	control.backdrop:SetDrawTier(0)
	control.backdrop:SetCenterColor(RdKGToolOverview.roVars.playerBlockColors.defaultBackground.r, RdKGToolOverview.roVars.playerBlockColors.defaultBackground.g, RdKGToolOverview.roVars.playerBlockColors.defaultBackground.b, 0.8)
	control.backdrop:SetEdgeColor(0,0,0,0)
	
	control.ultimateProgress = wm:CreateControl(nil, control, CT_STATUSBAR)
	control.ultimateProgress:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.ultimateProgress:SetDimensions(width, height - blockMagickaHeight - blockStaminaHeight)
	control.ultimateProgress:SetMinMax(0, 100)
	control.ultimateProgress:SetValue(0)
	control.ultimateProgress:SetDrawTier(1)
	
	control.magickaProgress = wm:CreateControl(nil, control, CT_STATUSBAR)
	control.magickaProgress:SetAnchor(TOPLEFT, control, TOPLEFT, 0, height - blockMagickaHeight - blockStaminaHeight)
	control.magickaProgress:SetDimensions(width, blockMagickaHeight)
	control.magickaProgress:SetMinMax(0, 100)
	control.magickaProgress:SetValue(0)
	control.magickaProgress:SetDrawTier(3)
	
	control.staminaProgress = wm:CreateControl(nil, control, CT_STATUSBAR)
	control.staminaProgress:SetAnchor(TOPLEFT, control, TOPLEFT, 0, height - blockStaminaHeight)
	control.staminaProgress:SetDimensions(width, blockStaminaHeight)
	control.staminaProgress:SetMinMax(0, 100)
	control.staminaProgress:SetValue(0)
	control.staminaProgress:SetDrawTier(1)
	
	control.labelName = wm:CreateControl(nil, control, CT_LABEL)
	control.labelName:SetAnchor(TOPLEFT, control, TOPLEFT, blockGroupWidth, 0)
	control.labelName:SetFont(RdKGToolOverview.config.font)
	control.labelName:SetWrapMode(ELLIPSIS)
	control.labelName:SetDimensions(width - blockGroupWidth - 2, height - blockMagickaHeight - blockStaminaHeight - 4)
	control.labelName:SetText("")
	control.labelName:SetDrawTier(2)
	control.labelName:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	
	control.labelGroup = wm:CreateControl(nil, control, CT_LABEL)
	control.labelGroup:SetAnchor(TOPLEFT, control, TOPLEFT, 2, 0)
	control.labelGroup:SetFont(RdKGToolOverview.config.font)
	control.labelGroup:SetWrapMode(ELLIPSIS)
	control.labelGroup:SetDimensions(blockGroupWidth - 4, height - blockMagickaHeight - blockStaminaHeight - 4)
	control.labelGroup:SetText("")
	control.labelGroup:SetDrawTier(2)
	control.labelGroup:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	
	control.frontdrop = wm:CreateControl(nil, control, CT_BACKDROP)
	control.frontdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.frontdrop:SetDimensions(width, height)
	control.frontdrop:SetDrawTier(2)
	control.frontdrop:SetEdgeColor(0,0,0,0)
	
	control.border = wm:CreateControl(nil, control, CT_BACKDROP)
	control.border:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.border:SetDimensions(width, height)
	control.border:SetEdgeTexture(nil, 1, 1, RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].border, 0)
	control.border:SetCenterColor(0, 0, 0, 0)
	control.border:SetEdgeColor(RdKGToolOverview.roVars.playerBlockColors.borderOutOfCombat.r, RdKGToolOverview.roVars.playerBlockColors.borderOutOfCombat.g, RdKGToolOverview.roVars.playerBlockColors.borderOutOfCombat.b, 1)
	control.border:SetDrawTier(2)
	control.border:SetHidden(true)
	
	control:SetHidden(true)
	return control
end

function RdKGToolOverview.CreateGroupsUI()
	RdKGToolOverview.controls.groupsTLW = {}
	RdKGToolOverview.controls.groupsEntries = {}
	for i = 1, 5 do
		local tlw = RdKGToolOverview.CreateGroupsGroupWindow(i)
		table.insert(RdKGToolOverview.controls.groupsTLW, tlw)
	end
	RdKGToolOverview.controls.groupsEmptyTLW = wm:CreateTopLevelWindow(RdKGToolOverview.constants.TLW_GROUPS_EMPTY)
	RdKGToolOverview.controls.groupsEmptyTLW:SetDimensions(0,0)
	RdKGToolOverview.controls.groupsEmptyTLW:SetHidden(true)
	for i = 1, 24 do
		local entry = RdKGToolOverview.CreateGroupsEntryControl(RdKGToolOverview.controls.groupsEmptyTLW)
		table.insert(RdKGToolOverview.controls.groupsEntries, entry)
	end
end

function RdKGToolOverview.CreateGroupsGroupWindow(index)
	local captionFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].captionFontSize, RdKGToolFonts.constants.WEIGHT_THICK_OUTLINE)

	local tlw = wm:CreateTopLevelWindow(RdKGToolOverview.constants.TLW_GROUPS_GROUP[index])
	
	tlw:SetClampedToScreen(RdKGToolOverview.config.groups.isClampedToScreen)
	tlw:SetDrawLayer(0)
	tlw:SetDrawLevel(0)
	tlw:SetHandler("OnMoveStop", RdKGToolOverview.SaveGroupsGroupWindowLocation)
	tlw:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].width, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].height)
	
	tlw.rootControl = wm:CreateControl(nil, tlw, CT_CONTROL)
	local rootControl = tlw.rootControl
	
	rootControl:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].width, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].height)
	rootControl:SetAnchor(TOPLEFT, tlw, TOPLEFT, 0, 0)
	
	rootControl.movableBackdrop = wm:CreateControl(nil, rootControl, CT_BACKDROP)
	
	rootControl.movableBackdrop:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	rootControl.movableBackdrop:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].width, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].height)
	
	rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	rootControl.caption = wm:CreateControl(nil, rootControl, CT_LABEL)
	rootControl.caption:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 2, 0)
	rootControl.caption:SetFont(captionFont)
	rootControl.caption:SetWrapMode(ELLIPSIS)
	rootControl.caption:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight)
	rootControl.caption:SetText("")
	rootControl.caption:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	rootControl.caption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	
	return tlw
end

function RdKGToolOverview.CreateGroupsEntryControl(parent)
	if parent ~= nil then
		local font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].fontSizeWithResources, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
		local control = wm:CreateControl(nil, parent, CT_CONTROL)
		
		control:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight)
		control:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
		
		control.backdrop = wm:CreateControl(nil, control, CT_BACKDROP)
		control.backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
		control.backdrop:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight)
		control.backdrop:SetCenterColor(1, 0, 0, 0.0)
		control.backdrop:SetEdgeColor(1, 0, 0, 0.0)
	
		control.edge = wm:CreateControl(nil, control, CT_BACKDROP)
		control.edge:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
		control.edge:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight)
		control.edge:SetEdgeTexture(nil, 1, 1, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].edgeSize, 0)
		control.edge:SetCenterColor(0, 0, 0, 0)
		control.edge:SetEdgeColor(RdKGToolOverview.roVars.groups.borderOutOfCombat.r, RdKGToolOverview.roVars.groups.borderOutOfCombat.g, RdKGToolOverview.roVars.groups.borderOutOfCombat.b, 1)
		
		control.progress = wm:CreateControl(nil, control, CT_STATUSBAR)
		control.progress:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - 2, 2)
		control.progress:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - 4)
		control.progress:SetMinMax(0, 100)
		control.progress:SetValue(0)
		
		control.softBackdrop = wm:CreateControl(nil, control, CT_BACKDROP)
		control.softBackdrop:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - 2, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].softHeight * 2 - 2)
		control.softBackdrop:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].softHeight * 2)
		control.softBackdrop:SetCenterColor(1, 0, 0, 0.0)
		control.softBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		
		control.magicka = wm:CreateControl(nil, control, CT_STATUSBAR)
		control.magicka:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - 2, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].softHeight * 2 - 2)
		control.magicka:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].softHeight)
		control.magicka:SetMinMax(0, 100)
		control.magicka:SetValue(0)
		
		control.stamina = wm:CreateControl(nil, control, CT_STATUSBAR)
		control.stamina:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - 2, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].softHeight - 2)
		control.stamina:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].softHeight)
		control.stamina:SetMinMax(0, 100)
		control.stamina:SetValue(0)
		
		control.name = wm:CreateControl(nil, control, CT_LABEL)
		control.name:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolOverview.config.groups.entryHeight, 0)
		control.name:SetFont(font)
		control.name:SetWrapMode(ELLIPSIS)
		control.name:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryPercentWidth, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - 4)
		control.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		control.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		
		control.percent = wm:CreateControl(nil, control, CT_LABEL)
		control.percent:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryPercentWidth) - 2, 0)
		control.percent:SetFont(font)
		control.percent:SetWrapMode(ELLIPSIS)
		control.percent:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryPercentWidth, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - 4)
		control.percent:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		control.percent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		
		control.texture = wm:CreateControl(nil, control, CT_TEXTURE)
		control.texture:SetAnchor(TOPLEFT, control, TOPLEFT, 2, 2)
		control.texture:SetDimensions(RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - 4, RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight - 4)

		
		return control
	end
	
	return nil
end

function RdKGToolUltimates.SetClientUltimate(control, ultimateIndex)
	if ultimateIndex ~= nil and control ~= nil then
		local ultimates = RdKGToolUltimates.ultimates
		if ultimateIndex > 0 and ultimateIndex <= #ultimates then
			RdKGToolOverview.charVars.ro.selectedUltimateId = ultimates[ultimateIndex].id
			RdKGToolOverview.state.selectedClientUltimate = ultimates[ultimateIndex]
			control.texture:SetTexture(ultimates[ultimateIndex].icon)
			if ultimates[ultimateIndex].iconColor == nil then
				control.texture:SetColor(1,1,1)
			else
				control.texture:SetColor(ultimates[ultimateIndex].iconColor.r, ultimates[ultimateIndex].iconColor.g, ultimates[ultimateIndex].iconColor.b)
			end
		end
	end
end

function RdKGToolUltimates.SetGroupUltimate(control, ultimateIndex)
	if ultimateIndex ~= nil and control ~= nil and control.label ~= nil then
		local ultimates = RdKGToolUltimates.ultimates
		if ultimateIndex > 0 and ultimateIndex <= #ultimates then
			local controlIndex = control.controlIndex
			RdKGToolOverview.roVars.groupUltimatesSettings.ultimates[controlIndex] = ultimates[ultimateIndex].id
			control.texture:SetTexture(ultimates[ultimateIndex].icon)
			control.label:SetText(ultimates[ultimateIndex].name)
			if ultimates[ultimateIndex].iconColor == nil then
				control.texture:SetColor(1,1,1)
			else
				control.texture:SetColor(ultimates[ultimateIndex].iconColor.r, ultimates[ultimateIndex].iconColor.g, ultimates[ultimateIndex].iconColor.b)
			end
		end
	end
end

function RdKGToolOverview.SetPositionLocked(value)
	RdKGToolOverview.roVars.positionLocked = value
	RdKGToolOverview.controls.clientUltimateTLW:SetMovable(not value)
	RdKGToolOverview.controls.clientUltimateTLW:SetMouseEnabled(not value)
	RdKGToolOverview.controls.groupUltimatesTLW:SetMovable(not value)
	RdKGToolOverview.controls.groupUltimatesTLW:SetMouseEnabled(not value)
	RdKGToolOverview.controls.groupAssignmentTLW:SetMovable(not value)
	RdKGToolOverview.controls.groupAssignmentTLW:SetMouseEnabled(not value)
	RdKGToolOverview.controls.ultimateOverviewTLW:SetMovable(not value)
	RdKGToolOverview.controls.ultimateOverviewTLW:SetMouseEnabled(not value)
	for i = 1, #RdKGToolOverview.controls.groupsTLW do
		RdKGToolOverview.controls.groupsTLW[i]:SetMovable(not value)
		RdKGToolOverview.controls.groupsTLW[i]:SetMouseEnabled(not value)
	end
	if value == true then
		RdKGToolOverview.controls.clientUltimateTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolOverview.controls.clientUltimateTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		RdKGToolOverview.controls.groupUltimatesTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolOverview.controls.groupUltimatesTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		RdKGToolOverview.controls.groupAssignmentTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolOverview.controls.groupAssignmentTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		RdKGToolOverview.controls.ultimateOverviewTLW.rootControl.movableBackdrop:SetCenterColor(0.2, 0.2, 0.2, 0.4)
		RdKGToolOverview.controls.ultimateOverviewTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		for i = 1, #RdKGToolOverview.controls.groupsTLW do
			RdKGToolOverview.controls.groupsTLW[i].rootControl.movableBackdrop:SetCenterColor(1, 0.0, 0.0, 0.0)
			RdKGToolOverview.controls.groupsTLW[i].rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		end
	else
		RdKGToolOverview.controls.clientUltimateTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolOverview.controls.clientUltimateTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		RdKGToolOverview.controls.groupUltimatesTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolOverview.controls.groupUltimatesTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		RdKGToolOverview.controls.groupAssignmentTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolOverview.controls.groupAssignmentTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		RdKGToolOverview.controls.ultimateOverviewTLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolOverview.controls.ultimateOverviewTLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		for i = 1, #RdKGToolOverview.controls.groupsTLW do
			RdKGToolOverview.controls.groupsTLW[i].rootControl.movableBackdrop:SetCenterColor(1, 0.0, 0.0, 0.5)
			RdKGToolOverview.controls.groupsTLW[i].rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
		end
	end
end

function RdKGToolOverview.AdjustInCombatSettings()
	local playerBlocks = RdKGToolOverview.controls.groupUltimatesTLW.rootControl.playerBlocks
	for i = 1, #playerBlocks do
		playerBlocks[i].border:SetHidden(not RdKGToolOverview.roVars.playerBlockColors.inCombatEnabled)
		--d(not RdKGToolOverview.roVars.playerBlockColors.inCombatEnabled)
	end
end

function RdKGToolOverview.SetDisplayedUltimates(value)
	if value ~= nil and value > 0 and value <= 12 then
		local sizeIncrease = RdKGToolOverview.roVars.size - RdKGToolOverview.constants.size.SMALL
		local ultiIconWidth = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].ultiIconWidth - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth) * sizeIncrease)
		local offset = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].offset - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset) * sizeIncrease)
		local ultiIconHeight = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].ultiIconHeight - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight) * sizeIncrease)
		
		RdKGToolOverview.roVars.groupUltimatesSettings.displayedUltimates = value
		local groupsRootControl = RdKGToolOverview.controls.groupUltimatesTLW.rootControl
		for i = 1, value do
			groupsRootControl.ultimateSelector[i]:SetHidden(false)
			groupsRootControl.ultimateSelector[i].button:SetHidden(false)
			groupsRootControl.ultimateSelector[i].texture:SetHidden(false)
		end
		for i = value + 1, 12 do
			groupsRootControl.ultimateSelector[i]:SetHidden(true)
			groupsRootControl.ultimateSelector[i].button:SetHidden(true)
			groupsRootControl.ultimateSelector[i].texture:SetHidden(true)
		end
		RdKGToolOverview.controls.groupUltimatesTLW:SetDimensions(ultiIconWidth * value + offset * 2 + RdKGToolOverview.state.spacing * (value - 1), ultiIconHeight + offset * 2)
		if RdKGToolOverview.roVars.displayMode == RdKGToolOverview.constants.displayModes.CLASSIC then
			groupsRootControl:SetDimensions(ultiIconWidth * value + offset * 2 + RdKGToolOverview.state.spacing * (value - 1), ultiIconHeight + RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset * 2)
			groupsRootControl.movableBackdrop:SetDimensions(ultiIconWidth * value + offset * 2 + RdKGToolOverview.state.spacing * (value - 1), ultiIconHeight + offset * 2)
			RdKGToolOverview.controls.groupUltimatesTLW:SetDimensions(ultiIconWidth * value + offset * 2 + RdKGToolOverview.state.spacing * (value - 1), ultiIconHeight + offset * 2)
		else
			local playerBlockWidth = (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockWidth + (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].playerBlockWidth - RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockWidth) * sizeIncrease)
			local ultiIconHeight = (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight + (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].ultiIconHeight - RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight) * sizeIncrease)
			groupsRootControl:SetDimensions(playerBlockWidth * value + offset * 2 + RdKGToolOverview.state.spacing * (value - 1), ultiIconHeight + RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].offset * 2)
			groupsRootControl.movableBackdrop:SetDimensions(playerBlockWidth * value + offset * 2 + RdKGToolOverview.state.spacing * (value - 1), ultiIconHeight + offset * 2)
			RdKGToolOverview.controls.groupUltimatesTLW:SetDimensions(playerBlockWidth * value + offset * 2 + RdKGToolOverview.state.spacing * (value - 1), ultiIconHeight + offset * 2)
		end
	end
end

function RdKGToolOverview.SetControlVisibility()
	local enabled = RdKGToolOverview.roVars.enabled
	local clientEnabled = RdKGToolOverview.roVars.clientUltimateSettings.enabled
	local groupEnabled = RdKGToolOverview.roVars.groupUltimatesSettings.enabled
	local overviewEnabled = RdKGToolOverview.roVars.ultimateOverviewSettings.enabled
	local pvpOnly = RdKGToolOverview.roVars.pvpOnly
	local ultimateGroupsEnabled = RdKGToolOverview.roVars.ultimates.enabled
	local groupsEnabledVal = RdKGToolOverview.roVars.groups.enabled
	local groupsEnabled = {}
	local setClientHidden = true
	local setGroupHidden = true
	local setAssignmentHidden = true
	local setOverviewHidden = true
	local setGroupsHidden = {}
	for i = 1, #RdKGToolOverview.controls.groupsTLW do
		setGroupsHidden[i] = true
		groupsEnabled[i] = RdKGToolOverview.roVars.groups["group" .. i].enabled
	end
	if enabled ~= nil and clientEnabled ~= nil and groupEnabled ~= nil and pvpOnly ~= nil then

		if enabled == true and (pvpOnly == false or (pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) --[[and RdKGToolOverview.state.foreground == true]] then
			if clientEnabled == true then
				setClientHidden = false
			end
			if groupEnabled == true then
				setGroupHidden = false
			end
			if overviewEnabled == true and ultimateGroupsEnabled == true then
				setOverviewHidden = false
			end
			if ultimateGroupsEnabled == true then
				setAssignmentHidden = false
			end
			
			if groupsEnabledVal == true then
				for i = 1, #RdKGToolOverview.controls.groupsTLW do
					if groupsEnabled[i] == true then
						setGroupsHidden[i] = false
					end
				end
			end
		end
	end
	RdKGToolOverview.controls.clientUltimateTLW:SetHidden(setClientHidden)
	RdKGToolOverview.controls.groupUltimatesTLW:SetHidden(setGroupHidden)
	RdKGToolOverview.controls.groupAssignmentTLW:SetHidden(setAssignmentHidden)
	RdKGToolOverview.controls.ultimateOverviewTLW:SetHidden(setOverviewHidden)
	for i = 1, #RdKGToolOverview.controls.groupsTLW do
		RdKGToolOverview.controls.groupsTLW[i]:SetHidden(setGroupsHidden[i])
		--RdKGToolOverview.controls.groupsTLW[i]:SetHidden(false)
	end
end

function RdKGToolOverview.GetAbilityCost(ultimateId)
	local cost = 0
	local ultimates = RdKGToolUltimates.ultimates
	for i = 1, #ultimates do
		if ultimateId == ultimates[i].id then
			RdKGToolUltimates.UpdateAbilityCosts(i)
			cost = ultimates[i].cost
			break
		end
	end
	return cost
end

function RdKGToolOverview.GetPlayerDebuffs()
	return RdKGToolDbo.GetPlayerDebuffs()
end

function RdKGToolOverview.GetPlayerResources()	
	local currentStamina, maxStamina = GetUnitPower("player", POWERTYPE_STAMINA)
	local currentMagicka, maxMagicka = GetUnitPower("player", POWERTYPE_MAGICKA)
	local currentUltimate, maxUltimate = GetUnitPower("player", POWERTYPE_ULTIMATE)
	
	local ultimate = math.floor((currentUltimate / RdKGToolOverview.GetAbilityCost(RdKGToolOverview.charVars.ro.selectedUltimateId)) * 100)
	if ultimate > 100 then
		ultimate = 100
	end
	local magicka = math.floor((currentMagicka / maxMagicka) * 100)
	local stamina = math.floor((currentStamina / maxStamina) * 100)
	local debuffs = RdKGToolOverview.GetPlayerDebuffs()
	if debuffs > 7 then
		debuffs = 7
	end
	debuffs = RdKGToolMath.DecodeBitArrayHelper(debuffs)
	--d(debuffs)
	ultimate = RdKGToolMath.DecodeBitArrayHelper(ultimate)
	magicka = RdKGToolMath.DecodeBitArrayHelper(magicka)
	stamina = RdKGToolMath.DecodeBitArrayHelper(stamina)
	ultimate[8] = debuffs[1]
	magicka[8] = debuffs[2]
	stamina[8] = debuffs[3]
	ultimate = RdKGToolMath.EncodeBitArrayHelper(ultimate, 0)
	magicka = RdKGToolMath.EncodeBitArrayHelper(magicka, 0)
	stamina = RdKGToolMath.EncodeBitArrayHelper(stamina, 0)
	--d("GetPlayerResources")
	--d(ultimate)
	--d(magicka)
	--d(stamina)
	return RdKGToolOverview.charVars.ro.selectedUltimateId, ultimate, magicka, stamina
end

function RdKGToolOverview.AdjustStaminaMagickaBarVisibility()
	local playerBlocks = RdKGToolOverview.controls.groupUltimatesTLW.rootControl.playerBlocks
	if playerBlocks ~= nil then
		--RdKGToolOverview.AdjustSize()
		local sizeIncrease = RdKGToolOverview.roVars.size - RdKGToolOverview.constants.size.SMALL
		--local playerBlockWidth = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockWidth + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockWidth - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockWidth) * sizeIncrease)
		local playerBlockHeight = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockHeight + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockHeight - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockHeight) * sizeIncrease)
		local playerBlockMagickaHeight = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockMagickaHeight + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockMagickaHeight - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockMagickaHeight) * sizeIncrease)
		local playerBlockStaminaHeight = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockStaminaHeight + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockStaminaHeight - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockStaminaHeight) * sizeIncrease)
		local playerBlockWidth = RdKGToolOverview.state.playerBlockWidth
		for i = 1, #playerBlocks do
			playerBlocks[i].magickaProgress:SetHidden(not RdKGToolOverview.roVars.showSoftResources)
			playerBlocks[i].staminaProgress:SetHidden(not RdKGToolOverview.roVars.showSoftResources)
			
			if RdKGToolOverview.roVars.showSoftResources == true then
				playerBlocks[i].ultimateProgress:SetDimensions(playerBlockWidth, playerBlockHeight - playerBlockMagickaHeight - playerBlockStaminaHeight)
				
			else
				playerBlocks[i].ultimateProgress:SetDimensions(playerBlockWidth, playerBlockHeight)
				
			end
		end
		--RdKGToolOverview.AdjustSize()
	end
end

function RdKGToolOverview.AdjustColors()
	local playerBlocks = RdKGToolOverview.controls.groupUltimatesTLW.rootControl.playerBlocks
	if playerBlocks ~= nil then
		for i = 1, #playerBlocks do
			playerBlocks[i].magickaProgress:SetColor(RdKGToolOverview.roVars.playerBlockColors.magicka.r, RdKGToolOverview.roVars.playerBlockColors.magicka.g, RdKGToolOverview.roVars.playerBlockColors.magicka.b, 1.0)
			playerBlocks[i].staminaProgress:SetColor(RdKGToolOverview.roVars.playerBlockColors.stamina.r, RdKGToolOverview.roVars.playerBlockColors.stamina.g, RdKGToolOverview.roVars.playerBlockColors.stamina.b, 1.0)
			playerBlocks[i].backdrop:SetCenterColor(RdKGToolOverview.roVars.playerBlockColors.defaultBackground.r, RdKGToolOverview.roVars.playerBlockColors.defaultBackground.g, RdKGToolOverview.roVars.playerBlockColors.defaultBackground.b, 0.8)
			playerBlocks[i].backdrop:SetEdgeColor(0,0,0,0)
			playerBlocks[i].labelGroup:SetColor(RdKGToolOverview.roVars.playerBlockColors.labelGroup.r, RdKGToolOverview.roVars.playerBlockColors.labelGroup.g, RdKGToolOverview.roVars.playerBlockColors.labelGroup.b)
		end
	end
end

function RdKGToolOverview.ComparePlayersByUltiAssignmentThenPercent(playerA, playerB)
	if playerA.resources == nil or playerA.resources.ultimateAssignment == nil or
	   playerB.resources == nil or playerB.resources.ultimateAssignment == nil then
		if (playerA.resources == nil or playerA.resources.ultimateAssignment == nil) and 
		   (playerB.resources ~= nil and playerB.resources.ultimateAssignment ~= nil) then
			return false
		elseif (playerA.resources ~= nil and playerA.resources.ultimateAssignment ~= nil) and 
		   (playerB.resources == nil or playerB.resources.ultimateAssignment == nil) then
			return true
		else
			return RdKGToolOverview.ComparePlayersByUltiThenName(playerA, playerB)
		end
	end
	if playerA.resources.ultimateAssignment < playerB.resources.ultimateAssignment then
		return true
	elseif playerA.resources.ultimateAssignment > playerB.resources.ultimateAssignment then
		return false
	else
		return playerA.charName < playerB.charName
	end
end

function RdKGToolOverview.SortPlayersByUlti(oldPlayerList)
	local players = {}
	local highestAssignment = 0
	for i = 1, #oldPlayerList do
		players[i] = oldPlayerList[i]
		if players[i].resources ~= nil and players[i].resources.ultimateAssignment ~= nil and players[i].resources.ultimateAssignment > highestAssignment then
			highestAssignment = players[i].resources.ultimateAssignment
		end
		if players[i].resources ~= nil then
			players[i].resources.oldReference = oldPlayerList[i]
		end
	end
	--d("------------------")
	--d(highestAssignment)
	for i = 1, #players do
		if players[i].resources ~= nil and players[i].resources.ultimatePercent == 100 and players[i].resources.ultimateAssignment == nil then
			highestAssignment = highestAssignment + 1
			players[i].resources.ultimateAssignment = highestAssignment
			oldPlayerList[i].resources.ultimateAssignment = highestAssignment
			--d("new assignment")
		elseif players[i].resources.ultimatePercent == nil or players[i].resources.ultimatePercent < 100 then
			players[i].resources.ultimateAssignment = nil
			oldPlayerList[i].resources.ultimateAssignment = nil
			--d("assignment removed")
		end
	end

	table.sort(players, RdKGToolOverview.ComparePlayersByUltiAssignmentThenPercent)

	for i = 1, #players do
		if players[i].resources.ultimateAssignment ~= nil then
			players[i].resources.ultimateAssignment = i
			players[i].resources.oldReference.resources.ultimateAssignment = i
		end
	end
	return players
end

function RdKGToolOverview.ComparePlayersByUltiThenName(playerA, playerB)
	if playerA.resources == nil or playerA.resources.ultimatePercent == nil or
	   playerB.resources == nil or playerB.resources.ultimatePercent == nil then
	   
		if (playerA.resources == nil or playerA.resources.ultimatePercent == nil) and 
		   (playerB.resources ~= nil and playerB.resources.ultimatePercent ~= nil) then
			return false
		elseif (playerA.resources ~= nil and playerA.resources.ultimatePercent ~= nil) and 
		   (playerB.resources == nil or playerB.resources.ultimatePercent == nil) then
			return true
		else
			if playerA.charName == nil then
				return false
			elseif playerB.charName == nil then
				return true
			else
				return playerA.charName < playerB.charName
			end
		end
	end
	if playerA.resources.ultimatePercent < playerB.resources.ultimatePercent then
		return false
	elseif playerA.resources.ultimatePercent > playerB.resources.ultimatePercent then
		return true
	else
		if playerA.charName == nil then
			return false
		elseif playerB.charName == nil then
			return true
		else
			return playerA.charName < playerB.charName
		end
	end
end

function RdKGToolOverview.AdjustPlayerOrder(oldPlayerList)
	local players = {}
	if oldPlayerList ~= Nil then
		--[[
		if RdKGToolOverview.roVars.ultimates.sortingMode == RdKGToolOverview.constants.ultimateModes.ORDER_BY_GROUP then
		
		elseif RdKGToolOverview.roVars.ultimates.sortingMode == RdKGToolOverview.constants.ultimateModes.ORDER_BY_READINESS then
		
		elseif RdKGToolOverview.roVars.ultimates.sortingMode == RdKGToolOverview.constants.ultimateModes.ORDER_BY_NAME then
		]]
		
		if RdKGToolOverview.roVars.ultimates.sortingMode == RdKGToolOverview.constants.ultimateModes.ORDER_BY_NAME then
			for i = 1, #oldPlayerList do
				players[i] = oldPlayerList[i]
			end
			table.sort(players, RdKGToolOverview.ComparePlayersByUltiThenName)
		elseif RdKGToolOverview.roVars.ultimates.sortingMode == RdKGToolOverview.constants.ultimateModes.ORDER_BY_READINESS then
			players = RdKGToolOverview.SortPlayersByUlti(oldPlayerList)
		end
		--[[end]]
	end
	return players
end

function RdKGTool.IsUltimateDisplayed(ultimateId)
	local isDisplayed = false
	local index = 0
	if ultimateId ~= nil then
		local displayedUltimates = RdKGToolOverview.roVars.groupUltimatesSettings.displayedUltimates
		local ultimates = RdKGToolOverview.roVars.groupUltimatesSettings.ultimates
		for i = 1, displayedUltimates do
			if RdKGToolOverview.roVars.groupUltimatesSettings.ultimates[i] == ultimateId then
				isDisplayed = true
				index = i
				break
			end
		end
	end
	return isDisplayed, index
end

function RdKGToolOverview.GetUltimateGroupSize(ultimateId)
	local groupSize = 0
	local ultimateType = nil
	if ultimateId == 1 then --Negate
		groupSize = RdKGToolOverview.roVars.ultimates.groupSizeNegate
		ultimateType = "negate"
	elseif ultimateId == 5 then --Nova
		groupSize = RdKGToolOverview.roVars.ultimates.groupSizeNova
		ultimateType = "nova"
	elseif ultimateId == 13 then --Storm
		groupSize = RdKGToolOverview.roVars.ultimates.groupSizeStorm
		ultimateType = "storm"
	elseif ultimateId == 15 then --Destro
		groupSize = RdKGToolOverview.roVars.ultimates.groupSizeDestro
		ultimateType = "destro"
	elseif ultimateId == 29 then --Negate Offensive
		groupSize = RdKGToolOverview.roVars.ultimates.groupSizeNegateOffensive
		ultimateType = "negateOffensive"
	elseif ultimateId == 30 then --Negate Counter
		groupSize = RdKGToolOverview.roVars.ultimates.groupSizeNegateCounter
		ultimateType = "negateCounter"
	elseif ultimateId == 35 then --Storm
		groupSize = RdKGToolOverview.roVars.ultimates.groupSizeNorthernStorm
		ultimateType = "northernStorm"
	elseif ultimateId == 36 then --Storm
		groupSize = RdKGToolOverview.roVars.ultimates.groupSizePermafrost
		ultimateType = "permafrost"
	end
	return groupSize, ultimateType
end

function RdKGToolOverview.SendBoom()
	local message = {}
	message.b0 = RdKGToolNetworking.messageTypes.MESSAGE_ID_BOOM
	local array = RdKGToolOverview.GetGroupUltiArray()
	message.b1, message.b2, message.b3 = RdKGToolNetworking.EncodeBitArrayToMessage(array)
	message.sent = false
	
	local send = false
	for i = 1, #array do
		if array[i] == 1 then
			send = true
			break
		end
	end
	if send == true then
		--local mode = RdKGToolNetworking.GetUrgentMode()
		--[[if mode == RdKGToolNetworking.constants.urgentMode.DIRECT then
			local messageSent = RdKGToolNetworking.SendUrgentMessage(message)
			if messageSent == false then
				--retry
				zo_callLater(RdKGToolOverview.SendBoom, 500)
			end
		elseif mode == RdKGToolNetworking.constants.urgentMode.CRITICAL then]]
		if RdKGToolOverview.state.lastUrgentMessage == nil or RdKGToolOverview.state.lastUrgentMessage.sent == true then
			RdKGToolNetworking.SendMessage(message, RdKGToolNetworking.constants.priorities.CRITICAL)
			RdKGToolOverview.state.lastUrgentMessage = message
		else
			RdKGToolOverview.state.lastUrgentMessage.b1 = message.b1
			RdKGToolOverview.state.lastUrgentMessage.b2 = message.b2
			RdKGToolOverview.state.lastUrgentMessage.b3 = message.b3
		end
		--end
	end
	array = nil
	RdKGToolOverview.state.lastBoom = GetGameTimeMilliseconds()
end

function RdKGToolOverview.GetGroupUltiArray()
	local array = {}
	local index = 1
	local players = RdKGToolUtilGroup.GetGroupInformation()
	
	if players ~= nil then
		
		for i = 1, 24 do
			if players[i] == nil then
				array[i] = 0
			else
				local resources = players[i].resources
				if resources.ultiGroup == 1 then
					array[i] = 1
				else
					array[i] = 0
				end
			end
		end
	else
		for i = 1, 24 do 
			array[i] = 0
		end
	end
	return array
end

function RdKGToolOverview.IndexUltiGroup(unitTag, groupId)
	local players = RdKGToolUtilGroup.GetGroupInformation()
	if players ~= nil then
		for i = 1, #players do
			if players[i].unitTag == unitTag then
				players[i].resources.ultiGroup = groupId
			end
		end
	end
end

function RdKGToolOverview.AdjustAssignmentControlSize()
	local assignmentRootControl = RdKGToolOverview.controls.groupAssignmentTLW.rootControl
	RdKGToolOverview.controls.groupAssignmentTLW:SetDimensions(RdKGToolOverview.roVars.assignmentSize * 2.5, RdKGToolOverview.roVars.assignmentSize)
	assignmentRootControl:SetDimensions(RdKGToolOverview.roVars.assignmentSize * 2.5, RdKGToolOverview.roVars.assignmentSize)
	assignmentRootControl.movableBackdrop:SetDimensions(RdKGToolOverview.roVars.assignmentSize * 2.5, RdKGToolOverview.roVars.assignmentSize)
	assignmentRootControl.label:SetDimensions(RdKGToolOverview.roVars.assignmentSize * 2.5, RdKGToolOverview.roVars.assignmentSize)
	local font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolOverview.roVars.assignmentSize - 10, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THICK)
	assignmentRootControl.label:SetFont(font)
end

function RdKGToolOverview.GetGroupNameFromIndex(index)
	if index == nil or index == 0 then
		return "-"
	else
		return RdKGToolOverview.roVars.groups["group" .. (index)].name
	end
end

function RdKGToolOverview.GetGroupIndexFromName(value)
	if value == "-" then
		return 0
	else
		for i = 1, 5 do
			if RdKGToolOverview.roVars.groups["group" .. (i)].name == value then
				return i
			end
		end
	end
	return 0
end

function RdKGToolUtilGroup.SortPlayersByGroupsModePriorityName(playerA, playerB)
	if playerA.resources == nil or playerA.resources.ultimateId == nil or
	   playerB.resources == nil or playerB.resources.ultimateId == nil then
	   
		if (playerA.resources == nil or playerA.resources.ultimateId == nil) and 
		   (playerB.resources ~= nil and playerB.resources.ultimateId ~= nil) then
			return false
		elseif (playerA.resources ~= nil and playerA.resources.ultimateId ~= nil) and 
		   (playerB.resources == nil or playerB.resources.ultimateId == nil) then
			return true
		else
			if playerA.name == nil then
				return false
			elseif playerB.name == nil then
				return true
			else
				return playerA.name < playerB.name
			end
		end
	end
	local config = RdKGToolOverview.roVars.groups.ultimateGroups
	local priorityA = config[RdKGToolUltimates.GetUltimateIndexFromUltimateId(playerA.resources.ultimateId)].priority
	local priorityB = config[RdKGToolUltimates.GetUltimateIndexFromUltimateId(playerB.resources.ultimateId)].priority
	if  priorityA > priorityB then
		return false
	elseif priorityA < priorityB then
		return true
	else
		if playerA.resources.ultimateId > playerB.resources.ultimateId then
			return false
		elseif playerA.resources.ultimateId < playerB.resources.ultimateId then
			return true
		else
			if playerA.name == nil then
				return false
			elseif playerB.name == nil then
				return true
			else
				return playerA.name < playerB.name
			end
		end
	end
end

function RdKGToolUtilGroup.SortPlayersByGroupsModePriorityPercent(playerA, playerB)
		if playerA.resources == nil or playerA.resources.ultimateId == nil or
	   playerB.resources == nil or playerB.resources.ultimateId == nil then
	   
		if (playerA.resources == nil or playerA.resources.ultimateId == nil) and 
		   (playerB.resources ~= nil and playerB.resources.ultimateId ~= nil) then
			return false
		elseif (playerA.resources ~= nil and playerA.resources.ultimateId ~= nil) and 
		   (playerB.resources == nil or playerB.resources.ultimateId == nil) then
			return true
		else
			if playerA.name == nil then
				return false
			elseif playerB.name == nil then
				return true
			else
				return playerA.name < playerB.name
			end
		end
	end
	local config = RdKGToolOverview.roVars.groups.ultimateGroups
	local priorityA = config[RdKGToolUltimates.GetUltimateIndexFromUltimateId(playerA.resources.ultimateId)].priority
	local priorityB = config[RdKGToolUltimates.GetUltimateIndexFromUltimateId(playerB.resources.ultimateId)].priority
	if  priorityA > priorityB then
		return false
	elseif priorityA < priorityB then
		return true
	else
		if playerA.resources.ultimateId > playerB.resources.ultimateId then
			return false
		elseif playerA.resources.ultimateId < playerB.resources.ultimateId then
			return true
		else
			return RdKGToolOverview.ComparePlayersByUltiAssignmentThenPercent(playerA, playerB)
		end
		--return RdKGToolOverview.ComparePlayersByUltiAssignmentThenPercent(playerA, playerB)
	end
end

function RdKGToolUtilGroup.SortPlayersByGroupsModePercent(playerA, playerB)
	return RdKGToolOverview.ComparePlayersByUltiAssignmentThenPercent(playerA, playerB)
end

function RdKGToolOverview.AdjustGroupsShowSoftResources()
	local entries = RdKGToolOverview.controls.groupsEntries
	local setHidden = RdKGToolOverview.roVars.groups.showSoftResources
	local sizeIncrease = RdKGToolOverview.roVars.groups.size - RdKGToolOverview.constants.size.SMALL
	local entryWidth = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].entryWidth - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth) * sizeIncrease)
	local entryHeight = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].entryHeight - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight) * sizeIncrease)
	local softHeight = 0
	local fontSize = 0
	local edgeSize = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].edgeSize + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].edgeSize - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].edgeSize) * sizeIncrease)
	if setHidden == true then
		softHeight = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].softHeight + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].softHeight - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].softHeight) * sizeIncrease)
		fontSize = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].fontSizeWithResources + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].fontSizeWithResources - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].fontSizeWithResources) * sizeIncrease)
	else
		fontSize = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].fontSizeWithoutResources + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].fontSizeWithoutResources - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].fontSizeWithoutResources) * sizeIncrease)
	end
	
	for i = 1, #entries do
		entries[i].magicka:SetHidden(not setHidden)
		entries[i].stamina:SetHidden(not setHidden)
		entries[i].softBackdrop:SetHidden(not setHidden)
		local font = nil
		if setHidden == true then
			entries[i].progress:SetDimensions(entryWidth - entryHeight, entryHeight - edgeSize * 2 - softHeight * 2)
			font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
		else
			entries[i].progress:SetDimensions(entryWidth - entryHeight, entryHeight - edgeSize * 2)
			font = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
		end
		entries[i].name:SetFont(font)
		entries[i].percent:SetFont(font)
	end
end

function RdKGToolOverview.AdjustGroupsColor()
	local entries = RdKGToolOverview.controls.groupsEntries
	local bgColor = RdKGToolOverview.roVars.groups.backdropColor
	local magickaColor = RdKGToolOverview.roVars.groups.magicka
	local staminaColor = RdKGToolOverview.roVars.groups.stamina
	for	i = 1, #entries do
		entries[i].backdrop:SetCenterColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
		entries[i].softBackdrop:SetCenterColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
		entries[i].magicka:SetColor(magickaColor.r, magickaColor.g, magickaColor.b, magickaColor.a)
		entries[i].stamina:SetColor(staminaColor.r, staminaColor.g, staminaColor.b, staminaColor.a)
	end
end

function RdKGToolOverview.SortGroupsPlayersByUlti(oldPlayerList)
	local players = {}
	local highestAssignment = 0
	for i = 1, #oldPlayerList do
		players[i] = oldPlayerList[i]
		if players[i].resources ~= nil and players[i].resources.ultimateAssignment ~= nil and players[i].resources.ultimateAssignment > highestAssignment then
			highestAssignment = players[i].resources.ultimateAssignment
		end
		if players[i].resources ~= nil then
			players[i].resources.oldReference = oldPlayerList[i]
		end
	end
	--d("------------------")
	--d(highestAssignment)
	for i = 1, #players do
		if players[i].resources ~= nil and players[i].resources.ultimatePercent == 100 and players[i].resources.ultimateAssignment == nil then
			highestAssignment = highestAssignment + 1
			players[i].resources.ultimateAssignment = highestAssignment
			oldPlayerList[i].resources.ultimateAssignment = highestAssignment
			--d("new assignment")
		elseif players[i].resources.ultimatePercent == nil or players[i].resources.ultimatePercent < 100 then
			players[i].resources.ultimateAssignment = nil
			oldPlayerList[i].resources.ultimateAssignment = nil
			--d("assignment removed")
		end
	end
	if RdKGToolOverview.roVars.groups.mode == RdKGToolOverview.constants.groupsModes.MODE_PRIORITY_PERCENT then
		table.sort(players, RdKGToolUtilGroup.SortPlayersByGroupsModePriorityPercent)
	elseif RdKGToolOverview.roVars.groups.mode == RdKGToolOverview.constants.groupsModes.MODE_PERCENT then
		table.sort(players, RdKGToolUtilGroup.SortPlayersByGroupsModePercent)
	end
	for i = 1, #players do
		if players[i].resources.ultimateAssignment ~= nil then
			players[i].resources.ultimateAssignment = i
			players[i].resources.oldReference.resources.ultimateAssignment = i
		end
	end
	return players
end

function RdKGToolUtilGroup.SortPlayersForGroupEntries(oldPlayerList)
	local players = nil
	if oldPlayerList ~= nil then
		players = {}
		for i = 1, #oldPlayerList do
			players[i] = oldPlayerList[i]
		end
		if RdKGToolOverview.roVars.groups.mode == RdKGToolOverview.constants.groupsModes.MODE_PRIORITY_NAME then
			table.sort(players, RdKGToolUtilGroup.SortPlayersByGroupsModePriorityName)
		elseif RdKGToolOverview.roVars.groups.mode == RdKGToolOverview.constants.groupsModes.MODE_PRIORITY_PERCENT then
			players = RdKGToolOverview.SortGroupsPlayersByUlti(oldPlayerList)
		elseif RdKGToolOverview.roVars.groups.mode == RdKGToolOverview.constants.groupsModes.MODE_PERCENT then
			players = RdKGToolOverview.SortGroupsPlayersByUlti(oldPlayerList)
		end
	end	
	return players
end

function RdKGToolOverview.AdjustGroupsGroups()
	--d("adjust groups groups")
	local players = RdKGToolUtilGroup.GetGroupInformation()
	if players ~= nil then
		players = RdKGToolUtilGroup.SortPlayersForGroupEntries(players)
		local currentIndex = {}
		for i = 1, #RdKGToolOverview.controls.groupsTLW do
			currentIndex[i] = 1
		end
		local config = RdKGToolOverview.roVars.groups.ultimateGroups
		
		for i = 1, #players do
			if players[i].resources.ultimateId ~= nil then
				local ultimateIndex = RdKGToolUltimates.GetUltimateIndexFromUltimateId(players[i].resources.ultimateId)
				local groupId = config[ultimateIndex].group
				if groupId ~= nil and groupId ~= 0 then
					local entry = RdKGToolOverview.controls.groupsEntries[i]
					entry:ClearAnchors()
					local heightOffset = currentIndex[groupId] * (RdKGToolOverview.state.groupsEntryHeight + 2)
					entry:SetAnchor(TOPLEFT, RdKGToolOverview.controls.groupsTLW[groupId].rootControl,TOPLEFT, 0, heightOffset)
					entry:SetParent(RdKGToolOverview.controls.groupsTLW[groupId].rootControl)
					currentIndex[groupId] = currentIndex[groupId] + 1
					entry.charName = players[i].charName
					entry.displayName = players[i].displayName
					entry.unitTag = players[i].unitTag
					entry.name:SetText(players[i].name)
					entry.texture:SetTexture(RdKGToolUltimates.ultimates[ultimateIndex].icon)
					if RdKGToolOverview.roVars.groups.mode == RdKGToolOverview.constants.groupsModes.MODE_PRIORITY_PERCENT or RdKGToolOverview.roVars.groups.mode == RdKGToolOverview.constants.groupsModes.MODE_PERCENT then
						if players[i].resources ~= nil and players[i].resources.ultimatePercent ~= nil then
							entry.percent:SetText(string.format("%s %%", players[i].resources.ultimatePercent))
							entry.progress:SetValue(players[i].resources.ultimatePercent)
						else
							entry.progress:SetValue(0)
						end
						local progressColor = { r = RdKGToolOverview.roVars.groups.progressFull.r, g = RdKGToolOverview.roVars.groups.progressFull.g, b = RdKGToolOverview.roVars.groups.progressFull.b, a = RdKGToolOverview.roVars.groups.progressFull.a}
						if IsUnitDead(players[i].unitTag) == true then
							progressColor.r = RdKGToolOverview.roVars.groups.dead.r
							progressColor.g = RdKGToolOverview.roVars.groups.dead.g
							progressColor.b = RdKGToolOverview.roVars.groups.dead.b
							progressColor.a = RdKGToolOverview.roVars.groups.dead.a
						elseif players[i].distances ~= nil and players[i].distances.fromLeader ~= nil and RdKGToolOverview.roVars.groups.maxDistance < players[i].distances.fromLeader then
							progressColor.r = RdKGToolOverview.roVars.groups.outOfRange.r
							progressColor.g = RdKGToolOverview.roVars.groups.outOfRange.g
							progressColor.b = RdKGToolOverview.roVars.groups.outOfRange.b
							progressColor.a = RdKGToolOverview.roVars.groups.outOfRange.a
						elseif players[i].resources.ultimatePercent ~= 100 then
							progressColor.r = RdKGToolOverview.roVars.groups.progressNotFull.r
							progressColor.g = RdKGToolOverview.roVars.groups.progressNotFull.g
							progressColor.b = RdKGToolOverview.roVars.groups.progressNotFull.b
							progressColor.a = RdKGToolOverview.roVars.groups.progressNotFull.a
						end
						local labelColor = {r = RdKGToolOverview.roVars.groups.labelFull.r, g = RdKGToolOverview.roVars.groups.labelFull.g, b = RdKGToolOverview.roVars.groups.labelFull.b}
						if players[i].resources.ultimatePercent ~= 100 then
							labelColor.r = RdKGToolOverview.roVars.groups.labelNotFull.r
							labelColor.g = RdKGToolOverview.roVars.groups.labelNotFull.g
							labelColor.b = RdKGToolOverview.roVars.groups.labelNotFull.b
						end
						entry.progress:SetColor(progressColor.r, progressColor.g, progressColor.b, progressColor.a)
						entry.name:SetColor(labelColor.r, labelColor.g, labelColor.b)
						entry.percent:SetColor(labelColor.r, labelColor.g, labelColor.b)
						local edgeColor = RdKGToolOverview.roVars.groups.borderOutOfCombat
						if players[i].isInCombat == true then
							edgeColor = RdKGToolOverview.roVars.groups.borderInCombat
						end
						entry.edge:SetEdgeColor(edgeColor.r, edgeColor.g, edgeColor.b, 1)
						if RdKGToolOverview.roVars.groups.showSoftResources == true then
							entry.magicka:SetValue(players[i].resources.magickaPercent)
							entry.stamina:SetValue(players[i].resources.staminaPercent)
						end
					end
				else
					RdKGToolOverview.controls.groupsEntries[i]:ClearAnchors()
					RdKGToolOverview.controls.groupsEntries[i]:SetAnchor(TOPLEFT, RdKGToolOverview.controls.groupsEmptyTLW,TOPLEFT, 0, 0)
					RdKGToolOverview.controls.groupsEntries[i]:SetParent(RdKGToolOverview.controls.groupsEmptyTLW)
				end
			else
				RdKGToolOverview.controls.groupsEntries[i]:ClearAnchors()
				RdKGToolOverview.controls.groupsEntries[i]:SetAnchor(TOPLEFT, RdKGToolOverview.controls.groupsEmptyTLW,TOPLEFT, 0, 0)
				RdKGToolOverview.controls.groupsEntries[i]:SetParent(RdKGToolOverview.controls.groupsEmptyTLW)
			end
		end
		for i = #players + 1, 24 do
			RdKGToolOverview.controls.groupsEntries[i]:ClearAnchors()
			RdKGToolOverview.controls.groupsEntries[i]:SetAnchor(TOPLEFT, RdKGToolOverview.controls.groupsEmptyTLW,TOPLEFT, 0, 0)
			RdKGToolOverview.controls.groupsEntries[i]:SetParent(RdKGToolOverview.controls.groupsEmptyTLW)
		end
	else
		for i = 1, #RdKGToolOverview.controls.groupsEntries do
			RdKGToolOverview.controls.groupsEntries[i]:ClearAnchors()
			RdKGToolOverview.controls.groupsEntries[i]:SetAnchor(TOPLEFT, RdKGToolOverview.controls.groupsEmptyTLW,TOPLEFT, 0, 0)
			RdKGToolOverview.controls.groupsEntries[i]:SetParent(RdKGToolOverview.controls.groupsEmptyTLW)
		end
	end
end

function RdKGToolOverview.AdjustDisplayMode()
	RdKGToolOverview.AdjustSize()
end

function RdKGToolOverview.AdjustSize()
	--Primary Mode Configuration
	local sizeIncrease = RdKGToolOverview.roVars.size - RdKGToolOverview.constants.size.SMALL
	local playerBlockWidth = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockWidth + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockWidth - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockWidth) * sizeIncrease)
	local playerBlockHeight = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockHeight + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockHeight - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockHeight) * sizeIncrease)
	local ultiIconHeight = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].ultiIconHeight - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight) * sizeIncrease)
	local offset = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].offset - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].offset) * sizeIncrease)
	local ultiIconWidth = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].ultiIconWidth - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth) * sizeIncrease)
	RdKGToolOverview.state.playerBlockWidth = playerBlockWidth
	RdKGToolOverview.state.playerBlockHeight = playerBlockHeight
	RdKGToolOverview.state.ultiIconHeight = ultiIconHeight
	RdKGToolOverview.state.offset = offset
	local blockMagickaHeight = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockMagickaHeight + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockMagickaHeight - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockMagickaHeight) * sizeIncrease)
	local blockStaminaHeight = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockStaminaHeight + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockStaminaHeight - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockStaminaHeight) * sizeIncrease)
	local playerBlockGroupWidth = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockGroupWidth + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].playerBlockGroupWidth - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].playerBlockGroupWidth) * sizeIncrease)
	local ultimateFontSize = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].fontSize + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].fontSize - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].fontSize) * sizeIncrease)
	local ultimateFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, ultimateFontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	local ultimateFontStealth = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.GAMEPAD_MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, ultimateFontSize, RdKGToolFonts.constants.WEIGHT_THICK_OUTLINE)
	local spacing = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].spacingRatio + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].spacingRatio - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].spacingRatio) * sizeIncrease) * RdKGToolOverview.roVars.spacing
	RdKGToolOverview.state.spacing = spacing
	local border = (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].border + (RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.BIG].border - RdKGToolOverview.config.sizes[RdKGToolOverview.constants.size.SMALL].border) * sizeIncrease)

	RdKGToolOverview.state.cominedFontNormal = ultimateFont
	RdKGToolOverview.state.cominedFontStealth = ultimateFontStealth
	
	--Client
	RdKGToolOverview.controls.clientUltimateTLW:SetDimensions(ultiIconWidth + offset * 2, ultiIconHeight + offset * 2)
	
	local clientRootControl = RdKGToolOverview.controls.clientUltimateTLW.rootControl
	
	clientRootControl:SetDimensions(ultiIconWidth + offset * 2, ultiIconHeight + offset * 2)
	
	clientRootControl.movableBackdrop:SetDimensions(ultiIconWidth + offset * 2, ultiIconHeight + offset * 2)
	
	
	clientRootControl.ultimateSelector:SetDimensions(ultiIconWidth, ultiIconHeight)
	clientRootControl.ultimateSelector:ClearAnchors()
	clientRootControl.ultimateSelector:SetAnchor(TOPLEFT, clientRootControl, TOPLEFT, offset, offset)
	
	clientRootControl.ultimateSelector:SetDimensions(ultiIconWidth, ultiIconHeight)
	
	clientRootControl.ultimateSelector.button:SetDimensions(ultiIconWidth, ultiIconHeight)
	clientRootControl.ultimateSelector.texture:SetDimensions(ultiIconWidth - 4, ultiIconHeight - 4)
	
	if RdKGToolOverview.roVars.displayMode == RdKGToolOverview.constants.displayModes.CLASSIC then
		--Group Ultimates
		RdKGToolOverview.controls.groupUltimatesTLW:SetDimensions(ultiIconWidth * 12 + offset * 2, ultiIconHeight + offset * 2)
		local groupsRootControl = RdKGToolOverview.controls.groupUltimatesTLW.rootControl
		
		
		
		groupsRootControl:SetDimensions(ultiIconWidth * 12 + offset * 2, ultiIconHeight + offset * 2)

		groupsRootControl.movableBackdrop:SetDimensions(ultiIconWidth * 12 + offset * 2, ultiIconHeight + offset * 2)
		
		
		for i = 1, 12 do
			
			groupsRootControl.ultimateSelector[i].label:SetHidden(true)
			groupsRootControl.ultimateSelector[i]:SetDimensions(ultiIconWidth, ultiIconHeight)
			groupsRootControl.ultimateSelector[i]:ClearAnchors()
			groupsRootControl.ultimateSelector[i]:SetAnchor(TOPLEFT, groupsRootControl, TOPLEFT, offset + (ultiIconWidth * (i - 1)) + spacing * (i - 1), offset)
			
			groupsRootControl.ultimateSelector[i]:SetDimensions(ultiIconWidth, ultiIconHeight)
			
			groupsRootControl.ultimateSelector[i].button:SetDimensions(ultiIconWidth, ultiIconHeight)
			groupsRootControl.ultimateSelector[i].texture:SetDimensions(ultiIconWidth - 4, ultiIconHeight - 4)
			groupsRootControl.ultimateSelector[i].texture:SetAnchor(TOPLEFT, groupsRootControl.ultimateSelector[i], TOPLEFT, 2, 2)
		end
		
		--Group Selector Player Blocks
		for i = 1, 24 do
			
			local control = groupsRootControl.playerBlocks[i]
			control:SetDimensions(playerBlockWidth, playerBlockHeight)
			control.backdrop:SetDimensions(playerBlockWidth, playerBlockHeight)
			control.ultimateProgress:SetDimensions(playerBlockWidth, playerBlockHeight - blockMagickaHeight - blockStaminaHeight)
			
			control.magickaProgress:ClearAnchors()
			control.magickaProgress:SetAnchor(TOPLEFT, control, TOPLEFT, 0, playerBlockHeight - blockMagickaHeight - blockStaminaHeight)
			control.magickaProgress:SetDimensions(playerBlockWidth, blockMagickaHeight)
			
			control.staminaProgress:ClearAnchors()
			control.staminaProgress:SetAnchor(TOPLEFT, control, TOPLEFT, 0, playerBlockHeight - blockStaminaHeight)
			control.staminaProgress:SetDimensions(playerBlockWidth, blockStaminaHeight)
			
			control.labelName:ClearAnchors()
			control.labelName:SetAnchor(TOPLEFT, control, TOPLEFT, playerBlockGroupWidth, 0)
			control.labelName:SetFont(ultimateFont)
			control.labelName:SetWrapMode(ELLIPSIS)
			if RdKGToolOverview.roVars.showSoftResources == true then
				control.labelName:SetDimensions(playerBlockWidth - playerBlockGroupWidth - 2, playerBlockHeight - blockMagickaHeight - blockStaminaHeight)
				control.labelGroup:SetDimensions(playerBlockGroupWidth, playerBlockHeight - blockMagickaHeight - blockStaminaHeight - 2)
			else
				control.labelName:SetDimensions(playerBlockWidth - playerBlockGroupWidth - 2, playerBlockHeight)
				control.labelGroup:SetDimensions(playerBlockGroupWidth, playerBlockHeight - 2)
			end
			
			control.labelGroup:ClearAnchors()
			control.labelGroup:SetAnchor(TOPLEFT, control, TOPLEFT, 2, 0)
			control.labelGroup:SetFont(ultimateFont)
			--control.labelGroup:SetDimensions(playerBlockGroupWidth - 4, playerBlockHeight - blockMagickaHeight - blockStaminaHeight - 4)
			
			control.frontdrop:SetDimensions(playerBlockWidth, playerBlockHeight)
			
			control.border:SetDimensions(playerBlockWidth, playerBlockHeight)
			control.border:SetEdgeTexture(nil, 1, 1, border, 0)
		end
	elseif RdKGToolOverview.roVars.displayMode == RdKGToolOverview.constants.displayModes.SWIMLANES then
		local sizeIncrease = RdKGToolOverview.roVars.size - RdKGToolOverview.constants.size.SMALL
		local playerBlockWidth = (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockWidth + (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].playerBlockWidth - RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockWidth) * sizeIncrease)
		local playerBlockHeight = (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockHeight + (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].playerBlockHeight - RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockHeight) * sizeIncrease)
		local ultiIconHeight = (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight + (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].ultiIconHeight - RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].ultiIconHeight) * sizeIncrease)
		local offset = (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].offset + (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].offset - RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].offset) * sizeIncrease)
		local ultiIconWidth = (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth + (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].ultiIconWidth - RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].ultiIconWidth) * sizeIncrease)
		RdKGToolOverview.state.playerBlockWidth = playerBlockWidth
		RdKGToolOverview.state.playerBlockHeight = playerBlockHeight
		RdKGToolOverview.state.ultiIconHeight = ultiIconHeight
		RdKGToolOverview.state.offset = offset
		local blockMagickaHeight = (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockMagickaHeight + (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].playerBlockMagickaHeight - RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockMagickaHeight) * sizeIncrease)
		local blockStaminaHeight = (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockStaminaHeight + (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].playerBlockStaminaHeight - RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockStaminaHeight) * sizeIncrease)
		local playerBlockGroupWidth = (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockGroupWidth + (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].playerBlockGroupWidth - RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].playerBlockGroupWidth) * sizeIncrease)
		local ultimateFontSizePlayer = (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].fontSizePlayer + (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].fontSizePlayer - RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].fontSizePlayer) * sizeIncrease)
		local ultimateFontPlayer = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, ultimateFontSizePlayer, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
		local ultimateFontSizeHeader = (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].fontSizeHeader + (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].fontSizeHeader - RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].fontSizeHeader) * sizeIncrease)
		local ultimateFontHeader = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, ultimateFontSizeHeader, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
		local spacing = (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].spacingRatio + (RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.BIG].spacingRatio - RdKGToolOverview.config.swimLaneSizes[RdKGToolOverview.constants.size.SMALL].spacingRatio) * sizeIncrease) * RdKGToolOverview.roVars.spacing
		RdKGToolOverview.state.spacing = spacing
	
	
		local groupsRootControl = RdKGToolOverview.controls.groupUltimatesTLW.rootControl
		
		groupsRootControl:SetDimensions(playerBlockWidth * 12 + offset * 2, ultiIconHeight + offset * 2)

		groupsRootControl.movableBackdrop:SetDimensions(playerBlockWidth * 12 + offset * 2, ultiIconHeight + offset * 2)
		
		for i = 1, 12 do
			groupsRootControl.ultimateSelector[i].label:SetHidden(false)
			groupsRootControl.ultimateSelector[i].label:ClearAnchors()
			groupsRootControl.ultimateSelector[i].label:SetAnchor(TOPLEFT, groupsRootControl.ultimateSelector[i], TOPLEFT, ultiIconWidth, 0)
			groupsRootControl.ultimateSelector[i].label:SetFont(ultimateFontHeader)
			groupsRootControl.ultimateSelector[i].label:SetDimensions(playerBlockWidth - ultiIconWidth, ultiIconHeight)
			
			groupsRootControl.ultimateSelector[i]:SetDimensions(ultiIconWidth, ultiIconHeight)
			groupsRootControl.ultimateSelector[i]:ClearAnchors()
			groupsRootControl.ultimateSelector[i]:SetAnchor(TOPLEFT, groupsRootControl, TOPLEFT, offset + (playerBlockWidth * (i - 1)) + spacing * (i - 1), offset)
			
			groupsRootControl.ultimateSelector[i].button:SetDimensions(ultiIconWidth, ultiIconHeight)
			groupsRootControl.ultimateSelector[i].texture:SetDimensions(ultiIconWidth - 2 * sizeIncrease, ultiIconHeight - 2 * sizeIncrease)
			groupsRootControl.ultimateSelector[i].texture:SetAnchor(TOPLEFT, groupsRootControl.ultimateSelector[i], TOPLEFT, 1 * sizeIncrease, 1 * sizeIncrease)
		end
		
		--Group Selector Player Blocks
		for i = 1, 24 do
			
			local control = groupsRootControl.playerBlocks[i]
			control:SetDimensions(playerBlockWidth, playerBlockHeight)
			control.backdrop:SetDimensions(playerBlockWidth, playerBlockHeight)
			control.ultimateProgress:SetDimensions(playerBlockWidth, playerBlockHeight - blockMagickaHeight - blockStaminaHeight)
			
			control.magickaProgress:ClearAnchors()
			control.magickaProgress:SetAnchor(TOPLEFT, control, TOPLEFT, 0, playerBlockHeight - blockMagickaHeight - blockStaminaHeight)
			control.magickaProgress:SetDimensions(playerBlockWidth, blockMagickaHeight)
			
			control.staminaProgress:ClearAnchors()
			control.staminaProgress:SetAnchor(TOPLEFT, control, TOPLEFT, 0, playerBlockHeight - blockStaminaHeight)
			control.staminaProgress:SetDimensions(playerBlockWidth, blockStaminaHeight)
			
			control.labelName:ClearAnchors()
			control.labelName:SetAnchor(TOPLEFT, control, TOPLEFT, playerBlockGroupWidth, 0)
			control.labelName:SetFont(ultimateFont)
			control.labelName:SetWrapMode(ELLIPSIS)
			if RdKGToolOverview.roVars.showSoftResources == true then
				control.labelName:SetDimensions(playerBlockWidth - playerBlockGroupWidth - 2, playerBlockHeight - blockMagickaHeight - blockStaminaHeight)
				control.labelGroup:SetDimensions(playerBlockGroupWidth, playerBlockHeight - blockMagickaHeight - blockStaminaHeight - 2)
			else
				control.labelName:SetDimensions(playerBlockWidth - playerBlockGroupWidth - 2, playerBlockHeight)
				control.labelGroup:SetDimensions(playerBlockGroupWidth, playerBlockHeight - 2)
			end
			--control.labelName:SetDimensions(playerBlockWidth - playerBlockGroupWidth - 2, playerBlockHeight - blockMagickaHeight - blockStaminaHeight - 4)
			
			control.labelGroup:ClearAnchors()
			control.labelGroup:SetAnchor(TOPLEFT, control, TOPLEFT, 2, 0)
			control.labelGroup:SetFont(ultimateFont)
			--control.labelGroup:SetDimensions(playerBlockGroupWidth - 4, playerBlockHeight - blockMagickaHeight - blockStaminaHeight - 4)
			
			control.frontdrop:SetDimensions(playerBlockWidth, playerBlockHeight)
			
			control.border:SetDimensions(playerBlockWidth, playerBlockHeight)
			control.border:SetEdgeTexture(nil, 1, 1, border, 0)
		end
	end
	
	--Group Overview Window
	local assignmentWidth = (RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].width + (RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.BIG].width - RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].width) * sizeIncrease)
	local assignmentHeight = (RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].height + (RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.BIG].height - RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].height) * sizeIncrease)
	local assignmentBlockHeight = (RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].blockHeight + (RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.BIG].blockHeight - RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].blockHeight) * sizeIncrease)
	local assignmentFontSize = (RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].fontSize + (RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.BIG].fontSize - RdKGToolOverview.config.ultimateOverview[RdKGToolOverview.constants.size.SMALL].fontSize) * sizeIncrease)
	local assignmentFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, assignmentFontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THICK)
	
	
	
	RdKGToolOverview.controls.ultimateOverviewTLW:SetDimensions(assignmentWidth, assignmentHeight)

	local ultimateOverviewControl = RdKGToolOverview.controls.ultimateOverviewTLW.rootControl
	
	ultimateOverviewControl:SetDimensions(assignmentWidth, assignmentHeight)
	
	ultimateOverviewControl.movableBackdrop:SetDimensions(assignmentWidth, assignmentHeight)
	
	ultimateOverviewControl.destructionLabel:ClearAnchors()
	ultimateOverviewControl.destructionLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, 5, 0)
	ultimateOverviewControl.destructionLabel:SetFont(assignmentFont)
	ultimateOverviewControl.destructionLabel:SetDimensions(assignmentWidth - 20, height)
	
	ultimateOverviewControl.destructionLabel.currentBoomLabel:ClearAnchors()
	ultimateOverviewControl.destructionLabel.currentBoomLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, assignmentWidth - 20, 0)
	ultimateOverviewControl.destructionLabel.currentBoomLabel:SetFont(assignmentFont)
	ultimateOverviewControl.destructionLabel.currentBoomLabel:SetDimensions(20, assignmentHeight)
	
	ultimateOverviewControl.stormLabel:ClearAnchors()
	ultimateOverviewControl.stormLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, 5, assignmentBlockHeight)
	ultimateOverviewControl.stormLabel:SetFont(assignmentFont)
	ultimateOverviewControl.stormLabel:SetDimensions(assignmentWidth - 20, height)
	
	ultimateOverviewControl.stormLabel.currentBoomLabel:ClearAnchors()
	ultimateOverviewControl.stormLabel.currentBoomLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, assignmentWidth - 20, assignmentBlockHeight)
	ultimateOverviewControl.stormLabel.currentBoomLabel:SetFont(assignmentFont)
	ultimateOverviewControl.stormLabel.currentBoomLabel:SetDimensions(20, assignmentHeight)
	
	ultimateOverviewControl.negateLabel:ClearAnchors()
	ultimateOverviewControl.negateLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, 5, assignmentBlockHeight * 2)
	ultimateOverviewControl.negateLabel:SetFont(assignmentFont)
	ultimateOverviewControl.negateLabel:SetDimensions(assignmentWidth - 20, height)
	
	ultimateOverviewControl.negateLabel.currentBoomLabel:ClearAnchors()
	ultimateOverviewControl.negateLabel.currentBoomLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, assignmentWidth - 20, assignmentBlockHeight * 2)
	ultimateOverviewControl.negateLabel.currentBoomLabel:SetFont(assignmentFont)
	ultimateOverviewControl.negateLabel.currentBoomLabel:SetDimensions(20, assignmentHeight)
	
	ultimateOverviewControl.novaLabel:ClearAnchors()
	ultimateOverviewControl.novaLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, 5, assignmentBlockHeight * 3)
	ultimateOverviewControl.novaLabel:SetFont(assignmentFont)
	ultimateOverviewControl.novaLabel:SetDimensions(assignmentWidth - 20, height)
	
	ultimateOverviewControl.novaLabel.currentBoomLabel:ClearAnchors()
	ultimateOverviewControl.novaLabel.currentBoomLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, assignmentWidth - 20, assignmentBlockHeight * 3)
	ultimateOverviewControl.novaLabel.currentBoomLabel:SetFont(assignmentFont)
	ultimateOverviewControl.novaLabel.currentBoomLabel:SetDimensions(20, assignmentHeight)
	
	
	
	
	RdKGToolOverview.SetDisplayedUltimates(RdKGToolOverview.roVars.groupUltimatesSettings.displayedUltimates)
	RdKGToolOverview.AdjustStaminaMagickaBarVisibility()
	RdKGToolOverview.UiLoop()
	
	
	--Groups Window Configuration
	RdKGToolOverview.AdjustGroupsShowSoftResources()
	
	
	local sizeIncrease = RdKGToolOverview.roVars.groups.size - RdKGToolOverview.constants.size.SMALL
	local width = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].width + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].width - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].width) * sizeIncrease)
	local height = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].height + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].height - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].height) * sizeIncrease)
	local entryWidth = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].entryWidth - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryWidth) * sizeIncrease)
	local entryHeight = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].entryHeight - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryHeight) * sizeIncrease)
	local edgeSize = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].edgeSize + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].edgeSize - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].edgeSize) * sizeIncrease)
	local captionFontSize = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].captionFontSize + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].captionFontSize - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].captionFontSize) * sizeIncrease)
	local softHeight = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].softHeight + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].softHeight - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].softHeight) * sizeIncrease)
	local entryPercentWidth = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryPercentWidth + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].entryPercentWidth - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].entryPercentWidth) * sizeIncrease)
	RdKGToolOverview.state.groupsEntryHeight = entryHeight
	
	local setHidden = RdKGToolOverview.roVars.groups.showSoftResources
	local fontSize = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].fontSizeWithResources + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].fontSizeWithResources - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].fontSizeWithResources) * sizeIncrease)
	if setHidden == false then
		fontSize = (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].fontSizeWithoutResources + (RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.BIG].fontSizeWithoutResources - RdKGToolOverview.config.groups[RdKGToolOverview.constants.size.SMALL].fontSizeWithoutResources) * sizeIncrease)
	end
	local fontNormal = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, fontSize, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THIN)
	local fontStealth = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.GAMEPAD_MEDIUM_FONT, RdKGToolFonts.constants.INPUT_KB, fontSize, RdKGToolFonts.constants.WEIGHT_THICK_OUTLINE)
	
	RdKGToolOverview.state.splitFontNormal = fontNormal
	RdKGToolOverview.state.splitFontStealth = fontStealth
	
	local captionFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.BOLD_FONT, RdKGToolFonts.constants.INPUT_KB, captionFontSize, RdKGToolFonts.constants.WEIGHT_THICK_OUTLINE)
	
	for i = 1, #RdKGToolOverview.controls.groupsTLW do
		RdKGToolOverview.controls.groupsTLW[i].rootControl.caption:SetFont(captionFont)
		RdKGToolOverview.controls.groupsTLW[i].rootControl.caption:SetDimensions(entryWidth, entryHeight)
		RdKGToolOverview.controls.groupsTLW[i]:SetDimensions(width, height)
		RdKGToolOverview.controls.groupsTLW[i].rootControl:SetDimensions(width, height)
		RdKGToolOverview.controls.groupsTLW[i].rootControl.movableBackdrop:SetDimensions(width, height)
	end
	
	for i = 1, #RdKGToolOverview.controls.groupsEntries do
		local control = RdKGToolOverview.controls.groupsEntries[i]
		
		control:SetDimensions(entryWidth, RentryHeight)
		
		control.backdrop:SetDimensions(entryWidth, entryHeight)

	
		control.edge:SetDimensions(entryWidth, entryHeight)
		control.edge:SetEdgeTexture(nil, 1, 1, edgeSize, 0)
		
		control.progress:ClearAnchors()
		control.progress:SetAnchor(TOPLEFT, control, TOPLEFT, entryHeight - edgeSize, 2)
		control.progress:SetDimensions(entryWidth - entryHeight, entryHeight - edgeSize * 2)
		
		control.softBackdrop:ClearAnchors()
		control.softBackdrop:SetAnchor(TOPLEFT, control, TOPLEFT, entryHeight - 2, entryHeight - softHeight * 2 - edgeSize)
		control.softBackdrop:SetDimensions(entryWidth - entryHeight, softHeight * 2)
		
		control.magicka:ClearAnchors()
		control.magicka:SetAnchor(TOPLEFT, control, TOPLEFT, entryHeight - edgeSize, entryHeight - softHeight * 2 - edgeSize)
		control.magicka:SetDimensions(entryWidth - entryHeight, softHeight)

		control.stamina:ClearAnchors()
		control.stamina:SetAnchor(TOPLEFT, control, TOPLEFT, entryHeight - edgeSize, entryHeight - softHeight - edgeSize)
		control.stamina:SetDimensions(entryWidth - entryHeight, softHeight)

		
		control.name:ClearAnchors()
		control.name:SetAnchor(TOPLEFT, control, TOPLEFT, entryHeight, edgeSize)
		if setHidden == false then
			control.name:SetDimensions(entryWidth - entryHeight - entryPercentWidth - edgeSize, entryHeight - edgeSize * 2)
		else
			control.name:SetDimensions(entryWidth - entryHeight - entryPercentWidth - edgeSize, entryHeight - edgeSize * 2 - softHeight * 1.5)
		end
		
		control.percent:ClearAnchors()
		control.percent:SetAnchor(TOPLEFT, control, TOPLEFT, entryHeight + (entryWidth - entryHeight - entryPercentWidth) - edgeSize, edgeSize)
		if setHidden == false then
			control.percent:SetDimensions(entryPercentWidth, entryHeight - edgeSize * 2)
		else
			control.percent:SetDimensions(entryPercentWidth, entryHeight - edgeSize * 2 - softHeight * 1.5)
		end
		
		control.texture:ClearAnchors()
		control.texture:SetAnchor(TOPLEFT, control, TOPLEFT, edgeSize, edgeSize)
		control.texture:SetDimensions(entryHeight - edgeSize * 2, entryHeight - edgeSize * 2)

	end
	RdKGToolOverview.AdjustGroupsGroups()
end

--callbacks
function RdKGToolOverview.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolOverview.roVars = currentProfile.group.ro
		RdKGToolOverview.SetEnabled(RdKGToolOverview.roVars.enabled)
		RdKGToolOverview.charVars = RdKGTool.profile.GetCharacterVars()
		RdKGToolOverview.charVars.ro = RdKGToolOverview.charVars.ro or {}
		if RdKGToolOverview.state.initialized == true then
			RdKGToolOverview.controls.groupAssignmentTLW.rootControl.label:SetColor(RdKGToolOverview.roVars.assignmentColor.r, RdKGToolOverview.roVars.assignmentColor.g, RdKGToolOverview.roVars.assignmentColor.b, 1)
			RdKGToolOverview.AdjustSize()
			RdKGToolOverview.AdjustAssignmentControlSize()
			RdKGToolOverview.AdjustColors()
			RdKGToolOverview.AdjustStaminaMagickaBarVisibility()
			RdKGToolOverview.SetControlVisibility()
			RdKGToolOverview.SetTlwLocation()
			RdKGToolOverview.SetDisplayedUltimates(RdKGToolOverview.roVars.groupUltimatesSettings.displayedUltimates)
			RdKGToolOverview.AdjustGroupNames()
			RdKGToolOverview.AdjustGroupsShowSoftResources()
			RdKGToolOverview.AdjustGroupsColor()
			RdKGToolOverview.SetPositionLocked(RdKGToolOverview.roVars.positionLocked)
			RdKGToolOverview.AdjustInCombatSettings()
			
		end
	end
end

function RdKGToolOverview.SaveClientUltimateWindowLocation()
	if RdKGToolOverview.roVars.positionLocked == false then
		RdKGToolOverview.roVars.clientUltimateSettings.location = RdKGToolOverview.roVars.clientUltimateSettings.location or {}
		RdKGToolOverview.roVars.clientUltimateSettings.location.x = RdKGToolOverview.controls.clientUltimateTLW:GetLeft()
		RdKGToolOverview.roVars.clientUltimateSettings.location.y = RdKGToolOverview.controls.clientUltimateTLW:GetTop()
	end
end

function RdKGToolOverview.SaveGroupUltimatesWindowLocation()
	if RdKGToolOverview.roVars.positionLocked == false then
		RdKGToolOverview.roVars.groupUltimatesSettings.location = RdKGToolOverview.roVars.groupUltimatesSettings.location or {}
		RdKGToolOverview.roVars.groupUltimatesSettings.location.x = RdKGToolOverview.controls.groupUltimatesTLW:GetLeft()
		RdKGToolOverview.roVars.groupUltimatesSettings.location.y = RdKGToolOverview.controls.groupUltimatesTLW:GetTop()
	end
end

function RdKGToolOverview.SaveGroupAssignmentWindowLocation()
	if RdKGToolOverview.roVars.positionLocked == false then
		RdKGToolOverview.roVars.groupAssignmentSettings.location = RdKGToolOverview.roVars.groupAssignmentSettings.location or {}
		RdKGToolOverview.roVars.groupAssignmentSettings.location.x = RdKGToolOverview.controls.groupAssignmentTLW:GetLeft()
		RdKGToolOverview.roVars.groupAssignmentSettings.location.y = RdKGToolOverview.controls.groupAssignmentTLW:GetTop()
	end
end

function RdKGToolOverview.SaveUltimateOverviewLocation()
	if RdKGToolOverview.roVars.positionLocked == false then
		RdKGToolOverview.roVars.ultimateOverviewSettings.location = RdKGToolOverview.roVars.ultimateOverviewSettings.location or {}
		RdKGToolOverview.roVars.ultimateOverviewSettings.location.x = RdKGToolOverview.controls.ultimateOverviewTLW:GetLeft()
		RdKGToolOverview.roVars.ultimateOverviewSettings.location.y = RdKGToolOverview.controls.ultimateOverviewTLW:GetTop()
	end
end

function RdKGToolOverview.SaveGroupsGroupWindowLocation()
	if RdKGToolOverview.roVars.positionLocked == false then
		RdKGToolOverview.roVars.groups.location = RdKGToolOverview.roVars.groups.location or {}
		for i = 1, #RdKGToolOverview.controls.groupsTLW do
			RdKGToolOverview.roVars.groups.location[i] = RdKGToolOverview.roVars.groups.location[i] or {}
			RdKGToolOverview.roVars.groups.location[i].x = RdKGToolOverview.controls.groupsTLW[i]:GetLeft()
			RdKGToolOverview.roVars.groups.location[i].y = RdKGToolOverview.controls.groupsTLW[i]:GetTop()
		end
	end
end

function RdKGToolOverview.OnPlayerActivated(eventCode, initial)
	if RdKGToolOverview.roVars.enabled == true and (RdKGToolOverview.roVars.pvpOnly == false or (RdKGToolOverview.roVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea() == true)) then
		if RdKGToolOverview.state.registredGlobalConsumers == false then
			EVENT_MANAGER:RegisterForUpdate(RdKGToolOverview.networkingCallbackName, RdKGToolOverview.config.networkUpdateInterval, RdKGToolOverview.MessageUpdateLoop)
			EVENT_MANAGER:RegisterForUpdate(RdKGToolOverview.messageCallbackName, RdKGToolOverview.config.messageUpdateInterval, RdKGToolOverview.NetworkLoop)
			RdKGToolUtilGroup.AddFeature(RdKGToolOverview.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_LEADER_TO_MEMBER_DISTANCE, RdKGToolOverview.config.uiUpdateInterval)
			RdKGToolUtilGroup.AddFeature(RdKGToolOverview.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_RESOURCES, RdKGToolOverview.config.uiUpdateInterval)
			RdKGToolUtilGroup.AddFeature(RdKGToolOverview.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS, RdKGToolOverview.config.buffUpdateInterval)
			RdKGToolNetworking.AddRawMessageHandler(RdKGToolOverview.callbackName, RdKGToolOverview.HandleRawNetworkMessage)
			RdKGToolOverview.state.registredGlobalConsumers = true
		end
		if RdKGToolOverview.roVars.groupUltimatesSettings.enabled == true or
		   RdKGToolOverview.roVars.ultimateOverviewSettings.enabled == true or
		   RdKGToolOverview.roVars.ultimates.enabled == true then
			if RdKGToolOverview.state.registredActiveConsumers == false then
				EVENT_MANAGER:RegisterForUpdate(RdKGToolOverview.uiCallbackName, RdKGToolOverview.config.uiUpdateInterval, RdKGToolOverview.UiLoop)
				RdKGToolOverview.state.registredActiveConsumers = true
			end
		else
			if RdKGToolOverview.state.registredActiveConsumers == true then
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolOverview.uiCallbackName)
				RdKGToolOverview.state.registredActiveConsumers = false
			end
		end
		if RdKGToolOverview.roVars.groups.enabled == true then
			if RdKGToolOverview.state.registredGroupsConsumers == false then
				EVENT_MANAGER:RegisterForUpdate(RdKGToolOverview.groupsUiCallbackName, RdKGToolOverview.config.groupsUiUpdateInterval, RdKGToolOverview.GroupsUiLoop)
				RdKGToolUtilGroup.AddGroupChangedCallback(RdKGToolOverview.callbackName, RdKGToolOverview.AdjustGroupsGroups)
				RdKGToolUtilGroup.AddUltimatesChangedCallback(RdKGToolOverview.callbackName, RdKGToolOverview.AdjustGroupsGroups)
				RdKGToolOverview.state.registredGroupsConsumers = true
			end
			RdKGToolOverview.AdjustGroupsGroups()
		else
			if RdKGToolOverview.state.registredGroupsConsumers == true then
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolOverview.groupsUiCallbackName)
				RdKGToolUtilGroup.RemoveGroupChangedCallback(RdKGToolOverview.callbackName)
				RdKGToolUtilGroup.RemoveUltimatesChangedCallback(RdKGToolOverview.callbackName)
				RdKGToolOverview.state.registredGroupsConsumers = false
			end
		end
	else
		if RdKGToolOverview.state.registredGlobalConsumers == true then
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolOverview.networkingCallbackName)
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolOverview.messageCallbackName)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolOverview.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_LEADER_TO_MEMBER_DISTANCE)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolOverview.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_RESOURCES)
			RdKGToolUtilGroup.RemoveFeature(RdKGToolOverview.callbackName, RdKGToolUtilGroup.features.FEATURE_GROUP_BUFFS)
			RdKGToolNetworking.RemoveRawMessageHandler(RdKGToolOverview.callbackName)
			RdKGToolOverview.state.registredGlobalConsumers = false
		end
		if RdKGToolOverview.state.registredActiveConsumers == true then
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolOverview.uiCallbackName)
			RdKGToolOverview.state.registredActiveConsumers = false
		end
		if RdKGToolOverview.state.registredGroupsConsumers == true then
			EVENT_MANAGER:UnregisterForUpdate(RdKGToolOverview.groupsUiCallbackName)
			RdKGToolUtilGroup.RemoveGroupChangedCallback(RdKGToolOverview.callbackName)
			RdKGToolUtilGroup.RemoveUltimatesChangedCallback(RdKGToolOverview.callbackName)
			RdKGToolOverview.state.registredGroupsConsumers = false
		end
	end
	RdKGToolOverview.SetControlVisibility()
end

function RdKGToolOverview.ShowUltimateControlOptions(control)
	if control ~= nil then
		ClearMenu()
		local ultimates = RdKGToolUltimates.ultimates
		for i = 1, #ultimates do
			AddCustomMenuItem(ultimates[i].name, function() 
				if control.clickFunction ~= nil and type(control.clickFunction) == "function" then
					control.clickFunction(control, i)
				end
			end)
		end
		ShowMenu(control)
	end
end
	
function RdKGToolOverview.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolOverview.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolOverview.state.foreground = false
	end
	RdKGToolOverview.SetControlVisibility()
end

function RdKGToolOverview.UiLoop()
	--d("normal ui loop")
	local players = RdKGToolUtilGroup.GetGroupInformation()
	local playerBlocks = RdKGToolOverview.controls.groupUltimatesTLW.rootControl.playerBlocks
	if RdKGToolOverview.roVars.pvpOnly == false or (RdKGToolOverview.roVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea()) then

		
		
		if players ~= nil then
			if playerBlocks ~= nil then
				--Update Ultimates
				local rootControl = RdKGToolOverview.controls.groupUltimatesTLW.rootControl
				players = RdKGToolOverview.AdjustPlayerOrder(players)
				RdKGToolOverview.state.groupUltimateStacks = {}
				RdKGToolOverview.state.groupUltimateAssignments = {}
				local gameTime = GetGameTimeMilliseconds()
				local groupUltimatesReady = {}
				groupUltimatesReady.destro = 0
				groupUltimatesReady.storm = 0
				groupUltimatesReady.northernStorm = 0
				groupUltimatesReady.permafrost = 0
				groupUltimatesReady.negate = 0
				groupUltimatesReady.negateOffensive = 0
				groupUltimatesReady.negateCounter = 0
				groupUltimatesReady.nova = 0
				local groupUltimatesInRange = {}
				groupUltimatesInRange.destro = 0
				groupUltimatesInRange.storm = 0
				groupUltimatesInRange.northernStorm = 0
				groupUltimatesInRange.permafrost = 0
				groupUltimatesInRange.negate = 0
				groupUltimatesInRange.negateOffensive = 0
				groupUltimatesInRange.negateCounter = 0
				groupUltimatesInRange.nova = 0

				for i = 1, #players do
					
					local resources = players[i].resources
					local isDisplayed, index = RdKGTool.IsUltimateDisplayed(resources.ultimateId)
					if isDisplayed == true and players[i].isOnline == true and RdKGToolOverview.constants.OFFLINE_TRESHOLD + players[i].resources.lastPing > gameTime then
						if RdKGToolOverview.roVars.groupUltimatesSettings.enabled == true then
							playerBlocks[i]:SetHidden(false)
							local stack = RdKGToolOverview.state.groupUltimateStacks[resources.ultimateId]
							if stack == nil then
								stack = 0
							end
							
							playerBlocks[i].ultimateProgress:SetValue(resources.ultimatePercent)
							playerBlocks[i].magickaProgress:SetValue(resources.magickaPercent)
							playerBlocks[i].staminaProgress:SetValue(resources.staminaPercent)
							-- To change the font when a player is in stealth
							if RdKGToolOverview.roVars.combinedInStealthEnabled == true then
								if players[i].isInStealth > 0 then
									playerBlocks[i].labelName:SetFont(RdKGToolOverview.state.cominedFontStealth)
								else
									playerBlocks[i].labelName:SetFont(RdKGToolOverview.state.cominedFontNormal)
								end
							else
								playerBlocks[i].labelName:SetFont(RdKGToolOverview.state.cominedFontNormal)
							end
							
							playerBlocks[i].labelName:SetText(players[i].name)
							playerBlocks[i]:ClearAnchors()
							playerBlocks[i]:SetAnchor(TOPLEFT, rootControl, TOPLEFT, (index - 1) * RdKGToolOverview.state.playerBlockWidth + RdKGToolOverview.state.offset + RdKGToolOverview.state.spacing * (index - 1), stack * RdKGToolOverview.state.playerBlockHeight + RdKGToolOverview.state.ultiIconHeight + RdKGToolOverview.state.offset)
							stack = stack + 1
							RdKGToolOverview.state.groupUltimateStacks[resources.ultimateId] = stack
							
							if IsUnitDead(players[i].unitTag) == true then
								playerBlocks[i].frontdrop:SetHidden(false)
								playerBlocks[i].frontdrop:SetCenterColor(RdKGToolOverview.roVars.playerBlockColors.dead.r, RdKGToolOverview.roVars.playerBlockColors.dead.g, RdKGToolOverview.roVars.playerBlockColors.dead.b, 0.6)
							elseif players[i].distances ~= nil and players[i].distances.fromLeader ~= nil and RdKGToolOverview.roVars.ultimates.maxDistance < players[i].distances.fromLeader then
								playerBlocks[i].frontdrop:SetHidden(false)
								playerBlocks[i].frontdrop:SetCenterColor(RdKGToolOverview.roVars.playerBlockColors.outOfRange.r, RdKGToolOverview.roVars.playerBlockColors.outOfRange.g, RdKGToolOverview.roVars.playerBlockColors.outOfRange.b, 0.8)
							else
								playerBlocks[i].frontdrop:SetHidden(true)
							end
						end
					else
						playerBlocks[i]:SetHidden(true)
					end
					if RdKGToolOverview.roVars.playerBlockColors.inCombatEnabled == true then
						local borderColor = RdKGToolOverview.roVars.playerBlockColors.borderOutOfCombat
						if players[i].isInCombat == true then
							borderColor = RdKGToolOverview.roVars.playerBlockColors.borderInCombat
						end
						playerBlocks[i].border:SetEdgeColor(borderColor.r, borderColor.g, borderColor.b, 1)
					end
					if resources.ultimatePercent == nil or resources.ultimatePercent < 100 then
						playerBlocks[i].ultimateProgress:SetColor(RdKGToolOverview.roVars.playerBlockColors.progressNotFull.r, RdKGToolOverview.roVars.playerBlockColors.progressNotFull.g, RdKGToolOverview.roVars.playerBlockColors.progressNotFull.b)
						playerBlocks[i].labelName:SetColor(RdKGToolOverview.roVars.playerBlockColors.labelNotFull.r, RdKGToolOverview.roVars.playerBlockColors.labelNotFull.g, RdKGToolOverview.roVars.playerBlockColors.labelNotFull.b)
						playerBlocks[i].labelGroup:SetText("")
						--RdKGToolOverview.controls.groupAssignmentTLW.rootControl.label:SetText("")
						RdKGToolOverview.IndexUltiGroup(players[i].unitTag, 0)
					else
						local groupIndex = 0
						local groupSize, ultimateType = RdKGToolOverview.GetUltimateGroupSize(resources.ultimateId)
						if ultimateType ~= nil then
							groupUltimatesReady[ultimateType] = groupUltimatesReady[ultimateType] + 1
						end
						if groupSize > 0 and IsUnitDead(players[i].unitTag) == false and players[i].distances ~= nil and players[i].distances.fromLeader ~= nil and RdKGToolOverview.roVars.ultimates.maxDistance >= players[i].distances.fromLeader and players[i].isOnline == true then 
							local assignment = RdKGToolOverview.state.groupUltimateAssignments[resources.ultimateId]
							if assignment == nil then
								assignment = 0
							end
							assignment = assignment + 1
							groupIndex = (assignment - (assignment % groupSize)) / groupSize
							if assignment % groupSize ~= 0 then
								groupIndex = groupIndex + 1
							end
							RdKGToolOverview.state.groupUltimateAssignments[resources.ultimateId] = assignment
							if ultimateType ~= nil then
								groupUltimatesInRange[ultimateType] = groupUltimatesInRange[ultimateType] + 1
							end
						end
						if groupIndex == 0 then
							playerBlocks[i].labelGroup:SetText("")
						elseif RdKGToolOverview.roVars.ultimates.enabled == true then
							playerBlocks[i].labelGroup:SetText(groupIndex)
						else
							playerBlocks[i].labelGroup:SetText("")
						end
						RdKGToolOverview.IndexUltiGroup(players[i].unitTag, groupIndex)
						
						playerBlocks[i].ultimateProgress:SetColor(RdKGToolOverview.roVars.playerBlockColors.progressFull.r, RdKGToolOverview.roVars.playerBlockColors.progressFull.g, RdKGToolOverview.roVars.playerBlockColors.progressFull.b)
						playerBlocks[i].labelName:SetColor(RdKGToolOverview.roVars.playerBlockColors.labelFull.r, RdKGToolOverview.roVars.playerBlockColors.labelFull.g, RdKGToolOverview.roVars.playerBlockColors.labelFull.b)
						
					end
					if players[i].displayName == GetUnitDisplayName("player") and players[i].charName == GetUnitName("player") then
						--d(groupIndex)
						local groupIndex = players[i].resources.ultiGroup
						if RdKGToolOverview.roVars.ultimates.enabled == true then
							if groupIndex == 0 then
								if RdKGToolOverview.state.useUltimateCommandReceived == true and
								   RdKGToolOverview.state.useUltimateCommandTimeStamp + 3000 > GetGameTimeMilliseconds() then
									RdKGToolOverview.controls.groupAssignmentTLW.rootControl.label:SetText(RdKGToolOverview.constants.BOOM)
								else
									RdKGToolOverview.controls.groupAssignmentTLW.rootControl.label:SetText("")
									RdKGToolOverview.state.useUltimateCommandReceived = false
								end
							else
								if RdKGToolOverview.state.useUltimateCommandReceived == true and
								   RdKGToolOverview.state.useUltimateCommandTimeStamp + 3000 > GetGameTimeMilliseconds() then
									RdKGToolOverview.controls.groupAssignmentTLW.rootControl.label:SetText(RdKGToolOverview.constants.BOOM)
									--RdKGToolOverview.controls.groupAssignmentTLW.rootControl.label:SetHidden(false) --Bug Fix 1.12.0? failed
								else
									RdKGToolOverview.controls.groupAssignmentTLW.rootControl.label:SetText(groupIndex)
									RdKGToolOverview.state.useUltimateCommandReceived = false
								end
							end
						end
					end
				end
				for i = #players + 1, 24 do
					playerBlocks[i]:SetHidden(true)
				end
				--Update Overview
				if RdKGToolOverview.roVars.ultimateOverviewSettings.enabled == true and RdKGToolOverview.roVars.ultimates.enabled == true then
					local ultimateOverviewControl = RdKGToolOverview.controls.ultimateOverviewTLW.rootControl
					ultimateOverviewControl.destructionLabel:SetText(string.format(string.format(RdKGToolOverview.constants.ULTIMATE_OVERVIEW_STRING, groupUltimatesInRange.destro, groupUltimatesReady.destro, RdKGToolOverview.constants.IDENENTIFIER_DESTRUCTION)))
					ultimateOverviewControl.stormLabel:SetText(string.format(string.format(RdKGToolOverview.constants.ULTIMATE_OVERVIEW_STRING, groupUltimatesInRange.storm + groupUltimatesInRange.northernStorm + groupUltimatesInRange.permafrost, groupUltimatesReady.storm + groupUltimatesReady.northernStorm + groupUltimatesReady.permafrost, RdKGToolOverview.constants.IDENENTIFIER_STORM)))
					ultimateOverviewControl.negateLabel:SetText(string.format(string.format(RdKGToolOverview.constants.ULTIMATE_OVERVIEW_STRING, groupUltimatesInRange.negate + groupUltimatesInRange.negateOffensive + groupUltimatesInRange.negateCounter, groupUltimatesReady.negate + groupUltimatesReady.negateOffensive + groupUltimatesReady.negateCounter, RdKGToolOverview.constants.IDENENTIFIER_NEGATE)))
					ultimateOverviewControl.novaLabel:SetText(string.format(string.format(RdKGToolOverview.constants.ULTIMATE_OVERVIEW_STRING, groupUltimatesInRange.nova, groupUltimatesReady.nova, RdKGToolOverview.constants.IDENENTIFIER_NOVA)))
					if RdKGToolOverview.state.sentUltimateCommandTimeStamp + 3000 <= GetGameTimeMilliseconds() then
						ultimateOverviewControl.destructionLabel.currentBoomLabel:SetText("0")
						ultimateOverviewControl.stormLabel.currentBoomLabel:SetText("0")
						ultimateOverviewControl.negateLabel.currentBoomLabel:SetText("0")
						ultimateOverviewControl.novaLabel.currentBoomLabel:SetText("0")
					end
				end
			end
		else
			if playerBlocks ~= nil then
				for i = 1, #playerBlocks do
					playerBlocks[i]:SetHidden(true)
				end
			end
		end
	else
		if players ~= nil and playerBlocks ~= nil then
			for i = 1, #playerBlocks do
				playerBlocks[i]:SetHidden(true)
			end
		end
	end
end

function RdKGToolOverview.GroupsUiLoop()
	--d("groups ui loop")
	if RdKGToolOverview.roVars.groups.mode == RdKGToolOverview.constants.groupsModes.MODE_PRIORITY_PERCENT or RdKGToolOverview.roVars.groups.mode == RdKGToolOverview.constants.groupsModes.MODE_PERCENT then
		RdKGToolOverview.AdjustGroupsGroups()
	elseif RdKGToolOverview.roVars.groups.mode == RdKGToolOverview.constants.groupsModes.MODE_PRIORITY_NAME then
		local players = RdKGToolUtilGroup.GetGroupInformation()
		if players ~= nil then
			local entries = RdKGToolOverview.controls.groupsEntries
			for i = 1, #players do
				if players[i].resources ~= nil and players[i].resources.ultimatePercent ~= nil then
					for j = 1, #entries do
						if players[i].charName == entries[j].charName and players[i].charName == entries[j].charName then
							if players[i].resources ~= nil and players[i].resources.ultimatePercent ~= nil then
								entries[j].percent:SetText(string.format("%s %%", players[i].resources.ultimatePercent))
								entries[j].progress:SetValue(players[i].resources.ultimatePercent)
							else
								entries[j].progress:SetValue(0)
							end
							local progressColor = { r = RdKGToolOverview.roVars.groups.progressFull.r, g = RdKGToolOverview.roVars.groups.progressFull.g, b = RdKGToolOverview.roVars.groups.progressFull.b, a = RdKGToolOverview.roVars.groups.progressFull.a}
							if IsUnitDead(players[i].unitTag) == true then
								progressColor.r = RdKGToolOverview.roVars.groups.dead.r
								progressColor.g = RdKGToolOverview.roVars.groups.dead.g
								progressColor.b = RdKGToolOverview.roVars.groups.dead.b
								progressColor.a = RdKGToolOverview.roVars.groups.dead.a
							elseif players[i].distances ~= nil and players[i].distances.fromLeader ~= nil and RdKGToolOverview.roVars.groups.maxDistance < players[i].distances.fromLeader then
								progressColor.r = RdKGToolOverview.roVars.groups.outOfRange.r
								progressColor.g = RdKGToolOverview.roVars.groups.outOfRange.g
								progressColor.b = RdKGToolOverview.roVars.groups.outOfRange.b
								progressColor.a = RdKGToolOverview.roVars.groups.outOfRange.a
							elseif players[i].resources.ultimatePercent ~= 100 then
								progressColor.r = RdKGToolOverview.roVars.groups.progressNotFull.r
								progressColor.g = RdKGToolOverview.roVars.groups.progressNotFull.g
								progressColor.b = RdKGToolOverview.roVars.groups.progressNotFull.b
								progressColor.a = RdKGToolOverview.roVars.groups.progressNotFull.a
							end
							local labelColor = {r = RdKGToolOverview.roVars.groups.labelFull.r, g = RdKGToolOverview.roVars.groups.labelFull.g, b = RdKGToolOverview.roVars.groups.labelFull.b}
							if players[i].resources.ultimatePercent ~= 100 then
								labelColor.r = RdKGToolOverview.roVars.groups.labelNotFull.r
								labelColor.g = RdKGToolOverview.roVars.groups.labelNotFull.g
								labelColor.b = RdKGToolOverview.roVars.groups.labelNotFull.b
							end
							entries[j].progress:SetColor(progressColor.r, progressColor.g, progressColor.b, progressColor.a)
							entries[j].name:SetColor(labelColor.r, labelColor.g, labelColor.b)
							entries[j].percent:SetColor(labelColor.r, labelColor.g, labelColor.b)
							local edgeColor = RdKGToolOverview.roVars.groups.borderOutOfCombat
							if players[i].isInCombat == true then
								edgeColor = RdKGToolOverview.roVars.groups.borderInCombat
							end
							entries[j].edge:SetEdgeColor(edgeColor.r, edgeColor.g, edgeColor.b, 1)
							if RdKGToolOverview.roVars.groups.showSoftResources == true then
								entries[j].magicka:SetValue(players[i].resources.magickaPercent)
								entries[j].stamina:SetValue(players[i].resources.staminaPercent)
							end
							-- Adjust Font if in stealth
							local font = RdKGToolOverview.state.splitFontNormal
							if RdKGToolOverview.roVars.splitInStealthEnabled == true and players[i].isInStealth > 0 then
								font = RdKGToolOverview.state.splitFontStealth
							end
							entries[j].name:SetFont(font)
							entries[j].percent:SetFont(font)
						end
					end
				end
			end
		end
	end
end

function RdKGToolOverview.HandleRawNetworkMessage(message)
	if message ~= nil and message.b0 == RdKGToolNetworking.messageTypes.MESSAGE_ID_BOOM and RdKGToolOverview.roVars.ultimates.enabled == true then
		--d("booom received")
		--d(message)
		if RdKGToolUtilGroup.IsUnitGroupLeader(message.pingTag) or GetGroupSize() == 0 then
			local array = RdKGToolNetworking.DecodeMessageFromBitArray(message.b1, message.b2, message.b3)
			local players = RdKGToolUtilGroup.GetGroupInformation()
			--d(array)
			local sendBoom = false
			if GetGroupSize() == 0 and array[1] == 1 then
				sendBoom = true
			else
				
				if players ~= nil then
					for i = 1, #players do 
						if players[i].displayName == GetUnitDisplayName("player") and
						   players[i].charName == GetUnitName("player") then
							if array[i] == 1 then
								sendBoom = true
								break
							end
						end
					end
				end
			end
			
			if sendBoom == true then
				--d(message)
				RdKGToolOverview.state.useUltimateCommandReceived = true
				RdKGToolOverview.state.useUltimateCommandTimeStamp = GetGameTimeMilliseconds()
				if RdKGToolOverview.roVars.soundEnabled == true then
					--d(RdKGToolOverview.roVars.selectedSound)
					RdKGToolSound.PlaySoundByName(RdKGToolOverview.roVars.selectedSound)
				end
			end
			if RdKGToolOverview.roVars.ultimateOverviewSettings.enabled == true and players ~= nil then
				RdKGToolOverview.state.sentUltimateCommandTimeStamp = GetGameTimeMilliseconds()
				local boom = {}
				boom.destro = 0
				boom.storm = 0
				boom.northernStorm = 0
				boom.permafrost = 0
				boom.negate = 0
				boom.negateOffensive = 0
				boom.negateCounter = 0
				boom.nova = 0
				
				for i = 1, #players do
					if array[i] == 1 then
						local size, ultimateType = RdKGToolOverview.GetUltimateGroupSize(players[i].resources.ultimateId)
						if ultimateType ~= nil then
							boom[ultimateType] = boom[ultimateType] + 1
						end
					end
				end
				
				local ultimateOverviewControl = RdKGToolOverview.controls.ultimateOverviewTLW.rootControl
				ultimateOverviewControl.destructionLabel.currentBoomLabel:SetText(boom.destro)
				ultimateOverviewControl.stormLabel.currentBoomLabel:SetText(boom.storm + boom.northernStorm + boom.permafrost)
				ultimateOverviewControl.negateLabel.currentBoomLabel:SetText(boom.negate + boom.negateOffensive + boom.negateCounter)
				ultimateOverviewControl.novaLabel.currentBoomLabel:SetText(boom.nova)
			end
			
		end
	end
end

function RdKGToolOverview.NetworkLoop()
	if RdKGToolOverview.roVars.pvpOnly == false or (RdKGToolOverview.roVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea()) then
		local message = RdKGToolOverview.state.lastMessage
		local sendMessage = false
		if message == nil or message.sent == true then
			message = {}
			message.sent = false
			sendMessage = true
		end
		
		message.b0, message.b1, message.b2, message.b3 = RdKGToolOverview.GetPlayerResources()
		
		if sendMessage == true then
			RdKGToolNetworking.SendHeartbeatMessage(message, RdKGToolNetworking.constants.priorities.MEDIUM)
		end
		RdKGToolOverview.state.lastMessage = message
	end
end

function RdKGToolOverview.MessageUpdateLoop()
	if RdKGToolOverview.roVars.pvpOnly == false or (RdKGToolOverview.roVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea()) then
		local message = RdKGToolOverview.state.lastMessage
		if message ~= nil and message.sent == false then
			message.b0, message.b1, message.b2, message.b3 = RdKGToolOverview.GetPlayerResources()
		end
	end
end

function RdKGToolOverview.OnBoomKeyBinding()
	if (RdKGToolUtilGroup.IsPlayerGroupLeader() == true or GetGroupSize() == 0) and GetGameTimeMilliseconds() > RdKGToolOverview.state.lastBoom + 1000 and RdKGToolOverview.roVars.ultimates.enabled == true then
		RdKGToolOverview.SendBoom()
		--d("sending boom")
	end
end

--menu interactions
function RdKGToolOverview.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.RO_HEADER_ULTIMATES,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_ENABLED,
					getFunc = RdKGToolOverview.GetRoEnabled,
					setFunc = RdKGToolOverview.SetRoEnabled,
					warning = RdKGToolMenu.constants.RO_SHARED_SETTING
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_POSITION_FIXED,
					getFunc = RdKGToolOverview.GetRoPositionLocked,
					setFunc = RdKGToolOverview.SetRoPositionLocked,
					warning = RdKGToolMenu.constants.RO_SHARED_SETTING
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_PVP_ONLY,
					getFunc = RdKGToolOverview.GetRoPvpOnly,
					setFunc = RdKGToolOverview.SetRoPvpOnly,
					warning = RdKGToolMenu.constants.RO_SHARED_SETTING
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_ULTIMATE_OVERVIEW_ENABLED,
					getFunc = RdKGToolOverview.GetRoUltimateOverviewEnabled,
					setFunc = RdKGToolOverview.SetRoUltimateOverviewEnabled
				},
				[5] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_CLIENT_ULTIMATE_ENABLED,
					getFunc = RdKGToolOverview.GetRoClientUltimateEnabled,
					setFunc = RdKGToolOverview.SetRoClientUltimateEnabled
				},
				[6] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_GROUP_ULTIMATES_ENABLED,
					getFunc = RdKGToolOverview.GetRoGroupUltimatesEnabled,
					setFunc = RdKGToolOverview.SetRoGroupUltimatesEnabled
				},
				[7] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_SHOW_SOFT_RESOURCES,
					getFunc = RdKGToolOverview.GetRoShowSoftResources,
					setFunc = RdKGToolOverview.SetRoShowSoftResources
				},
				[8] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_ULTIMATE_GROUPS_ENABLED,
					getFunc = RdKGToolOverview.GetRoGroupUltimatesGroupsEnabled,
					setFunc = RdKGToolOverview.SetRoGroupUltimatesGroupsEnabled
				},
				[9] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.RO_ULTIMATE_DISPLAY_MODE,
					choices = RdKGToolOverview.GetRoAvailableDisplayModes(),
					getFunc = RdKGToolOverview.GetRoAvailableDisplayMode,
					setFunc = RdKGToolOverview.SetRoAvailableDisplayMode,
					width = "full",
					reference = lReference
				},
				[10] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_SPACING,
					min = 0,
					max = 200,
					step = 1,
					getFunc = RdKGToolOverview.GetRoSpacing,
					setFunc = RdKGToolOverview.SetRoSpacing,
					width = "full",
					decimals = 0,
					default = 0
				},
				[11] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_SIZE,
					min = 1.0,
					max = 2.0,
					step = 0.01,
					getFunc = RdKGToolOverview.GetRoSize,
					setFunc = RdKGToolOverview.SetRoSize,
					width = "full",
					decimals = 2,
					default = 1.0
				},
				[12] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_DISPLAYED_ULTIMATES,
					min = 1,
					max = 12,
					step = 1,
					getFunc = RdKGToolOverview.GetRoDisplayUltimates,
					setFunc = RdKGToolOverview.SetRoDisplayUltimates,
					width = "full",
					default = 6
				},
				[13] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_BACKGROUND,
					getFunc = RdKGToolOverview.GetRoColorBackground,
					setFunc = RdKGToolOverview.SetRoColorBackground,
					width = "full"
				},
				[14] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_MAGICKA,
					getFunc = RdKGToolOverview.GetRoColorMagicka,
					setFunc = RdKGToolOverview.SetRoColorMagicka,
					width = "full"
				},
				[15] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_STAMINA,
					getFunc = RdKGToolOverview.GetRoColorStamina,
					setFunc = RdKGToolOverview.SetRoColorStamina,
					width = "full"
				},
				[16] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_OUT_OF_RANGE,
					getFunc = RdKGToolOverview.GetRoColorOutOfRange,
					setFunc = RdKGToolOverview.SetRoColorOutOfRange,
					width = "full"
				},
				[17] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_DEAD,
					getFunc = RdKGToolOverview.GetRoColorDead,
					setFunc = RdKGToolOverview.SetRoColorDead,
					width = "full"
				},
				[18] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_PROGRESS_NOT_FULL,
					getFunc = RdKGToolOverview.GetRoColorProgressNotFull,
					setFunc = RdKGToolOverview.SetRoColorProgressNotFull,
					width = "full"
				},
				[19] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_PROGRESS_FULL,
					getFunc = RdKGToolOverview.GetRoColorProgressFull,
					setFunc = RdKGToolOverview.SetRoColorProgressFull,
					width = "full"
				},
				[20] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_LABEL_FULL,
					getFunc = RdKGToolOverview.GetRoColorLabelFull,
					setFunc = RdKGToolOverview.SetRoColorLabelFull,
					width = "full"
				},
				[21] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_LABEL_NOT_FULL,
					getFunc = RdKGToolOverview.GetRoColorLabelNotFull,
					setFunc = RdKGToolOverview.SetRoColorLabelNotFull,
					width = "full"
				},
				[22] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_LABEL_GROUP,
					getFunc = RdKGToolOverview.GetRoColorLabelGroup,
					setFunc = RdKGToolOverview.SetRoColorLabelGroup,
					width = "full"
				},
				[23] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_LABEL_ANNOUNCEMENT,
					getFunc = RdKGToolOverview.GetRoColorLabelAnnouncement,
					setFunc = RdKGToolOverview.SetRoColorLabelAnnouncement,
					width = "full"
				},
				[24] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_ANNOUNCEMENT_SIZE,
					min = 32,
					max = 64,
					step = 1,
					getFunc = RdKGToolOverview.GetRoAnnouncementSize,
					setFunc = RdKGToolOverview.SetRoAnnouncementSize,
					width = "full",
					default = 50
				},
				[25] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_IN_COMBAT_ENABLED,
					getFunc = RdKGToolOverview.GetRoInCombatEnabled,
					setFunc = RdKGToolOverview.SetRoInCombatEnabled
				},
				[26] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_IN_COMBAT_COLOR,
					getFunc = RdKGToolOverview.GetRoInCombatColor,
					setFunc = RdKGToolOverview.SetRoInCombatColor,
					width = "full"
				},
				[27] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_OUT_OF_COMBAT_COLOR,
					getFunc = RdKGToolOverview.GetRoOutOfCombatColor,
					setFunc = RdKGToolOverview.SetRoOutOfCombatColor,
					width = "full"
				},
				[28] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_IN_STEALTH_ENABLED,
					getFunc = RdKGToolOverview.GetRoCombinedInStealthEnabled,
					setFunc = RdKGToolOverview.SetRoCombinedInStealthEnabled
				},
				[29] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.RO_ULTIMATE_SORTING_MODE,
					choices = RdKGToolOverview.GetRoAvailableUltimateSortingModes(),
					getFunc = RdKGToolOverview.GetRoSelectedUltimateSortingMode,
					setFunc = RdKGToolOverview.SetRoSelectedUltimateSortingMode,
					width = "full"
				},
				[30] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_DESTRO,
					min = 0,
					max = 24,
					step = 1,
					getFunc = RdKGToolOverview.GetRoUltimateGroupSizeDestro,
					setFunc = RdKGToolOverview.SetRoUltimateGroupSizeDestro,
					width = "full",
					default = 2
				},
				[31] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_STORM,
					min = 0,
					max = 24,
					step = 1,
					getFunc = RdKGToolOverview.GetRoUltimateGroupSizeStorm,
					setFunc = RdKGToolOverview.SetRoUltimateGroupSizeStorm,
					width = "full",
					default = 1
				},
				[32] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NORTHERNSTORM,
					min = 0,
					max = 24,
					step = 1,
					getFunc = RdKGToolOverview.GetRoUltimateGroupSizeNorthernStorm,
					setFunc = RdKGToolOverview.SetRoUltimateGroupSizeNorthernStorm,
					width = "full",
					default = 1
				},
				[33] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_PERMAFROST,
					min = 0,
					max = 24,
					step = 1,
					getFunc = RdKGToolOverview.GetRoUltimateGroupSizePermafrost,
					setFunc = RdKGToolOverview.SetRoUltimateGroupSizePermafrost,
					width = "full",
					default = 1
				},
				[34] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NEGATE,
					min = 0,
					max = 24,
					step = 1,
					getFunc = RdKGToolOverview.GetRoUltimateGroupSizeNegate,
					setFunc = RdKGToolOverview.SetRoUltimateGroupSizeNegate,
					width = "full",
					default = 2
				},
				[35] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NEGATE_OFFENSIVE,
					min = 0,
					max = 24,
					step = 1,
					getFunc = RdKGToolOverview.GetRoUltimateGroupSizeNegateOffensive,
					setFunc = RdKGToolOverview.SetRoUltimateGroupSizeNegateOffensive,
					width = "full",
					default = 2
				},
				[36] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NEGATE_COUNTER,
					min = 0,
					max = 24,
					step = 1,
					getFunc = RdKGToolOverview.GetRoUltimateGroupSizeNegateCounter,
					setFunc = RdKGToolOverview.SetRoUltimateGroupSizeNegateCounter,
					width = "full",
					default = 2
				},
				[37] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_ULTIMATE_GROUP_SIZE_NOVA,
					min = 0,
					max = 24,
					step = 1,
					getFunc = RdKGToolOverview.GetRoUltimateGroupSizeNova,
					setFunc = RdKGToolOverview.SetRoUltimateGroupSizeNova,
					width = "full",
					default = 2
				},
				[38] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_MAX_DISTANCE,
					min = 1,
					max = 50,
					step = 1,
					getFunc = RdKGToolOverview.GetRoMaxDistance,
					setFunc = RdKGToolOverview.SetRoMaxDistance,
					width = "full",
					default = 50
				},
				[39] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_SOUND_ENABLED,
					getFunc = RdKGToolOverview.GetRoSoundEnabled,
					setFunc = RdKGToolOverview.SetRoSoundEnabled
				},
				[40] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.RO_SELECTED_SOUND,
					choices = RdKGToolOverview.GetRoAvailableSounds(),
					getFunc = RdKGToolOverview.GetRoSelectedSound,
					setFunc = RdKGToolOverview.SetRoSelectedSound,
					width = "full"
				},
			},
		},
		[2] = {
			type = "submenu",
			name = RdKGToolMenu.constants.RO_HEADER_GROUPS,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_ENABLED,
					getFunc = RdKGToolOverview.GetRoEnabled,
					setFunc = RdKGToolOverview.SetRoEnabled,
					warning = RdKGToolMenu.constants.RO_SHARED_SETTING
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_POSITION_FIXED,
					getFunc = RdKGToolOverview.GetRoPositionLocked,
					setFunc = RdKGToolOverview.SetRoPositionLocked,
					warning = RdKGToolMenu.constants.RO_SHARED_SETTING
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_PVP_ONLY,
					getFunc = RdKGToolOverview.GetRoPvpOnly,
					setFunc = RdKGToolOverview.SetRoPvpOnly,
					warning = RdKGToolMenu.constants.RO_SHARED_SETTING
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_GROUPS_ENABLED,
					getFunc = RdKGToolOverview.GetRoGroupsEnabled,
					setFunc = RdKGToolOverview.SetRoGroupsEnabled
				},
				[5] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.RO_GROUPS_MODE,
					choices = RdKGToolOverview.GetRoGroupsAvailableModes(),
					getFunc = RdKGToolOverview.GetRoGroupsAvailableMode,
					setFunc = RdKGToolOverview.SetRoGroupsAvailableMode,
					width = "full",
					reference = lReference
				},
				[6] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_SIZE,
					min = 1.0,
					max = 2.0,
					step = 0.01,
					getFunc = RdKGToolOverview.GetRoGroupsSize,
					setFunc = RdKGToolOverview.SetRoGroupsSize,
					width = "full",
					decimals = 2,
					default = 1.0
				},
				[7] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_GROUPS_1_ENABLED,
					getFunc = RdKGToolOverview.GetRoGroups1Enabled,
					setFunc = RdKGToolOverview.SetRoGroups1Enabled
				},
				[8] = {
					type = "editbox",
					name = RdKGToolMenu.constants.RO_GROUPS_1_NAME,
					getFunc = RdKGToolOverview.GetRoGroups1Name,
					setFunc = RdKGToolOverview.SetRoGroups1Name,
					isMultiline = false,
					width = "full",
					default = ""
				},
				[9] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_GROUPS_2_ENABLED,
					getFunc = RdKGToolOverview.GetRoGroups2Enabled,
					setFunc = RdKGToolOverview.SetRoGroups2Enabled
				},
				[10] = {
					type = "editbox",
					name = RdKGToolMenu.constants.RO_GROUPS_2_NAME,
					getFunc = RdKGToolOverview.GetRoGroups2Name,
					setFunc = RdKGToolOverview.SetRoGroups2Name,
					isMultiline = false,
					width = "full",
					default = ""
				},
				[11] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_GROUPS_3_ENABLED,
					getFunc = RdKGToolOverview.GetRoGroups3Enabled,
					setFunc = RdKGToolOverview.SetRoGroups3Enabled
				},
				[12] = {
					type = "editbox",
					name = RdKGToolMenu.constants.RO_GROUPS_3_NAME,
					getFunc = RdKGToolOverview.GetRoGroups3Name,
					setFunc = RdKGToolOverview.SetRoGroups3Name,
					isMultiline = false,
					width = "full",
					default = ""
				},
				[13] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_GROUPS_4_ENABLED,
					getFunc = RdKGToolOverview.GetRoGroups4Enabled,
					setFunc = RdKGToolOverview.SetRoGroups4Enabled
				},
				[14] = {
					type = "editbox",
					name = RdKGToolMenu.constants.RO_GROUPS_4_NAME,
					getFunc = RdKGToolOverview.GetRoGroups4Name,
					setFunc = RdKGToolOverview.SetRoGroups4Name,
					isMultiline = false,
					width = "full",
					default = ""
				},
				[15] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_GROUPS_5_ENABLED,
					getFunc = RdKGToolOverview.GetRoGroups5Enabled,
					setFunc = RdKGToolOverview.SetRoGroups5Enabled
				},
				[16] = {
					type = "editbox",
					name = RdKGToolMenu.constants.RO_GROUPS_5_NAME,
					getFunc = RdKGToolOverview.GetRoGroups5Name,
					setFunc = RdKGToolOverview.SetRoGroups5Name,
					isMultiline = false,
					width = "full",
					default = ""
				},
				[17] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_SHOW_SOFT_RESOURCES,
					getFunc = RdKGToolOverview.GetRoGroupsShowSoftResources,
					setFunc = RdKGToolOverview.SetRoGroupsShowSoftResources
				},
				[18] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.RO_IN_STEALTH_ENABLED,
					getFunc = RdKGToolOverview.GetRoSplitInStealthEnabled,
					setFunc = RdKGToolOverview.SetRoSplitInStealthEnabled
				},
				[19] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_BACKGROUND,
					getFunc = RdKGToolOverview.GetRoGroupsColorBackground,
					setFunc = RdKGToolOverview.SetRoGroupsColorBackground,
					width = "full"
				},
				[20] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_MAGICKA,
					getFunc = RdKGToolOverview.GetRoGroupsColorMagicka,
					setFunc = RdKGToolOverview.SetRoGroupsColorMagicka,
					width = "full"
				},
				[21] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_STAMINA,
					getFunc = RdKGToolOverview.GetRoGroupsColorStamina,
					setFunc = RdKGToolOverview.SetRoGroupsColorStamina,
					width = "full"
				},
				[22] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_OUT_OF_RANGE,
					getFunc = RdKGToolOverview.GetRoGroupsColorOutOfRange,
					setFunc = RdKGToolOverview.SetRoGroupsColorOutOfRange,
					width = "full"
				},
				[23] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_DEAD,
					getFunc = RdKGToolOverview.GetRoGroupsColorDead,
					setFunc = RdKGToolOverview.SetRoGroupsColorDead,
					width = "full"
				},
				[24] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_PROGRESS_NOT_FULL,
					getFunc = RdKGToolOverview.GetRoGroupsColorProgressNotFull,
					setFunc = RdKGToolOverview.SetRoGroupsColorProgressNotFull,
					width = "full"
				},
				[25] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_PROGRESS_FULL,
					getFunc = RdKGToolOverview.GetRoGroupsColorProgressFull,
					setFunc = RdKGToolOverview.SetRoGroupsColorProgressFull,
					width = "full"
				},
				[26] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_LABEL_FULL,
					getFunc = RdKGToolOverview.GetRoGroupsColorLabelFull,
					setFunc = RdKGToolOverview.SetRoGroupsColorLabelFull,
					width = "full"
				},
				[27] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_LABEL_NOT_FULL,
					getFunc = RdKGToolOverview.GetRoGroupsColorLabelNotFull,
					setFunc = RdKGToolOverview.SetRoGroupsColorLabelNotFull,
					width = "full"
				},
				[28] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_GROUPS_EDGE_OUT_OF_COMBAT,
					getFunc = RdKGToolOverview.GetRoGroupsColorEdgeOutOfCombat,
					setFunc = RdKGToolOverview.SetRoGroupsColorEdgeOutOfCombat,
					width = "full"
				},
				[29] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.RO_COLOR_GROUPS_EDGE_IN_COMBAT,
					getFunc = RdKGToolOverview.GetRoGroupsColorEdgeInCombat,
					setFunc = RdKGToolOverview.SetRoGroupsColorEdgeInCombat,
					width = "full"
				},
				[30] = {
					type = "slider",
					name = RdKGToolMenu.constants.RO_MAX_DISTANCE,
					min = 1,
					max = 50,
					step = 1,
					getFunc = RdKGToolOverview.GetRoGroupsMaxDistance,
					setFunc = RdKGToolOverview.SetRoGroupsMaxDistance,
					width = "full",
					default = 25
				},
				[31] = {
					type = "divider",
					width = "full"
				},
			}
		}
	}
	
	for i = 1, #RdKGToolUltimates.ultimates do
		local lReference = RdKGToolOverview.constants.references.GROUPS_DROPDOWN .. i
		menu[2].controls[#menu[2].controls + 1] = {
			type = "dropdown",
			name = RdKGToolUltimates.ultimates[i].name .. RdKGToolMenu.constants.RO_GROUPS_GROUP,
			choices = RdKGToolOverview.GetRoAvailableGroupsGroups(),
			getFunc = function() return RdKGToolOverview.GetRoSelectedGroupsGroup(i) end,
			setFunc = function(value) RdKGToolOverview.SetRoSelectedGroupsGroup(i, value) end,
			width = "full",
			reference = lReference
		}
		menu[2].controls[#menu[2].controls + 1] = {
			type = "slider",
			name = RdKGToolUltimates.ultimates[i].name .. RdKGToolMenu.constants.RO_GROUPS_PRIORITY,
			min = 1,
			max = 30,
			step = 1,
			getFunc = function() return RdKGToolOverview.GetRoGroupsGroupPriority(i) end,
			setFunc = function(value) RdKGToolOverview.SetRoGroupsGroupPriority(i, value) end,
			width = "full",
			default = 30
		}
		table.insert(RdKGToolOverview.state.references, lReference)
	end
	
	return menu
end


function RdKGToolOverview.GetRoEnabled()
	return RdKGToolOverview.roVars.enabled
end

function RdKGToolOverview.SetRoEnabled(value)
	RdKGToolOverview.SetEnabled(value)
end

function RdKGToolOverview.GetRoPositionLocked()
	return RdKGToolOverview.roVars.positionLocked
end

function RdKGToolOverview.SetRoPositionLocked(value)
	RdKGToolOverview.SetPositionLocked(value)
end

function RdKGToolOverview.GetRoPvpOnly()
	return RdKGToolOverview.roVars.pvpOnly
end

function RdKGToolOverview.SetRoPvpOnly(value)
	RdKGToolOverview.roVars.pvpOnly = value
	RdKGToolOverview.SetEnabled(RdKGToolOverview.roVars.enabled)
end

function RdKGToolOverview.GetRoUltimateOverviewEnabled()
	return RdKGToolOverview.roVars.ultimateOverviewSettings.enabled
end

function RdKGToolOverview.SetRoUltimateOverviewEnabled(value)
	RdKGToolOverview.roVars.ultimateOverviewSettings.enabled = value
	RdKGToolOverview.SetEnabled(RdKGToolOverview.roVars.enabled)
end

function RdKGToolOverview.GetRoClientUltimateEnabled()
	return RdKGToolOverview.roVars.clientUltimateSettings.enabled
end

function RdKGToolOverview.SetRoClientUltimateEnabled(value)
	RdKGToolOverview.roVars.clientUltimateSettings.enabled = value
	RdKGToolOverview.SetEnabled(RdKGToolOverview.roVars.enabled)
end

function RdKGToolOverview.GetRoGroupUltimatesEnabled()
	return RdKGToolOverview.roVars.groupUltimatesSettings.enabled
end

function RdKGToolOverview.SetRoGroupUltimatesEnabled(value)
	RdKGToolOverview.roVars.groupUltimatesSettings.enabled = value
	RdKGToolOverview.SetEnabled(RdKGToolOverview.roVars.enabled)
end

function RdKGToolOverview.GetRoShowSoftResources()
	return RdKGToolOverview.roVars.showSoftResources
end

function RdKGToolOverview.SetRoShowSoftResources(value)
	RdKGToolOverview.roVars.showSoftResources = value
	--RdKGToolOverview.AdjustStaminaMagickaBarVisibility()
	RdKGToolOverview.AdjustSize()
end

function RdKGToolOverview.GetRoGroupUltimatesGroupsEnabled()
	return RdKGToolOverview.roVars.ultimates.enabled
end

function RdKGToolOverview.SetRoGroupUltimatesGroupsEnabled(value)
	RdKGToolOverview.roVars.ultimates.enabled = value
	RdKGToolOverview.SetEnabled(RdKGToolOverview.roVars.enabled)
end

function RdKGToolOverview.GetRoAvailableDisplayModes()
	return RdKGToolOverview.config.displayModes
end

function RdKGToolOverview.GetRoAvailableDisplayMode()
	return RdKGToolOverview.config.displayModes[RdKGToolOverview.roVars.displayMode]
end

function RdKGToolOverview.SetRoAvailableDisplayMode(value)
	if value ~= nil then
		for i = 1, #RdKGToolOverview.config.displayModes do
			if RdKGToolOverview.config.displayModes[i] == value then
				RdKGToolOverview.roVars.displayMode = i
			end
		end
		RdKGToolOverview.AdjustDisplayMode()
	end
end

function RdKGToolOverview.GetRoDisplayUltimates()
	return RdKGToolOverview.roVars.groupUltimatesSettings.displayedUltimates
end

function RdKGToolOverview.SetRoDisplayUltimates(value)
	RdKGToolOverview.SetDisplayedUltimates(value)
end

function RdKGToolOverview.GetRoColorBackground()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.playerBlockColors.defaultBackground)
end

function RdKGToolOverview.SetRoColorBackground(r, g, b)
	RdKGToolOverview.roVars.playerBlockColors.defaultBackground = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoColorMagicka()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.playerBlockColors.magicka)
end

function RdKGToolOverview.SetRoColorMagicka(r, g, b)
	RdKGToolOverview.roVars.playerBlockColors.magicka = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolOverview.AdjustColors()
end
	
function RdKGToolOverview.GetRoColorStamina()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.playerBlockColors.stamina)
end

function RdKGToolOverview.SetRoColorStamina(r, g, b)
	RdKGToolOverview.roVars.playerBlockColors.stamina = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolOverview.AdjustColors()
end

function RdKGToolOverview.GetRoColorOutOfRange()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.playerBlockColors.outOfRange)
end

function RdKGToolOverview.SetRoColorOutOfRange(r, g, b)
	RdKGToolOverview.roVars.playerBlockColors.outOfRange = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoColorDead()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.playerBlockColors.dead)
end

function RdKGToolOverview.SetRoColorDead(r, g, b)
	RdKGToolOverview.roVars.playerBlockColors.dead = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoColorProgressNotFull()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.playerBlockColors.progressNotFull)
end

function RdKGToolOverview.SetRoColorProgressNotFull(r, g, b)
	RdKGToolOverview.roVars.playerBlockColors.progressNotFull = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoColorProgressFull()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.playerBlockColors.progressFull)
end

function RdKGToolOverview.SetRoColorProgressFull(r, g, b)
	RdKGToolOverview.roVars.playerBlockColors.progressFull = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoColorLabelFull()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.playerBlockColors.labelFull)
end

function RdKGToolOverview.SetRoColorLabelFull(r, g, b)
	RdKGToolOverview.roVars.playerBlockColors.labelFull = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoColorLabelNotFull()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.playerBlockColors.labelNotFull)
end

function RdKGToolOverview.SetRoColorLabelNotFull(r, g, b)
	RdKGToolOverview.roVars.playerBlockColors.labelNotFull = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoColorLabelGroup()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.playerBlockColors.labelGroup)
end

function RdKGToolOverview.SetRoColorLabelGroup(r, g, b)
	RdKGToolOverview.roVars.playerBlockColors.labelGroup = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoColorLabelAnnouncement()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.assignmentColor)
end

function RdKGToolOverview.SetRoColorLabelAnnouncement(r, g, b)
	RdKGToolOverview.roVars.assignmentColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolOverview.controls.groupAssignmentTLW.rootControl.label:SetColor(r, g, b, 1)
end

function RdKGToolOverview.GetRoAnnouncementSize()
	return RdKGToolOverview.roVars.assignmentSize
end

function RdKGToolOverview.SetRoAnnouncementSize(value)
	RdKGToolOverview.roVars.assignmentSize = value
	RdKGToolOverview.AdjustAssignmentControlSize()
end

function RdKGToolOverview.GetRoInCombatEnabled()
	return RdKGToolOverview.roVars.playerBlockColors.inCombatEnabled
end

function RdKGToolOverview.SetRoInCombatEnabled(value)
	RdKGToolOverview.roVars.playerBlockColors.inCombatEnabled = value
	RdKGToolOverview.AdjustInCombatSettings()
end

function RdKGToolOverview.GetRoInCombatColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.playerBlockColors.borderInCombat)
end

function RdKGToolOverview.SetRoInCombatColor(r, g, b)
	RdKGToolOverview.roVars.playerBlockColors.borderInCombat = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoOutOfCombatColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.playerBlockColors.borderOutOfCombat)
end

function RdKGToolOverview.SetRoOutOfCombatColor(r, g, b)
	RdKGToolOverview.roVars.playerBlockColors.borderOutOfCombat = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoCombinedInStealthEnabled()
	return RdKGToolOverview.roVars.combinedInStealthEnabled
end

function RdKGToolOverview.SetRoCombinedInStealthEnabled(value)
	RdKGToolOverview.roVars.combinedInStealthEnabled = value
end

function RdKGToolOverview.GetRoAvailableUltimateSortingModes()
	return RdKGToolOverview.config.ultimateModes
end

function RdKGToolOverview.GetRoSelectedUltimateSortingMode()
	return RdKGToolOverview.config.ultimateModes[RdKGToolOverview.roVars.ultimates.sortingMode]
end

function RdKGToolOverview.SetRoSelectedUltimateSortingMode(value)
	if value ~= nil then
		for i = 1, #RdKGToolOverview.config.ultimateModes do
			if RdKGToolOverview.config.ultimateModes[i] == value then
				RdKGToolOverview.roVars.ultimates.sortingMode = i
			end
		end
	end
end

function RdKGToolOverview.GetRoUltimateGroupSizeDestro()
	return RdKGToolOverview.roVars.ultimates.groupSizeDestro
end

function RdKGToolOverview.SetRoUltimateGroupSizeDestro(value)
	RdKGToolOverview.roVars.ultimates.groupSizeDestro = value
end

function RdKGToolOverview.GetRoUltimateGroupSizeStorm()
	return RdKGToolOverview.roVars.ultimates.groupSizeStorm
end

function RdKGToolOverview.SetRoUltimateGroupSizeStorm(value)
	RdKGToolOverview.roVars.ultimates.groupSizeStorm = value
end

function RdKGToolOverview.GetRoUltimateGroupSizeNorthernStorm()
	return RdKGToolOverview.roVars.ultimates.groupSizeNorthernStorm
end

function RdKGToolOverview.SetRoUltimateGroupSizeNorthernStorm(value)
	RdKGToolOverview.roVars.ultimates.groupSizeNorthernStorm = value
end

function RdKGToolOverview.GetRoUltimateGroupSizePermafrost()
	return RdKGToolOverview.roVars.ultimates.groupSizePermafrost
end

function RdKGToolOverview.SetRoUltimateGroupSizePermafrost(value)
	RdKGToolOverview.roVars.ultimates.groupSizePermafrost = value
end

function RdKGToolOverview.GetRoUltimateGroupSizeNegate()
	return RdKGToolOverview.roVars.ultimates.groupSizeNegate
end

function RdKGToolOverview.SetRoUltimateGroupSizeNegate(value)
	RdKGToolOverview.roVars.ultimates.groupSizeNegate = value
end

function RdKGToolOverview.GetRoUltimateGroupSizeNegateOffensive()
	return RdKGToolOverview.roVars.ultimates.groupSizeNegateOffensive
end

function RdKGToolOverview.SetRoUltimateGroupSizeNegateOffensive(value)
	RdKGToolOverview.roVars.ultimates.groupSizeNegateOffensive = value
end

function RdKGToolOverview.GetRoUltimateGroupSizeNegateCounter()
	return RdKGToolOverview.roVars.ultimates.groupSizeNegateCounter
end

function RdKGToolOverview.SetRoUltimateGroupSizeNegateCounter(value)
	RdKGToolOverview.roVars.ultimates.groupSizeNegateCounter = value
end

function RdKGToolOverview.GetRoUltimateGroupSizeNova()
	return RdKGToolOverview.roVars.ultimates.groupSizeNova
end

function RdKGToolOverview.SetRoUltimateGroupSizeNova(value)
	RdKGToolOverview.roVars.ultimates.groupSizeNova = value
end

function RdKGToolOverview.GetRoMaxDistance()
	return RdKGToolOverview.roVars.ultimates.maxDistance
end

function RdKGToolOverview.SetRoMaxDistance(value)
	RdKGToolOverview.roVars.ultimates.maxDistance = value
end

function RdKGToolOverview.GetRoSoundEnabled()
	return RdKGToolOverview.roVars.soundEnabled
end

function RdKGToolOverview.SetRoSoundEnabled(value)
	RdKGToolOverview.roVars.soundEnabled = value
end

function RdKGToolOverview.GetRoAvailableSounds()
	local sounds = {}
	for i = 1, #RdKGToolOverview.state.sounds do
		sounds[i] = RdKGToolOverview.state.sounds[i].name
	end
	return sounds
end

function RdKGToolOverview.GetRoSelectedSound()
	return RdKGToolOverview.roVars.selectedSound
end

function RdKGToolOverview.SetRoSelectedSound(value)
	if value ~= nil then
		RdKGToolOverview.roVars.selectedSound = value
		RdKGToolSound.PlaySoundByName(value)
	end
end

function RdKGToolOverview.GetRoGroupsEnabled()
	return RdKGToolOverview.roVars.groups.enabled
end

function RdKGToolOverview.SetRoGroupsEnabled(value)
	RdKGToolOverview.SetGroupsEnabled(value)
end

function RdKGToolOverview.GetRoGroups1Enabled()
	return RdKGToolOverview.roVars.groups.group1.enabled
end

function RdKGToolOverview.SetRoGroups1Enabled(value)
	RdKGToolOverview.roVars.groups.group1.enabled = value
	RdKGToolOverview.SetGroupsEnabled(RdKGToolOverview.roVars.groups.enabled)
end

function RdKGToolOverview.GetRoGroups1Name()
	return RdKGToolOverview.roVars.groups.group1.name
end

function RdKGToolOverview.SetRoGroups1Name(value)
	RdKGToolOverview.roVars.groups.group1.name = value
	RdKGToolOverview.AdjustGroupNames()
end

function RdKGToolOverview.GetRoGroups2Enabled()
	return RdKGToolOverview.roVars.groups.group2.enabled
end

function RdKGToolOverview.SetRoGroups2Enabled(value)
	RdKGToolOverview.roVars.groups.group2.enabled = value
	RdKGToolOverview.SetGroupsEnabled(RdKGToolOverview.roVars.groups.enabled)
end

function RdKGToolOverview.GetRoGroups2Name()
	return RdKGToolOverview.roVars.groups.group2.name
end

function RdKGToolOverview.SetRoGroups2Name(value)
	RdKGToolOverview.roVars.groups.group2.name = value
	RdKGToolOverview.AdjustGroupNames()
end

function RdKGToolOverview.GetRoGroups3Enabled()
	return RdKGToolOverview.roVars.groups.group3.enabled
end

function RdKGToolOverview.SetRoGroups3Enabled(value)
	RdKGToolOverview.roVars.groups.group3.enabled = value
	RdKGToolOverview.SetGroupsEnabled(RdKGToolOverview.roVars.groups.enabled)
end

function RdKGToolOverview.GetRoGroups3Name()
	return RdKGToolOverview.roVars.groups.group3.name
end

function RdKGToolOverview.SetRoGroups3Name(value)
	RdKGToolOverview.roVars.groups.group3.name = value
	RdKGToolOverview.AdjustGroupNames()
end

function RdKGToolOverview.GetRoGroups4Enabled()
	return RdKGToolOverview.roVars.groups.group4.enabled
end

function RdKGToolOverview.SetRoGroups4Enabled(value)
	RdKGToolOverview.roVars.groups.group4.enabled = value
	RdKGToolOverview.SetGroupsEnabled(RdKGToolOverview.roVars.groups.enabled)
end

function RdKGToolOverview.GetRoGroups4Name()
	return RdKGToolOverview.roVars.groups.group4.name
end

function RdKGToolOverview.SetRoGroups4Name(value)
	RdKGToolOverview.roVars.groups.group4.name = value
	RdKGToolOverview.AdjustGroupNames()
end

function RdKGToolOverview.GetRoGroups5Enabled()
	return RdKGToolOverview.roVars.groups.group5.enabled
end

function RdKGToolOverview.SetRoGroups5Enabled(value)
	RdKGToolOverview.roVars.groups.group5.enabled = value
	RdKGToolOverview.SetGroupsEnabled(RdKGToolOverview.roVars.groups.enabled)
end

function RdKGToolOverview.GetRoGroups5Name()
	return RdKGToolOverview.roVars.groups.group5.name
end

function RdKGToolOverview.SetRoGroups5Name(value)
	RdKGToolOverview.roVars.groups.group5.name = value
	RdKGToolOverview.AdjustGroupNames()
end

function RdKGToolOverview.GetRoAvailableGroupsGroups()
	local groups = {}
	table.insert(groups, "-")
	table.insert(groups, RdKGToolOverview.roVars.groups.group1.name)
	table.insert(groups, RdKGToolOverview.roVars.groups.group2.name)
	table.insert(groups, RdKGToolOverview.roVars.groups.group3.name)
	table.insert(groups, RdKGToolOverview.roVars.groups.group4.name)
	table.insert(groups, RdKGToolOverview.roVars.groups.group5.name)
	return groups
end

function RdKGToolOverview.GetRoSelectedGroupsGroup(index)
	return RdKGToolOverview.GetGroupNameFromIndex(RdKGToolOverview.roVars.groups.ultimateGroups[index].group)
end

function RdKGToolOverview.SetRoSelectedGroupsGroup(index, value)
	if value ~= nil then
		value = RdKGToolOverview.GetGroupIndexFromName(value)
		RdKGToolOverview.roVars.groups.ultimateGroups[index].group = value
		RdKGToolOverview.AdjustGroupsGroups()
	end
end

function RdKGToolOverview.GetRoGroupsGroupPriority(index)
	return RdKGToolOverview.roVars.groups.ultimateGroups[index].priority
end

function RdKGToolOverview.SetRoGroupsGroupPriority(index, value)
	RdKGToolOverview.roVars.groups.ultimateGroups[index].priority = value
	RdKGToolOverview.AdjustGroupsGroups()
end


function RdKGToolOverview.GetRoGroupsAvailableModes()
	return RdKGToolOverview.config.groupsModes
end

function RdKGToolOverview.GetRoGroupsAvailableMode()
	return RdKGToolOverview.config.groupsModes[RdKGToolOverview.roVars.groups.mode]
end

function RdKGToolOverview.SetRoGroupsAvailableMode(value)
	if value ~= nil then
		for i = 1, #RdKGToolOverview.config.groupsModes do
			if value == RdKGToolOverview.config.groupsModes[i] then
				RdKGToolOverview.roVars.groups.mode = i
				break
			end
		end
		RdKGToolOverview.AdjustGroupsGroups()
	end
end

function RdKGToolOverview.GetRoGroupsShowSoftResources()
	return RdKGToolOverview.roVars.groups.showSoftResources
end

function RdKGToolOverview.SetRoGroupsShowSoftResources(value)
	RdKGToolOverview.roVars.groups.showSoftResources = value
	RdKGToolOverview.AdjustSize()
end

function RdKGToolOverview.GetRoSplitInStealthEnabled()
	return RdKGToolOverview.roVars.splitInStealthEnabled
end

function RdKGToolOverview.SetRoSplitInStealthEnabled(value)
	RdKGToolOverview.roVars.splitInStealthEnabled = value
end

function RdKGToolOverview.GetRoGroupsColorBackground()
	return RdKGToolMenu.GetRGBAColor(RdKGToolOverview.roVars.groups.backdropColor)
end

function RdKGToolOverview.SetRoGroupsColorBackground(r, g, b, a)
	RdKGToolOverview.roVars.groups.backdropColor = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	RdKGToolOverview.AdjustGroupsColor()
end

function RdKGToolOverview.GetRoGroupsColorMagicka()
	return RdKGToolMenu.GetRGBAColor(RdKGToolOverview.roVars.groups.magicka)
end

function RdKGToolOverview.SetRoGroupsColorMagicka(r, g ,b, a)
	RdKGToolOverview.roVars.groups.magicka = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	RdKGToolOverview.AdjustGroupsColor()
end

function RdKGToolOverview.GetRoGroupsColorStamina()
	return RdKGToolMenu.GetRGBAColor(RdKGToolOverview.roVars.groups.stamina)
end

function RdKGToolOverview.SetRoGroupsColorStamina(r, g ,b, a)
	RdKGToolOverview.roVars.groups.stamina = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	RdKGToolOverview.AdjustGroupsColor()
end

function RdKGToolOverview.GetRoGroupsColorOutOfRange()
	return RdKGToolMenu.GetRGBAColor(RdKGToolOverview.roVars.groups.outOfRange)
end

function RdKGToolOverview.SetRoGroupsColorOutOfRange(r, g ,b, a)
	RdKGToolOverview.roVars.groups.outOfRange = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
end

function RdKGToolOverview.GetRoGroupsColorDead()
	return RdKGToolMenu.GetRGBAColor(RdKGToolOverview.roVars.groups.dead)
end

function RdKGToolOverview.SetRoGroupsColorDead(r, g ,b, a)
	RdKGToolOverview.roVars.groups.dead = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
end

function RdKGToolOverview.GetRoGroupsColorProgressNotFull()
	return RdKGToolMenu.GetRGBAColor(RdKGToolOverview.roVars.groups.progressNotFull)
end

function RdKGToolOverview.SetRoGroupsColorProgressNotFull(r, g ,b, a)
	RdKGToolOverview.roVars.groups.progressNotFull = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
end

function RdKGToolOverview.GetRoGroupsColorProgressFull()
	return RdKGToolMenu.GetRGBAColor(RdKGToolOverview.roVars.groups.progressFull)
end

function RdKGToolOverview.SetRoGroupsColorProgressFull(r, g ,b, a)
	RdKGToolOverview.roVars.groups.progressFull = RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
end

function RdKGToolOverview.GetRoGroupsColorLabelFull()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.groups.labelFull)
end

function RdKGToolOverview.SetRoGroupsColorLabelFull(r, g ,b)
	RdKGToolOverview.roVars.groups.labelFull = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoGroupsColorLabelNotFull()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.groups.labelNotFull)
end

function RdKGToolOverview.SetRoGroupsColorLabelNotFull(r, g ,b)
	RdKGToolOverview.roVars.groups.labelNotFull = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoGroupsColorEdgeOutOfCombat()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.groups.borderOutOfCombat)
end

function RdKGToolOverview.SetRoGroupsColorEdgeOutOfCombat(r, g ,b)
	RdKGToolOverview.roVars.groups.borderOutOfCombat = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoGroupsColorEdgeInCombat()
	return RdKGToolMenu.GetRGBColor(RdKGToolOverview.roVars.groups.borderInCombat)
end

function RdKGToolOverview.SetRoGroupsColorEdgeInCombat(r, g ,b)
	RdKGToolOverview.roVars.groups.borderInCombat = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolOverview.GetRoGroupsMaxDistance()
	return RdKGToolOverview.roVars.groups.maxDistance
end

function RdKGToolOverview.SetRoGroupsMaxDistance(value)
	RdKGToolOverview.roVars.groups.maxDistance = value
end

function RdKGToolOverview.GetRoSize()
	return RdKGToolOverview.roVars.size
end

function RdKGToolOverview.SetRoSize(value)
	RdKGToolOverview.roVars.size = value
	RdKGToolOverview.AdjustSize()
end

function RdKGToolOverview.GetRoGroupsSize()
	return RdKGToolOverview.roVars.groups.size
end

function RdKGToolOverview.SetRoGroupsSize(value)
	RdKGToolOverview.roVars.groups.size = value
	RdKGToolOverview.AdjustSize()
end

function RdKGToolOverview.GetRoSpacing()
	return RdKGToolOverview.roVars.spacing
end

function RdKGToolOverview.SetRoSpacing(value)
	RdKGToolOverview.roVars.spacing = value
	RdKGToolOverview.AdjustSize()
end