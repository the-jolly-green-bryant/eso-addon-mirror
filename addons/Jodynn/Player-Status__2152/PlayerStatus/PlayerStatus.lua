PlayerStatus = {} -- {{{1

-- Lol
SI_PLAYERSTATUS1 = "Online"
SI_PLAYERSTATUS2 = "Away"
SI_PLAYERSTATUS3 = "Do Not Disturb"
SI_PLAYERSTATUS4 = "Offline"

local PlayerStatus = PlayerStatus

PlayerStatus.init = false
PlayerStatus.REFIRE = "Refire"
PlayerStatus.REFIRE_INTERVAL = 750

PlayerStatus.name = "PlayerStatus"
PlayerStatus.version = 1.7
PlayerStatus.displayName = "|c998899Player Status|r"

PlayerStatus.Defaults = {}
PlayerStatus.Defaults.showIndi = true
PlayerStatus.Defaults.size = 40
PlayerStatus.Defaults.away = 60000
PlayerStatus.Defaults.autoAway = true
PlayerStatus.Defaults.autoAwayOnTabOut = true
PlayerStatus.Defaults.autoShowOnTabReturn = true
PlayerStatus.Defaults.autoShow = true
PlayerStatus.Defaults.shutup = true

PlayerStatus.Defaults.vHRC = true
PlayerStatus.Defaults.vSO  = true
PlayerStatus.Defaults.vAA  = true
PlayerStatus.Defaults.vMOL = true
PlayerStatus.Defaults.vAS  = true
PlayerStatus.Defaults.vHOF = true
PlayerStatus.Defaults.vCR  = true
PlayerStatus.Defaults.vMA  = true
PlayerStatus.Defaults.vDSA = true

PlayerStatus.Defaults.ui = {
    ["offsetX"]  = 0,
    ["offsetY"]  = 0,
    ["point"]    = TOPRIGHT,
    ["relPoint"] = TOPRIGHT,
}

PlayerStatus.zoneNameMap = {
    ["vAA"]  = "Aetherian Archive",
    ["vSO"]  = "Sanctum Ophidia",

    ["vHRC"] = "Hel Ra Citadel",
    ["vMOL"] = "Maw of Lorkhaj",
    ["vAS"]  = "Asylum Sanctorium",
    ["vHOF"] = "Halls of Fabrication",
    ["vCR"]  = "Cloudrest",

    ["vMA"]  = "Maelstrom Arena",
    ["vDSA"] = "Dragonstar Arena",
}

PlayerStatus.zoneMapName = { }
for i,v in pairs(PlayerStatus.zoneNameMap) do
    PlayerStatus.zoneMapName[v] = i
end

PlayerStatus.lastPosition = { 0, 0 }
PlayerStatus.lastStatus = -1
PlayerStatus.awayAccum = 0
PlayerStatus.ISetAway = false

PlayerStatus.currentZone = ""
PlayerStatus.currentSubZone = ""

PlayerStatus.Textures = {
    [PLAYER_STATUS_AWAY]           = "/esoui/art/tutorial/tutorial_illo_status_afk.dds",
    [PLAYER_STATUS_ONLINE]         = "/esoui/art/tutorial/tutorial_illo_status_online.dds",
    [PLAYER_STATUS_DO_NOT_DISTURB] = "/esoui/art/tutorial/tutorial_illo_status_dnd.dds",
    [PLAYER_STATUS_OFFLINE]        = "/esoui/art/tutorial/tutorial_illo_status_offline.dds",
}

local function show() -- {{{1
    if GetPlayerStatus() == PLAYER_STATUS_ONLINE then return end

    SelectPlayerStatus(PLAYER_STATUS_ONLINE)
    PlayerStatusIndi:SetTexture(PlayerStatus.Textures[GetPlayerStatus()])
    if PlayerStatus.sv.shutup then
    else
        d("You are now online |t16:16:" .. PlayerStatus.Textures[GetPlayerStatus()] .. "|t")
    end
end

local function away() -- {{{1
    if GetPlayerStatus() == PLAYER_STATUS_AWAY then return end

    SelectPlayerStatus(PLAYER_STATUS_AWAY)
    PlayerStatusIndi:SetTexture(PlayerStatus.Textures[GetPlayerStatus()])
    if PlayerStatus.sv.shutup then
    else
        d("You are now away |t16:16:" .. PlayerStatus.Textures[GetPlayerStatus()] .. "|t")
    end
end

local function busy() -- {{{1
    if GetPlayerStatus() == PLAYER_STATUS_DO_NOT_DISTURB then return end

    SelectPlayerStatus(PLAYER_STATUS_DO_NOT_DISTURB)
    PlayerStatusIndi:SetTexture(PlayerStatus.Textures[GetPlayerStatus()])
    if PlayerStatus.sv.shutup then
    else
        d("You are now busy |t16:16:" .. PlayerStatus.Textures[GetPlayerStatus()] .. "|t")
    end
end

local function hide() -- {{{1
    if GetPlayerStatus() == PLAYER_STATUS_OFFLINE then return end

    SelectPlayerStatus(PLAYER_STATUS_OFFLINE)
    PlayerStatusIndi:SetTexture(PlayerStatus.Textures[GetPlayerStatus()])
    if PlayerStatus.sv.shutup then
    else
        d("You are now hidden |t16:16:" .. PlayerStatus.Textures[GetPlayerStatus()] .. "|t")
    end
end

local function leaveGroup() -- {{{1
    GroupLeave()
    if PlayerStatus.sv.shutup then
    else
        d("Leaving group")
    end
end

local function logout() -- {{{1
    Logout()
    if PlayerStatus.sv.shutup then
    else
        d("Logging out")
    end
end

local function quit() -- {{{1
    Quit()
    if PlayerStatus.sv.shutup then
    else
        d("Quitting")
    end
end

local function hideAndQuit() -- {{{1
    hide()
    quit()
end

local function hideAndLogout() -- {{{1
    hide()
    logout()
end

local function hideAndLeaveGroup() -- {{{1
    leaveGroup()
    hide()
end

local function hideAndLeaveGroupAndQuit() -- {{{1
    leaveGroup()
    hide()
    quit()
end

local function hideAndLeaveGroupAndLogout() -- {{{1
    leaveGroup()
    hide()
    logout()
end

local function updateIndicatorSize() -- {{{1
    PlayerStatusIndi:SetDimensions(PlayerStatus.sv.size, PlayerStatus.sv.size)
    PlayerStatus_BG:SetDimensions(PlayerStatus.sv.size + 10, PlayerStatus.sv.size + 10)
end

local function updateIndicatorHidden() -- {{{1
    PlayerStatusIndi:SetHidden(not PlayerStatus.sv.showIndi)
    PlayerStatus_BG:SetHidden(not PlayerStatus.sv.showIndi)
end

local function createSettings() -- {{{1
    local LAM = LibAddonMenu2

    local settingsWindowData = {
        type = "panel",
        name = PlayerStatus.displayName,
        author = "|caaffeFJodynn|r",
        version = tostring(PlayerStatus.version),
        slashCommand = "/hiddensettings"
    }

    local settingsOptionsData = {
        [1] = {
            type = "checkbox",
            name = "Show indicator",
            tooltip = "Whether or not you want to show the thing that shows if you are online or not.",
            default = PlayerStatus.Defaults.showIndi,
            getFunc = function() return PlayerStatus.sv.showIndi end,
            setFunc = function(newValue)
                PlayerStatus.sv.showIndi = newValue
                updateIndicatorHidden()
            end,
        },
        [2] = {
            type = "slider",
            name = "Size",
            tooltip = "How big do you want the indicator to be",
            min = 0,
            max = 1000,
            step = 1,
            default = PlayerStatus.Defaults.size,
            getFunc = function() return PlayerStatus.sv.size end,
            setFunc = function(newValue)
                PlayerStatus.sv.size = newValue
                updateIndicatorSize()
            end,
        },

        [3] = {
            type = "header",
            name = "Auto |cffff00Away|r after x seconds",
        },

        [4] = {
            type = "checkbox",
            name = "Away",
            default = PlayerStatus.Defaults.autoAway,
            getFunc = function() return PlayerStatus.sv.autoAway end,
            setFunc = function(newValue)
                PlayerStatus.sv.autoAway = newValue
                updateIndicatorHidden()
            end,
        },

        [5] = {
            type = "checkbox",
            name = "Revert on Move",
            default = PlayerStatus.Defaults.autoShow,
            getFunc = function() return PlayerStatus.sv.autoShow end,
            setFunc = function(newValue)
                PlayerStatus.sv.autoShow = newValue
                updateIndicatorHidden()
            end,
        },

        [6] = {
            type = "slider",
            name = "Timer",
            tooltip = "How long before it sets you to away.  ( In seconds ) ",
            min = 1,
            max = 10000,
            step = 1,
            default = PlayerStatus.Defaults.away,
            getFunc = function() return PlayerStatus.sv.away / 1000 end,
            setFunc = function(newValue)
                PlayerStatus.sv.away = newValue * 1000
                updateIndicatorSize()
            end,
        },

        [7] = {
            type = "header",
            name = "Auto |cffff00Away|r on tab out",
        },

        [8] = {
            type = "checkbox",
            name = "Tab out",
            default = PlayerStatus.Defaults.autoAwayOnTabOut,
            getFunc = function() return PlayerStatus.sv.autoAwayOnTabOut end,
            setFunc = function(newValue)
                PlayerStatus.sv.autoAwayOnTabOut = newValue
                updateIndicatorHidden()
            end,
        },

        [9] = {
            type = "checkbox",
            name = "Revert on Tab In",
            default = PlayerStatus.Defaults.autoShowOnTabReturn,
            getFunc = function() return PlayerStatus.sv.autoShowOnTabReturn end,
            setFunc = function(newValue)
                PlayerStatus.sv.autoShowOnTabReturn = newValue
                updateIndicatorHidden()
            end,
        },

        [10] = {
            type = "header",
            name = "Auto |cff0000Busy|r when entered",
        },

        [11] = {
            type = "checkbox",
            name = "vHRC",
            default = PlayerStatus.Defaults.vHRC,
            getFunc = function() return PlayerStatus.sv.vHRC end,
            setFunc = function(newValue)
                PlayerStatus.sv.vHRC = newValue
                if IsGroupUsingVeteranDifficulty() and GetMapName() == PlayerStatus.zoneNameMap["vHRC"] then
                    busy()
                end
            end,
        },

        [12] = {
            type = "checkbox",
            name = "vSO",
            default = PlayerStatus.Defaults.vSO,
            getFunc = function() return PlayerStatus.sv.vSO end,
            setFunc = function(newValue)
                PlayerStatus.sv.vSO = newValue
                if newValue and IsGroupUsingVeteranDifficulty() and GetMapName() == PlayerStatus.zoneNameMap["vSO"] then
                    busy()
                end
            end,
        },

        [13] = {
            type = "checkbox",
            name = "vAA",
            default = PlayerStatus.Defaults.vAA,
            getFunc = function() return PlayerStatus.sv.vAA end,
            setFunc = function(newValue)
                PlayerStatus.sv.vAA = newValue
                if newValue and IsGroupUsingVeteranDifficulty() and GetMapName() == PlayerStatus.zoneNameMap["vAA"] then
                    busy()
                end
            end,
        },

        [14] = {
            type = "checkbox",
            name = "vAS",
            default = PlayerStatus.Defaults.vAS,
            getFunc = function() return PlayerStatus.sv.vAS end,
            setFunc = function(newValue)
                PlayerStatus.sv.vAS = newValue
                if newValue and IsGroupUsingVeteranDifficulty() and GetMapName() == PlayerStatus.zoneNameMap["vAS"] then
                    busy()
                end
            end,
        },

        [15] = {
            type = "checkbox",
            name = "vHOF",
            default = PlayerStatus.Defaults.vHOF,
            getFunc = function() return PlayerStatus.sv.vHOF end,
            setFunc = function(newValue)
                PlayerStatus.sv.vHOF = newValue
                if newValue and IsGroupUsingVeteranDifficulty() and GetMapName() == PlayerStatus.zoneNameMap["vHOF"] then
                    busy()
                end
            end,
        },

        [16] = {
            type = "checkbox",
            name = "vMOL",
            default = PlayerStatus.Defaults.vMOL,
            getFunc = function() return PlayerStatus.sv.vMOL end,
            setFunc = function(newValue)
                PlayerStatus.sv.vMOL = newValue
                if newValue and IsGroupUsingVeteranDifficulty() and GetMapName() == PlayerStatus.zoneNameMap["vMOL"] then
                    busy()
                end
            end,
        },

        [17] = {
            type = "checkbox",
            name = "vMA",
            default = PlayerStatus.Defaults.vMA,
            getFunc = function() return PlayerStatus.sv.vMA end,
            setFunc = function(newValue)
                PlayerStatus.sv.vMA = newValue
                if newValue and GetMapName() == PlayerStatus.zoneNameMap["vMA"] then
                    busy()
                end
            end,
        },

        [18] = {
            type = "checkbox",
            name = "vDSA",
            default = PlayerStatus.Defaults.vDSA,
            getFunc = function() return PlayerStatus.sv.vDSA end,
            setFunc = function(newValue)
                PlayerStatus.sv.vDSA = newValue
                if newValue and IsGroupUsingVeteranDifficulty() and GetMapName() == PlayerStatus.zoneNameMap["vDSA"] then
                    busy()
                end
            end,
        },

        [19] = {
            type = "checkbox",
            name = "vCR",
            default = PlayerStatus.Defaults.vCR,
            getFunc = function() return PlayerStatus.sv.vCR end,
            setFunc = function(newValue)
                PlayerStatus.sv.vCR = newValue
                if newValue and IsGroupUsingVeteranDifficulty() and GetMapName() == PlayerStatus.zoneNameMap["vCR"] then
                    busy()
                end
            end,
        },

        [20] = {
            type = "header",
            name = "Misc.",
        },

        [21] = {
            type = "checkbox",
            name = "No Log",
            tooltip = "If off don't log status messages.",
            default = PlayerStatus.Defaults.shutup,
            getFunc = function() return PlayerStatus.sv.shutup end,
            setFunc = function(newValue)
                PlayerStatus.sv.shutup = newValue
            end,
        },
    }

    local settingsOptionPanel = LAM:RegisterAddonPanel(PlayerStatus.name.."_LAM", settingsWindowData)
    LAM:RegisterOptionControls(PlayerStatus.name.."_LAM", settingsOptionsData)
end

function PlayerStatus:Initialize() -- {{{1
    PlayerStatus.sv = ZO_SavedVars:New("PlayerStatus_sv", 1, nil, PlayerStatus.Defaults)

    -- Restore from settings
    PlayerStatus_BG:ClearAnchors()
    PlayerStatus_BG:SetAnchor(PlayerStatus.sv.ui.point, GuiRoot, PlayerStatus.sv.ui.relPoint, PlayerStatus.sv.ui.offsetX, PlayerStatus.sv.ui.offsetY)
    PlayerStatusIndi:SetTexture(PlayerStatus.Textures[GetPlayerStatus()])
    updateIndicatorHidden()
    updateIndicatorSize()

    PlayerStatus_BG:SetHandler("OnMoveStop", function (self)
        local valid, point, _, relPoint, offsetX, offsetY = PlayerStatus_BG:GetAnchor(0)
        PlayerStatus.sv.ui.point = point
        PlayerStatus.sv.ui.relPoint = relPoint
        PlayerStatus.sv.ui.offsetX = offsetX
        PlayerStatus.sv.ui.offsetY = offsetY
    end)

    PlayerStatusIndi:SetHandler("OnShow", function (self)
        PlayerStatusIndi:SetTexture(PlayerStatus.Textures[GetPlayerStatus()])
    end)

    createSettings()

    SLASH_COMMANDS["/hide"]          = hide
    SLASH_COMMANDS["/away"]          = away
    SLASH_COMMANDS["/busy"]          = busy
    SLASH_COMMANDS["/show"]          = show

    SLASH_COMMANDS["/leave"]         = leaveGroup

    SLASH_COMMANDS["/hidequit"]      = hideAndQuit
    SLASH_COMMANDS["/hidecamp"]      = hideAndLogout
    SLASH_COMMANDS["/hideleave"]     = hideAndLeaveGroup
    SLASH_COMMANDS["/hideleavequit"] = hideAndLeaveGroupAndQuit
    SLASH_COMMANDS["/hideleavecamp"] = hideAndLeaveGroupAndLogout
end

EVENT_MANAGER:RegisterForEvent(PlayerStatus.name, EVENT_PLAYER_ACTIVATED , function(eventCode, initial) -- {{{1
    if PlayerStatus.init then
    else
        PlayerStatus.init = true
        zo_callLater ( PlayerStatus.Initialize, 1000 )
    end
end)

EVENT_MANAGER:RegisterForEvent(PlayerStatus.name, EVENT_LOGOUT_DISALLOWED, function (eventCode, quitReq) -- {{{1
    if quitReq then
        if PlayerStatus.sv.shutup then
        else
            d("You can't quit for some reason...")
        end
    else
        if PlayerStatus.sv.shutup then
        else
            d("You can't logout for some reason...")
        end
    end
end)

EVENT_MANAGER:RegisterForEvent(PlayerStatus.name, EVENT_PLAYER_STATUS_CHANGED, function (eventCode, oldStatus, newStatus) -- {{{1
    PlayerStatusIndi:SetTexture(PlayerStatus.Textures[GetPlayerStatus()])
    PlayerStatus.awayAccum = 0
end)

EVENT_MANAGER:RegisterForEvent(PlayerStatus.name, EVENT_PLAYER_ACTIVATED , function(eventCode, initial) -- {{{1
    if PlayerStatus.sv == nil then return end
    if GetPlayerStatus() == PLAYER_STATUS_OFFLINE then return end

    if GetMapName() == PlayerStatus.zoneNameMap["vMA"] and PlayerStatus.sv.vMA then
        busy()
    else
        local ac = PlayerStatus.zoneMapName[GetMapName()]

        if ac ~= nil then
            if IsGroupUsingVeteranDifficulty() and PlayerStatus.sv[ac] then
                busy()
            end
        end
    end
end)

EVENT_MANAGER:RegisterForUpdate(REFIRE, PlayerStatus.REFIRE_INTERVAL, function () -- {{{1
    -- 'Dont do this if we are hiding lol'
    if PlayerStatus.sv == nil then return end
    if GetPlayerStatus() == PLAYER_STATUS_OFFLINE then return end
    if not PlayerStatus.sv.autoAway then return end

    local x, z, _, _ = GetMapPlayerPosition("player")

    if  PlayerStatus.lastPosition[1] ~= x or PlayerStatus.lastPosition[2] ~= z then
        PlayerStatus.lastPosition = { x, z }
        PlayerStatus.awayAccum = 0
        if GetPlayerStatus() == PLAYER_STATUS_AWAY and PlayerStatus.ISetAway and PlayerStatus.sv.autoShow then
            if lastStatus == PLAYER_STATUS_AWAY then
                show()
            elseif lastStatus == PLAYER_STATUS_ONLINE then
                show()
            elseif lastStatus == PLAYER_STATUS_DO_NOT_DISTURB then
                busy()
            end
        end
    else
        if GetPlayerStatus() == PLAYER_STATUS_AWAY then
            PlayerStatus.awayAccum = 0
        else
            PlayerStatus.awayAccum = PlayerStatus.REFIRE_INTERVAL + PlayerStatus.awayAccum
            if PlayerStatus.awayAccum > PlayerStatus.sv.away then
                lastStatus = GetPlayerStatus()
                away()
                PlayerStatus.ISetAway = true
                PlayerStatus.awayAccum = 0
            end
        end

    end
end)

EVENT_MANAGER:RegisterForEvent(PlayerStatus.name, EVENT_GAME_FOCUS_CHANGED, function (eventCode, hasFocus) -- {{{1
    if GetPlayerStatus() == PLAYER_STATUS_OFFLINE then return end
    if PlayerStatus.sv == nil then return end

    if hasFocus and PlayerStatus.sv.autoShowOnTabReturn then
        if lastStatus == PLAYER_STATUS_AWAY then
            show()
        elseif lastStatus == PLAYER_STATUS_ONLINE then
            show()
        elseif lastStatus == PLAYER_STATUS_DO_NOT_DISTURB then
            busy()
        end
    elseif not hasFocus and PlayerStatus.sv.autoAwayOnTabOut then
        lastStatus = GetPlayerStatus()
        away()
    end
end)
