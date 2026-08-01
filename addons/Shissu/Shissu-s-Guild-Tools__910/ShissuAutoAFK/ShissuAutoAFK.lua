-- Shissu AutoAFK
-- --------------
-- 
-- Desc:        Automatisches AFK/Online setzen nach X-Minuten
-- Filename:    ShissuAutoAFK.lua
-- Version:     1.4.2.1
-- Last Update: 21.11.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local yellow = _globals["yellow"]
local setPanel = ShissuFramework["setPanel"]
local _P = ShissuFramework["functions"]["chat"].print

local _offline = PLAYER_STATUS_OFFLINE
local _online = PLAYER_STATUS_ONLINE
local _dnd = PLAYER_STATUS_DO_NOT_DISTURB
local _away = PLAYER_STATUS_AWAY
local _cache = PLAYER_STATUS_ONLINE

local _addon = {}
_addon.Name	= "ShissuAutoAFK"
_addon.Version = "1.4.2.1"
_addon.formattedName = stdColor .. "Shissu" .. white .. "'s AutoAFK"
_addon.controls = {}
_addon.lastUpdate = "21.11.2020"
_addon.settings = {
  ["enabled"] = true,
  ["autoOnline"] = true,
  ["whisperOnline"] = true,
  ["reminderOffline"] = true,
  ["reminderOfflineTime"] = 10,
  ["time"] = 20,
}              

local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version, _addon.lastUpdate)

function _addon.setOnline()
  local currentStatus = GetPlayerStatus()

  if ( shissuAutoAFK["autoOnline"] and currentStatus == _offline ) then
    SelectPlayerStatus(_online)
  end
end

function _addon.isAutoAFK()
  if ( shissuAutoAFK["enabled"] ) then
    EVENT_MANAGER:UnregisterForUpdate("ShissuGT_AutoAFK")
    local currentStatus = GetPlayerStatus() 

    if currentStatus == _online or currentStatus == _dnd then
      _addon.autoAFK()
    end
  end
end

-- Bewegungen in der UI / Bewegung im Sichtfeld?
function _addon.EVENT_UI_MOVEMENT(eventCode)
  _addon.setOnline()
  
  local currentStatus = GetPlayerStatus()

  if (shissuAutoAFK["enabled"] and currentStatus == _away) then 
    SelectPlayerStatus(_cache)
    _addon.autoAFK()
  end
end

function _addon.autoAFK()
  local _minute = shissuAutoAFK["time"] or 1
  
  EVENT_MANAGER:RegisterForUpdate("ShissuGT_AutoAFK", _minute * 60 * 1000 , function()
    local currentStatus = GetPlayerStatus()
    local notMoving = not IsPlayerMoving() 

    if notMoving and (currentStatus == _online or currentStatus == _dnd) then
      EVENT_MANAGER:UnregisterForUpdate("ShissuGT_AutoAFK")
      SelectPlayerStatus(_away)
    end           
  end)
end

-- AutoAFK: Spielerstatus -> AFK -> Online/BRB
function _addon.EVENT_PLAYER_STATUS_CHANGED(eventCode, oldStatus, newStatus)
  _addon.cacheStatus = oldStatus

  if ( shissuAutoAFK["reminderOffline"] and newStatus == _offline) then
    _addon.reminderOffline()
  end                        

  if shissuAutoAFK["enabled"] then
    if newStatus == _away then
      EVENT_MANAGER:RegisterForUpdate("ShissuGT_AutoAFK", 500, function()
        local currentStatus = GetPlayerStatus()
        local moving = not IsPlayerMoving()     
        
        if IsPlayerMoving() and currentStatus == _away then
          SelectPlayerStatus(_cache)
          EVENT_MANAGER:UnregisterForUpdate("ShissuGT_AutoAFK")
        end         
      end)                                            
    elseif newStatus == _online or newStatus == _dnd then
      _cache = newStatus
    end
    
    _addon.autoAFK()
  end     
end

-- Automatische Erinnerung alle shissuAutoAFK["reminderOfflineTime"]-Minuten
function _addon.reminderOffline()
  local _minute = shissuAutoAFK["reminderOfflineTime"]
  local currentStatus = GetPlayerStatus() 
  
  if ( currentStatus == _offline ) then
    EVENT_MANAGER:RegisterForUpdate("SGT_AutoAFK_Reminder", _minute * 60 * 1000 , function()
      local currentStatus = GetPlayerStatus() 
      
      if ( currentStatus == _offline ) then
        _P(_L("INFOFFLINE"), {}, "SAAFK", _L("REMINDER"))
        _addon.setOnline()
      end 
    
      if ( shissuAutoAFK["reminderOffline"] == false ) then
        EVENT_MANAGER:UnregisterForUpdate("SGT_AutoAFK_Reminder")
      end
    end)
  end
end

function _addon.createSettingMenu()
  local controls = ShissuFramework._settings[_addon.Name].controls

  controls[#controls+1] = {
    type = "title", 
    name = _L("TITLE"),
  }
  
  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("AUTOAFK"),
    getFunc = shissuAutoAFK["enabled"],
    setFunc = function(_, value)
      shissuAutoAFK["enabled"] = value
      if (value) then _addon.autoAFK() end
    end,
  }

  controls[#controls+1] = {
    type = "slider", 
    name = _L("AUTOAFK") .. " " .. _L("MINUTE"),
    minimum = 1,
    maximum = 120,
    steps = 1,
    getFunc = shissuAutoAFK["time"],
    setFunc = function(value)
      shissuAutoAFK["time"] = value
      _addon.isAutoAFK()
    end,
  }  
                    
  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("AUTOONLINE"),
    reference = "ShissuAutoAFKSettingsAutoOnline",
    getFunc = shissuAutoAFK["autoOnline"],
    setFunc = function(_, value)
      shissuAutoAFK["autoOnline"] = value
      if (value) then _addon.reminderOffline() end
    end,
  }   

  controls[#controls+1] = {
    type = "title", 
    name = _L("REMINDER"),
  }

  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("REMINDER"),
    getFunc = shissuAutoAFK["reminderOffline"],
    setFunc = function(_, value)
      shissuAutoAFK["reminderOffline"] = value
      if (value) then _addon.setOnline() end
    end,
  }   
  
  controls[#controls+1] = {
    type = "slider", 
    name = _L("REMINDEROFFLINE").. " " .. _L("MINUTE"),
    minimum = 1,
    maximum = 120,
    steps = 1,
    getFunc = shissuAutoAFK["reminderOfflineTime"],
    setFunc = function(value)
      shissuAutoAFK["reminderOfflineTime"] = value
      
      if ( shissuAutoAFK["reminderOffline"] ) then
        EVENT_MANAGER:UnregisterForUpdate("SGT_AutoAFK_Reminder")
        _addon.reminderOffline()
      end  
    end,
  }   
end
                     
function _addon.initialized()
  -- Einstellungen
  shissuAutoAFK = shissuAutoAFK or _addon.settings
  if shissuAutoAFK["enabled"] == nil then shissuAutoAFK = _addon.settings end

  _addon.createSettingMenu()
  
  -- Tastenkombination
  ShissuFramework._bindings.SAAFK_autoOnline_toogle = function() 
    if shissuAutoAFK["autoOnline"] == true then 
      shissuAutoAFK["autoOnline"] = false
      _P(_L("OFF"), {}, "SAAFK", _L("AUTOONLINE"))
    else
      shissuAutoAFK["autoOnline"] = true
      _P(_L("ON"), {}, "SAAFK", _L("AUTOONLINE"))
    end

    if (ShissuAutoAFKSettingsAutoOnline ~= nil) then
      ShissuAutoAFKSettingsAutoOnline.checkbox.toogleFunction()
    end
  end

  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_NEW_MOVEMENT_IN_UI_MODE, _addon.EVENT_UI_MOVEMENT)
  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_RETICLE_HIDDEN_UPDATE, _addon.EVENT_UI_MOVEMENT)
  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_PLAYER_STATUS_CHANGED, _addon.EVENT_PLAYER_STATUS_CHANGED)

  _addon.isAutoAFK()  
  
  if ( shissuAutoAFK["reminderOffline"] ) then
    if ( currentStatus == _offline ) then
      _P(_L("INFOFFLINE"), {}, "SAAFK", _L("REMINDER"))
    end 
    
    _addon.reminderOffline()
  end      
end

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end

  zo_callLater(function()         
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end, 50) 

            
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end  

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)