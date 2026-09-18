local E, C, T = PBWT.Engine, PBWT.Config, PBWT.Theme
local UI = {}; UI.__index = UI; PBWT.UI = UI
local unpack = unpack or table.unpack
-- Keep the content above the native gamepad keybind strip; the room stays fullscreen.
local layout = { width=1440, height=900, side=40, top=8, bottom=160 }
local messages = {
    tutorial_goal="金枠と左の案内に沿って操作してください（未消費）",tutorial_next="×で次の練習盤へ進みます",
    invalid_roll="ダイスを振れる手順ではありません", die_rolled="ダイスを振りました", dice_tie="同点です。もう一度双方が振ります",
    dice_decided="出目が決まりました。勝者が選択権を選びます", right_chosen="選択権が決まりました", order_chosen="先攻・後攻が決まりました",
    faction_taken="その同盟は相手が選択済みです", invalid_opening_choice="現在の選択肢を選んでください", opening_required="先にダイスと開始条件を決めてください",
    scroll_invoked="星霜の書を開封。相手の次の手番を凌げば勝利！", scroll_broken="開封を阻止！ 支払った4点と使用権は戻りません",
    scroll_active="星霜の書は開封中です", scroll_spent="この軍の開封は使用済みです", scroll_too_late="最終手番には開封できません",
    scroll_reader="中央に隠密状態でない自軍の木札が必要です", scroll_flags="中央旗を含む2旗以上の支配が必要です",
    scroll_contested="敵が旗上にいる間は開封できません", scroll_score="開封には4点を支払う必要があります",
    finished="対局は終了しています", wrong_turn="手番が違います", own_piece_required="手番側の駒を選んでください",
    outside="盤外です", move_range="縦横の移動範囲内を選んでください", blocked="駒が移動を妨げています",
    no_action="通常行動は使用済みです。カードまたはターン終了を選んでください", enemy_required="敵駒を選んでください",
    attack_range="縦横に隣接する敵を選んでください", hidden="隠密中の斥候は攻撃できません",
    siege_target="旗上の敵守護者を選んでください", no_horn_move="角笛の追加移動はありません",
    choose_faction_required="先に陣営を選択してください", invalid_faction="陣営が不正です", faction_selected="陣営を確定しました",
    no_card_target="この駒には札の有効な対象がありません",
    card_spent="このカードは使用済みです", scout_required="自軍の斥候を選んでください",
    dead_soldier_required="撃破された自軍兵士が必要です", home_required="自軍初期配置の空きマスを選んでください",
    no_neighbors="縦横に隣接する味方がいません", moved="移動しました", defeated="敵駒を撃破しました",
    repelled="防御を崩せませんでした（通常行動を消費）", turn_ended="次の手番です",
    stealth_applied="次の自分の手番まで隠密", revived="兵士が復帰しました", horn_applied="隣接する味方に追加移動を付与しました",
}
local function box(parent, x,y,w,h, color)
    local c=WINDOW_MANAGER:CreateControl(nil,parent,CT_BACKDROP)
    c:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y); c:SetDimensions(w,h)
    c:SetCenterColor(unpack(color or T.wood)); c:SetEdgeColor(unpack(T.brass)); c:SetEdgeTexture("",1,1,2)
    return c
end
-- Solid strips keep board boundaries visible without an edge-texture resource.
local function border(control,w,h,color,level,thickness)
    control.pbwtBorder={}
    local t=thickness or 2
    for _,r in ipairs({{0,0,w,t},{0,h-t,w,t},{0,t,t,h-2*t},{w-t,t,t,h-2*t}}) do
        local line=box(control,r[1],r[2],r[3],r[4],color)
        line:SetEdgeColor(0,0,0,0);line:SetDrawLayer(DL_TEXT);line:SetDrawLevel(level or 1)
        control.pbwtBorder[#control.pbwtBorder+1]=line
    end
end
local function borderColor(control,color)
    control:SetEdgeColor(unpack(color))
    for _,line in ipairs(control.pbwtBorder) do line:SetCenterColor(unpack(color)) end
end
local function label(parent,x,y,w,h,font)
    local c=WINDOW_MANAGER:CreateControl(nil,parent,CT_LABEL)
    c:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y); c:SetDimensions(w,h)
    PBWT.Typography.Apply(c,font or "ZoFontGamepad27",font=="ZoFontGamepad18"); c:SetColor(unpack(T.text)); c:SetDrawLayer(DL_TEXT)
    return c
end
local function focusMarker(parent,w,h)
    local frame=box(parent,-4,-4,w+8,h+8,{0,0,0,0})
    frame:SetEdgeColor(0,0,0,0)
    border(frame,w+8,h+8,T.cursor,6,4)
    local badge=box(frame,w-112,4,112,22,{0.04,0.05,0.06,1})
    badge:SetDrawLayer(DL_TEXT);badge:SetDrawLevel(6)
    local text=label(badge,0,0,112,22,'ZoFontGamepad18')
    text:SetDrawLevel(7);text:SetHorizontalAlignment(TEXT_ALIGN_CENTER);text:SetText('選択中')
    frame:SetHidden(true)
    return frame,text
end
function UI.New(mode,difficulty)
    local self=setmetatable({state=E.New(true),x=1,y=3,focus="board",cardIndex=1,sessions={}},UI)
    self.mode=mode or "solo"
    if self.mode=='tutorial' then self.tutorial=PBWT.Tutorial.New();self.state=self.tutorial.state end
    self.difficulty=PBWT.AI.Difficulty(difficulty)
    if self.mode=="solo" then self.computer=PBWT.Solo.New(self.state,self.difficulty,GetGameTimeMilliseconds) end
    self.notice=self.mode=="solo" and ("あなたはP1、"..self:ComputerName().."はP2です") or "同じ画面で両軍を操作する検証モード"
    local root=WINDOW_MANAGER:CreateTopLevelWindow("PBsWarTableWindow")
    root:SetAnchorFill(GuiRoot); root:SetHidden(true)
    self.root=root
    local screen=box(root,0,0,1,1,{0.055,0.045,0.035,1})
    screen:SetAnchorFill(root); screen:SetDrawLayer(DL_BACKGROUND); screen:SetEdgeColor(0,0,0,0)
    self.screen=screen
    local content=WINDOW_MANAGER:CreateControl(nil,root,CT_CONTROL)
    content:SetDimensions(layout.width,layout.height)
    content:SetAnchor(CENTER,root,CENTER,0,(layout.top-layout.bottom)/2)
    self.content=content; root=content
    local bg=box(root,0,0,1440,900,T.base); self.backdrop=bg; bg:SetDrawLayer(DL_BACKGROUND)
    self.boardFrame=box(root,408,178,612,612,T.wood); self.boardFrame:SetDrawLayer(DL_BACKGROUND)
    self.title=label(root,220,22,1000,52,"ZoFontGamepad42"); self.title:SetText(C.TITLE); self.title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local sub=label(root,360,72,720,30,"ZoFontGamepad22"); sub:SetText(C.SUBTITLE); sub:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.turn=label(root,400,115,640,44); self.turn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.players={label(root,30,155,320,110),label(root,1090,155,320,110)}
    self.details=label(root,30,280,350,505)
    self.scrollPanel=box(root,30,600,350,188)
    self.scrollTitle=label(self.scrollPanel,82,12,258,50,"ZoFontGamepad22")
    self.scrollText=label(self.scrollPanel,12,70,326,110,"ZoFontGamepad18")
    self.scrollPanel:SetMouseEnabled(true)
    self.scrollPanel:SetHandler("OnMouseUp",function(_,button,inside)
        if button==MOUSE_BUTTON_INDEX_LEFT and inside and not self.transition.phase then
            self.focus,self.selected,self.card="scroll",nil,nil; self:Refresh()
        end
    end)
    self.cells={}
    for y=1,C.SIZE do
        for x=1,C.SIZE do
            local cell=box(root,420+(x-1)*120,190+(y-1)*120,110,110,(x+y)%2==0 and T.tile or T.tileAlt)
            border(cell,110,110,T.brass)
            local range=box(cell,6,6,98,98,{0.35,0.75,0.85,0.22}); border(range,98,98,T.cursor); range:SetHidden(true)
            local rangeText=label(range,0,32,98,28,"ZoFontGamepad18"); rangeText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            local icon=WINDOW_MANAGER:CreateControl(nil,cell,CT_TEXTURE)
            icon:SetAnchor(TOP,cell,TOP,0,20); icon:SetDimensions(68,68); icon:SetDrawLayer(DL_TEXT); icon:SetDrawLevel(2)
            local namePanel=box(cell,2,0,106,22,{0.055,0.04,0.025,0.9}); namePanel:SetEdgeColor(0,0,0,0); namePanel:SetHidden(true)
            local name=label(cell,2,0,106,28,"ZoFontGamepad18"); name:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            local flagPanel=box(cell,0,88,110,22,{0.055,0.04,0.025,0.9}); flagPanel:SetEdgeColor(0,0,0,0); flagPanel:SetHidden(true)
            local flag=label(cell,0,82,110,28,"ZoFontGamepad18"); flag:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            local effectPanel=box(cell,3,64,104,22,{0.06,0.04,0.02,0.92}); effectPanel:SetDrawLayer(DL_TEXT); effectPanel:SetEdgeColor(0,0,0,0); effectPanel:SetHidden(true)
            local effect=label(cell,0,64,110,22,"ZoFontGamepad18"); effect:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            for _,panel in ipairs({namePanel,flagPanel,effectPanel}) do panel:SetDrawLayer(DL_TEXT);panel:SetDrawLevel(3) end
            for _,text in ipairs({name,flag,effect,rangeText}) do text:SetDrawLevel(4) end
            local selected=box(cell,5,5,100,100,{0,0,0,0}); border(selected,100,100,T.selected,4); selected:SetEdgeColor(unpack(T.selected)); selected:SetHidden(true)
            local cursor=box(cell,-3,-3,116,116,{0,0,0,0}); border(cursor,116,116,T.cursor,5); cursor:SetEdgeColor(unpack(T.cursor)); cursor:SetHidden(true)
            cell:SetMouseEnabled(true)
            local cx,cy=x,y
            cell:SetHandler("OnMouseEnter",function()
                if self.transition.phase or self.showRecords or self.state.status~="playing" then return end
                self.x,self.y,self.focus=cx,cy,"board"; self:Refresh()
            end)
            cell:SetHandler("OnMouseUp",function(_,button,inside)
                if button==MOUSE_BUTTON_INDEX_LEFT and inside then self.x,self.y,self.focus=cx,cy,"board"; self:Confirm() end
            end)
            self.cells[(y-1)*C.SIZE+x]={root=cell,range=range,rangeText=rangeText,icon=icon,name=name,namePanel=namePanel,flag=flag,flagPanel=flagPanel,effect=effect,effectPanel=effectPanel,selected=selected,cursor=cursor}
        end
    end
    self.cardControls={}
    for i,id in ipairs(C.CARD_ORDER) do
        local panel=box(root,1080,270+(i-1)*84,320,78)
        local text=label(panel,12,12,295,40)
        local marker,markerText=focusMarker(panel,320,78)
        self.cardControls[i]={panel=panel,text=text,focusMarker=marker,focusText=markerText}
    end
    self.endPanel=box(root,1080,710,320,68)
    local endText=label(self.endPanel,12,22,296,32,"ZoFontGamepad22"); endText:SetHorizontalAlignment(TEXT_ALIGN_CENTER); endText:SetText("ターン終了 / 得点確定")
    self.endFocus,self.endFocusText=focusMarker(self.endPanel,320,68)
    self.practiceLabel=label(root,408,156,612,22,"ZoFontGamepad18");self.practiceLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER);self.practiceLabel:SetHidden(true)
    self.status=label(root,360,798,720,42,"ZoFontGamepad22"); self.status:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.footer=label(root,30,844,1380,34,"ZoFontGamepad22")
    self.presentation=PBWT.Presentation.New(self)
    self.factionUI=PBWT.FactionUI.New(self)
    self.movement=PBWT.Movement.New(self)
    self.keybinds={alignment=KEYBIND_STRIP_ALIGN_CENTER,
        {keybind="UI_SHORTCUT_PRIMARY",name=function() return self.mode=="online" and "承諾 / 決定" or (self.state.status=="finished" and "新しい対局" or "決定") end,enabled=function() return not self:IsComputerTurn() end,callback=function() self:Confirm() end},
        {keybind="UI_SHORTCUT_NEGATIVE",name="戻る",callback=function() self:Cancel() end},
        {keybind="UI_SHORTCUT_SECONDARY",name="戦術カード",enabled=function() return not self:IsComputerTurn() end,callback=function() self:OpenCards() end},
        {keybind="UI_SHORTCUT_TERTIARY",name="詳細 / ヘルプ",callback=function() self.help=not self.help; self:Refresh() end},
        {keybind="UI_SHORTCUT_LEFT_SHOULDER",name="前の駒 / 札",callback=function() self:Cycle(-1) end},
        {keybind="UI_SHORTCUT_RIGHT_SHOULDER",name="次の駒 / 札",callback=function() self:Cycle(1) end},
        {keybind="UI_SHORTCUT_LEFT_STICK",name=function() return self.mode=='tutorial' and 'この章をやり直す' or '戦績 / 表示設定' end,callback=function() if self.mode=='tutorial' then self:LoadTutorial(false) else self.showRecords=not self.showRecords; self:Refresh() end end},
        {keybind="UI_SHORTCUT_RIGHT_STICK",name="投了",visible=function() return self.mode=="online" and self.network and self.network.phase=="active" end,callback=function() self:RequestResign() end},
    }
    self.scene=ZO_Scene:New("pbwtBoard",SCENE_MANAGER)
    self.scene:AddFragment(ZO_SimpleSceneFragment:New(self.root))
    self.scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    self.scene:AddFragment(ZO_ActionLayerFragment:New("PBsWarTableInput"))
    self.transition=PBWT.Transition.New(self)
    self.scene:RegisterCallback("StateChange",function(_,state)
        if state==SCENE_SHOWING then
            self.visible=true; self.sceneShown=false
            self.nextInput=0; self.lastDirection=nil; self.heldDirection=nil
            for _,cell in ipairs(self.cells) do
                if cell.icon.pbwtKind and not PBWT.Assets.IsUsable(cell.icon) then PBWT.Assets.Apply(cell.icon,cell.icon.pbwtKind,true) end
            end
            self.presentation:Reopen()
            self:Refresh(); KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds)
            DIRECTIONAL_INPUT:Activate(self,self.root)
            self:SyncComputer()
        elseif state==SCENE_SHOWN then
            self.sceneShown=true; self:SyncComputer()
        elseif state==SCENE_HIDING then
            self.visible=false; self.sceneShown=false; self.heldDirection=nil; self.lastDirection=nil
            self:StopComputer(); self:StopAssetPolling(); self.transition:Cancel(); self.presentation:Stop()
            self.movement:Reset()
            DIRECTIONAL_INPUT:Deactivate(self); KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds)
        end
    end)
    return self
end
function UI:Show()
    if self.transition.phase then return end
    if not self.visible then
        self.transition:Start(function() SCENE_MANAGER:Show("pbwtBoard") end)
    else self:Refresh(); self:SyncComputer() end
end
function UI:StopAssetPolling()
    EVENT_MANAGER:UnregisterForUpdate("PBsWarTableAssets"); self.assetsRunning=false
end
function UI:PollAssets()
    if not self.visible then self:StopAssetPolling(); return end
    self.presentation:Poll()
    local pending=self.presentation:Pending()
    for _,cell in ipairs(self.cells) do
        if cell.hasPiece then
            local usable,done=PBWT.Assets.Poll(cell.icon)
            cell.icon:SetHidden(not usable)
            if not done then pending=true end
        end
    end
    self.movement:HideDestination()
    if not pending then self:StopAssetPolling() end
end
function UI:StartAssetPolling()
    if not self.visible or self.assetsRunning then return end
    if self.presentation:Pending() then
        self.assetsRunning=true
        if not self.assetTick then self.assetTick=function() self:PollAssets() end end
        EVENT_MANAGER:RegisterForUpdate("PBsWarTableAssets",100,self.assetTick)
        return
    end
    for _,cell in ipairs(self.cells) do
        if cell.hasPiece and not cell.icon.pbwtDone then
            self.assetsRunning=true
            if not self.assetTick then self.assetTick=function() self:PollAssets() end end
            EVENT_MANAGER:RegisterForUpdate("PBsWarTableAssets",100,self.assetTick)
            return
        end
    end
end
function UI:IsComputerTurn() return self.computer and self.computer:IsTurn() or false end
function UI:OnlineLocked()
    return self.mode=="online" and (not self.network or not self.network:Playable())
end
function UI:RequestResign()
    if self.transition.phase or self.mode~="online" or not self.network or self.network.phase~="active" or self.network.pending then return end
    self.resignConfirm=true; self:Refresh()
end
function UI:StopComputer()
    EVENT_MANAGER:UnregisterForUpdate("PBsWarTableComputer")
    self.computerRunning=false
    if self.computer then self.computer:Pause() end
end
function UI:SyncComputer()
    if self.visible and self.sceneShown and not self.transition.phase and not (self.movement and self.movement.active) and self:IsComputerTurn() then
        if not self.computerRunning then
            self.computerRunning=true; self.computer:Resume(GetFrameTimeMilliseconds())
            if not self.computerTick then self.computerTick=function() self:TickComputer() end end
            EVENT_MANAGER:RegisterForUpdate("PBsWarTableComputer",C.AI.TICK_MS,self.computerTick)
        end
    else self:StopComputer() end
end
function UI:TickComputer()
    if not self.visible or not self:IsComputerTurn() then self:StopComputer(); return end
    local command,ok,reason=self.computer:Tick(GetFrameTimeMilliseconds())
    if command then
        local action=command.card and PBWT.Cards.definitions[command.card].name or
            (command.type=='roll_dice' and 'ダイスロール' or command.type=='choose_right' and '選択権' or command.type=='choose_order' and '先攻・後攻' or command.type=='choose_faction' and '同盟選択' or command.type=='invoke_scroll' and '星霜の書' or command.type=="attack" and "攻撃" or command.type=="end_turn" and "ターン終了" or "移動")
        self.notice="COM："..action.."  •  "..(messages[reason] or reason or "")
        self.selected,self.card=nil,nil
        self:Refresh(); self:SyncComputer()
    end
end
function UI:ComputerName() return "COM"..C.AI.DIFFICULTIES[self.difficulty].name end
function UI:SessionKey(mode,difficulty) return mode=="solo" and (mode..":"..difficulty) or mode end
function UI:SetMode(mode,difficulty)
    difficulty=PBWT.AI.Difficulty(difficulty or self.difficulty)
    if mode==self.mode and difficulty==self.difficulty then return end
    self:StopComputer();self.movement:Reset()
    self.sessions[self:SessionKey(self.mode,self.difficulty)]={state=self.state,computer=self.computer,tutorial=self.tutorial}
    local session=self.sessions[self:SessionKey(mode,difficulty)]
    self.mode,self.difficulty=mode,difficulty
    self.state=session and session.state or E.New(true)
    self.tutorial=mode=='tutorial' and (session and session.tutorial or PBWT.Tutorial.New()) or nil
    if self.tutorial then self.state=self.tutorial.state end
    self.computer=session and session.computer or (mode=="solo" and PBWT.Solo.New(self.state,difficulty,GetGameTimeMilliseconds) or nil)
    self.selected,self.card,self.focus,self.help=nil,nil,"board",false
    self.showRecords=false
    self.notice=mode=="solo" and ("あなたはP1、"..self:ComputerName().."はP2です") or "同じ画面で両軍を操作する検証モード"
    self:SyncComputer()
end
function UI:NewGame()
    self:StopComputer();self.movement:Reset(); self.state=E.New(true)
    if self.mode=='tutorial' then self.tutorial=PBWT.Tutorial.New();self.state=self.tutorial.state end
    self.computer=self.mode=="solo" and PBWT.Solo.New(self.state,self.difficulty,GetGameTimeMilliseconds) or nil
    self.selected,self.card,self.focus,self.help=nil,nil,"board",false
    self.x,self.y=1,3; self.notice="新しい対局です"
    self:Refresh(); self:SyncComputer()
end
function UI:LoadTutorial(advance)
    self.movement:Reset()
    if advance then self.tutorial:Next() else self.tutorial:Load() end
    self.state=self.tutorial.state;self.x,self.y=1,3
    self.selected,self.card,self.focus,self.help,self.showRecords=nil,nil,'board',false,false
    self.notice='練習盤を準備しました';self:Refresh()
end
function UI:UpdateDirectionalInput()
    -- Called by ESO only while registered. No state/strings/tables rebuilt while idle.
    -- Never query ZO_DI_DPAD: it calls the private IsKeyDown on console clients.
    local x,y=DIRECTIONAL_INPUT:GetXY(ZO_DI_LEFT_STICK_NO_KEYBOARD)
    if self.transition.phase then return end
    local direction=self.heldDirection
    if not direction and math.max(math.abs(x),math.abs(y))>0.4 then
        if math.abs(x)>math.abs(y) then direction=x>0 and "right" or "left"
        else direction=y>0 and "up" or "down" end
    end
    self:MoveDirection(direction)
end
function UI:DirectionKey(direction,down)
    if not self.visible or self.transition.phase then return end
    if down then
        self.heldDirection=direction; self:MoveDirection(direction)
    elseif self.heldDirection==direction then self.heldDirection=nil; self.lastDirection=nil end
end
function UI:MoveDirection(direction)
    if not direction then self.lastDirection=nil; return end
    local now=GetFrameTimeMilliseconds()
    if direction~=self.lastDirection or now>=(self.nextInput or 0) then
        self.nextInput=now+(direction~=self.lastDirection and 300 or 150)
        self.lastDirection=direction; self:Navigate(direction)
    end
end
function UI:Navigate(direction)
    if self.state.status=="setup" and not self.showRecords then self:Cycle((direction=="left" or direction=="up") and -1 or 1); return end
    if self.showRecords then self:Cycle((direction=="left" or direction=="up") and -1 or 1); return end
    if self.focus=="scroll" then
        if direction=="right" then self.focus="board"; self.x=1 end
    elseif self.focus=="cards" then
        if direction=="up" then self.cardIndex=(self.cardIndex-2)%#C.CARD_ORDER+1 end
        if direction=="down" then self.cardIndex=self.cardIndex%#C.CARD_ORDER+1 end
        if direction=="left" then self.focus="board" end
    elseif self.focus=="end" then
        if direction=="left" then self.focus="board" end
        if direction=="up" then self.focus="cards" end
    elseif direction=="right" and self.x==C.SIZE then self.focus="end"
    elseif direction=="right" then self.x=self.x+1
    elseif direction=="left" and self.x==1 and not self.card then self.focus="scroll"; self.selected=nil
    elseif direction=="left" then self.x=math.max(1,self.x-1)
    elseif direction=="up" then self.y=math.max(1,self.y-1)
    elseif direction=="down" then self.y=math.min(C.SIZE,self.y+1) end
    self:Refresh()
end
function UI:Cycle(delta)
    if self.state.status=="setup" and not self.showRecords then
        local choices=PBWT.Opening.Choices(self.state)
        self.factionIndex=((self.factionIndex or 1)-1+delta)%choices+1
        if choices==3 and self.state.factions[3-self.state.player]==self.factionIndex then self.factionIndex=(self.factionIndex-1+(delta<0 and -1 or 1))%3+1 end
        self:Refresh(); return
    end
    if self.showRecords then
        local count=#PBWT.Records.Data().history
        if count>0 then self.recordIndex=((self.recordIndex or 1)-1+delta)%count+1 end
        self:Refresh(); return
    end
    if self.focus=="cards" then
        self.cardIndex=(self.cardIndex-1+delta)%#C.CARD_ORDER+1
    else
        self.focus="board"
        local current=E.At(self.state,self.x,self.y)
        local index=current and current.id or (delta>0 and 0 or 1)
        for _=1,#self.state.pieces do
            index=(index-1+delta)%#self.state.pieces+1
            local p=self.state.pieces[index]
            if p.alive and p.owner==self.state.player then self.x,self.y=p.x,p.y; break end
        end
    end
    self:Refresh()
end
function UI:OpenCards()
    if self.movement.active then return end
    if self.showRecords then
        local data=PBWT.Records.Data(); data.presentation=data.presentation=="light" and "full" or "light"
        self:Refresh(); return
    end
    if self:OnlineLocked() or self.transition.phase or self.state.status~="playing" or self:IsComputerTurn() then return end
    self.focus=self.focus=="cards" and "board" or "cards"
    self.selected,self.card,self.help=nil,nil,false
    self:Refresh()
end
function UI:Cancel()
    if self.showRecords then self.showRecords=false; self:Refresh(); return end
    if self.resignConfirm then self.resignConfirm=nil; self:Refresh(); return end
    if self.mode=="online" and self.network and (self.network.phase=="invited" or self.network.phase=="inviting" or self.network.phase=="accepting" or self.network.phase=="starting") then
        self.network:Decline(); SCENE_MANAGER:Hide("pbwtBoard"); return
    end
    if self.transition.phase then
        if self.visible then SCENE_MANAGER:Hide("pbwtBoard") else self.transition:Cancel() end
        return
    end
    if self.card and self.selected and PBWT.Cards.definitions[self.card].targeting~="home" then
        self.selected=nil; self.notice="対象の自軍駒を選び直してください"; self:Refresh(); return
    end
    if self.card or self.selected or self.focus~="board" or self.help then
        self.card,self.selected,self.focus,self.help=nil,nil,"board",false
        self.notice="選択を取り消しました（未実行の札は消費しません）"; self:Refresh()
    else SCENE_MANAGER:Hide("pbwtBoard") end
end
function UI:Submit(command)
    if self.transition.phase or self.movement.active or self:IsComputerTurn() then return false end
    if self.mode=="online" then
        if not self.network then return false end
        local ok,reason=self.network:Submit(command)
        if not ok then self.network.message=messages[reason] or reason end
        if ok then self.selected,self.card=nil,nil end
        self:Refresh(); return ok
    end
    local ok,reason
    if self.mode=='tutorial' then ok,reason=self.tutorial:Apply(command)
    else ok,reason=E.Apply(self.state,self.state.player,command) end
    self.notice=messages[reason] or reason
    if ok then self.selected,self.card,self.help=nil,nil,false end
    self:Refresh()
    self:SyncComputer()
    return ok
end
function UI:Confirm()
    if self.showRecords then self.showRecords=false; self:Refresh(); return end
    if self.transition.phase or self.movement.active or self:IsComputerTurn() then return end
    if self.mode=='tutorial' and self.tutorial.complete then self:LoadTutorial(true);return end
    if self.mode=="online" then
        if not self.network then return end
        local phase=self.network.phase
        if phase=="invited" then self.network:Accept(); return end
        if (phase=="closed" or phase=="finished") and not self.network.pending then PBWT.Open("solo"); return end
        if self.resignConfirm then self.resignConfirm=nil; self:Submit({type="resign"}); return end
        if not self.network:Playable() then return end
    end
    local s=self.state
    if s.status=="setup" then
        local command
        if (self.mode=='online' or self.mode=='tutorial') and (s.opening=='roll' or s.opening=='reroll') then command={type='roll_dice'}
        else command=PBWT.Opening.Command(s,self.factionIndex or 1) end
        self:Submit(command);return
    end
    if s.status=="finished" then
        self:NewGame(); return
    end
    if self.focus=="end" then
        self.focus="board"; self:Submit({type="end_turn"}); return
    end
    if self.focus=="scroll" then self:Submit({type="invoke_scroll"}); return end
    if self.focus=="cards" then
        local id=C.CARD_ORDER[self.cardIndex]
        if not s.cards[s.player][id] then self.notice=messages.card_spent; self:Refresh(); return end
        self.card,self.selected,self.focus,self.help=id,nil,"board",false
        if PBWT.Cards.definitions[id].targeting=="home" then
            for _,p in ipairs(s.pieces) do
                if p.owner==s.player and p.kind=="soldier" and not p.alive then self.selected=p.id; break end
            end
            if not self.selected then self.notice=messages.dead_soldier_required; self.card=nil; self:Refresh(); return end
        end
        self.notice="札の対象を指定してください"; self:Refresh(); return
    end
    local p=E.At(s,self.x,self.y)
    if self.card then
        local targeting=PBWT.Cards.definitions[self.card].targeting
        if (targeting=="destination" or targeting=="enemy") and not self.selected then
            local ok,reason=PBWT.Cards.SourceAt(s,s.player,self.card,self.x,self.y)
            if ok then self.selected=p.id; self.notice=targeting=="enemy" and "攻撃対象を選んでください" or "移動先を選んでください"
            else self.notice=messages[reason] or reason end
            self:Refresh(); return
        end
        self:Submit(PBWT.Cards.CommandAt(s,self.card,self.selected,self.x,self.y)); return
    end
    if not self.selected then
        if p and p.owner==s.player then self.selected=p.id; self.notice="空きマスへ移動、隣接敵へ攻撃"
        else self.notice=messages.own_piece_required end
        self:Refresh(); return
    end
    if p and p.owner==s.player then self.selected=p.id; self:Refresh(); return end
    if p then self:Submit({type="attack",id=self.selected,target=p.id})
    else
        local selected=E.Piece(s,self.selected)
        local useHorn=s.horn[self.selected] and math.abs(selected.x-self.x)+math.abs(selected.y-self.y)==1
        self:Submit({type=useHorn and "horn_move" or "move",id=self.selected,x=self.x,y=self.y})
    end
end
-- Called only on input/state refresh; uses the same validators as actual play.
function UI:CardTargetAt(x,y)
    local s=self.state
    local targeting=PBWT.Cards.definitions[self.card].targeting
    if not self.selected and (targeting=="destination" or targeting=="enemy") then
        return PBWT.Cards.SourceAt(s,s.player,self.card,x,y)
    end
    return PBWT.Cards.Preview(s,s.player,PBWT.Cards.CommandAt(s,self.card,self.selected,x,y))
end
-- Read-only preview: shared path validation, no state clone or idle updates.
-- Other seats / out-of-turn pieces show a clearly labelled reference range.
function UI:MovementSource()
    local s=self.state
    if s.status~="playing" or self.card or self.focus~="board" or self.showRecords or self.resignConfirm or self:OnlineLocked() then return end
    local p=E.At(s,self.x,self.y) or E.Piece(s,self.selected)
    if not p or not p.alive then return end
    local seat=self.mode=="online" and self.network.seat or self.mode=="solo" and 1 or s.player
    return p,p.owner~=seat or p.owner~=s.player
end
function UI:MovementAt(p,reference,x,y)
    if not p then return end
    local s=self.state
    if reference then
        if E.CanMove(s,p,x,y,E.MoveRange(s,p)) then return "reference" end
    else
        -- Match Confirm's priority: a one-square step spends the horn token first.
        if s.horn[p.id] and E.CanMove(s,p,x,y,C.HORN_DISTANCE) then return "horn" end
        if s.actions>0 and E.CanMove(s,p,x,y,E.MoveRange(s,p)) then return "move" end
    end
end
local rangeStyles={
    move={color={0.57,0.88,0.96,1},text="移動"},
    horn={color={0.98,0.79,0.35,1},text="角笛"},
    reference={color={0.82,0.61,0.60,1},text="参考"},
}
function UI:Refresh()
    local s=self.state
    local step=s.opening..':'..s.player..':'..s.rollRound
    if self.openingStep~=step then
        self.openingStep=step;self.factionIndex=1
        if s.status=='setup' and PBWT.Opening.Choices(s)==3 and s.factions[3-s.player]==1 then self.factionIndex=2 end
    end
    if self.mode=="solo" then PBWT.Records.Record(s,"solo",self.difficulty,1) end
    -- The opaque screen always fills GuiRoot. Only the safe-area content scales.
    self.content:SetScale(math.min((GuiRoot:GetWidth()-2*layout.side)/layout.width,
        (GuiRoot:GetHeight()-layout.top-layout.bottom)/layout.height))
    self.turn:SetText(string.format("手番 %d / %d  •  %s  •  通常行動 %d",s.turn,C.MAX_TURNS,self:IsComputerTurn() and "COM思考中" or "P"..s.player,s.actions))
    if s.scrollOwner~=0 and s.status=='playing' then
        self.turn:SetText('P'..s.scrollOwner..' 星霜開封中 • P'..(3-s.scrollOwner)..'の手番終了で決着')
    end
    self.footer:SetText((self.mode=="solo" and self:ComputerName() or "ローカル検証").."  •  左端から左：星霜の書 / 右端から右：終了  •  ○：戻る  □：札  △：詳細  L3：戦績")
    if self.mode=="online" and self.network then self.footer:SetText("対人 P"..self.network.seat.." • 左端から左：星霜 / 右端から右：終了 • R3：投了 • 再表示 /pbwt online") end
    if s.status=="setup" then
        self.turn:SetText("対局準備  •  P"..s.player.."の選択 / ロール")
        self.footer:SetText("十字キー / L1・R1：選択切替　×：ロール / 確定　○：閉じる　L3：戦績")
    end
    for player=1,2 do
        local flags,pieces=E.Counts(s,player)
        self.players[player]:SetColor(unpack(T.Player(player,s)))
        local name=self.mode=="solo" and (player==1 and "あなた" or self:ComputerName()) or (player==s.player and "手番" or "待機")
        if self.mode=="online" and self.network then name=player==self.network.seat and "あなた" or "対戦相手" end
        local faction=PBWT.Factions.Get(s,player)
        if faction then name=name.." / "..faction.short end
        PBWT.Typography.Apply(self.players[player],"ZoFontGamepad22")
        self.players[player]:SetText(string.format("P%d  %s\n%d / %d点\n旗 %d  •  駒 %d",player,name,s.score[player],C.WIN_SCORE,flags,pieces))
    end
    local rangePiece,rangeReference=self:MovementSource()
    for y=1,C.SIZE do for x=1,C.SIZE do
        local cell=self.cells[(y-1)*C.SIZE+x]
        local kind=self:MovementAt(rangePiece,rangeReference,x,y)
        cell.rangeKind=kind; cell.range:SetHidden(not kind)
        if kind then
            local style=rangeStyles[kind]; local color=style.color
            cell.range:SetCenterColor(color[1],color[2],color[3],0.24)
            borderColor(cell.range,color); cell.rangeText:SetColor(unpack(color)); cell.rangeText:SetText(style.text)
        end
        local p=E.At(s,x,y)
        cell.name:SetText(p and ("P"..p.owner.." "..C.PIECES[p.kind].name) or "")
        cell.namePanel:SetHidden(not p)
        cell.hasPiece=p~=nil
        cell.icon:SetHidden(true)
        if p then
            PBWT.Assets.Apply(cell.icon,PBWT.Assets.PieceKind(p.kind))
            if PBWT.Assets.IsUsable(cell.icon) then cell.icon.pbwtDone=true; cell.icon:SetHidden(false) end
            local wooden=cell.icon.pbwtKind~=p.kind
            if wooden then cell.icon:SetColor(1,1,1,1) else cell.icon:SetColor(unpack(T.Player(p.owner,s))) end
            cell.name:SetColor(unpack(T.Player(p.owner,s)))
        end
        local owner,index=E.Flag(s,x,y)
        cell.flagPanel:SetHidden(not index)
        cell.flag:SetText(index and (C.FLAGS[index].points.."点 "..(owner==0 and "中立" or "P"..owner)) or "")
        cell.flag:SetColor(unpack(owner and owner~=0 and T.Player(owner,s) or T.text))
        local eligible=self.card and self:CardTargetAt(x,y)
        local practice=self.mode=='tutorial' and self.tutorial:TargetAt(x,y)
        borderColor(cell.root,(eligible or practice) and T.selected or T.brass)
        local effects=p and ((s.scrollOwner~=0 and s.scrollReader==p.id and "開封 " or "")..(p.hiddenUntil and (eligible and "隠 " or "隠密 ") or "")..(s.horn[p.id] and (eligible and "笛 " or "角笛 ") or "")) or ""
        cell.effect:SetText(effects..(eligible and "対象" or ""))
        cell.effectPanel:SetHidden(effects=="" and not eligible)
        cell.selected:SetHidden(not p or (self.selected~=p.id and not (s.scrollOwner~=0 and s.scrollReader==p.id and s.status=='playing')))
        cell.cursor:SetHidden(self.focus~="board" or self.x~=x or self.y~=y)
    end end
    local focusVisible=s.status=="playing" and not self.showRecords
    for i,id in ipairs(C.CARD_ORDER) do
        local row=self.cardControls[i]
        local focused=focusVisible and self.focus=="cards" and self.cardIndex==i
        row.focusMarker:SetHidden(not focused)
        row.focusText:SetText(self.mode=="tutorial" and self.tutorial.complete and "次章へ" or "選択中")
        local hand=self.mode=="online" and self.network and self.network.seat or s.player
        row.text:SetText(PBWT.Cards.definitions[id].name..(s.cards[hand][id] and (self.card==id and "  対象選択中" or "  未使用") or "  使用済"))
        row.text:SetAlpha(s.cards[hand][id] and 1 or 0.5)
        row.panel:SetEdgeColor(unpack(self.focus=="cards" and self.cardIndex==i and T.cursor or T.brass))
    end
    self.endPanel:SetEdgeColor(unpack(self.focus=="end" and T.cursor or T.brass))
    self.endFocus:SetHidden(not (focusVisible and self.focus=="end"))
    self.endFocusText:SetText(self.mode=="tutorial" and self.tutorial.complete and "次章へ" or "選択中")
    self.practiceLabel:SetHidden(self.mode~="tutorial" or s.status=="setup" or self.showRecords)
    if self.mode=="tutorial" then
        local _,own=E.Counts(s,1);local _,opponent=E.Counts(s,2)
        self.practiceLabel:SetText(string.format("練習用配置：P1 %d枚 / P2 %d枚（章ごとに変更）",own,opponent))
    end
    local seat=self.mode=="online" and self.network and self.network.seat or self.mode=="solo" and 1 or s.player
    local canOpen,scrollWhy=PBWT.Scroll.CanInvoke(s,seat)
    local scrollVisible=s.status~="setup" and not self.showRecords and not self.help and not self.card and self.focus~="cards"
    self.scrollPanel:SetHidden(not scrollVisible)
    self.scrollPanel:SetEdgeColor(unpack(self.focus=="scroll" and T.cursor or s.scrollOwner~=0 and T.selected or T.brass))
    self.scrollTitle:SetText("星霜の書\n"..(s.reason=='elder_scroll' and '帝位の宣告' or s.scrollOwner~=0 and "運命の開封" or canOpen and "×：4点を払い開封" or "左端から左で詳細"))
    self.scrollText:SetText(PBWT.Scroll.Text(s,seat))
    self.details:SetDimensions(350,scrollVisible and 305 or 505)
    local p=E.At(s,self.x,self.y)
    local text
    if self.showRecords then
        text=PBWT.Records.Text(self.recordIndex)
    elseif self.focus=="scroll" then
        text="星霜の書 — 帝位の宣告\n\n開封には4点と通常行動を消費。\n相手の次の手番終了まで維持すれば勝利。\n読者は防御1。移動・隠密でも失敗。\n敵の旗進入でも即座に失敗。\n失敗時の返金・再使用なし。\n相手の10点到達が先なら敗北。\n\n"..(canOpen and "×：開封 / ○・右：戻る" or (messages[scrollWhy] or scrollWhy))
    elseif self.help then
        text="1手番に1駒を移動か攻撃。\n攻撃≧防御で撃破。\n旗は手番終了時に制圧。\n支配旗から1 / 2 / 1点。\n10点先取。30手番で判定。\n\n星霜の書：左端から左で詳細。\n4点＋通常行動で開封、\n相手の次の手番を凌げば勝利。\n敵の旗進入か読者撃破で阻止。\n\n□で札、○で解除。右端から右で終了。"
    elseif self.card or self.focus=="cards" then
        local id=self.card or C.CARD_ORDER[self.cardIndex]
        text=PBWT.Cards.definitions[id].name.."\n\n"..PBWT.Cards.definitions[id].description
        if self.card then
            local targeting=PBWT.Cards.definitions[id].targeting
            local sourceStage=not self.selected and (targeting=="destination" or targeting=="enemy")
            local prompt=sourceStage and "自軍駒を選択" or targeting=="home" and "復帰先の空きマスを選択" or targeting=="destination" and "移動先を選択" or targeting=="enemy" and "旗上の敵守護者を選択" or "対象の自軍駒を選択"
            local valid,reason=self:CardTargetAt(self.x,self.y)
            text=text.."\n\n"..prompt.."\n金枠・対象：選択可能\n\n"
            if sourceStage then text=text..(valid and "×：この駒を選択" or (messages[reason] or reason))
            elseif valid then
                text=text.."予測："..(messages[reason] or reason)
                if id=="siege" and p then
                    local attacker=E.Piece(s,self.selected)
                    text=text..string.format("\n攻撃%d / 防御%d→%d",E.Attack(s,attacker),E.Defense(s,p),E.Defense(s,p,true))
                end
                text=text.."\n×で実行・札を消費"
            else text=text..(messages[reason] or reason) end
        end
    elseif p then
        local spec=C.PIECES[p.kind]
        text=string.format("P%d %s\n攻撃 %d / 防御 %d\n移動 縦横%dマス\n%s%s",p.owner,spec.name,E.Attack(s,p),E.Defense(s,p),E.MoveRange(s,p),p.hiddenUntil and "隠密中\n" or "",s.horn[p.id] and "角笛：追加1マス移動可\n" or "")
        local faction=PBWT.Factions.Get(s,p.owner)
        if faction then text=text.."\n"..faction.short.."："..faction.ability.."\n"..faction.description end
        if self.selected and p.owner~=s.player then
            local attacker=E.Piece(s,self.selected)
            local ok,why=E.CanAttack(s,attacker,p,false)
            text=text.."\n"..(ok and (E.Attack(s,attacker)>=E.Defense(s,p) and "攻撃予測：撃破" or "攻撃予測：防御を崩せない") or (messages[why] or why))
        end
    else text="三つの旗を奪い合う戦卓。\n\n駒を選び、移動先か敵を決定してください。\n\n旗は空けても支配が続きます。\n\n△：ルールを表示" end
    if rangePiece and not self.help then
        text=text.."\n\n"..(rangeReference and "参考範囲（現在の行動可否は含まない）" or "青白：移動 / 金：角笛")
    end
    PBWT.Typography.Apply(self.details,(scrollVisible or self.showRecords or rangePiece or self.help) and "ZoFontGamepad22" or "ZoFontGamepad27")
    self.details:SetText(text)
    self.presentation:Refresh()
    self.factionUI:Refresh()
    if s.status=="finished" then
        self.status:SetText((s.winner==0 and "引き分け" or "P"..s.winner.."の勝利").."  •  "..(s.reason=="elder_scroll" and "星霜の書による決着" or s.reason=="score" and "10点到達" or "30手番判定").."  •  ×で新規対局")
    else self.status:SetText(self.notice or "") end
    if self.mode=="online" and self.network then
        if self.network.phase=="closed" then self.status:SetText(self.network.message.."  •  ×で戻る")
        elseif s.status=="finished" then
            self.status:SetText((s.winner==0 and "引き分け" or s.winner==self.network.seat and "あなたの勝利" or "相手の勝利")..(s.reason=="elder_scroll" and "（星霜の書）" or s.reason=="resign" and "（投了）" or "")..(self.network.pending and " • 同期確認中" or " • ×で戻る"))
        else self.status:SetText(self.resignConfirm and "投了しますか？ ×：投了 / ○：取消" or self.network.message or "") end
    end
    if self.mode=='tutorial' then
        if not self.card and self.focus~='cards' then
            self.scrollPanel:SetHidden(self.focus~='scroll')
            self.details:SetDimensions(350,self.focus=='scroll' and 305 or 505)
            PBWT.Typography.Apply(self.details,'ZoFontGamepad22')
            self.details:SetText(self.focus=='scroll' and ('星霜の書の練習\n\n×：4点＋通常行動で開封。\n中央含む2旗支配が必要です。\n読者は防御1。敵の旗進入でも失敗。\n\n開封後は○か右で盤へ戻り、\n右端から右でターン終了。\n今回は相手がパスします。') or self.tutorial:Text())
        end
        self.status:SetText(string.format('チュートリアル %d/%d：%s',self.tutorial.index,#PBWT.Tutorial.lessons,self.tutorial.complete and '成功！ ×で次章の練習配置へ' or self.notice or self.tutorial.lesson.title))
        self.footer:SetText('練習専用・戦績対象外 • ×：決定 / 成功後は次へ • □：札 • L3：章をやり直す • ○：戻る / 閉じる')
        if self.state.status=='setup' then self.factionUI.guide:SetText('練習用の出目：あなた5 / 相手2。×：ロール・確定') end
    end
    self.movement:Observe()
    if self.scene and self.scene:IsShowing() then KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybinds) end
    self:StartAssetPolling()
    self:SyncComputer()
end
