HomesteadEng.TO={};
local TO=HomesteadEng.TO;

TO.__index=TO;

function TO.New()
  local result={};
  result.count=0;
  result.list={};
  result.find={};
  setmetatable(result,TO);
  return result;
end

function TO:Next(window)
  local idx=self.find[window];
  if not idx then
    return nil;
  end
  local tries=self.count
  while tries>0 do
    if idx==self.count then
      idx=1;
    else
      idx=idx+1;
    end
    if self.list[idx]:GetEditEnabled() then
      return self.list[idx];
    end
    tries=tries-1;
  end
  return window;
end

function TO:Prev(window)
  local idx=self.find[window];
  if not idx then
    return nil;
  end
  local tries=self.count;
  while tries>0 do
    if idx==1 then
      idx=self.count;
    else
      idx=idx-1;
    end
    if self.list[idx]:GetEditEnabled() then
      return self.list[idx];
    end
    tries=tries-1;
  end
  return window;
end

function TO:Tab(window)
  local newWnd=self:Next(window);
  if not newWnd then
    return
  end
  newWnd:TakeFocus();
end

function TO:Insert(window,index)
  assert(type(self)=="table");
  assert(window:GetType()==CT_EDITBOX,"Only Editbox can be added to the tab order");
  if self.find[window] then
    return;
  end
  index=index or self.count+1;
  table.insert(self.list,index,window);
  self.count=self.count+1;
  for fixIdx=index,self.count do
    self.find[self.list[fixIdx]]=fixIdx;
  end
  window:SetHandler("OnTab",function () self:Tab(window);end);
end

function TO:InsertAfter(addThis,afterThis)
  local index=self.find[afterThis];
  if not index then
    return
  end
  return self:Insert(addThis,index+1);
end
