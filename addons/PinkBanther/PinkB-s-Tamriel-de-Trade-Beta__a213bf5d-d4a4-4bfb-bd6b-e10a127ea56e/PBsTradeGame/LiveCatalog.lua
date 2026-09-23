-- Imports names shipped by the running ESO client. The static fictional catalog
-- remains the balance baseline; these records add canonical, localized places.
local L={imported=false,count=0}; PBTrade.LiveCatalog=L
local D,C=PBTrade.Data,PBTrade.Config
local function clean(value)
    value=tostring(value or "")
    if zo_strformat then value=zo_strformat("<<1>>",value) end
    return value:gsub("|c%x%x%x%x%x%x",""):gsub("|r",""):gsub("[%s%p・：]",""):lower()
end
local function zoneForName(name)
    local key=clean(name); if key=="" then return nil end
    for _,zone in ipairs(D.zones) do
        local candidate=clean(zone.name)
        if key==candidate or (#key>=6 and candidate:find(key,1,true)) or (#candidate>=6 and key:find(candidate,1,true)) then return zone end
    end
end
local categoryWords={
    {"鉱","mine","quarry","採掘","mine"},{"製材","lumber","sawmill","lumber"},{"鍛冶","forge","smith","forge"},
    {"仕立","tailor","cloth","tailor"},{"錬金","alchemy","apothec","alchemy"},{"酒場","tavern","pub","tavern"},
    {"宿","inn","lodging","inn"},{"港","harbor","dock","port"},{"隊商","caravan","caravan"},
    {"農場","farm","plantation","farm"},{"牧場","ranch","stable","ranch"},{"書","library","book","books"},
    {"魔術","mage","arcane","mages"},{"戦士","fighter","garrison","fighters"},{"宝飾","jewel","jewelry"},
}
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
local function find(zoneId,name)
    local key=clean(name)
    for _,id in ipairs(D.propertyIdsByZone[zoneId] or {}) do if clean(D.propertyById[id].name)==key then return D.propertyById[id] end end
end
local function add(id,name,zone,category,description,source,sourceData)
    if not zone or name=="" or D.propertyById[id] or find(zone.id,name) then return nil end
    local seed=hash(id..name); local value=math.floor((4200+seed%12800)/50)*50
    local p={id=id,name=name,zone=zone.id,category=category,marketValue=value,
        expectedProfit=math.floor(value*(.045+(seed%37)/1000)),owner=C.neutralId,
        independenceRisk=8+seed%25,independenceIncrease=7+seed%12,
        gaugeAcceleration=.8+(seed%15)/10,groups={},negotiationResistances={},isHeadquarters=false,
        businessProfile="canonical",profileName="ESO実在地点",description=description~="" and description or zone.name.."で確認された実在地点。",
        minChapter=zone.minChapter,canonical=true,requiresVisit=true,canonicalSource=source,sourceData=sourceData}
    D.properties[#D.properties+1]=p; D.AddProperty(p); L.count=L.count+1; return p
end
function L.Import()
    if L.imported then return L.count end; L.imported=true
    if type(GetNumZones)~="function" or type(GetZoneNameByIndex)~="function" then return 0 end
    local zoneByIndex={}
    for zoneIndex=1,GetNumZones() do zoneByIndex[zoneIndex]=zoneForName(GetZoneNameByIndex(zoneIndex)) end
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
    return L.count
end
function L.CaptureCurrent(state)
    if not state or type(GetPlayerLocationName)~="function" or type(GetUnitZoneIndex)~="function" then return end
    local zoneIndex=GetUnitZoneIndex("player"); if not zoneIndex then return end
    local zone=zoneForName(GetZoneNameByIndex(zoneIndex)); local name=GetPlayerLocationName()
    if not zone or not name or name=="" or clean(name)==clean(zone.name) then return end
    local id=string.format("eso_location_%d_%d",zoneIndex,hash(name))
    local p=find(zone.id,name) or add(id,name,zone,inferCategory(name,"",false),"プレイヤーが実際に訪れたESO内の地点。","eso_location",{zoneIndex=zoneIndex})
    if p then
        state.visitedProperties=state.visitedProperties or {}; local newlyVisited=not state.visitedProperties[p.id]
        state.visitedProperties[p.id]=true
        p.requiresVisit=true
        if not state.properties[p.id] then
            state.properties[p.id]=PBTrade.Model.Copy(p)
            state.properties[p.id].reserve=p.expectedProfit*C.battle.reserveProfitFactor
        end
        return p,newlyVisited
    end
end
return L
