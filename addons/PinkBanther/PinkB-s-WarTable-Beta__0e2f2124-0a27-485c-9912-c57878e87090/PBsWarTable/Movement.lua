-- One pooled lift/travel/land sprite. Gameplay is already committed; this is visual only.
local M={};M.__index=M;PBWT.Movement=M
local DURATION=420
local function ease(t) return t*t*(3-2*t) end
function M.New(ui)
 local self=setmetatable({ui=ui,positions={}},M)
 self.shadow=WINDOW_MANAGER:CreateControl(nil,ui.content,CT_BACKDROP)
 self.shadow:SetEdgeTexture('',1,1,1);self.shadow:SetEdgeColor(0,0,0,0);self.shadow:SetDrawLayer(DL_OVERLAY);self.shadow:SetHidden(true)
 self.sprite=WINDOW_MANAGER:CreateControl(nil,ui.content,CT_TEXTURE)
 self.sprite:SetDrawLayer(DL_OVERLAY);self.sprite:SetHidden(true)
 self.tick=function() self:Tick(GetFrameTimeMilliseconds()) end
 return self
end
function M:Restore()
 local ui=self.ui
 if self.id then
  local p=PBWT.Engine.Piece(ui.state,self.id)
  if p and p.alive then local c=ui:Cell(p.x,p.y);c.icon:SetHidden(not PBWT.Assets.IsUsable(c.icon)) end
 end
end
function M:Stop()
 EVENT_MANAGER:UnregisterForUpdate('PBsWarTableMovement')
 self:Restore();self.active=false;self.id=nil;self.sprite:SetHidden(true);self.shadow:SetHidden(true)
end
function M:Reset() self:Stop();self.turn=nil;for _,v in pairs(self.positions) do v.alive=false end end
function M:HideDestination()
 if self.active then
  local p=PBWT.Engine.Piece(self.ui.state,self.id)
  if p and p.alive then self.ui:Cell(p.x,p.y).icon:SetHidden(true) end
 end
end
function M:Observe()
 local ui,s=self.ui,self.ui.state
 local enabled=ui.visible and not ui.showRecords and not ui.transition.phase and s.status=='playing' and PBWT.Records.Data().presentation=='full'
 local networkBlocked=ui.mode=='online' and (not ui.network or ui.network.phase~='active')
 if networkBlocked or self.networkBlocked then enabled=false end
 self.networkBlocked=networkBlocked
 if self.active then
  local p=PBWT.Engine.Piece(s,self.id)
  if self.turn~=s.turn or not p or not p.alive then self:Stop() end
 end
 local moved,fromX,fromY,count=nil,nil,nil,0
 for _,p in ipairs(s.pieces) do
  local old=self.positions[p.id]
  if old and old.alive and p.alive and (old.x~=p.x or old.y~=p.y) then moved,fromX,fromY=p,old.x,old.y;count=count+1 end
 end
 if not enabled then self:Stop()
 elseif count>0 then
  self:Stop()
  if count==1 and self.turn==s.turn then
   local cell=ui:Cell(moved.x,moved.y)
   if PBWT.Assets.IsUsable(cell.icon) then
    self.sprite.pbwtKind=cell.icon.pbwtKind;self.sprite:SetTexture(PBWT.Assets.Path(cell.icon.pbwtKind,cell.icon.pbwtRoot))
    if PBWT.Assets.IsUsable(self.sprite) then
     self.id,self.x1,self.y1,self.x2,self.y2=moved.id,fromX,fromY,moved.x,moved.y
     self.active,self.started=true,GetFrameTimeMilliseconds();self.sprite:SetColor(1,1,1,1)
     self.sprite:SetHidden(false);self.shadow:SetHidden(false);self:Tick(self.started)
     EVENT_MANAGER:RegisterForUpdate('PBsWarTableMovement',16,self.tick)
    end
   end
  end
 end
 for _,p in ipairs(s.pieces) do
  local v=self.positions[p.id] or {};self.positions[p.id]=v;v.x,v.y,v.alive=p.x,p.y,p.alive
 end
 self.turn=s.turn;self:HideDestination()
end
function M:Tick(now)
 if not self.active then return end
 if not self.ui.visible then self:Stop();return end
 local t=math.max(0,math.min(1,(now-self.started)/DURATION))
 local travel=ease(math.max(0,math.min(1,(t-0.22)/0.56)))
 local lift=t<0.22 and ease(t/0.22) or t>0.78 and 1-ease((t-0.78)/0.22) or 1
 local g=self.ui.boardGeom or {originX=420,originY=190,pitch=120,cellSize=110,icon=68,iconTop=20,k=1}
 local k=g.k
 local x=g.originX+(g.cellSize-g.icon)/2+((self.x1-1)+(self.x2-self.x1)*travel)*g.pitch
 local y=g.originY+g.iconTop+((self.y1-1)+(self.y2-self.y1)*travel)*g.pitch
 local size=g.icon+10*k*lift
 self.sprite:SetDimensions(size,size);self.sprite:SetAnchor(TOPLEFT,self.ui.content,TOPLEFT,x-(size-g.icon)/2,y-20*k*lift-(size-g.icon)/2)
 self.shadow:SetDimensions(g.icon-6+12*k*lift,g.icon-6+12*k*lift);self.shadow:SetAnchor(TOPLEFT,self.ui.content,TOPLEFT,x+4*k+3*k*lift,y+6*k+5*k*lift)
 self.shadow:SetCenterColor(0,0,0,0.30-0.10*lift)
 self:HideDestination()
 if t>=1 then self:Stop();self.ui:SyncComputer() end
end
