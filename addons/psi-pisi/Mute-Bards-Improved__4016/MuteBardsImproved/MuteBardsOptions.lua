MBI = MBI or {};
local isInitialized = false;
local bardZoneToRemove
local musicZoneToRemove
local musicDropdownOption
local bardDropdownOption

local function copyTable(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in pairs(orig) do
          copy[orig_key] = orig_value
      end
  else
      copy = orig
  end
  return copy
end

local function firstNonEmptyValue(zoneOptions)
  local tempTable = copyTable(zoneOptions)
  local keys = {}
  for k,_ in pairs(tempTable) do
      table.insert(keys, k)
  end
  table.sort(keys)
  return tempTable[keys[1]]
end

local function getCurrentActiveZoneName(savedVariables)
  if (savedVariables ~= nil and savedVariables.currentActiveZone ~= nil and savedVariables.currentActiveZone ~= "") then
    return savedVariables.currentActiveZone;
  end
  return "UNKNOWN"
end

local function getCurrentMainZoneName(savedVariables)
  if (savedVariables ~= nil and savedVariables.currentMainZone ~= nil and savedVariables.currentMainZone ~= "") then
    return savedVariables.currentMainZone;
  end
  return "UNKNOWN"
end

local function generateBardZoneDropdownOption(savedVariables)
  local currentActiveZone = getCurrentActiveZoneName(savedVariables)

  local result = MBI:ContainsZone(currentActiveZone, nil)

  if (result ~= nil and result.bard == true) then
    bardDropdownOption = currentActiveZone
  else
    local zoneOptions =  copyTable(savedVariables.mutedBardZones)
    table.sort(zoneOptions)
    bardDropdownOption = firstNonEmptyValue(zoneOptions)
  end

  bardZoneToRemove = bardDropdownOption

  return bardDropdownOption
end

local function generateMusicZoneDropdownOption(savedVariables)
  local currentMainZone = getCurrentMainZoneName(savedVariables)

  local result = MBI:ContainsZone(nil, currentMainZone)

  if (result ~= nil and result.music == true) then
    musicDropdownOption = currentMainZone

  else
    local zoneOptions =  copyTable(savedVariables.mutedMusicZones)
    table.sort(zoneOptions)
    musicDropdownOption = firstNonEmptyValue(zoneOptions)
  end

  musicZoneToRemove = musicDropdownOption

  return musicDropdownOption
end

local function changeZoneToRemove(value, type)
  if (type == VOLUME_TYPES.BARD) then
    bardZoneToRemove = value
  else
    musicZoneToRemove = value
  end
end

function MBI:InitSettingsPanel(savedVariables)
  local function refreshCallback()
    self:Refresh();
  end
  
  local panelName = "Mute Bards Improved"

  local panelData = {
    type = "panel",
    name = panelName,
    displayName = panelName,
    author = "@psi-pisi",
    version = self.version,
    website = "https://www.esoui.com/downloads/info4016-MuteBardsImproved.html",
    feedback = "https://www.esoui.com/downloads/info4016-MuteBardsImproved.html#comments",
    slashCommand = "/mbi",
    registerForRefresh = true,
    registerForDefaults = false
  }

  local optionsTable = {
    {
      type = "header",
      name = "Bard Zone Settings",
      width = "full"
    },
    {
      type = "divider",
      width = "full",
      height = 10,
      alpha = 0.25
    },
    {
      type = "description",
      title = "Current Zone:",
      text = function() return "  " .. getCurrentActiveZoneName(savedVariables) end,
      width = "full"
    },
    {
      type = "divider",
      width = "full",
      height = 10,
      alpha = 0.25
    },
		{
			type = "dropdown",
			name = "Muted Bard Zones",
			choices = savedVariables.mutedBardZones,
      sort = "name-up",
			getFunc = function() return generateBardZoneDropdownOption(savedVariables) end,
			setFunc = function(value) changeZoneToRemove(value, VOLUME_TYPES.BARD) end,
      reference = "mutedBardZonesDropdown",
		},
    {
      type = "button",
      name = "Add Zone",
      disabled = function()  return getCurrentActiveZoneName(savedVariables) == "UNKNOWN" end,
      func = function()
        if (getCurrentActiveZoneName(savedVariables) ~= "UNKNOWN") then
          self:AddZone(getCurrentActiveZoneName(savedVariables), VOLUME_TYPES.BARD, refreshCallback);
          mutedBardZonesDropdown:UpdateChoices(savedVariables.mutedBardZones)
          ReloadUI("ingame")
        end
      end,
      width = "half",
      warning = "This will reload the UI for changes to be applied."
    },
    {
      type = "button",
      name = "Remove Zone",
      func = function()
        d("bardZoneToRemove: " .. bardZoneToRemove)
        self:RemoveZone(bardZoneToRemove, VOLUME_TYPES.BARD, refreshCallback);
        mutedBardZonesDropdown:UpdateChoices(savedVariables.mutedBardZones)
        ReloadUI("ingame")
      end,
      width = "half",
      warning = "This will reload the UI for changes to be applied."
    },
    {
      type = "header",
      name = "Music Zone Settings",
      width = "full"
    },
    {
      type = "divider",
      width = "full",
      height = 10,
      alpha = 0.25
    },
    {
      type = "description",
      title = "Current Main Zone:",
      text = function() return "  " .. getCurrentMainZoneName(savedVariables) end,
      width = "full"
    },
    {
      type = "divider",
      width = "full",
      height = 10,
      alpha = 0.25
    },
    {
			type = "dropdown",
			name = "Muted Music Zones",
			choices = savedVariables.mutedMusicZones,
      sort = "name-up",
			getFunc = function() return generateMusicZoneDropdownOption(savedVariables) end,
			setFunc = function(value) changeZoneToRemove(value, VOLUME_TYPES.MUSIC) end,
      reference = "mutedMusicZonesDropdown",
		},
    {
      type = "button",
      name = "Add Zone",
      disabled = function()  return getCurrentMainZoneName(savedVariables) == "UNKNOWN" end,
      func = function()
        if (getCurrentMainZoneName(savedVariables) ~= "UNKNOWN") then
          self:AddZone(getCurrentMainZoneName(savedVariables), VOLUME_TYPES.MUSIC, refreshCallback);
          mutedMusicZonesDropdown:UpdateChoices(savedVariables.mutedMusicZones)
          ReloadUI("ingame")
        end
      end,
      width = "half",
      warning = "This will reload the UI for changes to be applied."
    },
    {
      type = "button",
      name = "Remove Zone",
      func = function()
        d("musicZoneToRemove: " .. musicZoneToRemove)
        self:RemoveZone(musicZoneToRemove, VOLUME_TYPES.MUSIC, refreshCallback);
        mutedMusicZonesDropdown:UpdateChoices(savedVariables.mutedMusicZones)
        ReloadUI("ingame")
      end,
      width = "half",
      warning = "This will reload the UI for changes to be applied."
    },
    {
      type = "header",
      name = "Sound Settings",
      width = "full"
    },
    {
      type = "divider",
      width = "full",
      height = 10,
      alpha = 0.25
    },
    {
      type = "description",
      text = "Default sound effects sfxVolume when you are not around Bards.",
      width = "full"
    },
    {
			type = "slider",
			name = "SFX Volume",
			min = 1,
			max = 100,
			step = 1,
			getFunc = function() return savedVariables.sfxVolume end,
			setFunc = function(value) MBI:ChangeVolume(value, VOLUME_TYPES.BARD) end,
		},
    {
      type = "description",
      text = "Default music volume of the game.",
      width = "full"
    },
    {
			type = "slider",
			name = "Music Volume",
			min = 1,
			max = 100,
			step = 1,
			getFunc = function() return savedVariables.musicVolume end,
			setFunc = function(value) MBI:ChangeVolume(value, VOLUME_TYPES.MUSIC) end,
		},
    {
      type = "header",
      name = "Log Settings",
      width = "full"
    },
    {
      type = "divider",
      width = "full",
      height = 10,
      alpha = 0.25
    },
    {
      type = "description",
      text = "Since zones keep changing while you are moving around, it may cause too many logs getting printed in the chat.",
      width = "full"
    },
    {
      type = "description",
      text = "You can disable printing logs when sound effects are muted or unmuted.",
      width = "full"
    },
    {
      type = "checkbox",
      name = "Print mute/unmute logs",
      getFunc = function() return savedVariables.printLogs end,
      setFunc = function(value) MBI:TogglePrintLogs(value) end,
      width = "full"
  }
  }

  local LAM = LibAddonMenu2

  if (not isInitialized) then
    LAM:RegisterAddonPanel(panelName, panelData);
  end

  LAM:RegisterOptionControls(panelName, optionsTable);

  isInitialized = true;
end