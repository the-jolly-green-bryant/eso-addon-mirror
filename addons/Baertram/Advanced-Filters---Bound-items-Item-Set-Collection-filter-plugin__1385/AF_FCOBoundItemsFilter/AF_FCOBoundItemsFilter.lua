local util = AdvancedFilters.util
local universalDeconStr = "UniversalDecon"

local function checkBindType(itemLink, bindTypesNeeded)
	if not itemLink or itemLink == "" then return false end
	local bindType = GetItemLinkBindType(itemLink)
	--[[
		BIND_TYPE_NONE = 0
		BIND_TYPE_ON_PICKUP = 1
		BIND_TYPE_ON_EQUIP = 2
		BIND_TYPE_ON_PICKUP_BACKPACK = 3
	]]
	if not bindType then return false end
	for _,bindTypeNeeded in ipairs(bindTypesNeeded) do
		if bindTypeNeeded == bindType then return true end
	end
	return false
end


--[[
	This function handles the actual filtering. Use whatever parameters for "GetFilterCallback..."
    and whatever logic you need to in "function( slot )".
  ]]
local function GetFilterCallbackForFCOBoundItems(check, bindTypesNeeded, special)
	return function( slot , slotIndex)
		local function checkBound(p_check, p_slot, p_bindTypesNeeded)
			p_check = p_check or false
			local function checkNow(itemLink)
				if itemLink ~= nil then
					local isItemBound = IsItemLinkBound(itemLink)
					if isItemBound == p_check then
						if p_bindTypesNeeded ~= nil then
							return checkBindType(itemLink, p_bindTypesNeeded)
						else
							return true
						end
					end
				end
				return false
			end
			--get the item link
			local itemLink = util.GetItemLink(p_slot)
			--Check if bound items should be shown, or not
			local checkResult = checkNow(itemLink)
			return checkResult, itemLink
		end
		--Prepare crafting inventory slots with the bagId and slotIndex properly
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end
		--Special handling or normal?
		if special == nil then
			return checkBound(check, slot, bindTypesNeeded)
		else
			--BOP tradeable?
			if special == "BOPTrade" then
				return IsItemBoPAndTradeable(slot.bagId, slot.slotIndex)
				--Unbound or bound but on pickup only or on equip
			elseif special == "UnboundToChar" then
				--Unbound items: Return true
				local isBoundResultValid = checkBound(false, slot, nil)
				if isBoundResultValid then
					return true
				else
					--Check if any of the bindTypes is true
					return checkBound(true, slot, bindTypesNeeded)
				end
				return false
			--SetItemCollection known or SetItemCollection unknown
			elseif special == "SICKnown" or special == "SICUnknown" then
				local checkSICKnown = (special == "SICKnown") or false
				local checkSICUnknown = (special == "SICUnknown") or false
				local isBoundResultValid, itemLink = checkBound(check, slot, bindTypesNeeded)
				if isBoundResultValid then
					--No self crafted set items!
					if IsItemLinkCrafted(itemLink) then return false end
					local isKnownSetCollectionPiece = IsItemLinkSetCollectionPiece(itemLink) and IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink))
					if GetItemLinkActorCategory(itemLink) == GAMEPLAY_ACTOR_CATEGORY_COMPANION then return false end
					local checkResultVar
					if checkSICKnown == true then
						checkResultVar = true
					else
						checkResultVar = false
					end
					return (isKnownSetCollectionPiece == checkResultVar) or false
				end
			end
		end
	end
end

--[[
	This table is processed within Advanced Filters and it's contents are added to Advanced Filter's
    callback table. The string value for name is the relevant key for the language table.
  ]]
local FCOBoundItemsDropdownCallback = {
	{ name = "FCOBound", 							filterCallback = GetFilterCallbackForFCOBoundItems(true, 	nil,										nil)},
	{ name = "FCOBoundOnEquip", 					filterCallback = GetFilterCallbackForFCOBoundItems(true, 	{BIND_TYPE_ON_EQUIP},						nil)},
	{ name = "FCOBoundOnPickup", 					filterCallback = GetFilterCallbackForFCOBoundItems(true, 	{BIND_TYPE_ON_PICKUP}, 						nil)},
	{ name = "FCOBoundOnPickupBackpack", 			filterCallback = GetFilterCallbackForFCOBoundItems(true, 	{BIND_TYPE_ON_PICKUP_BACKPACK}, 			nil)},
	{ name = "FCOBOPTradeable", 					filterCallback = GetFilterCallbackForFCOBoundItems(true, 	nil, 										"BOPTrade")},
	{ name = "FCOUnboundToChar", 					filterCallback = GetFilterCallbackForFCOBoundItems(nil, 	{BIND_TYPE_ON_PICKUP, BIND_TYPE_ON_EQUIP}, 	"UnboundToChar")},
	{ name = "FCOUnbound", 							filterCallback = GetFilterCallbackForFCOBoundItems(false, 	nil, 										nil)},
	{ name = "FCOUnboundUnknownSetItemCollection", 	filterCallback = GetFilterCallbackForFCOBoundItems(false, 	{BIND_TYPE_ON_PICKUP, BIND_TYPE_ON_EQUIP}, 	"SICUnknown")},
	{ name = "FCOUnboundKnownSetItemCollection", 	filterCallback = GetFilterCallbackForFCOBoundItems(false, 	{BIND_TYPE_ON_PICKUP, BIND_TYPE_ON_EQUIP}, 	"SICKnown")},
	{ name = "FCOBoundKnownSetItemCollection", 		filterCallback = GetFilterCallbackForFCOBoundItems(true, 	{BIND_TYPE_ON_PICKUP, BIND_TYPE_ON_EQUIP}, 	"SICKnown")},
}

--[[
	There are four potential tables for this section - enStrings (English), deStrings (German),
	frStrings (French), ruStrings (Russian). Only enStrings is required. If other language tables are
	not included, the english table will automatically be used for those languages. If other languages
	are included, all language must share common keys.
  ]]
local enFCOBoundStrings = {
	["FCOBoundFiltersSubmenu"] 		= "Bound state",
	["FCOBound"]   					= "Bound",
	["FCOBoundOnEquip"]				= "BOE -> Bound on equip",
	["FCOBoundOnPickup"] 			= "BOP -> Bound on pickup",
	["FCOBoundOnPickupBackpack"]	= "BOP (to character)",
	["FCOBOPTradeable"]				= "BOP (tradeable in group)",
	["FCOUnboundToChar"]			= "Unbound & not bound to current char",
	["FCOUnbound"] 					= "Unbound",
	["FCOUnboundUnknownSetItemCollection"] 	= "Unbound & unknown set item collection",
	["FCOUnboundKnownSetItemCollection"] 	= "Unbound & known set item collection",
	["FCOBoundKnownSetItemCollection"] 		= "Known set item collection",
}
local deFCOBoundStrings = {
	["FCOBoundFiltersSubmenu"] 		= "Gebunden Status",
	["FCOBound"] 	 				= "Gebunden",
	["FCOBoundOnEquip"]				= "BOE -> Gebunden beim Ausrüsten",
	["FCOBoundOnPickup"] 			= "BOP -> Gebunden beim Aufheben",
	["FCOBoundOnPickupBackpack"]	= "BOP (an den Charakter)",
	["FCOBOPTradeable"]				= "BOP (in Gruppe handelbar)",
	["FCOUnboundToChar"]			= "Ungebunden & nicht gebunden an Charakter",
	["FCOUnbound"] 	 				= "Ungebunden",
	["FCOUnboundUnknownSetItemCollection"] 	= "Ungebunden & unbekannte Set Kollektion",
	["FCOUnboundKnownSetItemCollection"] 	= "Ungebunden & bekannte Set Kollektion",
	["FCOBoundKnownSetItemCollection"] 		= "Bekannte Set Kollektion",
}
local frFCOBoundStrings = {
	["FCOBoundFiltersSubmenu"] 		= "État lié",
	["FCOBound"] 	 				= "Lié",
	["FCOBoundOnEquip"]				= "BOE -> Lié sur équiper",
	["FCOBoundOnPickup"] 			= "BOP -> Lié au ramassage",
	["FCOBoundOnPickupBackpack"]	= "BOP (au personnage)",
	["FCOBOPTradeable"]				= "BOP (échangeable en groupe)",
	["FCOUnbound"] 	 				= "Non lié",
	["FCOUnboundUnknownSetItemCollection"] 	= "Collection d'ensemble non liés et inconnus",
	["FCOUnboundKnownSetItemCollection"] 	= "Collection d'ensemble non liés et connus",
	["FCOBoundKnownSetItemCollection"] 		= "Collection d'ensemble connus",
}
local esFCOBoundStrings = {
	["FCOBoundFiltersSubmenu"] 		= "Estado obligado",
	["FCOBound"] 					= "Fidelizado",
	["FCOBoundOnEquip"]				= "BOE -> Fidelizado en equipar",
	["FCOBoundOnPickup"] 			= "BOP -> Fidelizado en la recogida",
	["FCOBoundOnPickupBackpack"]	= "BOP (al personaje)",
	["FCOBOPTradeable"]				= "BOP (negociable en grupo)",
	["FCOUnbound"]   				= "Non fidelizado",
	["FCOUnboundUnknownSetItemCollection"] 	= "Colección de artículos non fidelizado & desconocido",
	["FCOUnboundKnownSetItemCollection"] 	= "Colección de artículos non fidelizado & conocido ",
	["FCOBoundKnownSetItemCollection"] 		= "Colección de artículos conocido",
}
local ruFCOBoundStrings = {
	["FCOBoundFiltersSubmenu"] 		= "Связанное состояние",
	["FCOBound"] 					= "граница",
	["FCOBoundOnEquip"]				= "BOE -> Привязан к экипировке",
	["FCOBoundOnPickup"] 			= "BOP -> Связано при получении",
	["FCOBoundOnPickupBackpack"]	= "BOP (характер)",
	["FCOBOPTradeable"]				= "BOP (торгуемый в группе)",
	["FCOUnbound"]   				= "несвязанный",
	["FCOUnboundUnknownSetItemCollection"] 	= "Несвязанный и неизвестный набор элементов коллекции",
	["FCOUnboundKnownSetItemCollection"] 	= "Несвязанный и известный набор элементов коллекции",
	["FCOBoundKnownSetItemCollection"] 		= "Известный набор элементов коллекции",
}

--[[
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ALL] =     universalDeconStr .. "All",
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_ARMOR] =   universalDeconStr .. "Armor",
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_WEAPONS] = universalDeconStr .. "Weapons",
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_JEWELRY] = universalDeconStr .. "Jewelry",
    [INVENTORY_TYPE_UNIVERSAL_DECONSTRUCTION_GLYPHS] =  universalDeconStr .. "Glyphs",
]]

--Build the AdvancedFilters filterInformation table for filters and subfilters
local filterInformation = {
	submenuName = "FCOBoundFiltersSubmenu",
	callbackTable = FCOBoundItemsDropdownCallback,
	filterType = { 	ITEMFILTERTYPE_ALL,
					ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL,
					ITEMFILTERTYPE_AF_UNIVERSAL_DECON_WEAPONS,
					ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ARMOR,
					ITEMFILTERTYPE_AF_UNIVERSAL_DECON_JEWELRY,
	},
    subfilters = {"All",},
    onlyGroups = {"Armor", "Weapons", "Jewelry", "Consumables", "Furnishings", "Miscellaneous", "Companion",
				   "All" ..universalDeconStr,"Armor"..universalDeconStr, "Weapons"..universalDeconStr, "Jewelry"..universalDeconStr},
	excludeFilterPanels = {
		LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
		LF_SMITHING_REFINE, LF_SMITHING_CREATION,
		LF_JEWELRY_REFINE, LF_JEWELRY_CREATION,
		LF_ALCHEMY_CREATION,
		LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
		LF_QUICKSLOT,
		LF_CRAFTBAG
	},
	enStrings = enFCOBoundStrings,
	deStrings = deFCOBoundStrings,
	frStrings = frFCOBoundStrings,
	esStrings = esFCOBoundStrings,
	ruStrings = ruFCOBoundStrings,
}
--Register the filter
AdvancedFilters_RegisterFilter(filterInformation)