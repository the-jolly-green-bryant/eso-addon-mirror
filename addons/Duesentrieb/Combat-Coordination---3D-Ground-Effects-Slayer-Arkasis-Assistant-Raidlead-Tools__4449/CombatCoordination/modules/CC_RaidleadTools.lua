local CC = CombatCoordination
local LUT = CC.LUT.RAIDLEAD_TOOLS

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "RaidleadTools",
    menuName  = "RAIDLEAD TOOLS & TIMERS",
    iconPath  = "/esoui/art/icons/ability_dragonknight_032.dds",
    menuLayer = 0,

    VOTE_TIMEOUT = 30,

    Broadcast = {
        LUT.BREAK_TIMER,
        LUT.PULL_TIMER,
        LUT.ULTIPULL_TIMER,
        LUT.WIPE_PLEASE,
        LUT.EXIT_INSTANCE,
        LUT.PORT_IN_PLEASE,
        LUT.PORT_TO_LEADER,
        LUT.VOTE_START,
        LUT.VOTE_REPLY,
    },

    VoteData = {
        endTime = 0,
        yes = 0,
        no = 0,
        idc = 0,
        pending = 0,
        total = 0,
        VotedTags = {}
    },

    Default = {
        breakMinutes = 10,
        pullSeconds = 5,
        fontSize = 64,
        fontStyle = "$(BOLD_FONT)",
        fontWeight = "thick-outline",
        Color = { 1, 1, 1, 1 },
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- BROADCAST OR LOCAL
----------------------------------------------------------------------------------------------------
function Module:RequestBreak(breakMinutes)
    if not CC.IsRaidlead() then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Raidlead status required.", "RD")))
        return
    end

    -- 0 TO STOP
    local cleanMinutes = math.floor(breakMinutes or self.SV.breakMinutes)

    -- CANCEL IF PRESSED AGAIN
    if cleanMinutes > 0 and CC.DisplayNotification.breakEndTime > GetGameTimeSeconds() then
        cleanMinutes = 0
    end

    local Data = { ID = LUT.BREAK_TIMER, TX = 0, TY = 0, TZ = 0, RX = 0, RY = 0, RZ = cleanMinutes }

    if IsUnitGrouped("player") then
        CC.Broadcast:Send(Data)
    else
        self:HandleBroadcast("player", Data)
    end
end

----------------------------------------------------------------------------------------------------
-- SEND PULL TIMER INCL. "HACK" INTO HODOR REFLEXES }:-> SORRY, m00ny!
----------------------------------------------------------------------------------------------------
function Module:RequestPull(pullSeconds)
    if not CC.IsRaidlead() then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Raidlead status required.", "RD")))
        return
    end

    -- 0 TO STOP
    local cleanSeconds = math.floor(pullSeconds or self.SV.pullSeconds)

    -- CANCEL IF PRESSED AGAIN
    if cleanSeconds > 0 and CC.DisplayNotification.pullEndTime > GetGameTimeSeconds() then
        cleanSeconds = 0
    end

    -- CLEAR HODOR REFLEXES DELAY
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "HODORREFLEXES_PULLTIMER_DELAY")

    local Data = { ID = LUT.PULL_TIMER, TX = 0, TY = 0, TZ = 0, RX = 0, RY = 0, RZ = cleanSeconds }

    if IsUnitGrouped("player") then
        -- COMBAT COORDINATION PULL TIMER
        CC.Broadcast:Send(Data)

        -- HODOR REFLEXES PULL TIMER
        if HodorReflexes and HodorReflexes.modules and HodorReflexes.modules.pull then
            if IsUnitGroupLeader("player") then
                if cleanSeconds >= 3 and cleanSeconds <= 10 then
                    HodorReflexes.modules.pull:SendPullCountdown(cleanSeconds)
                elseif cleanSeconds > 10 then
                    -- DELAY AND SEND 10s TIMER
                    local delayMs = (cleanSeconds - 10) * 1000
                    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "HODORREFLEXES_PULLTIMER_DELAY", delayMs, function()
                        EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "HODORREFLEXES_PULLTIMER_DELAY")
                        if HodorReflexes and HodorReflexes.modules and HodorReflexes.modules.pull then
                            HodorReflexes.modules.pull:SendPullCountdown(10)
                        end
                    end)
                end
            end
        end
    else
        self:HandleBroadcast("player", Data)
    end
end

----------------------------------------------------------------------------------------------------
-- SEND P-T-E TO GROUP
----------------------------------------------------------------------------------------------------
function Module:RequestExitInstance()
    if not CC.IsRaidlead() then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Raidlead status required.", "RD")))
        return
    end

    local Data = { ID = LUT.EXIT_INSTANCE, TX = 0, TY = 0, TZ = 0, RX = 0, RY = 0, RZ = 0 }

    if IsUnitGrouped("player") then
        d(string.format("%s Exit instance request transmitted.", CC.CHAT))
        CC.Broadcast:Send(Data)
    else
        self:HandleBroadcast("player", Data)
    end
end

----------------------------------------------------------------------------------------------------
-- SEND WIPE PLEASE
----------------------------------------------------------------------------------------------------
function Module:RequestWipe()
    if not CC.IsRaidlead() then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Raidlead status required.", "RD")))
        return
    end

    local Data = { ID = LUT.WIPE_PLEASE, TX = 0, TY = 0, TZ = 0, RX = 0, RY = 0, RZ = 0 }

    if IsUnitGrouped("player") then
        d(string.format("%s Wipe request transmitted.", CC.CHAT))
        CC.Broadcast:Send(Data)
    else
        self:HandleBroadcast("player", Data)
    end
end

----------------------------------------------------------------------------------------------------
-- SEND PORT-TO-ME TO GROUP
----------------------------------------------------------------------------------------------------
function Module:RequestPortToLeader()
    if not CC.IsRaidlead() then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Raidlead status required.", "RD")))
        return
    end

    local Data = { ID = LUT.PORT_TO_LEADER, TX = 0, TY = 0, TZ = 0, RX = 0, RY = 0, RZ = 0 }

    if IsUnitGrouped("player") then
        d(string.format("%s Port to leader request transmitted.", CC.CHAT))
        CC.Broadcast:Send(Data)
    else
        self:HandleBroadcast("player", Data)
    end
end

----------------------------------------------------------------------------------------------------
-- REQUEST PORT IN
----------------------------------------------------------------------------------------------------
function Module:RequestPortIn()
    if not CC.IsRaidlead() then return end

    local playerZoneId = CC.GetCleanZoneId()
    local mappedRx = 0
    for k, v in pairs(CC.ZoneMap) do
        if v == playerZoneId then
            mappedRx = k
            break
        end
    end

    local Data = { ID = LUT.PORT_IN_PLEASE, TX = 0, TY = 0, TZ = 0, RX = mappedRx, RY = 0, RZ = 0 }

    if IsUnitGrouped("player") then
        d(string.format("%s Port in request transmitted.", CC.CHAT))
        CC.Broadcast:Send(Data)
    else
        self:HandleBroadcast("player", Data)
    end
end

----------------------------------------------------------------------------------------------------
-- INIT VOTE DATA
----------------------------------------------------------------------------------------------------
function Module:InitVoteData()
    local totalUsers = 0 -- DEBUG: SET TO 1
    for _, _ in pairs(CC.UserData) do
        totalUsers = totalUsers + 1
    end

    self.VoteData.endTime = GetGameTimeSeconds() + self.VOTE_TIMEOUT
    self.VoteData.yes = 0
    self.VoteData.no = 0
    self.VoteData.idc = 0
    self.VoteData.total = totalUsers
    self.VoteData.pending = totalUsers
    ZO_ClearTable(self.VoteData.VotedTags)

    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Vote_Timeout")
    EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "Vote_Timeout", 1000, function()
        if GetGameTimeSeconds() >= self.VoteData.endTime then --or self.VoteData.pending <= 0 then
            self:FinishVote()
        end
    end)
end

----------------------------------------------------------------------------------------------------
-- VOTE
----------------------------------------------------------------------------------------------------
function Module:StartVote()
    if not CC.IsRaidlead() then
        d(string.format("%s %s", CC.CHAT, CC.ColorString("Permission denied. Raidlead status required.", "RD")))
        return
    end

    -- ACTIVE VOTE? STOP
    if self.VoteData.endTime > 0 then
        local Data = { ID = LUT.VOTE_START, TX = 0, TY = 0, TZ = 0, RX = 0, RY = 0, RZ = 1 } -- RZ = 1 STOP

        if IsUnitGrouped("player") then
            d(string.format("%s Vote sequence stopped early.", CC.CHAT))
            CC.Broadcast:Send(Data)
        else
            d(string.format("%s Vote sequence stopped early (Debug, Solo).", CC.CHAT))
            self:HandleBroadcast("player", Data)
        end
    else
        self:InitVoteData()
        local Data = { ID = LUT.VOTE_START, TX = 0, TY = 0, TZ = 0, RX = 0, RY = 0, RZ = 0 } -- RZ = 0 START

        if IsUnitGrouped("player") then
            d(string.format("%s Vote sequence initiated.", CC.CHAT))
            CC.Broadcast:Send(Data)
        else
            d(string.format("%s Vote sequence initiated (Debug, Solo).", CC.CHAT))
            self:HandleBroadcast("player", Data)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- SEND VOTE REPLY
----------------------------------------------------------------------------------------------------
function Module:SendVoteReply(voteValue)
    -- 1 = YES, 2 = NO, 3 = IDC
    local Data = { ID = LUT.VOTE_REPLY, TX = 0, TY = 0, TZ = 0, RX = 0, RY = 0, RZ = voteValue }

    if IsUnitGrouped("player") then
        CC.Broadcast:Send(Data)
    else
        self:HandleBroadcast("player", Data)
    end
end

----------------------------------------------------------------------------------------------------
-- FINISH VOTE
----------------------------------------------------------------------------------------------------
function Module:FinishVote()
    EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "Vote_Timeout")
    if self.VoteData.endTime == 0 then return end
    self.VoteData.endTime = 0

    local stringResult = string.format("|c00FF00YES: %d|r - |cFF0000NO: %d|r - |cFFDF00IDC: %d|r", self.VoteData.yes, self.VoteData.no, self.VoteData.idc)
    d(string.format("%s Vote finished! ", CC.CHAT) .. stringResult)
    CC.DisplayNotification:TriggerCustom(5, "VOTE FINISHED!", stringResult, false)

    PlaySound(SOUNDS.LEVEL_UP)

    if CC.DisplayDialog.isVoteRequested then
        CC.DisplayDialog.isVoteRequested = false
        CC.DisplayDialog:UpdateDimensions()
    end

    if CC.DisplayPanel.SV.isVisible then
        CC.DisplayPanel:UpdateData()
    end
end

----------------------------------------------------------------------------------------------------
-- HANDLE INCOMING BROADCAST
----------------------------------------------------------------------------------------------------
function Module:HandleBroadcast(unitTag, Data)
    if not Data then return end

    ----------------------------------------------------------------------------------------------------
    -- BREAK TIMER
    ----------------------------------------------------------------------------------------------------
    if Data.ID == LUT.BREAK_TIMER then
        local timeSec = (Data.RZ or 0) * 60
        local displayName = GetUnitDisplayName(unitTag)
        CC.DisplayNotification:TriggerBreak(timeSec, displayName)
    end

    ----------------------------------------------------------------------------------------------------
    -- PULL TIMER
    ----------------------------------------------------------------------------------------------------
    if Data.ID == LUT.PULL_TIMER then
        local timeSec = Data.RZ or 0
        CC.DisplayNotification:TriggerPull(timeSec)
    end

    ----------------------------------------------------------------------------------------------------
    -- EXIT INSTANCE
    ----------------------------------------------------------------------------------------------------
    if Data.ID == LUT.EXIT_INSTANCE then
        CC.DisplayDialog:RequestExitInstance()
    end

    ----------------------------------------------------------------------------------------------------
    -- PORT TO LEADER
    ----------------------------------------------------------------------------------------------------
    if Data.ID == LUT.PORT_TO_LEADER then
        if not AreUnitsEqual(unitTag, "player") then
            local characterName = GetUnitName(unitTag)
            local displayName = GetUnitDisplayName(unitTag)
            local playerLink = CC.GetPlayerLinkFromDisplayName(displayName) or displayName

            CC.DisplayDialog:RequestPortToLeader(characterName, playerLink)
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- VOTE START / STOP
    ----------------------------------------------------------------------------------------------------
    if Data.ID == LUT.VOTE_START then
        if Data.RZ == 1 then
            -- RZ = 1 VOTE STOP
            if self.VoteData.endTime > 0 then
                self:FinishVote()
            end
        else
            -- RZ = 0 VOTE START
            self:InitVoteData()
            CC.DisplayDialog:RequestVote()
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- VOTE REPLY
    ----------------------------------------------------------------------------------------------------
    if Data.ID == LUT.VOTE_REPLY then
        if self.VoteData.endTime > 0 then
            local displayName = GetUnitDisplayName(unitTag) or unitTag
            -- DOUBLE VOTING?
            if not self.VoteData.VotedTags[displayName] then
                self.VoteData.VotedTags[displayName] = true
                self.VoteData.pending = self.VoteData.pending - 1

                local replyName = displayName

                if Data.RZ == 1 then
                    self.VoteData.yes = self.VoteData.yes + 1
                    replyName = "|c00FF00" .. replyName .. ": YES|r"
                elseif Data.RZ == 2 then
                    self.VoteData.no = self.VoteData.no + 1
                    replyName = "|cFF0000" .. replyName .. ": NO|r"
                elseif Data.RZ == 3 then
                    self.VoteData.idc = self.VoteData.idc + 1
                    replyName = "|cFFDF00" .. replyName .. ": IDC|r"
                end

                if CC.DisplayPanel.SV.isVisible then
                    CC.DisplayPanel:UpdateData()
                end

                local stringResult = string.format("|c00FF00YES: %d|r - |cFF0000NO: %d|r - |cFFDF00IDC: %d|r", self.VoteData.yes, self.VoteData.no, self.VoteData.idc)
                CC.DisplayNotification:TriggerCustom(1.0, replyName, stringResult, false)

                CC.PlaySound(SOUNDS.COUNTDOWN_TICK, 2)

                if self.VoteData.pending <= 0 then
                    zo_callLater(function() self:FinishVote() end, 1000 + 500)
                end
            end
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- PORT IN PLEASE
    ----------------------------------------------------------------------------------------------------
    if Data.ID == LUT.PORT_IN_PLEASE then
        --local targetZoneName = GetUnitZone(unitTag)
        local targetZoneId = CC.ZoneMap[Data.RX] or 0
        local playerZoneId = CC.GetCleanZoneId()

        local shouldShow = false
        local zoneName = "Unknown Zone"

        if targetZoneId ~= 0 then
            shouldShow = (playerZoneId ~= targetZoneId)
            zoneName = CC.TrialZones[targetZoneId] or GetUnitZone(unitTag)
        else
            shouldShow = true
            zoneName = GetUnitZone(unitTag)
        end

        if not zoneName or zoneName == "" then zoneName = "Group Instance" end

        if AreUnitsEqual(unitTag, "player") then
            shouldShow = true
            zoneName = GetUnitZone("player")
            if not zoneName or zoneName == "" then zoneName = "Player Instance" end
        end

        if shouldShow then
            CC.DisplayNotification:TriggerPortIn(5, zo_strformat("<<1>>", zoneName))
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- WIPE PLEASE
    ----------------------------------------------------------------------------------------------------
    if Data.ID == LUT.WIPE_PLEASE then
        CC.DisplayNotification:TriggerWipe(5)
    end
end

----------------------------------------------------------------------------------------------------
-- PREVIEW
----------------------------------------------------------------------------------------------------
function Module:UpdateNotificationVisuals()
    if CC.DisplayNotification.LabelLine1 then
        local isDemo = (CC.DisplayNotification.breakEndTime == 0 and CC.DisplayNotification.slayerEndTime == 0 and CC.DisplayNotification.pullEndTime == 0)

        if isDemo then
            CC.DisplayNotification.Parent:SetHidden(false)
        end

        local fontString = string.format("%s|%d|%s", CC.DisplayNotification.SV.fontStyle, CC.DisplayNotification.SV.fontSize, CC.DisplayNotification.SV.fontWeight)
        CC.DisplayNotification.LabelLine1:SetFont(fontString)
        CC.DisplayNotification.LabelLine1:SetColor(unpack(self.SV.Color))

        if isDemo then
            CC.DisplayNotification.LabelLine1:SetText("BREAK 5:00 (DEMO)")

            -- END DEMO
            zo_callLater(function()
                if CC.DisplayNotification.breakEndTime == 0 and CC.DisplayNotification.slayerEndTime == 0 and CC.DisplayNotification.pullEndTime == 0 then
                    CC.DisplayNotification.Parent:SetHidden(true)
                end
            end, 2500)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- INIT MODULE INCL. PREHOOK INTO HODOR REFLEXES PULL TIMER; THX ExoY!
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    -- PRE-HOOK HODOR REFLEXES PULL TIMER
    if HodorReflexes and HodorReflexes.modules and HodorReflexes.modules.pull then
        ZO_PreHook(HodorReflexes.modules.pull, "RenderPullCountdown", function(pull, durationMS)
            local timeSec = math.floor((durationMS or 0) / 1000)
            if timeSec > 0 then
                CC.DisplayNotification:TriggerPull(timeSec)
            end
            return true
        end)
    end
end

CC[Module.name] = Module
table.insert(CC.Modules, Module)

----------------------------------------------------------------------------------------------------
-- SLASH COMMANDS
----------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/cc_pull"] = function(arg)
    local rawTime = tonumber(arg)
    local time = rawTime
    if rawTime == nil then
        time = CC.RaidleadTools.SV.pullSeconds
    end
    time = math.max(0, math.min(30, time))
    CC.RaidleadTools:RequestPull(time)
end

SLASH_COMMANDS["/cc_break"] = function(arg)
    local rawTime = tonumber(arg)
    local time = rawTime
    if rawTime == nil then
        time = CC.RaidleadTools.SV.breakMinutes
    end
    time = math.max(0, math.min(60, time))
    CC.RaidleadTools:RequestBreak(time)
end

SLASH_COMMANDS["/cc_vote"] = function()
    CC.RaidleadTools:StartVote()
end

SLASH_COMMANDS["/cc_wipe"] = function()
    CC.RaidleadTools:RequestWipe()
end