local SS = {
    name = "SurveySentinel",
    slotState = {},
    lastLootAtMs = 0,
}

local SURVEY_FUN_OPENERS = {
    "Field report:",
    "Survey bulletin:",
    "Crafting dispatch:",
    "Route update:",
    "Log entry:",
    "Foreman note:",
}

local SURVEY_FUN_ACTIONS = {
    "the node cluster has been thoroughly negotiated.",
    "your pickaxe delivered premium customer service.",
    "the local ore now fears your footsteps.",
    "writ board economics continue to improve.",
    "your resource route remains highly suspiciously efficient.",
    "mudcrabs filed another strongly worded complaint.",
    "the harvest bag is humming with confidence.",
}

local SURVEY_FUN_CLOSERS = {
    "Carry on, professional gatherer.",
    "The crafting station awaits your return.",
    "Your mount requests fewer sharp turns.",
    "Operational excellence has been noted.",
    "Please wave to the next node cluster.",
    "Inventory morale remains high.",
}

local LAST_SURVEY_FUN_OPENERS = {
    "Stack cleared:",
    "Final report consumed:",
    "Survey stack complete:",
    "Zero remaining:",
    "Mission accomplished:",
}

local LAST_SURVEY_FUN_ACTIONS = {
    "time to restock at the writ board.",
    "the route planner can finally exhale.",
    "even the ore vein looked impressed.",
    "inventory logistics salute your dedication.",
    "the crafting gods are mildly amused.",
    "your shovel has earned a paid vacation.",
}

local LOOT_WINDOW_MS = 1500

local function NormalizeName(name)
    if not name or name == "" then
        return nil
    end
    return zo_strlower(zo_strformat("<<C:1>>", name))
end

local function SeedRandom()
    if SS.randomSeeded then
        return
    end

    local seed = 1
    if type(GetTimeStamp) == "function" then
        seed = tonumber(GetTimeStamp()) or seed
    end

    math.randomseed(seed)
    math.random()
    SS.randomSeeded = true
end

local function PickRandomLine(lines)
    if not lines or #lines == 0 then
        return nil
    end
    local index = math.random(1, #lines)
    return lines[index]
end

local function BuildFunLine(surveysLeft)
    if surveysLeft == 0 then
        return string.format(
            "%s %s",
            PickRandomLine(LAST_SURVEY_FUN_OPENERS) or "Stack cleared:",
            PickRandomLine(LAST_SURVEY_FUN_ACTIONS) or "time to restock."
        )
    end

    return string.format(
        "%s %s %s",
        PickRandomLine(SURVEY_FUN_OPENERS) or "Survey update:",
        PickRandomLine(SURVEY_FUN_ACTIONS) or "the route continues.",
        PickRandomLine(SURVEY_FUN_CLOSERS) or "Carry on."
    )
end

local function MarkRecentLoot()
    if type(GetFrameTimeMilliseconds) ~= "function" then
        return
    end
    SS.lastLootAtMs = GetFrameTimeMilliseconds()
end

local function IsLikelySurveyConsumption(itemSoundCategory)
    if ITEM_SOUND_CATEGORY_LOOT ~= nil and itemSoundCategory ~= nil and itemSoundCategory ~= ITEM_SOUND_CATEGORY_LOOT then
        return false
    end

    if type(GetFrameTimeMilliseconds) == "function" then
        if not SS.lastLootAtMs or SS.lastLootAtMs <= 0 then
            return false
        end
        local elapsed = GetFrameTimeMilliseconds() - SS.lastLootAtMs
        if elapsed < 0 or elapsed > LOOT_WINDOW_MS then
            return false
        end
    end

    return true
end

local function GetSurveyLinkAt(bagId, slotIndex)
    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
    if not itemLink or itemLink == "" then
        return nil
    end

    if type(GetItemLinkSpecializedItemType) == "function" and SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT ~= nil then
        local specializedItemType = GetItemLinkSpecializedItemType(itemLink)
        if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then
            return itemLink
        end
    end

    local displayName = GetItemLinkName(itemLink)
    local normalizedName = NormalizeName(displayName)
    if normalizedName and string.find(normalizedName, "survey", 1, true) then
        return itemLink
    end

    return nil
end

local function BuildSlotSnapshot(bagId, slotIndex)
    local stackSize = GetSlotStackSize(bagId, slotIndex)
    if not stackSize or stackSize <= 0 then
        return nil
    end

    local surveyLink = GetSurveyLinkAt(bagId, slotIndex)
    if not surveyLink then
        return {
            stack = stackSize,
            isSurvey = false,
        }
    end

    local displayName = GetItemLinkName(surveyLink)
    return {
        stack = stackSize,
        isSurvey = true,
        displayName = zo_strformat("<<1>>", displayName),
        normalizedName = NormalizeName(displayName),
    }
end

local function RebuildBackpackState()
    SS.slotState = {}
    local bagSize = GetBagSize(BAG_BACKPACK) or 0
    for slotIndex = 0, bagSize - 1 do
        SS.slotState[slotIndex] = BuildSlotSnapshot(BAG_BACKPACK, slotIndex)
    end
end

local function CountSurveyByNormalizedName(normalizedSurveyName)
    if not normalizedSurveyName then
        return 0
    end

    local total = 0
    local bagSize = GetBagSize(BAG_BACKPACK) or 0
    for slotIndex = 0, bagSize - 1 do
        local snapshot = BuildSlotSnapshot(BAG_BACKPACK, slotIndex)
        if snapshot and snapshot.isSurvey and snapshot.normalizedName == normalizedSurveyName then
            total = total + (snapshot.stack or 0)
        end
    end

    return total
end

local function PrintSurveyConsumed(previousSnapshot)
    local surveyName = previousSnapshot.displayName or "Unknown"
    local surveysLeft = CountSurveyByNormalizedName(previousSnapshot.normalizedName)
    local message = string.format("You did %s survey, you have %d left in your inventory.", surveyName, surveysLeft)

    local funLine = BuildFunLine(surveysLeft)
    if funLine and funLine ~= "" then
        message = string.format("%s %s", message, funLine)
    end

    d(message)
end

function SS.OnInventorySingleSlotUpdate(_, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    if bagId ~= BAG_BACKPACK then
        return
    end

    local previous = SS.slotState[slotIndex]
    local current = BuildSlotSnapshot(BAG_BACKPACK, slotIndex)

    if INVENTORY_UPDATE_REASON_DEFAULT ~= nil and inventoryUpdateReason ~= nil and inventoryUpdateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then
        SS.slotState[slotIndex] = current
        return
    end

    local itemCountDelta = tonumber(stackCountChange)
    if itemCountDelta == nil then
        local previousStack = previous and previous.stack or 0
        local currentStack = current and current.stack or 0
        itemCountDelta = currentStack - previousStack
    end

    if previous and previous.isSurvey and (itemCountDelta or 0) < 0 and not isNewItem and IsLikelySurveyConsumption(itemSoundCategory) then
        PrintSurveyConsumed(previous)
    end

    SS.slotState[slotIndex] = current
end

function SS.OnLootReceived(_, _, _, _, _, lootType, selfLoot)
    if LOOT_TYPE_ITEM ~= nil and lootType ~= LOOT_TYPE_ITEM then
        return
    end
    if selfLoot == false then
        return
    end

    MarkRecentLoot()
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= SS.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(SS.name, EVENT_ADD_ON_LOADED)
    SeedRandom()
    RebuildBackpackState()
    if EVENT_LOOT_RECEIVED ~= nil then
        EVENT_MANAGER:RegisterForEvent(SS.name, EVENT_LOOT_RECEIVED, SS.OnLootReceived)
    end
    EVENT_MANAGER:RegisterForEvent(SS.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SS.OnInventorySingleSlotUpdate)
    d("SurveySentinel loaded.")
end

EVENT_MANAGER:RegisterForEvent(SS.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
