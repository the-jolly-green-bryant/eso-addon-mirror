--  -------------------
--  Shissu's LUA Memory
--  -------------------
--
--  Shissu's LUA Memory führt regelmäßig eine zwanghafte Bereinigung des LUA Speichers durch.
--  Unnötige leere Variablen und sonstige nicht benötige Daten werden aus dem Arbeitsspeicher entfernt.
--  Dadurch läuft das Spiel letztendlich auch mit unzählen AddOns flüssiger und hat kürzere Ladebildschirme.
--
--  (c) im Januar 2014 - November 2020 by @Shissu [EU]
--
--  Author: Christian Flory (@Shissu, EU-Server) - esoui@flory.one
--  File: ShissuLUAMemory.lua
--  Last Update: 01.12.2020

--  Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local setPanel = ShissuFramework["setPanel"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local blue = _globals["blue"]
local red = _globals["red"]
local green = _globals["green"]

local _addon = {}
_addon.Name	= "ShissuLUAMemory"
_addon.Version = "2.0.1.8"
_addon.lastUpdate = "01.12.2020"
_addon.formattedName	= stdColor .. "Shissu" .. white .. "'s LUA Memory" 
_addon.sFormattedName = stdColor .. "SLM"

_addon.settings = {
  ["auto"] = true,
  ["chat"] = false,
  ["delay"] = 120,
}

_addon.cacheInfo = {}
_addon.cacheCount = 0;

local _L = ShissuFramework["func"]._L(_addon.Name)
local _P = ShissuFramework["functions"]["chat"].print

_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version, _addon.lastUpdate)
_addon.controls = {}

function _addon.createControls()
  local controls = _addon.controls 
  controls[#controls+1] = {
    type = "title",
    name = _L("INFO"),
  }

  controls[#controls+1] = {
    type = "description",
    text = _L("DESC"),
  }

  controls[#controls+1] = {
    type = "title",
    name = _L("INFO2"),
  }

  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("AUTO"),
    getFunc = shissuLUAMemory["auto"],
    setFunc = function(_, value)
      shissuLUAMemory["auto"] = value
    end,
  }        

  controls[#controls+1] = {
    type = "slider", 
    name = _L("DELAY"),
    minimum=30,
    maximum=600,
    steps=1,
    getFunc = shissuLUAMemory["delay"],
    setFunc = function(value)
      shissuLUAMemory["delay"] = value

      _addon.deactivate()
      _addon.activate()
    end,
  }        

  controls[#controls+1] = {
    type = "checkbox", 
    name = _L("CHAT"),
    getFunc = shissuLUAMemory["chat"],
    setFunc = function(_, value)
      shissuLUAMemory["chat"] = value
    end,
  }    

  controls[#controls+1] = {
    type = "title",
    name = _L("PROTOCOL"),
  }

  controls[#controls+1] = {
    type = "description",
    reference = "ShissuLUAMemorySettingsProtocol",
    text = "n/a",
  }
end

function _addon.initialized() 
  _addon.createControls()
  
  if shissuLUAMemory["auto"] == true then
    _addon.activate()
  end
end

function _addon.deactivate()
  EVENT_MANAGER:UnregisterForUpdate("shissuLUAMemory_Auto")
end

function _addon.activate()
  EVENT_MANAGER:RegisterForUpdate("shissuLUAMemory_Auto", shissuLUAMemory["delay"]*1000, function()
    if shissuLUAMemory["auto"] == true then
      _addon.clear(1)
    end
  end)
end

function _addon.clear(arg)
  local previous = math.ceil(collectgarbage("count") / 1000)
  collectgarbage("collect")
  local after = math.ceil(collectgarbage("count") / 1000)
  local chat = 1

  if (arg == 1 and shissuLUAMemory["chat"] ~= true) then
    chat = 0
  end

  if (chat == 1) then
    -- Diff. zwischen Vorher und Nachher
    local diff = previous - after

    -- Chatausgabe der zeitlichen Abstände, zwischen den einzelnen Durchgängen
    local timeDiff = shissuLUAMemory["delay"]

    -- keine Ausgabe wenn die Differenz = 1 ist, und damit keine Bereinigung erzielt wurde (unnötige Ausgabe)
    if timeDiff > 1 then
      if timeDiff > 180 then
        timeDiff = timeDiff / 60 .. _L("MINUTES")
      else
        timeDiff = timeDiff .. _L("SECONDS")
      end

      -- einzelne Strings
      local cPREVIOUS =   _L("PREVIOUS") .. red .. previous .. " MB " .. white
      local cAFTER =      _L("AFTER") .. green .. after .. " MB " .. white
      local CDIFF =       _L("DIFF") .. blue .. diff .. " MB "
      
      local output = "(" .. timeDiff .. "): " .. cPREVIOUS .. cAFTER .. CDIFF

      if (_addon.cacheCount > 4) then
        _addon.cacheCount = 0
      end

      _addon.cacheInfo[_addon.cacheCount] = output
      --d("DBG: " .. _addon.cacheCount)
      --d("DBG: " .. _addon.cacheInfo[_addon.cacheCount]
      _P(output, nil, "SLM")

      local protocolList = ""

      for i=0, #_addon.cacheInfo do
        protocolList = protocolList .. "\n" .. _addon.cacheInfo[i] 
      end
      
      if (ShissuLUAMemorySettingsProtocol) then
        ShissuLUAMemorySettingsProtocol.desc:SetText(protocolList)
      end
      _addon.cacheCount = _addon.cacheCount + 1
    end
  end 
end

function _addon.slashcommand(arg)
  if arg == "current" then
    local output = red .. math.ceil(collectgarbage("count") / 1000) .. " MB"
    _P(output, nil, "SLM", white .. _L("CURRENT"))
  elseif arg == "clean" then
    _addon.clear(0)
  elseif arg == "off" then

    _P(_L("OFF"), nil, "SLM")
    shissuLUAMemory["auto"] = false
    _addon.deactivate()
  elseif arg == "on" then
    _P(_L("ON"), nil, "SLM")
    shissuLUAMemory["auto"] = true
    _addon.activate()
  end 
end

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end

  shissuLUAMemory = shissuLUAMemory or {}

  if shissuLUAMemory == {} then
    shissuLUAMemory = _addon.settings 
  end 

  zo_callLater(function()               
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    SLASH_COMMANDS["/slm"] = _addon.slashcommand

    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end)

  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end
 
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)