DWAllianceRankProgress.UserSettings = {}

local LHAS = LibHarvensAddonSettings

local colourSchemes = {
  white = GetString(DW_ARPB_STR_COLOUR_SCHEME_WH),
  alliance = GetString(DW_ARPB_STR_COLOUR_SCHEME_AL),
  ap = GetString(DW_ARPB_STR_COLOUR_SCHEME_GR),
}

local function GetBarColour()
  return colourSchemes[DWAllianceRankProgress.settings.barColour]
end

local function SetBarColour(value)
  DWAllianceRankProgress.settings.barColour = value
  DWAllianceRankProgress:SetColours()
end

local meterTypes = {
  nn = GetString(DW_ARPB_STR_METER_TYPE_NN),
  tonext = GetString(DW_ARPB_STR_METER_TYPE_TONEXT)
}

local function GetMeterType()
  return meterTypes[DWAllianceRankProgress.settings.meterType]
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

local function GetPosX()
  return DWAllianceRankProgress.settings.position.x
end

local function SetPosX(value)
  DWAllianceRankProgress.settings.position.x = value
  DWAllianceRankProgress:ReAnchor()
end

local function GetPosY()
  return DWAllianceRankProgress.settings.position.y
end

local function SetPosY(value)
  DWAllianceRankProgress.settings.position.y = value
  DWAllianceRankProgress:ReAnchor()
end

function DWAllianceRankProgress.UserSettings:Init()
  local settings = LHAS:AddAddon(GetString(DW_ARPB_STR_ADDON_NAME))
	settings.allowRefresh = false -- don't need this as all settings are independent of each other
	settings.allowDefaults = true
	settings.version = DWAllianceRankProgress.version
  settings.website = "https://www.esoui.com/downloads/info2772-AllianceRankProgress.html"

  if not settings then
    return
  end

  local colourScheme = {
    type = LHAS.ST_DROPDOWN,
    label = GetString(DW_ARPB_STR_COLOUR_SCHEME),
    setFunction = function(combobox, name, item) SetBarColour(item.data) end,
    getFunction = function() return GetBarColour() end,
    default = DWAllianceRankProgress.settingsDefaults.barColour,
    items = {
      {
        name = GetString(DW_ARPB_STR_COLOUR_SCHEME_WH),
        data = "white"
      },
      {
        name = GetString(DW_ARPB_STR_COLOUR_SCHEME_AL),
        data = "alliance"
      },
      {
        name = GetString(DW_ARPB_STR_COLOUR_SCHEME_GR),
        data = "ap"
      }
    }
  }
  settings:AddSetting(colourScheme)

  local meterType = {
    type = LHAS.ST_DROPDOWN,
    label = GetString(DW_ARPB_STR_METER_TYPE),
    setFunction = function(combobox, name, item) SetMeterType(item.data) end,
    getFunction = function() return GetMeterType() end,
    default = DWAllianceRankProgress.settingsDefaults.meterType,
    items = {
      {
        name = GetString(DW_ARPB_STR_METER_TYPE_NN),
        data = "nn"
      },
      {
        name = GetString(DW_ARPB_STR_METER_TYPE_TONEXT),
        data = "tonext"
      }
    }
  }
  settings:AddSetting(meterType)

  local onlyShowInAva = {
    type = LHAS.ST_CHECKBOX,
    label = GetString(DW_ARPB_STR_SHOW_IN_AVA),
    default = DWAllianceRankProgress.settingsDefaults.showOnlyInAvaZones,
    setFunction = function(value) SetShowOnlyInAvaZones(value) end,
    getFunction = function() return GetShowOnlyInAvaZones() end
  }
  settings:AddSetting(onlyShowInAva)

  local swapIcons = {
    type = LHAS.ST_CHECKBOX,
    label = GetString(DW_ARPB_STR_SWAP_ICONS),
    default = DWAllianceRankProgress.settingsDefaults.swapRankAndAllianceIcons,
    setFunction = function(value) SetAwapRankAndAllianceIcons(value) end,
    getFunction = function() return GetSwapRankAndAllianceIcons() end
  }
  settings:AddSetting(swapIcons)

  local posX = {
    type = LibHarvensAddonSettings.ST_SLIDER,
    label = GetString(DW_ARPB_STR_POS_X),
    setFunction = function(value) SetPosX(value) end,
    getFunction = function() return GetPosX() end,
    default = DWAllianceRankProgress.settingsDefaults.position.x,
    min = 0,
    max = 1520,
    step = 10
  }
  settings:AddSetting(posX)

  local posY = {
    type = LibHarvensAddonSettings.ST_SLIDER,
    label = GetString(DW_ARPB_STR_POS_Y),
    setFunction = function(value) SetPosY(value) end,
    getFunction = function() return GetPosY() end,
    default = DWAllianceRankProgress.settingsDefaults.position.y,
    min = 0,
    max = 1000,
    step = 10
  }
  settings:AddSetting(posY)
end
