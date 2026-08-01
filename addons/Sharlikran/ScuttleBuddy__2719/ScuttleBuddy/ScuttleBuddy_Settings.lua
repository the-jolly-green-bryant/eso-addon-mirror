local CCP = COMPASS_PINS
local LMP = LibMapPins
local LAM = LibAddonMenu2

local pin_textures_list = {
  [1] = "Scuttle Bloom (Default)",
}

local panelData = {
  type = "panel",
  name = GetString(mod_title),
  displayName = "|cFFFFB0" .. GetString(mod_title) .. "|r",
  author = "|cFF9B15Sharlikran|r",
  version = ScuttleBuddy.addon_version,
  slashCommand = "/ScuttleBuddy",
  registerForRefresh = true,
  registerForDefaults = true,
  website = ScuttleBuddy.addon_website,
}

local create_icons, shovel_icon, digsite_icon
local function create_icons(panel)
  if panel == WINDOW_MANAGER:GetControlByName(ScuttleBuddy.addon_name, "_Options") then
    shovel_icon = WINDOW_MANAGER:CreateControl(nil, panel.controlsToRefresh[1], CT_TEXTURE)
    shovel_icon:SetAnchor(RIGHT, panel.controlsToRefresh[1].combobox, LEFT, -10, 0)
    shovel_icon:SetTexture(ScuttleBuddy.pin_textures[ScuttleBuddy_SavedVars.pin_type])
    shovel_icon:SetDimensions(ScuttleBuddy_SavedVars.digsite_pin_size, ScuttleBuddy_SavedVars.digsite_pin_size)
    digsite_icon = WINDOW_MANAGER:CreateControl(nil, panel.controlsToRefresh[2], CT_TEXTURE)
    digsite_icon:SetAnchor(RIGHT, panel.controlsToRefresh[2].combobox, LEFT, -10, 0)
    digsite_icon:SetTexture(ScuttleBuddy.pin_textures[ScuttleBuddy_SavedVars.digsite_pin_type])
    digsite_icon:SetDimensions(ScuttleBuddy_SavedVars.digsite_pin_size, ScuttleBuddy_SavedVars.digsite_pin_size)
    CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", create_icons)
  end
end
CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", create_icons)

local optionsTable = {
  -- Set Map Pin and Compas Pin texture
  {
    type = "dropdown",
    name = GetString(map_pin_texture_text),
    tooltip = GetString(map_pin_texture_desc),
    choices = pin_textures_list,
    getFunc = function() return pin_textures_list[ScuttleBuddy_SavedVars.pin_type] end,
    setFunc = function(selected)
      for index, name in ipairs(pin_textures_list) do
        if name == selected then
          ScuttleBuddy_SavedVars.pin_type = index
          LMP:SetLayoutKey(ScuttleBuddy.ScuttleBuddy_map_pin, "texture", ScuttleBuddy.pin_textures[index])
          shovel_icon:SetTexture(ScuttleBuddy.pin_textures[index])
          ScuttleBuddy.RefreshPinLayout()
          LMP:RefreshPins(ScuttleBuddy.ScuttleBuddy_map_pin)
          CCP.pinLayouts[ScuttleBuddy.custom_compass_pin].texture = ScuttleBuddy.pin_textures[index]
          CCP:RefreshPins(ScuttleBuddy.custom_compass_pin)
          break
        end
      end
    end,
    default = pin_textures_list[ScuttleBuddy.ScuttleBuddy_defaults.pin_type],
  },
  -- 3D Digsite Icon Texture
  --[[
  {
      type = "dropdown",
      name = GetString(digsite_texture_text),
      tooltip = GetString(digsite_texture_desc),
      choices = pin_textures_list,
      getFunc = function() return pin_textures_list[ScuttleBuddy_SavedVars.digsite_pin_type] end,
      setFunc = function(selected)
              for index, name in ipairs(pin_textures_list) do
                  if name == selected then
                      ScuttleBuddy_SavedVars.digsite_pin_type = index
                      digsite_icon:SetTexture(ScuttleBuddy.pin_textures[index])
                      --ScuttleBuddy.Draw3DPins() -- this makes the pins appear when the are normally hidden
                      break
                  end
              end
          end,
      default = pin_textures_list[ScuttleBuddy.ScuttleBuddy_defaults.digsite_pin_type],
  },
  ]]--
  -- Set Map Pin pin size
  {
    type = "slider",
    name = GetString(pin_size),
    tooltip = GetString(pin_size_desc),
    min = 20,
    max = 70,
    getFunc = function() return ScuttleBuddy_SavedVars.pin_size end,
    setFunc = function(size)
      ScuttleBuddy_SavedVars.pin_size = size
      shovel_icon:SetDimensions(size, size)
      LMP:SetLayoutKey(ScuttleBuddy.ScuttleBuddy_map_pin, "size", size)
      ScuttleBuddy.RefreshPinLayout()
      LMP:RefreshPins(ScuttleBuddy.ScuttleBuddy_map_pin)
    end,
    default = ScuttleBuddy.ScuttleBuddy_defaults.pin_size,
  },
  -- Set Map Pin pin level meaning what takes precedence over other pins
  {
    type = "slider",
    name = GetString(pin_layer),
    tooltip = GetString(pin_layer_desc),
    min = 10,
    max = 200,
    step = 5,
    getFunc = function() return ScuttleBuddy_SavedVars.pin_level end,
    setFunc = function(level)
      ScuttleBuddy_SavedVars.pin_level = level
      LMP:SetLayoutKey(ScuttleBuddy.ScuttleBuddy_map_pin, "level", level)
      ScuttleBuddy.RefreshPinLayout()
      LMP:RefreshPins(ScuttleBuddy.ScuttleBuddy_map_pin)
    end,
    default = ScuttleBuddy.ScuttleBuddy_defaults.pin_level,
  },
  -- Set the max distance for compas pins to show up
  {
    type = "slider",
    name = GetString(compass_max_dist),
    tooltip = GetString(compass_max_dist_desc),
    min = 1,
    max = 100,
    getFunc = function() return ScuttleBuddy_SavedVars.compass_max_distance * 1000 end,
    setFunc = function(maxDistance)
      ScuttleBuddy_SavedVars.compass_max_distance = maxDistance / 1000
      CCP.pinLayouts[ScuttleBuddy.custom_compass_pin].maxDistance = maxDistance / 1000
      CCP:RefreshPins(ScuttleBuddy.custom_compass_pin)
    end,
    width = "full",
    default = ScuttleBuddy.ScuttleBuddy_defaults.compass_max_distance * 1000,
  },
  -- Set color for the 3D Map Pin Spike
  --[[
  {
      type = "colorpicker",
      name = GetString(spike_pincolor),
      tooltip = GetString(spike_pincolor_desc),
      getFunc = function() return unpack(ScuttleBuddy_SavedVars.digsite_spike_color) end,
      setFunc = function(r,g,b,a)
          ScuttleBuddy_SavedVars.digsite_spike_color = ScuttleBuddy.create_color_table(r, g, b, a)
          --ScuttleBuddy.Draw3DPins()
      end,
      default = ScuttleBuddy.ScuttleBuddy_defaults.digsite_spike_color,
  },
  ]]--
}

local function OnPlayerActivated(event)
  LAM:RegisterAddonPanel(ScuttleBuddy.addon_name .. "_Options", panelData)
  LAM:RegisterOptionControls(ScuttleBuddy.addon_name .. "_Options", optionsTable)
  EVENT_MANAGER:UnregisterForEvent(ScuttleBuddy.addon_name .. "_Options", EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(ScuttleBuddy.addon_name .. "_Options", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
