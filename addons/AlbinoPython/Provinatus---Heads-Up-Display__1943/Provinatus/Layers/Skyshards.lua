ProvinatusSkyshards = ZO_Object:Subclass()

local UnknownTexture = "EsoUI/Art/MapPins/skyshard_seen.dds"
local KnownTexture = "EsoUI/Art/MapPins/skyshard_complete.dds"

function ProvinatusSkyshards:New(...)
  self.Vars = Provinatus.SavedVars.Skyshards
  return ZO_Object.New(self)
end

function ProvinatusSkyshards:Update()
  local Skyshards = {}
  if (self.Vars.Enabled) then
    local ZoneId = GetZoneId(GetUnitZoneIndex("player"))
    for i = 1, GetNumSkyshardsInZone(ZoneId) do
      local ShardId = GetZoneSkyshardId(ZoneId, i)
      local X, Y, _OnCurrentMap = GetNormalizedPositionForSkyshardId(ShardId)
      if X >= 0 and X <= 1 and Y >= 0 and Y <= 1 then
        local Element = {X = X, Y = Y}
        local Status = GetSkyshardDiscoveryStatus(ShardId)
        local IsAcquired = Status == SKYSHARD_DISCOVERY_STATUS_ACQUIRED
        if IsAcquired and self.Vars.ShowCollected then
          Element.Alpha = self.Vars.Collected.Alpha
          Element.Size = self.Vars.Collected.Size
          Element.Texture = KnownTexture
        elseif not IsAcquired then
          Element.Alpha = self.Vars.Uncollected.Alpha
          Element.Size = self.Vars.Uncollected.Size
          Element.Texture = UnknownTexture
        end

        if Element.Alpha then
          table.insert(Skyshards, Element)
        end
      end
    end
  end

  Provinatus:DrawElements(self, Skyshards)
end

function ProvinatusSkyshards:GetMenu()
  return {
    type = "submenu",
    name = "Skyshards",
    reference = "ProvinatusSkyshard",
    icon = KnownTexture,
    controls = {
      [1] = {
        type = "checkbox",
        name = PROVINATUS_ENABLE_SKYSHARDS,
        getFunc = function()
          return self.Vars.Enabled
        end,
        setFunc = function(value)
          self.CurrentZone = nil
          self.Vars.Enabled = value
        end,
        tooltip = function()
          return PROVINATUS_ENABLE_SKYSHARDS_TT
        end,
        width = "full",
        default = ProvinatusConfig.Skyshards.Enabled
      },
      [2] = {
        type = "submenu",
        name = PROVINATUS_UNDISCOVERED,
        disabled = function()
          return not self.Vars.Enabled
        end,
        controls = {
          [1] = {
            type = "slider",
            name = PROVINATUS_ICON_SIZE,
            getFunc = function()
              return self.Vars.Uncollected.Size
            end,
            setFunc = function(value)
              self.Vars.Uncollected.Size = value
            end,
            min = 20,
            max = 150,
            step = 1,
            clampInput = true,
            decimals = 0,
            autoSelect = true,
            inputLocation = "below",
            tooltip = PROVINATUS_ICON_SIZE_TT,
            width = "half",
            default = ProvinatusConfig.Skyshards.Uncollected.Size
          },
          [2] = {
            type = "slider",
            name = PROVINATUS_TRANSPARENCY,
            getFunc = function()
              return self.Vars.Uncollected.Alpha * 100
            end,
            setFunc = function(value)
              self.Vars.Uncollected.Alpha = value / 100
            end,
            min = 0,
            max = 100,
            step = 1,
            clampInput = true,
            decimals = 0,
            autoSelect = true,
            inputLocation = "below",
            tooltip = PROVINATUS_TRANSPARENCY_TT,
            width = "half",
            default = ProvinatusConfig.Skyshards.Uncollected.Alpha * 100
          }
        }
      },
      [3] = {
        type = "submenu",
        name = PROVINATUS_DISCOVERED,
        disabled = function()
          return not self.Vars.Enabled
        end,
        controls = {
          [1] = {
            type = "checkbox",
            name = PROVINATUS_SHOW_DISCOVERED,
            getFunc = function()
              return self.Vars.ShowCollected
            end,
            setFunc = function(value)
              self.Vars.ShowCollected = value
            end,
            tooltip = PROVINATUS_SHOW_DISCOVERED_TT,
            width = "full",
            default = ProvinatusConfig.Skyshards.ShowCollected
          },
          [2] = {
            type = "slider",
            name = PROVINATUS_ICON_SIZE,
            getFunc = function()
              return self.Vars.Collected.Size
            end,
            setFunc = function(value)
              self.Vars.Collected.Size = value
            end,
            min = 20,
            max = 150,
            step = 1,
            clampInput = true,
            decimals = 0,
            autoSelect = true,
            inputLocation = "below",
            tooltip = PROVINATUS_ICON_SIZE_TT,
            width = "half",
            default = ProvinatusConfig.Skyshards.Collected.Size
          },
          [3] = {
            type = "slider",
            name = PROVINATUS_TRANSPARENCY,
            getFunc = function()
              return self.Vars.Collected.Alpha * 100
            end,
            setFunc = function(value)
              self.Vars.Collected.Alpha = value / 100
            end,
            min = 0,
            max = 100,
            step = 1,
            clampInput = true,
            decimals = 0,
            autoSelect = true,
            inputLocation = "below",
            tooltip = PROVINATUS_TRANSPARENCY_TT,
            width = "half",
            default = ProvinatusConfig.Skyshards.Collected.Alpha * 100
          }
        }
      }
    }
  }
end
