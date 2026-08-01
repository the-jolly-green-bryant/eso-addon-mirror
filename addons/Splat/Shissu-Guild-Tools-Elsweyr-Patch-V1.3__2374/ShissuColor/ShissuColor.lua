-- Shissu Guild Tools Addon
-- ShissuColor
--
-- Version: v1.1.0
-- Last Update: 24.05.2019
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]

local setPanel = ShissuFramework["setPanel"]

local _addon = {}
_addon.Name	= "ShissuColor"
_addon.Version = "1.1.0"
_addon.formattedName = stdColor .. "Shissu" .. white .. "'s Color"
_addon.controls = {}

local _L = ShissuFramework["func"]._L(_addon.Name)
 
_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version)

function _addon.createSettingMenu()
  if ( shissuColor["c1"] == nil ) then
    shissuColor["c1"] = {1, 1, 1, 1}
    shissuColor["c2"] = {1, 1, 1, 1}
    shissuColor["c3"] = {1, 1, 1, 1}
    shissuColor["c4"] = {1, 1, 1, 1}
    shissuColor["c5"] = {1, 1, 1, 1}
  end

  local controls = ShissuFramework._settings[_addon.Name].controls
  
  controls[#controls+1] = {
    type = "description", 
    text = _L("DESC") .. ":",
  }
  
  controls[#controls+1] = {
    type = "description", 
    text = stdColor .. "- " .. white .. _L("NOTE") .. "\n" .. 
           stdColor .. "- " .. white .. _L("NOTE2") .. "\n" ..
           stdColor .. "- " .. white .. _L("MOTD") ..  "\n" ..
           stdColor .. "- " .. white .. "...",
  }
 
  for i = 1, 5 do
    controls[#controls+1] = {
      type = "colorpicker", 
      name = _L("STD") .. " " .. i,
      getFunc = shissuColor["c" .. i], 
      setFunc = function (r, g, b, a)                                                                                                                                                                         
        shissuColor["c" .. i] = {r, g, b, a}
      end,
    }    
  end
end               

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end

  shissuColor = shissuColor or {}
  
  zo_callLater(function()         
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    ShissuFramework.initAddon(_addon.Name, _addon.createSettingMenu)
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end  

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)