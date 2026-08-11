GuildMarketScannerDev = GuildMarketScannerDev or {}
local GMS = GuildMarketScannerDev

GMS.name = "GuildMarketScannerDev"
GMS.version = "0.1.1"
GMS.schemaVersion = 6
GMS.maxGuildSnapshotsPerItem = 20
GMS.maxPricesPerItemDuringScan = 24

GMS.saved=nil
GMS.isTraderOpen=false
GMS.isScanning=false
GMS.waitingForSearch=false
GMS.scanPage=0
GMS.scanLoaded=0
GMS.scanGuildId=0
GMS.scanGuildName=""
GMS.scanBuffer={}
GMS.keybindAdded=false

-- Snapshot array = {count, median, q1, q3, updated}
local S_COUNT,S_MED,S_Q1,S_Q3,S_UPD = 1,2,3,4,5

local defaults={
    schemaVersion=6,
    items={},
    totalItems=0,
    totalGuildSnapshots=0,
    lastScan=nil,
}

local function Chat(msg)
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage("|c66CCFF[GMS]|r "..tostring(msg))
    else d("[GMS] "..tostring(msg)) end
end

local function Count(t)
    local n=0
    if t then for _ in pairs(t) do n=n+1 end end
    return n
end

local function CopyArray(src)
    local out={}
    for i=1,#src do out[i]=src[i] end
    return out
end

local function Median(a)
    local n=#a
    if n==0 then return nil end
    table.sort(a)
    if n%2==1 then return a[(n+1)/2] end
    return (a[n/2]+a[n/2+1])/2
end

local function Percentile(a,p)
    local n=#a
    if n==0 then return nil end
    table.sort(a)
    if n==1 then return a[1] end
    local pos=1+(n-1)*p
    local lo=math.floor(pos)
    local hi=math.ceil(pos)
    if lo==hi then return a[lo] end
    local f=pos-lo
    return a[lo]+(a[hi]-a[lo])*f
end

function GMS:GetTrader()
    local id,name=GetCurrentTradingHouseGuildDetails()
    return id or 0,name or ""
end

function GMS:GetOrCreateItem(link,name)
    local item=self.saved.items[link]
    if not item then
        item={n=name or "",g={}}
        self.saved.items[link]=item
        self.saved.totalItems=(self.saved.totalItems or 0)+1
    end
    item.g=item.g or {}
    return item
end

function GMS:BuildGuildSnapshot(prices,seenAt)
    if not prices or #prices==0 then return nil end
    local p=CopyArray(prices)
    table.sort(p)
    return {
        #p,
        math.floor((Median(p) or 0)+0.5),
        math.floor((Percentile(p,0.25) or p[1])+0.5),
        math.floor((Percentile(p,0.75) or p[#p])+0.5),
        seenAt or GetTimeStamp(),
    }
end

function GMS:PruneOldGuildSnapshots(item)
    local c=Count(item.g)
    while c>self.maxGuildSnapshotsPerItem do
        local oldestKey,oldestTime=nil,nil
        for guildKey,s in pairs(item.g) do
            local t=s[S_UPD] or 0
            if oldestTime==nil or t<oldestTime then oldestKey,oldestTime=guildKey,t end
        end
        if not oldestKey then break end
        item.g[oldestKey]=nil
        c=c-1
    end
end

function GMS:Recount()
    local items,snaps=0,0
    for _,item in pairs(self.saved.items or {}) do
        items=items+1
        item.g=item.g or {}
        snaps=snaps+Count(item.g)
    end
    self.saved.totalItems=items
    self.saved.totalGuildSnapshots=snaps
end

function GMS:AnalyzeItem(item)
    if not item or not item.g then return nil end

    local medians={}
    local totalListings=0
    local newest=0

    for _,s in pairs(item.g) do
        local m=s[S_MED]
        if m and m>0 then
            medians[#medians+1]=m
            totalListings=totalListings+(s[S_COUNT] or 1)
            newest=math.max(newest,s[S_UPD] or 0)
        end
    end

    table.sort(medians)
    if #medians==0 then return nil end

    local rawMedian=Median(medians)
    local q1=Percentile(medians,0.25)
    local q3=Percentile(medians,0.75)
    local iqr=math.max((q3 or rawMedian)-(q1 or rawMedian),1)
    local lowFence=math.max(0,(q1 or rawMedian)-1.5*iqr)
    local highFence=(q3 or rawMedian)+1.5*iqr

    local cluster={}
    local lowOut,highOut=0,0
    for _,price in ipairs(medians) do
        if price<lowFence then lowOut=lowOut+1
        elseif price>highFence then highOut=highOut+1
        else cluster[#cluster+1]=price end
    end
    if #cluster==0 then cluster=medians end
    table.sort(cluster)

    local confidence=0
    if #cluster>=8 then confidence=3
    elseif #cluster>=4 then confidence=2
    elseif #cluster>=2 then confidence=1 end

    return {
        p=math.floor((Median(cluster) or rawMedian)+0.5),
        l=math.floor((Percentile(cluster,0.25) or cluster[1])+0.5),
        h=math.floor((Percentile(cluster,0.75) or cluster[#cluster])+0.5),
        g=#medians,c=#cluster,o=totalListings,lo=lowOut,hi=highOut,
        cf=confidence,u=newest
    }
end

function GMS:ConfidenceLabel(v)
    if v==3 then return "HIGH" end
    if v==2 then return "MEDIUM" end
    if v==1 then return "LOW" end
    return "INSUFFICIENT"
end

function GMS:PrintPriceByName(query)
    query=string.lower(query or "")
    if query=="" then Chat("Usage: /gmsprice item name"); return end
    local best=nil
    for _,item in pairs(self.saved.items or {}) do
        local n=string.lower(item.n or "")
        if n==query then best=item break
        elseif not best and string.find(n,query,1,true) then best=item end
    end
    if not best then Chat("No stored market data found for: "..query); return end
    local p=self:AnalyzeItem(best)
    if not p then Chat("No usable market profile for "..tostring(best.n)); return end
    Chat(string.format(
        "%s | Suggested %dg | Typical %d-%dg | %d/%d guilds in cluster | %d listings represented | %d low + %d high guild outliers | Confidence %s",
        best.n or "Item",p.p,p.l,p.h,p.c,p.g,p.o,p.lo,p.hi,self:ConfidenceLabel(p.cf)
    ))
end

function GMS:MigrateV5ToV6()
    Chat("OPTIMIZING compact market database for v0.1.1...")
    local oldItems=self.saved.items or {}
    local newItems={}

    for itemLink,oldItem in pairs(oldItems) do
        local newItem={n=oldItem.itemName or oldItem.n or "",g={}}
        local oldGuilds=oldItem.guilds or oldItem.g or {}

        for guildKey,s in pairs(oldGuilds) do
            if type(s)=="table" then
                if s.med~=nil then
                    newItem.g[guildKey]={
                        s.n or 1,
                        s.med or 0,
                        s.q1 or s.med or 0,
                        s.q3 or s.med or 0,
                        s.updated or 0,
                    }
                else
                    newItem.g[guildKey]=s
                end
            end
        end

        if Count(newItem.g)>0 then newItems[itemLink]=newItem end
        oldItems[itemLink]=nil
    end

    self.saved.items=newItems
    self.saved.priceData=nil
    self.saved.priceDataCount=nil
    self.saved.priceDataUpdated=nil
    self.saved.schemaVersion=6
    self:Recount()

    Chat(string.format(
        "OPTIMIZATION COMPLETE: %d items / %d guild snapshots. Duplicate cached price profiles removed.",
        self.saved.totalItems,self.saved.totalGuildSnapshots
    ))
end

function GMS:BufferListing(link,name,unitPrice)
    if not link or link=="" or not unitPrice or unitPrice<=0 then return end
    local b=self.scanBuffer[link]
    if not b then b={n=name or "",p={}}; self.scanBuffer[link]=b end
    if #b.p<self.maxPricesPerItemDuringScan then b.p[#b.p+1]=unitPrice end
end

function GMS:CaptureCurrentPage()
    local n,page,more=GetTradingHouseSearchResultsInfo()
    n=n or 0; page=page or 0

    for i=1,n do
        local _,name,_,stack,_,_,total,_,_,unit=GetTradingHouseSearchResultItemInfo(i)
        local link=GetTradingHouseSearchResultItemLink(i,LINK_STYLE_DEFAULT)
        if (not unit or unit<=0) and stack and stack>0 and total then unit=total/stack end
        self:BufferListing(link,name,unit)
    end

    self.scanLoaded=self.scanLoaded+n
    self.scanPage=page
    Chat(string.format("Page %d: %d listings loaded | Temporary item buffers: %d",page+1,n,Count(self.scanBuffer)))
    return page,more==true
end

function GMS:CommitScanBuffer()
    local guildKey=tostring(self.scanGuildId or "")
    local now=GetTimeStamp()
    local itemCount=0

    for link,b in pairs(self.scanBuffer) do
        if #b.p>0 then
            local item=self:GetOrCreateItem(link,b.n)
            local snap=self:BuildGuildSnapshot(b.p,now)
            if snap then
                item.g[guildKey]=snap
                self:PruneOldGuildSnapshots(item)
                itemCount=itemCount+1
            end
        end
    end

    self.scanBuffer={}
    self:Recount()
    return itemCount
end

function GMS:StopScan(reason,commit)
    if not self.isScanning then return end
    self.isScanning=false
    self.waitingForSearch=false

    local committed=0
    if commit then committed=self:CommitScanBuffer() else self.scanBuffer={} end

    self.saved.lastScan={
        guildId=self.scanGuildId,guildName=self.scanGuildName,
        completedAt=GetTimeStamp(),pagesProcessed=self.scanPage+1,
        loadedListings=self.scanLoaded,compactItemsUpdated=committed,
        reason=reason or "Stopped"
    }

    Chat(string.format(
        "%s | %s | Pages: %d | Loaded: %d | Compact items updated: %d | DB: %d items / %d guild snapshots",
        reason or "Stopped",self.scanGuildName,self.scanPage+1,self.scanLoaded,committed,
        self.saved.totalItems or 0,self.saved.totalGuildSnapshots or 0
    ))

    if KEYBIND_STRIP and self.keybindGroup then KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindGroup) end
end

function GMS:RequestPage(page)
    if not self.isScanning or not self.isTraderOpen or self.waitingForSearch then return end
    local cd=GetTradingHouseCooldownRemaining() or 0
    if cd>0 then zo_callLater(function() GMS:RequestPage(page) end,cd+100); return end
    self.waitingForSearch=true
    self.scanPage=page
    ExecuteTradingHouseSearch(page,TRADING_HOUSE_SORT_SALE_PRICE_PER_UNIT,true,true)
end

function GMS:StartScan()
    if self.isScanning then self:StopScan("Scan cancelled",false); return end
    local guildId,guildName=self:GetTrader()
    if guildId==0 then Chat("No Guild Trader is open."); return end

    self.isScanning=true
    self.waitingForSearch=false
    self.scanPage=0
    self.scanLoaded=0
    self.scanGuildId=guildId
    self.scanGuildName=guildName
    self.scanBuffer={}

    Chat("Starting OPTIMIZED compact market scan: "..tostring(guildName))
    self:RequestPage(0)
    if KEYBIND_STRIP and self.keybindGroup then KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindGroup) end
end

function GMS:OnTradingHouseResponse(responseType,result)
    if not self.isScanning or responseType~=TRADING_HOUSE_RESULT_SEARCH_PENDING then return end
    self.waitingForSearch=false

    if result~=TRADING_HOUSE_RESULT_SUCCESS then
        if result==TRADING_HOUSE_RESULT_SEARCH_RATE_EXCEEDED then
            local cd=GetTradingHouseCooldownRemaining() or 1000
            zo_callLater(function() if GMS.isScanning then GMS:RequestPage(GMS.scanPage) end end,math.max(cd,1000)+150)
            return
        end
        self:StopScan("Search stopped: "..tostring(result),false)
        return
    end

    local page,more=self:CaptureCurrentPage()
    if more then
        local cd=GetTradingHouseCooldownRemaining() or 0
        zo_callLater(function() if GMS.isScanning then GMS:RequestPage(page+1) end end,cd+150)
    else
        self:StopScan("SCAN COMPLETE",true)
    end
end

function GMS:AddTraderKeybind()
    if self.keybindAdded or not KEYBIND_STRIP then return end
    self.keybindGroup={
        alignment=KEYBIND_STRIP_ALIGN_LEFT,
        {
            name=function() return GMS.isScanning and "Cancel Scan" or "Scan Trader" end,
            keybind="UI_SHORTCUT_LEFT_STICK",
            callback=function() GMS:StartScan() end,
            visible=function() return GMS.isTraderOpen end,
        },
    }
    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindGroup)
    self.keybindAdded=true
end

function GMS:RemoveTraderKeybind()
    if self.keybindAdded and KEYBIND_STRIP and self.keybindGroup then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindGroup)
    end
    self.keybindAdded=false
end

function GMS:Initialize()
    self.saved=ZO_SavedVars:NewAccountWide("GuildMarketScannerSavedVariables",1,nil,defaults)

    if (self.saved.schemaVersion or 1)<6 then
        self:MigrateV5ToV6()
    else
        self.saved.items=self.saved.items or {}
        self:Recount()
    end

    SLASH_COMMANDS["/gmsprice"]=function(text) GMS:PrintPriceByName(text) end

    EVENT_MANAGER:RegisterForEvent(self.name.."_Open",EVENT_OPEN_TRADING_HOUSE,function()
        GMS.isTraderOpen=true; GMS:AddTraderKeybind(); Chat("Trader opened. Press Scan Trader to start.")
    end)

    EVENT_MANAGER:RegisterForEvent(self.name.."_Close",EVENT_CLOSE_TRADING_HOUSE,function()
        if GMS.isScanning then GMS:StopScan("Scan stopped: trader closed",false) end
        GMS.isTraderOpen=false; GMS:RemoveTraderKeybind()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name.."_Response",EVENT_TRADING_HOUSE_RESPONSE_RECEIVED,function(_,rt,res)
        GMS:OnTradingHouseResponse(rt,res)
    end)

    Chat("BUILD 011 LEAN STORAGE TEST")
    Chat("Guild Market Scanner DEV v0.1.1 loaded.")
    Chat(string.format("Lean DB: %d items / %d guild snapshots.",self.saved.totalItems or 0,self.saved.totalGuildSnapshots or 0))
end

local function OnAddonLoaded(_,addonName)
    if addonName~=GMS.name then return end
    EVENT_MANAGER:UnregisterForEvent(GMS.name,EVENT_ADD_ON_LOADED)
    GMS:Initialize()
end

EVENT_MANAGER:RegisterForEvent(GMS.name,EVENT_ADD_ON_LOADED,OnAddonLoaded)
