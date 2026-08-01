local util = AdvancedFilters.util
local function GetFilterCallback(name)
	return function( slot , slotIndex)
		local surveyType = SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT	
		local surveyTextFilter = " Survey:"
		local isSurveyMatch = false

		if name ~= "All Surveys" then
			surveyTextFilter = name .. surveyTextFilter
		end

		--d(surveyTextFilter)

		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end

		--get the item link, name and check if it has the desired filter text
		local itemType, sItemType = GetItemType(slot.bagId, slot.slotIndex)

		if itemType == ITEMTYPE_TROPHY and (sItemType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT) then 
			if name == "All Surveys" then
				isSurveyMatch = true
			else
				local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
				local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
				--d(itemName)

				isSurveyMatch = itemName:find(surveyTextFilter, 1, true) == 1
			end
		end

		return isSurveyMatch
	end
end

local AFSurveyFilterCallBacks = {
	[1] = {name = "All Surveys", filterCallback = GetFilterCallback("All Surveys")},
	[2] = {name = "Alchemist", filterCallback = GetFilterCallback("Alchemist")},
	[3] = {name = "Blacksmith", filterCallback = GetFilterCallback("Blacksmith")},
	[4] = {name = "Clothier", filterCallback = GetFilterCallback("Clothier")},
	[5] = {name = "Enchanter", filterCallback = GetFilterCallback("Enchanter")},
	[6] = {name = "Jewelry", filterCallback = GetFilterCallback("Jewelry Crafting")},
	[7] = {name = "Woodworker", filterCallback = GetFilterCallback("Woodworker")},
}


local en = {
	["Survey Filter"] = "Survey Filter",
	["All Surveys"] = "All Surveys",
	["Alchemist"] = "Alchemist",
	["Blacksmith"] = "Blacksmith",
	["Clothier"] = "Clothier",
	["Enchanter"] = "Enchanter",
	["Jewelry"] = "Jewelry",
	["Woodworker"] = "Woodworker",
}


local filterInformation = {
	submenuName = "Survey Filter",
	callbackTable = AFSurveyFilterCallBacks,
	filterType = {ITEMFILTERTYPE_ALL, ITEMFILTERTYPE_MISCELLANEOUS,},
	subfilters = {"All",},
	onlyGroups = {"Miscellaneous", "All"},
	excludeSubfilters = {"Glyphs", "Soul Gem", "Siege", "Bait", "Tool", "Fence", "Vanity"},
	enStrings = en
}

AdvancedFilters_RegisterFilter(filterInformation)
