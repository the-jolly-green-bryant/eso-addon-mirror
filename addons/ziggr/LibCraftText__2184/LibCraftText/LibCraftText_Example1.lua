-- Example code for LibCraftText


LibCraftText_Example1 = {}
local Example1 = LibCraftText_Example1

SLASH_COMMANDS["/example1"] = function() Example1.Example1() end

local red   = "|cFF6666"
local grey  = "|c999999"
local white = "|cFFFFFF"

-- Example1  -----------------------------------------------------------------
--
-- Scan quest journal and dump any daily crafting writ quests.
function Example1.Example1()
    local at_least_one = false
    for quest_index = 1, MAX_JOURNAL_QUESTS do
    -- for quest_index = 1, 11 do
        local is_one = Example1.Example1_OneQuest(quest_index)
        at_least_one = at_least_one or is_one
    end
    if not at_least_one then
        d("No daily crafting quests. Go start some and try again.")
    end
end

function Example1.Example1_OneQuest(quest_index)
                        -- Is this a daily crafting writ quest?
                        --

                        -- ZOS API
                        -- GetJournalQuestInfo(number journalQuestIndex)
                        --  1   Returns: string  questName
                        --  2          , string  backgroundText
                        --  3          , string  activeStepText
                        --  4          , number  activeStepType
                        --  5          , string  activeStepTrackerOverrideText
                        --  6          , boolean completed
                        --  7          , boolean tracked
                        --  8          , number  questLevel
                        --  9          , boolean pushed
                        -- 10          , number  questType
                        -- 11          , number  InstanceDisplayType instanceDisplayType
    local jqi = { GetJournalQuestInfo(quest_index) }
    local quest_name    = jqi[ 1]

                        -- ZOS API
                        -- GetJournalQuestRepeatType(number journalQuestIndex)
                        --      Returns: number repeatType
                        --
    local repeat_type   = GetJournalQuestRepeatType(quest_index)
    if (jqi[10] ~= QUEST_TYPE_CRAFTING) or (repeat_type ~= QUEST_REPEAT_DAILY) then
        d(string.format( grey.."Quest %d: %s not a daily crafting quest."
                       , quest_index, quest_name ))
        return          -- Not a daily crafting quest.
    end

                        -- LibCraftText API
                        -- DailyQuestNameToCraftingType(quest_name)
                        --      Returns: CRAFTING_TYPE_X
    local crafting_type = LibCraftText.DailyQuestNameToCraftingType(quest_name)
    if not crafting_type then
        d(string.format( red.."Quest %d: %s   LibCraftText bug: failed to identify crafting type."
                       , quest_index, quest_name ))
        return          -- Nope. Not a daily crafting writ quest.
    end

    d(string.format( "Quest %d: %s  "..grey.."crafting_type:%d"
                   , quest_index, quest_name, crafting_type))
                        -- Scan this quest's conditions and
                        -- report what you find.

                        -- ZOS API
                        -- GetJournalQuestNumSteps(number journalQuestIndex)
                        --      Returns: number numSteps
    local step_ct = GetJournalQuestNumSteps(quest_index)
    for step_i = 1,step_ct do

                        -- ZOS API
                        -- GetJournalQuestStepInfo( number journalQuestIndex
                        --                        , number stepIndex )
                        --  1   Returns: string stepText
                        --  2          , number:nilable visibility
                        --  3          , number stepType
                        --  4          , string trackerOverrideText
                        --  5          , number numConditions
        local step_info    = { GetJournalQuestStepInfo(quest_index, step_i) }
        local condition_ct = step_info[5]
        for cond_i = 1,condition_ct do

                        -- ZOS API
                        -- GetJournalQuestConditionInfo( number journalQuestIndex
                        --                             , number stepIndex
                        --                             , number conditionIndex )
                        --  1   Returns: string conditionText
                        --  2          , number current
                        --  3          , number max
                        --  4          , boolean isFailCondition
                        --  5          , boolean isComplete
                        --  6          , boolean isCreditShared
                        --  7          , boolean isVisible
            local cond_info = { GetJournalQuestConditionInfo(
                                        quest_index, step_i, cond_i) }
            local cond_text = cond_info[1]

            if cond_text ~= "" then
                        -- Here it is, the big LibCraftText API
                        -- ParseDailyCondition( crafting_type
                        --                    , cond_text)
                        --      Returns: table with variable fields
                local parse_results = LibCraftText.ParseDailyCondition(
                                            crafting_type, cond_text)
                d(string.format( grey.."quest %d  step %d  condition %d :"..white.." '%s'"
                               , quest_index, step_i, cond_i, cond_text ))
                if parse_results then
                    LibCraftText.DumpTable(parse_results)
                end
            end
        end
    end
    return true
end

