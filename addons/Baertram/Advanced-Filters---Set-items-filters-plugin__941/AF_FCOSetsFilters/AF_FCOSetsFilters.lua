local pluginPrefix = "FCOSetFilters"

local util = AdvancedFilters.util
local util_PrepareSlot = util.prepareSlot
--[[
	This function handles the actual filtering. Use whatever parameters for "GetFilterCallback..."
    and whatever logic you need to in "function( slot )". A return value of true means the item in
    question will be shown while the filter is active.
  ]]


local function GetFilterCallbackForSets( isASet, setBonuses, equalsBonus )
	equalsBonus = equalsBonus or false

	return function( slot , slotIndex)
		if util_PrepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util_PrepareSlot(slot, slotIndex)
			end
		end
		--get the item link
        local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
        --Get the set item information
        local hasSet, _, numBonuses, _, _ = GetItemLinkSetInfo(itemLink)

        --local itemName = GetItemLinkName(itemLink)
        if hasSet == nil then return true end

        --Is a set?
        if isASet == true then
	        --Is a set and got set bonuses?
	        if setBonuses ~= nil then
	        	if not equalsBonus then
                	return numBonuses >= setBonuses
                else
               		return numBonuses == setBonuses
                end
	        end
        	return hasSet
        else
        	if not hasSet then return true end
        end
   		return false
	end
end

--[[
	This table is processed within Advanced Filters and its contents are added to Advanced Filters'
    callback table. The string value for name is the relevant key for the language table.
  ]]
local fullLevelDropdownSetsCallbacks = {
	[1] = { name = pluginPrefix.."isnoset", filterCallback   	  			= GetFilterCallbackForSets(false, nil, false) },
	[2] = { name = pluginPrefix.."isset", filterCallback  	  			= GetFilterCallbackForSets(true, nil, false) },
	[3] = { name = pluginPrefix.."issetwith1bonus", filterCallback    	= GetFilterCallbackForSets(true, 1, false) },
	[4] = { name = pluginPrefix.."issetwithonly1bonus", filterCallback    = GetFilterCallbackForSets(true, 1, true) },
	[5] = { name = pluginPrefix.."issetwith2bonus", filterCallback    	= GetFilterCallbackForSets(true, 2, false) },
	[6] = { name = pluginPrefix.."issetwithonly2bonus", filterCallback    = GetFilterCallbackForSets(true, 2, true) },
	[7] = { name = pluginPrefix.."issetwith3bonus", filterCallback  		= GetFilterCallbackForSets(true, 3, false) },
	[8] = { name = pluginPrefix.."issetwithonly3bonus", filterCallback  	= GetFilterCallbackForSets(true, 3, true) },
	[9] = { name = pluginPrefix.."issetwith4bonus", filterCallback   		= GetFilterCallbackForSets(true, 4, false) },
	[10] = { name = pluginPrefix.."issetwithonly4bonus", filterCallback   = GetFilterCallbackForSets(true, 4, true) },
}

--[[
	There are four potential tables for this section each covering either english, german, french,
	or russian. Only english is required. If other language tables are not included, the english
	table will automatically be used for those languages. All languages must share common keys.
  ]]
local stringsEN = {
	[pluginPrefix.."Submenu"] = "Sets",
	[pluginPrefix.."isnoset"]			= "No sets",
	[pluginPrefix.."isset"] 			= "Sets",
	[pluginPrefix.."issetwith1bonus"] = "Sets >= 1 bonus",
	[pluginPrefix.."issetwithonly1bonus"] = "Sets = 1 bonus",
	[pluginPrefix.."issetwith2bonus"] = "Sets >= 2 bonus",
	[pluginPrefix.."issetwithonly2bonus"] = "Sets = 2 bonus",
	[pluginPrefix.."issetwith3bonus"] = "Sets >= 3 bonus",
	[pluginPrefix.."issetwithonly3bonus"] = "Sets = 3 bonus",
	[pluginPrefix.."issetwith4bonus"] = "Sets >= 4 bonus",
	[pluginPrefix.."issetwithonly4bonus"] = "Sets = 4 bonus",
}
local stringsDE = {
	[pluginPrefix.."Submenu"] = "Sets",
	[pluginPrefix.."isnoset"]			= "Keine Sets",
	[pluginPrefix.."isset"] 			= "Sets",
}
stringsDE = setmetatable(stringsDE, {__index = stringsEN})

local stringsFR = {
	[pluginPrefix.."Submenu"] = "Sets",
	[pluginPrefix.."isnoset"]			= "No sets",
	[pluginPrefix.."isset"] 			= "Sets",
	[pluginPrefix.."issetwith1bonus"] = "Sets >= 1 bonus",
	[pluginPrefix.."issetwithonly1bonus"] = "Sets = 1 bonus",
	[pluginPrefix.."issetwith2bonus"] = "Sets >= 2 bonus",
	[pluginPrefix.."issetwithonly2bonus"] = "Sets = 2 bonus",
	[pluginPrefix.."issetwith3bonus"] = "Sets >= 3 bonus",
	[pluginPrefix.."issetwithonly3bonus"] = "Sets = 3 bonus",
	[pluginPrefix.."issetwith4bonus"] = "Sets >= 4 bonus",
	[pluginPrefix.."issetwithonly4bonus"] = "Sets = 4 bonus",
}
local stringsRU = {
	[pluginPrefix.."Submenu"] = "набор",
	[pluginPrefix.."isnoset"]			= "Нет наборов",
	[pluginPrefix.."isset"] 			= "набор",
	[pluginPrefix.."issetwith1bonus"] = "набор >= 1 bonus",
	[pluginPrefix.."issetwithonly1bonus"] = "набор = 1 bonus",
	[pluginPrefix.."issetwith2bonus"] = "набор >= 2 bonus",
	[pluginPrefix.."issetwithonly2bonus"] = "набор = 2 bonus",
	[pluginPrefix.."issetwith3bonus"] = "набор >= 3 bonus",
	[pluginPrefix.."issetwithonly3bonus"] = "набор = 3 bonus",
	[pluginPrefix.."issetwith4bonus"] = "набор >= 4 bonus",
	[pluginPrefix.."issetwithonly4bonus"] = "набор = 4 bonus",
}
local stringsES = {
    [pluginPrefix.."Submenu"] = "Conjuntos",
    [pluginPrefix.."isnoset"]			= "No conjuntos",
    [pluginPrefix.."isset"] 			= "Conjuntos",
    [pluginPrefix.."issetwith1bonus"] = "Conjuntos >= 1 bonus",
    [pluginPrefix.."issetwithonly1bonus"] = "Conjuntos = 1 bonus",
    [pluginPrefix.."issetwith2bonus"] = "Conjuntos >= 2 bonus",
    [pluginPrefix.."issetwithonly2bonus"] = "Conjuntos = 2 bonus",
    [pluginPrefix.."issetwith3bonus"] = "Conjuntos >= 3 bonus",
    [pluginPrefix.."issetwithonly3bonus"] = "Conjuntos = 3 bonus",
    [pluginPrefix.."issetwith4bonus"] = "Conjuntos >= 4 bonus",
    [pluginPrefix.."issetwithonly4bonus"] = "Conjuntos = 4 bonus",
}

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
	submenuName = pluginPrefix.."Submenu",
	callbackTable = fullLevelDropdownSetsCallbacks,
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
	ruStrings = stringsRU,
    esStrings = stringsES,
}

--[[
	Register your filters by passing your new filter information to this function.
  ]]
AdvancedFilters_RegisterFilter(filterInformation)

--Add filter to ALL itemtypes, which are body parts
filterInformation.filterType = ITEMFILTERTYPE_ALL
filterInformation.onlyGroups = {"Body"}
--Register the same filter again at the ALL inventory tab
AdvancedFilters_RegisterFilter(filterInformation)
