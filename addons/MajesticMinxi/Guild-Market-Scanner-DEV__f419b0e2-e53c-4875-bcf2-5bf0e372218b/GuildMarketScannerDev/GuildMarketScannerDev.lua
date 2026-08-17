GuildMarketScannerDev = GuildMarketScannerDev or {}
local GMS = GuildMarketScannerDev

GMS.name = "GuildMarketScannerDev"
GMS.version = "0.4.4"
GMS.schemaVersion = 8
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
    schemaVersion=8,
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
        local g,c,m,u=string.match(row,"^([^,]+),([^,]+),([^,]+),([^,]+)$")
        if g then
            flat[#flat+1]=tonumber(g) or g
            flat[#flat+1]=tonumber(c) or 0
            flat[#flat+1]=tonumber(m) or 0
            flat[#flat+1]=tonumber(u) or 0
        end
    end
    return name,flat
end

local function SerializeRecord(name,flat)
    local rows={}
    for i=1,#flat,4 do
        rows[#rows+1]=tostring(flat[i] or 0)..","..
                     tostring(flat[i+1] or 0)..","..
                     tostring(flat[i+2] or 0)..","..
                     tostring(flat[i+3] or 0)
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
    for i=1,#flat,4 do
        if tostring(flat[i])==tostring(guildId) then return i end
    end
    return nil
end

function GMS:PruneOldestGuildSnapshot(flat)
    while (#flat/4)>self.maxGuildSnapshotsPerItem do
        local oldestOffset=nil
        local oldestTime=nil
        for i=1,#flat,4 do
            local t=flat[i+3] or 0
            if oldestTime==nil or t<oldestTime then
                oldestTime=t
                oldestOffset=i
            end
        end
        if not oldestOffset then break end
        for _=1,4 do table.remove(flat,oldestOffset) end
    end
end

function GMS:SetGuildSnapshot(key,name,guildId,count,median,updated)
    local oldRecord=self.saved.items[key]
    local oldName,flat=ParseRecord(oldRecord)
    if oldName~="" then name=oldName end

    local oldCount=#flat/4
    local offset=self:FindGuildOffset(flat,guildId)
    if offset then
        flat[offset]=guildId
        flat[offset+1]=count
        flat[offset+2]=median
        flat[offset+3]=updated
    else
        flat[#flat+1]=guildId
        flat[#flat+1]=count
        flat[#flat+1]=median
        flat[#flat+1]=updated
    end

    self:PruneOldestGuildSnapshot(flat)

    if not oldRecord then
        self.saved.totalItems=(self.saved.totalItems or 0)+1
    end

    self.saved.items[key]=SerializeRecord(name or "",flat)
    local newCount=#flat/4
    self.saved.totalGuildSnapshots=
        math.max(0,(self.saved.totalGuildSnapshots or 0)+(newCount-oldCount))
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
    local newest=0

    for i=1,#flat,4 do
        local cnt=tonumber(flat[i+1]) or 1
        local med=tonumber(flat[i+2])
        local upd=tonumber(flat[i+3]) or 0
        if med and med>0 then
            medians[#medians+1]=med
            counts[#counts+1]=cnt
            totalListings=totalListings+cnt
            newest=math.max(newest,upd)
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
        if running>=target then suggested=pairsList[i][1];break end
    end

    local confidence=0
    if #clusterPrices>=8 then confidence=3
    elseif #clusterPrices>=4 then confidence=2
    elseif #clusterPrices>=2 then confidence=1 end

    return {
        p=math.floor((suggested or rawMedian)+0.5),
        l=math.floor((Percentile(clusterPrices,0.25) or clusterPrices[1])+0.5),
        h=math.floor((Percentile(clusterPrices,0.75) or clusterPrices[#clusterPrices])+0.5),
        g=#medians,c=#clusterPrices,o=totalListings,
        lo=lowOut,hi=highOut,cf=confidence,u=newest
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

function GMS:MigrateToV7()
    self.saved.schemaVersion=8
    self.saved.items={}
    self.saved.totalItems=0
    self.saved.totalGuildSnapshots=0
    self.saved.lastScan=nil
    self.saved.guildScans={}
    self.saved.export=nil
    if collectgarbage then collectgarbage("collect") end
    Chat("GMS STRING-DB initialized with clean schema v8.")
end

function GMS:BufferListing(link,name,unitPrice)
    if not link or link=="" or not unitPrice or unitPrice<=0 then return end
    local key=ItemKey(link)
    local b=self.scanBuffer[key]
    if not b then
        b={n=name or "",p={}}
        self.scanBuffer[key]=b
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

    for key,b in pairs(self.scanBuffer) do
        if #b.p>0 then
            local med=BuildMedian(b.p)
            if med then
                self:SetGuildSnapshot(key,b.n,guildId,#b.p,med,now)
                itemCount=itemCount+1
            end
        end
    end

    self.scanBuffer={}
    if collectgarbage then collectgarbage("collect") end
    self:MemoryReport("after scan cleanup",false)
    return itemCount
end

function GMS:RecordCompletedGuildScan()
    self.saved.guildScans=self.saved.guildScans or {}
    if not self.scanGuildId or self.scanGuildId==0 then return end
    self.saved.guildScans[tostring(self.scanGuildId)]=
        Escape(self.scanGuildName or "").."|"..
        tostring(GetTimeStamp()).."|"..
        tostring(self.scanLoaded or 0)
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
    },"|"), math.floor(#flat/4)
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
    local guildCount=math.floor(#flat/4)

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

    for i=1,#flat,4 do
        local count=tonumber(flat[i+1]) or 0
        local price=tonumber(flat[i+2]) or 0
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
    for i=1,#flat,4 do
        local gid=tostring(flat[i])
        local idx=guildMap[gid]
        if idx then
            local count=tonumber(flat[i+1]) or 0
            local price=tonumber(flat[i+2]) or 0
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

    for i=1,#flat,4 do
        local gid=tostring(flat[i])
        local idx=guildMap[gid]
        local count=tonumber(flat[i+1]) or 0
        local price=tonumber(flat[i+2]) or 0

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

function GMS:Initialize()
    self.saved=ZO_SavedVars:NewAccountWide(
        "GuildMarketScannerSavedVariables",
        1,nil,defaults
    )

    if (self.saved.schemaVersion or 0)~=8 then
        self:MigrateToV7()
    else
        self.saved.items=self.saved.items or {}
        self.saved.guildScans=self.saved.guildScans or {}
        self:Recount()
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

    Chat("BUILD 044 FINAL EXPORT MEASURER")
    Chat("Guild Market Scanner DEV v0.4.4 loaded.")
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
