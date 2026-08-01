ProvinatusPlayerOrientation = ZO_Object:Subclass()

local Texture = "/esoui/art/icons/mapkey/mapkey_player.dds"

function ProvinatusPlayerOrientation:Update()
  local Elements = {}
  local Element = {
    X = Provinatus.X,
    Y = Provinatus.Y,
    Alpha = Provinatus.SavedVars.MyIcon.Alpha,
    Texture = Texture,
    Width = Provinatus.SavedVars.MyIcon.Size,
    Height = Provinatus.SavedVars.MyIcon.Size
  }
  if Provinatus.SavedVars.MyIcon.Enabled then
    table.insert(Elements, Element)
  end

  local RenderedElements = Provinatus:DrawElements(self, Elements)
  if RenderedElements[Element] then
    RenderedElements[Element]:SetTextureRotation(Provinatus.Heading - GetPlayerCameraHeading())
  end
end

function ProvinatusPlayerOrientation:GetMenu()
  return {
    type = "submenu",
    name = PROVINATUS_MY_ICON,
    reference = "ProvinatusMyIconMenu",
    icon = Texture,
    controls = {
      [1] = {
        type = "checkbox",
        name = PROVINATUS_MY_ICON_SHOW,
        getFunc = function()
          return Provinatus.SavedVars.MyIcon.Enabled
        end,
        setFunc = function(value)
          Provinatus.SavedVars.MyIcon.Enabled = value
        end,
        tooltip = PROVINATUS_MY_ICON_SHOW_TT,
        width = "full",
        default = ProvinatusConfig.MyIcon.Enabled
      },
      [2] = {
        type = "submenu",
        name = PROVINATUS_ICON_SETTINGS,
        controls = ProvinatusMenu.GetIconSettingsMenu(
          "",
          function()
            return Provinatus.SavedVars.MyIcon.Size
          end,
          function(value)
            Provinatus.SavedVars.MyIcon.Size = value
          end,
          function()
            return Provinatus.SavedVars.MyIcon.Alpha * 100
          end,
          function(value)
            Provinatus.SavedVars.MyIcon.Alpha = value / 100
          end,
          ProvinatusConfig.MyIcon.Size,
          ProvinatusConfig.MyIcon.Alpha * 100,
          function()
            return not Provinatus.SavedVars.MyIcon.Enabled
          end
        )
      }
    }
  }
end
