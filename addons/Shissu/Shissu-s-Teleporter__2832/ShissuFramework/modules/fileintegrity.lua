-- Shissu Framework: Fileintegrity
-- -------------------------------
-- 
-- Filename:    modules/fileintegrity.lua
-- Version:     v1.0.0
-- Last Update: 19.11.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local setPanel = ShissuFramework["setPanel"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local red = _globals["red"]
local green = _globals["green"]

local _addon = {}
_addon.Name	= "ShissuFileIntegrity"
_addon.Version = "1.0.0"
_addon.lastUpdate = "18.11.2020"

local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.formattedName = stdColor .. "Shissu" .. white .. "'s " .. _L("TITLE")
_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version, _addon.lastUpdate)
_addon.controls = {}

function _addon.createSettings()
  local controls = _addon.controls 
  
  controls[#controls+1]= {
    type = "title",
    name = _L("INFO", "ShissuFramework"),     
  }
  controls[#controls+1] = {
    type = "description",
    text = _L("INFO"),  
  }
  controls[#controls+1] = {
    type = "title",
    name = _L("FILES"),     
  } 

  local fileList = ShissuFramework["fileIntegrity"]["data"]
  local fileDesc = ""

  for _, file in ipairs(fileList) do
    local status = file[2]

    if (status == false) then 
      status = white .. "[" .. red .. "ERR" .. white .. "] "
    else
      status = white .. "[" .. green .. "OK" .. white .. "] "
    end

    fileDesc = fileDesc .. "\n" .. status .. file[1]
  end

  controls[#controls+1] = {
    type = "description",
    text = fileDesc or "-- empty --",  
  }

  return controls
end

function _addon.initialized()
  _addon.createSettings()
end

ShissuFramework._settings[_addon.Name] = {}

zo_callLater(function()              
  EVENT_MANAGER:RegisterForUpdate("ShissuFrameworkWaitToFileList", 10, function() 
    local fileList = ShissuFramework["fileIntegrity"]["data"]

    if (#fileList > 0) then
      --ShissuFramework._settings[_addon.Name] = {}
      ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
      ShissuFramework._settings[_addon.Name].controls = _addon.controls  
    
      ShissuFramework.initAddon(_addon.Name, _addon.initialized)
      EVENT_MANAGER:UnregisterForUpdate("ShissuFrameworkWaitToFileList")  
    end
  end)
end, 150)