--
-- Calamath's Quest Tracker [CQT]
--
-- Copyright (c) 2022 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not CQuestTracker then return end
local CQT = CQuestTracker:SetSharedEnvironment()
local g_mapPinManager = ZO_WorldMap_GetPinManager()
local g_mapPanAndZoom = ZO_WorldMap_GetPanAndZoom()

-- ---------------------------------------------------------------------------------------
-- Quest Ping Manager Class for Vanilla WorldMap
-- ---------------------------------------------------------------------------------------
-- Scope: This class provides a feature for displaying ping animations for quest MapPin on vanilla map screens.
--        We only deal with MAP_PIN_TYPE_QUEST_PING, which has nothing to do with MAP_PIN_TYPE_PING.
--
local CQT_QuestPing_Singleton = CT_AdjustableInitializingObject:Subclass()

function CQT_QuestPing_Singleton:RegisterOverriddenAttributeTable(overriddenAttrib)
	-- If the external attribute table not be specified in the constructor, it could be registered with this method only once.
	if self._hasOverriddenAttrib or type(overriddenAttrib) ~= "table" then
		return false
	else
		self._overriddenAttrib = overriddenAttrib
		self._hasOverriddenAttrib = true
		return true
	end
end

function CQT_QuestPing_Singleton:Initialize()
	self.name = "CQT-QuestPingSingleton"
	self._attrib = {
		pingingEnabled = true, 
		pingingOnFocusChange = true, 
		stopPingingOnHidingMapScene = false, 
		tryCompensatingQuestPingPin = true, 
	}
	CT_AdjustableInitializingObject.Initialize(self)
	self.isFirstTimePlayerActivated = true
	self.modifiedClearQuestPings = false
	self.shouldShowOnFocusChangeCallback = nil
	self.internalQuestPingData = {
		questIndex = 0, 
		stepIndex = nil, 
		conditionIndex = nil, 
	}
	self:OverrideClearQuestPingsFunction()
	SecurePostHook("ZO_WorldMap_ShowQuestOnMap", function(questIndex)
		local g_questPingData = ZO_WorldMap_GetQuestPingData()
		if g_questPingData and g_questPingData.questIndex == questIndex then
--			CQT.LDL:Debug("ZO_WorldMap_ShowQuestOnMap:QuestPing data set to %s", tostring(questIndex))
			self:SetInternalQuestPingData(questIndex, g_questPingData.stepIndex, g_questPingData.conditionIndex)
		end
	end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, function(_, addonName)
		if addonName ~= CQT.name then return end
--		CQT.LDL:Debug("QuestPingSingleton:EVENT_ADD_ON_LOADED")
		EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
		self:InitializeWorldMapQuestPingData()
	end)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(event, initial)
		if self.isFirstTimePlayerActivated then
			self.isFirstTimePlayerActivated = false
--			CQT.LDL:Debug("QuestPingSingleton:EVENT_PLAYER_ACTIVATED")
			-- The callback should not react to state change events prior to becoming player activated.
			FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerAssistStateChanged", function(unassistedData, assistedData)
				self:OnQuestAssistStateChanged(unassistedData, assistedData)
			end)
			if not initial then	-- ----------------------------- after reloadui
				self:RefreshWorldMapQuestPings()
			end
		end
	end)
	WORLD_MAP_MANAGER:RegisterCallback("Hidden", function()
		self:OnWorldMapFragmentHidden()
	end)

	-- The following are triggered after OnWorldMapFragmentHidden. Created to provide an option to force the quest pinging to stop when the map scene transitions to hidden.
	-- NOTE: If you use a minimap add-on that reuses WORLD_MAP_FRAGMENT, quest pinging will keep visible when transitioning from the map scene to the HUD scene because WORLD_MAP_FRAGMENT will not be hidden. 
	-- This is a vanilla UI specification, but enable the stopPingingOnHidingMapScene attribute if you do not want to display any quest pings on the minimap at all.
	if WORLD_MAP_SCENE then
		WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
			if newState == SCENE_HIDDEN then
				self:OnWorldMapSceneHidden()
			end
		end)
	end
	if GAMEPAD_WORLD_MAP_SCENE then
		GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState)
			if newState == SCENE_HIDDEN then
				self:OnWorldMapSceneHidden()
			end
		end)
	end

	-- ZOS said wait until the map mode has been set before fielding these updates since adding a pin depends on the map having a mode.
	-- Our callback function must run after ZO_WorldMapPins_Manager:OnQuestAvailable.
	-- Therefore, keep in mind that the timing of callback registration depends on the timing of ZO_WorldMapPins_Manager registration.
	local function OnWorldMapModeChanged(modeData)
		if modeData then
			WORLD_MAP_QUEST_BREADCRUMBS:RegisterCallback("QuestAvailable", function(...)
				self:OnQuestAvailable(...)
			end)
			CALLBACK_MANAGER:UnregisterCallback("OnWorldMapModeChanged", OnWorldMapModeChanged)
		end
	end
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", OnWorldMapModeChanged)
end

function CQT_QuestPing_Singleton:ShouldShowOnFocusChange()
	local shouldShow = self:GetAttribute("pingingEnabled") and self:GetAttribute("pingingOnFocusChange")
	-- If you want to limit the quests that display QuestPing, register an optional callback function via SetShouldShowOnFocusChangeCallback method.
	if type(self.shouldShowOnFocusChangeCallback) == "function" then
		shouldShow = shouldShow and self.shouldShowOnFocusChangeCallback()
	end
	return shouldShow
end

function CQT_QuestPing_Singleton:OnQuestAssistStateChanged(unassistedData, assistedData)
--	CQT.LDL:Debug("FQT-QuestTrackerAssistStateChanged : %s -> %s", tostring(unassistedData and unassistedData:GetJournalIndex()), tostring(assistedData and assistedData:GetJournalIndex()))
	local newFocusedQuestIndex = assistedData and assistedData:GetJournalIndex()
	if newFocusedQuestIndex then
		if self:ShouldShowOnFocusChange() then
			self:SetWorldMapQuestPingPins(newFocusedQuestIndex)
		else
			self:ResetWorldMapQuestPingPins()
		end
	end
end

function CQT_QuestPing_Singleton:OnWorldMapFragmentHidden()
--	CQT.LDL:Debug("WORLD_MAP_FRAGMENT:OnHidden")
	if self:GetAttribute("pingingEnabled") then
		local journalIndex, stepIndex, conditionIndex = self:GetInternalQuestPingData()
		self:SetWorldMapQuestPingData(journalIndex, stepIndex, conditionIndex)
		self:RefreshWorldMapQuestPings()
	else
		self:ResetWorldMapQuestPingPins()
	end
end

function CQT_QuestPing_Singleton:OnWorldMapSceneHidden()
--	CQT.LDL:Debug("WORLD_MAP_SCENE:OnHidden")
	if self:GetAttribute("stopPingingOnHidingMapScene") then
		self:ResetWorldMapQuestPingPins()
	end
end

function CQT_QuestPing_Singleton:OnQuestAvailable(journalIndex)
	if journalIndex == self:GetInternalQuestPingData() then
		-- TODO: Remove the following lines after update 45.
		if g_mapPinManager.DoesCurrentMapHideQuestPins and g_mapPinManager.DoesCurrentMapHideQuestPins() then
			return
		end
		-- TODO: up to this line
		if not ZO_WorldMap_IsPinGroupShown(MAP_FILTER_QUESTS) then
			return
		end
		if not self:GetAttribute("pingingEnabled") then
			return
		end
		if not self:GetAttribute("tryCompensatingQuestPingPin") then
			return
		end
		-- When the quest condition destination is inside a dungeon, and the player is in a distant zone different from the destination dungeon entrance, 
		-- WORLD_MAP_QUEST_BREADCRUMBS often loses the entrance location on the dungeon entrance map.
		-- The internal API processing for obtaining map coordinates for quest conditions tries to use the map coordinates inside the dungeon by converting 
		-- them to the world map coordinates but fails to convert a correct coordinate to draw as the quest pin. 
		-- So, we try to create a quest ping pin based on dungeon POI coordinates instead in some cases where the QuestPing does not appear on the zone map.

		if not g_mapPinManager:FindPin("pings", MAP_PIN_TYPE_QUEST_PING) then
			local questSteps = WORLD_MAP_QUEST_BREADCRUMBS:GetSteps(journalIndex)
			local stepIndex, questConditions = next(questSteps or {})
			local conditionIndex = next(questConditions or {})
--			CQT.LDL:Debug("WORLD_MAP_QUEST_BREADCRUMBS:OnQuestPingPinAvailable - Missing QuestPingPin = %s-%s-%s", tostring(journalIndex), tostring(stepIndex), tostring(conditionIndex))
			if DoesJournalQuestConditionHavePosition(journalIndex, stepIndex, conditionIndex) then
				local currentMapId = GetCurrentMapId()
				if CQT_WORLD_MAP_UTILITY:IsRootZoneMap(currentMapId) or CQT_WORLD_MAP_UTILITY:IsRootZoneCityDetailedMap(currentMapId) then
					SetMapToQuestCondition(journalIndex, stepIndex, conditionIndex)
					local destinationMapId, destinationMapContentType = GetCurrentMapId(), GetMapContentType()
					SetMapToMapId(currentMapId)
					if destinationMapContentType ~= MAP_CONTENT_DUNGEON then
						return
					end
					local destinationPoiId = CQT_WORLD_MAP_UTILITY:GetPoiIdForDungeon(destinationMapId)
					local poiZoneIndex, poiIndex = GetPOIIndices(destinationPoiId)
					local xLoc, yLoc, _, _, isShownInCurrentMap = GetPOIMapInfo(GetPOIIndices(destinationPoiId))
					if isShownInCurrentMap and ZO_WorldMap_IsNormalizedPointInsideMapBounds(xLoc, yLoc) then
						local questPinTag = ZO_MapPin.CreateQuestPinTag(journalIndex, stepIndex, conditionIndex)
						g_mapPinManager:CreatePin(MAP_PIN_TYPE_QUEST_PING, questPinTag, xLoc, yLoc)
						CQT.LDL:Debug("created Quest Ping Pin : poiId = %s", tostring(destinationPoiId))
					end
				end
			end
		end
	end
end


-- [WorldMap questPingData management] --

--  Since g_questPingData is a local variable in 'worldmap.lua' and its initial value is nil, we cannot write until someone fills it with a value first.
--  There is no global ZO_WorldMap_SetQuestPingData function for g_questPingData, and currently only ZO_WorldMap_ShowQuestOnMap api sets the value.
--  Therefore, we will try to initialize g_questPingData by passing a special quest index to the function under special circumstance.

-- VERSION1
--  To perform this process behind the scenes, we prevent the transition to the map screen, which is the original purpose of ZO_WorldMap_ShowQuestOnMap.
--  @journalIndex - valid quest index for initializing. The quest must be able to display a map. Avoid crafting quests and Cadwells Almanac.
--[[
function CQT_QuestPing_Singleton:InitializeWorldMapQuestPingData(journalIndex)
	local g_questPingData = ZO_WorldMap_GetQuestPingData()
	if not g_questPingData then
		local currentScene = SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene()
		local journalIndex = journalIndex or QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex() or 0
		if not currentScene or not IsValidQuestIndex(journalIndex) then CQT.LDL:Error("QuestPingSingleton: requirements not met in InitializeWorldMapQuestPingData") return false end
		local currentMapId = GetCurrentMapId()
		local currentNormalizedZoom = g_mapPanAndZoom:GetCurrentNormalizedZoom()
		-- BEGIN preventing scene change.  You may want to say hacky.
		local noQuestMapLocationErrorStringId = SI_WORLD_MAP_NO_QUEST_MAP_LOCATION
		local hideSceneConfirmationCallback = currentScene.hideSceneConfirmationCallback
		_G["SI_WORLD_MAP_NO_QUEST_MAP_LOCATION"] = 0	-- Temporarily suppress alert message.
		currentScene:SetHideSceneConfirmationCallback(function() end)
		ZO_WorldMap_ShowQuestOnMap(journalIndex)
		currentScene:SetHideSceneConfirmationCallback(hideSceneConfirmationCallback)
		_G["SI_WORLD_MAP_NO_QUEST_MAP_LOCATION"] = noQuestMapLocationErrorStringId
		-- END preventing scene change.
		if SCENE_MANAGER:GetCurrentScene() ~= currentScene then CQT.LDL:Error("QuestPingSingleton: preventing scene change failed in InitializeWorldMapQuestPingData") end
		if GetCurrentMapId() ~= currentMapId then
			WORLD_MAP_MANAGER:SetMapById(currentMapId)
		end
		if g_mapPanAndZoom:GetCurrentNormalizedZoom() ~= currentNormalizedZoom then
			g_mapPanAndZoom:SetCurrentNormalizedZoom(currentNormalizedZoom)
		end
		return ZO_WorldMap_GetQuestPingData() ~= nil
	end
end
]]
local voidIsMapChangingAllowed = function() return true end	-- always allowed
local voidClearQuestPings = function() end	-- void
local voidSetMapToQuestZone = function() return SET_MAP_RESULT_MAP_CHANGED end 	-- void but always return successful
local voidIsWorldMapShowing = function() return true end	-- void but always return true (showing)
local voidJumpToPinWhenAvailable = function() end	-- void
local voidCALLBACK_MANAGER = { FireCallbacks = function() end, }	-- void FireCallbacks method
function CQT_QuestPing_Singleton:InitializeWorldMapQuestPingData()
	-- Design rule: Never use SetWorldMapQuestPingData or ClearWorldMapQuestPingData methods inside this function.
	local g_questPingData = ZO_WorldMap_GetQuestPingData()
	if not g_questPingData then
		-- backup some apis
		local orgIsMapChangingAllowed = WORLD_MAP_MANAGER.IsMapChangingAllowed
		local orgClearQuestPings = WORLD_MAP_MANAGER.ClearQuestPings
		local orgSetMapToQuestZone = SetMapToQuestZone
		local orgIsWorldMapShowing = ZO_WorldMap_IsWorldMapShowing
		local orgJumpToPinWhenAvailable = g_mapPanAndZoom.JumpToPinWhenAvailable
		local orgCALLBACK_MANAGER = CALLBACK_MANAGER
		-- equivalent operation of g_questPingData = { questIndex = 0 }
		WORLD_MAP_MANAGER.IsMapChangingAllowed = voidIsMapChangingAllowed
		WORLD_MAP_MANAGER.ClearQuestPings = voidClearQuestPings
		_G["SetMapToQuestZone"] = voidSetMapToQuestZone
		_G["ZO_WorldMap_IsWorldMapShowing"] = voidIsWorldMapShowing
		g_mapPanAndZoom.JumpToPinWhenAvailable = voidJumpToPinWhenAvailable
		_G["CALLBACK_MANAGER"] = voidCALLBACK_MANAGER
		ZO_WorldMap_ShowQuestOnMap(0)
		-- restore apis
		WORLD_MAP_MANAGER.IsMapChangingAllowed = orgIsMapChangingAllowed
		WORLD_MAP_MANAGER.ClearQuestPings = orgClearQuestPings
		_G["SetMapToQuestZone"] = orgSetMapToQuestZone
		_G["ZO_WorldMap_IsWorldMapShowing"] = orgIsWorldMapShowing
		g_mapPanAndZoom.JumpToPinWhenAvailable = orgJumpToPinWhenAvailable
		_G["CALLBACK_MANAGER"] = orgCALLBACK_MANAGER
		-- validation
		if self:GetWorldMapQuestPingData() then
--			CQT.LDL:Debug("QuestPingSingleton: InitializeWorldMapQuestPingData [successful]")
		else
			CQT.LDL:Error("QuestPingSingleton: InitializeWorldMapQuestPingData [failed]")
		end
		return ZO_WorldMap_GetQuestPingData() ~= nil
	else
		CQT.LDL:Debug("QuestPingSingleton: InitializeWorldMapQuestPingData [saved value]")
	end
end

--  The original ClearQuestPings would destroy the g_questPingData table and assign nil.
--  In this case, it is no longer possible to assign values to g_questPingData again after this, so we decided to keep the original table.
--  For this purpose, we shall completely replace the original ZO_WorldMapManager:ClearQuestPings method.
function CQT_QuestPing_Singleton:OverrideClearQuestPingsFunction()
	if self.modifiedClearQuestPings then return end
	ZO_PreHook(WORLD_MAP_MANAGER, "ClearQuestPings", function(WORLD_MAP_MANAGER_self, ...)
		self:ClearWorldMapQuestPingData()
		self:RemoveWorldMapQuestPings()
		-- Returning true in the ZO_PreHook function means blocking the execution of the original WORLD_MAP_MANAGER:ClearQuestPings function.
		-- If you want to hook into this function, adjust your add-on's manifest file so that it is loaded after this add-on.
		return true
	end)
	self.modifiedClearQuestPings = true
end

function CQT_QuestPing_Singleton:ClearWorldMapQuestPingData()
	local g_questPingData = ZO_WorldMap_GetQuestPingData()
	if type(g_questPingData) == "table" then
		ZO_ClearTable(g_questPingData)
		-- NOTE: After consideration, the initialization value of g_questPingData should not be an empty table. A table with the questIndex of 0 is better.
		-- (1) 0 is not in LuaIndex.
		-- (2) 0 is never regularly used as the journalQuestIndex. In other words, a ZO_MapPin object with the questIndex value of 0 is never created.
		-- (3) To make the judgment of the ZO_MapPin:DoesQuestDataMatchQuestPingData function the same as before, the questIndex values of questPingData and ZO_MapPin.m_PinTag[1] of non-quest pin must be different.
		--     Occasionally, ZO_MapPin:GetQuestIndex() returns -1 as an outlier for non-quest pins. Because of this, we must avoid -1 as well, except for nil.
		-- (4) ZO_WorldMapPins_Manager:AddPinsToArray returns all quest pins from the lookup table when passing nil as the questIndex value argument.
		--     On the other hand, if we pass 0 as the argument, there are no pins to explore. This helps reduce the load on RefreshMapPings.
		g_questPingData.questIndex = 0
--		CQT.LDL:Debug("QuestPingSingleton:QuestPing data cleared")
	else
		self:InitializeWorldMapQuestPingData()
	end
end

function CQT_QuestPing_Singleton:GetWorldMapQuestPingData()
	return ZO_WorldMap_GetQuestPingData()
end

function CQT_QuestPing_Singleton:SetWorldMapQuestPingData(journalIndex, stepIndex, conditionIndex)
	local journalIndex = journalIndex or 0
	local g_questPingData = self:GetWorldMapQuestPingData()
	if type(g_questPingData) ~= "table" then
		self:InitializeWorldMapQuestPingData()
	end
	g_questPingData = self:GetWorldMapQuestPingData()
	g_questPingData.questIndex = journalIndex
	g_questPingData.stepIndex = stepIndex
	g_questPingData.conditionIndex = conditionIndex
--	CQT.LDL:Debug("QuestPingSingleton:QuestPing data set (%s, %s, %s)", tostring(journalIndex), tostring(stepIndex), tostring(conditionIndex))
end


-- [Internal questPingData management]:
--  g_questPingData will initialize each time the worldmap scene fragment transitions to the hiding state. So we need to keep it backed up internally.
function CQT_QuestPing_Singleton:ClearInternalQuestPingData()
	return self:SetInternalQuestPingData(0, nil, nil)
end

function CQT_QuestPing_Singleton:GetInternalQuestPingData()
	return self.internalQuestPingData.questIndex, self.internalQuestPingData.stepIndex, self.internalQuestPingData.conditionIndex
end

function CQT_QuestPing_Singleton:SetInternalQuestPingData(journalIndex, stepIndex, conditionIndex)
	local journalIndex = journalIndex or 0
	self.internalQuestPingData.questIndex = journalIndex
	self.internalQuestPingData.stepIndex = stepIndex
	self.internalQuestPingData.conditionIndex = conditionIndex
end


-- [WorldMap QuestPingPin management]
function CQT_QuestPing_Singleton:RemoveWorldMapQuestPings()
	g_mapPinManager:RemovePins("pings", MAP_PIN_TYPE_QUEST_PING)
end

function CQT_QuestPing_Singleton:AddWorldMapQuestPings()
-- We must maintain functional equivalence with the questPing section in the RefreshMapPings function.
	if GetMapType() ~= MAPTYPE_COSMIC then
		-- Design rule: ZOS doesn't want manual player pings showing up on the Aurbis.
		local g_questPingData = self:GetWorldMapQuestPingData()
		if g_questPingData and IsValidQuestIndex(g_questPingData.questIndex or 0) then
			local questMapPins = {}
			g_mapPinManager:AddPinsToArray(questMapPins, "quest", g_questPingData.questIndex)
			for _, questPin in ipairs(questMapPins) do
				if questPin:DoesQuestDataMatchQuestPingData() then
					local tag = ZO_MapPin.CreateQuestPinTag(g_questPingData.questIndex, g_questPingData.stepIndex, g_questPingData.conditionIndex)
					--  NOTE: This is not a joke, the specification.
					--　QuestPinTag = {
					--     [1] = questIndex(= journalIndex), 
					--     [2] = conditionIndex, 
					--     [3] = stepIndex, 
					--  } 
					local xLoc, yLoc = questPin:GetNormalizedPosition()
					g_mapPinManager:CreatePin(MAP_PIN_TYPE_QUEST_PING, tag, xLoc, yLoc)
				end
			end
		end
	end
end

function CQT_QuestPing_Singleton:RefreshWorldMapQuestPings()
	self:RemoveWorldMapQuestPings()
	self:AddWorldMapQuestPings()
end


-- [Api section]
function CQT_QuestPing_Singleton:SetWorldMapQuestPingPins(journalIndex)
	if not self:GetAttribute("pingingEnabled") then return end
	self:SetInternalQuestPingData(journalIndex, nil, nil)
	self:SetWorldMapQuestPingData(journalIndex, nil, nil)
	self:RefreshWorldMapQuestPings()
end

function CQT_QuestPing_Singleton:ResetWorldMapQuestPingPins()
	self:ClearWorldMapQuestPingData()
	self:ClearInternalQuestPingData()
	self:RemoveWorldMapQuestPings()
end

function CQT_QuestPing_Singleton:IsShowingQuestPingPins(journalIndex)
	local questIndex = self:GetInternalQuestPingData()
	if journalIndex then
		return journalIndex == questIndex
	else
		return questIndex ~= 0
	end
end

function CQT_QuestPing_Singleton:SetShouldShowOnFocusChangeCallback(callback)
	self.shouldShowOnFocusChangeCallback = callback
end

-- ---------------------------------------------------------------------------------------

local CQT_QUEST_PING_MANAGER = CQT_QuestPing_Singleton:New()	-- Never do this more than once!

-- global API --
local function GetQuestPingManager() return CQT_QUEST_PING_MANAGER end
CQT:RegisterSharedObject("GetQuestPingManager", GetQuestPingManager)

