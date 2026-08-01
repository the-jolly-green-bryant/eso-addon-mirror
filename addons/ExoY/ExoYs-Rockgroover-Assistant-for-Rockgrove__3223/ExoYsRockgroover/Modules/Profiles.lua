Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.profiles = ERG.profiles or {}
local Profiles = ERG.profiles


function Profiles.Initialize()
  Profiles.name = ERG.name.."Profiles"
  Profiles.editBox = ""

  Profiles.newProfileName = ERG_PROFILE_NEW
end


function Profiles.GetDefaults( profileName )
  local defaults = { name = profileName }

  for _, encounter in ipairs( ERG.GetEncounterList() ) do
    defaults[encounter] = {}

    -- general default values for notifications

    local notificationList = ERG[encounter].GetNotificationList()
    local mechanicData = ERG[encounter].GetMechanicData()

    for id, specificNotificationList in pairs(notificationList) do
      defaults[encounter][id] = {}
      defaults[encounter][id].color = mechanicData[id].color
      defaults[encounter][id].sound = mechanicData[id].sound or "None"
      for notification, data in pairs(specificNotificationList) do
        defaults[encounter][id][notification] = true
        local text = mechanicData[id].name or ERG.GetFormattedAbilityName(id)
        defaults[encounter][id][notification.."Text"] = text
        if notification == "OnCastAlert" and mechanicData[id].action then text = mechanicData[id].action end
      end
    end

    -- specific default values
    if ERG[encounter].GetSpecialDefaults then
      for key, uniqueDefaults in pairs( ERG[encounter].GetSpecialDefaults() ) do
        defaults[encounter][key] = uniqueDefaults
      end
    end

    -- cca settings
    if ERG[encounter].Get_CCA_Settings then
      defaults[encounter].CCA_Settings = {}
      for mechanic, settings in pairs( ERG[encounter].Get_CCA_Settings() ) do
        defaults[encounter].CCA_Settings[mechanic] = true
      end
    end

  end
  return defaults
end


function Profiles.GetList()
  local list = {}
  for num, profile in ipairs(ERG.SV.profiles) do
    table.insert(list, profile.name)
  end
  return list
end


function Profiles.GetCurrentNum()
  return ERG.SV.profileManager[ERG.charId]
end


function Profiles.GetCurrentName()
  return Profiles.GetList()[Profiles.GetCurrentNum()]
end


function Profiles.GetNameWithNum( num )
  return Profiles.GetList()[num]
end


function Profiles.GetNumWithName( profileName )
  for num, name in pairs( Profiles.GetList() ) do
    if profileName == name then
      return num
    end
  end
end


function Profiles.IsDuplicateName( checkName )
  local duplicate = false
  for _, name in pairs( Profiles.GetList() ) do
    if checkName == name then
      duplicate = true
      break
    end
  end
  return duplicate
end


function Profiles.ChangeNameOfCurrent( newName )
  ERG.SV.profiles[ Profiles.GetCurrentNum() ].name = newName or Profiles.editBox
end


function Profiles.SetCurrent( profileNum )
  ERG.SV.profileManager[ERG.charId] = profileNum

  Profiles.SynchronizeSaveVariables( profileNum )

  ERG.store = ERG.SV.profiles[profileNum]

  if ERG.initialized then
    for _, encounter in ipairs( ERG.GetEncounterList() ) do
      local func = ERG[encounter].OnProfileChange or nil
      if type(func) == "function" then
        func()
      end
    end
  end
end

function Profiles.SynchronizeSaveVariables( profileNum )
  local default = Profiles.GetDefaults( "SyncVar" )
  local store = ZO_DeepTableCopy( ERG.SV.profiles[ profileNum ] )

  local function HandleSubtables(subDefault, subStore)
    for k,v in pairs( subDefault ) do
      if type(v) ~= type(subStore[k]) then
        subStore[k] = nil
        rawset( subStore, k, v)
        --subStore[k] = v
      elseif type(v) == "table" then
        HandleSubtables( subDefault[k], subStore[k] )
      end
    end
  end
  HandleSubtables( default, store )
  ERG.SV.profiles[profileNum] = store
end

----------
-- Menu --
----------

function Profiles.CopyCurrent()
  table.insert(ERG.SV.profiles, ZO_DeepTableCopy(ERG.store) )
  local newName = ERG.profiles.editBox
  Profiles.SetCurrent(#ERG.SV.profiles)
  Profiles.ChangeNameOfCurrent(newName)
  Profiles.SetCurrent(#ERG.SV.profiles)
end

function Profiles.UpdateMenu()
  ERG_MENU_PROFILE_LIST:UpdateChoices( Profiles.GetList() )
end

function Profiles.CreateNew( profileName )
  table.insert(ERG.SV.profiles, Profiles.GetDefaults( profileName ) )
end

function Profiles.DeleteCurrentProfile()
  local deletedProfileName = Profiles.GetCurrentName()
  local deletedProfileNum = Profiles.GetCurrentNum()
  local profileList = Profiles.GetList()

  table.remove(ERG.SV.profiles, deletedProfileNum )

  for charId, profilNum in pairs( ERG.SV.profileManager ) do
    if profilNum > deletedProfileNum then
      ERG.SV.profileManager[charId] = profilNum - 1
    elseif profilNum == deletedProfileNum then
      ERG.SV.profileManager[charId] = 1
    end
  end

  Profiles.UpdateMenu()
  Profiles.SetCurrent(1)
end
