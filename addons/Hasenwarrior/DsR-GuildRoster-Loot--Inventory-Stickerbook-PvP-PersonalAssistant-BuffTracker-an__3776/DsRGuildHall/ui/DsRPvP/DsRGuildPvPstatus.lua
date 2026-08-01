-- Create namespace
DsRGuildPvPstatus = {}
local DsRGuildPvPstatus = DsRGuildPvPstatus  or {}

DsRGuildPvPstatus.callbackName = "DsRGuildPvPstatus"

DsRGuildPvPstatus.config = {}
DsRGuildPvPstatus.config.isClampedToScreen = true
DsRGuildPvPstatus.config.imageWidth = 30
DsRGuildPvPstatus.config.nameWidth = 150
DsRGuildPvPstatus.config.flagWidth = 40
DsRGuildPvPstatus.config.flagHeight = 8
DsRGuildPvPstatus.config.flagFlipWidth = 20
DsRGuildPvPstatus.config.underAttackForWidth = 50
DsRGuildPvPstatus.config.width = 375
DsRGuildPvPstatus.config.siegeWidth = 20
DsRGuildPvPstatus.config.entryHeight = 30
DsRGuildPvPstatus.config.height = DsRGuildPvPstatus.config.entryHeight * 10
DsRGuildPvPstatus.config.backdropAlphaOdd = 0.25
DsRGuildPvPstatus.config.backdropAlphaEven = 0.15
DsRGuildPvPstatus.config.flagBackdropColor = {}
DsRGuildPvPstatus.config.flagBackdropColor.r = 0.1
DsRGuildPvPstatus.config.flagBackdropColor.g = 0.1
DsRGuildPvPstatus.config.flagBackdropColor.b = 0.1

DsRGuildPvPstatus.constants = DsRGuildPvPstatus.constants or {}
DsRGuildPvPstatus.constants.PREFIX = "CS"
DsRGuildPvPstatus.constants.TLW = "DsRGuildPvP.toolbox.status.tlw"
DsRGuildPvPstatus.constants.textures = {}
DsRGuildPvPstatus.constants.textures.TEXTURE_KEEP = "/esoui/art/mappins/ava_largekeep_neutral.dds"
DsRGuildPvPstatus.constants.textures.TEXTURE_OUTPOST = "/esoui/art/mappins/ava_outpost_neutral.dds"
DsRGuildPvPstatus.constants.textures.TEXTURE_VILLAGE = "/esoui/art/mappins/ava_town_neutral.dds"
DsRGuildPvPstatus.constants.textures.TEXTURE_TEMPLE = "/esoui/art/icons/mapkey/mapkey_temple.dds"
DsRGuildPvPstatus.constants.textures.TEXTURE_DESTRUCTIBLE_BRDIGE = ""
DsRGuildPvPstatus.constants.textures.TEXTURE_DESTRUCTIBLE_GATE = ""
DsRGuildPvPstatus.constants.textures.TEXTURE_RESOURCE_MINE = "/esoui/art/compass/ava_mine_neutral.dds"
DsRGuildPvPstatus.constants.textures.TEXTURE_RESOURCE_FARM = "/esoui/art/compass/ava_farm_neutral.dds"
DsRGuildPvPstatus.constants.textures.TEXTURE_RESOURCE_LUMBER = "/esoui/art/compass/ava_lumbermill_neutral.dds"
DsRGuildPvPstatus.constants.textures.TEXTURE_BRIDGE_PASSABLE = "/esoui/art/mappins/ava_bridge_passable.dds"
DsRGuildPvPstatus.constants.textures.TEXTURE_BRIDGE_NOT_PASSABLE = "/esoui/art/mappins/ava_bridge_not_passable.dds"
DsRGuildPvPstatus.constants.textures.TEXTURE_MILEGATE_PASSABLE = "/esoui/art/mappins/ava_milegate_passable.dds"
DsRGuildPvPstatus.constants.textures.TEXTURE_MILEGATE_NOT_PASSABLE = "/esoui/art/mappins/ava_milegate_not_passable.dds"

DsRGuildPvPstatus.state = {}
DsRGuildPvPstatus.state.initialized = false
DsRGuildPvPstatus.state.foreground = true
DsRGuildPvPstatus.state.registredConsumers = false
DsRGuildPvPstatus.state.registredCyrodiilConsumers = false
DsRGuildPvPstatus.state.activeLayerIndex = 1
DsRGuildPvPstatus.state.visibleControls = {}
DsRGuildPvPstatus.state.newProfileName = ""
DsRGuildPvPstatus.state.positionFixedConsumers = {}
DsRGuildPvPstatus.state.consumers = {}

DsRGuildPvPstatus.controls = {}

local wm = WINDOW_MANAGER

DsRGuildPvPstatus.battleContext = BGQUERY_LOCAL

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.Initialize()
	DsRGuildPvPstatus.CreateUI()
	
	DsRGuildPvPstatus.AddPositionFixedConsumer(DsRGuildPvPstatus.SetCsPositionLocked)
	
	DsRGuildPvPstatus.AdjustDisplayedComponents()
	DsRGuildPvPstatus.state.initialized = true
	DsRGuildPvPstatus.SetEnabled(DsRGuildPvP.pvp.PvPstatusenabled)
	DsRGuildPvPstatus.SetPositionLocked(DsRGuildPvP.pvp.PvPstatuspositionLocked)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.PositionFixedConsumerExists(consumer)
	for i = 1, #DsRGuildPvPstatus.state.positionFixedConsumers do
		if DsRGuildPvPstatus.state.positionFixedConsumers[i] == consumer then
			return true
		end
	end
	return false
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.AddPositionFixedConsumer(consumer)
	if consumer ~= nil and type(consumer) == "function" and DsRGuildPvPstatus.PositionFixedConsumerExists(consumer) == false then
		table.insert(DsRGuildPvPstatus.state.positionFixedConsumers, consumer)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.RemovePositionFixedConsumer(consumer)
	if consumer ~= nil and type(consumer) == "function" and DsRGuildPvPstatus.PositionFixedConsumerExists(consumer) == true then
		for i = 1, #DsRGuildPvPstatus.state.positionFixedConsumers do
			if DsRGuildPvPstatus.state.positionFixedConsumers[i] == consumer then
				table.remove(DsRGuildPvPstatus.state.positionFixedConsumers, i)
				break
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.SetTlwLocation()
	DsRGuildPvPstatus.controls.TLW:ClearAnchors()
	if DsRGuildPvP.pvp.PvPstatuslocation == nil then
		DsRGuildPvPstatus.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, 250, -250)
	else
		DsRGuildPvPstatus.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DsRGuildPvP.pvp.PvPstatuslocation.x, DsRGuildPvP.pvp.PvPstatuslocation.y)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.CreateUI()
	DsRGuildPvPstatus.controls.TLW = wm:CreateTopLevelWindow(DsRGuildPvPstatus.constants.FRAME)
	
	DsRGuildPvPstatus.SetTlwLocation()
		
	DsRGuildPvPstatus.controls.TLW:SetClampedToScreen(DsRGuildPvPstatus.config.isClampedToScreen)
	DsRGuildPvPstatus.controls.TLW:SetHandler("OnMoveStop", DsRGuildPvPstatus.SaveWindowLocation)
	DsRGuildPvPstatus.controls.TLW:SetDimensions(DsRGuildPvPstatus.config.width, DsRGuildPvPstatus.config.height)
	
	DsRGuildPvPstatus.controls.TLW.rootControl = wm:CreateControl(nil, DsRGuildPvPstatus.controls.TLW, CT_CONTROL)
	
	local rootControl = DsRGuildPvPstatus.controls.TLW.rootControl
	
	rootControl:SetDimensions(DsRGuildPvPstatus.config.width, DsRGuildPvPstatus.config.height)
	rootControl:SetAnchor(TOPLEFT, DsRGuildPvPstatus.controls.TLW, TOPLEFT, 0, 0)
	
	rootControl.movableBackdrop = wm:CreateControl(nil, rootControl, CT_BACKDROP)
	
	rootControl.movableBackdrop:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
	rootControl.movableBackdrop:SetDimensions(DsRGuildPvPstatus.config.width, DsRGuildPvPstatus.config.height)
	
	rootControl.movableBackdrop:SetCenterColor(0, 0, 0, 0.0)
	rootControl.movableBackdrop:SetEdgeColor(0, 0, 0, 0.0)
	
	DsRGuildPvPstatus.state.visibleControls = DsRGuildPvPstatus.CreateDefaultList(rootControl)
	for i = 1, #DsRGuildPvPstatus.state.visibleControls do
		DsRGuildPvPstatus.state.visibleControls[i]:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, DsRGuildPvPstatus.config.entryHeight * (i - 1))
	end

	local controlFont = DsRGuildfonts.CreateFontString(DsRGuildfonts.constants.CHAT_FONT, DsRGuildfonts.constants.INPUT_KB, DsRGuildPvPstatus.config.entryHeight - 12, DsRGuildfonts.constants.WEIGHT_SOFT_SHADOW_THICK)

	local defVolIcon = zo_iconFormat("/esoui/art/hud/volendrung/daedricartifact_volendrung_empty.dds", 34, 34)
	local defDivider = zo_iconFormat("/esoui/art/miscellaneous/horizontaldivider_mythic.dds", 520, 3)

	rootControl.Volendrung = wm:CreateControl(nil, rootControl, CT_LABEL)
	rootControl.Volendrung:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 40, -55) 
	rootControl.Volendrung:SetFont(controlFont)
	rootControl.Volendrung:SetWrapMode(ELLIPSIS)
	rootControl.Volendrung:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	rootControl.Volendrung:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	rootControl.Volendrung:SetText(defVolIcon .. GetString(DsRGuildPvP_VolendrungInACT))

	rootControl.StatDivider = wm:CreateControl(nil, rootControl, CT_LABEL)
	rootControl.StatDivider:SetAnchor(TOPLEFT, rootControl, TOPLEFT, -70, -15) 
	rootControl.StatDivider:SetFont(controlFont)
	rootControl.StatDivider:SetWrapMode(ELLIPSIS)
	rootControl.StatDivider:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	rootControl.StatDivider:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	rootControl.StatDivider:SetText(defDivider)
	
	-- rootControl.StatTime = wm:CreateControl(nil, rootControl, CT_LABEL)
	-- rootControl.StatTime:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, -30) 
	-- rootControl.StatTime:SetFont(controlFont)
	-- rootControl.StatTime:SetWrapMode(ELLIPSIS)
	-- rootControl.StatTime:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	-- rootControl.StatTime:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

	rootControl.StatAD = wm:CreateControl(nil, rootControl, CT_LABEL)
	rootControl.StatAD:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 40, -30) 
	-- rootControl.StatAD:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 70, -30) 
	rootControl.StatAD:SetFont(controlFont)
	rootControl.StatAD:SetWrapMode(ELLIPSIS)
	rootControl.StatAD:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	rootControl.StatAD:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

	rootControl.StatEP = wm:CreateControl(nil, rootControl, CT_LABEL)
	rootControl.StatEP:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 145, -30) 
	rootControl.StatEP:SetFont(controlFont)
	rootControl.StatEP:SetWrapMode(ELLIPSIS)
	rootControl.StatEP:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	rootControl.StatEP:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

	rootControl.StatDC = wm:CreateControl(nil, rootControl, CT_LABEL)
	rootControl.StatDC:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 250, -30) 
	rootControl.StatDC:SetFont(controlFont)
	rootControl.StatDC:SetWrapMode(ELLIPSIS)
	rootControl.StatDC:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	rootControl.StatDC:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.CreateDefaultList(parent)
	local entries = {}
	for i = 1, 10 do
		local entry = DsRGuildPvPstatus.CreateEntryControl(parent)
		
		table.insert(entries, entry)
	end
	return entries
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.CreateEntryControl(parent)
	local controlFont = DsRGuildfonts.CreateFontString(DsRGuildfonts.constants.CHAT_FONT, DsRGuildfonts.constants.INPUT_KB, DsRGuildPvPstatus.config.entryHeight - 12, DsRGuildfonts.constants.WEIGHT_SOFT_SHADOW_THICK)
	--d(controlFont)
	local control = wm:CreateControl(nil, parent, CT_CONTROL)
	control:SetDimensions(DsRGuildPvPstatus.config.width, DsRGuildPvPstatus.config.entryHeight)
	control:SetHidden(true)
	
	control.backdrop = wm:CreateControl(nil, control, CT_BACKDROP)
	control.backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.backdrop:SetDimensions(DsRGuildPvPstatus.config.width, DsRGuildPvPstatus.config.entryHeight)
	control.backdrop:SetDrawLayer(0)
	
	control.uaImage = wm:CreateControl(nil, control, CT_TEXTURE)
	control.uaImage:SetAnchor(TOPLEFT, control, TOPLEFT, -1, -1)
	control.uaImage:SetDimensions(DsRGuildPvPstatus.config.imageWidth + 2, DsRGuildPvPstatus.config.entryHeight + 2)
	control.uaImage:SetTexture("/esoui/art/mappins/ava_attackburst_64.dds")
	control.uaImage:SetHidden(true)
	control.uaImage:SetDrawLayer(1)
	
	control.image = wm:CreateControl(nil, control, CT_TEXTURE)
	control.image:SetAnchor(TOPLEFT, control, TOPLEFT, -2, -2)
	control.image:SetDimensions(DsRGuildPvPstatus.config.imageWidth + 4, DsRGuildPvPstatus.config.entryHeight + 4)
	control.image:SetDrawLayer(2)
	
	control.name = wm:CreateControl(nil, control, CT_LABEL)
	control.name:SetAnchor(TOPLEFT, control, TOPLEFT, DsRGuildPvPstatus.config.imageWidth + 4, 0) 
	control.name:SetDimensions(DsRGuildPvPstatus.config.nameWidth, DsRGuildPvPstatus.config.entryHeight)
	control.name:SetFont(controlFont)
	control.name:SetWrapMode(ELLIPSIS)
	control.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	control.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	
	control.progress = wm:CreateControl(nil, control, CT_CONTROL)
	control.progress:SetAnchor(TOPLEFT, control, TOPLEFT, DsRGuildPvPstatus.config.imageWidth + 4 + DsRGuildPvPstatus.config.nameWidth, 0)
	control.progress:SetDimensions(DsRGuildPvPstatus.config.flagWidth, DsRGuildPvPstatus.config.entryHeight)
	
	control.progress.bar1 = DsRGuildPvPstatus.CreateProgressBar(control.progress)
	control.progress.bar2 = DsRGuildPvPstatus.CreateProgressBar(control.progress)
	control.progress.bar3 = DsRGuildPvPstatus.CreateProgressBar(control.progress)
	
	control.adSiege = wm:CreateControl(nil, control, CT_LABEL)
	control.adSiege:SetAnchor(TOPLEFT, control, TOPLEFT, DsRGuildPvPstatus.config.imageWidth + 4 + DsRGuildPvPstatus.config.nameWidth + DsRGuildPvPstatus.config.flagWidth, 0) 
	control.adSiege:SetDimensions(DsRGuildPvPstatus.config.siegeWidth, DsRGuildPvPstatus.config.entryHeight)
	control.adSiege:SetFont(controlFont)
	control.adSiege:SetWrapMode(ELLIPSIS)
	control.adSiege:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	control.adSiege:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	
	control.epSiege = wm:CreateControl(nil, control, CT_LABEL)
	control.epSiege:SetAnchor(TOPLEFT, control, TOPLEFT, DsRGuildPvPstatus.config.imageWidth + 4 + DsRGuildPvPstatus.config.nameWidth + DsRGuildPvPstatus.config.flagWidth + DsRGuildPvPstatus.config.siegeWidth, 0) 
	control.epSiege:SetDimensions(DsRGuildPvPstatus.config.siegeWidth, DsRGuildPvPstatus.config.entryHeight)
	control.epSiege:SetFont(controlFont)
	control.epSiege:SetWrapMode(ELLIPSIS)
	control.epSiege:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	control.epSiege:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	
	control.dcSiege = wm:CreateControl(nil, control, CT_LABEL)
	control.dcSiege:SetAnchor(TOPLEFT, control, TOPLEFT, DsRGuildPvPstatus.config.imageWidth + 4 + DsRGuildPvPstatus.config.nameWidth + DsRGuildPvPstatus.config.flagWidth + DsRGuildPvPstatus.config.siegeWidth * 2, 0) 
	control.dcSiege:SetDimensions(DsRGuildPvPstatus.config.siegeWidth, DsRGuildPvPstatus.config.entryHeight)
	control.dcSiege:SetFont(controlFont)
	control.dcSiege:SetWrapMode(ELLIPSIS)
	control.dcSiege:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	control.dcSiege:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	
	control.flipStatus = wm:CreateControl(nil, control, CT_LABEL)
	control.flipStatus:SetAnchor(TOPLEFT, control, TOPLEFT, DsRGuildPvPstatus.config.imageWidth + 4 + DsRGuildPvPstatus.config.nameWidth + DsRGuildPvPstatus.config.flagWidth + DsRGuildPvPstatus.config.siegeWidth * 3 + 10, 0) 
	control.flipStatus:SetDimensions(DsRGuildPvPstatus.config.flagFlipWidth, DsRGuildPvPstatus.config.entryHeight)
	control.flipStatus:SetFont(controlFont)
	control.flipStatus:SetWrapMode(ELLIPSIS)
	control.flipStatus:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	control.flipStatus:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	
	control.underAttackFor = wm:CreateControl(nil, control, CT_LABEL)
	control.underAttackFor:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0) 
	control.underAttackFor:SetDimensions(DsRGuildPvPstatus.config.underAttackForWidth, DsRGuildPvPstatus.config.entryHeight)
	control.underAttackFor:SetFont(controlFont)
	control.underAttackFor:SetWrapMode(ELLIPSIS)
	control.underAttackFor:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	control.underAttackFor:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	
	return control
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.CreateProgressBar(parent)
	local control = wm:CreateControl(nil, parent, CT_CONTROL)
	control:SetDimensions(DsRGuildPvPstatus.config.flagWidth, DsRGuildPvPstatus.config.flagHeight)
	control:SetHidden(true)
	
	control.backdrop = wm:CreateControl(nil, control, CT_BACKDROP)
	control.backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
	control.backdrop:SetDimensions(DsRGuildPvPstatus.config.flagWidth, DsRGuildPvPstatus.config.flagHeight)
	control.backdrop:SetEdgeColor(0, 0, 0, 0)
	control.backdrop:SetCenterColor(DsRGuildPvPstatus.config.flagBackdropColor.r, DsRGuildPvPstatus.config.flagBackdropColor.g, DsRGuildPvPstatus.config.flagBackdropColor.b, 1)
	
	control.progress = wm:CreateControl(nil, control, CT_STATUSBAR)
	control.progress:SetAnchor(TOPLEFT, control, TOPLEFT, 1, 1)
	control.progress:SetDimensions(DsRGuildPvPstatus.config.flagWidth - 2, DsRGuildPvPstatus.config.flagHeight - 2)
	control.progress:SetMinMax(0, 100)
	control.progress:SetValue(0)
	return control
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.SetEnabled(value)
	if DsRGuildPvPstatus.state.initialized == true and value ~= nil then
		DsRGuildPvP.pvp.PvPstatusenabled = value
		if value == true then
			if DsRGuildPvPstatus.state.registredConsumers == false then
				EVENT_MANAGER:RegisterForEvent(DsRGuildPvPstatus.callbackName, EVENT_PLAYER_ACTIVATED, DsRGuildPvPstatus.OnPlayerActivated)
			end
			DsRGuildPvPstatus.state.registredConsumers = true
		else
			if DsRGuildPvPstatus.state.registredConsumers == true then
				EVENT_MANAGER:UnregisterForEvent(DsRGuildPvPstatus.callbackName, EVENT_PLAYER_ACTIVATED)
			end
			DsRGuildPvPstatus.state.registredConsumers = false
		end
		DsRGuildPvPstatus.OnPlayerActivated()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.SetPositionLocked(value)
	DsRGuildPvP.pvp.PvPstatuspositionLocked = value
	
	DsRGuildPvPstatus.controls.TLW:SetMovable(not value)
	DsRGuildPvPstatus.controls.TLW:SetMouseEnabled(not value)
	DsRGuildPvPstatus.controls.TLW.rootControl.movableBackdrop:SetCenterColor(0, 0, 0, 0.0)
	DsRGuildPvPstatus.controls.TLW.rootControl.movableBackdrop:SetEdgeColor(0, 0, 0, 0.0)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.SetControlVisibility()
	local enabled = DsRGuildPvP.pvp.PvPstatusenabled
	local setHidden = true
	if enabled ~= nil and enabled == true and DsRGuildPvPstatus.IsInCyrodiil() == true then
		setHidden = false
	end
	if setHidden == false then
		if DsRGuildPvP.pvp.PvPstatushideOnWorldMap == false and SCENE_MANAGER ~= nil and SCENE_MANAGER.currentScene ~= nil and SCENE_MANAGER.currentScene.name == "worldMap" then
			DsRGuildPvPstatus.controls.TLW:SetHidden(false)
		elseif DsRGuildPvPstatus.state.foreground == false then
			DsRGuildPvPstatus.controls.TLW:SetHidden(DsRGuildPvPstatus.state.activeLayerIndex > 2)
		else
			DsRGuildPvPstatus.controls.TLW:SetHidden(false)
		end
	else
		DsRGuildPvPstatus.controls.TLW:SetHidden(setHidden)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.GetTextureAndOffsetForItem(keepType, rType, isPassable)
	if keepType == KEEPTYPE_KEEP then
		return DsRGuildPvPstatus.constants.textures.TEXTURE_KEEP, 3
	elseif keepType == KEEPTYPE_OUTPOST then
		return DsRGuildPvPstatus.constants.textures.TEXTURE_OUTPOST, 3
	elseif keepType == KEEPTYPE_RESOURCE then
		if rType == DsRGuildPvPcyro.constants.resourceType.FARM then
			return DsRGuildPvPstatus.constants.textures.TEXTURE_RESOURCE_FARM, -1
		elseif rType == DsRGuildPvPcyro.constants.resourceType.MINE then
			return DsRGuildPvPstatus.constants.textures.TEXTURE_RESOURCE_MINE, -1
		elseif rType == DsRGuildPvPcyro.constants.resourceType.LUMBER then
			return DsRGuildPvPstatus.constants.textures.TEXTURE_RESOURCE_LUMBER, -1
		end
	elseif keepType == KEEPTYPE_TOWN then
		return DsRGuildPvPstatus.constants.textures.TEXTURE_VILLAGE, 2
	elseif keepType == KEEPTYPE_ARTIFACT_KEEP then
		return DsRGuildPvPstatus.constants.textures.TEXTURE_TEMPLE, -2
	elseif keepType == KEEPTYPE_BRIDGE then
		if isPassable == true then
			return DsRGuildPvPstatus.constants.textures.TEXTURE_BRIDGE_PASSABLE, -2
		else
			return DsRGuildPvPstatus.constants.textures.TEXTURE_BRIDGE_NOT_PASSABLE, -2
		end
	elseif keepType == KEEPTYPE_MILEGATE then
		if isPassable == true then
			return DsRGuildPvPstatus.constants.textures.TEXTURE_MILEGATE_PASSABLE, -2
		else
			return DsRGuildPvPstatus.constants.textures.TEXTURE_MILEGATE_NOT_PASSABLE, -2
		end
	end
	return "", 0
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.SetSiegeWeapons(control, weapons)
	if weapons ~= nil and weapons > 0 then
		control:SetText(weapons)
	else
		control:SetText("")
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.FormatUnderAttackTime(underAttackFor)
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

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.UpdateEntries(itemsOfInterest)
	--d(#itemsOfInterest)
	local adColor = DsRGuildPvPstatus.GetColorForAlliance(ALLIANCE_ALDMERI_DOMINION)
	local epColor = DsRGuildPvPstatus.GetColorForAlliance(ALLIANCE_EBONHEART_PACT)
	local dcColor = DsRGuildPvPstatus.GetColorForAlliance(ALLIANCE_DAGGERFALL_COVENANT)
	local index = 1
	for i = 1, #itemsOfInterest do
		
		local itemOfInterest = itemsOfInterest[i]
		local showItem = false
		if itemOfInterest.keepType == KEEPTYPE_KEEP and DsRGuildPvP.pvp.PvPstatusshowKeeps == true then
			showItem = true
		elseif itemOfInterest.keepType == KEEPTYPE_OUTPOST and DsRGuildPvP.pvp.PvPstatusshowOutposts == true then
			showItem = true
		elseif itemOfInterest.keepType == KEEPTYPE_RESOURCE and DsRGuildPvP.pvp.PvPstatusshowResources == true then
			showItem = true
		elseif itemOfInterest.keepType == KEEPTYPE_TOWN and DsRGuildPvP.pvp.PvPstatusshowVillages == true then
			showItem = true
		elseif itemOfInterest.keepType == KEEPTYPE_ARTIFACT_KEEP and DsRGuildPvP.pvp.PvPstatusshowTemples == true then
			showItem = true
		elseif (itemOfInterest.keepType == KEEPTYPE_BRIDGE or itemOfInterest.keepType == KEEPTYPE_MILEGATE) and DsRGuildPvP.pvp.PvPstatusshowDestructibles == true then
			showItem = true
		end
		
		if showItem == true then
			local control = DsRGuildPvPstatus.state.visibleControls[index]
			control:ClearAnchors()
			control:SetAnchor(TOPLEFT, DsRGuildPvPstatus.controls.TLW.rootControl, TOPLEFT, 0, DsRGuildPvPstatus.config.entryHeight * (index - 1))
			control:SetHidden(false)
			local ac = DsRGuildPvPstatus.GetColorForAlliance(itemOfInterest.owningAlliance)
			if index % 2 == 0 then
				if DsRGuildPvP.pvp.PvPstatusshowBackground == true then
					control.backdrop:SetCenterColor(ac.r, ac.g, ac.b, 0)
				else
					control.backdrop:SetCenterColor(ac.r, ac.g, ac.b, DsRGuildPvPstatus.config.backdropAlphaEven)
				end
			else
				if DsRGuildPvP.pvp.PvPstatusshowBackground == true then
					control.backdrop:SetCenterColor(ac.r, ac.g, ac.b, 0)
				else
					control.backdrop:SetCenterColor(ac.r, ac.g, ac.b, DsRGuildPvPstatus.config.backdropAlphaOdd)
				end
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
			local texture, offset = DsRGuildPvPstatus.GetTextureAndOffsetForItem(itemOfInterest.keepType, itemOfInterest.rType, itemOfInterest.isPassable)
			control.image:SetTexture(texture)
			control.image:ClearAnchors()
			control.image:SetAnchor(TOPLEFT, control, TOPLEFT, -offset, -offset)
			control.image:SetDimensions(DsRGuildPvPstatus.config.imageWidth + offset * 2, DsRGuildPvPstatus.config.entryHeight + offset * 2)
			control.image:SetColor(ac.r, ac.g, ac.b, 1)
			control.name:SetColor(ac.r, ac.g, ac.b, 1)
			control.name:SetText(itemOfInterest.name)
			if DsRGuildPvP.pvp.PvPstatusshowSieges == true then
				if itemOfInterest.siegeWeapons ~= nil then
					DsRGuildPvPstatus.SetSiegeWeapons(control.adSiege, itemOfInterest.siegeWeapons.AD)
					DsRGuildPvPstatus.SetSiegeWeapons(control.epSiege, itemOfInterest.siegeWeapons.EP)
					DsRGuildPvPstatus.SetSiegeWeapons(control.dcSiege, itemOfInterest.siegeWeapons.DC)
					control.adSiege:SetColor(adColor.r, adColor.g, adColor.b, 1)
					control.epSiege:SetColor(epColor.r, epColor.g, epColor.b, 1)
					control.dcSiege:SetColor(dcColor.r, dcColor.g, dcColor.b, 1)
				else
					control.adSiege:SetText("")
					control.epSiege:SetText("")
					control.dcSiege:SetText("")
				end
			end
			if DsRGuildPvP.pvp.PvPstatusshowActionTimers == true then
				local underAttackFor = itemOfInterest.underAttackFor
				control.underAttackFor:SetText(DsRGuildPvPstatus.FormatUnderAttackTime(underAttackFor / 1000))
				if itemOfInterest.isCoolingDown == true then
					control.underAttackFor:SetColor(DsRGuildPvP.pvp.PvPstatuscooldownColor.r, DsRGuildPvP.pvp.PvPstatuscooldownColor.g, DsRGuildPvP.pvp.PvPstatuscooldownColor.b,1)
				else
					control.underAttackFor:SetColor(DsRGuildPvP.pvp.PvPstatusdefaultColor.r, DsRGuildPvP.pvp.PvPstatusdefaultColor.g, DsRGuildPvP.pvp.PvPstatusdefaultColor.b,1)
				end
			end
			local objectives = itemOfInterest.objectives
			if DsRGuildPvP.pvp.PvPstatusshowFlags == true then
				
				control.progress.bar1:ClearAnchors()
				control.progress.bar2:ClearAnchors()
				control.progress.bar3:ClearAnchors()
				if itemOfInterest.keepType == KEEPTYPE_KEEP or itemOfInterest.keepType == KEEPTYPE_OUTPOST then
					control.progress.bar1:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, DsRGuildPvPstatus.config.entryHeight / 2 - DsRGuildPvPstatus.config.flagHeight - 1)
					control.progress.bar2:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, DsRGuildPvPstatus.config.entryHeight / 2 + 1)
					
					control.progress.bar1:SetHidden(false)
					control.progress.bar2:SetHidden(false)
					control.progress.bar3:SetHidden(true)
					
					if objectives ~= nil and objectives[1] ~= nil and objectives[2] ~= nil then
						control.progress.bar1.progress:SetValue(objectives[1].state)
						control.progress.bar2.progress:SetValue(objectives[2].state)
						control.progress.bar1.progress:SetColor(DsRGuildPvPstatus.ColorRgbToParams(DsRGuildPvPstatus.GetColorForAlliance(objectives[1].holdingAlliance)))
						control.progress.bar2.progress:SetColor(DsRGuildPvPstatus.ColorRgbToParams(DsRGuildPvPstatus.GetColorForAlliance(objectives[2].holdingAlliance)))
					else
						control.progress.bar1.progress:SetValue(100)
						control.progress.bar2.progress:SetValue(100)
						control.progress.bar1.progress:SetColor(DsRGuildPvPstatus.ColorRgbToParams(DsRGuildPvPstatus.GetColorForAlliance(0)))
						control.progress.bar2.progress:SetColor(DsRGuildPvPstatus.ColorRgbToParams(DsRGuildPvPstatus.GetColorForAlliance(0)))
					end

					
				elseif itemOfInterest.keepType == KEEPTYPE_TOWN then
					control.progress.bar1:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, DsRGuildPvPstatus.config.entryHeight / 6 - DsRGuildPvPstatus.config.flagHeight / 2)
					control.progress.bar2:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, DsRGuildPvPstatus.config.entryHeight / 6 * 3 - DsRGuildPvPstatus.config.flagHeight / 2)
					control.progress.bar3:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, DsRGuildPvPstatus.config.entryHeight / 6 * 5 - DsRGuildPvPstatus.config.flagHeight / 2)
				
					control.progress.bar1:SetHidden(false)
					control.progress.bar2:SetHidden(false)
					control.progress.bar3:SetHidden(false)
					
					if objectives ~= nil then
						control.progress.bar1.progress:SetValue(objectives[1].state)
						control.progress.bar2.progress:SetValue(objectives[2].state)
						control.progress.bar3.progress:SetValue(objectives[3].state)
						control.progress.bar1.progress:SetColor(DsRGuildPvPstatus.ColorRgbToParams(DsRGuildPvPstatus.GetColorForAlliance(objectives[1].holdingAlliance)))
						control.progress.bar2.progress:SetColor(DsRGuildPvPstatus.ColorRgbToParams(DsRGuildPvPstatus.GetColorForAlliance(objectives[2].holdingAlliance)))
						control.progress.bar3.progress:SetColor(DsRGuildPvPstatus.ColorRgbToParams(DsRGuildPvPstatus.GetColorForAlliance(objectives[3].holdingAlliance)))
					else
						control.progress.bar1.progress:SetColor(DsRGuildPvPstatus.ColorRgbToParams(DsRGuildPvPstatus.GetColorForAlliance(0)))
						control.progress.bar2.progress:SetColor(DsRGuildPvPstatus.ColorRgbToParams(DsRGuildPvPstatus.GetColorForAlliance(0)))
						control.progress.bar3.progress:SetColor(DsRGuildPvPstatus.ColorRgbToParams(DsRGuildPvPstatus.GetColorForAlliance(0)))
					end
					
					
				elseif itemOfInterest.keepType == KEEPTYPE_RESOURCE then
					control.progress.bar1:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, DsRGuildPvPstatus.config.entryHeight / 2 - DsRGuildPvPstatus.config.flagHeight / 2)
				
					control.progress.bar1:SetHidden(false)
					control.progress.bar2:SetHidden(true)
					control.progress.bar3:SetHidden(true)
					
					if objectives ~= nil then
						control.progress.bar1.progress:SetValue(objectives[1].state)
						control.progress.bar1.progress:SetColor(DsRGuildPvPstatus.ColorRgbToParams(DsRGuildPvPstatus.GetColorForAlliance(objectives[1].holdingAlliance)))
					else
						control.progress.bar1.progress:SetColor(DsRGuildPvPstatus.ColorRgbToParams(DsRGuildPvPstatus.GetColorForAlliance(0)))
					end
				else
					control.progress.bar1:SetHidden(true)
					control.progress.bar2:SetHidden(true)
					control.progress.bar3:SetHidden(true)
				end
			end
			if DsRGuildPvP.pvp.PvPstatusshowOwnerChanges == true then
				if itemOfInterest.flipsAt ~= nil then
					local flipsIn = math.floor((itemOfInterest.flipsAt - GetGameTimeMilliseconds()) / 1000)
					if flipsIn >= 0 then
						control.flipStatus:SetText(flipsIn)
						if objectives ~= nil and objectives[1].holdingAlliance == GetUnitAlliance("player") then
							control.flipStatus:SetColor(DsRGuildPvP.pvp.PvPstatusflipsAtPositiveColor.r, DsRGuildPvP.pvp.PvPstatusflipsAtPositiveColor.g, DsRGuildPvP.pvp.PvPstatusflipsAtPositiveColor.b)
						else
							control.flipStatus:SetColor(DsRGuildPvP.pvp.PvPstatusflipsAtNegativeColor.r, DsRGuildPvP.pvp.PvPstatusflipsAtNegativeColor.g, DsRGuildPvP.pvp.PvPstatusflipsAtNegativeColor.b)
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
	for i = index, #DsRGuildPvPstatus.state.visibleControls do
		DsRGuildPvPstatus.state.visibleControls[i]:SetHidden(true)
	end

	local IconAD  = zo_iconFormat("/esoui/art/ava/ava_hud_emblem_aldmeri.dds", 26, 30)    
	local IconEP  = zo_iconFormat("/esoui/art/ava/ava_hud_emblem_ebonheart.dds", 26, 30)  
	local IconDC  = zo_iconFormat("/esoui/art/ava/ava_hud_emblem_daggerfall.dds", 26, 30) 

	local rootControl = DsRGuildPvPstatus.controls.TLW.rootControl
	local time, ADpoints, EPpoints, DCpoints, ADpopulate, DCpopulate, EPpopulate = DsRGuildPvPcyro.PvPStandStats()

	local ValStrAD = zo_strformat("<<1>><<2>>/<<3>>", IconAD, ADpopulate, ADpoints)
	local ValStrEP = zo_strformat("<<1>><<2>>/<<3>>", IconEP, EPpopulate, EPpoints)
	local ValStrDC = zo_strformat("<<1>><<2>>/<<3>>", IconDC, DCpopulate, DCpoints)

	-- rootControl.StatTime:SetText(time)
	rootControl.StatAD:SetText(ValStrAD)
	rootControl.StatEP:SetText(ValStrEP)
	rootControl.StatDC:SetText(ValStrDC)

end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.AdjustDisplayedComponents()
	local globalWidth = DsRGuildPvPstatus.config.width
	for i = 1, #DsRGuildPvPstatus.state.visibleControls do
		local offset = DsRGuildPvPstatus.config.imageWidth + 4 + DsRGuildPvPstatus.config.nameWidth
		local control = DsRGuildPvPstatus.state.visibleControls[i]
		local progress = control.progress
		progress:ClearAnchors()
		if DsRGuildPvP.pvp.PvPstatusshowFlags == true then
			progress:SetHidden(false)
			progress:SetAnchor(TOPLEFT, control, TOPLEFT, offset, 0)
			offset = offset + DsRGuildPvPstatus.config.flagWidth
		else
			progress:SetHidden(true)
		end
		local adSiege = control.adSiege
		local epSiege = control.epSiege
		local dcSiege = control.dcSiege
		adSiege:ClearAnchors()
		epSiege:ClearAnchors()
		dcSiege:ClearAnchors()
		if DsRGuildPvP.pvp.PvPstatusshowSieges == true then
			adSiege:SetHidden(false)
			adSiege:SetAnchor(TOPLEFT, control, TOPLEFT, offset, 0)
			offset = offset + DsRGuildPvPstatus.config.siegeWidth
			epSiege:SetHidden(false)
			epSiege:SetAnchor(TOPLEFT, control, TOPLEFT, offset, 0)
			offset = offset + DsRGuildPvPstatus.config.siegeWidth
			dcSiege:SetHidden(false)
			dcSiege:SetAnchor(TOPLEFT, control, TOPLEFT, offset, 0)
			offset = offset + DsRGuildPvPstatus.config.siegeWidth
		else
			adSiege:SetHidden(true)
			epSiege:SetHidden(true)
			dcSiege:SetHidden(true)
		end
		offset = offset + 10
		local flipStatus = control.flipStatus
		flipStatus:ClearAnchors()
		if DsRGuildPvP.pvp.PvPstatusshowOwnerChanges == true then
			
			flipStatus:SetHidden(false)
			flipStatus:SetAnchor(TOPLEFT, control, TOPLEFT, offset, 0)
			offset = offset + DsRGuildPvPstatus.config.flagFlipWidth
		else
			flipStatus:SetHidden(true)
		end
		offset = offset + 10
		local underAttackFor = control.underAttackFor
		if DsRGuildPvP.pvp.PvPstatusshowActionTimers == true then
			underAttackFor:SetHidden(false)
			offset = offset + DsRGuildPvPstatus.config.underAttackForWidth
		else
			underAttackFor:SetHidden(true)
		end
		globalWidth = offset
		control:SetDimensions(globalWidth, DsRGuildPvPstatus.config.entryHeight)
		control.backdrop:SetDimensions(globalWidth, DsRGuildPvPstatus.config.entryHeight)
	end
	DsRGuildPvPstatus.controls.TLW:SetDimensions(globalWidth, DsRGuildPvPstatus.config.height)
	DsRGuildPvPstatus.controls.TLW.rootControl.movableBackdrop:SetDimensions(globalWidth, DsRGuildPvPstatus.config.height)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.SaveWindowLocation()
	if DsRGuildPvP.pvp.PvPstatuspositionLocked == false then
		DsRGuildPvP.pvp.PvPstatuslocation = DsRGuildPvP.pvp.PvPstatuslocation or {}
		DsRGuildPvP.pvp.PvPstatuslocation.x = DsRGuildPvPstatus.controls.TLW:GetLeft()
		DsRGuildPvP.pvp.PvPstatuslocation.y = DsRGuildPvPstatus.controls.TLW:GetTop()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.OnPlayerActivated(eventCode, initial)
	if DsRGuildPvP.pvp.PvPstatusenabled == true and DsRGuildPvPstatus.IsInCyrodiil() == true then
		if DsRGuildPvPstatus.state.registredCyrodiilConsumers == false then
			EVENT_MANAGER:RegisterForEvent(DsRGuildPvPstatus.callbackName, EVENT_ACTION_LAYER_POPPED, DsRGuildPvPstatus.SetForegroundVisibility)
			EVENT_MANAGER:RegisterForEvent(DsRGuildPvPstatus.callbackName, EVENT_ACTION_LAYER_PUSHED, DsRGuildPvPstatus.SetForegroundVisibility)
			DsRGuildPvPcyro.AddConsumer(DsRGuildPvPstatus.callbackName, DsRGuildPvPstatus.OnUiUpdate, nil)
			DsRGuildPvPstatus.state.registredCyrodiilConsumers = true
		end
	else
		if DsRGuildPvPstatus.state.registredCyrodiilConsumers == true then
			EVENT_MANAGER:UnregisterForEvent(DsRGuildPvPstatus.callbackName, EVENT_ACTION_LAYER_POPPED)
			EVENT_MANAGER:UnregisterForEvent(DsRGuildPvPstatus.callbackName, EVENT_ACTION_LAYER_PUSHED)
			DsRGuildPvPcyro.RemoveConsumer(DsRGuildPvPstatus.callbackName)
			DsRGuildPvPstatus.state.registredCyrodiilConsumers = false
		end
	end
	DsRGuildPvPstatus.SetControlVisibility()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.OnUiUpdate(itemsOfInterest)
	if itemsOfInterest ~= nil then
		if #itemsOfInterest > #DsRGuildPvPstatus.state.visibleControls then
			for i = #DsRGuildPvPstatus.state.visibleControls + 1, #itemsOfInterest do
				local control = DsRGuildPvPstatus.CreateEntryControl(DsRGuildPvPstatus.controls.TLW.rootControl)
				control:ClearAnchors()
				control:SetAnchor(TOPLEFT, DsRGuildPvPstatus.controls.TLW.rootControl, TOPLEFT, 0, DsRGuildPvPstatus.config.entryHeight * (#DsRGuildPvPstatus.state.visibleControls + i - 1))
				control:SetHidden(false)
				table.insert(DsRGuildPvPstatus.state.visibleControls, control)
			end
			DsRGuildPvPstatus.AdjustDisplayedComponents()
		else
			for i = #itemsOfInterest + 1, #DsRGuildPvPstatus.state.visibleControls do
				DsRGuildPvPstatus.state.visibleControls[i]:SetHidden(true)
			end
		end
		DsRGuildPvPstatus.UpdateEntries(itemsOfInterest)
	else
		for i = 1, #DsRGuildPvPstatus.state.visibleControls do
			DsRGuildPvPstatus.state.visibleControls[i]:SetHidden(true)
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.SetForegroundVisibility(eventCode, layerIndex, activeLayerIndex)
	if eventCode == EVENT_ACTION_LAYER_POPPED then
		DsRGuildPvPstatus.state.foreground = true
	elseif eventCode == EVENT_ACTION_LAYER_PUSHED then
		DsRGuildPvPstatus.state.foreground = false
	end
	DsRGuildPvPstatus.state.activeLayerIndex = activeLayerIndex
	DsRGuildPvPstatus.SetControlVisibility()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.IsInCyrodiil()
	if IsInCyrodiil() == true then
		return true
	elseif IsInCyrodiil() == false and IsPlayerInAvAWorld() == true and IsInAvAZone() == true and IsInImperialCity() == false and IsActiveWorldBattleground() == false then
		return true
	else
		return false
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.ColorRgbToParams(color)
	return color.r, color.g, color.b
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.GetColorForAlliance(alliance)
	if alliance == ALLIANCE_ALDMERI_DOMINION then
		return DsRGuildPvP.Acol.DsRColorad
	elseif alliance == ALLIANCE_EBONHEART_PACT then
		return DsRGuildPvP.Acol.DsRColorep
	elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then
		return DsRGuildPvP.Acol.DsRColordc
	else
		return DsRGuildPvP.Acol.DsRColornoAlliance
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPstatus.OnAddonLoaded()
	DsRGuildPvPstatus.Initialize()
end
