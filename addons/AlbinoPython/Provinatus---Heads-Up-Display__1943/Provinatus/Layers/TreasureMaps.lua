ProvinatusTreasureMaps = ZO_Object:Subclass()
local Texture = "Provinatus/Icons/Treasure.dds"
local Disabled = not (LibTreasure_GetMapIdData and LOST_TREASURE)

function ProvinatusTreasureMaps:Update()
  if Disabled then
    return
  end

  local Data = LibTreasure_GetMapIdData(GetCurrentMapId())
  if Data then
    local Elements = {}
    for _, PinData in pairs(Data) do
      if LOST_TREASURE.internal.itemCache:IsItemInBagCache(PinData.itemId) and Provinatus.SavedVars.TreasureMaps.Enabled then
        table.insert(
          Elements,
          {
            X = PinData.x,
            Y = PinData.y,
            Alpha = Provinatus.SavedVars.TreasureMaps.Alpha,
            Width = Provinatus.SavedVars.TreasureMaps.Size,
            Height = Provinatus.SavedVars.TreasureMaps.Size,
            Texture = Texture,
            PinData = PinData
          }
        )
      end
    end

    Provinatus:DrawElements(self, Elements)
  end
end

function ProvinatusTreasureMaps:GetMenu()
  return {
    type = "submenu",
    name = PROVINATUS_TREASURE_MAPS,
    reference = "ProvinatusTreasureMapsMenu",
    icon = Texture,
    disabled = Disabled,
    tooltip = function()
      if Disabled then
        return "Must install Lost Treasure to use this"
      end
    end,
    controls = {
      [1] = {
        type = "checkbox",
        name = PROVINATUS_TREASURE_MAPS_ENABLE,
        getFunc = function()
          return Provinatus.SavedVars.TreasureMaps.Enabled
        end,
        setFunc = function(value)
          Provinatus.SavedVars.TreasureMaps.Enabled = value
        end,
        tooltip = function()
          if LOST_TREASURE_DATA == nil then
            return PROVINATUS_TREASURE_MAPS_ENABLE_NO_ADDON
          end
        end,
        width = "full",
        default = ProvinatusConfig.TreasureMaps.Enabled
      },
      [2] = {
        type = "submenu",
        name = PROVINATUS_ICON_SETTINGS,
        controls = ProvinatusMenu.GetIconSettingsMenu(
          "",
          function()
            return Provinatus.SavedVars.TreasureMaps.Size
          end,
          function(value)
            Provinatus.SavedVars.TreasureMaps.Size = value
          end,
          function()
            return Provinatus.SavedVars.TreasureMaps.Alpha * 100
          end,
          function(value)
            Provinatus.SavedVars.TreasureMaps.Alpha = value / 100
          end,
          ProvinatusConfig.TreasureMaps.Size,
          ProvinatusConfig.TreasureMaps.Alpha * 100
        )
      }
    }
  }
end
