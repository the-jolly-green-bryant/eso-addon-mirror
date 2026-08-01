-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- Data for CollectThemAll add-on
-----------------------------------------------------------

CollectThemAllData = CollectThemAllData or {}
local CTAData = CollectThemAllData

CTAData.armors = {
    "Helm", "Pauldrons", "Cuirass", "Gauntlets", "Girdle", "Greaves", "Sabatons",
    "Helmet", "Arm Cops", "Jack", "Belt", "Bracers", "Guards", "Boots",
    "Hat", "Epaulets", "Jerkin", "Robe", "Gloves", "Sash", "Breeches", "Shoes",

    -- alternatives
    "Mask", "Shoulder", "Hood", "Shawl", "Wraps", "Sandals", "Skirt", "Arm Cop", "Gauntlet", "Pauldron", "Epaulet", "Shoulders",
}
CTAData.weapons = {
    "Axe", "Battle Axe", "Bow", "Dagger", "Greatsword", "Mace", "Maul", "Shield", "Staff", "Sword",

    -- alternatives
    "Hammer"
}

CTAData.crownCrateQualities = {
    [1] = "Radiant Apex",
    [2] = "Apex",
    [3] = "Legendary",
    [4] = "Epic",
    [5] = "Superior",
    [6] = "Fine",
    [7] = "Normal",
}

CTAData.categoryTypes = {
    COLLECTIBLE_CATEGORY_TYPE_HOUSE,
    COLLECTIBLE_CATEGORY_TYPE_FURNITURE,
    COLLECTIBLE_CATEGORY_TYPE_ASSISTANT,
    COLLECTIBLE_CATEGORY_TYPE_COMPANION,
    COLLECTIBLE_CATEGORY_TYPE_MOUNT,
    COLLECTIBLE_CATEGORY_TYPE_VANITY_PET,
    COLLECTIBLE_CATEGORY_TYPE_MEMENTO,
    COLLECTIBLE_CATEGORY_TYPE_EMOTE,
    COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE,
    COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE,
    COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE,
    COLLECTIBLE_CATEGORY_TYPE_POLYMORPH,
    COLLECTIBLE_CATEGORY_TYPE_PERSONALITY,
    COLLECTIBLE_CATEGORY_TYPE_SKIN,
    COLLECTIBLE_CATEGORY_TYPE_COSTUME,
    COLLECTIBLE_CATEGORY_TYPE_HAT,
    COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING,
    COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING,
    COLLECTIBLE_CATEGORY_TYPE_HAIR,
    COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS,
    COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY,
    COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY,

    COLLECTIBLE_CATEGORY_TYPE_TRIBUTE_PATRON, -- TODO: separated group
    COLLECTIBLE_CATEGORY_TYPE_DLC, -- TODO: separated group
    COLLECTIBLE_CATEGORY_TYPE_ACCOUNT_UPGRADE,
    COLLECTIBLE_CATEGORY_TYPE_HOUSE_BANK,
    COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT,
}

CTAData.categoryTypesMap = {}
for i, v in ipairs(CTAData.categoryTypes) do
    CTAData.categoryTypesMap[v] = i
end

-- COLLECTIBLE_CATEGORY_TYPE_MOUNT = Mounts
-- COLLECTIBLE_CATEGORY_TYPE_VANITY_PET = Non-Combat Pets
-- COLLECTIBLE_CATEGORY_TYPE_MEMENTO = Mementos
-- COLLECTIBLE_CATEGORY_TYPE_EMOTE = Emotes
-- COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE = Armor Styles & Weapon Styles
-- COLLECTIBLE_CATEGORY_TYPE_POLYMORPH = Appearance -> Polymorphs
-- COLLECTIBLE_CATEGORY_TYPE_PERSONALITY = Appearance -> Personalities
-- COLLECTIBLE_CATEGORY_TYPE_SKIN = Appearance -> Skins
-- COLLECTIBLE_CATEGORY_TYPE_COSTUME = Appearance -> Costumes
-- COLLECTIBLE_CATEGORY_TYPE_HAT = Appearance -> Hats
-- COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING = Appearance -> Body Markings
-- COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING = Appearance -> Head Markings

-- COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE = Appearance -> Skill Styles
-- COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE = Customized Actions

-- COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY = Appearance -> Major Adornments
-- COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS = Appearance -> Facial Hairs
-- COLLECTIBLE_CATEGORY_TYPE_HAIR = Appearance -> Hair Styles
-- COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY = Appearance -> Minor Adornments

CTAData.specialSource = "Special"
CTAData.fragmentsSource = "Fragments"
CTAData.defaultSource = "Unknown"

CTAData.othersSource = "Others"
CTAData.unobtainableGroup = "Unobtainable"

CTAData.groups = {}

-- SPFLibUtils.Spread(CTAData.groups, CollectThemAllData_Events)
-- SPFLibUtils.Spread(CTAData.groups, CollectThemAllData_TamrielTomes)
-- SPFLibUtils.Spread(CTAData.groups, CollectThemAllData_GoldCoastBazaar)
SPFLibUtils.Spread(CTAData.groups, CollectThemAllData_CustomGroupSort)
SPFLibUtils.Spread(CTAData.groups, CollectThemAllData_Vendors)
SPFLibUtils.Spread(CTAData.groups, CollectThemAllData_Crates)
SPFLibUtils.Spread(CTAData.groups, CollectThemAllData_Store)
SPFLibUtils.Spread(CTAData.groups, CollectThemAllData_Game)
SPFLibUtils.Spread(CTAData.groups, CollectThemAllData_Motifs)
SPFLibUtils.Spread(CTAData.groups, CollectThemAllData_Others)
