
local AddonName="MapFilterTestCase"
local SavedVars,DefaultVars={},{[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,[9]=true,[10]=true,[11]=true,[12]=true,[13]=true,[14]=true,[15]=true,[16]=true,[17]=true,[18]=true,[19]=true,[20]=true,[21]=true,[22]=true,[23]=true,[24]=true,[25]=true,[26]=true}

local PinManager
local UpdatingMapPin,UpdatingCompassPin,PinId={},{},{}
local FILTER_COUNT=26 --Amount of filters
local CustomPins={	--Types
	[1]={name="old_Chest_1",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/old/Chest_1.dds"},
	[2]={name="old_Chest_2",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/old/Chest_2.dds"},
	[3]={name="old_Lorebook_1",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/old/Lorebook_1.dds"},
	[4]={name="old_Lorebook_1-2",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/old/Lorebook_1-2.dds"},
	[5]={name="old_Lorebook_2",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/old/Lorebook_2.dds"},
	[6]={name="old_Lorebook_2-2",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/old/Lorebook_2-2.dds"},
	[7]={name="old_Scroll_1",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/old/Scroll_1.dds"},
	[8]={name="old_Skyshard_1",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/old/Skyshard_1.dds"},
	[9]={name="old_Treasure_1",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/old/Treasure_1.dds"},
	[10]={name="old_Treasure_1-2",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/old/Treasure_1-2.dds"},
	[11]={name="old_Treasure_2",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/old/Treasure_2.dds"},
	[12]={name="old_Treasure_3",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/old/Treasure_3.dds"},
	[13]={name="old_Treasure_4",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/old/Treasure_4.dds"},
	[14]={name="new_Chest_1",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/new/Chest_1.dds"},
	[15]={name="new_Chest_2",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/new/Chest_2.dds"},
	[16]={name="new_Lorebook_1",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/new/Lorebook_1.dds"},
	[17]={name="new_Lorebook_1-2",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/new/Lorebook_1-2.dds"},
	[18]={name="new_Lorebook_2",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/new/Lorebook_2.dds"},
	[19]={name="new_Lorebook_2-2",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/new/Lorebook_2-2.dds"},
	[20]={name="new_Scroll_1",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/new/Scroll_1.dds"},
	[21]={name="new_Skyshard_1",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/new/Skyshard_1.dds"},
	[22]={name="new_Treasure_1",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/new/Treasure_1.dds"},
	[23]={name="new_Treasure_1-2",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/new/Treasure_1-2.dds"},
	[24]={name="new_Treasure_2",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/new/Treasure_2.dds"},
	[25]={name="new_Treasure_3",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/new/Treasure_3.dds"},
	[26]={name="new_Treasure_4",id={},pin={},maxDistance=0.05,level=101,texture=AddonName.."/new/Treasure_4.dds"},
	}
-- Create Pin that does only whats needed
local function customCreatePin(pinType, pinTag, xLoc, yLoc)
    local pin, pinKey = PinManager:AcquireObject()
    pin:SetData(pinType, pinTag)
    pin:SetOriginalPosition(xLoc, yLoc)
    pin:SetLocation(xLoc, yLoc)

    local customPinData = PinManager.customPins[pinType]
    if customPinData then
        PinManager:MapPinLookupToPinKey(customPinData.pinTypeString, pinType, pinTag, pinKey)
    end
end
--Callbacks
local function MapPinAddCallback(i)
	if not CustomPins[i] then d("MapFilterTestCase: "..tostring(i).." is wrong pin type.") return end
	if i <= 13 then 
		customCreatePin(_G[CustomPins[i].name],{i},0.1+(i*0.05),0.5)
	elseif i <= 26 then 
		customCreatePin(_G[CustomPins[i].name],{i},0.1+((i*0.05)-(13*0.05)),0.6)
	else 
		customCreatePin(_G[CustomPins[i].name],{i},0.1+((i*0.05)-(26*0.05)),0.7)
	end
end

--Initialization
local function AddPinFilter()
	local function SetNameForMapPinGroup(i)
		local mapPinGroup = _G[CustomPins[i].name]
		local icon=zo_iconFormat(CustomPins[i].texture,24,24)
		local name=CustomPins[i].name
		ZO_CreateStringId("SI_MAPFILTER" .. mapPinGroup, icon.." "..name)
		return mapPinGroup
	end
	local function FilterCallback()
	end
	for i=FILTER_COUNT,1,-1 do --revesed else they apear backwars in filter list
		if CustomPins[i] then
			local mapPinGroup = SetNameForMapPinGroup(i)
			local function AddCheckBox(panel)
				local orgBuild = panel.PostBuildControls
				function panel.PostBuildControls(panel)
					panel:AddPinFilterCheckBox(mapPinGroup, FilterCallback)
					return orgBuild(panel)
				end
			end
			AddCheckBox(GAMEPAD_WORLD_MAP_FILTERS.pvePanel)
			AddCheckBox(GAMEPAD_WORLD_MAP_FILTERS.pvpPanel)
			AddCheckBox(GAMEPAD_WORLD_MAP_FILTERS.imperialPvPPanel) 
		end
	end
end

local filterIdToFilterIndex ={}
ZO_PostHook(ZO_WorldMapFilterPanel_Shared, "GetPinFilter", function(self, mapPinGroup)
    local i = filterIdToFilterIndex[mapPinGroup]
	if i then return SavedVars[i] end
end)
ZO_PostHook(ZO_WorldMapFilterPanel_Shared, "SetPinFilter", function(self, mapPinGroup, shown)
    local i = filterIdToFilterIndex[mapPinGroup]
	if i then
		SavedVars[i] = shown
		for pin,id in pairs(CustomPins[i].id) do
			PinManager:SetCustomPinEnabled(id, shown)
			PinManager:RefreshCustomPins(id)
		end
	end
end)

--update the Filters
local function OnMapChanged()
	for mapPinGroup,i in pairs(filterIdToFilterIndex) do
		if GAMEPAD_WORLD_MAP_FILTERS then
			GAMEPAD_WORLD_MAP_FILTERS.currentPanel:SetPinFilter(mapPinGroup, SavedVars[i] ~= false)
		end
	end
end

local function OnLoad(eventCode,addonName)
	if addonName~=AddonName then return end
	EVENT_MANAGER:UnregisterForEvent(AddonName,EVENT_ADD_ON_LOADED)
	SavedVars=ZO_SavedVars:New("MapFilterTestCase_SavedVars",2,nil,DefaultVars)
	PinManager=ZO_WorldMap_GetPinManager()
	for i=1,FILTER_COUNT do
		local filter=CustomPins[i]
		if filter then
			filter.size=40
			PinManager:AddCustomPin(filter.name,function() MapPinAddCallback(i) end,nil,filter)
			local id = _G[filter.name]
			filter.id[i]=id PinId[i]=id
			filterIdToFilterIndex[id] = i
		end
	end		
	AddPinFilter()
	--OnMapChanged()
	SLASH_COMMANDS["/test"]=function()
		CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnMapChanged)
	end
	
end

EVENT_MANAGER:RegisterForEvent(AddonName,EVENT_ADD_ON_LOADED,OnLoad)
