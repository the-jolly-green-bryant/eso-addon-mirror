local logger = InventorySpaceWarning.logger

function InventorySpaceWarning.OnIndicatorMoveStop()
  local savedVariables = InventorySpaceWarning.savedVariables
  savedVariables.left = InventorySpaceIndicator:GetLeft()
  savedVariables.top = InventorySpaceIndicator:GetTop()
end

local function _updateVisibility()
  if (InventorySpaceWarning.freeSlots > InventorySpaceWarning.savedVariables.spaceLimit) then
    InventorySpaceIndicator:SetHidden(not InventorySpaceWarning.showingHud or
      not InventorySpaceWarning.savedVariables.alwaysShow)

    InventorySpaceIndicatorIcon:SetColor(0.7, 0.7, 0.7, 1)
  else
    InventorySpaceIndicator:SetHidden(not InventorySpaceWarning.showingHud)
    InventorySpaceIndicatorIcon:SetColor(1, 0, 0, 1)
  end
end

function InventorySpaceWarning.CheckFreeSlots()
  InventorySpaceWarning.freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)

  logger:Debug("Free backpack slots count: %d", InventorySpaceWarning.freeSlots)
  InventorySpaceIndicatorLabel:SetText(InventorySpaceWarning.freeSlots)
  _updateVisibility()
end

local function _onInventoryChanged(_eventCode, _bagId, slotIndex, _isNewItem, _itemSoundCategory,
                                   updateReason, _stackCountChange)
  logger:Debug("Inventory changed. slotIndex: %s, updateReason: %s", slotIndex, updateReason)
  InventorySpaceWarning.CheckFreeSlots()
end

local function _restoreSavedPosition()
  local savedVariables = InventorySpaceWarning.savedVariables
  local left = savedVariables.left
  local top = savedVariables.top

  -- Checking if we have saved positions.
  if (left and top) then
    InventorySpaceIndicator:ClearAnchors()
    InventorySpaceIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  end
end

local function _restoreIconSize()
  local savedVariables = InventorySpaceWarning.savedVariables
  local size = savedVariables.iconSize
  InventorySpaceIndicatorIcon:SetDimensions(size, size)
end

local function _restoreIcon()
  local savedVariables = InventorySpaceWarning.savedVariables
  local icon = InventorySpaceWarning.Constants.iconsValues[savedVariables.icon]
  InventorySpaceIndicatorIcon:SetTexture(icon)
end

local function _restoreLabelVisibility()
  local savedVariables = InventorySpaceWarning.savedVariables
  local visible = savedVariables.labelVisibility
  InventorySpaceIndicatorLabel:SetHidden(not visible)
end

local function _onfragmentChange(_, newState)
  logger:Debug("HUD Visibility changed: %s", newState)
  if (newState == SCENE_FRAGMENT_SHOWN) then
    InventorySpaceWarning.showingHud = true
    _updateVisibility()
  elseif (newState == SCENE_FRAGMENT_HIDDEN) then
    InventorySpaceWarning.showingHud = false
    _updateVisibility()
  end
end

local function _registerUpdateEvents()
  EVENT_MANAGER:RegisterForEvent(
    InventorySpaceWarning.name,
    EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    _onInventoryChanged
  )
  EVENT_MANAGER:AddFilterForEvent(
    InventorySpaceWarning.name,
    EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
    REGISTER_FILTER_BAG_ID,
    BAG_BACKPACK
  )

  EVENT_MANAGER:RegisterForEvent(
    InventorySpaceWarning.name,
    EVENT_INVENTORY_BAG_CAPACITY_CHANGED,
    _onInventoryChanged
  )
end

function InventorySpaceWarning.Initialize()
  _registerUpdateEvents()

  InventorySpaceWarning.InitSavedVars()
  InventorySpaceWarning.InitializeSettings()

  _restoreSavedPosition()
  _restoreIconSize()
  _restoreIcon()
  _restoreLabelVisibility()

  local fragment = HUD_FRAGMENT
  fragment:RegisterCallback("StateChange", _onfragmentChange)

  InventorySpaceWarning.showingHud = fragment:IsShowing()
  InventorySpaceWarning.CheckFreeSlots()
end

-- BEGIN: Callbacks for settings
function InventorySpaceWarning.UpdateLabelVisibility(visible)
  local savedVariables = InventorySpaceWarning.savedVariables
  savedVariables.labelVisibility = visible
  _restoreLabelVisibility()
end

function InventorySpaceWarning.UpdateAlwaysShowState(visible)
    local savedVariables = InventorySpaceWarning.savedVariables
    savedVariables.alwaysShow = visible
end

function InventorySpaceWarning.UpdateSpaceLimit(value)
  local savedVariables = InventorySpaceWarning.savedVariables
  savedVariables.spaceLimit = value
  _updateVisibility()
end

function InventorySpaceWarning.UpdateIconSize(value)
  local savedVariables = InventorySpaceWarning.savedVariables
  savedVariables.iconSize = value
  _restoreIconSize()
end

function InventorySpaceWarning.UpdateIcon(value)
  local savedVariables = InventorySpaceWarning.savedVariables
  savedVariables.icon = value
  _restoreIcon()
end

-- BEGIN: end
