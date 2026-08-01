--The constant for ALL SETS
local allSetsConstantId = 9999999999
--The itemIds of the craftable sets
local setIds = {
    [1] = allSetsConstantId,  -- All sets

    [2] = 49575,  -- Aschengriff
	[3] = 43805,  -- Todeswind
	[4] = 47279,  -- Stille der Nacht
	[5] = 43808,  -- Zwielicht
	[6] = 48042,  -- Verführung
	[7] = 43979,  -- Torugs Pakt
	[8] = 69942,  -- Prüfungen
	[9] = 51105,  -- Histrinde
	[10] = 47663,  -- Weißplanke
	[11] = 43849,  -- Magnus
	[12] = 48425,  -- Kuss des Vampirs
	[13] = 52243,  -- Lied der Lamien
	[14] = 52624,  -- Alessias Bollwerk
	[15] = 60280,  -- Adelssieg
	[16] = 71806,  -- Tavas Gunst
	[17] = 75406,  -- DB:Kwatch Gladiator
	[18] = 51486,  -- Weidenpfad
	[19] = 51864,  -- Hundings Zorn
	[20] = 49195,  -- Mutter der Nacht
	[21] = 69592,  -- Julianos
	[22] = 60630,  -- Umverteilung
	[23] = 72156,  -- Schlauer Alchemist
    [24] = 75756,  -- DB:Varen's Legacy
	[25] = 43968,  -- Erinnerung
	[26] = 43972,  -- Schemenauge
	[27] = 44053,  -- Augen von Mara
	[28] = 54149,  -- Shalidor's Fluch
	[29] = 53772,  -- Karegnas Hoffnung
	[30] = 53006,  -- Ogrumms Schuppen
	[31] = 54963,  -- Arena
	[32] = 58174,  -- Doppelstern
	[33] = 60980,  -- Rüstungsmeister
	[34] = 70642,  -- Morkuldin
	[35] = 72506,  -- Ewige Jagd
	[36] = 76106,  -- DB:Pelinal's Aptitude
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
    [tostring(allSetsConstantId)]      = GetString(AF_SNU_ALL_CRAFTED_SETS),
    ["SNUSetFiltersSubmenuCraftedSet"] = GetString(AF_SNU_CRAFTED_SETS),
}
getSetNames(stringsEN)

local stringsDE = {
    [tostring(allSetsConstantId)]      = GetString(AF_SNU_ALL_CRAFTED_SETS),
    ["SNUSetFiltersSubmenuCraftedSet"] = GetString(AF_SNU_CRAFTED_SETS),
}
getSetNames(stringsDE )

local stringsFR = {
    [tostring(allSetsConstantId)]      = GetString(AF_SNU_ALL_CRAFTED_SETS),
    ["SNUSetFiltersSubmenuCraftedSet"] = GetString(AF_SNU_CRAFTED_SETS),
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
	submenuName = "SNUSetFiltersSubmenuCraftedSet",
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
	submenuName = "SNUSetFiltersSubmenuCraftedSet",
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
	submenuName = "SNUSetFiltersSubmenuCraftedSet",
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
