ICT = ICT or {}
ICT.name = "ICTheNextBoss"
ICT.version = "1.2.4"

ICT.running = false
ICT.spawntime = 900 --Respawn after 15 minutes
ICT.fallbackMaxTime = 60

function ICT.updateTimers()

	for boss, lastSeen in pairs(ICT.fallbackTimes) do
		if ICT.fallbackTimes[boss] > 0 then
			ICT.fallbackTimes[boss] = lastSeen - 1
		end
	end

	local districtString = ""
	local timerString = ""
	local color = ""

	for district, respawn in pairs(ICT.timetable) do
	
		local remaining = respawn - os.time()
	
		if remaining > 0 then
			color = "|cFF0000"
			if ICT.savedVariables.chatdebug == true and ICT.timetable[district] == 0 then
				d(district .. " is up again.")
			end
		else
			-- Boss is up
			color = "|c00FF00"
			remaining = 0
		end
		
		districtString = districtString .. color .. district .. "|r\n"
		timerString = timerString .. ICT.secondsToClock(remaining) .. "\n"
		
		if ICT.savedVariables.maptimers == true then
			ICT.ui.districts[district]:SetText(color .. ICT.secondsToClock(remaining))
		end
	end
	
	if ICT.savedVariables.timetable == true then
		ICTDistricLabel:SetText(districtString)
		ICTTimerLabel:SetText(timerString)
	end
end

function ICT.onMonsterDeath(_, unitTag, isDead)
		
	local mobName = GetUnitName(unitTag)

	if ICT.locations[mobName] ~= nil and isDead == true then
		local district = ICT.locations[mobName]
		ICT.timetable[district] = os.time() + ICT.spawntime
		if ICT.savedVariables.chatdebug == true then
			d(mobName .. " just died.")
		end
	end
end

function ICT.onMonsterReticle(_)

	local unitName = GetUnitNameHighlightedByReticle()
	local isDead = IsUnitDead('reticleover')
		
	if unitName == nil or unitName == "" then return end
	
	if ICT.savedVariables.chatdebug == true then
		local link = "|H1:icdebug:" .. unitName .. "|h[" .. unitName .. "]|h"
		d(link)
	end
	
	if ICT.fallbackTimes[unitName] == nil or (ICT.timetable[ICT.locations[unitName]] - os.time()) > 0 then return end
	
	if isDead == true then
		if ICT.fallbackTimes[unitName] > 0 then
			local district = ICT.locations[unitName]
			ICT.timetable[district] = os.time() + ICT.spawntime
			ICT.fallbackTimes[unitName] = 0
			if ICT.savedVariables.chatdebug == true then
				d(unitName .. " died. (in the last " .. ICT.fallbackMaxTime .. "s)")
			end
		end
	else
		ICT.fallbackTimes[unitName] = ICT.fallbackMaxTime
	end
end

function ICT.onZoneChange(_, _)
	
	local zone, x, y, z = GetUnitWorldPosition("player")

	if zone == 584 or zone == 643 then
		if ICT.running == false then
			-- Player joined IC
			EVENT_MANAGER:RegisterForEvent(ICT.name, EVENT_UNIT_DEATH_STATE_CHANGED, ICT.onMonsterDeath)
			EVENT_MANAGER:RegisterForEvent(ICT.name, EVENT_RETICLE_TARGET_CHANGED, ICT.onMonsterReticle)
			EVENT_MANAGER:RegisterForUpdate(ICT.name .. "_loop", 1000, ICT.updateTimers)
			ICTTimeTable:SetWidth(tonumber(GetString(SI_ICTHENEXTBOSS_GUI_WIDTH)))
			if ICT.savedVariables.timetable == true then
				HUD_SCENE:AddFragment(ICT.ui.timetable)
				HUD_UI_SCENE:AddFragment(ICT.ui.timetable)
				ICTTimeTable:SetHidden(false)
			end
			ICT.running = true
		else
			-- Player is still in IC
			-- Show Timetable again for some reason
			if ICT.savedVariables.timetable == true then
				HUD_SCENE:AddFragment(ICT.ui.timetable)
				HUD_UI_SCENE:AddFragment(ICT.ui.timetable)
				ICTTimeTable:SetHidden(false)
			end
		end
	else
		-- Player left IC
		if zone ~= 181 then	EVENT_MANAGER:UnregisterForUpdate(ICT.name .. "_loop") end -- Cyrodiil escape ;D
		EVENT_MANAGER:UnregisterForEvent(ICT.name, EVENT_UNIT_DEATH_STATE_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(ICT.name, EVENT_RETICLE_TARGET_CHANGED)
		ICTTimeTable:SetHidden(true)
		HUD_SCENE:RemoveFragment(ICT.ui.timetable)
		HUD_UI_SCENE:RemoveFragment(ICT.ui.timetable)
		ICT.running = false
	end
end

function ICT.HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, data)
	if linkType == "icdebug" then
		CHAT_SYSTEM.textEntry:Open(data)
		return true
	end
end

function ICT.OnAddOnLoaded(event, addonName)
	if addonName ~= ICT.name then return end
	
	EVENT_MANAGER:RegisterForEvent(ICT.name, EVENT_PLAYER_ACTIVATED, ICT.onZoneChange)
	
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, ICT.HandleClickEvent)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, ICT.HandleClickEvent)
	
	ICT.initializeSettingsMenu()
	ICT.restoreUIPosition()
	ICT.onMapOpen()
	ICT.disableMapMouseWheelZoom()
	ICTMapTimers:SetDrawTier(DT_HIGH) --Draw above WorldMap
	
	ICT.running = false
end

EVENT_MANAGER:RegisterForEvent(ICT.name, EVENT_ADD_ON_LOADED, ICT.OnAddOnLoaded)