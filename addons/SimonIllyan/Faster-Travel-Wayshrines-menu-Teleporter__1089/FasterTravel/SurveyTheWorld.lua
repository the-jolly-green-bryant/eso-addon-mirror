local STW 	= {}
STW.surveyNames 		= {}
STW.treasureNames 		= {}
STW.leadsLookup         = {}

local treasure 			= SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP
local survey 			= SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT

local function buildSurveyNameList()
	local surveyNames 		= {}
	local treasureNames 	= {}
	local bagId  = BAG_BACKPACK
	local numBagSlots = GetBagSize(bagId)
	for slotId = 0, numBagSlots do	
		local itemType, sItemType = GetItemType(bagId, slotId)
		if itemType == ITEMTYPE_TROPHY and (sItemType == treasure or sItemType == survey) then 
			local itemName = zo_strformat(GetItemName(bagId, slotId)):match("^%s*(.-)%s*$")
			if sItemType == survey then
				table.insert(surveyNames, itemName)
			else
				table.insert(treasureNames, itemName)
			end
		end
	end	
	STW.surveyNames		= surveyNames
	STW.treasureNames	= treasureNames
	--df("buildSurveyNameList %d %d", #surveyNames, #treasureNames)
end

local function countInList(which, zoneName)
	-- <zonename> (CE)? Treasure Map (<roman>) | <type> Survey: <zonename> <roman>?
	-- special cases: Orsinium = Wrothgar, Alik'r = Alik'r Desert, Bleakrock = Bleakrock Isle
	local list
	if string.match(zoneName, "Alik'r") then zoneName = "Alik'r" 
	elseif string.match(zoneName, "Алик'р") then zoneName = "Алик'р" 
	elseif string.match(zoneName, "Wrothgar") and which == "t" then zoneName = "Orsinium"
	elseif string.match(zoneName, "Ротгар") and which == "t" then zoneName = "Орсиниум"
	elseif string.match(zoneName, "Bleakrock Isle") and which == "t" then zoneName = "Bleakrock"
	end
	if which == "s" then
		list = STW.surveyNames
	else
		list = STW.treasureNames
	end
	count = 0
	for index, name in pairs(list) do
		if string.match(name, zoneName) then count = count + 1 end
	end
	return count
end

local function GetLeadCountsInZones()
	local leadsLookup = {}
	local i = GetNextAntiquityId()
	while i do
		local havelead = DoesAntiquityHaveLead(i)
		if havelead then
			 local zoneId = GetAntiquityZoneId(i)
			 if zoneId then
				 local count = leadsLookup[zoneId]
				 if count then 
					leadsLookup[zoneId] = count + 1
				 else
					leadsLookup[zoneId] = 1
				 end
			 end
		end
		i = GetNextAntiquityId(i)
	end
	STW.leadsLookup = leadsLookup
end

local function getCountersFor(zoneId, zoneName)
	zoneName = FasterTravel.Utils.BareName(zoneName)
    local surveys = countInList("s", zoneName)
	local treasures = countInList("t", zoneName)
	local leads = STW.leadsLookup[zoneId] or 0
	local colors = FasterTravel.settings.colors
	local signs = FasterTravel.settings.signs
	-- df("getCountersFor %d %d %d", surveys, treasures, leads)
	local sign = (surveys > 0 and colors.surveys:Colorize(signs.surveys) or "") ..
	             (treasures > 0 and colors.treasures:Colorize(signs.treasures) or "") ..
	             (leads > 0 and colors.leads:Colorize(signs.leads) or "")
	return 	surveys > 0 and colors.surveys:Colorize(string.format(" %d", surveys)) or "",
			treasures > 0 and colors.treasures:Colorize(string.format(" %d", treasures)) or "",
			leads > 0 and colors.leads:Colorize(string.format(" %d", leads)) or "",
			sign
end

local function escapeZoneName(zoneName)
	zoneName = zoneName:gsub("^%A*", "")
	return zoneName
end

local function onSlotUpdate(eventCode, bagId, slotId, isNewItem)
	if bagId ~= BAG_BACKPACK then return end
	if isNewItem then 
		local itemType, sItemType = GetItemType(bagId, slotId)
		if itemType == ITEMTYPE_TROPHY and (sItemType == treasure or sItemType == survey) then 
			STW.buildSurveyNameList()
		end
	else
		STW.buildSurveyNameList() 
	end
end

STW.countInList = countInList
STW.GetLeadCountsInZones = GetLeadCountsInZones
STW.getCountersFor = getCountersFor
STW.buildSurveyNameList = buildSurveyNameList
STW.onSlotUpdate = onSlotUpdate

FasterTravel.SurveyTheWorld = STW
