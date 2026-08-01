FyrMM = {}
FyrMM.Panel = {}
FyrMM.Options = {}
FyrMM.noMap = false
FyrMM.Visible = true
FyrMM.AutoHidden = false
FyrMM.FpsTest = false
FyrMM.Fps = 0
FyrMM.FpsRaw = 0
FyrMM.Initialized = false
FyrMM.pScale = 75
FyrMM.pScalePercent = 0.75
FyrMM.questPinCount = 0
FyrMM.currentLocationsCount = 0
FyrMM.currentPOICount = 0
FyrMM.currentForwardCamps = 0
FyrMM.currentWayshrineCount = 0
FyrMM.AfterCombatUnhidePending = false
FyrMM.AfterCombatUnhideTimeStamp = 0
FyrMM.LastQuestPinRequest = 0
FyrMM.MovementSpeed = 0
FyrMM.MovementSpeedPrevious = 0
FyrMM.MovementSpeedMax = 0
FyrMM.UseOriginalFunctions = true
FyrMM.MeasureMaps = true
FyrMM.DistanceMeasurementStarted = false
FyrMM.InitialPreloadTimeStamp = nil
FyrMM.currentMap = {}
FyrMM.currentMap.MapId = 0
FyrMM.currentMap.PlayerNX = 0
FyrMM.currentMap.PlayerNY = 0
FyrMM.currentMap.mapBuilt = false
FyrMM.currentMap.PlayerMounted = false
FyrMM.currentMap.PlayerSwimming = false
FyrMM.currentMap.movedTimeStamp = 0
FyrMM.currentMap.ZoneId = 0
FyrMM.CheckingZone = false
FyrMM.CustomPinList = {}
FyrMM.LoadingCustomPins = {}
FyrMM.UpdatingCustomPins = {}
FyrMM.CustomPinsEnabled = true
FyrMM.CustomWaypointsList = {}
FyrMM.IsGroup = false
FyrMM.IsWaypoint = false
FyrMM.Waypoint = nil
FyrMM.IsRally = false
FyrMM.Rally = nil
FyrMM.IsPing = false
FyrMM.Ping = nil
FyrMM.OverMiniMap = false
FyrMM.OverMenu = false
FyrMM.MenuFadingIn = false
FyrMM.MenuFadingOut = false
FyrMM.DisableSubzones = false
FyrMM.Halted = false
FyrMM.HaltTimeOffset = 0
FyrMM.LastReload = 0
FyrMM.DebugMode = false
FyrMM.MapAPI0Present = false
FyrMM.FadingEdges = false
FyrMM.KeepRefreshNeeded = true
FyrMM.GroupRefreshNeeded = true
FyrMM.CustomPinCount = 0
FyrMM.AvailableQuestGivers = {}

FYRMM_ZOOM_MAX = 50
FYRMM_ZOOM_MIN = 1
FYRMM_DEFAULT_ZOOM_LEVEL = 10
FYRMM_ZOOM_INCREMENT_AMOUNT = nil
FYRMM_QUEST_PIN_REQUEST_TIMEOUT = 10000 -- Time in miliseconds to wait for quest pin data
FYRMM_QUEST_PIN_REQUEST_MINIMUM_DELAY = 1000 -- Time in miliseconds to be passed before requesting quest pins again

MM_GetNumMapLocations = GetNumMapLocations -- Location pin count
MM_IsMapLocationVisible = IsMapLocationVisible -- is Location visible
MM_GetMapLocationIcon = GetMapLocationIcon -- Location pin texture
MM_GetNumPOIs = GetNumPOIs -- POI pin count
MM_GetPOIMapInfo = GetPOIMapInfo -- POI pin info

local QuestPins = {}
local RequestedQuestPins = {}
local FreeQuestPinIndex = {}
local CurrentTasks = {}
local NeedQuestPinUpdate = true
local QuestPinsUpdating = false
local QuestTasksPending = false
local CustomPinsCopying = false
local PinRef = nil
local PRCustomPins = nil
local PRMap = nil
local LastQuestPinIndex = 0
local CurrentMap = FyrMM.currentMap
local CurrentMapId = 0
local CurrentTasks = CurrentTasks
local CWSTimeStamp = 0
local AQGTimeStamp = 0
local CleanPOIs = 0
local CustomPinIndex = {}
 FyrMM.CustomPinKeyIndex = {}
local FreeCustomPinIndex = {}
local LastCustomPinIndex = 0
local CustomPinMapId = 0
local PinsList = {}
local PinsIndex = {}
local Wayshrines = {}
local WayshrineDistancesTimStamp  = 0
local KeepIndex = {}
local PositionLog = {}
local PositionLogCounter = 0
local Treasures = {}
local AQGList = {}
local AQGListFull = {}
local wuthreads = 0
local ruthreads = 0
local MenuAnimation
local wrc = 0
local mapContentType = 0
local pinData = ZO_MapPin.PIN_DATA
local pi = math.pi
local AVA_OBJECTIVE_PINS_WITH_ARROWS =
{	
	[MAP_PIN_TYPE_FLAG_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_FLAG_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_FLAG_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_FLAG_NEUTRAL] = true,
	[MAP_PIN_TYPE_BALL_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_BALL_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_BALL_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_BALL_NEUTRAL] = true,	   
}

local ASSISTED_PIN_TYPES =
{
	[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = true,
	[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = true,
	[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = true,
}

local QUEST_PIN_TYPES =
{
	[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = true,
	[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = true,
	[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = true,
	[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = true,
	[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = true,
	[MAP_PIN_TYPE_TRACKED_QUEST_ENDING] = true,
}

local questPinTextures =
{
	[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon_assisted.dds",
	[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon_assisted.dds",
	[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon_assisted.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon.dds",
}

local breadcrumbQuestPinTextures =
{
	[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
	[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
	[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon_door_assisted.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon_door.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon_door.dds",
	[MAP_PIN_TYPE_TRACKED_QUEST_ENDING] = "EsoUI/Art/Compass/quest_icon_door.dds",
}

local CustomWaypoints =
{
	[MAP_PIN_TYPE_PING] = true,
	[MAP_PIN_TYPE_RALLY_POINT] = true,
	[MAP_PIN_TYPE_PLAYER_WAYPOINT] = true,
}
----------------------------------------------------------------

local function GetQuestPinCount()
--	local count = 0
--	local l
--	for i  = 1, Fyr_MM_Scroll_Map_QuestPins:GetNumChildren()+100 do
--		l = GetControl("Fyr_MM_Scroll_Map_QuestPins_Pin"..tostring(i))
--		if l ~= nil then
--			if l.m_PinTag ~= nil then
--				count = count + 1
--			end
--		end
--	end
	return FyrMM.questPinCount
end

local function AvailableCustomPins()
	local count = 0
	for i, b in pairs (FyrMM.CustomPinList) do
		count = count + #b
	end
	return count
end

local function IsCustomPinsLoading()
	for i, b in pairs (FyrMM.LoadingCustomPins) do
		if b then return b end
	end
	return false
end

local function GetQuestFreePinIndex()
	local index = LastQuestPinIndex
	if not table.empty(FreeQuestPinIndex) then
		for i, n in pairs(FreeQuestPinIndex) do
			index = n
			FreeQuestPinIndex[i] = nil
			return index
		end
	end
	index = index + 1
	LastQuestPinIndex = index
	return index
end

FyrMM.RequestJournalQuestConditionAssistance = RequestJournalQuestConditionAssistance
function RequestJournalQuestConditionAssistance(questIndex, stepIndex, conditionIndex, assisted)
	local taskId = FyrMM.RequestJournalQuestConditionAssistance(questIndex, stepIndex, conditionIndex, assisted)
	local tag = ZO_MapPin.CreateQuestPinTag(questIndex, stepIndex, conditionIndex)
	if GetGameTimeMilliseconds() - FyrMM.LastQuestPinRequest > FYRMM_QUEST_PIN_REQUEST_MINIMUM_DELAY then
		FyrMM.questPinCount = GetQuestPinCount()
		QuestPinsUpdating = true
	end
	if taskId ~= nil and not FyrMM.Halted then
		FyrMM.LastQuestPinRequest = GetGameTimeMilliseconds()
		CurrentTasks[taskId] = {}
		CurrentTasks[taskId] = tag
		CurrentTasks[taskId].RequestTimeStamp = FyrMM.LastQuestPinRequest
		CurrentTasks[taskId].MapId = FyrMM.GetMapId()
		CurrentTasks[taskId].Fetched = true
		CurrentTasks[taskId].ZO_MapVisible = ZO_WorldMap:IsHidden()
	end
	return taskId
end

-----------------------------------------------------------------
-- Utility functions
-----------------------------------------------------------------
function table.empty (self)
	for _, _ in pairs(self) do
		return false
	end
	return true
end

local function CancelUpdates()
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapDelayedRegister")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapZoneCheck")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapPOIPins")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapLocationsPins")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapWayshrinesPins")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapCustomPins")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapPOIPinsD")
	EVENT_MANAGER:UnregisterForUpdate("OnFyrMiniMapInitialPreload")
	EVENT_MANAGER:UnregisterForUpdate("OnFyrMiniMapCustomPinGroupAll")
	FyrMM.UpdatingCustomPins = {}
	FyrMM.LoadingCustomPins = {}
	if PinRef ~= nil then
		for i, n in pairs(PRCustomPins) do
			if i > MAP_PIN_TYPE_INVALID then
				EVENT_MANAGER:UnregisterForUpdate("OnFyrMiniMapCustomPinGroup"..tostring(i))
			end
		end
	end
end

local function IsCurrentLocation(pin)
	if pin == nil then return end
	local x, y, _ = GetMapPlayerPosition("player")
	local nX, nY
	if pin.normalizedX ~= nil and pin.normalizedY ~= nil then
		nX = pin.normalizedX
		nY = pin.normalizedY
	end
	if pin.nX ~= nil and pin.nY ~= nil then
		nX = pin.nX
		nY = pin.nY
	end
	if nX ~= nil and nY ~= nil and CurrentMap.TrueMapSize ~= nil then
		local distance = zo_round(CurrentMap.TrueMapSize*math.sqrt((x-nX)*(x-nX)+(y-nY)*(y-nY))*7.55)/10 -- assumed size is 1.325 times larger than approximate effective skill distance in meters.
		local message = GetString(SI_MM_STRING_DISTANCE).." "..tostring(distance).." m"
		if not InformationTooltip:IsHidden() then
			InformationTooltip:AddLine(message, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
		end
		if not ZO_MapLocationTooltip:IsHidden() then
			ZO_MapLocationTooltip:AddLine(message, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
		end
		return CurrentMap.TrueMapSize*math.sqrt((x-nX)*(x-nX)+(y-nY)*(y-nY)) < 14 -- Approximate distance to use a wayshrine
	else
		return false
	end
end

 local function IsCraftingService(pin)
	if not pin then return false end
	local pos = nil
	local text, ntl, n, _
	if pin.locationIndex then
		ntl = GetNumMapLocationTooltipLines(pin.locationIndex)
		for i, v in pairs(FyrMM.CSProviders) do
			if v ~= nil then
				for j =1, ntl do
					_, n, _, _ = GetMapLocationTooltipLineInfo(pin.locationIndex, j)
					pos = select(2, n:find(v))
					if pos ~= nil then return true end
				end
			end
		end
	end
	return false
end

local function SetTooltipMessage(pin)
	if pin:IsFastTravelWayShrine() then
		local nodeIndex = pin:GetFastTravelNodeIndex()
		local known, name = GetFastTravelNodeInfo(nodeIndex)
		if not known then name = name.." (undiscovered)" end
		InformationTooltip:AddLine(zo_strformat(SI_WORLD_MAP_LOCATION_NAME, name), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()) -- Wayshrine name
		if IsCurrentLocation(pin) then
			InformationTooltip:AddLine(GetString(SI_TOOLTIP_WAYSHRINE_CURRENT_LOC), "", ZO_HIGHLIGHT_TEXT:UnpackRGB()) -- Player is near wayshrine
		else				
			if IsInCyrodiil() then
				InformationTooltip:AddLine(GetString(SI_TOOLTIP_WAYSHRINE_CANT_RECALL_AVA), "", ZO_ERROR_COLOR:UnpackRGB()) -- Can't travel to a wayshrine in Cyrodiil
			else
				local _, premiumTimeLeft = GetRecallCooldown()
				if premiumTimeLeft == 0 then
					InformationTooltip:AddLine(GetString(SI_TOOLTIP_WAYSHRINE_CLICK_TO_RECALL), "", ZO_HIGHLIGHT_TEXT:UnpackRGB()) -- Recall text line
					local cost = GetRecallCost()
					if cost > 0 then
						if cost <= GetCurrentMoney() then
							ZO_ItemTooltip_AddMoney(InformationTooltip, cost, SI_TOOLTIP_RECALL_COST, CURRENCY_HAS_ENOUGH)
						else
							ZO_ItemTooltip_AddMoney(InformationTooltip, cost, SI_TOOLTIP_RECALL_COST, CURRENCY_NOT_ENOUGH)
						end
					end
				else
					local cooldownText = zo_strformat(SI_TOOLTIP_WAYSHRINE_RECALL_COOLDOWN, ZO_FormatTimeMilliseconds(premiumTimeLeft, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS))
			InformationTooltip:AddLine(cooldownText, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
			end
			end
		end
	else
		local poiIndex = pin:GetPOIIndex()
		local zoneIndex = pin:GetPOIZoneIndex()
		local poiName, _, poiStartDesc, poiFinishedDesc = GetPOIInfo(zoneIndex, poiIndex)
		InformationTooltip:AddLine(zo_strformat(SI_WORLD_MAP_LOCATION_NAME, poiName), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()) 
		local pinType = select(3, MM_GetPOIMapInfo(zoneIndex, poiIndex))
		if not (ZO_MapPin.POI_PIN_TYPES[pinType]) then InformationTooltip:AddLine("(undiscovered)", "", ZO_HIGHLIGHT_TEXT:UnpackRGB()) end
		if pinType == MAP_PIN_TYPE_POI_COMPLETE then
			if poiFinishedDesc ~= "" then
				InformationTooltip:AddLine(poiFinishedDesc, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
			end
		else
			if poiStartDesc ~= "" then
				InformationTooltip:AddLine(poiStartDesc, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
			end
		end
	end
end

 function GetCurrentMapTextureFileInfo()
	local tileTexture = (GetMapTileTexture()):lower()
	if tileTexture == nil or tileTexture == "" then
		return "tamriel_0", "tamriel_", "art/maps/tamriel/"
	end
	local pos = select(2,tileTexture:find("maps/([%w%-]+)/"))
	if pos == nil then
		return "tamriel_0", "tamriel_", "art/maps/tamriel/"
	end
	pos = pos + 1
	return string.gsub(string.sub(tileTexture, pos),".dds",""), string.gsub(string.sub(tileTexture, pos),"0.dds",""), string.sub(tileTexture, 1, pos - 1)
end

local function GetMapId()
	local _, pos, tileTexture, map
	tileTexture = (GetMapTileTexture()):lower()
	pos = select(2,tileTexture:find("maps/([%w%-]+)/"))
	if pos == nil then return FyrMM.GetMapId() end
	map = string.gsub(string.sub(tileTexture, pos + 1),".dds","")
	if FyrMM.MapList then
		if FyrMM.MapList[map] then
			return FyrMM.MapList[map]
		end
	end
	return "unknown"
end

local function GetTrueMapSize()
	local _, pos, tileTexture, map
	tileTexture = (GetMapTileTexture()):lower()
	pos = select(2,tileTexture:find("maps/([%w%-]+)/"))
	if pos == nil then return "unknown", 1 end
	map = string.gsub(string.sub(tileTexture, pos + 1),".dds","")
	if FyrMM.MapList and FyrMM.MapData then
		if FyrMM.MapList[map] then
			local id = FyrMM.MapList[map]
			if FyrMM.MapData[id] then
				return FyrMM.MapList[map], FyrMM.MapData[id][5]
			end
		end
	end
	return "unknown", 1
end

function FyrMM.GetMapId(map)
	local _, pos, tileTexture
	if map == nil and CurrentMap.MapId ~= nil then
		return CurrentMap.MapId
	end
	if map == nil then
		if CurrentMap.filename then
			map = CurrentMap.filename
		else
			tileTexture = (GetMapTileTexture()):lower()
			pos = select(2,tileTexture:find("maps/([%w%-]+)/"))
			map = string.gsub(string.sub(tileTexture, pos + 1),".dds","")
		end
	end
	if FyrMM.MapList then
		if FyrMM.MapList[map] then
			return FyrMM.MapList[map]
		end
	end
	return "unknown"
end

local function SetMapToZone()
	if FyrMM.DisableSubzones == true and GetMapType() == 1 then
		MapZoomOut()
	end
end

function FyrMM.MapHalfDiagonal()
	local x1 = Fyr_MM_Player:GetRight() local y1 = Fyr_MM_Player:GetTop()
	local x2 = Fyr_MM:GetRight() local y2 = Fyr_MM:GetTop()
	FyrMM.DiagonalND = math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2))
	return FyrMM.DiagonalND
end

local function IsSubmap()
	return GetMapContentType() == MAP_CONTENT_DUNGEON or GetMapType() == MAPTYPE_SUBZONE
end

local function GetQuestJournalMaxValidIndex()
	local index = 0
	for i = 1, MAX_JOURNAL_QUESTS do
		if(IsValidQuestIndex(i)) and index < i then
			index = i
		end
	end
	return index
end

local function IsAssisted(pinType)
	local function check(i)
		return ASSISTED_PIN_TYPES[i]
	end
	if pinType then
		if check(pinType) then
			return true
		else
			return false
		end
	end
	return false
end

local function IsQuestType(pinType)
	local function check(i)
		return QUEST_PIN_TYPES[i]
	end
	if check(pinType) then
		return true
	else
		return false
	end
end

local function valueExists(i, x)
	for _, v in ipairs(x) do
		if v == i then
			return true
		end
	end
	return false
end

local function questpinDataExists(pinData, array)
	for i, v in pairs(array) do
		if v.questIndex == pinData.questIndex and v.questName == pinData.questName and v.coditionText == pinData.coditionText and v.stepIndex == pinData.stepIndex and v.stepIndex == pinData.stepIndex and v.conditionIndex == pinData.conditionIndex
			and v.normalizedX == pinData.normalizedX and v.normalizedY == pinData.normalizedY and v.areaRadius == pinData.areaRadius then
			return i
		end
	end
	return nil
end


local function questpinDataCount()
	local count = 0
	for i, v in pairs(QuestPins) do
		count = count + 1
	end
	return count
end

function FyrMM.SetTargetScale(pin, targetScale)
	if pin == nil or targetScale == nil then return end
	if((pin.targetScale ~= nil and targetScale ~= pin.targetScale) or (pin.targetScale == nil and targetScale ~= pin:GetScale())) then
		pin.targetScale = targetScale
		for i=1, 50 do
			zo_callLater(function() if pin == nil or pin.targetScale == nil then return end local newScale = zo_deltaNormalizedLerp(pin:GetScale(), pin.targetScale, 0.1)
			if(zo_abs(newScale - pin.targetScale) < 0.01) then
				pin:SetScale(pin.targetScale)
				if pin.primaryPin ~= nil then
					pin.primaryPin:SetScale(pin.targetScale)
				end
				if pin.secondaryPin ~= nil then
					pin.secondaryPin:SetScale(pin.targetScale)
				end
				if pin.tertiaryPin ~= nil then
					pin.tertiaryPin:SetScale(pin.targetScale)
				end
				pin.targetScale = nil				
			else
				pin:SetScale(newScale)
				if pin.primaryPin ~= nil then
					pin.primaryPin:SetScale(newScale)
				end
				if pin.secondaryPin ~= nil then
					pin.secondaryPin:SetScale(newScale)
				end
				if pin.tertiaryPin ~= nil then
					pin.tertiaryPin:SetScale(newScale)
				end
				end end, i*5)
		end
	end
end

local function AfterCombatShow()
	if not FyrMM.AfterCombatUnhidePending then return end
	if GetFrameTimeMilliseconds() - FyrMM.AfterCombatUnhideTimeStamp < 1000 * (FyrMM.SV.AfterCombatUnhideDelay -1) then return end
	FyrMM.AfterCombatUnhidePending = false
	if not IsUnitInCombat("player") then FyrMM.AutoHidden = false FyrMM.Visible = true end
end

local function WayshrineDistances(nDistance)
	if not (FyrMM.SV.BorderPins and FyrMM.SV.BorderWayshrine) or FyrMM.currentWayshrineCount == 0 then return end
	if CurrentMap.movedTimeStamp == WayshrineDistancesTimeStamp and WayshrineDistancesTimeStamp ~= 0 then return end
	local t = GetGameTimeMilliseconds()
	WayshrineDistancesTimeStamp = CurrentMap.movedTimeStamp
	local wDi = 1
	local wDmi = 1
	local minWD = 1
	local owDmi = 1
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "WayshrineDistances Start:"..tostring(FyrMM.currentWayshrineCount))
	if FyrMM.currentWayshrineCount == 1 then Wayshrines[1].Closest = true return end
	EVENT_MANAGER:RegisterForUpdate("OnFyrMiniMapDistances", 50, function()
		local x = CurrentMap.PlayerNX
		local y = CurrentMap.PlayerNY
		if Wayshrines[wDi] ~= nil then
			Wayshrines[wDi].nDistance = math.sqrt((x-Wayshrines[wDi].nX)*(x-Wayshrines[wDi].nX)+(y-Wayshrines[wDi].nY)*(y-Wayshrines[wDi].nY))
			if Wayshrines[wDi].nDistance < minWD then
				minWD = Wayshrines[wDi].nDistance
				wDmi = wDi
			end	
		end
		if wDi <= FyrMM.currentWayshrineCount then
			wDi = wDi + 1
		else
			for i, p in pairs(Wayshrines) do
				if i ~= wDmi then
					Wayshrines[i].Closest = false
					Wayshrines[i].pin.Closest = false
				else
					Wayshrines[i].pin.Closest = true
					Wayshrines[i].Closest = true
				end
			end
			CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "WayshrineDistances Done. ("..tostring(wDmi)..") "..tostring(GetGameTimeMilliseconds()-t))
			EVENT_MANAGER:UnregisterForUpdate("OnFyrMiniMapDistances")
		end
	end)
end

local function sort(a,b)
	if type(a.index)=="number" and type(b.index)=="number" then return a.index<b.index end
	if type(a.index)=="number" and type(b.index)~="number" then return true end
	if type(a.index)~="number" and type(b.index)=="number" then return false end
	return a.index and b.index and tostring(a.index) < tostring(b.index)
end

local function FirstKey(Table, offset)
	if table.empty(Table) then return nil end
	if offset == nil then offset = 0 end
	for key = offset, 1000 do
		if Table[key] ~= nil then
			return key
		end
	end
	return nil
end

local function QuestGiverDistances()
	if not (FyrMM.SV.BorderPins and FyrMM.SV.BorderQuestGivers) or #FyrMM.AvailableQuestGivers == 0 then return end
	local t = GetGameTimeMilliseconds()
	local x, y, _, minDistance, minId
	local key = 0
	if CurrentMap.PlayerNX ~= nil and CurrentMap.PlayerNY ~= nil and not Fyr_MM:IsHidden() then
		x = CurrentMap.PlayerNX
		y = CurrentMap.PlayerNY
	else
		x, y, _ = GetMapPlayerPosition("player")
	end
    AQGListFull = {}
	AQGList = {}
	local multiplier = Fyr_MM:GetWidth()
	for i, v in pairs(FyrMM.AvailableQuestGivers) do 
		if v.nX ~= nil and v.nY ~= nil then
            v.nDistance = math.sqrt((x-v.nX)*(x-v.nX)+(y-v.nY)*(y-v.nY))
			table.insert(AQGListFull, {index = math.floor(multiplier*v.nDistance), data = v, })
		end
	end
    local count = 0
	table.sort(AQGListFull, sort)
	for i, n in ipairs(AQGListFull) do
		count = count + 1
		if count > 5 then
			CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "QuestGiverDistances "..tostring(GetGameTimeMilliseconds()-t))
			 return
		end
		table.insert(AQGList, n.data)
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "QuestGiverDistances "..tostring(GetGameTimeMilliseconds()-t))
end

function FyrMM.MenuTooltip(button, message)
	--Fyr_MM_Menu:SetAlpha(1)
	FyrMM.OverMenu = true
	Fyr_MM_Close:SetAlpha(1)
	if message == nil or message == "" or button == nil then return end
	InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 38, button:GetTop())
	InformationTooltip:AddLine(message, "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
end

function FyrMM.TooltipExit()
	FyrMM.OverMenu = false
	--Fyr_MM_Menu:SetAlpha(0.1)
	Fyr_MM_Close:SetAlpha(0)
	ClearTooltip(InformationTooltip)
end

function FyrMM.PinToggle(value)
	MM_SetLockPosition(value)
	MM_RefreshPanel()
end

function FyrMM.OpenSettingsPanel()
	FyrMM.LAM:OpenToPanel(FyrMM.CPL)
end

function FyrMM.API_Check()
	if FyrMM.SV.UseOriginalAPI then -- if Zygor is active and original functions to be used
		if _IsMapLocationVisible then
			MM_IsMapLocationVisible = _IsMapLocationVisible
		end
		if _GetMapLocationIcon then
			MM_GetNumMapLocations = _GetNumMapLocations
		end
		if _GetMapLocationIcon then
			MM_GetMapLocationIcon = _GetMapLocationIcon
		end
		if _GetPOIMapInfo_ORIG_ZGV then
			MM_GetPOIMapInfo = _GetPOIMapInfo_ORIG_ZGV
		end
		if _0GetNumMapLocations ~= nil then
			FyrMM.MapAPI0Present = true
			MM_GetNumMapLocations = _0GetNumMapLocations
		end
		if _0IsMapLocationVisible ~= nil then
			MM_IsMapLocationVisible = _0IsMapLocationVisible
		end
		if _0GetMapLocationIcon ~= nil then
			MM_GetMapLocationIcon = _0GetMapLocationIcon
		end
		if _0GetNumPOIs ~= nil then
			MM_GetNumPOIs = _0GetNumPOIs
		end
		if _0GetPOIMapInfo ~= nil then
			MM_GetPOIMapInfo = _0GetPOIMapInfo
		end
	else
		MM_GetNumMapLocations = GetNumMapLocations
		MM_IsMapLocationVisible = IsMapLocationVisible
		MM_GetMapLocationIcon = GetMapLocationIcon
		MM_GetPOIMapInfo = GetPOIMapInfo
	end
end

function GetCurrentMapSize() -- Returns calculated map size in assumed feet, returns nil if size is not yet calculated, or it is not possible to do so
	if CurrentMap then
		return CurrentMap.TrueMapSize
	else return nil end
end

local function GetRotatedPosition(x, y) -- Inspired by DeathAngel's RadarMiniMap
	if CurrentMap.Heading == nil then return end
	local  mWidth, mHeight = Fyr_MM_Scroll_Map:GetDimensions()
	if CurrentMap.Heading == nil then return end
	if x and CurrentMap.PlayerX then
	local ix = (x * mWidth) - CurrentMap.PlayerX
	local iy = (y * mHeight) - CurrentMap.PlayerY
	local rx = (math.cos(-CurrentMap.Heading) * ix) - (math.sin(-CurrentMap.Heading) * iy)
	local ry = (math.sin(-CurrentMap.Heading) * ix) + (math.cos(-CurrentMap.Heading) * iy)
	return zo_round(rx), zo_round(ry)
	end
	return x, y
end

local function GetNorthFacingPosition(x, y)
	local  mWidth, mHeight = Fyr_MM_Scroll_Map:GetDimensions()
	if x and y then
		return zo_round(mWidth * x), zo_round(mHeight * y)
	else
		return x, y
	end
end

local function Is_PinInsideWheel(pin)
	if pin.nX == nil and pin.nY == nil and pin.normalizedX == nil and pin.normalizedY == nil then return false end
	local di = Fyr_MM:GetWidth()
	local x = (pin:GetRight()+pin:GetLeft())/2
	local y = (pin:GetTop()+pin:GetBottom())/2
	local x1 = (Fyr_MM_Player:GetRight()+Fyr_MM_Player:GetLeft())/2
	local y1 = (Fyr_MM_Player:GetBottom()+Fyr_MM_Player:GetTop())/2
	if pin.areaRadius ~= nil then
		if pin.areaRadius > 0 then
			return math.sqrt((x-x1)*(x-x1)+(y-y1)*(y-y1)) < di/2 - ((30 / 512) * di) + pin:GetWidth()/2 - 10
		end
	end
	return math.sqrt((x-x1)*(x-x1)+(y-y1)*(y-y1)) < di/2 - ((30 / 512) * di) 
end

local function SetPinFunctions(pin)
	if pin.UpdateWheelVisibility == nil then
		pin.UpdateWheelVisibility = function(self) if FyrMM.SV.WheelMap then self:SetHidden(not Is_PinInsideWheel(self)) end end
	end
	if pin.RefreshAnchor == nil then
		pin.RefreshAnchor = function(self) local x, y
			if self.nX ~= nil and self.nY ~= nil then
				x = self.nX
				y = self.nY
			end
			if self.normalizedX ~= nil and self.normalizedY ~= nil then
				x = self.normalizedX
				y = self.normalizedY
			end
			if x~= nil and y ~= nil then
				self:ClearAnchors()
				if FyrMM.SV.RotateMap then
					self:SetAnchor(CENTER, Fyr_MM_Scroll, CENTER, GetRotatedPosition(x, y))
				else
					self:SetAnchor(CENTER, self:GetParent(), TOPLEFT, GetNorthFacingPosition(x, y))
				end
			end
		end
	end
end

function FyrMM.AxisPosition(a)
	local mmWidth, mmHeight = Fyr_MM:GetDimensions()
	if mmWidth == nil then mmWidth = FyrMM.SV.MapWidth end
	if mmHeight == nil then mmHeight = FyrMM.SV.MapHeight end

	local piHalf = pi * 0.5
	local piDoub = pi * 2.0

	mmWidth = mmWidth/2
	mmHeight = mmHeight/2

	local na = math.atan((mmWidth)/(mmHeight))
	local nb = piHalf - na
	local npos, epos, spos, wpos

	local nbX2 = nb*2
	local aMna = a - na
	local aPna = a + na

	if aPna >= piDoub or aMna <= 0 then -- upper border line
		if aMna <= 0 then
			npos = mmWidth + mmHeight * math.sin(a) / math.sin(piHalf - a)
		else
			npos = mmWidth - mmHeight * math.sin(piDoub - a) / math.sin(piHalf - (piDoub - a))
		end
		return npos, 0
	end
	if aMna > 0 and aMna < nbX2 then -- right border line
		if aMna > nb then
			epos = mmHeight + mmWidth * math.sin(aMna - nb) / math.sin(piHalf - (aMna - nb))
		else
			epos = mmWidth * math.sin(aMna) / math.sin(piHalf - (aMna))
		end
		return mmWidth*2, epos
	end
	if aMna >= nbX2 and a <= 3 * na + nbX2 then -- bottom border line
		if aMna - na > nbX2 then
			spos = mmWidth - mmHeight * math.sin(a - 2 * na - nbX2) / math.sin(piHalf - (a - 2 * na - nbX2))
		else
			spos = mmWidth*2 - mmHeight * math.sin(aMna - nbX2) / math.sin(piHalf - (aMna - nbX2))
		end
		return spos, mmHeight*2
	end
	if aPna > piDoub - nbX2 and aPna < piDoub then -- left border line
		if aMna > nb then
			wpos = mmHeight - mmWidth * math.sin(a - 3 * na - 3 * nb) / math.sin(piHalf - (a - 3 * na - 3 * nb))
		else
			wpos = mmHeight - mmWidth * math.sin(a - 3 * na - nbX2) / math.sin(piHalf - (a - 3 * na - nbX2))
		end
		return 0, wpos
	end
end

local function RoundArc(angle)
	if angle > pi * 2 then angle = angle - pi * 2 end
	return angle
end

local function AxisSwitch()
	for i =1, Fyr_MM_Axis_Textures:GetNumChildren() do
		local l = Fyr_MM_Axis_Textures:GetChild(i)
		if l ~= nil then
			l:ClearAnchors()
			l:SetHidden(FyrMM.SV.WheelMap or not FyrMM.SV.RotateMap)
			l:SetDimensions(20, 20)
		end
	end
	for i =1, Fyr_MM_Axis_Labels:GetNumChildren() do
		local l = Fyr_MM_Axis_Labels:GetChild(i)
		if l ~= nil then
			l:ClearAnchors()
			l:SetHidden(FyrMM.SV.WheelMap or not FyrMM.SV.RotateMap)
		end
	end
end

function FyrMM.AxisPins()
	if (FyrMM.SV.WheelMap and not Fyr_MM_Axis_N:IsHidden()) or not (FyrMM.SV.RotateMap and not Fyr_MM_Axis_N:IsHidden()) then
		AxisSwitch()
		return
	end
	if not FyrMM.SV.RotateMap or not CurrentMap.Heading then return end
	--Fyr_MM_Axis_Control:SetTopmost(true)

	local n = pi * 2  - CurrentMap.Heading
	local ne = RoundArc(n + pi * 0.25)
	local e = RoundArc(n + pi * 0.5)
	local se = RoundArc(n + pi * 0.75)
	local s = RoundArc(n + pi)
	local sw = RoundArc(n + pi * 1.25)
	local w = RoundArc(n + pi * 1.5)
	local nw = RoundArc(n + pi * 1.75)

	Fyr_MM_Axis_N:ClearAnchors()
	Fyr_MM_Axis_N_Label:ClearAnchors()
	Fyr_MM_Axis_N:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(n))
	Fyr_MM_Axis_N_Label:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(n))

	Fyr_MM_Axis_NE:ClearAnchors()
	Fyr_MM_Axis_NE_Label:ClearAnchors()
	Fyr_MM_Axis_NE:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(ne))
	Fyr_MM_Axis_NE_Label:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(ne))

	Fyr_MM_Axis_E:ClearAnchors()
	Fyr_MM_Axis_E_Label:ClearAnchors()
	Fyr_MM_Axis_E:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(e))
	Fyr_MM_Axis_E_Label:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(e))
	
	Fyr_MM_Axis_SE:ClearAnchors()
	Fyr_MM_Axis_SE_Label:ClearAnchors()
	Fyr_MM_Axis_SE:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(se))
	Fyr_MM_Axis_SE_Label:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(se))

	Fyr_MM_Axis_S:ClearAnchors()
	Fyr_MM_Axis_S_Label:ClearAnchors()
	Fyr_MM_Axis_S:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(s))
	Fyr_MM_Axis_S_Label:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(s))

	Fyr_MM_Axis_SW:ClearAnchors()
	Fyr_MM_Axis_SW_Label:ClearAnchors()
	Fyr_MM_Axis_SW:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(sw))
	Fyr_MM_Axis_SW_Label:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(sw))

	Fyr_MM_Axis_W:ClearAnchors()
	Fyr_MM_Axis_W_Label:ClearAnchors()
	Fyr_MM_Axis_W:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(w))
	Fyr_MM_Axis_W_Label:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(w))

	Fyr_MM_Axis_NW:ClearAnchors()
	Fyr_MM_Axis_NW_Label:ClearAnchors()
	Fyr_MM_Axis_NW:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(nw))
	Fyr_MM_Axis_NW_Label:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, FyrMM.AxisPosition(nw))
end

local function IsCoordinateInRange(x, y)
	if not CurrentMap.TrueMapSize or not CurrentMap.PlayerNX or not FyrMM.SV.CustomPinViewRange or not FyrMM.SV.ViewRangeFiltering then return true end
	return CurrentMap.TrueMapSize * math.sqrt((x-CurrentMap.PlayerNX)*(x-CurrentMap.PlayerNX)+(y-CurrentMap.PlayerNY)*(y-CurrentMap.PlayerNY)) <= FyrMM.SV.CustomPinViewRange
end

function FyrMM.SetPinSize(pin, size, _)
	local properSize = math.floor(size/2)*2
	pin:SetDimensions(properSize, properSize)
end

function FyrMM.SetPinAnchor(pin, x, y, AnchorToControl, hidden)
	local newX, newY, currentX, currentY, currentObject, _
	if pin == nil then return end
	SetPinFunctions(pin)
	if pin.nX == nil and pin.nY == nil and pin.normalizedX == nil and pin.normalizedY == nil then
		PinsList[pin:GetName()] = nil
		pin:ClearAnchors()
		pin:SetHidden()
		return
	end
	if x and y and AnchorToControl then
		_, _, currentObject, _, currentX, currentY = pin:GetAnchor()
		if PinsList[pin:GetName()] == nil then
			PinsList[pin:GetName()] = pin
		end
		if FyrMM.SV.RotateMap then
			newX, newY = GetRotatedPosition(x, y)
			AnchorToControl = Fyr_MM_Scroll
		else
			newX, newY = GetNorthFacingPosition(x, y)
		end
		if newX ~= currentX or newY ~= currentY or currentObject ~= AnchorToControl then
			pin:ClearAnchors()
			if FyrMM.SV.RotateMap then
				pin:SetAnchor(CENTER, AnchorToControl, CENTER, newX, newY)
			else
				pin:SetAnchor(CENTER, AnchorToControl, TOPLEFT, newX, newY)
			end
		end
	end
	if hidden then
		pin:SetHidden(true)
	else
		if FyrMM.SV.WheelMap and x ~= nil and y ~= nil then
			pin:SetHidden(not Is_PinInsideWheel(pin))
		end
	end
end

local function RescaleLinks()
	if not IsInCyrodiil() then return end
	local  mWidth, mHeight = Fyr_MM_Scroll_Map:GetDimensions()
	local Count, l, startX, startY, endX, endY
	for i=1, 100 do
		l = GetControl("Fyr_MM_Scroll_Map_Links_Link"..tostring(i))
		if l ~= nil then
			if FyrMM.SV.WheelMap then
				l:SetParent(Fyr_MM_Scroll_CW_Map_Pins)
			else
				l:SetParent(Fyr_MM_Scroll_Map_Links)
			end
			if FyrMM.SV.RotateMap then
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.startNX, l.startNY))
				l:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.endNX, l.endNY))
			else
				startX, startY, endX, endY = l.startNX * mWidth - mWidth/2, l.startNY * mHeight -mHeight/2, l.endNX * mWidth - mWidth/2, l.endNY * mHeight -mHeight/2
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll_Map_Links, CENTER, zo_round(startX), zo_round(startY) )
				l:SetAnchor(BOTTOMRIGHT , Fyr_MM_Scroll_Map_Links, CENTER, zo_round(endX),  zo_round(endY))
			end
		else
			i = 99
		end
		l = GetControl("Fyr_MM_Scroll_Map_LinksNS_Link"..tostring(i))
		if l ~= nil then
			if FyrMM.SV.RotateMap then
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.startNX, l.startNY))
				l:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.endNX, l.endNY))
			else
				startX, startY, endX, endY = l.startNX * mWidth - mWidth/2, l.startNY * mHeight -mHeight/2, l.endNX * mWidth - mWidth/2, l.endNY * mHeight -mHeight/2
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll_Map_Links, CENTER, zo_round(startX), zo_round(startY) )
				l:SetAnchor(BOTTOMRIGHT , Fyr_MM_Scroll_Map_Links, CENTER, zo_round(endX),  zo_round(endY))
			end
		end
		l = GetControl("Fyr_MM_Scroll_Map_LinksWE_Link"..tostring(i))
		if l ~= nil then
			if FyrMM.SV.RotateMap then
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.startNX, l.startNY))
				l:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.endNX, l.endNY))
			else
				startX, startY, endX, endY = l.startNX * mWidth - mWidth/2, l.startNY * mHeight -mHeight/2, l.endNX * mWidth - mWidth/2, l.endNY * mHeight -mHeight/2
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll_Map_Links, CENTER, zo_round(startX), zo_round(startY) )
				l:SetAnchor(BOTTOMRIGHT , Fyr_MM_Scroll_Map_Links, CENTER, zo_round(endX),  zo_round(endY))
			end
		end
	end
end

local function UpdateWheelPins()
	if Fyr_MM:IsHidden() then return end
	local RotateMap = FyrMM.SV.RotateMap
	local WheelMap = FyrMM.SV.WheelMap
	if RotateMap or WheelMap then
		for i,v in pairs(PinsList) do
			if WheelMap then
				v:UpdateWheelVisibility()
			end
			if RotateMap then
				if not v:IsHidden() or v.BorderPin ~= nil then
					v:RefreshAnchor()
				end
			end
		end
		RescaleLinks()
	end
end

function FyrMM.RegisterRWUpdates()
	EVENT_MANAGER:RegisterForUpdate("FyrMiniMapRWUpdate", 100, UpdateWheelPins)
end

function FyrMM.UnRegisterRWUpdates()
	EVENT_MANAGER:UnRegisterForUpdate("FyrMiniMapRWUpdate")
end

local function UpdateCustomPinPositions()
	if not FyrMM.Visible or Fyr_MM:IsHidden() or not ZO_WorldMap:IsHidden() or CustomPinsCopying then return end
	local currentZone = FyrMM.GetMapId()
	local mWidth, mHeight = Fyr_MM_Scroll_Map:GetDimensions()
	local enabled
	for i, p in pairs(PinsList) do
		if p ~= nil then
			if p.m_PinType ~= nil then
				if p.m_PinType >= MAP_PIN_TYPE_INVALID then
					if PinRef ~= nil then
						if PRCustomPins ~= nil then
							enabled = PRCustomPins[p.m_PinType].enabled
						end
					else		
						enabled =  ZO_WorldMap_IsCustomPinEnabled(p.m_PinType)
					end
					if p.nX ~= nil and p.nY ~= nil and enabled then
						p:SetHidden(not IsCoordinateInRange(p.nX, p.nY))
						if not p:IsHidden() then
							if p.pinTexture ~= nil then
								if p.pinTexture ~= p:GetTextureFileName() then
									p:SetTexture(p.pinTexture)
								end
							end
							p:RefreshAnchor()
						end
					end
				end
			end
		end
	end
end

local function RescalePinPositions()
	if Fyr_MM:IsHidden() or not CurrentMap.needRescale then return end
	CurrentMap.needRescale = false
	for i, v in pairs(PinsList) do
		--if (FyrMM.SV.WheelMap and not v:IsHidden()) or (not FyrMM.SV.WheelMap and FyrMM.IsPinVisible(v)) or v.BorderPin ~= nil then
				v:RefreshAnchor()
		--end
		if FyrMM.SV.WheelMap then
			v:SetHidden(not Is_PinInsideWheel(v))
			if v.BorderPin then
				v.BorderPin:SetHidden(not v:IsHidden())
			end
		end
	end
	RescaleLinks()
	FyrMM.UpdateQuestPinPositions()
	FyrMM.PlaceBorderPins()
end

local ZoomAnimating = false
local function AnimateZoom(newzoom)
	local step = (newzoom - CurrentMap.ZoomLevel) / 10
	if CurrentMap.ZoomLevel ~= newzoom then
		ZoomAnimating = true
		EVENT_MANAGER:RegisterForUpdate("OnFyrMMZoomAnimate", 1, function()
			FyrMM.SetCurrentMapZoom(CurrentMap.ZoomLevel + step)
			FyrMM.UpdateMapTiles(true)
			FyrMM.PositionUpdate()
			CurrentMap.needRescale = true
			RescalePinPositions()
			FyrMM.UpdateMapTiles(true)
			if (CurrentMap.ZoomLevel <= newzoom and step < 0) or (CurrentMap.ZoomLevel >= newzoom and step > 0) then
				EVENT_MANAGER:UnregisterForUpdate("OnFyrMMZoomAnimate")
				FyrMM.SetCurrentMapZoom(newzoom)
				FyrMM.UpdateMapTiles(true)
				FyrMM.PositionUpdate()
				CurrentMap.needRescale = true
				RescalePinPositions()
				FyrMM.UpdateMapTiles(true)
				ZoomAnimating = false
			end
		end)
	end
end

local function GetQuestData(pin)
	return pin.m_PinTag[1], pin.m_PinTag[3], pin.m_PinTag[2]
end

local function SetQuestTooltip(pin)
	if pin == nil then
		return
	end
	local tooltipLines = {}
	local line = ""
	local nX = pin.normalizedX
	local nY = pin.normalizedY
	local pinCount = Fyr_MM_Scroll_Map_QuestPins:GetNumChildren()
	for i=1, pinCount+10 do
		local l = GetControl("Fyr_MM_Scroll_Map_QuestPins_Pin"..tostring(i))
		if l ~= nil then
			if not l:IsHidden() or FyrMM.SV.WheelMap then
				
				line = ""
				if l.normalizedX == nX and l.normalizedY == nY then
					if l.m_PinType == MAP_PIN_TYPE_ASSISTED_QUEST_ENDING or l.m_PinType == MAP_PIN_TYPE_TRACKED_QUEST_ENDING then
						line = GenerateQuestEndingTooltipLine(questIndex)
						if valueExists(line, tooltipLines) then
							line = ""
						else
							InformationTooltip:AppendQuestEnding(l.m_PinTag[1])
						end
					end
					if (l.m_PinType == MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION or l.m_PinType == MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION or
						l.m_PinType == MAP_PIN_TYPE_TRACKED_QUEST_CONDITION or l.m_PinType == MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION) then
						line = GenerateQuestConditionTooltipLine(GetQuestData(l))
						if valueExists(line, tooltipLines) then
							line = ""
						else
							InformationTooltip:AppendQuestCondition(GetQuestData(l))
						end
					end
					if GetTrackedIsAssisted(TRACK_TYPE_QUEST, l.questIndex) then
						l:SetMouseEnabled(true)
					else
						l:SetMouseEnabled(false)
					end
				end
				if line ~= "" then
					table.insert(tooltipLines, line)
				end
			end
		end
	end
	pin:SetMouseEnabled(true)
end

--local function GetQuestPinById(Id) -- Returns first visible pin by quest Id
--	for i=1, FyrMM.questPinCount do
--		local l = GetControl("Fyr_MM_Scroll_Map_QuestPins_Pin"..tostring(i))
--		if l ~= nil then
--			if l.questIndex == Id and not l:IsHidden() then
--				return l
--			end
--		end
--	end
--	return nil
--end

function FyrMM.IsPinVisible(pin) -- Check for pin leaving map limits
	return (pin:GetRight() >= Fyr_MM:GetLeft() + 6 and pin:GetLeft() <= Fyr_MM:GetRight() - 10 and pin:GetBottom() >= Fyr_MM:GetTop() + 6 and pin:GetTop() <= Fyr_MM:GetBottom() - 10)
end

function FyrMM.IsValidBorderPin(pin)
	local Visible, Tracked
	if FyrMM.SV.WheelMap then
		Visible = Is_PinInsideWheel(pin)
	else
		Visible = FyrMM.IsPinVisible(pin)
	end
	if pin.m_PinType == MAP_PIN_TYPE_GROUP or pin.m_PinType == MAP_PIN_TYPE_GROUP_LEADER then
		if IsUnitOnline(pin.unitTag) then
			if FyrMM.SV.BorderPinsOnlyLeader then 
				Tracked = IsUnitGroupLeader(pin.unitTag) and (GetUnitZone("player") == GetUnitZone(pin.unitTag))
			else
				Tracked = (GetUnitZone("player") == GetUnitZone(pin.unitTag))
			end
		end
	else
		if FyrMM.SV.BorderPinsOnlyAssisted then
			Tracked = GetTrackedIsAssisted(TRACK_TYPE_QUEST, pin.questIndex)
		else
			Tracked = true
		end
	end
	if CustomWaypoints[pin.m_PinType] then
		Tracked = FyrMM.SV.BorderPinsWaypoint 
	end
	if pin.m_Pin ~= nil then
		if pin.m_Pin:IsFastTravelWayShrine() then
			local index, _ = string.gsub(pin:GetName(),"Fyr_MM_Scroll_Map_WayshrinePins_Pin", "")
			if Wayshrines[tonumber(index)] ~= nil then
				if Wayshrines[tonumber(index)].Closest then
					Tracked = FyrMM.SV.BorderWayshrine
				else
					Tracked = false
				end
			end
		end
	end
	if pin.m_PinType == MAP_PIN_TYPE_LOCATION then
		Tracked = false
		if pin.IsBankPin and FyrMM.SV.BorderPinsBank then
			Tracked = pin.IsBankPin
		end
		if pin.IsStablePin and FyrMM.SV.BorderPinsStables then
			Tracked = pin.IsStablePin
		end
		if pin.IsCraftingServicePin and FyrMM.SV.BorderCrafting then
			Tracked = pin.IsCraftingServicePin
		end
	end
	if pin.IsTreasure then
		if string.sub(string.lower(pin.pinTexture),1,12) == "losttreasure" then
			Tracked = FyrMM.SV.BorderTreasures
		else
			pin.IsTreasure = nil
		end
	end
	if pin.IsAvailableQuest then
		if pin.m_PinTag ~= nil then
			if pin.m_PinTag.IsAvailableQuest then
				Tracked = FyrMM.SV.BorderQuestGivers
			else
				pin.IsAvailableQuest = nil
			end
		else
			pin.IsAvailableQuest = nil
		end
	end
	return not Visible and Tracked and FyrMM.SV.BorderPins
end

local function GetNumBorderPins()
	local totalPins = Fyr_MM_Axis_Border_Pins:GetNumChildren()
	local count = 0
	for i=1, totalPins do
		local l = Fyr_MM_Axis_Border_Pins:GetChild(i)
		if l ~= nil then
			if l.pin then
				count = count + 1
			else
				l:SetHidden(true)
			end
		end
	end
	return count
end

local function RemoveBorderPin(pin)
	if pin ~= nil then
		pin:SetHidden(true)
		pin:SetMouseEnabled(false)
		pin:ClearAnchors()
		--pin:SetTexture(nil)
--		pin:SetHandler("OnMouseEnter", function() return end)
--		pin:SetHandler("OnMouseExit", function() return end)
--		pin:SetHandler("OnMouseUp", function() return end)
		if pin.pin then
			if pin.pin.OnBorder then
				pin.pin.OnBorder = nil
			end
			if pin.pin.BorderPin then
				pin.pin.BorderPin = nil
			end
			pin.pin = nil
		end
	end
end

local function CleanUpMisc()
	local t = GetGameTimeMilliseconds()
	if not IsInCyrodiil() then
		KeepIndex = {}
		for i=1, 100 do
			l = GetControl("Fyr_MM_Scroll_Map_Links_Link"..tostring(i))
			if l ~= nil then
				l:ClearAnchors()
				l:SetHidden(true)
				l:SetMouseEnabled(false)
			end
			l = GetControl("Fyr_MM_Scroll_Map_LinksNS_Link"..tostring(i))
			if l ~= nil then
				l:ClearAnchors()
				l:SetHidden(true)
				l:SetMouseEnabled(false)
			end
			l = GetControl("Fyr_MM_Scroll_Map_LinksWE_Link"..tostring(i))
			if l ~= nil then
				l:ClearAnchors()
				l:SetHidden(true)
				l:SetMouseEnabled(false)
			end
			if l == nil then i = 100 end
		end
	end
	FyrMM.CustomPinCount = 0
	FreeCustomPinIndex = {}
	CustomPinIndex = {}
	FyrMM.CustomPinKeyIndex = {}
	LastCustomPinIndex = 0
	FyrMM.Reloading = false
	FyrMM.InitialPreload()


	for i=1, 100 do
		l = GetControl("Fyr_MM_Scroll_Map_Locks_Lock"..tostring(i))
		if l ~= nil then
			l:ClearAnchors()
			l.normalizedX = nil
			l.normalizedY = nil
			l:SetHidden(true)
			l:SetMouseEnabled(false)
			--l:SetTexture(nil)
			l:SetDimensions(0,0)
		end
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "CleanUpMisc "..tostring(GetGameTimeMilliseconds()-t))
end

local function RemoveCustomPin(p)
	if p == nil then return end
	if p.BorderPin ~= nil then
		RemoveBorderPin(p.BorderPin)
	end
	p:ClearAnchors()
	p:SetHidden(true)
	p.m_PinTag = nil
	p.MapId = nil
	p.radius = nil
	p.nX = nil
	p.nY = nil
	p.IsTreasure = nil
	p.IsAvailableQuest = nil
	p.pinTexture = nil
		if FyrMM.CustomPinList[p.m_PinType] ~= nil then
			if FyrMM.CustomPinList[p.m_PinType][p.Key] ~= nil then
				if FyrMM.CustomPinList[p.m_PinType][p.Key].pin ~= nil then
					FyrMM.CustomPinList[p.m_PinType][p.Key].pin = nil
					FyrMM.CustomPinList[p.m_PinType][p.Key] = nil
				end
			end
		end
	if not table.empty(CustomPinIndex) then
		if p.Index ~= nil then
			table.insert(FreeCustomPinIndex, p.Index)
			FyrMM.CustomPinCount = FyrMM.CustomPinCount - 1
		end
		if CustomPinIndex[p.m_PinType] ~= nil and p.Index ~= nil then
			if CustomPinIndex[p.m_PinType][p.Index] ~= nil then
				CustomPinIndex[p.m_PinType][p.Index] = nil
			end
--			if p.Key ~= nil then
--				FyrMM.CustomPinKeyIndex[p.m_PinType][p.Key] = nil
--			end
		end
	end
	if p:GetName() ~= nil then
		if PinsList[p:GetName()] ~= nil then
			PinsList[p:GetName()] = nil
		end
	end
	p.Key = nil
	p.m_PinType = nil
	p.Index = nil
end


local function CheckCustomPinConsistence(Type)
	local pin
	if Type == nil then
		for i, n in pairs(FyrMM.CustomPinKeyIndex) do
			if FyrMM.CustomPinList[i] == nil then
				for j, index in pairs(n) do
					pin = GetControl("Fyr_MM_Scroll_Map_Pins_Pin"..tostring(index))
					RemoveCustomPin(pin)
					FyrMM.CustomPinKeyIndex[i][j] = nil
				end
			else
				if #n ~= #FyrMM.CustomPinList[i] then
					for j, index in pairs(n) do
						if FyrMM.CustomPinList[i][j] == nil then
							pin = GetControl("Fyr_MM_Scroll_Map_Pins_Pin"..tostring(index))
							RemoveCustomPin(pin)
							FyrMM.CustomPinKeyIndex[i][j] = nil
						end
					end
				end
			end
		end
	else
		if FyrMM.CustomPinKeyIndex[Type] == nil then
			return
		end
		if FyrMM.CustomPinList[Type] == nil then
			for j, index in pairs(FyrMM.CustomPinKeyIndex[Type]) do
				pin = GetControl("Fyr_MM_Scroll_Map_Pins_Pin"..tostring(index))
				RemoveCustomPin(pin)
				FyrMM.CustomPinKeyIndex[Type][j] = nil
			end
		else
			if #FyrMM.CustomPinKeyIndex[Type] ~= #FyrMM.CustomPinList[Type] then
				for j, index in pairs(FyrMM.CustomPinKeyIndex[Type]) do
					if FyrMM.CustomPinList[Type][j] == nil then
						pin = GetControl("Fyr_MM_Scroll_Map_Pins_Pin"..tostring(index))
						RemoveCustomPin(pin)
						FyrMM.CustomPinKeyIndex[Type][j] = nil
					end
				end
			end
		end
	end
end

local function CleanUpPins()
	if not table.empty(PinsList) then
		local cui = 0
		local chunk = FyrMM.SV.ChunkSize
		local delay = FyrMM.SV.ChunkDelay
		if chunk == nil then chunk = 50 end
		if delay == nil then delay = 50 end

		CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "CleanUpPins Start:"..tostring(chunk).."..."..tostring(delay/2))

		EVENT_MANAGER:RegisterForUpdate("FyrMiniMapCleanupPinsTask", delay/2, function()
			local c = 0
			local k = false
			cui = cui + 1
			local t = GetGameTimeMilliseconds()
			for i, l in pairs(PinsList) do
				c = c + 1
				if c >= chunk then
					CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "CleanUpPins "..tostring(cui).." "..tostring(GetGameTimeMilliseconds()-t))
					return
				end
				if l ~= nil then
					k = false
					if l.m_PinType ~= nil then
						if l.m_PinType >= MAP_PIN_TYPE_INVALID then
							RemoveCustomPin(l)
							k = true
						end
					end
					if not k then
						if l.BorderPin then
							RemoveBorderPin(l.BorderPin)
						end
						l:ClearAnchors()
						l:SetHidden(true)
						l:SetMouseEnabled(false)
						l.nX = nil
						l.nY = nil
						l:ClearAnchors()
						l:SetHidden(true)
						l:SetMouseEnabled(false)
						--l:SetTexture(nil)
						l:SetDimensions(0,0)
						l.m_PinTag = nil
						l.m_PinType = nil
						l.m_Pin = nil
						l.IsAvailableQuest = nil
						l.normalizedX = nil
						l.normalizedY = nil
						l.areaRadius = nil
						l.MapId = nil
						l.Index = nil
						l.questName = nil
						l.PinToolTipText = nil
						l.primaryPin = nil
						l.secondaryPin = nil
						l.tertiaryPin = nil
						l.MM_Tag = nil
						l.pinAge = nil
						l.IsTreasure = nil
						l.isDps = nil
						l.isHeal = nil
						l.isTank = nil
						l.ClassId = nil
						l.isLeader = nil
						PinsList[i] = nil
					end
					
				end
			end
			if table.empty(PinsList) then
				CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "CleanUpPins Done. "..tostring(GetGameTimeMilliseconds()-t))
				EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapCleanupPinsTask")
				CleanUpMisc()
				return
			end
		end)
	else
		FyrMM.Reloading = false
	end
end

local function GetNewBorderPinIndex()
	if Fyr_MM_Axis_Border_Pins:GetNumChildren() == 0 then return 1 end
	if Fyr_MM_Axis_Border_Pins:GetNumChildren() ~= GetNumBorderPins() then
		for i=1, Fyr_MM_Axis_Border_Pins:GetNumChildren() do
			local l = Fyr_MM_Axis_Border_Pins:GetChild(i)
			if l ~= nil then
				if l.pin == nil then
					return i
				end
			end
		end
	end
	return Fyr_MM_Axis_Border_Pins:GetNumChildren() + 1
end

local function GetTextureForBorderPin(pin)
local texture = ""
	if pin.IsTreasure or pin.IsAvailableQuest then
		if pin.pinTexture ~= nil then
			return pin.pinTexture
		end
	end
	if pin.m_PinType == MAP_PIN_TYPE_PLAYER_WAYPOINT then
		return "EsoUI/Art/MapPins/UI_Worldmap_pin_customDestination.dds"
	end
	if pin.m_PinType == MAP_PIN_TYPE_RALLY_POINT then
		return "MiniMap/Textures/rally.dds"
	end
	if pin.m_PinType == MAP_PIN_TYPE_PING then
		return "MiniMap/Textures/ping.dds"
	end
	if pin.m_Pin ~= nil then
		if pin.m_Pin:IsFastTravelWayShrine() then
			if pin.m_Pin.m_PinTag[2] ~= nil then
				return pin.m_Pin.m_PinTag[2]
			else
				return "/esoui/art/icons/poi_wayshrine_complete.dds"
			end
		end
	end
	if pin.m_PinType == MAP_PIN_TYPE_LOCATION then
		if pin.m_PinTag[2] ~= nil then
			return pin.m_PinTag[2]
		end
	end
	if pin.m_PinType == MAP_PIN_TYPE_GROUP or pin.m_PinType == MAP_PIN_TYPE_GROUP_LEADER then
		local isgmDps, isgmHeal, isgmTank = GetGroupMemberRoles(pin.unitTag)
		if IsUnitGroupLeader(pin.unitTag) then
			if FyrMM.SV.LeaderPin == "Default" then
				texture = "EsoUI/Art/Compass/groupLeader.dds"
			elseif FyrMM.SV.LeaderPin == "Class" then
				texture = GetClassIcon(GetUnitClassId(pin.unitTag))
			elseif isgmDps then
				texture = "EsoUI/Art/LFG/LFG_dps_down.dds"
			elseif isgmHeal then
				texture = "EsoUI/Art/LFG/LFG_healer_down.dds"
			elseif isgmTank then
				texture = "EsoUI/Art/LFG/LFG_tank_down.dds"
			else
				texture = "EsoUI/Art/Compass/groupLeader.dds"
			end
		else
			if FyrMM.SV.MemberPin == "Default" then
				texture = "EsoUI/Art/MapPins/UI-WorldMapGroupPip.dds"
			elseif FyrMM.SV.MemberPin == "Class" then
				texture = GetClassIcon(GetUnitClassId(pin.unitTag))
			elseif isgmDps then
				texture = "EsoUI/Art/LFG/LFG_dps_down.dds"
			elseif isgmHeal then
				texture = "EsoUI/Art/LFG/LFG_healer_down.dds"
			elseif isgmTank then
				texture = "EsoUI/Art/LFG/LFG_tank_down.dds"
			else
				texture = "EsoUI/Art/MapPins/UI-WorldMapGroupPip.dds"
			end
		end
		return texture
	end
	if QUEST_PIN_TYPES[pin.m_PinType] then
		return questPinTextures[pin.m_PinType]
		else return "MiniMap/Textures/Blank.dds"
	end
end

local function ProcessQuestPinClick(pin)
	local PinHandlers = {}
	local Pins = {}
	local HandlerCount = 0
	local Handler = {}
	local entries = {}
	local entry = ""
	Handler.Callback = function (questIndex) QUEST_TRACKER:ForceAssist(questIndex) end
	Handler.Name = zo_strformat(SI_WORLD_MAP_ACTION_SELECT_QUEST, GetJournalQuestName(pin.questIndex))
	table.insert(PinHandlers, Handler)
	table.insert(Pins, pin)
	for i=1, FyrMM.questPinCount do
		local p = GetControl("Fyr_MM_Scroll_Map_QuestPins_Pin"..tostring(i))
		if p ~= nil then
			if p ~= pin and p.normalizedX == pin.normalizedX and p.normalizedY == pin.normalizedY and not p:IsHidden() then
				entry = zo_strformat(SI_WORLD_MAP_ACTION_SELECT_QUEST, GetJournalQuestName(p.questIndex))
				if not valueExists(entry, entries) then
					HandlerCount = HandlerCount + 1
					local Handler = {}
					Handler.Callback = function (questIndex) QUEST_TRACKER:ForceAssist(questIndex) end
					Handler.Name = zo_strformat(SI_WORLD_MAP_ACTION_SELECT_QUEST, GetJournalQuestName(p.questIndex))
					table.insert(PinHandlers, Handler)
					table.insert(Pins, p)
					table.insert(entries, entry)
				end
			end
		end
	end 
	if HandlerCount <= 1 then
		PinHandlers[1].Callback(Pins[1].questIndex)
	else
		ClearMenu()
		for i=1, HandlerCount do
			local Handler = PinHandlers[i]
			local questIndex = Pins[i].questIndex
			local Name = Handler.Name
			if type(Name) == "function" then
				Name = Name(Pins[i])
			end
			AddMenuItem(Name, function() Handler.Callback(questIndex) end)
		end
		ShowMenu(pin)
	end
end

local function PinOnMouseExit(pin)
	if pin == nil then return end
	FyrMM.SetTargetScale(pin, 1)
	if pin.m_PinType == MAP_PIN_TYPE_LOCATION then
		ClearTooltip(ZO_MapLocationTooltip)
	else
		ClearTooltip(InformationTooltip)
	end
end

local function PinOnMouseEnter(pin)
	FyrMM.SetTargetScale(pin, 1.3)
	if not FyrMM.SV.PinTooltips then return end

	if pin.m_PinType ~= nil then
		if QUEST_PIN_TYPES[pin.m_PinType] then
			InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 0, 0)
			SetQuestTooltip(pin)
			IsCurrentLocation(pin)
			return
		end
		if CustomWaypoints[pin.m_PinType] then
			if ZO_MapPin.TOOLTIP_CREATORS[pin.m_PinType] then
				if ZO_MapPin.TOOLTIP_CREATORS[pin.m_PinType].tooltip and ZO_MapPin.TOOLTIP_CREATORS[pin.m_PinType].creator then 
					InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 0, 0)
					ZO_MapPin.TOOLTIP_CREATORS[pin.m_PinType].creator(pin)
					IsCurrentLocation(pin)
					return
				end
			end
		end
		if pin.m_PinType >= MAP_PIN_TYPE_INVALID then
			if ZO_MapPin.TOOLTIP_CREATORS[pin.m_PinType] then
				if ZO_MapPin.TOOLTIP_CREATORS[pin.m_PinType].tooltip and ZO_MapPin.TOOLTIP_CREATORS[pin.m_PinType].creator then 
					InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 0, 0)
					ZO_MapPin.TOOLTIP_CREATORS[pin.m_PinType].creator(pin.mpin)
					IsCurrentLocation(pin)
					return
				end
			end
		end
		if ZO_MapPin.FAST_TRAVEL_WAYSHRINE_PIN_TYPES[pin.m_PinType] or ZO_MapPin.POI_PIN_TYPES[pin.m_PinType] then
			InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 0, 0)
			SetTooltipMessage(pin.m_Pin)
			if not ZO_MapPin.FAST_TRAVEL_WAYSHRINE_PIN_TYPES[pin.m_PinType] then
				IsCurrentLocation(pin)
			end
			return
		end
		if pin.m_PinType == MAP_PIN_TYPE_LOCATION then
			if ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_LOCATION].tooltip then
				InitializeTooltip(ZO_MapLocationTooltip, Fyr_MM, TOPLEFT, 0, 0)
				ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_LOCATION].creator(pin.m_Pin)
				IsCurrentLocation(pin)
				return
			end
		end
		if ZO_MapPin.GROUP_PIN_TYPES[pin.m_PinType] then
			InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 0, 0)
			InformationTooltip:AppendUnitName(pin.unitTag)
			IsCurrentLocation(pin)
			return
		end

	end
end

local function PinOnMouseUp(pin)
	FyrMM.SetTargetScale(pin, 1.3)
	if not FyrMM.SV.PinTooltips then return end
	if pin.m_PinType ~= nil then
		if QUEST_PIN_TYPES[pin.m_PinType] then
			ProcessQuestPinClick(pin)
			FyrMM.UpdateQuestPins()
		end
		if ZO_MapPin.FAST_TRAVEL_WAYSHRINE_PIN_TYPES[pin.m_PinType] then
			if not IsInCyrodiil() and FyrMM.SV.FastTravelEnabled then
				if IsCurrentLocation(pin.m_Pin) then return end -- No need to recall if player is near wayshrine
				local nodeIndex = pin.m_Pin:GetFastTravelNodeIndex()
				ZO_Dialogs_ReleaseDialog("FAST_TRAVEL_CONFIRM")
				local name = select(2, GetFastTravelNodeInfo(nodeIndex))
				ZO_Dialogs_ShowDialog("FAST_TRAVEL_CONFIRM", {nodeIndex = nodeIndex, recall = true}, {mainTextParams = {name}}) 
	   		end
		end
	end
end

local function BorderPinOnMouseExit(pin)
	if pin == nil then return end
	if pin.pin == nil then return end
	FyrMM.SetTargetScale(pin, 1)
	if pin.pin.m_PinType then
		if pin.pin.m_PinType == MAP_PIN_TYPE_LOCATION then
			ClearTooltip(ZO_MapLocationTooltip)
		else
			ClearTooltip(InformationTooltip)
		end
	end
end

local function BorderPinOnMouseEnter(pin)
	if pin.pin == nil then RemoveBorderPin(pin) return end
	FyrMM.SetTargetScale(pin, 1.3)
	if not FyrMM.SV.PinTooltips then return end
	if pin.pin.m_PinType then
		if pin.pin.m_PinType == MAP_PIN_TYPE_LOCATION then
			if ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_LOCATION].tooltip then
				InitializeTooltip(ZO_MapLocationTooltip, Fyr_MM, TOPLEFT, 0, 0)
				ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_LOCATION].creator(pin.pin.m_Pin)
			end
			IsCurrentLocation(pin.pin)
			return
		else
			if ZO_MapPin.FAST_TRAVEL_WAYSHRINE_PIN_TYPES[pin.pin.m_PinType] then
				InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 0, 0) SetTooltipMessage(pin.pin.m_Pin)
				return
			end
			if pin.pin.IsTreasure or pin.pin.IsAvailableQuest then
				if ZO_MapPin.TOOLTIP_CREATORS[pin.pin.m_PinType] == nil then return end
				if ZO_MapPin.TOOLTIP_CREATORS[pin.pin.m_PinType].tooltip then
					InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 0, 0)
				end
				ZO_MapPin.TOOLTIP_CREATORS[pin.pin.m_PinType].creator(pin.pin.mpin)
				IsCurrentLocation(pin.pin)
				return
			end
			if pin.pin.m_PinType == MAP_PIN_TYPE_GROUP or pin.pin.m_PinType == MAP_PIN_TYPE_GROUP_LEADER then
				InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 0, 0)
				InformationTooltip:AppendUnitName(pin.pin.unitTag)
				IsCurrentLocation(pin.pin)
				return
			end
			if ZO_MapPin.MAP_PING_PIN_TYPES[pin.pin.m_PinType] then
				InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 0, 0)
				InformationTooltip:AppendMapPing(pin.pin.m_PinType, "player")
				IsCurrentLocation(pin.pin)
			end
		end
	end
end

local function SetBorderPinHandlers(pin)
	pin:SetHandler("OnMouseEnter", BorderPinOnMouseEnter)
	pin:SetHandler("OnMouseExit", BorderPinOnMouseExit)
	pin:SetMouseEnabled(true)
end

function FyrMM.CreateBorderPin(pin)
	if pin == nil then return end
	local borderpin
	if not FyrMM.IsValidBorderPin(pin) then
		if pin.BorderPin ~= nil then
			RemoveBorderPin(pin.BorderPin)
		end
		return nil
	end
	local mmWidth, mmHeight = Fyr_MM:GetDimensions()
	local mmX, mmY = Fyr_MM_Player:GetRight(), Fyr_MM_Player:GetTop()
	local pinX, pinY = math.abs(pin:GetRight() - mmX), math.abs(pin:GetTop() - mmY)
	local m = 0
	if pinX ~= 0 then
		m = pinY/pinX
	end
	local D = mmWidth/2 - ((38 / 512) * mmWidth)
	local newX, newY
	local na = math.atan((mmWidth/2)/(mmHeight/2))
	local nb = pi * 0.5 - na
	local pa = math.atan(pinX/(pinY))
	local pb = pi * 0.5 - pa

	local index = GetNewBorderPinIndex()
	if not pin.OnBorder then
		borderpin = GetControl("Fyr_MM_Axis_Border_Pin"..tostring(index))
		if borderpin == nil then
			borderpin = WINDOW_MANAGER:CreateControl("Fyr_MM_Axis_Border_Pin"..tostring(index), Fyr_MM_Axis_Border_Pins, CT_TEXTURE)
		end
		pin.BorderPin = borderpin
		borderpin.pin = pin
		SetBorderPinHandlers(borderpin)
	else
		borderpin = pin.BorderPin
	end
	 SetBorderPinHandlers(borderpin)
	pin.OnBorder = true
	borderpin:SetTexture(GetTextureForBorderPin(pin))
	--pinData[p.pinType].tint
	borderpin:SetColor(1,1,1,1)
	if pin.m_PinType ~= nil then
		if pinData[pin.m_PinType].tint ~= nil then
			if type(pinData[pin.m_PinType].tint) ~= "function" then
				borderpin:SetColor(pinData[pin.m_PinType].tint:UnpackRGBA())
			else
				if borderpin.pin.m_Pin ~= nil then
					borderpin:SetColor(pinData[pin.m_PinType].tint(borderpin.pin.m_Pin):UnpackRGBA())
				else
					borderpin:SetColor(pinData[pin.m_PinType].tint(borderpin.pin):UnpackRGBA())
				end
			end
		end
	end
	if pinX > 0 and pinY > 0 then
			if pa <= na then
				if pin:GetRight() >=  mmX then
					newX = mmWidth/2 + mmHeight/2 * math.sin(pa) / math.sin(pi * 0.5 - pa)
				else
					newX = mmWidth/2 - mmHeight/2 * math.sin(pa) / math.sin(pi * 0.5 - pa)
				end
				if pin:GetTop() < mmY then
					newY = 4
				else
					newY = mmHeight - (32 * FyrMM.pScalePercent)/2 + 2
				end
			else
				if pin:GetRight() > mmX then
					newX = mmWidth - (32 * FyrMM.pScalePercent)/2 + 4
				else
					newX = 2
				end
				pa = pi * 0.5 - (pa - na)
				if pin:GetTop() <=  mmY then
					newY = mmHeight/2 - mmWidth/2 * math.sin(pa - na) / math.sin(pi * 0.5 - (pa - na))
				else
					newY = mmHeight/2 + mmWidth/2 * math.sin(pa - na) / math.sin(pi * 0.5 - (pa - na))
				end
			end
			if pin.m_PinType == MAP_PIN_TYPE_GROUP then
				FyrMM.SetPinSize(borderpin, pin:GetDimensions())
			else
				FyrMM.SetPinSize(borderpin, 32 * FyrMM.pScalePercent, 0)
			end
			if FyrMM.SV.WheelMap then
				if pin:GetRight() >= mmX and pin:GetTop() >= mmY then
					newX = D/math.sqrt(1+m*m) + mmWidth/2
					newY = (m*D)/math.sqrt(1+m*m) + mmHeight/2
				end
				if pin:GetRight() >= mmX and pin:GetTop() < mmY then
					newX = D/math.sqrt(1+m*m) + mmWidth/2
					newY =  mmWidth/2 -(m*D)/math.sqrt(1+m*m)
				end
				if pin:GetRight() < mmX and pin:GetTop() < mmY then
					newX = mmWidth/2 - D/math.sqrt(1+m*m) 
					newY = mmWidth/2 - (m*D)/math.sqrt(1+m*m) 
				end
				if pin:GetRight() < mmX and pin:GetTop() >= mmY then
					newX = mmWidth/2 -D/math.sqrt(1+m*m)
					newY = (m*D)/math.sqrt(1+m*m) + mmWidth/2
				end
			end
			borderpin:SetHidden(false)
			borderpin:ClearAnchors()
			borderpin:SetAnchor(CENTER, Fyr_MM_Axis_Control, TOPLEFT, newX, newY)
		end
	return borderpin
end

function FyrMM.PlaceBorderPins()
	local i, j, l, v
	if ((not FyrMM.Visible or Fyr_MM:IsHidden())) then return end
	for i=1, Fyr_MM_Axis_Border_Pins:GetNumChildren() do
		l = Fyr_MM_Axis_Border_Pins:GetChild(i)
		if l ~= nil then
			if FyrMM.SV.BorderPins then
				if not l.pin then
					l:SetHidden(true)
				else
					if not FyrMM.IsValidBorderPin(l.pin) then
						RemoveBorderPin(l)
					end
				end
			else
				RemoveBorderPin(l)
			end
		end
	end
	if not FyrMM.SV.BorderPins then return end
	FyrMM.PlaceWaypointBorderPins()
	if Fyr_MM_Axis_Control:IsHidden() and FyrMM.SV.BorderPins then
		Fyr_MM_Axis_Control:SetHidden(false)
	end
	for i, v in pairs(QuestPins) do
		if not v.Pin:IsHidden() and FyrMM.IsValidBorderPin(v.Pin) then
			FyrMM.CreateBorderPin(v.Pin)
		end
	end
	for i=1, 24 do
		l = GetControl("Fyr_MM_Scroll_Map_Pinsgroup"..tostring(i))
		if l ~= nil then
			if not l:IsHidden() and FyrMM.IsValidBorderPin(l) then 
				FyrMM.CreateBorderPin(l)
			end
		end
	end
	if FyrMM.SV.BorderPinsBank or FyrMM.SV.BorderPinsStables or FyrMM.SV.BorderCrafting then
		for i=1, FyrMM.currentLocationsCount do
			l = GetControl("Fyr_MM_Scroll_Map_LocationPins_Pin"..tostring(i))
			if l ~= nil then
				if l.m_PinType == MAP_PIN_TYPE_LOCATION and FyrMM.IsValidBorderPin(l) then
					FyrMM.CreateBorderPin(l)
				end
			end
		end
	end
	if FyrMM.SV.BorderWayshrine and FyrMM.currentWayshrineCount > 0 then
		for i, v in ipairs(Wayshrines) do 
			if v.Closest then
				l = GetControl("Fyr_MM_Scroll_Map_WayshrinePins_Pin"..tostring(i))
				if l ~= nil then
					FyrMM.CreateBorderPin(l)
				end
			end
		end
	end
	if FyrMM.SV.BorderTreasures and not table.empty(Treasures) then
		for i, v in pairs(Treasures) do 
			if v ~= nil then
				if v.IsTreasure then
					FyrMM.CreateBorderPin(v)
				end
			end
		end
	end
	if FyrMM.SV.BorderQuestGivers and not table.empty(FyrMM.AvailableQuestGivers) then
		if #FyrMM.AvailableQuestGivers <= 5 then
			for i, v in pairs(FyrMM.AvailableQuestGivers) do 
				if v ~= nil then
					if v.IsAvailableQuest then
						FyrMM.CreateBorderPin(v)
					end
				end
			end
		else
			if not table.empty(AQGList) then
				for i=1, 5 do
					if AQGList[i] ~= nil then
						FyrMM.CreateBorderPin(AQGList[i])
					end
				end
			end
		end
	end
end

local function SetBorderPinHandlers()
	local l
	for i=1, Fyr_MM_Axis_Border_Pins:GetNumChildren() + 50 do
		l = GetControl("Fyr_MM_Axis_Border_Pins_Pin"..tostring(i))
		if l ~= nil then
			if l.pin ~= nil then
				if CustomWaypoints[l.pin.m_PinType] then
					RemoveBorderPin(l)
				end
			end
		else
			return
		end
	end
end

function FyrMM.PlaceWaypointBorderPins()
	SetBorderPinHandlers()
	if FyrMM.SV.BorderPinsWaypoint then
		if FyrMM.IsWaypoint then
			if not FyrMM.Waypoint:IsHidden() or not Is_PinInsideWheel(FyrMM.Waypoint) then
				FyrMM.CreateBorderPin(FyrMM.Waypoint)
				if FyrMM.Waypoint.BorderPin then
					FyrMM.Waypoint.BorderPin:SetHandler("OnMouseEnter", BorderPinOnMouseEnter)
					FyrMM.Waypoint.BorderPin:SetHandler("OnMouseExit", BorderPinOnMouseExit)
					FyrMM.Waypoint.BorderPin:SetMouseEnabled(true)
				end
			else
				if  FyrMM.Waypoint.BorderPin ~= nil then
					RemoveBorderPin(FyrMM.Waypoint)
				end
			end
		end
		if FyrMM.IsPing then
			if not FyrMM.Ping:IsHidden() then
				FyrMM.CreateBorderPin(FyrMM.Ping)
				if FyrMM.Ping.BorderPin then
					FyrMM.Ping.BorderPin:SetHandler("OnMouseEnter", BorderPinOnMouseEnter)
					FyrMM.Ping.BorderPin:SetHandler("OnMouseExit", BorderPinOnMouseExit)
					FyrMM.Ping.BorderPin:SetMouseEnabled(true)
				end
			else
				if  FyrMM.Ping.BorderPin ~= nil then
					RemoveBorderPin(FyrMM.Ping)
				end
			end
		end
		if FyrMM.IsRally then
			if not FyrMM.Rally:IsHidden() then
				FyrMM.CreateBorderPin(FyrMM.Rally)
				if FyrMM.Rally.BorderPin then
					FyrMM.Rally.BorderPin:SetHandler("OnMouseEnter", BorderPinOnMouseEnter)
					FyrMM.Rally.BorderPin:SetHandler("OnMouseExit", BorderPinOnMouseExit)
					FyrMM.Rally.BorderPin:SetMouseEnabled(true)
				end
			else
				if  FyrMM.Rally.BorderPin ~= nil then
					RemoveBorderPin(FyrMM.Rally)
				end
			end
		end
	end
end

-----------------------------------------------------------------
-- Pin Clean up
-----------------------------------------------------------------
local function CleanupMapLocations()
	local t = GetGameTimeMilliseconds()
	local totalPins = Fyr_MM_Scroll_Map_LocationPins:GetNumChildren()
	if totalPins > FyrMM.currentLocationsCount then
		for i=FyrMM.currentLocationsCount+1, totalPins do
			local l = GetControl("Fyr_MM_Scroll_Map_LocationPins_Pin"..tostring(i))
			if l ~= nil then
				if l.BorderPin ~= nil then
					RemoveBorderPin(l.BorderPin)
				end
				l.nX = nil
				l.nY = nil
				l:ClearAnchors()
				l:SetHidden(true)
				l:SetMouseEnabled(false)
				--l:SetTexture(nil)
				l:SetDimensions(0,0)
				l.m_Pin = nil
				PinsList[l:GetName()] = nil
			end
		end
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "CleanupMapLocations "..tostring(GetGameTimeMilliseconds()-t))
end

local function CleanupWayshrines()
	local t = GetGameTimeMilliseconds()
	local totalPins = Fyr_MM_Scroll_Map_WayshrinePins:GetNumChildren()
	if totalPins > FyrMM.currentWayshrineCount then
		for i=FyrMM.currentWayshrineCount+1, totalPins do
			local l = GetControl("Fyr_MM_Scroll_Map_WayshrinePins_Pin"..tostring(i))
			if l ~= nil then
				if l.BorderPin ~= nil then
					RemoveBorderPin(l.BorderPin)
				end
				l.nX = nil
				l.nY = nil
				l:ClearAnchors()
				l:SetHidden(true)
				l:SetMouseEnabled(false)
				--l:SetTexture(nil)
				l:SetDimensions(0,0)
				l.m_Pin = nil
				PinsList[l:GetName()] = nil
			end
		end
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "CleanupWayshrines "..tostring(GetGameTimeMilliseconds()-t))
end

local function CleanupPOIs()
	local t = GetGameTimeMilliseconds()
	local totalPins = Fyr_MM_Scroll_Map_POIPins:GetNumChildren()
	if totalPins == 0 then return end
	if CleanPOIs + FyrMM.currentPOICount ~= totalPins then
	--if totalPins > FyrMM.currentPOICount then
		CleanPOIs = 0
		for i=FyrMM.currentPOICount+1, totalPins do
			local l = GetControl("Fyr_MM_Scroll_Map_POIPins_Pin"..tostring(i))
			if l ~= nil then
				l.nX = nil
				l.nY = nil
				l:ClearAnchors()
				l:SetHidden(true)
				l:SetMouseEnabled(false)
				--l:SetTexture(nil)
				l:SetDimensions(0,0)
				l.m_Pin = nil
				PinsList[l:GetName()] = nil
				CleanPOIs = CleanPOIs + 1
			end
		end
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "CleanupPOIs ("..tostring(FyrMM.currentPOICount+1).." - "..tostring(totalPins)..") ("..CleanPOIs..") "..tostring(GetGameTimeMilliseconds()-t))
end

local function RemoveQuestPin(l)
	if l == nil then return end
	if l.MM_Tag ~= nil then
		if l.MM_Tag == 1 then
			if l.secondaryPin ~= nil then
				l.secondaryPin.MM_Tag = nil
				RemoveQuestPin(l.secondaryPin)
			end
			if l.tertiaryPin ~= nil then
				l.tertiaryPin.MM_Tag = nil
				RemoveQuestPin(l.tertiaryPin)
			end
		else
			if l.primaryPin ~= nil then
				l.primaryPin.MM_Tag = nil
				RemoveQuestPin(l.primaryPin)
			end
		end
	end
	if l.OnBorder then
		if l.BorderPin then
			l.BorderPin:ClearAnchors()
			l.BorderPin:SetHidden()
			l.BorderPin.pin = nil
			l.BorderPin = nil
		end
		l.OnBorder = nil
	end
	if l.questdataIndex ~= nil then
		if FyrMM.questPinCount > 0 then
			FyrMM.questPinCount = FyrMM.questPinCount - 1
		end
		if QuestPins[l.questdataIndex] ~= nil then
			table.insert(FreeQuestPinIndex, QuestPins[l.questdataIndex].pinIndex)
		end
		QuestPins[l.questdataIndex] = nil
	end

	l:SetParent(Fyr_MM_Scroll_Map_QuestPins)
	l:ClearAnchors()
	l:SetHidden(true)
	l:SetMouseEnabled(false)
	--l:SetTexture(nil)
	l:SetDimensions(0,0)
	l.questdataIndex = nil
	l.MM_Tag = nil
	l.m_PinTag = nil
	l.m_PinType = nil
	l.m_Pin = nil
	l.normalizedX = nil
	l.normalizedY = nil
	l.areaRadius = nil
	l.MapId = nil
	l.questIndex = nil
	l.questName = nil
	l.PinToolTipText = nil
	l.primaryPin = nil
	l.secondaryPin = nil
	l.tertiaryPin = nil
	l.pinAge = nil
	PinsList[l:GetName()] = nil
end

function FyrMM.RemoveInvalidQuestPins()
	local t = GetGameTimeMilliseconds()
	local _
	local compleate
	for i, v in pairs(QuestPins) do
		local l = v.Pin
		if l ~= nil then
			if not l:IsHidden() then
				local a = l.m_PinTag[1]
				local b = l.m_PinTag[3]
				local c = l.m_PinTag[2]
				local qi = l.questIndex
				if l.questIndex ~= nil then
					if not IsValidQuestIndex(qi) or GetJournalQuestName(qi) ~= l.questName then
						RemoveQuestPin(l)
					else
						if l.m_PinTag ~= nil and l.PinToolTipText ~= nil then
							if l.PinToolTipText ~= GenerateQuestConditionTooltipLine(a, b, c) then
								RemoveQuestPin(l)
							else
								_, _, _, _, compleate, _ = GetJournalQuestConditionInfo(a, b, c)
								if compleate then
									RemoveQuestPin(l)
								end
							end
						else
							RemoveQuestPin(l)
						end
					end
				else
					RemoveQuestPin(l)
				end
			end
		end
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "RemoveInvalidQuestPins "..tostring(GetGameTimeMilliseconds()-t))
end

function FyrMM.UpdateLabels(eventCode, zoneName, subZoneName, newSubzone, someID, subzoneId)
	if not FyrMM.SV then return end -- too soon
	local currentMapName, _ = string.gsub(GetMapName(), "(%w+)[%^]+.*", "%1")
	local currentAreaName = string.gsub(GetPlayerLocationName(), "(%w+)[%^]+.*", "%1")
	if not FyrMM.SV.ZoneNameContents ~= nil then
		if FyrMM.SV.ZoneNameContents == "Classic (Map only)" then
			Fyr_MM_Zone:SetText(currentMapName)
		elseif FyrMM.SV.ZoneNameContents == "Map & Area" then
			if currentMapName  ~= currentAreaName then
				Fyr_MM_Zone:SetText(currentMapName.."\n"..currentAreaName)
			else
				Fyr_MM_Zone:SetText(currentMapName)
			end
		else
			Fyr_MM_Zone:SetText(currentAreaName)
		end
	else
		Fyr_MM_Zone:SetText(currentMapName)
	end
	Fyr_MM_ZoomLevel:SetText(tostring(CurrentMap.ZoomLevel))
end
-----------------------------------------------------------------
-- Updates
-----------------------------------------------------------------
 local function FinishDistanceMeasurement()
	if Fyr_MM:IsHidden() or not ZO_WorldMap:IsHidden() then return end
	FyrMM.DistanceMeasurementStarted = false
	if CurrentMap.TrueMapSize > 1 then return end
	local x, y = FyrMM.MeasurementX, FyrMM.MeasurementY
	SetMapToPlayerLocation()
	local xl, yl = FyrMM.MeasurementXl, FyrMM.MeasurementYl
	local x2l, y2l, _ = GetMapPlayerPosition("player")
	local mapId = GetCurrentMapIndex()
	d(mapId)
	if mapId == nil then
		MapZoomOut()
		mapId = GetCurrentMapIndex()
	end
	local worldsize, multiplier
	multiplier = 1
	if mapId ~= 23 then
		SetMapToMapListIndex(1)
		worldsize = 33440   -- Assumed Tamriel size in feet taken from ZygorGuides
		-- Based on assumption that player constantly moves at the same speed anywhere - world size has to be adjusted to match it. According to Tamriel distance difference for some specific maps I made a few adjustments for the worldsizes while in those maps.
		-- Maps like Auridon or Glenumbra indicate same player speeds while Cyrodiil, Craglorn and starting maps show compleately different speeds (for mapsize 33440)
		if mapId == 14 then
			multiplier = 2.2 
		end
		if mapId == 18 then
			multiplier = 1.353
		end
		if mapId == 19 then
			multiplier = 2.6
		end
		if mapId == 20 or mapId == 21 then
			multiplier = 2.4865
		end
		if mapId == 22 then
			multiplier = 3.1
		end
		if mapId == 25 then
			multiplier = 1.087
		end
	else
		worldsize = 5684	-- Assumed Coldharbour size in feet
	end
	local x2, y2, _ = GetMapPlayerPosition("player")
	FyrMM.SetMapToPlayerLocation()
	local localdistance = math.sqrt((xl-x2l)*(xl-x2l)+(yl-y2l)*(yl-y2l)) -- Local map distance
	local continentdistance = math.sqrt((x-x2)*(x-x2)+(y-y2)*(y-y2)) -- Tamriel/Coldharbour 
	local mapSize = (worldsize * continentdistance / localdistance) * multiplier
	if not (mapSize > 0) then -- Error
		FyrMM.DistanceMeasurementStarted = true
		return
	end
	if FyrMM.SV.MapSizes == nil then FyrMM.SV.MapSizes = {} end
	FyrMM.SV.MapSizes[CurrentMap.filename] = mapSize
	CurrentMap.TrueMapSize = mapSize
end

function FyrMM.MeasureDistance()
	if not FyrMM.MeasureMaps then return end
	local _
	if CurrentMap.TrueMapSize > 1 then
		FyrMM.DistanceMeasurementStarted = false
		return
	end
	SetMapToPlayerLocation()
	FyrMM.MeasurementXl, FyrMM.MeasurementYl, _ = GetMapPlayerPosition("player")
	local mapId = GetCurrentMapIndex()
	if mapId == nil then
		MapZoomOut()
		mapId = GetCurrentMapIndex()
	end
	if mapId ~= 23 then
		SetMapToMapListIndex(1)
	end
	FyrMM.MeasurementX, FyrMM.MeasurementY, _ = GetMapPlayerPosition("player")
	FyrMM.DistanceMeasurementStarted = true
	FyrMM.SetMapToPlayerLocation()
	zo_callLater(FinishDistanceMeasurement, 5000)
end

function FyrMM.InCombatAutoHideCheck()
	if not FyrMM.SV.InCombatAutoHide then return end
	if IsUnitInCombat("player") then
		FyrMM.AfterCombatUnhidePending = false
		if not Fyr_MM:IsHidden() then 
			FyrMM.Visible = false
			FyrMM.AutoHidden = true
		end
	else
		if Fyr_MM:IsHidden() and FyrMM.AutoHidden then
			if not FyrMM.AfterCombatUnhidePending then
				FyrMM.AfterCombatUnhidePending = true
				FyrMM.AfterCombatUnhideTimeStamp = GetFrameTimeMilliseconds()
				zo_callLater(AfterCombatShow, 1000 * FyrMM.SV.AfterCombatUnhideDelay)
			end
		end
	end
end

local function DelayedReload()
	EVENT_MANAGER:RegisterForUpdate("MiniMapReload", 100, FyrMM.Reload)
end

local function DelayedShow()
	EVENT_MANAGER:RegisterForUpdate("FyrMiniMapDelayedShow", 200, FyrMM.Show)
end

local frameRatePrevious = GetFramerate()
function FyrMM.HideCheck() -- fires every 100 ticks
	if FyrMM.Reloading then return end
	FyrMM.Refresh = false
	local siegeControlling = IsPlayerControllingSiegeWeapon()
	local menuHidden = ZO_KeybindStripControl:IsHidden()
	local interactHidden = ZO_InteractWindow:IsHidden()
	local gameMenuHidden = ZO_GameMenu_InGame:IsHidden()
	local crownStoreActive = WINDOW_MANAGER:IsSecureRenderModeEnabled()
	local frameRate = GetFramerate()
	if frameRate < frameRatePrevious and frameRatePrevious - frameRate > 10 then
		FyrMM.UnregisterUpdates()
		FyrMM.HaltTimeOffset = GetFrameTimeMilliseconds()
	end
	frameRatePrevious = (frameRatePrevious + frameRate) / 2
	if FyrMM.SV.ShowFPS or FyrMM.FpsTest then 
		if (frameRate < 20.0) then
		Fyr_MM_FPS:SetColor(1, 0, 0, 1)
	elseif (frameRate < 30.0) then
		Fyr_MM_FPS:SetColor(1, 0.6, 0, 1)
	elseif (frameRate < 60.0) then
			Fyr_MM_FPS:SetColor(0, 1, 0, 1)
		else
			Fyr_MM_FPS:SetColor(1, 1, 1, 1)
		end
		Fyr_MM_FPS:SetText(string.format(" %.1f", frameRate))
	end
	if FyrMM.SV.ShowClock then
		Fyr_MM_Time:SetText(GetTimeString())
		if Fyr_MM_Time:IsHidden() then Fyr_MM_Time:SetHidden(false) end
	else
		Fyr_MM_Time:SetHidden(true)
	end
	if not Fyr_MM:IsHidden() and FyrMM.FpsTest then
		if FyrMM.Fps == 0 then
			FyrMM.Fps = frameRate
		else
			FyrMM.Fps = (FyrMM.Fps + frameRate) / 2
		end
	end
	if not FyrMM.SV.ShowFPS and not FyrMM.FpsTest then
		Fyr_MM_FPS:SetText("")
		Fyr_MM_FPS:SetAlpha(0)
	end
	if Fyr_MM:IsHidden() and FyrMM.FpsTest then
		if FyrMM.FpsRaw == 0 then
			FyrMM.FpsRaw = frameRate
		else
			FyrMM.FpsRaw = (FyrMM.FpsRaw + frameRate) / 2
		end
	end
	FyrMM.InCombatAutoHideCheck()
	if siegeControlling and FyrMM.SV.Siege then
		DelayedShow()
		return
	end
	if crownStoreActive then
		FyrMM.Hide()
		return
	end
	if FyrMM.Visible == false or FyrMM.noMap == true then
		FyrMM.Hide()
	elseif menuHidden == true and interactHidden == true and gameMenuHidden == true then
		DelayedShow()
	elseif menuHidden == false or interactHidden == false or gameMenuHidden == false then
		if gameMenuHidden == false then
			DelayedShow()
		else
			FyrMM.Hide()
		end
	end
	if FyrMM.Visible == true and FyrMM.noMap == true then
		FyrMM.noMap = false;
		DelayedReload()
		DelayedShow()
		return
	end
end

function FyrMM.WorldMapShowHide()
	if ZO_WorldMap:IsHidden() then
		FyrMM.UnregisterUpdates()
		CancelUpdates()
		FyrMM.Reloading = true
		FyrMM.Hide()
		if not FyrMM.SV.WorldMapRefresh then
			CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "OnWorldMapChanged (Show/Hide)"..tostring(GetGameTimeMilliseconds()))
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
		end
	else
		CurrentTasks = {}
		FyrMM.Reloading = false
		zo_callLater(FyrMM.SetMapToPlayerLocation,50)
	end
end

function FyrMM.SetMapToPlayerLocation(stealth)
	local changed = false
	if not Stealth then
		if Fyr_MM:IsHidden() then return end
	end
	if FyrMM.DisableSubzones == true and GetMapType() ~= 1 then return end
	if not ZO_WorldMap:IsHidden() then return end
	if SetMapToPlayerLocation() ~= SET_MAP_RESULT_CURRENT_MAP_UNCHANGED  then
		changed = true
		if FyrMM.SV.WorldMapRefresh or stealth then
			CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "OnWorldMapChanged (SetMapToPlayerLocation)"..tostring(GetGameTimeMilliseconds()))
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
		end
	end
	if FyrMM.DisableSubzones == true and GetMapType() == 1 then
		SetMapToZone()
	end
	return changed
end

function FyrMM.Hide()
	if Fyr_MM:IsHidden() then return end
	FyrMM.UnregisterUpdates()
	Fyr_MM:SetHidden(true)
	Fyr_MM_Wheel_Background:SetHidden(true)
	Fyr_MM_Menu:SetHidden(true)
	Fyr_MM_Coordinates:SetHidden(true)
	Fyr_MM_Axis_Control:SetHidden(true)
	Fyr_MM_Scroll_WheelCenter:SetHidden(true)
	Fyr_MM_Scroll_WheelNS:SetHidden(true)
	Fyr_MM_Scroll_WheelWE:SetHidden(true)
	Fyr_MM_Frame_Wheel:SetHidden(true)
	if not FyrMM.SV.ShowBorder then Fyr_MM_Border:SetAlpha(0) end
	Fyr_MM:SetMouseEnabled(false)
	Fyr_MM_Menu:SetMouseEnabled(false)
	Fyr_MM_FPS_Frame:SetHidden(true)
	Fyr_MM_ZoneFrame:SetHidden(true)
	Fyr_MM_Speed:SetHidden(true)
	Fyr_MM:SetMouseEnabled(false)
	Fyr_MM_Frame_Control:SetMouseEnabled(false)
	Fyr_MM_ZoneFrame:SetMouseEnabled(false)
	Fyr_MM_FPS_Frame:SetMouseEnabled(false)
end

function FyrMM.Show_WheelScrolls()
	FyrMM.UpdateMapTiles()
	Fyr_MM_Wheel_Background:SetHidden(not FyrMM.SV.WheelMap)
	Fyr_MM_Scroll_WheelCenter:SetHidden(not FyrMM.SV.WheelMap)
	Fyr_MM_Scroll_WheelNS:SetHidden(not FyrMM.SV.WheelMap)
	Fyr_MM_Scroll_WheelWE:SetHidden(not FyrMM.SV.WheelMap)
	Fyr_MM_Scroll:SetHorizontalScroll(CurrentMap.hpos)
	Fyr_MM_Scroll:SetVerticalScroll(CurrentMap.vpos)
	Fyr_MM_Scroll_WheelCenter:SetHorizontalScroll(CurrentMap.hpos)
	Fyr_MM_Scroll_WheelCenter:SetVerticalScroll(CurrentMap.vpos)
	Fyr_MM_Scroll_WheelNS:SetHorizontalScroll(CurrentMap.hpos)
	Fyr_MM_Scroll_WheelNS:SetVerticalScroll(CurrentMap.vpos)
	Fyr_MM_Scroll_WheelWE:SetHorizontalScroll(CurrentMap.hpos)
	Fyr_MM_Scroll_WheelWE:SetVerticalScroll(CurrentMap.vpos)
end

function FyrMM.Show()
	if FyrMM.Reloading then return end
	if FyrMM.Halted and FyrMM.Visible and ZO_WorldMap:IsHidden() and FyrMM.HaltTimeOffset ~= 0 then
		if GetFrameTimeMilliseconds() - FyrMM.HaltTimeOffset > 1000 then
			FyrMM.RegisterUpdates()
		end
	end
	if not (IsPlayerControllingSiegeWeapon() and FyrMM.SV.Siege) then 
		if not FyrMM.Visible or not ZO_WorldMap:IsHidden() or not ZO_KeybindStripControl:IsHidden() or not ZO_InteractWindow:IsHidden() or not ZO_GameMenu_InGame:IsHidden() or WINDOW_MANAGER:IsSecureRenderModeEnabled() then return end
	end
	if FyrMM.SV.hideCompass == true then
		ZO_CompassFrame:SetHidden(true)
	end
	FyrMM.SetMapToPlayerLocation()
	if Fyr_MM:IsHidden() then
		EVENT_MANAGER:RegisterForUpdate("FyrMiniMapDelayedRegister", 100, function()
			FyrMM.UpdateMapTiles(true)
			FyrMM.UpdateMapTiles(true)
			FyrMM.RegisterUpdates()
			EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapDelayedRegister") end)
		Fyr_MM_Frame_Wheel:SetHidden(not FyrMM.SV.WheelMap)
		if FyrMM.SV.WheelMap then
			FyrMM.Show_WheelScrolls()
		end
		Fyr_MM_Frame_Control:SetHidden(not FyrMM.SV.WheelMap)
		Fyr_MM:SetHidden(false)
		Fyr_MM_Menu:SetHidden(FyrMM.SV.MenuDisabled)
		Fyr_MM_Menu:SetMouseEnabled(not FyrMM.SV.MenuDisabled)
		Fyr_MM_ZoneFrame:SetHidden(FyrMM.SV.HideZoneLabel)
		Fyr_MM_Coordinates:SetHidden(not FyrMM.SV.ShowPosition)
		Fyr_MM_Axis_Control:SetHidden(not (FyrMM.SV.RotateMap or FyrMM.SV.BorderPins))
		Fyr_MM_FPS_Frame:SetHidden(not FyrMM.SV.ShowFPS)
		Fyr_MM_Speed:SetHidden(not FyrMM.SV.ShowSpeed)
		Fyr_MM_ZoneFrame:SetMouseEnabled(true)
		Fyr_MM:SetMouseEnabled(true)
	end
	if FyrMM.SV.ShowBorder then
		Fyr_MM_Border:SetAlpha(100)
	end
	Fyr_MM:SetMouseEnabled(true)
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapDelayedShow")
end

function FyrMM.ZoneUpdate()
	if FyrMM.Reloading then return end
	if FyrMM.SV.DisableSubzones then FyrMM.ZoneCheck() end
end

local function ZoneCheck()
	if ZO_WorldMap:IsHidden() then
		FyrMM.CheckingZone = true
		local filename, _, _ = GetCurrentMapTextureFileInfo()
		if filename == "tamriel_0" then return end
		CurrentMap.ZoneId = GetCurrentMapZoneIndex()
		if CurrentMap.filename ~= filename then
			FyrMM.UnregisterUpdates()
			CancelUpdates()
			local ZoneId = 0
			if FyrMM.MapList[filename] then
				FyrMM.LoadCustomPinList()
			end
			if ZoneId == 0 then
				SetMapToPlayerLocation()
				CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
			else
				CurrentMap.ZoneId = ZoneId
			end
			FyrMM.UpdateMapInfo()
			FyrMM.UpdateMapTiles(true)
			FyrMM.MovementSpeed = 0
			FyrMM.MovementSpeedPrevious = 0
			FyrMM.MovementSpeedMax = 0
			CustomPinIndex = {}
			if IsInCyrodiil() then
				zo_callLater(FyrMM.RequestKeepRefresh, 1000)
			end
			CurrentMap.PlayerNX, CurrentMap.PlayerNY, _ = GetMapPlayerPosition("player")
			CurrentMap.MapId = FyrMM.GetMapId()
			CALLBACK_MANAGER:FireCallbacks("OnFyrMiniNewMapEntered")
		end
	end
	FyrMM.CheckingZone = false
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapZoneCheck")
end

function FyrMM.ZoneCheck()
	if FyrMM.CheckingZone then return end
	EVENT_MANAGER:RegisterForUpdate("FyrMiniMapZoneCheck", 50, ZoneCheck)
end

local function TaskExists(tag)
	for i,v in pairs(CurrentTasks) do
		if CurrentTasks[i] ~= nil then
			if GetFrameTimeMilliseconds() - CurrentTasks[i].RequestTimeStamp < FYRMM_QUEST_PIN_REQUEST_TIMEOUT then
				if CurrentTasks[i][1] == tag[1] and CurrentTasks[i][2] == tag[2] and CurrentTasks[i][3] == tag[3]
				 and CurrentTasks[i].isBreadcrumb == tag.isBreadcrumb 
				 then return true end
			else
				--CurrentTasks[i] = nil
			end
		end
	end
	return false
end

local function DestroyTasks()
	for i,v in pairs(CurrentTasks) do
		if CurrentTasks[i] ~= nil then
			CurrentTasks[i] = nil
		end
	end
end

local function RemoveObsoleteQuestPins()
local t = GetGameTimeMilliseconds()
	for i,v in pairs(QuestPins) do
		if questpinDataExists(v, RequestedQuestPins) == nil then
			RemoveQuestPin(v.Pin)
		end
	end
	local pinCount = Fyr_MM_Scroll_Map_QuestPins:GetNumChildren()
	local l
	local nilcount = 0
	for i = 1, pinCount+100 do
		l = GetControl("Fyr_MM_Scroll_Map_QuestPins_Pin"..tostring(i))
		if l == nil then
			nilcount = nilcount + 1
			if nilcount > 1 then return end
		end
		if l ~= nil and l.questdataIndex ~= nil then
			if QuestPins[l.questdataIndex] == nil then
				if  l.MM_Tag == nil then
					RemoveQuestPin(l)
				else
					if l.MM_Tag == 1 then
						if l.secondaryPin ~= nil then
							l.secondaryPin.MM_Tag = nil
							RemoveQuestPin(l.secondaryPin)
						end
						if l.tertiaryPin ~= nil then
							l.tertiaryPin.MM_Tag = nil
							RemoveQuestPin(l.tertiaryPin)
						end
						l.MM_Tag = nil
						RemoveQuestPin(l)
					end
				end
				zo_callLater(FyrMM.RequestQuestPinUpdate,1000)
			end
		end
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "RemoveObsoleteQuestPins "..tostring(GetGameTimeMilliseconds()-t))
end

local function AddMissingQuestPins()
	local properType, pinTexture, size
	for i,v in pairs(RequestedQuestPins) do
		if questpinDataExists(v, QuestPins) == nil then
			properType, pinTexture, size = FyrMM.GetQuestPinInfo(MAP_PIN_TYPE_TRACKED_QUEST_CONDITION, GetTrackedIsAssisted(TRACK_TYPE_QUEST, v.questIndex), v.isBreadcrumb, v.areaRadius)
			FyrMM.CreateQuestPin(properType, v.tag, v.normalizedX, v.normalizedY, v.areaRadius)
			zo_callLater(FyrMM.RequestQuestPinUpdate,1000)
		end
	end
end

function FyrMM.PinUpdate()
	if FyrMM.Halted then return end
	if ((not FyrMM.Visible or Fyr_MM:IsHidden()) and FyrMM.Initialized) or not ZO_WorldMap:IsHidden() then return end
	local a = GetGameTimeMilliseconds()
	--CurrentMap.ZoneId = GetCurrentMapZoneIndex()
	FyrMM.RemoveInvalidQuestPins()
	if FyrMM.currentPOICount == 0 then
		EVENT_MANAGER:RegisterForUpdate("FyrMiniMapPOIPins", 30, function()
			if FyrMM.Reloading then return end
			FyrMM.POIPins()
			if FyrMM.currentPOICount ~= 0 then
				EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapPOIPins")
				return
			end
		end)
	end
	if FyrMM.currentLocationsCount == 0 then
		EVENT_MANAGER:RegisterForUpdate("FyrMiniMapLocationsPins", 30, function()
			if FyrMM.Reloading then return end
			FyrMM.LocationPins()
			if FyrMM.currentLocationsCount ~= 0 then
				EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapLocationsPins")
				return
			end
		end)
	end
	if FyrMM.currentWayshrineCount == 0 then
		EVENT_MANAGER:RegisterForUpdate("FyrMiniMapWayshrinesPins", 30, function()
			if FyrMM.Reloading then return end
			FyrMM.Wayshrines()
			if FyrMM.currentWayshrineCount ~= 0 then
				EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapWayshrinesPins")
				return
			end
		end)
	end
	if FyrMM.CustomPinCount ~= AvailableCustomPins() or table.empty(FyrMM.CustomPinList) then
		if FyrMM.MapList[CurrentMap.filename] and table.empty(FyrMM.CustomPinList) then
			FyrMM.LoadCustomPinList()
		end
		EVENT_MANAGER:RegisterForUpdate("FyrMiniMapCustomPins", 1000, function()
			if FyrMM.Reloading then return end
			if FyrMM.CustomPinCount ~= AvailableCustomPins() then
				CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.CustomPins Start: ("..tostring(FyrMM.CustomPinCount)..") "..tostring(GetGameTimeMilliseconds()))
				FyrMM.CustomPins()
			else
				CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.CustomPins End: ("..tostring(FyrMM.CustomPinCount)..") "..tostring(GetGameTimeMilliseconds()))
				EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapCustomPins")
			end
		end)
	end
	if table.empty(CurrentTasks) and QuestPinsUpdating and not QuestTasksPending then
		RemoveObsoleteQuestPins()
		AddMissingQuestPins()
		GetNumBorderPins()
		QuestPinsUpdating = false
	end
	if (NeedQuestPinUpdate or FyrMM.questPinCount == 0) and GetQuestJournalMaxValidIndex() > 0 then
		if not QuestPinsUpdating then
			if not (table.empty(CurrentTasks) and GetFrameTimeMilliseconds() - FyrMM.LastQuestPinRequest < FYRMM_QUEST_PIN_REQUEST_MINIMUM_DELAY) then
				RequestedQuestPins = {}
				FyrMM.UpdateQuestPins()
				NeedQuestPinUpdate = false
			end
		end
	end
	CheckCustomPinConsistence()
	a = GetFrameTimeMilliseconds() - a
	if a > 0 then CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.PinUpdate "..tostring(a)) end
end

function FyrMM.Debug_d(value)
	if FyrMM.DebugMode and FyrMM.SV then
		if FyrMM.SV.DebugLog == nil then
			FyrMM.SV.DebugLog = {}
		end
		local t = GetGameTimeMilliseconds() - math.floor(GetGameTimeMilliseconds()/1000)*1000
		d("["..GetTimeString()..string.format("] %s",tostring(value)))
		table.insert(FyrMM.SV.DebugLog, "["..GetTimeString().."."..tostring(t).."] FPS:"..tostring(zo_round(GetFramerate()*10)/10).." RAM:"..tostring(zo_round((collectgarbage("count")/1024)*100)/100).." MAP:"..tostring(CurrentMap.MapId).." LOC:"..string.format("%05.02f, %05.02f", zo_round(CurrentMap.PlayerNX*10000)/100, zo_round(CurrentMap.PlayerNY*10000)/100).." FN:"..tostring(value))
	end
end

--local function CleanupCustomPins()
--	if CustomPinsCopying then return end
--	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "CleanupCustomPins "..tostring(GetFrameTimeMilliseconds()))
--	local l
--	for i=1, Fyr_MM_Scroll_Map_Pins:GetNumChildren() do  -- custom pin clean up
--		l = Fyr_MM_Scroll_Map_Pins:GetChild(i)
--		if l ~= nil then
--			if l.BorderPin ~= nil then
--				RemoveBorderPin(l.BorderPin)
--			end
--			l:ClearAnchors()
--			l:SetHidden(true)
--			l:SetMouseEnabled(false)
--			l.nX = nil
--			l.nY = nil
--			l:SetTexture(nil)
--			l:SetDimensions(0,0)
--			l.IsTreasure = nil
--			l.IsAvailableQuest = nil
--			l.pinTexture = nil
--			PinsList[l:GetName()] = nil
--		end
--	end
--end

function FyrMM.Reload()
	if FyrMM.Reloading then return end
	local t = GetGameTimeMilliseconds()
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.Reload Start:")
	FyrMM.Reloading = true
	CancelUpdates()
	CustomPinsCopying = false
	FyrMM.LastReload = GetFrameTimeMilliseconds()
	FyrMM.UnregisterUpdates()
	FyrMM.UpdateLabels()
	FyrMM.MapHalfDiagonal()
	FyrMM.UpdateMapInfo()
	FyrMM.UpdateMapTiles(true)
	FyrMM.PositionUpdate()
	CleanUpPins()
	FreeQuestPinIndex = {}
	QuestPins = {}
	LastQuestPinIndex = 0
	FyrMM.DistanceMeasurementStarted = false
	FyrMM.MovementSpeedMax = 0
	FyrMM.questPinCount = 0
	FyrMM.currentLocationsCount = 0
	FyrMM.currentPOICount = 0
	FyrMM.currentForwardCamps = 0
	FyrMM.currentWayshrineCount = 0
	FyrMM.MeasureDistance()
	FyrMM.PlaceWaypointBorderPins()
	FyrMM.LoadCustomPinList()
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.Reload Done."..tostring(GetGameTimeMilliseconds()-t))
	EVENT_MANAGER:UnregisterForUpdate("MiniMapReload")
end



function FyrMM.WheelScroll(x, y)
	if x and y then
		Fyr_MM_Scroll_WheelCenter:SetHorizontalScroll(x)
		Fyr_MM_Scroll_WheelCenter:SetVerticalScroll(y)
		Fyr_MM_Scroll_WheelNS:SetHorizontalScroll(x)
		Fyr_MM_Scroll_WheelNS:SetVerticalScroll(y)
		Fyr_MM_Scroll_WheelWE:SetHorizontalScroll(x)
		Fyr_MM_Scroll_WheelWE:SetVerticalScroll(y)
	end
end

local function SetSpeedLabel(speed)
	if speed == nil then
		speed = 0
	end
	if speed ~= 0 then
		if FyrMM.SV.SpeedUnit == "ft/s" then
			speed = zo_round(speed*10000)/100
			Fyr_MM_SpeedLabel:SetText(string.format("(%05.02f ft/s)", speed))
		end
		if FyrMM.SV.SpeedUnit == "m/s" then
			speed = zo_round(speed*7550)/100
			Fyr_MM_SpeedLabel:SetText(string.format("(%05.02f m/s)", speed))
		end
		if FyrMM.SV.SpeedUnit == "%" then
			speed = zo_round(speed*100000)/90
			Fyr_MM_SpeedLabel:SetText(string.format("(%05.01f ", speed).."%)")
		end
	else
		Fyr_MM_SpeedLabel:SetText("(0 "..FyrMM.SV.SpeedUnit..")")
	end
end

local function LogPosition()
	local MapId = CurrentMap.MapId
	local size = CurrentMap.TrueMapSize
	local t = GetFrameTimeMilliseconds()
	CurrentMap.PlayerNX, CurrentMap.PlayerNY, CurrentMap.PlayerHeading = GetMapPlayerPosition("player")
	local LogEntry = {t = t, x = CurrentMap.PlayerNX, y = CurrentMap.PlayerNY, size = size}
	CurrentMap.CameraHeading = GetPlayerCameraHeading()
	CurrentMap.PlayerTurned = (CurrentMap.Heading ~= math.abs(CurrentMap.PlayerHeading - pi *2))
	CurrentMap.Heading = math.abs(CurrentMap.PlayerHeading - pi *2)
	CurrentMap.PlayerMoved = IsPlayerMoving()
	if CurrentMap.PlayerHeading < 0 then
		CurrentMap.PlayerHeading = pi * 2 + CurrentMap.PlayerHeading
	end
	if zo_round(CurrentMap.PlayerNX * 100)/100 <= 0 or zo_round(CurrentMap.PlayerNY * 100)/100 <= 0 or CurrentMap.PlayerNX >= 1 or CurrentMap.PlayerNY >= 1 then
		if not Fyr_MM:IsHidden() then
			SetMapToPlayerLocation()
		end
	end
	if MapId ~= CurrentMap.MapId then FyrMM.ZoneCheck() end
	CurrentMap.PlayerX, CurrentMap.PlayerY = Fyr_MM_Scroll_Map:GetDimensions()
	CurrentMap.PlayerX = CurrentMap.PlayerX * CurrentMap.PlayerNX
	CurrentMap.PlayerY = CurrentMap.PlayerY * CurrentMap.PlayerNY
	CurrentMap.currentTimeStamp = t
	if CurrentMap.PlayerMoved then
		CurrentMap.movedTimeStamp = t
	end
	PositionLogCounter = PositionLogCounter + 1
	if PositionLog[PositionLogCounter] == nil then
		PositionLog[PositionLogCounter] = LogEntry
	else
		PositionLog[PositionLogCounter].t = LogEntry.t
		PositionLog[PositionLogCounter].x = LogEntry.x
		PositionLog[PositionLogCounter].y = LogEntry.y
		PositionLog[PositionLogCounter].size = LogEntry.size
	end
	Fyr_MM_Position:SetText(string.format("%05.02f, %05.02f", CurrentMap.PlayerNX*100, CurrentMap.PlayerNY*100)) -- thanks Garkin
	Fyr_MM_Player_incombat:SetHidden(not (FyrMM.SV.InCombatState and IsUnitInCombat("player")))
end

local function SpeedMeasure()
	if table.empty(PositionLog) then return end
	local x1 = PositionLog[1].x
	local y1 = PositionLog[1].y
	local t1 = PositionLog[1].t
	local v1 = 0
	local va = 0
	local size = PositionLog[1].size
	local cnt = 1
	local i = 0
	if IsPlayerMoving() then
		for i=2, PositionLogCounter do
			if size == PositionLog[i].size then
				v1 = math.abs(math.sqrt((PositionLog[i].x-x1)*(PositionLog[i].x-x1)+(PositionLog[i].y-y1)*(PositionLog[i].y-y1)) * size / ((t1 - PositionLog[i].t)/10))
			else
				size = PositionLog[i].size
				v1 = math.abs(math.sqrt((PositionLog[i].x-x1)*(PositionLog[i].x-x1)+(PositionLog[i].y-y1)*(PositionLog[i].y-y1)) * size / ((PositionLog[i].t-t1)/10))
			end
			x1 = PositionLog[i].x
			y1 = PositionLog[i].y
			t1 = PositionLog[i].t
			va = va + v1
		end
	end
	va = va / (PositionLogCounter - 1)
	PositionLogCounter = 0
	if FyrMM.MovementSpeedPrevious ~= nil then
		FyrMM.MovementSpeed = (va + FyrMM.MovementSpeedPrevious) / 2
	else
	FyrMM.MovementSpeed = va
	end
	if FyrMM.MovementSpeedPrevious ~= FyrMM.MovementSpeed then
		CALLBACK_MANAGER:FireCallbacks("MovementSpeedChanged", va*100)
		FyrMM.MovementSpeedPrevious = FyrMM.MovementSpeed
	end
	if va > FyrMM.MovementSpeedMax then
		FyrMM.MovementSpeedMax = va
	end
	if FyrMM.SV.ShowSpeed then
		SetSpeedLabel(va)
	end
end

function FyrMM.PositionUpdate()
	if ((not FyrMM.Visible or Fyr_MM:IsHidden()) and FyrMM.Initialized) or not ZO_WorldMap:IsHidden() then return end
	if (not FyrMM.Visible or Fyr_MM:IsHidden()) and not FyrMM.Initialized then return end
	if not FyrMM.SV.WorldMapRefresh and GetMapId() ~= CurrentMap.MapId then FyrMM.ZoneCheck() end
	if Fyr_MM_Scroll_Map_0 == nil then return end
	if CurrentMap.Dx == nil then return end
	local a = GetGameTimeMilliseconds()
	local x = CurrentMap.PlayerNX
	local y = CurrentMap.PlayerNY
	local pheading = CurrentMap.PlayerHeading
	if x == nil or pheading == nil then
		x, y, pheading = GetMapPlayerPosition("player")
	end
	local currentTimeStamp = CurrentMap.currentTimeStap
	local speed = 0
	local moved = CurrentMap.PlayerMoved
	if CurrentMap.CameraHeading == nil then
		CurrentMap.CameraHeading = GetPlayerCameraHeading()
	end
	local cpheading = CurrentMap.CameraHeading
	if FyrMM.SV.RotateMap then
		cpheading =  math.abs(pheading - pi *2) + cpheading
	end
	Fyr_MM_Camera:SetTextureRotation(cpheading)
	local mapWidth = Fyr_MM_Scroll_Map_0:GetWidth()
	local mmWidth = Fyr_MM_Scroll:GetWidth()
	local widthCenter = mmWidth / 2
	local mapWidth = mapWidth * CurrentMap.Dx
	local mapHeight = Fyr_MM_Scroll_Map_0:GetHeight()
	local mmHeight = Fyr_MM_Scroll:GetHeight()
	local heightCenter = mmHeight / 2
	local mapHeight = mapHeight * CurrentMap.Dx 
	local hscroll = x * mapWidth
	local hpos = hscroll - widthCenter
	local vscroll = y * mapHeight
	local vpos = vscroll - heightCenter
	local zoomlevel = 0
	local chp, cvp = Fyr_MM_Scroll:GetScrollOffsets()
	local heading = pheading
	if FyrMM.SV.PPStyle ~= GetString(SI_MM_STRING_PLAYERANDCAMERA) then
		if FyrMM.SV.Heading == "CAMERA" then
			heading = CurrentMap.CameraHeading
		end
		if not moved and FyrMM.SV.Heading == "MIXED" then
			heading = CurrentMap.CameraHeading
		end
	end
	if CurrentMap.PlayerMoved and FyrMM.SV.ViewRangeFiltering then
		UpdateCustomPinPositions()
	end
	if ((x < 1.2 and x > -0.2) and (y < 1.2 and y > - 0.2)) then -- Can't let the scroll go too far outside view (Black map issue)
			if not Fyr_MM:IsHidden() and moved then FyrMM.SetMapToPlayerLocation() end
			CurrentMap.hpos = hpos
			CurrentMap.vpos = vpos
			if FyrMM.SV.RotateMap then
				Fyr_MM_Scroll:SetHorizontalScroll(0)
				Fyr_MM_Scroll:SetVerticalScroll(0)
				if CurrentMap.PlayerMoved or CurrentMap.PlayerTurned then
				end
			else
				Fyr_MM_Scroll:SetHorizontalScroll(hpos)
				Fyr_MM_Scroll:SetVerticalScroll(vpos)
			end
			if FyrMM.SV.WheelMap then
				FyrMM.WheelScroll(CurrentMap.hpos, CurrentMap.vpos)
			end
		else
			Fyr_MM_Scroll:SetHorizontalScroll(CurrentMap.hpos)
			Fyr_MM_Scroll:SetVerticalScroll(CurrentMap.vpos)
			if FyrMM.SV.WheelMap then
				FyrMM.WheelScroll(CurrentMap.hpos, CurrentMap.vpos)
			 end
		end
	if FyrMM.SV.RotateMap then
		if CurrentMap.PlayerMoved or CurrentMap.PlayerTurned then
			FyrMM.UpdateMapTiles(CurrentMap.PlayerMoved)
			CurrentMap.needRescale = true
		end
		Fyr_MM_Player:SetTextureRotation(0)
		FyrMM.AxisPins()
	else
		Fyr_MM_Player:SetTextureRotation(heading)
	end
	a = GetGameTimeMilliseconds() - a
	if a > 0 then CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.PositionUpdate "..tostring(a)) end
end

-------------------------------------------------------------
-- Map Building
-------------------------------------------------------------
-- get map info for minimap
function FyrMM.UpdateMapInfo(IgnoreZone)
	local t = GetGameTimeMilliseconds()
	CurrentMap.ready = false
	CurrentMap.name = GetMapName()
	CurrentMap.tileTexture = string.lower(GetMapTileTexture())
	CurrentMap.Dx, CurrentMap.Dy = GetMapNumTiles()
	CurrentMap.filename, CurrentMap.nameNoNum, CurrentMap.path = GetCurrentMapTextureFileInfo()
	CurrentMap.filename = string.lower(CurrentMap.filename)
	CurrentMap.TextureAngle = 0
	local id = 0
	if FyrMM.MapList[CurrentMap.filename] then
		id = FyrMM.MapList[CurrentMap.filename]
	end
	if string.lower(CurrentMap.filename) == "tamriel_0" then zo_callLater(FyrMM.UpdateMapInfo, 5) return end
	if CurrentMap.Dx < 2 or CurrentMap.Dy < 2 or CurrentMap.Dx == nil or CurrentMap.Dy == nil then
		if id ~= 0 and FyrMM.MapData[id] then
			CurrentMap.Dx = FyrMM.MapData[id][3]
			CurrentMap.Dy = FyrMM.MapData[id][4]
		else
			CurrentMap.Dx = 3
			CurrentMap.Dy = 3
		end
	end
	CurrentMap.type = GetMapType()
	if not IgnoreZone then
		CurrentMap.ZoneId = GetCurrentMapZoneIndex()
	end
-- if we have no texture we have nothing further to do
	if CurrentMap.tileTexture == "" or CurrentMap.Dx == nil or CurrentMap.Dy == nil then
		FyrMM.noMap = true;
		return 
	else
		FyrMM.noMap = false;
	end
	
	CurrentMap.numTiles = CurrentMap.Dx * CurrentMap.Dy
	CurrentMap.TrueMapSize = 1
	if id ~= 0 and FyrMM.MapData[id] then
		CurrentMap.TrueMapSize = FyrMM.MapData[id][5]
		if FyrMM.SV.MapSizes then
			if FyrMM.SV.MapSizes[CurrentMap.filename] and CurrentMap.TrueMapSize > 1 then
				FyrMM.SV.MapSizes[CurrentMap.filename] = nil
			end
		end
	end
	-- store tile textures in table
	CurrentMap.tiles = {}
	for i = 1, CurrentMap.numTiles do
		table.insert(CurrentMap.tiles, string.lower(GetMapTileTexture(i)))
	end
	if FyrMM.SV.ZoomTable[CurrentMap.filename] == nil then
		FyrMM.SV.ZoomTable[CurrentMap.filename] = FYRMM_DEFAULT_ZOOM_LEVEL
		CurrentMap.ZoomLevel = FYRMM_DEFAULT_ZOOM_LEVEL
	else
		CurrentMap.ZoomLevel = FyrMM.SV.ZoomTable[CurrentMap.filename]
	end
	if id ~= 0 then
		CurrentMap.MapId = id
		if CurrentMap.TrueMapSize == 1 then
			if FyrMM.SV.MapSizes[CurrentMap.filename] then
				CurrentMap.TrueMapSize = FyrMM.SV.MapSizes[CurrentMap.filename]
			end
		end 
	else
		CurrentMap.MapId = "unknown"
		if FyrMM.SV.MapSizes == nil then
			FyrMM.SV.MapSizes = {}
			FyrMM.SV.MapSizes[CurrentMap.filename] = 1
			CurrentMap.TrueMapSize = 1
		else
			if FyrMM.SV.MapSizes[CurrentMap.filename] ~= nil then
				CurrentMap.TrueMapSize = FyrMM.SV.MapSizes[CurrentMap.filename]
			end
		end
	end

	CurrentMap.ready = true
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.UpdateMapInfo "..tostring(GetGameTimeMilliseconds()-t))
	CALLBACK_MANAGER:FireCallbacks("OnFyrMiniMapChanged")
end

-- gets tile scale for map
function FyrMM.GetTileDimensions()
	local texW, texH = Fyr_MM_Scroll_Map_0:GetTextureFileDimensions()
	local id = 0
	if FyrMM.MapList[CurrentMap.filename] then
		id = FyrMM.MapList[CurrentMap.filename]
	end
	local mr = nil
	if FyrMM.MapData[id] then
		mr = FyrMM.MapData[id]
	end
	if (texW < 256 or texH < 256) or  (texW > 1024 or texH > 1024) or texW == nil or texH == nil then
		if CurrentMap.filename ~= nil then
			if mr then
				texW = mr[1]
				texH = texW
			else -- unknown Map
				texW = 256
				texH = 256
			end
		else -- unknown Map
			texW = 256
			texH = 256
		end
	end
	local dx, dy = GetMapNumTiles()
	if dx < 2 or dy < 2 or dx == nil or dy == nil and mr then
		dx = mr[3]
		dy = mr[4]
	end
	local zoomlevel = CurrentMap.ZoomLevel
	if zoomlevel == nil then zoomlevel = FYRMM_DEFAULT_ZOOM_LEVEL end
	local tileX = math.floor(zo_round(((CurrentMap.ZoomLevel/10) * texW * dx) / dx)/2)*2
	local tileY = math.floor(zo_round(((CurrentMap.ZoomLevel/10) * texW * dy) / dy)/2)*2
	return tileX,tileY
end

local Tiles = false
function FyrMM.UpdateMapTiles(stealth)
local needRescale = false
	if not stealth and ((not FyrMM.Visible or Fyr_MM:IsHidden()) and not FyrMM.Initialized) then return end
	if not CurrentMap.ready then return end
	if string.lower(CurrentMap.filename) == "tamriel_0" then return end

	local MM_TileSizeW, MM_TileSizeH = FyrMM.GetTileDimensions()
	if Fyr_MM_Scroll_Map_0:GetTextureFileName():lower() == CurrentMap.tiles[1]:lower() and
		zo_round(Fyr_MM_Scroll_Map_0:GetWidth()) == zo_round(MM_TileSizeW) and
		zo_round(Fyr_MM_Scroll_Map_0:GetHeight()) == zo_round(MM_TileSizeH) then if stealth  == GetFrameTimeMilliseconds() then return end
	else
		if zo_round(Fyr_MM_Scroll_Map_0:GetWidth()) ~= zo_round(MM_TileSizeW) or zo_round(Fyr_MM_Scroll_Map_0:GetHeight()) ~= zo_round(MM_TileSizeH) then
			CurrentMap.needRescale = true
		end
	end -- nothing to update if same map
	if Tiles then return end
	Tiles = true
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.UpdateMapTiles "..tostring(stealth))
	local sa, sb, centerSize
	local i = 0

	local MM_TileSizeW, MM_TileSizeH = FyrMM.GetTileDimensions()
	local mWidth, mHeight = MM_TileSizeW * CurrentMap.Dx, MM_TileSizeH * CurrentMap.Dy
	Fyr_MM_Scroll_Map:SetDimensions(mWidth, mHeight)
	if not FyrMM.SV.WheelMap then
		Fyr_MM_Bg:SetColor(0,0,0,1)
		Fyr_MM_Scroll_WheelNS:SetHidden(true)
		Fyr_MM_Scroll_WheelCenter:SetHidden(true)
		Fyr_MM_Scroll_WheelWE:SetHidden(true)
	else
		Fyr_MM_Bg:SetColor(1,1,1,0)
		Fyr_MM_Border:SetHidden(true)
		sa = Fyr_MM:GetWidth() - ((50 / 512) * Fyr_MM:GetWidth())
		sb = (220 / 512) * Fyr_MM:GetWidth()
		Fyr_MM_Scroll_WheelWE:SetDimensions(sa, sb)
		Fyr_MM_Scroll_WheelNS:SetDimensions(sb, sa)
		Fyr_MM_Frame_Control:SetDimensions(Fyr_MM:GetWidth(), Fyr_MM:GetWidth())
		Fyr_MM_Frame_Wheel:SetDimensions(Fyr_MM:GetWidth()+8, Fyr_MM:GetWidth()+8)
		if FyrMM.SV.RotateMap then
			Fyr_MM_Frame_Wheel:SetTextureRotation(CurrentMap.Heading)
		end
		centerSize = math.sqrt(2 * Fyr_MM:GetWidth() * Fyr_MM:GetWidth()) / 2
		Fyr_MM_Scroll_WheelCenter:SetDimensions(centerSize, centerSize)
		if not CurrentMap.PlayerX or not CurrentMap.PlayerY or not CurrentMap.Heading then
			local x, y, pheading = GetMapPlayerPosition("player")
			CurrentMap.PlayerNX = x
			CurrentMap.PlayerNY = y
			CurrentMap.PlayerX, CurrentMap.PlayerY = Fyr_MM_Scroll_Map:GetDimensions()
			CurrentMap.PlayerX = CurrentMap.PlayerX * x
			CurrentMap.PlayerY = CurrentMap.PlayerY * y
			CurrentMap.Heading = math.abs(pheading - pi *2)
		end

	end
	local tilec, tilens, tilewe
	local tileposX, tileposY, x, y
	for a=1, CurrentMap.Dy do
		for b=1, CurrentMap.Dx do
			i = i + 1
			local tileControl = GetControl("Fyr_MM_Scroll_Map_"..tostring(i - 1))
			if tileControl == nil then
				tileControl = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_"..tostring(i - 1), Fyr_MM_Scroll_Map, CT_TEXTURE)
			end
			local tilens = GetControl("Fyr_MM_Scroll_WNS_Map_"..tostring(i-1))
			if tilens == nil then
				tilens = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_WNS_Map_"..tostring(i - 1), Fyr_MM_Scroll_WheelNS, CT_TEXTURE)
			end
			local tilec = GetControl("Fyr_MM_Scroll_CW_Map_"..tostring(i-1))
			if tilec == nil then
				tilec = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_CW_Map_"..tostring(i - 1), Fyr_MM_Scroll_WheelCenter, CT_TEXTURE)
			end
			local tilewe = GetControl("Fyr_MM_Scroll_WWE_Map_"..tostring(i - 1))
			if tilewe == nil then
				tilewe = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_WWE_Map_"..tostring(i - 1), Fyr_MM_Scroll_WheelWE, CT_TEXTURE)
			end
			tileControl:SetHidden(FyrMM.SV.WheelMap)
			tilens:SetHidden(not FyrMM.SV.WheelMap)
			tilec:SetHidden(not FyrMM.SV.WheelMap)
			tilewe:SetHidden(not FyrMM.SV.WheelMap)
			if tileControl:GetTextureFileName():lower() ~= CurrentMap.tiles[i]:lower() then
				tileControl:SetTexture(CurrentMap.tiles[i])
				tilens:SetTexture(CurrentMap.tiles[i])
				tilec:SetTexture(CurrentMap.tiles[i])
				tilewe:SetTexture(CurrentMap.tiles[i])
			end
			tileControl:SetDimensions(FyrMM.GetTileDimensions())
			tilens:SetDimensions(FyrMM.GetTileDimensions())
			tilec:SetDimensions(FyrMM.GetTileDimensions())
			tilewe:SetDimensions(FyrMM.GetTileDimensions())
			tileControl:SetDrawLayer(0)
			tilens:SetDrawLayer(1)
			tilec:SetDrawLayer(1)
			tilewe:SetDrawLayer(1)
			tilens:ClearAnchors()
			tilec:ClearAnchors()
			tilewe:ClearAnchors()
			tileControl:ClearAnchors()
			if FyrMM.SV.RotateMap then
				if not CurrentMap.PlayerX or not CurrentMap.PlayerY or not CurrentMap.Heading then
					local x, y, pheading = GetMapPlayerPosition("player")
					CurrentMap.PlayerNX = x
					CurrentMap.PlayerNY = y
					CurrentMap.PlayerX, CurrentMap.PlayerY = Fyr_MM_Scroll_Map:GetDimensions()
					CurrentMap.PlayerX = CurrentMap.PlayerX * x
					CurrentMap.PlayerY = CurrentMap.PlayerY * y
					CurrentMap.Heading = math.abs(pheading - pi *2)
				end
				x = ((b-0.5) * mWidth/CurrentMap.Dx) - CurrentMap.PlayerX
				y = ((a-0.5) * mHeight/CurrentMap.Dy) - CurrentMap.PlayerY
				tileposX = (math.cos(-CurrentMap.Heading) * x) - (math.sin(-CurrentMap.Heading) * y)
				tileposY = (math.sin(-CurrentMap.Heading) * x) + (math.cos(-CurrentMap.Heading) * y)
				tileControl:SetTextureRotation(CurrentMap.Heading,0.5,0.5);
				tilens:SetTextureRotation(CurrentMap.Heading,0.5,0.5);
				tilec:SetTextureRotation(CurrentMap.Heading,0.5,0.5);
				tilewe:SetTextureRotation(CurrentMap.Heading,0.5,0.5);
				if FyrMM.SV.MapAlpha > 80 then 
					tilens:SetScale(1.0055)
					tilec:SetScale(1.0055)
					tilewe:SetScale(1.0055)
					tileControl:SetScale(1.0055)
				else
					tilens:SetScale(1)
					tilec:SetScale(1)
					tilewe:SetScale(1)
					tileControl:SetScale(1)
				end
				tileControl:SetAnchor(CENTER, Fyr_MM_Scroll, CENTER, tileposX, tileposY)
				tilens:SetAnchor(CENTER, Fyr_MM_Scroll_WheelNS, CENTER, tileposX, tileposY)
				tilec:SetAnchor(CENTER, Fyr_MM_Scroll_WheelCenter, CENTER, tileposX, tileposY)
				tilewe:SetAnchor(CENTER, Fyr_MM_Scroll_WheelWE, CENTER, tileposX, tileposY)
			else
				tileposX = ((b-0.5) * mWidth/CurrentMap.Dx) - mWidth/2
				tileposY = ((a-0.5) * mHeight/CurrentMap.Dy) - mHeight/2
				tileControl:SetScale(1)
				tilens:SetScale(1)
				tilec:SetScale(1)
				tilewe:SetScale(1)
				tileControl:SetTextureRotation(0)
				tilens:SetTextureRotation(0)
				tilec:SetTextureRotation(0)
				tilewe:SetTextureRotation(0)
				tileControl:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tilens:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tilec:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tilewe:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tileControl:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tilens:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tilec:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)
				tilewe:SetAnchor(CENTER, Fyr_MM_Scroll_Map, CENTER, tileposX, tileposY)


			end
			
		end
	end
	for j=i, Fyr_MM_Scroll_Map:GetNumChildren() do
		tileControl = GetControl("Fyr_MM_Scroll_Map_"..tostring(j))
		tilens = GetControl("Fyr_MM_Scroll_WNS_Map_"..tostring(j))
		tilec = GetControl("Fyr_MM_Scroll_CW_Map_"..tostring(j))
		tilewe = GetControl("Fyr_MM_Scroll_WWE_Map_"..tostring(j))		
		if (tileControl) then
			tileControl:ClearAnchors()
			tileControl:SetHidden(true)
		end
		if (tilens) then
			tilens:ClearAnchors()
			tilens:SetHidden(true)
		end
		if (tilec) then
			tilec:ClearAnchors()
			tilec:SetHidden(true)
		end
		if (tilewe) then
			tilewe:ClearAnchors()
			tilewe:SetHidden(true)
		end
	end
	if FyrMM.SV.WheelMap then
		CurrentMap.TextureAngle = CurrentMap.Heading
	else
		CurrentMap.TextureAngle = 0
	end
	Tiles = false
end

function FyrMM.GetScrollObject(control)
	local xl = control:GetLeft()
	local xr = control:GetRight()
	local yt = control:GetTop()
	local yb = control:GetBottom()
	if FyrMM.SV.WheelMap then
		if (xr >= Fyr_MM_Scroll_WheelCenter:GetLeft() + 6 and xl <= Fyr_MM_Scroll_WheelCenter:GetRight() - 10 and yb >= Fyr_MM_Scroll_WheelCenter:GetTop() + 6 and yt <= Fyr_MM_Scroll_WheelCenter:GetBottom() - 10) then
			return Fyr_MM_Scroll_WheelCenter
		end
		if (xr >= Fyr_MM_Scroll_WheelNS:GetLeft() + 6 and xl <= Fyr_MM_Scroll_WheelNS:GetRight() - 10 and yb >= Fyr_MM_Scroll_WheelNS:GetTop() + 6 and yt <= Fyr_MM_Scroll_WheelNS:GetBottom() - 10) then
			return Fyr_MM_Scroll_WheelNS
		end
		if (xr >= Fyr_MM_Scroll_WheelWE:GetLeft() + 6 and xl <= Fyr_MM_Scroll_WheelWE:GetRight() - 10 and yb >= Fyr_MM_Scroll_WheelWE:GetTop() + 6 and yt <= Fyr_MM_Scroll_WheelWE:GetBottom() - 10) then
			return Fyr_MM_Scroll_WheelWE
		end
	else
		return Fyr_MM_Scroll_Map
	end
	return Fyr_MM_Scroll_WheelCenter
end


-----------------------------------------------------------------
-- Map Pins
-----------------------------------------------------------------
local function GetPinTexture(pinType, control)
	if type(ZO_MapPin.PIN_DATA[pinType].texture) == 'string' then
		return ZO_MapPin.PIN_DATA[pinType].texture
	elseif type(ZO_MapPin.PIN_DATA[pinType].texture) == 'function' then
	if(control.m_PinTag.isBreadcrumb) then
		return breadcrumbQuestPinTextures[pinType]
	else
		return questPinTextures[pinType]
	end
		return ZO_MapPin.PIN_DATA[pinType].texture(control)
	end
end

local function GetCustomPin()
	local p
	if table.empty(FreeCustomPinIndex) then
		LastCustomPinIndex = LastCustomPinIndex + 1
		p = GetControl("Fyr_MM_Scroll_Map_Pins_Pin"..tostring(LastCustomPinIndex))
		if p == nil then
			p = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_Pins_Pin"..tostring(LastCustomPinIndex), Fyr_MM_Scroll_Map_Pins, CT_TEXTURE)
			p:SetHandler("OnMouseEnter", PinOnMouseEnter)
			p:SetHandler("OnMouseExit", PinOnMouseExit)
		end
		p.Index = LastCustomPinIndex
		return p
	else
		for i, n in pairs(FreeCustomPinIndex) do
			p = GetControl("Fyr_MM_Scroll_Map_Pins_Pin"..tostring(n))
			if p == nil then
				p = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_Pins_Pin"..tostring(n), Fyr_MM_Scroll_Map_Pins, CT_TEXTURE)
				p:SetHandler("OnMouseEnter", PinOnMouseEnter)
				p:SetHandler("OnMouseExit", PinOnMouseExit)
			end
			p.Index = n
			FreeCustomPinIndex[i] = nil
			return p
		end
	end
end

local function ClearCustomPinReminder()
	if CustomPinsCopying then return end
	for i=FyrMM.CustomPinCount+1, Fyr_MM_Scroll_Map_Pins:GetNumChildren() do
		local l = GetControl("Fyr_MM_Scroll_Map_Pins_Pin"..tostring(i))
		if l ~= nil then
			if l.BorderPin ~= nil then
				RemoveBorderPin(l.BorderPin)
			end
			l:ClearAnchors()
			l:SetHidden(true)
			l.nX = nil
			l.nY = nil
			l.IsTreasure = nil
			l.IsAvailableQuest = nil
			l.pinTexture = nil
		end
	end
end

local ci = 0
function InsertCustomPin(p, key)
	if p == nil or FyrMM.Reloading then return end
	local j = 1
	local mapId = GetMapId()
	local pin, texture, pScalePercent
	pScalePercent = FyrMM.pScalePercent
	if pScalePercent == nil then
		pScalePercent = 1
	end
	local enabled
	if type(p) == "table" then
		enabled = true
		if PinRef ~= nil then
			if PRCustomPins ~= nil and p.m_PinType >= MAP_PIN_TYPE_INVALID then
				enabled = PRCustomPins[p.m_PinType].enabled
			end
		else		
			if p.m_PinType >= MAP_PIN_TYPE_INVALID then
				enabled =  ZO_WorldMap_IsCustomPinEnabled(p.m_PinType)
			end
		end
		if CustomPinIndex[p.m_PinType] == nil then
			CustomPinIndex[p.m_PinType] = {}
		end
		if FyrMM.CustomPinKeyIndex[p.m_PinType] == nil then
			FyrMM.CustomPinKeyIndex[p.m_PinType] = {}
		end
		if FyrMM.CustomPinList[p.m_PinType] == nil then
			FyrMM.CustomPinList[p.m_PinType] = {}
		end
		if enabled then
			pin = GetCustomPin()
			if pin.mpin == nil then
				pin.mpin = ZO_MapPin:New()
			end
			if FyrMM.CustomPinList[p.m_PinType][key] ~= nil then
				FyrMM.CustomPinList[p.m_PinType][key].pin = pin
			end
			j = pin.Index
			if key ~= nil then
				FyrMM.CustomPinKeyIndex[p.m_PinType][key] = j
			end
			FyrMM.CustomPinCount = FyrMM.CustomPinCount + 1
			CustomPinIndex[p.m_PinType][j] = pin
			pin:SetHidden(true) -- updating...
			if pin.BorderPin ~= nil then
				RemoveBorderPin(pin.BorderPin)
			end
			texture = ""
			pin.m_PinType = p.m_PinType
			pin.m_PinTag = p.m_PinTag
			pin.mpin.m_PinType = p.m_PinType
			pin.mpin.m_PinTag = p.m_PinTag
			pin.mpin.normalizedX = p.normalizedX
			pin.mpin.normalizedY = p.normalizedY
			pin.nX = p.normalizedX
			pin.nY = p.normalizedY
			pin.radius = p.radius
			pin.MapId = CurrentMap.MapId
			pin.Index = j
			pin.Key = key
			--pin.GetPinTypeAndTag = function(self) return self.m_PinType, self.m_PinTag end
			if pinData[p.m_PinType].size ~= nil then
				FyrMM.SetPinSize(pin, pinData[p.m_PinType].size * pScalePercent)
			end

			if type(pinData[p.m_PinType].texture) == 'string' then
				texture = pinData[p.m_PinType].texture
			elseif type(pinData[p.m_PinType].texture) == 'function' then
				texture = pinData[p.m_PinType].texture(pin.mpin)
			end
			if p.m_PinType == MAP_PIN_TYPE_PLAYER_WAYPOINT then
				texture = "EsoUI/Art/MapPins/UI_Worldmap_pin_customDestination.dds"
				FyrMM.IsWaypoint = true
				FyrMM.SetPinSize(pin, 32 * pScalePercent)
				if FyrMM.Waypoint ~= nil then
					if FyrMM.Waypoint.BorderPin ~= nil then
						RemoveBorderPin(FyrMM.Waypoint.BorderPin)
					end
				end
				FyrMM.Waypoint = pin
			end
			if p.m_PinType == MAP_PIN_TYPE_RALLY_POINT then
				texture = "MiniMap/Textures/rally.dds"
				FyrMM.SetPinSize(pin, 32 * pScalePercent)
				FyrMM.IsRally = true
				if FyrMM.Rally ~= nil then
					if FyrMM.Rally.BorderPin ~= nil then
						RemoveBorderPin(FyrMM.Rally.BorderPin)
					end
				end
				FyrMM.Rally = pin
			end
			if p.m_PinType == MAP_PIN_TYPE_PING then
				texture = "MiniMap/Textures/ping.dds"
				FyrMM.SetPinSize(pin, 32 * FyrMM.pScalePercent)
				FyrMM.IsPing = true
				if FyrMM.Ping ~= nil then
					if FyrMM.Ping.BorderPin ~= nil then
						RemoveBorderPin(FyrMM.Ping.BorderPin)
					end
				end
				FyrMM.Ping = pin
			end
			pin.pinTexture = texture
			pin:SetTexture(texture)
			if string.sub(string.lower(texture),1,12) == "losttreasure" then
				pin.IsTreasure = true
				table.insert(Treasures, pin)
			end
			if type(p.m_PinTag) == "table" then
				if p.m_PinTag.IsAvailableQuest then
					pin.IsAvailableQuest = true
					table.insert(FyrMM.AvailableQuestGivers, pin)
				end
			end

			pin:SetColor(1,1,1,1)
			if pinData[p.m_PinType].tint ~= nil then
				if type(pinData[p.m_PinType].tint) ~= "function" then
					pin:SetColor(pinData[p.m_PinType].tint:UnpackRGBA())
				else
				local c = pinData[p.m_PinType].tint(pin.mpin)
					if type(c) == "table" then
						pin:SetColor(c.r, c.g, c.b, c.a)
					end
				end
			end
			FyrMM.SetPinAnchor(pin, pin.nX, pin.nY, Fyr_MM_Scroll_Map_Pins)
			local pinHidden = true
			if FyrMM.SV.WheelMap then
				pin:SetHidden(not Is_PinInsideWheel(pin) and pinHidden)
			else
				pin:SetHidden(not pinHidden)
			end
			pin:SetMouseEnabled(true)
			if (FyrMM.IsWaypoint or FyrMM.IsRally or FyrMM.IsPing) and FyrMM.SV.BorderPinsWaypoint then
				FyrMM.PlaceWaypointBorderPins()
			end
		else
			if pin ~= nil then
				if pin.BorderPin ~= nil then
					RemoveBorderPin(pin.BorderPin)
				end
				pin:ClearAnchors()
				pin:SetHidden(true)
				pin.nX = nil
				pin.nY = nil
				pin.MapId = nil
				pin.Index = nil
				pin.IsTreasure = nil
				pin.IsAvailableQuest = nil
				pin.pinTexture = nil
				PinsList[pin:GetName()] = nil
			end
		end
	end
end

function FyrMM.CustomPins()
	if FyrMM.Halted then return end
	if not FyrMM.Visible or Fyr_MM:IsHidden() or not ZO_WorldMap:IsHidden() then return end
	local t = GetGameTimeMilliseconds()
	if not table.empty(FyrMM.CustomPinList) and not IsCustomPinsLoading() then
		Treasures = {}
		FyrMM.AvailableQuestGivers = {}
		FyrMM.CustomPinCount = 0
		--FreeCustomPinIndex = {}
		CustomPinIndex = {}
		--LastCustomPinIndex = 0
		local c = 0
		for t, n in pairs(FyrMM.CustomPinList) do
			if not FyrMM.UpdatingCustomPins[t] then
				for i, v in pairs(n) do
					c = c + 1
					if v.pin == nil then
						InsertCustomPin(v, i)
					else
						local p = v.pin
						local pinType = p.m_PinType
						local Index = p.Index
						local Key = p.Key
						if pinType ~= nil then
							if not FyrMM.UpdatingCustomPins[pinType] then
								if CustomPinIndex[pinType] == nil then
									CustomPinIndex[pinType] = {}
								end
								CustomPinIndex[pinType][Index] = p
								FyrMM.CustomPinKeyIndex[pinType][Key] = Index
								FyrMM.CustomPinCount = FyrMM.CustomPinCount +1
								if type(p.m_PinTag) == "table" then
									if p.m_PinTag.IsAvailableQuest then
										table.insert(FyrMM.AvailableQuestGivers, pin)
									end
								end
								if string.sub(string.lower(p.pinTexture),1,12) == "losttreasure" then
									table.insert(Treasures, p)
								end
							end
						end
					end					
				end
			end
		end
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.CustomPins "..tostring(GetGameTimeMilliseconds()-t))
end

------------------------------------------------------------
-- Wayshrine Pins
-----------------------------------------------------------
function FyrMM.UpdateWayshrinePinPositions()
	if not FyrMM.Visible or Fyr_MM:IsHidden() or not ZO_WorldMap:IsHidden() then return end
	local currentZone = FyrMM.GetMapId()
	for i=1, FyrMM.currentWayshrineCount do
		local l = GetControl("Fyr_MM_Scroll_Map_WayshrinePins_Pin"..tostring(i))
		if l ~= nil then
			if l.MapId == currentZone then
				l:SetHidden(not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_WAYSHRINES))
				FyrMM.SetPinAnchor(l, l.nX, l.nY, Fyr_MM_Scroll_Map_WayshrinePins)
			else
				l:SetHidden(true)
				l:ClearAnchors()
			end
		end
	end
end

local function CreateWayshrinePin(pinType, tag, nX, nY)
	local wayshrinePin
	wayshrinePin = GetControl("Fyr_MM_Scroll_Map_WayshrinePins_Pin"..tostring(FyrMM.currentWayshrineCount))
	if wayshrinePin == nil then
		wayshrinePin = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_WayshrinePins_Pin"..tostring(FyrMM.currentWayshrineCount), Fyr_MM_Scroll_Map_WayshrinePins, CT_TEXTURE)
		wayshrinePin.nDistance = function(self) if self.nX == nil then return 1 end return math.sqrt((zo_round(CurrentMap.PlayerNX*10000)-zo_round(self.nX*10000))*(zo_round(CurrentMap.PlayerNX*10000)-zo_round(self.nX*10000))+(zo_round(CurrentMap.PlayerNY*10000)-zo_round(self.nY*10000))*(zo_round(CurrentMap.PlayerNX*10000)-zo_round(self.nY*10000)))/10000 end
		wayshrinePin:SetHandler("OnMouseEnter", PinOnMouseEnter)
		wayshrinePin:SetHandler("OnMouseExit", PinOnMouseExit)
		wayshrinePin:SetHandler("OnMouseUp", PinOnMouseUp)
	end
	local pin = ZO_Object.New(ZO_MapPin)
	local pinSize = 40 * FyrMM.pScalePercent
	pin.m_PinType = pinType
	pin.m_PinTag = tag
	pin.nX = nX
	pin.nY = nY
	wayshrinePin.m_Pin = pin
	wayshrinePin.MapId = FyrMM.GetMapId()
	wayshrinePin.nX = nX
	wayshrinePin.nY = nY
	wayshrinePin.m_PinType = pinType
	wayshrinePin:SetDrawLayer(1)
	FyrMM.SetPinSize(wayshrinePin, pinSize, 0)
	wayshrinePin:SetTexture(tag[2])
	wayshrinePin:SetHidden(not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_WAYSHRINES))
	FyrMM.SetPinAnchor(wayshrinePin, nX, nY, Fyr_MM_Scroll_Map_WayshrinePins)
	wayshrinePin:SetMouseEnabled(true)
	Wayshrines[FyrMM.currentWayshrineCount] = {Closest = false, nDistance = 1, tag = tag, nX = nX, nY = nY, MapId = FyrMM.GetMapId(), pin = wayshrinePin}
end

function FyrMM.Wayshrines()
	if FyrMM.Halted or GetNumFastTravelNodes() == 0 then return end
	if not FyrMM.Visible or Fyr_MM:IsHidden() or not ZO_WorldMap:IsHidden() then return end
	local t = GetGameTimeMilliseconds()
	FyrMM.SetMapToPlayerLocation()
	local mapContentType = GetMapContentType()
	FyrMM.currentWayshrineCount = 0
	Wayshrines = {}
	if CurrentMap.filename ~= "giantsrun_base_0" then
		for nodeIndex = 1, GetNumFastTravelNodes() do
			local known, name, nX, nY, icon, glowIcon, poiType = GetFastTravelNodeInfo(nodeIndex)
--			nX = zo_round(nX * 10000) / 10000
--			nY = zo_round(nY * 10000) / 10000
			if known or FyrMM.SV.ShowUnexploredPins then
				if not known then icon = "/esoui/art/icons/poi/poi_wayshrine_incomplete.dds" glowIcon = "/esoui/art/icons/poi/poi_wayshrine_glow.dds" end
				local tag = ZO_MapPin.CreateTravelNetworkPinTag(nodeIndex, icon, glowIcon)
				local pinType = MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE
				if nX > 0 and nX < 1.0001 and nY > 0 and nY < 1.0001 then
					FyrMM.currentWayshrineCount = FyrMM.currentWayshrineCount + 1
					CreateWayshrinePin(pinType, tag, nX, nY)					
				end
			end
		end
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.Wayshrines ("..tostring(GetNumFastTravelNodes())..") "..tostring(GetGameTimeMilliseconds()-t))
	CleanupWayshrines()
end
------------------------------------------------------------
-- POI Pins
------------------------------------------------------------
function FyrMM.UpdatePOIPinPositions()
	for i=1, FyrMM.currentPOICount do
		local l = GetControl("Fyr_MM_Scroll_Map_POIPins_Pin"..tostring(i))
		if l ~= nil then
			if l.MapId == FyrMM.GetMapId() then
				l:SetHidden(not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_OBJECTIVES))
				FyrMM.SetPinAnchor(l, l.nX, l.nY, Fyr_MM_Scroll_Map_POIPins)
			else
				l:SetHidden(true)
				l:ClearAnchors()
			end
		end
	end
end

local function CreatePOIPin(poiIndex)
	local POIPin
	local nX, nY, iconType, icon = MM_GetPOIMapInfo(CurrentMap.ZoneId, poiIndex)
--	nX = zo_round(nX * 10000) / 10000
--	nY = zo_round(nY * 10000) / 10000
	if CraftingStations ~= nil and zo_strfind(icon, "icons/poi/poi_crafting_") then return end -- Crafting stations mix-up fix by Garkin
	if not (ZO_MapPin.POI_PIN_TYPES[iconType]) and FyrMM.SV.ShowUnexploredPins then icon = "/esoui/art/inventory/newitem_icon.dds" iconType = MAP_PIN_TYPE_POI_SEEN end
	if nX > 0 and nX < 1.0001 and nY > 0 and nY < 1.0001 and (ZO_MapPin.POI_PIN_TYPES[iconType]) then
		if(not IsPOIWayshrine(CurrentMap.ZoneId, poiIndex) or iconType == MAP_PIN_TYPE_POI_SEEN ) then
			FyrMM.currentPOICount = FyrMM.currentPOICount + 1
			local tag = ZO_MapPin.CreatePOIPinTag(CurrentMap.ZoneId, poiIndex, icon)
			POIPin = GetControl("Fyr_MM_Scroll_Map_POIPins_Pin"..tostring(FyrMM.currentPOICount))
			if POIPin == nil then
				POIPin = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_POIPins_Pin"..tostring(FyrMM.currentPOICount), Fyr_MM_Scroll_Map_POIPins, CT_TEXTURE)
				POIPin:SetHandler("OnMouseEnter", PinOnMouseEnter)
				POIPin:SetHandler("OnMouseExit", PinOnMouseExit)
			end
			local pin = ZO_Object.New(ZO_MapPin)
			local pinSize = 40 * FyrMM.pScalePercent
			if icon == "/esoui/art/inventory/newitem_icon.dds" then
				pinSize = 32 * FyrMM.pScalePercent
				POIPin:SetColor(FyrMM.SV.UndiscoveredPOIPinColor.r, FyrMM.SV.UndiscoveredPOIPinColor.g, FyrMM.SV.UndiscoveredPOIPinColor.b, FyrMM.SV.UndiscoveredPOIPinColor.a)
			else
				POIPin:SetColor(1, 1, 1, 1)
			end
			POIPin.poiIndex = poiIndex
			pin.m_PinType = iconType
			pin.m_PinTag = tag
			POIPin.m_Pin = pin
			POIPin.MapId = FyrMM.GetMapId()
			POIPin.nX = nX
			POIPin.nY = nY
			POIPin.m_PinType = iconType
			POIPin:SetDrawLayer(1)
			FyrMM.SetPinSize(POIPin, pinSize, 0)
			POIPin:SetTexture(icon)
			POIPin:SetHidden(not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_OBJECTIVES))
			FyrMM.SetPinAnchor(POIPin, nX, nY, Fyr_MM_Scroll_Map_POIPins)
			POIPin:SetMouseEnabled(true)
		end
	end
end

function FyrMM.POIPins()
	if FyrMM.Halted or MM_GetNumPOIs(CurrentMap.ZoneId) == 0 then return end
	local t = GetGameTimeMilliseconds()
	FyrMM.currentPOICount = 0
	FyrMM.API_Check()
	FyrMM.SetMapToPlayerLocation()
	if CurrentMap.filename ~= "giantsrun_base_0" then
		for i = 1, MM_GetNumPOIs(CurrentMap.ZoneId) do
			if FyrMM.Reloading then return end
			CreatePOIPin(i)
		end
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.POIPins ("..tostring(MM_GetNumPOIs(CurrentMap.ZoneId))..") "..tostring(GetGameTimeMilliseconds()-t))
	if FyrMM.currentPOICount == 0 and Fyr_MM_Scroll_Map_POIPins:GetNumChildren() == CleanPOIs then return end
	CleanPOIs = 0
	CleanupPOIs()
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapPOIPinsD")
end

local function DelayedPOIPins()
	EVENT_MANAGER:RegisterForUpdate("FyrMiniMapPOIPinsD", 300,  FyrMM.POIPins)
end
------------------------------------------------------------
-- Location Pins
------------------------------------------------------------

function FyrMM.UpdateLocationPinPositions()
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "MM_UpdateLocationPinPositions ("..tostring(FyrMM.currentLocationsCount)..") ")
	for i=1, FyrMM.currentLocationsCount do
		local l = GetControl("Fyr_MM_Scroll_Map_LocationPins_Pin"..tostring(i))
		if l ~= nil then
			if l.MapId == FyrMM.GetMapId() then
				if FyrMM.SV.ShowUnexploredPins then
					l:SetHidden(false)
				else
					if l:IsHidden() then l:SetHidden(not MM_IsMapLocationVisible(i)) end
				end
				FyrMM.SetPinAnchor(l, l.nX, l.nY, Fyr_MM_Scroll_Map_LocationPins)
			else
				l:SetHidden(true)
				l:ClearAnchors()
			end
		end
	end
end

local function AddLocation(locationIndex)
	local locationPin
	if(MM_IsMapLocationVisible(locationIndex) or FyrMM.SV.ShowUnexploredPins) then
		local icon, x, y = MM_GetMapLocationIcon(locationIndex)
--		x = zo_round(x * 10000) / 10000
--		y = zo_round(y * 10000) / 10000
		if icon ~= "" and x > 0 and x < 1.0001 and y > 0 and y < 1.0001 then
			FyrMM.currentLocationsCount = FyrMM.currentLocationsCount + 1
			local tag = ZO_MapPin.CreateLocationPinTag(locationIndex, icon)
			locationPin = GetControl("Fyr_MM_Scroll_Map_LocationPins_Pin"..tostring(FyrMM.currentLocationsCount))
			if locationPin == nil then
				locationPin = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_LocationPins_Pin"..tostring(FyrMM.currentLocationsCount), Fyr_MM_Scroll_Map_LocationPins, CT_TEXTURE)
				locationPin:SetHandler("OnMouseEnter", PinOnMouseEnter)
				locationPin:SetHandler("OnMouseExit", PinOnMouseExit)
			end
			local pinSize = 36 * FyrMM.pScalePercent
			local pin = ZO_Object.New(ZO_MapPin)
			locationPin.locationIndex = locationIndex
			pin.m_PinType = MAP_PIN_TYPE_LOCATION
			pin.m_PinTag = tag
			locationPin.m_Pin = pin
			locationPin.m_PinType = MAP_PIN_TYPE_LOCATION
			locationPin.m_PinTag = tag
			locationPin.MapId = FyrMM.GetMapId()
			locationPin.nX = x
			locationPin.nY = y
			FyrMM.SetPinSize(locationPin, pinSize, 0)
			locationPin:SetDrawLayer(1)
			locationPin:SetTexture(icon)
			locationPin.IsCraftingServicePin = IsCraftingService(locationPin)
			if tag[2] ~= nil then
				if string.sub(tag[2],-8) == "bank.dds" then
					locationPin.IsBankPin = true
				else
					locationPin.IsBankPin = false
				end
				if string.sub(tag[2],-10) == "stable.dds" then
					locationPin.IsStablePin = true
				else
					locationPin.IsStablePin = false
				end
			end
			if string.sub(icon, 1, 17) ~= "ZygorGuidesViewer" then
				if FyrMM.SV.ShowUnexploredPins then
					locationPin:SetHidden(false)
				else
					if locationPin:IsHidden() then locationPin:SetHidden(not MM_IsMapLocationVisible(i)) end
				end
			else
				locationPin:SetHidden(false)
			end
			FyrMM.SetPinAnchor(locationPin, x, y, Fyr_MM_Scroll_Map_LocationPins)
			locationPin:SetMouseEnabled(true)
		end
	end
end

function FyrMM.LocationPins()
	if FyrMM.Halted or MM_GetNumMapLocations() == 0 then return end -- delay if still halted
	local t = GetGameTimeMilliseconds()
	FyrMM.currentLocationsCount = 0
	FyrMM.API_Check()
	FyrMM.SetMapToPlayerLocation()
	if CurrentMap.filename ~= "giantsrun_base_0" then
		for i = 1, MM_GetNumMapLocations() do
			if FyrMM.Reloading then return end
			AddLocation(i)
		end
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.LocationPins ("..tostring(MM_GetNumMapLocations())..") "..tostring(GetGameTimeMilliseconds()-t))
	CleanupMapLocations()
end

------------------------------------------------------------
-- Group Pins
------------------------------------------------------------
function FyrMM.GroupEvent()
	FyrMM.GroupRefreshNeeded = true
	FyrMM.RefreshGroup()
end

function FyrMM.SetGroupPinTexture(gmPin)
	--local LeaderPinSize = FyrMM.SV.LeaderPinSize * FyrMM.pScalePercent
	--local MemberPinSize = FyrMM.SV.MemberPinSize * FyrMM.pScalePercent
	local gmPinTexture =""
	if gmPin.isLeader then
		if FyrMM.SV.LeaderPin == "Default" then
			gmPinTexture = "EsoUI/Art/Compass/groupLeader.dds"
		elseif FyrMM.SV.LeaderPin == "Class" then
			gmPinTexture = GetClassIcon(gmPin.ClassId)
		elseif gmPin.isDps then
		gmPinTexture = "EsoUI/Art/LFG/LFG_dps_down.dds"
		elseif gmPin.isHeal then
		gmPinTexture = "EsoUI/Art/LFG/LFG_healer_down.dds"
		elseif gmPin.isTank then
		gmPinTexture = "EsoUI/Art/LFG/LFG_tank_down.dds"
		else
		gmPinTexture = "EsoUI/Art/Compass/groupLeader.dds"
		end
		FyrMM.SetPinSize(gmPin, FyrMM.SV.LeaderPinSize * FyrMM.pScalePercent, 0)
	else
		if FyrMM.SV.MemberPin == "Default" then
			gmPinTexture = "EsoUI/Art/MapPins/UI-WorldMapGroupPip.dds"
		elseif FyrMM.SV.MemberPin == "Class" then
			gmPinTexture = GetClassIcon(gmPin.ClassId)
		elseif gmPin.isDps then
		gmPinTexture = "EsoUI/Art/LFG/LFG_dps_down.dds"
		elseif gmPin.isHeal then
		gmPinTexture = "EsoUI/Art/LFG/LFG_healer_down.dds"
		elseif gmPin.isTank then
		gmPinTexture = "EsoUI/Art/LFG/LFG_tank_down.dds"
		else
			gmPinTexture = "EsoUI/Art/MapPins/UI-WorldMapGroupPip.dds"
		end
		FyrMM.SetPinSize(gmPin, FyrMM.SV.MemberPinSize * FyrMM.pScalePercent, 0)
	end
	gmPin:SetTexture(gmPinTexture)
end

function FyrMM.SetGroupPin(tag)
	local pin, pin_ic, text, nX, nY
	local isDps, isHeal, isTank = GetGroupMemberRoles(tag)
	local isDead = IsUnitDead(tag)
	pin = GetControl("Fyr_MM_Scroll_Map_GroupPins_"..tag)
	pin_ic = GetControl("Fyr_MM_Scroll_Map_GroupPins_"..tag.."_incombat")
	text = GetControl("Fyr_MM_Scroll_Map_GroupPins_"..tag.."_label")
	if not (DoesUnitExist(tag) and not AreUnitsEqual("player", tag) and IsUnitOnline(tag)) then
		if pin ~= nil then
			pin:SetHidden(true)
			pin:SetMouseEnabled(false)
			pin:ClearAnchors()
			pin.isDps = nil
			pin.isHeal = nil
			pin.isTank = nil
			pin.ClassId = nil
			pin.isLeader = nil
			pin.nX = nil
			pin.nY = nil
			pin_ic.nX = nil
			pin_ic.nY = nil
			pin_ic:SetHidden(true)
			pin_ic:ClearAnchors()
			PinsList["Fyr_MM_Scroll_Map_GroupPins_"..tag] = nil
			PinsList["Fyr_MM_Scroll_Map_GroupPins_"..tag.."_incombat"] = nil			
			if pin.OnBorder then
				if pin.BorderPin then
					pin.BorderPin:ClearAnchors()
					pin.BorderPin:SetHidden()
					pin.BorderPin.pin = nil
					pin.BorderPin = nil
				end
				pin.OnBorder = nil
			end
		end
		return
	end
	if pin == nil then return end
	nX, nY = GetMapPlayerPosition(tag)
--	nX = zo_round(nX * 10000) / 10000
--	nY = zo_round(nY * 10000) / 10000
	pin.isDps = isDps
	pin.isHeal = isHeal
	pin.isTank = isTank
	pin.isLeader = IsUnitGroupLeader(tag)
	if pin.isLeader then
		pin.m_PinType = MAP_PIN_TYPE_GROUP_LEADER
		if FyrMM.SV.LeaderPinColor ~= nil and FyrMM.SV.LeaderDeadPinColor ~= nil then
			if isDead then
				pin:SetColor(FyrMM.SV.LeaderDeadPinColor.r, FyrMM.SV.LeaderDeadPinColor.g, FyrMM.SV.LeaderDeadPinColor.b, FyrMM.SV.LeaderDeadPinColor.a)
				text:SetColor(255 - FyrMM.SV.LeaderDeadPinColor.r, 255 - FyrMM.SV.LeaderDeadPinColor.g, 255 - FyrMM.SV.LeaderDeadPinColor.b, FyrMM.SV.LeaderDeadPinColor.a)
			else
				pin:SetColor(FyrMM.SV.LeaderPinColor.r, FyrMM.SV.LeaderPinColor.g, FyrMM.SV.LeaderPinColor.b, FyrMM.SV.LeaderPinColor.a)
				text:SetColor(255 - FyrMM.SV.LeaderPinColor.r, 255 - FyrMM.SV.LeaderPinColor.g, 255 - FyrMM.SV.LeaderPinColor.b, FyrMM.SV.LeaderPinColor.a)
			end
		else
			text:SetColor(0,0,0,1)
		end
	else
		pin.m_PinType = MAP_PIN_TYPE_GROUP
		if FyrMM.SV.MemberPinColor ~= nil and FyrMM.SV.MemberDeadPinColor ~= nil then
			if isDead then
				pin:SetColor(FyrMM.SV.MemberDeadPinColor.r, FyrMM.SV.MemberDeadPinColor.g, FyrMM.SV.MemberDeadPinColor.b, FyrMM.SV.MemberDeadPinColor.a)
				text:SetColor(255 - FyrMM.SV.MemberDeadPinColor.r, 255 - FyrMM.SV.MemberDeadPinColor.g, 255 - FyrMM.SV.MemberDeadPinColor.b, FyrMM.SV.MemberDeadPinColor.a)
			else
				pin:SetColor(FyrMM.SV.MemberPinColor.r, FyrMM.SV.MemberPinColor.g, FyrMM.SV.MemberPinColor.b, FyrMM.SV.MemberPinColor.a)
				text:SetColor(255 - FyrMM.SV.MemberPinColor.r, 255 - FyrMM.SV.MemberPinColor.g, 255 - FyrMM.SV.MemberPinColor.b, FyrMM.SV.MemberPinColor.a)
			end
		else
			text:SetColor(0,0,0,1)
		end
	end
	pin.ClassId = GetUnitClassId(tag)
	pin.nX = nX
	pin.nY = nY
	pin.unitTag = tag
	if (IsUnitInCombat(tag) and FyrMM.SV.InCombatState) then
		pin_ic.nX = nX
		pin_ic.nY = nY
		pin_ic:SetHidden(false)
		FyrMM.SetPinAnchor(pin_ic, nX, nY, Fyr_MM_Scroll_Map_GroupPins)
	else
		PinsList["Fyr_MM_Scroll_Map_GroupPins_"..tag.."_incombat"] = nil	
		pin_ic.nX = nil
		pin_ic.nY = nil
		pin_ic:SetHidden(true)
		pin_ic:ClearAnchors()
	end
	if FyrMM.SV.ShowGroupLabels then
		text:SetText(tostring(GetGroupIndexByUnitTag(tag)))
		text:SetHidden(false)
	else
		text:SetText("")
	end
	FyrMM.SetGroupPinTexture(pin)
	FyrMM.SetPinSize(pin_ic, pin:GetDesiredHeight()+6, 0)
	pin:SetDrawLayer(3)
	pin_ic:SetDrawLayer(2)
	pin:SetMouseEnabled(true)
	FyrMM.SetPinAnchor(pin, nX, nY, Fyr_MM_Scroll_Map_GroupPins)
	PinsList["Fyr_MM_Scroll_Map_GroupPins_"..tag.."_incombat"] = nil
	if FyrMM.SV.WheelMap then
		pin:SetHidden(not Is_PinInsideWheel(pin))
	else
		pin:SetHidden(false)
	end
	if FyrMM.IsValidBorderPin(pin) then
		FyrMM.CreateBorderPin(pin)
	end
end

local function ClearGroupPins()
	local pin, pin_ic, tag
	for i = 1, 24 do
		tag = "group"..tostring(i)
		local pin = GetControl("Fyr_MM_Scroll_Map_GroupPins_"..tag)
		local pin_ic = GetControl("Fyr_MM_Scroll_Map_GroupPins_"..tag.."_incombat")
		if pin ~= nil then
			pin:SetHidden(true)
			pin:SetMouseEnabled(false)
			pin:ClearAnchors()
			pin.isDps = nil
			pin.isHeal = nil
			pin.isTank = nil
			pin.ClassId = nil
			pin.isLeader = nil
			pin.nX = nil
			pin.nY = nil
			pin_ic.nX = nil
			pin_ic.nY = nil
			pin_ic:SetHidden(true)
			pin_ic:ClearAnchors()
			PinsList["Fyr_MM_Scroll_Map_GroupPins_"..tag] = nil
			PinsList["Fyr_MM_Scroll_Map_GroupPins_"..tag.."_incombat"] = nil			
			if pin.OnBorder then
				if pin.BorderPin then
					pin.BorderPin:ClearAnchors()
					pin.BorderPin:SetHidden()
					pin.BorderPin.pin = nil
					pin.BorderPin = nil
				end
				pin.OnBorder = nil
			end
		end
	end
end

function FyrMM.RefreshGroup()
	if not FyrMM.GroupRefreshNeeded then return end
	local maxgroupsize = 24
	local tag, pin, pin_ic
	if not IsUnitGrouped("player") then
		ClearGroupPins()
		return
	end 
	local nogroup = (GetGroupSize() == 0)
	local t = GetGameTimeMilliseconds()
	if GetGroupSize() > 24 then maxgroupsize = GetGroupSize() end -- Crazy wishfull thinking :)
	for i = 1, maxgroupsize do
		if FyrMM.Reloading then return end
		tag = "group"..tostring(i)
		if maxgroupsize > 24 then  -- Very crazy wishfull thinking :)
			if GetControl("Fyr_MM_Scroll_Map_GroupPins_"..tag) == nil then
				pin = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_GroupPins_"..tag, Fyr_MM_Scroll_Map_GroupPins, CT_TEXTURE)
				pin:SetHandler("OnMouseEnter", PinOnMouseEnter)
				pin:SetHandler("OnMouseExit", PinOnMouseExit)
			end
			if GetControl("Fyr_MM_Scroll_Map_GroupPins_"..tag.."_incombat") == nil then
				pin_ic = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_GroupPins_"..tag.."_incombat", Fyr_MM_Scroll_Map_GroupPins, CT_TEXTURE)
				pin_ic:SetTexture("esoui/art/mappins/ava_attackburst_32.dds")
			end
		end
		FyrMM.SetGroupPin(tag)
	end
	if GetGroupSize() == 0 then
		FyrMM.GroupRefreshNeeded = false
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.RefreshGroup "..tostring(GetGameTimeMilliseconds()-t))
end

---------------------------------------------------
-- Quest pin updates
---------------------------------------------------
function FyrMM.GetQuestPinInfo(pinType, isassited, isBreadcrumb, areaRadius)
	if areaRadius == nil then
		areaRadius = 0
	end
	local mWidth, mHeight = Fyr_MM_Scroll_Map:GetDimensions()
	local Diameter = areaRadius * 2 * mHeight
	if Diameter < 16 then
		Diameter = 16
	end
	local properType, properTexture
	if (pinType == MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION or pinType == MAP_PIN_TYPE_TRACKED_QUEST_CONDITION) then
		if isassited then
			properType = MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION
		else
			properType = MAP_PIN_TYPE_TRACKED_QUEST_CONDITION
		end
	end
	if (pinType == MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION or pinType == MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION) then
		if isassited then
			properType = MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION
		else
			properType = MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION
		end
	end
	if (pinType == MAP_PIN_TYPE_ASSISTED_QUEST_ENDING or pinType == MAP_PIN_TYPE_TRACKED_QUEST_ENDING) then
		if isassited then
			properType = MAP_PIN_TYPE_ASSISTED_QUEST_ENDING
		else
			properType = MAP_PIN_TYPE_TRACKED_QUEST_ENDING
		end
	end
	if areaRadius == 0 then
		if isBreadcrumb then
			return properType, breadcrumbQuestPinTextures[properType], 32 * FyrMM.pScalePercent
		else
			return properType, questPinTextures[properType], 32 * FyrMM.pScalePercent
		end
	else
		if Diameter > 24 then
			if(isassited) then
				return properType, "EsoUI/Art/MapPins/map_assistedAreaPin.dds", Diameter
			else
				return properType, "EsoUI/Art/MapPins/map_areaPin.dds", Diameter
			end
		else
			if(isassited) then
				return properType, "EsoUI/Art/MapPins/map_assistedAreaPin_32.dds", Diameter
			else
				return properType, "EsoUI/Art/MapPins/map_areaPin_32.dds", Diameter
			end
		end
	end
end

function FyrMM.ApplyProperQuestPinTextures() -- Discrepany fix
	local l, pinType
	for i = 1, MAX_JOURNAL_QUESTS do
		if(IsValidQuestIndex(i)) then
			for a=1, FyrMM.questPinCount do
				l = GetControl("Fyr_MM_Scroll_Map_QuestPins_Pin"..tostring(a))
				if l ~= nil then
					if l.questIndex == i and not l:IsHidden(true) then
						if IsAssisted(l.m_PinType) ~= FyrMM.GetQuestPinInfo(GetTrackedByIndex(i)) then -- discrepancy
							local properType, pinTexture, size = FyrMM.GetQuestPinInfo(l.m_PinType, GetTrackedIsAssisted(TRACK_TYPE_QUEST, l.questIndex), l.m_PinTag.isBreadcrumb, l.areaRadius)
							l.m_PinType = properType
							l:SetTexture(pinTexture)
							FyrMM.SetPinSize(l, size, 0)
							if GetTrackedIsAssisted(TRACK_TYPE_QUEST, l.questIndex) then
								l:SetDrawLayer(3)
							else
								l:SetDrawLayer(2)
							end
						end
					end
				end
			end
		end
	end
end

--local function SetAreaPinTextureAndSize(pin, pinDiameter)
--	local pinType = pin.m_PinType
--	if(ZO_MapPin.PIN_DATA[pinType].minAreaSize and pinDiameter < ZO_MapPin.PIN_DATA[pinType].minAreaSize) then
--		pinDiameter = ZO_MapPin.PIN_DATA[pinType].minAreaSize
--	end
--	if(pinDiameter > 48) then
--		if(ASSISTED_PIN_TYPES[pinType]) then
--			pin:SetTexture("EsoUI/Art/MapPins/map_assistedAreaPin.dds")
--		else
--			pin:SetTexture("EsoUI/Art/MapPins/map_areaPin.dds")
--		end
--	else
--		if(ASSISTED_PIN_TYPES[pinType]) then
--			pin:SetTexture("EsoUI/Art/MapPins/map_assistedAreaPin_32.dds")
--		else
--			pin:SetTexture("EsoUI/Art/MapPins/map_areaPin_32.dds")
--		end
--	end
--	if pinDiameter < 16 then
--		pinDiameter = 16
--	end
--	FyrMM.SetPinSize(pin, pinDiameter, 0)
--end

local function UpdateQuestPinPosition(l)
	if l ~= nil then
		if l.MapId == FyrMM.GetMapId() and l.m_PinTag and l.m_PinTag then
			local properType, pinTexture, size = FyrMM.GetQuestPinInfo(l.m_PinType, GetTrackedIsAssisted(TRACK_TYPE_QUEST, l.questIndex), l.m_PinTag.isBreadcrumb, l.areaRadius)
			l.m_PinType = properType
			l:SetTexture(pinTexture)
			FyrMM.SetPinSize(l, size, 0)
			l:SetHidden(not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_QUESTS))
			if GetTrackedIsAssisted(TRACK_TYPE_QUEST, l.questIndex) then
				l:SetDrawLayer(3)
			else
				l:SetDrawLayer(2)
			end
			FyrMM.SetPinAnchor(l, l.normalizedX, l.normalizedY, Fyr_MM_Scroll_Map_QuestPins)
			if FyrMM.SV.WheelMap and l.areaRadius > 0 and l.MM_Tag == nil then
				l:SetParent(Fyr_MM_Scroll_CW_Map_Pins)
			else
				if l.MM_Tag ~= nil then
					if not FyrMM.SV.WheelMap then
						if l.MM_Tag == 1 then
							l:SetParent(Fyr_MM_Scroll_Map_QuestPins)
						end
					else
						if l.areaRadius > 0 then
							if l.MM_Tag == 1 then
								l:SetParent(Fyr_MM_Scroll_CW_Map_Pins)
								if l.secondaryPin ~= nil then
									l.secondaryPin:SetTexture(pinTexture)
								end
								if l.tertiaryPin ~= nil then
									l.tertiaryPin:SetTexture(pinTexture)
								end				
							end
							if l.MM_Tag == 2 then
								l:SetParent(Fyr_MM_Scroll_NS_Map_Pins)
							end
							if l.MM_Tag == 3 then
								l:SetParent(Fyr_MM_Scroll_WE_Map_Pins)
							end
						else
							l.MM_Tag = nil
							l:SetParent(Fyr_MM_Scroll_Map_QuestPins)
						end
					end
				end
			end
			if FyrMM.IsValidBorderPin(l) then
				FyrMM.CreateBorderPin(l)
			end
		else
			l:SetHidden(true)
			l:ClearAnchors()
		end
	end
end

function FyrMM.UpdateQuestPinPositions()
	if QuestPinsUpdating then return end
	for i, v in pairs(QuestPins) do
		UpdateQuestPinPosition(v.Pin)
		if v.Pin.secondaryPin ~= nil then
			UpdateQuestPinPosition(v.Pin.secondaryPin)
		end
		if v.Pin.tertiaryPin ~= nil then
			UpdateQuestPinPosition(v.Pin.tertiaryPin)
		end
	end
end


local function PlayTextureAnimation(pin, loopCount)
	if not pin.m_textureAnimTimeline then
		local anim
		anim, pin.m_textureAnimTimeline = CreateSimpleAnimation(ANIMATION_TEXTURE, pin)
		anim:SetImageData(32, 1)
		anim:SetFramerate(32)
		anim:SetHandler("OnStop", function() pin:SetTextureCoords(0, 1, 0, 1) end)
	end
	pin.m_textureAnimTimeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, loopCount)
	pin.m_textureAnimTimeline:PlayFromStart()
end

local function ResetAnimation(pin, resetOptions, loopCount, pulseIcon, overlayIcon, postPulseCallback, min, max)
	resetOptions = resetOptions or RESET_ANIM_PREVENT_PLAY

	-- The animated control
	local pulseControl = pin
	
	if(resetOptions == RESET_ANIM_ALLOW_PLAY) then   
		pulseControl:SetHidden(pulseIcon == nil)
		if(pulseIcon) then
			pulseControl:SetTexture(pulseIcon)
			postPulseCallback = postPulseCallback or ZO_MapPin.DoFinalFadeOutAfterPing
			ZO_AlphaAnimation_GetAnimation(pulseControl):PingPong(.3, 1, 750, loopCount, postPulseCallback)
		end
	elseif(resetOptions == RESET_ANIM_HIDE_CONTROL) then
		ZO_AlphaAnimation_GetAnimation(pulseControl):Stop()
		pulseControl:SetHidden(true)
		pulseControl:StopTextureAnimation()
	elseif(resetOptions == RESET_ANIM_PREVENT_PLAY) then
		ZO_AlphaAnimation_GetAnimation(pulseControl):FadeOut(0, 300, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA, ZO_MapPin.HidePulseAfterFadeOut)
	end
end

local function CreateQuestAreaSidePins(pin)
	local index
	local properType, pinTexture, size = FyrMM.GetQuestPinInfo(pinType, GetTrackedIsAssisted(TRACK_TYPE_QUEST, pin.m_PinTag[1]), pin.m_PinTag.isBreadcrumb, pin.areaRadius)
	FyrMM.questPinCount = FyrMM.questPinCount+1
	local questPinNS
	index = GetQuestFreePinIndex()
	questPinNS = GetControl("Fyr_MM_Scroll_Map_QuestPins_Pin"..tostring(index))
	if questPinNS == nil then
		questPinNS = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_QuestPins_Pin"..tostring(index), Fyr_MM_Scroll_NS_Map_Pins, CT_TEXTURE)
	else
		questPinNS:SetParent(Fyr_MM_Scroll_NS_Map_Pins)
	end
	questPinNS.m_PinTag = pin.m_PinTag
	questPinNS.questIndex = pin.questIndex
	questPinNS.m_PinType = properType
	questPinNS.PinToolTipText = pin.PinToolTipText
	questPinNS.questName = pin.questName
	questPinNS.normalizedX = pin.normalizedX
	questPinNS.normalizedY = pin.normalizedY
	questPinNS.areaRadius = pin.areaRadius
	questPinNS.MapId = pin.MapId
	questPinNS:SetTexture(pinTexture)
	FyrMM.SetPinSize(questPinNS, size, 0)
	questPinNS.pinAge = pin.pinAge
	questPinNS:SetHidden(not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_QUESTS))
	questPinNS.MM_Tag = 2
	questPinNS.primaryPin = pin
	pin.secondaryPin = questPinNS
	FyrMM.SetPinAnchor(questPinNS, questPinNS.normalizedX, questPinNS.normalizedY, Fyr_MM_Scroll_Map_QuestPins)
	questPinNS:SetHandler("OnMouseUp", PinOnMouseUp)
	questPinNS:SetHandler("OnMouseEnter", PinOnMouseEnter)
	questPinNS:SetHandler("OnMouseExit", PinOnMouseExit)
			
	FyrMM.questPinCount = FyrMM.questPinCount+1
	local questPinWE
	index = GetQuestFreePinIndex()
	questPinWE = GetControl("Fyr_MM_Scroll_Map_QuestPins_Pin"..tostring(index))
	if questPinWE == nil then
		questPinWE = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_QuestPins_Pin"..tostring(index), Fyr_MM_Scroll_WE_Map_Pins, CT_TEXTURE)
	else
		questPinWE:SetParent(Fyr_MM_Scroll_WE_Map_Pins)
	end
	questPinWE.m_PinTag = pin.m_PinTag
	questPinWE.questIndex = pin.questIndex
	questPinWE.m_PinType = properType
	questPinWE.PinToolTipText = pin.PinToolTipText
	questPinWE.questName = pin.questName
	questPinWE.normalizedX = pin.normalizedX
	questPinWE.normalizedY = pin.normalizedY
	questPinWE.areaRadius = pin.areaRadius
	questPinWE.MapId = pin.MapId
	questPinWE:SetTexture(pinTexture)
	FyrMM.SetPinSize(questPinWE, size, 0)
	questPinWE.pinAge = pin.pinAge
	questPinWE:SetHidden(not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_QUESTS))
	questPinWE.MM_Tag = 3
	questPinWE.primaryPin = pin
	pin.tertiaryPin = questPinWE
	FyrMM.SetPinAnchor(questPinWE, questPinWE.normalizedX, questPinWE.normalizedY, Fyr_MM_Scroll_Map_QuestPins)
	questPinWE:SetHandler("OnMouseUp", PinOnMouseUp)
	questPinWE:SetHandler("OnMouseEnter", PinOnMouseEnter)
	questPinWE:SetHandler("OnMouseExit", PinOnMouseExit)
end

local function QuestPinExists(pinType, tag, xLoc, yLoc, areaRadius)
	local l
	for i, v in pairs(QuestPins) do
		if v.Pin ~= nil then
			l = v.Pin
			if l.m_PinTag then
				if l.m_PinTag[1] == tag[1] and l.m_PinTag[2] == tag[2] and l.m_PinTag[3] == tag[3] and l.m_PinType == pinType and l.areaRadius == areaRadius and l.normalizedX == xLoc and l.normalizedY == yLoc then
					RemoveQuestPin(l)
				end
			end
		end
	end
	return false
end

function FyrMM.CreateQuestPin(pinType, tag, xLoc, yLoc, areaRadius)
	if QuestPinExists(pinType, tag, xLoc, yLoc, areaRadius) then return end -- dupe elimination
	FyrMM.questPinCount = FyrMM.questPinCount+1
	local questPin
	local pinData = {}
	local index = GetQuestFreePinIndex()
	questPin = GetControl("Fyr_MM_Scroll_Map_QuestPins_Pin"..tostring(index))	
	if FyrMM.SV.WheelMap and areaRadius > 0 then
		if questPin == nil then
			questPin = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_QuestPins_Pin"..tostring(index), Fyr_MM_Scroll_CW_Map_Pins, CT_TEXTURE)
		else
			questPin:SetParent(Fyr_MM_Scroll_CW_Map_Pins)
		end
	else
		if questPin == nil then
			questPin = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_QuestPins_Pin"..tostring(index), Fyr_MM_Scroll_Map_QuestPins, CT_TEXTURE)
		else
			questPin:SetParent(Fyr_MM_Scroll_Map_QuestPins)
		end
	end
	local properType, pinTexture, size = FyrMM.GetQuestPinInfo(pinType, GetTrackedIsAssisted(TRACK_TYPE_QUEST, tag[1]), tag.isBreadcrumb, areaRadius)
	pinType = properType
	questPin.m_PinTag = tag
	questPin.questIndex = tag[1]
	questPin.m_PinType = properType
	questPin.PinToolTipText = GenerateQuestConditionTooltipLine(tag[1], tag[3], tag[2])
	questPin.questName = GetJournalQuestName(tag[1])
	questPin.normalizedX = xLoc
	questPin.normalizedY = yLoc
	questPin.areaRadius = areaRadius
	questPin.MapId = FyrMM.GetMapId()

	questPin.pinAge = GetFrameTimeMilliseconds()

	pinData.questIndex = tag[1]
	pinData.questName = GetJournalQuestName(tag[1])
	pinData.coditionText = GenerateQuestConditionTooltipLine(tag[1], tag[3], tag[2])
	pinData.stepIndex = tag[3]
	pinData.conditionIndex = tag[2]
	pinData.pinIndex = index
	pinData.normalizedX = xLoc
	pinData.normalizedY = yLoc
	pinData.areaRadius = areaRadius
	pinData.isBreadcrumb = tag.isBreadcrumb
	pinData.isAssisted = GetTrackedIsAssisted(TRACK_TYPE_QUEST, tag[1])
	pinData.MapId = FyrMM.GetMapId()
	pinData.Pin = questPin
	pinData.tag = tag
	local questdataIndex = questpinDataExists(pinData, QuestPins)
	if questdataIndex == nil then
		table.insert(QuestPins, pinData)
		questdataIndex = questpinDataExists(pinData, QuestPins)
	else
		QuestPins[questdataIndex] = pinData
	end
	questPin.questdataIndex = questdataIndex
	local questPinData = ZO_MapPin.PIN_DATA[pinType]
	if(questPinData ~= nil) then
		local _, pulseTexture, glowTexture = GetPinTexture(pinType, questPin)
		questPin:SetTexture(pinTexture)
		FyrMM.SetPinSize(questPin, size, 0)
		if(pulseTexture) then
			ResetAnimation(questPin, RESET_ANIM_ALLOW_PLAY, LONG_LOOP_COUNT, pulseTexture, overlayTexture, ZO_MapPin.DoFinalFadeInAfterPing)
		else if(glowTexture) then
			ResetAnimation(questPin, RESET_ANIM_HIDE_CONTROL)
			end
		end
		questPin:SetDrawLevel(zo_max(questPinData.level, 1))
		if(questPinData.isAnimated) then
			PlayTextureAnimation(questPin, LOOP_INDEFINITELY)
		end
		if FyrMM.SV.WheelMap and questPin.areaRadius > 0 then
			questPin.MM_Tag = 1
			CreateQuestAreaSidePins(questPin)
		else
			if questPin.secondaryPin ~= nil then
					questPin.secondaryPin.MM_Tag = nil
					RemoveQuestPin(questPin.secondaryPin)
			end
			if questPin.tertiaryPin ~= nil then
					questPin.tertiaryPin.MM_Tag = nil
					RemoveQuestPin(questPin.tertiaryPin)
			end
			questPin.MM_Tag = nil
			questPin.primaryPin = nil
			questPin.secondaryPin = nil
			questPin.tertiaryPin = nil
			questPin:SetParent(Fyr_MM_Scroll_Map_QuestPins)
		end
		questPin:SetHidden(not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_QUESTS))
		FyrMM.SetPinAnchor(questPin, questPin.normalizedX, questPin.normalizedY, Fyr_MM_Scroll_Map_QuestPins)
		if FyrMM.IsValidBorderPin(questPin) then
			FyrMM.CreateBorderPin(questPin)
		end
		if GetTrackedIsAssisted(TRACK_TYPE_QUEST, tag[1]) then
			questPin:SetDrawLayer(3)
		else
			questPin:SetDrawLayer(2)
		end
		questPin:SetHandler("OnMouseUp", PinOnMouseUp)
		questPin:SetHandler("OnMouseEnter", PinOnMouseEnter)
		questPin:SetHandler("OnMouseExit", PinOnMouseExit)
		questPin:SetMouseEnabled(true)
	end
end

local function OnQuestPositionRequestComplete(eventCode, taskId, pinType, xLoc, yLoc, areaRadius, insideCurrentMapWorld, isBreadcrumb)
--	xLoc = zo_round(xLoc * 10000) / 10000
--	yLoc = zo_round(yLoc * 10000) / 10000
	local tag = CurrentTasks[taskId]
	if(tag and insideCurrentMapWorld) then
		if CurrentTasks[taskId].Fetched then
			zo_callLater(FyrMM.RequestQuestPinUpdate,100)
			if CurrentTasks[taskId].MapId ~= FyrMM.GetMapId() then
				CurrentTasks[taskId] = nil
				return
			end
		else
			if CurrentTasks[taskId].ZO_MapVisible then return end
			local pinData = {}
			pinData.questIndex = tag[1]
			pinData.questName = GetJournalQuestName(tag[1])
			pinData.coditionText = GenerateQuestConditionTooltipLine(tag[1], tag[3], tag[2])
			pinData.stepIndex = tag[3]
			pinData.conditionIndex = tag[2]
			pinData.normalizedX = xLoc
			pinData.normalizedY = yLoc
			pinData.areaRadius = areaRadius
			pinData.isBreadcrumb = isBreadcrumb
			pinData.isAssisted = GetTrackedIsAssisted(TRACK_TYPE_QUEST, tag[1])
			pinData.MapId = FyrMM.GetMapId()
			pinData.tag = tag
			local requestedquestdataIndex = questpinDataExists(pinData, RequestedQuestPins)
			if requestedquestdataIndex == nil then
				table.insert(RequestedQuestPins, pinData)
			else
				RequestedQuestPins[requestedquestdataIndex] = pinData
			end
			pinData = {}
		end
		if tag.MapId == FyrMM.GetMapId() then
			tag.isBreadcrumb = isBreadcrumb
			FyrMM.CreateQuestPin(pinType, tag, xLoc, yLoc, areaRadius)
		end
	else
		if isBreadcrumb then NeedQuestPinUpdate = true end
	end
	if tag then
		CurrentTasks[taskId] = nil
	end
	if table.empty(CurrentTasks) then
		QuestTasksPending = false
	else
		QuestTasksPending = true
	end
end

local function AddQuestPins(questIndex)
	if(ZO_WorldMap_IsPinGroupShown(MAP_FILTER_QUESTS)) then
		local assisted = GetTrackedIsAssisted(TRACK_TYPE_QUEST, questIndex)
		if(GetJournalQuestIsComplete(questIndex)) then
			local tag = ZO_MapPin.CreateQuestPinTag(questIndex, QUEST_MAIN_STEP_INDEX, 1)
			if not TaskExists(tag) then
			local taskId = FyrMM.RequestJournalQuestConditionAssistance(questIndex, QUEST_MAIN_STEP_INDEX, 1, assisted)
				if taskId ~= nil then
					FyrMM.LastQuestPinRequest = GetFrameTimeMilliseconds()
					CurrentTasks[taskId] = {}
					tag.MapId = FyrMM.GetMapId()
					CurrentTasks[taskId] = tag
					CurrentTasks[taskId].RequestTimeStamp = FyrMM.LastQuestPinRequest
				end
			end
	else	
			for stepIndex = QUEST_MAIN_STEP_INDEX, GetJournalQuestNumSteps(questIndex) do
				for conditionIndex = 1, GetJournalQuestNumConditions(questIndex, stepIndex) do
					local _, _, isFailCondition, isComplete = GetJournalQuestConditionValues(questIndex, stepIndex, conditionIndex)
					if(not (isFailCondition or isComplete)) then
						local tag = ZO_MapPin.CreateQuestPinTag(questIndex, stepIndex, conditionIndex)
						if not TaskExists(tag) then
							local taskId = FyrMM.RequestJournalQuestConditionAssistance(questIndex, stepIndex, conditionIndex, assisted)
							if taskId ~= nil then
								FyrMM.LastQuestPinRequest = GetFrameTimeMilliseconds()
								CurrentTasks[taskId] = {}
								tag.MapId = FyrMM.GetMapId()
								CurrentTasks[taskId] = tag
								CurrentTasks[taskId].RequestTimeStamp = FyrMM.LastQuestPinRequest
								end
						end
					end
				end
			end		
		end
	end
end

function FyrMM.UpdateQuestPins()
	if FyrMM.Halted then return end
	if not table.empty(CurrentTasks) and GetFrameTimeMilliseconds() - FyrMM.LastQuestPinRequest > FYRMM_QUEST_PIN_REQUEST_TIMEOUT then DestroyTasks() end
	if not table.empty(CurrentTasks) then return end
	if table.empty(CurrentTasks) and GetFrameTimeMilliseconds() - FyrMM.LastQuestPinRequest < FYRMM_QUEST_PIN_REQUEST_MINIMUM_DELAY then return end --spam
	FyrMM.questPinCount = GetQuestPinCount()
	QuestPinsUpdating = true
	QuestTasksPending = true
	for i = 1, MAX_JOURNAL_QUESTS do
		if(IsValidQuestIndex(i)) then
			if FyrMM.Reloading then return end
			AddQuestPins(i)
		end
	end
end

function FyrMM.RequestQuestPinUpdate()
	NeedQuestPinUpdate = true
end

---------------------------------------------------
-- Keep Network updates
---------------------------------------------------
local function AvAPinOnMouseExit(pin)
	FyrMM.SetTargetScale(pin, 1)
	if pin.tooltipId == 4 then
		ZO_Tooltips_HideTextTooltip()
	else
		ZO_KeepTooltip:SetHidden(true)
	end
end

local function AvAPinOnMouseEnter(pin)
	FyrMM.SetTargetScale(pin, 1.3)
	if not FyrMM.SV.PinTooltips then return end
	if pin == nil then return end
	--if pin.m_PinType == nil then return end
	--if ZO_MapPin.TOOLTIP_CREATORS[pin.m_PinType] == nil then return end
	--if not ZO_MapPin.TOOLTIP_CREATORS[pin.m_PinType].tooltip then return end
	--if ZO_MapPin.TOOLTIP_CREATORS[pin.m_PinType].tooltip ~= ZO_KeepTooltip then return end
	if pin.tooltipId == nil then return end
	if pin.tooltipId == 1 then
		ZO_KeepTooltip:SetKeep(pin.keepId, ZO_WorldMap_GetBattlegroundQueryType(), 95)
		ZO_KeepTooltip:SetHidden(false)
		ZO_KeepTooltip:ClearAnchors()
		ZO_KeepTooltip:SetAnchor(TOPLEFT, Fyr_MM, TOPRIGHT, 0, 0)
		return
	end
	if pin.tooltipId == 2 then
		ZO_KeepTooltip:SetForwardCamp(pin.m_Pin:GetForwardCampIndex())
		ZO_KeepTooltip:SetHidden(false)
		ZO_KeepTooltip:ClearAnchors()
		ZO_KeepTooltip:SetAnchor(TOPLEFT, Fyr_MM, TOPRIGHT, 0, 0)
		return
	end
	if pin.tooltipId == 3 then
		InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 0, 0)
		InformationTooltip:AddLine(zo_strformat(SI_AVA_OBJECTIVE_ARTIFACT_TOOLTIP, GetAvAObjectiveInfo(pin.keepId, pin.objectiveId, ZO_WorldMap_GetBattlegroundQueryType())))
		return
	end
	if pin.tooltipId == 4 then
		ZO_Tooltips_ShowTextTooltip(self, nil, zo_strformat(SI_TOOLTIP_ALLIANCE_RESTRICTED_LINK, GetAllianceName(pin.alliance)))
	end
end

function FyrMM.UpdateKeepNetworkPositions()
	if not IsInCyrodiil() or Fyr_MM:IsHidden() or not CurrentMap.ready then return end
	local  mWidth, mHeight = Fyr_MM_Scroll_Map:GetDimensions()
	local Count, l, startX, startY, endX, endY
	for i=1, 100 do
		l = GetControl("Fyr_MM_Scroll_Map_Links_Link"..tostring(i))
		if l ~= nil then
			if FyrMM.SV.WheelMap then
				l:SetParent(Fyr_MM_Scroll_CW_Map_Pins)
			else
				l:SetParent(Fyr_MM_Scroll_Map_Links)
			end
			if FyrMM.SV.RotateMap then
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.startNX, l.startNY))
				l:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.endNX, l.endNY))
			else
				startX, startY, endX, endY = zo_round(l.startNX * mWidth - mWidth/2), zo_round(l.startNY * mHeight -mHeight/2), zo_round(l.endNX * mWidth - mWidth/2), zo_round(l.endNY * mHeight -mHeight/2)
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll_Map_Links, CENTER, startX, startY )
				l:SetAnchor(BOTTOMRIGHT , Fyr_MM_Scroll_Map_Links, CENTER, endX,  endY)
			end
		end
		l = GetControl("Fyr_MM_Scroll_Map_LinksNS_Link"..tostring(i))
		if l ~= nil then
			if FyrMM.SV.RotateMap then
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.startNX, l.startNY))
				l:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.endNX, l.endNY))
			else
				startX, startY, endX, endY = l.startNX * mWidth - mWidth/2, l.startNY * mHeight -mHeight/2, l.endNX * mWidth - mWidth/2, l.endNY * mHeight -mHeight/2
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll_Map_Links, CENTER, startX, startY )
				l:SetAnchor(BOTTOMRIGHT , Fyr_MM_Scroll_Map_Links, CENTER, endX,  endY)
			end
		end
		l = GetControl("Fyr_MM_Scroll_Map_LinksWE_Link"..tostring(i))
		if l ~= nil then
			if FyrMM.SV.RotateMap then
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.startNX, l.startNY))
				l:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(l.endNX, l.endNY))
			else
				startX, startY, endX, endY = l.startNX * mWidth - mWidth/2, l.startNY * mHeight -mHeight/2, l.endNX * mWidth - mWidth/2, l.endNY * mHeight -mHeight/2
				l:ClearAnchors()
				l:SetAnchor(TOPLEFT, Fyr_MM_Scroll_Map_Links, CENTER, startX, startY )
				l:SetAnchor(BOTTOMRIGHT , Fyr_MM_Scroll_Map_Links, CENTER, endX,  endY)
			end
		end
	end

	Count = Fyr_MM_Scroll_Map_Kill_Locations:GetNumChildren()
	for i=1, Count do
		l = Fyr_MM_Scroll_Map_Kill_Locations:GetChild(i)
		if l ~= nil then
			if l.normalizedX ~= nil and l.normalizedY ~= nil then
				FyrMM.SetPinAnchor(l, l.normalizedX, l.normalizedY, Fyr_MM_Scroll_Map_Kill_Locations)
			end
		end
	end
	Count = Fyr_MM_Scroll_Map_ForwardCamps:GetNumChildren()
	for i=1, Count do
		l = Fyr_MM_Scroll_Map_ForwardCamps:GetChild(i)
		if l ~= nil then
			if l.normalizedX ~= nil and l.normalizedY ~= nil then
				FyrMM.SetPinAnchor(l, l.normalizedX, l.normalizedY, Fyr_MM_Scroll_Map_ForwardCamps)
			end
		end
	end
	Count = Fyr_MM_Scroll_Map_Objectives:GetNumChildren()
	for i=1, Count do
		l = Fyr_MM_Scroll_Map_Objectives:GetChild(i)
		if l ~= nil then
			if l.normalizedX ~= nil and l.normalizedY ~= nil then
				FyrMM.SetPinAnchor(l, l.normalizedX, l.normalizedY, Fyr_MM_Scroll_Map_Objectives)
			end
		end
	end
	for i, v in pairs(KeepIndex) do
		l = GetControl("Fyr_MM_Scroll_Map_Keeps_Keep"..tostring(v))
		if l ~= nil then
			if l.normalizedX ~= nil and l.normalizedY ~= nil then
				FyrMM.SetPinAnchor(l, l.normalizedX, l.normalizedY, Fyr_MM_Scroll_Map_Keeps)
			end
		end
		l = GetControl("Fyr_MM_Scroll_Map_Keeps_Under_Attack_Keep"..tostring(i))
		if l ~= nil then
			if l.normalizedX ~= nil and l.normalizedY ~= nil then
				FyrMM.SetPinAnchor(l, l.normalizedX, l.normalizedY, Fyr_MM_Scroll_Map_Keeps)
			end
		end
	 end
end

local function KeepNetworkCleanupReminder(from, parent)
	if parent == nil then return end
	local t = GetGameTimeMilliseconds() 
	local Count = parent:GetNumChildren()
	for i=from, Count do
		l = parent:GetChild(i)
		if l ~= nil then
			l:ClearAnchors()
			l.nX = nil
			l.nY = nil
			l.m_PinType = nil
			l.tooltipId = nil
			l.continuousUpdate = nil
			l.objectiveId = nil
			l:SetHidden(true)
			l:SetMouseEnabled(false)
			l:SetTexture(nil)
			l:SetDimensions(0,0)
			PinsList[l:GetName()] = nil
		end
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "KeepNetworkCleanupReminder "..parent:GetName().." "..tostring(GetGameTimeMilliseconds()-t))
end

function FyrMM.UpdateKeepNetwork()
	if FyrMM.Halted then return end
	if not IsInCyrodiil() or (not FyrMM.Visible or Fyr_MM:IsHidden()) or (not CurrentMap.ready and not CurrentMap.mapBuilt) then return end
	if not FyrMM.KeepRefreshNeeded then return end
	local t = GetGameTimeMilliseconds()
	local historyPercent = 100.0
	local playerAlliance = GetUnitAlliance("player")
	local bgContext = ZO_WorldMap_GetBattlegroundQueryType()
	local  mWidth, mHeight = Fyr_MM_Scroll_Map:GetDimensions()
	KeepNetworkCleanupReminder(1, Fyr_MM_Scroll_Map_Keeps)
	KeepNetworkCleanupReminder(1, Fyr_MM_Scroll_Map_Keeps_Under_Attack)

	for i = 1, GetNumKeeps() do
		if FyrMM.Reloading then return end
		local keepId, kbgContext = GetKeepKeysByIndex(i)
		KeepIndex[keepId] = nil
		if IsLocalBattlegroundContext(kbgContext) then
		KeepIndex[keepId] = i
			local pinType, normalizedX, normalizedY = GetHistoricalKeepPinInfo(keepId, bgContext, historyPercent)
--			normalizedX = zo_round(normalizedX * 10000) / 10000
--			normalizedY = zo_round(normalizedY * 10000) / 10000
			local keepAlliance = GetKeepAlliance(keepId, bgContext) 
			local keepUnderAttack = GetKeepUnderAttack(keepId, bgContext)
			local keepUnderAttackPinType = ZO_WorldMap_GetUnderAttackPinForKeepPin(pinType)
			if FyrMM.IsCoordinatesInMap(normalizedX, normalizedY) then
				local uakeepControl = GetControl("Fyr_MM_Scroll_Map_Keeps_Under_Attack_Keep"..tostring(keepId))
				if keepUnderAttack then 
					if uakeepControl == nil then
			  			uakeepControl = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_Keeps_Under_Attack_Keep"..tostring(keepId), Fyr_MM_Scroll_Map_Keeps_Under_Attack, CT_TEXTURE)
					end
					uakeepControl:SetTexture(GetPinTexture(keepUnderAttackPinType, uakeepControl))
					uakeepControl.nX = normalizedX
					uakeepControl.nY = normalizedY
					uakeepControl.keepId = keepId
					uakeepControl.m_PinType = keepUnderAttackPinType
					uakeepControl:SetHidden(false)
					uakeepControl:SetDrawLayer(1)
					FyrMM.SetPinSize(uakeepControl, ZO_MapPin.PIN_DATA[keepUnderAttackPinType].size * FyrMM.pScalePercent, 0)
					FyrMM.SetPinAnchor(uakeepControl, normalizedX, normalizedY, Fyr_MM_Scroll_Map_Keeps_Under_Attack)
				else
					if uakeepControl ~= nil then
						uakeepControl:ClearAnchors()
						uakeepControl.nX = nil
						uakeepControl.nY = nil
						uakeepControl.m_PinType = nil
						uakeepControl:SetHidden(true)
						uakeepControl:SetMouseEnabled(false)
						uakeepControl:SetTexture(nil)
						uakeepControl:SetDimensions(0,0)
						PinsList[uakeepControl:GetName()] = nil
					end
				end

				local keepControl = GetControl("Fyr_MM_Scroll_Map_Keeps_Keep"..tostring(i))
				if keepControl == nil then
					keepControl = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_Keeps_Keep"..tostring(i), Fyr_MM_Scroll_Map_Keeps, CT_TEXTURE)
					keepControl:SetHandler("OnMouseEnter", AvAPinOnMouseEnter)
					keepControl:SetHandler("OnMouseExit", AvAPinOnMouseExit)
				end
				keepControl.nX = normalizedX
				keepControl.nY = normalizedY
				keepControl:SetTexture(GetPinTexture(pinType, keepControl))
				keepControl.keepId = keepId
				keepControl.m_PinType = pinType
				keepControl:SetDrawLayer(3)
				FyrMM.SetPinSize(keepControl, ZO_MapPin.PIN_DATA[pinType].size * FyrMM.pScalePercent, 0)
				keepControl:SetHidden(false)
				FyrMM.SetPinAnchor(keepControl, normalizedX, normalizedY, Fyr_MM_Scroll_Map_Keeps)
				local pinTooltipInfo = ZO_MapPin.TOOLTIP_CREATORS[pinType]
				keepControl.tooltipId = 1 -- Keeps
				keepControl:SetMouseEnabled(true)
			else
				keepControl = GetControl("Fyr_MM_Scroll_Map_Keeps_Keep"..tostring(keepId))
				uakeepControl = GetControl("Fyr_MM_Scroll_Map_Keeps_Keep"..tostring(keepId))
		if keepControl ~= nil then
					keepControl:SetHidden(true)
				end
				if uakeepControl ~= nil then
					uakeepControl:SetHidden(true)
				end
			end
		end
	end
	local numForwardCamps = GetNumForwardCamps(bgContext) -- Needs testing
	FyrMM.currentForwardCamps = 0
	KeepNetworkCleanupReminder(numForwardCamps+1, Fyr_MM_Scroll_Map_ForwardCamps)
	for i = 1, numForwardCamps do
		local pinType, normalizedX, normalizedY, normalizedRadius = GetForwardCampPinInfo(bgContext, i)	
--		normalizedX = zo_round(normalizedX * 10000) / 10000
--		normalizedY = zo_round(normalizedY * 10000) / 10000	
		if(normalizedX > 0 and normalizedX < 1.0001 and normalizedY > 0 and normalizedY < 1.0001) then
			if(not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_AVA_GRAVEYARD_AREAS)) then
				normalizedRadius = 0
			end
			FyrMM.currentForwardCamps = FyrMM.currentForwardCamps + 1
			local forwardCampControl = GetControl("Fyr_MM_Scroll_Map_ForwardCamps_Pin"..tostring(FyrMM.currentForwardCamps))
			if forwardCampControl == nil then
				forwardCampControl = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_ForwardCamps_Pin"..tostring(FyrMM.currentForwardCamps), Fyr_MM_Scroll_Map_ForwardCamps, CT_TEXTURE)
				forwardCampControl:SetHandler("OnMouseEnter", AvAPinOnMouseEnter)
				forwardCampControl:SetHandler("OnMouseExit", AvAPinOnMouseExit)
			end
			local forwardCampBlobControl = GetControl("Fyr_MM_Scroll_Map_ForwardCamps_Pin"..tostring(FyrMM.currentForwardCamps).."_Blob")
			if forwardCampBlobControl == nil then
				forwardCampBlobControl = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_ForwardCamps_Pin"..tostring(FyrMM.currentForwardCamps).."_Blob", Fyr_MM_Scroll_Map_ForwardCamps, CT_TEXTURE)
			end
			local pin = ZO_Object.New(ZO_MapPin)
			forwardCampControl.nX = normalizedX
			forwardCampControl.nY = normalizedY
			forwardCampBlobControl.nX = normalizedX
			forwardCampBlobControl.nY = normalizedY
			pin.normalizedX = normalizedX
			pin.normalizedY = normalizedY
			pin.normalizedRadius = normalizedRadius
			pin.m_PinType = pinType
			pin.m_PinTag = ZO_MapPin.CreateForwardCampPinTag(i)
			forwardCampBlobControl.m_Pin = pin
			forwardCampBlobControl:SetDrawLayer(3)
			forwardCampBlobControl:SetTexture("EsoUI/Art/MapPins/map_areaPin.dds")
			forwardCampControl.m_Pin = pin
			forwardCampControl.m_PinType = pinType
			forwardCampControl:SetDrawLayer(3)
			forwardCampControl:SetTexture(ZO_MapPin.PIN_DATA[pinType].texture)
			local campIconSize = 64 * FyrMM.pScalePercent
			local campBlobSize = mHeight * normalizedRadius * 2
			FyrMM.SetPinSize(forwardCampControl, campIconSize, 0)
			FyrMM.SetPinSize(forwardCampBlobControl, campBlobSize, 0)
			forwardCampControl:SetHidden(false)
			forwardCampBlobControl:SetHidden(false)
			FyrMM.SetPinAnchor(forwardCampControl, normalizedX, normalizedY, Fyr_MM_Scroll_Map_ForwardCamps)
			FyrMM.SetPinAnchor(forwardCampBlobControl, normalizedX, normalizedY, Fyr_MM_Scroll_Map_ForwardCamps)
			forwardCampControl.tooltipId = 2
			forwardCampControl:SetMouseEnabled(true)
			
		end
	end   
	local numObjectives = GetNumAvAObjectives()
	KeepNetworkCleanupReminder(numObjectives+1, Fyr_MM_Scroll_Map_Objectives)
	for i = 1, numObjectives do
		local okeepId, objectiveId, obgContext = GetAvAObjectiveKeysByIndex(i)
	if(IsLocalBattlegroundContext(obgContext)) then	
		if(ZO_WorldMap_IsObjectiveShown(okeepId, objectiveId, obgContext)) then 
		--To do... spawn locations
		--local opinType, spawnX, spawnY = GetAvAObjectiveSpawnPinInfo(okeepId, objectiveId, obgContext)  
				local opinType, currentX, currentY, continuousUpdate = GetAvAObjectivePinInfo(okeepId, objectiveId, bgContext)
--				currentX = zo_round(currentX * 10000) / 10000
--				currentY = zo_round(currentY * 10000) / 10000
				if(opinType ~= MAP_PIN_TYPE_INVALID) then
					local objectiveControl = GetControl("Fyr_MM_Scroll_Map_Objectives_Objective"..tostring(objectiveId))
					if objectiveControl == nil then
						objectiveControl = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_Objectives_Objective"..tostring(objectiveId), Fyr_MM_Scroll_Map_Objectives, CT_TEXTURE)
						objectiveControl:SetHandler("OnMouseEnter", AvAPinOnMouseEnter)
						objectiveControl:SetHandler("OnMouseExit", PinOnMouseExit)
					end
					objectiveControl.nX = currentX
					objectiveControl.nY = currentY
					objectiveControl.m_PinType = opinType
					objectiveControl.continuousUpdate = continuousUpdate
					objectiveControl:SetDrawLayer(3)
					objectiveControl:SetTexture(GetPinTexture(opinType, objectiveControl))
					FyrMM.SetPinSize(objectiveControl, ZO_MapPin.PIN_DATA[opinType].size * FyrMM.pScalePercent, 0)
					objectiveControl:SetHidden(false)
					FyrMM.SetPinAnchor(objectiveControl, currentX, currentY, Fyr_MM_Scroll_Map_Objectives)
					objectiveControl.keepId = okeepId
					objectiveControl.objectiveId = objectiveId
					objectiveControl.tooltipId = 3
					objectiveControl:SetMouseEnabled(true)
			if(continuousUpdate) then
			------------ To do... Continuous Position Update for opinType, keepId, objectiveId	
			end
		end
				-- To do ... assisted pins
		   --if(AVA_OBJECTIVE_PINS_WITH_ARROWS[opinType]) then
		   --end
			end
		end
	end
	--- Kill Locations (Battles)
	--- 
	local killPinCount = 0
	KeepNetworkCleanupReminder(GetNumKillLocations()+1, Fyr_MM_Scroll_Map_Kill_Locations)
	for i = 1, GetNumKillLocations() do
		local pinType, normalizedX, normalizedY = GetKillLocationPinInfo(i)
--		normalizedX = zo_round(normalizedX * 10000) / 10000
--		normalizedY = zo_round(normalizedY * 10000) / 10000		
		if(pinType ~= MAP_PIN_TYPE_INVALID) then
			if(ZO_WorldMap_IsPinGroupShown(MAP_FILTER_KILL_LOCATIONS)) then
				if ((normalizedX < 1.001 or normalizedY < 1.001) and (normalizedX > -.001 or normalizedY > -.001)) then
				killPinCount = killPinCount + 1
				local killPin = GetControl("Fyr_MM_Scroll_Map_Kill_Locations_Pin"..tostring(killPinCount))
				if killPin == nil then
					killPin = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_Kill_Locations_Pin"..tostring(killPinCount), Fyr_MM_Scroll_Map_Kill_Locations, CT_TEXTURE)
				end
					local killPinSize = ZO_MapPin.PIN_DATA[pinType].size * FyrMM.pScalePercent
					killPin:SetTexture(ZO_MapPin.PIN_DATA[pinType].texture)
					FyrMM.SetPinSize(killPin, killPinSize, 0)
					local pin = ZO_Object.New(ZO_MapPin)
					pin.normalizedX = normalizedX
					pin.normalizedY = normalizedY
					pin.m_PinType = pinType
					pin.m_PinTag = i
					killPin.m_Pin = pin
					killPin.m_PinType = pinType
					killPin.nX = normalizedX
					killPin.nY = normalizedY
					killPin:SetDrawLayer(3)
					killPin:SetHidden(false)
					FyrMM.SetPinAnchor(killPin, normalizedX, normalizedY, Fyr_MM_Scroll_Map_Kill_Locations)
				end
			end
		end
	end
	local r,g,b
	local numLinks = GetNumKeepTravelNetworkLinks(bgContext)
	local linkControl, linkControlNS, linkControlWE

	for linkIndex = 1, numLinks do
		local linkType, linkOwner, restrictedToAlliance, startNX, startNY, endNX, endNY = GetHistoricalKeepTravelNetworkLinkInfo(linkIndex, bgContext, historyPercent)
--		startNX = zo_round(startNX * 10000) / 10000
--		startNY = zo_round(startNY * 10000) / 10000	
--		endNX = zo_round(endNX * 10000) / 10000
--		endNY = zo_round(endNY * 10000) / 10000	
		if startNX < 1 or startNY < 1 or endNX < 1 or endNY < 1 then
			local startX, startY, endX, endY = zo_round(startNX * mWidth - mWidth/2), zo_round(startNY * mHeight -mHeight/2), zo_round(endNX * mWidth - mWidth/2), zo_round(endNY * mHeight -mHeight/2)
			local linkControl = GetControl("Fyr_MM_Scroll_Map_Links_Link"..tostring(linkIndex))
			if linkControl == nil then
				linkControl = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_Links_Link"..tostring(linkIndex), Fyr_MM_Scroll_Map_Links, CT_LINE)
			end
			local linkControlNS = GetControl("Fyr_MM_Scroll_Map_LinksNS_Link"..tostring(linkIndex))
			if linkControlNS == nil then
				linkControlNS = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_LinksNS_Link"..tostring(linkIndex), Fyr_MM_Scroll_NS_Map_Pins, CT_LINE)
			end
			local linkControlWE = GetControl("Fyr_MM_Scroll_Map_LinksWE_Link"..tostring(linkIndex))
			if GetControl("Fyr_MM_Scroll_Map_LinksWE_Link"..tostring(linkIndex)) == nil then
				linkControlWE = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_LinksWE_Link"..tostring(linkIndex), Fyr_MM_Scroll_WE_Map_Pins, CT_LINE)
			end
			linkControl.startNX = startNX
			linkControl.startNY = startNY
			linkControl.endNX = endNX
			linkControl.endNY = endNY
			linkControl:SetHidden(false)
			linkControl:SetDrawLayer(1)

			linkControlNS.startNX = startNX
			linkControlNS.startNY = startNY
			linkControlNS.endNX = endNX
			linkControlNS.endNY = endNY
			linkControlNS:SetHidden(false)
			linkControlNS:SetDrawLayer(1)

			linkControlWE.startNX = startNX
			linkControlWE.startNY = startNY
			linkControlWE.endNX = endNX
			linkControlWE.endNY = endNY
			linkControlWE:SetHidden(false)
			linkControlWE:SetDrawLayer(1)

			local linkThickness = math.floor((zo_round(80 * FyrMM.pScalePercent)/10)/2)*2
			if linkThickness < 6 then
				linkThickness = 6
			end
			linkControl:SetThickness(linkThickness)
			linkControlNS:SetThickness(linkThickness)
			linkControlWE:SetThickness(linkThickness)

			if(GetKeepFastTravelInteraction()) then
				if(linkOwner == playerAlliance) then
					if(linkType == FAST_TRAVEL_LINK_ACTIVE) then
						linkControl:SetColor(ZO_KeepNetwork.LINK_READY_COLOR:UnpackRGBA())
						linkControlNS:SetColor(ZO_KeepNetwork.LINK_READY_COLOR:UnpackRGBA())
						linkControlWE:SetColor(ZO_KeepNetwork.LINK_READY_COLOR:UnpackRGBA())
					else
						linkControl:SetColor(ZO_KeepNetwork.LINK_NOT_READY_COLOR:UnpackRGBA())
						linkControlNS:SetColor(ZO_KeepNetwork.LINK_NOT_READY_COLOR:UnpackRGBA())
						linkControlWE:SetColor(ZO_KeepNetwork.LINK_NOT_READY_COLOR:UnpackRGBA())
					end
				else
					r,g,b = GetAllianceColor(linkOwner):UnpackRGB()
					linkControl:SetColor(r, g, b, ZO_KeepNetwork.ALLIANCE_OWNER_ALPHA[linkOwner])
					linkControlNS:SetColor(r, g, b, ZO_KeepNetwork.ALLIANCE_OWNER_ALPHA[linkOwner])
					linkControlWE:SetColor(r, g, b, ZO_KeepNetwork.ALLIANCE_OWNER_ALPHA[linkOwner])
				end
			else
				r,g,b = GetAllianceColor(linkOwner):UnpackRGB()
				linkControl:SetColor(r, g, b, ZO_KeepNetwork.ALLIANCE_OWNER_ALPHA[linkOwner])
				linkControlNS:SetColor(r, g, b, ZO_KeepNetwork.ALLIANCE_OWNER_ALPHA[linkOwner])
				linkControlWE:SetColor(r, g, b, ZO_KeepNetwork.ALLIANCE_OWNER_ALPHA[linkOwner])
			end
			if(linkType == FAST_TRAVEL_LINK_IN_COMBAT) then
				linkControl:SetTexture("EsoUI/Art/AvA/AvA_transitLine_dashed.dds")
				linkControlNS:SetTexture("EsoUI/Art/AvA/AvA_transitLine_dashed.dds")
				linkControlWE:SetTexture("EsoUI/Art/AvA/AvA_transitLine_dashed.dds")
			else
				linkControl:SetTexture("EsoUI/Art/AvA/AvA_transitLine.dds")
				linkControlNS:SetTexture("EsoUI/Art/AvA/AvA_transitLine.dds")
				linkControlWE:SetTexture("EsoUI/Art/AvA/AvA_transitLine.dds")
			end
			if FyrMM.SV.WheelMap then
				linkControl:SetParent(Fyr_MM_Scroll_CW_Map_Pins)
			else
				linkControl:SetParent(Fyr_MM_Scroll_Map_Links)
			end
			if FyrMM.SV.RotateMap then
				linkControl:SetAnchor(TOPLEFT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(startNX, startNY))
				linkControl:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(endNX, endNY))
				linkControlNS:SetAnchor(TOPLEFT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(startNX, startNY))
				linkControlNS:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(endNX, endNY))
				linkControlWE:SetAnchor(TOPLEFT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(startNX, startNY))
				linkControlWE:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll, CENTER, GetRotatedPosition(endNX, endNY))
			else
				linkControl:SetAnchor(TOPLEFT, Fyr_MM_Scroll_Map_Links, CENTER, startX, startY)
				linkControl:SetAnchor(BOTTOMRIGHT , Fyr_MM_Scroll_Map_Links, CENTER, endX, endY)
				linkControlNS:SetAnchor(TOPLEFT, Fyr_MM_Scroll_Map_Links, CENTER, startX, startY)
				linkControlNS:SetAnchor(BOTTOMRIGHT , Fyr_MM_Scroll_Map_Links, CENTER, endX, endY)
				linkControlWE:SetAnchor(TOPLEFT, Fyr_MM_Scroll_Map_Links, CENTER, startX, startY)
				linkControlWE:SetAnchor(BOTTOMRIGHT , Fyr_MM_Scroll_Map_Links, CENTER, endX, endY)
			end

			-- Link Locks
			if(linkOwner == ALLIANCE_NONE and restrictedToAlliance ~= ALLIANCE_NONE) then
				local lockControl = GetControl("Fyr_MM_Scroll_Map_Locks_Lock"..tostring(linkIndex))
				if lockControl == nil then
					lockControl = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_Locks_Lock" .. tostring(linkIndex), Fyr_MM_Scroll_Map_Locks, CT_TEXTURE)
					lockControl:SetAlpha(0.4)
				end
				lockControl:SetTexture("/esoui/art/ava/ava_transitlocked.dds")
				FyrMM.SetPinSize(lockControl, 16 * FyrMM.pScalePercent, 0)
				lockControl:SetHidden(false)
				r,g,b = GetAllianceColor(restrictedToAlliance):UnpackRGB()
				lockControl:SetColor(r, g, b, 1)
				lockControl.alliance = restrictedToAlliance
				lockControl:SetDrawLayer(2)
				lockControl:SetAnchor(CENTER, linkControl, CENTER, 0, 0)
				lockControl.Lock = true
				lockControl.tooltipId = 4
				lockControl:SetHandler("OnMouseEnter", AvAPinOnMouseEnter)
				lockControl:SetHandler("OnMouseExit", AvAPinOnMouseExit)
				lockControl:SetMouseEnabled(true)
			end
		end
	end
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.UpdateKeepNetwork "..tostring(GetGameTimeMilliseconds()-t))
	FyrMM.KeepRefreshNeeded = false
end

function FyrMM.RequestKeepRefresh()
	FyrMM.KeepRefreshNeeded = true
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "Keep refresh request ")
end
-------------------------------------------------------------
-- Miscelaneous functions
-------------------------------------------------------------
function FyrMM.IsCoordinatesInMap(nX, nY)
	if nX <= 1 and nX >= 0 and nY <= 1 and nY >= 0 then return true else return false end
end

function FyrMM.SetCurrentMapZoom(newZoom)
	CurrentMap.ZoomLevel = newZoom
	if FyrMM.SV.ZoomTable ~= nil then 
		FyrMM.SV.ZoomTable[CurrentMap.filename] = newZoom
	end
	Fyr_MM_ZoomLevel:SetText(newZoom)
end

function FyrMM.UnregisterUpdates()
	FyrMM.Halted = true
	FyrMM.HaltTimeOffset = GetFrameTimeMilliseconds()
	--EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapView")
	EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapPins")
	EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapGroupPins")
	EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapZone")
	EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapPosition")
	EVENT_MANAGER:UnregisterForUpdate("OnUpdateFyrMMMapKeepNetwork")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapRWUpdate")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapRescale")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapWayshrineDistances")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapQuestGiverDistances")
	EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapBorderPins")
end

function FyrMM.RegisterUpdates()
	FyrMM.UnregisterUpdates()
	FyrMM.Halted = false
	FyrMM.HaltTimeOffset = 0
	--EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapView", FyrMM.SV.ViewRefreshRate, FyrMM.UpdateMapTiles)
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapPins", FyrMM.SV.PinRefreshRate, FyrMM.PinUpdate)
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapGroupPins", FyrMM.SV.MapRefreshRate, FyrMM.RefreshGroup)
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapZone", FyrMM.SV.ZoneRefreshRate, FyrMM.ZoneUpdate)
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapPosition", FyrMM.SV.MapRefreshRate, FyrMM.PositionUpdate)
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMMapKeepNetwork", FyrMM.SV.KeepNetworkRefreshRate, FyrMM.UpdateKeepNetwork)
	EVENT_MANAGER:RegisterForUpdate("FyrMiniMapRWUpdate", 1001, UpdateWheelPins)
	EVENT_MANAGER:RegisterForUpdate("FyrMiniMapRescale", 60, RescalePinPositions)
	EVENT_MANAGER:RegisterForUpdate("FyrMiniMapWayshrineDistances", 5000, WayshrineDistances)
	EVENT_MANAGER:RegisterForUpdate("FyrMiniMapQuestGiverDistances", 2000, QuestGiverDistances)
	EVENT_MANAGER:RegisterForUpdate("FyrMiniMapBorderPins", 2000, FyrMM.PlaceBorderPins)
end

-------------------------------------------------------------
-- On Initialized
-------------------------------------------------------------
function FyrMM.LoadScreen() -- Initialize Player group events
	if not FyrMM.SV.StartupInfo then
		d("|ceeeeeeMiniMap by |c006600Fyrakin |ceeeeee v"..FyrMM.Panel.version.."|r")
	end
	if FYRMM_ZOOM_INCREMENT_AMOUNT == nil then
		FYRMM_ZOOM_INCREMENT_AMOUNT = 1
	end
	EVENT_MANAGER:RegisterForEvent( "MiniMapOnUnitCreated", EVENT_UNIT_CREATED  , FyrMM.GroupEvent )
	EVENT_MANAGER:RegisterForEvent( "MiniMapOnUnitDestroyed", EVENT_UNIT_DESTROYED  , FyrMM.GroupEvent )
	EVENT_MANAGER:RegisterForEvent( "MiniMapOnGroupDisbanded", EVENT_GROUP_DISBANDED  , FyrMM.GroupEvent )
	EVENT_MANAGER:RegisterForEvent( "MiniMapOnLeaderUpdated", EVENT_LEADER_UPDATE  , FyrMM.GroupEvent )
	FyrMM.GroupEvent()
	FyrMM.UpdateQuestPins()
	local pinTooltipInfo = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_PLAYER]
	Fyr_MM_Player:SetHandler("OnMouseEnter", function(Fyr_MM_Player) FyrMM.SetTargetScale(Fyr_MM_Player, 1.3)
							if not FyrMM.SV.PinTooltips then return end
							InitializeTooltip(InformationTooltip, Fyr_MM, TOPLEFT, 0, 0)
							InformationTooltip:AppendUnitName("player") end)
	Fyr_MM_Player:SetHandler("OnMouseExit", function(Fyr_MM_Player) FyrMM.SetTargetScale(Fyr_MM_Player, 1) ClearTooltip(InformationTooltip) end)
	Fyr_MM_Player:SetMouseEnabled(true)
	EVENT_MANAGER:UnregisterForEvent( "MiniMap", EVENT_PLAYER_ACTIVATED )

end

function FyrMM.InitialPreload()
	local t = GetGameTimeMilliseconds()
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.InitialPreload Start:")
	local task = 0
	FyrMM.InitialPreloadTimeStamp = GetFrameTimeMilliseconds()
	FyrMM.SetMapToPlayerLocation()
	CurrentMap.ZoneId = GetCurrentMapZoneIndex() 
	EVENT_MANAGER:RegisterForUpdate("OnFyrMiniMapInitialPreload", 30, function()
		if FyrMM.Reloading then return end
		task = task + 1
		if task == 1 then FyrMM.UpdateMapInfo() end
		if task == 2 then FyrMM.UpdateMapTiles(true) end
		if task == 3 then FyrMM.Show() end
		if task == 4 then FyrMM.MapHalfDiagonal() end
		if task == 5 then FyrMM.PositionUpdate() end
		if task == 6 then FyrMM.GroupEvent() end
		if task == 7 then FyrMM.UpdateQuestPins() end
		if task == 8 then CurrentMap.needRescale = true RescalePinPositions() end
		if task == 9 and FyrMM.SV.BorderPins then FyrMM.PlaceBorderPins() end
		if task == 10 and IsInCyrodiil() then FyrMM.RequestKeepRefresh() end
		if task == 11 then FyrMM.PinUpdate() end
		if task >= 12 then CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.InitialPreload Done."..tostring(GetGameTimeMilliseconds()-t)) EVENT_MANAGER:UnregisterForUpdate("OnFyrMiniMapInitialPreload") FyrMM.RegisterUpdates() end
		end)
end

function FyrMM.FastTravelInteraction(Interacting, Index, EventCode)
	CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.FastTravelInteraction ("..tostring(Interacting)..") "..tostring(Index))
	if Interacting then
		FyrMM.FastTravelOpen = true
		FyrMM.UnregisterUpdates()
		CancelUpdates()
		FyrMM.Reloading = true
	else
		CurrentTasks = {}
		FyrMM.Reloading = false
		FyrMM.FastTravelOpen = false
	end
end

function FyrMM.LoadCustomPinList()
	if Fyr_MM:IsHidden() then return end
	if PRCustomPins then
		if not table.empty(PRCustomPins) then
			FyrMM.CustomPinList = {}
			local t = 0
			for i, n in pairs(PRCustomPins) do
				t = t + 30
				EVENT_MANAGER:RegisterForUpdate("FyrMiniMapLoadCustomPinGroupStart"..tostring(i), t, function()
				FyrMM.LoadCustomPinGroup(i)
				EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapLoadCustomPinGroupStart"..tostring(i)) end)
			end
		end
	end
end

local _FindPin = _G["ZO_WorldMapPins"].FindPin
local function FindPin(obj, pinTypeString, pinType, pinIndex)
	if FyrMM.LoadingCustomPins then
		if FyrMM.LoadingCustomPins[pinType] then
			return nil
		end
	end
	return _FindPin(obj, pinTypeString, pinType, pinIndex)
end
_G["ZO_WorldMapPins"].FindPin = FindPin

local _CreatePin = _G["ZO_WorldMapPins"].CreatePin
local function CreatePin(obj, pinType, pinTag, x, y, radius)
	if obj == nil or pinType == nil then return end
	if obj ~= nil and PinRef == nil then
		PinRef = obj
		FyrMM.PinRef = obj
		PRCustomPins = obj.customPins
		PRMap = obj.m_Active
	end
	local mapId = GetMapId()
	if CurrentMap.MapId ~= mapId and not Fyr_MM:IsHidden() then
		FyrMM.ZoneCheck()
		if MapId ~= "unknown" then
			CurrentMap.MapId = mapId
		end
		CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "CreatePin detected New Map ID:"..tostring(mapId))
	end
	CustomPinMapId = mapId
	if not FyrMM.FastTravelOpen and x ~= nil and y ~= nil and CustomWaypoints[pinType] then
		if CustomPinMapId ~= "unknown" then
			if pinType == MAP_PIN_TYPE_PING and FyrMM.Ping ~= nil then
				FyrMM.Ping.nX = x
				FyrMM.Ping.nY = y
				FyrMM.Ping:RefreshAnchor()
			end
			if pinType == MAP_PIN_TYPE_RALLY_POINT and FyrMM.Rally ~= nil then
				FyrMM.Rally.nX = x
				FyrMM.Rally.nY = y
			FyrMM.Rally:RefreshAnchor()
			end
			if pinType == MAP_PIN_TYPE_PLAYER_WAYPOINT and FyrMM.Waypoint ~= nil then
				FyrMM.Waypoint.nX = x
				FyrMM.Waypoint.nY = y
				FyrMM.Waypoint:RefreshAnchor()
			end
		end
	end
	if FyrMM.LoadingCustomPins[pinType] then
		local r = {m_PinType = pinType, m_PinTag = pinTag, normalizedX = x, normalizedY = y, radius = radius}
		if pinType ~= nil then
			if FyrMM.CustomPinList[pinType] == nil then
				FyrMM.CustomPinList[pinType] = {}
			end
			table.insert(FyrMM.CustomPinList[pinType], r)
		end
		local timeout = 100
		if string.sub(PRCustomPins[pinType].pinTypeString,1,4) == "DEST" then
			timeout = 250
		end
		EVENT_MANAGER:RegisterForUpdate("FyrMiniMapLoadCustomPinGroup"..tostring(pinType), 100, function()
			FyrMM.LoadingCustomPins[pinType] = false
		EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapLoadCustomPinGroup"..tostring(pinType)) end)

		-- Compatibility with WaypointIt code:
		if WaypointIt then
			local func = function() return false end
			r.IsGroup = func
			r.IsPOI = func
			r.IsLocation = func
			r.IsQuest = func
			r.IsAvAObjective = func
			r.IsKeep = func
			r.IsMapPing = func
			r.IsKillLocation = func
			r.IsFastTravelKeep = func
			r.IsFastTravelWayShrine = func
			r.IsForwardCamp = func
			r.IsAvARespawn = func
			r.UpdateLocation = function() end
			r.GetNormalizedPosition = function(self) return self.normalizedX, self.normalizedY end
			r.GetPinTypeAndTag = function(self) return self.m_PinType, self.m_PinTag end
			r.PIN_DATA = ZO_MapPin.PIN_DATA
		end
		--
		return r

	else
		local pin = _CreatePin(obj, pinType, pinTag, x, y, radius)
		return pin
	end
end
_G["ZO_WorldMapPins"].CreatePin = CreatePin

function FyrMM.LoadCustomPinGroup(Type)
	if Fyr_MM:IsHidden() then return end
	if PRCustomPins ~= nil then
		if PRCustomPins[Type] ~=nil then
			if PRCustomPins[Type].enabled then
				if PRCustomPins[Type].layoutCallback ~= nil then
					if type(PRCustomPins[Type].layoutCallback) == "function" then						
						EVENT_MANAGER:RegisterForUpdate("FyrMiniMapLoadCustomPinGroup"..tostring(Type), 30, function()
							if FyrMM.LoadingCustomPins[Type] or FyrMM.UpdatingCustomPins[Type] then return end
								if Fyr_MM:IsHidden() then return end
								if FyrMM.CustomPinList == nil then
									FyrMM.CustomPinList = {}
								end
								FyrMM.CustomPinList[Type] = {}
								FyrMM.LoadingCustomPins[Type] = true
								PRCustomPins[Type].layoutCallback(PinRef)
								EVENT_MANAGER:RegisterForUpdate("FyrMiniMapLoadCustomPinGroupTimeout"..tostring(Type), 500, function()
									FyrMM.LoadingCustomPins[Type] = false
								EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapLoadCustomPinGroupTimeout"..tostring(Type)) end)
						EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapLoadCustomPinGroup"..tostring(Type)) end)
					end
				end
			end
		end
	end
end
local function InitFinish()
	FyrMM.Initialized = true
	if FyrMM.SV.MenuAutoHide then
		zo_callLater(FyrMM.MenuFadeOut, 3000)
	end
end

local function RemoveCustomPinGroup(pinType)
	if pinType >= MAP_PIN_TYPE_INVALID then
		EVENT_MANAGER:RegisterForUpdate("FyrMiniMapCustomPinGroupRemove"..tostring(pinType), 30, function()
			if FyrMM.UpdatingCustomPins[pinType] then return end
			if Fyr_MM:IsHidden() then return end
			FyrMM.UpdatingCustomPins[pinType] = true
			if FyrMM.CustomPinList[pinType] ~= nil then
				for i, n in pairs(FyrMM.CustomPinList[pinType]) do
					RemoveCustomPin(n.pin)
				end
			end
			FyrMM.CustomPinList[pinType] = {}
			FyrMM.UpdatingCustomPins[pinType] = false
			FyrMM.LoadCustomPinGroup(pinType)
			CheckCustomPinConsistence(pinType)
		EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapCustomPinGroupRemove"..tostring(pinType)) end)
	end
end

local function RemoveCustomPins(PinTypeStr, majorIndex, keyIndex)
	if PinRef == nil or Fyr_MM:IsHidden() or FyrMM.Reloading then return end
	local Map = PinRef
	local MapTable = PRMap
	local lookupTable = Map.m_keyToPinMapping[PinTypeStr]
	local p
	if(majorIndex) then
		if majorIndex >= MAP_PIN_TYPE_INVALID then
			local pinType = majorIndex
			if FyrMM.CustomPinList[pinType] ~= nil then
				RemoveCustomPinGroup(pinType)
			end
			return
		end
	else
		if PinTypeStr then
			for pinType, _ in pairs(lookupTable) do
				if pinType >= MAP_PIN_TYPE_INVALID then
					if FyrMM.CustomPinList[pinType] ~= nil then
						RemoveCustomPinGroup(pinType)
					end
				end
			end
			return
		end
	end
end

function FyrMM.ResetCustomPinGroup(pinType)
	if pinType == nil then FyrMM.LoadCustomPinList() return end
	local t = GetGameTimeMilliseconds()
	if pinType >= MAP_PIN_TYPE_INVALID and PRCustomPins then
		RemoveCustomPins(PRCustomPins[pinType].pinTypeString, pinType)
	end
		CALLBACK_MANAGER:FireCallbacks("FyrMMDebug", "FyrMM.CustomPinGroup "..tostring(pinType).." Done. "..tostring(GetGameTimeMilliseconds()-t))
end

local function OnInit() -- Initialize Map and Update events after add-on load
	Fyr_MM_Frame_Control:SetAnchor(CENTER, Fyr_MM, CENTER, 0, 0)
	Fyr_MM_Wheel_Background:SetAnchor(CENTER, Fyr_MM, CENTER, 0, 0)
	Fyr_MM_Wheel_Background:SetTexture("MiniMap/Textures/wheelbackground.dds")
	Fyr_MM_Scroll_WheelNS:SetAnchor(CENTER, Fyr_MM_Scroll, CENTER, 0, 0)
	Fyr_MM_Scroll_WheelWE:SetAnchor(CENTER, Fyr_MM_Scroll, CENTER, 0, 0)
	Fyr_MM_Scroll_WheelCenter:SetAnchor(CENTER, Fyr_MM_Scroll, CENTER, 0, 0)
	MenuAnimation = ZO_AlphaAnimation:New(Fyr_MM_Menu)

	--FyrMM.PinUpdateNeeded = true
	FyrMM.LAM = LibStub("LibAddonMenu-2.0")
	FyrMM.CPL = FyrMM.LAM:RegisterAddonPanel("FyrMiniMap", FyrMM.Panel)
	FyrMM.SettingsPanel = FyrMM.LAM:RegisterOptionControls("FyrMiniMap", FyrMM.Options)

	Fyr_MM:SetHandler("OnMouseWheel", function(self, delta, ctrl, alt, shift) if not FyrMM.SV.MouseWheel then return end if delta < 0 then FyrMM.ZoomOut() else FyrMM.ZoomIn() end end)
	FyrMM.UpdateLabels()
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMHideCheck", 100, FyrMM.HideCheck)
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMLogPosition", 30, LogPosition)
	EVENT_MANAGER:RegisterForUpdate("OnUpdateFyrMMSpeedMeasure", 301, SpeedMeasure)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_QUEST_ADDED, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_QUEST_ADVANCED, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_QUEST_COMPLETE_DIALOG, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_QUEST_COMPLETE, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_QUEST_CONDITION_COUNTER_CHANGED, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_QUEST_LIST_UPDATED, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_QUEST_OFFERED, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_QUEST_OPTIONAL_STEP_ADVANCED, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_MOUSE_REQUEST_ABANDON_QUEST, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_QUEST_REMOVED, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_QUEST_TOOL_UPDATED, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_ACTIVE_QUEST_TOOL_CLEARED, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_ACTIVE_QUEST_TOOL_CHANGED, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_OBJECTIVES_UPDATED, FyrMM.RequestQuestPinUpdate)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_POI_UPDATED, DelayedPOIPins)
	EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_DISCOVERY_EXPERIENCE, FyrMM.Wayshrines)


	EVENT_MANAGER:RegisterForEvent( "MiniMap",  EVENT_KEEPS_INITIALIZED, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap",  EVENT_KEEP_ALLIANCE_OWNER_CHANGED, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap",  EVENT_KEEP_END_INTERACTION, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap",  EVENT_KEEP_GATE_STATE_CHANGED, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap",  EVENT_KEEP_GUILD_CLAIM_UPDATE, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap",  EVENT_KEEP_INITIALIZED, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap",  EVENT_KEEP_OWNERSHIP_CHANGED_NOTIFICATION, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap",  EVENT_KEEP_RESOURCE_UPDATE, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap",  EVENT_KEEP_START_INTERACTION, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap",  EVENT_KEEP_UNDER_ATTACK_CHANGED, FyrMM.RequestKeepRefresh)
	EVENT_MANAGER:RegisterForEvent( "MiniMap",  EVENT_KILL_LOCATIONS_UPDATED, FyrMM.RequestKeepRefresh)

	QUEST_TRACKER:RegisterCallback("QuestTrackerAssistStateChanged", function() FyrMM.UpdateQuestPinPositions() end)
	QUEST_TRACKER:RegisterCallback("QuestTrackerRefreshedMapPins", function() FyrMM.RequestQuestPinUpdate() end)
	CALLBACK_MANAGER:RegisterCallback("OnFyrMiniNewMapEntered", DelayedReload)
	CALLBACK_MANAGER:RegisterCallback("OnFyrMiniMapChanged", FyrMM.UpdateLabels)
	CALLBACK_MANAGER:RegisterCallback("FyrMMDebug", function(value) FyrMM.Debug_d(value) end)
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function(manual)
	if manual == nil then
		FyrMM.Refresh = true
		FyrMM.ZoneCheck()
		return false
	else FyrMM.Refresh = false
	end end)
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", function(mode)
			EVENT_MANAGER:RegisterForUpdate("FyrMiniMapOnWorldMapModeChanged", 20, function()
			if ZO_WorldMap:IsHidden() then
				if SetMapToPlayerLocation() ~= SET_MAP_RESULT_CURRENT_MAP_UNCHANGED then
					CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
				end
			FyrMM.ZoneCheck()
			else FyrMM.UnregisterUpdates()
			end
			EVENT_MANAGER:UnregisterForUpdate("FyrMiniMapOnWorldMapModeChanged") end) 
	end)
	ZO_PreHook(ZO_WorldMapPins, "RemovePins", function(ref, PinTypeStr, majorIndex, keyIndex) RemoveCustomPins(PinTypeStr, majorIndex, keyIndex) end)
	ZO_PreHook(ZO_WorldMapPins, "RefreshCustomPins", function(ref, pt) FyrMM.ResetCustomPinGroup(pt) end)
	ZO_PreHook(ZO_Fishing, "StartInteraction", function() local action = GetGameCameraInteractableActionInfo() if zo_strformat(SI_GAME_CAMERA_TARGET, action) == GetString(SI_GAMECAMERAACTIONTYPE13) then zo_callLater(FyrMM.RequestQuestPinUpdate,4000) end return false end)
	ZO_PreHook(COMPASS, "PerformFullAreaQuestUpdate", FyrMM.RequestQuestPinUpdate)
	ZO_PreHook(ZO_WorldMap, "SetHidden", FyrMM.WorldMapShowHide)

	ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function() zo_callLater(FyrMM.HideCheck,10) end)
	ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function() zo_callLater(FyrMM.HideCheck,10) end)
	ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function() zo_callLater(FyrMM.HideCheck,10) end)
	ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function() zo_callLater(FyrMM.HideCheck,10) end)
	ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function() zo_callLater(FyrMM.HideCheck,10) end)
	ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function() zo_callLater(FyrMM.HideCheck,10) end)
	ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function() zo_callLater(FyrMM.HideCheck,10) end)
	ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function() zo_callLater(FyrMM.HideCheck,10) end)
	if FyrMM.CustomPinsEnabled then
		for i = 1, 1200 do
			local pin = GetControl("Fyr_MM_Scroll_Map_Pins_Pin"..tostring(i))
			if pin == nil then
				pin = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_Pins_Pin"..tostring(i), Fyr_MM_Scroll_Map_Pins, CT_TEXTURE)
				pin:SetHandler("OnMouseEnter", PinOnMouseEnter)
				pin:SetHandler("OnMouseExit", PinOnMouseExit)
				SetPinFunctions(pin)
			end
		end
	end
	for i = 1, 50 do
		local pin = GetControl("Fyr_MM_Scroll_Map_WayshrinePins_Pin"..tostring(i))
		if pin == nil then
			pin = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_WayshrinePins_Pin"..tostring(i), Fyr_MM_Scroll_Map_WayshrinePins, CT_TEXTURE)
			pin.nDistance = function(self) if self.nX == nil then return 1 end return math.sqrt((zo_round(CurrentMap.PlayerNX*10000)-zo_round(self.nX*10000))*(zo_round(CurrentMap.PlayerNX*10000)-zo_round(self.nX*10000))+(zo_round(CurrentMap.PlayerNY*10000)-zo_round(self.nY*10000))*(zo_round(CurrentMap.PlayerNX*10000)-zo_round(self.nY*10000)))/10000 end
			pin:SetHandler("OnMouseEnter", PinOnMouseEnter)
			pin:SetHandler("OnMouseExit", PinOnMouseExit)
			pin:SetHandler("OnMouseUp", PinOnMouseUp)
			SetPinFunctions(pin)
		end
	end
	for i = 1, 50 do
		local pin = GetControl("Fyr_MM_Scroll_Map_LocationPins_Pin"..tostring(i))
		if pin == nil then
			pin = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_LocationPins_Pin"..tostring(i), Fyr_MM_Scroll_Map_LocationPins, CT_TEXTURE)
			pin:SetHandler("OnMouseEnter", PinOnMouseEnter)
			pin:SetHandler("OnMouseExit", PinOnMouseExit)
			SetPinFunctions(pin)
		end
	end
	for i = 1, 100 do
		local pin = GetControl("Fyr_MM_Scroll_Map_POIPins_Pin"..tostring(i))
		if pin == nil then
			pin = WINDOW_MANAGER:CreateControl("Fyr_MM_Scroll_Map_POIPins_Pin"..tostring(i), Fyr_MM_Scroll_Map_POIPins, CT_TEXTURE)
			pin:SetHandler("OnMouseEnter", PinOnMouseEnter)
			pin:SetHandler("OnMouseExit", PinOnMouseExit)
			SetPinFunctions(pin)
		end
	end
	for i = 1, 100 do
		local pin = GetControl("Fyr_MM_Axis_Border_Pin"..tostring(i))
		if pin == nil then
			pin = WINDOW_MANAGER:CreateControl("Fyr_MM_Axis_Border_Pin"..tostring(i), Fyr_MM_Axis_Border_Pins, CT_TEXTURE)
			SetBorderPinHandlers(pin)
		end

	end
	for i = 1, 24 do
		local pin = GetControl("Fyr_MM_Scroll_Map_GroupPins_group"..tostring(i))
		if pin ~= nil then
			pin:SetHandler("OnMouseEnter", PinOnMouseEnter)
			pin:SetHandler("OnMouseExit", PinOnMouseExit)
			SetPinFunctions(pin)
		end
	end
	--EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_ZONE_CHANGED, function() FyrMM.PinUpdateNeeded = true end)
	zo_callLater(InitFinish,FyrMM.SV.ZoneRefreshRate)
end

function FyrMM.MenuFadeIn()
	if Fyr_MM_Menu:GetAlpha() > 0 or FyrMM.SV.MenuDisabled or FyrMM.MenuFadingIn or Fyr_MM:IsHidden() then return end
	FyrMM.MenuFadingIn = true
	if FyrMM.SV.ZoneFrameLocationOption == "Default" then
		Fyr_MM_ZoneFrame:ClearAnchors()
		Fyr_MM_ZoneFrame:SetAnchor(TOP, Fyr_MM_Menu, BOTTOM, 0, -Fyr_MM_Menu:GetHeight()/5)
		Fyr_MM_ZoneFrame:SetMovable(false)
	end
	if FyrMM.OverMiniMap or FyrMM.OverMenu then
		MenuAnimation:FadeIn(0, 1000, ZO_ALPHA_ANIMATION_OPTION_FORCE_ALPHA, function() FyrMM.MenuFadingIn = false end)
	end
end

function FyrMM.MenuFadeOut()
	if not FyrMM.SV.MenuAutoHide or FyrMM.OverMiniMap or FyrMM.OverMenu or Fyr_MM_Menu:GetAlpha() == 0 or FyrMM.SV.MenuDisabled  or FyrMM.MenuFadingOut then return end
	FyrMM.MenuFadingOut = true
	MenuAnimation:FadeOut(0, 1000, ZO_ALPHA_ANIMATION_OPTION_FORCE_ALPHA, function() FyrMM.MenuFadingOut = false
																			if FyrMM.SV.ZoneFrameLocationOption == "Default" then
																				Fyr_MM_ZoneFrame:ClearAnchors()
																				Fyr_MM_ZoneFrame:SetAnchor(TOP, Fyr_MM_Border, BOTTOM)
																				Fyr_MM_ZoneFrame:SetMovable(false)
																			end end)
end

local function UpdateZoomTable()
	if FyrMM.SV.ZoomTable then
		local t = {}
		for i, n in pairs(FyrMM.SV.ZoomTable) do
			t[i] = n
		end
		FyrMM.SV.ZoomTable = t
		FyrMM.SV.MapTable = nil
	end
	if FyrMM.SV.MapTable then
		FyrMM.SV.ZoomTable = {}
		for i, n in pairs(FyrMM.SV.MapTable) do
			FyrMM.SV.ZoomTable[i] = n.ZoomLevel
		end
		FyrMM.SV.MapTable = nil
	end
end

local function OnLoaded(eventCode, addOnName)
	if addOnName ~= "MiniMap" then return end
	FyrMM.Initialized = false
	MM_CreateDataTables()
	FyrMM.SV = ZO_SavedVars:NewAccountWide( "FyrMMSV" , 5 , nil , FyrMM.Defaults , nil )
	if FyrMM.SV ~= nil then
		UpdateZoomTable()
		MM_LoadSavedVars()
	end
	FyrMM.API_Check()
	Fyr_MM:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)
	Fyr_MM:SetHandler("OnMouseEnter", function() FyrMM.OverMiniMap = true FyrMM.MenuFadeIn() Fyr_MM_Close:SetAlpha(1) end)
	Fyr_MM:SetHandler("OnMouseExit", function() FyrMM.OverMiniMap = false zo_callLater(FyrMM.MenuFadeOut, 3000) Fyr_MM_Close:SetAlpha(0) end)
	Fyr_MM_Menu:SetHandler("OnMouseEnter", function() FyrMM.OverMenu = true FyrMM.MenuFadeIn() Fyr_MM_Close:SetAlpha(1) end)
	Fyr_MM_Menu:SetHandler("OnMouseExit", function() FyrMM.OverMenu = false zo_callLater(FyrMM.MenuFadeOut, 3000) Fyr_MM_Close:SetAlpha(0) end)
	Fyr_MM:SetHandler("OnMouseUp", function(self) if not FyrMM.SV.LockPosition then
						local width = Fyr_MM:GetWidth()
						local height = Fyr_MM:GetHeight()
						MM_SetMapWidth(width)
						MM_SetMapHeight(height)
						FyrMM.SV.position.offsetX = Fyr_MM:GetLeft()
						FyrMM.SV.position.offsetY = Fyr_MM:GetTop()
						FyrMM.MapHalfDiagonal()
						MM_RefreshPanel()
					else
						local pos = {}
						pos.anchorTo = GetControl(pos.anchorTo)
						Fyr_MM:SetAnchor(FyrMM.SV.position.point, pos.anchorTo, FyrMM.SV.position.relativePoint, FyrMM.SV.position.offsetX, FyrMM.SV.position.offsetY)
						Fyr_MM:SetDimensions(FyrMM.SV.MapWidth, FyrMM.SV.MapHeight)
					end	end)
	Fyr_MM_Coordinates:SetHandler("OnMouseUp", function(self) local pos = {}
								_, pos[1], pos[2], pos[3], pos[4], pos[5] = Fyr_MM_Coordinates:GetAnchor() if pos[2] ~= nil then pos[2] = pos[2]:GetName() end
								FyrMM.SV.CoordinatesAnchor = pos end)
	Fyr_MM_ZoneFrame:SetHandler("OnMouseUp", function(self) local pos = {}
								_, pos[1], pos[2], pos[3], pos[4], pos[5] = Fyr_MM_ZoneFrame:GetAnchor() if pos[1] == nil then return end if pos[2] ~= nil then pos[2] = pos[2]:GetName() end
								FyrMM.SV.ZoneFrameAnchor = pos end)
	Fyr_MM_Scroll:SetScrollBounding(0)
	Fyr_MM_Player_incombat:SetTexture("esoui/art/mappins/ava_attackburst_32.dds")
	AxisSwitch()
	zo_callLater(OnInit,1000) 
end

-----------------------------------------
-- Key bind functions
-----------------------------------------

function FyrMM.ZoomOut()
	if not FyrMM.Visible or Fyr_MM:IsHidden() or ZoomAnimating then return end
	local zoomLevel = CurrentMap.ZoomLevel
	zoomLevel = zoomLevel - FYRMM_ZOOM_INCREMENT_AMOUNT
	if zoomLevel < FYRMM_ZOOM_MIN then zoomLevel = FYRMM_ZOOM_MIN end
	PlaySound(SOUNDS.MAP_ZOOM_OUT)
	if FyrMM.SV.RotateMap then
		Fyr_MM_Scroll:SetHorizontalScroll(0)
		Fyr_MM_Scroll:SetVerticalScroll(0)
		FyrMM.WheelScroll(0, 0)
	end
	if not ZoomAnimating and zoomLevel ~= CurrentMap.ZoomLevel then
		AnimateZoom(zoomLevel)
	end
end

function FyrMM.ZoomIn()
	if not FyrMM.Visible or Fyr_MM:IsHidden() or ZoomAnimating then return end
	local zoomLevel = CurrentMap.ZoomLevel
	zoomLevel = zoomLevel + FYRMM_ZOOM_INCREMENT_AMOUNT
	if zoomLevel > FYRMM_ZOOM_MAX then zoomLevel = FYRMM_ZOOM_MAX end
	PlaySound(SOUNDS.MAP_ZOOM_IN)
	if FyrMM.SV.RotateMap then
		Fyr_MM_Scroll:SetHorizontalScroll(0)
		Fyr_MM_Scroll:SetVerticalScroll(0)
		FyrMM.WheelScroll(0, 0)
	end
	if not ZoomAnimating and zoomLevel ~= CurrentMap.ZoomLevel then
		AnimateZoom(zoomLevel)
	end
end

function FyrMM.ToggleVisible()
	if ZO_WorldMap:IsHidden() and ZO_InteractWindow:IsHidden() and ZO_KeybindStripControl:IsHidden() then
		if FyrMM.Visible then
			PlaySound(SOUNDS.MAP_WINDOW_CLOSE)
		else
			PlaySound(SOUNDS.MAP_WINDOW_OPEN)
		end
		FyrMM.Visible = not FyrMM.Visible
	end
end

EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_QUEST_POSITION_REQUEST_COMPLETE, OnQuestPositionRequestComplete)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_ADD_ON_LOADED , OnLoaded)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_ZONE_CHANGED, FyrMM.UpdateLabels)
--EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_ZONE_UPDATE, function (eventCode, unitTag, newZoneName) d(eventCode) d(unitTag) d(newZoneName) end) 
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_PLAYER_ACTIVATED  , FyrMM.LoadScreen)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_START_FAST_TRAVEL_INTERACTION, function(eventCode, index) FyrMM.FastTravelInteraction(true, index, eventCode) end)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_END_FAST_TRAVEL_INTERACTION, function(eventCode) FyrMM.FastTravelInteraction(false, nil, eventCode) end)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_START_FAST_TRAVEL_KEEP_INTERACTION, function(eventCode, index) FyrMM.FastTravelInteraction(true, index, eventCode) end)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_END_FAST_TRAVEL_KEEP_INTERACTION, function(eventCode) FyrMM.FastTravelInteraction(false, nil, eventCode) end)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_MOUNTED_STATE_CHANGED, function(eventCode, mounted) CurrentMap.PlayerMounted = mounted end)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_PLAYER_NOT_SWIMMING, function(eventCode) CurrentMap.PlayerSwimming = false end)
EVENT_MANAGER:RegisterForEvent( "MiniMap", EVENT_PLAYER_SWIMMING, function(eventCode) CurrentMap.PlayerSwimming = true end)