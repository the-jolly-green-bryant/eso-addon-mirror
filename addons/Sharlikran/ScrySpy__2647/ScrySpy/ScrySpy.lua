local LMP = LibMapPins
local GPS = LibGPS3
local CCP = COMPASS_PINS
local LMD = LibMapData
-------------------------------------------------
----- Logger Function                       -----
-------------------------------------------------
ScrySpy.show_log = false
if LibDebugLogger then
  ScrySpy.logger = LibDebugLogger.Create(ScrySpy.addon_name)
end
local logger
local viewer
if DebugLogViewer then viewer = true else viewer = false end
if LibDebugLogger then logger = true else logger = false end

local function create_log(log_type, log_content)
  if not viewer and log_type == "Info" then
    CHAT_ROUTER:AddSystemMessage(log_content)
    return
  end
  if not ScrySpy.show_log then return end
  if logger and log_type == "Debug" then
    ScrySpy.logger:Debug(log_content)
  end
  if logger and log_type == "Info" then
    ScrySpy.logger:Info(log_content)
  end
  if logger and log_type == "Verbose" then
    ScrySpy.logger:Verbose(log_content)
  end
  if logger and log_type == "Warn" then
    ScrySpy.logger:Warn(log_content)
  end
end

local function emit_message(log_type, text)
  if (text == "") then
    text = "[Empty String]"
  end
  create_log(log_type, text)
end

local function emit_table(log_type, t, indent, table_history)
  indent = indent or "."
  table_history = table_history or {}

  for k, v in pairs(t) do
    local vType = type(v)

    emit_message(log_type, indent .. "(" .. vType .. "): " .. tostring(k) .. " = " .. tostring(v))

    if (vType == "table") then
      if (table_history[v]) then
        emit_message(log_type, indent .. "Avoiding cycle on table...")
      else
        table_history[v] = true
        emit_table(log_type, v, indent .. "  ", table_history)
      end
    end
  end
end

function ScrySpy:dm(log_type, ...)
  for i = 1, select("#", ...) do
    local value = select(i, ...)
    if (type(value) == "table") then
      emit_table(log_type, value)
    else
      emit_message(log_type, tostring(value))
    end
  end
end

---------------------------------------
----- ScrySpy Vars                -----
---------------------------------------

ScrySpy_SavedVars = ScrySpy_SavedVars or { }
ScrySpy_SavedVars.version = ScrySpy_SavedVars.version or 1 -- This is not the addon version number
ScrySpy_SavedVars.location_info = ScrySpy_SavedVars.location_info or { }
ScrySpy_SavedVars.pin_level = ScrySpy_SavedVars.pin_level or ScrySpy.scryspy_defaults.pin_level
ScrySpy_SavedVars.pin_size = ScrySpy_SavedVars.pin_size or ScrySpy.scryspy_defaults.pin_size
ScrySpy_SavedVars.digsite_pin_size = ScrySpy_SavedVars.digsite_pin_size or ScrySpy.scryspy_defaults.digsite_pin_size
ScrySpy_SavedVars.pin_type = ScrySpy_SavedVars.pin_type or ScrySpy.scryspy_defaults.pin_type
ScrySpy_SavedVars.digsite_pin_type = ScrySpy_SavedVars.digsite_pin_type or ScrySpy.scryspy_defaults.digsite_pin_type
ScrySpy_SavedVars.compass_max_distance = ScrySpy_SavedVars.compass_max_distance or ScrySpy.scryspy_defaults.compass_max_distance
ScrySpy_SavedVars.digsite_spike_color = ScrySpy_SavedVars.digsite_spike_color or ScrySpy.scryspy_defaults.digsite_spike_color
--[[TODO easy access boolean for whether or not to draw pins, but it's always true?]]--
ScrySpy_SavedVars.compass_pins_enabled = ScrySpy_SavedVars.compass_pins_enabled or ScrySpy.scryspy_defaults.filters[ScrySpy.custom_compass_pin_type]
ScrySpy_SavedVars.map_pins_enabled = ScrySpy_SavedVars.map_pins_enabled or ScrySpy.scryspy_defaults.filters[ScrySpy.scryspy_map_pin_type]
ScrySpy_SavedVars.digsite_pins_enabled = ScrySpy_SavedVars.digsite_pins_enabled or ScrySpy.scryspy_defaults.filters[ScrySpy.digsite_map_pin_type]

-- Existing Local
local PIN_TYPE = "pinType_Digsite" -- This is changed by LAM now, use ScrySpy.scryspy_map_pin_type
local PIN_FILTER_NAME = "ScrySpy"
local PIN_NAME = "Dig Location"
local PIN_PRIORITY_OFFSET = 1
local SAVE_VARIABLES_VERSION = 5

---------------------------------------
----- Camera RenderSpace Setup -----
---------------------------------------

-- Create the 3D render space control used to query the active camera transform
ScrySpy.cameraControl = CreateControl("ScrySpy_CameraMeasurementControl", GuiRoot, CT_CONTROL)
ScrySpy.cameraControl:Create3DRenderSpace()

-- ScrySpy
ScrySpy.dig_site_names = {
  ["de"] = "Ausgrabungsstätte",
  ["en"] = "Dig Site",
  ["es"] = "yacimiento",
  ["fr"] = "site de fouilles",
  ["kb"] = "縜潴 頄覥",
  ["kr"] = "縜潴 頄覥",
  ["pl"] = "Wykopalisko",
  ["ru"] = "Место раскопок",
  ["jp"] = "発掘現場",
}

ScrySpy.loc_index = {
  x_pos = 1,
  y_pos = 2,
  x_gps = 3,
  y_gps = 4,
  worldX = 5,
  worldY = 6,
  worldZ = 7,
}

-- Function to check for empty table
local function is_empty_or_nil(t)
  if t == nil or t == "" then return true end
  return type(t) == "table" and ZO_IsTableEmpty(t) or false
end

local function is_in(search_value, search_table)
    if is_empty_or_nil(search_value) then return false end
    for k, v in pairs(search_table) do
        if search_value == v then return true end
        if type(search_value) == "string" then
            if string.find(string.lower(v), string.lower(search_value)) then return true end
        end
    end
    return false
end

local function get_digsite_locations(zone)
  --d(zone)
  if is_empty_or_nil(ScrySpy.dig_sites[zone]) then
    return {}
  else
    return ScrySpy.dig_sites[zone]
  end
end

---------------------------------------
----- ScrySpy                     -----
---------------------------------------
ScrySpy.worldControlPool = ZO_ControlPool:New("ScrySpy_WorldPin", ScrySpy_WorldPins)
ScrySpy.antiquity_dig_sites = {}
ScrySpy.scrying_antiquities = false

local function get_digsite_loc_sv(zone)
  --d(zone)
  if is_empty_or_nil(ScrySpy_SavedVars.location_info[zone]) then
    return {}
  else
    return ScrySpy_SavedVars.location_info[zone]
  end
end

local function save_to_sv(locations_table, location)
  --[[
  This should be the table not the Zone like Skyrim or
  the ZoneID

  example ScrySpy.dig_sites[zone_id][zone] where zone might be
  ["skyrim/westernskryim_base_0"] and zone_id is 1160
  ]]--
  local save_location = true
  for num_entry, digsite_loc in ipairs(locations_table) do
    local distance = zo_round(GPS:GetLocalDistanceInMeters(digsite_loc[ScrySpy.loc_index.x_pos], digsite_loc[ScrySpy.loc_index.y_pos], location[ScrySpy.loc_index.x_pos], location[ScrySpy.loc_index.y_pos]))
    -- ScrySpy:dm("Debug", string.format("save_to_sv from location table distance: %s", distance))
    if distance <= 10 then
      -- ScrySpy:dm("Debug", "less then 10 to close to me")
      return false
    else
      -- ScrySpy:dm("Debug", "more then 10, far away, save it")
    end
  end
  return save_location
end

local function save_dig_site_location()
  --ScrySpy:dm("Debug", "save_dig_site_location")
  local x_pos, y_pos = GetMapPlayerPosition("player")
  local x_gps, y_gps = GPS:LocalToGlobal(x_pos, y_pos)
  local zone_id, worldX, worldY, worldZ = GetUnitWorldPosition("player")

  local zone = LMP:GetZoneAndSubzone(true, false, true)
  -- if ScrySpy_SavedVars.location_info == nil then ScrySpy_SavedVars.location_info = {} end
  -- not needed, because it's already created above
  ScrySpy_SavedVars.location_info = ScrySpy_SavedVars.location_info or { }
  ScrySpy_SavedVars.location_info[zone] = ScrySpy_SavedVars.location_info[zone] or { }

  if ScrySpy.dig_sites == nil then ScrySpy.dig_sites = {} end
  if ScrySpy.dig_sites[zone] == nil then ScrySpy.dig_sites[zone] = {} end

  local dig_sites_table = get_digsite_locations(zone)
  if is_empty_or_nil(dig_sites_table) then dig_sites_table = {} end

  local dig_sites_sv_table = get_digsite_loc_sv(zone)
  if is_empty_or_nil(dig_sites_sv_table) then dig_sites_sv_table = {} end

  local location = {
    [ScrySpy.loc_index.x_pos] = x_pos,
    [ScrySpy.loc_index.y_pos] = y_pos,
    [ScrySpy.loc_index.x_gps] = x_gps,
    [ScrySpy.loc_index.y_gps] = y_gps,
    [ScrySpy.loc_index.worldX] = worldX,
    [ScrySpy.loc_index.worldY] = worldY,
    [ScrySpy.loc_index.worldZ] = worldZ,
  }
  local meetsDigsiteTable = save_to_sv(dig_sites_table, location)
  local meetsDigsiteSavedVariables = save_to_sv(dig_sites_sv_table, location)
  if meetsDigsiteTable and meetsDigsiteSavedVariables then
    --ScrySpy:dm("Debug", "Saving Location")
    table.insert(ScrySpy_SavedVars.location_info[zone], location)
    LMP:RefreshPins(ScrySpy.scryspy_map_pin_type)
    CCP:RefreshPins(ScrySpy.custom_compass_pin_type)
    ScrySpy.Draw3DPins()
  else
    --ScrySpy:dm("Debug", "No need to save location")
  end
end

function ScrySpy.RefreshPinLayout()
  LMP:SetLayoutKey(ScrySpy.scryspy_map_pin_type, "size", ScrySpy_SavedVars.pin_size)
  LMP:SetLayoutKey(ScrySpy.scryspy_map_pin_type, "level", ScrySpy_SavedVars.pin_level + PIN_PRIORITY_OFFSET)
  LMP:SetLayoutKey(ScrySpy.scryspy_map_pin_type, "texture", ScrySpy.pin_textures[ScrySpy_SavedVars.pin_type])
end

---------------------------------------
----- Lib3D                       -----
---------------------------------------

function ScrySpy:GetCameraRenderSpace()
  local measurementControl = self.cameraControl
  Set3DRenderSpaceToCurrentCamera(measurementControl:GetName())
  local x, y, z = measurementControl:Get3DRenderSpaceOrigin()
  local forwardX, forwardY, forwardZ = measurementControl:Get3DRenderSpaceForward()
  local rightX, rightY, rightZ = measurementControl:Get3DRenderSpaceRight()
  local upX, upY, upZ = measurementControl:Get3DRenderSpaceUp()
  return x, y, z, forwardX, forwardY, forwardZ, rightX, rightY, rightZ, upX, upY, upZ
end

function ScrySpy.Hide3DPins()
  -- remove the on update handler and hide the ScrySpy.dig_site_pin
  EVENT_MANAGER:UnregisterForUpdate("DigSite")
  ScrySpy_WorldPins:SetHidden(true)
  ScrySpy.worldControlPool:ReleaseAllObjects()
end

function ScrySpy.Draw3DPins()
  EVENT_MANAGER:UnregisterForUpdate("DigSite")
  --ScrySpy:dm("Debug", "Draw3DPins")
  local zone = LMP:GetZoneAndSubzone(true, false, true)

  local mapData = ScrySpy.get_pin_data(zone) or { }
  -- pseudo_pin_location
  if mapData then
    local worldX, worldZ, worldY = WorldPositionToGuiRender3DPosition(0, 0, 0)
    if not worldX then return end
    ScrySpy_WorldPins:Set3DRenderSpaceOrigin(worldX, worldZ, worldY)
    ScrySpy_WorldPins:SetHidden(false)

    for pin, pinData in ipairs(mapData) do
      local pinControl = ScrySpy.worldControlPool:AcquireObject(pin)
      if not pinControl:Has3DRenderSpace() then
        pinControl:Create3DRenderSpace()
      end

      local size = 1
      local iconControl = pinControl:GetNamedChild("Icon")
      if not iconControl:Has3DRenderSpace() then
        iconControl:Create3DRenderSpace()
        iconControl:Set3DRenderSpaceUsesDepthBuffer(true)
      end
      iconControl:SetTexture(ScrySpy.pin_textures[ScrySpy_SavedVars.digsite_pin_type])
      iconControl:Set3DRenderSpaceOrigin(pinData[ScrySpy.loc_index.worldX] / 100, (pinData[ScrySpy.loc_index.worldY] / 100) + 2.5, pinData[ScrySpy.loc_index.worldZ] / 100)
      iconControl:Set3DLocalDimensions(0.30 * size + 0.6, 0.30 * size + 0.6)

      local spikeControl = pinControl:GetNamedChild("Spike")
      if not spikeControl:Has3DRenderSpace() then
        spikeControl:Create3DRenderSpace()
        spikeControl:Set3DRenderSpaceUsesDepthBuffer(true)
      end
      spikeControl:SetColor(ScrySpy.unpack_color_table(ScrySpy_SavedVars.digsite_spike_color))
      spikeControl:Set3DRenderSpaceOrigin(pinData[ScrySpy.loc_index.worldX] / 100, (pinData[ScrySpy.loc_index.worldY] / 100) + 1.0, pinData[ScrySpy.loc_index.worldZ] / 100)
      spikeControl:Set3DLocalDimensions(0.25 * size + 0.75, 0.75 * size + 1.25)
    end

    local activeObjects = ScrySpy.worldControlPool:GetActiveObjects()

    -- don't do that every single frame. it's not necessary
    EVENT_MANAGER:RegisterForUpdate("DigSite", 100, function()
      local x, y, z, forwardX, forwardY, forwardZ, rightX, rightY, rightZ, upX, upY, upZ = ScrySpy:GetCameraRenderSpace()
      for key, pinControl in pairs(activeObjects) do
        for i = 1, pinControl:GetNumChildren() do
          local textureControl = pinControl:GetChild(i)
          textureControl:Set3DRenderSpaceForward(forwardX, forwardY, forwardZ)
          textureControl:Set3DRenderSpaceRight(rightX, rightY, rightZ)
          textureControl:Set3DRenderSpaceUp(upX, upY, upZ)
        end
      end
    end)
  end
end

local function OnInteract(event_code, client_interact_result, interact_target_name)
  --ScrySpy:dm("Debug", "OnInteract Occured")
  --ScrySpy:dm("Debug", client_interact_result)
  local text = zo_strformat(SI_CHAT_MESSAGE_FORMATTER, interact_target_name)
  --ScrySpy:dm("Debug", text)
  if text == ScrySpy.dig_site_names[ScrySpy.effective_lang] then
    save_dig_site_location()
  else
    --ScrySpy:dm("Debug", "Did not match")
  end
end
EVENT_MANAGER:RegisterForEvent(ScrySpy.addon_name .. "_OnInteract", EVENT_CLIENT_INTERACT_RESULT, OnInteract)

function ScrySpy.combine_data(zone)
  ScrySpy_SavedVars.location_info = ScrySpy_SavedVars.location_info or { }
  ScrySpy_SavedVars.location_info[zone] = ScrySpy_SavedVars.location_info[zone] or { }

  ScrySpy.dig_sites[zone] = ScrySpy.dig_sites[zone] or { }

  local digsiteData = ScrySpy.dig_sites[zone] or { }
  local dig_sites_sv_table = get_digsite_loc_sv(zone) or { }
  for num_entry, digsite_loc in ipairs(dig_sites_sv_table) do
    if save_to_sv(digsiteData, digsite_loc) then
      table.insert(digsiteData, digsite_loc)
    end
  end
  return digsiteData
end

-- /script d(zo_round(LibGPS3:GetLocalDistanceInMeters(0.82357305288315, 0.36382120383569, 0.904232442379, 0.78514248132706)))
function ScrySpy.get_pin_data(zone)
  --ScrySpy:dm("Debug", "get_pin_data")
  local function digsite_in_range(location)
    for key, compas_pin_loc in pairs(ScrySpy.antiquity_dig_sites) do
      local distance = zo_round(GPS:GetLocalDistanceInMeters(compas_pin_loc.x, compas_pin_loc.y, location[ScrySpy.loc_index.x_pos], location[ScrySpy.loc_index.y_pos]))
      --ScrySpy:dm("Debug", string.format("digsite_in_range distance: %s", distance))
      --ScrySpy:dm("Debug", string.format("digsite_in_range dig site size: %s", ScrySpy.antiquity_dig_sites[key].size))
      if distance <= ScrySpy.antiquity_dig_sites[key].size then
        return true
      end
    end
    return false
  end

  local function in_mod_digsite_pool(main_table, location)
    for _, compas_pin_loc in pairs(main_table) do
      local distance = zo_round(GPS:GetLocalDistanceInMeters(compas_pin_loc[ScrySpy.loc_index.x_pos], compas_pin_loc[ScrySpy.loc_index.y_pos], location[ScrySpy.loc_index.x_pos], location[ScrySpy.loc_index.y_pos]))
      -- ScrySpy:dm("Debug", string.format("in_mod_digsite_pool distance: %s", distance))
      if distance <= 10 then
        return true
      end
    end
    return false
  end

  ScrySpy_SavedVars.location_info = ScrySpy_SavedVars.location_info or { }
  ScrySpy_SavedVars.location_info[zone] = ScrySpy_SavedVars.location_info[zone] or { }

  ScrySpy.dig_sites[zone] = ScrySpy.dig_sites[zone] or { }

  -- this is the end result if within range
  local mod_digsite_pool = { }

  --ScrySpy.show_log = false
  for num_entry, digsite_loc in ipairs(ScrySpy.dig_sites[zone]) do
    if digsite_in_range(digsite_loc) then
      table.insert(mod_digsite_pool, digsite_loc)
      -- ScrySpy:dm("Debug", "digsite pool updated")
    end
  end
  --ScrySpy.show_log = true

  local dig_sites_sv_table = get_digsite_loc_sv(zone) or { }
  for num_entry, digsite_loc in ipairs(dig_sites_sv_table) do
    local digsiteInRange = digsite_in_range(digsite_loc)
    local withinModDigsitePool = in_mod_digsite_pool(mod_digsite_pool, digsite_loc)
    if digsiteInRange and not withinModDigsitePool then
      --ScrySpy:dm("Debug", "digsite pool updated")
      table.insert(mod_digsite_pool, digsite_loc)
    end
  end

  --mod_digsite_pool = ScrySpy.combine_data(zone)
  return mod_digsite_pool
end

local function InitializePins()
  local map_pin_layout = {
    level = ScrySpy_SavedVars.pin_level,
    texture = ScrySpy.pin_textures[ScrySpy_SavedVars.pin_type],
    size = ScrySpy_SavedVars.pin_size,
  }

  local pinlayout_compass = {
    maxDistance = 0.05,
    texture = ScrySpy.pin_textures[ScrySpy_SavedVars.digsite_pin_type],
    sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
      if zo_abs(normalizedAngle) > 0.25 then
        pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
      else
        pin:SetDimensions(48, 48)
      end
    end,
  }

  local function map_pin_callback(pinType)
    --[[
    Problem encountered. When standing in the ["skyrim/solitudeoutlawsrefuge_0"]

    The Zone ID for that map is 1178 and the mapname is ["skyrim/solitudeoutlawsrefuge_0"]

    If you have the map open and change maps, then the map might be ["craglorn/craglorn_base_0"]
    but the player, where they are currently standing is still 1178.

    meaning the game will look for 1178 and ["craglorn/craglorn_base_0"] which is invalid
    ]]--
    --d(zone)
    if LMD.isWorld then
      return
    end

    if not LMP:IsEnabled(pinType) then
      return
    end

    local zone = LMP:GetZoneAndSubzone(true, false, true)
    local mapData = ScrySpy.get_pin_data(zone) or { }
    if mapData then
      for index, pinData in pairs(mapData) do
        LMP:CreatePin(ScrySpy.scryspy_map_pin_type, pinData, pinData[ScrySpy.loc_index.x_pos], pinData[ScrySpy.loc_index.y_pos])
      end
    end
  end

  local function compass_pin_callback()
    if LMD.isWorld then
      --ScrySpy:dm("Debug", "Tamriel or Aurbis reached, stopped")
      return
    end

    if not ScrySpy_SavedVars.compass_pins_enabled then
      return
    end

    local zone = LMP:GetZoneAndSubzone(true, false, true)
    local mapData = ScrySpy.get_pin_data(zone) or { }
    if mapData then
      for _, pinData in ipairs(mapData) do
        CCP.pinManager:CreatePin(ScrySpy.custom_compass_pin_type, pinData, pinData[ScrySpy.loc_index.x_pos], pinData[ScrySpy.loc_index.y_pos])
      end
    end
  end

  local pinTooltipCreator = {
    creator = function(pin)
      if IsInGamepadPreferredMode() then
        local InformationTooltip = ZO_MapLocationTooltip_Gamepad
        local baseSection = InformationTooltip.tooltip
        InformationTooltip:LayoutIconStringLine(baseSection, nil, ScrySpy.addon_name, baseSection:GetStyle("mapLocationTooltipContentHeader"))
        InformationTooltip:LayoutIconStringLine(baseSection, nil, PIN_NAME, baseSection:GetStyle("mapLocationTooltipContentName"))
      else
        SetTooltipText(InformationTooltip, PIN_NAME)
      end
    end
  }

  LMP:AddPinType(ScrySpy.scryspy_map_pin_type, function() map_pin_callback(ScrySpy.scryspy_map_pin_type) end, nil, map_pin_layout, pinTooltipCreator)
  ScrySpy.RefreshPinLayout()
  LMP:RefreshPins(ScrySpy.scryspy_map_pin_type)
  CCP:AddCustomPin(ScrySpy.custom_compass_pin_type, compass_pin_callback, pinlayout_compass)
  CCP:RefreshPins(ScrySpy.custom_compass_pin_type)
end

local function build_zone_data()
  local zone = LMP:GetZoneAndSubzone(true, false, true)
  if ScrySpy_SavedVars.data_store == nil then ScrySpy_SavedVars.data_store = {} end
  ScrySpy_SavedVars.data_store[zone] = ScrySpy.combine_data(zone)
end

local function build_all_zone_data()
  local all_internal_data = ZO_DeepTableCopy(ScrySpy.dig_sites)
  local all_savedvariables_data = ZO_DeepTableCopy(ScrySpy_SavedVars["location_info"])
  local current_internal_zone
  ScrySpy_SavedVars.data_store = {}

  for zone, zone_data in pairs(all_internal_data) do
    if not is_empty_or_nil(zone_data) then
      if ScrySpy_SavedVars.data_store[zone] == nil then ScrySpy_SavedVars.data_store[zone] = {} end
      ScrySpy_SavedVars.data_store[zone] = zone_data
    end
  end

  for zone, zone_data in pairs(all_savedvariables_data) do
    current_internal_zone = get_digsite_locations(zone)
    if not is_empty_or_nil(current_internal_zone) then
      for index, location_data in pairs(zone_data) do
        if save_to_sv(current_internal_zone, location_data) then
          if ScrySpy_SavedVars.data_store[zone] == nil then ScrySpy_SavedVars.data_store[zone] = {} end
          table.insert(ScrySpy_SavedVars.data_store[zone], location_data)
        end
      end
    end
  end
end

local function reset_zone_data()
  ScrySpy_SavedVars.data_store = nil
  ScrySpy_SavedVars.cleaned_data_store = nil
end

local function OnPlayerActivated(eventCode, initial)
  --ScrySpy:dm("Debug", "OnPlayerActivated Occured")
  ScrySpy.RefreshPinLayout()
  CCP.pinLayouts[ScrySpy.custom_compass_pin_type].maxDistance = ScrySpy_SavedVars.compass_max_distance
  CCP.pinLayouts[ScrySpy.custom_compass_pin_type].texture = ScrySpy.pin_textures[ScrySpy_SavedVars.pin_type]
  CCP:RefreshPins(ScrySpy.custom_compass_pin_type)
  ScrySpy.update_antiquity_dig_sites()
  ScrySpy.Draw3DPins()
  EVENT_MANAGER:UnregisterForEvent(ScrySpy.addon_name .. "_InitPins", EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(ScrySpy.addon_name .. "_InitPins", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

function ScrySpy.disable_active_dig_site_info()
  ScrySpy.scrying_antiquities = false
  -- also disable compas pins
  ScrySpy_SavedVars.compass_pins_enabled = false
  -- also disable map pins
  --[[TODO ScrySpy_SavedVars.map_pins_enabled is not used because of LMP:Enable() ]]--
  ScrySpy_SavedVars.map_pins_enabled = false
  -- release all the world objects
  ScrySpy.worldControlPool:ReleaseAllObjects()
  LMP:Disable(ScrySpy.scryspy_map_pin_type)
  ScrySpy.Hide3DPins()
end

function ScrySpy.enable_active_dig_site_info()
  ScrySpy.scrying_antiquities = true
  -- also enable compas pins
  ScrySpy_SavedVars.compass_pins_enabled = true
  -- also enable map pins
  --[[TODO ScrySpy_SavedVars.map_pins_enabled is not used because of LMP:Enable() ]]--
  ScrySpy_SavedVars.map_pins_enabled = true
  LMP:Enable(ScrySpy.scryspy_map_pin_type)
  ScrySpy.Draw3DPins()
end

function ScrySpy.update_active_dig_sites()
  if NonContiguousCount(ScrySpy.antiquity_dig_sites) >= 1 then
    ScrySpy.enable_active_dig_site_info()
  else
    ScrySpy.disable_active_dig_site_info()
  end

  LMP:RefreshPins(ScrySpy.scryspy_map_pin_type)
  CCP:RefreshPins(ScrySpy.custom_compass_pin_type)
end

-- MAP_PIN_TYPE_TRACKED_ANTIQUITY_DIG_SITE = 42
-- LibMapPins
function ScrySpy.update_antiquity_dig_sites()
  local function mapZoomFactorToInt(panAndZoomInfo)
    if panAndZoomInfo and panAndZoomInfo.currentNormalizedZoom ~= nil then
      local zoomFactor = panAndZoomInfo.currentNormalizedZoom
      zoomFactor = math.min(1, math.max(0, zoomFactor))
      local sizeMapping = {
        [0] = 10,
        [1] = 10,
        [2] = 9,
        [3] = 8,
        [4] = 7,
        [5] = 6,
        [6] = 5,
        [7] = 4,
        [8] = 3,
        [9] = 2,
        [10] = 1,
      }
      local zoomFactorMapping = {
        [0] = 2.9,
        [1] = 3.7,
        [2] = 3.4,
        [3] = 3.0,
        [4] = 2.6,
        [5] = 2.2,
        [6] = 1.7,
        [7] = 1.1,
        [8] = 1.5,
        [9] = -0.2,
        [10] = -0.9,
      }
      local size = sizeMapping[math.floor(zoomFactor * 10)]
      local zfSize = zoomFactorMapping[math.floor(zoomFactor * 10)]
      return size, zfSize
    else
      return 1
    end
  end

  -- setup variables
  local digsiteIndexes = {}
  ScrySpy.antiquity_dig_sites = {}

  local function get_digsite_indexes()
    local digsiteKeys = LMP.pinManager.m_keyToPinMapping["antiquityDigSite"]
    for outerKey, outerValue in pairs(digsiteKeys) do
      for key, value in pairs(outerValue) do
        table.insert(digsiteIndexes, value)
      end
    end
    return NonContiguousCount(digsiteIndexes) >= 1
  end

  --ScrySpy:dm("Debug", "update_antiquity_dig_sites")
  --ScrySpy:dm("Debug", LMP:GetZoneAndSubzone(true, false, true))
  -- LibMapPins
  local hasActiveDigsites = get_digsite_indexes()
  if not hasActiveDigsites then
    ScrySpy.has_active_digsites = false
  else
    ScrySpy.has_active_digsites = true
    -- /script d(LibMapPins.pinManager.m_keyToPinMapping["antiquityDigSite"])
    --ScrySpy:dm("Debug", map_pin_keys)
    --local _, blobIndex = next(map_pin_keys)
    --ScrySpy:dm("Debug", blobIndex)
    --local polygon_information = LMP.pinManager["m_Active"][blobIndex]
    --ScrySpy:dm("Debug", polygon_information)
    local polygon_information = LMP.pinManager["m_Active"]
    local panAndZoomInfo = ZO_WorldMap_GetPanAndZoom()
    local zoomFactor, zSize = mapZoomFactorToInt(panAndZoomInfo)
    local blob_key

    for _, pinIndex in pairs(digsiteIndexes) do
      local blobNormalizedX = polygon_information[pinIndex]["normalizedX"]
      local blobNormalizedY = polygon_information[pinIndex]["normalizedY"]
      local temp_compas_pin_location = {}
      temp_compas_pin_location.x = blobNormalizedX
      temp_compas_pin_location.y = blobNormalizedY
      blob_key = polygon_information[pinIndex]["polygonBlobKey"]
      if blob_key then
        -- set to 230 by default, then update as long as the control exists
        local blobSize = 0
        local blobMod = 0
        temp_compas_pin_location.size = 290
        local my_control = WINDOW_MANAGER:GetControlByName("ZO_WorldMapContainerPinPolygonBlob", blob_key)
        if my_control then
          local get_dimensions = my_control:GetDimensions()
          if get_dimensions ~= nil then
            blobSize = get_dimensions * zoomFactor
            blobMod = get_dimensions * zSize
            temp_compas_pin_location.size = blobSize - blobMod
          else
            --ScrySpy:dm("Debug", "GetDimensions Unavailable")
            ScrySpy.has_active_digsites = false
          end
        else
          --ScrySpy:dm("Debug", "GetControlByName Unavailable")
          ScrySpy.has_active_digsites = false
        end
        ScrySpy.antiquity_dig_sites[blob_key] = temp_compas_pin_location
      else
        --ScrySpy:dm("Debug", "Blog Key Unavailable")
        ScrySpy.has_active_digsites = false
      end
    end
  end
  ScrySpy.update_active_dig_sites()
end

local function OnTrackingUpdate(eventCode)
  --ScrySpy:dm("Debug", "TrackingUpdate Occured")
  ScrySpy.update_antiquity_dig_sites()
end
EVENT_MANAGER:RegisterForEvent(ScrySpy.addon_name .. "_OnTrackingUpdate", EVENT_ANTIQUITY_TRACKING_UPDATE, OnTrackingUpdate)

local function OnRevealAntiquity(eventCode)
  --ScrySpy:dm("Debug", "RevealAntiquity Occured")
  ScrySpy.update_antiquity_dig_sites()
  if not ScrySpy.has_active_digsites then
    ScrySpy:dm("Info", "Digsite Compass Pins Unavailable.")
    ScrySpy:dm("Info", "Use /ssrefresh when near Digsites to show pins.")
  end
end
EVENT_MANAGER:RegisterForEvent(ScrySpy.addon_name .. "_OnRevealAntiquity", EVENT_REVEAL_ANTIQUITY_DIG_SITES_ON_MAP, OnRevealAntiquity)

local function purge_duplicate_data()
  local all_savedvariables_data = ZO_DeepTableCopy(ScrySpy_SavedVars["location_info"])
  local current_internal_zone
  ScrySpy_SavedVars.location_info = {}
  for zone, zone_data in pairs(all_savedvariables_data) do
    current_internal_zone = get_digsite_locations(zone)
    if not is_empty_or_nil(current_internal_zone) then
      for index, location_data in pairs(zone_data) do
        if save_to_sv(current_internal_zone, location_data) then
          if ScrySpy_SavedVars.location_info[zone] == nil then ScrySpy_SavedVars.location_info[zone] = {} end
          table.insert(ScrySpy_SavedVars.location_info[zone], location_data)
        end
      end
    else
      --ScrySpy:dm("Debug", "ScrySpy nothing to loop over")
      ScrySpy_SavedVars.location_info[zone] = all_savedvariables_data[zone] or {}
    end
  end
end

---------------------------------------
----- Zone / World Change Handling -----
---------------------------------------

local function OnPlayerActivated2()
  local zoneId = GetZoneId(GetUnitZoneIndex("player"))
  ScrySpy:dm("Debug", string.format("Player activated in zone %d", zoneId))

  if ScrySpy.scrying_antiquities then
    ScrySpy.Draw3DPins()
  else
    ScrySpy.Hide3DPins()
  end
end

local function OnZoneChanged(_, unitTag, newZoneName, newSubZoneName, newZoneId, oldZoneId)
  if unitTag ~= "player" then return end
  ScrySpy:dm("Debug", string.format("Zone changed: %s → %s", oldZoneId or "?", newZoneId or "?"))

  if ScrySpy.scrying_antiquities then
    ScrySpy.Draw3DPins()
  else
    ScrySpy.Hide3DPins()
  end
end
EVENT_MANAGER:RegisterForEvent(ScrySpy.addon_name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated2)
EVENT_MANAGER:RegisterForEvent(ScrySpy.addon_name .. "_ZoneChanged", EVENT_ZONE_CHANGED, OnZoneChanged)

local function OnLoad(eventCode, addOnName)
  if addOnName ~= ScrySpy.addon_name then return end
  --ScrySpy:dm("Debug", "OnLoad")
  -- turn the top level control into a 3d control
  ScrySpy_WorldPins:Create3DRenderSpace()

  -- make sure the control is only shown, when the player can see the world
  -- i.e. the control is only shown during non-menu scenes
  local fragment = ZO_SimpleSceneFragment:New(ScrySpy_WorldPins)
  HUD_UI_SCENE:AddFragment(fragment)
  HUD_SCENE:AddFragment(fragment)
  LOOT_SCENE:AddFragment(fragment)

  if ScrySpy_SavedVars.version ~= SAVE_VARIABLES_VERSION then
    local temp_locations
    if ScrySpy_SavedVars.version == nil then ScrySpy_SavedVars.version = 1 end
    if ScrySpy_SavedVars.version >= 2 then
      if ScrySpy_SavedVars.location_info then
        temp_locations = ScrySpy_SavedVars.location_info
      end
    end
    ScrySpy_SavedVars = { }
    ScrySpy_SavedVars.version = SAVE_VARIABLES_VERSION
    ScrySpy_SavedVars.location_info = temp_locations or { }
    ScrySpy_SavedVars.pin_level = ScrySpy_SavedVars.pin_level or ScrySpy.scryspy_defaults.pin_level
    ScrySpy_SavedVars.pin_size = ScrySpy_SavedVars.pin_size or ScrySpy.scryspy_defaults.pin_size
    ScrySpy_SavedVars.digsite_pin_size = ScrySpy_SavedVars.digsite_pin_size or ScrySpy.scryspy_defaults.digsite_pin_size
    ScrySpy_SavedVars.pin_type = ScrySpy_SavedVars.pin_type or ScrySpy.scryspy_defaults.pin_type
    ScrySpy_SavedVars.digsite_pin_type = ScrySpy_SavedVars.digsite_pin_type or ScrySpy.scryspy_defaults.digsite_pin_type
    ScrySpy_SavedVars.compass_max_distance = ScrySpy_SavedVars.compass_max_distance or ScrySpy.scryspy_defaults.compass_max_distance
    ScrySpy_SavedVars.compass_pins_enabled = ScrySpy_SavedVars.compass_pins_enabled or ScrySpy.scryspy_defaults.filters[ScrySpy.custom_compass_pin_type]
    ScrySpy_SavedVars.map_pins_enabled = ScrySpy_SavedVars.map_pins_enabled or ScrySpy.scryspy_defaults.filters[ScrySpy.scryspy_map_pin_type]
    ScrySpy_SavedVars.digsite_pins_enabled = ScrySpy_SavedVars.digsite_pins_enabled or ScrySpy.scryspy_defaults.filters[ScrySpy.digsite_map_pin_type]
    if ScrySpy_SavedVars.version >= SAVE_VARIABLES_VERSION then
      ScrySpy_SavedVars.digsite_spike_color = ScrySpy_SavedVars.digsite_spike_color or ScrySpy.scryspy_defaults.digsite_spike_color
    else
      ScrySpy_SavedVars.digsite_spike_color = ScrySpy.scryspy_defaults.digsite_spike_color
    end
  end

  if ScrySpy_SavedVars["location_info"]["eyevea_base_0"] then
    ScrySpy_SavedVars["location_info"]["guildmaps/eyevea_base_0"] = ScrySpy_SavedVars["location_info"]["eyevea_base_0"]
    ScrySpy_SavedVars["location_info"]["eyevea_base_0"] = nil
  end
  purge_duplicate_data()

  InitializePins()
  ScrySpy.update_antiquity_dig_sites()

  --SLASH_COMMANDS["/ssreset"] = function() reset_zone_data() end

  --SLASH_COMMANDS["/ssbuild"] = function() build_zone_data() end

  --SLASH_COMMANDS["/ssbuildall"] = function() build_all_zone_data() end

  SLASH_COMMANDS["/ssrefresh"] = function() ScrySpy.update_antiquity_dig_sites() end

  EVENT_MANAGER:UnregisterForEvent(ScrySpy.addon_name, EVENT_ADD_ON_LOADED)
end
EVENT_MANAGER:RegisterForEvent(ScrySpy.addon_name, EVENT_ADD_ON_LOADED, OnLoad)
