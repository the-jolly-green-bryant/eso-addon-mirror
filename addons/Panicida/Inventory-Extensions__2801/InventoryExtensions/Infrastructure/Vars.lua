InventoryExtensions = {
    name = "InventoryExtensions",
    varsVersion = 1,
    Localization = {},
    Loc = function(var) return InventoryExtensions.Localization.en[var] or var end,
    DefaultVars = {
        autoJunk = {
            weaponsArmorJewelry = {
                enabled = false,
                jewelryQuality = 1,
                armorWeaponQuality = 1,
                excludeResearchable = true,
                excludeTrait = {
                    [ITEM_TRAIT_TYPE_ARMOR_DIVINES] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_INFUSED] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = false,
                    -- [ITEM_TRAIT_TYPE_ARMOR_ORNATE] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_STURDY] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_TRAINING] = false,
                    [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = false,
                    -- [ITEM_TRAIT_TYPE_JEWELRY_ORNATE] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = false,
                    [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_CHARGED] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_INFUSED] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = false,
                    -- [ITEM_TRAIT_TYPE_WEAPON_ORNATE] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_POWERED] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_PRECISE] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = false,
                    [ITEM_TRAIT_TYPE_WEAPON_TRAINING] = false
                },
                excludedSets = {} -- array
            },
            consumibles = {
                foodAndDrinks = true,
                potionsAndPoisons = true,
                ignoreCrafted = true,
                ignoreBound = true
            },
            miscellaneous = {
                monsterTropies = true,
                treasures = true,
                treasureMaps = false,
                trash = true
            },
            ignored = {}
        },
        dialyGoldIncomeTracker = true,
        dialyGoldIncome = 0
    },
    InventoryLists = {
        [ZO_PlayerInventoryList] = true,
        [ZO_CraftBagList] = true
    }
}