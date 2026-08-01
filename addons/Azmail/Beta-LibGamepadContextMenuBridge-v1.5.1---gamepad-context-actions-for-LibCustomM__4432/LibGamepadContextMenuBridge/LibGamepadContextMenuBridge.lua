local MAJOR = "LibGamepadContextMenuBridge"
local MINOR = 151
local ADDON_VERSION = "1.5.1"

local existing = _G[MAJOR]
if existing and existing.minor and existing.minor >= MINOR then
    return
end

local bridge = existing or {}
_G[MAJOR] = bridge

bridge.major = MAJOR
bridge.minor = MINOR
bridge.enabled = true
bridge.debug = bridge.debug or false
bridge._initialized = false
bridge._registerWrapped = false
bridge._discoverHooked = false
bridge._refreshHooked = false
bridge._contextCallbacks = bridge._contextCallbacks or {}
bridge._callbackKeys = bridge._callbackKeys or {}
bridge._submenuDialogRegistered = bridge._submenuDialogRegistered or false
bridge._submenuDialogName = bridge._submenuDialogName or (MAJOR .. "_SubmenuDialog")
bridge._settingsPanelRegistered = bridge._settingsPanelRegistered or false
bridge._slashCommandsRegistered = bridge._slashCommandsRegistered or false
bridge._tooltipPriceHooked = bridge._tooltipPriceHooked or false
bridge._tradingHouseTooltipHooked = bridge._tradingHouseTooltipHooked or false
bridge._playerActivatedHookRegistered = bridge._playerActivatedHookRegistered or false
bridge._debugLog = bridge._debugLog or {}
bridge._stringIdByLabel = bridge._stringIdByLabel or {}
bridge._nextStringIdIndex = bridge._nextStringIdIndex or 1
bridge._tooltipTtcCache = bridge._tooltipTtcCache or {}
bridge._formattedTooltipLineCache = bridge._formattedTooltipLineCache or {}
bridge._tooltipTtcCacheSize = bridge._tooltipTtcCacheSize or 0
bridge._formattedTooltipLineCacheSize = bridge._formattedTooltipLineCacheSize or 0
bridge._overlayWindow = bridge._overlayWindow or nil
bridge._craftingStationActive = bridge._craftingStationActive or false
bridge._templateCraftingOverlayActive = bridge._templateCraftingOverlayActive or false

local SAVED_VARS_NAME = MAJOR .. "_SavedVars"
local SAVED_VARS_VERSION = 1
local DEFAULTS = {
    enabled = true,
    debug = false,
    debugVerbose = false,
    debugToChat = true,
    debugStoreHistory = true,
    maxDebugMessages = 200,
    debugLog = {},
    showTtcPriceInTooltip = true,
    showTtcPriceDetailsInTooltip = false,
    showJunkStatusInTooltip = true,
    showVendorPriceInTooltip = true,
}

local unpackArgs = unpack or table.unpack

local function TrimString(value)
    if type(value) ~= "string" then
        return ""
    end
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function GetDebugTimestamp()
    if type(GetTimeStamp) == "function" then
        local ok, ts = pcall(GetTimeStamp)
        if ok and ts then
            return tostring(ts)
        end
    end
    return tostring(math.floor((GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0) / 1000))
end

function bridge:_addDebugHistory(message)
    if type(message) ~= "string" or message == "" then
        return
    end

    local entry = string.format("%s %s", GetDebugTimestamp(), message)
    self._debugLog[#self._debugLog + 1] = entry

    -- Also persist to SavedVars so the log survives /reloadui and is written to disk.
    if self.savedVars then
        if type(self.savedVars.debugLog) ~= "table" then
            self.savedVars.debugLog = {}
        end
        local sv = self.savedVars.debugLog
        sv[#sv + 1] = entry
        -- Keep SavedVars log bounded (max 500 lines to avoid giant file).
        local svLimit = 500
        while #sv > svLimit do
            table.remove(sv, 1)
        end
    end

    local limit = DEFAULTS.maxDebugMessages
    if self.savedVars and tonumber(self.savedVars.maxDebugMessages) then
        limit = math.max(20, tonumber(self.savedVars.maxDebugMessages))
    end

    while #self._debugLog > limit do
        table.remove(self._debugLog, 1)
    end
end

function bridge:_debugMessage(message, verboseOnly)
    if not self.debug then
        return
    end

    if verboseOnly and not self.debugVerbose then
        return
    end

    local formatted = string.format("[%s] %s", MAJOR, tostring(message))

    if not self.savedVars or self.savedVars.debugStoreHistory ~= false then
        self:_addDebugHistory(formatted)
    end

    if (not self.savedVars or self.savedVars.debugToChat ~= false) and type(d) == "function" then
        d(formatted)
    end
end

local function LogDebug(message)
    bridge:_debugMessage(message, false)
end

local function LogTrace(message)
    bridge:_debugMessage(message, true)
end

local function SafeCallCallback(callback)
    if type(callback) ~= "function" then
        return
    end

    local ok = pcall(callback)
    if ok then
        return
    end

    pcall(callback, nil)
end

local function SafeCallCallbackWithContext(callback, contextControl)
    if type(callback) ~= "function" then
        return
    end

    local ok = pcall(callback, contextControl)
    if ok then
        return
    end

    SafeCallCallback(callback)
end

local function EvaluateValue(value, ...)
    if type(value) ~= "function" then
        return value
    end

    local ok, result = pcall(value, ...)
    if ok then
        return result
    end

    ok, result = pcall(value)
    if ok then
        return result
    end

    return nil
end

local function SafeGetString(stringId, fallback)
    if type(GetString) == "function" and stringId ~= nil then
        local ok, value = pcall(GetString, stringId)
        if ok and type(value) == "string" and value ~= "" then
            return value
        end
    end

    return fallback or ""
end

local function SafeGetTargetData(entryList)
    if not entryList or type(entryList.GetTargetData) ~= "function" then
        return nil
    end

    local ok, data = pcall(entryList.GetTargetData, entryList)
    if ok then
        return data
    end

    ok, data = pcall(entryList.GetTargetData)
    if ok then
        return data
    end

    return nil
end

local function SafeGetTargetControl(entryList)
    if not entryList then
        return nil
    end

    if type(entryList.GetTargetControl) == "function" then
        local ok, control = pcall(entryList.GetTargetControl, entryList)
        if ok and control then
            return control
        end

        ok, control = pcall(entryList.GetTargetControl)
        if ok and control then
            return control
        end
    end

    if type(entryList.GetSelectedControl) == "function" then
        local ok, control = pcall(entryList.GetSelectedControl, entryList)
        if ok and control then
            return control
        end

        ok, control = pcall(entryList.GetSelectedControl)
        if ok and control then
            return control
        end
    end

    return nil
end

local function IsValidItemLink(link)
    return type(link) == "string" and link:find("|H") ~= nil
end

function bridge:_extractItemLinkFromData(data)
    if type(data) ~= "table" then
        return nil
    end

    local directKeys = {
        "itemLink",
        "resultItemLink",
        "previewItemLink",
        "recipeResultItemLink",
        "furnishingItemLink",
        "craftedItemLink",
        "link",
    }

    for i = 1, #directKeys do
        local value = data[directKeys[i]]
        if IsValidItemLink(value) then
            return value
        end
    end

    local nestedKeys = {
        "itemData",
        "resultData",
        "recipeData",
        "selectedData",
        "entryData",
        "data",
        "recipe",
    }

    for i = 1, #nestedKeys do
        local nested = data[nestedKeys[i]]
        if type(nested) == "table" then
            local nestedLink = self:_extractItemLinkFromData(nested)
            if IsValidItemLink(nestedLink) then
                return nestedLink
            end
        end
    end

    if type(GetRecipeResultItemLink) == "function" then
        local recipeListIndex = data.recipeListIndex or data.selectedRecipeListIndex or data.listIndex
        local recipeIndex = data.recipeIndex or data.selectedRecipeIndex or data.index
        if recipeListIndex ~= nil and recipeIndex ~= nil then
            local ok, recipeLink = pcall(GetRecipeResultItemLink, recipeListIndex, recipeIndex)
            if ok and IsValidItemLink(recipeLink) then
                return recipeLink
            end
        end
    end

    if type(GetSmithingPatternResultLink) == "function" then
        local patternIndex = data.patternIndex
        local materialIndex = data.materialIndex
        local materialQuantity = data.materialQuantity
        local styleIndex = data.styleIndex
        local traitIndex = data.traitIndex
        if patternIndex ~= nil and materialIndex ~= nil then
            local ok, patternLink = pcall(GetSmithingPatternResultLink, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
            if ok and IsValidItemLink(patternLink) then
                return patternLink
            end
        end
    end

    return nil
end

function bridge:_resolveCurrentFurnishingLink(sourceObject)
    if IsValidItemLink(self._pendingCraftingLink) then
        return self._pendingCraftingLink
    end

    local methodNames = {
        "GetCurrentResultItemLink",
        "GetResultItemLink",
        "GetCurrentResultLink",
        "GetCurrentFurnishingResultItemLink",
        "GetFurnishingResultItemLink",
        "GetCurrentFurnishingLink",
        "GetSelectedRecipeResultItemLink",
        "GetSelectedFurnishingRecipeResultItemLink",
    }

    local methodTargets = {
        sourceObject,
        sourceObject and sourceObject.resultTooltip,
        ZO_GamepadSmithingCreation,
        ZO_SmithingCreation,
        SMITHING,
        GAMEPAD_SMITHING_CREATION,
    }

    for targetIndex = 1, #methodTargets do
        local target = methodTargets[targetIndex]
        if type(target) == "table" then
            for methodIndex = 1, #methodNames do
                local methodName = methodNames[methodIndex]
                local method = target[methodName]
                if type(method) == "function" then
                    local ok, link = pcall(method, target)
                    if ok and IsValidItemLink(link) then
                        return link
                    end

                    ok, link = pcall(method)
                    if ok and IsValidItemLink(link) then
                        return link
                    end
                end
            end
        end
    end

    local listTargets = {
        sourceObject and sourceObject.itemList,
        sourceObject and sourceObject.list,
        sourceObject and sourceObject.parametricList,
        sourceObject and sourceObject.recipeList,
        sourceObject and sourceObject.patternList,
        ZO_GamepadSmithingCreation and ZO_GamepadSmithingCreation.itemList,
        ZO_GamepadSmithingCreation and ZO_GamepadSmithingCreation.list,
        ZO_GamepadSmithingCreation and ZO_GamepadSmithingCreation.parametricList,
        ZO_GamepadSmithingCreation and ZO_GamepadSmithingCreation.recipeList,
        ZO_GamepadSmithingCreation and ZO_GamepadSmithingCreation.patternList,
    }

    for i = 1, #listTargets do
        local selectedData = SafeGetTargetData(listTargets[i])
        local link = self:_extractItemLinkFromData(selectedData)
        if IsValidItemLink(link) then
            return link
        end
    end

    return nil
end

local function MergeCraftContextField(dst, src, key)
    if dst[key] == nil and src[key] ~= nil then
        dst[key] = src[key]
    end
end

function bridge:_extractCraftContextFromData(data)
    if type(data) ~= "table" then
        return nil
    end

    local context = {
        selectedData = data,
    }

    local recipeData = type(data.recipeData) == "table" and data.recipeData or nil

    context.recipeListIndex = data.recipeListIndex
        or data.selectedRecipeListIndex
        or (recipeData and recipeData.recipeListIndex)
        or data.listIndex
    context.recipeIndex = data.recipeIndex
        or data.selectedRecipeIndex
        or (recipeData and recipeData.recipeIndex)
        or data.index

    context.patternIndex = data.patternIndex
    context.materialIndex = data.materialIndex
    context.materialQuantity = data.materialQuantity
    context.styleIndex = data.styleIndex
    context.traitIndex = data.traitIndex

    return context
end

function bridge:_resolveCurrentFurnishingCraftContext(sourceObject, baseContext)
    local context = {}

    if type(baseContext) == "table" then
        for key, value in pairs(baseContext) do
            context[key] = value
        end
    end

    local listTargets = {
        sourceObject and sourceObject.itemList,
        sourceObject and sourceObject.list,
        sourceObject and sourceObject.parametricList,
        sourceObject and sourceObject.recipeList,
        sourceObject and sourceObject.patternList,
        sourceObject and sourceObject.categoryList and sourceObject.categoryList.list,
        ZO_GamepadSmithingCreation and ZO_GamepadSmithingCreation.itemList,
        ZO_GamepadSmithingCreation and ZO_GamepadSmithingCreation.list,
        ZO_GamepadSmithingCreation and ZO_GamepadSmithingCreation.parametricList,
        ZO_GamepadSmithingCreation and ZO_GamepadSmithingCreation.recipeList,
        ZO_GamepadSmithingCreation and ZO_GamepadSmithingCreation.patternList,
        ZO_GamepadSmithingCreation and ZO_GamepadSmithingCreation.categoryList and ZO_GamepadSmithingCreation.categoryList.list,
    }

    for i = 1, #listTargets do
        local selectedData = SafeGetTargetData(listTargets[i])
        if type(selectedData) == "table" then
            local extracted = self:_extractCraftContextFromData(selectedData)
            if type(extracted) == "table" then
                MergeCraftContextField(context, extracted, "recipeListIndex")
                MergeCraftContextField(context, extracted, "recipeIndex")
                MergeCraftContextField(context, extracted, "patternIndex")
                MergeCraftContextField(context, extracted, "materialIndex")
                MergeCraftContextField(context, extracted, "materialQuantity")
                MergeCraftContextField(context, extracted, "styleIndex")
                MergeCraftContextField(context, extracted, "traitIndex")
                if type(extracted.selectedData) == "table" then
                    context.selectedData = extracted.selectedData
                end
            end
        end
    end

    if context.recipeListIndex == nil and type(sourceObject) == "table" and type(sourceObject.GetRecipeData) == "function" then
        local ok, recipeData = pcall(sourceObject.GetRecipeData, sourceObject)
        if ok and type(recipeData) == "table" then
            context.recipeListIndex = recipeData.recipeListIndex or context.recipeListIndex
            context.recipeIndex = recipeData.recipeIndex or context.recipeIndex
            if type(context.selectedData) ~= "table" then
                context.selectedData = recipeData
            end
        end
    end

    return context
end

function bridge:_makeCraftContext(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
    return {
        patternIndex = patternIndex,
        materialIndex = materialIndex,
        materialQuantity = materialQuantity,
        styleIndex = styleIndex,
        traitIndex = traitIndex,
    }
end

function bridge:_resolveSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
    if type(GetSmithingPatternResultLink) ~= "function" then
        return nil
    end

    local ok, link = pcall(GetSmithingPatternResultLink, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
    if ok and IsValidItemLink(link) then
        return link
    end

    return nil
end

function bridge:_makeRecipeCraftContext(recipeListIndex, recipeIndex, selectedData)
    local context = {
        recipeListIndex = recipeListIndex,
        recipeIndex = recipeIndex,
    }
    if type(selectedData) == "table" then
        context.selectedData = selectedData
    end
    return context
end

local function ResolveCategory(lcm, category)
    local early = lcm and tonumber(lcm.CATEGORY_EARLY) or nil
    local late = lcm and tonumber(lcm.CATEGORY_LATE) or nil

    category = tonumber(category) or late or early

    if category == nil then
        return nil
    end

    if early == nil or late == nil then
        return category
    end

    if type(zo_clamp) == "function" then
        return zo_clamp(category, early, late)
    end

    if category < early then
        return early
    end

    if category > late then
        return late
    end

    return category
end

local function ResolveLabel(value, contextControl)
    value = EvaluateValue(value, ZO_Menu, contextControl)

    if value == nil then
        return nil
    end

    if type(value) == "number" and type(GetString) == "function" then
        local ok, localized = pcall(GetString, value)
        if ok and type(localized) == "string" and localized ~= "" then
            return localized
        end
    end

    if type(value) ~= "string" then
        value = tostring(value)
    end

    if value == "" then
        return nil
    end

    return value
end

local function IsDividerLabel(label)
    if not label then
        return true
    end

    if label == "-" then
        return true
    end

    if type(LibCustomMenu) == "table" and label == LibCustomMenu.DIVIDER then
        return true
    end

    return false
end

local function BuildCallbackKey(func, category, args)
    local key = tostring(func) .. "|" .. tostring(category)
    if args and #args > 0 then
        for i = 1, #args do
            key = key .. "|" .. tostring(args[i])
        end
    end
    return key
end

local function ReadActionName(entry)
    if type(entry) ~= "table" then
        return nil
    end

    local actionName = entry.name or entry.actionName or entry[1]

    if type(actionName) == "number" and type(GetString) == "function" then
        local ok, localized = pcall(GetString, actionName)
        if ok and type(localized) == "string" then
            actionName = localized
        end
    end

    if type(actionName) ~= "string" or actionName == "" then
        return nil
    end

    return actionName
end

local function CollectExistingActionNames(slotActions)
    local names = {}

    local candidates = {
        slotActions and slotActions.m_slotActions,
        slotActions and slotActions.m_actionList,
        slotActions and slotActions.actionList,
        slotActions and slotActions.m_actions,
    }

    for i = 1, #candidates do
        local list = candidates[i]
        if type(list) == "table" then
            for index = 1, #list do
                local name = ReadActionName(list[index])
                if name then
                    names[name] = true
                end
            end
        end
    end

    return names
end

local function StampActionLabel(slotActions, label, callback)
    if type(slotActions) ~= "table" or type(label) ~= "string" or label == "" or type(callback) ~= "function" then
        return
    end

    local candidates = {
        slotActions.m_slotActions,
        slotActions.m_actionList,
        slotActions.actionList,
        slotActions.m_actions,
    }

    for i = 1, #candidates do
        local list = candidates[i]
        if type(list) == "table" then
            for index = #list, 1, -1 do
                local actionEntry = list[index]
                if type(actionEntry) == "table" then
                    local entryCallback = actionEntry.callback or actionEntry.actionCallback or actionEntry[2]
                    if entryCallback == callback then
                        actionEntry.name = actionEntry.name or label
                        actionEntry.actionName = actionEntry.actionName or label
                        if actionEntry[1] == nil then
                            actionEntry[1] = label
                        end
                        return
                    end
                end
            end
        end
    end
end

function bridge:_ensureActionStringId(label)
    if type(label) ~= "string" or label == "" then
        return label
    end

    local existingId = self._stringIdByLabel[label]
    if existingId ~= nil then
        return existingId
    end

    if type(ZO_CreateStringId) ~= "function" then
        return label
    end

    local idName = string.format("SI_LGCMB_ACTION_%d", tonumber(self._nextStringIdIndex or 1))
    self._nextStringIdIndex = (self._nextStringIdIndex or 1) + 1
    pcall(ZO_CreateStringId, idName, label)

    local createdId = _G[idName]
    if createdId == nil then
        createdId = label
    end

    self._stringIdByLabel[label] = createdId
    return createdId
end

function bridge:_readContextMenuRegistry()
    local lcm = LibCustomMenu
    if type(lcm) ~= "table" then
        return nil, "LibCustomMenu missing"
    end

    local registry = lcm.contextMenuRegistry
    if type(registry) ~= "table" then
        return nil, "contextMenuRegistry missing"
    end

    local callbackRegistry = registry.callbackRegistry or registry.m_callbackRegistry
    if type(callbackRegistry) ~= "table" then
        return nil, "callback registry missing"
    end

    return callbackRegistry, nil
end

function bridge:_summarizeContextRegistry()
    local callbackRegistry, err = self:_readContextMenuRegistry()
    if not callbackRegistry then
        return err or "unavailable", 0
    end

    local early = LibCustomMenu and tonumber(LibCustomMenu.CATEGORY_EARLY) or nil
    local late = LibCustomMenu and tonumber(LibCustomMenu.CATEGORY_LATE) or nil
    if early == nil or late == nil then
        return "category bounds unavailable", 0
    end
    local parts = {}
    local total = 0
    for category = early, late do
        local handlers = callbackRegistry[category]
        local count = type(handlers) == "table" and #handlers or 0
        total = total + count
        parts[#parts + 1] = string.format("%d=%d", category, count)
    end

    return table.concat(parts, ", "), total
end

function bridge:_invokeRawRegistryHandlers(lcm, inventorySlot, slotActions)
    local callbackRegistry, err = self:_readContextMenuRegistry()
    if not callbackRegistry then
        LogTrace("Raw registry fallback unavailable: " .. tostring(err))
        return 0
    end

    local early = tonumber(lcm.CATEGORY_EARLY)
    local late = tonumber(lcm.CATEGORY_LATE)
    if early == nil or late == nil then
        return 0
    end
    local invoked = 0

    for category = early, late do
        local handlers = callbackRegistry[category]
        if type(handlers) == "table" then
            for i = 1, #handlers do
                local entry = handlers[i]
                local callback = nil
                local args = nil

                if type(entry) == "function" then
                    callback = entry
                elseif type(entry) == "table" then
                    callback = entry.callback or entry.func or entry[1]
                    if type(entry.args) == "table" then
                        args = entry.args
                    end
                end

                if type(callback) == "function" then
                    local ok, callbackErr
                    if args and #args > 0 then
                        local callArgs = {}
                        for argIndex = 1, #args do
                            callArgs[#callArgs + 1] = args[argIndex]
                        end
                        callArgs[#callArgs + 1] = inventorySlot
                        callArgs[#callArgs + 1] = slotActions
                        ok, callbackErr = pcall(callback, unpackArgs(callArgs))
                    else
                        ok, callbackErr = pcall(callback, inventorySlot, slotActions)
                    end

                    invoked = invoked + 1
                    if not ok then
                        LogTrace(string.format("Raw handler error in category %s: %s", tostring(category), tostring(callbackErr)))
                    end
                end
            end
        end
    end

    return invoked
end

function bridge:_resolveNormalizedSlotType(inventorySlot, slotType)
    if slotType == SLOT_TYPE_ITEM or slotType == SLOT_TYPE_BANK_ITEM or slotType == SLOT_TYPE_GUILD_BANK_ITEM then
        return slotType
    end

    if type(ZO_Inventory_GetBagAndIndex) ~= "function" then
        return slotType
    end

    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    if bagId == nil or slotIndex == nil then
        return slotType
    end

    if type(BAG_BACKPACK) == "number" and bagId == BAG_BACKPACK and SLOT_TYPE_ITEM ~= nil then
        return SLOT_TYPE_ITEM
    end

    if type(BAG_BANK) == "number" and bagId == BAG_BANK and SLOT_TYPE_BANK_ITEM ~= nil then
        return SLOT_TYPE_BANK_ITEM
    end

    if type(BAG_SUBSCRIBER_BANK) == "number" and bagId == BAG_SUBSCRIBER_BANK and SLOT_TYPE_BANK_ITEM ~= nil then
        return SLOT_TYPE_BANK_ITEM
    end

    if type(BAG_GUILDBANK) == "number" and bagId == BAG_GUILDBANK and SLOT_TYPE_GUILD_BANK_ITEM ~= nil then
        return SLOT_TYPE_GUILD_BANK_ITEM
    end

    return slotType
end

function bridge:_resolveBagAndSlot(inventorySlot)
    if type(inventorySlot) == "table" then
        local bagId = inventorySlot.bagId or inventorySlot.bag
        local slotIndex = inventorySlot.slotIndex or inventorySlot.slot
        if bagId ~= nil and slotIndex ~= nil then
            return bagId, slotIndex
        end
    end

    if type(ZO_Inventory_GetBagAndIndex) ~= "function" then
        return nil, nil
    end

    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    if bagId == nil or slotIndex == nil then
        return nil, nil
    end

    return bagId, slotIndex
end

function bridge:_buildNativeJunkAction(inventorySlot)
    if type(SetItemIsJunk) ~= "function" or type(IsItemJunk) ~= "function" then
        return nil
    end

    local bagId, slotIndex = self:_resolveBagAndSlot(inventorySlot)
    if bagId == nil or slotIndex == nil then
        return nil
    end

    if type(BAG_VIRTUAL) == "number" and bagId == BAG_VIRTUAL then
        return nil
    end

    local isJunk = IsItemJunk(bagId, slotIndex) == true
    if not isJunk then
        if type(IsItemPlayerLocked) == "function" and IsItemPlayerLocked(bagId, slotIndex) then
            return nil
        end

        if type(CanItemBeMarkedAsJunk) ~= "function" or not CanItemBeMarkedAsJunk(bagId, slotIndex) then
            return nil
        end
    end

    local labelStringId = isJunk and SI_ITEM_ACTION_UNMARK_AS_JUNK or SI_ITEM_ACTION_MARK_AS_JUNK
    local fallbackLabel = isJunk and "Unmark as Junk" or "Mark as Junk"
    local label = SafeGetString(labelStringId, fallbackLabel)
    if type(label) ~= "string" or label == "" then
        return nil
    end

    return {
        label = label,
        callback = function()
            SetItemIsJunk(bagId, slotIndex, not isJunk)
        end,
    }
end

function bridge:_rememberContextCallback(func, category, args)
    if type(func) ~= "function" then
        return
    end

    local key = BuildCallbackKey(func, category, args)
    if self._callbackKeys[key] then
        return
    end

    self._callbackKeys[key] = true

    local callbacks = self._contextCallbacks[category]
    if not callbacks then
        callbacks = {}
        self._contextCallbacks[category] = callbacks
    end

    callbacks[#callbacks + 1] = {
        func = func,
        args = args,
    }

    LogTrace(string.format("Registered callback in category %s (count=%d)", tostring(category), #callbacks))
end

function bridge:_importExistingCallbacks(lcm)
    local registry = lcm and lcm.contextMenuRegistry
    if type(registry) ~= "table" then
        return
    end

    local callbackRegistry = registry.callbackRegistry or registry.m_callbackRegistry
    if type(callbackRegistry) ~= "table" then
        return
    end

    for category, handlers in pairs(callbackRegistry) do
        local numericCategory = tonumber(category)
        if numericCategory and type(handlers) == "table" then
            local resolvedCategory = ResolveCategory(lcm, numericCategory)

            for i = 1, #handlers do
                local entry = handlers[i]
                if type(entry) == "table" then
                    local callback = entry[1] or entry.callback
                    if type(callback) == "function" then
                        local args = {}
                        if entry.args and type(entry.args) == "table" then
                            for argIndex = 1, #entry.args do
                                args[#args + 1] = entry.args[argIndex]
                            end
                        else
                            for argIndex = 2, #entry do
                                args[#args + 1] = entry[argIndex]
                            end
                        end

                        self:_rememberContextCallback(callback, resolvedCategory, args)
                    end
                end
            end
        end
    end
end

function bridge:_wrapRegisterContextMenu(lcm)
    if self._registerWrapped then
        return
    end

    if type(lcm) ~= "table" or type(lcm.RegisterContextMenu) ~= "function" then
        return
    end

    self._originalRegisterContextMenu = lcm.RegisterContextMenu

    lcm.RegisterContextMenu = function(libSelf, func, category, ...)
        local callbackArgs = { ... }
        bridge:_rememberContextCallback(func, ResolveCategory(lcm, category), callbackArgs)
        return bridge._originalRegisterContextMenu(libSelf, func, category, ...)
    end

    self._registerWrapped = true
end

function bridge:RegisterContextMenu(func, category, ...)
    local lcm = LibCustomMenu
    if type(lcm) ~= "table" then
        return
    end

    if type(lcm.RegisterContextMenu) == "function" then
        lcm:RegisterContextMenu(func, category, ...)
    else
        self:_rememberContextCallback(func, ResolveCategory(lcm, category), { ... })
    end
end

function bridge:SetEnabled(enabled)
    self.enabled = not not enabled
    if self.savedVars then
        self.savedVars.enabled = self.enabled
    end
    if not self.enabled then
        self:_hideOverlay()
    end
    LogDebug("Bridge enabled: " .. tostring(self.enabled))
end

function bridge:SetDebugEnabled(enabled)
    self.debug = not not enabled
    if self.savedVars then
        self.savedVars.debug = self.debug
    end
    self:_debugMessage("Debug enabled: " .. tostring(self.debug), false)
end

function bridge:SetDebugVerbose(enabled)
    self.debugVerbose = not not enabled
    if self.savedVars then
        self.savedVars.debugVerbose = self.debugVerbose
    end
    self:_debugMessage("Debug verbose: " .. tostring(self.debugVerbose), false)
end

function bridge:SetShowTtcPriceInTooltip(enabled)
    local value = not not enabled
    if self.savedVars then
        self.savedVars.showTtcPriceInTooltip = value
    end
end

function bridge:SetShowTtcPriceDetailsInTooltip(enabled)
    local value = not not enabled
    if self.savedVars then
        self.savedVars.showTtcPriceDetailsInTooltip = value
    end
end

function bridge:SetShowJunkStatusInTooltip(enabled)
    local value = not not enabled
    if self.savedVars then
        self.savedVars.showJunkStatusInTooltip = value
    end
end

function bridge:SetShowVendorPriceInTooltip(enabled)
    local value = not not enabled
    if self.savedVars then
        self.savedVars.showVendorPriceInTooltip = value
    end
end

function bridge:ClearDebugLog()
    self._debugLog = {}
    if self.savedVars then
        self.savedVars.debugLog = {}
    end
    self:_debugMessage("Debug log cleared", false)
end

function bridge:DumpDebugLog(limit)
    if type(d) ~= "function" then
        return
    end

    local count = #self._debugLog
    if count == 0 then
        d(string.format("[%s] Debug log is empty", MAJOR))
        return
    end

    local maxLines = tonumber(limit) or 40
    if maxLines < 1 then
        maxLines = 1
    end

    local startIndex = math.max(1, count - maxLines + 1)
    d(string.format("[%s] Debug log (%d entries, showing %d..%d)", MAJOR, count, startIndex, count))
    for i = startIndex, count do
        d(self._debugLog[i])
    end
end

function bridge:DumpRuntimeStatus()
    if type(d) ~= "function" then
        return
    end

    local summary, total = self:_summarizeContextRegistry()
    local overlayVisible = false
    if self._overlayWindow and self._overlayWindow.window and type(self._overlayWindow.window.IsHidden) == "function" then
        overlayVisible = not self._overlayWindow.window:IsHidden()
    end

    d(string.format(
        "[%s] enabled=%s debug=%s verbose=%s overlay=%s initialized=%s",
        MAJOR,
        tostring(self.enabled),
        tostring(self.debug),
        tostring(self.debugVerbose),
        tostring(overlayVisible),
        tostring(self._initialized)
    ))
    d(string.format(
        "[%s] hooks tooltip=%s crafting=%s tradingHouse=%s discover=%s refresh=%s playerActivated=%s",
        MAJOR,
        tostring(self._tooltipPriceHooked),
        tostring(self._craftingTooltipsHooked == true),
        tostring(self._tradingHouseTooltipHooked),
        tostring(self._discoverHooked),
        tostring(self._refreshHooked),
        tostring(self._playerActivatedHookRegistered)
    ))
    d(string.format(
        "[%s] overlay created=%s visible=%s cachedLines=%d formattedCache=%d",
        MAJOR,
        tostring(self._overlayWindow ~= nil),
        tostring(overlayVisible),
        tonumber(self._tooltipTtcCacheSize or 0),
        tonumber(self._formattedTooltipLineCacheSize or 0)
    ))
    d(string.format(
        "[%s] settings TTC=%s TTCdetails=%s junk=%s vendor=%s registry=%d (%s)",
        MAJOR,
        tostring(self:_shouldShowTtcTooltipPrice()),
        tostring(self:_shouldShowTtcTooltipDetails()),
        tostring(self:_shouldShowJunkStatusInTooltip()),
        tostring(self:_shouldShowVendorPriceInTooltip()),
        tonumber(total or 0),
        tostring(summary)
    ))
end

function bridge:_initializeSavedVars()
    if self.savedVars then
        return
    end

    if type(ZO_SavedVars) ~= "table" or type(ZO_SavedVars.NewAccountWide) ~= "function" then
        self.enabled = DEFAULTS.enabled
        self.debug = DEFAULTS.debug
        self.debugVerbose = DEFAULTS.debugVerbose
        return
    end

    self.savedVars = ZO_SavedVars:NewAccountWide(SAVED_VARS_NAME, SAVED_VARS_VERSION, nil, DEFAULTS)
    self.enabled = self.savedVars.enabled ~= false
    self.debug = self.savedVars.debug == true
    self.debugVerbose = self.savedVars.debugVerbose == true
    -- Restore in-memory log from persisted SavedVars log.
    if type(self.savedVars.debugLog) == "table" then
        for _, v in ipairs(self.savedVars.debugLog) do
            self._debugLog[#self._debugLog + 1] = v
        end
    else
        self.savedVars.debugLog = {}
    end
    LogTrace("SavedVars loaded")
end

function bridge:_shouldShowTtcTooltipPrice()
    return not not (not self.savedVars or self.savedVars.showTtcPriceInTooltip ~= false)
end

function bridge:_shouldShowTtcTooltipDetails()
    return self.savedVars and self.savedVars.showTtcPriceDetailsInTooltip == true
end

function bridge:_shouldShowJunkStatusInTooltip()
    return not not (not self.savedVars or self.savedVars.showJunkStatusInTooltip ~= false)
end

function bridge:_shouldShowVendorPriceInTooltip()
    return not not (not self.savedVars or self.savedVars.showVendorPriceInTooltip ~= false)
end

function bridge:_shouldShowTemplateCraftingOverlay()
    return self._templateCraftingOverlayActive == true
end

function bridge:_getTtcPriceInfo(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" then
        return nil
    end

    local providers = {
        _G.TamrielTradeCentrePrice,
        type(TamrielTradeCentre) == "table" and TamrielTradeCentre.Price or nil,
    }

    for i = 1, #providers do
        local provider = providers[i]
        if type(provider) == "table" and type(provider.GetPriceInfo) == "function" then
            local ok, priceInfo = pcall(provider.GetPriceInfo, provider, itemLink)
            if ok and type(priceInfo) == "table" then
                return {
                    Avg = priceInfo.Avg or priceInfo.A,
                    Max = priceInfo.Max or priceInfo.X,
                    Min = priceInfo.Min or priceInfo.N,
                    EntryCount = priceInfo.EntryCount or priceInfo.EC,
                    AmountCount = priceInfo.AmountCount or priceInfo.AC,
                    SuggestedPrice = priceInfo.SuggestedPrice or priceInfo.S,
                    SaleAvg = priceInfo.SaleAvg or priceInfo.SA,
                    SaleEntryCount = priceInfo.SaleEntryCount or priceInfo.SE,
                    SaleAmountCount = priceInfo.SaleAmountCount or priceInfo.SAC,
                }
            end
        end
    end

    return nil
end

function bridge:_getTtcPriceTableUpdatedText()
    local providers = {
        _G.TamrielTradeCentrePrice,
        type(TamrielTradeCentre) == "table" and TamrielTradeCentre.Price or nil,
    }

    for i = 1, #providers do
        local provider = providers[i]
        if type(provider) == "table" and type(provider.GetPriceTableUpdatedDateString) == "function" then
            local ok, updatedText = pcall(provider.GetPriceTableUpdatedDateString, provider)
            if ok and type(updatedText) == "string" and updatedText ~= "" then
                return updatedText
            end
        end
    end

    return nil
end

function bridge:_formatTtcCurrency(value)
    if type(value) ~= "number" then
        return nil
    end

    value = math.floor(value + 0.5)

    if type(ZO_CurrencyControl_FormatCurrency) == "function" then
        local ok, formatted = pcall(ZO_CurrencyControl_FormatCurrency, value, true, nil)
        if ok and type(formatted) == "string" and formatted ~= "" then
            return formatted
        end
    end

    if type(TamrielTradeCentre) == "table" and type(TamrielTradeCentre.FormatNumber) == "function" then
        local ok, formatted = pcall(TamrielTradeCentre.FormatNumber, TamrielTradeCentre, value, 0)
        if ok and type(formatted) == "string" and formatted ~= "" then
            return formatted
        end
    end

    return tostring(zo_floor and zo_floor(value) or math.floor(value))
end

function bridge:_formatTooltipInfoCurrency(value)
    return self:_formatTtcCurrency(value)
end

function bridge:_formatCompactTooltipCurrency(value)
    if type(value) ~= "number" then
        return nil
    end

    value = math.floor(value + 0.5)

    local suffix = nil
    local scaled = value
    if value >= 1000000 then
        scaled = value / 1000000
        suffix = "кк"
    elseif value >= 1000 then
        scaled = value / 1000
        suffix = "к"
    end

    if not suffix then
        return tostring(value)
    end

    local precision = scaled >= 10 and 0 or 1
    local text = string.format("%0." .. tostring(precision) .. "f", scaled)
    text = text:gsub("([%.%,]0+)$", "")
    text = text:gsub("%.$", "")
    text = text:gsub("%,$", "")
    return text .. suffix
end

function bridge:_getTooltipTtcCacheKey(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" then
        return nil
    end

    return table.concat({
        itemLink,
        tostring(self:_shouldShowTtcTooltipPrice()),
        tostring(self:_shouldShowTtcTooltipDetails()),
    }, "|")
end

function bridge:_getCachedTtcTooltipLines(itemLink)
    local cacheKey = self:_getTooltipTtcCacheKey(itemLink)
    if not cacheKey then
        return nil
    end

    local cached = self._tooltipTtcCache[cacheKey]
    if cached ~= nil then
        return cached
    end

    local lines = {}
    if self:_shouldShowTtcTooltipPrice() then
        local priceInfo = self:_getTtcPriceInfo(itemLink)
        if type(priceInfo) == "table" then
            local primaryPrice = priceInfo.SuggestedPrice or priceInfo.Avg or priceInfo.Min
            local primaryPriceText = self:_formatTooltipInfoCurrency(primaryPrice)
            if type(primaryPriceText) == "string" and primaryPriceText ~= "" then
                lines[#lines + 1] = "TTC: " .. primaryPriceText
            end

            if self:_shouldShowTtcTooltipDetails() then
                local minPriceText = self:_formatCompactTooltipCurrency(priceInfo.Min or primaryPrice)
                local avgPriceText = self:_formatCompactTooltipCurrency(priceInfo.Avg or primaryPrice)
                local maxPriceText = self:_formatCompactTooltipCurrency(priceInfo.Max or primaryPrice)
                if minPriceText and avgPriceText and maxPriceText then
                    lines[#lines + 1] = string.format("Min/Avg/Max: %s / %s / %s", minPriceText, avgPriceText, maxPriceText)
                end
            end
        end
    end

    if self._tooltipTtcCache[cacheKey] == nil then
        self._tooltipTtcCacheSize = (self._tooltipTtcCacheSize or 0) + 1
        if self._tooltipTtcCacheSize > 256 then
            self._tooltipTtcCache = {}
            self._tooltipTtcCacheSize = 0
        end
    end

    self._tooltipTtcCache[cacheKey] = lines
    return lines
end

function bridge:_getItemLinkFromBagAndSlot(bagId, slotIndex)
    if type(GetItemLink) ~= "function" or bagId == nil or slotIndex == nil then
        return nil
    end

    local ok, itemLink = pcall(GetItemLink, bagId, slotIndex)
    if not ok or type(itemLink) ~= "string" or itemLink == "" then
        return nil
    end

    return itemLink
end

function bridge:_getVendorPriceText(bagId, slotIndex)
    if not self:_shouldShowVendorPriceInTooltip() then
        return nil
    end

    local sellPrice = nil
    if type(GetItemSellValueWithBonuses) == "function" then
        local ok, value = pcall(GetItemSellValueWithBonuses, bagId, slotIndex)
        if ok and type(value) == "number" then
            sellPrice = value
        end
    end

    if sellPrice == nil and type(GetItemSellValue) == "function" then
        local ok, value = pcall(GetItemSellValue, bagId, slotIndex)
        if ok and type(value) == "number" then
            sellPrice = value
        end
    end

    if type(sellPrice) ~= "number" or sellPrice <= 0 then
        return nil
    end

    local priceText = self:_formatTooltipInfoCurrency(sellPrice)
    if type(priceText) ~= "string" or priceText == "" then
        return nil
    end

    return "Vendor: " .. priceText
end

function bridge:_getJunkStatusText(bagId, slotIndex)
    if not self:_shouldShowJunkStatusInTooltip() then
        return nil
    end

    if type(IsItemJunk) ~= "function" then
        return nil
    end

    local ok, isJunk = pcall(IsItemJunk, bagId, slotIndex)
    if ok and isJunk == true then
        return "Junk: Yes"
    end

    if type(CanItemBeMarkedAsJunk) == "function" then
        local canMarkOk, canMark = pcall(CanItemBeMarkedAsJunk, bagId, slotIndex)
        if canMarkOk and canMark == true then
            return "Junk: No"
        end
    end

    return nil
end

function bridge:_isBoundItem(bagId, slotIndex, itemLink)
    local isBound = false

    if bagId ~= nil and slotIndex ~= nil and type(IsItemBound) == "function" then
        local ok, value = pcall(IsItemBound, bagId, slotIndex)
        if ok and value == true then
            isBound = true
        end
    end

    if not isBound and type(IsItemLinkBound) == "function" and type(itemLink) == "string" then
        local ok, value = pcall(IsItemLinkBound, itemLink)
        if ok and value == true then
            isBound = true
        end
    end

    return isBound
end

function bridge:_buildTooltipInfoLines(bagId, slotIndex)
    local lines = {}
    local itemLink = self:_getItemLinkFromBagAndSlot(bagId, slotIndex)
    if self:_isBoundItem(bagId, slotIndex, itemLink) then
        return lines
    end

    local stackCount = nil
    if type(GetSlotStackSize) == "function" then
        local ok, value = pcall(GetSlotStackSize, bagId, slotIndex)
        if ok and type(value) == "number" and value > 0 then
            stackCount = value
        end
    end
    if itemLink then
        local linkLines = self:_buildTooltipInfoLinesByLink(itemLink, stackCount, nil, false)
        for i = 1, #linkLines do
            lines[#lines + 1] = linkLines[i]
        end
    end

    local junkStatus = self:_getJunkStatusText(bagId, slotIndex)
    if junkStatus then
        lines[#lines + 1] = junkStatus
    end

    local vendorPrice = self:_getVendorPriceText(bagId, slotIndex)
    if vendorPrice then
        lines[#lines + 1] = vendorPrice
    end

    return lines
end

function bridge:_buildTooltipInfoLinesByLink(itemLink, stackCount, listingPrice, includeVendor, craftContext, source)
    local lines = {}
    if type(itemLink) ~= "string" or itemLink == "" then
        return lines
    end

    if self:_isBoundItem(nil, nil, itemLink) then
        return lines
    end

    if includeVendor == nil then
        includeVendor = true
    end

    if self:_shouldShowTtcTooltipPrice() then
        local ttcLines = self:_getCachedTtcTooltipLines(itemLink)
        if type(ttcLines) == "table" then
            for i = 1, #ttcLines do
                lines[#lines + 1] = ttcLines[i]
            end
        end

        if type(stackCount) == "number" and stackCount > 1 then
            local priceInfo = self:_getTtcPriceInfo(itemLink)
            if priceInfo then
                local unitPrice = priceInfo.SuggestedPrice or priceInfo.Avg
                if type(unitPrice) == "number" and unitPrice > 0 then
                    local stackTotal = unitPrice * stackCount
                    local stackText = self:_formatTooltipInfoCurrency(stackTotal)
                    if type(stackText) == "string" and stackText ~= "" then
                        lines[#lines + 1] = "TTC x" .. stackCount .. ": " .. stackText
                    end
                end
            end
        end

        if type(listingPrice) == "number" and listingPrice > 0
            and type(stackCount) == "number" and stackCount > 0
        then
            local priceInfo = self:_getTtcPriceInfo(itemLink)
            local unitPrice = priceInfo and (priceInfo.SuggestedPrice or priceInfo.Avg)
            if type(unitPrice) == "number" and unitPrice > 0 then
                local listingPerUnit = listingPrice / stackCount
                local diff = listingPerUnit - unitPrice
                local absDiff = math.abs(diff)
                local diffText = self:_formatCompactTooltipCurrency(absDiff)
                if type(diffText) == "string" and diffText ~= "" then
                    if diff > 0.5 then
                        lines[#lines + 1] = "vs TTC: +" .. diffText .. " overpriced"
                    elseif diff < -0.5 then
                        lines[#lines + 1] = "vs TTC: -" .. diffText .. " cheaper"
                    else
                        lines[#lines + 1] = "vs TTC: fair"
                    end
                end
            end
        end
    end

    if source == "furncraft" and type(craftContext) == "table" then
        local craftLines = self:_buildCraftMaterialCostLines(itemLink, craftContext)
        if type(craftLines) == "table" then
            for i = 1, #craftLines do
                lines[#lines + 1] = craftLines[i]
            end
        end
    end

    if includeVendor and self:_shouldShowVendorPriceInTooltip() and type(GetItemLinkValue) == "function" then
        local ok, sellPrice = pcall(GetItemLinkValue, itemLink)
        if ok and type(sellPrice) == "number" and sellPrice > 0 then
            local priceText = self:_formatTooltipInfoCurrency(sellPrice)
            if type(priceText) == "string" and priceText ~= "" then
                lines[#lines + 1] = "Vendor: " .. priceText
            end
        end
    end

    return lines
end

local function ClampColorByte(value)
    value = tonumber(value) or 1
    if value < 0 then value = 0 end
    if value > 1 then value = 1 end
    return math.floor(value * 255 + 0.5)
end

local function RgbToHex(r, g, b)
    return string.format("%02X%02X%02X", ClampColorByte(r), ClampColorByte(g), ClampColorByte(b))
end

local function FirstPositiveNumber(...)
    local count = select("#", ...)
    for i = 1, count do
        local v = select(i, ...)
        if type(v) == "number" and v > 0 then
            return v
        end
    end
    return nil
end

function bridge:_getItemLinkQualityHex(itemLink)
    if not IsValidItemLink(itemLink) then
        return "B8B29A"
    end

    local quality = nil
    if type(GetItemLinkDisplayQuality) == "function" then
        local ok, q = pcall(GetItemLinkDisplayQuality, itemLink)
        if ok and type(q) == "number" then
            quality = q
        end
    end
    if quality == nil and type(GetItemLinkQuality) == "function" then
        local ok, q = pcall(GetItemLinkQuality, itemLink)
        if ok and type(q) == "number" then
            quality = q
        end
    end

    if quality ~= nil and type(GetInterfaceColor) == "function"
        and type(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS) == "number"
    then
        local ok, r, g, b = pcall(GetInterfaceColor, INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)
        if ok and type(r) == "number" and type(g) == "number" and type(b) == "number" then
            return RgbToHex(r, g, b)
        end
    end

    return "B8B29A"
end

function bridge:_collectRecipeIngredients(recipeListIndex, recipeIndex)
    local ingredients = {}
    if recipeListIndex == nil or recipeIndex == nil then
        return ingredients
    end

    local function callGlobal(globalName, ...)
        local fn = _G[globalName]
        if type(fn) ~= "function" then
            return false
        end
        return pcall(fn, ...)
    end

    local function callAny(globalNames, argSets)
        for i = 1, #globalNames do
            local globalName = globalNames[i]
            for j = 1, #argSets do
                local args = argSets[j]
                local ok, a, b, c, d, e, f = callGlobal(globalName, unpack(args))
                if ok then
                    return true, a, b, c, d, e, f, globalName, j
                end
            end
        end
        return false
    end

    local ingredientCount = 0

    if type(GetRecipeNumIngredients) == "function" then
        local okCount, value = pcall(GetRecipeNumIngredients, recipeListIndex, recipeIndex)
        if okCount and type(value) == "number" then
            ingredientCount = value
        else
            LogTrace("craft.recipe: GetRecipeNumIngredients failed okCount=" .. tostring(okCount)
                .. " ingredientCount type=" .. type(value) .. " value=" .. tostring(value))
        end
    else
        LogTrace("craft.recipe: GetRecipeNumIngredients not available")
    end

    if ingredientCount <= 0 then
        local okCurrent, currentCount = callGlobal("GetCurrentRecipeIngredientCount")
        if okCurrent and type(currentCount) == "number" and currentCount > 0 then
            ingredientCount = currentCount
        end
    end

    -- Furnishing recipe UI sometimes reports 0 here even when ingredients exist.
    local scanCount = ingredientCount > 0 and ingredientCount or 24

    for i = 1, scanCount do
        local link = nil
        if type(GetRecipeIngredientItemLink) == "function" then
            local ok, value = pcall(GetRecipeIngredientItemLink, recipeListIndex, recipeIndex, i)
            if ok and IsValidItemLink(value) then
                link = value
            elseif not ok then
                LogTrace("craft.recipe: slot " .. i .. " GetRecipeIngredientItemLink error")
            end
        end

        if not IsValidItemLink(link) then
            local okLink, a, b, c, d, e, f, fromName = callAny(
                {
                    "GetCurrentRecipeIngredientItemLink",
                    "GetCurrentRecipeIngredientLink",
                },
                {
                    { i },
                    { recipeListIndex, recipeIndex, i },
                }
            )
            if okLink then
                local fallbackLink = nil
                if IsValidItemLink(a) then
                    fallbackLink = a
                elseif IsValidItemLink(b) then
                    fallbackLink = b
                elseif IsValidItemLink(c) then
                    fallbackLink = c
                elseif IsValidItemLink(d) then
                    fallbackLink = d
                elseif IsValidItemLink(e) then
                    fallbackLink = e
                elseif IsValidItemLink(f) then
                    fallbackLink = f
                end
                if IsValidItemLink(fallbackLink) then
                    link = fallbackLink
                end
            end
        end

        local quantity = nil
        if type(GetRecipeIngredientItemInfo) == "function" then
            local okInfo, a, b, c, d, e, f = pcall(GetRecipeIngredientItemInfo, recipeListIndex, recipeIndex, i)
            if okInfo then
                quantity = FirstPositiveNumber(a, b, c, d, e, f)
            end
        end

        if quantity == nil then
            local okInfo, a, b, c, d, e, f, fromName = callAny(
                {
                    "GetCurrentRecipeIngredientItemInfo",
                    "GetCurrentRecipeIngredientInfo",
                    "GetCurrentRecipeIngredientData",
                    "GetCurrentRecipeIngredientItemCount",
                    "GetCurrentRecipeIngredientQuantity",
                },
                {
                    { i },
                    { recipeListIndex, recipeIndex, i },
                }
            )
            if okInfo then
                quantity = FirstPositiveNumber(a, b, c, d, e, f)
                if not IsValidItemLink(link) then
                    if IsValidItemLink(a) then
                        link = a
                    elseif IsValidItemLink(b) then
                        link = b
                    elseif IsValidItemLink(c) then
                        link = c
                    elseif IsValidItemLink(d) then
                        link = d
                    elseif IsValidItemLink(e) then
                        link = e
                    elseif IsValidItemLink(f) then
                        link = f
                    end
                end
            end
        end

        local name = nil
        if IsValidItemLink(link) and type(GetItemLinkName) == "function" then
            local okName, value = pcall(GetItemLinkName, link)
            if okName and type(value) == "string" and value ~= "" then
                name = value
            end
        end

        if ingredientCount <= 0 and not IsValidItemLink(link) and quantity == nil then
            break
        end

        ingredients[#ingredients + 1] = {
            itemLink = link,
            quantity = math.max(1, math.floor((quantity or 1) + 0.5)),
            name = name,
        }
    end

    return ingredients
end

function bridge:_itemIdFromLink(link)
    if type(link) ~= "string" then
        return nil
    end
    return tonumber(link:match("|H%d+:item:(%d+):"))
end

function bridge:_collectRecipeIngredientsByResultLink(resultItemLink)
    local ingredients = {}
    local targetId = self:_itemIdFromLink(resultItemLink)
    if targetId == nil then
        return ingredients
    end

    self._recipeResultLookupCache = self._recipeResultLookupCache or {}
    local cached = self._recipeResultLookupCache[targetId]
    if cached == false then
        return ingredients
    end
    if type(cached) == "table" and cached.recipeListIndex and cached.recipeIndex then
        return self:_collectRecipeIngredients(cached.recipeListIndex, cached.recipeIndex)
    end

    if type(GetNumRecipeLists) ~= "function"
        or type(GetRecipeListInfo) ~= "function"
        or type(GetRecipeResultItemLink) ~= "function"
    then
        return ingredients
    end

    local okLists, listCount = pcall(GetNumRecipeLists)
    if not okLists or type(listCount) ~= "number" or listCount <= 0 then
        return ingredients
    end

    for recipeListIndex = 1, listCount do
        local okInfo, _, numRecipes = pcall(GetRecipeListInfo, recipeListIndex)
        if okInfo and type(numRecipes) == "number" and numRecipes > 0 then
            for recipeIndex = 1, numRecipes do
                local okLink, link = pcall(GetRecipeResultItemLink, recipeListIndex, recipeIndex)
                if okLink and IsValidItemLink(link) and self:_itemIdFromLink(link) == targetId then
                    self._recipeResultLookupCache[targetId] = {
                        recipeListIndex = recipeListIndex,
                        recipeIndex = recipeIndex,
                    }
                    LogTrace("craft.materials: recipe lookup by result link hit list=" .. tostring(recipeListIndex)
                        .. " index=" .. tostring(recipeIndex)
                        .. " itemId=" .. tostring(targetId))
                    return self:_collectRecipeIngredients(recipeListIndex, recipeIndex)
                end
            end
        end
    end

    self._recipeResultLookupCache[targetId] = false
    LogTrace("craft.materials: recipe lookup by result link miss itemId=" .. tostring(targetId))
    return ingredients
end

function bridge:_collectIngredientsFromSelectedData(selectedData)
    local ingredients = {}
    if type(selectedData) ~= "table" then
        return ingredients
    end

    local candidates = {
        selectedData.ingredients,
        selectedData.ingredientData,
        selectedData.ingredientSlotData,
        selectedData.recipeData and selectedData.recipeData.ingredients,
    }

    for i = 1, #candidates do
        local bucket = candidates[i]
        if type(bucket) == "table" then
            for _, entry in pairs(bucket) do
                if type(entry) == "table" then
                    local link = self:_extractItemLinkFromData(entry)
                    local qty = tonumber(entry.requiredQuantity or entry.quantity or entry.stack or entry.stackCount)
                    local name = entry.name
                    if (IsValidItemLink(link) or type(name) == "string") and qty and qty > 0 then
                        ingredients[#ingredients + 1] = {
                            itemLink = link,
                            quantity = math.max(1, math.floor(qty + 0.5)),
                            name = name,
                        }
                    end
                end
            end
        end
    end

    if #ingredients > 0 then
        return ingredients
    end

    -- Deep fallback for furncraft: scan nested selectedData structures.
    local visited = {}
    local function walk(node, depth)
        if type(node) ~= "table" or depth > 5 or visited[node] then
            return
        end
        visited[node] = true

        local link = self:_extractItemLinkFromData(node)
        local qty = FirstPositiveNumber(
            node.requiredQuantity,
            node.quantity,
            node.materialQuantity,
            node.stack,
            node.stackCount,
            node.count,
            node.numRequired
        )
        local name = node.name or node.itemName or node.ingredientName
        if IsValidItemLink(link) and qty and qty > 0 then
            ingredients[#ingredients + 1] = {
                itemLink = link,
                quantity = math.max(1, math.floor(qty + 0.5)),
                name = type(name) == "string" and name ~= "" and name or nil,
            }
        end

        for _, child in pairs(node) do
            if type(child) == "table" then
                walk(child, depth + 1)
            end
        end
    end

    walk(selectedData, 0)

    return ingredients
end

function bridge:_collectSmithingPatternIngredients(craftContext)
    local ingredients = {}
    if type(craftContext) ~= "table" then
        return ingredients
    end

    local patternIndex = craftContext.patternIndex
    if patternIndex == nil then
        return ingredients
    end

    -- Probe material slots 1..12 until empty link.
    -- This handles both single-material (weapons/armor) and multi-material (furnishings).
    -- Quantity: try GetSmithingPatternMaterialQuantityRequired(pattern, slot), fallback to context qty.
    local function getMatLink(slot)
        if type(GetSmithingPatternMaterialItemLink) == "function" then
            local ok, l = pcall(GetSmithingPatternMaterialItemLink, patternIndex, slot)
            if ok and IsValidItemLink(l) then return l end
        end
        if type(GetSmithingPatternMaterialLink) == "function" then
            local ok, l = pcall(GetSmithingPatternMaterialLink, patternIndex, slot)
            if ok and IsValidItemLink(l) then return l end
        end
        return nil
    end

    local function getMatQty(slot)
        -- Try various ESO API names for material quantity
        for _, fnName in ipairs({"GetSmithingPatternMaterialQuantityRequired",
                                  "GetSmithingPatternNumMaterialsRequired",
                                  "GetSmithingPatternMaterialQuantityRequiredForResult"}) do
            local fn = _G[fnName]
            if type(fn) == "function" then
                local ok, q = pcall(fn, patternIndex, slot)
                if ok and type(q) == "number" and q > 0 then return q end
                -- Some functions take a 3rd arg (result count = 1)
                ok, q = pcall(fn, patternIndex, slot, 1)
                if ok and type(q) == "number" and q > 0 then return q end
            end
        end
        -- Fallback: use materialQuantity from context if this is the matching slot
        if craftContext.materialQuantity and craftContext.materialIndex == slot then
            return math.max(1, math.floor((tonumber(craftContext.materialQuantity) or 1) + 0.5))
        end
        return 1
    end

    for slot = 1, 12 do
        local link = getMatLink(slot)
        if not IsValidItemLink(link) then break end
        local qty = getMatQty(slot)
        ingredients[#ingredients + 1] = {
            itemLink = link,
            quantity = qty,
            name = (type(GetItemLinkName) == "function" and GetItemLinkName(link)) or nil,
        }
    end

    -- If nothing found via slot iteration but context has materialIndex (regular weapon/armor),
    -- fall through to the explicit-index fallback.
    if #ingredients > 0 then
        return ingredients
    end

    -- Fallback: single material via context (regular weapon/armor with explicit materialIndex)
    local materialIndex = craftContext.materialIndex
    if materialIndex == nil then
        return ingredients
    end

    local function tryGetLink(fnName)
        local fn = _G[fnName]
        if type(fn) ~= "function" then return nil end
        local tries = {
            { patternIndex, materialIndex, craftContext.materialQuantity, craftContext.styleIndex, craftContext.traitIndex },
            { patternIndex, materialIndex, craftContext.styleIndex, craftContext.traitIndex },
            { patternIndex, materialIndex },
        }
        for _, args in ipairs(tries) do
            local ok, value = pcall(fn, unpack(args))
            if ok and IsValidItemLink(value) then return value end
        end
        return nil
    end

    local link = tryGetLink("GetSmithingPatternMaterialItemLink")
        or tryGetLink("GetSmithingPatternMaterialLink")
    if IsValidItemLink(link) then
        ingredients[#ingredients + 1] = {
            itemLink = link,
            quantity = math.max(1, math.floor((tonumber(craftContext.materialQuantity) or 1) + 0.5)),
            name = (type(GetItemLinkName) == "function" and GetItemLinkName(link)) or nil,
        }
    end

    return ingredients
end

function bridge:_mergeIngredientList(baseList, appendList)
    if type(baseList) ~= "table" or type(appendList) ~= "table" then
        return baseList
    end

    local indexByKey = {}
    for i = 1, #baseList do
        local key = tostring(baseList[i].itemLink or "") .. "|" .. tostring(baseList[i].name or "")
        indexByKey[key] = i
    end

    for i = 1, #appendList do
        local entry = appendList[i]
        local key = tostring(entry.itemLink or "") .. "|" .. tostring(entry.name or "")
        local existing = indexByKey[key]
        if existing then
            baseList[existing].quantity = (baseList[existing].quantity or 0) + (entry.quantity or 0)
        else
            baseList[#baseList + 1] = entry
            indexByKey[key] = #baseList
        end
    end

    return baseList
end

function bridge:_buildCraftMaterialCostLines(resultItemLink, craftContext)
    if type(craftContext) ~= "table" then
        return {}
    end

    local ingredients = {}
    if craftContext.recipeListIndex ~= nil and craftContext.recipeIndex ~= nil then
        local r = self:_collectRecipeIngredients(craftContext.recipeListIndex, craftContext.recipeIndex)
        ingredients = self:_mergeIngredientList(ingredients, r)
    end
    if #ingredients == 0 and IsValidItemLink(resultItemLink) then
        local r = self:_collectRecipeIngredientsByResultLink(resultItemLink)
        ingredients = self:_mergeIngredientList(ingredients, r)
    end
    if type(craftContext.selectedData) == "table" then
        local r = self:_collectIngredientsFromSelectedData(craftContext.selectedData)
        ingredients = self:_mergeIngredientList(ingredients, r)
    end
    if craftContext.patternIndex ~= nil and craftContext.materialIndex ~= nil
        and craftContext.forceSmithingPatternMaterials == true
    then
        local r = self:_collectSmithingPatternIngredients(craftContext)
        ingredients = self:_mergeIngredientList(ingredients, r)
    end

    -- Selected-data fallbacks can include the crafted result item itself.
    -- Exclude it from ingredient list to avoid showing the product as a material.
    local resultItemId = self:_itemIdFromLink(resultItemLink)
    if resultItemId ~= nil and #ingredients > 0 then
        local filtered = {}
        local removed = 0
        for i = 1, #ingredients do
            local entry = ingredients[i]
            local entryItemId = self:_itemIdFromLink(entry and entry.itemLink)
            if entryItemId ~= nil and entryItemId == resultItemId then
                removed = removed + 1
            else
                filtered[#filtered + 1] = entry
            end
        end
        if removed > 0 then
            ingredients = filtered
        end
    end

    if #ingredients == 0 then
        return {}
    end

    local lines = {}
    lines[#lines + 1] = "|c8E8B68Materials:|r"

    local totalCost = 0
    local knownCostCount = 0
    local maxLines = 8

    for i = 1, math.min(#ingredients, maxLines) do
        local entry = ingredients[i]
        local qty = math.max(1, tonumber(entry.quantity) or 1)
        local link = entry.itemLink
        local qualityHex = self:_getItemLinkQualityHex(link)

        local name = entry.name
        if (type(name) ~= "string" or name == "") and IsValidItemLink(link) and type(GetItemLinkName) == "function" then
            local okName, resolved = pcall(GetItemLinkName, link)
            if okName and type(resolved) == "string" and resolved ~= "" then
                name = resolved
            end
        end
        if (type(name) ~= "string" or name == "") and IsValidItemLink(link) then
            name = "Unknown mat."
        end

        if type(name) ~= "string" or name == "" then
            -- Skip unknown placeholder-like ingredients to avoid noisy fake entries.
        else
            local costText = "n/a"
            if IsValidItemLink(link) then
                local priceInfo = self:_getTtcPriceInfo(link)
                local unitPrice = priceInfo and (priceInfo.SuggestedPrice or priceInfo.Avg)
                if type(unitPrice) == "number" and unitPrice > 0 then
                    local lineCost = unitPrice * qty
                    totalCost = totalCost + lineCost
                    knownCostCount = knownCostCount + 1
                    costText = self:_formatCompactTooltipCurrency(lineCost) or tostring(math.floor(lineCost + 0.5))
                end
            end

            lines[#lines + 1] = string.format("|c%s• %s x%d: %s|r", qualityHex, name, qty, costText)
        end
    end

    if #ingredients > maxLines then
        lines[#lines + 1] = string.format("|c8E8B68  ...and %d more mats|r", #ingredients - maxLines)
    end

    if knownCostCount > 0 then
        local totalText = self:_formatCompactTooltipCurrency(totalCost) or tostring(math.floor(totalCost + 0.5))
        lines[#lines + 1] = "|cD7C98FMat total: " .. totalText .. "|r"

        local resultPriceInfo = self:_getTtcPriceInfo(resultItemLink)
        local resultUnit = resultPriceInfo and (resultPriceInfo.SuggestedPrice or resultPriceInfo.Avg)
        if type(resultUnit) == "number" and resultUnit > 0 then
            local delta = resultUnit - totalCost
            local deltaText = self:_formatCompactTooltipCurrency(math.abs(delta)) or tostring(math.floor(math.abs(delta) + 0.5))
            if delta > 0.5 then
                lines[#lines + 1] = "|c6AB87Avs crafted: +" .. deltaText .. "|r"
            elseif delta < -0.5 then
                lines[#lines + 1] = "|cD46A6Avs crafted: -" .. deltaText .. "|r"
            else
                lines[#lines + 1] = "|cA0A070vs crafted: near zero|r"
            end
        end
    end

    return lines
end

local function FormatTooltipLine(text)
    if type(text) ~= "string" or text == "" then
        return text
    end

    local cached = bridge._formattedTooltipLineCache[text]
    if cached ~= nil then
        return cached
    end

    local formatted = nil

    if text:match("^TTC:%s") then
        formatted = "|cD8C06A" .. text .. "|r"
    elseif text:match("^Vendor:%s") then
        formatted = "|cC9B36B" .. text .. "|r"
    elseif text:match("^Junk:%s") then
        local junkValue = text:match("^Junk:%s*(.+)$")
        if junkValue == "Yes" then
            formatted = "|cB088D9" .. text .. "|r"
        else
            formatted = "|cF0F0F0" .. text .. "|r"
        end
    elseif text:match("^Min/Avg/Max:%s") then
        formatted = "|c9F9780" .. text .. "|r"
    elseif text:match("^TTC x%d") then
        -- TTC stack total — same gold colour as TTC line
        formatted = "|cD8C06A" .. text .. "|r"
    elseif text:match("^vs TTC:") then
        -- cheaper = green, overpriced = red, fair = neutral gray
        if text:find("cheaper") or text:find("дешевле") then
            formatted = "|c6AB87A" .. text .. "|r"
        elseif text:find("overpriced") or text:find("дороже") then
            formatted = "|cD46A6A" .. text .. "|r"
        else
            formatted = "|cA0A070" .. text .. "|r"
        end
    elseif text:match("^Bound:%s") then
        formatted = "|cA7A7A7" .. text .. "|r"
    else
        formatted = "|cB8B29A" .. text .. "|r"
    end

    if bridge._formattedTooltipLineCache[text] == nil then
        bridge._formattedTooltipLineCacheSize = (bridge._formattedTooltipLineCacheSize or 0) + 1
        if bridge._formattedTooltipLineCacheSize > 128 then
            bridge._formattedTooltipLineCache = {}
            bridge._formattedTooltipLineCacheSize = 0
        end
    end

    bridge._formattedTooltipLineCache[text] = formatted
    return formatted
end

function bridge:_ensureOverlayWindow()
    if self._overlayWindow then
        LogTrace("Overlay reuse existing window")
        return self._overlayWindow
    end

    local wm = WINDOW_MANAGER
    if wm == nil and type(GetWindowManager) == "function" then
        local ok, resolved = pcall(GetWindowManager)
        if ok then
            wm = resolved
        end
    end

    if wm == nil then
        LogDebug("Overlay unavailable: WINDOW_MANAGER missing")
        return nil
    end

    local guiRoot = _G.GuiRoot
    if guiRoot == nil then
        LogDebug("Overlay unavailable: GuiRoot missing")
        return nil
    end

    local window = nil
    local isTopLevelWindow = false

    if type(wm.CreateTopLevelWindow) == "function" then
        window = wm:CreateTopLevelWindow(MAJOR .. "_Overlay")
        isTopLevelWindow = true
        LogTrace("Overlay using CreateTopLevelWindow")
    elseif type(wm.CreateControl) == "function" and CT_CONTROL ~= nil then
        window = wm:CreateControl(MAJOR .. "_Overlay", guiRoot, CT_CONTROL)
        LogTrace("Overlay using CreateControl fallback")
    else
        LogDebug("Overlay unavailable: no supported window/control factory")
        return nil
    end

    if window == nil then
        LogDebug("Overlay unavailable: factory returned nil")
        return nil
    end

    window:SetHidden(true)
    window:SetMouseEnabled(false)
    if type(window.SetDrawLayer) == "function" then
        window:SetDrawLayer(DL_OVERLAY or "OVERLAY")
    end
    if type(window.SetDrawTier) == "function" then
        window:SetDrawTier(DT_HIGH or DT_MEDIUM or "HIGH")
    end
    if type(window.SetDrawLevel) == "function" then
        window:SetDrawLevel(10)
    end
    if type(window.SetMovable) == "function" then
        window:SetMovable(false)
    end
    if type(window.SetClampedToScreen) == "function" then
        window:SetClampedToScreen(true)
    end
    if not isTopLevelWindow and type(window.SetParent) == "function" then
        window:SetParent(guiRoot)
    end
    window:SetDimensions(320, 120)
    window:ClearAnchors()
    window:SetAnchor(TOPRIGHT, guiRoot, TOPRIGHT, -40, 140)

    local backdrop = wm:CreateControl(nil, window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    if type(backdrop.SetCenterColor) == "function" then
        backdrop:SetCenterColor(0, 0, 0, 0.70)
    end
    if type(backdrop.SetEdgeTexture) == "function" then
        backdrop:SetEdgeTexture("EsoUI/Art/Miscellaneous/Gamepad/gp_tooltip_edge_semitrans_64.dds", 64, 8, 8)
    end
    if type(backdrop.SetHidden) == "function" then
        backdrop:SetHidden(false)
    end

    -- Gold border lines (CT_TEXTURE), shown only for furncraft
    local function makeBorderTex(parent)
        local b = wm:CreateControl(nil, parent, CT_TEXTURE)
        b:SetColor(0.678, 0.651, 0.518, 1.0)
        b:SetHidden(true)
        return b
    end
    -- 3px черный отступ от края окна, затем 2px золотая линия
    local P, T = 3, 2
    local borderTop = makeBorderTex(window)
    borderTop:SetAnchor(TOPLEFT, window, TOPLEFT, P, P)
    borderTop:SetAnchor(BOTTOMRIGHT, window, TOPRIGHT, -P, P + T)
    local borderBottom = makeBorderTex(window)
    borderBottom:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, P, -P)
    borderBottom:SetAnchor(TOPRIGHT, window, BOTTOMRIGHT, -P, -(P + T))
    local borderLeft = makeBorderTex(window)
    borderLeft:SetAnchor(TOPLEFT, window, TOPLEFT, P, P)
    borderLeft:SetAnchor(BOTTOMRIGHT, window, BOTTOMLEFT, P + T, -P)
    local borderRight = makeBorderTex(window)
    borderRight:SetAnchor(TOPRIGHT, window, TOPRIGHT, -P, P)
    borderRight:SetAnchor(BOTTOMLEFT, window, BOTTOMRIGHT, -(P + T), -P)

    local label = wm:CreateControl(nil, window, CT_LABEL)
    label:SetAnchor(TOPLEFT, window, TOPLEFT, 12, 8)
    label:SetWidth(296)
    label:SetHeight(92)
    if type(label.SetVerticalAlignment) == "function" then
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    end
    if type(label.SetHorizontalAlignment) == "function" then
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    end
    if type(label.SetFont) == "function" then
        label:SetFont("ZoFontGamepad27")
    end
    if type(label.SetColor) == "function" then
        label:SetColor(1, 1, 1, 1)
    end

    self._overlayWindow = {
        window = window,
        backdrop = backdrop,
        borderTop = borderTop,
        borderBottom = borderBottom,
        borderLeft = borderLeft,
        borderRight = borderRight,
        label = label,
        lineLabels = { label },
        renderedLineCount = 0,
    }

    LogDebug("Overlay window created")

    return self._overlayWindow
end

function bridge:_ensureOverlayLineLabels(overlay, lineCount)
    if not overlay or not overlay.window or not overlay.label then
        return nil
    end

    overlay.lineLabels = overlay.lineLabels or { overlay.label }
    local lineLabels = overlay.lineLabels
    local wm = WINDOW_MANAGER

    for index = #lineLabels + 1, lineCount do
        local lineLabel = wm:CreateControl(nil, overlay.window, CT_LABEL)
        lineLabel:SetWidth(296)
        lineLabel:SetHeight(28)
        if type(lineLabel.SetVerticalAlignment) == "function" then
            lineLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
        end
        if type(lineLabel.SetHorizontalAlignment) == "function" then
            lineLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        end
        if type(lineLabel.SetWrapMode) == "function" and type(TEXT_WRAP_MODE_ELLIPSIS) == "number" then
            lineLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        end
        if type(lineLabel.SetFont) == "function" then
            lineLabel:SetFont("ZoFontGamepad27")
        end
        if type(lineLabel.SetColor) == "function" then
            lineLabel:SetColor(1, 1, 1, 1)
        end

        lineLabel:ClearAnchors()
        lineLabel:SetAnchor(TOPLEFT, lineLabels[index - 1], BOTTOMLEFT, 0, 0)
        lineLabels[index] = lineLabel
    end

    return lineLabels
end

function bridge:_renderOverlayLines(overlay, formattedLines)
    if not overlay or not overlay.label then
        return
    end

    local lineCount = math.max(1, #formattedLines)
    local lineLabels = self:_ensureOverlayLineLabels(overlay, lineCount)
    if not lineLabels then
        return
    end

    overlay.renderedLineCount = #formattedLines
    for index = 1, #lineLabels do
        local lineLabel = lineLabels[index]
        if type(lineLabel.SetWrapMode) == "function" and type(TEXT_WRAP_MODE_ELLIPSIS) == "number" then
            lineLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        end
        local text = formattedLines[index]
        if type(text) == "string" and text ~= "" then
            lineLabel:SetHeight(28)
            lineLabel:SetText(text)
            lineLabel:SetHidden(false)
        else
            lineLabel:SetText("")
            lineLabel:SetHidden(true)
            lineLabel:SetHeight(0)
        end
    end
end

function bridge:_isRenderableControl(control)
    return control
        and (type(control.IsHidden) ~= "function" or control:IsHidden() == false)
        and (type(control.GetWidth) ~= "function" or control:GetWidth() > 0)
        and (type(control.GetHeight) ~= "function" or control:GetHeight() > 0)
end

function bridge:_getOverlayTooltipBySource(source)
    if type(GAMEPAD_TOOLTIPS) ~= "table" or type(GAMEPAD_TOOLTIPS.GetTooltip) ~= "function" then
        return nil
    end

    local tooltipTypes = nil
    if source == "furncraft" then
        tooltipTypes = { GAMEPAD_LEFT_TOOLTIP, GAMEPAD_RIGHT_TOOLTIP, GAMEPAD_MOVABLE_TOOLTIP }
    else
        tooltipTypes = { GAMEPAD_RIGHT_TOOLTIP, GAMEPAD_LEFT_TOOLTIP, GAMEPAD_MOVABLE_TOOLTIP }
    end

    for i = 1, #tooltipTypes do
        local tooltipType = tooltipTypes[i]
        if type(tooltipType) == "number" then
            local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(tooltipType)
            if self:_isRenderableControl(tooltip) then
                return tooltip
            end
        end
    end

    return nil
end

function bridge:_getActiveOverlayTooltip()
    if self:_isRenderableControl(self._overlayTooltipControl) then
        return self._overlayTooltipControl
    end

    return self:_getOverlayTooltipBySource(self._overlaySource)
end

function bridge:_getOverlayAnchorContainer()
    local tooltip = self:_getActiveOverlayTooltip()
    if not self:_isRenderableControl(tooltip) then
        return nil
    end

    local current = tooltip
    local best = tooltip
    local guiRoot = _G.GuiRoot

    for _ = 1, 8 do
        if type(current.GetParent) ~= "function" then
            break
        end

        local ok, parent = pcall(current.GetParent, current)
        if not ok or not self:_isRenderableControl(parent) or parent == guiRoot then
            break
        end

        best = parent
        current = parent
    end

    return best
end

function bridge:_shouldKeepOverlayVisible()
    local tooltip = self:_getActiveOverlayTooltip()
    if tooltip then
        return true
    end

    return self:_isRenderableControl(self._overlayAnchorControl)
end

function bridge:_refreshOverlayVisibility()
    local overlay = self._overlayWindow
    if not overlay or not overlay.window or overlay.window:IsHidden() then
        return
    end

    local now = type(GetGameTimeMilliseconds) == "function" and GetGameTimeMilliseconds() or 0
    if now - (overlay._lastVisibilityCheckAt or 0) < 100 then
        return
    end
    overlay._lastVisibilityCheckAt = now

    if self:_shouldKeepOverlayVisible() then
        return
    end

    self:_hideOverlay()
    LogTrace("Overlay hidden by visibility guard")
end

function bridge:_resizeOverlayToText(overlay)
    if not overlay or not overlay.window or not overlay.label then
        return
    end

    local tooltip = self:_getOverlayAnchorContainer() or self:_getActiveOverlayTooltip()
    local guiRoot = _G.GuiRoot
    local availableWidth = 500
    local maxHeight = 220

    if tooltip and type(tooltip.GetWidth) == "function" then
        if self._overlaySource == "furncraft" then
            availableWidth = math.max(380, math.min(math.floor(tooltip:GetWidth() * 0.92), 540))
        elseif self._overlaySource == "guildstore" then
            availableWidth = math.max(360, math.min(tooltip:GetWidth() - 28, 470))
        else
            availableWidth = math.max(430, math.min(tooltip:GetWidth() - 12, 560))
        end
    end
    if tooltip and type(tooltip.GetHeight) == "function" then
        if self._overlaySource == "furncraft" then
            maxHeight = math.max(280, math.min(math.floor(tooltip:GetHeight() * 1.35), 900))
        else
            maxHeight = math.max(120, math.min(math.floor(tooltip:GetHeight() * 0.42), 220))
        end
    end

    if guiRoot and type(guiRoot.GetHeight) == "function" then
        local screenMax = math.max(220, (guiRoot:GetHeight() or 1080) - 24)
        maxHeight = math.min(maxHeight, screenMax)
    end

    local labelWidth = availableWidth - 20
    local lineLabels = overlay.lineLabels or { overlay.label }
    local renderedLineCount = overlay.renderedLineCount or 0
    local usedHeight = 14

    for index = 1, #lineLabels do
        local lineLabel = lineLabels[index]
        lineLabel:SetWidth(labelWidth)
        if type(lineLabel.SetDimensionConstraints) == "function" then
            lineLabel:SetDimensionConstraints(labelWidth, 0, labelWidth, maxHeight - 12)
        end

        if index <= renderedLineCount then
            local textHeight = type(lineLabel.GetTextHeight) == "function" and lineLabel:GetTextHeight() or 28
            local lineHeight = math.max(30, textHeight + 2)
            lineLabel:SetHeight(lineHeight)
            lineLabel:SetHidden(false)
            usedHeight = usedHeight + lineHeight
        else
            lineLabel:SetHeight(0)
            lineLabel:SetHidden(true)
        end
    end

    local minHeight = (self._overlaySource == "furncraft") and 156 or 96
    local desiredHeight = math.max(minHeight, math.min(usedHeight + 16, maxHeight))

    overlay.window:SetDimensions(availableWidth, desiredHeight)
end

function bridge:_getOverlayInsetsForSource(source)
    if source == "guildstore" then
        return -10, -168
    end
    if source == "bag" then
        return -12, -176
    end
    if source == "furncraft" then
        return 0, -184
    end
    return 0, -100
end

function bridge:_hideOverlay()
    self._overlayAnchorControl = nil
    self._overlaySource = nil
    self._overlayTooltipControl = nil

    local overlay = self._overlayWindow
    if overlay and overlay.window and type(overlay.window.SetHidden) == "function" then
        overlay._lastVisibilityCheckAt = 0
        if type(overlay.window.SetHandler) == "function" then
            overlay.window:SetHandler("OnUpdate", nil)
        end
        overlay.window:SetHidden(true)
    end
end

function bridge:_positionOverlay()
    local overlay = self:_ensureOverlayWindow()
    if not overlay or not overlay.window then
        LogDebug("Overlay position skipped: overlay missing")
        return false
    end

    local guiRoot = _G.GuiRoot
    local anchorTarget = guiRoot
    local point = TOPRIGHT
    local relativePoint = TOPRIGHT
    local offsetX = -24
    local offsetY = 120

    local tooltip = self:_getOverlayAnchorContainer() or self:_getActiveOverlayTooltip()
    if tooltip then
        local insetX, insetY = self:_getOverlayInsetsForSource(self._overlaySource)
        anchorTarget = tooltip
        if self._overlaySource == "furncraft" then
            local gap = 42
            local safe = 8
            local overlayWidth = (type(overlay.window.GetWidth) == "function") and overlay.window:GetWidth() or 280
            local tooltipLeft = (type(tooltip.GetLeft) == "function") and tooltip:GetLeft() or 0
            local tooltipRight = (type(tooltip.GetRight) == "function") and tooltip:GetRight() or 0
            local screenWidth = (type(guiRoot.GetWidth) == "function") and guiRoot:GetWidth() or 1920
            local leftSpace = tooltipLeft - safe
            local rightSpace = screenWidth - tooltipRight - safe

            if leftSpace >= overlayWidth + gap then
                point = TOPRIGHT
                relativePoint = TOPLEFT
                offsetX = -gap
                offsetY = -18
            elseif rightSpace >= overlayWidth + gap then
                point = TOPLEFT
                relativePoint = TOPRIGHT
                offsetX = gap
                offsetY = -18
            else
                point = TOP
                relativePoint = TOP
                offsetX = insetX
                offsetY = insetY
            end
        else
            point = TOPLEFT
            relativePoint = TOPLEFT
            offsetX = insetX
            offsetY = insetY
        end
        LogTrace("Overlay anchored inside active tooltip")
    elseif self:_isRenderableControl(self._overlayAnchorControl) then
        anchorTarget = self._overlayAnchorControl
        point = BOTTOMLEFT
        relativePoint = TOPLEFT
        offsetX = 18
        offsetY = -8
        LogTrace("Overlay anchored above selected item row fallback")
    else
        LogTrace("Overlay fallback anchor: GuiRoot")
        return false
    end

    overlay.window:ClearAnchors()
    overlay.window:SetAnchor(point, anchorTarget, relativePoint, offsetX, offsetY)

    -- Keep the full dynamic window inside the screen bounds by nudging vertically.
    local rootTop = (guiRoot and type(guiRoot.GetTop) == "function") and guiRoot:GetTop() or 0
    local rootBottom = (guiRoot and type(guiRoot.GetBottom) == "function") and guiRoot:GetBottom() or 1080
    local winTop = (type(overlay.window.GetTop) == "function") and overlay.window:GetTop() or rootTop
    local winBottom = (type(overlay.window.GetBottom) == "function") and overlay.window:GetBottom() or rootBottom
    local safe = 6
    local adjustY = 0
    if type(winBottom) == "number" and type(rootBottom) == "number" and winBottom > (rootBottom - safe) then
        adjustY = adjustY - (winBottom - (rootBottom - safe))
    end
    if type(winTop) == "number" and type(rootTop) == "number" and (winTop + adjustY) < (rootTop + safe) then
        adjustY = adjustY + ((rootTop + safe) - (winTop + adjustY))
    end

    if math.abs(adjustY) >= 1 then
        overlay.window:ClearAnchors()
        overlay.window:SetAnchor(point, anchorTarget, relativePoint, offsetX, offsetY + adjustY)
    end

    return true
end

local function ParseCompactOverlayInfo(lines)
    local info = {
        ttc = nil,
        minAvgMax = nil,
        stackTotal = nil,
        versusTtc = nil,
        vendor = nil,
        junk = nil,
    }

    for i = 1, #lines do
        local line = lines[i]
        if type(line) == "string" then
            local value = line:match("^TTC:%s*(.+)$")
            if value then
                info.ttc = value
            end

            local minValue, avgValue, maxValue = line:match("^Min/Avg/Max:%s*(.-)%s*/%s*(.-)%s*/%s*(.+)$")
            if minValue and avgValue and maxValue then
                info.minAvgMax = string.format("%s / %s / %s", minValue, avgValue, maxValue)
            end

            local stackCount, stackPrice = line:match("^TTC x(%d+):%s*(.+)$")
            if stackCount and stackPrice then
                info.stackTotal = string.format("x%s %s", stackCount, stackPrice)
            end

            local diffValue = line:match("^vs TTC:%s*(.+)$")
            if diffValue then
                info.versusTtc = diffValue
            end

            local vendorValue = line:match("^Vendor:%s*(.+)$")
            if vendorValue then
                info.vendor = vendorValue
            end

            local junkValue = line:match("^Junk:%s*(.+)$")
            if junkValue then
                info.junk = junkValue
            end
        end
    end

    return info
end

local function BuildCompactMinAvgMaxLine(text)
    if not text then
        return nil
    end

    return string.format("|c9F9780Min/Avg/Max: %s|r", text)
end

local function BuildCompactVersusTtcLine(text)
    if not text then
        return nil
    end

    local prefix = "|cA0A070"
    if text:find("cheaper") or text:find("дешевле") then
        prefix = "|c6AB87A"
    elseif text:find("overpriced") or text:find("дороже") then
        prefix = "|cD46A6A"
    end

    return string.format("%svs TTC: %s|r", prefix, text)
end

local function AppendIfValue(lines, value)
    if value then
        lines[#lines + 1] = value
    end
end

local function BuildCompactOverlayBaseLines(info)
    local compact = {}

    AppendIfValue(compact, info.ttc and string.format("|cD8C06ATTC: %s|r", info.ttc) or nil)
    AppendIfValue(compact, BuildCompactMinAvgMaxLine(info.minAvgMax))
    AppendIfValue(compact, info.stackTotal and string.format("|cD8C06ATTC x%s|r", info.stackTotal:sub(2)) or nil)

    return compact
end

function bridge:_buildCompactOverlayLines(lines, source)
    if type(lines) ~= "table" or #lines == 0 then
        return lines
    end

    if source == "furncraft" then
        return lines
    end

    local info = ParseCompactOverlayInfo(lines)

    if source == "bag" then
        local compact = BuildCompactOverlayBaseLines(info)

        AppendIfValue(compact, info.vendor and string.format("|cC9B36BVendor: %s|r", info.vendor) or nil)
        AppendIfValue(compact, info.junk == "Yes" and "|cB088D9Junk: Yes|r" or nil)
        AppendIfValue(compact, BuildCompactVersusTtcLine(info.versusTtc))

        if #compact > 0 then
            return compact
        end
    end

    local compact = BuildCompactOverlayBaseLines(info)
    AppendIfValue(compact, info.vendor and string.format("|cC9B36BVendor: %s|r", info.vendor) or nil)
    AppendIfValue(compact, BuildCompactVersusTtcLine(info.versusTtc))

    if #compact > 0 then
        return compact
    end

    return lines
end

function bridge:_scheduleOverlayShowRetry(lines, source, tooltipControl, retryCount)
    if type(zo_callLater) ~= "function" then
        return false
    end

    retryCount = tonumber(retryCount) or 0
    if retryCount >= 6 then
        return false
    end

    zo_callLater(function()
        bridge:_showOverlayLines(lines, source, tooltipControl, retryCount + 1)
    end, 40)

    LogTrace("Overlay show delayed until tooltip anchor is ready")
    return true
end

function bridge:_showOverlayLines(lines, source, tooltipControl, retryCount)
    if type(lines) ~= "table" or #lines == 0 then
        LogTrace("Overlay show skipped: no lines")
        self:_hideOverlay()
        return
    end

    local overlay = self:_ensureOverlayWindow()
    if not overlay or not overlay.label then
        LogDebug("Overlay show failed: overlay or label missing")
        return
    end

    local overlayLines = self:_buildCompactOverlayLines(lines, source)
    local formattedLines = {}
    for i = 1, #overlayLines do
        local line = overlayLines[i]
        if type(line) == "string" and line:find("|c") then
            formattedLines[#formattedLines + 1] = line
        else
            formattedLines[#formattedLines + 1] = FormatTooltipLine(line)
        end
    end

    self._overlaySource = source
    self._overlayTooltipControl = tooltipControl
    local isFurncraft = (source == "furncraft")
    if overlay.backdrop then
        if isFurncraft then
            if type(overlay.backdrop.SetCenterColor) == "function" then
                overlay.backdrop:SetCenterColor(0, 0, 0, 0.70)
            end
            if type(overlay.backdrop.SetHidden) == "function" then
                overlay.backdrop:SetHidden(false)
            end
        else
            if type(overlay.backdrop.SetHidden) == "function" then
                overlay.backdrop:SetHidden(true)
            end
        end
    end
    for _, bName in ipairs({ "borderTop", "borderBottom", "borderLeft", "borderRight" }) do
        local b = overlay[bName]
        if b and type(b.SetHidden) == "function" then
            b:SetHidden(not isFurncraft)
        end
    end
    self:_renderOverlayLines(overlay, formattedLines)
    self:_resizeOverlayToText(overlay)

    local anchored = self:_positionOverlay()
    if not anchored then
        if self:_scheduleOverlayShowRetry(lines, source, tooltipControl, retryCount) then
            return
        end
    end

    if type(overlay.window.SetHandler) == "function" then
        if not bridge._onRefreshOverlay then
            bridge._onRefreshOverlay = function()
                bridge:_refreshOverlayVisibility()
            end
        end
        overlay.window:SetHandler("OnUpdate", bridge._onRefreshOverlay)
    end
    overlay.window:SetHidden(false)
    LogDebug(string.format("Overlay shown: source=%s lines=%d", tostring(source), #lines))
end

function bridge:_appendGamepadTooltipInfoByLink(tooltip, itemLink, stackCount, listingPrice, source, craftContext)
    if tooltip == nil or type(itemLink) ~= "string" or itemLink == "" then
        return
    end

    LogTrace("_appendByLink: " .. tostring(itemLink):sub(1, 50)
        .. " sc=" .. tostring(stackCount) .. " price=" .. tostring(listingPrice))

    -- Dedup: include stackCount/listingPrice in key so same item at different TH prices
    -- doesn't get skipped within the 200ms window.
    local contextKey = ""
    if type(craftContext) == "table" then
        contextKey = table.concat({
            tostring(craftContext.recipeListIndex or ""),
            tostring(craftContext.recipeIndex or ""),
            tostring(craftContext.patternIndex or ""),
            tostring(craftContext.materialIndex or ""),
            tostring(craftContext.materialQuantity or ""),
        }, ":")
    end
    local dedupKey = itemLink .. "|" .. tostring(stackCount or "") .. "|" .. tostring(listingPrice or "") .. "|" .. contextKey
    local now = type(GetGameTimeMilliseconds) == "function" and GetGameTimeMilliseconds() or 0
    if tooltip._lgcmbLastKey == dedupKey and now - (tooltip._lgcmbLastLinkTime or 0) < 200 then
        return
    end
    tooltip._lgcmbLastKey = dedupKey
    tooltip._lgcmbLastLinkTime = now

    local lines = self:_buildTooltipInfoLinesByLink(itemLink, stackCount, listingPrice, true, craftContext, source)

    if #lines == 0 then
        self:_hideOverlay()
        return
    end

    self:_showOverlayLines(lines, source, tooltip)
end

function bridge:_appendGamepadTooltipInfo(tooltip, bagId, slotIndex, source)
    local lines = self:_buildTooltipInfoLines(bagId, slotIndex)

    if #lines == 0 then
        self:_hideOverlay()
        return
    end

    self:_showOverlayLines(lines, source, tooltip)
end

-- Look up the purchase price (and stack count) of a trading house search result that
-- matches the given item link.  Returns totalPrice, stack2 (both may be nil on failure).
-- stackCount and sellerName are used as optional filters when provided; if itemLink
-- matching fails (e.g., link style mismatch) we fall back to returning data from the
-- first result whose item ID matches.
function bridge:_lookupTradingHouseListingPrice(itemLink, stackCount, sellerName)
    -- GetTradingHouseSearchResultItemInfo(i) →
    --   icon, itemName, displayQuality, stackCount, sellerName, timeRemaining, purchasePrice, currencyType, uid
    -- GetTradingHouseSearchResultItemLink(i) → itemLink
    local getInfoFn = type(GetTradingHouseSearchResultItemInfo) == "function"
                      and GetTradingHouseSearchResultItemInfo
                   or type(GetGuildStoreSearchResultItemInfo) == "function"
                      and GetGuildStoreSearchResultItemInfo
                   or nil
    local getLinkFn = type(GetTradingHouseSearchResultItemLink) == "function"
                      and GetTradingHouseSearchResultItemLink
                   or type(GetGuildStoreSearchResultItemLink) == "function"
                      and GetGuildStoreSearchResultItemLink
                   or nil

    if not getInfoFn then
        LogTrace("lookup: no item-info API found")
        return nil, nil
    end

    -- Extract the numeric item-type ID from a link string for fuzzy fallback.
    local function itemIdFromLink(link)
        if type(link) ~= "string" then return nil end
        return link:match("|H%d+:item:(%d+):")
    end
    local targetId = itemIdFromLink(itemLink)

    -- APPROACH 1: Gamepad TH browse list — read DIRECTLY from scroll list data entries.
    -- ESO stores itemLink, stackCount, purchasePrice in each entry's data table.
    -- This is reliable even when GetTradingHouseSearchResultItemLink is unavailable.
    -- We also verify the link matches before trusting the data.
    if type(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS) == "table" then
        local scene = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS
        local list = scene.itemList or scene.list or scene.parametricList
                  or (scene.categoryList and scene.categoryList.list)
        if list then
            local selectedData = nil
            if type(list.GetTargetData) == "function" then
                local ok2, d2 = pcall(function() return list:GetTargetData() end)
                if ok2 then selectedData = d2 end
            end
            if not selectedData and type(ZO_ScrollList_GetSelectedData) == "function" then
                local ok2, d2 = pcall(ZO_ScrollList_GetSelectedData, list)
                if ok2 and type(d2) == "table" then selectedData = d2 end
            end
            if selectedData then
                -- Try to read all fields directly from data (most reliable path).
                -- ESO TH browse result entries contain: itemLink, stackCount, purchasePrice.
                local dataLink = selectedData.itemLink or selectedData.link
                local dataSc   = selectedData.stackCount or selectedData.count
                local dataPrice = selectedData.purchasePrice

                if type(dataLink) == "string" and dataLink:find("|H") and dataLink == itemLink
                   and type(dataSc) == "number" and type(dataPrice) == "number" then
                    LogTrace("lookup: A1 from data fields sc=" .. tostring(dataSc) .. " price=" .. tostring(dataPrice))
                    return dataPrice, dataSc
                end

                -- Fallback: use slotIndex + getInfoFn, verified via getLinkFn or data.itemLink.
                local slotIndex = selectedData.slotIndex or selectedData.index or selectedData.slot
                if type(slotIndex) == "number" then
                    local slotLink = nil
                    if getLinkFn then
                        local okL, l = pcall(getLinkFn, slotIndex)
                        if okL then slotLink = l end
                    elseif type(dataLink) == "string" and dataLink:find("|H") then
                        slotLink = dataLink  -- use data.itemLink as verification source
                    end
                    local linkMatches = (slotLink == itemLink)
                    LogTrace("lookup: A1 slot=" .. tostring(slotIndex)
                        .. " slotLink=" .. tostring(slotLink and slotLink:sub(1,30) or "nil")
                        .. " match=" .. tostring(linkMatches))
                    -- Trust the scroll list's current selection: GetTargetData() is up-to-date
                    -- when LayoutItem fires (scene updates list selection before calling LayoutItem).
                    -- Same-type listings share itemLink, so link-matching is unreliable;
                    -- slotIndex uniquely identifies a listing and getInfoFn gives its exact data.
                    local ok2, _, _, _, sc, _, _, totalPrice = pcall(getInfoFn, slotIndex)
                    if ok2 and type(totalPrice) == "number" then
                        LogTrace("lookup: A1 result sc=" .. tostring(sc)
                            .. " price=" .. tostring(totalPrice)
                            .. " linkVerified=" .. tostring(linkMatches))
                        return totalPrice, sc
                    end
                    -- getInfoFn failed — fall through to scan.
                else
                    if self.debugVerbose then
                        local keys = ""
                        for k, _ in pairs(selectedData) do keys = keys .. tostring(k) .. " " end
                        LogTrace("lookup: A1 data keys=" .. keys:sub(1, 120))
                    end
                end
            else
                LogTrace("lookup: GAMEPAD_TH_BROWSE list=" .. tostring(list)
                    .. " ZO_SL_fn=" .. tostring(type(ZO_ScrollList_GetSelectedData) == "function"))
            end
        else
            LogTrace("lookup: GAMEPAD_TH_BROWSE no list (itemList=" .. tostring(scene.itemList)
                .. " list=" .. tostring(scene.list)
                .. " parametricList=" .. tostring(scene.parametricList) .. ")")
        end
    end

    -- APPROACH 2: Walk all visible scroll-list entries and find one matching itemLink.
    -- This works even without GetTradingHouseSearchResultItemLink by reading data.itemLink
    -- directly from each entry.  Falls back to getInfoFn scan when data fields are absent.
    if type(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS) == "table" then
        local scene = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS
        local list = scene.itemList or scene.list or scene.parametricList
                  or (scene.categoryList and scene.categoryList.list)
        -- ZO_ScrollList exposes the underlying data array via .data (keyboard)
        -- or via iteration helpers.  Try to iterate all entries.
        if list then
            local allData = nil
            -- ZO_ScrollList stores scroll data in list.scrollControl.data or .data arrays
            local scrollCtrl = type(list.GetScrollControl) == "function" and list:GetScrollControl() or list
            if type(scrollCtrl) == "table" then
                allData = scrollCtrl.data or scrollCtrl.scrollData
            end
            if type(allData) == "table" then
                for _, entry in ipairs(allData) do
                    local ed = type(entry) == "table" and (entry.data or entry) or nil
                    if type(ed) == "table" then
                        local eLink  = ed.itemLink or ed.link
                        local eSc    = ed.stackCount or ed.count
                        local ePrice = ed.purchasePrice
                        if type(eLink) == "string" and eLink == itemLink
                           and type(eSc) == "number" and type(ePrice) == "number" then
                            LogTrace("lookup: A2 scrollData match sc=" .. tostring(eSc)
                                .. " price=" .. tostring(ePrice))
                            return ePrice, eSc
                        end
                    end
                end
            end
        end
    end

    -- APPROACH 3: Scan results via getInfoFn iteration (requires getLinkFn to match correctly).
    -- Without getLinkFn this can only return the first result, so skip if no link function.
    if not getLinkFn then
        LogTrace("lookup: no linkFn, skipping scan (would return wrong item)")
        return nil, nil
    end

    local fallbackPrice, fallbackStack = nil, nil

    for i = 1, 200 do
        local okInfo, _, _, _, sc, seller2, _, totalPrice = pcall(getInfoFn, i)
        if not okInfo or type(totalPrice) ~= "number" then break end

        local passFilters = (not sellerName or seller2 == sellerName)
            and (not stackCount or not (type(stackCount) == "number") or sc == stackCount)
        if passFilters then
            local okLink, link2 = pcall(getLinkFn, i)
            if self.debugVerbose and i <= 3 then
                LogTrace("lookup[" .. i .. "]: link2=" .. tostring(link2):sub(1,40)
                    .. " match=" .. tostring(okLink and link2 == itemLink))
            end
            if okLink and link2 == itemLink then
                return totalPrice, sc   -- exact match
            end
            if targetId and fallbackPrice == nil and itemIdFromLink(link2) == targetId then
                fallbackPrice, fallbackStack = totalPrice, sc
            end
        end
    end

    if fallbackPrice == nil then
        LogTrace("lookup: A3 scan done, no match")
    end

    return fallbackPrice, fallbackStack
end

function bridge:_hookTooltipPrice()
    if self._tooltipPriceHooked then
        return true
    end

    LogTrace("Attempting to hook tooltip price...")

    if type(GAMEPAD_TOOLTIPS) ~= "table" then
        LogTrace("GAMEPAD_TOOLTIPS not available (type: " .. type(GAMEPAD_TOOLTIPS) .. ")")
        return false
    end

    if type(GAMEPAD_TOOLTIPS.GetTooltip) ~= "function" then
        LogTrace("GAMEPAD_TOOLTIPS.GetTooltip not available")
        return false
    end

    local tooltipTypes = {
        GAMEPAD_LEFT_TOOLTIP,
        GAMEPAD_RIGHT_TOOLTIP,
        GAMEPAD_MOVABLE_TOOLTIP,
    }

    local hookedAny = false
    for i = 1, #tooltipTypes do
        local tooltipType = tooltipTypes[i]
        LogTrace("Checking tooltip type " .. tostring(i) .. ": " .. tostring(tooltipType))

        local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(tooltipType)
        LogTrace("Got tooltip: " .. type(tooltip))

        if tooltip ~= nil then
            if tooltipType == GAMEPAD_RIGHT_TOOLTIP
                and type(tooltip.SetHidden) == "function"
                and not tooltip._lgcmbOverlayHideHooked
            then
                ZO_PostHook(tooltip, "SetHidden", function(ctrl, hidden)
                    if hidden then
                        bridge:_hideOverlay()
                        LogTrace("Overlay hidden because GAMEPAD_RIGHT_TOOLTIP was hidden")
                    end
                end)
                tooltip._lgcmbOverlayHideHooked = true
                hookedAny = true
                LogTrace("Hooked GAMEPAD_RIGHT_TOOLTIP hide for overlay cleanup")
            end

            -- LayoutBagItem: append after the base tooltip is fully laid out.
            if type(tooltip.LayoutBagItem) == "function" and not tooltip._lgcmbBagHooksInstalled then
                ZO_PostHook(tooltip, "LayoutBagItem", function(ctrl, bagId, slotIndex, ...)
                    if not bridge.enabled then return end
                    ctrl._lgcmbLastKey = nil
                    bridge:_appendGamepadTooltipInfo(ctrl, bagId, slotIndex, "bag")
                end)
                tooltip._lgcmbBagHooksInstalled = true
                hookedAny = true
                LogDebug("Hooked LayoutBagItem post-layout on tooltip " .. tostring(i))
            end

            -- LayoutFurnishingCraftingResult: append after the crafting result tooltip is laid out.
            if type(tooltip.LayoutFurnishingCraftingResult) == "function" and not tooltip._lgcmbFurnCraftHooked then
                ZO_PreHook(tooltip, "LayoutFurnishingCraftingResult", function(ctrl, ...)
                    local args = {...}
                    if type(args[1]) == "number" then
                        bridge._pendingCraftingContext = bridge:_makeCraftContext(args[1], args[2], args[3], args[4], args[5])
                    else
                        bridge._pendingCraftingContext = nil
                    end
                end)
                ZO_PostHook(tooltip, "LayoutFurnishingCraftingResult", function(ctrl, ...)
                    if not bridge.enabled then return end
                    bridge._templateCraftingOverlayActive = true
                    if not bridge:_shouldShowTemplateCraftingOverlay() then
                        bridge:_hideOverlay()
                        return
                    end
                    local furnCraftCtx = bridge:_resolveCurrentFurnishingCraftContext(ZO_GamepadSmithingCreation, bridge._pendingCraftingContext)
                    bridge._pendingCraftingContext = furnCraftCtx
                    local link = bridge:_resolveCurrentFurnishingLink(ZO_GamepadSmithingCreation)
                    if type(link) == "string" and link:find("|H") then
                        ctrl._lgcmbLastKey = nil
                        bridge:_appendGamepadTooltipInfoByLink(ctrl, link, nil, nil, "furncraft", furnCraftCtx)
                    end
                end)
                tooltip._lgcmbFurnCraftHooked = true
                hookedAny = true
                LogDebug("Hooked LayoutFurnishingCraftingResult on tooltip " .. tostring(i))
            end

            if type(tooltip.LayoutItemLink) == "function" and not tooltip._lgcmbCraftItemLinkHooked then
                ZO_PostHook(tooltip, "LayoutItemLink", function(ctrl, itemLink, ...)
                    if not bridge.enabled or not bridge._craftingStationActive then return end
                    if not bridge:_shouldShowTemplateCraftingOverlay() then
                        bridge:_hideOverlay()
                        return
                    end

                    if IsValidItemLink(itemLink) then
                        local furnCraftCtx = bridge:_resolveCurrentFurnishingCraftContext(ZO_GamepadSmithingCreation, bridge._pendingCraftingContext)
                        bridge._pendingCraftingContext = furnCraftCtx
                        ctrl._lgcmbLastKey = nil
                        bridge:_appendGamepadTooltipInfoByLink(ctrl, itemLink, nil, nil, "furncraft", furnCraftCtx)
                    end
                end)
                tooltip._lgcmbCraftItemLinkHooked = true
                hookedAny = true
                LogDebug("Hooked LayoutItemLink for crafting tooltips on tooltip " .. tostring(i))
            end
        end
    end

    if type(GAMEPAD_INVENTORY) == "table"
        and type(GAMEPAD_INVENTORY.UpdateCategoryLeftTooltip) == "function"
        and not GAMEPAD_INVENTORY._lgcmbTooltipCategoryWrapped
    then
        local updateCategoryLeftTooltip = GAMEPAD_INVENTORY.UpdateCategoryLeftTooltip
        GAMEPAD_INVENTORY.UpdateCategoryLeftTooltip = function(control, ...)
            local result = updateCategoryLeftTooltip(control, ...)
            if control and control.selectedEquipSlot and type(GAMEPAD_TOOLTIPS.LayoutBagItem) == "function" then
                GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, BAG_WORN, control.selectedEquipSlot)
                LogTrace("Refreshed left tooltip for selected equipped slot")
            end
            return result
        end
        GAMEPAD_INVENTORY._lgcmbTooltipCategoryWrapped = true
        hookedAny = true
        LogTrace("Hooked GAMEPAD_INVENTORY.UpdateCategoryLeftTooltip")
    end

    if hookedAny then
        self._tooltipPriceHooked = true
        LogDebug("Tooltip info hook registered successfully")
        return true
    end

    LogTrace("No tooltips were hooked")
    return false
end

-- Hook crafting station result tooltips in gamepad mode.
-- Follows the same pattern as TTC (SecurePostHook on the crafting singleton,
-- get the item link from crafting API, append to the active gamepad tooltip).
-- This handles cases where the crafting system calls LayoutFurnishingCraftingResult
-- (no item link in args) instead of LayoutItemLink.
function bridge:_hookCraftingTooltips()
    if self._craftingTooltipsHooked then return true end
    if type(SecurePostHook) ~= "function" then return false end
    if type(GAMEPAD_TOOLTIPS) ~= "table" then return false end

    local function appendToActiveCraftingTooltip(link, craftContext)
        if not bridge.enabled then return end
        if type(link) ~= "string" or not link:find("|H") then return end
        if not bridge:_shouldShowTemplateCraftingOverlay() then return end
        -- Try tooltip types in order: LEFT is the typical crafting preview tooltip
        local types = {GAMEPAD_LEFT_TOOLTIP, GAMEPAD_RIGHT_TOOLTIP, GAMEPAD_MOVABLE_TOOLTIP}
        for _, tType in ipairs(types) do
            if type(tType) == "number" then
                local tt = type(GAMEPAD_TOOLTIPS.GetTooltip) == "function"
                    and GAMEPAD_TOOLTIPS:GetTooltip(tType) or nil
                if tt ~= nil then
                    bridge:_appendGamepadTooltipInfoByLink(tt, link, nil, nil, "furncraft", craftContext)
                    return
                end
            end
        end
    end

    local hooked = false

    -- CraftStore pattern: the smithing result tooltip receives full context via
    -- SetPendingSmithingItem(pid, mid, mq, sid, tid). This is reliable for both
    -- regular smithing and furnishing templates.
    local function hookSetPendingSmithingItem(target, targetName)
        if type(target) ~= "table" then
            return false
        end
        if type(target.SetPendingSmithingItem) ~= "function" then
            return false
        end
        if target._lgcmbSetPendingHooked then
            return false
        end

        ZO_PreHook(target, "SetPendingSmithingItem", function(_, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
            local link = bridge:_resolveSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
            bridge._pendingCraftingLink = link
            bridge._pendingCraftingContext = bridge:_makeCraftContext(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
            bridge._templateCraftingOverlayActive = IsValidItemLink(bridge._pendingCraftingLink)
            LogDebug("SetPendingSmithingItem PRE (" .. tostring(targetName) .. "): pid=" .. tostring(patternIndex)
                .. " mid=" .. tostring(materialIndex)
                .. " qty=" .. tostring(materialQuantity)
                .. " link=" .. tostring(bridge._pendingCraftingLink):sub(1, 45))
        end)

        SecurePostHook(target, "SetPendingSmithingItem", function(_, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
            if not bridge.enabled then return end
            local link = bridge._pendingCraftingLink
            if not IsValidItemLink(link) then
                local resolved = bridge:_resolveSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
                if IsValidItemLink(resolved) then
                    link = resolved
                    bridge._pendingCraftingLink = resolved
                end
            end
            if IsValidItemLink(link) then
                appendToActiveCraftingTooltip(link, bridge._pendingCraftingContext)
            end
        end)

        target._lgcmbSetPendingHooked = true
        LogDebug("Hooked SetPendingSmithingItem on " .. tostring(targetName))
        return true
    end

    do
        local candidates = {
            { _G["ZO_SmithingTopLevelCreationPanelResultTooltip"], "ZO_SmithingTopLevelCreationPanelResultTooltip" },
            { _G["ZO_GamepadSmithingTopLevelCreationPanelResultTooltip"], "ZO_GamepadSmithingTopLevelCreationPanelResultTooltip" },
            { _G["ZO_GamepadSmithingTopLevelResultTooltip"], "ZO_GamepadSmithingTopLevelResultTooltip" },
        }
        for i = 1, #candidates do
            if hookSetPendingSmithingItem(candidates[i][1], candidates[i][2]) then
                hooked = true
            end
        end
    end

    -- Smithing / clothier / woodworking creation (keyboard class; fires in gamepad mode only if
    -- ZO_GamepadSmithingCreation does NOT override SetupResultTooltip, so kept as fallback).
    -- PRE-hook caches the link so LayoutFurnishingCraftingResult (hooked in _hookTooltipPrice)
    -- can pick it up before the tooltip is laid out.
    if type(ZO_SmithingCreation) == "table"
        and type(ZO_SmithingCreation.SetupResultTooltip) == "function"
    then
        ZO_PreHook(ZO_SmithingCreation, "SetupResultTooltip",
            function(_, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
                bridge._pendingCraftingLink = bridge:_resolveSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
                bridge._pendingCraftingContext = bridge:_makeCraftContext(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
            end)
        SecurePostHook(ZO_SmithingCreation, "SetupResultTooltip",
            function(_, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
                if not (type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode()) then return end
                local link = bridge._pendingCraftingLink
                appendToActiveCraftingTooltip(link, bridge._pendingCraftingContext)
            end)
        hooked = true
        LogDebug("Hooked ZO_SmithingCreation.SetupResultTooltip")
    end

    -- Gamepad smithing creation — overrides SetupResultTooltip and uses its own
    -- resultTooltip.tip floating control instead of the standard GAMEPAD_TOOLTIPS pool.
    -- PRE-hook caches the link (for LayoutFurnishingCraftingResult top-inject path).
    -- POST-hook appends directly to resultTooltip.tip as a second path.
    if type(ZO_GamepadSmithingCreation) == "table"
        and type(ZO_GamepadSmithingCreation.SetupResultTooltip) == "function"
    then
        ZO_PreHook(ZO_GamepadSmithingCreation, "SetupResultTooltip",
            function(_, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
                bridge._pendingCraftingLink = bridge:_resolveSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
                bridge._pendingCraftingContext = bridge:_makeCraftContext(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
                if not IsValidItemLink(bridge._pendingCraftingLink) then
                    bridge._pendingCraftingLink = bridge:_resolveCurrentFurnishingLink(ZO_GamepadSmithingCreation)
                end
                bridge._templateCraftingOverlayActive = IsValidItemLink(bridge._pendingCraftingLink)
            end)
        SecurePostHook(ZO_GamepadSmithingCreation, "SetupResultTooltip",
            function(selfArg, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
                if not bridge.enabled then return end
                local link = bridge._pendingCraftingLink
                if not IsValidItemLink(link) then
                    link = bridge:_resolveCurrentFurnishingLink(selfArg)
                    bridge._pendingCraftingLink = link
                end
                bridge._templateCraftingOverlayActive = IsValidItemLink(link)
                if type(link) ~= "string" or not link:find("|H") then
                    return
                end
                -- Also try the dedicated resultTooltip panel used by gamepad smithing.
                local tip = selfArg and selfArg.resultTooltip and selfArg.resultTooltip.tip
                if tip then
                    bridge:_appendGamepadTooltipInfoByLink(tip, link, nil, nil, "furncraft", bridge._pendingCraftingContext)
                end
            end)
        hooked = true
        LogDebug("Hooked ZO_GamepadSmithingCreation.SetupResultTooltip")
    end

    -- Provisioner (food/drink recipes)
    if type(ZO_Provisioner) == "table"
        and type(ZO_Provisioner.RefreshRecipeDetails) == "function"
    then
        SecurePostHook(ZO_Provisioner, "RefreshRecipeDetails", function(ctrl)
            if not (type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode()) then return end
            local recipeListIndex = type(ctrl.GetSelectedRecipeListIndex) == "function" and ctrl:GetSelectedRecipeListIndex() or nil
            local recipeIndex     = type(ctrl.GetSelectedRecipeIndex)     == "function" and ctrl:GetSelectedRecipeIndex()     or nil
            if recipeListIndex and recipeIndex then
                local link = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
                appendToActiveCraftingTooltip(link, bridge:_makeRecipeCraftContext(recipeListIndex, recipeIndex))
            end
        end)
        hooked = true
        LogDebug("Hooked ZO_Provisioner.RefreshRecipeDetails")
    end

    -- Gamepad provisioner furnishing templates use RefreshRecipeDetails(selectedData)
    -- and populate the tooltip via resultTooltip.tip:SetProvisionerResultItem(...).
    if type(ZO_GamepadProvisioner) == "table"
        and type(ZO_GamepadProvisioner.RefreshRecipeDetails) == "function"
    then
        SecurePostHook(ZO_GamepadProvisioner, "RefreshRecipeDetails", function(selfArg, selectedData)
            if not bridge.enabled then return end
            if not (type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode()) then return end

            local isFurnishingTemplate = type(selectedData) == "table"
                and ((type(PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING) == "number"
                    and selectedData.specialIngredientType == PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING)
                    or (type(PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING) == "number"
                        and selfArg.filterType == PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING))
            bridge._templateCraftingOverlayActive = isFurnishingTemplate

            if type(selectedData) ~= "table" then
                bridge:_hideOverlay()
                return
            end

            if not isFurnishingTemplate then
                bridge:_hideOverlay()
                return
            end

            local recipeListIndex = selectedData.recipeListIndex
            local recipeIndex = selectedData.recipeIndex
            if recipeListIndex == nil and type(selfArg.GetRecipeData) == "function" then
                local ok, recipeData = pcall(selfArg.GetRecipeData, selfArg)
                if ok and type(recipeData) == "table" then
                    recipeListIndex = recipeData.recipeListIndex or recipeListIndex
                    recipeIndex = recipeData.recipeIndex or recipeIndex
                end
            end

            if recipeListIndex == nil or recipeIndex == nil or type(GetRecipeResultItemLink) ~= "function" then
                return
            end

            local ok, link = pcall(GetRecipeResultItemLink, recipeListIndex, recipeIndex)
            if not ok or not IsValidItemLink(link) then
                return
            end

            local tip = selfArg and selfArg.resultTooltip and selfArg.resultTooltip.tip
            if tip then
                bridge:_appendGamepadTooltipInfoByLink(
                    tip,
                    link,
                    nil,
                    nil,
                    "furncraft",
                    bridge:_makeRecipeCraftContext(recipeListIndex, recipeIndex, selectedData)
                )
            else
                appendToActiveCraftingTooltip(link, bridge:_makeRecipeCraftContext(recipeListIndex, recipeIndex, selectedData))
            end
        end)
        hooked = true
        LogDebug("Hooked ZO_GamepadProvisioner.RefreshRecipeDetails")
    end

    -- Enchanting
    if type(ZO_Enchanting) == "table"
        and type(ZO_Enchanting.UpdateTooltip) == "function"
    then
        SecurePostHook(ZO_Enchanting, "UpdateTooltip", function()
            if not (type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode()) then return end
            local link = type(ENCHANTING) == "table"
                and type(ENCHANTING.GetResultItemLink) == "function"
                and ENCHANTING:GetResultItemLink() or nil
            appendToActiveCraftingTooltip(link, { station = "enchanting" })
        end)
        hooked = true
        LogDebug("Hooked ZO_Enchanting.UpdateTooltip")
    end

    -- Alchemy
    if type(ZO_Alchemy) == "table"
        and type(ZO_Alchemy.UpdateTooltip) == "function"
    then
        SecurePostHook(ZO_Alchemy, "UpdateTooltip", function()
            if not (type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode()) then return end
            local link = type(ALCHEMY) == "table"
                and type(ALCHEMY.GetResultItemLink) == "function"
                and ALCHEMY:GetResultItemLink() or nil
            appendToActiveCraftingTooltip(link)
        end)
        hooked = true
        LogDebug("Hooked ZO_Alchemy.UpdateTooltip")
    end

    if hooked then
        self._craftingTooltipsHooked = true
        return true
    end
    return false
end

-- Hook the trading-house browse-results tooltip in gamepad mode.
-- The reliable hook point is the tooltip's own LayoutGuildStoreSearchResult method,
-- which is attached dynamically when the gamepad trading house UI is opened.
function bridge:_hookTradingHouseTooltip()
    if self._tradingHouseTooltipHooked then
        return true
    end

    if type(GAMEPAD_TOOLTIPS) ~= "table" then return false end
    if type(GAMEPAD_TOOLTIPS.GetTooltip) ~= "function" then return false end

    local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP)
    if not tooltip then return false end
    if type(tooltip.LayoutGuildStoreSearchResult) ~= "function" then return false end
    if tooltip._lgcmbTradingHouseLayoutHooked then
        self._tradingHouseTooltipHooked = true
        return true
    end

    ZO_PreHook(tooltip, "LayoutGuildStoreSearchResult", function(ctrl, itemLink, stackCount, sellerName, ...)
        if not bridge.enabled then
            return
        end

        if type(itemLink) ~= "string" or not itemLink:find("|H") then
            return
        end

        local listingPrice, resolvedStackCount = bridge:_lookupTradingHouseListingPrice(itemLink, stackCount, sellerName)
        ctrl._lgcmbPendingInfo = {
            link = itemLink,
            stackCount = resolvedStackCount or stackCount,
            listingPrice = listingPrice,
        }
    end)

    ZO_PostHook(tooltip, "LayoutGuildStoreSearchResult", function(ctrl, itemLink, stackCount, sellerName, ...)
        if not bridge.enabled then return end

        if type(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS) == "table" then
            local list = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS.itemList
                or GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS.list
                or GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS.parametricList
            bridge._overlayAnchorControl = SafeGetTargetControl(list)
        end

        if type(itemLink) ~= "string" or not itemLink:find("|H") then
            bridge:_hideOverlay()
            LogDebug("TH LayoutGuildStoreSearchResult: no valid itemLink")
            return
        end

        ctrl._lgcmbLastKey = nil
        local pendingInfo = ctrl._lgcmbPendingInfo
        local effectiveStackCount = pendingInfo and pendingInfo.stackCount or stackCount
        local listingPrice = pendingInfo and pendingInfo.listingPrice

        if (type(listingPrice) ~= "number" or listingPrice <= 0) and type(itemLink) == "string" and itemLink:find("|H") then
            local resolvedPrice, resolvedStackCount = bridge:_lookupTradingHouseListingPrice(itemLink, effectiveStackCount, sellerName)
            if type(resolvedPrice) == "number" and resolvedPrice > 0 then
                listingPrice = resolvedPrice
            end
            if type(resolvedStackCount) == "number" and resolvedStackCount > 0 then
                effectiveStackCount = resolvedStackCount
            end
        end

        bridge:_appendGamepadTooltipInfoByLink(ctrl, itemLink, effectiveStackCount, listingPrice, "guildstore")

        LogDebug(string.format("TH layout: sc=%s price=%s seller=%s link=%s",
            tostring(effectiveStackCount), tostring(listingPrice), tostring(sellerName), tostring(itemLink):sub(1, 30)))
    end)

    tooltip._lgcmbTradingHouseLayoutHooked = true

    self._tradingHouseTooltipHooked = true
    LogDebug("Hooked LayoutGuildStoreSearchResult on gamepad trading house tooltip")
    return true
end

function bridge:_scheduleTooltipPriceHookRetry()
    if self._tooltipPriceHooked then
        return
    end

    if type(zo_callLater) == "function" then
        LogTrace("Scheduling tooltip price hook retry in 2500ms")
        zo_callLater(function()
            LogTrace("Retrying tooltip price hook...")
            bridge:_hookTooltipPrice()
        end, 2500)
    end
end

function bridge:_initializeSlashCommands()
    if self._slashCommandsRegistered then
        return
    end

    if type(SLASH_COMMANDS) ~= "table" then
        return
    end

    local function PrintHelp()
        if type(d) ~= "function" then
            return
        end
        d(string.format("[%s] /lgcmb status", MAJOR))
        d(string.format("[%s] /lgcmb on|off", MAJOR))
        d(string.format("[%s] /lgcmb debug on|off", MAJOR))
        d(string.format("[%s] /lgcmb verbose on|off", MAJOR))
        d(string.format("[%s] /lgcmb log [count]", MAJOR))
        d(string.format("[%s] /lgcmb clearlog", MAJOR))
    end

    SLASH_COMMANDS["/lgcmb"] = function(text)
        local cmd = string.lower(TrimString(text or ""))
        if cmd == "" or cmd == "help" then
            PrintHelp()
            return
        end

        if cmd == "status" then
            self:DumpRuntimeStatus()
            return
        end

        if cmd == "on" then
            self:SetEnabled(true)
            return
        end
        if cmd == "off" then
            self:SetEnabled(false)
            return
        end
        if cmd == "debug on" then
            self:SetDebugEnabled(true)
            return
        end
        if cmd == "debug off" then
            self:SetDebugEnabled(false)
            return
        end
        if cmd == "verbose on" then
            self:SetDebugVerbose(true)
            return
        end
        if cmd == "verbose off" then
            self:SetDebugVerbose(false)
            return
        end
        if cmd == "clearlog" then
            self:ClearDebugLog()
            return
        end

        local logCount = cmd:match("^log%s+(%d+)$")
        if cmd == "log" or logCount then
            self:DumpDebugLog(tonumber(logCount) or 40)
            return
        end

        PrintHelp()
    end

    self._slashCommandsRegistered = true
    LogTrace("Slash command /lgcmb registered")
end

function bridge:_initializeSettingsPanel()
    if self._settingsPanelRegistered then
        return
    end

    local lam = _G.LibAddonMenu2 or _G.LibAddonMenu
    if type(lam) ~= "table" then
        return
    end
    if type(lam.RegisterAddonPanel) ~= "function" or type(lam.RegisterOptionControls) ~= "function" then
        return
    end

    local panelData = {
        type = "panel",
        name = MAJOR,
        displayName = MAJOR,
        author = "Azmail",
        version = ADDON_VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "description",
            text = "Bridge for LibCustomMenu context actions in gamepad mode.",
        },
        {
            type = "checkbox",
            name = "Enable bridge",
            getFunc = function()
                return self.enabled
            end,
            setFunc = function(value)
                self:SetEnabled(value)
            end,
            default = DEFAULTS.enabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Debug mode",
            getFunc = function()
                return self.debug
            end,
            setFunc = function(value)
                self:SetDebugEnabled(value)
            end,
            default = DEFAULTS.debug,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Verbose debug",
            getFunc = function()
                return self.debugVerbose
            end,
            setFunc = function(value)
                self:SetDebugVerbose(value)
            end,
            default = DEFAULTS.debugVerbose,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show TTC price in gamepad overlay",
            getFunc = function()
                return self:_shouldShowTtcTooltipPrice()
            end,
            setFunc = function(value)
                self:SetShowTtcPriceInTooltip(value)
            end,
            default = DEFAULTS.showTtcPriceInTooltip,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show expanded TTC details",
            getFunc = function()
                return self:_shouldShowTtcTooltipDetails()
            end,
            setFunc = function(value)
                self:SetShowTtcPriceDetailsInTooltip(value)
            end,
            disabled = function()
                return not self:_shouldShowTtcTooltipPrice()
            end,
            default = DEFAULTS.showTtcPriceDetailsInTooltip,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show junk status in gamepad overlay",
            getFunc = function()
                return self:_shouldShowJunkStatusInTooltip()
            end,
            setFunc = function(value)
                self:SetShowJunkStatusInTooltip(value)
            end,
            default = DEFAULTS.showJunkStatusInTooltip,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show vendor price in gamepad overlay",
            getFunc = function()
                return self:_shouldShowVendorPriceInTooltip()
            end,
            setFunc = function(value)
                self:SetShowVendorPriceInTooltip(value)
            end,
            default = DEFAULTS.showVendorPriceInTooltip,
            width = "full",
        },
        {
            type = "button",
            name = "Print debug log to chat",
            func = function()
                self:DumpDebugLog(60)
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Clear debug log",
            func = function()
                self:ClearDebugLog()
            end,
            width = "half",
        },
    }

    lam:RegisterAddonPanel(MAJOR .. "_Settings", panelData)
    lam:RegisterOptionControls(MAJOR .. "_Settings", optionsData)
    self._settingsPanelRegistered = true
    LogTrace("Settings panel registered in LibAddonMenu")
end

function bridge:_captureMenuEntry(capture, labelValue, callback, itemType, enabled)
    local itemTypeValue = itemType or MENU_ADD_OPTION_LABEL
    if itemTypeValue == MENU_ADD_OPTION_HEADER then
        return #capture.entries
    end

    enabled = EvaluateValue(enabled, ZO_Menu, capture.contextControl)
    if enabled == false then
        return #capture.entries
    end

    local label = ResolveLabel(labelValue, capture.contextControl)
    if not label or IsDividerLabel(label) then
        return #capture.entries
    end

    if itemTypeValue == MENU_ADD_OPTION_CHECKBOX then
        label = "[ ] " .. label
    end

    if type(callback) ~= "function" then
        return #capture.entries
    end

    capture.entries[#capture.entries + 1] = {
        kind = "action",
        label = label,
        callback = function()
            SafeCallCallbackWithContext(callback, capture.contextControl)
        end,
    }
    LogTrace(string.format("Captured action: %s", tostring(label)))

    return #capture.entries
end

function bridge:_captureSubMenuEntries(capture, submenuLabelValue, entries, submenuCallback)
    local submenuLabel = ResolveLabel(submenuLabelValue, capture.contextControl)
    if not submenuLabel then
        LogTrace("Skipped submenu with empty label")
        return #capture.entries
    end

    local submenuEntries = entries
    if type(submenuEntries) == "function" then
        submenuEntries = EvaluateValue(submenuEntries, ZO_Menu, capture.contextControl)
    end

    if type(submenuEntries) ~= "table" then
        LogTrace(string.format("Skipped submenu '%s': entries is %s", tostring(submenuLabel), type(submenuEntries)))
        return #capture.entries
    end

    local submenuActionEntries = {}

    for i = 1, #submenuEntries do
        local entry = submenuEntries[i]
        if type(entry) == "table" then
            local visible = EvaluateValue(entry.visible, ZO_Menu, capture.contextControl)
            if visible ~= false then
                local disabled = EvaluateValue(entry.disabled or false, ZO_Menu, capture.contextControl)
                if not disabled then
                    local itemTypeValue = entry.itemType or MENU_ADD_OPTION_LABEL
                    if itemTypeValue ~= MENU_ADD_OPTION_HEADER then
                        local childLabel = ResolveLabel(entry.label or entry.name or entry[1], capture.contextControl)
                        if childLabel and not IsDividerLabel(childLabel) then
                            if itemTypeValue == MENU_ADD_OPTION_CHECKBOX then
                                local checked = EvaluateValue(entry.checked or false, ZO_Menu, capture.contextControl)
                                childLabel = string.format("[%s] %s", checked and "x" or " ", childLabel)
                            end

                            local callback = entry.callback or entry.func or entry[2]
                            if type(callback) == "function" then
                                submenuActionEntries[#submenuActionEntries + 1] = {
                                    label = childLabel,
                                    callback = function()
                                        SafeCallCallbackWithContext(callback, capture.contextControl)
                                    end,
                                }
                            end
                        end
                    end
                end
            end
        end
    end

    if #submenuActionEntries == 0 then
        LogTrace(string.format("Skipped submenu '%s': no visible actions", submenuLabel))
        return #capture.entries
    end

    capture.entries[#capture.entries + 1] = {
        kind = "submenu",
        label = submenuLabel,
        entries = submenuActionEntries,
        callback = type(submenuCallback) == "function" and function()
            SafeCallCallbackWithContext(submenuCallback, capture.contextControl)
        end or nil,
    }
    LogTrace(string.format("Captured submenu: %s (%d items)", submenuLabel, #submenuActionEntries))

    return #capture.entries
end

function bridge:_beginCapture(lcm)
    local capture = {
        entries = {},
        originals = {},
        contextControl = nil,
    }

    capture.originals.AddMenuItem = AddMenuItem
    capture.originals.AddCustomMenuItem = AddCustomMenuItem
    capture.originals.AddCustomSubMenuItem = AddCustomSubMenuItem
    capture.originals.AddCustomMenuTooltip = AddCustomMenuTooltip
    capture.originals.ShowMenu = ShowMenu
    capture.originals.ClearMenu = ClearMenu

    _G.AddMenuItem = function(mytext, myfunction, itemType, myFont, normalColor, highlightColor, itemYPad, horizontalAlignment, isHighlighted, onEnter, onExit, enabled)
        return bridge:_captureMenuEntry(capture, mytext, myfunction, itemType, enabled)
    end

    _G.AddCustomMenuItem = function(mytext, myfunction, itemType, myFont, normalColor, highlightColor, itemYPad, horizontalAlignment, isHighlighted, onEnter, onExit, enabled)
        return bridge:_captureMenuEntry(capture, mytext, myfunction, itemType, enabled)
    end

    _G.AddCustomSubMenuItem = function(mytext, entries, myfont, normalColor, highlightColor, itemYPad, callback)
        return bridge:_captureSubMenuEntries(capture, mytext, entries, callback)
    end

    _G.AddCustomMenuTooltip = function()
        return nil
    end

    _G.ShowMenu = function()
        return nil
    end

    _G.ClearMenu = function()
        return nil
    end

    if type(lcm) == "table" and type(lcm.AddMenuItem) == "function" then
        capture.originals.LibAddMenuItem = lcm.AddMenuItem
        lcm.AddMenuItem = function(...)
            return _G.AddMenuItem(...)
        end
    end

    return capture
end

function bridge:_endCapture(lcm, capture)
    if not capture or not capture.originals then
        return
    end

    _G.AddMenuItem = capture.originals.AddMenuItem
    _G.AddCustomMenuItem = capture.originals.AddCustomMenuItem
    _G.AddCustomSubMenuItem = capture.originals.AddCustomSubMenuItem
    _G.AddCustomMenuTooltip = capture.originals.AddCustomMenuTooltip
    _G.ShowMenu = capture.originals.ShowMenu
    _G.ClearMenu = capture.originals.ClearMenu

    if type(lcm) == "table" and capture.originals.LibAddMenuItem then
        lcm.AddMenuItem = capture.originals.LibAddMenuItem
    end
end

function bridge:_runContextCallbacks(lcm, inventorySlot, slotActions)
    if self._isCapturing then
        return {}
    end

    self._isCapturing = true
    local capture = self:_beginCapture(lcm)
    capture.contextControl = inventorySlot
    LogTrace("Context capture started")
    local originalGetSlotType = ZO_InventorySlot_GetType

    local originalContextMenuMode = slotActions and slotActions.m_contextMenuMode

    local ok, err = pcall(function()
        local early = tonumber(lcm.CATEGORY_EARLY)
        local late = tonumber(lcm.CATEGORY_LATE)
        if early == nil or late == nil then
            return
        end
        local contextMenuRegistry = lcm.contextMenuRegistry
        local hasFireCallbacks = type(contextMenuRegistry) == "table" and type(contextMenuRegistry.FireCallbacks) == "function"
        local summary, totalCallbacks = self:_summarizeContextRegistry()
        LogTrace(string.format("Context registry callbacks: total=%d (%s)", tonumber(totalCallbacks or 0), tostring(summary)))
        if type(ZO_InventorySlot_GetType) == "function" then
            local slotType = ZO_InventorySlot_GetType(inventorySlot)
            LogTrace(string.format("Slot type: %s", tostring(slotType)))
        end

        if type(originalGetSlotType) == "function" then
            ZO_InventorySlot_GetType = function(slot)
                local resolved = originalGetSlotType(slot)
                if slot ~= inventorySlot then
                    return resolved
                end

                local normalized = bridge:_resolveNormalizedSlotType(slot, resolved)
                if normalized ~= resolved then
                    LogTrace(string.format("Normalized slot type %s -> %s", tostring(resolved), tostring(normalized)))
                    return normalized
                end
                return resolved
            end
        end

        if slotActions then
            slotActions.m_contextMenuMode = true
        end

        if hasFireCallbacks then
            LogTrace("Running callbacks via LibCustomMenu contextMenuRegistry:FireCallbacks")
            for category = early, late do
                local callbackOk, callbackErr = pcall(contextMenuRegistry.FireCallbacks, contextMenuRegistry, category, inventorySlot, slotActions)
                if not callbackOk then
                    LogDebug(callbackErr)
                end
            end
        else
            LogTrace("Running callbacks via internal callback cache (fallback mode)")
            for category = early, late do
                local callbacks = self._contextCallbacks[category]
                if callbacks then
                    for i = 1, #callbacks do
                        local callbackData = callbacks[i]
                        if type(callbackData) == "table" and type(callbackData.func) == "function" then
                            local args = callbackData.args
                            local callbackOk, callbackErr

                            if args and #args > 0 then
                                local callArgs = {}
                                for argIndex = 1, #args do
                                    callArgs[#callArgs + 1] = args[argIndex]
                                end
                                callArgs[#callArgs + 1] = inventorySlot
                                callArgs[#callArgs + 1] = slotActions
                                callbackOk, callbackErr = pcall(callbackData.func, unpackArgs(callArgs))
                            else
                                callbackOk, callbackErr = pcall(callbackData.func, inventorySlot, slotActions)
                            end

                            if not callbackOk then
                                LogDebug(callbackErr)
                            end
                        end
                    end
                end
            end
        end

        if #capture.entries == 0 and totalCallbacks and totalCallbacks > 0 then
            local invoked = self:_invokeRawRegistryHandlers(lcm, inventorySlot, slotActions)
            LogTrace(string.format("Raw registry fallback invoked %d handlers", invoked))
        end
    end)

    if slotActions then
        slotActions.m_contextMenuMode = originalContextMenuMode
    end
    if type(originalGetSlotType) == "function" then
        ZO_InventorySlot_GetType = originalGetSlotType
    end

    self:_endCapture(lcm, capture)
    self._isCapturing = false

    if not ok then
        LogDebug(err)
    end

    LogTrace(string.format("Context capture finished with %d entries", #capture.entries))
    return capture.entries
end

function bridge:_ensureSubmenuDialog()
    if self._submenuDialogRegistered then
        return true
    end

    if type(ZO_Dialogs_RegisterCustomDialog) ~= "function" then
        return false
    end

    if type(GAMEPAD_DIALOGS) ~= "table" or GAMEPAD_DIALOGS.PARAMETRIC == nil then
        return false
    end

    local dialogName = self._submenuDialogName or (MAJOR .. "_SubmenuDialog")
    self._submenuDialogName = dialogName

    ZO_Dialogs_RegisterCustomDialog(dialogName, {
        canQueue = true,
        blockDirectionalInput = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
            allowRightStickPassThrough = true,
        },
        title = {
            text = function(dialog)
                local data = dialog and dialog.data
                local title = data and data.title
                if type(title) == "string" and title ~= "" then
                    return title
                end
                return SafeGetString(SI_GAMEPAD_SELECT_OPTION, "Select")
            end,
        },
        mainText = {
            text = function(dialog)
                local data = dialog and dialog.data
                local mainText = data and data.mainText
                if type(mainText) == "string" then
                    return mainText
                end
                return ""
            end,
        },
        parametricList = {},
        setup = function(dialog, data)
            local parametricList = dialog.info and dialog.info.parametricList
            if type(parametricList) ~= "table" then
                return
            end

            if type(ZO_ClearNumericallyIndexedTable) == "function" then
                ZO_ClearNumericallyIndexedTable(parametricList)
            else
                while #parametricList > 0 do
                    table.remove(parametricList)
                end
            end

            local submenuEntries = data and data.entries
            if type(submenuEntries) ~= "table" then
                submenuEntries = {}
            end

            for i = 1, #submenuEntries do
                local submenuEntry = submenuEntries[i]
                if type(submenuEntry) == "table" then
                    local submenuLabel = submenuEntry.label or submenuEntry.name or submenuEntry[1]
                    if type(submenuLabel) ~= "string" then
                        submenuLabel = tostring(submenuLabel or "")
                    end
                    local submenuCallback = submenuEntry.callback or submenuEntry.func or submenuEntry[2]
                    if submenuLabel ~= "" then
                        local entryData
                        if type(ZO_GamepadEntryData) == "table" and type(ZO_GamepadEntryData.New) == "function" then
                            entryData = ZO_GamepadEntryData:New(submenuLabel)
                            if type(entryData.SetIconTintOnSelection) == "function" then
                                entryData:SetIconTintOnSelection(true)
                            end
                        else
                            entryData = { text = submenuLabel }
                        end

                        if type(ZO_SharedGamepadEntry_OnSetup) == "function" then
                            entryData.setup = ZO_SharedGamepadEntry_OnSetup
                        end

                        entryData._lgcmbCallback = type(submenuCallback) == "function" and submenuCallback or nil
                        table.insert(parametricList, {
                            template = "ZO_GamepadItemEntryTemplate",
                            entryData = entryData,
                        })
                    end
                end
            end

            if type(dialog.setupFunc) == "function" then
                dialog:setupFunc()
            end

            if dialog.entryList and type(dialog.entryList.SetSelectedIndexWithoutAnimation) == "function" then
                pcall(dialog.entryList.SetSelectedIndexWithoutAnimation, dialog.entryList, 1, true, false)
            end
        end,
        buttons = {
            {
                keybind = "DIALOG_NEGATIVE",
                text = SafeGetString(SI_DIALOG_CANCEL, "Cancel"),
            },
            {
                keybind = "DIALOG_PRIMARY",
                text = SafeGetString(SI_GAMEPAD_SELECT_OPTION, "Select"),
                callback = function(dialog)
                    local selected = dialog and dialog.entryList and SafeGetTargetData(dialog.entryList)
                    local callback = selected and (selected._lgcmbCallback or (selected.entryData and selected.entryData._lgcmbCallback))
                    ZO_Dialogs_ReleaseDialogOnButtonPress(dialogName)
                    if type(callback) == "function" then
                        SafeCallCallback(callback)
                    end
                end,
            },
        },
    })

    self._submenuDialogRegistered = true
    return true
end

function bridge:_showSubmenuDialog(submenuLabel, submenuEntries, submenuCallback)
    if type(submenuCallback) == "function" then
        SafeCallCallback(submenuCallback)
    end

    if type(submenuEntries) ~= "table" or #submenuEntries == 0 then
        return
    end

    if not self:_ensureSubmenuDialog() then
        return
    end

    ZO_Dialogs_ShowDialog(self._submenuDialogName, {
        title = submenuLabel,
        entries = submenuEntries,
    })
end

function bridge:_appendEntriesToSlotActions(slotActions, entries, inventorySlot)
    if type(slotActions) ~= "table" or type(slotActions.AddSlotAction) ~= "function" then
        return
    end

    local knownNames = CollectExistingActionNames(slotActions)
    local addedCount = 0

    local function AddUniqueAction(label, callback)
        if type(label) ~= "string" or label == "" then
            return
        end
        if type(callback) ~= "function" then
            return
        end
        if knownNames[label] then
            return
        end

        knownNames[label] = true
        local actionName = bridge:_ensureActionStringId(label)
        -- Keep this nil for compatibility with gamepad action dialogs that derive labels from raw action metadata.
        slotActions:AddSlotAction(actionName, callback, nil)
        StampActionLabel(slotActions, label, callback)
        addedCount = addedCount + 1
    end

    for i = 1, #entries do
        local entry = entries[i]
        if type(entry) == "table" then
            if entry.kind == "submenu" then
                local submenuEntries = entry.entries
                if type(submenuEntries) == "table" and #submenuEntries > 0 then
                    for subIndex = 1, #submenuEntries do
                        local submenuEntry = submenuEntries[subIndex]
                        if
                            type(submenuEntry) == "table"
                            and type(submenuEntry.label) == "string"
                            and submenuEntry.label ~= ""
                            and type(submenuEntry.callback) == "function"
                        then
                            AddUniqueAction(string.format("%s: %s", entry.label, submenuEntry.label), submenuEntry.callback)
                        end
                    end
                end
            else
                AddUniqueAction(entry.label, entry.callback)
            end
        end
    end

    local nativeJunkAction = self:_buildNativeJunkAction(inventorySlot)
    if nativeJunkAction then
        AddUniqueAction(nativeJunkAction.label, nativeJunkAction.callback)
    end

    LogTrace(string.format("Injected %d actions from %d captured entries", addedCount, #entries))
end

function bridge:_tryInjectGamepadContextActions(inventorySlot, slotActions)
    if not self.enabled then
        LogTrace("Skip inject: bridge disabled")
        return
    end

    if type(slotActions) ~= "table" then
        LogTrace("Skip inject: slotActions is invalid")
        return
    end

    if slotActions.m_contextMenuMode then
        LogTrace("Skip inject: already in context menu mode")
        return
    end

    if type(IsInGamepadPreferredMode) == "function" and not IsInGamepadPreferredMode() then
        LogTrace("Skip inject: not in gamepad preferred mode")
        return
    end

    do
        local bagId, slotIndex = self:_resolveBagAndSlot(inventorySlot)
        if bagId == nil or slotIndex == nil then
            LogTrace("Skip inject: slot has no bag/slot index")
            return
        end
    end

    local lcm = LibCustomMenu
    local capturedEntries = {}
    if type(lcm) == "table" then
        capturedEntries = self:_runContextCallbacks(lcm, inventorySlot, slotActions) or {}
    else
        LogTrace("LibCustomMenu missing; injecting native fallback actions only")
    end

    if #capturedEntries == 0 then
        LogTrace("No LibCustomMenu entries captured for this slot")
    end

    self:_appendEntriesToSlotActions(slotActions, capturedEntries, inventorySlot)
end

function bridge:_hookDiscoverSlotActions()
    if self._discoverHooked then
        return
    end

    if type(SecurePostHook) == "function" then
        SecurePostHook("ZO_InventorySlot_DiscoverSlotActionsFromActionList", function(inventorySlot, slotActions)
            bridge:_tryInjectGamepadContextActions(inventorySlot, slotActions)
        end)
    elseif type(ZO_PostHook) == "function" then
        ZO_PostHook("ZO_InventorySlot_DiscoverSlotActionsFromActionList", function(inventorySlot, slotActions)
            bridge:_tryInjectGamepadContextActions(inventorySlot, slotActions)
        end)
    else
        return
    end

    self._discoverHooked = true
end

function bridge:_hookRefreshKeybindStrip()
    if self._refreshHooked then
        return
    end

    if type(ZO_ItemSlotActionsController) ~= "table" then
        return
    end

    local hookInstalled = false

    local function OnRefreshKeybindStrip(controller)
        if not controller or type(controller) ~= "table" then
            return
        end

        local slotActions = controller.slotActions
        local inventorySlot = controller.inventorySlot

        if not inventorySlot and type(GAMEPAD_INVENTORY) == "table" and GAMEPAD_INVENTORY.itemActions then
            inventorySlot = GAMEPAD_INVENTORY.itemActions.inventorySlot
        end

        if inventorySlot and slotActions then
            bridge:_tryInjectGamepadContextActions(inventorySlot, slotActions)
        end
    end

    if type(SecurePostHook) == "function" then
        SecurePostHook(ZO_ItemSlotActionsController, "RefreshKeybindStrip", OnRefreshKeybindStrip)
        hookInstalled = true
    elseif type(ZO_PostHook) == "function" then
        ZO_PostHook(ZO_ItemSlotActionsController, "RefreshKeybindStrip", OnRefreshKeybindStrip)
        hookInstalled = true
    end

    if not hookInstalled then
        return
    end

    self._refreshHooked = true
end

function bridge:Initialize()
    if self._initialized then
        return
    end

    self:_initializeSavedVars()
    self:_initializeSlashCommands()
    self:_initializeSettingsPanel()

    local lcm = LibCustomMenu
    if type(lcm) == "table" then
        self:_wrapRegisterContextMenu(lcm)
        self:_importExistingCallbacks(lcm)
        self:_hookDiscoverSlotActions()
        self:_hookRefreshKeybindStrip()
    else
        LogDebug("LibCustomMenu not found; tooltip/overlay features stay active, context bridge is idle")
    end
    
    -- Попытка подцепить тултипы
    local tooltipHookSuccess = self:_hookTooltipPrice()
    if not tooltipHookSuccess then
        LogDebug("Initial tooltip hook failed, scheduling retry...")
        self:_scheduleTooltipPriceHookRetry()
    end

    -- Тултипы крафтовых станций (gamepad-режим)
    self:_hookCraftingTooltips()

    -- Тултип торгового дома (gamepad-режим)
    self:_hookTradingHouseTooltip()

    self:_registerPlayerActivatedHook()

    self._initialized = true
    LogDebug(string.format(
        "Initialize summary: tooltipHooks=%s crafting=%s tradingHouse=%s overlay=%s enabled=%s",
        tostring(self._tooltipPriceHooked),
        tostring(self._craftingTooltipsHooked == true),
        tostring(self._tradingHouseTooltipHooked),
        tostring(self._overlayWindow ~= nil),
        tostring(self.enabled)
    ))
    LogDebug("Initialized")
end

local EVENT_NAMESPACE = MAJOR .. "_OnLoaded"
local PLAYER_ACTIVATED_EVENT_NAMESPACE = MAJOR .. "_PlayerActivated"

function bridge:_registerPlayerActivatedHook()
    if self._playerActivatedHookRegistered then
        return
    end

    if type(EVENT_MANAGER) ~= "table" or type(EVENT_MANAGER.RegisterForEvent) ~= "function" then
        return
    end

    EVENT_MANAGER:RegisterForEvent(PLAYER_ACTIVATED_EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
        local hooked = bridge:_hookTooltipPrice()
        if not hooked then
            bridge:_scheduleTooltipPriceHookRetry()
        end
        bridge:_hookCraftingTooltips()
        bridge:_hookTradingHouseTooltip()
        if type(EVENT_MANAGER.UnregisterForEvent) == "function" then
            EVENT_MANAGER:UnregisterForEvent(PLAYER_ACTIVATED_EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
        end
    end)

    -- LayoutGuildStoreSearchResult is added to tooltip instances dynamically the first
    -- time the trading house is opened.  Hook on EVENT_OPEN_TRADING_HOUSE so we catch
    -- that moment reliably, even if the player never triggered EVENT_PLAYER_ACTIVATED
    -- while in front of a TH.
    local TH_OPEN_NS = MAJOR .. "_THOpen"
    EVENT_MANAGER:RegisterForEvent(TH_OPEN_NS, EVENT_OPEN_TRADING_HOUSE, function()
        bridge:_hookTradingHouseTooltip()
        LogTrace("EVENT_OPEN_TRADING_HOUSE: retried TH tooltip hook")
    end)

    local TH_CLOSE_NS = MAJOR .. "_THClose"
    if type(EVENT_CLOSE_TRADING_HOUSE) == "number" then
        EVENT_MANAGER:RegisterForEvent(TH_CLOSE_NS, EVENT_CLOSE_TRADING_HOUSE, function()
            bridge:_hideOverlay()
            LogTrace("Overlay hidden on EVENT_CLOSE_TRADING_HOUSE")
        end)
    end

    local CRAFT_OPEN_NS = MAJOR .. "_CraftOpen"
    if type(EVENT_CRAFTING_STATION_INTERACT) == "number" then
        EVENT_MANAGER:RegisterForEvent(CRAFT_OPEN_NS, EVENT_CRAFTING_STATION_INTERACT, function(_, craftSkill, sameStation, craftMode)
            bridge._craftingStationActive = true
            bridge._templateCraftingOverlayActive = false
            bridge:_hookTooltipPrice()
            bridge:_hookCraftingTooltips()
            LogTrace(string.format("EVENT_CRAFTING_STATION_INTERACT: skill=%s same=%s mode=%s",
                tostring(craftSkill), tostring(sameStation), tostring(craftMode)))
        end)
    end

    local CRAFT_CLOSE_NS = MAJOR .. "_CraftClose"
    if type(EVENT_END_CRAFTING_STATION_INTERACT) == "number" then
        EVENT_MANAGER:RegisterForEvent(CRAFT_CLOSE_NS, EVENT_END_CRAFTING_STATION_INTERACT, function()
            bridge._craftingStationActive = false
            bridge._templateCraftingOverlayActive = false
            bridge:_hideOverlay()
            LogTrace("Overlay hidden on EVENT_END_CRAFTING_STATION_INTERACT")
        end)
    end

    self._playerActivatedHookRegistered = true
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= MAJOR then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED)
    bridge:Initialize()
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED, OnAddonLoaded)
