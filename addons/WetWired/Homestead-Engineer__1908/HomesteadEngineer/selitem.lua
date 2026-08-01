local function HomesteadEngSelItem_SetItem(self,furnID)
  if self.furnID==furnID then
    return;
  end
  if furnID==nil then
    self.furnID=nil;
    self:GetNamedChild("Link"):SetText("No selection");
    self:GetNamedChild("Cat"):SetText("");
    self:GetNamedChild("Subcat"):SetText("");
    self:GetNamedChild("Theme"):SetText("");
    self:GetNamedChild("Size"):SetText("");
    self:GetNamedChild("Origin"):SetText("");
    self:GetNamedChild("Tex"):SetHidden(true);
    return;
  end
  local rawName,icon,dataID=GetPlacedHousingFurnitureInfo(furnID);
  local itemLink,colLink=GetPlacedFurnitureLink(furnID,LINK_STYLE_DEFAULT);
  local name
  if itemLink and itemLink~="" then
    name=itemLink;
  elseif colLink and colLink~="" then
    name=colLink;
  else
    name=zo_strformat(SI_HOUSING_FURNITURE_NAME_FORMAT,rawName);
  end
  local catID,subCatID,themeID=GetFurnitureDataInfo(dataID);
  local catName=GetFurnitureCategoryInfo(catID);
  local subCatName=GetFurnitureCategoryInfo(subCatID);
  local themeName=GetString("SI_FURNITURETHEMETYPE",themeID);
  local furnx1,furny1,furnz1,furnx2,furny2,furnz2=HousingEditorGetFurnitureLocalBounds(furnID);
  local size=string.format("Size: %0.1f %0.1f %0.1f",100*(furnx2-furnx1),100*(furny2-furny1),100*(furnz2-furnz1));
  local origin=string.format("Origin: %0.1f %0.1f %0.1f",100*-furnx1,100*-furny1,100*-furnz1);
  self.furnID=furnID;
  self:GetNamedChild("Link"):SetText(name);
  self:GetNamedChild("Cat"):SetText(catName);
  self:GetNamedChild("Subcat"):SetText(subCatName);
  self:GetNamedChild("Theme"):SetText(themeName);
  self:GetNamedChild("Size"):SetText(size);
  self:GetNamedChild("Origin"):SetText(origin);
  self:GetNamedChild("Tex"):SetHidden(false);
  self:GetNamedChild("Tex"):SetTexture(icon);
end

function HomesteadEngSelItem_Initialize(self)
  self.SetItem=HomesteadEngSelItem_SetItem;
  self.furnID=0;--To make not nil
  self:SetItem(nil);
end
