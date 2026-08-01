ProvinatusDropMarker = ZO_Object:Subclass()

local PinTypeString = "ProvDropMarker"

local function GetMarker()
  local Marker = {
    Pin = ZO_WorldMap_GetPinManager():CreatePin(
      _G[PinTypeString],
      {
        X = Provinatus.X,
        Y = Provinatus.Y,
      },
      Provinatus.X,
      Provinatus.Y
    )
  }

  Marker.Add = function()
    if Marker.Next then
      Marker.Next.Add()
    else
      Marker.Next = GetMarker()
    end
  end

  return Marker
end

local MarkerList = ZO_Object:Subclass()

function MarkerList:Add()
  if not self.Head then
    self.Head = GetMarker()
  else
    self.Head.Add()
  end
end

function MarkerList:Remove()
  if self.Head then
    ZO_WorldMap_GetPinManager():RemovePins(PinTypeString, _G[PinTypeString], self.Head.Pin.m_PinTag)
    self.Head = self.Head.Next
  end
end

function MarkerList:RemoveAll()
  while self.Head do
    self:Remove()
  end
end

local Yellow = "/esoui/art/compass/ava_returnpoint_aldmeri.dds"
local Red = "/esoui/art/compass/ava_returnpoint_ebonheart.dds"
local Blue = "/esoui/art/compass/ava_returnpoint_daggerfall.dds"
local White = "/esoui/art/compass/ava_returnpoint_neutral.dds"

function ProvinatusDropMarker:New(...)
  self.Vars = Provinatus.SavedVars.DropMarker
  self.Vars.Texture = self.Vars.Texture or Yellow
  self.MarkerList = MarkerList:New()
  ZO_WorldMap_AddCustomPin(
    PinTypeString,
    function(PinManager)
    end,
    function()
    end,
    {
      texture = function()
        return self.Vars.Texture
      end,
      size = self.Vars.Size,
      level = 1
    }
  )

  self.PinTypeId = _G[PinTypeString]
  ZO_WorldMap_GetPinManager():SetCustomPinEnabled(self.PinTypeId, true)

  Provinatus.PinIterator:AddPinTypeHandler(
    self.PinTypeId,
    function(Data)
      return self:UpdateDropMarker(Data)
    end
  )

  SLASH_COMMANDS["/resetprovmarker"] = function()
    Provinatus.DropMarker:RemoveMarker()
  end

  return ZO_Object.New(self)
end

function ProvinatusDropMarker:UpdateDropMarker(Data)
  return {
    X = Data.normalizedX,
    Y = Data.normalizedY,
    Size = self.Vars.Size,
    Alpha = self.Vars.Alpha,
    Texture = self.Vars.Texture
  }
end

function ProvinatusDropMarker:DropMarker()
  self.MarkerList:Add()
end

function ProvinatusDropMarker:RemoveMarker()
  self.MarkerList:Remove()
end

function ProvinatusDropMarker:RemoveAllMarkers()
  self.MarkerList:RemoveAll()
end

-- Return a submenu with this layer's settings
function ProvinatusDropMarker:GetMenu()
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
      default = ProvinatusConfig.DropMarker.Size,
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
      default = ProvinatusConfig.DropMarker.Alpha * 100,
      disabled = DisableLayer
    },
    {
      type = "dropdown",
      name = PROVINATUS_ICON_COLOR,
      choices = {
        GetString(PROVINATUS_YELLOW),
        GetString(PROVINATUS_BLUE),
        GetString(PROVINATUS_RED),
        GetString(PROVINATUS_WHITE)
      },
      choicesValues = {Yellow, Blue, Red, White},
      getFunc = function()
        return self.Vars.Texture
      end,
      setFunc = function(var)
        self.Vars.Texture = var
      end,
      scrollable = true,
      default = Yellow
    }
  }

  return {
    type = "submenu",
    name = PROVINATUS_DROP_MARKER,
    tooltip = PROVINATUS_DROP_MARKER_TT,
    controls = Controls,
    icon = function()
      return self.Vars.Texture
    end,
    reference = "DropMarkerMenu"
  }
end

-- TODO Add hotkey to point pointer thing to marker
-- TODO use cropped icons
-- function ProvinatusDropMarker:SetMenuIcon()
--   DropMarkerMenu.icon:SetDimensions(40, 40)
-- end
