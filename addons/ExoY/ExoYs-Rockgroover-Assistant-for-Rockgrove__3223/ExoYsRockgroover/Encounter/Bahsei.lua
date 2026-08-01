Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.bahsei = ERG.bahsei or {}
local Bahsei = ERG.bahsei

local mechanicId = {
  ["cursedGround"] = 152475,
  ["eyeRotationNegative"] = 153517, --CW
  ["eyeRotationPositive"] = 153518, --CCW
  ["fireBehemoth"] = 152525,
  ["hemorrhagingSmack"] = 150008,
  ["meteorSwarm"] = 155357,
  --["rancidHammer"] = 149922,
  ["scaldingStrike"] = 153175,
  ["sickleStrike"] = 150067,
  ["bloodyBash"] = 153180,

}

function Bahsei.GetMechanicIds()
  return mechanicId
end

local mechanicData = {
  [mechanicId.bloodyBash] = {color = {0.65,0,0,1} },
  [mechanicId.cursedGround] = { color = {0,0.8,1,1}, icon = "/esoui/art/icons/ability_mage_028.dds", cooldown = 28000 },
  [mechanicId.eyeRotationNegative] = { name = "Clockwise", color = {0.3,0,1,1}, icon = "/esoui/art/icons/achievement_ic_026.dds"},
  [mechanicId.eyeRotationPositive] = { name = "Counter Clockwise", color = {1,0.4,0.9,1}, icon = "/esoui/art/icons/achievement_ic_026_heroic.dds"},
  [mechanicId.fireBehemoth] = { color = {1,0.8,0,1}, icon = "/esoui/art/icons/achievement_u30_oblivionportalgenerals.dds"},
  [mechanicId.hemorrhagingSmack] = { color = {1,0,0,1} },
  [mechanicId.meteorSwarm] = { color = {0.65,0,0,1}, cooldown = 26000 },
  --[mechanicId.rancidHammer] = { color = {1,0.8,0,1}, cooldown = 20000, result = ACTION_RESULT_BEGIN,  },
  [mechanicId.scaldingStrike] = { color = {1,0.5,0,1}, icon = "/esoui/art/icons/ability_artifact_volendrung_006.dds" },
  [mechanicId.sickleStrike] = {color = {1,0,0,1}, icon = "/esoui/art/icons/ability_necromancer_007_a.dds", cooldown = 15000, result = ACTION_RESULT_BEGIN}
}

function Bahsei.GetMechanicData()
  return mechanicData
end


function Bahsei.OnMeteorSwarm()
  if not ERG.anticipation.GetActiveState("bahsei", mechanicId.meteorSwarm) then
    ERG.anticipation.SetActiveState("bahsei", mechanicId.meteorSwarm, true)
  end
  local function Warning()
    local timeRemaining = ERG.GetRemainingMilliseconds( Bahsei.meteorExplodeTime )
    if timeRemaining == 0 then ERG.healthFrame.Hide() end
    if timeRemaining > 10000 then
      return zo_strformat("<<1>> <<2>>", "Landing", ERG.GetTimeRemaining(Bahsei.meteorExplodeTime-10000, true))
    else
      return zo_strformat("<<1>> <<2>>", "Explosion", ERG.GetTimeRemaining(Bahsei.meteorExplodeTime, true))
    end
  end

  local meteorHp = {
    [1] = 158431,  --normal
    [2] = 291077,  -- veteran --323419
    [3] = 509385,  --veteran hardmode --565983
  }

  local maxHp = meteorHp[ ERG.GetCustomDifficulty() ]
  if not maxHp then return end
  Bahsei.meteorExplodeTime = GetGameTimeMilliseconds() + 13500
  zo_callLater(function() Bahsei.meteorExplodeTime = nil end, 14000)
  ERG.anticipation.OnCast("bahsei",mechanicId.meteorSwarm, mechanicData[mechanicId.meteorSwarm].cooldown)
  ERG.healthFrame.Show( maxHp , Warning)
end

function Bahsei.OnCursedGround()
  ERG.anticipation.OnCast("bahsei",mechanicId.cursedGround, mechanicData[mechanicId.cursedGround].cooldown)
end

function Bahsei.OnHemorrhagingSmack()
  --ERG.anticipation.OnCast("bahsei",mechanicId.hemorrhagingSmack, mechanicData[mechanicId.hemorrhagingSmack].cooldown)
end

function Bahsei.OnNegativeRotation()
  Bahsei.portalTracker.data.direction = mechanicId.eyeRotationNegative
  Bahsei.portalTracker.data.isPortal = true
end

function Bahsei.OnPositiveRotation()
  Bahsei.portalTracker.data.direction = mechanicId.eyeRotationPositive
  Bahsei.portalTracker.data.isPortal = true
end


local notificationList = {
  [mechanicId.bloodyBash] = {
    ["OnCastAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
        [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
      },
      dynamicFilter = {
        ["targetType"] = COMBAT_UNIT_TYPE_PLAYER,
      },
      duration = 600,
    },
  },
  [mechanicId.cursedGround] = {
    ["OnTextAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
          [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
      },
      callback = Bahsei.OnCursedGround
    },
  },
  [mechanicId.eyeRotationNegative] = {
    ["OnBannerAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
          [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_EFFECT_GAINED,
      },
      duration = 5000,
      callback = Bahsei.OnNegativeRotation,
    },
  },
  [mechanicId.eyeRotationPositive] = {
    ["OnBannerAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
          [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_EFFECT_GAINED,
      },
      duration = 5000,
      callback = Bahsei.OnPositiveRotation,
    },
  },
  [mechanicId.hemorrhagingSmack] = {
    ["OnTextAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
          [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
      },
      callback = Bahsei.OnHemorrhagingSmack,
    },
  },
  [mechanicId.scaldingStrike] = {
    ["OnTextAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
          [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
      },
    },
  },
}

function Bahsei.GetNotificationList()
  return notificationList
end


local CCA_Settings = {
      eye = {name = ERG_CCA_CREEPING_EYE_DIRECTION, refId = 153517, icon = "/esoui/art/icons/achievement_ic_016.dds"},
      convoke = {},
      meteorSwarm = {},
      takingAim = {icon = "/esoui/art/icons/death_recap_cold_ranged_arrow.dds"},
}

--function Bahsei.Get_CCA_Settings()
--  return CCA_Settings
--end


function Bahsei.GetSpecialDefaults()
  local specialDefaults = {}
  specialDefaults["anticipation"] = Bahsei.GetAnticipationDefaults()
  specialDefaults["portalTracker"] = Bahsei.GetPortalTrackerDefaults()
  specialDefaults["debuffIndicator"] = Bahsei.GetDebuffIndicatorDefaults()
  specialDefaults["addTracker"] = Bahsei.GetAddTrackerDefaults()
  specialDefaults[mechanicId.fireBehemoth] = {
    OnTextAlertText = GetAbilityName(mechanicId.fireBehemoth),
    OnTextAlert = true,
    color = mechanicData[mechanicId.fireBehemoth].color,
    sound = "None",
  }
  return specialDefaults
end

function Bahsei.GetAdditionalNotificationMenu()
  return {
    [mechanicId.fireBehemoth] = {
      header = ERG.GetMenuAbilityName(mechanicId.fireBehemoth, mechanicData),
      notification = "OnTextAlert",
      warning = ERG_MENU_WARNING_SUBTITLE,
    },
  }
end

function Bahsei.GetPanelMenus()
  local panelMenu = {}
  table.insert(panelMenu, {
    type="button",
    name=ERG_SHOW_HIDE,
    func = function() ERG.DemoPanel("bahsei") end,
    width = "half",
  })
  table.insert(panelMenu, Bahsei.GetAnticipationMenu() )
  table.insert(panelMenu, Bahsei.GetPortalTrackerMenu() )
  table.insert(panelMenu, Bahsei.GetAddTrackerMenu() )
  --table.insert(panelMenu, Bahsei.GetDebuffIndicatorMenu() )
  return panelMenu
end



function Bahsei.Initialize()
  Bahsei.name = ERG.name.."Bahsei"

  Bahsei.fragList = {}
  Bahsei.fragListForHardmode = {}
  Bahsei.InitializeAnticipationPanel( mechanicData )
  Bahsei.InitializePortalTracker()
  Bahsei.InitializeDebuffIndicator()
  Bahsei.InitializeAddTracker()

  for _, subtitle in ipairs( ERG.GetBehemothSubtitleList() ) do
    ERG.notifications.RegisterSubtitle("bahsei", subtitle, function() ERG.notifications.OnTextAlert("bahsei", mechanicId.fireBehemoth) end)
  end

  ERG.EM:RegisterForEvent(Bahsei.name.."OnMeteorSwarm", EVENT_COMBAT_EVENT, Bahsei.OnMeteorSwarm)
  ERG.EM:AddFilterForEvent(Bahsei.name.."OnMeteorSwarm", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION)
  ERG.EM:AddFilterForEvent(Bahsei.name.."OnMeteorSwarm", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, mechanicId.meteorSwarm)
end

function Bahsei.OnCombatStart()
  ERG.anticipation.SetActiveState( "bahsei", mechanicId.meteorSwarm )
  Bahsei.portalTracker.data = {isHope = false, isPortal = false, nextPortal = GetGameTimeMilliseconds() + 20000, hopeEnd = GetGameTimeMilliseconds(), playerInside = {}, portalNumber = 0}
  Bahsei.UpdatePortalTrackerStaticLabels()
  ERG.anticipation.RebuildPanel("bahsei")
  Bahsei.addTracker.abomination = { counter = 0, unitList = { number = {}, id = {}} , aoeCountdown = {} }
end

function Bahsei.GetFragList( returnAll )
  local fragList = {}
  for _, data in ipairs( Bahsei.fragList ) do
    if returnAll then
      table.insert(fragList, data.frag)
    else
      if data.IsEnabled() then
        table.insert(fragList, data.frag)
      end
    end
  end
  return fragList
end

function Bahsei.OnHardmodeChange( isHm )
  if isHm and ERG.store.bahsei.portalTracker.enabled then
    HUD_UI_SCENE:AddFragment( Bahsei.portalTracker.frag )
    HUD_SCENE:AddFragment( Bahsei.portalTracker.frag )
  else
    HUD_UI_SCENE:RemoveFragment( Bahsei.portalTracker.frag )
    HUD_SCENE:RemoveFragment( Bahsei.portalTracker.frag )
  end
end

function Bahsei.OnUpdate()
  Bahsei.OnAnticipationPanelUpdate()
  Bahsei.OnPortalTrackerUpdate()
  Bahsei.OnDebuffIndicatorUpdate()
  Bahsei.OnAddTrackerUpdate()
end

function Bahsei.OnProfileChange()
  Bahsei.AdaptAnticipationPanelAccordingToProfile()
  Bahsei.AdaptPortalTrackerAccordingToProfile()
  --Bahsei.AdaptDebuffIndicatorAccordingToProfile()
  Bahsei.AdaptAddTrackerAccordingToProfile()
end

-------------------
-- Track Enemies --
-------------------

function Bahsei.OnMeteorSwarmSpawn(spawn, unitId )
  if not Bahsei.meteorExplodeTime then return end
  if spawn then
    ERG.units.damage[unitId] = 0
    ERG.healthFrame.SetTrackedUnit( unitId )
  else
    ERG.units.damage[unitId] = nil
    ERG.healthFrame.Hide()
  end
end

function Bahsei.OnRancidHammer(spawn, unitId)
  if spawn then
    --d("Detect Abomination "..tostring(unitId) )
  else
    --d("Killed Abomination "..tostring(unitId) )
  end
end

function Bahsei.GetIdentifyEnemyList()
  return {
    [152735] = Bahsei.OnMeteorSwarmSpawn,
    [153180] = Bahsei.OnRancidHammer,
    --[149922] = Bahsei.OnRancidHammer, --doesnt work
    --[4583] = Bahsei.OnSlimCraw,--WARNING
  }
end
