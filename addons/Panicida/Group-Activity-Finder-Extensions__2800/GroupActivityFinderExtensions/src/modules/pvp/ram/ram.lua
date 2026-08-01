-- =============================================================================
-- Localized Globals
-- =============================================================================
local ZO_Object = ZO_Object
local ZO_StatusBar_SetGradientColor = ZO_StatusBar_SetGradientColor
local ZO_POWER_BAR_GRADIENT_COLORS = ZO_POWER_BAR_GRADIENT_COLORS
local CreateControlFromVirtual = CreateControlFromVirtual
local zo_strformat = zo_strformat
local GetRawUnitName = GetRawUnitName
local GetNumPlayersEscortingRam = GetNumPlayersEscortingRam
local GetMinMaxRamEscorts = GetMinMaxRamEscorts
local IsPlayerEscortingRam = IsPlayerEscortingRam
local TOPLEFT = TOPLEFT
local TOPRIGHT = TOPRIGHT
local COMBAT_MECHANIC_FLAGS_HEALTH = COMBAT_MECHANIC_FLAGS_HEALTH
local EVENT_RAM_ESCORT_COUNT_UPDATE = EVENT_RAM_ESCORT_COUNT_UPDATE
local EVENT_LEAVE_RAM_ESCORT = EVENT_LEAVE_RAM_ESCORT
local SI_SIEGE_BAR_NAME = SI_SIEGE_BAR_NAME

local GAFE = GroupActivityFinderExtensions

-- =============================================================================
-- Constants
-- =============================================================================
local MAX_ESCORTS_SHOWN = 6
local MIN_MET_TEXTURE = "EsoUI/Art/AvA/AvA_ram_slot_green.dds"
local MIN_NOT_MET_TEXTURE = "EsoUI/Art/AvA/AvA_ram_slot_red.dds"
local SPOT_NOT_FILLED_TEXTURE = "EsoUI/Art/AvA/AvA_ram_slot_empty.dds"

-- =============================================================================
-- Module Declaration
-- =============================================================================
local Ram = ZO_Object:Subclass()

-- =============================================================================
-- Private Functions
-- =============================================================================

--- Creates and positions the escort indicator controls.
--- @param self table The Ram instance
local function createIndicatorControls(self)
  local prevControl
  for i = 1, MAX_ESCORTS_SHOWN do
    local currentControl = CreateControlFromVirtual(
      "GAFE_RamIndicators",
      self.indicatorsControl,
      "ZO_RamIndicator",
      i
    )
    self.indicatorsList[i] = currentControl
    if prevControl then
      currentControl:SetAnchor(TOPLEFT, prevControl, TOPRIGHT)
    else
      currentControl:SetAnchor(TOPLEFT, nil, TOPLEFT)
    end
    prevControl = currentControl
  end
end

--- Event handler for ram escort count updates.
--- @param self table The Ram instance
--- @param eventCode number The event code
--- @param numEscorts number The current number of escorts
local function onRamEscortCountUpdate(self, eventCode, numEscorts)
  self:UpdateRam(numEscorts)
end

--- Event handler for leaving ram escort.
--- @param self table The Ram instance
local function onLeaveRamEscort(self)
  self.isInitialized = false
  self:UpdateVisibility()
end

-- =============================================================================
-- Public Functions
-- =============================================================================

--- Creates a new Ram instance.
--- @param control any The UI control element
--- @return table The new Ram instance
function Ram:New(control)
  local object = ZO_Object.New(self)
  object:Initialize(control)
  return object
end

--- Initializes the Ram instance with the given control.
--- @param control any The UI control element
function Ram:Initialize(control)
  self.control = control
  self.name = control:GetNamedChild("Name")
  self.indicatorsControl = control:GetNamedChild("Indicators")
  self.indicatorsList = {}

  createIndicatorControls(self)

  ZO_StatusBar_SetGradientColor(
    ZO_RamHealth,
    ZO_POWER_BAR_GRADIENT_COLORS[COMBAT_MECHANIC_FLAGS_HEALTH]
  )

  control:RegisterForEvent(EVENT_RAM_ESCORT_COUNT_UPDATE,
    function(eventCode, numEscorts)
      onRamEscortCountUpdate(self, eventCode, numEscorts)
    end)
  control:RegisterForEvent(EVENT_LEAVE_RAM_ESCORT, function()
    onLeaveRamEscort(self)
  end)

  self:UpdateRam()
end

--- Updates the ram display with the current escort count.
--- @param numEscorts number|nil The number of escorts (optional, fetched if nil)
function Ram:UpdateRam(numEscorts)
  if not self.isInitialized then
    self.name:SetText(zo_strformat(
      SI_SIEGE_BAR_NAME,
      GetRawUnitName("escortedram")
    ))
    self.isInitialized = true
  end

  self:UpdateNumEscorts(numEscorts or GetNumPlayersEscortingRam())
  self:UpdateVisibility()
end

--- Updates the escort indicator visuals based on current count.
--- @param numEscorts number The current number of escorts
function Ram:UpdateNumEscorts(numEscorts)
  local minRequiredEscorts, maxPossibleEscorts = GetMinMaxRamEscorts()
  local spotFilledTexture = (numEscorts >= minRequiredEscorts) and
      MIN_MET_TEXTURE or MIN_NOT_MET_TEXTURE

  for i = 1, MAX_ESCORTS_SHOWN do
    local control = self.indicatorsList[i]
    if i <= maxPossibleEscorts then
      control:SetHidden(false)
      if i <= numEscorts then
        control:SetTexture(spotFilledTexture)
      else
        control:SetTexture(SPOT_NOT_FILLED_TEXTURE)
      end
    else
      control:SetHidden(true)
    end
  end
end

--- Updates the visibility of the ram control based on escort status.
function Ram:UpdateVisibility()
  self.control:SetHidden(not IsPlayerEscortingRam())
end

--- Initializes the GAFE Ram module from XML.
--- @param control any The UI control element from XML
function GAFE_Ram_Initialize(control)
  if GAFE.SavedVars.beta then
    GAFE.Ram = Ram:New(control)
  end
end
