SetContainerCollector = SetContainerCollector or {}
local SCC = SetContainerCollector

SCC.Name = "SetContainerCollector"
SCC.DisplayName = "Set Container Collector"
SCC.Author = "sivaDog"
SCC.Version = "1.0.1"

SCC.defaultSetting = {
  auto_resolve = true,
  tooltip_font_size = 18,
  colorKnown = 0x55ff1c,
  colorPartial = 0x3399FF,
  colorUnknown = 0x777766,
}

local SAVED_VARS_NAME = "SetContainerCollectorSavedVariables"
local SAVED_VARS_VERSION = 2

local function MigrateLegacySavedVariables(savedVariables)
  if savedVariables.migratedServerScope then return end

  local legacy = ZO_SavedVars:NewAccountWide(
    SAVED_VARS_NAME,
    1,
    nil,
    SCC.defaultSetting
  )

  for key, defaultValue in pairs(SCC.defaultSetting) do
    if savedVariables[key] == nil and legacy[key] ~= nil and legacy[key] ~= defaultValue then
      savedVariables[key] = legacy[key]
    end
  end

  savedVariables.migratedServerScope = true
end

local function LoadSavedVariables()
  SCC.savedVariables = ZO_SavedVars:NewAccountWide(
    SAVED_VARS_NAME,
    SAVED_VARS_VERSION,
    nil,
    SCC.defaultSetting,
    GetWorldName()
  )

  MigrateLegacySavedVariables(SCC.savedVariables)
end

local function InitializeAfterLibSets()
  SCC.BuildPoolPieceCache()
  SCC.HookTooltips()
end

local function RegisterSettings()
  local panelData = {
    type = "panel",
    name = SCC.DisplayName,
    displayName = SCC.DisplayName,
    author = SCC.Author,
    version = SCC.Version,
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local options = {
    {
      type = "description",
      text = GetString(SI_SCC_SETTINGS_DESCRIPTION),
    },
    {
      type = "divider",
    },
    {
      type = "checkbox",
      name = GetString(SI_SCC_SETTINGS_AUTO_RESOLVE),
      tooltip = GetString(SI_SCC_SETTINGS_AUTO_RESOLVE_TT),
      getFunc = function() return SCC.IsAutoResolveEnabled() end,
      setFunc = function(value) SCC.savedVariables.auto_resolve = value end,
      default = SCC.defaultSetting.auto_resolve,
    },
    {
      type = "slider",
      name = GetString(SI_SCC_SETTINGS_TOOLTIP_FONT_SIZE),
      tooltip = GetString(SI_SCC_SETTINGS_TOOLTIP_FONT_SIZE_TT),
      min = 12,
      max = 28,
      step = 1,
      getFunc = function()
        return SCC.savedVariables.tooltip_font_size or SCC.defaultSetting.tooltip_font_size
      end,
      setFunc = function(value)
        SCC.savedVariables.tooltip_font_size = value
      end,
      default = SCC.defaultSetting.tooltip_font_size,
      disabled = function() return IsInGamepadPreferredMode() end,
    },
    {
      type = "description",
      text = GetString(SI_SCC_SETTINGS_SLASH_HELP),
    },
  }

  LibAddonMenu2:RegisterAddonPanel(SCC.Name .. "Options", panelData)
  LibAddonMenu2:RegisterOptionControls(SCC.Name .. "Options", options)
end

local function OnSlashCommand(input)
  if input == nil or input == "" then
    d(GetString(SI_SCC_SLASH_POOL_USAGE))
    return
  end

  local poolKey = string.match(input, "^pool%s+(%S+)$")
  if poolKey then
    SCC.PrintPoolSummary(poolKey)
    return
  end

  local debugLink = string.match(input, "^debuglink%s+(.+)$")
  if debugLink then
    SCC.DebugItemLink(debugLink)
  end
end

local function RegisterSlashCommands()
  if IsConsoleUI() then return end

  if LibSlashCommander then
    local cmd = LibSlashCommander:Register()
    cmd:AddAlias("/scc")
    cmd:SetCallback(OnSlashCommand)
    cmd:SetDescription("Set Container Collector")
  else
    SLASH_COMMANDS["/scc"] = OnSlashCommand
  end
end

local function OnLoad(eventCode, name)
  if name ~= SCC.Name then return end
  EVENT_MANAGER:UnregisterForEvent(SCC.Name, EVENT_ADD_ON_LOADED)

  LoadSavedVariables()
  RegisterSettings()
  RegisterSlashCommands()
  SCC.WaitForLibSets(InitializeAfterLibSets)
end

EVENT_MANAGER:RegisterForEvent(SCC.Name, EVENT_ADD_ON_LOADED, OnLoad)
