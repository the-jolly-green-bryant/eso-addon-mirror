MinistryOfNormalWalks = MinistryOfNormalWalks or {}
local MNW = MinistryOfNormalWalks
MNW.name = "MinistryOfNormalWalks"
MNW.version = "1.0.0"

local defaultOptions = {
    debug = false,
    printChat = false,
    pollingDelay = 300,
    enabled = false,
    muteSound = false,
    blockAlert = false,
    onMove = {
        personality = 0,
    },
    onIdle = {
        personality = 0,
    },
}

---------------------------------------------------------------------------------------------------
local function PrintDebug(message)
    if (MNW.savedOptions.debug) then
        d(message)
    end
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local shouldMute = false

local reasons = {
    [COLLECTIBLE_USAGE_BLOCK_REASON_ACTIVE_DIG_SITE_REQUIRED] = "ACTIVE_DIG_SITE_REQUIRED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_BLACKLISTED] = "BLACKLISTED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_LEADERBOARD_EVENT] = "BLOCKED_BY_LEADERBOARD_EVENT",
    [COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_SUBZONE] = "BLOCKED_BY_SUBZONE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_ZONE] = "BLOCKED_BY_ZONE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_CATEGORY_REQUIREMENT_FAILED] = "CATEGORY_REQUIREMENT_FAILED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_COLLECTIBLE_ALREADY_QUEUED] = "COLLECTIBLE_ALREADY_QUEUED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_COMPANION_INTRO_QUEST] = "COMPANION_INTRO_QUEST",
    [COLLECTIBLE_USAGE_BLOCK_REASON_COMPANION_INTRO_QUEST_BLOCKED_BY_ZONE] = "COMPANION_INTRO_QUEST_BLOCKED_BY_ZONE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_COMPANION_MENU_REQUIRED] = "COMPANION_MENU_REQUIRED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_DEAD] = "DEAD",
    [COLLECTIBLE_USAGE_BLOCK_REASON_DEFAULT_ALREADY_ACTIVE] = "DEFAULT_ALREADY_ACTIVE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_DUELING] = "DUELING",
    [COLLECTIBLE_USAGE_BLOCK_REASON_GROUP_FULL] = "GROUP_FULL",
    [COLLECTIBLE_USAGE_BLOCK_REASON_HAS_PENDING_COMPANION] = "HAS_PENDING_COMPANION",
    [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_ALLIANCE] = "INVALID_ALLIANCE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_CLASS] = "INVALID_CLASS",
    [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_COLLECTIBLE] = "INVALID_COLLECTIBLE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_GENDER] = "INVALID_GENDER",
    [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_RACE] = "INVALID_RACE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_IN_AIR] = "IN_AIR",
    [COLLECTIBLE_USAGE_BLOCK_REASON_IN_COMBAT] = "IN_COMBAT",
    [COLLECTIBLE_USAGE_BLOCK_REASON_IN_HIDEY_HOLE] = "IN_HIDEY_HOLE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_IN_WATER] = "IN_WATER",
    [COLLECTIBLE_USAGE_BLOCK_REASON_MAX_NUMBER_EQUIPPED] = "MAX_NUMBER_EQUIPPED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_MOUNT_IN_COMBAT] = "MOUNT_IN_COMBAT",
    [COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED] = "NOT_BLOCKED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_ON_COOLDOWN] = "ON_COOLDOWN",
    [COLLECTIBLE_USAGE_BLOCK_REASON_ON_MOUNT] = "ON_MOUNT",
    [COLLECTIBLE_USAGE_BLOCK_REASON_PLACED_IN_HOUSE] = "PLACED_IN_HOUSE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_QUEST_FOLLOWER] = "QUEST_FOLLOWER",
    [COLLECTIBLE_USAGE_BLOCK_REASON_TARGET_REQUIRED] = "TARGET_REQUIRED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_TEMPORARILY_DISABLED] = "TEMPORARILY_DISABLED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_UNACQUIRED_SKILL] = "UNACQUIRED_SKILL",
    [COLLECTIBLE_USAGE_BLOCK_REASON_UNUSABLE_BY_COMPANION] = "UNUSABLE_BY_COMPANION",
    [COLLECTIBLE_USAGE_BLOCK_REASON_WORLD_BOSS] = "WORLD_BOSS",
    [COLLECTIBLE_USAGE_BLOCK_REASON_WORLD_EVENT] = "WORLD_EVENT",
}

local function CanUseCollectible(collectibleId)
    if (collectibleId == 0) then return true end -- This can happen if deactivating collectible
    if (not IsCollectibleBlocked(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) and IsCollectibleUsable(collectibleId)) then
        return true
    end

    local reason = GetCollectibleBlockReason(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    PrintDebug(string.format("|cFF6600Can't use collectible because %s|r", reasons[reason] or "???"))
    return false
end

-- Use all collectibles in the list, then listen for success or failure. On success, cancel the polling
local retries = 0
local function UseCollectibles(collectibleIds)
    retries = retries + 1
    if (retries > 3) then
        PrintDebug("too many retries, stopping")
        shouldMute = false
        EVENT_MANAGER:UnregisterForUpdate(MNW.name .. "UseCollectiblesUpdate")
        EVENT_MANAGER:UnregisterForEvent(MNW.name .. "TestCollectible", EVENT_COLLECTIBLE_UPDATED)
        EVENT_MANAGER:UnregisterForEvent(MNW.name .. "TestCollectible", EVENT_COLLECTIBLE_USE_RESULT)
        return
    end

    -- Use all at once, because staggering can make them go on cooldown
    local collectibleId = collectibleIds[1]
    if (not CanUseCollectible(collectibleId)) then return end
    for i = 1, #collectibleIds do
        UseCollectible(collectibleIds[i])
    end

    -- Even if the API says the collectible isn't blocked, it could still be because of cooldown
    -- So attempt to use it, and listen for change
    PrintDebug("Listening: |t20:20:" .. GetCollectibleIcon(collectibleId) .. "|t")
    EVENT_MANAGER:RegisterForEvent(MNW.name .. "TestCollectible", EVENT_COLLECTIBLE_UPDATED, function(_, id)
        if (id == collectibleId) then
            EVENT_MANAGER:UnregisterForEvent(MNW.name .. "TestCollectible", EVENT_COLLECTIBLE_UPDATED)
            EVENT_MANAGER:UnregisterForEvent(MNW.name .. "TestCollectible", EVENT_COLLECTIBLE_USE_RESULT)

            -- On success, stop polling
            PrintDebug("was probably successful")
            shouldMute = false
            EVENT_MANAGER:UnregisterForUpdate(MNW.name .. "UseCollectiblesUpdate")
        end
    end)

    -- This doesn't provide ID, so we'll just assume it's from ours
    EVENT_MANAGER:RegisterForEvent(MNW.name .. "TestCollectible", EVENT_COLLECTIBLE_USE_RESULT, function(_, result)
        EVENT_MANAGER:UnregisterForEvent(MNW.name .. "TestCollectible", EVENT_COLLECTIBLE_USE_RESULT)

        -- If the collectible failed, then it won't get updated, so stop listening for it
        if (result ~= COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED) then
            PrintDebug(string.format("|cFF3300Collectible failed because %s|r", reasons[result] or "???"))
            EVENT_MANAGER:UnregisterForEvent(MNW.name .. "TestCollectible", EVENT_COLLECTIBLE_UPDATED)
        end
    end)
end

local function PollUseCollectibles(collectibleIds)
    if (#collectibleIds == 0) then return end

    shouldMute = true
    retries = 0
    EVENT_MANAGER:RegisterForUpdate(MNW.name .. "UseCollectiblesUpdate", MNW.savedOptions.pollingDelay, function() UseCollectibles(collectibleIds) end)
    UseCollectibles(collectibleIds)
end

---------------------------------------------------------------------
-- Constantly poll for moving
---------------------------------------------------------------------
local moving = false

local function MaybePollCollectible(desiredId)
    if (desiredId == 0) then
        local active = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY)
        if (active ~= 0) then
            PollUseCollectibles({active})
        end
    elseif (not IsCollectibleActive(desiredId)) then
        PollUseCollectibles({desiredId})
    end
end

local function RegisterUpdates()
    if (not MNW.savedOptions.enabled) then return end

    EVENT_MANAGER:RegisterForUpdate(MNW.name .. "PollMoving", 500, function()
        local mov = IsPlayerMoving()
        if (mov == moving) then return end
        moving = mov

        -- Personality doesn't do anything anyway
        if (IsMounted() or IsUnitSwimming("player")) then
            return
        end

        if moving then
            PrintDebug("now moving")
            MaybePollCollectible(MNW.savedOptions.onMove.personality)
        else
            PrintDebug("stopped")
            MaybePollCollectible(MNW.savedOptions.onIdle.personality)
        end
    end)
end
MNW.RegisterUpdates = RegisterUpdates

local function UnregisterUpdates()
    EVENT_MANAGER:UnregisterForUpdate(MNW.name .. "PollMoving")
end
MNW.UnregisterUpdates = UnregisterUpdates

---------------------------------------------------------------------
-- Initialize
local function Initialize()
    MNW.savedOptions = ZO_SavedVars:New("MinistryOfNormalWalksSavedVariables", 2, "Options", defaultOptions)

    MNW.CreateSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(MNW.name .. "FirstActivated", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(MNW.name .. "FirstActivated", EVENT_PLAYER_ACTIVATED)

        RegisterUpdates()
    end)

    -- Mute collectible sounds when they're about to happen
    ZO_PreHook("PlaySound", function(sound)
        if (MNW.savedOptions.muteSound) then
            if (sound == SOUNDS.COLLECTIBLE_ACTIVATED
                or sound == SOUNDS.COLLECTIBLE_DEACTIVATED
                or sound == SOUNDS.COLLECTIBLE_ON_COOLDOWN) then
                return shouldMute
            end
        end
    end)

    -- Block "This collectible is not ready yet"
    ZO_PreHook(ZO_AlertText_GetHandlers(), EVENT_COLLECTIBLE_USE_RESULT, function(result)
        if (result ~= COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED and MNW.savedOptions.blockAlert) then
            return shouldMute
        end
    end)

    SLASH_COMMANDS["/normalwalk"] = function()
        MNW.savedOptions.enabled = not MNW.savedOptions.enabled
        UnregisterUpdates()
        RegisterUpdates()
        if (MNW.savedOptions.enabled) then
            CHAT_SYSTEM:AddMessage("Auto personality change ON")
        else
            CHAT_SYSTEM:AddMessage("Auto personality change OFF")
        end
    end
end

---------------------------------------------------------------------
-- On load
local function OnAddOnLoaded(_, addonName)
    if (addonName == MNW.name) then
        EVENT_MANAGER:UnregisterForEvent(MNW.name, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(MNW.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
