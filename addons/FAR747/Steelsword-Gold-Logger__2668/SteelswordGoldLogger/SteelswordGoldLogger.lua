SteelswordGoldLogger = {
    name            = "SteelswordGoldLogger",           -- Matches folder and Manifest file names.
    version         = "1.2.3",                -- A nuisance to match to the Manifest.
    author          = "FAR747",
    color           = "DDFFEE",             -- Used in menu titles and so on.
    menuName        = "Steelsword Gold Logger",          -- A UNIQUE identifier for menu object.
    website         = "https://steelsword.ru/",
    classes         = {},
}

local SIGoldReasons = {0,1,2,3,4,5,8,9,11,13,19,21,24,27,28,29,31,32,33,42,43,44,45,47,50,51,52,55,56,57,60,61,62,63,64}

SteelswordGoldLogger.addonGUI = {
    MainWindow = SteelswordGoldLoggerMainWindow,
    curload = {},
    transactions = {},
    days = {},
    bank = {},
}
SteelswordGoldLogger.Temps = {
    lasttransaction = {},
    istransactionlogstart = false,
    --button
    isdaylogsinlist = false,
    isbanklogsinlist = false,
    --
    lasttransaction_time = 0,
    isfirstdayinit = false,
    curdatecreate = false,
    curisnewday = false,
    --bank
    bank = {
        curdatecreate = false,
        isfirstsesstionbankupd = false,
    },
}
SteelswordGoldLogger.Currectuser = {
    userid = "nil",
    charName = "nil",
    charID = 0,
}
SteelswordGoldLogger.Goldvars = {
    Current = 0,
    SessionStart = 0,
    Session = 0,
    Day = 0,
    Bank = 0,
    BankDay = 0,
}
-- Default settings.
SteelswordGoldLogger.defaultVars = {
    firstLoad = true,                   -- First time the addon is loaded ever.
    accountWide = false,                -- Load settings from account savedVars, instead of character.
    greetingmes = true,
    debugmes = false,
    debugautoopengui = false,
    msgundefinedreason = true,
    savetransactions = false,
    savetransactions_max = 3,
    transactionslimitsenable = false,
    transactionsminlimit = 0,
    hidecurrectgold = false,
    stacktransactions = false,
    stacktransactions_timecheck = false,
    stacktransactions_time = 5,
    stacktransactions_isnewonly = true,
    hidebankbutton = false,
    legacybuttons = false,
    autoopeninbank = false,
    -- Saved logs
    logs_transactions = {
        charid = 0,
        lastdate = 0,
        log = {},},
    logs_days = {
        charid = 0,
        lastdate = 0,
        log = {},},
    --last day info
    lastdayinfo = {
        day = "00.00.00",
        gold = -1,
        yesterdaysgold = -1,
    }
}

SteelswordGoldLogger.savedVars = {
    firstLoad = true,                   -- First time the addon is loaded ever.
    accountWide = false, -- Load settings from account savedVars, instead of character.
    msgundefinedreason = true,
    savetransactions = false,
    savetransactions_max = 3,
    transactionslimitsenable = false,
    transactionsminlimit = 0,
    hidecurrectgold = false,
    stacktransactions = false,
    stacktransactions_timecheck = false,
    stacktransactions_time = 5,
    stacktransactions_isnewonly = true,
    hidebankbutton = false,
    legacybuttons = false,
    autoopeninbank = false,
    --DEBUG
    greetingmes = true,
    debugmes = false,
    debugautoopengui = false,

    --savlogs
    logs_transactions = {
        charid = 0,
        lastdate = 0,
        log = {},},
    logs_days = {
        charid = 0,
        lastdate = 0,
        log = {},},
    --last day info
    lastdayinfo = {
        day = "00.00.00",
        gold = -1,
        yesterdaysgold = -1,
    }
}

SteelswordGoldLogger.savedAccinfo = {
    addonversion = SteelswordGoldLogger.version,
    banklog = {
        lastdate = 0,
        lastdatestr = "00.00.00",
        Gold = 0,
        DayGold = 0,
        LastDayGold = 0,
        log = {},}
}
--Vars
--SGM_SlashCommand = "/goldlogger";
local SGM_SavedVars = "SteelswordGoldLoggervars"
local SGL_SavedLogs = "SteelswordGoldLoggerLOGS"
local SGL_SavedAccInfo = "SteelswordGoldLoggerAccvars"
local SGM_Windowstage = false
-- Wraps text with a color.
function SteelswordGoldLogger.Colorize(text, color)
    -- Default to addon's .color.
    if not color then color = SteelswordGoldLogger.color end

    text = string.format('|c%s%s|r', color, text)

    return text
end

function SteelswordGoldLogger.showUserGUI()
    SteelswordGoldLogger.senddebugmes("showUserGUI run")
    SteelswordGoldLogger.updgold()
    SteelswordGoldLogger.addonGUI.MainWindow:SetHidden(false)
    SteelswordGoldLogger.MW_OpenWindowUPD()
    SGM_Windowstage = true;
end

function SteelswordGoldLogger.hideUserGUI()
    SteelswordGoldLogger.senddebugmes("hideUserGUI run")
    SteelswordGoldLogger.addonGUI.MainWindow:SetHidden(true)
    SGM_Windowstage = false;
end

function SteelswordGoldLogger.slashcommand0 (extra) -- /goldlogger
    SteelswordGoldLogger.senddebugmes("/goldlogger command")
    if not  SGM_Windowstage then
        SteelswordGoldLogger.showUserGUI()
    else
        SteelswordGoldLogger.hideUserGUI()
    end
    if extra == "help" then
        d("Help")
    end
end

function SteelswordGoldLogger.BIND_OpenGui ()
    SteelswordGoldLogger.senddebugmes("Key Down")
    if not SGM_Windowstage then
        SteelswordGoldLogger.showUserGUI()
    else
        SteelswordGoldLogger.hideUserGUI()
    end
end

function SteelswordGoldLogger.MoneyUpdateEventHandler (eventCode, newMoney, oldMoney, reason)
    SteelswordGoldLogger.senddebugmes("MoneyUPDEvent: "..eventCode.." New: "..newMoney.." Old: "..oldMoney.." Reason: "..reason)
    SteelswordGoldLogger.Transactionsadd(newMoney,oldMoney,reason)
    SteelswordGoldLogger.updgold()
end

function SteelswordGoldLogger.Transactionsadd(newMoney, oldMoney, reason) -- Transactions Add
    local scrollData = ZO_ScrollList_GetDataList(SteelswordGoldLogger.addonGUI.transactions)
    local TransactionSumm = newMoney - oldMoney
    local isadd = true
    local isupd = false
    local checkstack = true
    local TransactionData = {
        name = SteelswordGoldLogger.GetMoneyUPDReason(reason),
        date = SteelswordGoldLogger.getDateTime(),
        udate = GetTimeStamp(),
        price = TransactionSumm
    }
    if SteelswordGoldLogger.savedVars.transactionslimitsenable then
        if TransactionSumm >= 0 then
            if TransactionSumm > SteelswordGoldLogger.savedVars.transactionsminlimit then
                isadd = true
            else
                isadd = false
            end
        else
            isadd = true
        end
    else
        isadd = true
    end

    if SteelswordGoldLogger.savedVars.stacktransactions_timecheck and SteelswordGoldLogger.Temps.lasttransaction_time > 0 then
        local ts = GetTimeStamp()
        local lastrecordtime = SteelswordGoldLogger.Temps.lasttransaction_time + SteelswordGoldLogger.savedVars.stacktransactions_time
        if ts > lastrecordtime then
        checkstack = false
        end
    end

    if SteelswordGoldLogger.savedVars.stacktransactions and SteelswordGoldLogger.Temps.istransactionlogstart and checkstack then
        SteelswordGoldLogger.senddebugmes("stack test")
        local t = 1
        local lastindex = #scrollData
        for _,lastitem in pairs(scrollData) do
            if t == lastindex then
                if lastitem.data.name == TransactionData.name then
                lastitem.data:Add(TransactionData)
                isupd = true
                isadd = false
                end
                break
            end
            t = t+1
        end
        --[[if lastindex.name == TransactionData.name then
            lastindex:Add(TransactionData)
            isupd = true
            isadd = false
        end--]]
    end
    if isadd then
        local data = SGLogDetail:New(TransactionData)
        scrollData[#scrollData+1] = ZO_ScrollList_CreateDataEntry(1, data)
        --SteelswordGoldLogger.Temps.lasttransaction = data
        ZO_ScrollList_Commit(SteelswordGoldLogger.addonGUI.transactions)
        SteelswordGoldLogger.Temps.istransactionlogstart = true
        SteelswordGoldLogger.Temps.lasttransaction_time = GetTimeStamp()
    end
    if isupd then
        ZO_ScrollList_Commit(SteelswordGoldLogger.addonGUI.transactions)
        if not SteelswordGoldLogger.savedVars.stacktransactions_isnewonly then
            SteelswordGoldLogger.Temps.lasttransaction_time = GetTimeStamp()
        end
    end
    if SteelswordGoldLogger.savedVars.savetransactions then
        SteelswordGoldLogger.savedlogsUPD(true)
    end
    
end


function SteelswordGoldLogger.updgold()
    local gold = SteelswordGoldLogger.Getcurrectgold()
    SteelswordGoldLogger.Goldvars.Current = gold;
    SteelswordGoldLogger.Goldvars.Session = gold - SteelswordGoldLogger.Goldvars.SessionStart
    SteelswordGoldLogger.setcurrectgold(gold) -- GET Currect Gold
    SteelswordGoldLogger.setsessiongold(SteelswordGoldLogger.Goldvars.Session)
    SteelswordGoldLogger.lastdayinit()
    SteelswordGoldLogger.lastdayUPD()
    SteelswordGoldLogger.UPDWindowEv()
end

function SteelswordGoldLogger.senddebugmes (debugtext)
    if SteelswordGoldLogger.savedVars.debugmes then
    d("|cf11100SGL Debug:|r "..debugtext)
    end
end

function SteelswordGoldLogger.sendWarningmes (mestext)
    d("|cf11100SGL Warning:|r "..mestext)
end

SLASH_COMMANDS["/goldlogger"] = SteelswordGoldLogger.slashcommand0

-- Only show the loading message on first load ever.
function SteelswordGoldLogger.Activated(e)
    EVENT_MANAGER:UnregisterForEvent(SteelswordGoldLogger.name, EVENT_PLAYER_ACTIVATED)
    SteelswordGoldLogger.senddebugmes(GetString(SI_SGL_DEBUG_MESSAGE))
    SteelswordGoldLogger.senddebugmes("Addon Active")
    SteelswordGoldLogger.UserInit()
    SteelswordGoldLogger.senddebugmes("Current Gold ".. SteelswordGoldLogger.Getcurrectgold())
    SteelswordGoldLogger.Goldvars.Current = SteelswordGoldLogger.Getcurrectgold()
    SteelswordGoldLogger.Goldvars.SessionStart = SteelswordGoldLogger.Goldvars.Current
    SteelswordGoldLogger.Windowinit()
    SteelswordGoldLogger.lastdayinit()
    SteelswordGoldLogger.daysloginit()
    SteelswordGoldLogger.Bankloginit()
    if SteelswordGoldLogger.savedVars.greetingmes then
    d(string.format(GetString(SI_SGL_DEBUG_MESSAGE_GREETING),SteelswordGoldLogger.version))
    end
    if SteelswordGoldLogger.savedVars.debugautoopengui then
        SteelswordGoldLogger.senddebugmes("Auto open addon window enabled")
        SteelswordGoldLogger.showUserGUI()
    end
    if (SteelswordGoldLogger.savedVars.savetransactions)then
        SteelswordGoldLogger.savedLogsLoad()
    end
    
end


function SteelswordGoldLogger.OnAddOnLoaded(event, addonName)
   if addonName ~= SteelswordGoldLogger.name then return end
   EVENT_MANAGER:UnregisterForEvent(SteelswordGoldLogger.name, EVENT_ADD_ON_LOADED)

    -- Load saved variables.
    SteelswordGoldLogger.characterSavedVars = ZO_SavedVars:NewCharacterIdSettings(SGM_SavedVars, 1, nil, SteelswordGoldLogger.savedVars)
    SteelswordGoldLogger.accountSavedVars = ZO_SavedVars:NewAccountWide(SGM_SavedVars, 1, nil, SteelswordGoldLogger.savedVars)
    SteelswordGoldLogger.AccSavedVarsLoad = ZO_SavedVars:NewAccountWide(SGL_SavedAccInfo, 1, nil, SteelswordGoldLogger.savedAccinfo)

    if not SteelswordGoldLogger.characterSavedVars.accountWide then
        SteelswordGoldLogger.savedVars = SteelswordGoldLogger.characterSavedVars
    else
        SteelswordGoldLogger.savedVars = SteelswordGoldLogger.accountSavedVars
    end
    SteelswordGoldLogger.savedAccinfo = SteelswordGoldLogger.AccSavedVarsLoad
    -- When player is ready, after everything has been loaded.
    EVENT_MANAGER:RegisterForEvent(SteelswordGoldLogger.name, EVENT_PLAYER_ACTIVATED, SteelswordGoldLogger.Activated)
    EVENT_MANAGER:RegisterForEvent(SteelswordGoldLogger.name, EVENT_MONEY_UPDATE, SteelswordGoldLogger.MoneyUpdateEventHandler)
    EVENT_MANAGER:RegisterForEvent(SteelswordGoldLogger.name, EVENT_BANKED_MONEY_UPDATE, SteelswordGoldLogger.BankMoneyUpdateEventHandler)
    --Open/Close BANK
    EVENT_MANAGER:RegisterForEvent(SteelswordGoldLogger.name, EVENT_OPEN_BANK, SteelswordGoldLogger.OpenBankEventHandler)
    EVENT_MANAGER:RegisterForEvent(SteelswordGoldLogger.name, EVENT_CLOSE_BANK, SteelswordGoldLogger.CloseBankEventHandler)
    SteelswordGoldLogger.LoadSettings()
   SteelswordGoldLogger.addonGUI.MainWindow = SteelswordGoldLoggerMainWindow
   SteelswordGoldLogger.LeagcyInit()
   SteelswordGoldLogger.ToolTipsInit()
end
-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(SteelswordGoldLogger.name, EVENT_ADD_ON_LOADED, SteelswordGoldLogger.OnAddOnLoaded)

function SteelswordGoldLogger.Getcurrectgold()
    return GetCurrentMoney()
end

function SteelswordGoldLogger.UserInit()
    local userid = GetDisplayName()
    local charID = GetCurrentCharacterId()
    local charName = zo_strformat("<<1>>",GetRawUnitName("player"))
    SteelswordGoldLogger.Currectuser.userid = userid
    SteelswordGoldLogger.Currectuser.charID = charID
    SteelswordGoldLogger.Currectuser.charName = charName
    SteelswordGoldLogger.senddebugmes("UserInfo: "..charName..userid)
end

function SteelswordGoldLogger.getDateTime()
    local date = GetDateStringFromTimestamp(GetTimeStamp()) 
    local time = GetTimeString()
    local str0 = date.." "..time
    return str0
end

function SteelswordGoldLogger.GetMoneyUPDReason(reason)
    local found = false
    local ret = "nil"
    for index, value in ipairs(SIGoldReasons) do
        if reason == value then
            found = true
        end
    end
    if found then
        ret = GetString("SI_SGL_GUPD_REASON_", reason)
    else
        ret = GetString(SI_SGL_GUPD_REASON_UNDEFINED)
        ret = ret.." ("..reason..")"
        if (SteelswordGoldLogger.savedVars.msgundefinedreason) then
            SteelswordGoldLogger.sendWarningmes(string.format(GetString(SI_SGL_GUPD_REASON_UNDEFINED_MSG), reason))
        end
    end

    return ret
end

function SteelswordGoldLogger.savedLogsSettingsEVN(value)
    if value then
        SteelswordGoldLogger.savedlogsUPD(false)
        if SteelswordGoldLogger.Temps.istransactionlogstart then
            SteelswordGoldLogger.savedlogsUPD(true)
        end
    else
        SteelswordGoldLogger.savedVars.logs_transactions = nil
    end
end

function SteelswordGoldLogger.savedLogsLoad()
    if not SteelswordGoldLogger.savedVars.savetransactions then
        return false
    end
    local savlogdata = SteelswordGoldLogger.savedVars.logs_transactions.log
    local scrollData = ZO_ScrollList_GetDataList(SteelswordGoldLogger.addonGUI.transactions)
    for _,lastitem in ipairs(savlogdata) do
        local TransactionData = {
            name = lastitem.name,
            date = lastitem.date,
            udate = lastitem.udate,
            price = lastitem.price,
        }
        local data = SGLogDetail:New(TransactionData)
        scrollData[#scrollData+1] = ZO_ScrollList_CreateDataEntry(1, data)
    end
    
        ZO_ScrollList_Commit(SteelswordGoldLogger.addonGUI.transactions)
        SteelswordGoldLogger.Temps.istransactionlogstart = true
        SteelswordGoldLogger.Temps.lasttransaction_time = GetTimeStamp()
end

function SteelswordGoldLogger.savedlogsUPD(isupd)
    if not SteelswordGoldLogger.savedVars.savetransactions then
    return false
    end
    if isupd then
        local scrollData = ZO_ScrollList_GetDataList(SteelswordGoldLogger.addonGUI.transactions)
        local t = 1
        local tm = 1
        local maxitem = SteelswordGoldLogger.savedVars.savetransactions_max
        local lastindex = #scrollData
        local setdata = {}
        if lastindex <= maxitem then
            tm = 1
        else
            tm = lastindex - maxitem
        end
        for _,lastitem in pairs(scrollData) do
           if t > tm then
            local ltdata = lastitem.data
            local locdata = {
                name = ltdata.name,
                date = ltdata.date,
                udate = ltdata.udate,
                price = ltdata.price,
            }
            setdata[#setdata+1] = locdata
            end
        
            t = t+1
        end
            SteelswordGoldLogger.savedVars.logs_transactions.charid = SteelswordGoldLogger.Currectuser.charID
            SteelswordGoldLogger.savedVars.logs_transactions.lastdate = GetTimeStamp()
            local setlogs = SteelswordGoldLogger.savedVars.logs_transactions.log
            SteelswordGoldLogger.savedVars.logs_transactions.log = setdata
    elseif not isupd then
        local setdata = {
            charid = SteelswordGoldLogger.Currectuser.charID,
            lastdate = GetTimeStamp(),
            log = {},
        }
        SteelswordGoldLogger.savedVars.logs_transactions = setdata
    else
        return false
    end
end

function SteelswordGoldLogger.lastdayinit()
    local curdate = GetDateStringFromTimestamp(GetTimeStamp())
    local isnewday = false
    if SteelswordGoldLogger.savedVars.lastdayinfo.gold == -1 then
        SteelswordGoldLogger.savedVars.lastdayinfo.gold = SteelswordGoldLogger.Goldvars.Current
        SteelswordGoldLogger.savedVars.lastdayinfo.yesterdaysgold = SteelswordGoldLogger.Goldvars.Current
        SteelswordGoldLogger.savedVars.lastdayinfo.day = curdate
    end

    if SteelswordGoldLogger.savedVars.lastdayinfo.day ~= curdate then
        isnewday = true
        SteelswordGoldLogger.Temps.curisnewday = true
        SteelswordGoldLogger.savedVars.lastdayinfo.yesterdaysgold = SteelswordGoldLogger.savedVars.lastdayinfo.gold
        SteelswordGoldLogger.savedVars.lastdayinfo.day = curdate
        SteelswordGoldLogger.savedVars.lastdayinfo.gold = SteelswordGoldLogger.Goldvars.Current
        
    else
        
    end
    SteelswordGoldLogger.savedVars.lastdayinfo.gold = SteelswordGoldLogger.Goldvars.Current
    local curgold = SteelswordGoldLogger.savedVars.lastdayinfo.gold - SteelswordGoldLogger.savedVars.lastdayinfo.yesterdaysgold
    SteelswordGoldLogger.Goldvars.Day = curgold
    SteelswordGoldLogger.setdaygold(curgold)
end

function SteelswordGoldLogger.daysloginit(isnewday)
    local curdate = GetDateStringFromTimestamp(GetTimeStamp())
    local scrollData = ZO_ScrollList_GetDataList(SteelswordGoldLogger.addonGUI.days)
    SteelswordGoldLogger.dayslogload()
    if SteelswordGoldLogger.Temps.curisnewday then
        local TransactionData = {
        date = curdate,
        udate = GetTimeStamp(),
        price = SteelswordGoldLogger.Goldvars.Day,
        name = ZO_CurrencyControl_FormatCurrencyAndAppendIcon(SteelswordGoldLogger.Goldvars.Current, false, CURT_MONEY, false),
        }
        local data = SGLogDetail:New(TransactionData)
        scrollData[#scrollData+1] = ZO_ScrollList_CreateDataEntry(1, data)
        ZO_ScrollList_Commit(SteelswordGoldLogger.addonGUI.days)
        SteelswordGoldLogger.Temps.curdatecreate = true
        SteelswordGoldLogger.lastdayUPD()
    
    end
    
end

function SteelswordGoldLogger.dayslogload()
    local savlogdata = SteelswordGoldLogger.savedVars.logs_days.log
    local curdate = GetDateStringFromTimestamp(GetTimeStamp())
    local isnil = true
    if SteelswordGoldLogger.savedVars.logs_days.charid == 0 then
        SteelswordGoldLogger.savedVars.logs_days.charid = SteelswordGoldLogger.Currectuser.charID
        SteelswordGoldLogger.savedVars.logs_days.lastdate = GetTimeStamp()
    end
    local scrollData = ZO_ScrollList_GetDataList(SteelswordGoldLogger.addonGUI.days)
    for _,lastitem in ipairs(savlogdata) do
        local TransactionData = {
            name = lastitem.name,
            date = lastitem.date,
            udate = lastitem.udate,
            price = lastitem.price,
        }
        local data = SGLogDetail:New(TransactionData)
        scrollData[#scrollData+1] = ZO_ScrollList_CreateDataEntry(1, data)
        isnil = false
    end
        ZO_ScrollList_Commit(SteelswordGoldLogger.addonGUI.days)
    if isnil then
        local TransactionData = {
            name = ZO_CurrencyControl_FormatCurrencyAndAppendIcon(SteelswordGoldLogger.Goldvars.Current, false, CURT_MONEY, false),
            date = curdate,
            udate = GetTimeStamp(),
            price = 0,
        }
        local data = SGLogDetail:New(TransactionData)
        scrollData[#scrollData+1] = ZO_ScrollList_CreateDataEntry(1, data)
        ZO_ScrollList_Commit(SteelswordGoldLogger.addonGUI.days)
        SteelswordGoldLogger.Temps.curdatecreate = true
    end
end

function SteelswordGoldLogger.lastdayUPD()
    local curdate = GetDateStringFromTimestamp(GetTimeStamp())
    local scrollData = ZO_ScrollList_GetDataList(SteelswordGoldLogger.addonGUI.days)
    local isfound = false
    
    for _,lastitem in pairs(scrollData) do
        
        if lastitem.data.date == curdate then
            isfound = true
            local TransactionData = {
                name = ZO_CurrencyControl_FormatCurrencyAndAppendIcon(SteelswordGoldLogger.Goldvars.Current, false, CURT_MONEY, false),
                date = curdate,
                udate = GetTimeStamp(),
                price = SteelswordGoldLogger.Goldvars.Day,
                isday = true
            }
            lastitem.data:Add(TransactionData)
            ZO_ScrollList_Commit(SteelswordGoldLogger.addonGUI.days)
            break
        end
        
    end
    if not isfound then
        local TransactionData = {
            name = ZO_CurrencyControl_FormatCurrencyAndAppendIcon(SteelswordGoldLogger.Goldvars.Current, false, CURT_MONEY, false),
            date = curdate,
            udate = GetTimeStamp(),
            price = 0,
        }
        local data = SGLogDetail:New(TransactionData)
        scrollData[#scrollData+1] = ZO_ScrollList_CreateDataEntry(1, data)
        ZO_ScrollList_Commit(SteelswordGoldLogger.addonGUI.days)
        SteelswordGoldLogger.Temps.curdatecreate = true
    end
    SteelswordGoldLogger.daylogssav()
end
function SteelswordGoldLogger.daylogssav()
    local scrollData = ZO_ScrollList_GetDataList(SteelswordGoldLogger.addonGUI.days)
        local t = 1
        local tm = 1
        local maxitem = 60
        local lastindex = #scrollData
        local setdata = {}
        if lastindex <= maxitem then
            tm = 1
        else
            tm = lastindex - maxitem
        end
        for _,lastitem in pairs(scrollData) do
           if t >= tm then
            local ltdata = lastitem.data
            local locdata = {
                name = ltdata.name,
                date = ltdata.date,
                udate = ltdata.udate,
                price = ltdata.price,
            }
            setdata[#setdata+1] = locdata
            end
            t = t+1
        end
            SteelswordGoldLogger.savedVars.logs_days.charid = SteelswordGoldLogger.Currectuser.charID
            SteelswordGoldLogger.savedVars.logs_days.lastdate = GetTimeStamp()
            local setlogs = SteelswordGoldLogger.savedVars.logs_days.log
            SteelswordGoldLogger.savedVars.logs_days.log = setdata
end


function SteelswordGoldLogger.OpenBankEventHandler(eventCode, bankBag)
    if bankBag == BAG_BANK and SteelswordGoldLogger.savedVars.autoopeninbank then
        SteelswordGoldLogger.showUserGUI()
        SteelswordGoldLogger.GUIButtonsClick(2)
    end
end

function SteelswordGoldLogger.CloseBankEventHandler(eventCode, bankBag)
    if SteelswordGoldLogger.savedVars.autoopeninbank then
        SteelswordGoldLogger.hideUserGUI()
    end
end