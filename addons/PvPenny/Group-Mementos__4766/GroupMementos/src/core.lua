GroupMementos = GroupMementos or {}
local GroupMementos = GroupMementos

---------------------------------------------------------------------
-- Ability IDs verified against the "Mudballed - Memento Counter" addon,
-- which uses this same EVENT_COMBAT_EVENT + ACTION_RESULT_EFFECT_GAINED pattern.
GroupMementos.MEMENTO_ORDER = { "mudball", "snowball", "blossom", "crow", "pie" }

GroupMementos.MEMENTO_DATA = {
    mudball = {
        id = 86774, -- Mudball (Mud Ball Pouch)
        label = "Mud Ball Pouch",
        icon = "/esoui/art/icons/collectible_memento_mudball_bag.dds",
        chatFormat = "|cFFFFFF%s|caaaaaa coated |cFFFFFF%s|caaaaaa in mud! (%d this session)",
    },
    pie = {
        id = 116879, -- Alliance Pie (Revelry Pie, from Jester's Festival Reward Boxes)
        label = "Revelry Pie",
        icon = "/esoui/art/icons/event_jestersfestival_revelerypie.dds",
        chatFormat = "|cFFFFFF%s|caaaaaa threw a pie at |cFFFFFF%s|caaaaaa! (%d this session)",
    },
    snowball = {
        id = 129540, -- Memento Throw Snowball (Everlasting Snowball)
        label = "Everlasting Snowball",
        icon = "/esoui/art/icons/collectible_memento_snowball.dds",
        chatFormat = "|cFFFFFF%s|caaaaaa hit |cFFFFFF%s|caaaaaa with a snowball! (%d this session)",
    },
    blossom = {
        id = 89372, -- Pelted! (Cherry Blossom Branch)
        label = "Cherry Blossom Branch",
        icon = "/art/fx/texture/cherryblossomground_01.dds",
        chatFormat = "|cFFFFFF%s|caaaaaa showered |cFFFFFF%s|caaaaaa in petals! (%d this session)",
    },
    crow = {
        id = 98378, -- Murderous Strike (Murderous Crow)
        label = "Murderous Crow",
        icon = "/esoui/art/icons/achievement_update16_016.dds",
        chatFormat = "|cFFFFFF%s|caaaaaa covered |cFFFFFF%s|caaaaaa in feathers! (%d this session)",
    },
}

---------------------------------------------------------------------
-- Keep track of who is currently in the group, keyed by formatted character
-- name (that's the only identifier EVENT_COMBAT_EVENT gives us) and mapped to
-- their account name (the "@Handle" ESO calls a Display Name, and players
-- commonly call their ESO user ID). Includes the local player, since
-- COMBAT_UNIT_TYPE_PLAYER is used for your own combat events
-- (COMBAT_UNIT_TYPE_GROUP is used for other group members' events).
function GroupMementos.RefreshGroupMembers()
    ZO_ClearTable(GroupMementos.groupMembers)

    if (not IsUnitGrouped("player")) then
        return
    end

    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if (unitTag) then
            local characterName = zo_strformat("<<1>>", GetUnitName(unitTag))
            if (characterName ~= "") then
                GroupMementos.groupMembers[characterName] = GetUnitDisplayName(unitTag) or characterName
            end
        end
    end
end

---------------------------------------------------------------------
-- Resolve a group member's character name to whichever name the user wants
-- shown, per the "Group member display name" setting. Falls back to the
-- character name for anyone we don't have a cached account name for (e.g. a
-- combat target who isn't a group member).
function GroupMementos.GetDisplayName(characterName)
    if (GroupMementos.savedOptions.nameDisplay == "userid") then
        local accountName = GroupMementos.groupMembers[characterName]
        if (accountName) then
            return accountName
        end
    end
    return characterName
end

---------------------------------------------------------------------
function GroupMementos.ResetSession()
    GroupMementos.savedOptions.sessionTally = {}
    GroupMementos.UpdateDisplay()
end

---------------------------------------------------------------------
-- Maps the "Leaderboard chat channel" setting to the actual chat channel
-- constant. Kept separate from the saved value itself so the SavedVariables
-- store a stable string ("party") rather than a numeric constant that could
-- change between API versions.
local LEADERBOARD_CHANNEL = {
    party = CHAT_CHANNEL_PARTY,
    guild = CHAT_CHANNEL_GUILD_1,
    say = CHAT_CHANNEL_SAY,
}

---------------------------------------------------------------------
-- Finds whoever has the highest value of some per-character metric among
-- current group members (ties included). getValue(characterName) -> number.
local function FindLeaders(getValue)
    local bestValue = 0
    local leaders = {}

    for characterName in pairs(GroupMementos.groupMembers) do
        local value = getValue(characterName)
        if (value > bestValue) then
            bestValue = value
            leaders = { characterName }
        elseif (value > 0 and value == bestValue) then
            table.insert(leaders, characterName)
        end
    end

    return bestValue, leaders
end

-- Formats a "Label: Name & Name (count)" entry, or nil if nobody qualifies.
local function FormatLeaderEntry(label, bestValue, leaders)
    if (bestValue <= 0) then return nil end

    local leaderNames = {}
    for _, characterName in ipairs(leaders) do
        table.insert(leaderNames, GroupMementos.GetDisplayName(characterName))
    end
    table.sort(leaderNames)

    return string.format("%s: %s (%d)", label, table.concat(leaderNames, " & "), bestValue)
end

---------------------------------------------------------------------
-- Builds a single-line "who's ahead in each tracked memento" leaderboard and
-- pre-fills it into the chat input, on whichever channel the "Leaderboard
-- chat channel" setting picks. This only prepares the text - the player
-- still has to press Enter to actually send it, since addons can't (and
-- shouldn't) silently post messages into a chat channel on their own.
function GroupMementos.AnnounceLeaderboard()
    if (not IsUnitGrouped("player")) then
        GroupMementos.msg("You're not in a group.")
        return
    end

    local trackedTypes = {}
    for _, mementoType in ipairs(GroupMementos.MEMENTO_ORDER) do
        if (GroupMementos.savedOptions.trackMemento[mementoType]) then
            table.insert(trackedTypes, mementoType)
        end
    end

    local parts = {}

    -- "Master Menace" is the overall leader across every tracked memento
    -- summed together - only meaningful with more than one to sum, same
    -- reasoning as why the tally window hides its Total column otherwise.
    if (#trackedTypes > 1) then
        local bestTotal, leaders = FindLeaders(function(characterName)
            local counts = GroupMementos.savedOptions.sessionTally[characterName] or {}
            local total = 0
            for _, mementoType in ipairs(trackedTypes) do
                total = total + (counts[mementoType] or 0)
            end
            return total
        end)
        local entry = FormatLeaderEntry("Master Menace", bestTotal, leaders)
        if (entry) then table.insert(parts, entry) end
    end

    for _, mementoType in ipairs(trackedTypes) do
        local bestCount, leaders = FindLeaders(function(characterName)
            return (GroupMementos.savedOptions.sessionTally[characterName] or {})[mementoType] or 0
        end)
        local entry = FormatLeaderEntry(GroupMementos.MEMENTO_DATA[mementoType].label, bestCount, leaders)
        if (entry) then table.insert(parts, entry) end
    end

    if (#parts == 0) then
        GroupMementos.msg("No tracked mementos have been used yet this session.")
        return
    end

    -- No "|" anywhere in this message - ESO's chat input treats it as the
    -- start of a markup/hyperlink escape sequence (the same mechanism as
    -- |c color codes), and a bare "|" used as a plain separator gets
    -- misparsed into garbage fragments once it actually reaches the channel.
    local message = "Memento Leaderboard - " .. table.concat(parts, " - ")
    local channel = LEADERBOARD_CHANNEL[GroupMementos.savedOptions.leaderboardChannel] or CHAT_CHANNEL_PARTY
    StartChatInput(message, channel)
end

---------------------------------------------------------------------
local function OnMementoUsed(mementoType, sourceName, sourceType, targetName, targetType)
    if (not GroupMementos.savedOptions.trackMemento[mementoType]) then
        return
    end

    -- Only count it if both the source and the target are the local player or
    -- a current group member - a group member pieing a random bystander or an
    -- NPC shouldn't count.
    if (sourceType ~= COMBAT_UNIT_TYPE_PLAYER and sourceType ~= COMBAT_UNIT_TYPE_GROUP) then
        return
    end
    if (targetType ~= COMBAT_UNIT_TYPE_PLAYER and targetType ~= COMBAT_UNIT_TYPE_GROUP) then
        return
    end

    sourceName = zo_strformat("<<1>>", sourceName)
    if (not GroupMementos.groupMembers[sourceName]) then
        return -- defensive: ignore names that don't match the current roster
    end

    targetName = zo_strformat("<<1>>", targetName)
    if (not GroupMementos.groupMembers[targetName]) then
        return -- defensive: target isn't a name we recognize as a current group member
    end

    local tally = GroupMementos.savedOptions.sessionTally
    if (not tally[sourceName]) then
        tally[sourceName] = {}
    end
    tally[sourceName][mementoType] = (tally[sourceName][mementoType] or 0) + 1

    if (GroupMementos.savedOptions.chat) then
        local data = GroupMementos.MEMENTO_DATA[mementoType]
        GroupMementos.msg(string.format(data.chatFormat, GroupMementos.GetDisplayName(sourceName), GroupMementos.GetDisplayName(targetName), tally[sourceName][mementoType]))
    end

    GroupMementos.UpdateDisplay()
end

---------------------------------------------------------------------
local function OnGroupMemberLeft(_, memberCharacterName, reason, isLocalPlayer)
    if (isLocalPlayer) then
        GroupMementos.ResetSession()
    end
    GroupMementos.RefreshGroupMembers()
    GroupMementos.UpdateDisplay()
end

local function OnGroupDisbanded()
    GroupMementos.ResetSession()
    GroupMementos.RefreshGroupMembers()
    GroupMementos.UpdateDisplay()
end

local function OnGroupRosterChanged()
    GroupMementos.RefreshGroupMembers()
    GroupMementos.UpdateDisplay()
end

---------------------------------------------------------------------
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
function GroupMementos.InitializeCore()
    GroupMementos.RefreshGroupMembers()

    for mementoType, data in pairs(GroupMementos.MEMENTO_DATA) do
        local eventName = GroupMementos.name .. mementoType
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(_, _, _, _, _, _, sourceName, sourceType, targetName, targetType, hitValue)
            if (hitValue == 1) then
                OnMementoUsed(mementoType, sourceName, sourceType, targetName, targetType)
            end
        end)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, data.id)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
    end

    EVENT_MANAGER:RegisterForEvent(GroupMementos.name .. "MemberLeft", EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)
    EVENT_MANAGER:RegisterForEvent(GroupMementos.name .. "MemberJoined", EVENT_GROUP_MEMBER_JOINED, OnGroupRosterChanged)
    EVENT_MANAGER:RegisterForEvent(GroupMementos.name .. "Disbanded", EVENT_GROUP_DISBANDED, OnGroupDisbanded)
    EVENT_MANAGER:RegisterForEvent(GroupMementos.name .. "Update", EVENT_GROUP_UPDATE, OnGroupRosterChanged)
end
