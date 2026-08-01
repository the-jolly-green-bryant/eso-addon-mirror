-- Shissu Framework: Chat commands
-- -------------------------------
-- 
-- Filename:    modules/chatcommands.lua
-- Version:     v1.0.11
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
_addon.Name	= "ShissuStandardCommands"
_addon.Version = "1.0.11"
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
    text = _L("DESC"),
  },          
}

function _addon.dice(number)    
  if (number == false) then return false end 
  local number = number

  local i18n = _L(string.upper(GetCVar("Language.2")) .. "_DICE")
  local langPlaceholder = string.find(number, ' ')

  if (langPlaceholder ~= nil) then
    lang = string.sub(number, langPlaceholder)
    lang = string.gsub(lang, " " , "")
    number = string.sub(number, 0, langPlaceholder) 
    langPlaceholder = string.upper(lang) .. "_DICE" 
    
    i18n = _L(langPlaceholder)
  end

  local numMax = tonumber(number)

  if (numMax ~= nil) then 
    local numRnd = math.random(numMax)
    i18n = replacePlaceholder (i18n, {GetUnitName("player"), numMax, numRnd})

    CHAT_SYSTEM:StartTextEntry(i18n)
  end
end

function _addon.offlineToogle()
  local offline = PLAYER_STATUS_OFFLINE
  local online = PLAYER_STATUS_ONLINE
  local current = GetPlayerStatus()
  
  if (current == offline) then
    SelectPlayerStatus(online)
  elseif (current == online) then
    SelectPlayerStatus(offline)
  else
    SelectPlayerStatus(online)
  end
end

function _addon.initialized()
  SLASH_COMMANDS["/rl"] = function() SLASH_COMMANDS["/reloadui"]() end
  SLASH_COMMANDS["/on"] = function() SelectPlayerStatus(PLAYER_STATUS_ONLINE) end
  SLASH_COMMANDS["/off"] = function() SelectPlayerStatus(PLAYER_STATUS_OFFLINE) end
  SLASH_COMMANDS["/brb"] = function() SelectPlayerStatus(PLAYER_STATUS_DO_NOT_DISTURB) end
  SLASH_COMMANDS["/dnd"] = function() SelectPlayerStatus(PLAYER_STATUS_DO_NOT_DISTURB) end
  SLASH_COMMANDS["/afk"] = function() SelectPlayerStatus(PLAYER_STATUS_AWAY) end  

  SLASH_COMMANDS["/roll"] = _addon.dice
  SLASH_COMMANDS["/dice"] = _addon.dice

  ShissuFramework._bindings["offlineToogle"] = _addon.offlineToogle 
  ShissuFramework._bindings["reload"] = function() SLASH_COMMANDS["/reloadui"]() end
end

ShissuFramework._bindings = {}
ShissuFramework._settings[_addon.Name] = {}
ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
ShissuFramework._settings[_addon.Name].controls = _addon.controls                 

ShissuFramework.initAddon(_addon.Name, _addon.initialized)