DressingRoom.GearMarkers = {
  gearMap = {},
  marks = {}
}
local GearMarkers = DressingRoom.GearMarkers


function GearMarkers:buildMap()
  -- merge gear from sets in a single table for inventory markers & tooltips
  self.gearMap = {}
  for setId = 1, DressingRoom:numSets() do
    local gear = DressingRoom.sv.gearSet[setId]
    if gear then
      for k, _ in pairs(gear) do
        self.gearMap[k] = setId
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
    local old_setupCb = inventories[i].dataTypes[1].setupCallback
    inventories[i].dataTypes[1].setupCallback = function(control, slot)
      old_setupCb(control, slot)
      GearMarkers:addMarkerCallback(control)
    end
  end
end


function GearMarkers:addMarkerCallback(control)
  local slot = control.dataEntry.data
  local mark = self:getMark(control)
  local isInSomeSet = self.gearMap[Id64ToString(GetItemUniqueId(slot.bagId, slot.slotIndex))]
  mark:SetHidden(not isInSomeSet)
end


function GearMarkers:getMark(control)
  local mark = self.marks[control:GetName()]
  if not mark then
    mark = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    self.marks[control:GetName()] = mark
    mark:SetTexture("/esoui/art/ava/ava_resourcestatus_upkeeplevel_marker.dds")
 		mark:SetColor(1, 0.6, 0.2, 1)
		--mark:SetDrawLayer(3)
		mark:SetHidden(true)
    mark:SetDimensions(24,24)
    mark:SetAnchor(RIGHT, control, LEFT, 34)
  end
  return mark
end
