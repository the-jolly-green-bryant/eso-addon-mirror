local ua = UAssistant
ua.Deconstruct = ua.Deconstruct or {}
local deconstruct = ua.Deconstruct

deconstruct.active = false
deconstruct.currentCraftingType = nil

deconstruct.collectors = {}
deconstruct.collectorOrder = {}

deconstruct.itemQueue = {}
deconstruct.deconstructedCount = 0
deconstruct.soundOverride = nil
deconstruct.queueActive = false
deconstruct.queueToken = 0

local QUEUE_EVENT_NAME = "UADeconstructQueue"

local function RestoreRegularStationSound(override)
    if not override or deconstruct.soundOverride ~= override then
        return
    end

    CALLBACK_MANAGER:UnregisterCallback("CraftingAnimationsStopped", override.callback)

    local results = override.results

    if results then
        results:SetTooltipAnimationSounds(
            override.originalSuccessSound,
            override.originalFailureSound
        )
    end

    deconstruct.soundOverride = nil
end

local function PrepareRegularStationSound()
    if deconstruct.IsUniversalStation() then
        return
    end

    RestoreRegularStationSound(deconstruct.soundOverride)

    local results

    if IsInGamepadPreferredMode() then
        results = GAMEPAD_CRAFTING_RESULTS
    else
        results = CRAFTING_RESULTS
    end

    if not results or not results.SetTooltipAnimationSounds then
        return
    end

    local override = {
        results = results,
        originalSuccessSound = results.tooltipAnimationSuccessSound,
        originalFailureSound = results.tooltipAnimationFailureSound,
    }

    override.callback = function()
        zo_callLater(function()
            RestoreRegularStationSound(override)
        end, 0)
    end

    deconstruct.soundOverride = override

    results:SetTooltipAnimationSounds(
        SOUNDS.UNIVERSAL_DECONSTRUCTION_SUCCESS,
        SOUNDS.UNIVERSAL_DECONSTRUCTION_FAIL
    )

    CALLBACK_MANAGER:RegisterCallback("CraftingAnimationsStopped", override.callback)

    zo_callLater(function()
        RestoreRegularStationSound(override)
    end, 5000)
end

local keybindStripDescriptor = {
    {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,

        name = function()
            return ua.GetString("MASS_DECONSTRUCT")
        end,

        keybind = "UA_DECONSTRUCT",

        callback = function()
            deconstruct.Run()
        end,
    },
}

function deconstruct.ShowKeybind()
    if not KEYBIND_STRIP then
        return
    end

    if not KEYBIND_STRIP:HasKeybindButtonGroup(keybindStripDescriptor) then
        KEYBIND_STRIP:AddKeybindButtonGroup(keybindStripDescriptor)
    end
end

function deconstruct.HideKeybind()
    if not KEYBIND_STRIP then
        return
    end

    if KEYBIND_STRIP:HasKeybindButtonGroup(keybindStripDescriptor) then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindStripDescriptor)
    end
end

function deconstruct.OnStationInteract(eventCode, craftingType, sameStation, craftingMode)
    deconstruct.active = true
    deconstruct.currentCraftingType = craftingType

    deconstruct.ShowKeybind()
end

function deconstruct.OnStationExit()
    deconstruct.queueToken = deconstruct.queueToken + 1
    deconstruct.queueActive = false
    deconstruct.active = false
    deconstruct.currentCraftingType = nil

    EVENT_MANAGER:UnregisterForEvent(QUEUE_EVENT_NAME, EVENT_CRAFT_COMPLETED)

    deconstruct.itemQueue = {}
    deconstruct.deconstructedCount = 0

    RestoreRegularStationSound(deconstruct.soundOverride)

    deconstruct.HideKeybind()
end

function deconstruct.IsUniversalStation()
    return GetCraftingInteractionMode() == CRAFTING_INTERACTION_MODE_UNIVERSAL_DECONSTRUCTION
end

function deconstruct.IsEnchantingStation()
    return not deconstruct.IsUniversalStation()
        and deconstruct.currentCraftingType == CRAFTING_TYPE_ENCHANTING
end

function deconstruct.GetSmithingObject()
    local isUniversal = deconstruct.IsUniversalStation()

    if IsInGamepadPreferredMode() then
        if isUniversal then
            return UNIVERSAL_DECONSTRUCTION_GAMEPAD
        end

        return SMITHING_GAMEPAD
    end

    if isUniversal then
        return UNIVERSAL_DECONSTRUCTION
    end

    return SMITHING
end

function deconstruct.GetMaxQuality(profile)
    local savedQuality = tonumber(profile.maxQuality)

    if
        savedQuality
        and savedQuality >= ITEM_QUALITY_NORMAL
        and savedQuality <= ITEM_QUALITY_LEGENDARY
    then
        profile.maxQuality = savedQuality
        return savedQuality
    end

    local savedText = tostring(profile.maxQuality)

    local qualityDefinitions = {
        {
            value = ITEM_QUALITY_NORMAL,
            key = "QUALITY_NORMAL",
        },
        {
            value = ITEM_QUALITY_MAGIC,
            key = "QUALITY_FINE",
        },
        {
            value = ITEM_QUALITY_ARCANE,
            key = "QUALITY_SUPERIOR",
        },
        {
            value = ITEM_QUALITY_ARTIFACT,
            key = "QUALITY_EPIC",
        },
        {
            value = ITEM_QUALITY_LEGENDARY,
            key = "QUALITY_LEGENDARY",
        },
    }

    for _, qualityDefinition in ipairs(qualityDefinitions) do
        local qualityName = ua.GetString("DECONSTRUCT_" .. qualityDefinition.key)
        local gameQualityName = GetString("SI_ITEMQUALITY", qualityDefinition.value)

        if
            (qualityName and string.find(savedText, qualityName, 1, true))
            or (
                gameQualityName
                and gameQualityName ~= ""
                and string.find(savedText, gameQualityName, 1, true)
            )
        then
            profile.maxQuality = qualityDefinition.value
            return qualityDefinition.value
        end
    end

    profile.maxQuality = ITEM_QUALITY_NORMAL
    return ITEM_QUALITY_NORMAL
end

function deconstruct.Chat(message)
    if not message then
        return
    end

    if ua.savedVariables and ua.savedVariables.deconstructChatMessages == false then
        return
    end

    d("|cFFFFFF[|r|c3A92FFU|r|cFFFF00A|r|cFFFFFFDeconstructor]|r " .. message)
end

function deconstruct.RegisterCollector(collectorName, callback)
    if not collectorName or type(callback) ~= "function" then
        return
    end

    if not deconstruct.collectors[collectorName] then
        table.insert(deconstruct.collectorOrder, collectorName)
    end

    deconstruct.collectors[collectorName] = callback
end

local function FinishDeconstruction()
    deconstruct.queueActive = false
    deconstruct.queueToken = deconstruct.queueToken + 1
    EVENT_MANAGER:UnregisterForEvent(QUEUE_EVENT_NAME, EVENT_CRAFT_COMPLETED)

    local count = deconstruct.deconstructedCount or 0

    deconstruct.itemQueue = {}
    deconstruct.deconstructedCount = 0

    if count <= 0 then
        return
    end

    local message = ua.GetString("DECONSTRUCT_CHAT_DECONSTRUCTED_ITEMS")

    if message then
        deconstruct.Chat(string.format(message, count))
    end
end

local StartNextBatch

local function ContinueDeconstruction()
    local token = deconstruct.queueToken
    zo_callLater(function()
        StartNextBatch(token)
    end, 50)
end

StartNextBatch = function(token)
    if token ~= deconstruct.queueToken or not deconstruct.queueActive or not deconstruct.active then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(QUEUE_EVENT_NAME, EVENT_CRAFT_COMPLETED)

    if #deconstruct.itemQueue == 0 then
        FinishDeconstruction()
        return
    end

    PrepareDeconstructMessage()

    local addedItems = 0
    local allowedSlots = {}
    local currentCandidates = {}

    for _, collectorName in ipairs(deconstruct.collectorOrder) do
        local collector = deconstruct.collectors[collectorName]

        if collector then
            collector(currentCandidates)
        end
    end

    for _, item in ipairs(currentCandidates) do
        allowedSlots[tostring(item.bagId) .. ":" .. tostring(item.slotIndex)] = true
    end

    while #deconstruct.itemQueue > 0 do
        local item = table.remove(deconstruct.itemQueue, 1)

        local slotKey = tostring(item.bagId) .. ":" .. tostring(item.slotIndex)
        local currentLink = GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)
        local currentId = GetItemUniqueId and tostring(GetItemUniqueId(item.bagId, item.slotIndex))
        local valid = allowedSlots[slotKey]
            and currentLink == item.itemLink
            and (not item.uniqueId or currentId == item.uniqueId)
            and not IsItemPlayerLocked(item.bagId, item.slotIndex)
        local itemAdded = valid
            and AddItemToDeconstructMessage(item.bagId, item.slotIndex, item.quantity)

        if itemAdded then
            addedItems = addedItems + 1
            deconstruct.deconstructedCount = deconstruct.deconstructedCount + 1
        elseif valid and addedItems > 0 then
            table.insert(deconstruct.itemQueue, 1, item)
            break
        end
    end

    if addedItems == 0 then
        FinishDeconstruction()
        return
    end

    EVENT_MANAGER:RegisterForEvent(QUEUE_EVENT_NAME, EVENT_CRAFT_COMPLETED, ContinueDeconstruction)

    PrepareRegularStationSound()
    SendDeconstructMessage()
end

function deconstruct.StartQueue(candidates)
    if deconstruct.queueActive or not deconstruct.active then
        return
    end

    if not candidates or #candidates == 0 then
        deconstruct.Chat(ua.GetString("DECONSTRUCT_CHAT_NO_ITEMS"))

        return
    end

    if deconstruct.IsEnchantingStation() then
        if not ENCHANTING then
            return
        end

        if ENCHANTING.enchantingMode ~= ENCHANTING_MODE_EXTRACTION then
            ZO_MenuBar_SelectDescriptor(ENCHANTING.modeBar, ENCHANTING_MODE_EXTRACTION)
        end
    else
        local smithingObject = deconstruct.GetSmithingObject()

        if not smithingObject then
            return
        end

        if smithingObject.mode ~= SMITHING_MODE_DECONSTRUCTION then
            ZO_MenuBar_SelectDescriptor(smithingObject.modeBar, SMITHING_MODE_DECONSTRUCTION)
        end
    end

    deconstruct.itemQueue = candidates
    deconstruct.deconstructedCount = 0
    deconstruct.queueActive = true
    deconstruct.queueToken = deconstruct.queueToken + 1
    local token = deconstruct.queueToken

    for _, item in ipairs(candidates) do
        item.itemLink = item.itemLink or GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)
        item.uniqueId = GetItemUniqueId and tostring(GetItemUniqueId(item.bagId, item.slotIndex))
    end

    zo_callLater(function()
        StartNextBatch(token)
    end, 50)
end

function deconstruct.Run()
    if deconstruct.queueActive then
        return
    end

    if not deconstruct.active then
        deconstruct.Chat(ua.GetString("DECONSTRUCT_CHAT_OPEN_STATION"))

        return
    end

    local candidates = {}

    for _, collectorName in ipairs(deconstruct.collectorOrder) do
        local collector = deconstruct.collectors[collectorName]

        if collector then
            collector(candidates)
        end
    end

    deconstruct.StartQueue(candidates)
end

function deconstruct.Initialize()
    EVENT_MANAGER:RegisterForEvent(
        "UADeconstruct_StationStart",
        EVENT_CRAFTING_STATION_INTERACT,
        deconstruct.OnStationInteract
    )

    EVENT_MANAGER:RegisterForEvent(
        "UADeconstruct_StationEnd",
        EVENT_END_CRAFTING_STATION_INTERACT,
        deconstruct.OnStationExit
    )
end
