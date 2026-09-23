local A={}; A.__index=A; PBTrade.Controller=A
local C,D,M=PBTrade.Config,PBTrade.Data,PBTrade.Model
local tutorial={
    "交易台帳へようこそ\n\n各地域の物件を買収し、商会の総資産を伸ばします。L1 / R1で地図・所有物件・連合・駆け引き・経営を切り替えます。",
    "買収交渉\n\n交渉はリアルタイムです。相手は左、自社は右。資金要求や駆け引きで青い帯を伸ばし、赤との境目を左端まで押し切ってください。\nコマンドは「資金要求・グループ要求・駆け引き・自社資金」の4分類。←→ / L1 R1で分類、↑↓で項目を選びます。撤退は□ボタンです。",
    "資金と離反\n\n所有物件へ要求すると独立危険度が上昇します。強い物件を使い続けるほど失う危険が増え、根回しが重要になります。",
    "連合と駆け引き\n\n同地域・同業種をそろえると大口の連合調達を閃きます。物件抵抗を確認し、買収後に習得する駆け引きを組み合わせてください。",
}
function A.New(random,saved)
    if PBTrade.LiveCatalog then PBTrade.LiveCatalog.Import() end
    local self=setmetatable({tab=1,index=1,screen="map",zone="auridon",notice="Phase 5：全開発フェーズ実装済み"},A)
    self.random=random or math.random
    self.saved=saved; self.tutorialComplete=saved and saved.tutorialComplete or false
    self.state=saved and saved.state and M.Load(saved.state) or M.New(); self.engine=PBTrade.Engine.New(self.state,self.random)
    if PBTrade.LiveCatalog then PBTrade.LiveCatalog.CaptureCurrent(self.state) end
    self.previousRanks={}; for _,r in ipairs(M.Rankings(self.state)) do self.previousRanks[r.id]=r.rank end
    return self
end
function A:Save()
    if self.saved then self.saved.state=M.Export(self.state); self.saved.tutorialComplete=self.tutorialComplete end
end
function A:Flash(kind,text,duration)
    self.fx={kind=kind,text=text,remaining=duration or 2.2,duration=duration or 2.2}
    if PBTrade.Audio and PBTrade.Audio.Play then PBTrade.Audio.Play(kind) end
end
local function comma(n)
    local s=tostring(math.floor(n)); local sign=""
    if s:sub(1,1)=="-" then sign="-"; s=s:sub(2) end
    return sign..s:reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end
-- Round steps: 1, 2, 2.5, 5 x 10^k.
local function ladder(limit)
    local steps={}; local scale=10
    while scale<=limit*10 do
        for _,f in ipairs({1,2,2.5,5}) do steps[#steps+1]=math.floor(f*scale+.5) end
        scale=scale*10
    end
    return steps
end
local function roundUpTwoDigits(n)
    local magnitude=1; while n>=magnitude*100 do magnitude=magnitude*10 end
    return math.ceil(n/magnitude)*magnitude
end
-- Treasury amounts built around the bid gap: the base closes the gap (or, when leading,
-- extends the lead by a share of the value); round ladder steps are added either side.
function A:TreasuryOptions()
    local b=self.engine.battle; local B=C.battle
    local gap=b and (b.enemyBid-b.playerBid) or 0
    local base,tag
    if gap>0 then base,tag=roundUpTwoDigits(gap),"差額を埋める"
    else base,tag=roundUpTwoDigits((b and b.effectiveValue or 0)*B.treasuryLeadShare),"リードを広げる" end
    base=math.max(B.treasuryMinimum,base)
    local below,above={}, {}
    for _,step in ipairs(ladder(base)) do
        if step>=B.treasuryMinimum and step<base then below[#below+1]=step elseif step>base and #above<B.treasuryStepsEachSide then above[#above+1]=step end
    end
    local options={}
    for i=math.max(1,#below-B.treasuryStepsEachSide+1),#below do options[#options+1]={amount=below[i]} end
    options[#options+1]={amount=base,tag=tag,base=true}
    for _,step in ipairs(above) do options[#options+1]={amount=step} end
    -- Never leave the treasury unusable: offer the whole balance when every step is too large.
    local cash=self.state.cash
    if cash>0 and cash<options[1].amount then table.insert(options,1,{amount=cash,tag="手元の全額"}) end
    return options,gap
end
function A:Rows()
    local rows={}
    if self.screen=="map" then
        for _,z in ipairs(D.zones) do if (z.minChapter or 1)<=self.state.chapter then rows[#rows+1]={id=z.id,label=z.name,zone=z} end end
    elseif self.screen=="properties" or self.screen=="owned" then
        local definitions=self.screen=="properties" and D.propertyIdsByZone[self.zone] or D.properties
        for _,def in ipairs(definitions) do
            local p=self.state.properties[type(def)=="string" and def or def.id]
            if M.IsAvailable(self.state,p) and ((self.screen=="properties" and p.zone==self.zone) or (self.screen=="owned" and p.owner==C.playerId)) then
                rows[#rows+1]={id=p.id,label=p.name,property=p}
            end
        end
    elseif self.screen=="groups" then
        -- Groups stay secret until discovered: only learned ones are listed.
        local ids={}; for id in pairs(self.state.learnedGroups) do if D.groups[id] then ids[#ids+1]=id end end
        table.sort(ids,function(x,y) return D.groups[x].name<D.groups[y].name end)
        for _,id in ipairs(ids) do local status=M.GroupStatus(self.state,id); rows[#rows+1]={id=id,label=status.name,group=status} end
        if #rows==0 then rows[1]={label="まだ閃いた連合はありません",detailText="連合\n\nまだ閃いた連合はありません。"} end
    elseif self.screen=="tactics" then
        for _,tactic in ipairs(D.tactics) do rows[#rows+1]={id=tactic.id,label=tactic.name,tactic=tactic,learned=self.state.learnedTactics[tactic.id]} end
    elseif self.screen=="management" then
        local status=M.CampaignStatus(self.state)
        rows[#rows+1]={label="第"..self.state.chapter.."章の進行  "..status.current.." / "..status.target,command="campaign",status=status}
        rows[#rows+1]={label="決算と財務  第"..self.state.cycles.."期 / 負債 "..self.state.debt,command="finance"}
        rows[#rows+1]={label="再建融資を申請  +"..C.economy.rebuildGrant.." ゴールド",command="rebuild",enabled=M.CanRebuild(self.state)}
    elseif self.screen=="battle" then
        -- Four command categories; ←→ / L1 R1 switch category, ↑↓ pick within it.
        local category=A.battleCategories[self.battleCategory or 1].id
        if category=="request" then
            for _,p in ipairs(M.Owned(self.state)) do rows[#rows+1]={id=p.id,label=p.name,property=p,command="request"} end
            if #rows==0 then rows[1]={label="資金を要求できる自社物件がありません",command="none",enabled=false,hint="物件を買収すると、その手元資金を要求できます"} end
        elseif category=="group" then
            local ids={}; for id in pairs(self.state.learnedGroups) do ids[#ids+1]=id end
            table.sort(ids,function(x,y) return D.groups[x].name<D.groups[y].name end)
            for _,id in ipairs(ids) do
                local group=D.groups[id] and M.GroupStatus(self.state,id)
                if group then rows[#rows+1]={id=id,label=group.name.."（"..group.count.."/"..group.minimum.."件）",group=group,command="group",
                    enabled=group.usable and true or false,hint=not group.usable and ("構成物件が不足（"..group.count.."/"..group.minimum.."件）") or nil} end
            end
            if #rows==0 then rows[1]={label="まだ閃いた連合はありません",command="none",enabled=false,hint="まだ閃いた連合はありません"} end
        elseif category=="tactic" then
            for _,tactic in ipairs(D.tactics) do if self.state.learnedTactics[tactic.id] then
                rows[#rows+1]={id=tactic.id,label=tactic.name.."（"..tactic.cost.."）",tactic=tactic,command="tactic"}
            end end
            rows[#rows+1]={label="地元評議会へ根回し（"..C.independence.stabilizeCost.."）",command="stabilize"}
        else
            local options,gap=self:TreasuryOptions()
            local situation=gap>0 and ("相手との差 "..comma(gap)) or ("自社が "..comma(-gap).." リード")
            for _,o in ipairs(options) do
                local enough=self.state.cash>=o.amount
                rows[#rows+1]={label=comma(o.amount).." ゴールド"..(o.tag and "（"..o.tag.."）" or ""),amount=o.amount,base=o.base,
                    command="treasury",enabled=enough,
                    hint=situation.."  /  "..(enough and ("商会資金 "..comma(self.state.cash).." → "..comma(self.state.cash-o.amount))
                        or ("商会資金が不足（現在 "..comma(self.state.cash).."）"))}
            end
        end
    elseif self.screen=="rankings" then
        for _,r in ipairs(self.rankingRows or {}) do rows[#rows+1]={id=r.id,label=r.name,ranking=r} end
    end
    return rows
end
function A:Selected(rows)
    rows=rows or self:Rows(); self.index=math.max(1,math.min(self.index,#rows)); return rows[self.index]
end
function A:Move(delta)
    if self.modal or self.screen=="result" then return end
    local rows=self:Rows(); if #rows>0 then self.index=(self.index-1+delta)%#rows+1 end
end
A.battleCategories={{id="request",name="資金要求"},{id="group",name="グループ要求"},{id="tactic",name="駆け引き"},{id="treasury",name="自社資金"}}
function A:SwitchBattleCategory(delta)
    self.battleIndexes=self.battleIndexes or {}
    local current=self.battleCategory or 1
    self.battleIndexes[current]=self.index
    self.battleCategory=(current-1+delta)%#A.battleCategories+1
    self.index=self.battleIndexes[self.battleCategory] or 1
    -- The treasury list moves with the bids, so it always opens on the gap-closing amount.
    if A.battleCategories[self.battleCategory].id=="treasury" then
        for i,row in ipairs(self:Rows()) do if row.base then self.index=i end end
    end
end
-- Test/automation helper: jump to the category holding a command and select it.
function A:SelectBattleCommand(command,id)
    for c,category in ipairs(A.battleCategories) do
        self.battleCategory=c
        for i,row in ipairs(self:Rows()) do
            if row.command==command and (id==nil or row.id==id or row.amount==id) then self.index=i; return row end
        end
    end
end
function A:MovePage(delta)
    if self.screen=="battle" then
        if self.modal then return end
        return self:SwitchBattleCategory(delta)
    end
    self:Move(delta*C.ui.pageSize)
end
function A:Tab(delta)
    if self.screen=="battle" and not self.modal then return self:SwitchBattleCategory(delta) end
    if self.modal or self.screen=="battle" or self.screen=="result" or self.screen=="rankings" then return end
    self.tab=(self.tab-1+delta)%5+1
    self.screen=self.tab==1 and "map" or (self.tab==2 and "owned" or (self.tab==3 and "groups" or (self.tab==4 and "tactics" or "management"))); self.index=1
end
function A:ShowChapterIntro()
    local chapter=D.campaigns[self.state.chapter]; if not chapter then return end
    local status=M.CampaignStatus(self.state)
    self.modal={campaign=true,background=chapter.background,text=chapter.title.."\n"..chapter.subtitle.."\n\n"..chapter.description
        .."\n\n目標："..status.current.." / "..status.target.."\n\n× / ○：交易地図へ"}
    self:Flash("chapter",chapter.title,2.8)
end
function A:ShowTutorialPage()
    self.modal={action="tutorial",text="初回指南  "..self.tutorialPage.." / "..#tutorial.."\n\n"..tutorial[self.tutorialPage].."\n\n×：次へ　○：指南を終了"}
end
function A:BeginSession()
    if self.introShown then return end; self.introShown=true
    if not self.tutorialComplete then self.tutorialPage=1; self:ShowTutorialPage() else self:ShowChapterIntro() end
end
function A:Act(action)
    if self.modal then
        if action=="confirm" then
            local pending=self.modal.action; self.modal=nil
            if pending=="tutorial" then
                self.tutorialPage=self.tutorialPage+1
                if self.tutorialPage<=#tutorial then self:ShowTutorialPage() else self.tutorialComplete=true; self:Save(); self:ShowChapterIntro() end
            elseif pending=="start" then
                local ok,why=self.engine:Start(self.pendingId)
                if ok then self.screen="battle"; self.index=1; self.battleCategory=1; self.battleIndexes={}; self.counterattackChecked=false else self.notice=why end
            elseif pending=="withdraw" then self.engine:Finish("withdrawn"); self.screen="result" end
        elseif action=="back" and self.modal.action=="tutorial" then self.modal=nil; self.tutorialComplete=true; self:Save(); self:ShowChapterIntro()
        elseif action=="back" or action=="info" or action=="detail" then self.modal=nil end
        return
    end
    if action=="previous" then return self:Tab(-1) end
    if action=="next" then return self:Tab(1) end
    if action=="info" and self.screen=="battle" then return self:RequestWithdraw() end
    if action=="info" then
        self.modal={text="交易の手引き\n\n地域 → 物件 → ×で交渉開始。\n相手は左、自社は右。交渉は待ち時間中もリアルタイムで進みます。\n資金要求は独立危険度を上げ、離反判定を発生させます。\n閃いた系列を必要数そろえると連合調達が使えます。\n根回しは最も危険な自社物件を安定させます。\n投入資金は不成立・撤退でも戻りません。\n各交渉後に敵の攻撃判定と資金力ランキングがあります。"}; return
    end
    if self.screen=="result" then
        if action=="confirm" or action=="back" then self:AfterBattle() end
        return
    end
    if self.screen=="rankings" and (action=="confirm" or action=="back") then
        local report=M.SettleCycle(self.state)
        local nextChapter=M.AdvanceCampaign(self.state)
        self.screen=nextChapter and "map" or "properties"; self.index=1; self:Save()
        local reportText="第"..report.cycle.."期 決算\n\n事業収益："..report.gross.." ゴールド\n負債返済："..report.debtPayment
            .."\n手取："..report.net.."\n調達余力回復："..report.reserveRecovered
        if nextChapter and nextChapter.ending then
            self.tab=1; self.modal={campaign=true,background="chapter_5",text="交易戦終結\n\nモラグ・バル コンツェルンの中枢契約は破棄され、異界へ延びた鎖は断たれました。\n薄紅の羅針商会はタムリエル第一の交易組織として新しい帳簿を開きます。\n\n"..reportText.."\n\n× / ○：自由経営へ"}; self:Flash("ending","交易戦終結",4)
        elseif nextChapter then self.tab=1; self.notice=reportText:gsub("\n","  "); self:ShowChapterIntro()
        else self.modal={text=reportText.."\n\n× / ○：台帳へ戻る"}; self:Flash("settlement","決算  +"..report.net,2.4) end
        return
    end
    local row=self:Selected()
    if action=="detail" and row and (row.property or row.group or row.tactic or row.command) then
        local text=row.property and self:Detail(row.property)
            or (row.group and self:GroupDetail(row.group)
            or (row.tactic and self:TacticDetail(row.tactic) or self:ManagementDetail(row)))
        self.modal={text=text.."\n\n× / ○：閉じる"}; return
    end
    if action=="back" then
        if self.screen=="battle" then self.closeRequested=true
        elseif self.screen=="properties" then self.screen="map"; self.index=1
        else self.closeRequested=true end
        return
    end
    if action~="confirm" or not row then return end
    if self.screen=="map" then
        if not self.state.unlocked[row.id] then self.notice="所有物件を増やすと交易路が開きます（初期2件から2件ごとに拡張）"; return end
        self.zone=row.id; self.state.visited[row.id]=true; self.screen="properties"; self.index=1
    elseif self.screen=="properties" or self.screen=="owned" then
        if row.property.owner==C.playerId then self.modal={text=self:Detail(row.property)}
        elseif not M.IsPropertyVisited(self.state,row.property) then
            self.notice="実在地点はESO内で現地を訪問すると買収できます"
            self.modal={text=row.label.."\n\n未訪問の実在地点です。\nESO本編でこの場所へ実際に移動すると、買収交渉が解放されます。\n\n× / ○：閉じる"}
        else self.pendingId=row.id; self.modal={action="start",text=row.label.."\n\n買収交渉を始めますか？\n単体調達で物件の負担が増えます。\n投入資金は結果にかかわらず消費します。\n\n×：開始　○：戻る"} end
    elseif self.screen=="groups" then
        if row.group then self.modal={text=self:GroupDetail(row.group).."\n\n× / ○：閉じる"} end
    elseif self.screen=="tactics" then
        self.modal={text=self:TacticDetail(row.tactic).."\n\n× / ○：閉じる"}
    elseif self.screen=="management" then
        if row.command=="rebuild" then
            local ok,value=M.Rebuild(self.state); self.notice=ok and "再建融資を受けました" or value
            if ok then self:Save(); self:Flash("settlement","再建融資  +"..value,2.5) end
        elseif row.command=="campaign" then self.modal={text=row.status.chapter.title.."\n\n"..row.status.chapter.description.."\n\n進行："..row.status.current.." / "..row.status.target}
        else self.modal={text="経営状況\n\n商会資金："..self.state.cash.."\n資金力："..M.FundingPower(self.state).."\n負債："..self.state.debt.."\n評判："..self.state.reputation.."\n決算回数："..self.state.cycles.."\n再建回数："..self.state.rebuilds} end
    elseif self.screen=="battle" then
        local ok,why,info
        if row.enabled==false then self.notice=row.hint or "今は実行できません"; return end
        if row.command=="request" then ok,why,info=self.engine:Request(row.id)
        elseif row.command=="group" then ok,why,info=self.engine:RequestGroup(row.id)
        elseif row.command=="tactic" then ok,info=self.engine:UseTactic(row.id); why=not ok and info or nil
        elseif row.command=="stabilize" then ok,why=self.engine:Stabilize()
        else ok,why=self.engine:Treasury(row.amount) end
        self.notice=ok and "出資・工作が届きました" or why
        if ok then self:Save(); if row.command=="tactic" then self:StartTacticScene(info) end end
        if ok and info then
            local messages={}
            for _,id in ipairs(info.discoveries or {}) do messages[#messages+1]=D.groups[id].name.."を閃いた！" end
            if info.defected==true then messages[#messages+1]=info.property.name.."が離反しました。"
            elseif type(info.defected)=="table" then for _,p in ipairs(info.defected) do messages[#messages+1]=p.name.."が離反しました。" end end
            if #messages>0 then
                self.modal={text=table.concat(messages,"\n").."\n\n× / ○：交渉へ戻る"}
                local defected=info.defected==true or (type(info.defected)=="table" and #info.defected>0)
                self:Flash(defected and "defection" or "discovery",messages[1],2.5)
            end
        end
    end
end
function A:ManagementDetail(row)
    if row.command=="campaign" then
        return row.status.chapter.title.."\n\n"..row.status.chapter.description.."\n\n進行："..row.status.current.." / "..row.status.target
    elseif row.command=="rebuild" then
        return "再建融資\n\n資金力が"..C.economy.rebuildThreshold.."未満のとき、"..C.economy.rebuildGrant
            .."ゴールドを借り入れます。\n返済は各決算の利益から行い、評判が"..C.economy.rebuildReputationCost.."低下します。"
            .."\n\n現在："..(M.CanRebuild(self.state) and "申請可能" or "申請条件を満たしていません")
    end
    return "経営状況\n\n商会資金："..self.state.cash.."\n資金力："..M.FundingPower(self.state)
        .."\n負債："..self.state.debt.."\n評判："..self.state.reputation.."\n決算回数："..self.state.cycles
        .."\n再建回数："..self.state.rebuilds.."\n\n決算では所有物件から利益を得て、物件の調達余力が回復します。"
end
function A:TacticDetail(tactic)
    local rule=tactic.learn; local condition=rule.starting and "初期習得"
        or rule.category and (D.categories[rule.category].."を所有して交渉終了")
        or rule.defense and "防衛戦終了" or rule.result=="won" and "買収成功" or "買収失敗"
    return tactic.name.."\n\n"..tactic.description.."\nコスト："..tactic.cost.." ゴールド"
        .."\n習得："..condition..(rule.chance and " / "..math.floor(rule.chance*100).."%" or "")
        .."\n状態："..(self.state.learnedTactics[tactic.id] and "習得済み" or "未習得")
        .."\n抵抗判定："..tactic.resistanceKey
end
-- Special action (□ during a negotiation): one press opens the withdraw confirmation.
function A:RequestWithdraw()
    local b=self.engine.battle
    if not b or b.result then return end
    self.modal={action="withdraw",text="交渉から撤退しますか？\n投入した資金は戻りません。\n"..(b.mode=="defense" and "防衛対象の物件を失います。\n" or "").."\n×：撤退する　○ / □：続行"}
end
function A:ShowRankings()
    if self.lastRecoveredBattle~=self.engine.battle then
        self.lastRecoveredBattle=self.engine.battle
        for _,p in ipairs(M.Owned(self.state)) do p.independenceRisk=math.max(0,p.independenceRisk-C.independence.passiveRecovery) end
    end
    self.rankingRows=M.Rankings(self.state)
    self.index=1
    for i,r in ipairs(self.rankingRows) do
        r.previousRank=self.previousRanks[r.id] or r.rank
        r.rankChange=r.previousRank-r.rank
        self.previousRanks[r.id]=r.rank
        if r.id==C.playerId then self.index=i end
    end
    self.screen="rankings"; self.modal=nil
    self.notice=self.counterattackNotice or "交渉と防衛処理が完了しました"
end
function A:AfterBattle()
    local b=self.engine.battle
    if not b or not b.result then return end
    if b.mode=="defense" or self.counterattackChecked then self:ShowRankings(); return end
    self.counterattackChecked=true
    local attack,message=M.RollCounterattack(self.state,self.random)
    self.counterattackNotice=message
    if attack then
        local ok,why=self.engine:Start(attack.propertyId,attack.companyId)
        if ok then
            self.screen="battle"; self.index=1; self.battleCategory=1; self.battleIndexes={}
            self.notice=message
            self.modal={pauseBattle=true,text="敵商会が買収を仕掛けました\n\n"..message.."\n攻撃元："..self.state.properties[attack.sourcePropertyId].name.."\n\n境目を左端まで押し返せば防衛成功。\n右端到達・期限切れ・撤退では物件を失います。\n防衛が終わると資金力ランキングを表示します。\n\n×：防衛戦へ"}
            return
        end
        self.counterattackNotice="買収攻撃を開始できませんでした："..why
    end
    self:ShowRankings()
end
function A:Detail(p)
    local company=D.companies[p.owner]
    local groupNames={}; for _,id in ipairs(p.groups) do if self.state.learnedGroups[id] then groupNames[#groupNames+1]=D.groups[id].name end end
    local risk=M.RiskLabel(p.independenceRisk)
    local text=p.name.."\n"..D.categories[p.category]..(p.isHeadquarters and " / 本社" or "").."\n\n所有："..company.name
        .."\n経営："..(p.profileName or "個別設計")
        ..(p.canonical and "\n現地確認："..(M.IsPropertyVisited(self.state,p) and "訪問済み・買収可能" or "未訪問・買収不可") or "")
        .."\n評価額："..p.marketValue.."\n予想収益："..p.expectedProfit.." / 期（参考）"
        .."\n調達用手元資金："..p.reserve.."\n独立負担："..risk.." "..p.independenceRisk.." / 128"
        .."\n要求時の負担増：+"..p.independenceIncrease.."\n交渉の推進力："..p.gaugeAcceleration
        .."\n\n系列："..(#groupNames>0 and table.concat(groupNames," / ") or "不明")
        .."\n離反率："..math.floor(self.engine:DefectionChance(p)*100).."%（次回要求時）"
    return text
end
function A:GroupDetail(group)
    local state=group.id and M.GroupStatus(self.state,group.id) or group
    local names={}; for _,p in ipairs(state.members) do names[#names+1]=p.name end
    return state.name.."\n\n"..(state.learned and "習得済み" or "未習得：単体資金要求で閃く可能性あり")
        .."\n系列物件："..state.count.." / 必要 "..state.minimum
        .."\n調達倍率："..state.bonus.."倍\n使用："..(state.usable and "可能" or "不可")
        .."\n\n構成物件：\n"..(#names>0 and table.concat(names,"\n") or "なし")
end
-- Tactic cut-in: a staged scene (move → reaction → verdict) built from the engine outcome.
local function effectSummary(tactic,info)
    local e=tactic.effect; local a=math.abs(info.amount or 0)
    if e.type=="playerAcceleration" then return string.format("自社の押し込み +%.2f（%d秒）",a,e.duration)
    elseif e.type=="enemyAccelerationPenalty" then return string.format("相手の勢い -%.2f（%d秒）",a,e.duration)
    elseif e.type=="velocity" then return string.format("ゲージ速度 %.1f 自社側へ",a)
    elseif e.type=="randomVelocity" then
        return string.format("ゲージ速度 %.1f %s",a,info.direction==1 and "相手側へ" or "自社側へ")
    elseif e.type=="playerWaitMultiplier" then return string.format("自社の伝令待ち ×%.2f（%d秒）",math.max(.1,1-(1-e.amount)*info.power),e.duration)
    elseif e.type=="enemyWait" then return string.format("相手の次の出資 %.1f秒遅延",a)
    elseif e.type=="delayedAcceleration" then return string.format("%d秒後、自社の押し込み +%.2f（%d秒）",e.delay,a,e.duration)
    elseif e.type=="resetWaits" then return "双方の伝令待ちを初期化"
    elseif e.type=="valueMultiplier" then return string.format("評価額 ×%.2f（%d秒）",1+(e.amount-1)*info.power,e.duration)
    elseif e.type=="enemyRisk" then
        return string.format("%s の独立危険度 +%d%s",info.target.name,math.floor(a+.5),info.targetDefected and "  → 離反！" or "")
    elseif e.type=="ownRisk" then return string.format("%s の独立危険度 -%d",info.target.name,math.floor(a+.5)) end
    return tactic.description
end
function A:StartTacticScene(info)
    local tactic=info.tactic; local lines=tactic.scene or {}
    local verdict,kind
    if info.power<=0 then verdict,kind="無効","void"
    elseif tactic.effect.type=="randomVelocity" then
        if info.direction==1 then verdict,kind="裏目に出た……","backfire" else verdict,kind="大成功！","great" end
    elseif info.targetDefected then verdict,kind="大成功！","great"
    elseif info.power>=.85 then verdict,kind="大成功！","great"
    elseif info.power>=.5 then verdict,kind="成功","good"
    else verdict,kind="効果薄……","weak" end
    local failed=kind=="void" or kind=="backfire"
    self.tacticScene={time=0,tactic=tactic,kind=kind,verdict=verdict,power=info.power,
        act=lines.act or tactic.description,
        reaction=(failed and lines.resist or lines.success) or "",
        detail=failed and kind=="void" and "効果なし（抵抗 100%）"
            or (effectSummary(tactic,info).."  /  相手の抵抗 "..math.floor(info.resistance*100+.5).."%")}
    if PBTrade.Audio and PBTrade.Audio.Play then PBTrade.Audio.Play("tactic") end
end
function A:TacticVerdictCue()
    local scene=self.tacticScene
    if not scene or scene.cued then return end
    scene.cued=true
    local failed=scene.kind=="void" or scene.kind=="backfire" or scene.kind=="weak"
    if PBTrade.Audio and PBTrade.Audio.Play then PBTrade.Audio.Play(failed and "tacticFail" or "tacticSuccess") end
end
function A:TacticStage()
    local scene=self.tacticScene; if not scene then return nil end
    local S=C.tacticScene
    if scene.time<S.intro then return "intro",scene.time/S.intro end
    if scene.time<S.intro+S.react then return "react",(scene.time-S.intro)/S.react end
    return "result",math.min(1,(scene.time-S.intro-S.react)/S.result)
end
function A:Tick(dt)
    if self.fx then self.fx.remaining=self.fx.remaining-dt; if self.fx.remaining<=0 then self.fx=nil end end
    if self.tacticScene then
        -- The banner plays alongside the negotiation; it never holds the clock.
        local scene=self.tacticScene; scene.time=scene.time+dt
        local S=C.tacticScene
        if scene.time>=S.intro+S.react then self:TacticVerdictCue() end
        if scene.time>=S.intro+S.react+S.result then self.tacticScene=nil end
    end
    if self.screen=="battle" and not (self.modal and self.modal.pauseBattle) then
        self.engine:Tick(dt)
        if self.engine.battle.result then
            self.screen="result"; self.modal=nil; self:Save()
            local learned=self.engine.battle.learnedTactics or {}
            if #learned>0 then self:Flash("discovery",D.tacticById[learned[1]].name.."を習得！",3) end
        end
    end
end
