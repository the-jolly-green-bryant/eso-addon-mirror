PBT=PBT or {}
local M={};M.__index=M;PBT.Match=M
local active={inviting=true,invited=true,accepted=true,countdown=true,playing=true}
-- BroadcastAddOnDataToGroup runs on a cooldown, and every add-on on the client shares that one
-- channel, so a hop can take seconds rather than the moment a local test takes. Agreeing to
-- start takes four hops, which has to fit inside these.
local LEAD=12         -- from both sides agreeing to the boards starting
local WINDOW=45       -- how long an invite, an accept and the handshake may take in total
local QUIET=30        -- silence during play before the duel is abandoned
local function uint(n,max) return type(n)=="number" and n==math.floor(n) and n>=0 and n<=max end
function M.New(o) return setmetatable({o=o,state="idle",nextSend=0,closed={},cooldown={}},M) end
function M:Active() return active[self.state]==true end
function M:Notify() if self.o.changed then self.o.changed(self) end end
function M:Reset(peer,session,seed,host,state)
 if self.peer then self.closed[self.peer..":"..self.session]=self.o.now()+120 end
 self.peer,self.session,self.seed,self.host,self.state=peer,session,seed,host,state
 self.engine=nil;self.startAt=0;self.armed=false;self.received=0;self.terminal=0
 self.peerTerminal=0;self.peerHeight=0;self.reason=nil;self.result=nil;self.untilTime=nil
 self.lastSeen=self.o.now();self.deadline=self.o.now()+WINDOW;self.nextSend=0
end
function M:Packet(kind)
 return {kind=kind,session=self.session,seed=self.seed,startAt=self.startAt,
  attack=self.engine and self.engine.sent or 0,height=self.engine and self.engine:Height() or 0,terminal=self.terminal}
end
function M:Send(kind)
 if not self.o.send(self.peer,self:Packet(kind)) then self:Abort("通信を送信できませんでした。",false);return false end
 return true
end
function M:Invite(peer)
 if self:Active() or peer==self.o.name or not self.o.allowed(peer) then return false end
 self:Reset(peer,self.o.random(),self.o.random()%2147483646+1,true,"inviting")
 if self:Send(1) then self:Notify();return true end
 -- Send already aborted with a reason. Returning it is what puts it in front of the player:
 -- the board never opens on a failed invite, so nothing else would ever show it.
 return false,self.reason
end
function M:Accept()
 if self.state~="invited" then return end
 self.state="accepted";self.nextSend=0;self:Send(2);self:Notify()
end
function M:Abort(reason,send)
 if send and self.peer then self.o.send(self.peer,self:Packet(6)) end
 self.state="aborted";self.reason=reason
 if self.peer then self.closed[self.peer..":"..self.session]=self.o.now()+120 end
 self:Notify()
end
function M:Quit()
 if self.state=="playing" then self.terminal=2;self:Resolve();self:Send(5)
 elseif self:Active() then self:Abort("対戦を中止しました。",true) end
end
function M:Resolve()
 if self.engine and self.engine.over and self.terminal==0 then self.terminal=1 end
 if self.terminal==0 and self.peerTerminal==0 then return end
 self.state="result";self.untilTime=self.untilTime or self.o.now()+20
 if self.terminal>0 and self.peerTerminal>0 then self.result="同時終了・引き分け"
 elseif self.terminal>0 then self.result="あなたの負け"
 else self.result="あなたの勝ち！" end
 self:Notify()
end
function M:Receive(sender,p)
 -- Incoming packets are vetted with allowedFrom, which does not repeat the checks that decide
 -- whether this player may open a duel. Refusing what has already arrived on those grounds is
 -- how a duel ends up silently one-sided.
 local allowed=self.o.allowedFrom or self.o.allowed
 if sender==self.o.name or not allowed(sender) or type(p)~="table" then return end
 for key,max in pairs({kind=6,session=4294967295,seed=2147483647,startAt=4294967295,attack=65535,height=22,terminal=2}) do
  if not uint(p[key],max) then return end
 end
 if p.kind<1 or p.seed<1 then return end
 local now=self.o.now();local key=sender..":"..p.session
 if self.closed[key] then return end
 if p.kind==1 then
  if self.state=="result" and sender==self.peer and p.session==self.session then return end
  if self:Active() then
   if sender==self.peer and p.session==self.session then
    if self.state=="accepted" then self:Send(2) end
    return
   end
   if not (self.state=="inviting" and sender==self.peer and sender<self.o.name) then return end
   self.closed[self.peer..":"..self.session]=now+120
  end
  if self.cooldown[sender] and self.cooldown[sender]>now then return end
  self.cooldown[sender]=now+10
  self:Reset(sender,p.session,p.seed,false,"invited");self:Notify();return
 end
 if sender~=self.peer or p.session~=self.session or p.seed~=self.seed then return end
 if not self:Active() and self.state~="result" then return end
 self.lastSeen=now
 if p.kind==6 then if self.state~="result" then self:Abort("相手が対戦を中止しました。",false) end;return end
 if p.kind==2 and self.host then
  if self.state=="inviting" then self.startAt=self.o.wall()+LEAD;self.state="countdown";self.deadline=now+WINDOW end
  if self.state=="countdown" then self:Send(3) end
 elseif p.kind==3 and not self.host and (self.state=="accepted" or self.state=="countdown") then
  if self.state=="accepted" then
   -- Wide on purpose. A proposal that spent a while in the send queue can arrive with its
   -- moment already past, and the two clients' clocks need not agree to the second.
   if p.startAt<self.o.wall()-WINDOW or p.startAt>self.o.wall()+WINDOW then return end
   self.startAt=p.startAt;self.state="countdown";self.deadline=now+WINDOW
  elseif p.startAt~=self.startAt then return end
  self:Send(4)
 elseif p.kind==4 and self.host and self.state=="countdown" and p.startAt==self.startAt then
  self.armed=true;self:Send(5)
 elseif p.kind==5 and p.startAt==self.startAt and self.startAt>0 then
  if self.state=="countdown" and not self.host then self.armed=true end
  if self.state=="playing" or self.state=="result" then
   if p.attack>self.received then
    local delta=p.attack-self.received;self.received=p.attack
    if self.state=="playing" then self.engine:AddGarbage(delta) end
   end
   self.peerHeight=p.height
   self.peerTerminal=math.max(self.peerTerminal,p.terminal)
   self:Resolve()
  end
 end
 self:Notify()
end
function M:Tick(dt)
 local now=self.o.now()
 for k,t in pairs(self.closed) do if now>=t then self.closed[k]=nil end end
 for k,t in pairs(self.cooldown) do if now>=t then self.cooldown[k]=nil end end
 if self:Active() and not self.o.allowed(self.peer) then self:Abort("相手との通信ができないため対戦を中止しました。",true);return end
 -- Starts when both ends have agreed and the moment has come, in that order. Reaching the
 -- moment without having agreed used to end the duel on the spot, which gave the handshake
 -- only the lead time to finish; it now has until the deadline, and starts at once if the
 -- agreement lands after the moment has already passed.
 if self.state=="countdown" and self.armed and self.o.wall()>=self.startAt then
  self.engine=PBT.Engine.New(self.seed,true);self.state="playing";self.lastSeen=now;self:Notify()
 elseif self:Active() and self.state~="playing" and now>=self.deadline then
  self:Abort(self.state=="countdown" and "開始の同期に失敗しました。もう一度招待してください。" or "招待が時間切れになりました。",true);return
 end
 if self.state=="playing" then
  if now-self.lastSeen>QUIET then self:Abort("通信が途切れたため、勝敗を付けずに中止しました。",true);return end
  if self.engine.sent>65535 then self:Abort("対戦の通信上限に達しました。",true);return end
  if self.engine.over then self.terminal=1;self:Resolve();self:Send(5) end
 end
 if now>=self.nextSend then
  self.nextSend=now+1.5
  if self.state=="inviting" then self:Send(1)
  elseif self.state=="accepted" then self:Send(2)
  elseif self.state=="countdown" then
   if self.host then self:Send(self.armed and 5 or 3) else self:Send(4) end
  elseif self.state=="playing" or (self.state=="result" and now<(self.untilTime or 0)) then self:Send(5) end
 end
end
