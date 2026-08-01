-----------------------------------------------------------
-- DarkScrollsUI - DS_Quest.lua
-- Quest tracker showing the focused quest with its main
-- objectives, optional steps and hint steps — mirroring
-- the native ESO tracker behaviour.
--
-- Step visibility constants (ESOUI):
--   QUEST_STEP_VISIBILITY_OPTIONAL  = optional side steps
--   QUEST_STEP_VISIBILITY_HINT      = hidden/hint steps
-- Step type constants (ESOUI):
--   QUEST_STEP_TYPE_AND / _OR / _END
-----------------------------------------------------------

DarkScrollsUI.QuestTrackerDisplay = nil

-----------------------------------------------------------
-- LABEL POOL (procedural)
-- Labels are reused across refreshes to avoid accumulation.
-----------------------------------------------------------
local function CreateLabelPool(parent, baseName)
    return { parent = parent, baseName = baseName, pool = {}, active = {}, count = 0 }
end

local function LabelPoolAcquire(lp)
    local label = table.remove(lp.pool)
    if not label then
        lp.count = lp.count + 1
        label = WINDOW_MANAGER:CreateControl(lp.baseName .. lp.count, lp.parent, CT_LABEL)
        label:SetDrawTier(DT_HIGH)
        label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    end
    label:SetHidden(false)
    table.insert(lp.active, label)
    return label
end

local function LabelPoolReleaseAll(lp)
    for _, label in ipairs(lp.active) do
        label:SetHidden(true)
        label:ClearAnchors()
        table.insert(lp.pool, label)
    end
    lp.active = {}
end

-----------------------------------------------------------
-- HELPERS (mirrors CQT TrackerPanel local helpers)
-----------------------------------------------------------

-- Returns number of visible (non-fail) conditions in a step.
local function GetNumVisibleConditions(questIndex, stepIndex)
    local count = 0
    for ci = 1, GetJournalQuestNumConditions(questIndex, stepIndex) do
        local _, _, isFailCondition, _, _, isVisible =
            GetJournalQuestConditionValues(questIndex, stepIndex, ci)
        if isVisible and not isFailCondition then
            count = count + 1
        end
    end
    return count
end

-- Returns total visible hint conditions across all hint steps.
local function GetNumVisibleHintConditions(questIndex)
    local count = 0
    local numSteps = GetJournalQuestNumSteps(questIndex) or 0
    for si = QUEST_MAIN_STEP_INDEX + 1, numSteps do
        local _, stepVisibility, stepType = GetJournalQuestStepInfo(questIndex, si)
        if stepType ~= QUEST_STEP_TYPE_END
        and stepVisibility == QUEST_STEP_VISIBILITY_HINT then
            count = count + GetNumVisibleConditions(questIndex, si)
        end
    end
    return count
end

-- True when a step has no overrideText, is OR-type, and has >2
-- visible conditions — same check CQT uses for "IsOrDescription".
local function IsOrStep(questIndex, stepIndex)
    local _, _, stepType, overrideText = GetJournalQuestStepInfo(questIndex, stepIndex)
    return (not overrideText or overrideText == "")
        and stepType == QUEST_STEP_TYPE_OR
        and GetNumVisibleConditions(questIndex, stepIndex) > 2
end

-----------------------------------------------------------
-- CONDITION RENDERER
-- Appends labels for one step to the tracker frame.
-- Returns the number of labels added.
-----------------------------------------------------------
local function RenderConditions(control, questIndex, stepIndex,
                                scale, labelW, isHint, lineCount, maxLines)
    local _, stepVisibility, stepType, overrideText, conditionCount =
        GetJournalQuestStepInfo(questIndex, stepIndex)

    -- Colour: hints slightly dimmer (matches CQT hintColor intent)
    local r, g, b = isHint and 0.75 or 1, isHint and 0.75 or 1, isHint and 0.75 or 1

    if overrideText and overrideText ~= "" then
        -- Single override-text entry for the whole step
        if lineCount >= maxLines then return 0 end
        local label = LabelPoolAcquire(control.pool)
        local prev  = control.lastLabel
        label:SetAnchor(TOPRIGHT,
            prev or control.title, BOTTOMRIGHT,
            0, prev and 3 or 8)
        label:SetFont("ZoFontWinH4")
        label:SetColor(r, g, b, 1)
        label:SetScale(scale * 0.85)
        label:SetWidth(labelW)
        label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        label:SetText("• " .. overrideText)
        control.lastLabel = label
        return 1
    end

    local added = 0
    for ci = 1, conditionCount do
        if lineCount + added >= maxLines then break end
        local conditionText, _, _, isFailCondition, isComplete, _, isVisible =
            GetJournalQuestConditionInfo(questIndex, stepIndex, ci)
        if isVisible and not isFailCondition and conditionText ~= "" then
            local label = LabelPoolAcquire(control.pool)
            local prev  = control.lastLabel
            label:SetAnchor(TOPRIGHT,
                prev or control.title, BOTTOMRIGHT,
                0, prev and 3 or 8)
            -- Completed conditions: greyed out with a check marker
            if isComplete then
                label:SetFont("ZoFontWinH4")
                label:SetColor(0.55, 0.55, 0.55, 1)
                label:SetScale(scale * 0.80)
                label:SetWidth(labelW)
                label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                label:SetText("[x] " .. conditionText)
            else
                label:SetFont("ZoFontWinH4")
                label:SetColor(r, g, b, 1)
                label:SetScale(scale * 0.85)
                label:SetWidth(labelW)
                label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                label:SetText("• " .. conditionText)
            end
            control.lastLabel = label
            added = added + 1
        end
    end
    return added
end

-- Renders a small sub-header label (e.g. "Optional:", "Hints (2):")
local function RenderSubHeader(control, text, scale, labelW)
    local label = LabelPoolAcquire(control.pool)
    local prev  = control.lastLabel
    label:SetAnchor(TOPRIGHT,
        prev or control.title, BOTTOMRIGHT,
        0, prev and 6 or 8)
    label:SetFont("ZoFontWinH4")
    label:SetColor(1, 0.65, 0, 1)   -- amber — distinct from white conditions
    label:SetScale(scale * 0.78)
    label:SetWidth(labelW)
    label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    label:SetText(text)
    control.lastLabel = label
    return label
end

-----------------------------------------------------------
-- UPDATE
-----------------------------------------------------------
function DarkScrollsUI.UpdateQuestTrackerInformation()
    local control = DarkScrollsUI.QuestTrackerDisplay
    if not control then return end

    local enabled   = DarkScrollsUI.SavedVariables
                      and DarkScrollsUI.SavedVariables.customQuestTrackerEnabled
    local isEditing = not DarkScrollsUI.isInterfaceLocked
                      or DarkScrollsUI.isGlobalEditModeActive
    local s         = DarkScrollsUI.SavedVariables
                      and DarkScrollsUI.SavedVariables["DarkScrollsUI_QuestObjectiveTracker"]

    if not enabled and not isEditing then
        control:SetHidden(true)
        return
    end

    control:SetHidden(false)
    control:SetAlpha((s and s.a) or 1)

    local fontScale    = (s and s.fs) or 1
    local currentWidth = control:GetWidth()
    if currentWidth < 50 then currentWidth = 300 end
    local scale  = (currentWidth / 300) * fontScale
    local labelW = math.max(50, currentWidth - 10)

    -- Release all pooled labels from the previous frame
    LabelPoolReleaseAll(control.pool)
    control.lastLabel = nil

    -- ── EDIT MODE ────────────────────────────────────────
    if isEditing then
        control.bg:SetCenterColor(0, 1, 0, 0.3)
        control.bg:SetEdgeColor(0, 1, 0, 0.8)
        control.title:SetText("QUEST NAME (EDIT MODE)")
        control.title:SetHidden(false)
        control.title:SetScale(scale)
        control.title:SetWidth(labelW)

        local sampleLines = {
            "• Main objective example",
            "• Another main objective",
            "Optional:",
            "• Optional objective",
            "Hints (1):",
            "• Hint line example",
        }
        for _, txt in ipairs(sampleLines) do
            local lbl = LabelPoolAcquire(control.pool)
            local prev = control.lastLabel
            lbl:SetAnchor(TOPRIGHT,
                prev or control.title, BOTTOMRIGHT, 0, prev and 3 or 8)
            lbl:SetFont("ZoFontWinH4")
            lbl:SetColor(1, 1, 1, 1)
            lbl:SetScale(scale * 0.85)
            lbl:SetWidth(labelW)
            lbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            lbl:SetText(txt)
            control.lastLabel = lbl
        end
        return
    else
        control.bg:SetCenterColor(0, 0, 0, 0)
        control.bg:SetEdgeColor(0, 0, 0, 0)
    end

    -- ── LIVE MODE ────────────────────────────────────────
    if not (GetNumJournalQuests and GetJournalQuestName) then
        control:SetHidden(true)
        return
    end

    -- Find focused quest (assisted first, then first valid)
    local questIndex = 0
    for i = 1, MAX_JOURNAL_QUESTS do
        if IsValidQuestIndex(i) then
            if GetTrackedIsAssisted and GetTrackedIsAssisted(TRACK_TYPE_QUEST or 1, i) then
                questIndex = i
                break
            end
        end
    end
    if questIndex == 0 then
        for i = 1, MAX_JOURNAL_QUESTS do
            if IsValidQuestIndex(i) then
                questIndex = i
                break
            end
        end
    end

    if questIndex == 0 then
        control.title:SetText("")
        control.title:SetHidden(true)
        return
    end

    local questName = GetJournalQuestName(questIndex) or ""
    if questName == "" then
        control.title:SetHidden(true)
        return
    end

    control.title:SetText(tostring(questName):upper())
    control.title:SetHidden(false)
    control.title:SetScale(scale)
    control.title:SetWidth(labelW)

    local MAX_LINES = 12   -- safety cap so the tracker never overflows the screen
    local lineCount = 0
    local numSteps  = GetJournalQuestNumSteps(questIndex) or 0

    -- ── MAIN STEP (QUEST_MAIN_STEP_INDEX) ────────────────
    do
        local stepText, _, _, overrideText, numConditions =
            GetJournalQuestStepInfo(questIndex, QUEST_MAIN_STEP_INDEX)

        if numConditions and numConditions > 0 then
            lineCount = lineCount + RenderConditions(
                control, questIndex, QUEST_MAIN_STEP_INDEX,
                scale, labelW, false, lineCount, MAX_LINES)
        else
            -- Fallback: show step description
            local desc = (overrideText and overrideText ~= "")
                         and overrideText or stepText
            if desc and desc ~= "" and lineCount < MAX_LINES then
                local lbl = LabelPoolAcquire(control.pool)
                local prev = control.lastLabel
                lbl:SetAnchor(TOPRIGHT,
                    prev or control.title, BOTTOMRIGHT, 0, prev and 3 or 8)
                lbl:SetFont("ZoFontWinH4")
                lbl:SetColor(1, 1, 1, 1)
                lbl:SetScale(scale * 0.85)
                lbl:SetWidth(labelW)
                lbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                lbl:SetText("• " .. desc)
                control.lastLabel = lbl
                lineCount = lineCount + 1
            end
        end
    end

    -- ── OPTIONAL STEPS ───────────────────────────────────
    local optionalHeaderShown = false
    for si = QUEST_MAIN_STEP_INDEX + 1, numSteps do
        if lineCount >= MAX_LINES then break end
        local _, stepVisibility, stepType =
            GetJournalQuestStepInfo(questIndex, si)
        if stepType ~= QUEST_STEP_TYPE_END
        and stepVisibility == QUEST_STEP_VISIBILITY_OPTIONAL then
            if not optionalHeaderShown then
                RenderSubHeader(control,
                    IsOrStep(questIndex, si)
                        and "Optional (choose one):"
                        or  "Optional:",
                    scale, labelW)
                optionalHeaderShown = true
                lineCount = lineCount + 1
            end
            local added = RenderConditions(
                control, questIndex, si,
                scale, labelW, false, lineCount, MAX_LINES)
            lineCount = lineCount + added
        end
    end

    -- ── HINT STEPS ───────────────────────────────────────
    local hintHeaderShown = false
    local visibleHints    = GetNumVisibleHintConditions(questIndex)
    if visibleHints > 0 then
        for si = QUEST_MAIN_STEP_INDEX + 1, numSteps do
            if lineCount >= MAX_LINES then break end
            local _, stepVisibility, stepType =
                GetJournalQuestStepInfo(questIndex, si)
            if stepType ~= QUEST_STEP_TYPE_END
            and stepVisibility == QUEST_STEP_VISIBILITY_HINT then
                if not hintHeaderShown then
                    RenderSubHeader(control,
                        string.format("Hints (%d):", visibleHints),
                        scale, labelW)
                    hintHeaderShown = true
                    lineCount = lineCount + 1
                end
                local added = RenderConditions(
                    control, questIndex, si,
                    scale, labelW, true, lineCount, MAX_LINES)
                lineCount = lineCount + added
            end
        end
    end
end

-----------------------------------------------------------
-- CREATE
-----------------------------------------------------------
function DarkScrollsUI.CreateQuestTrackerDisplay()
    local wm         = WINDOW_MANAGER
    local name       = "DarkScrollsUI_QuestObjectiveTracker"
    local defaultPos = { l = 1600, t = 200, w = 300, h = 150, a = 1, fs = 1 }

    local frame = wm:CreateControl(name, GuiRoot, CT_TOPLEVELCONTROL)
    frame:SetDrawLayer(DL_BACKGROUND)
    frame:SetDrawTier(DT_HIGH)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(not DarkScrollsUI.isInterfaceLocked)
    frame:SetMovable(not DarkScrollsUI.isInterfaceLocked)
    frame:SetHidden(false)

    frame.bg = wm:CreateControl(name .. "BG", frame, CT_BACKDROP)
    frame.bg:SetAnchorFill()
    frame.bg:SetCenterColor(0, 0, 0, 0)
    frame.bg:SetEdgeColor(0, 0, 0, 0)
    frame.bg:SetEdgeTexture("", 1, 1, 2)
    frame.bg:SetDrawTier(DT_LOW)

    frame.title = wm:CreateControl(name .. "Title", frame, CT_LABEL)
    frame.title:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -5, 5)
    frame.title:SetFont("ZoFontWinH3")
    frame.title:SetColor(1, 0.8, 0, 1)
    frame.title:SetDrawTier(DT_HIGH)
    frame.title:SetWidth(300)
    frame.title:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    frame.title:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    -- Dynamic label pool — replaces the old static objectives table
    frame.pool      = CreateLabelPool(frame, name .. "PoolLbl")
    frame.lastLabel = nil

    DarkScrollsUI.QuestTrackerDisplay = frame
    frame.isQuestTracker = true

    if not DarkScrollsUI.SavedVariables[name] then
        DarkScrollsUI.SavedVariables[name] = defaultPos
    end
    local s = DarkScrollsUI.SavedVariables[name]
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.l, s.t)
    frame:SetDimensions(s.w, s.h)

    DarkScrollsUI.SetupCommonInterfaceHandlers(frame)

    local events = {
        EVENT_QUEST_ADDED,
        EVENT_QUEST_REMOVED,
        EVENT_QUEST_ADVANCED,
        EVENT_QUEST_CONDITION_COUNTER_CHANGED,
        EVENT_TRACKING_UPDATE,
    }
    for _, event in ipairs(events) do
        EVENT_MANAGER:RegisterForEvent(
            name .. event, event,
            function() DarkScrollsUI.UpdateQuestTrackerInformation() end)
    end
end
