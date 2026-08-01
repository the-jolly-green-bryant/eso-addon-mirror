-- Battleboard_Debug.lua  (temporary debug panel)
-- Part of Battleboard. Kept isolated so it can be removed cleanly before launch.

local BL = Battleboard
local _x = BL.__constants

local Num = _x.Num
local CreateLabel = _x.CreateLabel
local CreateSoftFill = _x.CreateSoftFill

local function FormatDebugDuration(seconds)
    seconds = math.floor(Num(seconds) + 0.5)
    if seconds <= 0 then return "0m 00s" end

    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if hours > 0 then
        return string.format("%dh %02dm %02ds", hours, minutes, secs)
    end
    return string.format("%dm %02ds", minutes, secs)
end

local function DebugStatusText(status)
    if status == "PAUSED" then
        return "|cFF4444PAUSED|r"
    end
    return status
end

local function SetDebugLine(label, prefix, seconds, state)
    if not label then return end

    if state == "INACTIVE" then
        label:SetColor(0.28, 0.28, 0.28, 1)
        label:SetText(prefix .. ": " .. FormatDebugDuration(seconds))
    elseif state == "PAUSED" then
        label:SetColor(1, 1, 1, 1)
        label:SetText(prefix .. ": " .. FormatDebugDuration(seconds) .. " (" .. DebugStatusText("PAUSED") .. ")")
    else
        label:SetColor(1, 1, 1, 1)
        label:SetText(prefix .. ": " .. FormatDebugDuration(seconds))
    end
end

function BL.BuildDebugPanel()
    if BL.debugPanel or not GuiRoot then return end

    local panel = WINDOW_MANAGER:CreateTopLevelWindow("BattleboardDebugPanel")
    panel:SetDimensions(250, 152)
    panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 18, 18)
    panel:SetDrawLayer(DL_OVERLAY)
    panel:SetDrawTier(DT_HIGH)
    panel:SetDrawLevel(2)
    panel:SetHidden(true)
    panel:SetMouseEnabled(false)
    panel:SetClampedToScreen(true)
    BL.debugPanel = panel

    local bg = CreateSoftFill(panel, "BattleboardDebugPanelBg", 0.018, 0.016, 0.013, 0.84)
    bg:SetAnchorFill(panel)
    BL.debugPanelBg = bg

    BL.debugPanelTitle = CreateLabel(panel, "BattleboardDebugPanelTitle", "BATTLEBOARD DEBUG", "ZoFontGameBold", {0.92, 0.84, 0.62, 1})
    BL.debugPanelTitle:SetAnchor(TOPLEFT, panel, TOPLEFT, 10, 8)
    BL.debugPanelTitle:SetDimensions(218, 18)

    BL.debugPanelMatch = CreateLabel(panel, "BattleboardDebugPanelMatch", "Match: --", "ZoFontGameSmall", {0.84, 0.80, 0.70, 1})
    BL.debugPanelMatch:SetAnchor(TOPLEFT, panel, TOPLEFT, 10, 30)
    BL.debugPanelMatch:SetDimensions(218, 16)

    BL.debugPanelCombat = CreateLabel(panel, "BattleboardDebugPanelCombat", "Combat: --", "ZoFontGameSmall", {0.84, 0.80, 0.70, 1})
    BL.debugPanelCombat:SetAnchor(TOPLEFT, panel, TOPLEFT, 10, 48)
    BL.debugPanelCombat:SetDimensions(218, 16)

    BL.debugPanelDead = CreateLabel(panel, "BattleboardDebugPanelDead", "Dead: --", "ZoFontGameSmall", {0.84, 0.80, 0.70, 1})
    BL.debugPanelDead:SetAnchor(TOPLEFT, panel, TOPLEFT, 10, 66)
    BL.debugPanelDead:SetDimensions(218, 16)

    BL.debugPanelQueue = CreateLabel(panel, "BattleboardDebugPanelQueue", "Queue: --", "ZoFontGameSmall", {0.84, 0.80, 0.70, 1})
    BL.debugPanelQueue:SetAnchor(TOPLEFT, panel, TOPLEFT, 10, 84)
    BL.debugPanelQueue:SetDimensions(218, 16)

    BL.debugPanelQueueCache = CreateLabel(panel, "BattleboardDebugPanelQueueCache", "Queue cache: --", "ZoFontGameSmall", {0.84, 0.80, 0.70, 1})
    BL.debugPanelQueueCache:SetAnchor(TOPLEFT, panel, TOPLEFT, 10, 102)
    BL.debugPanelQueueCache:SetDimensions(218, 16)

    BL.debugPanelDeserter = CreateLabel(panel, "BattleboardDebugPanelDeserter", "Deserter cache: --", "ZoFontGameSmall", {0.84, 0.80, 0.70, 1})
    BL.debugPanelDeserter:SetAnchor(TOPLEFT, panel, TOPLEFT, 10, 120)
    BL.debugPanelDeserter:SetDimensions(218, 16)
end

function BL.UpdateDebugPanel()
    local enabled = BL.vars and BL.vars.debugPanel == true
    if not enabled then
        if BL.debugPanel then
            BL.debugPanel:SetHidden(true)
            BL.debugPanel:SetHandler("OnUpdate", nil)
            BL.debugPanelUpdating = false
        end
        return
    end

    BL.BuildDebugPanel()
    if not BL.debugPanel then return end

    local now = GetTimeStamp()
    BL.ExpireQueueCacheIfNeeded(now)

    local hasMatchTimer = BL.currentBattlegroundEnteredAt ~= nil
    local matchSeconds = 0
    if hasMatchTimer then
        if BL.currentBattlegroundTimersFrozen then
            matchSeconds = Num(BL.currentBattlegroundFrozenDurationSeconds)
        else
            matchSeconds = math.max(0, Num(now) - Num(BL.currentBattlegroundEnteredAt))
        end
    end
    local combatSeconds = hasMatchTimer and BL.GetCurrentBattlegroundCombatSeconds(now) or 0
    local deadSeconds = hasMatchTimer and BL.GetCurrentBattlegroundDeadSeconds(now) or 0
    local queueSeconds = 0
    local queueStatus = "INACTIVE"
    if BL.queueSessionIsBattleground or BL.currentQueueStartedAt then
        queueSeconds = BL.GetLFGQueueElapsedSeconds()
        queueStatus = "RUNNING"
    end

    local queueCacheSeconds = 0
    local queueCacheStatus = "INACTIVE"
    if BL.queueCacheSeconds then
        queueCacheSeconds = Num(BL.queueCacheSeconds)
        queueCacheStatus = "PAUSED"
    end

    local matchStatus = hasMatchTimer and (BL.currentBattlegroundTimersFrozen and "PAUSED" or "RUNNING") or "INACTIVE"
    local combatStatus = hasMatchTimer and (BL.currentBattlegroundCombatStartedAt and "RUNNING" or "PAUSED") or "INACTIVE"
    local deadStatus = hasMatchTimer and (BL.currentBattlegroundDeathStartedAt and "RUNNING" or "PAUSED") or "INACTIVE"

    SetDebugLine(BL.debugPanelMatch, "Match", matchSeconds, matchStatus)
    SetDebugLine(BL.debugPanelCombat, "Combat", combatSeconds, combatStatus)
    SetDebugLine(BL.debugPanelDead, "Dead", deadSeconds, deadStatus)
    SetDebugLine(BL.debugPanelQueue, "Queue", queueSeconds, queueStatus)
    local deserterCacheSeconds = Num(BL.deserterTimerCacheSeconds)
    local deserterStatus = deserterCacheSeconds > 0 and "ACTIVE" or "INACTIVE"

    SetDebugLine(BL.debugPanelQueueCache, "Queue cache", queueCacheSeconds, queueCacheStatus)
    SetDebugLine(BL.debugPanelDeserter, "Deserter cache", deserterCacheSeconds, deserterStatus)
    BL.debugPanel:SetHidden(false)

    if not BL.debugPanelUpdating then
        BL.debugPanelUpdating = true
        BL.debugPanel:SetHandler("OnUpdate", function()
            BL.UpdateDebugPanel()
        end)
    end
end
