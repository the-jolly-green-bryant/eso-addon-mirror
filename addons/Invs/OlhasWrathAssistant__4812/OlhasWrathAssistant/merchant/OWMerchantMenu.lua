local owa = OWAssistant
local merchant = owa.Merchant

local EMPTY_SOUL_GEM_ITEM_ID = 33265

local function L(key)
    return owa.GetString("MERCHANT_" .. key)
end

local function CreateCheckbox(
    profile,
    field,
    name,
    tooltip,
    isEnableCheckbox,
    parentField
)
    return {
        type = "checkbox",
        name = name,
        tooltip = tooltip,

        getFunc = function()
            return profile[field]
        end,

        setFunc = function(value)
            profile[field] = value
        end,

        default = false,

        disabled = function()
            return not isEnableCheckbox
                and not profile[parentField or "enabled"]
        end,
    }
end

local function CreateQualityDropdown(
    profile,
    name,
    tooltip,
    field,
    parentField
)
    field = field or "maxQuality"
    parentField = parentField or "enabled"

    local choices = {
        "|cFFFFFF" .. L("QUALITY_NORMAL") .. "|r",
        "|c2DC50E" .. L("QUALITY_FINE") .. "|r",
        "|c3A92FF" .. L("QUALITY_SUPERIOR") .. "|r",
        "|cA02EF7" .. L("QUALITY_EPIC") .. "|r",
        "|cCFAF37" .. L("QUALITY_LEGENDARY") .. "|r",
    }

    local choiceValues = {
        ITEM_QUALITY_NORMAL,
        ITEM_QUALITY_MAGIC,
        ITEM_QUALITY_ARCANE,
        ITEM_QUALITY_ARTIFACT,
        ITEM_QUALITY_LEGENDARY,
    }

    return {
        type = "dropdown",
        name = name,
        tooltip = tooltip,
        choices = choices,
        choicesValues = choiceValues,

        getFunc = function()
            return profile[field]
        end,

        setFunc = function(value)
            if type(value) == "number" then
                profile[field] = value
            end
        end,

        default = ITEM_QUALITY_NORMAL,

        disabled = function()
            return not profile[parentField]
        end,
    }
end

local function CreateConsumablesControls()
    local profile = merchant.GetProfile("consumables")

    return {
        CreateCheckbox(
            profile,
            "foodDrinkEnabled",
            L("FOOD_DRINK_ENABLE"),
            L("FOOD_DRINK_ENABLE_TOOLTIP"),
            true
        ),
        CreateQualityDropdown(
            profile,
            L("FOOD_DRINK_MAX_QUALITY"),
            L("FOOD_DRINK_MAX_QUALITY_TOOLTIP"),
            "foodDrinkMaxQuality",
            "foodDrinkEnabled"
        ),
        CreateCheckbox(
            profile,
            "excludeFoodDrinkCP150",
            L("FOOD_DRINK_EXCLUDE_CP150"),
            L("FOOD_DRINK_EXCLUDE_CP150_TOOLTIP"),
            false,
            "foodDrinkEnabled"
        ),
        CreateCheckbox(
            profile,
            "nonCraftedFoodDrink",
            L("FOOD_DRINK_NON_CRAFTED"),
            L("FOOD_DRINK_NON_CRAFTED_TOOLTIP"),
            false,
            "foodDrinkEnabled"
        ),
        { type = "divider" },
        CreateCheckbox(
            profile,
            "potionPoisonEnabled",
            L("POTION_POISON_ENABLE"),
            L("POTION_POISON_ENABLE_TOOLTIP"),
            true
        ),
        CreateCheckbox(
            profile,
            "excludePotionPoisonCP150",
            L("POTION_POISON_EXCLUDE_CP150"),
            L("POTION_POISON_EXCLUDE_CP150_TOOLTIP"),
            false,
            "potionPoisonEnabled"
        ),
        CreateCheckbox(
            profile,
            "nonCraftedPotionPoison",
            L("POTION_POISON_NON_CRAFTED"),
            L("POTION_POISON_NON_CRAFTED_TOOLTIP"),
            false,
            "potionPoisonEnabled"
        ),
        { type = "divider" },
        CreateCheckbox(
            profile,
            "knownRecipesEnabled",
            L("KNOWN_RECIPES_ENABLE"),
            L("KNOWN_RECIPES_ENABLE_TOOLTIP"),
            true
        ),
        CreateQualityDropdown(
            profile,
            L("RECIPE_MAX_QUALITY"),
            L("RECIPE_MAX_QUALITY_TOOLTIP"),
            "recipeMaxQuality",
            "knownRecipesEnabled"
        ),
        { type = "divider" },
        CreateCheckbox(
            profile,
            "knownHousingPatternsEnabled",
            L("KNOWN_HOUSING_PATTERNS_ENABLE"),
            L("KNOWN_HOUSING_PATTERNS_ENABLE_TOOLTIP"),
            true
        ),
        CreateQualityDropdown(
            profile,
            L("HOUSING_PATTERN_MAX_QUALITY"),
            L("HOUSING_PATTERN_MAX_QUALITY_TOOLTIP"),
            "housingPatternMaxQuality",
            "knownHousingPatternsEnabled"
        ),
    }
end

local function CreateItemLink(itemId)
    return string.format(
        "|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
        itemId
    )
end

local function CreateIconName(itemLink, text)
    local icon = GetItemLinkIcon(itemLink)

    if not icon or icon == "" then
        return text
    end

    return string.format(
        "|t24:24:%s|t %s",
        icon,
        text
    )
end

local function CreateTraitMaterialName(definition)
    local icon = GetItemLinkIcon(
        CreateItemLink(definition.itemId)
    )
    local text = string.format(
        "%s (%s)",
        definition.name,
        definition.trait
    )

    if not icon or icon == "" then
        return text
    end

    return string.format(
        "|t24:24:%s|t %s",
        icon,
        text
    )
end

local function CreateTraitMaterialControls(
    profile,
    profileName
)
    local controls = {}
    local definitions =
        merchant.traitMaterialDefinitions[profileName] or {}

    for _, definition in ipairs(definitions) do
        local currentDefinition = definition

        table.insert(controls, {
            type = "checkbox",
            name = CreateTraitMaterialName(currentDefinition),
            tooltip = string.format(
                L("TRAIT_MATERIAL_TOOLTIP"),
                currentDefinition.name,
                currentDefinition.trait
            ),

            getFunc = function()
                return profile.traitMaterials[
                    currentDefinition.itemId
                ]
            end,

            setFunc = function(value)
                profile.traitMaterials[
                    currentDefinition.itemId
                ] = value
            end,

            default = false,

            disabled = function()
                return not profile.traitMaterialsEnabled
            end,
        })
    end

    return controls
end

local RUNE_QUALITY_COLORS = {
    QUALITY_NORMAL = "FFFFFF",
    QUALITY_FINE = "2DC50E",
    QUALITY_SUPERIOR = "3A92FF",
    QUALITY_EPIC = "A02EF7",
    QUALITY_LEGENDARY = "CFAF37",
}

local function CreateRuneName(definition)
    local icon = GetItemLinkIcon(
        CreateItemLink(definition.itemId)
    )
    local text = definition.name
    local color = RUNE_QUALITY_COLORS[
        definition.qualityKey
    ]

    if color then
        text = string.format(
            "|c%s%s|r",
            color,
            text
        )
    end

    if not icon or icon == "" then
        return text
    end

    return string.format(
        "|t24:24:%s|t %s",
        icon,
        text
    )
end

local function GetRuneTooltip(groupName, definition)
    if groupName == "potency" then
        return string.format(
            L("POTENCY_RUNE_TOOLTIP"),
            definition.level,
            L("RUNE_POLARITY_" .. definition.polarity)
        )
    elseif groupName == "essence" then
        return string.format(
            L("ESSENCE_RUNE_TOOLTIP"),
            L(definition.effectKey)
        )
    end

    return string.format(
        L("ASPECT_RUNE_TOOLTIP"),
        L(definition.qualityKey)
    )
end

local function CreateRuneControls(profile, groupName)
    local controls = {}
    local definitions =
        merchant.enchantingRuneDefinitions[groupName] or {}
    local selectionField = groupName .. "Runes"
    local enabledField = groupName .. "RunesEnabled"

    for _, definition in ipairs(definitions) do
        local currentDefinition = definition

        table.insert(controls, {
            type = "checkbox",
            name = CreateRuneName(currentDefinition),
            tooltip = GetRuneTooltip(
                groupName,
                currentDefinition
            ),

            getFunc = function()
                return profile[selectionField][
                    currentDefinition.itemId
                ]
            end,

            setFunc = function(value)
                profile[selectionField][
                    currentDefinition.itemId
                ] = value
            end,

            default = false,

            disabled = function()
                return not profile[enabledField]
            end,
        })
    end

    return controls
end

local function AppendRuneSection(
    controls,
    profile,
    groupName,
    prefix
)
    local enabledField = groupName .. "RunesEnabled"

    table.insert(controls, { type = "divider" })
    table.insert(controls, CreateCheckbox(
        profile,
        enabledField,
        L(prefix .. "_RUNES_ENABLE"),
        L(prefix .. "_RUNES_ENABLE_TOOLTIP"),
        true
    ))
    table.insert(controls, {
        type = "submenu",
        name = L(prefix .. "_RUNES"),
        tooltip = L(prefix .. "_RUNES_TOOLTIP"),
        disabled = function()
            return not profile[enabledField]
        end,
        controls = CreateRuneControls(profile, groupName),
    })
end

local function CreateEquipmentControls(prefix, profileName)
    local profile = merchant.GetProfile(profileName)

    return {
        CreateCheckbox(
            profile,
            "enabled",
            L(prefix .. "_ENABLE"),
            L(prefix .. "_ENABLE_TOOLTIP"),
            true
        ),
        CreateQualityDropdown(
            profile,
            L(prefix .. "_MAX_QUALITY"),
            L(prefix .. "_MAX_QUALITY_TOOLTIP")
        ),
        CreateCheckbox(
            profile,
            "noTrait",
            L(prefix .. "_NO_TRAIT"),
            L(prefix .. "_NO_TRAIT_TOOLTIP")
        ),
        CreateCheckbox(
            profile,
            "ornate",
            L(prefix .. "_ORNATE"),
            L(prefix .. "_ORNATE_TOOLTIP")
        ),
        CreateCheckbox(
            profile,
            "intricate",
            L(prefix .. "_INTRICATE"),
            L(prefix .. "_INTRICATE_TOOLTIP")
        ),
        CreateCheckbox(
            profile,
            "tradable",
            L(prefix .. "_TRADABLE"),
            L(prefix .. "_TRADABLE_TOOLTIP")
        ),
        { type = "divider" },
        CreateCheckbox(
            profile,
            "traitMaterialsEnabled",
            L("TRAIT_MATERIALS_ENABLE"),
            L("TRAIT_MATERIALS_ENABLE_TOOLTIP"),
            true
        ),
        {
            type = "submenu",
            name = L("TRAIT_MATERIALS"),
            tooltip = L("TRAIT_MATERIALS_TOOLTIP"),
            disabled = function()
                return not profile.traitMaterialsEnabled
            end,
            controls = CreateTraitMaterialControls(
                profile,
                profileName
            ),
        },
    }
end

local function CreateEnchantingControls()
    local profile = merchant.GetProfile("enchanting")
    local controls = {
        CreateCheckbox(
            profile,
            "enabled",
            L("ENCHANTING_ENABLE"),
            L("ENCHANTING_ENABLE_TOOLTIP"),
            true
        ),
        CreateQualityDropdown(
            profile,
            L("ENCHANTING_MAX_QUALITY"),
            L("ENCHANTING_MAX_QUALITY_TOOLTIP")
        ),
    }

    AppendRuneSection(
        controls,
        profile,
        "potency",
        "POTENCY"
    )
    AppendRuneSection(
        controls,
        profile,
        "essence",
        "ESSENCE"
    )
    AppendRuneSection(
        controls,
        profile,
        "aspect",
        "ASPECT"
    )

    return controls
end

local function CreateCraftMaterialControls()
    local profile = merchant.GetProfile("materials")
    local function CreateMaterialCheckbox(
        field,
        itemId,
        nameKey,
        tooltipKey
    )
        local itemLink = CreateItemLink(itemId)
        local itemName = zo_strformat(
            SI_TOOLTIP_ITEM_NAME,
            GetItemLinkName(itemLink)
        )
        local checkbox = CreateCheckbox(
            profile,
            field,
            CreateIconName(
                itemLink,
                string.format(L(nameKey), itemName)
            ),
            string.format(
                L(tooltipKey),
                itemName,
                itemName
            ),
            true
        )

        checkbox.width = "half"
        return checkbox
    end

    local blacksmithing = CreateMaterialCheckbox(
        "blacksmithingEnabled",
        64489,
        "CRAFT_BLACKSMITHING",
        "CRAFT_BLACKSMITHING_TOOLTIP"
    )
    local blacksmithingRaw = CreateMaterialCheckbox(
        "blacksmithingRawEnabled",
        71198,
        "CRAFT_BLACKSMITHING_RAW",
        "CRAFT_BLACKSMITHING_RAW_TOOLTIP"
    )
    local clothing = CreateMaterialCheckbox(
        "clothingMaterialsEnabled",
        64504,
        "CRAFT_CLOTHING",
        "CRAFT_CLOTHING_TOOLTIP"
    )
    local clothingRaw = CreateMaterialCheckbox(
        "clothingRawMaterialsEnabled",
        71200,
        "CRAFT_CLOTHING_RAW",
        "CRAFT_CLOTHING_RAW_TOOLTIP"
    )
    local leather = CreateMaterialCheckbox(
        "leatherMaterialsEnabled",
        64506,
        "CRAFT_LEATHER",
        "CRAFT_LEATHER_TOOLTIP"
    )
    local leatherRaw = CreateMaterialCheckbox(
        "leatherRawMaterialsEnabled",
        71239,
        "CRAFT_LEATHER_RAW",
        "CRAFT_LEATHER_RAW_TOOLTIP"
    )
    local jewelry = CreateMaterialCheckbox(
        "jewelryMaterialsEnabled",
        135146,
        "CRAFT_JEWELRY",
        "CRAFT_JEWELRY_TOOLTIP"
    )
    local jewelryRaw = CreateMaterialCheckbox(
        "jewelryRawMaterialsEnabled",
        135145,
        "CRAFT_JEWELRY_RAW",
        "CRAFT_JEWELRY_RAW_TOOLTIP"
    )
    local woodworking = CreateMaterialCheckbox(
        "woodworkingEnabled",
        64502,
        "CRAFT_WOODWORKING",
        "CRAFT_WOODWORKING_TOOLTIP"
    )
    local woodworkingRaw = CreateMaterialCheckbox(
        "woodworkingRawEnabled",
        71199,
        "CRAFT_WOODWORKING_RAW",
        "CRAFT_WOODWORKING_RAW_TOOLTIP"
    )

    return {
        blacksmithing,
        blacksmithingRaw,
        clothing,
        clothingRaw,
        leather,
        leatherRaw,
        woodworking,
        woodworkingRaw,
        jewelry,
        jewelryRaw,
    }
end

local function AreAllItemsSelected(
    profile,
    selectionField,
    definitions
)
    if #definitions == 0 then
        return false
    end

    for _, definition in ipairs(definitions) do
        if profile[selectionField][definition.itemId] ~= true then
            return false
        end
    end

    return true
end

local function GetLocalizedItemName(itemLink)
    return zo_strformat(
        SI_TOOLTIP_ITEM_NAME,
        GetItemLinkName(itemLink)
    )
end

local function CreateFurnishingMaterialControls()
    local profile = merchant.GetProfile("materials")
    local definitions = merchant.furnishingMaterialDefinitions
    local controls = {
        CreateCheckbox(
            profile,
            "furnishingMaterialsEnabled",
            L("FURNISHING_MATERIALS_ENABLE"),
            L("FURNISHING_MATERIALS_ENABLE_TOOLTIP"),
            true
        ),
        { type = "divider" },
    }

    for _, definition in ipairs(definitions) do
        local currentDefinition = definition
        local itemLink = CreateItemLink(currentDefinition.itemId)
        local itemName = GetLocalizedItemName(itemLink)

        table.insert(controls, {
            type = "checkbox",
            name = CreateIconName(itemLink, itemName),
            tooltip = string.format(
                L("FURNISHING_MATERIAL_ITEM_TOOLTIP"),
                itemName
            ),

            getFunc = function()
                return profile.furnishingMaterials[
                    currentDefinition.itemId
                ]
            end,

            setFunc = function(value)
                profile.furnishingMaterials[
                    currentDefinition.itemId
                ] = value
            end,

            default = false,

            disabled = function()
                return not profile.furnishingMaterialsEnabled
            end,
        })
    end

    return controls
end

local function CreateStyleMaterialControls()
    local profile = merchant.GetProfile("materials")
    local definitions =
        merchant.GetStyleMaterialDefinitions()
    local controls = {
        CreateCheckbox(
            profile,
            "styleMaterialsEnabled",
            L("STYLE_MATERIALS_ENABLE"),
            L("STYLE_MATERIALS_ENABLE_TOOLTIP"),
            true
        ),
        {
            type = "checkbox",
            name = L("STYLE_MATERIALS_SELECT_ALL"),
            tooltip = L("STYLE_MATERIALS_SELECT_ALL_TOOLTIP"),

            getFunc = function()
                return AreAllItemsSelected(
                    profile,
                    "styleMaterials",
                    definitions
                )
            end,

            setFunc = function(value)
                for _, definition in ipairs(definitions) do
                    profile.styleMaterials[
                        definition.itemId
                    ] = value
                end
            end,

            default = false,

            disabled = function()
                return not profile.styleMaterialsEnabled
            end,
        },
        { type = "divider" },
    }

    for _, definition in ipairs(definitions) do
        local currentDefinition = definition

        table.insert(controls, {
            type = "checkbox",
            name = CreateIconName(
                currentDefinition.itemLink,
                currentDefinition.name
            ),
            tooltip = string.format(
                L("STYLE_MATERIAL_ITEM_TOOLTIP"),
                currentDefinition.name,
                currentDefinition.styleName
            ),

            getFunc = function()
                return profile.styleMaterials[
                    currentDefinition.itemId
                ]
            end,

            setFunc = function(value)
                profile.styleMaterials[
                    currentDefinition.itemId
                ] = value
            end,

            default = false,

            disabled = function()
                return not profile.styleMaterialsEnabled
            end,
        })
    end

    return controls
end

local RESOURCE_QUALITY_COLORS = {
    [ITEM_QUALITY_ARTIFACT] = "A02EF7",
    [ITEM_QUALITY_LEGENDARY] = "CFAF37",
}

local function CreateResourceIngredientName(
    itemLink,
    itemName,
    quality
)
    local color = RESOURCE_QUALITY_COLORS[quality]

    if color then
        itemName = string.format(
            "|c%s%s|r",
            color,
            itemName
        )
    end

    return CreateIconName(itemLink, itemName)
end

local function CreateResourceIngredientControls(
    profile,
    groupName,
    prefix
)
    local definitions =
        merchant.resourceIngredientDefinitions[groupName] or {}
    local enabledField = groupName .. "Enabled"
    local selectionField = groupName .. "Ingredients"
    local controls = {
        CreateCheckbox(
            profile,
            enabledField,
            L(prefix .. "_ENABLE"),
            L(prefix .. "_ENABLE_TOOLTIP"),
            true
        ),
        {
            type = "checkbox",
            name = L("RESOURCE_SELECT_ALL"),
            tooltip = L("RESOURCE_SELECT_ALL_TOOLTIP"),

            getFunc = function()
                return AreAllItemsSelected(
                    profile,
                    selectionField,
                    definitions
                )
            end,

            setFunc = function(value)
                for _, definition in ipairs(definitions) do
                    profile[selectionField][definition.itemId] = value
                end
            end,

            default = false,

            disabled = function()
                return not profile[enabledField]
            end,
        },
        { type = "divider" },
    }

    for _, definition in ipairs(definitions) do
        local currentDefinition = definition
        local itemLink = CreateItemLink(currentDefinition.itemId)
        local itemName = GetLocalizedItemName(itemLink)

        table.insert(controls, {
            type = "checkbox",
            name = CreateResourceIngredientName(
                itemLink,
                itemName,
                currentDefinition.quality
            ),
            tooltip = string.format(
                L(prefix .. "_ITEM_TOOLTIP"),
                itemName
            ),

            getFunc = function()
                return profile[selectionField][
                    currentDefinition.itemId
                ]
            end,

            setFunc = function(value)
                profile[selectionField][
                    currentDefinition.itemId
                ] = value
            end,

            default = false,

            disabled = function()
                return not profile[enabledField]
            end,
        })
    end

    return controls
end

local function CreateAlchemySolventControls(profile)
    local controls = {
        CreateCheckbox(
            profile,
            "alchemySolventsEnabled",
            L("SOLVENT_PROFICIENCY_ENABLE"),
            L("SOLVENT_PROFICIENCY_ENABLE_TOOLTIP"),
            true
        ),
        { type = "divider" },
    }

    for _, definition in ipairs(
        merchant.alchemySolventDefinitions
    ) do
        local currentDefinition = definition
        local itemLink = CreateItemLink(currentDefinition.itemId)
        local itemName = GetLocalizedItemName(itemLink)
        local checkbox = {
            type = "checkbox",
            name = CreateIconName(itemLink, itemName),
            tooltip = string.format(
                L("SOLVENT_PROFICIENCY_ITEM_TOOLTIP"),
                itemName,
                currentDefinition.level
            ),

            getFunc = function()
                return profile.alchemySolvents[
                    currentDefinition.itemId
                ]
            end,

            setFunc = function(value)
                profile.alchemySolvents[
                    currentDefinition.itemId
                ] = value
            end,

            default = false,
            width = "half",

            disabled = function()
                return not profile.alchemySolventsEnabled
            end,
        }

        table.insert(controls, checkbox)
    end

    return controls
end

local function CreateAlchemyResourceControls(profile)
    return {
        {
            type = "submenu",
            name = L("ALCHEMY_INGREDIENTS"),
            tooltip = L("ALCHEMY_INGREDIENTS_TOOLTIP"),
            controls = CreateResourceIngredientControls(
                profile,
                "alchemy",
                "ALCHEMY"
            ),
        },
        {
            type = "submenu",
            name = L("SOLVENT_PROFICIENCY"),
            tooltip = L("SOLVENT_PROFICIENCY_TOOLTIP"),
            controls = CreateAlchemySolventControls(profile),
        },
    }
end

local function CreateResourcesControls()
    local profile = merchant.GetProfile("resources")

    return {
        {
            type = "submenu",
            name = L("PROVISIONING"),
            tooltip = L("PROVISIONING_TOOLTIP"),
            controls = CreateResourceIngredientControls(
                profile,
                "provisioning",
                "PROVISIONING"
            ),
        },
        {
            type = "submenu",
            name = L("ALCHEMY"),
            tooltip = L("ALCHEMY_TOOLTIP"),
            controls = CreateAlchemyResourceControls(profile),
        },
    }
end

local function CreateMaterialsControls()
    return {
        {
            type = "submenu",
            name = L("CRAFT_MATERIALS"),
            tooltip = L("CRAFT_MATERIALS_TOOLTIP"),
            controls = CreateCraftMaterialControls(),
        },
        {
            type = "submenu",
            name = L("FURNISHING_MATERIALS"),
            tooltip = L("FURNISHING_MATERIALS_TOOLTIP"),
            controls = CreateFurnishingMaterialControls(),
        },
        {
            type = "submenu",
            name = L("STYLE_MATERIALS"),
            tooltip = L("STYLE_MATERIALS_TOOLTIP"),
            controls = CreateStyleMaterialControls(),
        },
    }
end

local function CreateFishingControls(profile)
    return {
        CreateCheckbox(
            profile,
            "fishingBaitEnabled",
            L("FISHING_BAIT_ENABLE"),
            L("FISHING_BAIT_ENABLE_TOOLTIP"),
            true
        ),
        CreateCheckbox(
            profile,
            "trophyFishEnabled",
            L("TROPHY_FISH_ENABLE"),
            L("TROPHY_FISH_ENABLE_TOOLTIP"),
            true
        ),
    }
end

local function CreateOtherControls()
    local profile = merchant.GetProfile("other")
    local itemLink = CreateItemLink(
        EMPTY_SOUL_GEM_ITEM_ID
    )
    local itemName = GetLocalizedItemName(itemLink)
    local iconName = CreateIconName(itemLink, itemName)

    return {
        CreateCheckbox(
            profile,
            "emptySoulGemsEnabled",
            string.format(
                L("EMPTY_SOUL_GEMS_ENABLE"),
                iconName
            ),
            string.format(
                L("EMPTY_SOUL_GEMS_ENABLE_TOOLTIP"),
                itemName
            ),
            true
        ),
        {
            type = "submenu",
            name = L("FISHING"),
            tooltip = L("FISHING_TOOLTIP"),
            controls = CreateFishingControls(profile),
        },
    }
end

function merchant.CreateSettings()
    if not owa.savedVariables.merchantEnabled then
        return
    end

    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local panelId = "OWMerchantSettings"

    local panelData = {
        type = "panel",
        name = owa.GetString("MERCHANT_PANEL"),
        displayName = owa.GetString("MERCHANT_PANEL"),
        author = "@Invs",
        version = owa.version,
        registerForRefresh = true,
    }

    local options = {
        {
            type = "submenu",
            name = L("WEAPON"),
            tooltip = L("WEAPON_TOOLTIP"),
            controls = CreateEquipmentControls(
                "WEAPON",
                "weapon"
            ),
        },
        {
            type = "submenu",
            name = L("CLOTHING"),
            tooltip = L("CLOTHING_TOOLTIP"),
            controls = CreateEquipmentControls(
                "CLOTHING",
                "clothing"
            ),
        },
        {
            type = "submenu",
            name = L("JEWELRY"),
            tooltip = L("JEWELRY_TOOLTIP"),
            controls = CreateEquipmentControls(
                "JEWELRY",
                "jewelry"
            ),
        },
        {
            type = "submenu",
            name = L("ENCHANTING"),
            tooltip = L("ENCHANTING_TOOLTIP"),
            controls = CreateEnchantingControls(),
        },
        {
            type = "submenu",
            name = L("CONSUMABLES"),
            tooltip = L("CONSUMABLES_TOOLTIP"),
            controls = CreateConsumablesControls(),
        },
        {
            type = "submenu",
            name = L("RESOURCES"),
            tooltip = L("RESOURCES_TOOLTIP"),
            controls = CreateResourcesControls(),
        },
        {
            type = "submenu",
            name = L("MATERIALS"),
            tooltip = L("MATERIALS_TOOLTIP"),
            controls = CreateMaterialsControls(),
        },
        {
            type = "submenu",
            name = L("OTHER"),
            tooltip = L("OTHER_TOOLTIP"),
            controls = CreateOtherControls(),
        },
        { type = "divider" },
        {
            type = "checkbox",
            name = L("CHAT_MESSAGES"),
            tooltip = L("CHAT_MESSAGES_TOOLTIP"),

            getFunc = function()
                return owa.savedVariables.merchantChatMessages
            end,

            setFunc = function(value)
                owa.savedVariables.merchantChatMessages = value
            end,

            default = true,
        },
        {
            type = "dropdown",
            name = L("CHAT_MODE"),
            tooltip = L("CHAT_MODE_TOOLTIP"),
            choices = {
                L("CHAT_MODE_SUMMARY"),
                L("CHAT_MODE_DETAILED"),
            },
            choicesValues = {
                "summary",
                "detailed",
            },

            getFunc = function()
                return owa.savedVariables.merchantChatMode
            end,

            setFunc = function(value)
                owa.savedVariables.merchantChatMode = value
            end,

            default = "summary",

            disabled = function()
                return not owa.savedVariables.merchantChatMessages
            end,
        },
    }

    LAM:RegisterAddonPanel(panelId, panelData)
    LAM:RegisterOptionControls(panelId, options)
end
