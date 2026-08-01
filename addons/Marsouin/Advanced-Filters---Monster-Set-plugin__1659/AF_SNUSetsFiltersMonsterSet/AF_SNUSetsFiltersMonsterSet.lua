--The constant for ALL SETS
local allSetsConstantId = 9999999999
--The itemIds of the craftable sets
local setIds = {
    [1] = allSetsConstantId,  -- All sets

    [2] = 76438,-- MawoftheInfernal	|H0:item:76438:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [3] = 76444,-- ValkynSkoria	|H0:item:76444:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [4] = 76450,-- Nerien'eth	|H0:item:76450:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [5] = 76456,-- EngineGuardian	|H0:item:76456:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [6] = 76462,-- Nightflame	|H0:item:76462:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [7] = 76468,-- SpawnofMephala	|H0:item:76468:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [8] = 76474,-- LordWarden	|H0:item:76474:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [9] = 76480,-- MolagKena	|H0:item:76480:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [10] = 76486,-- BloodSpawn	|H0:item:76486:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [11] = 76492,-- ScourgeHarvester	|H0:item:76492:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [12] = 82168,-- Velidreth	|H0:item:82168:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [13] = 82216,-- MightyChudan	|H0:item:82216:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [14] = 94739,-- Shadowrend	|H0:item:94739:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [15] = 94747,-- Kragh	|H0:item:94747:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [16] = 94755,-- SwarmMother	|H0:item:94755:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [17] = 94763,-- SentinelofRkugamz	|H0:item:94763:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [18] = 94771,-- Chokethorn	|H0:item:94771:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [19] = 94779,-- Slimecraw	|H0:item:94779:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [20] = 94787,-- Sellistrix	|H0:item:94787:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [21] = 94795,-- InfernalGuardian	|H0:item:94795:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [22] = 94803,-- Ilambris	|H0:item:94803:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [23] = 94811,-- Iceheart	|H0:item:94811:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [24] = 94819,-- Stormfist	|H0:item:94819:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [25] = 94827,-- Tremorscale	|H0:item:94827:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [26] = 94835,-- PirateSkeleton	|H0:item:94835:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [27] = 94843,-- TheTrollKing	|H0:item:94843:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [28] = 94851,-- Selene	|H0:item:94851:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
    [29] = 94859,-- Grothdarr	|H0:item:94859:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h
--Add new sets here
}
local setNames = {}
local setNamesWithId = {}
--Get the name of the sets
for _, setItemId in pairs(setIds) do
    local setName = ""
    --All entries except the ALL SETS entry
    if setItemId ~= allSetsConstantId then
        local link = '|H1:item:'..setItemId..':30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h'
        local _,setNameLocal, _, _, _ = GetItemLinkSetInfo(link, false)
        setName = setNameLocal
    else
        setName = "--ALL--"
    end
    --Build the setNames table with the Ids for the comparison
    setNamesWithId[setItemId] = setName
    if setItemId ~= allSetsConstantId then
        --Remove gender stuff from the set name
        setName = zo_strformat("<<C:1>>", setName)
    end
    --Put the id and name as a table in the table "setNames". This way setNames can be sorted
    --The string contains the setItemId, a divider "::" and the setname
    table.insert(setNames, setName .. "::" .. tostring(setItemId))
end
table.sort(setNames)

local function GetFilterCallbackForSets( setId )
	return function( slot )
        local setFound = false
        --get the item link
        local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
        --Get the set item information
        local _, setName, _, _, _ = GetItemLinkSetInfo(itemLink)
        if setName == nil or setName == "" then return false end

        --Check for all sets?
		if setId == allSetsConstantId then
            for eachSetId, eachSetName in pairs(setNamesWithId) do
                setFound = (string.find(setName, eachSetName)) or false
                if setFound then return true end
            end

        --Only check one specific set
        else
            setFound = (string.find(setName, setNamesWithId[setId])) or false
        end
        return setFound
	end
end

local fullLevelDropdownSetsCallbacks = {}
--Get the name of the sets
for _, setString in ipairs(setNames) do
    --Split the set string by the "::"
    local setName, setIdStr = zo_strsplit("::", setString)
    local setItemId = tonumber(setIdStr)
    local link = '|H1:item:'..setItemId..':30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h'
	table.insert(fullLevelDropdownSetsCallbacks, { name = tostring(setItemId), filterCallback = GetFilterCallbackForSets( setItemId ) } )
end

--Loop over the standard set names and add them to the returnTable
local function getSetNames(returnTable)
	if returnTable == nil then return end
    --Build the set names without gender specific strings
    for setItemId, setName in pairs(setNamesWithId) do
        --Check if entry with setId already exists (e.g. the entry with the "allSetsConstantId" ID) and don't overwrite it
        if returnTable[tostring(setItemId)] == nil then
            --Remove gender stuff from the set name
            setName = zo_strformat("<<C:1>>", setName)
            returnTable[tostring(setItemId)] = setName
        end
    end
end
 
local stringsEN = {
    [tostring(allSetsConstantId)]      = GetString(AF_SNU_ALL_MONSTRE_SETS),
    ["SNUSetFiltersSubmenuMonsterSet"] = GetString(AF_SNU_MONSTRE_SETS),
}
getSetNames(stringsEN)

local stringsDE = {
    [tostring(allSetsConstantId)]      = GetString(AF_SNU_ALL_MONSTRE_SETS),
    ["SNUSetFiltersSubmenuMonsterSet"] = GetString(AF_SNU_MONSTRE_SETS),
}
getSetNames(stringsDE )

local stringsFR = {
    [tostring(allSetsConstantId)]      = GetString(AF_SNU_ALL_MONSTRE_SETS),
    ["SNUSetFiltersSubmenuMonsterSet"] = GetString(AF_SNU_MONSTRE_SETS),
}
getSetNames(stringsFR )


--[[
	This section packages the data for Advanced Filters to use.
	All keys are required except for deStrings, frStrings, and ruStrings, as they correspond to
		optional languages. Al language keys are assigned the same table here only to demonstrate
		the key names. You do not need to do this.
	The filterType key expects an ITEMFILTERTYPE constant provided by the game.
	The values for key/value pairs in subfilters can be any of the string keys from lines 127 - 218
		of AdvancedFiltersData.lua (AF_Callbacks table) such as "All", "OneHanded", "Body", or
		"Blacksmithing".
	If your filterType is ITEMFILTERTYPE_ALL then subfilters must only contain the value "All".
  ]]

--[[
  	If you want your filters to show up under more than one main filter, redefine filterInformation
  	to include the new filterType. The shorthand version (not including optional languages) is shown here.
  ]]
local filterInformation = {
	submenuName = "SNUSetFiltersSubmenuMonsterSet",
	callbackTable = fullLevelDropdownSetsCallbacks,
	filterType = ITEMFILTERTYPE_WEAPONS,
    subfilters = {"All",},
	enStrings = stringsEN,
	frStrings = stringsFR,
	deStrings = stringsDE,
}

--[[
	Again, register your filters by passing your new filter information to this function.
  ]]
AdvancedFilters_RegisterFilter(filterInformation)

local filterInformation = {
	submenuName = "SNUSetFiltersSubmenuMonsterSet",
	callbackTable = fullLevelDropdownSetsCallbacks,
	filterType = ITEMFILTERTYPE_ARMOR,
    subfilters = {"All",},
	enStrings = stringsEN,
	frStrings = stringsFR,
	deStrings = stringsDE,
}
--[[
	Again, register your filters by passing your new filter information to this function.
  ]]
AdvancedFilters_RegisterFilter(filterInformation)

local filterInformation = {
	submenuName = "SNUSetFiltersSubmenuMonsterSet",
	callbackTable = fullLevelDropdownSetsCallbacks,
	filterType = ITEMFILTERTYPE_ALL,
    subfilters = {"All",},
	enStrings = stringsEN,
	frStrings = stringsFR,
	deStrings = stringsDE,
}
--[[
	Again, register your filters by passing your new filter information to this function.
  ]]
AdvancedFilters_RegisterFilter(filterInformation)
