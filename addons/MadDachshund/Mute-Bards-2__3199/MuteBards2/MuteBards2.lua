MuteBards = MuteBards or {};
MuteBards.name = "MuteBards2"
MuteBards.version = "2.0.6"

local savedVars = {}
MuteBards.sv = savedVars; -- saved vars

local currentSubZone;

local accountDefaults = {
  zones = { "Ebonheart", "Nimalten", "Kragenmoor", "Davon's Watch", "Stormhold", "Riften", "Velyn Harbor", "Solitude", "Rimmen", "Belkarth", "Lilmoth", "Bright-Throat Village", "Mournhold Guild Plaza", "Mournhold Residential District", "Alinor", "Shimmerene" },
};
local characterDefaults = {
  currentSubZone = '',
};

local function setSfxVolume(volume)
  SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, volume);
end

local function getSVZones(sv)
  return sv and sv.account and sv.account.zones;
end

-- Todo how can I get the current subZone name?  I could not figure that out.  If I can do that, I can add a button to mute current subZone.

--define Callback
local function OnAddOnLoaded(eventCode, addOnName)
  --Check if that is your addons on Load, if not quit
  if (addOnName ~= MuteBards.name) then
    return;
  end

  --Unregister Loaded Callback
  EVENT_MANAGER:UnregisterForEvent(MuteBards.name, EVENT_ADD_ON_LOADED);

  --create the default table
  --create the saved variable access object here and assign it to savedVars
  savedVars.account = ZO_SavedVars:NewAccountWide("MuteBards_Settings", "1.0.0", "Zones", accountDefaults, GetWorldName());
  savedVars.character = ZO_SavedVars:NewCharacterIdSettings("MuteBards_Settings", "1.0.0", "currentSubZone", characterDefaults, GetWorldName());

  if ((savedVars.character.currentSubZone == nil or savedVars.character.currentSubZone == "") and (currentSubZone ~= nil and currentSubZone ~= "")) then
    savedVars.character.currentSubZone = currentSubZone;
  end

  MuteBards:InitSettingsPanel(getSVZones(savedVars), savedVars.character);
  MuteBards:Refresh();
end

--Register Loaded Callback
EVENT_MANAGER:RegisterForEvent(MuteBards.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded);

function MuteBards2_OnCombatStateChange(event_id, inCombat)
  if inCombat then
    setSfxVolume(70);
  end
end

function MuteBards:AddZone(zoneName, cb)
  if (self:ContainsZone(zoneName)) then
    d('Zone ' .. zoneName .. ' already in list');
    return;
  end
  d('Adding zone ' .. zoneName);
  table.insert(getSVZones(savedVars), zoneName);
  if (cb ~= nil) then
    cb();
  end
end

function MuteBards:RemoveZone(zoneName, cb)
  if (self:ContainsZone(zoneName)) then
    for i, v in ipairs(getSVZones(savedVars)) do
      if (v:lower() == zoneName:lower()) then
        table.remove(getSVZones(savedVars), i);
        d('Zone ' .. zoneName .. ' removed from list');
        if (cb ~= nil) then
          cb();
        end
        return;
      end
    end
  end
  d('Zone ' .. zoneName .. ' not found in list');
end

function MuteBards:ContainsZone(zoneName)
  if (getSVZones(savedVars) == nil) then
    return false;
  end
  for i, v in ipairs(getSVZones(savedVars)) do
    if (v ~= nil and zoneName ~= nil) then -- protects against indexing nil on next line
      if (v:lower() == zoneName:lower()) then
        return true;
      end
    end
  end
  return false;
end

function MuteBards2_OnZoneChange(subZoneName)
  if (MuteBards.sv ~= nil and MuteBards.sv.character ~= nil) then
    MuteBards.sv.character.currentSubZone = subZoneName;
  else
    currentSubZone = subZoneName
  end
  setSfxVolume(70);
  if (MuteBards:ContainsZone(subZoneName)) then
    setSfxVolume(0);
  end
end

-- Handle cases where you're interacting with an object?

EVENT_MANAGER:RegisterForEvent("MuteBards2_OnCombatStateChange", EVENT_PLAYER_COMBAT_STATE, MuteBards2_OnCombatStateChange)
EVENT_MANAGER:RegisterForEvent("MuteBards2_OnZoneChange", EVENT_ZONE_CHANGED, function(_, __, subZoneName) MuteBards2_OnZoneChange(subZoneName) end)

function MuteBards:Refresh()
  MuteBards2_OnZoneChange((MuteBards.sv.character and MuteBards.sv.character.currentSubZone) or currentSubZone);
end
