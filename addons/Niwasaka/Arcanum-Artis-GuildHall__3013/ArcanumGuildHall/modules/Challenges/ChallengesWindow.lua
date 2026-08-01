local ArcanumGuildHall = _G["ArcanumGuildHall"]

local pled = ArcanumGuildHallPledges
local res = ArcanumGuildHallMediaRes

local TAB_COLOR_ACTIVE_BG = { 0.16, 0.16, 0.16, 0.95 }
local TAB_COLOR_ACTIVE_EDGE = { 0.35, 0.35, 0.35, 1 }
local TAB_COLOR_INACTIVE_BG = { 0.08, 0.08, 0.08, 0.70 }
local TAB_COLOR_INACTIVE_EDGE = { 0.25, 0.25, 0.25, 1 }
local TAB_COLOR_HOVER_BG = { 0.12, 0.12, 0.12, 0.90 }
local TAB_COLOR_HOVER_EDGE = { 0.42, 0.42, 0.42, 1 }

local ACTION_BUTTON_BG = { 0.10, 0.10, 0.10, 0.85 }
local ACTION_BUTTON_EDGE = { 0.30, 0.30, 0.30, 1 }
local ACTION_BUTTON_HOVER_BG = { 0.16, 0.16, 0.16, 0.95 }
local ACTION_BUTTON_HOVER_EDGE = { 0.45, 0.45, 0.45, 1 }

local LABEL_COLOR = { 0.82, 0.72, 0.42, 1 }
local VALUE_COLOR = { 1, 1, 1, 1 }
local INFO_COLOR = { 0.72, 0.72, 0.72, 1 }
local TAB_TEXT_ACTIVE_COLOR = { 1, 1, 1, 1 }
local TAB_TEXT_INACTIVE_COLOR = { 0.72, 0.72, 0.72, 1 }
local TAB_TEXT_HOVER_COLOR = { 0.92, 0.92, 0.92, 1 }
local ACTION_BUTTON_TEXT = { 0.92, 0.92, 0.92, 1 }
local ACTION_BUTTON_TEXT_HOVER = { 1, 1, 1, 1 }

local PLEDGE_ROTATION_REFERENCE_TIMESTAMP = 1615168800
local DAY_IN_SECONDS = 86400

local function getNextPledgeChangeTimestamp()
    local now = GetTimeStamp()
    local todayMidnightUTC = now - (now % 86400)
    local todayResetUTC = todayMidnightUTC + 10800 -- 03:00 UTC

    if now < todayResetUTC then
        return todayResetUTC
    end

    return todayResetUTC + 86400
end

local function roundToMinute(timestamp)
    return math.floor(timestamp / 60) * 60
end

local function getNextWeeklyChangeTimestamp()
    local _, secsUntilNextStart = GetRaidOfTheWeekTimes()

    if secsUntilNextStart and secsUntilNextStart > 0 then
        return roundToMinute(GetTimeStamp() + secsUntilNextStart)
    end

    return 0
end

local function formatWindowTime(timestamp)
    return os.date("%d.%m.%Y %H:%M", timestamp)
end

function ArcanumGuildHall:RestoreChallengesWindowPosition()
    local control = self.challengesWindow.control

    if self.db.challengesWindowX ~= nil and self.db.challengesWindowY ~= nil then
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.db.challengesWindowX, self.db.challengesWindowY)
    end
end

function ArcanumGuildHall:SaveChallengesWindowPosition()
    local control = self.challengesWindow.control
    self.db.challengesWindowX = zo_floor(control:GetLeft())
    self.db.challengesWindowY = zo_floor(control:GetTop())
end

function ArcanumGuildHall:InitializeChallengesWindow()
    local control = ArcanumGuildHallChallengesWindow
    local contentBg = control:GetNamedChild("ContentBG")
    local pledgesPane = contentBg:GetNamedChild("PledgesPane")
    local weekliesPane = contentBg:GetNamedChild("WeekliesPane")
    local closeButton = control:GetNamedChild("Close")

    self.challengesWindow = {
        control = control,
        title = control:GetNamedChild("Title"),

        pledgesTab = control:GetNamedChild("PledgesTab"),
        pledgesTabBg = control:GetNamedChild("PledgesTab"):GetNamedChild("BG"),
        pledgesTabLabel = control:GetNamedChild("PledgesTab"):GetNamedChild("Label"),

        weekliesTab = control:GetNamedChild("WeekliesTab"),
        weekliesTabBg = control:GetNamedChild("WeekliesTab"):GetNamedChild("BG"),
        weekliesTabLabel = control:GetNamedChild("WeekliesTab"):GetNamedChild("Label"),

        pledgesPane = pledgesPane,
        pledgesDateLabel = pledgesPane:GetNamedChild("DateLabel"),
        pledgesDateValue = pledgesPane:GetNamedChild("DateValue"),
        pledgesNpc1Label = pledgesPane:GetNamedChild("Npc1Label"),
        pledgesNpc1Value = pledgesPane:GetNamedChild("Npc1Value"),
        pledgesNpc2Label = pledgesPane:GetNamedChild("Npc2Label"),
        pledgesNpc2Value = pledgesPane:GetNamedChild("Npc2Value"),
        pledgesNpc3Label = pledgesPane:GetNamedChild("Npc3Label"),
        pledgesNpc3Value = pledgesPane:GetNamedChild("Npc3Value"),
        pledgesSendButton = pledgesPane:GetNamedChild("SendButton"),
        pledgesSendButtonBg = pledgesPane:GetNamedChild("SendButton"):GetNamedChild("BG"),
        pledgesSendButtonLabel = pledgesPane:GetNamedChild("SendButton"):GetNamedChild("Label"),

        weekliesPane = weekliesPane,
        weekliesPeriodLabel = weekliesPane:GetNamedChild("PeriodLabel"),
        weekliesPeriodValue = weekliesPane:GetNamedChild("PeriodValue"),
        weekliesTrialLabel = weekliesPane:GetNamedChild("TrialLabel"),
        weekliesTrialValue = weekliesPane:GetNamedChild("TrialValue"),
        weekliesSoloLabel = weekliesPane:GetNamedChild("SoloLabel"),
        weekliesSoloValue = weekliesPane:GetNamedChild("SoloValue"),

        infoLabel = contentBg:GetNamedChild("Info"),

        currentTab = self.db.challengesWindowLastTab == "weeklies" and "weeklies" or "pledges",
        fragment = ZO_HUDFadeSceneFragment:New(control, nil, 0),
        isEnabled = false,
    }

    local window = self.challengesWindow

    control:SetHidden(true)

    window.pledgesTabLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("PLEDGES_BUTTON"))
    window.weekliesTabLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("WEEKLY_CHALLENGES_TITLE"))

    window.pledgesDateLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("CHALLENGES_WINDOW_DATE"))
    window.pledgesNpc1Label:SetText(pled.npcNames[1])
    window.pledgesNpc2Label:SetText(pled.npcNames[2])
    window.pledgesNpc3Label:SetText(pled.npcNames[3])
    window.pledgesSendButtonLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("CHALLENGES_WINDOW_SEND_BUTTON"))

    window.weekliesPeriodLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("CHALLENGES_WINDOW_PERIOD"))
    window.weekliesTrialLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("WEEKLY_CHALLENGES_TRIAL"))
    window.weekliesSoloLabel:SetText(ArcanumGuildHall.GetDefaultLocaleString("WEEKLY_CHALLENGES_SOLO"))

    window.pledgesDateLabel:SetColor(unpack(LABEL_COLOR))
    window.pledgesNpc1Label:SetColor(unpack(LABEL_COLOR))
    window.pledgesNpc2Label:SetColor(unpack(LABEL_COLOR))
    window.pledgesNpc3Label:SetColor(unpack(LABEL_COLOR))
    window.weekliesPeriodLabel:SetColor(unpack(LABEL_COLOR))
    window.weekliesPeriodValue:SetColor(unpack(VALUE_COLOR))
    window.weekliesTrialLabel:SetColor(unpack(LABEL_COLOR))
    window.weekliesSoloLabel:SetColor(unpack(LABEL_COLOR))
    window.infoLabel:SetColor(unpack(INFO_COLOR))

    window.pledgesDateValue:SetColor(unpack(VALUE_COLOR))
    window.pledgesNpc1Value:SetColor(unpack(VALUE_COLOR))
    window.pledgesNpc2Value:SetColor(unpack(VALUE_COLOR))
    window.pledgesNpc3Value:SetColor(unpack(VALUE_COLOR))
    window.weekliesTrialValue:SetColor(unpack(VALUE_COLOR))
    window.weekliesSoloValue:SetColor(unpack(VALUE_COLOR))

    window.pledgesSendButtonBg:SetCenterColor(unpack(ACTION_BUTTON_BG))
    window.pledgesSendButtonBg:SetEdgeColor(unpack(ACTION_BUTTON_EDGE))
    window.pledgesSendButtonLabel:SetColor(unpack(ACTION_BUTTON_TEXT))

    closeButton:SetHandler("OnClicked", function()
        self:HideChallengesWindow()
    end)

    window.pledgesTab:SetHandler("OnClicked", function()
        self:SetChallengesWindowTab("pledges")
    end)

    window.weekliesTab:SetHandler("OnClicked", function()
        self:SetChallengesWindowTab("weeklies")
    end)

    window.pledgesTab:SetHandler("OnMouseEnter", function()
        if window.currentTab ~= "pledges" then
            window.pledgesTabBg:SetCenterColor(unpack(TAB_COLOR_HOVER_BG))
            window.pledgesTabBg:SetEdgeColor(unpack(TAB_COLOR_HOVER_EDGE))
            window.pledgesTabLabel:SetColor(unpack(TAB_TEXT_HOVER_COLOR))
        end
    end)

    window.pledgesTab:SetHandler("OnMouseExit", function()
        self:UpdateChallengesWindowTabState()
    end)

    window.weekliesTab:SetHandler("OnMouseEnter", function()
        if window.currentTab ~= "weeklies" then
            window.weekliesTabBg:SetCenterColor(unpack(TAB_COLOR_HOVER_BG))
            window.weekliesTabBg:SetEdgeColor(unpack(TAB_COLOR_HOVER_EDGE))
            window.weekliesTabLabel:SetColor(unpack(TAB_TEXT_HOVER_COLOR))
        end
    end)

    window.weekliesTab:SetHandler("OnMouseExit", function()
        self:UpdateChallengesWindowTabState()
    end)

    window.pledgesSendButton:SetHandler("OnClicked", function()
        self:SendPledgesToChat()
    end)

    window.pledgesSendButton:SetHandler("OnMouseEnter", function()
        window.pledgesSendButtonBg:SetCenterColor(unpack(ACTION_BUTTON_HOVER_BG))
        window.pledgesSendButtonBg:SetEdgeColor(unpack(ACTION_BUTTON_HOVER_EDGE))
        window.pledgesSendButtonLabel:SetColor(unpack(ACTION_BUTTON_TEXT_HOVER))
    end)

    window.pledgesSendButton:SetHandler("OnMouseExit", function()
        window.pledgesSendButtonBg:SetCenterColor(unpack(ACTION_BUTTON_BG))
        window.pledgesSendButtonBg:SetEdgeColor(unpack(ACTION_BUTTON_EDGE))
        window.pledgesSendButtonLabel:SetColor(unpack(ACTION_BUTTON_TEXT))
    end)

    control:SetHandler("OnMoveStop", function()
        self:SaveChallengesWindowPosition()
    end)

    control:SetHandler("OnEffectivelyShown", function()
        self:RestoreChallengesWindowPosition()
        self:RefreshChallengesWindow()
    end)

    self:UpdateChallengesWindowTabState()
    self:RestoreChallengesWindowPosition()

    if self.db.challengesWindowVisible then
        self:ShowChallengesWindow()
    end

    EVENT_MANAGER:RegisterForEvent(self.name .. "ChallengesActivated", EVENT_PLAYER_ACTIVATED, function()
        if not ArcanumGuildHallChallengesWindow:IsHidden() then
            self.challengesWindow.isEnabled = true
            local attempts = 0
            local function tryRefresh()
                local _, trialRaidId = GetRaidOfTheWeekLeaderboardInfo(RAID_CATEGORY_TRIAL)
                if trialRaidId and trialRaidId > 0 then
                    self:RefreshChallengesWindowWeeklies()
                    self:RefreshChallengesWindowInfo()
                    return
                end
                attempts = attempts + 1
                if attempts < 5 then
                    QueryRaidLeaderboardData(RAID_CATEGORY_TRIAL, 0, 0)
                    QueryRaidLeaderboardData(RAID_CATEGORY_CHALLENGE, 0, 0)
                    zo_callLater(tryRefresh, 500)
                end
            end
            QueryRaidLeaderboardData(RAID_CATEGORY_TRIAL, 0, 0)
            QueryRaidLeaderboardData(RAID_CATEGORY_CHALLENGE, 0, 0)
            zo_callLater(tryRefresh, 500)
        end
    end)
end

function ArcanumGuildHall:UpdateChallengesWindowTabState()
    local window = self.challengesWindow
    local isPledges = window.currentTab == "pledges"

    window.pledgesPane:SetHidden(not isPledges)
    window.weekliesPane:SetHidden(isPledges)

    window.title:SetText(ArcanumGuildHall.GetDefaultLocaleString("CHALLENGES_WINDOW_TITLE"))

    if isPledges then
        window.pledgesTabBg:SetCenterColor(unpack(TAB_COLOR_ACTIVE_BG))
        window.pledgesTabBg:SetEdgeColor(unpack(TAB_COLOR_ACTIVE_EDGE))
        window.pledgesTabLabel:SetColor(unpack(TAB_TEXT_ACTIVE_COLOR))

        window.weekliesTabBg:SetCenterColor(unpack(TAB_COLOR_INACTIVE_BG))
        window.weekliesTabBg:SetEdgeColor(unpack(TAB_COLOR_INACTIVE_EDGE))
        window.weekliesTabLabel:SetColor(unpack(TAB_TEXT_INACTIVE_COLOR))
    else
        window.pledgesTabBg:SetCenterColor(unpack(TAB_COLOR_INACTIVE_BG))
        window.pledgesTabBg:SetEdgeColor(unpack(TAB_COLOR_INACTIVE_EDGE))
        window.pledgesTabLabel:SetColor(unpack(TAB_TEXT_INACTIVE_COLOR))

        window.weekliesTabBg:SetCenterColor(unpack(TAB_COLOR_ACTIVE_BG))
        window.weekliesTabBg:SetEdgeColor(unpack(TAB_COLOR_ACTIVE_EDGE))
        window.weekliesTabLabel:SetColor(unpack(TAB_TEXT_ACTIVE_COLOR))
    end
end

function ArcanumGuildHall:SetChallengesWindowTab(tabKey)
    if self.challengesWindow.currentTab == tabKey then
        return
    end

    self.challengesWindow.currentTab = tabKey
    self.db.challengesWindowLastTab = tabKey

    self:UpdateChallengesWindowTabState()
    self:RefreshChallengesWindow()
end

function ArcanumGuildHall:RefreshChallengesWindow()
    self:RefreshChallengesWindowPledges()
    self:RefreshChallengesWindowWeeklies()
    self:RefreshChallengesWindowInfo()
end

function ArcanumGuildHall:RefreshChallengesWindowPledges()
    local window = self.challengesWindow
    local elapsedDays = zo_floor((GetTimeStamp() - PLEDGE_ROTATION_REFERENCE_TIMESTAMP) / DAY_IN_SECONDS)

    if elapsedDays < 0 then
        elapsedDays = 0
    end

    local valueLabels = {
        window.pledgesNpc1Value,
        window.pledgesNpc2Value,
        window.pledgesNpc3Value,
    }

    window.pledgesDateValue:SetText(os.date("%d.%m.%Y"))

    for i = 1, 3 do
        local row = pled.dailies[i]
        local maxIds = #row
        local actualId = (elapsedDays % maxIds) + 1
        local value = row[actualId][1]

        valueLabels[i]:SetText(value)
        valueLabels[i]:SetColor(unpack(VALUE_COLOR))
    end
end

function ArcanumGuildHall:RefreshChallengesWindowWeeklies()
    local window = self.challengesWindow

    local _, trialRaidId = GetRaidOfTheWeekLeaderboardInfo(RAID_CATEGORY_TRIAL)
    local _, soloRaidId = GetRaidOfTheWeekLeaderboardInfo(RAID_CATEGORY_CHALLENGE)

    window.weekliesTrialValue:SetText(trialRaidId and trialRaidId > 0 and GetRaidLeaderboardName(trialRaidId) or "")
    window.weekliesSoloValue:SetText(soloRaidId and soloRaidId > 0 and GetRaidLeaderboardName(soloRaidId) or "")

    local secsUntilEnd, secsUntilNextStart = GetRaidOfTheWeekTimes()
    local now = GetTimeStamp()
    local periodEnd = secsUntilEnd and secsUntilEnd > 0 and roundToMinute(now + secsUntilEnd) or 0
    local periodStart = secsUntilNextStart and secsUntilNextStart > 0 and roundToMinute((now + secsUntilNextStart) - 604800) or 0

    if periodStart > 0 and periodEnd > 0 then
        window.weekliesPeriodValue:SetText(formatWindowTime(periodStart) .. " – " .. formatWindowTime(periodEnd))
    else
        window.weekliesPeriodValue:SetText("")
    end
end

function ArcanumGuildHall:RefreshChallengesWindowInfo()
    local window = self.challengesWindow

    if window.currentTab == "pledges" then
        window.infoLabel:SetText(
                ArcanumGuildHall.GetDefaultLocaleString("CHALLENGES_WINDOW_NEXT_DAILY_CHANGE")
                        .. formatWindowTime(getNextPledgeChangeTimestamp())
        )
    else
        window.infoLabel:SetText(
                ArcanumGuildHall.GetDefaultLocaleString("CHALLENGES_WINDOW_NEXT_WEEKLY_CHANGE")
                        .. formatWindowTime(getNextWeeklyChangeTimestamp())
        )
    end
end

function ArcanumGuildHall:ShowChallengesWindow()
    if self.challengesWindow.isEnabled then
        return
    end

    self.challengesWindow.isEnabled = true
    self.db.challengesWindowVisible = true

    HUD_SCENE:AddFragment(self.challengesWindow.fragment)
    HUD_UI_SCENE:AddFragment(self.challengesWindow.fragment)

    QueryRaidLeaderboardData(RAID_CATEGORY_TRIAL, 0, 0)
    QueryRaidLeaderboardData(RAID_CATEGORY_CHALLENGE, 0, 0)
end

function ArcanumGuildHall:HideChallengesWindow()
    if not self.challengesWindow.isEnabled then
        return
    end

    HUD_SCENE:RemoveFragment(self.challengesWindow.fragment)
    HUD_UI_SCENE:RemoveFragment(self.challengesWindow.fragment)

    self.challengesWindow.isEnabled = false
    self.db.challengesWindowVisible = false
end

function ArcanumGuildHall:ToggleChallengesWindow()
    if self.challengesWindow.isEnabled then
        self:HideChallengesWindow()
    else
        self:ShowChallengesWindow()
    end
end