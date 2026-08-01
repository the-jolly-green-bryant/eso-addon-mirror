-------------------------------------------------------------------------------
-- Quiet Sanctuary
-- Author: @lowkeyyy
-- Version: 1.0
-- Description: Adjusts ambient volume in "The Erstwhile Sanctuary" house.
-------------------------------------------------------------------------------

QuietSanctuary = {}
QuietSanctuary.name = "QuietSanctuary"

local savedVariables

local defaults = {
  houseVolume = 20,
  worldVolume = 70,
}

sVars = ZO_SavedVars:NewAccountWide("QuietSanctuaryVars", 1, nil, defaults)

local function adjustAmbientVolume()
  local currentZone = GetUnitZone("player")
  if currentZone == "The Erstwhile Sanctuary" then
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME, tostring(sVars.houseVolume))
  else
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME, tostring(sVars.worldVolume))
  end
  ApplySettings()
end

local function initializeQuietSanctuaryAddon()
  local LAM2 = LibAddonMenu2
  local panelName = "QuietSanctuaryOptions"

  local panelData = {
    type = "panel",
    name = "QuietSanctuary",
    displayName = "Quiet Sanctuary",
    author = "@lowkeyyy",
    version = "1.0",
  }

  local optionsData = {
    [1] = {
      type = "slider",
      name = "House Ambient Volume",
      tooltip = "Sets the ambient volume inside of your house",
      min = 0,
      max = 100,
      getFunc = function() return sVars.houseVolume end,
      setFunc = function(value)
        sVars.houseVolume = value
        if GetUnitZone("player") == "The Erstwhile Sanctuary" then
          adjustAmbientVolume()
        end
      end,
      default = 20,
    },
    [2] = {
      type = "slider",
      name = "World Ambient Volume",
      tooltip = "Sets the ambient volume outside of your house",
      min = 0,
      max = 100,
      getFunc = function() return sVars.worldVolume end,
      setFunc = function(value)
        sVars.worldVolume = value
        if GetUnitZone("player") ~= "The Erstwhile Sanctuary" then
          adjustAmbientVolume()
        end
      end,
      default = 70,
    },
  }

  local panel = LAM2:RegisterAddonPanel(panelName, panelData)
  LAM2:RegisterOptionControls(panelName, optionsData)
end

function QuietSanctuary.OnAddOnLoaded(event, name)
  if name ~= "QuietSanctuary" then return end
  EVENT_MANAGER:UnregisterForEvent("QuietSanctuary", EVENT_ADD_ON_LOADED)

  sVars = ZO_SavedVars:NewAccountWide("QuietSanctuaryVars", 1, nil, defaults)

  initializeQuietSanctuaryAddon()
end

EVENT_MANAGER:RegisterForEvent(QuietSanctuary.name, EVENT_PLAYER_ACTIVATED, adjustAmbientVolume)
EVENT_MANAGER:RegisterForEvent(QuietSanctuary.name, EVENT_ADD_ON_LOADED, QuietSanctuary.OnAddOnLoaded)
