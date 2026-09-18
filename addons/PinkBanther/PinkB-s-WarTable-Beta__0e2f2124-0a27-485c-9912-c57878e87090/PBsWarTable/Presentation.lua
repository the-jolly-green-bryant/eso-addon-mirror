-- Pooled artwork and a bounded result reveal; no idle animation or UI rebuilding.
local P={}; P.__index=P; PBWT.Presentation=P
local unpack=unpack or table.unpack
function P.New(ui)
    local self=setmetatable({ui=ui,textures={}},P)
    local function texture(parent,kind,x,y,w,h)
        local t=WINDOW_MANAGER:CreateControl(nil,parent,CT_TEXTURE)
        t:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y); t:SetDimensions(w,h); t:SetDrawLayer(DL_BACKGROUND)
        t.pbwtArt=kind; t:SetHidden(true); self.textures[#self.textures+1]=t; return t
    end
    self.background=texture(ui.screen,'war_room',0,0,1,1); self.background:SetAnchorFill(ui.screen)
    self.board=texture(ui.boardFrame,'board_material',0,0,612,612)
    self.crest=texture(ui.content,'crest',110,26,112,112)
    self.scroll=texture(ui.scrollPanel,'elder_scroll',10,8,64,64)
    self.marks={}
    for player,kind in ipairs({'alliance_dominion','alliance_covenant'}) do
        local mark=texture(ui.content,kind,player==1 and 309 or 1355,156,44,44)
        mark:SetColor(unpack(PBWT.Theme.Player(player))); self.marks[player]=mark
    end
    -- A single continuous map underlay avoids 25 visibly repeated patches.
    -- Native cell edges remain the exact 5x5 grid.
    for i,id in ipairs(PBWT.Config.CARD_ORDER) do
        local row=ui.cardControls[i]
        row.material=texture(row.panel,'card_material',0,0,320,78)
        row.artIcon=texture(row.panel,id,19,17,44,44)
        row.text:SetAnchor(TOPLEFT,row.panel,TOPLEFT,72,25); row.text:SetDimensions(236,40); PBWT.Typography.Apply(row.text,'ZoFontGamepad22',true)
    end
    self.button=texture(ui.endPanel,'button_material',0,0,320,68)
    for _,f in ipairs(PBWT.Config.FLAGS) do
        local cell=ui.cells[(f.y-1)*5+f.x]
        local icon=texture(cell.root,'flag',5,90,18,18); icon:SetDrawLayer(DL_TEXT)
        icon.pbwtFlag=f
        cell.flag:SetAnchor(TOPLEFT,cell.root,TOPLEFT,24,89); cell.flag:SetDimensions(84,21)
    end
    self.result=WINDOW_MANAGER:CreateControl(nil,ui.content,CT_BACKDROP)
    self.result:SetAnchor(TOPLEFT,ui.content,TOPLEFT,442,408); self.result:SetDimensions(566,126)
    self.result:SetCenterColor(0.07,0.055,0.04,0.98); self.result:SetEdgeColor(unpack(PBWT.Theme.selected)); self.result:SetEdgeTexture('',1,1,3)
    self.result:SetDrawLayer(DL_OVERLAY); self.result:SetHidden(true)
    local title=WINDOW_MANAGER:CreateControl(nil,self.result,CT_LABEL)
    title:SetAnchor(TOPLEFT,self.result,TOPLEFT,12,12); title:SetDimensions(542,100)
    PBWT.Typography.Apply(title,'ZoFontGamepad34'); title:SetColor(unpack(PBWT.Theme.text)); title:SetHorizontalAlignment(TEXT_ALIGN_CENTER); title:SetDrawLayer(DL_OVERLAY)
    self.resultText=title
    return self
end
function P:Reopen()
    if self.full then
        for _,t in ipairs(self.textures) do
            if not PBWT.Assets.IsUsable(t) then PBWT.Assets.Apply(t,t.pbwtArt,true) end
        end
    end
end
function P:Stop()
    EVENT_MANAGER:UnregisterForUpdate('PBsWarTableResult'); self.animating=false; self.result:SetAlpha(1)
end
function P:Pending()
    if not self.full then return false end
    for _,t in ipairs(self.textures) do if not t.pbwtDone then return true end end
    return false
end
function P:BoardSurface()
    local mapReady=self.full and PBWT.Assets.IsUsable(self.board)
    for _,cell in ipairs(self.ui.cells) do
        if mapReady then cell.root:SetCenterColor(0.09,0.07,0.04,0.42)
        else cell.root:SetCenterColor(unpack(PBWT.Theme.tile)) end
    end
end
function P:CardColors()
    for _,row in ipairs(self.ui.cardControls) do
        local paper=self.full and PBWT.Assets.IsUsable(row.material)
        if paper then row.text:SetColor(0.17,0.10,0.055,1); row.artIcon:SetColor(0.25,0.14,0.06,1)
        else row.text:SetColor(unpack(PBWT.Theme.text)); row.artIcon:SetColor(1,1,1,1) end
    end
end
function P:Poll()
    if not self.full then return end
    for _,t in ipairs(self.textures) do
        if not t.pbwtDone then local ready=PBWT.Assets.Poll(t); t:SetHidden(not ready) end
    end
    self:CardColors(); self:BoardSurface()
end
function P:Refresh()
    local ui=self.ui; local state=ui.state; local full=PBWT.Records.Data().presentation=='full'
    for player,mark in ipairs(self.marks) do
        local id=PBWT.Theme.Id(player,state); local kind=PBWT.Theme.themes[id].motif
        if mark.pbwtArt~=kind then
            mark.pbwtArt=kind
            if full then PBWT.Assets.Apply(mark,kind,true) end
        end
        mark:SetColor(unpack(PBWT.Theme.Player(player,state)))
    end
    if self.full~=full then
        self.full=full
        for _,t in ipairs(self.textures) do
            if full then PBWT.Assets.Apply(t,t.pbwtArt,true)
            else t:SetHidden(true); t:SetTexture(''); t.pbwtKind=nil; t.pbwtDone=true end
        end
        ui.backdrop:SetCenterColor(0.06,0.05,0.04,full and 0.65 or 0.99)
    end
    if full then
        for _,t in ipairs(self.textures) do
            if PBWT.Assets.IsUsable(t) then t.pbwtDone=true; t:SetHidden(false) end
            if t.pbwtFlag then
                local owner=PBWT.Engine.Flag(state,t.pbwtFlag.x,t.pbwtFlag.y)
                t:SetColor(unpack(owner~=0 and PBWT.Theme.Player(owner,state) or PBWT.Theme.brass))
            end
        end
    end
    self:BoardSurface()
    self:CardColors()
    local finished=state.status=='finished' and not ui.showRecords
    if ui.mode=='online' then finished=finished and ui.network and ui.network.phase=='finished' and not ui.network.pending end
    self.result:SetHidden(not finished)
    if finished then
        local seat=ui.mode=='online' and ui.network.seat or 1
        local title=state.winner==0 and '引き分け' or ui.mode=='local' and ('P'..state.winner..'の勝利') or state.winner==seat and '勝利' or '敗北'
        self.resultText:SetText(title..(state.reason=='elder_scroll' and ' — 星霜の書' or '')..'\n'..state.score[1]..'  ―  '..state.score[2]..'   /   '..state.turn..'手番')
        if self.lastResult~=state then
            self.lastResult=state; self:Stop()
            if full and ui.visible then
                self.animating=true; local start=GetFrameTimeMilliseconds(); self.result:SetAlpha(0)
                EVENT_MANAGER:RegisterForUpdate('PBsWarTableResult',32,function()
                    local alpha=math.min(1,(GetFrameTimeMilliseconds()-start)/320)
                    self.result:SetAlpha(alpha)
                    if alpha>=1 then self:Stop() end
                end)
            end
        end
    elseif self.animating then self:Stop() end
    if not full and self.animating then self:Stop() end
end
