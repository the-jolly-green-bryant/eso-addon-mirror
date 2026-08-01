KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.QuickSlots = KyzderpsDerps.QuickSlots or {}
local QuickSlots = KyzderpsDerps.QuickSlots

---------------------------------------------------------------------
-- Saved options structure
---------------------------------------------------------------------
--[[
KyzderpsDerps.savedOptions.quickSlots.savedWheels = {
    [HOTBAR_CATEGORY_TOOL_WHEEL] = {
        [1] = {
            actionType = ACTION_TYPE_EMOTE,
            actionId = 715,
        },
        [2] = {},
    },
    [HOTBAR_CATEGORY_ALLY_WHEEL] = {},
    [HOTBAR_CATEGORY_MEMENTO_WHEEL] = {},
    [HOTBAR_CATEGORY_EMOTE_WHEEL] = {},
}
]]


---------------------------------------------------------------------
-- Saving wheels
---------------------------------------------------------------------
local hotbarCategories = {
    [HOTBAR_CATEGORY_TOOL_WHEEL] = "Tools",
    [HOTBAR_CATEGORY_ALLY_WHEEL] = "Allies",
    [HOTBAR_CATEGORY_MEMENTO_WHEEL] = "Mementos",
    [HOTBAR_CATEGORY_EMOTE_WHEEL] = "Emotes",
}

local slotTypes = {
    [ACTION_TYPE_ABILITY] = "ABILITY",
    [ACTION_TYPE_CHAMPION_SKILL] = "CHAMPION_SKILL",
    [ACTION_TYPE_COLLECTIBLE] = "COLLECTIBLE",
    [ACTION_TYPE_EMOTE] = "EMOTE",
    [ACTION_TYPE_ITEM] = "ITEM",
    [ACTION_TYPE_NOTHING] = "----",
    [ACTION_TYPE_QUEST_ITEM] = "QUEST_ITEM",
    [ACTION_TYPE_QUICK_CHAT] = "QUICK_CHAT",
}

local function ResolveActionIdToReadable(actionId, actionType)
    if (actionType == ACTION_TYPE_EMOTE) then
        return GetEmoteSlashNameByIndex(GetEmoteIndex(actionId))
    elseif (actionType == ACTION_TYPE_COLLECTIBLE) then
        return GetCollectibleLink(actionId, LINK_STYLE_BRACKETS)
    end
    return ""
end

local function SaveWheels()
    local newWheels = {}

    for hotbarCategory, name in pairs(hotbarCategories) do
        newWheels[hotbarCategory] = {}
        KyzderpsDerps:dbg(name)
        for actionSlotIndex = 1, 8 do
            local actionType = GetSlotType(actionSlotIndex, hotbarCategory)
            local actionId = GetSlotBoundId(actionSlotIndex, hotbarCategory)
            newWheels[hotbarCategory][actionSlotIndex] = {actionType = actionType, actionId = actionId}
            KyzderpsDerps:dbg(string.format(".  [%d] = %s %d (%s)",
                actionSlotIndex,
                slotTypes[actionType],
                actionId,
                ResolveActionIdToReadable(actionId, actionType)))
        end
    end

    KyzderpsDerps.savedOptions.quickSlots.savedWheels = newWheels
    KyzderpsDerps:msg("Saved quickslot wheels")
end


---------------------------------------------------------------------
-- Loading wheels
---------------------------------------------------------------------
local function AssignSlot(actionType, actionId, actionSlotIndex, hotbarCategory)
    if IsProtectedFunction("SelectSlotSimpleAction") then
        CallSecureProtected("SelectSlotSimpleAction", actionType, actionId, actionSlotIndex, hotbarCategory)
    else
        SelectSlotSimpleAction(actionType, actionId, actionSlotIndex, hotbarCategory)
    end
end

local function ClearQuickSlot(actionSlotIndex, hotbarCategory)
    if IsProtectedFunction("ClearSlot") then
        CallSecureProtected("ClearSlot", actionSlotIndex, hotbarCategory)
    else
        ClearSlot(actionSlotIndex, hotbarCategory)
    end
end

local wheelQueue = {}

-- Recursive function to load wheels one after the other
local function LoadWheelCategory()
    if (#wheelQueue < 1) then
        KyzderpsDerps:msg("Loaded all quickslot wheels.")
        return
    end

    local hotbarCategory = table.remove(wheelQueue, 1)
    local name = hotbarCategories[hotbarCategory]
    KyzderpsDerps:msg(string.format("Loading %s wheel...", name))

    local savedWheels = KyzderpsDerps.savedOptions.quickSlots.savedWheels
    for actionSlotIndex = 1, 8 do
        if (savedWheels[hotbarCategory][actionSlotIndex]) then
            local actionType = savedWheels[hotbarCategory][actionSlotIndex].actionType
            local actionId = savedWheels[hotbarCategory][actionSlotIndex].actionId
            if (actionType == 0) then
                ClearQuickSlot(actionSlotIndex, hotbarCategory)
            else
                KyzderpsDerps:dbg(string.format("%s [%d] %s",
                    name,
                    actionSlotIndex,
                    ResolveActionIdToReadable(actionId, actionType)))
                AssignSlot(actionType, actionId, actionSlotIndex, hotbarCategory)
            end
        end
    end

    if (#wheelQueue < 1) then
        KyzderpsDerps:msg("Loaded all quickslot wheels.")
        return
    end

    zo_callLater(LoadWheelCategory, 4000)
end

-- Loading them all results in a warning for spamming, so need to delay in between wheels
local function LoadWheels()
    KyzderpsDerps:msg("Please wait to avoid being kicked for spamming...")
    local savedWheels = KyzderpsDerps.savedOptions.quickSlots.savedWheels
    wheelQueue = {}
    for hotbarCategory, _ in pairs(hotbarCategories) do
        if (savedWheels[hotbarCategory]) then
            table.insert(wheelQueue, hotbarCategory)
        end
    end

    LoadWheelCategory()
end
-- /script KyzderpsDerps.QuickSlots.LoadWheels()


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
local function GetSavedWheelsText()
    local text = ""

    local savedWheels = KyzderpsDerps.savedOptions.quickSlots.savedWheels
    for hotbarCategory, name in pairs(hotbarCategories) do
        text = string.format("%s\n%s", text, name)
        if (savedWheels[hotbarCategory]) then
            for actionSlotIndex = 1, 8 do
                if (savedWheels[hotbarCategory][actionSlotIndex]) then
                    local actionType = savedWheels[hotbarCategory][actionSlotIndex].actionType
                    local actionId = savedWheels[hotbarCategory][actionSlotIndex].actionId
                    if (actionType ~= 0) then
                        text = string.format("%s\n    [%d] = %s",
                            text,
                            actionSlotIndex,
                            ResolveActionIdToReadable(actionId, actionType))
                    end
                end
            end
        end
    end

    if (text == "") then return "None" end
    return text
end

function QuickSlots.GetSaveLoadSettings()
    return {
        {
            type = "description",
            title = nil,
            text = "Quickslot wheels are not saved account-wide, and setting them up on multiple characters can take some work. This allows you to save the Tools, Allies, Mementos, and Emote wheels (NOT the main Quickslots!) from one character, then apply them to other characters.",
            width = "full",
        },
        {
            type = "button",
            name = "Save Wheels",
            tooltip = "Save the current character's quickslots so you can load it on another character",
            func = SaveWheels,
            width = "half",
        },
        {
            type = "button",
            name = "Apply Wheels",
            tooltip = "Apply the saved quickslots to this character. This will take half a minute, to avoid getting kicked for spam",
            func = LoadWheels,
            warning = "Apply the below quickslots to this character. This cannot be undone! It will take half a minute, to avoid getting kicked for spam",
            isDangerous = true,
            width = "half",
        },
        {
            type = "description",
            title = "Your saved quickslot wheels:",
            text = GetSavedWheelsText,
            width = "full",
        }
    }
end
