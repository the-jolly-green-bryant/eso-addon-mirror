-- Shissu Guild Tools Addon
-- ShissuCompareMember
--
-- Version: v1.1.0
-- Last Update: 24.05.2019
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local red = _globals["red"]

local setPanel = ShissuFramework["setPanel"]

local _addon = {}
_addon.Name	= "ShissuCompareMember"
_addon.Version = "1.1.0"
_addon.formattedName = stdColor .. "Shissu" .. white .. "'s CompareMember"
_addon.compares = {}
_addon.guildData = {}

local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version)
_addon.controls = {
  [1] = {
    type = "title",
    name = "Info",     
  },
  [2] = {
    type = "description",
    text = _L("INFO"), 
  },
  [3] = {
    type = "description",
    text = red .. _L("SYNTAX") .. white .. "\n" .. _L("NOGUILD"), 
  },  
}

-- /scm_save Tamrizon
function _addon.scm_save(guildName)
  local numGuild = GetNumGuilds()
  local found = 0
  
  for guildId = 1, numGuild do
    local name = GetGuildName(GetGuildId(guildId))    
    
    if (name == guildName) then
      local numMember = GetNumGuildMembers(GetGuildId(guildId))
      found = 1
      
      shissuCompareMember[guildName] = {}  

      for memberId = 1, numMember do
        local memberData = { GetGuildMemberInfo(GetGuildId(guildId), memberId) }
        local accName = memberData[1]  
        
        table.insert(shissuCompareMember[guildName], accName)
      end    
    end
  end
  
  if ( found == 1 ) then
    return true
  else
    return false
  end
end

function _addon.split(str, pat)
  local t = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
     if s ~= 1 or cap ~= "" then
        table.insert(t,cap)
     end
  
     last_end = e+1
     s, e, cap = str:find(fpat, last_end)
  end
  
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  
  return t
end

function _addon.tableCompare(tableIndex)
  local guildData = _addon.guildData
  local exact = {}
  
  if ( guildData[tableIndex] ~= nil and _addon.compares ~= nil ) then
    for i = 1, #guildData[tableIndex] do
      for y = 1, #_addon.compares do
        if guildData[tableIndex][i] == _addon.compares[y] then
            table.insert(exact, guildData[tableIndex][i])        
          end
        end
      end  
  else
    _addon.compares = {}
    return false
  end
  
  if ( #exact > 0 ) then
    _addon.compares = exact
    return true
  end
  
  _addon.compares = {} 
  return false
end

-- /scm_compare Tamrizon,Tamrilando
function _addon.scm_compare(guildNames)
  local guildNames = _addon.split(guildNames, ",")
  local names = stdColor .. "- " .. white .. _L("COMPAREFROM") .. ":"
  local noData = ""
  
  _addon.guildData = {}
  _addon.compares = {}
  
  for i = 1, #guildNames do
    names = names .. " " .. stdColor .. guildNames[i]
    
    if (i < #guildNames) then
      names = names .. white .. ","
    end

    if ( shissuCompareMember[guildNames[i]] ~= nil ) then
      _addon.guildData[i] = shissuCompareMember[guildNames[i]]  
    else
      if (_addon.scm_save(guildNames[i]) == true) then
        _addon.guildData[i] = shissuCompareMember[guildNames[i]]
      else
        if (noData ~= "") then
          noData = noData .. white .. "," 
        end
        
        noData = noData .. red .. " " .. guildNames[i]
      end  
    end
  end    
  
  local guildData = _addon.guildData  
  
  if ( guildData[1] ~= nil and guildData[2] ~= nil ) then
    _addon.compares = guildData[1]
      
    d(stdColor .. "Shissu" .. white .. "'s CompareMember")
    d(names)
    
    if ( noData ~= "" ) then
      d(stdColor .. "- " .. white .. string.format(_L("NODATAFROM"), noData, white))
    else
      if (_addon.tableCompare(2) == true) then
        
        if (#guildNames > 2) then
          for i=3, #guildNames do
            if (_addon.tableCompare(i) == false) then
              break
            end            
          end
        end
      
        if (#_addon.compares > 0) then
          table.sort(_addon.compares)
          --d(_addon.compares)
          names = ""
  
          for i = 1, #_addon.compares do
            names = names .. " " .. _addon.compares[i]
                
            if (i < #_addon.compares) then
              names = names .. white .. ","
            end
          end
          
          d("\n" .. stdColor .. _L("MEMBERS") .. ":\n" .. white .. names)
          d("\n")
          d(string.format(white .. _L("COUNT"), red, #_addon.compares, white))      
        else
          d("\n" .. red .. _L("NOMEMBERS"))
        end
      else
        d("\n" .. red .. _L("NOMEMBERS"))
      end
    end                                
  else
    d(stdColor .. "Shissu" .. white .. "'s CompareMember\n" .. red .. _L("SYNTAX") .. white ..": " .. _L("NOGUILD")) 
  end
end

-- Initialize Event            
function _addon.EVENT_ADD_ON_LOADED(_, addOnName)  
  if addOnName ~= _addon.Name then return end

  SLASH_COMMANDS["/scm_save"] = _addon.scm_save
  SLASH_COMMANDS["/scm"] = _addon.scm_compare
  
  shissuCompareMember = shissuCompareMember or {}

  zo_callLater(function()               
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    ShissuFramework.initAddon(_addon.Name, function() end)
  end, 150) 
  
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)