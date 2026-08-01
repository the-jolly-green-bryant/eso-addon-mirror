local CCP = COMPASS_PINS
local LMP = LibMapPins
local LAM = LibAddonMenu2

local SCRYSPY_MAP_PIN = 1
local SCRYSPY_DIGSITE_PIN = 2

local pin_textures_list = {
  [1] = "Pickaxe-Shovel Red-X (Default)",
  [2] = "Pickaxe-Shovel",
  [3] = "Question Mark",
  [4] = "Glowing Crystal",
  [5] = "Crystal",
  [6] = "Facet",
  [7] = "Tracking Icon",
  [8] = "Eye",
  [9] = "Holy Grail",
  [10] = "Spade",
}

local panelData = {
  type = "panel",
  name = GetString(mod_title),
  displayName = "|cFFFFB0" .. GetString(mod_title) .. "|r",
  author = "Sharlikran",
  version = ScrySpy.addon_version,
  slashCommand = "/scryspy",
  registerForRefresh = true,
  registerForDefaults = true,
  website = ScrySpy.addon_website,
}

local shovel_icon, digsite_icon
local function create_icons(panel)
  if panel == WINDOW_MANAGER:GetControlByName(ScrySpy.addon_name, "_Options") then
    shovel_icon = WINDOW_MANAGER:CreateControl(nil, panel.controlsToRefresh[SCRYSPY_MAP_PIN], CT_TEXTURE)
    shovel_icon:SetAnchor(RIGHT, panel.controlsToRefresh[SCRYSPY_MAP_PIN].combobox, LEFT, -10, 0)
    shovel_icon:SetTexture(ScrySpy.pin_textures[ScrySpy_SavedVars.pin_type])
    shovel_icon:SetDimensions(ScrySpy_SavedVars.digsite_pin_size, ScrySpy_SavedVars.digsite_pin_size)
    digsite_icon = WINDOW_MANAGER:CreateControl(nil, panel.controlsToRefresh[SCRYSPY_DIGSITE_PIN], CT_TEXTURE)
    digsite_icon:SetAnchor(RIGHT, panel.controlsToRefresh[SCRYSPY_DIGSITE_PIN].combobox, LEFT, -10, 0)
    digsite_icon:SetTexture(ScrySpy.pin_textures[ScrySpy_SavedVars.digsite_pin_type])
    digsite_icon:SetDimensions(ScrySpy_SavedVars.digsite_pin_size, ScrySpy_SavedVars.digsite_pin_size)
    CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", create_icons)
  end
end
CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", create_icons)

local optionsData = {}
-- Set Map Pin and Compas Pin texture
optionsData[SCRYSPY_MAP_PIN] = {
  type = "dropdown",
  name = GetString(map_pin_texture_text),
  tooltip = GetString(map_pin_texture_desc),
  choices = pin_textures_list,
  getFunc = function() return pin_textures_list[ScrySpy_SavedVars.pin_type] end,
  setFunc = function(selected)
    for index, name in ipairs(pin_textures_list) do
      if name == selected then
        ScrySpy_SavedVars.pin_type = index
        LMP:SetLayoutKey(ScrySpy.scryspy_map_pin_type, "texture", ScrySpy.pin_textures[index])
        shovel_icon:SetTexture(ScrySpy.pin_textures[index])
        ScrySpy.RefreshPinLayout()
        LMP:RefreshPins(ScrySpy.scryspy_map_pin_type)
        CCP.pinLayouts[ScrySpy.custom_compass_pin_type].texture = ScrySpy.pin_textures[index]
        CCP:RefreshPins(ScrySpy.custom_compass_pin_type)
        break
      end
    end
  end,
  default = pin_textures_list[ScrySpy.scryspy_defaults.pin_type],
}
-- 3D Digsite Icon Texture
optionsData[SCRYSPY_DIGSITE_PIN] = {
  type = "dropdown",
  name = GetString(digsite_texture_text),
  tooltip = GetString(digsite_texture_desc),
  choices = pin_textures_list,
  getFunc = function() return pin_textures_list[ScrySpy_SavedVars.digsite_pin_type] end,
  setFunc = function(selected)
    for index, name in ipairs(pin_textures_list) do
      if name == selected then
        ScrySpy_SavedVars.digsite_pin_type = index
        digsite_icon:SetTexture(ScrySpy.pin_textures[index])
        ScrySpy.Draw3DPins() -- this makes the pins appear when the are normally hidden
        break
      end
    end
  end,
  default = pin_textures_list[ScrySpy.scryspy_defaults.digsite_pin_type],
}
-- Set Map Pin pin size
optionsData[#optionsData + 1] = {
  type = "slider",
  name = GetString(pin_size),
  tooltip = GetString(pin_size_desc),
  min = 20,
  max = 70,
  getFunc = function() return ScrySpy_SavedVars.pin_size end,
  setFunc = function(size)
    ScrySpy_SavedVars.pin_size = size
    shovel_icon:SetDimensions(size, size)
    LMP:SetLayoutKey(ScrySpy.scryspy_map_pin_type, "size", size)
    ScrySpy.RefreshPinLayout()
    LMP:RefreshPins(ScrySpy.scryspy_map_pin_type)
  end,
  default = ScrySpy.scryspy_defaults.pin_size,
}
-- Set Map Pin pin level meaning what takes precedence over other pins
optionsData[#optionsData + 1] = {
  type = "slider",
  name = GetString(pin_layer),
  tooltip = GetString(pin_layer_desc),
  min = 10,
  max = 200,
  step = 5,
  getFunc = function() return ScrySpy_SavedVars.pin_level end,
  setFunc = function(level)
    ScrySpy_SavedVars.pin_level = level
    LMP:SetLayoutKey(ScrySpy.scryspy_map_pin_type, "level", level)
    ScrySpy.RefreshPinLayout()
    LMP:RefreshPins(ScrySpy.scryspy_map_pin_type)
  end,
  default = ScrySpy.scryspy_defaults.pin_level,
}
-- Set the max distance for compas pins to show up
optionsData[#optionsData + 1] = {
  type = "slider",
  name = GetString(compass_max_dist),
  tooltip = GetString(compass_max_dist_desc),
  min = 1,
  max = 100,
  getFunc = function() return ScrySpy_SavedVars.compass_max_distance * 1000 end,
  setFunc = function(maxDistance)
    ScrySpy_SavedVars.compass_max_distance = maxDistance / 1000
    CCP.pinLayouts[ScrySpy.custom_compass_pin_type].maxDistance = maxDistance / 1000
    CCP:RefreshPins(ScrySpy.custom_compass_pin_type)
  end,
  width = "full",
  default = ScrySpy.scryspy_defaults.compass_max_distance * 1000,
}
-- Set color for the 3D Map Pin Spike
optionsData[#optionsData + 1] = {
  type = "colorpicker",
  name = GetString(spike_pincolor),
  tooltip = GetString(spike_pincolor_desc),
  getFunc = function() return unpack(ScrySpy_SavedVars.digsite_spike_color) end,
  setFunc = function(r, g, b, a)
    ScrySpy_SavedVars.digsite_spike_color = ScrySpy.create_color_table(r, g, b, a)
    ScrySpy.Draw3DPins()
  end,
  default = ScrySpy.scryspy_defaults.digsite_spike_color,
}
--[[
-- Show degub messages on or off
optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = GetString(spike_debug),
    tooltip = GetString(spike_debug_desc),
    getFunc = function() return ScrySpy.show_log end,
    setFunc = function(value)
            ScrySpy.show_log = value
        end,
    default = false,
}
]]--

local function OnPlayerActivated(event)
  LAM:RegisterAddonPanel(ScrySpy.addon_name .. "_Options", panelData)
  LAM:RegisterOptionControls(ScrySpy.addon_name .. "_Options", optionsData)
  EVENT_MANAGER:UnregisterForEvent(ScrySpy.addon_name .. "_Options", EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(ScrySpy.addon_name .. "_Options", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
