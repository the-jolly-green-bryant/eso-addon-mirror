BatmansHomeAndOut = {
	name = "BatmansHomeAndOut",
}

local GS = GetString
local instanceZoneId = false
local currentZoneId = false
local lastZoneId = false
local activatedCallback = false
local leaderIsBack = false
local ultiFull = false
local debugMode = false

local wayPoints = {
	-- arenas
	[1227] = 457, -- Vateshran Hollows
	[677] = 249, -- Maelstrom Arena
	[1082] = 378, -- Blackrose Prison
	[635] = 270, -- Dragonstar Arena
	-- trials
	[1344] = 488, -- Dreadsail Reef
	[1121] = 399, -- Sunspire
	[725] = 258, -- Maw of Lorkhaj
	[1000] = 346, -- Asylum Sanctorium
	[639] = 232, -- Sanctum Ophidia
	[636] = 230, -- Hel Ra Citadel
	[1051] = 364, -- Cloudrest
	[1196] = 434, -- Kyne's Aegis
	[975] = 331, -- Halls of Fabrication
	[638] = 231, -- Aetherian Archive
	[1263] = 468, -- Rockgrove
	-- dungeons
	[64] = 187, -- Blessed Crucible
	[449] = 195, -- Direfrost Keep
	[130] = 190, -- Crypt of Hearts I
	[131] = 188, -- Tempest Island
	[843] = 260, -- Ruins of Mazzatun
	[1228] = 437, -- Black Drake Villa
	[973] = 326, -- Bloodroot Forge
	[974] = 332, -- Falkreath Hold
	[144] = 193, -- Spindleclutch I
	[1361] = 521, -- Graven Deep
	[146] = 189, -- Wayrest Sewers I
	[148] = 192, -- Arx Corinium
	[1301] = 497, -- Coral Aerie
	[22] = 196, -- Volenfell
	[283] = 98, -- Fungal Grotto I
	[1052] = 371, -- Moon Hunter Keep
	[1360] = 520, -- Earthen Root Enclave
	[31] = 185, -- Selene's Web
	[1302] = 498, -- Shipwright's Regret
	[1122] = 391, -- Moongrave Fane
	[930] = 264, -- Darkshade Caverns II
	[931] = 265, -- Elden Hollow II
	[932] = 269, -- Crypt of Hearts II
	[933] = 263, -- Wayrest Sewers II
	[934] = 266, -- Fungal Grotto II
	[935] = 262, -- The Banished Cells II
	[936] = 267, -- Spindleclutch II
	[681] = 268, -- City of Ash II
	[1123] = 398, -- Lair of Maarselok
	[1229] = 454, -- The Cauldron
	[1201] = 436, -- Castle Thorn
	[1197] = 435, -- Stone Garden
	[1153] = 425, -- Unhallowed Grave
	[1152] = 424, -- Icereach
	[688] = 247, -- White-Gold Tower
	[1009] = 341, -- Fang Lair
	[1010] = 363, -- Scalecaller Peak
	[1267] = 470, -- Red Petal Bastion
	[1268] = 469, -- The Dread Cellar
	[11] = 184, -- Vaults of Madness
	[38] = 186, -- Blackheart Haven
	[1055] = 370, -- March of Sacrifices
	[1080] = 389, -- Frostvault
	[1081] = 390, -- Depths of Malatar
	[176] = 197, -- City of Ash I
	[848] = 261, -- Cradle of Shadows
	[380] = 194, -- The Banished Cells I
	[678] = 236, -- Imperial City Prison
	[126] = 191, -- Elden Hollow I
	[63] = 198, -- Darkshade Caverns I
	[1389] = 531, --Bal Sunnar
	[1390] = 532, --Scrivener's Hall
	
}

local function BHAO_DEBUG(msg)
	if not debugMode then return end
	d(msg)
end

local function retryMultipleTimes(retryFunction)	
	BHAO_DEBUG("Trying to port - try no. 1")
	retryFunction()
	EVENT_MANAGER:UnregisterForUpdate(BatmansHomeAndOut.name.."RetryPorting")
	if BatmansHomeAndOut.sV.retryTime then 
		local portTries = 0
		EVENT_MANAGER:RegisterForUpdate(BatmansHomeAndOut.name.."RetryPorting", 1000, 
			function() 
				retryFunction()
				portTries = portTries + 1 
				BHAO_DEBUG("Trying to port - try no. "..portTries + 1)
				if portTries >= BatmansHomeAndOut.sV.retryTime then 
					EVENT_MANAGER:UnregisterForUpdate(BatmansHomeAndOut.name.."RetryPorting") 
				end 
			end)
	end
end

function BatmansHomeAndOut.debug()
	debugMode = not debugMode
	d(debugMode and "Batman ist debugging" or "Batman is not debugging")
end


local function isUltiFull()
	local currentUlti, maxUlti, effectiveMaxUlti = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_ULTIMATE)
	return currentUlti == maxUlti
end

local function isInHouse(houseId, homeOwner)
	if not GetUnitWorldPosition("player") == GetHouseZoneId(houseId) then return false end
	if not homeOwner then return IsOwnerOfCurrentHouse() end
	return DecorateDisplayName(GetCurrentHouseOwner()) == DecorateDisplayName(homeOwner)
end

local function findWayPoint(zoneId)
	local function simplifyName(complexName)
		local article = zo_strformat("<<x:1>>", complexName)
		local stgs = string.gsub
		local ls = string.lower
		return stgs(stgs(stgs(stgs(ls(stgs(stgs(stgs(zo_strformat("<<c:1>>", complexName), article, ""), ls(GS(SI_INSTANCEDISPLAYTYPE2)), ""), ls(GS(SI_INSTANCEDISPLAYTYPE3)), "")), "ä", "ae"), "ö", "oe"), "ü", "ue"), "[%p%s]", "")
	end

	local zoneName = simplifyName(GetZoneNameById(zoneId))
	
	for i=1, GetNumFastTravelNodes() do
		local _, wpName = GetFastTravelNodeInfo(i)
		if simplifyName(wpName) == zoneName then return i end
	end
end

local function portToZone(zoneId)	
	local myWaypoint = wayPoints[zoneId] or findWayPoint(zoneId) or false
	if not myWaypoint then return end
	
	if GetRecallCost(myWaypoint) > GetCurrencyAmount(GetRecallCurrency(myWaypoint), CURRENCY_LOCATION_CHARACTER) then return end

	local _, wpName = GetFastTravelNodeInfo(myWaypoint)
	
	d(zo_strformat("... <<C:1>>", wpName))

	retryMultipleTimes(function() FastTravelToNode(myWaypoint)  end)

end

function BatmansHomeAndOut.checkWaypoints()
	for _, v in ipairs(ZO_ACTIVITY_FINDER_ROOT_MANAGER:GetLocationsData(LFG_ACTIVITY_DUNGEON)) do 
		if v.zoneId and not wayPoints[v.zoneId] then
			d(v.zoneId)
			d(findWayPoint(v.zoneId))
		end
	end
end

local function waitForUlti(callbackFunc)
	EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."PowerUpdate", EVENT_POWER_UPDATE)
	EVENT_MANAGER:RegisterForEvent(BatmansHomeAndOut.name.."PowerUpdate", EVENT_POWER_UPDATE, 
		function(_, unitTag, powerIndex, powerType, powerValue, powerMax) 
			if unitTag ~= "player" then return end
			ultiFull = powerValue == powerMax
			if ultiFull then 
				callbackFunc()
				EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."PowerUpdate", EVENT_POWER_UPDATE)
			end			
		end)
	EVENT_MANAGER:AddFilterForEvent(BatmansHomeAndOut.name.."PowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_ULTIMATE)
end

local function checkForAutoPortBack()
	
	ultiFull = isUltiFull()
	if ultiFull then zo_callLater(function() portToZone(instanceZoneId) end, 1000 * (BatmansHomeAndOut.sV.waitToPortBack or 1)) return end
	
	waitForUlti(function() portToZone(instanceZoneId) end)
	
end

local function portToTheHouse()
	if BatmansHomeAndOut.sV.useOtherHouse and BatmansHomeAndOut.sV.ownerName then
		retryMultipleTimes(function() JumpToSpecificHouse(BatmansHomeAndOut.sV.ownerName, BatmansHomeAndOut.sV.homeToPost) end)
	else
		retryMultipleTimes(function() RequestJumpToHouse(BatmansHomeAndOut.sV.homeToPost, false) end)
	end
end

local function autoPortToHouse()
	if BatmansHomeAndOut.sV.autoPortBack then 
		EVENT_MANAGER:RegisterForEvent(BatmansHomeAndOut.name.."_PlayerActivePortToHouse", EVENT_PLAYER_ACTIVATED, 
			function() 
				EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."_PlayerActivePortToHouse", EVENT_PLAYER_ACTIVATED)
				ultiFull = false
				checkForAutoPortBack()
			end) 
	end
	portToTheHouse()
end

local function resetInstance()
	EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."_PlayerActiveResetInst", EVENT_PLAYER_ACTIVATED)
	zo_callLater(function()
			local currentDifficulty = IsGroupUsingVeteranDifficulty()
			if not CanPlayerChangeGroupDifficulty() then return end
			
			EVENT_MANAGER:RegisterForEvent(BatmansHomeAndOut.name.."_Reset", EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, 
				function()
					if IsGroupUsingVeteranDifficulty() ~= currentDifficulty then
						SetVeteranDifficulty(currentDifficulty)
					else	
						EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."_Reset", EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED)
						d(GS(BatmansHAO_AutoResetSuccess))
						if isUltiFull() or isInHouse(BatmansHomeAndOut.sV.homeToPost, BatmansHomeAndOut.sV.useOtherHouse and BatmansHomeAndOut.sV.ownerName or false) then
							if BatmansHomeAndOut.sV.autoPortBack then
								checkForAutoPortBack()
							end
						else
							if BatmansHomeAndOut.sV.autoPortToHouse then autoPortToHouse() end
						end
					end
				end)
			SetVeteranDifficulty(not currentDifficulty)
		end, 500)
end

local function BHAO_Post()
	if not BatmansHomeAndOut.sV.homeToPost then return end
	ZO_ChatWindowTextEntryEditBox:SetText("/party ")
	local textBefore = BatmansHomeAndOut.sV.textBefore or GS(BatmansHAO_CustomTextStandard)
	local textToPost = string.format("%s %s", textBefore, GetHousingLink(BatmansHomeAndOut.sV.homeToPost, BatmansHomeAndOut.sV.useOtherHouse and BatmansHomeAndOut.sV.ownerName or GetUnitDisplayName("player"), 1))
	StartChatInput(textToPost)
	
	local function OnChatEvent(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
		if fromDisplayName ~= GetUnitDisplayName("player") then return end
		if channelType ~= CHAT_CHANNEL_PARTY then return end
		if text ~= textToPost then return end
		EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."_ChatListener", EVENT_CHAT_MESSAGE_CHANNEL)
		
		if GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_NONE then return end
		instanceZoneId = currentZoneId
		
		if BatmansHomeAndOut.sV.autoReset then 
			EVENT_MANAGER:RegisterForEvent(BatmansHomeAndOut.name.."_PlayerActiveResetInst", EVENT_PLAYER_ACTIVATED, resetInstance) 
		end
		if IsUnitInCombat("player") or IsUnitDead("player") then
			ExitInstanceImmediately()
		else 
			portToTheHouse()
		end 
	end
	
	EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."_ChatListener", EVENT_CHAT_MESSAGE_CHANNEL)
	EVENT_MANAGER:RegisterForEvent(BatmansHomeAndOut.name.."_ChatListener", EVENT_CHAT_MESSAGE_CHANNEL, OnChatEvent)
	
	zo_callLater(function() EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."_ChatListener", EVENT_CHAT_MESSAGE_CHANNEL) end, BatmansHomeAndOut.sV.waitingTime * 1000)
end

BatmansHomeAndOut.BHAO_Post = BHAO_Post

local function portBackToLeader()
	retryMultipleTimes(function() JumpToGroupLeader() end)
end

local function waitForLeader(_, unitTag)
	if not AreUnitsEqual(unitTag, GetGroupLeaderUnitTag()) then return end
	if GetUnitWorldPosition(GetGroupLeaderUnitTag()) ~= instanceZoneId then return end
	leaderIsBack = true
	EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."_WaitForLeader", EVENT_ZONE_UPDATE) 
	if isUltiFull() or not BatmansHomeAndOut.sV.waitForUlti then 
		portBackToLeader() 
	else
		waitForUlti(portBackToLeader)
	end
end

local function OnChatEventGroup(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
	--* EVENT_ZONE_UPDATE (*string* _unitTag_, *string* _newZoneName_)
	if not BatmansHomeAndOut.sV.exitOnChat then return end
	if channelType ~= CHAT_CHANNEL_PARTY then return end
	if fromDisplayName ~= GetUnitDisplayName(GetGroupLeaderUnitTag()) then return end
	local linkedHome = string.match(text, "|H%d:housing:.-|h.-|h")
	if not linkedHome then return end
	
	--EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."_ChatListenerGroup", EVENT_CHAT_MESSAGE_CHANNEL)
	
	instanceZoneId = currentZoneId
	leaderIsBack = false
	ultiFull = isUltiFull()
	
	local houseId = string.match(linkedHome, "|H%d:housing:(.-):")
	local homeOwner = string.match(linkedHome, "|H%d:housing:%d+:(.-)|")
	
	if BatmansHomeAndOut.sV.portToLeader then EVENT_MANAGER:RegisterForEvent(BatmansHomeAndOut.name.."_WaitForLeader", EVENT_ZONE_UPDATE, waitForLeader) end
	
	ESO_Dialogs["BatmansHomeAndOutOkCancelDiag"] = {
		canQueue = true,
		uniqueIdentifier = "BatmansHomeAndOutOkCancelDiag",
		title = {text = "Batman's Home And Out"},
		mainText = {text = string.format(GS(BatmansHAO_DiagPortNow), linkedHome) },
		buttons = {
			[1] = {
				text = SI_DIALOG_CONFIRM,
				callback =  function() 
					if IsUnitInCombat("player") or IsUnitDead("player") then
						BHAO_DEBUG("Can't port, exit instance")
						activatedCallback = function() 
							BHAO_DEBUG("Activated callback...")
							activatedCallback = false 
							if BatmansHomeAndOut.sV.portToLeader  and ultiFull and leaderIsBack then portBackToLeader() return end
							if not ultiFull then 
								if not isInHouse(houseId, homeOwner) then
									retryMultipleTimes(function() JumpToSpecificHouse(homeOwner, houseId) end) 
								end
							end
						end
						ExitInstanceImmediately()
					else 
						activatedCallback = function() 
							activatedCallback = false 
							if BatmansHomeAndOut.sV.portToLeader  and ultiFull and leaderIsBack then portBackToLeader() return end
							
						end
						retryMultipleTimes(function() JumpToSpecificHouse(homeOwner, houseId) end)
					end 
				end,
			},
			[2] = {
				text = SI_DIALOG_CANCEL,
				callback =  function() end,
			},
		},
		setup = function() end,
	}	
	
	ZO_Dialogs_ShowDialog("BatmansHomeAndOutOkCancelDiag", {}, {mainTextParams = {}, titleParams = {}})
	
end

local function doesDungeonDifficultyFit()
	local difficulty = GetCurrentZoneDungeonDifficulty() 
	if difficulty == DUNGEON_DIFFICULTY_NONE then return false end
	if BatmansHomeAndOut.sV.otherThanVet or difficulty == DUNGEON_DIFFICULTY_VETERAN then return true end
	return false
end

local function setupGroupChatListener()
	if BatmansHomeAndOut.sV.exitOnChat and doesDungeonDifficultyFit() and not AreUnitsEqual(GetGroupLeaderUnitTag(), "player") then
		EVENT_MANAGER:RegisterForEvent(BatmansHomeAndOut.name.."_ChatListenerGroup", EVENT_CHAT_MESSAGE_CHANNEL, OnChatEventGroup)
	else
		EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."_ChatListenerGroup", EVENT_CHAT_MESSAGE_CHANNEL)
	end
end	

local function onPlayerActivated() -- this one is called on every PLAYER_ACTIVATED event
	EVENT_MANAGER:UnregisterForUpdate(BatmansHomeAndOut.name.."RetryPorting")
	local newZoneId = GetUnitWorldPosition("player")
	if newZoneId == currentZoneId then return end
	lastZoneId = currentZoneId
	currentZoneId = newZoneId
	if currentZoneId == instanceZoneId then
		BHAO_DEBUG("Back in instance, unregistering events")
		EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."PowerUpdate", EVENT_POWER_UPDATE)
		EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."_WaitForLeader", EVENT_ZONE_UPDATE)
		instanceZoneId = false
	end
	if activatedCallback then activatedCallback() end
	setupGroupChatListener()
end

local function BHAOInit()
	-- Setup the SavedVars
	BatmansHomeAndOut.sV = ZO_SavedVars:NewAccountWide("BatmansHomeAndOutSavedVariables", 1, nil, {}) -- account wide
	
	EVENT_MANAGER:RegisterForEvent(BatmansHomeAndOut.name.."_GroupUpdate", EVENT_LEADER_UPDATE, setupGroupChatListener)
	
	BatmansHomeAndOut.sV.homeToPost = BatmansHomeAndOut.sV.homeToPost or false
	BatmansHomeAndOut.sV.waitingTime = BatmansHomeAndOut.sV.waitingTime or 10

	local myHouseIds, myHouseNames = {}, {}
	
	local selectedHouseName = false
	
	local function refreshHouses()
		myHouseIds, myHouseNames = {}, {}
		selectedHouseName = false
		for _, collectibleData in pairs(ZO_COLLECTIBLE_DATA_MANAGER:GetAllCollectibleDataObjects({ZO_CollectibleCategoryData.IsHousingCategory }, { function() return true end }, SORTED)) do
			if collectibleData:IsUnlocked() or BatmansHomeAndOut.sV.useOtherHouse then 
				table.insert(myHouseNames, zo_strformat("<<C:1>> (<<C:2>>)", collectibleData:GetName(), collectibleData:GetFormattedNickname()))
				table.insert(myHouseIds, collectibleData:GetReferenceId())
				if BatmansHomeAndOut.sV.homeToPost == collectibleData:GetReferenceId() then
					selectedHouseName = zo_strformat("<<C:1>> (<<C:2>>)", collectibleData:GetName(), collectibleData:GetFormattedNickname())
					BHAO_DEBUG("Selected house: "..selectedHouseName)
					BatmansHomeAndOutLAM_LocationDropdown.dropdown:SetSelectedItemText(selectedHouseName)
				end
			end
		end
		return myHouseNames, myHouseIds
	end
		
	local panelName = "Batman's Home And Out"
	local panelData = {
		type = "panel",
		name = panelName,
		displayName = "Batman's Home And Out",
		author = "|c1d6dadIrniben|r",
		registerForRefresh = true,
    }
		
	local optionsData = {	
		{
			type = "dropdown",
			name = GS(BatmansHAO_LocationDropdown),
			width = "full",
			choices = myHouseNames,
			choicesValues = myHouseIds,
			sort = "name-up",
			default = false,
			getFunc = function() return BatmansHomeAndOut.sV.homeToPost end,
			setFunc = function(value) BatmansHomeAndOut.sV.homeToPost = value end,
			reference = "BatmansHomeAndOutLAM_LocationDropdown",
			scrollable  = true,
			disabled = function() return false end, 
		},
		
		{
			type = "checkbox",
			name = GS(BatmansHAO_UseStrangersHouse),
			tooltip =  GS(BatmansHAO_UseStrangersHouse),
			width = "full",
			default = false,
			getFunc = function() return BatmansHomeAndOut.sV.useOtherHouse end,
			setFunc = function(value) BatmansHomeAndOut.sV.useOtherHouse = value end,
			disabled = function() return false end, 
		},		
		{
			type = "editbox",
			name = GS(SI_CUSTOMER_SERVICE_ASK_FOR_HELP_PLAYER_NAME),
			width = "full",
			maxchars = 300,
			sort = "name-up",
			default = false,
			getFunc = function() return BatmansHomeAndOut.sV.ownerName or "-" end,
			setFunc = function(value) BatmansHomeAndOut.sV.ownerName = value ~= "" and value ~= "-" and value or false end,
			disabled = function() return not BatmansHomeAndOut.sV.useOtherHouse end, 
		},
		{
			type = "divider",
			width = "full",
		},
		{
			
			type = "header",
			name = GS(SI_GROUP_LIST_PANEL_LEADER_TOOLTIP),
			width = "full",
		},			
		{
			type = "editbox",
			name = GS(BatmansHAO_CustomText),
			width = "full",
			maxchars = 300,
			sort = "name-up",
			default = false,
			getFunc = function() return BatmansHomeAndOut.sV.textBefore or GS(BatmansHAO_CustomTextStandard) end,
			setFunc = function(value) BatmansHomeAndOut.sV.textBefore = value end,
			disabled = function() return false end, 
		},
		{
			type = "slider",
			name = GS(BatmansHAO_WaitingTime),
			tooltip = GS(BatmansHAO_WaitingTimeTT),
			width = "full",
			min = 5,
			max = 30,
			step = 1, --(optional)
			default = false,
			getFunc = function() return BatmansHomeAndOut.sV.waitingTime end,
			setFunc = function(value) BatmansHomeAndOut.sV.waitingTime = value end,
			disabled = function() return false end, 
		},
		{
			type = "checkbox",
			name = GS(BatmansHAO_AutoReset),
			tooltip = GS(BatmansHAO_AutoReset),
			width = "full",
			default = false,
			getFunc = function() return BatmansHomeAndOut.sV.autoReset end,
			setFunc = function(value) BatmansHomeAndOut.sV.autoReset = value end,
			disabled = function() return false end, 
		},		
		{
			type = "checkbox",
			name = GS(BatmansHAO_PortToHouse),
			tooltip =  GS(BatmansHAO_PortToHouse),
			width = "full",
			default = false,
			getFunc = function() return BatmansHomeAndOut.sV.autoReset and BatmansHomeAndOut.sV.autoPortToHouse end,
			setFunc = function(value) BatmansHomeAndOut.sV.autoPortToHouse = value end,
			disabled = function() return not BatmansHomeAndOut.sV.autoReset end, 
		},		
		{
			type = "checkbox",
			name = GS(BatmansHAO_PortBack),
			tooltip = GS(BatmansHAO_PortBack),
			width = "full",
			default = false,
			getFunc = function() return BatmansHomeAndOut.sV.autoReset and BatmansHomeAndOut.sV.autoPortToHouse and BatmansHomeAndOut.sV.autoPortBack end,
			setFunc = function(value) BatmansHomeAndOut.sV.autoPortBack = value end,
			disabled = function() return not (BatmansHomeAndOut.sV.autoReset and BatmansHomeAndOut.sV.autoPortToHouse) end, 
		},		
		{
			type = "slider",
			name = GS(BatmansHAO_PortBackWait),
			tooltip = GS(BatmansHAO_PortBackWaitTT),
			width = "full",
			min = 0.5,
			max = 7,
			step = 0.5, --(optional)
			default = false,
			getFunc = function() return BatmansHomeAndOut.sV.waitToPortBack or 1 end,
			setFunc = function(value) BatmansHomeAndOut.sV.waitToPortBack = value end,
			disabled = function() return false end, 
		},
		{
			type = "slider",
			name = GS(BatmansHAO_PortBackRetry),
			tooltip = GS(BatmansHAO_PortBackRetryTT),
			width = "full",
			min = 0,
			max = 10,
			step = 1, --(optional)
			default = false,
			getFunc = function() return BatmansHomeAndOut.sV.retryTime end,
			setFunc = function(value) BatmansHomeAndOut.sV.retryTime = value end,
			disabled = function() return false end, 
		},		
		{
			type = "divider",
			width = "full",
		},
		{
			
			type = "header",
			name = GS(SI_PLAYERS_MET_TITLE_GROUP),
			width = "full",
		},			
		{
			type = "checkbox",
			name = GS(BatmansHAO_ExitOnChat),
			tooltip = GS(BatmansHAO_ExitOnChat),
			width = "full",
			default = false,
			getFunc = function() return BatmansHomeAndOut.sV.exitOnChat end,
			setFunc = function(value) BatmansHomeAndOut.sV.exitOnChat = value setupGroupChatListener() end,
		},	
		{
			type = "checkbox",
			name = GS(BatmansHAO_VeteranOnly),
			tooltip = GS(BatmansHAO_VeteranOnly),
			width = "full",
			default = false,
			getFunc = function() return not BatmansHomeAndOut.sV.otherThanVet end,
			setFunc = function(value) BatmansHomeAndOut.sV.otherThanVet = not value setupGroupChatListener() end,
		},	
		{
			type = "checkbox",
			name = GS(BatmansHAO_PortToLeader),
			tooltip = GS(BatmansHAO_PortToLeader),
			width = "full",
			default = false,
			getFunc = function() return BatmansHomeAndOut.sV.portToLeader end,
			setFunc = function(value) BatmansHomeAndOut.sV.portToLeader = value end,
			disabled = function() return not BatmansHomeAndOut.sV.exitOnChat end, 
		},	
		{
			type = "checkbox",
			name = GS(BatmansHAO_WaitForUlti),
			tooltip = GS(BatmansHAO_WaitForUlti),
			width = "full",
			default = false,
			getFunc = function() return BatmansHomeAndOut.sV.waitForUlti end,
			setFunc = function(value) BatmansHomeAndOut.sV.waitForUlti = value end,
			disabled = function() return not BatmansHomeAndOut.sV.exitOnChat or not BatmansHomeAndOut.sV.portToLeader end, 
		},	
	}	
	
	local LAM = LibAddonMenu2
	
    local myPanel = LAM:RegisterAddonPanel("BatmansHomeAndOutOptions", panelData)
	LAM:RegisterOptionControls("BatmansHomeAndOutOptions", optionsData)
		
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
		if panel ~= myPanel then return end
		if BatmansHomeAndOutLAM_LocationDropdown then
			BatmansHomeAndOutLAM_LocationDropdown:UpdateChoices(refreshHouses())
			if selectedHouseName then 
				BatmansHomeAndOutLAM_LocationDropdown.dropdown:SetSelectedItemText(selectedHouseName)
			end	
		else
			refreshHouses()
		end
	end)
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
		if panel ~= myPanel then return end
		if BatmansHomeAndOutLAM_LocationDropdown then
			BatmansHomeAndOutLAM_LocationDropdown:UpdateChoices(refreshHouses())
			if selectedHouseName then 
				BatmansHomeAndOutLAM_LocationDropdown.dropdown:SetSelectedItemText(selectedHouseName)
			end	
		end
	end)

	EVENT_MANAGER:UnregisterForEvent(BatmansHomeAndOut.name.."OnLoad", EVENT_ADD_ON_LOADED)
end

local function BHAOOnAddonLoaded(event, addonName)
  if addonName == BatmansHomeAndOut.name then
     BHAOInit()
  end
end

EVENT_MANAGER:RegisterForEvent(BatmansHomeAndOut.name.."OnLoad", EVENT_ADD_ON_LOADED, BHAOOnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(BatmansHomeAndOut.name.."OnActivated", EVENT_PLAYER_ACTIVATED, onPlayerActivated)

SLASH_COMMANDS["/hao"] = function() BHAO_Post() end