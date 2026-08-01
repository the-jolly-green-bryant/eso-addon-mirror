local HARDCORE = HARDCORE

local ID = "QuestlessExile"
local NS = "HARDCORE_QuestlessExile"

local ICON_QUESTLESS_EXILE = "/esoui/art/journal/journal_tabicon_quest_up.dds"

local Rule = {
    id = ID,
    title = "Questless Exile: no questing",
    icon = ICON_QUESTLESS_EXILE,
    defaultEnabled = false
}

Rule.active = false
Rule._hooksInstalled = false
Rule._lastBlockAlertMs = 0
Rule._lastAbandonAlertMs = 0
Rule._lastProtectedAlertMs = 0

local AbandonAbandonableQuests

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function IsRuleActive()
    return Rule.active and IsHardcoreActive()
end

local function EndQuestInteraction()
    EndInteraction(INTERACTION_QUEST)
end

local function AlertBlocked()
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastBlockAlertMs > 1200 then
        HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK,
            "HARDCORE: Questless Exile forbids accepting or completing quests.")
        Rule._lastBlockAlertMs = now
    end
end

local function AlertAbandoned(count)
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastAbandonAlertMs > 1200 then
        local message = "HARDCORE: Questless Exile abandoned " .. tostring(count) .. " quest"
        if count ~= 1 then
            message = message .. "s"
        end
        HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.QUEST_ABANDONED, message .. ".")
        Rule._lastAbandonAlertMs = now
    end
end

local function AlertProtected(questName)
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastProtectedAlertMs > 4000 then
        local name = questName and questName ~= "" and (": " .. questName) or "."
        HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK,
            "HARDCORE: Questless Exile cannot abandon protected quests" .. name)
        Rule._lastProtectedAlertMs = now
    end
end

local function TryAbandonQuest(journalQuestIndex)
    if not (journalQuestIndex and IsValidQuestIndex(journalQuestIndex)) then
        return false, false
    end

    local questName = GetJournalQuestName(journalQuestIndex)
    if CanAbandonJournalQuest(journalQuestIndex) then
        AbandonQuest(journalQuestIndex)
        return true, false
    end

    if GetJournalQuestType(journalQuestIndex) == QUEST_TYPE_MAIN_STORY then
        return false, true, questName
    end
    return false, true, questName
end

AbandonAbandonableQuests = function(showProtectedAlert)
    if not IsRuleActive() then
        return
    end

    local abandoned = 0
    local protectedName = nil
    for journalQuestIndex = GetNumJournalQuests(), 1, -1 do
        local didAbandon, isProtected, questName = TryAbandonQuest(journalQuestIndex)
        if didAbandon then
            abandoned = abandoned + 1
        elseif isProtected and not protectedName then
            protectedName = questName
        end
    end

    if abandoned > 0 then
        AlertAbandoned(abandoned)
    elseif showProtectedAlert and protectedName then
        AlertProtected(protectedName)
    end
end

local function BlockQuestAction()
    if IsRuleActive() then
        EndQuestInteraction()
        AlertBlocked()
        zo_callLater(AbandonAbandonableQuests, 100)
        return true
    end
end

local function InstallHooks()
    if Rule._hooksInstalled then
        return
    end

    ZO_PreHook("AcceptOfferedQuest", BlockQuestAction)
    ZO_PreHook("AcceptSharedQuest", BlockQuestAction)
    ZO_PreHook("CompleteQuest", BlockQuestAction)

    Rule._hooksInstalled = true
end

local function OnQuestAdded(_, journalQuestIndex, questName)
    if not IsRuleActive() then
        return
    end

    EndQuestInteraction()
    zo_callLater(function()
        local didAbandon, isProtected, protectedName = TryAbandonQuest(journalQuestIndex)
        if didAbandon then
            AlertAbandoned(1)
        elseif isProtected then
            AlertProtected(protectedName or questName)
        end
    end, 100)
end

local function OnQuestInteraction()
    if IsRuleActive() then
        EndQuestInteraction()
        AlertBlocked()
        zo_callLater(AbandonAbandonableQuests, 100)
    end
end

local function RegisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ADDED", EVENT_QUEST_ADDED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_OFFERED", EVENT_QUEST_OFFERED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_COMPLETE", EVENT_QUEST_COMPLETE_DIALOG)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)

    EVENT_MANAGER:RegisterForEvent(NS .. "_ADDED", EVENT_QUEST_ADDED, OnQuestAdded)
    EVENT_MANAGER:RegisterForEvent(NS .. "_OFFERED", EVENT_QUEST_OFFERED, OnQuestInteraction)
    EVENT_MANAGER:RegisterForEvent(NS .. "_COMPLETE", EVENT_QUEST_COMPLETE_DIALOG, OnQuestInteraction)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(AbandonAbandonableQuests, 200)
    end)
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ADDED", EVENT_QUEST_ADDED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_OFFERED", EVENT_QUEST_OFFERED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_COMPLETE", EVENT_QUEST_COMPLETE_DIALOG)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
end

function Rule:OnEnable()
    self.active = true
    InstallHooks()
    RegisterEvents()
    zo_callLater(function()
        AbandonAbandonableQuests(true)
    end, 200)
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
end

HARDCORE.RuleManager:RegisterRule(Rule)
