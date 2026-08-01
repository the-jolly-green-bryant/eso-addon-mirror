local util = AdvancedFilters.util
--[[
	This function handles the actual filtering. Use whatever parameters for "GetFilterCallback..."
    and whatever logic you need to in "function( slot )". A return value of true means the item in
    question will be shown while the filter is active.
  ]]
local function GetFilterCallbackForQualities( minQuality, maxQuality )

--[[
    [ITEM_QUALITY_TRASH] 	 = "qualityTrash",
    [ITEM_QUALITY_NORMAL] 	 = "qualityNormal",
    [ITEM_QUALITY_MAGIC] 	 = "qualityMagic",
    [ITEM_QUALITY_ARCANE] 	 = "qualityArcane",
    [ITEM_QUALITY_ARTIFACT]  = "qualityArtifact",
    [ITEM_QUALITY_LEGENDARY] = "qualityLegendary",
]]

	return function( slot , slotIndex)
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end
		--get the item link
        local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
		-- Gets the item quality
		local itemQuality = GetItemLinkQuality(itemLink)

   		return false or ((itemQuality >= minQuality) and (itemQuality <= maxQuality))
	end
end

--[[
	This table is processed within Advanced Filters and its contents are added to Advanced Filters'
    callback table. The string value for name is the relevant key for the language table.
  ]]
local fullLevelDropdownQualitiesCallbacks = {
	[1] = { name = "gray", filterCallback   	  = GetFilterCallbackForQualities(ITEM_QUALITY_TRASH, ITEM_QUALITY_TRASH) },
	[2] = { name = "white", filterCallback  	  = GetFilterCallbackForQualities(ITEM_QUALITY_NORMAL, ITEM_QUALITY_NORMAL) },
	[3] = { name = "graywhite", filterCallback    = GetFilterCallbackForQualities(ITEM_QUALITY_TRASH, ITEM_QUALITY_NORMAL) },
	[4] = { name = "green", filterCallback  	  = GetFilterCallbackForQualities(ITEM_QUALITY_MAGIC, ITEM_QUALITY_MAGIC) },
	[5] = { name = "blue", filterCallback   	  = GetFilterCallbackForQualities(ITEM_QUALITY_ARCANE, ITEM_QUALITY_ARCANE) },
	[6] = { name = "greenblue", filterCallback    = GetFilterCallbackForQualities(ITEM_QUALITY_MAGIC, ITEM_QUALITY_ARCANE) },
	[7] = { name = "purple", filterCallback		  = GetFilterCallbackForQualities(ITEM_QUALITY_ARTIFACT, ITEM_QUALITY_ARTIFACT) },
	[8] = { name = "gold", filterCallback   	  = GetFilterCallbackForQualities(ITEM_QUALITY_LEGENDARY, ITEM_QUALITY_LEGENDARY) },
	[9] = { name = "purplegold", filterCallback   = GetFilterCallbackForQualities(ITEM_QUALITY_ARTIFACT, ITEM_QUALITY_LEGENDARY) },
}

--[[
	There are four potential tables for this section each covering either english, german, french,
	or russian. Only english is required. If other language tables are not included, the english
	table will automatically be used for those languages. All languages must share common keys.
  ]]
local stringsEN = {
	["FCOQualityFiltersSubmenu"] = "Quality",
	["gray"]	= "Quality [Trash]",
	["white"] 	= "Quality [Normal]",
	["graywhite"] = "Quality [Trash] - [Normal]",
	["green"] 	= "Quality [Magic]",
	["blue"] 	= "Quality [Arcane]",
	["greenblue"] = "Quality [Magic] - [Arcane]",
	["purple"] 	= "Quality [Artifact]",
	["gold"] 	= "Quality [Legendary]",
	["purplegold"] = "Quality [Artifact] - [Legendary]",
}
local stringsDE = {
	["FCOQualityFiltersSubmenu"] = "Qualität",
	["gray"]	= "Qualität [Abfall]",
	["white"] 	= "Qualität [Normal]",
	["graywhite"] = "Qualität [Abfall] - [Normal]",
	["green"] 	= "Qualität [Magisch]",
	["blue"] 	= "Qualität [Obskur]",
	["greenblue"] = "Qualität [Magisch] - [Obskur]",
	["purple"] 	= "Qualität [Artefakt]",
	["gold"] 	= "Qualität [Legendär]",
	["purplegold"] = "Qualität [Artefakt] - [Legendär]",
}
local stringsFR = {
	["FCOQualityFiltersSubmenu"] = "Qualité",
	["gray"]	= "Qualité [Déchets]",
	["white"] 	= "Qualité [Normal]",
	["graywhite"] = "Qualité [Déchets] - [Normal]",
	["green"] 	= "Qualité [Magique]",
	["blue"] 	= "Qualité [Arcane]",
	["greenblue"] = "Qualité [Magique] - [Arcane]",
	["purple"] 	= "Qualité [Artefact]",
	["gold"] 	= "Qualité [Légendaire]",
	["purplegold"] = "Qualité [Artefact] - [Légendaire]",
}
local stringsRU = {
	["FCOQualityFiltersSubmenu"] = "Quality",
	["gray"]	= "Quality [Trash]",
	["white"] 	= "Quality [Normal]",
	["graywhite"] = "Quality [Trash] - [Normal]",
	["green"] 	= "Quality [Magic]",
	["blue"] 	= "Quality [Arcane]",
	["greenblue"] = "Quality [Magic] - [Arcane]",
	["purple"] 	= "Quality [Artifact]",
	["gold"] 	= "Quality [Legendary]",
	["purplegold"] = "Quality [Artifact] - [Legendary]",
}
local stringsES = {
	["FCOQualityFiltersSubmenu"] = "Calidad",
	["gray"]	= "Calidad [Basura]",
	["white"] 	= "Calidad [Normal]",
	["graywhite"] = "Calidad [Basura] - [Normal]",
	["green"] 	= "Calidad [Magia]",
	["blue"] 	= "Calidad [Arcano]",
	["greenblue"] = "Calidad [Magia] - [Arcano]",
	["purple"] 	= "Calidad [Artefacto]",
	["gold"] 	= "Calidad [Legendario]",
	["purplegold"] = "Calidad [Artefacto] - [Legendario]",
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
    submenuName = "FCOQualityFiltersSubmenu",
    callbackTable = fullLevelDropdownQualitiesCallbacks,
    filterType = ITEMFILTERTYPE_ALL,
    subfilters = {"All",},
    excludeSubfilters = {"Clothing", "Vanity"},
    enStrings = stringsEN,
    deStrings = stringsDE,
    frStrings = stringsFR,
    ruStrings = stringsRU,
    esStrings = stringsES,
}
--[[
	Again, register your filters by passing your new filter information to this function.
  ]]
AdvancedFilters_RegisterFilter(filterInformation)