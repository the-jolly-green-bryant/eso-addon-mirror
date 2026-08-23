NQOL = NQOL or {}

local AdvancedData = {}

local ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"
local BASE = #ALPHABET
local CHECKSUM_MODULUS = BASE * BASE
local MAX_JOURNAL_QUESTS_FALLBACK = 25
local QUEST_MAIN_STEP = 1
local PAYLOAD_LENGTH = 38
local PREFIX = "E4"
local HEADING_SCALE = 1000
local UINT32_MODULUS = 4294967296
local EVENT_NAMESPACE = "NQOL_GPS_ADVANCED_DATA"
local GAMEPLAY_SCENES = {
    hud = true,
    hudui = true,
    siegeBar = true,
}

local writStates = { 0, 0, 0, 0, 0, 0, 0 }
local questCraftingTypes = {}
local writStatesDirty = true
local initialized = false
local hasUnknownWrit = false

local Floor = math.floor
local StringByte = string.byte
local StringFind = string.find
local StringFormat = string.format
local StringGsub = string.gsub
local StringSub = string.sub

local function AlphabetIndex(character)
    local index = StringFind(ALPHABET, character, 1, true)
    return index and index - 1 or nil
end

local function EncodeFixed(value, width)
    value = tonumber(value)
    if not value or value < 0 or value ~= Floor(value) or value >= BASE ^ width then
        return nil
    end

    local encoded = {}
    for index = width, 1, -1 do
        local digit = value % BASE
        encoded[index] = StringSub(ALPHABET, digit + 1, digit + 1)
        value = Floor(value / BASE)
    end
    return table.concat(encoded)
end

local function DecodeFixed(encoded)
    local value = 0
    for index = 1, #encoded do
        local digit = AlphabetIndex(StringSub(encoded, index, index))
        if digit == nil then
            return nil
        end
        value = value * BASE + digit
    end
    return value
end

local function CalculateChecksum(payload)
    local checksum = 0
    for index = 1, #payload do
        checksum = (checksum * 33 + StringByte(payload, index)) % CHECKSUM_MODULUS
    end
    return checksum
end

local function NormalizeInteractionText(value)
    if type(value) ~= "string" then
        return ""
    end
    value = StringGsub(value, "|c%x%x%x%x%x%x", "")
    value = StringGsub(value, "|r", "")
    value = StringGsub(value, "%s+", " ")
    value = StringGsub(value, "^%s+", "")
    return StringGsub(value, "%s+$", "")
end

local function HashInteraction(action, name)
    local normalizedAction = NormalizeInteractionText(action)
    local normalizedName = NormalizeInteractionText(name)
    if normalizedAction == "" or normalizedName == "" then
        return 0
    end

    local value = 5381
    local combined = normalizedAction .. "\31" .. normalizedName
    for index = 1, #combined do
        value = (value * 33 + StringByte(combined, index)) % UINT32_MODULUS
    end
    return value
end

local function IsReticleUnit()
    if type(DoesUnitExist) == "function" then
        return DoesUnitExist("reticleover") == true
    end
    return type(IsUnitPlayer) == "function" and IsUnitPlayer("reticleover") == true
end

local function CollectInteraction()
    if type(GetGameCameraInteractableActionInfo) ~= "function" then
        return 0, 0, false
    end

    local action, name, blocked, owned, _, _, _, criminal =
        GetGameCameraInteractableActionInfo()
    if type(action) ~= "string" or action == "" or type(name) ~= "string" or name == "" then
        return 0, 0, true
    end

    if IsReticleUnit() then
        return 0, 16, true
    end

    local flags = 1
    if blocked == true then flags = flags + 2 end
    if owned == true then flags = flags + 4 end
    if criminal == true then flags = flags + 8 end
    return HashInteraction(action, name), flags, true
end

local function IsDailyCraftingQuest(questIndex)
    if type(GetJournalQuestRepeatType) ~= "function"
        or type(GetJournalQuestType) ~= "function"
    then
        return false
    end
    return GetJournalQuestRepeatType(questIndex) == QUEST_REPEAT_DAILY
        and GetJournalQuestType(questIndex) == QUEST_TYPE_CRAFTING
end

local function GetQuestConditionCount(questIndex)
    local conditionCount = 5
    if type(GetJournalQuestStepInfo) == "function" then
        conditionCount = tonumber(select(5, GetJournalQuestStepInfo(questIndex, QUEST_MAIN_STEP))) or conditionCount
    end
    return math.max(1, conditionCount)
end

local function FindQuestCraftingType(questIndex)
    if type(GetQuestConditionItemInfo) ~= "function" then
        return nil
    end

    for conditionIndex = 1, GetQuestConditionCount(questIndex) do
        local _, _, craftingType = GetQuestConditionItemInfo(
            questIndex,
            QUEST_MAIN_STEP,
            conditionIndex
        )
        if type(craftingType) == "number" and craftingType >= 1 and craftingType <= 7 then
            return craftingType
        end
    end
    return nil
end

local function IsWritDeliveryReady(questIndex)
    if type(GetJournalQuestConditionInfo) == "function"
        and type(QUEST_CONDITION_TYPE_ADVANCE_COMPLETABLE_SIBLINGS) == "number"
    then
        for conditionIndex = 1, GetQuestConditionCount(questIndex) do
            local isVisible, conditionType = select(
                7,
                GetJournalQuestConditionInfo(questIndex, QUEST_MAIN_STEP, conditionIndex)
            )
            if isVisible == true
                and conditionType == QUEST_CONDITION_TYPE_ADVANCE_COMPLETABLE_SIBLINGS
            then
                return true
            end
        end
    end

    return type(IsJournalQuestStepEnding) == "function"
        and IsJournalQuestStepEnding(questIndex, QUEST_MAIN_STEP) == true
end

local function RefreshWritStates()
    for craftingType = 1, 7 do
        writStates[craftingType] = 0
    end
    hasUnknownWrit = false

    if type(IsValidQuestIndex) ~= "function" then
        writStatesDirty = false
        return false
    end

    local maximum = tonumber(MAX_JOURNAL_QUESTS) or MAX_JOURNAL_QUESTS_FALLBACK
    for questIndex = 1, maximum do
        if IsValidQuestIndex(questIndex) and IsDailyCraftingQuest(questIndex) then
            local questId = type(GetJournalQuestId) == "function"
                and GetJournalQuestId(questIndex)
                or questIndex
            local craftingType = FindQuestCraftingType(questIndex)
                or questCraftingTypes[questId]
            if craftingType then
                questCraftingTypes[questId] = craftingType
                writStates[craftingType] = IsWritDeliveryReady(questIndex) and 2 or 1
            else
                hasUnknownWrit = true
            end
        end
    end

    writStatesDirty = false
    return true
end

local function PackWritStates()
    if writStatesDirty then
        RefreshWritStates()
    end
    local packed = 0
    local multiplier = 1
    for craftingType = 1, 7 do
        packed = packed + writStates[craftingType] * multiplier
        multiplier = multiplier * 4
    end
    return packed
end

local function GetCurrentSceneName()
    if not SCENE_MANAGER then
        return nil
    end
    if SCENE_MANAGER.GetCurrentSceneName then
        return SCENE_MANAGER:GetCurrentSceneName()
    end
    local scene = SCENE_MANAGER.GetCurrentScene and SCENE_MANAGER:GetCurrentScene()
    return scene and scene.GetName and scene:GetName() or nil
end

local function ClassifyScene(craftingType)
    if craftingType > 0 then
        return 1
    end
    if type(ZO_Dialogs_IsShowing) == "function"
        and (ZO_Dialogs_IsShowing("GAMEPAD_LOG_OUT") or ZO_Dialogs_IsShowing("LOG_OUT"))
    then
        return 7
    end
    local name = GetCurrentSceneName()
    if GAMEPLAY_SCENES[name] then
        return 0
    end
    local normalized = type(name) == "string" and string.lower(name) or ""
    if StringFind(normalized, "journal", 1, true) or StringFind(normalized, "quest", 1, true) then
        return 2
    end
    if StringFind(normalized, "setting", 1, true)
        or StringFind(normalized, "option", 1, true)
        or StringFind(normalized, "gamemenu", 1, true)
    then
        return 3
    end
    if StringFind(normalized, "interact", 1, true)
        or StringFind(normalized, "dialog", 1, true)
    then
        return 4
    end
    if SCENE_MANAGER and SCENE_MANAGER.IsInUIMode and SCENE_MANAGER:IsInUIMode() then
        return 5
    end
    return 6
end

local function BuildPayload(zoneId, worldX, worldY, worldZ, playerHeading, cameraHeading)
    local craftingType = type(GetCraftingInteractionType) == "function"
        and tonumber(GetCraftingInteractionType())
        or 0
    if not craftingType or craftingType < 0 or craftingType >= BASE then
        craftingType = 0
    end

    local interactionHash, interactionFlags, hasInteractionAPI = CollectInteraction()
    local packedWritStates = PackWritStates()
    local stateFlags = 0
    if type(IsValidQuestIndex) == "function" then stateFlags = stateFlags + 1 end
    if hasUnknownWrit then stateFlags = stateFlags + 2 end
    if hasInteractionAPI then stateFlags = stateFlags + 4 end

    local fields = {
        PREFIX,
        EncodeFixed(zoneId, 3),
        EncodeFixed(worldX, 4),
        EncodeFixed(worldY, 4),
        EncodeFixed(worldZ, 4),
        EncodeFixed(playerHeading, 3),
        EncodeFixed(cameraHeading, 3),
        EncodeFixed(interactionHash, 6),
        EncodeFixed(interactionFlags, 1),
        EncodeFixed(packedWritStates, 3),
        EncodeFixed(craftingType, 1),
        EncodeFixed(ClassifyScene(craftingType), 1),
        EncodeFixed(stateFlags, 1),
    }
    for index = 1, #fields do
        if not fields[index] then
            return nil
        end
    end

    local body = table.concat(fields)
    local checksum = EncodeFixed(CalculateChecksum(body), 2)
    local payload = body .. checksum
    return #payload == PAYLOAD_LENGTH and payload or nil
end

local function MarkWritStatesDirty()
    writStatesDirty = true
end

function AdvancedData.Initialize()
    if initialized then
        return
    end
    initialized = true
    writStatesDirty = true
    if not EVENT_MANAGER then
        return
    end

    local events = {}
    if EVENT_QUEST_ADDED then events[#events + 1] = EVENT_QUEST_ADDED end
    if EVENT_QUEST_REMOVED then events[#events + 1] = EVENT_QUEST_REMOVED end
    if EVENT_QUEST_ADVANCED then events[#events + 1] = EVENT_QUEST_ADVANCED end
    if EVENT_QUEST_CONDITION_COUNTER_CHANGED then
        events[#events + 1] = EVENT_QUEST_CONDITION_COUNTER_CHANGED
    end
    for index, eventCode in ipairs(events) do
        if eventCode then
            EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. index, eventCode, MarkWritStatesDirty)
        end
    end
end

function AdvancedData.BuildPayload(zoneId, worldX, worldY, worldZ, playerHeading, cameraHeading)
    return BuildPayload(
        tonumber(zoneId),
        tonumber(worldX),
        tonumber(worldY),
        tonumber(worldZ),
        tonumber(playerHeading),
        tonumber(cameraHeading)
    )
end

function AdvancedData.EncodeFixed(value, width)
    return EncodeFixed(value, width)
end

function AdvancedData.DecodeFixed(value)
    return DecodeFixed(value)
end

function AdvancedData.HashInteraction(action, name)
    return HashInteraction(action, name)
end

function AdvancedData.VerifyPayload(payload)
    return type(payload) == "string"
        and #payload == PAYLOAD_LENGTH
        and StringSub(payload, 1, 2) == PREFIX
        and DecodeFixed(StringSub(payload, 37, 38)) == CalculateChecksum(StringSub(payload, 1, 36))
end

function AdvancedData.MarkWritStatesDirty()
    MarkWritStatesDirty()
end

NQOL.GPSAdvancedData = AdvancedData
