local ua = UAssistant
local repair = ua.Repair

repair.Research = repair.Research or {}
local research = repair.Research

local EVENT_NAMESPACE = ua.addonName .. "Research"
local CHAT_PREFIX = "|cFFFFFF[|r|c3A92FFU|r|cFFFF00A|r" .. "|cFFFFFFResearch]|r "
local GetRetraitResearchLineInfo = GetResearchLineInfoFromRetraitItem
    or GetRearchLineInfoFromRetraitItem

local CRAFT_DEFINITIONS = {
    {
        key = "blacksmithing",
        craftingType = CRAFTING_TYPE_BLACKSMITHING,
    },
    {
        key = "clothing",
        craftingType = CRAFTING_TYPE_CLOTHIER,
    },
    {
        key = "woodworking",
        craftingType = CRAFTING_TYPE_WOODWORKING,
    },
    {
        key = "jewelry",
        craftingType = CRAFTING_TYPE_JEWELRYCRAFTING,
    },
}

local CRAFT_DEFINITIONS_BY_TYPE = {}

for _, definition in ipairs(CRAFT_DEFINITIONS) do
    CRAFT_DEFINITIONS_BY_TYPE[definition.craftingType] = definition
end

local function NormalizeText(value)
    return zo_strformat("<<C:1>>", value or "")
end

function research.GetCraftDefinition(craftingType)
    return CRAFT_DEFINITIONS_BY_TYPE[craftingType]
end

function research.GetCraftSettings(definition)
    local settings = repair.GetSettings()

    settings.research = settings.research or {}
    settings.research[definition.key] = settings.research[definition.key] or {}

    local craftSettings = settings.research[definition.key]

    craftSettings.lines = craftSettings.lines or {}

    if definition.key == "jewelry" and not craftSettings.jewelrySettingsMigrated then
        local oldLines = {
            [1] = craftSettings.rings,
            [2] = craftSettings.necklaces,
        }

        for lineIndex, oldTraits in pairs(oldLines) do
            craftSettings.lines[lineIndex] = craftSettings.lines[lineIndex] or {}

            for traitType, value in pairs(oldTraits or {}) do
                if craftSettings.lines[lineIndex][traitType] == nil then
                    craftSettings.lines[lineIndex][traitType] = value
                end
            end
        end

        craftSettings.rings = nil
        craftSettings.necklaces = nil
        craftSettings.jewelrySettingsMigrated = true
    end

    if craftSettings.priority ~= "sequence" and craftSettings.priority ~= "shortest" then
        craftSettings.priority = "sequence"
    end

    local numLines = GetNumSmithingResearchLines(definition.craftingType)

    for lineIndex = 1, numLines do
        craftSettings.lines[lineIndex] = craftSettings.lines[lineIndex] or {}
    end

    return craftSettings
end

function research.GetLineDetails(definition)
    local details = {}
    local numLines = GetNumSmithingResearchLines(definition.craftingType)

    for lineIndex = 1, numLines do
        local name, icon, numTraits, researchTime =
            GetSmithingResearchLineInfo(definition.craftingType, lineIndex)

        details[lineIndex] = {
            lineIndex = lineIndex,
            name = name,
            icon = icon,
            numTraits = numTraits,
            researchTime = researchTime or math.huge,
        }
    end

    return details
end

function research.GetResearchSequence(definition)
    local sequence = {}
    local lineDetails = research.GetLineDetails(definition)

    for firstLineIndex = 1, #lineDetails, 2 do
        local secondLineIndex = firstLineIndex + 1
        local firstLine = lineDetails[firstLineIndex]
        local secondLine = lineDetails[secondLineIndex]
        local maxTraits = firstLine.numTraits

        if secondLine then
            maxTraits = math.max(maxTraits, secondLine.numTraits)
        end

        for traitIndex = 1, maxTraits do
            for lineIndex = firstLineIndex, math.min(secondLineIndex, #lineDetails) do
                local line = lineDetails[lineIndex]

                if traitIndex <= line.numTraits then
                    local traitType = GetSmithingResearchLineTraitInfo(
                        definition.craftingType,
                        lineIndex,
                        traitIndex
                    )

                    if traitType then
                        table.insert(sequence, {
                            lineIndex = lineIndex,
                            lineName = line.name,
                            lineIcon = line.icon,
                            traitIndex = traitIndex,
                            traitType = traitType,
                            researchTime = line.researchTime,
                            pairStart = firstLineIndex,
                        })
                    end
                end
            end
        end
    end

    return sequence
end

local function GetResearchState(definition)
    local busyLines = {}
    local activeResearchCount = 0
    local numLines = GetNumSmithingResearchLines(definition.craftingType)

    for lineIndex = 1, numLines do
        local _, _, numTraits = GetSmithingResearchLineInfo(definition.craftingType, lineIndex)

        for traitIndex = 1, numTraits do
            local _, timeRemaining =
                GetSmithingResearchLineTraitTimes(definition.craftingType, lineIndex, traitIndex)

            if timeRemaining and timeRemaining > 0 then
                busyLines[lineIndex] = true
                activeResearchCount = activeResearchCount + 1
                break
            end
        end
    end

    local maximumResearch = GetMaxSimultaneousSmithingResearch(definition.craftingType) or 0

    return activeResearchCount < maximumResearch, busyLines
end

local function IsTraitUnknown(definition, lineIndex, traitType)
    local _, _, numTraits = GetSmithingResearchLineInfo(definition.craftingType, lineIndex)

    for traitIndex = 1, numTraits do
        local currentTraitType, _, known =
            GetSmithingResearchLineTraitInfo(definition.craftingType, lineIndex, traitIndex)

        if currentTraitType == traitType then
            return not known
        end
    end

    return false
end

local function IsSaferResearchItem(bagId, slotIndex)
    if IsItemPlayerLocked(bagId, slotIndex) then
        return false
    end

    if IsItemStolen(bagId, slotIndex) then
        return false
    end

    if IsItemReconstructed and IsItemReconstructed(bagId, slotIndex) then
        return false
    end

    return GetItemTraitInformation(bagId, slotIndex) == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED
end

local function IsBetterCandidate(candidate, current)
    if not current then
        return true
    end

    if candidate.quality ~= current.quality then
        return candidate.quality < current.quality
    end

    if candidate.sellPrice ~= current.sellPrice then
        return candidate.sellPrice < current.sellPrice
    end

    return candidate.slotIndex < current.slotIndex
end

local function IncludeBankedItems()
    local smithingObject = IsInGamepadPreferredMode() and SMITHING_GAMEPAD or SMITHING

    if not smithingObject then
        return false
    end

    local researchPanel

    if smithingObject.GetResearchPanel then
        researchPanel = smithingObject:GetResearchPanel()
    else
        researchPanel = smithingObject.researchPanel
    end

    if not researchPanel then
        return false
    end

    if researchPanel.IsIncludeBankedItemsChecked then
        return researchPanel:IsIncludeBankedItemsChecked() == true
    end

    return researchPanel.savedVars and researchPanel.savedVars.includeBankedItemsChecked == true
end

local function GetResearchBags()
    local bags = { BAG_BACKPACK }

    if not IncludeBankedItems() then
        return bags
    end

    table.insert(bags, BAG_BANK)

    if IsESOPlusSubscriber() then
        table.insert(bags, BAG_SUBSCRIBER_BANK)
    end

    return bags
end

local function FindCandidate(definition, option)
    local bestCandidate
    local targetLineName = NormalizeText(option.lineName)

    for _, bagId in ipairs(GetResearchBags()) do
        local bagSize = GetBagSize(bagId)

        for slotIndex = 0, bagSize - 1 do
            local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)

            if
                itemLink ~= ""
                and GetItemTrait(bagId, slotIndex) == option.traitType
                and IsSaferResearchItem(bagId, slotIndex)
            then
                local craftingType, lineName = GetRetraitResearchLineInfo(bagId, slotIndex)

                if
                    craftingType == definition.craftingType
                    and NormalizeText(lineName) == targetLineName
                then
                    local _, _, sellPrice = GetItemInfo(bagId, slotIndex)
                    local candidate = {
                        bagId = bagId,
                        slotIndex = slotIndex,
                        itemLink = itemLink,
                        craftingType = craftingType,
                        lineName = lineName,
                        traitType = option.traitType,
                        researchTime = option.researchTime,
                        quality = GetItemLinkDisplayQuality(itemLink) or 0,
                        sellPrice = sellPrice or 0,
                    }

                    if IsBetterCandidate(candidate, bestCandidate) then
                        bestCandidate = candidate
                    end
                end
            end
        end
    end

    return bestCandidate
end

local function IsCandidateStillValid(candidate)
    if not IsSaferResearchItem(candidate.bagId, candidate.slotIndex) then
        return false
    end

    if GetItemTrait(candidate.bagId, candidate.slotIndex) ~= candidate.traitType then
        return false
    end

    local craftingType, lineName = GetRetraitResearchLineInfo(candidate.bagId, candidate.slotIndex)

    return craftingType == candidate.craftingType
        and NormalizeText(lineName) == NormalizeText(candidate.lineName)
end

local function SelectResearchMode()
    if IsInGamepadPreferredMode() then
        if SCENE_MANAGER:GetCurrentScene():GetName() ~= "gamepad_smithing_research" then
            SCENE_MANAGER:Show("gamepad_smithing_research")
        end

        return
    end

    if
        SMITHING
        and SMITHING.modeBar
        and ZO_MenuBar_GetSelectedDescriptor(SMITHING.modeBar) ~= SMITHING_MODE_RESEARCH
    then
        ZO_MenuBar_SelectDescriptor(SMITHING.modeBar, SMITHING_MODE_RESEARCH, true, false)
    end
end

local function FindNextResearchCandidate(definition, settings, busyLines)
    local selectedCandidate
    local sequence = research.GetResearchSequence(definition)

    for _, option in ipairs(sequence) do
        if
            not busyLines[option.lineIndex]
            and settings.lines[option.lineIndex][option.traitType]
            and IsTraitUnknown(definition, option.lineIndex, option.traitType)
        then
            local candidate = FindCandidate(definition, option)

            if candidate then
                if settings.priority == "sequence" then
                    return candidate
                end

                if
                    not selectedCandidate
                    or candidate.researchTime < selectedCandidate.researchTime
                then
                    selectedCandidate = candidate
                end
            end
        end
    end

    return selectedCandidate
end

function research.TryStartResearch()
    local definition = research.GetCraftDefinition(research.activeCraftingType)

    if
        not definition
        or not research.stationActive
        or research.actionPending
        or GetCraftingInteractionType() ~= definition.craftingType
    then
        return
    end

    local hasFreeSlot, busyLines = GetResearchState(definition)

    if not hasFreeSlot then
        return
    end

    local settings = research.GetCraftSettings(definition)
    local candidate = FindNextResearchCandidate(definition, settings, busyLines)

    if not candidate then
        return
    end

    research.actionPending = true
    research.actionId = (research.actionId or 0) + 1
    local actionId = research.actionId
    SelectResearchMode()

    zo_callLater(function()
        if
            research.actionId == actionId
            and research.stationActive
            and GetCraftingInteractionType() == definition.craftingType
            and IsCandidateStillValid(candidate)
        then
            research.pendingChatCandidate = candidate
            ResearchSmithingTrait(candidate.bagId, candidate.slotIndex)
        end

        zo_callLater(function()
            if research.actionId == actionId then
                research.actionPending = false
                research.pendingChatCandidate = nil
            end
        end, 1000)
    end, 150)
end

local ScheduleNextResearch

local function OnResearchStarted()
    local candidate = research.pendingChatCandidate
    research.pendingChatCandidate = nil

    if candidate then
        local settings = repair.GetSettings()

        if settings.researchChatMessages then
            local traitName =
                zo_strformat("<<C:1>>", GetString("SI_ITEMTRAITTYPE", candidate.traitType))
            local message = ua.GetString("REPAIR_RESEARCH_STARTED")

            if message then
                d(CHAT_PREFIX .. string.format(message, candidate.itemLink, traitName))
            end
        end
    end

    ScheduleNextResearch()
end

ScheduleNextResearch = function()
    if not research.stationActive then
        return
    end

    research.actionPending = false
    research.actionId = (research.actionId or 0) + 1

    zo_callLater(function()
        research.TryStartResearch()
    end, 500)
end

function research.Initialize()
    for _, definition in ipairs(CRAFT_DEFINITIONS) do
        research.GetCraftSettings(definition)
    end

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "StationStart",
        EVENT_CRAFTING_STATION_INTERACT,
        function(eventCode, craftingType)
            if not research.GetCraftDefinition(craftingType) then
                return
            end

            research.stationActive = true
            research.activeCraftingType = craftingType
            research.actionPending = false
            research.actionId = (research.actionId or 0) + 1

            zo_callLater(function()
                research.TryStartResearch()
            end, 500)
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "StationEnd",
        EVENT_END_CRAFTING_STATION_INTERACT,
        function()
            research.stationActive = false
            research.activeCraftingType = nil
            research.actionPending = false
            research.pendingChatCandidate = nil
            research.actionId = (research.actionId or 0) + 1
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "Started",
        EVENT_SMITHING_TRAIT_RESEARCH_STARTED,
        OnResearchStarted
    )

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "Completed",
        EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED,
        ScheduleNextResearch
    )
end
