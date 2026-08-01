-- Shissu Guild Tools Addon
-- ShissuMemberStatus
--
-- Version: v1.3.1
-- Last Update: 24.05.2019
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!
 
local ZOS_ShowPlayerContextMenu = CHAT_SYSTEM.ShowPlayerContextMenu

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local green = _globals["green"]
local red = _globals["red"]
local yellow = _globals["yellow"]
local gray = _globals["gray"]

local setPanel = ShissuFramework["setPanel"]

local _addon = {}
_addon.Name = "ShissuMemberStatus"
_addon.Version = "1.3.1"
_addon.formattedName	= stdColor .. "Shissu" .. white .. "'s MemberStatus"
_addon.settings = {
  added = {}, 
  removed = {}, 
  memberstatus = {},
}

local _L = ShissuFramework["func"]._L(_addon.Name)
                                                                                                                                                                                                                              
local _guildId = 0
local _status = 0

_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version)
_addon.controls = {}

-- Event: EVENT_GUILD_MEMBER_ADDED
function _addon.playerAdded(_, guildId, accName)
  local guildName = GetGuildName(guildId)
  
  if shissuMemberStatus["added"][guildName] == false then return end
    if (GetGuildMemberIndexFromDisplayName(guildId, accName) ~= nil) then 
       text = stdColor .. guildName .. ": " .. white .. accName .. " - " .. green .. _L("FULLYADDED")
       d(text)
  else
       text = stdColor .. guildName .. ": " .. white .. accName .. " - " .. yellow .. _L("ADDED")
       d(text)
  end
end

-- Event: EVENT_GUILD_MEMBER_REMOVED
function _addon.playerRemoved(_, guildId, accName)
  local guildName = GetGuildName(guildId)
  
  if shissuMemberStatus["removed"][guildName] == false then return end

  text = stdColor .. guildName .. ": " .. white .. accName .. " - " .. red .. _L("REMOVED")
  d(text)
end         

-- Event: EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED
function _addon.playerStatusChanged(_, guildId, accName, _, newStatus)
  if (_guildId == guildId and _status == newStatus) then return end
  local guildName = GetGuildName(guildId)
  
  if shissuMemberStatus["memberstatus"][guildName] == false then return end
  
  _guildId = guildId
  _status = newStatus
  
  local statusText = {
    green .. "Online",
    yellow .. "AFK",
    red .. "BRB",                                   
    gray .. "Offline",
  }

  text = stdColor .. guildName .. ": " .. white .. accName .. " - " .. statusText[_status]

  d(text)
end

function _addon.createSettingMenu()
  local controls = _addon.controls 

  controls[#controls+1] = {
    type = "title",
    name = "Chat " .. GetString(SI_BINDING_NAME_TOGGLE_NOTIFICATIONS),     
  }

  controls[#controls+1] = {
    type = "guildCheckbox",
    name = stdColor .. _L("STATUS"),
    saveVar = shissuMemberStatus["memberstatus"],
  }  
  controls[#controls+1] = {
    type = "guildCheckbox",
    name = stdColor .. GetString(SI_GAMEPAD_WORLD_MAP_TOOLTIP_CATEGORY_PLAYERS) .. ": " .. green .. _L("ADDED"),
    saveVar = shissuMemberStatus["added"],
  }      
  controls[#controls+1] = {
    type = "guildCheckbox",
    name = stdColor .. GetString(SI_GAMEPAD_WORLD_MAP_TOOLTIP_CATEGORY_PLAYERS) .. ": " .. red .. _L("REMOVED"),
    saveVar = shissuMemberStatus["removed"],
  }            
end

function _addon.initialized()
  --d(_addon.formattedName .. " " .. _addon.Version)
      
  _addon.createSettingMenu()
    
   -- Hat jemand die neue SaveVar schon?  
  if (shissuMemberStatus["memberstatus"] == nil) then shissuMemberStatus["memberstatus"] = {} end
  if (shissuMemberStatus["added"] == nil) then shissuMemberStatus["added"] = {} end
  if (shissuMemberStatus["removed"] == nil) then shissuMemberStatus["removed"] = {} end
  
  for guildId=1, GetNumGuilds() do
local xguildId = GetGuildId(guildId)
    local guildName = GetGuildName(xguildId)  
    if (shissuMemberStatus["memberstatus"][guildName] == nil) then shissuMemberStatus["memberstatus"][guildName] = false end
    if (shissuMemberStatus["added"][guildName] == nil) then shissuMemberStatus["added"][guildName] = true end
    if (shissuMemberStatus["removed"][guildName] == nil) then shissuMemberStatus["removed"][guildName] = true end
  end
  
  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_MEMBER_REMOVED, _addon.playerRemoved)
  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_MEMBER_ADDED, _addon.playerAdded)
  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, _addon.playerStatusChanged)      
end          
                                                                

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end
  
  -- KOPIE / Leeren alter SGT Var
  shissuMemberStatus = shissuMemberStatus or {}
  
  if shissuMemberStatus == {} then
    shissuMemberStatus = _addon.settings 
  end 
  
  zo_callLater(function()               
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)