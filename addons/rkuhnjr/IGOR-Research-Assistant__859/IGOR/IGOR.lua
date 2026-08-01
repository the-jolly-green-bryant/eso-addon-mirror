-- IGOR Addon for Elder Scrolls Online
-- Author: Cristo (rkuhnjr)
-- All rights reserved

IGOR = {
	 name = "IGOR"
	,version = "0.1a"
	,initialised = false
	,showLogs = true
	,crafts = {}
	,traits = {}
	,defaults = {
		avatars	= {}
	}
}

local next = next 

function OnAddOnLoaded(eventCode, addOnName)
	if (IGOR.name ~= addOnName) then return end
	
	IGOR.crafts[CRAFTING_TYPE_BLACKSMITHING]   = "Blacksmithing"
	IGOR.crafts[CRAFTING_TYPE_CLOTHIER]        = "Clothing"
	IGOR.crafts[CRAFTING_TYPE_WOODWORKING]     = "Woodworking"
	
    IGOR.traits[ITEM_TRAIT_TYPE_WEAPON_POWERED] = "Powered"
    IGOR.traits[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = "Charged"
    IGOR.traits[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = "Precise"
    IGOR.traits[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = "Infused"
    IGOR.traits[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = "Defending"
    IGOR.traits[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = "Training"
    IGOR.traits[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = "Sharpened"
    IGOR.traits[ITEM_TRAIT_TYPE_WEAPON_WEIGHTED] = "Weighted"
    IGOR.traits[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = "Nirnhoned"
    IGOR.traits[ITEM_TRAIT_TYPE_ARMOR_STURDY] = "Sturdy"
    IGOR.traits[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = "Impenetrable"
    IGOR.traits[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = "Reinforced"
    IGOR.traits[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = "Well Fitted"
    IGOR.traits[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = "Training"
    IGOR.traits[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = "Infused"
    IGOR.traits[ITEM_TRAIT_TYPE_ARMOR_EXPLORATION] = "Exploration"
    IGOR.traits[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = "Divines"
    IGOR.traits[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = "Nirnhoned"
	
	
	IGOR.vars = ZO_SavedVars:NewAccountWide("IGOR_ResearchTimers", 1, nil, IGOR.defaults)
	
	IGOR.UpdateCurrentAvatar()
	
	IGOR.initialised = true
end 

function OnResearchEvent(eventCode, craftingSkillType, researchLineIndex, traitIndex)
	if (not IGOR.initialised) then return end
	IGOR.UpdateCurrentAvatar()
end

EVENT_MANAGER:RegisterForEvent(IGOR.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(IGOR.name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED , OnResearchEvent)
EVENT_MANAGER:RegisterForEvent(IGOR.name, EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, OnResearchEvent)

function cli(params)
	if (not IGOR.initialised) then
		err("Not initialised")
	elseif(params == "g") then
		IGOR.UpdateCurrentAvatar()
	elseif (params == "d" or params == "display") then
		IGOR.ListCurrentTimers()
	elseif (params == "da" or params == "displayall") then
		IGOR.ListAllTimers()
	else
		d("|c00FF00" .. IGOR.name .. "|r v" .. IGOR.version)
		d("g, get  : Force Update")
		d("d, display : Show Researches for active Avatar ")
		d("da, displayall : Show Researches for all loaded Avatars ")
	end
end
 
SLASH_COMMANDS["/igor"] = cli

function err(msg)
	d("|cFF0000IGOR ERR:|r " .. msg)
end

function igorLog(msg)
	if (IGOR.showLogs) then
		d("|c00FF00IGOR Log: " .. msg .. "|r")
	end
end

function IGOR.UpdateCurrentAvatar()
	igorLog("Updating avatar")
	
	if (IGOR.vars.avatars[GetUnitName("player")] ~= nil) then 
		IGOR.vars.avatars[GetUnitName("player")] = nil
	end
	
	local activeResearches = IGOR.GetAllTimers()
	
	if (activeResearches ~= nil) then
		IGOR.vars.avatars[GetUnitName("player")] = activeResearches
	end
end

function IGOR.GetAllTimers()
	local activeResearches = {}
	for k, v in pairs(IGOR.crafts) do
		local tR = IGOR.GetResearchTimer(k)
		for x,y in pairs(tR) do activeResearches[x] = y end
	end
	
	return activeResearches
end

--This block of code borrowed from AI research grid
-- Author: Stormknight/LCAmethyst
function IGOR.GetResearchTimer(thisCraft)
    local i, j
    local tType, tKnown, tRemain, tSlot
    local maxLines = GetNumSmithingResearchLines(thisCraft)     -- the number of columns for this profession
    local craftResearches = {}  -- create a table for this profession
    -- Cycle through items for this profession
    for i = 1, maxLines do
		tSlot,_,numTraits = GetSmithingResearchLineInfo(thisCraft, i) 
        for j = 1, numTraits do
            tType,_,tKnown = GetSmithingResearchLineTraitInfo(thisCraft,i,j)
			duration, tRemain = GetSmithingResearchLineTraitTimes(thisCraft, i, j)
			
            if (not tKnown and duration ~= nil and tRemain ~= nil) then
				completionTime = GetTimeStamp() + tRemain
				local thisResearch = {Craft = IGOR.crafts[thisCraft], Slot = tSlot, Trait = IGOR.traits[tType], CompleteDate = completionTime}
				craftResearches[thisResearch.Craft .. "_" .. thisResearch.Slot] = thisResearch
			end
        end
    end
    return craftResearches 
end 

function IGOR.ListCurrentTimers()
	d("Active Researches for " .. GetUnitName("player"))
	
	local a = IGOR.vars.avatars[GetUnitName("player")]
	
	if (a == nil) then
		d("No researches found")
	else	
		for x, y in pairs(a) do
		  local timeLeft = GetDiffBetweenTimeStamps(y.CompleteDate, GetTimeStamp()) 
		  local hrTimeLeft = FormatTimeSeconds(timeLeft, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR, TIME_FORMAT_DIRECTION_NONE)
		  local completeClockTime = FormatTimeSeconds(GetSecondsSinceMidnight() + timeLeft, TIME_FORMAT_STYLE_CLOCK_TIME,  TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR, TIME_FORMAT_DIRECTION_NONE)
		  d("--[" .. y.Craft .. "] " .. y.Trait .. " " .. y.Slot .. " : " .. hrTimeLeft .. " on " .. GetDateStringFromTimestamp(y.CompleteDate) .. " " .. completeClockTime)
		end
	end
end

function IGOR.ListAllTimers()
	if (IGOR.vars.avatars == nil or next(IGOR.vars.avatars) == nil) then
		err("No avatars loaded")
	else
		for k, v in pairs(IGOR.vars.avatars) do
			d("Active Researches for " .. k)
			for x, y in pairs(IGOR.vars.avatars[k]) do
			  local timeLeft = GetDiffBetweenTimeStamps(y.CompleteDate, GetTimeStamp()) 
			  local hrTimeLeft = FormatTimeSeconds(timeLeft, TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR, TIME_FORMAT_DIRECTION_NONE)
			  local completeClockTime = FormatTimeSeconds(GetSecondsSinceMidnight() + timeLeft, TIME_FORMAT_STYLE_CLOCK_TIME,  TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR, TIME_FORMAT_DIRECTION_NONE)
			  d("--[" .. y.Craft .. "] " .. y.Trait .. " " .. y.Slot .. " : " .. hrTimeLeft .. " on " .. GetDateStringFromTimestamp(y.CompleteDate) .. " " .. completeClockTime)
			end
		end
	end
end


