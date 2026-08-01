local Addon = LarvalTearMod
local SettingsPanel = Addon.Modules.SettingsPanel
local SpSaverModes = Addon.Common.SpSaverModes

local SETTINGS_PANEL_ID = "LarvalTearSettings"
local ACTIVE_MODE_STRING_IDS = {
    active_priority = "SI_LTM_SP_SAVER_ACTIVE_PRIORITY",
    skip_skill_changes = "SI_LTM_SP_SAVER_SKIP_SKILL_CHANGES",
}
local PASSIVE_MODE_STRING_IDS = {
    best_effort = "SI_LTM_SP_SAVER_BEST_EFFORT",
    all_or_nothing = "SI_LTM_SP_SAVER_ALL_OR_NOTHING",
    preserve_current = "SI_LTM_SP_SAVER_PRESERVE_CURRENT",
}

local function GetText(stringIdName, fallback)
    -- NOTE:
    -- Missing localization fallback is intentionally not forced here.
    -- nil/empty labels help surface missing string IDs during testing.
    if type(Addon.GetStringText) == "function" then
        return Addon.GetStringText(stringIdName)
    end

    return fallback
end

local function BuildModeChoices(modeOrder, stringIds)
    local choices = {}
    for _, mode in ipairs(modeOrder) do
        choices[#choices + 1] = GetText(stringIds[mode])
    end
    return choices
end

local function CopyModeOrder(modeOrder)
    local values = {}
    for _, mode in ipairs(modeOrder) do
        values[#values + 1] = mode
    end
    return values
end

local function GetLibAddonMenu()
    local lam = rawget(_G, "LibAddonMenu2")
    if type(lam) ~= "table" then
        return nil
    end

    if type(lam.RegisterAddonPanel) ~= "function" or type(lam.RegisterOptionControls) ~= "function" then
        return nil
    end

    return lam
end

local function IsHudLauncherVisible()
    if type(Addon.GetHudLauncherSettings) ~= "function" then
        return true
    end

    local settings = Addon:GetHudLauncherSettings(false)
    return type(settings) ~= "table" or settings.hidden ~= true
end

local function IsHudLauncherLocked()
    if type(Addon.GetHudLauncherSettings) ~= "function" then
        return false
    end

    local settings = Addon:GetHudLauncherSettings(false)
    return type(settings) == "table" and settings.locked == true
end

local function IsDebugModeEnabled()
    return type(Addon.savedVars) == "table" and Addon.savedVars.debugRunCompact == true
end

local function IsPrintMessagesEnabled()
    if type(Addon.IsPrintMessagesEnabled) == "function" then
        return Addon:IsPrintMessagesEnabled()
    end

    return true
end

local function IsIgnoreCostumesEnabled()
    if type(Addon.IsIgnoreCostumesEnabled) == "function" then
        return Addon:IsIgnoreCostumesEnabled()
    end

    return false
end

local function IsAutoRefillQuickSlotEnabled()
    if type(Addon.IsAutoRefillQuickSlotEnabled) == "function" then
        return Addon:IsAutoRefillQuickSlotEnabled()
    end

    return false
end

local function IsAutoRefillFoodHelperEnabled()
    if type(Addon.IsAutoRefillFoodHelperEnabled) == "function" then
        return Addon:IsAutoRefillFoodHelperEnabled()
    end

    return false
end

local function GetEquipmentDepositCleanupScope()
    if type(Addon.GetEquipmentDepositCleanupScope) == "function" then
        return Addon:GetEquipmentDepositCleanupScope()
    end

    return "all_build_cards"
end

local function SetEquipmentDepositCleanupScope(value)
    if type(Addon.SetEquipmentDepositCleanupScope) == "function" then
        Addon:SetEquipmentDepositCleanupScope(value)
    end
end

local function GetEquipmentDepositItemFilter()
    if type(Addon.GetEquipmentDepositItemFilter) == "function" then
        return Addon:GetEquipmentDepositItemFilter()
    end

    return "saved_build_gear_only"
end

local function SetEquipmentDepositItemFilter(value)
    if type(Addon.SetEquipmentDepositItemFilter) == "function" then
        Addon:SetEquipmentDepositItemFilter(value)
    end
end

local function GetEquipmentDepositSafetyMode()
    if type(Addon.GetEquipmentDepositSafetyMode) == "function" then
        return Addon:GetEquipmentDepositSafetyMode()
    end

    return "normal"
end

local function SetEquipmentDepositSafetyMode(value)
    if type(Addon.SetEquipmentDepositSafetyMode) == "function" then
        Addon:SetEquipmentDepositSafetyMode(value)
    end
end

local function GetApplyUiMode()
    if type(Addon.GetApplyUiMode) == "function" then
        return Addon:GetApplyUiMode()
    end

    return "default"
end

local function SetApplyUiMode(value)
    if type(Addon.SetApplyUiMode) == "function" then
        Addon:SetApplyUiMode(value)
    end
end

local function GetSpSaverActiveMode()
    local settings = Addon:GetSpSaverSettings()
    return settings.activeMode
end

local function SetSpSaverActiveMode(value)
    Addon:SetSpSaverActiveMode(value)
end

local function GetSpSaverPassiveMode()
    local settings = Addon:GetSpSaverSettings()
    return settings.passiveMode
end

local function SetSpSaverPassiveMode(value)
    Addon:SetSpSaverPassiveMode(value)
end

function SettingsPanel:Register()
    if self.registered == true then
        return true
    end

    local lam = GetLibAddonMenu()
    if lam == nil then
        return false
    end

    local displayName = Addon.displayName or Addon.name or "LarvalTear"
    local panelData = {
        name = displayName,
        displayName = displayName,
        author = "Thory'JP",
    }
    local optionsTable = {
        {
            type = "header",
            name = GetText("SI_LTM_SETTINGS_HEADER", "LarvalTear Settings"),
        },
        {
            type = "checkbox",
            name = GetText("SI_LTM_SETTINGS_SHOW_ICON", "Show on-screen icon"),
            tooltip = GetText("SI_LTM_SETTINGS_SHOW_ICON_TOOLTIP", "Show the LarvalTear launcher icon on the HUD."),
            getFunc = IsHudLauncherVisible,
            setFunc = function(value)
                if type(Addon.SetHudLauncherHidden) == "function" then
                    Addon:SetHudLauncherHidden(value ~= true)
                end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = GetText("SI_LTM_SETTINGS_LOCK_ICON", "Lock icon movement"),
            tooltip = GetText("SI_LTM_SETTINGS_LOCK_ICON_TOOLTIP", "Prevent dragging the on-screen icon."),
            getFunc = IsHudLauncherLocked,
            setFunc = function(value)
                if type(Addon.SetHudLauncherLocked) == "function" then
                    Addon:SetHudLauncherLocked(value == true)
                end
            end,
            default = false,
        },
        {
            type = "checkbox",
            name = GetText("SI_LTM_SETTINGS_PRINT_MESSAGES", "Print messages"),
            tooltip = GetText("SI_LTM_SETTINGS_PRINT_MESSAGES_TOOLTIP", "Show normal LarvalTear chat messages. Errors and warnings are still shown when this is off."),
            getFunc = IsPrintMessagesEnabled,
            setFunc = function(value)
                if type(Addon.SetPrintMessagesEnabled) == "function" then
                    Addon:SetPrintMessagesEnabled(value == true)
                end
            end,
            default = true,
        },
        {
            type = "header",
            name = GetText("SI_LTM_SETTINGS_IGNORE_HEADER", "IGNORE"),
        },
        {
            type = "checkbox",
            name = GetText("SI_LTM_SETTINGS_IGNORE_COSTUMES", "Ignore Costumes"),
            tooltip = GetText("SI_LTM_SETTINGS_IGNORE_COSTUMES_TOOLTIP", "Skip outfit and costume application during build apply while keeping saved outfit data unchanged."),
            getFunc = IsIgnoreCostumesEnabled,
            setFunc = function(value)
                if type(Addon.SetIgnoreCostumesEnabled) == "function" then
                    Addon:SetIgnoreCostumesEnabled(value == true)
                end
            end,
            default = false,
        },
        {
            type = "header",
            name = GetText("SI_LTM_SETTINGS_AUTO_REFILL_HEADER", "AUTO REFILL"),
        },
        {
            type = "description",
            text = GetText("SI_LTM_SETTINGS_AUTO_REFILL_DESCRIPTION", "When opening a bank or chest, detect currently active Quick Slot and Food items and automatically refill their stacks to full."),
        },
        {
            type = "checkbox",
            name = GetText("SI_LTM_SETTINGS_AUTO_REFILL_QUICK_SLOT", "Quick Slot"),
            tooltip = GetText("SI_LTM_SETTINGS_AUTO_REFILL_QUICK_SLOT_TOOLTIP", "Reserved setting for automatically refilling active Quick Slot items when a bank opens."),
            getFunc = IsAutoRefillQuickSlotEnabled,
            setFunc = function(value)
                if type(Addon.SetAutoRefillQuickSlotEnabled) == "function" then
                    Addon:SetAutoRefillQuickSlotEnabled(value == true)
                end
            end,
            default = false,
        },
        {
            type = "checkbox",
            name = GetText("SI_LTM_SETTINGS_AUTO_REFILL_FOOD_HELPER", "Food Helper"),
            tooltip = GetText("SI_LTM_SETTINGS_AUTO_REFILL_FOOD_HELPER_TOOLTIP", "Reserved setting for automatically refilling the active Food Helper item when a bank opens."),
            getFunc = IsAutoRefillFoodHelperEnabled,
            setFunc = function(value)
                if type(Addon.SetAutoRefillFoodHelperEnabled) == "function" then
                    Addon:SetAutoRefillFoodHelperEnabled(value == true)
                end
            end,
            default = false,
        },
        {
            type = "header",
            name = GetText("SI_LTM_SETTINGS_DEPOSIT_HEADER", "BANK / CHEST DEPOSIT"),
        },
        {
            type = "dropdown",
            name = GetText("SI_LTM_SETTINGS_DEPOSIT_CLEANUP_SCOPE", "Inventory Cleanup Scope"),
            tooltip = GetText("SI_LTM_SETTINGS_DEPOSIT_CLEANUP_SCOPE_TOOLTIP", "Controls which Build Card equipment is protected when depositing unused gear."),
            choices = {
                GetText("SI_LTM_SETTINGS_DEPOSIT_SCOPE_CURRENT_BUILD", "Current Build only"),
                GetText("SI_LTM_SETTINGS_DEPOSIT_SCOPE_ALL_BUILD_CARDS", "All Build Cards"),
            },
            choicesValues = {
                "current_build",
                "all_build_cards",
            },
            choicesTooltips = {
                GetText("SI_LTM_SETTINGS_DEPOSIT_SCOPE_CURRENT_BUILD_TOOLTIP", "Protects only the currently selected Build Card equipment. Frees more inventory space."),
                GetText("SI_LTM_SETTINGS_DEPOSIT_SCOPE_ALL_BUILD_CARDS_TOOLTIP", "Protects equipment used by any saved Build Card. Reduces repeated withdraws."),
            },
            getFunc = GetEquipmentDepositCleanupScope,
            setFunc = SetEquipmentDepositCleanupScope,
            default = "all_build_cards",
        },
        {
            type = "description",
            text = GetText("SI_LTM_SETTINGS_DEPOSIT_CLEANUP_SCOPE_DESCRIPTION", "All Build Cards protects all equipment registered in this addon and deposits other gear. Current Build only protects only the currently selected Build Card equipment and deposits other gear."),
        },
        {
            type = "dropdown",
            name = GetText("SI_LTM_SETTINGS_EQUIPMENT_DEPOSIT_ITEM_FILTER", "Deposit Target Items"),
            tooltip = GetText("SI_LTM_SETTINGS_EQUIPMENT_DEPOSIT_ITEM_FILTER_TOOLTIP", "Controls which backpack equipment can become a deposit candidate."),
            choices = {
                GetText("SI_LTM_SETTINGS_EQUIPMENT_DEPOSIT_ITEM_FILTER_ALL", "All Equipment"),
                GetText("SI_LTM_SETTINGS_EQUIPMENT_DEPOSIT_ITEM_FILTER_SAVED_BUILD_ONLY", "Saved Build Gear Only"),
            },
            choicesValues = {
                "all_equipment",
                "saved_build_gear_only",
            },
            getFunc = GetEquipmentDepositItemFilter,
            setFunc = SetEquipmentDepositItemFilter,
            default = "saved_build_gear_only",
        },
        {
            type = "description",
            text = GetText("SI_LTM_SETTINGS_EQUIPMENT_DEPOSIT_ITEM_FILTER_DESCRIPTION", "All Equipment makes all equipment outside Build Card protection deposit candidates, including unregistered drops. Saved Build Gear Only deposits only equipment saved in LarvalTear Build Cards and ignores unregistered loot, ornate gear, deconstruction items, and miscellaneous equipment."),
        },
        {
            type = "dropdown",
            name = GetText("SI_LTM_SETTINGS_DEPOSIT_SAFETY_MODE", "Deposit Safety Mode"),
            tooltip = GetText("SI_LTM_SETTINGS_DEPOSIT_SAFETY_MODE_TOOLTIP", "Controls additional protection for movable items when depositing unused gear."),
            choices = {
                GetText("SI_LTM_SETTINGS_DEPOSIT_SAFETY_STRICT", "Strict"),
                GetText("SI_LTM_SETTINGS_DEPOSIT_SAFETY_NORMAL", "Normal"),
                GetText("SI_LTM_SETTINGS_DEPOSIT_SAFETY_AGGRESSIVE", "Aggressive"),
            },
            choicesValues = {
                "strict",
                "normal",
                "aggressive",
            },
            choicesTooltips = {
                GetText("SI_LTM_SETTINGS_DEPOSIT_SAFETY_STRICT_TOOLTIP", "Protects locked, mythic, and bound items."),
                GetText("SI_LTM_SETTINGS_DEPOSIT_SAFETY_NORMAL_TOOLTIP", "Protects locked items only."),
                GetText("SI_LTM_SETTINGS_DEPOSIT_SAFETY_AGGRESSIVE_TOOLTIP", "Protects only Build Card equipment and items that cannot be banked."),
            },
            getFunc = GetEquipmentDepositSafetyMode,
            setFunc = SetEquipmentDepositSafetyMode,
            default = "normal",
        },
        {
            type = "description",
            text = GetText("SI_LTM_SETTINGS_DEPOSIT_SAFETY_MODE_DESCRIPTION", "Strict does not deposit locked, mythic, or bound items. Normal does not deposit locked items, but can deposit mythic and bound items. Aggressive deposits all movable equipment except Build Card protected equipment and items that cannot be banked."),
        },
        {
            type = "header",
            name = GetText("SI_LTM_SETTINGS_APPLY_UI_HEADER", "APPLY UI"),
        },
        {
            type = "dropdown",
            name = GetText("SI_LTM_SETTINGS_APPLY_UI_MODE", "Apply UI Mode"),
            tooltip = GetText("SI_LTM_SETTINGS_APPLY_UI_MODE_TOOLTIP", "Controls how LarvalTear is displayed while applying a build."),
            choices = {
                GetText("SI_LTM_SETTINGS_APPLY_UI_MODE_DEFAULT", "Default"),
                GetText("SI_LTM_SETTINGS_APPLY_UI_MODE_SMALL_PROGRESS", "Small Progress Window"),
            },
            choicesValues = {
                "default",
                "small_progress",
            },
            choicesTooltips = {
                GetText("SI_LTM_SETTINGS_APPLY_UI_MODE_DEFAULT_TOOLTIP", "Keep the existing main window behavior while applying."),
                GetText("SI_LTM_SETTINGS_APPLY_UI_MODE_SMALL_PROGRESS_TOOLTIP", "Hide the main window and show a compact progress window while applying."),
            },
            getFunc = GetApplyUiMode,
            setFunc = SetApplyUiMode,
            default = "default",
        },
        {
            type = "header",
            name = GetText("SI_LTM_SETTINGS_SP_SAVER_HEADER"),
        },
        {
            type = "description",
            text = GetText("SI_LTM_SETTINGS_SP_SAVER_DESCRIPTION"),
        },
        {
            type = "dropdown",
            name = GetText("SI_LTM_SP_SAVER_ACTIVE_MODE_LABEL"),
            tooltip = GetText("SI_LTM_SP_SAVER_ACTIVE_NOTE"),
            choices = BuildModeChoices(SpSaverModes.ActiveModes, ACTIVE_MODE_STRING_IDS),
            choicesValues = CopyModeOrder(SpSaverModes.ActiveModes),
            getFunc = GetSpSaverActiveMode,
            setFunc = SetSpSaverActiveMode,
            default = SpSaverModes.ActiveDefault,
        },
        {
            type = "dropdown",
            name = GetText("SI_LTM_SP_SAVER_PASSIVE_MODE_LABEL"),
            choices = BuildModeChoices(SpSaverModes.PassiveModes, PASSIVE_MODE_STRING_IDS),
            choicesValues = CopyModeOrder(SpSaverModes.PassiveModes),
            getFunc = GetSpSaverPassiveMode,
            setFunc = SetSpSaverPassiveMode,
            default = SpSaverModes.PassiveDefault,
        },
        {
            type = "header",
            name = GetText("SI_LTM_SETTINGS_DEVELOPER_HEADER", "Developer"),
        },
        {
            type = "checkbox",
            name = GetText("SI_LTM_SETTINGS_DEBUG_MODE", "Debug mode"),
            tooltip = GetText("SI_LTM_SETTINGS_DEBUG_MODE_TOOLTIP", "Developer use. Same setting as /ltm_debug on|off."),
            getFunc = IsDebugModeEnabled,
            setFunc = function(value)
                if type(Addon.SetCompactDebugRunEnabled) == "function" then
                    Addon:SetCompactDebugRunEnabled(value == true)
                end
            end,
            default = false,
        },
    }

    lam:RegisterAddonPanel(SETTINGS_PANEL_ID, panelData)
    lam:RegisterOptionControls(SETTINGS_PANEL_ID, optionsTable)
    self.registered = true
    return true
end
