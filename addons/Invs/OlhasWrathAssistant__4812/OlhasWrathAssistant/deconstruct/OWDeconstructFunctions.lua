local owa = OWAssistant
owa.Deconstruct = owa.Deconstruct or {}
local deconstruct = owa.Deconstruct

deconstruct.active = false
deconstruct.currentCraftingType = nil

deconstruct.collectors = {}
deconstruct.collectorOrder = {}

deconstruct.itemQueue = {}
deconstruct.deconstructedCount = 0

local QUEUE_EVENT_NAME = "OWDeconstructQueue"

local keybindStripDescriptor = {
    {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,

        name = function()
            return owa.GetString("MASS_DECONSTRUCT")
        end,

        keybind = "OWA_DECONSTRUCT",

        callback = function()
            deconstruct.Run()
        end,
    },
}

function deconstruct.ShowKeybind()
    if not KEYBIND_STRIP then
        return
    end

    if not KEYBIND_STRIP:HasKeybindButtonGroup(
        keybindStripDescriptor
    ) then
        KEYBIND_STRIP:AddKeybindButtonGroup(
            keybindStripDescriptor
        )
    end
end

function deconstruct.HideKeybind()
    if not KEYBIND_STRIP then
        return
    end

    if KEYBIND_STRIP:HasKeybindButtonGroup(
        keybindStripDescriptor
    ) then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(
            keybindStripDescriptor
        )
    end
end

function deconstruct.OnStationInteract(
    eventCode,
    craftingType,
    sameStation,
    craftingMode
)
    deconstruct.active = true
    deconstruct.currentCraftingType = craftingType

    deconstruct.ShowKeybind()
end

function deconstruct.OnStationExit()
    deconstruct.active = false
    deconstruct.currentCraftingType = nil

    EVENT_MANAGER:UnregisterForEvent(
        QUEUE_EVENT_NAME,
        EVENT_CRAFT_COMPLETED
    )

    deconstruct.itemQueue = {}
    deconstruct.deconstructedCount = 0

    deconstruct.HideKeybind()
end

function deconstruct.IsUniversalStation()
    return GetCraftingInteractionMode()
        == CRAFTING_INTERACTION_MODE_UNIVERSAL_DECONSTRUCTION
end

function deconstruct.IsEnchantingStation()
    return not deconstruct.IsUniversalStation()
        and deconstruct.currentCraftingType
        == CRAFTING_TYPE_ENCHANTING
end

function deconstruct.GetSmithingObject()
    local isUniversal =
        deconstruct.IsUniversalStation()

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

    if savedQuality
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

    for _, qualityDefinition in ipairs(
        qualityDefinitions
    ) do
        local qualityName = owa.GetString(
            "DECONSTRUCT_" .. qualityDefinition.key
        )

        if qualityName
            and string.find(savedText, qualityName, 1, true)
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

    if owa.savedVariables
        and owa.savedVariables.deconstructChatMessages == false
    then
        return
    end

    d("[OWDeconstructor] " .. message)
end

function deconstruct.RegisterCollector(
    collectorName,
    callback
)
    if not collectorName
        or type(callback) ~= "function"
    then
        return
    end

    if not deconstruct.collectors[collectorName] then
        table.insert(
            deconstruct.collectorOrder,
            collectorName
        )
    end

    deconstruct.collectors[collectorName] =
        callback
end

local function FinishDeconstruction()
    EVENT_MANAGER:UnregisterForEvent(
        QUEUE_EVENT_NAME,
        EVENT_CRAFT_COMPLETED
    )

    local count =
        deconstruct.deconstructedCount or 0

    deconstruct.itemQueue = {}
    deconstruct.deconstructedCount = 0

    if count <= 0 then
        return
    end

    local message = owa.GetString(
        "DECONSTRUCT_CHAT_DECONSTRUCTED_ITEMS"
    )

    if message then
        deconstruct.Chat(
            string.format(message, count)
        )
    end
end

local StartNextBatch

local function ContinueDeconstruction()
    zo_callLater(function()
        StartNextBatch()
    end, 50)
end

StartNextBatch = function()
    EVENT_MANAGER:UnregisterForEvent(
        QUEUE_EVENT_NAME,
        EVENT_CRAFT_COMPLETED
    )

    -- На звичайній станції зачарування
    -- гліфи розбираються по одному,
    -- оскільки ESO використовує окремий
    -- виклик ExtractEnchantingItem.
    if deconstruct.IsEnchantingStation() then
        while #deconstruct.itemQueue > 0 do
            local item = table.remove(
                deconstruct.itemQueue,
                1
            )

            local canExtract =
                CanItemBeSmithingExtractedOrRefined(
                    item.bagId,
                    item.slotIndex,
                    CRAFTING_TYPE_ENCHANTING
                )

            if canExtract then
                EVENT_MANAGER:RegisterForEvent(
                    QUEUE_EVENT_NAME,
                    EVENT_CRAFT_COMPLETED,
                    ContinueDeconstruction
                )

                deconstruct.deconstructedCount =
                    deconstruct.deconstructedCount + 1

                ExtractEnchantingItem(
                    item.bagId,
                    item.slotIndex
                )

                return
            end
        end

        FinishDeconstruction()
        return
    end

    -- Ковальська, швейна, деревообробна,
    -- ювелірна та універсальна станції.
    local smithingObject =
        deconstruct.GetSmithingObject()

    local deconstructionPanel =
        smithingObject
        and smithingObject.deconstructionPanel

    if not smithingObject
        or not deconstructionPanel
    then
        FinishDeconstruction()
        return
    end

    if deconstructionPanel.extractionSlot:HasItems() then
        deconstruct.Chat(
            owa.GetString("DECONSTRUCT_CHAT_SLOT_OCCUPIED")
        )

        FinishDeconstruction()
        return
    end

    local addedItems = 0

    local maximumItems =
        MAX_ITERATIONS_PER_DECONSTRUCTION
        or 100

    while #deconstruct.itemQueue > 0
        and addedItems < maximumItems
    do
        local item = table.remove(
            deconstruct.itemQueue,
            1
        )

        local canAdd = true

        if smithingObject.CanItemBeAddedToCraft then
            canAdd =
                smithingObject:CanItemBeAddedToCraft(
                    item.bagId,
                    item.slotIndex
                )
        end

        if canAdd then
            smithingObject:AddItemToCraft(
                item.bagId,
                item.slotIndex
            )

            addedItems = addedItems + 1

            deconstruct.deconstructedCount =
                deconstruct.deconstructedCount + 1
        end
    end

    if addedItems == 0 then
        FinishDeconstruction()
        return
    end

    EVENT_MANAGER:RegisterForEvent(
        QUEUE_EVENT_NAME,
        EVENT_CRAFT_COMPLETED,
        ContinueDeconstruction
    )

    if addedItems == 1 then
        deconstructionPanel:ExtractSingle()
    else
        deconstructionPanel:ExtractAll()
    end
end

function deconstruct.StartQueue(candidates)
    if not candidates or #candidates == 0 then
        deconstruct.Chat(
            owa.GetString("DECONSTRUCT_CHAT_NO_ITEMS")
        )

        return
    end

    if deconstruct.IsEnchantingStation() then
        if not ENCHANTING then
            return
        end

        if ENCHANTING.enchantingMode
            ~= ENCHANTING_MODE_EXTRACTION
        then
            ZO_MenuBar_SelectDescriptor(
                ENCHANTING.modeBar,
                ENCHANTING_MODE_EXTRACTION
            )
        end
    else
        local smithingObject =
            deconstruct.GetSmithingObject()

        if not smithingObject then
            return
        end

        if smithingObject.mode
            ~= SMITHING_MODE_DECONSTRUCTION
        then
            ZO_MenuBar_SelectDescriptor(
                smithingObject.modeBar,
                SMITHING_MODE_DECONSTRUCTION
            )
        end
    end

    deconstruct.itemQueue = candidates
    deconstruct.deconstructedCount = 0

    zo_callLater(function()
        StartNextBatch()
    end, 50)
end

function deconstruct.Run()
    if not deconstruct.active then
        deconstruct.Chat(
            owa.GetString("DECONSTRUCT_CHAT_OPEN_STATION")
        )

        return
    end

    local candidates = {}

    for _, collectorName in ipairs(
        deconstruct.collectorOrder
    ) do
        local collector =
            deconstruct.collectors[collectorName]

        if collector then
            collector(candidates)
        end
    end

    deconstruct.StartQueue(candidates)
end

function deconstruct.Initialize()
    EVENT_MANAGER:RegisterForEvent(
        "OWDeconstruct_StationStart",
        EVENT_CRAFTING_STATION_INTERACT,
        deconstruct.OnStationInteract
    )

    EVENT_MANAGER:RegisterForEvent(
        "OWDeconstruct_StationEnd",
        EVENT_END_CRAFTING_STATION_INTERACT,
        deconstruct.OnStationExit
    )
end
