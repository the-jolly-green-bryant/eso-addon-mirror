local util = AdvancedFilters.util
local function GetFilterCallbackForCraftingMaterialLevels(minLevel, maxLevel)
	return function( slot , slotIndex)
		if not CMLD_GetItemLevel then return false end
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end

    	local function getItemIdNumberFromItemLink(itemLink)
			local itemId = select(4, ZO_LinkHandler_ParseLink(itemLink))
		    return tonumber(itemId)
        end
		local bagId, slotIndex = slot.bagId, slot.slotIndex
		local link = util.GetItemLink(slot)
        local itemId = getItemIdNumberFromItemLink(link)
        local tradeSkillType, itemType = GetItemCraftingInfo(bagId, slotIndex)

		--Mapping array for the old veteran levels to champion points
		local veteranLevelToLevelStr = {
			[60] = "CP10",
			[70] = "CP20",
			[80] = "CP30",
			[90] = "CP40",
			[100] = "CP50",
			[110] = "CP60",
			[120] = "CP70",
			[130] = "CP80",
			[140] = "CP90",
			[150] = "CP100",
			[160] = "CP110",
			[170] = "CP120",
			[180] = "CP130",
			[190] = "CP140",
			[200] = "CP150",
			[210] = "CP160",
		}

		local levelMin, levelMax = CMLD_GetItemLevel(tradeSkillType, itemType, itemId)
		--Item is not level relevant, hide it
		if levelMin == -1 and levelMax == -1 then return false end

		--Compare determined material levels with filter values minLevel and maxLevel now
		if levelMin == levelMax then
			--Material is only valid for 1 level
	        return false or (levelMin == minLevel)
        else
			--Material is valid for a level range
	        return false or ((levelMin >= minLevel) and (levelMax <= maxLevel))
        end
	end
end

local craftingMaterialsLevelDropdownCallbacks = {
	[1] = { name = "mat1", filterCallback 			= GetFilterCallbackForCraftingMaterialLevels(1, 1) },
	[2] = { name = "mat1-5", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(1, 5) },
	[3] = { name = "mat1-10", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(1, 10) },
	[4] = { name = "mat1-15", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(1, 15) },
	[5] = { name = "mat5", filterCallback 			= GetFilterCallbackForCraftingMaterialLevels(5, 5) },
	[6] = { name = "mat5-10", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(5, 10) },
	[7] = { name = "mat10", filterCallback 			= GetFilterCallbackForCraftingMaterialLevels(10, 10) },
	[8] = { name = "mat10-15", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(10, 15) },
	[9] = { name = "mat10-20", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(10, 20) },
	[10] = { name = "mat15", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(15, 15) },
	[11] = { name = "mat15-20", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(15, 20) },
	[12] = { name = "mat15-25", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(15, 25) },
	[13] = { name = "mat20", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(20, 20) },
	[14] = { name = "mat20-25", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(20, 25) },
	[15] = { name = "mat20-30", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(20, 30) },
	[16] = { name = "mat25", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(25, 25) },
	[17] = { name = "mat25-30", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(25, 30) },
	[18] = { name = "mat25-35", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(25, 35) },
	[19] = { name = "mat30", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(30, 30) },
	[20] = { name = "mat30-35", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(30, 35) },
	[21] = { name = "mat30-40", filterCallback		= GetFilterCallbackForCraftingMaterialLevels(30, 40) },
	[22] = { name = "mat35", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(35, 35) },
	[23] = { name = "mat35-40", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(35, 40) },
	[24] = { name = "mat35-45", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(35, 45) },
	[25] = { name = "mat40", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(40, 40) },
	[26] = { name = "mat40-45", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(40, 45) },
	[27] = { name = "mat40-50", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(40, 50) },
	[28] = { name = "mat45", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(45, 45) },
	[29] = { name = "mat45-50", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(45, 50) },
	[30] = { name = "mat50", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(50, 50) },
	[31] = { name = "matCP10-CP30", filterCallback 	= GetFilterCallbackForCraftingMaterialLevels(60, 80) },
	[32] = { name = "matCP30-CP50", filterCallback 	= GetFilterCallbackForCraftingMaterialLevels(80, 100) },
	[33] = { name = "matCP40-CP60", filterCallback 	= GetFilterCallbackForCraftingMaterialLevels(90, 110) },
	[34] = { name = "matCP50", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(100, 100) },
	[35] = { name = "matCP50-CP70", filterCallback 	= GetFilterCallbackForCraftingMaterialLevels(100, 120) },
	[36] = { name = "matCP70-CP80", filterCallback 	= GetFilterCallbackForCraftingMaterialLevels(120, 130) },
	[37] = { name = "matCP70-CP90", filterCallback 	= GetFilterCallbackForCraftingMaterialLevels(120, 140) },
	[38] = { name = "matCP90-CP140", filterCallback = GetFilterCallbackForCraftingMaterialLevels(140, 190) },
	[39] = { name = "matCP100-CP140", filterCallback = GetFilterCallbackForCraftingMaterialLevels(150, 190) },
	[40] = { name = "matCP150-CP160", filterCallback = GetFilterCallbackForCraftingMaterialLevels(200, 210) },
	[41] = { name = "mat1-50", filterCallback 		= GetFilterCallbackForCraftingMaterialLevels(1, 50) },
	[42] = { name = "matCP10-CP160", filterCallback = GetFilterCallbackForCraftingMaterialLevels(60, 210) },
}

local cpIcon = zo_iconFormat("/esoui/art/menubar/gamepad/gp_playermenu_icon_champion.dds", 16, 16)
local stringsEn = {
	["FCOCMLDLevelFiltersSubmenu"] = "Craft. mat. level",
	["mat1"]     = "1",
	["mat1-5"]   = "1-5",
	["mat1-10"]  = "1-10",
	["mat1-15"]  = "1-15",
	["mat5"] 	 = "5",
	["mat5-10"]  = "5-10",
	["mat10"] 	 = "10",
	["mat10-15"] = "10-15",
	["mat10-20"] = "10-20",
	["mat15"] 	 = "15",
	["mat15-20"] = "15-20",
	["mat15-25"] = "15-25",
	["mat20"] 	 = "20",
	["mat20-25"] = "20-25",
	["mat20-30"] = "20-30",
	["mat25"] 	 = "25",
	["mat25-30"] = "25-30",
	["mat25-35"] = "25-35",
	["mat30"] 	 = "30",
	["mat30-35"] = "30-35",
	["mat30-40"] = "30-40",
	["mat35"]	 = "35",
	["mat35-40"] = "35-40",
	["mat35-45"] = "35-45",
	["mat40"] 	 = "40",
	["mat40-45"] = "40-45",
	["mat40-50"] = "40-50",
	["mat45"] 	 = "45",
	["mat45-50"] = "45-50",
	["mat50"] 	 = "50",
	["mat1-50"]   = "1-50",
	["matCP10-CP30"] = cpIcon .. "10-" .. cpIcon .. "30",
	["matCP30-CP50"] = cpIcon .. "30-" .. cpIcon .. "50",
	["matCP40-CP60"] = cpIcon .. "40-" .. cpIcon .. "60",
	["matCP50"] 	 = cpIcon .. "50",
	["matCP50-CP70"] = cpIcon .. "50-" .. cpIcon .. "70",
	["matCP70-CP80"] = cpIcon .. "70-" .. cpIcon .. "80",
	["matCP70-CP90"] = cpIcon .. "70-" .. cpIcon .. "90",
	["matCP90-CP140"] = cpIcon .. "90-" .. cpIcon .. "140",
	["matCP100-CP140"] = cpIcon .. "100-" .. cpIcon .. "140",
	["matCP150-CP160"] = cpIcon .. "150-" .. cpIcon .. "160",
	["matCP10-CP160"] = cpIcon .. "10-" .. cpIcon .. "160"
}

local stringsDe = {
	["FCOCMLDLevelFiltersSubmenu"] = "Craft. Mat. Level",
}
stringsDe = setmetatable(stringsDe, {_index = stringsEn })

local stringsFr = {
	["FCOCMLDLevelFiltersSubmenu"] = "Level de mat. craft.",
}
stringsFr = setmetatable(stringsFr, {_index = stringsEn })

local stringsRu = {
    ["FCOCMLDLevelFiltersSubmenu"] = "Level de mat. craft.",
}
stringsRu = setmetatable(stringsRu, {_index = stringsEn })

local stringsEs = {
    ["FCOCMLDLevelFiltersSubmenu"] = "Level de mat. craft.",
}
stringsEs = setmetatable(stringsEs, {_index = stringsEn })

local filterInformation = {
	submenuName = "FCOCMLDLevelFiltersSubmenu",
	callbackTable = craftingMaterialsLevelDropdownCallbacks,
	filterType = ITEMFILTERTYPE_CRAFTING,
    subfilters = {"All",},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE, LF_SMITHING_CREATION,
        LF_ALCHEMY_CREATION,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT
    },
	enStrings = stringsEn,
	deStrings = stringsDe,
	frStrings = stringsFr,
	ruStrings = stringsRu,
    esStrings = stringsEs,
}
AdvancedFilters_RegisterFilter(filterInformation)

local filterInformation = {
    submenuName = "FCOCMLDLevelFiltersSubmenu",
    callbackTable = craftingMaterialsLevelDropdownCallbacks,
    filterType = ITEMFILTERTYPE_ALL,
    subfilters = {"All",},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE, LF_SMITHING_CREATION,
        LF_ALCHEMY_CREATION,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT
    },
    onlyGroups = {"Crafting", "Craftbag"},
    enStrings = stringsEn,
    deStrings = stringsDe,
    frStrings = stringsFr,
    ruStrings = stringsRu,
    esStrings = stringsEs,
}
AdvancedFilters_RegisterFilter(filterInformation)
