local AF = AdvancedFilters
local util = AF.util
if not AF or not util then return end
local textures = AF.textures
local universalDeconStr = "UniversalDecon"

local pluginName = "FCOItemTraitType_"

--Armor
local armorTraits = {
    --[ITEM_TRAIT_TYPE_NONE] = SI_ITEMTRAITTYPE0,
--    [ITEM_TRAIT_TYPE_SPECIAL_STAT] = SI_ITEMTRAITTYPE27,
    [ITEM_TRAIT_TYPE_ARMOR_DIVINES] = SI_ITEMTRAITTYPE18,
    [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = SI_ITEMTRAITTYPE12,
    [ITEM_TRAIT_TYPE_ARMOR_INFUSED] = SI_ITEMTRAITTYPE16,
    [ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = SI_ITEMTRAITTYPE20,
    [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = SI_ITEMTRAITTYPE26,
    [ITEM_TRAIT_TYPE_ARMOR_ORNATE] = SI_ITEMTRAITTYPE19,
    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = SI_ITEMTRAITTYPE17,
    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = SI_ITEMTRAITTYPE13,
    [ITEM_TRAIT_TYPE_ARMOR_STURDY] = SI_ITEMTRAITTYPE11,
    [ITEM_TRAIT_TYPE_ARMOR_TRAINING] = SI_ITEMTRAITTYPE15,
    [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = SI_ITEMTRAITTYPE14,
    --Companion
    [ITEM_TRAIT_TYPE_ARMOR_AGGRESSIVE] = SI_ITEMTRAITTYPE47,
    [ITEM_TRAIT_TYPE_ARMOR_AUGMENTED] = SI_ITEMTRAITTYPE49,
    [ITEM_TRAIT_TYPE_ARMOR_BOLSTERED] = SI_ITEMTRAITTYPE50,
    [ITEM_TRAIT_TYPE_ARMOR_FOCUSED] = SI_ITEMTRAITTYPE45,
    [ITEM_TRAIT_TYPE_ARMOR_PROLIFIC] = SI_ITEMTRAITTYPE44,
    [ITEM_TRAIT_TYPE_ARMOR_QUICKENED] = SI_ITEMTRAITTYPE43,
    [ITEM_TRAIT_TYPE_ARMOR_SHATTERING] = SI_ITEMTRAITTYPE46,
    [ITEM_TRAIT_TYPE_ARMOR_SOOTHING] = SI_ITEMTRAITTYPE48,
    [ITEM_TRAIT_TYPE_ARMOR_VIGOROUS] = SI_ITEMTRAITTYPE51,
}
--Jewelry
local jewelryTraits = {
    --[ITEM_TRAIT_TYPE_NONE] = SI_ITEMTRAITTYPE0,
    [ITEM_TRAIT_TYPE_JEWELRY_ARCANE]		= SI_ITEMTRAITTYPE22,
    [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY]	= SI_ITEMTRAITTYPE31,
    [ITEM_TRAIT_TYPE_JEWELRY_HARMONY] 		= SI_ITEMTRAITTYPE29,
    [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] 		= SI_ITEMTRAITTYPE21,
    [ITEM_TRAIT_TYPE_JEWELRY_INFUSED] 		= SI_ITEMTRAITTYPE33,
    [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] 	= SI_ITEMTRAITTYPE27,
    [ITEM_TRAIT_TYPE_JEWELRY_ORNATE] 		= SI_ITEMTRAITTYPE24,
    [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] 	= SI_ITEMTRAITTYPE32,
    [ITEM_TRAIT_TYPE_JEWELRY_ROBUST] 		= SI_ITEMTRAITTYPE23,
    [ITEM_TRAIT_TYPE_JEWELRY_SWIFT] 		= SI_ITEMTRAITTYPE28,
    [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] 		= SI_ITEMTRAITTYPE30,
    --Companion
    [ITEM_TRAIT_TYPE_JEWELRY_AGGRESSIVE] = SI_ITEMTRAITTYPE56,
    [ITEM_TRAIT_TYPE_JEWELRY_AUGMENTED] = SI_ITEMTRAITTYPE58,
    [ITEM_TRAIT_TYPE_JEWELRY_BOLSTERED] = SI_ITEMTRAITTYPE59,
    [ITEM_TRAIT_TYPE_JEWELRY_FOCUSED] = SI_ITEMTRAITTYPE54,
    [ITEM_TRAIT_TYPE_JEWELRY_PROLIFIC] = SI_ITEMTRAITTYPE53,
    [ITEM_TRAIT_TYPE_JEWELRY_QUICKENED] = SI_ITEMTRAITTYPE52,
    [ITEM_TRAIT_TYPE_JEWELRY_SHATTERING] = SI_ITEMTRAITTYPE55,
    [ITEM_TRAIT_TYPE_JEWELRY_SOOTHING] = SI_ITEMTRAITTYPE57,
    [ITEM_TRAIT_TYPE_JEWELRY_VIGOROUS] = SI_ITEMTRAITTYPE60,
}
--Weapon
local weaponTraits = {
    --[ITEM_TRAIT_TYPE_NONE] = SI_ITEMTRAITTYPE0,
--    [ITEM_TRAIT_TYPE_SPECIAL_STAT] = SI_ITEMTRAITTYPE27,
    [ITEM_TRAIT_TYPE_WEAPON_CHARGED] = SI_ITEMTRAITTYPE2,
    [ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = SI_ITEMTRAITTYPE8,
    [ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = SI_ITEMTRAITTYPE5,
    [ITEM_TRAIT_TYPE_WEAPON_INFUSED] = SI_ITEMTRAITTYPE4,
    [ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = SI_ITEMTRAITTYPE9,
    [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = SI_ITEMTRAITTYPE25,
    [ITEM_TRAIT_TYPE_WEAPON_ORNATE] = SI_ITEMTRAITTYPE10,
    [ITEM_TRAIT_TYPE_WEAPON_POWERED] = SI_ITEMTRAITTYPE1,
    [ITEM_TRAIT_TYPE_WEAPON_PRECISE] = SI_ITEMTRAITTYPE3,
    [ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = SI_ITEMTRAITTYPE7,
    [ITEM_TRAIT_TYPE_WEAPON_TRAINING] = SI_ITEMTRAITTYPE6,
    --Companion
    [ITEM_TRAIT_TYPE_WEAPON_AGGRESSIVE] = SI_ITEMTRAITTYPE38,
    [ITEM_TRAIT_TYPE_WEAPON_AUGMENTED] = SI_ITEMTRAITTYPE40,
    [ITEM_TRAIT_TYPE_WEAPON_BOLSTERED] = SI_ITEMTRAITTYPE41,
    [ITEM_TRAIT_TYPE_WEAPON_FOCUSED] = SI_ITEMTRAITTYPE36,
    [ITEM_TRAIT_TYPE_WEAPON_PROLIFIC] = SI_ITEMTRAITTYPE35,
    [ITEM_TRAIT_TYPE_WEAPON_QUICKENED] = SI_ITEMTRAITTYPE34,
    [ITEM_TRAIT_TYPE_WEAPON_SHATTERING] = SI_ITEMTRAITTYPE37,
    [ITEM_TRAIT_TYPE_WEAPON_SOOTHING] = SI_ITEMTRAITTYPE39,
    [ITEM_TRAIT_TYPE_WEAPON_VIGOROUS] = SI_ITEMTRAITTYPE42,
}

local armorTraitNames = {}
--local armorTraitIds = {}
for traitId, traitName in pairs(armorTraits) do
    traitName = GetString(traitName)
    if traitId ~= nil and traitName ~= "" then
        table.insert(armorTraitNames, traitName .. "::"  .. traitId)
        --armorTraitIds[traitId] = traitName
    end
end
table.sort(armorTraitNames)

local jewelryTraitNames = {}
--local jewelryTraitIds = {}
for traitId, traitName in pairs(jewelryTraits) do
    traitName = GetString(traitName)
    if traitId ~= nil and traitName ~= "" then
        table.insert(jewelryTraitNames, traitName .. "::"  .. traitId)
        --jewelryTraitIds[traitId] = traitName
    end
end
table.sort(jewelryTraitNames)

local weaponTraitNames = {}
--local weaponTraitIds = {}
for traitId, traitName in pairs(weaponTraits) do
    traitName = GetString(traitName)
    if traitId ~= nil and traitName ~= "" then
        table.insert(weaponTraitNames, traitName .. "::"  .. traitId)
        --weaponTraitIds[traitId] = traitName
    end
end
table.sort(weaponTraitNames)


--[[
	This function handles the actual filtering. Use whatever parameters for "GetFilterCallback..."
    and whatever logic you need to in "function( slot )".
  ]]
local allowedItemTypes = {
    [ITEMTYPE_ARMOR]    = true,
    [ITEMTYPE_WEAPON]   = true,
}
local function GetFilterCallbackForFCOItemTraitType(traitType)
	return function( slot , slotIndex)
        if util.prepareSlot ~= nil then
            if slotIndex ~= nil and type(slot) ~= "table" then
                slot = util.prepareSlot(slot, slotIndex)
            end
        end
        --get the item link
        local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
        --Check if bound items should be shown, or not
        if itemLink == nil then return false end
        local itemType = GetItemLinkItemType(itemLink)
        if not itemType or not allowedItemTypes[itemType] then return false end
        local itemTraitType = GetItemLinkTraitInfo(itemLink)
        --Compare check parameter with the itemtrait
        return (traitType == itemTraitType) or false
	end
end

--[[
	This table is processed within Advanced Filters and it's contents are added to Advanced Filter's
    callback table. The string value for name is the relevant key for the language table.
  ]]
local FCOTraitTypeArmorDropdownCallback = {}
--Get the name of the armor traits
table.insert(FCOTraitTypeArmorDropdownCallback, { name = pluginName..tostring(0), filterCallback = GetFilterCallbackForFCOItemTraitType( ITEM_TRAIT_TYPE_NONE ) } )
for _, traitString in ipairs(armorTraitNames) do
    --Split the trait string by the "::"
    local _, armorTraitIdStr = zo_strsplit("::", traitString)
    local armorTraitId = tonumber(armorTraitIdStr)
    table.insert(FCOTraitTypeArmorDropdownCallback, { name = pluginName..tostring(armorTraitId), filterCallback = GetFilterCallbackForFCOItemTraitType( armorTraitId ) } )
end

local FCOTraitTypeJewelryDropdownCallback = {}
--Get the name of the jewelry traits
table.insert(FCOTraitTypeJewelryDropdownCallback, { name = pluginName..tostring(0), filterCallback = GetFilterCallbackForFCOItemTraitType( ITEM_TRAIT_TYPE_NONE ) } )
for _, traitString in ipairs(jewelryTraitNames) do
    --Split the trait string by the "::"
    local _, jewelryTraitIdStr = zo_strsplit("::", traitString)
    local jewelryTraitId = tonumber(jewelryTraitIdStr)
    table.insert(FCOTraitTypeJewelryDropdownCallback, { name = pluginName..tostring(jewelryTraitId), filterCallback = GetFilterCallbackForFCOItemTraitType( jewelryTraitId ) } )
end

local FCOTraitTypeWeaponsDropdownCallback = {}
--Get the name of the weapon traits
table.insert(FCOTraitTypeWeaponsDropdownCallback, { name = pluginName..tostring(0), filterCallback = GetFilterCallbackForFCOItemTraitType( ITEM_TRAIT_TYPE_NONE ) } )
for _, traitString in ipairs(weaponTraitNames) do
    --Split the trait string by the "::"
    local _, weaponTraitIdStr = zo_strsplit("::", traitString)
    local weaponTraitId = tonumber(weaponTraitIdStr)
    table.insert(FCOTraitTypeWeaponsDropdownCallback, { name = pluginName..tostring(weaponTraitId), filterCallback = GetFilterCallbackForFCOItemTraitType( weaponTraitId ) } )
end
--AdvancedFilters._FCOTraitTypeWeaponsDropdownCallback= FCOTraitTypeWeaponsDropdownCallback

--Generic traits
--[[
local ornateTexture         = "esoui/art/inventory/inventory_trait_ornate_icon.dds"
local intricateTexture      = "esoui/art/inventory/inventory_trait_intricate_icon.dds"
--Companion traits
local AGGRESSIVETexture     = "EsoUI/Art/Campaign/campaignBrowser_indexIcon_normal_up.dds"
local AUGMENTEDTexture      = "EsoUI/Art/Campaign/overview_indexIcon_bonus_up.dds"
local BOLSTEREDTexture      = "EsoUI/Art/Campaign/campaign_tabIcon_browser_up.dds"
local FOCUSEDTexture        = "EsoUI/Art/Campaign/overview_indexIcon_scoring_up.dds"
local PROLIFICTexture       = "EsoUI/Art/Crafting/retrait_tabicon_up.dds"
local QUICKENEDTexture      = "EsoUI/Art/Guild/tabIcon_history_up.dds"
local SHATTERINGTexture     = "EsoUI/Art/Repair/inventory_tabIcon_repair_up.dds"
local SOOTHINGTexture       = "EsoUI/Art/Inventory/inventory_tabIcon_healstaff_up.dds"
local VIGOROUSTexture       = "EsoUI/Art/Crafting/provisioner_indexIcon_beer_up.dds"
]]
local ornateTexture         = textures.Ornate
local intricateTexture      = textures.Intricate
--Companion traits
local AGGRESSIVETexture     = textures.Aggressive
local AUGMENTEDTexture      = textures.Augmented
local BOLSTEREDTexture      = textures.Bolstered
local FOCUSEDTexture        = textures.Focused
local PROLIFICTexture       = textures.Prolific
local QUICKENEDTexture      = textures.Quickened
local SHATTERINGTexture     = textures.Shattering
local SOOTHINGTexture       = textures.Soothing
local VIGOROUSTexture       = textures.Vigorous

local traitTextures = {
    [ITEM_TRAIT_TYPE_NONE]					= "",
    --Armor
    [ITEM_TRAIT_TYPE_ARMOR_ORNATE]			= ornateTexture,
    [ITEM_TRAIT_TYPE_ARMOR_INTRICATE]		= intricateTexture,
    [ITEM_TRAIT_TYPE_ARMOR_DIVINES]			= "esoui/art/icons/crafting_accessory_sp_names_001.dds",
    [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE]	= "esoui/art/icons/crafting_jewelry_base_diamond_r3.dds",
    [ITEM_TRAIT_TYPE_ARMOR_INFUSED]			= "esoui/art/icons/crafting_enchantment_baxe_bloodstone_r2.dds",
    [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED]		= "/esoui/art/icons/crafting_fortified_nirncrux_stone.dds",
    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS]		= "esoui/art/icons/crafting_jewelry_base_garnet_r3.dds",
    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED]		= "esoui/art/icons/crafting_enchantment_base_sardonyx_r2.dds",
    [ITEM_TRAIT_TYPE_ARMOR_STURDY]			= "esoui/art/icons/crafting_runecrafter_plug_component_002.dds",
    [ITEM_TRAIT_TYPE_ARMOR_TRAINING]		= "esoui/art/icons/crafting_jewelry_base_emerald_r2.dds",
    [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED]		= "esoui/art/icons/crafting_accessory_sp_names_002.dds",
    [ITEM_TRAIT_TYPE_ARMOR_AGGRESSIVE]     = AGGRESSIVETexture,
    [ITEM_TRAIT_TYPE_ARMOR_AUGMENTED]      = AUGMENTEDTexture,
    [ITEM_TRAIT_TYPE_ARMOR_BOLSTERED]      = BOLSTEREDTexture,
    [ITEM_TRAIT_TYPE_ARMOR_FOCUSED]        = FOCUSEDTexture,
    [ITEM_TRAIT_TYPE_ARMOR_PROLIFIC]       = PROLIFICTexture,
    [ITEM_TRAIT_TYPE_ARMOR_QUICKENED]      = QUICKENEDTexture,
    [ITEM_TRAIT_TYPE_ARMOR_SHATTERING]     = SHATTERINGTexture,
    [ITEM_TRAIT_TYPE_ARMOR_SOOTHING]       = SOOTHINGTexture,
    [ITEM_TRAIT_TYPE_ARMOR_VIGOROUS]       = VIGOROUSTexture,
    --Jewelry
    [ITEM_TRAIT_TYPE_JEWELRY_ORNATE]		= ornateTexture,
    [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE]		= intricateTexture,
    [ITEM_TRAIT_TYPE_JEWELRY_ARCANE]		= textures.Arcane,
    [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]		= textures.Healthy,
    [ITEM_TRAIT_TYPE_JEWELRY_ROBUST]		= textures.Robust,
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY]	= textures.Bloodthirsty,
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY]		= textures.Harmony,
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED]		= textures.Infused,
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE]	= textures.Protective,
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT]			= textures.Swift,
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE]		= textures.Triune,
    [ITEM_TRAIT_TYPE_JEWELRY_AGGRESSIVE]     = AGGRESSIVETexture,
    [ITEM_TRAIT_TYPE_JEWELRY_AUGMENTED]      = AUGMENTEDTexture,
    [ITEM_TRAIT_TYPE_JEWELRY_BOLSTERED]      = BOLSTEREDTexture,
    [ITEM_TRAIT_TYPE_JEWELRY_FOCUSED]        = FOCUSEDTexture,
    [ITEM_TRAIT_TYPE_JEWELRY_PROLIFIC]       = PROLIFICTexture,
    [ITEM_TRAIT_TYPE_JEWELRY_QUICKENED]      = QUICKENEDTexture,
    [ITEM_TRAIT_TYPE_JEWELRY_SHATTERING]     = SHATTERINGTexture,
    [ITEM_TRAIT_TYPE_JEWELRY_SOOTHING]       = SOOTHINGTexture,
    [ITEM_TRAIT_TYPE_JEWELRY_VIGOROUS]       = VIGOROUSTexture,
    --Weapons
    [ITEM_TRAIT_TYPE_WEAPON_ORNATE]			= ornateTexture,
    [ITEM_TRAIT_TYPE_WEAPON_INTRICATE]		= intricateTexture,
    [ITEM_TRAIT_TYPE_WEAPON_CHARGED]		= "esoui/art/icons/crafting_jewelry_base_amethyst_r3.dds",
    [ITEM_TRAIT_TYPE_WEAPON_DECISIVE]		= "esoui/art/icons/crafting_smith_potion__sp_names_003.dds",
    [ITEM_TRAIT_TYPE_WEAPON_DEFENDING]		= "esoui/art/icons/crafting_jewelry_base_turquoise_r3.dds",
    [ITEM_TRAIT_TYPE_WEAPON_INFUSED]		= "esoui/art/icons/crafting_enchantment_base_jade_r3.dds",
    [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED]		= "esoui/art/icons/crafting_potent_nirncrux_dust.dds",
    [ITEM_TRAIT_TYPE_WEAPON_POWERED]		= "esoui/art/icons/crafting_runecrafter_potion_008.dds",
    [ITEM_TRAIT_TYPE_WEAPON_PRECISE]		= "esoui/art/icons/crafting_jewelry_base_ruby_r3.dds",
    [ITEM_TRAIT_TYPE_WEAPON_SHARPENED]		= "esoui/art/icons/crafting_enchantment_base_fire_opal_r3.dds",
    [ITEM_TRAIT_TYPE_WEAPON_TRAINING] 		= "esoui/art/icons/crafting_runecrafter_armor_component_004.dds",
    [ITEM_TRAIT_TYPE_WEAPON_AGGRESSIVE]     = AGGRESSIVETexture,
    [ITEM_TRAIT_TYPE_WEAPON_AUGMENTED]      = AUGMENTEDTexture,
    [ITEM_TRAIT_TYPE_WEAPON_BOLSTERED]      = BOLSTEREDTexture,
    [ITEM_TRAIT_TYPE_WEAPON_FOCUSED]        = FOCUSEDTexture,
    [ITEM_TRAIT_TYPE_WEAPON_PROLIFIC]       = PROLIFICTexture,
    [ITEM_TRAIT_TYPE_WEAPON_QUICKENED]      = QUICKENEDTexture,
    [ITEM_TRAIT_TYPE_WEAPON_SHATTERING]     = SHATTERINGTexture,
    [ITEM_TRAIT_TYPE_WEAPON_SOOTHING]       = SOOTHINGTexture,
    [ITEM_TRAIT_TYPE_WEAPON_VIGOROUS]       = VIGOROUSTexture,
}

local function createTraitNameWithTexture(traitId, traitName)
    if not traitName then return "" end
    if not traitId then return traitName end
    if not traitTextures[traitId] or traitTextures[traitId] == "" then return traitName end
    return zo_iconFormat(traitTextures[traitId], 20, 20) .. " " .. traitName
end

local function buildItemTraitTypeTextForAFFilterInformation(traitsTable, tableToAddTo)
    tableToAddTo = tableToAddTo or {}
    for itemTraitType, siStringConstant in pairs(traitsTable) do
        tableToAddTo[pluginName..tostring(itemTraitType)] = createTraitNameWithTexture(itemTraitType, GetString(siStringConstant))
    end
end

--[[
	There are four potential tables for this section - enStrings (English), deStrings (German),
	frStrings (French), ruStrings (Russian). Only enStrings is required. If other language tables are
	not included, the english table will automatically be used for those languages. If other languages
	are included, all language must share common keys.
  ]]

local traitStr          = GetString(SI_TRADINGHOUSEFEATURECATEGORY3)    --Trait
local traitStrForType   = traitStr .. " (%s)"                           --Trait (%s)

--English
local enFCOItemTraitType = {
    ["FCOItemTraitTypeSubMenu"]        = traitStr,
    ["FCOItemTraitTypeSubMenuArmor"]   = string.format(traitStrForType, GetString(SI_ITEMTYPEDISPLAYCATEGORY2)), --Trait (Armor)
    ["FCOItemTraitTypeSubMenuWeapon"]  = string.format(traitStrForType, GetString(SI_ITEMTYPEDISPLAYCATEGORY1)), --Trait (Weapons)
    ["FCOItemTraitTypeSubMenuJewelry"] = string.format(traitStrForType, GetString(SI_ITEMTYPEDISPLAYCATEGORY3)), --Trait (Jewelry)
    --None
    [pluginName..tostring(ITEM_TRAIT_TYPE_NONE)]   = createTraitNameWithTexture(ITEM_TRAIT_TYPE_NONE, GetString(SI_ITEMTRAITTYPE0)),
}

--Add the texts for the different traits
buildItemTraitTypeTextForAFFilterInformation(armorTraits,   enFCOItemTraitType)
buildItemTraitTypeTextForAFFilterInformation(jewelryTraits, enFCOItemTraitType)
buildItemTraitTypeTextForAFFilterInformation(weaponTraits,  enFCOItemTraitType)

--For debugging
--[[
AFTraits = {
    stringsEn = enFCOItemTraitType,
}
]]

--German
--[[
local deFCOItemTraitType = {
	["FCOItemTraitTypeSubMenu"] 			= "Eigenschaft",
	["FCOItemTraitTypeSubMenuArmor"] 		= "Eigenschaft (Rüstung)",
	["FCOItemTraitTypeSubMenuWeapon"] 		= "Eigenschaft (Waffen)",
	["FCOItemTraitTypeSubMenuJewelry"] 		= "Eigenschaft (Schmuck)",
}

--Use metatables to get strings of EN table for other languages, e.g. DE, too
deFCOItemTraitType = setmetatable(deFCOItemTraitType, {__index = enFCOItemTraitType})
]]


------------------------------------------------------------------------------------------------------------------------
--ARMOR
--Build the AdvancedFilters filterInformation table for filters and subfilters
local filterInformation = {
	submenuName = "FCOItemTraitTypeSubMenuArmor",
	callbackTable = FCOTraitTypeArmorDropdownCallback,
	filterType = {ITEMFILTERTYPE_ALL,
        ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL,
        ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ARMOR,
    },
    subfilters = {"All",},
    onlyGroups = {"Armor", "Junk", "Companion",
				   "All" ..universalDeconStr, "Armor"..universalDeconStr},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE,
        LF_ALCHEMY_CREATION,
        LF_CRAFTBAG,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT,
    },
	enStrings = enFCOItemTraitType,
	deStrings = enFCOItemTraitType,
	frStrings = enFCOItemTraitType,
	esStrings = enFCOItemTraitType,
	ruStrings = enFCOItemTraitType,
	jpStrings = enFCOItemTraitType,
}
--Register the filter
AdvancedFilters_RegisterFilter(filterInformation)

------------------------------------------------------------------------------------------------------------------------
--JEWELRY
--Build the AdvancedFilters filterInformation table for filters and subfilters
filterInformation = {
	submenuName = "FCOItemTraitTypeSubMenuJewelry",
	callbackTable = FCOTraitTypeJewelryDropdownCallback,
    filterType = {ITEMFILTERTYPE_ALL,
        ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL,
        ITEMFILTERTYPE_AF_UNIVERSAL_DECON_JEWELRY,
    },
    subfilters = {"All",},
    onlyGroups = {"Junk", "Companion", --"Jewelry" was removed as AF uses buildIn jewelry trait filters now since version AdvancedFilters UPDATED v1.5.4.0
				   "All" ..universalDeconStr, "Jewelry"..universalDeconStr},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE, 
        LF_ALCHEMY_CREATION,
        LF_CRAFTBAG,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT
    },
	enStrings = enFCOItemTraitType,
    deStrings = enFCOItemTraitType,
	frStrings = enFCOItemTraitType,
	esStrings = enFCOItemTraitType,
	ruStrings = enFCOItemTraitType,
	jpStrings = enFCOItemTraitType,
}
--Register the filter
AdvancedFilters_RegisterFilter(filterInformation)

------------------------------------------------------------------------------------------------------------------------
--WEAPONS
--Build the AdvancedFilters filterInformation table for filters and subfilters
filterInformation = {
	submenuName = "FCOItemTraitTypeSubMenuWeapon",
	callbackTable = FCOTraitTypeWeaponsDropdownCallback,
    filterType = {ITEMFILTERTYPE_ALL,
        ITEMFILTERTYPE_AF_UNIVERSAL_DECON_ALL,
        ITEMFILTERTYPE_AF_UNIVERSAL_DECON_WEAPONS,
    },
    subfilters = {"All"},
    onlyGroups = {"Weapons", "Junk", "Companion",
				   "All" ..universalDeconStr, "Weapons"..universalDeconStr},
    excludeFilterPanels = {
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION,
        LF_SMITHING_REFINE,
        LF_ALCHEMY_CREATION,
        LF_CRAFTBAG,
        LF_PROVISIONING_BREW, LF_PROVISIONING_COOK,
        LF_QUICKSLOT
    },
	enStrings = enFCOItemTraitType,
    deStrings = enFCOItemTraitType,
	frStrings = enFCOItemTraitType,
	esStrings = enFCOItemTraitType,
	ruStrings = enFCOItemTraitType,
	jpStrings = enFCOItemTraitType,
}
--Register the filter
AdvancedFilters_RegisterFilter(filterInformation)