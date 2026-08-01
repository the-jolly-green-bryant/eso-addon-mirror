-- BugCatcher Object Creation

local tempDB = {}
local msg
local LAM = LibAddonMenu2
local SF = LibSFUtils
local L = GetString
local BC_Colors = BugCatcher.colors


-- BugCatcher colors
local blue    = BC_Colors.blue
local yellow  = BC_Colors.yellow
local cyan    = BC_Colors.cyan
local white   = BC_Colors.white

-- BugCatcher.saved contains table references from the appropriate saved variables
BugCatcher.saved = {    -- loaded from savedvars, see defaults below
}

local default = {   -- default values for saved variables
    offsetx = 15,
    offsety = 15,
    locked = true,
}


-- Load the saved variables. Values are always account-wide.
local function loadSavedVars()
    local isEmpty = SF.isEmpty
    local defaultMissing = SF.defaultMissing

    -- load our saved variables
    BugCatcher.saved = SF.getAcctSavedVars("BugCatcherSavedVars",
		1.0, default)
end


-- BugCatcher Setup Functions

local function onLoad(_, addonName)
    if addonName ~= "BugCatcher" then return end
    BugCatcher.evtmgr:unregEvt(EVENT_ADD_ON_LOADED)

    loadSavedVars()

    BugCatcher.databaseHandler()

    BugCatcher.doMessage = function(textMessage, ...)
        BugCatcher.Send(zo_strformat(blue("Bug Catcher")..white(textMessage)), ...)
    end

    msg = BugCatcher.doMessage or function() end

    BugCatcher.panelData = {
        type                    = "panel",
        name                    = BugCatcher.name,
        displayName             = BugCatcher.displayName,
        author                  = BugCatcher.author,
        version                 = BugCatcher.version,
        slashCommand            = "/bugs",
        registerForRefresh      = true
    }

    BugCatcher.optionsData = {
		{
			type = "checkbox",
			name = BUGCATCHER_LOCKUI_NAME,
			tooltip = BUGCATCHER_LOCKUI,
			getFunc = function() return BugCatcher.saved.locked end,
			setFunc = function(x)
				BugCatcher.saved.locked = x
				BugCatcher.lockWindow()
			end,
            width = "half",
		},  -- end checkbox
        {
            type                    = "button",
            name                    = BUGCATCHER_RESETPOS ,
            func                    = function ()
                                            BugCatcher.ResetPosition()
                                            BugCatcher.setPosition()
                                            BugCatcher.saved.locked = true
                                            BugCatcher.lockWindow()
                                        end,
            disabled                = BugCatcher.saved.locked,
            width                   = "half"
        },

        {
            type                    = "header",
            name                    = BugCatcher.setName
        },

        {
            type                    = "description",
            name                    = SI_BUGCATCHER_BUG_INFO,
            text                    = BugCatcher.setDescription
        },

        {
            type                    = "editbox",
            name                    = "",
            getFunc                 = BugCatcher.setEditBox,
            setFunc                 = function() end,
            isMultiline             = true,
            isExtraWide             = true,
            disabled                = function() return #BugCatcherDB == 0 end,
            width                   = "full",
            reference               = "BugCatcher_EditBox"
        },

        {
            type                    = "button",
            name                    = SI_BUGCATCHER_PREV_BUG ,
            func                    = BugCatcher.previousBug,
            disabled                = function() return BugCatcherDB.bugPage == 1 end,
            width                   = "half"
        },

        {
            type                    = "button",
            name                    = SI_BUGCATCHER_NEXT_BUG,
            func                    = BugCatcher.nextBug,
            disabled                = function() return BugCatcherDB.bugPage == ((#BugCatcherDB == 0) and 1 or #BugCatcherDB) and true or false end,
            width                   = "half"
        },

        {
            type                    = "button",
            name                    = SI_BUGCATCHER_DISMISS_BUG,
            func                    = BugCatcher.dismissBug,
            disabled                = function() return #BugCatcherDB == 0 end,
            width                   = "half"
        },

        {
            type                    = "button",
            name                    = SI_BUGCATCHER_WIPE_ALL_BUGS,
            func                    = BugCatcher.wipeBugs,
            disabled                = function() return #BugCatcherDB == 0 end,
            width                   = "half"
        }
    }

    LAM:RegisterAddonPanel("BugCatcher_Panel",     BugCatcher.panelData)
    LAM:RegisterOptionControls("BugCatcher_Panel", BugCatcher.optionsData)

    if BugCatcher.bugSack then BugCatcher.createBugSack() end

    CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", BugCatcher.setEditBoxSize)

    BugCatcher.isLoaded = true
end

-- BugCatcher LibAddonMenu Functions

function BugCatcher.setName()
    local nobugs_page = cyan.Colorize(SI_BUGCATCHER_NO_BUGS_FOUND)
    local hazbugs_page = SF.str(cyan("Bug "), yellow("<<1>>", cyan(" of "), yellow("<<2>>")))

    if #BugCatcherDB == 0 then
        return zo_strformat(nobugs_page)
    end
    return zo_strformat(hazbugs_page, BugCatcherDB.bugPage, #BugCatcherDB)
end

local desc_template = SF.str(cyan("Caught "), yellow("<<1>>"),
					  cyan(" duplicate<<2>>, last seen on "),
                      yellow("<<3>>"), cyan("."))
local timeStamp_template = SF.str(yellow("<<1>>"), cyan(" at "), yellow("<<2>><<3>>"))
function BugCatcher.setDescription()
    local bugPage = BugCatcherDB.bugPage
    local desc             = desc_template
    local date, time, ampm = (BugCatcherDB.time[BugCatcherDB[bugPage]] or ""):match("(.*) (.*) (.*)")
    local timeStamp        = zo_strformat(timeStamp_template, (date or "?"), (time or "?"), ((ampm or ""):gsub("[.]", "") or "?"))

    if #BugCatcherDB > 0 and desc then
        return zo_strformat(L(SI_BUGCATCHER_CAUGHT_DUPLICATE), (BugCatcherDB.count[BugCatcherDB[bugPage]] or 0), ((BugCatcherDB.count[BugCatcherDB[bugPage]] or 0) == 1 and "" or "s"), (timeStamp or "an unknown time"))
    end
    return cyan(SI_BUGCATCHER_NOTHING)
end

function BugCatcher.setEditBox()
    return (#BugCatcherDB == 0 and "" or BugCatcherDB[BugCatcherDB.bugPage])
end

function BugCatcher.previousBug()
    local bugPage = BugCatcherDB.bugPage
    BugCatcherDB.bugPage = (bugPage and bugPage > 1) and bugPage - 1 or bugPage
end

function BugCatcher.nextBug()
    local bugPage = BugCatcherDB.bugPage
    BugCatcherDB.bugPage = (bugPage and bugPage ~= #BugCatcherDB) and bugPage + 1 or bugPage
end

function BugCatcher.setEditBoxSize(panel)
    if panel ~= BugCatcher_Panel then return end

    if BugCatcher_EditBox then
        BugCatcher_EditBox:SetHeight(24 * 14)
        BugCatcher_EditBox.container:SetHeight(24 * 14)
    end
end

-- BugCatcher Core Functions
-- send (print) a message to ALL chat tabs
function BugCatcher.Send(textMessage, ... )
    if not textMessage or type(textMessage) ~= "string" then return end
    local addonName = BugCatcher.name

    textMessage = addonName and blue(addonName)..": "..textMessage  or textMessage
    textMessage = zo_strformat(textMessage, ...) or textMessage

    for windowIndex = 1, #CHAT_SYSTEM.containers do
        for tabIndex  = 1, #CHAT_SYSTEM.containers[windowIndex].windows do
            CHAT_SYSTEM.containers[windowIndex].windows[tabIndex].buffer:AddMessage(textMessage)
        end
    end
end

function BugCatcher.databaseHandler(wipeBugs)
    if not BugCatcherDB or wipeBugs then
        BugCatcherDB = { time = {}, count = {} }
    end
    BugCatcherDB.bugPage = 1
end

local function errorHandler(_, errorString, errorCode)
    ZO_ERROR_FRAME:HideCurrentError()
 
    if type(errorString or 0) ~= "string" then return end
    if (errorString and errorCode == 0x32BBA739) then return end
 
    if not BugCatcher.isLoaded then
        tempDB[#tempDB + 1] = { errorString, errorCode }
 
        zo_callLater(BugCatcher.readyCheck, 500)
 
        return
    end

    for errorIndex = 1, #BugCatcherDB do
        if (errorString:find("stack traceback") and (BugCatcherDB[errorIndex]:match("^.-stack traceback") == errorString:match("^.-stack traceback"))) or (BugCatcherDB[errorIndex] == errorString) then
            BugCatcherDB.count[errorString] = (BugCatcherDB.count[errorString] or 0) + 1

            BugCatcher.iconHandler(BugCatcher_Panel)

            return
        end
    end

    zo_callLater(function() msg(L(SI_BUGCATCHER_CAUGHT_BUG), #BugCatcherDB) end, 2000)

    BugCatcherDB[#BugCatcherDB + 1] = errorString
    BugCatcherDB.time[errorString]  = zo_strformat("<<1>> <<2>>", (GetDateStringFromTimestamp(GetTimeStamp()) or "?"), (ZO_FormatClockTime() or "?"))

    BugCatcher.iconHandler(BugCatcher_Panel)
end

local readyChkCB
function BugCatcher.readyCheck()
    if BugCatcher.isLoaded then
        local bugIndex

        if not readyChkCB then
           readyChkCB = SF.CallLater:NewSingle(BugCatcher.readyCheck, 500)
        end
        for bugIndex = 1, #tempDB do
            errorHandler(_, unpack(tempDB[bugIndex]))
 
            tempDB[bugIndex] = nil
        end
    else
        readyChkCB:Start()
    end
end



function BugCatcher.dismissBug()
    local bugPage = BugCatcherDB.bugPage
    table.remove(BugCatcherDB, bugPage)

    BugCatcherDB.bugPage = (bugPage == 1) and 1 or (bugPage - 1)

    BugCatcher.iconHandler(BugCatcher_Panel)
end

function BugCatcher.wipeBugs()
    if #BugCatcherDB == 0 then return end

    BugCatcher.databaseHandler(true)

    BugCatcher.iconHandler(BugCatcher_Panel)
end

-- BugCatcher Initialization
BugCatcher.evtmgr:registerEvt(EVENT_LUA_ERROR, errorHandler)
BugCatcher.evtmgr:registerEvt(EVENT_ADD_ON_LOADED, onLoad)
