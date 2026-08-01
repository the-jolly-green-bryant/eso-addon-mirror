-- Example code for LibCraftText

-- If you have other crafting add-ons such as Dolgubon's, disable them while
-- running with this example. Otherwise the other add-ons will try to control
-- the same dialogs that this example code does.

LibCraftText_Example2 = {}
local Example2 = LibCraftText_Example2
Example2.name = "LibCraftText_Example2"

SLASH_COMMANDS["/example2"] = function() LibCraftText_Example2.SlashCommand() end

local red   = "|cFF6666"
local green = "|c66FF66"
local grey  = "|c999999"
local white = "|cFFFFFF"

local function Info(msg, ...)
    local s = string.format(grey.."Example2: "..msg, ...)
    d(s)
end

-- Example2 ------------------------------------------------------------------
--
-- Automate dialog and quest interaction for daily writs
--
-- Daily writ sequence:
--
--  1. Interact with writ board
--
--      EVENT_CHATTER_BEGIN
--        title = "-Equipment Crafting Writs-"
--        opt   = "<Examine the Clothier Writ>"
--
--    choose option 1 if it's a crafting option
--
function Example2.ChatterWritBoard()
    local data          = { GetChatterData() }
    local option_ct     = data[2]
    local option_text_1 = GetChatterOption(1)
                        -- If the writ board offers us an option
                        -- to start a daily writ, choose that option.
    local crafting_type = LibCraftText.DailyDialogOptionToCraftingType(option_text_1)
    if crafting_type then
        Info("ChatterWritBoard() choosing option[1]:'%s'...",option_text_1)
                        -- Must choose options after a delay: picking them
                        -- right away tends to fail silently.
        zo_callLater(function() SelectChatterOption(1) end, 500)
    else
        Info("No more crafting quests to accept."
             .." Go craft something then turn it in.")
    end
end

--  2. EVENT_QUEST_OFFERED
--      title = "-Equipment Crafting Writs-"
--      info[1] "blah blah blah"
--      info[2] "<Pull a writ from the Board.>"
--
--  Choosing an option to start a daily writ opens a quest offer dialog.
--  Accept that quest.
--
function Example2.QuestOfferedDailyWrit()
    local dialog_text, response = GetOfferedQuestInfo()
    if response == LibCraftText.DAILY.DIALOG.OPTION_ACCEPT then
        Info("QuestOfferedDailyWrit() accepting quest...")
        AcceptOfferedQuest()
    else
        Info("QuestOfferedDailyWrit() not our quest.")
    end
end

--  3. EVENT_QUEST_ADDDED(quest_index,quest_name)
--
-- Accepting the offered quest fires EVENT_QUEST_ADDED
--
-- Report the requested item
function Example2.QuestAdded(quest_index, quest_name)
    if not LibCraftText.DailyQuestNameToCraftingType(quest_name) then
        Info("QuestAdded() not our quest: '%s'", quest_name)
        return          -- Not one of ours.
    end
                        -- If you have Example1 code loaded, it can dump all
                        -- about this shiny new daily crafting quest.
    Info(green.."Quest added:|r", quest_name)
    if LibCraftText_Example1 and LibCraftText_Example1.Example1_OneQuest then
        LibCraftText.ParseAndDump(quest_index)
    end
end

--  4. EVENT_CHATTER_BEGIN
--       back to the daily writ board
--
-- Accepting the offered quest returns us to the daily writ board, where we
-- can choose another quest, or exit.
--
-- WHILE there are still remaining daily writs to acquire,
-- GOTO 1. "Interact with writ board" above

--  5. Exit writ board interaction after you have acquired.
--
--  6. EVENT_CHATTER_END
--     Fired in response to exiting the writ board interaction.
--
--  7. Craft the required item(s).
--
--     EVENT_QUEST_CONDITION_COUNTER_CHANGED(quest_index, quest_name,...)
--
--  8. Exit crafting station
--     EVENT_CHATTER_END  (for exiting the crafting station)
--

--  9. Interact with daily writ turn-in crate.
--
-- 10. EVENT_CHATTER_BEGIN()
--     title  = "-Blacksmith Delivery Crate-"
--     option = "<Place the goods within the crate.>"
--
--     Choose dialog option "<Place the goods within the crate.>"
--     to turn in the quest.
function Example2.ChatterDeliveryCrate()
    local data          = { GetChatterData() }
    local option_ct     = data[2]
    local option_text_1 = GetChatterOption(1)


                        -- "<Place the goods within the crate.>"
    if option_text_1 == LibCraftText.DAILY.DIALOG.OPTION_FINISH_PLACE then
                        -- Must choose options after a delay: picking them
                        -- right away tends to fail silently.
        Info("ChatterDeliveryCrate() choosing option[1]:'%s'", option_text_1)
        zo_callLater(function() SelectChatterOption(1) end, 500)

    elseif option_text_1 == LibCraftText.DAILY.DIALOG.OPTION_FINISH_SIGN then
                        -- "<Sign the Manifest.>"
                        -- Happens if you exit crate interaction before
                        -- completing quest.
        Info("ChatterDeliveryCrate() choosing option[1]:'%s'", option_text_1)
        zo_callLater(function() SelectChatterOption(1) end, 500)
    else
        Info("ChatterDeliveryCrate() not our option:'%s'", option_text_1)
    end
end

-- 11. EVENT_QUEST_CONDITION_COUNTER_CHANGED()
--     EVENT_QUEST_ADVANCED(qi,qname)
--     EVENT_QUEST_COMPLETE_DIALOG(qi)
--
--     In response to choosing "<Place the goods within the crate.>",
--     the quest advances all the way to the "quest complete" dialog.
--
--     Complete the quest, receive rewards.
--
function Example2.QuestCompleteDialog(quest_index)
    local data = { GetJournalQuestEnding(quest_index) }
    local goal = data[1]
                        -- "Sign Delivery Manifest"
    if goal == LibCraftText.DAILY.DIALOG.GOAL_SIGN then
        Info("QuestCompleteDialog() completing quest:'%s'", goal)
        CompleteQuest()
    else
        Info("QuestCompleteDialog() not our quest:'%s'", goal)
    end
end

-- 12. EVENT_QUEST_REMOVED(is_completed, quest_index, quest_name)
--     EVENT_QUEST_COMPLETE
--     EVENT_CHATTER_END
--
--     All fired in response to completing the quest.
--
--     DONE!


-- Distracting Details -------------------------------------------------------
--
-- Event listeners and dispatching events to the proper step above.
--

function Example2.SlashCommand()
    local self = Example2
    if not self.registered then
        self.RegisterEventListeners()
        self.registered = true
    else
        self.UnregisterEventListeners()
        self.registered = false
    end
end

function Example2.RegisterEventListeners()
                        -- Install event listeners to detect when a crafting
                        -- quest is offered, when a quest turn-in dialog
                        -- occurs, and so on.
    local self = Example2
    local name = self.name.."_hello"

                        -- EVENT_CHATTER_BEGIN fires when an NPC dialog appears
                        -- after you interact with them. Use this to detect
                        -- when talking to Rolis Hlaalu. Or the daily writ
                        -- board!
    EVENT_MANAGER:RegisterForEvent( name
                                  , EVENT_CHATTER_BEGIN
                                  , function() Example2.OnChatterBegin() end )

                        -- EVENT_QUEST_OFFERED fires when a dialog offers a
                        -- quest. Fires when opening a sealed master writ, and
                        -- when interacting with the daily crafting writ
                        -- boards.
    EVENT_MANAGER:RegisterForEvent( name
                                  , EVENT_QUEST_OFFERED
                                  , function()
                                        Example2.OnQuestOffered()
                                    end )

                        -- EVENT_QUEST_ADDED fires when a quest has been
                        -- accepted.
    EVENT_MANAGER:RegisterForEvent( name
                                  , EVENT_QUEST_ADDED
                                  , function(event_code, quest_index, quest_name)
                                        Example2.OnQuestAdded(quest_index, quest_name)
                                    end )

                        -- EVENT_QUEST_COMPLETE_DIALOG fires when turning in  a
                        -- quest. Use this to detect when the user (or your own
                        -- automation code) has turned in a quest.
    EVENT_MANAGER:RegisterForEvent( name
                                  , EVENT_QUEST_COMPLETE_DIALOG
                                  , function(event_code, quest_index)
                                        Example2.OnQuestCompleteDialog(quest_index)
                                    end )

    LibCraftText.rolis_registered = true
    Info("Dialog listeners registered."
         .." Go acquire or turn in some crafting quests.")
end

function Example2.UnregisterEventListeners()
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

function Example2.OnChatterBegin()
                        -- A dialog with an NPC (or the daily writ board!)
                        -- has begun. Who is it?
    local self         = Example2
    local dialog_title = self.GetDialogTitle()

                        -- Is it the daily writ board?
    if LibCraftText.DailyDialogTitleIsWritBoard(dialog_title) then
        self.ChatterWritBoard()
        return
    end

                        -- Is it a daily writ turn-in crate?
    local crafting_type = LibCraftText.DailyDialogTurnInTitleToCraftingType(dialog_title)
    if crafting_type then
        Example2.ChatterDeliveryCrate()
        return
    end
                        -- Not a writ board. Not a turn-in crate.
                        -- Not part of this example.
end

function Example2.OnQuestOffered()
                        -- A "quest offer" dialog is on screen now.
    Example2.QuestOfferedDailyWrit()
end

function Example2.OnQuestAdded(quest_index, quest_name)
                        -- We just accepted a quest.
    Example2.QuestAdded(quest_index, quest_name)
end

function Example2.OnQuestCompleteDialog(quest_index)
    Example2.QuestCompleteDialog(quest_index)
end

function Example2.GetDialogTitle()
    return ZO_InteractWindowTargetAreaTitle:GetText()
end
