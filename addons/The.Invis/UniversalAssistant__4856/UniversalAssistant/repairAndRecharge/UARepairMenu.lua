local ua = UAssistant
local repair = ua.Repair
local research = repair.Research

local REPAIR_ICON = "/esoui/art/vendor/vendor_tabicon_repair_up.dds"
local RECHARGE_ICON = "/esoui/art/inventory/inventory_tabicon_craftbag_enchanting_up.dds"

local RESEARCH_ICONS = {
    research = "/esoui/art/crafting/smithing_tabicon_research_up.dds",
    blacksmithing = "/esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds",
    clothing = "/esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds",
    woodworking = "/esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds",
    jewelry = "/esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds",
}

local function L(key)
    return ua.GetString("REPAIR_" .. key)
end

local function CreateCategoryName(icon, text)
    if not icon or icon == "" then
        return text
    end

    return string.format("%s %s", zo_iconFormat(icon, 32, 32), text)
end

local function GetCraftingTypeName(craftingType, fallback)
    if ua.GetLanguageCode() == "ua" then
        return fallback
    end

    local name = GetString("SI_TRADESKILLTYPE", craftingType)

    if name and name ~= "" then
        return zo_strformat("<<C:1>>", name)
    end

    return fallback
end

local function CreateResearchOptionName(lineIcon, lineName, traitType)
    local _, _, traitIcon = GetSmithingTraitItemInfo(traitType + 1)
    local traitName = zo_strformat("<<C:1>>", GetString("SI_ITEMTRAITTYPE", traitType))
    local parts = {
        zo_iconFormat(lineIcon, 24, 24),
        zo_strformat("<<C:1>>", lineName),
    }

    if traitIcon and traitIcon ~= "" then
        table.insert(parts, zo_iconFormat(traitIcon, 24, 24))
    end

    table.insert(parts, traitName)

    return table.concat(parts, " ")
end

local function CreateResearchControls(craftingType)
    local definition = research.GetCraftDefinition(craftingType)
    local settings = research.GetCraftSettings(definition)
    local sequence = research.GetResearchSequence(definition)
    local controls = {
        {
            type = "checkbox",
            name = L("RESEARCH_SELECT_ALL"),
            getFunc = function()
                for _, option in ipairs(sequence) do
                    if settings.lines[option.lineIndex][option.traitType] ~= true then
                        return false
                    end
                end

                return true
            end,
            setFunc = function(value)
                for _, option in ipairs(sequence) do
                    settings.lines[option.lineIndex][option.traitType] = value
                end
            end,
            default = false,
        },
        {
            type = "dropdown",
            name = L("RESEARCH_PRIORITY"),
            tooltip = L("RESEARCH_PRIORITY_TOOLTIP"),
            choices = {
                L("RESEARCH_PRIORITY_SEQUENCE"),
                L("RESEARCH_PRIORITY_SHORTEST"),
            },
            choicesValues = {
                "sequence",
                "shortest",
            },
            getFunc = function()
                return settings.priority
            end,
            setFunc = function(value)
                settings.priority = value
            end,
            default = "sequence",
        },
        { type = "divider" },
    }

    local currentPair

    for _, option in ipairs(sequence) do
        if currentPair and currentPair ~= option.pairStart then
            table.insert(controls, { type = "divider" })
        end

        currentPair = option.pairStart

        local currentLineIndex = option.lineIndex
        local currentTraitType = option.traitType

        table.insert(controls, {
            type = "checkbox",
            name = CreateResearchOptionName(option.lineIcon, option.lineName, currentTraitType),
            width = "half",
            getFunc = function()
                return settings.lines[currentLineIndex][currentTraitType] == true
            end,
            setFunc = function(value)
                settings.lines[currentLineIndex][currentTraitType] = value
            end,
            default = false,
        })
    end

    return controls
end

local function CreateThresholdSlider(settings, field, name, tooltip, chatKey, enabledField)
    return {
        type = "slider",
        name = name,
        tooltip = tooltip,
        min = 0,
        max = 20,
        step = 1,
        decimals = 0,
        clampInput = true,

        getFunc = function()
            return settings[field]
        end,

        setFunc = function(value)
            value = zo_clamp(zo_round(value), 0, 20)

            if settings[field] ~= value then
                settings[field] = value
                repair.Chat(chatKey, value)
                repair.ScheduleScan()
            end
        end,

        default = 10,

        disabled = function()
            return not settings[enabledField]
        end,
    }
end

local function CreateResourceThresholdSlider(
    settings,
    field,
    name,
    tooltip,
    enabledField,
    trackingField
)
    return {
        type = "slider",
        name = name,
        tooltip = tooltip,
        min = 1,
        max = 50,
        step = 1,
        decimals = 0,
        clampInput = true,

        getFunc = function()
            return settings[field]
        end,

        setFunc = function(value)
            settings[field] = zo_clamp(zo_round(value), 1, 50)
        end,

        default = 10,

        disabled = function()
            return not settings[enabledField] or not settings[trackingField]
        end,
    }
end

function repair.CreateSettings()
    if not ua.savedVariables.repairEnabled then
        return
    end

    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local settings = repair.GetSettings()
    local panelId = "UARepairAndRechargeSettings"

    local panelData = {
        type = "panel",
        name = ua.GetString("REPAIR_PANEL"),
        displayName = ua.GetString("REPAIR_PANEL"),
        author = "@The.Invis",
        version = ua.version,
        registerForRefresh = true,
        registerForDefaults = true,
        resetFunc = function()
            ua.ResetRepairSettings()
        end,
    }

    local options = {
        {
            type = "submenu",
            name = CreateCategoryName(REPAIR_ICON, L("AUTO_REPAIR")),
            tooltip = L("AUTO_REPAIR_TOOLTIP"),
            controls = {
                {
                    type = "checkbox",
                    name = L("ENABLE_REPAIR"),
                    tooltip = L("ENABLE_REPAIR_TOOLTIP"),

                    getFunc = function()
                        return settings.autoRepair
                    end,

                    setFunc = function(value)
                        settings.autoRepair = value
                        repair.ScheduleScan()
                    end,

                    default = false,
                },
                CreateThresholdSlider(
                    settings,
                    "repairThreshold",
                    L("REPAIR_THRESHOLD"),
                    L("REPAIR_THRESHOLD_TOOLTIP"),
                    "REPAIR_THRESHOLD_SET",
                    "autoRepair"
                ),
                {
                    type = "checkbox",
                    name = L("USE_CROWN_REPAIR_KITS_FIRST"),
                    tooltip = L("USE_CROWN_REPAIR_KITS_FIRST_TOOLTIP"),

                    getFunc = function()
                        return settings.useCrownRepairKitsFirst
                    end,

                    setFunc = function(value)
                        settings.useCrownRepairKitsFirst = value
                        repair.ScheduleScan()
                    end,

                    default = false,

                    disabled = function()
                        return not settings.autoRepair
                    end,
                },
                {
                    type = "checkbox",
                    name = L("REPAIR_IN_COMBAT"),
                    tooltip = L("REPAIR_IN_COMBAT_TOOLTIP"),

                    getFunc = function()
                        return settings.repairInCombat
                    end,

                    setFunc = function(value)
                        settings.repairInCombat = value
                        repair.ScheduleScan()
                    end,

                    default = false,

                    disabled = function()
                        return not settings.autoRepair
                    end,
                },
                {
                    type = "checkbox",
                    name = L("TRACK_REPAIR_KITS"),
                    tooltip = L("TRACK_REPAIR_KITS_TOOLTIP"),

                    getFunc = function()
                        return settings.repairResourceTracking
                    end,

                    setFunc = function(value)
                        settings.repairResourceTracking = value
                    end,

                    default = false,

                    disabled = function()
                        return not settings.autoRepair
                    end,
                },
                CreateResourceThresholdSlider(
                    settings,
                    "repairResourceThreshold",
                    L("REPAIR_KIT_WARNING_THRESHOLD"),
                    L("REPAIR_KIT_WARNING_THRESHOLD_TOOLTIP"),
                    "autoRepair",
                    "repairResourceTracking"
                ),
                {
                    type = "checkbox",
                    name = L("REPAIR_CHAT_MESSAGES"),
                    tooltip = L("REPAIR_CHAT_MESSAGES_TOOLTIP"),

                    getFunc = function()
                        return settings.repairChatMessages
                    end,

                    setFunc = function(value)
                        settings.repairChatMessages = value
                    end,

                    default = false,

                    disabled = function()
                        return not settings.autoRepair
                    end,
                },
            },
        },
        {
            type = "submenu",
            name = CreateCategoryName(RECHARGE_ICON, L("AUTO_RECHARGE")),
            tooltip = L("AUTO_RECHARGE_TOOLTIP"),
            controls = {
                {
                    type = "checkbox",
                    name = L("ENABLE_RECHARGE"),
                    tooltip = L("ENABLE_RECHARGE_TOOLTIP"),

                    getFunc = function()
                        return settings.autoRecharge
                    end,

                    setFunc = function(value)
                        settings.autoRecharge = value
                        repair.ScheduleScan()
                    end,

                    default = false,
                },
                CreateThresholdSlider(
                    settings,
                    "rechargeThreshold",
                    L("RECHARGE_THRESHOLD"),
                    L("RECHARGE_THRESHOLD_TOOLTIP"),
                    "RECHARGE_THRESHOLD_SET",
                    "autoRecharge"
                ),
                {
                    type = "checkbox",
                    name = L("USE_CROWN_SOUL_GEMS_FIRST"),
                    tooltip = L("USE_CROWN_SOUL_GEMS_FIRST_TOOLTIP"),

                    getFunc = function()
                        return settings.useCrownSoulGemsFirst
                    end,

                    setFunc = function(value)
                        settings.useCrownSoulGemsFirst = value
                        repair.ScheduleScan()
                    end,

                    default = false,

                    disabled = function()
                        return not settings.autoRecharge
                    end,
                },
                {
                    type = "checkbox",
                    name = L("RECHARGE_IN_COMBAT"),
                    tooltip = L("RECHARGE_IN_COMBAT_TOOLTIP"),

                    getFunc = function()
                        return settings.rechargeInCombat
                    end,

                    setFunc = function(value)
                        settings.rechargeInCombat = value
                        repair.ScheduleScan()
                    end,

                    default = false,

                    disabled = function()
                        return not settings.autoRecharge
                    end,
                },
                {
                    type = "checkbox",
                    name = L("TRACK_SOUL_GEMS"),
                    tooltip = L("TRACK_SOUL_GEMS_TOOLTIP"),

                    getFunc = function()
                        return settings.rechargeResourceTracking
                    end,

                    setFunc = function(value)
                        settings.rechargeResourceTracking = value
                    end,

                    default = false,

                    disabled = function()
                        return not settings.autoRecharge
                    end,
                },
                CreateResourceThresholdSlider(
                    settings,
                    "rechargeResourceThreshold",
                    L("SOUL_GEM_WARNING_THRESHOLD"),
                    L("SOUL_GEM_WARNING_THRESHOLD_TOOLTIP"),
                    "autoRecharge",
                    "rechargeResourceTracking"
                ),
                {
                    type = "checkbox",
                    name = L("RECHARGE_CHAT_MESSAGES"),
                    tooltip = L("RECHARGE_CHAT_MESSAGES_TOOLTIP"),

                    getFunc = function()
                        return settings.rechargeChatMessages
                    end,

                    setFunc = function(value)
                        settings.rechargeChatMessages = value
                    end,

                    default = false,

                    disabled = function()
                        return not settings.autoRecharge
                    end,
                },
            },
        },
        {
            type = "submenu",
            name = CreateCategoryName(RESEARCH_ICONS.research, L("RESEARCH")),
            tooltip = L("RESEARCH_TOOLTIP"),
            controls = {
                {
                    type = "submenu",
                    name = CreateCategoryName(
                        RESEARCH_ICONS.blacksmithing,
                        GetCraftingTypeName(
                            CRAFTING_TYPE_BLACKSMITHING,
                            L("RESEARCH_BLACKSMITHING")
                        )
                    ),
                    controls = CreateResearchControls(CRAFTING_TYPE_BLACKSMITHING),
                },
                {
                    type = "submenu",
                    name = CreateCategoryName(
                        RESEARCH_ICONS.clothing,
                        GetCraftingTypeName(CRAFTING_TYPE_CLOTHIER, L("RESEARCH_CLOTHING"))
                    ),
                    controls = CreateResearchControls(CRAFTING_TYPE_CLOTHIER),
                },
                {
                    type = "submenu",
                    name = CreateCategoryName(
                        RESEARCH_ICONS.woodworking,
                        GetCraftingTypeName(CRAFTING_TYPE_WOODWORKING, L("RESEARCH_WOODWORKING"))
                    ),
                    controls = CreateResearchControls(CRAFTING_TYPE_WOODWORKING),
                },
                {
                    type = "submenu",
                    name = CreateCategoryName(
                        RESEARCH_ICONS.jewelry,
                        GetCraftingTypeName(CRAFTING_TYPE_JEWELRYCRAFTING, L("RESEARCH_JEWELRY"))
                    ),
                    controls = CreateResearchControls(CRAFTING_TYPE_JEWELRYCRAFTING),
                },
                { type = "divider" },
                {
                    type = "checkbox",
                    name = L("RESEARCH_CHAT_MESSAGES"),
                    tooltip = L("RESEARCH_CHAT_MESSAGES_TOOLTIP"),
                    getFunc = function()
                        return settings.researchChatMessages
                    end,
                    setFunc = function(value)
                        settings.researchChatMessages = value
                    end,
                    default = false,
                },
            },
        },
    }

    LAM:RegisterAddonPanel(panelId, panelData)
    LAM:RegisterOptionControls(panelId, options)
end
