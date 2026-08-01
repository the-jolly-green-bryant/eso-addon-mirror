-- Shissu Framework: Chat commands
-- -------------------------------
-- 
-- Filename:    modules/language.lua
-- Version:     v1.0.10
-- Last Update: 19.11.2020
--
-- Written by Christian Flory (@Shissu, EU) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local red = _globals["red"]

local setPanel = ShissuFramework["setPanel"]
local replacePlaceholder = ShissuFramework["functions"]["chat"].replacePlaceholder

local _addon = {}
_addon.Name	= "ShissuLanguageChanger"
_addon.Version = "1.0.10"
_addon.lastUpdate = "19.11.2020"

local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.formattedName = stdColor .. "Shissu" .. white .. "'s " .. _L("TITLE")
_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version, _addon.lastUpdate)
_addon.controls = {
  [1] = {
    type = "title",
    name = _L("TITLE"),     
  }, 
  [2] = {
    type = "description",
    text = _L("DESC") .. replacePlaceholder(_L("SLASH"), {stdColor}) .. "\n\n" .. replacePlaceholder(_L("WARNING"), {red}),
  },
  [3] = {
    type = "title",
    name = _L("LANG"),     
  },      
  [4] = {
    type = "combobox",
    name = _L("LANG"),
    items = {"de", "en", "es", "fr", "jp", "ru"},
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

  if ( option == "de" or option == "en" or option == "es" or option == "fr" or option == "jp" or option == "ru" ) then
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