DsRGuildPvPBossTimer = DsRGuildPvPBossTimer or {
	name 	  		= "DsRGuildPvPBossTimer",
	running 		= false,
	spawntime 		= 900, --Respawn after 15 minutes
	spawntimeMolag 	= 300, --Respawn after 5 minutes
	fallbackMaxTime = 60,
}

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Data
-------------------------------------------------------------------------------------------------------------------------------------------------
DsRGuildPvPBossTimer.locations = {
	[GetString(DsRPvPBossTimer_AMONCRUL)] 		= GetString(DsRPvPBossTimer_NOBLESDISTRICT),
	[GetString(DsRPvPBossTimer_THIRSK)] 		= GetString(DsRPvPBossTimer_NOBLESDISTRICT),
	[GetString(DsRPvPBossTimer_GLORGOLOCH)]		= GetString(DsRPvPBossTimer_ARENADISTRICT),
	[GetString(DsRPvPBossTimer_CHARR)] 			= GetString(DsRPvPBossTimer_TEMPLEDISTRICT),
	[GetString(DsRPvPBossTimer_KHROGO)] 		= GetString(DsRPvPBossTimer_ARENADISTRICT),
	[GetString(DsRPvPBossTimer_MALYGDA)] 		= GetString(DsRPvPBossTimer_ARBORETUMDISTRICT),
	[GetString(DsRPvPBossTimer_MAZALUHAD)] 		= GetString(DsRPvPBossTimer_TEMPLEDISTRICT),
	[GetString(DsRPvPBossTimer_NUNATAK)] 		= GetString(DsRPvPBossTimer_MEMORIALDISTRICT),
	[GetString(DsRPvPBossTimer_MATRON)] 		= GetString(DsRPvPBossTimer_ELVENGARDENSDISTRICT),
	[GetString(DsRPvPBossTimer_VOLGHASS)] 		= GetString(DsRPvPBossTimer_MEMORIALDISTRICT),
	[GetString(DsRPvPBossTimer_YSENDA)] 		= GetString(DsRPvPBossTimer_ARBORETUMDISTRICT),
	[GetString(DsRPvPBossTimer_ZOAL)] 			= GetString(DsRPvPBossTimer_ELVENGARDENSDISTRICT),
	[GetString(DsRPvPBossTimer_MOLAG)] 			= GetString(DsRPvPBossTimer_CAN),
}

DsRGuildPvPBossTimer.timetable = {
	[GetString(DsRPvPBossTimer_NOBLESDISTRICT)] 		= 0,
	[GetString(DsRPvPBossTimer_ARENADISTRICT)] 			= 0,
	[GetString(DsRPvPBossTimer_TEMPLEDISTRICT)] 		= 0,
	[GetString(DsRPvPBossTimer_ARBORETUMDISTRICT)] 		= 0,
	[GetString(DsRPvPBossTimer_MEMORIALDISTRICT)] 		= 0,
	[GetString(DsRPvPBossTimer_ELVENGARDENSDISTRICT)]	= 0,
	[GetString(DsRPvPBossTimer_CAN)] 					= 0,
}

DsRGuildPvPBossTimer.datas = {
	[0]  = DsRPvPBossTimer_CAN,
	[1]  = DsRPvPBossTimer_MEMORIALDISTRICT,
	[2]  = DsRPvPBossTimer_ARENADISTRICT,
	[3]  = DsRPvPBossTimer_ARBORETUMDISTRICT,
	[4]  = DsRPvPBossTimer_TEMPLEDISTRICT,
	[5]  = DsRPvPBossTimer_NOBLESDISTRICT,
	[6]  = DsRPvPBossTimer_ELVENGARDENSDISTRICT,
	[7]  = DsRPvPBossTimer_MEMORIALDISTRICT,
	[8]  = DsRPvPBossTimer_ARENADISTRICT,
	[9]  = DsRPvPBossTimer_ARBORETUMDISTRICT,
	[10] = DsRPvPBossTimer_TEMPLEDISTRICT,
	[11] = DsRPvPBossTimer_NOBLESDISTRICT,
	[12] = DsRPvPBossTimer_ELVENGARDENSDISTRICT,
	[13] = DsRPvPBossTimer_MEMORIALDISTRICT,
	[14] = DsRPvPBossTimer_ARENADISTRICT,
	[15] = DsRPvPBossTimer_ARBORETUMDISTRICT,
	[16] = DsRPvPBossTimer_TEMPLEDISTRICT,
	[17] = DsRPvPBossTimer_NOBLESDISTRICT,
	[18] = DsRPvPBossTimer_ELVENGARDENSDISTRICT,
}

DsRGuildPvPBossTimer.nextcw = {
	[0] = 0,
	[1] = 2,
	[2] = 3,
	[3] = 4,
	[4] = 5,
	[5] = 6,
	[6] = 1
}

DsRGuildPvPBossTimer.fallbackTimes = {
	[GetString(DsRPvPBossTimer_AMONCRUL)] 	 = 0,
	[GetString(DsRPvPBossTimer_THIRSK)] 	 = 0,
	[GetString(DsRPvPBossTimer_GLORGOLOCH)]  = 0,
	[GetString(DsRPvPBossTimer_CHARR)] 	 	 = 0,
	[GetString(DsRPvPBossTimer_KHROGO)] 	 = 0,
	[GetString(DsRPvPBossTimer_MALYGDA)] 	 = 0,
	[GetString(DsRPvPBossTimer_MAZALUHAD)]   = 0,
	[GetString(DsRPvPBossTimer_NUNATAK)] 	 = 0,
	[GetString(DsRPvPBossTimer_MATRON)] 	 = 0,
	[GetString(DsRPvPBossTimer_VOLGHASS)] 	 = 0,
	[GetString(DsRPvPBossTimer_YSENDA)] 	 = 0,
	[GetString(DsRPvPBossTimer_ZOAL)] 		 = 0,
	[GetString(DsRPvPBossTimer_MOLAG)] 	 	 = 0,
}

DsRGuildPvPBossTimer.districtIds = {
	[1]  = 142,		-- Gedenk
	[2]  = 146,		-- Arena
	[3]  = 143,		-- Aboretum
	[4]  = 147,		-- Tempel
	[5]  = 141,		-- Adels
	[6]  = 148,		-- Elfengarten
	[7]  = 142, 	-- Gedenk
	[8]  = 146, 	-- Arena
	[9]  = 143, 	-- Aboretum
	[10] = 147, 	-- Tempel
	[11] = 141, 	-- Adels
	[12] = 148, 	-- Elfengarten
	[13] = 142, 	-- Gedenk
	[14] = 146, 	-- Arena
	[15] = 143, 	-- Aboretum
	[16] = 147, 	-- Tempel
	[17] = 141, 	-- Adels
	[18] = 148, 	-- Elfengarten
}

-------------------------------------------------------------------------------------------------------------------------------------------------
-- GUI
-------------------------------------------------------------------------------------------------------------------------------------------------
DsRGuildPvPBossTimer.ui = {
	opened = false,
	mapid = 0,
	timetable = ZO_SimpleSceneFragment:New(DsRGuildPvPBossTimerTimeTable),
	maptimers = ZO_SimpleSceneFragment:New(DsRGuildPvPBossTimerMapTimers),
	
	districts = {
		[GetString(DsRPvPBossTimer_MEMORIALDISTRICT)] 	  = DsRGuildPvPBossTimerMemorialDistrictLabel,
		[GetString(DsRPvPBossTimer_ARENADISTRICT)] 		  = DsRGuildPvPBossTimerArenaDistrictLabel,
		[GetString(DsRPvPBossTimer_ARBORETUMDISTRICT)] 	  = DsRGuildPvPBossTimerArboretumDistrictLabel,
		[GetString(DsRPvPBossTimer_TEMPLEDISTRICT)] 	  = DsRGuildPvPBossTimerTempleDistrictLabel,
		[GetString(DsRPvPBossTimer_NOBLESDISTRICT)] 	  = DsRGuildPvPBossTimerNoblesDistrictLabel,
		[GetString(DsRPvPBossTimer_ELVENGARDENSDISTRICT)] = DsRGuildPvPBossTimerElvenGardensDistrictLabel,
		[GetString(DsRPvPBossTimer_CAN)]				  = DsRGuildPvPBossTimerCanLabel,
	}
}

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.disableMapMouseWheelZoom()
	
	local function disableZoom(self, delta, force)
		if force ~= nil then return false end
		if DsRGuildPvPBossTimer.running == true and DsRGuildPvP.pvp.PvPmaptimers == true and DsRGuildPvPBossTimer.ui.mapid == 660 then
			ZO_WorldMapZoom_OnMouseWheel(-1000, _, true)
			return true
		end
	end
	
	ZO_PreHook('ZO_WorldMap_MouseWheel', disableZoom)
	ZO_PreHook('ZO_WorldMapZoom_OnMouseWheel', disableZoom)
	ZO_PreHook('ZO_WorldMapZoomMinus_OnClicked', disableZoom)
	ZO_PreHook('ZO_WorldMapZoomPlus_OnClicked', disableZoom)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.disableMapZoomSlider(boolean)
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

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.onMapOpen()
	
	local function check()
		if DsRGuildPvPBossTimer.running == true and DsRGuildPvPBossTimer.ui.opened == true and DsRGuildPvP.pvp.PvPmaptimers == true and DsRGuildPvPBossTimer.ui.mapid == 660 then
			DsRGuildPvPBossTimerMapTimers:SetHidden(false)
			DsRGuildPvPBossTimer.disableMapZoomSlider(true)

			if PerfectPixel then
				DsRGuildPvPBossTimerMemorialDistrictLabel:SetAnchor(CENTER, DsRGuildPvPBossTimerMapTimers, CENTER, 70 , -100) -- 75 ,20
				DsRGuildPvPBossTimerArenaDistrictLabel:SetAnchor(CENTER, DsRGuildPvPBossTimerMapTimers, CENTER, 160 , -50)
				DsRGuildPvPBossTimerArboretumDistrictLabel:SetAnchor(CENTER, DsRGuildPvPBossTimerMapTimers, CENTER, 160 , 80)
				DsRGuildPvPBossTimerTempleDistrictLabel:SetAnchor(CENTER, DsRGuildPvPBossTimerMapTimers, CENTER, 70 , 125)
				DsRGuildPvPBossTimerNoblesDistrictLabel:SetAnchor(CENTER, DsRGuildPvPBossTimerMapTimers, CENTER, -25 , 80)
				DsRGuildPvPBossTimerElvenGardensDistrictLabel:SetAnchor(CENTER, DsRGuildPvPBossTimerMapTimers, CENTER, -25 , -50)
				DsRGuildPvPBossTimerCanLabel:SetAnchor(CENTER, DsRGuildPvPBossTimerMapTimers, CENTER, 70 , 15)
			end
		else
			DsRGuildPvPBossTimerMapTimers:SetHidden(true)
			DsRGuildPvPBossTimer.disableMapZoomSlider(false)
		end
	end
	
	WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
	
		DsRGuildPvPBossTimer.ui.mapid = GetCurrentMapId()
		
		if newState == SCENE_SHOWN or newState == SCENE_SHOWING then
			DsRGuildPvPBossTimer.ui.opened = true
		else
			DsRGuildPvPBossTimer.ui.opened = false
		end
		
		check()
	end)
	
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
		DsRGuildPvPBossTimer.ui.mapid = GetCurrentMapId()
		check()
	end)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.onTableMove()
	DsRGuildPvP.pvp.PvPtimetableTop = DsRGuildPvPBossTimerTimeTable:GetTop()
	DsRGuildPvP.pvp.PvPtimetableLeft = DsRGuildPvPBossTimerTimeTable:GetLeft()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.restoreUIPosition()
	DsRGuildPvPBossTimerTimeTable:ClearAnchors()
	DsRGuildPvPBossTimerTimeTable:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, DsRGuildPvP.pvp.PvPtimetableLeft, DsRGuildPvP.pvp.PvPtimetableTop)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.secondsToClock(sec)
	return string.format("%02d:%02d", math.floor(sec / 60), (sec % 60))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.updateTimers()
	local controlFont = DsRGuildfonts.CreateFontString(DsRGuildfonts.constants.CHAT_FONT, DsRGuildfonts.constants.INPUT_KB, 18, DsRGuildfonts.constants.WEIGHT_SOFT_SHADOW_THICK)

	for boss, lastSeen in pairs(DsRGuildPvPBossTimer.fallbackTimes) do
		if DsRGuildPvPBossTimer.fallbackTimes[boss] > 0 then
			DsRGuildPvPBossTimer.fallbackTimes[boss] = lastSeen - 1
		end
	end

	local MolagBalIcon	    = zo_iconFormat("/esoui/art/icons/pet_molagbalimp.dds", 30, 30)
	local districtUAicon    = zo_iconFormat("/esoui/art/mappins/ava_attackburst_64.dds", 34, 34)
	local districtIcon      = ""
	local DistricName       = ""
	local DistrictUA        = ""
	local TimerNumber       = ""
	local TimerRemaining    = ""
	local color 		    = ""

	local highestIndex = 6
	local highestValue = 0

	-- MOLAG BAL
	for i = 1,6,1 
	do 
		local district  = GetString(DsRGuildPvPBossTimer.datas[i])
		local respawn   = DsRGuildPvPBossTimer.timetable[district]
		local remaining = respawn - os.time()
	
		if remaining > highestValue then
			highestIndex = i
			highestValue = remaining
		end
	end
	
	local districtMolag  = GetString(DsRGuildPvPBossTimer.datas[0])
	local respawnMolag   = DsRGuildPvPBossTimer.timetable[districtMolag]
	local remainingMolag = respawnMolag - os.time()
	
	if remainingMolag > 0 then
		color = "|cf25757"
	else
		color    	   = "|cffffff"
		remainingMolag = 0
	end

	DistrictUA     = DistrictUA .. MolagBalIcon .. "\n"
	districtIcon   = districtIcon .. MolagBalIcon .."\n"
	DistricName    = DistricName .. districtMolag .. "\n"
	TimerRemaining = TimerRemaining .. color .. DsRGuildPvPBossTimer.secondsToClock(remainingMolag) .. "|r\n"
	
	if DsRGuildPvP.pvp.PvPmaptimers == true then
		DsRGuildPvPBossTimer.ui.districts[districtMolag]:SetText(color .. DsRGuildPvPBossTimer.secondsToClock(remainingMolag))
	end

	-- DISTRICT's
	local modifier = 1
	local endpoint = 5
	local nextdistrict = DsRGuildPvPBossTimer.nextcw[highestIndex]
	
	for i = nextdistrict+6,nextdistrict+6+endpoint,modifier 
	do 
		local district  = GetString(DsRGuildPvPBossTimer.datas[i])
		local respawn   = DsRGuildPvPBossTimer.timetable[district]
		local remaining = respawn - os.time()
	
		local alliance      = GetKeepAlliance(DsRGuildPvPBossTimer.districtIds[i], BGQUERY_LOCAL)
		local allianceColor = GetAllianceColor(alliance):GetBright()
	
		local allianceIcon    = string.format("|c%s|t34:34:/esoui/art/mappins/ava_imperialdistrict_neutral.dds:inheritcolor|t|r", GetAllianceColor(alliance):ToHex())

		local underAttack =	GetKeepUnderAttack(DsRGuildPvPBossTimer.districtIds[i],  BGQUERY_LOCAL)
		if underAttack then
			DistrictUA = DistrictUA .. districtUAicon .. "\n"
		else
			DistrictUA = DistrictUA .. allianceIcon .. "\n"
		end

		if remaining > 0 then
			color = "|cf25757"
		else
			color     = "|cffffff"
			remaining = 0
		end

		local ActDistrictName = GetPlayerActiveSubzoneName():gsub("%^.+", "")

		if ActDistrictName == zo_strsub(district, 5, 100) then
			districtColor = allianceColor:Colorize(district) .. " " .. "|c35fc38|t26:26:/esoui/art/dye/dyes_tabicon_player_disabled.dds:inheritcolor|t|r"
		else
			districtColor = allianceColor:Colorize(district)
		end

		districtIcon    = districtIcon .. allianceIcon .."\n"
		DistricName     = DistricName .. districtColor .. "\n"
		TimerRemaining  = TimerRemaining .. color .. DsRGuildPvPBossTimer.secondsToClock(remaining) .. "|r\n"
		
		if DsRGuildPvP.pvp.PvPmaptimers == true then
			DsRGuildPvPBossTimer.ui.districts[district]:SetText(color .. DsRGuildPvPBossTimer.secondsToClock(remaining))
		end

		DsRGuildPvPBossTimer.saveTimers()
	end

	-- Population
	local IconAD  = zo_iconFormat("/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds", 36, 40)    
	local IconEP  = zo_iconFormat("/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds", 36, 40)  
	local IconDC  = zo_iconFormat("/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds", 36, 40) 

	local ColorAD = GetAllianceColor(1):GetBright() -- 1 = Aldmeri
	local ColorEP = GetAllianceColor(2):GetBright() -- 2 = Ebenerz
	local ColorDC = GetAllianceColor(3):GetBright() -- 3 = Dolchsturz

	-- local campaignID = GetAssignedCampaignId()
	local campaignID = GetCurrentCampaignId()

	for campaignIndex = 1, GetNumSelectionCampaigns() do 
		if campaignID == GetSelectionCampaignId(campaignIndex) then 
			campaignIDX = campaignIndex
		end
	end

	DsRGuildPvPBossTimer.ad_pop = GetSelectionCampaignPopulationData(campaignIDX, ALLIANCE_ALDMERI_DOMINION)
    DsRGuildPvPBossTimer.dc_pop = GetSelectionCampaignPopulationData(campaignIDX, ALLIANCE_DAGGERFALL_COVENANT)
    DsRGuildPvPBossTimer.ep_pop = GetSelectionCampaignPopulationData(campaignIDX, ALLIANCE_EBONHEART_PACT)

	local ADpopulate = ColorAD:Colorize(zo_iconFormatInheritColor(ZO_CampaignBrowser_GetPopulationIcon(DsRGuildPvPBossTimer.ad_pop), 26, 26))
	local DCpopulate = ColorDC:Colorize(zo_iconFormatInheritColor(ZO_CampaignBrowser_GetPopulationIcon(DsRGuildPvPBossTimer.dc_pop), 26, 26))
	local EPpopulate = ColorEP:Colorize(zo_iconFormatInheritColor(ZO_CampaignBrowser_GetPopulationIcon(DsRGuildPvPBossTimer.ep_pop), 26, 26))

	local ValStrAD = zo_strformat("<<1>><<2>>", IconAD, ADpopulate)
	local ValStrEP = zo_strformat("<<1>><<2>>", IconEP, EPpopulate)
	local ValStrDC = zo_strformat("<<1>><<2>>", IconDC, DCpopulate)

	-- Fill List and Population
	if DsRGuildPvP.pvp.PvPtimetable == true then
		DsRGuildPvPBossTimerStatAD:SetFont(controlFont)
		DsRGuildPvPBossTimerStatAD:SetText(ValStrAD)
		DsRGuildPvPBossTimerStatEP:SetFont(controlFont)
		DsRGuildPvPBossTimerStatEP:SetText(ValStrEP)
		DsRGuildPvPBossTimerStatDC:SetFont(controlFont)
		DsRGuildPvPBossTimerStatDC:SetText(ValStrDC)
		DsRGuildPvPBossTimerDistricIcon:SetFont(controlFont)
		DsRGuildPvPBossTimerDistricIcon:SetText(districtIcon)
		DsRGuildPvPBossTimerDistricIcon:SetDrawLayer(1)
		DsRGuildPvPBossTimerDistricUAIcon:SetFont(controlFont)
		DsRGuildPvPBossTimerDistricUAIcon:SetText(DistrictUA)
		DsRGuildPvPBossTimerDistricUAIcon:SetDrawLayer(0)
		DsRGuildPvPBossTimerDistricName:SetFont(controlFont)
		DsRGuildPvPBossTimerDistricName:SetText(DistricName)
		DsRGuildPvPBossTimerTimerRemaining:SetFont(controlFont)
		DsRGuildPvPBossTimerTimerRemaining:SetText(TimerRemaining)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.onMonsterDeath(_, unitTag, isDead)
	local mobName = GetUnitName(unitTag)
	if isDead == true then
		DsRGuildPvPBossTimer.unitDead(unitName)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.onMonsterReticle(_)
	local unitName = GetUnitNameHighlightedByReticle()
	local isDead = IsUnitDead('reticleover')
	if unitName == nil or unitName == "" then return end
	
	if DsRGuildPvPBossTimer.fallbackTimes[unitName] == nil or (DsRGuildPvPBossTimer.timetable[DsRGuildPvPBossTimer.locations[unitName]] - os.time()) > 0 then return end
	
	if isDead == true then
		if DsRGuildPvPBossTimer.fallbackTimes[unitName] > 0 then
			DsRGuildPvPBossTimer.unitDead(unitName)
		end
	else
		DsRGuildPvPBossTimer.fallbackTimes[unitName] = DsRGuildPvPBossTimer.fallbackMaxTime
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.unitDead(unitName)
	if DsRGuildPvPBossTimer.locations[unitName] ~= nil then
		local district = DsRGuildPvPBossTimer.locations[unitName]
		if unitName == GetString(DsRPvPBossTimer_MOLAG) then 
			DsRGuildPvPBossTimer.startTimer(district, DsRGuildPvPBossTimer.spawntimeMolag, true)
		else
			DsRGuildPvPBossTimer.startTimer(district, DsRGuildPvPBossTimer.spawntime, true)
		end
		DsRGuildPvPBossTimer.fallbackTimes[unitName] = 0
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.saveTimers()
	for i = 0,6,1 
	do 
		local district = GetString(DsRGuildPvPBossTimer.datas[i])
		local respawn = DsRGuildPvPBossTimer.timetable[district]
		DsRGuildPvP.pvp.PvPsaved_timers[district] = respawn
		DsRGuildPvP.pvp.PvPsaved_timers["data"] = GetCurrentCampaignId()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.restoreTimers()
	if DsRGuildPvP.pvp.PvPsaved_timers["data"] == GetCurrentCampaignId() then
		for i = 0,6,1 
		do 
			local district = GetString(DsRGuildPvPBossTimer.datas[i])
			local respawn = DsRGuildPvP.pvp.PvPsaved_timers[district]
			if respawn then
				if respawn > os.time() then
					DsRGuildPvPBossTimer.timetable[district] = respawn
				end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.resetTimers()
	if DsRGuildPvP.pvp.PvPsaved_timers["data"] ~= GetCurrentCampaignId() then
		for i = 0,6,1 
		do 
			local district = GetString(DsRGuildPvPBossTimer.datas[i])
			DsRGuildPvPBossTimer.timetable[district] = 0
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.markDistrict(districtId)
	local district = DsRGuildPvPBossTimer.datas[districtId]
	if district == nil then return end
	DsRGuildPvPBossTimer.markDead(district)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.getDistrictID(district)
	local districtId = 0
	for index = 0,6,1 do 
		local districtString = DsRGuildPvPBossTimer.datas[index]
		if district == GetString(districtString) then 
			districtId = index
		end
	end
	return districtId
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.markDead(districtString)
	local district = GetString(districtString)
	-- d(district)
	if DsRGuildPvPBossTimer.timetable[district] ~= nil then
		if districtString == DsRPvPBossTimer_CAN then 
			DsRGuildPvPBossTimer.startTimer(district, DsRGuildPvPBossTimer.spawntimeMolag, false)
		else
			DsRGuildPvPBossTimer.startTimer(district, DsRGuildPvPBossTimer.spawntime, false)
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.startTimer(district, spawntime, share)
	DsRGuildPvPBossTimer.timetable[district] = os.time() + spawntime
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.onZoneChange(_, _)
	local zone, x, y, z = GetUnitWorldPosition("player")
	DsRGuildPvPBossTimer.resetTimers()

	if zone == 584 or zone == 643 then
		if DsRGuildPvPBossTimer.running == false then
			-- Player joined IC
			DsRGuildPvPBossTimer.enable()
		else
			-- Player is still in IC
			-- Show Timetable again for some reason
			DsRGuildPvPBossTimer.showTimetable()
		end
	else
		DsRGuildPvPBossTimer.disable()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.editSpawnTime()
	if DsRGuildPvP.pvp.PvPeventtimers == true then
		DsRGuildPvPBossTimer.spawntime = 420
	else
		DsRGuildPvPBossTimer.spawntime = 900
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.enable()
	EVENT_MANAGER:RegisterForEvent(DsRGuildPvPBossTimer.name, EVENT_UNIT_DEATH_STATE_CHANGED, DsRGuildPvPBossTimer.onMonsterDeath)
	EVENT_MANAGER:RegisterForEvent(DsRGuildPvPBossTimer.name, EVENT_RETICLE_TARGET_CHANGED, DsRGuildPvPBossTimer.onMonsterReticle)
	EVENT_MANAGER:RegisterForUpdate(DsRGuildPvPBossTimer.name .. "_loop", 1000, DsRGuildPvPBossTimer.updateTimers)
	DsRGuildPvPBossTimerTimeTable:SetWidth(tonumber(GetString(DsRPvPBossTimer_GUI_WIDTH)))
	DsRGuildPvPBossTimer.showTimetable()
	DsRGuildPvPBossTimer.restoreTimers()
	DsRGuildPvPBossTimer.running = true
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.disable()
	local zone, x, y, z = GetUnitWorldPosition("player")
	if zone ~= 181 then	EVENT_MANAGER:UnregisterForUpdate(DsRGuildPvPBossTimer.name .. "_loop") end -- Cyrodiil escape ;D
	EVENT_MANAGER:UnregisterForEvent(DsRGuildPvPBossTimer.name, EVENT_UNIT_DEATH_STATE_CHANGED)
	EVENT_MANAGER:UnregisterForEvent(DsRGuildPvPBossTimer.name, EVENT_RETICLE_TARGET_CHANGED)
	DsRGuildPvPBossTimerTimeTable:SetHidden(true)
	HUD_SCENE:RemoveFragment(DsRGuildPvPBossTimer.ui.timetable)
	HUD_UI_SCENE:RemoveFragment(DsRGuildPvPBossTimer.ui.timetable)
	DsRGuildPvPBossTimer.running = false
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.showTimetable()
	if DsRGuildPvP.pvp.PvPtimetable == true then
		HUD_SCENE:AddFragment(DsRGuildPvPBossTimer.ui.timetable)
		HUD_UI_SCENE:AddFragment(DsRGuildPvPBossTimer.ui.timetable)
		DsRGuildPvPBossTimerTimeTable:SetHidden(false)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPBossTimer.OnAddOnLoaded(event, addonName)
	EVENT_MANAGER:RegisterForEvent(DsRGuildPvPBossTimer.name, EVENT_PLAYER_ACTIVATED, DsRGuildPvPBossTimer.onZoneChange)
	
	DsRGuildPvPBossTimer.restoreUIPosition()
	DsRGuildPvPBossTimer.onMapOpen()
	DsRGuildPvPBossTimer.disableMapMouseWheelZoom()
	DsRGuildPvPBossTimerMapTimers:SetDrawTier(DT_HIGH) --Draw above WorldMap
	
	DsRGuildPvPBossTimer.editSpawnTime()
	
	DsRGuildPvPBossTimer.running = false
end
