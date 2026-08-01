local gps = LibStub("LibGPS2")

function GetSetIndexByName(setName)
	if (CraftingStations ~= nil and CraftingStations.ItemSets) then
		local itemSets = CraftingStations.ItemSets
		for i, data in ipairs(itemSets) do
			if(data.name == setName) then
				return i, true
			end
		end
		return #itemSets + 1, false
	end
	
	return nil, false
end

function GetCraftingStationDataBySetIndex(itemSetIndex)
	if (CraftingStations ~= nil and CraftingStations.Data) then
		local craftingStationsData = CraftingStations.Data
		
		--format: { globalX, globalY, setIndex, zoneMapIndex, zoneIndex, poiIndex, hideOnWorldmap, achievementId }, -- "set name"
		for i, itemSetValue in ipairs(craftingStationsData) do
			if (itemSetValue[3] == itemSetIndex) then
				return itemSetValue, true
			end
		end
		
		return #craftingStationsData + 1, false
	end
	
	return nil, false
end

function OpenMapToSet(setName)
	if (CraftingStations ~= nil) then
		local itemSetIndex, alreadyExists = GetSetIndexByName(setName)
		
		if (alreadyExists) then
			local itemSetData, itemSetExists = GetCraftingStationDataBySetIndex(itemSetIndex)
			
			if (itemSetExists) then
				if (not ZO_WorldMap_IsWorldMapShowing()) then
					ZO_WorldMap_ShowWorldMap()
				end
				
				zo_callLater(function() ZO_WorldMap_SetMapByIndex(itemSetData[4]) zo_callLater(function() gps:PanToMapPosition(gps:GlobalToLocal(itemSetData[1], itemSetData[2])) end, 1000) end, 1000)
				
				return itemSetData
			end
		end
		
		return false
	end
	
	return nil
end

local function normalizedLowerStr(str)
	return zo_strformat("<<z:1>>", str)
end

function IsQuestNameMasterWrit(name)
	if WritCreater ~= nil and WritCreater.langMasterWritNames ~= nil then
		--if not WritCreater.langMasterWritNames then return end
		local writNames = WritCreater.langMasterWritNames()
		local isMasterWrit = false
		local normalizedName = normalizedLowerStr(name)
		
		return string.find(normalizedLowerStr(name), writNames["M"])
	end
	
	return false
end

local function Split(str)
	if str ~= nil and type(str) == "string" then
		local rows = {}
		for row in str:gmatch("([^\n]*)\n?") do
			table.insert(rows, row)
		end
		
		return rows
	end
	
	return str
end

function EvalQuestForCraftingSetName(questIndex)
	--local questName, bgText, stepText, stepType, stepOverrideText, completed, tracked = GetJournalQuestInfo(questIndex)
	local questName = GetJournalQuestName(questIndex)

	if IsQuestNameMasterWrit(questName) then
		local condition, completed = GetJournalQuestConditionInfo(questIndex, 1)
		if completed == 1 or condition == "" then return end
		
		condition = string.gsub(condition, '-', ' ')
		
		local conditionStrings = Split(condition)
		local itemSetDelimiter = "Set: "
		
		for k, v in pairs(conditionStrings) do
			if (v ~= nil and v:len() > 2) then
				local matchString = v:sub(3)
				local matchSetIndex = matchString:find(itemSetDelimiter)
			
				if matchSetIndex ~= nil then
					matchSetIndex = (matchSetIndex + itemSetDelimiter:len())
				
					if (matchSetIndex <= matchString:len()) then
						d(matchString:sub(matchSetIndex, -1))
					
						OpenMapToSet(matchString:sub(matchSetIndex, -1))
						
						return true
					end
				
				end
				
			end
			
		end
	end
	
	return false
end