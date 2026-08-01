_SGTguildMemberList = {}

local _addon = {}
_addon.Name = "ShissuProvisionMember"

function _addon.createGuildVars(name, memberId, guildId) 
  if _SGTguildMemberList[name] == nil then
    _SGTguildMemberList[name] = {}
    _SGTguildMemberList[name]["guilds"] = {} 
        
    _SGTguildMemberList[name].id = memberId
    _SGTguildMemberList[name].gid = guildId
  end          
end

function _addon.createGuildMemberList()
  _SGTguildMemberList = {}

  local numGuilds = GetNumGuilds()
  
  for i = 1, numGuilds do
    local guildId = GetGuildId(i)
    local guildName = GetGuildName(guildId)
    local numMembers = GetNumGuildMembers(guildId)
    
    for memberId = 1, numMembers, 1 do
      local charData = { GetGuildMemberCharacterInfo(guildId, memberId) }
      local memberData = { GetGuildMemberInfo(guildId, memberId) }
      local accName = memberData[1]  
      local charName = charData[2]            
      
      _addon.createGuildVars(charName, memberId, guildId) 
      _addon.createGuildVars(accName, memberId, guildId) 
                                                                                       
      local charList = _SGTguildMemberList[charName]["guilds"]
      charList[#charList +1] = { guildName, guildId, memberId }    

      local accList = _SGTguildMemberList[accName]["guilds"]
      accList[#accList + 1] = { guildName, guildId, memberId }   
    end
  end
end

--function MEOWMEOW2()
--  local mss = GetGameTimeMilliseconds()
--  _addon.createGuildMemberList()
--  local mse = GetGameTimeMilliseconds()
--  d("Diff: " .. mse - mss .. " ms")
--end

function _addon.removedMember(_, guildId, accName)
  local mss = GetGameTimeMilliseconds()
  local memberId = -1
  local gId = -1
  local gName = ""
  local numGuilds = 0
  local gId2 = -1

  guildId = GetGuildId(guildId)
  local guildName = GetGuildName(guildId)

  if ( _SGTguildMemberList[accName] ~= nil ) then
    local data = _SGTguildMemberList[accName]

    if ( data ~= nil ) then
      if ( data["guilds"] ~= nil ) then
        numGuilds = #data["guilds"]

        if ( numGuilds == 1 ) then 
          gName = data["guilds"][1][1]
          memberId = data["guilds"][1][3] 
          gId = data["guilds"][1][2]
          --d("NUR EINE GILDE")
        else
          --d("MEHR ALS EINE GILDE")
          for guildIndex = 1, numGuilds do
            if ( data["guilds"][guildIndex][1] == guildName ) then
              gName = data["guilds"][guildIndex][1]
              gId = data["guilds"][guildIndex][2]
              memberId = data["guilds"][guildIndex][3] 
              gId2 = guildIndex

              --d("GILDE GEFUNDEN")
              break
            end
          end
        end
      end
    end
  end

  if ( numGuilds > 1 and memberId ~= -1 ) then
    --d("MUSS NUR EINS LÖSCHEN")

    local charName = ""
    for name, nameData in pairs(_SGTguildMemberList) do 
      if ( nameData["guilds"] ~= nil ) then
        local num = #nameData["guilds"]

        for i = 1, GetNumGuilds() do
          if ( nameData["guilds"][1][1] == gName and nameData["guilds"][1][2] == gId and nameData["guilds"][1][3] == memberId ) then
            --d("GILDE UND CHARNAME GEFUNDEN")
            charName = name
            break
          end
        end

        if ( charName ~= "" ) then
          break
        end
      end
    end
  
    if ( charName ~= "") then
      --d("GELÖSCHT")
      _SGTguildMemberList[accName] = nil
      _SGTguildMemberList[charName] = nil 
    end

  elseif ( numGuilds > 1 and memberId ~= -1 ) then
    --d("MEHR ALS EINE GILDE")

    local charName = ""
    for name, nameData in pairs(_SGTguildMemberList) do 
      if ( nameData["guilds"] ~= nil ) then
        local num = #nameData["guilds"]

        if ( num == 1 ) then
          if ( nameData["guilds"][1][1] == gName and nameData["guilds"][1][2] == gId and nameData["guilds"][1][3] == memberId ) then
            --d("GILDE UND CHARNAME GEFUNDEN")
            charName = name
            break
          end
        end
      end
    end

    if ( charName ~= "") then
      --d("GELÖSCHT")
       _SGTguildMemberList[accName]["guilds"][gId2] = nil
       _SGTguildMemberList[charName]["guilds"][gId2] = nil
    end   
  else
    --d("EINFACH NEUBAUEN")
    _addon.createGuildMemberList()
  end

  --local mse = GetGameTimeMilliseconds()
  --d("Diff: " .. mse - mss .. " ms")
end

function _addon.addedMember(_, guildId, accName)
  --local mss = GetGameTimeMilliseconds()

  guildId = GetGuildId(guildId)
  local guildName = GetGuildName(guildId)
  local numMembers = GetNumGuildMembers(guildId)

  for memberId = 1, numMembers, 1 do
    local charData = { GetGuildMemberCharacterInfo(guildId, memberId) }
    local memberData = { GetGuildMemberInfo(guildId, memberId) }
    local accName2 = memberData[1]  
    local charName = charData[2]            

    if ( accName == accName2 ) then
      _addon.createGuildVars(charName, memberId, guildId) 
      _addon.createGuildVars(accName, memberId, guildId) 
                                                                                       
      local charList = _SGTguildMemberList[charName]["guilds"]
      charList[#charList +1] = { guildName, guildId, memberId }    

      local accList = _SGTguildMemberList[accName]["guilds"]
      accList[#accList + 1] = { guildName, guildId, memberId }   
      break
    end
  end

  --local mse = GetGameTimeMilliseconds()
  --d("Diff: " .. mse - mss .. " ms")
end

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end

  zo_callLater(function()               
    _addon.createGuildMemberList()

    EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_MEMBER_REMOVED, _addon.removedMember)
    EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_MEMBER_ADDED, _addon.addedMember)
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)