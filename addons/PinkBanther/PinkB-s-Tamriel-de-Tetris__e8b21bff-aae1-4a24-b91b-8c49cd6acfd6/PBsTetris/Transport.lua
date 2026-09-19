PBT=PBT or {}
-- Protocol ids are one number per add-on, shared across everything a player has installed, and
-- whichever add-on declares one second is refused outright. 460-469 is PinkBanther's block on
-- the LibGroupBroadcast id list: 460 is this, 461 PB's Janken and 462 PB's Translate. 509 and
-- 510, used before, were both taken by other add-ons.
-- BUILD must equal ## AddOnVersion in both manifests; package.py refuses to build otherwise.
-- It rides on the wire so that two players on different versions are told so, instead of each
-- silently discarding the other's packets as unreadable.
local T={ID=460,BUILD=11500};T.__index=T;PBT.Transport=T
-- Development ID, distinct from PBsJanken's 511. Reserve before public release.
-- attack, height and terminal ride in one word rather than three narrow fields of their own.
function T.Pack(packet) return (packet.attack or 0)*128+(packet.height or 0)*4+(packet.terminal or 0) end
function T.Unpack(packed,into)
 into.terminal=packed%4;into.height=math.floor(packed/4)%32;into.attack=math.floor(packed/128)
 return into
end
function T.Identity(name)
 local h=PBT.SHA256(name);return tonumber(h:sub(1,8),16),tonumber(h:sub(9,16),16)
end
function T:Find(peer)
 for i=1,GetGroupSize() do
  local tag=GetGroupUnitTagByIndex(i)
  if GetUnitDisplayName(tag)==peer then return tag end
 end
end
-- Every refusal comes back with the reason it was refused. A duel that does not start is
-- otherwise indistinguishable from one that was never invited.
function T:Check(peer,outgoing)
 if not peer or peer=="" then return false,"送信者の表示名を取得できません" end
 if peer==GetDisplayName() then return false,"自分自身宛です" end
 local tag=self:Find(peer)
 if not tag then return false,"相手が同じグループにいません" end
 if not IsUnitOnline(tag) then return false,"相手がオフラインです" end
 if IsIgnored(peer) then return false,"相手を無視リストに入れています" end
 if IsUnitInCombat("player") then return false,"自分が戦闘中です" end
 if IsUnitInCombat(tag) then return false,"相手が戦闘中です" end
 -- The platform's communication permission decides what this add-on sends out. It is not
 -- asked again about what arrives: the library only delivers from inside the player's own
 -- group, the payload is game state rather than anything a player wrote, and a permission
 -- that answers differently on each end would drop every packet with nothing to show for it.
 if outgoing and not CanCommunicateWith(GetUnitName(tag)) then return false,"この相手との通信が許可されていません" end
 return true
end
function T:Allowed(peer) local ok=self:Check(peer,true);return ok end
function T:AllowedFrom(peer) local ok=self:Check(peer,false);return ok end
function T.New(receive,refused)
 local self=setmetatable({},T)
 if not LibGroupBroadcast then self.error="対戦にはLibGroupBroadcastが必要です。";return self end
 local ok,err=pcall(function()
  local handler=assert(LibGroupBroadcast:RegisterHandler("PBsTetris"))
  handler:SetDisplayName("PB's Tamriel de Tetris")
  handler:SetDescription("グループ内で落ちものパズル対戦")
  local p=handler:DeclareProtocol(T.ID,"PBsTetrisV3Dev");self.protocol=p
  p:SetDisplayName("PB's Tamriel de Tetris")
  -- Laid out like PBsJanken's, which is the shape known to work on console: two bits of
  -- version, three of kind, and everything else a full 32 bit word. The odd widths this used
  -- to declare (31, 16, 5, 2) are the only thing that differed from it at the wire level.
  -- version and build come first and keep their widths forever. Whatever changes behind them,
  -- a client on another version can still read these two and say so.
  p:AddField(LibGroupBroadcast.CreateNumericField("version",{numBits=2}))
  p:AddField(LibGroupBroadcast.CreateNumericField("build",{numBits=32}))
  p:AddField(LibGroupBroadcast.CreateNumericField("kind",{numBits=3}))
  for _,key in ipairs({"target1","target2","session","seed","startAt","packed"}) do
   p:AddField(LibGroupBroadcast.CreateNumericField(key,{numBits=32}))
  end
  -- Resolved on use rather than at load: this runs from EVENT_ADD_ON_LOADED, where the client
  -- can still answer an empty display name, and an identity built from one would reject every
  -- packet addressed to the player for the rest of the session with nothing to show for it.
  local name,a,b
  local function own()
   local current=GetDisplayName()
   if current and current~="" and current~=name then name=current;a,b=T.Identity(current) end
   return a,b
  end
  self.Own=own
  p:OnData(function(tag,data)
   -- The library hands a sender its own broadcasts back. Dropped without a word, as PBsJanken
   -- drops it: it is not a failure and saying so would bury the failures that matter.
   local peer=GetUnitDisplayName(tag)
   if not peer or peer=="" or peer==GetDisplayName() then return end
   self.heard=(self.heard or 0)+1
   if data.build~=T.BUILD then
    self.mismatched=(self.mismatched or 0)+1
    self.why=string.format("相手のバージョンが違います（相手 %s / 自分 %d）",tostring(data.build),T.BUILD)
    if refused then refused(self.why) end
    return
   end
   local mine1,mine2=own()
   if data.version~=2 or data.target1~=mine1 or data.target2~=mine2 then
    self.misaddressed=(self.misaddressed or 0)+1
    self.why=string.format("自分宛ではありませんでした（宛先 %s,%s / 自分 %s,%s）",
     tostring(data.target1),tostring(data.target2),tostring(mine1),tostring(mine2))
    if refused then refused(self.why) end
    return
   end
   T.Unpack(data.packed or 0,data)
   local ok,why=self:Check(peer,false)
   if not ok then
    self.refused=(self.refused or 0)+1;self.why="受信を弾きました："..why
    if refused then refused(why) end
    return
   end
   self.taken=(self.taken or 0)+1;receive(peer,data)
  end)
  -- Everything this protocol sends is the current state of the match in full: the attack and
  -- terminal counts are running totals and the rest is fixed for the match, so a packet still
  -- waiting its turn is always superseded by the next one. Letting the newer packet replace it
  -- keeps one message in the queue instead of a backlog of stale ones, which matters because
  -- the broadcast runs on a cooldown that every add-on on the client shares.
  assert(p:Finalize({isRelevantInCombat=false,replaceQueuedMessages=true}))
 end)
 if not ok then
  self.protocol=nil
  -- DeclareProtocol only raises when the id or the name is already taken, so that error has
  -- one cause worth naming: something else on this client already holds the id, most often a
  -- second copy of this add-on. The library's own message names the protocol sitting there.
  local first=tostring(err):match("^[^\n]*") or tostring(err)
  self.detail=first:gsub("^.*[/\\]","")
  if first:find("already exists") then
   self.error=string.format("通信ID %d は、このクライアントの別のアドオンがすでに使用しています。（%s）",T.ID,self.detail)
  else
   self.error="対戦通信を初期化できません。（"..self.detail.."）"
  end
 end
 return self
end
function T:Send(peer,packet)
 if not self.protocol then self.why="通信が初期化されていません";return false end
 if not self.protocol:IsEnabled() then self.why="LibGroupBroadcastでこのアドオンの通信が無効になっています";return false end
 local ok,why=self:Check(peer,true)
 if not ok then self.why="送信できません："..why;return false end
 local p={version=2,build=T.BUILD,kind=packet.kind,session=packet.session,seed=packet.seed,startAt=packet.startAt,packed=T.Pack(packet)}
 p.target1,p.target2=T.Identity(peer)
 if self.protocol:Send(p,{replaceQueuedMessages=true})~=true then self.why="LibGroupBroadcastが送信を受け付けませんでした";return false end
 self.why=nil;self.sent=(self.sent or 0)+1;return true
end
function T:Report()
 if self.error then return self.error end
 -- `x and x()` keeps only the first return value, which is how the second half of the
 -- identity came out nil in the report while the real comparison had both halves.
 local mine1,mine2
 if self.Own then mine1,mine2=self.Own() end
 return string.format('通信ID %d / 版 %d / 有効 %s / グループ %d人 / 自分 %s(%s,%s) / 送信 %d / 受信 %d（版違い %d・自分宛でない %d・拒否 %d・採用 %d）%s',
  T.ID,T.BUILD,tostring(self.protocol and self.protocol:IsEnabled()),GetGroupSize() or 0,
  tostring(GetDisplayName()),tostring(mine1),tostring(mine2),
  self.sent or 0,self.heard or 0,self.mismatched or 0,self.misaddressed or 0,self.refused or 0,self.taken or 0,
  self.why and (' / 直近の失敗：'..self.why) or '')
end
