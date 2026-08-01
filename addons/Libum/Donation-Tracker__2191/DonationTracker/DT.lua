-- Some constants
DT = {
    SAVED_VARIABLES = "DTSAVEDATA",
    VERSION = "1.20",
    NAME = "DonationTracker",
    TITLE = "Donation Tracker"
}

DT.DATA_DEFAULTS = {
    VERSION = DT.VERSION,
    Accounts = {},
    CustomPrice = {},
    CustomNotes = {},
    OBORecords = {},
    CurMailNum = 0,
    LastGBUpdated = GetTimeStamp(),
    -- RaffleUnlimited meta info
    RUTickets = {},
    RUIgnore = {},
    -- UI Settings
    WinLeft = 450,
    WinTop = 120,
    -- Settings
    IsMailAutoTrack = true,
    IsForwarder = false,
    ForwarderTarget = "",
    GuildIndex = nil,
    -- Voucher Counter
    VoucherCounter = {
        IsIgnoreJewelryWrits = true
    },
    -- Multipliers
    IsMulRetrospective = true,
    GoldValMul = 1,
    EquipMatsMul = 1,
    JCMatsMul = 1,
    ConsumMatsMul = 1,
    AlchemyMatsMul = 1,
    FurnishMatsMul = 1,
    WritsMul = 1,
    JCWritsMul = 1,
    ClothierIntricatesMul = 1,
    BSIntricatesMul = 1,
    WWIntricatesMul = 1,
    JCIntricatesMul = 1,
    GearMul = 1,
    MiscMul = 1,
    -- Price guesser
    PricingOrder = {"Custom", "GearForDecon", "MM", "TTCSuggested", "TTCAvg", "WritFormula"},
    MMTTC = {
        MinDataPoints = 5
    },
    WritFormula = {
        IsRetrospective = true,
        IsIgnoreMatsCost = false,
        VoucherBaseValue = 1000,
        JCVoucherBaseValue = 1000
    },
    GearForDecon = {
        IsIgnoreJewelry = false,
        IntricateValue = 200,
        JCIntricateValue = 300,
        NormalValue = 200,
        FineValue = 200,
        SuperiorValue = 200,
        EpicValue = 300,
        LegendaryValue = 500
    }
}

DT.CATEGORY_DESC = {
    EquipMats = "Clothier/BS/WW Materials",
    JCMats = "Jewelry Materials",
    ConsumMats = "Provisioning/Enchanting Materials",
    AlchemyMats = "Alchemy Materials",
    FurnishMats = "Furnishing Materials",
    Writs = "Non-JC Master Writs",
    JCWrits = "JC Master Writs",
    ClothierIntricates = "Clothier Intricates",
    BSIntricates = "Blacksmithing Intricates",
    WWIntricates = "Woodworking Intricates",
    JCIntricates = "Jewelry Intricates",
    Gear = "Gear/Equipment",
    Misc = "Misc",
    -- Categories not used right now
    Intricates = "Intricates",
    Mats = "Mats"
}

---- Table templates
DT.ACCOUNT_TBL = {Account=nil, CustomCash=0, Items={}, ItemsOwed={}, GoldObjs={}}
DT.ITEM_TBL = {Account=nil, Key=0, Link=nil, Name=nil, Count=0, Category="Misc", PriceSource=nil, Price=nil, Multiplier=1, ReceivedTime=nil, IsGB=nil, MailId=nil}
DT.GOLD_TBL = {Account=nil, Amount=0, Multiplier=1, ReceivedTime=nil, IsGB=nil, MailId=nil}
DT.MAIL_TBL = {Sender=nil, Subject=nil, ReceivedTime=nil, Attachments={}, MailCash=nil, IsCOD=nil, IsSenderUser=nil, MailRecId=nil}
DT.OBO_TBL = {Sender=nil, Beneficiary=nil, Cash=0, ItemsStr="", ItemsLinkStr="", ReceivedTime=nil, IsForward=false, MailId=nil}

---- Data fixer
function DT.TryFixData(isForced)
    if isForced == nil then isForced = false end

    local function SetDefault(obj, template)
        for k,v in pairs(template) do
            if obj[k] == nil then
                obj[k] = (type(template[k]) == "table" and DT.Clone(template[k]) or template[k])
            end
        end
    end
    
    local function RenameSetting(oldStr, newStr)
        if DT.Data[oldStr] ~= nil then
            DT.Data[newStr] = DT.Data[oldStr]
            DT.Data[oldStr] = nil
        end
    end
    
    if DT.Data.GuildIndex ~= nil and DT.Data.GuildIndex > GetNumGuilds() then
        DT.Data.GuildIndex = nil
    end
    
    RenameSetting("DataVersion", "VERSION")
    
    if isForced or DT.Data.VERSION ~= DT.VERSION then
        -- Update Categories
        DT.RecalcCategories()
        for accName, acc in pairs(DT.Data.Accounts) do
            -- Add gold table
            if acc.GoldObjs == nil then
                acc.GoldObjs = {}
                if acc.MailCash > 0 then
                    local goldObj = DT.Clone(DT.GOLD_TBL)
                    goldObj.Amount = acc.MailCash
                    goldObj.Account = acc.Account
                    goldObj.Multiplier = 1
                    goldObj.ReceivedTime = GetTimeStamp()
                    goldObj.IsGB = false
                    goldObj.MailId = 0
                    table.insert(acc.GoldObjs, goldObj)
                end
            end
            -- Fix some gold table errors
            DT.ArrayRemove(acc.GoldObjs, function(goldObj, i)
                return goldObj.Amount == 0 or goldObj.Amount == nil
            end)
            -- Fix some item values
            for i, item in pairs(acc.Items) do
                if item.Key == nil then item.Key = DT.GetItemLinkKey(item.Link) end
                if item.Multiplier == nil then item.Multiplier = 1 end
                if item.PriceSource == "TTC" then item.PriceSource = "TTCSuggested" end
                if item.PriceSource == "Writ Formula" then item.PriceSource = "WritFormula" end
                if not item.IsGB and item.MailId == nil then item.MailId = 0 end
                SetDefault(item, DT.ITEM_TBL)
            end
            -- Get rid of old variables
            acc.MailCash = nil
            acc.GBCash = nil
            
            SetDefault(acc, DT.ACCOUNT_TBL)
        end
        for i, oboRec in pairs(DT.Data.OBORecords) do
            if oboRec.MailId == nil then oboRec.MailId = 0 end
            SetDefault(oboRec, DT.OBO_TBL)
        end
        for oldKey, price in pairs(DT.Data.CustomPrice) do
            if tonumber(oldKey) ~= nil then
                local newKey = DT.GetItemLinkKey(oldKey)
                DT.Data.CustomPrice[oldKey] = nil
                DT.Data.CustomPrice[newKey] = price
            end
        end
        -- Fix some global settings
        RenameSetting("JewelryIntricatesMul", "JCIntricatesMul")
        RenameSetting("JewelryMatsMul", "JCMatsMul")
        SetDefault(DT.Data.GearForDecon, DT.DATA_DEFAULTS.GearForDecon)
        SetDefault(DT.Data.WritFormula, DT.DATA_DEFAULTS.WritFormula)
        SetDefault(DT.Data.MMTTC, DT.DATA_DEFAULTS.MMTTC)
        DT.Data.VERSION = DT.VERSION
        DT.SystemPrintf("[DonationTracker] Data updated to version %s", DT.Data.VERSION)
    end
end

---- Session-only globals
DT.IsTrackPressed = false
DT.IsCurMailForwarded = false
DT.IsCurMailWithAttachments = false
DT.IsCurMailFromUser = false
DT.PreTakeAttachmentMail = nil

DT.IsGBUpdating = false

function DT.UpdateGuildHist()
    local function OnProccessed(lastEventTS, itemCount, goldAmt)
        DT.IsGBUpdating = false
        if lastEventTS ~= nil then
            local oldTS = DT.Data.LastGBUpdated
            DT.Data.LastGBUpdated = lastEventTS
            DT.SystemPrintf("[DonationTracker] Guild bank scanned for [%s] -> [%s]. Tracked %d items and %s.", os.date("%c", oldTS), os.date("%c", lastEventTS), itemCount, DT.FormatMoney(goldAmt))
            DT.UI.ItemScrollList:RefreshData()
            DT.UI.DonorScrollList:RefreshData()
        else
            local msg = itemCount
            DT.Error(string.format("[DonationTracker] GetGuildHist: %s", msg))
        end
    end

    if DT.Data.GuildIndex ~= nil then
        if DT.IsGBUpdating == true then
            DT.SystemPrintf("[DonationTracker] Guild bank update already in progress, please be patient as this involves sending requests to the server")
        else
            DT.IsGBUpdating = true
            DT.ProcessGuildHist(DT.Data.GuildIndex, DT.Data.LastGBUpdated, OnProccessed)
        end
    else
        DT.SystemPrintf("[DonationTracker] Please set a guild in the settings menu to start tracking its guild bank")
    end
end

function DT.ProcessGuildHist(guildIndex, cutoffTS, cb)
    local STACK_SPLIT_SECS = 60*10 -- if there is a withdraw -> deposit within 10 minutes we consider that stack splitting
    local lastEventTS = cutoffTS
    local itemCount = 0
    local goldAmt = 0
    
    local function OnGuildHistResult(histList, msg)
        if histList == nil then return cb(nil, msg) end
        -- Aggregate stack splitting events (i.e withdrawing but putting most of a stack back)
        local aggRows = {}
        for i,row in ipairs(histList) do
            -- param1 -> Account
            -- param2 -> Count/Gold
            -- param3 -> Link/nil
            
            if row.timeStamp > lastEventTS then lastEventTS = row.timeStamp end
            local isGold = (row.eventType == GUILD_EVENT_BANKGOLD_ADDED)
            local isDeposit = (row.subcategoryId == GUILD_HISTORY_BANK_DEPOSITS)
            row.param2 = tonumber(row.param2)
            if not isGold then
                local key = row.param1..DT.GetItemLinkKey(row.param3)
                local aggRow = aggRows[key]
                if aggRow == nil then
                    aggRows[key] = row
                else
                    if math.abs(aggRow.timeStamp - row.timeStamp) < STACK_SPLIT_SECS then
                        aggRow.param2 = aggRow.param2 + row.param2 * ((row.subcategoryId == aggRow.subcategoryId) and 1 or -1) -- Adjust deposit amount by this withdrawl
                        aggRow.timeStamp = math.max(row.timeStamp, aggRow.timeStamp)
                        row.param2 = 0
                    else
                        -- Aggregate the next block
                        aggRows[key] = row
                    end
                end
            end
        end
        
        for i,row in ipairs(histList) do
            -- param1 -> Account
            -- param2 -> Count/Gold
            -- param3 -> Link/nil
            
            -- Normalize everything into positive counts
            if row.param2 < 0 then
                row.subcategoryId = ((row.subcategoryId == GUILD_HISTORY_BANK_DEPOSITS) and GUILD_HISTORY_BANK_WITHDRAWALS or GUILD_HISTORY_BANK_DEPOSITS)
                row.param2 = -row.param2
            end
            
            local isGold = (row.eventType == GUILD_EVENT_BANKGOLD_ADDED)
            local isDeposit = (row.subcategoryId == GUILD_HISTORY_BANK_DEPOSITS)
                
            -- Get account reference
            local acc = DT.Data.Accounts[row.param1]
            if acc == nil then
                -- Open a new account for our new donor!
                acc = DT.Clone(DT.ACCOUNT_TBL)
                acc.Account = row.param1
                DT.Data.Accounts[row.param1] = acc
            end        
            
            if not isGold then
                -- Prioritize updating older records if they are still within the stack split time frame
                if isDeposit then
                    DT.ArrayRemove(acc.ItemsOwed, function(items, i)
                        local item = items[i]
                        if item.IsGB == false then return false end
                        if DT.GetItemLinkKey(row.param3) == item.Key and math.abs(row.timeStamp - item.ReceivedTime) < STACK_SPLIT_SECS then
                            if row.param2 > item.Count then
                                -- Put back enough to cancel out what was owed
                                row.param2 = row.param2 - item.Count
                                return true
                            else
                                -- Put back some, still oweing
                                item.Count = item.Count - row.param2
                                item.ReceivedTime = row.timeStamp
                                row.param2 = 0
                                return (item.Count == 0)
                            end
                        end
                        return false
                    end)
                else
                    DT.ArrayRemove(acc.Items, function(items, i)
                        local item = items[i]
                        if item.IsGB == false then return false end
                        if DT.GetItemLinkKey(row.param3) == item.Key and math.abs(row.timeStamp - item.ReceivedTime) < STACK_SPLIT_SECS then
                            if row.param2 >= item.Count then
                                -- Took out more than what was put in
                                row.param2 = row.param2 - item.Count
                                return true
                            else
                                -- Took out less than what was put in
                                item.Count = item.Count - row.param2
                                item.ReceivedTime = row.timeStamp
                                row.param2 = 0
                                return false
                            end
                        end
                        return false
                    end)
                end
                
                -- Add the record
                if row.param2 > 0 then
                    local item = DT.Clone(DT.ITEM_TBL)
                    item.Account = row.param1
                    item.Link = row.param3
                    item.Key = DT.GetItemLinkKey(row.param3)
                    item.Name = DT.GetItemLinkName(row.param3)
                    item.Count = row.param2
                    item.Category = DT.GetItemLinkCategory(row.param3)
                    item.Multiplier = DT.GetItemMultiplier(item)
                    item.ReceivedTime = row.timeStamp
                    item.IsGB = true
                    DT.UpdateItemPrice(item)
                    if isDeposit then
                        table.insert(acc.Items, item)
                        itemCount = itemCount + item.Count
                    else
                        -- store item withdrawls
                        table.insert(acc.ItemsOwed, item)
                    end
                end
            else
                if row.param2 > 0 and isDeposit then
                    -- Add gold
                    local goldObj = DT.Clone(DT.GOLD_TBL)
                    goldObj.Amount = row.param2
                    goldObj.Account = row.param1
                    goldObj.Multiplier = DT.Data.GoldValMul
                    goldObj.ReceivedTime = row.timeStamp
                    goldObj.IsGB = true
                    table.insert(acc.GoldObjs, goldObj)
                    
                    goldAmt = goldAmt + goldObj.Amount
                end
            end 
        end
        
        -- Done proccessing up to lastEventTS
        cb(lastEventTS, itemCount, goldAmt)
    end
    DT.GetGuildHist(guildIndex, cutoffTS, GUILD_HISTORY_BANK, OnGuildHistResult)
end

function DT.GetGuildHist(guildIndex, cutoffTS, selectedCategory, cb)
    local guildId = GetGuildId(guildIndex)
    local histList = {}
    local histRefreshCount = 0
    local histNum = 1
    local prevNumEvents = 0
    local lastEventTS = nil
    local isProcessing = false
    --
    local function ReadHistDone()
        DT.Debug("GetGuildHist: Done")
        EVENT_MANAGER:UnregisterForEvent(DT.NAME, EVENT_GUILD_HISTORY_RESPONSE_RECEIVED)
        cb(histList)
    end
    
    local function ReadHistError(msg)
        EVENT_MANAGER:UnregisterForEvent(DT.NAME, EVENT_GUILD_HISTORY_RESPONSE_RECEIVED)
        cb(nil, msg)
    end
    
    local function ReadHist(isPreScan)
        isProcessing = true
        local numEvents = GetNumGuildEvents(guildId, selectedCategory)
        local isOrderDesc = nil
        DT.Debug(string.format("GetGuildHist: Got %d new records%s. Current index %d/%d", numEvents-prevNumEvents, isPreScan and " (Prescan)" or "", histNum, numEvents))
        
        if not isPreScan and numEvents == prevNumEvents then
            -- Update didn't give any new records
            return ReadHistDone()
        end
        while histNum <= numEvents do
            local eventType, secsSinceEvent, param1, param2, param3, param4, param5, param6 = GetGuildEventInfo(guildId, selectedCategory, histNum)
            local row = {
                eventType = eventType,
                param1 = param1,
                param2 = param2,
                param3 = param3,
                param4 = param4,
                param5 = param5,  
                param6 = param6,                                                  
                secsSinceEvent = secsSinceEvent,
                subcategoryId = ComputeGuildHistoryEventSubcategory(eventType, selectedCategory),
                timeStamp = GetTimeStamp() - secsSinceEvent
            }
            
            isOrderDesc = (lastEventTS == nil or (lastEventTS - row.timeStamp >= 0))
            
            -- Do row processing here
            if not isPreScan then  DT.Debug(string.format("[%s] %s %s %s %s", os.date("%c", row.timeStamp), row.param1, row.param2, row.param3, row.subcategoryId)) end
            if row.timeStamp > cutoffTS then
                table.insert(histList, row)
            elseif not isPreScan then
                ReadHistDone()
                return
            end

            histNum = histNum + 1
            lastEventTS = row.timeStamp
        end
        prevNumEvents = numEvents
        isProcessing = false
        
        DT.Debug(string.format("GetGuildHist: Finished records. Current order %s. Current index %d/%d", isOrderDesc and "Desc" or "Asc", histNum, numEvents))
        -- Ran out of events
        if not isPreScan then
            if isOrderDesc then
                if RequestGuildHistoryCategoryOlder(guildId, selectedCategory) == false then return ReadHistError("Failed to request older history") end
            else
                ReadHistDone()
                --if RequestGuildHistoryCategoryNewest(guildId, selectedCategory) == false then return ReadHistError("Failed to request newest history") end
            end
        end
    end
    
    local function OnGBHistRefreshed(eventCode, guildHistCat)
        if guildHistCat == selectedCategory and not isProcessing then
            histRefreshCount = histRefreshCount + 1
            DT.Debug(string.format("GetGuildHist: Received refresh #%d (event %d)", histRefreshCount, eventCode))
            ReadHist(false)
        end
    end
    
    ReadHist(true) -- Scan all the events already pulled
    EVENT_MANAGER:RegisterForEvent(DT.NAME, EVENT_GUILD_HISTORY_RESPONSE_RECEIVED , OnGBHistRefreshed)
    if RequestGuildHistoryCategoryNewest(guildId, selectedCategory) == false then return ReadHistError("No more new events") end
end


---- Mail event functions
function DT.RetriveMailReport()
    local mailId = MAIL_INBOX:GetOpenMailId()
    local dataMail = DT.UnpackMailObj(ReadMail(mailId))
    
    DT.RecordMailObj(dataMail)
    
    -- Add extra OBO record for forwarding
    local mail = DT.CreateMailObj(mailId)
    local oboRec = DT.CreateOBOObj(dataMail)
    oboRec.Sender = mail.Sender
    oboRec.Beneficiary = dataMail.Sender
    oboRec.IsForward = true
    table.insert(DT.Data.OBORecords, oboRec)
    
    if DT.DEBUGMODE ~= true then
        DeleteMail(mailId, true)
    end
end

function DT.InsertMailReport()
    if string.sub(DT.Data.ForwarderTarget, 1, 1) ~= "@" then
        DT.Error("Please set a forwarder target!")
        return
    end
 
    local mailId = MAIL_INBOX:GetOpenMailId()
    local mailData = {}
    ZO_MailInboxShared_PopulateMailData(mailData, mailId)
    local mail = DT.CreateMailObj(mailId)
    
    -- Fill the UI
    SendMail(DT.Data.ForwarderTarget, "data: " .. mailData.senderDisplayName, DT.PackMailObj(mail))
    DT.SystemPrintf("[DonationTracker] Forwarded mail to %s", DT.Data.ForwarderTarget)
    DT.PreTakeAttachmentMail = mail
    ZO_MailInboxShared_TakeAll(mailId)
    DeleteMail(mailId, true)
end

function DT.OnMailSelect(eventCode, mailId)
    if mailId == nil then mailId = MAIL_INBOX:GetOpenMailId() end
    -- Mailbox is closed
    if mailId == nil then
        DT.IsCurMailWithAttachments = false
        DT.IsCurMailForwarded = false
        DT.IsCurMailFromUser = false
        return
    end
    -- Update state based on current mail
    local mailData = {}
    ZO_MailInboxShared_PopulateMailData(mailData, mailId)
    
    DT.IsCurMailWithAttachments = (mailData.numAttachments > 0 or mailData.attachedMoney > 0)
    DT.IsCurMailForwarded = (string.match(string.lower(mailData.subject), "^data:") ~= nil)
    DT.IsCurMailFromUser = (string.sub(mailData.senderDisplayName, 1, 1) == "@") and not (mailData.fromCS or mailData.fromSystem)
    -- Force refresh keybind strip
    DT.UI.KBStripNameUpdate()
end

function DT.OnPreMailTakeAttachment(mailId)
    DT.PreTakeAttachmentMail = DT.CreateMailObj(mailId)
end

function DT.OnPostMailTakeAttachment(eventId, mailId)
    if DT.PreTakeAttachmentMail == nil then return end
    
    if not DT.Data.IsMailAutoTrack and not DT.IsTrackPressed then
        return
    end
    
    if DT.Data.IsMailAutoTrack and DT.IsTrackPressed then
        DT.SystemPrintf("[DonationTracker] Excluded mail attachments from %s", DT.PreTakeAttachmentMail.Sender)
        return
    end
    
    DT.RecordMailObj(DT.PreTakeAttachmentMail)
    
    -- Unset cached mail data just in case the event double fires
    DT.PreTakeAttachmentMail = nil
end

---- Mail processing functions
function DT.GetNewMailId()
    DT.Data.CurMailNum = DT.Data.CurMailNum + 1
    return DT.Data.CurMailNum
end

function DT.UnpackMailObj(data)
   local mailCompact = json.decode(data)
    
    -- Deserialize compacted data
    local mail = DT.Clone(DT.MAIL_TBL)
    mail.Sender = mailCompact[1]
    mail.Subject = mailCompact[2]
    mail.ReceivedTime = mailCompact[3]
    mail.MailCash = mailCompact[4]
    mail.IsCOD = mailCompact[5]
    mail.IsSenderUser = mailCompact[6]
    
    for i,attCompact in pairs(mailCompact[7]) do
        local att = DT.Clone(DT.ITEM_TBL)
        att.Account = mail.Sender
        att.Link = attCompact[1]
        att.Key = DT.GetItemLinkKey(attCompact[1])
        att.Name = DT.GetItemLinkName(attCompact[1])
        att.Count = attCompact[2]
        att.Category = DT.GetItemLinkCategory(attCompact[1])
        att.Multiplier = DT.GetItemMultiplier(att)
        att.ReceivedTime = mail.ReceivedTime
        att.IsGB = att[3]
        table.insert(mail.Attachments, att)
    end
    
    return mail
end

function DT.PackMailObj(mail)
    local mailCompact = {mail.Sender, mail.Subject, mail.ReceivedTime, mail.MailCash, mail.IsCOD, mail.IsSenderUser, {}}
    
    for i, att in pairs(mail.Attachments) do
        local attCompact = {att.Link, att.Count, att.IsGB}
        table.insert(mailCompact[#mailCompact], attCompact)
    end
    
    return json.encode(mailCompact)
end

function DT.CreateMailObj(mailId)
    local mailData = {}
    ZO_MailInboxShared_PopulateMailData(mailData, mailId)  
    
    local mail = DT.Clone(DT.MAIL_TBL)
    mail.Sender = mailData.senderDisplayName
    mail.Subject = mailData.subject
    mail.ReceivedTime = GetTimeStamp() - mailData.secsSinceReceived
    mail.MailCash = mailData.attachedMoney
    mail.IsCOD = (mailData.codAmount > 0)
    mail.IsSenderUser = (string.sub(mailData.senderDisplayName, 1, 1) == "@") and not (mailData.fromCS or mailData.fromSystem)
    
    local itemsCache = {}
    if mailData.numAttachments > 0 then
      GetMailAttachmentInfo(mailId)
      for i=1, mailData.numAttachments do
        local itemLink = GetAttachedItemLink(mailId, i, LINK_STYLE_BRACKETS)
        local icon, count, cn, sp, meets = GetAttachedItemInfo(mailId, i)
        local cachedItem = itemsCache[DT.GetItemLinkKey(itemLink)]
        if cachedItem == nil then
            local item = DT.Clone(DT.ITEM_TBL)
            item.Account = mailData.senderDisplayName
            item.Link = itemLink
            item.Key = DT.GetItemLinkKey(itemLink)
            item.Name = DT.GetItemLinkName(itemLink)
            item.Count = count
            item.Category = DT.GetItemLinkCategory(itemLink)
            item.Multiplier = DT.GetItemMultiplier(item)
            item.ReceivedTime = mail.ReceivedTime
            item.IsGB = false
            table.insert(mail.Attachments, item)
            itemsCache[item.Key] = item
        else
            cachedItem.Count = cachedItem.Count + count
        end
      end
    end
    
    return mail
end

function DT.CreateOBOObj(mail)
    if mail.MailRecId == nil then return nil end
    local beneficiary = string.match(mail.Subject, "%w+:%s*(@[^%s]+)")
    local oboRec = DT.Clone(DT.OBO_TBL)
    oboRec.Sender = mail.Sender
    oboRec.Beneficiary = beneficiary
    oboRec.Cash = mail.MailCash
    oboRec.ReceivedTime = mail.ReceivedTime
    oboRec.MailId = mail.MailRecId
    
    -- Record a short summary of the attachments
    for i, att in pairs(mail.Attachments) do
        if oboRec ~= nil then
            oboRec.ItemsStr = oboRec.ItemsStr .. ", [" .. att.Name .. "]x" .. att.Count
            oboRec.ItemsLinkStr = oboRec.ItemsLinkStr .. "," .. att.Link .. "x" .. att.Count
        end
    end
    
    if oboRec.ItemsStr ~= "" then
        oboRec.ItemsStr = string.sub(oboRec.ItemsStr, 3)
        oboRec.ItemsLinkStr = string.sub(oboRec.ItemsLinkStr, 2)
    end
    
    return oboRec
end

function DT.RecordMailObj(mail)
    DT.DebugReplaceSender(mail)
    if mail.Sender == nil or not mail.IsSenderUser or mail.IsCOD then return end -- Ignore COD mail and mails from guild store

    mail.MailRecId = DT.GetNewMailId()
    
    local oboRec
    if DT.StartsWith(string.lower(mail.Subject), "obo:") or DT.StartsWith(string.lower(mail.Subject), "onbehalfof:") then
        oboRec = DT.CreateOBOObj(mail)
        table.insert(DT.Data.OBORecords, oboRec)
        mail.Sender = oboRec.Beneficiary
    end
    
    local acc = DT.Data.Accounts[mail.Sender]
    if acc == nil then
        -- Open a new account for our new donor!
        acc = DT.Clone(DT.ACCOUNT_TBL)
        acc.Account = mail.Sender
        DT.Data.Accounts[mail.Sender] = acc
    end
    
    -- Add gold
    if mail.MailCash > 0 then
        local goldObj = DT.Clone(DT.GOLD_TBL)
        goldObj.Amount = mail.MailCash
        goldObj.Account = acc.Account
        goldObj.Multiplier = DT.Data.GoldValMul
        goldObj.ReceivedTime = mail.ReceivedTime
        goldObj.IsGB = false
        goldObj.MailId = mail.MailRecId
        table.insert(acc.GoldObjs, goldObj)
    end
    
    local itemsValAdj = 0
    local vouchers = 0
    -- Go through each attachment
    for i, att in pairs(mail.Attachments) do
        -- Make sure we attribute items to the correct sender if sender has been replaced
        att.Account = mail.Sender
        
        -- Try to find the item's worth
        if not DT.UpdateItemPrice(att) then
            DT.Error("No price information for " .. att.Link)
        end
        
        -- Record mail record Id
        att.MailId = mail.MailRecId
        
        -- Add item into account
        table.insert(acc.Items, att)
        
        -- Keep track of the value of this mail
        itemsValAdj = itemsValAdj + (att.Price ~= nil and att.Price*att.Count*att.Multiplier or 0) 
        if att.Category == "JCWrits" or att.Category == "Writs" then
            vouchers = vouchers + ((DT.Data.VoucherCounter.IsIgnoreJewelryWrits and att.Category == "JCWrits") and 0 or DT.MasterWritVoucherCount(att.Link))
        end
    end

    DT.SystemPrintf("[DonationTracker][Mail] %s Items + %s Cash + %d Vouchers received from %s (Mail #%d)", DT.FormatMoney(mail.MailCash + itemsValAdj), DT.FormatMoney(mail.MailCash), vouchers, mail.Sender, mail.MailRecId)
    
end

---- Price Guesser
function DT.RecalcMultipliers()
    for accName, acc in pairs(DT.Data.Accounts) do
        for i, item in pairs(acc.Items) do
            item.Multiplier = DT.GetItemMultiplier(item)
        end
        for i, goldObj in pairs(acc.GoldObjs) do
            goldObj.Multiplier = DT.Data.GoldValMul
        end
    end
end

-- Shouldn't happen normally. Should only run if category determination algorithm changes.
function DT.RecalcCategories()
    for accName, acc in pairs(DT.Data.Accounts) do
        for i, item in pairs(acc.Items) do
            item.Category = DT.GetItemLinkCategory(item.Link)
        end
    end
end

function DT.RecalcPrices(onlyUnknown)
    if onlyUnknown == nil then onlyUnknown = true end

    for accName, acc in pairs(DT.Data.Accounts) do
        for i, item in pairs(acc.Items) do
            if (onlyUnknown and item.Price == nil) or (not onlyUnknown) then
                DT.UpdateItemPrice(item)
            end
        end
    end
end

function DT.RecalcPriceSource(source, func)
    for accName, acc in pairs(DT.Data.Accounts) do
        for i, item in pairs(acc.Items) do
            if item.PriceSource == source then
                item.Price = func(item)
            end
        end
    end
end

function DT.RecalcMMTTC(item)
    for accName, acc in pairs(DT.Data.Accounts) do
        for i, item in pairs(acc.Items) do
            local price
            if item.PriceSource == "MM" then
                price = DT.MMPrice(item.Link)
                item.Price = (price ~= nil and price or item.Price)
            elseif item.PriceSource == "TTCAvg" then
                price = DT.TTCAvgPrice(item.Link)
                item.Price = (price ~= nil and price or item.Price)
            elseif item.PriceSource == "TTCSuggested" then
                price = DT.TTCSuggestedPrice(item.Link)
                item.Price = (price ~= nil and price or item.Price)
            end
        end
    end
end

function DT.PriceWritFormula(item)
    -- Estimate Master Writ price with WritWorthy
    if item.Category == "JCWrits" or item.Category == "Writs" then
        local writCost = (DT.Data.WritFormula.IsIgnoreMatsCost and 0 or DT.MasterWritCost(item.Link))
        local basePrice = (item.Category == "JCWrits" and DT.Data.WritFormula.JCVoucherBaseValue or DT.Data.WritFormula.VoucherBaseValue)
        if writCost ~= nil then
            return math.max(basePrice*DT.MasterWritVoucherCount(item.Link) - writCost, 0)
        end
    end
end

function DT.PriceGearForDecon(item)
    local INTRICATE_CATS = {"ClothierIntricates", "WWIntricates", "BSIntricates"}
    local QUALITY_PRICE = {TRASH=0, NORMAL=DT.Data.GearForDecon.NormalValue, FINE=DT.Data.GearForDecon.FineValue, SUPERIOR=DT.Data.GearForDecon.SuperiorValue, EPIC=DT.Data.GearForDecon.EpicValue, LEGENDARY=DT.Data.GearForDecon.LegendaryValue}

    if DT.Data.GearForDecon.IsIgnoreJewelry and item.Category == "JCIntricates" then return nil end
    
    if item.Category == "Gear" then
        local quality = GetItemLinkQuality(item.Link)
        local price = QUALITY_PRICE[DT.QUALITY_NAME[quality]]
        return price
    elseif item.Category == "JCIntricates" then
        return DT.Data.GearForDecon.JCIntricateValue
    elseif DT.HasValue(INTRICATE_CATS, item.Category) then
        return DT.Data.GearForDecon.IntricateValue
    end
end

function DT.PriceCustom(item)
    if DT.Data.CustomPrice[item.Key] ~= nil then
        return DT.Data.CustomPrice[item.Key]
    end
end

function DT.UpdateItemPrice(item)
    local PRICING_FUNC = {
        MM = function(item) return DT.MMPrice(item.Link) end,
        TTCSuggested = function(item) return DT.TTCSuggestedPrice(item.Link) end,
        TTCAvg = function(item) return DT.TTCAvgPrice(item.Link) end,
        WritFormula = DT.PriceWritFormula,
        GearForDecon = DT.PriceGearForDecon,
        Custom = DT.PriceCustom
    }
    for i, method in pairs(DT.Data.PricingOrder) do
        if PRICING_FUNC[method] ~= nil then
            local price = PRICING_FUNC[method](item)
            if price ~= nil then
                item.Price = price
                item.PriceSource = method
                return true
            end
        end
    end
    return false
end

function DT.GetItemLinkCategory(link)
    EquipMatsTypes = {ITEMTYPE_WOODWORKING_RAW_MATERIAL, ITEMTYPE_WOODWORKING_MATERIAL, ITEMTYPE_WOODWORKING_BOOSTER, ITEMTYPE_CLOTHIER_RAW_MATERIAL, ITEMTYPE_CLOTHIER_MATERIAL, ITEMTYPE_CLOTHIER_BOOSTER, ITEMTYPE_BLACKSMITHING_RAW_MATERIAL, ITEMTYPE_BLACKSMITHING_MATERIAL, ITEMTYPE_BLACKSMITHING_BOOSTER}
    JCMatsTypes = {ITEMTYPE_JEWELRYCRAFTING_BOOSTER, ITEMTYPE_JEWELRYCRAFTING_MATERIAL, ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER, ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL, ITEMTYPE_JEWELRY_RAW_TRAIT, ITEMTYPE_JEWELRY_TRAIT}
    ConsumMatsTypes = {ITEMTYPE_SPICE, ITEMTYPE_FLAVORING, ITEMTYPE_INGREDIENT, ITEMTYPE_ENCHANTING_RUNE_ASPECT, ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY, ITEMTYPE_ENCHANTMENT_BOOSTER}
    AlchemyMatsTypes = {ITEMTYPE_REAGENT, ITEMTYPE_POISON_BASE, ITEMTYPE_POTION_BASE}
    FurnishMatsTypes = {ITEMTYPE_FURNISHING_MATERIAL}
    WritsTypes = {ITEMTYPE_MASTER_WRIT}
    GearTypes = {ITEMTYPE_ARMOR, ITEMTYPE_WEAPON} -- Must go after intricates
    
    local itemType, specType = GetItemLinkItemType(link)
    
    if DT.HasValue(EquipMatsTypes, itemType) then
        DT.Debug(link.." -> EquipMats")
        return "EquipMats"
    end
    if DT.HasValue(JCMatsTypes, itemType) then
        DT.Debug(link.." -> JCMats")
        return "JCMats"
    end
    if DT.HasValue(ConsumMatsTypes, itemType) then
        DT.Debug(link.." -> ConsumMats")
        return "ConsumMats"
    end
    if DT.HasValue(AlchemyMatsTypes, itemType) then
        DT.Debug(link.." -> AlchmeyMats")
        return "AlchemyMats"
    end
    if DT.HasValue(FurnishMatsTypes, itemType) then
        DT.Debug(link.." -> FurnishMats")
        return "FurnishMats"
    end
    if DT.HasValue(WritsTypes,itemType) then
        if string.find(DT.GetItemLinkName(link), "Sealed Jewelry", 1, true) ~= nil then
            DT.Debug(link.." -> JCWrits")
            return "JCWrits"
        else
            DT.Debug(link.." -> Writs")
            return "Writs"
        end
    end
    
    -- Detect intricates
    local trait, desc = GetItemLinkTraitInfo(link)
    if trait == 20 or trait == 9 or trait == 27 then
        if itemType == ITEMTYPE_WEAPON then
            BSWeapTypes = {WEAPONTYPE_AXE, WEAPONTYPE_DAGGER, WEAPONTYPE_HAMMER, WEAPONTYPE_SWORD, WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_TWO_HANDED_SWORD}
            local weapType = GetItemLinkWeaponType(link)
            if DT.HasValue(BSWeapTypes, weapType) then
                DT.Debug(link.." -> BSIntricates")
                return "BSIntricates"
            else
                DT.Debug(link.." -> WWIntricates")
                return "WWIntricates"
            end
        else
            local armorType = GetItemLinkArmorType(link)
            if armorType == ARMORTYPE_HEAVY then
                DT.Debug(link.." -> BSIntricates")
                return "BSIntricates"
            elseif armorType == ARMORTYPE_NONE then
                DT.Debug(link.." -> JCIntricates")
                return "JCIntricates"
            else
                DT.Debug(link.." -> ClothierIntricates")
                return "ClothierIntricates"
            end
        end
    end
    
    if DT.HasValue(GearTypes, itemType) then
        DT.Debug(link.." -> Gear")
        return "Gear"
    end
    DT.Debug(link.." -> Misc")
    return "Misc"
end

function DT.GetItemMultiplier(item)
    local mul = DT.Data[item.Category .. "Mul"]
    assert(mul ~= nil)
    return mul
end

function DT.GetItemLinkName(itemLink)
    local res = {string.gsub(GetItemLinkName(itemLink), "%^%w+$", "")}
    return res[1]
end

function DT.GetItemLinkKey(itemLink)
	if CanItemLinkBeVirtual(itemLink) then	-- anything that goes in the craft bag - must be a crafting material
		return tostring(GetItemLinkItemId(itemLink))
	else
		-- other oddball items that might have level info in them
		local itemType, subType = GetItemLinkItemType(itemLink)
		if	(itemType == ITEMTYPE_TOOL and subType == SPECIALIZED_ITEMTYPE_TOOL) or
			itemType == ITEMTYPE_RACIAL_STYLE_MOTIF or		-- 9-12-16 AM - added because motifs now appear to have level info in them
			itemType == ITEMTYPE_RECIPE then
			return tostring(GetItemLinkItemId(itemLink))
		end
	end
	return itemLink
end

function DT.CreateItemLinkFromKey(itemKey)
    if tonumber(itemKey) ~= nil then
        local newLink = ZO_LinkHandler_CreateLink("", nil, ITEM_LINK_TYPE, tonumber(itemKey), 1, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10000, 0)
        newLink =  ZO_LinkHandler_CreateLink(DT.GetItemLinkName(newLink), nil, ITEM_LINK_TYPE, tonumber(itemKey), 1, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10000, 0)
        return newLink
    else
        return itemKey
    end
end

function DT.GetAccountOBOCred(accName)
    local oboSent = 0
    local oboReceived = 0
    for i, rec in pairs(DT.Data.OBORecords) do
        if not rec.IsForward then
            if rec.Sender == accName then oboSent = oboSent + rec.Cash end
            if rec.Beneficiary == accName then oboReceived = oboReceived + rec.Cash end
        end
    end
    return oboSent, oboReceived
end

---- Functions for updating internal data from the UI
function DT.ItemRowEqual(a, b)
    return a.Key == b.Key and a.ReceivedTime == b.ReceivedTime
end

function DT.GoldObjRowEqual(a, b)
    return a.Amount == b.Amount and a.ReceivedTime == b.ReceivedTime
end

function DT.UpdateItemRow(row, opt)
    local isAgg = (row.AccountsStr ~= nil)
    local isGoldEntry = (row.Amount ~= nil)
    local accounts = (isAgg and DT.Data.Accounts or {[row.Account] = DT.Data.Accounts[row.Account]})

    if opt.Delete == true then
        for accName, acc in pairs(accounts) do
            if not isGoldEntry then
                DT.ArrayRemove(acc.Items, function(t, i)
                    local item = t[i]
                    return (isAgg and row.Key == item.Key) or (not isAgg and DT.ItemRowEqual(row, item))
                end)
            else
                DT.ArrayRemove(acc.GoldObjs, function(t, i)
                    local goldObj = t[i]
                    return isAgg or DT.GoldObjRowEqual(row, goldObj)
                end)
            end
        end
    end
    
    if opt.RefreshPrice == true or opt.CustomPrice ~= nil then
        for accName, acc in pairs(accounts) do
            for i, item in pairs(acc.Items) do
                if (isAgg and row.Key == item.Key) or (not isAgg and DT.ItemRowEqual(row, item)) then
                    if opt.CustomPrice ~= nil then
                        local price = (opt.CustomPrice ~= "?" and opt.CustomPrice or nil)
                        item.Price = price
                        item.PriceSource = (price ~= nil and "Custom" or nil)
                        DT.Data.CustomPrice[item.Key] = price
                    else
                        DT.UpdateItemPrice(item)
                    end
                end
            end
        end
    end
end

function DT.UpdateDonorRow(row, opt)
    if opt.CustomNote ~= nil then
        DT.Data.CustomNotes[row.Account] = opt.CustomNote
    end
    if opt.CustomCash ~= nil then
        DT.Data.Accounts[row.Account].CustomCash = opt.CustomCash
    end
end

function DT.Reset()
    DT.Data.Accounts = {}
    DT.Data.OBORecords = {}
    DT.Data.CurMailNum = 0
    
    DT.Data.RUTickets = {}
end

---- Output formatting

function DT.ExporterDumpDataToDir(data, dir)
    DT.Data = data
    -- Load xlsxwriter
    require("xlsxwriter.workbook")
    

    local DataWB  = Workbook:new(dir .. "\\" .. os.date("%Y-%m-%d", os.time()) .. "-DonationTrackerData.xlsx")
    -- Create some formats
    local headerFormat = DataWB:add_format({bold = true})
    local numFormat = DataWB:add_format({num_format = "#,##0.00"})
    -- Create worksheets
    local DonorsWS = DataWB:add_worksheet("Donors")
    local ItemsWS = DataWB:add_worksheet("Items")
    local GoldWS = DataWB:add_worksheet("Gold")
    local OBOWS = DataWB:add_worksheet("On Behalf Of")

    -- No changes here will be saved because it's being ran outside the game
    local DonorData = {}
    local ItemData = {}
    local GoldObjData = {}
    DT.FillDonorMasterList(DonorData)
    DT.FillItemMasterList(ItemData)
    DT.FillGoldObjMasterList(GoldObjData)
    
    local function WriteHeaders(ws, columns)
        for j, column in pairs(columns) do
            ws:write(0, j - 1, column, headerFormat)
        end 
    end
    
    -- Write donor rows
    WriteHeaders(DonorsWS, DT_DONOR_COLUMNS)
    for i, row in ipairs(DonorData) do
        row.OBOSent, row.OBOReceived = DT.GetAccountOBOCred(row.Account)
        for j, column in ipairs(DT_DONOR_COLUMNS) do
            local fmt = nil
            if type(row[column]) == "number" then fmt = numFormat end
            DonorsWS:write(i, j - 1, row[column], fmt)
        end
    end
    
    -- Write items rows
    WriteHeaders(ItemsWS, DT_ITEM_COLUMNS)
    for i, row in ipairs(ItemData) do
        for j, column in pairs(DT_ITEM_COLUMNS) do
            local fmt = nil
            if type(row[column]) == "number" then fmt = numFormat end
            ItemsWS:write(i, j - 1, row[column], fmt)
        end
    end
    
    -- Write gold donation
    WriteHeaders(GoldWS, DT_GOLDOBJ_COLUMNS)
    for i, row in ipairs(GoldObjData) do
        for j, column in ipairs(DT_GOLDOBJ_COLUMNS) do
            local fmt = nil
            if type(row[column]) == "number" then fmt = numFormat end
            GoldWS:write(i, j - 1, row[column], fmt)
        end
    end

    -- Write OBO rows
    WriteHeaders(OBOWS, DT_OBO_COLUMNS)
    for i, row in ipairs(DT.Data.OBORecords) do
        row.ReceivedDate = os.date("%c", row.ReceivedTime)
        row.Type = (row.IsForward and "Forwarded" or "OBO Donation")
        for j, column in ipairs(DT_OBO_COLUMNS) do
            local fmt = nil
            if type(row[column]) == "number" then fmt = numFormat end
            OBOWS:write(i, j - 1, row[column], fmt)
        end
    end
    
    DataWB:close()
end

function DT.FillDonorMasterList(masterList, itemFilterCB)
    local keys = DT.GetOrderedKeyList(DT.Data.Accounts)
    local cacheList = {}
    local grandTotal = 0
    for i, accName in pairs(keys) do
        local donor = DT.Data.Accounts[accName]
        local mailItemsVal = 0
        local GBItemsVal = 0
        local mailCash = 0
        local GBCash = 0
        local vouchers = 0
        local itemCategories = ""
        local itemCats = {}

        -- Total item donations with recorded modifiers and price (at time of donation)
        for i, item in pairs(donor.Items) do
            if itemFilterCB == nil or not itemFilterCB(item) then
                local itemCat = item.Category
                -- Keep track of categories
                if itemCat == "Gear" or string.match(itemCat, "Intricates") ~= nil then itemCat = "Intricates" end -- Group together all intricates and gear
                if itemCat ~= "FurnishMats" and string.match(itemCat, "Mats") ~= nil then itemCat = "Mats" end -- Group together non furnishing mats
                itemCats[itemCat] = (itemCats[itemCat] == nil and 0 or itemCats[itemCat]) + item.Count
                -- Keep track of vouchers
                if itemCat == "JCWrits" or itemCat == "Writs" then
                    vouchers = vouchers + ((DT.Data.VoucherCounter.IsIgnoreJewelryWrits and itemCat == "JCWrits") and 0 or DT.MasterWritVoucherCount(item.Link))
                end
                -- Keep track of total value
                local itemPrice = (item.Price ~= nil and item.Price*item.Count*item.Multiplier or 0)
                if item.IsGB then
                    GBItemsVal = GBItemsVal + itemPrice
                else
                    mailItemsVal = mailItemsVal + itemPrice
                end
            end
        end
        -- Build item categories string
        for cat, count in pairs(itemCats) do
            itemCategories = itemCategories .. ", " .. DT.CATEGORY_DESC[cat] .. " (" .. count .. ")"
        end
        if itemCategories ~= "" then itemCategories = string.sub(itemCategories, 3) end

        -- Total gold donations with recorded modifiers and price (at time of donation)
        for i, goldObj in pairs(donor.GoldObjs) do
            if itemFilterCB == nil or not itemFilterCB(goldObj) then
                if goldObj.IsGB == true then
                    GBCash = GBCash + goldObj.Amount
                else
                    mailCash = mailCash + goldObj.Amount
                end
            end
        end
        
        
        local total = mailCash + GBCash + mailItemsVal + GBItemsVal + donor.CustomCash
        local note = (DT.Data.CustomNotes[donor.Account] ~= nil and DT.Data.CustomNotes[donor.Account] or "")
        local row = {Account=donor.Account, MailCash=mailCash, GBCash=GBCash, CustomCash=donor.CustomCash, MailItemsValue=mailItemsVal, GBItemsValue=GBItemsVal, ItemCategories=itemCategories, Vouchers=vouchers, Total=total, CustomNote=note}
        table.insert(cacheList, row)
        
        grandTotal = grandTotal + total
    end
    
    for i, row in pairs(cacheList) do
        row.TotalPercent = (row.Total / grandTotal) * 100
        table.insert(masterList, row)
    end
end

function DT.FillItemMasterList(masterList, isAgg)
    if isAgg == nil then isAgg = false end
    
    local items = {}
    for accName, acc in pairs(DT.Data.Accounts) do
        for i, item in ipairs(acc.Items) do
            local receivedDate = os.date("%c", item.ReceivedTime)
            local donationSource = item.IsGB and "GB" or ("Mail #" .. item.MailId)
            if isAgg then
                if items[item.Key] == nil then
                    local row = {Key=item.Key, Link=item.Link, Name=item.Name, Count=item.Count, Category=item.Category, AccountsCount=1, AccountsStr=item.Account, PriceAverage=item.Price, FromMail=(item.IsGB and 0 or item.Count), FromGB=(item.IsGB and item.Count or 0)}
                    items[item.Key] = row
                else
                    local itemsRec = items[item.Key]
                    if string.find(itemsRec.AccountsStr, item.Account, 1, true) == nil then
                        -- New donor of this item
                        itemsRec.AccountsCount = itemsRec.AccountsCount + 1
                        itemsRec.AccountsStr = itemsRec.AccountsStr .. ", " .. item.Account
                    end
                    if item.Price ~= nil then
                        if itemsRec.PriceAverage == nil then itemsRec.PriceAverage = item.Price end
                        itemsRec.PriceAverage = (item.Count*item.Price + itemsRec.Count*itemsRec.PriceAverage) / (item.Count + itemsRec.Count) -- Must calculate before updating count!
                    end
                    itemsRec.Count = itemsRec.Count + item.Count
                    itemsRec.FromMail = itemsRec.FromMail + (item.IsGB and 0 or item.Count)
                    itemsRec.FromGB =  itemsRec.FromGB + (item.IsGB and item.Count or 0)
                end
            else
                local row = {Key=item.Key, Link=item.Link, Name=item.Name, Count=item.Count, Category=item.Category, Account=item.Account, PriceSource=item.PriceSource, Price=item.Price, Multiplier=item.Multiplier, ReceivedDate=receivedDate, ReceivedTime=item.ReceivedTime, DonationSource=donationSource}
                table.insert(masterList, row)
            end
        end
    end
    
    if isAgg then
        for itemLink, row in pairs(items) do
            -- Set non-applicable fields for compatibility
            row.Account = row.AccountsCount .. " Donors"
            row.PriceSource = ""
            row.Price = row.PriceAverage
            row.Multiplier = nil
            row.ReceivedDate = ""
            row.DonationSource = string.format("Mail (%d), GB (%d)", row.FromMail, row.FromGB)
            table.insert(masterList, row)
            
        end
    end
end

function DT.FillGoldObjMasterList(masterList, isAgg)
    if isAgg == nil then isAgg = false end
    local goldSum
    for accName, acc in pairs(DT.Data.Accounts) do
        for i, goldObj in ipairs(acc.GoldObjs) do
            local receivedDate = os.date("%c", goldObj.ReceivedTime)
            local donationSource = goldObj.IsGB and "GB" or ("Mail #"..goldObj.MailId)
            
            if isAgg then
                if goldSum == nil then
                    goldSum = {AccountsCount=1, AccountsStr=goldObj.Account, Amount=goldObj.Amount, FromGB=0, FromMail=0}
                end
                if string.find(goldSum.AccountsStr, goldObj.Account, 1, true) == nil then
                    goldSum.AccountsCount = goldSum.AccountsCount + 1
                    goldSum.AccountsStr = goldSum.AccountsStr .. ", " .. goldObj.Account
                end
                goldSum.Amount = goldSum.Amount + goldObj.Amount
                goldSum.FromGB = goldSum.FromGB + (goldObj.IsGB and goldObj.Amount or 0)
                goldSum.FromMail = goldSum.FromMail + (goldObj.IsGB and 0 or goldObj.Amount)
            else
                local row = {Account=goldObj.Account, Amount=goldObj.Amount, Multiplier=goldObj.Multiplier, ReceivedDate=receivedDate, ReceivedTime=goldObj.ReceivedTime, DonationSource=donationSource}
                table.insert(masterList, row)
            end
        end
    end
    if isAgg then
        if goldSum == nil then goldSum = {AccountsCount=0, AccountsStr="", Amount=0, FromGB=0, FromMail=0} end
        -- Set non-applicable fields for compatibility
        goldSum.Account = goldSum.AccountsCount .. " Donors"
        goldSum.Multiplier = nil
        goldSum.ReceivedDate = ""
        goldSum.DonationSource = string.format("Mail (%s), GB (%s)", DT.FormatMoney(goldSum.FromMail), DT.FormatMoney(goldSum.FromGB))
        table.insert(masterList, goldSum)
    end
end


function DT.InitializeCommands()
    
    SLASH_COMMANDS["/dtundo"] = function(optStr)
        local mailId = tonumber(string.match(optStr, "#(%d+)"))
        local total = 0
        local attCount = 0
        local goldAmt = 0
        for accName, acc in pairs(DT.Data.Accounts) do
            DT.ArrayRemove(acc.Items, function(t, i)
                if t[i].MailId == mailId then
                    total = total + (t[i].Price == nil and 0 or t[i].Price) * t[i].Count
                    attCount = attCount + 1
                    return true
                else
                    return false
                end
            end)
            DT.ArrayRemove(acc.GoldObjs, function(t, i)
                if t[i].MailId == mailId then
                    total = total + t[i].Amount
                    goldAmt = goldAmt + t[i].Amount
                    return true
                else
                    return false
                end
            end)
        end
        DT.SystemPrintf("Removed %d attachments and %s from mail #%d -> %s", attCount, DT.FormatMoney(goldAmt), mailId, DT.FormatMoney(total))
        DT.UI.ItemScrollList:RefreshData()
    end
    
    SLASH_COMMANDS["/dtcustom"] = function(optStr)
        local itemLink, price = string.match(optStr, "^(%S*)%s*(.-)$")
        local sp
        
        if itemLink == "" then
            if next(DT.Data.CustomPrice) ~= nil then
                DT.SystemPrintf("-------------------------------------------------------")
                for itemKey, price in pairs(DT.Data.CustomPrice) do
                    DT.SystemPrintf("%s -> %s", DT.CreateItemLinkFromKey(itemKey), DT.FormatMoney(price))
                end
            else
                DT.SystemPrintf("Custom price table empty")
            end
            return
        end
        
        if price == "?" or price == "auto" then
            sp = price
            price = nil
        else
            price = tonumber(price)
        end
        
        local itemKey = DT.GetItemLinkKey(itemLink)
        local itemLink = DT.CreateItemLinkFromKey(itemKey)
        
        if sp == "auto" and DT.Data.CustomPrice[itemKey] ~= nil then
            -- if we're trying to update it into auto remove the custom price
            DT.Data.CustomPrice[itemKey] = nil
        end
        
        local priceSource
        if sp ~= nil or type(price) == "number" then
            local updatedCount = 0
            for accName, acc in pairs(DT.Data.Accounts) do
                for i, item in pairs(acc.Items) do
                    if item.Link == itemLink then
                        if sp == "auto" then
                            DT.UpdateItemPrice(item)
                            price = item.Price
                        else
                            item.Price = price
                            if sp == "?" then
                                item.PriceSource = nil
                            else
                                item.PriceSource = "Custom"
                            end
                        end
                        priceSource = item.PriceSource
                        updatedCount = updatedCount + item.Count
                    end
                end
            end
            DT.SystemPrintf("Set price for %sx%d as %s (%s)", itemLink, updatedCount, DT.FormatMoney(price), priceSource == nil and "No Price" or priceSource)
            if updatedCount > 0 then DT.UI.ItemScrollList:RefreshData() end
            -- Store the price for the future
            if price == nil or priceSource == "Custom" then
                DT.Data.CustomPrice[itemKey] = price
            end
        end
    end

    SLASH_COMMANDS["/dtruignore"] = function(optStr)
        local accName = string.match(optStr, "(%-?[#@]%S+)")
        if accName == nil then
            if next(DT.Data.RUIgnore) ~= nil then
                DT.SystemPrintf("-----------------------------------------")
                for accName,ts in pairs(DT.Data.RUIgnore) do
                    DT.SystemPrintf("%s -> %s", accName, os.date("%x", ts))
                end
            else
                DT.SystemPrintf("Ignore list empty")
            end
        else
            if DT.StartsWith(accName, "-") then
                accName = string.sub(accName,2)
                DT.Data.RUIgnore[accName] = nil
                DT.SystemPrintf("Removed %s from ignore list", accName)
            else
                DT.Data.RUIgnore[accName] = GetTimeStamp()
                DT.SystemPrintf("Added %s to ignore list", accName)
            end
        end
    end

    SLASH_COMMANDS["/dtruinject"] = function(optStr)
        local function GetMailIdFilterFunc()
            local IgnoreMailIds = {}
            for ignoreStr, ts in pairs(DT.Data.RUIgnore) do
                if string.sub(ignoreStr, 1, 1) == "#" then
                    table.insert(IgnoreMailIds, tonumber(string.sub(ignoreStr, 2)))
                end
            end
            return function(item)
                return item.MailId ~= nil and DT.HasValue(IgnoreMailIds, item.MailId)
            end
        end
    
        local function DoRaffleInject(allowRemove)
            local Tickets = DT.Data.RUTickets
            local summary = {}
            local data = {}

            DT.FillDonorMasterList(data, GetMailIdFilterFunc())
            for i, row in pairs(data) do
                if Tickets[row.Account] == nil then Tickets[row.Account] = 0 end
                local tixGoal = math.floor(row.Total / RaffleUnlimited.db.entryPrice)
                local tixRequired = (DT.Data.RUIgnore[row.Account] == nil and (tixGoal - Tickets[row.Account]) or 0)
                if tixRequired > 0 then
                    RaffleUnlimited.Cmd("set tickets " .. tixRequired .. " " .. row.Account)
                    Tickets[row.Account] = Tickets[row.Account] + tixRequired
                else
                    -- Need to take away some raffles, requires a reset
                    if tixGoal >= 0 and allowRemove then
                        RaffleUnlimited.Cmd("reset tickets")
                        DT.Data.RUTickets = {}
                        return DoRaffleInject(false)
                    end
                end
                -- Record current status for output
                local isIgnored = (DT.Data.RUIgnore[row.Account] ~= nil)
                if (not isIgnored and tixGoal > 0) or Tickets[row.Account] > 0 then
                    table.insert(summary, string.format("%s -> %d/%d tickets injected (%s)", row.Account .. (isIgnored and " (Ignored)" or ""), Tickets[row.Account], isIgnored and 0 or tixGoal, DT.FormatMoney(row.Total)))
                end
            end
            if next(summary) ~= nil then 
                DT.SystemPrintf("-----------------------------------------")
                for i, msg in ipairs(summary) do
                    DT.SystemPrintf(msg)
                end
            else
                DT.SystemPrintf("No donors with enough donation for raffle tickets")
            end
        end
        
        if optStr ~= nil then optStr = string.lower(string.match(optStr, "%S+")) end
        if RaffleUnlimited == nil then
            DT.Error("Raffle Unlimited not installed")
            return
        end
        
        DoRaffleInject(optStr == "allowreset")
    end
    
    SLASH_COMMANDS["/dtreset"] = function(optStr)
        DT.UI.ConfirmDialog("RESET", "Are you sure you want to reset all DonationTracker records?", DT.Reset)
    end
    
    SLASH_COMMANDS["/dt"] = DT.UI.ToggleWindow
    
    -- commands for fixing stuff
    
    SLASH_COMMANDS["/dtgbupdate"] = function(optStr)
        DT.SystemPrintf("[DonationTracker] Sending guild history update request, this might take anywhere from a few seconds to a few minutes.")
        DT.UpdateGuildHist()
    end
    
    SLASH_COMMANDS["/dtfixdata"] = function() DT.TryFixData(true) end
end
    
---- Main Body

function DT.Initialize()

    DT.Data = ZO_SavedVars:NewAccountWide(DT.SAVED_VARIABLES, 1, nil, DT.DATA_DEFAULTS)
    
    DT.TryFixData()

    DT.UI.Initialize()
    
    DT.InitializeCommands()
   
    ZO_PreHook("ZO_MailInboxShared_TakeAll", DT.OnPreMailTakeAttachment)
    EVENT_MANAGER:RegisterForEvent(DT.NAME, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS , DT.OnPostMailTakeAttachment)
    EVENT_MANAGER:RegisterForEvent(DT.NAME, EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS , DT.OnPostMailTakeAttachment)

    EVENT_MANAGER:RegisterForEvent(DT.NAME, EVENT_MAIL_OPEN_MAILBOX, DT.OnMailSelect)
    EVENT_MANAGER:RegisterForEvent(DT.NAME, EVENT_MAIL_READABLE, DT.OnMailSelect)
    EVENT_MANAGER:RegisterForEvent(DT.NAME, EVENT_MAIL_INBOX_UPDATE , DT.OnMailSelect)
    
    --EVENT_MANAGER:RegisterForEvent(DT.NAME, EVENT_GUILD_BANK_ITEM_ADDED, DT.UpdateGuildHist)
    --EVENT_MANAGER:RegisterForEvent(DT.NAME, EVENT_GUILD_BANKED_MONEY_UPDATE, DT.UpdateGuildHist)
    local function TimerTick()
        DT.UpdateGuildHist()
    end
    --zo_callLater(TimerTick, 60*60*1000) -- milliseconds
    
    -- Try refresh GB
    DT.UpdateGuildHist()
end

function DT.OnAddonLoaded(eventCode, addOnName)
    if ( addOnName ~= DT.NAME ) then return end
    EVENT_MANAGER:UnregisterForEvent(DT.NAME, EVENT_ADDON_LOADED)
    DT.Initialize()
end

EVENT_MANAGER:RegisterForEvent(DT.NAME, EVENT_ADD_ON_LOADED, DT.OnAddonLoaded)