local Addon = LarvalTearMod
local LTM = Addon
local Log = Addon.Common.Log
local SHARED_UTIL = Addon.Common.Util
local SP_SAVER_MODES = Addon.Common.SpSaverModes
local LTM_UI = Addon.UI
local LTM_UI_APPLY_PROGRESS = Addon.UI.ApplyProgress
local LTM_APPLY_PRECHECK = Addon.Modules.ApplyPrecheck
local LTM_APPLY_PRECHECK_GATE = Addon.Modules.ApplyPrecheckGate
local LTM_BUILD_CODEC = Addon.Modules.BuildCodec
local LTM_BUILD_STORE = Addon.Modules.BuildStore
local LTM_PIPELINE = Addon.Core.Pipeline
local LTM_FOOD_HELPER = Addon.Modules.FoodHelper
local LTM_ALCHEMY_RECIPE = Addon.Modules.AlchemyRecipe
local LTM_ENCHANT_RECIPE = Addon.Modules.EnchantRecipe
local LTM_SCRIBING_RECIPE = Addon.Modules.ScribingRecipe
local LTM_QUICKSLOT_PROFILES = Addon.Modules.QuickslotProfiles
local LTM_SETTINGS_PANEL = Addon.Modules.SettingsPanel
local LTM_AUTO_REFILL = Addon.Modules.AutoRefill

local SAVED_VARS_DEFAULTS = {
    schemaVersion = LTM.SAVED_VARS_SCHEMA_VERSION,
}
local HUD_LAUNCHER_DEFAULTS = {
    hidden = false,
    locked = false,
    left = nil,
    top = nil,
}
local SETTINGS_DEFAULTS = {
    printMessages = true,
    ignoreCostumes = false,
    autoRefillQuickSlot = false,
    autoRefillFoodHelper = false,
    equipmentDepositCleanupScope = "all_build_cards",
    equipmentDepositItemFilter = "saved_build_gear_only",
    equipmentDepositSafetyMode = "normal",
    applyUiMode = "default",
    spSaver = {
        activeMode = SP_SAVER_MODES.ActiveDefault,
        passiveMode = SP_SAVER_MODES.PassiveDefault,
    },
}
local APPLY_REQUEST_SUPERSEDED = "request_superseded"

LTM.name = "LarvalTear"
LTM.displayName = "LarvalTear"
LTM.savedVariablesName = "LarvalTear"
LTM.pendingApplyRequest = nil
LTM.queuedApplyRequest = nil
LTM.activeApplyRun = nil
LTM.currentBuildCardState = nil
LTM.nextApplyRunId = 0

local function HasAnyEntries(entries)
    return type(entries) == "table" and next(entries) ~= nil
end

local function HasMeaningfulSavedData(savedVars)
    if type(savedVars) ~= "table" then
        return false
    end

    if HasAnyEntries(savedVars.buildsByCharacter) then
        return true
    end

    if HasAnyEntries(savedVars.quickslotProfilesByCharacter) then
        return true
    end

    if HasAnyEntries(savedVars.foodHelperByCharacter) then
        return true
    end

    if HasAnyEntries(savedVars.alchemyRecipeByCharacter) then
        return true
    end

    if HasAnyEntries(savedVars.enchantRecipeByCharacter) then
        return true
    end

    if HasAnyEntries(savedVars.scribingRecipeByCharacter) then
        return true
    end

    if savedVars.debugRunCompact == true then
        return true
    end

    if savedVars.quickslotFetchPreferLowCondition == true then
        return true
    end

    if savedVars.quickslotFetchMode == "refill_max" then
        return true
    end

    return false
end

local function CleanupLegacySavedVariables(savedVars)
    if type(savedVars) ~= "table" then
        return
    end

    savedVars.activityLog = nil
    savedVars.foodHelper = nil
    savedVars.language = nil
    savedVars.serverScopedInitialized = nil
    savedVars.schemaVersion = nil
    savedVars.hudLauncher = nil
    savedVars.quickslotFetchMode = nil
    savedVars.quickslotFetchPreferLowCondition = nil
    savedVars.foodHelperByCharacter = nil
    savedVars.quickslotProfilesByCharacter = nil
    savedVars.debugRunCompact = nil
end

local function CleanupLegacySavedVariablesRoot(savedVariablesName)
    local savedVariablesRoot = rawget(_G, savedVariablesName)
    if type(savedVariablesRoot) ~= "table" then
        return
    end

    for _, accountScope in pairs(savedVariablesRoot) do
        if type(accountScope) == "table" then
            for _, accountSavedVars in pairs(accountScope) do
                if type(accountSavedVars) == "table" then
                    CleanupLegacySavedVariables(accountSavedVars["$AccountWide"])
                end
            end
        end
    end
end

local function NormalizeEquipmentDepositCleanupScope(scope)
    if scope == "current_build" then
        return "current_build"
    end

    return "all_build_cards"
end

local function NormalizeEquipmentDepositSafetyMode(mode)
    if mode == "strict" or mode == "aggressive" then
        return mode
    end

    return "normal"
end

local function NormalizeEquipmentDepositItemFilter(value)
    if value == "all_equipment" then
        return "all_equipment"
    end

    return "saved_build_gear_only"
end

local function NormalizeApplyUiMode(mode)
    if mode == "small_progress" then
        return "small_progress"
    end

    return "default"
end

local function NormalizeSpSaverSettings(settings)
    settings = type(settings) == "table" and settings or {}
    settings.activeMode = SP_SAVER_MODES:NormalizeActiveMode(settings.activeMode)
    settings.passiveMode = SP_SAVER_MODES:NormalizePassiveMode(settings.passiveMode)
    return settings
end

function LTM:EnsureSavedVarsSchemaVersion(savedVars)
    if type(savedVars) ~= "table" then
        return nil
    end

    local latestVersion = tonumber(self.SAVED_VARS_SCHEMA_VERSION)
    if type(latestVersion) ~= "number" then
        return savedVars.schemaVersion
    end

    local currentVersion = tonumber(savedVars.schemaVersion) or 0
    if currentVersion >= latestVersion then
        return savedVars.schemaVersion
    end

    if currentVersion < 9 and latestVersion >= 9 then
        if type(LTM_BUILD_CODEC) ~= "table" or type(LTM_BUILD_CODEC.MigrateToSchema9) ~= "function" then
            return savedVars.schemaVersion
        end

        local ok, migrationErr = LTM_BUILD_CODEC:MigrateToSchema9(savedVars)
        if ok ~= true then
            if type(Log.LogDebugSummary) == "function" then
                Log.LogDebugSummary("SavedVariables schema 9 migration failed", "reason=" .. tostring(migrationErr))
            end
            return savedVars.schemaVersion
        end
        savedVars.schemaVersion = 9
    end

    if currentVersion < 10 and latestVersion >= 10 then
        if type(LTM_BUILD_CODEC) ~= "table" or type(LTM_BUILD_CODEC.MigrateToSchema10) ~= "function" then
            return savedVars.schemaVersion
        end

        local ok, migrationErr = LTM_BUILD_CODEC:MigrateToSchema10(savedVars)
        if ok ~= true then
            if type(Log.LogDebugSummary) == "function" then
                Log.LogDebugSummary("SavedVariables schema 10 migration failed", "reason=" .. tostring(migrationErr))
            end
            return savedVars.schemaVersion
        end
    end

    savedVars.schemaVersion = latestVersion
    return savedVars.schemaVersion
end

function LTM:EnsureHudLauncherSettings(savedVars)
    if type(savedVars) ~= "table" then
        return nil
    end

    local settings = savedVars.hudLauncher
    if type(settings) ~= "table" then
        settings = SHARED_UTIL:DeepCopy(HUD_LAUNCHER_DEFAULTS)
        savedVars.hudLauncher = settings
    end

    settings.hidden = settings.hidden == true
    settings.locked = settings.locked == true
    settings.left = tonumber(settings.left)
    settings.top = tonumber(settings.top)
    return settings
end

function LTM:EnsureSettings(savedVars)
    if type(savedVars) ~= "table" then
        return nil
    end

    local settings = savedVars.settings
    if type(settings) ~= "table" then
        settings = SHARED_UTIL:DeepCopy(SETTINGS_DEFAULTS)
        savedVars.settings = settings
    end

    settings.printMessages = settings.printMessages ~= false
    settings.ignoreCostumes = settings.ignoreCostumes == true
    settings.autoRefillQuickSlot = settings.autoRefillQuickSlot == true
    settings.autoRefillFoodHelper = settings.autoRefillFoodHelper == true
    settings.equipmentDepositCleanupScope = NormalizeEquipmentDepositCleanupScope(settings.equipmentDepositCleanupScope)
    settings.equipmentDepositItemFilter = NormalizeEquipmentDepositItemFilter(settings.equipmentDepositItemFilter)
    settings.equipmentDepositSafetyMode = NormalizeEquipmentDepositSafetyMode(settings.equipmentDepositSafetyMode)
    settings.applyUiMode = NormalizeApplyUiMode(settings.applyUiMode)
    settings.spSaver = NormalizeSpSaverSettings(settings.spSaver)
    return settings
end

function LTM:GetHudLauncherSettings(forWrite)
    if type(self.savedVars) ~= "table" then
        return SHARED_UTIL:DeepCopy(HUD_LAUNCHER_DEFAULTS)
    end

    if forWrite == true then
        return self:EnsureHudLauncherSettings(self.savedVars)
    end

    local settings = self.savedVars.hudLauncher
    if type(settings) ~= "table" then
        return SHARED_UTIL:DeepCopy(HUD_LAUNCHER_DEFAULTS)
    end

    return {
        hidden = settings.hidden == true,
        locked = settings.locked == true,
        left = tonumber(settings.left),
        top = tonumber(settings.top),
    }
end

function LTM:GetSettings(forWrite)
    if type(self.savedVars) ~= "table" then
        return SHARED_UTIL:DeepCopy(SETTINGS_DEFAULTS)
    end

    if forWrite == true then
        return self:EnsureSettings(self.savedVars)
    end

    local settings = self.savedVars.settings
    if type(settings) ~= "table" then
        return SHARED_UTIL:DeepCopy(SETTINGS_DEFAULTS)
    end

    return {
        printMessages = settings.printMessages ~= false,
        ignoreCostumes = settings.ignoreCostumes == true,
        autoRefillQuickSlot = settings.autoRefillQuickSlot == true,
        autoRefillFoodHelper = settings.autoRefillFoodHelper == true,
        equipmentDepositCleanupScope = NormalizeEquipmentDepositCleanupScope(settings.equipmentDepositCleanupScope),
        equipmentDepositItemFilter = NormalizeEquipmentDepositItemFilter(settings.equipmentDepositItemFilter),
        equipmentDepositSafetyMode = NormalizeEquipmentDepositSafetyMode(settings.equipmentDepositSafetyMode),
        applyUiMode = NormalizeApplyUiMode(settings.applyUiMode),
        spSaver = {
            activeMode = SP_SAVER_MODES:NormalizeActiveMode(type(settings.spSaver) == "table" and settings.spSaver.activeMode or nil),
            passiveMode = SP_SAVER_MODES:NormalizePassiveMode(type(settings.spSaver) == "table" and settings.spSaver.passiveMode or nil),
        },
    }
end

function LTM:GetSavedVarsNamespace()
    if type(GetWorldName) ~= "function" then
        return nil
    end

    local worldName = GetWorldName()
    if type(worldName) ~= "string" or worldName == "" then
        return nil
    end

    return worldName
end

function LTM:MigrateLegacySavedVarsIfNeeded(currentSavedVars, legacySavedVars)
    if type(currentSavedVars) ~= "table" then
        return false
    end

    if HasMeaningfulSavedData(currentSavedVars) then
        return false
    end

    if not HasMeaningfulSavedData(legacySavedVars) then
        return false
    end

    currentSavedVars.buildsByCharacter = SHARED_UTIL:DeepCopy(legacySavedVars.buildsByCharacter) or {}
    currentSavedVars.quickslotProfilesByCharacter = SHARED_UTIL:DeepCopy(legacySavedVars.quickslotProfilesByCharacter) or {}
    currentSavedVars.foodHelperByCharacter = SHARED_UTIL:DeepCopy(legacySavedVars.foodHelperByCharacter) or {}
    currentSavedVars.alchemyRecipeByCharacter = SHARED_UTIL:DeepCopy(legacySavedVars.alchemyRecipeByCharacter) or {}
    currentSavedVars.enchantRecipeByCharacter = SHARED_UTIL:DeepCopy(legacySavedVars.enchantRecipeByCharacter) or {}
    currentSavedVars.scribingRecipeByCharacter = SHARED_UTIL:DeepCopy(legacySavedVars.scribingRecipeByCharacter) or {}
    currentSavedVars.lastRunAt = tonumber(legacySavedVars.lastRunAt) or 0
    currentSavedVars.lastErrorCode = legacySavedVars.lastErrorCode
    currentSavedVars.lastErrorAt = tonumber(legacySavedVars.lastErrorAt) or 0
    currentSavedVars.debugRunCompact = legacySavedVars.debugRunCompact == true
    if legacySavedVars.quickslotFetchMode == "refill_max" then
        currentSavedVars.quickslotFetchMode = "refill_max"
    end
    if legacySavedVars.quickslotFetchPreferLowCondition == true then
        currentSavedVars.quickslotFetchPreferLowCondition = true
    end
    return true
end

function LTM:InitializeSavedVars()
    local legacySavedVars = ZO_SavedVars:NewAccountWide(self.savedVariablesName, 1, nil, SAVED_VARS_DEFAULTS)
    local namespace = self:GetSavedVarsNamespace()

    self.savedVars = ZO_SavedVars:NewAccountWide(self.savedVariablesName, 1, namespace, SAVED_VARS_DEFAULTS)
    self:MigrateLegacySavedVarsIfNeeded(self.savedVars, legacySavedVars)
    local schemaVersionBeforeMigration = tonumber(self.savedVars.schemaVersion) or 0
    local latestSchemaVersion = tonumber(self.SAVED_VARS_SCHEMA_VERSION)
    local schemaVersionAfterMigration = self:EnsureSavedVarsSchemaVersion(self.savedVars)
    local migrationFailed = latestSchemaVersion ~= nil
        and schemaVersionBeforeMigration < latestSchemaVersion
        and (tonumber(schemaVersionAfterMigration) or 0) < latestSchemaVersion
    self:EnsureHudLauncherSettings(self.savedVars)
    self:EnsureSettings(self.savedVars)
    if legacySavedVars ~= self.savedVars then
        CleanupLegacySavedVariables(legacySavedVars)
    end
    CleanupLegacySavedVariablesRoot(self.savedVariablesName)
    if migrationFailed then
        return false
    end
end

local function TrimSlashArg(args)
    if type(args) ~= "string" then
        return ""
    end

    return args:gsub("^%s+", ""):gsub("%s+$", "")
end

local function NormalizeSlashArg(args)
    return string.lower(TrimSlashArg(args))
end

local function ReplaceParams(text, params)
    if type(text) ~= "string" then
        return ""
    end

    return (text:gsub("{([%w_]+)}", function(key)
        local value = type(params) == "table" and params[key] or nil
        if value == nil then
            return ""
        end

        return tostring(value)
    end))
end

local function GetStringText(stringIdName, params)
    local stringId = type(stringIdName) == "string" and rawget(_G, stringIdName) or nil
    local text = type(GetString) == "function" and stringId ~= nil and GetString(stringId) or stringIdName
    return ReplaceParams(text, params)
end

LTM.GetStringText = GetStringText

local function IsPipelineSafeAbortReason(reason)
    local safeAbortReasons = type(LTM_PIPELINE) == "table" and LTM_PIPELINE.SAFE_ABORT_REASONS or nil
    return type(reason) == "string" and type(safeAbortReasons) == "table" and safeAbortReasons[reason] == true
end

local function IsPipelineSafeAbortFailure(err, finalResult)
    if type(finalResult) ~= "table" or finalResult.finalStatus ~= "failure" then
        return false
    end

    if IsPipelineSafeAbortReason(err) or IsPipelineSafeAbortReason(finalResult.resultCode) then
        return true
    end

    if type(finalResult.reasons) == "table" then
        for _, reason in ipairs(finalResult.reasons) do
            if IsPipelineSafeAbortReason(reason) then
                return true
            end
        end
    end

    return false
end

local GetApplyRequestDisplayName

local function HideMainWindowIfAvailable()
    if type(LTM_UI) == "table" and type(LTM_UI.HideMainWindow) == "function" then
        Log.Debug("HideMainWindow invoked after safe abort")
        LTM_UI:HideMainWindow()
        return true
    end

    return false
end

local function ShowMainWindowIfAvailable()
    if type(LTM.GetApplyUiMode) == "function" and LTM:GetApplyUiMode() == "small_progress" then
        return false
    end

    if type(LTM_UI) == "table" and type(LTM_UI.ShowMainWindow) == "function" then
        LTM_UI:ShowMainWindow()
        return true
    end

    return false
end

local function HideMainWindowForApplyProgress()
    if type(LTM_UI) == "table" and type(LTM_UI.HideMainWindow) == "function" then
        LTM_UI:HideMainWindow()
        return true
    end

    return false
end

local function IsApplyProgressUsable()
    return type(LTM_UI_APPLY_PROGRESS) == "table"
end

local function IsSmallProgressAvailable()
    return type(LTM.GetApplyUiMode) == "function"
        and LTM:GetApplyUiMode() == "small_progress"
        and IsApplyProgressUsable()
end

local function GetProgressWaitStatusText(waitType)
    if waitType == "combat_queue" then
        return "Waiting for combat to end"
    end

    if waitType == "skill_cooldown" or waitType == "cp_cooldown" then
        return "Waiting for cooldown"
    end

    if waitType == "attribute_retry" then
        return "Retrying..."
    end

    if waitType == "server_busy" then
        return "Waiting for game response"
    end

    return nil
end

local function UpdateApplyProgressStatus(text)
    if not IsApplyProgressUsable()
        or LTM.applyProgressActiveToken == nil
        or type(text) ~= "string"
        or text == "" then
        return false
    end

    if type(LTM_UI_APPLY_PROGRESS.UpdateStatus) == "function" then
        LTM_UI_APPLY_PROGRESS:UpdateStatus(text)
        return true
    end

    return false
end

local function BeginApplyProgressForRequest(request, statusText)
    if not IsSmallProgressAvailable() then
        return nil
    end

    LTM.applyProgressRunToken = (tonumber(LTM.applyProgressRunToken) or 0) + 1
    local token = LTM.applyProgressRunToken
    LTM.applyProgressActiveToken = token
    LTM.applyProgressSpecificWaitActive = false

    HideMainWindowForApplyProgress()
    if type(LTM_UI_APPLY_PROGRESS.Show) == "function" then
        LTM_UI_APPLY_PROGRESS:Show(GetApplyRequestDisplayName(request))
    end
    if type(statusText) == "string" and statusText ~= "" then
        UpdateApplyProgressStatus(statusText)
    end

    return token
end

local function HideApplyProgressIfCurrent(token)
    if LTM.applyProgressActiveToken ~= token or not IsApplyProgressUsable() then
        return false
    end

    if type(LTM_UI_APPLY_PROGRESS.Hide) == "function" then
        LTM_UI_APPLY_PROGRESS:Hide()
    end
    LTM.applyProgressActiveToken = nil
    LTM.applyProgressSpecificWaitActive = false
    return true
end

local function SetApplyProgressResult(token, success, reason, statusText)
    if LTM.applyProgressActiveToken ~= token or not IsApplyProgressUsable() then
        return false
    end

    if type(LTM_UI_APPLY_PROGRESS.SetResult) == "function" then
        LTM_UI_APPLY_PROGRESS:SetResult(success == true, reason)
    end
    if type(statusText) == "string" and statusText ~= "" then
        UpdateApplyProgressStatus(statusText)
    end
    LTM.applyProgressSpecificWaitActive = false
    return true
end

local function NormalizeWaitSeconds(seconds)
    if type(seconds) ~= "number" or seconds <= 0 then
        return nil
    end

    return math.ceil(seconds)
end

function LTM:SetCompactDebugRunEnabled(enabled)
    if type(self.savedVars) ~= "table" then
        return
    end

    self.savedVars.debugRunCompact = enabled and true or false
    Log.WriteChat("Compact debug run enabled=" .. tostring(self.savedVars.debugRunCompact))
end

function LTM:IsPrintMessagesEnabled()
    local settings = self:GetSettings(false)
    return type(settings) ~= "table" or settings.printMessages ~= false
end

function LTM:SetPrintMessagesEnabled(enabled)
    local settings = self:GetSettings(true)
    if type(settings) ~= "table" then
        return false
    end

    settings.printMessages = enabled ~= false
    return true
end

function LTM:IsIgnoreCostumesEnabled()
    local settings = self:GetSettings(false)
    return type(settings) == "table" and settings.ignoreCostumes == true
end

function LTM:SetIgnoreCostumesEnabled(enabled)
    local settings = self:GetSettings(true)
    if type(settings) ~= "table" then
        return false
    end

    settings.ignoreCostumes = enabled == true
    return true
end

function LTM:IsAutoRefillQuickSlotEnabled()
    local settings = self:GetSettings(false)
    return type(settings) == "table" and settings.autoRefillQuickSlot == true
end

function LTM:SetAutoRefillQuickSlotEnabled(enabled)
    local settings = self:GetSettings(true)
    if type(settings) ~= "table" then
        return false
    end

    settings.autoRefillQuickSlot = enabled == true
    return true
end

function LTM:IsAutoRefillFoodHelperEnabled()
    local settings = self:GetSettings(false)
    return type(settings) == "table" and settings.autoRefillFoodHelper == true
end

function LTM:SetAutoRefillFoodHelperEnabled(enabled)
    local settings = self:GetSettings(true)
    if type(settings) ~= "table" then
        return false
    end

    settings.autoRefillFoodHelper = enabled == true
    return true
end

function LTM:GetEquipmentDepositCleanupScope()
    local settings = self:GetSettings(false)
    return NormalizeEquipmentDepositCleanupScope(type(settings) == "table" and settings.equipmentDepositCleanupScope or nil)
end

function LTM:SetEquipmentDepositCleanupScope(scope)
    local settings = self:GetSettings(true)
    if type(settings) ~= "table" then
        return false
    end

    settings.equipmentDepositCleanupScope = NormalizeEquipmentDepositCleanupScope(scope)
    return true
end

function LTM:GetEquipmentDepositItemFilter()
    local settings = self:GetSettings(false)
    return NormalizeEquipmentDepositItemFilter(type(settings) == "table" and settings.equipmentDepositItemFilter or nil)
end

function LTM:SetEquipmentDepositItemFilter(value)
    local settings = self:GetSettings(true)
    if type(settings) ~= "table" then
        return false
    end

    settings.equipmentDepositItemFilter = NormalizeEquipmentDepositItemFilter(value)
    return true
end

function LTM:GetEquipmentDepositSafetyMode()
    local settings = self:GetSettings(false)
    return NormalizeEquipmentDepositSafetyMode(type(settings) == "table" and settings.equipmentDepositSafetyMode or nil)
end

function LTM:SetEquipmentDepositSafetyMode(mode)
    local settings = self:GetSettings(true)
    if type(settings) ~= "table" then
        return false
    end

    settings.equipmentDepositSafetyMode = NormalizeEquipmentDepositSafetyMode(mode)
    return true
end

function LTM:GetApplyUiMode()
    local settings = self:GetSettings(false)
    return NormalizeApplyUiMode(type(settings) == "table" and settings.applyUiMode or nil)
end

function LTM:SetApplyUiMode(mode)
    local settings = self:GetSettings(true)
    if type(settings) ~= "table" then
        return false
    end

    settings.applyUiMode = NormalizeApplyUiMode(mode)
    return true
end

function LTM:GetSpSaverSettings()
    local settings = self:GetSettings(false)
    return type(settings) == "table" and settings.spSaver or nil
end

function LTM:SetSpSaverActiveMode(mode)
    local settings = self:GetSettings(true)
    if type(settings) ~= "table" then
        return nil
    end

    settings.spSaver.activeMode = SP_SAVER_MODES:NormalizeActiveMode(mode)
    return settings.spSaver.activeMode
end

function LTM:SetSpSaverPassiveMode(mode)
    local settings = self:GetSettings(true)
    if type(settings) ~= "table" then
        return nil
    end

    settings.spSaver.passiveMode = SP_SAVER_MODES:NormalizePassiveMode(mode)
    return settings.spSaver.passiveMode
end

function LTM:GetClientLanguage()
    local clientLanguage = type(GetCVar) == "function" and (GetCVar("language.2") or GetCVar("Language.2")) or nil
    clientLanguage = type(clientLanguage) == "string" and string.lower(clientLanguage) or nil
    if clientLanguage == "en" or clientLanguage == "jp" or clientLanguage == "fr" then
        return clientLanguage
    end

    return "en"
end

function LTM:GetPreferredLanguage()
    return self:GetClientLanguage()
end

function LTM:ApplyLocalizationEntries(entries)
    for stringIdName, value in pairs(entries or {}) do
        if type(value) == "string" then
            local stringId = rawget(_G, stringIdName)
            if stringId == nil then
                if type(ZO_CreateStringId) == "function" then
                    ZO_CreateStringId(stringIdName, value)
                end
            elseif type(SafeAddString) == "function" then
                SafeAddString(stringId, value, 2)
            end
        end
    end
end

function LTM:ApplyLanguage()
    local baseEntries = type(Addon.Localization) == "table" and Addon.Localization.en or nil
    self:ApplyLocalizationEntries(baseEntries)

    local targetLanguage = self:GetPreferredLanguage()
    if targetLanguage ~= "en" then
        local localizedEntries = type(Addon.Localization) == "table" and Addon.Localization[targetLanguage] or nil
        self:ApplyLocalizationEntries(localizedEntries)
    end

    self.activeLanguage = targetLanguage
    return targetLanguage
end

function LTM:GetWaitMessageStringId(waitType, seconds)
    if waitType == "server_busy" then
        return seconds ~= nil and "SI_LTM_WAIT_SERVER_BUSY_SECONDS" or "SI_LTM_WAIT_SERVER_BUSY"
    end
    if waitType == "skill_cooldown" then
        return seconds ~= nil and "SI_LTM_WAIT_SKILL_COOLDOWN_SECONDS" or "SI_LTM_WAIT_SKILL_COOLDOWN"
    end
    if waitType == "attribute_retry" then
        return seconds ~= nil and "SI_LTM_WAIT_ATTRIBUTE_RETRY_SECONDS" or "SI_LTM_WAIT_ATTRIBUTE_RETRY"
    end
    if waitType == "cp_cooldown" then
        return seconds ~= nil and "SI_LTM_WAIT_CP_COOLDOWN_SECONDS" or "SI_LTM_WAIT_CP_COOLDOWN"
    end
    if waitType == "combat_queue" then
        return "SI_LTM_WAIT_COMBAT_QUEUE"
    end

    return nil
end

function LTM:GetActivityDisallowedMessageStringId(restrictionType)
    if restrictionType == "class_skills" then
        return "SI_LTM_ACTIVITY_DISALLOWED_CLASS_SKILLS"
    end

    if restrictionType == "attributes" then
        return "SI_LTM_ACTIVITY_DISALLOWED_ATTRIBUTES"
    end

    return nil
end

function LTM:NotifyActivityDisallowed(restrictionType)
    local stringId = self:GetActivityDisallowedMessageStringId(restrictionType)
    if stringId == nil then
        return false
    end

    Log.WriteChat(GetStringText(stringId))
    return true
end

function LTM:NotifyActionError(actionKey, reason)
    if type(LTM_UI) == "table" and type(LTM_UI.LogActionError) == "function" then
        LTM_UI:LogActionError(actionKey, reason)
        return true
    end

    return false
end

function LTM:RequestApplyStartConfirmation(context)
    if type(LTM_UI) == "table" and type(LTM_UI.ShowDialog) == "function" then
        LTM_UI:ShowDialog("APPLY_START_CONFIRM", context)
        return true
    end

    return false
end

function LTM:NotifyQuickSlotsChanged(source)
    local quickSettings = type(LTM_UI) == "table" and LTM_UI.QuickSettings or nil
    if type(quickSettings) == "table" and type(quickSettings.RefreshQuickSlots) == "function" then
        quickSettings:RefreshQuickSlots()
        return true
    end

    return false
end

function LTM:ResetWaitNotification(stateHolder)
    local holder = type(stateHolder) == "table" and stateHolder or self
    holder._ltmWaitType = nil
    holder._ltmWaitSeconds = nil
end

function LTM:NotifyWaitStarted(stateHolder, waitType, seconds)
    local holder = type(stateHolder) == "table" and stateHolder or self
    local normalizedSeconds = NormalizeWaitSeconds(seconds)
    local stringId = self:GetWaitMessageStringId(waitType, normalizedSeconds)
    if stringId == nil then
        return false
    end

    if holder._ltmWaitType == waitType and holder._ltmWaitSeconds == normalizedSeconds then
        return false
    end

    holder._ltmWaitType = waitType
    holder._ltmWaitSeconds = normalizedSeconds
    Log.WriteChat(GetStringText(stringId, {
        seconds = normalizedSeconds,
    }))
    local progressStatusText = GetProgressWaitStatusText(waitType)
    if progressStatusText ~= nil then
        self.applyProgressSpecificWaitActive = true
        UpdateApplyProgressStatus(progressStatusText)
    end
    return true
end

function LTM:RegisterSettingsPanel()
    if type(LTM_SETTINGS_PANEL) == "table" and type(LTM_SETTINGS_PANEL.Register) == "function" then
        return LTM_SETTINGS_PANEL:Register()
    end

    return false
end

local function CloneTableShallow(source)
    local cloned = {}
    for key, value in pairs(source or {}) do
        cloned[key] = value
    end
    return cloned
end

local function CloneResolvedSpSaverPolicy(policy)
    if type(policy) ~= "table" then
        return nil
    end

    return CloneTableShallow(policy)
end

local function CloneAcceptedSkillPointPrecheck(precheck)
    if type(precheck) ~= "table" then
        return nil
    end

    local cloned = CloneTableShallow(precheck)
    cloned.route = type(precheck.route) == "table" and CloneTableShallow(precheck.route) or nil
    cloned.diagnostics = type(precheck.diagnostics) == "table"
        and CloneTableShallow(precheck.diagnostics)
        or nil
    cloned.continuation = type(precheck.continuation) == "table"
        and CloneTableShallow(precheck.continuation)
        or nil
    cloned.spSaver = CloneResolvedSpSaverPolicy(precheck.spSaver)
    return cloned
end

local function CloneApplyRequest(request)
    if type(request) ~= "table" then
        return {}
    end

    local cloned = CloneTableShallow(request)
    cloned.acceptedSkillPointPrecheck = CloneAcceptedSkillPointPrecheck(request.acceptedSkillPointPrecheck)
    return cloned
end

local function ResolveApplyRequestForceChampionRespec(request)
    if type(request) ~= "table" then
        return false
    end

    if request.forceChampionRespec ~= nil then
        return request.forceChampionRespec == true
    end

    local buildId = type(request.buildId) == "string" and request.buildId ~= "" and request.buildId or nil
    if buildId == nil and type(request.build) == "table" then
        buildId = type(request.build.id) == "string" and request.build.id ~= "" and request.build.id or nil
    end

    if type(buildId) ~= "string" or buildId == "" then
        return false
    end

    return type(LTM_BUILD_STORE) == "table"
        and type(LTM_BUILD_STORE.GetBuildForceChampionRespec) == "function"
        and LTM_BUILD_STORE:GetBuildForceChampionRespec(buildId) == true
end

local function GetApplyRequestIdentifier(request)
    if type(request) ~= "table" then
        return nil
    end

    if type(request.buildId) == "string" and request.buildId ~= "" then
        return request.buildId
    end

    local build = request.build
    if type(build) ~= "table" then
        return nil
    end

    if type(build.id) == "string" and build.id ~= "" then
        return build.id
    end

    if type(build.name) == "string" and build.name ~= "" then
        return build.name
    end

    return nil
end

function GetApplyRequestDisplayName(request)
    if type(request) ~= "table" then
        return "LarvalTear"
    end

    local build = request.build
    if type(build) == "table" then
        if type(build.name) == "string" and build.name ~= "" then
            return build.name
        end
        if type(build.id) == "string" and build.id ~= "" then
            return build.id
        end
    end

    local identifier = GetApplyRequestIdentifier(request)
    if type(identifier) == "string" and identifier ~= "" then
        return identifier
    end

    return "LarvalTear"
end

local function GetProgressFailureReason(err, finalResult)
    if type(finalResult) == "table" then
        if type(finalResult.resultCode) == "string" and finalResult.resultCode ~= "" then
            return finalResult.resultCode
        end
        if type(finalResult.reason) == "string" and finalResult.reason ~= "" then
            return finalResult.reason
        end
    end

    if type(err) == "string" and err ~= "" then
        return err
    end

    return "unknown"
end

local function FormatApplyProgressSafeAbortStatus(reason)
    local displayReason = type(reason) == "string" and reason ~= "" and reason or "unknown"
    if displayReason ~= "unknown"
        and type(Log) == "table"
        and type(Log.LocalizeErrorReason) == "function" then
        displayReason = Log.LocalizeErrorReason(reason)
    end

    return "Stopped safely: " .. tostring(displayReason)
end

local function FormatApplySafeAbortChatReason(reason)
    local displayReason = type(reason) == "string" and reason ~= "" and reason or "unknown"
    if displayReason ~= "unknown"
        and type(Log) == "table"
        and type(Log.LocalizeErrorReason) == "function" then
        displayReason = Log.LocalizeErrorReason(reason)
    end

    return tostring(displayReason)
end

function LTM:LogApplyRequestSummary(...)
    if type(Log.LogDebugSummary) == "function" then
        Log.LogDebugSummary(...)
    end
end

local function BuildApplyRequestEnvelope(requestData, completion)
    local requestedAt = type(GetTimeStamp) == "function" and GetTimeStamp() or 0
    local clonedRequest = CloneApplyRequest(requestData)

    return {
        request = clonedRequest,
        completion = completion,
        completionNotified = false,
        buildId = GetApplyRequestIdentifier(clonedRequest),
        pageId = clonedRequest.pageId,
        source = clonedRequest.source,
        requestedAt = requestedAt,
    }
end

local function CompleteApplyRequestEnvelope(envelope, success, err, finalResult)
    if type(envelope) ~= "table" or envelope.completionNotified == true then
        return false
    end

    envelope.completionNotified = true
    local completion = envelope.completion
    envelope.completion = nil
    if type(completion) ~= "function" then
        return true
    end

    local ok, callbackErr = pcall(completion, success == true, err, finalResult)
    if ok ~= true then
        Log.Debug("Apply request completion failed:", callbackErr)
    end
    return true
end

local function BuildSupersededApplyRequestResult(envelope)
    return {
        finalStatus = "failure",
        resultCode = APPLY_REQUEST_SUPERSEDED,
        reasons = {
            APPLY_REQUEST_SUPERSEDED,
        },
        residualSummary = nil,
        sourcePhase = nil,
        superseded = true,
        buildId = type(envelope) == "table" and envelope.buildId or nil,
        pageId = type(envelope) == "table" and envelope.pageId or nil,
        source = type(envelope) == "table" and envelope.source or nil,
        requestedAt = type(envelope) == "table" and envelope.requestedAt or nil,
    }
end

local function CompleteSupersededApplyRequestEnvelope(envelope)
    return CompleteApplyRequestEnvelope(
        envelope,
        false,
        APPLY_REQUEST_SUPERSEDED,
        BuildSupersededApplyRequestResult(envelope)
    )
end

local function StartApplyRequestEnvelope(owner, envelope)
    if type(owner) ~= "table" or type(envelope) ~= "table" or type(envelope.request) ~= "table" then
        return false, "apply_request_envelope_invalid"
    end

    local ok, err = owner:ApplyRequest(envelope.request, function(success, completionErr, finalResult)
        CompleteApplyRequestEnvelope(envelope, success, completionErr, finalResult)
    end)
    if ok ~= true then
        CompleteApplyRequestEnvelope(envelope, false, err, nil)
    end
    return ok, err
end

function LTM:ResolveBuildCardLocation(buildId, pageId)
    if type(buildId) ~= "string" or buildId == "" then
        return nil, nil
    end

    if type(LTM_BUILD_STORE) ~= "table" then
        return nil, nil
    end

    if type(pageId) == "string"
        and pageId ~= ""
        and type(LTM_BUILD_STORE.GetBuildOrdinalForPage) == "function"
        and LTM_BUILD_STORE:GetBuildOrdinalForPage(pageId, buildId) ~= nil then
        return buildId, pageId
    end

    if type(LTM_BUILD_STORE.GetPageList) == "function" then
        for _, pageEntry in ipairs(LTM_BUILD_STORE:GetPageList()) do
            local resolvedPageId = type(pageEntry) == "table" and pageEntry.pageId or nil
            local page = type(pageEntry) == "table" and pageEntry.page or nil
            for _, orderedBuildId in ipairs(type(page) == "table" and page.buildOrder or {}) do
                if orderedBuildId == buildId and type(resolvedPageId) == "string" and resolvedPageId ~= "" then
                    return buildId, resolvedPageId
                end
            end
        end
    end

    return nil, nil
end

function LTM:SetCurrentBuildCardState(buildId, pageId)
    local resolvedBuildId, resolvedPageId = self:ResolveBuildCardLocation(buildId, pageId)
    if type(resolvedBuildId) ~= "string" or type(resolvedPageId) ~= "string" then
        return false
    end

    self.currentBuildCardState = {
        buildId = resolvedBuildId,
        pageId = resolvedPageId,
    }
    return true
end

function LTM:GetSelectedBuildCardState()
    if type(LTM_BUILD_STORE) ~= "table"
        or type(LTM_BUILD_STORE.GetSelectedPageId) ~= "function"
        or type(LTM_BUILD_STORE.GetSelectedBuildIdForPage) ~= "function" then
        return nil
    end

    local pageId = LTM_BUILD_STORE:GetSelectedPageId()
    local buildId = type(pageId) == "string" and LTM_BUILD_STORE:GetSelectedBuildIdForPage(pageId) or nil
    local resolvedBuildId, resolvedPageId = self:ResolveBuildCardLocation(buildId, pageId)
    if type(resolvedBuildId) ~= "string" or type(resolvedPageId) ~= "string" then
        return nil
    end

    return {
        buildId = resolvedBuildId,
        pageId = resolvedPageId,
    }
end

function LTM:GetCurrentBuildCardState()
    local state = type(self.currentBuildCardState) == "table" and self.currentBuildCardState or nil
    local buildId = type(state) == "table" and state.buildId or nil
    local pageId = type(state) == "table" and state.pageId or nil
    local resolvedBuildId, resolvedPageId = self:ResolveBuildCardLocation(buildId, pageId)

    if type(resolvedBuildId) == "string" and type(resolvedPageId) == "string" then
        self.currentBuildCardState = {
            buildId = resolvedBuildId,
            pageId = resolvedPageId,
        }
        return self.currentBuildCardState
    end

    return self:GetSelectedBuildCardState()
end

function LTM:ResolveBuildCardShortcutTarget(shortcutType, ordinal)
    if type(LTM_BUILD_STORE) ~= "table" then
        return nil, nil, "build_store_unavailable"
    end

    if shortcutType == "ordinal" then
        if type(LTM_BUILD_STORE.GetSelectedPageId) ~= "function"
            or type(LTM_BUILD_STORE.GetBuildIdByOrdinalForPage) ~= "function" then
            return nil, nil, "build_card_lookup_unavailable"
        end

        local pageId = LTM_BUILD_STORE:GetSelectedPageId()
        local buildId = LTM_BUILD_STORE:GetBuildIdByOrdinalForPage(pageId, ordinal)
        if type(buildId) ~= "string" or buildId == "" then
            return nil, pageId, "build_card_not_found"
        end

        return buildId, pageId
    end

    local currentState = self:GetCurrentBuildCardState()
    if type(currentState) ~= "table" then
        return nil, nil, "current_build_card_missing"
    end

    if shortcutType == "current" then
        return currentState.buildId, currentState.pageId
    end

    if shortcutType ~= "previous" and shortcutType ~= "next" then
        return nil, currentState.pageId, "build_card_shortcut_invalid"
    end

    if type(LTM_BUILD_STORE.GetBuildOrdinalForPage) ~= "function"
        or type(LTM_BUILD_STORE.GetBuildIdByOrdinalForPage) ~= "function" then
        return nil, currentState.pageId, "build_card_lookup_unavailable"
    end

    local currentOrdinal = LTM_BUILD_STORE:GetBuildOrdinalForPage(currentState.pageId, currentState.buildId)
    if type(currentOrdinal) ~= "number" then
        return nil, currentState.pageId, "current_build_card_missing"
    end

    local targetOrdinal = shortcutType == "previous" and currentOrdinal - 1 or currentOrdinal + 1
    local buildId = LTM_BUILD_STORE:GetBuildIdByOrdinalForPage(currentState.pageId, targetOrdinal)
    if type(buildId) ~= "string" or buildId == "" then
        return nil, currentState.pageId, shortcutType == "previous" and "build_card_at_first" or "build_card_at_last"
    end

    return buildId, currentState.pageId
end

function LTM:SyncSelectedBuildCardState(buildId, pageId)
    if type(buildId) ~= "string" or buildId == "" then
        return false
    end

    if type(pageId) == "string"
        and pageId ~= ""
        and type(LTM_BUILD_STORE) == "table"
        and type(LTM_BUILD_STORE.SetSelectedPageId) == "function" then
        LTM_BUILD_STORE:SetSelectedPageId(pageId)
    end

    if type(pageId) == "string"
        and pageId ~= ""
        and type(LTM_BUILD_STORE) == "table"
        and type(LTM_BUILD_STORE.SetSelectedBuildIdForPage) == "function" then
        LTM_BUILD_STORE:SetSelectedBuildIdForPage(pageId, buildId)
    end

    if type(LTM_UI) == "table" and type(LTM_UI.SyncSelectedBuildCardState) == "function" then
        return LTM_UI:SyncSelectedBuildCardState(buildId, pageId)
    end

    return true
end

function LTM:IsApplyRunning()
    return type(self.activeApplyRun) == "table"
end

function LTM:BeginApplyRun(requestData)
    self.nextApplyRunId = (tonumber(self.nextApplyRunId) or 0) + 1
    local runId = self.nextApplyRunId
    local requestedAt = type(GetTimeStamp) == "function" and GetTimeStamp() or 0
    local clonedRequest = CloneApplyRequest(requestData)

    self.activeApplyRun = {
        runId = runId,
        request = clonedRequest,
        requestedAt = requestedAt,
        buildId = GetApplyRequestIdentifier(clonedRequest),
        pageId = clonedRequest.pageId,
        source = clonedRequest.source,
    }

    return runId, self.activeApplyRun
end

function LTM:QueueLatestApplyRequest(requestData, completion)
    local previousEnvelope = self.queuedApplyRequest
    local queuedEnvelope = BuildApplyRequestEnvelope(requestData, completion)
    self.queuedApplyRequest = queuedEnvelope

    self:LogApplyRequestSummary(
        "Apply request queued",
        "buildId=" .. tostring(queuedEnvelope.buildId),
        "pageId=" .. tostring(queuedEnvelope.pageId),
        "source=" .. tostring(queuedEnvelope.source),
        "requestedAt=" .. tostring(queuedEnvelope.requestedAt),
        "replacedPrevious=" .. tostring(type(previousEnvelope) == "table")
    )

    if type(Log.WriteChat) == "function" then
        Log.WriteChat(GetStringText("SI_LTM_STATUS_APPLY_QUEUED_LATEST"))
    end

    if type(previousEnvelope) == "table" then
        self:LogApplyRequestSummary(
            "Queued request superseded",
            "buildId=" .. tostring(previousEnvelope.buildId),
            "pageId=" .. tostring(previousEnvelope.pageId),
            "source=" .. tostring(previousEnvelope.source),
            "requestedAt=" .. tostring(previousEnvelope.requestedAt)
        )
        CompleteSupersededApplyRequestEnvelope(previousEnvelope)
    end

    return true, "queued"
end

function LTM:StartQueuedApplyRequest()
    local queuedRequest = self.queuedApplyRequest
    if type(queuedRequest) ~= "table" then
        return false
    end

    self.queuedApplyRequest = nil
    ShowMainWindowIfAvailable()
    self:LogApplyRequestSummary(
        "Queued request started",
        "buildId=" .. tostring(queuedRequest.buildId),
        "pageId=" .. tostring(queuedRequest.pageId),
        "source=" .. tostring(queuedRequest.source),
        "requestedAt=" .. tostring(queuedRequest.requestedAt)
    )

    return StartApplyRequestEnvelope(self, queuedRequest)
end

local APPLY_PARTIAL_REASON_STRING_IDS = {
    insufficient_skill_points = "SI_LTM_STATUS_APPLY_PARTIAL_REASON_INSUFFICIENT_POINTS",
    passive_skills_unavailable = "SI_LTM_STATUS_APPLY_PARTIAL_REASON_PASSIVE_SKILLS_UNAVAILABLE",
    passive_ranks_not_restored = "SI_LTM_STATUS_APPLY_PARTIAL_REASON_PASSIVE_RANKS_NOT_RESTORED",
    sp_saver_skip_skill_changes = "SI_LTM_STATUS_APPLY_PARTIAL_REASON_SP_SAVER_SKILL_CHANGES_SKIPPED",
    sp_saver_passive_all_or_nothing_skipped =
        "SI_LTM_STATUS_APPLY_PARTIAL_REASON_SP_SAVER_ALL_OR_NOTHING_SKIPPED",
    sp_saver_passive_preserve_current_skipped =
        "SI_LTM_STATUS_APPLY_PARTIAL_REASON_SP_SAVER_PRESERVE_CURRENT",
    equipment_item_not_found = "SI_LTM_STATUS_APPLY_PARTIAL_REASON_EQUIPMENT_ITEMS_NOT_FOUND",
    champion_allocated_respec_unsupported =
        "SI_LTM_STATUS_APPLY_PARTIAL_REASON_CP_ALLOCATION_MISMATCH",
    champion_passive_deactivate_unsupported =
        "SI_LTM_STATUS_APPLY_PARTIAL_REASON_CP_ALLOCATION_MISMATCH",
    champion_non_slottable_allocation_mismatch_skipped =
        "SI_LTM_STATUS_APPLY_PARTIAL_REASON_CP_ALLOCATION_MISMATCH",
    champion_slotted_not_purchased_skipped =
        "SI_LTM_STATUS_APPLY_PARTIAL_REASON_CHAMPION_SLOTTED_NOT_PURCHASED",
    champion_force_respec_expected_result_failed =
        "SI_LTM_STATUS_APPLY_PARTIAL_REASON_CHAMPION_FORCE_RESPEC_EXPECTED_RESULT_FAILED",
    champion_force_respec_insufficient_gold =
        "SI_LTM_STATUS_APPLY_PARTIAL_REASON_CHAMPION_FORCE_RESPEC_INSUFFICIENT_GOLD",
}

local function ResolveApplyPartialReasonStringId(reason)
    local stringIdName = APPLY_PARTIAL_REASON_STRING_IDS[reason]
    if stringIdName ~= nil then
        return stringIdName
    end
    if type(reason) == "string" and string.sub(reason, 1, 12) == "ROLE_APPLY_E" then
        return "SI_LTM_STATUS_APPLY_PARTIAL_REASON_ROLE_FAILED"
    end
    return nil
end

local function ResolveApplyResultDomainLabel(domain)
    if type(LTM_PIPELINE) == "table" and type(LTM_PIPELINE.ResolvePhaseTargetLabel) == "function" then
        return LTM_PIPELINE:ResolvePhaseTargetLabel(domain)
    end
    return tostring(domain or GetStringText("SI_LTM_COMMON_UNKNOWN"))
end

local function ResolveMultipleDomainResults(finalResult)
    local entries = {}
    local seenDomains = {}
    for _, entry in ipairs(type(finalResult) == "table" and finalResult.results or {}) do
        local domain = type(entry) == "table" and (entry.domain or entry.sourcePhase) or nil
        local severity = type(entry) == "table" and entry.severity or nil
        if type(domain) == "string"
            and domain ~= ""
            and (severity == "failure" or severity == "partial")
            and seenDomains[domain] ~= true then
            seenDomains[domain] = true
            entries[#entries + 1] = entry
        end
    end
    return #entries >= 2 and entries or nil
end

local function BuildMultipleDomainSummary(entries, safeAbortMessage)
    local failureDomains = {}
    local partialDomains = {}
    for _, entry in ipairs(entries or {}) do
        local label = ResolveApplyResultDomainLabel(entry.domain or entry.sourcePhase)
        if entry.severity == "failure" then
            failureDomains[#failureDomains + 1] = label
        elseif entry.severity == "partial" then
            partialDomains[#partialDomains + 1] = label
        end
    end

    local lines = {}
    if type(safeAbortMessage) == "string" and safeAbortMessage ~= "" then
        lines[#lines + 1] = safeAbortMessage
    end
    lines[#lines + 1] = GetStringText("SI_LTM_STATUS_APPLY_MULTIPLE_RESULTS")
    if #failureDomains > 0 then
        lines[#lines + 1] = GetStringText("SI_LTM_STATUS_APPLY_MULTIPLE_FAILURES", {
            domains = table.concat(failureDomains, " / "),
        })
    end
    if #partialDomains > 0 then
        lines[#lines + 1] = GetStringText("SI_LTM_STATUS_APPLY_MULTIPLE_PARTIALS", {
            domains = table.concat(partialDomains, " / "),
        })
    end
    return table.concat(lines, "\n")
end

local function ResolveApplyResultReasonText(reason)
    local stringIdName = ResolveApplyPartialReasonStringId(reason)
    if stringIdName ~= nil then
        return GetStringText(stringIdName)
    end
    if type(Log.ResolveLocalizedErrorReason) == "function" then
        return Log.ResolveLocalizedErrorReason(reason)
    end
    return nil
end

local function BuildMultipleDomainDetails(entries)
    local lines = {}
    for _, entry in ipairs(entries or {}) do
        local label = ResolveApplyResultDomainLabel(entry.domain or entry.sourcePhase)
        local reasonTexts = {}
        local seenTexts = {}
        local reasons = type(entry.reasons) == "table" and entry.reasons or {}
        if #reasons == 0 and type(entry.resultCode) == "string" and entry.resultCode ~= "" then
            reasons = {
                entry.resultCode,
            }
        end
        for _, reason in ipairs(reasons) do
            local reasonText = ResolveApplyResultReasonText(reason)
            if reasonText == nil and type(reason) == "string" and reason ~= "" then
                reasonText = reason
            end
            if type(reasonText) == "string" and reasonText ~= "" and seenTexts[reasonText] ~= true then
                seenTexts[reasonText] = true
                reasonTexts[#reasonTexts + 1] = reasonText
            end
        end
        if #reasonTexts > 0 then
            lines[#lines + 1] = label .. ": " .. table.concat(reasonTexts, " / ")
        else
            lines[#lines + 1] = label
        end
    end
    return table.concat(lines, "\n")
end

local function WriteImportantApplyChat(message)
    if type(Log.WriteImportantChat) == "function" then
        Log.WriteImportantChat(message)
    elseif type(Log.WriteChat) == "function" then
        Log.WriteChat(message)
    end
end

function LTM:FinishApplyRun(runId, success, err, finalResult, afterActiveRunCleared)
    local activeRun = self.activeApplyRun
    if type(activeRun) ~= "table" or activeRun.runId ~= runId then
        return false
    end

    if type(LTM_UI.Dispatch) == "table"
        and type(LTM_UI.Dispatch.RecordSkillPointTerminalSummary) == "function" then
        local terminalOk, terminalErr = pcall(
            LTM_UI.Dispatch.RecordSkillPointTerminalSummary,
            LTM_UI.Dispatch,
            runId,
            activeRun.buildId,
            finalResult
        )
        if terminalOk ~= true then
            Log.Debug("Skill Point terminal summary failed:", terminalErr)
        end
    end

    self:LogApplyRequestSummary(
        "Run finished",
        "runId=" .. tostring(runId),
        "success=" .. tostring(type(finalResult) == "table" and finalResult.finalStatus ~= "failure" or false),
        "err=" .. tostring(err),
        "finalStatus=" .. tostring(type(finalResult) == "table" and finalResult.finalStatus or nil),
        "partial=" .. tostring(type(finalResult) == "table" and finalResult.finalStatus == "partial_success" or false),
        "resultCode=" .. tostring(type(finalResult) == "table" and finalResult.resultCode or nil),
        "buildId=" .. tostring(activeRun.buildId),
        "pageId=" .. tostring(activeRun.pageId),
        "source=" .. tostring(activeRun.source)
    )

    local multipleDomainResults = ResolveMultipleDomainResults(finalResult)
    local isSafeAbortFailure = IsPipelineSafeAbortFailure(err, finalResult)
    local safeAbortMessage = isSafeAbortFailure
        and GetStringText("SI_LTM_STATUS_APPLY_SAFE_ABORT", {
            reason = FormatApplySafeAbortChatReason(GetProgressFailureReason(err, finalResult)),
        })
        or nil
    if type(Log.WriteChat) == "function" then
        local buildId = tostring(activeRun.buildId or "")
        local status = type(finalResult) == "table" and finalResult.finalStatus or nil
        if multipleDomainResults ~= nil then
            WriteImportantApplyChat(BuildMultipleDomainSummary(multipleDomainResults, safeAbortMessage))
            if type(Log.IsSummaryDebugEnabled) == "function" and Log.IsSummaryDebugEnabled() then
                WriteImportantApplyChat(BuildMultipleDomainDetails(multipleDomainResults))
            end
        elseif status == "partial_success" then
            Log.WriteChat(GetStringText("SI_LTM_STATUS_APPLY_PARTIAL", {
                buildId = buildId,
            }))
            local reasons = type(finalResult.reasons) == "table" and finalResult.reasons or {}
            local writtenReasonKeys = {}
            for _, reason in ipairs(reasons) do
                local stringIdName = ResolveApplyPartialReasonStringId(reason)

                if stringIdName ~= nil and writtenReasonKeys[stringIdName] ~= true then
                    writtenReasonKeys[stringIdName] = true
                    Log.WriteChat(GetStringText(stringIdName))
                end
            end
        end
    end

    if isSafeAbortFailure then
        if multipleDomainResults == nil and type(Log.WriteChat) == "function" then
            Log.WriteChat(safeAbortMessage)
        end
        HideMainWindowIfAvailable()
    end

    if type(finalResult) == "table"
        and finalResult.finalStatus ~= "failure"
        and type(activeRun.request) == "table"
        and activeRun.request.partialScope == nil
        and type(activeRun.buildId) == "string"
        and activeRun.buildId ~= "" then
        self:SetCurrentBuildCardState(activeRun.buildId, activeRun.pageId)
    end

    self.activeApplyRun = nil

    local queuedStarted = false
    local function StartQueuedApplyRequestOnce()
        if queuedStarted then
            return
        end

        queuedStarted = true
        self:StartQueuedApplyRequest()
    end

    if type(afterActiveRunCleared) == "function" then
        local ok, callbackErr = pcall(afterActiveRunCleared, StartQueuedApplyRequestOnce)
        if ok ~= true then
            Log.Debug("Post apply hook failed:", callbackErr)
            StartQueuedApplyRequestOnce()
        end
        return true
    end

    StartQueuedApplyRequestOnce()
    return true
end

function LTM:QueueApplyRequest(requestData, completion)
    local previousEnvelope = self.pendingApplyRequest
    local queuedEnvelope = BuildApplyRequestEnvelope(requestData, completion)
    self.pendingApplyRequest = queuedEnvelope

    BeginApplyProgressForRequest(requestData, "Waiting for combat to end")
    self.applyProgressSpecificWaitActive = true
    self:NotifyWaitStarted(self, "combat_queue")

    if type(previousEnvelope) == "table" then
        self:LogApplyRequestSummary(
            "Combat queued request superseded",
            "buildId=" .. tostring(previousEnvelope.buildId),
            "pageId=" .. tostring(previousEnvelope.pageId),
            "source=" .. tostring(previousEnvelope.source),
            "requestedAt=" .. tostring(previousEnvelope.requestedAt)
        )
        CompleteSupersededApplyRequestEnvelope(previousEnvelope)
    end
end

function LTM:OnCombatStateChanged(inCombat)
    if inCombat then
        return
    end

    local queuedRequest = self.pendingApplyRequest
    if type(queuedRequest) ~= "table" or type(queuedRequest.request) ~= "table" then
        return
    end

    self.pendingApplyRequest = nil

    if type(IsUnitInCombat) == "function" and IsUnitInCombat("player") then
        self.pendingApplyRequest = queuedRequest
        return
    end

    self:ResetWaitNotification(self)
    ShowMainWindowIfAvailable()
    Log.WriteChat(GetStringText("SI_LTM_STATUS_APPLY_RESUME_AFTER_COMBAT"))
    StartApplyRequestEnvelope(self, queuedRequest)
end

function LTM:RegisterCombatStateObserver()
    if self.combatStateObserverRegistered then
        return
    end

    self.combatStateObserverRegistered = true
    EVENT_MANAGER:RegisterForEvent(self.name .. "_CombatState", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        self:OnCombatStateChanged(inCombat)
    end)
end

function LTM:RunBuild(build, completion, options)
    if not build then
        return false, "build_not_found"
    end

    local ok, err = LTM_PIPELINE:Run(build, completion, options)
    if not ok and err ~= "handled" then
        Log.Debug("Build run failed:", err)
    end
    return ok, err
end

function LTM:EvaluateApplyPrecheck(request, options)
    local normalizedRequest = CloneApplyRequest(request)
    normalizedRequest.source = type(normalizedRequest.source) == "string" and normalizedRequest.source ~= ""
        and normalizedRequest.source
        or "unknown"
    normalizedRequest.forceChampionRespec = ResolveApplyRequestForceChampionRespec(normalizedRequest)

    if type(LTM_APPLY_PRECHECK) ~= "table" or type(LTM_APPLY_PRECHECK.Evaluate) ~= "function" then
        return nil, "apply_precheck_unavailable"
    end

    return LTM_APPLY_PRECHECK:Evaluate(normalizedRequest, options)
end

local function EvaluateApplyRequestGate(request)
    if type(LTM_APPLY_PRECHECK_GATE) ~= "table"
        or type(LTM_APPLY_PRECHECK_GATE.Evaluate) ~= "function" then
        return nil
    end

    return LTM_APPLY_PRECHECK_GATE:Evaluate(request)
end

local function ResolveAcceptedSkillPointPrecheck(request)
    local precheck = type(request) == "table" and request.acceptedSkillPointPrecheck or nil
    if type(precheck) ~= "table" then
        return nil, nil
    end

    local continuation = type(precheck.continuation) == "table" and precheck.continuation or nil
    return precheck, continuation
end

local function ResolveSkillPhasePreflightSkip(build, request)
    if type(build) ~= "table"
        or type(request) ~= "table"
        or request.preflightMode == "subclass_only" then
        return nil, nil
    end

    local _, continuation = ResolveAcceptedSkillPointPrecheck(request)
    if type(continuation) ~= "table" then
        return nil, nil
    end

    if continuation.skillPhaseMode == "skip_due_to_insufficient_points" then
        return continuation.skillPhaseMode,
            continuation.skillPhaseReason or "insufficient_points_preflight"
    end

    return nil, nil
end

function LTM:ApplyRequestCore(request, completion)
    local normalizedRequest = CloneApplyRequest(request)
    normalizedRequest.source = type(normalizedRequest.source) == "string" and normalizedRequest.source ~= ""
        and normalizedRequest.source
        or "unknown"
    normalizedRequest.forceChampionRespec = ResolveApplyRequestForceChampionRespec(normalizedRequest)

    if normalizedRequest.skipStartStateCheck ~= true
        and type(LTM_APPLY_PRECHECK) == "table"
        and type(LTM_APPLY_PRECHECK.Begin) == "function" then
        return LTM_APPLY_PRECHECK:Begin(normalizedRequest, completion, function(cleanRequest, cleanCompletion)
            local resumedRequest = CloneApplyRequest(cleanRequest)
            resumedRequest.skipStartStateCheck = true
            return LTM:ApplyRequestCore(resumedRequest, cleanCompletion)
        end)
    end

    local build = normalizedRequest.build
    if type(build) ~= "table" then
        local buildId = normalizedRequest.buildId
        build = type(LTM_BUILD_STORE) == "table" and type(LTM_BUILD_STORE.GetBuildById) == "function"
            and LTM_BUILD_STORE:GetBuildById(buildId)
            or nil
        if not build then
            Log.Debug("Build not found:", buildId)
            return false, "build_not_found"
        end
    end

    local skillPhaseMode, skillPhaseReason = ResolveSkillPhasePreflightSkip(build, normalizedRequest)
    local acceptedPrecheck, acceptedContinuation = ResolveAcceptedSkillPointPrecheck(normalizedRequest)
    local resolvedSpSaver = CloneResolvedSpSaverPolicy(
        type(acceptedPrecheck) == "table" and acceptedPrecheck.spSaver or nil
    )
    local resolvedPreflightMode = type(acceptedContinuation) == "table"
        and acceptedContinuation.resolvedPreflightMode
        or normalizedRequest.preflightMode
    if skillPhaseMode == "skip_due_to_insufficient_points" then
        -- Existing subclass-only transaction mode commits subclass and Class
        -- Mastery lanes without entering Normal SP mutations.
        resolvedPreflightMode = "subclass_only"
    end

    return self:RunBuild(build, completion, {
        partialScope = normalizedRequest.partialScope,
        preflightMode = resolvedPreflightMode,
        skillPhaseMode = skillPhaseMode,
        skillPhaseReason = skillPhaseReason,
        spSaver = resolvedSpSaver,
        source = normalizedRequest.source,
        pageId = normalizedRequest.pageId,
        forceChampionRespec = normalizedRequest.forceChampionRespec == true,
        onPhaseUpdate = normalizedRequest.onPhaseUpdate,
        onStatusUpdate = normalizedRequest.onStatusUpdate,
    })
end

local function BuildAcceptedSkillPointContinuation(precheck)
    if type(precheck) ~= "table" then
        return nil
    end

    local route = type(precheck.route) == "table" and precheck.route or nil
    local diagnostics = type(precheck.diagnostics) == "table" and precheck.diagnostics or nil
    local skillPointPlan = type(diagnostics) == "table" and diagnostics.skillPointPlan or nil
    local skillPhaseMode = type(route) == "table" and route.skillPhaseMode or nil
    local resolvedPreflightMode = skillPhaseMode == "skip_due_to_insufficient_points"
        and "subclass_only"
        or (type(route) == "table" and route.preflightMode or nil)
    return {
        continuation = {
            skillPhaseMode = skillPhaseMode,
            skillPhaseReason = type(route) == "table" and route.skillPhaseReason or nil,
            resolvedPreflightMode = resolvedPreflightMode,
        },
        diagnostics = {
            expectedResult = type(skillPointPlan) == "table" and skillPointPlan.expectedResult or nil,
        },
        spSaver = CloneResolvedSpSaverPolicy(precheck.spSaver),
    }
end

local function BuildApplyPrecheckFailureResult(err, precheck, request)
    return {
        finalStatus = "failure",
        resultCode = err,
        reasons = { err },
        residualSummary = nil,
        sourcePhase = "apply_precheck",
        failurePhase = "apply_precheck",
        failurePhases = { "apply_precheck" },
        activityRestrictionType = type(precheck) == "table" and precheck.activityRestrictionType or nil,
        buildId = GetApplyRequestIdentifier(request),
        pageId = type(request) == "table" and request.pageId or nil,
        source = type(request) == "table" and request.source or nil,
    }
end

local function NotifyApplyPrecheckFailure(completion, err, finalResult)
    if type(completion) ~= "function" then
        return
    end

    local ok, callbackErr = pcall(completion, false, err, finalResult)
    if ok ~= true then
        Log.Debug("Apply request completion failed:", callbackErr)
    end
end

function LTM:ApplyRequest(request, completion)
    local normalizedRequest = CloneApplyRequest(request)
    normalizedRequest.source = type(normalizedRequest.source) == "string" and normalizedRequest.source ~= ""
        and normalizedRequest.source
        or "unknown"
    normalizedRequest.forceChampionRespec = ResolveApplyRequestForceChampionRespec(normalizedRequest)

    self:LogApplyRequestSummary(
        "Apply request received",
        "buildId=" .. tostring(GetApplyRequestIdentifier(normalizedRequest)),
        "pageId=" .. tostring(normalizedRequest.pageId),
        "source=" .. tostring(normalizedRequest.source),
        "forceChampionRespec=" .. tostring(normalizedRequest.forceChampionRespec == true)
    )

    -- Combat remains the first runtime gate. Once a run is active, defer the
    -- remaining runtime precheck until this request is actually started so it
    -- cannot observe the active run's transient skill state.
    local gateResult = EvaluateApplyRequestGate(normalizedRequest)
    if type(gateResult) == "table" and gateResult.action == "queue" then
        normalizedRequest.acceptedSkillPointPrecheck = nil
        self:QueueApplyRequest(normalizedRequest, completion)
        return true, "queued"
    end

    if self:IsApplyRunning() then
        normalizedRequest.acceptedSkillPointPrecheck = nil
        return self:QueueLatestApplyRequest(normalizedRequest, completion)
    end

    local precheck = self:EvaluateApplyPrecheck(normalizedRequest)
    if type(precheck) == "table" and precheck.action == "queue" then
        normalizedRequest.acceptedSkillPointPrecheck = nil
        self:QueueApplyRequest(normalizedRequest, completion)
        return true, "queued"
    end
    if type(precheck) == "table" and precheck.action == "block" then
        local err = precheck.error or "apply_precheck_blocked"
        if type(Log.LogDebugSummary) == "function" then
            Log.LogDebugSummary(
                "Apply request blocked by precheck",
                "reason=" .. tostring(err),
                "invalidReason=" .. tostring(precheck.invalidReason),
                "buildId=" .. tostring(GetApplyRequestIdentifier(normalizedRequest))
            )
        end
        if err == "skill_point_evaluator_invalid" and type(Log.WriteChat) == "function" then
            Log.WriteChat(GetStringText("SI_LTM_STATUS_SKILL_POINT_EVALUATOR_INVALID", {
                reason = tostring(precheck.invalidReason or "unknown"),
            }))
        end
        if err == "activity_disallowed" then
            self:NotifyActivityDisallowed(precheck.activityRestrictionType)
            local finalResult = BuildApplyPrecheckFailureResult(err, precheck, normalizedRequest)
            NotifyApplyPrecheckFailure(completion, err, finalResult)
        end
        return false, err
    end

    normalizedRequest.acceptedSkillPointPrecheck = BuildAcceptedSkillPointContinuation(precheck)
    local runId, activeRun = self:BeginApplyRun(normalizedRequest)
    if type(LTM_UI.Dispatch) == "table"
        and type(LTM_UI.Dispatch.RecordAcceptedSkillPointRun) == "function" then
        local auditOk, auditErr = pcall(
            LTM_UI.Dispatch.RecordAcceptedSkillPointRun,
            LTM_UI.Dispatch,
            {
                runId = runId,
                buildId = activeRun and activeRun.buildId,
            },
            precheck
        )
        if auditOk ~= true then
            Log.Debug("Skill Point accepted run audit failed:", auditErr)
        end
    end
    self:LogApplyRequestSummary(
        "Apply request accepted",
        "runId=" .. tostring(runId),
        "buildId=" .. tostring(activeRun and activeRun.buildId),
        "pageId=" .. tostring(activeRun and activeRun.pageId),
        "source=" .. tostring(activeRun and activeRun.source),
        "forceChampionRespec=" .. tostring(normalizedRequest.forceChampionRespec == true)
    )

    local progressRunToken = BeginApplyProgressForRequest(normalizedRequest, "Now applying...")
    local useSmallProgress = progressRunToken ~= nil
    if useSmallProgress then
        normalizedRequest.onPhaseUpdate = function(phaseName)
            if LTM.applyProgressActiveToken ~= progressRunToken then
                return
            end
            LTM.applyProgressSpecificWaitActive = false
            if type(LTM_UI_APPLY_PROGRESS.UpdatePhase) == "function" then
                LTM_UI_APPLY_PROGRESS:UpdatePhase(phaseName)
            end
        end
        normalizedRequest.onStatusUpdate = function(statusName, detail)
            if LTM.applyProgressActiveToken ~= progressRunToken then
                return
            end
            if statusName == "deferred" then
                if LTM.applyProgressSpecificWaitActive == true then
                    return
                end
                UpdateApplyProgressStatus("Waiting for game response")
                return
            end
            if statusName == "retry" then
                LTM.applyProgressSpecificWaitActive = true
                UpdateApplyProgressStatus("Retrying...")
                return
            end
            if statusName == "safe_abort" then
                SetApplyProgressResult(progressRunToken, false, detail, FormatApplyProgressSafeAbortStatus(detail))
                return
            end
        end
    end

    local lifecycleCompleted = false
    local function finalizeLifecycle(success, err, finalResult)
        if lifecycleCompleted then
            return
        end

        lifecycleCompleted = true
        if useSmallProgress and LTM.applyProgressActiveToken == progressRunToken then
            local progressFailureReason = GetProgressFailureReason(err, finalResult)
            local safeAbortStatus = IsPipelineSafeAbortFailure(err, finalResult)
                and FormatApplyProgressSafeAbortStatus(progressFailureReason)
                or nil
            SetApplyProgressResult(
                progressRunToken,
                type(finalResult) == "table" and finalResult.finalStatus ~= "failure",
                progressFailureReason,
                safeAbortStatus
            )
            if type(finalResult) == "table"
                and finalResult.finalStatus ~= "failure"
                and type(zo_callLater) == "function" then
                zo_callLater(function()
                    HideApplyProgressIfCurrent(progressRunToken)
                end, 1200)
            end
        end

        local postFullApply = type(finalResult) == "table"
            and finalResult.finalStatus ~= "failure"
            and type(normalizedRequest.postFullApply) == "function"
            and normalizedRequest.postFullApply
            or nil

        local completionNotified = false
        local function NotifyCompletion()
            if completionNotified then
                return
            end

            completionNotified = true
            if type(completion) == "function" then
                local completionOk, completionErr = pcall(completion, success == true, err, finalResult)
                if completionOk ~= true then
                    Log.Debug("Apply request completion failed:", completionErr)
                end
            end
        end

        if type(postFullApply) ~= "function" then
            NotifyCompletion()
            self:FinishApplyRun(runId, success == true, err, finalResult)
            return
        end

        self:FinishApplyRun(runId, success == true, err, finalResult, function(startQueuedApplyRequest)
            local postCompleted = false
            local function FinishPostApply()
                if postCompleted then
                    return
                end

                postCompleted = true
                NotifyCompletion()
                if type(startQueuedApplyRequest) == "function" then
                    startQueuedApplyRequest()
                end
            end

            local ok, postErr = pcall(postFullApply, FinishPostApply, finalResult)
            if ok ~= true then
                Log.Debug("Post full apply failed:", postErr)
                FinishPostApply()
            end
        end)
    end

    local ok, err = self:ApplyRequestCore(normalizedRequest, finalizeLifecycle)
    if ok ~= true then
        finalizeLifecycle(false, err)
    end

    return ok, err
end

function LTM:RunBuildById(buildId, completion, options)
    options = type(options) == "table" and options or nil
    return self:ApplyRequest({
        buildId = buildId,
        source = options and options.source or "run_build_by_id",
        pageId = options and options.pageId or nil,
        skipCombatQueue = options and options.skipCombatQueue or nil,
        partialScope = options and options.partialScope or nil,
        preflightMode = options and options.preflightMode or nil,
    }, completion)
end

function LTM:HandlePrimaryShortcut()
    if type(LTM_UI) == "table" and type(LTM_UI.ToggleMainWindow) == "function" then
        LTM_UI:ToggleMainWindow()
    end
end

function LTM:HandleBuildCardShortcut(shortcutType, ordinal)
    local buildId, pageId, err = self:ResolveBuildCardShortcutTarget(shortcutType, ordinal)
    if type(buildId) ~= "string" or buildId == "" then
        if type(Log.WriteChat) == "function" then
            Log.WriteChat(GetStringText("SI_LTM_STATUS_ERROR", {
                action = "Build Card keybind",
                reason = type(Log.LocalizeErrorReason) == "function" and Log.LocalizeErrorReason(err) or tostring(err),
            }))
        end
        return nil, err
    end

    local ok, applyErr = self:ApplyRequest({
        buildId = buildId,
        pageId = pageId,
        source = "keybind_full_apply",
    }, function(success, completionErr)
        if type(LTM_UI) == "table" and type(LTM_UI.OnApplyCompleted) == "function" then
            LTM_UI:OnApplyCompleted(success, completionErr)
        end
    end)

    if ok == true then
        self:SetCurrentBuildCardState(buildId, pageId)
        self:SyncSelectedBuildCardState(buildId, pageId)
    end

    return ok, applyErr
end

function LTM:SetHudLauncherHidden(hidden)
    if type(self.savedVars) ~= "table" then
        return false
    end

    local hudSettings = self:GetHudLauncherSettings(true)
    if type(hudSettings) ~= "table" then
        return false
    end

    hudSettings.hidden = hidden == true
    if type(LTM_UI) == "table" and type(LTM_UI.RefreshHudLauncher) == "function" then
        LTM_UI:RefreshHudLauncher()
    end

    Log.WriteChat("HUD icon enabled=" .. tostring(hudSettings.hidden ~= true))
    return true
end

function LTM:SetHudLauncherLocked(locked)
    if type(self.savedVars) ~= "table" then
        return false
    end

    local hudSettings = self:GetHudLauncherSettings(true)
    if type(hudSettings) ~= "table" then
        return false
    end

    hudSettings.locked = locked == true
    if type(LTM_UI) == "table" and type(LTM_UI.RefreshHudLauncher) == "function" then
        LTM_UI:RefreshHudLauncher()
    end

    Log.WriteChat("HUD icon locked=" .. tostring(hudSettings.locked == true))
    return true
end

function LTM_PrimaryShortcut()
    return LTM:HandlePrimaryShortcut()
end

function LTM_BuildCardShortcut(shortcutType, ordinal)
    return LTM:HandleBuildCardShortcut(shortcutType, ordinal)
end

function LTM:RegisterSlashCommands()
    SLASH_COMMANDS["/ltm"] = function(args)
        local arg = NormalizeSlashArg(args)

        if arg == "on" or arg == "enable" or arg == "show" or arg == "1" then
            self:SetHudLauncherHidden(false)
            return
        end

        if arg == "off" or arg == "disable" or arg == "hide" or arg == "0" then
            self:SetHudLauncherHidden(true)
            return
        end

        if arg == "status" then
            local hudSettings = self:GetHudLauncherSettings(false)
            Log.WriteChat("HUD icon enabled=" .. tostring(type(hudSettings) ~= "table" or hudSettings.hidden ~= true))
            return
        end

        if arg ~= "" then
            Log.WriteChat("Usage: /ltm on|off|status")
            return
        end

        return self:HandlePrimaryShortcut()
    end

    SLASH_COMMANDS["/ltm_debug"] = function(args)
        local arg = NormalizeSlashArg(args)

        if arg == "" or arg == "status" then
            Log.WriteChat("Debug enabled=" .. tostring(self.savedVars and self.savedVars.debugRunCompact == true))
            return
        end

        if arg == "on" or arg == "enable" or arg == "1" then
            self:SetCompactDebugRunEnabled(true)
            return
        end

        if arg == "off" or arg == "disable" or arg == "0" then
            self:SetCompactDebugRunEnabled(false)
            return
        end

        Log.WriteChat("Usage: /ltm_debug on|off|status")
    end
end

function LTM:Initialize()
    local migrationFailed = self:InitializeSavedVars() == false
    self:ApplyLanguage()
    if migrationFailed and type(Log.LogSavedVarsMigrationError) == "function" then
        Log.LogSavedVarsMigrationError()
    end
    if type(LTM_BUILD_STORE) == "table" and type(LTM_BUILD_STORE.Initialize) == "function" then
        LTM_BUILD_STORE:Initialize(self.savedVars)
    end
    if type(LTM_QUICKSLOT_PROFILES) == "table" and type(LTM_QUICKSLOT_PROFILES.Initialize) == "function" then
        LTM_QUICKSLOT_PROFILES:Initialize(self.savedVars)
    end
    if type(LTM_FOOD_HELPER) == "table" and type(LTM_FOOD_HELPER.Initialize) == "function" then
        LTM_FOOD_HELPER:Initialize(self.savedVars)
    end
    if type(LTM_ALCHEMY_RECIPE) == "table" and type(LTM_ALCHEMY_RECIPE.Initialize) == "function" then
        LTM_ALCHEMY_RECIPE:Initialize(self.savedVars)
    end
    if type(LTM_ENCHANT_RECIPE) == "table" and type(LTM_ENCHANT_RECIPE.Initialize) == "function" then
        LTM_ENCHANT_RECIPE:Initialize(self.savedVars)
    end
    if type(LTM_SCRIBING_RECIPE) == "table" and type(LTM_SCRIBING_RECIPE.Initialize) == "function" then
        LTM_SCRIBING_RECIPE:Initialize(self.savedVars)
    end
    if type(LTM_AUTO_REFILL) == "table" and type(LTM_AUTO_REFILL.Initialize) == "function" then
        LTM_AUTO_REFILL:Initialize()
    end
    if type(LTM_UI) == "table" and type(LTM_UI.Initialize) == "function" then
        LTM_UI:Initialize()
    end
    if type(LTM_UI) == "table"
        and type(LTM_UI.StationLauncher) == "table"
        and type(LTM_UI.StationLauncher.Initialize) == "function" then
        LTM_UI.StationLauncher:Initialize()
    end
    self:RegisterSettingsPanel()
    self:RegisterSlashCommands()
    self:RegisterCombatStateObserver()
    Log.Debug("Initialized")
end

function LTM.OnAddOnLoaded(_, addonName)
    if addonName ~= LTM.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(LTM.name, EVENT_ADD_ON_LOADED)
    LTM:Initialize()
end

EVENT_MANAGER:RegisterForEvent(LTM.name, EVENT_ADD_ON_LOADED, LTM.OnAddOnLoaded)
-- Thanks for reading this.
