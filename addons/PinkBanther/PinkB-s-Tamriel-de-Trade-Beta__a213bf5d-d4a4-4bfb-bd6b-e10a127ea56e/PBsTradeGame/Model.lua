local M = {}; PBTrade.Model = M
local C, D = PBTrade.Config, PBTrade.Data
function M.Copy(value)
    if type(value) ~= "table" then return value end
    local copy = {}; for k,v in pairs(value) do copy[k] = M.Copy(v) end; return copy
end
function M.New()
    local s = {schemaVersion=C.schemaVersion, cash=C.campaign.startingCash, properties={},
        companies=M.Copy(D.companies),
        visited={}, visitedProperties={}, unlocked={}, learnedTactics={smile=true}, learnedGroups={}, alliances={},
        wins=0, losses=0, defensesWon=0, defensesLost=0, chapter=1, reputation=50,
        cycles=0,debt=0,rebuilds=0,campaignComplete=false}
    for _, p in ipairs(D.properties) do
        s.properties[p.id] = M.Copy(p)
        s.properties[p.id].reserve = p.expectedProfit * C.battle.reserveProfitFactor
    end
    M.Unlock(s); return s
end
function M.HasOwnedCategory(s,category)
    for _,p in ipairs(M.Owned(s)) do if p.category==category then return true end end
    return false
end
function M.Owned(s, owner)
    local result = {}
    for _, p in ipairs(D.properties) do
        if s.properties[p.id].owner == (owner or C.playerId) then result[#result+1] = s.properties[p.id] end
    end
    return result
end
function M.IsAvailable(s,p)
    local company=s.companies[p.owner]
    return (p.minChapter or (company and company.minChapter) or 1)<=s.chapter
end
function M.IsPropertyVisited(s,p)
    return not p.canonical or p.requiresVisit==false or s.visitedProperties[p.id]==true
end
function M.Assets(s)
    local total = s.cash
    for _, p in ipairs(M.Owned(s)) do total = total + p.marketValue end
    return total
end
function M.Unlock(s)
    local tier = math.floor(math.max(0, #M.Owned(s)-2) / C.campaign.unlockOwnedStep)
    for _, z in ipairs(D.zones) do
        if (z.minChapter or 1)<=s.chapter and z.unlockTier<=tier then s.unlocked[z.id]=true end
    end
end
function M.RiskLabel(risk)
    if risk >= 128 then return "離反", "888888" end
    if risk >= 90 then return "危険", "ff8585" end
    if risk >= 55 then return "警戒", "ffc46b" end
    if risk >= 25 then return "注意", "eee193" end
    return "安定", "94d3b0"
end
function M.ZoneSummary(s, id)
    local counts = {own=0, enemy=0, neutral=0}
    for _, propertyId in ipairs(D.propertyIdsByZone[id] or {}) do
        local p=s.properties[propertyId]
        if M.IsAvailable(s,p) then
            local key = p.owner == C.playerId and "own" or (p.owner == C.neutralId and "neutral" or "enemy")
            counts[key] = counts[key]+1
        end
    end
    return counts
end
function M.Rankings(s)
    local rows,byId={},{}
    for id,company in pairs(s.companies) do
        if id~=C.neutralId and (company.minChapter or 1)<=s.chapter then
            local cash=id==C.playerId and s.cash or company.cash
            local row={id=id,name=company.name,cash=cash,reserves=0,assets=cash,propertyCount=0}
            rows[#rows+1]=row; byId[id]=row
        end
    end
    for _,p in pairs(s.properties) do
        local row=byId[p.owner]
        if row then
            row.reserves=row.reserves+p.reserve; row.assets=row.assets+p.marketValue; row.propertyCount=row.propertyCount+1
        end
    end
    for _,row in ipairs(rows) do row.fundingPower=row.cash+row.reserves end
    table.sort(rows,function(a,b)
        if a.fundingPower~=b.fundingPower then return a.fundingPower>b.fundingPower end
        if a.assets~=b.assets then return a.assets>b.assets end
        return a.id<b.id
    end)
    for i,row in ipairs(rows) do row.rank=i end
    return rows
end
function M.GroupMembers(s,id,owner)
    local result={}
    for _,p in ipairs(D.properties) do
        local state=s.properties[p.id]
        if state.owner==(owner or C.playerId) and M.IsAvailable(s,state) then
            for _,groupId in ipairs(state.groups) do
                if groupId==id then result[#result+1]=state; break end
            end
        end
    end
    return result
end
function M.GroupStatus(s,id)
    local group=D.groups[id]; if not group then return nil end
    local members=M.GroupMembers(s,id)
    return {id=id,name=group.name,members=members,count=#members,minimum=group.minimum,
        learned=s.learnedGroups[id] or false,usable=s.learnedGroups[id] and #members>=group.minimum,
        bonus=group.bonus,discoveryChance=group.discoveryChance}
end
function M.AvailableGroups(s)
    local rows={}
    for id in pairs(D.groups) do local status=M.GroupStatus(s,id); if status.usable then rows[#rows+1]=status end end
    table.sort(rows,function(a,b) return a.name<b.name end); return rows
end
function M.CampaignStatus(s)
    local chapter=D.campaigns[s.chapter]; if not chapter then return nil end
    local objective=chapter.objective; local current,target,complete
    if objective.type=="assets" then
        current=M.Assets(s); target=objective.target; complete=current>=target
    else
        current=0; target=#objective.targets
        for _,id in ipairs(objective.targets) do if s.properties[id].owner==C.playerId then current=current+1 end end
        complete=current>=target
    end
    return {chapter=chapter,current=current,target=target,complete=complete}
end
function M.AdvanceCampaign(s)
    local status=M.CampaignStatus(s)
    if status and status.complete and s.chapter<#D.campaigns then s.chapter=s.chapter+1; M.Unlock(s); return D.campaigns[s.chapter] end
    if status and status.complete and s.chapter==#D.campaigns and not s.campaignComplete then
        s.campaignComplete=true; return {ending=true,title="交易戦終結",background="chapter_5"}
    end
end
function M.FundingPower(s)
    local total=s.cash; for _,p in ipairs(M.Owned(s)) do total=total+p.reserve end; return total
end
function M.CanRebuild(s) return M.FundingPower(s)<C.economy.rebuildThreshold end
function M.Rebuild(s)
    if not M.CanRebuild(s) then return false,"再建融資が必要な状態ではありません" end
    s.cash=s.cash+C.economy.rebuildGrant; s.debt=s.debt+C.economy.rebuildGrant
    s.reputation=math.max(0,s.reputation-C.economy.rebuildReputationCost); s.rebuilds=s.rebuilds+1
    return true,C.economy.rebuildGrant
end
function M.SettleCycle(s)
    local gross,recovered=0,0
    for _,p in pairs(s.properties) do
        if p.owner==C.playerId then
            gross=gross+math.floor(p.expectedProfit*C.economy.profitShare)
            local cap=p.expectedProfit*C.battle.reserveProfitFactor
            local before=p.reserve; p.reserve=math.min(cap,p.reserve+p.expectedProfit*C.economy.reserveRecoveryPeriods)
            recovered=recovered+(p.reserve-before)
        elseif p.owner~=C.neutralId and s.companies[p.owner] then
            s.companies[p.owner].cash=s.companies[p.owner].cash+math.floor(p.expectedProfit*C.economy.enemyProfitShare)
        end
    end
    local debtPayment=math.min(s.debt,math.floor(gross*C.economy.debtPaymentShare))
    s.debt=s.debt-debtPayment; s.cash=s.cash+gross-debtPayment; s.cycles=s.cycles+1
    return {gross=gross,debtPayment=debtPayment,net=gross-debtPayment,reserveRecovered=recovered,cycle=s.cycles}
end
local stateFields={"cash","wins","losses","defensesWon","defensesLost","chapter","reputation","cycles","debt","rebuilds","campaignComplete"}
function M.Export(s)
    local out={schemaVersion=C.schemaVersion,properties={},companies={},visited=M.Copy(s.visited),
        visitedProperties=M.Copy(s.visitedProperties),unlocked=M.Copy(s.unlocked),
        learnedTactics=M.Copy(s.learnedTactics),learnedGroups=M.Copy(s.learnedGroups),alliances=M.Copy(s.alliances),canonicalProperties={}}
    for _,key in ipairs(stateFields) do out[key]=s[key] end
    for id,p in pairs(s.properties) do
        out.properties[id]={owner=p.owner,independenceRisk=p.independenceRisk,reserve=p.reserve}
        if p.canonical then
            local definition=M.Copy(p); definition.reserve=nil; out.canonicalProperties[id]=definition
        end
    end
    for id,company in pairs(s.companies) do out.companies[id]={cash=company.cash} end
    return out
end
function M.Load(saved)
    if type(saved)~="table" then return M.New() end
    for id,p in pairs(saved.canonicalProperties or {}) do
        if not D.propertyById[id] and D.zoneById[p.zone] then local definition=M.Copy(p); D.properties[#D.properties+1]=definition; D.AddProperty(definition) end
    end
    local s=M.New()
    for _,key in ipairs(stateFields) do if saved[key]~=nil then s[key]=saved[key] end end
    for id,record in pairs(saved.properties or {}) do
        local p=s.properties[id]; if p then
            if record.owner and s.companies[record.owner] then p.owner=record.owner end
            if type(record.independenceRisk)=="number" then p.independenceRisk=math.max(0,math.min(C.battle.riskMax,record.independenceRisk)) end
            if type(record.reserve)=="number" then p.reserve=math.max(0,record.reserve) end
        end
    end
    for id,record in pairs(saved.companies or {}) do if s.companies[id] and type(record.cash)=="number" then s.companies[id].cash=math.max(0,record.cash) end end
    for _,key in ipairs({"visited","visitedProperties","unlocked","learnedTactics","learnedGroups","alliances"}) do if type(saved[key])=="table" then s[key]=M.Copy(saved[key]) end end
    s.learnedTactics.smile=true; s.schemaVersion=C.schemaVersion; M.Unlock(s); return s
end
-- One decision per offensive battle cycle. Defense settlement does not recurse.
function M.RollCounterattack(s,random)
    local owned=M.Owned(s)
    if #owned==0 then return nil,"防衛対象の物件がありません" end
    local candidates,total={},0
    -- Sort IDs so the same RNG sequence is deterministic on Lua implementations.
    local ids={}; for id in pairs(s.companies) do ids[#ids+1]=id end; table.sort(ids)
    for _,id in ipairs(ids) do
        local c=s.companies[id]
        if id~=C.playerId and id~=C.neutralId and (c.minChapter or 1)<=s.chapter and c.cash>=C.counterattack.minimumCash and #M.Owned(s,id)>0 then
            local weight=c.aggression or .5; total=total+weight
            candidates[#candidates+1]={id=id,company=c,weight=weight}
        end
    end
    if total<=0 then return nil,"敵商会は攻撃資金を準備できませんでした" end
    local pick=random()*total; local selected=candidates[#candidates]
    for _,candidate in ipairs(candidates) do pick=pick-candidate.weight; if pick<0 then selected=candidate; break end end
    local chance=math.min(C.counterattack.maxChance,C.counterattack.baseChance+(selected.company.aggression or .5)*C.counterattack.aggressionWeight)
    if random()>=chance then return nil,"今回は敵商会からの買収攻撃はありませんでした" end
    local source
    for _,p in ipairs(M.Owned(s,selected.id)) do
        if not source or (p.isHeadquarters and not source.isHeadquarters)
            or (p.isHeadquarters==source.isHeadquarters and p.marketValue>source.marketValue) then source=p end
    end
    local best,score
    for _,p in ipairs(owned) do
        local value=random()+p.independenceRisk/C.battle.riskMax*C.counterattack.riskWeight
        if p.category==selected.company.acquisitionBias then value=value+selected.weight end
        if p.isHeadquarters then value=value+C.counterattack.headquartersWeight end
        if not score or value>score then best,score=p,value end
    end
    return {companyId=selected.id,propertyId=best.id,sourcePropertyId=source.id,chance=chance},selected.company.name.."が"..best.name.."への買収を仕掛けました"
end
