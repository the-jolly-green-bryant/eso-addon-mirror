NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Provisioning = {}

local EVENT_NAMESPACE = "NQOL_Provisioning"
local REFRESH_THRESHOLD_SECONDS = 5 * 60
local CHECK_INTERVAL_MS = 60 * 1000
local RETRY_DELAY_MS = 3000
local EFFECT_CHECK_DELAY_MS = 250
local AUTO_USE_VERIFY_DELAY_MS = 1000
local USE_COOLDOWN_MS = 30 * 1000
local STOCK_WARNING_THRESHOLD = 5
local STOCK_CHECK_DELAY_MS = 500
local STARTUP_CHECK_DELAYS_MS = { 3000, 7000, 15000 }
local INDEX_ACTION_NAME = 1
local INDEX_ACTION_CALLBACK = 2

local defaults = {
    provisioning = {
        autoFood = false,
        logFood = false,
        checkStock = false,
        characterFood = {},
    },
}

local savedVariables
local eventsRegistered = false
local manualUseHooksInstalled = false
local checkQueued = false
local retryQueued = false
local effectCheckQueued = false
local pendingRefresh = false
local lastUseAtMilliseconds
local assumedFoodBuffEnding = 0
local savedFoodItemCount
local originalActionBarOnActionButtonUp

local RefreshSavedFoodItemCount
local QueueRetry

local function Log(message)
    NQOL.Chat.Message(message, NQOL.L("common.feature.provisioning"))
end

local function GetCharacterKey()
    if GetCurrentCharacterId then
        local characterId = GetCurrentCharacterId()
        if characterId and characterId ~= 0 then
            return "id:" .. tostring(characterId)
        end
    end

    if GetUnitName then
        local characterName = GetUnitName("player")
        if characterName and characterName ~= "" then
            return "name:" .. characterName
        end
    end

    return "default"
end

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "provisioning")

    NQOL.Settings.Default(settings, defaults.provisioning, "autoFood")
    NQOL.Settings.Default(settings, defaults.provisioning, "logFood")
    NQOL.Settings.Default(settings, defaults.provisioning, "checkStock")
    NQOL.Settings.EnsureTable(settings, "characterFood")

    return settings
end

local function GetFoodSettings()
    local settings = GetSettings()
    if not savedVariables then
        return settings
    end

    local characterKey = GetCharacterKey()
    if type(settings.characterFood[characterKey]) ~= "table" then
        settings.characterFood[characterKey] = {}
    end

    return settings.characterFood[characterKey]
end

local function IsBlocked()
    if IsUnitInCombat and IsUnitInCombat("player") then
        return true
    end

    if IsUnitDeadOrReincarnating and IsUnitDeadOrReincarnating("player") then
        return true
    end

    return IsUnitDead and IsUnitDead("player")
end

local function IsFoodOrDrinkItem(bagId, slotId)
    if not GetItemType then
        return false
    end

    local itemType = GetItemType(bagId, slotId)
    return itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK
end

local function IsLibFoodDrinkBuffAvailable()
    local lib = LibFoodDrinkBuff or LIB_FOOD_DRINK_BUFF
    return lib
        and type(lib.IsAbilityAFoodBuff) == "function"
        and type(lib.IsAbilityADrinkBuff) == "function"
end

local function IsFoodOrDrinkBuffAbility(abilityId)
    if not abilityId or abilityId == 0 or not IsLibFoodDrinkBuffAvailable() then
        return false
    end

    local lib = LibFoodDrinkBuff or LIB_FOOD_DRINK_BUFF
    if lib:IsAbilityAFoodBuff(abilityId) == true then
        return true
    end

    return lib:IsAbilityADrinkBuff(abilityId) == true
end

local function GetActiveFoodBuff()
    if not GetNumBuffs or not GetUnitBuffInfo then
        return nil
    end

    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    local activeFoodBuff

    for buffIndex = 1, GetNumBuffs("player") do
        local buffName, _, timeEnding, _, _, _, _, _, _, _, abilityId =
            GetUnitBuffInfo("player", buffIndex)

        if IsFoodOrDrinkBuffAbility(abilityId) then
            local ending = timeEnding or 0
            if ending <= 0 or ending > now then
                if not activeFoodBuff or ending == 0 or ending > activeFoodBuff.timeEnding then
                    activeFoodBuff = {
                        name = buffName,
                        timeEnding = ending,
                        abilityId = abilityId,
                    }
                end
            end
        end
    end

    return activeFoodBuff
end

local function GetFoodBuffTimeEnding(activeFoodBuff)
    if not activeFoodBuff then
        return nil
    end

    if activeFoodBuff.timeEnding and activeFoodBuff.timeEnding > 0 then
        return activeFoodBuff.timeEnding
    end

    return nil
end

local function IsFoodBuffExpiring(activeFoodBuff)
    local timeEnding = GetFoodBuffTimeEnding(activeFoodBuff)
    if not timeEnding then
        return false
    end

    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    return timeEnding - now <= REFRESH_THRESHOLD_SECONDS
end

local function GetFrameTimeMs()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds() or 0
    end

    if GetFrameTimeSeconds then
        return (GetFrameTimeSeconds() or 0) * 1000
    end

    return 0
end

local function RememberActiveFoodBuff(activeFoodBuff)
    local timeEnding = GetFoodBuffTimeEnding(activeFoodBuff)
    if timeEnding then
        assumedFoodBuffEnding = timeEnding
    end
end

local function RememberRecentFoodUse()
    lastUseAtMilliseconds = GetFrameTimeMs()
end

local function SaveFoodItem(itemId, itemLink)
    if not itemId or itemId == 0 or not itemLink or itemLink == "" then
        return false
    end

    local foodSettings = GetFoodSettings()
    local hadSavedFood = foodSettings.currentFoodItemId ~= nil
        or (foodSettings.currentFoodItemLink ~= nil and foodSettings.currentFoodItemLink ~= "")
    local shouldAnnounceSave = not hadSavedFood
        or foodSettings.currentFoodItemId ~= itemId
        or foodSettings.currentFoodItemLink ~= itemLink

    foodSettings.currentFoodItemId = itemId
    foodSettings.currentFoodItemLink = itemLink

    if shouldAnnounceSave and Provisioning.GetLogFood() then
        Log(NQOL.L("features.provisioning.log_saved_food", itemLink))
    end

    if RefreshSavedFoodItemCount then
        RefreshSavedFoodItemCount()
    end

    return true
end

local function SaveCurrentFoodItem(bagId, slotId)
    if not GetItemId or not GetItemLink or not IsFoodOrDrinkItem(bagId, slotId) then
        return false
    end

    return SaveFoodItem(
        GetItemId(bagId, slotId),
        GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS)
    )
end

local function SaveFoodItemLink(itemLink)
    if not GetItemLinkItemId or not GetItemLinkItemType then
        return false
    end

    local itemType = GetItemLinkItemType(itemLink)
    if itemType ~= ITEMTYPE_FOOD and itemType ~= ITEMTYPE_DRINK then
        return false
    end

    return SaveFoodItem(GetItemLinkItemId(itemLink), itemLink)
end

local function RecordManualFoodUse(bagId, slotId, itemLink)
    if not Provisioning.GetAutoFood() then
        return false
    end

    if bagId ~= nil and slotId ~= nil then
        if SaveCurrentFoodItem(bagId, slotId) then
            RememberRecentFoodUse()
            return true
        end
    elseif itemLink and SaveFoodItemLink(itemLink) then
        RememberRecentFoodUse()
        return true
    end

    return false
end

local function GetQuickslotItemLink(slotNum, hotbarCategory)
    if hotbarCategory ~= HOTBAR_CATEGORY_QUICKSLOT_WHEEL or not GetSlotItemLink then
        return nil
    end

    local activeSlotNum = GetCurrentQuickslot and GetCurrentQuickslot() or slotNum
    local itemLink = GetSlotItemLink(activeSlotNum, hotbarCategory)
    if (not itemLink or itemLink == "") and activeSlotNum ~= slotNum then
        itemLink = GetSlotItemLink(slotNum, hotbarCategory)
    end

    return itemLink
end

local function InstallUseItemHook()
    if type(ZO_PreHookProtected) == "function" then
        ZO_PreHookProtected("UseItem", function(bagId, slotId)
            RecordManualFoodUse(bagId, slotId)
            return false
        end)
    end
end

local function InstallInventoryUseActionHook()
    if not SecurePostHook or type(ZO_InventorySlot_DiscoverSlotActionsFromActionList) ~= "function" then
        return
    end

    SecurePostHook(_G, "ZO_InventorySlot_DiscoverSlotActionsFromActionList", function(inventorySlot, slotActions)
        if not inventorySlot or not slotActions or not slotActions.m_slotActions or not ZO_Inventory_GetBagAndIndex then
            return
        end

        local bagId, slotId = ZO_Inventory_GetBagAndIndex(inventorySlot)
        if not IsFoodOrDrinkItem(bagId, slotId) then
            return
        end

        local primaryAction = slotActions.m_slotActions[1]
        if not primaryAction
            or primaryAction[INDEX_ACTION_NAME] ~= GetString(SI_ITEM_ACTION_USE)
            or type(primaryAction[INDEX_ACTION_CALLBACK]) ~= "function"
        then
            return
        end

        local originalCallback = primaryAction[INDEX_ACTION_CALLBACK]
        primaryAction[INDEX_ACTION_CALLBACK] = function(...)
            RecordManualFoodUse(bagId, slotId)
            return originalCallback(...)
        end
    end)
end

local function InstallManualUseHooks()
    if manualUseHooksInstalled then
        return
    end

    manualUseHooksInstalled = true

    InstallUseItemHook()
    InstallInventoryUseActionHook()

    if type(ZO_ActionBar_OnActionButtonUp) == "function" then
        originalActionBarOnActionButtonUp = ZO_ActionBar_OnActionButtonUp

        ZO_ActionBar_OnActionButtonUp = function(slotNum, hotbarCategory, ...)
            local itemLink = GetQuickslotItemLink(slotNum, hotbarCategory)

            local result = originalActionBarOnActionButtonUp(slotNum, hotbarCategory, ...)
            if itemLink and itemLink ~= "" then
                RecordManualFoodUse(nil, nil, itemLink)
            end

            return result
        end
    end
end

local function FindCurrentFoodSlot()
    local foodSettings = GetFoodSettings()
    if not foodSettings.currentFoodItemId or not GetBagSize or not GetItemId then
        return nil
    end

    local backpackSize = GetBagSize(BAG_BACKPACK)
    if not backpackSize then
        return nil
    end

    for slotId = 0, backpackSize - 1 do
        if IsFoodOrDrinkItem(BAG_BACKPACK, slotId)
            and GetItemId(BAG_BACKPACK, slotId) == foodSettings.currentFoodItemId
        then
            return slotId
        end
    end

    return nil
end

local function GetBackpackItemCount(itemId)
    if not itemId or itemId == 0 or not GetBagSize or not GetItemId or not GetItemInfo then
        return nil
    end

    local backpackSize = GetBagSize(BAG_BACKPACK)
    if not backpackSize then
        return nil
    end

    local count = 0
    for slotId = 0, backpackSize - 1 do
        if GetItemId(BAG_BACKPACK, slotId) == itemId then
            local _, stackCount = GetItemInfo(BAG_BACKPACK, slotId)
            count = count + (tonumber(stackCount) or 1)
        end
    end

    return count
end

RefreshSavedFoodItemCount = function()
    local foodSettings = GetFoodSettings()
    savedFoodItemCount = GetBackpackItemCount(foodSettings.currentFoodItemId)
end

local function CheckConsumedFoodStock(itemId, itemLink)
    if not Provisioning.GetCheckStock() then
        return
    end

    local count = GetBackpackItemCount(itemId)
    if count and count < STOCK_WARNING_THRESHOLD then
        Log(NQOL.L("features.provisioning.low_stock", itemLink or NQOL.L("features.provisioning.food"), tostring(count)))
    end
end

local function QueueStockCheck(itemId, itemLink)
    if not zo_callLater then
        CheckConsumedFoodStock(itemId, itemLink)
        return
    end

    zo_callLater(function()
        CheckConsumedFoodStock(itemId, itemLink)
    end, STOCK_CHECK_DELAY_MS)
end

local function QueueAutoUseVerification(itemId, itemLink, countBeforeUse, previousBuffEnding)
    if not zo_callLater then
        return
    end

    zo_callLater(function()
        if not Provisioning.GetAutoFood() then
            return
        end

        local activeFoodBuff = GetActiveFoodBuff()
        local countAfterUse = GetBackpackItemCount(itemId)
        if countBeforeUse and countAfterUse and countAfterUse < countBeforeUse then
            if activeFoodBuff then
                RememberActiveFoodBuff(activeFoodBuff)
            end
            if Provisioning.GetLogFood() then
                Log(NQOL.L("features.provisioning.refreshed_food", itemLink))
            end
            QueueStockCheck(itemId, itemLink)
            pendingRefresh = false
            savedFoodItemCount = countAfterUse
            return
        end

        if activeFoodBuff then
            local buffEnding = GetFoodBuffTimeEnding(activeFoodBuff)
            if not previousBuffEnding or buffEnding == 0 or (buffEnding and buffEnding > previousBuffEnding + 1) then
                RememberActiveFoodBuff(activeFoodBuff)
                if Provisioning.GetLogFood() then
                    Log(NQOL.L("features.provisioning.refreshed_food", itemLink))
                end
                QueueStockCheck(itemId, itemLink)
                pendingRefresh = false
                RefreshSavedFoodItemCount()
                return
            end
        end

        pendingRefresh = true
        QueueRetry(USE_COOLDOWN_MS)
    end, AUTO_USE_VERIFY_DELAY_MS)
end

local function QueueCheck()
    if checkQueued or not Provisioning.GetAutoFood() then
        return
    end

    checkQueued = true
    zo_callLater(function()
        checkQueued = false
        Provisioning.CheckAutoFood()
        QueueCheck()
    end, CHECK_INTERVAL_MS)
end

QueueRetry = function(delayMs)
    if retryQueued then
        return
    end

    retryQueued = true
    zo_callLater(function()
        retryQueued = false
        Provisioning.TryPending()
    end, delayMs or RETRY_DELAY_MS)
end

local function QueueEffectCheck()
    if effectCheckQueued or not Provisioning.GetAutoFood() then
        return
    end

    effectCheckQueued = true
    if zo_callLater then
        zo_callLater(function()
            effectCheckQueued = false
            Provisioning.CheckAutoFood()
        end, EFFECT_CHECK_DELAY_MS)
    else
        effectCheckQueued = false
        Provisioning.CheckAutoFood()
    end
end

local function UseBackpackItem(slotId)
    if IsItemUsable then
        local usable, usableOnlyFromActionSlot = IsItemUsable(BAG_BACKPACK, slotId)
        if not usable or usableOnlyFromActionSlot then
            return false
        end
    end

    if CanInteractWithItem then
        local canInteract = CanInteractWithItem(BAG_BACKPACK, slotId)
        if not canInteract then
            return false
        end
    end

    if CallSecureProtected then
        return CallSecureProtected("UseItem", BAG_BACKPACK, slotId) == true
    end

    if not UseItem then
        return false
    end

    UseItem(BAG_BACKPACK, slotId)
    return true
end

local function TryRefreshFood(activeFoodBuff)
    local foodSettings = GetFoodSettings()
    if not Provisioning.GetAutoFood() or not foodSettings.currentFoodItemId then
        return false
    end

    if IsBlocked() then
        pendingRefresh = true
        QueueRetry()
        return false
    end

    local now = GetFrameTimeMs()
    if lastUseAtMilliseconds and now > 0 and now - lastUseAtMilliseconds < USE_COOLDOWN_MS then
        return false
    end

    local slotId = FindCurrentFoodSlot()
    if not slotId then
        return false
    end

    if GetItemCooldownInfo then
        local remainingCooldown = GetItemCooldownInfo(BAG_BACKPACK, slotId)
        if remainingCooldown and remainingCooldown > 0 then
            pendingRefresh = true
            QueueRetry(remainingCooldown + 100)
            return false
        end
    end

    local itemLink = GetItemLink and GetItemLink(BAG_BACKPACK, slotId, LINK_STYLE_BRACKETS) or foodSettings.currentFoodItemLink
    if not itemLink or itemLink == "" then
        itemLink = foodSettings.currentFoodItemLink or "food"
    end

    local itemId = foodSettings.currentFoodItemId
    local countBeforeUse = GetBackpackItemCount(itemId)
    local succeeded, usedItem = pcall(UseBackpackItem, slotId)
    if not succeeded or not usedItem then
        pendingRefresh = true
        QueueRetry()
        return false
    end

    RememberRecentFoodUse()
    SaveCurrentFoodItem(BAG_BACKPACK, slotId)
    QueueAutoUseVerification(itemId, itemLink, countBeforeUse, GetFoodBuffTimeEnding(activeFoodBuff))
    return true
end

local function OnEffectChanged(_, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, _, abilityId)
    if unitTag ~= "player" then
        return
    end

    if changeType == EFFECT_RESULT_FADED and IsFoodOrDrinkBuffAbility(abilityId) then
        assumedFoodBuffEnding = 0
    end

    if changeType == EFFECT_RESULT_GAINED
        or changeType == EFFECT_RESULT_UPDATED
        or changeType == EFFECT_RESULT_FULL_REFRESH
        or changeType == EFFECT_RESULT_FADED
    then
        QueueEffectCheck()
    end
end

local function OnCombatState(_, inCombat)
    if not inCombat then
        Provisioning.TryPending()
    end
end

local function OnPlayerAlive()
    Provisioning.TryPending()
end

local function RegisterEvents()
    if eventsRegistered then
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Effects", EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE .. "_Effects",
        EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG,
        "player"
    )

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Combat", EVENT_PLAYER_COMBAT_STATE, OnCombatState)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Alive", EVENT_PLAYER_ALIVE, OnPlayerAlive)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "_Reincarnated", EVENT_PLAYER_REINCARNATED, OnPlayerAlive)
    eventsRegistered = true
end

local function UnregisterEvents()
    if not eventsRegistered then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Effects", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Combat", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Alive", EVENT_PLAYER_ALIVE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "_Reincarnated", EVENT_PLAYER_REINCARNATED)
    eventsRegistered = false
end

local function RefreshEvents()
    if Provisioning.GetAutoFood() then
        RegisterEvents()
        RefreshSavedFoodItemCount()
        QueueCheck()
    else
        UnregisterEvents()
    end
end

function Provisioning.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function Provisioning.Initialize()
    InstallManualUseHooks()
    RefreshEvents()

    for _, delayMs in ipairs(STARTUP_CHECK_DELAYS_MS) do
        zo_callLater(function()
            Provisioning.CheckAutoFood(false)
        end, delayMs)
    end
end

function Provisioning.CheckAutoFood(allowMissingRefresh)
    if not Provisioning.GetAutoFood() then
        return
    end

    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    local activeFoodBuff = GetActiveFoodBuff()
    if not activeFoodBuff then
        if assumedFoodBuffEnding > now then
            return
        end

        if allowMissingRefresh ~= false then
            TryRefreshFood()
        end

        return
    end

    RememberActiveFoodBuff(activeFoodBuff)
    if IsFoodBuffExpiring(activeFoodBuff) then
        TryRefreshFood(activeFoodBuff)
    end
end

function Provisioning.TryPending()
    if IsBlocked() then
        QueueRetry()
        return
    end

    if pendingRefresh then
        pendingRefresh = false
        Provisioning.CheckAutoFood()
    end
end

function Provisioning.GetAutoFood()
    if not savedVariables then
        return defaults.provisioning.autoFood
    end

    return GetSettings().autoFood
end

function Provisioning.SetAutoFood(value)
    GetSettings().autoFood = value == true
    RefreshEvents()

    if GetSettings().autoFood then
        Provisioning.CheckAutoFood()
    end
end

function Provisioning.GetLogFood()
    if not savedVariables then
        return defaults.provisioning.logFood
    end

    return GetSettings().logFood
end

function Provisioning.SetLogFood(value)
    GetSettings().logFood = value == true
end

function Provisioning.GetCheckStock()
    if not savedVariables then
        return defaults.provisioning.checkStock
    end

    return GetSettings().checkStock
end

function Provisioning.SetCheckStock(value)
    GetSettings().checkStock = value == true
end

function Provisioning.GetAutoFoodLabel()
    return NQOL.L("features.provisioning.auto_food_label")
end

function Provisioning.GetAutoFoodTooltip()
    return NQOL.L("features.provisioning.auto_food_tooltip")
end

function Provisioning.GetLogFoodLabel()
    return NQOL.L("features.provisioning.log_food_label")
end

function Provisioning.GetLogFoodTooltip()
    return NQOL.L("features.provisioning.log_food_tooltip")
end

function Provisioning.GetCheckStockLabel()
    return NQOL.L("features.provisioning.check_stock_label")
end

function Provisioning.GetCheckStockTooltip()
    return NQOL.L("features.provisioning.check_stock_tooltip")
end

function Provisioning.GetAutoFoodSavedFoodLabel()
    local foodSettings = GetFoodSettings()
    local itemLink = foodSettings.currentFoodItemLink

    if itemLink and itemLink ~= "" then
        return NQOL.L("features.provisioning.saved_food", itemLink)
    end

    return NQOL.L("features.provisioning.saved_food_none")
end

function Provisioning.HasAutoFoodSavedFood()
    local foodSettings = GetFoodSettings()
    return foodSettings.currentFoodItemId ~= nil
        or (foodSettings.currentFoodItemLink ~= nil and foodSettings.currentFoodItemLink ~= "")
end

function Provisioning.ClearAutoFoodSavedFood()
    local foodSettings = GetFoodSettings()
    foodSettings.currentFoodItemId = nil
    foodSettings.currentFoodItemLink = nil
    savedFoodItemCount = nil
    Log(NQOL.L("features.provisioning.cleared_food"))
end

function Provisioning.GetAutoFoodSavedFoodTooltip()
    return NQOL.L("features.provisioning.auto_food_saved_food_tooltip")
end

NQOL.Features.Provisioning = Provisioning
