GuildMarketScannerDev = GuildMarketScannerDev or {}
local GMS = GuildMarketScannerDev

GMS.name = "GuildMarketScannerDev"
GMS.version = "0.7.3"
GMS.schemaVersion = 10
GMS.maxGuildSnapshotsPerItem = 20
GMS.maxPricesPerItemDuringScan = 24
GMS.snapshotFields = 9
GMS.memoryHardLimitMB = 118
GMS.memoryMaxScanGrowthMB = 22
GMS.scanStartMemoryMB = 0

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
GMS.exportCurrentChunk=nil
GMS.exportCurrentChunkBytes=0
GMS.exportChunkTargetBytes=24000
GMS.priceSearchRunning=false
GMS.priceSearchQuery=nil
GMS.priceSearchLastKey=nil
GMS.priceSearchBestKey=nil

GMS.streamExportRunning=false
GMS.streamExportLastKey=nil
GMS.streamExportLines=nil
GMS.streamExportBytes=0
GMS.streamExportTargetBytes=24000
GMS.streamExportTotalItems=0
GMS.streamExportTotalGuildRows=0
GMS.cloudExportRunning=false
GMS.cloudExportSid=nil
GMS.cloudExportLastKey=nil
GMS.cloudExportPart=0
GMS.cloudExportTotalItems=0
GMS.cloudExportTotalGuildRows=0
GMS.cloudExportChunkTargetBytes=4000
GMS.cloudExportMinGuilds=3
GMS.cloudExportMode="price"
GMS.cloudOpportunityMode=false

local defaults={
    schemaVersion=10,
    items={},
    totalItems=0,
    totalGuildSnapshots=0,
    lastScan=nil,
    guildScans={},
    pendingGuilds={},
    marketSyncVersion=1,
    marketSyncBootstrapVersion=0,
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

local SNAP62="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

local function PackNum(n)
    n=math.floor(math.max(0,tonumber(n) or 0)+0.5)
    if n<=0 then return "0" end
    local out={}
    while n>0 do
        local r=(n%62)+1
        out[#out+1]=string.sub(SNAP62,r,r)
        n=math.floor(n/62)
    end
    local rev={}
    for i=#out,1,-1 do rev[#rev+1]=out[i] end
    return table.concat(rev)
end

local function UnpackNum(s)
    s=tostring(s or "")
    local n=0
    for i=1,#s do
        local ch=string.sub(s,i,i)
        local p=string.find(SNAP62,ch,1,true)
        if not p then return 0 end
        n=n*62+(p-1)
    end
    return n
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

local function BuildLocalPriceSummary(prices)
    if not prices or #prices==0 then return nil,nil,nil,nil,nil end

    local p={}
    for i=1,#prices do
        local v=tonumber(prices[i])
        if v and v>0 then p[#p+1]=v end
    end
    if #p==0 then return nil,nil,nil,nil,nil end

    table.sort(p)

    local rawMin=math.floor((p[1] or 0)+0.5)
    local rawMax=math.floor((p[#p] or 0)+0.5)

    if #p<4 then
        local med=math.floor((Median(p) or p[1])+0.5)
        local low=math.floor((p[1] or med)+0.5)
        local high=math.floor((p[#p] or med)+0.5)
        return low,med,high,rawMin,rawMax
    end

    local rawMedian=Median(p)
    local q1=Percentile(p,0.25)
    local q3=Percentile(p,0.75)
    local iqr=math.max((q3 or rawMedian)-(q1 or rawMedian),1)
    local lowFence=math.max(0,(q1 or rawMedian)-1.5*iqr)
    local highFence=(q3 or rawMedian)+1.5*iqr

    local clean={}
    for i=1,#p do
        if p[i]>=lowFence and p[i]<=highFence then
            clean[#clean+1]=p[i]
        end
    end
    if #clean==0 then clean=p end

    local low=math.floor((Percentile(clean,0.25) or clean[1])+0.5)
    local med=math.floor((Median(clean) or rawMedian)+0.5)
    local high=math.floor((Percentile(clean,0.75) or clean[#clean])+0.5)

    return low,med,high,rawMin,rawMax
end

local function Escape(s)
    s=tostring(s or "")
    s=string.gsub(s,"%%","%%25")
    s=string.gsub(s,"|","%%7C")
    s=string.gsub(s,";","%%3B")
    s=string.gsub(s,",","%%2C")
    s=string.gsub(s,"\n","%%0A")
    s=string.gsub(s,"\r","")
    return s
end

local function Unescape(s)
    s=tostring(s or "")
    s=string.gsub(s,"%%0A","\n")
    s=string.gsub(s,"%%2C",",")
    s=string.gsub(s,"%%3B",";")
    s=string.gsub(s,"%%7C","|")
    s=string.gsub(s,"%%25","%%")
    return s
end

local function HashLink(link,seed)
    local h=seed or 5381
    for i=1,#link do
        h=(h*33+string.byte(link,i))%2147483647
    end
    return h
end

local function ItemKey(link)
    return tostring(HashLink(link,5381))..":"..
           tostring(HashLink(link,7919))..":"..
           tostring(#link)
end

local function RecordName(record)
    if not record then return "" end
    local p=string.find(record,"|",1,true)
    if not p then return Unescape(record) end
    return Unescape(string.sub(record,1,p-1))
end

local function ParseRecord(record)
    local name=""
    local flat={}
    if not record or record=="" then return name,flat end

    local p=string.find(record,"|",1,true)
    local data=""
    if p then
        name=Unescape(string.sub(record,1,p-1))
        data=string.sub(record,p+1)
    else
        name=Unescape(record)
    end

    for row in string.gmatch(data,"([^;]+)") do
        if string.sub(row,1,1)=="~" then
            local body=string.sub(row,2)

            -- v10 packed row: guild,count,units,low,median,high,rawMin,rawMax,time
            local g,c,u,l,m,h,rmin,rmax,t=
                string.match(body,
                    "^([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)$"
                )

            if g then
                flat[#flat+1]=UnpackNum(g)
                flat[#flat+1]=UnpackNum(c)
                flat[#flat+1]=UnpackNum(u)
                flat[#flat+1]=UnpackNum(l)
                flat[#flat+1]=UnpackNum(m)
                flat[#flat+1]=UnpackNum(h)
                flat[#flat+1]=UnpackNum(rmin)
                flat[#flat+1]=UnpackNum(rmax)
                flat[#flat+1]=UnpackNum(t)
            else
                -- v9 packed row: guild,count,units,low,median,high,time
                local g9,c9,u9,l9,m9,h9,t9=
                    string.match(body,
                        "^([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)$"
                    )

                if g9 then
                    local guild=UnpackNum(g9)
                    local count=UnpackNum(c9)
                    local units=UnpackNum(u9)
                    local low=UnpackNum(l9)
                    local med=UnpackNum(m9)
                    local high=UnpackNum(h9)
                    local upd=UnpackNum(t9)

                    flat[#flat+1]=guild
                    flat[#flat+1]=count
                    flat[#flat+1]=units
                    flat[#flat+1]=low
                    flat[#flat+1]=med
                    flat[#flat+1]=high
                    flat[#flat+1]=low
                    flat[#flat+1]=high
                    flat[#flat+1]=upd
                end
            end
        else
            -- v8 decimal row: guild,count,median,time
            local g,c,m,t=
                string.match(row,"^([^,]+),([^,]+),([^,]+),([^,]+)$")
            if g then
                local guild=tonumber(g) or 0
                local count=tonumber(c) or 0
                local median=tonumber(m) or 0
                local updated=tonumber(t) or 0

                flat[#flat+1]=guild
                flat[#flat+1]=count
                flat[#flat+1]=count
                flat[#flat+1]=median
                flat[#flat+1]=median
                flat[#flat+1]=median
                flat[#flat+1]=median
                flat[#flat+1]=median
                flat[#flat+1]=updated
            end
        end
    end

    return name,flat
end

local function SerializeRecord(name,flat)
    local rows={}
    for i=1,#flat,9 do
        rows[#rows+1]="~"..
            PackNum(flat[i] or 0)..","..
            PackNum(flat[i+1] or 0)..","..
            PackNum(flat[i+2] or 0)..","..
            PackNum(flat[i+3] or 0)..","..
            PackNum(flat[i+4] or 0)..","..
            PackNum(flat[i+5] or 0)..","..
            PackNum(flat[i+6] or 0)..","..
            PackNum(flat[i+7] or 0)..","..
            PackNum(flat[i+8] or 0)
    end
    return Escape(name or "").."|"..table.concat(rows,";")
end

local function SnapshotCount(record)
    if not record then return 0 end
    local p=string.find(record,"|",1,true)
    if not p then return 0 end
    local data=string.sub(record,p+1)
    if data=="" then return 0 end
    local n=1
    for _ in string.gmatch(data,";") do n=n+1 end
    return n
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

function GMS:GetOrCreateItem(key,name)
    -- Compatibility helper: permanent records are strings, not child tables.
    local record=self.saved.items[key]
    if not record then
        self.saved.items[key]=SerializeRecord(name or "",{})
        self.saved.totalItems=(self.saved.totalItems or 0)+1
    end
    return key
end

function GMS:FindGuildOffset(flat,guildId)
    for i=1,#flat,9 do
        if tostring(flat[i])==tostring(guildId) then return i end
    end
    return nil
end

function GMS:PruneOldestGuildSnapshot(flat)
    while (#flat/9)>self.maxGuildSnapshotsPerItem do
        local oldestOffset=nil
        local oldestTime=nil

        for i=1,#flat,9 do
            local t=flat[i+8] or 0
            if oldestTime==nil or t<oldestTime then
                oldestTime=t
                oldestOffset=i
            end
        end

        if not oldestOffset then break end
        for _=1,9 do table.remove(flat,oldestOffset) end
    end
end

function GMS:SetGuildSnapshot(
    key,name,guildId,count,totalUnits,localLow,median,localHigh,rawMin,rawMax,updated
)
    local oldRecord=self.saved.items[key]
    local oldName,flat=ParseRecord(oldRecord)
    if oldName~="" then name=oldName end

    local oldCount=#flat/9
    local offset=self:FindGuildOffset(flat,guildId)

    if offset then
        flat[offset]=guildId
        flat[offset+1]=count
        flat[offset+2]=totalUnits
        flat[offset+3]=localLow
        flat[offset+4]=median
        flat[offset+5]=localHigh
        flat[offset+6]=rawMin
        flat[offset+7]=rawMax
        flat[offset+8]=updated
    else
        flat[#flat+1]=guildId
        flat[#flat+1]=count
        flat[#flat+1]=totalUnits
        flat[#flat+1]=localLow
        flat[#flat+1]=median
        flat[#flat+1]=localHigh
        flat[#flat+1]=rawMin
        flat[#flat+1]=rawMax
        flat[#flat+1]=updated
    end

    self:PruneOldestGuildSnapshot(flat)

    if not oldRecord then
        self.saved.totalItems=(self.saved.totalItems or 0)+1
    end

    self.saved.items[key]=SerializeRecord(name or "",flat)

    local newCount=#flat/9
    self.saved.totalGuildSnapshots=
        math.max(
            0,
            (self.saved.totalGuildSnapshots or 0)+(newCount-oldCount)
        )
end

function GMS:Recount()
    local items,snaps=0,0
    for _,record in pairs(self.saved.items or {}) do
        items=items+1
        snaps=snaps+SnapshotCount(record)
    end
    self.saved.totalItems=items
    self.saved.totalGuildSnapshots=snaps
end

function GMS:AnalyzeItem(record)
    local _,flat=ParseRecord(record)
    if #flat==0 then return nil end

    local medians={}
    local counts={}
    local totalListings=0
    local totalUnits=0
    local newest=0
    local observedMin=nil
    local observedMax=nil

    for i=1,#flat,9 do
        local cnt=tonumber(flat[i+1]) or 1
        local units=tonumber(flat[i+2]) or cnt
        local med=tonumber(flat[i+4])
        local rmin=tonumber(flat[i+6])
        local rmax=tonumber(flat[i+7])
        local upd=tonumber(flat[i+8]) or 0

        if med and med>0 then
            medians[#medians+1]=med
            counts[#counts+1]=cnt
            totalListings=totalListings+cnt
            totalUnits=totalUnits+units
            newest=math.max(newest,upd)

            if rmin and rmin>0 then
                observedMin=observedMin and math.min(observedMin,rmin) or rmin
            end
            if rmax and rmax>0 then
                observedMax=observedMax and math.max(observedMax,rmax) or rmax
            end
        end
    end

    if #medians==0 then return nil end

    local sorted={}
    for i=1,#medians do sorted[i]=medians[i] end
    table.sort(sorted)

    local rawMedian=Median(sorted)
    local q1=Percentile(sorted,0.25)
    local q3=Percentile(sorted,0.75)
    local iqr=math.max((q3 or rawMedian)-(q1 or rawMedian),1)
    local lowFence=math.max(0,(q1 or rawMedian)-1.5*iqr)
    local highFence=(q3 or rawMedian)+1.5*iqr

    local pairsList={}
    local clusterPrices={}
    local lowOut,highOut,totalWeight=0,0,0

    for i=1,#medians do
        local price=medians[i]
        if price<lowFence then
            lowOut=lowOut+1
        elseif price>highFence then
            highOut=highOut+1
        else
            local w=math.max(1,math.min(counts[i] or 1,20))
            pairsList[#pairsList+1]={price,w}
            clusterPrices[#clusterPrices+1]=price
            totalWeight=totalWeight+w
        end
    end

    if #pairsList==0 then
        for i=1,#medians do
            local w=math.max(1,math.min(counts[i] or 1,20))
            pairsList[#pairsList+1]={medians[i],w}
            clusterPrices[#clusterPrices+1]=medians[i]
            totalWeight=totalWeight+w
        end
    end

    table.sort(pairsList,function(a,b) return a[1]<b[1] end)
    table.sort(clusterPrices)

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

    local confidence=0
    if #clusterPrices>=8 then confidence=3
    elseif #clusterPrices>=4 then confidence=2
    elseif #clusterPrices>=2 then confidence=1 end

    return {
        p=math.floor((suggested or rawMedian)+0.5),
        l=math.floor((Percentile(clusterPrices,0.25) or clusterPrices[1])+0.5),
        h=math.floor((Percentile(clusterPrices,0.75) or clusterPrices[#clusterPrices])+0.5),
        mn=observedMin or math.floor((clusterPrices[1] or suggested)+0.5),
        mx=observedMax or math.floor((clusterPrices[#clusterPrices] or suggested)+0.5),
        g=#medians,
        c=#clusterPrices,
        o=totalListings,
        v=totalUnits,
        lo=lowOut,
        hi=highOut,
        cf=confidence,
        u=newest
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
    if query=="" then Chat("Usage: /gmsprice item name");return end
    if self.priceSearchRunning then Chat("A price search is already running.");return end

    self.priceSearchRunning=true
    self.priceSearchQuery=query
    self.priceSearchLastKey=nil
    self.priceSearchBestKey=nil

    local function process()
        if not GMS.priceSearchRunning then return end
        local processed=0
        local key=GMS.priceSearchLastKey

        while processed<350 do
            local nextKey,record=next(GMS.saved.items,key)
            if not nextKey then
                GMS.priceSearchRunning=false
                local best=GMS.priceSearchBestKey
                GMS.priceSearchLastKey=nil
                if not best then
                    Chat("No stored market data found for: "..query)
                    return
                end
                local bestRecord=GMS.saved.items[best]
                local a=GMS:AnalyzeItem(bestRecord)
                local name=RecordName(bestRecord)
                if a then
                    Chat(string.format(
                        "%s | Suggested %dg | Typical %d-%dg | %d/%d guilds in cluster | %d listings represented | %d low + %d high guild outliers | Confidence %s",
                        name,a.p,a.l,a.h,a.c,a.g,a.o,a.lo,a.hi,GMS:ConfidenceLabel(a.cf)
                    ))
                end
                return
            end

            key=nextKey
            GMS.priceSearchLastKey=nextKey
            processed=processed+1
            local name=RecordName(record)
            local lower=string.lower(name or "")

            if lower==query then
                GMS.priceSearchRunning=false
                GMS.priceSearchLastKey=nil
                local a=GMS:AnalyzeItem(record)
                if a then
                    Chat(string.format(
                        "%s | Suggested %dg | Typical %d-%dg | %d/%d guilds in cluster | %d listings represented | %d low + %d high guild outliers | Confidence %s",
                        name,a.p,a.l,a.h,a.c,a.g,a.o,a.lo,a.hi,GMS:ConfidenceLabel(a.cf)
                    ))
                end
                return
            elseif not GMS.priceSearchBestKey and string.find(lower,query,1,true) then
                GMS.priceSearchBestKey=nextKey
            end
        end
        zo_callLater(process,10)
    end

    process()
end

function GMS:MigrateToV10()
    self.saved.items=self.saved.items or {}
    self.saved.guildScans=self.saved.guildScans or {}
    self.saved.totalItems=self.saved.totalItems or 0
    self.saved.totalGuildSnapshots=self.saved.totalGuildSnapshots or 0
    self.saved.schemaVersion=10

    self:Recount()

    if collectgarbage then
        collectgarbage("collect")
    end

    Chat("GMS schema v10 enabled without deleting the existing market database.")
    Chat("Old v8/v9 snapshots remain readable and convert to compact v10 when rescanned.")
end
function GMS:BufferListing(link,name,unitPrice,quantity)
    if not link or link=="" or not unitPrice or unitPrice<=0 then return end

    local key=ItemKey(link)
    local b=self.scanBuffer[key]

    if not b then
        b={
            n=name or "",
            p={},
            c=0,
            u=0,
        }
        self.scanBuffer[key]=b
    end

    b.c=(b.c or 0)+1
    b.u=(b.u or 0)+math.max(1,tonumber(quantity) or 1)

    -- Prices are only a temporary bounded sample for the local cluster.
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
        self:BufferListing(link,name,unit,stack)
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

function GMS:BeginCommitScanBuffer(reason)
    if self.isCommitting then return end

    self.isCommitting=true
    self.commitReason=reason or "SCAN COMPLETE"
    self.commitGuildId=self.scanGuildId or 0
    self.commitNow=GetTimeStamp()
    self.commitItemCount=0
    self.commitKeys={}
    self.commitIndex=1

    for key,_ in pairs(self.scanBuffer or {}) do
        self.commitKeys[#self.commitKeys+1]=key
    end

    Chat(string.format(
        "Finalizing scan in frame-safe batches: %d temporary item buffers...",
        #self.commitKeys
    ))

    zo_callLater(function()
        GMS:CommitScanBufferBatch()
    end,25)
end

function GMS:CommitScanBufferBatch()
    if not self.isCommitting then return end

    local keys=self.commitKeys or {}
    local startIndex=self.commitIndex or 1
    local batchSize=35
    local stopIndex=math.min(startIndex+batchSize-1,#keys)

    for i=startIndex,stopIndex do
        local key=keys[i]
        local b=self.scanBuffer and self.scanBuffer[key]

        if b and b.p and #b.p>0 then
            local low,med,high,rawMin,rawMax=BuildLocalPriceSummary(b.p)

            if med then
                self:SetGuildSnapshot(
                    key,
                    b.n,
                    self.commitGuildId or 0,
                    b.c or #b.p,
                    b.u or (b.c or #b.p),
                    low or med,
                    med,
                    high or med,
                    rawMin or low or med,
                    rawMax or high or med,
                    self.commitNow or GetTimeStamp()
                )
                self.commitItemCount=(self.commitItemCount or 0)+1
            end
        end

        -- Release each temporary item buffer as soon as it is committed.
        if self.scanBuffer then
            self.scanBuffer[key]=nil
        end
    end

    self.commitIndex=stopIndex+1

    if self.commitIndex<=#keys then
        zo_callLater(function()
            GMS:CommitScanBufferBatch()
        end,25)
        return
    end

    local committed=self.commitItemCount or 0

    self.scanBuffer={}
    self.commitKeys=nil
    self.commitIndex=nil
    self.commitItemCount=nil
    self.commitGuildId=nil
    self.commitNow=nil
    self.isCommitting=false

    if collectgarbage then
        collectgarbage("collect")
    end

    self:MemoryReport("after scan cleanup",false)
    self:FinalizeStoppedScan(self.commitReason or "SCAN COMPLETE",committed,true)
    self.commitReason=nil
end

function GMS:FinalizeStoppedScan(reason,committed,recordGuild)
    committed=committed or 0

    if recordGuild then
        self:RecordCompletedGuildScan()
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

function GMS:RecordCompletedGuildScan()
    self.saved.guildScans=self.saved.guildScans or {}
    self.saved.pendingGuilds=self.saved.pendingGuilds or {}

    if not self.scanGuildId or self.scanGuildId==0 then return end

    local guildId=tostring(self.scanGuildId)
    local now=GetTimeStamp()

    self.saved.guildScans[guildId]=
        Escape(self.scanGuildName or "").."|"..
        tostring(now).."|"..
        tostring(self.scanLoaded or 0)

    -- A completed rescan replaces this guild in the next Market Sync.
    self.saved.pendingGuilds[guildId]=now
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

    if commit then
        self:BeginCommitScanBuffer(reason or "SCAN COMPLETE")
        return
    end

    self.scanBuffer={}
    if collectgarbage then collectgarbage("collect") end

    self:FinalizeStoppedScan(reason or "Stopped",0,false)
end

function GMS:CheckScanMemory()
    if not self.isScanning then return true end

    local current=MemoryMB()
    local growth=current-(self.scanStartMemoryMB or current)

    if current<(self.memoryHardLimitMB or 118) and
       growth<(self.memoryMaxScanGrowthMB or 22) then
        return true
    end

    if collectgarbage then
        collectgarbage("collect")
    end

    current=MemoryMB()
    growth=current-(self.scanStartMemoryMB or current)

    if current>=(self.memoryHardLimitMB or 118) or
       growth>=(self.memoryMaxScanGrowthMB or 22) then

        Chat(string.format(
            "MEMORY SAFETY: scan stopped at %.1f MB Lua (scan growth %.1f MB). No partial guild scan will be committed.",
            current,
            math.max(0,growth)
        ))

        return false
    end

    return true
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
    if self.isCommitting then
        Chat("Previous trader scan is still finalizing. Please wait for SCAN COMPLETE.")
        return
    end

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
    self.scanStartMemoryMB=MemoryMB()

    Chat(string.format(
        "Starting COMPACT v9 market scan: %s | start memory %.1f MB",
        tostring(guildName),
        self.scanStartMemoryMB or 0
    ))
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

    if not self:CheckScanMemory() then
        self:StopScan("MEMORY SAFETY STOP",false)
        return
    end

    if more then
        local cd=GetTradingHouseCooldownRemaining() or 0
        zo_callLater(function()
            if GMS.isScanning then GMS:RequestPage(page+1) end
        end,cd+150)
    else
        self:StopScan("SCAN COMPLETE",true)
    end
end

local function ExportEscape(s)
    s=tostring(s or "")
    s=string.gsub(s,"%%","%%25")
    s=string.gsub(s,"|","%%7C")
    s=string.gsub(s,";","%%3B")
    s=string.gsub(s,",","%%2C")
    s=string.gsub(s,"\n","%%0A")
    s=string.gsub(s,"\r","")
    return s
end

local function HashLink(link,seed)
    -- Deterministic compact key generated from the exact item link.
    -- Two independent 31-bit hashes are exported to make accidental
    -- collisions vanishingly unlikely while avoiding repeated full links.
    local h=seed or 5381
    for i=1,#link do
        h=(h*33+string.byte(link,i))%2147483647
    end
    return h
end

local function ExportLine(key,record)
    local name,flat=ParseRecord(record)
    local a=GMS:AnalyzeItem(record)
    if not a then return nil,0 end
    local p=string.find(record,"|",1,true)
    local snapshots=p and string.sub(record,p+1) or ""
    return table.concat({
        "I",key,Escape(name),
        tostring(a.p or 0),tostring(a.l or 0),tostring(a.h or 0),
        tostring(a.cf or 0),tostring(a.g or 0),tostring(a.o or 0),
        tostring(a.u or 0),snapshots
    },"|"), math.floor(#flat/9)
end

function GMS:BuildGuildExportHeader()
    local rows={}
    for guildId,value in pairs(self.saved.guildScans or {}) do
        rows[#rows+1]=tostring(guildId)..","..tostring(value)
    end
    return "G|"..table.concat(rows,";")
end

function GMS:SaveStreamChunk(done)
    local chunk=table.concat(self.streamExportLines or {},"\n")
    local previous=self.saved.export
    local chunkNumber=previous and previous.chunkNumber or 1

    self.saved.export={
        v=3,
        generated=previous and previous.generated or GetTimeStamp(),
        world=previous and previous.world or (GetWorldName and GetWorldName() or ""),
        chunkNumber=chunkNumber,
        chunk=chunk,
        lastKey=self.streamExportLastKey,
        done=done==true,
        totalItems=self.streamExportTotalItems,
        totalGuildRows=self.streamExportTotalGuildRows,
    }

    self.streamExportRunning=false
    self.streamExportLines=nil
    self.streamExportBytes=0
    if collectgarbage then collectgarbage("collect") end

    Chat(string.format(
        "EXPORT CHUNK %d READY: %d bytes | %d items / %d guild rows%s",
        chunkNumber,#chunk,self.streamExportTotalItems,self.streamExportTotalGuildRows,
        done and " | EXPORT COMPLETE" or ""
    ))
    self:MemoryReport("after streaming export chunk",false)
    if not done then Chat("Retrieve this chunk, then use /gmsnext.") end
end

function GMS:ProcessStreamExportBatch()
    if not self.streamExportRunning then return end
    local processed=0

    while processed<80 do
        local nextKey,record=next(self.saved.items,self.streamExportLastKey)
        if not nextKey then
            self:SaveStreamChunk(true)
            return
        end

        local line,guildRows=ExportLine(nextKey,record)
        self.streamExportLastKey=nextKey
        processed=processed+1

        if line then
            local extra=#line+1
            if self.streamExportBytes>0 and
               self.streamExportBytes+extra>self.streamExportTargetBytes then
                self:SaveStreamChunk(false)
                return
            end

            self.streamExportLines[#self.streamExportLines+1]=line
            self.streamExportBytes=self.streamExportBytes+extra
            self.streamExportTotalItems=self.streamExportTotalItems+1
            self.streamExportTotalGuildRows=self.streamExportTotalGuildRows+guildRows
        end
    end

    zo_callLater(function() GMS:ProcessStreamExportBatch() end,10)
end

function GMS:BuildExport()
    if self.streamExportRunning then
        Chat("Export chunk is already running.")
        return
    end

    self.saved.export=nil
    if collectgarbage then collectgarbage("collect") end

    self.streamExportRunning=true
    self.streamExportLastKey=nil
    self.streamExportLines={self:BuildGuildExportHeader()}
    self.streamExportBytes=#self.streamExportLines[1]+1
    self.streamExportTotalItems=0
    self.streamExportTotalGuildRows=0

    self.saved.export={
        v=3,generated=GetTimeStamp(),
        world=GetWorldName and GetWorldName() or "",
        chunkNumber=1,chunk="",lastKey=nil,done=false,
        totalItems=0,totalGuildRows=0
    }

    Chat("STREAM EXPORT START: one small chunk at a time.")
    self:ProcessStreamExportBatch()
end

function GMS:NextExportChunk()
    if self.streamExportRunning then
        Chat("Current export chunk is still running.")
        return
    end
    local old=self.saved.export
    if not old then Chat("No export session. Use /gmsexport.");return end
    if old.done then Chat("Export is already complete.");return end

    self.streamExportRunning=true
    self.streamExportLastKey=old.lastKey
    self.streamExportLines={}
    self.streamExportBytes=0
    self.streamExportTotalItems=old.totalItems or 0
    self.streamExportTotalGuildRows=old.totalGuildRows or 0

    self.saved.export={
        v=3,generated=old.generated,world=old.world,
        chunkNumber=(old.chunkNumber or 1)+1,
        chunk="",lastKey=old.lastKey,done=false,
        totalItems=self.streamExportTotalItems,
        totalGuildRows=self.streamExportTotalGuildRows
    }

    Chat("Generating export chunk "..tostring(self.saved.export.chunkNumber).."...")
    self:ProcessStreamExportBatch()
end

function GMS:ClearExport()
    self.streamExportRunning=false
    self.streamExportLastKey=nil
    self.streamExportLines=nil
    self.streamExportBytes=0
    self.saved.export=nil
    if collectgarbage then collectgarbage("collect") end
    Chat("Streaming export state cleared.")
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

local function UrlEncode(s)
    s=tostring(s or "")
    return (string.gsub(s,"([^%w%-%._~])",function(c)
        return string.format("%%%02X",string.byte(c))
    end))
end

function GMS:BuildSubmissionSample()
    -- Build a deliberately small REAL sample from the current GMS market DB.
    -- This is only to prove PS5 -> Worker -> KV using real scanner data.
    local lines={self:BuildGuildExportHeader()}
    local bytes=#lines[1]+1
    local items=0
    local guildRows=0

    for key,record in pairs(self.saved.items or {}) do
        local line,rows=ExportLine(key,record)
        if line then
            -- Keep the RAW sample small enough that percent-encoding still
            -- produces a conservative console-browser URL.
            if bytes+#line+1>650 then break end
            lines[#lines+1]=line
            bytes=bytes+#line+1
            items=items+1
            guildRows=guildRows+(rows or 0)
        end
    end

    return table.concat(lines,"\n"),items,guildRows
end

function GMS:SubmitRealDataTest()
    if type(RequestOpenUnsafeURL)~="function" then
        Chat("ERROR: RequestOpenUnsafeURL is not available on this client.")
        return
    end

    local payload,items,guildRows=self:BuildSubmissionSample()
    if not payload or payload=="" or items==0 then
        Chat("No market data available for submission test.")
        return
    end

    local world=GetWorldName and GetWorldName() or "unknown"
    local sid=tostring(GetTimeStamp()).."-"..tostring(self.saved.totalItems or 0)

    local url=
        "https://gma-data-receiver.lucie-gordon.workers.dev/submit"..
        "?sid="..UrlEncode(sid)..
        "&world="..UrlEncode(world)..
        "&part=1"..
        "&done=0"..
        "&items="..tostring(items)..
        "&rows="..tostring(guildRows)..
        "&data="..UrlEncode(payload)

    Chat(string.format(
        "Opening REAL GMA market submission test: %d items / %d guild rows.",
        items,guildRows
    ))
    Chat("This test sends a small real sample only, not the full database.")

    RequestOpenUnsafeURL(url)
end

local function Base36(n)
    n=math.floor(tonumber(n) or 0)
    if n==0 then return "0" end
    local chars="0123456789abcdefghijklmnopqrstuvwxyz"
    local out={}
    while n>0 do
        local r=(n%36)+1
        out[#out+1]=string.sub(chars,r,r)
        n=math.floor(n/36)
    end
    local rev={}
    for i=#out,1,-1 do rev[#rev+1]=out[i] end
    return table.concat(rev)
end

function GMS:BuildCloudGuildMap()
    local ids={}
    for guildId,_ in pairs(self.saved.guildScans or {}) do
        ids[#ids+1]=tostring(guildId)
    end
    table.sort(ids)

    local map={}
    local header={}
    for i=1,#ids do
        local gid=ids[i]
        map[tostring(gid)]=i

        local value=self.saved.guildScans[gid] or ""
        local ts=0
        -- stored form: escapedGuildName|timestamp|loaded
        local _,stamp=string.match(value,"^(.-)|([^|]+)|")
        ts=tonumber(stamp) or 0

        -- Header: index.guildId.timestamp
        header[#header+1]=
            Base36(i).."."..Base36(tonumber(gid) or 0).."."..Base36(ts)
    end

    return map,"h~"..table.concat(header,"_")
end

local B64="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

local function B64Num(n)
    n=math.floor(tonumber(n) or 0)
    if n<=0 then return "0" end
    local out={}
    while n>0 do
        local r=(n%62)+1
        out[#out+1]=string.sub(B64,r,r)
        n=math.floor(n/62)
    end
    local rev={}
    for i=#out,1,-1 do rev[#rev+1]=out[i] end
    return table.concat(rev)
end

local function ZigZag(n)
    n=math.floor(tonumber(n) or 0)
    if n>=0 then return n*2 end
    return (-n)*2-1
end

function GMS:CompactCloudItem(key,record,guildMap)
    local _,flat=ParseRecord(record)
    local guildCount=math.floor(#flat/9)

    if guildCount<(self.cloudExportMinGuilds or 3) then
        return nil,0
    end

    local h1,h2,ln=string.match(tostring(key),"^(%d+):(%d+):(%d+)$")
    local compactKey

    if h1 and h2 and ln then
        local mod=562949953421312
        local combined=
            ((tonumber(h1) or 0)*262144 + ((tonumber(h2) or 0)%262144))
        combined=(combined + (tonumber(ln) or 0)*131071)%mod
        compactKey=B64Num(combined)
    else
        compactKey=string.gsub(tostring(key),":",".")
    end

    local prices={}
    local totalSupply=0

    for i=1,#flat,9 do
        local count=tonumber(flat[i+1]) or 0
        local price=tonumber(flat[i+4]) or 0
        if price>0 then
            prices[#prices+1]=price
            totalSupply=totalSupply+count
        end
    end

    if #prices<(self.cloudExportMinGuilds or 3) then
        return nil,0
    end

    table.sort(prices)

    local low=prices[1]
    local high=prices[#prices]
    local mid
    if #prices%2==1 then
        mid=prices[math.floor(#prices/2)+1]
    else
        local a=prices[#prices/2]
        local b=prices[#prices/2+1]
        mid=math.floor((a+b)/2+0.5)
    end

    -- PRICE LAYER:
    -- itemId~guildConfidence.low.suggested.high.totalSupply
    -- One compact record regardless of whether the item was seen in
    -- 3 guilds or 30 guilds.
    local out=
        compactKey.."~"..
        B64Num(#prices).."."..
        B64Num(low).."."..
        B64Num(mid).."."..
        B64Num(high).."."..
        B64Num(totalSupply)

    return out,#prices
end

function GMS:GetPlayerGuildSet()
    local set={}
    local names={}
    local count=GetNumGuilds and GetNumGuilds() or 0

    for i=1,count do
        local guildId=GetGuildId and GetGuildId(i) or 0
        if guildId and guildId~=0 then
            local key=tostring(guildId)
            set[key]=true
            local name=GetGuildName and GetGuildName(guildId) or ""
            names[key]=name or ""
        end
    end

    return set,names
end

function GMS:BuildOpportunityGuildMap()
    local ids={}

    for guildId,_ in pairs(self.saved.guildScans or {}) do
        ids[#ids+1]=tostring(guildId)
    end

    table.sort(ids)

    local map={}
    local header={}

    for i=1,#ids do
        local gid=ids[i]
        map[gid]=i

        local scan=self.saved.guildScans[gid] or ""
        local _,stamp=string.match(scan,"^(.-)|([^|]+)|")
        local ts=tonumber(stamp) or 0

        -- index.guildId.scanTimestamp
        header[#header+1]=
            B64Num(i).."."..
            B64Num(tonumber(gid) or 0).."."..
            B64Num(ts)
    end

    return map,"o~"..table.concat(header,"_"),#ids
end

function GMS:CompactOpportunityItem(key,record,guildMap)
    local _,flat=ParseRecord(record)
    if #flat==0 then return nil,0 end

    local h1,h2,ln=string.match(tostring(key),"^(%d+):(%d+):(%d+)$")
    local compactKey

    if h1 and h2 and ln then
        local mod=562949953421312
        local combined=
            ((tonumber(h1) or 0)*262144 + ((tonumber(h2) or 0)%262144))
        combined=(combined + (tonumber(ln) or 0)*131071)%mod
        compactKey=B64Num(combined)
    else
        compactKey=string.gsub(tostring(key),":",".")
    end

    local rows={}
    for i=1,#flat,9 do
        local gid=tostring(flat[i])
        local idx=guildMap[gid]
        if idx then
            local count=tonumber(flat[i+1]) or 0
            local price=tonumber(flat[i+4]) or 0
            if price>0 then
                rows[#rows+1]={
                    idx=idx,
                    count=math.min(count,4095),
                    price=price,
                }
            end
        end
    end

    if #rows==0 then return nil,0 end
    table.sort(rows,function(a,b) return a.idx<b.idx end)

    -- OPPORTUNITY record:
    -- itemId~guildIndex.count.price[_guildIndex.count.price...]
    -- Only the player's scanned selling guilds are included.
    local pieces={compactKey,"~"}
    for i=1,#rows do
        local r=rows[i]
        if i>1 then pieces[#pieces+1]="_" end
        pieces[#pieces+1]=B64Num(r.idx)
        pieces[#pieces+1]="."
        pieces[#pieces+1]=B64Num(r.count)
        pieces[#pieces+1]="."
        pieces[#pieces+1]=B64Num(r.price)
    end

    return table.concat(pieces),#rows
end

function GMS:StartOpportunityExport()
    if type(RequestOpenUnsafeURL)~="function" then
        Chat("ERROR: RequestOpenUnsafeURL is not available on this client.")
        return
    end

    self.cloudOpportunityMode=true
    self.cloudExportRunning=true
    self.cloudExportSid=
        "opp-"..tostring(GetTimeStamp()).."-"..
        tostring(self.saved.totalItems or 0)
    self.cloudExportLastKey=nil
    self.cloudExportPart=0
    self.cloudExportTotalItems=0
    self.cloudExportTotalGuildRows=0

    self.cloudExportGuildMap,
    self.cloudExportGuildHeader,
    self.cloudOpportunityGuildCount=
        self:BuildOpportunityGuildMap()

    if (self.cloudOpportunityGuildCount or 0)==0 then
        Chat("GMA GUILD SUPPLY: no scanned guild data is available.")
        self:ResetCloudExport()
        return
    end

    Chat(string.format(
        "GMA GUILD SUPPLY START: %d scanned guilds will be exported.",
        self.cloudOpportunityGuildCount or 0
    ))
    Chat("Use /gmsoppnext to send Part 1.")
end

function GMS:BuildNextOpportunityChunk()
    if not self.cloudExportRunning or not self.cloudOpportunityMode then
        return nil
    end

    local records={}
    local bytes=0
    local chunkItems=0
    local chunkRows=0
    local key=self.cloudExportLastKey
    local done=false

    if self.cloudExportPart==0 then
        local header=self.cloudExportGuildHeader or "o~"
        records[#records+1]=header
        bytes=#header
    end

    while true do
        local nextKey,record=next(self.saved.items,key)
        if not nextKey then
            done=true
            break
        end

        local compact,rows=
            self:CompactOpportunityItem(
                nextKey,
                record,
                self.cloudExportGuildMap or {}
            )

        if compact then
            local extra=#compact+1
            if chunkItems>0 and
               bytes+extra>self.cloudExportChunkTargetBytes then
                break
            end

            records[#records+1]=compact
            bytes=bytes+extra
            chunkItems=chunkItems+1
            chunkRows=chunkRows+(rows or 0)
        end

        key=nextKey
        self.cloudExportLastKey=nextKey
    end

    return {
        data=table.concat(records,"-"),
        items=chunkItems,
        rows=chunkRows,
        done=done,
        bytes=bytes,
    }
end

function GMS:SendNextOpportunityPart()
    if not self.cloudExportRunning or not self.cloudOpportunityMode then
        Chat("No Guild Opportunity export. Use /gmsoppstart first.")
        return
    end

    local chunk=self:BuildNextOpportunityChunk()
    if not chunk or not chunk.data or chunk.data=="" then
        Chat("Guild Opportunity export has no data to send.")
        self:ResetCloudExport()
        return
    end

    self.cloudExportPart=self.cloudExportPart+1
    self.cloudExportTotalItems=
        self.cloudExportTotalItems+(chunk.items or 0)
    self.cloudExportTotalGuildRows=
        self.cloudExportTotalGuildRows+(chunk.rows or 0)

    local world=GetWorldName and GetWorldName() or "unknown"

    local url=
        "https://gma-data-receiver.lucie-gordon.workers.dev/submit"..
        "?v=4"..
        "&layer=supply"..
        "&sid="..UrlEncode(self.cloudExportSid)..
        "&world="..UrlEncode(world)..
        "&part="..tostring(self.cloudExportPart)..
        "&done="..(chunk.done and "1" or "0")..
        "&items="..tostring(chunk.items or 0)..
        "&rows="..tostring(chunk.rows or 0)..
        "&cumItems="..tostring(self.cloudExportTotalItems)..
        "&cumRows="..tostring(self.cloudExportTotalGuildRows)..
        "&data="..chunk.data

    Chat(string.format(
        "Opening GMA GUILD SUPPLY Part %d: %d items / %d guild rows / ~%d chars.",
        self.cloudExportPart,
        chunk.items or 0,
        chunk.rows or 0,
        chunk.bytes or 0
    ))

    RequestOpenUnsafeURL(url)

    if chunk.done then
        self.cloudExportRunning=false
        self.cloudOpportunityMode=false
    end
end

function GMS:ResetCloudExport()
    self.cloudExportRunning=false
    self.cloudExportSid=nil
    self.cloudExportLastKey=nil
    self.cloudExportPart=0
    self.cloudExportTotalItems=0
    self.cloudExportTotalGuildRows=0
    self.cloudExportGuildMap=nil
    self.cloudExportGuildHeader=nil
    self.cloudOpportunityMode=false
    self.cloudOpportunityGuildCount=0
    Chat("Cloud export session reset.")
end

function GMS:CountCloudEligibleItems()
    local eligible=0
    local rows=0
    local minGuilds=self.cloudExportMinGuilds or 3
    for _,record in pairs(self.saved.items or {}) do
        local count=SnapshotCount(record)
        if count>=minGuilds then
            eligible=eligible+1
            rows=rows+count
        end
    end
    return eligible,rows
end

function GMS:StartCloudExport()
    self.cloudOpportunityMode=false
    if type(RequestOpenUnsafeURL)~="function" then
        Chat("ERROR: RequestOpenUnsafeURL is not available on this client.")
        return
    end

    self.cloudExportRunning=true
    self.cloudExportSid=
        tostring(GetTimeStamp()).."-"..
        tostring(self.saved.totalItems or 0).."-"..
        tostring(self:GuildScanCount())
    self.cloudExportLastKey=nil
    self.cloudExportPart=0
    self.cloudExportTotalItems=0
    self.cloudExportTotalGuildRows=0
    self.cloudExportGuildMap,self.cloudExportGuildHeader=
        self:BuildCloudGuildMap()

    local eligible,eligibleRows=self:CountCloudEligibleItems()
    Chat(string.format(
        "GMA PRICE DATA: %d/%d items eligible (>= %d guilds) / %d source guild rows.",
        eligible,
        self.saved.totalItems or 0,
        self.cloudExportMinGuilds or 3,
        eligibleRows
    ))
    Chat("Use /gmscloudnext to send Part 1.")
end

function GMS:BuildNextCloudChunk()
    if not self.cloudExportRunning or not self.cloudExportSid then
        return nil,nil
    end

    local records={}
    local bytes=0
    local chunkItems=0
    local sourceGuildRows=0
    local key=self.cloudExportLastKey
    local done=false

    while true do
        local nextKey,record=next(self.saved.items,key)
        if not nextKey then
            done=true
            break
        end

        local compact,rows=
            self:CompactCloudItem(
                nextKey,
                record,
                self.cloudExportGuildMap or {}
            )

        if compact then
            local extra=#compact+1
            if chunkItems>0 and
               bytes+extra>self.cloudExportChunkTargetBytes then
                break
            end

            records[#records+1]=compact
            bytes=bytes+extra
            chunkItems=chunkItems+1
            sourceGuildRows=sourceGuildRows+(rows or 0)
        end

        key=nextKey
        self.cloudExportLastKey=nextKey
    end

    if #records==0 then done=true end

    return {
        data=table.concat(records,"-"),
        items=chunkItems,
        rows=sourceGuildRows,
        done=done,
        lastKey=self.cloudExportLastKey,
        bytes=bytes,
    }
end

function GMS:SendNextCloudPart()
    if not self.cloudExportRunning then
        Chat("No cloud export session. Use /gmscloudstart first.")
        return
    end

    local chunk=self:BuildNextCloudChunk()
    if not chunk or not chunk.data or chunk.data=="" then
        Chat("Cloud export has no data to send.")
        self:ResetCloudExport()
        return
    end

    self.cloudExportPart=self.cloudExportPart+1
    self.cloudExportTotalItems=
        self.cloudExportTotalItems+(chunk.items or 0)
    self.cloudExportTotalGuildRows=
        self.cloudExportTotalGuildRows+(chunk.rows or 0)

    local world=GetWorldName and GetWorldName() or "unknown"

    local url=
        "https://gma-data-receiver.lucie-gordon.workers.dev/submit"..
        "?v=4"..
        "&layer=price"..
        "&sid="..UrlEncode(self.cloudExportSid)..
        "&world="..UrlEncode(world)..
        "&part="..tostring(self.cloudExportPart)..
        "&done="..(chunk.done and "1" or "0")..
        "&items="..tostring(chunk.items or 0)..
        "&rows="..tostring(chunk.rows or 0)..
        "&cumItems="..tostring(self.cloudExportTotalItems)..
        "&cumRows="..tostring(self.cloudExportTotalGuildRows)..
        "&data="..chunk.data

    Chat(string.format(
        "Opening GMA PRICE Part %d: %d items / %d source guild rows / ~%d payload chars.",
        self.cloudExportPart,
        chunk.items or 0,
        chunk.rows or 0,
        chunk.bytes or 0
    ))

    if chunk.done then
        Chat("This is the FINAL cloud export part.")
    else
        Chat("After confirmation, return to ESO and use /gmscloudnext.")
    end

    RequestOpenUnsafeURL(url)

    if chunk.done then
        self.cloudExportRunning=false
    end
end

function GMS:TestSubmissionURL()
    local world = GetWorldName and GetWorldName() or "unknown"
    local token = tostring(GetTimeStamp()) .. "-" .. tostring(self.saved.totalItems or 0)

    local url =
        "https://gma-data-receiver.lucie-gordon.workers.dev/" ..
        "?gma_test=1" ..
        "&world=" .. tostring(world) ..
        "&token=" .. tostring(token)

    Chat("Opening GMA submission connectivity test...")
    Chat("No market data is being sent in this test.")

    if type(RequestOpenUnsafeURL) == "function" then
        RequestOpenUnsafeURL(url)
    else
        Chat("ERROR: RequestOpenUnsafeURL is not available on this client.")
    end
end

local function Clamp(v,lo,hi)
    if v<lo then return lo end
    if v>hi then return hi end
    return v
end

function GMS:FinalShortItemId(key)
    local h1,h2,ln=string.match(tostring(key),"^(%d+):(%d+):(%d+)$")
    if h1 and h2 and ln then
        local mod=562949953421312
        local combined=
            ((tonumber(h1) or 0)*262144 + ((tonumber(h2) or 0)%262144))
        combined=(combined + (tonumber(ln) or 0)*131071)%mod
        return B64Num(combined)
    end
    return string.gsub(tostring(key),":",".")
end

function GMS:BuildFinalPriceRecord(key,record)
    local a=self:AnalyzeItem(record)
    if not a or (a.g or 0)<3 then return nil end

    local suggested=Clamp(math.floor(a.p or 0),0,67108863)
    if suggested<=0 then return nil end

    -- Range is represented as percentage deviation from suggested.
    -- AnalyzeItem already rejects extreme guild outliers before l/h.
    local lowDev=Clamp(
        math.floor(((suggested-(a.l or suggested))/suggested)*100+0.5),
        0,63
    )
    local highDev=Clamp(
        math.floor((((a.h or suggested)-suggested)/suggested)*100+0.5),
        0,63
    )
    local confidence=Clamp(tonumber(a.cf) or 0,0,3)

    -- Pack into < 2^40:
    -- 26 bits suggested, 6 bits low%, 6 bits high%, 2 bits confidence.
    local packed=
        (((suggested*64 + lowDev)*64 + highDev)*4 + confidence)

    return self:FinalShortItemId(key).."~"..B64Num(packed)
end

function GMS:BuildFinalOpportunityRecord(key,record,guildMap)
    local a=self:AnalyzeItem(record)
    if not a or (a.g or 0)<3 or not a.p or a.p<=0 then
        return nil,0
    end

    local _,flat=ParseRecord(record)
    if #flat==0 then return nil,0 end

    local supplies={}
    local candidates={}

    for i=1,#flat,9 do
        local gid=tostring(flat[i])
        local idx=guildMap[gid]
        local count=tonumber(flat[i+1]) or 0
        local price=tonumber(flat[i+4]) or 0

        if idx and price>0 then
            supplies[#supplies+1]=count

            -- Never recommend a materially underpriced guild.
            if price >= (a.l or a.p) then
                candidates[#candidates+1]={
                    idx=idx,
                    count=count,
                    price=price
                }
            end
        end
    end

    if #supplies<3 or #candidates==0 then return nil,0 end
    table.sort(supplies)
    local medianSupply=Median(supplies) or 0

    -- A recommendation should represent a real scarcity advantage.
    -- It is enough to be notably below the item's typical guild supply.
    local scarcityLimit=math.max(2,math.floor(medianSupply*0.70+0.5))

    local strong={}
    for i=1,#candidates do
        local c=candidates[i]
        if c.count<=scarcityLimit then
            strong[#strong+1]=c
        end
    end

    if #strong==0 then return nil,0 end

    table.sort(strong,function(x,y)
        if x.count~=y.count then return x.count<y.count end
        return x.price>y.price
    end)

    -- Top 3 strong guild opportunities are enough to power:
    -- Best Guild to Sell + guild->item Suggestions when inverted server-side.
    local take=math.min(3,#strong)
    local pieces={self:FinalShortItemId(key),"~"}

    for i=1,take do
        local c=strong[i]
        if i>1 then pieces[#pieces+1]="_" end
        pieces[#pieces+1]=B64Num(c.idx)
        pieces[#pieces+1]="."
        pieces[#pieces+1]=B64Num(math.min(c.count,4095))
        pieces[#pieces+1]="."
        pieces[#pieces+1]=B64Num(c.price)
    end

    return table.concat(pieces),take
end

function GMS:MeasureFinalExport()
    local guildMap,_,guildCount=self:BuildOpportunityGuildMap()

    local priceItems=0
    local priceBytes=0
    local oppItems=0
    local oppRows=0
    local oppBytes=0
    local scanned=0

    Chat("FINAL EXPORT MEASURE STARTED. This does not upload anything.")

    for key,record in pairs(self.saved.items or {}) do
        scanned=scanned+1

        local p=self:BuildFinalPriceRecord(key,record)
        if p then
            priceItems=priceItems+1
            priceBytes=priceBytes+#p+1
        end

        local o,rows=self:BuildFinalOpportunityRecord(key,record,guildMap)
        if o then
            oppItems=oppItems+1
            oppRows=oppRows+(rows or 0)
            oppBytes=oppBytes+#o+1
        end
    end

    local target=4000
    local pricePages=math.max(1,math.ceil(priceBytes/target))
    local oppPages=math.max(1,math.ceil(oppBytes/target))
    local totalPages=pricePages+oppPages

    Chat(string.format(
        "FINAL PRICE: %d items / ~%d chars / ~%d safe 4K pages.",
        priceItems,priceBytes,pricePages
    ))
    Chat(string.format(
        "FINAL OPPORTUNITY: %d items / %d recommended guild rows / ~%d chars / ~%d safe 4K pages.",
        oppItems,oppRows,oppBytes,oppPages
    ))
    Chat(string.format(
        "FINAL WEEKLY ESTIMATE NOW: ~%d browser confirmations for %d scanned guilds / %d DB items.",
        totalPages,guildCount or 0,scanned
    ))
    Chat("Nothing was uploaded. Existing Price/Supply exports are unchanged.")
end


function GMS:PrintSnapshotByName(query)
    query=string.lower(query or "")
    if query=="" then
        Chat("Usage: /gmssnapshot item name")
        return
    end

    for key,record in pairs(self.saved.items or {}) do
        local name=RecordName(record)

        if string.find(string.lower(name or ""),query,1,true) then
            local _,flat=ParseRecord(record)

            Chat(string.format(
                "SNAPSHOT %s | %d guild rows",
                tostring(name),
                math.floor(#flat/9)
            ))

            local shown=0
            for i=1,#flat,9 do
                Chat(string.format(
                    "Guild %s | listings %d | units %d | trusted %d-%d-%d | observed %d-%d | updated %d",
                    tostring(flat[i] or 0),
                    tonumber(flat[i+1]) or 0,
                    tonumber(flat[i+2]) or 0,
                    tonumber(flat[i+3]) or 0,
                    tonumber(flat[i+4]) or 0,
                    tonumber(flat[i+5]) or 0,
                    tonumber(flat[i+6]) or 0,
                    tonumber(flat[i+7]) or 0,
                    tonumber(flat[i+8]) or 0
                ))
                shown=shown+1
                if shown>=5 then break end
            end

            return
        end
    end

    Chat("No stored item matched: "..tostring(query))
end

function GMS:FindAllMatchingRecords(query)
    query=string.lower(query or "")
    if query=="" then
        Chat("Usage: /gmsfind item name")
        return
    end

    local matches={}

    for key,record in pairs(self.saved.items or {}) do
        local name=RecordName(record)
        if string.find(string.lower(name or ""),query,1,true) then
            local _,flat=ParseRecord(record)
            matches[#matches+1]={
                key=key,
                name=name,
                rows=math.floor(#flat/9),
                flat=flat
            }
        end
    end

    table.sort(matches,function(a,b)
        if a.name~=b.name then return tostring(a.name)<tostring(b.name) end
        return tostring(a.key)<tostring(b.key)
    end)

    Chat(string.format(
        "IDENTITY FIND '%s': %d separate DB record(s).",
        tostring(query),
        #matches
    ))

    if #matches==0 then return end

    local maxRecords=10
    for r=1,math.min(#matches,maxRecords) do
        local m=matches[r]

        Chat(string.format(
            "#%d %s | key %s | %d guild rows",
            r,
            tostring(m.name),
            tostring(m.key),
            m.rows
        ))

        local shown=0
        for i=1,#m.flat,9 do
            Chat(string.format(
                "  guild %s | listings %d | units %d | trusted %d-%d-%d | observed %d-%d",
                tostring(m.flat[i] or 0),
                tonumber(m.flat[i+1]) or 0,
                tonumber(m.flat[i+2]) or 0,
                tonumber(m.flat[i+3]) or 0,
                tonumber(m.flat[i+4]) or 0,
                tonumber(m.flat[i+5]) or 0,
                tonumber(m.flat[i+6]) or 0,
                tonumber(m.flat[i+7]) or 0
            ))
            shown=shown+1
            if shown>=5 then break end
        end
    end

    if #matches>maxRecords then
        Chat(string.format(
            "... %d additional matching DB records not printed.",
            #matches-maxRecords
        ))
    end
end



local function MeasurePages(chars)
    if not chars or chars<=0 then return 0 end
    return math.ceil(chars/4000)
end

local function ClampInt(v,lo,hi)
    v=math.floor((tonumber(v) or 0)+0.5)
    if v<lo then return lo end
    if v>hi then return hi end
    return v
end

local function GetGuildSnapshotV10(flat,guildId)
    for i=1,#flat,9 do
        if tostring(flat[i])==tostring(guildId) then
            return {
                listings=tonumber(flat[i+1]) or 0,
                units=tonumber(flat[i+2]) or 0,
                trustedLow=tonumber(flat[i+3]) or 0,
                trustedMedian=tonumber(flat[i+4]) or 0,
                trustedHigh=tonumber(flat[i+5]) or 0,
                observedMin=tonumber(flat[i+6]) or 0,
                observedMax=tonumber(flat[i+7]) or 0,
                updated=tonumber(flat[i+8]) or 0
            }
        end
    end
    return nil
end

function GMS:BuildDenseMeasuredPriceRecord(key,record)
    local a=self:AnalyzeItem(record)
    if not a or (a.g or 0)<3 or not a.p or a.p<=0 then
        return nil
    end

    local p=ClampInt(a.p,0,67108863)
    if p<=0 then return nil end

    -- Trusted range stored as % deviation from recommendation.
    local lowPct=ClampInt(((p-(a.l or p))/p)*100,0,63)
    local highPct=ClampInt((((a.h or p)-p)/p)*100,0,63)
    local conf=ClampInt(a.cf or 0,0,3)

    -- 40-bit exact integer:
    -- 26-bit price + 6-bit low% + 6-bit high% + 2-bit confidence
    local packA=(((p*64+lowPct)*64+highPct)*4+conf)

    -- Observed min/max deviations get a separate compact pack.
    -- 0..255% is plenty for display; larger extremes clamp at 255%.
    local obsLowPct=ClampInt(((p-(a.mn or p))/p)*100,0,255)
    local obsHighPct=ClampInt((((a.mx or p)-p)/p)*100,0,255)

    local packB=obsLowPct*256+obsHighPct

    return self:FinalShortItemId(key).."~"..
        B64Num(packA).."."..B64Num(packB)
end

local function InsertTopCandidate(list,candidate,maxKeep)
    list[#list+1]=candidate
    table.sort(list,function(x,y)
        if x.score~=y.score then return x.score>y.score end
        return tostring(x.key)<tostring(y.key)
    end)
    if #list>maxKeep then
        table.remove(list)
    end
end

function GMS:ScoreOpportunityForGuild(key,a,flat,guildId)
    local snap=GetGuildSnapshotV10(flat,guildId)

    local listings=0
    local units=0
    local localLow=0
    local localMedian=0
    local localHigh=0
    local absent=false

    if snap then
        listings=snap.listings or 0
        units=snap.units or 0
        localLow=snap.trustedLow or 0
        localMedian=snap.trustedMedian or 0
        localHigh=snap.trustedHigh or 0
    else
        absent=true
    end

    local relevance=
        math.min(45,(a.g or 0)*6)+
        math.min(25,(a.cf or 0)*8)+
        math.min(30,math.floor(math.log(math.max(2,a.p or 1))*4))

    local scarcity
    if absent then
        scarcity=100
    else
        local listingPenalty=math.min(70,listings*7)
        local unitPenalty=math.min(30,math.floor(units/25))
        scarcity=100-listingPenalty-unitPenalty
    end

    local priceSafety=20
    if localMedian>0 and (a.l or a.p)>0 then
        if localMedian < (a.l or a.p)*0.70 then
            priceSafety=-80
        elseif localMedian > (a.h or a.p)*1.60 then
            priceSafety=-20
        end
    end

    local score=relevance+scarcity+priceSafety
    if score<=80 then return nil end

    return {
        key=key,
        score=score,
        listings=listings,
        units=units,
        localLow=localLow,
        localMedian=localMedian,
        localHigh=localHigh,
        absent=absent
    }
end

function GMS:MeasureOpportunityChars(list,cap)
    local chars=0
    local take=math.min(cap,#list)

    for i=1,take do
        local c=list[i]

        -- Dense opportunity record:
        -- itemId~listings.units.localMedian
        -- We intentionally do NOT repeat full low/high here.
        -- The opportunity list only needs scarcity + a sane local reference price.
        local rec=
            self:FinalShortItemId(c.key).."~"..
            B64Num(c.listings or 0).."."..
            B64Num(c.units or 0).."."..
            B64Num(c.localMedian or 0)

        chars=chars+#rec+1
    end

    return chars,take
end

function GMS:FinishAsyncTransportMeasure()
    local s=self.transportMeasure
    if not s then return end

    local pricePages=MeasurePages(s.priceChars)

    Chat(string.format(
        "DENSE GLOBAL PRICE: %d items / ~%d chars / ~%d safe 4K pages.",
        s.priceItems,s.priceChars,pricePages
    ))

    local dictKnownPages=MeasurePages(s.dictKnownChars)
    local dictBootstrapPages=MeasurePages(s.dictBootstrapChars)

    Chat(string.format(
        "DICT WEEKLY PRICE: %d items / ~%d chars / ~%d safe 4K pages.",
        s.priceItems,s.dictKnownChars,dictKnownPages
    ))

    Chat(string.format(
        "DICT FIRST-TIME/ALL-NEW: ~%d chars / ~%d safe 4K pages.",
        s.dictBootstrapChars,dictBootstrapPages
    ))

    local caps={25,50,100}

    for ci=1,#caps do
        local cap=caps[ci]
        local oppChars=0
        local oppRows=0

        for gi=1,#s.guildIds do
            local guildId=s.guildIds[gi]
            local list=s.topByGuild[guildId] or {}

            -- compact guild header
            oppChars=oppChars+#B64Num(tonumber(guildId) or 0)+2

            local c,r=self:MeasureOpportunityChars(list,cap)
            oppChars=oppChars+c
            oppRows=oppRows+r
        end

        local oppPages=MeasurePages(oppChars)
        local totalNow=pricePages+oppPages

        local avgGuildChars=0
        if #s.guildIds>0 then
            avgGuildChars=oppChars/#s.guildIds
        end

        local projectedOppPages50=MeasurePages(avgGuildChars*50)
        local projectedTotal50=pricePages+projectedOppPages50

        Chat(string.format(
            "TOP %d/GUILD NOW: %d rows / ~%d chars / ~%d opp pages / ~%d TOTAL.",
            cap,oppRows,oppChars,oppPages,totalNow
        ))

        Chat(string.format(
            "TOP %d/GUILD -> 50 GUILDS: ~%d opp pages + %d price pages = ~%d confirmations.",
            cap,projectedOppPages50,pricePages,projectedTotal50
        ))

        Chat(string.format(
            "DICT TOP %d -> 50 GUILDS: ~%d opp + %d dict price = ~%d confirmations.",
            cap,projectedOppPages50,dictKnownPages,
            projectedOppPages50+dictKnownPages
        ))
    end

    Chat("TARGET: about 5-10 confirmations total at ~50 guilds.")
    Chat("Measurement complete. Nothing was uploaded or changed.")

    self.transportMeasure=nil

    if collectgarbage then
        collectgarbage("collect")
    end
end

function GMS:ProcessAsyncTransportBatch()
    local s=self.transportMeasure
    if not s then return end

    local batchSize=120
    local stopAt=math.min(s.index+batchSize-1,#s.keys)

    for n=s.index,stopAt do
        local key=s.keys[n]
        local record=self.saved.items[key]

        if record then
            local a=self:AnalyzeItem(record)

            if a and (a.g or 0)>=3 and (a.p or 0)>0 then
                local priceRec=self:BuildDenseMeasuredPriceRecord(key,record)

                if priceRec then
                    s.priceChars=s.priceChars+#priceRec+1
                    s.priceItems=s.priceItems+1

                    -- Persistent Cloudflare dictionary measurement:
                    -- normal weekly update sends only compact dictionary index
                    -- plus the two packed price integers.
                    local sep=string.find(priceRec,"~",1,true)
                    local packed=sep and string.sub(priceRec,sep+1) or ""
                    local idx=B64Num(s.nextDictIndex)

                    s.dictKnownChars=s.dictKnownChars+
                        #idx+1+#packed+1

                    -- One-time bootstrap/new-item cost additionally carries
                    -- the short scanner item identity so Cloudflare can bind
                    -- the permanent index.
                    local shortId=self:FinalShortItemId(key)
                    s.dictBootstrapChars=s.dictBootstrapChars+
                        #idx+1+#shortId+1+#packed+1

                    s.nextDictIndex=s.nextDictIndex+1
                end

                local _,flat=ParseRecord(record)

                for gi=1,#s.guildIds do
                    local guildId=s.guildIds[gi]
                    local c=self:ScoreOpportunityForGuild(
                        key,a,flat,guildId
                    )

                    if c then
                        InsertTopCandidate(
                            s.topByGuild[guildId],
                            c,
                            100
                        )
                    end
                end
            end
        end
    end

    s.index=stopAt+1

    if s.index>#s.keys then
        self:FinishAsyncTransportMeasure()
        return
    end

    if (s.index%960)<120 then
        Chat(string.format(
            "Transport measure progress: %d/%d items...",
            math.min(s.index-1,#s.keys),
            #s.keys
        ))
    end

    zo_callLater(function()
        GMS:ProcessAsyncTransportBatch()
    end,25)
end

function GMS:MeasureFinalWeeklyTransportAsync()
    if self.transportMeasure then
        Chat("Transport measurement already running.")
        return
    end

    local guildIds={}
    for guildId,_ in pairs(self.saved.guildScans or {}) do
        guildIds[#guildIds+1]=tostring(guildId)
    end
    table.sort(guildIds)

    local keys={}
    for key,_ in pairs(self.saved.items or {}) do
        keys[#keys+1]=key
    end

    local topByGuild={}
    for i=1,#guildIds do
        topByGuild[guildIds[i]]={}
    end

    self.transportMeasure={
        keys=keys,
        index=1,
        guildIds=guildIds,
        topByGuild=topByGuild,
        priceChars=0,
        priceItems=0,
        dictKnownChars=0,
        dictBootstrapChars=0,
        nextDictIndex=1
    }

    Chat(string.format(
        "ASYNC DENSE TRANSPORT MEASURE STARTED: %d DB items / %d registered guilds.",
        #keys,#guildIds
    ))
    Chat("Nothing will be uploaded or changed. Processing in small frame-safe batches.")

    zo_callLater(function()
        GMS:ProcessAsyncTransportBatch()
    end,25)
end


GMS.weeklyChunkTargetBytes = 3900
GMS.weeklyOpportunityCap = 25
GMS.weeklyBuildBatchSize = 100

local function WeeklyPages(chars)
    if not chars or chars<=0 then return 0 end
    return math.ceil(chars/(GMS.weeklyChunkTargetBytes or 3900))
end

local function WeeklyGetGuildSnapshot(flat,guildId)
    for i=1,#flat,9 do
        if tostring(flat[i])==tostring(guildId) then
            return {
                listings=tonumber(flat[i+1]) or 0,
                units=tonumber(flat[i+2]) or 0,
                trustedLow=tonumber(flat[i+3]) or 0,
                trustedMedian=tonumber(flat[i+4]) or 0,
                trustedHigh=tonumber(flat[i+5]) or 0,
                observedMin=tonumber(flat[i+6]) or 0,
                observedMax=tonumber(flat[i+7]) or 0,
                updated=tonumber(flat[i+8]) or 0
            }
        end
    end
    return nil
end

function GMS:WeeklyBuildPricePacked(key,record)
    local a=self:AnalyzeItem(record)
    if not a or (a.g or 0)<3 or not a.p or a.p<=0 then
        return nil,nil
    end

    local p=math.floor((a.p or 0)+0.5)
    if p<=0 then return nil,nil end

    local function Clamp(v,lo,hi)
        v=math.floor((tonumber(v) or 0)+0.5)
        if v<lo then return lo end
        if v>hi then return hi end
        return v
    end

    local lowPct=Clamp(((p-(a.l or p))/p)*100,0,63)
    local highPct=Clamp((((a.h or p)-p)/p)*100,0,63)
    local conf=Clamp(a.cf or 0,0,3)

    local packA=(((p*64+lowPct)*64+highPct)*4+conf)

    local obsLowPct=Clamp(((p-(a.mn or p))/p)*100,0,255)
    local obsHighPct=Clamp((((a.mx or p)-p)/p)*100,0,255)
    local packB=obsLowPct*256+obsHighPct

    return B64Num(packA).."."..B64Num(packB),a
end

function GMS:WeeklyScoreOpportunity(key,a,flat,guildId)
    local snap=WeeklyGetGuildSnapshot(flat,guildId)

    local listings=0
    local units=0
    local localMedian=0
    local absent=false

    if snap then
        listings=snap.listings or 0
        units=snap.units or 0
        localMedian=snap.trustedMedian or 0
    else
        absent=true
    end

    local relevance=
        math.min(45,(a.g or 0)*6)+
        math.min(25,(a.cf or 0)*8)+
        math.min(30,math.floor(math.log(math.max(2,a.p or 1))*4))

    local scarcity
    if absent then
        scarcity=100
    else
        local listingPenalty=math.min(70,listings*7)
        local unitPenalty=math.min(30,math.floor(units/25))
        scarcity=100-listingPenalty-unitPenalty
    end

    local priceSafety=20
    if localMedian>0 and (a.l or a.p)>0 then
        if localMedian < (a.l or a.p)*0.70 then
            priceSafety=-80
        elseif localMedian > (a.h or a.p)*1.60 then
            priceSafety=-20
        end
    end

    local score=relevance+scarcity+priceSafety
    if score<=80 then return nil end

    return {
        key=key,
        score=score,
        listings=listings,
        units=units,
        localMedian=localMedian,
        absent=absent
    }
end

local function WeeklyInsertTop(list,candidate,maxKeep)
    local n=#list

    if n<maxKeep then
        list[n+1]=candidate
        return
    end

    -- Keep the Top-N unsorted while scanning. Finding the current worst
    -- among 25 entries is cheaper and more predictable than sorting on
    -- every qualifying item/guild comparison.
    local worstIndex=1
    local worst=list[1]

    for i=2,n do
        local v=list[i]
        if v.score<worst.score or
           (v.score==worst.score and tostring(v.key)>tostring(worst.key)) then
            worst=v
            worstIndex=i
        end
    end

    if candidate.score>worst.score or
       (candidate.score==worst.score and tostring(candidate.key)<tostring(worst.key)) then
        list[worstIndex]=candidate
    end
end



-- ============================================================================
-- v0.7.0 INCREMENTAL MARKET SYNC
-- ============================================================================
--
-- GMS is a collector. D1 is the persistent market.
--
-- A completed trader scan marks only that guild as pending.
-- /gmssync snapshots the pending guild list.
-- /gmssyncnext generates ONE bounded unified browser page at a time.
--
-- A page can contain:
--   P<item>~<price-pack>          global price update
--   G~<guild-index>               opportunity guild header
--   O<item>~<listings>.<units>.<localMedian>
--
-- The Worker stages every page. The current market is changed only when the
-- final page succeeds. At finalize:
--   * price rows in this sync are UPSERTED; other market prices stay untouched
--   * opportunity rows are REPLACED only for the guilds in this sync
--   * every other guild remains untouched
--
-- This is intentionally not a "whole market replacement".
-- ============================================================================

GMS.syncChunkTargetBytes = 6000
GMS.syncOpportunityCap = 25

local function SyncCandidateBetter(a,b)
    if not b then return true end
    if a.score~=b.score then return a.score>b.score end
    return tostring(a.key)<tostring(b.key)
end

local function SyncCandidateWorse(a,b)
    if not b then return true end
    if a.score~=b.score then return a.score<b.score end
    return tostring(a.key)>tostring(b.key)
end

local function SyncKeepTop(list,candidate,cap)
    local n=#list
    if n<cap then
        list[n+1]=candidate
        return
    end

    local worstIndex=1
    local worst=list[1]

    for i=2,n do
        local v=list[i]
        if SyncCandidateWorse(v,worst) then
            worst=v
            worstIndex=i
        end
    end

    if SyncCandidateBetter(candidate,worst) then
        list[worstIndex]=candidate
    end
end

local function ParseGuildScanMeta(value)
    value=tostring(value or "")
    local p1=string.find(value,"|",1,true)
    if not p1 then return Unescape(value),0,0 end
    local p2=string.find(value,"|",p1+1,true)

    if not p2 then
        return Unescape(string.sub(value,1,p1-1)),
               tonumber(string.sub(value,p1+1)) or 0,
               0
    end

    return
        Unescape(string.sub(value,1,p1-1)),
        tonumber(string.sub(value,p1+1,p2-1)) or 0,
        tonumber(string.sub(value,p2+1)) or 0
end

function GMS:SyncLatestGuildTimes()
    local out={}
    for guildId,value in pairs(self.saved.guildScans or {}) do
        local _,ts=ParseGuildScanMeta(value)
        out[tostring(guildId)]=ts or 0
    end
    return out
end

function GMS:SyncParseCurrentRecord(record,latestTimes)
    local name,flat=ParseRecord(record)
    if #flat==0 then return name,{},{} end

    local current={}
    local allByGuild={}

    for i=1,#flat,9 do
        local gid=tostring(flat[i])
        local row={
            guildId=gid,
            listings=tonumber(flat[i+1]) or 0,
            units=tonumber(flat[i+2]) or 0,
            low=tonumber(flat[i+3]) or 0,
            median=tonumber(flat[i+4]) or 0,
            high=tonumber(flat[i+5]) or 0,
            rawMin=tonumber(flat[i+6]) or 0,
            rawMax=tonumber(flat[i+7]) or 0,
            updated=tonumber(flat[i+8]) or 0
        }

        allByGuild[gid]=row

        local latest=tonumber(latestTimes[gid]) or 0

        -- Snapshot rows are stamped at the BEGINNING of frame-safe commit,
        -- while guildScans is stamped a few seconds later after commit ends.
        -- v0.7.1 compared these timestamps exactly and therefore rejected
        -- every freshly committed row as "old".
        --
        -- Allow a small commit-completion tolerance. Truly old rows from a
        -- previous scan are normally minutes/hours/days older and remain
        -- excluded, while rows from the just-completed scan stay current.
        local currentFloor=latest>0 and math.max(0,latest-30) or 0

        if latest<=0 or row.updated>=currentFloor then
            current[#current+1]=row
        end
    end

    return name,current,allByGuild
end

function GMS:SyncAnalyzeCurrentRows(rows)
    if not rows or #rows==0 then return nil end

    local medians={}
    local counts={}
    local totalListings=0
    local totalUnits=0
    local newest=0
    local observedMin=nil
    local observedMax=nil

    for i=1,#rows do
        local row=rows[i]
        local med=tonumber(row.median)

        if med and med>0 then
            local cnt=tonumber(row.listings) or 1
            local units=tonumber(row.units) or cnt

            medians[#medians+1]=med
            counts[#counts+1]=cnt
            totalListings=totalListings+cnt
            totalUnits=totalUnits+units
            newest=math.max(newest,tonumber(row.updated) or 0)

            local rmin=tonumber(row.rawMin)
            local rmax=tonumber(row.rawMax)

            if rmin and rmin>0 then
                observedMin=observedMin and math.min(observedMin,rmin) or rmin
            end

            if rmax and rmax>0 then
                observedMax=observedMax and math.max(observedMax,rmax) or rmax
            end
        end
    end

    if #medians==0 then return nil end

    local sorted={}
    for i=1,#medians do sorted[i]=medians[i] end
    table.sort(sorted)

    local rawMedian=Median(sorted)
    local q1=Percentile(sorted,0.25)
    local q3=Percentile(sorted,0.75)
    local iqr=math.max((q3 or rawMedian)-(q1 or rawMedian),1)
    local lowFence=math.max(0,(q1 or rawMedian)-1.5*iqr)
    local highFence=(q3 or rawMedian)+1.5*iqr

    local pairsList={}
    local clusterPrices={}
    local lowOut,highOut,totalWeight=0,0,0

    for i=1,#medians do
        local price=medians[i]

        if price<lowFence then
            lowOut=lowOut+1
        elseif price>highFence then
            highOut=highOut+1
        else
            local w=math.max(1,math.min(counts[i] or 1,20))
            pairsList[#pairsList+1]={price,w}
            clusterPrices[#clusterPrices+1]=price
            totalWeight=totalWeight+w
        end
    end

    if #pairsList==0 then
        for i=1,#medians do
            local w=math.max(1,math.min(counts[i] or 1,20))
            pairsList[#pairsList+1]={medians[i],w}
            clusterPrices[#clusterPrices+1]=medians[i]
            totalWeight=totalWeight+w
        end
    end

    table.sort(pairsList,function(a,b) return a[1]<b[1] end)
    table.sort(clusterPrices)

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

    local confidence=0
    if #clusterPrices>=8 then confidence=3
    elseif #clusterPrices>=4 then confidence=2
    elseif #clusterPrices>=2 then confidence=1 end

    return {
        p=math.floor((suggested or rawMedian)+0.5),
        l=math.floor((Percentile(clusterPrices,0.25) or clusterPrices[1])+0.5),
        h=math.floor((Percentile(clusterPrices,0.75) or clusterPrices[#clusterPrices])+0.5),
        mn=observedMin or math.floor((clusterPrices[1] or suggested)+0.5),
        mx=observedMax or math.floor((clusterPrices[#clusterPrices] or suggested)+0.5),
        g=#medians,
        c=#clusterPrices,
        o=totalListings,
        v=totalUnits,
        lo=lowOut,
        hi=highOut,
        cf=confidence,
        u=newest
    }
end

function GMS:SyncBuildPricePacked(a)
    if not a or (a.g or 0)<3 or not a.p or a.p<=0 then
        return nil
    end

    local p=math.floor((a.p or 0)+0.5)
    if p<=0 then return nil end

    local function C(v,lo,hi)
        v=math.floor((tonumber(v) or 0)+0.5)
        if v<lo then return lo end
        if v>hi then return hi end
        return v
    end

    local lowPct=C(((p-(a.l or p))/p)*100,0,63)
    local highPct=C((((a.h or p)-p)/p)*100,0,63)
    local conf=C(a.cf or 0,0,3)
    local packA=(((p*64+lowPct)*64+highPct)*4+conf)

    local obsLowPct=C(((p-(a.mn or p))/p)*100,0,255)
    local obsHighPct=C((((a.mx or p)-p)/p)*100,0,255)
    local packB=obsLowPct*256+obsHighPct

    return B64Num(packA).."."..B64Num(packB)
end

function GMS:SyncScoreOpportunity(key,a,currentByGuild,guildId)
    if not a or (a.g or 0)<3 or not a.p or a.p<=0 then return nil end

    local row=currentByGuild[tostring(guildId)]
    local listings=0
    local units=0
    local localMedian=0
    local absent=true

    if row then
        listings=tonumber(row.listings) or 0
        units=tonumber(row.units) or 0
        localMedian=tonumber(row.median) or 0
        absent=false
    end

    local relevance=
        math.min(45,(a.g or 0)*6)+
        math.min(25,(a.cf or 0)*8)+
        math.min(30,math.floor(math.log(math.max(2,a.p or 1))*4))

    local scarcity
    if absent then
        scarcity=100
    else
        scarcity=100-
            math.min(70,listings*7)-
            math.min(30,math.floor(units/25))
    end

    local priceSafety=20

    if localMedian>0 and (a.l or a.p)>0 then
        if localMedian < (a.l or a.p)*0.70 then
            priceSafety=-80
        elseif localMedian > (a.h or a.p)*1.60 then
            priceSafety=-20
        end
    end

    local score=relevance+scarcity+priceSafety
    if score<=80 then return nil end

    return {
        key=key,
        score=score,
        listings=listings,
        units=units,
        localMedian=localMedian,
        absent=absent
    }
end

function GMS:SyncPendingCount()
    local n=0
    for _ in pairs(self.saved.pendingGuilds or {}) do n=n+1 end
    return n
end

function GMS:SyncResetRuntime()
    self.syncSession=nil
    self.syncWork=nil
end

function GMS:SyncStart()
    if self.syncWork then
        Chat("Market Sync work is already running.")
        return
    end

    local ids={}
    for guildId,_ in pairs(self.saved.pendingGuilds or {}) do
        ids[#ids+1]=tostring(guildId)
    end
    table.sort(ids)

    if #ids==0 then
        Chat("MARKET SYNC: no guild scans are pending.")
        return
    end

    local pendingSet={}
    local guildIndex={}
    local guildMeta={}
    local topByGuild={}
    local latestTimes=self:SyncLatestGuildTimes()

    for i=1,#ids do
        local gid=ids[i]
        pendingSet[gid]=true
        guildIndex[gid]=i
        topByGuild[gid]={}

        local name,ts,loaded=ParseGuildScanMeta(
            (self.saved.guildScans or {})[gid]
        )

        guildMeta[#guildMeta+1]={
            index=i,
            guildId=gid,
            name=name or "",
            scannedAt=ts or 0,
            loaded=loaded or 0
        }
    end

    self.syncSession={
        sid="sync-"..tostring(GetTimeStamp()).."-"..tostring(#ids),
        world=GetWorldName and GetWorldName() or "unknown",
        guildIds=ids,
        pendingSet=pendingSet,
        guildIndex=guildIndex,
        guildMeta=guildMeta,
        latestTimes=latestTimes,
        topByGuild=topByGuild,

        phase="items",
        cursor=nil,
        page=1,
        processed=0,
        matchedItems=0,
        priceRows=0,
        opportunityRows=0,

        awaitingConfirm=false,
        lastPage=nil,
        nextCursor=nil,
        nextPhase=nil,
        finalOpened=false
    }

    Chat(string.format(
        "MARKET SYNC STARTED: %d pending guild%s. No whole-market replacement.",
        #ids,#ids==1 and "" or "s"
    ))
    Chat("Use /gmssyncnext to generate Sync Page 1.")
end

function GMS:SyncGuildMetaString()
    local s=self.syncSession
    if not s then return "" end

    local out={}
    for i=1,#s.guildMeta do
        local g=s.guildMeta[i]
        out[#out+1]=
            tostring(g.index).."~"..
            tostring(g.guildId).."~"..
            tostring(g.scannedAt or 0).."~"..
            tostring(g.loaded or 0).."~"..
            UrlEncode(g.name or "")
    end
    return table.concat(out,";")
end

function GMS:SyncOpenPage(page)
    local s=self.syncSession
    if not s or not page then return end

    local base="https://gma-data-receiver.guildmarketassistant.workers.dev/market-sync"

    local url=
        base..
        "?v=9"..
        "&sid="..UrlEncode(s.sid)..
        "&world="..UrlEncode(s.world)..
        "&page="..tostring(page.page)..
        "&done="..(page.done and "1" or "0")..
        "&prices="..tostring(page.priceRows or 0)..
        "&opps="..tostring(page.oppRows or 0)

    if page.page==1 then
        url=url.."&gmeta="..UrlEncode(self:SyncGuildMetaString())
    end

    url=url.."&data="..UrlEncode(page.data or "")

    Chat(string.format(
        "Opening MARKET SYNC PAGE %d | %d price updates / %d opportunities | ~%d chars | DB inspected %d/%d%s",
        page.page,
        page.priceRows or 0,
        page.oppRows or 0,
        #(page.data or ""),
        s.processed or 0,
        self.saved.totalItems or 0,
        page.done and " | FINAL PAGE" or ""
    ))

    RequestOpenUnsafeURL(url)
end

function GMS:SyncRetry()
    local s=self.syncSession
    if not s or not s.lastPage then
        Chat("No Market Sync page is waiting for retry.")
        return
    end

    Chat("Reopening the same Market Sync page. No cursor was advanced.")
    self:SyncOpenPage(s.lastPage)
end

function GMS:SyncAcceptPreviousPage()
    local s=self.syncSession
    if not s or not s.awaitingConfirm then return true end

    if s.lastPage and s.lastPage.done then
        Chat("Final Market Sync page is waiting for confirmation. If browser succeeded, use /gmssyncconfirm. If it failed, use /gmssyncretry.")
        return false
    end

    s.cursor=s.nextCursor
    s.phase=s.nextPhase or s.phase
    s.page=(s.lastPage and s.lastPage.page or s.page)+1
    s.awaitingConfirm=false
    s.lastPage=nil
    s.nextCursor=nil
    s.nextPhase=nil

    if collectgarbage then collectgarbage("collect") end
    return true
end

function GMS:SyncNext()
    local s=self.syncSession

    if not s then
        Chat("No Market Sync session. Use /gmssync.")
        return
    end

    if self.syncWork then
        Chat("Market Sync page generation is already running.")
        return
    end

    if not self:SyncAcceptPreviousPage() then return end

    if s.phase=="items" then
        self:SyncBeginItemPage()
        return
    end

    if s.phase=="opportunities" then
        self:SyncBeginOpportunityPage()
        return
    end

    if s.phase=="error" then
        Chat("Market Sync is stopped in safety state. Pending guilds were NOT cleared. Start a new sync with /gmssync.")
        return
    end

    Chat("Market Sync final page already opened. Use /gmssyncconfirm after browser success.")
end

function GMS:SyncBeginItemPage()
    local s=self.syncSession
    if not s then return end

    self.syncWork={
        phase="items",
        cursor=s.cursor,
        records={},
        bytes=0,
        priceRows=0,
        oppRows=0,
        reachedEnd=false
    }

    Chat(string.format("Generating MARKET SYNC PAGE %d...",s.page))
    zo_callLater(function() GMS:SyncItemBatch() end,20)
end

function GMS:SyncItemBatch()
    local s=self.syncSession
    local w=self.syncWork
    if not s or not w or w.phase~="items" then return end

    local target=self.syncChunkTargetBytes or 13500
    local batchSize=8
    local processed=0
    local key=w.cursor

    while processed<batchSize do
        local nextKey,record=next(self.saved.items or {},key)

        if not nextKey then
            w.reachedEnd=true
            break
        end

        local _,currentRows,allByGuild=
            self:SyncParseCurrentRecord(record,s.latestTimes)

        local currentByGuild={}
        for i=1,#currentRows do
            currentByGuild[currentRows[i].guildId]=currentRows[i]
        end

        local affected=false

        -- A current OR older row for a pending guild means this item's
        -- contribution changed when that guild was rescanned.
        for gi=1,#s.guildIds do
            if allByGuild[s.guildIds[gi]] then
                affected=true
                break
            end
        end

        local a=self:SyncAnalyzeCurrentRows(currentRows)

        -- Opportunity selection sees every current item, including items
        -- absent from a pending guild. Only 25 candidates per pending guild
        -- are retained.
        if a and (a.g or 0)>=3 then
            for gi=1,#s.guildIds do
                local gid=s.guildIds[gi]
                local c=self:SyncScoreOpportunity(
                    nextKey,a,currentByGuild,gid
                )

                if c then
                    SyncKeepTop(
                        s.topByGuild[gid],
                        c,
                        self.syncOpportunityCap or 25
                    )
                end
            end
        end

        if affected and a then
            local packed=self:SyncBuildPricePacked(a)

            if packed then
                local rec=
                    "P"..self:FinalShortItemId(nextKey).."~"..packed

                local extra=#rec+1

                if #w.records>0 and w.bytes+extra>target then
                    -- Leave this item for the next page.
                    break
                end

                w.records[#w.records+1]=rec
                w.bytes=w.bytes+extra
                w.priceRows=w.priceRows+1
                s.matchedItems=s.matchedItems+1
            end
        end

        key=nextKey
        w.cursor=nextKey
        s.processed=s.processed+1
        processed=processed+1

        -- Long sync walks create temporary parsing/analysis tables. Do not
        -- allow them to accumulate until ESO's low-memory watchdog fires.
        if (s.processed or 0)%64==0 and collectgarbage then
            collectgarbage("collect")
        end
    end

    if w.reachedEnd then
        self:SyncFinishItemPage(true)
        return
    end

    if processed<batchSize and #w.records>0 then
        self:SyncFinishItemPage(false)
        return
    end

    if w.bytes>=target-256 then
        self:SyncFinishItemPage(false)
        return
    end

    zo_callLater(function() GMS:SyncItemBatch() end,20)
end

function GMS:SyncFinishItemPage(reachedEnd)
    local s=self.syncSession
    local w=self.syncWork
    if not s or not w then return end

    self.syncWork=nil

    if #w.records==0 and reachedEnd then
        s.cursor=w.cursor
        s.phase="opportunities"
        self:SyncBeginOpportunityPage()
        return
    end

    local nextPhase=reachedEnd and "opportunities" or "items"

    local page={
        page=s.page,
        data=table.concat(w.records,"-"),
        priceRows=w.priceRows,
        oppRows=0,
        done=false
    }

    s.lastPage=page
    s.awaitingConfirm=true
    s.nextCursor=w.cursor
    s.nextPhase=nextPhase
    s.priceRows=s.priceRows+(w.priceRows or 0)

    self:SyncOpenPage(page)
end

function GMS:SyncBuildOpportunityRecords()
    local s=self.syncSession
    if not s then return {} end

    local records={}

    for gi=1,#s.guildIds do
        local gid=s.guildIds[gi]
        local list=s.topByGuild[gid] or {}

        table.sort(list,function(a,b)
            return SyncCandidateBetter(a,b)
        end)

        records[#records+1]="G~"..B64Num(s.guildIndex[gid] or gi)

        for i=1,#list do
            local c=list[i]
            records[#records+1]=
                "O"..self:FinalShortItemId(c.key).."~"..
                B64Num(c.listings or 0).."."..
                B64Num(c.units or 0).."."..
                B64Num(c.localMedian or 0)
        end
    end

    return records
end

function GMS:SyncBeginOpportunityPage()
    local s=self.syncSession
    if not s then return end

    if not s.oppRecords then
        s.oppRecords=self:SyncBuildOpportunityRecords()
        s.oppIndex=1
    end

    -- Safety guard: an empty sync must NEVER be sent as a successful final
    -- update. Keep all guilds pending and stop instead.
    if (s.priceRows or 0)==0 and #(s.oppRecords or {})==0 then
        s.phase="error"
        s.awaitingConfirm=false
        s.lastPage=nil

        if collectgarbage then collectgarbage("collect") end

        Chat("MARKET SYNC STOPPED: generated 0 price rows and 0 opportunity rows.")
        Chat("Nothing was sent/finalized and all pending guilds remain pending.")
        return
    end

    local target=self.syncChunkTargetBytes or 13500
    local records={}
    local bytes=0
    local oppRows=0
    local i=s.oppIndex or 1
    local currentHeader=nil

    while i<=#s.oppRecords do
        local rec=s.oppRecords[i]
        local isHeader=string.sub(rec,1,2)=="G~"
        local extra=#rec+1

        if isHeader then
            currentHeader=rec
        end

        if #records>0 and bytes+extra>target then
            break
        end

        records[#records+1]=rec
        bytes=bytes+extra

        if not isHeader then oppRows=oppRows+1 end

        i=i+1
    end

    local reachedEnd=i>#s.oppRecords

    -- If an opportunity page starts in the middle of one guild, repeat its
    -- header so the Worker can decode the page independently.
    if #records>0 and string.sub(records[1],1,2)~="G~" then
        local back=(s.oppIndex or 1)-1
        while back>=1 do
            local prev=s.oppRecords[back]
            if string.sub(prev,1,2)=="G~" then
                table.insert(records,1,prev)
                bytes=bytes+#prev+1
                break
            end
            back=back-1
        end
    end

    local page={
        page=s.page,
        data=table.concat(records,"-"),
        priceRows=0,
        oppRows=oppRows,
        done=reachedEnd
    }

    s.lastPage=page
    s.awaitingConfirm=true
    s.nextCursor=s.cursor
    s.nextPhase=reachedEnd and "finished" or "opportunities"
    s.nextOppIndex=i
    s.opportunityRows=s.opportunityRows+oppRows

    -- Advance oppIndex only after the user confirms this page by asking next.
    page._nextOppIndex=i

    self:SyncOpenPage(page)
end

function GMS:SyncAcceptPreviousPage()
    local s=self.syncSession
    if not s or not s.awaitingConfirm then return true end

    if s.lastPage and s.lastPage.done then
        Chat("Final Market Sync page is waiting for confirmation. If browser succeeded, use /gmssyncconfirm. If it failed, use /gmssyncretry.")
        return false
    end

    s.cursor=s.nextCursor

    if s.lastPage and s.lastPage._nextOppIndex then
        s.oppIndex=s.lastPage._nextOppIndex
    end

    s.phase=s.nextPhase or s.phase
    s.page=(s.lastPage and s.lastPage.page or s.page)+1
    s.awaitingConfirm=false
    s.lastPage=nil
    s.nextCursor=nil
    s.nextPhase=nil

    if collectgarbage then collectgarbage("collect") end
    return true
end

function GMS:SyncConfirm()
    local s=self.syncSession
    if not s or not s.lastPage or not s.lastPage.done then
        Chat("No final Market Sync page is waiting for confirmation.")
        return
    end

    for i=1,#s.guildIds do
        self.saved.pendingGuilds[s.guildIds[i]]=nil
    end

    local guildCount=#s.guildIds
    local pages=s.page
    local prices=s.priceRows or 0
    local opps=s.opportunityRows or 0

    self:SyncResetRuntime()

    if collectgarbage then collectgarbage("collect") end

    Chat(string.format(
        "MARKET SYNC CONFIRMED: %d guilds / %d pages / %d price updates / %d opportunity rows. Pending flags cleared.",
        guildCount,pages,prices,opps
    ))
end

function GMS:SyncStatus()
    local pending=self:SyncPendingCount()
    Chat(string.format(
        "MARKET SYNC STATUS: %d pending guild%s | DB %d items / %d guild snapshots.",
        pending,pending==1 and "" or "s",
        self.saved.totalItems or 0,
        self.saved.totalGuildSnapshots or 0
    ))
end

function GMS:Initialize()
    self.saved=ZO_SavedVars:NewAccountWide(
        "GuildMarketScannerSavedVariables",
        1,nil,defaults
    )

    if (self.saved.schemaVersion or 0)~=10 then
        self:MigrateToV10()
    else
        self.saved.items=self.saved.items or {}
        self.saved.guildScans=self.saved.guildScans or {}
        self:Recount()
    end

    self.saved.pendingGuilds=self.saved.pendingGuilds or {}

    -- v0.7.1 bootstrap fix:
    -- v0.7.0 accidentally defaulted marketSyncVersion to 1 before the
    -- existing-scan migration ran, so existing scans were not marked pending.
    -- Use a NEW dedicated bootstrap flag that did not exist in v0.7.0.
    -- Therefore every installation upgrading from v0.7.0 gets exactly one
    -- safe bootstrap of its already-completed guild scans.
    if (self.saved.marketSyncBootstrapVersion or 0)<1 then
        local bootstrapped=0

        for guildId,value in pairs(self.saved.guildScans or {}) do
            local _,ts=ParseGuildScanMeta(value)
            self.saved.pendingGuilds[tostring(guildId)]=ts or GetTimeStamp()
            bootstrapped=bootstrapped+1
        end

        self.saved.marketSyncBootstrapVersion=1

        if bootstrapped>0 then
            Chat(string.format(
                "Market Sync bootstrap: %d existing guild scan%s marked pending.",
                bootstrapped,
                bootstrapped==1 and "" or "s"
            ))
        end
    end

    -- Any unfinished blank export shell is safe to discard at startup.
    if self.saved.export and self.saved.export.chunk=="" then
        self.saved.export=nil
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

    SLASH_COMMANDS["/gmsnext"]=function()
        GMS:NextExportChunk()
    end

    SLASH_COMMANDS["/gmsclearexport"]=function()
        GMS:ClearExport()
    end

    SLASH_COMMANDS["/gmstesturl"]=function()
        GMS:TestSubmissionURL()
    end

    SLASH_COMMANDS["/gmssubmittest"]=function()
        GMS:SubmitRealDataTest()
    end

    SLASH_COMMANDS["/gmscloudstart"]=function()
        GMS:StartCloudExport()
    end

    SLASH_COMMANDS["/gmscloudnext"]=function()
        GMS:SendNextCloudPart()
    end

    SLASH_COMMANDS["/gmscloudreset"]=function()
        GMS:ResetCloudExport()
    end

    SLASH_COMMANDS["/gmsoppstart"]=function()
        GMS:StartOpportunityExport()
    end

    SLASH_COMMANDS["/gmsoppnext"]=function()
        GMS:SendNextOpportunityPart()
    end

    SLASH_COMMANDS["/gmsmeasurefinal"]=function()
        GMS:MeasureFinalExport()
    end

    SLASH_COMMANDS["/gmssnapshot"]=function(text)
        GMS:PrintSnapshotByName(text)
    end

    SLASH_COMMANDS["/gmsfind"]=function(text)
        GMS:FindAllMatchingRecords(text)
    end

    SLASH_COMMANDS["/gmsmeasuretransport"]=function()
        GMS:MeasureFinalWeeklyTransportAsync()
    end

    SLASH_COMMANDS["/gmssync"]=function()
        GMS:SyncStart()
    end

    SLASH_COMMANDS["/gmssyncnext"]=function()
        GMS:SyncNext()
    end

    SLASH_COMMANDS["/gmssyncretry"]=function()
        GMS:SyncRetry()
    end

    SLASH_COMMANDS["/gmssyncconfirm"]=function()
        GMS:SyncConfirm()
    end

    SLASH_COMMANDS["/gmssyncstatus"]=function()
        GMS:SyncStatus()
    end

    -- Old command kept only as a friendly redirect; it no longer performs a
    -- whole-market weekly export.
    SLASH_COMMANDS["/gmsweekly"]=function()
        Chat("Weekly whole-market export was retired in v0.7.0. Use /gmssync.")
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

    Chat("BUILD 0703 CONSOLE-SAFE SYNC URL SIZE")
    Chat("Guild Market Scanner DEV v0.7.3 loaded.")
    Chat(string.format(
        "DB: %d items / %d guild snapshots / %d registered guild scans.",
        self.saved.totalItems or 0,
        self.saved.totalGuildSnapshots or 0,
        self:GuildScanCount()
    ))
    self:MemoryReport("startup final",false)
end

local function OnAddonLoaded(_,addonName)
    if addonName~=GMS.name then return end
    EVENT_MANAGER:UnregisterForEvent(GMS.name,EVENT_ADD_ON_LOADED)
    GMS:Initialize()
end

EVENT_MANAGER:RegisterForEvent(GMS.name,EVENT_ADD_ON_LOADED,OnAddonLoaded)
