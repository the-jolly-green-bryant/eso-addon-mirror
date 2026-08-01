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
_addon.Name	= "ShissuStandardCommands"
_addon.Version = "1.0.1"
_addon.formattedName = stdColor .. "Shissu" .. white .. "'s standard commands"

local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version)

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

function _addon.helmToogle()
  local cache = GetSetting( SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM )

  SetSetting( SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, 1 - cache )
end

function _addon.dice(number)     
  if (number == false) then return false end
  
  local variableText = {
    ["de"] = " hat bei einem Zufallswurf (1-MAX) die Zahl: RND erwürfelt.",
    ["fr"] = " roule le nombre RND dans un jet alkatoire de 1-MAX.",
    ["ru"] = " hat bei einem Zufallswurf (1-MAX) die Zahl: RND erwürfelt.",
    ["en"] = " rolls the number RND in a random throw of 1-MAX."  
  }
  
  local text = variableText[GetCVar("Language.2")]
   
  if string.len(text) < 5 then
    text = " rolls the number RND in a random throw of 1-MAX."
  end
   
  local textLang = string.sub(number, string.len(number)-2, string.len(number))
  textLang = string.gsub(textLang, " ", "")

  if textLang ~= nil then    
    if variableText[textLang] then
      text = variableText[textLang]
      number = string.gsub(number, "" .. textLang, "")
    end
  end

  local numMax = tonumber(number)

  if numMax ~= nil then 
    local numRnd = math.random(numMax)
    
    text = string.gsub (text, "MAX" , numMax)
    text = string.gsub (text , "RND", numRnd)
           
    CHAT_SYSTEM:StartTextEntry(GetUnitName("player") .. text)
  end
end

function _addon.offlineToogle()
  local offline = PLAYER_STATUS_OFFLINE
  local online = PLAYER_STATUS_ONLINE
  local current = GetPlayerStatus()
  
  if ( current == offline) then
    SelectPlayerStatus(online)
  elseif ( current == online) then
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

  SLASH_COMMANDS["/helm"] = _addon.helmToogle
  SLASH_COMMANDS["/roll"] = _addon.dice
  SLASH_COMMANDS["/dice"] = _addon.dice

  ShissuFramework._bindings["helmToogle"] = _addon.helmToogle 
  ShissuFramework._bindings["offlineToogle"] = _addon.offlineToogle 
  ShissuFramework._bindings["reload"] = function() SLASH_COMMANDS["/reloadui"]() end

  --SLASH_COMMANDS["/setting"] = function() SelectPlayerStatus(PLAYER_STATUS_AWAY) end
  --SLASH_COMMANDS["/shissu"] = function() SelectPlayerStatus(PLAYER_STATUS_AWAY) end
end

ShissuFramework._bindings = {}
ShissuFramework._settings[_addon.Name] = {}
ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
ShissuFramework._settings[_addon.Name].controls = _addon.controls                 

ShissuFramework.initAddon(_addon.Name, _addon.initialized)