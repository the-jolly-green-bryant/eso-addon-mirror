local OldJournalSceneGroup = PP.journalSceneGroup
PP.journalSceneGroup = function()
    PP:CreateBackground(JQL_Window, nil, nil, nil, -10, -10, nil, nil, nil, 0, 10)
    PP.Anchor(JQL_Window, TOPRIGHT, GuiRoot, TOPRIGHT, 0, 120, true, BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, -70)

    return OldJournalSceneGroup()
end

local OldJournalQuestLogInitalize = JournalQuestLog.Initialize
function JournalQuestLog.Initialize()
    OldJournalQuestLogInitalize()

    JQL_SCENE:RemoveFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    JQL_SCENE:RemoveFragment(RIGHT_BG_FRAGMENT)
    JQL_SCENE:RemoveFragment(TITLE_FRAGMENT)
    JQL_SCENE:RemoveFragment(JOURNAL_TITLE_FRAGMENT)
    JQL_SCENE:RemoveFragment(TREE_UNDERLAY_FRAGMENT)
end