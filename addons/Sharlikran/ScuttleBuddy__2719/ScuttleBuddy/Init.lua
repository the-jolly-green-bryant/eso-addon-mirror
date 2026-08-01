ScuttleBuddy = {}

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

ScuttleBuddy.client_lang = GetCVar("Language.2")
ScuttleBuddy.effective_lang = nil
ScuttleBuddy.supported_lang = { "de", "en", "es", "fr", "pl", "ru", "jp", }
if is_in(ScuttleBuddy.client_lang, ScuttleBuddy.supported_lang) then
  ScuttleBuddy.effective_lang = ScuttleBuddy.client_lang
else
  ScuttleBuddy.effective_lang = "en"
end
ScuttleBuddy.supported_lang = ScuttleBuddy.client_lang == ScuttleBuddy.effective_lang

-------------------------------------------------
----- mod                                   -----
-------------------------------------------------

--[[
Some settings moved to Init.lua to make them global to other files
]]--

--[[ Previous var to toggle map pins
ScuttleBuddy_defaults = {
    show_pins=true,
}

-- Saved Vars
ScuttleBuddy_SavedVars.show_pins
]]--
ScuttleBuddy.addon_name = "ScuttleBuddy"
ScuttleBuddy.addon_version = "1.14"
ScuttleBuddy.addon_website = "https://www.esoui.com/downloads/info2647-ScuttleBuddy.html"
ScuttleBuddy.custom_compass_pin = "ScuttleBuddy_compass_pin" -- custom compas pin pin type
ScuttleBuddy.ScuttleBuddy_map_pin = "ScuttleBuddy_map_pin"
ScuttleBuddy.dig_site_pin = "ScuttleBuddy_location_pin"
ScuttleBuddy.should_update_digsites = true

ScuttleBuddy.pin_textures = {
  [1] = "ScuttleBuddy/img/harvest_scuttlebloom.dds",
}

function ScuttleBuddy.unpack_color_table(the_table)
  local col_r, col_g, col_b, col_a = unpack(the_table)
  return col_r, col_g, col_b, col_a
end

function ScuttleBuddy.create_color_table(r, g, b, a)
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

ScuttleBuddy.ScuttleBuddy_defaults = {
  ["pin_level"] = 30,
  ["pin_size"] = 25,
  ["digsite_pin_size"] = 25,
  ["pin_type"] = 1,
  ["digsite_pin_type"] = 1,
  ["compass_max_distance"] = 0.05,
  ["filters"] = {
    [ScuttleBuddy.custom_compass_pin] = true, -- toggle show pin on compass
    [ScuttleBuddy.ScuttleBuddy_map_pin] = true, -- toggle show pin on world map
    [ScuttleBuddy.dig_site_pin] = true, -- toggle show 3d pin in overland
  },
  ["digsite_spike_color"] = {
    [1] = 1,
    [2] = 1,
    [3] = 1,
    [4] = 1,
  },
}
