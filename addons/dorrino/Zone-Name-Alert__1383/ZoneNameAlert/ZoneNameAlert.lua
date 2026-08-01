local LAM2 = LibStub("LibAddonMenu-2.0")
local ZNA={}
ZNA.icons={}
ZNA.colors={}
ZNA.version="1.15"
ZNA.name = "ZoneNameAlert"
ZNA.playerActivated=false
ZNA.lastZone="start"
ZNA.lastDisplayedZone="start"
ZNA.lastZoneTime=nil
ZNA.zoneDeadTime=5000
ZNA.defaultZoneIcon="/esoui/art/icons/mapkey/mapkey_elderscroll.dds"
ZNA.groupDungeonZoneIcon="/esoui/art/icons/mapkey/mapkey_groupinstance.dds"
ZNA.delveZoneIcon="/esoui/art/icons/mapkey/mapkey_delve.dds"
ZNA.underAttackIcon="/esoui/art/mappins/ava_attackburst_64.dds"
ZNA.spacerTexture="/esoui/art/worldmap/worldmap_map_background.dds"
ZNA.defaults={
	enabled=true,
	UseIcons=true,
	TwoIcons=true,
	IsColor=true,
	largeFont=true,
	IconSize=64
	}

ZNA.icons[KEEPTYPE_KEEP] = {
	"/esoui/art/compass/ava_largekeep_neutral.dds", 
	"/esoui/art/compass/ava_largekeep_aldmeri.dds",
	"/esoui/art/compass/ava_largekeep_daggerfall.dds",
	"/esoui/art/compass/ava_largekeep_ebonheart.dds",
	-- "/esoui/art/mappins/ava_largekeep_neutral_underattack.dds", 
	-- "/esoui/art/mappins/ava_largekeep_aldmeri_underattack.dds",
	-- "/esoui/art/mappins/ava_largekeep_daggerfall_underattack.dds",
	-- "/esoui/art/mappins/ava_largekeep_ebonheart_underattack.dds",
}
ZNA.icons[KEEPTYPE_OUTPOST] = {
	"/esoui/art/compass/ava_outpost_neutral.dds",
	"/esoui/art/compass/ava_outpost_aldmeri.dds",
	"/esoui/art/compass/ava_outpost_daggerfall.dds",
	"/esoui/art/compass/ava_outpost_ebonheart.dds",
	-- "/esoui/art/mappins/ava_outpost_neutral.dds",
	-- "/esoui/art/mappins/ava_outpost_aldmeri.dds",
	-- "/esoui/art/mappins/ava_outpost_daggerfall.dds",
	-- "/esoui/art/mappins/ava_outpost_ebonheart.dds"	
}
ZNA.icons[RESOURCETYPE_FOOD] = {
	"/esoui/art/compass/ava_farm_neutral.dds",
	"/esoui/art/compass/ava_farm_aldmeri.dds",
	"/esoui/art/compass/ava_farm_daggerfall.dds",
	"/esoui/art/compass/ava_farm_ebonheart.dds",
	-- "/esoui/art/mappins/ava_farmunderattack_neutral.dds",
	-- "/esoui/art/mappins/ava_farmunderattack_aldmeri.dds",
	-- "/esoui/art/mappins/ava_farmunderattack_daggerfall.dds",
	-- "/esoui/art/mappins/ava_farmunderattack_ebonheart.dds"
}
ZNA.icons[RESOURCETYPE_ORE] = {
	"/esoui/art/compass/ava_mine_neutral.dds",
	"/esoui/art/compass/ava_mine_aldmeri.dds",
	"/esoui/art/compass/ava_mine_daggerfall.dds",
	"/esoui/art/compass/ava_mine_ebonheart.dds",
	-- "/esoui/art/mappins/ava_mineunderattack_neutral.dds",
	-- "/esoui/art/mappins/ava_mineunderattack_aldmeri.dds",
	-- "/esoui/art/mappins/ava_mineunderattack_daggerfall.dds",
	-- "/esoui/art/mappins/ava_mineunderattack_ebonheart.dds"
}
ZNA.icons[RESOURCETYPE_WOOD] = {
	"/esoui/art/compass/ava_lumbermill_neutral.dds",
	"/esoui/art/compass/ava_lumbermill_aldmeri.dds",
	"/esoui/art/compass/ava_lumbermill_daggerfall.dds",
	"/esoui/art/compass/ava_lumbermill_ebonheart.dds",
	-- "/esoui/art/mappins/ava_lumbermillunderattack_neutral.dds",
	-- "/esoui/art/mappins/ava_lumbermillunderattack_aldmeri.dds",
	-- "/esoui/art/mappins/ava_lumbermillunderattack_daggerfall.dds",
	-- "/esoui/art/mappins/ava_lumbermillunderattack_ebonheart.dds"
}
ZNA.icons[KEEPTYPE_ARTIFACT_GATE] = {
	"/esoui/art/icons/mapkey/mapkey_elderscroll.dds",
	"/esoui/art/compass/ava_artifactgate_aldmeri_closed.dds",
	"/esoui/art/compass/ava_artifactgate_daggerfall_closed.dds",
	"/esoui/art/compass/ava_artifactgate_ebonheart_closed.dds",	
	-- "/esoui/art/compass/ava_artifactgate_aldmeri_closed.dds",
	-- "/esoui/art/compass/ava_artifactgate_daggerfall_closed.dds",
	-- "/esoui/art/compass/ava_artifactgate_ebonheart_closed.dds"
}
ZNA.icons[KEEPTYPE_IMPERIAL_CITY_DISTRICT] = {
	"/esoui/art/compass/ava_imperialdistrict_neutral.dds",
	"/esoui/art/compass/ava_imperialdistrict_aldmeri.dds",
	"/esoui/art/compass/ava_imperialdistrict_daggerfall.dds",
	"/esoui/art/compass/ava_imperialdistrict_ebonheart.dds",
}	

ZNA.colors[1]="C3AA49"
ZNA.colors[2]="DE5C4F"
ZNA.colors[3]="688EB1"



function ZNA.Colorize(text, color)
     local combineTable = { "|c", color, tostring(text), "|r" }
     return table.concat(combineTable)
end

function ZNA.OnZone(isCallback,zoneIndex,newZone,subzoneIndex)
	
	if not ZNA.playerActivated then return end

	local zoneText
	if newZone=="" or newZone==nil then 
		zoneText=GetPlayerLocationName()
	else 
		zoneText=newZone
	end
	if zoneText=="" or zoneText==nil  then return end	--discarded
		

	local zoneTime=GetFrameTimeMilliseconds()
	local timeDiff=(zoneTime-ZNA.lastZoneTime)
	-- local queueSizeCSA=CENTER_SCREEN_ANNOUNCE:GetNumQueuedEvents()
	local queueSizeCSA=#CENTER_SCREEN_ANNOUNCE.displayQueue
	local isInDeadZone=timeDiff<ZNA.zoneDeadTime

	if (isCallback=="Callback" and isInDeadZone) then return end --CALLBACK discarded
	if zoneText==ZNA.lastDisplayedZone and isCallback~="AVA" then ZNA.lastZoneTime=zoneTime return end
	
	local currentIcon 	
	
	if isCallback~="Callback" then zoneIndex, subzoneIndex=GetCurrentSubZonePOIIndices() end
	currentIcon=ZNA.GetIcon(zoneText, zoneIndex, subzoneIndex)
	
	if isInDeadZone or queueSizeCSA>=1 then
		local callbackDelay
		if queueSizeCSA>=1 then
			ZNA.lastZoneTime=zoneTime
			callbackDelay=ZNA.zoneDeadTime
		else
			callbackDelay=1.01*(ZNA.zoneDeadTime-timeDiff) 
		end
		zo_callLater(function() ZNA.OnZone("Callback", zoneIndex, zoneText, subzoneIndex) end, callbackDelay)
		return
	end

	ZNA.lastZoneTime=zoneTime
	ZNA.lastDisplayedZone=zoneText
	ZNA.OnDraw(zoneText,currentIcon)
end

function ZNA.GetIcon(zoneText, zoneIndex, subzoneIndex)

	local currentIcon=ZNA.defaultZoneIcon
	if zoneIndex and subzoneIndex then
		local _,_,_,currentMapIcon,isShown,_=GetPOIMapInfo(zoneIndex,subzoneIndex)
		if isShown and currentMapIcon~=nil then currentIcon=currentMapIcon end
	end
	
	return currentIcon
end


function ZNA.OnDraw(zoneText,currentIcon)

	local iconSize=ZNA.savedVariables.IconSize
	local drawUnderAttack=false

	if IsInCyrodiil() then
		if string.match(zoneText,"Elsweyr Gate") then 
			currentIcon="/esoui/art/compass/ava_borderkeep_pin_aldmeri.dds" 
			if ZNA.savedVariables.IsColor then zoneText=ZNA.Colorize(zoneText,ZNA.colors[1]) end
		elseif string.match(zoneText,"Morrowind Gate") then 
			currentIcon="/esoui/art/compass/ava_borderkeep_pin_ebonheart.dds" 
			if ZNA.savedVariables.IsColor then zoneText=ZNA.Colorize(zoneText,ZNA.colors[2]) end
		elseif string.match(zoneText,"High Rock  Gate") then 
			currentIcon="/esoui/art/compass/ava_borderkeep_pin_daggerfall.dds" 
			if ZNA.savedVariables.IsColor then zoneText=ZNA.Colorize(zoneText,ZNA.colors[3]) end
		elseif string.match(zoneText,"Scroll Temple") then 
			if string.match(zoneText,"Altadoon") or string.match(zoneText,"Mnem") then
				currentIcon="/esoui/art/compass/ava_artifacttemple_aldmeri.dds" 
				if ZNA.savedVariables.IsColor then zoneText=ZNA.Colorize(zoneText,ZNA.colors[1]) end
			elseif string.match(zoneText,"Ghartok") or string.match(zoneText,"Chim") then
				currentIcon="/esoui/art/compass/ava_artifacttemple_ebonheart.dds" 
				if ZNA.savedVariables.IsColor then zoneText=ZNA.Colorize(zoneText,ZNA.colors[2]) end
			elseif string.match(zoneText,"Alma Ruma") or string.match(zoneText,"Ni-Mohk") then
				currentIcon="/esoui/art/compass/ava_artifacttemple_daggerfall.dds" 
				if ZNA.savedVariables.IsColor then zoneText=ZNA.Colorize(zoneText,ZNA.colors[3]) end
			end
		else
			local isUnderAttack, KeepAlliance, keepType = ZNA.OnCyro(zoneText) 
			-- d('zoneText', zoneText)
			-- d('keepType', keepType)
			if isUnderAttack~=nil and KeepAlliance~=nil and keepType~=nil then
				if KeepAlliance==1 then
						currentIcon=ZNA.icons[keepType][2]
				elseif KeepAlliance==2 then
						currentIcon=ZNA.icons[keepType][4]
				elseif KeepAlliance==3 then
						currentIcon=ZNA.icons[keepType][3]
				else
						currentIcon=ZNA.icons[keepType][1]
				end
				if ZNA.savedVariables.IsColor then 
					 zoneText=ZNA.Colorize(zoneText,ZNA.colors[KeepAlliance])
				else
					currentIcon=ZNA.icons[keepType][1]
				end
				if isUnderAttack then drawUnderAttack=true end
			end
		end
	end
	
	if IsUnitInDungeon("player") then
		if GetCurrentZoneDungeonDifficulty()~=0 then
			currentIcon=ZNA.groupDungeonZoneIcon
		else 
			currentIcon=ZNA.delveZoneIcon
		end
	end
	------------------------------------------------------------------------------------------------------
	-- This, below, is a very bad way of doing icons alignment in a text input, but it's the only one i could find. Enjoy it, embrace it.
	------------------------------------------------------------------------------------------------------
	local textIconLeft = zo_iconTextFormat(currentIcon, iconSize, iconSize, zoneText)
	local textIconRight = zo_iconFormat(currentIcon, -iconSize, iconSize)
	local alignmentFix=zo_iconFormat(ZNA.spacerTexture, 1.16*iconSize, iconSize)
	local alignmentFixRight=zo_iconFormat(ZNA.spacerTexture, -0.15*iconSize, iconSize)
	local alignmentFixRightLarge=zo_iconFormat(ZNA.spacerTexture, -1.15*iconSize, iconSize)
	local alignmentFixRightLargeNoAttack=zo_iconFormat(ZNA.spacerTexture, -0.99*iconSize, iconSize)
	local alignmentFixRightSmall=zo_iconFormat(ZNA.spacerTexture, -0.995*iconSize, iconSize)
	local alignmentFixLeft=zo_iconFormat(ZNA.spacerTexture, 0.145*iconSize, iconSize)
	local alignmentFixSpacer=zo_iconFormat(ZNA.spacerTexture, 1.145*iconSize, iconSize)
	local underAttackTextLeft=zo_iconFormat(ZNA.underAttackIcon, -iconSize*1.3, iconSize*1.3)
	local underAttackTextRight=zo_iconFormat(ZNA.underAttackIcon, iconSize*1.3, iconSize*1.3)

	local messageCSA
	
	if ZNA.savedVariables.UseIcons then
		if ZNA.savedVariables.TwoIcons then
			if drawUnderAttack then
				messageCSA=alignmentFix..alignmentFixLeft..underAttackTextLeft..alignmentFixLeft..textIconLeft..alignmentFixSpacer..textIconRight..alignmentFixRight..underAttackTextRight
			else
				messageCSA=alignmentFixRightLargeNoAttack..textIconLeft..alignmentFixSpacer..textIconRight
			end
		else
			if drawUnderAttack then
				messageCSA=alignmentFixRightLarge..alignmentFix..underAttackTextLeft..alignmentFixLeft..textIconLeft
			else
				messageCSA=alignmentFixRightSmall..alignmentFixRight..textIconLeft
			end
		end
	else
		messageCSA=zoneText
	end

	local messageParams	
	
	if ZNA.savedVariables.largeFont then
		-- :DisplayMessage(messageParams)
		messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
		
		messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_ADDED)
		-- CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(EVENT_QUEST_ADDED, CSA_EVENT_LARGE_TEXT, nil, messageCSA)
	else
		messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
		messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_ADDED)
		-- CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(EVENT_QUEST_ADDED, CSA_EVENT_SMALL_TEXT, nil, messageCSA)
	end
	messageParams:SetText(messageCSA)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
	-- d('Zonename: '..messageCSA)
end

function ZNA.OnCyro(zoneText)
	if string.sub(zoneText,-string.len("Lumbermill"))=="Lumbermill" or 
		string.sub(zoneText,-string.len("Mine"))=="Mine" or 	
		string.sub(zoneText,-string.len("Farm"))=="Farm" or
		string.sub(zoneText,-string.len("Keep"))=="Keep" or
		string.sub(zoneText,-string.len("District"))=="District" or
		string.match(zoneText,"Arboretum") or
		string.sub(zoneText,-string.len("Outpost"))=="Outpost" or
		((string.sub(zoneText,1,string.len("Fort"))=="Fort" or 
		string.sub(zoneText,1,string.len("Gate of"))=="Gate of" or
		string.sub(zoneText,1,string.len("Castle"))=="Castle") and
		string.sub(zoneText,-string.len("Grounds"))~="Grounds") then
	   		for i=1, GetNumKeeps() do
				local keepId=GetKeepKeysByIndex(i)
				if GetKeepName(keepId)==zoneText then
					return GetKeepUnderAttack(keepId,BGQUERY_LOCAL), GetKeepAlliance(keepId,BGQUERY_LOCAL), GetKeepType(keepId), keepId -- 1-AD, 2-EP 3-DC
				end
			end
		end
	return
end

function ZNA.OnActivated()
	ZNA.playerActivated=true
	ZNA.lastZone="start"
	ZNA.lastDisplayedZone="start"
	ZNA.lastZoneTime=GetFrameTimeMilliseconds()-ZNA.zoneDeadTime
	ZNA.OnZone(nil)
end

function ZNA.initializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Zone Name Alert",
		displayName = "Zone Name Alert",
		author = "Dorrino",
		version = ZNA.version,
		slashCommand = "/zna",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local optionsPanel = LAM2:RegisterAddonPanel("ZoneNameAlert", panelData)
	
	
	local optionsData = {}
	
	table.insert(optionsData, {
		type = "header",
		name = "Zone Name Alerts options",
		})	
	table.insert(optionsData, {
		type = "checkbox",
		name = "ADDON ENABLED",
		tooltip = "ON - enabled, OFF - disabled",
		default = ZNA.defaults.enabled,
		getFunc = function() return ZNA.savedVariables.enabled end,
		setFunc = function(newValue) ZNA.savedVariables.enabled = newValue ZNA.OnOff() end,
		})	
	table.insert(optionsData, {
		type = "header",
		name = "Points of interest icons options",
		})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Show icons",
		tooltip = "ON - shows Point of Interest icons around the zone name text, OFF - does not show Point of Interest icons",
		default = true,
		disabled = function() return not ZNA.savedVariables.enabled end,
		getFunc = function() return ZNA.savedVariables.UseIcons end,
		setFunc = function(newValue) ZNA.savedVariables.UseIcons = newValue	
			-- ZNA.messageUseIcons = newValue 
			ZNA.OnDraw("TEST ZONE NAME",ZNA.defaultZoneIcon) end,
		})	
	table.insert(optionsData, {
		type = "checkbox",
		name = "Double icons",
		tooltip = "ON - shows left and right Point of Interest icons around the zone name text, OFF - only shows one icon to the left of the zone name text",
		default = true,
		disabled = function() return not ZNA.savedVariables.enabled end,
		getFunc = function() return ZNA.savedVariables.TwoIcons end,
		setFunc = function(newValue) ZNA.savedVariables.TwoIcons = newValue	
			-- ZNA.messageTwoIcons = newValue
			if ZNA.savedVariables.UseIcons then ZNA.OnDraw("TEST ZONE NAME",ZNA.defaultZoneIcon) end 
		end,
		})	
	table.insert(optionsData, {
			type = "dropdown",
			name = "Pick POI icons size",
			tooltip = "Small icons size - 32px, normal icons size - 64px, larger icon size - 72px",
			choices = {"Small icons", "Normal icons", "Larger icons"},
			getFunc = function() 
				if ZNA.savedVariables.IconSize==48 then 
					return "Small icons"
				elseif ZNA.savedVariables.IconSize==64 then
					return "Normal icons"
				elseif ZNA.savedVariables.IconSize==72 then
					return "Larger icons"
				end
			end,
			setFunc = function(newValue)
				if newValue=="Small icons" then 
					ZNA.savedVariables.IconSize=48
					-- ZNA.zoneIconSize=48
				elseif newValue=="Normal icons" then
					ZNA.savedVariables.IconSize=64
					-- ZNA.zoneIconSize=64
				elseif 	newValue=="Larger icons" then
					ZNA.savedVariables.IconSize=72
					-- ZNA.zoneIconSize=72
				end
				ZNA.OnDraw("TEST ZONE NAME",ZNA.defaultZoneIcon)
			end,
			default = "Normal icons",
			disabled = function() return not ZNA.savedVariables.enabled end,
		})	
	table.insert(optionsData, {
		type = "header",
		name = "Misc",
		})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Use large font size",
		tooltip = "ON - use LARGE font and its specific animation for zone text, OFF - use SMALL font and its specific animation for zone text",
		default = true,
		disabled = function() return not ZNA.savedVariables.enabled end,
		getFunc = function() return ZNA.savedVariables.largeFont end,
		setFunc = function(newValue) ZNA.savedVariables.largeFont = newValue	
			-- ZNA.messageUseIcons = newValue 
			ZNA.OnDraw("TEST ZONE NAME",ZNA.defaultZoneIcon) end,
		})	
	table.insert(optionsData, {
		type = "checkbox",
		name = "Zone text and icons is colored in Cyrodiil",
		tooltip = "ON - Cyrodiil keeps and resources names and icons have colors based on the alliance that controls them, OFF - names and icons stay white in Cyrodiil",
		default = true,
		disabled = function() return not ZNA.savedVariables.enabled end,
		getFunc = function() return ZNA.savedVariables.IsColor end,
		setFunc = function(newValue) 
			ZNA.savedVariables.IsColor = newValue	
			-- ZNA.colorMessageCyro = newValue
			if newValue then
				local text=ZNA.Colorize("Test keep test resource",ZNA.colors[1])
				ZNA.OnDraw(text,ZNA.icons[KEEPTYPE_KEEP][2])
			else
				ZNA.OnDraw("Test keep test resource",ZNA.icons[KEEPTYPE_KEEP][1])
			end
		end,
		})
	
	LAM2:RegisterOptionControls("ZoneNameAlert", optionsData)	
end

function ZNA.OnKeepStatus(eventCode, keepId, battlegroundContext, underAttack)
	if GetPlayerLocationName()==GetKeepName(keepId) and (battlegroundContext==BGQUERY_LOCAL or battlegroundContext==BGQUERY_ASSIGNED_AND_LOCAL) then ZNA.OnZone("AVA") end
end

function ZNA.OnOff()
	if ZNA.savedVariables.enabled then
		EVENT_MANAGER:RegisterForEvent(ZNA.name, EVENT_PLAYER_ACTIVATED, ZNA.OnActivated)
		EVENT_MANAGER:RegisterForEvent(ZNA.name, EVENT_ZONE_CHANGED, function(...) ZNA.OnZone(...) end)
		EVENT_MANAGER:RegisterForEvent(ZNA.name, EVENT_PLAYER_DEACTIVATED, function() ZNA.playerActivated=false end)
		EVENT_MANAGER:RegisterForEvent(ZNA.name, EVENT_KEEP_UNDER_ATTACK_CHANGED, ZNA.OnKeepStatus)
		ZNA.OnActivated()
	else
		EVENT_MANAGER:UnregisterForEvent(ZNA.name, EVENT_PLAYER_ACTIVATED, ZNA.OnActivated)
		EVENT_MANAGER:UnregisterForEvent(ZNA.name, EVENT_ZONE_CHANGED, function(...) ZNA.OnZone(...) end)
		EVENT_MANAGER:UnregisterForEvent(ZNA.name, EVENT_PLAYER_DEACTIVATED, function() ZNA.playerActivated=false end)
		EVENT_MANAGER:UnregisterForEvent(ZNA.name, EVENT_KEEP_UNDER_ATTACK_CHANGED, ZNA.OnKeepStatus)
	end
end

function ZNA.OnLoad(eventCode, addonName)
	if addonName~=ZNA.name then return end
	ZNA.savedVariables = ZO_SavedVars:New("ZoneAlertSettings", 1.1, nil, ZNA.defaults)
	ZNA.initializeAddonMenu()
	
	EVENT_MANAGER:UnregisterForEvent(ZNA.name, EVENT_ADD_ON_LOADED, ZNA.OnLoad)
	if ZNA.savedVariables.enabled then
		EVENT_MANAGER:RegisterForEvent(ZNA.name, EVENT_PLAYER_ACTIVATED, ZNA.OnActivated)
		EVENT_MANAGER:RegisterForEvent(ZNA.name, EVENT_ZONE_CHANGED, function(...) ZNA.OnZone(...) end)
		EVENT_MANAGER:RegisterForEvent(ZNA.name, EVENT_PLAYER_DEACTIVATED, function() ZNA.playerActivated=false end)
		EVENT_MANAGER:RegisterForEvent(ZNA.name, EVENT_KEEP_UNDER_ATTACK_CHANGED, ZNA.OnKeepStatus)
	end
	ZO_PreHook(ZO_AlertText_GetHandlers(), EVENT_ZONE_CHANGED, function() return ZNA.savedVariables.enabled end)
	
end

EVENT_MANAGER:RegisterForEvent(ZNA.name, EVENT_ADD_ON_LOADED, ZNA.OnLoad)
