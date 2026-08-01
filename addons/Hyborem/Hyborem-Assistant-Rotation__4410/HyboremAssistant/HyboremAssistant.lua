local _n="HyboremAssistant"
local db
local asst={merchant={267,301,6378,8995,9744,11877,12414},banker={6376,8994,9743,11876,12413},decon={10184,13063},fence={300}}
local _inRot=false

local function GetUnlocked(cat)
local n,ids={"None"},{["None"]=0}
for _,id in ipairs(asst[cat]) do if IsCollectibleUnlocked(id) then local name=GetCollectibleInfo(id) table.insert(n,name) ids[name]=id end end
return n,ids
end

local function SummonComp()
if _inRot or not db or not db.enabled or IsUnitInCombat("player") then return end
if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)>0 then return end
local id=db.lastComp
if id and id>0 and GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION)==0 then UseCollectible(id) end
end

local function GetNextInOrder(currentId)
if not db then return nil end
local keys={"None","merchant","banker","decon","fence"}
local currentCat="None"
for cat,ids in pairs(asst) do for _,id in ipairs(ids) do if id==currentId then currentCat=cat break end end end
local currentPos=0
for i=1,4 do if keys[db.order[i]]==currentCat then currentPos=i break end end
local nextPos=currentPos+1
if nextPos>4 then return nil end
local nextCatIdx=db.order[nextPos]
if nextCatIdx<=1 then return nil end
return db.selected[keys[nextCatIdx]]
end

function HyboremAssistant_Rotation(forceNextId)
if not db or IsUnitInCombat("player") then _inRot=false return end
if forceNextId and forceNextId>0 then 
_inRot=true
UseCollectible(forceNextId) 
else 
_inRot=false
local activeId=GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
if activeId>0 then UseCollectible(activeId) end
end
end

local function OnChatEnd()
local activeAsstId=GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
if activeAsstId>0 then
local nextId=GetNextInOrder(activeAsstId)
_inRot=true
zo_callLater(function() HyboremAssistant_Rotation(nextId) end,600)
end
end

local function OnUnitDestroyed()
zo_callLater(function()
if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)==0 then
if not _inRot then SummonComp() end
end
end,1100)
end

function HyboremAssistant_OnLoad(_,n)
if n~=_n then return end
local def={enabled=true,selected={merchant=0,banker=0,decon=0,fence=0},order={1,1,1,1},lastComp=0}
db=LibSavedVars:NewAccountWide("HyboremAssistant_DB", 1, def)
EVENT_MANAGER:RegisterForEvent(_n,EVENT_COMPANION_ACTIVATED,function(_,id) if not _inRot then db.lastComp=GetCompanionCollectibleId(id) end end)
EVENT_MANAGER:RegisterForEvent(_n,EVENT_CHATTER_END,OnChatEnd)
EVENT_MANAGER:RegisterForEvent(_n,EVENT_UNIT_DESTROYED,OnUnitDestroyed)
EVENT_MANAGER:RegisterForEvent(_n,EVENT_PLAYER_ACTIVATED,OnUnitDestroyed)
EVENT_MANAGER:RegisterForEvent(_n,EVENT_PLAYER_COMBAT_STATE,function(_,inCombat) if inCombat then _inRot=false end OnUnitDestroyed() end)
local LAM=LibAddonMenu2
if not LAM then return end
local mN,mI=GetUnlocked("merchant")
local bN,bI=GetUnlocked("banker")
local dN,dI=GetUnlocked("decon")
local fN,fI=GetUnlocked("fence")
local ch={"None","Merchant","Banker","Deconstructor","Fence"}
local opts={{type="checkbox",name="Enable Auto-Companion",getFunc=function()return db.enabled end,setFunc=function(v)db.enabled=v end},{type="header",name="|c00FF001. Selection|r"},{type="dropdown",name="Merchant",choices=mN,getFunc=function()for n,id in pairs(mI) do if id==db.selected.merchant then return n end end return "None" end,setFunc=function(v)db.selected.merchant=mI[v] end},{type="dropdown",name="Banker",choices=bN,getFunc=function()for n,id in pairs(bI) do if id==db.selected.banker then return n end end return "None" end,setFunc=function(v)db.selected.banker=bI[v] end},{type="dropdown",name="Deconstructor",choices=dN,getFunc=function()for n,id in pairs(dI) do if id==db.selected.decon then return n end end return "None" end,setFunc=function(v)db.selected.decon=dI[v] end},{type="dropdown",name="Fence",choices=fN,getFunc=function()for n,id in pairs(fI) do if id==db.selected.fence then return n end end return "None" end,setFunc=function(v)db.selected.fence=fI[v] end},{type="header",name="|c00FF002. Rotation Order|r"}}
for i=1,4 do table.insert(opts,{type="dropdown",name="Pos "..i,choices=ch,getFunc=function()return ch[db.order[i]] or "None" end,setFunc=function(v)for k,c in ipairs(ch) do if c==v then db.order[i]=k end end end}) end
LAM:RegisterAddonPanel(_n.."Panel", {type="panel", name="Hyborem Assistant Rotation", author="Hyborem & Gemini"})
LAM:RegisterOptionControls(_n.."Panel", opts)
end
EVENT_MANAGER:RegisterForEvent(_n, EVENT_ADD_ON_LOADED, HyboremAssistant_OnLoad)