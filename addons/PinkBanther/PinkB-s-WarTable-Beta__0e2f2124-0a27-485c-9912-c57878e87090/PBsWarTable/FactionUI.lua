local FUI={}; FUI.__index=FUI; PBWT.FactionUI=FUI
local unpack=unpack or table.unpack
function FUI.New(ui)
    local self=setmetatable({ui=ui,rows={}},FUI)
    local function panel(parent,x,y,w,h)
        local p=WINDOW_MANAGER:CreateControl(nil,parent,CT_BACKDROP)
        p:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y);p:SetDimensions(w,h)
        p:SetCenterColor(0.08,0.06,0.04,0.99);p:SetEdgeTexture('',1,1,3);p:SetEdgeColor(unpack(PBWT.Theme.brass));p:SetDrawLayer(DL_OVERLAY)
        return p
    end
    local function label(parent,x,y,w,h,font)
        local t=WINDOW_MANAGER:CreateControl(nil,parent,CT_LABEL)
        t:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y);t:SetDimensions(w,h);PBWT.Typography.Apply(t,font or 'ZoFontGamepad27')
        t:SetColor(unpack(PBWT.Theme.text));t:SetDrawLayer(DL_OVERLAY);t:SetHorizontalAlignment(TEXT_ALIGN_CENTER);return t
    end
    self.root=panel(ui.content,30,140,1380,650);self.root:SetMouseEnabled(true);self.root:SetHidden(true)
    self.title=label(self.root,40,20,1300,54,'ZoFontGamepad34')
    self.subtitle=label(self.root,40,80,1300,45,'ZoFontGamepad22')
    for index,id in ipairs(PBWT.Factions.order) do
        local definition=PBWT.Factions.definitions[id]
        local p=panel(self.root,100+(index-1)*400,145,380,375)
        local icon=WINDOW_MANAGER:CreateControl(nil,p,CT_TEXTURE)
        icon:SetAnchor(TOPLEFT,p,TOPLEFT,150,20);icon:SetDimensions(80,80);icon:SetDrawLayer(DL_OVERLAY)
        icon.pbwtArt=definition.motif;icon:SetColor(unpack(PBWT.Theme.themes[id].color));icon:SetHidden(true)
        ui.presentation.textures[#ui.presentation.textures+1]=icon
        label(p,16,110,348,65,'ZoFontGamepad22'):SetText(definition.name)
        label(p,16,181,348,42):SetText(definition.ability)
        label(p,26,235,328,130,'ZoFontGamepad22'):SetText(definition.description)
        p.taken=label(p,16,343,348,28,'ZoFontGamepad18')
        self.rows[index]=p
    end
    self.options={}
    for i=1,2 do
        local p=panel(self.root,230+(i-1)*480,170,440,310)
        p.title=label(p,20,70,400,60,'ZoFontGamepad34')
        p.description=label(p,25,160,390,120,'ZoFontGamepad22')
        self.options[i]=p
    end
    self.die=panel(self.root,580,180,220,220)
    self.die:SetCenterColor(0.87,0.81,0.66,1)
    self.pips={}
    for _,xy in ipairs({{45,45},{175,45},{45,110},{110,110},{175,110},{45,175},{175,175}}) do
        -- Native inset marks do not depend on the localized font containing a dot glyph.
        local dot=panel(self.die,xy[1]-11,xy[2]-11,22,22)
        dot:SetCenterColor(0.13,0.09,0.04,1);dot:SetEdgeColor(0.30,0.23,0.13,1);dot:SetDrawLevel(2)
        self.pips[#self.pips+1]=dot
    end
    self.dieLabel=label(self.root,100,430,1180,75,'ZoFontGamepad27')
    self.guide=label(self.root,40,555,1300,60,'ZoFontGamepad22')
    return self
end
function FUI:Refresh()
    local ui=self.ui;local s=ui.state
    local active=s.status=='setup' and not ui.showRecords and (ui.mode~='online' or (ui.network and ui.network.phase=='active'))
    self.root:SetHidden(not active)
    if not active then return end
    local choosing=not ui:IsComputerTurn() and (ui.mode~='online' or (ui.network.seat==s.player and not ui.network.pending))
    local name=ui.mode=='solo' and (s.player==1 and 'あなた' or 'COM') or ('P'..s.player)
    local faction=s.opening=='faction' or s.opening=='other_faction'
    local roll=s.opening=='roll' or s.opening=='reroll'
    self.title:SetText(name..(roll and '：ダイスを1個振る' or faction and '：同盟を選択' or s.opening=='right' and '：選択権を選ぶ' or '：先攻・後攻を選ぶ'))
    local result=string.format('第%dロール  P1：%s / P2：%s',s.rollRound,s.dice[1]==0 and '未' or s.dice[1],s.dice[2]==0 and '未' or s.dice[2])
    self.subtitle:SetText(result..(s.rollWinner~=0 and ('  勝者 P'..s.rollWinner) or s.opening=='reroll' and '  同点：双方振り直し' or '  大きい出目が選択権を取ります'))
    self.guide:SetText(choosing and (roll and '×：ダイスを振る　○：閉じる' or '十字キー / L1・R1：切替　×：確定　○：閉じる') or '相手のロール・選択・通信確認を待っています')
    for i,row in ipairs(self.rows) do
        row:SetHidden(not faction)
        row.taken:SetText(s.factions[3-s.player]==i and '相手が選択済み' or '')
        row:SetEdgeColor(unpack(i==(ui.factionIndex or 1) and PBWT.Theme.cursor or PBWT.Theme.brass))
    end
    for i,row in ipairs(self.options) do
        row:SetHidden(faction or roll)
        row:SetEdgeColor(unpack(i==(ui.factionIndex or 1) and PBWT.Theme.cursor or PBWT.Theme.brass))
        row.title:SetText(s.opening=='right' and (i==1 and '同盟の優先選択' or '先攻・後攻の選択') or (i==1 and '自分が先攻' or '自分が後攻'))
        row.description:SetText(s.opening=='right' and (i==1 and '自軍の同盟を先に選ぶ。相手が先後を決め、残る2同盟から選ぶ。' or '自分の先攻・後攻を決める。相手が同盟を先に選ぶ。') or (i==1 and '自分が第1手番。配置の左右とP番号は変わらない。' or '相手が第1手番。配置の左右とP番号は変わらない。'))
    end
    self.die:SetHidden(not roll);self.dieLabel:SetHidden(not roll)
    local face=s.dice[2]>0 and s.dice[2] or s.dice[1]
    -- Before the first roll, show an illustrative five rather than a blank ivory tile.
    -- This preview never changes the unrolled (zero) game state.
    local dots=({[0]={1,2,4,6,7},[1]={4},[2]={1,7},[3]={1,4,7},[4]={1,2,6,7},[5]={1,2,4,6,7},[6]={1,2,3,5,6,7}})[face]
    for _,p in ipairs(self.pips) do p:SetHidden(true) end
    for _,index in ipairs(dots) do self.pips[index]:SetHidden(false) end
    self.dieLabel:SetText(s.opening=='reroll' and '同じ出目です。もう一度P1から振ります。' or face==0 and '未ロール（絵は見本です） / ×でダイスを振る' or ('P1の出目 '..face..' — 次はP2が振ります'))
end
