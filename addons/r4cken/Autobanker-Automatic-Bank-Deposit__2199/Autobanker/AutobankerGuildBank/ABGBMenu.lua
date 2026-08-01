-- Create the global namespace for the addon
AutobankerGuildBank = AutobankerGuildBank or {}

-- Create a local shortcut for global
local ABGB = AutobankerGuildBank

-- Dependencies
local LAM = LibAddonMenu2

function ABGB.CreateSettingsMenu()
    local function ClampLowestToZero(value)
        return value < 0 and 0 or value
    end

    -- All per item "default" fallbacks read from the DEFAULT profile.
    local dflt = ABGB.DefaultSettings.guildProfiles["default"]

    local panel = {
        type = "panel",
        name = ABGB.name,
        displayName = ABGB.name,
        author = ABGB.author,
        version = ABGB.version,
        slashCommand = "/abgb",
        registerForRefresh = true,
        registerForDefaults = true
    }
    LAM:RegisterAddonPanel("Auto_banker_Guild_Bank", panel)

    local optionsData = {
        { type = "header", name = "General Settings" },
        {
            -- Guild profile selector
            type = "dropdown",
            name = GetString(ABGB_EDIT_PROFILE),
            tooltip = GetString(ABGB_EDIT_PROFILE_TOOLTIP),
            scrollable = false,
            choices = (function()
                local names = {}
                for i = 1, GetNumGuilds() do
                    local gid = GetGuildId(i)
                    local gname = GetGuildName(gid)
                    if gname and gname ~= "" then
                        table.insert(names, zo_strformat("<<1>>", gname))
                    end
                end
                return names
            end)(),
            choicesValues = (function()
                local vals = {}
                for i = 1, GetNumGuilds() do
                    local gid = GetGuildId(i)
                    local gname = GetGuildName(gid)
                    if gname and gname ~= "" then
                        table.insert(vals, tostring(gid))
                    end
                end
                return vals
            end)(),
            getFunc = function()
                local account = ABGB.GetAccountSettings()
                local id = account.editProfileId
                if not id or id == "default" then
                    id = ABGB.GetFirstGuildId()
                    account.editProfileId = id
                end
                return id
            end,
            setFunc = function(value)
                ABGB.GetAccountSettings().editProfileId = value

                ABGB.GetProfile(value)
            end,
            width = "full",
            default = "default",
        },
        {
            type = "checkbox",
            name = GetString(ABGB_ENABLE_GUILD),

            tooltip = GetString(ABGB_ENABLE_GUILD_TOOLTIP),
            getFunc = function()
                return ABGB.GetSettings().enabled
            end,
            setFunc = function(value)
                ABGB.GetSettings().enabled = value
            end,
            width = "full",
            default = ABGB.DefaultSettings.guildProfiles["default"].enabled,
        },
        { type = "header", name = GetString(ABGB_MODE_HEADER) },
        {
            type = "checkbox",
            name = GetString(ABGB_AUTOMODE),
            tooltip = GetString(ABGB_AUTOMODE_TOOLTIP),
            getFunc = function()
                return ABGB.GetAccountSettings().autoMode
            end,
            setFunc = function(value)
                ABGB.GetAccountSettings().autoMode = value
            end,
            -- Grey out if False
            disabled = function()
                return not ABGB.GetSettings().enabled
            end,
            width = "full",
            default = ABGB.DefaultSettings.autoMode,
        },
        {
            type = "checkbox",
            name = GetString(ABGB_GLOBAL),
            tooltip = GetString(ABGB_GLOBAL_TOOLTIP),
            warning = GetString(ABGB_WARNING),
            getFunc = function()
                return ABGB.GetAccountSettings().useGlobalSettings
            end,
            setFunc = function(state)
                ABGB.GetAccountSettings().useGlobalSettings = state
                ReloadUI()
            end,
            default = ABGB.DefaultSettings.useGlobalSettings
        },
        { type = "header", name = GetString(SI_MAIN_MENU_NOTIFICATIONS) },
        {
            type = "checkbox",
            name = GetString(ABGB_NOTIFICATION_DEPOSIT),
            tooltip = GetString(ABGB_NOTIFICATION_TOOLTIP),
            getFunc = function()
                return ABGB.GetAccountSettings().notifications.deposit
            end,
            setFunc = function(value)
                ABGB.GetAccountSettings().notifications.deposit = value
            end,
            -- Grey out if False
            disabled = function()
                return not ABGB.GetSettings().enabled
            end,
            width = "half",
            default = ABGB.DefaultSettings.notifications.deposit
        },
        {
            type = "checkbox",
            name = GetString(ABGB_NOTIFICATION_AMOUNT),
            tooltip = GetString(ABGB_NOTIFICATION_TOOLTIP),
            getFunc = function()
                return ABGB.GetAccountSettings().notifications.amount
            end,
            setFunc = function(value)
                ABGB.GetAccountSettings().notifications.amount = value
            end,
            -- Grey out if False
            disabled = function()
                return not ABGB.GetSettings().enabled
            end,
            width = "half",
            default = ABGB.DefaultSettings.notifications.amount
        },
        ---------------------------------------------------------
        -- CURRENCY & NOTIFICATIONS
        ---------------------------------------------------------
        --TODO FIX IT BECAUSE IF SET TO 5K IF LEAVES 5K ON PLAYER AND DEPOSITS THE REST!
        {
            type = "submenu",
            name = GetString(ABGB_CURR),
            controls = {
                {
                    type = "checkbox",
                    name = GetString(ABGB_CURR1),
                    warning = GetString(ABGB_CURR1_TOOLTIP),
                    getFunc = function()
                        return ABGB.GetSettings().CURRENCY_DATA[CURT_MONEY].deposit
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().CURRENCY_DATA[CURT_MONEY].deposit = value
                    end,
                    width = "half",
                    default = dflt.CURRENCY_DATA[CURT_MONEY].deposit
                },
                {
                    type = "slider",
                    name = GetString(ABGB_SLIDER_TOOLTIPGOLD),
                    min = 0,
                    max = dflt.CURRENCY_DATA[CURT_MONEY].slider.max,
                    step = dflt.CURRENCY_DATA[CURT_MONEY].slider.step,
                    getFunc = function()
                        return ABGB.GetSettings().CURRENCY_DATA[CURT_MONEY].depositAmount
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().CURRENCY_DATA[CURT_MONEY].depositAmount = ClampLowestToZero(value)
                    end,
                    disabled = function()
                        return not ABGB.GetSettings().CURRENCY_DATA[CURT_MONEY].deposit
                    end,
                    width = "half",
                    default = dflt.CURRENCY_DATA[CURT_MONEY].depositAmount
                }
            }
        },
        ---------------------------------------------------------
        -- CRAFTING MATS
        ---------------------------------------------------------
        {
            type = "submenu",
            name = GetString(ABGB_CRAFT),
            controls = {
                {
                    type = "header",
                    name = GetString(SI_ITEMTYPEDISPLAYCATEGORY14)
                }, -- ALCHEMY
                {
                    type = "checkbox",
                    name = GetString("SI_ITEMTYPE", ITEMTYPE_POTION_BASE),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_POTION_BASE]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_POTION_BASE] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_POTION_BASE]
                },
                {
                    type = "checkbox",
                    name = GetString("SI_ITEMTYPE", ITEMTYPE_POISON_BASE),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_POISON_BASE]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_POISON_BASE] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_POISON_BASE]
                },
                {
                    type = "checkbox",
                    name = GetString("SI_ITEMTYPE", ITEMTYPE_REAGENT),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_REAGENT]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_REAGENT] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_REAGENT]
                },
                {
                    type = "header",
                    name = GetString(SI_ITEMTYPEDISPLAYCATEGORY15)
                }, -- Enchanting
                {
                    type = "checkbox",
                    name = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ASPECT),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_ASPECT]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_ASPECT] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_ASPECT]
                },
                {
                    type = "checkbox",
                    name = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_ESSENCE),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_ESSENCE]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_ESSENCE]
                },
                {
                    type = "checkbox",
                    name = GetString("SI_ITEMTYPE", ITEMTYPE_ENCHANTING_RUNE_POTENCY),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_POTENCY]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_POTENCY] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_ENCHANTING_RUNE_POTENCY]
                },
                { type = "header", name = GetString(ABGB_MATERIALS_NAME) }, -- MATS
                {
                    type = "checkbox",
                    name = GetString(ABGB_MATERIALS_NAME),
                    tooltip = GetString(ABGB_MATERIALS_TOOLTIP),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_BLACKSMITHING_MATERIAL]
                            and ABGB.GetSettings().typesToDeposit[ITEMTYPE_CLOTHIER_MATERIAL]
                            and ABGB.GetSettings().typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_MATERIAL]
                            and ABGB.GetSettings().typesToDeposit[ITEMTYPE_WOODWORKING_MATERIAL]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_BLACKSMITHING_MATERIAL] = value
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_CLOTHIER_MATERIAL] = value
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = value
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_WOODWORKING_MATERIAL] = value
                    end,
                    default = dflt.typesToDeposit[ITEMTYPE_BLACKSMITHING_MATERIAL]
                        and dflt.typesToDeposit[ITEMTYPE_CLOTHIER_MATERIAL]
                        and dflt.typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_MATERIAL]
                        and dflt.typesToDeposit[ITEMTYPE_WOODWORKING_MATERIAL],
                },
                {
                    type = "checkbox",
                    name = GetString(SI_SPECIALIZEDITEMTYPE1600), -- Raw mats
                    tooltip = GetString(ABGB_MATERIALS_TOOLTIP),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL]
                            and ABGB.GetSettings().typesToDeposit[ITEMTYPE_CLOTHIER_RAW_MATERIAL]
                            and ABGB.GetSettings().typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL]
                            and ABGB.GetSettings().typesToDeposit[ITEMTYPE_WOODWORKING_RAW_MATERIAL]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = value
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_CLOTHIER_RAW_MATERIAL] = value
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = value
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_WOODWORKING_RAW_MATERIAL] = value
                    end,
                    default = dflt.typesToDeposit[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL]
                        and dflt.typesToDeposit[ITEMTYPE_CLOTHIER_RAW_MATERIAL]
                        and dflt.typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL]
                        and dflt.typesToDeposit[ITEMTYPE_WOODWORKING_RAW_MATERIAL],
                },
                {
                    type = "checkbox",
                    name = GetString(ABGB_TRAITMATERIALS_NAME),
                    tooltip = GetString(ABGB_TRAITDES),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_ARMOR_TRAIT] and
                            ABGB.GetSettings().typesToDeposit[ITEMTYPE_JEWELRY_TRAIT] and
                            ABGB.GetSettings().typesToDeposit[ITEMTYPE_WEAPON_TRAIT]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_ARMOR_TRAIT] = value
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_JEWELRY_TRAIT] = value
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_WEAPON_TRAIT] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_ARMOR_TRAIT] and
                        dflt.typesToDeposit[ITEMTYPE_JEWELRY_TRAIT] and
                        dflt.typesToDeposit[ITEMTYPE_WEAPON_TRAIT]
                },
                {
                    type = "checkbox",
                    name = GetString(ABGB_UPGRADEMATERIALS_NAME),
                    tooltip = GetString(ABGB_UPMATDES),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_BLACKSMITHING_BOOSTER]
                            and ABGB.GetSettings().typesToDeposit[ITEMTYPE_CLOTHIER_BOOSTER]
                            and ABGB.GetSettings().typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_BOOSTER]
                            and ABGB.GetSettings().typesToDeposit[ITEMTYPE_WOODWORKING_BOOSTER]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_BLACKSMITHING_BOOSTER] = value
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_CLOTHIER_BOOSTER] = value
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = value
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_WOODWORKING_BOOSTER] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_BLACKSMITHING_BOOSTER]
                        and dflt.typesToDeposit[ITEMTYPE_CLOTHIER_BOOSTER]
                        and dflt.typesToDeposit[ITEMTYPE_JEWELRYCRAFTING_BOOSTER]
                        and dflt.typesToDeposit[ITEMTYPE_WOODWORKING_BOOSTER],
                },
                {
                    type = "checkbox",
                    name = GetString(SI_ITEMTYPEDISPLAYCATEGORY17), -- Style Materials
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_STYLE_MATERIAL]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_STYLE_MATERIAL] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_STYLE_MATERIAL]
                },
                {
                    type = "checkbox",
                    name = GetString("SI_ITEMTYPE", ITEMTYPE_FURNISHING_MATERIAL),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_FURNISHING_MATERIAL]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_FURNISHING_MATERIAL] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_FURNISHING_MATERIAL]
                },
                {
                    type = "checkbox",
                    name = GetString(ABGB_INGREDIENT_NAME),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_INGREDIENT]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_INGREDIENT] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_INGREDIENT]
                },
                {
                    type = "checkbox",
                    name = GetString("SI_ITEMTYPE", ITEMTYPE_SCRIBING_INK),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_SCRIBING_INK]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_SCRIBING_INK] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_SCRIBING_INK]
                }
            }
        },
        {
            type = "submenu",
            name = GetString(SI_ARMORY_EQUIPMENT_LABEL),                  -- EQUIPMENT
            controls = {
                { type = "header", name = GetString(SI_ITEMTRAITTYPE9) }, -- INTRICATE
                {
                    type = "checkbox",
                    name = GetString(SI_ITEMTRAITTYPE27),
                    getFunc = function() return ABGB.GetSettings().shouldDepositIntricate end,
                    setFunc = function(value) ABGB.GetSettings().shouldDepositIntricate = value end,
                    width = "half",
                    default = dflt.shouldDepositIntricate,

                },
                {
                    type = "checkbox",
                    name = zo_strformat("<<1>> <<2>>", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE),
                        GetString(SI_ITEM_FORMAT_STR_ARMOR)),
                    getFunc = function() return ABGB.GetSettings().intricateType[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] end,
                    setFunc = function(value) ABGB.GetSettings().intricateType[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = value end,
                    disabled = function() return not ABGB.GetSettings().shouldDepositIntricate end,
                    width = "half",
                    default = dflt.intricateType[ITEM_TRAIT_TYPE_ARMOR_INTRICATE]
                },
                {
                    type = "checkbox",
                    name = zo_strformat("<<1>> <<2>>", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_WEAPON_INTRICATE),
                        GetString("SI_ITEMTYPE", ITEMTYPE_WEAPON)),
                    getFunc = function() return ABGB.GetSettings().intricateType[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] end,
                    setFunc = function(value) ABGB.GetSettings().intricateType[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = value end,
                    disabled = function() return not ABGB.GetSettings().shouldDepositIntricate end,
                    width = "half",
                    default = dflt.intricateType[ITEM_TRAIT_TYPE_WEAPON_INTRICATE]
                },
                {
                    type = "checkbox",
                    name = zo_strformat("<<1>> <<2>>", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_JEWELRY_INTRICATE),
                        GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY)),
                    getFunc = function() return ABGB.GetSettings().intricateType[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] end,
                    setFunc = function(value) ABGB.GetSettings().intricateType[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = value end,
                    disabled = function() return not ABGB.GetSettings().shouldDepositIntricate end,
                    width = "half",
                    default = dflt.intricateType[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE]
                }
                -- type = "header", name = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_TRAIT_ITEMS)}, -- TRAITS
            }
        },
        {
            type = "submenu",
            name = GetString(ABGB_MAPS), -- Maps, Surveys & Writs
            controls = {
                {
                    type = "checkbox",
                    name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP), -- MAPS
                    getFunc = function()
                        return ABGB.GetSettings().shouldDepositTreasureMap
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().shouldDepositTreasureMap = value
                    end,
                    width = "half"
                },
                {
                    type = "checkbox",
                    name = GetString(ABGB_TREASURE_MAP), -- MAPS UNOPEN
                    tooltip = GetString(ABGB_TREASURE_MAP_TOOLTIP),
                    getFunc = function()
                        local ids = { 224681 }
                        for _, id in ipairs(ids) do
                            if not
                                ABGB.GetSettings().itemIdsToDeposit[id] then
                                return false
                            end
                        end
                        return true
                    end,
                    setFunc = function(value)
                        local ids = { 224681 }
                        for _, id in ipairs(ids) do
                            ABGB.GetSettings().itemIdsToDeposit[id] = value
                        end
                    end,
                    width = "half",
                    default = false
                },
                {
                    type = "checkbox",
                    name = GetString(ABGB_SURVEYS),
                    tooltip = GetString(ABGB_SURVEYS_TOOLTIP),
                    getFunc = function()
                        local ids = {
                            219849, 219850, 219851, 219852, 219853, 219854
                        }
                        for _, id in ipairs(ids) do
                            if not
                                ABGB.GetSettings().itemIdsToDeposit[id] then
                                return false
                            end
                        end
                        return true
                    end,
                    setFunc = function(value)
                        local ids = {
                            219849, 219850, 219851, 219852, 219853, 219854
                        }
                        for _, id in ipairs(ids) do
                            ABGB.GetSettings().itemIdsToDeposit[id] = value
                        end
                    end,
                    width = "half",
                    default = false
                },
                { type = "header", name = "Writs" },
                {
                    type = "checkbox",
                    name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_MASTER_WRIT),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_MASTER_WRIT]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_MASTER_WRIT] = value
                    end,
                    width = "half"
                },
                {
                    type = "checkbox",
                    name = GetString(ABGB_WRITS),
                    tooltip = GetString(ABGB_WRITS_TOOLTIP),
                    getFunc = function()
                        local ids = {
                            217917, 217918, 217923, 217919, 217922, 217920,
                            217921
                        }
                        for _, id in ipairs(ids) do
                            if not
                                ABGB.GetSettings().itemIdsToDeposit[id] then
                                return false
                            end
                        end
                        return true
                    end,
                    setFunc = function(value)
                        local ids = {
                            217917, 217918, 217923, 217919, 217922, 217920,
                            217921
                        }
                        for _, id in ipairs(ids) do
                            ABGB.GetSettings().itemIdsToDeposit[id] = value
                        end
                    end,
                    width = "half",
                    default = false
                }
            }
        }, ---------------------------------------------------------
        -- CONSUMABLES & HOME
        ---------------------------------------------------------
        {
            type = "submenu",
            name = GetString(ABGB_CON_RECIPES),
            controls = {
                { type = "header", name = "Consumables" },
                {
                    type = "checkbox",
                    name = GetString(SI_ITEMTYPEDISPLAYCATEGORY19), -- Food
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_FOOD]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_FOOD] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_FOOD]
                },
                {
                    type = "checkbox",
                    name = GetString(SI_ITEMTYPEDISPLAYCATEGORY20), -- Drinks
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_DRINK]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_DRINK] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_DRINK]
                },
                {
                    type = "checkbox",
                    name = GetString(SI_ITEMTYPEDISPLAYCATEGORY22), -- Potions
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_POTION]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_POTION] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_POTION]
                },
                {
                    type = "checkbox",
                    name = GetString(SI_ITEMTYPEDISPLAYCATEGORY23), -- Poisons
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_POISON]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_POISON] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_POISON]
                },
                {
                    type = "checkbox",
                    name = GetString(ABGB_SGF),
                    getFunc = function()
                        return ABGB.GetSettings().depositFilledSoulGems
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().depositFilledSoulGems = value
                    end,
                    width = "half"
                },
                {
                    type = "checkbox",
                    name = GetString(ABGB_SGE),
                    getFunc = function()
                        return ABGB.GetSettings().depositEmptySoulGems
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().depositEmptySoulGems = value
                    end,
                    width = "half"
                },
                { type = "header", name = "Recipes" },
                {
                    type = "checkbox",
                    name = GetString(ABGB_RECIPE_F),
                    getFunc = function()
                        return ABGB.GetSettings().shouldDepositFurnishingRecipe
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().shouldDepositFurnishingRecipe = value
                    end,
                    width = "half",
                    default = dflt.shouldDepositFurnishingRecipe
                },
                {
                    type = "checkbox",
                    name = GetString(ABGB_RECIPE_P),
                    getFunc = function()
                        return ABGB.GetSettings().shouldDepositProvisioningRecipe
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().shouldDepositProvisioningRecipe = value
                    end,
                    width = "half",
                    default = dflt.shouldDepositProvisioningRecipe
                },
                {
                    type = "checkbox",
                    name = GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_CRAFTED_ABILITY_SCRIPT]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_CRAFTED_ABILITY_SCRIPT] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_CRAFTED_ABILITY_SCRIPT]
                },
                {
                    type = "checkbox",
                    name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK),
                    getFunc = function()
                        return ABGB.GetSettings().shouldDepositMotifBook
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().shouldDepositMotifBook = value
                    end,
                    width = "half",
                    default = dflt.shouldDepositMotifBook
                },
                {
                    type = "checkbox",
                    name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER),
                    getFunc = function()
                        return ABGB.GetSettings().shouldDepositMotifChapter
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().shouldDepositMotifChapter = value
                    end,
                    width = "half",
                    default = dflt.shouldDepositMotifChapter
                },
                {
                    type = "checkbox",
                    name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE),
                    tooltip = GetString(ABGB_STYLE_PAGE),
                    getFunc = function()
                        return ABGB.GetSettings().shouldDepositStylePage
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().shouldDepositStylePage = value
                    end,
                    width = "half",
                    default = dflt.shouldDepositStylePage
                },
                {
                    type = "checkbox",
                    name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT),
                    getFunc = function()
                        return ABGB.GetSettings().shouldDepositRecipeFragment
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().shouldDepositRecipeFragment = value
                    end,
                    width = "half",
                    default = dflt.shouldDepositRecipeFragment
                },
                {
                    type = "checkbox",
                    name = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT),
                    getFunc = function()
                        return ABGB.GetSettings().shouldDepositRuneboxFragment
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().shouldDepositRuneboxFragment = value
                    end,
                    width = "half",
                    default = dflt.shouldDepositRuneboxFragment
                }
            }
        },
        {
            type = "submenu",
            name = GetString(SI_ITEMFILTERTYPE5),
            controls = {
                {
                    type = "checkbox",
                    name = GetString("SI_ITEMFILTERTYPE",
                        ITEMFILTERTYPE_FURNISHING),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_FURNISHING]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_FURNISHING] = value
                    end,
                    width = "half"
                },
                -- NEW CODE 6/3
                {
                    type = "checkbox",
                    name = GetString(ABGB_REPAIR_KITS),
                    tooltip = GetString(ABGB_RK_TOOLTIP),
                    getFunc = function()
                        return ABGB.GetSettings().depositRepairKits
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().depositRepairKits = value
                    end,
                    width = "half"
                },
                {
                    type = "checkbox",
                    name = GetString("SI_ITEMTYPE", ITEMTYPE_TREASURE),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_TREASURE]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_TREASURE] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_TREASURE]
                },
                {
                    type = "checkbox",
                    name = GetString(ABGB_TOOLS_NAME),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_SIEGE] and
                            ABGB.GetSettings().typesToDeposit[ITEMTYPE_AVA_REPAIR]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_SIEGE] = value
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_AVA_REPAIR] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_SIEGE] and
                        dflt.typesToDeposit[ITEMTYPE_AVA_REPAIR]
                },
                {
                    type = "checkbox",
                    name = GetString("SI_ITEMTYPE", ITEMTYPE_LOCKPICK),
                    getFunc = function()
                        return ABGB.GetSettings().typesToDeposit[ITEMTYPE_LOCKPICK]
                    end,
                    setFunc = function(value)
                        ABGB.GetSettings().typesToDeposit[ITEMTYPE_LOCKPICK] = value
                    end,
                    width = "half",
                    default = dflt.typesToDeposit[ITEMTYPE_LOCKPICK]
                }
            }
        }
    }

    LAM:RegisterOptionControls("Auto_banker_Guild_Bank", optionsData)
end
