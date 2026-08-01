PreviousQuest = {}
PreviousQuest.name = "PreviousQuest"
PreviousQuest.version = "2026.07.09"
PreviousQuest.defaults = {
    invertKey = "CTRL",
}

-- Lookup table built once instead of doing string comparisons on every keypress.
local INVERT_KEY_FUNCS = {
    CTRL  = IsControlKeyDown,
    SHIFT = IsShiftKeyDown,
    ALT   = IsAltKeyDown,
    CMD   = IsCommandKeyDown,
}

function PreviousQuest.isInvertKeyPressed()
    if not PreviousQuest.vars then
        return IsControlKeyDown()
    end
    local keyFunc = INVERT_KEY_FUNCS[PreviousQuest.vars.invertKey]
    if keyFunc then
        return keyFunc()
    end
    return false
end

-- Yep I created an unexisting ZO_function to make it easier Oo!
function ZO_QuestJournal_Manager:GetPreviousSortedQuestForQuestIndex(questIndex)
    local quests = self.quests
    local numQuests = #quests
    for i = 1, numQuests do
        if quests[i].questIndex == questIndex then
            local previousQuest = (i == 1) and numQuests or (i - 1)
            return quests[previousQuest].questIndex
        end
    end
end

-- ZO function overwrite
function ZO_Tracker:AssistNext(ignoreSceneRestriction)
    local isShowingBase = SCENE_MANAGER:IsShowingBaseScene()
    if ignoreSceneRestriction or isShowingBase then

        local assistedData = self.assistedData
        if PreviousQuest.isInvertKeyPressed() then
            -- find previous quest
            if assistedData then
                local previousQuestIndex = QUEST_JOURNAL_MANAGER:GetPreviousSortedQuestForQuestIndex(assistedData.arg1)

                if previousQuestIndex then
                    if self:BeginTracking(TRACK_TYPE_QUEST, previousQuestIndex) then
                        CALLBACK_MANAGER:FireCallbacks("QuestTrackerUpdatedOnScreen")
                        return
                    end
                end
            end
        else
            -- if we are showing one quest now, find the next one to show ordered by the order they appear in the quest journal
            if assistedData then
                local nextQuestIndex = QUEST_JOURNAL_MANAGER:GetNextSortedQuestForQuestIndex(assistedData.arg1)
                if nextQuestIndex then
                    if self:BeginTracking(TRACK_TYPE_QUEST, nextQuestIndex) then
                        CALLBACK_MANAGER:FireCallbacks("QuestTrackerUpdatedOnScreen")
                        return
                    end
                end
            end
        end

        -- if we aren't showing any quest look for some quest to show
        for i = 1, MAX_JOURNAL_QUESTS do
            if IsValidQuestIndex(i) then
                if self:BeginTracking(TRACK_TYPE_QUEST, i) then
                    CALLBACK_MANAGER:FireCallbacks("QuestTrackerUpdatedOnScreen")
                    break
                end
            end
        end
    end
end


function PreviousQuest.CreateConfiguration()

    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = PreviousQuest.name,
        author = "|c3CB371@Masteroshi430|r",
        version = PreviousQuest.version,
        registerForDefaults = true,
        registerForRefresh = true,
    }

    LAM:RegisterAddonPanel(PreviousQuest.name.."Config", panelData)

    local controlData =
    {
            [1] = {
              type = "dropdown",
              name = "Backwards Key",
              tooltip = "Long pressing that key while using the keybind to cycle focused quest will allow it to do it backwards.",
              choices = {"CTRL", "SHIFT", "ALT", "CMD"},
              getFunc = function()  return PreviousQuest.vars.invertKey end,
              setFunc = function(NewVal) PreviousQuest.vars.invertKey = NewVal end,

            },
    }

    LAM:RegisterOptionControls(PreviousQuest.name.."Config", controlData)

end

local function OnAddonLoaded(event, addonName)
    if addonName == PreviousQuest.name then
       PreviousQuest.vars = ZO_SavedVars:NewAccountWide("PreviousQuestVars", 2, nil, PreviousQuest.defaults)
       -- Validate, not just nil-check: earlier versions saved the typo'd default "CRTL" to disk,
       -- so existing users' saved variables can hold that literal invalid value.
       if not INVERT_KEY_FUNCS[PreviousQuest.vars.invertKey] then
           PreviousQuest.vars.invertKey = "CTRL"
       end
       PreviousQuest.CreateConfiguration()
       EVENT_MANAGER:UnregisterForEvent(PreviousQuest.name, EVENT_ADD_ON_LOADED)
    end

end

EVENT_MANAGER:RegisterForEvent(PreviousQuest.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
