--------------------------------------------------------------
-- VampireStageReminder_v2.lua — v2.0.1-test1 "Stage One Guard"
-- Author: SugaComa (Rik Sprint)
-- Console-safe, PS5 tested
--
-- New in v2.0:
--   • Muted startup if player is not a vampire
--   • Zone change / recheck no longer trigger click sounds
--   • Cleaner block headers for readability
--   • Retains original polling and adaptive reminders
--------------------------------------------------------------

VampireStageReminder_v2 = {}
VampireStageReminder_v2.name    = "VampireStageReminder_v2"
VampireStageReminder_v2.version = "2.0.1-test1"

--------------------------------------------------------------
-- Timing defaults
--------------------------------------------------------------
local REMINDER_WINDOW_SEC = 30 * 60
local REMINDER_PERIOD_MS  = 5 * 60 * 1000
local checkInterval       = 90 * 1000
local MESSAGE_DELAY       = 2000

--------------------------------------------------------------
-- Colours
--------------------------------------------------------------
local COLOR_MAGENTA = "|cFF00FF"
local COLOR_YELLOW  = "|cFFFF66"
local COLOR_END     = "|r"

--------------------------------------------------------------
-- State
--------------------------------------------------------------
local reminderToken   = 0
local lastMessageTime = 0
local SV_VERSION      = 2
local SV              = nil
local currentStage    = nil
local muted           = false  -- True when not a vampire

--------------------------------------------------------------
-- Helpers
--------------------------------------------------------------
local function CanonicalizeName(s)
    if not s or s == "" then return nil end
    s = tostring(s)
    s = s:gsub("[\226\128\153\226\128\156\226\128\157]", "'")
    s = s:gsub("[\226\128\147\226\128\148]", "-")
    s = s:gsub("%^.", "")
    s = s:gsub("[^%w%s'-]", "")
    s = s:gsub("%s+", " ")
    s = s:match("^%s*(.-)%s*$") or ""
    return zo_strlower(s)
end

local function fmt_hms(total)
    local s = math.max(0, math.floor(total or 0))
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local r = s % 60
    return h, m, r
end

local function Print(msg, soundId)
    if muted then return end
    local now   = GetFrameTimeSeconds() * 1000
    local delay = math.max(0, lastMessageTime + MESSAGE_DELAY - now)
    zo_callLater(function()
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, soundId or nil,
            "[VampireStageReminder_v2] " .. tostring(msg))
        lastMessageTime = GetFrameTimeSeconds() * 1000
    end, delay)
end

--------------------------------------------------------------
-- Buff definitions
--------------------------------------------------------------
local KNOWN_VAMPIRE_BUFFS = {
    ["vampirism stage 1"] = 1,
    ["vampirism stage 2"] = 2,
    ["vampirism stage 3"] = 3,
    ["vampirism stage 4"] = 4,
    ["vampirism stage 5"] = 5,
    ["vampirism"]         = 1,
}

local BUFF_NAME_ALIASES = {
    ["vampire stage 1"] = "vampirism stage 1",
    ["vampire stage 2"] = "vampirism stage 2",
    ["vampire stage 3"] = "vampirism stage 3",
    ["vampire stage 4"] = "vampirism stage 4",
    ["vampire stage 5"] = "vampirism stage 5",
    ["vampire"]         = "vampirism",
}

local function IsVampireBuff(buffName)
    local n = CanonicalizeName(buffName)
    if not n then return false, nil end
    if KNOWN_VAMPIRE_BUFFS[n] then
        return true, KNOWN_VAMPIRE_BUFFS[n]
    end
    local alias = BUFF_NAME_ALIASES[n]
    if alias and KNOWN_VAMPIRE_BUFFS[alias] then
        return true, KNOWN_VAMPIRE_BUFFS[alias]
    end
    return false, nil
end

--------------------------------------------------------------
-- Core query
--------------------------------------------------------------
local function QueryVampireStage()
    local now = GetFrameTimeSeconds()
    for i = 1, GetNumBuffs("player") do
        local name, _, finish = GetUnitBuffInfo("player", i)
        local isVampire, stage = IsVampireBuff(name)
        if isVampire then
            local remaining = math.max(0, (finish or 0) - now)
            return true, stage, remaining
        end
    end
    return false, nil, 0
end

--------------------------------------------------------------
-- Reminder loop
--------------------------------------------------------------
-- Forward declaration: StartReminders is defined before the scanner below.
-- Without this, a delayed reference resolves to a nil global in Lua.
local CheckVampireStage

local function StopReminders()
    reminderToken = reminderToken + 1
end

local function StartReminders()
    local myToken = reminderToken + 1
    reminderToken = myToken

    local function tick()
        if myToken ~= reminderToken then return end
        local isVampire, stage, remaining = QueryVampireStage()
        if not isVampire then
            muted = true
            StopReminders()
            currentStage = nil
            return
        end
        muted = false

        -- Stage 1 is the minimum vampire stage and has no decay timer.
        -- A zero/expired timer should never start a rapid recheck loop;
        -- EVENT_EFFECT_CHANGED and the normal 90-second poll catch transitions.
        if (stage or 1) <= 1 or remaining <= 0 then
            StopReminders()
            return
        end

        ----------------------------------------------------------
        -- Adaptive cadence (center screen on final stage)
        ----------------------------------------------------------
        local h, m, s = fmt_hms(remaining)
        local timerColor = COLOR_YELLOW
        local nextMs = REMINDER_PERIOD_MS
        local soundToPlay = nil

        local finalStageSec = (SV and (SV.finalStageMin or 3) or 3) * 60
        local intervalSec   = (SV and (SV.finalStageInterval or 15) or 15)

        -- Final Stage (1–5 min)
        if remaining <= finalStageSec and remaining > 180 then
            timerColor  = "|cFFA500"
            nextMs      = intervalSec * 1000
            if VampireStageReminder_v2.soundEnabled then
                soundToPlay = SOUNDS.ABILITY_ULTIMATE_READY
            end
            local msg = string.format(
                "%sStage %d%s — %s%02dh %02dm %02ds%s to next stage",
                COLOR_MAGENTA, stage or 1, COLOR_END,
                timerColor, h, m, s, COLOR_END
            )
            local CSA = CENTER_SCREEN_ANNOUNCE
            if CSA and CSA.CreateMessageParams then
                local p = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, soundToPlay)
                p:SetText(msg)
                CSA:DisplayMessage(p)
            else
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, soundToPlay, msg)
            end

        -- Panic Mode (≤3 min)
        elseif remaining <= 180 then
            timerColor = ((math.floor(remaining) % 2 == 0) and "|cFF0000" or "|cFFFFFF")
            nextMs     = 3000
            if VampireStageReminder_v2.soundEnabled then
                soundToPlay = SOUNDS.DUEL_START
            end
            local msg = string.format(
                "%sStage %d%s — %s%02dh %02dm %02ds%s to next stage",
                COLOR_MAGENTA, stage or 1, COLOR_END,
                timerColor, h, m, s, COLOR_END
            )
            local CSA = CENTER_SCREEN_ANNOUNCE
            if CSA and CSA.CreateMessageParams then
                local p = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, soundToPlay)
                p:SetText(msg)
                CSA:DisplayMessage(p)
            else
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, soundToPlay, msg)
            end

        -- Regular Window (≤30 min)
        elseif remaining <= REMINDER_WINDOW_SEC then
            timerColor  = COLOR_YELLOW
            nextMs      = 5 * 60 * 1000
            local msg = string.format(
                "%sStage %d%s — %s%02dh %02dm %02ds%s to next stage",
                COLOR_MAGENTA, stage or 1, COLOR_END,
                timerColor, h, m, s, COLOR_END
            )
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, soundToPlay, msg)
        end

        zo_callLater(tick, nextMs)
    end

    tick()
end

--------------------------------------------------------------
-- Periodic scan
--------------------------------------------------------------
CheckVampireStage = function()
    local isVampire, stage, remaining = QueryVampireStage()
    if not isVampire then
        muted = true
        StopReminders()
        currentStage = nil
        return
    end

    muted = false
    if stage and stage ~= currentStage then
        currentStage = stage
        if stage <= 1 or remaining <= 0 then
            Print(string.format(
                "Stage changed to %sStage 1%s — minimum vampire stage; no decay countdown.",
                COLOR_MAGENTA, COLOR_END))
        else
            local h, m, s = fmt_hms(remaining)
            local msg = string.format(
                "Stage changed to %sStage %d%s — %s%02dh %02dm %02ds%s to next stage",
                COLOR_MAGENTA, stage, COLOR_END,
                COLOR_YELLOW, h, m, s, COLOR_END)
            Print(msg)
        end
    end

    if stage and stage > 1 and remaining > 0 and remaining <= REMINDER_WINDOW_SEC then
        StartReminders()
    else
        StopReminders()
    end
end

--------------------------------------------------------------
-- Timer helpers
--------------------------------------------------------------
local function PausePolling()
    EVENT_MANAGER:UnregisterForUpdate("VampireStageReminder_v2_CheckBuff")
end

local function ResumePolling()
    EVENT_MANAGER:UnregisterForUpdate("VampireStageReminder_v2_CheckBuff")
    EVENT_MANAGER:RegisterForUpdate("VampireStageReminder_v2_CheckBuff", checkInterval, CheckVampireStage)
end

--------------------------------------------------------------
-- Events + Slash Commands
--------------------------------------------------------------
local function SenseCheckVampire()
    local isVampire, stage, remaining = QueryVampireStage()
    if not isVampire then
        muted = true
        StopReminders()
        currentStage = nil
        return
    end
    muted = false
    currentStage = stage

    if (stage or 1) <= 1 or remaining <= 0 then
        Print(string.format(
            "%sStage 1%s — minimum vampire stage; no decay countdown.",
            COLOR_MAGENTA, COLOR_END))
        StopReminders()
        return
    end

    local h, m, s = fmt_hms(remaining)
    local msg = string.format("%sStage %d%s — %s%02dh %02dm %02ds%s to next stage",
        COLOR_MAGENTA, stage, COLOR_END,
        COLOR_YELLOW, h, m, s, COLOR_END)
    Print(msg)
    if remaining <= REMINDER_WINDOW_SEC then StartReminders() else StopReminders() end
end

--------------------------------------------------------------
-- SavedVars + Sound Toggle
--------------------------------------------------------------
VampireStageReminder_v2.soundEnabled = true

local function InitializeSavedVars()
    local defaults = {
        soundEnabled = true,
        finalStageMin = 3,
        finalStageInterval = 15,
    }
    local ok, sv = pcall(function()
        return ZO_SavedVars:NewAccountWide("VampireStageReminder_v2_SV", SV_VERSION, nil, defaults)
    end)
    if not ok or type(sv) ~= "table" then
        sv = ZO_DeepTableCopy(defaults)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil,
            "[VampireStageReminder_v2] Failed to initialize SavedVariables; using defaults.")
    end
    SV = sv
    VampireStageReminder_v2.SV = SV
    VampireStageReminder_v2.soundEnabled       = SV.soundEnabled
    VampireStageReminder_v2.finalStageMin      = SV.finalStageMin
    VampireStageReminder_v2.finalStageInterval = SV.finalStageInterval
end

local function SaveState()
    if SV then
        SV.soundEnabled       = VampireStageReminder_v2.soundEnabled
        SV.finalStageMin      = VampireStageReminder_v2.finalStageMin or SV.finalStageMin
        SV.finalStageInterval = VampireStageReminder_v2.finalStageInterval or SV.finalStageInterval
    end
end

local function ToggleSound()
    VampireStageReminder_v2.soundEnabled = not VampireStageReminder_v2.soundEnabled
    if SV then SV.soundEnabled = VampireStageReminder_v2.soundEnabled end
    local status = VampireStageReminder_v2.soundEnabled and "|c00FF00ENABLED|r" or "|cFF0000DISABLED|r"
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "[VampireStageReminder_v2] Sound alerts " .. status)
end

--------------------------------------------------------------
-- Activation + Menu Hook
--------------------------------------------------------------
local function OnPlayerActivated()
    ResumePolling()
    EVENT_MANAGER:UnregisterForEvent(VampireStageReminder_v2.name, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:RegisterForEvent(VampireStageReminder_v2.name, EVENT_EFFECT_CHANGED,
        function(_, _, _, _, _, unitTag)
            if unitTag == "player" then CheckVampireStage() end
        end)
    CheckVampireStage()
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= VampireStageReminder_v2.name then return end
    EVENT_MANAGER:UnregisterForEvent(VampireStageReminder_v2.name, EVENT_ADD_ON_LOADED)
    InitializeSavedVars()

    EVENT_MANAGER:RegisterForEvent(VampireStageReminder_v2.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(VampireStageReminder_v2.name, EVENT_PLAYER_DEACTIVATED, SaveState)
    EVENT_MANAGER:RegisterForEvent(VampireStageReminder_v2.name, EVENT_PLAYER_LOGOUT, SaveState)

    SLASH_COMMANDS["/vampcheck"]     = SenseCheckVampire
    SLASH_COMMANDS["/vampmute"] = ToggleSound

    local function TryAttachVSRMenu_v2()
        if VSRMenu_v2 and VSRMenu_v2.Setup then
            zo_callLater(function() VSRMenu_v2.Setup(VampireStageReminder_v2) end, 6000)
        else
            zo_callLater(TryAttachVSRMenu_v2, 4000)
        end
    end
    zo_callLater(TryAttachVSRMenu_v2, 5000)

    Print("VampireStageReminder_v2 v" .. VampireStageReminder_v2.version .. " loaded.")
end

EVENT_MANAGER:RegisterForEvent(VampireStageReminder_v2.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)