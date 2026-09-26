-- Imports names shipped by the running ESO client. The static fictional catalog
-- remains the balance baseline; these records add canonical, localized places.
local L={imported=false,count=0,byKey={},zoneCache={},pending=nil}; PBTrade.LiveCatalog=L
local D,C=PBTrade.Data,PBTrade.Config
-- Name key for matching. Only ASCII spaces/punctuation are stripped by pattern (Lua classes
-- work on bytes, so multi-byte characters must never appear inside [...]); Japanese
-- separators are removed as whole literal sequences.
local separators={"　","・","：","「","」","（","）","『","』","〈","〉","、","。","－","―"}
function L.Key(value)
    value=tostring(value or "")
    if zo_strformat then value=zo_strformat("<<1>>",value) end
    value=value:gsub("|c%x%x%x%x%x%x",""):gsub("|r",""):gsub("[%s%p]","")
    for _,mark in ipairs(separators) do value=value:gsub(mark,"") end
    return value:lower()
end
local function zoneForName(name)
    local key=L.Key(name); if key=="" then return nil end
    for _,zone in ipairs(D.zones) do
        if key==L.Key(zone.name) then return zone end
    end
    -- Partial matches need at least three Japanese characters (9 bytes) on the shorter side.
    for _,zone in ipairs(D.zones) do
        local candidate=L.Key(zone.name)
        if (#key>=9 and candidate:find(key,1,true)) or (#candidate>=9 and key:find(candidate,1,true)) then return zone end
    end
end
local function zoneForIndex(zoneIndex)
    local cached=L.zoneCache[zoneIndex]
    if cached==nil then
        cached=type(GetZoneNameByIndex)=="function" and zoneForName(GetZoneNameByIndex(zoneIndex)) or false
        L.zoneCache[zoneIndex]=cached
    end
    return cached or nil
end
L.ZoneForName=zoneForName
local function zoneForId(zoneId)
    if not zoneId or zoneId==0 then return nil end
    local name=type(GetZoneNameById)=="function" and GetZoneNameById(zoneId) or nil
    local zone=name and zoneForName(name)
    if zone or type(GetZoneIndex)~="function" then return zone end
    local ok,indexValue=pcall(GetZoneIndex,zoneId)
    return ok and indexValue and zoneForIndex(indexValue) or nil
end
-- Player housing exposes the stable houseId and the outdoor zone where that house is found.
-- The small table is a last resort for the two base-game inn rooms if that API is unavailable.
local function houseTradeZone(houseId)
    if not houseId or houseId==0 then return nil end
    if type(GetHouseFoundInZoneId)=="function" then
        local ok,zoneId=pcall(GetHouseFoundInZoneId,houseId)
        if ok then local zone=zoneForId(zoneId); if zone then return zone,"housingApi" end end
    end
    local zoneId=C.canonical.houseRegions and C.canonical.houseRegions[houseId]
    return zoneId and D.zoneById[zoneId] or nil,"houseTable"
end
L.HouseTradeZone=houseTradeZone
-- Interiors use their own zone index. Walk the client zone hierarchy so an add-on loaded
-- after the player is already inside an inn/house can still file it under its outdoor region.
local function parentZoneForIndex(zoneIndex)
    if type(GetZoneId)~="function" or type(GetParentZoneId)~="function" then return nil end
    local zoneId=GetZoneId(zoneIndex); local seen={}
    for _=1,12 do
        if not zoneId or zoneId==0 or seen[zoneId] then break end
        seen[zoneId]=true
        local parentId=GetParentZoneId(zoneId)
        if not parentId or parentId==0 or parentId==zoneId then break end
        local zone=zoneForId(parentId)
        if zone then return zone end
        zoneId=parentId
    end
end
L.ParentZoneForIndex=parentZoneForIndex
local categoryWords={
    {"鉱","mine","quarry","採掘","mine"},{"製材","lumber","sawmill","lumber"},{"鍛冶","forge","smith","forge"},
    {"仕立","tailor","cloth","tailor"},{"錬金","alchemy","apothec","alchemy"},{"酒場","tavern","pub","tavern"},
    {"宿","inn","lodging","inn"},{"港","harbor","dock","port"},{"隊商","caravan","caravan"},
    {"農場","farm","plantation","farm"},{"牧場","ranch","stable","ranch"},{"書","library","book","books"},
    {"魔術","mage","arcane","mages"},{"戦士","fighter","garrison","fighters"},{"宝飾","jewel","jewelry"},
}
-- Price tier from the place's name (descriptions are long flavour text and would mislead):
-- banks and palaces are dear, taverns and camps cheap. nil means the market norm.
function L.ValueTier(name)
    local text=tostring(name or ""):lower()
    for _,tier in ipairs(C.canonical.tiers) do
        for _,word in ipairs(tier.words) do if text:find(word,1,true) then return tier end end
    end
end
local function inferCategory(name,description,isHouse)
    if isHouse then return "inn" end
    local text=(tostring(name or "").." "..tostring(description or "")):lower()
    for _,row in ipairs(categoryWords) do
        for i=1,#row-1 do if text:find(row[i],1,true) then return row[#row] end end
    end
    return "market"
end
local function hash(text)
    local value=17
    for i=1,#text do value=(value*33+text:byte(i))%1000003 end
    return value
end
L.Hash=hash
function L.Find(zoneId,name)
    local key=L.Key(name)
    for _,p in ipairs(L.byKey[key] or {}) do if p.zone==zoneId then return p end end
    -- A live ESO location must never resolve to one of the fictional campaign businesses.
    -- Only canonical records participate in current-location matching.
    for _,id in ipairs(D.propertyIdsByZone[zoneId] or {}) do
        local p=D.propertyById[id]
        if p.canonical and L.Key(p.name)==key then return p end
    end
end
-- Interiors (houses, instanced taverns, delves) are their own zones; match them by name anywhere.
function L.FindAnywhere(name)
    local list=L.byKey[L.Key(name)]; return list and list[1] or nil
end
local function index(p)
    local key=L.Key(p.name); local list=L.byKey[key]
    if not list then list={}; L.byKey[key]=list end
    list[#list+1]=p
end
L.Index=index
-- A real place is priced relative to the average property of the moment: its tier's multiple
-- (1 when unrecognised) with a small deterministic spread, so two of a kind differ a little.
function L.PriceFactor(id,name)
    local K=C.canonical; local seed=hash(id..name); local tier=L.ValueTier(name)
    local jitter=1+K.jitter*(((seed%2001)/1000)-1)
    return (tier and tier.mult or 1)*jitter,(tier and tier.yield or K.defaultYield),tier
end
function L.BaseValue(id,name,average)
    local special=C.canonical.specialValues and C.canonical.specialValues[L.Key(name)]
    if special then
        local tier={label=special.label or "特別物件",category=special.category,yield=special.yield or C.canonical.defaultYield,
            finalAcquisition=special.finalAcquisition==true}
        return special.value,math.floor(special.value*tier.yield),tier
    end
    local factor,yield,tier=L.PriceFactor(id,name)
    local value=math.max(C.Money(500),math.floor((average or L.CatalogAverage())*factor/(50*C.currencyScale))*(50*C.currencyScale))
    value=value+hash(id..name..":value")%C.currencyScale
    return value,math.floor(value*yield),tier
end
-- Average value of the regular (non-real-place) catalog before any period has passed.
function L.CatalogAverage()
    if not L.catalogAverage then
        local total,n=0,0
        for _,p in ipairs(D.properties) do if not p.canonical then total=total+p.marketValue; n=n+1 end end
        L.catalogAverage=n>0 and total/n or C.canonical.base
    end
    return L.catalogAverage
end
local function add(id,name,zone,category,description,source,sourceData)
    if not zone or name=="" or D.propertyById[id] or L.Find(zone.id,name) then return nil end
    local seed=hash(id..name)
    local value,profit,tier=L.BaseValue(id,name)
    if tier and tier.category and category~="inn" then category=tier.category end
    local p={id=id,name=name,zone=zone.id,category=category,marketValue=value,valueTier=tier and tier.label or nil,
        expectedProfit=profit,owner=C.neutralId,
        independenceRisk=8+seed%25,independenceIncrease=7+seed%12,
        gaugeAcceleration=.8+(seed%15)/10,groups={},negotiationResistances={},isHeadquarters=false,
        businessProfile="canonical",profileName="ESO実在地点",description=description~="" and description or zone.name.."で確認された実在地点。",
        minChapter=zone.minChapter,canonical=true,requiresVisit=true,canonicalSource=source,sourceData=sourceData,
        finalAcquisition=tier and tier.finalAcquisition or false}
    D.properties[#D.properties+1]=p; D.AddProperty(p); index(p); L.count=L.count+1; return p
end
function L.Import()
    if L.imported then return L.count end; L.imported=true
    if type(GetNumZones)~="function" or type(GetZoneNameByIndex)~="function" then return 0 end
    local zoneByIndex={}
    for zoneIndex=1,GetNumZones() do zoneByIndex[zoneIndex]=zoneForIndex(zoneIndex) end
    if type(GetNumPOIs)=="function" and type(GetPOIInfo)=="function" then
        for zoneIndex,zone in pairs(zoneByIndex) do if zone then
            for poiIndex=1,GetNumPOIs(zoneIndex) do
                local name,_,opening,finished=GetPOIInfo(zoneIndex,poiIndex)
                local poiType=type(GetPOIType)=="function" and GetPOIType(zoneIndex,poiIndex) or nil
                local standard=POI_TYPE_STANDARD==nil or poiType==POI_TYPE_STANDARD or poiType==POI_TYPE_HOUSE
                if standard and name and name~="" then
                    local description=(finished and finished~="" and finished) or opening or ""
                    add(string.format("eso_poi_%d_%d",zoneIndex,poiIndex),name,zone,
                        inferCategory(name,description,poiType==POI_TYPE_HOUSE),description,"eso_poi",{zoneIndex=zoneIndex,poiIndex=poiIndex})
                end
            end
        end end
    end
    if type(GetNumFastTravelNodes)=="function" and type(GetFastTravelNodeInfo)=="function" then
        for nodeIndex=1,GetNumFastTravelNodes() do
            local _,name,_,_,_,_,poiType=GetFastTravelNodeInfo(nodeIndex)
            if name and name~="" and (POI_TYPE_HOUSE==nil or poiType==POI_TYPE_HOUSE) then
                local zoneIndex=type(GetFastTravelNodePOIIndicies)=="function" and GetFastTravelNodePOIIndicies(nodeIndex) or nil
                local zone=zoneIndex and zoneByIndex[zoneIndex]
                add(string.format("eso_house_%d_%d",zoneIndex or 0,nodeIndex),name,zone,"inn",
                    "ESOクライアントの住宅・宿屋地点データから登録。","eso_house",{zoneIndex=zoneIndex,nodeIndex=nodeIndex})
            end
        end
    end
    -- A few base-game interiors are important registration anchors but are not exposed as
    -- house fast-travel nodes on every platform/client state.  Add name-based fallbacks after
    -- the live import; `add` suppresses them when the client already supplied the same place.
    local knownInteriors={
        {id="eso_known_drunken_lion",name="酔いどれライオン",zone="glenumbra",category="inn"},
        {id="eso_known_maras_kiss",name="マーラの口付け",zone="auridon",category="inn"},
        {id="eso_known_maras_kiss_pub",name="パブ マーラの口付け",zone="auridon",category="tavern"},
        {id="eso_known_tor_dryoch",name="トール・ドライオク",zone="glenumbra",category="market",
            description="第5章の後に最後の証文が届く、100京ゴールド級の最終物件。"},
    }
    for _,place in ipairs(knownInteriors) do
        add(place.id,place.name,D.zoneById[place.zone],place.category,
            place.description or "ESO内の実在する宿屋・酒場。現地で明示的に物件登録できます。","eso_known",{known=true})
    end
    return L.count
end
-- Where the player is right now, as the client reports it. Cheap enough for a 2 s poll.
function L.ReadHere()
    if type(GetUnitZoneIndex)~="function" or type(GetZoneNameByIndex)~="function" then return nil end
    local zoneIndex=GetUnitZoneIndex("player"); if not zoneIndex then return nil end
    local here={zoneIndex=zoneIndex,zoneName=GetZoneNameByIndex(zoneIndex) or "",
        location=type(GetPlayerLocationName)=="function" and GetPlayerLocationName() or "",
        houseId=type(GetCurrentZoneHouseId)=="function" and GetCurrentZoneHouseId() or 0}
    here.zone=zoneForIndex(zoneIndex)
    if not here.zone and here.houseId~=0 then here.parentZone,here.tradeZoneSource=houseTradeZone(here.houseId) end
    if not here.zone and not here.parentZone then
        here.parentZone=parentZoneForIndex(zoneIndex)
        if here.parentZone then here.tradeZoneSource="parentZone" end
    end
    local tradeZone=here.zone or here.parentZone
    if tradeZone then L.lastOutdoorZone=tradeZone.id end
    return here
end
-- A visit record: outdoors it is the local place name inside a trade region; inside an
-- instanced interior it is the interior's own name, filed under the last outdoor region.
function L.Observe()
    local here=L.ReadHere(); if not here then return nil end
    if here.zone then
        if here.location=="" or L.Key(here.location)==L.Key(here.zone.name) then return nil end
        return {zoneId=here.zone.id,name=here.location,houseId=here.houseId}
    end
    local name=here.zoneName~="" and here.zoneName or here.location
    if name=="" then return nil end
    return {zoneId=here.parentZone and here.parentZone.id or L.lastOutdoorZone,
        name=name,alt=here.location~=name and here.location or nil,interior=true,houseId=here.houseId}
end
-- Resolve a live record to a canonical property without marking it as registered.  This is
-- used by the title screen so the player can review and explicitly register the current place.
function L.Resolve(state,record)
    if not state or not record then return nil end
    local p=record.zoneId and L.Find(record.zoneId,record.name)
    if not p and record.interior then p=L.FindAnywhere(record.name) or (record.alt and L.FindAnywhere(record.alt)) end
    -- POI/node indices can be renumbered between client versions. When no exact canonical
    -- name match exists, a house gets a stable ID based on the API's houseId instead.
    -- Never reuse that ID when an earlier observation attached it to another name/region.
    -- A stale record used to make Snugpod resolve as the Rosy Lion for the rest of the
    -- session. Keep the base ID for the normal case and disambiguate only a collision.
    if not p and record.zoneId and record.houseId and record.houseId~=0 then
        local zone=D.zoneById[record.zoneId]
        local baseId="eso_houseid_"..record.houseId
        local id=baseId
        local existing=D.propertyById[id]
        if existing and (L.Key(existing.name)~=L.Key(record.name) or existing.zone~=record.zoneId) then
            id=baseId.."_"..hash(record.zoneId.."|"..record.name)
            existing=D.propertyById[id]
        end
        p=existing or add(id,record.name,zone,"inn",
            "ESOの住宅IDから所在地を確認した宿屋・住宅。","eso_house",{houseId=record.houseId})
    end
    if not p and record.zoneId then
        local zone=D.zoneById[record.zoneId]
        local id=string.format("eso_location_%s_%d",record.zoneId,hash(record.name))
        p=D.propertyById[id] or add(id,record.name,zone,inferCategory(record.name,"",false),
            record.interior and "プレイヤーが実際に立ち入ったESO内の建物・屋内。" or "プレイヤーが実際に訪れたESO内の地点。","eso_location",{})
    end
    if not p then return nil end
    if not state.properties[p.id] then
        state.properties[p.id]=PBTrade.Model.Copy(p)
        PBTrade.Model.PriceCanonical(state,state.properties[p.id])
    end
    return p
end
function L.Apply(state,record)
    local p=L.Resolve(state,record)
    if not p then return nil end
    state.visitedProperties=state.visitedProperties or {}
    local newlyVisited=not state.visitedProperties[p.id]
    state.visitedProperties[p.id]=true
    return p,newlyVisited
end
function L.CaptureCurrent(state) return L.Apply(state,L.Observe()) end
function L.PreviewCurrent(state,record)
    record=record or L.Observe()
    local p=L.Resolve(state,record)
    return p,record,p and state.visitedProperties and state.visitedProperties[p.id] or false
end
-- Visits made before the ledger is first opened are kept as small records in saved variables.
function L.RecordPending(saved,record)
    if not saved or not record then return end
    saved.pendingVisits=saved.pendingVisits or {}
    local key=(record.zoneId or "?").."|"..L.Key(record.name)
    for _,r in ipairs(saved.pendingVisits) do if r.key==key then return end end
    if #saved.pendingVisits>=200 then table.remove(saved.pendingVisits,1) end
    saved.pendingVisits[#saved.pendingVisits+1]={key=key,zoneId=record.zoneId,name=record.name,alt=record.alt,
        interior=record.interior,houseId=record.houseId}
end
-- Returns how many places were newly confirmed, and their names (for the opening notice).
function L.ApplyPending(state,saved)
    if not saved or not saved.pendingVisits then return 0,{} end
    local count,names=0,{}
    for _,record in ipairs(saved.pendingVisits) do
        local p,newlyVisited=L.Apply(state,record)
        if newlyVisited then count=count+1; names[#names+1]=p.name end
    end
    saved.pendingVisits=nil
    return count,names
end
-- Human-readable report for /pbtrade here and the management ledger.
function L.Describe(state)
    local here=L.ReadHere()
    if not here then return "現在地を取得できません（ESOクライアント外）" end
    local tradeRegion
    if here.zone then tradeRegion=here.zone.name
    elseif here.parentZone then
        local source=here.tradeZoneSource=="housingApi" and "住宅所在地API" or (here.tradeZoneSource=="houseTable" and "住宅ID" or "親地域")
        tradeRegion=here.parentZone.name.."（"..source.."から判定）"
    else tradeRegion="対応なし・屋内扱い"..(L.lastOutdoorZone and ("（直前の地域 "..D.zoneById[L.lastOutdoorZone].name.."）") or "") end
    local lines={"ESOの地域："..here.zoneName.."（zoneIndex "..here.zoneIndex..(here.houseId~=0 and (" / 住宅ID "..here.houseId) or "")..")",
        "地名："..(here.location~="" and here.location or "（なし）"),"交易地域："..tradeRegion}
    local record=L.Observe()
    if not record then lines[#lines+1]="物件：なし（地域名そのもの、または地名なし）"
    else
        local p=record.zoneId and L.Find(record.zoneId,record.name)
        if not p and record.interior then p=L.FindAnywhere(record.name) or (record.alt and L.FindAnywhere(record.alt)) end
        if p then
            local sp=state and state.properties[p.id]
            lines[#lines+1]="物件："..p.name.."（"..(state and state.visitedProperties[p.id] and "登録済み・遠隔買収可" or "未登録")
                ..(sp and (" / 評価額 "..sp.marketValue) or "").."）"
        elseif record.zoneId then lines[#lines+1]="物件：未登録（「"..record.name.."」として現在地の再確認時に登録できます）"
        else lines[#lines+1]="物件：未登録（所属する交易地域を特定できません。一度屋外へ出てから入り直してください）" end
    end
    return table.concat(lines,"\n")
end
return L
