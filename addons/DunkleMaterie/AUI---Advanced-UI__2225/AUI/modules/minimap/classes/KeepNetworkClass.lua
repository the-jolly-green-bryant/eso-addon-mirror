local cyrodilMapIndex = GetCyrodiilMapIndex()

AUI_KeepNetwork = ZO_Object:Subclass()
	
function AUI_KeepNetwork:New(container)
    local manager = ZO_Object.New(self)

    manager.container = container
    manager.linkPool = ZO_ControlPool:New("ZO_MapKeepLink", container, "Link")
	
    return manager
end	
	
function AUI_KeepNetwork:GetKeepNetworkOffset(linkX, linkY)
	local offsetX = linkX * AUI.MapData.mapContainerSize
	local offsetY = linkY * AUI.MapData.mapContainerSize		
	
	if AUI.Settings.Minimap.rotate then	
		local x = (offsetX - (AUI.MapData.mapContainerSize * AUI.MapData.playerX))
		local y = (offsetY - (AUI.MapData.mapContainerSize * AUI.MapData.playerY))
			
		offsetX = (math.cos(-AUI.MapData.heading) * x) - (math.sin(-AUI.MapData.heading) * y)
		offsetY = (math.sin(-AUI.MapData.heading) * x) + (math.cos(-AUI.MapData.heading) * y)			
	end
	
	return offsetX, offsetY
end	
	
function AUI_KeepNetwork:UpdateLocation(linkControl)
	local startX, startY = self:GetKeepNetworkOffset(linkControl.startNX, linkControl.startNY)
	local endX, endY = self:GetKeepNetworkOffset(linkControl.endNX, linkControl.endNY)

	linkControl:ClearAnchors()
	
	if AUI.Settings.Minimap.rotate then
		linkControl:SetAnchor(TOPLEFT, AUI_Minimap_Map_Scroll, CENTER, startX, startY)
		linkControl:SetAnchor(BOTTOMRIGHT, AUI_Minimap_Map_Scroll, CENTER, endX, endY)
	else
		ZO_Anchor_LineInContainer(linkControl, nil, startX, startY, endX, endY)	
	end
end	
	
function AUI_KeepNetwork:AddNetworkLinks()
	local linkPool = self.linkPool
	local pinManager = AUI.Minimap.Pin.GetPinManager()
	
	linkPool:ReleaseAllObjects()
	pinManager:RemovePins("restrictedLink")

	if(GetMapContentType() ~= MAP_CONTENT_AVA or GetCurrentMapIndex() ~= cyrodilMapIndex) then
		return
	end

	local showTransitLines = ZO_WorldMap_GetFilterValue(MAP_FILTER_TRANSIT_LINES) ~= false
	if(not showTransitLines) then
		return
	end

	local showOnlyMyAlliance = ZO_WorldMap_GetFilterValue(MAP_FILTER_TRANSIT_LINES_ALLIANCE) == MAP_TRANSIT_LINE_ALLIANCE_MINE

	local playerAlliance = GetUnitAlliance("player")
	local bgContext = BGQUERY_LOCAL
	local numLinks = GetNumKeepTravelNetworkLinks(bgContext)
	local historyPercent = 1.0

	for linkIndex = 1, numLinks do
		local linkType, linkOwner, restrictedToAlliance, startNX, startNY, endNX, endNY = GetHistoricalKeepTravelNetworkLinkInfo(linkIndex, bgContext, historyPercent)
		local matchesAllianceOption = not showOnlyMyAlliance or linkOwner == playerAlliance
		local r,g,b = GetAllianceColor(linkOwner):UnpackRGB()
		if(matchesAllianceOption and (pinManager:IsNormalizedPointInsideMapBounds(startNX, startNY) or pinManager:IsNormalizedPointInsideMapBounds(endNX, endNY))) then
			local linkControl, key = linkPool:AcquireObject()
			linkControl.startNX = startNX
			linkControl.startNY = startNY
			linkControl.endNX = endNX
			linkControl.endNY = endNY
			linkControl:SetHidden(false)		
			linkControl:SetColor(r, g, b, ZO_KeepNetwork.ALLIANCE_OWNER_ALPHA[linkOwner])

			if(linkType == FAST_TRAVEL_LINK_IN_COMBAT) then
				linkControl:SetTexture("EsoUI/Art/AvA/AvA_transitLine_dashed.dds")
			else
				linkControl:SetTexture("EsoUI/Art/AvA/AvA_transitLine.dds")
			end	

			self:UpdateLocation(linkControl)
			
			if(linkOwner == ALLIANCE_NONE and restrictedToAlliance ~= ALLIANCE_NONE) then
				local linkCenterX = (startNX + endNX) / 2
				local linkCenterY = (startNY + endNY) / 2

				local tag = AUI_Pin.CreateRestrictedLinkTravelNetworkPinTag(restrictedToAlliance, bgContext)
				local pinType = AUI_MINIMAP_ALLIANCE_TO_RESTRICTED_PIN_TYPE[restrictedToAlliance]
				pinManager:CreatePin(pinType, tag, linkCenterX, linkCenterY)
			end			
		end
	end
end

function AUI_KeepNetwork:RefreshLinks()
	self.AddNetworkLinks(self)
end	