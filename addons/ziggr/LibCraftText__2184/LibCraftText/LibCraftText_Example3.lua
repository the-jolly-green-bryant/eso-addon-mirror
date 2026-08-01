-- Example code for LibCraftText

-- If you have other crafting add-ons such as Dolgubon's, disable them while
-- running with this example. Otherwise the other add-ons will try to control
-- the same dialogs that this example code does.

LibCraftText_Example3 = {}
local Example3 = LibCraftText_Example3
Example3.name = "LibCraftText_Example3"

SLASH_COMMANDS["/example3"] = function() LibCraftText_Example3.SlashCommand() end

local red   = "|cFF6666"
local green = "|c66FF66"
local grey  = "|c999999"
local white = "|cFFFFFF"

local function Info(msg, ...)
    local s = string.format(grey.."Example3: "..msg, ...)
    d(s)
end

-- Example3 ------------------------------------------------------------------
--
-- Automate dialog and quest interaction for master writs
--
-- Master writ sequence:
--
--  1. Inventory: open a sealed master writ
--
--      EVENT_INVENTORY_ITEM_USED
--      EVENT_QUEST_OFFERED
--        title  = "-Sealed Blacksmithing Writ-"
--        option = "<Accept the contract.>"
--
--    Accept the quest.
--
function Example3.QuestOfferedMasterWrit()
    local dialog_text, response = GetOfferedQuestInfo()
    if response == LibCraftText.MASTER.DIALOG.OPTION_ACCEPT[1]
        or response == LibCraftText.MASTER.DIALOG.OPTION_ACCEPT[2] then
        Info("QuestOfferedMasterWrit() accepting quest...")
        zo_callLater( function()
                        AcceptOfferedQuest()
                        ResetChatter()
                      end
                    , 500)
    else
        Info(green.."Done turning in master writ quests.")
    end
end

--  2. EVENT_QUEST_ADDED(quest_index, quest_name)
--
--      Accepting the offered quest fires EVENT_QUEST_ADDED.
--
--      Report the requested item.
function Example3.QuestAdded(quest_index, quest_name)
    if not LibCraftText.MasterQuestNameToCraftingTypeList(quest_name) then
        Info("QuestAdded() not our quest: '%s'", quest_name)
        return          -- Not one of ours.
    end

    Info(green.."Quest added:|r", quest_name)
    if LibCraftText_Example1 then
        local parse_result = Example3.ParseMasterQuest(quest_index)
        LibCraftText.DumpTable(parse_result)
    end
    Info(green.."Go craft the requested item, then bring it to Rolis.")
end

--  3. EVENT_CHATTER_END
--
--      Fired in response to ending the sealed master writ's quest offer
--      dialog.
--
--  4. Craft required item
--
--      EVENT_QUEST_CONDITION_COUNTER_CHANGED
--      EVENT_QUEST_ADVANCED
--      Fired in response to completing the required crafting.
--
--      quest condition text is now "Deliver the Weapon" or other item
--
--  5. Travel to Rolis
--
--  6. interact with Rolis
--
--  7. EVENT_CHATTER_BEGIN
--     title  = "-Rolis Hlaalu-"
--     option = "I've finished the Blacksmithing job."
--
--     Choose option "I've finished the Blacksmithing job."
--
function Example3.ChatterRolis()
    local data          = { GetChatterData() }
    local option_ct     = data[2]
    local option_text_1 = GetChatterOption(1)


                        -- "I've finished the Blacksmithing job."
    local crafting_type = LibCraftText.RolisDialogOptionToCraftingType(option_text_1)
    if crafting_type then
                        -- Must choose options after a delay: picking them
                        -- right away tends to fail silently.
        Info("ChatterRolis() choosing option[1]:'%s'", option_text_1)
        zo_callLater(function() SelectChatterOption(1) end, 500)

    elseif option_text_1 == LibCraftText.MASTER.DIALOG.OPTION_FINISH_JOB then
                        -- "<Finish the job.>"
                        -- Happens if you exit Rolis interaction before
                        -- completing quest.
        Info("ChatterRolis() choosing option[1]:'%s'", option_text_1)
        zo_callLater(function() SelectChatterOption(1) end, 500)
    else
                        -- Once you're out of writs to turn in, the store
                        -- option "Store (Mastercraft Mediator)" ends up in
                        -- slot option[1]
        Info("ChatterRolis() not our option:'%s'", option_text_1)
    end
end

--  8. EVENT_QUEST_ADVANCED(quest_index, quest_name, false, true, true)
--     EVENT_QUEST_COMPLETE_DIALOG(quest_index)
--         title  = "-Rolis Hlaalu-"
--
--         GetJournalQuestEnding(quest_index)
--             [2] = "<He notes your work and tenders payment.>"
--
--    In response to choosing "I've finished the Blacksmithing job." above,
--    the quest advances all the way to the "quest complete" dialog.
--
--    Complete the quest, receive rewards.
--
--         CompleteQuest()
function Example3.QuestCompleteDialog(quest_index)
    local data = { GetJournalQuestEnding(quest_index) }
    local goal     = data[1]
    local response = data[2]

                        -- "<He notes your work and tenders payment.>"
    if response == LibCraftText.MASTER.DIALOG.RESPONSE_ENDING then
        Info("QuestCompleteDialog() completing quest:'%s'", response)
        CompleteQuest()
    else
        Info("QuestCompleteDialog() not our quest:'%s'", response)
    end
end

--  9. EVENT_QUEST_REMOVED(true, quest_index, quest_name, 294967291,294967291,5972)
--     EVENT_QUEST_COMPLETE(quest_name, 50, 545317, 619417, 1131, 4, 0)
--
--     Both fired in response to completing the master writ quest.
--
-- 10. EVENT_CHATTER_BEGIN:   GOTO 7.
--
--     Loop back to Rolis for the next writ to turn in, or stop when we
--     run out of writs to turn in.


-- Parsing a Master Writ quest -----------------------------------------------
--
-- Parse a single master writ quest's requirements.
--
-- Master quests always call for exactly one item, so this function returns a
-- single result table, not a list.
--
-- Returns a LibCraftText.ParseMasterCondition() table, with varying fields.
--
function Example3.ParseMasterQuest(quest_index)
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
    local quest_name    = jqi[ 1]               -- "A Masterful Plate"

                        -- Alchemy? Blacksmithing? Not sure?
                        --
                        -- Some quest titles ("A Masterful Weapon") could be
                        -- either blacksmithing or woodworking. Have to try
                        -- parsing for each possible crafting_type, and the
                        -- type that actually matches the condition will
                        -- produce a parse result. The others will produce nil.
    local crafting_type_list
                = LibCraftText.MasterQuestNameToCraftingTypeList(quest_name)
    if not crafting_type_list then return nil end
    local result_list = {}
    for _,crafting_type in pairs(crafting_type_list) do
                        --
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
                    local parse_result = LibCraftText.ParseMasterCondition(
                                            crafting_type, cond_text)
                    if parse_result then
                        return parse_result
                    end
                end
            end
        end
    end
    return nil
end


-- Distracting Details -------------------------------------------------------
--
-- Event listeners and dispatching events to the proper step above
--

function Example3.SlashCommand()
    local self = Example3
    if not self.registered then
        self.RegisterEventListeners()
        self.registered = true
    else
        self.UnregisterEventListeners()
        self.registered = false
    end
end

function Example3.RegisterEventListeners()
                        -- Install event listeners to detect when a crafting
                        -- quest is offered, when a quest turn-in dialog
                        -- occurs, and so on.
    local self = Example3
    local name = self.name.."_hello"
                        -- EVENT_CHATTER_BEGIN fires when an NPC dialog appears
                        -- after you interact with them. Use this to detect
                        -- when talking to Rolis Hlaalu. Or the daily writ
                        -- board!
    EVENT_MANAGER:RegisterForEvent( name
                                  , EVENT_CHATTER_BEGIN
                                  , function() Example3.OnChatterBegin() end )

                        -- EVENT_QUEST_OFFERED fires when a dialog offers a
                        -- quest. Fires when opening a sealed master writ, and
                        -- when interacting with the daily crafting writ
                        -- boards.
    EVENT_MANAGER:RegisterForEvent( name
                                  , EVENT_QUEST_OFFERED
                                  , function()
                                        Example3.OnQuestOffered()
                                    end )

                        -- EVENT_QUEST_ADDED fires when a quest has been
                        -- accepted.
    EVENT_MANAGER:RegisterForEvent( name
                                  , EVENT_QUEST_ADDED
                                  , function(event_code, quest_index, quest_name)
                                        Example3.OnQuestAdded(quest_index, quest_name)
                                    end )

                        -- EVENT_QUEST_COMPLETE_DIALOG fires when turning in  a
                        -- quest. Use this to detect when the user (or your own
                        -- automation code) has turned in a quest.
    EVENT_MANAGER:RegisterForEvent( name
                                  , EVENT_QUEST_COMPLETE_DIALOG
                                  , function(event_code, quest_index)
                                        Example3.OnQuestCompleteDialog(quest_index)
                                    end )

    LibCraftText.rolis_registered = true
    Info("Dialog listeners registered."
         .." Go open a sealed master writ.")
end

function Example3.UnregisterEventListeners()
    local name = LibCraftText.name .. "_hello"
    local event_list = { EVENT_CHATTER_BEGIN
                       , EVENT_QUEST_OFFERED
                       , EVENT_QUEST_ADDED
                       , EVENT_QUEST_COMPLETE_DIALOG
                       }
    for _,event_id in ipairs(event_list) do
        EVENT_MANAGER:UnregisterForEvent( name
                                        , event_id
                                        )
    end
    Info("Dialog listeners removed.")
end

function Example3.OnChatterBegin()
                        -- A dialog with an NPC (or the daily writ board!)
                        -- has begun. Who is it?
    local self         = Example3
    local dialog_title = self.GetDialogTitle()

                        -- Is it Rolis?
    if dialog_title == LibCraftText.MASTER.DIALOG.TITLE_ROLIS then
        self.ChatterRolis()
        return
    end
                        -- Not Rolis Hlaalu.
                        -- Not part of this example.
end

function Example3.OnQuestOffered()
                        -- A "quest offer" dialog is on screen now.
    Example3.QuestOfferedMasterWrit()
end

function Example3.OnQuestAdded(quest_index, quest_name)
                        -- We just accepted a quest.
    Example3.QuestAdded(quest_index, quest_name)
end

function Example3.OnQuestCompleteDialog(quest_index)
    Example3.QuestCompleteDialog(quest_index)
end

function Example3.GetDialogTitle()
    return ZO_InteractWindowTargetAreaTitle:GetText()
end
