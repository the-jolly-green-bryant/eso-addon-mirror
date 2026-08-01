Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.oaxiltso = ERG.oaxiltso or {}
local Oaxiltso = ERG.oaxiltso

local mechanicId = {
  ["blazingBoon"] = 152502,
  ["blazingBoonMini"] = 152503,
  ["blisteringSmash"] = 149531,
  ["magmaPool"] = 153400,
  ["magmaSludge"] = 153713,
  ["meteorCrash"] = 152365,
  ["moltenEarth"] = 149232,
  ["noxiousSludge"] = 149190,
  ["poisoned"] = 157860,
  ["ravenousChomp"] = 149648,
  ["savageBlitz"] = 149414,
  ["sunburst"] = 153181,
 }


function Oaxiltso.GetMechanicIds()
  return mechanicId
end

local mechanicData = {
  [mechanicId.blazingBoon] = { color = {0.65,0,0,1}, icon = "/esoui/art/icons/achievement_u30_groupboss6.dds"},
  [mechanicId.blazingBoonMini] = { color = {0.65,0,0,1}, icon = "/esoui/art/icons/u30_trial_mehrunesfavor.dds"},
  [mechanicId.blisteringSmash] = { color = {1,0.8,0,1}, icon = "/esoui/art/icons/ability_u27_behemothbonecrusher.dds", cooldown = 22000, result = ACTION_RESULT_BEGIN, start  = 12000},
  [mechanicId.magmaSludge] = { color = {1,0.55,0,1}, icon = "/esoui/art/icons/death_recap_fire_ranged.dds"},
  [mechanicId.meteorCrash] = { color = {0.7,0,1,1}, icon = "/esoui/art/icons/u30_trial_meteorcall.dds"},
  [mechanicId.moltenEarth] = { color = {1,0.8,0,1}, icon = "/esoui/art/icons/ability_u27_behemothtremor.dds", cooldown = 28000, result = ACTION_RESULT_BEGIN, start = 6000},
  [mechanicId.noxiousSludge] = { color = {0,0.8,0,1}, icon = "/esoui/art/icons/death_recap_poison_ranged.dds", cooldown = 27000, start = 15000 },
  [mechanicId.poisoned] = {name = ERG_OAXILTSO_POISONED, color = {0,0.8,0,1}},
  [mechanicId.ravenousChomp] = { color = {1,0.8,0,1}, icon = "/esoui/art/icons/ability_u27_behemothviciousgnaw.dds", cooldown = 10000, result = ACTION_RESULT_BEGIN, start = 12000},
  [mechanicId.savageBlitz] = { color = {0.1,0.6,1,1}, icon = "/esoui/art/icons/ability_u27_behemothbitterboom.dds", iconId = 161042, cooldown = 38000, action = "Dodge!", alternativeIds = {157932}, start = 15000 }, --"/esoui/art/icons/ability_u27_behemothrampage.dds"
  [mechanicId.sunburst] = { color = {1,0.8,0,1}, icon = "/esoui/art/icons/ava_siege_ui_002.dds"},
}

function Oaxiltso.GetMechanicData()
  return mechanicData
end

---------------
-- Callback --
---------------

function Oaxiltso.OnNoxiousSludge()
  ERG.anticipation.OnCast("oaxiltso", mechanicId.noxiousSludge, mechanicData[mechanicId.noxiousSludge].cooldown)
  Oaxiltso.UpdatePoisonCounter()
end

function Oaxiltso.OnSavageBlitz()
  ERG.anticipation.OnCast("oaxiltso", mechanicId.savageBlitz, mechanicData[mechanicId.savageBlitz].cooldown)
end

function Oaxiltso.OnMeteorCrash()
  Oaxiltso.numMeteorCrash = Oaxiltso.numMeteorCrash + 1
end

------------------
-- Notification --
------------------

local notificationList = {
  [mechanicId.meteorCrash] = {
    ["OnBannerAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
          [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_EFFECT_GAINED,
      },
      delay = 5000,
      duration = 4500,
      callback = Oaxiltso.OnMeteorCrash
    },
  },
  [mechanicId.noxiousSludge] = {
    ["OnTextAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
        [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
      },
      callback = Oaxiltso.OnNoxiousSludge
    },
  },
  [mechanicId.poisoned] = {
    ["OnTextAlert"] = {
      event = EVENT_EFFECT_CHANGED,
      staticFilter = {
        [REGISTER_FILTER_UNIT_TAG] = "player",
      },
      dynamicFilter = {
        ["changeType"] = EFFECT_RESULT_GAINED,
      },
    },
  },
  [mechanicId.savageBlitz] = {
    ["OnCastAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
        [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
      },
      dynamicFilter = {
        ["targetType"] = COMBAT_UNIT_TYPE_PLAYER,
      },
      duration = 2750,
      callback = Oaxiltso.OnSavageBlitz
    },
  },
  [mechanicId.sunburst] = {
    -- castAlert in CCA enthalten
    ["OnTextAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
        [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
      },
      delay = 2500,
    },
  },
}

function Oaxiltso.GetNotificationList()
  return notificationList
end

local CCA_Settings = {
  cinder = {tooltip = ERG_OAXILTSO_CCA_TT_CINDER},
  standingInAoe = {id = 157859, tooltip = ERG_OAXILTSO_CCA_TT_NOXIOUS_PUDDLE},
  blitz = {refId = 149414, tooltip = ERG_OAXILTSO_CCA_TT_SAVAGE_BLITZ},
}

--function Oaxiltso.Get_CCA_Settings()
--  return CCA_Settings
--end


function Oaxiltso.GetSpecialDefaults()
  local specialDefaults = {}
  specialDefaults["anticipation"] = Oaxiltso.GetAnticipationDefaults()
  specialDefaults["poolTracker"] = Oaxiltso.GetPoolTrackerDefaults()
  specialDefaults["poisonTracker"] = Oaxiltso.GetPoisonTrackerDefaults()
  specialDefaults[mechanicId.blazingBoon] = {
    OnTextAlertText = GetAbilityName(mechanicId.blazingBoon),
    OnTextAlert = true,
    color = mechanicData[mechanicId.blazingBoon].color,
    sound = "None",
  }
  specialDefaults[mechanicId.blazingBoonMini] = {
    OnTextAlertText = GetAbilityName(mechanicId.blazingBoonMini),
    OnTextAlert = true,
    color = mechanicData[mechanicId.blazingBoonMini].color,
    sound = "None",
  }
  specialDefaults[mechanicId.magmaSludge] = {
    OnTextAlertText = GetAbilityName(mechanicId.magmaSludge),
    OnTextAlert = true,
    color = mechanicData[mechanicId.magmaSludge].color,
    sound = "None",
  }
  return specialDefaults
end

function Oaxiltso.GetAdditionalNotificationMenu()
  return {
    [mechanicId.blazingBoon] = {
      header = ERG.GetMenuAbilityName(mechanicId.blazingBoon, mechanicData),
      notification = "OnTextAlert",
    },
    [mechanicId.blazingBoonMini] = {
      header = ERG.GetMenuAbilityName(mechanicId.blazingBoonMini, mechanicData),
      notification = "OnTextAlert",
    },
    [mechanicId.magmaSludge] = {
      header = ERG.GetMenuAbilityName(mechanicId.magmaSludge, mechanicData),
      notification = "OnTextAlert",
    }
  }
end

function Oaxiltso.GetPanelMenus()
  local panelMenu = {}
  table.insert(panelMenu, {
    type="button",
    name=ERG_SHOW_HIDE,
    func = function() ERG.DemoPanel("oaxiltso") end,
    width = "half",
  })
  table.insert(panelMenu, Oaxiltso.GetAnticipationMenu() )
  table.insert(panelMenu, Oaxiltso.GetPoisonTrackerMenu() )
  table.insert(panelMenu, Oaxiltso.GetPoolTrackerMenu() )
  return panelMenu
end


function Oaxiltso.IndicateEnrage( show )
  local panelList = {"poolTracker", "poisonTracker", "anticipation"}
  for _, panelName in pairs(panelList) do
    local panel = Oaxiltso[panelName].panel
    local store = ERG.store.oaxiltso[panelName]
    if not store.enrage then show = false end
    --panel.edge:SetHidden( not show ) --WARNING
    if store.back.enabled then
      panel.back:SetCenterColor(unpack(show and {0.4,0,0, store.back.opacity} or {0,0,0, store.back.opacity} ))
    end
  end
  Oaxiltso.isEnrage = show
end

function Oaxiltso.OnEnrageBoss(_, changeType)
  if changeType == EFFECT_RESULT_FADED then
    Oaxiltso.IndicateEnrage(false)
    return
  end
  if Oaxiltso.isEnrage then return end
  ERG.notifications.OnTextAlert("oaxiltso", mechanicId.blazingBoon)
  Oaxiltso.IndicateEnrage(true)
end

function Oaxiltso.OnEnrageMini(_, changeType)
  if changeType == EFFECT_RESULT_FADED then
    Oaxiltso.isMiniEnrage = false
    return
  end
  if Oaxiltso.isMiniEnrage then return end
  ERG.notifications.OnTextAlert("oaxiltso", mechanicId.blazingBoonMini)
  Oaxiltso.isMiniEnrage = true
end

--/script Rockgroover.notifications.OnTextAlert("oaxiltso", 153713)
function Oaxiltso.OnMagmaSludge()
  if GetGameTimeMilliseconds()-Oaxiltso.lastMagmaSludge < 12000 then return end
  Oaxiltso.lastMagmaSludge = GetGameTimeMilliseconds()
  ERG.notifications.OnTextAlert("oaxiltso", mechanicId.magmaSludge)
end


function Oaxiltso.Initialize()
  Oaxiltso.name = ERG.name.."Oaxiltso"

  Oaxiltso.demoPanel = false
  Oaxiltso.fragList = {}
  Oaxiltso.fragListForHardmode = {}
  Oaxiltso.InitializeAnticipationPanel( mechanicData )
  Oaxiltso.InitializePoisonTracker()
  Oaxiltso.InitializePoolTracker()

  Oaxiltso.ResetVariables()

  -- Exceptions
  ERG.EM:RegisterForEvent( Oaxiltso.name.."EnrageBoss", EVENT_EFFECT_CHANGED, Oaxiltso.OnEnrageBoss )
  ERG.EM:AddFilterForEvent( Oaxiltso.name.."EnrageBoss", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mechanicId.blazingBoon)

  ERG.EM:RegisterForEvent( Oaxiltso.name.."EnrageMini", EVENT_EFFECT_CHANGED, Oaxiltso.OnEnrageMini )
  ERG.EM:AddFilterForEvent( Oaxiltso.name.."EnrageMini", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mechanicId.blazingBoonMini)

  ERG.EM:RegisterForEvent( Oaxiltso.name.."MagmaSludge", EVENT_COMBAT_EVENT, Oaxiltso.OnMagmaSludge )
  ERG.EM:AddFilterForEvent( Oaxiltso.name.."MagmaSludge", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, mechanicId.magmaSludge)
  ERG.EM:AddFilterForEvent( Oaxiltso.name.."MagmaSludge", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
end


function Oaxiltso.ResetVariables()
  Oaxiltso.lastMagmaSludge = GetGameTimeMilliseconds()
  --PoisonTracker
  Oaxiltso.numMeteorCrash = 0
  Oaxiltso.countPoisons = false
  Oaxiltso.poisonTracker.number = 1
  Oaxiltso.poisonTracker.list = {}
  Oaxiltso.UpdatePoisonCounter()
  Oaxiltso.UpdatePoisonTrackerStaticLabels()
  --PoolTracker
  for i = 1,4 do
    Oaxiltso.poolTracker.cleanse[i] = GetGameTimeMilliseconds()
    Oaxiltso.poolTracker.magma[i] = false
  end
  --Anticipation
  for id, data in pairs( mechanicData ) do
    if data.cooldown then
      local startValue = data.start or 0
      Oaxiltso.anticipation.nextCast[id] = GetGameTimeMilliseconds() + startValue
    end
  end
end

function Oaxiltso.OnCombatStart()
  Oaxiltso.ResetVariables()
end

function Oaxiltso.OnCombatEnd()
  Oaxiltso.ResetVariables()
  Oaxiltso.IndicateEnrage( false )
end

function Oaxiltso.GetFragList( returnAll )
  local fragList = {}
  for _, data in ipairs( Oaxiltso.fragList ) do
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

function Oaxiltso.OnUpdate()
  Oaxiltso.OnAnticipationPanelUpdate()
  Oaxiltso.OnPoisonTrackerUpdate()
  Oaxiltso.OnPoolTrackerUpdate()
end

function Oaxiltso.OnProfileChange()
  Oaxiltso.AdaptAnticipationPanelAccordingToProfile()
  Oaxiltso.AdaptPoisonTrackerAccordingToProfile()
  Oaxiltso.AdaptPoolTrackerAccordingToProfile()
end

function Oaxiltso.OnHardmodeChange( isHm )
  Oaxiltso.AdaptPoisonTrackerAccordingToHardmode( isHm )
end

--

function Oaxiltso.OnAnnihilator(spawn, unitId)
  if spawn then
    d("Detect Annihilator "..tostring(unitId) )
  else
    d("Killed Annihilator "..tostring(unitId) )
  end
end

function Oaxiltso.GetIdentifyEnemyList()
  return {
    [153181] = Oaxiltso.OnAnnihilator, --sunburst
  }
end
