local U={}; U.__index=U; PBTrade.UI=U
local C,D,M=PBTrade.Config,PBTrade.Data,PBTrade.Model
local T=C.theme
local ink=T.text; local light=T.text
local layoutRecords
local function gold(value)
    local reversed=tostring(math.floor(value or 0)):reverse():gsub("(%d%d%d)","%1,")
    return reversed:gsub(",$",""):reverse()
end
local function remember(c,parent,x,y,w,h)
    layoutRecords[#layoutRecords+1]={control=c,parent=parent,x=x,y=y,w=w,h=h}
    return c
end
local function box(parent,x,y,w,h,color,edge)
    local c=WINDOW_MANAGER:CreateControl(nil,parent,CT_BACKDROP)
    c:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y); c:SetDimensions(w,h)
    c:SetCenterColor(unpack(color or T.panel))
    c:SetEdgeColor(unpack(edge or T.edge)); c:SetEdgeTexture("",1,1,1)
    return remember(c,parent,x,y,w,h)
end
local function label(parent,x,y,w,h,text,size,color)
    local c=WINDOW_MANAGER:CreateControl(nil,parent,CT_LABEL)
    c:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y); c:SetDimensions(w,h)
    c:SetFont("ZoFontGamepad"..(size or 22)); c:SetColor(unpack(color or light))
    c:SetText(text or ""); return remember(c,parent,x,y,w,h)
end
local function panel(parent,x,y,w,h)
    local c=WINDOW_MANAGER:CreateControl(nil,parent,CT_CONTROL)
    c:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y); c:SetDimensions(w,h); return remember(c,parent,x,y,w,h)
end
local function texture(parent,x,y,w,h,name,color)
    local c=WINDOW_MANAGER:CreateControl(nil,parent,CT_TEXTURE)
    c:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y); c:SetDimensions(w,h)
    PBTrade.Assets.Apply(c,name); c:SetColor(unpack(color or {1,1,1,1}))
    c:SetDrawLayer(DL_BACKGROUND)
    return remember(c,parent,x,y,w,h)
end
local function plaque(parent,x,y,w,h)
    local base=box(parent,x,y,w,h,{.04,.05,.03,1},T.edge)
    local art=texture(base,0,0,w,h,"wood_frame",{1,1,1,.72})
    return base,art
end
function U.New(app)
    local self=setmetatable({app=app,rows={},pins={},coinControls={{},{}},nextMove=0,refreshMarkers={}},U)
    self.root=WINDOW_MANAGER:CreateTopLevelWindow("PBTradeWindow")
    self.root:SetAnchorFill(GuiRoot); self.root:SetHidden(true)
    layoutRecords={}
    local scenery=texture(self.root,0,0,1,1,"treasury"); scenery:SetAnchorFill(self.root)
    local veil=box(self.root,0,0,1,1,{.015,.023,.02,.20},{0,0,0,0}); veil:SetAnchorFill(self.root)
    local p=panel(self.root,0,0,C.ui.width,C.ui.height); self.content=p
    -- Background is edge-to-edge; only the standard keybind strip has reserved space.
    layoutRecords={}
    box(p,0,0,1240,108,{.02,.025,.02,.70},{0,0,0,0})
    box(p,40,104,1160,1,T.gold,{0,0,0,0})
    box(p,40,704,1160,1,T.edge,{0,0,0,0})
    texture(p,39,17,80,80,"crest"):SetDrawLayer(DL_CONTROLS)
    label(p,133,27,660,44,C.displayTitle,34)
    self.subtitle=label(p,135,71,650,30,"",18)
    self.stats=label(p,820,27,370,80,"",22)
    self.tabs=label(p,42,111,1140,32,"",22)
    self.map=panel(p,40,158,1160,500)
    texture(self.map,0,0,760,500,"atlas",{.83,.81,.75,1})
    -- Original decorative atlas with real ESO region cards layered above it.
    texture(self.map,774,0,386,500,"wood_frame",{.67,.72,.69,.96})
    box(self.map,18,9,609,35,{.04,.05,.04,.88},{0,0,0,0})
    self.mapHeading=label(self.map,26,12,595,30,"",18)
    label(self.map,640,32,100,35,"N  ↑",27,{.18,.14,.09,1})
    box(self.map,24,455,704,36,{.04,.05,.04,.88},{0,0,0,0})
    label(self.map,35,459,690,32,"↑↓：地域選択    ←→：8地域ずつ移動    ×：地域を開く",18)
    label(self.map,798,20,340,40,"交易路の記録",27)
    self.mapDetail=label(self.map,798,76,338,360,"",22)
    for i=1,C.ui.mapPageSize do
        local pin=plaque(self.map,30+((i-1)%2)*350,62+math.floor((i-1)/2)*96,330,78)
        local text=label(pin,12,9,306,62,"",22)
        pin:SetMouseEnabled(true); pin:SetHandler("OnMouseUp",function() self.app.index=(self.mapPage or 0)*C.ui.mapPageSize+i; self.app:Act("confirm"); self:Refresh() end)
        self.pins[i]={box=pin,text=text}
    end
    self.ledger=panel(p,40,158,1160,500)
    texture(self.ledger,0,0,710,500,"wood_frame",{.66,.69,.65,.98})
    texture(self.ledger,734,0,426,500,"wood_frame",{.65,.70,.67,.97})
    self.ledgerHeading=label(self.ledger,22,12,670,35,"",27,ink)
    self.detail=label(self.ledger,758,22,376,454,"",22)
    for i=1,C.ui.pageSize do
        local row=plaque(self.ledger,18,60+(i-1)*51,674,47)
        local text=label(row,10,4,652,39,"",22,ink)
        row:SetMouseEnabled(true); row:SetHandler("OnMouseUp",function()
            self.app.index=(self.page or 0)*C.ui.pageSize+i; self.app:Act("confirm"); self:Refresh()
        end)
        self.rows[i]={box=row,text=text}
    end
    self.battle=panel(p,40,158,1160,500)
    box(self.battle,0,0,1160,500,{.025,.034,.03,.30},{.49,.39,.24,.55})
    self.battleTitle=label(self.battle,24,8,1100,36,"",27)
    self.bands={}
    for i=1,6 do
        local y=64+(i-1)*38
        local enemy=box(self.battle,20,y,560,28,{.48,.12,.14,.40},{0,0,0,0})
        local own=box(self.battle,580,y,560,28,{.08,.27,.52,.44},{0,0,0,0})
        local enemyTip=texture(self.battle,508,y,C.battle.bandTipWidth,28,"band_tip_right",{.48,.12,.14,.40})
        local ownTip=texture(self.battle,580,y,C.battle.bandTipWidth,28,"band_tip_left",{.08,.27,.52,.44})
        local enemyGlow=texture(self.battle,20,y,C.battle.bandGlowWidth,28,"band_glow",{1,.44,.35,.88})
        local ownGlow=texture(self.battle,1044,y,C.battle.bandGlowWidth,28,"band_glow",{.42,.78,1,.92})
        enemyGlow:SetDrawLayer(DL_CONTROLS); ownGlow:SetDrawLayer(DL_CONTROLS)
        self.bands[i]={enemy=enemy,own=own,enemyTip=enemyTip,ownTip=ownTip,enemyGlow=enemyGlow,ownGlow=ownGlow,phase=(i-1)/6}
    end
    self.coinAreas={}; self.floors={}; self.depthLabels={}
    for side=1,2 do
        local bayX=side==1 and 74 or 674
        texture(self.battle,bayX-40,30,52,52,"crest",side==1 and {.72,.84,.90,1} or {1,.86,.79,1}):SetDrawLayer(DL_CONTROLS)
        self.depthLabels[side]=label(self.battle,bayX+30,38,420,25,"",18)
        local viewport=panel(self.battle,bayX,65,400,C.coins.viewportHeight)
        self.coinAreas[side]=viewport
        self.floors[side]=texture(viewport,0,C.coins.floorY+C.coins.plinthOffsetY,C.coins.plinthWidth,C.coins.plinthHeight,"coin_plinth")
    end
    plaque(self.battle,34,306,516,45)
    plaque(self.battle,610,306,516,45)
    self.leftBid=label(self.battle,52,313,490,34,"",27,{.94,.79,.60,1})
    self.rightBid=label(self.battle,628,313,490,34,"",27,{1,.88,.56,1})
    self.status=label(self.battle,24,365,1110,34,"",18)
    texture(self.battle,16,410,696,89,"wood_frame",{.83,.83,.76,1})
    texture(self.battle,723,410,421,89,"wood_frame",{.72,.76,.71,1})
    self.commandTabs=label(self.battle,28,417,670,22,"",18,T.gold)
    self.command=label(self.battle,28,438,670,32,"",27)
    self.commandHint=label(self.battle,28,472,670,25,"",18)
    self.log=label(self.battle,735,417,398,78,"",18)
    -- Tactic banner: two slim lines over the title row, clear of the bands, coins and bids.
    local function overlay(c,level) c:SetDrawLayer(DL_OVERLAY); c:SetDrawLevel(level); return c end
    self.cutin=overlay(box(self.battle,14,4,1132,56,{.018,.024,.02,.90},T.gold),15)
    self.cutinStripe=overlay(box(self.cutin,0,53,1132,3,T.gold,{0,0,0,0}),16)
    self.cutinLine=overlay(label(self.cutin,14,2,1104,27,"",18),17)
    self.cutinVerdict=overlay(label(self.cutin,14,27,1104,27,"",18),17)
    self.cutin:SetHidden(true)
    self.notice=label(p,44,675,1150,32,"",18)
    label(p,44,720,1150,30,"↑↓：選択    ←→：頁送り（交渉中は分類切替）    L1 / R1：帳簿・分類切替    ×：決定    ○：戻る / 中断    □：手引き（交渉中は撤退）    △：詳細",18)
    self.modal,self.modalArt=plaque(p,225,155,790,510)
    self.modal:SetCenterColor(.025,.03,.02,1)
    self.modalArt:SetDrawLayer(DL_OVERLAY); self.modalArt:SetDrawLevel(11)
    self.modal:SetDrawLayer(DL_OVERLAY); self.modal:SetDrawLevel(10)
    self.campaignBackdrop=texture(self.modal,8,8,774,494,"chapter_1"); self.campaignBackdrop:SetDrawLayer(DL_OVERLAY); self.campaignBackdrop:SetDrawLevel(11)
    self.campaignShade=box(self.modal,8,8,774,494,{.01,.015,.012,.62},{0,0,0,0}); self.campaignShade:SetDrawLayer(DL_OVERLAY); self.campaignShade:SetDrawLevel(12)
    self.modalText=label(self.modal,30,25,730,460,"",22); self.modalText:SetDrawLayer(DL_OVERLAY); self.modalText:SetDrawLevel(13)
    self.fxPanel=box(p,320,102,600,64,{.04,.08,.07,.94},T.gold)
    self.fxPanel:SetDrawLayer(DL_OVERLAY); self.fxPanel:SetDrawLevel(20)
    self.fxText=label(self.fxPanel,16,10,568,44,"",27,T.gold)
    self.fxText:SetDrawLayer(DL_OVERLAY); self.fxText:SetDrawLevel(21)
    self.keybinds={alignment=KEYBIND_STRIP_ALIGN_CENTER}
    for _,spec in ipairs({{"UI_SHORTCUT_PRIMARY","confirm","決定"},{"UI_SHORTCUT_NEGATIVE","back","戻る"},
        {"UI_SHORTCUT_SECONDARY","info","手引き"},{"UI_SHORTCUT_TERTIARY","detail","詳細"},
        {"UI_SHORTCUT_LEFT_SHOULDER","previous","前の分類"},{"UI_SHORTCUT_RIGHT_SHOULDER","next","次の分類"}}) do
        local action=spec[2]
        local name=spec[3]
        -- □ is the negotiation's special action: withdraw with a single press.
        if action=="info" then name=function()
            local app=self.app; return type(app)=="table" and app.screen=="battle" and "撤退" or "手引き" end end
        self.keybinds[#self.keybinds+1]={keybind=spec[1],name=name,callback=function() self:Action(action) end}
    end
    self.scene=ZO_Scene:New(C.scene,SCENE_MANAGER)
    self.scene:AddFragment(ZO_SimpleSceneFragment:New(self.root))
    self.scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    self.scene:AddFragment(ZO_ActionLayerFragment:New("PBTradeInput"))
    self.scene:RegisterCallback("StateChange",function(_,state)
        if state==SCENE_SHOWING then
            -- The session state is built on first open, not during add-on load.
            if type(self.app)=="function" then self.app=self.app() end
            self.app:BeginSession()
            self:Resize()
            KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds); self:Refresh()
        elseif state==SCENE_SHOWN then
            self.active=true; self.nextMove=0; DIRECTIONAL_INPUT:Activate(self,self.root)
        elseif state==SCENE_HIDING then
            self.active=false; self.keyDirection=nil; DIRECTIONAL_INPUT:Deactivate(self); KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds)
        end
    end)
    self.layout=layoutRecords; layoutRecords=nil
    self:Resize()
    return self
end
function U:Resize()
    local w,h=GuiRoot:GetWidth(),GuiRoot:GetHeight()
    self.viewportWidth,self.viewportHeight=w,h
    local height=math.max(1,h-C.ui.keybindHeight)
    local scale=math.min(w/C.ui.width,height/C.ui.height)
    self.sx=w/(scale*C.ui.width); self.sy=height/(scale*C.ui.height)
    self.content:SetScale(scale); self.content:SetDimensions(w/scale,height/scale)
    self.content:ClearAnchors(); self.content:SetAnchor(TOPLEFT,self.root,TOPLEFT,0,0)
    for _,item in ipairs(self.layout) do
        item.control:ClearAnchors()
        item.control:SetAnchor(TOPLEFT,item.parent,TOPLEFT,item.x*self.sx,item.y*self.sy)
        item.control:SetDimensions(item.w*self.sx,item.h*self.sy)
    end
end
function U:UpdateBattleBands(normalized)
    local total=1120
    local red=total*normalized
    local blue=total-red
    local glow=C.battle.bandGlowWidth
    local tip=C.battle.bandTipWidth
    for _,band in ipairs(self.bands) do
        local y=(64+(_-1)*38)*self.sy
        local redTip=math.min(tip,red); local blueTip=math.min(tip,blue)
        band.enemy:SetHidden(red<=redTip); band.own:SetHidden(blue<=blueTip)
        band.enemy:ClearAnchors(); band.enemy:SetAnchor(TOPLEFT,self.battle,TOPLEFT,20*self.sx,y)
        band.enemy:SetWidth(math.max(1,(red-redTip)*self.sx))
        band.enemyTip:SetHidden(redTip<2); band.enemyTip:ClearAnchors()
        band.enemyTip:SetAnchor(TOPLEFT,self.battle,TOPLEFT,(20+red-redTip)*self.sx,y); band.enemyTip:SetDimensions(redTip*self.sx,28*self.sy)
        band.ownTip:SetHidden(blueTip<2); band.ownTip:ClearAnchors()
        band.ownTip:SetAnchor(TOPLEFT,self.battle,TOPLEFT,(20+red)*self.sx,y); band.ownTip:SetDimensions(blueTip*self.sx,28*self.sy)
        band.own:ClearAnchors(); band.own:SetAnchor(TOPLEFT,self.battle,TOPLEFT,(20+red+blueTip)*self.sx,y)
        band.own:SetWidth(math.max(1,(blue-blueTip)*self.sx))
        local phase=((self.bandFxTime or 0)/C.battle.bandAnimationSeconds+band.phase)%1
        local redGlow=math.min(glow,red)
        local blueGlow=math.min(glow,blue)
        band.enemyGlow:SetHidden(redGlow<4)
        band.ownGlow:SetHidden(blueGlow<4)
        if redGlow>=4 then
            band.enemyGlow:ClearAnchors()
            band.enemyGlow:SetAnchor(TOPLEFT,self.battle,TOPLEFT,
                (20+phase*math.max(0,red-redGlow))*self.sx,y)
            band.enemyGlow:SetDimensions(redGlow*self.sx,28*self.sy)
        end
        if blueGlow>=4 then
            band.ownGlow:ClearAnchors()
            band.ownGlow:SetAnchor(TOPLEFT,self.battle,TOPLEFT,
                (20+red+(1-phase)*math.max(0,blue-blueGlow))*self.sx,y)
            band.ownGlow:SetDimensions(blueGlow*self.sx,28*self.sy)
        end
    end
end
function U:Action(action)
    self.app:Act(action)
    if self.app.closeRequested then self.app.closeRequested=false; SCENE_MANAGER:Hide(C.scene) end
    self:Refresh()
end
-- The D-pad arrives as Bindings.xml Down/Up events. Never query ZO_DI_DPAD:
-- it calls the private IsKeyDown and raises an insecure-code UI error on consoles.
function U:DirectionKey(direction,down)
    if not self.active then return end
    if down then self.keyDirection=direction; self:MoveDirection(direction)
    elseif self.keyDirection==direction then self.keyDirection=nil end
end
function U:MoveDirection(direction)
    if not direction then self.heldDirection=nil; return end
    local now=GetFrameTimeSeconds()
    if direction~=self.heldDirection or now>=self.nextMove then
        if direction=="up" then self.app:Move(-1)
        elseif direction=="down" then self.app:Move(1)
        else self.app:MovePage(direction=="right" and 1 or -1) end
        self:Refresh()
        self.nextMove=now+(direction==self.heldDirection and C.input.repeatDelay or C.input.firstRepeat)
        self.heldDirection=direction
    end
end
function U:UpdateDirectionalInput()
    if not self.active then return end
    local x,y=DIRECTIONAL_INPUT:GetXY(ZO_DI_LEFT_STICK)
    local direction=self.keyDirection
    if not direction then
        if math.abs(y)>C.input.deadzone then direction=y>0 and "up" or "down"
        elseif math.abs(x)>C.input.deadzone then direction=x>0 and "right" or "left" end
    end
    self:MoveDirection(direction)
end
-- Anything that changes which texts or lists are shown forces a full Refresh.
local function markers(a)
    local b=a.engine.battle
    return a.screen,a.modal,a.fx,b,b and #b.log,b and b.result,a.tacticScene
end
function U:Changed()
    local screen,modal,fx,b,logs,result,scene=markers(self.app)
    local m=self.refreshMarkers
    return screen~=m[1] or modal~=m[2] or fx~=m[3] or b~=m[4] or logs~=m[5] or result~=m[6] or scene~=m[7]
end
-- Per-tick battle visuals only: gauge bands, bids, timers and coin piles.
-- Row lists, ledgers and headings are rebuilt by the throttled full Refresh.
function U:RefreshBattleFrame()
    local b=self.app.engine.battle
    if not b then return end
    local normalized=(b.gauge+C.battle.gaugeLimit)/(2*C.battle.gaugeLimit)
    self:UpdateBattleBands(normalized)
    self.leftBid:SetText("相手の拠出　"..gold(b.enemyBid).." ゴールド")
    self.rightBid:SetText("自社の拠出　"..gold(b.playerBid).." ゴールド")
    self.status:SetText(string.format("← %s    速度 %+.2f / 加速度 %+.2f    相手待ち %.1f秒    残り %.0f秒    %s →",
        b.mode=="defense" and "防衛成功" or "買収成立",-(b.gaugeSpeed or b.velocity),-b.acceleration,b.enemyWait,math.max(0,C.battle.duration-b.elapsed),b.mode=="defense" and "物件喪失" or "不成立"))
    if self.commandHintText then
        self.commandHint:SetText(string.format("伝令 %.1f秒  |  %s",b.playerWait,self.commandHintText))
    end
    if self.visualBattle~=b then self.visualBattle=b; self.coins=PBTrade.Coins.New(b.effectiveValue) end
    self.coins:SetBid(1,b.enemyBid); self.coins:SetBid(2,b.playerBid)
    self:RenderCoins()
    self:RenderTacticScene()
end
-- UTF-8 aware typewriter: characters are split once per line, text is only
-- rebuilt when the visible count changes.
local function characters(text)
    local chars={}; for ch in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do chars[#chars+1]=ch end
    return chars
end
local function easeOut(t) t=math.min(1,math.max(0,t)); return 1-(1-t)^3 end
local verdictColors={great={1,.84,.38,1},good={.62,.95,.72,1},weak={.86,.8,.62,1},void={.62,.62,.6,1},backfire={1,.42,.38,1}}
-- Line 1 types the move, then the opponent's reaction; line 2 stamps the verdict and effect.
-- The negotiation keeps running underneath and input stays with the trade.
function U:RenderTacticScene()
    local a=self.app; local scene=a.tacticScene
    self.cutin:SetHidden(not scene)
    if not scene then self.cutinState=nil; return end
    local st=self.cutinState
    if not st or st.scene~=scene then
        local head="◆ 駆け引き「"..scene.tactic.name.."」  "
        st={scene=scene,act=characters(head..scene.act),react=characters(head..scene.reaction),head=#characters(head)}
        self.cutinState=st
        self.cutinLine:SetText(""); self.cutinVerdict:SetText("")
        self.cutinVerdict:SetColor(unpack(verdictColors[scene.kind] or T.gold))
    end
    local stage,t=a:TacticStage()
    local S=C.tacticScene
    local chars,elapsed=st.act,scene.time
    if stage~="intro" then chars,elapsed=st.react,scene.time-S.intro end
    -- The tactic name appears at once; only the narration types out.
    local count=math.min(#chars,st.head+math.floor(elapsed*S.typeSpeed))
    if st.chars~=chars or st.count~=count then
        st.chars,st.count=chars,count; self.cutinLine:SetText(table.concat(chars,"",1,count))
    end
    self.cutinStripe:SetWidth(math.max(1,1132*easeOut(stage=="intro" and t or 1)*self.sx))
    if stage=="result" then
        if not st.verdictShown then st.verdictShown=true; self.cutinVerdict:SetText(scene.verdict.."   "..scene.detail) end
        self.cutinVerdict:SetScale(1+.25*(1-easeOut(t*5)))
    else self.cutinVerdict:SetScale(1) end
end
function U:Refresh()
    local a=self.app; local rows=a:Rows(); local row=a:Selected(rows); local b=a.engine.battle
    local m=self.refreshMarkers
    if m[1]~=a.screen and self.active and KEYBIND_STRIP.UpdateKeybindButtonGroup then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybinds)
    end
    m[1],m[2],m[3],m[4],m[5],m[6],m[7]=markers(a)
    self.fullRefreshElapsed=0
    self.subtitle:SetText("薄紅の羅針商会  /  交易台帳  /  第"..a.state.chapter.."章")
    self.stats:SetText("商会資金  "..a.state.cash.."\n総資産  "..M.Assets(a.state).."\n所有  "..#M.Owned(a.state).." 件")
    local campaign=M.CampaignStatus(a.state)
    self.tabs:SetText((a.tab==1 and "◆ " or "◇ ").."地図    "..(a.tab==2 and "◆ " or "◇ ").."所有物件    "
        ..(a.tab==3 and "◆ " or "◇ ").."連合    "..(a.tab==4 and "◆ " or "◇ ").."駆け引き    "
        ..(a.tab==5 and "◆ " or "◇ ").."経営    |  第"..a.state.chapter.."章  "..campaign.current.." / "..campaign.target)
    self.map:SetHidden(a.screen~="map")
    self.ledger:SetHidden(a.screen~="properties" and a.screen~="owned" and a.screen~="groups" and a.screen~="tactics" and a.screen~="management" and a.screen~="rankings")
    self.battle:SetHidden(a.screen~="battle" and a.screen~="result")
    self.notice:SetText(a.notice)
    if a.screen=="map" then
        local mapRows=rows; self.mapPage=math.floor((a.index-1)/C.ui.mapPageSize)
        self.mapHeading:SetText("交易地図・地域索引  "..(self.mapPage+1).." / "..math.ceil(#mapRows/C.ui.mapPageSize).."  |  現在"..#mapRows.."地域")
        for i,pin in ipairs(self.pins) do
            local index=self.mapPage*C.ui.mapPageSize+i
            local z=mapRows[index] and mapRows[index].zone; pin.box:SetHidden(not z)
            if z then
            local counts=M.ZoneSummary(a.state,z.id)
            local color=not a.state.unlocked[z.id] and T.locked
                or (counts.own>0 and T.own or (counts.enemy>0 and T.enemy or T.neutral))
            pin.box:SetCenterColor(color[1],color[2],color[3],.62)
            pin.box:SetEdgeColor(unpack(index==a.index and T.gold or T.edge))
            pin.text:SetText((index==a.index and "◆ " or "")..z.shortName.."\n"..(a.state.unlocked[z.id] and "買収可" or "未開放").." / "..(counts.own+counts.enemy+counts.neutral).."物件")
            end
        end
        if row then
            local z=row.zone; local counts=M.ZoneSummary(a.state,z.id)
            self.mapDetail:SetText(z.name.."\n"..(a.state.visited[z.id] and "交易路調査済み" or "未訪問")
                .."\n\n自社所有："..counts.own.."\n敵商会所有："..counts.enemy.."\n中立："..counts.neutral
                .."\n\n"..(a.state.unlocked[z.id] and "×：地域の物件を見る" or "開放条件：所有 "..(2+z.unlockTier*C.campaign.unlockOwnedStep).." 件")
                .."\n\n緑：自社拠点あり\n赤：敵商会あり\n金茶：中立のみ\n灰：未開放\n※混在地域の内訳は上記参照")
        end
    elseif a.screen=="rankings" then
        self.page=0
        self.ledgerHeading:SetText("商会資金力ランキング  /  交渉・防衛後")
        for i,controls in ipairs(self.rows) do
            local r=a.rankingRows[i]; controls.box:SetHidden(not r)
            if r then
                controls.text:SetText(r.rank.."位  "..r.name.."  "..r.fundingPower..(r.id==C.playerId and "  ★" or ""))
                controls.text:SetColor(unpack(ink))
                controls.box:SetCenterColor(unpack(a.index==i and {.47,.41,.23,.65} or {.04,.065,.05,.36}))
            end
        end
        if row and row.ranking then
            local r=row.ranking
            self.detail:SetText(r.name.."\n現在 "..r.rank.."位 / "..#a.rankingRows.."商会"
                .."\n前回比："..(r.rankChange>0 and "+" or "")..r.rankChange.."\n\n資金力："..r.fundingPower
                .."\n商会現金："..r.cash.."\n物件の調達余力："..r.reserves.."\n\n総資産："..r.assets
                .."\n所有物件："..r.propertyCount.."\n\n資金力＝現金＋物件調達余力\n評価額は総資産にのみ加算。\n\n★：自社 / ↑↓：商会を選択\n× / ○：地域の物件へ")
        end
    elseif a.screen=="properties" or a.screen=="owned" or a.screen=="groups" or a.screen=="tactics" or a.screen=="management" then
        self.page=math.floor((a.index-1)/C.ui.pageSize)
        local heading=a.screen=="owned" and "所有物件" or (a.screen=="groups" and "グループ資金調達"
            or (a.screen=="tactics" and "駆け引き技" or (a.screen=="management" and "商会経営" or "地域の物件")))
        self.ledgerHeading:SetText(heading.."  /  "..#rows.." 件  /  "..(self.page+1).."頁  ←→切替")
        for i,controls in ipairs(self.rows) do
            local index=self.page*C.ui.pageSize+i; local item=rows[index]; controls.box:SetHidden(not item)
            if item then
                if item.tactic then
                    controls.text:SetText((a.index==index and "◆ " or "   ")..item.tactic.name.."  ["..(item.learned and "習得" or "未習得").."]  "..item.tactic.cost.." ゴールド")
                    controls.text:SetColor(unpack(item.learned and ink or {.52,.52,.48,1}))
                elseif item.group then
                    local g=item.group; controls.text:SetText((a.index==index and "◆ " or "   ")..g.name.."  ["..(g.learned and "習得" or "未習得").."]  "..g.count.."/"..g.minimum)
                    controls.text:SetColor(unpack(ink))
                elseif item.property then
                    local p=item.property; local owner=p.owner==C.playerId and "自社" or (p.owner==C.neutralId and "中立" or "敵")
                    local risk=p.owner==C.playerId and M.RiskLabel(p.independenceRisk) or nil
                    local visit=p.canonical and not M.IsPropertyVisited(a.state,p) and "/未訪問" or ""
                    controls.text:SetText((a.index==index and "◆ " or "   ")..p.name.."  ["..owner..(risk and "/"..risk or "")..visit.."]  "..p.marketValue)
                    local riskColor=risk=="離反" and {.53,.53,.53,1} or risk=="危険" and {1,.52,.52,1}
                        or risk=="警戒" and {1,.77,.42,1} or risk=="注意" and {.93,.88,.58,1} or ink
                    controls.text:SetColor(unpack(riskColor))
                else
                    controls.text:SetText((a.index==index and "◆ " or "   ")..item.label)
                    controls.text:SetColor(unpack(item.enabled==false and {.52,.52,.48,1} or ink))
                end
                controls.box:SetCenterColor(unpack(a.index==index and {.47,.41,.23,.65} or {.04,.065,.05,.36}))
            end
        end
        self.detail:SetText(row and (row.detailText or row.tactic and a:TacticDetail(row.tactic)
            or (row.group and a:GroupDetail(row.group) or (row.property and a:Detail(row.property) or a:ManagementDetail(row)))) or "記録はありません")
    elseif b then
        local target=a.state.properties[b.targetId]
        self.battleTitle:SetText((b.mode=="defense" and "商会防衛" or "買収交渉").."  /  "..target.name.."  /  "..D.companies[b.defender].name)
        self:RefreshBattleFrame()
        if row then
            local tabs={}
            for c,category in ipairs(a.battleCategories) do
                tabs[#tabs+1]=((a.battleCategory or 1)==c and "◆ " or "◇ ")..category.name
            end
            self.commandTabs:SetText(table.concat(tabs,"   ").."      ←→ / L1 R1：切替")
            self.command:SetText("‹ "..a.index.."/"..#rows.." ›  "..row.label)
            self.command:SetColor(unpack(row.enabled==false and {.52,.52,.48,1} or ink))
            local hint=row.hint or row.command=="request" and ("要求額 "..a.engine:Quote(row.id).." / 残高 "..row.property.reserve.." / 負担 "..row.property.independenceRisk.." +"..row.property.independenceIncrease)
                or (row.command=="group" and (row.group.count.."件 / 調達倍率 "..row.group.bonus.." / 全構成物件に負担")
                or (row.command=="tactic" and (row.tactic.description.." / コスト "..row.tactic.cost))
                or (row.command=="stabilize" and "最も危険な自社物件の独立危険度を下げる") or "投入資金は返還されません")
            self.commandHintText=hint
            self.commandHint:SetText(string.format("伝令 %.1f秒  |  %s",b.playerWait,hint))
        else self.commandHintText=nil end
        local log={}; for i=math.max(1,#b.log-2),#b.log do log[#log+1]=b.log[i] end; self.log:SetText(table.concat(log,"\n"))
    end
    local modalText=a.modal and a.modal.text
    if a.screen=="result" and not modalText then
        local heading=b.mode=="defense" and (b.result=="won" and "防衛成功 — 商会の旗を守りました" or "防衛不成立 — 物件の所有権を失いました")
            or (b.result=="won" and "契約締結 — 商会に新たな旗印" or "交渉終了 — 帳簿を見直しましょう")
        modalText=heading
            .."\n\n"..a.state.properties[b.targetId].name.."\n自社出資："..b.playerBid.."　相手出資："..b.enemyBid
            .."\n商会資金の消費："..b.treasurySpent.."\n"..(b.result=="timeout" and "交渉期限切れ。" or "")
            ..(#(b.learnedTactics or {})>0 and "\n\n習得："..table.concat((function() local n={}; for _,id in ipairs(b.learnedTactics) do n[#n+1]=D.tacticById[id].name end; return n end)()," / ") or "")
            .."\n\n×："..(b.mode=="defense" and "資金力ランキングへ" or "敵商会の攻撃判定へ")
    end
    local campaignModal=a.modal and a.modal.campaign
    self.campaignBackdrop:SetHidden(not campaignModal); self.campaignShade:SetHidden(not campaignModal)
    if campaignModal and self.campaignAsset~=a.modal.background then
        self.campaignAsset=a.modal.background; PBTrade.Assets.Apply(self.campaignBackdrop,self.campaignAsset)
    end
    self.modal:SetHidden(not modalText); self.modalText:SetText(modalText or "")
    self.fxPanel:SetHidden(not a.fx)
    if a.fx then
        self.fxText:SetText(a.fx.text)
        local colors={discovery={.93,.74,.29,1},defection={1,.38,.34,1},chapter={.67,.86,1,1},
            ending={1,.84,.38,1},settlement={.57,1,.72,1},tactic={.82,.68,1,1}}
        self.fxText:SetColor(unpack(colors[a.fx.kind] or T.gold))
    end
end
-- ESO controls do not expose SetClipsChildren. Crop texture geometry and UVs
-- together using the public TextureControl API, including partially visible rims.
local function clippedTexture(control,parent,x,y,w,h)
    local left,top=math.max(0,x),math.max(0,y)
    local right,bottom=math.min(parent:GetWidth(),x+w),math.min(parent:GetHeight(),y+h)
    local visible=right>left and bottom>top
    control:SetHidden(not visible)
    if not visible then return end
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT,parent,TOPLEFT,left,top)
    control:SetDimensions(right-left,bottom-top)
    control:SetTextureCoords(math.max(0,(left-x)/w),math.min(1,(right-x)/w),
        math.max(0,(top-y)/h),math.min(1,(bottom-y)/h))
end
-- Coin sprites are pooled on demand and capped per frame; creating the full
-- pool at load exhausts the shared per-frame add-on CPU budget on consoles.
function U:CoinControl(side,i)
    local controls=self.coinControls[side]
    local coin=controls[i]
    if coin or self.coinsCreated>=C.coins.createPerFrame then return coin end
    coin=WINDOW_MANAGER:CreateControl(nil,self.coinAreas[side],CT_TEXTURE)
    PBTrade.Assets.Apply(coin,"coin"); coin:SetDimensions(C.coins.width,C.coins.height)
    coin:SetColor(1,1,1,1); coin:SetDrawLayer(DL_CONTROLS); coin:SetDrawLevel(i); coin:SetHidden(true)
    controls[i]=coin; self.coinsCreated=self.coinsCreated+1
    return coin
end
function U:RenderCoins()
    if not self.coins then return end
    self.coinsCreated=0
    for side,controls in ipairs(self.coinControls) do
        local frame=self.coins:Frame(side)
        local viewport=self.coinAreas[side]
        local center=(400*self.sx-C.coins.pileWidth)/2
        for i=1,math.min(#frame.coins,C.coins.limit) do self:CoinControl(side,i) end
        for i,control in ipairs(controls) do
            local coin=frame.coins[i]
            control:SetHidden(not coin)
            if coin then
                clippedTexture(control,viewport,center+coin.x,coin.y,
                    C.coins.width*coin.scale,C.coins.height*coin.scale)
                control:SetColor(coin.shade,coin.shade,coin.shade,1)
            end
        end
        local floor=self.floors[side]
        clippedTexture(floor,viewport,center+(C.coins.pileWidth-C.coins.plinthWidth)/2,
            frame.floorY+C.coins.plinthOffsetY,C.coins.plinthWidth,C.coins.plinthHeight)
        self.depthLabels[side]:SetText((side==1 and "相手の金庫" or "自社の金庫")..(frame.camera>0 and "  /  上層を追従中" or "  /  金貨を積層"))
    end
end
function U:Tick(dt)
    if not self.active then return end
    PBTrade.Assets.PollAll()
    if self.viewportWidth~=GuiRoot:GetWidth() or self.viewportHeight~=GuiRoot:GetHeight() then self:Resize() end
    self.app:Tick(dt)
    if self.coins and (self.app.screen=="battle" or self.app.screen=="result")
        and not (self.app.modal and self.app.modal.pauseBattle) then
        self.bandFxTime=(self.bandFxTime or 0)+dt
        local impacts=self.coins:Tick(dt)
        PBTrade.Audio.Impact(self.coins,impacts)
    end
    -- Full text/list rebuilds allocate heavily (row tables, 1,302-property scans),
    -- so run them at a low rate or on a visible state change; animate every tick.
    local screen=self.app.screen
    self.fullRefreshElapsed=(self.fullRefreshElapsed or 0)+dt
    if self:Changed() or self.fullRefreshElapsed>=C.ui.fullRefreshSeconds then
        self:Refresh()
    elseif screen=="battle" or screen=="result" then
        self:RefreshBattleFrame()
    end
end
