-- RdK Group Tool Cyrodiil Status
-- By @s0rdrak (PC / EU)

RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolTB = RdKGTool.toolbox
RdKGToolTB.cs = RdKGToolTB.cs or {}
local RdKGToolCS = RdKGToolTB.cs
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem
RdKGToolUtil.fonts = RdKGToolUtil.fonts or {}
local RdKGToolFonts = RdKGToolUtil.fonts
RdKGToolUtil.allianceColor = RdKGToolUtil.allianceColor or {}
local RdKGToolAC = RdKGToolUtil.allianceColor
RdKGToolUtil.cyrodiil = RdKGToolUtil.cyrodiil or {}
local RdKGToolCyro = RdKGToolUtil.cyrodiil


RdKGToolCS.callbackName = RdKGTool.addonName .. "CyrodiilStatus"

RdKGToolCS.config = {}
RdKGToolCS.config.isClampedToScreen = true
RdKGToolCS.config.imageWidth = 30
RdKGToolCS.config.nameWidth = 150
RdKGToolCS.config.flagWidth = 40
RdKGToolCS.config.flagHeight = 8
RdKGToolCS.config.flagFlipWidth = 20
RdKGToolCS.config.underAttackForWidth = 50
RdKGToolCS.config.width = 375
RdKGToolCS.config.siegeWidth = 20
RdKGToolCS.config.entryHeight = 30
RdKGToolCS.config.height = RdKGToolCS.config.entryHeight * 10
RdKGToolCS.config.backdropAlphaOdd = 0.25
RdKGToolCS.config.backdropAlphaEven = 0.15
RdKGToolCS.config.flagBackdropColor = {}
RdKGToolCS.config.flagBackdropColor.r = 0.1
RdKGToolCS.config.flagBackdropColor.g = 0.1
RdKGToolCS.config.flagBackdropColor.b = 0.1

RdKGToolCS.constants = RdKGToolCS.constants or {}
RdKGToolCS.constants.PREFIX = "CS"
RdKGToolCS.constants.TLW = "RdKGTool.toolbox.cs.tlw"
RdKGToolCS.constants.textures = {}
RdKGToolCS.constants.textures.TEXTURE_KEEP = "/esoui/art/mappins/ava_largekeep_neutral.dds"
RdKGToolCS.constants.textures.TEXTURE_OUTPOST = "/esoui/art/mappins/ava_outpost_neutral.dds"
RdKGToolCS.constants.textures.TEXTURE_VILLAGE = "/esoui/art/mappins/ava_town_neutral.dds"
RdKGToolCS.constants.textures.TEXTURE_TEMPLE = "/esoui/art/icons/mapkey/mapkey_temple.dds"
RdKGToolCS.constants.textures.TEXTURE_DESTRUCTIBLE_BRDIGE = ""
RdKGToolCS.constants.textures.TEXTURE_DESTRUCTIBLE_GATE = ""
RdKGToolCS.constants.textures.TEXTURE_RESOURCE_MINE = "/esoui/art/compass/ava_mine_neutral.dds"
RdKGToolCS.constants.textures.TEXTURE_RESOURCE_FARM = "/esoui/art/compass/ava_farm_neutral.dds"
RdKGToolCS.constants.textures.TEXTURE_RESOURCE_LUMBER = "/esoui/art/compass/ava_lumbermill_neutral.dds"
RdKGToolCS.constants.textures.TEXTURE_BRIDGE_PASSABLE = "/esoui/art/mappins/ava_bridge_passable.dds"
RdKGToolCS.constants.textures.TEXTURE_BRIDGE_NOT_PASSABLE = "/esoui/art/mappins/ava_bridge_not_passable.dds"
RdKGToolCS.constants.textures.TEXTURE_MILEGATE_PASSABLE = "/esoui/art/mappins/ava_milegate_passable.dds"
RdKGToolCS.constants.textures.TEXTURE_MILEGATE_NOT_PASSABLE = "/esoui/art/mappins/ava_milegate_not_passable.dds"

RdKGToolCS.state = {}
RdKGToolCS.state.initialized = false
RdKGToolCS.state.foreground = true
RdKGToolCS.state.registredConsumers = false
RdKGToolCS.state.registredCyrodiilConsumers = false
RdKGToolCS.state.activeLayerIndex = 1
RdKGToolCS.state.visibleControls = {}

RdKGToolCS.controls = {}

local wm = WINDOW_MANAGER

function RdKGToolCS.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolCS.callbackName, RdKGToolCS.OnProfileChanged)
	
	RdKGToolCS.CreateUI()
	
	RdKGToolMenu.AddPositionFixedConsumer(RdKGToolCS.SetCsPositionLocked)
	
	RdKGToolCS.AdjustDisplayedComponents()
	RdKGToolCS.state.initialized = true
	RdKGToolCS.SetEnabled(RdKGToolCS.csVars.enabled)
	RdKGToolCS.SetPositionLocked(RdKGToolCS.csVars.positionLocked)
	--RdKGToolCS.SetControlVisibility()
end

function RdKGToolCS.SetTlwLocation()
	RdKGToolCS.controls.TLW:ClearAnchors()
	if RdKGToolCS.csVars.location == nil then
		RdKGToolCS.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, 250, -250)
	else
		RdKGToolCS.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RdKGToolCS.csVars.location.x, RdKGToolCS.csVars.location.y)
	end
end

function RdKGToolCS.CreateUI()
	RdKGToolCS.controls.TLW = wm:CreateTopLevelWindow(RdKGToolCS.constants.TLW)
	
	RdKGToolCS.SetTlwLocation()
	
		
	RdKGToolCS.controls.TLW:SetClampedToScreen(RdKGToolCS.config.isClampedToScreen)
	RdKGToolCS.controls.TLW:SetHandler("OnMoveStop", RdKGToolCS.SaveWindowLocation)
	RdKGToolCS.controls.TLW:SetDimensions(RdKGToolCS.config.width, RdKGToolCS.config.height)
	
	RdKGToolCS.controls.TLW.rootControl = wm:CreateControl(nil, RdKGToolCS.controls.TLW, CT_CONTROL)
	
	local rootControl = RdKGToolCS.controls.TLW.rootControl
	
	rootControl:SetDimensions(RdKGToolCS.config.width, RdKGToolCS.config.height)
	rootControl:SetAnchor(TOPLEFT, RdKGToolCS.controls.TLW, TOPLEFT, 0, 0)
	
	rootControl.movableBackdrop = wm:CreateControl(nil, rootControl, CT_BACKDROP)
	
	rootControl.movableBackdrop:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	rootControl.movableBackdrop:SetDimensions(RdKGToolCS.config.width, RdKGToolCS.config.height)
	
	rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
	rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	
	RdKGToolCS.state.visibleControls = RdKGToolCS.CreateDefaultList(rootControl)
	for i = 1, #RdKGToolCS.state.visibleControls do
		RdKGToolCS.state.visibleControls[i]:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, RdKGToolCS.config.entryHeight * (i - 1))
	end
end

function RdKGToolCS.CreateDefaultList(parent)
	local entries = {}
	for i = 1, 10 do
		local entry = RdKGToolCS.CreateEntryControl(parent)
		
		table.insert(entries, entry)
	end
	return entries
end

function RdKGToolCS.CreateEntryControl(parent)
	local controlFont = RdKGToolFonts.CreateFontString(RdKGToolFonts.constants.CHAT_FONT, RdKGToolFonts.constants.INPUT_KB, RdKGToolCS.config.entryHeight - 12, RdKGToolFonts.constants.WEIGHT_SOFT_SHADOW_THICK)
	--d(controlFont)
	local control = wm:CreateControl(nil, parent, CT_CONTROL)
	control:SetDimensions(RdKGToolCS.config.width, RdKGToolCS.config.entryHeight)
	control:SetHidden(true)
	
	control.backdrop = wm:CreateControl(nil, control, CT_BACKDROP)
	control.backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.backdrop:SetDimensions(RdKGToolCS.config.width, RdKGToolCS.config.entryHeight)
	control.backdrop:SetDrawLayer(0)
	
	control.uaImage = wm:CreateControl(nil, control, CT_TEXTURE)
	control.uaImage:SetAnchor(TOPLEFT, control, TOPLEFT, -1, -1)
	control.uaImage:SetDimensions(RdKGToolCS.config.imageWidth + 2, RdKGToolCS.config.entryHeight + 2)
	control.uaImage:SetTexture("/esoui/art/mappins/ava_attackburst_64.dds")
	control.uaImage:SetHidden(true)
	control.uaImage:SetDrawLayer(1)
	
	control.image = wm:CreateControl(nil, control, CT_TEXTURE)
	control.image:SetAnchor(TOPLEFT, control, TOPLEFT, -2, -2)
	control.image:SetDimensions(RdKGToolCS.config.imageWidth + 4, RdKGToolCS.config.entryHeight + 4)
	control.image:SetDrawLayer(2)
	
	control.name = wm:CreateControl(nil, control, CT_LABEL)
	control.name:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolCS.config.imageWidth + 4, 0) 
	control.name:SetDimensions(RdKGToolCS.config.nameWidth, RdKGToolCS.config.entryHeight)
	control.name:SetFont(controlFont)
	control.name:SetWrapMode(ELLIPSIS)
	control.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	control.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	
	control.progress = wm:CreateControl(nil, control, CT_CONTROL)
	control.progress:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolCS.config.imageWidth + 4 + RdKGToolCS.config.nameWidth, 0)
	control.progress:SetDimensions(RdKGToolCS.config.flagWidth, RdKGToolCS.config.entryHeight)
	
	control.progress.bar1 = RdKGToolCS.CreateProgressBar(control.progress)
	control.progress.bar2 = RdKGToolCS.CreateProgressBar(control.progress)
	control.progress.bar3 = RdKGToolCS.CreateProgressBar(control.progress)
	
	control.adSiege = wm:CreateControl(nil, control, CT_LABEL)
	control.adSiege:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolCS.config.imageWidth + 4 + RdKGToolCS.config.nameWidth + RdKGToolCS.config.flagWidth, 0) 
	control.adSiege:SetDimensions(RdKGToolCS.config.siegeWidth, RdKGToolCS.config.entryHeight)
	control.adSiege:SetFont(controlFont)
	control.adSiege:SetWrapMode(ELLIPSIS)
	control.adSiege:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	control.adSiege:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	
	control.epSiege = wm:CreateControl(nil, control, CT_LABEL)
	control.epSiege:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolCS.config.imageWidth + 4 + RdKGToolCS.config.nameWidth + RdKGToolCS.config.flagWidth + RdKGToolCS.config.siegeWidth, 0) 
	control.epSiege:SetDimensions(RdKGToolCS.config.siegeWidth, RdKGToolCS.config.entryHeight)
	control.epSiege:SetFont(controlFont)
	control.epSiege:SetWrapMode(ELLIPSIS)
	control.epSiege:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	control.epSiege:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	
	control.dcSiege = wm:CreateControl(nil, control, CT_LABEL)
	control.dcSiege:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolCS.config.imageWidth + 4 + RdKGToolCS.config.nameWidth + RdKGToolCS.config.flagWidth + RdKGToolCS.config.siegeWidth * 2, 0) 
	control.dcSiege:SetDimensions(RdKGToolCS.config.siegeWidth, RdKGToolCS.config.entryHeight)
	control.dcSiege:SetFont(controlFont)
	control.dcSiege:SetWrapMode(ELLIPSIS)
	control.dcSiege:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	control.dcSiege:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	
	control.flipStatus = wm:CreateControl(nil, control, CT_LABEL)
	control.flipStatus:SetAnchor(TOPLEFT, control, TOPLEFT, RdKGToolCS.config.imageWidth + 4 + RdKGToolCS.config.nameWidth + RdKGToolCS.config.flagWidth + RdKGToolCS.config.siegeWidth * 3 + 10, 0) 
	control.flipStatus:SetDimensions(RdKGToolCS.config.flagFlipWidth, RdKGToolCS.config.entryHeight)
	control.flipStatus:SetFont(controlFont)
	control.flipStatus:SetWrapMode(ELLIPSIS)
	control.flipStatus:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	control.flipStatus:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	
	control.underAttackFor = wm:CreateControl(nil, control, CT_LABEL)
	control.underAttackFor:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0) 
	control.underAttackFor:SetDimensions(RdKGToolCS.config.underAttackForWidth, RdKGToolCS.config.entryHeight)
	control.underAttackFor:SetFont(controlFont)
	control.underAttackFor:SetWrapMode(ELLIPSIS)
	control.underAttackFor:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	control.underAttackFor:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	--control.underAttackFor:SetText("00:00")
	
	return control
end

function RdKGToolCS.CreateProgressBar(parent)
	local control = wm:CreateControl(nil, parent, CT_CONTROL)
	control:SetDimensions(RdKGToolCS.config.flagWidth, RdKGToolCS.config.flagHeight)
	control:SetHidden(true)
	
	control.backdrop = wm:CreateControl(nil, control, CT_BACKDROP)
	control.backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.backdrop:SetDimensions(RdKGToolCS.config.flagWidth, RdKGToolCS.config.flagHeight)
	control.backdrop:SetEdgeColor(0, 0, 0, 0)
	control.backdrop:SetCenterColor(RdKGToolCS.config.flagBackdropColor.r, RdKGToolCS.config.flagBackdropColor.g, RdKGToolCS.config.flagBackdropColor.b, 1)
	
	control.progress = wm:CreateControl(nil, control, CT_STATUSBAR)
	control.progress:SetAnchor(TOPLEFT, control, TOPLEFT, 1, 1)
	control.progress:SetDimensions(RdKGToolCS.config.flagWidth - 2, RdKGToolCS.config.flagHeight - 2)
	control.progress:SetMinMax(0, 100)
	control.progress:SetValue(0)
	return control
end

function RdKGToolCS.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.positionLocked = false
	defaults.showKeeps = true
	defaults.showResources = true
	defaults.showOutposts = true
	defaults.showVillages = true
	defaults.showTemples = true
	defaults.showDestructibles = true
	defaults.defaultColor = {}
	defaults.defaultColor.r = 1
	defaults.defaultColor.g = 1
	defaults.defaultColor.b = 1
	defaults.cooldownColor = {}
	defaults.cooldownColor.r = 0
	defaults.cooldownColor.g = 1
	defaults.cooldownColor.b = 0
	defaults.flipsAtPositiveColor = {}
	defaults.flipsAtPositiveColor.r = 0
	defaults.flipsAtPositiveColor.g = 1
	defaults.flipsAtPositiveColor.b = 0
	defaults.flipsAtNegativeColor = {}
	defaults.flipsAtNegativeColor.r = 1
	defaults.flipsAtNegativeColor.g = 0
	defaults.flipsAtNegativeColor.b = 0
	defaults.hideOnWorldMap = false
	defaults.showFlags = true
	defaults.showSieges = true
	defaults.showOwnerChanges = true
	defaults.showActionTimers = true
	return defaults
end

function RdKGToolCS.SetEnabled(value)
	if RdKGToolCS.state.initialized == true and value ~= nil then
		RdKGToolCS.csVars.enabled = value
		if value == true then
			if RdKGToolCS.state.registredConsumers == false then
				
				EVENT_MANAGER:RegisterForEvent(RdKGToolCS.callbackName, EVENT_PLAYER_ACTIVATED, RdKGToolCS.OnPlayerActivated)
			end
			RdKGToolCS.state.registredConsumers = true
			
		else
			if RdKGToolCS.state.registredConsumers == true then
				
				EVENT_MANAGER:UnregisterForEvent(RdKGToolCS.callbackName, EVENT_PLAYER_ACTIVATED)
			end
			RdKGToolCS.state.registredConsumers = false
		end
		RdKGToolCS.OnPlayerActivated()
	end
end

function RdKGToolCS.SetPositionLocked(value)
	RdKGToolCS.csVars.positionLocked = value
	
	RdKGToolCS.controls.TLW:SetMovable(not value)
	RdKGToolCS.controls.TLW:SetMouseEnabled(not value)
	if value == true then
		RdKGToolCS.controls.TLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
		RdKGToolCS.controls.TLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	else
		RdKGToolCS.controls.TLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
		RdKGToolCS.controls.TLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
	end
end

function RdKGToolCS.SetControlVisibility()
	local enabled = RdKGToolCS.csVars.enabled
	local setHidden = true
	if enabled ~= nil and enabled == true and RdKGToolUtil.IsInCyrodiil() == true then
		setHidden = false
	end
	if setHidden == false then
		if RdKGToolCS.csVars.hideOnWorldMap == false and SCENE_MANAGER ~= nil and SCENE_MANAGER.currentScene ~= nil and SCENE_MANAGER.currentScene.name == "worldMap" then
			RdKGToolCS.controls.TLW:SetHidden(false)
		elseif RdKGToolCS.state.foreground == false then
			RdKGToolCS.controls.TLW:SetHidden(RdKGToolCS.state.activeLayerIndex > 2)
		else
			RdKGToolCS.controls.TLW:SetHidden(false)
		end
	else
		RdKGToolCS.controls.TLW:SetHidden(setHidden)
	end
end

function RdKGToolCS.GetTextureAndOffsetForItem(keepType, rType, isPassable)
	if keepType == KEEPTYPE_KEEP then
		return RdKGToolCS.constants.textures.TEXTURE_KEEP, 3
	elseif keepType == KEEPTYPE_OUTPOST then
		return RdKGToolCS.constants.textures.TEXTURE_OUTPOST, 3
	elseif keepType == KEEPTYPE_RESOURCE then
		if rType == RdKGToolCyro.constants.resourceType.FARM then
			return RdKGToolCS.constants.textures.TEXTURE_RESOURCE_FARM, -1
		elseif rType == RdKGToolCyro.constants.resourceType.MINE then
			return RdKGToolCS.constants.textures.TEXTURE_RESOURCE_MINE, -1
		elseif rType == RdKGToolCyro.constants.resourceType.LUMBER then
			return RdKGToolCS.constants.textures.TEXTURE_RESOURCE_LUMBER, -1
		end
	elseif keepType == KEEPTYPE_TOWN then
		return RdKGToolCS.constants.textures.TEXTURE_VILLAGE, 2
	elseif keepType == KEEPTYPE_ARTIFACT_KEEP then
		return RdKGToolCS.constants.textures.TEXTURE_TEMPLE, -2
	elseif keepType == KEEPTYPE_BRIDGE then
		if isPassable == true then
			return RdKGToolCS.constants.textures.TEXTURE_BRIDGE_PASSABLE, -2
		else
			return RdKGToolCS.constants.textures.TEXTURE_BRIDGE_NOT_PASSABLE, -2
		end
	elseif keepType == KEEPTYPE_MILEGATE then
		if isPassable == true then
			return RdKGToolCS.constants.textures.TEXTURE_MILEGATE_PASSABLE, -2
		else
			return RdKGToolCS.constants.textures.TEXTURE_MILEGATE_NOT_PASSABLE, -2
		end
	end
	return "", 0
end

function RdKGToolCS.SetSiegeWeapons(control, weapons)
	if weapons ~= nil and weapons > 0 then
		control:SetText(weapons)
	else
		control:SetText("")
	end
end

function RdKGToolCS.FormatUnderAttackTime(underAttackFor)
	if underAttackFor ~= nil or underAttackFor == 0 then
		local minutes = string.format("%d", underAttackFor / 60)
		local seconds = underAttackFor - minutes * 60
		if seconds > 0 and seconds < 10 then
			return string.format("%d:0%d", minutes, seconds)
		elseif seconds == 0 then
			return string.format("%d:00", minutes)
		else
			return string.format("%d:%d", minutes, seconds)
		end
	else
		return ""
	end
end

function RdKGToolCS.UpdateEntries(itemsOfInterest)
	--d(#itemsOfInterest)
	local adColor = RdKGToolAC.GetColorForAlliance(ALLIANCE_ALDMERI_DOMINION)
	local epColor = RdKGToolAC.GetColorForAlliance(ALLIANCE_EBONHEART_PACT)
	local dcColor = RdKGToolAC.GetColorForAlliance(ALLIANCE_DAGGERFALL_COVENANT)
	local index = 1
	for i = 1, #itemsOfInterest do
		
		local itemOfInterest = itemsOfInterest[i]
		local showItem = false
		if itemOfInterest.keepType == KEEPTYPE_KEEP and RdKGToolCS.csVars.showKeeps == true then
			showItem = true
		elseif itemOfInterest.keepType == KEEPTYPE_OUTPOST and RdKGToolCS.csVars.showOutposts == true then
			showItem = true
		elseif itemOfInterest.keepType == KEEPTYPE_RESOURCE and RdKGToolCS.csVars.showResources == true then
			showItem = true
		elseif itemOfInterest.keepType == KEEPTYPE_TOWN and RdKGToolCS.csVars.showVillages == true then
			showItem = true
		elseif itemOfInterest.keepType == KEEPTYPE_ARTIFACT_KEEP and RdKGToolCS.csVars.showTemples == true then
			showItem = true
		elseif (itemOfInterest.keepType == KEEPTYPE_BRIDGE or itemOfInterest.keepType == KEEPTYPE_MILEGATE) and RdKGToolCS.csVars.showDestructibles == true then
			showItem = true
		end
		
		if showItem == true then
			local control = RdKGToolCS.state.visibleControls[index]
			control:ClearAnchors()
			control:SetAnchor(TOPLEFT, RdKGToolCS.controls.TLW.rootControl, TOPLEFT, 0, RdKGToolCS.config.entryHeight * (index - 1))
			control:SetHidden(false)
			local ac = RdKGToolAC.GetColorForAlliance(itemOfInterest.owningAlliance)
			--d(ac)
			--d("---")
			if index % 2 == 0 then
				control.backdrop:SetCenterColor(ac.r, ac.g, ac.b, RdKGToolCS.config.backdropAlphaEven)
			else
				control.backdrop:SetCenterColor(ac.r, ac.g, ac.b, RdKGToolCS.config.backdropAlphaOdd)
			end
			control.backdrop:SetEdgeColor(0,0,0,0)
			if itemOfInterest.isUnderAttack == true then
				control.backdrop:SetHidden(false)
				control.uaImage:SetHidden(false)
				control.image:SetHidden(false)
			else
				control.backdrop:SetHidden(false)
				control.uaImage:SetHidden(true)
				control.image:SetHidden(false)
			end
			local texture, offset = RdKGToolCS.GetTextureAndOffsetForItem(itemOfInterest.keepType, itemOfInterest.rType, itemOfInterest.isPassable)
			control.image:SetTexture(texture)
			control.image:ClearAnchors()
			control.image:SetAnchor(TOPLEFT, control, TOPLEFT, -offset, -offset)
			control.image:SetDimensions(RdKGToolCS.config.imageWidth + offset * 2, RdKGToolCS.config.entryHeight + offset * 2)
			control.image:SetColor(ac.r, ac.g, ac.b, 1)
			control.name:SetColor(ac.r, ac.g, ac.b, 1)
			control.name:SetText(itemOfInterest.name)
			if RdKGToolCS.csVars.showSieges == true then
				if itemOfInterest.siegeWeapons ~= nil then
					RdKGToolCS.SetSiegeWeapons(control.adSiege, itemOfInterest.siegeWeapons.AD)
					RdKGToolCS.SetSiegeWeapons(control.epSiege, itemOfInterest.siegeWeapons.EP)
					RdKGToolCS.SetSiegeWeapons(control.dcSiege, itemOfInterest.siegeWeapons.DC)
					control.adSiege:SetColor(adColor.r, adColor.g, adColor.b, 1)
					control.epSiege:SetColor(epColor.r, epColor.g, epColor.b, 1)
					control.dcSiege:SetColor(dcColor.r, dcColor.g, dcColor.b, 1)
				else
					control.adSiege:SetText("")
					control.epSiege:SetText("")
					control.dcSiege:SetText("")
				end
			end
			if RdKGToolCS.csVars.showActionTimers == true then
				local underAttackFor = itemOfInterest.underAttackFor
				control.underAttackFor:SetText(RdKGToolCS.FormatUnderAttackTime(underAttackFor / 1000))
				if itemOfInterest.isCoolingDown == true then
					control.underAttackFor:SetColor(RdKGToolCS.csVars.cooldownColor.r, RdKGToolCS.csVars.cooldownColor.g, RdKGToolCS.csVars.cooldownColor.b,1)
				else
					control.underAttackFor:SetColor(RdKGToolCS.csVars.defaultColor.r, RdKGToolCS.csVars.defaultColor.g, RdKGToolCS.csVars.defaultColor.b,1)
				end
			end
			local objectives = itemOfInterest.objectives
			if RdKGToolCS.csVars.showFlags == true then
				
				control.progress.bar1:ClearAnchors()
				control.progress.bar2:ClearAnchors()
				control.progress.bar3:ClearAnchors()
				if itemOfInterest.keepType == KEEPTYPE_KEEP or itemOfInterest.keepType == KEEPTYPE_OUTPOST then
					control.progress.bar1:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, RdKGToolCS.config.entryHeight / 2 - RdKGToolCS.config.flagHeight - 1)
					control.progress.bar2:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, RdKGToolCS.config.entryHeight / 2 + 1)
					
					control.progress.bar1:SetHidden(false)
					control.progress.bar2:SetHidden(false)
					control.progress.bar3:SetHidden(true)
					
					if objectives ~= nil and objectives[1] ~= nil and objectives[2] ~= nil then
						control.progress.bar1.progress:SetValue(objectives[1].state)
						control.progress.bar2.progress:SetValue(objectives[2].state)
						control.progress.bar1.progress:SetColor(RdKGToolUtil.ColorRgbToParams(RdKGToolAC.GetColorForAlliance(objectives[1].holdingAlliance)))
						control.progress.bar2.progress:SetColor(RdKGToolUtil.ColorRgbToParams(RdKGToolAC.GetColorForAlliance(objectives[2].holdingAlliance)))
					else
						control.progress.bar1.progress:SetValue(100)
						control.progress.bar2.progress:SetValue(100)
						RdKGToolChat.SendChatMessage("Objectives are nil", RdKGToolCS.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)
						control.progress.bar1.progress:SetColor(RdKGToolUtil.ColorRgbToParams(RdKGToolAC.GetColorForAlliance(0)))
						control.progress.bar2.progress:SetColor(RdKGToolUtil.ColorRgbToParams(RdKGToolAC.GetColorForAlliance(0)))
					end

					
				elseif itemOfInterest.keepType == KEEPTYPE_TOWN then
					control.progress.bar1:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, RdKGToolCS.config.entryHeight / 6 - RdKGToolCS.config.flagHeight / 2)
					control.progress.bar2:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, RdKGToolCS.config.entryHeight / 6 * 3 - RdKGToolCS.config.flagHeight / 2)
					control.progress.bar3:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, RdKGToolCS.config.entryHeight / 6 * 5 - RdKGToolCS.config.flagHeight / 2)
				
					control.progress.bar1:SetHidden(false)
					control.progress.bar2:SetHidden(false)
					control.progress.bar3:SetHidden(false)
					
					if objectives ~= nil then
						control.progress.bar1.progress:SetValue(objectives[1].state)
						control.progress.bar2.progress:SetValue(objectives[2].state)
						control.progress.bar3.progress:SetValue(objectives[3].state)
						control.progress.bar1.progress:SetColor(RdKGToolUtil.ColorRgbToParams(RdKGToolAC.GetColorForAlliance(objectives[1].holdingAlliance)))
						control.progress.bar2.progress:SetColor(RdKGToolUtil.ColorRgbToParams(RdKGToolAC.GetColorForAlliance(objectives[2].holdingAlliance)))
						control.progress.bar3.progress:SetColor(RdKGToolUtil.ColorRgbToParams(RdKGToolAC.GetColorForAlliance(objectives[3].holdingAlliance)))
					else
						control.progress.bar1.progress:SetColor(RdKGToolUtil.ColorRgbToParams(RdKGToolAC.GetColorForAlliance(0)))
						control.progress.bar2.progress:SetColor(RdKGToolUtil.ColorRgbToParams(RdKGToolAC.GetColorForAlliance(0)))
						control.progress.bar3.progress:SetColor(RdKGToolUtil.ColorRgbToParams(RdKGToolAC.GetColorForAlliance(0)))
					end
					
					
				elseif itemOfInterest.keepType == KEEPTYPE_RESOURCE then
					control.progress.bar1:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, RdKGToolCS.config.entryHeight / 2 - RdKGToolCS.config.flagHeight / 2)
				
					control.progress.bar1:SetHidden(false)
					control.progress.bar2:SetHidden(true)
					control.progress.bar3:SetHidden(true)
					
					if objectives ~= nil then
						control.progress.bar1.progress:SetValue(objectives[1].state)
						control.progress.bar1.progress:SetColor(RdKGToolUtil.ColorRgbToParams(RdKGToolAC.GetColorForAlliance(objectives[1].holdingAlliance)))
					else
						control.progress.bar1.progress:SetColor(RdKGToolUtil.ColorRgbToParams(RdKGToolAC.GetColorForAlliance(0)))
					end
					
					
				else
					control.progress.bar1:SetHidden(true)
					control.progress.bar2:SetHidden(true)
					control.progress.bar3:SetHidden(true)
				end
			end
			if RdKGToolCS.csVars.showOwnerChanges == true then
				if itemOfInterest.flipsAt ~= nil then
					local flipsIn = math.floor((itemOfInterest.flipsAt - GetGameTimeMilliseconds()) / 1000)
					if flipsIn >= 0 then
						control.flipStatus:SetText(flipsIn)
						if objectives ~= nil and objectives[1].holdingAlliance == GetUnitAlliance("player") then
							control.flipStatus:SetColor(RdKGToolCS.csVars.flipsAtPositiveColor.r, RdKGToolCS.csVars.flipsAtPositiveColor.g, RdKGToolCS.csVars.flipsAtPositiveColor.b)
						else
							control.flipStatus:SetColor(RdKGToolCS.csVars.flipsAtNegativeColor.r, RdKGToolCS.csVars.flipsAtNegativeColor.g, RdKGToolCS.csVars.flipsAtNegativeColor.b)
						end
					else
						control.flipStatus:SetText("")
					end
				else
					control.flipStatus:SetText("")
				end
			end
			index = index + 1
		end
		
	end
	for i = index, #RdKGToolCS.state.visibleControls do
		RdKGToolCS.state.visibleControls[i]:SetHidden(true)
	end
end

function RdKGToolCS.AdjustDisplayedComponents()
	local globalWidth = RdKGToolCS.config.width
	for i = 1, #RdKGToolCS.state.visibleControls do
		local offset = RdKGToolCS.config.imageWidth + 4 + RdKGToolCS.config.nameWidth
		local control = RdKGToolCS.state.visibleControls[i]
		local progress = control.progress
		progress:ClearAnchors()
		if RdKGToolCS.csVars.showFlags == true then
			progress:SetHidden(false)
			progress:SetAnchor(TOPLEFT, control, TOPLEFT, offset, 0)
			offset = offset + RdKGToolCS.config.flagWidth
		else
			progress:SetHidden(true)
		end
		local adSiege = control.adSiege
		local epSiege = control.epSiege
		local dcSiege = control.dcSiege
		adSiege:ClearAnchors()
		epSiege:ClearAnchors()
		dcSiege:ClearAnchors()
		if RdKGToolCS.csVars.showSieges == true then
			adSiege:SetHidden(false)
			adSiege:SetAnchor(TOPLEFT, control, TOPLEFT, offset, 0)
			offset = offset + RdKGToolCS.config.siegeWidth
			epSiege:SetHidden(false)
			epSiege:SetAnchor(TOPLEFT, control, TOPLEFT, offset, 0)
			offset = offset + RdKGToolCS.config.siegeWidth
			dcSiege:SetHidden(false)
			dcSiege:SetAnchor(TOPLEFT, control, TOPLEFT, offset, 0)
			offset = offset + RdKGToolCS.config.siegeWidth
		else
			adSiege:SetHidden(true)
			epSiege:SetHidden(true)
			dcSiege:SetHidden(true)
		end
		offset = offset + 10
		local flipStatus = control.flipStatus
		flipStatus:ClearAnchors()
		if RdKGToolCS.csVars.showOwnerChanges == true then
			
			flipStatus:SetHidden(false)
			flipStatus:SetAnchor(TOPLEFT, control, TOPLEFT, offset, 0)
			offset = offset + RdKGToolCS.config.flagFlipWidth
		else
			flipStatus:SetHidden(true)
		end
		offset = offset + 10
		local underAttackFor = control.underAttackFor
		--underAttackFor:ClearAnchors()
		if RdKGToolCS.csVars.showActionTimers == true then
			underAttackFor:SetHidden(false)
			--underAttackFor:SetAnchor(TOPLEFT, control, TOPLEFT, offset, 0)
			offset = offset + RdKGToolCS.config.underAttackForWidth
		else
			underAttackFor:SetHidden(true)
		end
		globalWidth = offset
		control:SetDimensions(globalWidth, RdKGToolCS.config.entryHeight)
		control.backdrop:SetDimensions(globalWidth, RdKGToolCS.config.entryHeight)
	end
	RdKGToolCS.controls.TLW:SetDimensions(globalWidth, RdKGToolCS.config.height)
	RdKGToolCS.controls.TLW.rootControl.movableBackdrop:SetDimensions(globalWidth, RdKGToolCS.config.height)
end

--callbacks
function RdKGToolCS.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolCS.csVars = currentProfile.toolbox.cs
		RdKGToolCS.SetEnabled(RdKGToolCS.csVars.enabled)
		if RdKGToolCS.state.initialized == true then
			RdKGToolCS.SetPositionLocked(RdKGToolCS.csVars.positionLocked)
			RdKGToolCS.SetTlwLocation()
			RdKGToolCS.AdjustDisplayedComponents()
		end
	end
end

function RdKGToolCS.SaveWindowLocation()
	if RdKGToolCS.csVars.positionLocked == false then
		RdKGToolCS.csVars.location = RdKGToolCS.csVars.location or {}
		RdKGToolCS.csVars.location.x = RdKGToolCS.controls.TLW:GetLeft()
		RdKGToolCS.csVars.location.y = RdKGToolCS.controls.TLW:GetTop()
	end
end

function RdKGToolCS.OnPlayerActivated(eventCode, initial)
	if RdKGToolCS.csVars.enabled == true and RdKGToolUtil.IsInCyrodiil() == true then
		if RdKGToolCS.state.registredCyrodiilConsumers == false then
			EVENT_MANAGER:RegisterForEvent(RdKGToolCS.callbackName, EVENT_ACTION_LAYER_POPPED, RdKGToolCS.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForEvent(RdKGToolCS.callbackName, EVENT_ACTION_LAYER_PUSHED, RdKGToolCS.SetForegroundVisibility)
			RdKGToolCyro.AddConsumer(RdKGToolCS.callbackName, RdKGToolCS.OnUiUpdate, nil)
			RdKGToolCS.state.registredCyrodiilConsumers = true
		end
	else
		if RdKGToolCS.state.registredCyrodiilConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(RdKGToolCS.callbackName, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(RdKGToolCS.callbackName, EVENT_ACTION_LAYER_PUSHED)
			RdKGToolCyro.RemoveConsumer(RdKGToolCS.callbackName)
			RdKGToolCS.state.registredCyrodiilConsumers = false
		end
	end
	RdKGToolCS.SetControlVisibility()
end

function RdKGToolCS.OnUiUpdate(itemsOfInterest)
	if itemsOfInterest ~= nil then
		if #itemsOfInterest > #RdKGToolCS.state.visibleControls then
			for i = #RdKGToolCS.state.visibleControls + 1, #itemsOfInterest do
				local control = RdKGToolCS.CreateEntryControl(RdKGToolCS.controls.TLW.rootControl)
				control:ClearAnchors()
				control:SetAnchor(TOPLEFT, RdKGToolCS.controls.TLW.rootControl, TOPLEFT, 0, RdKGToolCS.config.entryHeight * (#RdKGToolCS.state.visibleControls + i - 1))
				control:SetHidden(false)
				table.insert(RdKGToolCS.state.visibleControls, control)
			end
			RdKGToolCS.AdjustDisplayedComponents()
		else
			for i = #itemsOfInterest + 1, #RdKGToolCS.state.visibleControls do
				RdKGToolCS.state.visibleControls[i]:SetHidden(true)
			end
		end
		RdKGToolCS.UpdateEntries(itemsOfInterest)
	else
		for i = 1, #RdKGToolCS.state.visibleControls do
			RdKGToolCS.state.visibleControls[i]:SetHidden(true)
		end
	end
end

function RdKGToolCS.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		RdKGToolCS.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		RdKGToolCS.state.foreground = false
	end
	--hack?
	RdKGToolCS.state.activeLayerIndex = activeLayerIndex
	
	RdKGToolCS.SetControlVisibility()
end

--menu interactions
function RdKGToolCS.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.CS_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CS_ENABLED,
					getFunc = RdKGToolCS.GetCsEnabled,
					setFunc = RdKGToolCS.SetCsEnabled
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CS_POSITION_FIXED,
					getFunc = RdKGToolCS.GetCsPositionLocked,
					setFunc = RdKGToolCS.SetCsPositionLocked
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CS_HIDE_ON_WORLDMAP,
					getFunc = RdKGToolCS.GetCsHideOnWorldMap,
					setFunc = RdKGToolCS.SetCsHideOnWorldMap
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CS_SHOW_FLAGS,
					getFunc = RdKGToolCS.GetCsShowFlagsEnabled,
					setFunc = RdKGToolCS.SetCsShowFlagsEnabled
				},
				[5] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CS_SHOW_SIEGES,
					getFunc = RdKGToolCS.GetCsShowSiegesEnabled,
					setFunc = RdKGToolCS.SetCsShowSiegesEnabled
				},
				[6] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CS_SHOW_OWNER_CHANGES,
					getFunc = RdKGToolCS.GetCsShowOwnerChangesEnabled,
					setFunc = RdKGToolCS.SetCsShowOwnerChangesEnabled
				},
				[7] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CS_SHOW_ACTION_TIMERS,
					getFunc = RdKGToolCS.GetCsShowActionTimersEnabled,
					setFunc = RdKGToolCS.SetCsShowActionTimersEnabled
				},
				[8] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CS_COLOR_DEFAULT,
					getFunc = RdKGToolCS.GetCsDefaultColor,
					setFunc = RdKGToolCS.SetCsDefaultColor,
					width = "full"
				},
				[9] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CS_COLOR_COOLDOWN,
					getFunc = RdKGToolCS.GetCsCooldownColor,
					setFunc = RdKGToolCS.SetCsCooldownColor,
					width = "full"
				},
				[10] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CS_COLOR_FLIPS_POSITIVE,
					getFunc = RdKGToolCS.GetCsFlipsAtPositiveColor,
					setFunc = RdKGToolCS.SetCsFlipsAtPositiveColor,
					width = "full"
				},
				[11] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CS_COLOR_FLIPS_NEGATIVE,
					getFunc = RdKGToolCS.GetCsFlipsAtNegativeColor,
					setFunc = RdKGToolCS.SetCsFlipsAtNegativeColor,
					width = "full"
				},
				[12] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CS_SHOW_KEEPS,
					getFunc = RdKGToolCS.GetCsShowKeeps,
					setFunc = RdKGToolCS.SetCsShowKeeps
				},
				[13] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CS_SHOW_OUTPOSTS,
					getFunc = RdKGToolCS.GetCsShowOutposts,
					setFunc = RdKGToolCS.SetCsShowOutposts
				},
				[14] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CS_SHOW_RESOURCES,
					getFunc = RdKGToolCS.GetCsShowResources,
					setFunc = RdKGToolCS.SetCsShowResources
				},
				[15] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CS_SHOW_VILLAGES,
					getFunc = RdKGToolCS.GetCsShowVillages,
					setFunc = RdKGToolCS.SetCsShowVillages
				},
				[16] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CS_SHOW_TEMPLES,
					getFunc = RdKGToolCS.GetCsShowTemples,
					setFunc = RdKGToolCS.SetCsShowTemples
				},
				[17] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CS_SHOW_DESTRUCTIBLES,
					getFunc = RdKGToolCS.GetCsShowDestructibles,
					setFunc = RdKGToolCS.SetCsShowDestructibles
				}
			}
		}
	}
	return menu
end

function RdKGToolCS.GetCsEnabled()
	return RdKGToolCS.csVars.enabled
end

function RdKGToolCS.SetCsEnabled(value)
	RdKGToolCS.SetEnabled(value)
end

function RdKGToolCS.GetCsPositionLocked()
	return RdKGToolCS.csVars.positionLocked
end

function RdKGToolCS.SetCsPositionLocked(value)
	RdKGToolCS.SetPositionLocked(value)
end

function RdKGToolCS.GetCsHideOnWorldMap()
	return RdKGToolCS.csVars.hideOnWorldMap
end

function RdKGToolCS.SetCsHideOnWorldMap(value)
	RdKGToolCS.csVars.hideOnWorldMap = value
end

function RdKGToolCS.GetCsShowFlagsEnabled()
	return RdKGToolCS.csVars.showFlags
end

function RdKGToolCS.SetCsShowFlagsEnabled(value)
	RdKGToolCS.csVars.showFlags = value
	RdKGToolCS.AdjustDisplayedComponents()
end

function RdKGToolCS.GetCsShowSiegesEnabled()
	return RdKGToolCS.csVars.showSieges
end

function RdKGToolCS.SetCsShowSiegesEnabled(value)
	RdKGToolCS.csVars.showSieges = value
	RdKGToolCS.AdjustDisplayedComponents()
end

function RdKGToolCS.GetCsShowOwnerChangesEnabled()
	return RdKGToolCS.csVars.showOwnerChanges
end

function RdKGToolCS.SetCsShowOwnerChangesEnabled(value)
	RdKGToolCS.csVars.showOwnerChanges = value
	RdKGToolCS.AdjustDisplayedComponents()
end

function RdKGToolCS.GetCsShowActionTimersEnabled()
	return RdKGToolCS.csVars.showActionTimers
end

function RdKGToolCS.SetCsShowActionTimersEnabled(value)
	RdKGToolCS.csVars.showActionTimers = value
	RdKGToolCS.AdjustDisplayedComponents()
end

function RdKGToolCS.GetCsDefaultColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolCS.csVars.defaultColor)
end

function RdKGToolCS.SetCsDefaultColor(r, g, b)
	RdKGToolCS.csVars.defaultColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolCS.GetCsCooldownColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolCS.csVars.cooldownColor)
end

function RdKGToolCS.SetCsCooldownColor(r, g, b)
	RdKGToolCS.csVars.cooldownColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolCS.GetCsFlipsAtPositiveColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolCS.csVars.flipsAtPositiveColor)
end

function RdKGToolCS.SetCsFlipsAtPositiveColor(r, g, b)
	RdKGToolCS.csVars.flipsAtPositiveColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolCS.GetCsFlipsAtNegativeColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolCS.csVars.flipsAtNegativeColor)
end

function RdKGToolCS.SetCsFlipsAtNegativeColor(r, g, b)
	RdKGToolCS.csVars.flipsAtNegativeColor = RdKGToolMenu.GetColorFromRGB(r, g, b)
end

function RdKGToolCS.GetCsShowKeeps()
	return RdKGToolCS.csVars.showKeeps
end

function RdKGToolCS.SetCsShowKeeps(value)
	RdKGToolCS.csVars.showKeeps = value
end

function RdKGToolCS.GetCsShowOutposts()
	return RdKGToolCS.csVars.showOutposts
end

function RdKGToolCS.SetCsShowOutposts(value)
	RdKGToolCS.csVars.showOutposts = value
end

function RdKGToolCS.GetCsShowResources()
	return RdKGToolCS.csVars.showResources
end

function RdKGToolCS.SetCsShowResources(value)
	RdKGToolCS.csVars.showResources = value
end

function RdKGToolCS.GetCsShowVillages()
	return RdKGToolCS.csVars.showVillages
end

function RdKGToolCS.SetCsShowVillages(value)
	RdKGToolCS.csVars.showVillages = value
end

function RdKGToolCS.GetCsShowTemples()
	return RdKGToolCS.csVars.showTemples
end

function RdKGToolCS.SetCsShowTemples(value)
	RdKGToolCS.csVars.showTemples = value
end

function RdKGToolCS.GetCsShowDestructibles()
	return RdKGToolCS.csVars.showDestructibles
end

function RdKGToolCS.SetCsShowDestructibles(value)
	RdKGToolCS.csVars.showDestructibles = value
end