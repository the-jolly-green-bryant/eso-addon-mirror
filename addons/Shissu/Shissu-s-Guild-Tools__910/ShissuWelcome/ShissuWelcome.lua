-- Shissu Guild Tools Addon
-- ShissuWelcome
--
-- Version: v1.2.1
-- Last Update: 12.11.2020
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local splitToArray = ShissuFramework["functions"]["datatypes"].splitToArray
local setPanel = ShissuFramework["setPanel"]

local _addon = {}
_addon.Name = "ShissuWelcome"
_addon.Version = "1.2.6"
_addon.lastUpdate = "12.11.2020"
_addon.formattedName = stdColor .. "Shissu" .. white .. "'s Welcome"
_addon.controls = {}  
_addon.settings = {
  ["invite"] = {}, -- true, true, true, true, true },
  ["message"] = {}, -- { "Welcome %1 in %2", "Welcome %1", "Welcome %1", "Welcome %1", "Welcome %1" }
}

local _L = ShissuFramework["func"]._L(_addon.Name)
_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version, _addon.lastUpdate)

function _addon.createSettingMenu()
  local controls = ShissuFramework._settings[_addon.Name].controls
  local numGuild = GetNumGuilds()
  
  controls[#controls+1] = {
    type = "title",
    name = _L("INFO"),
  }
  controls[#controls+1] = {                
    type = "description",
    text = _L("DESC1") .. ":",
  }
  controls[#controls+1] = {
    type = "description",
    text = stdColor .. "%1 " .. white .. "- " .. _L("DESC2") .. "\n" .. 
           stdColor .. "%2 " .. white .. "- " .. _L("DESC3") .. "\n" .. 
           stdColor .. "|| " .. white .. "- " .. _L("DESC4"),
  }
    
  controls[#controls+1] = {
    type = "title",
    name = GetString(SI_GAMEPAD_HOUSING_PERMISSIONS_SEARCH_GUILD),
  }
    
  for guildId = 1, numGuild do
    local gId = GetGuildId(guildId)
    local name = GetGuildName(gId)

    controls[#controls+1] = {
      type = "description",
      text = stdColor .. name,
    }

    controls[#controls+1] = {
      type = "checkbox",
      name = "Chat: " .. _L("TITLE"),
      getFunc = shissuWelcome["invite"][name],
      setFunc = function(_, value)
        shissuWelcome["invite"][name] = value 
      end,
    } 
    
    controls[#controls+1] = {
      type = "editbox",
      name = _L("TITLE"),
      getFunc = shissuWelcome["message"][name],
      setFunc = function(value)
        shissuWelcome["message"][name] = value 
      end,
    }   
  end          
end
                                         
-- Event: EVENT_GUILD_MEMBER_ADDED
function _addon.guildMemberAdded(_, guildId, accName)
  local guildName = GetGuildName(guildId) 
  local allowInvite = shissuWelcome["invite"][guildName]
        
  if allowInvite == false then return end

  local currentText = CHAT_SYSTEM.textEntry:GetText()
  
  -- Nur eine Willkommensnachricht in die Textbox schreiben, wenn USER nicht aktiv selber aktuell was schreibt.
  if string.len(currentText) < 1 then
    local chatMessageArray = splitToArray(shissuWelcome["message"][guildName], "|")
          
    local rnd = math.random(#chatMessageArray) 
    local chatMessage = string.gsub(chatMessageArray[rnd], "%%1", accName)
    chatMessage = string.gsub(chatMessage, "%%2", guildName)
    
    -- Überprüfen ob der GuildID-Zähler stimmt
    local guildID = 0
    for gId=1, GetNumGuilds() do
      local gId_guildId = GetGuildId(gId)
      if(guildId == gId_guildId) then guildID = gId end
    end

    if (GetGuildMemberIndexFromDisplayName(guildId, accName) ~= nil) then 
      local text = "/g" .. guildID .. " " .. chatMessage     
      ZO_ChatWindowTextEntryEditBox:SetText(text)
    end
  end                        
end

function _addon.initialized()
  if (shissuWelcome["invite"] == nil) then shissuWelcome["invite"] = {} end
  if (shissuWelcome["message"] == nil) then shissuWelcome["message"] = {} end
  
  local welcomeString = "Welcome / Willkommen %1"
  
  for guildId=1, GetNumGuilds() do
    local gId = GetGuildId(guildId)
    local guildName = GetGuildName(gId)  
    
    if (shissuWelcome["invite"][guildName] == nil) then shissuWelcome["invite"][guildName] = true end
    if (shissuWelcome["message"][guildName] == nil) then shissuWelcome["message"][guildName] = welcomeString end
  end
  
  _addon.createSettingMenu()
  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_MEMBER_ADDED, _addon.guildMemberAdded)
end

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end

  shissuWelcome = shissuWelcome or {}
  
  if shissuWelcome == {} then
    shissuWelcome = _addon.settings 
  end 

  zo_callLater(function()         
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end, 50) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end  

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)