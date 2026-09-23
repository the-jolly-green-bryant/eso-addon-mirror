local E, C, T = PBWT.Engine, PBWT.Config, PBWT.Theme
local UI = {}; UI.__index = UI; PBWT.UI = UI
local unpack = unpack or table.unpack
-- Keep the content above the native gamepad keybind strip; the room stays fullscreen.
local layout = { width=1440, height=900, side=40, top=8, bottom=160 }
local messages=setmetatable({},{__index=function(_,key) return PBWT.L("msg_"..key) end})
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
local function resizeBorder(control,w,h,thickness)
    local t=thickness or 2
    for i,r in ipairs({{0,0,w,t},{0,h-t,w,t},{0,t,t,h-2*t},{w-t,t,t,h-2*t}}) do
        local line=control.pbwtBorder[i]
        line:SetAnchor(TOPLEFT,control,TOPLEFT,r[1],r[2]); line:SetDimensions(r[3],r[4])
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
    text:SetDrawLevel(7);text:SetHorizontalAlignment(TEXT_ALIGN_CENTER);text:SetText(PBWT.L("ui_selected_badge"))
    frame:SetHidden(true)
    return frame,text
end
function UI.New(mode,difficulty,variant)
    variant=C.VARIANTS[variant] and variant or "light"
    local self=setmetatable({state=E.New(true,variant),variant=variant,x=1,y=3,focus="board",cardIndex=1,sessions={}},UI)
    self.mode=mode or "solo"
    if self.mode=='tutorial' then self.tutorial=PBWT.Tutorial.New();self.state=self.tutorial.state end
    self.difficulty=PBWT.AI.Difficulty(difficulty)
    if self.mode=="solo" then self.computer=PBWT.Solo.New(self.state,self.difficulty,GetGameTimeMilliseconds) end
    self.notice=self.mode=="solo" and PBWT.L("ui_solo_notice",self:ComputerName()) or PBWT.L("ui_local_notice")
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
    self.title=label(root,220,22,1000,52,"ZoFontGamepad42"); self.title:SetText(C.Title()); self.title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.subtitle=label(root,360,72,720,30,"ZoFontGamepad22"); self.subtitle:SetText(C.Subtitle()); self.subtitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.turn=label(root,400,101,640,44); self.turn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.playerPanels={box(root,24,148,336,124),box(root,1084,148,336,124)}
    self.players={label(self.playerPanels[1],26,18,246,96),label(self.playerPanels[2],26,18,246,96)}
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
    for y=1,C.MAX_BOARD do
        for x=1,C.MAX_BOARD do
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
            self.cells[(y-1)*C.MAX_BOARD+x]={root=cell,range=range,rangeText=rangeText,icon=icon,name=name,namePanel=namePanel,flag=flag,flagPanel=flagPanel,effect=effect,effectPanel=effectPanel,selected=selected,cursor=cursor,x=x,y=y}
        end
    end
    self.cardControls={}
    for i,id in ipairs(C.CARD_ORDER) do
        local panel=box(root,1080,270+(i-1)*72,320,68)
        local text=label(panel,12,8,295,40)
        local marker,markerText=focusMarker(panel,320,68)
        self.cardControls[i]={panel=panel,text=text,focusMarker=marker,focusText=markerText}
    end
    self.endPanel=box(root,1080,710,320,68)
    self.endText=label(self.endPanel,12,22,296,32,"ZoFontGamepad22"); self.endText:SetHorizontalAlignment(TEXT_ALIGN_CENTER); self.endText:SetText(PBWT.L("ui_end_button"))
    self.endFocus,self.endFocusText=focusMarker(self.endPanel,320,68)
    self.practiceLabel=label(root,408,150,612,22,"ZoFontGamepad18");self.practiceLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER);self.practiceLabel:SetHidden(true)
    self.status=label(root,360,808,720,42,"ZoFontGamepad22"); self.status:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.footer=label(root,30,854,1380,34,"ZoFontGamepad22")
    self.presentation=PBWT.Presentation.New(self)
    self.factionUI=PBWT.FactionUI.New(self)
    self.movement=PBWT.Movement.New(self)
    self.keybinds={alignment=KEYBIND_STRIP_ALIGN_CENTER,
        {keybind="UI_SHORTCUT_PRIMARY",name=function() return self.mode=="online" and PBWT.L("ui_accept") or (self.state.status=="finished" and PBWT.L("ui_new_match") or PBWT.L("ui_confirm")) end,enabled=function() return not self:IsComputerTurn() end,callback=function() self:Confirm() end},
        {keybind="UI_SHORTCUT_NEGATIVE",name=PBWT.L("ui_back"),callback=function() self:Cancel() end},
        {keybind="UI_SHORTCUT_SECONDARY",name=PBWT.L("ui_cards"),enabled=function() return not self:IsComputerTurn() end,callback=function() self:OpenCards() end},
        {keybind="UI_SHORTCUT_TERTIARY",name=PBWT.L("ui_details"),callback=function() self.help=not self.help; self:Refresh() end},
        {keybind="UI_SHORTCUT_LEFT_SHOULDER",name=PBWT.L("ui_prev"),callback=function() self:Cycle(-1) end},
        {keybind="UI_SHORTCUT_RIGHT_SHOULDER",name=PBWT.L("ui_next"),callback=function() self:Cycle(1) end},
        {keybind="UI_SHORTCUT_LEFT_STICK",name=function() return self.mode=='tutorial' and PBWT.L("ui_retry_chapter") or PBWT.L("ui_records_button") end,callback=function() if self.mode=='tutorial' then self:LoadTutorial(false) else self.showRecords=not self.showRecords; self:Refresh() end end},
        {keybind="UI_SHORTCUT_RIGHT_STICK",name=PBWT.L("ui_resign"),visible=function() return self.mode=="online" and self.network and self.network.phase=="active" end,callback=function() self:RequestResign() end},
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
            PBWT.Audio.Music(true)
            self:SyncComputer()
        elseif state==SCENE_SHOWN then
            self.sceneShown=true; self:SyncComputer()
        elseif state==SCENE_HIDING then
            self.visible=false; self.sceneShown=false; self.heldDirection=nil; self.lastDirection=nil
            self:StopComputer(); self:StopAssetPolling(); self.transition:Cancel(); self.presentation:Stop()
            PBWT.Audio.Music(false)
            self.movement:Reset()
            DIRECTIONAL_INPUT:Deactivate(self); KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds)
        end
    end)
    return self
end
-- One control set covers every board. Sizes and offsets scale from the 110px cell of the
-- light board, and squares outside the current variant are hidden.
function UI:Cell(x,y) return self.cells[(y-1)*C.MAX_BOARD+x] end
function UI:LayoutBoard()
    local size=E.Rules(self.state).SIZE
    if self.boardSize==size then return end
    self.boardSize=size
    local pitch=math.floor(600/size)
    local gap=math.max(4,math.floor(pitch*0.084+0.5))
    local cellSize=pitch-gap
    local originX,originY=420+math.floor((600-pitch*size)/2),190+math.floor((600-pitch*size)/2)
    local k=cellSize/110
    local function scale(v) return math.floor(v*k+0.5) end
    for y=1,C.MAX_BOARD do for x=1,C.MAX_BOARD do
        local cell=self:Cell(x,y)
        local inside=x<=size and y<=size
        cell.root:SetHidden(not inside)
        if not inside then
            -- Squares the smaller board does not use must not keep the other board's tablets.
            cell.hasPiece=nil; cell.rangeKind=nil
            cell.icon:SetHidden(true); cell.range:SetHidden(true)
            cell.name:SetText(""); cell.flag:SetText(""); cell.effect:SetText("")
            cell.namePanel:SetHidden(true); cell.flagPanel:SetHidden(true); cell.effectPanel:SetHidden(true)
            cell.selected:SetHidden(true); cell.cursor:SetHidden(true)
            if cell.flagIcon then cell.flagIcon:SetHidden(true) end
        end
        if inside then
            cell.root:SetAnchor(TOPLEFT,self.content,TOPLEFT,originX+(x-1)*pitch,originY+(y-1)*pitch)
            cell.root:SetDimensions(cellSize,cellSize)
            resizeBorder(cell.root,cellSize,cellSize)
            local inset=scale(6)
            cell.range:SetAnchor(TOPLEFT,cell.root,TOPLEFT,inset,inset)
            cell.range:SetDimensions(cellSize-inset*2,cellSize-inset*2)
            resizeBorder(cell.range,cellSize-inset*2,cellSize-inset*2)
            cell.rangeText:SetAnchor(TOPLEFT,cell.range,TOPLEFT,0,scale(32))
            cell.rangeText:SetDimensions(cellSize-inset*2,scale(28))
            cell.icon:SetAnchor(TOP,cell.root,TOP,0,scale(20)); cell.icon:SetDimensions(scale(68),scale(68))
            cell.namePanel:SetAnchor(TOPLEFT,cell.root,TOPLEFT,scale(2),0)
            cell.namePanel:SetDimensions(cellSize-scale(4),scale(22))
            cell.name:SetAnchor(TOPLEFT,cell.root,TOPLEFT,scale(2),0)
            cell.name:SetDimensions(cellSize-scale(4),scale(28))
            -- Full keep names are wider than a square on the 9x9 board, so their strip spans
            -- the neighbouring columns; keeps sit two columns apart, so the strips never meet.
            local wide=size>5
            local nameWidth=wide and pitch*2 or cellSize
            local nameLeft=(cellSize-nameWidth)/2
            cell.flagPanel:SetAnchor(TOPLEFT,cell.root,TOPLEFT,nameLeft,cellSize-scale(22))
            cell.flagPanel:SetDimensions(nameWidth,scale(22))
            local textInset=(cell.flagIcon and not wide) and scale(24) or 0
            local textPad=wide and 6 or 0 -- keeps the name clear of the strip's edges
            cell.flag:SetAnchor(TOPLEFT,cell.root,TOPLEFT,nameLeft+textInset+textPad,cellSize-scale(28))
            cell.flag:SetDimensions(nameWidth-textInset-textPad*2,scale(28))
            if cell.flagIcon then
                -- The banner marker only fits beside the short labels of the light board.
                cell.flagIcon:SetHidden(wide)
                cell.flagIcon:SetAnchor(TOPLEFT,cell.root,TOPLEFT,scale(5),cellSize-scale(20))
                cell.flagIcon:SetDimensions(scale(18),scale(18))
            end
            cell.effectPanel:SetAnchor(TOPLEFT,cell.root,TOPLEFT,scale(3),scale(64))
            cell.effectPanel:SetDimensions(cellSize-scale(6),scale(22))
            cell.effect:SetAnchor(TOPLEFT,cell.root,TOPLEFT,0,scale(64))
            cell.effect:SetDimensions(cellSize,scale(22))
            cell.selected:SetAnchor(TOPLEFT,cell.root,TOPLEFT,scale(5),scale(5))
            cell.selected:SetDimensions(cellSize-scale(10),cellSize-scale(10))
            resizeBorder(cell.selected,cellSize-scale(10),cellSize-scale(10),4)
            cell.cursor:SetAnchor(TOPLEFT,cell.root,TOPLEFT,-scale(3),-scale(3))
            cell.cursor:SetDimensions(cellSize+scale(6),cellSize+scale(6))
            resizeBorder(cell.cursor,cellSize+scale(6),cellSize+scale(6),5)
        end
    end end
    self.boardGeom={originX=originX,originY=originY,pitch=pitch,cellSize=cellSize,
        icon=scale(68),iconTop=scale(20),k=k}
    local frame=pitch*(size-1)+cellSize+22
    self.boardFrame:SetAnchor(TOPLEFT,self.content,TOPLEFT,originX-12,originY-12)
    self.boardFrame:SetDimensions(frame,frame)
    if self.presentation and self.presentation.board then
        self.presentation.board:SetDimensions(frame,frame)
    end
    self.x=math.min(self.x,size); self.y=math.min(self.y,size)
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
        local action=command.card and PBWT.Cards.Name(command.card) or
            (command.type=='roll_dice' and PBWT.L("ui_act_roll") or command.type=='choose_right' and PBWT.L("ui_act_right") or command.type=='choose_order' and PBWT.L("ui_act_order") or command.type=='choose_faction' and PBWT.L("ui_act_faction") or command.type=='invoke_scroll' and PBWT.L("ui_scroll_title") or command.type=="attack" and PBWT.L("ui_range_attack") or command.type=="end_turn" and PBWT.L("ui_range_end") or PBWT.L("ui_range_move"))
        self.notice="COM："..action.."  •  "..(messages[reason] or reason or "")
        self.selected,self.card=nil,nil
        self:Refresh(); self:SyncComputer()
    end
end
function UI:ComputerName() return PBWT.L("com_name",C.LevelName(self.difficulty)) end
function UI:SessionKey(mode,difficulty,variant)
    variant=variant or self.variant
    return (mode=="solo" and (mode..":"..difficulty) or mode)..":"..variant
end
function UI:SetMode(mode,difficulty,variant)
    difficulty=PBWT.AI.Difficulty(difficulty or self.difficulty)
    variant=C.VARIANTS[variant] and variant or (mode=="tutorial" and "light" or self.variant)
    if mode==self.mode and difficulty==self.difficulty and variant==self.variant then return end
    self:StopComputer();self.movement:Reset()
    self.sessions[self:SessionKey(self.mode,self.difficulty,self.variant)]={state=self.state,computer=self.computer,tutorial=self.tutorial}
    local session=self.sessions[self:SessionKey(mode,difficulty,variant)]
    self.mode,self.difficulty,self.variant=mode,difficulty,variant
    self.state=session and session.state or E.New(true,variant)
    self.tutorial=mode=='tutorial' and (session and session.tutorial or PBWT.Tutorial.New()) or nil
    if self.tutorial then self.state=self.tutorial.state end
    self.computer=session and session.computer or (mode=="solo" and PBWT.Solo.New(self.state,difficulty,GetGameTimeMilliseconds) or nil)
    self.selected,self.card,self.focus,self.help=nil,nil,"board",false
    self.showRecords=false
    self.notice=mode=="solo" and PBWT.L("ui_solo_notice",self:ComputerName()) or PBWT.L("ui_local_notice")
    self:SyncComputer()
end
function UI:NewGame()
    self:StopComputer();self.movement:Reset(); self.state=E.New(true,self.variant)
    if self.mode=='tutorial' then self.tutorial=PBWT.Tutorial.New();self.state=self.tutorial.state end
    self.computer=self.mode=="solo" and PBWT.Solo.New(self.state,self.difficulty,GetGameTimeMilliseconds) or nil
    self.selected,self.card,self.focus,self.help=nil,nil,"board",false
    self.x,self.y=1,3; self.notice=PBWT.L("ui_new_match_notice")
    self.boardSize=nil
    self:Refresh(); self:SyncComputer()
end
function UI:LoadTutorial(advance)
    self.movement:Reset()
    if advance then self.tutorial:Next() else self.tutorial:Load() end
    self.state=self.tutorial.state;self.x,self.y=1,3
    self.selected,self.card,self.focus,self.help,self.showRecords=nil,nil,'board',false,false
    self.notice=PBWT.L("ui_practice_ready");self:Refresh()
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
    elseif direction=="right" and self.x==E.Rules(self.state).SIZE then self.focus="end"
    elseif direction=="right" then self.x=self.x+1
    elseif direction=="left" and self.x==1 and not self.card then self.focus="scroll"; self.selected=nil
    elseif direction=="left" then self.x=math.max(1,self.x-1)
    elseif direction=="up" then self.y=math.max(1,self.y-1)
    elseif direction=="down" then self.y=math.min(E.Rules(self.state).SIZE,self.y+1) end
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
        self.selected=nil; self.notice=PBWT.L("ui_pick_source_again"); self:Refresh(); return
    end
    if self.card or self.selected or self.focus~="board" or self.help then
        self.card,self.selected,self.focus,self.help=nil,nil,"board",false
        self.notice=PBWT.L("ui_cancelled"); self:Refresh()
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
        if self.card and PBWT.Cards.definitions[self.card].targeting=="card" then
            self:Submit({type="card",card=self.card,id=self.cardIndex}); return
        end
        if not s.cards[s.player][id] then self.notice=messages.card_spent; self:Refresh(); return end
        self.card,self.selected,self.focus,self.help=id,nil,"board",false
        if PBWT.Cards.definitions[id].targeting=="card" then
            self.focus="cards"; self.notice=PBWT.L("ui_pick_spent_card"); self:Refresh(); return
        end
        if PBWT.Cards.definitions[id].targeting=="home" then
            for _,p in ipairs(s.pieces) do
                if p.owner==s.player and p.kind=="soldier" and not p.alive then self.selected=p.id; break end
            end
            if not self.selected then self.notice=messages.dead_soldier_required; self.card=nil; self:Refresh(); return end
        end
        -- Opening a card with nowhere to use it looks broken, so say why and keep the card.
        local targets=self:CardTargets()
        if targets==0 then
            self.notice=messages[self.card.."_no_target"] or messages.no_card_target
            self.card,self.selected=nil,nil; self:Refresh(); return
        end
        self.notice=PBWT.L("ui_card_targets",targets); self:Refresh(); return
    end
    local p=E.At(s,self.x,self.y)
    if self.card then
        local targeting=PBWT.Cards.definitions[self.card].targeting
        if (targeting=="destination" or targeting=="enemy") and not self.selected then
            local ok,reason=PBWT.Cards.SourceAt(s,s.player,self.card,self.x,self.y)
            if ok then self.selected=p.id; self.notice=targeting=="enemy" and PBWT.L("ui_pick_attack") or PBWT.L("ui_pick_destination")
            else self.notice=messages[reason] or reason end
            self:Refresh(); return
        end
        self:Submit(PBWT.Cards.CommandAt(s,self.card,self.selected,self.x,self.y)); return
    end
    if not self.selected then
        if p and p.owner==s.player then self.selected=p.id; self.notice=PBWT.L("ui_pick_move_or_attack")
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
-- Counts the squares the open card could be used on, for the prompt and for refusing
-- to enter a targeting mode that has nothing to point at.
function UI:CardTargets()
    if not self.card then return 0 end
    local size=E.Rules(self.state).SIZE
    local count=0
    for y=1,size do for x=1,size do
        if self:CardTargetAt(x,y) then count=count+1 end
    end end
    return count
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
        local occupant=E.At(s,x,y)
        if occupant and occupant.owner~=p.owner then
            -- An attack is ordered by moving onto the defender, so it shows in the same range.
            if E.CanAttack(s,p,occupant,false) then return "attack" end
            return
        end
        -- Match Confirm's priority: a one-square step spends the horn token first.
        if s.horn[p.id] and E.CanMove(s,p,x,y,C.HORN_DISTANCE) then return "horn" end
        if s.actions>0 and E.CanMove(s,p,x,y,E.MoveRange(s,p)) then return "move" end
    end
end
local rangeStyles={
    move={color={0.57,0.88,0.96,1},text=PBWT.L("ui_range_move")},
    horn={color={0.98,0.79,0.35,1},text=PBWT.L("ui_range_horn")},
    attack={color={0.95,0.45,0.40,1},text=PBWT.L("ui_range_attack")},
    card={color={0.94,0.85,0.55,1},text=PBWT.L("ui_range_card")},
    reference={color={0.82,0.61,0.60,1},text=PBWT.L("ui_range_reference")},
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
    -- Chrome text is rebuilt here too, so a language change applies without a reload.
    self.title:SetText(C.Title()); self.subtitle:SetText(C.Subtitle()); self.endText:SetText(PBWT.L("ui_end_button"))
    self.turn:SetText(PBWT.L("ui_turn_line",C.VariantName(E.Rules(s),true),s.turn,E.Rules(s).MAX_TURNS,self:IsComputerTurn() and PBWT.L("ui_com_thinking") or "P"..s.player,s.actions))
    if s.scrollOwner~=0 and s.status=='playing' then
        self.turn:SetText('P'..s.scrollOwner..PBWT.L("ui_scroll_banner")..(3-s.scrollOwner)..PBWT.L("ui_scroll_banner_end"))
    end
    self.footer:SetText((self.mode=="solo" and self:ComputerName() or PBWT.L("ui_local_mode"))..PBWT.L("ui_footer_solo"))
    if self.mode=="online" and self.network then self.footer:SetText(PBWT.L("ui_footer_online",self.network.seat)) end
    if s.status=="setup" then
        self.turn:SetText(PBWT.L("ui_setup_prefix")..s.player..PBWT.L("ui_setup_suffix"))
        self.footer:SetText(PBWT.L("ui_footer_setup"))
    end
    for player=1,2 do
        local flags,pieces=E.Counts(s,player)
        self.players[player]:SetColor(unpack(T.OnWood(T.Player(player,s))))
        local name=self.mode=="solo" and (player==1 and PBWT.L("ui_you") or self:ComputerName()) or (player==s.player and PBWT.L("ui_turn_side") or PBWT.L("ui_waiting"))
        if self.mode=="online" and self.network then name=player==self.network.seat and PBWT.L("ui_you") or PBWT.L("ui_opponent") end
        local faction=PBWT.Factions.Get(s,player)
        if faction then name=name.." / "..PBWT.Factions.Name(faction,true) end
        PBWT.Typography.Apply(self.players[player],"ZoFontGamepad22")
        local rules=E.Rules(s)
        local crown=""
        if rules.EMPEROR then
            local short=#rules.FLAGS-flags
            crown=short==0 and PBWT.L("ui_crowned") or (short<=2 and PBWT.L("ui_crown_in",short) or "")
        end
        self.players[player]:SetText(PBWT.L("ui_score_plaque",player,name,s.score[player],E.WinScore(s,player),
            E.Komi(s,player)~=0 and PBWT.L("ui_second_seat") or "",flags,pieces,crown))
    end
    local rangePiece,rangeReference=self:MovementSource()
    self:LayoutBoard()
    local size,compact=E.Rules(s).SIZE,E.Rules(s).SIZE>5
    for y=1,size do for x=1,size do
        local cell=self:Cell(x,y)
        local kind=self:MovementAt(rangePiece,rangeReference,x,y)
        if self.card and self:CardTargetAt(x,y) then kind="card" end
        cell.rangeKind=kind; cell.range:SetHidden(not kind)
        if kind then
            local style=rangeStyles[kind]; local color=style.color
            cell.range:SetCenterColor(color[1],color[2],color[3],0.24)
            borderColor(cell.range,color); cell.rangeText:SetColor(unpack(color)); cell.rangeText:SetText(style.text)
        end
        local p=E.At(s,x,y)
        local pieceName=p and ("P"..p.owner..(compact and "" or " ")..C.PieceName(p.kind,compact)) or ""
        cell.name:SetText(pieceName)
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
        local keep=index and E.Rules(s).FLAGS[index]
        if cell.flagIcon then cell.flagIcon:SetHidden(compact or not keep or not PBWT.Assets.IsUsable(cell.flagIcon)) end
        -- Wide board: the name alone, coloured by its holder. Light board: points and holder.
        cell.flag:SetText(keep and (compact and C.KeepName(keep) or PBWT.L("keep_points",keep.points,owner==0 and PBWT.L("neutral") or "P"..owner)) or "")
        cell.flag:SetColor(unpack(owner and owner~=0 and T.Player(owner,s) or T.text))
        local eligible=self.card and self:CardTargetAt(x,y)
        local practice=self.mode=='tutorial' and self.tutorial:TargetAt(x,y)
        borderColor(cell.root,(eligible or practice) and T.selected or T.brass)
        local effects=p and ((s.scrollOwner~=0 and s.scrollReader==p.id and PBWT.L("ui_mark_scroll") or "")..(p.hiddenUntil and (eligible and PBWT.L("ui_mark_hidden_short") or PBWT.L("ui_mark_hidden")) or "")..(s.horn[p.id] and (eligible and PBWT.L("ui_mark_horn_short") or PBWT.L("ui_mark_horn")) or "")) or ""
        cell.effect:SetText(effects..(eligible and PBWT.L("ui_range_card") or ""))
        cell.effectPanel:SetHidden(effects=="" and not eligible)
        cell.selected:SetHidden(not p or (self.selected~=p.id and not (s.scrollOwner~=0 and s.scrollReader==p.id and s.status=='playing')))
        cell.cursor:SetHidden(self.focus~="board" or self.x~=x or self.y~=y)
    end end
    local focusVisible=s.status=="playing" and not self.showRecords
    for i,id in ipairs(C.CARD_ORDER) do
        local row=self.cardControls[i]
        local focused=focusVisible and self.focus=="cards" and self.cardIndex==i
        row.focusMarker:SetHidden(not focused)
        row.focusText:SetText(self.mode=="tutorial" and self.tutorial.complete and PBWT.L("ui_next_chapter") or PBWT.L("ui_selected_badge"))
        local hand=self.mode=="online" and self.network and self.network.seat or s.player
        row.text:SetText(PBWT.Cards.Name(id).."  "..(s.cards[hand][id] and (self.card==id and PBWT.L("card_targeting") or PBWT.L("card_unused")) or PBWT.L("card_spent_short")))
        row.text:SetAlpha(s.cards[hand][id] and 1 or 0.5)
        row.panel:SetEdgeColor(unpack(self.focus=="cards" and self.cardIndex==i and T.cursor or T.brass))
    end
    self.endPanel:SetEdgeColor(unpack(self.focus=="end" and T.cursor or T.brass))
    self.endFocus:SetHidden(not (focusVisible and self.focus=="end"))
    self.endFocusText:SetText(self.mode=="tutorial" and self.tutorial.complete and PBWT.L("ui_next_chapter") or PBWT.L("ui_selected_badge"))
    self.practiceLabel:SetHidden(self.mode~="tutorial" or s.status=="setup" or self.showRecords)
    if self.mode=="tutorial" then
        local _,own=E.Counts(s,1);local _,opponent=E.Counts(s,2)
        self.practiceLabel:SetText(PBWT.L("ui_practice_pieces",own,opponent))
    end
    local seat=self.mode=="online" and self.network and self.network.seat or self.mode=="solo" and 1 or s.player
    local canOpen,scrollWhy=PBWT.Scroll.CanInvoke(s,seat)
    local scrollVisible=s.status~="setup" and not self.showRecords and not self.help and not self.card and self.focus~="cards"
    self.scrollPanel:SetHidden(not scrollVisible)
    self.scrollPanel:SetEdgeColor(unpack(self.focus=="scroll" and T.cursor or s.scrollOwner~=0 and T.selected or T.brass))
    self.scrollTitle:SetText(PBWT.L("ui_scroll_title").."\n"..(s.reason=='elder_scroll' and PBWT.L("ui_scroll_decided") or s.scrollOwner~=0 and PBWT.L("ui_scroll_open_title") or canOpen and PBWT.L("ui_scroll_open_hint") or PBWT.L("ui_scroll_more")))
    self.scrollText:SetText(PBWT.Scroll.Text(s,seat))
    self.details:SetDimensions(350,scrollVisible and 305 or 505)
    local p=E.At(s,self.x,self.y)
    local text
    if self.showRecords then
        text=PBWT.Records.Text(self.recordIndex)
    elseif self.focus=="scroll" then
        text=PBWT.L("ui_scroll_panel",E.Rules(s).SCROLL.COST,E.WinScore(s,3-s.player))..(canOpen and PBWT.L("ui_scroll_confirm") or (messages[scrollWhy] or scrollWhy))
    elseif self.help then
        local rules=E.Rules(s)
        local points={} for _,f in ipairs(rules.FLAGS) do points[#points+1]=f.points end
        text=PBWT.L("ui_rules_card",rules.ACTIONS or 1,C.VariantName(rules),rules.SIZE,rules.SIZE,#rules.FLAGS,
            table.concat(points," / "),rules.EMPEROR and PBWT.L("ui_rules_emperor") or "",
            rules.WIN_SCORE,rules.WIN_SCORE+rules.KOMI,rules.SECOND_TURN_ACTIONS,rules.MAX_TURNS,rules.SCROLL.COST)
    elseif self.card or self.focus=="cards" then
        local id=self.card or C.CARD_ORDER[self.cardIndex]
        text=PBWT.Cards.Name(id).."\n\n"..PBWT.Cards.Description(id)
        if self.card then
            local targeting=PBWT.Cards.definitions[id].targeting
            local sourceStage=not self.selected and (targeting=="destination" or targeting=="enemy")
            local prompt=sourceStage and PBWT.L("ui_target_own") or targeting=="home" and PBWT.L("ui_target_home") or targeting=="destination" and PBWT.L("ui_target_destination") or targeting=="enemy" and PBWT.L("ui_target_enemy") or targeting=="card" and PBWT.L("ui_target_card") or PBWT.L("ui_target_piece")
            local valid,reason
            if targeting=="card" then valid,reason=PBWT.Cards.Preview(s,s.player,{type="card",card=self.card,id=self.cardIndex})
            else valid,reason=self:CardTargetAt(self.x,self.y) end
            text=text.."\n\n"..prompt..PBWT.L("ui_target_hint")
            if sourceStage then text=text..(valid and PBWT.L("ui_pick_this") or (messages[reason] or reason))
            elseif valid then
                text=text..PBWT.L("ui_preview")..(messages[reason] or reason)
                if id=="siege" and p then
                    local attacker=E.Piece(s,self.selected)
                    text=text..PBWT.L("ui_siege_forecast",E.Attack(s,attacker),E.Attack(s,attacker,true),E.Defense(s,p),E.Defense(s,p,true))
                end
                text=text..PBWT.L("ui_confirm_card")
            else text=text..(messages[reason] or reason) end
        end
    elseif p or E.Flag(s,self.x,self.y) then
        local owner,index=E.Flag(s,self.x,self.y)
        local keep=index and E.Rules(s).FLAGS[index]
        local keepText=keep and PBWT.L("ui_keep_line",C.KeepName(keep) or PBWT.L("ui_keep"),keep.points,
            owner==0 and PBWT.L("ui_neutral") or PBWT.L("ui_held_by","P"..owner)) or ""
        local spec=p and C.PIECES[p.kind]
        text=keepText..(p and "" or (E.Rules(s).EMPEROR and PBWT.L("ui_keep_emperor_note") or PBWT.L("ui_empty_keep")))
        if p then text=PBWT.L("ui_piece_card",p.owner,C.PieceName(p.kind),E.Attack(s,p),E.Defense(s,p),E.MoveRange(s,p),p.hiddenUntil and PBWT.L("ui_state_hidden") or "",s.horn[p.id] and PBWT.L("ui_state_horn") or "")
        text=keepText..text end
        local faction=p and PBWT.Factions.Get(s,p.owner)
        if faction then text=text..PBWT.L("ui_faction_line",PBWT.Factions.Name(faction,true),PBWT.Factions.Ability(faction),PBWT.Factions.Description(faction)) end
        if p and self.selected and p.owner~=s.player then
            local attacker=E.Piece(s,self.selected)
            local ok,why=E.CanAttack(s,attacker,p,false)
            text=text.."\n"..(ok and (E.Attack(s,attacker)>=E.Defense(s,p) and PBWT.L("ui_attack_kill") or PBWT.L("ui_attack_hold")) or (messages[why] or why))
        end
    else
        local rules=E.Rules(s)
        text=PBWT.L("ui_idle_board",#rules.FLAGS==3 and PBWT.L("ui_three_banners") or PBWT.L("ui_six_keeps"))..
            (rules.EMPEROR and PBWT.L("ui_idle_emperor") or "")..PBWT.L("ui_idle_help")
    end
    if rangePiece and not self.help then
        text=text.."\n\n"..(rangeReference and PBWT.L("ui_reference_note") or PBWT.L("ui_range_note"))
    end
    PBWT.Typography.Apply(self.details,(scrollVisible or self.showRecords or rangePiece or self.help) and "ZoFontGamepad22" or "ZoFontGamepad27")
    self.details:SetText(text)
    self.presentation:Refresh()
    self.factionUI:Refresh()
    if s.status=="finished" then
        self.status:SetText((s.winner==0 and PBWT.L("ui_draw") or "P"..s.winner..PBWT.L("ui_victory_suffix")).."  •  "..(s.reason=="elder_scroll" and PBWT.L("ui_reason_scroll") or s.reason=="emperor" and PBWT.L("ui_reason_emperor") or s.reason=="score" and (s.winner and E.WinScore(s,s.winner) or E.Rules(s).WIN_SCORE)..PBWT.L("ui_reason_score") or E.Rules(s).MAX_TURNS..PBWT.L("ui_reason_limit"))..PBWT.L("ui_hint_new"))
    else self.status:SetText(self.notice or "") end
    if self.mode=="online" and self.network then
        if self.network.phase=="closed" then self.status:SetText(self.network.message..PBWT.L("ui_hint_back"))
        elseif s.status=="finished" then
            self.status:SetText((s.winner==0 and PBWT.L("ui_draw") or s.winner==self.network.seat and PBWT.L("ui_you_win") or PBWT.L("ui_they_win"))..(s.reason=="elder_scroll" and PBWT.L("ui_by_scroll") or s.reason=="resign" and PBWT.L("ui_by_resign") or "")..(self.network.pending and PBWT.L("ui_syncing") or PBWT.L("ui_hint_back_short")))
        else self.status:SetText(self.resignConfirm and PBWT.L("ui_resign_confirm") or self.network.message or "") end
    end
    if self.mode=='tutorial' then
        if not self.card and self.focus~='cards' then
            self.scrollPanel:SetHidden(self.focus~='scroll')
            self.details:SetDimensions(350,self.focus=='scroll' and 305 or 505)
            PBWT.Typography.Apply(self.details,'ZoFontGamepad22')
            self.details:SetText(self.focus=='scroll' and (PBWT.L("ui_practice_scroll")) or self.tutorial:Text())
        end
        self.status:SetText(string.format(PBWT.L("ui_tutorial_line"),self.tutorial.index,#PBWT.Tutorial.lessons,self.tutorial.complete and PBWT.L("ui_tutorial_done") or self.notice or PBWT.Tutorial.LessonTitle(self.tutorial.lesson)))
        self.footer:SetText(PBWT.L("ui_tutorial_footer"))
        if self.state.status=='setup' then self.factionUI.guide:SetText(PBWT.L("ui_tutorial_dice")) end
    end
    self.movement:Observe()
    if self.scene and self.scene:IsShowing() then KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybinds) end
    self:StartAssetPolling()
    self:SyncComputer()
end
