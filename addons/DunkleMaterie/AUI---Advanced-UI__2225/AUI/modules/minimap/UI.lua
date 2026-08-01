AUI.Minimap.UI = {}

local LMP = LibStub('LibMediaProvider-1.0')

local isLoaded = false
local lastLocName = nil

local function AUI_UI_OnMouseDown(_eventCode, _button, _ctrl, _alt, _shift)
	if _button == 1 and not AUI.Settings.Minimap.lock_window then
		AUI_Minimap_MainWindow:SetMovable(true)
		AUI_Minimap_MainWindow:StartMoving()
	end		
end

local function AUI_UI_OnMouseUp(_eventCode, _button, _ctrl, _alt, _shift)
	AUI_Minimap_MainWindow:SetMovable(false)

	if _button == 1 and not AUI.Settings.Minimap.lock_window then	
		_, AUI.Settings.Minimap.anchor.point, _, AUI.Settings.Minimap.anchor.relativePoint, AUI.Settings.Minimap.anchor.offsetX, AUI.Settings.Minimap.anchor.offsetY = AUI_Minimap_MainWindow:GetAnchor()
	end
end

local function AUI_UI_OnMouseWheel(self, delta, ctrl, alt, shift)
    if delta > 0 then
		AUI.Minimap.Map.ZoomOut()
    elseif delta < 0 then
        AUI.Minimap.Map.ZoomIn()
    end
end

local function AUI_UI_GetLocationAnchorPoints()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_UI_GetLocationAnchorPoints")
	end
	--/DebugMessage--	

	local point = TOP
	local rPoint = TOP

	if AUI.Settings.Minimap.location_Position == "bottom" then
		point = BOTTOM
		rPoint = BOTTOM
	elseif AUI.Settings.Minimap.location_Position == "top" then
		point = TOP	
		rPoint = TOP		
	end	
		
	return point, rPoint
end

local function AUI_UI_GetCoordsAnchorPoints()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_UI_GetCoordsAnchorPoints")
	end
	--/DebugMessage--

	local point = TOP
	local rPoint = TOP

	if AUI.Settings.Minimap.coords_Position == "bottom" then
		point = BOTTOM
		rPoint = BOTTOM
	elseif AUI.Settings.Minimap.coords_Position== "top" then
		point = TOP	
		rPoint = TOP		
	end	
		
	return point, rPoint
end

local function AUI_UI_GetMapContainerPosition()	
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_UI_GetMapContainerPosition")
	end
	--/DebugMessage--

	local paddingX = 0
	local paddingY = 0

	if AUI.Settings.Minimap.preview_locationName then
		if AUI.Settings.Minimap.location_Position == "top" then
			paddingY = AUI.Settings.Minimap.location_FontSize + 5
		end
	end
	
	if AUI.Settings.Minimap.preview_coords then
		if AUI.Settings.Minimap.location_Position == "top" and AUI.Settings.Minimap.coords_Position == "top" then
			paddingY = paddingY + AUI.Settings.Minimap.coords_FontSize + 5
		elseif AUI.Settings.Minimap.coords_Position == "top" then
			paddingY = AUI.Settings.Minimap.coords_FontSize + 5
		end
	end	
		
	return paddingX, paddingY
end

local function AUI_UI_GetRootContainerSize()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_UI_GetRootContainerSize")
	end
	--/DebugMessage--
	
	local width = AUI.Settings.Minimap.width
	local height = AUI.Settings.Minimap.height

	if AUI.Settings.Minimap.preview_locationName then
		height = (height + AUI.Settings.Minimap.location_FontSize) + 5
	end

	if AUI.Settings.Minimap.preview_coords then
		height = (height + AUI.Settings.Minimap.coords_FontSize) + 5	
	end
		
	return width, height
end

local function AUI_UI_SetMiniMapSize()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_UI_SetMiniMapSize")
	end
	--/DebugMessage--

	local rootWidth, rootHeight = AUI_UI_GetRootContainerSize()

	local mapWidth = AUI.Settings.Minimap.width
	
	if AUI.MapData.heightAsWidth then
		AUI.Settings.Minimap.height = AUI.Settings.Minimap.width	
	end
	
	local mapHeight = AUI.Settings.Minimap.height
	
	AUI_Minimap_MainWindow:SetDimensions(rootWidth, rootHeight)	
	AUI_Minimap_MainWindow_Map:SetDimensions(mapWidth, mapHeight)	
end

local function AUI_UI_SetMiniMapPosition(point, rPoint, x, y)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_UI_SetMiniMapPosition")
	end
	--/DebugMessage--

	AUI_Minimap_MainWindow:ClearAnchors()
    AUI_Minimap_MainWindow:SetAnchor(point, nil, rPoint, x, y)

	local point, rPoint = AUI_UI_GetCoordsAnchorPoints()
	
	AUI_Coords:ClearAnchors()
	AUI_Coords:SetAnchor(point, AUI_Minimap_MainWindow, rPoint, 0, 0)	
	
	local point, rPoint = AUI_UI_GetLocationAnchorPoints()
		
	local locationNamePosY =  0
		
	if AUI.Settings.Minimap.preview_locationName and AUI.Settings.Minimap.preview_coords then
		if AUI.Settings.Minimap.location_Position == "top" and AUI.Settings.Minimap.coords_Position == "top" then
			locationNamePosY = AUI.Settings.Minimap.coords_FontSize + 5
		elseif AUI.Settings.Minimap.location_Position == "bottom" and AUI.Settings.Minimap.coords_Position == "bottom" then
			locationNamePosY = -AUI.Settings.Minimap.coords_FontSize - 5
		end
	end
	
	AUI_Location_Name:ClearAnchors()
	AUI_Location_Name:SetAnchor(point, AUI_Minimap_MainWindow, rPoint, 0, locationNamePosY)		
	
	local mapX, mapY =  AUI_UI_GetMapContainerPosition()
	
	AUI_Minimap_MainWindow_Map:ClearAnchors()
	AUI_Minimap_MainWindow_Map:SetAnchor(TOPLEFT, AUI_Minimap_MainWindow, TOPLEFT, mapX, mapY)
end

local function AUI_UI_CreateTheme()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_UI_CreateTheme")
	end
	--/DebugMessage--

	local theme = AUI.Minimap.Theme.GetCurrentMiniMapTheme()
	
	if theme ~= nil then
		local showDefaultFrame = theme["Default_Frame"]
	
		if showDefaultFrame then
			AUI_Minimap_MainWindow_MapFrame:SetHidden(false)
		else
			AUI_Minimap_MainWindow_MapFrame:SetHidden(true)
		end
	
		local overlayTexture = theme["Overlay_Texture"]
	
		if overlayTexture ~= nil and not AUI.String.IsEmpty(overlayTexture) then
			AUI_Minimap_MainWindow_Map_Overlay:SetTexture(overlayTexture)
			AUI_Minimap_MainWindow_Map_Overlay:SetHidden(false)
		else
			AUI_Minimap_MainWindow_Map_Overlay:SetHidden(true)
		end
		
		local backgroundTexture = theme["Background_Texture"]
		
		if backgroundTexture ~= nil and not AUI.String.IsEmpty(backgroundTexture) then
			AUI_Minimap_MainWindow_Map_Background:SetTexture(backgroundTexture)
		end	
		
		local rotateTexture = theme["Rotate_Texture"]
		
		if rotateTexture ~= nil and not AUI.String.IsEmpty(rotateTexture) then
			AUI_Minimap_MainWindow_Map_Rotate:SetTexture(rotateTexture)
			AUI_Minimap_MainWindow_Map_Rotate:SetHidden(false)
		else
			AUI_Minimap_MainWindow_Map_Rotate:SetHidden(true)
		end		

		local forcePlayerCenter = theme["Fixed_Player"]
		
		if forcePlayerCenter ~= nil and forcePlayerCenter then
			AUI.MapData.forcePlayerCenter = true
		else
			AUI.MapData.forcePlayerCenter = false
		end	
		
		local heightAsWidth = theme["Fixed_Size"]
		
		if heightAsWidth ~= nil and heightAsWidth then
			AUI.MapData.heightAsWidth = true
		else
			AUI.MapData.heightAsWidth = false
		end			
	end
end

local function AUI_UI_Create()
	AUI_Minimap_MainWindow:SetHandler("OnMouseDown", AUI_UI_OnMouseDown)
	AUI_Minimap_MainWindow:SetHandler("OnMouseUp", AUI_UI_OnMouseUp)
	AUI_Minimap_MainWindow:SetHandler("OnMouseWheel", AUI_UI_OnMouseWheel) 
end

function AUI.Minimap.UI.UpdateCoords()
	if not isLoaded or not AUI.Minimap.IsLoaded() then
		return
	end

	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Minimap.UI.UpdateCoords")
	end
	--/DebugMessage--	
	
	local x, y = GetMapPlayerPosition("player")

	if x ~= lastPlayerX or y ~= lastPlayerY then
		x = AUI.Math.Round(x * 10000) / 100
		y = AUI.Math.Round(y * 10000) / 100

		AUI_Coords:SetText("X: " .. x .. "   Y: " .. y)	
	
		lastPlayerX = x
		lastPlayerY = y
	end
end

function AUI.Minimap.UI.UpdateLocationName()
	if not isLoaded or not AUI.Minimap.IsLoaded() then
		return
	end
	
	local locName = GetPlayerLocationName() 

	if locName ~= lastLocName then
		--DebugMessage--
		if AUI_DEBUG then
			AUI.DebugMessage("AUI.Minimap.UI.UpdateLocationName")
		end
		--/DebugMessage--		
	
		if not AUI.String.IsEmpty(locName) then
			local str = AUI.String.FirstToUpper(AUI.String.FormatName(locName))
			AUI_Location_Name:SetText(str)
		end 
		lastLocName = locName
	end
end

function AUI.Minimap.UI.Update()
	if not isLoaded or not AUI.Minimap.IsLoaded() then
		return
	end
	
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Minimap.UI.Update")
	end
	--/DebugMessage--		

	AUI_UI_SetMiniMapSize()
	AUI_UI_SetMiniMapPosition(AUI.Settings.Minimap.anchor.point, AUI.Settings.Minimap.anchor.relativePoint, AUI.Settings.Minimap.anchor.offsetX, AUI.Settings.Minimap.anchor.offsetY)
		
	AUI_Location_Name:SetFont(LMP:Fetch('font', AUI.Settings.Minimap.location_FontArt) .. "|" .. AUI.Settings.Minimap.location_FontSize .. "|" .. AUI.Settings.Minimap.location_FontStyle)	
	AUI_Location_Name:SetHidden(not AUI.Settings.Minimap.preview_locationName)
	AUI_Location_Name:SetColor(AUI.Settings.Minimap.location_FontColor.r, AUI.Settings.Minimap.location_FontColor.g, AUI.Settings.Minimap.location_FontColor.b, AUI.Settings.Minimap.location_FontColor.a)		
		
	AUI_Coords:SetFont(LMP:Fetch('font', AUI.Settings.Minimap.coords_FontArt) .. "|" .. AUI.Settings.Minimap.coords_FontSize .. "|" .. AUI.Settings.Minimap.coords_FontStyle)	
	AUI_Coords:SetHidden(not AUI.Settings.Minimap.preview_coords)
	AUI_Coords:SetColor(AUI.Settings.Minimap.coords_FontColor.r, AUI.Settings.Minimap.coords_FontColor.g, AUI.Settings.Minimap.coords_FontColor.b, AUI.Settings.Minimap.coords_FontColor.a)		
	
	local mapAlpha = 1
	if AUI.Settings.Minimap.opacity then
		mapAlpha = AUI.Settings.Minimap.opacity
	end
	
	AUI_Minimap_MainWindow:SetAlpha(mapAlpha)
	
	AUI_UI_CreateTheme()	
end

function AUI.Minimap.UI.Init()
	if isLoaded then
		return
	end

	isLoaded = true
	
	AUI_UI_Create()
	AUI_UI_CreateTheme()
end

