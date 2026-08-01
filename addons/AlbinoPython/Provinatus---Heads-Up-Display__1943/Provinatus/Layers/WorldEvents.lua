local function ApplyAnimation(Element, Icon)
  local IsAnimated = Element.IsAnimated
  local IconHasAnimation = Icon.Animation ~= nil
  local AnimationPlaying = IconHasAnimation and Icon.Timeline:IsPlaying()
  if not IsAnimated and AnimationPlaying then
    Icon.Timeline:Stop()
    Icon.Animation:SetImageData(1, 1)
  elseif IsAnimated and IconHasAnimation and not AnimationPlaying then
    Icon.Animation:SetImageData(Element.PinData.framesWide, Element.PinData.framesHigh)
    Icon.Timeline:PlayFromStart()
  elseif IsAnimated and not IconHasAnimation then
    local animation, timeline = CreateSimpleAnimation(ANIMATION_TEXTURE, Icon)
    animation:SetImageData(Element.PinData.framesWide, Element.PinData.framesHigh)
    animation:SetFramerate(Element.PinData.framesPerSecond)
    timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
    timeline:PlayFromStart()
    Icon.Animation = animation
    Icon.Timeline = timeline
  end
end

local function SetColor(UnitTag, Icon)
  local health, maxHealth, effectiveMaxHealth = GetUnitPower(UnitTag, POWERTYPE_HEALTH)
  local ratio = health / maxHealth
  local G = ratio
  local B = ratio
  Icon:SetColor(1, G, B, math.min(Provinatus.SavedVars.WorldEvent.Alpha, Icon:GetAlpha()))
end

ProvinatusWorldEvents = ZO_Object:Subclass()

ProvinatusWorldEvents.WorldEvents = {} -- {[instance id] => {[unit tag] => pin type}}

function ProvinatusWorldEvents:Initialize()
  local function GetNextWorldEventInstanceIdIter(state, var1)
    return GetNextWorldEventInstanceId(var1)
  end

  for worldEventInstanceId in GetNextWorldEventInstanceIdIter do
    self.WorldEvents[worldEventInstanceId] = {}
    for i = 1, GetNumWorldEventInstanceUnits(worldEventInstanceId) do
      local unitTag = GetWorldEventInstanceUnitTag(worldEventInstanceId, i)
      local pinType = GetWorldEventInstanceUnitPinType(worldEventInstanceId, unitTag)
      if unitTag and pinType then
        self.WorldEvents[worldEventInstanceId][unitTag] = pinType
      end
    end
  end

  EVENT_MANAGER:RegisterForEvent(
      ProvinatusConfig.Name, EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE,
      function(_eventCode, worldEventInstanceId, unitTag, _oldPinType_, newPinType)
        if not self.WorldEvents[worldEventInstanceId] then
          self.WorldEvents[worldEventInstanceId] = {}
        end

        self.WorldEvents[worldEventInstanceId][unitTag] = newPinType
      end)

  EVENT_MANAGER:RegisterForEvent(
      ProvinatusConfig.Name, EVENT_WORLD_EVENT_UNIT_DESTROYED,
      function(eventCode, worldEventInstanceId, unitTag)
        self.WorldEvents[worldEventInstanceId][unitTag] = nil
      end)
end

function ProvinatusWorldEvents:Update()
  local elements = {}
  if Provinatus.SavedVars.WorldEvent.Enabled then
    for worldEventInstanceId, tagPinTypes in pairs(self.WorldEvents) do
      for unitTag, pinType in pairs(tagPinTypes) do
        local x, y, heading, onCurrentMap = GetMapPlayerPosition(unitTag)
        if pinType and onCurrentMap then
          local pinData = ZO_MapPin.PIN_DATA[pinType]
          local element = {}
          element.X = x
          element.Y = y
          element.Texture = GetWorldEventInstanceUnitPinIcon(worldEventInstanceId, unitTag)
          element.Alpha = Provinatus.SavedVars.WorldEvent.Alpha
          element.PinData = pinData
          element.Height = Provinatus.SavedVars.WorldEvent.Size
          element.Width = Provinatus.SavedVars.WorldEvent.Size
          element.UnitTag = unitTag
          element.IsAnimated = GetIsWorldEventInstanceUnitPinIconAnimated(
              worldEventInstanceId, unitTag)
          table.insert(elements, element)
        end
      end
    end
  end

  local renderedElements = Provinatus:DrawElements(self, elements)
  for element, icon in pairs(renderedElements) do
    ApplyAnimation(element, icon)
    SetColor(element.UnitTag, icon)
  end
end

function ProvinatusWorldEvents:GetMenu()
  local function getSize()
    return Provinatus.SavedVars.WorldEvent.Size
  end
  local function setSize(value)
    Provinatus.SavedVars.WorldEvent.Size = value
  end

  local function getAlpha()
    return Provinatus.SavedVars.WorldEvent.Alpha * 100
  end

  local function setAlpha(value)
    Provinatus.SavedVars.WorldEvent.Alpha = value / 100
  end

  return {
    type = "submenu",
    name = "World Events (Dragons)",
    reference = "ProvinatusWorldEventsMenu",
    icon = "Provinatus/Icons/dragon_fly-2.dds",
    controls = {
      [1] = {
        type = "checkbox",
        name = PROVINATUS_ENABLE,
        getFunc = function()
          return Provinatus.SavedVars.WorldEvent.Enabled
        end,
        setFunc = function(value)
          Provinatus.SavedVars.WorldEvent.Enabled = value
        end,
        tooltip = "Show world events on HUD",
        width = "full",
        default = ProvinatusConfig.WorldEvent.Enabled
      },
      [2] = {
        type = "slider",
        name = PROVINATUS_ICON_SIZE,
        getFunc = getSize,
        setFunc = setSize,
        min = 20,
        max = 150,
        step = 1,
        clampInput = true,
        decimals = 0,
        autoSelect = true,
        inputLocation = "below",
        tooltip = PROVINATUS_ICON_SIZE_TT,
        width = "half",
        default = ProvinatusConfig.WorldEvent.Size
      },
      [3] = {
        type = "slider",
        name = PROVINATUS_TRANSPARENCY,
        getFunc = getAlpha,
        setFunc = setAlpha,
        min = 0,
        max = 100,
        step = 1,
        clampInput = true,
        decimals = 0,
        autoSelect = true,
        inputLocation = "below",
        tooltip = PROVINATUS_TRANSPARENCY_TT,
        width = "half",
        default = ProvinatusConfig.WorldEvent.Alpha * 100
      }
    }
  }
end
