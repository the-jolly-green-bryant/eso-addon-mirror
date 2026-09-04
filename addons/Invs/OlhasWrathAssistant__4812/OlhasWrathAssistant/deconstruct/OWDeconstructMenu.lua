function OWDeconstruct_GetLanguageStrings()
    if OWA_SavedVariables.language == "ua" then
        return OW_DECONSTRUCT_LANG_UA
    end

    return OW_DECONSTRUCT_LANG_EN
end

function OWDeconstruct_CreateSettings()

    if not OWA_SavedVariables.deconstructEnabled then
        return
    end

    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local D = OWDeconstruct_GetLanguageStrings()
    local panelId = "OWDeconstructSettings"
    local function NormalizeQualityValue(value)

    if type(value) == "number" then
        return value
    end

    local savedText = tostring(value)

    local qualityValues = {
        {
            value = ITEM_QUALITY_NORMAL,
            ua = OW_DECONSTRUCT_LANG_UA.QUALITY_NORMAL,
            en = OW_DECONSTRUCT_LANG_EN.QUALITY_NORMAL,
        },
        {
            value = ITEM_QUALITY_FINE,
            ua = OW_DECONSTRUCT_LANG_UA.QUALITY_FINE,
            en = OW_DECONSTRUCT_LANG_EN.QUALITY_FINE,
        },
        {
            value = ITEM_QUALITY_SUPERIOR,
            ua = OW_DECONSTRUCT_LANG_UA.QUALITY_SUPERIOR,
            en = OW_DECONSTRUCT_LANG_EN.QUALITY_SUPERIOR,
        },
        {
            value = ITEM_QUALITY_EPIC,
            ua = OW_DECONSTRUCT_LANG_UA.QUALITY_EPIC,
            en = OW_DECONSTRUCT_LANG_EN.QUALITY_EPIC,
        },
        {
            value = ITEM_QUALITY_LEGENDARY,
            ua = OW_DECONSTRUCT_LANG_UA.QUALITY_LEGENDARY,
            en = OW_DECONSTRUCT_LANG_EN.QUALITY_LEGENDARY,
        },
    }

    for _, qualityData in ipairs(qualityValues) do
        if string.find(savedText, qualityData.ua, 1, true)
            or string.find(savedText, qualityData.en, 1, true)
        then
            return qualityData.value
        end
    end

    return ITEM_QUALITY_NORMAL
    end

    local function GetProfile(profileName)

        local profiles = OWA_SavedVariables.deconstructProfiles

        if not profiles[profileName] then
            profiles[profileName] = {}
        end

        local profile = profiles[profileName]

        local defaults = {
            enabled = false,
            maxQuality = ITEM_QUALITY_NORMAL,

            noTrait = false,
            crafted = false,
            ornate = false,
            intricate = false,
            reconstructed = false,
            tradable = false,
            fromBank = false,
            nirnhoned = false,

            research = false,
            researchMode = "all",
        }

        for settingName, defaultValue in pairs(defaults) do
            if profile[settingName] == nil then
                profile[settingName] = defaultValue
            end
        end

        return profile
    end

    local function Checkbox(profile, field, name, tooltip, isEnableCheckbox)
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
                return not isEnableCheckbox and not profile.enabled
            end,
        }
    end

    local function QualityDropdown(profile, T)
        profile.maxQuality = NormalizeQualityValue(profile.maxQuality)

        local choices = {
            "|cFFFFFF" .. D.QUALITY_NORMAL .. "|r",
            "|c2DC50E" .. D.QUALITY_FINE .. "|r",
            "|c3A92FF" .. D.QUALITY_SUPERIOR .. "|r",
            "|cA02EF7" .. D.QUALITY_EPIC .. "|r",
            "|cCFAF37" .. D.QUALITY_LEGENDARY .. "|r",
        }

        local qualityByChoice = {
            [choices[1]] = ITEM_QUALITY_NORMAL,
            [choices[2]] = ITEM_QUALITY_MAGIC,
            [choices[3]] = ITEM_QUALITY_ARCANE,
            [choices[4]] = ITEM_QUALITY_ARTIFACT,
            [choices[5]] = ITEM_QUALITY_LEGENDARY,
        }

        local choiceByQuality = {
            [ITEM_QUALITY_NORMAL] = choices[1],
            [ITEM_QUALITY_MAGIC] = choices[2],
            [ITEM_QUALITY_ARCANE] = choices[3],
            [ITEM_QUALITY_ARTIFACT] = choices[4],
            [ITEM_QUALITY_LEGENDARY] = choices[5],
        }

        return {
            type = "dropdown",
            name = T.MAX_QUALITY,
            tooltip = T.MAX_QUALITY_TOOLTIP,

            choices = choices,

            getFunc = function()
                return choiceByQuality[profile.maxQuality]
                    or choices[1]
            end,

            setFunc = function(choice)
                profile.maxQuality = qualityByChoice[choice]
                    or NormalizeQualityValue(choice)
            end,

            default = choices[1],

            disabled = function()
                return not profile.enabled
            end,
        }
    end

    local function ResearchDropdown(profile, T)
        return {
            type = "dropdown",
            name = T.RESEARCH_MODE,
            tooltip = T.RESEARCH_MODE_TOOLTIP,

            choices = {
                T.RESEARCH_ALL,
                T.RESEARCH_KEEP_LOWEST,
            },

            choicesValues = {
                "all",
                "keep_lowest_unresearched",
            },

            getFunc = function()
                return profile.researchMode
            end,

            setFunc = function(value)
                profile.researchMode = value
            end,

            default = "all",

            disabled = function()
                return not profile.enabled or not profile.research
            end,

            warning = T.RESEARCH_KEEP_LOWEST_TOOLTIP,
        }
    end

    local function JewelryResearchDropdown(
        profile,
        T
    )
        return {
            type = "dropdown",
            name = T.RESEARCH_MODE,
            tooltip = T.RESEARCH_MODE_TOOLTIP,

            choices = {
                T.RESEARCH_ALL,
                T.RESEARCH_BASIC,
                T.RESEARCH_KEEP_LOWEST,
            },

            choicesValues = {
                "all",
                "basic_traits",
                "keep_lowest_unresearched",
            },

            getFunc = function()
                return profile.researchMode
            end,

            setFunc = function(value)
                profile.researchMode = value
            end,

            default = "all",

            disabled = function()
                return not profile.enabled
                    or not profile.research
            end,

            warning =
                T.RESEARCH_KEEP_LOWEST_TOOLTIP,
        }
    end

    local function CreateEquipmentControls(profileName, T)
        local profile = GetProfile(profileName)

        return {
            Checkbox(profile, "enabled", T.ENABLE, T.ENABLE_TOOLTIP, true),
            QualityDropdown(profile, T),

            Checkbox(profile, "noTrait", T.NO_TRAIT, T.NO_TRAIT_TOOLTIP),
            Checkbox(profile, "crafted", T.CRAFTED, T.CRAFTED_TOOLTIP),
            Checkbox(profile, "ornate", T.ORNATE, T.ORNATE_TOOLTIP),
            Checkbox(profile, "intricate", T.INTRICATE, T.INTRICATE_TOOLTIP),
            Checkbox(profile, "reconstructed", T.RECONSTRUCTED, T.RECONSTRUCTED_TOOLTIP),
            Checkbox(profile, "tradable", T.TRADABLE, T.TRADABLE_TOOLTIP),
            Checkbox(profile, "fromBank", T.FROM_BANK, T.FROM_BANK_TOOLTIP),
            Checkbox(profile, "nirnhoned", T.NIRNHONED, T.NIRNHONED_TOOLTIP),
            Checkbox(profile, "research", T.RESEARCH, T.RESEARCH_TOOLTIP),

            ResearchDropdown(profile, T),
        }
    end

    local function CreateJewelryControls(T)
        local profile = GetProfile("jewelry")

        return {
            Checkbox(
                profile,
                "enabled",
                T.ENABLE,
                T.ENABLE_TOOLTIP,
                true
            ),

            QualityDropdown(profile, T),

            Checkbox(
                profile,
                "noTrait",
                T.NO_TRAIT,
                T.NO_TRAIT_TOOLTIP
            ),

            Checkbox(
                profile,
                "crafted",
                T.CRAFTED,
                T.CRAFTED_TOOLTIP
            ),

            Checkbox(
                profile,
                "ornate",
                T.ORNATE,
                T.ORNATE_TOOLTIP
            ),

            Checkbox(
                profile,
                "intricate",
                T.INTRICATE,
                T.INTRICATE_TOOLTIP
            ),

            Checkbox(
                profile,
                "reconstructed",
                T.RECONSTRUCTED,
                T.RECONSTRUCTED_TOOLTIP
            ),

            Checkbox(
                profile,
                "tradable",
                T.TRADABLE,
                T.TRADABLE_TOOLTIP
            ),

            Checkbox(
                profile,
                "fromBank",
                T.FROM_BANK,
                T.FROM_BANK_TOOLTIP
            ),

            Checkbox(
                profile,
                "research",
                T.RESEARCH,
                T.RESEARCH_TOOLTIP
            ),

            JewelryResearchDropdown(
                profile,
                T
            ),
        }
    end

    local function CreateEnchantingControls(T)
        local profile = GetProfile("enchanting")

        return {
            Checkbox(profile, "enabled", T.ENABLE, T.ENABLE_TOOLTIP, true),
            QualityDropdown(profile, T),

            Checkbox(profile, "crafted", T.CRAFTED, T.CRAFTED_TOOLTIP),
            Checkbox(profile, "fromBank", T.FROM_BANK, T.FROM_BANK_TOOLTIP),
        }
    end

    local panelData = {
        type = "panel",
        name = "OWDeconstruct",
        displayName = OWA_GetLanguageStrings().DECONSTRUCT,
        author = "|c57ff80@Invs|r",
        version = "|c57ff800.1.1|r",

        registerForRefresh = true,
    }

    local options = {
        {
            type = "submenu",
            name = D.WEAPON,
            tooltip = D.WEAPON_TOOLTIP,
            controls = CreateEquipmentControls(
                "weapon",
                D.WEAPON_SETTINGS
            ),
        },

        {
            type = "submenu",
            name = D.CLOTHING,
            tooltip = D.CLOTHING_TOOLTIP,
            controls = CreateEquipmentControls(
                "clothing",
                D.CLOTHING_SETTINGS
            ),
        },

        {
            type = "submenu",
            name = D.JEWELRY,
            tooltip = D.JEWELRY_TOOLTIP,
            controls = CreateJewelryControls(
                D.JEWELRY_SETTINGS
            ),
        },

        {
            type = "submenu",
            name = D.ENCHANTING,
            tooltip = D.ENCHANTING_TOOLTIP,
            controls = CreateEnchantingControls(
                D.ENCHANTING_SETTINGS
            ),
        },
    }

    local panel =
        LAM:RegisterAddonPanel(
            panelId,
            panelData
        )

    OWA_AddGuildButton(
        panel,
        LAM
    )

    LAM:RegisterOptionControls(
        panelId,
        options
    )
end