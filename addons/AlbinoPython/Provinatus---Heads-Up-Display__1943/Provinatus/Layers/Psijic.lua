ProvinatusPsijic = ZO_Object:Subclass()

local Texture = "/esoui/art/icons/rep_psijic_64.dds"

local function CreateElement()
  return {}
end

function ProvinatusPsijic:New(...)
  return ZO_Object.New(self)
end

function ProvinatusPsijic:Update()
  if Provinatus.SavedVars.Psijic.Enabled then
    local Elements = {}
    if Provinatus.SavedVars.Psijic.Enabled and ProvinatusPsijicPortals[Provinatus.Subzone] then
      for _, Data in pairs(ProvinatusPsijicPortals[Provinatus.Subzone]) do
        local level = GetSkillLineXPInfo(5, 4)
        if Data[3] == level / 10 + 2 then
          table.insert(
            Elements,
            {
              X = Data[1],
              Y = Data[2],
              Texture = Texture,
              Alpha = Provinatus.SavedVars.Psijic.Alpha,
              Height = Provinatus.SavedVars.Psijic.Size / 2,
              Width = Provinatus.SavedVars.Psijic.Size / 2
            }
          )
        end
      end
    end

    Provinatus:DrawElements(self, Elements)
  end
end

function ProvinatusPsijic:GetMenu()
  local function getSize()
    return Provinatus.SavedVars.Psijic.Size
  end

  local function setSize(value)
    Provinatus.SavedVars.Psijic.Size = value
  end

  local function getAlpha()
    return Provinatus.SavedVars.Psijic.Alpha * 100
  end

  local function setAlpha(value)
    Provinatus.SavedVars.Psijic.Alpha = value / 100
  end

  local Controls = {
    {
      type = "checkbox",
      name = PROVINATUS_ENABLE,
      getFunc = function()
        return Provinatus.SavedVars.Psijic.Enabled
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Psijic.Enabled = value
      end,
      width = "full",
      tooltip = PROVINATUS_LAYER_ENABLE_TT,
      default = ProvinatusConfig.Psijic.Enabled
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
      default = ProvinatusConfig.Psijic.Size
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
      default = ProvinatusConfig.Psijic.Alpha * 100
    }
  }

  return {
    type = "submenu",
    name = PROVINATUS_TIMEBREACH,
    reference = "ProvinatusPsijicMenu",
    icon = Texture,
    controls = Controls
  }
end

