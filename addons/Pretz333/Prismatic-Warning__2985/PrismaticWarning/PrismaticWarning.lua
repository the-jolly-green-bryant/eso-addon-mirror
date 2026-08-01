-- Addon Controls --

PrismaticWarning = PrismaticWarning or {
  name = "PrismaticWarning",
  author = "@Pretz333 (NA)",
  version = "4.5.4",
  variableVersion = 1,
  defaults = {
    left = GuiRoot:GetWidth()/2,
    top  = (2*GuiRoot:GetHeight()/3),
    refreshRate = 1000,
    hideOnScreenAlert = false,
    hideOnScreenAlertInCombat = true,
    isLocked = false,
    fontName = "EsoUI/Common/Fonts/Univers67.otf",
    fontSize = 48,
    infoFontSize = 25,
    fontOutline = "thick-outline",
    fontColor = {255, 255, 255, 255},
    alertToChat = false,
    alertOnlyOnVet = false,
    alertInDungeons = true,
    alertInPartialDungeons = true,
    alertInTrials = true,
    alertInArenas = true,
    alertIfTank = false,
    alertIfHeal= false,
    alertIfMagDD = true,
    alertIfStamDD = true,
    alertIfUnderFifty = false,
    autoSwapTo = GetString(PRISMATICWARNING_MENU_DONT),
    equipSlot = nil,
    poisonSlot = nil,
    debugAlerts = false,
  },
}

function PrismaticWarning.OnAddOnLoaded(_, addonName)
  if addonName ~= PrismaticWarning.name then return end

  EVENT_MANAGER:UnregisterForEvent(PrismaticWarning.name, EVENT_ADD_ON_LOADED)
  PrismaticWarning.savedVariables = ZO_SavedVars:NewAccountWide("PrismaticWarningSavedVariables", PrismaticWarning.variableVersion, nil, PrismaticWarning.defaults, nil, "$InstallationWide")
  PrismaticWarning.SettingsWindow()
  PrismaticWarning.settingsBypass = false
  PrismaticWarning.combatState = IsUnitInCombat('player')

  if not PrismaticWarning.savedVariables.hideOnScreenAlert then
    PrismaticWarning.InitializeUI()
  end

  if PrismaticWarning.isWeaponPrismatic(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN) or PrismaticWarning.isWeaponPrismatic(BAG_WORN, EQUIP_SLOT_MAIN_HAND) then
    PrismaticWarning.isPrismaticEquipped = true
  else
    PrismaticWarning.isPrismaticEquipped = false
  end

  EVENT_MANAGER:RegisterForEvent(PrismaticWarning.name .. "Kick", EVENT_INSTANCE_KICK_TIME_UPDATE, PrismaticWarning.kicking)
  EVENT_MANAGER:RegisterForEvent(PrismaticWarning.name .. "Load", EVENT_PLAYER_ACTIVATED, PrismaticWarning.sorter)
  EVENT_MANAGER:RegisterForEvent(PrismaticWarning.name .. "Reset", EVENT_ACTIVITY_FINDER_STATUS_UPDATE, PrismaticWarning.OnActivityFinderStatusUpdate)
  EVENT_MANAGER:RegisterForEvent(PrismaticWarning.name .. "Gear", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, PrismaticWarning.gearChanged)
  EVENT_MANAGER:AddFilterForEvent(PrismaticWarning.name .. "Gear", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
  EVENT_MANAGER:AddFilterForEvent(PrismaticWarning.name .. "Gear", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
  EVENT_MANAGER:RegisterForEvent(PrismaticWarning.name .. "Combat", EVENT_PLAYER_COMBAT_STATE, PrismaticWarning.updateCombatState)
end

function PrismaticWarning.OnActivityFinderStatusUpdate(_, result) -- Thank you @code65536 (stolen from dungeon timer)
	-- Covers the case where a group requeues directly into the same dungeon
	if (result == ACTIVITY_FINDER_STATUS_FORMING_GROUP or result == ACTIVITY_FINDER_STATUS_READY_CHECK) then
		PrismaticWarning.dungeonComplete(false)
	end
end

function PrismaticWarning.kicking()
  PrismaticWarning.zoneId = nil -- to fix the case where the player ports directly from the old instance into the new instance
end

-- Dungeon Watchers --

function PrismaticWarning.AA()
  local _, y = PrismaticWarning.currentLocation()
  local mapId = GetCurrentMapId()
  
  if mapId == 642 and ((y > 25 and y < 43) or (y > 48 and y < 75)) then
    PrismaticWarning.alerter(true)
  elseif mapId == 641 or mapId == 640 then
    PrismaticWarning.alerter(false)
    PrismaticWarning.dungeonComplete(true, false)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.BC1()
  local x, y = PrismaticWarning.currentLocation()
  if x < 38 and y > 32 then
    PrismaticWarning.alerter(false)
    PrismaticWarning.dungeonComplete(true, false)
  else
    PrismaticWarning.alerter(true)
  end
end

function PrismaticWarning.BC2()
  local x, y = PrismaticWarning.currentLocation()
  if (x > 71 and y > 69) or (x < 48 and y > 58 and y < 73) or (y < 29 and x > 40) then
    PrismaticWarning.alerter(false)
  elseif x < 43 and y < 20 then
    PrismaticWarning.alerter(true)
    PrismaticWarning.dungeonComplete(true, true)
  else
    PrismaticWarning.alerter(true)
  end
end

function PrismaticWarning.BHH()  
  -- If someone in group is doing quest, adds after roost mother all count (add " or (y < 30 and x < 55 and group member doing quest) to "mapId == 344")
  -- I'm currently ignoring that since I don't know how to tell if someone in group talked to Shifty Tom after the Atarus kill
  
  local _, y = PrismaticWarning.currentLocation()
  local mapId = GetCurrentMapId()
  if (mapId == 346 and y < 55) or y < 8 then
    PrismaticWarning.alerter(true)
  elseif mapId == 344 then
    PrismaticWarning.alerter(true)
    PrismaticWarning.dungeonComplete(true, true)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.BRF()
  local _, y = PrismaticWarning.currentLocation()
  if PrismaticWarning.specialEventTrigger then
    PrismaticWarning.alerter(true)
    PrismaticWarning.dungeonComplete(true, true)
  elseif GetCurrentMapId() == 1309 and y > 63 then
    PrismaticWarning.caresAboutXPGain = true
    PrismaticWarning.alerter(false)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.COA1()
  local x, y = PrismaticWarning.currentLocation()
  if x > 50 then
    PrismaticWarning.alerter(false)
    PrismaticWarning.dungeonComplete(true, false)
  -- elseif x < 22 and y > 58 then -- Golor technically isn't an undead/daedra, but he dies so quickly it'll slow groups down if they unequip, then re-equip the prismatic
    -- PrismaticWarning.alerter(false)
  else
    PrismaticWarning.alerter(true)
  end
end

function PrismaticWarning.COS()
  local x, y = PrismaticWarning.currentLocation()
  local mapId = GetCurrentMapId()
  
  if mapId == 1134 and ((y > 66 and x > 60) or (x < 33 and y < 62)) then
    PrismaticWarning.alerter(true)
  elseif mapId == 1135 and (y > 56 or x > 58) then
    PrismaticWarning.alerter(true)
  elseif mapId == 1136 or mapId == 1137 then
    PrismaticWarning.alerter(true)
    PrismaticWarning.dungeonComplete(true, true)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.CT()
  local x, y = PrismaticWarning.currentLocation()
  local mapId = GetCurrentMapId()
  
  if mapId == 1823 and x < 38 or y < 38 then
    PrismaticWarning.alerter(true)
    PrismaticWarning.dungeonComplete(true, true)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.Direfrost()
  -- no dungeonComplete since it's possible to do this dungeon basically backwards
  
  local x, y = PrismaticWarning.currentLocation()
  if (GetCurrentMapId() == 162) or (x > 74 and y > 40) then
    PrismaticWarning.alerter(false)
  elseif y < 67 and y > 10 then
    PrismaticWarning.alerter(true)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.DOM()
  local x, y = PrismaticWarning.currentLocation()
  if GetCurrentMapId() == 1596 and x < 51 and y < 37 then
    if x > 38 and y > 24 then
      PrismaticWarning.alerter(true)
    else
      PrismaticWarning.alerter(false)
    end
  else
    PrismaticWarning.alerter(false)
    PrismaticWarning.dungeonComplete(true, false)
  end
end

function PrismaticWarning.DSA()
  local mapId = GetCurrentMapId()
  if mapId == 689 or mapId == 691 then
    PrismaticWarning.alerter(true)
  elseif mapId == 692 then
    PrismaticWarning.alerter(false)
    PrismaticWarning.dungeonComplete(true, false)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.EH2()
  local x, y = PrismaticWarning.currentLocation()
  local mapId = GetCurrentMapId()
  if mapId == 1146 or (PrismaticWarning.counter == 1 and x > 65 and y > 55 and y < 75) then
    PrismaticWarning.alerter(false)
  elseif y < 33 and x < 55 or mapId == 1147 then
    PrismaticWarning.alerter(true)
    PrismaticWarning.dungeonComplete(true, true)
  else
    PrismaticWarning.alerter(true)
  end
end

function PrismaticWarning.FG2()
  local x, y = PrismaticWarning.currentLocation()
  
  if GetCurrentMapId() == 1151 or x < 34 or (y > 46 and y < 50 and x < 39) then
    PrismaticWarning.alerter(false)
    PrismaticWarning.dungeonComplete(true, false)
  elseif y > 38 and y < 50 and x < 45 then
    PrismaticWarning.alerter(true)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.FH()
  local x, y = PrismaticWarning.currentLocation()
  local mapId = GetCurrentMapId()
  if mapId == 1322 then
    if x > 60 and y > 78 then
      PrismaticWarning.alerter(false)
      PrismaticWarning.dungeonComplete(true, false)
    else
      PrismaticWarning.alerter(true)
    end
  elseif x < 30 and y > 62 then
    PrismaticWarning.alerter(true)
  elseif mapId == 1323 then
    PrismaticWarning.alerter(false)
    PrismaticWarning.dungeonComplete(true, false)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.FullDungeon()
  PrismaticWarning.alerter(true)
  if PrismaticWarning.isPrismaticEquipped then
    PrismaticWarning.dungeonComplete(true)
  end
end

function PrismaticWarning.HRC()
  local _, y = PrismaticWarning.currentLocation()
  local mapId = GetCurrentMapId()
  
  if mapId == 616 or PrismaticWarning.counter > 0 then
    PrismaticWarning.alerter(false)
    PrismaticWarning.dungeonComplete(true, false)
  elseif mapId == 615 and y > 52 and PrismaticWarning.specialEventTrigger then
    PrismaticWarning.alerter(true)
  else
    -- PrismaticWarning.specialEventTrigger = false -- in case of early true forced, though I've yet to see that
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.KA()
  if GetCurrentMapId() == 1806 then -- 1807 is the 2nd floor, 1808 is the bottom floor
    PrismaticWarning.alerter(true)
    PrismaticWarning.dungeonComplete(true, true)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.MA()
  local mapId = GetCurrentMapId()
  if mapId == 988 or mapId == 973 then
    PrismaticWarning.alerter(true)
  elseif mapId == 986 then
    PrismaticWarning.alerter(true)
    PrismaticWarning.dungeonComplete(true, true)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.MOL()
  local x = PrismaticWarning.currentLocation()
  
  if GetCurrentMapId()== 1000 and x < 75 then
    PrismaticWarning.alerter(true)
    PrismaticWarning.dungeonComplete(true, true)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.NoneDungeon()
  PrismaticWarning.alerter(false)
  if not PrismaticWarning.isPrismaticEquipped then
    PrismaticWarning.dungeonComplete(true)
  end
end

function PrismaticWarning.Spindle1()
  local _, y = PrismaticWarning.currentLocation()
  if y > 68 then
    PrismaticWarning.alerter(true)
    PrismaticWarning.dungeonComplete(true, true)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.Spindle2()
  local x, y = PrismaticWarning.currentLocation()
  if x > 70 or y > 55 then
    PrismaticWarning.alerter(true)
    PrismaticWarning.dungeonComplete(true, true)
  elseif x > 52 and y < 33 then
    PrismaticWarning.alerter(false)
  else
    PrismaticWarning.alerter(true)
  end
end

function PrismaticWarning.Tempest()
  local x, y = PrismaticWarning.currentLocation()
  if y < 39 and y > 30 and x > 78 and x < 85 then
    PrismaticWarning.alerter(true)
  elseif GetCurrentMapId() == 597 then
    PrismaticWarning.alerter(false)
    PrismaticWarning.dungeonComplete(true, false)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.UHG()
  local _, y = PrismaticWarning.currentLocation()
  local mapId = GetCurrentMapId()
  
  if mapId == 1769 then
    PrismaticWarning.alerter(true)
  elseif (mapId == 1796 and y > 75) or mapId == 1767 then
    PrismaticWarning.alerter(false)
    PrismaticWarning.dungeonComplete(true, false)
  else
    PrismaticWarning.alerter(false)
  end
end

function PrismaticWarning.VH()
  local mapId = GetCurrentMapId()
  
  if mapId == 1843 or mapId == 1845 then
    PrismaticWarning.alerter(true)
  elseif mapId == 1844 then
    PrismaticWarning.alerter(false)
  elseif mapId == 1846 then
    PrismaticWarning.alerter(false)
    PrismaticWarning.dungeonComplete(true, false)
  end
end

PrismaticWarning.zones = {
  -- [zoneId] = {isArena, isTrial, isNotAPartialDungeon, isAPartialDungeon, sortFunc},
  -- use string matching to a one letter code (a, t, d, p) in sorter() instead of the 3 falses, 1 true?
  [11] = {false, false, true, false, PrismaticWarning.FullDungeon}, -- VOM
  [22] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- Volenfell
  [31] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- Selene's
  [38] = {false, false, false, true, PrismaticWarning.BHH},
  [63] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- DC1
  [64] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- Blessed Crucible
  [126] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- EH1
  [130] = {false, false, true, false, PrismaticWarning.FullDungeon}, -- COH1
  [131] = {false, false, false, true, PrismaticWarning.Tempest}, 
  [144] = {false, false, false, true, PrismaticWarning.Spindle1}, 
  [146] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- Wayrest 1
  [148] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- Arx Corinium
  [176] = {false, false, false, true, PrismaticWarning.COA1}, 
  [283] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- FG1
  [380] = {false, false, false, true, PrismaticWarning.BC1}, 
  [449] = {false, false, false, true, PrismaticWarning.Direfrost}, 
  [635] = {true, false, false, false, PrismaticWarning.DSA}, 
  [636] = {false, true, false, false, PrismaticWarning.HRC}, 
  [638] = {false, true, false, false, PrismaticWarning.AA}, 
  [639] = {false, true, false, false, PrismaticWarning.NoneDungeon}, -- SO
  [677] = {true, false, false, false, PrismaticWarning.MA}, 
  [678] = {false, false, true, false, PrismaticWarning.FullDungeon}, --ICP
  [681] = {false, false, true, false, PrismaticWarning.FullDungeon}, --COA2
  [688] = {false, false, true, false, PrismaticWarning.FullDungeon}, --WGT
  [725] = {false, true, false, false, PrismaticWarning.MOL}, 
  [843] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- ROM
  [848] = {false, false, false, true, PrismaticWarning.COS}, 
  [930] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- DC2
  [931] = {false, false, false, true, PrismaticWarning.EH2}, 
  [932] = {false, false, true, false, PrismaticWarning.FullDungeon}, -- COH2
  [933] = {false, false, true, false, PrismaticWarning.FullDungeon}, -- Wayrest 2
  [934] = {false, false, false, true, PrismaticWarning.FG2}, 
  [935] = {false, false, false, true, PrismaticWarning.BC2}, 
  [936] = {false, false, false, true, PrismaticWarning.Spindle2}, 
  [973] = {false, false, false, true, PrismaticWarning.BRF}, 
  [974] = {false, false, false, true, PrismaticWarning.FH}, 
  [975] = {false, true, false, false, PrismaticWarning.NoneDungeon}, -- HOF
  [1000] = {false, true, false, false, PrismaticWarning.NoneDungeon}, -- Asylum
  [1009] = {false, false, true, false, PrismaticWarning.FullDungeon}, -- FL
  [1010] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- SCP
  [1051] = {false, true, false, false, PrismaticWarning.NoneDungeon}, -- CR
  [1052] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- MHK
  [1055] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- MOS
  [1080] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- Frostvault
  [1082] = {true, false, false, false, PrismaticWarning.NoneDungeon}, -- BRP
  [1081] = {false, false, false, true, PrismaticWarning.DOM}, 
  [1121] = {false, true, false, false, PrismaticWarning.NoneDungeon}, -- SS
  [1122] = {false, false, true, false, PrismaticWarning.FullDungeon}, -- MGF
  [1123] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- LOM
  [1152] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- Icereach
  [1153] = {false, false, false, true, PrismaticWarning.UHG},  
  [1196] = {false, true, false, false, PrismaticWarning.KA},
  [1197] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- Stone Garden
  [1201] = {false, false, false, true, PrismaticWarning.CT},
  [1227] = {true, false, false, false, PrismaticWarning.VH},
  [1228] = {false, false, true, false, PrismaticWarning.NoneDungeon}, -- BDV
  [1229] = {false, false, true, false, PrismaticWarning.FullDungeon}, -- Cauldron
}

PrismaticWarning.usesSpecialEvent = {
  [636] = EVENT_BOSSES_CHANGED, --HRC
  [931] = EVENT_UNIT_DEATH_STATE_CHANGED, --EH2
  [973] = EVENT_EXPERIENCE_GAIN, --BRF
}

-- Sorter --

function PrismaticWarning.sorter()
  local zoneId = GetZoneId(GetUnitZoneIndex('player'))

  if PrismaticWarning.zoneId ~= zoneId then
    PrismaticWarning.zoneId = zoneId
    PrismaticWarning.dungeonComplete(false)
  elseif PrismaticWarning.settingsBypass then
    PrismaticWarning.settingsBypass = false
    PrismaticWarning.dungeonComplete(false) -- in case shouldWatch is now false
  else
    return -- already checked this zone and settings haven't changed
  end
  
  local shouldWatch, zoneIsArena, zoneIsTrial, zoneIsPartialDungeon, zoneIsDungeon

  if PrismaticWarning.zones[zoneId] ~= nil then
    if PrismaticWarning.zones[zoneId][4] then
      zoneIsPartialDungeon = true
      zoneIsDungeon = true
    elseif PrismaticWarning.zones[zoneId][3] then
      zoneIsDungeon = true
    elseif PrismaticWarning.zones[zoneId][2] then
      zoneIsTrial = true
    elseif PrismaticWarning.zones[zoneId][1] then
      zoneIsArena = true
    end
  end

  if zoneIsDungeon or zoneIsTrial or zoneIsArena then
    local role = GetSelectedLFGRole()
    if PrismaticWarning.savedVariables.alertOnlyOnVet and (GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_VETERAN) then
      PrismaticWarning.debugAlert("Doesn't want alerts on normal difficulty")
    elseif (role == LFG_ROLE_TANK) and (not PrismaticWarning.savedVariables.alertIfTank) then
      PrismaticWarning.debugAlert("Doesn't want alerts on a tank")
    elseif (role == LFG_ROLE_HEAL) and (not PrismaticWarning.savedVariables.alertIfHeal) then
      PrismaticWarning.debugAlert("Doesn't want alerts on a healer")
    elseif (role == LFG_ROLE_DPS) and (not PrismaticWarning.savedVariables.alertIfMagDD) and (GetPlayerStat(STAT_MAGICKA_MAX, STAT_BONUS_OPTION_APPLY_BONUS) > GetPlayerStat(STAT_STAMINA_MAX, STAT_BONUS_OPTION_APPLY_BONUS)) then
      PrismaticWarning.debugAlert("Doesn't want alerts on a MagDPS")
    elseif (role == LFG_ROLE_DPS) and (not PrismaticWarning.savedVariables.alertIfStamDD) and (GetPlayerStat(STAT_STAMINA_MAX, STAT_BONUS_OPTION_APPLY_BONUS) > GetPlayerStat(STAT_MAGICKA_MAX, STAT_BONUS_OPTION_APPLY_BONUS)) then
      PrismaticWarning.debugAlert("Doesn't want alerts on a StamDPS")
    elseif GetUnitLevel('player') < 50 and not PrismaticWarning.savedVariables.alertIfUnderFifty then
      PrismaticWarning.debugAlert("Doesn't want alerts on an under 50 character")
    elseif zoneIsTrial and (not PrismaticWarning.savedVariables.alertInTrials) then
      PrismaticWarning.debugAlert("Doesn't want alerts in a trial")
    elseif zoneIsArena and (not PrismaticWarning.savedVariables.alertInArenas) then
      PrismaticWarning.debugAlert("Doesn't want alerts in an arena")
    elseif zoneIsDungeon and (not PrismaticWarning.savedVariables.alertInDungeons) then
      PrismaticWarning.debugAlert("Doesn't want alerts in dungeons")
    elseif zoneIsPartialDungeon and (not PrismaticWarning.savedVariables.alertInPartialDungeons) then
      PrismaticWarning.debugAlert("Doesn't want alerts in a partial dungeon, converted to a nungeon")
      EVENT_MANAGER:RegisterForUpdate(PrismaticWarning.name, PrismaticWarning.savedVariables.refreshRate, PrismaticWarning.NoneDungeon)
    else
      shouldWatch = true
    end
  end

  if shouldWatch then
    if PrismaticWarning.usesSpecialEvent[zoneId] then
      if PrismaticWarning.usesSpecialEvent[zoneId] == EVENT_UNIT_DEATH_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(PrismaticWarning.name .. "Death", EVENT_UNIT_DEATH_STATE_CHANGED, PrismaticWarning.bossDeathCounter)
        EVENT_MANAGER:AddFilterForEvent(PrismaticWarning.name .. "Death", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "boss1")
      elseif PrismaticWarning.usesSpecialEvent[zoneId] == EVENT_EXPERIENCE_GAIN then
        EVENT_MANAGER:RegisterForEvent(PrismaticWarning.name .. "XPGained", EVENT_EXPERIENCE_GAIN, PrismaticWarning.XPGained)
      elseif PrismaticWarning.usesSpecialEvent[zoneId] == EVENT_BOSSES_CHANGED then
        EVENT_MANAGER:RegisterForEvent(PrismaticWarning.name .. "BossesChanged", EVENT_BOSSES_CHANGED, PrismaticWarning.BossesChanged)
        EVENT_MANAGER:RegisterForEvent(PrismaticWarning.name .. "Death", EVENT_UNIT_DEATH_STATE_CHANGED, PrismaticWarning.bossDeathCounter)
        EVENT_MANAGER:AddFilterForEvent(PrismaticWarning.name .. "Death", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "boss1")
      end
    end
    
    if PrismaticWarning.zones[zoneId][5] ~= PrismaticWarning.NoneDungeon then
      PrismaticWarning.addChatMessage(GetString(PRISMATICWARNING_WATCHING))
    end
    EVENT_MANAGER:RegisterForUpdate(PrismaticWarning.name, PrismaticWarning.savedVariables.refreshRate, PrismaticWarning.zones[zoneId][5])
  end
end

-- Alert Controllers --

function PrismaticWarning.alerter(shouldEquip)
  -- Could add " and PrismaticWarning.savedVariables.hideOnScreenAlertInCombat". It adds an extra check but would pop up the alert if stuck in combat
  if PrismaticWarning.combatState then return end
  
  if PrismaticWarning.lastCall ~= shouldEquip then
    PrismaticWarning.lastCall = shouldEquip
    
    local whatToDo
    
    if shouldEquip and not PrismaticWarning.isPrismaticEquipped then
      whatToDo = GetString(PRISMATICWARNING_EQUIP_NOW)
      PrismaticWarning.alert = true
    elseif not shouldEquip and PrismaticWarning.isPrismaticEquipped then
      whatToDo = GetString(PRISMATICWARNING_UNEQUIP_NOW)
      PrismaticWarning.alert = true
    else
      PrismaticWarning.alert = false
    end
    
    if PrismaticWarning.savedVariables.equipSlot == nil then
      PrismaticWarning.addChatMessage(whatToDo)
      PrismaticWarning.alertVisible(PrismaticWarning.alert, whatToDo)
    elseif PrismaticWarning.alert then
      PrismaticWarning.equipper(shouldEquip)
    end
  end
end

function PrismaticWarning.XPGained(_, reason)
  if PrismaticWarning.caresAboutXPGain and reason == PROGRESS_REASON_SCRIPTED_EVENT then
    PrismaticWarning.specialEventTrigger = true
  end
end

function PrismaticWarning.BossesChanged(_, forced)
  if forced then
    PrismaticWarning.specialEventTrigger = true
  end
end

function PrismaticWarning.bossDeathCounter(_, _, isDead)
  if isDead then
    PrismaticWarning.counter = PrismaticWarning.counter + 1
    PrismaticWarning.debugAlert("Counter at " .. PrismaticWarning.counter)
  end
end

function PrismaticWarning.currentLocation()
  local x, y = GetMapPlayerPosition('player')
  
  if PrismaticWarning.zoneId ~= GetZoneId(GetCurrentMapZoneIndex()) then -- if they are viewing a different zone in the map 
    x = PrismaticWarning.x
    y = PrismaticWarning.y
  else
    PrismaticWarning.x = x
    PrismaticWarning.y = y
  end
  
  return x * 100, y * 100
end

function PrismaticWarning.dungeonComplete(endOfDungeon, shouldEquip)
  if endOfDungeon then
    if PrismaticWarning.combatState then
      -- copied from alerter to solve issue #24 in GitHub
      local whatToDo
      
      if shouldEquip and not PrismaticWarning.isPrismaticEquipped then
        whatToDo = GetString(PRISMATICWARNING_EQUIP_NOW)
        PrismaticWarning.alert = true
      elseif not shouldEquip and PrismaticWarning.isPrismaticEquipped then
        whatToDo = GetString(PRISMATICWARNING_UNEQUIP_NOW)
        PrismaticWarning.alert = true
      else
        PrismaticWarning.alert = false
      end
      
      if PrismaticWarning.alert then
        PrismaticWarning.addChatMessage(whatToDo)
        PrismaticWarning.alertVisible(not PrismaticWarning.savedVariables.hideOnScreenAlertInCombat, whatToDo)
      end
    end
    PrismaticWarning.addChatMessage(GetString(PRISMATICWARNING_DONE_WATCHING))
  else
    PrismaticWarning.alert = false
    PrismaticWarning.alertVisible(false, "")
  end
  
  EVENT_MANAGER:UnregisterForUpdate(PrismaticWarning.name)
  EVENT_MANAGER:UnregisterForEvent(PrismaticWarning.name .. "Death", EVENT_UNIT_DEATH_STATE_CHANGED)
  EVENT_MANAGER:UnregisterForEvent(PrismaticWarning.name .. "XPGained", EVENT_EXPERIENCE_GAIN)
  PrismaticWarning.caresAboutXPGain = false
  PrismaticWarning.specialEventTrigger = false
  PrismaticWarning.findFail = false
  PrismaticWarning.counter = 0
  PrismaticWarning.lastCall = nil
end

function PrismaticWarning.gearChanged(_, bag, slot) 
  if slot == EQUIP_SLOT_BACKUP_MAIN or slot == EQUIP_SLOT_MAIN_HAND then
    PrismaticWarning.findFail = false
    PrismaticWarning.lastCall = nil -- to allow alerter to check if they equipped the right weapon
    PrismaticWarning.alertVisible(false, "")
    PrismaticWarning.alert = false
    PrismaticWarning.updateUnequippedItemId()
    
    if PrismaticWarning.isWeaponPrismatic(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN) or PrismaticWarning.isWeaponPrismatic(BAG_WORN, EQUIP_SLOT_MAIN_HAND) then
      PrismaticWarning.isPrismaticEquipped = true
    else
      PrismaticWarning.isPrismaticEquipped = false
    end
  end
end

function PrismaticWarning.updateCombatState(_, inCombat)
  PrismaticWarning.combatState = inCombat
  if PrismaticWarning.savedVariables.hideOnScreenAlertInCombat and PrismaticWarning.alert then
    PrismaticWarningWindow:SetHidden(inCombat)
  end
end

-- Chat and Gear --

function PrismaticWarning.isWeaponPrismatic(bag, slot)
  if GetItemLinkAppliedEnchantId(GetItemLink(bag, slot, LINK_STYLE_DEFAULT)) == 147 then -- covers CP160 and CP150 gold glyphs, at least
    return true
  else
    return false
  end
end

function PrismaticWarning.equipper(equipAPrismatic)
-- * CompareId64s(*id64* _firstId_, *id64* _secondId_)
-- ** _Returns:_ *integer* _result_

  local itemSlot, unequippedItemId
  local numSlots = GetBagSize(BAG_BACKPACK)

  if PrismaticWarning.prismaticItemId == nil then
    for slot = 0, numSlots do
      if GetItemWeaponType(BAG_BACKPACK, slot) ~= WEAPONTYPE_NONE and PrismaticWarning.isWeaponPrismatic(BAG_BACKPACK, slot) then
        PrismaticWarning.prismaticItemId = GetItemUniqueId(BAG_BACKPACK, slot)
        PrismaticWarning.debugAlert("Found a prismatic")
        break
      end
    end
    if PrismaticWarning.prismaticItemId == nil then
      PrismaticWarning.addChatMessage(GetString(PRISMATICWARNING_NO_PRISMATIC_IN_INV))
      PrismaticWarning.findFail = true
    end
  end
  
  if equipAPrismatic then
    unequippedItemId = PrismaticWarning.prismaticItemId
  else
    unequippedItemId = PrismaticWarning.nonPrismaticItemId
  end

  if unequippedItemId == nil then
    PrismaticWarning.debugAlert("Don't know what to equip")
  else
    for slot = 0, numSlots do
      if GetItemWeaponType(BAG_BACKPACK, slot) ~= WEAPONTYPE_NONE and unequippedItemId == GetItemUniqueId(BAG_BACKPACK, slot) then
        itemSlot = slot
        break
      end
    end
  end

  if itemSlot == nil then
    local str = GetString(PRISMATICWARNING_AUTO_SWAP_FAILED)
    if equipAPrismatic then
      str = str .. string.lower(GetString(PRISMATICWARNING_EQUIP_NOW))
    else
      str = str .. string.lower(GetString(PRISMATICWARNING_UNEQUIP_NOW))
    end
    PrismaticWarning.addChatMessage(str)
    PrismaticWarning.alertVisible(true, str)
  else
    PrismaticWarning.updateUnequippedItemId()
    
    EquipItem(BAG_BACKPACK, itemSlot, PrismaticWarning.savedVariables.equipSlot)
    PrismaticWarning.addChatMessage(GetString(PRISMATICWARNING_AUTO_SWAP_SUCCESS))
    
    -- remove poisons if equipped on bar where the prismatic was/is equipped
    if GetItemUniqueId(BAG_WORN, PrismaticWarning.savedVariables.poisonSlot) ~= nil then
      local emptySlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
      if emptySlot == nil then
        PrismaticWarning.debugAlert("No space in inventory for unequipping poisons")
      else
        CallSecureProtected("RequestMoveItem", BAG_WORN, PrismaticWarning.savedVariables.poisonSlot, BAG_BACKPACK, emptySlot, 200)
      end
    end
  end
  
  if not PrismaticWarning.findFail then -- issue #40 in GitHub
    PrismaticWarning.lastCall = nil -- issue #22 in GitHub
  end

end

function PrismaticWarning.updateUnequippedItemId()
  if PrismaticWarning.isWeaponPrismatic(BAG_WORN, PrismaticWarning.savedVariables.equipSlot) then -- this doesn't throw an error if equipSlot is nil
    PrismaticWarning.prismaticItemId = GetItemUniqueId(BAG_WORN, PrismaticWarning.savedVariables.equipSlot)
  else
    PrismaticWarning.nonPrismaticItemId = GetItemUniqueId(BAG_WORN, PrismaticWarning.savedVariables.equipSlot)
  end
end

function PrismaticWarning.debugAlert(message)
  if PrismaticWarning.savedVariables.debugAlerts then
    CHAT_SYSTEM:AddMessage("[Prismatic Warning] " .. message)
  end
end

function PrismaticWarning.addChatMessage(message)
  if PrismaticWarning.savedVariables.alertToChat and message ~= nil then
    CHAT_SYSTEM:AddMessage("[Prismatic Warning] " .. message)
  end
end

-- On-Screen Alert --

function PrismaticWarning.InitializeUI()
  PrismaticWarningWindowLabelBG:ClearAnchors()
  PrismaticWarningWindowLabelBG:SetAnchor(TOPLEFT, PrismaticWarningWindow, CENTER, PrismaticWarning.savedVariables.left, PrismaticWarning.savedVariables.top)
  
  PrismaticWarning.updateFont()
  
  PrismaticWarningWindowLabel:SetText(string.upper(GetString(PRISMATICWARNING_ALERT)))
  PrismaticWarningWindowLabel:SetColor(unpack(PrismaticWarning.savedVariables.fontColor))
  PrismaticWarningWindowInfo:SetColor(unpack(PrismaticWarning.savedVariables.fontColor))
  PrismaticWarningWindowLabelBG:SetMouseEnabled(not PrismaticWarning.savedVariables.isLocked)

  if PrismaticWarning.savedVariables.hideOnScreenAlertInCombat and PrismaticWarning.alert then
    PrismaticWarningWindow:SetHidden(PrismaticWarning.combatState)
  end
  
  PrismaticWarning.alertVisible(false, "")
end

function PrismaticWarning.savePosition()
  PrismaticWarning.savedVariables.left = PrismaticWarningWindowLabelBG:GetLeft()
  PrismaticWarning.savedVariables.top = PrismaticWarningWindowLabelBG:GetTop()
end

function PrismaticWarning.updateFont()
  if PrismaticWarning.savedVariables.fontOutline == "none" then
    PrismaticWarningWindowLabel:SetFont(PrismaticWarning.savedVariables.fontName .. "|" .. PrismaticWarning.savedVariables.fontSize)
    PrismaticWarningWindowInfo:SetFont(PrismaticWarning.savedVariables.fontName .. "|" .. PrismaticWarning.savedVariables.infoFontSize)
  else
    PrismaticWarningWindowLabel:SetFont(PrismaticWarning.savedVariables.fontName .. "|" .. PrismaticWarning.savedVariables.fontSize .. "|" ..  PrismaticWarning.savedVariables.fontOutline)
    PrismaticWarningWindowInfo:SetFont(PrismaticWarning.savedVariables.fontName .. "|" .. PrismaticWarning.savedVariables.infoFontSize .. "|" ..  PrismaticWarning.savedVariables.fontOutline)
  end
end

function PrismaticWarning.alertVisible(visible, setText)
  if not PrismaticWarning.savedVariables.hideOnScreenAlert then
    PrismaticWarningWindowInfo:SetText(string.upper(setText))
    PrismaticWarningWindow:SetHidden(not visible)
  end
end 

EVENT_MANAGER:RegisterForEvent(PrismaticWarning.name, EVENT_ADD_ON_LOADED, PrismaticWarning.OnAddOnLoaded)