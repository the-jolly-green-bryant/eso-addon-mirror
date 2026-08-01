-- FavorTracker.lua
-- Tracks daily Favor quest completions from Freerunner Post Boards.

-- Slash commands (type in chat): /favortracker show|hide|toggle|reset|lock|unlock

local FavorTracker = {}

local DAILY_RESET_HOUR_UTC = 10
local RESET_OFFSET_SECONDS = DAILY_RESET_HOUR_UTC * 3600

local DEFAULT_QUESTS = {
    { matchName = "Arabelle", npcName = "Lady Arabelle",       zone = "Glenumbra"  },
    { matchName = "Holgunn",  npcName = "Holgunn One-Eye",     zone = "Stonefalls" },
    { matchName = "Urcelmo",  npcName = "Battlereeve Urcelmo", zone = "Auridon"    },
}

local defaults = {
    quests = {},
    lastResetDay = nil,
    windowLeft   = nil,
    windowTop    = nil,
    isLocked    = true,
    isHidden    = false,
}

FavorTracker.activeIndices = {}
FavorTracker.questIdToEntry = {}
FavorTracker.uiReady = false

local function GetServerDay()
    return math.floor((GetTimeStamp() - RESET_OFFSET_SECONDS) / 86400)
end

local function CheckDailyReset()
    local sv = FavorTracker.sv
    local today = GetServerDay()

    if sv.lastResetDay ~= today then
        d(string.format("[FavorTracker] New day detected (day %d -> %d). Resetting checklist.",
            sv.lastResetDay or -1, today))
        for i = 1, #sv.quests do
            sv.quests[i].completed = false
        end
        sv.lastResetDay = today
        sv.isHidden = false
        return true
    end
    return false
end

local function AllQuestsComplete()
    local sv = FavorTracker.sv
    for i = 1, #sv.quests do
        if not sv.quests[i].completed then
            return false
        end
    end
    return true
end

local function ScanJournalForFavors()
    FavorTracker.activeIndices = {}
    local sv = FavorTracker.sv
    local numQuests = GetNumJournalQuests()

    for qi = 1, numQuests do
        if IsValidQuestIndex(qi) then
            local questType = GetJournalQuestType(qi)
            if questType == QUEST_TYPE_FAVOR then
                local questName = GetJournalQuestName(qi)
                local nameLower = string.lower(questName)
                for i = 1, #sv.quests do
                    local matchLower = string.lower(sv.quests[i].matchName)
                    if matchLower ~= "" and string.find(nameLower, matchLower, 1, true) then
                        FavorTracker.activeIndices[qi] = i
                        break
                    end
                end
            end
        end
    end
end

local function RefreshChecklist()
    if not FavorTracker.uiReady then return end

    local sv     = FavorTracker.sv
    local window = FavorTracker.window

    -- Update each quest row
    for i = 1, #sv.quests do
        local row = window:GetNamedChild("Row" .. i)
        if row then
            local mark  = sv.quests[i].completed and "X" or " "
            row:SetText(string.format("[%s]  %s (%s)", mark, sv.quests[i].npcName, sv.quests[i].zone))
            if sv.quests[i].completed then
                row:SetColor(0.4, 1.0, 0.4, 1)  -- green
            else
                row:SetColor(1.0, 1.0, 1.0, 1)  -- white
            end
        end
    end

    local lockIcon = window:GetNamedChild("LockIcon")
    if lockIcon then
        if sv.isLocked then
            lockIcon:SetColor(1.0, 1.0, 1.0, 1.0)   -- full bright
        else
            lockIcon:SetColor(0.35, 0.35, 0.35, 0.5) -- dimmed = unlocked
        end
    end

    local handle = window:GetNamedChild("Handle")
    if handle then
        handle:SetHidden(sv.isLocked)
    end
end

local function ToggleLock()
    local sv = FavorTracker.sv
    sv.isLocked = not sv.isLocked

    local window = FavorTracker.window
    window:SetMovable(not sv.isLocked)
    window:SetMouseEnabled(true)

    RefreshChecklist()
end

local function CreateUI()
    local sv     = FavorTracker.sv
    local window = WINDOW_MANAGER:CreateTopLevelWindow("FavorTrackerWindow")

    local left = sv.windowLeft or (GuiRoot:GetWidth()  - 280)
    local top  = sv.windowTop  or (GuiRoot:GetHeight() - 200)
    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)

    window:SetDimensions(260, 136)
    window:SetMouseEnabled(true)
    window:SetMovable(not sv.isLocked)
    window:SetClampedToScreen(true)
    window:SetDrawLayer(DL_BACKGROUND)
    window:SetDrawTier(DT_HIGH)
    window:SetHidden(false)

    local handle = WINDOW_MANAGER:CreateControl("$(parent)Handle", window, CT_TEXTURE)
    handle:SetAnchor(TOPLEFT,  window, TOPLEFT,  26, 0)
    handle:SetAnchor(TOPRIGHT, window, TOPRIGHT, -26, 0)
    handle:SetHeight(7)
    handle:SetColor(0.45, 0.45, 0.5, 0.55)
    handle:SetHidden(sv.isLocked)

    local closeBtn = WINDOW_MANAGER:CreateControl("$(parent)CloseBtn", window, CT_LABEL)
    closeBtn:SetAnchor(TOPRIGHT, window, TOPRIGHT, -5, 4)
    closeBtn:SetDimensions(20, 20)
    closeBtn:SetFont("ZoFontGame")
    closeBtn:SetText("X")
    closeBtn:SetColor(0.85, 0.45, 0.40, 1)
    closeBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    closeBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    closeBtn:SetMouseEnabled(true)
    closeBtn:SetDrawLayer(DL_OVERLAY)
    closeBtn:SetHandler("OnMouseUp", function()
        local sv = FavorTracker.sv
        sv.isHidden = true
        FavorTracker.window:SetHidden(true)
    end)

    local lockIcon = WINDOW_MANAGER:CreateControl("$(parent)LockIcon", window, CT_TEXTURE)
    lockIcon:SetAnchor(TOPLEFT, window, TOPLEFT, 5, 5)
    lockIcon:SetDimensions(16, 16)
    lockIcon:SetTexture("EsoUI/Art/Miscellaneous/status_locked.dds")
    lockIcon:SetDrawLayer(DL_OVERLAY)
    lockIcon:SetColor(1.0, 1.0, 1.0, 1.0)
    lockIcon:SetHidden(false)

    local lockBtn = WINDOW_MANAGER:CreateControl("$(parent)LockBtn", window, CT_BUTTON)
    lockBtn:SetAnchor(TOPLEFT, window, TOPLEFT, 3, 3)
    lockBtn:SetDimensions(22, 22)
    lockBtn:SetMouseEnabled(true)
    lockBtn:SetDrawLayer(DL_OVERLAY)
    lockBtn:SetHandler("OnMouseUp", ToggleLock)

    local title = WINDOW_MANAGER:CreateControl("$(parent)Title", window, CT_LABEL)
    title:SetAnchor(TOPLEFT, lockBtn, TOPRIGHT, 8, 1)
    title:SetFont("ZoFontGame")
    title:SetText("Daily Favors")
    title:SetColor(0.96, 0.87, 0.70, 1)  -- beige

    for i = 1, #sv.quests do
        local row = WINDOW_MANAGER:CreateControl("$(parent)Row" .. i, window, CT_LABEL)
        row:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 6, 8 + (i - 1) * 24)
        row:SetFont("ZoFontGame")
        row:SetColor(1.0, 1.0, 1.0, 1)
    end

    window:SetHandler("OnMoveStop", function()
        local left = window:GetLeft()
        local top  = window:GetTop()
        if type(left) == "number" and type(top) == "number" then
            window:ClearAnchors()
            window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
            sv.windowLeft = left
            sv.windowTop  = top
        end
    end)

    FavorTracker.window  = window
    FavorTracker.uiReady = true
end

local function OnQuestAdded(_, journalIndex, questName, _)
    local questType = GetJournalQuestType(journalIndex)
    if questType ~= QUEST_TYPE_FAVOR then return end

    local nameLower = string.lower(questName)
    local sv = FavorTracker.sv
    for i = 1, #sv.quests do
        local matchLower = string.lower(sv.quests[i].matchName)
        if matchLower ~= "" and string.find(nameLower, matchLower, 1, true) then
            FavorTracker.activeIndices[journalIndex] = i
            local qid = GetJournalQuestId(journalIndex)
            if qid and qid ~= 0 then
                FavorTracker.questIdToEntry[qid] = i
            end
            return
        end
    end
end

local function OnQuestRemoved(_, isCompleted, journalIndex, questName, _, _, questID)
    if not isCompleted then return end

    local sv = FavorTracker.sv

    local entryIdx = FavorTracker.questIdToEntry[questID]

    if not entryIdx and questName then
        local nameLower = string.lower(questName)
        for i = 1, #sv.quests do
            if not sv.quests[i].completed then
                local matchLower = string.lower(sv.quests[i].matchName)
                if matchLower ~= "" and string.find(nameLower, matchLower, 1, true) then
                    entryIdx = i
                    break
                end
            end
        end
    end

    if not entryIdx then
        entryIdx = FavorTracker.activeIndices[journalIndex]
    end

    if not entryIdx then return end

    for qi, ei in pairs(FavorTracker.activeIndices) do
        if ei == entryIdx then
            FavorTracker.activeIndices[qi] = nil
        end
    end
    FavorTracker.questIdToEntry[questID] = nil

    CheckDailyReset()

    if sv.quests[entryIdx].completed then return end

    sv.quests[entryIdx].completed = true
    RefreshChecklist()

    if AllQuestsComplete() then
        FavorTracker.window:SetHidden(true)
        d("All favors done for today.")
    end
end

local function SlashHandler(args)
    args = string.lower(args or "")
    local window = FavorTracker.window
    if not window then return end

    if args == "show" then
        window:SetHidden(false)
        FavorTracker.sv.isHidden = false
        d("[FavorTracker] Checklist shown")

    elseif args == "hide" then
        window:SetHidden(true)
        FavorTracker.sv.isHidden = true
        d("[FavorTracker] Checklist hidden")

    elseif args == "toggle" then
        local hidden = not window:IsHidden()
        window:SetHidden(hidden)
        FavorTracker.sv.isHidden = hidden
        d("[FavorTracker] Checklist " .. (hidden and "hidden" or "shown"))

    elseif args == "reset" then
        local sv = FavorTracker.sv
        for i = 1, #sv.quests do
            sv.quests[i].completed = false
        end
        sv.lastResetDay = nil
        window:SetHidden(false)
        sv.isHidden = false
        RefreshChecklist()
        d("[FavorTracker] Daily checklist reset")

    elseif args == "lock" then
        if not FavorTracker.sv.isLocked then
            ToggleLock()
        end
        d("[FavorTracker] Window locked in place")

    elseif args == "unlock" then
        if FavorTracker.sv.isLocked then
            ToggleLock()
        end
        d("[FavorTracker] Window unlocked — drag to reposition")

    else
        d("[FavorTracker] Usage: /favortracker show | hide | toggle | reset | lock | unlock")
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= "FavorTracker" then return end

    SLASH_COMMANDS["/favortracker"] = SlashHandler

    FavorTracker.sv = ZO_SavedVars:NewCharacterIdSettings(
        "FavorTracker_SavedVars",
        1,
        nil,
        defaults
    )

    local sv = FavorTracker.sv

    if not sv.quests or #sv.quests == 0 then
        sv.quests = {}
        for _, q in ipairs(DEFAULT_QUESTS) do
            table.insert(sv.quests, {
                matchName = q.matchName,
                npcName   = q.npcName,
                zone      = q.zone,
                completed = false,
            })
        end
    else
        for i = 1, #sv.quests do
            if sv.quests[i].completed == nil then
                sv.quests[i].completed = false
            end
            if sv.quests[i].matchName == nil then
                sv.quests[i].matchName = DEFAULT_QUESTS[i] and DEFAULT_QUESTS[i].matchName or ("Favor Quest " .. i)
            end
            if sv.quests[i].npcName == nil then
                sv.quests[i].npcName = DEFAULT_QUESTS[i] and DEFAULT_QUESTS[i].npcName or ("Board " .. i .. " NPC")
            end
            if sv.quests[i].zone == nil then
                sv.quests[i].zone = DEFAULT_QUESTS[i] and DEFAULT_QUESTS[i].zone or ""
            end
        end
    end

    if sv.windowLeft == nil then
        sv.windowLeft = GuiRoot:GetWidth()  - 280
    end
    if sv.windowTop == nil then
        sv.windowTop  = GuiRoot:GetHeight() - 200
    end

    if sv.isLocked == nil then
        sv.isLocked = true
    end
    if sv.isHidden == nil then
        sv.isHidden = false
    end

    local didReset = CheckDailyReset()

    CreateUI()
    RefreshChecklist()

    local win = FavorTracker.window
    win:RegisterForEvent(EVENT_QUEST_ADDED,   OnQuestAdded)
    win:RegisterForEvent(EVENT_QUEST_REMOVED, OnQuestRemoved)

    if AllQuestsComplete() and not didReset then
        win:SetHidden(true)
    elseif sv.isHidden then
        win:SetHidden(true)
    end

    ScanJournalForFavors()

    local hudFragment = ZO_HUDFadeSceneFragment:New(FavorTracker.window)
    SCENE_MANAGER:GetScene("hud"):AddFragment(hudFragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(hudFragment)

    local fragShow = hudFragment.Show
    hudFragment.Show = function(self, ...)
        local didReset = CheckDailyReset()
        if didReset then
            RefreshChecklist()
        end
        if FavorTracker.sv.isHidden or AllQuestsComplete() then
            return  -- manually hidden or all quests done
        end
        return fragShow(self, ...)
    end

    d("[FavorTracker] Loaded. Tracking " .. #sv.quests .. " daily favors.  /favortracker for help.")
end

EVENT_MANAGER:RegisterForEvent("FavorTracker_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
