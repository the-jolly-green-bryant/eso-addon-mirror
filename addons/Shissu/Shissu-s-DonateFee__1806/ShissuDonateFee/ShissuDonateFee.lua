local setPanel = ShissuFramework["setPanel"]
local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local yellow = _globals["yellow"]
local goldSymbol = _globals["goldSymbol"]

local _addon = {}
_addon.Name = "ShissuDonateFee"
_addon.Version = "1.1.0"
_addon.formattedName	= stdColor .. "Shissu" .. white .. "'s Donate/Fee"

local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version)
_addon.controls = {}

_addon.chatReminder = 100
_addon.historyOpen = false

local SDF_MANUAL = 0
local SDF_CONFIRM = 1

function _addon.createGuildVar(guildName)
  if shissuDonateFee[guildName] == nil then 
    shissuDonateFee[guildName] = {}
  end
  
  if shissuDonateFee[guildName]["days"] == nil then 
    shissuDonateFee[guildName]["days"] = 7
  end
  
  if shissuDonateFee[guildName]["data"] == nil then 
    shissuDonateFee[guildName]["data"] = {}
  end
end

function _addon.createSettings()
  local controls = _addon.controls 
  
  -- Beschreibung
  controls[#controls+1] = {
    type = "description",
    text = string.format(_L("DESC1"), stdColor, "|cFA8072"),
  }   
  controls[#controls+1] = {
    type = "description",
    text = _L("DESC2"),
  } 
  controls[#controls+1] = {
    type = "description",
    text = stdColor .. _L("DESC3"),
  } 
  controls[#controls+1] = {
    type = "description",
    text = _L("DESC4"),
  } 

  -- Allgemeines
  controls[#controls+1] = {
    type = "title",
    name = _L("GENERAL"),
  } 

  if (shissuDonateFee["chatReminderHour"] == nil ) then
    shissuDonateFee["chatReminderHour"] = 1
  end
  
  if (shissuDonateFee["chatAutoDialog"] == nil ) then
    shissuDonateFee["chatAutoDialog"] = true
  end
  
  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("SET_AUTODIALOG"),
    tooltip = _L("SET_AUTODIALOG_TT"),
    getFunc = shissuDonateFee["chatAutoDialog"],
    setFunc = function(_, value)   
      shissuDonateFee["chatAutoDialog"] = value
    end,
  }      

  controls[#controls+1] = {
    type = "slider", 
    name = _L("SET_CHAT2"),
    minimum = 1,
    maximum = 120,
    steps = 1,
    getFunc = shissuDonateFee["chatReminderHour"],
    setFunc = function(value)
      shissuDonateFee["chatReminderHour"] = value      
    end,
  }      

  -- Turnus
  controls[#controls+1] = {
    type = "title",
    name = _L("SET_FREQ"),
  } 

  local numGuild = GetNumGuilds()
    
  for guildId = 1, numGuild do
    local guildId = GetGuildId(guildId)
    local guildName = GetGuildName(guildId)  

    controls[#controls+1] = {
      type = "title",
      name = stdColor .. guildName,
    }

    local guildEnabled = false
    local guildGold = 2000
    local guildDays = 7

    if ( shissuDonateFee[guildName] ~= nil )then
      guildEnabled = shissuDonateFee[guildName]["enabled"]
      guildGold = shissuDonateFee[guildName]["gold"]
      guildDays = shissuDonateFee[guildName]["days"]
    end

    controls[#controls+1] = {
      type = "checkbox",                                                                            
      name = _L("SET_AUTO"),
      tooltip = string.format(_L("SET_AUTO_TT"), stdColor .. guildName .. "|r"),
      getFunc = guildEnabled,
      setFunc = function(_, value)   
        _addon.createGuildVar(guildName)

        shissuDonateFee[guildName]["enabled"] = value
      end,
    }  

    controls[#controls+1] = {
      type = "sliderEditbox", 
      name = _L("SET_TIME"),
      tooltip = _L("SET_TIME_TT"),
      minimum = 1,
      maximum = 90,
      steps = 1,
      getFunc = guildDays,
      setFunc = function(value)
        _addon.createGuildVar(guildName)

        shissuDonateFee[guildName]["days"] = value      
      end,
    }      
  end
end
 
function _addon.refreshUI()
  if ( SHISSUDONATEFEEUI_MASTER ~= nil ) then
    zo_callLater(function() 
      if (SHISSUDONATEFEEUI_MASTER.Refresh ~= nil) then
        SHISSUDONATEFEEUI_MASTER:Refresh() 
      end
    end, 2000)
  end
end

-- d(os.date('%d.%m.%Y %H:%M:%S',shissuDonateFee["Tamrilando"]["nextAutoPay"]))

-- Erinnert den Spieler in einem variablen Zeitfenster alle 1-x (max 12h), dass
-- der Zeitraum für die Einzahlung überschritten ist. D.h. der Spieler hatte in x-Tagen
-- kein einziges mal das Gildenbank-Fenster offen!
function _addon.chatReminder()
    local timeStamp = GetTimeStamp()
    local numGuild = GetNumGuilds()

    for guildId = 1, numGuild do
      local guildId = GetGuildId(guildId)
      local guildName = GetGuildName(guildId)  

      if ( shissuDonateFee[guildName] ~= nil ) then
        if ( shissuDonateFee[guildName]["enabled"] == true and shissuDonateFee[guildName]["nextAutoPay"] ~= nil ) then
          if ( shissuDonateFee[guildName]["data"] ~= nil ) then 
            local gold = shissuDonateFee[guildName]["gold"] or 0
            local days = shissuDonateFee[guildName]["days"] or 0
            local dataLength = #shissuDonateFee[guildName]["data"]
            local data = shissuDonateFee[guildName]["data"][dataLength]     
            
            --d("Aktuell: " .. os.date('%d.%m.%Y %H:%M:%S', time))
            --d("Next: " .. os.date('%d.%m.%Y %H:%M:%S', shissuDonateFee[guildName]["nextAutoPay"]))
            
            if ( timeStamp >= shissuDonateFee[guildName]["nextAutoPay"]) then
                local textString = stdColor .. "[SDF] " .. yellow .. _L("CHAT_REMINDER") .. " " .. white .. "%s: " .. _L("CHAT_AUTO2")
                d(string.format(textString, guildName))

                if ( SHISSUDONATEFEEUI_MASTER ~= nil ) then
                  if (SHISSUDONATEFEEUI_MASTER.Refresh ~= nil) then
                    SHISSUDONATEFEEUI_MASTER:Refresh() 
                  end
                end
            end
          end
        end
    end
  end
end

function _addon.getManualGold(guildName)
  local manualGold = 0

  if ( shissuDonateFee[guildName] ~= nil ) then
    if ( shissuDonateFee[guildName]["data"] ~= nil and shissuDonateFee[guildName]["lastAutoPay"] ~= nil) then 
      local dataLength = #shissuDonateFee[guildName]["data"]
        
      for dataId = 1, dataLength do
        data = shissuDonateFee[guildName]["data"][dataId]

        if ( data[3] == SDF_MANUAL and data[1] >= shissuDonateFee[guildName]["lastAutoPay"]) then
          manualGold = manualGold + data[2]
        end
      end
    end
  end

  return manualGold
end

local overrideZOSDialog = false

-- Update: 24.03.2018
-- 
-- Grundlegende Überarbeitung
-- SDF Fenster wird nur automatisch geöffnet, wenn Spieler es sich in den Einstellungen wünscht.
function _addon.openUI()
  if ( shissuDonateFee["chatAutoDialog"] == true ) then  
    if ( ZO_GuildHistory:IsHidden() == false ) then
      local control = GetControl("ShissuDonateFeeUI")
  
      if ( control:IsHidden() and _addon.historyOpen == false) then
        control:SetHidden(false)
        _addon.historyOpen = true
      end
    else
      _addon.historyOpen = false
    end
  end

  if ( GUILD_BANKCurrencyTransferDialog ~= nil) then
    if ( GUILD_BANKCurrencyTransferDialog["info"] ~= nil ) then
      if ( GUILD_BANKCurrencyTransferDialog["info"]["buttons"] ~= nil ) then
        if ( GUILD_BANKCurrencyTransferDialog["info"]["buttons"][1] ~= nil ) then
          depositAllow = false
           
          if (ZO_KeybindStripButtonTemplate2NameLabel ~= nil ) then
            local guildName = ZO_KeybindStripButtonTemplate2NameLabel:GetText()
            local numGuilds = GetNumGuilds()
            local historyAllow = false

            for guildId=1, numGuilds do
              local guildId = GetGuildId(guildId)
              local guildName2 = GetGuildName(guildId)

              if ( guildName2 == guildName ) then
    	          depositAllow = DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_DEPOSIT)
                --
                break
              end
            end

            -- 6395 == Währung einlagern
            local dialogTitle = GUILD_BANKCurrencyTransferDialog["info"]["title"].text
            
            -- 6393 == Einlagern
            local dialogButton = GUILD_BANKCurrencyTransferDialog["info"]["buttons"][1].text

            if ( overrideZOSDialog == false and dialogButton == 6393 and dialogTitle == 6395 and depositAllow == true) then          
              local ZOS_CALLBACK = GUILD_BANKCurrencyTransferDialog["info"]["buttons"][1].callback

              GUILD_BANKCurrencyTransferDialog["info"]["buttons"][1].callback = function(dialog)
                local guildName = ZO_KeybindStripButtonTemplate2NameLabel:GetText()

                -- GUILD_PERMISSION_BANK_DEPOSIT
                local gold = ZO_DefaultCurrencyInputField_GetCurrency(GUILD_BANKCurrencyTransferDialogContainerDepositWithdrawCurrency)
                local timeStamp = GetTimeStamp()

                _addon.createGuildVar(guildName)
                local data = shissuDonateFee[guildName]["data"]

                table.insert(data, {timeStamp, gold, 0, SDF_MANUAL})
                
                if (shissuDonateFee[guildName]["days"] == nil ) then 
                  shissuDonateFee[guildName]["days"] = 7
                end

                shissuDonateFee[guildName]["nextAutoPay"] = timeStamp + ( shissuDonateFee[guildName]["days"] * ( 60 * 60 * 24) )
                
                if (SHISSUDONATEFEEUI_MASTER) then
                  SHISSUDONATEFEEUI_MASTER:Refresh()
                end

                -- Original ZOS Funktion ausführen
                ZOS_CALLBACK(dialog)
              end

              -- Fenster schließen und öffnen, damit die Änderungen für die aktuelle Session gültig werden!
              GUILD_BANKCurrencyTransferDialog["info"]["buttons"][2]["control"]:OnClicked()
              ZO_KeybindStripButtonTemplate3:OnClicked()
              overrideZOSDialog = true
            end
          end
        end
      end
    end
  end
end

function _addon.initTimers()
  if (shissuDonateFee["chatReminderHour"] == nil ) then
    shissuDonateFee["chatReminderHour"] = 1
  end

  _addon.chatReminder()
  EVENT_MANAGER:RegisterForUpdate("SDF_CHECK_CHATREMINDER", 1000 * 60 * shissuDonateFee["chatReminderHour"], _addon.chatReminder)
  EVENT_MANAGER:RegisterForUpdate("SDF_CHECK_OPENUI", 50, _addon.openUI)
end

function _addon.initHistoryCheck()
  GUILD_HISTORY.nextRequestNewestTime = 0

  _addon.repeatHistory()

  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_HISTORY_RESPONSE_RECEIVED, _addon.historyResponseReceived)
end

function _addon.repeatHistory()
  zo_callLater(function()
    local numGuild = GetNumGuilds()

    for guildId = 1, numGuild do
      local showAllow = DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_VIEW_DEPOSIT_HISTORY)

      if ( showAllow == true ) then
        RequestGuildHistoryCategoryNewest(GetGuildId(guildId), GUILD_HISTORY_BANK)
      end
    end
  end, 1000)
end

-- Update: 24.03.2018
-- 
-- Daten werden beim Lesen der History nun in der Zukunft direkt erfasst und als bestätigt angesehen (geht nur wenn Spieler Rechte hierzu hat)
function _addon.historyResponseReceived(eventCode, guildId, category)
  if (category ~= GUILD_HISTORY_BANK) and guildId ~= nil then 
    return 
  end

  local numEvents = GetNumGuildEvents(guildId, category)  
  local showAllow = DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_VIEW_DEPOSIT_HISTORY)
   
  if ( showAllow == false ) then return end
  if (numEvents == 0) then return end

  local guildName = GetGuildName(guildId)
  local last = 1
  local inc = -1

  -- Einzelne Events in den Aufzeichnungen abarbeiten
  for eventId = numEvents, 1, -1 do
    local eventType, eventTime, displayName, eventGold = GetGuildEventInfo(guildId, category, eventId)         
                                     
    local timeStamp = GetTimeStamp() - eventTime

    if (eventType == GUILD_EVENT_BANKGOLD_ADDED and displayName == GetDisplayName()) then
      --d("GILDE " .. guildName .. " EINZAHLER: " .. displayName .. " GOLD: " .. eventGold .. " EVENTTIME " .. eventTime .. " TIMESTAMP: " .. timeStamp)
  
      _addon.createGuildVar(guildName)
      local data = shissuDonateFee[guildName]["data"]

      -- Existiert schon
      local existData = false
      
      for dataId = 1, #data do
        if ( data[dataId][1] == timeStamp ) then
          existData = true
          
          -- Bestätigung durch die Gildenaufzeichnungen
          if ( data[dataId][4] == nil or ( data[dataId][1] >= timeStamp - 7 and data[dataId][1] <= timeStamp + 7 ) ) then
            data[dataId][4] = 1
          end
          
          break
        end
      end 
      
      if (existData == false) then
        table.insert(data, {timeStamp, eventGold, 0, SDF_CONFIRM})   
        
        local nextDonateReminder = shissuDonateFee[guildName]["nextAutoPay"]
        local nextDonate = timeStamp + ( shissuDonateFee[guildName]["days"] * ( 60 * 60 * 24) )
               
        if ( nextDonate > nextDonateReminder ) then 
          --d( os.date('%d.%m.%Y %H:%M:%S', nextDonate) )
          shissuDonateFee[guildName]["nextAutoPay"] = nextDonate
        end
      end
    end
  end
end 

function _addon.initialized()
  -- Einstellungen in Zusammenarbeit mit ShissuSuiteManager
  _addon.createSettings()
  
  -- Initialisierung Grundfunktion: Automatisches Einzahlen bei geöffneter Gildenbank
  _addon.initHistoryCheck()
  
  _addon.initTimers()
end

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end

  shissuDonateFee = shissuDonateFee or {}

  zo_callLater(function()               
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    ShissuFramework.initAddon(_addon.Name, _addon.initialized, _addon.formattedName .. " " .. _addon.Version)
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end 

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)