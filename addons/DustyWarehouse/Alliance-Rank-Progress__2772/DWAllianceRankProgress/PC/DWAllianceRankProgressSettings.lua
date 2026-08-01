DWAllianceRankProgress.UserSettings = {}

local LAM = LibAddonMenu2

local function GetBarColour()
  return DWAllianceRankProgress.settings.barColour
end

local function SetBarColour(value)
  DWAllianceRankProgress.settings.barColour = value
  DWAllianceRankProgress:SetColours()
end

local function GetMeterType()
  return DWAllianceRankProgress.settings.meterType
end

local function SetMeterType(value)
  DWAllianceRankProgress.settings.meterType = value
  DWAllianceRankProgress:GetStatus()
end

local function GetShowOnlyInAvaZones()
  return DWAllianceRankProgress.settings.showOnlyInAvaZones
end

local function SetShowOnlyInAvaZones(value)
  DWAllianceRankProgress.settings.showOnlyInAvaZones = value
  DWAllianceRankProgress:ZoneCheck()
end

local function GetSwapRankAndAllianceIcons()
  return DWAllianceRankProgress.settings.swapRankAndAllianceIcons
end

local function SetAwapRankAndAllianceIcons(value)
  DWAllianceRankProgress.settings.swapRankAndAllianceIcons = value
  DWAllianceRankProgress:GetAllianceFlag()
  DWAllianceRankProgress:GetAllianceLevelText()
end

function DWAllianceRankProgress.UserSettings:Init()
  panel = {
    type = "panel",
    name = GetString(DW_ARPB_STR_ADDON_NAME),
    displayName = GetString(DW_ARPB_STR_ADDON_NAME),
    author = "Dusty Warehouse",
    version = DWAllianceRankProgress.version,
    registerForRefresh = true
  }

  options = {
    {
      type = "header",
      name = GetString(DW_ARPB_STR_SETTINGS),
      width = "full",
    },
    {
      type = "dropdown",
      name = GetString(DW_ARPB_STR_COLOUR_SCHEME),
      tooltip = "",
      choices = {GetString(DW_ARPB_STR_COLOUR_SCHEME_WH), GetString(DW_ARPB_STR_COLOUR_SCHEME_AL), GetString(DW_ARPB_STR_COLOUR_SCHEME_GR)},
      choicesValues = {"white", "alliance", "ap"},
      getFunc = function() return GetBarColour() end,
      setFunc = function(value) SetBarColour(value) end,
      width = "full",
    },
    {
      type = "dropdown",
      name = GetString(DW_ARPB_STR_METER_TYPE),
      tooltip = "",
      choices = {GetString(DW_ARPB_STR_METER_TYPE_NN), GetString(DW_ARPB_STR_METER_TYPE_TONEXT)},
      choicesValues = {"nn", "tonext"},
      getFunc = function() return GetMeterType() end,
      setFunc = function(value) SetMeterType(value) end,
      width = "full",
    },
    {
      type = "checkbox",
      name = GetString(DW_ARPB_STR_SHOW_IN_AVA),
      tooltip = "",
      getFunc = function() return GetShowOnlyInAvaZones() end,
      setFunc = function(value) SetShowOnlyInAvaZones(value) end,
      width = "full",
    },
    {
      type = "checkbox",
      name = GetString(DW_ARPB_STR_SWAP_ICONS),
      tooltip = "",
      getFunc = function() return GetSwapRankAndAllianceIcons() end,
      setFunc = function(value) SetAwapRankAndAllianceIcons(value) end,
      width = "full",
    }
  }

  LAM:RegisterAddonPanel(DWAllianceRankProgress.name.."UserSettings", panel)
  LAM:RegisterOptionControls(DWAllianceRankProgress.name.."UserSettings", options)
end
