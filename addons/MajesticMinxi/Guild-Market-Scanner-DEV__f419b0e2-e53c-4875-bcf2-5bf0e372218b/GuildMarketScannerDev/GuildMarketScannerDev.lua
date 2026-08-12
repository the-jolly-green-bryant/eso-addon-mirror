GuildMarketScannerDev = GuildMarketScannerDev or {}
local GMS = GuildMarketScannerDev

GMS.name = "GuildMarketScannerDev"
GMS.version = "0.2.2"
GMS.schemaVersion = 7
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
GMS.exportRunning=false
GMS.exportKeys=nil
GMS.exportIndex=1
GMS.exportWorking=nil
GMS.exportItemCount=0
GMS.exportGuildRows=0
GMS.exportBatchSize=120

-- FLAT per-item snapshot array.
-- Repeating groups of 4:
-- { guildId, listingCount, guildMedian, updated, guildId, listingCount, guildMedian, updated, ... }
-- This replaces tens of thousands of child Lua tables.
local F_GUILD=0
local F_COUNT=1
local F_MED=2
local F_UPD=3
local F_STRIDE=4

local defaults={
    schemaVersion=7,
    items={},
    totalItems=0,
    totalGuildSnapshots=0,
    lastScan=nil,
    guildScans={},
    export=nil,
}

local function Chat(msg)
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage("|c66CCFF[GMS]|r "..tostring(msg))
    else
        d("[GMS] "..tostring(msg))
    end
end

local function MemoryMB()
    if collectgarbage then
        return (collectgarbage("count") or 0)/1024
    end
    return 0
end

local function CountFlatSnapshots(a)
    if not a then return 0 end
    return math.floor(#a/F_STRIDE)
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

local function BuildMedian(prices)
    if not prices or #prices==0 then return nil end
    local p={}
    for i=1,#prices do p[i]=prices[i] end
    table.sort(p)
    return math.floor((Median(p) or 0)+0.5)
end

function GMS:MemoryReport(label, doCollect)
    local before=MemoryMB()
    if doCollect and collectgarbage then collectgarbage("collect") end
    local after=MemoryMB()
    Chat(string.format("MEM %s: %.1f MB Lua%s",
        tostring(label or ""),
        after,
        doCollect and string.format(" (GC freed %.1f MB)",math.max(0,before-after)) or ""
    ))
end

function GMS:GetTrader()
    local id,name=GetCurrentTradingHouseGuildDetails()
    return id or 0,name or ""
end

function GMS:GetOrCreateItem(link,name)
    local item=self.saved.items[link]
    if not item then
        item={n=name or "",s={}}
        self.saved.items[link]=item
        self.saved.totalItems=(self.saved.totalItems or 0)+1
    end
    item.s=item.s or {}
    return item
end

function GMS:FindGuildOffset(flat,guildId)
    for i=1,#flat,F_STRIDE do
        if flat[i]==guildId then return i end
    end
    return nil
end

function GMS:PruneOldestGuildSnapshot(item)
    local flat=item.s
    local count=CountFlatSnapshots(flat)
    if count<=self.maxGuildSnapshotsPerItem then return end

    local oldestIndex=nil
    local oldestTime=nil
    for i=1,#flat,F_STRIDE do
        local t=flat[i+F_UPD] or 0
        if oldestTime==nil or t<oldestTime then
            oldestTime=t
            oldestIndex=i
        end
    end
    if oldestIndex then
        for _=1,F_STRIDE do table.remove(flat,oldestIndex) end
    end
end

function GMS:SetGuildSnapshot(item,guildId,count,median,updated)
    local flat=item.s
    local i=self:FindGuildOffset(flat,guildId)
    if i then
        flat[i]=guildId
        flat[i+F_COUNT]=count
        flat[i+F_MED]=median
        flat[i+F_UPD]=updated
    else
        flat[#flat+1]=guildId
        flat[#flat+1]=count
        flat[#flat+1]=median
        flat[#flat+1]=updated
        self:PruneOldestGuildSnapshot(item)
    end
end

function GMS:Recount()
    local items,snaps=0,0
    for _,item in pairs(self.saved.items or {}) do
        items=items+1
        item.s=item.s or {}
        snaps=snaps+CountFlatSnapshots(item.s)
    end
    self.saved.totalItems=items
    self.saved.totalGuildSnapshots=snaps
end

function GMS:AnalyzeItem(item)
    if not item or not item.s then return nil end

    local medians={}
    local counts={}
    local totalListings=0
    local newest=0

    for i=1,#item.s,F_STRIDE do
        local cnt=item.s[i+F_COUNT] or 1
        local med=item.s[i+F_MED]
        local upd=item.s[i+F_UPD] or 0
        if med and med>0 then
            medians[#medians+1]=med
            counts[#counts+1]=cnt
            totalListings=totalListings+cnt
            newest=math.max(newest,upd)
        end
    end

    if #medians==0 then return nil end

    -- Robust guild-level outlier rejection.
    local sorted={}
    for i=1,#medians do sorted[i]=medians[i] end
    table.sort(sorted)
    local rawMedian=Median(sorted)
    local q1=Percentile(sorted,0.25)
    local q3=Percentile(sorted,0.75)
    local iqr=math.max((q3 or rawMedian)-(q1 or rawMedian),1)
    local lowFence=math.max(0,(q1 or rawMedian)-1.5*iqr)
    local highFence=(q3 or rawMedian)+1.5*iqr

    local cluster={}
    local clusterWeights={}
    local lowOut,highOut=0,0

    for i=1,#medians do
        local price=medians[i]
        if price<lowFence then
            lowOut=lowOut+1
        elseif price>highFence then
            highOut=highOut+1
        else
            cluster[#cluster+1]=price
            -- Listing count still matters, but cap each guild so one giant store cannot dominate.
            clusterWeights[#clusterWeights+1]=math.min(counts[i] or 1,20)
        end
    end

    if #cluster==0 then
        cluster=medians
        clusterWeights=counts
    end

    -- Weighted median of guild medians: widespread repeated listings matter,
    -- but each guild has capped influence.
    local pairsList={}
    local totalWeight=0
    for i=1,#cluster do
        local w=math.max(1,math.min(clusterWeights[i] or 1,20))
        pairsList[#pairsList+1]={cluster[i],w}
        totalWeight=totalWeight+w
    end
    table.sort(pairsList,function(a,b) return a[1]<b[1] end)

    local target=totalWeight/2
    local running=0
    local suggested=pairsList[#pairsList][1]
    for i=1,#pairsList do
        running=running+pairsList[i][2]
        if running>=target then
            suggested=pairsList[i][1]
            break
        end
    end

    local clusterPrices={}
    for i=1,#cluster do clusterPrices[i]=cluster[i] end
    table.sort(clusterPrices)

    local confidence=0
    if #clusterPrices>=8 then confidence=3
    elseif #clusterPrices>=4 then confidence=2
    elseif #clusterPrices>=2 then confidence=1 end

    return {
        p=math.floor((suggested or rawMedian)+0.5),
        l=math.floor((Percentile(clusterPrices,0.25) or clusterPrices[1])+0.5),
        h=math.floor((Percentile(clusterPrices,0.75) or clusterPrices[#clusterPrices])+0.5),
        g=#medians,
        c=#clusterPrices,
        o=totalListings,
        lo=lowOut,
        hi=highOut,
        cf=confidence,
        u=newest,
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
        if n==query then
            best=item
            break
        elseif not best and string.find(n,query,1,true) then
            best=item
        end
    end

    if not best then
        Chat("No stored market data found for: "..query)
        return
    end

    local p=self:AnalyzeItem(best)
    if not p then
        Chat("No usable market profile for "..tostring(best.n))
        return
    end

    Chat(string.format(
        "%s | Suggested %dg | Typical %d-%dg | %d/%d guilds in cluster | %d listings represented | %d low + %d high guild outliers | Confidence %s",
        best.n or "Item",p.p,p.l,p.h,p.c,p.g,p.o,p.lo,p.hi,self:ConfidenceLabel(p.cf)
    ))
end

function GMS:MigrateToV7()
    Chat("FLATTENING market database for v0.2.0...")
    local oldItems=self.saved.items or {}
    local newItems={}
    local itemCount=0
    local snapCount=0

    for link,oldItem in pairs(oldItems) do
        local ni={n=oldItem.n or oldItem.itemName or "",s={}}

        if oldItem.s then
            -- Already flat safety path.
            for i=1,#oldItem.s do ni.s[i]=oldItem.s[i] end
        else
            local guilds=oldItem.g or oldItem.guilds or {}
            for guildKey,s in pairs(guilds) do
                local gid=tonumber(guildKey) or guildKey
                local cnt,med,upd

                if s.med~=nil then
                    cnt=s.n or 1
                    med=s.med or 0
                    upd=s.updated or 0
                else
                    -- v0.1.1 indexed snapshot: {count,median,q1,q3,updated}
                    cnt=s[1] or 1
                    med=s[2] or 0
                    upd=s[5] or 0
                end

                ni.s[#ni.s+1]=gid
                ni.s[#ni.s+1]=cnt
                ni.s[#ni.s+1]=med
                ni.s[#ni.s+1]=upd
                snapCount=snapCount+1
            end
        end

        if #ni.s>0 then
            newItems[link]=ni
            itemCount=itemCount+1
        end
    end

    self.saved.items=newItems
    self.saved.priceData=nil
    self.saved.priceDataCount=nil
    self.saved.priceDataUpdated=nil
    self.saved.schemaVersion=7
    self:Recount()

    oldItems=nil
    if collectgarbage then collectgarbage("collect") end

    Chat(string.format(
        "FLATTEN COMPLETE: %d items / %d guild snapshots. Nested snapshot tables removed.",
        self.saved.totalItems,self.saved.totalGuildSnapshots
    ))
    self:MemoryReport("after flatten GC",false)
end

function GMS:BufferListing(link,name,unitPrice)
    if not link or link=="" or not unitPrice or unitPrice<=0 then return end
    local b=self.scanBuffer[link]
    if not b then
        b={n=name or "",p={}}
        self.scanBuffer[link]=b
    end
    if #b.p<self.maxPricesPerItemDuringScan then
        b.p[#b.p+1]=unitPrice
    end
end

function GMS:CaptureCurrentPage()
    local n,page,more=GetTradingHouseSearchResultsInfo()
    n=n or 0
    page=page or 0

    for i=1,n do
        local _,name,_,stack,_,_,total,_,_,unit=GetTradingHouseSearchResultItemInfo(i)
        local link=GetTradingHouseSearchResultItemLink(i,LINK_STYLE_DEFAULT)
        if (not unit or unit<=0) and stack and stack>0 and total then
            unit=total/stack
        end
        self:BufferListing(link,name,unit)
    end

    self.scanLoaded=self.scanLoaded+n
    self.scanPage=page

    local buffers=0
    for _ in pairs(self.scanBuffer) do buffers=buffers+1 end

    Chat(string.format(
        "Page %d: %d listings loaded | Temporary item buffers: %d",
        page+1,n,buffers
    ))
    return page,more==true
end

function GMS:CommitScanBuffer()
    local guildId=self.scanGuildId or 0
    local now=GetTimeStamp()
    local itemCount=0

    for link,b in pairs(self.scanBuffer) do
        if #b.p>0 then
            local med=BuildMedian(b.p)
            if med then
                local item=self:GetOrCreateItem(link,b.n)
                self:SetGuildSnapshot(item,guildId,#b.p,med,now)
                itemCount=itemCount+1
            end
        end
    end

    self.scanBuffer={}
    if collectgarbage then collectgarbage("collect") end
    self:Recount()
    self:MemoryReport("after scan cleanup",false)
    return itemCount
end

function GMS:RecordCompletedGuildScan()
    self.saved.guildScans=self.saved.guildScans or {}
    if not self.scanGuildId or self.scanGuildId==0 then return end
    self.saved.guildScans[tostring(self.scanGuildId)]={
        n=self.scanGuildName or "",
        t=GetTimeStamp(),
        l=self.scanLoaded or 0,
    }
end

function GMS:GuildScanCount()
    local n=0
    for _ in pairs(self.saved.guildScans or {}) do n=n+1 end
    return n
end

function GMS:StopScan(reason,commit)
    if not self.isScanning then return end

    self.isScanning=false
    self.waitingForSearch=false

    local committed=0
    if commit then
        committed=self:CommitScanBuffer()
        self:RecordCompletedGuildScan()
    else
        self.scanBuffer={}
        if collectgarbage then collectgarbage("collect") end
    end

    self.saved.lastScan={
        guildId=self.scanGuildId,
        guildName=self.scanGuildName,
        completedAt=GetTimeStamp(),
        pagesProcessed=self.scanPage+1,
        loadedListings=self.scanLoaded,
        compactItemsUpdated=committed,
        reason=reason or "Stopped",
    }

    Chat(string.format(
        "%s | %s | Pages: %d | Loaded: %d | Compact items updated: %d | DB: %d items / %d guild snapshots",
        reason or "Stopped",self.scanGuildName,self.scanPage+1,self.scanLoaded,committed,
        self.saved.totalItems or 0,self.saved.totalGuildSnapshots or 0
    ))

    if KEYBIND_STRIP and self.keybindGroup then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindGroup)
    end
end

function GMS:RequestPage(page)
    if not self.isScanning or not self.isTraderOpen or self.waitingForSearch then return end

    local cd=GetTradingHouseCooldownRemaining() or 0
    if cd>0 then
        zo_callLater(function() GMS:RequestPage(page) end,cd+100)
        return
    end

    self.waitingForSearch=true
    self.scanPage=page
    ExecuteTradingHouseSearch(page,TRADING_HOUSE_SORT_SALE_PRICE_PER_UNIT,true,true)
end

function GMS:StartScan()
    if self.isScanning then
        self:StopScan("Scan cancelled",false)
        return
    end

    local guildId,guildName=self:GetTrader()
    if guildId==0 then
        Chat("No Guild Trader is open.")
        return
    end

    self.isScanning=true
    self.waitingForSearch=false
    self.scanPage=0
    self.scanLoaded=0
    self.scanGuildId=guildId
    self.scanGuildName=guildName
    self.scanBuffer={}

    Chat("Starting FLAT compact market scan: "..tostring(guildName))
    self:RequestPage(0)

    if KEYBIND_STRIP and self.keybindGroup then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindGroup)
    end
end

function GMS:OnTradingHouseResponse(responseType,result)
    if not self.isScanning or responseType~=TRADING_HOUSE_RESULT_SEARCH_PENDING then return end

    self.waitingForSearch=false

    if result~=TRADING_HOUSE_RESULT_SUCCESS then
        if result==TRADING_HOUSE_RESULT_SEARCH_RATE_EXCEEDED then
            local cd=GetTradingHouseCooldownRemaining() or 1000
            zo_callLater(function()
                if GMS.isScanning then GMS:RequestPage(GMS.scanPage) end
            end,math.max(cd,1000)+150)
            return
        end

        self:StopScan("Search stopped: "..tostring(result),false)
        return
    end

    local page,more=self:CaptureCurrentPage()
    if more then
        local cd=GetTradingHouseCooldownRemaining() or 0
        zo_callLater(function()
            if GMS.isScanning then GMS:RequestPage(page+1) end
        end,cd+150)
    else
        self:StopScan("SCAN COMPLETE",true)
    end
end

function GMS:CancelExport()
    self.exportRunning=false
    self.exportKeys=nil
    self.exportWorking=nil
    self.exportIndex=1
    self.exportItemCount=0
    self.exportGuildRows=0
    if collectgarbage then collectgarbage("collect") end
end

function GMS:FinishExport()
    if not self.exportWorking then
        self:CancelExport()
        return
    end

    self.saved.export=self.exportWorking

    local items=self.exportItemCount or 0
    local guildRows=self.exportGuildRows or 0
    local guilds=self:GuildScanCount()

    self.exportRunning=false
    self.exportKeys=nil
    self.exportWorking=nil
    self.exportIndex=1
    self.exportItemCount=0
    self.exportGuildRows=0

    if collectgarbage then collectgarbage("collect") end

    Chat(string.format(
        "EXPORT READY: %d items / %d guild rows / %d scanned guilds.",
        items,guildRows,guilds
    ))
    Chat("Export saved in GuildMarketScannerSavedVariables -> export.")
    Chat("Now /reloadui once to force SavedVariables to persist.")
    self:MemoryReport("after export",false)
end

function GMS:ProcessExportBatch()
    if not self.exportRunning or not self.exportKeys or not self.exportWorking then
        return
    end

    local last=math.min(self.exportIndex+self.exportBatchSize-1,#self.exportKeys)

    for idx=self.exportIndex,last do
        local link=self.exportKeys[idx]
        local item=self.saved.items[link]
        if item then
            local a=self:AnalyzeItem(item)
            if a then
                local guildData={}
                for i=1,#item.s,F_STRIDE do
                    guildData[#guildData+1]=item.s[i] or 0
                    guildData[#guildData+1]=item.s[i+F_COUNT] or 0
                    guildData[#guildData+1]=item.s[i+F_MED] or 0
                    guildData[#guildData+1]=item.s[i+F_UPD] or 0
                    self.exportGuildRows=self.exportGuildRows+1
                end

                self.exportWorking.items[link]={
                    item.n or "",
                    a.p or 0,
                    a.l or 0,
                    a.h or 0,
                    a.cf or 0,
                    a.g or 0,
                    a.o or 0,
                    a.u or 0,
                    guildData,
                }
                self.exportItemCount=self.exportItemCount+1
            end
        end
    end

    self.exportIndex=last+1

    if self.exportIndex>#self.exportKeys then
        self:FinishExport()
        return
    end

    local done=self.exportIndex-1
    local total=#self.exportKeys

    if done==self.exportBatchSize or done%1200<self.exportBatchSize then
        Chat(string.format("EXPORT PROGRESS: %d/%d items (%.0f%%)",
            done,total,(done/total)*100))
    end

    zo_callLater(function()
        GMS:ProcessExportBatch()
    end,10)
end

function GMS:BuildExport()
    if self.exportRunning then
        Chat("Export is already running.")
        return
    end

    Chat("BUILDING PRICE DATA EXPORT IN BATCHES...")

    local export={
        v=1,
        generated=GetTimeStamp(),
        world=GetWorldName and GetWorldName() or "",
        guilds={},
        items={},
    }

    for guildId,g in pairs(self.saved.guildScans or {}) do
        export.guilds[guildId]={g.n or "",g.t or 0,g.l or 0}
    end

    local keys={}
    for link in pairs(self.saved.items or {}) do
        keys[#keys+1]=link
    end

    self.exportRunning=true
    self.exportKeys=keys
    self.exportIndex=1
    self.exportWorking=export
    self.exportItemCount=0
    self.exportGuildRows=0

    Chat(string.format("EXPORT START: %d item records queued. Batch size: %d.",
        #keys,self.exportBatchSize))

    zo_callLater(function()
        GMS:ProcessExportBatch()
    end,10)
end

function GMS:ClearExport()
    if self.exportRunning then
        Chat("Cannot clear export while export is running.")
        return
    end

    self.saved.export=nil
    if collectgarbage then collectgarbage("collect") end
    Chat("Temporary export cache cleared.")
    self:MemoryReport("after export clear",false)
end

function GMS:AddTraderKeybind()
    if self.keybindAdded or not KEYBIND_STRIP then return end

    self.keybindGroup={
        alignment=KEYBIND_STRIP_ALIGN_LEFT,
        {
            name=function()
                return GMS.isScanning and "Cancel Scan" or "Scan Trader"
            end,
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
    self.saved=ZO_SavedVars:NewAccountWide(
        "GuildMarketScannerSavedVariables",
        1,nil,defaults
    )

    self:MemoryReport("loaded saved vars",false)

    if (self.saved.schemaVersion or 1)<7 then
        self:MigrateToV7()
    else
        self.saved.items=self.saved.items or {}
        self:Recount()
    end

    SLASH_COMMANDS["/gmsprice"]=function(text)
        GMS:PrintPriceByName(text)
    end

    SLASH_COMMANDS["/gmsmem"]=function()
        GMS:MemoryReport("manual",true)
    end

    SLASH_COMMANDS["/gmsexport"]=function()
        GMS:BuildExport()
    end

    SLASH_COMMANDS["/gmsclearexport"]=function()
        GMS:ClearExport()
    end

    SLASH_COMMANDS["/gmscancelxport"]=function()
        if GMS.exportRunning then
            GMS:CancelExport()
            Chat("Export cancelled.")
        else
            Chat("No export is currently running.")
        end
    end

    EVENT_MANAGER:RegisterForEvent(
        self.name.."_Open",
        EVENT_OPEN_TRADING_HOUSE,
        function()
            GMS.isTraderOpen=true
            GMS:AddTraderKeybind()
            Chat("Trader opened. Press Scan Trader to start.")
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.name.."_Close",
        EVENT_CLOSE_TRADING_HOUSE,
        function()
            if GMS.isScanning then
                GMS:StopScan("Scan stopped: trader closed",false)
            end
            GMS.isTraderOpen=false
            GMS:RemoveTraderKeybind()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.name.."_Response",
        EVENT_TRADING_HOUSE_RESPONSE_RECEIVED,
        function(_,rt,res)
            GMS:OnTradingHouseResponse(rt,res)
        end
    )

    if collectgarbage then collectgarbage("collect") end

    Chat("BUILD 022 BATCHED PRICE DATA EXPORT")
    Chat("Guild Market Scanner DEV v0.2.2 loaded.")
    Chat(string.format(
        "Flat DB: %d items / %d guild snapshots.",
        self.saved.totalItems or 0,
        self.saved.totalGuildSnapshots or 0
    ))
    Chat(string.format("Registered completed scans: %d guilds.",self:GuildScanCount()))
    Chat("Use /gmsexport only when you want to generate the library export.")
    self:MemoryReport("startup final",false)
end

local function OnAddonLoaded(_,addonName)
    if addonName~=GMS.name then return end
    EVENT_MANAGER:UnregisterForEvent(GMS.name,EVENT_ADD_ON_LOADED)
    GMS:Initialize()
end

EVENT_MANAGER:RegisterForEvent(GMS.name,EVENT_ADD_ON_LOADED,OnAddonLoaded)
