-----------------
---- Globals ----
-----------------
HowToSunspire                 = HowToSunspire or {}
local HowToSunspire           = HowToSunspire

HowToSunspire.name            = "HowToSunspire"
HowToSunspire.version         = "1.3.10"
HowToSunspire.slash           = "/hts"
HowToSunspire.prefix          = "|cffffffHT|cffbf00S|r: "
HowToSunspire.groupMembers    = {}
HowToSunspire.testMembers     = {
  [1]   = {
    tag   = "group1",
    name  = "@Test Name  1",
  },
  [2]   = {
    tag   = "group2",
    name  = "@Test Name  2",
  },
  [3]   = {
    tag   = "group3",
    name  = "@Test Name  3",
  },
  [4]   = {
    tag   = "group4",
    name  = "@Test Name  4",
  },
  [5]   = {
    tag   = "group5",
    name  = "@Test Name  5",
  },
  [6]   = {
    tag   = "group6",
    name  = "@Test Name  6",
  },
  [7]   = {
    tag   = "group7",
    name  = "@Test Name  7",
  },
  [8]   = {
    tag   = "group8",
    name  = "@Test Name  8",
  },
  [9]   = {
    tag   = "group9",
    name  = "@Test Name  9",
  },
  [10]  = {
    tag   = "group10",
    name  = "@Test Name 10",
  },
  [11]  = {
    tag   = "group11",
    name  = "@Test Name 11",
  },
  [12]  = {
    tag   = "group12",
    name  = "@Test Name 12",
  }
}

local playerTestIndex = 0
local function GetTestName(index)
  if index == playerTestIndex then return " |cff9900==|r YOU |cff9900==|r "
  else
    if HowToSunspire.testMembers[index] then
      return "|cff9900" ..  HowToSunspire.testMembers[index].name .. "|r"
    end
  end
end

local sV
local EM                      = EVENT_MANAGER
local WROTHGAR_MAP_INDEX      = 27
local WROTHGAR_MAP_STEP_SIZE  = 1.428571431461e-005
---------------------------
---- Variables Default ----
---------------------------
HowToSunspire.Default = {
  OffsetX = {
    HA            =    0,
    Block         =    0,
    Comet         =    0,
    Shield        =    0,
    Leap          =    0,

    Breath        =    0,
    Spit          =    0,
    Geyser        =    0,
    HP            =  350,
    Landing       =  350,

    GlacialFist   =    0,
    IceTomb       =    0,
    LaserLokke    =    0,

    Atro          =    0,
    Cata          =    0,
    NextFlare     =    0,
    -- Flare         =    0,

    PowerfulSlam  =    0,
    Stonefist     =    0,
    -- HailOfStone   =    0,
    Thrash        =    0,
    SweepBreath   =    0,
    SoulTear      =    0,
    Storm         =    0,
    NextMeteor    =    0,
    Portal        =    0,
    Negate        =    0,
    Wipe          =    0,
    MeteorNames   =    0
  },
  OffsetY = {
    HA            =    0,
    Block         =   50,
    Comet         = -150,
    Shield        = - 50,
    Leap          = - 50,

    Breath        = -100,
    Spit          = - 50,
    Geyser        =   50,
    HP            =   50,
    Landing       =   80,

    GlacialFist   = -200,
    IceTomb       = - 50,
    LaserLokke    =   50,

    Atro          = - 50,
    Cata          = - 50,
    NextFlare     = -100,
    -- Flare         =   50,

    PowerfulSlam 	=    0,
    Stonefist     = -150,
    -- HailOfStone   = -200,
    Thrash        =  100,
    SweepBreath   = -100,
    SoulTear      =  100,
    Storm         = -100,
    NextMeteor    =  150,
    Portal        =   50,
    Negate        = - 50,
    Wipe          =  150,
    MeteorNames   = -500
  },
  Enable = {
    HA 						= true,
    Block 				= true,
    Comet 				= true,
    Shield 				= true,
    Leap 					= true,

    Breath				= true,
    Spit 					= true,
    Geyser 				= true,
    hpLokke 			= true,
    hpYolna 			= true,
    hpNahvii			= true,
    landingLokke	= true,
    landingYolna	= true,
    landingNahvii	= true,

    GlacialFist		= true,
    IceTomb 			= true,
    LaserLokke 		= true,

    Atro 					= true,
    Cata 					= true,
    NextFlare 		= true,
    -- Flare					= true,

    PowerfulSlam 	= true,
    Stonefist			= true,
    -- HailOfStone 	= true,
    Thrash 				= true,
    SweepBreath 	= true,
    SoulTear 			= true,
    Storm 				= true,
    NextMeteor 		= true,
    Portal 				= true,
    Negate 				= true,
    Interrupt 		= true,
    Pins 					= true,
    Wipe 					= true,
    MeteorNames   = true,

    Sending 			= true,
    Sound 				= true,
  },

  hpShowPercent     =   5,
  timeBeforeLanding =   7,
  AlertSize         =  40,
  TimerSize         =  40,
  wipeCallLater     =  90,
  MeteorSelfOnly    = true,

  debug             = false
}

local fightStart = 0
local bossFight  = false
local function dbg( ... )
  if sV.debug then
    local message = zo_strformat( ... )
    if bossFight then
      local t = (GetGameTimeMilliseconds() / 1000) - fightStart
      fT = ZO_FormatTime(t, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_MILLISECONDS)
      d( HowToSunspire.prefix .. "[" .. fT .. "] " .. message)
    else
      d( HowToSunspire.prefix .. message )
    end
  end
end

local function setupTestGroup()
  local group = {}
  for k, v in pairs(HowToSunspire.testMembers) do
    group[k] = v
  end
  return group
end

local forcePlayerIndex = false
local playerRow = 1
local isTest = false
function HowToSunspire.SlashCommand( string )
  -- make all letters lower case for ease
  local cmd = string.lower( string )

  -- toggle debugging
  if cmd == "dbg" then
    sV.debug = not sV.debug
    local state = sV.debug and "On" or "Off"
    d( HowToSunspire.prefix .. "Debugging " .. state )

  elseif string.sub(cmd, 1, 6) == "meteor" then
    -- test meteor targets UI

    if string.sub(cmd, 8, string.len(cmd)) == "fp" then
      -- choose player number
      forcePlayerIndex = not forcePlayerIndex
      dbg("Testing with player always: |cffffff<<1>>|r.", forcePlayerIndex and "On" or "Off")

    elseif (string.sub(cmd, 8, 9) == "pr" and string.len(cmd) == 11) then
      -- choose player row
      local R = tonumber(string.sub(cmd, 11, 11))
      if R > 0 and R < 4 then
        playerRow = R
        dbg("Testing with player on row |cffffff<<1>>|r.", playerRow)
      end

    else -- run test scenario for the UI with or without added variables
      HowToSunspire.HideMeteorUnits(true)

      local n = string.sub(cmd, 7, string.len(cmd))

      -- the number assigned as players
      playerTestIndex = tonumber(n)
      dbg("Testing with player as unit |cffffff<<1>>|r.", playerTestIndex)

      -- tell function that this is a test to avoid running functions for getting actual player info
      isTest = true
      -- use only fake group members
      HowToSunspire.groupMembers = setupTestGroup()

      -- build table to use for keeping track of which numbers have been used.
      local t = {}

      for i = 1, 12 do t[i] = false end

      for i = 1, 3 do
        local r
        -- check how to run the function
        if (forcePlayerIndex and playerTestIndex > 0 and playerTestIndex < 13) then
          if i == playerRow
          then r = playerTestIndex
          else r = math.random(1, 12) end
        else r = math.random(1, 12) end

        dbg("Random unit |cffffff[<<1>>]|r = |cffffff<<2>>|r", i, r)
        -- only run each number once in case of duplicates
        if t[r] == false then
          t[r] = true
          HowToSunspire.Comet(_, 2240, _, _, _, _, _, _, _, _, 4000, _, _, _, _, r, 117251)
        end
      end
    end
  end
end
----------------------
---- ENTIRE TRIAL ----
----------------------
local listHA = {}
function HowToSunspire.HeavyAttack(_, result, _, abilityName, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if targetType ~= COMBAT_UNIT_TYPE_PLAYER or hitValue < 100 or sV.Enable.HA ~= true then return end

  if result == ACTION_RESULT_BEGIN then
    table.insert(listHA, GetGameTimeMilliseconds() + hitValue)

    Hts_Ha:SetHidden(false)
    if sV.Enable.Sound then
      PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
    end

    EM:UnregisterForUpdate(HowToSunspire.name .. "HeavyAttackTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "HeavyAttackTimer", 100, HowToSunspire.HeavyAttackUI)
  end
end

function HowToSunspire.HeavyAttackUI()
  local text = ""
  local currentTime = GetGameTimeMilliseconds()

  for key, value in ipairs(listHA) do
    local timer = value - currentTime
    if timer >= 0 then
      if text == "" then
        text = text .. tostring(string.format("%.1f", timer / 1000))
      else
        text = text .. "|cff1493 / |r" .. tostring(string.format("%.1f", timer / 1000))
      end
    else
      table.remove(listHA, key)
    end
  end

  if text ~= "" then
    Hts_Ha_Label:SetText("|cff1493HA|r: " .. text)
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "HeavyAttackTimer")
    Hts_Ha:SetHidden(true)
  end
end

function HowToSunspire.Block(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result == ACTION_RESULT_BEGIN and sV.Enable.Block == true then
    if hitValue > 400 then
      zo_callLater(function ()
        Hts_Block:SetHidden(false)
        if sV.Enable.Sound then
          PlaySound(SOUNDS.DUEL_START)
        end

        EM:UnregisterForUpdate(HowToSunspire.name .. "HideBlock")
        EM:RegisterForUpdate(HowToSunspire.name .. "HideBlock", 2500, HowToSunspire.HideBlock)
      end, hitValue - 400)
    else
      zo_callLater(function ()
        Hts_Block:SetHidden(false)
        if sV.Enable.Sound then
          PlaySound(SOUNDS.DUEL_START)
        end

        EM:UnregisterForUpdate(HowToSunspire.name .. "HideBlock")
        EM:RegisterForUpdate(HowToSunspire.name .. "HideBlock", 2500, HowToSunspire.HideBlock)
      end, hitValue)
    end
  end
end

function HowToSunspire.HideBlock()
  EM:UnregisterForUpdate(HowToSunspire.name .. "HideBlock")
  Hts_Block:SetHidden(true)
end

function HowToSunspire.Leap(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result == ACTION_RESULT_BEGIN and sV.Enable.Leap == true then
    if hitValue > 400 then
      zo_callLater(function ()
        Hts_Leap:SetHidden(false)

        EM:UnregisterForUpdate(HowToSunspire.name .. "HideLeap")
        EM:RegisterForUpdate(HowToSunspire.name .. "HideLeap", 2500, HowToSunspire.HideLeap)
      end, hitValue - 400)
    else
      zo_callLater(function ()
        Hts_Leap:SetHidden(false)

        EM:UnregisterForUpdate(HowToSunspire.name .. "HideLeap")
        EM:RegisterForUpdate(HowToSunspire.name .. "HideLeap", 2500, HowToSunspire.HideLeap)
      end, hitValue)
    end
  end
end

function HowToSunspire.HideLeap()
  EM:UnregisterForUpdate(HowToSunspire.name .. "HideLeap")
  Hts_Leap:SetHidden(true)
end

local cometTime
local isComet = true
local meteorUnits = {}
local sortedMeteorUnits = {
  [1] = { tag = "", index = 0, isPlayer = false },
  [2] = { tag = "", index = 0, isPlayer = false },
  [3] = { tag = "", index = 0, isPlayer = false }
}
local meteorDisplayTime = 0
local meteorBegin = 0
function HowToSunspire.SetMeteorDirections()
  if (meteorBegin + 100) - GetGameTimeMilliseconds() > 0 then return end

  EM:UnregisterForUpdate(HowToSunspire.name .. "MeteorUnits")

  -- local g         = HowToSunspire.testMembers
  local g           = HowToSunspire.groupMembers
  local m           = meteorUnits
  local s           = sortedMeteorUnits
  local c           = Hts_MeteorNames
  local tags        = {}
  local isPlayer    = false
  local playerIndex = 0

  local function assignUnit(assignment, unitTag, index)
    local unit  = nil
    local a     = s[assignment]
    local p     = index == playerIndex and true or false
    if a.index == 0 then
      a.tag       = unitTag
      a.index     = index
      a.isPlayer  = p
    else
      if a.index < index then
        unit = { tag = unitTag, index = index, isPlayer = p }
      else
        unit        = { tag = a.tag, index = a.index, isPlayer = a.isPlayer }
        a.tag       = unitTag
        a.index     = index
        a.isPlayer  = p
      end
    end
    return unit
  end

  local function indexMeteorUnits(unitTag, index)
    local u1 = assignUnit(1, unitTag, index)
    if u1 ~= nil then
      local u2 = assignUnit(2, u1.tag, u1.index)
      if u2 ~= nil then
        assignUnit(3, u2.tag, u2.index)
      end
    end
  end

  for id, tag in pairs(m) do

    local index = tonumber(string.sub(tag, 6, string.len(tag)))

    if (isTest) then
      if index == playerTestIndex then
        isPlayer    = true
        playerIndex = index
        dbg("Test with |cffffff<<1>>|r registered as player", index)
      end
    else
      dbg("not a test")
      if AreUnitsEqual("player", tag) then
        isPlayer    = true
        playerIndex = index
        dbg("player id / tag: |cffffff<<1>>|r / |cffffff<<2>>|r.", id, tag)
      end
    end

    dbg("[<<1>>] = <<2>>", index, tag)

    indexMeteorUnits(tag, index)
  end

  if sV.MeteorSelfOnly then
    if not isPlayer then
      HowToSunspire.HideMeteorUnits(true)
      dbg("Not Player (<<1>> / <<2>>)", tostring(isPlayer), playerIndex)
      return
    end
  end

  for i = 1, 3 do
    local label = c.labels[i]

    local a1, a2
    if      i == 1 then a1 = 1; a2 = 2
    elseif  i == 2 then a1 = 3; a2 = 4
    elseif  i == 3 then a1 = 5; a2 = 6 end

    if s[i].index > 0 then
      local name
      if isTest then
        name = GetTestName(s[i].index)
      else
        if s[i].isPlayer
        then name = " |cff9900==|r YOU |cff9900==|r "
        else name = "|cff9900" .. GetUnitDisplayName(s[i].tag) .. "|r" end
      end
      label:SetText(name)
      label:SetHidden(false)
      c.arrows[a1]:SetHidden(false)
      c.arrows[a2]:SetHidden(false)

      if s[i].isPlayer then
        label:SetFont("EsoUI/Common/Fonts/univers67.otf" .. "|" .. zo_round(sV.AlertSize * 1.5) .. "|" .. "thick-outline")
      end

      dbg("displaying for (<<2>> / <<1>>)", tostring(s[i].isPlayer), s[i].tag)

      HowToSunspire.UpdateArrowSizes()
    else
      label:SetHidden(true)
      c.arrows[a1]:SetHidden(true)
      c.arrows[a2]:SetHidden(true)
    end
  end

  m = {}

  s = {
    [1] = { tag = "", index = 0 },
    [2] = { tag = "", index = 0 },
    [3] = { tag = "", index = 0 }
  }

  -- isTest = false
  -- playerTestIndex = 0
  meteorDisplayTime = GetGameTimeMilliseconds() + 4000

  c:SetHidden(false)

  EM:UnregisterForUpdate(HowToSunspire.name .. "HideMeteorNames")
  EM:RegisterForUpdate(HowToSunspire.name .. "HideMeteorNames", 500, function() HowToSunspire.HideMeteorUnits(false) end)

  -- zo_callLater(function()
  --   HowToSunspire.HideMeteorUnits()
  -- end, 4000)
end

function HowToSunspire.HideMeteorUnits(disable)
  if not disable then
    local t = meteorDisplayTime - GetGameTimeMilliseconds()

    if t > 0 then return end
  end

  EM:UnregisterForUpdate(HowToSunspire.name .. "HideMeteorNames")

  dbg("Hiding Meteor Names")

  meteorDisplayTime = 0
  meteorUnits       = {}
  isTest            = false
  sortedMeteorUnits = {
    [1] = { tag = "", index = 0, isPlayer = false },
    [2] = { tag = "", index = 0, isPlayer = false },
    [3] = { tag = "", index = 0, isPlayer = false }
  }
  Hts_MeteorNames:SetHidden(true)
  HowToSunspire.SetMeteorNameSize()
end

--[[
/script HowToSunspire.Comet(_, 2240, _, _, _, _, _, _, _, _, 4000, _, _, _, _, 1, 117251)
/script HowToSunspire.Comet(_, 2240, _, _, _, _, _, _, _, _, 4000, _, _, _, _, 2, 117251)
/script HowToSunspire.Comet(_, 2240, _, _, _, _, _, _, _, _, 4000, _, _, _, _, 3, 123067)

/script HowToSunspire.Comet(_, 2240, _, _, _, _, _, _, _, _, 4000, _, _, _, _, 36761, 117251) HowToSunspire.Comet(_, 2240, _, _, _, _, _, _, _, _, 4000, _, _, _, _, 35061, 117251) HowToSunspire.Comet(_, 2240, _, _, _, _, _, _, _, _, 4000, _, _, _, _, 35486, 123067)

36761 =
.  (string): tag = group9
.  (boolean): ice = false
.  (string): name = @nogetrandom
35061 =
.  (string): tag = group5
.  (boolean): ice = false
.  (string): name = @Pride.eso
35486 =
.  (string): tag = group8
.  (boolean): ice = false
.  (string): name = @monkieponkie
36591 =
.  (string): tag = group1
.  (boolean): ice = false
.  (string): name = @Nilasnms

]]

function HowToSunspire.Comet(_, result, _, _, _, _, _, _, targetName, targetType, hitValue, _, _, _, _, targetUnitId, abilityId)
  if abilityId == 117251 or abilityId == 123067 then
    isComet = false
    HowToSunspire.NextMeteor(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)

    if (result ~= ACTION_RESULT_EFFECT_FADED) then
      if not targetUnitId then return end
      if targetUnitId == 0 then return end
      if not HowToSunspire.groupMembers[targetUnitId] then return end

      if not isTest then
        if GetGroupMemberSelectedRole(HowToSunspire.groupMembers[targetUnitId].tag) ~= 1 then return end
      end

      if not meteorUnits[targetUnitId] then
        if meteorBegin + 2000 > GetGameTimeMilliseconds() then
          meteorBegin = GetGameTimeMilliseconds()
        end

        meteorUnits[targetUnitId] = HowToSunspire.groupMembers[targetUnitId].tag

        dbg("unit |cffffff<<1>>|r added to meteor", targetUnitId)
        EM:UnregisterForUpdate(HowToSunspire.name .. "MeteorUnits")
        EM:RegisterForUpdate(HowToSunspire.name .. "MeteorUnits", 50, HowToSunspire.SetMeteorDirections)
      end
    else
      if meteorUnits[targetUnitId] then
        meteorUnits[targetUnitId] = nil
      end
    end

  else
    isComet = true
  end

  if sV.Enable.Comet ~= true or hitValue < 100 or targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end
  if (abilityId == 120359 and result ~= ACTION_RESULT_BEGIN) or
  (abilityId ~= 120359 and result ~= ACTION_RESULT_EFFECT_GAINED_DURATION) then return end

  cometTime = GetGameTimeMilliseconds() + hitValue

  if abilityId == 120359 then cometTime = cometTime + 1000 end

  HowToSunspire.CometUI()
  Hts_Comet:SetHidden(false)
  if sV.Enable.Sound then PlaySound(SOUNDS.DUEL_START) end

  EM:UnregisterForUpdate(HowToSunspire.name .. "CometTimer")
  EM:RegisterForUpdate(HowToSunspire.name .. "CometTimer", 100, HowToSunspire.CometUI)
end

function HowToSunspire.CometUI()
  local currentTime = GetGameTimeMilliseconds()
  local timer = cometTime - currentTime

  if timer >= 0 then
    if isComet then
      Hts_Comet_Label:SetText("|c87ceebComet: |r" .. tostring(string.format("%.1f", timer / 1000)))
    else
      Hts_Comet_Label:SetText("|cf51414Meteor: |r" .. tostring(string.format("%.1f", timer / 1000)))
    end
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "CometTimer")
    Hts_Comet:SetHidden(true)
  end
end

local shieldChargeTime
function HowToSunspire.ShieldCharge(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and sV.Enable.Shield == true then
    local currentTime = GetGameTimeMilliseconds()
    shieldChargeTime = currentTime + hitValue

    HowToSunspire.ShieldChargeTimerUI()
    Hts_Shield:SetHidden(false)

    EM:UnregisterForUpdate(HowToSunspire.name .. "ShieldChargeTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "ShieldChargeTimer", 100, HowToSunspire.ShieldChargeTimerUI)
  end
end

function HowToSunspire.ShieldChargeTimerUI()
  local currentTime = GetGameTimeMilliseconds()
  local timer = shieldChargeTime - currentTime

  if timer >= 0 then
    Hts_Shield_Label:SetText("|c7fffd4Shield Charge: |r" .. tostring(string.format("%.1f", timer / 1000)))
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "ShieldChargeTimer")
    Hts_Shield:SetHidden(true)
  end
end

local breathTime
function HowToSunspire.Breath(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and sV.Enable.Breath == true then
    local currentTime = GetGameTimeMilliseconds()
    breathTime = currentTime + hitValue

    HowToSunspire.BreathTimerUI()
    Hts_Breath:SetHidden(false)

    EM:UnregisterForUpdate(HowToSunspire.name .. "BreathTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "BreathTimer", 100, HowToSunspire.BreathTimerUI)
  end
end

function HowToSunspire.BreathTimerUI()
  local currentTime = GetGameTimeMilliseconds()
  local timer = breathTime - currentTime

  if timer >= 0 then
    Hts_Breath_Label:SetText("|cff6633Breath|r: " .. tostring(string.format("%.1f", timer / 1000)))
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "BreathTimer")
    Hts_Breath:SetHidden(true)
  end
end

local isFlying      = false
local flight        = 0
local flying        = 0
local grounded      = 0
local landingTime   = 0
local bossName      = ""
local takeOff       = 0
local estimate      = 0
local logTime       = 0
function HowToSunspire.CheckLandingTimer()

  if IsUnitAttackable("boss1") then
    EM:UnregisterForUpdate(HowToSunspire.name .. "TimeFlying")
    local t          = GetGameTimeMilliseconds() / 1000
    local timeFlying = t - takeOff
    local e          = estimate - t
    local diff

    if e >= 0 then
      -- to indicate that the time was less than expected
      e = e - (e * 2)
      diff = " (" .. e .. ")"
    else
      -- to indicate that the time was longer than expected
      e = e * -2
      diff = " (+" .. e .. ")"
    end

    dbg("[" .. bossName .. "]: #" .. flight .. " = " .. string.format("%.3fs", timeFlying) .. diff)
    if string.find(bossName, "Yolna") then
      dbg("Logtime was: " .. logTime)
    end
  end
end

function HowToSunspire.BossHealth()
  local current, max, effective = GetUnitPower("boss1", POWERTYPE_HEALTH)
  local bossHP = ( current / max ) * 100
  -- bossName = GetUnitName("boss1")

  if bossHP > 21 then
    if (bossName == "Lokkestiiz" and sV.Enable.hpLokke == true) then
      EM:RegisterForUpdate(HowToSunspire.name .. "BossHealth", 1000, HowToSunspire.LokkeHealth)
    elseif (bossName == "Yolnahkriin" and sV.Enable.hpYolna == true) then
      EM:RegisterForUpdate(HowToSunspire.name .. "BossHealth", 1000, HowToSunspire.YolnaHealth)
    elseif (bossName == "Nahviintaas" and sV.Enable.hpNahvii == true) then
      EM:RegisterForUpdate(HowToSunspire.name .. "BossHealth", 1000, HowToSunspire.NahviiHealth)
    end
    -- if sV.debug then
      -- EM:RegisterForUpdate(HowToSunspire.name .. "TimeFlying", 50, HowToSunspire.CheckLandingTimer)
    -- end
  else
    return
  end
end

function HowToSunspire.LokkeHealth()

  local current, max, effective = GetUnitPower("boss1", POWERTYPE_HEALTH)
  local l = ( current / max ) * 100

  if l >= 81 then                  flying = 81
  elseif (l < 81 and l >= 51) then flying = 51
  elseif (l < 50 and l >= 21) then flying = 21
  else
    Hts_HP:SetHidden(true)
    EM:UnregisterForUpdate(HowToSunspire.name .. "BossHealth")
    return
  end

  grounded = l - flying

  if grounded <= sV.hpShowPercent then
    Hts_HP:SetHidden(false)

    HowToSunspire.LokkeHealthUI()
    EM:UnregisterForUpdate(HowToSunspire.name .. "LokkestiizUI")
    EM:RegisterForUpdate(HowToSunspire.name .. "LokkestiizUI", 100, HowToSunspire.LokkeHealthUI)

    EM:UnregisterForUpdate(HowToSunspire.name .. "BossHealth")
  end
end

function HowToSunspire.LokkeHealthUI()
  local current, max, effective = GetUnitPower("boss1", POWERTYPE_HEALTH)
  local lokkeHP = ( current / max ) * 100
  grounded = lokkeHP - flying

  if grounded > 0 then
    Hts_HP_Label:SetText("|cffa500Can Fly In|r: " .. string.format("%.1f", grounded) .. "%")

  elseif grounded <= 0 then Hts_HP_Label:SetText("|cff0000Can Fly Now|r") end

  if grounded <= 0 then
    zo_callLater(function()
      Hts_HP:SetHidden(true)
      EM:UnregisterForUpdate(HowToSunspire.name .. "LokkestiizUI")
    end, 2500)
  end
end

function HowToSunspire.YolnaHealth()

  local current, max, effective = GetUnitPower("boss1", POWERTYPE_HEALTH)
  local y = ( current / max ) * 100

  if y >= 76 then                  flying = 76
  elseif (y < 76 and y >= 51) then flying = 51
  elseif (y < 51 and y >= 26) then flying = 26
  else
    Hts_HP:SetHidden(true)
    EM:UnregisterForUpdate(HowToSunspire.name .. "BossHealth")
    return
  end

  grounded = y - flying

  if grounded <= sV.hpShowPercent then
    Hts_HP:SetHidden(false)

    HowToSunspire.YolnaHealthUI()
    EM:UnregisterForUpdate(HowToSunspire.name .. "YolnahkriinUI")
    EM:RegisterForUpdate(HowToSunspire.name .. "YolnahkriinUI", 100, HowToSunspire.YolnaHealthUI)

    EM:UnregisterForUpdate(HowToSunspire.name .. "BossHealth")
  end
end

function HowToSunspire.YolnaHealthUI()
  local current, max, effective = GetUnitPower("boss1", POWERTYPE_HEALTH)
  local yolnaHP = ( current / max ) * 100
  grounded = yolnaHP - flying

  if grounded > 0 then
    Hts_HP_Label:SetText("|cffa500Can Fly In|r: " .. string.format("%.1f", grounded) .. "%")

  elseif grounded <= 0 then Hts_HP_Label:SetText("|cff0000Can Fly Now|r") end

  if grounded <= 0 then
    zo_callLater(function()
      Hts_HP:SetHidden(true)
      EM:UnregisterForUpdate(HowToSunspire.name .. "YolnahkriinUI")
    end, 2500)
  end
end

local inPortal = false
function HowToSunspire.NahviiHealth()
  if sV.Enable.hpNahvii ~= true or inPortal ~= false then return end

  local current, max, effective = GetUnitPower("boss1", POWERTYPE_HEALTH)
  local n = ( current / max ) * 100

  if n >= 80 then                  flying = 80
  elseif (n < 80 and n >= 60) then flying = 60
  elseif (n < 60 and n >= 40) then flying = 40
  else
    Hts_HP:SetHidden(true)
    EM:UnregisterForUpdate(HowToSunspire.name .. "BossHealth")
    return
  end

  grounded = n - flying

  if grounded <= sV.hpShowPercent then
    Hts_HP:SetHidden(false)

    HowToSunspire.NahviiHealthUI()
    EM:UnregisterForUpdate(HowToSunspire.name .. "NahviintaasUI")
    EM:RegisterForUpdate(HowToSunspire.name .. "NahviintaasUI", 100, HowToSunspire.NahviiHealthUI)

    EM:UnregisterForUpdate(HowToSunspire.name .. "BossHealth")
  end
end

function HowToSunspire.NahviiHealthUI()
  local current, max, effective = GetUnitPower("boss1", POWERTYPE_HEALTH)
  local nahviiHP = ( current / max ) * 100
  grounded = nahviiHP - flying

  if grounded > 0 then Hts_HP_Label:SetText("|cffa500Can Fly In|r: " .. string.format("%.1f", grounded) .. "%")
  elseif grounded <= 0 then Hts_HP_Label:SetText("|cff0000Can Fly Now|r") end

  if grounded <= 0 then
    zo_callLater(function()
      Hts_HP:SetHidden(true)
      EM:UnregisterForUpdate(HowToSunspire.name .. "NahviintaasUI")
    end, 2500)
  end
  if inPortal == true then
    Hts_HP:SetHidden(true)
    EM:UnregisterForUpdate(HowToSunspire.name .. "NahviintaasUI")
  end
end
--------------------
---- LOKKESTIIZ ----
--------------------
local glacialFist = {}
function HowToSunspire.GlacialFist(_, result, _, _, _, _, _, _, targetName, targetType, hitValue, _, _, _, _, targetId, abilityId)
  if ((sV.Enable.GlacialFist ~= true) or (hitValue < 100)) then return end

  if targetType == COMBAT_UNIT_TYPE_PLAYER then

    table.insert(glacialFist, GetGameTimeMilliseconds() + hitValue)

    Hts_GlacialFist:SetHidden(false)

    if sV.Enable.Sound == true then
      PlaySound(SOUNDS.DUEL_START)
    end

    EM:UnregisterForUpdate(HowToSunspire.name .. "GlacialFistTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "GlacialFistTimer", 100, HowToSunspire.GlacialFistUI)

  elseif HowToSunspire.groupMembers[targetId].tag then

    SetMapToPlayerLocation()
    local x1, y1 = GetMapPlayerPosition("player")
    local x2, y2 = GetMapPlayerPosition(HowToSunspire.groupMembers[targetId].tag)
    if (math.sqrt((x1 - x2)^2 + (y1 - y2)^2) * 1000) <= 4.5 then

      table.insert(glacialFist, GetGameTimeMilliseconds() + hitValue)

      Hts_GlacialFist:SetHidden(false)

      if sV.Enable.Sound == true then
        PlaySound(SOUNDS.DUEL_START)
      end

      EM:UnregisterForUpdate(HowToSunspire.name .. "GlacialFistTimer")
      EM:RegisterForUpdate(HowToSunspire.name .. "GlacialFistTimer", 100, HowToSunspire.GlacialFistUI)
    end
  end
end

function HowToSunspire.GlacialFistUI()
  local text = ""
  local currentTime = GetGameTimeMilliseconds()

  for key, value in ipairs(glacialFist) do
    local timer = value - currentTime
    if timer >= 0 then
      if text == ""
      then text = text .. tostring(string.format("%.1f", timer / 1000))
      else text = text .. "|c99ccff / |r" .. tostring(string.format("%.1f", timer / 1000)) end
    else table.remove(glacialFist, key) end
  end

  if text ~= "" then Hts_GlacialFist_Label:SetText("|c99ccffGlacial Fist|r: " .. text)
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "GlacialFistTimer")
    Hts_GlacialFist:SetHidden(true)
  end
end

local iceTime
local tomb
local iceNext     = 0
local iceNumber   = 0
local prevIce     = 0
local tombsArmed  = false
local iceDouble   = false
local tombsActive = 0
local tombsClear  = true
local iceState    = 0
local checkDouble = true

local laserTime
function HowToSunspire.IceTomb(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result ~= ACTION_RESULT_BEGIN then return end

  if sV.Enable.IceTomb == true then

    local time  = GetGameTimeMilliseconds()
    isFlying    = false
    iceTime     = time / 1000 + 13
    iceNext     = time / 1000 + 23
    prevIce     = time
    iceNumber   = iceNumber % 3 + 1
    tombsClear  = false
    iceState    = 1
    checkDouble = true

    HowToSunspire.IceTombTimerUI()
    Hts_Ice:SetHidden(false)
    if sV.Enable.Sound then PlaySound(SOUNDS.DUEL_START) end

    EM:UnregisterForUpdate(HowToSunspire.name .. "IceTombTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "IceTombTimer", 100, HowToSunspire.IceTombTimerUI)

    --update all 1 seconds instead of all 0.1 seconds
    -- zo_callLater(function ()
    --   HowToSunspire.IceTombTimerUI()
    --   EM:UnregisterForUpdate(HowToSunspire.name .. "IceTombTimer")
    --   EM:RegisterForUpdate(HowToSunspire.name .. "IceTombTimer", 1000, HowToSunspire.IceTombTimerUI)
    -- end, 4000)

    --events for both ice took
    --[[EM:UnregisterForEvent(HowToSunspire.name .. "IceTombFinished", EVENT_EFFECT_CHANGED)
    EM:RegisterForEvent(HowToSunspire.name .. "IceTombFinished", EVENT_EFFECT_CHANGED, HowToSunspire.IceTombFinished)
    EM:AddFilterForEvent(HowToSunspire.name .. "IceTombFinished", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 119638)]]
  end
end

local tCast       = 0
local tArmed      = 0
local tFaded      = 0
local iGained     = 0
local iFaded      = 0
local iceTomb     = {
  [1] = { time = 0, cast = false, armed = false, taken = false, clear = false, unit = 0 },
  [2] = { time = 0, cast = false, armed = false, taken = false, clear = false, unit = 0 }
}
local function ClearTombs()
  tCast       = 0
  tArmed      = 0
  tFaded      = 0
  iGained     = 0
  iFaded      = 0
  tombsClear  = true
  iceDouble   = false
  iceTomb     = {
    [1] = { time = 0, cast = false, armed = false, taken = false, clear = false, unit = 0 },
    [2] = { time = 0, cast = false, armed = false, taken = false, clear = false, unit = 0 }
  }
  dbg("Tombs Reset")
end

local function TombCast(time)
  tCast = tCast + 1
  ice = iceTomb[tCast]
  if ice then
    ice.cast = true
    ice.time = time
    dbg(tCast .. " Cast")
  end
end

local function TombArmed()
  if tArmed < 0 then tArmed = 0 end
  local now = (GetGameTimeMilliseconds() / 1000)
  tArmed = tArmed + 1
  local ice = iceTomb[tArmed]
  if ice then
    ice.armed = true
    ice.time  = now + 10
  end
  dbg(tArmed .. " Armed (true)")
end

local function TombFaded()
  if tFaded < 0 then tFaded = tFaded + 1 end
  tFaded = tFaded + 1

  if checkDouble and tFaded == 2 and iceTomb[2].unit == 0 then
    checkDouble = false
    zo_callLater(function()
      if iGained == 1 then
        iceDouble = true
        dbg("double")
      else iceDouble = false end
    end, 100)
  end

  local ice = iceTomb[tFaded]

  if ice then
    iceTomb[tFaded].armed = false
    dbg(tFaded .. " Armed (false)")

    if (iceState == 1 and tFaded == 2) then

      -- zo_callLater(function()
      --   if iGained == 1 then
      --     iceDouble = true
      --     dbg("double")
      --   else iceDouble = false end
      -- end, 100)

      iceState    = 2
      tombsArmed  = false
      dbg("No tombs left")
    end
  else
    dbg("Tomb " .. iGained .. " Gained Error")
  end
end

local function IceGained(id)

  iGained = iGained + 1

  local t = GetGameTimeMilliseconds() / 1000

  local ice = iceTomb[iGained]
  if ice then
    ice.time   = t + 8
    ice.taken  = true
    if id ~= nil then
      ice.unit = id
      dbg("Tomb " .. iGained .. " taken by: " .. HowToSunspire.groupMembers[id].name .. " (" .. id .. ")")

      -- if iGained == 1 and tombsArmed == true then
      --   zo_callLater(function()
      --     if tFaded == 2 then
      --       iceDouble = true
      --       dbg("double")
      --     else iceDouble = false end
      --   end, 100)
      -- end

    else dbg("Tomb " .. iGained .. " taken by: Offline") end
  else dbg("Tomb " .. iGained .. " Gained Error") end
end

local function IceFaded(id)
  iFaded = iFaded + 1

  local taken = 0
  local clear = 0

  for k, v in pairs(iceTomb) do
    if v.unit == id then v.clear = true end
    if v.clear then clear = clear + 1 end
    if v.taken then taken = taken + 1 end
  end

  local ts = tostring
  dbg(iFaded .. " Clear / Taken / Double: " .. ts(clear) .. " / " .. ts(taken) .. " / " .. ts(iceDouble))

  if (clear == 2) or (tFaded == 2 and taken == 1) or (clear == 1 and iceDouble) then ClearTombs() end
  local ts = tostring
end

local s1 = "[|c00ff00A|r]: "
local s2 = "[|c00ff00B|r]: "
local s3 = "|cd92626Take|r "
local s4 = "|c00ffffHeal|r "
local s5 = "|c00FF00Done|r"
local s6 = "|c00ffffinc|r "
local S1 = "|c00ffffIce Tomb|r "
local S2 = "|c00ffffin|r: "
local S4 = "|c00ffffEnter Before|r: "

-- /script HowToSunspire.InIce(_, 2240, _, _, _, _, _, _, _, 1, nil, _, _, _, _, 41461, 0)
function HowToSunspire.InIce(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, targetId, abilityId)
  if (targetId == nil or targetId == 0) then return end

  if    (result == ACTION_RESULT_EFFECT_GAINED) then IceGained(targetId)
  -- or result == ACTION_RESULT_EFFECT_GAINED_DURATION) then
  elseif (result == ACTION_RESULT_EFFECT_FADED) then IceFaded(targetId) end
end

local icyPresence = 123103
local function isBossFlying()

  if iceNumber == 0 then return true end

  if (DoesUnitExist("boss1") and not IsUnitDead("boss1")) then
    local c, m, e = GetUnitPower("boss1", POWERTYPE_HEALTH)
    local p = ( c / m ) * 100

    if p >= 81 then return false end

    local now = GetGameTimeMilliseconds() / 1000
    local l   = (laserTime - now)

    if l >= 0 then return true end

    local g = false

    for i = 1, GetNumBuffs("boss1") do
      -- local name, startTime, endTime, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("boss1", i)

      local abilityId = select(11, GetUnitBuffInfo("boss1", i))

      if abilityId == icyPresence then g = true end
    end
    return not g
  end
  return true
end

local function formatIceLabel(i, time)
  local x = iceTomb[i]
  local n = i == 1 and s1 or s2
  local s = ""

  if x.cast then
    s = n
    if x.clear then
      s = s .. s5
    else
      local t = x.time - time
      if t > 0 then
        local T = string.format("%.0fs", t)
        if x.taken then
          s = s .. s4 .. T
        else
          if x.armed
          then s = s .. s3 .. T
          else s = s .. s6 end
        end
      else
        s = ""
      end
    end
  end
  return s
end

function HowToSunspire.IceTombTimerUI()
  local I = Hts_Ice

  if IsUnitDead("boss1") then
    EM:UnregisterForUpdate(HowToSunspire.name .. "IceTombTimer")
    I:SetHidden(true)
    return
  end

  local now = GetGameTimeMilliseconds() / 1000
  local T1  = iceTime - now

  if tombsClear then
    if isBossFlying() or not IsUnitInCombat("player") then
      EM:UnregisterForUpdate(HowToSunspire.name .. "IceTombTimer")
      I:SetHidden(true)
      return
    else
      local T2   = iceNext - now
      local next = { [0] = 1, [1] = 2, [2] = 3, [3] = 1 }
      local iN   = next[iceNumber]
      if T2 <= 0
      then I.title:SetText(S1 .. "|cff0000" .. iN .. " |cff0000INC|r")
      else I.title:SetText(S1 .. "|cff0000" .. iN .. "|r " .. S2  .. string.format("%.0f", T2)) end
      I.row[1]:SetText("")
      I.row[2]:SetText("")
      return
    end
  end

  -- if (T1 >= 9)
  -- then stringT = S1 .. "|cff0000" .. iceNumber .. "|r " .. S2 .. string.format("%.1f", T1 - 9)
  -- else stringT = S1 .. "|cff0000" .. iceNumber .. "|r "
  -- I.title:SetText(S1 .. "|cff0000" .. iceNumber .. "|r " .. S2 .. string.format("%.1f", T1 - 9))
  -- else
  --   if tombsArmed or T1 > 0
  --   then I.title:SetText(S1 .. "|cff0000" .. iceNumber .. "|r " .. S4 .. string.format("%.0f", T1))
  --   else I.title:SetText(S1 .. "|cff0000" .. iceNumber .. "|r " .. S3) end
  -- end

  local stringT = S1 .. "|cff0000" .. iceNumber .. "|r "
  local stringA = formatIceLabel(1, now)
  local stringB = ""

  if iceDouble
  then stringB = s2 .. "|c00ff00Double|r"
  else stringB = formatIceLabel(2, now) end

  I.title:SetText(stringT)
  I.row[1]:SetText(stringA)
  I.row[2]:SetText(stringB)
end

function HowToSunspire.IceTombFinished(_, change, _, _, unitTag, _, _, _, _, _, _, _, _, unitName, _, abilityId, _)
  -- "frozen prison" effect: 116025, 116043, 116044 (all active from tomb enter to tomb exit)
  -- "frozen tomb" effect: 119643 (1ms duration)
  -- 116034 = "Remove 115883" (free from tomb, 1sec duration )
  -- 116045 = in tomb
  -- 124335 = don't go in tomb

  local i = HowToSunspire.IceTombEffects

  if abilityId == i[1] then
    if change == 1 then TombCast(GetGameTimeMilliseconds() / 1000) end

  elseif abilityId == i[2] then
    if      (change == EFFECT_RESULT_GAINED)  then  TombArmed()
    elseif  (change == EFFECT_RESULT_FADED)   then  TombFaded()
    else
      local c
      if change == 1 then c = "gained" elseif change == 2 then c = "updated" elseif change == 3 then c = "faded" else c = tostring(change) end
      dbg("< id 2 > " .. c .. " / " .. unitName)
    end
  end
end

--[[
HTS :[07s 701ms] < Tombs Cast > gained / Offline
HTS :[07s 702ms] < Tombs Cast > gained / Offline
HTS :[09s 982ms] < Tombs Cast > faded / Offline
HTS :[10s 154ms] < Tombs Cast > updated / Offline
HTS :[10s 175ms] Tomb 1 taken by: @nogetrandom (55393)
HTS :[10s 176ms] 1 Armed (true)
HTS :[10s 177ms] 1 Armed (false)
HTS :[10s 271ms] < Tombs Cast > faded / Offline
HTS :[10s 423ms] < Tombs Cast > updated / Offline
HTS :[10s 443ms] 2 Armed (true)
HTS :[16s 685ms] double
HTS :[16s 686ms] 2 Armed (false)
HTS :[16s 687ms] No tombs left

HTS :[08s 590ms] < Tombs Cast > gained / Offline
HTS :[08s 591ms] < Tombs Cast > gained / Offline
HTS :[10s 962ms] < Tombs Cast > faded / Offline
HTS :[11s 131ms] < Tombs Cast > updated / Offline
HTS :[11s 153ms] 1 Armed (true)
HTS :[11s 249ms] < Tombs Cast > faded / Offline
HTS :[11s 420ms] < Tombs Cast > updated / Offline
HTS :[11s 442ms] Tomb 1 taken by: @nogetrandom (55393)
HTS :[11s 443ms] 2 Armed (true)
HTS :[11s 445ms] 1 Armed (false)
HTS :[17s 531ms] double
HTS :[17s 532ms] 2 Armed (false)
HTS :[17s 533ms] No tombs left

HTS :[08s 781ms] < Tombs Cast > gained / Offline
HTS :[08s 782ms] < Tombs Cast > gained / Offline
HTS :[11s 268ms] < Tombs Cast > faded / Offline
HTS :[11s 402ms] < Tombs Cast > faded / Offline
HTS :[11s 443ms] < Tombs Cast > updated / Offline
HTS :[11s 461ms] 1 Armed (true)
HTS :[11s 601ms] < Tombs Cast > updated / Offline
HTS :[11s 635ms] 2 Armed (true)
HTS :[14s 161ms] Tomb 1 taken by: @nogetrandom (55393)
HTS :[14s 164ms] 1 Armed (false)
HTS :[14s 164ms] double
HTS :[14s 165ms] 2 Armed (false)
HTS :[14s 166ms] No tombs left
]]

function HowToSunspire.LokkeLaser(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result == ACTION_RESULT_BEGIN then

    isFlying  = true
    zo_callLater(function()
      iceNumber = 0
      prevIce   = 0
      if CombatAlerts then CombatAlerts.sunspire.tombId = 0 end
    end, 10000)

    local currentTime = GetGameTimeMilliseconds()

    local timerInvocAtros = 0
    if abilityId == 122820 then
      laserTime   = currentTime / 1000 + 40
      landingTime = laserTime + 12.8
      timerInvocAtros = 40 + 12.8

    elseif abilityId == 122821 then
      laserTime   = currentTime / 1000 + 10
      landingTime = laserTime + 54.6
      timerInvocAtros = 10 + 54.6

    elseif abilityId == 122822 then
      laserTime   = currentTime / 1000 + 32
      landingTime = laserTime + 32.1
      timerInvocAtros = 32 + 32.1

      if sV.Enable.hpLokke == true then
        zo_callLater(function() EM:UnregisterForUpdate(HowToSunspire.name .. "LokkestiizUI") end, 2500)
      end

    else return end

    flight   = flight + 1
    takeOff  = currentTime / 1000
    -- estimate = landingTime
    -- if sV.debug then
    --   zo_callLater(function()
    --     EM:RegisterForUpdate(HowToSunspire.name .. "TimeFlying", 20, HowToSunspire.CheckLandingTimer)
    --   end, 3000)
    -- end

    if sV.Enable.landingLokke == true then
      EM:RegisterForUpdate(HowToSunspire.name .. "BossLandingTimer", 100, HowToSunspire.BossLanding)
    end

    if sV.Enable.LaserLokke == true then
      HowToSunspire.LokkeLaserTimerUI()
      Hts_Laser:SetHidden(false)

      EM:UnregisterForUpdate(HowToSunspire.name .. "LokkeLaserTimer")
      EM:RegisterForUpdate(HowToSunspire.name .. "LokkeLaserTimer", 1000, HowToSunspire.LokkeLaserTimerUI)
    end
  end
end

function HowToSunspire.LokkeLaserTimerUI()
  local currentTime = GetGameTimeMilliseconds() / 1000
  local timer       = laserTime - currentTime

  if timer >= 0 then
    Hts_Laser_Label:SetText("|c7fffd4Laser|r: " .. tostring(string.format("%.0f", timer)))
  else
    Hts_Laser_Label:SetText("|c7fffd4Laser|r: NOW")
    EM:UnregisterForUpdate(HowToSunspire.name .. "LokkeLaserTimer")
    zo_callLater(function() Hts_Laser:SetHidden(true) end, 8000)
  end
end

--[[
[Lokkestiiz] (from flight start)
#1 = 53.347s, 53.172s, 52.696s, 52.625s, 52.878s, 52.471s, 53.029s, 52.622s, 52.942s, 52.715s, 53.215s, 52.754s
#2 = 64.528s, 64.768s, 64.393s, 65.189s, 64.535s, 64.752s, 64.692s, 64.660s, 64.533s
#3 = 64.253s, 63.725s, 64.076s, 64.018s

[Yolnahkriin]: (from Cataclysm Cast)
#1 = 11.435s, 11.636s, 11.508s, 11.439s, 11.403s
#2 = 11.310s, 11.358s, 11.260s
#3 = 11.316s, 11.219s, 11.285s

Cataclysm time:
#1 =
#2 =
#3 =

[Nahviintaas]: (from Fire Storm cast)
#1 = 20.381s, 20.130s, 20.696s, 20.240s, 20.672s, 20.718s
#2 = 20.005s, 20.093s, 20.504s
#3 = 20.123s, 20.951s, 20.914s
#4 = 20.512s, 20.429s, 20.127s

-----------------------

Lokke:  51.27, 51.60, 51.65, 51.61 51.63, 51.39
Yolna:  22.46, 22.54, 22.50
Nahvii: 45.77

]]

function HowToSunspire.TakeFlight(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
    if result == ACTION_RESULT_BEGIN then
        -- Yolna
        if abilityId == 124910 then
            -- time from flight until cata: start = 8.131, end = 16.088 (duration = 7.957)
            -- time from flight cast until attackable = 19.566
            -- time from flight cast until damage taken = 22.654
            flight   = 1
            logTime  = 22.654
        elseif abilityId == 124915 then
            -- time from flight until cata: start = 9.092, end = 17.065 (duration = 7.973)
            -- time from flight cast until attackable = 20.402
            -- time from flight cast until damage taken = 23.516
            flight   = 2
            logTime  = 23.516
        elseif abilityId == 124916 then
            -- time from flight until cata: start = 9.365, end = 17.313 (duration = 7.948)
            -- time from flight cast until attackable = 20.408
            -- time from flight cast until damage taken = 23.798
            flight   = 3
            logTime  = 23.798

        -- Nahvii
        -- TODO something with adds enraging
        -- elseif abilityId == 120921 then
        --
        -- elseif abilityId == 120991 then
        --
        -- elseif abilityId == 120992 then

        end
    end
end

function HowToSunspire.BossLanding()
  local currentTime = GetGameTimeMilliseconds() / 1000
  local timer       = landingTime - currentTime
  local showTime    = (landingTime - currentTime) - sV.timeBeforeLanding

  if timer > 0 then
    Hts_Landing_Label:SetText("|c5cd65cLanding in|r: " .. string.format("%.0f", timer))

    if showTime <= 0 then Hts_Landing:SetHidden(false) end

  elseif timer <= 0 then

    Hts_Landing_Label:SetText("|c5cd65cLanding|r: NOW")

    HowToSunspire.BossHealth()

    zo_callLater(function()
      EM:UnregisterForUpdate(HowToSunspire.name .. "BossLandingTimer")
      Hts_Landing:SetHidden(true)
    end, 2500)
  end
end
--------------------
---- YOLNAKRIIN ----
--------------------
function HowToSunspire.AtroSpawn(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result == ACTION_RESULT_BEGIN and sV.Enable.Atro == true then
    Hts_Atro:SetHidden(false)

    if sV.Enable.Sound then PlaySound(SOUNDS.DUEL_START) end

    EM:UnregisterForUpdate(HowToSunspire.name .. "HideAtro")
    EM:RegisterForUpdate(HowToSunspire.name .. "HideAtro", 4500, HowToSunspire.HideAtro)
  end
end

function HowToSunspire.HideAtro()
  EM:UnregisterForUpdate(HowToSunspire.name .. "HideAtro")
  Hts_Atro:SetHidden(true)
end

function HowToSunspire.LavaGeyser(_, result, _, _, _, _, _, _, targetName, targetType, hitValue, _, _, _, _, targetId, abilityId)
  if result == ACTION_RESULT_BEGIN and sV.Enable.Geyser == true then
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
      Hts_Geyser:SetHidden(false)

      if sV.Enable.Sound then PlaySound(SOUNDS.DUEL_START) end

      EM:UnregisterForUpdate(HowToSunspire.name .. "HideGeyser")
      EM:RegisterForUpdate(HowToSunspire.name .. "HideGeyser", 2500, HowToSunspire.HideGeyser)

    elseif HowToSunspire.groupMembers[targetId].tag then
      --copied from CCA
      SetMapToPlayerLocation()
      local x1, y1 = GetMapPlayerPosition("player")
      local x2, y2 = GetMapPlayerPosition(HowToSunspire.groupMembers[targetId].tag)
      if (math.sqrt((x1 - x2)^2 + (y1 - y2)^2) * 1000) < 2.8 then
        Hts_Geyser:SetHidden(false)

        if sV.Enable.Sound then PlaySound(SOUNDS.DUEL_START) end

        EM:UnregisterForUpdate(HowToSunspire.name .. "HideGeyser")
        EM:RegisterForUpdate(HowToSunspire.name .. "HideGeyser", 2500, HowToSunspire.HideGeyser)
      end
    end
  end
end

function HowToSunspire.HideGeyser()
  EM:UnregisterForUpdate(HowToSunspire.name .. "HideGeyser")
  Hts_Geyser:SetHidden(true)
end

local nextFlareTime
function HowToSunspire.NextFlare(_, result, _, _, _, _, _, _, targetName, targetType, hitValue, _, _, _, _, targetId, abilityId)
  local current, max, effective = GetUnitPower("boss1", POWERTYPE_HEALTH)
  local yHP = ( current / max ) * 100

  if abilityId == 121722 and result == ACTION_RESULT_BEGIN then
    nextFlareTime = GetGameTimeMilliseconds() / 1000 + 32

  elseif abilityId == 121459 and result == ACTION_RESULT_EFFECT_FADED then
    nextFlareTime = GetGameTimeMilliseconds() / 1000 + 30

    -- if yHP > 60 then
    -- 		landingTime = nextFlareTime - 5
    -- else
    -- 		landingTime = nextFlareTime - 6
    -- end

  elseif abilityId == nil and result == nil and targetName == nil and targetType == nil and hitValue == nil and targetId == nil then

    if not sV.Enable.NextFlare then return end

    --from fight begin
    nextFlareTime = GetGameTimeMilliseconds() / 1000 + 6

  else return end

  -- if sV.Enable.landingYolna == true then
  -- 		EM:RegisterForUpdate(HowToSunspire.name .. "BossLandingTimer", 100, HowToSunspire.BossLanding)
  -- end

  if sV.Enable.NextFlare then
    HowToSunspire.NextFlareUI()
    Hts_NextFlare:SetHidden(false)

    EM:UnregisterForUpdate(HowToSunspire.name .. "NextFlareTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "NextFlareTimer", 1000, HowToSunspire.NextFlareUI)
  end
end

function HowToSunspire.NextFlareUI()
  local currentTime = GetGameTimeMilliseconds() / 1000
  local timer = nextFlareTime - currentTime

  if timer >= 0 then
    Hts_NextFlare_Label:SetText("|ce51919Next Flare|r: " .. tostring(string.format("%.0f", timer)))
  else
    Hts_NextFlare_Label:SetText("|ce51919Next Flare|r: INC")
    EM:UnregisterForUpdate(HowToSunspire.name .. "NextFlareTimer")
  end
end

local cataTime
function HowToSunspire.Cata(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result == ACTION_RESULT_BEGIN then

    local currentTime = GetGameTimeMilliseconds()

    if cataTime > currentTime then return end

    cataTime = currentTime + hitValue

    landingTime = (cataTime / 1000) + 6.8
    takeOff     = currentTime / 1000
    estimate    = landingTime
    -- dbg("Cataclysm time: " .. string.format("%.3fs", hitValue / 1000))

    -- if sV.debug then
    --   EM:UnregisterForUpdate(HowToSunspire.name .. "TimeFlying")
    --   EM:RegisterForUpdate(HowToSunspire.name .. "TimeFlying", 20, HowToSunspire.CheckLandingTimer)
    -- end

    if sV.Enable.Cata == true then
      HowToSunspire.CataTimerUI()
      Hts_Cata:SetHidden(false)

      EM:UnregisterForUpdate(HowToSunspire.name .. "CataTimer")
      EM:RegisterForUpdate(HowToSunspire.name .. "CataTimer", 100, HowToSunspire.CataTimerUI)
    end

    if sV.Enable.landingYolna == true then
      EM:RegisterForUpdate(HowToSunspire.name .. "BossLandingTimer", 100, HowToSunspire.BossLanding)
    end
  end
end

function HowToSunspire.CataTimerUI()
  local currentTime = GetGameTimeMilliseconds()
  local timer       = cataTime - currentTime

  if timer >= 0 then
    Hts_Cata_Label:SetText("|ce51919Cataclysm Ends in|r: " .. tostring(string.format("%.1f", timer / 1000)))
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "CataTimer")
    Hts_Cata:SetHidden(true)
  end
end
---------------------
---- NAHVIINTAAS ----
---------------------
local slam = {}
function HowToSunspire.PowerfulSlam(_, result, _, _, _, _, _, _, targetName, targetType, hitValue, _, _, _, _, targetId, abilityId)
  if sV.Enable.PowerfulSlam ~= true or result ~= ACTION_RESULT_BEGIN then return end

  if targetType == COMBAT_UNIT_TYPE_PLAYER then
    table.insert(slam, GetGameTimeMilliseconds() + hitValue)

    HowToSunspire.PowerfulSlamUI()
    Hts_PowerfulSlam:SetHidden(false)

    if sV.Enable.Sound then PlaySound(SOUNDS.DUEL_START) end

    EM:UnregisterForUpdate(HowToSunspire.name .. "SlamTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "SlamTimer", 100, HowToSunspire.PowerfulSlamUI)

  elseif HowToSunspire.groupMembers[targetId] then
    if not HowToSunspire.groupMembers[targetId].tag then return end

    SetMapToPlayerLocation()
    local x1, y1 = GetMapPlayerPosition("player")
    local x2, y2 = GetMapPlayerPosition(HowToSunspire.groupMembers[targetId].tag)
    if not x2 and not y2 then return end
    if (math.sqrt((x1 - x2)^2 + (y1 - y2)^2) * 1000) <= 7 then -- <= 5.5 then
      table.insert(slam, GetGameTimeMilliseconds() + hitValue)

      HowToSunspire.PowerfulSlamUI()
      Hts_PowerfulSlam:SetHidden(false)

      if sV.Enable.Sound then PlaySound(SOUNDS.DUEL_START) end

      EM:UnregisterForUpdate(HowToSunspire.name .. "SlamTimer")
      EM:RegisterForUpdate(HowToSunspire.name .. "SlamTimer", 100, HowToSunspire.PowerfulSlamUI)
    end
  else return end
end

function HowToSunspire.PowerfulSlamUI()
  local text        = ""
  local currentTime = GetGameTimeMilliseconds()

  for key, value in ipairs(slam) do
    local timer = value - currentTime
    if timer >= 0 then
      if text == "" then
        text = text .. string.format("%.1f", timer / 1000)
      else
        text = text .. "|cFF4500 / |r" .. string.format("%.1f", timer / 1000)
      end
    else table.remove(slam, key) end
  end

  if text ~= "" then
    Hts_PowerfulSlam_Label:SetText("|cFF4500SLAM|r: " .. text)
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "SlamTimer")
    Hts_PowerfulSlam:SetHidden(true)
  end
end

local stoneFist = {}
function HowToSunspire.Stonefist(_, result, _, abilityName, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if hitValue > 3000 or result ~= ACTION_RESULT_BEGIN then return end
  if ((sV.Enable.Stonefist == true) and (targetType == COMBAT_UNIT_TYPE_PLAYER)) then

    table.insert(stoneFist, GetGameTimeMilliseconds() + hitValue)

    HowToSunspire.StoneFistUI()
    Hts_Stonefist:SetHidden(false)

    if sV.Enable.Sound == true then PlaySound(SOUNDS.DUEL_START) end

    EM:UnregisterForUpdate(HowToSunspire.name .. "StoneFistTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "StoneFistTimer", 100, HowToSunspire.StoneFistUI)
  end
end

function HowToSunspire.StoneFistUI()
  local text = ""
  local currentTime = GetGameTimeMilliseconds()

  for key, value in ipairs(stoneFist) do
    local timer = value - currentTime
    if timer >= 0 then
      if text == "" then text = text .. tostring(string.format("%.1f", timer / 1000))
      else text = text .. "|cb38600 / |r" .. tostring(string.format("%.1f", timer / 1000))
      end
    else table.remove(stoneFist, key) end
  end

  if text ~= "" then
    Hts_Stonefist_Label:SetText("|cb38600Stonefist|r: " .. text)
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "StoneFistTimer")
    Hts_Stonefist:SetHidden(true)
  end
end

--[[
local statues = 0
function HowToSunspire.LivingStone(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
		if sV.Enable.HailOfStone == false then return end

		if result == ACTION_RESULT_BEGIN then
				statues = statues + 1
		end
end

local hailOfStones = {}
function HowToSunspire.HailofStone(_, result, _, _, _, _, sourceName, _, _, _, hitValue, _, _, _, sourceUnitId, _, abilityId)
		if sV.Enable.HailOfStone == false then return end

		if result == ACTION_RESULT_EFFECT_FADED then
				hailOfStones = hailOfStones + 1

				if hailOfStones > statues then
						hailOfStones = statues
				end

				HowToSunspire.HailofStoneUI()

				Hts_HailOfStone:SetHidden(false)

				if sV.Enable.Sound then
						PlaySound(SOUNDS.TELVAR_GAINED)
				end

				EM:UnregisterForUpdate(HowToSunspire.name .. "HailofStone")
				EM:RegisterForUpdate(HowToSunspire.name .. "HailofStone", 500, HowToSunspire.HailofStoneUI)

		elseif result == ACTION_RESULT_BEGIN then
				hailOfStones = hailOfStones - 1
		end
end


local statue1	= nil
local stetue2	= nil
local statue3 = nil
local statue4 = nil
local hailTime1 = nil
local hailTime2 = nil
local hailTime3 = nil
local hailtime4 = nil
function HowToSunspire.HailofStone(_, result, _, _, _, _, sourceName, _, _, _, hitValue, _, _, _, sourceUnitId, _, abilityId)
		if sV.Enable.HailOfStone == false then return end

		if result == ACTION_RESULT_BEGIN then

				local t = GetGameTimeMilliseconds() / 1000

				if hailTime1 <= 0 then
						statue1 = sourceUnitId
						hailTime1 = t
        		table.insert(hailOfStones, hailTime1)
				else
						if hailTime2 <= 0 then
								statue2 = sourceUnitId
								hailTime2 = t
								table.insert(hailOfStones, hailTime2)
						else
								if hailTime3 <= 0 then
										statue3 = sourceUnitId
										hailTime3 = t
										table.insert(hailOfStones, hailTime3)
								else
										statue4 = sourceUnitId
										hailTime4 = t
										table.insert(hailOfStones, hailTime4)
								end
						end
				end

				Hts_HailOfStone:SetHidden(false)

				EM:UnregisterForUpdate(HowToSunspire.name .. "HailofStone")
				EM:RegisterForUpdate(HowToSunspire.name .. "HailofStone", 500, HowToSunspire.HailofStoneUI)

		elseif result == ACTION_RESULT_EFFECT_FADED then

				if sourceUnitId == statue1 then
						table.remove(hailOfStones, hailTime1)
						statue1 = nil
						hailTime1 = nil
				elseif sourceUnitId == statue2 then
						table.remove(hailOfStones, hailTime2)
						statue2 = nil
						hailTime2 = nil
				elseif sourceUnitId == statue3 then
						table.remove(hailOfStones, hailTime3)
						statue3 = nil
						hailTime3 = nil
				elseif sourceUnitId == statue4 then
						table.remove(hailOfStones, hailTime4)
						statue4 = nil
						hailTime4 = nil
				end
		end
end

function HowToSunspire.HailofStoneUI()
		local text = ""
		local currentTime = GetGameTimeMilliseconds() / 1000

		for key, value in ipairs(hailOfStones) do
				local timer = value + currentTime
				if timer ~= nil then
						if text == "" then
								text = text .. tostring(string.format("%.0f", timer))
						else
								text = text .. "|ce6ac00 / |r" .. tostring(string.format("%.0f", timer))
						end
				end
		end

		if text ~= "" then
				Hts_HailOfStone_Label:SetText("|ce6ac00Hail of Stones|r: " .. text)
		else
				EM:UnregisterForUpdate(HowToSunspire.name .. "HailofStone")
				Hts_HailOfStone:SetHidden(true)
		end
end
]]
local rightToLeft
function HowToSunspire.SweepingBreath(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result == ACTION_RESULT_BEGIN and sV.Enable.SweepBreath == true then
    if abilityId == 118743 then rightToLeft = true
    else rightToLeft = false end

    --run all UI functions for HA
    HowToSunspire.SweepingBreathUI()
    Hts_Sweep:SetHidden(false)
    if sV.Enable.Sound then PlaySound(SOUNDS.DUEL_START) end

    EM:UnregisterForUpdate(HowToSunspire.name .. "SweepingBreath")
    EM:RegisterForUpdate(HowToSunspire.name .. "SweepingBreath", 100, HowToSunspire.SweepingBreathUI)

    --hide 5sec later
    EM:RegisterForUpdate(HowToSunspire.name .. "HideSweepingBreath", 5000, HowToSunspire.HideSweepingBreath)
  end
end

local flash = 0
local function GetArrowForSweepingBreath()
  flash = flash % 4 + 1
  local arrow

  if rightToLeft then
    if flash == 1 then     arrow = "<<|cffa500<|r|cff0000<|r"
    elseif flash == 2 then arrow = "<|cffa500<|r|cff0000<|r|cffa500<|r"
    elseif flash == 3 then arrow = "|cffa500<|r|cff0000<|r|cffa500<|r<"
    else                   arrow = "|cff0000<|r|cffa500<|r<<"
    end
  else
    if flash == 1 then     arrow = "|cff0000>|r|cffa500>|r>>"
    elseif flash == 2 then arrow = "|cffa500>|r|cff0000>|r|cffa500>|r>"
    elseif flash == 3 then arrow = ">|cffa500>|r|cff0000>|r|cffa500>|r"
    else                   arrow = ">>|cffa500>|r|cff0000>|r"
    end
  end
  return arrow
end

function HowToSunspire.SweepingBreathUI()
  local arrow = GetArrowForSweepingBreath()

  Hts_Sweep_Label:SetText(arrow .. " Sweep Breath " .. arrow)
end

function HowToSunspire.HideSweepingBreath()
  EM:UnregisterForUpdate(HowToSunspire.name .. "HideSweepingBreath")
  EM:UnregisterForUpdate(HowToSunspire.name .. "SweepingBreath")
  Hts_Sweep:SetHidden(true)
end

local spitTime
function HowToSunspire.FireSpit(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if targetType ~= COMBAT_UNIT_TYPE_PLAYER or hitValue < 300 or sV.Enable.Spit ~= true then return end

  if result == ACTION_RESULT_BEGIN then
    spitTime = GetGameTimeMilliseconds() + hitValue

    if abilityId == 118860 then
      spitTime = spitTime + 900
    else
      spitTime = spitTime + 700
    end

    HowToSunspire.FireSpitUI()
    Hts_Spit:SetHidden(false)
    if sV.Enable.Sound then
      PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
    end

    EM:UnregisterForUpdate(HowToSunspire.name .. "FireSpitTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "FireSpitTimer", 100, HowToSunspire.FireSpitUI)
  end
end

function HowToSunspire.FireSpitUI()
  local currentTime = GetGameTimeMilliseconds()
  local timer = spitTime - currentTime

  if timer >= 0 then
    Hts_Spit_Label:SetText("|cff1493Spit|r: " .. tostring(string.format("%.1f", timer / 1000)))
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "FireSpitTimer")
    Hts_Spit:SetHidden(true)
  end
end

local thrashTime
local nextMeteorTime
function HowToSunspire.Thrash(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result == ACTION_RESULT_BEGIN and sV.Enable.Thrash == true then
    local currentTime = GetGameTimeMilliseconds()
    thrashTime = currentTime + hitValue

    HowToSunspire.ThrashTimerUI()
    if sV.Enable.Sound then PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED) end
    Hts_Thrash:SetHidden(false)

    EM:UnregisterForUpdate(HowToSunspire.name .. "ThrashTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "ThrashTimer", 100, HowToSunspire.ThrashTimerUI)

    nextMeteorTime = nextMeteorTime - 1.5
  end
end

function HowToSunspire.ThrashTimerUI()
  local currentTime = GetGameTimeMilliseconds()
  local timer = thrashTime - currentTime

  if timer >= 0 then
    Hts_Thrash_Label:SetText("|ce51919THRASH|r: " .. tostring(string.format("%.1f", timer / 1000)))
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "ThrashTimer")
    Hts_Thrash:SetHidden(true)
  end
end

local tearTime
function HowToSunspire.SoulTear(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result == ACTION_RESULT_BEGIN and sV.Enable.SoulTear == true then
    local currentTime = GetGameTimeMilliseconds()
    tearTime = currentTime + 2000

    HowToSunspire.SoulTearTimerUI()
    if sV.Enable.Sound then
      PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)
    end
    Hts_SoulTear:SetHidden(false)

    EM:UnregisterForUpdate(HowToSunspire.name .. "SoulTearTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "SoulTearTimer", 100, HowToSunspire.SoulTearTimerUI)
  end
end

function HowToSunspire.SoulTearTimerUI()
  local currentTime = GetGameTimeMilliseconds()
  local timer = tearTime - currentTime

  if timer >= 0 then
    Hts_SoulTear_Label:SetText("|c9966ffSOUL TEAR|r")
    -- Hts_SoulTear_Label:SetText("|c9966ffSOUL TEAR|r: " .. tostring(string.format("%.1f", timer / 1000)))
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "SoulTearTimer")
    Hts_SoulTear:SetHidden(true)
  end
end

function HowToSunspire.NextMeteor(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if not sV.Enable.NextMeteor then return end

  if (abilityId == 117251 or abilityId == 123067) and result == ACTION_RESULT_EFFECT_GAINED_DURATION then
    nextMeteorTime = GetGameTimeMilliseconds() / 1000 + 14.5
  elseif abilityId == 117308 and result == ACTION_RESULT_BEGIN then
    nextMeteorTime = GetGameTimeMilliseconds() / 1000 + 10.5
  else return end
  HowToSunspire.NextMeteorUI()
  Hts_NextMeteor:SetHidden(false)

  EM:UnregisterForUpdate(HowToSunspire.name .. "NextMeteorTimer")
  EM:RegisterForUpdate(HowToSunspire.name .. "NextMeteorTimer", 1000, HowToSunspire.NextMeteorUI)
end

function HowToSunspire.NextMeteorUI()
  local currentTime = GetGameTimeMilliseconds() / 1000
  local timer = nextMeteorTime - currentTime

  if timer >= 0 then
    Hts_NextMeteor_Label:SetText("|cf51414Next Meteor|r: " .. tostring(string.format("%.0f", timer)))
  else
    Hts_NextMeteor_Label:SetText("|cf51414Next Meteor|r: INC")
    EM:UnregisterForUpdate(HowToSunspire.name .. "NextMeteorTimer")
    --Hts_NextMeteor:SetHidden(true)
  end
end

function HowToSunspire.MarkForDeath(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result == ACTION_RESULT_BEGIN then
    nextMeteorTime = nextMeteorTime + 1.5
  end
end

--found on stackoverflow
local function spairs(t)
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end

  table.sort(keys)

  local i = 0
  return function()
    i = i + 1
    if keys[i] then return keys[i], t[keys[i]] end
  end
end
------------------------
---- PORTAL TIMERS -----
------------------------
local portalTime
local wipeTime
local canSend = false
local canReceive = false
function HowToSunspire.Portal(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result ~= ACTION_RESULT_BEGIN then return end
  canSend = true

  if sV.Enable.Portal == true then
    portalTime = GetGameTimeMilliseconds() / 1000 + 14

    HowToSunspire.PortalTimerUI()
    Hts_Portal:SetHidden(false)
    if sV.Enable.Sound then PlaySound(SOUNDS.TELVAR_GAINED) end

    EM:UnregisterForUpdate(HowToSunspire.name .. "PortalTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "PortalTimer", 1000, HowToSunspire.PortalTimerUI)
  end

  if sV.Enable.Wipe then
    wipeTime = GetGameTimeMilliseconds() / 1000 + 98

    local callLater = (93 - sV.wipeCallLater) * 1000
    zo_callLater(function()
      Hts_Wipe:SetHidden(false)
      EM:UnregisterForUpdate(HowToSunspire.name .. "WipeTimer")
      EM:RegisterForUpdate(HowToSunspire.name .. "WipeTimer", 1000, HowToSunspire.WipeTimerUI)
    end, callLater)

    EM:UnregisterForEvent(HowToSunspire.name .. "WipeFinished", EVENT_COMBAT_EVENT)
    EM:RegisterForEvent(HowToSunspire.name .. "WipeFinished", EVENT_COMBAT_EVENT, HowToSunspire.WipeFinished)
    EM:AddFilterForEvent(HowToSunspire.name .. "WipeFinished", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 121216)
  end
end

function HowToSunspire.PortalTimerUI()
  local currentTime = GetGameTimeMilliseconds() / 1000
  local timer = portalTime - currentTime

  if timer >= 11 then
    Hts_Portal_Label:SetText("|c7fffd4Portal|r: |cff0000" .. tostring(string.format("%.0f", timer)) .. "|r")
  elseif timer >= 0 then
    Hts_Portal_Label:SetText("|c7fffd4Portal|r: " .. tostring(string.format("%.0f", timer)))
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "PortalTimer")
    Hts_Portal:SetHidden(true)
  end
end

function HowToSunspire.WipeTimerUI()
  local currentTime = GetGameTimeMilliseconds() / 1000
  local timer = wipeTime - currentTime

  if timer > 0.1 then
    Hts_Wipe_Label:SetText("|c8a2be2Portal Wipe|r: " .. tostring(string.format("%.0f", timer)))
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "WipeTimer")
    Hts_Wipe:SetHidden(true)
  end
end

function HowToSunspire.WipeFinished(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result == ACTION_RESULT_EFFECT_FADED then
    wipeTime = 0
    EM:UnregisterForEvent(HowToSunspire.name .. "WipeFinished", EVENT_COMBAT_EVENT)
    EM:UnregisterForUpdate(HowToSunspire.name .. "WipeTimer")
    Hts_Wipe:SetHidden(true)
    if LibMapPing then
      LibMapPing:RemoveMapPing(MAP_PIN_TYPE_PING)
    end
  end
end

local cptPortal = 0
function HowToSunspire.PortalEnter(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if targetType == COMBAT_UNIT_TYPE_GROUP then
    cptPortal = cptPortal + 1
  elseif targetType ~= COMBAT_UNIT_TYPE_PLAYER then
    return
  end

  if result == ACTION_RESULT_EFFECT_GAINED_DURATION or cptPortal == 3 then
    inPortal = true
    Hts_HP:SetHidden(true)
    EM:UnregisterForUpdate(HowToSunspire.name .. "NahviintaasUI")
    cptPortal = 0
    EM:UnregisterForUpdate(HowToSunspire.name .. "PortalTimer")
    Hts_Portal:SetHidden(true)
  end
end

function HowToSunspire.PortalExit(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  --Unregister for all Portal relative events
  if result == ACTION_RESULT_EFFECT_GAINED_DURATION and targetType == COMBAT_UNIT_TYPE_PLAYER then
    inPortal = false
    EM:UnregisterForUpdate(HowToSunspire.name .. "InterruptTimer")
    EM:UnregisterForUpdate(HowToSunspire.name .. "PinsTimer")
    EM:UnregisterForEvent(HowToSunspire.name .. "Pins", EVENT_COMBAT_EVENT)
    Hts_Portal:SetHidden(true)
  end
end

local interruptTime
local interruptUnitId
function HowToSunspire.PortalInterrupt(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, targetUnitId, abilityId)
  if result ~= ACTION_RESULT_EFFECT_GAINED_DURATION --[[or inPortal ~= true]] then return end

  canReceive = true
  if LibMapPing then
    LibMapPing:RegisterCallback("BeforePingAdded", HowToSunspire.OnMapPing)
  end

  if sV.Enable.Pins == true then
    --register for when it is bashed
    EM:UnregisterForEvent(HowToSunspire.name .. "Pins", EVENT_COMBAT_EVENT)
    EM:RegisterForEvent(HowToSunspire.name .. "Pins", EVENT_COMBAT_EVENT, HowToSunspire.Pinned) --portal interrupt
    EM:AddFilterForEvent(HowToSunspire.name .. "Pins", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_INTERRUPT)
  end

  if sV.Enable.Interrupt == true then
    interruptTime = GetGameTimeMilliseconds() + hitValue
    interruptUnitId = targetUnitId

    HowToSunspire.InterruptTimerUI()
    Hts_Portal:SetHidden(false)

    EM:UnregisterForUpdate(HowToSunspire.name .. "InterruptTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "InterruptTimer", 100, HowToSunspire.InterruptTimerUI)
  end
end

function HowToSunspire.InterruptTimerUI()
  local currentTime = GetGameTimeMilliseconds()
  local timer = interruptTime - currentTime

  if timer >= 0 then
    Hts_Portal_Label:SetText("|c7fffd4Interrupt in|r: |cff0000" .. tostring(string.format("%.1f", timer / 1000)) .. "|r")
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "InterruptTimer")
    Hts_Portal:SetHidden(true)
  end
end

local pinsTime
function HowToSunspire.Pinned(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, targetUnitId, abilityId)
  --stop the timer of interrupt
  EM:UnregisterForUpdate(HowToSunspire.name .. "InterruptTimer")

  if interruptUnitId == targetUnitId then
    interruptUnitId = nil
    pinsTime = GetGameTimeMilliseconds() / 1000 + 20

    --run all UI functions for HA
    HowToSunspire.PinsTimerUI()
    Hts_Portal:SetHidden(false)

    EM:UnregisterForUpdate(HowToSunspire.name .. "PinsTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "PinsTimer", 1000, HowToSunspire.PinsTimerUI)
  end
end

function HowToSunspire.PinsTimerUI()
  local currentTime = GetGameTimeMilliseconds() / 1000
  local timer = pinsTime - currentTime

  if timer >= 0 then
    Hts_Portal_Label:SetText("|c7fffd4Next Pins|r: |cffcc00" .. tostring(string.format("%.0f", timer)) .. "|r")
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "PinsTimer")
    Hts_Portal:SetHidden(true)
  end
end

function HowToSunspire.NegateField(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, _, abilityId)
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and sV.Enable.Negate == true then
    Hts_Negate:SetHidden(false)
    if sV.Enable.Sound then PlaySound(SOUNDS.DUEL_START) end

    EM:UnregisterForUpdate(HowToSunspire.name .. "HideNegate")
    EM:RegisterForUpdate(HowToSunspire.name .. "HideNegate", 2500, HowToSunspire.HideNegate)
  end
end

function HowToSunspire.HideNegate()
  EM:UnregisterForUpdate(HowToSunspire.name .. "HideNegate")
  Hts_Negate:SetHidden(true)
end
----------------------------------
---- SHARE PART FOR EXPLOSION ----
----------------------------------
-- see https://i.ytimg.com/vi/O4tbOvKwZUw/maxresdefault.jpg
local stormTime
local firstStormTrigger = true
function HowToSunspire.FireStorm(_, result, _, _, _, _, _, _, _, targetType, hitValue, _, _, _, _, targetUnitId, abilityId)
  if result ~= ACTION_RESULT_BEGIN then return end

  if firstStormTrigger == true then firstStormTrigger = false return end

  firstStormTrigger = true
  stormTime         = GetGameTimeMilliseconds() / 1000 + 13.7
  landingTime       = stormTime + 6.6
  -- landingTime = GetGameTimeMilliseconds() / 1000 + 20.6

  flight   = flight + 1
  takeOff  = GetGameTimeMilliseconds() / 1000
  estimate = takeOff + landingTime

  -- if sV.debug then
  --   EM:UnregisterForUpdate(HowToSunspire.name .. "TimeFlying")
  --   EM:RegisterForUpdate(HowToSunspire.name .. "TimeFlying", 20, HowToSunspire.CheckLandingTimer)
  -- end

  if sV.Enable.landingNahvii == true then
    EM:RegisterForUpdate(HowToSunspire.name .. "BossLandingTimer", 100, HowToSunspire.BossLanding)
  end

  if sV.Enable.Storm == true then

    HowToSunspire.FireStormUI()
    Hts_Storm:SetHidden(false)

    EM:UnregisterForUpdate(HowToSunspire.name .. "FireStormTimer")
    EM:RegisterForUpdate(HowToSunspire.name .. "FireStormTimer", 100, HowToSunspire.FireStormUI)
  end

  if canSend and LibGPS3 and LibMapPing and sV.Enable.Sending then
    canSend = false

    local LGPS = LibGPS3
    local LMP = LibMapPing
    LGPS:PushCurrentMap()
    SetMapToMapListIndex(WROTHGAR_MAP_INDEX)

    local x = 42 * WROTHGAR_MAP_STEP_SIZE
    local y = 42 * WROTHGAR_MAP_STEP_SIZE
    LMP:SetMapPing(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, x, y)
    LGPS:PopCurrentMap()
  end
end

function HowToSunspire.FireStormUI()
  local currentTime = GetGameTimeMilliseconds() / 1000
  local timer       = stormTime - currentTime

  if timer >= 5.2 then
    Hts_Storm_Label:SetText("|ce51919Fire Storm Begin|r: " .. string.format("%.1f", timer - 5.2))
  elseif timer >= 0 then
    Hts_Storm_Label:SetText("|ce51919Fire Storm End|r: " .. string.format("%.1f", timer))
  else
    EM:UnregisterForUpdate(HowToSunspire.name .. "FireStormTimer")
    Hts_Storm:SetHidden(true)
  end
end

function HowToSunspire.OnMapPing(pingType, pingTag, _, _, isLocalPlayerOwner)
  if not canReceive or not LibGPS3 or not LibMapPing or isLocalPlayerOwner or not sV.Enable.Storm then return end

  local LGPS = LibGPS3
  local LMP = LibMapPing

  if pingType == MAP_PIN_TYPE_PING then
    LGPS:PushCurrentMap()
    SetMapToMapListIndex(WROTHGAR_MAP_INDEX)
    local x, y = LMP:GetMapPing(MAP_PIN_TYPE_PING, pingTag)

    if LMP:IsPositionOnMap(x, y) then
      --d("Enter in Received Function")
      canSend = false
      x = math.floor(x / WROTHGAR_MAP_STEP_SIZE)
      y = math.floor(y / WROTHGAR_MAP_STEP_SIZE)
      --d("X= " .. x .. " Y= " .. y)
      if x == 42 and y == 42 then
        canReceive = false
        LibMapPing:UnregisterCallback("BeforePingAdded", HowToSunspire.OnMapPing)

        stormTime = GetGameTimeMilliseconds() / 1000 + 13.7

        HowToSunspire.FireStormUI()
        Hts_Storm:SetHidden(false)

        EM:UnregisterForUpdate(HowToSunspire.name .. "FireStormTimer")
        EM:RegisterForUpdate(HowToSunspire.name .. "FireStormTimer", 100, HowToSunspire.FireStormUI)
      end
    end
    LGPS:PopCurrentMap()
  end
end

-- function HowToSunspire.DistanceCheck( unitId, distance )
-- 		-- if ((unitId and HowToSunspire.groupMembers[unitId]) or (unitId and HowToSunspire.groupMembers[unitId].tag)) then
-- 		if (unitId and HowToSunspire.groupMembers[unitId].tag) then
-- 				local unitTag = HowToSunspire.groupMembers[unitId].tag
-- 				if (IsUnitInGroupSupportRange(unitTag)) then
-- 						SetMapToPlayerLocation()
-- 						local _, x1, _, y1 = GetMapPlayerPosition("player")
-- 						local _, x2, _, y2 = GetMapPlayerPosition(unitTag)
-- 						return (math.sqrt((x1 - x2)^2 + (y1 - y2)^2) * 1000) <= distance	--(zo_sqrt((x1 - x2)^2 + (z1 - z2)^2) <= distance * 100)
-- 				end
-- 		end
-- 		return(false)
-- end

--------------
---- INIT ----
--------------
function HowToSunspire.ResetAll()
  --hide everything
  Hts_Ha:SetHidden(true)
  Hts_Comet:SetHidden(true)
  Hts_MeteorNames:SetHidden(true)
  Hts_Block:SetHidden(true)
  Hts_Leap:SetHidden(true)
  Hts_Shield:SetHidden(true)
  Hts_HP:SetHidden(true)
  Hts_Landing:SetHidden(true)
  Hts_Breath:SetHidden(true)
  Hts_Ice:SetHidden(true)
  Hts_Spit:SetHidden(true)
  Hts_Laser:SetHidden(true)
  Hts_Atro:SetHidden(true)
  Hts_Geyser:SetHidden(true)
  -- Hts_Flare:SetHidden(true)
  Hts_Storm:SetHidden(true)
  Hts_PowerfulSlam:SetHidden(true)
  Hts_Sweep:SetHidden(true)
  Hts_Thrash:SetHidden(true)
  Hts_SoulTear:SetHidden(true)
  Hts_Portal:SetHidden(true)
  Hts_Negate:SetHidden(true)
  Hts_Wipe:SetHidden(true)
  Hts_Cata:SetHidden(true)
  Hts_GlacialFist:SetHidden(true)
  Hts_Stonefist:SetHidden(true)
  -- Hts_HailOfStone:SetHidden(true)

  Hts_NextFlare:SetHidden(true)
  Hts_NextMeteor:SetHidden(true)
  zo_callLater(function()
    Hts_NextFlare:SetHidden(true)
    Hts_NextMeteor:SetHidden(true)
  end, 3000)

  --unregister UI timer events
  EM:UnregisterForUpdate(HowToSunspire.name .. "HeavyAttackTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "HideBlock")
  EM:UnregisterForUpdate(HowToSunspire.name .. "HideLeap")
  EM:UnregisterForUpdate(HowToSunspire.name .. "CometTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "ShieldChargeTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "BreathTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "IceTombTimer")
  EM:UnregisterForEvent(HowToSunspire.name .. "IceTombFinished", EVENT_EFFECT_CHANGED)
  EM:UnregisterForUpdate(HowToSunspire.name .. "LokkeLaserTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "BossLandingTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "BossHealth")
  EM:UnregisterForUpdate(HowToSunspire.name .. "LokkestiizUI")
  EM:UnregisterForUpdate(HowToSunspire.name .. "YolnahkriinUI")
  EM:UnregisterForUpdate(HowToSunspire.name .. "NahviintaasUI")
  EM:UnregisterForUpdate(HowToSunspire.name .. "HideAtro")
  -- EM:UnregisterForUpdate(HowToSunspire.name .. "FlareTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "HideGeyser")
  EM:UnregisterForUpdate(HowToSunspire.name .. "NextFlareTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "SlamTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "HideSweepingBreath")
  EM:UnregisterForUpdate(HowToSunspire.name .. "SweepingBreath")
  EM:UnregisterForUpdate(HowToSunspire.name .. "FireSpitTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "ThrashTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "SoulTearTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "NextMeteorTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "PortalTimer")
  EM:UnregisterForEvent( HowToSunspire.name .. "WipeFinished", EVENT_COMBAT_EVENT)
  EM:UnregisterForEvent( HowToSunspire.name .. "Pins", EVENT_COMBAT_EVENT)
  EM:UnregisterForUpdate(HowToSunspire.name .. "WipeTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "InterruptTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "PinsTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "HideNegate")
  EM:UnregisterForUpdate(HowToSunspire.name .. "FireStormTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "CataTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "GlacialFistTimer")
  EM:UnregisterForUpdate(HowToSunspire.name .. "StoneFistTimer")
  -- EM:UnregisterForUpdate(HowToSunspire.name .. "HailofStone")
  EM:UnregisterForUpdate(HowToSunspire.name .. "TimeFlying")
  EM:UnregisterForUpdate(HowToSunspire.name .. "MeteorUnits")
  EM:UnregisterForUpdate(HowToSunspire.name .. "HideMeteorNames")

  --[[if LibMapPing then
    LibMapPing:RemoveMapPing(MAP_PIN_TYPE_PING)
  end]]
  HowToSunspire.groupMembers  = {}
  --reset variables
  listHA                      = {}
  shieldChargeTime            = 0
  isComet                     = true
  cometTime                   = 0

  meteors                     = 0
  meteorUnits                 = {}
  meteorDisplayTime           = 0
  sortedMeteorUnits = {
    [1] = { tag = "", index = 0, isPlayer = false },
    [2] = { tag = "", index = 0, isPlayer = false },
    [3] = { tag = "", index = 0, isPlayer = false }
  }

  fightStart                  = 0
  bossFight                   = false
  bossName                    = ""
  spitTime                    = 0
  breathTime                  = 0
  flying                      = 0
  grounded                    = 0
  landingTime                 = 0

  glacialFist                 = {}
  iceNumber                   = 0
  tomb                        = 0
  prevIce                     = 0
  iceTime                     = 0
  tombsArmed                  = false
  laserTime                   = 0

  cataTime                    = 0
  nextFlareTime               = 0
  -- flares                      = {}

  slam                        = {}
  stoneFist                   = {}
  rightToLeft                 = 0
  flash                       = 0
  thrashTime                  = 0
  tearTime                    = 0
  stormTime                   = 0
  firstStormTrigger           = true
  nextMeteorTime              = 0

  portalTime                  = 0
  wipeTime                    = 0
  cptPortal                   = 0
  interruptTime               = 0
  interruptUnitId             = nil
  pinsTime                    = 0
  inPortal                    = false
  canReceive                  = false
  canSend                     = false

  -- statues											= 0
  -- hailOfStones 								= 0
  -- statue1											= nil
  -- statue2											= nil
  -- statue3 										= nil
  -- statue4 										= nil
  -- hailTime1 									= nil
  -- hailTime2 									= nil
  -- hailTime3 									= nil
  -- hailtime4 									= nil

  inIce                       = {
    [1] = { time = 0, armed = false, taken = false, active = false, id = 0 },
    [2] = { time = 0, armed = false, taken = false, active = false, id = 0 },
  }
  iceDouble                   = false
  checkDouble                 = true
  tombsActive                 = 0
  tombsClear                  = true
  tombsArmed                  = false
  isFlying                    = false

  tCast                       = 0
  tArmed                      = 0
  tFaded                      = 0
  iGained                     = 0
  iFaded                      = 0
  iceTomb                     = {
    [1] = { time = 0, cast = false, armed = false, taken = false, clear = false, unit = 0 },
    [2] = { time = 0, cast = false, armed = false, taken = false, clear = false, unit = 0 }
  }

  flight                      = 0
  timeFlying                  = 0
  takeOff                     = 0
  estimate                    = 0
  logTime                     = 0
end

function HowToSunspire.GetGroupTags(_, result, _, _, unitTag, _, _, _, _, _, _, _, _, unitName, unitId, _, abilityId)
  if not HowToSunspire.groupMembers[unitId] then
    HowToSunspire.groupMembers[unitId] = {
      tag  = unitTag,
      name = GetUnitDisplayName(unitTag) or unitName,
      ice  = false
    }
  end
end

function HowToSunspire.AudioReset( ) -- thanks to code65536
  SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED, "0")
  zo_callLater(function() SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED, "1") end, 500)
end

function HowToSunspire.CombatState()
  if IsUnitInCombat("player") then
    if DoesUnitExist("boss1") then

      bossName    = GetUnitName("boss1")
      bossFight   = true
      fightStart  = (GetGameTimeMilliseconds() / 1000)

      HowToSunspire.BossHealth()

      if bossName == "Lokkestiiz" then
        for i = 1, 2 do
          local ice = HowToSunspire.IceTombEffects[i]
          EM:RegisterForEvent(HowToSunspire.name .. "IceTombFinished" .. i, EVENT_EFFECT_CHANGED, HowToSunspire.IceTombFinished)
          EM:AddFilterForEvent(HowToSunspire.name .. "IceTombFinished" .. i, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ice)
        end

      elseif bossName == "Yolnahkriin" then
        HowToSunspire.NextFlare(_, nil, _, _, _, _, _, _, nil, nil, nil, _, _, _, _, nil, nil)
      end
    end
  end

  --on combat ended
  zo_callLater(function()
    if (not IsUnitInCombat("player")) then HowToSunspire.ResetAll() end
  end, 3000)
end

function HowToSunspire.OnPlayerActivated()
  if GetZoneId(GetUnitZoneIndex("player")) == 1121 then --in Sunspire
    for k, v in pairs(HowToSunspire.AbilitiesToTrack) do --Register for abilities in the other lua file
      EM:RegisterForEvent(HowToSunspire.name .. "Ability" .. k, EVENT_COMBAT_EVENT, v)
      EM:AddFilterForEvent(HowToSunspire.name .. "Ability" .. k, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
    end
    EM:RegisterForEvent(HowToSunspire.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, HowToSunspire.CombatState)
    EM:RegisterForEvent(HowToSunspire.name .. "GroupTags", EVENT_EFFECT_CHANGED, HowToSunspire.GetGroupTags)
    EM:AddFilterForEvent(HowToSunspire.name .. "GroupTags", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

    HowToSunspire.ResetAll()
  else
    for k, v in pairs(HowToSunspire.AbilitiesToTrack) do --Unregister for all abilities
      EM:UnregisterForEvent(HowToSunspire.name .. "Ability" .. k, EVENT_COMBAT_EVENT)
    end
    EM:UnregisterForEvent(HowToSunspire.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE)
    EM:UnregisterForUpdate(HowToSunspire.name .. "GroupTags", EVENT_EFFECT_CHANGED)
  end
end

function HowToSunspire:Initialize()
  --Saved Variables
  HowToSunspire.savedVariables = ZO_SavedVars:NewAccountWide("HowToSunspireVariables", 2, nil, HowToSunspire.Default)
  sV = HowToSunspire.savedVariables
  --Settings
  ZO_CreateStringId("SI_BINDING_NAME_RESET_STUCK_AUDIO", "Reset Audio")

  SLASH_COMMANDS[HowToSunspire.slash] = HowToSunspire.SlashCommand

  HowToSunspire.CreateSettingsWindow()
  HowToSunspire.InitUI()

  if LibMapPing then LibMapPing:MutePing(MAP_PIN_TYPE_PING) end

  --Events
  EM:RegisterForEvent(HowToSunspire.name .. "Activated", EVENT_PLAYER_ACTIVATED, HowToSunspire.OnPlayerActivated)

  EM:UnregisterForEvent(HowToSunspire.name, EVENT_ADD_ON_LOADED)
end

function HowToSunspire.OnAddOnLoaded(event, addonName)
  if addonName ~= HowToSunspire.name then return end
  HowToSunspire:Initialize()
end

EM:RegisterForEvent(HowToSunspire.name, EVENT_ADD_ON_LOADED, HowToSunspire.OnAddOnLoaded)


--[[
.181s (+4.7620000000024)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 14.301s (+5.002000000004)
HTS :Logtime was: 0
HTS :Cataclysm time: 0.010s
HTS :Cataclysm time: 5.000s
HTS :[Yolnahkriin]: #0 = 11.642s (-0.15799999999945)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 11.912s (+0.22400000000198)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 12.018s (+0.43600000000151)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 12.119s (+0.63800000000265)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 12.222s (+0.84400000000096)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 12.336s (+1.0720000000038)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 12.428s (+1.2560000000012)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 12.535s (+1.4700000000012)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 12.631s (+1.6620000000003)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 12.742s (+1.8840000000018)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 12.849s (+2.0980000000018)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 12.957s (+2.3140000000021)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 13.056s (+2.5120000000024)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 13.172s (+2.7440000000024)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 13.273s (+2.9460000000036)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 13.384s (+3.1680000000015)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 13.488s (+3.3760000000038)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 13.582s (+3.5640000000021)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 13.694s (+3.7880000000005)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 13.795s (+3.9900000000016)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 13.887s (+4.1740000000027)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 13.993s (+4.3860000000022)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 14.103s (+4.6060000000034)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 14.202s (+4.8040000000037)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 14.296s (+4.992000000002)
HTS :Logtime was: 0
HTS :[Yolnahkriin]: #0 = 14.408s (+5.2160000000003)
HTS :Logtime was: 0
HTS :Cataclysm time: 0.010s
HTS :[Yolnahkriin]: #0 = 10.970s (+8.3199999999997)
HTS :Logtime was: 0
SpeedRun: [Sunspire] Step 4 at 14:58.25.

HTS :[Nahviintaas]: #1 = 20.413s (-11814.468)
SpeedRun: [Sunspire] Step 5 at 20:02.68.
HTS :[Nahviintaas]: #1 = 20.550s (-11814.331)
HTS :[Nahviintaas]: #1 = 20.658s (-11814.223)
HTS :[Nahviintaas]: #1 = 20.759s (-11814.122)
HTS :[Nahviintaas]: #1 = 20.862s (-11814.019)
HTS :[Nahviintaas]: #1 = 20.975s (-11813.906)
HTS :[Nahviintaas]: #1 = 21.074s (-11813.807)
HTS :[Nahviintaas]: #1 = 21.173s (-11813.708)
HTS :[Nahviintaas]: #1 = 21.287s (-11813.594)
HTS :[Nahviintaas]: #1 = 21.376s (-11813.505)
HTS :[Nahviintaas]: #1 = 21.483s (-11813.398)
HTS :[Nahviintaas]: #1 = 21.588s (-11813.293)
HTS :[Nahviintaas]: #1 = 21.697s (-11813.184)
HTS :[Nahviintaas]: #1 = 21.804s (-11813.077)
HTS :[Nahviintaas]: #1 = 21.907s (-11812.974)
HTS :[Nahviintaas]: #1 = 22.018s (-11812.863)
HTS :[Nahviintaas]: #1 = 22.123s (-11812.758)
HTS :[Nahviintaas]: #1 = 22.226s (-11812.655)
HTS :[Nahviintaas]: #1 = 22.328s (-11812.553)
HTS :[Nahviintaas]: #1 = 22.427s (-11812.454)
HTS :[Nahviintaas]: #1 = 22.532s (-11812.349)
HTS :[Nahviintaas]: #1 = 22.634s (-11812.247)
HTS :[Nahviintaas]: #1 = 22.748s (-11812.133)
HTS :[Nahviintaas]: #1 = 22.850s (-11812.031)
HTS :[Nahviintaas]: #1 = 22.958s (-11811.923)
Portal Enter [@Shaqqun].
Portal Enter [@Thelperion].
Portal Enter [@Alvinguard].
HTS :[Nahviintaas]: #2 = 20.258s (-11924.918)
HTS :[Nahviintaas]: #2 = 20.375s (-11924.801)
HTS :[Nahviintaas]: #2 = 20.476s (-11924.7)
HTS :[Nahviintaas]: #2 = 20.578s (-11924.598)
HTS :[Nahviintaas]: #2 = 20.680s (-11924.496)
HTS :[Nahviintaas]: #2 = 20.788s (-11924.388)
HTS :[Nahviintaas]: #2 = 20.899s (-11924.277)
HTS :[Nahviintaas]: #2 = 20.993s (-11924.183)
HTS :[Nahviintaas]: #2 = 21.094s (-11924.082)
HTS :[Nahviintaas]: #2 = 21.209s (-11923.967)
HTS :[Nahviintaas]: #2 = 21.311s (-11923.865)
HTS :[Nahviintaas]: #2 = 21.420s (-11923.756)
HTS :[Nahviintaas]: #2 = 21.520s (-11923.656)
HTS :[Nahviintaas]: #2 = 21.611s (-11923.565)
HTS :[Nahviintaas]: #2 = 21.718s (-11923.458)
HTS :[Nahviintaas]: #2 = 21.818s (-11923.358)
HTS :[Nahviintaas]: #2 = 21.921s (-11923.255)
HTS :[Nahviintaas]: #2 = 22.023s (-11923.153)
HTS :[Nahviintaas]: #2 = 22.133s (-11923.043)
HTS :[Nahviintaas]: #2 = 22.229s (-11922.947)
HTS :[Nahviintaas]: #2 = 22.348s (-11922.828)
HTS :[Nahviintaas]: #2 = 22.438s (-11922.738)
HTS :[Nahviintaas]: #2 = 22.532s (-11922.644)
HTS :[Nahviintaas]: #2 = 22.637s (-11922.539)
HTS :[Nahviintaas]: #2 = 22.740s (-11922.436)
HTS :[Nahviintaas]: #2 = 22.856s (-11922.32)
Portal Exit [@Shaqqun].
Portal Exit [@Thelperion].
Portal Exit [@Alvinguard].
Portal Enter [@Shaqqun].
Portal Enter [@Thelperion].
Portal Enter [@Alvinguard].
HTS :[Nahviintaas]: #3 = 20.742s (-12040.271)
HTS :[Nahviintaas]: #3 = 20.873s (-12040.14)
HTS :[Nahviintaas]: #3 = 20.977s (-12040.036)
HTS :[Nahviintaas]: #3 = 21.077s (-12039.936)
HTS :[Nahviintaas]: #3 = 21.193s (-12039.82)
HTS :[Nahviintaas]: #3 = 21.295s (-12039.718)
HTS :[Nahviintaas]: #3 = 21.410s (-12039.603)
HTS :[Nahviintaas]: #3 = 21.508s (-12039.505)
HTS :[Nahviintaas]: #3 = 21.624s (-12039.389)
HTS :[Nahviintaas]: #3 = 21.722s (-12039.291)
HTS :[Nahviintaas]: #3 = 21.825s (-12039.188)
HTS :[Nahviintaas]: #3 = 21.922s (-12039.091)
HTS :[Nahviintaas]: #3 = 22.030s (-12038.983)
HTS :[Nahviintaas]: #3 = 22.135s (-12038.878)
HTS :[Nahviintaas]: #3 = 22.246s (-12038.767)
HTS :[Nahviintaas]: #3 = 22.345s (-12038.668)
HTS :[Nahviintaas]: #3 = 22.452s (-12038.561)
HTS :[Nahviintaas]: #3 = 22.566s (-12038.447)
HTS :[Nahviintaas]: #3 = 22.665s (-12038.348)
HTS :[Nahviintaas]: #3 = 22.772s (-12038.241)
HTS :[Nahviintaas]: #3 = 22.879s (-12038.134)
Portal Exit [@Alvinguard].
Portal Exit [@Shaqqun].
Portal Exit [@Thelperion].
Portal Enter [@Shaqqun].
Portal Enter [@Thelperion].
Portal Enter [@Alvinguard].
HTS :[Nahviintaas]: #4 = 20.604s (-12161.73)
HTS :[Nahviintaas]: #4 = 20.758s (-12161.576)
HTS :[Nahviintaas]: #4 = 20.857s (-12161.477)
HTS :[Nahviintaas]: #4 = 20.957s (-12161.377)
HTS :[Nahviintaas]: #4 = 21.064s (-12161.27)
HTS :[Nahviintaas]: #4 = 21.189s (-12161.145)
HTS :[Nahviintaas]: #4 = 21.281s (-12161.053)
HTS :[Nahviintaas]: #4 = 21.394s (-12160.94)
HTS :[Nahviintaas]: #4 = 21.503s (-12160.831)
HTS :[Nahviintaas]: #4 = 21.594s (-12160.74)
HTS :[Nahviintaas]: #4 = 21.698s (-12160.636)
HTS :[Nahviintaas]: #4 = 21.803s (-12160.531)
HTS :[Nahviintaas]: #4 = 21.914s (-12160.42)
HTS :[Nahviintaas]: #4 = 22.031s (-12160.303)
HTS :[Nahviintaas]: #4 = 22.134s (-12160.2)
HTS :[Nahviintaas]: #4 = 22.238s (-12160.096)
HTS :[Nahviintaas]: #4 = 22.335s (-12159.999)
HTS :[Nahviintaas]: #4 = 22.461s (-12159.873)
HTS :[Nahviintaas]: #4 = 22.552s (-12159.782)
HTS :[Nahviintaas]: #4 = 22.658s (-12159.676)
HTS :[Nahviintaas]: #4 = 22.758s (-12159.576)
HTS :[Nahviintaas]: #4 = 22.873s (-12159.461)
Portal Exit [@Shaqqun].
Portal Exit [@Thelperion].
Portal Exit [@Alvinguard].
]]
