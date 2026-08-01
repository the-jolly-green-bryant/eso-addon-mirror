local Addon = {}
Addon.Name = "ImprovedWorldMapInfoPanel"
Addon.DisplayName = "ImprovedWorldMapInfoPanel"
Addon.Author = "remosito"
Addon.Version = "37.0"

IWMIP.savedVars = {}


local function settingsClosed()

	GetControl("ZO_WorldMapInfo"):SetHeight(IWMIP.savedVars.height)
	GetControl("ZO_WorldMapInfoFootPrintBackground"):SetHeight(IWMIP.savedVars.height + 60)
	GetControl("ZO_WorldMapInfoFootPrintBackgroundBG"):SetHeight(IWMIP.savedVars.height + 400)
	GetControl("ZO_WorldMapInfo"):SetWidth(IWMIP.savedVars.width)
	GetControl("ZO_WorldMapInfoFootPrintBackground"):SetWidth(IWMIP.savedVars.width)
	GetControl("ZO_WorldMapInfoFootPrintBackgroundBG"):SetWidth(IWMIP.savedVars.width + 75)
	GetControl("ZO_WorldMapInfo"):SetAnchor(8, GuiRoot, 8, IWMIP.savedVars.anchorX, IWMIP.savedVars.anchorY, 0)
	GetControl("ZO_WorldMapInfoFootPrintBackground"):SetAnchor(8, GuiRoot, 8, IWMIP.savedVars.anchorX, IWMIP.savedVars.anchorY + 20, 0)
	ZO_ScrollList_UpdateDataTypeHeight(GetControl("ZO_WorldMapLocationsList"),1,IWMIP.savedVars.locrowheight)
	ZO_ScrollList_UpdateDataTypeHeight(GetControl("ZO_WorldMapHousesList"),2,IWMIP.savedVars.houserowheight)
end


local function savedVarsInitializer()

	if not IWMIP.savedVars.anchorX or not IWMIP.savedVars.anchorY then
		_,_,_,IWMIP.savedVars.anchorX,IWMIP.savedVars.anchorY,_ = GetControl("ZO_WorldMapInfo"):GetAnchor()
	end
	if not IWMIP.savedVars.height or not IWMIP.savedVars.width then
		IWMIP.savedVars.height = GetControl("ZO_WorldMapInfo"):GetHeight()
		IWMIP.savedVars.width = GetControl("ZO_WorldMapInfo"):GetWidth()
	end
	if not IWMIP.savedVars.locrowheight then
		IWMIP.savedVars.locrowheight = ZO_ScrollList_GetDataTypeTable(GetControl("ZO_WorldMapLocationsList"), 1).height
	end
	if not IWMIP.savedVars.houserowheight then
		IWMIP.savedVars.houserowheight = ZO_ScrollList_GetDataTypeTable(GetControl("ZO_WorldMapHousesList"), 2).height
	end
end


local function onPlayerActivated()

	savedVarsInitializer()
	IWMIP.CreateMenu()
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel) if panel ~= IWMIP.SettingsPanel then return end settingsClosed() end)
	settingsClosed()
	EVENT_MANAGER:UnregisterForEvent(Addon.Name, EVENT_PLAYER_ACTIVATED)
end


function IWMIP.onLoad(eventCode, name)
	
	if name ~= Addon.Name then return end
	IWMIP.savedVars = ZO_SavedVars:NewAccountWide("IWMIPVars", 1, nil, nil, GetWorldName(), nil)
	EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_PLAYER_ACTIVATED, onPlayerActivated)	
	EVENT_MANAGER:UnregisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED)
	
end


EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, IWMIP.onLoad)