------------------------------------------------------------
-- Settings
-------------------------------------------------------------
function MM_SetPPStyle(value)
	if value == nil then return end
	if value == "Classic" then -- Upgrade from version 2.24 or earlier
		value = GetString(SI_MM_STRING_CLASSIC)
	end
	if value == "Separate Player & Camera" then -- Upgrade from version 2.24 or earlier
		value = GetString(SI_MM_STRING_PLAYERANDCAMERA)
	end
	FyrMM.SV.PPStyle = value
	if value == GetString(SI_MM_STRING_PLAYERANDCAMERA) then
		Fyr_MM_Camera:SetHidden(false)
	else
		Fyr_MM_Camera:SetHidden(true)
	end
end

function MM_Upgrade_MapList()
	if FyrMM.SV.MapSettings == nil then return end
	FyrMM.SV.MapTable = {}
	for i, v in pairs(FyrMM.SV.MapSettings) do
		FyrMM.SV.MapTable[v.FileName] = {ZoomLevel = v.ZoomLevel, MapSize = v.MapSize}
	end
	FyrMM.SV.MapSettings = nil
end

function MM_SetPPTextures(value)
	if value == nil then return end
	FyrMM.SV.PPTextures = value
	if value == "ESO UI Worldmap" then
		Fyr_MM_Player:SetTexture("EsoUI/Art/MapPins/UI-WorldMapPlayerPip.dds")
		Fyr_MM_Camera:SetTexture("/MiniMap/Textures/ui-worldmapplayercamerapip.dds")
		Fyr_MM_Camera:SetBlendMode(TEX_BLEND_MODE_ADD)
		Fyr_MM_Player:SetScale(1)
		Fyr_MM_Camera:SetScale(1)
	else
	if value == "Vixion Regular" then
		Fyr_MM_Player:SetTexture("/MiniMap/Textures/VixionPlayerPointer_arrow.dds")
		Fyr_MM_Camera:SetTexture("/MiniMap/Textures/VixionCameraPointer_glow.dds")
		Fyr_MM_Camera:SetBlendMode(TEX_BLEND_MODE_ADD)
		Fyr_MM_Player:SetScale(1)
		Fyr_MM_Camera:SetScale(1)
	else
		if value == "Vixion Gold" then
			Fyr_MM_Player:SetTexture("/MiniMap/Textures/VixionPlayerPointer_arrow_gold.dds")
			Fyr_MM_Camera:SetTexture("/MiniMap/Textures/VixionCameraPointer_glow.dds")
			Fyr_MM_Camera:SetBlendMode(TEX_BLEND_MODE_ADD)
			Fyr_MM_Player:SetScale(1)
			Fyr_MM_Camera:SetScale(1)
		else
			Fyr_MM_Player:SetTexture("/MiniMap/Textures/PlayerPointer.dds")
			Fyr_MM_Camera:SetTexture("/MiniMap/Textures/CameraPointer.dds")
			Fyr_MM_Camera:SetBlendMode(TEX_BLEND_MODE_ADD)
			local scale = 0.75
		end
	end
	
		if FyrMM.SV.PinScale ~= nil then
			scale = FyrMM.SV.PinScale/100
		end
		Fyr_MM_Player:SetScale(scale)
		Fyr_MM_Camera:SetScale(scale)
	end
end


function MM_SetBorderPins(value)
	if value == nil then return end
	FyrMM.SV.BorderPins = value
	if not FyrMM.Initialized then return end
	Fyr_MM_Axis_Control:SetHidden(not (FyrMM.SV.RotateMap or FyrMM.SV.BorderPins))
	Fyr_MM_Axis_Control:SetTopmost(FyrMM.SV.RotateMap or FyrMM.SV.BorderPins)
	FyrMM.PlaceBorderPins()
end

function MM_SetUseOriginalAPI(value)
	if value == nil then return end
	FyrMM.SV.UseOriginalAPI = value
	FyrMM.API_Check()
end

function MM_SetShowUnexploredPins(value)
	if value == nil then return end
	FyrMM.SV.ShowUnexploredPins = value
	if FyrMM.Initialized then
		FyrMM.Reload()
	end
end

function MM_SetMapRefreshRate(value)
	if value == nil then return end
	FyrMM.SV.MapRefreshRate = value
	if not FyrMM.Initialized then return end
	EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapPosition")
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapPosition", FyrMM.SV.MapRefreshRate, FyrMM.PositionUpdate)
end

function MM_SetPinRefreshRate(value)
	if value == nil then return end
	FyrMM.SV.PinRefreshRate = value
	if not FyrMM.Initialized then return end
	EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapPins")
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapPins", FyrMM.SV.PinRefreshRate, FyrMM.PinUpdate)
end

function MM_SetViewRefreshRate(value)
	if value == nil then return end
	FyrMM.SV.ViewRefreshRate = value
	if not FyrMM.Initialized then return end
	EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapView")
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapView", FyrMM.SV.ViewRefreshRate, FyrMM.UpdateMapTiles)
end

function MM_SetZoneRefreshRate(value)
	if value == nil then return end
	FyrMM.SV.ZoneRefreshRate = value
	if not FyrMM.Initialized then return end
	EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapZone")
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapZone", FyrMM.SV.ZoneRefreshRate, FyrMM.ZoneUpdate)
end

function MM_SetKeepNetworkRefreshRate(value)
	if value == nil then return end
	if value < 900 then value = 2000 end
	FyrMM.SV.KeepNetworkRefreshRate = value
	if not FyrMM.Initialized then return end
	EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapKeepNetwork")
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapKeepNetwork", FyrMM.SV.KeepNetworkRefreshRate, FyrMM.UpdateKeepNetwork)
end


function MM_GetMapHeight()
	local mheight = Fyr_MM_Scroll:GetHeight()
	return mheight
end

function MM_GetMapWidth()
	local mwidth = Fyr_MM_Scroll:GetWidth()
	return mwidth
end

function MM_SetMapHeight(value)
if value == nil or FyrMM.SV.WheelMap then return end
if FyrMM.SV.LockPosition and FyrMM.Initialized then return end 
	FyrMM.SV.MapHeight = value
	Fyr_MM_Scroll:SetHeight(value)
	Fyr_MM_Border:SetHeight(value+8)
	Fyr_MM:SetHeight(value)
	Fyr_MM_Scroll_Fill:SetHeight(value)
	FyrMM.MapHalfDiagonal()
	MM_RearrangeMenu()
end

function MM_SetMapWidth(value)
if value == nil then return end
	if FyrMM.SV.LockPosition and FyrMM.Initialized then return end 
	FyrMM.SV.MapWidth = value
	Fyr_MM_Scroll:SetWidth(value)
	Fyr_MM_Border:SetWidth(value+8)
	Fyr_MM_Frame_Wheel:SetDimensions(value+8, value+8)
	Fyr_MM_Frame_RoundMenu:SetDimensions(value, value/4)
	Fyr_MM_Frame_RoundMenu:ClearAnchors()
	Fyr_MM_Frame_RoundMenu:SetAnchor(TOPLEFT, Fyr_MM, TOPLEFT, 0, value - value/9)
	Fyr_MM_Frame_SquareMenu:SetDimensions(value, value/4)
	Fyr_MM_Wheel_Background:SetDimensions(value+8, value+8)
	Fyr_MM:SetWidth(value)
	Fyr_MM_Scroll_Fill:SetWidth(value)
	if FyrMM.SV.WheelMap then
		FyrMM.SV.MapHeight = value
		Fyr_MM_Scroll:SetHeight(value)
		Fyr_MM_Border:SetHeight(value+8)
		Fyr_MM:SetHeight(value)
		Fyr_MM_Scroll_Fill:SetHeight(value)
		FyrMM.MapHalfDiagonal()
	end
	MM_RearrangeMenu()
end

function MM_GetPinScale()
	local scale = FyrMM.SV.PinScale
	return scale
end

function MM_SetPinScale(value)
if value == nil then return end
	FyrMM.pScale = value
	FyrMM.pScalePercent = FyrMM.pScale / 100
	MM_SetPPTextures(FyrMM.SV.PPTextures)
	FyrMM.SV.PinScale = value
end

function MM_GetMapAlpha()
	return FyrMM.SV.MapAlpha
end

function MM_SetMapAlpha(value)
if value == nil then return end
	local newAlphaPercent = value / 100
	FyrMM.SV.MapAlpha = value
	Fyr_MM_Wheel_Background:SetAlpha(newAlphaPercent+.10)
	Fyr_MM:SetAlpha(newAlphaPercent)
	Fyr_MM_Scroll_WheelWE:SetAlpha(newAlphaPercent)
	Fyr_MM_Scroll_WheelNS:SetAlpha(newAlphaPercent)
	Fyr_MM_Scroll_WheelCenter:SetAlpha(newAlphaPercent)
end

function MM_GetShowPosition()
	return FyrMM.SV.ShowPosition
end

function MM_SetShowPosition(value)
if value == nil then return end
	FyrMM.SV.ShowPosition = value
	Fyr_MM_Coordinates:SetHidden(not FyrMM.SV.ShowPosition)
end

function MM_GetMapZoom()
	local MM_zoom = FyrMM.SV.MapZoom
	if MM_zoom == nil then
		FyrMM.SV.MapZoom = FyrMM_DEFAULT_ZOOM_LEVEL
		MM_zoom = FyrMM_DEFAULT_ZOOM_LEVEL
	end

	return MM_zoom
end

function MM_GetHideCompass()
	return FyrMM.SV.hideCompass
end

function MM_SetHideCompass(value)
if value == nil then return end
	FyrMM.SV.hideCompass = value
	ZO_CompassFrame:SetHidden(not value)
end

function MM_SetRotateMap(value)
if value == nil then return end
	FyrMM.SV.RotateMap = value
	Fyr_MM_Axis_Control:SetHidden(not FyrMM.SV.RotateMap)
	FyrMM.AxisPins()
	if FyrMM.SV.WheelMap and not FyrMM.SV.RotateMap then
		Fyr_MM_Frame_Wheel:SetTextureRotation(0)
	end
	if not FyrMM.SV.RotateMap then
		FyrMM.UpdateMapTiles()
		FyrMM.Reload()
	end
end

function MM_RearrangeMenu()
	local scale = zo_round(Fyr_MM:GetWidth()/3.41)/100
	Fyr_MM_Time:SetScale(scale)
	Fyr_MM_ZoomIn:SetScale(scale)
	Fyr_MM_ZoomOut:SetScale(scale)
	Fyr_MM_PinDown:SetScale(scale)
	Fyr_MM_PinUp:SetScale(scale)
	Fyr_MM_Reload:SetScale(scale)
	Fyr_MM_Settings:SetScale(scale)
	if FyrMM.SV.WheelMap then
		Fyr_MM_Time:ClearAnchors()
		Fyr_MM_Time:SetDrawLayer(4)
		Fyr_MM_Time:SetAnchor(CENTER, Fyr_MM_Frame_RoundMenu, CENTER, 0, Fyr_MM_Frame_RoundMenu:GetHeight()/5.5)
		Fyr_MM_PinDown:ClearAnchors()
		Fyr_MM_PinDown:SetAnchor(CENTER, Fyr_MM_Frame_RoundMenu, CENTER, -Fyr_MM_Time:GetWidth()/1.4-Fyr_MM_ZoomIn:GetWidth()/1.5, Fyr_MM_Frame_RoundMenu:GetHeight()/11)
		Fyr_MM_PinUp:ClearAnchors()
		Fyr_MM_PinUp:SetAnchor(CENTER, Fyr_MM_Frame_RoundMenu, CENTER, -Fyr_MM_Time:GetWidth()/1.4-Fyr_MM_ZoomIn:GetWidth()/1.5, Fyr_MM_Frame_RoundMenu:GetHeight()/11)
		Fyr_MM_Reload:ClearAnchors()
		Fyr_MM_Reload:SetAnchor(CENTER, Fyr_MM_Frame_RoundMenu, CENTER, Fyr_MM_Time:GetWidth()/1.4+Fyr_MM_ZoomOut:GetWidth()/1.5, Fyr_MM_Frame_RoundMenu:GetHeight()/11)
		Fyr_MM_Settings:ClearAnchors()
		Fyr_MM_Settings:SetAnchor(CENTER, Fyr_MM_Frame_RoundMenu, CENTER, Fyr_MM_Time:GetWidth()/1.4+2*(Fyr_MM_ZoomOut:GetWidth()/1.5), -Fyr_MM_Frame_RoundMenu:GetHeight()/32)
		Fyr_MM_ZoomIn:ClearAnchors()
		Fyr_MM_ZoomIn:SetAnchor(CENTER, Fyr_MM_Frame_RoundMenu, CENTER, -Fyr_MM_Time:GetWidth()/1.4, Fyr_MM_Frame_RoundMenu:GetHeight()/6.5)
		Fyr_MM_ZoomOut:ClearAnchors()
		Fyr_MM_ZoomOut:SetAnchor(CENTER, Fyr_MM_Frame_RoundMenu, CENTER, Fyr_MM_Time:GetWidth()/1.4, Fyr_MM_Frame_RoundMenu:GetHeight()/6.5)
		Fyr_MM_Menu:SetDimensions(Fyr_MM_Frame_RoundMenu:GetDimensions())
		Fyr_MM_Menu:ClearAnchors()
		Fyr_MM_Menu:SetAnchor(TOPLEFT, Fyr_MM, TOPLEFT, 0, Fyr_MM:GetHeight() - Fyr_MM:GetHeight()/9)
	else
		Fyr_MM_Frame_SquareMenu:ClearAnchors()
		Fyr_MM_Frame_SquareMenu:SetAnchor(TOPLEFT, Fyr_MM, TOPLEFT, 0, Fyr_MM:GetHeight() - Fyr_MM_Frame_SquareMenu:GetHeight()/4.5)
		Fyr_MM_Time:ClearAnchors()
		Fyr_MM_Time:SetDrawLayer(4)
		Fyr_MM_Time:SetAnchor(CENTER, Fyr_MM_Frame_SquareMenu, CENTER, 0, Fyr_MM_Frame_SquareMenu:GetHeight()/32)
		Fyr_MM_PinDown:ClearAnchors()
		Fyr_MM_PinDown:SetAnchor(CENTER, Fyr_MM_Frame_SquareMenu, CENTER, -Fyr_MM_Time:GetWidth()/1.4-Fyr_MM_ZoomIn:GetWidth()/1.5, Fyr_MM_Frame_SquareMenu:GetHeight()/48)
		Fyr_MM_PinUp:ClearAnchors()
		Fyr_MM_PinUp:SetAnchor(CENTER, Fyr_MM_Frame_SquareMenu, CENTER, -Fyr_MM_Time:GetWidth()/1.4-Fyr_MM_ZoomIn:GetWidth()/1.5, Fyr_MM_Frame_SquareMenu:GetHeight()/48)
		Fyr_MM_Reload:ClearAnchors()
		Fyr_MM_Reload:SetAnchor(CENTER, Fyr_MM_Frame_SquareMenu, CENTER, Fyr_MM_Time:GetWidth()/1.4+Fyr_MM_ZoomOut:GetWidth()/1.5, Fyr_MM_Frame_SquareMenu:GetHeight()/48)
		Fyr_MM_Settings:ClearAnchors()
		Fyr_MM_Settings:SetAnchor(CENTER, Fyr_MM_Frame_SquareMenu, CENTER, Fyr_MM_Time:GetWidth()/1.4+2*(Fyr_MM_ZoomOut:GetWidth()/1.5), Fyr_MM_Frame_SquareMenu:GetHeight()/48)
		Fyr_MM_ZoomIn:ClearAnchors()
		Fyr_MM_ZoomIn:SetAnchor(CENTER, Fyr_MM_Frame_SquareMenu, CENTER, -Fyr_MM_Time:GetWidth()/1.4, Fyr_MM_Frame_SquareMenu:GetHeight()/48)
		Fyr_MM_ZoomOut:ClearAnchors()
		Fyr_MM_ZoomOut:SetAnchor(CENTER, Fyr_MM_Frame_SquareMenu, CENTER, Fyr_MM_Time:GetWidth()/1.4, Fyr_MM_Frame_SquareMenu:GetHeight()/48)
		Fyr_MM_Menu:SetDimensions(Fyr_MM_Frame_SquareMenu:GetDimensions())
		Fyr_MM_Menu:ClearAnchors()
		Fyr_MM_Menu:SetAnchor(TOPLEFT, Fyr_MM, TOPLEFT, 0, Fyr_MM:GetHeight() - Fyr_MM_Frame_SquareMenu:GetHeight()/4.5)
	end
end

function MM_SetWheelMap(value)
if value == nil then return end
	if value ~= FyrMM.SV.WheelMap and Fyr_MM:GetWidth() ~= Fyr_MM:GetHeight() then
		FyrMM.SV.WheelMap = value
		MM_SetMapWidth(Fyr_MM:GetWidth())
	end
	FyrMM.SV.WheelMap = value
	Fyr_MM_Border:SetHidden(FyrMM.SV.WheelMap)
	Fyr_MM_Frame_Wheel:SetHidden(not FyrMM.SV.WheelMap)
	Fyr_MM_Wheel_Background:SetHidden(not FyrMM.SV.WheelMap)
	Fyr_MM_Frame_RoundMenu:SetHidden(not FyrMM.SV.WheelMap)
	Fyr_MM_Frame_SquareMenu:SetHidden(FyrMM.SV.WheelMap)
	Fyr_MM_Scroll_Fill:SetHidden(FyrMM.SV.WheelMap)
	MM_RearrangeMenu()
	FyrMM.UpdateMapTiles(true)
	FyrMM.Reload()
	Fyr_MM_Frame_Wheel:SetHidden(not FyrMM.SV.WheelMap)
	Fyr_MM_Frame_Control:SetHidden(not FyrMM.SV.WheelMap)
	if FyrMM.SV.WheelMap then
		FyrMM.Show_WheelScrolls()
	end
end

function MM_GetShowBorder()
	return FyrMM.SV.ShowBorder
end

function MM_SetShowBorder(value)
if value == nil then return end
	FyrMM.SV.ShowBorder = value
	if FyrMM.SV.ShowBorder ~= true then Fyr_MM_Border:SetAlpha(0) else Fyr_MM_Border:SetAlpha(100) end
end

function MM_GetHeading()
	return FyrMM.SV.Heading
end

function MM_SetHeading(value)
if value == nil then return end
	FyrMM.SV.Heading = value
end

function MM_GetClampedToScreen()
 return FyrMM.SV.ClampedToScreen
end

function MM_SetClampedToScreen(value)
if value == nil then return end
 FyrMM.SV.ClampedToScreen = value
 Fyr_MM:SetClampedToScreen(value)
end

function MM_GetMapRefreshRate()
 return FyrMM.SV.MapRefreshRate
end

function MM_GetPinRefreshRate()
 return FyrMM.SV.PinRefreshRate
end

function MM_GetViewRefreshRate()
 return FyrMM.SV.ViewRefreshRate
end

function MM_GetZoneRefreshRate()
 return FyrMM.SV.ZoneRefreshRate
end

function MM_GetKeepNetworkRefreshRate()
 return FyrMM.SV.KeepNetworkRefreshRate
end

function MM_GetPinTooltips()
	return FyrMM.SV.PinTooltips
end

function MM_SetBorderPinsOnlyAssisted(value)
	if value == nil then return end
	FyrMM.SV.BorderPinsOnlyAssisted = value
	if not FyrMM.Initialized then return end
	FyrMM.PlaceBorderPins()
end

function MM_SetBorderPinsOnlyLeader(value)
if value == nil then return end
	FyrMM.SV.BorderPinsOnlyLeader = value
	if not FyrMM.Initialized then return end
	FyrMM.PlaceBorderPins()
end

function MM_SetBorderPinsWaypoint(value)
if value == nil then return end
	FyrMM.SV.BorderPinsWaypoint = value
	if not FyrMM.Initialized then return end
	FyrMM.PlaceBorderPins()
end

function MM_SetPinTooltips(value)
if value == nil then return end
	FyrMM.SV.PinTooltips = value
end

function MM_GetMapStepping()
	if FyrMM.SV.MapStepping == nil then
		FyrMM.SV.MapStepping = 2
	end
	return FyrMM.SV.MapStepping
end


function MM_SetMapStepping(value)
if value == nil then return end
	FyrMM.SV.MapStepping = value
end


function MM_GetFastTravelEnabled()
	return FyrMM.SV.FastTravelEnabled
end

function MM_SetFastTravelEnabled(value)
if value == nil then return end
	FyrMM.SV.FastTravelEnabled = value
end

function MM_GetHidePvPPins()
	return FyrMM.SV.HidePvPPins
end

function MM_SetHidePvPPins(value)
if value == nil then return end
	FyrMM.SV.HidePvPPins = value
end

function MM_GetMouseWheel()
	return FyrMM.SV.MouseWheel
end

function MM_SetMouseWheel(value)
if value == nil then return end
	FyrMM.SV.MouseWheel = value
end

function MM_GetHideZoneLabel()
	return FyrMM.SV.HideZoneLabel
end

function MM_SetHideZoneLabel(value)
if value == nil then return end
	FyrMM.SV.HideZoneLabel = value
	Fyr_MM_ZoneFrame:SetHidden(value)
end

function MM_SetInCombatAutoHide(value)
if value == nil then return end
	FyrMM.SV.InCombatAutoHide = value
end

function MM_SetAfterCombatUnhideDelay(value)
if value == nil then return end
	FyrMM.SV.AfterCombatUnhideDelay = value
end


function MM_GetHideZoomLevel()
	return FyrMM.SV.HideZoomLevel
end

function MM_SetHideZoomLevel(value)
if value == nil then return end
	FyrMM.SV.HideZoomLevel = value
	if FyrMM.SV.HideZoomLevel == true then Fyr_MM_ZoomLevel:SetAlpha(0) else Fyr_MM_ZoomLevel:SetAlpha(100) end
end

function  MM_SetShowClock(value)
if value == nil then return end
	FyrMM.SV.ShowClock = value
end

function  MM_SetShowFPS(value)
if value == nil then return end
	FyrMM.SV.ShowFPS = value
end

function  MM_SetLeaderPin(value)
if value == nil then return end
	FyrMM.SV.LeaderPin = value
end

function  MM_SetLeaderPinSize(value)
if value == nil then return end
	FyrMM.SV.LeaderPinSize = value
end

function MM_SetLeaderPinColor(r, g, b, a)
if r == nil then return end
	FyrMM.SV.LeaderPinColor.r = r
	FyrMM.SV.LeaderPinColor.g = g
	FyrMM.SV.LeaderPinColor.b = b
	FyrMM.SV.LeaderPinColor.a = a
end

function MM_SetLeaderDeadPinColor(r, g, b, a)
if r == nil then return end
	FyrMM.SV.LeaderDeadPinColor.r = r
	FyrMM.SV.LeaderDeadPinColor.g = g
	FyrMM.SV.LeaderDeadPinColor.b = b
	FyrMM.SV.LeaderDeadPinColor.a = a
end

function  MM_SetMemberPin(value)
if value == nil then return end
	FyrMM.SV.MemberPin = value
end

function MM_SetLockPosition(value)
	if value == nil then return end
	FyrMM.SV.LockPosition = value
	if FyrMM.SV.LockPosition then
		Fyr_MM_PinDown:SetHidden(true)
		Fyr_MM_PinUp:SetHidden(false)
	else
		Fyr_MM_PinDown:SetHidden(false)
		Fyr_MM_PinUp:SetHidden(true)
	end
	Fyr_MM:SetMovable(not value)
end

function  MM_SetMemberPinSize(value)
if value == nil then return end
	FyrMM.SV.MemberPinSize = value
end

function MM_SetMemberPinColor(r, g, b, a)
if r == nil then return end
	FyrMM.SV.MemberPinColor.r = r
	FyrMM.SV.MemberPinColor.g = g
	FyrMM.SV.MemberPinColor.b = b
	FyrMM.SV.MemberPinColor.a = a
end

function MM_SetMemberDeadPinColor(r, g, b, a)
if r == nil then return end
	FyrMM.SV.MemberDeadPinColor.r = r
	FyrMM.SV.MemberDeadPinColor.g = g
	FyrMM.SV.MemberDeadPinColor.b = b
	FyrMM.SV.MemberDeadPinColor.a = a
end

function MM_SetUndiscoveredPOIPinColor(r, g, b, a)
if r == nil then return end
	FyrMM.SV.UndiscoveredPOIPinColor.r = r
	FyrMM.SV.UndiscoveredPOIPinColor.g = g
	FyrMM.SV.UndiscoveredPOIPinColor.b = b
	FyrMM.SV.UndiscoveredPOIPinColor.a = a
end

function MM_SetMapSettings(Table)
	if Table == nil then return end
	FyrMM.SV.MapSettings = Table
end

function MM_SetZoneNameColor(r, g, b, a)
if r == nil then return end
	FyrMM.SV.ZoneNameColor.r = r
	FyrMM.SV.ZoneNameColor.g = g
	FyrMM.SV.ZoneNameColor.b = b
	FyrMM.SV.ZoneNameColor.a = a
	Fyr_MM_Zone:SetColor(r, g, b, a)
end

function MM_SetPositionColor(r, g, b, a)
if r == nil then return end
	FyrMM.SV.PositionColor.r = r
	FyrMM.SV.PositionColor.g = g
	FyrMM.SV.PositionColor.b = b
	FyrMM.SV.PositionColor.a = a
	Fyr_MM_Position:SetColor(r, g, b, a)
	Fyr_MM_SpeedLabel:SetColor(r, g, b, a)
end

function MM_SetCoordinatesLocation(value)
	if value == nil then return end
	FyrMM.SV.CorrdinatesLocation = value
	if FyrMM.SV.CorrdinatesLocation == "Free" then
			Fyr_MM_Coordinates:SetMovable(true)
			Fyr_MM_Coordinates:SetMouseEnabled(true)
			if FyrMM.SV.CoordinatesAnchor ~= nil then
				MM_SetCoordinatesAnchor(FyrMM.SV.CoordinatesAnchor)
			end
	else
		if FyrMM.SV.CorrdinatesLocation == "Top" then
			Fyr_MM_Coordinates:ClearAnchors()
			Fyr_MM_Coordinates:SetAnchor(TOP, Fyr_MM, TOP, 0, 0)
			Fyr_MM_Position:ClearAnchors()
			Fyr_MM_Position:SetAnchor(CENTER, Fyr_MM_Coordinates, CENTER, 0, 0)
			Fyr_MM_Position_Background:ClearAnchors()
			Fyr_MM_Position_Background:SetAnchor(CENTER, Fyr_MM_Position, CENTER, 0, 0)
			Fyr_MM_Coordinates:SetMovable(false)
		else
			Fyr_MM_Coordinates:ClearAnchors()
			Fyr_MM_Coordinates:SetAnchor(BOTTOM, Fyr_MM, BOTTOM, 0, 0)
			Fyr_MM_Position:ClearAnchors()
			Fyr_MM_Position:SetAnchor(CENTER, Fyr_MM_Coordinates, CENTER, 0, 0)
			Fyr_MM_Position_Background:ClearAnchors()
			Fyr_MM_Position_Background:SetAnchor(CENTER, Fyr_MM_Position, CENTER, 0, 0)
			Fyr_MM_Coordinates:SetMovable(false)
		end
	end
end

function MM_GetCoordinatesAnchor()
	return FyrMM.SV.CoordinatesAnchor[1], GetControl(FyrMM.SV.CoordinatesAnchor[2]), FyrMM.SV.CoordinatesAnchor[3], FyrMM.SV.CoordinatesAnchor[4], FyrMM.SV.CoordinatesAnchor[5]
end

function MM_SetCoordinatesAnchor(anchor)
	if anchor == nil then return end
	if not anchor[2] then anchor[2] = "Fyr_MM" end
	FyrMM.SV.CoordinatesAnchor = anchor
	if GetControl(FyrMM.SV.CoordinatesAnchor[2]) ~= nil and FyrMM.SV.CorrdinatesLocation == "Free" then
		Fyr_MM_Coordinates:ClearAnchors()
		Fyr_MM_Coordinates:SetAnchor(MM_GetCoordinatesAnchor())
	end
end

function MM_SetPositionBackground(value)
	if value == nil then return end
	FyrMM.SV.PositionBackground = value
	Fyr_MM_Position_Background:SetHidden(not FyrMM.SV.PositionBackground)
	Fyr_MM_Speed_Background:SetHidden(not FyrMM.SV.PositionBackground)
end

function MM_GetZoneFrameAnchor()
	return FyrMM.SV.ZoneFrameAnchor[1], GetControl(FyrMM.SV.ZoneFrameAnchor[2]), FyrMM.SV.ZoneFrameAnchor[3], FyrMM.SV.ZoneFrameAnchor[4], FyrMM.SV.ZoneFrameAnchor[5]
end

function MM_SetShowZoneBackground(value)
	if value == nil then return end
	FyrMM.SV.ShowZoneBackground = value
	Fyr_MM_Zone_Background:SetHidden(not FyrMM.SV.ShowZoneBackground)
end

function MM_SetZoneFrameLocationOption(value)
	if value == nil then return end
	FyrMM.SV.ZoneFrameLocationOption = value
	if FyrMM.SV.ZoneFrameLocationOption == "Default" then
		Fyr_MM_ZoneFrame:ClearAnchors()
		if FyrMM.SV.MenuDisabled then
			Fyr_MM_ZoneFrame:SetAnchor(TOP, Fyr_MM_Border, BOTTOM)
		else
			Fyr_MM_ZoneFrame:SetAnchor(TOP, Fyr_MM_Menu, BOTTOM, 0, -Fyr_MM_Menu:GetHeight()/5)
		end
		Fyr_MM_ZoneFrame:SetMovable(false)
	else
		if FyrMM.SV.ZoneFrameAnchor ~= nil then
			Fyr_MM_ZoneFrame:ClearAnchors()
			Fyr_MM_ZoneFrame:SetMovable(true)
			Fyr_MM_ZoneFrame:SetMouseEnabled(true)
			Fyr_MM_ZoneFrame:SetAnchor(MM_GetZoneFrameAnchor())
		end
	end 
end

function MM_SetZoneFrameAnchor(anchor)
	if anchor == nil then return end
	if not anchor[2] then anchor[2] = "Fyr_MM" end
	FyrMM.SV.ZoneFrameAnchor = anchor
	if GetControl(FyrMM.SV.ZoneFrameAnchor[2]) ~= nil and FyrMM.SV.ZoneFrameLocationOption == "Free" then
		Fyr_MM_ZoneFrame:ClearAnchors()
		Fyr_MM_ZoneFrame:SetAnchor(MM_GetZoneFrameAnchor())
	end
end

function MM_SetZoneFont()
	if FyrMM.SV.ZoneFont and FyrMM.SV.ZoneFontHeight and FyrMM.SV.ZoneFontStyle then
		Fyr_MM_Zone:SetFont(FyrMM.Fonts[FyrMM.SV.ZoneFont].."|"..tostring(FyrMM.SV.ZoneFontHeight).."|"..FyrMM.SV.ZoneFontStyle)
	end
end

function MM_SetPositionFont()
	if FyrMM.SV.PositionFont and FyrMM.SV.PositionHeight and FyrMM.SV.PositionFontStyle then
		Fyr_MM_Position:SetFont(FyrMM.Fonts[FyrMM.SV.PositionFont].."|"..tostring(FyrMM.SV.PositionHeight).."|"..FyrMM.SV.PositionFontStyle)
		Fyr_MM_SpeedLabel:SetFont(FyrMM.Fonts[FyrMM.SV.PositionFont].."|"..tostring(FyrMM.SV.PositionHeight).."|"..FyrMM.SV.PositionFontStyle)
	end
end

function MM_SetWheelTexture(value)
	if value == nil then return end
	FyrMM.SV.WheelTexture = value
	if FyrMM.WheelTextures[FyrMM.SV.WheelTexture] then
		Fyr_MM_Frame_Wheel:SetTexture(FyrMM.WheelTextures[FyrMM.SV.WheelTexture])
	end
end

function MM_SetMenuTexture(value)
	if value == nil then return end
	FyrMM.SV.MenuTexture = value
	if FyrMM.MenuTextures[FyrMM.SV.MenuTexture] then
		Fyr_MM_Frame_RoundMenu:SetTexture(FyrMM.MenuTextures[FyrMM.SV.MenuTexture].Round)
		Fyr_MM_Frame_SquareMenu:SetTexture(FyrMM.MenuTextures[FyrMM.SV.MenuTexture].Square)
	end
end

function MM_WheelModeDefaults()
	MM_SetWheelMap(true)
	MM_SetWheelTexture("Moosetrax Astro Wheel")
	MM_SetBorderPins(true)
	MM_SetBorderPinsOnlyAssisted(true)
	MM_SetRotateMap(false)
end

function MM_SquareModeDefaults()
	MM_SetWheelMap(false)
	MM_SetBorderPins(true)
	MM_SetBorderPinsOnlyAssisted(true)
	MM_SetRotateMap(false)
	FyrMM.UpdateMapTiles(true)
end

function MM_CreateDataTables()
FyrMM.Defaults = {
		["HideZoneLabel"] = false,
		["HideZoomLevel"] = false,
		["ShowBorder"] = true,
		["ClampedToScreen"] = true,
		["MapHeight"] = 280,
		["MapWidth"] = 280,
		["position"] = {
			["point"] = TOPLEFT,
			["relativePoint"] = TOPLEFT,
			["offsetX"] = 0,
			["offsetY"] = 0
		},
		["MapAlpha"] = 100,
		["Heading"] = "CAMERA",
		["PinScale"] = 75,
		["PinTooltips"] = true,
		["ShowPosition"] = true,
		["FastTravelEnabled"] = false,
		["HidePvPPins"] = false,
		["MouseWheel"] = true,
		["MapRefreshRate"] = 60,
		["PinRefreshRate"] = 1200,
		["ViewRefreshRate"] = 2500,
		["ZoneRefreshRate"] = 100,
		["KeepNetworkRefreshRate"] = 2000,
		["ShowClock"] = false,
		["ShowFPS"] = false,
		["InCombatState"] =true,
		["LeaderPin"] = "Default",
		["LeaderPinSize"] = 32,
		["ViewRangeFiltering"] = false,	
		["CustomPinViewRange"] = 250,
		["PPStyle"] = "Separate Player & Camera",
		["PPTextures"] = "ESO UI Worldmap",
		["MenuDisabled"] = false,
		["MenuTexture"] = "Default",
		["LeaderPinColor"] = {
			["r"] = 1,
			["g"] = 1,
			["b"] = 1,
			["a"] = 1
		},
		["LeaderDeadPinColor"] = {
			["r"] = 1,
			["g"] = 1,
			["b"] = 1,
			["a"] = 1
		},
		["MemberPin"] = "Default",
		["MemberPinSize"] = 32,
		["MemberPinColor"] = {
			["r"] = 1,
			["g"] = 1,
			["b"] = 1,
			["a"] = 1
		},
		["MemberDeadPinColor"] = {
			["r"] = 1,
			["g"] = 1,
			["b"] = 1,
			["a"] = 1
		},
		["ShowGroupLabels"] = false,
		["PositionColor"] = {
			["r"] = 0.996078431372549,
			["g"] = 0.92,
			["b"] = 0.3137254901960784,
			["a"] = 1
		},
		["ZoneNameColor"] = {
			["r"] = 1,
			["g"] = 1,
			["b"] = 1,
			["a"] = 1
		},
		["UndiscoveredPOIPinColor"] = {
			["r"] = .7,
			["g"] = .7,
			["b"] = .3,
			["a"] = .6
		},
		["MapTable"] = {},
		["MapStepping"] = 2,
		["ZoomIncrement"] = 1,
		["DefaultZoomLevel"] = 10,
		["InCombatAutoHide"] = false,
		["AfterCombatUnhideDelay"] = 5,
		["LockPosition"] = false,
		["UseOriginalAPI"] = true,
		["ShowUnexploredPins"] = true,
		["RotateMap"] = false,
		["BorderPins"] = false,
		["BorderPinsWaypoint"] = false,
		["BorderPinsBank"] = false,
		["BorderPinsStables"] = false,
		["BorderWayshrine"] = false,
		["BorderTreasures"] = false,
		["BorderQuestGivers"] = false,
		["BorderCrafting"] = false,
		["WheelMap"] = false,
		["CorrdinatesLocation"] = "Top",
		["ZoneNameContents"] = "Classic (Map only)",
		["ZoneFontHeight"] = 18,
		["ZoneFont"] = "Univers 57",
		["ZoneFontStyle"] = "soft-shadow-thick",
		["ZoneFrameLocationOption"] = "Default",
		["PositionHeight"] = 18,
		["PositionFont"] = "Univers 57",
		["StartupInfo"] = false,
		["PositionFontStyle"] = "soft-shadow-thick",
		["Siege"] = false,
		["ShowSpeed"] = false,
		["SpeedUnit"] = "ft/s",
		["ChunkSize"] = 200,
		["ChunkDelay"] = 10,
		["WorldMapRefresh"] = true,
		["MapSizes"] = {},
		["ZoomTable"] = {},}

		FyrMM.WheelTextures = {
		["Deathangel RMM Wheel"] = "MiniMap/Textures/wheel.dds",
		["Moosetrax Normal Wheel"] = "MiniMap/Textures/MNormalWheel.dds",
		["Moosetrax Normal Lense Wheel"] = "MiniMap/Textures/MNormalLense1Wheel.dds",
		["Moosetrax Astro Wheel"] = "MiniMap/Textures/MAstroWheel.dds",
		["Moosetrax Astro Lense Wheel"] = "MiniMap/Textures/MAstroLense1Wheel.dds",
		["Vixion Black"] = "MiniMap/Textures/Vixion_Black.dds",
		["Vixion Black Flat"] = "MiniMap/Textures/Vixion_BlackFlat.dds",
		["Vixion Black Gold"] = "MiniMap/Textures/Vixion_BlackGold.dds",
		["Vixion Flat"] = "MiniMap/Textures/Vixion_Flat.dds",
		["Vixion Gold"] = "MiniMap/Textures/Vixion_Gold.dds",
		["Vixion Normal"] = "MiniMap/Textures/Vixion_Normal.dds",
		["Vixion Gloss"] = "MiniMap/Textures/Vixion_Gloss.dds",
		["Vixion Shiny"] = "MiniMap/Textures/Vixion_Shiny.dds",
		["Vixion Shiny Gold"] = "MiniMap/Textures/Vixion_ShinyGold.dds",
		["Vixion Smooth"] = "MiniMap/Textures/Vixion_Smooth.dds",
		["Vixion Simple"] = "MiniMap/Textures/Vixion_Simple.dds",
		["Vixion Optic"] = "MiniMap/Textures/Vixion_Optic.dds",
		["Vixion Noble"] = "MiniMap/Textures/Vixion_Noble.dds",
		["Vixion Noble Gold"] = "MiniMap/Textures/Vixion_Noble_Gold.dds",
		["Rhymer Gold"] = "MiniMap/Textures/Rhymer_Gold.dds",
		["Rhymer Steel"] = "MiniMap/Textures/Rhymer_Steel.dds",
		["Rhymer Wood"] = "MiniMap/Textures/Rhymer_Wood.dds", }

		FyrMM.WheelTextureList = {"Deathangel RMM Wheel", "Moosetrax Normal Wheel", "Moosetrax Normal Lense Wheel", "Moosetrax Astro Wheel", "Moosetrax Astro Lense Wheel", "Vixion Black", "Vixion Black Flat", "Vixion Black Gold", "Vixion Flat", "Vixion Gold", "Vixion Normal", "Vixion Gloss", "Vixion Shiny", "Vixion Shiny Gold", "Vixion Smooth", "Vixion Simple", "Vixion Optic", "Vixion Noble", "Vixion Noble Gold", "Rhymer Gold", "Rhymer Steel", "Rhymer Wood", }

		FyrMM.FontList = {"Arial Narrow","Consolas","ESO Cartographer","Fontin Bold","Fontin Italic","Fontin Regular","Fontin SmallCaps","ProseAntique","Skyrim Handwritten","Trajan Pro","Univers 55","Univers 57","Univers 67",}
		FyrMM.FontStyles = {"normal", "outline", "thick-outline", "shadow", "soft-shadow-thick", "soft-shadow-thin"}
		FyrMM.MenuTextures = {	["Default"] = {["Square"] = "MiniMap/Textures/MiniMap_SquareMenuFrame_Default.dds", ["Round"] = "MiniMap/Textures/MiniMap_RoundMenuFrame_Default.dds",},
								["Black"] = {["Square"] = "MiniMap/Textures/MiniMap_SquareMenuFrame_Black.dds", ["Round"] = "MiniMap/Textures/MiniMap_RoundMenuFrame_Black.dds",},
								["Red"] = {["Square"] = "MiniMap/Textures/MiniMap_SquareMenuFrame_Red.dds", ["Round"] = "MiniMap/Textures/MiniMap_RoundMenuFrame_Red.dds",},
								["Gold"] = {["Square"] = "MiniMap/Textures/MiniMap_SquareMenuFrame_Gold.dds", ["Round"] = "MiniMap/Textures/MiniMap_RoundMenuFrame_Gold.dds",},}
		FyrMM.MenuTextureList = {"Default", "Black", "Red", "Gold",}
		FyrMM.CSProviders = {"Clothing", "Schneidertisch", "couture", "Blacksmithing", "Schmiedestelle", "forge", "Woodworking", "Schreinerbank", "bois", "Alchemy", "Alchemietisch", "d'alchimie", "Enchanting", "Verzauberungstisch", "d'enchantement",}
		FyrMM.SpeedUnits = {"ft/s", "m/s", "%",}
		FyrMM.MapList = {
						["abagarlas_base_0"] = 1,
						["abahslanding_base_0"] = 2,
						["abahslanding_sulima_base_0"] = 3,
						["abahslanding_velmont_base_0"] = 4,
						["aba-loria_base_0"] = 5,
						["abamath_base_0"] = 6,
						["abandonedmine_base_0"] = 7,
						["aetherianarchivebottom_base_0"] = 8,
						["aetherianarchiveend_base_0"] = 9,
						["aetherianarchiveislanda_base_0"] = 10,
						["aetherianarchiveislandb_base_0"] = 11,
						["aetherianarchiveislandc_base_0"] = 12,
						["aetherianarchivemiddle_base_0"] = 13,
						["albeceansea_base_0"] = 14,
						["alcairecastle_base_0"] = 15,
						["aldcroft_base_0"] = 16,
						["aldunz_base_0"] = 17,
						["alikr_base_0"] = 18,
						["alkiroutlawrefuge_base_0"] = 19,
						["altencorimont_base_0"] = 20,
						["ancientcarzogsdemise_base_0"] = 21,
						["angofssanctum_base_0"] = 22,
						["anvilcity_base_0"] = 23,
						["aphrenshold_base_0"] = 24,
						["apocryphasgate_base_0"] = 25,
						["apothacarium_base_0"] = 26,
						["apothacarium_map_0"] = 27,
						["arcwindpoint_base_0"] = 28,
						["arenasclockwork2_base_0"] = 29,
						["arenasclockworkint_base_0"] = 30,
						["arenaslavacaveinterior_base_0"] = 31,
						["arenaslobbyexterior_base_0"] = 32,
						["arenasmephalaexterior_base_0"] = 33,
						["arenasmurkmirecaveint_base_0"] = 34,
						["arenasmurkmirecaveinter_base_0"] = 35,
						["arenasmurkmireexterior_base_0"] = 36,
						["arenasoblivionexterior_base_0"] = 37,
						["arenasshiveringisles_base_0"] = 38,
						["arenaswrothgarexterior_base_0"] = 39,
						["arenthia_base_0"] = 40,
						["argentmine_base_0"] = 41,
						["argentmine2_base_0"] = 42,
						["arxcorinium_base_0"] = 43,
						["ashaba_base_0"] = 44,
						["ashmountain_base_0"] = 45,
						["atanazruins_base_0"] = 46,
						["ateliertwicebornstar_base_0"] = 47,
						["auridon_base_0"] = 48,
						["auridonoutlawrefuge_base_0"] = 49,
						["ava_whole_0"] = 50,
						["avancheznel_base_0"] = 51,
						["baandaritradingpost_base_0"] = 52,
						["badmanscave_base_0"] = 53,
						["badmansend_base_0"] = 54,
						["badmansstart_base_0"] = 55,
						["bahrahasgloom_base_0"] = 56,
						["balamath_base_0"] = 57,
						["balamathairmonarchcham_base_0"] = 58,
						["balamathlibrary_base_0"] = 59,
						["balfoyen_base_0"] = 60,
						["banditden1_base_0"] = 61,
						["banditden1_main_base_0"] = 62,
						["banditden1_room1_base_0"] = 63,
						["banditden1_room2_base_0"] = 64,
						["banditden1_room3_base_0"] = 65,
						["banditden10_base_0"] = 66,
						["banditden11_base_0"] = 67,
						["banditden11f2_base_0"] = 68,
						["banditden11r1_base_0"] = 69,
						["banditden11r2_base_0"] = 70,
						["banditden11r3_base_0"] = 71,
						["banditden12_base_0"] = 72,
						["banditden13_base_0"] = 73,
						["banditden2_base_0"] = 74,
						["banditden2_room1_base_0"] = 75,
						["banditden2_room2_base_0"] = 76,
						["banditden2_room3_base_0"] = 77,
						["banditden2_room4_base_0"] = 78,
						["banditden3_base_0"] = 79,
						["banditden3_base_cave_0"] = 80,
						["banditden3_base_room1_0"] = 81,
						["banditden3_base_room2_0"] = 82,
						["banditden3_base_room3_0"] = 83,
						["banditden4_base_0"] = 84,
						["banditden4_room1_base_0"] = 85,
						["banditden4_room2_base_0"] = 86,
						["banditden4_room3_base_0"] = 87,
						["banditden4_room4_base_0"] = 88,
						["banditden4_room5_base_0"] = 89,
						["banditden4_room6_base_0"] = 90,
						["banditden5_base_0"] = 91,
						["banditden5_room1_base_0"] = 92,
						["banditden5_room2_base_0"] = 93,
						["banditden5_room3_base_0"] = 94,
						["banditden5_room4_base_0"] = 95,
						["banditden6_base_0"] = 96,
						["banditden6_room1_base_0"] = 97,
						["banditden6_room2_base_0"] = 98,
						["banditden6_room3_base_0"] = 99,
						["banditden6_room4_base_0"] = 100,
						["banditden6_room5_base_0"] = 101,
						["banditden7_base_0"] = 102,
						["banditden8_base_0"] = 103,
						["banditden8_room1_base_0"] = 104,
						["banditden8_room2_base_0"] = 105,
						["banditden8_room3_base_0"] = 106,
						["banditden9_base_0"] = 107,
						["banditdenoneone_base_0"] = 108,
						["bangkorai_base_0"] = 109,
						["bangkoraigarrisonbtm_base_0"] = 110,
						["bangkoraigarrisonl_base_0"] = 111,
						["bangkoraigarrisonsewer_base_0"] = 112,
						["bangkoraigarrisontop_base_0"] = 113,
						["bangkoraioutlawrefuge_base_0"] = 114,
						["barkbitecave_base_0"] = 115,
						["barkbitemine_base_0"] = 116,
						["barrowtrench_base_0"] = 117,
						["bearclawmine_base_0"] = 118,
						["belkarth_base_0"] = 119,
						["bergama_base_0"] = 120,
						["betnihk_base_0"] = 121,
						["bewan_base_0"] = 122,
						["bisnensel_base_0"] = 123,
						["blackforge_base_0"] = 124,
						["blackhearthavenarea1_base_0"] = 125,
						["blackhearthavenarea2_base_0"] = 126,
						["blackhearthavenarea3_base_0"] = 127,
						["blackhearthavenarea4_base_0"] = 128,
						["blackvineruins_base_0"] = 129,
						["bleakrock_base_0"] = 130,
						["bleakrockvillage_base_0"] = 131,
						["blessedcrucible1_base_0"] = 132,
						["blessedcrucible2_base_0"] = 133,
						["blessedcrucible3_base_0"] = 134,
						["blessedcrucible4_base_0"] = 135,
						["blessedcrucible5_base_0"] = 136,
						["blessedcrucible6_base_0"] = 137,
						["blessedcrucible7_base_0"] = 138,
						["blisslower_base_0"] = 139,
						["blisstop_base_0"] = 140,
						["bloodyknoll_base_0"] = 141,
						["bloodmaynecave_base_0"] = 142,
						["bloodmatronscryptgroup_base_0"] = 143,
						["bloodmatronscryptsingle_base_0"] = 144,
						["bloodthornlair_base_0"] = 145,
						["bonegrinder_base_0"] = 146,
						["boneorchard_base_0"] = 147,
						["bonerock_caverns_base_0"] = 148,
						["bonesnapruins_base_0"] = 149,
						["bonesnapruinssecret_base_0"] = 150,
						["bonestrewncrest_base_0"] = 151,
						["brackenleaf_base_0"] = 152,
						["breaghafinlower_base_0"] = 153,
						["breaghafinupper_base_0"] = 154,
						["breakneckcave_base_0"] = 155,
						["brokenhelm_base_0"] = 156,
						["brokentuskcave_base_0"] = 157,
						["bthanual_base_0"] = 158,
						["bthzark_base_0"] = 159,
						["buraniim_base_0"] = 160,
						["burriedsands_base_0"] = 161,
						["burrootkwamamine_base_0"] = 162,
						["campgushnukbur_base_0"] = 163,
						["capstonecave_base_0"] = 164,
						["caracdena_base_0"] = 165,
						["carzogsdemise_base_0"] = 166,
						["castleoftheworm1_base_0"] = 167,
						["castleoftheworm2_base_0"] = 168,
						["castleoftheworm3_base_0"] = 169,
						["castleoftheworm4_base_0"] = 170,
						["castleoftheworm5_base_0"] = 171,
						["cathbedraud_base_0"] = 172,
						["catseyequay_base_0"] = 173,
						["caveofbrokensails_base_0"] = 174,
						["caveoftrophies_base_0"] = 175,
						["caveoftrophiesupper_base_0"] = 176,
						["ch_the_everfull_flagon_0"] = 177,
						["chambersofloyalty_base_0"] = 178,
						["charredridge_base_0"] = 179,
						["chateaumasterbedroom_base_0"] = 180,
						["chateauravenousrodent_base_0"] = 181,
						["cheesemongershollow_base_0"] = 182,
						["chidmoskaruins_base_0"] = 183,
						["chiselshriek_base_0"] = 184,
						["circusofcheerfulslaughter_base_0"] = 185,
						["cityofashboss_base_0"] = 186,
						["cityofashmain_base_0"] = 187,
						["clawsstrike_base_0"] = 188,
						["coldharbour_base_0"] = 189,
						["coldperchcavern_base_0"] = 190,
						["coldrockdiggings_base_0"] = 191,
						["coloredrooms_base_0"] = 192,
						["coloviancrossing_base_0"] = 193,
						["coralheartchamber_base_0"] = 194,
						["cormountprison_base_0"] = 195,
						["coromount_base_0"] = 196,
						["corpsegarden_base_0"] = 197,
						["courtofcontempt_base_0"] = 198,
						["crackedwoodcave_base_0"] = 199,
						["craglorn_base_0"] = 200,
						["craglorn_dragonstar_base_0"] = 201,
						["craglornoutlawrefuge_base_0"] = 202,
						["cragwallow_base_0"] = 203,
						["crestshademine_base_0"] = 204,
						["crgwamasucave_base_0"] = 205,
						["crimsoncove_base_0"] = 206,
						["cryptofhearts_base_0"] = 207,
						["cryptofheartsheroic_base_0"] = 208,
						["cryptofheartsheroicboss_0"] = 209,
						["cryptoftarishzi_base_0"] = 210,
						["cryptoftarishzi2_base_0"] = 211,
						["cryptoftarishzizone_base_0"] = 212,
						["cryptoftheexiles_base_0"] = 213,
						["cryptwatchfort_base_0"] = 214,
						["crosswych_base_0"] = 215,
						["crosswychmine_base_0"] = 216,
						["crowswood_base_0"] = 217,
						["crowswooddungeon_base_0"] = 218,
						["daggerfall_base_0"] = 219,
						["darkshadecaverns_base_0"] = 220,
						["darkshadecavernsheroic_base_0"] = 221,
						["davonswatch_base_0"] = 222,
						["davonswatchcrypt_base_0"] = 223,
						["deadmansdrop_base_0"] = 224,
						["deepcragden_base_0"] = 225,
						["delsclaim_base_0"] = 226,
						["depravedgrotto_base_0"] = 227,
						["deshaan_base_0"] = 228,
						["desolatecave_base_0"] = 229,
						["desolationsend_base_0"] = 230,
						["despair_base_0"] = 231,
						["dessicatedcave_base_0"] = 232,
						["dhalmora_base_0"] = 233,
						["direfrostkeep_base_0"] = 234,
						["direfrostkeepheroic_base_0"] = 235,
						["direfrostkeepsummit_base_0"] = 236,
						["divadschagrinmine_base_0"] = 237,
						["dokrintemple_base_0"] = 238,
						["doomcragground_base_0"] = 239,
						["doomcragmiddle_base_0"] = 240,
						["doomcragshroudedpass_base_0"] = 241,
						["doomcragtop_base_0"] = 242,
						["dourstonevault_base_0"] = 243,
						["dragonstararena01_0"] = 244,
						["dragonstararena01_base_0"] = 245,
						["dragonstararena02_base_0"] = 246,
						["dragonstararena03_base_0"] = 247,
						["dragonstararena04_base_0"] = 248,
						["dragonstararena05_base_0"] = 249,
						["dragonstararena06_base_0"] = 250,
						["dragonstararena07_base_0"] = 251,
						["dragonstararena08_base_0"] = 252,
						["dragonstararena09_base_0"] = 253,
						["dragonstararena09crypt_base_0"] = 254,
						["dragonstararena10_base_0"] = 255,
						["dragonstararenavault_base_0"] = 256,
						["dresankeep_base_0"] = 257,
						["dune_base_0"] = 258,
						["east_hut_portal_cave_base_0"] = 259,
						["eastelsweyrgate_base_0"] = 260,
						["eastmarch_base_0"] = 261,
						["eastmarchrefuge_base_0"] = 262,
						["eboncrypt_base_0"] = 263,
						["ebonheart_base_0"] = 264,
						["ebonmeretower_base_0"] = 265,
						["echocave_base_0"] = 266,
						["edraldundercroft_base_0"] = 267,
						["edraldundercroftdomed_base_0"] = 268,
						["eidolonshollow2_base_0"] = 269,
						["eyeschamber_base_0"] = 270,
						["eyevea_base_0"] = 271,
						["eldenhollow_base_0"] = 272,
						["eldenhollowheroic1_base_0"] = 273,
						["eldenhollowheroic2_base_0"] = 274,
						["eldenrootcrafting_base_0"] = 275,
						["eldenrootfightersguildown_base_0"] = 276,
						["eldenrootfightersguildup_base_0"] = 277,
						["eldenrootgroundfloor_base_0"] = 278,
						["eldenrootmagesguild_base_0"] = 279,
						["eldenrootmagesguilddown_base_0"] = 280,
						["eldenrootservices_base_0"] = 281,
						["eldenrootthroneroom_base_0"] = 282,
						["elinhirmagevision_base_0"] = 283,
						["elinhirsewerworks_base_0"] = 284,
						["emberflintmine_base_0"] = 285,
						["emericsdquagmireportion_base_0"] = 286,
						["emericsdream_base_0"] = 287,
						["emericsdreampart2_base_0"] = 288,
						["enduum_base_0"] = 289,
						["entilasfolly_base_0"] = 290,
						["erokii_base_0"] = 291,
						["evermore_base_0"] = 292,
						["exarchsstronghold_base_0"] = 293,
						["exilesbarrow_map_base_0"] = 294,
						["ezduiin_base_0"] = 295,
						["falinesticave_base_0"] = 296,
						["fallowstonevault_base_0"] = 297,
						["faltoniasmine_base_0"] = 298,
						["farangelsdelve_base_0"] = 299,
						["fardirsfolly_base_0"] = 300,
						["fearfang_base_0"] = 301,
						["fevered_mews_base_0"] = 302,
						["fevered_mews_subzone_base_0"] = 303,
						["fharunprison_base_0"] = 304,
						["fharunstronghold01_base_0"] = 305,
						["fharunstronghold02_base_0"] = 306,
						["fharunstronghold03_base_0"] = 307,
						["fharunstronghold03b_base_0"] = 308,
						["firsthold_base_0"] = 309,
						["flyleafcatacombs_base_0"] = 310,
						["forelhost_base_0"] = 311,
						["forgottencrypts_base_0"] = 312,
						["fortamol_base_0"] = 313,
						["fortarand_base_0"] = 314,
						["fortgreenwall_base_0"] = 315,
						["fortmorvunskar_base_0"] = 316,
						["fortsphinxmoth_base_0"] = 317,
						["fortvirakruin_base_0"] = 318,
						["foundryofwoe_base_0"] = 319,
						["frostbreakfortint_map_base_0"] = 320,
						["frostmonarchlair_base_0"] = 321,
						["fulstromcatacombs_base_0"] = 322,
						["fulstromhomestead_base_0"] = 323,
						["fungalgrotto_base_0"] = 324,
						["fungalgrottosecretroom_base_0"] = 325,
						["gandranen_base_0"] = 326,
						["garlasagea_base_0"] = 327,
						["giantsrun_base_0"] = 328,
						["gilvardelleabandoncave_0"] = 329,
						["gladeofthedivineasakala_base_0"] = 330,
						["gladeofthedivineshivering_base_0"] = 331,
						["gladeofthedivinevuldngrav_base_0"] = 332,
						["gladiatorsassembly_base_0"] = 333,
						["glenumbra_base_0"] = 334,
						["glenumbracamlornkeep_base_0"] = 335,
						["glenumbraoutlawrefuge_base_0"] = 336,
						["goblinminesend_base_0"] = 337,
						["goblinminesstart_base_0"] = 338,
						["godrunsdream_base_0"] = 339,
						["goldcoast_base_0"] = 340,
						["goldcoastrefuge_base_0"] = 341,
						["grahtwood_base_0"] = 342,
						["grahtwoodoutlawrefuge_base_0"] = 343,
						["graystonequarrybottom_base_0"] = 344,
						["graystonequarrytop_base_0"] = 345,
						["greatshackle1_base_0"] = 346,
						["greenhillcatacombs_base_0"] = 347,
						["greenshade_base_0"] = 348,
						["greymire_base_0"] = 349,
						["grundasgatehousemain_base_0"] = 350,
						["grundasgatehouseroom_base_0"] = 351,
						["guardiansorbit_base_0"] = 352,
						["gurzagsmine_base_0"] = 353,
						["haddock_base_0"] = 354,
						["haynotecave_base_0"] = 355,
						["hajuxith_base_0"] = 356,
						["halcyonlake_base_0"] = 357,
						["hallinsstand_base_0"] = 358,
						["hallofheroes_base_0"] = 359,
						["hallofthedead_base_0"] = 360,
						["halloftrials_base_0"] = 361,
						["hallsofichor_base_0"] = 362,
						["hallsofsubmission_base_0"] = 363,
						["hallsoftorment1_base_0"] = 364,
						["harridanslair_base_0"] = 365,
						["haven_base_0"] = 366,
						["havensewers_base_0"] = 367,
						["hazikslair_base_0"] = 368,
						["heartsgrief1_base_0"] = 369,
						["heartsgrief2_base_0"] = 370,
						["heartsgrief3_base_0"] = 371,
						["hectahamegrottoarboretum_base_0"] = 372,
						["hectahamegrottoarmory_base_0"] = 373,
						["hectahamegrottomain_base_0"] = 374,
						["hectahamegrottoritual_base_0"] = 375,
						["hectahamegrottovalenheart_base_0"] = 376,
						["heimlynkeepreliquary_base_0"] = 377,
						["helracitadel_base_0"] = 378,
						["helracitadelentry_base_0"] = 379,
						["helracitadelhallofwarrior_base_0"] = 380,
						["hewsbane_base_0"] = 381,
						["highrock_base_0"] = 382,
						["hightidehollow_base_0"] = 383,
						["hildunessecretrefuge_base_0"] = 384,
						["hiradirgecitadeltg3_base_0"] = 385,
						["hircineshaunt_base_0"] = 386,
						["hircineswoods_base_0"] = 387,
						["hircineswoods_group_base_0"] = 388,
						["hissmirruins_map_0"] = 389,
						["hoarfrost_base_0"] = 390,
						["hoarvorpit_base_0"] = 391,
						["hollowcity_base_0"] = 392,
						["hollowlair_base_0"] = 393,
						["honorsrestdesert_base_0"] = 394,
						["honorsrestfinalc_base_0"] = 395,
						["honorsrestfinalv_base_0"] = 396,
						["honorsrestleft_base_0"] = 397,
						["honorsrestorc_base_0"] = 398,
						["honorsrestright_base_0"] = 399,
						["housedrescrypts_base_0"] = 400,
						["howlingsepulcherscave_base_0"] = 401,
						["howlingsepulchersoverlan_base_0"] = 402,
						["howlingsepulchersoverland_base_0"] = 403,
						["howlingsepulchersscrying_base_0"] = 404,
						["hozzinsfolley_base_0"] = 405,
						["hrotacave_base_0"] = 406,
						["hrotacave02_base_0"] = 407,
						["iccoldharbonobels1_base_0"] = 408,
						["iccoldharbonobels2_base_0"] = 409,
						["iccoldharbonobels3_base_0"] = 410,
						["iccoldharboraboretum1_base_0"] = 411,
						["iccoldharboraboretum2_base_0"] = 412,
						["iccoldharboraboretum3_base_0"] = 413,
						["iccoldharbormarket1_base_0"] = 414,
						["iccoldharbormarket2_base_0"] = 415,
						["iccoldharbormarket3_base_0"] = 416,
						["icehammersvault_base_0"] = 417,
						["iceheartslair_map_base_0"] = 418,
						["ilessantower_base_0"] = 419,
						["iliathtempletunnels_base_0"] = 420,
						["ilmyris_base_0"] = 421,
						["ilthagsundertower_base_0"] = 422,
						["ilthagsundertower02_base_0"] = 423,
						["imperial_dragonfire_cath_base_0"] = 424,
						["imperial_dragonfire_tunne_base_0"] = 425,
						["imperialcity_base_0"] = 426,
						["imperialprisondistrictdun_base_0"] = 427,
						["imperialprisondunint01_base_0"] = 428,
						["imperialprisondunint02_base_0"] = 429,
						["imperialprisondunint03_base_0"] = 430,
						["imperialprisondunint04_base_0"] = 431,
						["imperialsewer_dagfall3b_base_0"] = 432,
						["imperialsewer_daggerfall1_base_0"] = 433,
						["imperialsewer_daggerfall2_base_0"] = 434,
						["imperialsewer_daggerfall3_base_0"] = 435,
						["imperialsewer_ebonheart3_base_0"] = 436,
						["imperialsewer_ebonheart3b_base_0"] = 437,
						["imperialsewer_ebonheart3m_base_0"] = 438,
						["imperialsewers_aldmeri1_base_0"] = 439,
						["imperialsewers_aldmeri2_base_0"] = 440,
						["imperialsewers_aldmeri3_base_0"] = 441,
						["imperialsewers_base_0"] = 442,
						["imperialsewers_ebon1_base_0"] = 443,
						["imperialsewers_ebon2_base_0"] = 444,
						["imperialsewersald1_base_0"] = 445,
						["imperialsewersald2_base_0"] = 446,
						["imperialsewersdagger1_base_0"] = 447,
						["imperialsewersdagger2_base_0"] = 448,
						["imperialsewersebon1_base_0"] = 449,
						["imperialsewersebon2_base_0"] = 450,
						["imperialsewershub_base_0"] = 451,
						["imperialundergroundpart1_base_0"] = 452,
						["imperialundergroundpart2_base_0"] = 453,
						["imperviousvault_base_0"] = 454,
						["innerseaarmature_base_0"] = 455,
						["innertanzelwil_base_0"] = 456,
						["islesoftorment_base_0"] = 457,
						["yldzuun_base_0"] = 458,
						["yokudanpalace_base_0"] = 459,
						["yokudanpalace02_base_0"] = 460,
						["jaggerjaw_base_0"] = 461,
						["jodeplane_base_0"] = 462,
						["jodeslight_base_0"] = 463,
						["kardala_base_0"] = 464,
						["karthdar_base_0"] = 465,
						["kennelrun_base_0"] = 466,
						["khajrawlith_base_0"] = 467,
						["khenarthisroost_base_0"] = 468,
						["kingscrest_base_0"] = 469,
						["koeglinmine_base_0"] = 470,
						["koeglinvillage_base_0"] = 471,
						["kozanset_base_0"] = 472,
						["kragenmoor_base_0"] = 473,
						["kulatimines-a_base_0"] = 474,
						["kulatimines-b_base_0"] = 475,
						["kunasdelve_base_0"] = 476,
						["kvatchcity_base_0"] = 477,
						["kwamacolony_base_0"] = 478,
						["laeloriaruins_base_0"] = 479,
						["lair_base_0"] = 480,
						["lastresortbarrow_base_0"] = 481,
						["ldtestworld_base_0"] = 482,
						["libraryofdusk_base_0"] = 483,
						["lightlesscell_base_0"] = 484,
						["lightlessoubliette_base_0"] = 485,
						["lightlessoubliettelava_base_0"] = 486,
						["lionsden_hiddentunnel_base_0"] = 487,
						["lipsandtarn_base_0"] = 488,
						["loriasel_base_0"] = 489,
						["loriasellowerlevel_base_0"] = 490,
						["lorkrataruinsa_base_0"] = 491,
						["lorkrataruinsb_base_0"] = 492,
						["lostcity_base_0"] = 493,
						["lostknifecave_base_0"] = 494,
						["lostprospect_base_0"] = 495,
						["lostprospect2_base_0"] = 496,
						["lothna_base_0"] = 497,
						["lowerbthanuel_base_0"] = 498,
						["magistratesbasement_base_0"] = 499,
						["malabaltor_base_0"] = 500,
						["malabaltoroutlawrefuge_base_0"] = 501,
						["malsorrastomb_base_0"] = 502,
						["manorofrevelrycave_base_0"] = 503,
						["manorofrevelryint01_base_0"] = 504,
						["manorofrevelryint02_base_0"] = 505,
						["manorofrevelryint03_base_0"] = 506,
						["manorofrevelryint04_base_0"] = 507,
						["manorofrevelryint05_base_0"] = 508,
						["marbruk_base_0"] = 509,
						["marbrukoutlawsrefuge_base_0"] = 510,
						["maw_of_lorkaj_base_0"] = 511,
						["mehrunesspite_base_0"] = 512,
						["mephalasnest_base_0"] = 513,
						["minesofkhuras_base_0"] = 514,
						["mistral_base_0"] = 515,
						["mistwatchcrevassecrypt_base_0"] = 516,
						["mistwatchtower_base_0"] = 517,
						["mobarmine_base_0"] = 518,
						["molavar_base_0"] = 519,
						["moonmonttemple_base_0"] = 520,
						["moriseli_base_0"] = 521,
						["morkul_base_0"] = 522,
						["morkuldescent_map_base_0"] = 523,
						["morkuldin_map_base_0"] = 524,
						["mournhold_base_0"] = 525,
						["mournholdoutlawsrefuge_base_0"] = 526,
						["mournholdsewers_base_0"] = 527,
						["mtharnaz_base_0"] = 528,
						["muckvalleycavern_base_0"] = 529,
						["mudshallowcave_base_0"] = 530,
						["mudtreemine_base_0"] = 531,
						["mundus_base_0"] = 532,
						["murciensclaim_base_0"] = 533,
						["mzendeldt_base_0"] = 534,
						["mzithumz_base_0"] = 535,
						["mzulft_base_0"] = 536,
						["narilnagaia_base_0"] = 537,
						["narsis_base_0"] = 538,
						["narsisruins_base_0"] = 539,
						["nchuduabtharthreshold_base_0"] = 540,
						["nereidtemple_base_0"] = 541,
						["nesalas_base_0"] = 542,
						["newtcave_base_0"] = 543,
						["nilataruins_base_0"] = 544,
						["nilataruinsboss_base_0"] = 545,
						["nimalten_base_0"] = 546,
						["nimaltenpart1_base_0"] = 547,
						["nimaltenpart2_base_0"] = 548,
						["nisincave_base_0"] = 549,
						["north_hut_portal_cave_base_0"] = 550,
						["northhighrockgate_base_0"] = 551,
						["northmorrowgate_base_0"] = 552,
						["northpoint_base_0"] = 553,
						["northwindmine_base_0"] = 554,
						["norvulkruins_base_0"] = 555,
						["obsidiangorge_base_0"] = 556,
						["obsidianscar_base_0"] = 557,
						["oldcreepycave_base_0"] = 558,
						["oldmerchantcaves_base_0"] = 559,
						["oldorsiniummap01_base_0"] = 560,
						["oldorsiniummap02_base_0"] = 561,
						["oldorsiniummap03_base_0"] = 562,
						["oldorsiniummap04_base_0"] = 563,
						["oldorsiniummap05_base_0"] = 564,
						["oldorsiniummap06_base_0"] = 565,
						["oldorsiniummap07_base_0"] = 566,
						["oldsordscave_base_0"] = 567,
						["ondil_base_0"] = 568,
						["onkobrakwamamine_base_0"] = 569,
						["onsisbreathmine_base_0"] = 570,
						["orcsfingerruins_base_0"] = 571,
						["orkeyshollow_base_0"] = 572,
						["orrery_base_0"] = 573,
						["orsinium_base_0"] = 574,
						["orsiniumtemplelower_base_0"] = 575,
						["orsiniumtempleupper_base_0"] = 576,
						["orsiniumthroneroom_base_0"] = 577,
						["ossuaryoftelacar_base_0"] = 578,
						["ouze_base_0"] = 579,
						["paragonsrememberance_base_0"] = 580,
						["pariahcatacombs_base_0"] = 581,
						["pathtothemoo_library_base_0"] = 582,
						["pathtothemoot_base_0"] = 583,
						["phaercatacombs_base_0"] = 584,
						["pinepeakcaverns_base_0"] = 585,
						["planeofjodecave_base_0"] = 586,
						["planeofjodedenoflorkhaj_base_0"] = 587,
						["planeofjodehubhillbos_base_0"] = 588,
						["planeofjodetemple_base_0"] = 589,
						["portdunwatch_base_0"] = 590,
						["porthunding_base_0"] = 591,
						["potholecavern_base_0"] = 592,
						["quarantineserk_base_0"] = 593,
						["quickwatercave_base_0"] = 594,
						["quickwaterdepths_base_0"] = 595,
						["rage_base_0"] = 596,
						["ragnthar_base_0"] = 597,
						["rahniza_1_0"] = 598,
						["rahniza_2_0"] = 599,
						["rahniza_3_0"] = 600,
						["raylescatacombs_base_0"] = 601,
						["rajhinsvault_base_0"] = 602,
						["rajhinsvaultsmallroom_base_0"] = 603,
						["rawlkha_base_0"] = 604,
						["rawlkhatemple_base_0"] = 605,
						["razakswheel_base_0"] = 606,
						["reapersmarch_base_0"] = 607,
						["reapersmarchoutlawrefuge_base_0"] = 608,
						["reavercitadelpyramid_base_0"] = 609,
						["rectory01_base_0"] = 610,
						["redfurtradingpost_base_0"] = 611,
						["redrubycave_base_0"] = 612,
						["reinholdsretreatcave_base_0"] = 613,
						["reliquaryofstars_base_0"] = 614,
						["reliquaryvaultbottom_base_0"] = 615,
						["reliquaryvaulttop_base_0"] = 616,
						["rendrocaverns_base_0"] = 617,
						["riften_base_0"] = 618,
						["riftoutlaw_base_0"] = 619,
						["rivenspire_base_0"] = 620,
						["rivenspireoutlaw_base_0"] = 621,
						["rkhardahrk_0"] = 622,
						["rkindaleftint01_base_0"] = 623,
						["rkindaleftint02_base_0"] = 624,
						["rkindaleftint03_base_0"] = 625,
						["rkindaleftoutside_base_0"] = 626,
						["rkulftzel_base_0"] = 627,
						["rkundzelft_base_0"] = 628,
						["rootsofsilvenar_base_0"] = 629,
						["rootsoftreehenge_base_0"] = 630,
						["rootsunder_base_0"] = 631,
						["rubblebutte_base_0"] = 632,
						["rulanyilsfall_base_0"] = 633,
						["sacredleapgrotto_base_0"] = 634,
						["safehouse_base_0"] = 635,
						["salasen_base_0"] = 636,
						["saltspray_base_0"] = 637,
						["sancretor1_base_0"] = 638,
						["sancretor2_base_0"] = 639,
						["sancretor3_base_0"] = 640,
						["sancretor4_base_0"] = 641,
						["sancretor5_base_0"] = 642,
						["sancretor6_base_0"] = 643,
						["sancretor7_base_0"] = 644,
						["sancretor8_base_0"] = 645,
						["sanctumofprowess_base_0"] = 646,
						["sandblownmine_base_0"] = 647,
						["sanguinesdemesne_base_0"] = 648,
						["santaki_base_0"] = 649,
						["scalecourtlaboratory_base_0"] = 650,
						["scaledcourtlaboratory_base_0"] = 651,
						["scarpkeeplower_base_0"] = 652,
						["scarpkeepupper_base_0"] = 653,
						["secludedsewers_base_0"] = 654,
						["secret_tunnel_base_0"] = 655,
						["seekersarchivedown_base_0"] = 656,
						["seekersarchiveup_base_0"] = 657,
						["selenesweb_base_0"] = 658,
						["seleneswebfinalbossarea_base_0"] = 659,
						["senelana_base_0"] = 660,
						["sentinel_base_0"] = 661,
						["serpenthollowcave_base_0"] = 662,
						["serpentsgrotto_base_0"] = 663,
						["serpentsnest_base_0"] = 664,
						["sf_percolatingmire_map_0"] = 665,
						["shadaburialgrounds_base_0"] = 666,
						["shadacitydistrict_base_0"] = 667,
						["shadahallofworship_base_0"] = 668,
						["shadamaincity_base_0"] = 669,
						["shadastula_base_0"] = 670,
						["shadatemplewing_base_0"] = 671,
						["shademistenclave_base_0"] = 672,
						["shadowfatecavern_base_0"] = 673,
						["shadowfen_base_0"] = 674,
						["shadowfenoutlawrefuge_base_0"] = 675,
						["shadowscaleenclave_base_0"] = 676,
						["shaelruins_base_0"] = 677,
						["sharktoothgrotto1_base_0"] = 678,
						["sharktoothgrotto2_base_0"] = 679,
						["shatteredshoals_base_0"] = 680,
						["sheogorathstongue_base_0"] = 681,
						["shorecave_base_0"] = 682,
						["shornhelm_base_0"] = 683,
						["shorsstone_base_0"] = 684,
						["shorsstonemine_base_0"] = 685,
						["shrineofblackworm_base_0"] = 686,
						["shrineofmauloch_base_0"] = 687,
						["shroudedhollowarea1_base_0"] = 688,
						["shroudedhollowarea2_base_0"] = 689,
						["shroudedhollowcenter_base_0"] = 690,
						["shroudedpass_base_0"] = 691,
						["shroudedpass2_base_0"] = 692,
						["shroudhearth_base_0"] = 693,
						["silatar_base_0"] = 694,
						["silumm_base_0"] = 695,
						["silvenarthroneroom_base_0"] = 696,
						["skinstealerlair_base_0"] = 697,
						["skyreachcatacombs1_base_0"] = 698,
						["skyreachcatacombs2_base_0"] = 699,
						["skyreachcatacombs3_base_0"] = 700,
						["skyreachcatacombs4_base_0"] = 701,
						["skyreachcatacombs5_base_0"] = 702,
						["skyreachhold1_base_0"] = 703,
						["skyreachhold2_base_0"] = 704,
						["skyreachhold3_base_0"] = 705,
						["skyreachhold4_base_0"] = 706,
						["skyreachpinnacle_base_0"] = 707,
						["skyreachtemple_base_0"] = 708,
						["skyshroudbarrow_base_0"] = 709,
						["skywatch_base_0"] = 710,
						["smugglerkingtunnel_base_0"] = 711,
						["smugglerstunnel_base_0"] = 712,
						["smugglertunnel_base_0"] = 713,
						["snaplegcave_base_0"] = 714,
						["softloamcavern_base_0"] = 715,
						["sorrowext_base_0"] = 716,
						["sorrowint01_base_0"] = 717,
						["sorrowint02_base_0"] = 718,
						["sorrowint03_base_0"] = 719,
						["south_hut_portal_cave_base_0"] = 720,
						["southhighrockgate_base_0"] = 721,
						["southmorrowgate_base_0"] = 722,
						["southpoint_base_0"] = 723,
						["southruins_base_0"] = 724,
						["spindleclutch_base_0"] = 725,
						["spindleclutchheroic_base_0"] = 726,
						["sren-ja_base_0"] = 727,
						["sren-ja1_base_0"] = 728,
						["sren-ja2_base_0"] = 729,
						["starvedplanes_base_0"] = 730,
						["stillrisevillage_base_0"] = 731,
						["stirk_base_0"] = 732,
						["stonefalls_base_0"] = 733,
						["stonefallsoutlawrefuge_base_0"] = 734,
						["stonefang_base_0"] = 735,
						["stonetoothfortress_base_0"] = 736,
						["stormcragcrypt_base_0"] = 737,
						["stormhaven_base_0"] = 738,
						["stormhavenoutlawrefuge_base_0"] = 739,
						["stormhold_base_0"] = 740,
						["stormholdayleidruin_base_0"] = 741,
						["stormholdguildhall_map_0"] = 742,
						["stormholdmortuary_map_0"] = 743,
						["stormlair_base_0"] = 744,
						["stormwardenundercroft_base_0"] = 745,
						["strosmkai_base_0"] = 746,
						["sulimamansion_floor1_0"] = 747,
						["sulimamansion_floor1_hidden_0"] = 748,
						["sulimamansion_floor2_0"] = 749,
						["sulimamansion_floor2_hidden_0"] = 750,
						["sunkenroad_base_0"] = 751,
						["sunscaleenclave_base_0"] = 752,
						["suturahs_crypt_base_0"] = 753,
						["taarengrav_base_0"] = 754,
						["taldeiccrypts_base_0"] = 755,
						["tempestisland_base_0"] = 756,
						["tempestislandncave_base_0"] = 757,
						["tempestislandsecave_base_0"] = 758,
						["tempestislandswcave_base_0"] = 759,
						["temple_base_0"] = 760,
						["templeofsul_base_0"] = 761,
						["templeofthemourningspring_base_0"] = 762,
						["tenmaurwolk_base_0"] = 763,
						["thaliasretreat_base_0"] = 764,
						["the_aldmiri_harborage_map_base_0"] = 765,
						["the_daggerfall_harborage_0"] = 766,
						["the_ebonheart_harborage_base_0"] = 767,
						["the_guardians_skull_base_0"] = 768,
						["the_masters_crypt_base_0"] = 769,
						["the_portal_chamber_map_base_0"] = 770,
						["thebanishedcells_base_0"] = 771,
						["thebastardstomb_base_0"] = 772,
						["thechillhollow_base_0"] = 773,
						["theearthforge_base_0"] = 774,
						["theearthforgepublic_base_0"] = 775,
						["theendlessstair_base_0"] = 776,
						["theeverfullflagon_base_0"] = 777,
						["thefarshores_base_0"] = 778,
						["thefivefingerdance_0"] = 779,
						["thefrigidgrotto_base_0"] = 780,
						["thegrave_base_0"] = 781,
						["thehuntinggrounds_base_0"] = 782,
						["thelibrarydusk_base_0"] = 783,
						["thelionsden_base_0"] = 784,
						["thelostfleet_base_0"] = 785,
						["themagesstaff_base_0"] = 786,
						["themangroves_base_0"] = 787,
						["themanorofrevelry_base_0"] = 788,
						["themiddens_base_0"] = 789,
						["themondmine_base_0"] = 790,
						["themooring_base_0"] = 791,
						["therefugeofdread_base_0"] = 792,
						["therift_base_0"] = 793,
						["theshrineofstveloth_base_0"] = 794,
						["theunderroot_base_0"] = 795,
						["thevaultofexile_base_0"] = 796,
						["thevilelaboratory_base_0"] = 797,
						["thevilemansefirstfloor_base_0"] = 798,
						["thevilemansesecondfloor_base_0"] = 799,
						["thewormsretreat_base_0"] = 800,
						["thibautscairn_base_0"] = 801,
						["thukozods_base_0"] = 802,
						["toadstoolhollow_base_0"] = 803,
						["toadstoolhollowlower_base_0"] = 804,
						["tombofanahbi_base_0"] = 805,
						["tomboflostkings_base_0"] = 806,
						["tomboftheapostates_base_0"] = 807,
						["toothmaulgully_base_0"] = 808,
						["torinaan1_base_0"] = 809,
						["torinaan2_base_0"] = 810,
						["torinaan3_base_0"] = 811,
						["torinaan4_base_0"] = 812,
						["torinaan5_base_0"] = 813,
						["tormented_spire_base_0"] = 814,
						["tormentedspireinstance_base_0"] = 815,
						["toweroflies_base_0"] = 816,
						["tribulationcrypt_base_0"] = 817,
						["tribunaltemple_base_0"] = 818,
						["tribunesfolly_base_0"] = 819,
						["triplecirclemine_base_0"] = 820,
						["trl_so_map01_base_0"] = 821,
						["trl_so_map02_base_0"] = 822,
						["trl_so_map03_base_0"] = 823,
						["trl_so_map04_base_0"] = 824,
						["trolhettacave_base_0"] = 825,
						["trolhettasummit_base_0"] = 826,
						["trollstoothpick_base_0"] = 827,
						["tsanji_base_0"] = 828,
						["underpallcave_base_0"] = 829,
						["unexploredcrag_base_0"] = 830,
						["urcelmosbetrayal_base_0"] = 831,
						["vahtacen_base_0"] = 832,
						["valeoftheghostsnake_base_0"] = 833,
						["valleyofblades1_base_0"] = 834,
						["valleyofblades2_base_0"] = 835,
						["vaultofhamanforgefire_base_0"] = 836,
						["vaultsofmadness1_base_0"] = 837,
						["vaultsofmadness2_base_0"] = 838,
						["veiledkeepbase_0"] = 839,
						["velynharbor_base_0"] = 840,
						["vernimwood_base_0"] = 841,
						["vetcirtyash01_base_0"] = 842,
						["vetcirtyash02_base_0"] = 843,
						["vetcirtyash03_base_0"] = 844,
						["vetcirtyash04_base_0"] = 845,
						["vilemansehouse01_base_0"] = 846,
						["vilemansehouse02_base_0"] = 847,
						["villageofthelost_base_0"] = 848,
						["vindeathcave_base_0"] = 849,
						["vineduckvillage_base_0"] = 850,
						["vineduckvillagecorridor_base_0"] = 851,
						["viridianhideaway_base_0"] = 852,
						["viridianwatch_base_0"] = 853,
						["visionofthecompanions_base_0"] = 854,
						["visionofthehist_base_0"] = 855,
						["volenfell_base_0"] = 856,
						["volenfell_pledge_base_0"] = 857,
						["vulkel_guard_prison_base_0"] = 858,
						["vulkhelguard_base_0"] = 859,
						["vulkwasten_base_0"] = 860,
						["wailingmaw_base_0"] = 861,
						["wailingprison1_base_0"] = 862,
						["wailingprison2_base_0"] = 863,
						["wailingprison3_base_0"] = 864,
						["wailingprison4_base_0"] = 865,
						["wailingprison5_base_0"] = 866,
						["wailingprison6_base_0"] = 867,
						["wailingprison7_base_0"] = 868,
						["wayrest_base_0"] = 869,
						["wayrestsewers_base_0"] = 870,
						["wansalen_base_0"] = 871,
						["watchershold_base_0"] = 872,
						["weepingwindcave_base_0"] = 873,
						["welloflostsouls_base_0"] = 874,
						["west_hut_portal_cave_base_0"] = 875,
						["westelsweyrgate_base_0"] = 876,
						["wgtbattlemage_base_0"] = 877,
						["wgtgreenemporerway_base_0"] = 878,
						["wgtimperialguardquarters_base_0"] = 879,
						["wgtimperialthroneroom_base_0"] = 880,
						["wgtlibraryhall_base_0"] = 881,
						["wgtlibrarymain_base_0"] = 882,
						["wgtpalacesewers_base_0"] = 883,
						["wgtpinnacle_base_0"] = 884,
						["wgtpinnacleboss_base_0"] = 885,
						["wgtregentsquarters_base_0"] = 886,
						["wgtvoid1_base_0"] = 887,
						["wgtvoid2_base_0"] = 888,
						["whitefallmountain_base_0"] = 889,
						["whiteroseprison_base_0"] = 890,
						["windhelm_base_0"] = 891,
						["windridgecave_base_0"] = 892,
						["wittestadrcrypts_base_0"] = 893,
						["woodhearth_base_0"] = 894,
						["wormrootdepths_base_0"] = 895,
						["wrothgar_base_0"] = 896,
						["wrothgaroutlawrefuge_base_0"] = 897,
						["zehtswatercavelower_base_0"] = 898,
						["zehtswatercaveupper_base_0"] = 899,
						["zthenganaz_base_0"] = 900,
						}
		FyrMM.MapData = {
						[1] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 455, },
						[2] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1179, },
						[3] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1179, },
						[4] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1179, },
						[5] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 369, },
						[6] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 354, },
						[7] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[8] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[9] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[10] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[11] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[12] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[13] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[14] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 209, },
						[15] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 583, },
						[16] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 666, },
						[17] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 495, },
						[18] = {[1] = 1024, [2] = 4, [3] = 2, [4] = 2, [5] = 4680, },
						[19] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 229, },
						[20] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 812, },
						[21] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1371, },
						[22] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 443, },
						[23] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 757, },
						[24] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 341, },
						[25] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[26] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 148, },
						[27] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 148, },
						[28] = {[1] = 512, [2] = 4, [3] = 2, [4] = 2, [5] = 506, },
						[29] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[30] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 325, },
						[31] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[32] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 469, },
						[33] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[34] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[35] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[36] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[37] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[38] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 628, },
						[39] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[40] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 833, },
						[41] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[42] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 500, },
						[43] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[44] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 645, },
						[45] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 421, },
						[46] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 349, },
						[47] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 98, },
						[48] = {[1] = 1024, [2] = 4, [3] = 2, [4] = 2, [5] = 5350, },
						[49] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 207, },
						[50] = {[1] = 1024, [2] = 25, [3] = 5, [4] = 5, [5] = 13065, },
						[51] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 267, },
						[52] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 637, },
						[53] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 532, },
						[54] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 278, },
						[55] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 278, },
						[56] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 555, },
						[57] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 526, },
						[58] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[59] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[60] = {[1] = 1024, [2] = 25, [3] = 5, [4] = 5, [5] = 1697, },
						[61] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[62] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[63] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[64] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[65] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[66] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[67] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[68] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[69] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[70] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[71] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[72] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[73] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[74] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[75] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[76] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[77] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[78] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[79] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[80] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[81] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[82] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[83] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[84] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[85] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[86] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[87] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[88] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[89] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[90] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[91] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[92] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[93] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[94] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[95] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[96] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[97] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[98] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[99] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[100] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[101] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[102] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[103] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[104] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[105] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[106] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[107] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[108] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[109] = {[1] = 1024, [2] = 9, [3] = 3, [4] = 3, [5] = 4345, },
						[110] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 164, },
						[111] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 212, },
						[112] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 303, },
						[113] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 183, },
						[114] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 169, },
						[115] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 226, },
						[116] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 182, },
						[117] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 391, },
						[118] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 318, },
						[119] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 659, },
						[120] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 715, },
						[121] = {[1] = 1024, [2] = 4, [3] = 2, [4] = 2, [5] = 2232, },
						[122] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[123] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 772, },
						[124] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1081, },
						[125] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[126] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[127] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[128] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[129] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 395, },
						[130] = {[1] = 512, [2] = 9, [3] = 3, [4] = 3, [5] = 1963, },
						[131] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 594, },
						[132] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[133] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[134] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[135] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[136] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[137] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[138] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[139] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 112, },
						[140] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 280, },
						[141] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 355, },
						[142] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[143] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[144] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[145] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 476, },
						[146] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 533, },
						[147] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[148] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 610, },
						[149] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 100, },
						[150] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 607, },
						[151] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 371, },
						[152] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[153] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 306, },
						[154] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 263, },
						[155] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[156] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 374, },
						[157] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 270, },
						[158] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 426, },
						[159] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 298, },
						[160] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[161] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 567, },
						[162] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 389, },
						[163] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 187, },
						[164] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[165] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 333, },
						[166] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1371, },
						[167] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 421, },
						[168] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 427, },
						[169] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 241, },
						[170] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 937, },
						[171] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[172] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 447, },
						[173] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[174] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[175] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 449, },
						[176] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[177] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[178] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 395, },
						[179] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 682, },
						[180] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 163, },
						[181] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 819, },
						[182] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 600, },
						[183] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 362, },
						[184] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 424, },
						[185] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 771, },
						[186] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[187] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[188] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 431, },
						[189] = {[1] = 1024, [2] = 4, [3] = 2, [4] = 2, [5] = 5622, },
						[190] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 489, },
						[191] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 413, },
						[192] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 191, },
						[193] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[194] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 218, },
						[195] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 81, },
						[196] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 285, },
						[197] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 295, },
						[198] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 151, },
						[199] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[200] = {[1] = 256, [2] = 49, [3] = 7, [4] = 7, [5] = 4682, },
						[201] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 458, },
						[202] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 195, },
						[203] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 326, },
						[204] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 360, },
						[205] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 263, },
						[206] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 572, },
						[207] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 603, },
						[208] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 603, },
						[209] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[210] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 351, },
						[211] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[212] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 799, },
						[213] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 352, },
						[214] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 465, },
						[215] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 828, },
						[216] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 539, },
						[217] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 695, },
						[218] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 145, },
						[219] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1040, },
						[220] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 652, },
						[221] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[222] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 956, },
						[223] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 306, },
						[224] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 427, },
						[225] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 460, },
						[226] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[227] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 548, },
						[228] = {[1] = 512, [2] = 16, [3] = 4, [4] = 4, [5] = 5348, },
						[229] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 304, },
						[230] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 241, },
						[231] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 224, },
						[232] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 401, },
						[233] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 403, },
						[234] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[235] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[236] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[237] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 397, },
						[238] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 460, },
						[239] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 162, },
						[240] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 153, },
						[241] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 414, },
						[242] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 115, },
						[243] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 320, },
						[244] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[245] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[246] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[247] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[248] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[249] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[250] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[251] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[252] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[253] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[254] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[255] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[256] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[257] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 265, },
						[258] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 875, },
						[259] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 168, },
						[260] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 807, },
						[261] = {[1] = 1024, [2] = 4, [3] = 2, [4] = 2, [5] = 5350, },
						[262] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 248, },
						[263] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 302, },
						[264] = {[1] = 512, [2] = 25, [3] = 5, [4] = 5, [5] = 1007, },
						[265] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 395, },
						[266] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[267] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 401, },
						[268] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 270, },
						[269] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 434, },
						[270] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[271] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 837, },
						[272] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[273] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[274] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[275] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 245, },
						[276] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 245, },
						[277] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 245, },
						[278] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1014, },
						[279] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 245, },
						[280] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 245, },
						[281] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 293, },
						[282] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 245, },
						[283] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 332, },
						[284] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[285] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 504, },
						[286] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 158, },
						[287] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 632, },
						[288] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[289] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 579, },
						[290] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[291] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 305, },
						[292] = {[1] = 512, [2] = 4, [3] = 2, [4] = 2, [5] = 750, },
						[293] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 565, },
						[294] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 458, },
						[295] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[296] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 328, },
						[297] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 279, },
						[298] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 212, },
						[299] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 240, },
						[300] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 339, },
						[301] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 451, },
						[302] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 311, },
						[303] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 128, },
						[304] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 398, },
						[305] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 157, },
						[306] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 109, },
						[307] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[308] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 173, },
						[309] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 877, },
						[310] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 241, },
						[311] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 203, },
						[312] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 444, },
						[313] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 658, },
						[314] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 274, },
						[315] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 244, },
						[316] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 444, },
						[317] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 592, },
						[318] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 213, },
						[319] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1080, },
						[320] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 545, },
						[321] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[322] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 419, },
						[323] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 540, },
						[324] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 653, },
						[325] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[326] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 375, },
						[327] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 496, },
						[328] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 3118, },
						[329] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[330] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 674, },
						[331] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[332] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 480, },
						[333] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[334] = {[1] = 1024, [2] = 9, [3] = 3, [4] = 3, [5] = 4964, },
						[335] = {[1] = 1024, [2] = 4, [3] = 2, [4] = 2, [5] = 1, },
						[336] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 282, },
						[337] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 340, },
						[338] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 218, },
						[339] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 538, },
						[340] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 3342, },
						[341] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 239, },
						[342] = {[1] = 1024, [2] = 4, [3] = 2, [4] = 2, [5] = 4624, },
						[343] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 204, },
						[344] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 715, },
						[345] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 647, },
						[346] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1004, },
						[347] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 351, },
						[348] = {[1] = 1024, [2] = 4, [3] = 2, [4] = 2, [5] = 3916, },
						[349] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[350] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 457, },
						[351] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 457, },
						[352] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[353] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 389, },
						[354] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 435, },
						[355] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[356] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 407, },
						[357] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[358] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 943, },
						[359] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 734, },
						[360] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 660, },
						[361] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 230, },
						[362] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 541, },
						[363] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 427, },
						[364] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 609, },
						[365] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 332, },
						[366] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 943, },
						[367] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[368] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[369] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 696, },
						[370] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 503, },
						[371] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 722, },
						[372] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 881, },
						[373] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 881, },
						[374] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 881, },
						[375] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 881, },
						[376] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 596, },
						[377] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 353, },
						[378] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1, },
						[379] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[380] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[381] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 3330, },
						[382] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[383] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 361, },
						[384] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 357, },
						[385] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 312, },
						[386] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 670, },
						[387] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[388] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[389] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 174, },
						[390] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 395, },
						[391] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 434, },
						[392] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 659, },
						[393] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 512, },
						[394] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 36, },
						[395] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 190, },
						[396] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 460, },
						[397] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 427, },
						[398] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 84, },
						[399] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 331, },
						[400] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 374, },
						[401] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 192, },
						[402] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 673, },
						[403] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 673, },
						[404] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[405] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 352, },
						[406] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 371, },
						[407] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 129, },
						[408] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[409] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[410] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[411] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[412] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[413] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[414] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[415] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[416] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[417] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 406, },
						[418] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 274, },
						[419] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 372, },
						[420] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 298, },
						[421] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 468, },
						[422] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 239, },
						[423] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 247, },
						[424] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[425] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[426] = {[1] = 256, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[427] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[428] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[429] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[430] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[431] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[432] = {[1] = 256, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[433] = {[1] = 256, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[434] = {[1] = 256, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[435] = {[1] = 256, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[436] = {[1] = 256, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[437] = {[1] = 256, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[438] = {[1] = 256, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[439] = {[1] = 256, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[440] = {[1] = 256, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[441] = {[1] = 256, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[442] = {[1] = 512, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[443] = {[1] = 256, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[444] = {[1] = 256, [2] = 36, [3] = 6, [4] = 6, [5] = 1, },
						[445] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[446] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[447] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[448] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[449] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[450] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[451] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[452] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 154, },
						[453] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 376, },
						[454] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 265, },
						[455] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 482, },
						[456] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[457] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 830, },
						[458] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 405, },
						[459] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 210, },
						[460] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 207, },
						[461] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 473, },
						[462] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 722, },
						[463] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 437, },
						[464] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 452, },
						[465] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 265, },
						[466] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 757, },
						[467] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 278, },
						[468] = {[1] = 1024, [2] = 5, [3] = 2, [4] = 2, [5] = 1, },
						[469] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[470] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 381, },
						[471] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 551, },
						[472] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 674, },
						[473] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 799, },
						[474] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 268, },
						[475] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 148, },
						[476] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 417, },
						[477] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 648, },
						[478] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 305, },
						[479] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 347, },
						[480] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 147, },
						[481] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 555, },
						[482] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[483] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 331, },
						[484] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 740, },
						[485] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 586, },
						[486] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 586, },
						[487] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 170, },
						[488] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[489] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 669, },
						[490] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[491] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 329, },
						[492] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 329, },
						[493] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 939, },
						[494] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 435, },
						[495] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 231, },
						[496] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 311, },
						[497] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 488, },
						[498] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 338, },
						[499] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 121, },
						[500] = {[1] = 512, [2] = 9, [3] = 3, [4] = 3, [5] = 4327, },
						[501] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 259, },
						[502] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 437, },
						[503] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 286, },
						[504] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 130, },
						[505] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 130, },
						[506] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 123, },
						[507] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 123, },
						[508] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 74, },
						[509] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 580, },
						[510] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 270, },
						[511] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 633, },
						[512] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[513] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 407, },
						[514] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 435, },
						[515] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 723, },
						[516] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 257, },
						[517] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 469, },
						[518] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 395, },
						[519] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 382, },
						[520] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 444, },
						[521] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 246, },
						[522] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 482, },
						[523] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 521, },
						[524] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 420, },
						[525] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1105, },
						[526] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 348, },
						[527] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 406, },
						[528] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 442, },
						[529] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[530] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 158, },
						[531] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 286, },
						[532] = {[1] = 1024, [2] = 4, [3] = 2, [4] = 2, [5] = 1, },
						[533] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 387, },
						[534] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 576, },
						[535] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 398, },
						[536] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 781, },
						[537] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 405, },
						[538] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 636, },
						[539] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 274, },
						[540] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 310, },
						[541] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 431, },
						[542] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[543] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[544] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 306, },
						[545] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 215, },
						[546] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 940, },
						[547] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 341, },
						[548] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 165, },
						[549] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[550] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 149, },
						[551] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1, },
						[552] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1, },
						[553] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 635, },
						[554] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 394, },
						[555] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 328, },
						[556] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 461, },
						[557] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 380, },
						[558] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[559] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 255, },
						[560] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 313, },
						[561] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 554, },
						[562] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 262, },
						[563] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 363, },
						[564] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 247, },
						[565] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 399, },
						[566] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 411, },
						[567] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 432, },
						[568] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[569] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 363, },
						[570] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 452, },
						[571] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 318, },
						[572] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 435, },
						[573] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 334, },
						[574] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 894, },
						[575] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 173, },
						[576] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 176, },
						[577] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 124, },
						[578] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 451, },
						[579] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 311, },
						[580] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 488, },
						[581] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 269, },
						[582] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 105, },
						[583] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 581, },
						[584] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[585] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 494, },
						[586] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 299, },
						[587] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 442, },
						[588] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 918, },
						[589] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 229, },
						[590] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 256, },
						[591] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 830, },
						[592] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[593] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 426, },
						[594] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[595] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[596] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 327, },
						[597] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 259, },
						[598] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[599] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[600] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[601] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1, },
						[602] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 353, },
						[603] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 90, },
						[604] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 559, },
						[605] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 535, },
						[606] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 656, },
						[607] = {[1] = 1024, [2] = 4, [3] = 2, [4] = 2, [5] = 4440, },
						[608] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 266, },
						[609] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 176, },
						[610] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 153, },
						[611] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 475, },
						[612] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[613] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[614] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 537, },
						[615] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 273, },
						[616] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 120, },
						[617] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 336, },
						[618] = {[1] = 512, [2] = 4, [3] = 2, [4] = 2, [5] = 758, },
						[619] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 246, },
						[620] = {[1] = 1024, [2] = 4, [3] = 2, [4] = 2, [5] = 4062, },
						[621] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 148, },
						[622] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 388, },
						[623] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 468, },
						[624] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[625] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 178, },
						[626] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 899, },
						[627] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 165, },
						[628] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 402, },
						[629] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 487, },
						[630] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 345, },
						[631] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 485, },
						[632] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 401, },
						[633] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 504, },
						[634] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[635] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 335, },
						[636] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 275, },
						[637] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[638] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 373, },
						[639] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 260, },
						[640] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 247, },
						[641] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 243, },
						[642] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 221, },
						[643] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 212, },
						[644] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 280, },
						[645] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 218, },
						[646] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[647] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 407, },
						[648] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 571, },
						[649] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 452, },
						[650] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[651] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[652] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 234, },
						[653] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 234, },
						[654] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 403, },
						[655] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[656] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[657] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[658] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[659] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[660] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 261, },
						[661] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1106, },
						[662] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[663] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 630, },
						[664] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 556, },
						[665] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 193, },
						[666] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[667] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[668] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[669] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[670] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 218, },
						[671] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[672] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 464, },
						[673] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 315, },
						[674] = {[1] = 512, [2] = 9, [3] = 3, [4] = 3, [5] = 4037, },
						[675] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[676] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[677] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 373, },
						[678] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 635, },
						[679] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 635, },
						[680] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[681] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 494, },
						[682] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 178, },
						[683] = {[1] = 512, [2] = 4, [3] = 2, [4] = 2, [5] = 630, },
						[684] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 752, },
						[685] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 452, },
						[686] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 266, },
						[687] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 658, },
						[688] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 452, },
						[689] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 452, },
						[690] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 227, },
						[691] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 243, },
						[692] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 274, },
						[693] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 296, },
						[694] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 949, },
						[695] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 373, },
						[696] = {[1] = 256, [2] = 18, [3] = 4, [4] = 4, [5] = 100, },
						[697] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 235, },
						[698] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[699] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[700] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[701] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[702] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[703] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 189, },
						[704] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 195, },
						[705] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 187, },
						[706] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 236, },
						[707] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[708] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[709] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 161, },
						[710] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 909, },
						[711] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 287, },
						[712] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[713] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 144, },
						[714] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 407, },
						[715] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 463, },
						[716] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 698, },
						[717] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 154, },
						[718] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 275, },
						[719] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 297, },
						[720] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 166, },
						[721] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1, },
						[722] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1, },
						[723] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[724] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[725] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 523, },
						[726] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[727] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 251, },
						[728] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 184, },
						[729] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 161, },
						[730] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[731] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 265, },
						[732] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 726, },
						[733] = {[1] = 1024, [2] = 4, [3] = 2, [4] = 2, [5] = 4771, },
						[734] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[735] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 230, },
						[736] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 744, },
						[737] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 334, },
						[738] = {[1] = 256, [2] = 49, [3] = 7, [4] = 7, [5] = 4682, },
						[739] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 320, },
						[740] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 635, },
						[741] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 442, },
						[742] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 191, },
						[743] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 127, },
						[744] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[745] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 461, },
						[746] = {[1] = 512, [2] = 9, [3] = 3, [4] = 3, [5] = 1983, },
						[747] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 172, },
						[748] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 172, },
						[749] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 172, },
						[750] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 172, },
						[751] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 452, },
						[752] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 294, },
						[753] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 249, },
						[754] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 351, },
						[755] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 402, },
						[756] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[757] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[758] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[759] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[760] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 17, },
						[761] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 280, },
						[762] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[763] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 253, },
						[764] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 441, },
						[765] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 153, },
						[766] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 181, },
						[767] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 162, },
						[768] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[769] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 93, },
						[770] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 178, },
						[771] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 549, },
						[772] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 432, },
						[773] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 379, },
						[774] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 762, },
						[775] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[776] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 549, },
						[777] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 160, },
						[778] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 486, },
						[779] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[780] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 332, },
						[781] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 231, },
						[782] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 500, },
						[783] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 181, },
						[784] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1203, },
						[785] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 175, },
						[786] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 764, },
						[787] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[788] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 725, },
						[789] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 453, },
						[790] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 281, },
						[791] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 264, },
						[792] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[793] = {[1] = 1024, [2] = 4, [3] = 2, [4] = 2, [5] = 5350, },
						[794] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 124, },
						[795] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 394, },
						[796] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[797] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 508, },
						[798] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 596, },
						[799] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 594, },
						[800] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 227, },
						[801] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 356, },
						[802] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 437, },
						[803] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[804] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[805] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 240, },
						[806] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 378, },
						[807] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 401, },
						[808] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 730, },
						[809] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[810] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[811] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[812] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[813] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[814] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 643, },
						[815] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 369, },
						[816] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 362, },
						[817] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 250, },
						[818] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 306, },
						[819] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 282, },
						[820] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 370, },
						[821] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[822] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[823] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[824] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[825] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 508, },
						[826] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 359, },
						[827] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 388, },
						[828] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 141, },
						[829] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[830] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 375, },
						[831] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 452, },
						[832] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[833] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 170, },
						[834] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 671, },
						[835] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 289, },
						[836] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 328, },
						[837] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 336, },
						[838] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 338, },
						[839] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[840] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 993, },
						[841] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 227, },
						[842] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[843] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[844] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[845] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[846] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 72, },
						[847] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 72, },
						[848] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1504, },
						[849] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 334, },
						[850] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 151, },
						[851] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 294, },
						[852] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 227, },
						[853] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 263, },
						[854] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 357, },
						[855] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 318, },
						[856] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[857] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[858] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[859] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1065, },
						[860] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 716, },
						[861] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 436, },
						[862] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[863] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[864] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[865] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[866] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[867] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[868] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[869] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 927, },
						[870] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[871] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[872] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 597, },
						[873] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 383, },
						[874] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 266, },
						[875] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 201, },
						[876] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 600, },
						[877] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[878] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[879] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[880] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[881] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[882] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[883] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[884] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[885] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[886] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[887] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[888] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[889] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[890] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 356, },
						[891] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 713, },
						[892] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 413, },
						[893] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 347, },
						[894] = {[1] = 256, [2] = 25, [3] = 5, [4] = 5, [5] = 1027, },
						[895] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 319, },
						[896] = {[1] = 512, [2] = 16, [3] = 4, [4] = 4, [5] = 4687, },
						[897] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 169, },
						[898] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[899] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 1, },
						[900] = {[1] = 256, [2] = 9, [3] = 3, [4] = 3, [5] = 476, },						}

FyrMM.Panel = {
	type = "panel",
	name = "MiniMap",
	displayName = GetString(SI_MM_STRING_SETTINGS),
	author = "|c006600Fyrakin|r",
	version = "3.00",
	slashCommand = "/fyrmmset",
	registerForRefresh = true,
	registerForDefaults = true,
}

	FyrMM.Options = {
	[1] = { type = "checkbox", name = GetString(SI_MM_SETTING_ZYGOR), tooltip = GetString(SI_MM_SETTING_ZYGOR_TOOLTIP),
			getFunc = function() return FyrMM.SV.UseOriginalAPI end,
			setFunc = function(value) MM_SetUseOriginalAPI(value) end,
			width = "full",	default = true,	},
	[2] = { type = "checkbox", name = GetString(SI_MM_SETTING_COMPASS), tooltip = GetString(SI_MM_SETTING_COMPASS_TOOLTIP),
			getFunc = function() return MM_GetHideCompass() end,
			setFunc = function(value) MM_SetHideCompass(value) end,
			width = "full", default = false, },
	[3] = { type = "checkbox", name = GetString(SI_MM_SETTING_STARTUP), tooltip = GetString(SI_MM_SETTING_STARTUP_TOOLTIP),
			getFunc = function() return FyrMM.SV.StartupInfo end,
			setFunc = function(value) FyrMM.SV.StartupInfo = value end,
			width = "full", default = false, },
	[4] = { type = "checkbox", name = GetString(SI_MM_SETTING_MENU), tooltip = GetString(SI_MM_SETTING_MENU_TOOLTIP),
			getFunc = function() return FyrMM.SV.MenuDisabled end,
			setFunc = function(value) FyrMM.SV.MenuDisabled = value if value then Fyr_MM_Menu:SetHidden(true) MM_SetZoneFrameLocationOption(FyrMM.SV.ZoneFrameLocationOption) else Fyr_MM_Menu:SetHidden(false) MM_SetZoneFrameLocationOption(FyrMM.SV.ZoneFrameLocationOption) end end,
			width = "half", default = false, },
	[5] = { type = "checkbox", name = GetString(SI_MM_SETTING_MENUAUTOHIDE), tooltip = GetString(SI_MM_SETTING_MENUAUTOHIDE_TOOLTIP),
			getFunc = function() return FyrMM.SV.MenuAutoHide end,
			setFunc = function(value) FyrMM.SV.MenuAutoHide = value if not value then Fyr_MM_Menu:SetAlpha(1) else FyrMM.MenuFadeOut() end end,
			width = "half", default = false, },
	[6] = { type = "button", name = GetString(SI_MM_SETTING_WHEELDEFAULTS), tooltip = GetString(SI_MM_SETTING_WHEELDEFAULTS_TOOLTIP),
								func = function() MM_WheelModeDefaults() end, width = "half", },
	[7] = { type = "button", name = GetString(SI_MM_SETTING_SQUAREDEFAULTS), tooltip = GetString(SI_MM_SETTING_SQUAREDEFAULTS_TOOLTIP),
								func = function() MM_SquareModeDefaults() end, width = "half", },
	[8] = { type = "submenu", name = GetString(SI_MM_SETTING_SIZEOPTIONS),
			controls = {
						[1] = { type = "slider", name = GetString(SI_MM_SETTING_X), tooltip = GetString(SI_MM_SETTING_X_TOOTLITP),
								min = 0, max = zo_round(GuiRoot:GetWidth()-Fyr_MM:GetWidth()), step = 1,
								getFunc = function() return zo_round(Fyr_MM:GetLeft()) end,
								setFunc = function(value) if FyrMM.SV.LockPosition then return end local pos = {} pos.anchorTo = GetControl(pos.anchorTo) FyrMM.SV.position.offsetX = value
										Fyr_MM:SetAnchor(FyrMM.SV.position.point, pos.anchorTo, FyrMM.SV.position.relativePoint, value, FyrMM.SV.position.offsetY) end,
								width = "half",	default = 0, },
						[2] = {	type = "slider", name = GetString(SI_MM_SETTING_Y), tooltip = GetString(SI_MM_SETTING_Y_TOOLTIP),
								min = 0, max = zo_round(GuiRoot:GetHeight()-Fyr_MM:GetHeight()), step = 1,
								getFunc = function() return zo_round(Fyr_MM:GetTop()) end,
								setFunc = function(value)	if FyrMM.SV.LockPosition then return end local pos = {} pos.anchorTo = GetControl(pos.anchorTo) FyrMM.SV.position.offsetY = value
										Fyr_MM:SetAnchor(FyrMM.SV.position.point, pos.anchorTo, FyrMM.SV.position.relativePoint, FyrMM.SV.position.offsetX, value) end,
								width = "half",	default = 0, },
						[3] = { type = "slider", name = GetString(SI_MM_SETTING_WIDTH), tooltip = GetString(SI_MM_SETTING_WIDTH_TOOLTIP),
								min = 50, max = zo_round(GuiRoot:GetWidth()), step = 1,
								getFunc = function() return MM_GetMapWidth() end,
								setFunc = function(value) MM_SetMapWidth(value) end,
								width = "half",	default = 280, },
						[4] = {	type = "slider", name = GetString(SI_MM_SETTING_HEIGHT), tooltip = GetString(SI_MM_SETTING_HEIGHT_TOOLTIP),
								min = 50, max = zo_round(GuiRoot:GetHeight()), step = 1,
								getFunc = function() return MM_GetMapHeight() end,
								setFunc = function(value) MM_SetMapHeight(value) end,
								width = "half",	default = 280, },
						[5] = { type = "checkbox", name = GetString(SI_MM_SETTING_LOCK), tooltip = GetString(SI_MM_SETTING_LOCK_TOOLTIP),
								getFunc = function() return FyrMM.SV.LockPosition end,
								setFunc = function(value) MM_SetLockPosition(value) end,
								width = "full",	default = false, },
						[6] = { type = "checkbox", name = GetString(SI_MM_SETTING_CLAMP), tooltip = GetString(SI_MM_SETTING_CLAPM_TOOLTIP),
								getFunc = function() return MM_GetClampedToScreen() end,
								setFunc = function(value) MM_SetClampedToScreen(value) end,
								width = "half",	default = true,	}, }, },
	[9] = { type = "submenu", name = GetString(SI_MM_SETTING_MODEOPTIONS),
			controls = {
						[1] = { type = "slider", name = GetString(SI_MM_SETTING_ALPHA), tooltip = GetString(SI_MM_SETTING_ALPHA_TOOLTIP),
								min = 60, max = 100, step = 1,
								getFunc = function() return MM_GetMapAlpha() end,
								setFunc = function(value) MM_SetMapAlpha(value) end,
								width = "half",	default = 100, },
						[2] = {	type = "slider", name = GetString(SI_MM_SETTING_PINSCALE), tooltip = GetString(SI_MM_SETTING_PINSCALE_TOOLTIP),
								min = 25, max = 150, step = 1,
								getFunc = function() return MM_GetPinScale() end,
								setFunc = function(value) MM_SetPinScale(value) end,
								width = "half",	default = 75, },
						[3] = { type = "slider", name = GetString(SI_MM_SETTING_DEFAULTZOOM), tooltip = GetString(SI_MM_SETTING_DEFAULTZOOM_TOOLTIP),
								min = FYRMM_ZOOM_MIN, max = FYRMM_ZOOM_MAX, step = FYRMM_ZOOM_INCREMENT_AMOUNT,
								getFunc = function() return FYRMM_DEFAULT_ZOOM_LEVEL end,
								setFunc = function(value) FYRMM_DEFAULT_ZOOM_LEVEL = value FyrMM.SV.DefaultZoomLevel = value end,
								width = "full",	default = 10, },
						[4] = { type = "slider", name = GetString(SI_MM_SETTING_CURRENTZOOM), tooltip = GetString(SI_MM_SETTING_CURRENTZOOM_TOOLTIP),
								min = FYRMM_ZOOM_MIN, max = FYRMM_ZOOM_MAX, step = FYRMM_ZOOM_INCREMENT_AMOUNT,
								getFunc = function() return FyrMM.currentMap.ZoomLevel end,
								setFunc = function(value) FyrMM.SetCurrentMapZoom(value) end,
								width = "half",	default = FYRMM_DEFAULT_ZOOM_LEVEL, },
						[5] = { type = "slider", name = GetString(SI_MM_SETTING_ZOOMSTEPPING), tooltip = GetString(SI_MM_SETTING_ZOOMSTEPPING_TOOLTIP),
								min = 0.1, max = 2, step = 0.1,
								getFunc = function() return FYRMM_ZOOM_INCREMENT_AMOUNT end,
								setFunc = function(value) value = ("%1.1f"):format(value) FYRMM_ZOOM_INCREMENT_AMOUNT = tonumber(value) FyrMM.SV.ZoomIncrement = tonumber(value) end,
								width = "half",	default = 1, },
						[6] = {	type = "dropdown", name = GetString(SI_MM_SETTING_HEADING), tooltip = GetString(SI_MM_SETTING_HEADING_TOOLTIP),
								choices = {"CAMERA", "PLAYER", "MIXED"},
								getFunc = function() return MM_GetHeading() end,
								setFunc = function(value) MM_SetHeading(value) end,
								width = "half", default = "CAMERA" },
						[7] = { type = "checkbox", name = GetString(SI_MM_SETTING_PVP), tooltip = GetString(SI_MM_SETTING_PVP_TOOLTIP),
								getFunc = function() return MM_GetHidePvPPins() end,
								setFunc = function(value) MM_SetHidePvPPins(value) end,
								width = "half",	default = false, },
						[8] = { type = "checkbox", name = GetString(SI_MM_SETTING_ROTATION), tooltip = GetString(SI_MM_SETTING_ROTATION_TOOLTIP),
								getFunc = function() return FyrMM.SV.RotateMap end,
								setFunc = function(value) MM_SetRotateMap(value) if not value then FyrMM.PendingRotatePins = {} end end,
								width = "half",	default = false,	},
						[9] = { type = "checkbox", name = GetString(SI_MM_SETTING_WHEEL), tooltip = GetString(SI_MM_SETTING_WHEEL_TOOLTIP),
								getFunc = function() return FyrMM.SV.WheelMap end,
								setFunc = function(value) MM_SetWheelMap(value) if not value then FyrMM.PendingWheelPins = {} end end,
								width = "half",	default = false,	},
						[10] = { type = "checkbox", name = GetString(SI_MM_SETTING_VIEWRANGE), tooltip = GetString(SI_MM_SETTING_VIEWRANGE_TOOLTIP),
								getFunc = function() return FyrMM.SV.ViewRangeFiltering end,
								setFunc = function(value) FyrMM.SV.ViewRangeFiltering = value end,
								width = "half",	default = false,	},
						[11] = { type = "slider", name = GetString(SI_MM_SETTING_RANGE), tooltip = GetString(SI_MM_SETTING_RANGE_TOOLTIP),
								min = 50, max = 1000, step = 1,
								getFunc = function() return FyrMM.SV.CustomPinViewRange end,
								setFunc = function(value) FyrMM.SV.CustomPinViewRange = value end,
								width = "half",	default = 250, },
						[12] = {	type = "dropdown", name = GetString(SI_MM_SETTING_WHEELTEXTURE), tooltip = GetString(SI_MM_SETTING_WHEELTEXTURE_TOOLTIP),
								choices = FyrMM.WheelTextureList,
								getFunc = function() return FyrMM.SV.WheelTexture end,
								setFunc = function(value) MM_SetWheelTexture(value) end,
								width = "full", default = "Deathangel RMM Wheel" },
						[13]  = {	type = "dropdown", name = GetString(SI_MM_SETTING_MENUTEXTURE), tooltip = GetString(SI_MM_SETTING_MENUTEXTURE_TOOLTIP),
								choices = FyrMM.MenuTextureList,
								getFunc = function() return FyrMM.SV.MenuTexture end,
								setFunc = function(value) MM_SetMenuTexture(value) end,
								width = "full", default = "Default" },
						[14] = { type = "checkbox", name = GetString(SI_MM_SETTING_UNEXPLORED), tooltip = GetString(SI_MM_SETTING_UNEXPLORED_TOOLTIP),
								getFunc = function() return FyrMM.SV.ShowUnexploredPins end,
								setFunc = function(value) MM_SetShowUnexploredPins(value) end,
								width = "full",	default = true,	},
						[15] = { type = "colorpicker", name = GetString(SI_MM_SETTING_UNEXPLOREDCOLOR), tooltip = GetString(SI_MM_SETTING_UNEXPLOREDCOLOR_TOOLTIP),
								getFunc = function() return FyrMM.SV.UndiscoveredPOIPinColor.r, FyrMM.SV.UndiscoveredPOIPinColor.g, FyrMM.SV.UndiscoveredPOIPinColor.b, FyrMM.SV.UndiscoveredPOIPinColor.a end,
								setFunc = function(r,g,b,a) MM_SetUndiscoveredPOIPinColor(r, g, b, a) end,
								width = "full", },
						[16] = { type = "checkbox", name = GetString(SI_MM_SETTING_TOOLTIPS), tooltip = GetString(SI_MM_SETTING_TOOLTIPS_TOOLTIP),
								getFunc = function() return MM_GetPinTooltips() end,
								setFunc = function(value) MM_SetPinTooltips(value) end,
								width = "half",	default = true,	},
						[17] = { type = "checkbox", name = GetString(SI_MM_SETTING_FASTTRAVEL), tooltip = GetString(SI_MM_SETTING_FASTTRAVEL_TOOLTIP),
								getFunc = function() return MM_GetFastTravelEnabled() end,
								setFunc = function(value) MM_SetFastTravelEnabled(value) end,
								width = "half",	default = true,	},
						[18] = { type = "checkbox", name = GetString(SI_MM_SETTING_MOUSEZOOM), tooltip = GetString(SI_MM_SETTING_MOUSEZOOM_TOOLTIP),
								getFunc = function() return MM_GetMouseWheel() end,
								setFunc = function(value) MM_SetMouseWheel(value) end,
								width = "half",	default = true,	},
						[19] = { type = "checkbox", name = GetString(SI_MM_SETTING_BORDER), tooltip = GetString(SI_MM_SETTING_BORDER_TOOLTIP),
								getFunc = function() return MM_GetShowBorder() end,
								setFunc = function(value) MM_SetShowBorder(value) end,
								width = "half",	default = true,	},
						[20] = { type = "checkbox", name = GetString(SI_MM_SETTING_COMBATHIDE), tooltip = GetString(SI_MM_SETTING_COMBATHIDE_TOOLTIP),
								getFunc = function() return FyrMM.SV.InCombatAutoHide end,
								setFunc = function(value) MM_SetInCombatAutoHide(value) end,
								width = "half",	default = true,	},
						[21] = { type = "slider", name = GetString(SI_MM_SETTING_AUTOSHOW), tooltip = GetString(SI_MM_SETTING_AUTOSHOW_TOOLTIP),
								min = 1, max = 60, step = 1,
								getFunc = function() return FyrMM.SV.AfterCombatUnhideDelay end,
								setFunc = function(value) MM_SetAfterCombatUnhideDelay(value) end,
								width = "half",	default = 5, }, 
						[22] = { type = "checkbox", name = GetString(SI_MM_SETTING_SIEGE), tooltip = GetString(SI_MM_SETTING_SIEGE_TOOLTIP),
								getFunc = function() return FyrMM.SV.Siege end,
								setFunc = function(value) FyrMM.SV.Siege = value end,
								width = "full",	default = true, }, 
						[23] = { type = "checkbox", name = GetString(SI_MM_SETTING_SUBZONE), tooltip = GetString(SI_MM_SETTING_SUBZONE_TOOLTIP),
								getFunc = function() return FyrMM.SV.DisableSubzones end,
								setFunc = function(value) FyrMM.SV.DisableSubzones = value FyrMM.DisableSubzones = value end,
								width = "full",	default = false,	}, }, },
	[10] = { type = "submenu", name = GetString(SI_MM_SETTING_INFOOPTIONS),
			controls = {
						[1] = { type = "checkbox", name = GetString(SI_MM_SETTING_POSITION), tooltip = GetString(SI_MM_SETTING_POSITION_TOOLTIP),
								getFunc = function() return MM_GetShowPosition() end,
								setFunc = function(value) MM_SetShowPosition(value) end,
								width = "full",	default = true,	},
						[2] = { type = "checkbox", name = GetString(SI_MM_SETTING_POSITIONBACKGROUND), tooltip = GetString(SI_MM_SETTING_POSITIONBACKGROUND_TOOLTIP),
								getFunc = function() return FyrMM.SV.PositionBackground end,
								setFunc = function(value) MM_SetPositionBackground(value) end,
								width = "full",	default = true,	},			
						[3] = {	type = "dropdown", name = GetString(SI_MM_SETTING_POSITIONLOCATION), tooltip = GetString(SI_MM_SETTING_POSITIONLOCATION_TOOLTIP),
								choices = {"Top", "Bottom", "Free"},
								getFunc = function() return FyrMM.SV.CorrdinatesLocation end,
								setFunc = function(value) MM_SetCoordinatesLocation(value) end,
								width = "half", default = "Top" },
						[4] = { type = "colorpicker", name = GetString(SI_MM_SETTING_POSITIONCOLOR), tooltip = GetString(SI_MM_SETTING_POSITIONCOLOR_TOOLTIP),
								getFunc = function() return FyrMM.SV.PositionColor.r, FyrMM.SV.PositionColor.g, FyrMM.SV.PositionColor.b, FyrMM.SV.PositionColor.a end,
								setFunc = function(r,g,b,a) MM_SetPositionColor(r, g, b, a) end,
								width = "half", },
						[5] = {	type = "dropdown", name = GetString(SI_MM_SETTING_POSITIONFONT), tooltip = GetString(SI_MM_SETTING_POSITIONFONT_TOOLTIP),
								choices = FyrMM.FontList,
								getFunc = function() return FyrMM.SV.PositionFont end,
								setFunc = function(value) if value ~= nil then FyrMM.SV.PositionFont = value MM_SetPositionFont() end end,
								width = "half", default = "Univers 57" },
						[6] = { type = "slider", name = GetString(SI_MM_SETTING_POSITIONSIZE), tooltip = GetString(SI_MM_SETTING_POSITIONSIZE_TOOLTIP),
								min = 6, max = 50, step = 1,
								getFunc = function() return FyrMM.SV.PositionHeight end,
								setFunc = function(value) if value ~= nil then FyrMM.SV.PositionHeight = value MM_SetPositionFont() end end,
								width = "half",	default = 18, },
						[7] = {type = "dropdown", name = GetString(SI_MM_SETTING_POSITIONSTYLE), tooltip = GetString(SI_MM_SETTING_POSITIONSTYLE_TOOLTIP),
								choices = FyrMM.FontStyles,
								getFunc = function() return FyrMM.SV.PositionFontStyle end,
								setFunc = function(value) if value ~= nil then FyrMM.SV.PositionFontStyle = value MM_SetPositionFont() end end,
								width = "full", default = "normal" },
						[8] = { type = "checkbox", name = GetString(SI_MM_SETTING_MAPNAME), tooltip = GetString(SI_MM_SETTING_MAPNAME_TOOLTIP),
								getFunc = function() return not MM_GetHideZoneLabel() end,
								setFunc = function(value) MM_SetHideZoneLabel(not value) end,
								width = "half", default = true, },
						[9] = {	type = "dropdown", name = GetString(SI_MM_SETTING_MAPNAMESTYLE), tooltip = GetString(SI_MM_SETTING_MAPNAMESTYLE_TOOLTIP),
								choices = {"Classic (Map only)", "Map & Area", "Area only"},
								getFunc = function() return FyrMM.SV.ZoneNameContents end,
								setFunc = function(value) if value ~= nil then FyrMM.SV.ZoneNameContents = value FyrMM.UpdateLabels() end end,
								width = "half", default = "Classic (Map only)" },
						[10] = { type = "checkbox", name = GetString(SI_MM_SETTING_MAPNAMEBACKGROUND), tooltip = GetString(SI_MM_SETTING_MAPNAMEBACKGROUND_TOOLTIP),
								getFunc = function() return FyrMM.SV.ShowZoneBackground end,
								setFunc = function(value) MM_SetShowZoneBackground(value) end,
								width = "full", default = true, },
						[11] = {	type = "dropdown", name = GetString(SI_MM_SETTING_MAPNAMELOCATION), tooltip = GetString(SI_MM_SETTING_MAPNAMELOCATION_TOOLTIP),
								choices = {"Default", "Free"},
								getFunc = function() return FyrMM.SV.ZoneFrameLocationOption end,
								setFunc = function(value) MM_SetZoneFrameLocationOption(value) end,
								width = "half", default = "Top" },
						[12] = { type = "colorpicker", name = GetString(SI_MM_SETTING_MAPNAMECOLOR), tooltip = GetString(SI_MM_SETTING_MAPNAMECOLOR_TOOLTIP),
								getFunc = function() return FyrMM.SV.ZoneNameColor.r, FyrMM.SV.ZoneNameColor.g, FyrMM.SV.ZoneNameColor.b, FyrMM.SV.ZoneNameColor.a end,
								setFunc = function(r,g,b,a) MM_SetZoneNameColor(r, g, b, a) end,
								width = "half", },
						[13] = {	type = "dropdown", name = GetString(SI_MM_SETTING_MAPNAMEFONT), tooltip = GetString(SI_MM_SETTING_MAPNAMEFONT_TOOLTIP),
								choices = FyrMM.FontList,
								getFunc = function() return FyrMM.SV.ZoneFont end,
								setFunc = function(value) if value ~= nil then FyrMM.SV.ZoneFont = value MM_SetZoneFont() end end,
								width = "half", default = "Univers 57" },
						[14] = { type = "slider", name = GetString(SI_MM_SETTING_MAPNAMESIZE), tooltip = GetString(SI_MM_SETTING_MAPNAMESIZE_TOOLTIP),
								min = 6, max = 50, step = 1,
								getFunc = function() return FyrMM.SV.ZoneFontHeight end,
								setFunc = function(value) if value ~= nil then FyrMM.SV.ZoneFontHeight = value MM_SetZoneFont() end end,
								width = "half",	default = 18, },
						[15] = {type = "dropdown", name = GetString(SI_MM_SETTING_MAPNAMESTYLE), tooltip = GetString(SI_MM_SETTING_MAPNAMESTYLE_TOOLTIP),
								choices = FyrMM.FontStyles,
								getFunc = function() return FyrMM.SV.ZoneFontStyle end,
								setFunc = function(value) if value ~= nil then FyrMM.SV.ZoneFontStyle = value MM_SetZoneFont() end end,
								width = "full", default = "normal" },
						[16] = { type = "checkbox", name = GetString(SI_MM_SETTING_ZOOMLABEL), tooltip = GetString(SI_MM_SETTING_ZOOMLABEL_TOOLTIP),
								getFunc = function() return MM_GetHideZoomLevel() end,
								setFunc = function(value) MM_SetHideZoomLevel(value) end,
								width = "half",	default = false, },
						[17] = { type = "checkbox", name = GetString(SI_MM_SETTING_CLOCK), tooltip = GetString(SI_MM_SETTING_CLOCK_TOOLTIP),
								getFunc = function() return FyrMM.SV.ShowClock end,
								setFunc = function(value) FyrMM.SV.ShowClock = value end,
								width = "half",	default = false,	},
						[18] = { type = "checkbox", name = GetString(SI_MM_SETTING_FPS), tooltip = GetString(SI_MM_SETTING_FPS_TOOLTIP),
								getFunc = function() return FyrMM.SV.ShowFPS end,
								setFunc = function(value) FyrMM.SV.ShowFPS = value end,
								width = "half",	default = false, }, 
						[19] = { type = "checkbox", name = GetString(SI_MM_SETTING_SPEED), tooltip = GetString(SI_MM_SETTING_SPEED_TOOLTIP),
								getFunc = function() return FyrMM.SV.ShowSpeed end,
								setFunc = function(value) FyrMM.SV.ShowSpeed = value Fyr_MM_Speed:SetHidden(not value) end,
								width = "full",	default = false, },
						[20] = { type = "dropdown", name = GetString(SI_MM_SETTING_SPEEDSTYLE), tooltip = GetString(SI_MM_SETTING_SPEEDSTYLE_TOOLTIP),
								choices = FyrMM.SpeedUnits,
								getFunc = function() return FyrMM.SV.SpeedUnit end,
								setFunc = function(value) if value ~= nil then FyrMM.SV.SpeedUnit = value end end,
								width = "full", default = "ft/s" }, }, },
	[11] = { type = "submenu", name = GetString(SI_MM_SETTING_GROUPOPTIONS),
			controls = {
						[1] = {	type = "dropdown", name = GetString(SI_MM_SETTING_PLAYERSTYLE), tooltip = GetString(SI_MM_SETTING_PLAYERSTYLE_TOOLTIP),
								choices = {GetString(SI_MM_STRING_CLASSIC), GetString(SI_MM_STRING_PLAYERANDCAMERA)},
								getFunc = function() return FyrMM.SV.PPStyle end,
								setFunc = function(value) MM_SetPPStyle(value) end,
								width = "full", default = GetString(SI_MM_PLAYERANDCAMERA) },
						[2] = {	type = "dropdown", name = GetString(SI_MM_SETTING_PLAYERTEXTURE), tooltip = GetString(SI_MM_SETTING_PLAYERTEXTURE_TOOLTIP),
								choices = {"ESO UI Worldmap", "MiniMap", "Vixion Regular", "Vixion Gold"},
								getFunc = function() return FyrMM.SV.PPTextures end,
								setFunc = function(value) MM_SetPPTextures(value) end,
								width = "full", default = "ESO UI Worldmap" },
						[3] = { type = "checkbox", name = GetString(SI_MM_SETTING_COMBATSTATE), tooltip = GetString(SI_MM_SETTING_COMBATSTATE_TOOLTIP),
								getFunc = function() return FyrMM.SV.InCombatState end,
								setFunc = function(value) FyrMM.SV.InCombatState = value end,
								width = "full",	default = true,	},
						[4] = { type = "dropdown", name = GetString(SI_MM_SETTING_LEADER), tooltip = GetString(SI_MM_SETTING_LEADER_TOLLTIP),
								choices = {"Default", "Role", "Class"},
								getFunc = function() return FyrMM.SV.LeaderPin end,
								setFunc = function(value) MM_SetLeaderPin(value) end,
								width = "half", default = "Default", warning = GetString(SI_MM_SETTING_UIWARNING) },
						[5] = { type = "slider", name = GetString(SI_MM_SETTING_LEADERSIZE), tooltip = GetString(SI_MM_SETTING_LEADERSIZE_TOOLTIP),
								min = 8, max = 32, step = 1,
								getFunc = function() return FyrMM.SV.LeaderPinSize end,
								setFunc = function(value) MM_SetLeaderPinSize(value) end,
								width = "half",	default = 32, },
						[6] = { type = "colorpicker", name = GetString(SI_MM_SETTING_LEADERCOLOR), tooltip = GetString(SI_MM_SETTING_LEADERCOLOR_TOOLTIP),
								getFunc = function() return FyrMM.SV.LeaderPinColor.r, FyrMM.SV.LeaderPinColor.g, FyrMM.SV.LeaderPinColor.b, FyrMM.SV.LeaderPinColor.a end,
								setFunc = function(r,g,b,a) MM_SetLeaderPinColor(r, g, b, a) end,
								width = "full", },
						[7] = { type = "colorpicker", name = GetString(SI_MM_SETTING_LEADERDEADCOLOR), tooltip = GetString(SI_MM_SETTING_LEADERDEADCOLOR_TOOLTIP),
								getFunc = function() return FyrMM.SV.LeaderDeadPinColor.r, FyrMM.SV.LeaderDeadPinColor.g, FyrMM.SV.LeaderDeadPinColor.b, FyrMM.SV.LeaderDeadPinColor.a end,
								setFunc = function(r,g,b,a) MM_SetLeaderDeadPinColor(r, g, b, a) end,
								width = "full", },
						[8] = { type = "dropdown", name = GetString(SI_MM_SETTING_MEMBER), tooltip = GetString(SI_MM_SETTING_MEMBER_TOLLTIP),
								choices = {"Default", "Role", "Class"},
								getFunc = function() return FyrMM.SV.MemberPin end,
								setFunc = function(value) MM_SetMemberPin(value) end,
								width = "half", default = "Default", warning = GetString(SI_MM_SETTING_UIWARNING) },
						[9] = { type = "slider", name = GetString(SI_MM_SETTING_MEMBERSIZE), tooltip = GetString(SI_MM_SETTING_MEMBERSIZE_TOOLTIP),
								min = 8, max = 32, step = 1,
								getFunc = function() return FyrMM.SV.MemberPinSize end,
								setFunc = function(value) MM_SetMemberPinSize(value) end,
								width = "half",	default = 32, },
						[10] = { type = "colorpicker", name = GetString(SI_MM_SETTING_MEMBERCOLOR), tooltip = GetString(SI_MM_SETTING_MEMBERCOLOR_TOOLTIP),
								getFunc = function() return FyrMM.SV.MemberPinColor.r, FyrMM.SV.MemberPinColor.g, FyrMM.SV.MemberPinColor.b, FyrMM.SV.MemberPinColor.a end,
								setFunc = function(r,g,b,a) MM_SetMemberPinColor(r, g, b, a) end,
								width = "full", },
						[11] = { type = "colorpicker", name = GetString(SI_MM_SETTING_MEMBERDEADCOLOR), tooltip = GetString(SI_MM_SETTING_MEMBERDEADCOLOR_TOOLTIP),
								getFunc = function() return FyrMM.SV.MemberDeadPinColor.r, FyrMM.SV.MemberDeadPinColor.g, FyrMM.SV.MemberDeadPinColor.b, FyrMM.SV.MemberDeadPinColor.a end,
								setFunc = function(r,g,b,a) MM_SetMemberDeadPinColor(r, g, b, a) end,
								width = "full", },
						[12] = { type = "checkbox", name = GetString(SI_MM_SETTING_SHOWGROUPLABELS), tooltip = GetString(SI_MM_SETTING_SHOWGROUPLABELS_TOOLTIP),
								getFunc = function() return FyrMM.SV.ShowGroupLabels end,
								setFunc = function(value) FyrMM.SV.ShowGroupLabels = value end,
								width = "full",	default = false,	},
						[13] = { type = "button", name = GetString(SI_MM_SETTING_RELOADUI), tooltip = GetString(SI_MM_SETTING_RELOADUI_TOOLTIP),
								func = function() ReloadUI("ingame") end, width = "full", }, }, },
	[12] = { type = "submenu", name = GetString(SI_MM_SETTING_BORDEROPTIONS),
			controls = {
						[1] = { type = "checkbox", name = GetString(SI_MM_SETTING_BORDERPINS), tooltip = GetString(SI_MM_SETTING_BORDERPINS_TOOLTIP),
							getFunc = function() return FyrMM.SV.BorderPins end,
							setFunc = function(value) MM_SetBorderPins(value) end,
							width = "full",	default = true,	},
						[2] = { type = "checkbox", name = GetString(SI_MM_SETTING_ASSISTED), tooltip = GetString(SI_MM_SETTING_ASSISTED_TOOLTIP),
							getFunc = function() return FyrMM.SV.BorderPinsOnlyAssisted end,
							setFunc = function(value) MM_SetBorderPinsOnlyAssisted(value) end,
							width = "full",	default = true,	},
						[3] = { type = "checkbox", name = GetString(SI_MM_SETTING_LEADERONLY), tooltip = GetString(SI_MM_SETTING_LEADERONLY_TOOLTIP),
							getFunc = function() return FyrMM.SV.BorderPinsOnlyLeader end,
							setFunc = function(value) MM_SetBorderPinsOnlyLeader(value) end,
							width = "full",	default = true,	},
						[4] = { type = "checkbox", name = GetString(SI_MM_SETTING_WAYPOINT), tooltip = GetString(SI_MM_SETTING_WAYPOINT_TOOLTIP),
							getFunc = function() return FyrMM.SV.BorderPinsWaypoint end,
							setFunc = function(value) MM_SetBorderPinsWaypoint(value) end,
							width = "full",	default = true,	},
						[5] = { type = "checkbox", name = GetString(SI_MM_SETTING_BANK), tooltip = GetString(SI_MM_SETTING_BANK_TOOLTIP),
							getFunc = function() return FyrMM.SV.BorderPinsBank end,
							setFunc = function(value) FyrMM.SV.BorderPinsBank = value end,
							width = "full",	default = true,	},
						[6] = { type = "checkbox", name = GetString(SI_MM_SETTING_STABLES), tooltip = GetString(SI_MM_SETTING_STABLES_TOOLTIP),
							getFunc = function() return FyrMM.SV.BorderPinsStables end,
							setFunc = function(value) FyrMM.SV.BorderPinsStables = value end,
							width = "full",	default = true,	},							
						[7] = { type = "checkbox", name = GetString(SI_MM_SETTING_WAYSHRINE), tooltip = GetString(SI_MM_SETTING_WAYSHRINE_TOOLTIP),
							getFunc = function() return FyrMM.SV.BorderWayshrine end,
							setFunc = function(value) FyrMM.SV.BorderWayshrine = value end,
							width = "full",	default = true,	},								
						[8] = { type = "checkbox", name = GetString(SI_MM_SETTING_TREASURE), tooltip = GetString(SI_MM_SETTING_TREASURE_TOOLTIP),
							getFunc = function() return FyrMM.SV.BorderTreasures end,
							setFunc = function(value) FyrMM.SV.BorderTreasures = value end,
							width = "full",	default = true,	},
						[9] = { type = "checkbox", name = GetString(SI_MM_SETTING_QUESTGIVERS), tooltip = GetString(SI_MM_SETTING_QUESTGIVERS_TOOLTIP),
							getFunc = function() return FyrMM.SV.BorderQuestGivers end,
							setFunc = function(value) FyrMM.SV.BorderQuestGivers = value end,
							width = "full",	default = true,	},
						[10] = { type = "checkbox", name = GetString(SI_MM_SETTING_CRAFTING), tooltip = GetString(SI_MM_SETTING_CRAFTING_TOOLTIP),
							getFunc = function() return FyrMM.SV.BorderCrafting end,
							setFunc = function(value) FyrMM.SV.BorderCrafting = value end,
							width = "full",	default = false, }, }, },
	[13] = { type = "submenu", name = GetString(SI_MM_SETTING_PERFORMANCEOPTIONS),
			controls = {
						[1] = { type = "slider", name = GetString(SI_MM_SETTING_POSITIONREFRESH), tooltip = GetString(SI_MM_SETTING_POSITIONREFRESH_TOOLTIP),
								min = 10, max = 250, step = 1,
								getFunc = function() return MM_GetMapRefreshRate() end,
								setFunc = function(value) MM_SetMapRefreshRate(value) end,
								width = "half",	default = 60, },
						[2] = { type = "slider", name = GetString(SI_MM_SETTING_PINREFRESH), tooltip = GetString(SI_MM_SETTING_PINREFRESH_TOOLTIP),
								min = 100, max = 2000, step = 1,
								getFunc = function() return MM_GetPinRefreshRate() end,
								setFunc = function(value) MM_SetPinRefreshRate(value) end,
								width = "half",	default = 600, },
--						[3] = { type = "slider", name = GetString(SI_MM_SETTING_TEXTUREREFRESH), tooltip = GetString(SI_MM_SETTING_TEXTUREREFRESH_TOOLTIP),
--								min = 300, max = 5000, step = 1,
--								getFunc = function() return MM_GetViewRefreshRate() end,
--								setFunc = function(value) MM_SetViewRefreshRate(value) end,
--								width = "half",	default = 2500,	},
						[3] = { type = "slider", name = GetString(SI_MM_SETTING_ZONEREFRESH), tooltip = GetString(SI_MM_SETTING_ZONEREFRESH_TOOLTIP),
								min = 25, max = 600, step = 1,
								getFunc = function() return MM_GetZoneRefreshRate() end,
								setFunc = function(value) MM_SetZoneRefreshRate(value) end,
								width = "half",	default = 100, },
						[4] = { type = "slider", name = GetString(SI_MM_SETTING_AVAREFRESH), tooltip = GetString(SI_MM_SETTING_AVA_REFRESH_TOOLTIP),
								min = 900, max = 8000, step = 1,
								getFunc = function() return MM_GetKeepNetworkRefreshRate() end,
								setFunc = function(value) MM_SetKeepNetworkRefreshRate(value) end,
								width = "half",	default = 2000, },
--						[5] = { type = "slider", name = GetString(SI_MM_SETTING_SCROLLSTEPPING), tooltip = GetString(SI_MM_SETTING_SCROLLSTEPPING_TOOLTIP),
--								min = 0.1, max = 5, step = 0.1,
--								getFunc = function() return MM_GetMapStepping() end,
--								setFunc = function(value) MM_SetMapStepping(value) end,
--								width = "half",	default = 2, },
						[5] = { type = "slider", name = GetString(SI_MM_SETTING_CHUNKDELAY), tooltip = GetString(SI_MM_SETTING_CHUNKDELAY_TOOLTIP),
								min = 10, max = 150, step = 1,
								getFunc = function() return FyrMM.SV.ChunkDelay end,
								setFunc = function(value) FyrMM.SV.ChunkDelay = value end,
								width = "half",	default = 50, },
						[6] = { type = "slider", name = GetString(SI_MM_SETTING_CHUNKSIZE), tooltip = GetString(SI_MM_SETTING_CHUNKSIZE_TOOLTIP),
								min = 10, max = 200, step = 1,
								getFunc = function() return FyrMM.SV.ChunkSize end,
								setFunc = function(value) FyrMM.SV.ChunkSize = value end,
								width = "half",	default = 50, },
   						[7] = { type = "checkbox", name = GetString(SI_MM_SETTING_WORLDMAPREFRESH), tooltip = GetString(SI_MM_SETTING_WORLDMAPREFRESH_TOOLTIP),
								getFunc = function() return FyrMM.SV.WorldMapRefresh end,
								setFunc = function(value) FyrMM.SV.WorldMapRefresh = value end,
								width = "full",	default = true,	}, }, },
	}
end

function MM_ResetToDefaults() -- Hardcoded reset
	MM_SetLockPosition(false)
	FyrMM.SV.HideZoneLabel = false
	FyrMM.SV.HideZoomLevel = false
	FyrMM.SV.ShowBorder = true
	FyrMM.SV.ClampedToScreen = true
	local pos = {}
	pos.anchorTo = GetControl(pos.anchorTo)
	Fyr_MM:SetAnchor(TOPLEFT, pos.anchorTo, TOPLEFT, 0, 0)	FyrMM.SV.MapHeight = 280
	FyrMM.SV.MapWidth = 280
	MM_SetMapHeight(280)
	MM_SetMapWidth(280)
	Fyr_MM_Border:SetWidth(288)
	Fyr_MM_Border:SetHeight(288)
	FyrMM.SV.MapAlpha = 100
	FyrMM.SV.Heading = "CAMERA"
	FyrMM.SV.PinScale = 75
	FyrMM.SV.PinTooltips = true
	FyrMM.SV.ShowPosition = true
	FyrMM.SV.HidePvPPins = false
	FyrMM.SV.MouseWheel = true
	MM_SetMapRefreshRate(40)
	MM_SetPinRefreshRate(600)
	MM_SetViewRefreshRate(1200)
	MM_SetZoneRefreshRate(100)
	MM_SetKeepNetworkRefreshRate(300)
	FyrMM.SV.hideCompass = false
	MM_SetHideCompass(false)
	FyrMM.SV.ShowClock = false
	FyrMM.SV.InCombatState = true
	FyrMM.SV.FastTravelEnabled = false
	FyrMM.SV.LeaderPin = "Default"
	FyrMM.SV.LeaderPinSize = 32
	FyrMM.SV.MemberPin = "Default"
	FyrMM.SV.MemberPinSize = 32
	MM_SetLeaderPinColor(1, 1, 1, 1)
	MM_SetLeaderDeadPinColor(1, 1, 1, 1)
	MM_SetMemberPinColor(1, 1, 1, 1)
	MM_SetMemberDeadPinColor(1, 1, 1, 1)
	FyrMM.SV.ZoomTable = {}
	FyrMM.SV.MapStepping = 2
	FyrMM_ZOOM_INCREMENT_AMOUNT = 1
	FyrMM.SV.ZoomIncrement = 1
	FyrMM.SV.InCombatAutoHide = false
	FyrMM.SV.AfterCombatUnhideDelay = 5
	FyrMM.SV.UseOriginalAPI = true
	MM_SetShowUnexploredPins(true)
	MM_SetUndiscoveredPOIPinColor(.7,.7,.3,.6)
	MM_SetPositionColor(0.996078431372549, 0.92, 0.3137254901960784, 1)
	FyrMM.SV.RotateMap = false
	MM_SetWheelMap(false)
	FyrMM.SV.BorderPins = false
	FyrMM.SV.BorderPinsWaypoint = false
	MM_SetCoordinatesLocation("Top")
	FyrMM.SV.StartupInfo = false
	FyrMM.SV.ZoneNameContents = "Classic (Map only)"
end

function MM_LoadSavedVars()	
	if FyrMM.SV.position ~= nil then
		local pos = {}
		pos.anchorTo = GetControl(pos.anchorTo)
		Fyr_MM:SetAnchor(FyrMM.SV.position.point, pos.anchorTo, FyrMM.SV.position.relativePoint, FyrMM.SV.position.offsetX, FyrMM.SV.position.offsetY)
		Fyr_MM_Bg:SetAnchorFill(Fyr_MM)
	end
	if FyrMM.SV.ZoneList ~= nil then FyrMM.SV.ZoneList = nil end
	if FyrMM.SV.MapHeight ~= nil then MM_SetMapHeight(FyrMM.SV.MapHeight) end
	if FyrMM.SV.MapWidth ~= nil then MM_SetMapWidth(FyrMM.SV.MapWidth) end
	if FyrMM.SV.MapAlpha ~= nil then MM_SetMapAlpha(FyrMM.SV.MapAlpha) end
	if FyrMM.SV.PinScale ~= nil then MM_SetPinScale(FyrMM.SV.PinScale) end
	if FyrMM.SV.ShowBorder ~= nil then MM_SetShowBorder(FyrMM.SV.ShowBorder) end
	if FyrMM.SV.Heading ~= nil then MM_SetHeading(FyrMM.SV.Heading) end
	if FyrMM.SV.ClampedToScreen ~= nil then MM_SetClampedToScreen(FyrMM.SV.ClampedToScreen) end
	if FyrMM.SV.hideCompass ~= nil then MM_SetHideCompass(FyrMM.SV.hideCompass) end
	if FyrMM.SV.ShowPosition ~= nil then MM_SetShowPosition(FyrMM.SV.ShowPosition) end
	if FyrMM.SV.PositionBackground ~= nil then MM_SetPositionBackground(FyrMM.SV.PositionBackground) end
	if FyrMM.SV.PositionColor ~= nil then MM_SetPositionColor(FyrMM.SV.PositionColor.r, FyrMM.SV.PositionColor.g, FyrMM.SV.PositionColor.b, FyrMM.SV.PositionColor.a) end
	if FyrMM.SV.PinTooltips ~= nil then MM_SetPinTooltips(FyrMM.SV.PinTooltips) end
	if FyrMM.SV.FastTravelEnabled ~= nil then MM_SetFastTravelEnabled(FyrMM.SV.FastTravelEnabled) end
	if FyrMM.SV.HidePvPPins ~= nil then MM_SetHidePvPPins(FyrMM.SV.HidePvPPins) end
	if FyrMM.SV.MouseWheel ~= nil then MM_SetMouseWheel(FyrMM.SV.MouseWheel) end
	if FyrMM.SV.WheelTexture ~= nil then MM_SetWheelTexture(FyrMM.SV.WheelTexture) end
	if FyrMM.SV.MapRefreshRate ~= nil then MM_SetMapRefreshRate(FyrMM.SV.MapRefreshRate) end
	if FyrMM.SV.PinRefreshRate ~= nil then MM_SetPinRefreshRate(FyrMM.SV.PinRefreshRate) end
	if FyrMM.SV.ViewRefreshRate ~= nil then MM_SetViewRefreshRate(FyrMM.SV.ViewRefreshRate) end
	if FyrMM.SV.ZoneRefreshRate ~= nil then MM_SetZoneRefreshRate(FyrMM.SV.ZoneRefreshRate) end
	if FyrMM.SV.KeepNetworkRefreshRate ~= nil then MM_SetKeepNetworkRefreshRate(FyrMM.SV.KeepNetworkRefreshRate) end
	if FyrMM.SV.HideZoneLabel ~= nil then MM_SetHideZoneLabel(FyrMM.SV.HideZoneLabel) end
	if FyrMM.SV.ShowZoneBackground ~= nil then MM_SetShowZoneBackground(FyrMM.SV.ShowZoneBackground) end
	if FyrMM.SV.ZoneFrameLocationOption ~= nil then MM_SetZoneFrameLocationOption(FyrMM.SV.ZoneFrameLocationOption) end
	if FyrMM.SV.ZoneFrameAnchor ~= nil then MM_SetZoneFrameAnchor(FyrMM.SV.ZoneFrameAnchor) end
	if FyrMM.SV.ZoneFontHeight ~= nil then MM_SetZoneFont() end
	if FyrMM.SV.ZoneFont ~= nil then MM_SetZoneFont() end
	if FyrMM.SV.ZoneFontStyle ~= nil then MM_SetZoneFont() end
	if FyrMM.SV.PositionFont ~= nil then MM_SetPositionFont() end
	if FyrMM.SV.PositionHeight ~= nil then MM_SetPositionFont() end
	if FyrMM.SV.PositionFontStyle ~= nil then MM_SetPositionFont() end
	if FyrMM.SV.ZoneNameColor ~= nil then MM_SetZoneNameColor(FyrMM.SV.ZoneNameColor.r, FyrMM.SV.ZoneNameColor.g, FyrMM.SV.ZoneNameColor.b, FyrMM.SV.ZoneNameColor.a) end
	if FyrMM.SV.HideZoomLevel ~= nil then MM_SetHideZoomLevel(FyrMM.SV.HideZoomLevel) end
	if FyrMM.SV.ShowClock ~= nil then MM_SetShowClock(FyrMM.SV.ShowClock) end
	if FyrMM.SV.ShowFPS ~= nil then MM_SetShowFPS(FyrMM.SV.ShowFPS) end
	if FyrMM.SV.LeaderPin ~= nil then MM_SetLeaderPin(FyrMM.SV.LeaderPin) end
	if FyrMM.SV.LeaderPinSize ~= nil then MM_SetLeaderPinSize(FyrMM.SV.LeaderPinSize) end
	if FyrMM.SV.LeaderPinColor ~= nil then MM_SetLeaderPinColor(FyrMM.SV.LeaderPinColor.r, FyrMM.SV.LeaderPinColor.g, FyrMM.SV.LeaderPinColor.b, FyrMM.SV.LeaderPinColor.a) end
	if FyrMM.SV.LeaderDeadPinColor ~= nil then MM_SetLeaderDeadPinColor(FyrMM.SV.LeaderDeadPinColor.r, FyrMM.SV.LeaderDeadPinColor.g, FyrMM.SV.LeaderDeadPinColor.b, FyrMM.SV.LeaderDeadPinColor.a) end
	if FyrMM.SV.MemberPin ~= nil then MM_SetMemberPin(FyrMM.SV.MemberPin) end
	if FyrMM.SV.MemberPinSize ~= nil then MM_SetMemberPinSize(FyrMM.SV.MemberPinSize) end
	if FyrMM.SV.MemberPinColor ~= nil then MM_SetMemberPinColor(FyrMM.SV.MemberPinColor.r, FyrMM.SV.MemberPinColor.g, FyrMM.SV.MemberPinColor.b, FyrMM.SV.MemberPinColor.a) end
	if FyrMM.SV.MemberDeadPinColor ~= nil then MM_SetMemberDeadPinColor(FyrMM.SV.MemberDeadPinColor.r, FyrMM.SV.MemberDeadPinColor.g, FyrMM.SV.MemberDeadPinColor.b, FyrMM.SV.MemberDeadPinColor.a) end
	if FyrMM.SV.MapStepping ~=nil then MM_SetMapStepping(FyrMM.SV.MapStepping) end
	if FyrMM.SV.ZoomIncrement ~=nil then FYRMM_ZOOM_INCREMENT_AMOUNT = tonumber(FyrMM.SV.ZoomIncrement) FyrMM.SV.ZoomIncrement = FYRMM_ZOOM_INCREMENT_AMOUNT end
	if FyrMM.SV.DefaultZoomLevel ~= nil then FYRMM_DEFAULT_ZOOM_LEVEL = tonumber(FyrMM.SV.DefaultZoomLevel) FyrMM.SV.DefaultZoomLevel = FYRMM_DEFAULT_ZOOM_LEVEL end
	if FyrMM.SV.InCombatAutoHide ~=nil then MM_SetInCombatAutoHide(FyrMM.SV.InCombatAutoHide) end
	if FyrMM.SV.AfterCombatUnhideDelay ~=nil then MM_SetAfterCombatUnhideDelay(FyrMM.SV.AfterCombatUnhideDelay) end
	if FyrMM.SV.LockPosition ~=nil then MM_SetLockPosition(FyrMM.SV.LockPosition) end
	if FyrMM.SV.UseOriginalAPI ~= nil then MM_SetUseOriginalAPI(FyrMM.SV.UseOriginalAPI) end
	if FyrMM.SV.ShowUnexploredPins ~= nil then MM_SetShowUnexploredPins(FyrMM.SV.ShowUnexploredPins) end
	if FyrMM.SV.RotateMap ~= nil then MM_SetRotateMap(FyrMM.SV.RotateMap) end
	if FyrMM.SV.WheelMap ~= nil then MM_SetWheelMap(FyrMM.SV.WheelMap) end
	if FyrMM.SV.BorderPins ~= nil then MM_SetBorderPins(FyrMM.SV.BorderPins) end
	if FyrMM.SV.BorderPinsWaypoint ~= nil then MM_SetBorderPinsWaypoint(FyrMM.SV.BorderPinsWaypoint) end
	if FyrMM.SV.CorrdinatesLocation ~= nil then MM_SetCoordinatesLocation(FyrMM.SV.CorrdinatesLocation) end
	if FyrMM.SV.CoordinatesAnchor ~= nil then MM_SetCoordinatesAnchor(FyrMM.SV.CoordinatesAnchor) end
	if FyrMM.SV.PPStyle ~= nil then MM_SetPPStyle(FyrMM.SV.PPStyle) end
	if FyrMM.SV.PPTextures ~= nil then MM_SetPPTextures(FyrMM.SV.PPTextures) end
	if FyrMM.SV.MenuDisabled ~= nil then Fyr_MM_Menu:SetHidden(FyrMM.SV.MenuDisabled) end
	if FyrMM.SV.MenuTexture ~= nil then MM_SetMenuTexture(FyrMM.SV.MenuTexture) end
	if FyrMM.SV.ShowSpeed ~= nil then Fyr_MM_Speed:SetHidden(not FyrMM.SV.ShowSpeed) end
	if FyrMM.SV.MapSettings ~= nil then MM_Upgrade_MapList() end -- Upgrade from version earlier to v2.15
	if FyrMM.SV.DisableSubzones ~= nil then FyrMM.DisableSubzones = FyrMM.SV.DisableSubzones end
	if FyrMM.SV.UndiscoveredPOIPinColor ~= nil then MM_SetUndiscoveredPOIPinColor(FyrMM.SV.UndiscoveredPOIPinColor.r, FyrMM.SV.UndiscoveredPOIPinColor.g, FyrMM.SV.UndiscoveredPOIPinColor.b, FyrMM.SV.UndiscoveredPOIPinColor.a) end
end

function MM_RefreshPanel()
	if not FyrMiniMap:IsHidden() then FyrMiniMap:SetHidden(true) FyrMM.LAM:OpenToPanel(FyrMM.CPL) end -- If Settings are open, have to refresh them
end

function FyrMM_CommandHandler(text)
	if text == "help" or text == "hel" then
		d(GetString(SI_MM_STRING_COMMANDHELP1))
		d("/fyrmm fpstest - "..GetString(SI_MM_STRING_COMMANDHELP2))
		d("/fyrmm help - "..GetString(SI_MM_STRING_COMMANDHELP3))
		d("/fyrmm hide - "..GetString(SI_MM_STRING_COMMANDHELP4))
		d("/fyrmm location - "..GetString(SI_MM_STRING_COMMANDHELP5))
		d("/fyrmm reset - "..GetString(SI_MM_STRING_COMMANDHELP6))
		d("/fyrmm unhide - "..GetString(SI_MM_STRING_COMMANDHELP7))
		d("/fyrmm version - "..GetString(SI_MM_STRING_COMMANDHELP8))
		d("/fyrmm debug - "..GetString(SI_MM_STRING_COMMANDHELP9))
		d("/fyrmmset - "..GetString(SI_MM_STRING_COMMANDHELP10))
	elseif text == "reset" or text == "res" then
		MM_ResetToDefaults()
		MM_RefreshPanel()
		FyrMM.Reload()
	elseif text == "fpstest" or text == "fps" then -- FPS test 
		FyrMM.FpsTest = not  FyrMM.FpsTest
	if  FyrMM.FpsTest then
		FyrMM.Fps = 0
		FyrMM.FpsRaw = 0
		d("["..GetTimeString().."] "..GetString(SI_MM_STRING_FPSRECORDING1))
		d("["..GetTimeString().."] "..GetString(SI_MM_STRING_FPSRECORDING2))
		d("["..GetTimeString().."] "..GetString(SI_MM_STRING_FPSRECORDING3))
		d("["..GetTimeString().."] "..GetString(SI_MM_STRING_FPSRECORDING4))
	else
		d("["..GetTimeString().."] "..GetString(SI_MM_STRING_FPSRECORDING5))
		d("["..GetTimeString().."] "..GetString(SI_MM_STRING_FPSRECORDING6))
		d(string.format(GetString(SI_MM_STRING_FPSRECORDING7).." = %f, "..GetString(SI_MM_STRING_FPSRECORDING8).." = %f", FyrMM.Fps, FyrMM.FpsRaw))
	end
	elseif text == "hide" or text == "hid" then
		FyrMM.Visible = false
	elseif text == "show" or text == "unhide" or text == "sho" or text == "unh" then
		FyrMM.Visible = true
	elseif text == "version" or text == "info" or text == "ver" or text == "inf" then
		d("|ceeeeeeMiniMap by |c006600Fyrakin |ceeeeee v"..FyrMM.Panel.version.."|r")
	elseif text == "loc" or text == "location" then
		local x, y, heading = GetMapPlayerPosition("player")
		d(string.format(GetString(SI_MM_STRING_COORDINATES).." x=%g, y=%g @ %s",("%05.04f"):format(zo_round(x*1000000)/10000),("%05.04f"):format(zo_round(y*1000000)/10000), Fyr_MM_Zone:GetText()))
	elseif text == "debug" or text == "deb" then
		if FyrMM.MovementSpeedMax == nil then FyrMM.MovementSpeedMax = 0 end
		d("Map: "..FyrMM.currentMap.filename..", Stored size: "..string.format("%g",("%05.04f"):format(zo_round(FyrMM.currentMap.TrueMapSize*100)/100))..", suggested size: "..string.format("%g",("%05.04f"):format(zo_round(FyrMM.currentMap.TrueMapSize*100*(9/(FyrMM.MovementSpeedMax*100)))/100)))
	  else
		d("/fyrmm help - "..GetString(SI_MM_STRING_COMMANDHELP11))
	end
end

SLASH_COMMANDS["/fyrmm"] = FyrMM_CommandHandler