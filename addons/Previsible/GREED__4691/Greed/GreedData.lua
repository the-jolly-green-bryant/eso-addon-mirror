Greed_Addon = Greed_Addon or {}
Greed_Addon.Data = {}
local GreedData = Greed_Addon.Data

GreedData.placeholderIcons = {
    armor = "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds",
    jewelry = "EsoUI/Art/Crafting/jewelry_tabIcon_icon_up.dds",
    weapon = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds",
    helmet = "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds",
    weaponOverlay = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds",
}

GreedData.armorSlots = {
    { key = "head", label = "Head", shortLabel = "Head", equipType = EQUIP_TYPE_HEAD, fallbackIcon = GreedData.placeholderIcons.armor },
    { key = "shoulders", label = "Shoulders", shortLabel = "Shldr", equipType = EQUIP_TYPE_SHOULDERS, fallbackIcon = GreedData.placeholderIcons.armor },
    { key = "chest", label = "Chest", shortLabel = "Chest", equipType = EQUIP_TYPE_CHEST, fallbackIcon = GreedData.placeholderIcons.armor },
    { key = "hands", label = "Hands", shortLabel = "Hands", equipType = EQUIP_TYPE_HAND, fallbackIcon = GreedData.placeholderIcons.armor },
    { key = "waist", label = "Waist", shortLabel = "Waist", equipType = EQUIP_TYPE_WAIST, fallbackIcon = GreedData.placeholderIcons.armor },
    { key = "legs", label = "Legs", shortLabel = "Legs", equipType = EQUIP_TYPE_LEGS, fallbackIcon = GreedData.placeholderIcons.armor },
    { key = "feet", label = "Feet", shortLabel = "Feet", equipType = EQUIP_TYPE_FEET, fallbackIcon = GreedData.placeholderIcons.armor },
    { key = "neck", label = "Neck", shortLabel = "Neck", equipType = EQUIP_TYPE_NECK, fallbackIcon = GreedData.placeholderIcons.jewelry },
    { key = "ring", label = "Ring", shortLabel = "Ring", equipType = EQUIP_TYPE_RING, fallbackIcon = GreedData.placeholderIcons.jewelry, total = 2 },
}

GreedData.weaponTypes = {
    lightningStaff = { label = "Lightning Staff", badge = "Ltng", weaponType = WEAPONTYPE_LIGHTNING_STAFF, fallbackIcon = GreedData.placeholderIcons.weapon },
    restorationStaff = { label = "Restoration Staff", badge = "Resto", weaponType = WEAPONTYPE_HEALING_STAFF, fallbackIcon = GreedData.placeholderIcons.weapon },
    bow = { label = "Bow", badge = "Bow", weaponType = WEAPONTYPE_BOW, fallbackIcon = GreedData.placeholderIcons.weapon },
    iceStaff = { label = "Ice Staff", badge = "Ice", weaponType = WEAPONTYPE_FROST_STAFF, fallbackIcon = GreedData.placeholderIcons.weapon },
    fireStaff = { label = "Fire Staff", badge = "Fire", weaponType = WEAPONTYPE_FIRE_STAFF, fallbackIcon = GreedData.placeholderIcons.weapon },
}

GreedData.favorites = {
    {
        name = "Spell Power Cure",
        setId = 185,
        source = "Dungeon - White-Gold Tower",
        pieces = {
            head = { collected = true },
            shoulders = { collected = false },
            chest = { collected = true, perfected = true },
            hands = { collected = true },
            waist = { collected = false },
            legs = { collected = true },
            feet = { collected = false },
            neck = { collected = true },
            ring = { count = 2, total = 2 },
        },
        weapons = {
            { type = "restorationStaff", collected = true },
        },
    },
    {
        name = "Powerful Assault",
        setId = 180,
        source = "Imperial City Tel Var",
        pieces = {
            head = { collected = false },
            shoulders = { collected = true },
            chest = { collected = false },
            hands = { collected = true },
            waist = { collected = true },
            legs = { collected = false },
            feet = { collected = true },
            neck = { collected = false },
            ring = { count = 1, total = 2 },
        },
        weapons = {
            { type = "lightningStaff", collected = true, perfected = true },
        },
    },
    {
        name = "Pillager's Profit",
        setId = 649,
        source = "Trial - Dreadsail Reef",
        pieces = {
            head = { collected = true, perfected = true },
            shoulders = { collected = true },
            chest = { collected = false },
            hands = { collected = false },
            waist = { collected = true },
            legs = { collected = true },
            feet = { collected = false },
            neck = { collected = false },
            ring = { count = 0, total = 2 },
        },
        weapons = {
            { type = "lightningStaff", collected = false },
            { type = "restorationStaff", collected = true, perfected = true },
        },
    },
    {
        name = "Roaring Opportunist",
        setId = 496,
        source = "Trial - Kyne's Aegis",
        pieces = {
            head = { collected = true },
            shoulders = { collected = false },
            chest = { collected = true },
            hands = { collected = true },
            waist = { collected = false },
            legs = { collected = false },
            feet = { collected = true },
            neck = { collected = true },
            ring = { count = 2, total = 2 },
        },
        weapons = {
            { type = "lightningStaff", collected = false },
            { type = "restorationStaff", collected = false },
        },
    },
    {
        name = "Jorvuld's Guidance",
        setId = 346,
        source = "Dungeon - Scalecaller Peak",
        pieces = {
            head = { collected = false },
            shoulders = { collected = false },
            chest = { collected = true },
            hands = { collected = false },
            waist = { collected = true },
            legs = { collected = true },
            feet = { collected = true },
            neck = { collected = false },
            ring = { count = 1, total = 2 },
        },
        weapons = {
            { type = "restorationStaff", collected = false },
        },
    },
    {
        name = "Master Architect",
        setId = 332,
        source = "Trial - Halls of Fabrication",
        pieces = {
            head = { collected = true },
            shoulders = { collected = true, perfected = true },
            chest = { collected = true },
            hands = { collected = false },
            waist = { collected = false },
            legs = { collected = true },
            feet = { collected = false },
            neck = { collected = true },
            ring = { count = 0, total = 2 },
        },
        weapons = {
            { type = "lightningStaff", collected = false },
        },
    },
    {
        name = "Xoryn's Masterpiece",
        setId = 769,
        source = "Trial - Lucent Citadel",
        pieces = {
            head = { collected = false },
            shoulders = { collected = true },
            chest = { collected = false },
            hands = { collected = true, perfected = true },
            waist = { collected = false },
            legs = { collected = true },
            feet = { collected = true },
            neck = { collected = false },
            ring = { count = 1, total = 2 },
        },
        weapons = {
            { type = "lightningStaff", collected = true },
            { type = "restorationStaff", collected = false },
        },
    },
    {
        name = "Martial Knowledge",
        setId = 147,
        lookupName = "Way of Martial Knowledge",
        source = "Overland - Craglorn",
        pieces = {
            head = { collected = true },
            shoulders = { collected = false },
            chest = { collected = false },
            hands = { collected = true },
            waist = { collected = true },
            legs = { collected = false },
            feet = { collected = true },
            neck = { collected = true },
            ring = { count = 2, total = 2 },
        },
        weapons = {
            { type = "lightningStaff", collected = false },
            { type = "restorationStaff", collected = true },
            { type = "bow", collected = false },
        },
    },
}
