ScrySpy = {}

-------------------------------------------------
----- early helper                          -----
-------------------------------------------------

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

-------------------------------------------------
----- lang setup                            -----
-------------------------------------------------

ScrySpy.client_lang = GetCVar("Language.2")
ScrySpy.effective_lang = nil
ScrySpy.supported_lang = { "de", "en", "es", "fr", "kb", "kr", "pl", "ru", "jp", }
if is_in(ScrySpy.client_lang, ScrySpy.supported_lang) then
  ScrySpy.effective_lang = ScrySpy.client_lang
else
  ScrySpy.effective_lang = "en"
end
ScrySpy.supported_lang = ScrySpy.client_lang == ScrySpy.effective_lang

-------------------------------------------------
----- mod                                   -----
-------------------------------------------------

--[[
Some settings moved to Init.lua to make them global to other files
]]--

--[[ Previous var to toggle map pins
scryspy_defaults = {
    show_pins=true,
}

-- Saved Vars
ScrySpy_SavedVars.show_pins
]]--
ScrySpy.addon_name = "ScrySpy"
ScrySpy.addon_version = "1.44"
ScrySpy.addon_website = "https://www.esoui.com/downloads/info2647-ScrySpy.html"
ScrySpy.custom_compass_pin_type = "compass_digsite" -- custom compas pin pin type
ScrySpy.scryspy_map_pin_type = "scryspy_map_pin"
ScrySpy.digsite_map_pin_type = "dig_site_pin"
ScrySpy.has_active_digsites = false

ScrySpy.pin_textures = {
  [1] = "ScrySpy/img/spade_shovel_redx_marker.dds",
  [2] = "ScrySpy/img/spade_shovel_marker.dds",
  [3] = "esoui/art/antiquities/digsite_unknown.dds",
  [4] = "esoui/art/antiquities/digging_crystal_full.dds",
  [5] = "esoui/art/antiquities/digging_crystal_empty.dds",
  [6] = "esoui/art/antiquities/digging_crystal_border.dds",
  [7] = "esoui/art/antiquities/keyboard/trackedantiquityicon.dds",
  [8] = "esoui/art/inventory/inventory_icon_visible.dds",
  [9] = "esoui/art/inventory/inventory_quest_tabicon_active.dds",
  [10] = "ScrySpy/img/cute_spade.dds",
}

function ScrySpy.unpack_color_table(the_table)
  local col_r, col_g, col_b, col_a = unpack(the_table)
  return col_r, col_g, col_b, col_a
end

function ScrySpy.create_color_table(r, g, b, a)
  local c = {}

  if (type(r) == "string") then
    c[4], c[1], c[2], c[3] = ConvertHTMLColorToFloatValues(r)
  elseif (type(r) == "table") then
    local otherColorDef = r
    c[1] = otherColorDef.r or 1
    c[2] = otherColorDef.g or 1
    c[3] = otherColorDef.b or 1
    c[4] = otherColorDef.a or 1
  else
    c[1] = r or 1
    c[2] = g or 1
    c[3] = b or 1
    c[4] = a or 1
  end

  return c
end

ScrySpy.scryspy_defaults = {
  ["pin_level"] = 30,
  ["pin_size"] = 25,
  ["digsite_pin_size"] = 25,
  ["pin_type"] = 1,
  ["digsite_pin_type"] = 1,
  ["compass_max_distance"] = 0.05,
  ["filters"] = {
    [ScrySpy.custom_compass_pin_type] = true, -- toggle show pin on compass
    [ScrySpy.scryspy_map_pin_type] = true, -- toggle show pin on world map
    [ScrySpy.digsite_map_pin_type] = true, -- toggle show 3d pin in overland
  },
  ["digsite_spike_color"] = {
    [1] = 0.0862745121,
    [2] = 0.7215686440,
    [3] = 0.9490196109,
    [4] = 1,
  },
}
