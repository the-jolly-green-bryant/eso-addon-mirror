local Addon = LarvalTearMod
local LTM = Addon
local Log = Addon.Common.Log
local LTM_ATTRIBUTE_APPLY = Addon.Modules.AttributeApply
local LTM_APPLY_START_STATE = Addon.Modules.ApplyStartState
local LTM_SKILL_RESPEC_APPLY = Addon.Modules.SkillRespecApply

local START_CLEAN_POLL_MS = 200
local START_CLEAN_MAX_ATTEMPTS = 20

local function IsControlVisible(control)
    return type(control) == "userdata"
        and type(control.IsHidden) == "function"
        and not control:IsHidden()
end

local function IsShowingScene(sceneName)
    return SCENE_MANAGER:IsShowing(sceneName)
end

local function GetCurrentSceneName()
    local scene = SCENE_MANAGER:GetCurrentScene()
    if type(scene) ~= "table" or type(scene.GetName) ~= "function" then
        return nil
    end

    return scene:GetName()
end

local function IsCurrentSceneBase()
    if type(SCENE_MANAGER.GetCurrentScene) ~= "function"
        or type(SCENE_MANAGER.GetBaseScene) ~= "function" then
        return false
    end

    local currentScene = SCENE_MANAGER:GetCurrentScene()
    local baseScene = SCENE_MANAGER:GetBaseScene()
    return currentScene ~= nil and currentScene == baseScene
end

local function IsCurrentSceneTransitioning()
    if type(SCENE_MANAGER.GetCurrentScene) ~= "function" then
        return false
    end

    local scene = SCENE_MANAGER:GetCurrentScene()
    if type(scene) ~= "table" then
        return false
    end

    if type(scene.IsTransitioning) == "function" and scene:IsTransitioning() == true then
        return true
    end

    if type(scene.GetState) ~= "function" then
        return false
    end

    local state = scene:GetState()
    local showingState = rawget(_G, "SCENE_SHOWING")
    local hidingState = rawget(_G, "SCENE_HIDING")
    return (showingState ~= nil and state == showingState)
        or (hidingState ~= nil and state == hidingState)
end

local function GetInteractionTypeSafe()
    if type(GetInteractionType) == "function" then
        return GetInteractionType()
    end

    return nil
end

local function HasSkillPendingChanges()
    if type(SKILLS_AND_ACTION_BAR_MANAGER) ~= "table" then
        return nil
    end

    if type(SKILLS_AND_ACTION_BAR_MANAGER.HasAnyPendingChanges) ~= "function" then
        return nil
    end

    return SKILLS_AND_ACTION_BAR_MANAGER:HasAnyPendingChanges()
end

local function IsSceneTransitioning(sceneName)
    local scene = SCENE_MANAGER:GetScene(sceneName)
    if type(scene) ~= "table" or type(scene.IsTransitioning) ~= "function" then
        return false
    end

    return scene:IsTransitioning() == true
end

local function LogSummary(...)
    if type(Log.LogDebugSummary) == "function" then
        Log.LogDebugSummary(...)
    end
end

local function IsLonePendingFalsePositive(snapshot)
    if type(snapshot) ~= "table" then
        return false
    end

    if snapshot.hasPendingChanges ~= true then
        return false
    end

    if snapshot.interaction ~= nil and snapshot.interaction ~= 0 then
        return false
    end

    if snapshot.allocationMode ~= nil and snapshot.allocationMode ~= 0 then
        return false
    end

    if type(snapshot.castRemainingMs) == "number" and snapshot.castRemainingMs > 0 then
        return false
    end

    if snapshot.skillsShowing == true
        or snapshot.gamepadSkillsShowing == true
        or snapshot.statsShowing == true
        or snapshot.gamepadStatsShowing == true
        or snapshot.sceneTransitioning == true
        or snapshot.dialogVisible == true then
        return false
    end

    return true
end

local function GetVisibleKeyboardDialog()
    local dialog = rawget(_G, "ZO_Dialog1")
    if IsControlVisible(dialog) then
        return dialog
    end

    return nil
end

local function IsAnyDialogShowing(visibleKeyboardDialog)
    if visibleKeyboardDialog ~= nil then
        return true
    end

    return type(ZO_Dialogs_IsShowingDialog) == "function"
        and ZO_Dialogs_IsShowingDialog() == true
end

local function GetDialogInfo(dialog)
    if type(dialog) ~= "userdata" then
        return nil
    end

    local info = dialog.info
    return type(info) == "table" and info or nil
end

local function GetDialogName(dialog)
    local info = GetDialogInfo(dialog)
    if type(info) ~= "table" then
        return nil
    end

    return info.name or info.dialogName or info.uniqueIdentifier or nil
end

local function GetDialogButton(dialog, index)
    if type(dialog) ~= "userdata" or type(dialog.GetNamedChild) ~= "function" then
        return nil
    end

    return dialog:GetNamedChild("Button" .. tostring(index))
end

local function GetControlText(control)
    if type(control) ~= "userdata" then
        return nil
    end

    if type(control.GetText) == "function" then
        local ok, text = pcall(control.GetText, control)
        if ok and type(text) == "string" and text ~= "" then
            return text
        end
    end

    if type(control.GetNamedChild) == "function" then
        local textChild = control:GetNamedChild("Text")
        if type(textChild) == "userdata" and type(textChild.GetText) == "function" then
            local ok, text = pcall(textChild.GetText, textChild)
            if ok and type(text) == "string" and text ~= "" then
                return text
            end
        end
    end

    return nil
end

local function GetDialogButtonText(dialog, index)
    return GetControlText(GetDialogButton(dialog, index))
end

local function ContainsToken(text, token)
    return type(text) == "string"
        and type(token) == "string"
        and string.find(string.lower(text), string.lower(token), 1, true) ~= nil
end

local function ResolveDialogDismissButtonIndex(dialog)
    local button1Text = GetDialogButtonText(dialog, 1)
    local button2Text = GetDialogButtonText(dialog, 2)

    if ContainsToken(button1Text, "accept")
        or ContainsToken(button1Text, "continue")
        or ContainsToken(button1Text, "leave")
        or ContainsToken(button1Text, "discard")
        or ContainsToken(button1Text, "yes") then
        return 1, button1Text, button2Text
    end

    if ContainsToken(button2Text, "accept")
        or ContainsToken(button2Text, "continue")
        or ContainsToken(button2Text, "leave")
        or ContainsToken(button2Text, "discard")
        or ContainsToken(button2Text, "yes") then
        return 2, button1Text, button2Text
    end

    return 1, button1Text, button2Text
end

local function InvokeDialogButtonCallback(dialog, button)
    if type(button) ~= "userdata" then
        return false, "dialog_button_missing"
    end

    if type(button.OnClicked) == "function" then
        local ok, err = pcall(button.OnClicked, button)
        if ok then
            return true
        end

        return false, err
    end

    local callback = button.m_callback
    if type(callback) ~= "function" then
        return false, "dialog_button_callback_missing"
    end

    local ok, err = pcall(callback, dialog)
    if not ok then
        return false, err
    end

    return true
end

function LTM_APPLY_START_STATE:BuildSnapshot()
    local interaction = GetInteractionTypeSafe()
    local hasPendingChanges = HasSkillPendingChanges()
    local allocationMode = type(SKILLS_AND_ACTION_BAR_MANAGER) == "table"
        and type(SKILLS_AND_ACTION_BAR_MANAGER.GetSkillPointAllocationMode) == "function"
        and SKILLS_AND_ACTION_BAR_MANAGER:GetSkillPointAllocationMode()
        or nil
    local castRemainingMs = type(GetSkillRespecCastTimeRemainingMs) == "function"
        and GetSkillRespecCastTimeRemainingMs()
        or nil
    local skillsShowing = IsShowingScene("skills")
    local gamepadSkillsShowing = IsShowingScene("gamepad_skills_root")
    local statsShowing = IsShowingScene("stats")
    local gamepadStatsShowing = IsShowingScene("gamepad_stats_root")
    local requiresConfirmScreen = hasPendingChanges == true
        or (interaction ~= nil and interaction ~= 0)
    local visibleDialog = GetVisibleKeyboardDialog()
    local snapshot = {
        scene = GetCurrentSceneName(),
        currentSceneIsBase = IsCurrentSceneBase(),
        currentSceneTransitioning = IsCurrentSceneTransitioning(),
        interaction = interaction,
        hasPendingChanges = hasPendingChanges,
        skillsShowing = skillsShowing,
        gamepadSkillsShowing = gamepadSkillsShowing,
        statsShowing = statsShowing,
        gamepadStatsShowing = gamepadStatsShowing,
        sceneTransitioning = IsSceneTransitioning("skills")
            or IsSceneTransitioning("gamepad_skills_root")
            or IsSceneTransitioning("stats")
            or IsSceneTransitioning("gamepad_stats_root"),
        requiresConfirmScreen = requiresConfirmScreen,
        dialogName = GetDialogName(visibleDialog),
        dialogVisible = IsAnyDialogShowing(visibleDialog),
        allocationMode = allocationMode,
        castRemainingMs = castRemainingMs,
    }
    snapshot.lonePendingFalsePositive = IsLonePendingFalsePositive(snapshot)
    if snapshot.lonePendingFalsePositive == true then
        snapshot.requiresConfirmScreen = false
    end

    return snapshot
end

function LTM_APPLY_START_STATE:IsHudBaseline(snapshot)
    return type(snapshot) == "table"
        and (snapshot.hasPendingChanges ~= true or snapshot.lonePendingFalsePositive == true)
        and (snapshot.interaction == nil or snapshot.interaction == 0)
        and snapshot.skillsShowing ~= true
        and snapshot.gamepadSkillsShowing ~= true
        and snapshot.statsShowing ~= true
        and snapshot.gamepadStatsShowing ~= true
        and snapshot.sceneTransitioning ~= true
end

local function IsCleanStartFastPathEligible(snapshot, classification)
    if classification ~= "start_clean"
        or not LTM_APPLY_START_STATE:IsHudBaseline(snapshot)
        or snapshot.currentSceneIsBase ~= true
        or snapshot.sceneTransitioning ~= false
        or snapshot.currentSceneTransitioning ~= false
        or snapshot.hasPendingChanges ~= false
        or snapshot.dialogVisible ~= false then
        return false
    end

    if snapshot.allocationMode ~= nil and snapshot.allocationMode ~= 0 then
        return false
    end

    if snapshot.castRemainingMs ~= nil
        and (type(snapshot.castRemainingMs) ~= "number" or snapshot.castRemainingMs > 0) then
        return false
    end

    return true
end

function LTM_APPLY_START_STATE:Classify(snapshot)
    if type(snapshot) ~= "table" then
        return "start_unrecoverable", "start_state_snapshot_missing"
    end

    if type(zo_callLater) ~= "function" then
        return "start_unrecoverable", "start_state_zo_callLater_unavailable"
    end

    if type(SKILLS_AND_ACTION_BAR_MANAGER) == "table"
        and type(SKILLS_AND_ACTION_BAR_MANAGER.HasAnyPendingChanges) ~= "function" then
        return "start_unrecoverable", "start_state_pending_state_unavailable"
    end

    if snapshot.requiresConfirmScreen == true then
        return "start_requires_confirm"
    end

    return "start_clean"
end

function LTM_APPLY_START_STATE:LogPrecheck(snapshot, classification, confirmShown, cleanAttemptResult, pipelineStarted)
    snapshot = type(snapshot) == "table" and snapshot or {}
    LogSummary(
        "Apply start precheck",
        "classification=" .. tostring(classification),
        "scene=" .. tostring(snapshot.scene),
        "interaction=" .. tostring(snapshot.interaction),
        "hasPendingChanges=" .. tostring(snapshot.hasPendingChanges),
        "dialogVisible=" .. tostring(snapshot.dialogVisible),
        "dialogName=" .. tostring(snapshot.dialogName),
        "lonePendingFalsePositive=" .. tostring(snapshot.lonePendingFalsePositive == true),
        "confirmShown=" .. tostring(confirmShown),
        "cleanAttemptResult=" .. tostring(cleanAttemptResult),
        "pipelineStarted=" .. tostring(pipelineStarted)
    )
end

function LTM_APPLY_START_STATE:NotifyCleanFailure(_reason)
    if type(LTM) == "table" and type(LTM.GetStringText) == "function" and type(Log.WriteChat) == "function" then
        Log.WriteChat(LTM.GetStringText("SI_LTM_START_STATE_CLEAN_FAILED"))
    end
end

function LTM_APPLY_START_STATE:DismissPendingConfirmationIfNeeded(snapshot)
    snapshot = type(snapshot) == "table" and snapshot or self:BuildSnapshot()
    if snapshot.dialogVisible ~= true then
        return false, nil
    end

    local dialog = GetVisibleKeyboardDialog()
    if dialog == nil then
        return false, nil
    end

    local buttonIndex, button1Text, button2Text = ResolveDialogDismissButtonIndex(dialog)
    local invokeOk, invokeErr = InvokeDialogButtonCallback(dialog, GetDialogButton(dialog, buttonIndex))
    local buttonUsed = buttonIndex

    if not invokeOk then
        local fallbackIndex = buttonIndex == 1 and 2 or 1
        invokeOk, invokeErr = InvokeDialogButtonCallback(dialog, GetDialogButton(dialog, fallbackIndex))
        buttonUsed = fallbackIndex
    end

    LogSummary(
        "Apply start clean dialog",
        "dialogName=" .. tostring(snapshot.dialogName),
        "button1Text=" .. tostring(button1Text),
        "button2Text=" .. tostring(button2Text),
        "buttonUsed=" .. tostring(buttonUsed),
        "invokeOk=" .. tostring(invokeOk),
        "invokeErr=" .. tostring(invokeErr)
    )

    -- ESO dialogs may be tracked by name or by control depending on the UI path.
    -- Try both defensively; either release attempt may fail without being fatal.
    if type(ZO_Dialogs_ReleaseDialog) == "function" and snapshot.dialogName ~= nil then
        pcall(ZO_Dialogs_ReleaseDialog, snapshot.dialogName)
    end

    if type(ZO_Dialogs_ReleaseDialog) == "function" then
        pcall(ZO_Dialogs_ReleaseDialog, dialog, true)
    end

    return true, snapshot.dialogName, dialog
end

function LTM_APPLY_START_STATE:ForceCloseVisibleDialog(snapshot, dialogName, dialogControl)
    snapshot = type(snapshot) == "table" and snapshot or self:BuildSnapshot()
    if snapshot.dialogVisible ~= true then
        return false
    end

    -- Force close mirrors the same defensive release strategy: control-backed
    -- and name-backed dialogs are both acceptable cleanup targets.
    if type(ZO_Dialogs_ReleaseDialog) == "function" and type(dialogControl) == "userdata" then
        pcall(ZO_Dialogs_ReleaseDialog, dialogControl, true)
    elseif type(ZO_Dialogs_ReleaseDialog) == "function" then
        local releaseName = dialogName or snapshot.dialogName
        if releaseName ~= nil then
            pcall(ZO_Dialogs_ReleaseDialog, releaseName, true)
        end
    end

    local afterSnapshot = self:BuildSnapshot()
    LogSummary(
        "Apply start force close dialog",
        "beforeVisible=" .. tostring(snapshot.dialogVisible),
        "beforeName=" .. tostring(snapshot.dialogName),
        "targetName=" .. tostring(dialogName),
        "targetControl=" .. tostring(dialogControl),
        "afterVisible=" .. tostring(afterSnapshot.dialogVisible),
        "afterName=" .. tostring(afterSnapshot.dialogName)
    )

    return afterSnapshot.dialogVisible ~= true
end

function LTM_APPLY_START_STATE:ShowConfirmDialog(onConfirm, onCancel)
    if type(LTM.RequestApplyStartConfirmation) ~= "function" then
        return false, "start_state_confirm_dialog_unavailable"
    end

    local shown = LTM:RequestApplyStartConfirmation({
        onConfirm = onConfirm,
        onCancel = onCancel,
    })
    if shown ~= true then
        return false, "start_state_confirm_dialog_unavailable"
    end

    return true
end

function LTM_APPLY_START_STATE:CancelToClean()
    if type(LTM_SKILL_RESPEC_APPLY) == "table" and type(LTM_SKILL_RESPEC_APPLY.ClearPendingContext) == "function" then
        pcall(LTM_SKILL_RESPEC_APPLY.ClearPendingContext, LTM_SKILL_RESPEC_APPLY)
    end

    if type(LTM_ATTRIBUTE_APPLY) == "table" then
        if type(LTM_ATTRIBUTE_APPLY.ClearPendingContext) == "function" then
            pcall(LTM_ATTRIBUTE_APPLY.ClearPendingContext, LTM_ATTRIBUTE_APPLY)
        else
            LTM_ATTRIBUTE_APPLY.pendingContext = nil
        end
    end

    if type(SKILLS_AND_ACTION_BAR_MANAGER) == "table" then
        local manager = SKILLS_AND_ACTION_BAR_MANAGER
        if type(manager.CancelChanges) == "function" then
            pcall(manager.CancelChanges, manager)
        elseif type(manager.ClearPendingChanges) == "function" then
            pcall(manager.ClearPendingChanges, manager)
        elseif type(manager.Reset) == "function" then
            pcall(manager.Reset, manager)
        end
    end

    if type(SKILL_POINT_ALLOCATION_MANAGER) == "table" and type(SKILL_POINT_ALLOCATION_MANAGER.Reset) == "function" then
        pcall(SKILL_POINT_ALLOCATION_MANAGER.Reset, SKILL_POINT_ALLOCATION_MANAGER)
    end

    if type(ACTION_BAR_ASSIGNMENT_MANAGER) == "table" and type(ACTION_BAR_ASSIGNMENT_MANAGER.Reset) == "function" then
        pcall(ACTION_BAR_ASSIGNMENT_MANAGER.Reset, ACTION_BAR_ASSIGNMENT_MANAGER)
    end

    if type(SKILL_LINE_ASSIGNMENT_MANAGER) == "table" and type(SKILL_LINE_ASSIGNMENT_MANAGER.Reset) == "function" then
        pcall(SKILL_LINE_ASSIGNMENT_MANAGER.Reset, SKILL_LINE_ASSIGNMENT_MANAGER)
    end
end

function LTM_APPLY_START_STATE:NormalizeToHudBaseline(onComplete)
    if type(onComplete) ~= "function" then
        return false, "start_state_completion_required"
    end

    self:CancelToClean()

    SCENE_MANAGER:ShowBaseScene()

    local context = {
        attemptIndex = 0,
        dismissedDialog = false,
        dismissedDialogName = nil,
        dismissedDialogControl = nil,
    }

    local function poll()
        context.attemptIndex = context.attemptIndex + 1
        local snapshot = self:BuildSnapshot()
        local dismissedDialog, dismissedDialogName, dismissedDialogControl = self:DismissPendingConfirmationIfNeeded(snapshot)
        if dismissedDialog == true then
            context.dismissedDialog = true
            context.dismissedDialogName = dismissedDialogName or context.dismissedDialogName
            context.dismissedDialogControl = dismissedDialogControl or context.dismissedDialogControl
        end
        SCENE_MANAGER:ShowBaseScene()
        snapshot = self:BuildSnapshot()
        if self:IsHudBaseline(snapshot) then
            if context.dismissedDialog == true then
                self:ForceCloseVisibleDialog(snapshot, context.dismissedDialogName, context.dismissedDialogControl)
            end
            snapshot = self:BuildSnapshot()
            onComplete(true, nil, snapshot)
            return
        end

        if context.attemptIndex >= START_CLEAN_MAX_ATTEMPTS then
            onComplete(false, "start_state_clean_timeout", snapshot)
            return
        end

        zo_callLater(poll, START_CLEAN_POLL_MS)
    end

    zo_callLater(poll, START_CLEAN_POLL_MS)
    return true
end

function LTM_APPLY_START_STATE:Begin(request, completion, startPipeline)
    if type(startPipeline) ~= "function" then
        return false, "start_state_pipeline_callback_required"
    end

    local snapshot = self:BuildSnapshot()
    local classification, reason = self:Classify(snapshot)
    self:LogPrecheck(snapshot, classification, "no", "not_started", false)

    if classification == "start_unrecoverable" then
        self:NotifyCleanFailure(reason)
        self:LogPrecheck(snapshot, classification, "no", "failed", false)
        if type(completion) == "function" then
            completion(false, reason)
        end
        return true, "handled"
    end

    local function startAfterClean(confirmShown, cleanSnapshot, cleanAttemptResult)
        self:LogPrecheck(
            cleanSnapshot or snapshot,
            classification,
            confirmShown,
            cleanAttemptResult,
            false
        )

        local startOk, startErr = startPipeline(request, completion)
        if startOk ~= true and startErr ~= "handled" then
            local notified = type(LTM.NotifyActionError) == "function"
                and LTM:NotifyActionError("common.apply", startErr) == true
            if not notified and type(Log.Debug) == "function" then
                Log.Debug("Apply start pipeline failed reason=" .. tostring(startErr or "unknown"))
            end
        end

        self:LogPrecheck(
            cleanSnapshot or snapshot,
            classification,
            confirmShown,
            cleanAttemptResult,
            startOk == true
        )
    end

    local function continueAfterClean(confirmShown)
        local cleanStarted, cleanErr = self:NormalizeToHudBaseline(function(ok, cleanReason, cleanSnapshot)
            local cleanAttemptResult = ok and "clean" or tostring(cleanReason or "failed")
            if not ok then
                self:NotifyCleanFailure(cleanReason)
                self:LogPrecheck(
                    cleanSnapshot or snapshot,
                    classification,
                    confirmShown,
                    cleanAttemptResult,
                    false
                )
                if type(completion) == "function" then
                    completion(false, cleanReason)
                end
                return
            end

            startAfterClean(confirmShown, cleanSnapshot, cleanAttemptResult)
        end)

        if not cleanStarted then
            self:NotifyCleanFailure(cleanErr)
            self:LogPrecheck(snapshot, classification, confirmShown, tostring(cleanErr), false)
            if type(completion) == "function" then
                completion(false, cleanErr)
            end
        end
    end

    if IsCleanStartFastPathEligible(snapshot, classification) then
        self:CancelToClean()
        startAfterClean("no", snapshot, "clean_fast_path")
        return true, "handled"
    end

    if classification == "start_clean" then
        continueAfterClean("no")
        return true, "handled"
    end

    local confirmOk, confirmErr = self:ShowConfirmDialog(function()
        continueAfterClean("yes")
    end, function()
        self:LogPrecheck(snapshot, classification, "no", "not_started", false)
        if type(completion) == "function" then
            completion(false, "start_state_canceled")
        end
    end)
    if not confirmOk then
        self:NotifyCleanFailure(confirmErr)
        self:LogPrecheck(snapshot, classification, "confirm_ui_unavailable", "failed", false)
        if type(completion) == "function" then
            completion(false, confirmErr)
        end
        return true, "handled"
    end

    self:LogPrecheck(snapshot, classification, "yes", "waiting_for_user", false)
    return true, "handled"
end
