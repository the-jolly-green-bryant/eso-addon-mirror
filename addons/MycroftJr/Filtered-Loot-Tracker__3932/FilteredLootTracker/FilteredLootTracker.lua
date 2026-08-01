FilteredLootTracker = { }
FilteredLootTracker.name = "FilteredLootTracker"
FilteredLootTracker.variableVersion = 1

local logger = LibDebugLogger.Create(FilteredLootTracker.name)

FilteredLootTracker.CurrentFilter = 1

local zo_strformat_helpUrl = "https://wiki.esoui.com/How_to_format_strings_with_zo_strformat"

---@class Filter
---@field Name string?
---@field Enabled boolean
---@field Keywords string[]
---@field Uniques boolean
---@field NeededForCollection boolean
---@field CompanionGear boolean
---@field Quality string
---@field UseTraits boolean
---@field Traits table<"Armor"|"Weapon"|"Jewelry", table<string, boolean>>
---@field UseEquipTypes boolean
---@field EquipTypes table<"Armor"|"Weapon"|"Jewelry", table<string, boolean>>
---@field Weights table<"Light"|"Medium"|"Heavy", boolean>
FilteredLootTracker.FilterDefaults = {
	Enabled = true,
	Keywords = { },
	Uniques = false,
	NeededForCollection = false,
	CompanionGear = false,
	Quality = GetString("SI_ITEMQUALITY", ITEM_DISPLAY_QUALITY_MAGIC),
	UseTraits = true,
	Traits = { },
	UseEquipTypes = true,
	EquipTypes = { },
}

---@class Vars
---@field Loot boolean
---@field Icons boolean
---@field Time boolean
---@field Group boolean
---@field Filters Filter[]
---@field OfferTemplate string
---@field BegTemplate string
---@field AskTemplate string
---@field MultiOfferTemplate string
FilteredLootTracker.Defaults = {
	Loot = true,
	Icons = true,
	Time = false,
	-- filters
	Group = true,
	Filters = { },
	OfferTemplate = "Anybody need <<1>>?",
	BegTemplate = "/w <<1>> You looted <<2>>, can I have it?",
	AskTemplate = "/w <<1>> Can I please have <<2{A}>> <<X:2>>?",
	MultiOfferTemplate = "Anybody need? <<1>>"
}

--- @alias EquipCategory "Armor"|"Jewelry"|"Weapon"

-- plz ZOS an API for these:
--- @type table<ItemTraitTypeCategory, EquipCategory>
local TRAIT_CATEGORY_NAMES = {
	[ITEM_TRAIT_TYPE_CATEGORY_WEAPON] = "Weapon",
	[ITEM_TRAIT_TYPE_CATEGORY_ARMOR] = "Armor",
	[ITEM_TRAIT_TYPE_CATEGORY_JEWELRY] = "Jewelry",
}

--- @type table<EquipType, EquipCategory>
local EQUIP_TYPES = {
	[EQUIP_TYPE_HEAD] = "Armor",
	[EQUIP_TYPE_NECK] = "Jewelry",
	[EQUIP_TYPE_CHEST] = "Armor",
	[EQUIP_TYPE_SHOULDERS] = "Armor",
	[EQUIP_TYPE_ONE_HAND] = "Weapon",
	[EQUIP_TYPE_TWO_HAND] = "Weapon",
	[EQUIP_TYPE_OFF_HAND] = "Weapon", -- yes, even shields are weapons in the API
	[EQUIP_TYPE_WAIST] = "Armor",
	[EQUIP_TYPE_LEGS] = "Armor",
	[EQUIP_TYPE_FEET] = "Armor",
	[EQUIP_TYPE_RING] = "Jewelry",
	[EQUIP_TYPE_HAND] = "Armor",
	[EQUIP_TYPE_MAIN_HAND] = "Weapon",
}

--- @type table<WeaponType, boolean>
local TWO_HANDERS = {
	[WEAPONTYPE_TWO_HANDED_SWORD] = true,
	[WEAPONTYPE_TWO_HANDED_AXE] = true,
	[WEAPONTYPE_TWO_HANDED_HAMMER] = true,
	[WEAPONTYPE_BOW] = true,
	[WEAPONTYPE_HEALING_STAFF] = true,
	[WEAPONTYPE_FIRE_STAFF] = true,
	[WEAPONTYPE_FROST_STAFF] = true,
	[WEAPONTYPE_LIGHTNING_STAFF] = true,
}

--- @type table<ItemTraitType, boolean>
local IS_COMPANION_TRAIT = {
	[ITEM_TRAIT_TYPE_ARMOR_AGGRESSIVE] = true,
	[ITEM_TRAIT_TYPE_ARMOR_AUGMENTED] = true,
	[ITEM_TRAIT_TYPE_ARMOR_BOLSTERED] = true,
	[ITEM_TRAIT_TYPE_ARMOR_FOCUSED] = true,
	[ITEM_TRAIT_TYPE_ARMOR_PROLIFIC] = true,
	[ITEM_TRAIT_TYPE_ARMOR_QUICKENED] = true,
	[ITEM_TRAIT_TYPE_ARMOR_SHATTERING] = true,
	[ITEM_TRAIT_TYPE_ARMOR_SOOTHING] = true,
	[ITEM_TRAIT_TYPE_ARMOR_VIGOROUS] = true,
	[ITEM_TRAIT_TYPE_JEWELRY_AGGRESSIVE] = true,
	[ITEM_TRAIT_TYPE_JEWELRY_AUGMENTED] = true,
	[ITEM_TRAIT_TYPE_JEWELRY_BOLSTERED] = true,
	[ITEM_TRAIT_TYPE_JEWELRY_FOCUSED] = true,
	[ITEM_TRAIT_TYPE_JEWELRY_PROLIFIC] = true,
	[ITEM_TRAIT_TYPE_JEWELRY_QUICKENED] = true,
	[ITEM_TRAIT_TYPE_JEWELRY_SHATTERING] = true,
	[ITEM_TRAIT_TYPE_JEWELRY_SOOTHING] = true,
	[ITEM_TRAIT_TYPE_JEWELRY_VIGOROUS] = true,
	[ITEM_TRAIT_TYPE_WEAPON_AGGRESSIVE] = true,
	[ITEM_TRAIT_TYPE_WEAPON_AUGMENTED] = true,
	[ITEM_TRAIT_TYPE_WEAPON_BOLSTERED] = true,
	[ITEM_TRAIT_TYPE_WEAPON_FOCUSED] = true,
	[ITEM_TRAIT_TYPE_WEAPON_PROLIFIC] = true,
	[ITEM_TRAIT_TYPE_WEAPON_QUICKENED] = true,
	[ITEM_TRAIT_TYPE_WEAPON_SHATTERING] = true,
	[ITEM_TRAIT_TYPE_WEAPON_SOOTHING] = true,
	[ITEM_TRAIT_TYPE_WEAPON_VIGOROUS] = true,
}
-- MINIMIZE HARD-CODED IDs/VALUES BELOW THIS POINT!

local function deepcopy(v)
	-- ZO_DeepTableCopy(v) if type(v) == "table" else v
	return type(v) == "table" and ZO_DeepTableCopy(v) or v
end

local function print(s)
	CHAT_ROUTER:AddSystemMessage(s)
end

local function printf(...)
	print(string.format(unpack(arg)))
end

local function OrderedValues(tab)
	local values = {}
	for i = 0, table.maxn(tab) do
		if tab[i] ~= nil then
			table.insert(values, tab[i])
		end
	end
	return values
end

--- @generic T
--- @param set table<T, true>
--- @return T[]
local function SetToList(set)
	local list = {}
	-- TODO: navigate in alphabetical key order?
	for k, v in pairs(set) do
		assert(v == true or v == false)
		if v then table.insert(list, k) end
	end
	return list
end

--- @generic T
--- @param list T[]
--- @return table<T, true>
local function ListToSet(list)
	local set = {}
	for _, v in pairs(list) do
		set[v] = true
	end
	return set
end

-- https://stackoverflow.com/a/51387770
local function tointeger( x )
	local num = tonumber( x )
	return num and (num < 0 and math.ceil( num ) or math.floor( num ))
end

-- https://stackoverflow.com/a/27028488/7376471
local function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

--- Set in AddonSettings()
--- @type table<string, ItemDisplayQuality>
local QUALITY_NAME_TO_ID = {}

-- These will be populated by TraitFinder()
--- @type table<ItemTraitType, string>
local TRAIT_NAMES = {}
--- @type table<EquipCategory, table<ItemTraitType, string>>
local TRAIT_MAP = {
	["Weapon"] = {},
	["Armor"] = {},
	["Jewelry"] = {},
	["Companion Gear"] = {},
}

-- These will be populated by EquipFinder(), through EQUIP_TYPE_MAP and TWO_HANDERS
--- @type table<WeaponType, string>
local WEAPONS_1H = { }
--- @type table<WeaponType, string>
local WEAPONS_2H = { }
-- These strings must match!
local TWO_HANDER_TO_CAT_NAME = {
	[false] = "One-Handed",
	[true] = "Two-Handed",
}
local EQUIP_TYPE_ORDER = {
	"One-Handed",
	"Two-Handed",
	"Armor",
	"Jewelry",
}
local EQUIP_TYPE_MAP = {
	["One-Handed"] = WEAPONS_1H,
	["Two-Handed"] = WEAPONS_2H,
	--- @type table<EquipType, string>
	["Armor"] = {},
	--- @type table<EquipType, string>
	["Jewelry"] = {},
}

-- This will also be populated by EquipFinder()
--- @type table<ArmorType, string>
local ARMOR_WEIGHTS = {}

local function EquipFinder()
	for t = EQUIP_TYPE_ITERATION_BEGIN, EQUIP_TYPE_ITERATION_END do
		local cat = EQUIP_TYPES[t]
		if cat and not cat:find("Weapon") then
			local str = GetString("SI_EQUIPTYPE", t)
			-- logger:Debug("%i: %s, %s", t, cat, str)
			EQUIP_TYPE_MAP[cat][t] = str
		end
	end
	for w = WEAPONTYPE_ITERATION_BEGIN, WEAPONTYPE_ITERATION_END do
		local str = GetString("SI_WEAPONTYPE", w)
		if str and str ~= "" and str ~= "do not translate" then
			if TWO_HANDERS[w] then
				WEAPONS_2H[w] = str
				str = "(2H) " .. str -- this is only for the logging
			else
				WEAPONS_1H[w] = str
			end
			-- logger:Debug("weapon %i: %s", w, str)
		end
	end
	for a = ARMORTYPE_ITERATION_BEGIN, ARMORTYPE_ITERATION_END do
		if a ~= ARMORTYPE_NONE then
			local str = GetString("SI_ARMORTYPE", a)
			if str and str ~= "" then
				ARMOR_WEIGHTS[a] = str
				-- logger:Debug("armor weight %i: %s", a, str)
			end
		end
	end
end
-- SLASH_COMMANDS["/allequips"] = EquipFinder

local function TraitFinder()
	-- GetItemTraitTypeCategory(ItemTraitType) Returns: ItemTraitTypeCategory
	--[[
	for cat = ITEM_TRAIT_TYPE_CATEGORY_ITERATION_BEGIN, ITEM_TRAIT_TYPE_CATEGORY_ITERATION_END do
		local info = GetString("SI_ITEMTRAITINFORMATION", cat)
		if info ~= nil and info ~= "" then
			logger:Warn("%i trait info: %s", cat, info)
		end

		local tag = GetString("SI_ITEMTAGCATEGORY", cat)
		if tag ~= nil and tag ~= "" then
			logger:Warn("%i tag category: %s", cat, tag)
		end

		local typ = GetString("SI_ITEMTYPE", cat)
		if typ ~= nil and typ ~= "" then
			logger:Warn("%i item type: %s", cat, typ)
		end

		local tcat = GetString("SI_ITEMTRAITTYPECATEGORY", cat)
		if tcat ~= nil and tcat ~= "" then
			logger:Warn("%i trait type category: %s", cat, tcat)
		end
	end
	]]

	for trait = ITEM_TRAIT_TYPE_ITERATION_BEGIN, ITEM_TRAIT_TYPE_ITERATION_END do
		local str = GetString("SI_ITEMTRAITTYPE", trait)
		TRAIT_NAMES[trait] = str

		local cat = nil
		if IS_COMPANION_TRAIT[trait] then
			if GetItemTraitTypeCategory(trait) == ITEM_TRAIT_TYPE_CATEGORY_ARMOR then
				cat = "Companion Gear"
			end
		else
			cat = TRAIT_CATEGORY_NAMES[GetItemTraitTypeCategory(trait)]
		end

		if cat then
			if TRAIT_MAP[cat] == nil then
				TRAIT_MAP[cat] = {}
			end

			-- logger:Debug("%i: %s, %s", trait, cat, str)
			TRAIT_MAP[cat][trait] = str
		end
	end
end
-- SLASH_COMMANDS["/alltraits"] = TraitFinder

local function Bool(b)
	if b then return true else return false end
end

local function CleanStr(str)
	return zo_strtrim(str)
end

-- Unlike filter.Name, this map also includes temporary names (e.g. keyword combos) and should not go in SavedVars
local filterNameMap = {}

local function UpdateFilterName(filter)
	local name = filter.Name or table.concat(filter.Keywords, ", ")
	filterNameMap[filter] = name
	return filter
end

local function ValidateFilter(filter)
	for k, v in pairs(FilteredLootTracker.FilterDefaults) do
		if filter[k] == nil then
			filter[k] = deepcopy(v)
		end
	end

	if filter.Weights == nil then
		filter.Weights = ListToSet(ARMOR_WEIGHTS)
	end
	for k, v in pairs(EQUIP_TYPE_MAP) do
		if filter.EquipTypes[k] == nil then
			filter.EquipTypes[k] = ListToSet(v)
		end
	end
	for k, v in pairs(TRAIT_MAP) do
		if filter.Traits[k] == nil then
			filter.Traits[k] = ListToSet(v)
		end
	end
	return UpdateFilterName(filter)
end

local function NewFilter()
	return ValidateFilter({})
end

local function CopyOfCurrentFilter()
	local filter = ValidateFilter(FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter])
	local newFilter = deepcopy(filter)
	-- if filter.Name then newFilter.Name = string.format("%s copy", filter.Name) end
	return UpdateFilterName(newFilter)
end

local function AddTraitSelector(optionsData, Cat)
	--- @type LAM2_MultiSelectDropdownData
	local comp = {
		type = "dropdown",
		name = Cat .. " traits",
		width = "half",
		choices = OrderedValues(TRAIT_MAP[Cat]),
		sort = "name-up",
		multiSelect = true,
		-- dataType = "set",
		multiSelectTextFormatter = "<<1[$d Trait/$d Traits]>>",
		multiSelectNoSelectionText = "No Traits Selected",

		disabled = function()
			return not FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].UseTraits
		end,
		getFunc = function()
			local ret = SetToList(FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Traits[Cat])
			-- logger:Info(Cat .. " traits get ", #ret)
			return ret
		end,
		setFunc = function(Traits)
			-- logger:Info(Cat .. " traits set ", #Traits)
			FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Traits[Cat] = ListToSet(Traits)
		end,
	}
	optionsData[#optionsData + 1] = comp
end

local function AddEquipTypeSelector(optionsData, Cat)
	local comp = {
		type = "dropdown",
		name = Cat,
		width = "half",
		choices = OrderedValues(EQUIP_TYPE_MAP[Cat]),
		-- sort = "name-down",
		multiSelect = true,
		-- dataType = "set",
		multiSelectTextFormatter = "<<1>> Selected",

		disabled = function()
			return not FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].UseEquipTypes
		end,
		getFunc = function()
			local ret = SetToList(FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].EquipTypes[Cat])
			-- logger:Info(Cat, "get", #ret)
			return ret
		end,
		setFunc = function(EquipTypes)
			-- logger:Info(Cat, "set", #EquipTypes)
			FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].EquipTypes[Cat] = ListToSet(EquipTypes)
		end,
	}
	optionsData[#optionsData + 1] = comp
end

--- EVENT_LOOT_RECEIVED helpers

local function MatchesKeywords(name, keywords)
	name = string.lower(name)
	if next(keywords) == nil then
		return true
	end
	for _, k in ipairs(keywords) do
		if string.find(name, k)~= nil then
			return true
		end
	end
	return false
end

local function GetTraitCategoryName(itemLink)
	if IS_COMPANION_TRAIT[GetItemLinkTraitType(itemLink)] then
		return "Companion Gear"
	end
	return TRAIT_CATEGORY_NAMES[GetItemLinkTraitCategory(itemLink)]
end

local function GetItemLinkTraitInfo(itemLink)
	local traitType = GetItemLinkTraitType(itemLink)
	local traitName = TRAIT_NAMES[traitType]
	return traitName, traitType
end

local function FilterMatch(filter, filterNum, itemLink)
	if not filter.Enabled then return false end

	-- unique check
	if filter.Uniques and not IsItemLinkUnique(itemLink) then
		logger:Debug("Filter %i: rejecting %s because it is not unique-named!", filterNum, itemLink)
		return false
	end

	-- "needed for stickerbook (set collection)" check
	if filter.NeededForCollection then
		if not IsItemLinkSetCollectionPiece(itemLink)
		or IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)) then
			logger:Debug("Filter %i: rejecting %s because it is not needed for your set collection!", filterNum, itemLink)
			return false
		end
	end

	-- quality check
	local targetQuality = QUALITY_NAME_TO_ID[filter.Quality]
	if GetItemLinkFunctionalQuality(itemLink) < targetQuality then
		logger:Debug("Filter %i: rejecting %s due to quality!", filterNum, itemLink)
		return false
	end

	-- trait check
	if filter.UseTraits then
		local cat = GetTraitCategoryName(itemLink)
		local traitName = GetItemLinkTraitInfo(itemLink)
		if not cat
		or not filter.Traits[cat]
		or not filter.Traits[cat][traitName] then
			logger:Debug("Filter %i: rejecting %s due to trait!", filterNum, itemLink)
			return false
		end
	end

	-- equipment type check
	if filter.UseEquipTypes then
		local equipType = GetItemLinkEquipType(itemLink)
		local cat = EQUIP_TYPES[equipType]
		if not cat then
			logger:Debug("Filter %i: rejecting %s due to lack of equip type!", filterNum, itemLink)
			return false
		end
		if cat == "Weapon" then
			local weaponType = GetItemLinkWeaponType(itemLink)
			local weaponCat = TWO_HANDER_TO_CAT_NAME[TWO_HANDERS[weaponType] or false]
			local weaponTypeName = EQUIP_TYPE_MAP[weaponCat][weaponType]
			if not filter.EquipTypes[weaponCat]
			or not filter.EquipTypes[weaponCat][weaponTypeName] then
				logger:Debug("Filter %i: rejecting %s due to weapon type!", filterNum, itemLink)
				return false
			end
		else
			local equipTypeName = EQUIP_TYPE_MAP[cat][equipType]
			if not filter.EquipTypes[cat]
			or not filter.EquipTypes[cat][equipTypeName] then
				logger:Debug("Filter %i: rejecting %s due to equip type!", filterNum, itemLink)
				return false
			end
		end

		local armorWeight = GetItemLinkArmorType(itemLink)
		local armorWeightName = ARMOR_WEIGHTS[armorWeight]
		if armorWeightName
		and not filter.Weights[armorWeightName] then
			logger:Debug("Filter %i: rejecting %s due to armor weight!", filterNum, itemLink)
			return false
		end
	end

	local name = GetItemLinkName(itemLink)
	-- keyword check
	if not MatchesKeywords(name, filter.Keywords) then
		local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
		if not (hasSet and MatchesKeywords(setName, filter.Keywords)) then
			if hasSet then logger:Debug(setName) end
			logger:Debug("Filter %i: rejecting %s due to keywords!", filterNum, itemLink)
			return false
		else
			logger:Info("Filter %i: rescued link %s from keyword failure using set name %s!", filterNum, itemLink, setName)
		end
	end
	-- ALL CHECKS PASSED
	logger:Debug("Filter %i: item link %s passed all checks!", filterNum, itemLink)
	return true
end

local function IsInGroupedInstance()
	return IsUnitGrouped("player") and GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_NONE
end

local function RemoveSwitches(msg)
	msg = CleanStr(msg)
	local switch, valid, switchArg, deferredError, targetEnd = ZO_GetChatSystem():TextToSwitchData(msg, false)
	if switch then
		if not valid then
			return nil
		end
		if deferredError then
			local err = switch.requirementErrorMessage
			if type(err) == "function" then
				err = err()
			end
			print(err)
		end
		if targetEnd then
			logger.Info('Fixing "%s" to "%s"', msg, msg:sub(targetEnd))
			return msg:sub(targetEnd)
		end
	end
	return msg
end

local function FixSavedVarTemplate(tbl, key)
	local fixed = RemoveSwitches(tbl[key])
	if not fixed then
		print(string.format("Reseting invalid SavedVar %s to default", key))
		fixed = FilteredLootTracker.Defaults[key]
	elseif fixed ~= tbl[key] then
		print(string.format('Fixing SavedVar %s ("%s") to "%s"!', key, tbl[key], fixed))
	end
	tbl[key] = fixed
	return fixed
end

local function MultiLineChatInput(msgs)
	if IsInGroupedInstance() then
		StartChatInput(msgs[1], CHAT_CHANNEL_PARTY)
	else
		StartChatInput(msgs[1])
	end
	if #msgs == 1 then return end
	--- @param text string
	--- @param fromDisplayName string
	local function OnChatMessage(eventId, channelType, fromName, text, isCustomerService, fromDisplayName)
		if text == msgs[1] and (channelType == CHAT_CHANNEL_WHISPER_SENT or fromDisplayName == GetDisplayName()) then
			table.remove(msgs, 1)
			if #msgs > 0 then
				StartChatInput(msgs[1])
			else
				EVENT_MANAGER:UnregisterForEvent(FilteredLootTracker.name, EVENT_CHAT_MESSAGE_CHANNEL)
			end
		end
	end
	EVENT_MANAGER:UnregisterForEvent(FilteredLootTracker.name, EVENT_CHAT_MESSAGE_CHANNEL)
	EVENT_MANAGER:RegisterForEvent(FilteredLootTracker.name, EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)
end

--- @param filt string
--- @param bindType BindType?
local function OfferLoot(filt, bindType)
	local keywords = {zo_strsplit(",", string.lower(filt))}
	for k, v in pairs(keywords) do
		keywords[k] = string.gsub(CleanStr(v), "%s+", " ")
	end
	logger:Debug(keywords)

	local links = {}
	local msgs = {}

	local function getMessage()
		local combined = table.concat(links, "")
		if #msgs < 1 then
			return zo_strformat(FixSavedVarTemplate(FilteredLootTracker.Vars, "MultiOfferTemplate"), combined)
		end
		return combined
	end

	for slotIndex = 1, GetBagSize(BAG_BACKPACK) do
		local wanted = false
		local itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_BRACKETS)
		if not IsItemBound(BAG_BACKPACK, slotIndex) then
			-- IsItemBoPAndTradeable(bagId, slotIndex)
			if (bindType == nil) or (GetItemLinkBindType(itemLink) == bindType) then
				-- don't want to offer up loot the user wants
				for k, filter in ipairs(FilteredLootTracker.Vars.Filters) do
					if FilterMatch(filter, k, itemLink) then
						logger:Debug("%s(%s, %s) rejected due to matching filter %d", itemLink, GetItemLinkName(itemLink), TRAIT_NAMES[GetItemLinkTraitType(itemLink)], k);
						wanted = true
						break
					end
				end
				if not wanted then
					local name = GetItemLinkName(itemLink)
					local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
					if MatchesKeywords(name, keywords) or (hasSet and MatchesKeywords(setName, keywords)) then
						if #links >= 5 then
							table.insert(msgs, getMessage())
							links = {}
						end
						table.insert(links, itemLink)
					end
				end
			else
				logger:Debug("%s(%s, %s) rejected due to not matching bind type %d", itemLink, GetItemLinkName(itemLink), TRAIT_NAMES[GetItemLinkTraitType(itemLink)], bindType)
			end
		end
	end
	if #links > 0 then
		table.insert(msgs, getMessage())
	end
	if #msgs <= 0 then
		print("No loot to share!")
	else
		MultiLineChatInput(msgs)
	end
end

local function AddonSettings()
	--- @type LAM2_PanelData
	local panelData = {
		type = "panel",
		name = "Filtered Loot Tracker",
		author = "@MycroftJr",
		version = "1.0",
		slashCommand = "/flt",
		website = "https://www.esoui.com/downloads/info3932-FilteredLootTracker.html",
		feedback = "https://www.esoui.com/portal.php?id=397&a=bugreport",
		registerForRefresh = true,
		registerForDefaults = false,
	}

	local LAM = LibAddonMenu2
	local name = FilteredLootTracker.name .. "Options"
	local panel = LAM:RegisterAddonPanel(name, panelData)
	local openPanel = SLASH_COMMANDS["/flt"]

	local LSC = LibSlashCommander
	local command = LSC:Register("/flt", function(extra) openPanel() end, "The base FilteredLootTracker command. Opens the addon's settings menu.")

	local offer = command:RegisterSubCommand()
	offer:AddAlias("offer")
	offer:SetCallback(function(extra)
		if string.len(extra) >= 1 then
			OfferLoot(extra)
		else
			print("When using /flt offer, the keywords are not optional!")
		end
	end)
	offer:SetDescription("Offers all tradables you've looted that don't match your filters in chat. Requires a comma-separated keyword list to filter the offered items by.")

	local offerBoP = command:RegisterSubCommand()
	offerBoP:AddAlias("bop")
	offerBoP:SetCallback(function(extra)
		OfferLoot(extra, BIND_TYPE_ON_PICKUP)
	end)
	offerBoP:SetDescription("Offers all Bind-on-pickup tradables you've looted that don't match your filters in chat. Optionally followed by a comma-separated keyword list to filter the offered items by.")

	local offerBoE = command:RegisterSubCommand()
	offerBoE:AddAlias("boe")
	offerBoE:SetCallback(function(extra)
		OfferLoot(extra, BIND_TYPE_ON_EQUIP)
	end)
	offerBoE:SetDescription("Offers all Bind-on-Equip tradables you've looted that don't match your filters in chat. Optionally followed by a comma-separated keyword list to filter the offered items by.")

	local perf = command:RegisterSubCommand()
	perf:AddAlias("perf")
	perf:SetCallback(function()
		OfferLoot("Perfected")
	end)
	perf:SetDescription("Offers all Perfected gear you've looted that doesn't match your filters in chat.")

	--- @type LAM2_ControlData[]
	local optionsData = {}

	optionsData[#optionsData + 1] = {
		type = "header",
		name = "Basic",
		width = "full",
	}
	--- @type LAM2_CheckboxData
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = "Enable addon",
		-- tooltip = "",
		width = "full",

		getFunc = function()
			return FilteredLootTracker.Vars.Loot
		end,

		setFunc = function(Loot)
			FilteredLootTracker.Vars.Loot = Loot
		end,
	}
	--- @type LAM2_CheckboxData
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = "Icons",
		tooltip = "Show item icons in the output.",

		getFunc = function()
			return FilteredLootTracker.Vars.Icons
		end,
		setFunc = function(Icons)
			FilteredLootTracker.Vars.Icons = Icons
		end,
	}
	--- @type LAM2_CheckboxData
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = "Timestamps",
		tooltip = "Show timestamps in the output.",

		getFunc = function()
			return FilteredLootTracker.Vars.Time
		end,
		setFunc = function(Time)
			FilteredLootTracker.Vars.Time = Time
		end,
	}

	optionsData[#optionsData + 1] = {
		type = "header",
		name = "Filters",
		width = "full",
	}
	--- @type LAM2_CheckboxData
	optionsData[#optionsData + 1] = {
		type = "checkbox",
		name = "Group loot",
		tooltip = "Include the loot of group members in your results?",
		width = "full",

		getFunc = function()
			return FilteredLootTracker.Vars.Group
		end,
		setFunc = function(Group)
			FilteredLootTracker.Vars.Group = Group
		end,
	}

	local qualityChoices = { }
	local qualityValues = { }
	for q = ITEM_DISPLAY_QUALITY_ITERATION_BEGIN, ITEM_DISPLAY_QUALITY_ITERATION_END do
		local str = GetString("SI_ITEMQUALITY", q)
		if str then
			local c = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, q))
			table.insert(qualityChoices, c:Colorize(str))
			table.insert(qualityValues, str)
			QUALITY_NAME_TO_ID[str] = q
		end
	end

	for _, filter in pairs(FilteredLootTracker.Vars.Filters) do
		UpdateFilterName(filter)
	end
	--- @type LAM2_SingleSelectDropdownData
	local filterDropdown = {
		type = "dropdown",
		name = "Current filter",
		choices = {},
		tooltip = "The filter to show/copy/delete below.",
		reference = FilteredLootTracker.name .. "FilterSelect",
		width = "half",
		scrollable = 25,

		getFunc = function()
			return FilteredLootTracker.CurrentFilter
		end,
		--- @param Filter integer
		setFunc = function(Filter)
			FilteredLootTracker.CurrentFilter = Filter
		end,
	}
	--- @type LAM2_MultiSelectDropdownData
	local filterMultiselect = {
		type = "dropdown",
		name = "Enabled filters",
		tooltip = "Only the selected filters will be used for loot matching.",
		reference = FilteredLootTracker.name .. "FilterMultiselect",
		choices = {},
		width = "half",
		scrollable = 25,
		multiSelect = true,
		-- dataType = "set",
		multiSelectTextFormatter = "<<1[$d Filter/$d Filters]>>",
		multiSelectNoSelectionText = "No Filters Selected",

		-- was filter#, true; now {filter#s}
		getFunc = function()
			local selected = {}
			for i, filter in ipairs(FilteredLootTracker.Vars.Filters) do
				if filter.Enabled then table.insert(selected, i) end
			end
			-- logger:Info("FilteredLootTrackerFilterMultiselect get:", dump(selected))
			return selected
		end,
		setFunc = function(value)
			value = ListToSet(value)
			for i, filter in ipairs(FilteredLootTracker.Vars.Filters) do
				filter.Enabled = Bool(value[i])
			end
		end,
	}

	local function UpdateFilterChoices()
		local function UpdateFilterChoicesInternal(controlData, control)
			controlData.choices = { }
			controlData.choicesValues = { }
			for k, filter in ipairs(FilteredLootTracker.Vars.Filters) do
				local filter_name = filterNameMap[filter]
				local label = string.format("%i: %s", k, filter_name)
				table.insert(controlData.choices, label)
				table.insert(controlData.choicesValues, k)
			end
			if control ~= nil then
				control:UpdateChoices(controlData.choices, controlData.choicesValues, controlData.choicesTooltips)
			end
		end
		UpdateFilterChoicesInternal(filterDropdown, FilteredLootTrackerFilterSelect)
		UpdateFilterChoicesInternal(filterMultiselect, FilteredLootTrackerFilterMultiselect)
	end
	UpdateFilterChoices()

	optionsData[#optionsData + 1] = filterDropdown
	optionsData[#optionsData + 1] = filterMultiselect

	local filterControls = optionsData -- {}
	--- @type LAM2_ButtonData
	filterControls[#filterControls + 1] = {
		type = "button",
		name = "New filter",
		width = "half",

		func = function()
			local newFilter = NewFilter()
			table.insert(FilteredLootTracker.Vars.Filters, newFilter)
			FilteredLootTracker.CurrentFilter = #FilteredLootTracker.Vars.Filters
			-- TODO: put typing cursor in Name editbox?
			UpdateFilterChoices()
		end,
	}
	--- @type LAM2_ButtonData
	filterControls[#filterControls + 1] = {
		type = "button",
		name = "Copy filter",
		width = "half",

		func = function()
			local newFilter = CopyOfCurrentFilter()
			FilteredLootTracker.CurrentFilter = FilteredLootTracker.CurrentFilter + 1
			table.insert(FilteredLootTracker.Vars.Filters, FilteredLootTracker.CurrentFilter, newFilter)
			UpdateFilterChoices()
		end,
	}
	--- @type LAM2_ButtonData
	filterControls[#filterControls + 1] = {
		type = "button",
		name = "Delete filter",
		width = "half",
		isDangerous = true,
		warning = function()
			local filter = FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter]
			local s = filter.Name and string.format(' ("%s")', filter.Name)
			if not s and #filter.Keywords > 0 then
				s = string.format(" (with keywords {%s})", table.concat(filter.Keywords, ", "))
			end
			return string.format("Are you sure you want to delete filter #%i%s?", FilteredLootTracker.CurrentFilter, s or "")
		end,

		disabled = function()
			return #FilteredLootTracker.Vars.Filters <= 1
		end,

		func = function()
			filterNameMap[table.remove(FilteredLootTracker.Vars.Filters, FilteredLootTracker.CurrentFilter)] = nil
			FilteredLootTracker.CurrentFilter = math.min(FilteredLootTracker.CurrentFilter, #FilteredLootTracker.Vars.Filters)
			UpdateFilterChoices()
		end,
	}
	--- @type LAM2_EditboxData
	filterControls[#filterControls + 1] = {
		type = "editbox",
		name = "Move to slot",
		reference = FilteredLootTracker.name .. "FilterMover",
		textType = TEXT_TYPE_NUMERIC,
		width = "half",

		getFunc = function()
			return ""
		end,

		setFunc = function(text)
			FilteredLootTrackerFilterMover:UpdateValue() -- clear the editbox
			text = CleanStr(text)
			if text == "" then return end
			local Slot = tointeger(text)
			if Slot < 1 or Slot > #FilteredLootTracker.Vars.Filters then
				-- TODO: show in popup instead?
				printf("Cannot move filter to slot %i! Please enter a number between 1 and %i.",
					Slot, #FilteredLootTracker.Vars.Filters)
				return
			end
			if Slot ~= FilteredLootTracker.CurrentFilter then
				local filter = table.remove(FilteredLootTracker.Vars.Filters, FilteredLootTracker.CurrentFilter)
				table.insert(FilteredLootTracker.Vars.Filters, Slot, filter)
				FilteredLootTracker.CurrentFilter = Slot
				UpdateFilterChoices()
			end
		end,
	}
	
	optionsData[#optionsData + 1] = {
		type = "header",
		name = "Filter Contents",
		width = "full",
	}
	--- @type LAM2_EditboxData
	filterControls[#filterControls + 1] = {
		type = "editbox",
		name = "Filter name",
		reference = FilteredLootTracker.name .. "FilterName",
		tooltip = "A name for you to remember this filter by.",
		isMultiline = false,
		isExtraWide = true,
		width = "full",

		-- TODO: default visual contents to keywords?
		getFunc = function()
			return FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Name
		end,

		setFunc = function(text)
			text = CleanStr(text)
			if text == "" then
				text = nil
			end
			if FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Name ~= text then
				FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Name = text
				UpdateFilterName(FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter])
				UpdateFilterChoices()
			end
		end,
	}
	--- @type LAM2_EditboxData
	filterControls[#filterControls + 1] = {
		type = "editbox",
		name = "Keywords (comma-separated)",
		tooltip = "If given, the item's name or set name must contain at least one keyword/phrase.",
		isMultiline = false,
		isExtraWide = true,
		width = "full",

		getFunc = function()
			return table.concat(FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Keywords, ", ")
		end,

		setFunc = function(text)
			local x = ""

			if FilteredLootTracker.Vars.Time then
				x = zo_strformat("[<<1>>] ",
					string.sub(GetTimeString(), 0.0, 5.0))
			end
			local keywords = {zo_strsplit(",", string.lower(text))}
			for k, v in pairs(keywords) do
				keywords[k] = string.gsub(CleanStr(v), "%s+", " ")
			end

			if #keywords > 0 then
				logger:Debug(zo_strformat("<<1>>Tracking items with keyword(s): {<<2>>}.", x, table.concat(keywords, ", ")))
			else
				logger:Debug(zo_strformat("<<1>>No longer tracking items with keyword(s).", x))
			end

			local filter = FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter]
			filter.Keywords = keywords
			if not filter.Name then
				UpdateFilterName(filter)
				UpdateFilterChoices()
			end
		end,
	}
	--- @type LAM2_CheckboxData
	filterControls[#filterControls + 1] = {
		type = "checkbox",
		name = "Only unique-named items",
		width = "half",

		getFunc = function()
			return FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Uniques
		end,
		setFunc = function(Uniques)
			FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Uniques = Uniques
		end,
	}
	--- @type LAM2_CheckboxData
	filterControls[#filterControls + 1] = {
		type = "checkbox",
		name = "Only set collection unlocks",
		tooltip = "Should the filter only allow items needed for your set collection?",
		width = "half",

		getFunc = function()
			return FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].NeededForCollection
		end,
		setFunc = function(NeededForCollection)
			FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].NeededForCollection = NeededForCollection
		end,
	}
	--- @type LAM2_SingleSelectDropdownData
	filterControls[#filterControls + 1] = {
		type = "dropdown",
		name = "Minimum quality",
		-- tooltip = "",
		width = "full",

		choices = qualityChoices,
		choicesValues = qualityValues,

		getFunc = function()
			return FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Quality
		end,
		--- @param Quality string
		setFunc = function(Quality)
			FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Quality = Quality
		end,
	}
	--- @type LAM2_DividerData
	filterControls[#filterControls + 1] = {
		type = "divider",
	}
	--- @type LAM2_CheckboxData
	filterControls[#filterControls + 1] = {
		type = "checkbox",
		name = "Filter by equipment type",
		width = "half",

		getFunc = function()
			return FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].UseEquipTypes
		end,
		setFunc = function(UseEquipTypes)
			FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].UseEquipTypes = UseEquipTypes
		end,
	}
	--- @type LAM2_MultiSelectDropdownData
	filterControls[#filterControls + 1] = {
		type = "dropdown",
		name = "Armor weights",
		tooltips = "Will only filter items that have armor weights",
		width = "half",
		choices = OrderedValues(ARMOR_WEIGHTS),
		multiSelect = true,
		-- dataType = "set",
		multiSelectTextFormatter = "<<1[$d Weight/$d Weights]>>",
		multiSelectNoSelectionText = "No Weights Selected",

		disabled = function()
			return not FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].UseEquipTypes
		end,
		getFunc = function()
			-- logger:Info("Armor weights get")
			-- logger:Info(dump(FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Weights))
			local ret = SetToList(FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Weights)
			-- logger:Info("to", dump(ret))
			return ret
		end,
		setFunc = function(Weights)
			-- logger:Info("Armor weights set")
			-- logger:Info(dump(Weights))
			FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Weights = ListToSet(Weights)
			-- logger:Info("to", dump(FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].Weights))
		end,
	}

	-- Make all of the equipment type multiselects
	for _, v in ipairs(EQUIP_TYPE_ORDER) do
		AddEquipTypeSelector(filterControls, v)
	end

	filterControls[#filterControls + 1] = {
		type = "divider",
	}
	--- @type LAM2_CheckboxData
	filterControls[#filterControls + 1] = {
		type = "checkbox",
		name = "Filter by traits",
		width = "half",

		getFunc = function()
			return FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].UseTraits
		end,
		setFunc = function(UseTraits)
			FilteredLootTracker.Vars.Filters[FilteredLootTracker.CurrentFilter].UseTraits = UseTraits
		end,
	}

	-- Make all of the trait multiselects
	for k, v in pairs(TRAIT_CATEGORY_NAMES) do
		AddTraitSelector(filterControls, v)
	end
	AddTraitSelector(filterControls, "Companion Gear")

	--[[
	--- @type LAM2_SubmenuData
	optionsData[#optionsData + 1] = {
		type = "submenu",
		name = "Selected Filter Settings",
		reference = FilteredLootTracker.name .. "FilterSubmenu",
		choices = filterControls,
		disabled = function()
			return true iff 0 or 2+ filters are selected
			also, "spring open" whenever not disabled?
		end,
	}
	]]

	optionsData[#optionsData + 1] = {
		type = "header",
		name = "Advanced",
		width = "full",
	}
	--- @type LAM2_EditboxData
	optionsData[#optionsData + 1] = {
		type = "editbox",
		name = "Offer item template",
		tooltip = '/p will be added automatically in grouped instances. Example: "Anybody need <<1>>?"',
		helpUrl = zo_strformat_helpUrl,
		isExtraWide = true,

		getFunc = function()
			return FilteredLootTracker.Vars.OfferTemplate
		end,

		setFunc = function(text)
			FilteredLootTracker.Vars.OfferTemplate = CleanStr(text)
		end,

		warning = function()
			local text = CleanStr(FilteredLootTracker.Vars.OfferTemplate)
			if text:sub(0, 3) == "/p " then
				return "It is recommended that you do not use /p as it will be added automatically!"
			end
			return nil
		end
	}
	--- @type LAM2_EditboxData
	optionsData[#optionsData + 1] = {
		type = "editbox",
		name = "Beg item template",
		tooltip = 'e.g. "/w <<1>> You looted <<2>>, can I have it?"',
		helpUrl = zo_strformat_helpUrl,
		isExtraWide = true,

		getFunc = function()
			return FilteredLootTracker.Vars.BegTemplate
		end,

		setFunc = function(text)
			FilteredLootTracker.Vars.BegTemplate = CleanStr(text)
		end,
	}
	--- @type LAM2_EditboxData
	optionsData[#optionsData + 1] = {
		type = "editbox",
		name = "Ask item template",
		tooltip = "used when the item was linked in chat",
		helpUrl = zo_strformat_helpUrl,
		isExtraWide = true,

		getFunc = function()
			return FilteredLootTracker.Vars.AskTemplate
		end,

		setFunc = function(text)
			FilteredLootTracker.Vars.AskTemplate = CleanStr(text)
		end,
	}
	--- @type LAM2_EditboxData
	optionsData[#optionsData + 1] = {
		type = "editbox",
		name = "Multi-offer item template",
		tooltip = 'Do NOT use /p, etc. Example: "Anybody need these? <<1>>"',
		helpUrl = zo_strformat_helpUrl,
		isExtraWide = true,

		getFunc = function()
			return FixSavedVarTemplate(FilteredLootTracker.Vars, "MultiOfferTemplate")
		end,

		setFunc = function(text)
			FilteredLootTracker.Vars.MultiOfferTemplate = text
		end,

		warning = function()
			local text = FilteredLootTracker.Vars.MultiOfferTemplate
			local cleaned = RemoveSwitches(text) or FilteredLootTracker.Defaults.MultiOfferTemplate
			if cleaned ~= text then
				return string.format('Text is invalid (must not start with /p etc)! Currently, "%s" will be used instead.', cleaned)
			end
			return nil
		end
	}

	LAM:RegisterOptionControls(name, optionsData)

	local lamPanelCreationInitDone = false
	local function LAMControlsCreatedCallbackFunc(pPanel)
		if pPanel ~= panel then return end
		if lamPanelCreationInitDone == true then return end

		lamPanelCreationInitDone = true

		FilteredLootTrackerFilterSelect = FilteredLootTrackerFilterSelect
		FilteredLootTrackerFilterMultiselect = FilteredLootTrackerFilterMultiselect
		FilteredLootTrackerFilterMover = FilteredLootTrackerFilterMover
	end
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", LAMControlsCreatedCallbackFunc)
end

-- Formatting numbers:
-- http://lua-users.org/wiki/FormattingNumbers
local function comma_value(amount)
	local formatted = amount
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
	  	if k == 0 then
			break
	  	end
	end
	return formatted
end

FilteredLootTracker.GroupMemberMap = { }

--- EVENT_GROUP_MEMBER_JOINED
--- doesn't currently work correctly atm, see https://www.esoui.com/forums/showthread.php?t=9376
---@param eventCode number
---@param memberCharacterName string
---@param memberDisplayName string
---@param isLocalPlayer boolean
local function GroupMemberJoined(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
	memberCharacterName = zo_strformat(SI_UNIT_NAME, memberCharacterName)
	-- logger:Debug("GroupMemberJoined: %s, %s", memberCharacterName, memberDisplayName)
	FilteredLootTracker.GroupMemberMap[memberCharacterName] = memberDisplayName
end

--- EVENT_UNIT_CREATED
---@param eventCode number
---@param unitTag string
local function OnUnitCreated(eventCode, unitTag)
	if ZO_Group_IsGroupUnitTag(unitTag) then
		local memberCharacterName = GetUnitName(unitTag)
		local memberDisplayName = GetUnitDisplayName(unitTag)
		-- logger:Debug("GroupMemberJoined: %s, %s", memberCharacterName, memberDisplayName)
		FilteredLootTracker.GroupMemberMap[memberCharacterName] = memberDisplayName
	end
end

--- EVENT_GROUP_MEMBER_LEFT
---@param eventCode number
---@param memberCharacterName string
---@param reason GroupLeaveReason
---@param isLocalPlayer boolean
---@param isLeader boolean
---@param memberDisplayName string
---@param actionRequiredVote boolean
local function GroupMemberLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
	memberCharacterName = zo_strformat(SI_UNIT_NAME, memberCharacterName)
	-- logger:Debug("GroupMemberLeft: %s, %s", memberCharacterName, memberDisplayName)
	FilteredLootTracker.GroupMemberMap[memberCharacterName] = nil
end

-- this function courtesy of @Scootworks on https://app.gitter.im/#/room/#esoui_esoui:gitter.im, with minor changes
local NO_UNIT_TAG, NO_PLAYER_NAME = nil, nil
local function GetPlayerNames(receivedBy)
	local masterList = GROUP_LIST_MANAGER.masterList
	local receivedCharacterName = ZO_CachedStrFormat(SI_UNIT_NAME, receivedBy)

	local characterName
	for _, g in pairs(masterList) do
		characterName = ZO_CachedStrFormat(SI_UNIT_NAME, g.characterName)
		if characterName == receivedCharacterName then
			local displayName = ZO_CachedStrFormat(SI_PLAYER_NAME, g.displayName)
			FilteredLootTracker.GroupMemberMap[characterName] = displayName
			return displayName, characterName, g.unitTag
		end
	end
	logger:Debug(masterList)
	logger:Debug("receivedCharacterName: %s", receivedCharacterName)

	return NO_PLAYER_NAME, receivedBy, NO_UNIT_TAG
end

--- EVENT_LOOT_RECEIVED

local function LootReceived(eventCode, lootedBy, itemLink, quantity, itemSound, lootType, self, isPickpocketLoot, questItemIcon, itemId, isStolen)
	if FilteredLootTracker.Vars.Loot then
		-- TODO: GetItemLinkBindType(itemLink) == BIND_TYPE_ON_PICKUP or BIND_TYPE_ON_PICKUP_BACKPACK?
		local isTradable = not IsItemLinkBound(itemLink) and GetLinkType(itemLink) == LINK_TYPE_ITEM  -- itemLink is technically itemName and could be a lead name instead of a link
		if not isTradable and not self then
			logger:Debug("Rejecting %s because it is not tradable!", itemLink)
			return
		end

		local filterPassed = false
		for k, filter in ipairs(FilteredLootTracker.Vars.Filters) do
			if FilterMatch(filter, k, itemLink) then
				filterPassed = true
				break
			end
		end
		if not filterPassed then
			logger:Debug("%s passed no enabled filter(s)!", itemLink)
			return
		end

		local icon = GetItemLinkIcon(itemLink)
		local temp_Icon = ""
		if FilteredLootTracker.Vars.Icons then
			temp_Icon = zo_strformat("|t24:24:<<1>>|t", icon)
		end

		local x = ""
		local y = ""
		local z = ""

		if FilteredLootTracker.Vars.Time then
			x = zo_strformat("[<<1>>] ",
			string.sub(GetTimeString(), 0.0, 5.0))
		end

		local traitName, traitType = GetItemLinkTraitInfo(itemLink)
		if traitType > 0
		and traitName
		and traitName ~= "" then
			y = zo_strformat("(<<1>>)", traitName)
		end

		-- Print the item link
		itemLink = itemLink:gsub("^|H0", "|H1", 1)
		local unitName = ZO_CachedStrFormat(SI_UNIT_NAME, lootedBy)
		if self then
			if isTradable then
				-- this adds the Offer Item functionality, which is not useful if the item is not tradable
				itemLink = itemLink:gsub("|h.-|h$", ":at:You|h|h", 1)
			end
			local stackCountBackpack, stackCountBank, stackCountCraftBag = GetItemLinkStacks(itemLink)

			local item_total_count = ""

			if stackCountBackpack > 1.0 then
				item_total_count = zo_strformat("<<1>>(<<2>>)",
					item_total_count, comma_value(stackCountBackpack))
			end

			if stackCountBank > 1.0 then
				item_total_count = zo_strformat("<<1>>(<<2>>)",
					item_total_count, comma_value(stackCountBank))
			end

			if stackCountCraftBag > 1.0 then
				item_total_count = zo_strformat("<<1>>(|t24:24:esoui/art/tooltips/icon_craft_bag.dds|t <<2>>)",
					item_total_count, comma_value(stackCountCraftBag))
			end

			if quantity == 1.0 then
				z = zo_strformat("<<1>>You looted <<2>> <<3>> <<4>> <<5>>",
					x, temp_Icon, itemLink, y, item_total_count)
			else
				z = zo_strformat("<<1>>You looted <<2>> x <<3>> <<4>> <<5>> <<6>>",
					x, quantity, temp_Icon, itemLink, y, item_total_count)
			end
		elseif FilteredLootTracker.Vars.Group then
			local userID = FilteredLootTracker.GroupMemberMap[unitName]
			if userID == nil then
				userID = GetPlayerNames(lootedBy)
				if userID == nil then
					logger:Warn('Failed to get UserID for character name "%s"!', unitName)
					userID = lootedBy
				end
			end
			itemLink = itemLink:gsub("|h.-|h$", string.format(":at:%s|h|h", userID), 1)
			y = string.format("%s %i", y, GetItemLinkBindType(itemLink))
			if quantity == 1.0 then
				z = zo_strformat("<<1>><<2>> looted <<3>> <<4>> <<5>> <<6>>",
					x, ZO_LinkHandler_CreateDisplayNameLink(userID), temp_Icon, itemLink, y)
			else
				z = zo_strformat("<<1>><<2>> looted <<3>> x <<4>> <<5>> <<6>> <<7>>",
					x, ZO_LinkHandler_CreateDisplayNameLink(userID), quantity, temp_Icon, itemLink, y)
			end
		else
			logger:Debug("Rejecting %s due to Group setting.", itemLink)
		end

		if z ~= "" then
			print(z)
		end
	end
end

--- EVENT_PLAYER_ACTIVATED

-- Registers the formatMessage function.
-- Unregisters itself from the player activation event with the event manager.
local function OnPlayerActivated()
	EVENT_MANAGER:UnregisterForEvent(FilteredLootTracker.name, EVENT_PLAYER_ACTIVATED)

	-- to not step on GroupLootNotifier's toes, we use :at: instead of :by:
	local function GetLinkLooter(link)
		local looter = link:match("^|H%d:item:.-:at:([^:]*).-|h.-|h$")
		-- logger:Debug(tostring(link).." "..tostring(looter))
		return looter
	end

	local origFunc = ZO_LinkHandler_OnLinkMouseUp
	ZO_LinkHandler_OnLinkMouseUp = function(link, mouseButton, control)
	--local function OnLinkClicked(link, mouseButton, control, color, linkType, lineNumber, chanCode)
		origFunc(link, mouseButton, control)
		local looter = GetLinkLooter(link)
		if not looter or mouseButton ~= MOUSE_BUTTON_INDEX_RIGHT then return end
		link = link:gsub(":at:[^|:]+", "", 1)  -- to be nice to the receiver's addons, un-modify the link before sharing

		if looter == "You" then
			local traitName, trait = GetItemLinkTraitInfo(link)
			if trait ~= 0 then
				link = string.format("%s (%s)", link, GetString("SI_ITEMTRAITTYPE", trait))
			end
			AddMenuItem("Offer item", function()
				local msg = zo_strformat(FilteredLootTracker.Vars.OfferTemplate, link)
				if IsInGroupedInstance() then
					StartChatInput(msg, CHAT_CHANNEL_PARTY)
				else
					StartChatInput(msg)
				end
			end)
		else
			-- see "ChatMessageFormatter"
			if looter:sub(1, 1) == "?" then
				looter = looter:sub(2)
				AddMenuItem("Ask for item", function() StartChatInput(zo_strformat(FilteredLootTracker.Vars.AskTemplate, looter, link)) end)
			else
				AddMenuItem("Beg for item", function() StartChatInput(zo_strformat(FilteredLootTracker.Vars.BegTemplate, looter, link)) end)
			end
		end
		ShowMenu(control)
	end
	-- LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, OnLinkClicked)

	-- Add an "Ask for item" context option to all links posted by anyone (thanks to pChat & SetCollectionMarker for the how):
	zo_callLater(function ()
		local originalFormatter = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
		-- (number eventCode, MsgChannelType channelType, string fromName, string text, boolean isCustomerService, string fromDisplayName)
		local function ChatMessageFormatter(channelType, fromName, text, isCustomerService, fromDisplayName)
			local saveTarget, tempText
			if originalFormatter then
				tempText, saveTarget = originalFormatter(channelType, fromName, text, isCustomerService, fromDisplayName)
				if not tempText then
					local origFormatter = originalFormatter
					logger:Error("originalFormatter returned nil!", debug.traceback())
				end
				text = tempText
			end
			if not text then return end
			if not saveTarget then
				local ChanInfoArray = ZO_ChatSystem_GetChannelInfo()
				local info = ChanInfoArray[channelType]
				saveTarget = info.saveTarget
			end

			if fromDisplayName then
				text = text:gsub("|H%d:item:.-|h.-|h", function(link)
					if IsItemLinkBound(link) then
						return link
					end
					local _, count = link:gsub(":", ":")
					if count ~= 22 then
						logger:Warn('Link formatter got link "%s" ?!', link:sub(4,-5))
					end
					if fromDisplayName == GetDisplayName() then
						return link:gsub("|h.-|h$", string.format(":at:You|h|h", fromDisplayName), 1)
					else
						return link:gsub("|h.-|h$", string.format(":at:?%s|h|h", fromDisplayName), 1)
					end
				end)
			end

			return text, saveTarget
		end
		CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, ChatMessageFormatter)
	end, 1000)
end

--- EVENT_ADD_ON_LOADED

local function AddOnLoaded(event, addonName)
	if addonName ~= FilteredLootTracker.name then return end

	EVENT_MANAGER:UnregisterForEvent(FilteredLootTracker.name, EVENT_ADD_ON_LOADED)
	FilteredLootTracker.LockWindow = true

	TraitFinder()
	EquipFinder()

	FilteredLootTracker.Vars = ZO_SavedVars:NewAccountWide(FilteredLootTracker.name .. "_Data", FilteredLootTracker.variableVersion, nil, FilteredLootTracker.Defaults) --[[@as Vars]]
	FilteredLootTracker.Vars.Filters = FilteredLootTracker.Vars.Filters or {}
	if #FilteredLootTracker.Vars.Filters < 1 then
		table.insert(FilteredLootTracker.Vars.Filters, NewFilter())
	else
		for _, filter in ipairs(FilteredLootTracker.Vars.Filters) do
			ValidateFilter(filter)
		end
	end

	AddonSettings()

	EVENT_MANAGER:RegisterForEvent(FilteredLootTracker.name, EVENT_LOOT_RECEIVED, LootReceived)
	EVENT_MANAGER:RegisterForEvent(FilteredLootTracker.name, EVENT_GROUP_MEMBER_JOINED, GroupMemberJoined)
	EVENT_MANAGER:RegisterForEvent(FilteredLootTracker.name, EVENT_UNIT_CREATED, OnUnitCreated)
	EVENT_MANAGER:RegisterForEvent(FilteredLootTracker.name, EVENT_GROUP_MEMBER_LEFT, GroupMemberLeft)
	-- because apparently the Chat doesn't intialize until EVENT_ADDON_LOADED is over
	EVENT_MANAGER:RegisterForEvent(FilteredLootTracker.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

-- TODO: submit this as a patch to the red/yellow square addon instead
ZO_PreHook("ZO_UpdateTraitInformationControlIcon", function(inventorySlot, slotData)
	local traitInfoControl = inventorySlot:GetNamedChild("TraitInfo")

	traitInfoControl:ClearIcons()

	if slotData.traitInformation == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED then
	  return true --prevent original function call to ZO_UpdateTraitInformationControlIcon
	end
end)

EVENT_MANAGER:RegisterForEvent(FilteredLootTracker.name, EVENT_ADD_ON_LOADED, AddOnLoaded)
