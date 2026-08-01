local addonPluginName = "AF_FCOCraftedSetFilters"
local function addOnPluginLoaded(event, name)
	if name ~= addonPluginName then return end
	--Unregister the filter plugin's EVENT_ADD_ON_LOADED after the plugin was loaded
	EVENT_MANAGER:UnregisterForEvent(addonPluginName, EVENT_ADD_ON_LOADED)

	--Check if library LibSets is loaded
	local libSets = LibSets
	if libSets == nil or libSets.AreSetsLoaded == nil then return end
	local libSets_GetSetName = libSets.GetSetName


	--Load the sets data
	if libSets and (not libSets.AreSetsLoaded() or libSets.craftedSets == nil) then
		libSets.LoadSets(true, addonPluginName)
		--return
	end
	local pluginName = "AF_FCOCraftedSets"

	--The constant for ALL SETS
	local allSetsConstantName 	= pluginName .. "--ALL_CRAFTED_SETS--"
	local allSetsConstantId 	= 9999999999

	--Build the setIds via LibSets
	local craftableSetIds = {}
	ZO_ShallowTableCopy(libSets.craftedSets, craftableSetIds)
	local setNamesWithId = {}
	local setNamesSorted = {}

	--AdvancedFilters utility functions
	local util = AdvancedFilters.util
	--Prepare the slot of the filter function to support crafting table inventory slots
	local util_PrepareSlot = util.prepareSlot


	--Get 1st cahracter of an UTF-8 string
	--From: https://stackoverflow.com/questions/13235091/extract-the-first-letter-of-a-utf-8-string-with-lua
	local function getFirstLetter(str)
		--Both below to not work, only start at the 2nd character and stripping the first char if it's an Umlaut Ä e.g.
		--return str:match("[%z\1-\127\194-\244][\128-\191]*")
		--return str:match(utf8.charpattern)
		--This works and returns the Ä
		--/tb local str = "Ätherisches Archiv" d(string.sub(str, 1, utf8.offset(str, 2) - 1))
		return string.sub(str, 1, utf8.offset(str, 2) - 1)
	end

	--/script local str = "Ätherisches Archiv" for code in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do print(code) end

------------------------------------------------------------------------------------------------------------------------
	--Get the names of the crafted sets
	for setId, _  in pairs(craftableSetIds) do
		local setName = libSets_GetSetName(setId)
		if setName and setName ~= "" then
			--Remove gender stuff from the set name
			setName = zo_strformat("<<C:1>>", setName)
			setNamesSorted[#setNamesSorted+1] = setName
			setNamesWithId[setName] = setId
		end
	end
	setNamesWithId[allSetsConstantName] = allSetsConstantId
	setNamesSorted[#setNamesSorted+1] = allSetsConstantName
	table.sort(setNamesSorted)


------------------------------------------------------------------------------------------------------------------------
	--Filter callback function for each entry in the filterPlugin. The item will be checked if it's a set and compared to the setId
	local function GetFilterCallbackForSets( setId, startingCharacter )
		--Do not forget the return here, else filter function won't work! Parameters of the filterFunction must be slot, slotIndex, where slot will either be a crafting inventory slot,
		--having the bagId in it's data (and read via AF.util.prepareSlot) or it will be the bagId directly (normal inventories)
		--filterFunction returns true if the filter matches (show item) or false if it does not match (hide item)
		return function( slot , slotIndex )
			if util_PrepareSlot ~= nil then
				if slotIndex ~= nil and type(slot) ~= "table" then
					slot = util_PrepareSlot(slot, slotIndex)
				end
			end

			local setFound = false
			--get the item link
			local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
			--Get the set item information
			local hasSet, _, _, _, _, setIdToCompareTo = GetItemLinkSetInfo(itemLink)
			--No set or no setId -> Send false to say "filter"
			if not hasSet or setIdToCompareTo == nil or setIdToCompareTo == 0 then return false end

			--Check for the "all sets" filter
			if setId == allSetsConstantId then
				for setIdToCompareToLoop, _ in pairs(craftableSetIds) do
					if setIdToCompareTo == setIdToCompareToLoop then return true end
					setFound = false
				end
			--Only check one specific set
			else
				setFound = (setIdToCompareTo == setId) or false
			end
			return setFound
		end
	end


------------------------------------------------------------------------------------------------------------------------
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
	--[[
		--Sorted list of set names in the dropdown!
		Add nested submenus for each 1st character (e.g. "A", "B", "C" etc.) in the nested submenus (see filterInformation[submenuName].callbackTable.nestedSubmenuEntries)
		of submenu pluginName .. "_SetNamesCrafted" (see filterInformation.submenuName).
		E.g. Submenu "Crafted sets" -> "A" -> { Set sarting with A 1, Set starting with A 2, ... }, -> "B" -> { Set sarting with B 1, Set starting with B 2, ... }, ...
		strings added to the stringsEN, stringsDE etc. language tables will be added to AdvancedFilters.Strings table. They need to be unique -> game wide! AF uses some kind of prefix to try to make them unique
		but better use some string names starting with your addon/plugin name so they are really unique game wide!
		Strings of main plugin dropdown menus, submenus r even nestedSubmenus (submenus in submenus) will all be on the same layer of the AF.Strings table entries!
	]]
	local stringsEN = {
		[allSetsConstantName]      						= "-All crafted sets-",
		[pluginName.."_SetNamesCrafted"]				= "Crafted sets",
		[pluginName.."_SetFiltersSubmenuCraftedSet"] 	= "Sets - crafted",
	}
	--Add the set names in logged in client language to th Strings table EN, where they will be read from the other stringsDE, FR tables via metatable trick then
	getSetNames(stringsEN)


------------------------------------------------------------------------------------------------------------------------
	local setNamesFilterPluginData = {
		--Add the "All crafted sets" entry first
		{ name = allSetsConstantName, filterCallback = GetFilterCallbackForSets( allSetsConstantId, nil ) }
		--After that: Add nested submenus, 1 each for the 1st character of the setnames -> See setNamesSubmenusAdded
	}

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
				setNamesSubmenusAdded[firstChar][#setNamesSubmenusAdded[firstChar]+1] = { name = pluginName.."_"..setName, filterCallback = GetFilterCallbackForSets( setId, firstChar ) }
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
	--German strings
	local stringsDE = {
		[allSetsConstantName]      						= "-Alle Handwerk Sets-",
		[pluginName .."_SetNamesCrafted"]				= "Handwerk Sets",
		[pluginName .. "_SetFiltersSubmenuCraftedSet"] 	= "Sets - Handwerk",
	}
	--Take missing indices from enStrings
	setmetatable(stringsDE, {__index = stringsEN})

	--French strings
	local stringsFR = {
		[allSetsConstantName]      						= "-Tous les sets fabriqués-",
		[pluginName.."_SetNamesCrafted"]				= "Sets fabriqués",
		[pluginName.."_SetFiltersSubmenuCraftedSet"]	= "Sets - fabriqués",
	}
	--Take missing indices from enStrings
	setmetatable(stringsFR, {__index = stringsEN})




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
		submenuName = pluginName.."_SetNamesCrafted",
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
	filterInformation.submenuName = pluginName.."_SetNamesCrafted"
	filterInformation.callbackTable = setNamesFilterPluginData
	filterInformation.filterType = ITEMFILTERTYPE_ALL
	filterInformation.onlyGroups = {"Body"}
	--Register the same filter again at the ALL inventory tab
	AdvancedFilters_RegisterFilter(filterInformation)
end

------------------------------------------------------------------------------------------------------------------------
--Make sure the filter plugin loads after dependencies , here LibSets
EVENT_MANAGER:RegisterForEvent(addonPluginName .. "_Loaded", EVENT_ADD_ON_LOADED, addOnPluginLoaded)

