ICT.ui = {
	opened = false,
	mapid = 0,
	timetable = ZO_SimpleSceneFragment:New(ICTTimeTable),
	maptimers = ZO_SimpleSceneFragment:New(ICTMapTimers),
	
	districts = {
		[GetString(SI_ICTHENEXTBOSS_MEMORIALDISTRICT)] = ICTMemorialDistrictLabel,
		[GetString(SI_ICTHENEXTBOSS_ARENADISTRICT)] = ICTArenaDistrictLabel,
		[GetString(SI_ICTHENEXTBOSS_ARBORETUMDISTRICT)] = ICTArboretumDistrictLabel,
		[GetString(SI_ICTHENEXTBOSS_TEMPLEDISTRICT)] = ICTTempleDistrictLabel,
		[GetString(SI_ICTHENEXTBOSS_NOBLESDISTRICT)] = ICTNoblesDistrictLabel,
		[GetString(SI_ICTHENEXTBOSS_ELVENGARDENSDISTRICT)] = ICTElvenGardensDistrictLabel,
	}
}

function ICT.disableMapMouseWheelZoom()
	
	local function disableZoom(self, delta, force)
		if force ~= nil then return false end
		if ICT.running == true and ICT.savedVariables.maptimers == true and ICT.ui.mapid == 660 then
			ZO_WorldMapZoom_OnMouseWheel(-1000, _, true)
			return true
		end
	end
	
	ZO_PreHook('ZO_WorldMap_MouseWheel', disableZoom)
	ZO_PreHook('ZO_WorldMapZoom_OnMouseWheel', disableZoom)
	ZO_PreHook('ZO_WorldMapZoomMinus_OnClicked', disableZoom)
	ZO_PreHook('ZO_WorldMapZoomPlus_OnClicked', disableZoom)
end

function ICT.disableMapZoomSlider(boolean)
	ZO_WorldMapZoomSliderButton1:SetEnabled(not boolean)
	ZO_WorldMapZoomSliderButton2:SetEnabled(not boolean)
	ZO_WorldMapZoomSliderButton3:SetEnabled(not boolean)
	ZO_WorldMapZoomSliderButton4:SetEnabled(not boolean)
	ZO_WorldMapZoomSliderButton5:SetEnabled(not boolean)
	ZO_WorldMapZoomSliderButton6:SetEnabled(not boolean)
	ZO_WorldMapZoomSliderButton7:SetEnabled(not boolean)
	ZO_WorldMapZoomSliderButton8:SetEnabled(not boolean)
	ZO_WorldMapZoomSliderButton9:SetEnabled(not boolean)
	ZO_WorldMapZoomSliderButton10:SetEnabled(not boolean)
	ZO_WorldMapZoomSliderButton11:SetEnabled(not boolean)
	ZO_WorldMapZoomMinus:SetEnabled(not boolean)
	ZO_WorldMapZoomPlus:SetEnabled(not boolean)
end

function ICT.onMapOpen()
	
	local function check()
		if ICT.running == true and ICT.ui.opened == true and ICT.savedVariables.maptimers == true and ICT.ui.mapid == 660 then
			ICTMapTimers:SetHidden(false)
			ICT.disableMapZoomSlider(true)
		else
			ICTMapTimers:SetHidden(true)
			ICT.disableMapZoomSlider(false)
		end
	end
	
	WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
	
		ICT.ui.mapid = GetCurrentMapId()
		
		if newState == SCENE_SHOWN or newState == SCENE_SHOWING then
			ICT.ui.opened = true
		else
			ICT.ui.opened = false
		end
		
		check()
	end)
	
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
		ICT.ui.mapid = GetCurrentMapId()
		check()
	end)
end

function ICT.onTableMove()
	ICT.savedVariables.timetableTop = ICTTimeTable:GetTop()
	ICT.savedVariables.timetableLeft = ICTTimeTable:GetLeft()
end

function ICT.restoreUIPosition()
	ICTTimeTable:ClearAnchors()
	ICTTimeTable:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ICT.savedVariables.timetableLeft, ICT.savedVariables.timetableTop)
end

function ICT.secondsToClock(sec)
	return string.format("%02d:%02d", math.floor(sec / 60), (sec % 60))
end