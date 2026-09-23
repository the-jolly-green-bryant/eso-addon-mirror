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
        label(p,16,110,348,65,'ZoFontGamepad22'):SetText(PBWT.Factions.Name(definition))
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
    self.dieArt=WINDOW_MANAGER:CreateControl(nil,self.die,CT_TEXTURE)
    self.dieArt:SetAnchor(TOPLEFT,self.die,TOPLEFT,0,0);self.dieArt:SetDimensions(220,220)
    self.dieArt:SetDrawLayer(DL_OVERLAY);self.dieArt:SetDrawLevel(1)
    self.dieArt.pbwtArt='dice_body';self.dieArt:SetHidden(true)
    ui.presentation.textures[#ui.presentation.textures+1]=self.dieArt
    self.pips={}
    for _,xy in ipairs({{58,58},{162,58},{58,110},{110,110},{162,110},{58,162},{162,162}}) do
        -- Native inset marks do not depend on the localized font containing a dot glyph.
        local dot=panel(self.die,xy[1]-11,xy[2]-11,22,22)
        dot:SetCenterColor(0.13,0.09,0.04,1);dot:SetEdgeColor(0.30,0.23,0.13,1);dot:SetDrawLevel(2)
        self.pips[#self.pips+1]=dot
    end
    self.dieLabel=label(self.root,100,430,1180,75,'ZoFontGamepad27')
    self.guide=label(self.root,40,555,1300,60,'ZoFontGamepad22')
    return self
end
function FUI:DiceSurface()
    local ready=self.ui.presentation.full and PBWT.Assets.IsUsable(self.dieArt)
    self.die:SetCenterColor(0.87,0.81,0.66,ready and 0 or 1)
    self.die:SetEdgeColor(0.50,0.40,0.24,ready and 0 or 1)
    self.dieArt:SetHidden(not ready)
end
function FUI:Refresh()
    self:DiceSurface()
    local ui=self.ui;local s=ui.state
    local active=s.status=='setup' and not ui.showRecords and (ui.mode~='online' or (ui.network and ui.network.phase=='active'))
    self.root:SetHidden(not active)
    if not active then return end
    local choosing=not ui:IsComputerTurn() and (ui.mode~='online' or (ui.network.seat==s.player and not ui.network.pending))
    local name=ui.mode=='solo' and (s.player==1 and PBWT.L("open_you") or 'COM') or ('P'..s.player)
    local faction=s.opening=='faction' or s.opening=='other_faction'
    local roll=s.opening=='roll' or s.opening=='reroll'
    self.title:SetText(name..(roll and PBWT.L("open_roll_one") or faction and PBWT.L("open_pick_faction") or s.opening=='right' and PBWT.L("open_pick_right") or PBWT.L("open_pick_order")))
    local result=string.format(PBWT.L("open_roll_line"),s.rollRound,s.dice[1]==0 and PBWT.L("open_unrolled") or s.dice[1],s.dice[2]==0 and PBWT.L("open_unrolled") or s.dice[2])
    self.subtitle:SetText(result..(s.rollWinner~=0 and (PBWT.L("open_winner")..s.rollWinner) or s.opening=='reroll' and PBWT.L("open_tie") or PBWT.L("open_high")))
    self.guide:SetText(choosing and (roll and PBWT.L("open_hint_roll") or PBWT.L("open_hint_choose")) or PBWT.L("open_waiting"))
    for i,row in ipairs(self.rows) do
        row:SetHidden(not faction)
        row.taken:SetText(s.factions[3-s.player]==i and PBWT.L("open_taken") or '')
        row:SetEdgeColor(unpack(i==(ui.factionIndex or 1) and PBWT.Theme.cursor or PBWT.Theme.brass))
    end
    for i,row in ipairs(self.options) do
        row:SetHidden(faction or roll)
        row:SetEdgeColor(unpack(i==(ui.factionIndex or 1) and PBWT.Theme.cursor or PBWT.Theme.brass))
        row.title:SetText(s.opening=='right' and (i==1 and PBWT.L("open_right_faction") or PBWT.L("open_right_order")) or (i==1 and PBWT.L("open_order_first") or PBWT.L("open_order_second")))
        row.description:SetText(s.opening=='right' and (i==1 and PBWT.L("open_right_faction_text") or PBWT.L("open_right_order_text")) or (i==1 and PBWT.L("open_order_first_text") or PBWT.L("open_order_second_text")))
    end
    self.die:SetHidden(not roll);self.dieLabel:SetHidden(not roll)
    local face=s.dice[2]>0 and s.dice[2] or s.dice[1]
    -- Before the first roll, show an illustrative five rather than a blank ivory tile.
    -- This preview never changes the unrolled (zero) game state.
    local dots=({[0]={1,2,4,6,7},[1]={4},[2]={1,7},[3]={1,4,7},[4]={1,2,6,7},[5]={1,2,4,6,7},[6]={1,2,3,5,6,7}})[face]
    for _,p in ipairs(self.pips) do p:SetHidden(true) end
    for _,index in ipairs(dots) do self.pips[index]:SetHidden(false) end
    self.dieLabel:SetText(s.opening=='reroll' and PBWT.L("open_same_roll") or face==0 and PBWT.L("open_not_rolled") or (PBWT.L("open_p1_rolled")..face..PBWT.L("open_p2_next")))
end
