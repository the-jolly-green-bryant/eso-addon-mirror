local EPC = ESOProgressionCoach
EPC.ChampionOptimizer = EPC.ChampionOptimizer or {}
local C = EPC.ChampionOptimizer

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok,a,b,c,d,e = pcall(fn,...)
    if not ok then return fallback end
    return a,b,c,d,e
end
local function num(fn, fallback, ...)
    local v=safe(fn,fallback,...); return tonumber(v) or fallback
end
local function lower(s) return string.lower(tostring(s or "")) end
local function has(text, words)
    text=lower(text)
    for _,w in ipairs(words or {}) do if string.find(text,w,1,true) then return true end end
    return false
end

local LABELS={}
local function disciplineLabel(t)
    if t==rawget(_G,"CHAMPION_DISCIPLINE_TYPE_WORLD") then return "CRAFT" end
    if t==rawget(_G,"CHAMPION_DISCIPLINE_TYPE_COMBAT") then return "WARFARE" end
    if t==rawget(_G,"CHAMPION_DISCIPLINE_TYPE_CONDITIONING") then return "FITNESS" end
    return "CHAMPION"
end

function C:GetContext()
    local profile=EPC.GearOptimizer and EPC.GearOptimizer.GetProfile and EPC.GearOptimizer:GetProfile() or {}
    local plan=EPC.GearOptimizer and EPC.GearOptimizer.BuildFullSkillPlan and EPC.GearOptimizer:BuildFullSkillPlan() or nil
    local role=plan and plan.context and plan.context.role or "DAMAGE"
    return { profile=profile or {}, role=tostring(role or "DAMAGE") }
end

function C:ScoreSkill(node, context)
    local name=lower(node.name); local desc=lower(node.desc); local text=name.." "..desc
    local score=0
    local label=disciplineLabel(node.disciplineType)
    local role=lower(context.role)
    local magicka=context.profile and context.profile.magicka==true

    if node.isRoot then score=score+35 end
    if node.slottable then score=score+120 end

    if label=="WARFARE" then
        if has(text,{"critical damage","critical healing","critical chance"}) then score=score+240 end
        if has(text,{"damage done","direct damage","damage over time","single target","area of effect"}) then score=score+210 end
        if magicka and has(text,{"magicka","spell"}) then score=score+95 end
        if (not magicka) and has(text,{"stamina","weapon"}) then score=score+95 end
        if role=="healer" then
            if has(text,{"healing done","healing received","heal","restoration"}) then score=score+330 end
            if has(text,{"damage done","direct damage"}) then score=score-80 end
        elseif role=="tank" then
            if has(text,{"damage taken","block","resistance","shield","mitigation"}) then score=score+320 end
            if has(text,{"healing received"}) then score=score+120 end
        else
            if has(text,{"damage done","critical damage","direct damage","damage over time","single target","area of effect"}) then score=score+180 end
        end
    elseif label=="FITNESS" then
        if has(text,{"max health","health","armor","resistance","damage taken"}) then score=score+150 end
        if has(text,{"movement speed","sprint","roll dodge","break free","block","recovery"}) then score=score+135 end
        if role=="tank" and has(text,{"block","health","resistance","damage taken","shield"}) then score=score+260 end
        if role=="healer" and has(text,{"magicka","recovery","health"}) then score=score+120 end
        if role=="damage" and has(text,{"movement speed","stamina","magicka","recovery"}) then score=score+100 end
    elseif label=="CRAFT" then
        if has(text,{"movement speed","out of combat","mount","riding"}) then score=score+210 end
        if has(text,{"gold","treasure","chest","loot","harvest","resource","gather"}) then score=score+190 end
        if has(text,{"craft","inspiration","research","deconstruct","refine","repair"}) then score=score+145 end
        if has(text,{"fall damage","stealth","pickpocket"}) then score=score+55 end
    end
    return score
end

function C:CollectNodes()
    local nodes,byId={},{}
    local count=num(GetNumChampionDisciplines,0)
    for di=1,count do
        local disciplineId=num(GetChampionDisciplineId,0,di)
        local dtype=safe(GetChampionDisciplineType,nil,disciplineId)
        local nskills=num(GetNumChampionDisciplineSkills,0,di)
        for si=1,nskills do
            local id=num(GetChampionSkillId,0,di,si)
            if id>0 then
                local maxp=num(GetChampionSkillMaxPoints,0,id)
                local minUnlock=maxp>0 and maxp or 0
                if maxp>0 and type(WouldChampionSkillNodeBeUnlocked)=="function" then
                    for p=0,maxp do if safe(WouldChampionSkillNodeBeUnlocked,false,id,p)==true then minUnlock=p break end end
                    if minUnlock==0 and not safe(IsChampionSkillRootNode,false,id) then minUnlock=1 end
                end
                local st=safe(GetChampionSkillType,nil,id)
                local slottable=type(CanChampionSkillTypeBeSlotted)=="function" and safe(CanChampionSkillTypeBeSlotted,false,st)==true
                local node={id=id,disciplineIndex=di,disciplineId=disciplineId,disciplineType=dtype,name=tostring(safe(GetChampionSkillName,"Champion Star",id) or "Champion Star"),desc=tostring(safe(GetChampionSkillDescription,"",id,math.max(1,minUnlock)) or ""),maxPoints=maxp,minUnlock=minUnlock,isRoot=safe(IsChampionSkillRootNode,false,id)==true,slottable=slottable,links={},saved=num(GetNumPointsSpentOnChampionSkill,0,id)}
                nodes[#nodes+1]=node; byId[id]=node
            end
        end
    end
    for _,node in ipairs(nodes) do
        if type(GetChampionSkillLinkIds)=="function" then
            local vals={GetChampionSkillLinkIds(node.id)}
            for _,v in ipairs(vals) do if tonumber(v) and byId[tonumber(v)] then node.links[#node.links+1]=tonumber(v) end end
        end
    end
    return nodes,byId
end

local function pathToRoot(target, byId)
    if target.isRoot then return {target} end
    local q, seen = {{target.id}}, {[target.id]=true}
    while #q>0 do
        local path=table.remove(q,1); local node=byId[path[#path]]
        if node then
            for _,lid in ipairs(node.links or {}) do
                if not seen[lid] then
                    seen[lid]=true; local np={}; for i,v in ipairs(path) do np[i]=v end; np[#np+1]=lid
                    local ln=byId[lid]
                    if ln and ln.isRoot then
                        local out={}; for i=#np,1,-1 do out[#out+1]=byId[np[i]] end; return out
                    end
                    q[#q+1]=np
                end
            end
        end
    end
    return {target}
end

function C:BuildPlan()
    local context=self:GetContext(); local nodes,byId=self:CollectNodes(); local plan={context=context,nodes=nodes,byId=byId,pools={},targets={},slotted={}}
    for _,node in ipairs(nodes) do
        local p=plan.pools[node.disciplineId]
        if not p then
            p={disciplineId=node.disciplineId,disciplineType=node.disciplineType,label=disciplineLabel(node.disciplineType),budget=num(GetNumSpentChampionPoints,0,node.disciplineId)+num(GetNumUnspentChampionPoints,0,node.disciplineId),spent=0,alloc={},ranked={}}
            plan.pools[node.disciplineId]=p
        end
        node.score=self:ScoreSkill(node,context); p.ranked[#p.ranked+1]=node
    end
    for _,p in pairs(plan.pools) do
        table.sort(p.ranked,function(a,b) if a.score==b.score then return a.name<b.name end return a.score>b.score end)
        for _,target in ipairs(p.ranked) do
            if p.spent>=p.budget then break end
            if target.score>0 then
                local path=pathToRoot(target,byId)
                local needed=0
                for _,n in ipairs(path) do local want=math.max(0,n.minUnlock or 0); needed=needed+math.max(0,want-(p.alloc[n.id] or 0)) end
                if p.spent+needed<=p.budget then
                    for _,n in ipairs(path) do local want=math.max(0,n.minUnlock or 0); local old=p.alloc[n.id] or 0; if want>old then p.alloc[n.id]=want; p.spent=p.spent+(want-old) end end
                    local room=p.budget-p.spent
                    local cur=p.alloc[target.id] or 0; local add=math.min(room,math.max(0,target.maxPoints-cur))
                    if add>0 then p.alloc[target.id]=cur+add; p.spent=p.spent+add end
                end
            end
        end
        -- If points remain, fill highest-scoring already connected nodes to cap.
        for _,n in ipairs(p.ranked) do
            if p.spent>=p.budget then break end
            if (p.alloc[n.id] or 0)>0 then local add=math.min(p.budget-p.spent,math.max(0,n.maxPoints-(p.alloc[n.id] or 0))); p.alloc[n.id]=(p.alloc[n.id] or 0)+add; p.spent=p.spent+add end
        end
        local slots={}
        for _,n in ipairs(p.ranked) do if n.slottable and (p.alloc[n.id] or 0)>0 then slots[#slots+1]=n end end
        p.slots=slots
    end
    return plan
end

function C:BuildView()
    local plan=self:BuildPlan(); local view={cost=num(GetChampionRespecCost,0),pools={},context=plan.context}
    for _,p in pairs(plan.pools) do
        local row={label=p.label,budget=p.budget,spent=p.spent,top={}}
        for _,n in ipairs(p.ranked) do if (p.alloc[n.id] or 0)>0 and #row.top<6 then row.top[#row.top+1]={name=n.name,points=p.alloc[n.id],slottable=n.slottable} end end
        view.pools[#view.pools+1]=row
    end
    table.sort(view.pools,function(a,b) local o={CRAFT=1,WARFARE=2,FITNESS=3}; return (o[a.label] or 9)<(o[b.label] or 9) end)
    return view
end

function C:Notify(msg,good)
    if EPC.GearOptimizer and EPC.GearOptimizer.NotifyResult then EPC.GearOptimizer:NotifyResult(msg,good) elseif d then d("[ESO Adventurer Suite] "..msg) end
end

function C:ApplyBestChampionBuild()
    if self.Initialize then self:Initialize() end
    if safe(IsUnitInCombat,false,"player")==true then self:Notify("CHAMPION: leave combat before redistributing points.",false) return false end
    if type(IsChampionSystemUnlocked)=="function" and not safe(IsChampionSystemUnlocked,false) then self:Notify("CHAMPION: Champion progression is not unlocked yet.",false) return false end
    if type(PrepareChampionPurchaseRequest)~="function" or type(AddSkillToChampionPurchaseRequest)~="function" or type(SendChampionPurchaseRequest)~="function" then self:Notify("CHAMPION: this ESO client does not expose the Champion allocation API.",false) return false end
    local cost=num(GetChampionRespecCost,0); local now=num(GetFrameTimeMilliseconds,0)
    if cost>0 and (not self._confirmUntil or now>self._confirmUntil) then self._confirmUntil=now+8000; self:Notify(string.format("REDISTRIBUTE CP costs %d gold. Click REDISTRIBUTE CP again within 8 seconds to confirm.",cost),false); return false end
    self._confirmUntil=nil
    local plan=self:BuildPlan()
    local ok=pcall(PrepareChampionPurchaseRequest,true); if not ok then self:Notify("CHAMPION: ESO would not start a Champion respec request here.",false) return false end
    -- A true respec request must describe the complete target state.
    -- Send every node, including zero-point targets, so old allocations are removed
    -- instead of only adding the new recommendations on top of them.
    for _,node in ipairs(plan.nodes) do
        local pool=plan.pools[node.disciplineId]
        local target=pool and (pool.alloc[node.id] or 0) or 0
        pcall(AddSkillToChampionPurchaseRequest,node.id,target)
    end
    if type(AddHotbarSlotToChampionPurchaseRequest)=="function" and HOTBAR_CATEGORY_CHAMPION~=nil then
        local startSlot,endSlot=1,12
        if type(GetAssignableChampionBarStartAndEndSlots)=="function" then local a,b=safe(GetAssignableChampionBarStartAndEndSlots,nil); startSlot=tonumber(a) or startSlot; endSlot=tonumber(b) or endSlot end
        local nextByDiscipline={}
        for slot=startSlot,endSlot do
            local reqId=type(GetRequiredChampionDisciplineIdForSlot)=="function" and num(GetRequiredChampionDisciplineIdForSlot,0,slot,HOTBAR_CATEGORY_CHAMPION) or 0
            local p=plan.pools[reqId]
            if p then
                nextByDiscipline[reqId]=(nextByDiscipline[reqId] or 0)+1
                local n=p.slots[nextByDiscipline[reqId]]
                pcall(AddHotbarSlotToChampionPurchaseRequest,slot,n and n.id or 0)
            else
                pcall(AddHotbarSlotToChampionPurchaseRequest,slot,0)
            end
        end
    end
    local expected=type(GetExpectedResultForChampionPurchaseRequest)=="function" and safe(GetExpectedResultForChampionPurchaseRequest,nil) or nil
    local successConst=rawget(_G,"CHAMPION_PURCHASE_SUCCESS")
    if expected~=nil and successConst~=nil and expected~=successConst then self:Notify("CHAMPION: ESO reports the planned Champion allocation is not currently valid (result "..tostring(expected)..").",false) return false end
    local sent=pcall(SendChampionPurchaseRequest)
    if not sent then self:Notify("CHAMPION: ESO rejected the Champion respec request.",false) return false end
    self:Notify(string.format("CHAMPION: best-build redistribution submitted for Craft, Warfare, and Fitness. Respec cost: %d gold.",cost),true)
    if EPC.RequestRefresh then EPC:RequestRefresh("champion-respec") end
    return true
end

function C:Initialize()
    if self._eventReady or not EVENT_MANAGER or not EVENT_CHAMPION_PURCHASE_RESULT then return end
    self._eventReady=true
    EVENT_MANAGER:RegisterForEvent("ESOAdventurerSuite_ChampionOptimizer", EVENT_CHAMPION_PURCHASE_RESULT, function(_, result)
        local success=rawget(_G,"CHAMPION_PURCHASE_SUCCESS")
        if success~=nil and result==success then
            C:Notify("CHAMPION: redistribution completed. Craft, Warfare, and Fitness were rebuilt.",true)
        else
            C:Notify("CHAMPION: ESO rejected the redistribution (result "..tostring(result).."). No success was reported.",false)
        end
        if EPC.RequestRefresh then EPC:RequestRefresh("champion-purchase-result") end
    end)
end
