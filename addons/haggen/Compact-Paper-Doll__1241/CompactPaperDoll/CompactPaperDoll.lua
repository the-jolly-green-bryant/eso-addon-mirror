-- CompactPaperDoll 1.0.0
-- Licensed under CC-NC-SA-4.0

CPD_VERSION = "1.0.0"

local function ResetAnchor(control, newPoint, newRelativeTo, newRelativePoint, newOffsetX, newOffsetY)
  local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor(0)
  d(control:GetName(), isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY)
  control:ClearAnchors()
  control:SetAnchor(newPoint or point, newRelativeTo or relativeTo, newRelativePoint or relativePoint, newOffsetX or offsetX, newOffsetY or offsetY)
end

local function CompactPaperDoll()
  ZO_CharacterPaperDoll:SetHidden(true)
  ZO_CharacterApparelSection:SetHidden(true)
  ZO_CharacterAccessoriesSection:SetHidden(true)
  ZO_CharacterWeaponsSection:SetHidden(true)

  ResetAnchor(ZO_CharacterEquipmentSlotsHead,       TOPLEFT, ZO_CharacterTitle,              BOTTOMLEFT,   0,  10)

  ResetAnchor(ZO_CharacterEquipmentSlotsShoulder,   TOPLEFT, ZO_CharacterEquipmentSlotsHead,        BOTTOMLEFT, 0, 10)
  ResetAnchor(ZO_CharacterEquipmentSlotsGlove,      TOPLEFT, ZO_CharacterEquipmentSlotsShoulder,        BOTTOMLEFT, 0, 10)
  ResetAnchor(ZO_CharacterEquipmentSlotsLeg,        TOPLEFT, ZO_CharacterEquipmentSlotsGlove,        BOTTOMLEFT, 0, 10)

  ResetAnchor(ZO_CharacterEquipmentSlotsChest,      TOPLEFT, ZO_CharacterEquipmentSlotsShoulder,        TOPRIGHT, 10, 0)
  ResetAnchor(ZO_CharacterEquipmentSlotsBelt,       TOPLEFT, ZO_CharacterEquipmentSlotsGlove,        TOPRIGHT, 10, 0)
  ResetAnchor(ZO_CharacterEquipmentSlotsFoot,       TOPLEFT, ZO_CharacterEquipmentSlotsLeg,        TOPRIGHT, 10, 0)

  ResetAnchor(ZO_CharacterEquipmentSlotsCostume,    TOPLEFT, ZO_CharacterEquipmentSlotsHead,        TOPRIGHT, 10, 0)

  ResetAnchor(ZO_CharacterEquipmentSlotsNeck,       TOPLEFT, ZO_CharacterEquipmentSlotsChest,        TOPRIGHT, 10, 0)
  ResetAnchor(ZO_CharacterEquipmentSlotsRing1,      TOPLEFT, ZO_CharacterEquipmentSlotsBelt,        TOPRIGHT, 10, 0)
  ResetAnchor(ZO_CharacterEquipmentSlotsRing2,      TOPLEFT, ZO_CharacterEquipmentSlotsFoot,        TOPRIGHT, 10, 0)

  ResetAnchor(ZO_CharacterEquipmentSlotsMainHand,   TOPLEFT, ZO_CharacterEquipmentSlotsLeg,        BOTTOMLEFT, 0, 10)
  -- ResetAnchor(ZO_CharacterEquipmentSlotsOffHand,    TOPLEFT, ZO_CharacterTitle,        nil, nil, nil)
  -- ResetAnchor(ZO_CharacterEquipmentSlotsBackupMain, TOPLEFT, ZO_CharacterTitle,        nil, nil, nil)
  -- ResetAnchor(ZO_CharacterEquipmentSlotsBackupOff,  TOPLEFT, ZO_CharacterTitle,        nil, nil, nil)
  --
  -- ResetAnchor(ZO_CharacterWeaponSwap,               TOPLEFT, ZO_CharacterTitle,        nil, nil, nil)
end

EVENT_MANAGER:RegisterForEvent("CompactPaperDoll", EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
  if (addOnName == "CompactPaperDoll") then
    CompactPaperDoll()
    EVENT_MANAGER:UnregisterForEvent("CompactPaperDoll", EVENT_ADD_ON_LOADED)
  end
end)
