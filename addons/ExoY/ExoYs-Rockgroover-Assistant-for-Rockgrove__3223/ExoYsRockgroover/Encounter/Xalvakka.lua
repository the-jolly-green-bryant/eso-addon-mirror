Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.xalvakka = ERG.xalvakka or {}
local Xalvakka = ERG.xalvakka

local mechanicId = {
  ["deadstar"] = 149075,
  ["volatailShell"] = 149294,
  ["flamePortal"] = 157390, --port on first floor
  ["scathingEvisceration"] = 153444, --very first HA
  ["soulResonance"] = 152993, --debuff -> synergie
  ["unstableCharge"] = 153164, --on blob
}

function Xalvakka.GetMechanicIds()
  return mechanicId
end

local mechanicData = {
  [mechanicId.flamePortal] = {color = {0,1,1,1}, cooldown = 35000, start = 30000, result = ACTION_RESULT_BEGIN},
  [mechanicId.volatailShell] = {color = {0,1,1,1}, cooldown = 65000, result = ACTION_RESULT_BEGIN},
  [mechanicId.deadstar] = {color = {1,0,0,1}, },
  [mechanicId.soulResonance] = {color = {0,1,1,1} },
  --[mechanicId.unstableCharge] = {color = {0,1,0,1} },
}

--------------
-- Callback --
--------------

function Xalvakka.OnDeadstar()
  if Xalvakka.waitForDeadstar then
    Xalvakka.OnFloorBegin()
  end
end

function Xalvakka.OnUnstableCharge(_, changeType)
  if changeType == EFFECT_RESULT_GAINED then
    CombatAlerts.AlertBorder(true, 15000, "green")
  elseif changeType == EFFECT_RESULT_FADED then
    CombatAlerts.AlertBorder(false)
  end
end
------------------
-- Notification --
------------------

function Xalvakka.GetMechanicData()
  return mechanicData
end

local notificationList = {
  [mechanicId.deadstar] = {
    ["OnTextAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
          [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
      },
      callback = Xalvakka.OnDeadstar
    },
  },
  [mechanicId.soulResonance] = {
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
}

function Xalvakka.GetNotificationList()
  return notificationList
end


function Xalvakka.GetSpecialDefaults()
  local specialDefaults = {}
  specialDefaults["anticipation"] = Xalvakka.GetAnticipationDefaults()
  return specialDefaults
end

function Xalvakka.GetPanelMenus()
  local panelMenu = {}
  table.insert(panelMenu, {
    type="button",
    name= ERG_SHOW_HIDE,
    func = function() ERG.DemoPanel("xalvakka") end,
    width = "half",
  })
  table.insert(panelMenu, Xalvakka.GetAnticipationMenu() )
  return panelMenu
end


function Xalvakka.Initialize()
  Xalvakka.name = ERG.name.."Xalvakka"

  Xalvakka.fragList = {}
  Xalvakka.floor = 1

  Xalvakka.InitializeAnticipationPanel(mechanicData)
  Xalvakka.InitializeSpawnTracker()


  ERG.EM:RegisterForEvent( Xalvakka.name.."OnBlob", EVENT_EFFECT_CHANGED, Xalvakka.OnUnstableCharge )
  ERG.EM:AddFilterForEvent( Xalvakka.name.."OnBlob", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mechanicId.unstableCharge)
  ERG.EM:AddFilterForEvent( Xalvakka.name.."OnBlob", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")




  for _, subtitle in ipairs( ERG.GetXalvakkaStairsSubtitleList() ) do
    ERG.notifications.RegisterSubtitle("xalvakka", subtitle, function()
      Xalvakka.floor = Xalvakka.floor + 1
      Xalvakka.waitForDeadstar = true
    end)
  end
end

function Xalvakka.OnCombatStart()
  Xalvakka.floor = 1
  Xalvakka.OnFloorBegin()
  Xalvakka.lastSpawn = GetGameTimeMilliseconds()
  for id, data in pairs( mechanicData ) do
    if data.cooldown then
      local startValue = data.start or 0
      Xalvakka.anticipation.nextCast[id] = GetGameTimeMilliseconds() + startValue
    end
  end
end

function Xalvakka.GetFragList( returnAll )
  local fragList = {}
  for _, data in ipairs( Xalvakka.fragList ) do
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

function Xalvakka.OnUpdate()
  Xalvakka.OnAnticipationPanelUpdate()
end

function Xalvakka.OnProfileChange()
  Xalvakka.AdaptAnticipationPanelAccordingToProfile()
end

--

function Xalvakka.OnFloorBegin()
    Xalvakka.referenceTime = GetGameTimeMilliseconds()
    Xalvakka.waitForDeadstar = false

    if Xalvakka.floor == 1 then
      ERG.anticipation.SetActiveState( "xalvakka", mechanicId.flamePortal, true )
      ERG.anticipation.SetActiveState( "xalvakka", mechanicId.volatailShell, false )
    elseif Xalvakka.floor == 2 then
      ERG.anticipation.SetActiveState( "xalvakka", mechanicId.flamePortal, false )
      ERG.anticipation.SetActiveState( "xalvakka", mechanicId.volatailShell, true )
      Xalvakka.anticipation.nextCast[mechanicId.volatailShell] = GetGameTimeMilliseconds() + 20000
    elseif Xalvakka.floor == 3 then
      Xalvakka.anticipation.nextCast[mechanicId.volatailShell] = GetGameTimeMilliseconds() + 42000
    end

end
