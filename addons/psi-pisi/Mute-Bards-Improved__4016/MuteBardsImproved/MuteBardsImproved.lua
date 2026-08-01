MBI = {
  name = "MuteBardsImproved",
  version = "1.0.0",
  author = "psi-pisi"
};

VOLUME_TYPES = {
  BARD = "bard";
  MUSIC = "music";
}

local currentActiveZone;

local currentMainZone;

local defaultBardZones = {
  "Mistral",                          -- Zone: Khenarthi's Roost    Location: Mistral               Bard: Eye-Fancy
  "Skywatch Wayshrine",               -- Zone: Auridon              Location: Skywatch              Bard: Annagail
  "Skywatch",                         -- Zone: Auridon              Location: Skywatch              Bard: Lorais
  "Firsthold",                        -- Zone: Auridon              Location: Firsthold             Bard: Ealare
  "Elden Root",                       -- Zone: Grathwood            Location: Elden Root            Bard: Fasana
  "Marbruk",                          -- Zone: Greenshade           Location: Marbruk               Bard: Elderien
  "Woodhearth",                       -- Zone: Greenshade           Location: Woodhearth            Bard: Rendarion
  "Velyn Harbor",                     -- Zone: Malabal Tor          Location: Velyn Harbor          Bard: Gilinora Birdsong
  "Daggerfall Castle Town",           -- Zone: Glenumbra            Location: Daggerfall            Bard: Axel Plourde
  "Wayrest Residential District",     -- Zone: Stormhaven           Location: Wayrest               Bard: Oceane Coravel
  "Davon's Watch",                    -- Zone: Stonefalls           Location: Davon's Watch         Bard: Siriaki Black-Owl
  "Ebonheart",                        -- Zone: Stonefalls           Location: Ebonheart             Bard: Helpirion
  "Kragenmoor",                       -- Zone: Stonefalls           Location: Kragenmoor            Bard: Odrys Drim
  "Mournhold Residential District",   -- Zone: Deshaan              Location: Mournhold             Bard: Athanas Samori
  "Mournhold Guild Plaza",            -- Zone: Deshaan              Location: Mournhold             Bard: Ophalia Strong-Voice
  "Riften",                           -- Zone: The Rift             Location: Riften                Bard: Anriel
  "Nimalten",                         -- Zone: The Rift             Location: Nimalten              Bard: Enjaadia
  "Ivarstead",                        -- Zone: The Rift             Location: Ivarstead             Bard: Eofel
  "Windhelm",                         -- Zone: Eastmarch            Location: Windhelm              Bard: Arani Longhair & Garrimar & Nil the Bard & Fargurd
  "Fort Amol",                        -- Zone: Eastmarch            Location: Fort Amol             Bard: Holsorr the Tuneful
  "Stormhold",                        -- Zone: Shadowfen            Location: Stormhold             Bard: Littrel Green-Hilt
  "Rawl'kha",                         -- Zone: Reaper's March       Location: Rawl'kha              Bard: No name
  "Sentinel",                         -- Zone: Alik'r Dessert       Location: Sentinel              Bard: Serosh & Taralqua the Minstrel
  "Evermore",                         -- Zone: Bangkorai            Location: Evermore              Bard: Nimirazan
  "Belkarth",                         -- Zone: Craglorn             Location: Belkarth              Bard: Petronious Libo
  "Dragonstar",                       -- Zone: Craglorn             Location: Dragonstar            Bard: Beritta Crow-Song
  "Leyawiin",                         -- Zone: Blackwood            Location: Leyawiin              Bard: Audania Decanius 
  "Gideon",                           -- Zone: Blackwood            Location: Gideon                Bard: Haderus Vano
  "Fargrave City District",           -- Zone: The Deadlands        Location: Fargrave              Bard: Tirasie Mirel & Alain Caria
  "Vastyr",                           -- Zone: Galen                Location: Vastyr                Bard: Luce Gemain
  "Gonfalon Bay",                     -- Zone: High Isle            Location: Gonfalon Bay          Bard: Portic Boulat
  "Lilmoth",                          -- Zone: Murkmire             Location: Lilmoth               Bard: Kalanu
  "Bright-Throat Village",            -- Zone: Murkmire             Location: Bright-Throat Village Bard: Ah-Seshs
  "Rimmen",                           -- Zone: Northern Elsweyr     Location: Rimmen                Bard: Daahin
  "Senchal",                          -- Zone: Southern Elsweyr     Location: Senchal               Bard: Ja-zinki & Rakzzin
  "Alinor",                           -- Zone: Summerset            Location: Alinor                Bard: Laeriwene
  "Shimmerene",                       -- Zone: Summerset            Location: Shimmerene            Bard: Endolale
  "Necrom",                           -- Zone: Telvanni Peninsula   Location: Necrom                Bard: Tolvise DoSWran
  "Markarth",                         -- Zone: The Reach            Location: Markarth              Bard: Tisnevere
  "Vivec City",                       -- Zone: Vvardenfell          Location: Vivec City            Bard: Mrylav Aralor & Altansawen
  "Skingrad"                          -- Zone: West Weald           Location: Skingrad              Bard: Ita Dannus
}

MBI.AccountDefaults = {
  currentActiveZone = '',
  currentMainZone = '',
  sfxVolume = 70,
  musicVolume = 70,
  printLogs = true,
  mutedBardZones = {},
  mutedMusicZones = {}
};

local isBardMuted = false
local isMusicMuted = false
local next = next

function table.removekey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

local function getMutedBardZones(accountDefaults)
  return accountDefaults and accountDefaults.mutedBardZones;
end

local function getMutedMusicZones(accountDefaults)
  return accountDefaults and accountDefaults.mutedMusicZones;
end

local function setVolume(volume, type)
  if (type == VOLUME_TYPES.BARD) then
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, volume);
  end
  if (type == VOLUME_TYPES.MUSIC) then
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME, volume);
  end
end

local function OnAddOnLoaded(addOnName)
  if (addOnName ~= MBI.name) then
    MBI:Initialize()
  end
end

function MBI:Initialize()
  --create the default table
  --create the saved variable access object here and assign it to savedVars
  MBI.SavedVariables = ZO_SavedVars:NewAccountWide("MuteBardsImproved_Settings", MBI.version, nil, MBI.AccountDefaults, GetWorldName());

  -- if the addon is older version then need to create new variables and remove the old ones
  if MBI.SavedVariables.currentZone ~= nil then
    local zoneIndex = GetCurrentMapZoneIndex()
	  local mainZone = zo_strformat(SI_UNIT_NAME, GetZoneNameByIndex(zoneIndex))

    MBI.AccountDefaults.currentActiveZone = MBI.SavedVariables.currentZone
    MBI.AccountDefaults.currentMainZone = mainZone
    MBI.AccountDefaults.sfxVolume = MBI.SavedVariables.volume
    MBI.AccountDefaults.musicVolume = MBI.SavedVariables.volume
    MBI.AccountDefaults.printLogs = MBI.SavedVariables.printLogs

    if next(MBI.SavedVariables.mutedZones) == nil then
      MBI.SavedVariables.mutedBardZones = defaultBardZones
      MBI.AccountDefaults.mutedBardZones = defaultBardZones
    else
      for index, data in pairs(MBI.SavedVariables.mutedZones) do
        MBI.AccountDefaults.mutedBardZones[index] = data
      end
    end
    table.removekey(MBI.SavedVariables, "currentZone")
    table.removekey(MBI.SavedVariables, "volume")
    table.removekey(MBI.SavedVariables, "mutedZones")
  end

  if MBI.SavedVariables.currentActiveZone ~= nil then
    MBI.AccountDefaults.currentActiveZone = MBI.SavedVariables.currentActiveZone
    MBI.AccountDefaults.currentMainZone = MBI.SavedVariables.currentMainZone
    MBI.AccountDefaults.sfxVolume = MBI.SavedVariables.sfxVolume
    MBI.AccountDefaults.musicVolume = MBI.SavedVariables.musicVolume
    MBI.AccountDefaults.printLogs = MBI.SavedVariables.printLogs

    if next(MBI.SavedVariables.mutedBardZones) == nil then
      MBI.SavedVariables.mutedBardZones = defaultBardZones
      MBI.AccountDefaults.mutedBardZones = defaultBardZones
    else
      for index, data in pairs(MBI.SavedVariables.mutedBardZones) do
        MBI.AccountDefaults.mutedBardZones[index] = data
      end
    end

    if next(MBI.SavedVariables.mutedMusicZones) ~= nil then
      for index, data in pairs(MBI.SavedVariables.mutedMusicZones) do
        MBI.AccountDefaults.mutedMusicZones[index] = data
      end
    end
  end
  --Unregister Loaded Callback
  EVENT_MANAGER:UnregisterForEvent(MBI.name, EVENT_ADD_ON_LOADED);

  MBI:InitSettingsPanel(MBI.AccountDefaults);
  MBI:Refresh();
end

function MBI:TogglePrintLogs(value)
  MBI.AccountDefaults.printLogs = value
  MBI.SavedVariables.printLogs = MBI.AccountDefaults.printLogs
end

function MBI:ChangeVolume(value, type)
  if(type == VOLUME_TYPES.BARD) then
    MBI.AccountDefaults.sfxVolume = value
    MBI.SavedVariables.sfxVolume = MBI.AccountDefaults.sfxVolume
  else
    MBI.AccountDefaults.musicVolume = value
    MBI.SavedVariables.musicVolume = MBI.AccountDefaults.musicVolume
  end
end

function MBI:AddZone(zoneName, type, cb)
  local result
  if (type == VOLUME_TYPES.BARD) then
    result = self:ContainsZone(zoneName, nil)
  else
    result = self:ContainsZone(nil, zoneName)
  end

  if (result ~= nil and result[type] == true) then
    d(MBI.name .. '> Zone "' .. zoneName .. '" is already in the muted ' .. type .. ' zones list.');
    return;
  end

  if (type == VOLUME_TYPES.BARD) then
    d(MBI.name .. '> Adding zone "' .. zoneName .. '" to the muted ' .. type .. ' zones list.');
    table.insert(MBI.AccountDefaults.mutedBardZones, zoneName);
    MBI.SavedVariables.mutedBardZones = MBI.AccountDefaults.mutedBardZones
  else
    d(MBI.name .. '> Adding zone "' .. zoneName .. '" to the muted ' .. type .. ' zones list.');
    table.insert(MBI.AccountDefaults.mutedMusicZones, zoneName);
    MBI.SavedVariables.mutedMusicZones = MBI.AccountDefaults.mutedMusicZones
  end

  if (cb ~= nil) then
    cb();
  end
end

function MBI:RemoveZone(zoneName, type, cb)
  local result
  if (type == VOLUME_TYPES.BARD) then
    result = self:ContainsZone(zoneName, nil)
  else
    result = self:ContainsZone(nil, zoneName)
  end

  if (result == nil or result[type] == false) then
    return
  end

  if (type == VOLUME_TYPES.BARD) then
    for i, v in pairs(getMutedBardZones(MBI.AccountDefaults)) do
      if (v:lower() == zoneName:lower()) then
        table.remove(MBI.AccountDefaults.mutedBardZones, i)
        MBI.SavedVariables.mutedBardZones = MBI.AccountDefaults.mutedBardZones
        d(MBI.name .. '> Zone "' .. zoneName .. '" is removed from the muted ' .. type .. ' zones list.');
        if (cb ~= nil) then
          cb();
        end
        return
      end
    end
  else
    for i, v in pairs(getMutedMusicZones(MBI.AccountDefaults)) do
      if (v:lower() == zoneName:lower()) then
        table.remove(MBI.AccountDefaults.mutedMusicZones, i)
        MBI.SavedVariables.mutedMusicZones = MBI.AccountDefaults.mutedMusicZones
        d(MBI.name .. '> Zone "' .. zoneName .. '" is removed from the muted ' .. type .. ' zones list.');
        if (cb ~= nil) then
          cb();
        end
        return
      end
    end
  end
end

function MBI:ContainsZone(activeZone, mainZone)
  local result = {
    bard = false,
    music = false
  };

  if(getMutedBardZones(MBI.AccountDefaults) ~= nil) then
    for i, v in ipairs(getMutedBardZones(MBI.AccountDefaults)) do
      if (v ~= nil and activeZone ~= nil) then -- protects against indexing nil on next line  
        if (v:lower() == activeZone:lower()) then
          result.bard = true
        end
      end
    end
  end

  if(getMutedMusicZones(MBI.AccountDefaults) ~= nil) then
    for i, v in ipairs(getMutedMusicZones(MBI.AccountDefaults)) do
      if (v ~= nil and mainZone ~= nil) then -- protects against indexing nil on next line  
        if (v:lower() == mainZone:lower()) then
          result.music = true
        end
      end
    end
  end
  return result;
end

function MBI:GetZoneNames()
  local mapName = GetMapName()
	local playerActiveSubzoneName = ZO_CachedStrFormat(SI_ZONE_NAME, GetPlayerActiveSubzoneName())
	local zoneIndex = GetCurrentMapZoneIndex()
	local zoneName = zo_strformat(SI_UNIT_NAME, GetZoneNameByIndex(zoneIndex))
  currentMainZone = zoneName

  --d('playerActiveSubzoneName: ' ..tostring(playerActiveSubzoneName))
  --d('zoneName: ' ..tostring(zoneName))
  --d('currentMainZone: ' .. currentMainZone)

	if (playerActiveSubzoneName ~= nil and playerActiveSubzoneName ~= '') then
		currentActiveZone = playerActiveSubzoneName
  elseif (mapName ~= nil and mapName ~= '') then
		currentActiveZone = mapName
	else
		currentActiveZone = zoneName
	end
end

function MBI:PrintLog(event, type, volume)
  if MBI.AccountDefaults.printLogs then
    if (type == VOLUME_TYPES.BARD) then
      if event == "zoneChange" then
        if volume == 0 then
          d(MBI.name .. '> There is a bard around, sound effects are muted.')
        else
          d(MBI.name .. '> No bard is around now, sound effects are unmuted.')
        end
      elseif event == "game" then
        if volume == 0 then
          d(MBI.name .. '> Game has ended, sound effects are muted.')
        else
          d(MBI.name .. '> Game has started, sound effects are unmuted.')
        end
      end
    else
      if volume == 0 then
        d(MBI.name .. '> Game music is muted.')
      else
        d(MBI.name .. '> Game music is unmuted.')
      end
    end
  end
end

function MBI.InCombatState(inCombat)
  if inCombat then
    setVolume(MBI.AccountDefaults.sfxVolume, VOLUME_TYPES.BARD);
    setVolume(MBI.AccountDefaults.musicVolume, VOLUME_TYPES.MUSIC);
  end
end

function MBI.OnAreaChange()
  MBI:GetZoneNames()
  --d('currentActiveZone ' .. currentActiveZone);

  if (MBI.AccountDefaults ~= nil and MBI.SavedVariables ~= nil) then
    MBI.AccountDefaults.currentActiveZone = currentActiveZone;
    MBI.SavedVariables.currentActiveZone = MBI.AccountDefaults.currentActiveZone

    MBI.AccountDefaults.currentMainZone = currentMainZone;
    MBI.SavedVariables.currentMainZone = MBI.AccountDefaults.currentMainZone

    --d('currentActiveZone: ' ..tostring(currentActiveZone))
    --d('MBI.SavedVariables.currentActiveZone: ' ..tostring(MBI.SavedVariables.currentActiveZone))
    local result = MBI:ContainsZone(currentActiveZone, currentMainZone)

    if (result ~= nil and result.bard == true) then
      MBI:PrintLog("zoneChange", VOLUME_TYPES.BARD, 0)
      setVolume(0, VOLUME_TYPES.BARD);
      isBardMuted = true
    elseif isBardMuted then
      MBI:PrintLog("zoneChange", VOLUME_TYPES.BARD, MBI.AccountDefaults.sfxVolume)
      setVolume(MBI.AccountDefaults.sfxVolume, VOLUME_TYPES.BARD);
      isBardMuted = false
    end
    
    if (result ~= nil and result.music == true) then
      MBI:PrintLog("zoneChange", VOLUME_TYPES.MUSIC, 0)
      setVolume(0, VOLUME_TYPES.MUSIC);
      isMusicMuted = true
    elseif isMusicMuted then
      MBI:PrintLog("zoneChange", VOLUME_TYPES.MUSIC, MBI.AccountDefaults.musicVolume)
      setVolume(MBI.AccountDefaults.musicVolume, VOLUME_TYPES.MUSIC);
      isMusicMuted = false
    end
  end
end

function MBI.OnGameStateChange(_, flowState)
  if (MBI:ContainsZone(currentActiveZone, nil)) then
    if(flowState == 0) then
      MBI:PrintLog("game", VOLUME_TYPES.BARD, 0)
      setVolume(0, VOLUME_TYPES.BARD);
      isBardMuted = true
    else
      if(flowState == 1) then
        MBI:PrintLog("game", VOLUME_TYPES.BARD, MBI.AccountDefaults.sfxVolume)
      end
      setVolume(MBI.AccountDefaults.sfxVolume, VOLUME_TYPES.BARD);
      isBardMuted = false
    end
  end
end

EVENT_MANAGER:RegisterForEvent(MBI.name..'InCombatState', EVENT_PLAYER_COMBAT_STATE, MBI.InCombatState)
EVENT_MANAGER:RegisterForEvent(MBI.name..'OnPlayerActivated', EVENT_PLAYER_ACTIVATED, MBI.OnAreaChange)
EVENT_MANAGER:RegisterForEvent(MBI.name..'OnZoneChange', EVENT_ZONE_CHANGED, MBI.OnAreaChange)
EVENT_MANAGER:RegisterForEvent(MBI.name..'OnGameStateChange', EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, MBI.OnGameStateChange)

--Register Loaded Callback
EVENT_MANAGER:RegisterForEvent(MBI.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded);

function MBI:Refresh()
  MBI.OnAreaChange()
end