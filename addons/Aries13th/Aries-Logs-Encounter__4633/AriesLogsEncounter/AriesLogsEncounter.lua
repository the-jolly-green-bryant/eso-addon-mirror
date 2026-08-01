AriesLogsEncounter = AriesLogsEncounter or {}
local ALE = AriesLogsEncounter
ALE.name = "AriesLogsEncounter"
ALE.author = "Aries13th"
ALE.version = "1.0.1"
ALE.trials = {
    [636] = true,
    [638] = true,
    [639] = true,
    [725] = true,
    [975] = true,
    [1000] = true,
    [1051] = true,
    [1121] = true,
    [1196] = true,
    [1263] = true,
    [1344] = true,
    [1427] = true,
    [1478] = true,
    [1548] = true,
}
ALE.dungeons = {
    [11] = true,
    [22] = true,
    [31] = true,
    [38] = true,
    [63] = true,
    [64] = true,
    [126] = true,
    [130] = true,
    [131] = true,
    [144] = true,
    [146] = true,
    [148] = true,
    [176] = true,
    [283] = true,
    [380] = true,
    [449] = true,
    [678] = true,
    [681] = true,
    [688] = true,
    [843] = true,
    [848] = true,
    [930] = true,
    [931] = true,
    [932] = true,
    [933] = true,
    [934] = true,
    [935] = true,
    [936] = true,
    [973] = true,
    [974] = true,
    [1009] = true,
    [1010] = true,
    [1052] = true,
    [1055] = true,
    [1080] = true,
    [1081] = true,
    [1122] = true,
    [1123] = true,
    [1152] = true,
    [1153] = true,
    [1197] = true,
    [1201] = true,
    [1228] = true,
    [1229] = true,
    [1267] = true,
    [1268] = true,
    [1301] = true,
    [1302] = true,
    [1360] = true,
    [1360] = true,
    [1389] = true,
    [1390] = true,
    [1470] = true,
    [1471] = true,
    [1496] = true,
    [1497] = true,
    [1551] = true,
    [1552] = true,
}
ALE.settings = {
    unlockStatus = false,
    unlockReminer = false,
    onRT = false,
    skipTime = 60 * 60 * 2,
    maxTimeToClosestRaid = 60 * 60,
    weekdays = {
        GetString(SI_NAME__ALE__WEEKDAY1),
        GetString(SI_NAME__ALE__WEEKDAY2),
        GetString(SI_NAME__ALE__WEEKDAY3),
        GetString(SI_NAME__ALE__WEEKDAY4),
        GetString(SI_NAME__ALE__WEEKDAY5),
        GetString(SI_NAME__ALE__WEEKDAY6),
        GetString(SI_NAME__ALE__WEEKDAY7),
    }
}


local baseD = d
local function d(msg)
    if (ALE.savedVars.showDebug) then
        baseD("ALE: " .. tostring(msg))
    end
end

function ALE.ReloadUI()
    ReloadUI()
end

function ALE.OnPanelMoveStop()
    ALE.savedVars.panelLeft = ALE_REMINDER_WINDOW:GetLeft()
    ALE.savedVars.panelTop = ALE_REMINDER_WINDOW:GetTop()
end

function ALE.OnLogsStatusUpdate()
    ALE.savedVars.statusLeft = ALE_REMINDER_LOGS_STATUS_WINDOW:GetLeft()
    ALE.savedVars.statusTop = ALE_REMINDER_LOGS_STATUS_WINDOW:GetTop()
    ALE.savedVars.statusWidth = ALE_REMINDER_LOGS_STATUS_WINDOW:GetWidth()
    ALE.savedVars.statusHeight = ALE_REMINDER_LOGS_STATUS_WINDOW:GetHeight()
end

function ALE.GetWeekDay()
    local result = tonumber(os.date("%w", GetTimeStamp()))
    if result == 0 then
        result = 7
    end
    return result
end

function ALE.GetSecondsFromDayStart()
    local t = os.date("*t")
    return t.hour * 3600 + t.min * 60 + t.sec
end

function ALE.OnZoneRemove(zoneId)
    ZO_Dialogs_ShowDialog(
        "ALE_CONFIRM_DIALOG",
        {
            title = string.format(
                GetString(SI_NAME__ALE__DIALOG_REMOVE_TITLE),
                ALE.savedVars.zones[tostring(zoneId)]
            ),
            text = GetString(SI_NAME__ALE__DIALOG_REMOVE_TEXT),
            onConfirm = function()
                ALE.savedVars.zones[tostring(zoneId)] = nil
                ALE.Menu.UpdateZonesList()
                ALE.OnPlayerActivated()
            end,
        }
    )
end

function ALE.OnZoneAdd()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if ALE.savedVars.zones[tostring(zoneId)] == nil then
        ALE.savedVars.zones[tostring(zoneId)] = GetZoneNameById(zoneId)
        ALE.OnPlayerActivated()
    end
end

function ALE.OnZonesAddDungeons()
    for zoneId, v in pairs(ALE.dungeons) do
        ALE.savedVars.zones[tostring(zoneId)] = GetZoneNameById(zoneId)
    end
    ALE.Menu.UpdateZonesList()
    ALE.OnPlayerActivated()
end

function ALE.OnZonesReset()
    ZO_Dialogs_ShowDialog(
        "ALE_CONFIRM_DIALOG",
        {
            title = GetString(SI_NAME__ALE__DIALOG_RESET_TITLE),
            text = GetString(SI_NAME__ALE__DIALOG_RESET_TEXT),
            onConfirm = function()
                local trials = {}
                for zoneId, v in pairs(ALE.trials) do
                    trials[tostring(zoneId)] = GetZoneNameById(zoneId)
                end
                ALE.savedVars.zones = trials
                ALE.Menu.UpdateZonesList()
                ALE.OnPlayerActivated()
            end,
        }
    )
end

function ALE.Skip()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    ALE.savedVars.skip[zoneId] = GetTimeStamp() + ALE.settings.skipTime
    ALE.OnPlayerActivated()
end

function ALE.UpdateSkipValues()
    for k, v in pairs(ALE.savedVars.skip) do
        if (v < GetTimeStamp()) then
            ALE.savedVars.skip[k] = nil
        end
    end
end

function ALE.GetClosestRaidSecondsLeft()
    local SECONDS_IN_DAY = 24 * 60 * 60
    local SECONDS_IN_WEEK = 7 * SECONDS_IN_DAY

    local now = ALE.GetSecondsFromDayStart() + (ALE.GetWeekDay() - 1) * SECONDS_IN_DAY

    local result = SECONDS_IN_WEEK * 2
    for i, rt in pairs(ALE.savedVars.RT) do
        rtStart = ((rt.weekday - 1) * SECONDS_IN_DAY + rt.startTime - 300) % SECONDS_IN_WEEK
        rtEnd = (rtStart + (rt.duration * 60 * 60) + 600) % SECONDS_IN_WEEK
        if rtStart < rtEnd then
            if (rtStart <= now) and (now <= rtEnd) then
                result = 0
            else
                result = math.min(result, ((rtStart + SECONDS_IN_WEEK - now) % SECONDS_IN_WEEK))
            end
        else
            if (now <= rtEnd) or (rtStart <= now) then
                result = 0
            else
                result = math.min(result, (rtStart - now))
            end
        end
    end
    return result
end

local function ShowSkipLogsDialog()
    ZO_Dialogs_ShowDialog(
        "ALE_CONFIRM_LOGS_DIALOG",
        {
            title = GetString(SI_NAME__ALE__DIALOG_ENCOUNTERLOGS_TITLE),
            text = GetString(SI_NAME__ALE__DIALOG_ENCOUNTERLOGS_BTN_CANCEL_LONG),
            btn1 = GetString(SI_NAME__ALE__DIALOG_ENCOUNTERLOGS_BTN_OK),
            btn2 = GetString(SI_NAME__ALE__DIALOG_ENCOUNTERLOGS_BTN_CANCEL),
            onConfirm = function()
                ALE.Skip()
            end,
            onCancel = function()
                ALE.savedVars.disableForLastZone = true
            end,
        }
    )
end

function ALE.LogsShouldBeStarted()
    local autoStart =  ALE.savedVars.autoStart
    local showReminder =  ALE.savedVars.showReminder
    local showDialog =  ALE.savedVars.showDialog
    if ALE.settings.onRT == true then
        autoStart =  ALE.savedVars.autoStartRT
        showReminder =  ALE.savedVars.showReminderRT
        showDialog =  ALE.savedVars.showDialogRT
    end

    if (autoStart) then
        SetEncounterLogEnabled(true)
        baseD(GetString(SI_NAME__ALE__ENCOUNTERLOG_ENABLED))
    elseif (showReminder) then
        ALE_REMINDER_WINDOW:SetHidden(false)
    elseif (showDialog) then
        ZO_Dialogs_ShowDialog(
            "ALE_CONFIRM_LOGS_DIALOG",
            {
                title = GetString(SI_NAME__ALE__DIALOG_ENCOUNTERLOGS_TITLE),
                text = GetString(SI_NAME__ALE__DIALOG_ENCOUNTERLOGS_TEXT),
                btn1 = GetString(SI_NAME__ALE__DIALOG_ENCOUNTERLOGS_BTN_OK),
                btn2 = GetString(SI_NAME__ALE__DIALOG_ENCOUNTERLOGS_BTN_CANCEL),
                onConfirm = function()
                    SetEncounterLogEnabled(true)
                end,
                onCancel = function()
                    zo_callLater(ShowSkipLogsDialog, 10)
                end,
            }
        )
    end
end

function ALE.OnPlayerActivated(event)
    if ALE.settings.unlockReminer then
        ALE_REMINDER_WINDOW:SetHidden(false)
        ALE_REMINDER_WINDOW:SetMovable(true)
    else
        ALE_REMINDER_WINDOW:SetHidden(true)
        ALE_REMINDER_WINDOW:SetMovable(false)
    end
    ALE.UpdateStatusPanel()

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local ignoreLogsStart = false
    if ALE.savedVars.disableForLastZone and (ALE.savedVars.lastZone == zoneId) then
        ignoreLogsStart = true
    else
        ALE.savedVars.disableForLastZone = false
    end
    ALE.savedVars.lastZone = zoneId

    ALE.UpdateSkipValues()

    local skipNormal = ALE.savedVars.skipNormal
    local autoStop = ALE.savedVars.autoStop
    local showStatus = ALE.savedVars.showStatus

    local secondsToRaid = ALE.settings.maxTimeToClosestRaid * 2
    if (ALE.savedVars.onlyOnRT == true) then
        secondsToRaid = ALE.GetClosestRaidSecondsLeft()
    end
    if (secondsToRaid == 0) or (secondsToRaid == nil) then
        if ALE.settings.onRT == false then
            ALE.settings.onRT = true
            ignoreLogsStart = false
        end
        skipNormal = ALE.savedVars.skipNormalRT
        autoStop = ALE.savedVars.autoStopRT
        if ALE.savedVars.autoStopRT and ALE.savedVars.autoStopRTWhenEnds then
            autoStop = false
        end
        showStatus = ALE.savedVars.showStatusRT
    else
        if ALE.settings.onRT == true then
            ALE.settings.onRT = false
            if ALE.savedVars.autoStopRT and ALE.savedVars.autoStopRTWhenEnds then
                ALE.savedVars.stopLogsOnLocChange = true
            end
        end
        if secondsToRaid < ALE.settings.maxTimeToClosestRaid then
            zo_callLater(ALE.OnPlayerActivated, (secondsToRaid + 5) * 1000)
        end
    end

    if (ALE.savedVars.zones[tostring(zoneId)]) then
        if ((ALE.trials[zoneId] == nil) or (GetCurrentZoneDungeonDifficulty() == 2) or (not skipNormal)) then
            if (ALE.savedVars.skip[zoneId] == nil) then
                if (showStatus) then
                    ALE_REMINDER_LOGS_STATUS_WINDOW:SetHidden(false)
                end
                if (ALE.savedVars.doNothing == false) or (ALE.settings.onRT == true) then
                    if (IsEncounterLogEnabled() == false) and (ignoreLogsStart == false) then
                        ALE.LogsShouldBeStarted()
                    end
                end
            end
        end
    else
        if IsEncounterLogEnabled() == true then
            if ALE.savedVars.stopLogsOnLocChange == true then
                SetEncounterLogEnabled(false)
                baseD(GetString(SI_NAME__ALE__ENCOUNTERLOG_DISABLED))
            end else if autoStop then
                if ignoreLogsStart == false then
                    SetEncounterLogEnabled(false)
                    baseD(GetString(SI_NAME__ALE__ENCOUNTERLOG_DISABLED))
                end
            end
        end
        ALE.savedVars.stopLogsOnLocChange = false
    end
end

function ALE.UpdateStatusPanel()
    local icoPath = "/AriesLogsEncounter/logs_off.dds"
    if IsEncounterLogEnabled() then
        icoPath = "/AriesLogsEncounter/logs_on.dds"
    end
    ALE_REMINDER_LOGS_STATUS_WINDOW_ICON:SetTexture(icoPath)
    if ALE.settings.unlockStatus then
        ALE_REMINDER_LOGS_STATUS_WINDOW:SetHidden(false)
        ALE_REMINDER_LOGS_STATUS_WINDOW:SetMovable(true)
        ALE_REMINDER_LOGS_STATUS_WINDOW:SetResizeHandleSize(8)
    else
        ALE_REMINDER_LOGS_STATUS_WINDOW:SetHidden(true)
        ALE_REMINDER_LOGS_STATUS_WINDOW:SetMovable(false)
        ALE_REMINDER_LOGS_STATUS_WINDOW:SetResizeHandleSize(0)
    end
end

function ALE.OnMessage(_, message)
    if (message == GetString(SI_NAME__ALE__ENCOUNTERLOG_DISABLED)) or (message == GetString(SI_NAME__ALE__ENCOUNTERLOG_ENABLED)) then
        zo_callLater(ALE.OnPlayerActivated, 100)
    end
end

function ALE.EncounterLog()
    if IsEncounterLogEnabled() then
        baseD(GetString(SI_NAME__ALE__ENCOUNTERLOG_DISABLED))
        SetEncounterLogEnabled(false)
    else
        baseD(GetString(SI_NAME__ALE__ENCOUNTERLOG_ENABLED))
        SetEncounterLogEnabled(true)
    end
end

function ALE:Initialize()
    local defaultSavedVars = {
        lastZone = 0,
        disableForLastZone = false,
        avgReload = 5,
        delta = 5,
        calculatedAvgReload = 0,
        countRecords = 0,
        zones = nil,
        panelLeft = -1,
        panelTop = -1,
        skip = {},
        autoStart = false,
        autoStop = false,
        showReminder = false,
        showDialog = true,
        doNothing = false,
        showDebug = false,
        skipNormal = true,
        onlyOnRT = false,
        RT = {},
        autoStartRT = false,
        showDialogRT = true,
        showReminderRT = false,
        skipNormalRT = true,
        autoStopRT = false,
        autoStopRTWhenEnds = false,
        statusLeft = nil,
        statusTop = nil,
        statusWidth = nil,
        statusHeight = nil,
        showStatus = false,
        showStatusRT = false,
        stopLogsOnLocChange = false,
    }
    local savedVarsOutdated = ZO_SavedVars:NewAccountWide(
        "AriesLogsEncounterSavedVariables",
        1,
        nil,
        defaultSavedVars
    )
    self.savedVars = ZO_SavedVars:NewAccountWide(
        "AriesLogsEncounterSavedVariables",
        1,
        nil,
        {},
        GetWorldName(),
        "AddonSettings"
    )
    for k, _ in pairs(defaultSavedVars) do
        if self.savedVars[k] == nil then
            self.savedVars[k] = savedVarsOutdated[k]
        end
    end
    if self.savedVars.zones == nil then
        local trials = {}
        for zoneId, v in pairs(ALE.trials) do
            trials[tostring(zoneId)] = GetZoneNameById(zoneId)
        end
        self.savedVars.zones = trials
    end
    ALE.Menu.AddonMenu()
    ALE_REMINDER_WINDOW:ClearAnchors()
    if (self.savedVars.panelLeft == -1) and (self.savedVars.panelTop == -1) then
        ALE_REMINDER_WINDOW:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    else
        ALE_REMINDER_WINDOW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.savedVars.panelLeft, self.savedVars.panelTop)
    end
    if (self.savedVars.statusLeft ~= nil) then
        ALE_REMINDER_LOGS_STATUS_WINDOW:ClearAnchors()
        ALE_REMINDER_LOGS_STATUS_WINDOW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.savedVars.statusLeft, self.savedVars.statusTop)
        ALE_REMINDER_LOGS_STATUS_WINDOW:SetWidth(self.savedVars.statusWidth)
        ALE_REMINDER_LOGS_STATUS_WINDOW:SetHeight(self.savedVars.statusHeight)
    end
    EVENT_MANAGER:RegisterForEvent(ALE.name, EVENT_PLAYER_ACTIVATED, ALE.OnPlayerActivated)

    ZO_Dialogs_RegisterCustomDialog(
        "ALE_CONFIRM_DIALOG",
        {
            title = {
                text = function(dialog)
                    return dialog.data.title
                end,
            },
            mainText = {
                text = function(dialog)
                    return dialog.data.text
                end,
            },
            buttons = {
                {
                    text = SI_DIALOG_CONFIRM,
                    callback = function(dialog)
                        dialog.data.onConfirm()
                    end,
                },
                {
                    text = SI_DIALOG_CANCEL,
                    callback = function(dialog)
                        if dialog.data.onCancel then
                            dialog.data.onCancel()
                        end
                    end,
                },
            },
        }
    )
    ZO_Dialogs_RegisterCustomDialog(
        "ALE_CONFIRM_LOGS_DIALOG",
        {
            title = {
                text = function(dialog)
                    return dialog.data.title
                end,
            },
            mainText = {
                text = function(dialog)
                    return dialog.data.text
                end,
            },
            buttons = {
                {
                    text = function(dialog)
                        return dialog.data.btn1
                    end,
                    callback = function(dialog)
                        dialog.data.onConfirm()
                    end,
                },
                {
                    text = function(dialog)
                        return dialog.data.btn2
                    end,
                    callback = function(dialog)
                        dialog.data.onCancel()
                    end,
                },
            },
        }
    )
    SecurePostHook(CHAT_ROUTER, "AddSystemMessage", ALE.OnMessage)
end

local function OnAddOnLoaded(event, addonName)
    if addonName == ALE.name then
        EVENT_MANAGER:UnregisterForEvent(ALE.name, event)
        ALE:Initialize()
    end
end


EVENT_MANAGER:RegisterForEvent(
    ALE.name,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)


SLASH_COMMANDS["/rui"] = ALE.ReloadUI
SLASH_COMMANDS["/lg"] = ALE.EncounterLog
SLASH_COMMANDS["/ale_skip"] = ALE.Skip
