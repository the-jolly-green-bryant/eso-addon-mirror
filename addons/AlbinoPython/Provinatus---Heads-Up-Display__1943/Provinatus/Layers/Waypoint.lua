ProvinatusWaypoint = ZO_Object:Subclass()

function ProvinatusWaypoint:New(...)
  self.Vars = Provinatus.SavedVars.Waypoint
  self.Texture = "esoui/art/compass/compass_waypoint.dds"
  Provinatus.PinIterator:AddPinTypeHandler(
    MAP_PIN_TYPE_PLAYER_WAYPOINT,
    function(Data)
      return self:UpdateWaypoint(Data)
    end
  )
  return ZO_Object.New(self)
end

function ProvinatusWaypoint:UpdateWaypoint(Data)
  if self.Vars.Enabled then
    return {
      X = Data.normalizedX,
      Y = Data.normalizedY,
      Alpha = self.Vars.Alpha,
      Texture = self.Texture,
      Size = self.Vars.Size
    }
  end
end

function ProvinatusWaypoint:GetMenu()
  local controls =
    ProvinatusMenu.GetIconSettingsMenu(
    PROVINATUS_WAYPOINT_SETTINGS,
    function()
      return Provinatus.SavedVars.Waypoint.Size
    end,
    function(value)
      Provinatus.SavedVars.Waypoint.Size = value
    end,
    function()
      return Provinatus.SavedVars.Waypoint.Alpha * 100
    end,
    function(value)
      Provinatus.SavedVars.Waypoint.Alpha = value / 100
    end,
    ProvinatusConfig.Waypoint.Size,
    ProvinatusConfig.Waypoint.Alpha * 100,
    function()
      return not Provinatus.SavedVars.Waypoint.Enabled
    end
  )

  table.insert(
    controls,
    1,
    {
      type = "checkbox",
      name = PROVINATUS_ENABLE,
      getFunc = function()
        return Provinatus.SavedVars.Waypoint.Enabled
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Waypoint.Enabled = value
      end,
      tooltip = PROVINATUS_WAYPOINT_TT,
      width = "full",
      default = ProvinatusConfig.Waypoint.Enabled
    }
  )

  return {
    type = "submenu",
    name = PROVINATUS_WAYPOINT,
    icon = self.Texture,
    reference = "ProvinatusWaypointMenu",
    controls = controls
  }
end
