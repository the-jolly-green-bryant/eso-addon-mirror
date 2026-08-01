DsRAutoINV = DsRAutoINV or {}
DsRAutoINV.AddonId = "DsRAutoInvite"
DsRAutoINV.name = "DsRAutoInvite"

local DsRIcon = DsRglobals:HolidayIconLoad()

-------------------------------------------------------------------------------------------------------------------------------------------------
--- Utility functions
-------------------------------------------------------------------------------------------------------------------------------------------------
local function b(v) if v then return "T" else return "F" end end
local function nn(val) if val == nil then return "NIL" else return val end end
local function dbg(msg) if DsRAutoINV.debug then d("|c999999" .. msg) end end
local function echo(msg) CHAT_ROUTER:AddSystemMessage("|CFFFF00" .. msg) end

DsRAutoINV.isCyrodiil = function(unit)
    if unit == nil then unit = "player" end
    dbg("Current zone: '" .. GetUnitZone(unit) .. "'")
    return GetUnitZone(unit) == "Cyrodiil"
end

-------------------------------------------------------------------------------------------------------------------------------------------------
--- Event handlers
-------------------------------------------------------------------------------------------------------------------------------------------------

--Main callback fired on chat message
DsRAutoINV.callback = function(_, messageType, from, message)
    if not DsRAutoINV.enabled or not DsRAutoINV.listening then
        return
    end

    -- TODO: Move this to the actual invite send so not per-message
    if GetGroupSize() >= DsRAutoINV.cfg.maxSize then
        echo(GetString(SI_DsRAI_GROUP_FULL_STOP))
        DsRAutoINV.stopListening()
    end

    local splittedText = {zo_strsplit(";" , DsRAutoINV.cfg.watchStr)}

    for i = 1, #splittedText do
        if string.lower(message) == splittedText[i] and from ~= nil and from ~= "" then
            if (messageType >= CHAT_CHANNEL_GUILD_1 and messageType <= CHAT_CHANNEL_OFFICER_5) or messageType == CHAT_CHANNEL_WHISPER then
                from = DsRAutoINV.accountNameLookup(messageType, from)
                if from == "" or from == nil then return end
            end

            echo(zo_strformat(GetString(SI_DsRAI_SEND_TO_USER), from))
            DsRAutoINV:invitePlayer(from)
        end
    end

    -- if string.lower(message) == DsRAutoINV.cfg.watchStr and from ~= nil and from ~= "" then
    --     if (messageType >= CHAT_CHANNEL_GUILD_1 and messageType <= CHAT_CHANNEL_OFFICER_5) or messageType == CHAT_CHANNEL_WHISPER then
    --         from = DsRAutoINV.accountNameLookup(messageType, from)
    --         if from == "" or from == nil then return end
    --     end

    --     echo(zo_strformat(GetString(SI_DsRAI_SEND_TO_USER), from))
    --     DsRAutoINV:invitePlayer(from)
    -- end





end


DsRAutoINV.playerLeave = function(_, unitTag, connectStatus, isSelf, acctName, charName)
    local player = GetDisplayName()

    if player == charName then
        if DsRAutoINV.enabled then
            DsRAutoINV.enabled = false
            DsRAutoINV.stopListening()
            DsRAutoINVUI.refresh()
            echo(zo_strformat(GetString(SI_DsRAI_OFF)))
        end
        return;
    else
        if DsRAutoINV.enabled and DsRAutoINV.cfg.restart then
            echo(zo_strformat(GetString(SI_DsRAI_USER_LEAVE), charName))
        if not DsRAutoINV.listening then
            echo(zo_strformat(GetString(SI_DsRAI_GROUP_OPEN_RESTART), DsRAutoINV.cfg.watchStr))
        end
            DsRAutoINV.startListening()
        end

        if isSelf then
            DsRAutoINV.kickTable = {}
        else
            local unitName = GetUnitName(unitTag):gsub("%^.+", "")
             DsRAutoINV.kickTable[unitName] = nil
        end
    end
end

DsRAutoINV.offlineEvent = function(_, unitTag, connectStatus, isSelf, acctName, charName)
    local unitName = GetUnitName(unitTag):gsub("%^.+", "")
    if connectStatus then
        dbg(unitTag .. "/" .. unitName .. " has reconnected")
        DsRAutoINV.kickTable[unitName] = nil
    else
        dbg(unitTag .. "/" .. unitName .. " has disconnected")
        DsRAutoINV.kickTable[unitName] = GetTimeStamp()
    end
    MINI_GROUP_LIST:updateSingle(name)
end

-- tick function: called every 1s
function DsRAutoINV.tick()
    local self = DsRAutoINV
    self.kickCheck()

    if self.listening then
        if GetGroupSize() >= self.cfg.maxSize then
            self.stopListening()
        else
            self:checkSentInvites()
            self:processQueue()
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
--- Encounterlog Status
-------------------------------------------------------------------------------------------------------------------------------------------------
local TRIAL_ZONE_IDS = {
    [636] = true,   -- Hel Ra Citadel
    [638] = true,   -- Aetherian Archive
    [639] = true,   -- Sanctum Ophidia
    [725] = true,   -- Maw of Lorkhaj
    [975] = true,   -- Halls of Fabrication
    [1000] = true,  -- Asylum Sanctorium
    [1051] = true,  -- Cloudrest
    [1121] = true,  -- Sunspire
    [1196] = true,  -- Kyne's Aegis
    [1263] = true,  -- Rockgrove
    [1344] = true,  -- Dreadsail Reef
    [1427] = true,  -- Sanity's Edge
    [1478] = true,  -- Lucent Citadel
    [1548] = true,  -- Ossein Cage
}

local ENABLE_ENCOUNTER_LOG_DIALOG_NAME  = DsRAutoINV.name .. "EnableEncounterLogDialog"
local DISABLE_ENCOUNTER_LOG_DIALOG_NAME = DsRAutoINV.name .. "DisableEncounterLogDialog"

DsRAutoINV.initializeDialogQuestion = function()
    ESO_Dialogs[ENABLE_ENCOUNTER_LOG_DIALOG_NAME] = {
        canQueue = true,
        uniqueIdentifier = ENABLE_ENCOUNTER_LOG_DIALOG_NAME,
        title = {
            text = zo_iconFormat(DsRIcon, 34, 34) .. "|c9fb6cdEncounterlog|r" .. zo_iconFormat(DsRIcon, 34, 34)
        },
        mainText = {
            text = GetString(SI_DsRAI_ENCOUNTER_DIALOG)
        },
        buttons = {
            [1] = {
                text = SI_DIALOG_YES,
                callback = DsRAutoINV.EnableEncounterLog
            },
            [2] = {
                text = SI_DIALOG_NO,
                callback = function(dialog) end
            }
        },
        setup = function(dialog, data) end
    }
    ESO_Dialogs[DISABLE_ENCOUNTER_LOG_DIALOG_NAME] = {
        canQueue = true,
        uniqueIdentifier = DISABLE_ENCOUNTER_LOG_DIALOG_NAME,
        title = {
            text = zo_iconFormat(DsRIcon, 34, 34) .. "|c9fb6cdEncounterlog|r" .. zo_iconFormat(DsRIcon, 34, 34)
        },
        mainText = {
            text = GetString(SI_DsRAI_ENCOUNTER_DIALOG_STOP)
        },
        buttons = {
            [1] = {
                text = SI_DIALOG_YES,
                callback = DsRAutoINV.DisableEncounterLog
            },
            [2] = {
                text = SI_DIALOG_NO,
                callback = function(dialog) end
            }
        },
        setup = function(dialog, data) end
    }
end

DsRAutoINV.EncounterAndTrialCheck = function(val)
    local Leader      = IsUnitGroupLeader("player")
    local Group       = IsUnitGrouped("player")
    local ZoneID      = GetZoneId(GetUnitZoneIndex("player"))
    local isRaid      = TRIAL_ZONE_IDS[ZoneID]
    local EncounterON = IsEncounterLogEnabled()

    if isRaid and Group and Leader then
        if EncounterON then
            DsRAI_EncounterLabel:SetText("Encounterlog |c35fc38ON|r")
        else
            if DsRAutoINV.cfg.EncounterQuest then
                local Answer = ZO_Dialogs_ShowDialog(ENABLE_ENCOUNTER_LOG_DIALOG_NAME)
                if Answer == true then
                    DsRAI_EncounterLabel:SetText("Encounterlog |c35fc38ON|r")
                else
                    DsRAI_EncounterLabel:SetText("Encounterlog |cFF0000OFF|r")
                end
            end
        end
        if DsRAutoINV.cfg.EncounterOnOff == true then
            DsRAI_Encounter:SetHidden(false)
        else
            DsRAI_Encounter:SetHidden(true)
        end
    else
        DsRAI_Encounter:SetHidden(true)
    end
end

DsRAutoINV.EnableEncounterLog = function(dialog)
    SetEncounterLogEnabled(true)
    DsRAI_EncounterLabel:SetText("Encounterlog |c35fc38ON|r")
    d(" |c9fb6cd[DsR-Encounter]|r " .. "|c35fc38" .. GetString(SI_DsRAI_ENCOUNTER_LOG))
end

DsRAutoINV.DisableEncounterLog = function(dialog)
    SetEncounterLogEnabled(false)
    DsRAI_EncounterLabel:SetText("Encounterlog |cFF0000OFF|r")
    d(" |c9fb6cd[DsR-Encounter]|r " .. "|c35fc38" .. GetString(SI_DsRAI_ENCOUNTER_LOG_STOP))
end

DsRAutoINV.RestorePosition = function()
    DsRAI_Encounter:ClearAnchors()
    DsRAI_Encounter:SetTopmost(true)
    DsRAI_Encounter:BringWindowToTop(true)
    DsRAI_Encounter:SetAnchor(
        TOPLEFT,
        GuiRoot,
        TOPLEFT,
        DsRAutoINV.cfg.EncounterOffsetX,
        DsRAutoINV.cfg.EncounterOffsetY
    )
    DsRAutoINV.EncounterAndTrialCheck()
end

DsRAutoINV.SaveLoc = function()
    DsRAutoINV.cfg.EncounterOffsetX = DsRAI_Encounter:GetLeft()
    DsRAutoINV.cfg.EncounterOffsetY = DsRAI_Encounter:GetTop()
end

DsRAutoINV.ShowLabel = function()
    local ZoneID = GetZoneId(GetUnitZoneIndex("player"))
    local isRaid = TRIAL_ZONE_IDS[ZoneID]
    if isRaid then
        if DsRAutoINV.cfg.EncounterOnOff then
            DsRAI_Encounter:SetHidden(false)
        else
            DsRAI_Encounter:SetHidden(true)
        end
    end
end

DsRAutoINV.HideLabel = function()
    DsRAI_Encounter:SetHidden(true)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
--- Event control
-------------------------------------------------------------------------------------------------------------------------------------------------
DsRAutoINV.disable = function()
    DsRAutoINV.enabled = false
    DsRAutoINV.stopListening()
    echo(zo_strformat(GetString(SI_DsRAI_OFF)))
    EVENT_MANAGER:UnregisterForUpdate(DsRAutoINV.AddonId)
    EVENT_MANAGER:UnregisterForEvent(DsRAutoINV.AddonId, EVENT_GROUP_INVITE_RESPONSE)
end

DsRAutoINV.stopListening = function()
    EVENT_MANAGER:UnregisterForEvent(DsRAutoINV.AddonId, EVENT_CHAT_MESSAGE_CHANNEL)
    DsRAutoINV.listening = false
end

--@param restart: (boolean) - true if restarted listening due to space open up
--currently only used for different print strings
DsRAutoINV.startListening = function(restart)
    if not DsRAutoINV.enabled then
        DsRAutoINV.enabled = true
        DsRAutoINV.checkOffline()
        EVENT_MANAGER:RegisterForUpdate(DsRAutoINV.AddonId, 1000, DsRAutoINV.tick)
        EVENT_MANAGER:RegisterForEvent(DsRAutoINV.AddonId, EVENT_GROUP_INVITE_RESPONSE, DsRAutoINV.inviteResponse)
    end

    if not DsRAutoINV.listening and GetGroupSize() < DsRAutoINV.cfg.maxSize then
        --Add handler
        EVENT_MANAGER:RegisterForEvent(DsRAutoINV.AddonId, EVENT_CHAT_MESSAGE_CHANNEL, DsRAutoINV.callback)
        DsRAutoINV.listening = true
        if restart ~= nil then
            echo(zo_strformat(GetString(SI_DsRAI_GROUP_OPEN_RESTART), DsRAutoINV.cfg.watchStr))
        else
            echo(zo_strformat(GetString(SI_DsRAI_START_ON), DsRAutoINV.cfg.watchStr))
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
--- Initialization
-------------------------------------------------------------------------------------------------------------------------------------------------
DsRAutoINV.init = function()
    EVENT_MANAGER:UnregisterForEvent("DsRAutoINVInit", EVENT_PLAYER_ACTIVATED)
    if DsRAutoINV.initDone then return end
    DsRAutoINV.initDone = true

    EVENT_MANAGER:RegisterForEvent(DsRAutoINV.AddonId, EVENT_GROUP_MEMBER_LEFT, DsRAutoINV.playerLeave)
    EVENT_MANAGER:RegisterForEvent(DsRAutoINV.AddonId, EVENT_GROUP_MEMBER_CONNECTED_STATUS, DsRAutoINV.offlineEvent)

    --Make sure Offline is updated after player zones (is offline for a bit
    EVENT_MANAGER:RegisterForEvent("DsRAutoINVInit", EVENT_PLAYER_ACTIVATED, DsRAutoINV.checkOffline)

    EVENT_MANAGER:RegisterForEvent(DsRAutoINV.AddonId, EVENT_PLAYER_ACTIVATED, DsRAutoINV.EncounterAndTrialCheck)
    EVENT_MANAGER:RegisterForEvent(DsRAutoINV.AddonId, EVENT_ZONE_CHANGED,     DsRAutoINV.EncounterAndTrialCheck)

    DsRAutoINV.listening = false
    DsRAutoINV.enabled   = false
    DsRAutoINV.player    = GetUnitName("player")
    DsRAutoINVUI.init()

    DsRAutoINV.RestorePosition()
    DsRAutoINV.initializeDialogQuestion()

    ZO_PreHookHandler(ZO_GameMenu_InGame     , "OnShow" , function() DsRAutoINV.HideLabel() end)
    ZO_PreHookHandler(ZO_GameMenu_InGame     , "OnHide" , function() DsRAutoINV.ShowLabel() end)
    ZO_PreHookHandler(ZO_InteractWindow      , "OnShow" , function() DsRAutoINV.HideLabel() end)
    ZO_PreHookHandler(ZO_InteractWindow      , "OnHide" , function() DsRAutoINV.ShowLabel() end)
    ZO_PreHookHandler(ZO_KeybindStripControl , "OnShow" , function() DsRAutoINV.HideLabel() end)
    ZO_PreHookHandler(ZO_KeybindStripControl , "OnHide" , function() DsRAutoINV.ShowLabel() end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar , "OnShow" , function() DsRAutoINV.HideLabel() end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar , "OnHide" , function() DsRAutoINV.ShowLabel() end)
end

EVENT_MANAGER:RegisterForEvent("DsRAutoINVInit", EVENT_PLAYER_ACTIVATED, DsRAutoINV.init)
