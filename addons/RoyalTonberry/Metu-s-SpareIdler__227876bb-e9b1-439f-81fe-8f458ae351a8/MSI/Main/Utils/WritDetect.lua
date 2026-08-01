-- WritDetect.lua
if MSI == nil then MSI = MSI or {} end
local MSI = _G['MSI']

local DUMMY_ITEM_LINK = "|H1:item:45850:20:1:0:0:0:0:0|h|h" -- Mundane Rune
local _probeUsable
local writDirty   = true
local writPresent = false

--*************************--
-- Crafting Writ Detection
local function ProbeHelper()
    if _probeUsable ~= nil then return end
    local probe = DoesItemLinkFulfillJournalQuestCondition
    if type(probe) == "function" then
        local ok = pcall(function()
            return probe(DUMMY_ITEM_LINK, 1, 1, 1)
        end)
        _probeUsable = ok
    else
        _probeUsable = false
    end
end

local function MarkWritDirty()
    writDirty = true
end

local journalEvents = {
    EVENT_QUEST_ADDED,
    EVENT_QUEST_REMOVED,
    EVENT_QUEST_LIST_UPDATED,
    EVENT_QUEST_CONDITION_COUNTER_CHANGED,
}
for _, e in ipairs(journalEvents) do
    EVENT_MANAGER:RegisterForEvent(MSI.Name.."WritDirty", e, MarkWritDirty)
end

local function ExpensiveWritScan()
    ProbeHelper()
    local useProbe = _probeUsable
    local probeFn  = useProbe and DoesItemLinkFulfillJournalQuestCondition or nil

    for qi = 1, GetNumJournalQuests() do
        if IsValidQuestIndex(qi)
        and GetJournalQuestType(qi) == QUEST_TYPE_CRAFTING
        and not GetJournalQuestIsComplete(qi) then
            if not useProbe then return true end
            local steps = GetJournalQuestNumSteps(qi)

            for si = 1, steps do
                local conds = GetJournalQuestNumConditions(qi, si)
                for ci = 1, conds do
                    local _,_,_,_, done = GetJournalQuestConditionInfo(qi, si, ci)
                    if not done and type(probeFn) == "function" then
                        local ok, fulfills = pcall(probeFn, DUMMY_ITEM_LINK, qi, si, ci)
                        if ok and fulfills then return true end
                    end
                end
            end
            return true
        end
    end
    return false
end

function MSI.HasActiveWrit()
   if writDirty then
        writPresent = ExpensiveWritScan()
        writDirty   = false
    end
    return writPresent
end
--eof