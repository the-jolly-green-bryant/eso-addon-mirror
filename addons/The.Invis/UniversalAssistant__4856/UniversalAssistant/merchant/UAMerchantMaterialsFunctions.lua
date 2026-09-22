local ua = UAssistant
local merchant = ua.Merchant

merchant.furnishingMaterialDefinitions = {
    { itemId = 114889 },
    { itemId = 114890 },
    { itemId = 114891 },
    { itemId = 114892 },
    { itemId = 114893 },
    { itemId = 114894 },
    { itemId = 114895 },
    { itemId = 135161 },
}

merchant.furnishingMaterialItemIds = {}

for _, definition in ipairs(merchant.furnishingMaterialDefinitions) do
    merchant.furnishingMaterialItemIds[definition.itemId] = true
end

merchant.rawMaterialDefinitions = {
    blacksmithing = {
        { itemId = 808, masterField = "blacksmithingRawEnabled" },
        { itemId = 5820, masterField = "blacksmithingRawEnabled" },
        { itemId = 23103, masterField = "blacksmithingRawEnabled" },
        { itemId = 23104, masterField = "blacksmithingRawEnabled" },
        { itemId = 23105, masterField = "blacksmithingRawEnabled" },
        { itemId = 4482, masterField = "blacksmithingRawEnabled" },
        { itemId = 23133, masterField = "blacksmithingRawEnabled" },
        { itemId = 23134, masterField = "blacksmithingRawEnabled" },
        { itemId = 23135, masterField = "blacksmithingRawEnabled" },
        {
            itemId = 71198,
            masterField = "blacksmithingRawEnabled",
            maximum = true,
        },
    },
    clothing = {
        { itemId = 812, masterField = "clothingRawMaterialsEnabled" },
        { itemId = 793, masterField = "leatherRawMaterialsEnabled" },
        { itemId = 4464, masterField = "clothingRawMaterialsEnabled" },
        { itemId = 4448, masterField = "leatherRawMaterialsEnabled" },
        { itemId = 23129, masterField = "clothingRawMaterialsEnabled" },
        { itemId = 23095, masterField = "leatherRawMaterialsEnabled" },
        { itemId = 23130, masterField = "clothingRawMaterialsEnabled" },
        { itemId = 6020, masterField = "leatherRawMaterialsEnabled" },
        { itemId = 23131, masterField = "clothingRawMaterialsEnabled" },
        { itemId = 23097, masterField = "leatherRawMaterialsEnabled" },
        { itemId = 33217, masterField = "clothingRawMaterialsEnabled" },
        { itemId = 23142, masterField = "leatherRawMaterialsEnabled" },
        { itemId = 33218, masterField = "clothingRawMaterialsEnabled" },
        { itemId = 23143, masterField = "leatherRawMaterialsEnabled" },
        { itemId = 33219, masterField = "clothingRawMaterialsEnabled" },
        { itemId = 800, masterField = "leatherRawMaterialsEnabled" },
        { itemId = 33220, masterField = "clothingRawMaterialsEnabled" },
        { itemId = 4478, masterField = "leatherRawMaterialsEnabled" },
        {
            itemId = 71200,
            masterField = "clothingRawMaterialsEnabled",
            maximum = true,
        },
        {
            itemId = 71239,
            masterField = "leatherRawMaterialsEnabled",
            maximum = true,
        },
    },
    woodworking = {
        { itemId = 802, masterField = "woodworkingRawEnabled" },
        { itemId = 521, masterField = "woodworkingRawEnabled" },
        { itemId = 23117, masterField = "woodworkingRawEnabled" },
        { itemId = 23118, masterField = "woodworkingRawEnabled" },
        { itemId = 23119, masterField = "woodworkingRawEnabled" },
        { itemId = 818, masterField = "woodworkingRawEnabled" },
        { itemId = 4439, masterField = "woodworkingRawEnabled" },
        { itemId = 23137, masterField = "woodworkingRawEnabled" },
        { itemId = 23138, masterField = "woodworkingRawEnabled" },
        {
            itemId = 71199,
            masterField = "woodworkingRawEnabled",
            maximum = true,
        },
    },
    jewelry = {
        { itemId = 135137, masterField = "jewelryRawMaterialsEnabled" },
        { itemId = 135139, masterField = "jewelryRawMaterialsEnabled" },
        { itemId = 135141, masterField = "jewelryRawMaterialsEnabled" },
        { itemId = 135143, masterField = "jewelryRawMaterialsEnabled" },
        {
            itemId = 135145,
            masterField = "jewelryRawMaterialsEnabled",
            maximum = true,
        },
    },
    style = {
        { itemId = 69556 },
        { itemId = 59923 },
        { itemId = 57665 },
        { itemId = 75371 },
        { itemId = 64688 },
        { itemId = 121523 },
        { itemId = 64690 },
        { itemId = 81995 },
        { itemId = 81997 },
        { itemId = 130062 },
        { itemId = 130058 },
        { itemId = 76911 },
        { itemId = 121521 },
        { itemId = 121522 },
    },
}

merchant.rawMaterialItemIds = {}
merchant.rawMaterialGroupsByField = {}
merchant.rawMaterialMasterFieldsByItemId = {}

for _, definitions in pairs(merchant.rawMaterialDefinitions) do
    for _, definition in ipairs(definitions) do
        merchant.rawMaterialItemIds[definition.itemId] = true
        if definition.masterField and not definition.maximum then
            merchant.rawMaterialMasterFieldsByItemId[definition.itemId] = definition.masterField
            merchant.rawMaterialGroupsByField[definition.masterField] = merchant.rawMaterialGroupsByField[definition.masterField]
                or {}
            table.insert(
                merchant.rawMaterialGroupsByField[definition.masterField],
                definition.itemId
            )
        end
    end
end

local function CreateDefaults()
    return {
        blacksmithingEnabled = false,
        blacksmithingRawEnabled = false,
        clothingMaterialsEnabled = false,
        clothingRawMaterialsEnabled = false,
        leatherMaterialsEnabled = false,
        leatherRawMaterialsEnabled = false,
        woodworkingEnabled = false,
        woodworkingRawEnabled = false,
        jewelryMaterialsEnabled = false,
        jewelryRawMaterialsEnabled = false,
        rawMaterials = {},
        rawMaterialsMigrated = false,
        rawMaterialMaximumsMigrated = false,
        furnishingMaterialsEnabled = false,
        furnishingMaterials = {},
        styleMaterialsEnabled = false,
        styleMaterials = {},
    }
end

local MOTIF_STYLE_IDS = {
    7,
    4,
    8,
    5,
    1,
    2,
    9,
    3,
    6,
    34,
    15,
    17,
    19,
    20,
    14,
    28,
    29,
    33,
    26,
    35,
    22,
    21,
    13,
    47,
    25,
    23,
    24,
    44,
    30,
    43,
    42,
    41,
    11,
    46,
    45,
    12,
    40,
    31,
    39,
    16,
    27,
    59,
    58,
    56,
    57,
    53,
    52,
    54,
    50,
    51,
    49,
    48,
    38,
    61,
    62,
    65,
    66,
    69,
    70,
    55,
    71,
    72,
    74,
    75,
    77,
    78,
    73,
    80,
    79,
    81,
    82,
    83,
    84,
    85,
    86,
    92,
    89,
    93,
    60,
    95,
    94,
    97,
    98,
    100,
    101,
    102,
    103,
    105,
    104,
    106,
    107,
    108,
    109,
    110,
    111,
    112,
    113,
    114,
    117,
    116,
    121,
    122,
    120,
    119,
    123,
    124,
    125,
    126,

    128,

    129,
    130,
    131,
    132,
    135,
    136,
    138,
    139,
    141,
    140,
    142,
    143,
    144,
    145,
    146,
    147,
    148,
    149,
    151,
    153,
    154,
    155,
    156,
    157,
    158,
    159,
    162,
}

function merchant.GetStyleMaterialDefinitions()
    if merchant.styleMaterialDefinitions then
        return merchant.styleMaterialDefinitions
    end

    local definitions = {}
    local itemIds = {}
    local highestStyleId = GetHighestItemStyleId()
    local motifNumber = 0

    for _, styleId in ipairs(MOTIF_STYLE_IDS) do
        motifNumber = motifNumber + 1
        if motifNumber == 109 or motifNumber == 111 then
            motifNumber = motifNumber + 1
        end

        local itemLink = styleId <= highestStyleId and GetItemStyleMaterialLink(styleId)

        if itemLink and itemLink ~= "" then
            local itemId = GetItemLinkItemId(itemLink)

            if itemId and itemId > 0 and not itemIds[itemId] then
                itemIds[itemId] = true

                table.insert(definitions, {
                    itemId = itemId,
                    itemLink = itemLink,
                    name = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink)),
                    styleName = GetItemStyleName(styleId),
                    motifNumber = motifNumber,
                })
            end
        end
    end

    merchant.styleMaterialDefinitions = definitions
    merchant.styleMaterialItemIds = itemIds

    return definitions
end

local function InitializeProfile(profile)
    if type(profile.rawMaterials) ~= "table" then
        profile.rawMaterials = {}
    end
    for itemId in pairs(merchant.rawMaterialItemIds) do
        if profile.rawMaterials[itemId] == nil then
            profile.rawMaterials[itemId] = false
        end
    end
    if not profile.rawMaterialsMigrated then
        for field, itemIds in pairs(merchant.rawMaterialGroupsByField) do
            if profile[field] then
                for _, itemId in ipairs(itemIds) do
                    profile.rawMaterials[itemId] = true
                end
            end
        end
        profile.rawMaterialsMigrated = true
    end
    if not profile.rawMaterialMaximumsMigrated then
        for _, definitions in pairs(merchant.rawMaterialDefinitions) do
            for _, definition in ipairs(definitions) do
                if definition.maximum then
                    profile.rawMaterials[definition.itemId] = false
                end
            end
        end
        profile.rawMaterialMaximumsMigrated = true
    end
    if type(profile.furnishingMaterials) ~= "table" then
        profile.furnishingMaterials = {}
    end
    for _, definition in ipairs(merchant.furnishingMaterialDefinitions) do
        if profile.furnishingMaterials[definition.itemId] == nil then
            profile.furnishingMaterials[definition.itemId] = false
        end
    end
    if type(profile.styleMaterials) ~= "table" then
        profile.styleMaterials = {}
    end
    for _, definition in ipairs(merchant.GetStyleMaterialDefinitions()) do
        if profile.styleMaterials[definition.itemId] == nil then
            profile.styleMaterials[definition.itemId] = false
        end
    end
end

local function IsSelectedRawMaterial(profile, itemLink)
    if type(profile.rawMaterials) ~= "table" then
        return false
    end
    local itemId = GetItemLinkItemId(itemLink)
    return merchant.rawMaterialItemIds[itemId] == true and profile.rawMaterials[itemId] == true
end

function merchant.SetRawMaterialGroupSelection(profile, field, value)
    profile[field] = value
    for _, itemId in ipairs(merchant.rawMaterialGroupsByField[field] or {}) do
        profile.rawMaterials[itemId] = value
    end
end

function merchant.SetRawMaterialSelection(profile, itemId, value)
    profile.rawMaterials[itemId] = value
    local field = merchant.rawMaterialMasterFieldsByItemId[itemId]
    if not field then
        return
    end
    for _, groupItemId in ipairs(merchant.rawMaterialGroupsByField[field] or {}) do
        if profile.rawMaterials[groupItemId] ~= true then
            profile[field] = false
            return
        end
    end
    profile[field] = true
end

local function IsSelectedFurnishingMaterial(profile, itemLink)
    if not profile.furnishingMaterialsEnabled or type(profile.furnishingMaterials) ~= "table" then
        return false
    end
    local itemId = GetItemLinkItemId(itemLink)
    return merchant.furnishingMaterialItemIds[itemId] == true
        and profile.furnishingMaterials[itemId] == true
end

local function IsSelectedStyleMaterial(profile, itemLink)
    if not profile.styleMaterialsEnabled or type(profile.styleMaterials) ~= "table" then
        return false
    end
    merchant.GetStyleMaterialDefinitions()
    local itemId = GetItemLinkItemId(itemLink)
    return merchant.styleMaterialItemIds[itemId] == true and profile.styleMaterials[itemId] == true
end

merchant.RegisterProfile("materials", CreateDefaults, InitializeProfile)

local RUBEDITE_INGOT_ITEM_ID = 64489
local ANCESTOR_SILK_ITEM_ID = 64504
local RUBEDO_LEATHER_ITEM_ID = 64506
local SANDED_RUBY_ASH_ITEM_ID = 64502
local PLATINUM_OUNCE_ITEM_ID = 135146

local FABRIC_MATERIAL_IDS = {
    [811] = true,
    [4463] = true,
    [23125] = true,
    [23126] = true,
    [23127] = true,
    [46131] = true,
    [46132] = true,
    [46133] = true,
    [46134] = true,
    [ANCESTOR_SILK_ITEM_ID] = true,
}

local LEATHER_MATERIAL_IDS = {
    [794] = true,
    [4447] = true,
    [23099] = true,
    [23100] = true,
    [23101] = true,
    [46135] = true,
    [46136] = true,
    [46137] = true,
    [46138] = true,
    [RUBEDO_LEATHER_ITEM_ID] = true,
}

merchant.RegisterCategory("materials", function(profile, bagId, slotIndex, itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local itemId = GetItemLinkItemId(itemLink)

    if IsSelectedRawMaterial(profile, itemLink) then
        return true
    end

    if
        profile.blacksmithingEnabled
        and itemType == ITEMTYPE_BLACKSMITHING_MATERIAL
        and itemId ~= RUBEDITE_INGOT_ITEM_ID
    then
        return true
    end

    if
        profile.clothingMaterialsEnabled
        and itemType == ITEMTYPE_CLOTHIER_MATERIAL
        and FABRIC_MATERIAL_IDS[itemId]
        and itemId ~= ANCESTOR_SILK_ITEM_ID
    then
        return true
    end

    if
        profile.leatherMaterialsEnabled
        and itemType == ITEMTYPE_CLOTHIER_MATERIAL
        and LEATHER_MATERIAL_IDS[itemId]
        and itemId ~= RUBEDO_LEATHER_ITEM_ID
    then
        return true
    end

    if
        profile.jewelryMaterialsEnabled
        and itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL
        and itemId ~= PLATINUM_OUNCE_ITEM_ID
    then
        return true
    end

    if
        profile.woodworkingEnabled
        and itemType == ITEMTYPE_WOODWORKING_MATERIAL
        and itemId ~= SANDED_RUBY_ASH_ITEM_ID
    then
        return true
    end

    if IsSelectedFurnishingMaterial(profile, itemLink) then
        return true
    end

    return itemType == ITEMTYPE_STYLE_MATERIAL and IsSelectedStyleMaterial(profile, itemLink)
end)
