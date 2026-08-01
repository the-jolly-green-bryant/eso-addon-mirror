local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local red = _globals["red"]

local setPanel = ShissuFramework["setPanel"]

local _addon = {}
_addon.Name	= "ShissuThemeColor"
_addon.Version = "1.0.4"
_addon.formattedName = stdColor .. "Shissu" .. white .. "'s theme color"

_addon.panel = setPanel("Theme Color", _addon.formattedName, _addon.Version)  
_addon.controls = {}            

function _addon.createSettings()
 local controls = _addon.controls 

  controls[#controls+1] = { 
    type = "colorpicker", 
    name = "Theme Color",
    getFunc = shissuFramework["color"], 
    setFunc = function (r, g, b, a)                                                                                                                                                                         
      shissuFramework["color"] = {r, g, b, a}
    end,     
  }
end

function _addon.initialized() 
  shissuFramework = shissuFramework or {}

  if (shissuFramework["color"] == nil) then
    shissuFramework["color"] = { 0.1568627506, 0.8313725591, 1, 1 }
  end

  _addon.createSettings()
end

  -- Initialize Event            
function _addon.EVENT_ADD_ON_LOADED (eventCode, addOnName)
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
            
  zo_callLater(function() 
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end, 150); 
end
  
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)