local COMPLETE_STATUS = 5
local MAP = SKILLPOINT_QUEST_BY_ACTIVITY or {}

local function IsDungeonQuestComplete(questId)
    local _, status = GetCompletedQuestInfo(questId)
    return status == COMPLETE_STATUS
end

local function UncompletedActivities()
    local out, n = {}, 0
    for activityId, questId in pairs(MAP) do
        if not IsDungeonQuestComplete(questId) then
            n = n + 1; out[n] = activityId
        end
    end
    table.sort(out)
    return out
end

local function CmdList()
    local pending = UncompletedActivities()
    local total = 0; for _ in pairs(MAP) do total = total + 1 end
    d(string.format("|c88FF88UDQ: %d / %d dungeons incomplete|r", #pending, total))
    for _, activityId in ipairs(pending) do
        local questId = MAP[activityId]
        d(string.format("%d - %s (questId=%d)", activityId, GetActivityName(activityId) or tostring(activityId),
            questId or 0))
    end
end

local function QueueSpecificDungeons(ids)
    if not (ClearActivityFinderSearch and AddActivityFinderSpecificSearchEntry and StartActivityFinderSearch) then
        d("|cFF5555UDQ: Queue APIs not available.|r")
        return false
    end
    ClearActivityFinderSearch()
    local added = 0
    for _, id in ipairs(ids) do
        AddActivityFinderSpecificSearchEntry(id); added = added + 1
    end
    if added > 0 then
        StartActivityFinderSearch(); d(zo_strformat("|c55FF55UDQ: Queued <<1>> activities.|r", added)); return true
    end
    d("|cAAAAFFUDQ: Nothing to queue.|r")
    return false
end

local function CmdQueue()
    local pending = UncompletedActivities()
    if #pending == 0 then
        d("|cAAAAFFUDQ: All dungeon quests complete.|r")
        return
    end
    QueueSpecificDungeons(pending)
end

SLASH_COMMANDS['/ugu'] = function(arg)
    arg = (arg or ''):lower()
    if arg == 'list' then
        CmdList()
    elseif arg == 'queue' or arg == 'q' then
        CmdQueue()
    else
        d("/ugu list | queue  (list unfinished dungeons or queue them)")
    end
end
