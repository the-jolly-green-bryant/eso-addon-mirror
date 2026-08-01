--IDEA
--[[    local params = {...}
    local paramTable = ERG.GetEventParameterNames( params[1] )

    local changeType = params[ paramTable["changeType"] ]
    local unitTag = params[ paramTable["unitTag"] ]]

--TODO Default color, icons, sounds, actions
--TODO select a few sounds
--TODO update profile for new options
--TODO go over everything and execute callbacks from table
--TODO Synchronize CD in one panel (or in all panel???4)


--IDEA bahsei panels: portal as existing; predictions panel (sun, sickle, cursed ground, aoe);  debuff banel; "RaidLead"-Panel (Boss HP, adds alive?!-- maybe just boss HP with thresholds)

--TODO change location defaults, so panels dont overlap (be on same position)

Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.name = "ExoYsRockgroover"

ERG.mehrunesIcon = "/esoui/art/icons/achievement_u30_flavor1.dds"
ERG.mehrunesIconBW = "/esoui/art/icons/heraldrycrests_daedra_mehronesdagon_01.dds"

ERG.displayName = "|c00FF00ExoY|rs Rockgroover"
ERG.displayNameWithIcon = zo_strformat( "<<1>>|t35:35:<<2>>|t", ERG.displayName, ERG.mehrunesIconBW )
ERG.author = "@|c00FF00ExoY|r94 (PC/EU)"
ERG.version = "0.3.6"

ERG.rgZone = 1263

ERG.EM = GetEventManager()
ERG.WM = GetWindowManager()

------------------
-- AddOn Loaded --
------------------

local function OnAddOnLoaded(_, addonName)
  if addonName == ERG.name then
    ERG.initialized = false
		ERG.Initialize()
    ERG.initialized = true
    ERG.EM:UnregisterForEvent(ERG.name, EVENT_ADD_ON_LOADED)
  end
end

EVENT_MANAGER:RegisterForEvent(ERG.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

----------------
-- Initialize --

function ERG.Initialize()
  ERG.initialized = false
  ERG.arena = {boss = "", hm = false}
  ERG.demo = ""
  ERG.charId = GetCurrentCharacterId()

  -- saved variables
  ERG.SV = ZO_SavedVars:NewAccountWide("ERGSV", 0, nil, ERG.GetDefaults(), "Rockgroove")
  ERG.profiles.SetCurrent( ERG.profiles.GetCurrentNum() )

  --initialize
  for _, entry in ipairs( ERG.GetAllMainLists() ) do
    local init = ERG[entry].Initialize or nil
    if type(init) == "function" then
      init()
    end
  end

  -- cca interface
  --ERG.CCA_Data = ZO_DeepTableCopy(CombatAlertsData.rg)
  --ERG.Update_CCA_Settings()

  -- variables and tables
  ERG.combat = { state = false } --TODO initial values

  --addon menu
  ERG.InitializeTooltips()
  ERG.CreateMenu()

  -- basic events
  ERG.EM:RegisterForEvent(ERG.name.."InitialPlayerActivated", EVENT_PLAYER_ACTIVATED, ERG.OnInitialPlayerActivated)
  ERG.EM:RegisterForEvent(ERG.name.."CombatState", EVENT_PLAYER_COMBAT_STATE, ERG.OnPlayerCombatState)
  ERG.EM:RegisterForEvent(ERG.name.."OnDisplayAnnouncement", EVENT_DISPLAY_ANNOUNCEMENT, ERG.OnDisplayAnnouncement)
  ERG.EM:RegisterForEvent(ERG.name.."BossChanged", EVENT_BOSSES_CHANGED, ERG.OnBossesChanged)

  ERG.EM:RegisterForUpdate(ERG.name.."Update", 100, ERG.OnUpdate)
end


function ERG.GetDefaults()
  local defaults = {
    profileManager = { [ERG.charId] = 1 },
    profiles = { ERG.profiles.GetDefaults("Groover") },
    welcome = true,
    showAbilityName = true,
    showIconWithAlerts = true,
  }
  return defaults
end

------------
-- Update --
------------

function ERG.OnUpdate()
  for _, encounter in ipairs( ERG.GetEncounterList() ) do
    local update = ERG[encounter].OnUpdate or nil
    if type(update) == "function" then
      update()
    end
  end
end

-------------------------
-- On Player Activated --
-------------------------

function ERG.OnInitialPlayerActivated()
  ERG.lastZone = 0

  ERG.EM:UnregisterForEvent(ERG.name.."InitialPlayerActivated", EVENT_PLAYER_ACTIVATED)

  ERG.OnPlayerActivated()
  ERG.EM:RegisterForEvent(ERG.name.."PlayerActivated", EVENT_PLAYER_ACTIVATED, ERG.OnPlayerActivated)
end


function ERG.OnPlayerActivated()
  local currentZone = GetZoneId(GetUnitZoneIndex("player"))
  if currentZone ~= ERG.lastZone and currentZone == ERG.rgZone and ERG.SV.welcome then
    local welcomeMessageList = ERG.GetWelcomeMessageList()
    local major = welcomeMessageList[ERG.GetRandomNumber(#welcomeMessageList, true, false)]
    major = ERG.AddIconToString(major, ERG.mehrunesIcon, 44, true)
    major = ERG.AddIconToString(major, ERG.mehrunesIcon, 44, false)
    local profileName = ERG.profiles.GetList()[ERG.profiles.GetCurrentNum()]
    local minor = "Selected Profile: "..profileName
    ERG.CreateCSA(major, minor, 4000)
  end
  ERG.lastZone = currentZone

  -- to ensure there are no panels visible outside of boss fight
  ERG.OnBossesChanged()
  if IsUnitInCombat("player") then ERG.OnPlayerCombatState(_, true) end
end


----------------------------
-- On Player Combat State --
----------------------------

function ERG.OnPlayerCombatState(_, inCombat)
  local function OnCombatStateChange( combatState )
    ERG.combat.state = combatState
    for _, entry in ipairs( ERG.GetAllMainLists() ) do
      if combatState then
        local func = ERG[entry].OnCombatStart
        if type(func) == "function" then func() end
      else
        local func =  ERG[entry].OnCombatEnd
        if type(func) == "function" then func() end
      end
    end
  end

  -- detect combat changes
  if ERG.combat.callback and inCombat then
    zo_removeCallLater(ERG.combat.callback)
    return
  end
  if ERG.combat.callback and not inCombat then
    zo_removeCallLater(ERG.combat.callback)
  end
  if not inCombat then
    ERG.combat.callback = zo_callLater( function()
      ERG.combat.callback = nil
      OnCombatStateChange( false )
    end, 1000)
  end
  if inCombat then
    OnCombatStateChange( true )
  end

end

-------------------
-- Panel Control --
-------------------

local function OnHardmodeChange(boss, isHm)
  if not ERG[boss].OnHardmodeChange then return end
  ERG[boss].OnHardmodeChange(isHm)
end

local function HideAllPanels()
  for _, boss in pairs( ERG.GetBossList() ) do
    for _, frag in pairs( ERG[boss].GetFragList( true ) ) do
      HUD_UI_SCENE:RemoveFragment( frag )
      HUD_SCENE:RemoveFragment( frag )
    end
    OnHardmodeChange(boss, false)
  end
end

local function ShowPanels(boss, all)
  HideAllPanels() -- making sure, only the correct panels are visible
  for _, frag in pairs( ERG[boss].GetFragList(all) ) do
    HUD_UI_SCENE:AddFragment( frag )
    HUD_SCENE:AddFragment( frag )
  end
end

-----------------------------
-- Demo Panel for Settings --
-----------------------------

function ERG.DemoPanel(boss)
  HideAllPanels()
  if ERG.demo ~= boss then
    ShowPanels(boss, true)
    OnHardmodeChange(boss, true)
    ERG.demo = boss
  else
    ERG.demo = ""
  end
end

-----------------------
-- Detect Boss Arena --
-----------------------

function ERG.AnalyseBossSituation()
  local current, maxHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
  if current == 0 or maxHP == 0 then
    ERG.ClearArena()
    return
  end

  local boss = ERG.GetBossHpList()[maxHP]
  local isHm = ERG.GetHardmodeHpList()[maxHP]

  if not boss then return end
  if boss == ERG.arena.boss and isHm == ERG.arena.hm then return end
  if boss ~= ERG.arena.boss then
    ShowPanels(boss)
    ERG.arena.boss = boss
  end
  if isHm ~= ERG.arena.hm then
    OnHardmodeChange(boss, isHm )
    ERG.arena.hm = isHm
  end
end


function ERG.ClearArena()
  ERG.arena.boss = nil
  ERG.arena.hm = false
  HideAllPanels()
end


function ERG.OnBossesChanged()
  if not ERG.IsPlayerInRockgrove() then
    if ERG.arena.boss then ERG.ClearArena() end
    return
  end
  ERG.AnalyseBossSituation()
end


function ERG.OnDisplayAnnouncement()
  if not ERG.IsPlayerInRockgrove() then return end
  zo_callLater(function() ERG.AnalyseBossSituation() end, 1000) -- wait for hardmode to take effect
end


---------------
-- Utilities --
---------------

function ERG.IsPlayerInRockgrove()
  return GetZoneId(GetUnitZoneIndex("player")) == ERG.rgZone and true or false
end

function ERG.GetCustomDifficulty() --TODO
  if not ERG.IsPlayerInRockgrove() then return 0 end
  if ERG.arena.hm then return 3 end
  if GetCurrentParticipatingRaidId() == 15 then return 2 end
  return 1
end

function ERG.GetRandomNumber(limit, includeLimit, allowZero)
  if includeLimit then limit = limit + 1 end
  if not allowZero then limit = limit - 1 end
  local rnd = GetGameTimeMilliseconds() % limit
  if not allowZero then rnd = rnd + 1 end
  return rnd
end


function ERG.GetRemainingMilliseconds(endTime)
  return zo_max(endTime - GetGameTimeMilliseconds(), 0)
end


function ERG.GetTimeRemaining( endTime, decimal, final )
  local timeRemaining = ERG.GetRemainingMilliseconds( endTime )/1000
  if not decimal then timeRemaining = math.floor(timeRemaining) end
  if timeRemaining == 0 then return final and final or "0" end
  if timeRemaining < 10 and decimal then
    return string.format( "%.1f", timeRemaining)
  else
    return string.format( "%.0f", timeRemaining)
  end
end


function ERG.ConvertDurationToClock( duration, InMilliseconds )
  local factor = InMilliseconds and 1000 or 1
  local timeUnits = {
    ["minutes"] = 60,
  }
  local result = {}
  for unit, ratio in pairs(timeUnits) do
    local inter = math.floor(duration/(ratio*factor) )
    result[unit] = inter > ratio and inter%ratio or inter
  end
  result.seconds = math.floor((duration/factor)%60)
  result.milliSeconds = InMilliseconds and duration%1000 or 0
  return result.minutes, result.seconds, result.milliSeconds
end


function ERG.ShortenString(originalString, length, suffix, startPosition ) --TODO work with string width instead of string len
  startPosition = startPosition or 1
  suffix = suffix or ".."
  if string.len(originalString) - startPosition < length then suffix = "" end --TODO test
  return zo_strformat("<<1>><<2>>", string.sub(originalString, startPosition, length), suffix)
end


function ERG.AddIconToString(string, icon, size, inFront)
  if type(icon) == "number" then
    icon = GetAbilityIcon(icon)
  end
  local iconStr = zo_strformat("|t<<2>>:<<2>>:<<1>>|t", icon, size)
  if inFront then
    return zo_strformat("<<1>> <<2>>", iconStr, string)
  else
    return zo_strformat("<<1>> <<2>>", string, iconStr)
  end
end


function ERG.ColorString( str, color)
  return string.format( "|c%s%s|r", ZO_ColorDef.FloatsToHex( unpack(color) ), str)
end


function ERG.GetCombatAlertsColor( color )
  return string.format( "0x%sff", ZO_ColorDef.FloatsToHex( unpack(color) ))
end


function ERG.GetFormattedAbilityName( abilityId )
  return zo_strformat( SI_ABILITY_NAME, GetAbilityName(abilityId) )
end


function ERG.GetFont( size )
  local font = "/EsoUI/Common/Fonts/Univers67.otf"
  local outline = "soft-shadow-thin"
  return string.format( "%s|%d|%s", font , size , outline )
end


function ERG.GetMenuAbilityName( id, mechanicData )
  local name = mechanicData[id].name
  local icon = mechanicData[id].icon
  return ERG.AddIconToString( name or ERG.GetFormattedAbilityName(id) ,icon or id, 32, true)
end

--------------------------------
-- Center Screen Announcement --
--------------------------------

--TODO Sound
--/script Rockgroover.CreateCSA("text", 3000)
function ERG.CreateCSA(major, minor, duration)
  local CSA = CENTER_SCREEN_ANNOUNCE
  local params = CSA:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
   -- params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
   params:SetText(major, minor)
   params:SetLifespanMS(duration)
   --params:MarkQueueImmediately(true)
   CSA:AddMessageWithParams(params)
end


--------------------------
-- Code's Combat Alerts --
--------------------------

function ERG.Update_CCA_Settings()
  for _, boss in ipairs( ERG.GetEncounterList() ) do
    if ERG[boss].Get_CCA_Settings then
      for mechanic, settings in pairs( ERG[boss].Get_CCA_Settings() ) do
        local enabled = ERG.store[boss].CCA_Settings[mechanic]

        if enabled then

          if settings.id then
            CombatAlertsData.rg[mechanic][settings.id] = ERG.CCA_Data[mechanic][settings.id]
          else
            CombatAlertsData.rg[mechanic] = ERG.CCA_Data[mechanic]
          end

        else -- not enabled
          if settings.id then
            CombatAlertsData.rg[mechanic][settings.id] = nil
          elseif type(CombatAlertsData.rg[mechanic]) == "table" then
            CombatAlertsData.rg[mechanic] = {}
          else
            CombatAlertsData.rg[mechanic] = nil
          end
        end

      end
    end
  end
end
