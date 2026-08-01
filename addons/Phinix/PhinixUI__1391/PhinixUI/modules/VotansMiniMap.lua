
function PUIAddon.VotansMiniMap()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = VotansMiniMap_Data.Default[GetDisplayName()]["$AccountWide"]

--	Collect and build data needed to support different screen resolutions.
	local guix, guiy
	local mapx, mapy
	local posx, posy
	ZO_WorldMap:ClearAnchors()
	ZO_WorldMap:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, 0, -24)
	guix, guiy = GuiRoot:GetCenter()
	mapx, mapy = ZO_WorldMap:GetCenter()
	posx, posy = mapx - guix, mapy - guiy

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	titleColor = {
		[4] = 1,
		[1] = 0.7725490928,
		[2] = 0.7607843876,
		[3] = 0.6196078658,
	}
	titleAtTop = true
	enableMap = true
	debug = false
	showCombat = true
	showMounted = true
	lockWindow = true
	enableCompass = "UNTOUCHED"
	height = 318.7714843750
	showRealTimeClock = true
	zoomIn = 2
	showHUD = true
	subZoneZoom = 0.4000000000
	showCameraAngle = false
	zoomToPlayer = false
	titleFontSize = 16
	mungeBorder = false
	borderAlpha = 0
	width = 256.7714843750
	mountedZoom = 0.6000000000
	titleFont = ""
	dungeonZoom = 0.4000000000
	showLoot = false
	allowFloorNavigation = false
	keepSquare = true
	cameraAngle = 45
	zoomOut = 0.1500000000
	unitPinScaleLimit = 0.8000000000
	showClock = false
	enableTweaks = false
	showFullTitle = false
	timeFormat = 4
	zoom = 0.4000000000
	battlegroundZoom = 0
	showViewAngle = false
	zoneAlertMode = "NEVER"
	asyncUpdate = false
	showInGameClock = true
	frameStyle = "Flat"
	showSiege = true
--	x = 1151.6142578125
--	y = -584.6142578125
	db.x = posx
	db.y = posy

end
