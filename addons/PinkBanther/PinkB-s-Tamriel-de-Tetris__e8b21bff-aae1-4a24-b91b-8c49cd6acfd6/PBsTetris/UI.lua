PBT=PBT or {}
local U={};U.__index=U;PBT.UI=U
-- 1-8 are the pieces and garbage. 9 and 10 are a row on its way out: white for an ordinary
-- clear, gold for four at once, which is the only place either colour is used.
local colors={{.35,.82,.87},{.94,.8,.35},{.72,.45,.85},{.38,.55,.94},{.94,.57,.3},{.45,.8,.46},{.88,.38,.39},{.52,.53,.55},{1,.97,.9},{1,.84,.35}}
local WIPE,QUAD_WIPE=.18,.3
local FLAKES=48
-- The highlight crosses the board diagonally over SHINE seconds and then stays away for the
-- rest of SHINE_CYCLE, so it reads as an occasional glint rather than a strobe.
local SHINE,SHINE_CYCLE,SHINE_WIDTH=1.5,4.2,.16
-- HOLD_MIN is a floor, not the wait itself: the curtain stays down until the scene reports
-- SCENE_SHOWN. SCENE_MANAGER:Show hides the menu first and brings the board up over the
-- following frames, and IsShowing() is already true while that is still happening, so lifting
-- on either of those shows the world through the gap. HOLD_MAX is there so a scene that never
-- reports itself shown cannot leave the screen black.
local FADE_IN,FADE_OUT,HOLD_MIN,HOLD_MAX=.28,.34,.1,1.2
local BANNER,BANNER_RISE=1.5,70
local function box(parent,x,y,w,h)
 local c=WINDOW_MANAGER:CreateControl(nil,parent,CT_BACKDROP);c:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y);c:SetDimensions(w,h)
 c:SetCenterColor(.018,.022,.026,.97);c:SetEdgeColor(.48,.4,.26,1);c:SetEdgeTexture('',1,1,1);return c
end
local function text(parent,x,y,w,h,size,value)
 local c=WINDOW_MANAGER:CreateControl(nil,parent,CT_LABEL);c:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y);c:SetDimensions(w,h)
 c:SetFont('ZoFontGamepad'..size);c:SetHorizontalAlignment(TEXT_ALIGN_CENTER);c:SetColor(.9,.86,.74,1);c:SetDrawLayer(DL_TEXT);c:SetText(value or '');return c
end
local function tile(parent,x,y,size)
 local c=WINDOW_MANAGER:CreateControl(nil,parent,CT_TEXTURE);c:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y);c:SetDimensions(size-2,size-2)
 c:SetTexture('PBsTetris/assets/stone.dds');c:SetDrawLayer(DL_CONTROLS);return c
end
-- shine is 0-4, a quantised distance from the highlight sweeping over the stack. Quantising
-- it is what keeps this cheap: a cell is recoloured when it changes step, not every frame.
local function paint(c,v,shine)
 shine=shine or 0
 if c.value==v and c.shine==shine then return end
 c.value=v;c.shine=shine;c:SetHidden(v==0)
 if v~=0 then
  local rgb=colors[math.abs(v)];local lift=v<0 and 0 or shine*.17
  c:SetColor(rgb[1]+(1-rgb[1])*lift,rgb[2]+(1-rgb[2])*lift,rgb[3]+(1-rgb[3])*lift,v<0 and .23 or 1)
 end
end
function U.New(app)
 local self=setmetatable({app=app,cells={},minis={},flakes={},snowAt=0},U)
 local root=WINDOW_MANAGER:CreateTopLevelWindow('PBsTetrisWindow');self.root=root
 root:SetAnchorFill(GuiRoot);root:SetHidden(true)
 local sky=WINDOW_MANAGER:CreateControl(nil,root,CT_TEXTURE);sky:SetAnchorFill(root);sky:SetTexture('PBsTetris/assets/sanctuary.dds');sky:SetDrawLayer(DL_BACKGROUND);sky:SetDrawLevel(0);self.sky=sky
 local veil=box(root,0,0,1,1);veil:SetAnchorFill(root);veil:SetCenterColor(.012,.025,.045,.24);veil:SetEdgeColor(0,0,0,0);veil:SetDrawLayer(DL_BACKGROUND);veil:SetDrawLevel(1)
 local content=WINDOW_MANAGER:CreateControl(nil,root,CT_CONTROL);content:SetDimensions(1100,850);content:SetAnchor(CENTER,root,CENTER,0,-20);self.content=content;root=content
 local stone=tile(root,0,0,1102);stone:SetDimensions(1100,850);stone:SetDrawLayer(DL_BACKGROUND);stone:SetColor(.22,.29,.34,.88)
 text(root,0,30,1100,30,22,'ゲームセンターPX')
 text(root,0,63,1100,55,42,'タムリエル de テトリス'):SetColor(.91,.77,.48,1)
 self.mode=text(root,0,118,1100,35,22)
 self.boardBox=box(root,390,162,320,620)
 for y=1,20 do self.cells[y]={};for x=1,10 do self.cells[y][x]=tile(root,400+(x-1)*30,172+(y-1)*30,30) end end
 self.holdLabel=text(root,65,173,270,35,27,'ホールド');self:Mini(140,220)
 self.nextLabel=text(root,765,173,270,35,27,'次のブロック')
 for i=1,3 do self:Mini(840,220+(i-1)*112) end
 self.stats=text(root,65,390,270,260,27)
 self.record=text(root,65,670,270,75,22)
 self.enemy=text(root,755,575,290,160,22)
 -- The duel's right half. The opponent's board is never sent, only how high it stands, so
 -- what goes here is that height at the same scale as the player's own stack rather than a
 -- guess at its shape.
 self.peerLabel=text(root,565,173,190,35,27,'相手');self.peerLabel:SetHidden(true)
 self.gaugeFrame=box(root,765,162,320,620);self.gaugeFrame:SetHidden(true)
 self.gauge=box(root,775,172,300,1);self.gauge:SetCenterColor(.42,.6,.78,.45);self.gauge:SetEdgeColor(.6,.76,.9,.5);self.gauge:SetHidden(true)
 self.footer=text(root,45,800,1010,28,18,'方向キー：移動　下：速く落とす　上：一気に落とす　L1：左回転')
 self.banner=text(root,390,300,320,60,42,'');self.banner:SetColor(1,.86,.42,1);self.banner:SetDrawLayer(DL_OVERLAY);self.banner:SetHidden(true)
 self.overlay=box(root,402,365,296,200);self.overlay:SetDrawLayer(DL_OVERLAY)
 self.message=text(self.overlay,8,15,280,170,27);self.message:SetDrawLayer(DL_OVERLAY);self.message:SetDrawLevel(1)
 -- A curtain of its own, on the high draw tier, so it covers the gamepad menu the board is
 -- being opened from as well as the board itself. It outlives the scene deliberately: the
 -- world has to go dark before the scene is shown at all.
 local curtain=WINDOW_MANAGER:CreateTopLevelWindow('PBsTetrisCurtain')
 curtain:SetAnchorFill(GuiRoot);curtain:SetHidden(true);curtain:SetDrawTier(DT_HIGH);curtain:SetDrawLayer(DL_OVERLAY);curtain:SetDrawLevel(9)
 local black=WINDOW_MANAGER:CreateControl(nil,curtain,CT_BACKDROP)
 black:SetAnchorFill(curtain);black:SetCenterColor(0,0,0,1);black:SetEdgeColor(0,0,0,0);black:SetEdgeTexture('',1,1,1)
 self.curtain=curtain
 for i=1,FLAKES do
  local c=WINDOW_MANAGER:CreateControl(nil,self.root,CT_TEXTURE)
  c:SetTexture('PBsTetris/assets/flake.dds');c:SetDrawLayer(DL_OVERLAY);c:SetDrawLevel(2);c:SetHidden(true)
  self.flakes[i]={control=c}
 end
 self.keybinds={alignment=KEYBIND_STRIP_ALIGN_CENTER}
 for _,entry in ipairs({{'UI_SHORTCUT_PRIMARY','primary'},{'UI_SHORTCUT_SECONDARY','drop'},{'UI_SHORTCUT_TERTIARY','hold'},{'UI_SHORTCUT_NEGATIVE','back'},{'UI_SHORTCUT_LEFT_SHOULDER','ccw'},{'UI_SHORTCUT_RIGHT_SHOULDER','music'}}) do
  local action=entry[2]
  self.keybinds[#self.keybinds+1]={keybind=entry[1],name=function() return app:ActionName(action) end,callback=function() app:Action(action) end}
 end
 self.scene=ZO_Scene:New('pbtGame',SCENE_MANAGER)
 self.scene:AddFragment(ZO_SimpleSceneFragment:New(self.root));self.scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
 self.scene:AddFragment(ZO_ActionLayerFragment:New('PBsTetrisInput'))
 self.scene:RegisterCallback('StateChange',function(_,state)
  if state==SCENE_SHOWING then
   self.content:SetScale(math.min((GuiRoot:GetHeight()-100)/850,(GuiRoot:GetWidth()-80)/1100));self:Refresh();KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds)
  elseif state==SCENE_SHOWN then self.sceneShown=true
  elseif state==SCENE_HIDING then self.sceneShown=false;KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds);app:Hidden() end
 end)
 return self
end
function U:Mini(x,y)
 local cells={};for i=1,16 do cells[i]=tile(self.content,x+((i-1)%4)*27,y+math.floor((i-1)/4)*27,27) end
 self.minis[#self.minis+1]=cells
end
-- Solo keeps the board in the middle with a panel either side. A duel splits the screen down
-- the middle instead: everything of the player's own on the left, the opponent on the right.
local LAYOUTS={
 solo={box=390,cells=400,hold={65,173,270},holdCells={140,220},next={765,173,270},
  nextCells={{840,220},{840,332},{840,444}},stats={65,390,270,260},enemy={755,575,290,160},banner=390,overlay=402},
 versus={box=215,cells=225,hold={10,173,190},holdCells={30,215},next={10,330,190},
  nextCells={{30,372},{30,484},{30,596}},stats={10,690,190,150},enemy={565,215,190,260},banner=215,overlay=227},
}
function U:PlaceMini(index,x,y)
 for i,c in ipairs(self.minis[index]) do
  c:SetAnchor(TOPLEFT,self.content,TOPLEFT,x+((i-1)%4)*27,y+math.floor((i-1)/4)*27)
 end
end
function U:Layout(versus)
 local key=versus and 'versus' or 'solo'
 if self.layout==key then return end
 self.layout=key
 local at=LAYOUTS[key];local content=self.content
 local function place(control,x,y,w,h)
  control:SetAnchor(TOPLEFT,content,TOPLEFT,x,y)
  if w then control:SetDimensions(w,h) end
 end
 place(self.boardBox,at.box,162,320,620)
 for y=1,20 do for x=1,10 do place(self.cells[y][x],at.cells+(x-1)*30,172+(y-1)*30) end end
 place(self.holdLabel,at.hold[1],at.hold[2],at.hold[3],35)
 place(self.nextLabel,at.next[1],at.next[2],at.next[3],35)
 self:PlaceMini(1,at.holdCells[1],at.holdCells[2])
 for i=1,3 do self:PlaceMini(i+1,at.nextCells[i][1],at.nextCells[i][2]) end
 place(self.stats,at.stats[1],at.stats[2],at.stats[3],at.stats[4])
 place(self.enemy,at.enemy[1],at.enemy[2],at.enemy[3],at.enemy[4])
 place(self.banner,at.banner,300,320,60)
 place(self.overlay,at.overlay,365,296,200)
 self.record:SetHidden(versus)
 self.peerLabel:SetHidden(not versus);self.gaugeFrame:SetHidden(not versus)
 if not versus then self.gauge:SetHidden(true) end
end
function U:Gauge(height)
 local tall=math.floor(600*math.min(22,math.max(0,height or 0))/22)
 if tall<2 then self.gauge:SetHidden(true);return end
 self.gauge:SetHidden(false);self.gauge:SetDimensions(300,tall)
 self.gauge:SetAnchor(TOPLEFT,self.content,TOPLEFT,775,772-tall)
end
function U:DrawMini(index,name)
 local values={};if name then for _,p in ipairs(PBT.Engine.Cells(name,0,0,0)) do values[p[2]*4+p[1]+1]=PBT.Engine.ids[name] end end
 for i,c in ipairs(self.minis[index]) do paint(c,values[i] or 0) end
end
-- Holds the board as it stood when the rows filled up, until the wipe has swept across it.
-- Returns how far the sweep has got, or nil once the live board should be drawn again.
function U:Wipe(e)
 local wipe=e and e.wipe
 if wipe~=self.wipe then self.wipe=wipe;self.wipeAt=wipe and GetFrameTimeSeconds() end
 if not wipe then return nil end
 local progress=(GetFrameTimeSeconds()-self.wipeAt)/(wipe.quad and QUAD_WIPE or WIPE)
 if progress<0 or progress>=1 then return nil end
 return wipe,math.floor(progress*10),wipe.quad and 10 or 9
end
-- Snow answers to how much room is left: a few flakes over a clear board, a blizzard once the
-- stack is at the ceiling. Falling is done here rather than with animation timelines because
-- the count changes every few seconds and rebuilding timelines would cost more than moving a
-- texture does.
local function reseed(f,width,height,top)
 f.x=math.random()*width;f.y=top and -math.random()*height*.4 or math.random()*height
 f.fall=height*(.05+math.random()*.09);f.sway=8+math.random()*26;f.phase=math.random()*6.28
 f.size=3+math.random()*7
 f.control:SetDimensions(f.size,f.size)
 f.control:SetColor(1,1,1,.25+math.random()*.35)
end
function U:Snow(e,now)
 local dt=math.min(.1,math.max(0,now-self.snowAt));self.snowAt=now
 local height=e and e:Height() or 0
 local weight=math.min(1,height/18)
 local wanted=e and math.floor(FLAKES*(.06+.94*weight*weight)) or 0
 local width,tall=self.root:GetWidth(),self.root:GetHeight()
 for i,f in ipairs(self.flakes) do
  if i>wanted then
   if f.y then f.y=nil;f.control:SetHidden(true) end
  else
   if not f.y then reseed(f,width,tall,false);f.control:SetHidden(false) end
   f.y=f.y+f.fall*dt*(.7+weight)
   if f.y>tall then reseed(f,width,tall,true) end
   f.control:SetAnchor(TOPLEFT,self.root,TOPLEFT,f.x+math.sin(now*1.7+f.phase)*f.sway,f.y)
  end
 end
end
function U:Shine(now)
 local at=now%SHINE_CYCLE
 if at>SHINE then return nil end
 return -.3+(at/SHINE)*1.6
end
-- Darkens the screen, runs `after` at full black, then lifts. Nothing of the board runs in
-- between: Playable() needs the scene, and the scene is only shown by `after`.
function U:Fade(after)
 self.fade={phase='in',elapsed=0,after=after}
 self.curtain:SetAlpha(0);self.curtain:SetHidden(false)
end
function U:CancelFade()
 if self.fade then self.fade.after=nil end
end
function U:Tick(dt)
 local fade=self.fade
 if not fade then return end
 fade.elapsed=fade.elapsed+math.min(.1,math.max(0,dt))
 if fade.phase=='in' then
  local alpha=math.min(1,fade.elapsed/FADE_IN);self.curtain:SetAlpha(alpha)
  if alpha>=1 then
   local after=fade.after
   fade.phase,fade.elapsed,fade.after=after and 'hold' or 'out',0,nil
   if after then self.sceneShown=false;after() end
  end
 elseif fade.phase=='hold' then
  if (self.sceneShown and fade.elapsed>=HOLD_MIN) or fade.elapsed>=HOLD_MAX then fade.phase,fade.elapsed='out',0 end
 else
  local alpha=1-fade.elapsed/FADE_OUT
  if alpha<=0 then self.curtain:SetAlpha(0);self.curtain:SetHidden(true);self.fade=nil
  else self.curtain:SetAlpha(alpha) end
 end
end
-- The banner is driven from the level the engine is carrying rather than from an event, so
-- that it cannot be missed while the board is not on screen and cannot fire on a new game.
function U:Banner(e,now)
 local level=e and e.level
 if e~=self.levelEngine then self.levelEngine=e;self.level=level;self.bannerAt=nil end
 if level and self.level and level>self.level then
  self.bannerAt=now;self.banner:SetText(level>=20 and ('レベル '..level..' · 20G') or ('レベル '..level))
 end
 self.level=level
 local at=self.bannerAt and (now-self.bannerAt)/BANNER
 if not at or at<0 or at>=1 then
  self.bannerAt=nil
  -- Hidden here rather than only on the frame it expires: starting a new game clears the
  -- timer outright, and the label would otherwise stay on screen from then on.
  if self.bannerOn then self.bannerOn=false;self.banner:SetHidden(true) end
  return
 end
 if not self.bannerOn then self.bannerOn=true;self.banner:SetHidden(false) end
 self.banner:SetAlpha(math.min(1,at*8)*math.min(1,(1-at)*3.2))
 self.banner:SetAnchor(TOPLEFT,self.content,TOPLEFT,390,300-BANNER_RISE*at)
end
function U:Refresh()
 local app=self.app;local e=app:Engine();local m=app.match
 self:Layout(not app.solo)
 self.mode:SetText(app.solo and (e and e:Is20G() and 'ひとりで挑戦 · 20G' or 'ひとりで挑戦 · スコアアタック') or ('対戦相手：'..(m.peer or '未選択')))
 if not app.solo then self.peerLabel:SetText(m.peer or '相手');self:Gauge(m.peerHeight) end
 local now=GetFrameTimeSeconds()
 local wipe,swept,tint=self:Wipe(e);self.wiping=wipe~=nil
 local board=wipe and wipe.board or (e and e:View())
 local glint=not wipe and self:Shine(now) or nil
 for y=1,20 do for x=1,10 do
  local value=board and board[y+2][x] or 0
  local shine=0
  if wipe and wipe.clearing[y+2] then value=x<=swept and 0 or tint
  elseif glint and value>0 then
   local along=((x-1)/9+(20-y)/19)/2
   shine=math.floor(math.max(0,1-math.abs(along-glint)/SHINE_WIDTH)*4+.5)
  end
  paint(self.cells[y][x],value,shine)
 end end
 self:Snow(e,now);self:Banner(e,now)
 self:DrawMini(1,e and e.hold)
 for i=1,3 do self:DrawMini(i+1,e and e.queue[i]) end
 self.stats:SetText(string.format('スコア\n%d\n\n消したライン　%d\nレベル　%d',e and e.score or 0,e and e.lines or 0,e and e.level or 1))
 self.record:SetText((e and e.force20G and '20G 自己ベスト\n' or '自己ベスト\n')..(e and e.force20G and (app.saved.highScore20G or 0) or app.saved.highScore))
 self.enemy:SetText(app.solo and (e and e:Is20G() and '20G · 即時接地\n地面を滑らせて配置\n固定猶予 0.5秒' or '10ラインごとに速度上昇\nレベル20から20G') or string.format('高さ\n%d / 22\n\n送ったおじゃま\n%d 段\n\n受けたおじゃま\n%d 段\n\n相殺した\n%d 段\n待機中 %d 段',
   m.peerHeight or 0,e and e.sent or 0,m.received or 0,e and e.cancelled or 0,e and e.pending or 0))
 local status=''
 if app.solo then
  if e.over then status='挑戦終了\n\nスコア　'..e.score..'\nもう一度挑戦できます'
  elseif e.paused then status='一時停止\n\n再開して冒険の続きを' end
 else
  local labels={inviting='招待を送りました\n\n相手の返答を待っています',invited='対戦に招待されました\n\n承諾すると開始します',accepted='開始を準備しています',result=m.result,aborted=m.reason,idle='対人メニューから\n相手を招待してください'}
  status=labels[m.state] or ''
  if m.state=='countdown' then status='まもなく対戦開始\n\n'..math.max(0,m.startAt-GetTimeStamp()) end
 end
 self.overlay:SetHidden(status=='');self.message:SetText(status)
 if self.scene:IsShowing() then KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybinds) end
end
