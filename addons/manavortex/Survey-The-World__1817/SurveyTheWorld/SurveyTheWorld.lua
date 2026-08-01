local treasurePrefix	= ". "
local surveyPrefix		= "* "


local SurveyTheWorld 	= {}
STW 					= SurveyTheWorld
STW.surveyNames 		= {}
STW.treasureNames 		= {}
local treasure 			= SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP
local survey 			= SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT
local em				= EVENT_MANAGER


local orgFunction

local function buildSurveyNameList()
	local surveyNames 		= {}
	local treasureNames 	= {}
	local bagId  = BAG_BACKPACK
	local numBagSlots = GetBagSize(bagId)
	local slotId = 0
	for slotId = 0, numBagSlots do	
		local itemType, sItemType = GetItemType(bagId, slotId)
		if itemType == ITEMTYPE_TROPHY and (sItemType == treasure or sItemType == survey) then 
			local itemName = (zo_strformat(GetItemName(bagId, slotId)):match "^%s*(.-)%s*$")
			table.insert(((sItemType == survey and surveyNames) or treasureNames), itemName)
		end
	end	
	STW.surveyNames		= surveyNames
	STW.treasureNames	= treasureNames
end
STW.buildSurveyNameList = buildSurveyNameList

local function isInSurveyList(zoneName)	
	local surveyNames = STW.surveyNames
	for index, surveyName in pairs(surveyNames) do		
		if string.match(surveyName, zoneName) then return true end
	end
	return false
end
STW.isInSurveyList = isInSurveyList

local function isInTreasureList(zoneName)
	local treasureNames = STW.treasureNames
	for index, treasureName in pairs(treasureNames) do
		if string.match(treasureName, zoneName) then return true end
	end
	return false
end
STW.isInTreasureList = isInTreasureList

local function getPrefixFor(zoneName)
	local prefix = ""
	for word in zoneName:gmatch("%w+") do 
		if #word > 3 then -- don't match on articles and anything apostrophized
			if isInSurveyList(word) then prefix = surveyPrefix .. prefix end
			if isInTreasureList(word) then prefix = treasurePrefix .. prefix end
		end
	end	
	return #prefix == 0 and prefix or (prefix .. " ")
end
STW.getPrefixFor = getPrefixFor

local function escapeZoneName(zoneName)
	local count = 0 -- I know, paranoid
	while zoneName:match("^%A") and count <= 6 do
		zoneName = zoneName:gsub("^%A", "")
		count = count+1
	end
	return zoneName
end

local function hookWorldMapFunctions()
 
    if nil == VOTANS_IMPROVED_LOCATIONS then
        orgFunction = WORLD_MAP_LOCATIONS.SetupLocation
        function WORLD_MAP_LOCATIONS:SetupLocation(rowControl, rowData)    
            if rowControl then  
                rowData.locationName = STW.getPrefixFor(rowData.locationName) .. escapeZoneName(rowData.locationName)
            end          
            orgFunction(self, rowControl, rowData)
        end
        
        --gamepad 
        local orgFunctionGamepad = GAMEPAD_WORLD_MAP_LOCATIONS.SetupLocation
        function GAMEPAD_WORLD_MAP_LOCATIONS:SetupLocation(rowControl, rowData, ...)
            --locationName changed already, but for gamepad it uses text instead 
			local zoneName = rowData.locationName  
            rowData.text = STW.getPrefixFor(rowData.locationName) .. escapeZoneName(rowData.locationName)
            orgFunctionGamepad(self, rowControl, rowData, ...)
        end  
    else    
        orgFunction = VOTANS_IMPROVED_LOCATIONS.SetupLocation   
        function VOTANS_IMPROVED_LOCATIONS:SetupLocation(rowControl, rowData)
            rowData.locationName = STW.getPrefixFor(rowData.locationName) .. escapeZoneName(rowData.locationName)
            orgFunction(self, rowControl, rowData)
        end
 
    end 
end

local function updateMap()
	if nil ~= WORLD_MAP_LOCATIONS then			WORLD_MAP_LOCATIONS:BuildLocationList() end
	if nil ~= GAMEPAD_WORLD_MAP_LOCATIONS then 	GAMEPAD_WORLD_MAP_LOCATIONS:BuildLocationList() end
end


local function onSlotUpdate(eventCode, bagId, slotId, isNewItem)
	if not bagId == BAG_BACKPACK then return end
	if not isNewItem then 
		STW.buildSurveyNameList() 
		updateMap()
		return
	end
	local itemType, sItemType = GetItemType(bagId, slotId)
	if itemType == ITEMTYPE_TROPHY and (sItemType == treasure or sItemType == survey) then 
		STW.buildSurveyNameList()
		updateMap()
	end		
end

local function registerEvents()
	em:RegisterForEvent("SurveyTheWorld", 	EVENT_PLAYER_ACTIVATED, 			buildSurveyNameList)
	em:RegisterForEvent("SurveyTheWorld", 	EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onSlotUpdate)
end


local function OnAddOnLoaded(event, addonName)

	if addonName ~= "SurveyTheWorld" then return end

	buildSurveyNameList()	
	hookWorldMapFunctions()
	registerEvents()
	em:UnregisterForEvent("SurveyTheWorld", EVENT_ADD_ON_LOADED)
	
end

em:RegisterForEvent("SurveyTheWorld", EVENT_ADD_ON_LOADED, OnAddOnLoaded)