--[[
-------------------------------------------------------------------------------
-- Autobanker, made by r4cken + updated by Muffins714
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at :
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

This AddOn has taken inspiration and small snippets from Dustman by Ayantir, Garkin & iFedix
]]

-- Dependencies
-- local LAM = LibAddonMenu2
local LR = LibResearch
local autobankerInitializeColor = "EFFBBE"

-- Create the namespace for AB, top-level table
if AB == nil then AB = {} end
-- Holds our SavedVariable data
AB.GlobalSavedVars = AB.GlobalSavedVars or {}
AB.SavedVars = AB.SavedVars or {}

-- AddOn information
AB.name = "Autobanker"
AB.version = "2.5"
AB.author = "r4cken + updated by Muffins714"
AB.website = "https://www.esoui.com/downloads/info2199-AutobankerAutomaticallydeposititems.html"

-- Default values for saved vars
local defaults = {
	-- Manual or Automatic deposits
	automaticTransfers = false,
	useGlobalSettings = true,
	typesToDeposit = {
		[ITEMTYPE_POTION_BASE] = false,
		[ITEMTYPE_POISON_BASE] = false,
		[ITEMTYPE_INGREDIENT] = false,
		[ITEMTYPE_STYLE_MATERIAL] = false,
		[ITEMTYPE_FOOD] = false,
		[ITEMTYPE_DRINK] = false,
		[ITEMTYPE_TREASURE] = false,
		[ITEMTYPE_LOCKPICK] = false,
		[ITEMTYPE_FURNISHING_MATERIAL] = false,
		[ITEMTYPE_MASTER_WRIT] = false,
		[ITEMTYPE_POTION] = false,
		[ITEMTYPE_POISON] = false,
		[ITEMTYPE_CRAFTED_ABILITY_SCRIPT] = false,
		[ITEMTYPE_FURNISHING] = false,
		[ITEMTYPE_CROWN_ITEM] = false,
		[ITEMTYPE_SIEGE] = false,
		[ITEMTYPE_AVA_REPAIR] = false,
		[ITEMTYPE_RECALL_STONE] = false,
		[ITEMTYPE_BLACKSMITHING_MATERIAL] = false,
		[ITEMTYPE_CLOTHIER_MATERIAL] = false,
		[ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = false,
		[ITEMTYPE_WOODWORKING_MATERIAL] = false,
		[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = false,
		[ITEMTYPE_CLOTHIER_RAW_MATERIAL] = false,
		[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = false,
		[ITEMTYPE_WOODWORKING_RAW_MATERIAL] = false,
		[ITEMTYPE_BLACKSMITHING_BOOSTER] = false,
		[ITEMTYPE_CLOTHIER_BOOSTER] = false,
		[ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = false,
		[ITEMTYPE_WOODWORKING_BOOSTER] = false,
		[ITEMTYPE_ARMOR_TRAIT] = false,
		[ITEMTYPE_JEWELRY_TRAIT] = false,
		[ITEMTYPE_WEAPON_TRAIT] = false,
		[ITEMTYPE_REAGENT] = false,
		[ITEMTYPE_ENCHANTING_RUNE_ASPECT] = false,
		[ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = false,
		[ITEMTYPE_ENCHANTING_RUNE_POTENCY] = false,
		[ITEMTYPE_SCRIBING_INK] = false,
		--	[ITEMTYPE_GROUP_REPAIR] = false,
	},

	depositFilledSoulGems = false,
	depositEmptySoulGems = false,
	depositRepairKits = false,
	-- Specific Ids
	itemIdsToDeposit = {
		-- Unknown Writs
		[217917] = false, -- BlackSmithing
		[217918] = false, -- Clothier
		[217923] = false, -- Jewelry
		[217919] = false, -- Woodworking
		[217922] = false, -- Alchemy
		[217920] = false, -- Enchanting
		[217921] = false, -- Provisioning
		-- Unknown Surveys
		[219849] = false, -- Blacksmith
		[219850] = false, -- Clothier
		[219854] = false, -- Jewelry
		[219851] = false, -- Woodworker
		[219853] = false, -- Alchemist
		[219852] = false, -- Enchanter
		-- Unknown Treasure Maps
		[224681] = false, -- Unopened Treasure Map
	},

	-- Glyphs
	glyphsType = {
		[ITEMTYPE_GLYPH_ARMOR] = false,
		[ITEMTYPE_GLYPH_JEWELRY] = false,
		[ITEMTYPE_GLYPH_WEAPON] = false,
	},
	-- Toggles depositing all intricate types
	shouldDepositIntricate = false,
	-- Specific categories
	intricateType = {
		[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = false,
		[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = false,
		[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = false,
	},
	shouldDepositTreasureMap = false,
	shouldDepositSurveyReport = false,
	shouldDepositResearchable = false,
	shouldDepositRecipeFragment = false,
	shouldDepositRuneboxFragment = false,
	shouldDepositMotifBook = false,
	shouldDepositMotifChapter = false,
	shouldDepositStylePage = false,
	shouldDepositFurnishingRecipe = false,
	shouldDepositProvisioningRecipe = false,

	-- Notifications
	notifications = {
		deposit = true,
		amount = true,
	},
	-- Currencies
	CURRENCY_DATA =
	{
		[CURT_MONEY] =
		{
			minimum = 5000,
			deposit = true,
			slider = { max = 1000000, step = 1000 },
		},
		[CURT_ALLIANCE_POINTS] =
		{
			minimum = 10000,
			deposit = true,
			slider = { max = 1000000, step = 5000 },
		},
		[CURT_TELVAR_STONES] =
		{
			minimum = 300,
			deposit = true,
			slider = { max = 60000, step = 300 },
		},
		[CURT_WRIT_VOUCHERS] =
		{
			minimum = 0,
			deposit = true,
			slider = { max = 1000, step = 10 },
		},
	},
}

-- Make a bag cache to to find empty slots
AB.ourBagCache = {
	[BAG_BANK] = {},
	[BAG_SUBSCRIBER_BANK] = {},
}

-- BAG FUNCTION
local function FindEmptySlotInBag(targetBag)
	for slotIndex = 0, (GetBagSize(targetBag) - 1) do
		if not SHARED_INVENTORY.bagCache[targetBag][slotIndex] and not AB.ourBagCache[targetBag][slotIndex] then
			AB.ourBagCache[targetBag][slotIndex] = true
			return slotIndex
		end
	end
	return nil
end

-- Predicate function for
-- SHARED_INVENTORY:GenerateFullSlotData(predicate, ...)
-- where ... is a variable argument of bags to combine for the bag data

local function FilterUnwantedItems(itemData)
	local isStolen = itemData.stolen
	local isJunk = itemData.isJunk
	local isProtected = itemData.isPlayerLocked
	if isStolen or isJunk or isProtected then
		return false
	else
		return true
	end
end

-- ADDON CHAT OUTPUT
function AB.ABPrint(message)
	CHAT_SYSTEM:AddMessage(message)
end

-- PROTECTED FUNCTION
local function MoveItem(sourceBag, sourceSlot, targetBag, emptySlot, stackCount)
	if IsProtectedFunction("RequestMoveItem") then
		CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, targetBag, emptySlot, stackCount)
	else
		RequestMoveItem(sourceBag, sourceSlot, targetBag, emptySlot, stackCount)
	end
end

-- BAG FUNCTION
-- Handle finding an empty slot and consider ESO+ and those without it

function AB.TryPlaceItemInEmptySlot(sourceBag, sourceSlot, targetBag, stackCount)
	local emptySlot = FindEmptySlotInBag(targetBag)

	--[[ Special case handling ESO+ members because they actually
		   have access to two separate different bank bags!
		]]
	if not emptySlot and IsESOPlusSubscriber() then
		if targetBag == BAG_BANK then
			targetBag = BAG_SUBSCRIBER_BANK
			emptySlot = FindEmptySlotInBag(targetBag)
		elseif targetBag == BAG_SUBSCRIBER_BANK then
			targetBag = BAG_BANK
			emptySlot = FindEmptySlotInBag(targetBag)
		end
	end

	if emptySlot ~= nil then
		MoveItem(sourceBag, sourceSlot, targetBag, emptySlot, stackCount)
		if AB.GetSettings().notifications.deposit then
			AB.ABPrint(zo_strformat(GetString(AB_TRANSACTION_FORMAT), GetItemLink(sourceBag, sourceSlot), stackCount))
		end
		return true
	else
		local errorStringId = SI_INVENTORY_ERROR_BANK_FULL
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, errorStringId)
		return false
	end
end

--
-- PREDICATE FUNCTIONS AND FILTERING
-- Checks conditions in Autobanker

function AB.IsItemRightType(itemType, specializedItemType)
	local settings = AB.GetSettings()

	-- Explicitly enabled the specialized type
	if settings.typesToDeposit_Specialized and settings.typesToDeposit_Specialized[specializedItemType] then
		return true
	end

	-- If the specialized type is not enabled, fall back to itemType
	if settings.typesToDeposit and settings.typesToDeposit[itemType] then
		return true
	end

	return false
end

function AB.IsItemTypeIntricate(itemTrait)
	return AB.GetSettings().shouldDepositIntricate and AB.GetSettings().intricateType[itemTrait]
end

function AB.IsItemResearchable(itemLink)
	local _, isItemResearchable = LR:GetItemTraitResearchabilityInfo(itemLink)
	if AB.GetSettings().shouldDepositResearchable and isItemResearchable then
		return true
	else
		return false
	end
end

function AB.IsItemSurveyReport(itemType, specializedItemType)
	return AB.GetSettings().shouldDepositSurveyReport
		and (itemType == ITEMTYPE_TROPHY
			and specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT)
end

function AB.IsItemTreasureMap(itemType, specializedItemType)
	return AB.GetSettings().shouldDepositTreasureMap
		and (itemType == ITEMTYPE_TROPHY
			and specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP)
end

function AB.IsItemRecipeFragment(itemType, specializedItemType)
	return AB.GetSettings().shouldDepositRecipeFragment
		and (itemType == ITEMTYPE_TROPHY
			and specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT)
end

function AB.IsItemRuneboxFragment(itemType, specializedItemType)
	return AB.GetSettings().shouldDepositRuneboxFragment
		and (itemType == ITEMTYPE_TROPHY
			and specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT)
end

function AB.IsItemMotifBook(itemType, specializedItemType)
	return AB.GetSettings().shouldDepositMotifBook
		and (itemType == ITEMTYPE_RACIAL_STYLE_MOTIF
			and specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK)
end

function AB.IsItemMotifChapter(itemType, specializedItemType)
	return AB.GetSettings().shouldDepositMotifChapter
		and (itemType == ITEMTYPE_RACIAL_STYLE_MOTIF
			and specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER)
end

function AB.IsItemStylePage(itemType, specializedItemType)
	return AB.GetSettings().shouldDepositStylePage
		and (itemType == ITEMTYPE_COLLECTIBLE
			and specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE)
end

-- NEW CODE
function AB.IsItemProvisioningRecipe(itemType, specializedItemType)
	return AB.GetSettings().shouldDepositProvisioningRecipe
		and itemType == ITEMTYPE_RECIPE
		and (specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD
			or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK)
end

-- NEW CODE

function AB.IsItemFurnishingRecipe(itemType, specializedItemType)
	return AB.GetSettings().shouldDepositFurnishingRecipe
		and itemType == ITEMTYPE_RECIPE
		and (specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING
			or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING
			or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING
			or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING
			or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING
			or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING
			or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING)
end

function AB.IsItemCharacterBound(itemLink)
	local bindType = GetItemLinkBindType(itemLink)
	local isBound = IsItemLinkBound(itemLink)
	return isBound and bindType == BIND_TYPE_ON_PICKUP_BACKPACK
end

function AB.ItemMeetsConditions(bagId, slotIndex, itemType, specializedItemType, itemTrait, itemLink)
	local settings = AB.GetSettings()
	local itemId = GetItemLinkItemId(itemLink)
	if settings.itemIdsToDeposit and settings.itemIdsToDeposit[itemId] then
		return true
	end
	--  Run other condition checks
	return AB.IsItemRightType(itemType, specializedItemType)
		or AB.IsItemTypeIntricate(itemTrait)
		or AB.IsItemResearchable(itemLink)
		or AB.IsItemSurveyReport(itemType, specializedItemType)
		or AB.IsItemTreasureMap(itemType, specializedItemType)
		or AB.IsItemRecipeFragment(itemType, specializedItemType)
		or AB.IsItemRuneboxFragment(itemType, specializedItemType)
		or AB.IsItemMotifBook(itemType, specializedItemType)
		or AB.IsItemMotifChapter(itemType, specializedItemType)
		or AB.IsItemStylePage(itemType, specializedItemType)
		or AB.IsSoulGemToDeposit(bagId, slotIndex, itemType, settings)
		or AB.IsRepairKitToDeposit(bagId, slotIndex, settings)
		or AB.IsItemProvisioningRecipe(itemType, specializedItemType)
		or AB.IsItemFurnishingRecipe(itemType, specializedItemType)
end

function AB.GetCurrencyToDeposit(currencyType)
	local curr = AB.GetSettings().CURRENCY_DATA[currencyType]
	if curr.deposit then
		local thisMuchOf = GetCarriedCurrencyAmount(currencyType) - curr.minimum
		if thisMuchOf > 0 then
			local alertString = zo_strformat(SI_FIRST_SPECIAL_CURRENCY, GetString(AB_CURT_TRANSFER_FORMAT),
				ZO_Currency_FormatPlatform(currencyType, thisMuchOf, ZO_CURRENCY_FORMAT_AMOUNT_ICON))
			AB.ABPrint(alertString)
			DepositCurrencyIntoBank(currencyType, thisMuchOf)
		end
	end
end

function AB.IsRepairKitToDeposit(bagId, slotIndex, settings)
	if settings.depositRepairKits and IsItemRepairKit(bagId, slotIndex) then
		return true
	end
	return false
end

function AB.IsSoulGemToDeposit(bagId, slotIndex, itemType, settings)
	if itemType ~= ITEMTYPE_SOUL_GEM then return false end
	if settings.depositFilledSoulGems and IsItemSoulGem(SOUL_GEM_TYPE_FILLED, bagId, slotIndex) then
		return true
	end
	if settings.depositEmptySoulGems and IsItemSoulGem(SOUL_GEM_TYPE_EMPTY, bagId, slotIndex) then
		return true
	end
	return false
end

--
-- EVENT
-- The main depositing function
--local function TriggerAutobanker(bankBag)
local function TriggerAutobanker()
	local bankingBag = GetBankingBag()

	-- Block depositing into Furniture Vault
	if IsFurnitureVault(bankingBag) then
		return
	end
	-- temporarily blocked until house bank support is added
	if IsHouseBankBag(bankingBag) then
		return
	end

	local nItemsDeposited = 0
	local transactions = 0
	local bagCache = SHARED_INVENTORY:GenerateFullSlotData(FilterUnwantedItems, BAG_BACKPACK)

	for _, data in pairs(bagCache) do
		if transactions < 50 then
			local itemLink = GetItemLink(BAG_BACKPACK, data.slotIndex)
			local itemType, specializedItemType = GetItemType(BAG_BACKPACK, data.slotIndex)
			--		local itemName = GetItemName(BAG_BACKPACK, data.slotIndex)
			local itemTrait = GetItemTrait(BAG_BACKPACK, data.slotIndex)

			--	AB.ABPrint(GetItemLink(BAG_BACKPACK, data.slotIndex) ..
			--		" type=" .. tostring(itemType) .. " special=" .. tostring(specializedItemType))

			if data.stackCount >= 1 then
				if AB.ItemMeetsConditions(BAG_BACKPACK, data.slotIndex, itemType, specializedItemType, itemTrait, itemLink) and not AB.IsItemCharacterBound(itemLink) then
					if AB.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount) then
						if (data.isJunk) then
							AB.ABPrint("True")
						end
						transactions = transactions + 1
						nItemsDeposited = nItemsDeposited + data.stackCount
					else
						break
					end
				end
			end
		end
	end

	if nItemsDeposited > 0 and AB.GetSettings().notifications.amount then
		AB.ABPrint(zo_strformat(GetString(AB_COUNT_FORMAT), nItemsDeposited))
	end

	for currencyType, _ in ipairs(defaults.CURRENCY_DATA) do
		AB.GetCurrencyToDeposit(currencyType)
	end
end


--
-- KEYBINDS
-- Autobanker button group on the keybindstrip
local autobankerKeybindButtonGroup =
{
	alignment = KEYBIND_STRIP_ALIGN_CENTER,
	{
		name = GetString(AB_TRIGGER_AUTOBANKER),
		keybind = "UI_SHORTCUT_QUATERNARY",
		callback = TriggerAutobanker,
	},
}

-- Bank scene BANK_FRAGMENT
-- Enable Autobankers keybindstrip
local function AutobankerOnStateChanged(oldState, newState)
	if newState == SCENE_FRAGMENT_SHOWN then
		KEYBIND_STRIP:AddKeybindButtonGroup(autobankerKeybindButtonGroup)
	elseif newState == SCENE_HIDDEN then
		KEYBIND_STRIP:RemoveKeybindButtonGroup(autobankerKeybindButtonGroup)
	end
end

-- CALLBACK
-- Enable Manual Autobanking
local function EnableManualAutobanking()
	BANK_FRAGMENT:RegisterCallback("StateChange", AutobankerOnStateChanged)
	BACKPACK_BANK_LAYOUT_FRAGMENT:RegisterCallback("StateChange", AutobankerOnStateChanged)
	AB.ABPrint(zo_strformat("Enabling Manual Autobanking"))
end

-- CALLBACK
-- Disable Manual Autobanking
local function DisableManualAutobanking()
	BANK_FRAGMENT:UnregisterCallback("StateChange", AutobankerOnStateChanged)
	BACKPACK_BANK_LAYOUT_FRAGMENT:UnregisterCallback("StateChange", AutobankerOnStateChanged)
	AB.ABPrint(zo_strformat("Disabling Manual Autobanking"))
end

-- Toggle the usage of Autobanker automatic deposits.
function AB.ToggleManualOverride()
	if AB.GetSettings().automaticTransfers then
		EVENT_MANAGER:RegisterForEvent(AB.name, EVENT_OPEN_BANK, TriggerAutobanker)
		DisableManualAutobanking()
	else
		EVENT_MANAGER:UnregisterForEvent(AB.name, EVENT_OPEN_BANK)
		EnableManualAutobanking()
	end
end

--
-- EVENT
-- AddOn PlayerActivated
local function OnPlayerActivated()
	EVENT_MANAGER:UnregisterForEvent(AB.name, EVENT_PLAYER_ACTIVATED)
	-- Initialization message
	AB.ABPrint(zo_strformat("|c<<1>><<2>>|r", autobankerInitializeColor, GetString(AB_INIT)))
end

--
-- EVENT
-- AddOn Initialization
local function Initialize(event, addon)
	-- filter for just Autobanker addon event
	if addon ~= AB.name then return end
	EVENT_MANAGER:UnregisterForEvent(AB.name, EVENT_ADD_ON_LOADED)

	--Load saved variables for account wide and character
	AB.GlobalSavedVars = ZO_SavedVars:NewAccountWide("AutobankerGlobalSavedVars", 5, nil, defaults, GetWorldName())
	AB.SavedVars = ZO_SavedVars:NewCharacterIdSettings("AutobankerSavedVars", 5, nil, defaults, GetWorldName())

	-- Explicitly purge old/removed keys from existing save data
	AB.GlobalSavedVars.worldname = nil
	AB.SavedVars.worldname = nil
	AB.GlobalSavedVars.typesToDeposit[ITEMTYPE_RECIPE] = nil
	AB.SavedVars.typesToDeposit[ITEMTYPE_RECIPE] = nil
	AB.GlobalSavedVars.typesToDeposit[ITEMTYPE_SOUL_GEM] = nil
	AB.SavedVars.typesToDeposit[ITEMTYPE_SOUL_GEM] = nil
	AB.GlobalSavedVars.typesToDeposit[ITEMTYPE_RACIAL_STYLE_MOTIF] = nil
	AB.SavedVars.typesToDeposit[ITEMTYPE_RACIAL_STYLE_MOTIF] = nil
	AB.GlobalSavedVars.itemIdsToDeposit[44874] = nil
	AB.GlobalSavedVars.itemIdsToDeposit[44875] = nil
	AB.GlobalSavedVars.itemIdsToDeposit[44876] = nil
	AB.GlobalSavedVars.itemIdsToDeposit[44877] = nil
	AB.GlobalSavedVars.itemIdsToDeposit[44878] = nil
	AB.GlobalSavedVars.itemIdsToDeposit[44879] = nil
	AB.SavedVars.itemIdsToDeposit[44874] = nil
	AB.SavedVars.itemIdsToDeposit[44875] = nil
	AB.SavedVars.itemIdsToDeposit[44876] = nil
	AB.SavedVars.itemIdsToDeposit[44877] = nil
	AB.SavedVars.itemIdsToDeposit[44878] = nil
	AB.SavedVars.itemIdsToDeposit[44879] = nil
	AB.GlobalSavedVars.qualitiesToDeposit = nil
	AB.SavedVars.qualitiesToDeposit = nil


	-- Default to account-wide settings
	if AB.GlobalSavedVars.useGlobalSettings == nil then
		AB.GlobalSavedVars.useGlobalSettings = true
	end

	if AB.GlobalSavedVars.useGlobalSettings then
		AB.SavedVars = AB.GlobalSavedVars
	end

	-- Make our options menu
	AB.CreateSettingsMenu(defaults)

	-- Register handlers for Manual and Automatic Autobanking
	if AB.GetSettings().automaticTransfers then
		EVENT_MANAGER:RegisterForEvent(AB.name, EVENT_OPEN_BANK, TriggerAutobanker)
	else
		EnableManualAutobanking()
	end

	EVENT_MANAGER:RegisterForEvent(AB.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

--
-- EVENT
-- Register for the loading of our addon
EVENT_MANAGER:RegisterForEvent(AB.name, EVENT_ADD_ON_LOADED, Initialize)
