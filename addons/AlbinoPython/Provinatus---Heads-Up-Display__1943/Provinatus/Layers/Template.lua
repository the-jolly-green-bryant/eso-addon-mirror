-- TODO Change the names of _Layer
-- TODO Add default settings in Config.lua
-- TODO Add entry to this file in addon-config.js
-- TODO Initialize an instance of this class in Provinatus.Layers (in Provinatus.lua)
_Layer = ZO_Object:Subclass()

-- Creates a new layer to display on the HUD
function _Layer:New(...)
  return ZO_Object.New(self)
end

-- TODO Optionally initialize.
-- Called after player data is set
function _Layer:Initialize()
end

-- TODO Change the names of Layer in SavedVars
-- Called everytime Provinatus updates.
function _Layer:Update()
  if Provinatus.SavedVars.Layer.Enabled and not DisableLayer then
    local Elements = {}
    -- Create and add Elements
    for Element, Icon in pairs(Provinatus:DrawElements(self, Elements)) do
      -- Optionally post process icon
    end
  end
end

-- Return a submenu with this layer's settings
function _Layer:GetMenu()
  local function getSize()
    return Provinatus.SavedVars.Layer.Size
  end

  local function setSize(value)
    Provinatus.SavedVars.Layer.Size = value
  end

  local function getAlpha()
    return Provinatus.SavedVars.Layer.Alpha * 100
  end

  local function setAlpha(value)
    Provinatus.SavedVars.Layer.Alpha = value / 100
  end

  local Controls = {
    {
      type = "checkbox",
      name = PROVINATUS_ENABLE,
      getFunc = function()
        return Provinatus.SavedVars.Layer.Enabled
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Layer.Enabled = value
      end,
      width = "full",
      tooltip = PROVINATUS_LAYER_ENABLE_TT,
      default = ProvinatusConfig.Layer.Enabled,
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
      default = ProvinatusConfig.Layer.Size,
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
      default = ProvinatusConfig.Layer.Alpha * 100,
      disabled = DisableLayer
    }
  }

  -- TODO Change PROVINATUS_LAYER
  -- TODO Change PROVINATUS_LAYER_TT
  -- TODO Change ProvinatusLayerMenu
  -- TODO Change Icon
  return {
    type = "submenu",
    name = PROVINATUS_LAYER,
    tooltip = PROVINATUS_LAYER_TT,
    reference = "ProvinatusLayerMenu",
    controls = Controls,
    icon = "/esoui/art/icons/poi/poi_groupboss_incomplete.dds"
  }
end

-- TODO Optionally update any icon
-- Called after the menu panel has been created
function _Layer:SetMenuIcon()
  ProvinatusMenu.DrawMenuIcon(ProvinatusLayerMenu.arrow, "/esoui/art/icons/poi/poi_groupboss_complete.dds")
end
