HomesteadEng={};
local HE=HomesteadEng;
HE.name="HomesteadEngineer"; --If this doesn't match what's in the .txt file, stuff will break...
HE.a={};

local HISTORY_VALID=1.0;
local TR=HomesteadEngTransform;

function HE.Log(data)
  table.insert(HE.a,data)
end

function HE.CheckTarget()
  if GetHousingEditorMode()~=HOUSING_EDITOR_MODE_SELECTION 
      or not HousingEditorCanSelectTargettedFurniture() then
    return nil;
  end
  LockCameraRotation(true);
  HousingEditorSelectTargettedFurniture();
  local furnId=HousingEditorGetSelectedFurnitureId();
  -- Do this EHT's way to avoid interop issues
  HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_DISABLED);
  HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION);
  --HousingEditorRequestSelectedPlacement();
  LockCameraRotation(false);
  return furnId;
end

function HE.C2L(x,y,z,p,w,r)
  return {x,y,z,p,w,r};
end

function HE.L2C(list)
  return list[1],list[2],list[3],list[4],list[5],list[6];
end

function HE.SelectPrimary()
  HE.SetPrimary(HE.CheckTarget());
end

function HE.SetPrimary(targetFurn)
  if targetFurn then
    HE.primaryTarget=targetFurn;
    HE.Wnd.ItemAdj:SetItem(targetFurn);
  end
end

function HE.SetLocalTransform(x,y,z,p,w,r)
  if not HE.locTrC or x~=HE.locTrC[1] or y~=HE.locTrC[2] or z~=HE.locTrC[3] or p~=HE.locTrC[4] or w~=HE.locTrC[5] or r~=HE.locTrC[6] then
    HE.locTrC={x,y,z,p,w,r};
    HE.locTr=TR.CoordToTransform(HE.L2C(HE.locTrC));
    HomesteadEngMover.OnLocalChanged();
    HE.Wnd.ItemAdj:LocalChanged();
  end
end

function HE.AddRetrieveBind()
  local panel=KEYBOARD_HOUSING_FURNITURE_BROWSER and KEYBOARD_HOUSING_FURNITURE_BROWSER.retrievalPanel;
  if not panel then
    return
  end
  local bind={
    name="Target in HomesteadEngineer",
    keybind="HOMESTEAD_ENG_UI_CONTEXT";
    callback=function()
      local sel=panel:GetMostRecentlySelectedData();
      if sel then
        HE.SetPrimary(sel.retrievableFurnitureId);
      end
    end,
    enabled=function()
      return panel:GetMostRecentlySelectedData()~=nil;
    end,
  };
  table.insert(panel.keybindStripDescriptor,bind);
end

function HE.OnAddOnLoaded(event,addonName)
  if(addonName==HE.name) then
    ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_ENG_SELECT_PRIMARY","Target furniture");
    HE.Wnd={};
    HE.Wnd.ItemAdj=HomesteadEngItemAdj;
    HE.Log("OnAddOnLoaded");
    HomesteadEngMover.Init();
    HE.lock=false;
    
    HE.SetLocalTransform(0,0,0,0,0,0);
    
    HE.AddRetrieveBind();
    
    EVENT_MANAGER:UnregisterForEvent(HE.name,EVENT_ADD_ON_LOADED);
  end
end

function HE.OnZone(event)
  HE.primaryTarget=nil;
  HomesteadEngMover.OnZone();
  HE.Wnd.ItemAdj:SetItem(nil);
  HE.Wnd.ItemAdj:SetHidden(true);
end

function HE.ModeChanged(event,oldMode,newMode)
  if HE.lock and newMode~=HOUSING_EDITOR_MODE_PLACEMENT then
    HE.lock=false;
    HE.Wnd.ItemAdj:SetLock(false);
    HomesteadEngMover.SetLock(false);
  end
  
  if not HE.lock and newMode==HOUSING_EDITOR_MODE_PLACEMENT then
    HE.lock=true;
    HE.Wnd.ItemAdj:SetLock(true);
    HomesteadEngMover.SetLock(true);
  end
end

function HE.FurnRemoved(event,furnId)
  if HE.primaryTarget==furnId then
    HE.primaryTarget=nil;
  end
  HomesteadEngMover.OnFurnRemoved(furnId);
  
  HE.Wnd.ItemAdj:OnFurnRemoved(furnId);
end

EVENT_MANAGER:RegisterForEvent(HE.name,EVENT_ADD_ON_LOADED,HE.OnAddOnLoaded);
EVENT_MANAGER:RegisterForEvent(HE.name,EVENT_PLAYER_ACTIVATED,HE.OnZone);
EVENT_MANAGER:RegisterForEvent(HE.name,EVENT_HOUSING_EDITOR_MODE_CHANGED,HE.ModeChanged);
EVENT_MANAGER:RegisterForEvent(HE.name,EVENT_HOUSING_FURNITURE_REMOVED,HE.FurnRemoved);

--###############--

function HomesteadEngEdit_Initialize(self)
  HE.Log("HomesteadEngEdit_Initialize "..tostring(self));
  local edit=self:GetNamedChild("Edit");
  edit:SetHandler("OnEscape",function () edit:LoseFocus();end);
end

--###############--

function HomesteadEngLEdit_Initialize(self)
  local label;
  local edit;

  for i=1,self:GetNumChildren() do
    local lvl1=self:GetChild(i);
    local lvl1Type=lvl1:GetType();
    if lvl1Type==CT_EDITBOX then
      if not edit then
        edit=lvl1;
      end
    elseif lvl1Type==CT_LABEL then
      if not label then
        label=lvl1;
      end
    else
      for j=1,lvl1:GetNumChildren() do
        local lvl2=lvl1:GetChild(j);
        local lvl2Type=lvl2:GetType();
        if lvl2Type==CT_EDITBOX then
          if not edit then
            edit=lvl2;
          end
        elseif lvl2Type==CT_LABEL then
          if not label then
            label=lvl2;
          end
        else
        end
      end
    end
  end
  self.label=label;
  self.edit=edit;
end

--###############--

