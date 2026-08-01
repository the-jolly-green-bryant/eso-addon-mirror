--[[
    Traveller by Patrick Smyth
    
    Module to handle all of the types of jump routine, error handling and recovery.

    All of this is centralised because so much of the error handling and recovery is common
    to all types of jump.

--]]
Gotos = { }

-- ==========================================================================================
--
-- Local constants
--

-- l_JUMP_PREFIX = "xyz" -- For Testing
local l_JUMP_PREFIX = "" -- Normal

local l_JUMP_SUCCESS = 0

local l_JUMP_STATE_IDLE         = 0
local l_JUMP_STATE_STARTED      = 1
local l_JUMP_STATE_FAILED       = 2
local l_JUMP_STATE_CANCEL       = 3
local l_JUMP_STATE_DONE         = 4

local l_ABILITY_ID_RECALL   = 6811
local l_RETRY_MAX   = 3

-- Data
local l_JumpBlock = {
    nameSpace = "TravellerJump",
    nameCount = 0,
    retryCount = 0,
    currentEntry = { },
    playerCharacter = "",
    reason = l_JUMP_SUCCESS,
    eventCode = 0,
    poolSize = 0,
    jumpPool = { },
    jumpQueue = nil,
    jumpState = l_JUMP_STATE_IDLE,
    enQueWait = 1000
}

-- ==========================================================================================
--
-- Event Handlers
--

local function e_FailJump1(eventCode, inCombat)
    -- Combat state changed
    if inCombat and (l_JumpBlock.jumpState == l_JUMP_STATE_STARTED) then
        l_JumpBlock.eventCode = 1
        l_JumpBlock.reason = 0
        l_JumpBlock.jumpState = l_JUMP_STATE_FAILED
    end
end

local function e_FailJump2(eventCode,
                            result,
                            isError,
                            abilityName,
                            abilityGraphic,
                            abilityActionSlotType,
                            sourceName,
                            sourceType,
                            targetName,
                            targetType,
                            hitValue,
                            powerType,
                            damageType,
                            log,
                            sourceUnitId,
                            targetUnitId,
                            abilityId)
    -- Error using recall ability
    if (targetName == l_JumpBlock.playerCharacter) and
        (l_JumpBlock.jumpState == l_JUMP_STATE_STARTED) then

        l_JumpBlock.eventCode = 2
        l_JumpBlock.reason = result
        l_JumpBlock.jumpState = l_JUMP_STATE_FAILED
    end
end

local function e_FailJump3(eventCode, error)
    -- Social error
    if l_JumpBlock.jumpState == l_JUMP_STATE_STARTED then
        l_JumpBlock.eventCode = 3
        l_JumpBlock.reason = error
        l_JumpBlock.jumpState = l_JUMP_STATE_FAILED
    end
end

local function e_FailJump4(eventCode, locked)
    -- Weapon pair lock change
    if (not locked) and (l_JumpBlock.jumpState == l_JUMP_STATE_STARTED) then
        l_JumpBlock.eventCode = 4
        l_JumpBlock.reason = 0
        l_JumpBlock.jumpState = l_JUMP_STATE_FAILED
    end
end

local function e_DoneJump(eventCode)
    -- Success
    if l_JumpBlock.jumpState == l_JUMP_STATE_STARTED then
        l_JumpBlock.jumpState = l_JUMP_STATE_DONE
    end
end

-- ==========================================================================================
--
-- Local routines
--

local function l_NextNameSpace()
    local newNS = ""
    l_JumpBlock.nameCount = l_JumpBlock.nameCount + 1
    newNS = l_JumpBlock.nameSpace .. tostring(l_JumpBlock.nameCount)
    return newNS
end

local function l_ShowJumpCost(nodeIndex)
    local rCost = GetRecallCost(nodeIndex)
    if rCost > 0 then
        local cType = GetRecallCurrency(nodeIndex)
        local currStr = ZO_CurrencyControl_BuildCurrencyString(cType, rCost)
        Traveller:Diag("Travel Cost: " .. currStr, 5)
    end
end

local function l_GetNodeName(nodeIndex)
    local nodeName = ""
    _, nodeName = GetFastTravelNodeInfo(nodeIndex)
    nodeName = nodeName or "Unknown"
    return nodeName
end

local function l_FormatName(characterName, accountName, nodeIndex)
    local fullName = ""
    local uChar = ""
    local uDisp = ""
    local houseName = nil
    local isDec = false

    characterName = characterName or ""
    if characterName ~= "" then
        uChar = ZO_StripGrammarMarkupFromCharacterName(characterName)
    end

    accountName = accountName or ""
    if accountName ~= "" then
        isDec = IsDecoratedDisplayName(accountName)
        if isDec then
            uDisp = accountName
        else
            uDisp = DecorateDisplayName(accountName)
        end
    end

    fullName = uChar .. uDisp

    if nodeIndex ~= nil then
        houseName = l_GetNodeName(nodeIndex)

        if fullName == "" then
            fullName = houseName
        else
            fullName = fullName .. "\\" .. houseName
        end
    end

    return fullName
end

local function l_AnnounceJump(entry)
    l_JumpBlock.currentEntry = entry

    if entry.jType == G_JUMP_NODE then
        targetName = l_GetNodeName(entry.nodeIndex)
        l_ShowJumpCost(entry.nodeIndex)
        Traveller:Diag("Attempting to goto node: " .. targetName)
    elseif entry.jType == G_JUMP_LEADER then
        Traveller:Diag("Attempting to goto group leader")
    elseif entry.jType == G_JUMP_GROUP then
        targetName = l_FormatName(entry.character, entry.account)
        Traveller:Diag("Attempting to goto groupmate: " .. targetName)
    elseif entry.jType == G_JUMP_FRIEND then
        targetName = l_FormatName(entry.character, entry.account)
        Traveller:Diag("Attempting to goto friend: " .. targetName)
    elseif entry.jType == G_JUMP_HOUSE then
        targetName = l_FormatName(entry.character, entry.account, entry.nodeIndex)
        Traveller:Diag("Attempting to goto house: " .. targetName)
    else
        targetName = l_FormatName(entry.character, entry.account)
        Traveller:Diag("Attempting to goto guildmate: " .. targetName)
    end
end

local function l_CancelJump()
    Queue:Reset(l_JumpBlock.jumpQueue)
    l_JumpBlock.currentEntry = nil
    CancelCast()
end

local function l_MakeJump(entry)
    local started = false
    local jumpPrefix = l_JUMP_PREFIX

    if l_JumpBlock.jumpState ~= l_JUMP_STATE_CANCEL then
        started = true
        l_JumpBlock.eventCode = 0
        l_JumpBlock.reason = l_JUMP_SUCCESS
        l_JumpBlock.jumpState = l_JUMP_STATE_STARTED

        if entry.jType == G_JUMP_NODE then
            FastTravelToNode(entry.nodeIndex)
        elseif entry.jType == G_JUMP_LEADER then
            JumpToGroupLeader()
        elseif entry.jType == G_JUMP_GROUP then
            -- JumpToGroupMember(entry.character)
            JumpToGroupMember(jumpPrefix .. entry.character) -- for error testing
        elseif entry.jType == G_JUMP_FRIEND then
            -- JumpToFriend(entry.account)
            JumpToFriend(jumpPrefix .. entry.account) -- for error testing
        elseif (entry.jType == G_JUMP_HOUSE) and (entry.account == nil) then
            FastTravelToNode(entry.nodeIndex)
        elseif (entry.jType == G_JUMP_HOUSE) and (entry.account ~= nil) then
            local houseId = nil

            if entry.nodeIndex ~= nil then
                houseId = GetFastTravelNodeHouseId(entry.nodeIndex)
            end
 
            if houseId == nil then
                -- JumpToHouse(entry.account)
                JumpToHouse(jumpPrefix .. entry.account)
            else
                -- JumpToSpecificHouse(entry.account, houseId)
                JumpToSpecificHouse(jumpPrefix .. entry.account, houseId)
            end
        else
            -- JumpToGuildMember(entry.account)
            JumpToGuildMember(jumpPrefix .. entry.account) -- for error testing
        end
    else
        l_CancelJump()
    end

    return started
end

local function l_JumpStart()
    local entry = Queue:Pop(l_JumpBlock.jumpQueue)
    local started = false

    if (entry ~= nil) and (l_JumpBlock.jumpState ~= l_JUMP_STATE_CANCEL) then
        l_AnnounceJump(entry)
        l_JumpBlock.retryCount = 0
        l_JumpBlock.currentEntry = entry
        started = l_MakeJump(entry)

    elseif l_JumpBlock.jumpState == l_JUMP_STATE_CANCEL then
        l_CancelJump()
    end

    return started
end

local function l_JumpRestart()
    local entry = l_JumpBlock.currentEntry
    local started = false

    if (entry ~= nil) and
        (l_JumpBlock.retryCount < l_RETRY_MAX) and
        (l_JumpBlock.jumpState ~= l_JUMP_STATE_CANCEL) then

        Traveller:Diag("Retrying Jump")
        l_JumpBlock.retryCount = l_JumpBlock.retryCount + 1
        started = l_MakeJump(entry)
    elseif l_JumpBlock.jumpState == l_JUMP_STATE_CANCEL then
        l_CancelJump()
    end

    return started
end

local function l_DecideRestart(eventCode, reason)
    local canRestart = true
    local tmpString = tostring(eventCode) .. "/" .. tostring(reason)

    Traveller:Diag("Jump Failed - reason code: " .. tmpString, 70)

    if eventCode == 1 then
        canRestart = false
    elseif eventCode == 3 then
        if (reason == SOCIAL_RESULT_CHARACTER_NOT_FOUND) or
            (reason == SOCIAL_RESULT_ACCOUNT_OFFLINE) or
            (reason == SOCIAL_RESULT_BEING_ARRESTED) or
            (reason == SOCIAL_RESULT_DISABLED) or
            (reason == SOCIAL_RESULT_NOT_GROUPED) or
            (reason == SOCIAL_RESULT_CANT_JUMP_SELF) or
            (reason == SOCIAL_RESULT_CANT_JUMP_TARGET_IN_HOMESHOW) or
            (reason == SOCIAL_RESULT_CANT_JUMP_TARGET_PREVIEWING_HOUSE) or
            (reason == SOCIAL_RESULT_NO_LOCATION) or
            (reason == SOCIAL_RESULT_NOT_SAME_GROUP) or
            (reason == SOCIAL_RESULT_WRONG_ALLIANCE) or
            (reason == SOCIAL_RESULT_NOT_IN_SAME_GROUP) or
            (reason == SOCIAL_RESULT_CANT_JUMP_INVALID_TARGET) then

            canRestart = false
        end
    elseif eventCode == 4 then
        canRestart = false
    end

    return canRestart
end

local function l_JumpHandler()
    local started = false
    Traveller:Diag("Jump Handler started", 70)

    if l_JumpBlock.jumpState == l_JUMP_STATE_IDLE then
        -- nothing happening so see if we can start something
        started = l_JumpStart()

    elseif l_JumpBlock.jumpState == l_JUMP_STATE_STARTED then
        -- Jump in progress - nothing happened - requeue
        started = true

    elseif l_JumpBlock.jumpState == l_JUMP_STATE_DONE then
        -- Successful jump happened
        Traveller:Diag("Jump was successful")
        Queue:Reset(l_JumpBlock.jumpQueue)
        l_JumpBlock.jumpState = l_JUMP_STATE_IDLE

    elseif l_JumpBlock.jumpState == l_JUMP_STATE_FAILED then
        -- Jump failed
        CancelCast() -- just in case it is still in progress
        local canRestart = l_DecideRestart(l_JumpBlock.eventCode, l_JumpBlock.reason)
 
        if canRestart then
            started = l_JumpRestart()
        end

        if not started then
            started = l_JumpStart()   -- next entry
        end
    elseif l_JumpBlock.jumpState == l_JUMP_STATE_CANCEL then
        -- Jump failed
        Traveller:Diag("Jump cancelled by user", 30)
        l_CancelJump()
    else
        Traveller:Diag("Unknown Jump State: " .. tostring(l_JumpBlock.jumpState))
    end

    if started then
        Traveller:Diag("Queueing Handler", 70)
        Gotos:EnqueueHandler()
    end

    Traveller:Diag("Jump Handler ended", 70)
end

-- This is really a local function but the RTS will not allow it
function Gotos:EnqueueHandler()
    zo_callLater(l_JumpHandler, l_JumpBlock.enQueWait)
end

local function l_CreateEntry(jumpType, displayName, characterName, nodeIndex)
    local entry = nil
    local validArgs = false

    if jumpType == G_JUMP_NODE then
        validArgs = Utils:IsNumber(nodeIndex)

        if not validArgs then
            Traveller:Diag("Invalid node index")
            Traveller:Diag("node index: ".. tostring(nodeIndex), 70)
        end

    elseif jumpType == G_JUMP_LEADER then
        validArgs = true

    elseif jumpType == G_JUMP_HOUSE then
        if nodeIndex ~= nil then
            validArgs = Utils:IsNumber(nodeIndex)
        else
            validArgs = Utils:IsString(displayName)
        end

        if not validArgs then
            Traveller:Diag("Invalid house description")
        end

    elseif jumpType == G_JUMP_GROUP then
        validArgs = Utils:IsString(characterName)
 
        if not validArgs then
            Traveller:Diag("Empty character name")
        end
    else
        -- we assume jump to friend or guildmate
        validArgs = Utils:IsString(displayName)

        if not validArgs then
            Traveller:Diag("Empty display name")
        end
    end

    if validArgs then
        entry = { jType = jumpType,
                    account = displayName,
                    character = characterName,
                    nodeIndex = nodeIndex }
   end

    return entry
end

-- ==========================================================================================
--
--  External Interface
--

function Gotos:Initialise()
    local nameSpace = l_NextNameSpace()
    local castTime = 1000

    EVENT_MANAGER:RegisterForEvent(nameSpace, EVENT_PLAYER_COMBAT_STATE, e_FailJump1)

    nameSpace = l_NextNameSpace()
    EVENT_MANAGER:RegisterForEvent(nameSpace, EVENT_COMBAT_EVENT, e_FailJump2)
    EVENT_MANAGER:AddFilterForEvent(nameSpace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, RECALL_ABILITY_ID)
    EVENT_MANAGER:AddFilterForEvent(nameSpace, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, true)
    EVENT_MANAGER:AddFilterForEvent(nameSpace, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_IN_GAMEPAD_PREFERRED_MODE, false)

    nameSpace = l_NextNameSpace()
    EVENT_MANAGER:RegisterForEvent(nameSpace, EVENT_SOCIAL_ERROR, e_FailJump3)

    nameSpace = l_NextNameSpace()
    EVENT_MANAGER:RegisterForEvent(nameSpace, EVENT_WEAPON_PAIR_LOCK_CHANGED, e_FailJump4)

    nameSpace = l_NextNameSpace()
    EVENT_MANAGER:RegisterForEvent(nameSpace, EVENT_PLAYER_DEACTIVATED, e_DoneJump)

    _, castTime = GetAbilityCastInfo(l_ABILITY_ID_RECALL)

    if castTime ~= nil then
        l_JumpBlock.enQueWait = castTime / 2
    end

    l_JumpBlock.playerCharacter = GetRawUnitName("player")

    l_JumpBlock.jumpQueue = Queue:Create(true)
end

function Gotos:AddToQueue(jumpType, displayName, characterName, nodeIndex)

    -- Reset from cancel
    if l_JumpBlock.jumpState == l_JUMP_STATE_CANCEL then
        l_JumpBlock.jumpState = l_JUMP_STATE_IDLE
    end

    if l_JumpBlock.jumpState == l_JUMP_STATE_IDLE then
        local entry = l_CreateEntry(jumpType, displayName, characterName, nodeIndex)

        if entry ~= nil then
            local poolKey = ""
            if jumpType == G_JUMP_LEADER then
                poolKey = "Group Leader"
            elseif jumpType == G_JUMP_HOUSE then
                if Utils:IsEmptyStr(displayName) then
                    poolKey = l_GetNodeName(nodeIndex)
                else
                    poolKey = displayName
                end
            else
                poolKey = displayName
            end

            -- Discard of duplicate keys so we don't try to jump to the same target twice
            if l_JumpBlock.jumpPool[poolKey] == nil then
                l_JumpBlock.poolSize = l_JumpBlock.poolSize + 1
                l_JumpBlock.jumpPool[poolKey] = entry
            end
        end
    end
end

function Gotos:ActionQueue(qOrder)

    -- Reset from cancel
    if l_JumpBlock.jumpState == l_JUMP_STATE_CANCEL then
        l_JumpBlock.jumpState = l_JUMP_STATE_IDLE
    end

    -- Only start jumps if nothing in progress
    if (l_JumpBlock.jumpState == l_JUMP_STATE_IDLE) and
        (l_JumpBlock.poolSize > 0) then
        -- empty the pool into the queue
        -- make sure the data comes out in priority order
        local orderLen = 0
        local order = qOrder or ""

        if order == "" then
            order = Order:GetFull()
        end

        orderLen = string.len(order)

        for count = 1, orderLen do
            jType = string.sub(order, count, count)
            for akey, avalue in pairs(l_JumpBlock.jumpPool) do
                if avalue.jType == jType then
                    Queue:Push(l_JumpBlock.jumpQueue, avalue)
                    l_JumpBlock.jumpPool[akey] = nil
                    l_JumpBlock.poolSize = l_JumpBlock.poolSize - 1
                end
            end
        end

        if l_JumpBlock.poolSize ~= 0 then
            Traveller:Diag("Pool should be empty after actioning queue", 70)
            l_JumpBlock.poolSize = 0
        end

        -- Off we go
        l_JumpHandler()
    elseif l_JumpBlock.poolSize <= 0 then
        Traveller:Diag("Nothing to action")
        l_JumpBlock.poolSize = 0
    else
        Traveller:Diag("Jump already in progress")
    end
end

function Gotos:SingleJump(jumpType, displayName, characterName, nodeIndex)

    -- Reset from cancel
    if l_JumpBlock.jumpState == l_JUMP_STATE_CANCEL then
        l_JumpBlock.jumpState = l_JUMP_STATE_IDLE
    end

    -- Only jump if nothing in progress
    if l_JumpBlock.jumpState == l_JUMP_STATE_IDLE then
        local entry = l_CreateEntry(jumpType, displayName, characterName, nodeIndex)

        if entry ~= nil then
            Queue:Push(l_JumpBlock.jumpQueue, entry)

            -- Off we go
            l_JumpHandler()
        end
    else
        Traveller:Diag("Jump already in progress")
    end  
end

function Gotos:IsQueueEmpty()
    -- entries are actually stored in the pool until actioned
    local isEmpty = (l_JumpBlock.poolSize == 0)
    return isEmpty
end

function Gotos:CancelGoto()
    Traveller:Diag("Cancel Started", 70)

    if (l_JumpBlock.jumpState ~= l_JUMP_STATE_IDLE) then
        l_JumpBlock.jumpState = l_JUMP_STATE_CANCEL
        l_CancelJump()
        Traveller:Diag("Cancel Requested", 70)
        -- l_JumpBlock.jumpState = l_JUMP_STATE_CANCEL
    end
end