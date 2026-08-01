function InventorySpaceWarning.InitSavedVars()
  local constants = InventorySpaceWarning.Constants

  InventorySpaceWarning.savedVariables =
    ZO_SavedVars:NewCharacterIdSettings("InventorySpaceWarningSavedVariables", 1, nil, {})

  local savedVariables = InventorySpaceWarning.savedVariables

  if savedVariables.spaceLimit == nil then
    savedVariables.spaceLimit = constants.spaceLimit
  end
  if savedVariables.iconSize == nil then
    savedVariables.iconSize = constants.iconSize
  end
  if savedVariables.labelVisibility == nil then
    savedVariables.labelVisibility = true
  end
  if savedVariables.alwaysShow == nil then
      savedVariables.alwaysShow = true
  end
  if savedVariables.icon == nil then
    savedVariables.icon = constants.icon
  end
end
