-- Pure Lua: no ESO calls, no wall clock. Inject RNG for repeatable tests.
local E = {}; E.__index=E; PBTrade.Engine=E
local C, M, D = PBTrade.Config, PBTrade.Model, PBTrade.Data
local B = C.battle
local function clamp(v,lo,hi) return math.max(lo,math.min(hi,v)) end
local profiles={
    steady={opening=1,budget=1,bid=1,wait=1,react=.20}, wealth={opening=1.15,budget=1.35,bid=1.25,wait=1.12,react=.18},
    aggressive={opening=1.30,budget=1.05,bid=1.08,wait=.72,react=.42}, information={opening=.85,budget=1.0,bid=.88,wait=.92,react=.72},
    subversion={opening=1.0,budget=1.12,bid=.96,wait=.82,react=.58}, dominion={opening=1.35,budget=1.55,bid=1.30,wait=.68,react=.85},
}
function E.New(state, rng)
    return setmetatable({state=state, random=rng or math.random, accumulator=0},E)
end
function E:Log(message)
    local log=self.battle.log; log[#log+1]=message
    while #log>B.logLimit do table.remove(log,1) end
end
function E:Start(id, attacker)
    if self.battle and not self.battle.result then return false,"買収交渉が進行中です" end
    local p=self.state.properties[id]
    if not p then return false,"物件が見つかりません" end
    if not M.IsAvailable(self.state,p) then return false,"この章では交易路が存在しません" end
    if not self.state.unlocked[p.zone] then return false,"まだ交易路が開いていません" end
    if not attacker and not M.IsPropertyVisited(self.state,p) then return false,"ESO内でこの場所を訪問すると買収できます" end
    if attacker then
        if p.owner~=C.playerId then return false,"防衛できる自社物件ではありません" end
        if attacker==C.playerId or attacker==C.neutralId or not self.state.companies[attacker] then return false,"攻撃商会が不正です" end
    elseif p.owner==C.playerId then return false,"すでに自社所有です" end
    local opponent=attacker or p.owner
    local company=self.state.companies[opponent]; local profile=profiles[(company and company.personality) or "steady"] or profiles.steady
    local defense=attacker and ((company and company.defense) or .5) or 0
    local opening=math.floor(p.marketValue*B.openingEnemyBidFactor*profile.opening*(1+defense*.25))
    local budget=math.floor(p.marketValue*B.enemyBudgetFactor*profile.budget*(1+defense*.20))
    if opponent~=C.neutralId then
        local company=self.state.companies[opponent]
        opening=math.min(opening,company.cash)
        budget=math.min(budget,company.cash-opening)
        company.cash=company.cash-opening
    end
    self.accumulator=0
    self.battle={targetId=id, defender=opponent, mode=attacker and "defense" or "acquisition", gauge=B.initialGauge, velocity=0, acceleration=0,
        playerWait=0, enemyWait=B.enemyOpeningWait, elapsed=0, playerBid=0,
        enemyBid=opening, enemyBudget=budget,
        momentum=0, requests={}, log={}, treasurySpent=0, baseValue=p.marketValue,effectiveValue=p.marketValue,
        effects={},delayedEffects={},learnedTactics={}}
    self.battle.aiProfile=profile; self.battle.aiStyle=(company and company.personality) or "steady"
    self:Log(attacker and "防衛開始。境目を左端まで押せば防衛成功、右端で物件喪失。" or "交渉開始。境目を左端まで押せば買収成立。")
    return true
end
function E:AddEffect(kind,amount,duration)
    local effects=self.battle.effects
    effects[#effects+1]={type=kind,amount=amount,remaining=duration}
    while #effects>C.tactics.effectLimit do table.remove(effects,1) end
end
function E:EffectTotal(kind,default)
    local value=default or 0
    for _,effect in ipairs(self.battle.effects) do
        if effect.type==kind then
            if kind=="playerWaitMultiplier" or kind=="valueMultiplier" then value=value*effect.amount else value=value+effect.amount end
        end
    end
    return value
end
function E:PlayerWaitDuration() return B.playerWait*self:EffectTotal("playerWaitMultiplier",1) end
function E:TacticResistance(tactic,target)
    return clamp(target and target.negotiationResistances and (target.negotiationResistances[tactic.resistanceKey] or 0) or 0,0,1)
end
function E:UseTactic(id)
    if not self:Ready() then return false,"伝令の帰還を待ってください" end
    local tactic=D.tacticById[id]
    if not tactic or not self.state.learnedTactics[id] then return false,"まだ習得していない駆け引きです" end
    if self.state.cash<tactic.cost then return false,"商会資金が不足しています" end
    local effect=tactic.effect; local target=self.state.properties[self.battle.targetId]
    local ownTarget
    if effect.type=="ownRisk" then
        for _,p in ipairs(M.Owned(self.state)) do if not ownTarget or p.independenceRisk>ownTarget.independenceRisk then ownTarget=p end end
        if not ownTarget then return false,"対象となる自社物件がありません" end
    elseif effect.type=="enemyRisk" and target.owner==C.neutralId then return false,"中立物件には離反工作が効きません" end
    self.state.cash=self.state.cash-tactic.cost; self.battle.treasurySpent=self.battle.treasurySpent+tactic.cost
    local resistance=self:TacticResistance(tactic,effect.type=="ownRisk" and ownTarget or target)
    local power=1-resistance; local amount=(effect.amount or 0)*power
    local direction,defected
    if power<=0 then self:Log(tactic.name.."は無効でした")
    elseif effect.type=="playerAcceleration" or effect.type=="enemyAccelerationPenalty" then self:AddEffect(effect.type,amount,effect.duration)
    elseif effect.type=="velocity" then self.battle.velocity=clamp(self.battle.velocity+amount,-B.maxVelocity,B.maxVelocity)
    elseif effect.type=="randomVelocity" then
        direction=self.random()<.55 and -1 or 1; self.battle.velocity=clamp(self.battle.velocity+direction*amount,-B.maxVelocity,B.maxVelocity)
    elseif effect.type=="playerWaitMultiplier" then self:AddEffect(effect.type,math.max(.1,1-(1-effect.amount)*power),effect.duration)
    elseif effect.type=="enemyWait" then self.battle.enemyWait=self.battle.enemyWait+amount
    elseif effect.type=="delayedAcceleration" then self.battle.delayedEffects[#self.battle.delayedEffects+1]={remaining=effect.delay,type="playerAcceleration",amount=amount,duration=effect.duration}
    elseif effect.type=="resetWaits" then self.battle.playerWait=B.playerWait; self.battle.enemyWait=B.enemyOpeningWait
    elseif effect.type=="valueMultiplier" then self:AddEffect(effect.type,1+(effect.amount-1)*power,effect.duration)
    elseif effect.type=="enemyRisk" then target.independenceRisk=clamp(target.independenceRisk+amount,0,B.riskMax-1); defected=self:CheckDefection(target)
    elseif effect.type=="ownRisk" then ownTarget.independenceRisk=clamp(ownTarget.independenceRisk+amount,0,B.riskMax-1) end
    if power>0 then self:Log(tactic.name.."を実行") end
    if effect.type~="resetWaits" then self.battle.playerWait=self:PlayerWaitDuration() end
    -- The outcome feeds the tactic cut-in: power, applied amount and any swing or defection.
    return true,{tactic=tactic,resistance=resistance,target=ownTarget or target,
        power=math.max(0,power),amount=amount,direction=direction,targetDefected=defected}
end
function E:TryLearnTactics(result)
    local learned={}; local defense=self.battle.mode=="defense"
    for _,tactic in ipairs(D.tactics) do
        local rule=tactic.learn
        if not self.state.learnedTactics[tactic.id] and not rule.starting then
            local eligible=(not rule.result or rule.result==result or (rule.result=="lost" and result~="won"))
                and (not rule.defense or defense) and (not rule.category or M.HasOwnedCategory(self.state,rule.category))
            if eligible and self.random()<(rule.chance or 0) then
                self.state.learnedTactics[tactic.id]=true; learned[#learned+1]=tactic.id
                self:Log(tactic.name.."を習得した！")
            end
        end
    end
    self.battle.learnedTactics=learned
end
function E:DefectionChance(p)
    return clamp((p.independenceRisk-C.independence.safeThreshold)*C.independence.chancePerPoint,0,C.independence.maxChance)
end
function E:CheckDefection(p)
    local chance=self:DefectionChance(p)
    if chance>0 and self.random()<chance then
        p.owner=C.neutralId; p.independenceRisk=B.riskMax
        self:Log(p.name.."が離反しました")
        return true
    end
    return false
end
function E:DiscoverGroup(p)
    local found={}
    for _,id in ipairs(p.groups) do
        local group=PBTrade.Data.groups[id]
        if group and not self.state.learnedGroups[id] and self.random()<(group.discoveryChance or 0) then
            self.state.learnedGroups[id]=true; found[#found+1]=id
            self:Log(group.name.."を閃いた！")
            if #found>=C.groups.maxDiscoveriesPerRequest then break end
        end
    end
    return found
end
function E:Ready()
    return self.battle and not self.battle.result and self.battle.playerWait<=0
end
function E:Quote(id)
    local p=self.state.properties[id]
    if not p or p.owner~=C.playerId then return 0 end
    local count=self.battle and self.battle.requests[id] or 0
    local base=p.expectedProfit*B.fundingProfitFactor+p.marketValue*B.fundingValueFactor
    return math.floor(math.min(p.reserve,base/(1+(count or 0)*B.fatiguePerRequest)))
end
function E:Fund(amount, acceleration)
    local b=self.battle
    b.playerBid=b.playerBid+amount
    b.momentum=clamp(b.momentum+acceleration*B.momentumPerFunding,0,B.maxMomentum)
    b.playerWait=self:PlayerWaitDuration()
end
function E:Request(id)
    if not self:Ready() then return false,"伝令の帰還を待ってください" end
    local amount=self:Quote(id)
    if amount<=0 then return false,"調達できる手元資金がありません" end
    local p=self.state.properties[id]
    p.reserve=p.reserve-amount
    p.independenceRisk=clamp(p.independenceRisk+p.independenceIncrease,0,B.riskMax-1)
    self.battle.requests[id]=(self.battle.requests[id] or 0)+1
    self:Fund(amount,p.gaugeAcceleration)
    self:Log(p.name.."  +"..amount.." / 負担 "..p.independenceRisk)
    local discoveries=self:DiscoverGroup(p); local defected=self:CheckDefection(p)
    return true,amount,{discoveries=discoveries,defected=defected,property=p}
end
function E:RequestGroup(id)
    if not self:Ready() then return false,"伝令の帰還を待ってください" end
    local status=M.GroupStatus(self.state,id)
    if not status or not status.learned then return false,"まだこの連合を閃いていません" end
    if not status.usable then return false,"系列物件が不足しています" end
    local base,acceleration,paid,defected=0,0,0,{}
    for _,p in ipairs(status.members) do
        local amount=self:Quote(p.id)
        if amount>0 then
            p.reserve=p.reserve-amount; p.independenceRisk=clamp(p.independenceRisk+p.independenceIncrease,0,B.riskMax-1)
            self.battle.requests[p.id]=(self.battle.requests[p.id] or 0)+1
            base=base+amount; acceleration=acceleration+p.gaugeAcceleration; paid=paid+1
            if self:CheckDefection(p) then defected[#defected+1]=p end
        end
    end
    if paid==0 then return false,"系列に調達余力がありません" end
    local amount=math.floor(base*status.bonus)
    self:Fund(amount,acceleration/paid+C.groups.accelerationBonus)
    self:Log(status.name.."  +"..amount.."（"..paid.."件）")
    return true,amount,{group=status,defected=defected}
end
function E:Stabilize()
    if not self:Ready() then return false,"伝令の帰還を待ってください" end
    if self.state.cash<C.independence.stabilizeCost then return false,"商会資金が不足しています" end
    local target
    for _,p in ipairs(M.Owned(self.state)) do if not target or p.independenceRisk>target.independenceRisk then target=p end end
    if not target or target.independenceRisk<=0 then return false,"根回しが必要な物件はありません" end
    self.state.cash=self.state.cash-C.independence.stabilizeCost
    target.independenceRisk=math.max(0,target.independenceRisk-C.independence.stabilizeAmount)
    self.battle.treasurySpent=self.battle.treasurySpent+C.independence.stabilizeCost
    self.battle.playerWait=B.playerWait; self:Log(target.name.."を安定化  -"..C.independence.stabilizeAmount)
    return true,target
end
function E:Treasury(amount)
    if not self:Ready() then return false,"伝令の帰還を待ってください" end
    -- Amounts come from the gap-based menu; any whole positive amount the treasury holds is valid.
    if type(amount)~="number" or amount~=amount or amount<=0 or amount==math.huge or amount~=math.floor(amount) then
        return false,"投入額が不正です" end
    if self.state.cash<amount then return false,"商会資金が不足しています" end
    self.state.cash=self.state.cash-amount
    self.battle.treasurySpent=self.battle.treasurySpent+amount
    self:Fund(amount,B.baseAcceleration)
    self:Log("商会資金を投入  +"..amount)
    return true
end
function E:Finish(result)
    local b=self.battle
    if not b or b.result then return end
    b.result=result
    if result=="won" then
        if b.mode=="defense" then
            self.state.defensesWon=self.state.defensesWon+1; self:Log("防衛成功。所有権を維持しました。")
        else
            local acquired=self.state.properties[b.targetId]; acquired.owner=C.playerId
            acquired.independenceRisk=math.min(acquired.independenceRisk,C.independence.reacquireRisk)
            self.state.wins=self.state.wins+1; M.Unlock(self.state)
            self:Log("買収成立。物件が商会に加わりました。")
        end
    else
        if b.mode=="defense" then
            self.state.properties[b.targetId].owner=b.defender
            self.state.defensesLost=self.state.defensesLost+1; self:Log("防衛不成立。物件の所有権を失いました。")
        else
            self.state.losses=self.state.losses+1
            self:Log(result=="withdrawn" and "交渉を撤回しました。" or "買収不成立。")
        end
    end
    self:TryLearnTactics(result)
    -- All committed capital is spent, including on withdrawal. No free retry loop.
    -- No income settlement yet: that belongs to the campaign phase.
end
function E:UseEnemyTactic(company)
    local id=company and company.tacticBias; local tactic=id and D.tacticById[id]
    if not tactic then return end
    if id=="messenger" then self.battle.enemyWait=self.battle.enemyWait*.55
    elseif id=="rumor" then self:AddEffect("enemyAccelerationBoost",.75,10)
    elseif id=="defection" then
        local target
        for _,p in ipairs(M.Owned(self.state)) do if not target or p.independenceRisk>target.independenceRisk then target=p end end
        if target then target.independenceRisk=clamp(target.independenceRisk+16,0,B.riskMax-1); self:CheckDefection(target) end
    elseif id=="gift" then
        local extra=math.min(company.cash,math.floor(self.battle.baseValue*.015)); company.cash=company.cash-extra
        self.battle.enemyBid=self.battle.enemyBid+extra
    end
    self:Log("相手が「"..tactic.name.."」を使用")
end
function E:Step(dt)
    local b=self.battle
    b.elapsed=b.elapsed+dt
    for i=#b.effects,1,-1 do local effect=b.effects[i]; effect.remaining=effect.remaining-dt; if effect.remaining<=0 then table.remove(b.effects,i) end end
    for i=#b.delayedEffects,1,-1 do
        local effect=b.delayedEffects[i]; effect.remaining=effect.remaining-dt
        if effect.remaining<=0 then self:AddEffect(effect.type,effect.amount,effect.duration); self:Log("宴席の働きかけが広がりました"); table.remove(b.delayedEffects,i) end
    end
    b.effectiveValue=b.baseValue*self:EffectTotal("valueMultiplier",1)
    b.playerWait=math.max(0,b.playerWait-dt)
    b.enemyWait=math.max(0,b.enemyWait-dt)
    if b.enemyWait<=0 then
        local profile=b.aiProfile or profiles.steady
        local pressure=clamp((b.playerBid-b.enemyBid)/math.max(B.priceFloor,b.effectiveValue),0,1)
        local amount=math.min(b.enemyBudget,math.floor(b.effectiveValue*B.enemyBidFactor*profile.bid*
            (1+self.random()*B.enemyBidVariation+profile.react*pressure)))
        if b.defender~=C.neutralId then
            local company=self.state.companies[b.defender]
            amount=math.min(amount,company.cash); company.cash=company.cash-amount
        end
        b.enemyBudget=b.enemyBudget-amount; b.enemyBid=b.enemyBid+amount
        b.enemyWait=B.enemyWait*profile.wait
        if amount>0 then self:Log("相手側の追加出資  +"..amount) end
        local company=b.defender~=C.neutralId and self.state.companies[b.defender] or nil
        if company and self.random()<C.tactics.aiUseChance then self:UseEnemyTactic(company) end
    end
    b.momentum=math.max(0,b.momentum-B.momentumDecay*dt)
    -- Saturation prevents a single enormous bid from teleporting the gauge.
    local pressure=clamp((b.playerBid-b.enemyBid)/math.max(B.priceFloor,b.effectiveValue),-1,1)
    b.acceleration=-pressure*B.pressureAcceleration-b.momentum+B.baseAcceleration
        -self:EffectTotal("playerAcceleration",0)-self:EffectTotal("enemyAccelerationPenalty",0)+self:EffectTotal("enemyAccelerationBoost",0)
    b.velocity=clamp(b.velocity+(b.acceleration-B.drag*b.velocity)*dt,-B.maxVelocity,B.maxVelocity)
    -- Position-dependent pace: the border creeps near the centre and races near either edge.
    local edge=math.abs(b.gauge)/B.gaugeLimit
    b.gaugeSpeed=b.velocity*B.paceScale*(B.centerSpeed+(B.edgeSpeed-B.centerSpeed)*edge^B.edgeCurve)
    b.gauge=clamp(b.gauge+b.gaugeSpeed*dt,-B.gaugeLimit,B.gaugeLimit)
    if b.gauge<=-B.gaugeLimit then self:Finish("won")
    elseif b.gauge>=B.gaugeLimit then self:Finish("lost")
    elseif b.elapsed>=B.duration then self:Finish("timeout") end
end
function E:Tick(dt)
    if not self.battle or self.battle.result or type(dt)~="number" or dt~=dt or dt<=0 then return end
    self.accumulator=self.accumulator+math.min(dt,B.maxFrameDelta)
    while self.accumulator+1e-9>=B.step and not self.battle.result do
        self.accumulator=math.max(0,self.accumulator-B.step); self:Step(B.step)
    end
end
