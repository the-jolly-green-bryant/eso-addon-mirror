ESOXP = {}
ESOXP.name = "ESOXP"

ESOXP.savedVars = nil
ESOXP.lastPrintTime = 0

---------------------------------------------------------
-- Helpers
---------------------------------------------------------

local function FormatElapsedTime(seconds)
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    return string.format("%d:%02d", m, s)
end

local function GetCharacterKey()
    return GetCurrentCharacterId()
end

---------------------------------------------------------
-- Reset logic
---------------------------------------------------------

function ESOXP.InternalResetSession(silent)
    if not ESOXP.savedVars then return end
    local sv = ESOXP.savedVars

    sv.characterKey   = GetCharacterKey()

    -- Stopwatch
    sv.timerRunning   = false
    sv.startTime      = 0

    -- XP accumulation
    sv.totalXPGained  = 0
    sv.lastXPValue    = nil
    sv.lastXPMax      = nil

    -- Progress baseline
    sv.startLevel     = GetUnitLevel("player")
    sv.startCP        = GetPlayerChampionPointsEarned()

    ESOXP.lastPrintTime = 0

    EVENT_MANAGER:UnregisterForUpdate(ESOXP.name .. "_Timer")

    if not silent then
        ESOXP.UpdateUI()
    end
end

function ESOXP.ResetSession()
    ESOXP.InternalResetSession(false)
end

---------------------------------------------------------
-- SavedVars validation
---------------------------------------------------------

function ESOXP.FixSavedVars()
    if not ESOXP.savedVars then return end
    local sv = ESOXP.savedVars
    local key = GetCharacterKey()

    if sv.characterKey ~= key then
        ESOXP.InternalResetSession(true)
    end

    sv.characterKey  = key
    sv.timerRunning  = sv.timerRunning or false
    sv.startTime     = sv.startTime or 0
    sv.totalXPGained = sv.totalXPGained or 0
end

---------------------------------------------------------
-- Stopwatch (TIME ONLY)
---------------------------------------------------------

function ESOXP.StartStopwatch()
    local sv = ESOXP.savedVars
    if sv.timerRunning then return end

    sv.timerRunning = true
    sv.startTime = GetGameTimeSeconds()

    EVENT_MANAGER:RegisterForUpdate(
        ESOXP.name .. "_Timer",
        1000,
        ESOXP.UpdateTimerOnly
    )
end

function ESOXP.UpdateTimerOnly()
    ESOXP.UpdateUI()
end

function ESOXP.GetElapsed()
    local sv = ESOXP.savedVars
    if not sv.timerRunning then return 0 end
    return math.max(GetGameTimeSeconds() - (sv.startTime or 0), 0)
end

---------------------------------------------------------
-- XP EVENT (ONLY XP math lives here)
---------------------------------------------------------

function ESOXP.OnXPUpdate(_, unitTag, currentXP, maxXP)
    if unitTag ~= "player" then return end
    local sv = ESOXP.savedVars
    if not sv then return end

    -- Start stopwatch on first XP gain
    if not sv.timerRunning then
        ESOXP.StartStopwatch()
    end

    -- Seed XP baseline
    if sv.lastXPValue == nil then
        sv.lastXPValue = currentXP
        sv.lastXPMax   = maxXP
        ESOXP.UpdateUI()
        return
    end

    local delta = currentXP - sv.lastXPValue

    -- Handle CP / level rollover
    if delta < 0 and maxXP and sv.lastXPMax then
        delta = (sv.lastXPMax - sv.lastXPValue) + currentXP
    end

    if delta > 0 then
        sv.totalXPGained = sv.totalXPGained + delta
    end

    sv.lastXPValue = currentXP
    sv.lastXPMax   = maxXP

    ESOXP.UpdateUI()
end

---------------------------------------------------------
-- UI UPDATE (READ-ONLY)
---------------------------------------------------------

function ESOXP.UpdateUI()
    if not ESOXP.savedVars then return end
    local sv = ESOXP.savedVars

    local elapsed = ESOXP.GetElapsed()
    local gained  = sv.totalXPGained or 0
    local xpHr    = (elapsed > 0) and (gained / elapsed * 3600) or 0

    local xpLabel      = GetControl("ESOXP_XPGained")
    local perHourLabel = GetControl("ESOXP_XPPerHour")
    local timeLabel    = GetControl("ESOXP_TimeElapsed")
    local progressLbl  = GetControl("ESOXP_ProgressLabel")
    local iconProgress = GetControl("ESOXP_Icon_Progress")

    if xpLabel then xpLabel:SetText(string.format("%d", gained)) end
    if perHourLabel then perHourLabel:SetText(string.format("%.0f/hr", xpHr)) end
    if timeLabel then timeLabel:SetText(FormatElapsedTime(elapsed)) end

    -- Level / CP progress
    local isCP = IsUnitChampion("player")
    local current = isCP and GetPlayerChampionPointsEarned() or GetUnitLevel("player")
    local start   = isCP and sv.startCP or sv.startLevel
    local gainedLv = math.max(current - start, 0)

    if progressLbl then
        progressLbl:SetText(string.format("%d %s", gainedLv, isCP and "CP" or "Lv"))
    end

    if iconProgress then
        iconProgress:SetTexture(
            isCP and "/esoui/art/champion/champion_icon.dds"
                 or "/esoui/art/tutorial/tutorial_idexperience.dds"
        )
    end
end

---------------------------------------------------------
-- Init
---------------------------------------------------------

function ESOXP.OnPlayerActivated()
    ESOXP.FixSavedVars()

    -- Re-arm stopwatch after reload / zoning
    if ESOXP.savedVars.timerRunning then
        EVENT_MANAGER:RegisterForUpdate(
            ESOXP.name .. "_Timer",
            1000,
            ESOXP.UpdateTimerOnly
        )
    end

    EVENT_MANAGER:RegisterForEvent(ESOXP.name, EVENT_EXPERIENCE_UPDATE, ESOXP.OnXPUpdate)
    EVENT_MANAGER:AddFilterForEvent(
        ESOXP.name,
        EVENT_EXPERIENCE_UPDATE,
        REGISTER_FILTER_UNIT_TAG,
        "player"
    )

    ESOXP.UpdateUI()
end

function ESOXP.OnAddOnLoaded(_, addonName)
    if addonName ~= ESOXP.name then return end

    ESOXP.savedVars = ZO_SavedVars:New(
        "ESOXP_SavedVariables",
        1,
        nil,
        {
            characterKey  = GetCharacterKey(),
            timerRunning  = false,
            startTime     = 0,
            totalXPGained = 0,
            lastXPValue   = nil,
            lastXPMax     = nil,
            startLevel    = GetUnitLevel("player"),
            startCP       = GetPlayerChampionPointsEarned(),
        }
    )

    -- Hook reset button (IMPORTANT)
    local resetButton = GetControl("ESOXP_ResetButton")
    if resetButton and resetButton.SetHandler then
        resetButton:SetHandler("OnClicked", ESOXP.ResetSession)
    end

    EVENT_MANAGER:RegisterForEvent(ESOXP.name, EVENT_PLAYER_ACTIVATED, ESOXP.OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(ESOXP.name, EVENT_ADD_ON_LOADED, ESOXP.OnAddOnLoaded)
