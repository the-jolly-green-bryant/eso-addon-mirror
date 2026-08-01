ProvinatusRallyPoint = ZO_Object:Subclass()

local Texture = "esoui/art/mappins/maprallypoint.dds"

local function Animate(Icon)
  local animation, timeline = CreateSimpleAnimation(ANIMATION_TEXTURE, Icon)
  animation:SetImageData(32, 1)
  animation:SetFramerate(60)
  timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
  timeline:PlayFromStart()
  return animation
end

function ProvinatusRallyPoint:Update()
  local Elements = {}
  local RallyX, RallyY = GetMapRallyPoint()
  local Element = {
    X = RallyX,
    Y = RallyY,
    Width = Provinatus.SavedVars.RallyPoint.Size,
    Height = Provinatus.SavedVars.RallyPoint.Size,
    Texture = Texture,
    Alpha = Provinatus.SavedVars.RallyPoint.Alpha
  }

  if (RallyX ~= 0 or RallyY ~= 0) and Provinatus.SavedVars.RallyPoint.Enabled then
    table.insert(Elements, Element)
  end

  local Rendered = Provinatus:DrawElements(self, Elements)
  if Rendered and Rendered[Element] and not self.Animation then
    self.Animation = Animate(Rendered[Element])
  end
end

function ProvinatusRallyPoint:GetMenu()
  return {
    type = "submenu",
    name = PROVINATUS_RALLYPOINT,
    reference = "ProvinatusRallyPointMenu",
    icon = Texture,
    controls = ProvinatusMenu.GetIconSettingsMenu(
      PROVINATUS_RALLYPOINT_SETTINGS,
      function()
        return Provinatus.SavedVars.RallyPoint.Size
      end,
      function(value)
        Provinatus.SavedVars.RallyPoint.Size = value
      end,
      function()
        return Provinatus.SavedVars.RallyPoint.Alpha * 100
      end,
      function(value)
        Provinatus.SavedVars.RallyPoint.Alpha = value / 100
      end,
      ProvinatusConfig.RallyPoint.Size,
      ProvinatusConfig.RallyPoint.Alpha * 100,
      false
    )
  }
end

function ProvinatusRallyPoint:SetMenuIcon()
  Animate(ProvinatusRallyPointMenu.icon)
end
