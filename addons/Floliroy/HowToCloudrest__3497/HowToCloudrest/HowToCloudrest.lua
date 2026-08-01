-----------------
---- Globals ----
-----------------
HowToCloudrest = HowToCloudrest or {}
local HowToCloudrest = HowToCloudrest

HowToCloudrest.name = "HowToCloudrest"
HowToCloudrest.version = "1.2.2"

-- local WROTHGAR_MAP_INDEX  = 27
-- local WROTHGAR_MAP_STEP_SIZE = 1.428571431461e-005

local sV
local EM = EVENT_MANAGER

local function HTC_Debug(string)
  if sV.debug then
    d("[HTC_Debug] ".. string)
  end
end
----------------------------------------------------------
--                   Variables Default                  --
----------------------------------------------------------
HowToCloudrest.Default = {
  OffsetX = {
    -- General
    HA = 885,
    Rooted = 875,
    MiniFrame = 1285,
    Announcement_MiniBash = 785,

    -- Siroria
    Flare = 960,

    -- Relequen
    ReleHA = 890,
    Overload = 805,

    -- Galenwe
    Hoarfrost = 805,
    ChillingComet = 810,

    -- Portal
    Portal = 1290,
    Portal_Announcement = 815,

    -- Z'Maja
    ZmajaJump = 830,
    CrushingDarkness_Kite = 885,
    CrushingDarkness_Next = 1290,
    ShadowSplash = 810,
    BanefulMark = 830,
    MaliciousSphere_Tracking = 970,
    MaliciousSphere_Announcement = 815,
    MaliciousSphere_Timer = 1290,
    Creeper_Announcement = 815,
  },
  OffsetY = {
    -- General
    HA = 575,
    Rooted = 610,
    MiniFrame = 325,
    Announcement_MiniBash = 670,

    -- Siroria
    Flare = 400,


    -- Relequen
    ReleHA = 575,
    Overload = 300,

    -- Galenwe
    Hoarfrost = 355,
    ChillingComet = 640,

    -- Portal
    Portal = 460,
    Portal_Announcement = 440,

    -- Z'Maja
    ZmajaJump = 145,
    CrushingDarkness_Kite = 400,
    CrushingDarkness_Next = 495,
    ShadowSplash = 640,
    BanefulMark = 145,
    MaliciousSphere_Tracking = 545,
    MaliciousSphere_Announcement = 440,
    MaliciousSphere_Timer = 525,
    Creeper_Announcement = 440,
  },
  Enable = {
    -- General
    HA = false,
    RazorThorns = true,
    Announcement_MiniBash = true,

    -- Mini Frame
    MiniFrame = true,
    MiniJump = true,
    MiniBash = true,
    MiniSkill = true,

    -- Siroria
    DarkTalons = true,
    Flare = true,

    -- Relequen
    ReleHA = true,
    Overload = true,
    Overload_Overlay = true,
    Overload_Tabulation = true,

    -- Galenwe
    Hoarfrost = true,
    ChillingComet = true,

    -- Portal
    Portal = true,
    Portal_Announcement = true,
    MalevolentCores = true,
    Spears = true,

    -- Z'Maja
    ZmajaJump = true,
    CrushingDarkness_Kite = true,
    CrushingDarkness_Next = true,
    ShadowSplash = true,
    BanefulMark = true,
    MaliciousSphere_Timer = true,
    MaliciousSphere_Announcement = true,
    MaliciousSphere_Tracking = true,
    MaliciousSphere_Execute = true,
    Creeper_Announcement = true,
  },
  ------------------------------
  -- Fontsizes
  ------------------------------
  -- General
  FontSize_HA = 32,
  FontSize_Rooted = 32,
  FontSize_BashAnnouncement = 32,

  -- Siroria
  FontSize_Flare = 50,


  -- Relequen
  FontSize_ReleHA = 32,
  FontSize_Overload = 50,

  -- Galenwe
  FontSize_Hoarfrost = 40,
  FontSize_ChillingComet = 40,

  -- Portal
  FontSize_Portal = 32,
  FontSize_Portal_Announcement = 40,
  -- Z'maja
  FontSize_ZmajaJump = 40,
  FontSize_CrushingDarkness_Kite = 40,
  FontSize_CrushingDarkness_Next = 32,
  FontSize_ShadowSplash = 32,
  FontSize_BanefulMark = 40,
  FontSize_MaliciousSphere_Tracking = 48,
  FontSize_MaliciousSphere_Announcement = 40,
  FontSize_MaliciousSphere_Timer = 32,
  FontSize_Creeper_Announcement = 32,

  Size_MiniFrame = 5,
  Sizes_MiniFrame = {
    [1] = {
      TopRow_OffsetX = 85,
      TopRow_OffsetY = 0,
      Mini_OffsetX = 5,
      Mini_OffsetY = 24,
      fontSize = 20,
    },
    [2] = {
      TopRow_OffsetX = 95,
      TopRow_OffsetY = 0,
      Mini_OffsetX = 5,
      Mini_OffsetY = 25,
      fontSize = 22,
    },
    [3] = {
      TopRow_OffsetX = 105,
      TopRow_OffsetY = 0,
      Mini_OffsetX = 5,
      Mini_OffsetY = 29,
      fontSize = 24,
    },
    [4] = {
      TopRow_OffsetX = 105,
      TopRow_OffsetY = 0,
      Mini_OffsetX = 5,
      Mini_OffsetY = 30,
      fontSize = 26,
    },
    [5] = {
      TopRow_OffsetX = 120,
      TopRow_OffsetY = 0,
      Mini_OffsetX = 5,
      Mini_OffsetY = 34,
      fontSize = 28,
    },
    [6] = {
      TopRow_OffsetX = 135,
      TopRow_OffsetY = 0,
      Mini_OffsetX = 5,
      Mini_OffsetY = 34,
      fontSize = 30,
    },
    [7] = {
      TopRow_OffsetX = 135,
      TopRow_OffsetY = 0,
      Mini_OffsetX = 5,
      Mini_OffsetY = 38,
      fontSize = 32,
    },
    [8] = {
      TopRow_OffsetX = 150,
      TopRow_OffsetY = 0,
      Mini_OffsetX = 5,
      Mini_OffsetY = 40,
      fontSize = 34,
    },
    [9] = {
      TopRow_OffsetX = 150,
      TopRow_OffsetY = 0,
      Mini_OffsetX = 5,
      Mini_OffsetY = 43,
      fontSize = 36,
    },
    [10] = {
      TopRow_OffsetX = 170,
      TopRow_OffsetY = 0,
      Mini_OffsetX = 5,
      Mini_OffsetY = 44,
      fontSize = 38,
    },
    [11] = {
      TopRow_OffsetX = 170,
      TopRow_OffsetY = 0,
      Mini_OffsetX = 5,
      Mini_OffsetY = 47,
      fontSize = 40,
    },
    [12] = {
      TopRow_OffsetX = 170,
      TopRow_OffsetY = 0,
      Mini_OffsetX = 5,
      Mini_OffsetY = 50,
      fontSize = 42,
    }
  },

  defaultSettingsChoice = "Show Everything",

  overloadColor = {1,0,1},
  overloadColorChoice = 4,
  OverloadFrequency = 5,
}
----------------------------------------------------------
--                Local Variables Default               --
----------------------------------------------------------
HTC = {
  ----- General Variables -----
  active = false, -- true when inside Cloudrest
  trackCombatEvents = false,  -- when enabled, all combat events are posted into chat
  inCombat = false,
  isSideBoss = false,

  String = HowToCloudrest.Strings,
  Color = HowToCloudrest.Color,

  ----- General Mini Variables -----
  groupMembers = {},

  siroAbilities = {
    [106532] = true, --when Siroria LA's
    [104755] = true, --when Siroria HA's
    [106601] = true, --when Siroria Jumps
    [104902] = true, --when Siroria does Banner
  },
  releAbilities = {
    [105776] = true, --when Relequen LA's
    [105780] = true, --when Relequen HA's
    [105796] = true, --when Relequen does Flux Burst (jump)
    [136735] = true, --when Relequen does Jolt (Cone?)
    [105380] = true, --when Relequen begins channeling Direct Current (Interrupt)
  },
  galeAbilities = {
    [105566] = true, --when Galenwe LA's
    [106375] = true, --when Galenwe HA's
    [106682] = true, --galenwe teleport
    [106378] = true, --when Galenwe does Donut
    [106405] = true, --when Galenwe begins channeling Glacial Spikes (Interrupt)
  },

  creeperRoot = false,

  --- Mini Heavy Attacks
  listHA = {},
  releHATime = 0,

  --- Mini Frame Specific variables ---
  siroShow = false,
  releShow = false,
  galeShow = false,
  --- Mini Jumps
  siroJumpTime = nil,
  releJumpTime = nil,
  galeJumpTime = nil,
  --------------------
  releBashTime = nil,
  galeBashTime = nil,
  releBashChannelTime = nil,
  galeBashChannelTime = nil,
  releBashAnnounceText = "",
  galeBashAnnounceText = "",
  siroSkillTime = nil,
  releSkillTime = nil,
  galeSkillTime = nil,
  --------------------

  ----- Siroria Specific Variables -----
  siroRoot = false,
  --------------------
  flare1 = {},
  flare2 = {},
  flareTime = nil,
  flareTarget = nil,
  flareTargetExecute = nil,

  ----- Relequen Specific Variables -----
  --- Overload (Barswap mechanic)
  overloadBar = nil,
  overloadTime = 0,
  overloadOnCd = false,
  overloadFreqCounter = 0,
  tabulation = true,  -- Overload blinking

  ----- Galenwe Specific Variables -----
  --hoarfrostDuration = 6, -- how many seconds until synergy available
  --hoarfrostMessage = "DROP FROST: |c00BFFF<<1>>|r", -- countdown: <<1>>
  --hoarfrostSynergyMessage = "|c1E90FF<<a:1>>|r DROPS FROST!", -- name: <<1>>
  hoarfrostTimer = 0,
  frostStarted = false,
  frostTargetName = "", -- Hoarfrost target name
  frostOneCount = 0,  -- Hoarfrost counter
  frostTwoCount = 0,  -- Hoarfrost counter
  lastFrost = false, -- Flag telling if the hoarfrost is the last one or not
  frostSynergy = false, -- Hoarfrost synergy available
  frostAoeActive = false, -- Frost AoE on the ground
  frostAoeTickGained = 0, -- Time of the last gained tick
  frostAoeTickFaded = 0, -- Time of the last faded tick
  --------------------
  chillingCometTime = nil,

  ----- Portal Variables -----
  --- Portal Timers
  portalTime = 0,
  isPortalOpen = false,
  portalGroup = 1,
  portalSpawnTipId = 100,

  --- Malevolent Core
  malevolentCoreCounter = 0,
  malevolentCoreIds = {},
  malevolentCoreNum = 0,

  --- Olorime Spears
  olorimeSpearCounter = 0,

  ----- Z'Maja Variables -----
  zmajaExecute = false,
  nocturnalsFavorCount = 0,

  -- Crushing Darkness (Kite)
  crushingDarknessKiteTime = nil,
  crushingDarknessNextTime = nil,
  kiting = false,

  -- Shadow Splash Cast (Interrupt)
  zmajaBashTime = nil,

  -- Z'Maja Jumping
  ZmajaJumpTime = 0,

  -- Baneful Mark during execute
  banefulMarkTime = 0,

  -- Malicious Sphere
  orbsRemaining = 0,
  maliciousStrikeCounter = 0,
  maliciousSphereExpired = false,
  maliciousSphereKillTime = nil,
  maliciousSphereNextTime = nil,
  maliciousSphereId = {},
  --------------------
}
HTC_Var_Reset_Values = HTC_AUX:DeepCopy(HTC) -- Save default values for all local variables. (Used when resetting)

function HowToCloudrest.HeavyAttack(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result ~= ACTION_RESULT_BEGIN or hitValue < 100 then return end

  if targetType == COMBAT_UNIT_TYPE_PLAYER and sV.Enable.HA then
    table.insert(HTC.listHA, GetGameTimeMilliseconds() + hitValue)
    HowToCloudrest.HeavyAttackUI()
    HTC_Ha:SetHidden(false)
    PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

    EM:UnregisterForUpdate(HowToCloudrest.name .. "HeavyAttackTimer")
    EM:RegisterForUpdate(HowToCloudrest.name .. "HeavyAttackTimer", 100, HowToCloudrest.HeavyAttackUI)

  elseif sV.Enable.ReleHA and abilityId == 105780 then
    HTC.ReleHATime = GetGameTimeMilliseconds() + hitValue
    HowToCloudrest.ReleHAUI()
    HTC_ReleHA:SetHidden(false)

    EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleHATimer")
    EM:RegisterForUpdate(HowToCloudrest.name .. "ReleHATimer", 100, HowToCloudrest.ReleHAUI)
  end
end

function HowToCloudrest.HeavyAttackUI()
  local text = ""
  local currentTime = GetGameTimeMilliseconds()

  for key, value in ipairs(HTC.listHA) do
    local timer = value - currentTime
    if timer > 0 then
      if text == "" then
        text = text .. tostring(string.format("%.1f", timer / 1000))
      else
        text = text .. "|cff1493 / |r" .. tostring(string.format("%.1f", timer / 1000))
      end
    else
      table.remove(HTC.listHA, key)
    end
  end

  if text ~= "" then
    HTC_Ha_Label:SetText("|cff1493HA: |r" .. text)
  else
    EM:UnregisterForUpdate(HowToCloudrest.name .. "HeavyAttackTimer")
    HTC_Ha:SetHidden(true)
  end
end
----------------------------------------------------------
--                     Mini Frame                       --
----------------------------------------------------------

--  Mini Spawn
function HowToCloudrest.MiniSpawn_Ability(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
  if not sV.Enable.MiniFrame then return end

  local currentTime = GetGameTimeMilliseconds() / 1000
  if HTC.siroAbilities[abilityId] then -- If Siroria cast the ability
    HowToCloudrest.MiniSpawn_Siroria(currentTime)
  elseif HTC.releAbilities[abilityId] then -- If Relequen cast the ability
    HowToCloudrest.MiniSpawn_Relequen(currentTime)
  elseif HTC.galeAbilities[abilityId] then -- If Galenwe cast the ability
    HowToCloudrest.MiniSpawn_Galenwe(currentTime)
  end
  HowToCloudrest.MiniSpawned()
end

function HowToCloudrest.Displacement(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
  if result ~= ACTION_RESULT_BEGIN then return end
  HTC_Debug("Mini Spawned! (Displacement)")
end

function HowToCloudrest.MiniSpawn_Disposition(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
  HTC_Debug("MiniSpawn_Disposition triggered!")
  HTC_Debug("MSD changeType: " .. tostring(changeType))
  HTC_Debug("MSD effectName: " .. tostring(effectName))
  HTC_Debug("MSD unitName: " .. tostring(unitName))
  HTC_Debug("MSD unitID: " .. tostring(unitId))
  HTC_Debug("MSD unitTag: " .. tostring(unitTag))
  if changeType ~= EFFECT_RESULT_GAINED then return end
  HowToCloudrest.MiniSpawned()
end

function HowToCloudrest.MiniSpawn_Siroria(timeSpawned)
  if not HTC.siroShow then
    HTC_Debug("Siroria spawned")
    HTC.siroJumpTime = timeSpawned + 0
  end
  HTC.siroShow = true
  HowToCloudrest.UnregisterForMiniSpawn(HTC.siroAbilities)
  HTC_MiniFrame_Siroria_Jump:SetText("-")
  HTC_MiniFrame_Siroria_Bash:SetText("-")
  HTC_MiniFrame_Siroria_Skill:SetText("-")
end

function HowToCloudrest.MiniSpawn_Relequen(timeSpawned)
  if not HTC.releShow then
    HTC_Debug("Relequen spawned")
    HTC.releJumpTime = timeSpawned + 0
  end
  HTC.releShow = true
  HowToCloudrest.UnregisterForMiniSpawn(HTC.releAbilities)
  HTC_MiniFrame_Relequen_Jump:SetText("-")
  HTC_MiniFrame_Relequen_Bash:SetText("-")
  HTC_MiniFrame_Relequen_Skill:SetText("-")
end

function HowToCloudrest.MiniSpawn_Galenwe(timeSpawned)
  if not HTC.galeShow then
    HTC_Debug("Galenwe spawned")
    HTC.galeJumpTime = timeSpawned + 0
  end
  HTC.galeShow = true
  HowToCloudrest.UnregisterForMiniSpawn(HTC.galeAbilities)
  HTC_MiniFrame_Galenwe_Jump:SetText("-")
  HTC_MiniFrame_Galenwe_Bash:SetText("-")
  HTC_MiniFrame_Galenwe_Skill:SetText("-")
end

function HowToCloudrest.MiniSpawned()
  if (HTC.siroShow or HTC.releShow or HTC.galeShow) then
    HowToCloudrest.UpdateMiniFrame()
    HTC_MiniFrame:SetHidden(false)
    HowToCloudrest.RegisterForAllMiniDeaths()
  end
end

--  Mini Death
function HowToCloudrest.MiniShackled(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
  if result ~= ACTION_RESULT_EFFECT_GAINED then return end

  local miniName = ""

  if HTC.siroShow then
    miniName = "Siroria"
  elseif HTC.releShow then
    miniName = "Relequen"
  elseif HTC.galeShow then
    miniName = "Galenwe"
  end
  HowToCloudrest.HideMiniUI(miniName)
end

function HowToCloudrest.OnBossDeath(eventCode, unitTag, isDead)
  local miniName = GetUnitName(unitTag)
  HTC_Debug(miniName .. " died!")

  if not DoesUnitExist(unitTag) or not isDead or unitTag:find("player") or unitTag:find("group") or unitTag:find("reticle") or unitTag:find("interact") then return end
  HTC_Debug(unitTag)

  HowToCloudrest.HideMiniUI(miniName)

  if GetUnitName(unitTag) == "Z'Maja" then --[[Do something when Z'Maja dies]] end
end

function HowToCloudrest.HideMiniUI(miniName)
  if miniName:find("Siroria") and HTC.siroShow then
    HTC_Debug("Siroria down!")
    HTC.siroShow = false
    HowToCloudrest.UnregisterForSiroriaFrameTimers()
    HowToCloudrest.UpdateMiniFrame()
    -- zo_callLater(function () HTC_MiniFrame_Siroria:SetHidden(true) end, 5000)
  elseif miniName:find("Relequen") and HTC.releShow then
    HTC_Debug("Relequen down!")
    HTC.releShow = false
    HowToCloudrest.UnregisterForRelequenFrameTimers()
    HowToCloudrest.UpdateMiniFrame()
    -- zo_callLater(function () HTC_MiniFrame_Relequen:SetHidden(true) end, 5000)
  elseif miniName:find("Galenwe") and HTC.galeShow then
    HTC_Debug("Galenwe down!")
    HTC.galeShow = false
    HowToCloudrest.UnregisterForGalenweFrameTimers()
    HowToCloudrest.UpdateMiniFrame()
    -- zo_callLater(function () HTC_MiniFrame_Galenwe:SetHidden(true) end, 5000)
  end

  if not(HTC.siroShow or HTC.releShow or HTC.galeShow) then
    HowToCloudrest.UnregisterForAllMiniFrameTimers()
    HowToCloudrest.UpdateMiniFrame()
    HTC_MiniFrame:SetHidden(true)
  end
end

-- function HowToCloudrest.OnOlorimeShackle(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
--     --if (((abilityId ~= 107490) or (abilityId ~= 107491)) or (abilityId ~= 107492)) then return end
--     if (not effectName:find("Shackles")) or (not effectName:find("Olorime")) then return end
--     HTC_Debug("OnOlorimeShackle fired!")
--     --HTC_Debug("Mini Shackled: " .. unitName)
--     -- HowToCloudrest.IdentifyUnit(unitId, unitName)
--     if (changeType == EFFECT_RESULT_GAINED) then
--         -- if unitName:find("Siroria") then
--         --     HTC_Debug("Shackled: unitName triggered")
--         -- elseif (unitId == HTC.unitId.Siroria) then
--         --     HTC_Debug("Shackled: UnitId triggered")
--         -- elseif unitName:find("Relequen") then
--         --     HTC_Debug("Shackled: unitName triggered")
--         -- elseif (unitId == HTC.unitId.Relequen) then
--         --     HTC_Debug("Shackled: UnitId triggered")
--         -- elseif unitName:find("Galenwe") then
--         --     HTC_Debug("Shackled: unitName triggered")
--         -- elseif (unitId == HTC.unitId.Galenwe) then
--         --     HTC_Debug("Shackled: UnitId triggered")
--         -- end
--         HowToCloudrest.HideMiniUI(unitName)
--     end
-- end
-------------------

--  Mini Jumps
function HowToCloudrest.MiniJump(_, result, _, _, _, _, sourceName, _, targetName, targetType, hitValue, _, _, _, _, _, abilityId)
    if result ~= ACTION_RESULT_BEGIN or not sV.Enable.MiniJump then return end

    local currentTime = GetGameTimeMilliseconds() / 1000

    if abilityId == 106601 then
        --HTC_Debug("Siroria jumped")
        HTC.siroJumpTime = currentTime + 23
        HTC_MiniFrame_Siroria_Jump:SetText(HTC.String.Mini_Jump_Cast)

        EM:UnregisterForUpdate(HowToCloudrest.name .. "SiroJumpTimer")
        zo_callLater(function () EM:RegisterForUpdate(HowToCloudrest.name .. "SiroJumpTimer", 1000, HowToCloudrest.MiniJumpUI) end, 3000)


    elseif abilityId == 105796 then
        --HTC_Debug("Relequen jumped")
        HTC.releJumpTime = currentTime + 19
        HTC_MiniFrame_Relequen_Jump:SetText(HTC.String.Mini_Jump_Cast)

        EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleJumpTimer")
        zo_callLater(function () EM:RegisterForUpdate(HowToCloudrest.name .. "ReleJumpTimer", 1000, HowToCloudrest.MiniJumpUI) end, 1000)

    elseif abilityId == 106682 then
        --HTC_Debug("Galenwe jumped")
        HTC.galeJumpTime = currentTime + 19
        HTC_MiniFrame_Galenwe_Jump:SetText(HTC.String.Mini_Jump_Cast)

        EM:UnregisterForUpdate(HowToCloudrest.name .. "GaleJumpTimer")
        zo_callLater(function () EM:RegisterForUpdate(HowToCloudrest.name .. "GaleJumpTimer", 1000, HowToCloudrest.MiniJumpUI) end, 3000)

    end
end

local function getMiniJumpText(miniJumpTime, currentTime)
    local miniText = "-"
    local timer = miniJumpTime - currentTime
        if timer >= 5 then
            miniText = HTC.Color.green(tostring(string.format("%.0f", timer)))
        elseif timer > 0 then
            miniText = HTC.Color.yellow(tostring(string.format("%.0f", timer)))
        else
            miniText = HTC.String.Mini_Jump_Off_Cooldown
        end
    return miniText
end

function HowToCloudrest.MiniJumpUI()

    if not sV.Enable.MiniJump then return end

    local currentTime = GetGameTimeMilliseconds() / 1000

    -- Siroria
    local siroText = "-"
    if HTC.siroJumpTime ~= nil then
        siroText = getMiniJumpText(HTC.siroJumpTime, currentTime)
    end
    if HTC.siroShow then
        HTC_MiniFrame_Siroria_Jump:SetText(siroText)
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "SiroJumpTimer")
    end

    -- Relequen
    local releText = "-"
    if HTC.releJumpTime ~= nil then
        releText = getMiniJumpText(HTC.releJumpTime, currentTime)
    end
    if HTC.releShow then
        HTC_MiniFrame_Relequen_Jump:SetText(releText)
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleJumpTimer")
    end

    -- Galenwe
    local galeText = "-"
    if HTC.galeJumpTime ~= nil then
        galeText = getMiniJumpText(HTC.galeJumpTime, currentTime)
    end
    if HTC.galeShow then
        HTC_MiniFrame_Galenwe_Jump:SetText(galeText)
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "GaleJumpTimer")
    end
end

--  Mini Bashes
function HowToCloudrest.MiniBash(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not (sV.Enable.MiniBash or sV.Enable.Announcement_MiniBash) then return end

    if result == ACTION_RESULT_BEGIN then
        local currentTime = GetGameTimeMilliseconds() / 1000

        if abilityId == 105380 then -- Relequens' Direct Current
            HTC.releBashTime = currentTime + 20

            HTC_MiniFrame_Relequen_Bash:SetText(HTC.String.Mini_Bash_Cast)
            PlaySound(SOUNDS.TELVAR_GAINED)

            if sV.Enable.Announcement_MiniBash then
                HTC.releBashChannelTime = currentTime
                EM:RegisterForUpdate(HowToCloudrest.name .. "ReleBashChannelTimer", 500, HowToCloudrest.MiniBashAnnouncement)
            end

            EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleBashTimer")
        end

        if abilityId == 106405 then -- Galenwes' Glacial Spikes
            HTC.galeBashTime = currentTime + 22

            -- HTC_Debug("Glacial spikes cast!")
            HTC_MiniFrame_Galenwe_Bash:SetText(HTC.String.Mini_Bash_Cast)
            PlaySound(SOUNDS.TELVAR_GAINED)

            if sV.Enable.Announcement_MiniBash then
                HTC.galeBashChannelTime = currentTime
                EM:RegisterForUpdate(HowToCloudrest.name .. "GaleBashChannelTimer", 500, HowToCloudrest.MiniBashAnnouncement)
            end
            EM:UnregisterForUpdate(HowToCloudrest.name .. "GaleBashTimer")
        end

    elseif result == ACTION_RESULT_EFFECT_FADED then
        local bashAnnounceText = ""
        if abilityId == 105380 then -- Relequens' Direct Current
            EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleBashChannelTimer")
            HTC.releBashAnnounceText = HTC.String.Announcement_ReleBash_Faded
            bashAnnounceText = HTC.releBashAnnounceText
            HTC.releBashChannelTime = nil

            HTC_MiniFrame_Relequen_Bash:SetText(HTC.String.Mini_Bash_Faded)
            zo_callLater(
                function()
                    HTC.releBashAnnounceText = ""
                    if sV.Enable.MiniBash then
                        EM:RegisterForUpdate(HowToCloudrest.name .. "ReleBashTimer", 1000, HowToCloudrest.MiniBashUI)
                    end
                end, 1000)
        end

        if abilityId == 106405 then -- Galenwes' Glacial Spikes
            EM:UnregisterForUpdate(HowToCloudrest.name .. "GaleBashChannelTimer")
            if bashAnnounceText ~= "" then
                bashAnnounceText = bashAnnounceText .. " / "
            end
            HTC.galeBashAnnounceText = HTC.String.Announcement_GaleBash_Faded
            bashAnnounceText = bashAnnounceText .. HTC.galeBashAnnounceText
            HTC.galeBashChannelTime = nil

            HTC_MiniFrame_Galenwe_Bash:SetText(HTC.String.Mini_Bash_Faded)
            zo_callLater(
                function()
                    HTC.galeBashAnnounceText = ""
                    if sV.Enable.MiniBash then
                        EM:RegisterForUpdate(HowToCloudrest.name .. "GaleBashTimer", 1000, HowToCloudrest.MiniBashUI)
                    end
                end, 1000)
        end

        HTC_Announcement_MiniBash_Label:SetText(bashAnnounceText)
        zo_callLater(function() HTC_Announcement_MiniBash:SetHidden(true) end, 1500)

    end
end

function HowToCloudrest.MiniBashAnnouncement()

    local currentTime = GetGameTimeMilliseconds() / 1000
    local bashAnnounceText = ""

    if HTC.releBashChannelTime ~= nil then
        local timer = currentTime - HTC.releBashChannelTime
        if timer <= 1 then
            HTC.releBashAnnounceText = HTC.String.Announcement_ReleBash_1
        elseif timer <= 2 then
            HTC.releBashAnnounceText = HTC.String.Announcement_ReleBash_2
        elseif timer <= 3 then
            HTC.releBashAnnounceText = HTC.String.Announcement_ReleBash_3
        elseif timer <= 4 then
            HTC.releBashAnnounceText = HTC.String.Announcement_ReleBash_4
        elseif timer <= 6 then
            EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleBashChannelTimer")
            HTC.releBashAnnounceText = HTC.String.Announcement_ReleBash_Faded
            HTC.releBashChannelTime = nil
            zo_callLater(function() HTC_Announcement_MiniBash:SetHidden(true) end, 2000)
        end
    end

    bashAnnounceText = HTC.releBashAnnounceText

    if HTC.galeBashChannelTime ~= nil then
        local timer = currentTime - HTC.galeBashChannelTime
        if timer <= 1 then
            HTC.galeBashAnnounceText = HTC.String.Announcement_GaleBash_1
        elseif timer <= 2 then
            HTC.galeBashAnnounceText = HTC.String.Announcement_GaleBash_2
        elseif timer <= 3 then
            HTC.galeBashAnnounceText = HTC.String.Announcement_GaleBash_3
        elseif timer <= 4 then
            HTC.galeBashAnnounceText = HTC.String.Announcement_GaleBash_4
        elseif timer <= 5 then
            HTC.galeBashAnnounceText = HTC.String.Announcement_GaleBash_5
        elseif timer <= 6 then
            HTC.galeBashAnnounceText = HTC.String.Announcement_GaleBash_6
        elseif timer <= 8 then
            EM:UnregisterForUpdate(HowToCloudrest.name .. "GaleBashChannelTimer")
            HTC.galeBashAnnounceText = HTC.String.Announcement_GaleBash_Faded
            HTC.galeBashChannelTime = nil
            zo_callLater(function() HTC_Announcement_MiniBash:SetHidden(true) end, 2000)
        end
    end

    if bashAnnounceText ~= "" and HTC.galeBashAnnounceText ~= "" then
        bashAnnounceText = bashAnnounceText .. " / "
    end

    bashAnnounceText = bashAnnounceText .. HTC.galeBashAnnounceText

    if bashAnnounceText ~= "" then
        HTC_Announcement_MiniBash:SetHidden(false)
        HTC_Announcement_MiniBash_Label:SetText(bashAnnounceText)
    end
end

local function getMiniBashText(miniBashTime, currentTime)
    local miniText = "-"
    local timer = miniBashTime - currentTime
        if timer >= 5 then
            miniText = HTC.Color.green(tostring(string.format("%.0f", timer)))
        elseif timer > 0 then
            miniText = HTC.Color.yellow(tostring(string.format("%.0f", timer)))
        else
            miniText = HTC.String.Mini_Bash_Off_Cooldown
        end
    return miniText
end

function HowToCloudrest.MiniBashUI()

    local currentTime = GetGameTimeMilliseconds() / 1000

    -- Relequen
    local releBashText = "-"
    if HTC.releBashTime ~= nil then
        releBashText = getMiniBashText(HTC.releBashTime, currentTime)
    end
    if HTC.releShow then
        HTC_MiniFrame_Relequen_Bash:SetText(releBashText)
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleBashTimer")
    end


    -- Galenwe
    local galeBashText = "-"
    if HTC.galeBashTime ~= nil then
        galeBashText = getMiniBashText(HTC.galeBashTime, currentTime)
    end
    if HTC.galeShow then
        HTC_MiniFrame_Galenwe_Bash:SetText(galeBashText)
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "GaleBashTimer")
    end
end

--  Mini Special Skills
function HowToCloudrest.MiniSkill(_, result, _, _, _, _, sourceName, _, targetName, targetType, hitValue, _, _, _, _, _, abilityId)
    if result ~= ACTION_RESULT_BEGIN or not sV.Enable.MiniSkill then return end

    local currentTime = GetGameTimeMilliseconds() / 1000

    if abilityId == 104902 then
        --HTC_Debug("Siroria used banner!")
        HTC.siroSkillTime = currentTime + 45
        HTC_MiniFrame_Siroria_Skill:SetText(HTC.String.Mini_Skill_Cast)

        EM:UnregisterForUpdate(HowToCloudrest.name .. "SiroSkillTimer")
        zo_callLater(function () EM:RegisterForUpdate(HowToCloudrest.name .. "SiroSkillTimer", 1000, HowToCloudrest.MiniSkillUI) end, 500)

    elseif abilityId == 106614 then
        --HTC_Debug("Relequen used cone!")
        HTC.releSkillTime = currentTime + 15
        HTC_MiniFrame_Relequen_Skill:SetText(HTC.String.Mini_Skill_Cast)

        EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleSkillTimer")
        zo_callLater(function () EM:RegisterForUpdate(HowToCloudrest.name .. "ReleSkillTimer", 1000, HowToCloudrest.MiniSkillUI) end, 1500)

    elseif abilityId == 106378 then
        --HTC_Debug("Galenwe used donut!")
        HTC.galeSkillTime = currentTime + 22
        HTC_MiniFrame_Galenwe_Skill:SetText(HTC.String.Mini_Skill_Cast)

        EM:UnregisterForUpdate(HowToCloudrest.name .. "GaleSkillTimer")
        zo_callLater(function () EM:RegisterForUpdate(HowToCloudrest.name .. "GaleSkillTimer", 1000, HowToCloudrest.MiniSkillUI) end, 500)
    end
end

local function getMiniSkillText(miniSkillTime, currentTime)
    local miniText = "-"
    local timer = miniSkillTime - currentTime
        if timer >= 5 then
            miniText = HTC.Color.green(tostring(string.format("%.0f", timer)))
        elseif timer > 0 then
            miniText = HTC.Color.yellow(tostring(string.format("%.0f", timer)))
        else
            miniText = HTC.String.Mini_Skill_Off_Cooldown
        end
    return miniText
end

function HowToCloudrest.MiniSkillUI()

    if not sV.Enable.MiniSkill then return end

    local currentTime = GetGameTimeMilliseconds() / 1000

    -- Siroria
    local siroSkillText = "-"
    if HTC.siroSkillTime ~= nil then
        siroSkillText = getMiniSkillText(HTC.siroSkillTime, currentTime)
    end
    if HTC.siroShow then
        HTC_MiniFrame_Siroria_Skill:SetText(siroSkillText)
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "SiroSkillTimer")
    end

    -- Relequen
    local releSkillText = "-"
    if HTC.releSkillTime ~= nil then
        releSkillText = getMiniSkillText(HTC.releSkillTime, currentTime)
    end
    if HTC.releShow then
        HTC_MiniFrame_Relequen_Skill:SetText(releSkillText)
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleSkillTimer")
    end

    -- Galenwe
    local galeSkillText = "-"
    if HTC.galeSkillTime ~= nil then
        galeSkillText = getMiniSkillText(HTC.galeSkillTime, currentTime)
    end
    if HTC.galeShow then
        HTC_MiniFrame_Galenwe_Skill:SetText(galeSkillText)
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "GaleSkillTimer")
    end
end

--  Razor Thorns (Creeper rooting ability)
function HowToCloudrest.RazorThorns(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not sV.Enable.RazorThorns or targetType ~= COMBAT_UNIT_TYPE_PLAYER) then return end

	if (result == ACTION_RESULT_EFFECT_GAINED) then

        HTC.creeperRoot = true
		HTC_Rooted_Label:SetText(HTC.String.RazorThorns)
		HTC_Rooted:SetHidden(false)
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

	elseif (result == ACTION_RESULT_EFFECT_FADED) then

        HTC.creeperRoot = false
        if HTC.siroRoot and sV.Enable.DarkTalons then
            HTC_Rooted_Label:SetText(HTC.String.DarkTalons)
        else
            HTC_Rooted:SetHidden(true)
        end
	end
end
----------------------------------------------------------
--                      SIRORIA                         --
----------------------------------------------------------

--  Dark Talons (Siroria root ability)
function HowToCloudrest.DarkTalons(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	if (not sV.Enable.DarkTalons or targetType ~= COMBAT_UNIT_TYPE_PLAYER) then return end

	if (result == ACTION_RESULT_EFFECT_GAINED) then

        HTC.siroRoot = true
        if not HTC.creeperRoot and sV.Enable.RazorThorns then
            HTC_Rooted_Label:SetText(HTC.String.DarkTalons)
        end
		HTC_Rooted:SetHidden(false)
		PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

	elseif (result == ACTION_RESULT_EFFECT_FADED) then

        HTC.siroRoot = false
        if not HTC.creeperRoot then
            HTC_Rooted:SetHidden(true)
        end
	end
end

function HowToCloudrest.RoaringFlare(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
	if result ~= ACTION_RESULT_BEGIN or sV.Enable.Flare ~= true or not HTC.groupMembers[targetUnitId] then return end

    HTC.flareTime = GetGameTimeMilliseconds() + 6600
    if abilityId == 110431 then
        HTC.flareTargetExecute = HTC.groupMembers[targetUnitId].name
    else
        HTC.flareTarget = HTC.groupMembers[targetUnitId].name
    end
    PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

    HowToCloudrest.RoaringFlareUI()
    HTC_Flare:SetHidden(false)

    EM:UnregisterForUpdate(HowToCloudrest.name .. "RoaringFlareTimer")
    EM:RegisterForUpdate(HowToCloudrest.name .. "RoaringFlareTimer", 100, HowToCloudrest.RoaringFlareUI)
end

function HowToCloudrest.RoaringFlareUI()
    if HTC.flareTime == nil or HTC.flareTarget == nil then return end

    local currentTime = GetGameTimeMilliseconds()
    local timer = HTC.flareTime - currentTime

    if timer > 0 then
        if HTC.flareTargetExecute ~= nil then
            HTC_Flare_Label:SetText(HTC.String.FlareExecFunc(HTC.flareTarget, HTC.flareTargetExecute, tostring(string.format("%.1f", timer / 1000))))
        else
            HTC_Flare_Label:SetText(HTC.String.FlareFunc(HTC.flareTarget) .. HTC.Color.red(tostring(string.format("%.1f", timer / 1000))))
        end
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "RoaringFlareTimer")
        HTC_Flare:SetHidden(true)

        HTC.flareTime = nil
        HTC.flareTarget = nil
        HTC.flareTargetExecute = nil
    end
end
----------------------------------------------------------
--                      RELEQUEN                        --
----------------------------------------------------------

--  Relequen Heavy Attack (AOE)
function HowToCloudrest.ReleHAUI()
    local currentTime = GetGameTimeMilliseconds()
    local timer = HTC.ReleHATime - currentTime

    if timer > 0 then
        HTC_ReleHA_Label:SetText(HTC.String.ReleHA .. tostring(string.format("%.1f", timer / 1000)))
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleHATimer")
        HTC_ReleHA:SetHidden(true)
    end
end

--  Relequen Overload (Barswap)
function HowToCloudrest.Overload(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
    if result ~= ACTION_RESULT_EFFECT_GAINED_DURATION or targetType ~= COMBAT_UNIT_TYPE_PLAYER or sV.Enable.Overload ~= true then return end

    HTC.overloadTime = GetGameTimeMilliseconds() + hitValue
    HTC.overloadFreqCounter = 0

    if abilityId == 103555 then
        --HTC_Debug("Overload first")
        HTC.overloadOnCd = true
    elseif abilityId == 87346 then
        --HTC_Debug("Overload second")
        HTC.overloadOnCd = false
        if sV.Enable.Overload_Overlay then
            HTC_Overload:SetHidden(false)
        end
    end

    HowToCloudrest.OverloadUI()
    HTC_OverloadTimer:SetHidden(false)

    EM:UnregisterForUpdate(HowToCloudrest.name .. "OverloadTimer")
    EM:RegisterForUpdate(HowToCloudrest.name .. "OverloadTimer", 100, HowToCloudrest.OverloadUI)
end

function HowToCloudrest.OverloadUI()
    local currentTime = GetGameTimeMilliseconds()
    local timer = HTC.overloadTime - currentTime

    HTC.overloadFreqCounter = HTC.overloadFreqCounter + 1
    if HTC.overloadFreqCounter == sV.OverloadFrequency then
        HTC.overloadFreqCounter = 0
        HTC.tabulation = not HTC.tabulation
    end
    local stringToShow
    if HTC.overloadOnCd then
        stringToShow = HTC.String.Overload_Incoming
    elseif sV.Enable.Overload_Tabulation then
        if HTC.tabulation then
            stringToShow = HTC.String.Overload_Tab1
        else
            stringToShow = HTC.String.Overload_Tab2
        end
    else
        stringToShow = HTC.String.Overload_Static
    end

    if timer > 0 and HTC.overloadOnCd then
        HTC_OverloadTimer_Label:SetText(stringToShow .. HTC.Color.yellow(tostring(string.format("%.1f", timer / 1000))))
    elseif timer > 0 then
        HTC_OverloadTimer_Label:SetText(stringToShow .. HTC.Color.red(tostring(string.format("%.1f", timer / 1000))))
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "OverloadTimer")
        HTC_OverloadTimer:SetHidden(true)

        if sV.Enable.Overload_Overlay then
            HTC_Overload:SetHidden(true)
        end
    end
end
----------------------------------------------------------
--                      GALENWE                         --
----------------------------------------------------------
function HowToCloudrest.HoarfrostCast(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not sV.Enable.Hoarfrost) then return end

    if (result == ACTION_RESULT_EFFECT_GAINED) then

        if abilityId == 105151 then
            HTC.frostOneCount = 0
            -- HTC_Debug("Hoarfrost 1 count reset!")
        elseif abilityId == 110466 then
            -- HTC_Debug("Hoarfrost 2 count reset!")
            HTC.frostTwoCount = 0
        end

        if targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end

		HowToCloudrest.FrostControlShow(HTC.String.Hoarfrost_Incoming)
		PlaySound(SOUNDS.NEW_MAIL)

	-- Need additional check here because this event can be fired after Hoarfrost effect gained (thus will hide the timer)
	elseif (not HTC.frostStarted and result == ACTION_RESULT_EFFECT_FADED) and targetType == COMBAT_UNIT_TYPE_PLAYER then

		HowToCloudrest.FrostControlHide()
	end
end

function HowToCloudrest.Hoarfrost(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not sV.Enable.Hoarfrost) then return end

	if (result == ACTION_RESULT_EFFECT_GAINED) then

        local currentTime = GetGameTimeMilliseconds() / 1000

        if abilityId == 103695 then
            HTC.frostOneCount = HTC.frostOneCount + 1
            -- HTC_Debug("Hoarfrost 1 picked up: " .. tostring(HTC.frostOneCount))
        elseif abilityId == 110516 then
            HTC.frostTwoCount = HTC.frostTwoCount + 1
            -- HTC_Debug("Hoarfrost 2 picked up: " .. tostring(HTC.frostTwoCount))
        end

        if targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end

		HTC.frostStarted = true
        HTC.hoarfrostTimer = currentTime + 6

        if abilityId == 103695 then
            if HTC.frostOneCount == 3 then
                HTC.lastFrost = true
            else
                HTC.lastFrost = false
            end
        elseif abilityId == 110516 then
            if HTC.frostTwoCount == 3 then
                HTC.lastFrost = true
            else
                HTC.lastFrost = false
            end
        end

		EM:UnregisterForUpdate(HowToCloudrest.name .. "FrostTimer")
		EM:RegisterForUpdate(HowToCloudrest.name .. "FrostTimer", 1000, HowToCloudrest.FrostTimerTick)

		--HowToCloudrest.FrostControlShow(HTC.String.Hoarfrost_Base .. HTC.Color.green(HTC.frostCount))
        HowToCloudrest.FrostTimerTick()
        PlaySound(SOUNDS.JUSTICE_NOW_KOS)
        --HTC_Hoarfrost:SetHidden(false)

	elseif (result == ACTION_RESULT_EFFECT_FADED and targetType == COMBAT_UNIT_TYPE_PLAYER) then
        --HTC_Debug("Hoarfrost faded!")
		HTC.frostStarted = false
		HowToCloudrest.FrostTimerStopAndHide()
	end
end

function HowToCloudrest.FrostTimerTick()

	local currentTime = GetGameTimeMilliseconds() / 1000
    local timer = HTC.hoarfrostTimer - currentTime
    local pretext = HTC.String.Hoarfrost_Base

    if HTC.lastFrost then
        pretext = HTC.String.Hoarfrost_Base_Last
    end

    if timer >= 5 then
        HowToCloudrest.FrostControlShow(pretext .. HTC.Color.green(string.format("%.0f", timer)))
        PlaySound(SOUNDS.COUNTDOWN_TICK)
    elseif timer > 0 then
        HowToCloudrest.FrostControlShow(pretext .. HTC.Color.yellow(string.format("%.0f", timer)))
        PlaySound(SOUNDS.COUNTDOWN_TICK)
    else
        HowToCloudrest.FrostControlShow(pretext .. HTC.Color.yellow(string.format("%.0f", timer)))
        EM:UnregisterForUpdate(HowToCloudrest.name .. "FrostTimer")
    end

    -- TODO: test
    -- if timer >= 3 and timer <= 4 then
    --     EM:UnregisterForUpdate(HowToCloudrest.name .. "FrostTimer")
    --     EM:RegisterForUpdate(HowToCloudrest.name .. "FrostTimer", 100, HowToCloudrest.FrostTimerTick)
    -- end
end

function HowToCloudrest.FrostTimerStopAndHide()

	EM:UnregisterForUpdate(HowToCloudrest.name .. "FrostTimer")
	HowToCloudrest.FrostControlHide()

end

function HowToCloudrest.HoarfrostSynergy(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not sV.Enable.Hoarfrost or targetType ~= COMBAT_UNIT_TYPE_PLAYER) then return end

	if (result == ACTION_RESULT_EFFECT_GAINED_DURATION) then

		-- Stop countdown

        HTC.frostSynergy = true
        if HTC.lastFrost then
            HowToCloudrest.FrostControlShow(HTC.String.Hoarfrost_Drop_Last)
        else
            HowToCloudrest.FrostControlShow(HTC.String.Hoarfrost_Drop)
        end
        PlaySound(SOUNDS.DUEL_START)

		-- after 5s don't wait for event and hide the message
		-- to prevent an issue when the message stays inside shadow realm, because people inside it don't recieve some events from people outside
		--[[ not needed atm, because we only track frost synergy on ourselves
		zo_callLater(
			function()
				if (HowToCloudrest.frostSynergy) then
					HowToCloudrest.frostSynergy = false
					HowToCloudrest.FrostControlHide()
				end
			end,
			5000
		)
		]]

	elseif (result == ACTION_RESULT_EFFECT_FADED) then

        HTC.frostSynergy = false
        HTC_Hoarfrost_Label:SetText(HTC.Color.galeDark("OK"))
		zo_callLater(function() HowToCloudrest.FrostControlHide() end, 1000)
	end
end

function HowToCloudrest.HoarfrostAoe(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if (not sV.Enable.Hoarfrost) then return end

	local t = GetFrameTimeSeconds()

	-- if a player doesn't have hoarfrost on him, but there is an aoe to pick up, then spam him with notifications
	if (not HTC.frostStarted) then

        if (result == ACTION_RESULT_EFFECT_GAINED) then

			-- while frost aoe is active, trigger notification every 1.5s
			if (not HTC.frostAoeActive) then

				EM:UnregisterForUpdate(HowToCloudrest.name .. "HoarfrostAoeTick")
				EM:RegisterForUpdate(HowToCloudrest.name .. "HoarfrostAoeTick", 1500, HowToCloudrest.HoarfrostAoeTick)

				HTC_Hoarfrost_Label:SetText(HTC.String.Hoarfrost_Pick_Up)
				HTC_AUX:FadeInControl(HTC_Hoarfrost, 800)

				PlaySound(SOUNDS.DEATH_RECAP_ATTACK_SHOWN)
			end

			HTC.frostAoeActive = true
			HTC.frostAoeTickGained = t

		elseif (result == ACTION_RESULT_EFFECT_FADED) then

			HTC.frostAoeTickFaded = t
		end
	end
end

function HowToCloudrest.HoarfrostAoeTick()

	local t = GetFrameTimeSeconds()

	-- if another frost tick occured recently, then keep the message, otherwise stop the notification
	if (t - HTC.frostAoeTickGained < 1) then

		-- don't show it to a player who picked up another frost
		if (not HTC.frostStarted) then

			HTC_Hoarfrost_Label:SetText(HTC.String.Hoarfrost_Pick_Up)
			HTC_AUX:FadeInControl(HTC_Hoarfrost, 800)

			PlaySound(SOUNDS.DEATH_RECAP_ATTACK_SHOWN)
		end

	else

		EM:UnregisterForUpdate(HowToCloudrest.name .. "HoarfrostAoeTick")
		HTC.frostAoeActive = false

		-- don't hide control if player has frost debuff
		if (not HTC.frostStarted) then
			HowToCloudrest.FrostControlHide()
		end
	end
end

-- Show frost control with optional text
function HowToCloudrest.FrostControlShow(text)

	HTC_Hoarfrost:SetHidden(false)

	if (text ~= nil) then
		HTC_Hoarfrost_Label:SetText(text)
	end
end

function HowToCloudrest.FrostControlHide()

    HTC_Hoarfrost_Label:SetText(HTC.String.Hoarfrost_Drop)
	HTC_Hoarfrost:SetHidden(true)
end

function HowToCloudrest.ChillingComet(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

    if sV.Enable.ChillingComet then
        HTC_Debug(tostring(result) .. " Chilling comet. TargetType: " .. tostring(targetType))
    end

    if (result ~= ACTION_RESULT_EFFECT_GAINED
    or targetType ~= COMBAT_UNIT_TYPE_PLAYER)
    or (not sV.Enable.ChillingComet) then return end

    HTC_Debug("Comet! This should print when comet is enabled and on you.")

    local currentTime = GetGameTimeMilliseconds() / 1000
    HTC.chillingCometTime = currentTime + 4


    HowToCloudrest.ChillingCometUI()
    HTC_ChillingComet:SetHidden(false)

    EM:UnregisterForUpdate(HowToCloudrest.name .. "ChillingCometTimer")
    EM:RegisterForUpdate(HowToCloudrest.name .. "ChillingCometTimer", 100, HowToCloudrest.ChillingCometUI)
end

function HowToCloudrest.ChillingCometUI()
    if HTC.chillingCometTime == nil then return end

    local currentTime = GetGameTimeMilliseconds() / 1000
    local timer = HTC.chillingCometTime - currentTime

    if timer > 0 then
        HTC_ChillingComet_Label:SetText(HTC.String.ChillingComet_Base .. HTC.Color.red(tostring(string.format("%.1f", timer))))
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "ChillingCometTimer")
        HTC_ChillingComet:SetHidden(true)
    end
end
----------------------------------------------------------
--                      PORTAL                          --
----------------------------------------------------------

--  Portal timers
function HowToCloudrest.PortalOpen(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    HTC.olorimeSpearCounter = 0
	HTC.malevolentCoreIds = {}
    HTC.malevolentCoreNum = 0

    if sV.Enable.Portal_Announcement and result == ACTION_RESULT_BEGIN then
        if ( HTC.portalGroup == 1 ) then
            HTC_Portal_Announcement_Label:SetText(HTC.String.Portal_Announcement_1 .. HTC.Color.portalOne(tostring(HTC.portalGroup)) .. HTC.String.Portal_Announcement_2)
        else
            HTC_Portal_Announcement_Label:SetText(HTC.String.Portal_Announcement_1 .. HTC.Color.portalTwo(tostring(HTC.portalGroup)) .. HTC.String.Portal_Announcement_2)
        end

        HTC_Portal_Announcement:SetHidden(false)
        zo_callLater(function () HTC_Portal_Announcement:SetHidden(true) end, 3000)
    end

    if not sV.Enable.Portal or result ~= ACTION_RESULT_EFFECT_GAINED then return end
    EM:UnregisterForUpdate(HowToCloudrest.name .. "PortalTimer")

    local currentTime = GetGameTimeMilliseconds() / 1000
    local portalOpenText = ""

    HTC.portalTime = currentTime + 75 --Time until portal closes
    HTC.isPortalOpen = true
    HTC_Portal:SetHidden(false)

    if HTC.portalGroup == 1 then
        portalOpenText = HTC.String.Portal_Open_Cast_1 .. HTC.Color.portalOne(HTC.portalGroup) .. HTC.String.Portal_Open_Cast_2
    elseif HTC.portalGroup == 2 then
        portalOpenText = HTC.String.Portal_Open_Cast_1 .. HTC.Color.portalTwo(HTC.portalGroup) .. HTC.String.Portal_Open_Cast_2
    end
    HTC_Portal_Label:SetText(portalOpenText)

    zo_callLater(function () EM:RegisterForUpdate(HowToCloudrest.name .. "PortalTimer", 1000, HowToCloudrest.PortalUI) end, 2000)
end

function HowToCloudrest.PortalClosed(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    -- If it's not a side boss, don't use "player exit shadowrealm" as indicator that portal closed.
    if abilityId == 105218 and not HTC.isSideBoss then return end
    -- If portal is not enabled, or the portal is not open, then return immediately.
    if not sV.Enable.Portal or not (result == ACTION_RESULT_EFFECT_FADED) or not HTC.isPortalOpen then return end
    HTC_Debug("Portal closed by '" .. abilityName .. "' (" .. tostring(abilityId) ..  "), result = " .. result)

    -- Will fix interrupt message of shadow realm boss from displaying after portal closes
    HTC_ShadowSplash:SetHidden(true)

	-- Hide Counters when Shadow Realm is closed
	-- HTC_Frame_MalevolentCoreCounter:SetHidden(true)
	-- HTC_Frame_OlorimeSpearCounter:SetHidden(true)
	HTC.malevolentCoreCounter = 0
    HTC.olorimeSpearCounter = 0

    EM:UnregisterForUpdate(HowToCloudrest.name .. "PortalTimer")

    local currentTime = GetGameTimeMilliseconds() / 1000

    -- if abilityId == 104057 then
    --     HTC_Debug("Portal closed by '" .. abilityName .. "' (" .. tostring(abilityId) ..  ")")
    -- elseif abilityId == 104792 then
    --     HTC_Debug("Portal closed by '" .. abilityName .. "' (" .. tostring(abilityId) ..  ")")
    -- elseif abilityId == 105890 then
    --     HTC_Debug("Portal closed by '" .. abilityName .. "' (" .. tostring(abilityId) ..  ")")
    -- elseif abilityId == 105218 then
    --     HTC_Debug("Portal closed by '" .. abilityName .. "' (" .. tostring(abilityId) ..  ")")
    -- end

    HTC.portalTime = currentTime + 46 -- Time till next portal spawns
    HTC.isPortalOpen = false
    if HTC.portalGroup == 1 then
        HTC.portalGroup = 2
    else
        HTC.portalGroup = 1
    end
    local portalClosedText = HTC.String.Portal_Closed_Cast
    if abilityId == 105890 then
        HTC.portalGroup = 1
        portalClosedText = HTC.String.Portal_Closed_1 .. HTC.Color.portalOne(HTC.portalGroup) .. HTC.String.Portal_Closed_2
    end

    HTC_Portal_Label:SetText(portalClosedText)
    HTC_Portal:SetHidden(false)
    zo_callLater(function () EM:RegisterForUpdate(HowToCloudrest.name .. "PortalTimer", 1000, HowToCloudrest.PortalUI) end, 3000)
end

function HowToCloudrest.PortalUI()

    if not sV.Enable.Portal then return end
    if HTC.zmajaExecute then
        EM:UnregisterForUpdate(HowToCloudrest.name .. "PortalTimer")
        HTC_Portal:SetHidden(true)
        return
    end

    local currentTime = GetGameTimeMilliseconds() / 1000
    local timer = HTC.portalTime - currentTime

    local portalText = ""

    -- Set pretext (e.g. "Next portal (1): " or "Portal closes:")
    if HTC.portalGroup == 1 and HTC.isPortalOpen then
        portalText = HTC.String.Portal_Open_1 .. HTC.Color.portalOne(tostring(HTC.portalGroup)) .. HTC.String.Portal_Open_2
    elseif HTC.portalGroup == 2 and HTC.isPortalOpen then
        portalText = HTC.String.Portal_Open_1 .. HTC.Color.portalTwo(tostring(HTC.portalGroup)) .. HTC.String.Portal_Open_2
    elseif HTC.portalGroup == 1 and not HTC.isPortalOpen then
        portalText = HTC.String.Portal_Closed_1 .. HTC.Color.portalOne(tostring(HTC.portalGroup)) .. HTC.String.Portal_Closed_2
    elseif HTC.portalGroup == 2 and not HTC.isPortalOpen then
        portalText = HTC.String.Portal_Closed_1 .. HTC.Color.portalTwo(tostring(HTC.portalGroup)) .. HTC.String.Portal_Closed_2
    end

    -- Set timer text
    --HTC_Debug("PortalTimer: " .. tostring(string.format("%.0f", timer)))
    if timer >= 5 then
        portalText = portalText .. HTC.Color.green(tostring(string.format("%.0f", timer)))
    elseif timer > 0 then
        portalText = portalText .. HTC.Color.yellow(tostring(string.format("%.0f", timer)))
    elseif HTC.isPortalOpen then
        portalText = HTC.String.Portal_Out_Of_Time
    else
        portalText = portalText .. HTC.String.Portal_Off_Cooldown
    end

    HTC_Portal_Label:SetText(portalText)
end

function HowToCloudrest.ResetPortals(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if ( result == ACTION_RESULT_EFFECT_GAINED ) then
		HTC.portalGroup = 1;
		HTC_Portal:SetHidden(true)
		HTC_Portal_Announcement:SetHidden(true)
	end
end
----------------------------------------------------------
--                      Z'Maja                          --
----------------------------------------------------------

--  Z'Maja Jumping (Timer affected by Crushing Darkness aswell)
function HowToCloudrest.ZmajaJump(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
    if result ~= ACTION_RESULT_BEGIN or not sV.Enable.ZmajaJump then return end

    HTC.ZmajaJumpTime = GetGameTimeMilliseconds() / 1000 + 19.9
    EM:UnregisterForUpdate(HowToCloudrest.name .. "ZmajaJumpTimer")
    zo_callLater(function () EM:RegisterForUpdate(HowToCloudrest.name .. "ZmajaJumpTimer", 1000, HowToCloudrest.ZmajaJumpUI) end, 3000)

    HTC_ZmajaJump:SetHidden(false)
    HTC_ZmajaJump_Label:SetText(HTC.String.ZMaja_Jump_Base .. HTC.String.ZMaja_Jump_Cast)
end

function HowToCloudrest.ZmajaJumpUI()
    if HTC.ZmajaJumpTime == nil then return end

    local currentTime = GetGameTimeMilliseconds() / 1000
    local timer = HTC.ZmajaJumpTime - currentTime

    if timer >= 5 then
        HTC_ZmajaJump_Label:SetText(HTC.String.ZMaja_Jump_Base .. HTC.Color.green(tostring(string.format("%.0f", timer))))
    elseif timer > 0 then
        HTC_ZmajaJump_Label:SetText(HTC.String.ZMaja_Jump_Base .. HTC.Color.yellow(tostring(string.format("%.0f", timer))))
    else
        HTC_ZmajaJump_Label:SetText(HTC.String.ZMaja_Jump_Base .. HTC.String.ZMaja_Jump_Off_Cooldown)
        EM:UnregisterForUpdate(HowToCloudrest.name .. "ZmajaJumpTimer")
    end
end

function HowToCloudrest.HideJump(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
    if result ~= ACTION_RESULT_BEGIN then return end
    EM:UnregisterForUpdate(HowToCloudrest.name .. "ZmajaJumpTimer")
    HTC_Debug("Going into execute!")
    HTC.zmajaExecute = true
    HTC_ZmajaJump:SetHidden(true)
    HTC_Portal:SetHidden(true)
    HTC_Portal_Announcement:SetHidden(true)
end

-- Z'Maja's Crushing Darkness (Kite) (Affects Zmaja Jump timer)
function HowToCloudrest.CrushingDarkness(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
    if not (sV.Enable.ZmajaJump or sV.Enable.CrushingDarkness) or HTC.zmajaExecute then return end

    local currentTime = GetGameTimeMilliseconds() / 1000

    -- When Zmaja casts Crushing Darkness, she will jump within the next 12 sec
    if sV.Enable.ZmajaJump and result == ACTION_RESULT_BEGIN then
        HTC.ZmajaJumpTime = currentTime + 12

        HowToCloudrest.ZmajaJumpUI()
        HTC_ZmajaJump:SetHidden(false)

        EM:UnregisterForUpdate(HowToCloudrest.name .. "ZmajaJumpTimer")
        EM:RegisterForUpdate(HowToCloudrest.name .. "ZmajaJumpTimer", 1000, HowToCloudrest.ZmajaJumpUI)
    end

    -- Only track Crushing Darkness if enabled and the player is targeted
    -- if targetType == COMBAT_UNIT_TYPE_PLAYER then
    --     HTC_Debug("Crushing Darkness Cast!")
    --     HTC_Debug("CDark abilityId: " .. tostring(abilityId))
    --     HTC_Debug("CDark result: " .. tostring(result))
    -- end

    -- When Crushing darkness is cast there's 28 sec till next cast
    if sV.Enable.CrushingDarkness_Next and result == ACTION_RESULT_BEGIN then
        HTC.crushingDarknessNextTime = currentTime + 25

        -- If tracking when next crushing darkness is cast, show it.
        HTC_CrushingDarkness_Next_Label:SetText(HTC.String.ZMaja_CrushingDarkness_Next_Base .. HTC.String.ZMaja_CrushingDarkness_Next_Cast)
        HTC_CrushingDarkness_Next:SetHidden(false)

        EM:UnregisterForUpdate(HowToCloudrest.name .. "CrushingDarknessNextTimer")
        EM:RegisterForUpdate(HowToCloudrest.name .. "CrushingDarknessNextTimer", 1000, HowToCloudrest.CrushingDarknessNextUI)
    end

    if ((sV.Enable.CrushingDarkness_Kite
    and targetType == COMBAT_UNIT_TYPE_PLAYER)
    and result == ACTION_RESULT_EFFECT_GAINED) then
        HTC.crushingDarknessKiteTime = currentTime + 11

        HTC.kiting = true
        HTC_CrushingDarkness_Next:SetHidden(true)

        HTC_CrushingDarkness_Kite_Label:SetText(HTC.String.ZMaja_CrushingDarkness_Kite_Base .. HTC.String.ZMaja_CrushingDarkness_Kite_Cast)
        HTC_CrushingDarkness_Kite:SetHidden(false)

        EM:UnregisterForUpdate(HowToCloudrest.name .. "CrushingDarknessKiteTimer")
        EM:RegisterForUpdate(HowToCloudrest.name .. "CrushingDarknessKiteTimer", 1000, HowToCloudrest.CrushingDarknessKiteUI)
    end
end

function HowToCloudrest.CrushingDarknessKiteUI()
    if HTC.crushingDarknessKiteTime == nil then return end

    local currentTime = GetGameTimeMilliseconds() / 1000
    local timer = HTC.crushingDarknessKiteTime - currentTime

    if timer >= 5 then
        HTC_CrushingDarkness_Kite_Label:SetText(HTC.String.ZMaja_CrushingDarkness_Kite_Base .. HTC.Color.red(tostring(string.format("%.0f", timer))))
    elseif timer > 0 then
        HTC_CrushingDarkness_Kite_Label:SetText(HTC.String.ZMaja_CrushingDarkness_Kite_Base .. HTC.Color.yellow(tostring(string.format("%.0f", timer))))
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "CrushingDarknessKiteTimer")
        HTC.kiting = false
        HTC_CrushingDarkness_Kite_Label:SetText(HTC.String.ZMaja_CrushingDarkness_Kite_Base .. HTC.String.ZMaja_CrushingDarkness_Kite_Faded)
        zo_callLater(
            function ()
                HTC_CrushingDarkness_Kite:SetHidden(true)
                if sV.Enable.CrushingDarkness_Next then
                    HTC_CrushingDarkness_Next:SetHidden(false)
                end
            end,
            1000
        )
    end
end

function HowToCloudrest.CrushingDarknessNextUI()
    if HTC.crushingDarknessNextTime == nil then return end

    local currentTime = GetGameTimeMilliseconds() / 1000
    local timer = HTC.crushingDarknessNextTime - currentTime

    if timer >= 5 then
        HTC_CrushingDarkness_Next_Label:SetText(HTC.String.ZMaja_CrushingDarkness_Next_Base .. HTC.Color.green(tostring(string.format("%.0f", timer))))
    elseif timer > 0 then
        HTC_CrushingDarkness_Next_Label:SetText(HTC.String.ZMaja_CrushingDarkness_Next_Base .. HTC.Color.yellow(tostring(string.format("%.0f", timer))))
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "CrushingDarknessKiteTimer")
        HTC.kiting = false
        HTC_CrushingDarkness_Next_Label:SetText(HTC.String.ZMaja_CrushingDarkness_Next_Base .. HTC.String.ZMaja_CrushingDarkness_Next_Off_Cooldown)
        --zo_callLater(function () HTC_CrushingDarkness_Next:SetHidden(true) end, 1000)
    end
end

-- Z'Maja's Shadow Splash interrupt (Drop from ceiling)
function HowToCloudrest.ShadowSplashCast(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

	if not sV.Enable.ShadowSplash then return end

	if result == ACTION_RESULT_BEGIN then
        local currentTime = GetGameTimeMilliseconds() / 1000
        HTC.zmajaBashTime = currentTime
		PlaySound(SOUNDS.SKILL_LINE_ADDED)
        HowToCloudrest.ShadowSplashUI()

		EM:UnregisterForUpdate(HowToCloudrest.name .. "ShadowSplashTimer")
		EM:RegisterForUpdate(HowToCloudrest.name .. "ShadowSplashTimer", 1000, HowToCloudrest.ShadowSplashUI)

	elseif result == ACTION_RESULT_EFFECT_FADED then

        EM:UnregisterForUpdate(HowToCloudrest.name .. "ShadowSplashTimer")
        HTC_ShadowSplash_Label:SetText(HTC.String.ZMaja_Bash_Faded)
		zo_callLater(function() HTC_ShadowSplash:SetHidden(true) end, 1000)
	end
end

function HowToCloudrest.ShadowSplashUI()

    local currentTime = GetGameTimeMilliseconds() / 1000

    local zmajaBashText = ""
    if HTC.zmajaBashTime ~= nil then
        local timer = currentTime - HTC.zmajaBashTime
        if timer <= 1 then
            zmajaBashText = HTC.String.ZMaja_Bash_Cast_1
        elseif timer <= 2 then
            zmajaBashText = HTC.String.ZMaja_Bash_Cast_2
        elseif timer <= 3 then
            zmajaBashText = HTC.String.ZMaja_Bash_Cast_3
        elseif timer <= 4 then
            zmajaBashText = HTC.String.ZMaja_Bash_Cast_4
        elseif timer <= 5 then
            zmajaBashText = HTC.String.ZMaja_Bash_Cast_3
        elseif timer <= 6 then
            zmajaBashText = HTC.String.ZMaja_Bash_Cast_4
        elseif timer <= 7 then
            zmajaBashText = HTC.String.ZMaja_Bash_Cast_3
        elseif timer <= 8 then
            zmajaBashText = HTC.String.ZMaja_Bash_Cast_4
        elseif timer <= 9 then
            zmajaBashText = HTC.String.ZMaja_Bash_Cast_3
        end
    end

    HTC_ShadowSplash_Label:SetText(zmajaBashText)
    HTC_ShadowSplash_Label:SetHorizontalAlignment(CENTER)
    HTC_ShadowSplash:SetHidden(false)
end

-- Baneful Mark during Z'Maja execute
function HowToCloudrest.BanefulMarkOnExecute(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

    if result ~= ACTION_RESULT_BEGIN or not sV.Enable.BanefulMark then return end

    local currentTime = GetGameTimeMilliseconds() / 1000

    HTC.banefulMarkTime = currentTime + 22
    HTC_BanefulMark:SetHidden(false)
    HTC_BanefulMark_Label:SetText(HTC.String.ZMaja_BanefulMark_Base .. HTC.String.ZMaja_BanefulMark_Cast)

    EM:UnregisterForUpdate(HowToCloudrest.name .. "BanefulMarkTimer")
    zo_callLater(function () EM:RegisterForUpdate("BanefulMarkTimer", 1000, HowToCloudrest.BanefulMarkUI ) end, 2000)
    HowToCloudrest.BanefulMarkUI()
end

local function getBanefulMarkText(banefulMarkTime, currentTime)
    local banefulMarkText = "-"
    local timer = banefulMarkTime - currentTime
        if timer >= 5 then
            banefulMarkText = HTC.String.ZMaja_BanefulMark_Base .. HTC.Color.green(tostring(string.format("%.0f", timer)))
        elseif timer > 0 then
            banefulMarkText = HTC.String.ZMaja_BanefulMark_Base .. HTC.Color.yellow(tostring(string.format("%.0f", timer)))
        else
            banefulMarkText = HTC.String.ZMaja_BanefulMark_Base .. HTC.String.ZMaja_BanefulMark_Off_Cooldown
        end
    return banefulMarkText
end

-- Updates the timer for next Baneful Mark ( only on execute )
function HowToCloudrest.BanefulMarkUI()
    local currentTime = GetGameTimeMilliseconds() / 1000

    local banefulMarkText = "-"
    if HTC.banefulMarkTime ~= nil then
        banefulMarkText = getBanefulMarkText(HTC.banefulMarkTime, currentTime)
        HTC_BanefulMark_Label:SetText(banefulMarkText)
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "BanefulMarkTimer")
        HTC_BanefulMark:SetHidden(true)
    end
end

--  Malicious Spheres (orbs during Z'Maja)
function HowToCloudrest.MaliciousSphereSpawn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if result ~= ACTION_RESULT_BEGIN then return end

    local currentTime = GetGameTimeMilliseconds() / 1000

    HTC.maliciousSphereKillTime = currentTime + 22
    HTC.maliciousSphereNextTime = currentTime + 33

    HTC.orbsRemaining = 3
    HTC.maliciousStrikeCounter = 0
    HTC.maliciousSphereExpired = false

    if sV.Enable.MaliciousSphere_Announcement then
        HTC_MaliciousSphere_Announcement:SetHidden(false)
        HTC_MaliciousSphere_Announcement_Label:SetText(HTC.String.Zmaja_MaliciousSphere_OrbSpawning)
        zo_callLater(function() HTC_MaliciousSphere_Announcement:SetHidden(true) end, 3000)
    end

    --HTC_Debug("Orbs spawning!")
    --HTC_Debug("Orbs remaining: " .. tostring(HTC.orbsRemaining))

    if sV.Enable.MaliciousSphere_Timer then
        EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereNextTimer")

        HTC_MaliciousSphere_Timer:SetHidden(false)
        HTC_MaliciousSphere_Timer_Label:SetText(HTC.String.ZMaja_MaliciousSphere_Timer_Next .. HTC.String.ZMaja_MaliciousSphere_Timer_Cast)

        EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereKillTimer")
        zo_callLater(function () EM:RegisterForUpdate(HowToCloudrest.name .. "MaliciousSphereKillTimer", 1000, HowToCloudrest.MaliciousSphereTimerKillUI) end, 2000)
    end

    if sV.Enable.MaliciousSphere_Tracking or (sV.Enable.MaliciousSphere_Execute and HTC.zmajaExecute) then
        HTC_MaliciousSphere_Tracking_1:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Alive)
        HTC_MaliciousSphere_Tracking_2:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Alive)
        HTC_MaliciousSphere_Tracking_3:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Alive)
        HTC_MaliciousSphere_Tracking:SetHidden(false)
    end
end

function HowToCloudrest.MaliciousSphereTimerKillUI()
    if HTC.maliciousSphereKillTime == nil then return end
    -- EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereNextTimer")

    local currentTime = GetGameTimeMilliseconds() / 1000
    local timer = HTC.maliciousSphereKillTime - currentTime

    if timer >= 5 then
        HTC_MaliciousSphere_Timer_Label:SetText(HTC.String.ZMaja_MaliciousSphere_Timer_Kill .. HTC.Color.green(tostring(string.format("%.0f", timer))))
    elseif timer > 0 then
        HTC_MaliciousSphere_Timer_Label:SetText(HTC.String.ZMaja_MaliciousSphere_Timer_Kill .. HTC.Color.yellow(tostring(string.format("%.0f", timer))))
    else
        HTC.maliciousSphereExpired = true
        EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereKillTimer")

        HTC_MaliciousSphere_Timer_Label:SetText(HTC.String.ZMaja_MaliciousSphere_Timer_Kill .. HTC.String.ZMaja_MaliciousSphere_Timer_Failed)

        EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereNextTimer")
        zo_callLater(function () EM:RegisterForUpdate(HowToCloudrest.name .. "MaliciousSphereNextTimer", 1000, HowToCloudrest.MaliciousSphereTimerNextUI) end, 2000)
    end
end

function HowToCloudrest.MaliciousSphereTimerNextUI()
    if HTC.maliciousSphereNextTime == nil then return end
    -- EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereKillTimer")

    local currentTime = GetGameTimeMilliseconds() / 1000
    local timer = HTC.maliciousSphereNextTime - currentTime

    if timer >= 5 then
        HTC_MaliciousSphere_Timer_Label:SetText(HTC.String.ZMaja_MaliciousSphere_Timer_Next .. HTC.Color.green(tostring(string.format("%.0f", timer))))
    elseif timer > 0 then
        HTC_MaliciousSphere_Timer_Label:SetText(HTC.String.ZMaja_MaliciousSphere_Timer_Next .. HTC.Color.yellow(tostring(string.format("%.0f", timer))))
    else
        EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereNextTimer")
        HTC_MaliciousSphere_Timer_Label:SetText(HTC.String.ZMaja_MaliciousSphere_Timer_Next .. HTC.String.ZMaja_MaliciousSphere_Timer_Off_Cooldown)
        --zo_callLater(function () HTC_CrushingDarkness_Next:SetHidden(true) end, 1000)
    end
end

function HowToCloudrest.MaliciousStrike(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    --if not sV.Enable.MaliciousSphere or result ~= ACTION_RESULT_BEGIN then return end
    --if not sV.Enable.MaliciousSphere_Tracking or not (sV.Enable.MaliciousSphere_Execute and HTC.zmajaExecute) then return end
    --HTC_Debug("MaliciousStrike abilityId, result: " .. tostring(abilityId) .. " , " .. tostring(result))

    -- if result == ACTION_RESULT_EFFECT_GAINED and abilityId == 110242 then
    --     -- If malicious strike already hit 2 other players, then a third one means atleast 1 orb is dead.
    --     if HTC.maliciousStrikeCounter >= 2 then
    --         HTC.maliciousStrikeCounter = 0
    --         if HTC.orbsRemaining ~= 0 then
    --             --HTC.orbsRemaining = HTC.orbsRemaining - 1
    --             HTC_Debug("Orbs remaining: " .. tostring(HTC.orbsRemaining))

    --         else
    --             HTC_Debug("All orbs down!")

    --             if sV.Enable.MaliciousSphere_Timer then
    --                 EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereKillTimer")

    --                 HTC_MaliciousSphere_Timer:SetHidden(false)
    --                 HTC_MaliciousSphere_Timer_Label:SetText(HTC.String.ZMaja_MaliciousSphere_Timer_Kill .. HTC.String.ZMaja_MaliciousSphere_Timer_Success)

    --                 EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereNextTimer")
    --                 zo_callLater(function () EM:RegisterForUpdate("MaliciousSphereNextTimer", 1000, HowToCloudrest.MaliciousSphereTimerNextUI) end, 2000)
    --             end

    --             if sV.Enable.MaliciousSphere_Tracking or (sV.Enable.MaliciousSphere_Execute and HTC.zmajaExecute) then
    --                 HTC_MaliciousSphere_Tracking_1:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Dead)
    --                 HTC_MaliciousSphere_Tracking_2:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Dead)
    --                 HTC_MaliciousSphere_Tracking_3:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Dead)
    --                 HTC_MaliciousSphere_Tracking:SetHidden(false)
    --                 zo_callLater(function() HTC_MaliciousSphere_Tracking:SetHidden(true) end, 1500)
    --             end
    --         end
    --     else
    --         HTC.maliciousStrikeCounter = HTC.maliciousStrikeCounter + 1
    --     end
    -- end

    if result == ACTION_RESULT_EFFECT_GAINED and targetType == COMBAT_UNIT_TYPE_PLAYER then
        --player is targeted by malicious strike
    end
end

function HowToCloudrest.ShadowBeadTick(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if (result ~= ACTION_RESULT_EFFECT_GAINED) then return end
    HTC.maliciousSphereId[targetUnitId] = true
    --HTC_Debug("ShadowBeadTick! " .. " id: " .. tostring(targetUnitId))
end

function HowToCloudrest.Death(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    --HTC_Debug("Death event!" .. " / name " .. tostring(targetName) .. " / id: " .. tostring(targetUnitId) .. " / type: " .. tostring(targetType))
    if HTC.maliciousSphereId[targetUnitId] then
        HTC.maliciousSphereId[targetUnitId] = false
        HTC.orbsRemaining = HTC.orbsRemaining - 1
        --HTC_Debug("(Orb kill) Orbs remaining: " .. HTC.orbsRemaining)

        if sV.Enable.MaliciousSphere_Tracking or (sV.Enable.MaliciousSphere_Execute and HTC.zmajaExecute) then
            if HTC.orbsRemaining == 2 then
                HTC_MaliciousSphere_Tracking_1:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Dead)
                HTC_MaliciousSphere_Tracking:SetHidden(false)

            elseif HTC.orbsRemaining == 1 then
                HTC_MaliciousSphere_Tracking_2:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Dead)
                HTC_MaliciousSphere_Tracking:SetHidden(false)

            elseif HTC.orbsRemaining == 0 then
                --HTC_Debug("All orbs are down")
                HTC_MaliciousSphere_Tracking_3:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Dead)
                HTC_MaliciousSphere_Tracking:SetHidden(false)
                zo_callLater(function() HTC_MaliciousSphere_Tracking:SetHidden(true) end, 1500)
            end
        end

        if sV.Enable.MaliciousSphere_Timer and HTC.orbsRemaining == 0 then
            EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereKillTimer")

            HTC_MaliciousSphere_Timer:SetHidden(false)
            HTC_MaliciousSphere_Timer_Label:SetText(HTC.String.ZMaja_MaliciousSphere_Timer_Kill .. HTC.String.ZMaja_MaliciousSphere_Timer_Success)

            EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereNextTimer")
            zo_callLater(function () EM:RegisterForUpdate(HowToCloudrest.name .. "MaliciousSphereNextTimer", 1000, HowToCloudrest.MaliciousSphereTimerNextUI) end, 2000)
        end
    end
end

function HowToCloudrest.ShadowBeadSpawn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    --HTC_Debug(tostring(result).. " ShadowBeadSpawn! " .. " / name " .. tostring(targetName) .. " / id: " .. tostring(targetUnitId) .. " / type: " .. tostring(targetType))
    if result ~= ACTION_RESULT_EFFECT_GAINED then return end
    if HTC.maliciousSphereId[targetUnitId] then
        HTC.maliciousSphereId[targetUnitId] = false
        HTC.orbsRemaining = HTC.orbsRemaining - 1
        --HTC_Debug("(Orb collided) Orbs remaining: " .. HTC.orbsRemaining)

        if sV.Enable.MaliciousSphere_Tracking or (sV.Enable.MaliciousSphere_Execute and HTC.zmajaExecute) then
            if HTC.orbsRemaining == 2 then
                HTC_MaliciousSphere_Tracking_1:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Collided)
                HTC_MaliciousSphere_Tracking:SetHidden(false)

            elseif HTC.orbsRemaining == 1 then
                HTC_MaliciousSphere_Tracking_2:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Collided)
                HTC_MaliciousSphere_Tracking:SetHidden(false)

            elseif HTC.orbsRemaining == 0 then
                --HTC_Debug("All orbs are down")
                HTC_MaliciousSphere_Tracking_3:SetTexture(HTC.String.ZMaja_MaliciousSphere_Tracking_Collided)
                HTC_MaliciousSphere_Tracking:SetHidden(false)
                zo_callLater(function() HTC_MaliciousSphere_Tracking:SetHidden(true) end, 1500)
            end
        end

        if sV.Enable.MaliciousSphere_Timer and HTC.orbsRemaining == 0 and not HTC.maliciousSphereExpired then
            EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereKillTimer")

            HTC_MaliciousSphere_Timer:SetHidden(false)
            HTC_MaliciousSphere_Timer_Label:SetText(HTC.String.ZMaja_MaliciousSphere_Timer_Kill .. HTC.String.ZMaja_MaliciousSphere_Timer_Success)

            EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereNextTimer")
            zo_callLater(function () EM:RegisterForUpdate(HowToCloudrest.name .. "MaliciousSphereNextTimer", 1000, HowToCloudrest.MaliciousSphereTimerNextUI) end, 2000)
        end
    end
end


function HowToCloudrest.ShadowBeadCharge(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
   --HTC_Debug(tostring(result).. " ShadowBeadCharge! " .. " / name " .. tostring(targetName) .. " / id: " .. tostring(targetUnitId) .. " / type: " .. tostring(targetType))
end

--  Creepers
function HowToCloudrest.CreeperSpawn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if not sV.Enable.Creeper_Announcement or result ~= ACTION_RESULT_BEGIN then return end
    HTC_Creeper_Announcement_Label:SetText(HTC.String.Zmaja_CreeperSpawning)
    HTC_Creeper_Announcement:SetHidden(false)
    zo_callLater(function() HTC_Creeper_Announcement:SetHidden(true) end, 3000)
end
----------------------------------------------------------
--                      INIT                            --
----------------------------------------------------------
function HowToCloudrest.ResetAll()
    HTC_Debug("Resetting variables and updates/events")

    --unregister UI timer events

    -- General
    EM:UnregisterForUpdate(HowToCloudrest.name .. "HeavyAttackTimer")

    -- Siroria
    EM:UnregisterForUpdate(HowToCloudrest.name .. "RoaringFlareTimer")

    -- Relequen
    EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleHATimer")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "OverloadTimer")

    -- Galenwe
    EM:UnregisterForUpdate(HowToCloudrest.name .. "HoarfrostAoeTick")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "FrostTimer")

    EM:UnregisterForUpdate(HowToCloudrest.name .. "ChillingCometTimer")

    -- Portal
    EM:UnregisterForUpdate(HowToCloudrest.name .. "PortalTimer")

    -- Z'Maja
    EM:UnregisterForUpdate(HowToCloudrest.name .. "ZmajaJumpTimer")

    EM:UnregisterForUpdate(HowToCloudrest.name .. "CrushingDarknessKiteTimer")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "CrushingDarknessNextTimer")

    EM:UnregisterForUpdate(HowToCloudrest.name .. "ShadowSplashTimer")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "BanefulMarkTimer")

    EM:UnregisterForEvent(HowToCloudrest.name .. "MaliciousSphere_Death")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereKillTimer")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "MaliciousSphereNextTimer")

    -- Other
    EM:UnregisterForUpdate(HowToCloudrest.name .. "CombatEnded")

    HowToCloudrest.UnregisterForAllMiniFrameTimers()
    HowToCloudrest.UnregisterForAllMiniSpawns()
    HowToCloudrest.UnregisterForAllMiniDeaths()

    HTC = HTC_AUX:DeepCopy(HTC_Var_Reset_Values) --reset variables

    --hide everything
    HowToCloudrest.HideAllUIElements()
    zo_callLater(function () HowToCloudrest.HideAllUIElements() end, 4000)
end

function HowToCloudrest.HideAllUIElements()
    -- General
    HTC_Ha:SetHidden(true)
    HTC_Rooted:SetHidden(true)

    -- Miniframe
    HTC_MiniFrame:SetHidden(true)
    HTC_Announcement_MiniBash:SetHidden(true)

    -- Siroria
    HTC_Flare:SetHidden(true)

    -- Relequen
    HTC_ReleHA:SetHidden(true)
    HTC_OverloadTimer:SetHidden(true)
    HTC_Overload:SetHidden(true)

    -- Galenwe
    HTC_Hoarfrost:SetHidden(true)
    HTC_ChillingComet:SetHidden(true)

    -- Portal
    HTC_Portal:SetHidden(true)
    HTC_Portal_Announcement:SetHidden(true)

    -- Z'maja
    HTC_ZmajaJump:SetHidden(true)

    HTC_CrushingDarkness_Kite:SetHidden(true)
    HTC_CrushingDarkness_Next:SetHidden(true)

    HTC_ShadowSplash:SetHidden(true)
    HTC_BanefulMark:SetHidden(true)

    HTC_MaliciousSphere_Timer:SetHidden(true)
    HTC_MaliciousSphere_Announcement:SetHidden(true)
    HTC_MaliciousSphere_Tracking:SetHidden(true)

    HTC_Creeper_Announcement:SetHidden(true)
end

function HowToCloudrest.GetGroupTags(_, _, _, _, unitTag, _, _, _, _, _, _, _, _, unitName, unitId, _, _)
    if not HTC.groupMembers[unitId] then
        HTC_Debug("Adding " .. GetUnitDisplayName(unitTag) .. " to group members.")
		HTC.groupMembers[unitId] = {
			tag = unitTag,
			name = GetUnitDisplayName(unitTag) or unitName,
		}
	end
end

function HowToCloudrest.OnCombatEnd()
    if (not IsUnitInCombat("player")) then
        HowToCloudrest.ResetAll()
    end
end

function HowToCloudrest.CombatState()
    if HTC.inCombat then
        zo_callLater(function()
            HTC_Debug("Waiting for combat to end...")
            EM:UnregisterForUpdate(HowToCloudrest.name .. "CombatEnded")
            EM:RegisterForUpdate(HowToCloudrest.name .. "CombatEnded", 4000, HowToCloudrest.OnCombatEnd)
        end, 1000)
    end

    if IsUnitInCombat("player") and not HTC.inCombat then
        HowToCloudrest.RegisterForAllMinisSpawn()
    end

    HTC.inCombat = true
end

----------------------------------------------------------
--                  OnPlayerActivated                   --
----------------------------------------------------------
HowToCloudrest.showWelcomeMessage = true
function HowToCloudrest.OnPlayerActivated()

    if GetZoneId(GetUnitZoneIndex("player")) == 1051 then -- In Cloudrest
        HTC_Debug("Inside Cloudrest, registering for events!")

        if HowToCloudrest.showWelcomeMessage then
            d("You are using HowTo|cff00ffCloudrest|r with |cffffff" .. sV.defaultSettingsChoice .. "|r profile activated!")
            HowToCloudrest.showWelcomeMessage = false
        end

        for k, v in pairs(HowToCloudrest.AbilitiesToTrack) do --Register for abilities in the other lua file
            EM:RegisterForEvent(HowToCloudrest.name .. "Ability" .. k, EVENT_COMBAT_EVENT, v)
            EM:AddFilterForEvent(HowToCloudrest.name .. "Ability" .. k, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
        end

        --EM:RegisterForEvent(HowToCloudrest.name .. "MaliciousSphereDead", EVENT_UNIT_DEATH_STATE_CHANGED, HowToCloudrest.MaliciousSphereDead)

        EM:RegisterForEvent(HowToCloudrest.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, HowToCloudrest.CombatState)

        EM:RegisterForEvent(HowToCloudrest.name .. "Death", EVENT_COMBAT_EVENT, HowToCloudrest.Death)
        EM:AddFilterForEvent(HowToCloudrest.name .. "Death", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED)

        --EM:RegisterForEvent(HowToCloudrest.name .. "MiniSpawnDisp", EVENT_EFFECT_CHANGED, HowToCloudrest.MiniSpawn_Disposition)
        --EM:AddFilterForEvent(HowToCloudrest.name .. "MiniSpawnDisp", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 105541)

        --EM:RegisterForEvent(HowToCloudrest.name .. "MaliciousSphere_Death", EVENT_EFFECT_CHANGED, HowToCloudrest.MaliciousSphere_Death)
        --EM:AddFilterForEvent(HowToCloudrest.name .. "MaliciousSphere_Death", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 60312)

        EM:RegisterForEvent(HowToCloudrest.name .. "GroupTags", EVENT_EFFECT_CHANGED, HowToCloudrest.GetGroupTags)
        EM:AddFilterForEvent(HowToCloudrest.name .. "GroupTags", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
        --EM:RegisterForEvent(HowToCloudrest.name .. "WeathyDied", EVENT_UNIT_DEATH_STATE_CHANGED, HowToCloudrest.Weathy)

        -- Register for any combat tip

        --EM:RegisterForUpdate(HowToCloudrest.name .. "CombatEnded", 4000, HowToCloudrest.OnCombatEnd)


        HowToCloudrest.ResetAll()
    else
        -- When outside of Cloudrest, unregister from all of the combat events.
        HTC_Debug("Outside Cloudrest, HowToCloudrest is now disabled!")

        for k, v in pairs(HowToCloudrest.AbilitiesToTrack) do --Unregister for all abilities
            EM:UnregisterForEvent(HowToCloudrest.name .. "Ability" .. k, EVENT_COMBAT_EVENT)
        end

        EM:UnregisterForEvent(HowToCloudrest.name .. "MiniSpawnDisp", EVENT_EFFECT_CHANGED)
        EM:UnregisterForEvent(HowToCloudrest.name .. "OlorimeShackles", EVENT_EFFECT_CHANGED)

        EM:UnregisterForEvent(HowToCloudrest.name .. "Death", EVENT_COMBAT_EVENT)

        EM:UnregisterForEvent(HowToCloudrest.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE)
        EM:UnregisterForUpdate(HowToCloudrest.name .. "GroupTags", EVENT_EFFECT_CHANGED)
        --EM:UnregisterForEvent(HowToCloudrest.name .. "WeathyDied", EVENT_UNIT_DEATH_STATE_CHANGED)
        EM:UnregisterForEvent(HowToCloudrest.name .. "inCombat", EVENT_PLAYER_COMBAT_STATE )
        EM:UnregisterForUpdate(HowToCloudrest.name)
        EM:UnregisterForEvent(HowToCloudrest.name .. "CloudrestCombatEvent", EVENT_COMBAT_EVENT)
        EM:UnregisterForUpdate(HowToCloudrest.name .. "CombatEnded")
        HowToCloudrest.ResetAll()
    end
end

function HowToCloudrest:Initialize()
	--Saved Variables
    HowToCloudrest.savedVariables = ZO_SavedVars:NewAccountWide("HowToCloudrestVariables", 1, nil, HowToCloudrest.Default)
    sV = HowToCloudrest.savedVariables

	--Settings
    HowToCloudrest.CreateSettingsWindow()

	--UI
    HowToCloudrest.InitUI()

    --Events
    EM:RegisterForEvent(HowToCloudrest.name .. "Activated", EVENT_PLAYER_ACTIVATED, HowToCloudrest.OnPlayerActivated)

    EM:UnregisterForEvent(HowToCloudrest.name, EVENT_ADD_ON_LOADED)
end

local key = 1
local colors = {
    [1]	= {1,0,0},
    [2]	= {0,1,0},
    [3]	= {0,0,1},
    [4]	= {1,0,1},
    [5]	= {0,1,1},
    [6]	= {1,1,0},
}
function HowToCloudrest.Rainbow()
    HowToCloudrest.SetOverloadOverlay(colors[key][1], colors[key][2], colors[key][3])

    key = key + 1
    if key == 7 then key = 1 end
end

function HowToCloudrest.OnAddOnLoaded(event, addonName)
  if addonName ~= HowToCloudrest.name then return end
  HowToCloudrest:Initialize()
end

EM:RegisterForEvent(HowToCloudrest.name, EVENT_ADD_ON_LOADED, HowToCloudrest.OnAddOnLoaded)
----------------------------------------------------------
--                      REGISTER                        --
----------------------------------------------------------
function HowToCloudrest.RegisterForMiniSpawn(miniAbilities)
    for k, v in pairs(miniAbilities) do
        EM:RegisterForEvent(HowToCloudrest.name .. "MiniSpawn" .. k, EVENT_COMBAT_EVENT, HowToCloudrest.MiniSpawn_Ability)
        EM:AddFilterForEvent(HowToCloudrest.name .. "MiniSpawn" .. k, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
    end
end

function HowToCloudrest.RegisterForAllMinisSpawn()
    --HTC_Debug("Registering for mini spawns!")
    HowToCloudrest.RegisterForMiniSpawn(HTC.siroAbilities)
    HowToCloudrest.RegisterForMiniSpawn(HTC.releAbilities)
    HowToCloudrest.RegisterForMiniSpawn(HTC.galeAbilities)
end

function HowToCloudrest.RegisterForAllMiniDeaths()
    for i = 1, MAX_BOSSES do
        local unitTag = "boss" .. tostring(i)
        if DoesUnitExist(unitTag) then
            local unitName = GetUnitName(unitTag)
            if unitName:find("Siroria") or unitName:find("Relequen") or unitName:find("Galenwe") then
                HTC_Debug("Tracking death of " .. unitName)
                EM:UnregisterForEvent(HowToCloudrest.name .. "BossDeath" .. i)
                EM:RegisterForEvent(HowToCloudrest.name .. "BossDeath" .. i, EVENT_UNIT_DEATH_STATE_CHANGED, HowToCloudrest.OnBossDeath)
                EM:AddFilterForEvent(HowToCloudrest.name .. "BossDeath" .. i, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "boss")
            end
            if unitName:find("Silaeda") or unitName:find("Belanaril") or unitName:find("Falarielle") then
                HTC.isSideBoss = true
            end
        end
    end
    HTC_Debug("Fight is sideboss = " .. tostring(HTC.isSideBoss))
end
----------------------------------------------------------
--                     UNREGISTER                       --
----------------------------------------------------------
function HowToCloudrest.UnregisterForMiniSpawn(miniAbilities)
    for k, v in pairs(miniAbilities) do
        EM:UnregisterForEvent(HowToCloudrest.name .. "MiniSpawn" .. k, EVENT_COMBAT_EVENT)
    end
end

function HowToCloudrest.UnregisterForAllMiniSpawns()
    -- HTC_Debug("Unregistering for mini spawns!")
    HowToCloudrest.UnregisterForMiniSpawn(HTC.siroAbilities)
    HowToCloudrest.UnregisterForMiniSpawn(HTC.releAbilities)
    HowToCloudrest.UnregisterForMiniSpawn(HTC.galeAbilities)
end

function HowToCloudrest.UnregisterForAllMiniDeaths()
    for i = 1, MAX_BOSSES do
        local unitTag = "boss" .. tostring(i)
        EM:UnregisterForEvent(HowToCloudrest.name .. "BossDeath" .. unitTag)
    end
end

function HowToCloudrest.UnregisterForSiroriaFrameTimers()
    EM:UnregisterForUpdate(HowToCloudrest.name .. "SiroJumpTimer")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "SiroBashTimer")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "SiroSkillTimer")
end

function HowToCloudrest.UnregisterForRelequenFrameTimers()
    EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleJumpTimer")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleBashTimer")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleSkillTimer")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "ReleBashChannelTimer")
end

function HowToCloudrest.UnregisterForGalenweFrameTimers()
    EM:UnregisterForUpdate(HowToCloudrest.name .. "GaleJumpTimer")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "GaleBashTimer")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "GaleSkillTimer")
    EM:UnregisterForUpdate(HowToCloudrest.name .. "GaleBashChannelTimer")
end

function HowToCloudrest.UnregisterForAllMiniFrameTimers()
    HowToCloudrest.UnregisterForSiroriaFrameTimers()
    HowToCloudrest.UnregisterForRelequenFrameTimers()
    HowToCloudrest.UnregisterForGalenweFrameTimers()
end

SLASH_COMMANDS["/htc_debug"] = function (argsv)
    sV.debug = not sV.debug
    if sV.debug then
        d("[HTC_Debug] Debugging turned on!")
    else
        d("[HTC_Debug] Debugging turned off!")
    end
end
