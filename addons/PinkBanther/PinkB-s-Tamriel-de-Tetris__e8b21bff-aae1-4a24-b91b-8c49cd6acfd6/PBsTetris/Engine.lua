PBT=PBT or {}
local E={WIDTH=10,HEIGHT=22,HIDDEN=2}; E.__index=E; PBT.Engine=E
local shapes={
 I={{0,1},{1,1},{2,1},{3,1}}, O={{0,0},{1,0},{0,1},{1,1}},
 T={{1,0},{0,1},{1,1},{2,1}}, J={{0,0},{0,1},{1,1},{2,1}},
 L={{2,0},{0,1},{1,1},{2,1}}, S={{1,0},{2,0},{0,1},{1,1}}, Z={{0,0},{1,0},{1,1},{2,1}},
}
E.names={"I","O","T","J","L","S","Z"}; E.ids={I=1,O=2,T=3,J=4,L=5,S=6,Z=7}
-- SRS offsets, x right and y up. Engine rows grow downwards.
local normal={
 ["01"]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}},["10"]={{0,0},{1,0},{1,-1},{0,2},{1,2}},
 ["12"]={{0,0},{1,0},{1,-1},{0,2},{1,2}},["21"]={{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}},
 ["23"]={{0,0},{1,0},{1,1},{0,-2},{1,-2}},["32"]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2}},
 ["30"]={{0,0},{-1,0},{-1,-1},{0,2},{-1,2}},["03"]={{0,0},{1,0},{1,1},{0,-2},{1,-2}},
}
local ikicks={
 ["01"]={{0,0},{-2,0},{1,0},{-2,-1},{1,2}},["10"]={{0,0},{2,0},{-1,0},{2,1},{-1,-2}},
 ["12"]={{0,0},{-1,0},{2,0},{-1,2},{2,-1}},["21"]={{0,0},{1,0},{-2,0},{1,-2},{-2,1}},
 ["23"]={{0,0},{2,0},{-1,0},{2,1},{-1,-2}},["32"]={{0,0},{-2,0},{1,0},{-2,-1},{1,2}},
 ["30"]={{0,0},{1,0},{-2,0},{1,-2},{-2,1}},["03"]={{0,0},{-1,0},{2,0},{-1,2},{2,-1}},
}
local function row() return {0,0,0,0,0,0,0,0,0,0} end
function E.New(seed,versus,force20G)
 local self=setmetatable({board={},rng=seed%2147483646+1,garbageRng=(seed+127)%2147483646+1,queue={},
  force20G=force20G==true,score=0,lines=0,level=1,pending=0,sent=0,cancelled=0,combo=-1,b2b=false,versus=versus,elapsed=0,gravity=0,lock=0,resets=0,paused=false},E)
 for y=1,22 do self.board[y]=row() end
 self:FillQueue(); self:Spawn(); return self
end
function E:Emit(kind) if self.onEvent then self.onEvent(kind) end end
function E:Random(n,garbage)
 local key=garbage and "garbageRng" or "rng"
 self[key]=(self[key]*16807)%2147483647
 return self[key]%n+1
end
function E:FillQueue()
 while #self.queue<8 do
  local bag={"I","O","T","J","L","S","Z"}
  for i=7,2,-1 do local j=self:Random(i);bag[i],bag[j]=bag[j],bag[i] end
  for _,name in ipairs(bag) do self.queue[#self.queue+1]=name end
 end
end
function E.Cells(name,rotation,x,y)
 local out={};local size=name=="I" and 4 or (name=="O" and 2 or 3)
 for _,cell in ipairs(shapes[name]) do
  local cx,cy=cell[1],cell[2]
  if name~="O" then for _=1,rotation do cx,cy=size-1-cy,cx end end
  out[#out+1]={x+cx,y+cy}
 end
 return out
end
function E:Fits(x,y,r,name)
 for _,p in ipairs(E.Cells(name or self.piece,r,x,y)) do
  if p[1]<1 or p[1]>10 or p[2]<1 or p[2]>22 or self.board[p[2]][p[1]]~=0 then return false end
 end
 return true
end
function E:Is20G() return self.force20G or self.level>=20 end
function E:Settle20G()
 if self:Is20G() and not self.over then self.y=self:GhostY();self.gravity=0 end
end
function E:Spawn(name)
 self:FillQueue();self.piece=name or table.remove(self.queue,1)
 self.x,self.y,self.rotation=4,1,0
 if self.piece=="O" then self.x=5 end
 self.gravity,self.lock,self.resets=0,0,0
 if not self:Fits(self.x,self.y,0) then self.over=true else self:Settle20G() end
end
function E:Grounded() return not self:Fits(self.x,self.y+1,self.rotation) end
function E:ResetLock(wasGrounded)
 if wasGrounded and self.resets<15 then self.lock=0;self.resets=self.resets+1 end
end
function E:Move(dx)
 if self.over or self.paused then return false end
 local ground=self:Grounded()
 if self:Fits(self.x+dx,self.y,self.rotation) then self.x=self.x+dx;self:Settle20G();self:ResetLock(ground);self:Emit("move");return true end
 return false
end
function E:Rotate(dir)
 if self.over or self.paused or self.piece=="O" then return false end
 local r=(self.rotation+dir)%4;local ground=self:Grounded()
 for _,k in ipairs((self.piece=="I" and ikicks or normal)[self.rotation..r]) do
  if self:Fits(self.x+k[1],self.y-k[2],r) then
   self.x,self.y,self.rotation=self.x+k[1],self.y-k[2],r;self:Settle20G();self:ResetLock(ground);self:Emit("rotate");return true
  end
 end
 return false
end
function E:GhostY()
 local y=self.y
 while self:Fits(self.x,y+1,self.rotation) do y=y+1 end
 return y
end
function E:Drop()
 if self.over or self.paused then return end
 local y=self:GhostY();self.score=self.score+2*(y-self.y);self.y=y;self:Lock()
end
function E:Hold()
 if self.over or self.paused or self.held then return false end
 local old=self.hold;self.hold=self.piece;self.held=true;self:Spawn(old);self:Emit("hold");return true
end
function E:AddGarbage(count)
 if self.over or count<=0 then return end
 self.pending=math.min(200,self.pending+count)
end
function E:ApplyGarbage()
 local count=self.pending;self.pending=0
 -- Applying over a board's height guarantees overflow; cap work, not outcome.
 for _=1,math.min(count,23) do
  for x=1,10 do if self.board[1][x]~=0 then self.over=true end end
  table.remove(self.board,1)
  local r={8,8,8,8,8,8,8,8,8,8};r[self:Random(10,true)]=0
  self.board[#self.board+1]=r
 end
 if count>22 then self.over=true end
end
function E:Lock()
 if self.over then return end
 local hidden=true
 for _,p in ipairs(E.Cells(self.piece,self.rotation,self.x,self.y)) do
  self.board[p[2]][p[1]]=E.ids[self.piece]
  if p[2]>2 then hidden=false end
 end
 if hidden then self.over=true;return end
 local rows={}
 for y=1,22 do
  local full=true;for x=1,10 do if self.board[y][x]==0 then full=false;break end end
  if full then rows[#rows+1]=y end
 end
 local cleared=#rows
 -- The board collapses now, so the drawing side is handed the rows as they stood and where
 -- they stood. It can wipe them away at its own pace without the engine waiting for it.
 self.wipe=nil
 if cleared>0 then
  local before={}
  for y=1,22 do local r={};for x=1,10 do r[x]=self.board[y][x] end;before[y]=r end
  local clearing={};for _,y in ipairs(rows) do clearing[y]=true end
  self.wipe={board=before,clearing=clearing,quad=cleared==4}
  for i=cleared,1,-1 do table.remove(self.board,rows[i]) end
  for _=1,cleared do table.insert(self.board,1,row()) end
 end
 self.lastClear=cleared
 self:Emit(cleared==4 and "quad" or (cleared>0 and "clear" or "lock"))
 local attack=0
 if cleared>0 then
  self.combo=self.combo+1
  local points=({100,300,500,800})[cleared] or 0
  attack=({0,1,2,4})[cleared] or 0
  if cleared==4 and self.b2b then points=points*1.5;attack=attack+1 end
  self.b2b=cleared==4
  self.score=self.score+(points+50*self.combo)*self.level
  attack=attack+math.min(4,math.floor(self.combo/2))
  local was=self.level
  self.lines=self.lines+cleared;self.level=math.floor(self.lines/10)+1
  if self.level>was then self:Emit('level') end
 else self.combo=-1 end
 local cancelled=math.min(attack,self.pending);self.pending=self.pending-cancelled;attack=attack-cancelled
 self.cancelled=self.cancelled+cancelled
 if self.versus then self.sent=self.sent+attack end
 self:ApplyGarbage();self.held=false
 if not self.over then self:Spawn() end
end
function E:Tick(dt,soft)
 if self.over or self.paused then return end
 -- Ignore huge suspended-frame gaps instead of simulating minutes in one frame.
 dt=math.min(math.max(dt,0),0.1);self.elapsed=self.elapsed+dt
 if self:Is20G() then self:Settle20G() else
 local interval=math.max(0.055,0.85*0.8^(self.level-1))
 if soft then interval=math.min(interval,0.035) end
 -- The timer carries whatever has built up towards the previous, slower interval. Spending
 -- that at the new one would empty it in a single frame: hold Down a moment before a slow
 -- fall was due and the piece would cross the whole board at once, exactly like a hard drop.
 if self.gravity>interval then self.gravity=interval end
 self.gravity=self.gravity+dt
 while self.gravity>=interval do
  self.gravity=self.gravity-interval
  if self:Fits(self.x,self.y+1,self.rotation) then self.y=self.y+1;if soft then self.score=self.score+1 end
  else break end
 end
 end
 if self:Grounded() then self.lock=self.lock+dt;if self.lock>=0.5 then self:Lock() end
 else self.lock=0 end
end
function E:Height()
 for y=1,22 do for x=1,10 do if self.board[y][x]~=0 then return 23-y end end end
 return 0
end
function E:View()
 local board={}
 for y=1,22 do board[y]={};for x=1,10 do board[y][x]=self.board[y][x] end end
 if not self.over then
  for _,p in ipairs(E.Cells(self.piece,self.rotation,self.x,self:GhostY())) do if board[p[2]][p[1]]==0 then board[p[2]][p[1]]=-E.ids[self.piece] end end
  for _,p in ipairs(E.Cells(self.piece,self.rotation,self.x,self.y)) do board[p[2]][p[1]]=E.ids[self.piece] end
 end
 return board
end
