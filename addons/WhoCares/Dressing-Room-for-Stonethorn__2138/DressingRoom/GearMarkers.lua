DressingRoom.GearMarkers = {
  gearMap = {},
  marks = {}
}
local GearMarkers = DressingRoom.GearMarkers


function GearMarkers:buildMap()
  -- merge gear from sets in a single table for inventory markers & tooltips
  self.gearMap = {}
  local maxPage, groupRoles
  if DressingRoom.enablePages then
    maxPage = #DressingRoom.ram.page.pages
  else
    maxPage = 1
  end
  if DressingRoom.roleSpecificPresets then
    groupRoles = DressingRoom.groupRoles
  else
    groupRoles = {[DressingRoom.currentGroupRole] = DressingRoom.groupRoles[DressingRoom.currentGroupRole]}
  end
  for pageId = maxPage, 1, -1 do
   for roleId in pairs(groupRoles) do
    for setId = 1, DressingRoom:numSets() do
      local gear = DressingRoom.ram.page.byRole[roleId][pageId].gearSet[setId]
      if gear then
        for k, _ in pairs(gear) do
          -- disgusting workaround for the messy data file structure
          if k ~= "emptySlots" and k ~= "name" and k ~= "text" then
            if type(self.gearMap[k]) ~= "table" then
              self.gearMap[k] = {}
            end
            table.insert(self.gearMap[k], {pageId = pageId, roleId = roleId, setId = setId})
          end
        end
      end
    end
   end
  end
end


function GearMarkers:initCallbacks()
  local inventories = {
    ZO_PlayerInventoryBackpack,
    ZO_PlayerBankBackpack,
    ZO_GuildBankBackpack,
    ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
    ZO_SmithingTopLevelImprovementPanelInventoryBackpack,
  }
  for i = 1, #inventories do
    SecurePostHook(inventories[i].dataTypes[1], "setupCallback", function(control, slot)
      GearMarkers:addMarkerCallback(control)
    end)
  end
end


function GearMarkers:addMarkerCallback(control)
  local slot = control.dataEntry.data
  local mark = self:getMark(control)

  mark:SetHandler("OnMouseEnter", function(control)
    local slotData = self.gearMap[Id64ToString(GetItemUniqueId(slot.bagId, slot.slotIndex))]
    local tooltipText = DressingRoom._msg.usedBy
    for i = 1, #slotData do
      local setName = DressingRoom.ram.page.byRole[slotData[i].roleId][slotData[i].pageId].customSetName[slotData[i].setId]
      if not setName then setName = string.format("%s %d", DressingRoom._msg.set, slotData[i].setId) end
      local pageName = DressingRoom.ram.page.name[slotData[i].pageId]
      tooltipText = tooltipText.."\n  "
      if DressingRoom.roleSpecificPresets then
        tooltipText = tooltipText.."|t24:24:"..DressingRoom:GetRoleIconTexturePath(slotData[i].roleId).."|t "
      end
      tooltipText = tooltipText..setName
      if DressingRoom.enablePages then
        tooltipText = tooltipText.." ("..pageName..")"
      end
    end
    ZO_Tooltips_ShowTextTooltip(control, BOTTOMRIGHT, tooltipText)
  end)
  mark:SetHandler("OnMouseExit", function()
    ZO_Tooltips_HideTextTooltip()
  end)

  local isInSomeSet = self.gearMap[Id64ToString(GetItemUniqueId(slot.bagId, slot.slotIndex))]
  mark:SetHidden(not isInSomeSet)
end


function GearMarkers:getMark(control)
  local name = control:GetName()
  local mark = self.marks[name]
  if not mark then
    mark = WINDOW_MANAGER:CreateControl(name.."_DressingRoomGearMarker", control, CT_TEXTURE)
    self.marks[name] = mark
    mark:SetTexture("/esoui/art/ava/ava_resourcestatus_upkeeplevel_marker.dds")
    mark:SetColor(0.6, 1, 0.2, 1)
    mark:SetDrawLayer(3)
    mark:SetHidden(true)
    mark:SetDimensions(12,12)
    mark:SetAnchor(RIGHT, control, LEFT, 40)
    mark:SetMouseEnabled(true)
  end
  return mark
end
