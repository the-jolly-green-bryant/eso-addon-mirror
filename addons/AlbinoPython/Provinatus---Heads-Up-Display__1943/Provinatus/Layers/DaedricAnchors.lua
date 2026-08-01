ProvinatusDaedricAnchors = ZO_Object:Subclass()

local PinData = ZO_MapPin.PIN_DATA[MAP_PIN_TYPE_WORLD_EVENT_POI_ACTIVE]

local function ApplyAnimation(Element, Icon)
  if not Icon.Animation then
    local AnimationControl = WINDOW_MANAGER:CreateControl(nil, Icon, CT_TEXTURE)
    AnimationControl:SetTexture("EsoUI/Art/MapPins/worldEvent_poi_active_complete.dds")
    AnimationControl:SetDimensions(Icon:GetDimensions())
    AnimationControl:SetAlpha(Icon:GetAlpha())
    AnimationControl:SetDrawLayer(1)
    Icon:SetDrawLayer(2)
    local Animation, Timeline = CreateSimpleAnimation(ANIMATION_TEXTURE, AnimationControl)
    Animation:SetImageData(PinData.framesWide, PinData.framesHigh)
    Animation:SetFramerate(PinData.framesPerSecond)
    Timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
    Timeline:PlayFromStart()
    Icon.AnimationControl = AnimationControl
    Icon.Animation = Animation
    Icon.Timeline = Timeline
  end

  Icon.AnimationControl:SetAnchor(
    CENTER,
    Provinatus.TopLevelWindow,
    CENTER,
    Element.Projection.XProjected,
    Element.Projection.YProjected
  )
end

function ProvinatusDaedricAnchors:New(...)
  self.Vars = Provinatus.SavedVars.DaedricAnchors
  Provinatus.PinIterator:AddPinTypeHandler(
    MAP_PIN_TYPE_WORLD_EVENT_POI_ACTIVE,
    function(Data)
      return self:ActiveAnchor(Data)
    end
  )

  EVENT_MANAGER:RegisterForEvent(
    ProvinatusConfig.Name,
    EVENT_WORLD_EVENT_ACTIVATED,
    function(EventCode, worldEventInstanceId)
      ZO_WorldMap_RefreshWorldEvent(worldEventInstanceId)
    end
  )

  Provinatus.PinIterator:AddPostProcessor(MAP_PIN_TYPE_WORLD_EVENT_POI_ACTIVE, ApplyAnimation)
  return ZO_Object.New(self)
end

function ProvinatusDaedricAnchors:ActiveAnchor(Data)
  if self.Vars.Enabled then
    return {
      X = Data.normalizedX,
      Y = Data.normalizedY,
      Size = self.Vars.Size,
      Alpha = self.Vars.Alpha,
      Texture = "/esoui/art/icons/poi/poi_portal_complete.dds",
      PinTag = Data.m_PinTag
    }
  end
end

function ProvinatusDaedricAnchors:GetMenu()
  local function getSize()
    return self.Vars.Size
  end

  local function setSize(value)
    self.Vars.Size = value
  end

  local function getAlpha()
    return self.Vars.Alpha * 100
  end

  local function setAlpha(value)
    self.Vars.Alpha = value / 100
  end

  local Controls = {
    {
      type = "checkbox",
      name = PROVINATUS_ENABLE,
      getFunc = function()
        return self.Vars.Enabled
      end,
      setFunc = function(value)
        self.Vars.Enabled = value
      end,
      width = "full",
      default = ProvinatusConfig.DaedricAnchors.Enabled,
      disabled = DisableLayer
    },
    {
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
      default = ProvinatusConfig.DaedricAnchors.Size,
      disabled = DisableLayer
    },
    {
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
      default = ProvinatusConfig.DaedricAnchors.Alpha * 100,
      disabled = DisableLayer
    }
  }

  return {
    type = "submenu",
    name = "Daedric Anchors",
    reference = "ProvinatusLayerMenu",
    controls = Controls,
    icon = "/esoui/art/icons/poi/poi_portal_complete.dds"
  }
end
