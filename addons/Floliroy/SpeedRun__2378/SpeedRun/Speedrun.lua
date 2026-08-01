-----------------
---- Globals ----
-----------------
Speedrun = Speedrun or {}
local Speedrun = Speedrun
local EM = EVENT_MANAGER
local sV
local cV
Speedrun.name               = "Speedrun"
Speedrun.version            = "0.1.9.5"
Speedrun.activeProfile      = ""
Speedrun.raidID             = 0
Speedrun.zone               = 0
Speedrun.raidList           = {}
Speedrun.stepList           = {}
Speedrun.customTimerSteps   = {}
Speedrun.segments           = {}
Speedrun.segmentTimer       = {}
Speedrun.currentRaidTimer   = {}
Speedrun.displayVitality    = ""
Speedrun.lastBossName       = ""
Speedrun.currentBossName    = ""
Speedrun.isBossDead         = true
Speedrun.Step               = 1
Speedrun.arenaRound         = 1
Speedrun.timeStarted        = nil
Speedrun.totalScore         = 0
-- Speedrun.slain							= {}
Speedrun.inCombat           = false
Speedrun.fightBegin         = 0
Speedrun.isNormal           = false
Speedrun.isComplete         = false
Speedrun.trialState         = -1 -- not in trial: -1, in trial: 0 = not started, 1 = active, 2 = complete.
Speedrun.isUIDrawn          = false
Speedrun.isScoreSet         = false
Speedrun.inMenu             = false
Speedrun.currentTrialMenu   = nil
Speedrun.profileToImportTo  = ""
Speedrun.profileNames       = {}
Speedrun.foodUnlocked       = false
local crMindblast           = 104515
local crAmulet              = 106023
local confirmedST           = false
-------------------
---- Functions ----
-------------------
function Speedrun.GetSavedTimer(raidID, step)
  local cStep = Speedrun.GetCustomTimerStep(raidID, step)
  if cStep and cStep ~= "" then
    cStep = tonumber(cStep)
    return cStep * 1000
  end

  local tStep = Speedrun.GetSavedTimerStep(raidID, step)
  if tStep then return tStep end

  -- return 0
end

function Speedrun.FormatRaidTimer(timer, ms)
  ms = ms or true
  local raidDurationSec
  local r = 0
  local timerFormat = ""

  if ms then
    if timer == 0 then raidDurationSec = math.floor(timer / 1000)
    else
      if timer > 0 then
        if (timer % 1000) >= 500 then r = 1 end
      end
      raidDurationSec = math.floor(timer / 1000) + r
    end
  else
    if timer >= 0 then raidDurationSec = timer
    else raidDurationSec = 0 end
  end

  if raidDurationSec then
    local returnedString = ""

    if raidDurationSec < 0 then returnedString = "-" end

    if raidDurationSec < 3600 and raidDurationSec > -3600 then
      timerFormat = returnedString .. string.format("%02d:%02d",
      math.floor((math.abs(raidDurationSec) / 60) % 60),
      math.abs(raidDurationSec) % 60)
    else
      timerFormat = returnedString .. string.format("%02d:%02d:%02d",
      math.floor(math.abs(raidDurationSec) / 3600),
      math.floor((math.abs(raidDurationSec) / 60) % 60),
      math.abs(raidDurationSec) % 60)
    end
    return timerFormat
  end
end

function Speedrun.FormatTimerForChatUpdate(timer)
  -- local h = ""
  -- local seconds = timer / 1000
  -- if seconds >= 3600 then
  --   h = string.format("%02d", math.floor(seconds / 3600)) .. ":"
  -- end
  -- local m  = string.format("%02d", math.floor(seconds / 60) % 60)
  -- local s  = string.format("%02d", math.floor(seconds) % 60)
  -- local ms = string.format("%02d", math.floor(zo_round(timer / 10)) % 100)
  -- local chatString = h .. m .. ":" .. s .. "." .. ms

  local chatString = ZO_FormatTime(timer, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_MILLISECONDS)
  return chatString
end

function Speedrun.FormatRaidScore(score)
  score = tostring(score)
  local fScore = string.sub(score,string.len(score)-2,string.len(score))
  local dScore = string.gsub(score,fScore,"")
  local string = dScore .. "'" .. fScore
  return string
end

-- Trial Score = (Base Score + Vitality x 1000) x (1 + (Par time - Your time(sec)) /10000)
function Speedrun.GetScore(timer, vitality, raidID)
  --AA
  if     raidID == 638  then return (124300 + (1000 * vitality)) * (1 + (900 - timer) / 10000)
    --HRC
  elseif raidID == 636  then return (133100 + (1000 * vitality)) * (1 + (900 - timer) / 10000)
    --SO
  elseif raidID == 639  then return (142700 + (1000 * vitality)) * (1 + (1500 - timer) / 10000)
    --MoL
  elseif raidID == 725  then return (108150 + (1000 * vitality)) * (1 + (2700 - timer) / 10000)
    --HoF
  elseif raidID == 975  then return (160100 + (1000 * vitality)) * (1 + (2700 - timer) / 10000)
    --AS
  elseif raidID == 1000 then return (70000  + (1000 * vitality)) * (1 + (1200 - timer) / 10000)
    --CR
  elseif raidID == 1051 then
    if Speedrun.addsOnCR == false then return (85750 + (1000 * vitality)) * (1 + (1200 - timer) / 10000)
    else return (88000 + (1000 * vitality)) * (1 + (1200 - timer) / 10000) end
    --BRP
  elseif raidID == 1082 then return (75000  + (1000 * vitality)) * (1 + (2400 - timer) / 10000)
    --MA
  elseif raidID == 677  then return (426000 + (1000 * vitality)) * (1 + (5400 - timer) / 10000)
    --DSA
  elseif raidID == 635  then return (20000  + (1000 * vitality)) * (1 + (3600 - timer) / 10000)
    --SS
  elseif raidID == 1121 then
    if Speedrun.hmOnSS == 1 then return (87250 + (1000 * vitality)) * (1 + (1800 - timer) / 10000)
    elseif Speedrun.hmOnSS == 2 then return (127250 + (1000 * vitality)) * (1 + (1800 - timer) / 10000)
    elseif Speedrun.hmOnSS == 3 then return (167250 + (1000 * vitality)) * (1 + (1800 - timer) / 10000)
    elseif Speedrun.hmOnSS == 4 then return (207250 + (1000 * vitality)) * (1 + (1800 - timer) / 10000) end
    --KA
  elseif raidID == 1196 then return (205950 + (1000 * vitality)) * (1 + (1200 - timer) / 10000)
    --VH
  elseif raidID == 1227 then return (205450 + (1000 * vitality)) * (1 + (5400 - timer) / 10000)
    -- RG
  elseif raidID == 1263 then return (232200 + (1000 * vitality)) * (1 + (2700 - timer) / 10000)

  else return 0 end
end

function Speedrun.UpdateWaypointNew(raidDuration)
  local raid = Speedrun.raidList[Speedrun.raidID]
  local waypoint = Speedrun.Step

  if raid then

    if not Speedrun.Data.stepList[raid.id][waypoint] or raidDuration < 1 then return end

    Speedrun.currentRaidTimer[waypoint] = math.floor(raidDuration)
    sV.currentRaidTimer[waypoint] = Speedrun.currentRaidTimer[waypoint]
    Speedrun.UpdateWindowPanel(waypoint, Speedrun.raidID)

    local timerWaypoint = 0
    if Speedrun.currentRaidTimer[waypoint - 1] then
      timerWaypoint = Speedrun.currentRaidTimer[waypoint] - Speedrun.currentRaidTimer[waypoint - 1]
    else
      timerWaypoint = Speedrun.currentRaidTimer[waypoint]
    end

    if (raid.timerSteps[waypoint] == nil or raid.timerSteps[waypoint] <= 0 or raid.timerSteps[waypoint] > timerWaypoint) then
      raid.timerSteps[waypoint] = timerWaypoint
      Speedrun.SaveTimerStep(raid.id, waypoint, timerWaypoint)
    end

    if Speedrun.raidID == 1082 then -- BRP
      Speedrun:dbg(2, "Stage: <<1>>, Round: <<2>>, Step: <<3>>.", Speedrun.GetBRPStage(), Speedrun.arenaRound, Speedrun.GetBRPStep())
    end

    Speedrun.Step = Speedrun.Step + 1
    sV.Step = Speedrun.Step

    if (sV.printStepUpdate) then
      Speedrun:dbg(0, '[|ce6b800<<1>>|r] |c00ff00Step <<2>>|r at |cffffff<<3>>|r.', GetUnitZone('player'), waypoint, Speedrun.FormatTimerForChatUpdate(GetRaidDuration() / 1000))
    end
  end
end

Speedrun.ScoreUpdate = function(eventCode, scoreUpdateReason, scoreAmount, totalScore)
  Speedrun.totalScore = totalScore
  sV.totalScore       = Speedrun.totalScore
  local scoreTimer    = GetRaidDuration()
  local sT            = Speedrun.FormatRaidTimer(scoreTimer, true)

  for k, v in pairs(Speedrun.scores) do

    if Speedrun.scores[k] == scoreUpdateReason or Speedrun.scores[k].id == scoreUpdateReason then
      Speedrun.scores[k].times = Speedrun.scores[k].times + 1
      Speedrun.scores[k].total = Speedrun.scores[k].total + scoreAmount
      sV.scores[k].times       = Speedrun.scores[k].times
      sV.scores[k].total       = Speedrun.scores[k].total

      if scoreUpdateReason ~= 9 then
        Speedrun:dbg(3, '[|cffffff<<4>>|r] +|cffffff<<2>>|r (|cffffff<<1>>|r) - Total: |cffffff<<3>>|r - |cffffff<<5>>|r.', Speedrun.scores[k].name, scoreAmount, totalScore, sT, GetMapName())
      end
    end
  end

  if Speedrun.raidID == 1227 then
    Speedrun.UpdateAdds()

  elseif Speedrun.raidID == 636 and Speedrun.Step <= 4 then
    local b = Speedrun.scores[5].times
    if ((Speedrun.Step == 2) and (b == 1)) or ((Speedrun.Step == 4) and (b == 3)) then
      Speedrun.lastBossName 		= Speedrun.currentBossName
      sV.lastBossName 					= Speedrun.lastBossName
      Speedrun.currentBossName  = ""
      sV.currentBossName 				= Speedrun.currentBossName
      Speedrun.UpdateWaypointNew(GetRaidDuration())
      EM:RegisterForUpdate(Speedrun.name .. "HelRaCitadel", 1000, Speedrun.MainHRC)
    end
  end
  Speedrun.UpdateCurrentScore()
end

function Speedrun.UpdateAdds()
  if not GetZoneId(GetUnitZoneIndex("player")) == 1227 then return end

  for k, v in pairs(Speedrun.scores) do
    local score = Speedrun.scores[k]

    if score == 1 or score.id == RAID_POINT_REASON_KILL_NORMAL_MONSTER then
      SpeedRun_Adds_SA:SetText(score.name .. ":")
      SpeedRun_Adds_SA_Counter:SetText(score.times .. " / 68")

      if score.times == 68 then
        SpeedRun_Adds_SA_Counter:SetColor(0, 1, 0, 1)
      else
        SpeedRun_Adds_SA_Counter:SetColor(1, 1, 1, 1)
      end

    elseif score == 2 or score.id == RAID_POINT_REASON_KILL_BANNERMEN then
      SpeedRun_Adds_LA:SetText(score.name .. ":")
      SpeedRun_Adds_LA_Counter:SetText(score.times .. " / 33")

      if score.times == 33 then
        SpeedRun_Adds_LA_Counter:SetColor(0, 1, 0, 1)
      else
        SpeedRun_Adds_LA_Counter:SetColor(1, 1, 1, 1)
      end

    elseif score == 3 or score.id == RAID_POINT_REASON_KILL_CHAMPION then
      SpeedRun_Adds_EA:SetText(score.name .. ":")
      SpeedRun_Adds_EA_Counter:SetText(score.times .. " / 15")

      if score.times == 15 then
        SpeedRun_Adds_EA_Counter:SetColor(0, 1, 0, 1)
      else
        SpeedRun_Adds_EA_Counter:SetColor(1, 1, 1, 1)
      end
    end
  end
end
----------------
---- Arenas ----
----------------
function Speedrun.GetBRPStage()
  local x, y = GetMapPlayerPosition('player');
  if (x > 0.54 and x < 0.64 and y > 0.79 and y < 0.89) then return 1
  elseif (x > 0.3  and x < 0.4  and y > 0.69 and y < 0.8 ) then return 2
  elseif (x > 0.41 and x < 0.52 and y > 0.43 and y < 0.53) then return 3
  elseif (x > 0.63 and x < 0.73 and y > 0.22 and y < 0.32) then return 4
  elseif (x > 0.4  and x < 0.5  and y > 0.08 and y < 0.18) then return 5
  else return 0 end
end

function Speedrun.GetBRPStep()
  local step = ((Speedrun.GetBRPStage() * 5) - 5) + Speedrun.arenaRound
  return step
end

function Speedrun.Announcement(_, title, _)
  if title == 'Final Round' or title == 'Letzte Runde' or title == 'Dernière manche' or title == 'Последний раунд' or title == '最終ラウンド' then
    Speedrun.arenaRound = 5
    sV.arenaRound 			= Speedrun.arenaRound
  else
    local round = string.match(title, '^.+%s(%d)$')
    if round then
      Speedrun.arenaRound = tonumber(round)
      sV.arenaRound 			= Speedrun.arenaRound
    end
  end
end

function Speedrun.PortalSpawnBRP(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

  if result == ACTION_RESULT_EFFECT_GAINED then
    local t = GetGameTimeMilliseconds()
    if t - lastPortal > 2000 then brpWave = brpWave + 1 end
    lastPortal = t
  end
end

Speedrun.MainArena = function(eventCode, scoreUpdateReason, scoreAmount, totalScore)

  if (Speedrun.raidID == 677) then --MA
    if Speedrun.Step <= 8 and scoreUpdateReason == 17 then
      Speedrun.UpdateWaypointNew(GetRaidDuration())
    end

    if (scoreUpdateReason == RAID_POINT_REASON_SOLO_ARENA_COMPLETE) then
      Speedrun.isBossDead = true
      sV.isBossDead       = Speedrun.isBossDead
    end

  elseif Speedrun.raidID == 1082 then --BRP
    if (Speedrun.Step <= 24 and (scoreUpdateReason >= 13 and scoreUpdateReason <= 16) or scoreUpdateReason == RAID_POINT_REASON_MIN_VALUE) then
      Speedrun.UpdateWaypointNew(GetRaidDuration())
    end

    if (scoreUpdateReason == RAID_POINT_REASON_KILL_BOSS) then
      Speedrun.UpdateWaypointNew(GetRaidDuration())
      Speedrun.isBossDead = true
      sV.isBossDead       = Speedrun.isBossDead
    end

  elseif Speedrun.raidID == 635 then --DSA
    if (scoreUpdateReason == RAID_POINT_REASON_BONUS_ACTIVITY_MEDIUM) then
      Speedrun.UpdateWaypointNew(GetRaidDuration())
    end

    if (scoreUpdateReason == RAID_POINT_REASON_KILL_BOSS) then
      Speedrun.UpdateWaypointNew(GetRaidDuration())
      Speedrun.isBossDead = true
      sV.isBossDead       = Speedrun.isBossDead
    end
  end
end

local lastPrint = ""
local sideBoss  = ""
function Speedrun.MainVH()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then

      --zo_strformat("<<C:1>>", GetUnitName('boss1'))
      local boss = GetUnitName("boss" .. i)
      Speedrun.currentBossName = string.lower(boss)

      if lastPrint ~= Speedrun.currentBossName then
        lastPrint = Speedrun.currentBossName
        Speedrun:dbg(2, "<<1>> Detected!", boss)
      end

      -- local current, max, effmax = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)

      if Speedrun.Step <= 6 then

        if ((Speedrun.currentBossName == Speedrun.lastBossName) or not IsUnitInCombat("player")) then return end

        if (string.find("leptfire", Speedrun.currentBossName) or string.find("xobutar", Speedrun.currentBossName) or string.find("mynar", Speedrun.currentBossName)) then
          if Speedrun.isSideBoss == false then
            Speedrun.isSideBoss = true
            sideBoss            = boss
          end
        else
          Speedrun.isSideBoss = false
          sideBoss            = ""
        end

        if (Speedrun.isSideBoss == true and IsUnitInCombat("player")) then
          EM:UnregisterForUpdate(Speedrun.name .. "SideBoss")
          EM:RegisterForUpdate(Speedrun.name .. "SideBoss", 100, Speedrun.SideBoss)
          return
        end

        if IsUnitInCombat("player") then
          if Speedrun.lastBossName ~= Speedrun.currentBossName then
            EM:RegisterForEvent(Speedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE, Speedrun.arenaBoss)
          else
            return
          end
        end
      end
    end
  end
end

function Speedrun.SideBoss()
  local current, max, effmax = GetUnitPower("boss1", POWERTYPE_HEALTH)

  if current <= 0 then
    EM:UnregisterForUpdate(Speedrun.name .. "SideBoss")
    Speedrun:dbg(1, "|cdf4242<<1>>|r killed at |cffff00<<2>>|r", sideBoss, Speedrun.FormatTimerForChatUpdate(GetRaidDuration()))
    Speedrun.lastBossName = Speedrun.currentBossName
    sV.lastBossName       = Speedrun.lastBossName
  end
end

Speedrun.arenaBoss = function(eventCode, scoreUpdateReason, scoreAmount, totalScore)
  if scoreUpdateReason == 13 or scoreUpdateReason == 14 or scoreUpdateReason == 15 or scoreUpdateReason == 16 or scoreUpdateReason == RAID_POINT_REASON_MIN_VALUE then

    Speedrun.lastBossName     = Speedrun.currentBossName
    sV.lastBossName           = Speedrun.lastBossName
    Speedrun.currentBossName  = ""
    Speedrun.UpdateWaypointNew(GetRaidDuration())
    EM:UnregisterForEvent(Speedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE)

    zo_callLater(function()
      EM:UnregisterForUpdate(Speedrun.name .. "VHBoss")
      EM:RegisterForUpdate(Speedrun.name .. "VHBoss", 1000, Speedrun.MainVH)
    end, 2000)
  end
end
----------------
---- Trials ----
----------------
-- function Speedrun.MiniTrial()

local zmaja   = {}
local isZmaja = false

function Speedrun.OnCombatEnd()
  if IsUnitInCombat("player") then return end
  zo_callLater(function()
    if (not IsUnitInCombat("player") and not Speedrun.isComplete) then
      Speedrun.inCombat         = false
      Speedrun.currentRaidTimer = {}
      sV.currentRaidTimer       = Speedrun.currentRaidTimer
      Speedrun.isBossDead       = true
      sV.isBossDead             = Speedrun.isBossDead
      Speedrun.Step             = 1
      sV.Step                   = Speedrun.Step
      if Speedrun.raidID == 1051 then
        zmaja   = {}
        isZmaja = false
        EM:UnregisterForUpdate(Speedrun.name .. "CombatEnded")
        EM:UnregisterForUpdate(Speedrun.name .. "MiniTrial")
        EM:UnregisterForEvent( Speedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
      end
    end
  end, 3000)
end

function Speedrun.CombatCR()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      local current, max, effectiveMax = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
      if (max > 64000000 and IsUnitAttackable("boss" .. i)) then
        if IsUnitInCombat("player") then
          -- zmaja name: ["Z'Maja"], ["З'Маджа"], ["ズマジャ"]
          -- zo_strformat("<<C:1>>", GetUnitName('boss1'))
          Speedrun.currentBossName = string.lower(GetUnitName("boss" .. i))
          sV.currentBossName 			 = Speedrun.currentBossName
          local z = {
            index     = i,
            name      = Speedrun.currentBossName,
            hpMax	    = max,
            hpCurrent = current,
          }
          zmaja   = z
          isZmaja = true
          if Speedrun.Step == 1 then
            Speedrun.UpdateWaypointNew(GetRaidDuration())
            EM:UnregisterForUpdate(Speedrun.name .. "MiniTrial")
            EM:RegisterForUpdate(	Speedrun.name .. "MiniTrial", 333, Speedrun.MainCloudrest)
          end
          Speedrun.inCombat = true

          zo_callLater(function()
            EM:UnregisterForUpdate(Speedrun.name .. "CombatEnded")
            EM:RegisterForUpdate(Speedrun.name .. "CombatEnded", 4000, Speedrun.OnCombatEnd)
          end, 1000)
        end

      else
        isZmaja = false
      end
    end
  end
end

function Speedrun.ZmajaShade()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      -- zo_strformat("<<C:1>>", GetUnitName('boss1'))
      local boss = string.lower(GetUnitName("boss" .. i))
      if (boss ~= zmaja.name and Speedrun.Step == 5) then
        -- if (boss ~= Speedrun.currentBossName and Speedrun.Step == 5) then
        Speedrun.currentBossName  = boss
        sV.currentBossName        = Speedrun.currentBossName
        Speedrun.UpdateWaypointNew(GetRaidDuration())
        EM:UnregisterForEvent(Speedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
      end
    end
  end
end

-- IsUnitActivelyEngaged(string unitTag)
-- Returns: boolean isActivelyEngaged

-- IsUnitAttackable(string unitTag)
-- Returns: boolean attackable

function Speedrun.MainCloudrest()
  if isZmaja then
    local current, max, effectiveMax = GetUnitPower("boss" .. zmaja.index, POWERTYPE_HEALTH)
    local percentageHP = current / max

    -- check for highest possible step in case 1 or 2 steps were passed while player was in portal
    if (percentageHP <= 0.06) then
      -- if Speedrun.Step < 5 then
      Speedrun.Step = 4
      Speedrun.UpdateWaypointNew(GetRaidDuration())
      EM:UnregisterForEvent(Speedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
      EM:RegisterForEvent(Speedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED, Speedrun.ZmajaShade)
      EM:UnregisterForUpdate(Speedrun.name .. "MiniTrial")
      return
      -- end
    elseif (percentageHP <= 0.25 and percentageHP >= 0.06) then
      if Speedrun.Step < 4 then
        Speedrun.Step = 3
        Speedrun.UpdateWaypointNew(GetRaidDuration())
        -- EM:UnregisterForEvent(Speedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
        -- EM:RegisterForEvent(Speedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED, Speedrun.ZmajaShade)
        return
      end

    elseif (percentageHP <= 0.5 and percentageHP > 0.25) then
      if Speedrun.Step < 3 then
        Speedrun.Step = 2
        Speedrun.UpdateWaypointNew(GetRaidDuration())
        return
      end

    elseif (percentageHP <= 0.75 and percentageHP > 0.5) then
      if Speedrun.Step < 2 then
        Speedrun.Step = 1
        Speedrun.UpdateWaypointNew(GetRaidDuration())
        return
      end
    end

  else
    EM:UnregisterForUpdate(Speedrun.name .. "MiniTrial")
  end
end

function Speedrun.CombatAS()
  if IsUnitInCombat("player") then
    for i = 1, MAX_BOSSES do
      if DoesUnitExist("boss" .. i) then
        local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
        if maxTargetHP > 99000000 then
          -- zo_strformat("<<C:1>>", GetUnitName('boss1'))
          Speedrun.currentBossName = string.lower(GetUnitName("boss" .. i))
          sV.currentBossName 			 = Speedrun.currentBossName
          Speedrun.inCombat = true

          zo_callLater(function()
            EM:UnregisterForUpdate(Speedrun.name .. "CombatEnded")
            EM:RegisterForUpdate(Speedrun.name .. "CombatEnded", 4000, Speedrun.OnCombatEnd)
          end, 1000)
        end
      end
    end
  end
end

function Speedrun.MainAsylum()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
      local percentageHP = currentTargetHP / maxTargetHP
      --start fight with boss
      if Speedrun.inCombat and Speedrun.isBossDead == true then
        --Olms got more than 99Million HP
        if (Speedrun.Step == 1    and maxTargetHP   >= 99000000) then Speedrun.UpdateWaypointNew(GetRaidDuration()) end
        if ( percentageHP <= 0.9  and Speedrun.Step == 2       ) then Speedrun.UpdateWaypointNew(GetRaidDuration()) end
        if ( percentageHP <= 0.75 and Speedrun.Step == 3       ) then Speedrun.UpdateWaypointNew(GetRaidDuration()) end
        if ( percentageHP <= 0.5  and Speedrun.Step == 4       ) then Speedrun.UpdateWaypointNew(GetRaidDuration()) end
        if ( percentageHP <= 0.25 and Speedrun.Step == 5       ) then Speedrun.UpdateWaypointNew(GetRaidDuration()) end
      -- else
      --   if (currentTargetHP > 0 and Speedrun.Step <= 6) then
      --     Speedrun.currentRaidTimer = {}
      --     sV.currentRaidTimer = Speedrun.currentRaidTimer
      --     Speedrun.Step = 1
      --     sV.Step = Speedrun.Step
      --   elseif currentTargetHP <= 0 then
      --     -- not in HM
      --     Speedrun.isBossDead = false
      --     sV.isBossDead = Speedrun.isBossDead
        -- end
      end
    end
  end
end

function Speedrun.MainHRC()
  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      -- zo_strformat("<<C:1>>", GetUnitName('boss1'))
      Speedrun.currentBossName   = string.lower(GetUnitName("boss" .. i))
      if (Speedrun.lastBossName == Speedrun.currentBossName) then return end
      if IsUnitInCombat("player") then
        Speedrun.UpdateWaypointNew(GetRaidDuration())
        EM:UnregisterForUpdate(Speedrun.name .. "HelRaCitadel")
      end
    else return end
  end
end

function Speedrun.LastArchive()
  if IsUnitInCombat("player") and Speedrun.Step == 6 then
    for i = 1, MAX_BOSSES do
      if DoesUnitExist("boss" .. i) then
        local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
        if currentTargetHP > 0 then
          Speedrun.UpdateWaypointNew(GetRaidDuration())
          --Unregister for update then register again on update for UI panel
          EM:UnregisterForUpdate(Speedrun.name .. "LastAA")
        end
      end
    end
  end
end

function Speedrun.BossFightBegin()
  for i = 1, MAX_BOSSES do
    local current, max, effmax = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)
    if IsUnitInCombat("player") and (current < max) then
      EM:UnregisterForUpdate(Speedrun.name .. "BossFight")
      Speedrun.UpdateWaypointNew(GetRaidDuration())
      -- Speedrun:dbg(2, "|cffffff<<1>>|r Started at: |cffffff<<2>>|r!", GetUnitName("boss" .. i), Speedrun.FormatTimerForChatUpdate(GetRaidDuration()))
    end
  end
end

function Speedrun.MainBoss()
  if Speedrun.Step == 6 and Speedrun.raidID == 638 then
    --to trigger the mage
    EM:RegisterForUpdate(Speedrun.name .. "LastAA", 333, Speedrun.LastArchive)
  end

  for i = 1, MAX_BOSSES do
    if DoesUnitExist("boss" .. i) then
      -- zo_strformat("<<C:1>>", GetUnitName('boss1'))

      local name = GetUnitName("boss" .. i)

      if string.lower(name) ~= Speedrun.currentBossName then
        if Speedrun.fightBegin == 0 and IsUnitInCombat("boss" .. i) then

          Speedrun.fightBegin = GetRaidDuration()
          Speedrun:dbg(2, "|cffffff<<1>>|r Started at: |cffffff<<2>>|r!", GetUnitName("boss" .. i), Speedrun.FormatTimerForChatUpdate(Speedrun.fightBegin / 1000))
        else
          Speedrun.fightBegin = 0
        end
      end

      Speedrun.currentBossName  = string.lower(name)
      sV.currentBossName 				= Speedrun.currentBossName


      if Speedrun.raidID == 1263 then
        if (string.find(Speedrun.currentBossName, "snakes") or string.find(Speedrun.currentBossName, "titan")) then return end
      end

      if Speedrun.currentBossName == Speedrun.lastBossName then return end

      local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss" .. i, POWERTYPE_HEALTH)

      if Speedrun.isBossDead == true and currentTargetHP > 0 then
        -- boss encounter begins
        Speedrun.isBossDead = false
        sV.isBossDead 			= Speedrun.isBossDead

        -- for Nahviintaas (to set time when in combat with the adds since they are relevant to the boss fight)
        if Speedrun.raidID == 1121 and Speedrun.Step == 5 then
          if IsUnitInCombat("player") then Speedrun.UpdateWaypointNew(GetRaidDuration()) return end
        end

        EM:UnregisterForUpdate(Speedrun.name .. "BossFightBegin")
        EM:RegisterForUpdate(Speedrun.name .. "BossFight", 50, Speedrun.BossFightBegin)
      end
    end
  end
end

local function BossMainZoneCheck(zone)
  local mbZones = { [638] = true, [639] = true, [725] = true, [975] = true, [1121] = true, [1196] = true, [1263] = true }
  if mbZones[zone] then return true end
  return false
end

Speedrun.BossDead = function(eventCode, scoreUpdateReason, scoreAmount, totalScore)

  local timer

  -- if scoreUpdateReason == RAID_POINT_REASON_KILL_MINIBOSS then
  --   timer = (GetRaidDuration() - Speedrun.fightBegin) / 1000
  --   Speedrun:dbg(2, "|cffffff<<1>>|r fight time: |cffffff<<2>>|r!", Speedrun.currentBossName, Speedrun.FormatTimerForChatUpdate(timer))
  --   return
  -- end

  if scoreUpdateReason == RAID_POINT_REASON_KILL_BOSS then

    timer = (GetRaidDuration() - Speedrun.fightBegin) / 1000

    -- Speedrun:dbg(2, "|cffffff<<1>>|r fight time: |cffffff<<2>>|r!", Speedrun.currentBossName, Speedrun.FormatTimerForChatUpdate(timer))

    Speedrun.lastBossName     = Speedrun.currentBossName
    sV.lastBossName           = Speedrun.lastBossName
    Speedrun.currentBossName  = ""
    sV.currentBossName        = Speedrun.currentBossName
    Speedrun.isBossDead       = true
    sV.isBossDead             = Speedrun.isBossDead
    Speedrun.UpdateWaypointNew(GetRaidDuration())

    -- if BossMainZoneCheck(GetZoneId(GetUnitZoneIndex("player"))) then
    -- 		EM:RegisterForEvent(Speedrun.name .. "Combat", EVENT_PLAYER_COMBAT_STATE, Speedrun.MainBoss)
    -- 		EM:RegisterForEvent(Speedrun.name .. "BossChange", EVENT_BOSSES_CHANGED, Speedrun.MainBoss)
    -- end
  end
end

function Speedrun.OnTrialStarted()
  Speedrun.scores 			= Speedrun.GetDefaultScores()
  sV.scores 						= Speedrun.scores
  Speedrun.RegisterTrialsEvents()
  Speedrun.UpdateCurrentVitality()
  Speedrun.trialState 	= 1
  Speedrun.timeStarted 	= GetGameTimeSeconds()
  sV.timeStarted 				= Speedrun.timeStarted
  Speedrun:dbg(1, "Trial: |ce6b800<<1>>|r Started!", GetUnitZone('player'))
end

Speedrun.OnTrialComplete = function(eventCode, trialName, score, totalTime)
  -- for mini-trials and HRC
  if Speedrun.raidID == 636 or Speedrun.raidID == 1000 or Speedrun.raidID == 1082 or Speedrun.raidID == 677 or Speedrun.raidID == 1227 then
    Speedrun.UpdateWaypointNew(totalTime)
  end
  -- for CR
  if Speedrun.raidID == 1051 then
    if Speedrun.Step ~= 6 then
      Speedrun.Step = 6
      sV.Step = Speedrun.Step
    end
    Speedrun.UpdateWaypointNew(totalTime)
  end
  -- save data before resetting in case we need it
  sV.finalScore = score
  sV.totalTime  = totalTime

  if (GetDisplayName() == "@nogetrandom") then Speedrun.UpdateScoreFactors(Speedrun.activeProfile, Speedrun.raidID) end
  Speedrun.SetLastTrial()

  local scoreString = Speedrun.FormatRaidScore(sV.finalScore)
  SpeedRun_Score_Label:SetText(scoreString)
  SpeedRun_TotalTimer_Title:SetText(Speedrun.FormatRaidTimer(sV.totalTime, true))
  Speedrun.trialState = 2
  Speedrun.isComplete = true

  Speedrun.UnregisterTrialsEvents()
  if (sV.printStepUpdate) then
    Speedrun:dbg(1, "|ce6b800<<1>>|r |c00ff00Complete|r!\n[Time: |cffffff<<2>>|r]  [Score: |cffffff<<3>>|r] <<4>>", GetUnitZone('player'), Speedrun.FormatTimerForChatUpdate(totalTime / 1000), scoreString, Speedrun.FormatVitality(true, GetRaidReviveCountersRemaining(), GetCurrentRaidStartingReviveCounters()))
  end
end

function Speedrun.OnTrialFailed(eventCode, trialName, score)
    -- Speedrun.Reset()
    -- Speedrun.ResetUI()
    Speedrun.UnregisterTrialsEvents()
		Speedrun:dbg(1, '|ce6b800<<1>>|r |cff0000Failed|r.', trialName)
end
-----------------------
---- Base & Events ----
-----------------------
function Speedrun.Reset()
  Speedrun.isComplete 			= false
  sV.isComplete							= Speedrun.isComplete
  Speedrun.scores 					= {}
  sV.scores 								= {}
  Speedrun.scores 					= Speedrun.GetDefaultScores()
  sV.scores 								= Speedrun.scores
  Speedrun.totalScore				= 0
  sV.totalScore							= Speedrun.totalScore
  Speedrun.displayVitality 	= ""
  Speedrun.currentRaidTimer = {}
  sV.currentRaidTimer 			= Speedrun.currentRaidTimer
  Speedrun.Step 						= 1
  sV.Step 									= Speedrun.Step
  Speedrun.arenaRound				= 0
  sV.arenaRound							= Speedrun.arenaRound
  Speedrun.isBossDead 			= true
  sV.isBossDead 						= Speedrun.isBossDead
  Speedrun.lastBossName 		= ""
  sV.lastBossName 					= Speedrun.lastBossName
  Speedrun.currentBossName 	= ""
  sV.currentBossName 				= Speedrun.currentBossName
  Speedrun.isUIDrawn 				= false
  Speedrun.fightBegin       = 0
  Speedrun:dbg(2, "Resetting Variables.")
end

function Speedrun.UnregisterTrialsEvents()
  EM:UnregisterForEvent( Speedrun.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE)
  EM:UnregisterForEvent( Speedrun.name .. "Combat", EVENT_PLAYER_COMBAT_STATE)
  EM:UnregisterForEvent( Speedrun.name .. "BossChange", EVENT_BOSSES_CHANGED)
  EM:UnregisterForEvent( Speedrun.name .. "BossChangeCR", EVENT_BOSSES_CHANGED)
  EM:UnregisterForEvent( Speedrun.name .. "BossDead", EVENT_RAID_TRIAL_SCORE_UPDATE)
  EM:UnregisterForEvent( Speedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE)
  EM:UnregisterForEvent( Speedrun.name .. "Complete", EVENT_RAID_TRIAL_COMPLETE)
  EM:UnregisterForEvent( Speedrun.name .. "VitalityLost", EVENT_RAID_REVIVE_COUNTER_UPDATE)
  EM:UnregisterForEvent( Speedrun.name .. "Announcement", EVENT_DISPLAY_ANNOUNCEMENT)
  EM:UnregisterForUpdate(Speedrun.name .. "Update")
  EM:UnregisterForUpdate(Speedrun.name .. "MiniTrial")
  EM:UnregisterForUpdate(Speedrun.name .. "LastAA")
  EM:UnregisterForUpdate(Speedrun.name .. "VHBoss")
  EM:UnregisterForUpdate(Speedrun.name .. "VHSideBoss")
  EM:UnregisterForUpdate(Speedrun.name .. "HelRaCitadel")
  EM:UnregisterForUpdate(Speedrun.name .. "BossFight")
end

function Speedrun.RegisterTrialsEvents()
  --AS
  if Speedrun.raidID == 1000 then
    EM:RegisterForEvent( 	Speedrun.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, Speedrun.CombatAS)
    EM:RegisterForUpdate( Speedrun.name .. "MiniTrial", 333, Speedrun.MainAsylum)

  --CR
  elseif Speedrun.raidID == 1051 then
    EM:RegisterForEvent(  Speedrun.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, Speedrun.CombatCR)
    EM:RegisterForUpdate(	Speedrun.name .. "MiniTrial", 333, Speedrun.MainCloudrest)
    -- EM:RegisterForEvent(	Speedrun.name .. "Zmaja_Shade", EVENT_COMBAT_EVENT, Speedrun.CloudrestExecute)
    -- EM:AddFilterForEvent(	Speedrun.name .. "Zmaja_Shade", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 106023)

  --BRP
  elseif Speedrun.raidID == 1082 then
    EM:RegisterForEvent(  Speedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE, Speedrun.MainArena)
    EM:RegisterForEvent(  Speedrun.name .. "Announcement", EVENT_DISPLAY_ANNOUNCEMENT, Speedrun.Announcement)

  -- MA, DSA
  elseif Speedrun.raidID == 677 or Speedrun.raidID == 635 then
    EM:RegisterForEvent( 	Speedrun.name .. "ArenaBoss", EVENT_RAID_TRIAL_SCORE_UPDATE, Speedrun.MainArena)

  --VH
  elseif GetZoneId(GetUnitZoneIndex("player")) == 1227 then
    EM:RegisterForUpdate(	Speedrun.name .. "VHBoss", 1000, Speedrun.MainVH)

  -- HRC
  elseif Speedrun.raidID == 636 then
    EM:RegisterForUpdate(	Speedrun.name .. "HelRaCitadel", 1000, Speedrun.MainHRC)

  -- other raids
  else
    EM:RegisterForEvent( Speedrun.name .. "Combat", EVENT_PLAYER_COMBAT_STATE, Speedrun.MainBoss)
    EM:RegisterForEvent( Speedrun.name .. "BossChange", EVENT_BOSSES_CHANGED, Speedrun.MainBoss)
    EM:RegisterForEvent( Speedrun.name .. "BossDead", EVENT_RAID_TRIAL_SCORE_UPDATE, Speedrun.BossDead)
  end

  EM:RegisterForUpdate(	Speedrun.name .. "Update", 900, Speedrun.UpdateWindowPanel)
  EM:RegisterForEvent( 	Speedrun.name .. "VitalityLost", EVENT_RAID_REVIVE_COUNTER_UPDATE, Speedrun.UpdateCurrentVitality)
  EM:RegisterForEvent( 	Speedrun.name .. "ScoreUpdate", EVENT_RAID_TRIAL_SCORE_UPDATE, Speedrun.ScoreUpdate)
  EM:RegisterForEvent( 	Speedrun.name .. "Started", EVENT_RAID_TRIAL_STARTED, Speedrun.OnTrialStarted)
  EM:RegisterForEvent( 	Speedrun.name .. "Complete", EVENT_RAID_TRIAL_COMPLETE, Speedrun.OnTrialComplete)
  EM:RegisterForEvent( 	Speedrun.name .. "Failed", EVENT_RAID_TRIAL_FAILED, Speedrun.OnTrialFailed)
end

function Speedrun.OnPlayerActivated( eventCode, initial )
  Speedrun.IsActivated(initial)

  if cV.isTracking == false then return end

  if Speedrun.IsInTrialZone() then
    local same = Speedrun.CheckTrial()

    if not Speedrun.isUIDrawn then
      Speedrun.CreateRaidSegment(Speedrun.raidID, same)
      SpeedRun_TotalTimer_Title:SetText(Speedrun.FormatRaidTimer(GetRaidDuration(), true))
    end

    Speedrun.UpdateCurrentScore()
    Speedrun.UpdateCurrentVitality()
    Speedrun.RegisterTrialsEvents()
    -- Speedrun.SetUIHidden(not sV.showUI)
  else
    -- Player is not in a trial. Disable tracking.
    Speedrun.trialState = -1
    sV.trialState       = Speedrun.trialState
    Speedrun.scores     = Speedrun.GetDefaultScores()
    sV.scores           = Speedrun.scores
    -- Speedrun.SetUIHidden(true)
    Speedrun.UnregisterTrialsEvents()
  end
  Speedrun.UpdateVisibility()
  Speedrun.ToggleFoodReminder()
end

-- IsPlayerInRaidStagingArea()
-- IsPlayerInReviveCounterRaid()
-- HasRaidEnded()

-- GetUnitCaption(string unitTag)

function Speedrun.IsInTrialZone()
  Speedrun.zone = GetZoneId(GetUnitZoneIndex("player"))
  for k, v in pairs(Speedrun.Data.raidList) do
    if Speedrun.Data.raidList[k].id == Speedrun.zone then

      -- if not IsUnitUsingVeteranDifficulty("player") then
      -- if ZO_GetEffectiveDungeonDifficulty() < 2 then
      if GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_VETERAN then
        if Speedrun.isNormal == false then
          Speedrun.isNormal = true
          Speedrun:dbg(2, "Difficulty: Normal. Hiding UI")
        end
        return false
      end
      Speedrun.isNormal = false
      return true
    end
  end
  return false
end

function Speedrun.CheckTrial()
  local shouldReset = false
  local isSame      = false
  local state       = -1

  local function CompletedTrialCheck()
    -- HasRaidEnded()
    if GetRaidDuration() > 0 and (not IsRaidInProgress()) then
      state = 2
      return true
    end
    return false
  end

  local function NewTrialCheck()
    -- using only GetRaidDuration <= 0 can mess up when trial is started.
    -- New instance. Reset variables from last trial
    if GetRaidDuration() <= 0 and (not IsRaidInProgress()) then
      state = 0
      return true
    end
    -- We can only get to here if trial is currently in progress.
    state = 1
    return false
  end

  -- Use active raid timer to evaluate if player is returning to the same active trial instance.
  local function IsActiveTrialOldTrial()
    if Speedrun.zone ~= Speedrun.raidID then return false end
    if (state ~= 1) then return false end

    if Speedrun.Step == 1 then
      Speedrun.isBossDead   = true
      sV.isBossDead         = Speedrun.isBossDead
      Speedrun.lastBossName = ""
      sV.lastBossName       = Speedrun.lastBossName
    end

    -- Check if trial was started at the same time as players currently active trial.
    -- Not sure yet if we need a +/- 10 sec buffer for this. probably not...
    local time = GetGameTimeSeconds() - Speedrun.timeStarted
    local duration = GetRaidDuration() / 1000
    if ((time <= (duration + 10)) and (time >= (duration - 10))) then return true end
    return false
  end

  -- In trial but it's complete.
  -- Setup UI in case it was reloaded, or leave as is until next reset.
  if CompletedTrialCheck() then
    if not Speedrun.isUIDrawn then Speedrun.CreateRaidSegment(Speedrun.zone) end
    SpeedRun_Score_Label:SetText(Speedrun.FormatRaidScore(sV.finalScore))
    SpeedRun_TotalTimer_Title:SetText(Speedrun.FormatRaidTimer(sV.totalTime, true))
    Speedrun.isComplete = true
    Speedrun.trialState = 2
    Speedrun:dbg(3, "Trial is Complete. Returning.")
    return
  end

  -- Trial Variables are no longer reset when leaving an unfinished trial.
  -- Check if player is returning to their active unfinished trial else reset.
  if NewTrialCheck() then
    Speedrun:dbg(3, "New Trial.")
    shouldReset = true
  else
    if IsActiveTrialOldTrial() then
      Speedrun:dbg(3, "Same Trial.")
      isSame = true
    else
      Speedrun:dbg(3, "Trial active (not same).")
      shouldReset = true
    end
  end

  if shouldReset == true then
    Speedrun.Reset()
    Speedrun.ResetUI()

    -- Set current game time as reference in case player will port out and re-enter.
    if IsRaidInProgress() then
      Speedrun.timeStarted  = GetGameTimeSeconds() - (GetRaidDuration() / 1000)
      sV.timeStarted        = Speedrun.timeStarted

      -- GetTimeStamp()
      -- Returns: id64 timestamp
      -- GetTimeString()
      -- Returns: string currentTimeString

    end
  end
  Speedrun.raidID     = Speedrun.zone
  sV.raidID           = Speedrun.raidID
  Speedrun.trialState = state
  sV.trialState       = Speedrun.trialState
  return isSame
end

function Speedrun.ToggleTracking()
  Speedrun.Tracking(not cV.isTracking)
end

function Speedrun.Tracking(track)
  if track ~= true then
    -- take no action if not already registered
    if cV.isTracking == false then return end
    -- shut down everything trial related
    EM:UnregisterForEvent(Speedrun.name .. "Started", EVENT_RAID_TRIAL_STARTED)
    EM:UnregisterForEvent(Speedrun.name .. "Complete", EVENT_RAID_TRIAL_COMPLETE)
    EM:UnregisterForEvent(Speedrun.name .. "Failed", EVENT_RAID_TRIAL_FAILED)
    Speedrun.UnregisterTrialsEvents()
    Speedrun.SetUIHidden(true)
    -- Speedrun.Reset()
    Speedrun:dbg(0, "Score and Time tracking set to: |cffffffOFF|r")
  else
    -- only if tracking was previously off
    if cV.isTracking ~= track then
      Speedrun.Reset()
      Speedrun.ResetUI()
      Speedrun.ResetAnchors()
      Speedrun.OnPlayerActivated()
      Speedrun:dbg(0, "Score and Time tracking set to: |cffffffON|r")
    end
    -- global trial events
    -- EM:RegisterForEvent(Speedrun.name .. "Started", EVENT_RAID_TRIAL_STARTED, Speedrun.OnTrialStarted)
    -- EM:RegisterForEvent(Speedrun.name .. "Complete", EVENT_RAID_TRIAL_COMPLETE, Speedrun.OnTrialComplete)
    -- EM:RegisterForEvent(Speedrun.name .. "Failed", EVENT_RAID_TRIAL_FAILED, Speedrun.OnTrialFailed)
  end
  cV.isTracking = track
  Speedrun.UpdateUIConfiguration()
end

function Speedrun:Initialize()

  confirmedST = Speedrun.StressTestedCheck()

  Speedrun.savedSettings 	= ZO_SavedVars:NewCharacterIdSettings("SpeedrunVariables", 2, nil, Speedrun.Default_Character)
  -- Keep tables and recorded data available accountwide
  Speedrun.savedVariables = ZO_SavedVars:NewAccountWide("SpeedrunVariables", 2, nil, Speedrun.Default_Account)
  sV 											= Speedrun.savedVariables
  cV 											= Speedrun.savedSettings
  Speedrun.stepList 			= Speedrun.Data.stepList

  Speedrun.LoadVariables()
  -- keybinds
  ZO_CreateStringId("SI_BINDING_NAME_SR_TOGGLE_HIDEGROUP", "Toggle Hide Group")
  ZO_CreateStringId("SI_BINDING_NAME_SR_TOGGLE_UI", "Toggle UI")
  ZO_CreateStringId("SI_BINDING_NAME_SR_CANCEL_CAST", "Cancel Cast")
  -- UI
  Speedrun.InitiateUI()
  -- Configure Data
  Speedrun.LoadUtils()
  -- Setup Menu
  Speedrun.CreateSettingsWindow()
  -- Check settings for tracking
  Speedrun.Tracking(cV.isTracking)

  -- if writCreator then cV.writHidePets = WritCreater:GetSettings().petBegone end

  EM:RegisterForEvent(Speedrun.name .. "Activated", EVENT_PLAYER_ACTIVATED, Speedrun.OnPlayerActivated)
  EM:UnregisterForEvent(Speedrun.name .. "Loaded", EVENT_ADD_ON_LOADED)
end

function Speedrun.OnAddOnLoaded(event, addonName)
  if addonName ~= Speedrun.name then return end
  -- Parse defaults
  Speedrun:GenerateDefaults()
  Speedrun:Initialize()
end

EM:RegisterForEvent(Speedrun.name .. "Loaded", EVENT_ADD_ON_LOADED, Speedrun.OnAddOnLoaded)

--[[	Possible filter for "PlayerActivated" ?

-- In case addon is loaded while inside an active or completed trial
if Speedrun.IsInTrialZone() and Speedrun.raidID == zoneID then
		Speedrun.LoadTrial()
end

function Speedrun.LoadTrial()
		local zoneID = GetZoneId(GetUnitZoneIndex("player"))
		--for MA and VH to save timers for each character individualy.
		if zoneID == 677 or zoneID == 1227 then
				zoneID = zoneID .. GetUnitName("player")
		end

		Speedrun.CreateRaidSegment(zoneID)

		if not IsRaidInProgress() then
				if GetRaidDuration() <= 0 then
						SpeedRun_Score_Label:SetText(Speedrun.BestPossible(Speedrun.raidID))
				elseif Speedrun.isComplete == true then
						SpeedRun_Score_Label:SetText(sV.finalScore)
						SpeedRun_TotalTimer_Title:SetText(Speedrun.FormatRaidTimer(sV.totalTime, true))
				end
		end
end

]]
