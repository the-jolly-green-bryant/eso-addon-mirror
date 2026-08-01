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
local SDF_AUTO = 1

function _addon.createGuildVar(guildName)
  if shissuDonateFee[guildName] == nil then 
    shissuDonateFee[guildName] = {}
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
    guildId = GetGuildId(guildId)
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
 -- if (shissuDonateFee["chatReminder"] == true ) then
    local timeStamp = GetTimeStamp()
    local numGuild = GetNumGuilds()

    for guildId = 1, numGuild do
      guildId = GetGuildId(guildId)
      local guildId = GetGuildId(guildId)
      local guildName = GetGuildName(guildId)  

      if ( shissuDonateFee[guildName] ~= nil ) then
        if ( shissuDonateFee[guildName]["enabled"] == true and shissuDonateFee[guildName]["nextAutoPay"] ~= nil ) then
          if ( shissuDonateFee[guildName]["data"] ~= nil ) then 
            local gold = shissuDonateFee[guildName]["gold"] or 0
            local days = shissuDonateFee[guildName]["days"] or 0
            local dataLength = #shissuDonateFee[guildName]["data"]
            local data = shissuDonateFee[guildName]["data"][dataLength]  

            if ( timeStamp >= shissuDonateFee[guildName]["nextAutoPay"]) then --shissuDonateFee[guildName]["nextAutoPay"]] ) then
              --local manual = _addon.getManualGold(guildName)
              --local payedFor = 0
              
              -- Vorauszahlungen berücksichtigen
             -- if (shissuDonateFee[guildName]["lastAutoPay"] ~= nil) then
              --  payedFor = math.floor ( manual / gold )
            --  end

              -- Wenn payedFor kleiner 1, fand bisher keine Einzahlung oder zu wenig statt!
           --   if (payedFor < 1 and payedFor > 0) then
             --   local restGold = ( shissuDonateFee[guildName]["gold"] - manual)
             --   local textString = "|cAFD3FF[SDF] |cFA8072" .. _L("REMINDER") .. " |ceeeeee%s: " .. _L(CHAT_AUTO1) 

            --    d(string.format(textString, guildName, manual .. goldSymbol, "|cFA8072" .. restGold .. goldSymbol))

           --   elseif ( payedFor == 0) then
                local textString = stdColor .. "[SDF] " .. yellow .. _L("CHAT_REMINDER") .. " " .. white .. "%s: " .. _L("CHAT_AUTO2")
                d(string.format(textString, guildName))

                if ( SHISSUDONATEFEEUI_MASTER ~= nil ) then
                  if (SHISSUDONATEFEEUI_MASTER.Refresh ~= nil) then
                    SHISSUDONATEFEEUI_MASTER:Refresh() 
                  end
                end
                
             -- end
            end
          end
        end
    --  end
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

function _addon.openUI()
  -- SDF Fenster öffnen, beim Öffnen der History
  if ( ZO_GuildHistory:IsHidden() == false ) then
    local control = GetControl("ShissuDonateFeeUI")

    if ( control:IsHidden() and _addon.historyOpen == false) then
      control:SetHidden(false)
      _addon.historyOpen = true
    end
  else
    _addon.historyOpen = false
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
	      guildId = GetGuildId(guildId)
              local guildId = GetGuildId(guildId)
              local guildName2 = GetGuildName(guildId)

              if ( guildName2 == guildName ) then
    	          depositAllow = DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_DEPOSIT)
                --
                break
              end
            end

            local titleText = GUILD_BANKCurrencyTransferDialog["info"]["buttons"][1].text
              
            if ( overrideZOSDialog == false and titleText == 6313 and depositAllow == true) then -- Einlagern
              local ZOS_CALLBACK = GUILD_BANKCurrencyTransferDialog["info"]["buttons"][1].callback

              GUILD_BANKCurrencyTransferDialog["info"]["buttons"][1].callback = function(dialog)
                local guildName = ZO_KeybindStripButtonTemplate2NameLabel:GetText()

                -- GUILD_PERMISSION_BANK_DEPOSIT
                local gold = ZO_DefaultCurrencyInputField_GetCurrency(GUILD_BANKCurrencyTransferDialogContainerDepositWithdrawCurrency)
                local timeStamp = GetTimeStamp()

                _addon.createGuildVar(guildName)
                shissuDonateFee[guildName]["data"] = shissuDonateFee[guildName]["data"] or {}
                local data = shissuDonateFee[guildName]["data"]

                table.insert(data, {timeStamp, gold, SDF_MANUAL})
                
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
      local showAllow = DoesPlayerHaveGuildPermission(GetGuildId(guildId), GUILD_PERMISSION_BANK_VIEW_DEPOSIT_HISTORY)

      if ( showAllow == true ) then
        RequestGuildHistoryCategoryNewest(GetGuildId(guildId), GUILD_HISTORY_BANK)
      end
    end
  end, 1000)
end

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
      --d(displayName)
      --d(eventGold)
     -- d(timeStamp)
      --d("----")

      _addon.createGuildVar(guildName)
      shissuDonateFee[guildName]["data"] = shissuDonateFee[guildName]["data"] or {}
      local data = shissuDonateFee[guildName]["data"]
      
      if ( data ~= nil ) then
        for dataId = 1, #data do
          if ( ( data[dataId][1] == timeStamp ) or ( data[dataId][1] >= timeStamp - 10 and data[dataId][1] <= timeStamp + 10 ) ) then
            if ( data[dataId][4] == nil ) then
            --d("GEFUNDEN HISTORY")
            data[dataId][4] = 1
            end
          end     
        end
      end
    end
  end
end 

function _addon.initialized()
  -- Einstellungen in Zusammenarbeit mit ShissuSuiteManager
  _addon.createSettings()
  
  -- Initialisierung Grundfunktion: Automatisches Einzahlen bei geöffneter Gildenbank
  _addon.initTimers()
  _addon.initHistoryCheck()
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