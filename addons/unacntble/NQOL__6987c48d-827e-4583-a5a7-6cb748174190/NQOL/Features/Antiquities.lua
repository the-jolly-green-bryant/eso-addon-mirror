NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Antiquities = {}

local SHOW_MISSING_LABEL = NQOL.L("features.antiquities.show_missing")
local SHOW_ALL_LABEL = NQOL.L("features.antiquities.show_all")
NQOL.Lexicon.RegisterRefreshCallback(function()
    SHOW_MISSING_LABEL = NQOL.L("features.antiquities.show_missing")
    SHOW_ALL_LABEL = NQOL.L("features.antiquities.show_all")
end)
local MAX_HOOK_ATTEMPTS = 20
local AUTO_EYE_EVENT_NAMESPACE = "NQOL_Antiquities_AutoEye"
local AUTO_EYE_INTERVAL_MS = 1000
local AUTO_EYE_FALLBACK_COLLECTIBLE_ID = 8006
local VENDOR_LEAD_OWNED_ICON = ZO_TIMER_ICON_64 or "EsoUI/Art/Miscellaneous/timer_64.dds"
local VENDOR_LEAD_EXCAVATED_ICON = "EsoUI/Art/Miscellaneous/check_icon_64.dds"

local defaults = {
    antiquities = {
        showMissingActiveLeadsButton = false,
        autoEye = false,
        vendorLeadIndicators = false,
    },
}

local savedVariables
local showMissingOnly = false
local hookAttempts = 0
local hooksInstalled = false
local vendorHookAttempts = 0
local vendorHookInstalled = false
local autoEyeRunning = false
local autoEyeDigging = false
local autoEyeEventsRegistered = false

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "antiquities")
    NQOL.Settings.Default(settings, defaults.antiquities, "showMissingActiveLeadsButton")
    NQOL.Settings.Default(settings, defaults.antiquities, "autoEye")
    NQOL.Settings.Default(settings, defaults.antiquities, "vendorLeadIndicators")

    return settings
end

local function IsPlayerBusyForAutoEye()
    return (IsPlayerMoving and IsPlayerMoving())
        or (IsUnitInCombat and IsUnitInCombat("player"))
        or autoEyeDigging
end

local function IsAutoEyeAllowedInCurrentContent()
    if IsUnitInDungeon("player") then
        return false
    end

    if IsPlayerInAvAWorld() then
        return false
    end

    if IsActiveWorldBattleground() then
        return false
    end

    if GetCurrentZoneHouseId() > 0 then
        return false
    end

    local contentType = GetMapContentType()
    if contentType == MAP_CONTENT_AVA
        or contentType == MAP_CONTENT_BATTLEGROUND
        or contentType == MAP_CONTENT_DUNGEON
    then
        return false
    end

    return true
end

local function HasTrackedAntiquityForAutoEye()
    local antiquityId = GetTrackedAntiquityId()
    return antiquityId ~= nil and antiquityId > 0
end

local function ShouldRunAutoEye()
    return Antiquities.GetAutoEye()
        and not autoEyeDigging
        and HasTrackedAntiquityForAutoEye()
        and IsAutoEyeAllowedInCurrentContent()
end

local function GetAutoEyeCollectibleId()
    if GetAntiquityScryingToolCollectibleId then
        local collectibleId = GetAntiquityScryingToolCollectibleId()
        if collectibleId and collectibleId > 0 then
            return collectibleId
        end
    end

    return AUTO_EYE_FALLBACK_COLLECTIBLE_ID
end

local function CanUseAutoEyeCollectible(collectibleId)
    if ZO_IsScryingToolUnlocked and not ZO_IsScryingToolUnlocked() then
        return false
    end

    if IsCollectibleValidForPlayer and not IsCollectibleValidForPlayer(collectibleId) then
        return false
    end

    if IsCollectibleUsable and not IsCollectibleUsable(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
        return false
    end

    if GetCollectibleBlockReason then
        local blockReason = GetCollectibleBlockReason(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        if blockReason ~= nil and blockReason ~= COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
            return false
        end
    elseif IsCollectibleBlocked and IsCollectibleBlocked(collectibleId) then
        return false
    end

    return true
end

local function RunAutoEye()
    if not ShouldRunAutoEye() or IsPlayerBusyForAutoEye() or not UseCollectible then
        return
    end

    local collectibleId = GetAutoEyeCollectibleId()
    if not CanUseAutoEyeCollectible(collectibleId) then
        return
    end

    if GetCollectibleCooldownAndDuration then
        local cooldown, duration = GetCollectibleCooldownAndDuration(collectibleId)
        if (cooldown and cooldown > 0) or (duration and duration > 0) then
            return
        end
    end

    UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
end

local function StartAutoEye()
    if autoEyeRunning or not ShouldRunAutoEye() then
        return
    end

    EVENT_MANAGER:RegisterForUpdate(AUTO_EYE_EVENT_NAMESPACE, AUTO_EYE_INTERVAL_MS, RunAutoEye)
    autoEyeRunning = true
    RunAutoEye()
end

local function StopAutoEye()
    if not autoEyeRunning then
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(AUTO_EYE_EVENT_NAMESPACE)
    autoEyeRunning = false
end

local function RefreshAutoEye()
    if ShouldRunAutoEye() then
        StartAutoEye()
    else
        StopAutoEye()
    end
end

local function RegisterAutoEyeEvents()
    if autoEyeEventsRegistered or not EVENT_MANAGER then
        return
    end

    autoEyeEventsRegistered = true
    EVENT_MANAGER:RegisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
        RefreshAutoEye()
    end)
    EVENT_MANAGER:RegisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_Deactivated", EVENT_PLAYER_DEACTIVATED, StopAutoEye)
    EVENT_MANAGER:RegisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_ZoneChanged", EVENT_ZONE_CHANGED, RefreshAutoEye)
    EVENT_MANAGER:RegisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_TrackingInitialized", EVENT_ANTIQUITY_TRACKING_INITIALIZED, RefreshAutoEye)
    EVENT_MANAGER:RegisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_TrackingUpdated", EVENT_ANTIQUITY_TRACKING_UPDATE, RefreshAutoEye)
    EVENT_MANAGER:RegisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_DigSitesUpdated", EVENT_ANTIQUITY_DIG_SITES_UPDATED, RefreshAutoEye)

    if EVENT_ANTIQUITY_DIGGING_READY_TO_PLAY then
        EVENT_MANAGER:RegisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_DiggingStart", EVENT_ANTIQUITY_DIGGING_READY_TO_PLAY, function()
            autoEyeDigging = true
            StopAutoEye()
        end)
    end

    if EVENT_ANTIQUITY_DIGGING_EXIT_RESPONSE then
        EVENT_MANAGER:RegisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_DiggingEnd", EVENT_ANTIQUITY_DIGGING_EXIT_RESPONSE, function()
            autoEyeDigging = false
            RefreshAutoEye()
        end)
    end

    RefreshAutoEye()
end

local function UnregisterAutoEyeEvents()
    if not autoEyeEventsRegistered or not EVENT_MANAGER then
        return
    end

    autoEyeEventsRegistered = false
    EVENT_MANAGER:UnregisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_Activated", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_Deactivated", EVENT_PLAYER_DEACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_ZoneChanged", EVENT_ZONE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_TrackingInitialized", EVENT_ANTIQUITY_TRACKING_INITIALIZED)
    EVENT_MANAGER:UnregisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_TrackingUpdated", EVENT_ANTIQUITY_TRACKING_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_DigSitesUpdated", EVENT_ANTIQUITY_DIG_SITES_UPDATED)

    if EVENT_ANTIQUITY_DIGGING_READY_TO_PLAY then
        EVENT_MANAGER:UnregisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_DiggingStart", EVENT_ANTIQUITY_DIGGING_READY_TO_PLAY)
    end
    if EVENT_ANTIQUITY_DIGGING_EXIT_RESPONSE then
        EVENT_MANAGER:UnregisterForEvent(AUTO_EYE_EVENT_NAMESPACE .. "_DiggingEnd", EVENT_ANTIQUITY_DIGGING_EXIT_RESPONSE)
    end

    autoEyeDigging = false
    StopAutoEye()
end

local function RefreshAutoEyeRuntime()
    if Antiquities.GetAutoEye() then
        RegisterAutoEyeEvents()
    else
        UnregisterAutoEyeEvents()
    end
end

local function IsScryableSubcategory(categoryData)
    return categoryData and ZO_IsAntiquityScryableSubcategory and ZO_IsAntiquityScryableSubcategory(categoryData)
end

local function IsMissingCodexDiscovery(antiquityData)
    if not antiquityData then
        return false
    end

    local numLoreEntries = antiquityData.GetNumLoreEntries and antiquityData:GetNumLoreEntries() or 0
    if numLoreEntries > 0 and antiquityData.GetNumUnlockedLoreEntries then
        return antiquityData:GetNumUnlockedLoreEntries() == 0
    end

    if antiquityData.GetNumRecovered then
        return antiquityData:GetNumRecovered() == 0
    end

    return true
end

local function ShouldShowMissingToggle()
    if not Antiquities.GetShowMissingActiveLeadsButton() then
        return false
    end

    if not ANTIQUITY_JOURNAL_LIST_GAMEPAD or not ANTIQUITY_JOURNAL_LIST_GAMEPAD.GetCurrentSubcategoryData then
        return false
    end

    return IsScryableSubcategory(ANTIQUITY_JOURNAL_LIST_GAMEPAD:GetCurrentSubcategoryData())
end

local function RefreshAntiquityList()
    if ANTIQUITY_JOURNAL_GAMEPAD and ANTIQUITY_JOURNAL_GAMEPAD.RefreshAntiquityList then
        ANTIQUITY_JOURNAL_GAMEPAD:RefreshAntiquityList()
    elseif ANTIQUITY_JOURNAL_LIST_GAMEPAD and ANTIQUITY_JOURNAL_LIST_GAMEPAD.RefreshAntiquities then
        ANTIQUITY_JOURNAL_LIST_GAMEPAD:RefreshAntiquities()
    end
end

local function AddShowMissingKeybind(list)
    for _, keybindDescriptor in ipairs(list.keybindStripDescriptor) do
        if keybindDescriptor.nqolShowMissingToggle then
            return
        end
    end

    table.insert(list.keybindStripDescriptor, {
        order = 35,
        keybind = "UI_SHORTCUT_RIGHT_STICK",
        name = function()
            return showMissingOnly and SHOW_ALL_LABEL or SHOW_MISSING_LABEL
        end,
        callback = function()
            showMissingOnly = not showMissingOnly
            RefreshAntiquityList()

            if list.UpdateKeybinds then
                list:UpdateKeybinds()
            end
        end,
        visible = ShouldShowMissingToggle,
        nqolShowMissingToggle = true,
    })
end

local function PatchRefreshAntiquities(list)
    if list.NQOLOriginalRefreshAntiquities then
        return
    end

    list.NQOLOriginalRefreshAntiquities = list.RefreshAntiquities
    list.RefreshAntiquities = function(self, ...)
        local categoryData = self.GetCurrentSubcategoryData and self:GetCurrentSubcategoryData()
        local shouldFilterMissing = Antiquities.GetShowMissingActiveLeadsButton()
            and showMissingOnly
            and IsScryableSubcategory(categoryData)

        if not shouldFilterMissing or not ZO_Antiquity or not ZO_Antiquity.IsVisible then
            return self:NQOLOriginalRefreshAntiquities(...)
        end

        local originalIsVisible = ZO_Antiquity.IsVisible
        ZO_Antiquity.IsVisible = function(antiquityData, ...)
            return originalIsVisible(antiquityData, ...) and IsMissingCodexDiscovery(antiquityData)
        end

        local results = { pcall(self.NQOLOriginalRefreshAntiquities, self, ...) }
        ZO_Antiquity.IsVisible = originalIsVisible

        local succeeded = table.remove(results, 1)
        if not succeeded then
            error(results[1])
        end

        return unpack(results)
    end
end

local function PatchViewCategory()
    if not ANTIQUITY_JOURNAL_GAMEPAD or ANTIQUITY_JOURNAL_GAMEPAD.NQOLOriginalViewCategory then
        return
    end

    ANTIQUITY_JOURNAL_GAMEPAD.NQOLOriginalViewCategory = ANTIQUITY_JOURNAL_GAMEPAD.ViewCategory
    ANTIQUITY_JOURNAL_GAMEPAD.ViewCategory = function(self, antiquityCategoryData, ...)
        if antiquityCategoryData
            and ZO_IsAntiquityScryableCategory
            and not ZO_IsAntiquityScryableCategory(antiquityCategoryData)
        then
            showMissingOnly = false
        end

        return self:NQOLOriginalViewCategory(antiquityCategoryData, ...)
    end
end

local function InstallHooks()
    if hooksInstalled then
        return
    end

    if not ANTIQUITY_JOURNAL_LIST_GAMEPAD
        or not ANTIQUITY_JOURNAL_LIST_GAMEPAD.keybindStripDescriptor
        or not ANTIQUITY_JOURNAL_LIST_GAMEPAD.RefreshAntiquities
        or not ZO_Antiquity
    then
        hookAttempts = hookAttempts + 1
        if hookAttempts < MAX_HOOK_ATTEMPTS then
            zo_callLater(InstallHooks, 500)
        end
        return
    end

    AddShowMissingKeybind(ANTIQUITY_JOURNAL_LIST_GAMEPAD)
    PatchRefreshAntiquities(ANTIQUITY_JOURNAL_LIST_GAMEPAD)
    PatchViewCategory()

    hooksInstalled = true
end

local function SetVendorLeadIndicatorData(data)
    if not data
        or not data.slotIndex
        or data.entryType ~= STORE_ENTRY_TYPE_ANTIQUITY_LEAD
        or not GetStoreEntryAntiquityId
    then
        return
    end

    data.overrideStatusIndicatorIcons = nil

    local antiquityId = GetStoreEntryAntiquityId(data.slotIndex)
    if not antiquityId or antiquityId == 0 then
        return
    end

    local indicatorIcons
    local buyStoreFailure = data.buyStoreFailure
    local hasLead = (DoesAntiquityHaveLead and DoesAntiquityHaveLead(antiquityId))
        or buyStoreFailure == STORE_FAILURE_ALREADY_HAVE_ANTIQUITY_LEAD
    local wasExcavated = (GetNumAntiquitiesRecovered and (GetNumAntiquitiesRecovered(antiquityId) or 0) > 0)
        or buyStoreFailure == STORE_FAILURE_ALREADY_UNEARTHED_ANTIQUITY

    if hasLead then
        indicatorIcons = {
            {
                iconTexture = VENDOR_LEAD_OWNED_ICON,
                iconNarration = NQOL.L("features.antiquities.vendor_lead_owned_narration"),
            },
        }
    end

    if wasExcavated then
        indicatorIcons = indicatorIcons or {}
        indicatorIcons[#indicatorIcons + 1] = {
            iconTexture = VENDOR_LEAD_EXCAVATED_ICON,
            iconTint = ZO_SUCCEEDED_TEXT,
            iconNarration = NQOL.L("features.antiquities.vendor_lead_excavated_narration"),
        }
    end

    data.overrideStatusIndicatorIcons = indicatorIcons
end

local function SetVendorLeadIndicators(items)
    if not items or not Antiquities.GetVendorLeadIndicators() then
        return
    end

    for index = 1, #items do
        SetVendorLeadIndicatorData(items[index])
    end
end

local function InstallVendorHook()
    if vendorHookInstalled then
        return
    end

    local buyComponent = STORE_WINDOW_GAMEPAD
        and STORE_WINDOW_GAMEPAD.components
        and STORE_WINDOW_GAMEPAD.components[ZO_MODE_STORE_BUY]
    local buyList = buyComponent and buyComponent.list

    if not buyList or not buyList.AddItems or not ZO_PreHook then
        vendorHookAttempts = vendorHookAttempts + 1
        if vendorHookAttempts < MAX_HOOK_ATTEMPTS then
            zo_callLater(InstallVendorHook, 500)
        end
        return
    end

    ZO_PreHook(buyList, "AddItems", function(_, items)
        SetVendorLeadIndicators(items)
    end)
    vendorHookInstalled = true
end

local function RefreshActiveVendorList()
    if not STORE_WINDOW_GAMEPAD or not STORE_WINDOW_GAMEPAD.GetActiveComponent then
        return
    end

    local activeComponent = STORE_WINDOW_GAMEPAD:GetActiveComponent()
    if activeComponent and activeComponent.Refresh and activeComponent.GetStoreMode and activeComponent:GetStoreMode() == ZO_MODE_STORE_BUY then
        activeComponent:Refresh()
    end
end

function Antiquities.Initialize()
    InstallHooks()
    InstallVendorHook()
    RefreshAutoEyeRuntime()
end

function Antiquities.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function Antiquities.GetShowMissingActiveLeadsButton()
    if not savedVariables then
        return defaults.antiquities.showMissingActiveLeadsButton
    end

    return GetSettings().showMissingActiveLeadsButton
end

function Antiquities.GetShowMissingActiveLeadsButtonDefault()
    return defaults.antiquities.showMissingActiveLeadsButton
end

function Antiquities.SetShowMissingActiveLeadsButton(value)
    GetSettings().showMissingActiveLeadsButton = value == true

    if not GetSettings().showMissingActiveLeadsButton then
        showMissingOnly = false
        RefreshAntiquityList()
    end

    if ANTIQUITY_JOURNAL_LIST_GAMEPAD and ANTIQUITY_JOURNAL_LIST_GAMEPAD.UpdateKeybinds then
        ANTIQUITY_JOURNAL_LIST_GAMEPAD:UpdateKeybinds()
    end
end

function Antiquities.GetAutoEye()
    if not savedVariables then
        return defaults.antiquities.autoEye
    end

    return GetSettings().autoEye
end

function Antiquities.SetAutoEye(value)
    GetSettings().autoEye = value == true
    RefreshAutoEyeRuntime()
end

function Antiquities.GetVendorLeadIndicators()
    if not savedVariables then
        return defaults.antiquities.vendorLeadIndicators
    end

    return GetSettings().vendorLeadIndicators
end

function Antiquities.GetVendorLeadIndicatorsDefault()
    return defaults.antiquities.vendorLeadIndicators
end

function Antiquities.SetVendorLeadIndicators(value)
    GetSettings().vendorLeadIndicators = value == true
    RefreshActiveVendorList()
end

function Antiquities.GetAutoEyeLabel()
    return NQOL.L("features.antiquities.auto_eye_label")
end

function Antiquities.GetAutoEyeTooltip()
    return NQOL.L("features.antiquities.auto_eye_tooltip")
end

function Antiquities.GetShowMissingActiveLeadsButtonLabel()
    return NQOL.L("features.antiquities.show_missing_active_leads_button_label")
end

function Antiquities.GetShowMissingActiveLeadsButtonTooltip()
    return NQOL.L("features.antiquities.show_missing_active_leads_button_tooltip")
end

function Antiquities.GetVendorLeadIndicatorsLabel()
    return NQOL.L("features.antiquities.vendor_lead_indicators_label")
end

function Antiquities.GetVendorLeadIndicatorsTooltip()
    return NQOL.L("features.antiquities.vendor_lead_indicators_tooltip")
end

NQOL.Features.Antiquities = Antiquities
