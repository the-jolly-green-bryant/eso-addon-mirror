local HE=HomesteadEng;
local Mover=HomesteadEngMover;
local TR=HomesteadEngTransform;

local function SetupSetAbs(self)
  local x,y,z,p,w,r=Mover.GetItemPos(self.furnID);
  self.lastLoc={x,y,z,p,w,r};
  self.wnd.CWnd:SetCoords(x,y,z,p,w,r);
end

local function UpdateSetAbs(self)
  local x,y,z,p,w,r=Mover.GetItemPos(self.furnID);
  local l=self.lastLoc;
  if x~=l[1] or y~=l[2] or z~=l[3] or p~=l[4] or w~=l[5] or r~=l[6] then
    self.lastLoc={x,y,z,p,w,r};
    self.wnd.CWnd:SetCoords(x,y,z,p,w,r);
  end
end

local function SetAbs(self,x,y,z,p,w,r)
  Mover.SetItemPos(self.furnID,x,y,z,p,w,r);
  self.wnd.CWnd:SetCoords(x,y,z,p,w,r);
  self.wnd.CWnd:WriteEdit();
end

local function SetupSetLoc(self)
  self.lastLoc={Mover.GetItemPos(self.furnID)};
  self.wnd.CWnd:SetCoords(Mover.GetItemPosLoc(self.furnID));
end

local function UpdateSetLoc(self)
  local x,y,z,p,w,r=Mover.GetItemPos(self.furnID);
  local l=self.lastLoc;
  if x~=l[1] or y~=l[2] or z~=l[3] or p~=l[4] or w~=l[5] or r~=l[6] then
    self.lastLoc={x,y,z,p,w,r};
    self.wnd.CWnd:SetCoords(Mover.GetItemPosLoc(self.furnID));
  end
end

local function SetLoc(self,x,y,z,p,w,r)
  Mover.SetItemPosLoc(self.furnID,x,y,z,p,w,r);
  self.wnd.CWnd:SetCoords(x,y,z,p,w,r);
  self.wnd.CWnd:WriteEdit();
end

local function MoveAbs(self,x,y,z,p,w,r)
  local x1,y1,z1,p1,w1,r1=Mover.GetItemPos(self.furnID);
  Mover.SetItemPos(self.furnID,x1+x,y1+y,z1+z,p1,w1,r1);
end

local function MoveLoc(self,x,y,z,p,w,r)
  local x1,y1,z1,p1,w1,r1=Mover.GetItemPosLoc(self.furnID);
  Mover.SetItemPosLoc(self.furnID,x1+x,y1+y,z1+z,p1,w1,r1);
end

local function MoveRel(self,x,y,z,p,w,r)
  Mover.MoveItemRel(self.furnID,x,y,z);
end

local function RotAbs(self,x,y,z,p,w,r)
  local x1,y1,z1,p1,w1,r1=Mover.GetItemPos(self.furnID);
  Mover.SetItemPos(self.furnID,x1,y1,z1,p1+p,w1+w,r1+r);
end

local function RotLoc(self,x,y,z,p,w,r)
  local x1,y1,z1,p1,w1,r1=Mover.GetItemPosLoc(self.furnID);
  Mover.SetItemPosLoc(self.furnID,x1,y1,z1,p1+p,w1+w,r1+r);
end

local function RotRel(self,x,y,z,p,w,r)
  Mover.RotItemRel(self.furnID,p,w,r);
end

local function SetupSetOrigin(self)
  self.wnd.CWnd:SetCoords(HE.L2C(HE.locTrC));
end

local function SetOrigin(self,x,y,z,p,w,r)
  HE.SetLocalTransform(x,y,z,p,w,r);
end

local function SetOriginFromTarget(self)
  if self.furnID then
    HE.SetLocalTransform(Mover.GetItemPos(self.furnID));
  end
end

local function Zero(self)
  self.wnd.CWnd:SetCoords(0,0,0,0,0,0);
end

local menu={
  {type="title",text="Set Location"},
  {type="sel",  text="Absolute",    title="Set Absolute",   showpos=true, showrot=true,callback=SetAbs,   setup=SetupSetAbs,update=UpdateSetAbs},
  {type="sel",  text="Local",       title="Set Local",      showpos=true, showrot=true,callback=SetLoc,   setup=SetupSetLoc,update=UpdateSetLoc,udloc=true},
  {type="title",text="Move"},
  {type="sel",  text="Absolute",    title="Move Absolute",  showpos=true, showrot=false,callback=MoveAbs, setup=Zero},
  {type="sel",  text="Local",       title="Move Local",     showpos=true, showrot=false,callback=MoveLoc, setup=Zero},
  {type="sel",  text="Relative",    title="Move Relative",  showpos=true, showrot=false,callback=MoveRel, setup=Zero},
  {type="title",text="Rotate"},
  {type="sel",  text="Absolute",    title="Rotate Absolute",showpos=false,showrot=true,callback=RotAbs,   setup=Zero},
  {type="sel",  text="Local",       title="Rotate Local",   showpos=false,showrot=true,callback=RotLoc,   setup=Zero},
  {type="sel",  text="Relative",    title="Rotate Relative",showpos=false,showrot=true,callback=RotRel,   setup=Zero},
  {type="title",text="Config Local Coords"},
  {type="sel",  text="Edit origin",title="Edit Local Origin",showpos=true, showrot=true,callback=SetOrigin,setup=SetupSetOrigin,udloc=true,itemless=true},
  {type="act",  text="Set from target",action=SetOriginFromTarget}
};

local function HomesteadEngItemAdj_CoordItemAndMode(self,setmode)
  if not self.furnID and not menu[self.sel].itemless then
    Zero(self);
    self.wnd.CWnd:EnableLoc(false);
    self.wnd.CWnd:EnableRot(false);
    self.wnd.CWnd:SetCallback(nil);
    return;
  end
  if setmode or not menu[self.sel].itemless then 
    menu[self.sel].setup(self);
    self.wnd.CWnd:WriteEdit();
    self.wnd.CWnd:EnableLoc(menu[self.sel].showpos);
    self.wnd.CWnd:EnableRot(menu[self.sel].showrot);
    if not self.lock then
      self.wnd.CWnd:SetCallback(function (x,y,z,p,w,r) menu[self.sel].callback(self,x,y,z,p,w,r);end);
    end
  end
end

local function OnItemPress(self,idx)
  if menu[idx].type=="sel" then
    if self.sel==idx then
      return
    end
    if self.sel then
      self.menu[self.sel]:SetState(0);
    end
    self.sel=idx;
    self.menu[idx]:SetState(3);
    self.wnd.Title:SetText(menu[idx].title);
    HomesteadEngItemAdj_CoordItemAndMode(self,true);
  elseif menu[idx].type=="act" then
    if menu[idx].action then
      menu[idx].action(self);
    end
  end
end

local function HomesteadEngItemAdj_BuildMenu(self,menuParent)
  local anchor=menuParent;
  local anchorPoint=TOPLEFT;
  local anchorOfs=0;
  local newItem;

  HomesteadEng.Log("Build");

  self.menu={};

  for i=1,#menu do
    HomesteadEng.Log(menu[i].text);
    if menu[i].type=="sel" then
      newItem=WINDOW_MANAGER:CreateControlFromVirtual("item"..i,menuParent,"HomesteadEngMenuButton");
      newItem:SetHandler("OnClicked",function () OnItemPress(self,i);end);
      newItem:SetAnchor(TOPLEFT,anchor,anchorPoint,0,anchorOfs);
      anchorOfs=0;
    elseif menu[i].type=="act" then
      newItem=WINDOW_MANAGER:CreateControlFromVirtual("item"..i,menuParent,"HomesteadEngMenuButtonAction");
      newItem:SetHandler("OnClicked",function () OnItemPress(self,i);end);
      newItem:SetAnchor(TOPLEFT,anchor,anchorPoint,0,anchorOfs+3);
      anchorOfs=3;
    else
      newItem=WINDOW_MANAGER:CreateControlFromVirtual("item"..i,menuParent,"HomesteadEngMenuHead");
      newItem:SetAnchor(TOPLEFT,anchor,anchorPoint,0,anchorOfs);
      anchorOfs=0;
    end
    newItem:SetText(menu[i].text);
    anchor=newItem;
    anchorPoint=BOTTOMLEFT;
    self.menu[i]=newItem;
  end

  HomesteadEng.Log("Done");
end

local function HomesteadEngItemAdj_OnUpdate(self)
--  d("UD!"..tostring(self.sel)..","..tostring(self.furnID)..","..tostring(menu[self.sel].update));
  if self.sel and self.furnID and menu[self.sel].update then
    menu[self.sel].update(self);
  end
end

local function HomesteadEngItemAdj_OnClose(self)
  self:SetHidden(true);
end

local function HomesteadEngItemAdj_AddToTabOrder(self,window)
  self.TO:Insert(window);
end

local function HomesteadEngItemAdj_SetItem(self,furnID)
  if furnID then
    self:SetHidden(false);
  end
  if self.furnID==furnID then
    return;
  end
  self.furnID=furnID;
  self.wnd.SelWnd:SetItem(furnID);
  HomesteadEngItemAdj_CoordItemAndMode(self);
end

local function HomesteadEngItemAdj_LocalChanged(self)
  if menu[self.sel].udloc then
    menu[self.sel].setup(self);
  end
end

local function HomesteadEngItemAdj_SetLock(self,lock)
  self.lock=lock;
  if lock then
    self.wnd.CWnd:SetCallback(nil);
  elseif menu[self.sel].callback and (self.furnID or menu[self.sel].itemless) then
    self.wnd.CWnd:SetCallback(function (x,y,z,p,w,r) menu[self.sel].callback(self,x,y,z,p,w,r);end);
  end
end

local function HomesteadEngItemAdj_OnFurnRemoved(self,furnID)
  if furnID==self.furnID then
    self:SetItem(nil);
  end
end

function HomesteadEngItemAdj_Initialize(self)
  self.TO=HomesteadEng.TO.New();
  self.OnUpdate=HomesteadEngItemAdj_OnUpdate;
  self.OnClose=HomesteadEngItemAdj_OnClose;
  self.SetItem=HomesteadEngItemAdj_SetItem;
  self.LocalChanged=HomesteadEngItemAdj_LocalChanged;
  self.SetLock=HomesteadEngItemAdj_SetLock;
  self.OnFurnRemoved=HomesteadEngItemAdj_OnFurnRemoved;

  self.wnd={};
  self.wnd.CWnd=self:GetNamedChild("C");
  self.wnd.CWnd:AddToTO(self.TO);
  self.wnd.SelWnd=self:GetNamedChild("Sel");
  self.wnd.Title=self:GetNamedChild("Title");

  HomesteadEngItemAdj_BuildMenu(self,self:GetNamedChild("Menu"));
  OnItemPress(self,2);
  
  HomesteadEng.Log("HomesteadEngItemAdj_Initialize "..tostring(self));
end

