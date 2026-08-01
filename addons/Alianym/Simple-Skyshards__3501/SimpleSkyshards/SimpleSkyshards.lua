local simpleSky = SimpleSkyshards
local addOnName = simpleSky.name

local zStrFmt = zo_strformat

----------
-- Populate Map
----------

local pinData = {}
local pinTypeShard = "SIMPLE_SKYSHARDS_PIN_TYPE_SHARD_ON_MAP"
local pinTypeShardNoTooltip = "SIMPLE_SKYSHARDS_PIN_TYPE_SHARD_ON_MAP_NO_TOOLTIP"
local pinTypePOIShard = "SIMPLE_SKYSHARDS_PIN_TYPE_SHARD_DELVE_OR_DUNGEON"
local pinTypePOIShardAcquired = "SIMPLE_SKYSHARDS_PIN_TYPE_SHARD_DELVE_OR_DUNGEON_ACQUIRED"

local function GeneratePinData()
	local function PopulatePOIShardData(zoneId, zoneIndex, skyId)
		for poiIndex=1, GetNumPOIs(zoneIndex) do
			local skyIdForPOI = GetPOISkyshardId(zoneIndex, poiIndex)

			if (((not skyId) or (skyId and skyId == skyIdForPOI)) and skyIdForPOI > 0) then
				local poiType = GetPOIType(zoneIndex, poiIndex)
				local poiX, poiY = GetPOIMapInfo(zoneIndex, poiIndex)
				local zoneCompletionType = GetPOIZoneCompletionType(zoneIndex, poiIndex)

				pinData[zoneId][skyId or skyIdForPOI] = {
					zoneIndex = zoneIndex, skyId = skyId, locX = poiX, locY = poiY,
					poiIndex = poiIndex, isPublicDungeon = poiType == POI_TYPE_PUBLIC_DUNGEON,
					isDelve = zoneCompletionType == ZONE_COMPLETION_TYPE_DELVES or zoneCompletionType == ZONE_COMPLETION_TYPE_GROUP_DELVES,
				}
				
				break
			end
		end
	end

	local function GetZoneSkyPinData(zoneId, zoneIndex)
		local function SkyshardLoop(zoneId, zoneIndex)
			local numShardsInZone = GetNumSkyshardsInZone(zoneId)

			if numShardsInZone > 0 then
				pinData[zoneId] = pinData[zoneId] or {}
				ZO_WorldMap_SetMapByIndex(GetMapIndexByZoneId(zoneId))

				for skyIndex=1, numShardsInZone do
					local skyId = GetZoneSkyshardId(zoneId, skyIndex)
					local normalizedX, normalizedY, isInCurrentMap = GetNormalizedPositionForSkyshardId(skyId)

					local zoneIndex = zoneIndex or GetCurrentMapZoneIndex()

					pinData[zoneId][skyId] = pinData[zoneId][skyId] or {zoneIndex = zoneIndex, skyId = skyId, locX = normalizedX, locY = normalizedY}
					pinData[zoneId][skyId] = pinData[zoneId][skyId] or {zoneIndex = zoneIndex, skyId = skyId, locX = normalizedX, locY = normalizedY}
					
					if not isInCurrentMap then 
						PopulatePOIShardData(zoneId, zoneIndex, skyId)
					end
				end
			end
		end

		local function GetNextZoneStoryZoneIdIter(_, lastZoneId)
			return GetNextZoneStoryZoneId(lastZoneId)
		end

		if zoneId and zoneIndex then
			SkyshardLoop(zoneId, zoneIndex)
		else
			for zoneId in GetNextZoneStoryZoneIdIter do
				SkyshardLoop(zoneId)
			end
		end
	end

	GetZoneSkyPinData()

	local function HandleExceptions()
		local function SetMapAndPopulateData(zoneId, secondZoneId)
			local secondZoneIndex = GetZoneIndex(secondZoneId)
			pinData[zoneId] = pinData[zoneId] or {}
			GetZoneSkyPinData(zoneId, secondZoneIndex)
		end

		SetMapAndPopulateData(980, 981)
		SetMapAndPopulateData(1011, 1027)
		SetMapAndPopulateData(1160, 1161)
		SetMapAndPopulateData(1207, 1208)
		SetMapAndPopulateData(1413, 1414)
	end

	HandleExceptions()

	if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	end
end

local function RefreshCustomPins()
	ZO_WorldMap_RefreshCustomPinsOfType(_G[pinTypeShard])
	ZO_WorldMap_RefreshCustomPinsOfType(_G[pinTypeShardNoTooltip])
	ZO_WorldMap_RefreshCustomPinsOfType(_G[pinTypePOIShard])
	ZO_WorldMap_RefreshCustomPinsOfType(_G[pinTypePOIShardAcquired])
end

function PopulatePins()
	local pinTintFaded = ZO_ColorDef:New(1,1,1,0.65)
	local skyIcon = "EsoUI/Art/MapPins/skyshard_seen.dds"

	local pinTintFadedAcquired = ZO_ColorDef:New(1,1,1,0.65)
	local skyIconAcquired = "EsoUI/Art/MapPins/skyshard_complete.dds"

	local function HandleExceptions(a)
		if a.zoneId == 980 and (not (a.pinSkyshardTag.isDelve or a.pinSkyshardTag.isPublicDungeon)) then
			a.pinManager:CreatePin(_G[a.pinType], a.pinSkyshardTag, a.locX, a.locY)
		end
	end

	local function GetZoneSkyData()
		local zoneId, zoneIndex = ZO_ExplorationUtils_GetZoneStoryZoneIdForCurrentMap(), GetCurrentMapZoneIndex()
		local numSkyshardsInZone = GetNumSkyshardsInZone(zoneId)

		return zoneId, zoneIndex, numSkyshardsInZone
	end

	local function pinTypeCallbackShard(pinManager)
		local pinType = pinTypeShard
		local zoneId, zoneIndex, numSkyshardsInZone = GetZoneSkyData()

		for skyshardIndex = 1, numSkyshardsInZone do
			local skyshardId = GetZoneSkyshardId(zoneId, skyshardIndex)
			local pinSkyshardTag = pinData[zoneId] ~= nil and pinData[zoneId][skyshardId]
			local normalizedX, normalizedY, isInCurrentMap = GetNormalizedPositionForSkyshardId(skyshardId)
			local isUndiscovered = GetSkyshardDiscoveryStatus(skyshardId) == SKYSHARD_DISCOVERY_STATUS_UNDISCOVERED
			local isUnacquired = GetSkyshardDiscoveryStatus(skyshardId) ~= SKYSHARD_DISCOVERY_STATUS_ACQUIRED
			local isInBounds = ZO_WorldMap_IsNormalizedPointInsideMapBounds(normalizedX, normalizedY)

			if pinSkyshardTag and isInBounds then
				if isInCurrentMap and isUndiscovered then
					pinManager:CreatePin(_G[pinType], pinSkyshardTag, normalizedX, normalizedY)
				elseif (not isInCurrentMap) and (isUndiscovered or ZO_WorldMap_IsPinGroupShown(MAP_FILTER_ACQUIRED_SKYSHARDS)) then
					local a = {
						pinManager = pinManager, pinType = pinType, pinSkyshardTag = pinSkyshardTag, 
						zoneId = zoneId, zoneIndex = zoneIndex, skyshardId = skyshardId,
						locX = normalizedX, locY = normalizedY, isInCurrentMap,
					}

					HandleExceptions(a)
				end
			end
		end
	end

	local function pinTypeCallbackShardNoTooltip(pinManager)
		local pinType = pinTypeShardNoTooltip
		local zoneId, zoneIndex, numSkyshardsInZone = GetZoneSkyData()

		for skyshardIndex = 1, numSkyshardsInZone do
			local skyshardId = GetZoneSkyshardId(zoneId, skyshardIndex)
			local pinSkyshardTag = pinData[zoneId][skyshardId]

			if pinSkyshardTag then
				local normalizedX, normalizedY, isInCurrentMap = GetNormalizedPositionForSkyshardId(skyshardId)
				local discoveryStatus = GetSkyshardDiscoveryStatus(skyshardId)

				if ZO_WorldMap_IsNormalizedPointInsideMapBounds(normalizedX, normalizedY) then
					local pinZoneIndex = pinSkyshardTag.zoneIndex

					-- Check for FyrMM and if present, display base-game 'mirror shards' as well
					if (FyrMM) and (isInCurrentMap) and discoveryStatus == SKYSHARD_DISCOVERY_STATUS_DISCOVERED then
						if not (WORLD_MAP_FRAGMENT:IsShowing() or GAMEPAD_WORLD_MAP_INFO_FRAGMENT:IsShowing()) then
							pinManager:CreatePin(_G[pinType], pinSkyshardTag, normalizedX, normalizedY)
						end
					-- Check for FyrMM and if present, display base-game 'mirror shards' as well
					elseif (FyrMM) and (isInCurrentMap) and (discoveryStatus == SKYSHARD_DISCOVERY_STATUS_ACQUIRED) and ZO_WorldMap_IsPinGroupShown(MAP_FILTER_ACQUIRED_SKYSHARDS) then
						if not (WORLD_MAP_FRAGMENT:IsShowing() or GAMEPAD_WORLD_MAP_INFO_FRAGMENT:IsShowing()) then
							pinManager:CreatePin(_G[pinType], pinSkyshardTag, normalizedX, normalizedY)
						end
					elseif (not isInCurrentMap) and GetMapType() == MAPTYPE_ZONE then
						if discoveryStatus ~= SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
							local poiIndex = pinSkyshardTag.poiIndex
							local poiX, poiY, _, _, _, _, isPOIDiscovered, isPOINearby = GetPOIMapInfo(zoneIndex, poiIndex)

							if isPOIDiscovered or isPOINearby then
								pinManager:CreatePin(_G[pinType], pinSkyshardTag, poiX, poiY)
							end
						end
					end
				end
			end
		end
	end

	local function pinTypeCallbackPOIShard(pinManager)
		local pinType = pinTypePOIShard
		local zoneId, zoneIndex, numSkyshardsInZone = GetZoneSkyData()

		for skyshardIndex = 1, numSkyshardsInZone do
			local skyshardId = GetZoneSkyshardId(zoneId, skyshardIndex)
			local pinSkyshardTag = pinData[zoneId] ~= nil and pinData[zoneId][skyshardId]
			local isInCurrentMap = select(3, GetNormalizedPositionForSkyshardId(skyshardId))

			if pinSkyshardTag and GetMapType() == MAPTYPE_ZONE then
				local pinZoneIndex = pinSkyshardTag.zoneIndex
				local isDelve, isPublicDungeon = pinSkyshardTag.isDelve, pinSkyshardTag.isPublicDungeon

				if (pinZoneIndex == zoneIndex and (not isInCurrentMap)) and (isDelve or isPublicDungeon)  then
					local poiIndex = pinSkyshardTag.poiIndex
					local poiX, poiY, _, _, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered, isNearby = GetPOIMapInfo(zoneIndex, poiIndex)

					if isShownInCurrentMap and (not (isDiscovered or isNearby)) and ZO_WorldMap_IsNormalizedPointInsideMapBounds(poiX, poiY) then
						local pinTagPOIShard = {zoneIndex, poiIndex, skyIcon, linkedCollectibleIsLocked, isDelve = isDelve, isPublicDungeon = isPublicDungeon, locX = poiX, locY = poiY}
						pinManager:CreatePin(_G[pinType], pinTagPOIShard, poiX, poiY)
					end
				end
			end
		end
	end

	local function pinTypeCallbackPOIShardAcquired(pinManager)
		if not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_ACQUIRED_SKYSHARDS) then return end
		
		local pinType = pinTypePOIShardAcquired
		local zoneId, zoneIndex, numSkyshardsInZone = GetZoneSkyData()

		for skyshardIndex = 1, numSkyshardsInZone do
			local skyshardId = GetZoneSkyshardId(zoneId, skyshardIndex)
			local pinSkyshardTag = pinData[zoneId] ~= nil and pinData[zoneId][skyshardId]
			local isInCurrentMap = select(3, GetNormalizedPositionForSkyshardId(skyshardId))
			local isAcquired = GetSkyshardDiscoveryStatus(skyshardId) == SKYSHARD_DISCOVERY_STATUS_ACQUIRED

			if pinSkyshardTag and GetMapType() == MAPTYPE_ZONE then
				local pinZoneIndex = pinSkyshardTag.zoneIndex
				local isDelve, isPublicDungeon = pinSkyshardTag.isDelve, pinSkyshardTag.isPublicDungeon

				if (pinZoneIndex == zoneIndex and (not isInCurrentMap)) and (isDelve or isPublicDungeon) and isAcquired then
					local poiIndex = pinSkyshardTag.poiIndex
					local poiX, poiY, _, _, isShownInCurrentMap, linkedCollectibleIsLocked = GetPOIMapInfo(zoneIndex, poiIndex)

					if isShownInCurrentMap and ZO_WorldMap_IsNormalizedPointInsideMapBounds(poiX, poiY) then
						local pinTagPOIShardAcquired = {zoneIndex, poiIndex, skyIconAcquired, linkedCollectibleIsLocked, isDelve = isDelve, isPublicDungeon = isPublicDungeon, locX = poiX, locY = poiY}
						pinManager:CreatePin(_G[pinType], pinTagPOIShardAcquired, poiX, poiY)
					end
				end
			end
		end
	end

	local pinTypeOnResizeCallback = function() end

	local function GetPinTexture(pin)
		local pinTag = pin.m_PinTag
		local isAcquired = GetSkyshardDiscoveryStatus(pinTag.skyId) == SKYSHARD_DISCOVERY_STATUS_ACQUIRED

		if isAcquired then
			return skyIconAcquired
		else return skyIcon end
	end
	local function GetShardPinTint(pin)
		local pinTag = pin.m_PinTag
		local isInCurrentMap = select(3, GetNormalizedPositionForSkyshardId(pinTag.skyId))

		if not isInCurrentMap then
			return pinTintFaded
		else return ZO_DEFAULT_ENABLED_COLOR end
	end
	local pinLayoutDataShard = {level = 46, size = 40, texture = GetPinTexture, tint = GetShardPinTint, hitInsetX = 5, hitInsetY = 10} 

	-- pinLayout has a 'level = 47' because at ''level = 46'' it shows up under Public Dungeon icons in at least one instance (Blackreach Caverns: Arkthzand)
	local function GetShardNoTooltipPinTint(pin)
		local pinTag = pin.m_PinTag

		if (pinTag.isDelve or pinTag.isPublicDungeon) then
			return pinTintFaded
		else return ZO_DEFAULT_ENABLED_COLOR end
	end
	local pinLayoutDataShardNoTooltip = {level = 47, size = 40, texture = GetPinTexture, tint = GetShardNoTooltipPinTint, hitInsetX = 5, hitInsetY = 10}

	local function GetPOIPinTexture(pin) return pin.m_PinTag[3] end
	local pinLayoutDataDelveOrDungeon = {level = 47, size = 40, texture = GetPOIPinTexture, tint = pinTintFaded, hitInsetX = 5, hitInsetY = 10}

	local pinTooltipCreatorShard = {
		creator = function(pin)
			ZO_WorldMap_GetTooltipForMode(ZO_MAP_TOOLTIP_MODE.INFORMATION):AppendSkyshardHint(pin.m_PinTag.skyId)
		end,
		tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
		categoryId = ZO_MapPin.PIN_ORDERS.SUGGESTIONS,
		gamepadSpacing = true,
	}

	local pinTooltipCreatorPOIShard = {
        creator = function(pin)
			local pinTag = pin.m_PinTag
			local zoneIndex, poiIndex = pinTag[1], pinTag[2]
			local poiName = GetPOIInfo(zoneIndex, poiIndex)
			local skyshardId = GetPOISkyshardId(zoneIndex, poiIndex)
			local mapInfoTip = ZO_WorldMap_GetTooltipForMode(ZO_MAP_TOOLTIP_MODE.INFORMATION)

			if not IsInGamepadPreferredMode() then
				if pinTag.isDelve then
					mapInfoTip:AddLine(zo_strformat(SI_WORLD_MAP_DELVE_NAME, poiName), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
				elseif pinTag.isPublicDungeon then
					mapInfoTip:AddLine(zo_strformat(SI_WORLD_MAP_PUBLIC_DUNGEON_NAME, poiName), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
				else
					mapInfoTip:AddLine(poiName, "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
				end
				
				if skyshardId ~= 0 then
					local hintText = GetSkyshardHint(skyshardId)
					mapInfoTip:AddLine(zo_strformat(SI_WORLD_MAP_SKYSHARD_HINT_FORMATTER, hintText), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())

					local skyshardDiscoveryStatus = GetSkyshardDiscoveryStatus(skyshardId)
					mapInfoTip:AddLine(zo_strformat(SI_WORLD_MAP_SKYSHARD_STATUS_FORMATTER, GetString("SI_SKYSHARDDISCOVERYSTATUS", skyshardDiscoveryStatus)), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
				end
			else
				local delveSection = mapInfoTip.tooltip:AcquireSection(mapInfoTip.tooltip:GetStyle("delveMainSection"))

				local nameFormat = pin:IsPublicDungeonPin() and SI_WORLD_MAP_PUBLIC_DUNGEON_NAME or SI_WORLD_MAP_DELVE_NAME
				local delveName = zo_strformat(nameFormat, poiName)
				mapInfoTip:LayoutStringLine(delveSection, delveName, mapInfoTip.tooltip:GetStyle("delveTooltipName"))

				local skyshardId = GetPOISkyshardId(zoneIndex, poiIndex)
				if skyshardId ~= 0 then
					local hint = GetSkyshardHint(skyshardId)
					mapInfoTip:LayoutStringLine(delveSection, zo_strformat(SI_WORLD_MAP_SKYSHARD_HINT_FORMATTER, hint), mapInfoTip.tooltip:GetStyle("delveSkyshardHint"))

					local skyshardDiscoveryStatus = GetSkyshardDiscoveryStatus(skyshardId)
					mapInfoTip:LayoutStringLine(delveSection, zo_strformat(SI_WORLD_MAP_SKYSHARD_STATUS_FORMATTER, GetString("SI_SKYSHARDDISCOVERYSTATUS", skyshardDiscoveryStatus)), mapInfoTip.tooltip:GetStyle("delveSkyshardHint"))
				end
				mapInfoTip.tooltip:AddSection(delveSection)
			end
		end,
        tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
        hasTooltip = function() return true end,
        categoryId = ZO_MapPin.PIN_ORDERS.DESTINATIONS,
        gamepadSpacing = true,
	}

	ZO_WorldMap_AddCustomPin(pinTypeShard, pinTypeCallbackShard, pinTypeOnResizeCallback, pinLayoutDataShard, pinTooltipCreatorShard)
	ZO_WorldMap_AddCustomPin(pinTypeShardNoTooltip, pinTypeCallbackShardNoTooltip, pinTypeOnResizeCallback, pinLayoutDataShardNoTooltip)
	ZO_WorldMap_AddCustomPin(pinTypePOIShard, pinTypeCallbackPOIShard, pinTypeOnResizeCallback, pinLayoutDataDelveOrDungeon, pinTooltipCreatorPOIShard)
	ZO_WorldMap_AddCustomPin(pinTypePOIShardAcquired, pinTypeCallbackPOIShardAcquired, pinTypeOnResizeCallback, pinLayoutDataDelveOrDungeon)

	ZO_WorldMap_SetCustomPinEnabled(_G[pinTypeShard], true)
	ZO_WorldMap_SetCustomPinEnabled(_G[pinTypeShardNoTooltip], true)
	ZO_WorldMap_SetCustomPinEnabled(_G[pinTypePOIShard], true)
	ZO_WorldMap_SetCustomPinEnabled(_G[pinTypePOIShardAcquired], true)
end

local function OnInitialActivated(e)
	GeneratePinData() PopulatePins() 

	local function GetShardCounts()
		local numShardsAcq, maxShards, tutShard = 0, 0, 1 -- (+ one missable, in Admantine Tower tutorial)
		local function GetNextZoneStoryZoneIdIter(_, lastZoneId) return GetNextZoneStoryZoneId(lastZoneId) end	
		for zoneId in GetNextZoneStoryZoneIdIter do 
			maxShards = maxShards + GetNumSkyshardsInZone(zoneId) 

			for skyIndex=1, GetNumSkyshardsInZone(zoneId) do
				local skyId = GetZoneSkyshardId(zoneId, skyIndex)

				if GetSkyshardDiscoveryStatus(skyId) == SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
					numShardsAcq = numShardsAcq + 1
				end
			end
		end

		maxShards = maxShards + tutShard
		numShardsAcq = numShardsAcq + (HasCompletedQuest(4296) and tutShard or 0)

		return numShardsAcq, maxShards
	end

	ZO_Skills:SetHandler("OnShow", function()
		local skyShards = GetNumSkyShards()
		local baseStr = zStrFmt(SI_SKILLS_SKY_SHARDS_COLLECTED, skyShards)

		local numShardsAcq, maxShards = GetShardCounts()

		ZO_SkillsSkyShards:SetText(zStrFmt("<<1>> |cffffff(<<2>>/<<3>>)|r", baseStr, numShardsAcq, maxShards))
	end, addOnName)

	-- Delaying this seems to iron out a few bugs with waiting for the map to load on laggy clients
	zo_callLater(function() RefreshCustomPins() SetMapToPlayerLocation() end, 500)

	-- Issue with FyrMM when refreshing, so if the user has it loaded, just let SimpleSkyshards update when they open the map, or on Skyshards Updated
	if not FyrMM then EVENT_MANAGER:RegisterForEvent(addOnName.."NoFyrMM", EVENT_POI_UPDATED, function() RefreshCustomPins() end) end

	EVENT_MANAGER:RegisterForEvent(addOnName, EVENT_SKYSHARDS_UPDATED, function() RefreshCustomPins() end)

	-- Quick replacement to show completed delve skyshards on world map on Acquired Skyshards base game map toggle
	SecurePostHook(ZO_WorldMapFilterPanel_Shared, "SetPinFilter", function(obj, mapPinGroup, shown)
		if mapPinGroup == MAP_FILTER_ACQUIRED_SKYSHARDS then
			RefreshCustomPins()
		end
	end)

	EVENT_MANAGER:UnregisterForEvent(addOnName, EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(addOnName, EVENT_PLAYER_ACTIVATED, function() zo_callLater(OnInitialActivated, 50) end)