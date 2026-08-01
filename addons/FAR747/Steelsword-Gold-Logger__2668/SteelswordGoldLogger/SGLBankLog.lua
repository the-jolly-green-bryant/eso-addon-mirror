function SteelswordGoldLogger.BankMoneyUpdateEventHandler(eventCode, newMoney, oldMoney)
    SteelswordGoldLogger.senddebugmes("BankMoneyUPDEvent: "..eventCode.." New: "..newMoney.." Old: "..oldMoney)
    SteelswordGoldLogger.BankLogUPD(newMoney, oldMoney)
end

function SteelswordGoldLogger.BankLogUPD(newMoney, oldMoney)
    local curdate = GetDateStringFromTimestamp(GetTimeStamp())
    local isnewday = false
    if SteelswordGoldLogger.savedAccinfo.banklog.lastdatestr ~= curdate then
    isnewday = true
    --SteelswordGoldLogger.savedAccinfo.banklog.lastdatestr = curdate
    SteelswordGoldLogger.savedAccinfo.banklog.LastDayGold = SteelswordGoldLogger.savedAccinfo.banklog.Gold
    end
    SteelswordGoldLogger.Goldvars.Bank = newMoney
    SteelswordGoldLogger.Goldvars.BankDay = newMoney - SteelswordGoldLogger.savedAccinfo.banklog.LastDayGold
    SteelswordGoldLogger.savedAccinfo.banklog.Gold = newMoney
    SteelswordGoldLogger.savedAccinfo.banklog.DayGold = SteelswordGoldLogger.Goldvars.BankDay
    SteelswordGoldLogger.BankListLogUPD()

    SteelswordGoldLogger.Temps.bank.isfirstsesstionbankupd = true
    SteelswordGoldLogger.MW_WarningMessageUPD(true, "nil")
end

function SteelswordGoldLogger.Bankloginit(isnewday)
    local curdate = GetDateStringFromTimestamp(GetTimeStamp())
    local scrollData = ZO_ScrollList_GetDataList(SteelswordGoldLogger.addonGUI.bank)
    SteelswordGoldLogger.Banklogload()
    local curdate = GetDateStringFromTimestamp(GetTimeStamp())
    local isnewday = false
    if SteelswordGoldLogger.savedAccinfo.banklog.lastdatestr ~= curdate then
    isnewday = true
    SteelswordGoldLogger.savedAccinfo.banklog.lastdatestr = curdate
    end
    if isnewday then
        local TransactionData = {
        date = curdate,
        udate = GetTimeStamp(),
        price = SteelswordGoldLogger.Goldvars.BankDay,
        name = ZO_CurrencyControl_FormatCurrencyAndAppendIcon(SteelswordGoldLogger.Goldvars.Bank, false, CURT_MONEY, false),
        }
        local data = SGLogDetail:New(TransactionData)
        scrollData[#scrollData+1] = ZO_ScrollList_CreateDataEntry(1, data)
        ZO_ScrollList_Commit(SteelswordGoldLogger.addonGUI.bank)
        SteelswordGoldLogger.Temps.bank.curdatecreate = true
        SteelswordGoldLogger.savedAccinfo.banklog.LastDayGold = SteelswordGoldLogger.savedAccinfo.banklog.Gold
        
    end
    
end

function SteelswordGoldLogger.Banklogload()
    local savlogdata = SteelswordGoldLogger.savedAccinfo.banklog.log
    local curdate = GetDateStringFromTimestamp(GetTimeStamp())
    local isnil = true
    if SteelswordGoldLogger.savedAccinfo.banklog.lastdate == 0 then
        SteelswordGoldLogger.savedAccinfo.banklog.lastdate = GetTimeStamp()
    end
    local scrollData = ZO_ScrollList_GetDataList(SteelswordGoldLogger.addonGUI.bank)
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
        ZO_ScrollList_Commit(SteelswordGoldLogger.addonGUI.bank)
    if isnil then
        local TransactionData = {
            name = ZO_CurrencyControl_FormatCurrencyAndAppendIcon(SteelswordGoldLogger.Goldvars.Bank, false, CURT_MONEY, false),
            date = curdate,
            udate = GetTimeStamp(),
            price = 0,
        }
        local data = SGLogDetail:New(TransactionData)
        scrollData[#scrollData+1] = ZO_ScrollList_CreateDataEntry(1, data)
        ZO_ScrollList_Commit(SteelswordGoldLogger.addonGUI.bank)
        SteelswordGoldLogger.Temps.bank.curdatecreate = true
        SteelswordGoldLogger.savedAccinfo.banklog.lastdatestr = GetDateStringFromTimestamp(GetTimeStamp())
        SteelswordGoldLogger.savedAccinfo.banklog.LastDayGold = SteelswordGoldLogger.savedAccinfo.banklog.Gold
        SteelswordGoldLogger.Goldvars.BankDay = 0
    end
end

function SteelswordGoldLogger.Banklogssav()
    local scrollData = ZO_ScrollList_GetDataList(SteelswordGoldLogger.addonGUI.bank)
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
            SteelswordGoldLogger.savedAccinfo.banklog.lastdate = GetTimeStamp()
            SteelswordGoldLogger.savedAccinfo.banklog.log = setdata
end


function SteelswordGoldLogger.BankListLogUPD()
    local curdate = GetDateStringFromTimestamp(GetTimeStamp())
    local scrollData = ZO_ScrollList_GetDataList(SteelswordGoldLogger.addonGUI.bank)
    local isfound = false
    
    for _,lastitem in pairs(scrollData) do
        
        if lastitem.data.date == curdate then
            isfound = true
            local TransactionData = {
                name = ZO_CurrencyControl_FormatCurrencyAndAppendIcon(SteelswordGoldLogger.Goldvars.Bank, false, CURT_MONEY, false),
                date = curdate,
                udate = GetTimeStamp(),
                price = SteelswordGoldLogger.Goldvars.BankDay,
                isday = true
            }
            lastitem.data:Add(TransactionData)
            ZO_ScrollList_Commit(SteelswordGoldLogger.addonGUI.bank)
            break
        end
        
    end
    if not isfound then
        local TransactionData = {
            name = ZO_CurrencyControl_FormatCurrencyAndAppendIcon(SteelswordGoldLogger.Goldvars.Bank, false, CURT_MONEY, false),
            date = curdate,
            udate = GetTimeStamp(),
            price = SteelswordGoldLogger.Goldvars.BankDay,
        }
        local data = SGLogDetail:New(TransactionData)
        scrollData[#scrollData+1] = ZO_ScrollList_CreateDataEntry(1, data)
        ZO_ScrollList_Commit(SteelswordGoldLogger.addonGUI.bank)
        SteelswordGoldLogger.Temps.bank.curdatecreate = true
        SteelswordGoldLogger.savedAccinfo.banklog.lastdatestr = GetDateStringFromTimestamp(GetTimeStamp())
        SteelswordGoldLogger.savedAccinfo.banklog.DayGold = 0
        --SteelswordGoldLogger.savedAccinfo.banklog.LastDayGold = SteelswordGoldLogger.savedAccinfo.banklog.Gold
        SteelswordGoldLogger.Goldvars.BankDay = 0
    end
    SteelswordGoldLogger.Banklogssav()
end

function SteelswordGoldLogger.WARNINGMESSAGE_SetBankUPDMessage()
    local text = "|cf11100"..GetString(SI_SGL_WARNINGMESSAGE_BANKUPD).."|r"
    SteelswordGoldLogger.MW_WarningMessageUPD(false, text)
end