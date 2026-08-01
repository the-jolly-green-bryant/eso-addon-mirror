local util = AdvancedFilters.util
--[[
    CRAFTING_TYPE_ALCHEMY = 4
    CRAFTING_TYPE_BLACKSMITHING = 1
    CRAFTING_TYPE_CLOTHIER = 2
    CRAFTING_TYPE_ENCHANTING = 3
    CRAFTING_TYPE_INVALID = 0
    CRAFTING_TYPE_ITERATION_BEGIN = 0
    CRAFTING_TYPE_ITERATION_END = 7
    CRAFTING_TYPE_JEWELRYCRAFTING = 7
    CRAFTING_TYPE_MAX_VALUE = 7
    CRAFTING_TYPE_MIN_VALUE = 0
    CRAFTING_TYPE_PROVISIONING = 5
    CRAFTING_TYPE_WOODWORKING = 6
]]
local supportedCraftingStationTypes = {
	CRAFTING_TYPE_BLACKSMITHING,
	CRAFTING_TYPE_CLOTHIER,
	CRAFTING_TYPE_ENCHANTING,
	CRAFTING_TYPE_ALCHEMY,
	CRAFTING_TYPE_PROVISIONING,
	CRAFTING_TYPE_WOODWORKING,
	CRAFTING_TYPE_JEWELRYCRAFTING
}
local suportedRawMaterialTypes = {
	[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] 	= true,
	[ITEMTYPE_CLOTHIER_RAW_MATERIAL] 		= true,
	[ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] 	= true,
	[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = true,
	[ITEMTYPE_JEWELRY_RAW_TRAIT] 			= true,
	[ITEMTYPE_RAW_MATERIAL] 				= true,
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] 	= true,
}

--[[
	This function handles the actual filtering. Use whatever parameters for "GetFilterCallback..."
    and whatever logic you need to in "function( slot )".
  ]]
local function GetFilterCallbackForFCORawMaterialItems()
	return function( slot , slotIndex)
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end
		local bag, slot = slot.bagId, slot.slotIndex
		if bag and slot then
			local itemLink = ""
            --local refineableRawMat = ZO_SharedSmithingExtraction_GetFilterTypeFromItem(slot.bagId, slot.slotIndex) == ZO_SMITHING_EXTRACTION_SHARED_FILTER_TYPE_RAW_MATERIALS
			-->Function was changed with Murkmire patch (API 100025) to:
			-->But will only work at crafting stations properly!
			local refineableRawMat = false
			if util.IsCraftingPanelShown() then
				refineableRawMat = (ZO_CraftingUtils_GetSmithingFilterFromItem(bag, slot) == SMITHING_FILTER_TYPE_RAW_MATERIALS) or false
			else
				itemLink = GetItemLink(bag, slot)
				local itemType = GetItemLinkItemType(itemLink)
				refineableRawMat = suportedRawMaterialTypes[itemType] or false
			end
         	--Item is allowed to be refined
			if refineableRawMat then
				local retVar = false
				for _, craftingStationType in pairs (supportedCraftingStationTypes) do
					--Check if item is really refineable
					if CanItemBeSmithingExtractedOrRefined ~= nil then -- removed with API100028 and split into CanItemBeDeconstructed and CanItemBeRefined
						retVar = CanItemBeSmithingExtractedOrRefined(bag, slot, craftingStationType)
					else
						retVar = CanItemBeRefined(bag, slot, craftingStationType)
					end
					if retVar == true then return true end
				end
				return retVar
			end
	    end
	    return false
	end
end

--[[
	This table is processed within Advanced Filters and it's contents are added to Advanced Filter's
    callback table. The string value for name is the relevant key for the language table.
  ]]
local FCORAWMaterialDropdownCallback = {
	[1] = { name = "FCORAWMaterial", filterCallback = GetFilterCallbackForFCORawMaterialItems()},
}

--[[
	There are four potential tables for this section - enStrings (English), deStrings (German),
	frStrings (French), ruStrings (Russian). Only enStrings is required. If other language tables are
	not included, the english table will automatically be used for those languages. If other languages
	are included, all language must share common keys.
  ]]
local enFCORAWMaterialStrings = {
	["FCORAWMaterial"] 	 = "RAW materials",
}
local deFCORAWMaterialStrings = {
	["FCORAWMaterial"] 	 = "Rohmaterialien",
}
local frFCORAWMaterialStrings = {
	["FCORAWMaterial"] 	 = "Matières premières",
}
local ruFCORAWMaterialStrings = {
	["FCORAWMaterial"] 	 = "сырье",
}
local esFCORAWMaterialStrings = {
	["FCORAWMaterial"] 	 = "Materias primas",
}

--Build the AdvancedFilters filterInformation table for filters and subfilters
local filterInformation = {
	callbackTable = FCORAWMaterialDropdownCallback,
	filterType = ITEMFILTERTYPE_CRAFTING,
    subfilters = {"All",},
	excludeSubfilters = {"Alchemy", "Enchanting", "Provisioning",
                         "Style", "WeaponTrait", "ArmorTrait",
                         "RawMaterial", "FurnishingMat"},
	excludeFilterPanels = {
		LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
		LF_SMITHING_REFINE,
		LF_ALCHEMY_CREATION,
		LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
		LF_QUICKSLOT
	},
	enStrings = enFCORAWMaterialStrings,
	deStrings = deFCORAWMaterialStrings,
	frStrings = frFCORAWMaterialStrings,
	esStrings = esFCORAWMaterialStrings,
	ruStrings = ruFCORAWMaterialStrings,
}
--Register the filter
AdvancedFilters_RegisterFilter(filterInformation)

local filterInformation = {
    callbackTable = FCORAWMaterialDropdownCallback,
    filterType = ITEMFILTERTYPE_ALL,
    subfilters = {"All",},
    onlyGroups = {"Crafting", "Blacksmithing", "Clothing", "Woodworking", "JewelryCrafting"},
    excludeSubfilters = {"Alchemy", "Enchanting", "Provisioning",
                         "Style", "WeaponTrait", "ArmorTrait",
                         "RawMaterial", "RefinedMaterial", "Temper", "Resin", "Tannin",
                         "FurnishingMat"},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE,
        LF_ALCHEMY_CREATION,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT
    },
    enStrings = enFCORAWMaterialStrings,
    deStrings = deFCORAWMaterialStrings,
    frStrings = frFCORAWMaterialStrings,
    esStrings = esFCORAWMaterialStrings,
    ruStrings = ruFCORAWMaterialStrings,
}
--Register the filter
AdvancedFilters_RegisterFilter(filterInformation)
