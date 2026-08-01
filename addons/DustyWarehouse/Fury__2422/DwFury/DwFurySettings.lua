DwFury.Settings = {}

local LAM = LibAddonMenu2

if not LAM and LibStub then
  LAM = LibStub("LibAddonMenu-2.0")
end

local function GetShowOutOfCombat()
  return DwFury.savedVars.showOutOfCombat
end

local function SetShowOutOfCombat(value)
  DwFury.savedVars.showOutOfCombat = value
  DwFury.showHide()
end

local function GetShowOnlyWhenActive()
  return DwFury.savedVars.showOnlyWhenActive
end

local function SetShowOnlyWhenActive(value)
  DwFury.savedVars.showOnlyWhenActive = value
  DwFury.showHide()
end

local function GetScale()
  return DwFury.savedVars.scale * 100
end

local function SetScale(value)
  DwFury.savedVars.scale = value / 100
	DwFury.setFontSize(DwFury.savedVars.stackTextSize * DwFury.savedVars.scale)
	DwFury.setPosition()
end

local function GetPlaySoundAtMaxStacks()
  return DwFury.savedVars.playAlertSound
end

local function SetPlaySoundAtMaxStacks(value)
  DwFury.savedVars.playAlertSound = value
end

function DwFury.Settings.Init()
  panel = {
    type = "panel",
    name = "Fury",
    displayName = "Fury",
    author = "Dusty Warehouse",
    version = DwFury.version,
    registerForRefresh = true
  }

  options = {
    {
        type = "header",
        name = "Settings",
        width = "full",
    },
    {
        type = "checkbox",
        name = "Show when not in combat",
        tooltip = "",
        getFunc = function() return GetShowOutOfCombat() end,
        setFunc = function(value) SetShowOutOfCombat(value) end,
        width = "full",
    },
    {
        type = "checkbox",
        name = "Show only when Fury is active",
        tooltip = "",
        getFunc = function() return GetShowOnlyWhenActive() end,
        setFunc = function(value) SetShowOnlyWhenActive(value) end,
        width = "full",
    },
    {
        type = "checkbox",
        name = "Play an alert sound when max stacks are reached",
        tooltip = "",
        getFunc = function() return GetPlaySoundAtMaxStacks() end,
        setFunc = function(value) SetPlaySoundAtMaxStacks(value) end,
        width = "full",
    },
    {
      type = "slider",
      name = "Scale",
      tooltip = "",
      min = 50,
      max = 200,
      step = 10,
      getFunc = function() return GetScale() end,
      setFunc = function(value) SetScale(value) end,
    }
  }

  LAM:RegisterAddonPanel(DwFury.name.."Settings", panel)
  LAM:RegisterOptionControls(DwFury.name.."Settings", options)
end
