local owa = OWAssistant
local deconstruct = owa.Deconstruct

local function L(key)
    return owa.GetString("DECONSTRUCT_" .. key)
end

local function CreateStringGroup(prefix)
    return setmetatable({}, {
        __index = function(_, key)
            return L(prefix .. "_" .. key)
        end,
    })
end

function deconstruct.CreateSettings()

    if not owa.savedVariables.deconstructEnabled then
        return
    end

    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local D = setmetatable({}, {
        __index = function(_, key)
            return L(key)
        end,
    })

    D.WEAPON_SETTINGS = CreateStringGroup("WEAPON_SETTINGS")
    D.CLOTHING_SETTINGS = CreateStringGroup("CLOTHING_SETTINGS")
    D.JEWELRY_SETTINGS = CreateStringGroup("JEWELRY_SETTINGS")
    D.ENCHANTING_SETTINGS = CreateStringGroup("ENCHANTING_SETTINGS")

    local panelId = "OWDeconstructSettings"

    local function NormalizeQualityValue(value)
        if type(value) == "number" then
            return value
        end

        local savedText = tostring(value)

        local qualityValues = {
            { value = ITEM_QUALITY_NORMAL, text = D.QUALITY_NORMAL },
            { value = ITEM_QUALITY_MAGIC, text = D.QUALITY_FINE },
            { value = ITEM_QUALITY_ARCANE, text = D.QUALITY_SUPERIOR },
            { value = ITEM_QUALITY_ARTIFACT, text = D.QUALITY_EPIC },
            { value = ITEM_QUALITY_LEGENDARY, text = D.QUALITY_LEGENDARY },
        }

        for _, qualityData in ipairs(qualityValues) do
            if string.find(savedText, qualityData.text, 1, true) then
                return qualityData.value
            end
        end

        return ITEM_QUALITY_NORMAL
    end

    local function GetProfile(profileName)
        local profiles = owa.savedVariables.deconstructProfiles

        if not profiles[profileName] then
            profiles[profileName] = {}
        end

        local profile = profiles[profileName]

        -- Versions before 0.1.3 used a separate research checkbox.
        -- Preserve its effective state when migrating to one dropdown.
        if profile.research ~= nil then
            if profile.research == false then
                profile.researchMode = "none"
            elseif not profile.researchMode
                or profile.researchMode == "none"
            then
                profile.researchMode = "all"
            end

            profile.research = nil
        end

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

            researchMode = "none",
        }

        for settingName, defaultValue in pairs(defaults) do
            if profile[settingName] == nil then
                profile[settingName] = defaultValue
            end
        end

        local validResearchModes = {
            none = true,
            all = true,
            keep_lowest_unresearched = true,
        }

        if profileName == "jewelry" then
            validResearchModes.basic_traits = true
        end

        if not validResearchModes[profile.researchMode] then
            profile.researchMode = "none"
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

        local choiceValues = {
            ITEM_QUALITY_NORMAL,
            ITEM_QUALITY_MAGIC,
            ITEM_QUALITY_ARCANE,
            ITEM_QUALITY_ARTIFACT,
            ITEM_QUALITY_LEGENDARY,
        }

        return {
            type = "dropdown",
            name = T.MAX_QUALITY,
            tooltip = T.MAX_QUALITY_TOOLTIP,

            choices = choices,
            choicesValues = choiceValues,

            getFunc = function()
                return profile.maxQuality
            end,

            setFunc = function(value)
                profile.maxQuality = NormalizeQualityValue(value)
            end,

            default = ITEM_QUALITY_NORMAL,

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
                T.RESEARCH_NONE,
                T.RESEARCH_ALL,
                T.RESEARCH_KEEP_LOWEST,
            },

            choicesValues = {
                "none",
                "all",
                "keep_lowest_unresearched",
            },

            getFunc = function()
                return profile.researchMode
            end,

            setFunc = function(value)
                profile.researchMode = value
            end,

            default = "none",

            disabled = function()
                return not profile.enabled
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
                T.RESEARCH_NONE,
                T.RESEARCH_ALL,
                T.RESEARCH_BASIC,
                T.RESEARCH_KEEP_LOWEST,
            },

            choicesValues = {
                "none",
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

            default = "none",

            disabled = function()
                return not profile.enabled
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
        name = owa.GetString("DECONSTRUCTOR_PANEL"),
        displayName = owa.GetString("DECONSTRUCTOR_PANEL"),
        author = "@Invs",
        version = owa.version,

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
        {
            type = "checkbox",
            name = D.CHAT_MESSAGES,
            tooltip = D.CHAT_MESSAGES_TOOLTIP,

            getFunc = function()
                return owa.savedVariables.deconstructChatMessages
                    ~= false
            end,

            setFunc = function(value)
                owa.savedVariables.deconstructChatMessages = value
            end,

            default = true,
        },
    }

    LAM:RegisterAddonPanel(panelId, panelData)

    LAM:RegisterOptionControls(
        panelId,
        options
    )
end
