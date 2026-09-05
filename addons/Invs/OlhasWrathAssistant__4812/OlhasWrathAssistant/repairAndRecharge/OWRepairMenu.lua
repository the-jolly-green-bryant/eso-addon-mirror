local owa = OWAssistant
local repair = owa.Repair

local function L(key)
    return owa.GetString("REPAIR_" .. key)
end

local function CreateThresholdSlider(
    settings,
    field,
    name,
    tooltip,
    chatKey,
    enabledField
)
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
            settings[field] = zo_clamp(
                zo_round(value),
                1,
                50
            )
        end,

        default = 10,

        disabled = function()
            return not settings[enabledField]
                or not settings[trackingField]
        end,
    }
end

function repair.CreateSettings()
    if not owa.savedVariables.repairEnabled then
        return
    end

    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local settings = repair.GetSettings()
    local panelId = "OWRepairAndRechargeSettings"

    local panelData = {
        type = "panel",
        name = owa.GetString("REPAIR_PANEL"),
        displayName = owa.GetString("REPAIR_PANEL"),
        author = "@Invs",
        version = owa.version,
        registerForRefresh = true,
    }

    local options = {
        {
            type = "submenu",
            name = L("AUTO_REPAIR"),
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

                    default = true,

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

                    default = true,

                    disabled = function()
                        return not settings.autoRepair
                    end,
                },
            },
        },
        {
            type = "submenu",
            name = L("AUTO_RECHARGE"),
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

                    default = true,

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

                    default = true,

                    disabled = function()
                        return not settings.autoRecharge
                    end,
                },
            },
        },
    }

    LAM:RegisterAddonPanel(panelId, panelData)
    LAM:RegisterOptionControls(panelId, options)
end
