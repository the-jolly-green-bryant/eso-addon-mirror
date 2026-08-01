ProvinatusHarvensPins = ZO_Object:Subclass()

function ProvinatusHarvensPins:New(...)
  if HarvensCustomMapPins ~= nill then
    self.Vars = Provinatus.SavedVars.HarvensPins
    self.Texture = "HarvensCustomMapPins/pinflag.dds"
    Provinatus.PinIterator:AddPinTypeHandler(
      HarvensCustomMapPins.pinTypeId,
      function(Data)
        return self:UpdatePin(Data)
      end
    )

    Provinatus.PinIterator:AddPostProcessor(
      HarvensCustomMapPins.pinTypeId, 
      function (Element, Icon) 
        self:ApplyTint(Element, Icon)
      end
    )
  end

  return ZO_Object.New(self)
end

function ProvinatusHarvensPins:UpdatePin(Data)
  if self.Vars.Enabled then
    return {
      X = Data.normalizedX,
      Y = Data.normalizedY,
      Alpha = self.Vars.Alpha,
      Texture = ZO_MapPin.PIN_DATA[Data.m_PinType].texture(Data),
      Tint = ZO_MapPin.PIN_DATA[Data.m_PinType].tint(Data),
      Size = self.Vars.Size,
      Data = Data
    }
  end
end

function ProvinatusHarvensPins:ApplyTint(Element, Icon)
  local Tint = Element.Tint
  Icon:SetColor(Tint.r, Tint.g, Tint.b, self.Vars.Alpha)
end

function ProvinatusHarvensPins:GetMenu()
  local controls =
    ProvinatusMenu.GetIconSettingsMenu(
    PROVINATUS_HARVENS_PINS,
    function()
      return Provinatus.SavedVars.HarvensPins.Size
    end,
    function(value)
      Provinatus.SavedVars.HarvensPins.Size = value
    end,
    function()
      return Provinatus.SavedVars.HarvensPins.Alpha * 100
    end,
    function(value)
      Provinatus.SavedVars.HarvensPins.Alpha = value / 100
    end,
    ProvinatusConfig.HarvensPins.Size,
    ProvinatusConfig.HarvensPins.Alpha * 100,
    function()
      return not Provinatus.SavedVars.HarvensPins.Enabled
    end
  )

  table.insert(
    controls,
    1,
    {
      type = "checkbox",
      name = PROVINATUS_ENABLE,
      getFunc = function()
        return Provinatus.SavedVars.HarvensPins.Enabled
      end,
      setFunc = function(value)
        Provinatus.SavedVars.HarvensPins.Enabled = value
      end,
      tooltip = PROVINATUS_WAYPOINT_TT,
      width = "full",
      default = ProvinatusConfig.HarvensPins.Enabled
    }
  )

  return {
    type = "submenu",
    name = PROVINATUS_HARVENS_PINS,
    icon = self.Texture,
    controls = controls,
    disabled = HarvensCustomMapPins == nil
  }
end
