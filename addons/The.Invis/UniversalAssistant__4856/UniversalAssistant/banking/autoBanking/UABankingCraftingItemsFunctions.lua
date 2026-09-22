local ua = UAssistant
local banking = ua.Banking
local autoBanking = ua.Banking.AutoBanking

autoBanking.CraftingItems = autoBanking.CraftingItems or {}
local craftingItems = autoBanking.CraftingItems

local DEFAULT_MODE = autoBanking.MODE_NONE
local LUMINOUS_INK_ITEM_ID = 204881

local CATEGORIES = {
    {
        key = "blacksmithing",
        nameKey = "BLACKSMITHING",
        craftingType = CRAFTING_TYPE_BLACKSMITHING,
        icon = "/esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds",
        itemTypes = {
            ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
            ITEMTYPE_BLACKSMITHING_MATERIAL,
            ITEMTYPE_BLACKSMITHING_BOOSTER,
        },
    },
    {
        key = "clothing",
        nameKey = "CLOTHING_CRAFT",
        craftingType = CRAFTING_TYPE_CLOTHIER,
        icon = "/esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds",
        itemTypes = {
            ITEMTYPE_CLOTHIER_RAW_MATERIAL,
            ITEMTYPE_CLOTHIER_MATERIAL,
            ITEMTYPE_CLOTHIER_BOOSTER,
        },
    },
    {
        key = "woodworking",
        nameKey = "WOODWORKING",
        craftingType = CRAFTING_TYPE_WOODWORKING,
        icon = "/esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds",
        itemTypes = {
            ITEMTYPE_WOODWORKING_RAW_MATERIAL,
            ITEMTYPE_WOODWORKING_MATERIAL,
            ITEMTYPE_WOODWORKING_BOOSTER,
        },
    },
    {
        key = "jewelryCrafting",
        nameKey = "JEWELRY_CRAFTING",
        craftingType = CRAFTING_TYPE_JEWELRYCRAFTING,
        icon = "/esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds",
        itemTypes = {
            ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
            ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
            ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
        },
    },
    {
        key = "alchemy",
        nameKey = "ALCHEMY",
        craftingType = CRAFTING_TYPE_ALCHEMY,
        icon = "/esoui/art/inventory/inventory_tabicon_craftbag_alchemy_up.dds",
        itemTypes = {
            ITEMTYPE_REAGENT,
            ITEMTYPE_POISON_BASE,
            ITEMTYPE_POTION_BASE,
        },
    },
    {
        key = "enchanting",
        nameKey = "ENCHANTING",
        craftingType = CRAFTING_TYPE_ENCHANTING,
        icon = "/esoui/art/inventory/inventory_tabicon_craftbag_enchanting_up.dds",
        itemTypes = {
            ITEMTYPE_ENCHANTING_RUNE_ASPECT,
            ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
            ITEMTYPE_ENCHANTING_RUNE_POTENCY,
        },
    },
    {
        key = "provisioning",
        nameKey = "PROVISIONING",
        craftingType = CRAFTING_TYPE_PROVISIONING,
        icon = "/esoui/art/inventory/inventory_tabicon_craftbag_provisioning_up.dds",
        itemTypes = {
            ITEMTYPE_INGREDIENT,
            ITEMTYPE_LURE,
        },
    },
    {
        key = "scribingMaterials",
        nameKey = "SCRIBING_MATERIALS",
        icon = "/esoui/art/crafting/scribing_tabicon_scribing_up.dds",
        itemTypes = {},
        specificItems = {
            {
                itemId = LUMINOUS_INK_ITEM_ID,
                nameKey = "LUMINOUS_INK",
            },
        },
    },
    {
        key = "styleMaterials",
        nameKey = "STYLE_MATERIALS",
        nameItemType = ITEMTYPE_STYLE_MATERIAL,
        icon = "/esoui/art/inventory/inventory_tabicon_craftbag_stylematerial_up.dds",
        itemTypes = {
            ITEMTYPE_RAW_MATERIAL,
            ITEMTYPE_STYLE_MATERIAL,
        },
    },
    {
        key = "traitItems",
        nameKey = "TRAIT_ITEMS",
        nameStringId = SI_CRAFTING_COMPONENT_TOOLTIP_TRAITS,
        icon = "/esoui/art/inventory/inventory_tabicon_craftbag_itemtrait_up.dds",
        itemTypes = {
            ITEMTYPE_ARMOR_TRAIT,
            ITEMTYPE_WEAPON_TRAIT,
            ITEMTYPE_JEWELRY_RAW_TRAIT,
            ITEMTYPE_JEWELRY_TRAIT,
        },
    },
    {
        key = "furnishings",
        nameKey = "FURNISHINGS",
        nameItemType = ITEMTYPE_FURNISHING_MATERIAL,
        icon = "/esoui/art/crafting/provisioner_indexicon_furnishings_up.dds",
        itemTypes = {
            ITEMTYPE_FURNISHING_MATERIAL,
        },
    },
}

local CRAFTING_ITEM_TYPES = {}

for _, category in ipairs(CATEGORIES) do
    for _, itemType in ipairs(category.itemTypes) do
        CRAFTING_ITEM_TYPES[itemType] = true
    end
end

local function L(key)
    return ua.GetString("BANKING_" .. key)
end

local ITEM_TYPE_NAME_KEYS = {
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = "RAW_MATERIAL",
    [ITEMTYPE_BLACKSMITHING_MATERIAL] = "MATERIAL",
    [ITEMTYPE_BLACKSMITHING_BOOSTER] = "TEMPER",
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = "RAW_MATERIAL",
    [ITEMTYPE_CLOTHIER_MATERIAL] = "MATERIAL",
    [ITEMTYPE_CLOTHIER_BOOSTER] = "TEMPER",
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = "RAW_MATERIAL",
    [ITEMTYPE_WOODWORKING_MATERIAL] = "MATERIAL",
    [ITEMTYPE_WOODWORKING_BOOSTER] = "TEMPER",
    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = "RAW_MATERIAL",
    [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = "MATERIAL",
    [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = "PLATING",
    [ITEMTYPE_REAGENT] = "REAGENT",
    [ITEMTYPE_POISON_BASE] = "POISON_BASE",
    [ITEMTYPE_POTION_BASE] = "POTION_BASE",
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = "ASPECT_RUNE",
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = "ESSENCE_RUNE",
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = "POTENCY_RUNE",
    [ITEMTYPE_INGREDIENT] = "INGREDIENT",
    [ITEMTYPE_LURE] = "LURE",
    [ITEMTYPE_RAW_MATERIAL] = "RAW_MATERIAL",
    [ITEMTYPE_STYLE_MATERIAL] = "STYLE_MATERIAL",
    [ITEMTYPE_ARMOR_TRAIT] = "ARMOR_TRAIT",
    [ITEMTYPE_WEAPON_TRAIT] = "WEAPON_TRAIT",
    [ITEMTYPE_JEWELRY_RAW_TRAIT] = "JEWELRY_RAW_TRAIT",
    [ITEMTYPE_JEWELRY_TRAIT] = "JEWELRY_TRAIT",
    [ITEMTYPE_FURNISHING_MATERIAL] = "FURNISHING_MATERIAL",
}

local ITEM_TYPE_ICON_ITEM_IDS = {
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = 71198,
    [ITEMTYPE_BLACKSMITHING_MATERIAL] = 64489,
    [ITEMTYPE_BLACKSMITHING_BOOSTER] = 54173,
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = 71200,
    [ITEMTYPE_CLOTHIER_MATERIAL] = 64504,
    [ITEMTYPE_CLOTHIER_BOOSTER] = 54177,
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = 71199,
    [ITEMTYPE_WOODWORKING_MATERIAL] = 64502,
    [ITEMTYPE_WOODWORKING_BOOSTER] = 54181,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = 135145,
    [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = 135146,
    [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = 135154,
    [ITEMTYPE_REAGENT] = 30165,
    [ITEMTYPE_POISON_BASE] = 75365,
    [ITEMTYPE_POTION_BASE] = 64501,
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = 45854,
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = 45831,
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = 68341,
    [ITEMTYPE_INGREDIENT] = 64222,
    [ITEMTYPE_LURE] = 42873,
    [ITEMTYPE_RAW_MATERIAL] = 69556,
    [ITEMTYPE_ARMOR_TRAIT] = 4456,
    [ITEMTYPE_WEAPON_TRAIT] = 23203,
    [ITEMTYPE_JEWELRY_RAW_TRAIT] = 135159,
    [ITEMTYPE_JEWELRY_TRAIT] = 135156,
    [ITEMTYPE_FURNISHING_MATERIAL] = 114889,
}

local ITEM_TYPE_FALLBACK_ICONS = {
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = "/esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds",
    [ITEMTYPE_BLACKSMITHING_MATERIAL] = "/esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds",
    [ITEMTYPE_BLACKSMITHING_BOOSTER] = "/esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds",
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = "/esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds",
    [ITEMTYPE_CLOTHIER_MATERIAL] = "/esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds",
    [ITEMTYPE_CLOTHIER_BOOSTER] = "/esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds",
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = "/esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds",
    [ITEMTYPE_WOODWORKING_MATERIAL] = "/esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds",
    [ITEMTYPE_WOODWORKING_BOOSTER] = "/esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds",
    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = "/esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds",
    [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = "/esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds",
    [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = "/esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds",
}

local function CreateItemLink(itemId)
    return string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
end

local function GetSpecificItemSettingKey(itemId)
    return "item:" .. tostring(itemId)
end

local function GetSpecificItemName(definition)
    local fallback = L(definition.nameKey)

    if ua.GetLanguageCode() == "ua" then
        return fallback
    end

    local itemLink = CreateItemLink(definition.itemId)
    local name = GetItemLinkName(itemLink)

    if name and name ~= "" then
        return zo_strformat("<<C:1>>", name)
    end

    return fallback
end

local function FindOwnedItemTypeIcon(itemType)
    local bags = {
        BAG_BACKPACK,
        BAG_BANK,
        BAG_SUBSCRIBER_BANK,
        BAG_VIRTUAL,
    }

    for _, bagId in ipairs(bags) do
        for slotIndex = 0, GetBagSize(bagId) - 1 do
            local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)

            if itemLink and itemLink ~= "" and GetItemLinkItemType(itemLink) == itemType then
                local icon = GetItemLinkIcon(itemLink)

                if icon and icon ~= "" then
                    return icon
                end
            end
        end
    end
end

local function GetItemTypeIcon(itemType)
    craftingItems.itemTypeIcons = craftingItems.itemTypeIcons or {}

    local cached = craftingItems.itemTypeIcons[itemType]

    if cached then
        return cached
    end

    local itemLink

    if itemType == ITEMTYPE_STYLE_MATERIAL then
        itemLink = GetItemStyleMaterialLink(1)
    else
        local itemId = ITEM_TYPE_ICON_ITEM_IDS[itemType]
        itemLink = itemId and CreateItemLink(itemId)
    end

    if itemLink and itemLink ~= "" and GetItemLinkItemType(itemLink) ~= itemType then
        itemLink = nil
    end

    local icon = itemLink and itemLink ~= "" and GetItemLinkIcon(itemLink)

    if not icon or icon == "" then
        icon = FindOwnedItemTypeIcon(itemType)
    end

    if not icon or icon == "" then
        icon = ITEM_TYPE_FALLBACK_ICONS[itemType]
            or "/esoui/art/inventory/inventory_tabicon_craftbag_up.dds"
    end

    craftingItems.itemTypeIcons[itemType] = icon

    return icon
end

function craftingItems.IsEnabled()
    return ua.savedVariables.banking and ua.savedVariables.banking.craftingItemsEnabled == true
end

function craftingItems.MatchesItemLink(itemLink)
    if GetItemLinkItemId(itemLink) == LUMINOUS_INK_ITEM_ID then
        return true
    end

    return CRAFTING_ITEM_TYPES[GetItemLinkItemType(itemLink)] == true
end

local function GetEffectiveMode(settings, key)
    local stackPlacement = autoBanking.StackPlacement

    if stackPlacement and stackPlacement.ShouldForcePersonalBankDeposit() then
        return autoBanking.MODE_DEPOSIT
    end

    local mode = settings[key]

    if autoBanking.IsValidMode(mode) then
        return mode
    end

    return DEFAULT_MODE
end

local function RefreshCategoryMenus()
    local allModeControl = _G["UABankingCraftingItemsAllMode"]

    if allModeControl and allModeControl.UpdateDisabled then
        allModeControl:UpdateDisabled()
    end

    for _, category in ipairs(CATEGORIES) do
        local control = _G["UABankingCraftingItems" .. category.key]

        if control and control.UpdateDisabled then
            control:UpdateDisabled()
        end
    end
end

local function GetItemModeReference(itemType)
    return "UABankingCraftingItemMode" .. tostring(itemType)
end

local function RefreshItemModeControls()
    for _, category in ipairs(CATEGORIES) do
        for _, itemType in ipairs(category.itemTypes) do
            local control = _G[GetItemModeReference(itemType)]

            if control and control.UpdateValue then
                control:UpdateValue()
            end
        end

        for _, definition in ipairs(category.specificItems or {}) do
            local settingKey = GetSpecificItemSettingKey(definition.itemId)
            local control = _G[GetItemModeReference(settingKey)]

            if control and control.UpdateValue then
                control:UpdateValue()
            end
        end
    end
end

local function RefreshAllModeControl()
    local control = _G["UABankingCraftingItemsAllMode"]

    if control and control.UpdateValue then
        control:UpdateValue()
    end
end

function craftingItems.CreateEnableControl()
    return {
        type = "checkbox",
        name = L("ENABLE_CRAFTING_ITEMS"),
        tooltip = L("ENABLE_CRAFTING_ITEMS_TOOLTIP"),
        getFunc = function()
            return craftingItems.IsEnabled()
        end,
        setFunc = function(value)
            ua.savedVariables.banking.craftingItemsEnabled = value
            RefreshCategoryMenus()

            if autoBanking.StackPlacement then
                autoBanking.StackPlacement.RefreshControls()
            end
        end,
        default = false,
    }
end

local function GetCategoryName(category)
    if category.craftingType then
        local fallback = category.nameKey and L(category.nameKey)

        if ua.GetLanguageCode() == "ua" and fallback and fallback ~= "" then
            return fallback
        end

        local name = GetString("SI_TRADESKILLTYPE", category.craftingType)

        if name and name ~= "" then
            return zo_strformat("<<C:1>>", name)
        end

        return fallback
    end

    if category.nameItemType then
        return banking.GetItemTypeName(category.nameItemType, L(category.nameKey))
    end

    if category.nameStringId then
        return banking.GetGameString(category.nameStringId, L(category.nameKey))
    end

    return L(category.nameKey)
end

local function GetItemTypeName(itemType)
    local nameKey = ITEM_TYPE_NAME_KEYS[itemType]

    return banking.GetItemTypeName(itemType, nameKey and L(nameKey) or nil)
end

function craftingItems.GetSettings()
    local savedVariables = ua.savedVariables
    savedVariables.banking = savedVariables.banking or {}
    savedVariables.banking.craftingItems = savedVariables.banking.craftingItems or {}

    local settings = savedVariables.banking.craftingItems

    if not autoBanking.IsValidMode(settings.allMode) then
        settings.allMode = DEFAULT_MODE
    end

    if ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER then
        settings[ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = nil
    end

    for _, category in ipairs(CATEGORIES) do
        for _, itemType in ipairs(category.itemTypes) do
            if not autoBanking.IsValidMode(settings[itemType]) then
                settings[itemType] = DEFAULT_MODE
            end
        end

        for _, definition in ipairs(category.specificItems or {}) do
            local settingKey = GetSpecificItemSettingKey(definition.itemId)

            if not autoBanking.IsValidMode(settings[settingKey]) then
                settings[settingKey] = DEFAULT_MODE
            end
        end
    end

    if settings.allMode ~= DEFAULT_MODE then
        for _, category in ipairs(CATEGORIES) do
            for _, itemType in ipairs(category.itemTypes) do
                settings[itemType] = settings.allMode
            end

            for _, definition in ipairs(category.specificItems or {}) do
                settings[GetSpecificItemSettingKey(definition.itemId)] = settings.allMode
            end
        end
    end

    return settings
end

function craftingItems.CreateAllModeControl()
    local settings = craftingItems.GetSettings()

    return {
        type = "dropdown",
        name = L("ALL_CRAFTING_ITEMS_MODE"),
        tooltip = L("ALL_CRAFTING_ITEMS_MODE_TOOLTIP"),
        choices = banking.GetBankModeChoices(),
        choicesValues = {
            autoBanking.MODE_NONE,
            autoBanking.MODE_DEPOSIT,
            autoBanking.MODE_WITHDRAW,
        },
        getFunc = function()
            return settings.allMode
        end,
        setFunc = function(value)
            settings.allMode = value

            for _, category in ipairs(CATEGORIES) do
                for _, itemType in ipairs(category.itemTypes) do
                    settings[itemType] = value
                end

                for _, definition in ipairs(category.specificItems or {}) do
                    settings[GetSpecificItemSettingKey(definition.itemId)] = value
                end
            end

            RefreshItemModeControls()
        end,
        disabled = function()
            return not craftingItems.IsEnabled()
        end,
        default = DEFAULT_MODE,
        reference = "UABankingCraftingItemsAllMode",
    }
end

function craftingItems.Initialize()
    local settings = craftingItems.GetSettings()

    for _, category in ipairs(CATEGORIES) do
        for _, itemType in ipairs(category.itemTypes) do
            local currentItemType = itemType

            autoBanking.RegisterRule("crafting:" .. tostring(currentItemType), function()
                if not craftingItems.IsEnabled() then
                    return autoBanking.MODE_NONE
                end

                return GetEffectiveMode(settings, currentItemType)
            end, function(itemLink)
                return GetItemLinkItemType(itemLink) == currentItemType
                    and GetItemLinkItemId(itemLink) ~= LUMINOUS_INK_ITEM_ID
            end)
        end

        for _, definition in ipairs(category.specificItems or {}) do
            local currentDefinition = definition
            local settingKey = GetSpecificItemSettingKey(currentDefinition.itemId)

            autoBanking.RegisterRule("crafting:" .. settingKey, function()
                if not craftingItems.IsEnabled() then
                    return autoBanking.MODE_NONE
                end

                return GetEffectiveMode(settings, settingKey)
            end, function(itemLink)
                return GetItemLinkItemId(itemLink) == currentDefinition.itemId
            end)
        end
    end
end

local function CreateDropdown(itemType, settings)
    local itemTypeName = GetItemTypeName(itemType)
    local displayName = zo_iconFormat(GetItemTypeIcon(itemType), 24, 24) .. " " .. itemTypeName

    return {
        type = "dropdown",
        name = displayName,
        tooltip = string.format(L("CRAFTING_ITEM_MODE_TOOLTIP"), itemTypeName),
        choices = banking.GetBankModeChoices(),
        choicesValues = {
            autoBanking.MODE_NONE,
            autoBanking.MODE_DEPOSIT,
            autoBanking.MODE_WITHDRAW,
        },
        getFunc = function()
            local mode = settings[itemType]

            if autoBanking.IsValidMode(mode) then
                return mode
            end

            return DEFAULT_MODE
        end,
        setFunc = function(value)
            settings[itemType] = value
            settings.allMode = DEFAULT_MODE
            RefreshAllModeControl()
        end,
        default = DEFAULT_MODE,
        reference = GetItemModeReference(itemType),
    }
end

local function CreateSpecificItemDropdown(definition, settings)
    local settingKey = GetSpecificItemSettingKey(definition.itemId)
    local itemName = GetSpecificItemName(definition)
    local itemLink = CreateItemLink(definition.itemId)
    local icon = GetItemLinkIcon(itemLink)
    local displayName = zo_iconFormat(icon, 24, 24) .. " " .. itemName

    return {
        type = "dropdown",
        name = displayName,
        tooltip = string.format(L("CRAFTING_ITEM_MODE_TOOLTIP"), itemName),
        choices = banking.GetBankModeChoices(),
        choicesValues = {
            autoBanking.MODE_NONE,
            autoBanking.MODE_DEPOSIT,
            autoBanking.MODE_WITHDRAW,
        },
        getFunc = function()
            local mode = settings[settingKey]

            if autoBanking.IsValidMode(mode) then
                return mode
            end

            return DEFAULT_MODE
        end,
        setFunc = function(value)
            settings[settingKey] = value
            settings.allMode = DEFAULT_MODE
            RefreshAllModeControl()
        end,
        default = DEFAULT_MODE,
        reference = GetItemModeReference(settingKey),
    }
end

local function CreateCategoryMenu(category, settings)
    local controls = {}

    for _, itemType in ipairs(category.itemTypes) do
        table.insert(controls, CreateDropdown(itemType, settings))
    end

    for _, definition in ipairs(category.specificItems or {}) do
        table.insert(controls, CreateSpecificItemDropdown(definition, settings))
    end

    local categoryName = GetCategoryName(category)

    local categoryIcon = category.icon

    if category.iconItemId then
        categoryIcon = GetItemLinkIcon(CreateItemLink(category.iconItemId))
    end

    return {
        type = "submenu",
        name = zo_iconFormat(categoryIcon, 32, 32) .. " " .. categoryName,
        tooltip = string.format(L("CRAFTING_CATEGORY_TOOLTIP"), categoryName),
        disabled = function()
            return not craftingItems.IsEnabled()
        end,
        reference = "UABankingCraftingItems" .. category.key,
        controls = controls,
    }
end

function craftingItems.CreateMenuControls()
    local settings = craftingItems.GetSettings()
    local controls = {}

    for _, category in ipairs(CATEGORIES) do
        table.insert(controls, CreateCategoryMenu(category, settings))
    end

    return controls
end
