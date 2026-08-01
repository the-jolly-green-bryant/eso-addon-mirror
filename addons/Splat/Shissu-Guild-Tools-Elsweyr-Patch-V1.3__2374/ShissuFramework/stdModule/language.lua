-- Shissu Guild Tools Addon
-- ShissuColor
--
-- Version: v1.0.8
-- Last Update: 25.09.2017
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local red = _globals["red"]

local setPanel = ShissuFramework["setPanel"]

local _addon = {}
_addon.Name	= "ShissuLanguageChanger"
_addon.Version = "1.0.4"
_addon.formattedName = stdColor .. "Shissu" .. white .. "'s language changer"

local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version)

_addon.controls = {
  [1] = {
    type = "title",
    name = _L("TITLE"),     
  }, 
  [2] = {
    type = "description",
    text = string.format(_L("DESC"), "\n" .. red) .. " " .. string.format(_L("SLASH"), stdColor),  
  },     
  [3] = {
    type = "combobox",
    name = _L("LANG"),
    items = {"de", "en", "fr"},
    getFunc = GetCVar("Language.2"),
    setFunc = function(_, value)
      SetCVar("Language.2", value)
      SLASH_COMMANDS["/reloadui"]() 
    end,
  },       
}

function _addon.slashCommand(option)
  if ( option == nil ) then return end
  if ( option == GetCVar("Language.2") ) then return end

  if ( option == "de" or option == "en" or option == "fr" ) then
    SetCVar("Language.2", option)
    SLASH_COMMANDS["/reloadui"]() 
  end
end

function _addon.initialized()
  ShissuFramework._settings[_addon.Name]["controls"][3].getFunc = GetCVar("Language.2")

  SLASH_COMMANDS["/slc"] = _addon.slashCommand
end

ShissuFramework._settings[_addon.Name] = {}
ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
ShissuFramework._settings[_addon.Name].controls = _addon.controls                 

ShissuFramework.initAddon(_addon.Name, _addon.initialized)