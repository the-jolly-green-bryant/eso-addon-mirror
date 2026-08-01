local Objectives = ZO_Object:Subclass()

local CYRODIIL_MAP_INDEX
local OBJECTIVE_DATA = 1
local LABEL_DATA = 2

function Objectives:New(...)
	local object = ZO_Object.New(self)
	object:Initialize(...)
	return object
end

function Objectives:Initialize(control)
	CYRODIIL_MAP_INDEX = GetCyrodiilMapIndex()

	self.control = control
	self.list = control:GetNamedChild("List")
	self.fragment = ZO_FadeSceneFragment:New(control)

	local map = SCENE_MANAGER:GetScene("worldMap")
	SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
		if(not IsInCyrodiil()) then return end
		if(scene == map and newState == "showing") then
			self:FocusOnObjective(self.selectedObjective)
		end
	end)
end

function Objectives:SetSelectedObjective(selectedObjective)
	self.selectedObjective = selectedObjective
	ZO_ScrollList_RefreshVisible(self.list)
end

local function CreateDataEntry(dataType, index, objectiveName, keepId, objectiveId, battlegroundContext, callback)
	return ZO_ScrollList_CreateDataEntry(dataType, {
		index = index,
		name = zo_strformat("<<1>>", objectiveName),
		keepId = keepId,
		objectiveId = objectiveId,
		battlegroundContext = battlegroundContext,
		callback = callback,
	})
end

local function AddObjectiveDataFromKeep(data, keepIndex)
	local keepId, battlegroundContext = GetKeepKeysByIndex(keepIndex)
	local keepName = GetKeepName(keepId)
	data[#data + 1] = CreateDataEntry(OBJECTIVE_DATA, #data + 1, keepName, keepId, nil, battlegroundContext)
end

local function AddObjectiveDataFromArtifactKeep(data, keepIndex)
	local keepId, battlegroundContext = GetKeepKeysByIndex(keepIndex)
	local objectiveId = GetKeepArtifactObjectiveId(keepId)
	local objectiveName = GetAvAObjectiveInfo(keepId, objectiveId, battlegroundContext)
	data[#data + 1] = CreateDataEntry(OBJECTIVE_DATA, #data + 1, objectiveName, keepId, objectiveId, battlegroundContext)
end

local function AddCustomObjectiveData(data, label, callback)
	data[#data + 1] = CreateDataEntry(OBJECTIVE_DATA, #data + 1, label, nil, nil, nil, callback)
end

local function AddLabeleData(data, label)
	data[#data + 1] = ZO_ScrollList_CreateDataEntry(LABEL_DATA, { label = label })
end

function Objectives:BuildLocationList()
	ZO_ScrollList_AddDataType(self.list, OBJECTIVE_DATA, "sidWarToolsObjectivesRow", 23, function(control, data)
		local objectiveLabel = control:GetNamedChild("Objective")
		objectiveLabel:SetText(data.name)
		objectiveLabel:SetSelected(self.selectedObjective == data)
	end)
	ZO_ScrollList_AddDataType(self.list, LABEL_DATA, "sidWarToolsObjectivesLabelRow", 25, function(control, data)
		local label = control:GetNamedChild("Text")
		label:SetText(data.label)
	end)

	local scrollData = ZO_ScrollList_GetDataList(self.list)

	-- Add Automatic Row

	AddCustomObjectiveData(scrollData, "Current Location", function()
		LibStub("LibGPS2"):PanToMapPosition(GetMapPlayerPosition("player"))
	end)

	local zoomButton = ZO_WorldMapZoomSliderButton1
	local zoomButtonClicked = zoomButton:GetHandler("OnClicked")
	AddCustomObjectiveData(scrollData, "Map Overview", function()
		zoomButtonClicked(zoomButton)
	end)

	-- Add GroupLeader Row
	-- Add Rally Point Row

	AddLabeleData(scrollData, GetString("SI_ALLIANCE", ALLIANCE_ALDMERI_DOMINION))
	AddObjectiveDataFromKeep(scrollData, 17) -- Black Boot
	AddObjectiveDataFromKeep(scrollData, 18) -- Bloodmayne
	AddObjectiveDataFromKeep(scrollData, 14) -- Faregyl
	AddObjectiveDataFromKeep(scrollData, 13) -- Alessia
	AddObjectiveDataFromKeep(scrollData, 15) -- Roebeck
	AddObjectiveDataFromKeep(scrollData, 16) -- Brindle
	AddObjectiveDataFromKeep(scrollData, 91) -- Nikel
	AddObjectiveDataFromArtifactKeep(scrollData, 79) -- Scroll of Altadoon
	AddObjectiveDataFromArtifactKeep(scrollData, 80) -- Scroll of Mnem

	AddLabeleData(scrollData, GetString("SI_ALLIANCE", ALLIANCE_DAGGERFALL_COVENANT))
	AddObjectiveDataFromKeep(scrollData, 1) -- Warden
	AddObjectiveDataFromKeep(scrollData, 2) -- Rayles
	AddObjectiveDataFromKeep(scrollData, 3) -- Glademist
	AddObjectiveDataFromKeep(scrollData, 4) -- Ash
	AddObjectiveDataFromKeep(scrollData, 5) -- Aleswell
	AddObjectiveDataFromKeep(scrollData, 6) -- Dragonclaw
	AddObjectiveDataFromKeep(scrollData, 93) -- Bleaker's
	AddObjectiveDataFromArtifactKeep(scrollData, 83) -- Scroll of Ni-Mohk
	AddObjectiveDataFromArtifactKeep(scrollData, 84) -- Scroll of Alma Ruma

	AddLabeleData(scrollData, GetString("SI_ALLIANCE", ALLIANCE_EBONHEART_PACT))
	AddObjectiveDataFromKeep(scrollData, 9) -- Kingscrest
	AddObjectiveDataFromKeep(scrollData, 10) -- Farragut
	AddObjectiveDataFromKeep(scrollData, 8) -- Arrius
	AddObjectiveDataFromKeep(scrollData, 7) -- Chalman
	AddObjectiveDataFromKeep(scrollData, 11) -- Blue Road
	AddObjectiveDataFromKeep(scrollData, 12) -- Drakelowe
	AddObjectiveDataFromKeep(scrollData, 92) -- Sejanus
	AddObjectiveDataFromArtifactKeep(scrollData, 82) -- Scroll of Chim
	AddObjectiveDataFromArtifactKeep(scrollData, 81) -- Scroll of Ghartok

	ZO_ScrollList_Commit(self.list)
end

function Objectives:FocusOnObjective(data)
	if(ZO_WorldMap_GetMode() >= MAP_MODE_KEEP_TRAVEL) then return end
	if(GetCurrentMapIndex() ~= CYRODIIL_MAP_INDEX and self.saveData.showCyrodiilMapInGates) then
		if(SetMapToMapListIndex(CYRODIIL_MAP_INDEX) == SET_MAP_RESULT_MAP_CHANGED) then
			LibStub("LibGPS2"):SetPlayerChoseCurrentMap()
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
		end
	end
	if(self.selectedObjective) then
		zo_callLater(function() -- TODO: do this without callLater
			if(data.callback) then
				data.callback()
		else
			local _, x, y
			if(data.objectiveId ~= nil) then
				_, x, y = GetAvAObjectivePinInfo(data.keepId, data.objectiveId, data.battlegroundContext)
			else
				_, x, y = GetKeepPinInfo(data.keepId, data.battlegroundContext)
			end

			LibStub("LibGPS2"):PanToMapPosition(x, y)
			WORLD_MAP_KEEP_INFO:ShowKeep(data.keepId)
		end
		end, 100)
	end
end

--Local XML

function Objectives:RowLocation_OnMouseDown(label, button)
	if(button == 1) then
		label:SetAnchor(LEFT, nil, LEFT, 0, 1)
	end
end

function Objectives:RowLocation_OnMouseUp(label, button, upInside)
	if(button == 1) then
		label:SetAnchor(LEFT, nil, LEFT, 0, 0)
		if(upInside) then
			local data = ZO_ScrollList_GetData(label:GetParent())
			self:SetSelectedObjective(data)

			PlaySound(SOUNDS.MAP_LOCATION_CLICKED)
			self:FocusOnObjective(data)
		end
	end
end

--Global XML
local ObjectivesInstance

function sidWarToolsObjectives_OnMouseDown(label, button)
	ObjectivesInstance:RowLocation_OnMouseDown(label, button)
end

function sidWarToolsObjectives_OnMouseUp(label, button, upInside)
	ObjectivesInstance:RowLocation_OnMouseUp(label, button, upInside)
end

function sidWarToolsObjectives_OnInitialized(self)
	ObjectivesInstance = Objectives:New(self)
	sidWarTools.Objectives = ObjectivesInstance
end
