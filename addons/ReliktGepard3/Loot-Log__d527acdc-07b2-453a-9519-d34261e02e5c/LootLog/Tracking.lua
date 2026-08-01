LootLog = LootLog or {}
local LL = LootLog

local function DebugValue(value)
    if value == nil then
        return "<nil>"
    end
    return tostring(value)
end

local function TryGetIndexedString(stringId, index)
    local numeric = tonumber(index)
    if type(GetString) ~= "function" or numeric == nil then
        return nil
    end

    local ok, value = pcall(GetString, stringId, numeric)
    if not ok or type(value) ~= "string" or value == "" then
        return nil
    end

    return value
end

local function FormatNumberWithName(value, displayName)
    local numeric = tonumber(value)
    if numeric == nil then
        return DebugValue(value)
    end

    if displayName then
        return string.format("%d (%s)", numeric, displayName)
    end

    return tostring(numeric)
end

local function FormatIndexedStringDebugValue(stringId, value)
    local numeric = tonumber(value)
    if numeric == nil then
        return DebugValue(value)
    end

    local displayName = TryGetIndexedString(stringId, numeric)
    return FormatNumberWithName(numeric, displayName)
end

local function FormatMappedDebugValue(value, valueNames)
    local numeric = tonumber(value)
    if numeric == nil then
        return DebugValue(value)
    end

    return FormatNumberWithName(numeric, valueNames and valueNames[numeric] or nil)
end

local function FormatCurrencyTypeDebugValue(value)
    local numeric = tonumber(value)
    if numeric == nil then
        return DebugValue(value)
    end

    if type(GetCurrencyName) == "function" then
        local ok, displayName = pcall(GetCurrencyName, numeric, true, false)
        if ok and type(displayName) == "string" and displayName ~= "" then
            return FormatNumberWithName(numeric, displayName)
        end
    end

    return FormatIndexedStringDebugValue("SI_CURRENCYTYPE", numeric)
end

local function FormatCurrencyChangeReasonDebugValue(value)
    return FormatMappedDebugValue(value, LL.CurrencyChangeReasonNames)
end

local function IsEventProbeEnabled()
    return LL.saved and LL.saved.settings and LL.saved.settings.eventProbe
end

local function IsVerboseProbeEnabled()
    return IsEventProbeEnabled() and LL.saved and LL.saved.settings and LL.saved.settings.debug
end

local function ProbePrint(message)
    if IsEventProbeEnabled() then
        LL.Print(string.format("[probe] %s", message))
    end
end

local function ProbeEventArgs(eventName, ...)
    if not IsEventProbeEnabled() then
        return
    end

    local argCount = select("#", ...)
    ProbePrint(string.format("event %s args=%d", tostring(eventName), argCount))
end

local function FormatLootTargetName(name, targetType)
    if type(name) ~= "string" or name == "" then
        return name
    end
    if type(zo_strformat) ~= "function" then
        return name
    end

    if targetType == INTERACT_TARGET_TYPE_ITEM and SI_TOOLTIP_ITEM_NAME ~= nil then
        return zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
    end
    if targetType == INTERACT_TARGET_TYPE_OBJECT and SI_LOOT_OBJECT_NAME ~= nil then
        return zo_strformat(SI_LOOT_OBJECT_NAME, name)
    end
    if targetType == INTERACT_TARGET_TYPE_FIXTURE and SI_TOOLTIP_FIXTURE_INSTANCE ~= nil then
        return zo_strformat(SI_TOOLTIP_FIXTURE_INSTANCE, name)
    end

    return name
end

local function ReadLootTarget()
    local targetName
    local targetType
    local nameFromFunction
    local typeFromFunction
    local infoName
    local infoTargetType
    local infoActionName
    local infoIsOwned

    if type(GetLootTargetName) == "function" then
        nameFromFunction = GetLootTargetName()
        targetName = nameFromFunction
    end
    if type(GetLootTargetType) == "function" then
        typeFromFunction = GetLootTargetType()
        targetType = typeFromFunction
    end

    if type(GetLootTargetInfo) == "function" then
        local name, parsedTargetType, actionName, isOwned = GetLootTargetInfo()
        infoName = name
        infoTargetType = parsedTargetType
        infoActionName = actionName
        infoIsOwned = isOwned

        if (not targetName or targetName == "") then
            targetName = infoName
        end
        if targetType == nil then
            targetType = infoTargetType
        end
    end

    targetName = FormatLootTargetName(targetName, targetType or infoTargetType)

    local meta = {
        nameFromFunction = nameFromFunction,
        typeFromFunction = typeFromFunction,
        infoName = infoName,
        infoTargetType = infoTargetType,
        infoActionName = infoActionName,
        infoIsOwned = infoIsOwned,
        resolvedName = targetName,
        resolvedType = targetType,
    }

    return LL.NormalizeDisplayName(targetName), targetType, meta
end

local function ProbeTargetSnapshot(eventName)
    if not IsEventProbeEnabled() then
        return
    end

    local targetName, targetType, meta = ReadLootTarget()
    ProbePrint(string.format(
        "target %s: name='%s' type=%s",
        tostring(eventName),
        DebugValue(meta and meta.resolvedName or targetName),
        DebugValue(meta and meta.resolvedType or targetType)
    ))

    if not IsVerboseProbeEnabled() then
        return
    end

    ProbePrint(string.format(
        "target_snapshot %s: resolvedName='%s' resolvedType=%s rawNameFn='%s' rawTypeFn=%s infoName='%s' infoTargetType=%s infoActionName='%s' infoIsOwned=%s",
        eventName,
        DebugValue(meta and meta.resolvedName or targetName),
        DebugValue(meta and meta.resolvedType or targetType),
        DebugValue(meta and meta.nameFromFunction),
        DebugValue(meta and meta.typeFromFunction),
        DebugValue(meta and meta.infoName),
        DebugValue(meta and meta.infoTargetType),
        DebugValue(meta and meta.infoActionName),
        DebugValue(meta and meta.infoIsOwned)
    ))
end

local function ReadInteractionContext()
    local interactionType
    local action
    local interactableName
    local additionalInfo
    local context = {}

    if type(GetInteractionType) == "function" then
        interactionType = GetInteractionType()
    end

    if type(GetGameCameraInteractableInfo) == "function" then
        action, interactableName, additionalInfo = GetGameCameraInteractableInfo()
        context.infoFunction = "GetGameCameraInteractableInfo"
    elseif type(GetGameCameraInteractableActionInfo) == "function" then
        action, interactableName, additionalInfo = GetGameCameraInteractableActionInfo()
        context.infoFunction = "GetGameCameraInteractableActionInfo"
    else
        context.infoFunction = "<none>"
    end

    context.interactionType = interactionType
    context.action = action
    context.interactableName = interactableName
    context.additionalInfo = additionalInfo

    return context
end

local function ProbeLootUpdatedContext(eventName)
    if not IsEventProbeEnabled() then
        return
    end

    local _, _, sourceMeta = ReadLootTarget()
    local interaction = ReadInteractionContext()

    ProbePrint(string.format(
        "target_live %s: resolvedName='%s' resolvedType=%s rawNameFn='%s' rawTypeFn=%s infoName='%s' infoTargetType=%s infoActionName='%s' infoIsOwned=%s interactionType=%s action='%s' interactable='%s' extra=%s via=%s",
        tostring(eventName),
        DebugValue(sourceMeta and sourceMeta.resolvedName),
        DebugValue(sourceMeta and sourceMeta.resolvedType),
        DebugValue(sourceMeta and sourceMeta.nameFromFunction),
        DebugValue(sourceMeta and sourceMeta.typeFromFunction),
        DebugValue(sourceMeta and sourceMeta.infoName),
        DebugValue(sourceMeta and sourceMeta.infoTargetType),
        DebugValue(sourceMeta and sourceMeta.infoActionName),
        DebugValue(sourceMeta and sourceMeta.infoIsOwned),
        DebugValue(interaction and interaction.interactionType),
        DebugValue(interaction and interaction.action),
        DebugValue(interaction and interaction.interactableName),
        DebugValue(interaction and interaction.additionalInfo),
        DebugValue(interaction and interaction.infoFunction)
    ))
end

local function ShouldTrackLoot(selfLoot)
    if not selfLoot then
        return false
    end
    return true
end

local function TrackItem(itemName, quantity)
    LL.Increment(LL.session.items, itemName, quantity)
    LL.Increment(LL.saved.manual.items, itemName, quantity)
    LL.Increment(LL.saved.lifetime.items, itemName, quantity)
    LL.RefreshUI()
end

local function ProbeLootReceivedSummary(itemName, quantity, lootType, selfLoot, isPickpocketLoot, isStolen, sourceMeta)
    if not IsEventProbeEnabled() then
        return
    end

    local interaction = ReadInteractionContext()

    ProbePrint(string.format(
        "loot_received item='%s' qty=%s lootType=%s self=%s pickpocket=%s stolen=%s target='%s' targetType=%s interactionType=%s action='%s' interactable='%s' extra=%s via=%s",
        DebugValue(itemName),
        DebugValue(quantity),
        DebugValue(lootType),
        DebugValue(selfLoot),
        DebugValue(isPickpocketLoot),
        DebugValue(isStolen),
        DebugValue(sourceMeta and sourceMeta.resolvedName),
        DebugValue(sourceMeta and sourceMeta.resolvedType),
        DebugValue(interaction and interaction.interactionType),
        DebugValue(interaction and interaction.action),
        DebugValue(interaction and interaction.interactableName),
        DebugValue(interaction and interaction.additionalInfo),
        DebugValue(interaction and interaction.infoFunction)
    ))
end

local function BeginLootInteraction()
    if LL.lootInteractionOpen then
        return
    end
    LL.lootInteractionOpen = true
    LL.currentInteractionHasLoot = false
end

local function EndLootInteraction()
    LL.lootInteractionOpen = false
    LL.currentInteractionHasLoot = false
end

local function TrackInteractionInstance()
    LL.Increment(LL.session.instances, "Total", 1)
    LL.Increment(LL.saved.manual.instances, "Total", 1)
    LL.Increment(LL.saved.lifetime.instances, "Total", 1)
    LL.RefreshUI()
end

local function IsTrackedCurrencyReason(reason)
    local numeric = tonumber(reason)
    if numeric == nil then
        return false
    end
    return LL.TrackedCurrencyChangeReasons and LL.TrackedCurrencyChangeReasons[numeric] == true
end

local function IsIgnoredCurrencyReason(reason)
    local numeric = tonumber(reason)
    if numeric == nil then
        return false
    end
    return LL.IgnoredCurrencyChangeReasons and LL.IgnoredCurrencyChangeReasons[numeric] == true
end

local function TrackCurrencyByReason(bucket, reason, currencyType, amount)
    if type(bucket) ~= "table" then
        return
    end

    local numericReason = tonumber(reason)
    local numericCurrencyType = tonumber(currencyType)
    local numericAmount = tonumber(amount)
    if numericReason == nil or numericCurrencyType == nil or numericAmount == nil or numericAmount <= 0 then
        return
    end

    bucket.currencyByReason = bucket.currencyByReason or {}
    if not bucket.currencyStartedAt or tonumber(bucket.currencyStartedAt) == nil or tonumber(bucket.currencyStartedAt) <= 0 then
        bucket.currencyStartedAt = LL.GetCurrentTimestamp()
    end
    bucket.currencyByReason[numericReason] = bucket.currencyByReason[numericReason] or {}
    LL.Increment(bucket.currencyByReason[numericReason], numericCurrencyType, numericAmount)
end

function LL.OnLootReceived(...)
    ProbeEventArgs("EVENT_LOOT_RECEIVED", ...)

    -- EVENT_LOOT_RECEIVED payload (known fields used here):
    -- 3=itemName, 4=quantity, 6=lootType, 7=selfLoot, 8=isPickpocketLoot, 11=isStolen
    local _, _, itemName, quantity, _, lootType, selfLoot, isPickpocketLoot, _, _, isStolen = ...
    if LOOT_TYPE_ITEM ~= nil and lootType ~= LOOT_TYPE_ITEM then
        return
    end

    if selfLoot == nil then
        selfLoot = true
    end

    local _, _, sourceMeta = ReadLootTarget()
    ProbeLootReceivedSummary(itemName, quantity, lootType, selfLoot, isPickpocketLoot, isStolen, sourceMeta)

    local shouldTrack = ShouldTrackLoot(selfLoot)
    if not shouldTrack then
        return
    end

    local normalizedItemName = LL.NormalizeDisplayName(itemName)
    local normalizedQuantity = tonumber(quantity) or 1
    if normalizedQuantity < 1 then
        normalizedQuantity = 1
    end

    if not normalizedItemName then
        LL.DebugPrint("skip_empty_item_name")
        return
    end

    BeginLootInteraction()
    LL.currentInteractionHasLoot = true
    TrackItem(normalizedItemName, normalizedQuantity)
    LL.DebugPrint(string.format(
        "loot_recorded item='%s' qty=%d pickpocket=%s stolen=%s target='%s' targetType=%s",
        tostring(normalizedItemName),
        normalizedQuantity,
        tostring(isPickpocketLoot),
        tostring(isStolen),
        DebugValue(sourceMeta and sourceMeta.resolvedName),
        DebugValue(sourceMeta and sourceMeta.resolvedType)
    ))
end

function LL.OnLootClosed(...)
    ProbeEventArgs("EVENT_LOOT_CLOSED", ...)
    ProbePrint(string.format(
        "loot_closed state: open=%s hasLoot=%s",
        tostring(LL.lootInteractionOpen),
        tostring(LL.currentInteractionHasLoot)
    ))
    if LL.lootInteractionOpen and LL.currentInteractionHasLoot then
        TrackInteractionInstance()
        LL.DebugPrint("recorded_loot_interaction")
    end
    EndLootInteraction()
end

-- Probe-only handlers. These are intentionally not used for tracking logic.
function LL.OnLootUpdated(...)
    ProbeEventArgs("EVENT_LOOT_UPDATED", ...)
    ProbeTargetSnapshot("EVENT_LOOT_UPDATED")
    ProbeLootUpdatedContext("EVENT_LOOT_UPDATED")
end

function LL.OnLootTargetUpdated(...)
    ProbeEventArgs("EVENT_LOOT_TARGET_UPDATED", ...)
    ProbeTargetSnapshot("EVENT_LOOT_TARGET_UPDATED")
end

function LL.OnLootItemFailed(...)
    ProbeEventArgs("EVENT_LOOT_ITEM_FAILED", ...)
    ProbeTargetSnapshot("EVENT_LOOT_ITEM_FAILED")
end

function LL.OnPlayerDead(...)
    ProbeEventArgs("EVENT_PLAYER_DEAD", ...)
end

function LL.OnInventorySingleSlotUpdate(...)
    ProbeEventArgs("EVENT_INVENTORY_SINGLE_SLOT_UPDATE", ...)
end

function LL.OnInventoryFullUpdate(...)
    ProbeEventArgs("EVENT_INVENTORY_FULL_UPDATE", ...)
end

function LL.OnCurrencyUpdate(...)
    local _, currencyType, currencyLocation, newAmount, oldAmount, reason, reasonInfo = ...
    if IsIgnoredCurrencyReason(reason) then
        return
    end

    ProbeEventArgs("EVENT_CURRENCY_UPDATE", ...)

    local numericNewAmount = tonumber(newAmount) or 0
    local numericOldAmount = tonumber(oldAmount) or 0
    local delta = numericNewAmount - numericOldAmount
    local trackedReason = IsTrackedCurrencyReason(reason)
    local trackedDelta = delta > 0
    local willTrack = trackedReason and trackedDelta

    LL.DebugPrint(string.format(
        "currency_decision type=%s delta=%s reason=%s trackedReason=%s trackedDelta=%s willTrack=%s reasonInfo=%s",
        FormatCurrencyTypeDebugValue(currencyType),
        DebugValue(delta),
        FormatCurrencyChangeReasonDebugValue(reason),
        tostring(trackedReason),
        tostring(trackedDelta),
        tostring(willTrack),
        DebugValue(reasonInfo)
    ))

    if willTrack then
        TrackCurrencyByReason(LL.session, reason, currencyType, delta)
        TrackCurrencyByReason(LL.saved.manual, reason, currencyType, delta)
        TrackCurrencyByReason(LL.saved.lifetime, reason, currencyType, delta)
        LL.RefreshUI()
    end

    if not IsEventProbeEnabled() then
        return
    end

    ProbePrint(string.format(
        "currency_update type=%s location=%s new=%s old=%s delta=%s reason=%s reasonInfo=%s",
        FormatCurrencyTypeDebugValue(currencyType),
        FormatIndexedStringDebugValue("SI_CURRENCYLOCATION", currencyLocation),
        DebugValue(newAmount),
        DebugValue(oldAmount),
        DebugValue(delta),
        FormatCurrencyChangeReasonDebugValue(reason),
        DebugValue(reasonInfo)
    ))
end

function LL.OnPendingCurrencyRewardCached(...)
    ProbeEventArgs("EVENT_PENDING_CURRENCY_REWARD_CACHED", ...)

    if not IsEventProbeEnabled() then
        return
    end

    ProbePrint(string.format(
        "pending_currency_reward_cached args=%d",
        select("#", ...)
    ))
end
