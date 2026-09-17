PBT=PBT or {}
local A={keys={}};PBT.App=A
function A:Alert(message) ZO_Alert(UI_ALERT_CATEGORY_ALERT,nil,message) end
-- Throttled, because a peer that keeps resending would otherwise fill the screen. Used for the
-- things that used to be dropped in silence, which is what an invite that never arrives looks
-- like from the other end.
function A:Notice(message)
 local now=GetFrameTimeSeconds()
 if self.noticeAt and now-self.noticeAt<10 then return end
 self.noticeAt=now;self:Alert(message)
end
function A:Engine() return self.solo and self.soloEngine or self.match.engine end
function A:ClearKeys() self.keys={};self.repeatAt=0 end
function A:Save()
 if self.soloEngine then local key=self.soloEngine.force20G and "highScore20G" or "highScore";self.saved[key]=math.max(self.saved[key] or 0,self.soloEngine.score);self.saved.bestLines=math.max(self.saved.bestLines,self.soloEngine.lines) end
end
function A:Solo(restart,force20G)
 if self.match:Active() then self:Alert('対戦を終了してから、ひとりで挑戦してください。');return end
 self.solo=true
 if force20G==nil then force20G=restart and self.soloEngine and self.soloEngine.force20G or false end
 if restart or not self.soloEngine or self.soloEngine.force20G~=force20G then self:Save();self.soloEngine=PBT.Engine.New(math.random(1,2147483646),false,force20G) end
 self.audio:Bind(self.soloEngine);self.soloEngine.paused=false;self:ClearKeys()
 self.ui:Fade(function() self.audio:Play("start");SCENE_MANAGER:Show('pbtGame');self.ui:Refresh() end)
end
function A:Challenge(peer)
 if self.match:Active() then self:Alert('進行中の対戦を終了してください。');return end
 if self.transport.error then self:Alert(self.transport.error);return end
 if not self.transport:Allowed(peer) then self:Alert('同じグループの、戦闘中ではない相手を招待してください。');return end
 self:Save();if self.soloEngine then self.soloEngine.paused=true end
 self.solo=false;self:ClearKeys()
 local ok,reason=self.match:Invite(peer)
 if ok then self.ui:Fade(function() SCENE_MANAGER:Show('pbtGame') end)
 else self:Alert(reason or '招待を送れませんでした。/pbt debug で詳細を確認できます。') end
end
function A:Hidden()
 self.ui:CancelFade();self.audio:Stop()
 self:ClearKeys();self:Save()
 if self.soloEngine then self.soloEngine.paused=true end
 if self.match:Active() then self.match:Quit() end
end
function A:Playable()
 local e=self:Engine();return self.ui.scene:IsShowing() and e and not e.over and not e.paused and (self.solo or self.match.state=='playing')
end
function A:Input(key,down)
 if not self:Playable() then self:ClearKeys();return end
 self.keys[key]=down
 if down then
  if key=='left' or key=='right' then self:Engine():Move(key=='left' and -1 or 1);self.repeatAt=GetFrameTimeSeconds()+.16
  elseif key=='up' then self:Engine():Drop() end
 end
end
function A:ActionName(key)
 local e=self:Engine()
 if key=='music' then return self.audio:Label() end
 if key=='primary' then
  if self.solo then return e.over and 'もう一度挑戦' or (e.paused and '再開' or '右回転') end
  return self.match.state=='invited' and '対戦を承諾' or '右回転'
 elseif key=='drop' then return '一気に落とす'
 elseif key=='hold' then return 'ホールド'
 elseif key=='ccw' then return '左回転'
 elseif key=='back' then return self.solo and e and not e.over and not e.paused and '一時停止' or (self.match:Active() and '対戦を終了して閉じる' or '閉じる') end
end
function A:Action(key)
 local e=self:Engine()
 if key=='music' then self.audio:Cycle(self:Playable())
 elseif key=='back' then
  self:ClearKeys()
  if self.solo and not e.over and not e.paused then e.paused=true;self:Save()
  else SCENE_MANAGER:Hide('pbtGame') end
 elseif key=='primary' and not self.solo and self.match.state=='invited' then self.match:Accept()
 elseif key=='primary' and self.solo and e.over then self:Solo(true)
 elseif key=='primary' and self.solo and e.paused then e.paused=false
 elseif self:Playable() then
  if key=='primary' then e:Rotate(1) elseif key=='ccw' then e:Rotate(-1) elseif key=='drop' then e:Drop() elseif key=='hold' then e:Hold() end
 end
 self.ui:Refresh()
end
function A:Initialize()
 self.saved=ZO_SavedVars:NewAccountWide('PBsTetrisSavedVariables',1,nil,{highScore=0,highScore20G=0,bestLines=0,soundEnabled=true,musicMode='tribute'})
 if self.saved.musicEnabled==false then self.saved.musicMode='off' end
 self.saved.musicEnabled=nil
 self.audio=PBT.Audio.New(self.saved)
 self.transport=PBT.Transport.New(function(sender,p)
  if self.solo and self.ui.scene:IsShowing() then return end
  self.match:Receive(sender,p)
 end,function(why) self:Notice('対戦の受信を弾きました：'..why) end)
 self.match=PBT.Match.New({name=GetDisplayName(),now=GetFrameTimeSeconds,wall=GetTimeStamp,random=function() return math.random(1,2147483646) end,
  allowed=function(peer) return self.transport:Allowed(peer) end,allowedFrom=function(peer) return self.transport:AllowedFrom(peer) end,send=function(peer,p) return self.transport:Send(peer,p) end,
  changed=function(m)
   if m.engine then self.audio:Bind(m.engine) end
   if m.state~=self.audioState then
    if m.state=='playing' then self.audio:Play('start') elseif m.state=='result' then self.audio:Play(m.terminal==0 and 'win' or 'lose') end
    self.audioState=m.state
   end
   if m.state=='invited' then self.solo=false;SCENE_MANAGER:Show('pbtGame') end
   if self.ui then self.ui:Refresh() end
  end})
 -- Announced on the way in, not only when someone tries to invite: the player being invited
 -- never invites anyone, so a transport that failed to start was invisible to exactly the
 -- side where it mattered.
 if self.transport.error then
  EVENT_MANAGER:RegisterForEvent('PBsTetrisTransport',EVENT_PLAYER_ACTIVATED,function()
   EVENT_MANAGER:UnregisterForEvent('PBsTetrisTransport',EVENT_PLAYER_ACTIVATED)
   self:Alert(self.transport.error)
  end)
 end
 self.ui=PBT.UI.New(self);PBT.HookMenus(self)
 SLASH_COMMANDS['/pbt']=function(arg)
  if arg=='20g' then self:Solo(false,true)
  elseif arg=='music' then self:Alert(self.audio:Cycle(self:Playable()))
  elseif arg=='sound' then self.saved.soundEnabled=not self.saved.soundEnabled;self:Alert(self.saved.soundEnabled and '効果音：入' or '効果音：切')
  elseif arg=='debug' then d(self.transport:Report());d(self.audio:Report()) else self:Solo() end
 end
 self.lastTick=GetFrameTimeSeconds();self.drawAt=0
 EVENT_MANAGER:RegisterForUpdate('PBsTetrisTick',16,function()
  local now=GetFrameTimeSeconds();local dt=math.min(.1,now-self.lastTick);self.lastTick=now
  self.ui:Tick(dt)
  if self:Playable() then
   local dx=(self.keys.left and -1 or 0)+(self.keys.right and 1 or 0)
   if dx~=0 and now>=self.repeatAt then self:Engine():Move(dx);self.repeatAt=now+.05 end
   self:Engine():Tick(dt,self.keys.down)
   if self:Engine().over then self:Save() end
  end
  self.audio:Sync(self:Playable())
  local e=self:Engine()
  if self.solo and e and e.over and self.finishedEngine~=e then self.finishedEngine=e;self.audio:Play("lose") end
  self.match:Tick(dt)
  if self.ui.scene:IsShowing() and now>=self.drawAt then self.drawAt=now+(self.ui.wiping and .016 or .033);self.ui:Refresh() end
 end)
 EVENT_MANAGER:RegisterForEvent('PBsTetris',EVENT_CONTROLLER_DISCONNECTED,function() self:Hidden();SCENE_MANAGER:Hide('pbtGame') end)
 EVENT_MANAGER:RegisterForEvent('PBsTetris',EVENT_PLAYER_DEACTIVATED,function() self:Hidden();SCENE_MANAGER:Hide('pbtGame') end)
 EVENT_MANAGER:RegisterForEvent('PBsTetris',EVENT_PLAYER_COMBAT_STATE,function(_,combat) if combat then self:Hidden();SCENE_MANAGER:Hide('pbtGame') end end)
end
EVENT_MANAGER:RegisterForEvent('PBsTetris',EVENT_ADD_ON_LOADED,function(_,name)
 if name=='PBsTetris' then EVENT_MANAGER:UnregisterForEvent('PBsTetris',EVENT_ADD_ON_LOADED);A:Initialize() end
end)
