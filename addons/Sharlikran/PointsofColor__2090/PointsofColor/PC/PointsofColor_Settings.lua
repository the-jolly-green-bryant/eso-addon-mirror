local LAM = LibAddonMenu2

local panelData = {
  type = "panel",
  name = "PointsofColor",
  displayName = "PointsofColor",
  author = "Jhenox",
  version = poc.version,
  slashCommand = "/poc",
  registerForRefresh = true,
  registerForDefaults = true,
}

local function build_table(index, title, tooltip, path, table_data)
  local optionsTable = {
    [index] = {
      type = "submenu",
      name = title,
      tooltip = tooltip,
      controls = {},
    },
  }
  for i = 1, #table_data do
    optionsTable[index]["controls"][i] = {
      type = "texture",
      image = path .. table_data[i][1],
      imageWidth = table_data[i][2],
      imageHeight = table_data[i][2],
      tooltip = table_data[i][1],
      width = "half",
    }
  end
  return optionsTable[index]
end

function poc:initLAM(poi_textures_complete, poi_textures_incomplete, service_textures)
  local optionsData = {}
  optionsData[#optionsData + 1] = {
    type = "description",
    text = GetString(POC_UNINSTALL_DESC),
  }
  optionsData[#optionsData + 1] = {
    type = "description",
    text = GetString(POC_EXITGAME_DESC),
  }
  optionsData[#optionsData + 1] = {
    type = "header",
    name = GetString(POC_HEADER_OPTIONS),
    width = "full"
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = GetString(POC_SHOW_GLOW_BACKGROUND_NAME),
    tooltip = GetString(POC_SHOW_GLOW_BACKGROUND_TOOLTIP),
    default = false,
    getFunc = function() return poc.SV.show_poi_glow_textures end,
    setFunc = function(val) poc.SV.show_poi_glow_textures = val end,
    width = "full",
    warning = "The game will need to be completely reloaded to take effect.",
  }
  optionsData[#optionsData + 1] = {
    type = "checkbox",
    name = GetString(POC_LESS_SATURATION_ICONS_NAME),
    tooltip = GetString(POC_LESS_SATURATION_ICONS_TOOLTIP),
    default = false,
    getFunc = function() return poc.SV.use_less_saturation_textures end,
    setFunc = function(val) poc.SV.use_less_saturation_textures = val end,
    width = "full",
    warning = "The game will need to be completely reloaded to take effect.",
  }
  local pointsOfIntrestCompleteIndex = #optionsData + 1
  optionsData[pointsOfIntrestCompleteIndex] = build_table(pointsOfIntrestCompleteIndex, "View Points of Interest - Complete", "View the textures for completed/discovered/owned points-of-interest.", "esoui\\art\\icons\\poi\\", poi_textures_complete)
  local pointsOfIntrestInompleteIndex = #optionsData + 1
  optionsData[pointsOfIntrestInompleteIndex] = build_table(pointsOfIntrestInompleteIndex, "View Points of Interest - Incomplete", "View the textures for incomplete/undiscovered/unowned points-of-interest.", "esoui\\art\\icons\\poi\\", poi_textures_incomplete)
  local viewServiceLocationsIndex = #optionsData + 1
  optionsData[viewServiceLocationsIndex] = build_table(viewServiceLocationsIndex, "View Service Locations", "View the textures for service locations.", "esoui\\art\\icons\\servicemappins\\", service_textures)

  LAM:RegisterAddonPanel("PointsofColor_OptionsPanel", panelData)
  LAM:RegisterOptionControls("PointsofColor_OptionsPanel", optionsData)
end