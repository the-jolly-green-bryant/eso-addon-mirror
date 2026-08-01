Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.trash = ERG.trash or {}
local Trash = ERG.trash

local mechanicId = {
  ["earthquake"] = 149535, -- aoe placed by reaver 149535
  ["extrication"] = 149159, -- aoe explosion on three players from soulweaver
  ["meteorCall"] = 152414, -- meteorcall by torchcaster after bahsei
  ["hastedAssault"] = 149261,
}

function Trash.GetMechanicIds()
  return mechanicId
end


local mechanicData = {
  [mechanicId.earthquake] = { color = {0.53,0.27,0,1}, },
  [mechanicId.extrication] = { color = {0,1,1,1}, },
  [mechanicId.hastedAssault] = {icon = "/esoui/art/icons/achievement_u30_groupboss5.dds", color = {1,0,0,1}, alternativeIds = {149268} } --ACTION_RESULT_BEGIN
}

function Trash.GetMechanicData()
  return mechanicData
end


local notificationList = {
  [mechanicId.earthquake] = {
    ["OnTextAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
        [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
      },
    },
  },
  [mechanicId.extrication] = {
    ["OnBannerAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
        [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_EFFECT_GAINED,
        [REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE] = COMBAT_UNIT_TYPE_PLAYER,
      },
      duration = 4000,
    },
  },
  [mechanicId.hastedAssault] = {
    ["OnTextAlert"] = {
      event = EVENT_COMBAT_EVENT,
      staticFilter = {
        [REGISTER_FILTER_COMBAT_RESULT] = ACTION_RESULT_BEGIN,
      },
    },
  },
}

function Trash.GetNotificationList()
  return notificationList
end


local CCA_Settings = {
  astralShield = {icon = "/esoui/art/icons/u30_trial_soullink.dds" },
  standingInAoe = {id = 150137}, --TODO add a different id as well (157308) for directed volley
  meteorCall = {}
}

--function Trash.Get_CCA_Settings()
--  return CCA_Settings
--end


function Trash.OnMeteorCall()
  local meteorHp = {
    [1] = 369671,
    [2] = 679180, -- 752933,
  }

  local function Warning()
    local timeRemaining = ERG.GetRemainingMilliseconds( Trash.meteorExplodeTime )
    if timeRemaining == 0 then ERG.healthFrame.Hide() end
    if timeRemaining > 10000 then
      return zo_strformat("<<1>> <<2>>", "Landing", ERG.GetTimeRemaining(Trash.meteorExplodeTime-10000, true))
    else
      return zo_strformat("<<1>> <<2>>", "Explosion", ERG.GetTimeRemaining(Trash.meteorExplodeTime, true))
    end
  end

  local maxHp = meteorHp[ ERG.GetCustomDifficulty() ]
  if not maxHp then return end

  Trash.meteorExplodeTime = GetGameTimeMilliseconds() + 13500
  zo_callLater(function() Trash.meteorExplodeTime = nil end, 14000)
  ERG.healthFrame.Show( maxHp ,Warning)
end


function Trash.Initialize()
  Trash.name = ERG.name.."Trash"

  ERG.testVar = true

  ERG.EM:RegisterForEvent(Trash.name.."OnMeteorCall", EVENT_COMBAT_EVENT, Trash.OnMeteorCall)
  ERG.EM:AddFilterForEvent(Trash.name.."OnMeteorCall", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
  ERG.EM:AddFilterForEvent(Trash.name.."OnMeteorCall", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, mechanicId.meteorCall)
end

function Trash.OnMeteorCallSpawn(spawn, unitId)
  if spawn then
    ERG.units.damage[unitId] = 0
    ERG.healthFrame.SetTrackedUnit( unitId )
  else
    ERG.units.damage[unitId] = nil
    ERG.healthFrame.Hide()
  end
end


function Trash.GetIdentifyEnemyList()
  return {
    [153435] = Trash.OnMeteorCallSpawn,
  }
end
