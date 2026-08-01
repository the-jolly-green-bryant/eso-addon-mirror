ZO_CreateStringId("SI_BINDING_NAME_BUGCATCHER_OPENLAM", "Open/Close Panel")
ZO_CreateStringId("SI_BINDING_NAME_BUGCATCHER_PREVIOUSBUG", "Previous Bug")
ZO_CreateStringId("SI_BINDING_NAME_BUGCATCHER_NEXTBUG", "Next Bug")
ZO_CreateStringId("SI_BINDING_NAME_BUGCATCHER_DISMISSBUG", "Dismiss Bug")
ZO_CreateStringId("SI_BINDING_NAME_BUGCATCHER_WIPEBUGS", "Wipe All Bugs")

-- OPEN/CLOSE LAM2 PANEL
function BugCatcherKeybinds_OpenLAM()
    if BugCatcher_Panel and LibAddonMenu2 then
        if not BugCatcher_Panel:IsHidden() then
            SCENE_MANAGER:ShowBaseScene()
        else
            LibAddonMenu2:OpenToPanel(BugCatcher_Panel)
        end
    end
end

-- BUTTONS
function BugCatcherKeybinds_PreviousBug()
    if BugCatcher and BugCatcher.previousBug then
        BugCatcher.previousBug()

        if BugCatcher_Panel and not BugCatcher_Panel:IsHidden() then
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BugCatcher_Panel)
        end
    end
end
function BugCatcherKeybinds_NextBug()
    if BugCatcher and BugCatcher.nextBug then
        BugCatcher.nextBug()

        if BugCatcher_Panel and not BugCatcher_Panel:IsHidden() then
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BugCatcher_Panel)
        end
    end
end
function BugCatcherKeybinds_DismissBug()
    if BugCatcher and BugCatcher.dismissBug then
        BugCatcher.dismissBug()

        if BugCatcher_Panel and not BugCatcher_Panel:IsHidden() then
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BugCatcher_Panel)
        end
    end
end
function BugCatcherKeybinds_WipeBugs()
    if BugCatcher and BugCatcher.wipeBugs then
        BugCatcher.wipeBugs()

        if BugCatcher_Panel and not BugCatcher_Panel:IsHidden() then
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", BugCatcher_Panel)
        end
    end
end