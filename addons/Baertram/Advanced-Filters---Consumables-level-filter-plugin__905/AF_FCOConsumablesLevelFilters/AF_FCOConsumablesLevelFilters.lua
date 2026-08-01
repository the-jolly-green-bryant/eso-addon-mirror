local util = AdvancedFilters.util

--[[
	This function handles the actual filtering. Use whatever parameters for "GetFilterCallback..."
    and whatever logic you need to in "function( slot )". A return value of true means the item in
    question will be shown while the filter is active.
  ]]
local function GetFilterCallbackForConsumablesLevel( minLevel, maxLevel )
	return function( slot , slotIndex)
		if util.prepareSlot ~= nil then
			if slotIndex ~= nil and type(slot) ~= "table" then
				slot = util.prepareSlot(slot, slotIndex)
			end
		end
		local link = util.GetItemLink(slot)
		local level = GetItemLinkRequiredLevel(link)
		local vetLevel = GetItemLinkRequiredVeteranRank(link)

		if vetLevel > 0 then
			level = level + vetLevel
		end
		return false or ((level >= minLevel) and (level <= maxLevel))
	end
end

--[[
	This table is processed within Advanced Filters and its contents are added to Advanced Filters'
    callback table. The string value for name is the relevant key for the language table.
  ]]
local fullLevelDropdownConsumablesCallbacks = {
	[1] = { name = "1-10", filterCallback 			= GetFilterCallbackForConsumablesLevel(1, 10) },
	[2] = { name = "11-20", filterCallback 			= GetFilterCallbackForConsumablesLevel(11, 20) },
	[3] = { name = "21-30", filterCallback 			= GetFilterCallbackForConsumablesLevel(21, 30) },
	[4] = { name = "31-40", filterCallback 			= GetFilterCallbackForConsumablesLevel(31, 40) },
	[5] = { name = "41-50", filterCallback 			= GetFilterCallbackForConsumablesLevel(41, 50) },
	[6] = { name = "CP10-CP20", filterCallback 		= GetFilterCallbackForConsumablesLevel(60, 70) },
	[7] = { name = "CP30-CP40", filterCallback 		= GetFilterCallbackForConsumablesLevel(80, 90) },
	[8] = { name = "CP50-CP60", filterCallback 		= GetFilterCallbackForConsumablesLevel(100, 110) },
	[9] = { name = "CP70-CP80", filterCallback 		= GetFilterCallbackForConsumablesLevel(120, 130) },
	[10] = { name = "CP90-CP100", filterCallback 	= GetFilterCallbackForConsumablesLevel(140, 150) },
	[11] = { name = "CP110-CP120", filterCallback 	= GetFilterCallbackForConsumablesLevel(160, 170) },
	[12] = { name = "CP130-CP140", filterCallback 	= GetFilterCallbackForConsumablesLevel(180, 190) },
	[13] = { name = "CP150-CP160", filterCallback 	= GetFilterCallbackForConsumablesLevel(200, 210) },
}

--[[
	There are four potential tables for this section each covering either english, german, french,
	or russian. Only english is required. If other language tables are not included, the english
	table will automatically be used for those languages. All languages must share common keys.
  ]]
local cpIcon = zo_iconFormat("/esoui/art/menubar/gamepad/gp_playermenu_icon_champion.dds", 16, 16)
local stringsEN = {
	["FCOConsumablesLevelFiltersSubmenu"] = "Misc.: Level",
	["1-10"] = "1-10",
	["11-20"] = "11-20",
	["21-30"] = "21-30",
	["31-40"] = "31-40",
	["41-50"] = "41-50",
	["CP10-CP20"] = cpIcon .. 	"10-".. cpIcon .. "20",
	["CP30-CP40"] = cpIcon .. 	"30-".. cpIcon .. "40",
	["CP50-CP60"] = cpIcon .. 	"50-".. cpIcon .. "60",
	["CP70-CP80"] = cpIcon .. 	"70-".. cpIcon .. "80",
	["CP90-CP100"] = cpIcon .. 	"90-".. cpIcon .. "100",
	["CP110-CP120"] = cpIcon .. "110-".. cpIcon .. "120",
	["CP130-CP140"] = cpIcon .. "130-".. cpIcon .. "140",
	["CP150-CP160"] = cpIcon .. "150-".. cpIcon .. "160",

}
local stringsDE = {
	["FCOConsumablesLevelFiltersSubmenu"] = "Versch.: Level",
}
stringsDE = setmetatable(stringsDE, {__index = StringsEN})
local stringsFR = {
	["FCOConsumablesLevelFiltersSubmenu"] = "Divers: Niveau",
}
stringsFR = setmetatable(stringsFR, {__index = StringsEN})
local stringsRU = {
	["FCOConsumablesLevelFiltersSubmenu"] = "Разное: уровень",
}
stringsRU = setmetatable(stringsRU, {__index = StringsEN})
local stringsES = {
	["FCOConsumablesLevelFiltersSubmenu"] = "Diverso: Nivel",
}
stringsES = setmetatable(stringsES, {__index = StringsEN})

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
    submenuName = "FCOConsumablesLevelFiltersSubmenu",
	callbackTable = fullLevelDropdownConsumablesCallbacks,
	filterType = ITEMFILTERTYPE_CONSUMABLE,
    subfilters = {"All",},
	excludeFilterPanels = {
		LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
		LF_SMITHING_REFINE, LF_SMITHING_CREATION,
		LF_ALCHEMY_CREATION,
		LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
		LF_QUICKSLOT,
        LF_CRAFTBAG
	},
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

local filterInformation = {
	submenuName = "FCOConsumablesLevelFiltersSubmenu",
	callbackTable = fullLevelDropdownConsumablesCallbacks,
	filterType = ITEMFILTERTYPE_ALL,
	onlyGroups = {"Consumables"},
	subfilters = {"All",},
	excludeFilterPanels = {
		LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
		LF_SMITHING_REFINE, LF_SMITHING_CREATION,
		LF_ALCHEMY_CREATION,
		LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
		LF_QUICKSLOT,
        LF_CRAFTBAG
	},
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