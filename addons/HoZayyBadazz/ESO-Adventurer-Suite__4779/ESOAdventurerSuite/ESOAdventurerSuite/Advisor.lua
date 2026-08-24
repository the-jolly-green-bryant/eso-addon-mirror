-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.Advisor = EPC.Advisor or {}
local A = EPC.Advisor

A.sessionOptions = {"CONTINUOUS", 30, 60, 120, "CUSTOM"}

local function safeNumber(v, fallback)
    v = tonumber(v)
    if v == nil then return fallback or 0 end
    return v
end

local function lower(v) return string.lower(tostring(v or "")) end

local function nowSeconds()
    if type(GetTimeStamp) == "function" then
        local ok, value = pcall(GetTimeStamp)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return 0
end

local function clampSessionMinutes(minutes)
    minutes = math.floor(safeNumber(minutes, 60) + 0.5)
    if minutes < 15 then minutes = 15 end
    if minutes > 240 then minutes = 240 end
    return minutes
end

local function refreshSessionControlsNow()
    -- Session buttons are user-facing controls and should react immediately.
    -- The full planner/snapshot refresh can stay on EPC's normal throttled pulse.
    if EPC.UI and type(EPC.UI.RefreshSessionControls) == "function" then
        pcall(EPC.UI.RefreshSessionControls, EPC.UI)
    end
end

function A:Initialize()
    if not EPC.saved then return end
    EPC.saved.sessionMinutes = clampSessionMinutes(EPC.saved.sessionMinutes or 60)
    EPC.saved.sessionCustomMinutes = clampSessionMinutes(EPC.saved.sessionCustomMinutes or 90)
    local mode = string.upper(tostring(EPC.saved.sessionMode or "CONTINUOUS"))
    if mode ~= "CONTINUOUS" and mode ~= "TIMED" and mode ~= "CUSTOM" then mode = "CONTINUOUS" end
    EPC.saved.sessionMode = mode
    EPC.saved.sessionStartedAt = safeNumber(EPC.saved.sessionStartedAt, 0)
    EPC.saved.smartCoach = EPC.saved.smartCoach ~= false
end

function A:SetSessionMode(mode)
    if not EPC.saved then return end
    mode = string.upper(tostring(mode or "CONTINUOUS"))
    if mode == "CONT" or mode == "OFF" then mode = "CONTINUOUS" end
    if mode == "CONTINUOUS" then
        EPC.saved.sessionMode = "CONTINUOUS"
        EPC.saved.sessionStartedAt = 0
    elseif mode == "CUSTOM" then
        EPC.saved.sessionMode = "CUSTOM"
        EPC.saved.sessionMinutes = clampSessionMinutes(EPC.saved.sessionCustomMinutes or 90)
        EPC.saved.sessionStartedAt = nowSeconds()
    elseif mode == "TIMED" then
        EPC.saved.sessionMode = "TIMED"
        EPC.saved.sessionStartedAt = nowSeconds()
    else
        return
    end
    refreshSessionControlsNow()
    EPC:RequestRefresh("session-mode")
end

function A:SetSessionMinutes(minutes)
    if not EPC.saved then return end
    minutes = clampSessionMinutes(minutes)
    EPC.saved.sessionMinutes = minutes
    if minutes == 30 or minutes == 60 or minutes == 120 then
        EPC.saved.sessionMode = "TIMED"
    else
        EPC.saved.sessionMode = "CUSTOM"
        EPC.saved.sessionCustomMinutes = minutes
    end
    EPC.saved.sessionStartedAt = nowSeconds()
    refreshSessionControlsNow()
    EPC:RequestRefresh("session-plan")
end

function A:SetCustomSessionMinutes(minutes)
    if not EPC.saved then return end
    minutes = clampSessionMinutes(minutes)
    EPC.saved.sessionCustomMinutes = minutes
    if EPC.saved.sessionMode == "CUSTOM" then
        EPC.saved.sessionMinutes = minutes
        EPC.saved.sessionStartedAt = nowSeconds()
    end
    refreshSessionControlsNow()
    EPC:RequestRefresh("session-custom")
end

function A:GetCustomSessionMinutes()
    return EPC.saved and clampSessionMinutes(EPC.saved.sessionCustomMinutes or 90) or 90
end

function A:GetSessionMode()
    return EPC.saved and tostring(EPC.saved.sessionMode or "CONTINUOUS") or "CONTINUOUS"
end

function A:IsContinuous()
    return self:GetSessionMode() == "CONTINUOUS"
end

function A:GetSessionMinutes()
    return EPC.saved and clampSessionMinutes(EPC.saved.sessionMinutes or 60) or 60
end

function A:GetSessionRemainingMinutes()
    if self:IsContinuous() then return nil end
    local total = self:GetSessionMinutes()
    local started = EPC.saved and safeNumber(EPC.saved.sessionStartedAt, 0) or 0
    local now = nowSeconds()
    if started <= 0 or now <= 0 then return total end
    local remaining = math.ceil(total - ((now - started) / 60))
    if remaining <= 0 then
        -- A timed plan ending never disables coaching. Return to continuous mode instead.
        EPC.saved.sessionMode = "CONTINUOUS"
        EPC.saved.sessionStartedAt = 0
        return nil
    end
    return remaining
end

function A:GetSessionStatusLabel()
    if self:IsContinuous() then return "CONTINUOUS" end
    local remaining = self:GetSessionRemainingMinutes()
    if remaining == nil then return "CONTINUOUS" end
    local mode = self:GetSessionMode()
    if mode == "CUSTOM" then return string.format("CUSTOM / %dm LEFT", remaining) end
    return string.format("%dm LEFT", remaining)
end

function A:GetGroupSize()
    if type(GetGroupSize) == "function" then
        local ok, n = pcall(GetGroupSize)
        if ok then return safeNumber(n, 0) end
    end
    return 0
end

function A:HasAssistedQuest()
    if type(GetNumJournalQuests) ~= "function" or type(GetJournalQuestInfo) ~= "function" then return false end
    local ok, count = pcall(GetNumJournalQuests)
    if not ok then return false end
    for i = 1, safeNumber(count, 0) do
        local qok, name, _, _, _, completed, tracked = pcall(GetJournalQuestInfo, i)
        if qok and name and name ~= "" and not completed and tracked then return true end
    end
    return false
end

function A:DetectContext(snapshot)
    snapshot = snapshot or EPC.lastSnapshot or {}
    local groupSize = self:GetGroupSize()
    local role = EPC.Role and EPC.Role:GetRole() or "DAMAGE"

    if type(IsUnitInDungeon) == "function" then
        local ok, inside = pcall(IsUnitInDungeon, "player")
        if ok and inside then
            if groupSize >= 8 then return "TRIALS", "Detected a large grouped PvE instance" end
            return "DUNGEONS", "Detected a grouped dungeon/instance"
        end
    end
    if groupSize >= 8 then return "TRIALS", "Large group detected" end
    if self:HasAssistedQuest() then return "QUESTING", "An assisted quest is active" end
    if safeNumber(snapshot.level, 1) >= 50 then
        if role == "HEALER" or role == "TANK" then return "DUNGEONS", "Support role detected; group progression is a strong default" end
        return "DPS", "Endgame damage profile detected"
    end
    return "QUESTING", "Leveling profile detected"
end

function A:GetEffectiveFocus(snapshot)
    local configured = EPC.Endgame and EPC.Endgame:GetFocus() or "DPS"
    if configured ~= "AUTO" then return configured, "Manual focus" end
    return self:DetectContext(snapshot)
end

function A:GetNextBestMove(model)
    if not model then return nil end
    local snapshot = model.snapshot or {}
    local focus, why = self:GetEffectiveFocus(snapshot)
    local role = EPC.Role and EPC.Role:GetRole() or "DAMAGE"
    local activity = EPC.Activities and EPC.Activities:BuildView(snapshot) or nil
    local topActivity = activity and activity.rows and activity.rows[1] or nil
    local rec = model.recommendations and model.recommendations[1] or nil

    local move = {
        focus = focus,
        focusLabel = EPC.Endgame and EPC.Endgame:GetFocusLabel(focus) or focus,
        reason = why,
        value = "PROGRESSION",
        action = nil,
    }

    if focus == "GOLD" or focus == "XP_CP" or focus == "DUNGEONS" or focus == "TRIALS" or focus == "QUESTING" then
        if topActivity then
            move.title = topActivity.name
            move.reason = string.format("%s. It currently ranks highest for your %s goal and %s role.", why, lower(move.focusLabel), lower(snapshot.roleLabel or role))
            move.value = focus == "GOLD" and "GOLD" or (focus == "XP_CP" and "XP / CP" or "ACTIVITY")
            move.activityKey = topActivity.key
            move.questIndex = topActivity.questIndex
            move.canRoute = topActivity.kind == "QUEST" and topActivity.canActivate == true
            return move
        end
    end

    if EPC.UtilitySuite and EPC.saved and EPC.saved.utilityInventoryTracking ~= false and not (EPC.Combat and EPC.Combat.inCombat) then
        local ok, inv = pcall(EPC.UtilitySuite.ScanInventory, EPC.UtilitySuite, false)
        if ok and inv then
            if safeNumber(inv.backpackSize, 0) > 0 and safeNumber(inv.backpackFree, 99) <= 5 then
                move.title = string.format("Clear inventory space — only %d slot%s free", safeNumber(inv.backpackFree, 0), safeNumber(inv.backpackFree, 0) == 1 and "" or "s")
                move.reason = "Your backpack is nearly full. Clearing space now reduces the chance of interrupting the next dungeon, farm, or quest route. The coach only recommends cleanup; it never destroys or sells items."
                move.value = "INVENTORY"
                return move
            end
        end
        if focus == "GEAR" and EPC.UtilitySuite.BuildResearchSummary then
            local rok, research = pcall(EPC.UtilitySuite.BuildResearchSummary, EPC.UtilitySuite)
            if rok and research and not research.unavailable and safeNumber(research.maxActive, 0) > safeNumber(research.active, 0) then
                local iok, inv2 = pcall(EPC.UtilitySuite.ScanInventory, EPC.UtilitySuite, false)
                if iok and inv2 and safeNumber(inv2.researchCandidates, 0) > 0 then
                    move.title = "Use an open trait-research slot"
                    move.reason = string.format("You have %d researchable backpack item%s and unused research capacity. Research is time-gated, so starting a useful trait is high leverage for long-term gearing.", safeNumber(inv2.researchCandidates, 0), safeNumber(inv2.researchCandidates, 0) == 1 and "" or "s")
                    move.value = "RESEARCH"
                    return move
                end
            end
        end
    end

    local target = model.targetBuild
    if target and safeNumber(target.score, 100) < 90 and (focus == "GEAR" or focus == "DPS" or focus == "TRIALS" or focus == "DUNGEONS") then
        move.title = target.nextGap or "Close the next target-build gap"
        move.reason = string.format("%s. Your selected %s target is %d%% complete, so this is the clearest build gap to close next.", why, lower(target.profileLabel or "build"), safeNumber(target.score, 0))
        move.value = "TARGET BUILD"
        return move
    end

    if focus == "GEAR" and safeNumber(model.gearScore, 0) < 95 then
        move.title = rec and rec.category == "GEAR" and rec.title or "Close the biggest gear gap"
        move.reason = string.format("%s. Your current gear score is %d/100, so equipment is the highest-leverage improvement.", why, safeNumber(model.gearScore, 0))
        move.value = "GEAR"
        return move
    end

    if focus == "DPS" and EPC.Combat and EPC.Combat.GetPersonalBest then
        local best = EPC.Combat:GetPersonalBest("DAMAGE")
        local last = EPC.Combat:GetLastFight()
        if last and safeNumber(last.dps, 0) > 0 then
            move.title = "Beat your last combat sample"
            move.reason = string.format("Last DPS: %.0f. Personal best: %.0f. Use the COMBAT tab to identify the largest damage-source gap.", safeNumber(last.dps, 0), safeNumber(best, 0))
            move.value = "DPS"
            return move
        end
    end

    if rec then
        move.title = rec.title
        move.reason = rec.reason or why
        move.value = rec.category or "BUILD"
        return move
    end

    move.title = topActivity and topActivity.name or "Review your current build priorities"
    move.reason = why
    return move
end

function A:BuildSessionPlan(snapshot)
    snapshot = snapshot or EPC.lastSnapshot or {}
    local view = EPC.Activities and EPC.Activities:BuildView(snapshot) or nil
    local rows = view and view.rows or {}
    local plan = {}
    if #rows == 0 then return plan end

    if self:IsContinuous() then
        for i = 1, math.min(4, #rows) do
            plan[#plan + 1] = string.format("%d. %s", i, rows[i].name or "Activity")
        end
        return plan
    end

    local remaining = self:GetSessionRemainingMinutes()
    if remaining == nil then return self:BuildSessionPlan(snapshot) end
    local slots = remaining <= 30 and 2 or (remaining <= 60 and 3 or 4)
    local left = remaining
    for i = 1, math.min(slots, #rows) do
        local remainingSlots = math.min(slots, #rows) - i + 1
        local slice = math.floor(left / remainingSlots)
        slice = math.max(5, slice)
        plan[#plan + 1] = string.format("%dm  %s", slice, rows[i].name or "Activity")
        left = math.max(0, left - slice)
    end
    return plan
end

function A:GetCompactContext(snapshot)
    local focus = self:GetEffectiveFocus(snapshot)
    if EPC.Combat and EPC.Combat.inCombat then return "COMBAT" end
    if focus == "QUESTING" and self:HasAssistedQuest() then return "QUEST" end
    if focus == "GOLD" then return "GOLD" end
    if focus == "XP_CP" then return "XP" end
    return "GUIDE"
end
