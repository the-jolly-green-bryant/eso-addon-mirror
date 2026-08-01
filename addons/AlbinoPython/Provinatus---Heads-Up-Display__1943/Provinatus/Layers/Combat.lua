ProvinatusCombat = ZO_Object:Subclass()

local Texture = "esoui/art/reticle/reticle-groundtarget.dds"

local function CreateElement()
  return {}
end

function ProvinatusCombat:New(...)
  EVENT_MANAGER:RegisterForEvent(
    "ProvinatusCombat",
    EVENT_PLAYER_COMBAT_STATE,
    function(_, InCombat)
      self:PlayerCombatState(InCombat)
    end
  )
  return ZO_Object.New(self)
end

function ProvinatusCombat:PlayerCombatState(InCombat)
  self.InCombat = InCombat
end

function ProvinatusCombat:Update()
  local Elements = {}
  if Provinatus.SavedVars.Combat.Enabled then
    if self.InCombat then
      table.insert(
        Elements,
        {
          X = Provinatus.X,
          Y = Provinatus.Y,
          Height = Provinatus.SavedVars.Combat.Size,
          Width = Provinatus.SavedVars.Combat.Size,
          Alpha = Provinatus.SavedVars.Combat.Alpha,
          Texture = Texture
        }
      )
    end

    for _, Icon in pairs(Provinatus:DrawElements(self, Elements)) do
      Icon:SetColor(1, 0, 0, Provinatus.SavedVars.Combat.Alpha)
    end
  end
end

function ProvinatusCombat:GetMenu()
  local function getSize()
    return Provinatus.SavedVars.Combat.Size
  end

  local function setSize(value)
    Provinatus.SavedVars.Combat.Size = value
  end

  local function getAlpha()
    return Provinatus.SavedVars.Combat.Alpha * 100
  end

  local function setAlpha(value)
    Provinatus.SavedVars.Combat.Alpha = value / 100
  end

  local Controls = {
    {
      type = "checkbox",
      name = PROVINATUS_ENABLE,
      getFunc = function()
        return Provinatus.SavedVars.Combat.Enabled
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Combat.Enabled = value
      end,
      width = "full",
      tooltip = PROVINATUS_LAYER_ENABLE_TT,
      default = ProvinatusConfig.Combat.Enabled
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
      default = ProvinatusConfig.Combat.Size
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
      default = ProvinatusConfig.Combat.Alpha * 100
    }
  }

  return {
    type = "submenu",
    name = PROVINATUS_COMBAT,
    tooltip = PROVINATUS_COMBAT_TT,
    icon = Texture,
    reference = "ProvinatusCombatMenu",
    controls = Controls
  }
end

function ProvinatusCombat:SetMenuIcon()
  ProvinatusCombatMenu.icon:SetColor(1, 0, 0, 1)
end
