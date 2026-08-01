--[[		  						PUGmo the Pick Up Group Utility (and more)

	PUGmo has some inspiration from Chat Watcher by @lintydruid and BegTheGear by oJelly
	The original idea was to provide a way to display items and gear that party member wished to trade after a Trial
	or Dungeon. Although, different from BegTheGear, it only lists gear that is linked in chat by a player,	not the looted items.
	During the research in how to make that happen I found the long abandoned Chat Watcher. It did not not work under
	the current API but I duct taped it up to see what it did. I liked the alert idea for certain events and decided to also
	incorporate that idea. I also incorporated the the idea	to watch for LFG and LFM as well as items for sale or trade
	but as a list instead of an alert similar to how BTG lists items. Although none (or very little) of that code exists
	in this addon, their ideas influenced my code. Thank you @lintydruid and oJelly
	Tigertron

--]]
if not PUGmo then
    PUGmo = {}
end
local PUG = PUGmo
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER
local CM = CALLBACK_MANAGER
local CS = CHAT_SYSTEM

PUG.name = "PUGmo"                  --- do not change
PUG.author = "Tigertron (@Jade-Tiger PC/NA)"
PUG.version = "21.10.09"            --- don't forget manifest file
PUG.savedversion = 1                --- increase to force a reload of variables from PUG.defaults

PUG.SV = {}

---    Factory restore settings
PUG.defaults = {
    debug = false,
    ["zone"] = { left = 1400, top = 200 },
    ["group"] = { left = 1400, top = 200 },
    ["alert"] = { left = 1200, top = 600 },
    confirmWhisper = true,
    skipLegendary = true,
    skipJewelery = false,
    preCheck = true,
    groupChat = true,
    setEncounterLog = false,
    alertOn = true,
    wtsOn = true,
    minimized = false,
    minWTSKeys = 1,
    minLFGKeys = 2,
    minCharges = 20,            --- enchant percentage red level max 99
    minCond = 20,               --- gear repair red level max 99
    freeSlots = 20,             --- free slots red level
    showGemsAndKits = true,
    xtime = 60 * 5,             --- expiration time of zone list messages in seconds
    markedDelay = 30,           --- time out for marked player arrow in seconds
    itemColor = {
        [1] = { r = 1, g = 0.5, b = 0, a = 1 },
        [2] = { r = 1, g = 1, b = 0, a = 1 },
        [3] = { r = 0, g = 0, b = 1, a = 1 },
        [4] = { r = 0, g = 1, b = 0, a = 1 },
        [5] = { r = 1, g = 0, b = 0, a = 1 },
    },
    bestFriend = "",
    lootWhisperPrefix = "May I get the",
    lootWhisperSuffix = "please?",
    itemBlacklist = {
        [1] = "H1:GUILD:",
    },
    alertTime = {
        test = 1,
        general = 5,
        whisper = 10,
        leader = 10,
    }
}

PUG.color = {
    white = "|cFFFFFF",
    black = "|c000000",
    amber = "|cFFC000",
    orange = "|cFF8000",
    lightorange = "|cFFAA33",
    lime = "|c00FF00",
    yellow = "|cFFFF00",
    fushia = "|cFF80FF",
    cinnibar = "|cE9323C",
    cyan = "|c00FFFF",
    red = "|cFF0000",
    green = "|c00FF00",
    blue = "|c0000FF",
    blueviolet = "|c8A2BE2",
    brown = "|cA52A2A",
    grey = "|cABEBEBE",
    darkgrey = "|c232323",
    olive = "|cCFDCBD",
}
PUG.data = {
    temp = "", --- for testing
    me = GetUnitDisplayName("player"),
    hide = true,
    refresh = true,
    blocked = false,
    initGroupList = false,
    autoInvite = false,
    zoneListCB = "PUGmoZoneListRefresh",
    alertBoxCB = "PUGmoAlertBoxRefresh",
    grouplistCB = "PUGmoGroupListRefresh",
    isPChat = false,
    isOSI = false,
    delay = 0,
    item = 1,
    button = nil,
    buttonFlag = false,
    marked = {
        icon = nil,
        delay = 0,
        tag = "", --- unitTag
        name = "",
    },
    zonesVisited = {},
    groupSets = {},
    dungeon = {
        last = 0,
        --zone = "",
        --name = "",
        index = 0,
        left = true,
        --time = 0,
    },
}
PUG.guildName = {}
PUG.guildColor = {
    [1] = PUG.color.green,
    [2] = PUG.color.fushia,
    [3] = PUG.color.cinnibar,
    [4] = PUG.color.cyan,
    [5] = PUG.color.brown,
}
PUG.role = {
    [0] = "|cFFFF00Not Online|r",
    [1] = "|c00FF00DPS|r",
    [2] = "|cFF0000Tank|r",
    [3] = "THREE",
    [4] = "|c0000FFHealer|r",
}
PUG.selected = {}
PUG.msg = {} --- accessed globally as PUGmo.msg

PUG.zoneBuffer = {} --- this is zone and guild messages
PUG.groupBuffer = {} --- this is group messages
PUG.myLootList = {} --- this is my loot to share

PUG.playerBlacklist = {}
PUG.alertBox = {
    delay = 0,
    pause = true,
    confirm = false,
    msgCache = {},
}

---****************************
---*** Begin Initialization ***
---****************************

--- Add Slash Commands
SLASH_COMMANDS["/pugmo"] = function(...)
    PUG:cmd(...)
end

-------------------------------------------------------------------------
--- Trigger and the initialization function
--- The event will trigger after all of the files have been loaded
-------------------------------------------------------------------------
EM:RegisterForEvent(PUG.name, EVENT_ADD_ON_LOADED, function(eventType, addonName)
    if (addonName ~= PUG.name) then
        return
    end
    --- it will never fire again but it wastes cycles checking so remove it
    EM:UnregisterForEvent(PUG.name, EVENT_ADD_ON_LOADED)
    --- from here the anonymous function initializes the addon

    if pChat then
        PUG.data.isPChat = true
    end

    if OSI then
        PUG.data.isOSI = true
    end

    for i = 1, 5 do
        PUG.guildName[i] = GetGuildName(GetGuildId(i))
    end

    --[[Saved Variables
        The table "PUG.SV" is what will be read from and written to, the file "SavedVariables\PUGmo.lua" and creates global table "PUGmoSavedVars".
        "PUGmoSavedVars" is also the name defined in the manifest txt file. They must match. Did I say THEY MUST MATCH.
        Table "PUG.SV" holds the saved variables. The addon can not add elements to "PUG.SV" they must be added from table "PUG.defaults".
        You can change what is there and it will save to your file, but new elements can not be added dynamically.
        Table "PUG.defaults" will only fill in missing vars and serves as a baseline if SavedVariables\PUGmo.lua is deleted or the version raised.
        If "PUG.savedversion" is increased then "SavedVariables\PUGmo.lua" file is erased and rebuilt from table "PUG.defaults".
    --]]

    --- Load table PUG.SV from the file "SavedVariables\PUGmo.lua"
    PUG.SV = ZO_SavedVars:NewAccountWide("PUGmoSavedVars", PUG.savedversion, nil, PUG.defaults, GetWorldName())

    --- Hotkey setup after bindings.xml is loaded
    ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_PUGMO", "PUGmo GO!")
    ZO_CreateStringId("SI_BINDING_NAME_LEAVE_GROUP_PUGMO", "Leave the group")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_TO_LEADER_PUGMO", "Jump to leader")
    ZO_CreateStringId("SI_BINDING_NAME_PRECHECK_PUGMO", "PreCheck Alert Box")

    --- Setup options window using LibAddonMenu
    PUG:makeLAM()

    --- restore positions
    PUGmoWindowZone:ClearAnchors()
    PUGmoWindowZone:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PUG.SV["zone"].left, PUG.SV["zone"].top)
    PUGmoWindowZone:SetHidden(true)
    PUGmoWindowGroup:ClearAnchors()
    PUGmoWindowGroup:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PUG.SV["group"].left, PUG.SV["group"].top)
    PUGmoWindowGroup:SetHidden(true)
    PUGmoAlertBoxWindow:ClearAnchors()
    PUGmoAlertBoxWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PUG.SV["alert"].left, PUG.SV["alert"].top)
    PUGmoAlertBoxWindow:SetHidden(true)
    PUGmoAlertBoxWindowConfirm:SetHidden(true)

    --- get dimensions
    local width, height = PUGmoWindowZone:GetDimensions()
    PUGmoWindowZoneListLFG:SetDimensions(width, height - 70)
    PUGmoWindowZoneWTS:SetHidden(true)
    PUGmoWindowZoneListWTS:SetHidden(true)

    if PUG.SV.wtsOn then
        PUGmoWindowZoneWTS:SetHidden(false)
        PUGmoWindowZoneListWTS:SetHidden(false)
        PUG.SV.minimized = not PUG.SV.minimized
        PUG:minimizeWTS()
    end


    --- Scroll List definition
    ---
    --- control = the scroll list control pointer
    --- typeId = a unique identifier to give to CreateDataEntry when you want to add an element of this type
    --- templateName = the name of the virtual control template that will be used to define this data
    --- height = height of the row, not the window - the control height
    --- setupCallback = the function that will be called when a control of this typeId becomes visible. Signature: setupCallback(control, data, scrollList)
    --- hideCallback = the function that will be called when the row control gets hidden.
    --- dataTypeSelectSound = an optional sound to play when a row of this data type is selected
    --- resetControlCallback = an optional callback when the datatype control gets reset
    --- ZO_ScrollList_AddDataType(self, typeId, templateName, height, setupCallback, hideCallback, dataTypeSelectSound, resetControlCallback)

    ZO_ScrollList_AddDataType(PUGmoWindowZoneListLFG, 1, "ListZoneTpl", 70, PUG.layoutRowZone, nil, nil, nil)
    ZO_ScrollList_AddDataType(PUGmoWindowZoneListWTS, 1, "ListZoneTpl", 70, PUG.layoutRowZone, nil, nil, nil)
    ZO_ScrollList_AddDataType(PUGmoWindowGroupListUnits, 1, "ListGroupTpl", 40, PUG.layoutRowGroup, nil, nil, nil)
    ZO_ScrollList_AddDataType(PUGmoWindowGroupListUnits, 2, "ButtonItemLinkTpl", 40, PUG.layoutRowGroupItem, nil, nil, nil)

    for x = 1, 4 do
        ZO_ScrollList_AddCategory(PUGmoWindowZoneListLFG, x, nil)
        ZO_ScrollList_AddCategory(PUGmoWindowZoneListWTS, x, nil)
    end

    EM:RegisterForEvent(PUG.name, EVENT_CAPS_LOCK_STATE_CHANGED, function(...)
        PUG:onCapsLock()
    end)
    EM:RegisterForEvent(PUG.name, EVENT_CHAT_MESSAGE_CHANNEL, function(...)
        PUG.onChat(...)
    end)
    EM:RegisterForEvent(PUG.name, EVENT_PLAYER_ACTIVATED, function(...)
        PUG.onPlayerActivated(...)
    end)
    EM:RegisterForEvent(PUG.name, EVENT_GROUP_MEMBER_LEFT, function(...)
        PUG.onUnitLeft(...)
    end)
    EM:RegisterForEvent(PUG.name, EVENT_GROUP_MEMBER_CONNECTED_STATUS, function(...)
        PUG.onUnitDisconnected(...)
    end)
    EM:RegisterForEvent(PUG.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, function(...)
        PUG.onRoleChanged(...)
    end)
    PUG:initGroupList()
end)

-------------------------------------------------------------------------
--- Slash Commands
-------------------------------------------------------------------------
function PUG:cmd(text)
    if text == "" or text == "?" or text == "help" then
        d("\nValid PUGmo commands:\ngo - Starts PUGmo!\nclear bl - clears any players black listed from LFG UI\ncheck - shows the PreCheck Box\nel - toggles Encounter Log\nreset - attempts to resets PUGmo to reload state")
        return

    elseif string.find(text, "test") then
        d("Test Function")
        PUG:test(string.sub(text, 6))
        return

    elseif text == "debug" then
        local s = "off."
        if not PUG.SV.debug then
            s = "on."
        end
        d("Debug " .. s)
        PUG.SV.debug = not PUG.SV.debug
        return

    elseif text == "check" then
        d("Pre-Check")
        PUG:preCheck()
        return

    elseif text == "el" then
        SetEncounterLogEnabled(not IsEncounterLogEnabled())
        d("PUGmo Encounter Log On?", IsEncounterLogEnabled())

    elseif text == "reset" then
        d("Reset")
        PUG:resetAll()
        return


    elseif text == "clear bl" then
        d("Player Blacklist cleared")
        PUG.playerBlacklist = {}
        return

    elseif text == "go" then
        d("PUGmo GO!")
        PUGmoGO()
        return

    else
        d("Command not recognized!")
    end
end

-------------------------------------------------------------------------
function PUG:test(text)
    --PUG.debugBuffer = {
    --    [1] = {
    --        name = "@player1",
    --        role = "DPS",
    --        items = {
    --            "|H0:item:170587:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h",
    --            "|H0:item:170570:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:0:0:0:0:0:0|h|h",
    --            "|H0:item:170575:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --
    --        }
    --    },
    --    [2] = {
    --        name = "@player2",
    --        role = "DPS",
    --        items = {
    --            "|H0:item:170583:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h",
    --            "|H0:item:170589:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h",
    --            "|H0:item:170577:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --
    --        }
    --    },
    --    [3] = {
    --        name = "@player3",
    --        role = "DPS",
    --        items = {
    --            "|H0:item:170584:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h|H0:item:170584:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h",
    --            "|H0:item:170576:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170590:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h",
    --
    --        }
    --    },
    --    [4] = {
    --        name = "@player4",
    --        role = "DPS",
    --        items = {
    --            "|H0:item:170582:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170571:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170586:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h",
    --
    --        }
    --    },
    --    [5] = {
    --        name = "@player5",
    --        role = "DPS",
    --        items = {
    --            "|H0:item:170580:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170573:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170588:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h",
    --
    --        }
    --    },
    --    [6] = {
    --        name = "@player6",
    --        role = "DPS",
    --        items = {
    --            "|H0:item:170410:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170405:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:0:0:0:0:0:0|h|h",
    --            "|H0:item:170422:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h",
    --
    --        }
    --    },
    --    [7] = {
    --        name = "@player7",
    --        role = "DPS",
    --        items = {
    --            "|H0:item:170413:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170413:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170419:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h",
    --
    --        }
    --    },
    --    [8] = {
    --        name = "@player8",
    --        role = "DPS",
    --        items = {
    --            "|H0:item:170415:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170408:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170423:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h",
    --
    --        }
    --    },
    --    [9] = {
    --        name = "@player9",
    --        role = "DPS",
    --        items = {
    --            "|H0:item:170416:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170409:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170420:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h",
    --
    --        }
    --    },
    --    [10] = {
    --        name = "@player10",
    --        role = "DPS",
    --        items = {
    --            "|H0:item:170237:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170232:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:0:0:0:0:0:0|h|h",
    --            "|H0:item:170249:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h",
    --
    --        }
    --    },
    --    [11] = {
    --        name = "@player11",
    --        role = "DPS",
    --        items = {
    --            "|H0:item:170244:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170233:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:0:0|h|h",
    --            "|H0:item:170248:362:50:0:0:0:0:0:0:0:0:0:0:0:2048:116:0:0:0:10000:0|h|h",
    --
    --        }
    --    },
    --
    --}
    --PUG.groupBuffer = PUG.debugBuffer
    --PUG:updateGroupList()

    d(text)
end

-------------------------------------------------------------------------
function PUG:debug(text)
    if PUG.SV.debug then
        d(text)
    end
end

