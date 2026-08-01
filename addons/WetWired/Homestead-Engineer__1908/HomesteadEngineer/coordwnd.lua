local function RoundPos(value)
  return math.floor(value+.5);
end

local function RoundAngle(value)
  return math.floor(value*100+.5)/100;
end

local function HomesteadEngCoord_SetupEdit(self,name,label)
  local child=self:GetNamedChild(name);
  self.wnd[name]=child.edit;
  child.label:SetText(label);
  child.edit:SetHandler("OnTextChanged",function () self:OnTextChanged();end);
  child.edit:SetHandler("OnEnter",function () self:OnApply();end);
end

local function HomesteadEngCoord_EnableLoc(self,enable)
  local alpha=enable and 1 or .3;
  self.wnd.X:SetEditEnabled(enable);
  self.wnd.Y:SetEditEnabled(enable);
  self.wnd.Z:SetEditEnabled(enable);
  self:GetNamedChild("X"):SetAlpha(alpha);
  self:GetNamedChild("Y"):SetAlpha(alpha);
  self:GetNamedChild("Z"):SetAlpha(alpha);
end

local function HomesteadEngCoord_EnableRot(self,enable)
  local alpha=enable and 1 or .3;
  self.wnd.P:SetEditEnabled(enable);
  self.wnd.W:SetEditEnabled(enable);
  self.wnd.R:SetEditEnabled(enable);
  self:GetNamedChild("P"):SetAlpha(alpha);
  self:GetNamedChild("W"):SetAlpha(alpha);
  self:GetNamedChild("R"):SetAlpha(alpha);
end

local function HomesteadEngCoord_AddToTO(self,tabOrder,afterWindow)
  local index;
  if afterWindow then
    index=tabOrder.find[afterWindow];
    if not index then
      return;
    end
  else
    index=tabOrder.count;
  end
  index=index+1;
  tabOrder:Insert(self.wnd.X,index);
  index=index+1;
  tabOrder:Insert(self.wnd.Y,index);
  index=index+1;
  tabOrder:Insert(self.wnd.Z,index);
  index=index+1;
  tabOrder:Insert(self.wnd.P,index);
  index=index+1;
  tabOrder:Insert(self.wnd.W,index);
  index=index+1;
  tabOrder:Insert(self.wnd.R,index);
end

local function HomesteadEngCoord_OnApply(self)
  self:ReadEdit();
  if not self.Callback then
    return
  end
  self.Callback(
    self.read.x,
    self.read.y,
    self.read.z,
    math.rad(self.read.p),
    math.rad(self.read.w),
    math.rad(self.read.r)
  );
end

local function HomesteadEngCoord_OnReset(self)
  self:WriteEdit();
end

local function HomesteadEngCoord_ReadEdit(self)
  self.read.x=tonumber(self.wnd.X:GetText()) or self.coord.x;
  self.read.y=tonumber(self.wnd.Y:GetText()) or self.coord.y;
  self.read.z=tonumber(self.wnd.Z:GetText()) or self.coord.z;
  self.read.p=RoundAngle(tonumber(self.wnd.P:GetText()) or self.coord.p);
  self.read.w=RoundAngle(tonumber(self.wnd.W:GetText()) or self.coord.w);
  self.read.r=RoundAngle(tonumber(self.wnd.R:GetText()) or self.coord.r);
  if self.read.x~=self.coord.x or 
     self.read.y~=self.coord.y or 
     self.read.z~=self.coord.z or 
     self.read.p~=self.coord.p or 
     self.read.w~=self.coord.w or
     self.read.r~=self.coord.r then
     self.dirty=true;
    self.wnd.reset:SetEnabled(true);
  end
end

local function HomesteadEngCoord_WriteEdit(self)
  self.wnd.X:SetText(string.format("%.0f",self.coord.x));
  self.wnd.Y:SetText(string.format("%.0f",self.coord.y));
  self.wnd.Z:SetText(string.format("%.0f",self.coord.z));
  self.wnd.P:SetText(string.format("%.2f",self.coord.p));
  self.wnd.W:SetText(string.format("%.2f",self.coord.w));
  self.wnd.R:SetText(string.format("%.2f",self.coord.r));
  self.dirty=false;
  self.wnd.reset:SetEnabled(false);
end

local function HomesteadEngCoord_OnTextChanged(self)
  self:ReadEdit();
end

local function HomesteadEngCoord_SetCoords(self,x,y,z,p,w,r,clear)
  self.coord.x=RoundPos(tonumber(x));
  self.coord.y=RoundPos(tonumber(y));
  self.coord.z=RoundPos(tonumber(z));
  self.coord.p=RoundAngle(math.deg(tonumber(p)));
  self.coord.w=RoundAngle(math.deg(tonumber(w)));
  self.coord.r=RoundAngle(math.deg(tonumber(r)));
  if clear or not self.dirty then
    self:WriteEdit();
  end
end

local function HomesteadEngCoord_SetCallback(self,callback)
  self.Callback=callback;
  if callback then
    self.wnd.apply:SetEnabled(true);
  else
    self.wnd.apply:SetEnabled(false);
  end
end

function HomesteadEngCoord_Initialize(self)
  HomesteadEng.Log("HomesteadEngCood_Initialize "..tostring(self));
  self.wnd={};
  self.coord={x=0,y=0,z=0,p=0,w=0,z=0};
  self.read={};
  self.dirty=false;

  self.AddToTO=HomesteadEngCoord_AddToTO;
  self.OnApply=HomesteadEngCoord_OnApply;
  self.OnReset=HomesteadEngCoord_OnReset;
  self.ReadEdit=HomesteadEngCoord_ReadEdit;
  self.WriteEdit=HomesteadEngCoord_WriteEdit;
  self.OnTextChanged=HomesteadEngCoord_OnTextChanged;
  self.SetCoords=HomesteadEngCoord_SetCoords;
  self.EnableLoc=HomesteadEngCoord_EnableLoc;
  self.EnableRot=HomesteadEngCoord_EnableRot;
  self.SetCallback=HomesteadEngCoord_SetCallback;

  self.wnd.apply=self:GetNamedChild("Apply");
  self.wnd.reset=self:GetNamedChild("Reset");
  self.wnd.apply:SetEnabled(false);
  self.wnd.reset:SetEnabled(false);

  HomesteadEngCoord_SetupEdit(self,"X","X");
  HomesteadEngCoord_SetupEdit(self,"Y","Y");
  HomesteadEngCoord_SetupEdit(self,"Z","Z");
  HomesteadEngCoord_SetupEdit(self,"P","Pitch");
  HomesteadEngCoord_SetupEdit(self,"W","Yaw");
  HomesteadEngCoord_SetupEdit(self,"R","Roll");

  self:SetCoords(0,0,0,0,0,0);

  HomesteadEng.Log("HomesteadEngCood_Initialize "..tostring(self));
end

