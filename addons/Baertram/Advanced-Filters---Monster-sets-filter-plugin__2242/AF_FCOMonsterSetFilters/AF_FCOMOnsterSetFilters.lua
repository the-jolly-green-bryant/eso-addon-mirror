--AdvancedFilters check
local AF = AdvancedFilters
local util = AF.util
if not AF or not util then return end
local util_prepareSlot = util.prepareSlot

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--LibSets check
local libSets = LibSets
if not libSets then return end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Constant
local pluginName          = "AF_FCOMonsterSetFilters"

--Constants for ALL SETS
local allSetsConstantName 	= pluginName.."--ALL_MONSTER_SETS--"
local allSetsConstantId 	= 9999999999
local submenuSetsConstantName = pluginName .. "_SetFiltersSubmenuMonsterSet"

local setNamesWithId = {}
local setNamesSorted = {}

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Global (for debugging)
--[[
AF_FCOMonsterSetFilters = {
	name = pluginName,
	version = "0.0.9",
	allSetsConstantId = allSetsConstantId,
	allSetsConstantName = allSetsConstantName,
	setNamesWithId = setNamesWithId,
	setNamesSorted = setNamesSorted,
}
]]

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--local pointers to ZOs
local EM 			= EVENT_MANAGER
local stc 			= ZO_ShallowTableCopy
local strform 		= ZO_CachedStrFormat
local strsub		= string.sub
local utf8off 		= utf8.offset
local gisi 			= GetItemLinkSetInfo
local gi 			= GetItemLink
local tinsert		= table.insert
local tsort			= table.sort


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--local pointers to LibSets
local libSets_areSetsLoaded = libSets.AreSetsLoaded
local libSets_getSetName    = libSets.GetSetName


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
--Get 1st cahracter of an UTF-8 string
--From: https://stackoverflow.com/questions/13235091/extract-the-first-letter-of-a-utf-8-string-with-lua
local function getFirstLetter(str)
	--Both below to not work, only start at the 2nd character and stripping the first char if it's an Umlaut Ä e.g.
	--return str:match("[%z\1-\127\194-\244][\128-\191]*")
	--return str:match(utf8.charpattern)
	--This works and returns the Ä
	--/tb local str = "Ätherisches Archiv" d(string.sub(str, 1, utf8.offset(str, 2) - 1))
	return strsub(str, 1, utf8off(str, 2) - 1)
end

--/script local str = "Ätherisches Archiv" for code in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do print(code) end

--Loop over the standard set names and add them to the "returnTable" (here enStrings -> So each setName will be in the AF Strings tbale later on)
local function getSetNames(returnTable)
	if returnTable == nil then return end
	--Build the set names without gender specific strings
	for setName, setId in pairs(setNamesWithId) do
		if setId ~= allSetsConstantId then
			--Check if entry with setId already exists (e.g. the entry with the "allSetsConstantId" ID) and don't overwrite it
			if returnTable[pluginName.."_"..setName] == nil then
				returnTable[pluginName.."_"..setName] = setName
			end
		end
	end
end
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------


--Addon plugin load function
local function addOnPluginLoaded(event, name)
	if name ~= pluginName then return end
	EM:UnregisterForEvent(pluginName, EVENT_ADD_ON_LOADED)

------------------------------------------------------------------------------------------------------------------------
	--Check if library LibSets is loaded and load the sets data if missing yet
	if not libSets_areSetsLoaded() or libSets.monsterSets == nil then
		libSets.LoadSets(true, pluginName)
		if not libSets_areSetsLoaded() or libSets.monsterSets == nil then
			d("[AdvancedFilters plugin: \'".. pluginName .. "\']ERROR - Missing LibSets sets data!")
			return
		end
	end


------------------------------------------------------------------------------------------------------------------------
	--Build the setIds via LibSets
	local monsterSetIds = {}
	stc(libSets.monsterSets, monsterSetIds)
	setNamesWithId = {}
	setNamesSorted = {}
	--Get the name of the sets
	for setId, _  in pairs(monsterSetIds) do
		local setName = ""
		--All entries except the ALL SETS entry
		setName = libSets_getSetName(setId)
		--Remove gender stuff from the set name
		setName = strform("<<C:1>>", setName)
		setNamesWithId[setName] = setId
		--Put the id and name as a table in the table "setNames". This way setNames can be sorted
		tinsert(setNamesSorted, setName)
	end
	setNamesWithId[allSetsConstantName] = allSetsConstantId
	tinsert(setNamesSorted, allSetsConstantName)
	tsort(setNamesSorted)


------------------------------------------------------------------------------------------------------------------------
	local function GetFilterCallbackForSets( setId )
		return function( slot , slotIndex)
			if util_prepareSlot ~= nil then
				if slotIndex ~= nil and type(slot) ~= "table" then
					slot = util_prepareSlot(slot, slotIndex)
				end
			end
			local setFound = false
			--get the item link
			local itemLink = gi(slot.bagId, slot.slotIndex)
			--Get the set item information
			local hasSet, _, _, _, _, setIdToCompareTo = gisi(itemLink)
			if not hasSet or setIdToCompareTo == nil or setIdToCompareTo == 0 then return false end
			--Check for all sets?
			if setId == allSetsConstantId then
				for setIdToCompareToLoop, _ in pairs(monsterSetIds) do
					setFound = (setIdToCompareTo == setIdToCompareToLoop) or false
					if setFound then return true end
				end
				--Only check one specific set
			else
				setFound = (setIdToCompareTo == setId) or false
			end
			return setFound
		end
	end


------------------------------------------------------------------------------------------------------------------------
	local stringsEN = {
		[allSetsConstantName]      = "-All monster sets-",
		[submenuSetsConstantName] 	= "Sets - Monsters"
	}
	--Add the set names in logged in client language to th Strings table EN, where they will be read from the other stringsDE, FR tables via metatable trick then
	getSetNames(stringsEN)


	local stringsDE = {
		[allSetsConstantName]      = "-Alle Monster Sets-",
		[submenuSetsConstantName] 	= "Sets - Monster"
	}
	setmetatable(stringsDE, {__index = stringsEN})
	local stringsFR = {
		[allSetsConstantName]      = "-Tous les set des monstres-",
		[submenuSetsConstantName] 	= "Sets - Monstres"
	}
	setmetatable(stringsFR, {__index = stringsEN})
------------------------------------------------------------------------------------------------------------------------


	--Add the 1 submenu containing all monster set names, as nested submenu 1 for each 1st letter of a monster set name
	local setNamesFilterPluginData = {
		--Add the "All moster sets" entry first
		{ name = allSetsConstantName, filterCallback = GetFilterCallbackForSets( allSetsConstantId ) }
		--After that: Add nested submenus, 1 each for the 1st character of the setnames -> See setNamesSubmenusAdded
	}

------------------------------------------------------------------------------------------------------------------------
	--Build the submenus for each 1st character of a setname
	local setNamesSubmenusAdded = {}
	for _, setName in ipairs(setNamesSorted) do
		local setId = setNamesWithId[setName]
		if setId ~= nil and setId ~= allSetsConstantId then
			local firstChar = getFirstLetter(setName)  --Does not work with UTF-8 strings >> string.sub(setName, 1, 1)
			if firstChar ~= nil and firstChar ~= "" then
				if setNamesSubmenusAdded[firstChar] == nil then
--d(">SetName: " ..tostring(setName) .. ", 1stChar: " ..tostring(firstChar))
					setNamesSubmenusAdded[firstChar] = {}
				end
				setNamesSubmenusAdded[firstChar][#setNamesSubmenusAdded[firstChar]+1] = { name = pluginName.."_"..setName, filterCallback = GetFilterCallbackForSets( setId ) }
			end
		end
	end

	--Loop the build submenu data and add them as entry to the filter callbackTable "setNamesFilterPluginData"
	for alphabetCharacter, setNamesOfAlphabetCharacters in pairs(setNamesSubmenusAdded) do
		local uppperCaseFirstChar = string.upper(alphabetCharacter)
		--add the 1st character of the set name to the Strings
		stringsEN[pluginName..uppperCaseFirstChar] = uppperCaseFirstChar
		--add the sets of the 1st character as nested submenu, using the "nestedSubmenuEntries" table
		table.insert(setNamesFilterPluginData, { name = pluginName..uppperCaseFirstChar, nestedSubmenuEntries = setNamesOfAlphabetCharacters } )
	end
	table.sort(setNamesFilterPluginData, function(a, b) return a.name < b.name  end)



------------------------------------------------------------------------------------------------------------------------
	--[[
		This section packages the data for Advanced Filters to use.
		A table filterInformation will be passed on to the API function AdvancedFilters_RegisterFilter.

		-submenuName is an optional String used for a submenu to show. If it's left nil there won't be used any submenu and the dropdown box will directly add the filters.
		If submenuName is provided the String used must be in teh enStrings language table with the same String too!

		-callbackTable is a mandatory table containing all the callback functions run for each of the dropdown filters, submenu filters or even nestedSubmenuEntries filters.
		Each direct filter entry must be of the type { name = StringFor_enStrings, filterCallback = filterCallbackFunction, ... }
		Each nestedSubmenuEntry (only working if you also specify a submenuName in the filterInformation) must contain { name = StringForTheNestedSubmenuOpener_enStrings, nestedSubmenuEntries = tableOfFilterCallbackFunctionsForEachNestedSubmenueEntry }

		-The filterType is mandatory and can be a single value or a table with several vales. The values expect an ITEMFILTERTYPE constant provided by the game, or by AdvancedFilters
		(e.g. ITEMFILTERTYPE_ARMOR, ITEMFILTERTYPE_AF_RETRAIT_ARMOR) -> See AdvancedFilters -> Constants.lua -> Table filterTypeNames

		-subFilters is an optional table that controls on which subfilters the filters should be shown.
		The values for subfilters can be any of the string values in AdcancedFilters -> Constants.lua -> table "subfilterButtonNames". For example
			"Blacksmithing", "HealStaff", "LightArmor", "RawMaterialSmithing" ...
		If your filterType is ITEMFILTERTYPE_ALL then subfilters must only contain the value "All".

		-onlyGroups is an optioal table containing the subfilterGroups of AdvancedFilters where the filter plugin should "only show" the filters.
		The values for onlyGroups can be any of the string values in AdcancedFilters -> Constants.lua -> table "filterTypeNames". For example
		"Weapons", "Armor", "Jewelry", "JewelryCraftingStation", "JewelryRetrait", "Junk", ...

		-excludeFilterPanels is an optional table containing the LibFilters filterPanelIds (for example LF_ENCHANTING_CREATION, LF_INVENTORY) which should be excluded.
		The filter dropdown won't show the entries of this plugin at these specified panels.

		-enStrings is a mandatory table to fill with the strings for the submenuName, the entries of the dropdown filters and optional nestedSubmeuEntries.
		deStrings, frStrings, ruStrings, esStrings and zhStrings are optional as they correspond to	optional languages.
		In this example the strings missing in the other languages get copied from the enStrings table via metatables!
		If a language table is missing (e.g. esStrings) it will be completely used from the mandatory enStrings table.

		-Special "subfilters" and "onlyGroups" entries:
		Some special entries exist which combine several of the filterTyes/-Groups into 1 string.
		See AdcancedFilters -> Constants.lua -> table "subfilterButtonEntriesNotForDropdownCallback". For example
		{"Clothing", "LightArmor", "Medium", "Heavy"} -> relate to the single entry "Body"

		-Optional generator: Add a function which returns the generated callbackTable and strings.
		 callbackTable must be a table like described above. Strings must be a table containing the string key "enStrings" at least (mandatory) and optionally any other language table key as string
		 e.g. "deStrings", "esStrings", ...
		 Example: generator = function() ... return callbackTable, stringsTable end
	  ]]

	local filterInformation = {
		submenuName = submenuSetsConstantName,
		callbackTable = setNamesFilterPluginData,
		filterType = {	ITEMFILTERTYPE_ARMOR, ITEMFILTERTYPE_WEAPONS,
						ITEMFILTERTYPE_AF_ARMOR_SMITHING, ITEMFILTERTYPE_AF_WEAPONS_SMITHING,
						ITEMFILTERTYPE_AF_ARMOR_WOODWORKING, ITEMFILTERTYPE_AF_WEAPONS_WOODWORKING,
						ITEMFILTERTYPE_AF_ARMOR_CLOTHIER,
						ITEMFILTERTYPE_AF_RETRAIT_ARMOR, ITEMFILTERTYPE_AF_RETRAIT_WEAPONS, ITEMFILTERTYPE_AF_RETRAIT_JEWELRY,
						ITEMFILTERTYPE_AF_JEWELRY_CRAFTING,
						ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL,
						ITEMFILTERTYPE_AF_UNIVERSAL_DECON_WEAPONS,
						ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ARMOR,
						ITEMFILTERTYPE_AF_UNIVERSAL_DECON_JEWELRY,
		},
		subfilters = {"All",},
		excludeFilterPanels = {
			LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
			LF_SMITHING_REFINE,
			LF_JEWELRY_REFINE,
			LF_ALCHEMY_CREATION,
			LF_CRAFTBAG,
			LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
			LF_QUICKSLOT
		},
		enStrings = stringsEN,
		deStrings = stringsDE,
		frStrings = stringsFR,
		--esStrings = stringsEN,
		--ruStrings = stringsEN,
		--zhStrings = stringsEN,
	}
	AdvancedFilters_RegisterFilter(filterInformation)


	--[[
		If you want your filters to show up under more than one main filter, redefine filterInformation
		to include the new filterType. The shorthand version (not including optional languages) is shown here.
	  ]]
	--Add filter to ALL itemtypes, which are body parts
	filterInformation.submenuName = submenuSetsConstantName
	filterInformation.callbackTable = setNamesFilterPluginData
	filterInformation.filterType = ITEMFILTERTYPE_ALL
	filterInformation.onlyGroups = {"Body"}
	--Register the same filter again at the ALL inventory tab
	AdvancedFilters_RegisterFilter(filterInformation)


end

EM:RegisterForEvent(pluginName .. "_Loaded", EVENT_ADD_ON_LOADED, addOnPluginLoaded)
