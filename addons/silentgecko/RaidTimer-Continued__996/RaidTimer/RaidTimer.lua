-----Declaring namespace and some variables along with tables-----
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
local LMP = LibStub:GetLibrary("LibMediaProvider-1.0")
RaidTimer = {}

RaidTimer.name		= 'RaidTimer'
RaidTimer.slash		= '/rt'
RaidTimer.version	= '1.4.0'
RaidTimer.versionDB	= 1
RaidTimer.loaded	= false
RaidTimer.author    = 'Noshiz, Garkin & silentgecko'

RaidTimer.tempVars = {
    stop = false,
    complete = false,
    showTimers = false,
    instance = false,
}

RaidTimer.variables = {
    TotalOffsetX = 45,
    TotalOffsetY = 30,
    ScoreOffsetX = 45,
    ScoreOffsetY = 60,
    VitalityOffsetX = 45,
    VitalityOffsetY = 60,
    FontFace = "Univers 67",
    FontSize = 16,
    FontStyle = "soft-shadow-thin",
    TotalFonts = "ZoFontHeader",
    ScoreFonts = "ZoFontHeader",
    VitalityFonts = "ZoFontHeader",
    TotalColor = { ZO_NORMAL_TEXT:UnpackRGBA() },
    ScoreColor = { ZO_NORMAL_TEXT:UnpackRGBA() },
    VitalityColor = { ZO_NORMAL_TEXT:UnpackRGBA() },
    Movable = true,
    hardMode = false,
    hardModePoints = 40000,       -- Hardmode Bonus Points for AA, HR and SO
    maSpeedBonusPoints = 15000,   -- Speed Bonus Points when under 90 mins
    topScores = {
        [1] = {
            time = 0,
            score = 0,
        },
        [2] = {
            time = 0,
            score = 0,
        },
        [3] = {
            time = 0,
            score = 0,
        },
        [4] = {
            time = 0,
            score = 0,
        },
        [5] = {
            time = 0,
            score = 0,
        },
        [6] = {
            time = 0,
            score = 0,
        },
    },
}

RaidTimer.timeLimits = {
    [0] = 0,    --none
    [1] = 720,  --Hel Ra Citadel (12 minutes)
    [2] = 720,  --Aetherian Archive (12 minutes)
    [3] = 1500, --Sanctum Ophidia (25 minutes)
    [4] = 3900, --Dragonstar Arena (Veteran) (65 minutes)
    [5] = 1500, --Maw of Lorkahj -- todo
    [6] = 5400, --Maelstrom Arena (Veteran) (4 hours 16 min 40 sek)
}

RaidTimer.raidPoints = {
    [0] = 0,     --none
    [1] = 69300, --Hel Ra Citadel
    [2] = 63000, --Aetherian Archive
    [3] = 100750,--Sanctum Ophidia (117.750 with troll archievement)
    [4] = 20000, --Dragonstar Arena (Veteran)
    [5] = 100000, --Maw of Lorkahj -- todo
    [6] = 396000, --Maelstrom Arena (Veteran)
}


local function CreateSettingsMenu()
    local self = RaidTimer
    ------Creating the menu with LibAddonMenu-2.0 (thank you Seerah)------- 
    self.panelData = {
        type = "panel",
        name = self.name,
        author = self.author,
        version = self.version,
        registerForRefresh = false,
    }

    self.optionsData = {
        {
            type = "description",
            text = GetString(RAIDTIMER_DESCRIPTION),
        },
        {
            type = "checkbox",
            name = GetString(RAIDTIMER_SHOW_TIMERS_OUTSIDE),
            tooltip = GetString(RAIDTIMER_SHOW_TIMERS_OUTSIDE_TOOLTIP),
            getFunc = function() return RaidTimer.tempVars.showTimers end,
            setFunc = function(value)
                RaidTimer.tempVars.showTimers = value
                RaidTimer.Total_Timer:SetHidden(RaidTimer.tempVars.instance and not value)
                RaidTimer.Raid_Score:SetHidden(RaidTimer.tempVars.instance and not value)
            end,
        },
        {
            type = "checkbox",
            name = GetString(RAIDTIMER_UNLOCK_TIMERS),
            tooltip = GetString(RAIDTIMER_UNLOCK_TIMERS_TOOLTIP),
            getFunc = function() return RaidTimer.savedVariables.Movable end,
            setFunc = function(value) 
                    RaidTimer.Total_Timer:SetMovable(value)
                    RaidTimer.Raid_Score:SetMovable(value)
                    RaidTimer.savedVariables.Movable = value
                end,
        },
        {
            type = "checkbox",
            name = GetString(RAIDTIMER_HARDMODE),
            tooltip = GetString(RAIDTIMER_HARDMODE_TOOLTIP),
            getFunc = function() return RaidTimer.savedVariables.hardMode end,
            setFunc = function(value)
                RaidTimer.savedVariables.hardMode = value
            end,
        },
        {
            type = "colorpicker",
            name = GetString(RAIDTIMER_TOTAL_TIME_COLOR),
            tooltip = GetString(RAIDTIMER_TOTAL_TIME_COLOR_TOOLTIP),
            getFunc = function() return unpack(RaidTimer.savedVariables.TotalColor) end,
            setFunc = function(r,g,b,a)
                    RaidTimer.Total_Timer:SetColor(r, g, b, a)
                    RaidTimer.savedVariables.TotalColor = {r,g,b,a}
                end,
        },
        {
            type = "colorpicker",
            name = GetString(RAIDTIMER_RAID_SCORE_COLOR),
            tooltip = GetString(RAIDTIMER_RAID_SCORE_COLOR_TOOLTIP),
            getFunc = function() return unpack(RaidTimer.savedVariables.ScoreColor) end,
            setFunc = function(r,g,b,a)
                    RaidTimer.Raid_Score:SetColor(r, g, b, a)
                    RaidTimer.savedVariables.ScoreColor = {r,g,b,a}
                end,
        },
        {
            type = "colorpicker",
            name = GetString(RAIDTIMER_VITALITY_BONUS_COLOR),
            tooltip = GetString(RAIDTIMER_VITALITY_BONUS_COLOR_TOOLTIP),
            getFunc = function() return unpack(RaidTimer.savedVariables.VitalityColor) end,
            setFunc = function(r,g,b,a)
                RaidTimer.Vitality_Bonus:SetColor(r, g, b, a)
                RaidTimer.savedVariables.VitalityColor = {r,g,b,a}
            end,
        },
        {
            type = "dropdown",
            name = GetString(RAIDTIMER_FONTS),
            tooltip = GetString(RAIDTIMER_FONTS_TOOLTIP),
            choices = LMP:List("font"),
            getFunc = function() return RaidTimer.savedVariables.FontFace end,
            setFunc = function(choice) RaidTimer.savedVariables.FontFace = choice end,
        },
        {
            type = "slider",
            name = GetString(RAIDTIMER_FONT_SIZE),
            tooltip = GetString(RAIDTIMER_FONT_SIZE_TOOLTIP),
            min = 16,
            max = 40,
            getFunc = function() return RaidTimer.savedVariables.FontSize end,
            setFunc = function(size) RaidTimer.savedVariables.FontSize = size end,
             
        },
        {
            type = "dropdown",
            name = GetString(RAIDTIMER_FONT_STYLE),
            tooltip = GetString(RAIDTIMER_FONT_STYLE_TOOLTIP),
            choices = {"none", "soft-shadow-thin", "soft-shadow-thick", "shadow"},
            getFunc = function() return RaidTimer.savedVariables.FontStyle end,
            setFunc = function(choice) RaidTimer.savedVariables.FontStyle = choice end,
             
        },
        {
            type = "checkbox",
            name = GetString(RAIDTIMER_DEBUG),
            tooltip = GetString(RAIDTIMER_DEBUG_TOOLTIP),
            getFunc = function() return RaidTimer.savedVariables.debug end,
            setFunc = function(value) 
                    RaidTimer.savedVariables.debug = value
                end,
        },
        {
            type = "button",
            name = GetString(RAIDTIMER_APPLY),
            tooltip = GetString(RAIDTIMER_APPLY_TOOLTIP),
            func = function() 
                    local formatstring = "%s|%d"
                    if RaidTimer.savedVariables.FontStyle ~= "none" then
                        formatstring = formatstring .. "|%s"
                    end
                    RaidTimer.finalFont = (formatstring):format(LMP:Fetch("font", RaidTimer.savedVariables.FontFace), RaidTimer.savedVariables.FontSize, RaidTimer.savedVariables.FontStyle)
                    RaidTimer.Total_Timer:SetFont(RaidTimer.finalFont)
                    RaidTimer.Raid_Score:SetFont(RaidTimer.finalFont)
                    if (GetAPIVersion() == 100014) then
                        RaidTimer.Vitality_Bonus:SetFont(RaidTimer.finalFont)
                    end
                    RaidTimer.savedVariables.TotalFonts = RaidTimer.finalFont
                    RaidTimer.savedVariables.ScoreFonts = RaidTimer.finalFont
                    RaidTimer.savedVariables.VitalityFonts = RaidTimer.finalFont
                end,
        },
    }

    LAM:RegisterAddonPanel("RaidTimerPanel", self.panelData)
    LAM:RegisterOptionControls("RaidTimerPanel", self.optionsData)
end


---------Passing saved variables to the labels at initialize-------     
function RaidTimer.Initialize(event, addonName)
    local self = RaidTimer

    if addonName ~= self.name then return end

    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    SLASH_COMMANDS[self.slash] = self.Commands

    self.savedVariables = ZO_SavedVars:NewAccountWide("RTVars", self.versionDB, nil, self.variables)

    self.pointReasons = {
        [RAID_POINT_REASON_KILL_NOXP_MONSTER]     = GetString(RAIDTIMER_KILL_NOXP_MONSTER),     -- 0
        [RAID_POINT_REASON_KILL_NORMAL_MONSTER]   = GetString(RAIDTIMER_KILL_NORMAL_MONSTER),   -- 1
        [RAID_POINT_REASON_KILL_BANNERMEN]        = GetString(RAIDTIMER_KILL_BANNERMEN),        -- 2
        [RAID_POINT_REASON_KILL_CHAMPION]         = GetString(RAIDTIMER_KILL_CHAMPION),         -- 3
        [RAID_POINT_REASON_KILL_MINIBOSS]         = GetString(RAIDTIMER_KILL_MINIBOSS),         -- 4
        [RAID_POINT_REASON_KILL_BOSS]             = GetString(RAIDTIMER_KILL_BOSS),             -- 5
        [RAID_POINT_REASON_BONUS_ACTIVITY_LOW]    = GetString(RAIDTIMER_BONUS_ACTIVITY_LOW),    -- 6
        [RAID_POINT_REASON_BONUS_ACTIVITY_MEDIUM] = GetString(RAIDTIMER_BONUS_ACTIVITY_MEDIUM), -- 7
        [RAID_POINT_REASON_BONUS_ACTIVITY_HIGH]   = GetString(RAIDTIMER_BONUS_ACTIVITY_HIGH),   -- 8
        [RAID_POINT_REASON_LIFE_REMAINING]        = GetString(RAIDTIMER_LIFE_REMAINING),        -- 9
        [RAID_POINT_REASON_BONUS_POINT_ONE]       = GetString(RAIDTIMER_BONUS_POINT_ONE),       -- 10
        [RAID_POINT_REASON_BONUS_POINT_TWO]       = GetString(RAIDTIMER_BONUS_POINT_THREE),     -- 11
        [RAID_POINT_REASON_BONUS_POINT_THREE]     = GetString(RAIDTIMER_BONUS_POINT_THREE),     -- 12
        [RAID_POINT_REASON_SOLO_ARENA_PICKUP_ONE]   = GetString(RAIDTIMER_SYGILLS_USED_THREE),  -- 13
        [RAID_POINT_REASON_SOLO_ARENA_PICKUP_TWO]   = GetString(RAIDTIMER_SYGILLS_USED_TWO),    -- 14
        [RAID_POINT_REASON_SOLO_ARENA_PICKUP_THREE] = GetString(RAIDTIMER_SYGILLS_USED_ONE),    -- 15
        [RAID_POINT_REASON_SOLO_ARENA_PICKUP_FOUR]  = GetString(RAIDTIMER_SYGILLS_USED_NONE),   -- 16
        [RAID_POINT_REASON_SOLO_ARENA_COMPLETE]     = GetString(RAIDTIMER_ARENA_COMPLETE),      -- 17
    }

    -------Creating the two labels---------
    self.Root_Window = WINDOW_MANAGER:CreateTopLevelWindow(nil)

    self.Total_Timer = WINDOW_MANAGER:CreateControl(nil, self.Root_Window, CT_LABEL)
    self.Total_Timer:SetText(GetString(RAIDTIMER_TOTAL_TIME_TEMPLATE))
    self.Total_Timer:SetMouseEnabled(true)
    self.Total_Timer:SetHidden(true)
    self.Total_Timer:SetAnchor(TOPLEFT, self.Root_Window, TOPLEFT, self.savedVariables.TotalOffsetX, self.savedVariables.TotalOffsetY)
    self.Total_Timer:SetFont(self.savedVariables.TotalFonts)
    self.Total_Timer:SetMovable(self.savedVariables.Movable)
    self.Total_Timer:SetClampedToScreen(true)
    self.Total_Timer:SetColor(unpack(self.savedVariables.TotalColor))
    self.Total_Timer:SetHandler("OnMoveStop", self.SaveLoc)

    self.Raid_Score = WINDOW_MANAGER:CreateControl(nil, self.Root_Window, CT_LABEL)
    self.Raid_Score:SetText(GetString(RAIDTIMER_RAID_SCORE_TEMPLATE))
    self.Raid_Score:SetMouseEnabled(true)
    self.Raid_Score:SetHidden(true)
    self.Raid_Score:SetAnchor(TOPLEFT, self.Root_Window, TOPLEFT, self.savedVariables.ScoreOffsetX, self.savedVariables.ScoreOffsetY)
    self.Raid_Score:SetFont(self.savedVariables.ScoreFonts)
    self.Raid_Score:SetMovable(self.savedVariables.Movable)
    self.Raid_Score:SetClampedToScreen(true)
    self.Raid_Score:SetColor(unpack(self.savedVariables.ScoreColor))
    self.Raid_Score:SetHandler("OnMoveStop", self.SaveLoc)

    if GetAPIVersion() == 100014 then
        self.Vitality_Bonus = WINDOW_MANAGER:CreateControl(nil, self.Root_Window, CT_LABEL)
        self.Vitality_Bonus:SetText(GetString(RAIDTIMER_VITALITY_BONUS_TEMPLATE))
        self.Vitality_Bonus:SetMouseEnabled(true)
        self.Vitality_Bonus:SetHidden(true)
        self.Vitality_Bonus:SetAnchor(TOPLEFT, self.Root_Window, TOPLEFT, self.savedVariables.VitalityOffsetX, self.savedVariables.VitalityOffsetY)
        self.Vitality_Bonus:SetFont(self.savedVariables.VitalityFonts)
        self.Vitality_Bonus:SetMovable(self.savedVariables.Movable)
        self.Vitality_Bonus:SetClampedToScreen(true)
        self.Vitality_Bonus:SetColor(unpack(self.savedVariables.VitalityColor))
        self.Vitality_Bonus:SetHandler("OnMoveStop", self.SaveLoc)
    end

    local RaidTimerSceneFragment = ZO_HUDFadeSceneFragment:New(self.Root_Window)
    HUD_SCENE:AddFragment(RaidTimerSceneFragment)
    HUD_UI_SCENE:AddFragment(RaidTimerSceneFragment)

    CreateSettingsMenu()

    if IsRaidInProgress() then
        self.TimerStart()
    else
        self.savedVariables.raidStart = nil
    end
end


---------The function that does all the calculation magic--------
function RaidTimer.TimerUpdate()
    local self = RaidTimer

    if self.tempVars.stop == true then
        EVENT_MANAGER:UnregisterForUpdate("RAID_TIMER_UPDATE")
        return
    end

    local currentTime = GetTimeStamp()
    local raidDuration = GetDiffBetweenTimeStamps(currentTime, self.raidStart)

    -- new on thieves guild
    if (GetAPIVersion() == 100014) then
        raidDuration = GetRaidDuration() / 1000 -- raidduration in MS
    end

    local formatedTime = ZO_FormatTime(raidDuration, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)
    self.Total_Timer:SetText(zo_strformat(GetString(RAIDTIMER_TOTAL_TIME), formatedTime))

    if self.score > 0 then
        self.raidId = self.raidId or GetCurrentParticipatingRaidId()
        local timeLimit = self.timeLimits[self.raidId] or 0
        local maxPoints = self.raidPoints[self.raidId] or 0
        if timeLimit > 0 and maxPoints > 0 then

            -- hardmode only on the raids
            local currentPoints = self.score
            if ((self.raidId > 0 and self.raidId <= 3) or self.raidId == 5) and self.savedVariables.hardMode then
                maxPoints = maxPoints + self.variables.hardModePoints
                currentPoints = self.score + self.variables.hardModePoints
            end

            -- add the bonus points for MA Veteran
            if self.raidId == 6 and raidDuration < timeLimit then
                maxPoints = maxPoints + self.variables.maSpeedBonusPoints
                currentPoints = self.score + self.variables.maSpeedBonusPoints
            end

            -- atm the vMA score has a bug, so we sub this points, like ZOS does
            if self.raidId == 6 then
                currentPoints = currentPoints - 15000
            end

            local estimatedScore = 0
            estimatedScore = self.EstimatedScore(currentPoints, maxPoints, timeLimit, raidDuration)

            local currentBestScore = self.savedVariables.topScores[self.raidId].score or 0
            local currentBestTime  = self.savedVariables.topScores[self.raidId].time or 0

            if estimatedScore > currentBestScore then
                self.Raid_Score:SetText(zo_strformat(GetString(RAIDTIMER_RAID_SCORE_WITH_NEW_TOPSCORE), ZO_CommaDelimitNumber(currentPoints), ZO_CommaDelimitNumber(estimatedScore)))
            else
                self.Raid_Score:SetText(zo_strformat(GetString(RAIDTIMER_RAID_SCORE_WITH_ESTIMATION), ZO_CommaDelimitNumber(currentPoints), ZO_CommaDelimitNumber(estimatedScore)))
            end
        end
    end
end

function RaidTimer.ScoreUpdate(event, scoreType, scoreAmount, totalScore)
    local self = RaidTimer

    self.score = self.score or GetCurrentRaidScore()
    if totalScore > self.score then
        self.raidId = self.raidId or GetCurrentParticipatingRaidId()
        local currentTime  = GetTimeStamp()
        local raidDuration = GetDiffBetweenTimeStamps(currentTime, self.raidStart)

        -- new on thieves guild
        if (GetAPIVersion() == 100014) then
            raidDuration = GetRaidDuration() / 1000 -- raidduration in MS
        end

        local timeLimit    = self.timeLimits[self.raidId] or 0
        local maxPoints    = self.raidPoints[self.raidId] or 0

        -- hardmode only on the raids
        local currentPoints = totalScore
        if ((self.raidId > 0 and self.raidId <= 3) or self.raidId == 5) and self.savedVariables.hardMode then
            maxPoints = maxPoints + self.variables.hardModePoints
            currentPoints = totalScore + self.variables.hardModePoints
        end

        -- add the bonus points for MA Veteran
        if self.raidId == 6 and raidDuration < timeLimit then
            maxPoints = maxPoints + self.variables.maSpeedBonusPoints
            currentPoints = self.score + self.variables.maSpeedBonusPoints
        end

        -- atm the vMA score has a bug, so we sub this points, like ZOS does
        if self.raidId == 6 then
            currentPoints = currentPoints - 15000
        end

        if timeLimit > 0 and maxPoints > 0 then
            local estimatedScore = 0
            estimatedScore = self.EstimatedScore(currentPoints, maxPoints, timeLimit, raidDuration)

            local currentBestScore = self.savedVariables.topScores[self.raidId].score or 0
            local currentBestTime  = self.savedVariables.topScores[self.raidId].time or 0
            -- if estimatedScore > currentBestScore then
            --    d(zo_strformat(GetString(RAIDTIMER_POSSIBLE_NEW_TOPSCORE_DEBUG), ZO_CommaDelimitNumber(currentBestScore), ZO_FormatTimeMilliseconds(currentBestTime, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)))
            -- end

        else
            self.Raid_Score:SetText(zo_strformat(GetString(RAIDTIMER_RAID_SCORE_WITHOUT_ESTIMATION), ZO_CommaDelimitNumber(currentPoints)))
        end
        self.score = totalScore
    end
    if self.savedVariables.debug and scoreType ~= nil and scoreAmount ~= nil then
        d(zo_strformat(GetString(RAIDTIMER_DEBUG_MESSAGE), scoreAmount, totalScore, self.pointReasons[scoreType]))
    end
end

function RaidTimer.ReviveUpdate(event, lifesRemaining)
    local self = RaidTimer

    if GetAPIVersion() == 100014 then
        local currentVitality = GetRaidReviveCountersRemaining()
        local maxVitality = GetCurrentRaidStartingReviveCounters()
        self.Vitality_Bonus:SetText(zo_strformat(GetString(RAIDTIMER_VITALITY_BONUS), currentVitality, maxVitality))
    end

    self.score = GetCurrentRaidScore()
    self.ScoreUpdate(event, nil, nil, self.score)
end

function RaidTimer.TimerStart()
    local self = RaidTimer

    -- check if we are currently running, then auto stop and restart
    if self.tempVars.instance then
        local raidName = GetRaidName(GetCurrentParticipatingRaidId())
        if #raidName == 0 then raidName = GetString(RAIDTIMER_TRIALNAME_UNKNOWN) end
        local raidScore = GetCurrentRaidScore()
        local totalTime
        if HasRaidEnded() and WasRaidSuccessful() then
            totalTime = GetGameTimeMilliseconds() - self.raidStart
        end
        self.TimerStop(nil, raidName, raidScore, totalTime)
    end

    self.tempVars.stop = false
    self.tempVars.instance = true

    if self.savedVariables.raidStart then
        self.raidStart = self.savedVariables.raidStart
    else
        self.raidStart = GetTimeStamp()
        self.savedVariables.raidStart = self.raidStart
    end

    self.score = GetCurrentRaidScore() or 0
    self.raidId = GetCurrentParticipatingRaidId()
    if self.savedVariables.debug then
        local currentTopScore = self.savedVariables.topScores[self.raidId].score or 0
        local currentTopTime  = self.savedVariables.topScores[self.raidId].time or 0
        d(zo_strformat(GetString(RAIDTIMER_TRIAL_START_MESSAGE), ZO_CommaDelimitNumber(currentTopScore), ZO_FormatTimeMilliseconds(currentTopTime, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)))
    end

    self.Total_Timer:SetHidden(false)
    self.Raid_Score:SetHidden(false)

    if GetAPIVersion() == 100014 then
        self.Vitality_Bonus:SetHidden(false)
        local currentVitality = GetRaidReviveCountersRemaining()
        local maxVitality = GetCurrentRaidStartingReviveCounters()
        self.Vitality_Bonus:SetText(zo_strformat(GetString(RAIDTIMER_VITALITY_BONUS), currentVitality, maxVitality))
    end

    self.TimerUpdate()
    EVENT_MANAGER:RegisterForUpdate("RAID_TIMER_UPDATE", 1000, self.TimerUpdate)
end

function RaidTimer.TimerStop(event, trialName, totalScore, totalTime)
    local self = RaidTimer

    self.tempVars.stop = true
    self.tempVars.instance = false

    local template = GetString(RAIDTIMER_TRIAL_COMPLETE)
    local raidId   = GetCurrentParticipatingRaidId()

    if totalTime == nil then
        local currentTime = GetTimeStamp()
        totalTime = GetDiffBetweenTimeStamps(currentTime, self.raidStart) * 1000
        template = GetString(RAIDTIMER_TRIAL_FAILED)
    end

    if raidId > 0 then
        -- set savedVariables.topScores
        local currentTopScore = self.savedVariables.topScores[raidId].score or 0
        local currentTopTime  = self.savedVariables.topScores[raidId].time or 0
        if totalScore > currentTopScore then
            self.savedVariables.topScores[raidId].time  = totalTime
            self.savedVariables.topScores[raidId].score = totalScore
            d(zo_strformat(GetString(RAIDTIMER_NEW_TOPSCORE)))
        end
    end

    local formatedTime = ZO_FormatTimeMilliseconds(totalTime, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)
    d(zo_strformat(template, trialName, formatedTime, ZO_CommaDelimitNumber(totalScore)))

    self.Total_Timer:SetHidden(true)
    self.Raid_Score:SetHidden(true)
    if GetAPIVersion() == 100014 then
        self.Vitality_Bonus:SetHidden(true)
    end
    self.score = 0
    self.raidId = nil
    self.raidStart = nil
    self.savedVariables.raidStart = nil
end

-------Get Estimated Score--------
function RaidTimer.EstimatedScore(currentPoints, maxPoints, timeLimit, raidDuration)
    -- old formula
    --zo_max(zo_round(((timeLimit - (raidDuration * maxPoints / currentPoints)) * (maxPoints / 1000)) + maxPoints), zo_floor(currentPoints / 100))
    local halfPoints = maxPoints / 2
    local calcPoints = currentPoints
    if currentPoints < halfPoints then
        calcPoints = maxPoints - currentPoints
    end
    return (maxPoints+((maxPoints)*((timeLimit-raidDuration)/10000)))
end

-------Saving the location of the labels when /rt show-------   
function RaidTimer.SaveLoc()
    local self = RaidTimer
    self.savedVariables.TotalOffsetX = self.Total_Timer:GetLeft()
    self.savedVariables.TotalOffsetY = self.Total_Timer:GetTop()
    self.savedVariables.ScoreOffsetX = self.Raid_Score:GetLeft()
    self.savedVariables.ScoreOffsetY = self.Raid_Score:GetTop()

    if GetAPIVersion() == 100014 then
        self.savedVariables.VitalityOffsetX = self.Vitality_Bonus:GetLeft()
        self.savedVariables.VitalityOffsetY = self.Vitality_Bonus:GetTop()
    end
end

---------Chat commands---------
function RaidTimer.Commands(text)
    local self = RaidTimer

    if not text or text =="" or text =="help" or text =="h" then
        d(GetString(RAIDTIMER_SLASH_HELP))
        d(GetString(RAIDTIMER_SLASH_START))
        d(GetString(RAIDTIMER_SLASH_STOP))
        d(GetString(RAIDTIMER_SLASH_SHOW))
        d(GetString(RAIDTIMER_SLASH_HIDE))
        d(GetString(RAIDTIMER_SLASH_DEBUG))
        d(GetString(RAIDTIMER_SLASH_SURPRISE))
        d(GetString(RAIDTIMER_SLASH_SETTINGS_HINT))
    elseif text == "start" or text == "s" then
        if not self.tempVars.instance then
            self.TimerStart()
        end
    elseif text =="stop" then
        if self.tempVars.instance then
            local raidName = GetRaidName(GetCurrentParticipatingRaidId())
            if #raidName == 0 then raidName = GetString(RAIDTIMER_TRIALNAME_UNKNOWN) end
            local raidScore = GetCurrentRaidScore()
            local totalTime
            if HasRaidEnded() and WasRaidSuccessful() then
                totalTime = GetGameTimeMilliseconds() - self.raidStart
            end
            self.TimerStop(nil, raidName, raidScore, totalTime)
        end
    elseif text =="show" then
        self.Total_Timer:SetHidden(false)
        self.Raid_Score:SetHidden(false)
        if GetAPIVersion() == 100014 then
            self.Vitality_Bonus:SetHidden(false)
        end
        self.tempVars.showTimers = true
    elseif text =="hide" then
        self.Total_Timer:SetHidden(true)
        self.Raid_Score:SetHidden(true)
        if GetAPIVersion() == 100014 then
            self.Vitality_Bonus:SetHidden(true)
        end
        self.tempVars.showTimers = false
    elseif text == "debug" then
        self.savedVariables.debug = not self.savedVariables.debug
    elseif text == "surprise" then ---A little bit of harmless trolling----
        d(GetString(RAIDTIMER_SURPRISE))
    else
        d(GetString(RAIDTIMER_HELP))
    end 

end

--workaround
if(GetAPIVersion() == 100013 and ACTIVITY_TRACKER ~= nil) then
    function GetAPIVersion() return 100014 end
end

EVENT_MANAGER:RegisterForEvent(RaidTimer.name, EVENT_ADD_ON_LOADED, RaidTimer.Initialize)
EVENT_MANAGER:RegisterForEvent("RAID_TIMER_UPDATE", EVENT_RAID_TRIAL_SCORE_UPDATE, RaidTimer.ScoreUpdate)
EVENT_MANAGER:RegisterForEvent("RAID_TIMER_UPDATE", EVENT_RAID_REVIVE_COUNTER_UPDATE, RaidTimer.ReviveUpdate)
EVENT_MANAGER:RegisterForEvent("RAID_TIMER_START", EVENT_RAID_TRIAL_STARTED, RaidTimer.TimerStart)
EVENT_MANAGER:RegisterForEvent("RAID_TIMER_STOP", EVENT_RAID_TRIAL_COMPLETE, RaidTimer.TimerStop)
EVENT_MANAGER:RegisterForEvent("RAID_TIMER_STOP", EVENT_RAID_TRIAL_FAILED, RaidTimer.TimerStop)
