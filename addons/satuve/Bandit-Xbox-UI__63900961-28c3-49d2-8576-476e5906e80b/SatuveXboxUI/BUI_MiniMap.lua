local ZOShowMapHeader

-- Dedicated minimap viewport. The gamepad world map is allowed to keep its
-- normal internal render size, but only the portion inside this scroll control
-- is visible while the minimap is active.
local function EnsureViewport()
	if not ZO_WorldMap or not ZO_WorldMapScroll then return nil end
	local viewport=rawget(_G,"BUI_MinimapViewport")
	if not viewport then
		viewport=WINDOW_MANAGER:CreateControl("BUI_MinimapViewport",rawget(_G,"BUI_Minimap") or SatuveUI,CT_SCROLL)
		viewport:SetMouseEnabled(false)
		-- Remember the original layout so the normal world map can be restored
		-- exactly after leaving minimap mode.
		BUI.MiniMap.WorldMapScrollOriginalParent=ZO_WorldMapScroll:GetParent()
		BUI.MiniMap.WorldMapScrollOriginalWidth=ZO_WorldMapScroll:GetWidth()
		BUI.MiniMap.WorldMapScrollOriginalHeight=ZO_WorldMapScroll:GetHeight()
		BUI.MiniMap.WorldMapScrollOriginalAnchors={}
		local count=ZO_WorldMapScroll:GetNumAnchors() or 0
		for i=0,count-1 do
			local point,relativeTo,relativePoint,offsetX,offsetY=ZO_WorldMapScroll:GetAnchor(i)
			table.insert(BUI.MiniMap.WorldMapScrollOriginalAnchors,{point,relativeTo,relativePoint,offsetX,offsetY})
		end
	end
	return viewport
end

local function AttachMapToViewport()
	local viewport=EnsureViewport()
	if not viewport or not ZO_WorldMapScroll then return end
	local size=tonumber(BUI.MiniMap.size) or 250
	size=math.max(200,math.min(500,size))

	-- Move only our own addon-created viewport between layouts. Once the stock
	-- ZO_WorldMapScroll has been placed inside the viewport, never SetParent()
	-- that protected ZOS control again. Re-parenting it while disabling the
	-- minimap can trigger "private function SetParent from insecure code".
	local minimapParent=rawget(_G,"BUI_Minimap") or SatuveUI
	if minimapParent and viewport:GetParent()~=minimapParent then
		viewport:SetParent(minimapParent)
	end
	viewport:SetDimensions(size,size)
	viewport:ClearAnchors()
	viewport:SetAnchor(TOPLEFT,minimapParent,TOPLEFT,0,0)
	viewport:SetHidden(false)

	-- This protected-control parent change is required only once, when viewport
	-- mode is first initialized. Restore/disable no longer changes its parent.
	if ZO_WorldMapScroll:GetParent()~=viewport then
		ZO_WorldMapScroll:SetParent(viewport)
	end
	-- Do not resize ESO's stock scroll control here. Its dimensions define the
	-- coordinate system used by the stock tile and pan/zoom managers. Forcing a
	-- different size made the minimap tiles/pins disagree with the normal map.
	-- Only the addon-owned viewport is sized; ESO keeps its native map geometry.
	ZO_WorldMapScroll:ClearAnchors()
	ZO_WorldMapScroll:SetAnchor(CENTER,viewport,CENTER,BUI.MiniMap.ViewportOffsetX or 0,BUI.MiniMap.ViewportOffsetY or 0)
end

local function DetachMapFromViewport()
	local viewport=rawget(_G,"BUI_MinimapViewport")
	if not viewport or not ZO_WorldMapScroll then return end

	-- Do NOT SetParent() on ZO_WorldMapScroll here. ESO can mark SetParent as
	-- private for this protected stock control. The stock map content therefore
	-- stays inside our addon-owned viewport for the whole session.
	local parent=ZO_WorldMap or BUI.MiniMap.WorldMapScrollOriginalParent
	if parent and viewport:GetParent()~=parent then
		viewport:SetParent(parent)
	end

	-- In full-map mode our addon-owned viewport simply fills the stock World Map.
	-- This avoids trying to reuse the original scroll-control anchors (which are
	-- not necessarily valid for a CT_SCROLL wrapper) and makes the Back-button map
	-- visible again without touching the protected ZO_WorldMapScroll parent.
	viewport:ClearAnchors()
	if ZO_WorldMap then
		viewport:SetAnchor(TOPLEFT,ZO_WorldMap,TOPLEFT,0,0)
		viewport:SetAnchor(BOTTOMRIGHT,ZO_WorldMap,BOTTOMRIGHT,0,0)
	else
		viewport:SetAnchor(CENTER,parent,CENTER,0,0)
		local w=BUI.MiniMap.WorldMapScrollOriginalWidth
		local h=BUI.MiniMap.WorldMapScrollOriginalHeight
		if w and h and w>0 and h>0 then viewport:SetDimensions(w,h) end
	end
	viewport:SetHidden(false)
	viewport:SetAlpha(1)

	local w,h
	if ZO_WorldMap then w,h=ZO_WorldMap:GetDimensions() end
	if not w or not h or w<=0 or h<=0 then
		w=BUI.MiniMap.WorldMapScrollOriginalWidth
		h=BUI.MiniMap.WorldMapScrollOriginalHeight
	end
	if w and h and w>0 and h>0 then
		ZO_WorldMapScroll:SetDimensions(w,h)
	end

	ZO_WorldMapScroll:ClearAnchors()
	ZO_WorldMapScroll:SetAnchor(CENTER,viewport,CENTER,0,0)
	ZO_WorldMapScroll:SetHidden(false)
	ZO_WorldMapScroll:SetAlpha(1)

	BUI.MiniMap.ViewportOffsetX=0
	BUI.MiniMap.ViewportOffsetY=0
	BUI.MiniMap.FollowX=nil
	BUI.MiniMap.FollowY=nil
end



-- Hide only the original world-map frame/chrome while the minimap viewport is
-- active. The actual map scroll control is re-parented into BUI_MinimapViewport,
-- so hiding the old frame removes the large translucent background without
-- touching the map content or the quest tracker.
local function SetViewportChromeHidden(hidden)
	local frame=rawget(_G,"ZO_WorldMapMapFrame")
	if frame then frame:SetHidden(hidden) end
	for _,name in ipairs({
		"ZO_WorldMapMapFrameBottomMunge",
		"ZO_WorldMapMapFrameTopMunge",
		"ZO_WorldMapMapFrameLeftMunge",
		"ZO_WorldMapMapFrameRightMunge",
	}) do
		local control=rawget(_G,name)
		if control then control:SetHidden(hidden) end
	end
end

local function UpdateDimensions()
	-- The selected size is the visible viewport size. Do not shrink the internal
	-- world-map renderer itself; render it behind a clipped square window.
	local size=tonumber(BUI.MiniMap.size) or 250
	size=math.max(200,math.min(500,size))

	-- Keep ESO's full WorldMap root at its native size. The minimap uses its own
	-- viewport parent, so the large root never needs to be resized or rendered.
	AttachMapToViewport()
end

local function SetSize(value)
	local size=tonumber(value)
	if not size then return end

	-- Keep controller dropdown, keyboard slider and saved variables on the same
	-- legal 20-pixel steps. LibGamepad may pass finite-list values as strings.
	size=math.max(200,math.min(500,math.floor((size+10)/20)*20))
	BUI.Vars.MiniMapDimensions=size
	BUI.MiniMap.size=size

	-- Resize the existing controls immediately. ReInit registers scene/event
	-- callbacks, so using it for every size change can duplicate callbacks and
	-- can leave the already-created world-map controls at their old dimensions.
	local container=rawget(_G,"BUI_Minimap")
	if container then container:SetDimensions(size,size) end
	local backdrop=rawget(_G,"BUI_Minimap_B")
	if backdrop then backdrop:SetDimensions(size,size) end
	local label=rawget(_G,"BUI_Minimap_L")
	if label then label:SetDimensions(size,size) end
	UpdateDimensions()

	if ZO_FocusedQuestTrackerPanel and not BUI.Vars.ZO_FocusedQuestTrackerPanel then
		ZO_FocusedQuestTrackerPanel:ClearAnchors()
		ZO_FocusedQuestTrackerPanel:SetAnchor(TOPRIGHT,GuiRoot,TOPRIGHT,0,size+20)
	end

	if BUI.init.MiniMap and BUI.MiniMap.MapPanAndZoom and BUI.MiniMap.PinManager then
		BUI.MiniMap.ZoneChanged()
	end
end

local function ApplyTransparency()
	local alpha=(tonumber(BUI.Vars.MiniMapAlpha) or 100)/100
	alpha=math.max(0,math.min(1,alpha))

	-- Do not fade the full gamepad world-map root or its native scroll control.
	-- ESO composites those controls at their full internal size before the
	-- minimap viewport clips them, which creates the large dark/translucent
	-- rectangle seen behind the HUD. Fade only our small clipped viewport.
	if ZO_WorldMap then ZO_WorldMap:SetAlpha(1) end
	if ZO_WorldMapScroll then ZO_WorldMapScroll:SetAlpha(1) end
	local viewport=rawget(_G,"BUI_MinimapViewport")
	if viewport then viewport:SetAlpha(alpha) end

	-- The Bandits minimap backdrop is not part of the map image and must not
	-- receive the transparency value; otherwise its black center becomes a
	-- visible shadow. Keep it fully transparent while the viewport is active.
	local backdrop=rawget(_G,"BUI_Minimap_B")
	if backdrop then backdrop:SetAlpha(0) end
end

local function SetAuxiliaryUIHidden(hidden)
	-- Disabled for safety. Traversing the gamepad UI/control tree can touch
	-- protected ZOS controls/functions and taint the UI, causing private-function
	-- errors. Quest tracker and all other HUD elements are left untouched.
	-- Switch Elevation is therefore not modified by this helper.
	return
end

local function EnsurePlayerPinVisible()
	-- The gamepad world-map refresh can leave the player's own map pin hidden
	-- after the minimap is re-centered. Touch only the existing player pin; do
	-- not rebuild pins or modify any other map/UI controls.
	if not BUI.MiniMap.PinManager then return end
	local pin=BUI.MiniMap.PinManager:GetPlayerPin()
	if not pin then return end
	local control=pin:GetControl()
	if control then
		control:SetHidden(false)
		control:SetAlpha(1)
	end
end

local function GetLivePlayerMapPosition()
	-- ESO's native map position uses exactly the same coordinate system as the
	-- active map tiles and player pin. Prefer it so the minimap and full map cannot
	-- disagree because of projection/hierarchy differences on zone and local maps.
	local nativeX,nativeY=GetMapPlayerPosition("player")
	if nativeX and nativeY and nativeX>=0 and nativeX<=1 and nativeY>=0 and nativeY<=1
		and (nativeX>0 or nativeY>0) then
		return nativeX,nativeY
	end

	-- Some transitioning instances briefly provide no native map position. Only in
	-- that case derive a temporary position from universal world coordinates.
	if GetUnitWorldPosition and GetNormalizedWorldPosition and GetUniversallyNormalizedMapInfo and GetCurrentMapId then
		local zoneId,worldX,worldY,worldZ=GetUnitWorldPosition("player")
		local mapId=GetCurrentMapId()
		if zoneId and mapId and mapId>0 then
			local worldNX,worldNY=GetNormalizedWorldPosition(zoneId,worldX,worldY,worldZ)
			local mapX,mapY,mapW,mapH=GetUniversallyNormalizedMapInfo(mapId)
			if worldNX and worldNY and mapX and mapY and mapW and mapH and mapW>0 and mapH>0 then
				local x=(worldNX-mapX)/mapW
				local y=(worldNY-mapY)/mapH
				if x>=0 and x<=1 and y>=0 and y<=1 then return x,y end
			end
		end
	end

	return nativeX,nativeY
end

local function CenterOnPlayer(x,y,heading)
	if not BUI.init.MiniMap or not BUI.MiniMap.PinManager then return end
	local viewport=rawget(_G,"BUI_MinimapViewport")
	if not viewport or not ZO_WorldMapScroll then return end

	x=x or nil
	y=y or nil
	if not x or not y then x,y=BUI.MiniMap.GetLivePlayerMapPosition() end
	if not x or not y then return end

	local pin=BUI.MiniMap.PinManager:GetPlayerPin()
	local control=pin and pin:GetControl() or nil

	-- Derive a fresh absolute offset every update. The old implementation added
	-- player movement deltas to the previous offset, so any stale map geometry or
	-- scene-transition correction became permanent drift. ZO_WorldMapContainer's
	-- dimensions include the current zoom and its centre includes ESO's internal
	-- map margins/pan. Remove only our current outer scroll translation, calculate
	-- the player's zero-offset screen position, then solve the required translation.
	local mapControl=rawget(_G,"ZO_WorldMapContainer")
	if not mapControl then return end
	local mapW,mapH=mapControl:GetDimensions()
	local mapCX,mapCY=mapControl:GetCenter()
	local viewCX,viewCY=viewport:GetCenter()
	local scrollCX,scrollCY=ZO_WorldMapScroll:GetCenter()
	if not mapW or not mapH or mapW<=0 or mapH<=0
		or not mapCX or not mapCY or not viewCX or not viewCY then return end

	local appliedOffsetX=(scrollCX and viewCX) and (scrollCX-viewCX) or 0
	local appliedOffsetY=(scrollCY and viewCY) and (scrollCY-viewCY) or 0
	local zeroOffsetMapCX=mapCX-appliedOffsetX
	local zeroOffsetMapCY=mapCY-appliedOffsetY
	local playerAtZeroX=zeroOffsetMapCX+(x-0.5)*mapW
	local playerAtZeroY=zeroOffsetMapCY+(y-0.5)*mapH

	BUI.MiniMap.ViewportOffsetX=viewCX-playerAtZeroX
	BUI.MiniMap.ViewportOffsetY=viewCY-playerAtZeroY
	BUI.MiniMap.FollowX=x
	BUI.MiniMap.FollowY=y

	ZO_WorldMapScroll:ClearAnchors()
	ZO_WorldMapScroll:SetAnchor(CENTER,viewport,CENTER,BUI.MiniMap.ViewportOffsetX or 0,BUI.MiniMap.ViewportOffsetY or 0)

	-- Keep the player marker visually fixed in the exact viewport center. Other
	-- pins remain attached to the map and move underneath it normally.
	if control then
		control:ClearAnchors()
		control:SetAnchor(CENTER,viewport,CENTER,0,0)
		control:SetHidden(false)
		control:SetAlpha(1)

		-- Rotate only the player marker. GetMapPlayerPosition() can return a
		-- stale heading while the full world-map scene is hidden (the same reason
		-- its x/y position can freeze). GetPlayerCameraHeading() is live in the HUD,
		-- so use it directly for the minimap arrow instead of preferring map heading.
		heading=heading or (GetPlayerCameraHeading and GetPlayerCameraHeading() or nil)
		if heading then
			local rotationControl=control
			-- Most ESO player pins are texture controls. If this UI version wraps the
			-- texture in a control, try the known texture/icon children without
			-- traversing the UI tree or touching protected globals.
			if not rotationControl.SetTextureRotation and rotationControl.GetNamedChild then
				rotationControl=rotationControl:GetNamedChild("Texture")
					or rotationControl:GetNamedChild("Icon")
					or rotationControl:GetNamedChild("Background")
			end
			if rotationControl and rotationControl.SetTextureRotation then
				rotationControl:SetTextureRotation(heading)
			end
		end
	end
end

local TWO_PI=math.pi*2
local POSITION_SMOOTH_SPEED=12
local ROTATION_SMOOTH_SPEED=14
local ZOOM_SMOOTH_SPEED=8
local LARGE_POSITION_JUMP_SQUARED=0.005625 -- 7.5 percent of the current map

local function NormalizeAngle(angle)
	if not angle then return 0 end
	return angle%TWO_PI
end

local function ShortestAngleDelta(fromAngle,toAngle)
	return (toAngle-fromAngle+math.pi)%TWO_PI-math.pi
end

local function ResetSmoothState()
	BUI.MiniMap.DisplayX=nil
	BUI.MiniMap.DisplayY=nil
	BUI.MiniMap.DisplayHeading=nil
	BUI.MiniMap.LastSmoothUpdateMs=nil
	BUI.MiniMap.FollowX=nil
	BUI.MiniMap.FollowY=nil
end

local function SnapMinimapToPlayer()
	local x,y=BUI.MiniMap.GetLivePlayerMapPosition()
	if not x or not y then return false end
	local heading=GetPlayerCameraHeading and GetPlayerCameraHeading() or 0
	BUI.MiniMap.DisplayX=x
	BUI.MiniMap.DisplayY=y
	BUI.MiniMap.DisplayHeading=NormalizeAngle(heading)
	BUI.MiniMap.LastSmoothUpdateMs=GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or nil
	BUI.MiniMap.CenterOnPlayer(x,y,BUI.MiniMap.DisplayHeading)
	return true
end

local function UpdateSmoothVisuals()
	if not BUI.init.MiniMap or BUI.MiniMap.MapSceneIsShowing or BUI.MiniMap.CombatHidden then return end

	local targetX,targetY=BUI.MiniMap.GetLivePlayerMapPosition()
	if not targetX or not targetY then return end
	local targetHeading=NormalizeAngle(GetPlayerCameraHeading and GetPlayerCameraHeading() or 0)
	local now=GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
	local last=BUI.MiniMap.LastSmoothUpdateMs
	local deltaTime=(last and now>last) and math.min((now-last)/1000,0.1) or 0.033
	BUI.MiniMap.LastSmoothUpdateMs=now

	if not BUI.MiniMap.DisplayX or not BUI.MiniMap.DisplayY or not BUI.MiniMap.DisplayHeading then
		BUI.MiniMap.DisplayX=targetX
		BUI.MiniMap.DisplayY=targetY
		BUI.MiniMap.DisplayHeading=targetHeading
	else
		local dx=targetX-BUI.MiniMap.DisplayX
		local dy=targetY-BUI.MiniMap.DisplayY
		if dx*dx+dy*dy>=LARGE_POSITION_JUMP_SQUARED then
			-- Teleports and large coordinate discontinuities must never fly across the map.
			BUI.MiniMap.DisplayX=targetX
			BUI.MiniMap.DisplayY=targetY
			BUI.MiniMap.DisplayHeading=targetHeading
		else
			local positionAlpha=1-math.exp(-POSITION_SMOOTH_SPEED*deltaTime)
			local rotationAlpha=1-math.exp(-ROTATION_SMOOTH_SPEED*deltaTime)
			BUI.MiniMap.DisplayX=BUI.MiniMap.DisplayX+dx*positionAlpha
			BUI.MiniMap.DisplayY=BUI.MiniMap.DisplayY+dy*positionAlpha
			BUI.MiniMap.DisplayHeading=NormalizeAngle(BUI.MiniMap.DisplayHeading+ShortestAngleDelta(BUI.MiniMap.DisplayHeading,targetHeading)*rotationAlpha)
		end
	end

	-- Only zoom values requested by a profile/mount change are animated here.
	-- Map selection, environment detection and pin/map rebuilding remain event based.
	if BUI.MiniMap.TargetZoom and BUI.MiniMap.CurrentZoom
		and math.abs(BUI.MiniMap.TargetZoom-BUI.MiniMap.CurrentZoom)>0.0001 then
		local zoomAlpha=1-math.exp(-ZOOM_SMOOTH_SPEED*deltaTime)
		BUI.MiniMap.CurrentZoom=BUI.MiniMap.CurrentZoom+(BUI.MiniMap.TargetZoom-BUI.MiniMap.CurrentZoom)*zoomAlpha
		if math.abs(BUI.MiniMap.TargetZoom-BUI.MiniMap.CurrentZoom)<0.0005 then
			BUI.MiniMap.CurrentZoom=BUI.MiniMap.TargetZoom
		end
		BUI.MiniMap.MapPanAndZoom:SetCurrentNormalizedZoomInternal(BUI.MiniMap.CurrentZoom)
	end

	BUI.MiniMap.CenterOnPlayer(BUI.MiniMap.DisplayX,BUI.MiniMap.DisplayY,BUI.MiniMap.DisplayHeading)
	local delta=math.floor(math.abs((BUI.MiniMap.LastX1-targetX)^2+(BUI.MiniMap.LastY1-targetY)^2)*100000)
	if delta>=(BUI.MiniMap.Subzone and 100 or 9) then
		BUI.MiniMap.LastX1=targetX
		BUI.MiniMap.LastY1=targetY
		CALLBACK_MANAGER:FireCallbacks("BUI_MiniMap_Update",true)
	end
end

local function ScheduleFreshRecenter(delay)
	-- BUI.CallLater uses a stable update name, so repeated scene/map events replace
	-- this callback instead of stacking multiple delayed offsets.
	BUI.CallLater("SXUI_MinimapFreshRecenter",delay or 100,function()
		if BUI.init.MiniMap and not BUI.MiniMap.MapSceneIsShowing then
			BUI.MiniMap.UpdateDimensions()
			BUI.MiniMap.SnapMinimapToPlayer()
			BUI.MiniMap.EnsurePlayerPinVisible()
		end
	end)
end

local function StabilizeMapViewport(expectedMapId)
	if not BUI.init.MiniMap or BUI.MiniMap.MapSceneIsShowing then return end
	if expectedMapId and GetCurrentMapId and GetCurrentMapId()~=expectedMapId then return end

	-- ESO's OnWorldMapChanged chain initializes the tile set and pan/zoom geometry.
	-- Re-assert only the addon viewport after that stock initialization has settled.
	BUI.MiniMap.UpdateDimensions()
	if ZO_WorldMap then ZO_WorldMap:SetHidden(true) end
	if ZO_WorldMapScroll then
		ZO_WorldMapScroll:SetHidden(false)
		ZO_WorldMapScroll:SetAlpha(1)
	end
	local container=rawget(_G,"BUI_Minimap")
	local viewport=rawget(_G,"BUI_MinimapViewport")
	if container then container:SetHidden(false) end
	if viewport then viewport:SetHidden(false) end
	BUI.MiniMap.SetViewportChromeHidden(true)
	BUI.MiniMap.ApplyTransparency()
	BUI.MiniMap.SnapMinimapToPlayer()
	BUI.MiniMap.EnsurePlayerPinVisible()
end

local function ScheduleMapViewportStabilization(mapId)
	-- One early and one late geometry pass handles asynchronous gamepad layout and
	-- texture setup without rebuilding the full map in the smooth 33 ms loop.
	BUI.CallLater("SXUI_MinimapMapGeometryEarly",60,function()
		if BUI.MiniMap.StabilizeMapViewport then BUI.MiniMap.StabilizeMapViewport(mapId) end
	end)
	BUI.CallLater("SXUI_MinimapMapGeometryLate",250,function()
		if BUI.MiniMap.StabilizeMapViewport then BUI.MiniMap.StabilizeMapViewport(mapId) end
	end)
end

local function UpdatePosition()
	ZO_WorldMap:ClearAnchors()
	ZO_WorldMap:SetAnchor(BUI.Vars.BUI_Minimap[1],nil,BUI.Vars.BUI_Minimap[2],BUI.Vars.BUI_Minimap[3],BUI.Vars.BUI_Minimap[4])
end

local function GetMinimapEnvironment()
	local mapType=GetMapType and GetMapType() or MAPTYPE_NONE
	local contentType=GetMapContentType and GetMapContentType() or MAP_CONTENT_NONE
	-- Prefer the live unit state over cached map metadata. In particular, an old
	-- dungeon texture must not keep the DUNGEON profile after the player left it.
	local isDungeon
	if IsUnitInDungeon then isDungeon=IsUnitInDungeon("player")
	else isDungeon=contentType==MAP_CONTENT_DUNGEON end
	local mapMatchesPlayer=DoesCurrentMapMatchMapForPlayerLocation and DoesCurrentMapMatchMapForPlayerLocation()

	if isDungeon then return "DUNGEON",mapType,contentType end
	if mapMatchesPlayer==false then return "WORLD",mapType,contentType end
	if mapType==MAPTYPE_SUBZONE then return "INTERIOR",mapType,contentType end
	-- Safe fallback: once the player is no longer in a dungeon or local/subzone
	-- map, never retain the previous local environment just because ESO cached it.
	return "WORLD",mapType,contentType
end

local function ZoomUpdate(mounted,snapZoom)
	if not BUI.MiniMap.MapPanAndZoom then return end
	mounted=mounted or IsMounted()
	local zoom
	local ratio=mounted and BUI.Vars.ZoomMountRatio/100 or 1
	local environment,mapType,content=BUI.MiniMap.GetMinimapEnvironment()

	if environment=="DUNGEON" then
		BUI.MiniMap.Subzone=false
		zoom=BUI.Vars.ZoomDungeon
	elseif environment=="INTERIOR" then
		local zonename=string.match(tostring(GetMapTileTexture()), "%w+/%w+/%w+/(%w+)")
		if zonename=="Imperialsewers" then
			BUI.MiniMap.Subzone=false zoom=BUI.Vars.ZoomImperialsewer
		elseif zonename=="imperialcity" then
			BUI.MiniMap.Subzone=false zoom=BUI.Vars.ZoomImperialCity
		else
			BUI.MiniMap.Subzone=true zoom=BUI.Vars.ZoomSubZone
		end
	else
		BUI.MiniMap.Subzone=false
		if content==MAP_CONTENT_AVA then
			zoom=BUI.Vars.ZoomCyrodiil
		else
			zoom=BUI.Vars.ZoomZone
		end
	end

	local targetZoom=zoom/100*ratio
	BUI.MiniMap.TargetZoom=targetZoom
	if snapZoom or not BUI.MiniMap.CurrentZoom then
		BUI.MiniMap.CurrentZoom=targetZoom
		BUI.MiniMap.MapPanAndZoom:SetCurrentNormalizedZoomInternal(targetZoom)
	end
	local pin=BUI.MiniMap.PinManager:GetPlayerPin()
	if pin then BUI.MiniMap.MapPanAndZoom:JumpToPin(pin, true) end
	BUI.MiniMap.ViewportOffsetX=0
	BUI.MiniMap.ViewportOffsetY=0
	BUI.MiniMap.FollowX=nil
	BUI.MiniMap.FollowY=nil
	BUI.MiniMap.UpdateDimensions()
	ScheduleFreshRecenter(30)
end
--	/script ZO_WorldMap_GetPanAndZoom():SetCurrentNormalizedZoomInternal(1)
--	/script local pin=ZO_WorldMap_GetPinManager():GetPlayerPin() ZO_WorldMap_GetPanAndZoom():PanToPin(pin, true)
local function OnMount(eventCode,mounted)
	if not BUI.init.MiniMap or BUI.MiniMap.ZoomUpdatind then return end
	BUI.MiniMap.ZoomUpdate(mounted,false)
end

local function ScheduleMapContextRefresh(delay,reason,snap)
	BUI.MiniMap.PendingContextRefresh=true
	BUI.MiniMap.PendingContextReason=reason or "DELAYED"
	BUI.MiniMap.PendingContextSnap=snap~=false
	BUI.CallLater("SXUI_MinimapContextRefresh",delay or 100,function()
		if BUI.Vars.MiniMap and BUI.MiniMap.RefreshMapContext then
			BUI.MiniMap.RefreshMapContext(BUI.MiniMap.PendingContextReason,BUI.MiniMap.PendingContextSnap)
		end
	end)
end

local function RefreshMapContext(reason,snap)
	if not BUI.Vars.MiniMap or BUI.MiniMap.ContextRefreshInProgress then return false end
	if BUI.MiniMap.MapSceneIsShowing then
		BUI.MiniMap.PendingContextRefresh=true
		return false
	end

	BUI.MiniMap.ContextRefreshInProgress=true
	local previousMapId=BUI.MiniMap.CurrentMapId
	local previousEnvironment=BUI.MiniMap.Environment
	local matchedBefore=DoesCurrentMapMatchMapForPlayerLocation and DoesCurrentMapMatchMapForPlayerLocation() or false
	local result=SetMapToPlayerLocation and SetMapToPlayerLocation() or nil
	if SET_MAP_RESULT_FAILED and result==SET_MAP_RESULT_FAILED then
		BUI.MiniMap.ContextRefreshInProgress=false
		-- Map data can be briefly unavailable while a loading screen settles.
		ScheduleMapContextRefresh(250,"RETRY_"..tostring(reason or "UNKNOWN"),true)
		return false
	end
	local mapId=GetCurrentMapId and GetCurrentMapId() or 0
	local environment=BUI.MiniMap.GetMinimapEnvironment()
	local mapChanged=previousMapId~=mapId
	local environmentChanged=previousEnvironment~=environment

	BUI.MiniMap.CurrentMapId=mapId
	BUI.MiniMap.Environment=environment
	BUI.MiniMap.LastContextReason=reason or "UNKNOWN"
	BUI.MiniMap.PendingContextRefresh=false

	-- SetMapToPlayerLocation changes only the API map identity. ESO normally follows
	-- it by firing OnWorldMapChanged, whose stock callbacks rebuild map tiles, pins
	-- and pan/zoom geometry. Calling ZO_WorldMap_UpdateMap directly skipped the stock
	-- pan/zoom initialization, producing blank delve maps and half-clipped world maps.
	-- This complete rebuild remains event-driven and never runs in the 33 ms loop.
	local setChanged=SET_MAP_RESULT_MAP_CHANGED and result==SET_MAP_RESULT_MAP_CHANGED
	if CALLBACK_MANAGER and (mapChanged or environmentChanged or setChanged or not matchedBefore or reason) then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	end

	BUI.MiniMap.ViewportOffsetX=0
	BUI.MiniMap.ViewportOffsetY=0
	BUI.MiniMap.ResetSmoothState()
	BUI.MiniMap.ZoomUpdate(nil,snap~=false or mapChanged or environmentChanged)

	if BUI.init.MiniMap then
		BUI.MiniMap.UpdateDimensions()
		BUI.MiniMap.SnapMinimapToPlayer()
		BUI.MiniMap.EnsurePlayerPinVisible()
	end
	ScheduleMapViewportStabilization(mapId)

	BUI.MiniMap.ContextRefreshInProgress=false
	return true
end

local function SetCombatHidden(hidden)
	-- The minimap remains visible and keeps tracking during combat. Retain this
	-- compatibility entry point for callers from older versions, but never hide.
	BUI.MiniMap.CombatHidden=false
end

local function OnMinimapCombatState(eventCode,inCombat)
	BUI.MiniMap.SetCombatHidden(inCombat)
end

local function ReInit()
	local function OnHUD(oldState, newState)
		if BUI.moveDefault or BUI.move then return end
		if newState==SCENE_HIDDEN then BUI.CallLater("MiniMap",20,function()
				if not BUI.MiniMap.BUI_MINIMAP_SCENE_NAMES[SCENE_MANAGER:GetCurrentSceneName()] then
					if BUI.init.MiniMap then ZO_WorldMap:SetHidden(true) _G["ZO_WorldMapMapFrame"]:SetHidden(true) end
				end
			end)
		elseif newState==SCENE_SHOWING then
			if BUI.init.MiniMap then
				-- The old Bandits behavior restored the full WorldMap root whenever the
				-- HUD scene became visible. With the dedicated minimap viewport this
				-- produces the large black/full-size map when opening or closing menus.
				-- Keep the full root hidden and re-assert only the clipped viewport.
				BUI.CallLater("SXUI_MinimapMenuViewport",20,function()
					if BUI.init.MiniMap and not BUI.MiniMap.MapSceneIsShowing and not BUI.MiniMap.CombatHidden then
						BUI.MiniMap.UpdateDimensions()
						if ZO_WorldMap then ZO_WorldMap:SetHidden(true) end
						if ZO_WorldMapScroll then ZO_WorldMapScroll:SetHidden(false) end
						local viewport=rawget(_G,"BUI_MinimapViewport")
						if viewport then viewport:SetHidden(false) end
						BUI.MiniMap.SetViewportChromeHidden(true)
						BUI.MiniMap.ApplyTransparency()
						ScheduleFreshRecenter(75)
					end
				end)
			else
				BUI.MiniMap.Show()
			end
		end
	end
	BUI.MiniMap.HUDSceneCallback=BUI.MiniMap.HUDSceneCallback or OnHUD
	OnHUD=BUI.MiniMap.HUDSceneCallback

	local function WorldSceneChanged(oldState, newState)
		if newState==SCENE_SHOWING then
			BUI.MiniMap.MapSceneIsShowing=true
			if BUI.init.MiniMap then BUI.MiniMap.Restore() else BUI.MiniMap.DetachMapFromViewport() end
		elseif newState==SCENE_SHOWN then
			-- Scene dimensions are final only after SHOWN. Re-apply the full-map
			-- viewport once so the stock map fills the complete map area.
			BUI.MiniMap.DetachMapFromViewport()
			if ZO_WorldMap then ZO_WorldMap:SetHidden(false) end
			BUI.MiniMap.SetViewportChromeHidden(false)
		elseif newState==SCENE_HIDDEN then
			BUI.CallLater("MiniMap",100,function()
				BUI.MiniMap.MapSceneIsShowing=false
				if BUI.Vars.MiniMap then
					BUI.MiniMap.RefreshMapContext("WORLD_MAP_CLOSED",true)
					BUI.MiniMap.Show()
				end
			end)
		end
	end
	BUI.MiniMap.WorldSceneCallback=BUI.MiniMap.WorldSceneCallback or WorldSceneChanged
	WorldSceneChanged=BUI.MiniMap.WorldSceneCallback

	-- The Back button opens GAMEPAD_WORLD_MAP_SCENE, not WORLD_MAP_SCENE.
	-- Without this callback the minimap update loop still thinks no map scene is
	-- open and immediately hides ZO_WorldMap, leaving the gamepad map page blank.
	-- Register once and keep it available even if the minimap is later disabled,
	-- because ZO_WorldMapScroll remains permanently inside our safe viewport.
	if GAMEPAD_WORLD_MAP_SCENE and not BUI.MiniMap.GamepadWorldSceneCallback then
		BUI.MiniMap.GamepadWorldSceneCallback=function(oldState,newState)
			if newState==SCENE_SHOWING then
				BUI.MiniMap.MapSceneIsShowing=true
				if BUI.init.MiniMap then BUI.MiniMap.Restore() else BUI.MiniMap.DetachMapFromViewport() end
				if ZO_WorldMap then ZO_WorldMap:SetHidden(false) end
				BUI.MiniMap.SetViewportChromeHidden(false)
			elseif newState==SCENE_SHOWN then
				BUI.MiniMap.DetachMapFromViewport()
				if ZO_WorldMap then ZO_WorldMap:SetHidden(false) end
				if ZO_WorldMapScroll then ZO_WorldMapScroll:SetHidden(false) end
				BUI.MiniMap.SetViewportChromeHidden(false)
				if ZO_WorldMap_UpdateMap then ZO_WorldMap_UpdateMap() end
			elseif newState==SCENE_HIDDEN then
				BUI.CallLater("SXUI_GamepadMapClosed",100,function()
					BUI.MiniMap.MapSceneIsShowing=false
					if BUI.Vars.MiniMap then
						BUI.MiniMap.RefreshMapContext("GAMEPAD_WORLD_MAP_CLOSED",true)
						BUI.MiniMap.Show()
					end
				end)
			end
		end
		GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange",BUI.MiniMap.GamepadWorldSceneCallback)
	end

	EVENT_MANAGER:RegisterForEvent("BUI_MiniMap_Event", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,	function(_,gamepadPreferred)
		BUI.MiniMap.ReInit()
	end)

	BUI.MiniMap.PinColors()
	if not BUI.Vars.MiniMap then
		if BUI.init.MiniMap then
			BUI.MiniMap.Restore()
			ZO_WorldMap:SetHidden(true)
			_G["ZO_WorldMapMapFrame"]:SetHidden(true)
			if not BUI.Vars.ZO_FocusedQuestTrackerPanel then
				ZO_FocusedQuestTrackerPanel:ClearAnchors() ZO_FocusedQuestTrackerPanel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, 0, 60)
			end
--			EVENT_MANAGER:UnregisterForEvent("BUI_Minimap", EVENT_RETICLE_HIDDEN_UPDATE)
			EVENT_MANAGER:UnregisterForEvent("BUI_Minimap", EVENT_SCREEN_RESIZED)
			EVENT_MANAGER:UnregisterForEvent("BUI_Minimap", EVENT_MOUNTED_STATE_CHANGED)
			for scene in pairs(BUI.MiniMap.BUI_MINIMAP_SCENE_NAMES) do
				local sceneObject=SCENE_MANAGER:GetScene(scene)
				if sceneObject then sceneObject:UnregisterCallback("StateChange",BUI.MiniMap.HUDSceneCallback) end
			end
			if BUI.MiniMap.WorldMapChangedCallback then CALLBACK_MANAGER:UnregisterCallback("OnWorldMapChanged",BUI.MiniMap.WorldMapChangedCallback) end
			WORLD_MAP_SCENE:UnregisterCallback("StateChange",BUI.MiniMap.WorldSceneCallback)
			BUI.MiniMap.SceneCallbacksRegistered=false
		end
		EVENT_MANAGER:UnregisterForEvent("BUI_ZoneChange", EVENT_PLAYER_ACTIVATED)
		EVENT_MANAGER:UnregisterForEvent("BUI_ZoneChange", EVENT_ZONE_CHANGED)
		EVENT_MANAGER:UnregisterForEvent("BUI_MinimapContext", EVENT_PLAYER_ACTIVATED)
		EVENT_MANAGER:UnregisterForEvent("BUI_MinimapContext", EVENT_ZONE_CHANGED)
		if EVENT_ZONE_UPDATE then EVENT_MANAGER:UnregisterForEvent("BUI_MinimapContext", EVENT_ZONE_UPDATE) end
		if EVENT_CURRENT_SUBZONE_LIST_CHANGED then EVENT_MANAGER:UnregisterForEvent("BUI_MinimapContext", EVENT_CURRENT_SUBZONE_LIST_CHANGED) end
		if EVENT_PLAYER_TELEPORTED_LOCALLY then EVENT_MANAGER:UnregisterForEvent("BUI_MinimapContext", EVENT_PLAYER_TELEPORTED_LOCALLY) end
		EVENT_MANAGER:UnregisterForEvent("BUI_MinimapCombat", EVENT_PLAYER_COMBAT_STATE)
		EVENT_MANAGER:UnregisterForUpdate("BUI_Minimap")
		return
	end
--[[	Reticle distance
	if BUI.Vars.DeveloperMode then
		local fs	=17
		BUI.UI.Label("BUI_ReticleDistance",	ZO_ReticleContainerReticle,	{fs*3.5,fs},	{TOP,BOTTOM,0,0},	BUI.UI.Font("esobold",fs), nil, {1,0}, "", false)
	end
--]]
	--Set variables
	BUI.MiniMap.LastX1,BUI.MiniMap.LastY1=GetMapPlayerPosition('player')
	BUI.MiniMap.LastX2=BUI.MiniMap.LastX1
	BUI.MiniMap.LastY2=BUI.MiniMap.LastY1
	BUI.MiniMap.size=BUI.Vars.MiniMapDimensions
	BUI.MiniMap.pinscale=BUI.Vars.PinScale/100

	--QuestTracker
	if not BUI.Vars.ZO_FocusedQuestTrackerPanel then
		ZO_FocusedQuestTrackerPanel:ClearAnchors() ZO_FocusedQuestTrackerPanel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, 0, BUI.MiniMap.size+20)
	end

	EVENT_MANAGER:RegisterForEvent("BUI_MinimapContext", EVENT_PLAYER_ACTIVATED,	function() ScheduleMapContextRefresh(500,"PLAYER_ACTIVATED",true) end)
	EVENT_MANAGER:RegisterForEvent("BUI_MinimapContext", EVENT_ZONE_CHANGED,		function() ScheduleMapContextRefresh(100,"ZONE_OR_SUBZONE_CHANGED",true) end)
	if EVENT_ZONE_UPDATE then
		EVENT_MANAGER:RegisterForEvent("BUI_MinimapContext", EVENT_ZONE_UPDATE,function(_,unitTag)
			if unitTag=="player" then ScheduleMapContextRefresh(100,"PLAYER_ZONE_UPDATED",true) end
		end)
	end
	if EVENT_CURRENT_SUBZONE_LIST_CHANGED then
		EVENT_MANAGER:RegisterForEvent("BUI_MinimapContext", EVENT_CURRENT_SUBZONE_LIST_CHANGED,function() ScheduleMapContextRefresh(100,"SUBZONE_LIST_CHANGED",true) end)
	end
	if EVENT_PLAYER_TELEPORTED_LOCALLY then
		EVENT_MANAGER:RegisterForEvent("BUI_MinimapContext", EVENT_PLAYER_TELEPORTED_LOCALLY,function() ScheduleMapContextRefresh(100,"PLAYER_TELEPORTED",true) end)
	end
	EVENT_MANAGER:RegisterForEvent("BUI_Minimap", EVENT_SCREEN_RESIZED,		BUI.MiniMap.Show)
	EVENT_MANAGER:RegisterForEvent("BUI_Minimap", EVENT_MOUNTED_STATE_CHANGED,	BUI.MiniMap.OnMount)

	BUI.MiniMap.WorldMapChangedCallback=BUI.MiniMap.WorldMapChangedCallback or function()
		if not BUI.MiniMap.ContextRefreshInProgress and not BUI.MiniMap.MapSceneIsShowing then
			ScheduleMapContextRefresh(75,"WORLD_MAP_CHANGED",true)
		end
	end
	if not BUI.MiniMap.SceneCallbacksRegistered then
		for scene in pairs(BUI.MiniMap.BUI_MINIMAP_SCENE_NAMES) do
			local sceneObject=SCENE_MANAGER:GetScene(scene)
			if sceneObject then sceneObject:RegisterCallback("StateChange",OnHUD) end
		end
		CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged",BUI.MiniMap.WorldMapChangedCallback)
		WORLD_MAP_SCENE:RegisterCallback("StateChange",WorldSceneChanged)
		BUI.MiniMap.SceneCallbacksRegistered=true
	end
--[[
	GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState==SCENE_SHOWING and BUI.init.MiniMap then BUI.MiniMap.MapSceneIsShowing=true BUI.MiniMap.Restore()
		elseif newState==SCENE_HIDDEN then BUI.MiniMap.MapSceneIsShowing=false BUI.MiniMap.Show() end
	end)
--]]
	--Controls
	local ctrl	=BUI.UI.Control("BUI_Minimap",	SatuveUI,	{BUI.MiniMap.size, BUI.MiniMap.size},	BUI.Vars.BUI_Minimap,	false)
	ctrl.backdrop=BUI.UI.Backdrop("BUI_Minimap_B",	ctrl,		"inherit",		{CENTER,CENTER,0,0},	{0,0,0,0.4}, {0,0,0,1}, nil, true)
	ctrl.label	=BUI.UI.Label("BUI_Minimap_L",	ctrl.backdrop,		"inherit",		{CENTER,CENTER,0,0},	BUI.UI.Font("standard",20,true), nil, {1,1}, BUI.Loc("MiniMap_Label"))

	ctrl:SetMovable(true)
	ctrl:SetMouseEnabled(false)
	ctrl:SetHandler("OnMouseUp", function(self) BUI.Menu:SaveAnchor(BUI_Minimap) end)	
	--Map Title
	ZO_WorldMapTitle:SetFont(BUI.UI.Font("standard", 20, "shadow"))
	ZO_WorldMapTitle:ClearAnchors()
	ZO_WorldMapTitle:SetAnchor(TOP,ZO_WorldMap,TOP,0,0)
	ZO_WorldMapTitle:SetHidden(not BUI.Vars.MiniMapTitle)
	BUI.MiniMap.CombatHidden=false
	BUI.MiniMap.Show()
end

local function PinColors()
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_GROUP_LEADER].tint=ZO_ColorDef:New(unpack(BUI.Vars.PinColor[MAP_PIN_TYPE_GROUP_LEADER]))
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_GROUP].tint=ZO_ColorDef:New(unpack(BUI.Vars.PinColor[MAP_PIN_TYPE_GROUP]))
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE].tint=ZO_ColorDef:New(unpack(BUI.Vars.PinColor[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE]))
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_POI_COMPLETE].tint=ZO_ColorDef:New(unpack(BUI.Vars.PinColor[MAP_PIN_TYPE_POI_COMPLETE]))
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING].tint=ZO_ColorDef:New(unpack(BUI.Vars.PinColor[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING]))
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING].tint=ZO_ColorDef:New(unpack(BUI.Vars.PinColor[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING]))
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_TRACKED_QUEST_ENDING].tint=ZO_ColorDef:New(unpack(BUI.Vars.PinColor[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING]))
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING].tint=ZO_ColorDef:New(unpack(BUI.Vars.PinColor[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING]))
	ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING].tint=ZO_ColorDef:New(unpack(BUI.Vars.PinColor[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING]))
end

local function Show()
	if not BUI.Vars.MiniMap or BUI.MiniMap.MapSceneIsShowing then return end
	EVENT_MANAGER:UnregisterForUpdate("BUI_Minimap")
	BUI.MiniMap.ResizePins(true)
	-- The addon viewport owns the minimap position. Leave the hidden stock
	-- ZO_WorldMap root in ESO's native layout so its tile coordinate system stays
	-- identical to the normal full map.
	BUI.MiniMap.UpdateDimensions()
	BUI.MiniMap.SetAuxiliaryUIHidden(true)
	BUI.MiniMap.ApplyTransparency()
--	ZO_WorldMap:SetMouseEnabled(false)
	-- The map content has been re-parented into BUI_MinimapViewport, so the
	-- original full-size WorldMap root can stay hidden. This removes the large
	-- black/translucent rectangle while the clipped minimap remains visible.
	ZO_WorldMap:SetHidden(true)
	if ZO_WorldMapScroll then ZO_WorldMapScroll:SetHidden(false) end
	local viewport=rawget(_G,"BUI_MinimapViewport")
	local container=rawget(_G,"BUI_Minimap")
	BUI.MiniMap.SetViewportChromeHidden(true)
	BUI.init.MiniMap=true

	if not BUI.MiniMap.CurrentMapId or BUI.MiniMap.PendingContextRefresh then
		BUI.MiniMap.RefreshMapContext("MINIMAP_SHOWN",true)
	else
		BUI.MiniMap.ZoomUpdate(nil,true)
		BUI.MiniMap.ResetSmoothState()
	end

	if container then container:SetHidden(false) end
	if viewport then viewport:SetHidden(false) end
	BUI.MiniMap.SnapMinimapToPlayer()
	BUI.CallLater("SXUI_PlayerPinVisible",50,function()
		if BUI.init.MiniMap and not BUI.MiniMap.CombatHidden then BUI.MiniMap.EnsurePlayerPinVisible() end
	end)
	-- Gamepad map code may restore dimensions one frame later. Re-apply only
	-- the minimap dimensions so the selected value remains 1:1.
	BUI.CallLater("SXUI_MinimapPixelSize",50,function()
		if BUI.init.MiniMap and not BUI.MiniMap.CombatHidden then
			BUI.MiniMap.UpdateDimensions()
			BUI.MiniMap.SetViewportChromeHidden(true)
			BUI.MiniMap.SnapMinimapToPlayer()
		end
	end)
	BUI.CallLater("MiniMap_Shown",50,function()
		if BUI.init.MiniMap and not BUI.MiniMap.MapSceneIsShowing and not BUI.MiniMap.CombatHidden then
			EVENT_MANAGER:RegisterForUpdate("BUI_Minimap",33,BUI.MiniMap.Update)
		end
	end)
	CALLBACK_MANAGER:FireCallbacks("BUI_MiniMap_Shown", true)
	local EMPTY_HEADER_INFO =
	{
		nameText = "",
		descriptionText = "",
		owner = "BUI",
		showProgressBar = false,
	}
	WORLD_MAP_MANAGER:SetMapHeader(EMPTY_HEADER_INFO)	
end

local function Restore()	
	EVENT_MANAGER:UnregisterForUpdate("BUI_Minimap")
	BUI.MiniMap.DetachMapFromViewport()
	BUI.MiniMap.SetViewportChromeHidden(false)
	if ZO_WorldMap then ZO_WorldMap:SetHidden(false) end
	BUI.MiniMap.SetAuxiliaryUIHidden(false)
	if ZO_WorldMap then ZO_WorldMap:SetAlpha(1) end
	if ZO_WorldMapScroll then ZO_WorldMapScroll:SetAlpha(1) end
--	if BUI.API<=10024 then
	BUI.MiniMap.ResizePins(false)
	BUI.MiniMap.MapPanAndZoom:SetCurrentNormalizedZoomInternal(BUI.Vars.ZoomGlobal/100)	
	ZO_WorldMap_UpdateMap()
	BUI.init.MiniMap=false
	CALLBACK_MANAGER:FireCallbacks("BUI_MiniMap_Shown", false)
	if BUI.g_mapPinManager and (BUI.Vars.StatsShareDPS or BUI.Vars.StatShare) then
		BUI.g_mapPinManager:RemovePins("pings", MAP_PIN_TYPE_PING)
	end
	local CLEAR_HEADER_INFO =
	{
		nameText = "",
		descriptionText = "",
		owner = nil,
		showProgressBar = false,
	}
	WORLD_MAP_MANAGER:SetMapHeader(CLEAR_HEADER_INFO)	
end

local function ResizePins(resize)
	local scale=(resize) and BUI.MiniMap.pinscale or 1
	for pin=9,210 do
		if ZO_MapPin.PIN_DATA[pin] then
			local size=ZO_MapPin.PIN_DATA[pin].size
			local origsize=ZO_MapPin.PIN_DATA[pin].origsize or size or 40
			ZO_MapPin.PIN_DATA[pin].origsize=origsize
			ZO_MapPin.PIN_DATA[pin].size=origsize*scale
		end
	end
end

local function Map_Toggle() -- Unreferenced Function
	local _visible=not ZO_WorldMap:IsHidden()
	ZO_WorldMap:SetHidden(_visible)
	_G["ZO_WorldMapMapFrame"]:SetHidden(_visible)
	if not _visible then
--		ZO_WorldMap_SetCustomZoomLevels(2.5,2.5)
		ZO_WorldMap_JumpToPlayer()
	end
end

local function Update()
	if not BUI.init.MiniMap or BUI.MiniMap.CombatHidden then return end
	BUI.MiniMap.UpdateSmoothVisuals()
end

local function ZoneChanged(delay)
	if not BUI.Vars.MiniMap then return end
	ScheduleMapContextRefresh(delay or 0,"ZONE_CHANGED",true)
end

local function Settings_Init()
	local MenuOptions={
		--	type="header",name="Minimap",advanced=true
		--Enable Minimap
		{	type		="checkbox",
			name		="Minimap",
			getFunc	=function() return BUI.Vars.MiniMap end,
			setFunc	=function(value) BUI.Vars.MiniMap=value BUI.MiniMap.ReInit() end,
		},
		--Minimap Size
		{	type		="slider",
			name		="MiniMapDimensions",
			min		=200,
			max		=500,
			step		=20,
			getFunc	=function() return BUI.Vars.MiniMapDimensions end,
			setFunc	=function(value) BUI.Vars.MiniMapDimensions=value BUI.MiniMap.ReInit() end,
			disabled	=function() return not BUI.Vars.MiniMap end,
		},
		--Minimap transparency
		{	type		="slider",
			name		="MinimapTransparency",
			min		=0,
			max		=100,
			step		=5,
			getFunc	=function() return BUI.Vars.MiniMapAlpha or 100 end,
			setFunc	=function(value) BUI.Vars.MiniMapAlpha=value BUI.MiniMap.ApplyTransparency() end,
			disabled	=function() return not BUI.Vars.MiniMap end,
		},
		--Minimap title
		{	type		="checkbox",
			name		="MinimapTitle",
			getFunc	=function() return BUI.Vars.MiniMapTitle end,
			setFunc	=function(value) BUI.Vars.MiniMapTitle=value BUI.MiniMap.ReInit() end,
			disabled	=function() return not BUI.Vars.MiniMap end,
		},
		--Minimap PinScale
		{	type		="slider",
			name		="PinScale",
			min		=50,
			max		=100,
			step		=2,
			getFunc	=function() return BUI.Vars.PinScale end,
			setFunc	=function(value) BUI.Vars.PinScale=value BUI.MiniMap.ReInit() end,
			disabled	=function() return not BUI.Vars.MiniMap end,
		},
		{	type		="header",
			name		="ZoomHeader",
		},
		{	type		="slider",
			name		="ZoomZone",
			min		=0,
			max		=100,
			step		=10,
			getFunc	=function() return BUI.Vars.ZoomZone end,
			setFunc	=function(value) BUI.Vars.ZoomZone=value BUI.MiniMap.Show() end,
			disabled	=function() return not BUI.Vars.MiniMap end,
		},
		{	type		="slider",
			name		="ZoomSubZone",
			min		=0,
			max		=100,
			step		=10,
			getFunc	=function() return BUI.Vars.ZoomSubZone end,
			setFunc	=function(value) BUI.Vars.ZoomSubZone=value BUI.MiniMap.Show() end,
			disabled	=function() return not BUI.Vars.MiniMap end,
		},
		{	type		="slider",
			name		="ZoomDungeon",
			min		=0,
			max		=100,
			step		=10,
			getFunc	=function() return BUI.Vars.ZoomDungeon end,
			setFunc	=function(value) BUI.Vars.ZoomDungeon=value BUI.MiniMap.Show() end,
			disabled	=function() return not BUI.Vars.MiniMap end,
		},
		{	type		="slider",
			name		="ZoomCyrodiil",
			min		=0,
			max		=100,
			step		=10,
			getFunc	=function() return BUI.Vars.ZoomCyrodiil end,
			setFunc	=function(value) BUI.Vars.ZoomCyrodiil=value BUI.MiniMap.Show() end,
			disabled	=function() return not BUI.Vars.MiniMap end,
		},
		{	type		="slider",
			name		="ZoomImperialsewer",
			min		=0,
			max		=100,
			step		=10,
			getFunc	=function() return BUI.Vars.ZoomImperialsewer end,
			setFunc	=function(value) BUI.Vars.ZoomImperialsewer=value BUI.MiniMap.Show() end,
			disabled	=function() return not BUI.Vars.MiniMap end,
		},
		{	type		="slider",
			name		="ZoomImperialCity",
			min		=0,
			max		=100,
			step		=10,
			getFunc	=function() return BUI.Vars.ZoomImperialCity end,
			setFunc	=function(value) BUI.Vars.ZoomImperialCity=value BUI.MiniMap.Show() end,
			disabled	=function() return not BUI.Vars.MiniMap end,
		},
		{	type		="slider",
			name		="ZoomMountRatio",
			min		=50,
			max		=100,
			step		=10,
			getFunc	=function() return BUI.Vars.ZoomMountRatio end,
			setFunc	=function(value) BUI.Vars.ZoomMountRatio=value BUI.MiniMap.Show() end,
			disabled	=function() return not BUI.Vars.MiniMap end,
		},
		{	type		="slider",
			name		="ZoomGlobal",
			min		=0,
			max		=100,
			step		=10,
			getFunc	=function() return BUI.Vars.ZoomGlobal end,
			setFunc	=function(value) BUI.Vars.ZoomGlobal=value BUI.MiniMap.Show() end,
			disabled	=function() return not BUI.Vars.MiniMap end,
		},
	--[[
		{--Reset
			type		="button",
			name		="MinimapReset",
			func		=function() BUI.Menu.Reset("Minimap") end,
		}
	--]]
	}

	local PinTypes={
	--	[MAP_PIN_TYPE_PLAYER]={name="Player",icon="/EsoUI/Art/MapPins/UI-WorldMapPlayerPip.dds"},
		[MAP_PIN_TYPE_GROUP_LEADER]={name="Group leader",icon="/EsoUI/Art/Compass/groupLeader.dds"},
		[MAP_PIN_TYPE_GROUP]={name="Group member",icon="/EsoUI/Art/MapPins/UI-WorldMapGroupPip.dds"},
		[MAP_PIN_TYPE_POI_COMPLETE]={name="POI complete",icon="/esoui/art/icons/poi/poi_areaofinterest_complete.dds"},
		[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE]={name="Wayshrine",icon="/esoui/art/icons/poi/poi_wayshrine_complete.dds"},
		[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING]={name="Quest complete",icon="/esoui/art/compass/quest_icon_assisted.dds"},
	--	[MAP_PIN_TYPE_VENDOR]={name="Vandor",icon="/esoui/art/icons/mapkey/mapkey_vendor.dds"},
	}

	do	--Pin colors
		table.insert(MenuOptions,{type="header",name="PinColorsHeader"})
		for pin,data in pairs(PinTypes) do
			table.insert(MenuOptions,
			{	type		="colorpicker",
				name		=zo_iconFormat(data.icon,32,32).." "..data.name,
				getFunc	=function() return unpack(BUI.Vars.PinColor[pin]) end,
				setFunc	=function(r,g,b,a) BUI.Vars.PinColor[pin]={r,g,b,a} BUI.MiniMap.PinColors() BUI.MiniMap.Show() end,
			})
		end
		table.insert(MenuOptions,
			{--Reset
			type		="button",
			name		="MinimapReset",
			func		=function()ZO_Dialogs_ShowDialog("BUI_RESET_CONFIRMATION", {text=BUI.Loc("MinimapResetDesc"),func=function()BUI.Menu.Reset("Minimap")end})end,
		})
	end
	local minimapName="9.  |t32:32:/esoui/art/icons/achievements_indexicon_exploration_up.dds|t"..BUI.Loc("MinimapHeader")

	-- When LibAddonMenu/LibGamepad is available, keep Minimap inside the single
	-- Bandit UI controller menu instead of registering it as a separate page.
	-- All checkbox/slider controls remain backed by the original BUI.Vars and
	-- setFunc handlers, so controller changes take effect immediately.
	local addedToGamepadMenu=false
	if BUI.SettingsBridge and BUI.SettingsBridge.AddGroupedSection then
		addedToGamepadMenu=BUI.SettingsBridge.AddGroupedSection("BUI_BanditUI", {
			id="Minimap",
			name=minimapName,
			order=9,
			options=MenuOptions,
			-- LibGamepad does not reliably forward controller left/right events
			-- for LAM sliders on every version. Convert only the Minimap sliders
			-- to numeric dropdowns with the same min/max/step values.
			controllerSafeSliders=true,
		})
	end

	-- Keep the original Bandit window complete as well.  The controller menu and
	-- legacy mouse/keyboard menu are two views over the same settings.
	BUI.Menu.RegisterPanel("BUI_MenuMinimap",{
		type="panel",
		name=minimapName,
		})
	BUI.Menu.RegisterOptions("BUI_MenuMinimap", MenuOptions)
	MenuHandlers={
		["OnEffectivelyShown"]=function() BUI.inMenu=true BUI.MiniMap.Show() end,
		["OnEffectivelyHidden"]=function() BUI.inMenu=false end,
	}
	for event,handler in pairs(MenuHandlers) do _G["BUI_MenuMinimap"]:SetHandler(event, handler) end
end

local function Initialize()
	-- Settings do not require the world-map controls. Register them immediately so
	-- page 9 is present before the unified LibAddonMenu controller menu is finalized.
	if not BUI.MiniMap.SettingsReady then
		BUI.MiniMap.Settings_Init()
		BUI.MiniMap.SettingsReady=true
	end
	if not ZO_WorldMap or not ZO_WorldMapScroll or not ZO_WorldMapManager or not WORLD_MAP_SCENE or not WORLD_MAP_MANAGER then
		BUI.CallLater("SXUI_MinimapInitialize", 500, Initialize)
		return
	end
	ZOShowMapHeader = ZO_WorldMapManager.TryShowSpectacleMapHeader
	BUI.MiniMap.MapPanAndZoom=ZO_WorldMap_GetPanAndZoom and ZO_WorldMap_GetPanAndZoom() or BUI.MiniMap.MapPanAndZoom
	BUI.MiniMap.PinManager=ZO_WorldMap_GetPinManager and ZO_WorldMap_GetPinManager() or BUI.MiniMap.PinManager
	if not BUI.MiniMap.MapPanAndZoom or not BUI.MiniMap.PinManager then
		BUI.CallLater("SXUI_MinimapInitialize", 500, Initialize)
		return
	end
	BUI.MiniMap.ReInit()
end

-- Setup MiniMap
BUI.MiniMap={}
BUI.MiniMap.LastX1=0
BUI.MiniMap.LastY1=0
BUI.MiniMap.LastX2=0
BUI.MiniMap.LastY2=0
BUI.MiniMap.size=250
BUI.MiniMap.pinscale=.75
BUI.MiniMap.Subzone=false
BUI.MiniMap.ZoomUpdatind=false
BUI.MiniMap.MapSceneIsShowing=false
BUI.MiniMap.CombatHidden=false
BUI.MiniMap.ContextRefreshInProgress=false
BUI.MiniMap.PendingContextRefresh=true
BUI.MiniMap.CurrentMapId=nil
BUI.MiniMap.Environment="WORLD"
BUI.MiniMap.CurrentZoom=nil
BUI.MiniMap.TargetZoom=nil
BUI.MiniMap.MapPanAndZoom=ZO_WorldMap_GetPanAndZoom and ZO_WorldMap_GetPanAndZoom() or nil
BUI.MiniMap.PinManager=ZO_WorldMap_GetPinManager and ZO_WorldMap_GetPinManager() or nil
BUI.MiniMap.BUI_MINIMAP_SCENE_NAMES={["hudui"]=true,["hud"]=true,}

-- Setup Defaults
BUI.MiniMap.Defaults={}
BUI.MiniMap.Defaults.MiniMap=true
BUI.MiniMap.Defaults.MiniMapDimensions=250
BUI.MiniMap.Defaults.MiniMapTitle=true
BUI.MiniMap.Defaults.MiniMapAlpha=100
BUI.MiniMap.Defaults.PinScale=75
BUI.MiniMap.Defaults.BUI_Minimap={TOPRIGHT,TOPRIGHT,0,0}
BUI.MiniMap.Defaults.ZoomZone=60
BUI.MiniMap.Defaults.ZoomSubZone=30
BUI.MiniMap.Defaults.ZoomDungeon=60
BUI.MiniMap.Defaults.ZoomCyrodiil=45
BUI.MiniMap.Defaults.ZoomImperialsewer=60
BUI.MiniMap.Defaults.ZoomImperialCity=80
BUI.MiniMap.Defaults.ZoomMountRatio=70
BUI.MiniMap.Defaults.ZoomGlobal=3
BUI.MiniMap.Defaults.PinColor={}
-- BUI.MiniMap.Defaults.PinColor[MAP_PIN_TYPE_PLAYER]={1,1,1,1}
BUI.MiniMap.Defaults.PinColor[MAP_PIN_TYPE_GROUP_LEADER]={1,1,0,1}
BUI.MiniMap.Defaults.PinColor[MAP_PIN_TYPE_GROUP]={1,1,1,1}
BUI.MiniMap.Defaults.PinColor[MAP_PIN_TYPE_POI_COMPLETE]={1,1,1,1}
-- BUI.MiniMap.Defaults.PinColor[MAP_PIN_TYPE_VENDOR]={1,1,1,1}
BUI.MiniMap.Defaults.PinColor[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE]={1,1,1,1}
BUI.MiniMap.Defaults.PinColor[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING]={1,1,1,1}

BUI:JoinTables(BUI.Defaults,BUI.MiniMap.Defaults)

-- Register Functions
BUI.MiniMap.ZoneChanged = ZoneChanged
BUI.MiniMap.Update = Update
BUI.MiniMap.Map_Toggle = Map_Toggle -- Unreferenced Function
BUI.MiniMap.ResizePins = ResizePins
BUI.MiniMap.Restore = Restore
BUI.MiniMap.Show = Show
BUI.MiniMap.PinColors = PinColors
BUI.MiniMap.Initialize = Initialize
BUI.MiniMap.UpdateDimensions = UpdateDimensions
BUI.MiniMap.EnsureViewport = EnsureViewport
BUI.MiniMap.AttachMapToViewport = AttachMapToViewport
BUI.MiniMap.DetachMapFromViewport = DetachMapFromViewport
BUI.MiniMap.SetViewportChromeHidden = SetViewportChromeHidden
BUI.MiniMap.SetSize = SetSize
BUI.MiniMap.UpdatePosition = UpdatePosition
BUI.MiniMap.ZoomUpdate = ZoomUpdate
BUI.MiniMap.OnMount = OnMount
BUI.MiniMap.Settings_Init = Settings_Init
BUI.MiniMap.ReInit = ReInit
BUI.MiniMap.ApplyTransparency = ApplyTransparency
BUI.MiniMap.SetAuxiliaryUIHidden = SetAuxiliaryUIHidden
BUI.MiniMap.GetLivePlayerMapPosition = GetLivePlayerMapPosition
BUI.MiniMap.CenterOnPlayer = CenterOnPlayer
BUI.MiniMap.EnsurePlayerPinVisible = EnsurePlayerPinVisible
BUI.MiniMap.GetMinimapEnvironment = GetMinimapEnvironment
BUI.MiniMap.ResetSmoothState = ResetSmoothState
BUI.MiniMap.SnapMinimapToPlayer = SnapMinimapToPlayer
BUI.MiniMap.UpdateSmoothVisuals = UpdateSmoothVisuals
BUI.MiniMap.StabilizeMapViewport = StabilizeMapViewport
BUI.MiniMap.ScheduleMapViewportStabilization = ScheduleMapViewportStabilization
BUI.MiniMap.ScheduleMapContextRefresh = ScheduleMapContextRefresh
BUI.MiniMap.RefreshMapContext = RefreshMapContext
BUI.MiniMap.SetCombatHidden = SetCombatHidden
BUI.MiniMap.OnCombatState = OnMinimapCombatState
BUI.MiniMap.HideHeader = HideHeader
