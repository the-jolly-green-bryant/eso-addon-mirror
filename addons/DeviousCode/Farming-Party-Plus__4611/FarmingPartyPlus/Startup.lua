local ADDON_NAME = 'FarmingPartyPlus'
local Addon = FarmingPartyPlus

local DIGIT_GROUP_REPLACER = ','
local DIGIT_GROUP_DECIMAL_REPLACER = '.'
local DIGIT_GROUP_REPLACER_THRESHOLD = zo_pow(10, GetDigitGroupingSize())
local READY_MESSAGE_DELAY_MS = 1500

local function LocalizeDecimalNumber(amount)
  if amount == 0 then
    amount = '0'
  end

  local amountNumber = tonumber(amount)
  if amountNumber >= DIGIT_GROUP_REPLACER_THRESHOLD then
    local decimalSeparatorIndex = zo_strfind(amount, '%' .. DIGIT_GROUP_DECIMAL_REPLACER)
    local decimalPartString = decimalSeparatorIndex and zo_strsub(amount, decimalSeparatorIndex) or ''
    local wholePartString = zo_strsub(amount, 1, decimalSeparatorIndex and decimalSeparatorIndex - 1)

    amount = ZO_CommaDelimitNumber(tonumber(wholePartString)) .. decimalPartString
  end

  return amount
end

function Addon.FormatNumber(num)
  return LocalizeDecimalNumber(string.format('%0.' .. (Addon.Settings:ValueDecimals() or 2) .. 'f', num))
end

local function OnPlayerDeactivated()
  Addon:Finalize()
end

local function GetTrackingStatusText()
  if Addon.Settings ~= nil and Addon.Settings:Status() == Addon.Settings.TRACKING_STATUS.ENABLED then
    return 'tracking on'
  end
  return 'tracking off'
end

function Addon:OnAddOnLoaded(event, addonName)
  if addonName ~= ADDON_NAME then
    return
  end

  ZO_CreateStringId('SI_BINDING_NAME_TOGGLE_TRACKING_PLUS', 'Toggle FPP Loot Tracking')
  ZO_CreateStringId('SI_BINDING_NAME_TOGGLE_SCOREBOARD_PLUS', 'Toggle FPP Scoreboard')
  ZO_CreateStringId('SI_BINDING_NAME_TOGGLE_COMPACT_SCOREBOARD_PLUS', 'Toggle FPP Compact Scoreboard')
  ZO_CreateStringId('SI_BINDING_NAME_TOGGLE_ITEM_BREAKDOWN_PLUS', 'Toggle FPP Item Breakdown')
  ZO_CreateStringId('SI_BINDING_NAME_TOGGLE_FILTERS_PLUS', 'Toggle FPP Filters')
  ZO_CreateStringId('SI_BINDING_NAME_TOGGLE_LOOT_HISTORY_PLUS', 'Toggle FPP Loot History')

  EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)
  EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
  Addon.Settings = FarmingPartyPlus.Classes.Settings:New()
  self:ConsoleCommands()
  self:Initialize()
  zo_callLater(function()
    d(string.format('[Farming Party Plus]: Ready. %s. Use /fpp for the scoreboard or /fpphelp for commands.', GetTrackingStatusText()))
  end, READY_MESSAGE_DELAY_MS)
end

function Addon:Finalize()
  for _, moduleObject in pairs(self.Modules) do
    moduleObject:Finalize()
  end

  if self.Settings:ResetStatusOnLogout() then
    self.Settings:ToggleStatusValue(FarmingPartyPlus.Settings.TRACKING_STATUS.DISABLED)
  end
end

function Addon:Initialize()
  self.Modules.MemberList = FarmingPartyPlus.Classes.MemberList:New()
  self.Modules.Logger = FarmingPartyPlus.Classes.Logger:New()
  self.Modules.MemberItems = FarmingPartyPlus.Classes.MemberItems:New()
  self.Modules.FilterWindow = FarmingPartyPlus.Classes.FilterWindow:New()
  self.Modules.Sync = FarmingPartyPlus.Classes.SyncHost:New()
  self.Modules.Loot = FarmingPartyPlus.Classes.Loot:New()
end

function Addon:Prune()
  self.Modules.MemberList:PruneMissingMembers()
  d('[Farming Party Plus]: Members have been pruned')
end

function Addon:UpdateMembers()
  self.Modules.MemberList:PruneMissingMembers()
  self.Modules.MemberList:AddAllGroupMembers()
  d('[Farming Party Plus]: Members have been updated')
end

function Addon:Reset()
  self.Modules.MemberList:Reset()
  if self.Modules.Loot ~= nil and self.Modules.Loot.ClearSessionState ~= nil then
    self.Modules.Loot:ClearSessionState()
  end
  if self.Modules.Sync ~= nil and self.Modules.Sync.ClearSessionState ~= nil then
    self.Modules.Sync:ClearSessionState()
  end
  d('[Farming Party Plus]: Tracking data has been reset')
end

function Addon:StartTracking()
  if FarmingPartyPlus.Settings:Status() == FarmingPartyPlus.Settings.TRACKING_STATUS.DISABLED then
    self.Modules.MemberList:AddEventHandlers()
    self.Modules.Loot:AddEventHandlers()
    FarmingPartyPlus.Settings:ToggleStatusValue(FarmingPartyPlus.Settings.TRACKING_STATUS.ENABLED)
  end
  d('[Farming Party Plus]: Tracking is on')
end

function Addon:StopTracking()
  self.Modules.MemberList:RemoveEventHandlers()
  self.Modules.Loot:RemoveEventHandlers()
  FarmingPartyPlus.Settings:ToggleStatusValue(FarmingPartyPlus.Settings.TRACKING_STATUS.DISABLED)
  d('[Farming Party Plus]: Tracking is off')
end

function Addon:ToggleTracking()
  if FarmingPartyPlus.Settings:Status() == FarmingPartyPlus.Settings.TRACKING_STATUS.ENABLED then
    self:StopTracking()
  else
    self:StartTracking()
  end
end

function Addon:ToggleMembersWindow()
  if self.Modules.MemberList ~= nil then
    self.Modules.MemberList:ToggleMembersWindow()
  end
end

function Addon:OpenFullScoreboard()
  if self.Modules.MemberList ~= nil and self.Modules.MemberList.OpenFullWindow ~= nil then
    self.Modules.MemberList:OpenFullWindow()
  end
end

function Addon:ToggleMemberItemsWindow()
  if self.Modules.MemberItems ~= nil then
    self.Modules.MemberItems:ToggleWindow()
  end
end

function Addon:OpenMemberItemsForKey(memberKey)
  if self.Modules.MemberItems ~= nil then
    self.Modules.MemberItems:SetAndToggle(memberKey)
  end
end

function Addon:ConsoleCommands()
  local function HandleMainCommand(param)
    local trimmedParam = string.gsub(param or '', '%s+$', ''):lower()
    if trimmedParam == '' then
      self.Modules.MemberList:ToggleMembersWindow()
    elseif trimmedParam == 'prune' then
      self:Prune()
    elseif trimmedParam == 'reset' then
      self:Reset()
    elseif trimmedParam == 'start' then
      self:StartTracking()
    elseif trimmedParam == 'stop' or trimmedParam == 'pause' then
      self:StopTracking()
    elseif trimmedParam == 'toggle' then
      self:ToggleTracking()
    elseif trimmedParam == 'status' then
      if Addon.Settings:Status() == Addon.Settings.TRACKING_STATUS.ENABLED then
        d('[Farming Party Plus]: Tracking is on')
      else
        d('[Farming Party Plus]: Tracking is off')
      end
    elseif trimmedParam == 'update' then
      self:UpdateMembers()
    elseif trimmedParam == 'filters' then
      self.Modules.FilterWindow:ToggleWindow()
    elseif trimmedParam == 'loot' or trimmedParam == 'log' then
      Addon.Settings:ToggleLootWindow()
    elseif trimmedParam == 'compact' then
      local isCompact = Addon.Settings:ToggleCompactMemberWindow()
      d(string.format('[Farming Party Plus]: Compact scoreboard mode %s', isCompact and 'is on' or 'is off'))
    elseif trimmedParam == 'compact on' then
      Addon.Settings:ToggleCompactMemberWindow(true)
      d('[Farming Party Plus]: Compact scoreboard mode is on')
    elseif trimmedParam == 'compact off' then
      Addon.Settings:ToggleCompactMemberWindow(false)
      d('[Farming Party Plus]: Compact scoreboard mode is off')
    elseif trimmedParam == 'whitelist on' then
      Addon.Settings:SetWhitelistMode(true)
      d('[Farming Party Plus]: Whitelist mode is on')
    elseif trimmedParam == 'whitelist off' then
      Addon.Settings:SetWhitelistMode(false)
      d('[Farming Party Plus]: Whitelist mode is off')
    elseif trimmedParam == 'help' then
      SLASH_COMMANDS['/fpphelp']()
    else
      d(string.format('Invalid parameter %s.', trimmedParam))
      SLASH_COMMANDS['/fpphelp']()
    end
  end

  SLASH_COMMANDS['/fpphelp'] = function()
    d('-- Farming Party Plus commands --')
    d('/fp                   Legacy alias for /fpp')
    d('/fpp                  Show or hide the highscore window.')
    d('/fpp prune            Removes members no longer in group.')
    d('/fpp reset            Resets all loot data.')
    d('/fpp [start]          Start loot tracking.')
    d('/fpp [stop]           Stop loot tracking.')
    d('/fpp toggle           Toggle loot tracking on or off.')
    d('/fpp [status]         Show loot tracking status.')
    d('/fpp update           Sync tracked members with current group.')
    d('/fpp filters          Open the node whitelist window.')
    d('/fpp loot             Show or hide the loot history window.')
    d('/fpp compact          Toggle compact scoreboard mode.')
    d('/fpp whitelist on     Count only selected whitelist items.')
    d('/fpp whitelist off    Use the original quality-based filters.')
    d('/fppc                 Put score output into the chat box.')
  end

  SLASH_COMMANDS['/fpp'] = HandleMainCommand
  SLASH_COMMANDS['/fp'] = HandleMainCommand

  SLASH_COMMANDS['/fppc'] = function()
    self.Modules.MemberList:PrintScoresToChat()
  end
  SLASH_COMMANDS['/fpc'] = SLASH_COMMANDS['/fppc']

  SLASH_COMMANDS['/fppm'] = function()
    self:ToggleMemberItemsWindow()
  end

  SLASH_COMMANDS['/fppfilters'] = function()
    self.Modules.FilterWindow:ToggleWindow()
  end

  SLASH_COMMANDS['/fpploot'] = function()
    Addon.Settings:ToggleLootWindow()
  end
end

EVENT_MANAGER:RegisterForEvent(
  ADDON_NAME,
  EVENT_ADD_ON_LOADED,
  function(...)
    Addon:OnAddOnLoaded(...)
  end
)
