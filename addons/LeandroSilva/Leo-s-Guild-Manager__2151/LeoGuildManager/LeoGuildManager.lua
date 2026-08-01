LeoGuildManager.members = {}
LeoGuildManager.guilds = {}
LeoGuildManager.isScanning = false
LeoGuildManager.salesEvents = {}
LeoGuildManager.depositsEvents = {}
LeoGuildManager.numEvents = {}
LeoGuildManager.inCombat = false
LeoGuildManager.nextGuildScan = 1
LeoGuildManager.isDebug = false
LeoGuildManager.lastScannedEvent = {}

LeoGuildManager.manualScan = false

local scanInterval = 5 * LeoGuildManager.MS_IN_MINUTE
local shortScanInterval = 2000

function LeoGuildManager.SetWarnOnline(guildName, value)
    LeoGuildManager.globalData.settings.guilds[guildName].warnOnline = value
end
function LeoGuildManager.GetWarnOnline(guildName)
    if LeoGuildManager.globalData.settings.guilds[guildName].warnOnline == nil then
        LeoGuildManager.globalData.settings.guilds[guildName].warnOnline = true
    end
    return LeoGuildManager.globalData.settings.guilds[guildName].warnOnline
end
function LeoGuildManager.SetAutoKick(guildName, value)
    LeoGuildManager.globalData.settings.guilds[guildName].autoKick = value
end
function LeoGuildManager.GetAutoKick(guildName)
    if LeoGuildManager.globalData.settings.guilds[guildName].autoKick == nil then
        LeoGuildManager.globalData.settings.guilds[guildName].autoKick = false
    end
    return LeoGuildManager.globalData.settings.guilds[guildName].autoKick
end
function LeoGuildManager.SetTooltipRoster(guildName, value)
    LeoGuildManager.globalData.settings.guilds[guildName].tooltipRoster = value
end
function LeoGuildManager.UseTooltipRoster(guildName)
    if LeoGuildManager.globalData.settings.guilds[guildName].tooltipRoster == nil then
        LeoGuildManager.globalData.settings.guilds[guildName].tooltipRoster = false
    end
    return LeoGuildManager.globalData.settings.guilds[guildName].tooltipRoster
end
function LeoGuildManager.SetPurgePurchases(guildName, value)
    LeoGuildManager.globalData.settings.guilds[guildName].purchases = value
end
function LeoGuildManager.GetPurgePurchases(guildName)
    if LeoGuildManager.globalData.settings.guilds[guildName].purchases == nil then
        LeoGuildManager.globalData.settings.guilds[guildName].purchases = 0
    end
    return LeoGuildManager.globalData.settings.guilds[guildName].purchases
end
function LeoGuildManager.SetKeepBankHistory(guildName, value)
    LeoGuildManager.globalData.settings.guilds[guildName].keepBankHistory = value
end
function LeoGuildManager.GetKeepBankHistory(guildName)
    if LeoGuildManager.globalData.settings.guilds[guildName].keepBankHistory == nil then
        LeoGuildManager.globalData.settings.guilds[guildName].keepBankHistory = 30
    end
    return LeoGuildManager.globalData.settings.guilds[guildName].keepBankHistory
end
function LeoGuildManager.SetKeepRosterHistory(guildName, value)
    LeoGuildManager.globalData.settings.guilds[guildName].keepRosterHistory = value
end
function LeoGuildManager.GetKeepRosterHistory(guildName)
    if LeoGuildManager.globalData.settings.guilds[guildName].keepRosterHistory == nil then
        LeoGuildManager.globalData.settings.guilds[guildName].keepRosterHistory = 30
    end
    return LeoGuildManager.globalData.settings.guilds[guildName].keepRosterHistory
end

function LeoGuildManager.TimeAgo(timestamp)
    local diff = GetTimeStamp() - timestamp
    if diff < 3600 then
        ago = ZO_CachedStrFormat(GetString(SI_TIME_FORMAT_MINUTES), math.floor(diff / 60))
    elseif diff < LeoGuildManager.SECONDS_IN_DAY then
        ago = ZO_CachedStrFormat(GetString(SI_TIME_FORMAT_HOURS), math.floor(diff / 3600))
    else
        ago = ZO_CachedStrFormat(GetString(SI_TIME_FORMAT_DAYS), math.floor(diff / LeoGuildManager.SECONDS_IN_DAY))
    end
    return ZO_CachedStrFormat(GetString(SI_TIME_DURATION_AGO), ago)
end

function LeoGuildManager.formatNumber(amount)
    if amount == nil then
        return nil;
    end
    if type(amount) == "string" then
        amount = tonumber(amount)
    end
    if type(amount) ~= "number" then
        return amount;
    end
    if amount < 0 then
        amount = 0
    end
    if amount < 1000 then
        return amount;
    end
    return FormatIntegerWithDigitGrouping(amount, GetString(SI_DIGIT_GROUP_SEPARATOR))
end

local function formatMessage(message)
    return LeoGuildManager.chatPrefix .. message
end

function LeoGuildManager.log(message)
    d(formatMessage(message))
end

function LeoGuildManager.debug(message)
    if LeoGuildManager.isDebug == true then
        d(formatMessage("[D] " .. message))
    end
end

function LeoGuildManager.GetCycles()
    local cycleData = LeoGuildManager.cycleMM
    if LeoGuildManager.globalData.settings.integration == "Arkadiu's Trade Tools" then
        cycleData = LeoGuildManager.cycleATT
    end
    local cycle = {}
    for _, data in pairs(cycleData) do
        table.insert(cycle, data.name)
    end
    return cycle
end

function LeoGuildManager.GetCycleName(id)
    local cycleData = LeoGuildManager.cycleMM
    if LeoGuildManager.globalData.settings.integration == "Arkadiu's Trade Tools" then
        cycleData = LeoGuildManager.cycleATT
    end
    for _, data in pairs(cycleData) do
        if data.id == id then
            return data.name
        end
    end
    return nil
end

function LeoGuildManager.GetNewRangeName(value)
    if value == 0 then
        return "None"
    elseif value == 7 then
        return "1 week"
    elseif value == 14 then
        return "2 weeks"
    elseif value == 21 then
        return "3 weeks"
    else
        return "1 month"
    end
end

function LeoGuildManager.GetCycleIdByName(name)
    local cycleData = LeoGuildManager.cycleMM
    if LeoGuildManager.globalData.settings.integration == "Arkadiu's Trade Tools" then
        cycleData = LeoGuildManager.cycleATT
    end
    for _, data in pairs(cycleData) do
        if data.name == name then
            return data.id
        end
    end
    return nil
end

function LeoGuildManager.GetGuildId(name)
    for guildId, guildName in pairs(LeoGuildManager.guilds) do
        if guildName == name then
            return guildId
        end
    end
    return nil
end

function LeoGuildManager.GetGuilds()
    if #LeoGuildManager.guilds > 0 then
        return LeoGuildManager.guilds
    end

    LeoGuildManager.guilds = {}
    if GetNumGuilds() > 0 then
        for guild = 1, GetNumGuilds() do
            local guildId = GetGuildId(guild)
            local guildName = GetGuildName(guildId)
            if (not guildName or (guildName):len() < 1) then
                guildName = "Guild " .. guildId
            end
            LeoGuildManager.guilds[guildId] = guildName
        end
    end

    return LeoGuildManager.guilds
end

function LeoGuildManager.GetGuildIndex(guildName)
    if GetNumGuilds() > 0 then
        for guild = 1, GetNumGuilds() do
            local name = GetGuildName(guildId)
            if name == guildName then
                return guild
            end
        end
    end
    return nil
end

function LeoGuildManager.GetGuildRankName(guildId, rankId)
    local name = GetGuildRankCustomName(guildId, rankId)
    if name == "" then
        name = GetDefaultGuildRankName(guildId, rankId)
    end
    return name
end

function LeoGuildManager.GetGuildRankId(guildId, rankName)
    for i = 1, GetNumGuildRanks(guildId) do
        local name = GetGuildRankCustomName(guildId, i)
        if name == "" then
            name = GetDefaultGuildRankName(guildId, i)
        end
        if name == rankName then
            return i
        end
    end
    return 0
end

function LeoGuildManager.GetGuildRanks(guildId)
    local ranks = {}
    for i = 1, GetNumGuildRanks(guildId) do
        local rankName = GetGuildRankCustomName(guildId, i)
        if rankName == "" then
            rankName = GetDefaultGuildRankName(guildId, i)
        end
        ranks[i] = rankName
    end
    return ranks
end

function LeoGuildManager.GetGuildMember(name)
    for i = 1, #LeoGuildManager.members do
        if LeoGuildManager.members[i].name == name then
            return LeoGuildManager.members[i]
        end
    end
    return nil
end

function LeoGuildManager.GetGuildMembers(guildId)

    LeoGuildManager.members = {}
    local numGuildMembers = GetNumGuildMembers(guildId)
    for guildMemberIndex = 1, numGuildMembers do
        local displayName, note, rankIndex, status, secsSinceLogoff = GetGuildMemberInfo(guildId, guildMemberIndex)
        if status ~= PLAYER_STATUS_OFFLINE then
            secsSinceLogoff = 0
        end
        local rankId = GetGuildRankId(guildId, rankIndex)
        local rankName = LeoGuildManager.GetGuildRankName(guildId, rankIndex)
        table.insert(LeoGuildManager.members, {
            memberIndex = guildMemberIndex, -- just to make sure ...
            name = displayName,
            rankIndex = rankIndex,
            rankId = rankId,
            rankName = rankName,
            memberSince = 0,
            invitedBy = "",
            online = secsSinceLogoff,
            deposits = -1,
            taxes = 0,
            sales = -1,
            purchases = -1,
            joined = 0,
            endangered = false,
            depositEvents = {}
        })
    end
end

function LeoGuildManager.SetJoined(memberName, joined)
    for i = 1, #LeoGuildManager.members do
        if LeoGuildManager.members[i].name == memberName then
            LeoGuildManager.members[i].joined = joined
            return
        end
    end
end

function LeoGuildManager.IsEndangered(memberName, value)
    for i = 1, #LeoGuildManager.members do
        if LeoGuildManager.members[i].name == memberName then
            return LeoGuildManager.members[i].endangered
        end
    end
end

function LeoGuildManager.RemoveMember(memberName)
    for i = 1, #LeoGuildManager.members do
        if LeoGuildManager.members[i].name == memberName then
            table.remove(LeoGuildManager.members, i)
            return
        end
    end
end

function LeoGuildManager.UpdateMemberRank(guildId, memberName)
    for i = 1, #LeoGuildManager.members do
        if LeoGuildManager.members[i].name == memberName then
            local _, _, rankIndex = GetGuildMemberInfo(guildId, LeoGuildManager.members[i].memberIndex)
            local rankId = GetGuildRankId(guildId, rankIndex)
            local rankName = LeoGuildManager.GetGuildRankName(guildId, rankIndex)
            LeoGuildManager.members[i].rankIndex = rankIndex
            LeoGuildManager.members[i].rankId = rankId
            LeoGuildManager.members[i].rankName = rankName
            return
        end
    end
end

function LeoGuildManager.SetEndangered(memberName, value)
    for i = 1, #LeoGuildManager.members do
        if LeoGuildManager.members[i].name == memberName then
            LeoGuildManager.members[i].endangered = value
            return
        end
    end
end

function LeoGuildManager.AddSale(memberName, value)
    for i = 1, #LeoGuildManager.members do
        if LeoGuildManager.members[i].name == memberName then
            if LeoGuildManager.members[i].sales < 0 then
                LeoGuildManager.members[i].sales = 0
            end
            LeoGuildManager.members[i].sales = LeoGuildManager.members[i].sales + value
            return
        end
    end
end

function LeoGuildManager.AddPurchase(memberName, value)
    for i = 1, #LeoGuildManager.members do
        if LeoGuildManager.members[i].name == memberName then
            if LeoGuildManager.members[i].purchases < 0 then
                LeoGuildManager.members[i].purchases = 0
            end
            LeoGuildManager.members[i].purchases = LeoGuildManager.members[i].purchases + value
            return
        end
    end
end

function LeoGuildManager.AddDeposit(memberName, value, timestamp)
    for i = 1, #LeoGuildManager.members do
        if LeoGuildManager.members[i].name == memberName then
            if LeoGuildManager.members[i].deposits < 0 then
                LeoGuildManager.members[i].deposits = 0
            end
            LeoGuildManager.members[i].deposits = LeoGuildManager.members[i].deposits + value
            table.insert(LeoGuildManager.members[i].depositEvents, {
                value = value,
                timestamp = timestamp
            })
            return
        end
    end
end

function LeoGuildManager.CreatePurgeDescription(guildName)
    if LeoGuildManager.globalData.selectedGuild == nil or LeoGuildManager.globalData.selectedGuild == "" then
        return
    end

    local cycle = LeoGuildManager.GetCycleName(LeoGuildManager.globalData.settings.guilds[guildName].cycle)

    local tickets = LeoGuildManager.globalData.settings.guilds[guildName].tickets
    local sales = LeoGuildManager.globalData.settings.guilds[guildName].sales
    local purchases = LeoGuildManager.GetPurgePurchases(guildName)
    local inactivity = LeoGuildManager.globalData.settings.guilds[guildName].inactivity
    local ignoreRank = LeoGuildManager.globalData.settings.guilds[guildName].ignoreRank
    local ignoreNew = LeoGuildManager.globalData.settings.guilds[guildName].ignoreNew

    local guildId = LeoGuildManager.GetGuildId(guildName)
    local canScan = LeoGuildManager.CanScanBankHistory(guildId)
    local integrationLoaded = LeoGuildManager.HasIntegrationAddonsLoaded()
    if not canScan then
        tickets = 0
    end
    if not integrationLoaded then
        sales = 0
    end

    local descPurge = ""

    if tickets > 0 or sales > 0 or purchases > 0 then
        descPurge = cycle .. ", members were required "
    end
    local hasCond = false
    if tickets > 0 then
        descPurge = descPurge .. "to buy at least " .. tickets .. "k in raffle tickets"
        hasCond = true
    end
    if sales > 0 then
        if hasCond then
            descPurge = descPurge .. " OR "
        end
        descPurge = descPurge .. "to have at least " .. sales .. "k sales"
        hasCond = true
    end
    if purchases > 0 then
        if hasCond then
            descPurge = descPurge .. " OR "
        end
        descPurge = descPurge .. "to have at least " .. purchases .. "k purchases"
        hasCond = true
    end

    hasCond = false
    if inactivity > 0 then
        descPurge = descPurge .. "\r\nInactivity policy of " .. inactivity .. " days. "
        hasCond = true
    end

    if ignoreRank > 0 then
        local rankName = LeoGuildManager.GetGuildRankName(guildId, LeoGuildManager.globalData.settings.guilds[guildName].ignoreRank)
        if not hasCond then
            descPurge = descPurge .. "\r\n"
        end
        descPurge = descPurge .. "Ignore members with rank equal or above " .. rankName .. "."
    end
    descPurge = descPurge .. "\r\nIgnore new members who joined the guild in less than " .. LeoGuildManager.GetNewRangeName(ignoreNew) .. "."
    return descPurge
end

local function initGuildScanData(guildName)
    if LeoGuildManager.scanData[guildName] == nil then
        LeoGuildManager.scanData[guildName] = {
            [GUILD_HISTORY_GENERAL] = {
                firstEvent = 0,
                lastEvent = 0,
                numAdded = 0,
                events = {}
            },
            [GUILD_HISTORY_BANK] = {
                firstEvent = 0,
                lastEvent = 0,
                numAdded = 0,
                events = {}
            },
            members = {}
        }
    end
    LeoGuildManager.scanData[guildName][GUILD_HISTORY_GENERAL].numAdded = 0
    LeoGuildManager.scanData[guildName][GUILD_HISTORY_BANK].numAdded = 0
end

local function initMemberScanData(guildName, displayName)
    if LeoGuildManager.scanData[guildName].members[displayName] == nil then
        LeoGuildManager.scanData[guildName].members[displayName] = {
            joined = 0,
            invited = 0,
            invitedBy = ""
        }
    end
end

local function normalizeGuilds()
    for name, data in pairs(LeoGuildManager.globalData.settings.guilds) do
        local deleted = true
        for guildId, guildName in pairs(LeoGuildManager.guilds) do
            if name == guildName then
                deleted = false
                break
            end
        end
        if deleted then
            LeoGuildManager.log("Not part of guild " .. name .. " anymore. Deleting ...")
            LeoGuildManager.globalData.settings.guilds[name] = nil
            LeoGuildManager.scanData[name] = nil
        end
    end

    for guildId, guildName in pairs(LeoGuildManager.guilds) do
        local found = false
        for name, data in pairs(LeoGuildManager.globalData.settings.guilds) do
            if name == guildName then
                found = true
                break
            end
        end
        if not found then
            LeoGuildManager.log("New guild " .. guildName .. " found. Initializing ...")
            LeoGuildManager.globalData.settings.guilds[guildName] = {
                id = guildId,
                enabled = false,
                cycle = 2,
                ignoreRank = 0,
                ignoreNew = 1,
                tickets = 0,
                sales = 0,
                purchases = 0,
                inactivity = 30,
                blacklist = {},
                tooltipRoster = false,
                keepBankHistory = 30,
                keepRosterHistory = 30
            }
        end
        if LeoGuildManager.globalData.settings.guilds[guildName].keepBankHistory == nil then
            LeoGuildManager.globalData.settings.guilds[guildName].keepBankHistory = 30
        end
        if LeoGuildManager.globalData.settings.guilds[guildName].keepRosterHistory == nil then
            LeoGuildManager.globalData.settings.guilds[guildName].keepRosterHistory = 30
        end
    end

    for _, guildName in pairs(LeoGuildManager.guilds) do
        initGuildScanData(guildName)
    end
end

function LeoGuildManager.Initialize()
    LeoGuildManager.globalData = ZO_SavedVars:NewAccountWide("LeoGuildManagerGlobalData", 2, nil, nil, GetWorldName())
    LeoGuildManager.scanData = ZO_SavedVars:NewAccountWide("LeoGuildManagerScanData", 2, nil, nil, GetWorldName())
    if not LeoGuildManager.globalData.settings or LeoGuildManager.globalData.settings == nil then
        LeoGuildManager.globalData.settings = {
            integration = LeoGuildManager.integrations[1],
            tooltipRoster = false,
            scanAutomatically = true,
            autoKick = false,
            warnOnline = true,
            guilds = {},
        }
    end
    if not LeoGuildManager.scanData then
        LeoGuildManager.scanData = {}
    end

    local LibFeedback = LibStub:GetLibrary("LibFeedback")
    local showButton, feedbackWindow = LibFeedback:initializeFeedbackWindow(LeoGuildManager,
            LeoGuildManager.name, LeoGuildManagerWindow, "@LeandroSilva",
            { TOPRIGHT, LeoGuildManagerWindow, TOPRIGHT, -50, 3 },
            { 0, 1000, 10000, "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=Y9KM4PZU2UZ6A" },
            "If you found a bug, have a request or a suggestion, or simply wish to donate, send a mail.")
    LeoGuildManager.feedback = feedbackWindow
    LeoGuildManager.feedback:SetDrawLayer(DL_OVERLAY)
    LeoGuildManager.feedback:SetDrawTier(DT_LOW)

    LeoGuildManager.GetGuilds()
    normalizeGuilds()

    LeoGuildManagerUI.InitializeUI()
    LeoGuildManagerUI.RestorePosition()

    LeoGuildManager.settings = LeoGuildManagerSettings:New()
    LeoGuildManager.settings:CreatePanel()

    SLASH_COMMANDS["/leogm"] = function(cmd)
        if cmd == "" then
            LeoGuildManagerUI:ToggleUI()
        elseif cmd == "debug" then
            if LeoGuildManager.isDebug == false then
                LeoGuildManager.isDebug = true
                LeoGuildManager.debug("Debug mode ON")
            else
                LeoGuildManager.debug("Debug mode OFF")
                LeoGuildManager.isDebug = false
            end
        end
    end
end

function LeoGuildManager.AutoKick()
    for _, guildName in pairs(LeoGuildManager.guilds) do
        local guildId = LeoGuildManager.GetGuildId(guildName)
        if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_REMOVE) and LeoGuildManager.globalData.settings.guilds[guildName].blacklist ~= nil then
            for _, userId in pairs(LeoGuildManager.globalData.settings.guilds[guildName].blacklist) do
                local numGuildMembers = GetNumGuildMembers(guildId)
                for guildMemberIndex = 1, numGuildMembers do
                    local displayName = GetGuildMemberInfo(guildId, guildMemberIndex)
                    if displayName == userId then
                        if LeoGuildManager.GetWarnOnline(guildName) then
                            LeoGuildManager.log("Found " .. userId .. " on " .. guildName)
                        end
                        if LeoGuildManager.GetAutoKick(guildName) == true then
                            LeoGuildManager.log("Kicking ...")
                            GuildRemove(guildId, userId)
                        end
                        break
                    end
                end
            end
        end
    end
end

local orig_ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter = ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter
local orig_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit = ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit

function LeoGuildManager.FormatTimeAgo(seconds)
    local ago
    if seconds < 3600 then
        ago = ZO_CachedStrFormat(GetString(SI_TIME_FORMAT_MINUTES), math.floor(seconds / 60))
    elseif seconds < 86400 then
        ago = ZO_CachedStrFormat(GetString(SI_TIME_FORMAT_HOURS), math.floor(seconds / 3600))
    else
        ago = ZO_CachedStrFormat(GetString(SI_TIME_FORMAT_DAYS), math.floor(seconds / 86400))
    end
    return ZO_CachedStrFormat(GetString(SI_TIME_DURATION_AGO), ago)
end

function ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter(control)
    orig_ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter(control)

    local guildName = GetGuildName(GUILD_SELECTOR.guildId)
    if not LeoGuildManager.UseTooltipRoster(guildName) then
        return
    end

    local parent = control:GetParent()
    local data = ZO_ScrollList_GetData(parent)
    local displayName = data.displayName
    local timeStamp = GetTimeStamp()

    local tooltip = data.characterName
    local num, str

    if (LeoGuildManager.scanData[guildName] ~= nil) then
        if (LeoGuildManager.scanData[guildName].members[displayName] ~= nil) then
            tooltip = tooltip .. "\n\n"

            if (LeoGuildManager.scanData[guildName].members[displayName].joined == 0) then
                str = LeoGuildManager.FormatTimeAgo(timeStamp - LeoGuildManager.scanData[guildName][GUILD_HISTORY_GENERAL].firstEvent)
                tooltip = tooltip .. "Joined > |cffffff" .. str .. "|r\n"
            else
                str = LeoGuildManager.FormatTimeAgo(timeStamp - LeoGuildManager.scanData[guildName].members[displayName].joined)
                tooltip = tooltip .. "Joined |cffffff" .. str .. "|r\n"
            end
            local invitedBy = LeoGuildManager.scanData[guildName].members[displayName].invitedBy
            if (invitedBy ~= "") then
                tooltip = tooltip .. "Invited by |cffffff" .. invitedBy .. "|r\n"
            end
        end
    end

    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOPCENTER)
    SetTooltipText(InformationTooltip, tooltip)
end

function ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
    ClearTooltip(InformationTooltip)

    orig_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
end

function LeoGuildManager.ProcessEvent(guildId, category, eventIndex)

    local guildName = GetGuildName(guildId)

    local eventId = GetGuildEventId(guildId, category, eventIndex)
    local eventIdNum = tonumber(Id64ToString(eventId))

    local evType, evTime, param1, param2 = GetGuildEventInfo(guildId, category, eventIndex)
    local displayName = param1
    local now = GetTimeStamp()
    local timeStamp = now - evTime

    if timeStamp < 0 then
        return false
    end

    local keepFor = LeoGuildManager.GetKeepBankHistory(guildName)
    if category == GUILD_HISTORY_BANK and keepFor > 0 and timeStamp < now - keepFor * LeoGuildManager.SECONDS_IN_DAY then
        return false
    end

    keepFor = LeoGuildManager.GetKeepRosterHistory(guildName)
    if category == GUILD_HISTORY_GENERAL and keepFor > 0 and timeStamp < now - keepFor * LeoGuildManager.SECONDS_IN_DAY then
        return false
    end

    if LeoGuildManager.scanData[guildName][category].lastEvent == 0 or
            LeoGuildManager.scanData[guildName][category].lastEvent < timeStamp then
        LeoGuildManager.scanData[guildName][category].lastEvent = timeStamp
    end
    if LeoGuildManager.scanData[guildName][category].firstEvent == 0 or
            LeoGuildManager.scanData[guildName][category].firstEvent > timeStamp then
        LeoGuildManager.scanData[guildName][category].firstEvent = timeStamp
    end

    if (category == GUILD_HISTORY_GENERAL) then
        if (evType == GUILD_EVENT_GUILD_JOIN) then
            LeoGuildManager.scanData[guildName][category].numAdded = LeoGuildManager.scanData[guildName][category].numAdded + 1
            initMemberScanData(guildName, displayName)
            LeoGuildManager.scanData[guildName].members[displayName].joined = timeStamp
            LeoGuildManager.debug("Added guild event (".. displayName .. " joined) for guild " .. GetGuildName(guildId) .. " from " .. LeoGuildManager.TimeAgo(timeStamp))
        elseif (evType == GUILD_EVENT_GUILD_INVITE) then
            LeoGuildManager.scanData[guildName][category].numAdded = LeoGuildManager.scanData[guildName][category].numAdded + 1
            initMemberScanData(guildName, param2)
            LeoGuildManager.scanData[guildName].members[param2].invited = timeStamp
            LeoGuildManager.scanData[guildName].members[param2].invitedBy = param1
            LeoGuildManager.debug("Added guild event (".. param2 .. " invited by " .. param1 .. ") for guild " .. GetGuildName(guildId) .. " from " .. LeoGuildManager.TimeAgo(timeStamp))
        end
    end

    if category == GUILD_HISTORY_BANK and (evType == GUILD_EVENT_BANKGOLD_ADDED or evType == GUILD_EVENT_BANKGOLD_REMOVED) and
            eventIdNum ~= 0 then
        if LeoGuildManager.scanData[guildName][category].events[eventIdNum] == nil then
            LeoGuildManager.scanData[guildName][category].events[eventIdNum] = {
                type = evType,
                timeStamp = timeStamp,
                member = displayName,
                gold = param2
            }
        end

        LeoGuildManager.scanData[guildName][category].numAdded = LeoGuildManager.scanData[guildName][category].numAdded + 1

        if evType == GUILD_EVENT_BANKGOLD_ADDED then
            LeoGuildManager.debug("Added bank event (".. displayName .. " deposited " .. param2 .. " gold) for guild " .. GetGuildName(guildId) .. " from " .. LeoGuildManager.TimeAgo(timeStamp))
        elseif evType == GUILD_EVENT_BANKGOLD_REMOVED then
            LeoGuildManager.debug("Added bank event (".. displayName .. " withdrew " .. param2 .. " gold) for guild " .. GetGuildName(guildId) .. " from " .. LeoGuildManager.TimeAgo(timeStamp))
        end
    end

    return true
end

local function onGuildHistoryResponseReceived(eventCode, guildId, category)
    if (category ~= GUILD_HISTORY_GENERAL) and (category ~= GUILD_HISTORY_BANK) then
        return
    end

    LeoGuildManager.lastScannedEvent[guildId] = LeoGuildManager.lastScannedEvent[guildId] or 1

    local guildName = GetGuildName(guildId)
    initGuildScanData(guildName)

    local numEvents = GetNumGuildEvents(guildId, category)
    if numEvents > 0 then
        LeoGuildManager.debug("Handling " .. numEvents .. " events for guild " .. GetGuildName(guildId))
    else
        -- LeoGuildManager.log("No events for guild " .. guildName)
        return
    end

    LeoGuildManager.scanData[guildName][GUILD_HISTORY_GENERAL].numAdded = 0
    LeoGuildManager.scanData[guildName][GUILD_HISTORY_BANK].numAdded = 0

    for i = LeoGuildManager.lastScannedEvent[guildId], numEvents do
        LeoGuildManager.ProcessEvent(guildId, category, i)
    end

    local guildEvents = LeoGuildManager.scanData[guildName][GUILD_HISTORY_GENERAL].numAdded or 0
    local bankEvents = LeoGuildManager.scanData[guildName][GUILD_HISTORY_BANK].numAdded or 0
    if guildEvents > 0 then
        LeoGuildManager.debug("Added " .. guildEvents .. " guild events for guild " .. guildName)
    end
    if bankEvents > 0 then
        LeoGuildManager.debug("Added " .. bankEvents .. " bank events for guild " .. guildName)
    end

    LeoGuildManager.lastScannedEvent[guildId] = numEvents + 1
end

function LeoGuildManager.HasIntegrationAddonsLoaded(integration)
    if integration == 1 then
        return MasterMerchant ~= nil and MasterMerchant.guildSales ~= nil
    elseif integration == 2 then
        return ArkadiusTradeTools ~= nil and ArkadiusTradeTools.Modules ~= nil and ArkadiusTradeTools.Modules.Sales ~= nil
    else
        return (LeoGuildManager.globalData.settings.integration == LeoGuildManager.integrations[2] and
                LeoGuildManager.HasIntegrationAddonsLoaded(2))
                or
                (LeoGuildManager.globalData.settings.integration == LeoGuildManager.integrations[1] and
                        LeoGuildManager.HasIntegrationAddonsLoaded(1))
    end
end

function LeoGuildManager.GuildNeedsScan(guildId)
    local guildName = GetGuildName(guildId)
    return LeoGuildManager.globalData.settings.guilds[guildName].enabled and
            (LeoGuildManager.CanScanBankHistory(guildId) or LeoGuildManager.UseTooltipRoster(guildName))
end

function LeoGuildManager.CanScanBankHistory(guildId)
    local guildName = GetGuildName(guildId)
    return LeoGuildManager.globalData.settings.guilds[guildName].enabled and
            DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_VIEW_GOLD)
end

function LeoGuildManager.StartScanGuilds()
    if LeoGuildManager.isScanning == true then
        return
    end

    LeoGuildManager.isScanning = true

    LeoGuildManager.ScanGuilds()
end

function LeoGuildManager.FinishScanGuilds()
    LeoGuildManager.isScanning = false
    zo_callLater(LeoGuildManager.ScanGuilds, scanInterval)
end

function LeoGuildManager.ScanGuilds()
    if LeoGuildManager.inCombat then
        zo_callLater(LeoGuildManager.ScanGuilds, 10000)
        return
    end

    local numGuilds = GetNumGuilds()
    local guildId

    for i = 1, numGuilds do
        guildId = GetGuildId(i)

        if LeoGuildManager.GuildNeedsScan(guildId) then
            -- local guildName = GetGuildName(guildId)

            -- if not HasGuildHistoryCategoryEverBeenRequested(guildId, GUILD_HISTORY_GENERAL) then
                -- LeoGuildManager.debug("Starting scan for general events on " .. guildName .. " ...")
                RequestMoreGuildHistoryCategoryEvents(guildId, GUILD_HISTORY_GENERAL)
            -- end

            if LeoGuildManager.CanScanBankHistory(guildId) then
                -- if not HasGuildHistoryCategoryEverBeenRequested(guildId, GUILD_HISTORY_BANK) then
                    -- LeoGuildManager.debug("Starting scan for bank events on " .. guildName .. " ...")
                    RequestMoreGuildHistoryCategoryEvents(guildId, GUILD_HISTORY_BANK)
                -- end
            end
        end
    end

    LeoGuildManager.nextGuildScan = 1

    zo_callLater(LeoGuildManager.ScanGuilds, 10000)
end

function LeoGuildManager:DeleteOldData()
    local numGuilds = GetNumGuilds()
    for i = 1, numGuilds do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        local old = LeoGuildManager.GetKeepRosterHistory(guildName) * LeoGuildManager.SECONDS_IN_DAY

        if old > 0 then
            local oldTimeStamp = GetTimeStamp() - old
            for name, memberTable in pairs(LeoGuildManager.scanData[guildName].members) do
                if memberTable.joined ~= nil and memberTable.joined < oldTimeStamp then
                    LeoGuildManager.scanData[guildName].members[name] = nil
                end
                if memberTable.invited ~= nil and memberTable.invited < oldTimeStamp then
                    LeoGuildManager.scanData[guildName].members[name] = nil
                end
            end

        end

        old = LeoGuildManager.GetKeepBankHistory(guildName) * LeoGuildManager.SECONDS_IN_DAY

        if old > 0 then
            local oldTimeStamp = GetTimeStamp() - old
            for index, event in pairs(LeoGuildManager.scanData[guildName][GUILD_HISTORY_BANK].events) do
                if event.timeStamp ~= nil and event.timeStamp < oldTimeStamp then
                    LeoGuildManager.scanData[guildName][GUILD_HISTORY_BANK].events[index] = nil
                end
            end
        end
    end
end

function LeoGuildManager.onReadMail(eventCode, mailId)
    local senderDisplayName, senderCharacterName, subject, icon, unread, fromSystem, fromCustomerService,
    returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived = GetMailItemInfo(mailId)

    --if fromSystem or not numAttachments or numAttachments <= 0 or fromCustomerService then return end
    local sender = GetMailSender(mailId)
    local message = ZO_MailInboxMessageBody:GetText()
    LeoGuildManager.log(sender)
    LeoGuildManager.log(message)
end

function LeoGuildManager:OnUpdate()
    LeoGuildManager.AutoKick()
end

local function onSettingsControlsCreated(panel)
    LeoGuildManagerSettings:OnSettingsControlsCreated(panel)
end

local function onNewMovementInUIMode(eventCode)
    if not LeoGuildManagerWindow:IsHidden() then
        LeoGuildManagerUI:CloseUI()
    end
end

local function onChampionPerksSceneStateChange(oldState, newState)
    if newState == SCENE_SHOWING then
        if not LeoGuildManagerWindow:IsHidden() then
            LeoGuildManagerUI:CloseUI()
        end
    end
end

local function onCombatState(eventCode, inCombat)
    LeoGuildManager.inCombat = inCombat
end

local function onPlayerActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(LeoGuildManager.name, eventCode)
    zo_callLater(function()
        LeoGuildManager.StartScanGuilds()
    end, 5000)
end

local function OnPlayerDeactivated()
    LeoGuildManager:DeleteOldData()
end

local function onReadMail()
    LeoGuildManager.onReadMail()
end

function LeoGuildManager.OnAddOnLoaded(event, addonName)
    if addonName == LeoGuildManager.name then
        EVENT_MANAGER:UnregisterForEvent(LeoGuildManager.Name, EVENT_ADD_ON_LOADED)
        SCENE_MANAGER:RegisterTopLevel(LeoGuildManagerWindow, false)

        LeoGuildManager.Initialize()

        EVENT_MANAGER:RegisterForUpdate(LeoGuildManager.name, 60000, function()
            LeoGuildManager.OnUpdate()
        end)
        EVENT_MANAGER:RegisterForEvent(LeoGuildManager.name, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
        EVENT_MANAGER:RegisterForEvent(LeoGuildManager.name, EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", onSettingsControlsCreated)
        EVENT_MANAGER:RegisterForEvent(LeoGuildManager.name, EVENT_NEW_MOVEMENT_IN_UI_MODE, onNewMovementInUIMode)
        CHAMPION_PERKS_SCENE:RegisterCallback('StateChange', onChampionPerksSceneStateChange)
        EVENT_MANAGER:RegisterForEvent(LeoGuildManager.name, EVENT_PLAYER_COMBAT_STATE, onCombatState)
        EVENT_MANAGER:RegisterForEvent(LeoGuildManager.name, EVENT_GUILD_HISTORY_RESPONSE_RECEIVED, onGuildHistoryResponseReceived)
        -- EVENT_MANAGER:RegisterForEvent(LeoGuildManager.name, EVENT_MAIL_READABLE, onReadMail)
        LeoGuildManager.log("started.")
    end
end

EVENT_MANAGER:RegisterForEvent(LeoGuildManager.name, EVENT_ADD_ON_LOADED, LeoGuildManager.OnAddOnLoaded)
