--[[
MIT License
Copyright (c) 2022 UnusualPi
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local LGH = LibHistoire
local LAM = LibAddonMenu2

local GBK = {}
GBK.name = "GuildBookkeeper"
GBK.version = "0.0.6"
GBK.author = 'ArcHouse'
GBK.saveVars = 'GuildBookkeeperVariables'
GBK.default = {guilds={}, ledger={}}
GBK.listeners = {}

function GBK.Msg(text, type) -- Make text coloring easy & standard by passing a message type.
  -- https://www.color-hex.com/color-palette/1015961
  if type == 'info' then
    d('[' .. GBK.name ..'] ' .. '|cfff85c' .. text .. '|r')
  elseif type == 'emph' then
    d('[' .. GBK.name ..'] ' .. '|c00b8ff' .. text .. '|r')
  elseif type == 'warn' then
    d('[' .. GBK.name ..'] ' .. '|cfb9e30' .. text .. '|r')
  elseif type == 'err' then
    d('[' .. GBK.name ..'] ' .. '|cff2f82' .. text .. '|r')
  end
end

function GBK.OnAddOnLoaded(event, addonName)
  if addonName == GBK.name then
    GBK:Initialize()
    EVENT_MANAGER:UnregisterForEvent(GBK.name, EVENT_ADD_ON_LOADED)
  end
end

function GBK.Initialize()
  EVENT_MANAGER:RegisterForEvent('GBK-initmsg', EVENT_PLAYER_ACTIVATED, GBK.InitMsg)
  EVENT_MANAGER:RegisterForEvent('GBK-ListenerState', EVENT_PLAYER_ACTIVATED, GBK.GetListenerState)
  GBK.GuildInfo()
  GBK.savedVariables=ZO_SavedVars:NewAccountWide(GBK.saveVars, 1, nil, GBK.default)
  GBK.SetupListeners()
  GBK.InitSettingMenu()
end

function GBK.InitMsg()
  GBK.Msg('v'..GBK.version..' add-on initializing...', 'info')
  EVENT_MANAGER:UnregisterForEvent('GBK-initmsg', EVENT_PLAYER_ACTIVATED)
end

function GBK.GuildInfo()
  for i=1, GetNumGuilds() do
    local guildId = GetGuildId(i)
    local guildName = GetGuildName(guildId)
    GBK.default['guilds'][guildId] = {guildName=guildName, enabled = false, lastEvent=nil, lookBackPeriod = 31}
    GBK.default['ledger'][guildName] = {}
  end
end

function GBK:GetTamrielTradeCentrePrice(itemLink)
  local priceStats = {}
  if not TamrielTradeCentrePrice then -- if TTC not installed
    priceStats['AmountCount'] = 'TTC not installed'
    priceStats['Avg'] = ''
    priceStats['SuggestedPrice'] = ''
  else
    local ttcPrices = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
    -- Line 22 of TamrielTradeCentrePrice.lua
    if ttcPrices == nil then
      priceStats['AmountCount'] = 'No TTC records'
      priceStats['Avg'] = ''
      priceStats['SuggestedPrice'] = ''
    else
      priceStats['AmountCount'] = ttcPrices['AmountCount']
      priceStats['Avg'] = ttcPrices['Avg']
      priceStats['SuggestedPrice'] = ttcPrices['SuggestedPrice']
    end
  end
  return priceStats
end

function GBK:GetMmPrice(itemLink) -- Prices pull from MM's "Default Days Range"
  local priceStats={}
  if not MasterMerchant then -- If MM not installed
    priceStats['numDays'] = ''
    priceStats['avgPrice'] = ''
    priceStats['numSales'] = 'MM not installed'
  else
    local mmStats = MasterMerchant:itemStats(itemLink, false)
    -- line 76 of MasterMerchant_Alias.lua which actually just returns the
    -- output from MasterMerchant:GetTooltipStats() on line 312 of MasterMerchant.lua
    -- continue to use `itemStats` for now since its recommended, but may not be
    -- needed in future.
    if mmStats['numSales'] == nil then
      priceStats['numDays'] = ''
      priceStats['avgPrice'] = ''
      priceStats['numSales'] = 'No MM sales'
    else
      priceStats['numDays'] = mmStats['numDays']
      priceStats['avgPrice'] = mmStats['avgPrice']
      priceStats['numSales'] = mmStats['numSales']
    end
  end
  return priceStats
end

function GBK:CheckExists(eventId, guildId, guildName)
  local e = false
  for k,v in pairs(GBK.savedVariables['ledger'][guildName]) do
    if v.transactionId == Id64ToString(eventId) then
      e = true break
    end
  end
  return e
end

function GBK.SetupListeners()
  for guildId,v in pairs(GBK.default['guilds']) do
    local guildName = GBK.default['guilds'][guildId]['guildName']
    GBK.SetupListener(guildId, guildName)
    if GBK.savedVariables['guilds'][guildId]['enabled'] == true then
      -- Guild listener should default to inactive, user should enabled in settings.
      GBK.listeners[guildId]:Start()
    end
  end
end

function GBK.SetupListener(guildId, guildName)
    GBK.listeners[guildId] = LGH:CreateGuildHistoryListener(guildId, GUILD_HISTORY_BANK)
    if GBK.savedVariables['guilds'][guildId]['lastEvent'] ~= nil then
      GBK.listeners[guildId]:SetAfterEventId(StringToId64(GBK.savedVariables['guilds'][guildId]['lastEvent']))
    else
      local minTs = os.time()-(GBK.savedVariables['guilds'][guildId]['lookBackPeriod']*86400)
      GBK.listeners[guildId]:SetAfterEventTime(minTs)
    end
    GBK.listeners[guildId]:SetNextEventCallback(function(eventType, eventId, eventTime, param1, param2, param3, param4, param5, param6)
      -- https://github.com/sirinsidiator/ESO-LibHistoire/blob/536e39d6313116b84f7dfa6e4f31c46047d8b6ff/src/guildHistoryCache/GuildHistoryEventListener.lua#L202
      local ttc = GBK:GetTamrielTradeCentrePrice(param3)
      local mm = GBK:GetMmPrice(param3)
      local typeId = eventType

      -- https://wiki.esoui.com/Constant_Values
      if typeId == 13 then typeName = 'Credit' typeDesc = 'Item Deposited' -- GUILD_EVENT_BANKITEM_ADDED
      elseif typeId == 14 then typeName = 'Debit' typeDesc = 'Item Withdrawn' -- GUILD_EVENT_BANKITEM_REMOVED
      elseif typeId == 21 then typeName = 'Credit' typeDesc = 'Gold Deposited'-- GUILD_EVENT_BANKGOLD_ADDED
      elseif typeId == 22 then typeName = 'Debit' typeDesc = 'Gold Withdrawn'-- GUILD_EVENT_BANKGOLD_REMOVED
      elseif typeId == 29 then typeName = 'Credit' typeDesc = 'Store Tax'-- GUILD_EVENT_BANKGOLD_GUILD_STORE_TAX
      elseif typeId == 29 then typeName = 'Credit'  typeDesc = 'Kiosk Bid'-- GUILD_EVENT_BANKGOLD_KIOSK_BID
      elseif typeId == 23 then typeName = 'Debit'  typeDesc = 'Kiosk Bid Refund'-- GUILD_EVENT_BANKGOLD_KIOSK_BID_REFUND
      elseif typeId == 26 then typeName = 'Credit'  typeDesc = 'Heraldry Purchase'-- GUILD_EVENT_BANKGOLD_PURCHASE_HERALDRY
      else typeId = ''
      end

      if typeId == 13 or typeId == 14 then
        -- TODO: Need to validate table structure below will handle all Event Types listed above.
        -- Only tested for types 13 & 14 so ignoring all others for now.
        t = {transactionId = Id64ToString(eventId)
              , transactionType = typeName
              , transactionDescription = typeDesc
              , typeId = eventType
              , transactionTimestamp = eventTime
              , transactionDatetime = os.date('%Y-%m-%d %H:%M:%S', eventTime)
              , guildMember = param1
              , itemId = GetItemLinkItemId(param3)
              , transactionQuantity = param2
              , itemName = GetItemLinkName(param3)
              , itemQuality = GetItemLinkQuality(param3)
              , itemTrait = GetItemLinkTraitType(param3)
              , itemCp = GetItemLinkRequiredChampionPoints(param3)
              , itemLevel = GetItemLinkRequiredLevel(param3)
              , ttcNumListings = ttc['AmountCount']
              , ttcAvg = ttc["Avg"]
              , ttcSuggested = ttc["SuggestedPrice"]
              , mmAvg = mm['avgPrice']
              , mmNumDays = mm['numDays']
              , mmNumSales = mm['numSales']
              , itemLink = param3
              , key = GBK.listeners[guildId]:GetKey()
            }
        if GBK:CheckExists(eventId, guildId, guildName) == false then
          -- !!THIS IS O(n), but good enough for now
          table.insert(GBK.savedVariables['ledger'][guildName], t)
        end
        GBK.savedVariables['guilds'][guildId]['lastEvent'] = Id64ToString(eventId)
      end
    end)
end
-------------------
--- SETTINGS UI ---
-------------------
function GBK:GetListenerState()
  for guildId,v in pairs(GBK.savedVariables['guilds']) do
    local guildName = GBK.default['guilds'][guildId]['guildName']
    local state = 'Dormant.'
    if GBK.listeners[guildId]:IsRunning() == true then
      state = 'Active.'
      GBK.Msg(guildName .. ': ' .. state, 'emph')
    else
      GBK.Msg(guildName .. ': ' .. state, 'warn')
    end
  end
  EVENT_MANAGER:UnregisterForEvent('GBK-ListenerState', EVENT_PLAYER_ACTIVATED, GBK.GetListenerState)
end

function GBK:ToggleListenerState(guildId)
  if GBK.listeners[guildId]:IsRunning() == true then
    GBK.listeners[guildId]:Stop()
    GBK.savedVariables['guilds'][guildId]['enabled'] = false
  else
    GBK.listeners[guildId]:Start()
    GBK.savedVariables['guilds'][guildId]['enabled'] = true
  end
  GBK:GetListenerState()
end

function GBK:ClearGuildLedger(guildId, guildName)
  GBK.savedVariables['guilds'][guildId]['lastEvent'] = nil
  local tt = GBK.savedVariables['ledger'][guildName]
  for i=1, #tt do
    tt[i] = nil
  end
  GBK.Msg('Ledger for ' .. guildName .. ' cleared.', 'err')
end

function GBK.UpdateLookback(guildId, guildName, days)
  GBK.savedVariables['guilds'][guildId]['lookBackPeriod'] = days
  GBK:ClearGuildLedger(guildId, guildName) -- meh, good enough, force reloadui.
end

function GBK:InitSettingMenu()
	local panelData = {
		type = "panel"
		, name = "Guild Bookkeeper"
		, author = GBK.author
		, version = GBK.version
    , registerForRefresh = true
    , registerForDefaults= false
	}

  local optionsTable = {
    [1] = {
      type = "header",
      name = "Utilities",
      width = "full"
    },
    [2] = {
      type = "button",
      name = "Show States",
      tooltip = "Display listener states in chat.",
      func = function() GBK:GetListenerState() end
    },
  }
  for guildId,v in pairs(GBK.default['guilds']) do
    local guildName = GBK.default['guilds'][guildId]['guildName']
    table.insert(optionsTable,
      {
        type = 'header',
        name = guildName .. ' Options',
        width = 'full'
      }
    )
    table.insert(optionsTable,
      {
        type = 'checkbox',
        name = 'Monitoring',
        tooltip = 'Enable monitoring for '.. guildName,
        getFunc = function() return GBK.listeners[guildId]:IsRunning() end,
        setFunc = function(v) GBK:ToggleListenerState(guildId) end
      }
    )
    table.insert(optionsTable,
      {
        type = "slider",
        name = "Lookback Days",
        requiresReload = true,
        getFunc = function() return GBK.savedVariables['guilds'][guildId]['lookBackPeriod'] end,
        setFunc = function(value) GBK.UpdateLookback(guildId, guildName, value) end,
        min = 1,
        max = 365,
        default = GBK.defaultLookback,
        reference = guildName.."Lookback Days"
      }
    )
    table.insert(optionsTable,
      {
        type = 'button',
        name = 'Clear Ledger',
        warning = 'Clears all data for ' .. guildName,
        func = function() GBK:ClearGuildLedger(guildId, guildName) end
      }
    )
  end
  LAM:RegisterAddonPanel("Guild Bancair", panelData)
  LAM:RegisterOptionControls("Guild Bancair", optionsTable)
end
--------------------
--- /SETTINGS UI ---
--------------------
EVENT_MANAGER:RegisterForEvent(GBK.name, EVENT_ADD_ON_LOADED, GBK.OnAddOnLoaded)
