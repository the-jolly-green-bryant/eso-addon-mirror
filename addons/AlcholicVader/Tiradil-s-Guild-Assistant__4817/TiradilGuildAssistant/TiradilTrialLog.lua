TiradilTrialLog = {}
local TTL = TiradilTrialLog

local CHAT_PREFIX = "TGATRIAL1"

local KNOWN_TRIAL_ZONES = {
    ["Aetherian Archive"] = true,
    ["Hel Ra Citadel"] = true,
    ["Sanctum Ophidia"] = true,
    ["Maw of Lorkhaj"] = true,
    ["Halls of Fabrication"] = true,
    ["Asylum Sanctorium"] = true,
    ["Cloudrest"] = true,
    ["Sunspire"] = true,
    ["Kyne's Aegis"] = true,
    ["Rockgrove"] = true,
    ["Dreadsail Reef"] = true,
    ["Sanity's Edge"] = true,
    ["Lucent Citadel"] = true,
    ["Ossein Cage"] = true,
}

function TTL.ToggleWindow()
    if TiradilTrialLogFrame:IsHidden() then
        TiradilTrialLogFrame:SetHidden(false)
        TTL.RefreshDisplay()
    else
        TiradilTrialLogFrame:SetHidden(true)
    end
end

local TEXT_ROW_TYPE = 1
local TEXT_ROW_HEIGHT = 20

local function SetupTextRow(control, data)
    control:GetNamedChild("Label"):SetText(data.text)
end

local function InitializeList(listControl)
    if not listControl then return end
    ZO_ScrollList_AddDataType(listControl, TEXT_ROW_TYPE, "GuildLedgerTextRowTemplate", TEXT_ROW_HEIGHT, SetupTextRow)
end

local function PopulateList(listControl, lines)
    if not listControl then return end
    local dataList = ZO_ScrollList_GetDataList(listControl)
    for i = #dataList, 1, -1 do
        dataList[i] = nil
    end
    for i = 1, #lines do
        table.insert(dataList, ZO_ScrollList_CreateDataEntry(TEXT_ROW_TYPE, { text = lines[i] }))
    end
    ZO_ScrollList_Commit(listControl)
end

local function GetCurrentGroupMembers()
    local members = {}
    local groupSize = GetGroupSize()
    if groupSize == 0 then
        table.insert(members, GetDisplayName())
        return members
    end
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            local name = GetUnitDisplayName(unitTag)
            if name and name ~= "" then
                table.insert(members, name)
            end
        end
    end
    return members
end

function TTL.LogCurrentGroup()
    local zoneName = GetPlayerActiveZoneName() or "?"
    local members = GetCurrentGroupMembers()
    local entry = {
        zone = zoneName,
        time = GetTimeStamp(),
        members = members,
        source = GetDisplayName(),
    }
    table.insert(TiradilTrialLog_SavedVars.entries, 1, entry)
    TTL.RefreshDisplay()
end

local TRIALLOG_CONFIRM_DIALOG = "TIRADIL_TRIALLOG_CONFIRM_ZONE"

local function GetZoneConfirmDialog()
    if not ESO_Dialogs[TRIALLOG_CONFIRM_DIALOG] then
        ESO_Dialogs[TRIALLOG_CONFIRM_DIALOG] = {
            canQueue = true,
            title = { text = "" },
            mainText = { text = "" },
            buttons = {
                [1] = { text = SI_DIALOG_CONFIRM, callback = function(dialog) end },
                [2] = { text = SI_DIALOG_CANCEL },
            },
        }
    end
    return ESO_Dialogs[TRIALLOG_CONFIRM_DIALOG]
end

function TTL.OnPlayerActivated()
    local zoneName = GetPlayerActiveZoneName()
    if not (zoneName and KNOWN_TRIAL_ZONES[zoneName]) then return end
    if TTL.lastPromptedZone == zoneName then return end
    TTL.lastPromptedZone = zoneName

    local dialog = GetZoneConfirmDialog()
    dialog.title.text = TiradilL10n.Get("TRIALLOG_ZONE_DETECTED_TITLE")
    dialog.mainText.text = zo_strformat(TiradilL10n.Get("TRIALLOG_ZONE_DETECTED_TEXT"), zoneName)
    dialog.buttons[1].callback = function()
        TTL.LogCurrentGroup()
    end
    ZO_Dialogs_ShowDialog(TRIALLOG_CONFIRM_DIALOG)
end

local function EncodeEntry(entry)
    return string.format("%s|%s|%d|%s", CHAT_PREFIX, entry.zone, entry.time, table.concat(entry.members, ";"))
end

local function DecodeMessage(text)
    if not (text and text:sub(1, #CHAT_PREFIX) == CHAT_PREFIX) then return nil end
    local zone, timeStr, memberStr = text:match("^" .. CHAT_PREFIX .. "|([^|]*)|(%d+)|(.*)$")
    if not (zone and timeStr and memberStr) then return nil end
    local members = {}
    for name in string.gmatch(memberStr, "([^;]+)") do
        table.insert(members, name)
    end
    return {
        zone = zone,
        time = tonumber(timeStr),
        members = members,
    }
end

function TTL.ShareLatestToOfficerChat()
    local entries = TiradilTrialLog_SavedVars.entries
    if #entries == 0 then
        d("|cFF6B6B[Tiradil's Guild Assistant]|r " .. TiradilL10n.Get("TRIALLOG_NO_ENTRY_TO_SHARE"))
        return
    end

    local guildIndex = TTL.selectedGuildIndex or 1
    local officerChannel = _G["CHAT_CHANNEL_OFFICER_" .. tostring(guildIndex)]
    if not officerChannel then
        d("|cFF6B6B[Tiradil's Guild Assistant]|r " .. TiradilL10n.Get("TRIALLOG_NO_OFFICER_CHANNEL"))
        return
    end

    local encoded = EncodeEntry(entries[1])
    StartChatInput(encoded, officerChannel)
end

function TTL.OnChatMessage(eventCode, channel, fromDisplayName, text)
    local isOfficerChannel = false
    for i = 1, 5 do
        if channel == _G["CHAT_CHANNEL_OFFICER_" .. i] then
            isOfficerChannel = true
            break
        end
    end
    if not isOfficerChannel then return end

    local decoded = DecodeMessage(text)
    if not decoded then return end

    local dedupeKey = (fromDisplayName or "?") .. "|" .. tostring(decoded.time)
    TiradilTrialLog_SavedVars.seenKeys = TiradilTrialLog_SavedVars.seenKeys or {}
    if TiradilTrialLog_SavedVars.seenKeys[dedupeKey] then return end
    TiradilTrialLog_SavedVars.seenKeys[dedupeKey] = true

    table.insert(TiradilTrialLog_SavedVars.entries, 1, {
        zone = decoded.zone,
        time = decoded.time,
        members = decoded.members,
        source = fromDisplayName,
    })

    if TiradilTrialLogFrame and not TiradilTrialLogFrame:IsHidden() then
        TTL.RefreshDisplay()
    end
end

function TTL.RefreshDisplay()
    if not (TiradilTrialLogFrame and not TiradilTrialLogFrame:IsHidden()) then return end

    local lines = {}
    local entries = TiradilTrialLog_SavedVars.entries
    for i = 1, math.min(#entries, 60) do
        local e = entries[i]
        local dateStr = os.date("%d.%m.%y %H:%M", e.time)
        local memberCount = #e.members
        table.insert(lines, string.format("|cFFB800%s|r  %s  |cA0A0A0(%d %s, %s)|r",
            dateStr, e.zone, memberCount, TiradilL10n.Get("TRIALLOG_MEMBERS_SUFFIX"), e.source or "?"))
    end

    PopulateList(TiradilTrialLogFrameBodyList, lines)
    TiradilTrialLogFrameBodyNone:SetText(#lines == 0 and TiradilL10n.Get("TRIALLOG_NONE") or "")
    TiradilTrialLogFrameFooterStatus:SetText(string.format(TiradilL10n.Get("TRIALLOG_STATUS_COUNT"), #entries))
end

local function GetGuildChoices()
    local choices = {}
    local numGuilds = GetNumGuilds()
    for i = 1, numGuilds do
        local guildId = GetGuildId(i)
        if guildId and guildId ~= 0 then
            table.insert(choices, GetGuildName(guildId))
        end
    end
    if #choices == 0 then
        table.insert(choices, "-")
    end
    return choices
end

function TTL.Initialize()
    TiradilTrialLog_SavedVars = TiradilTrialLog_SavedVars or {}
    TiradilTrialLog_SavedVars.entries = TiradilTrialLog_SavedVars.entries or {}
    TiradilTrialLog_SavedVars.seenKeys = TiradilTrialLog_SavedVars.seenKeys or {}
    TTL.selectedGuildIndex = 1

    InitializeList(TiradilTrialLogFrameBodyList)

    local combo = TiradilTrialLogFrameFilterAreaGuildCombo
    if combo then
        local comboObj = ZO_ComboBox_ObjectFromContainer(combo)
        comboObj:SetSortsItems(false)
        local choices = GetGuildChoices()
        for i, name in ipairs(choices) do
            local entry = comboObj:CreateItemEntry(name, function()
                TTL.selectedGuildIndex = i
            end)
            comboObj:AddItem(entry)
        end
        comboObj:SelectFirstItem()
    end

    EVENT_MANAGER:RegisterForEvent("TiradilTrialLog", EVENT_CHAT_MESSAGE_CHANNEL, TTL.OnChatMessage)
    EVENT_MANAGER:RegisterForEvent("TiradilTrialLog", EVENT_PLAYER_ACTIVATED, TTL.OnPlayerActivated)
end
