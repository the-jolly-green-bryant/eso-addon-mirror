  -------------------------------------------------------
  -- Idle Animations - Main File
  -- Stratejacket (Tierney11290) & @senorblackbean - 2017 & @FischyJones (FranklyBatman) 2020
  -------------------------------------------------------

 
IA = IA or {}
IA.appName = "IdleAnimations"

local isDebugging = false
local function logdebug(msg)
  if not isDebugging then return end
  d(GetTimeString() .. ': ' .. tostring(msg))
end    


function Keys(var)
  -- Functionally the equivalent of dict.keys() in Python
  if not var then return {} end
  local varkeys = {}
  local i = 1
  for k, v in pairs(var) do
    varkeys[i] = k
    i = i + 1
  end
  table.sort(varkeys)
  return varkeys
end


-- Just a utility function to dump emote information.  Output may exceed chat window buffer.
function IA.EmoteListAll()
  local i = 0
  local maxnum = GetNumEmotes()
  while i < maxnum do
    local emoteSlashName, emoteCategory, emoteId, desc, enabled = GetEmoteInfo(i)
    if emoteSlashName ~= "[Empty String]" then
      d(tostring(emoteSlashName) .. ' ' .. tostring(emoteCategory) .. ' "' .. tostring(desc) .. '" ' .. tostring(enabled))
    end
    i = i + 1
  end
end


local function GetRandomEmoteByProfile(profile)
  -- emote set of profile to run
  if not profile then return end

  local profileset = profile

  if profile == "Random" then
    -- Select the random profile to use
    local keylen = #Keys(emotes)
    if not keylen then return end
    local i2 = math.random(keylen)
    for i1,k in ipairs(Keys(emotes)) do
      if i1 == i2 then
        profileset = k
        break
      end
    end
  end

  keylen = #Keys(emotes[profileset])
  if not keylen then d(IA.appName .. ': Error: Empty profile set "' .. profileset .. '".') return end
  i2 = math.random(keylen)
  for i1, k in ipairs(Keys(emotes[profileset])) do
    if i1 == i2 then
      emoteset = k
      break
    end
  end
  if not emoteset then d(IA.appName .. ': Error: no emoteset?') return {} end

  result = emotes[profileset][emoteset]

  -- Check if the emoteset is disabled, return if not.
  for _, k1 in ipairs(Keys(IA.SVA.DisabledEmotesets)) do
    if k1 == profileset then
      for _, k2 in ipairs(Keys(IA.SVA.DisabledEmotesets[profileset])) do
        if k2 == emoteset then
          -- This one is disabled, fetch another!
          logdebug('Tried to use ' .. emoteset .. ', but it was disabled.')
          result = GetRandomEmoteByProfile(profileset)
        end
      end
    end
  end

  return result
end


-- is the player idle (not moving, not in stealth, not in combat)?
local isPlayerIdle = false
-- status for when the script is emoting versus when a player is emoting
local isIAEmoting = false
-- isEligible is an internal check to keep the auto-emotes suppressed if the player emotes while stealthed, then moves, and the script thinks its ok to start emoting again
local isEligible = true

local function PlayEmote()
  if not IA.SVC.IdleProfile then return end
  if not emotes then return end
  if not isEligible then return end
  if IsMounted() == true then return end
  
  local delay = 0

  for i, v in ipairs(GetRandomEmoteByProfile(IA.SVC.IdleProfile)) do
    if type(v) == "number" then
      delay = v
    elseif delay < IA.SVC.AnimTime then
      -- do not queue emotes after the animtime triggers the next emoteset
      logdebug('emote to run ' .. v .. ' delay ' .. delay )
      zo_callLater(
        function()
          isIAEmoting = true
          logdebug('calllater-playemote '.. tostring(v) .. ' status isPlayerIdle ' .. tostring(isPlayerIdle) .. ' isSJIEmoting ' .. tostring(isIAEmoting) .. ' isEligible ' .. tostring(isEligible))
          DoCommand(v)
          isIAEmoting = false
        end
        , delay
      )
    end
  end

  -- Call /idle to force animation pause between sets.
  if isPlayerIdle and IA.SVC.AnimPause > 0 then
    logdebug('halt in ' .. IA.SVC.AnimTime)
    zo_callLater(
      function()
        if isPlayerIdle and isElegible then 
          isIAEmoting = true
          DoCommand("/idle")
          logdebug('HALT /idle')
          isIAEmoting = false
        end
      end
      , IA.SVC.AnimTime
    )
  end
end

local px, py = GetMapPlayerPosition("player")
local function isPlayerMoving()
  local x, y = GetMapPlayerPosition("player")
  if px ~= x or py ~= y then
    -- Update position
    logdebug('player moved')
    px, py = x,y
    return true
  else
    return false
  end
end

local function OnPlayEmoteByIndex(index)
  -- This function is called when a player emotes, before the emote command runs.  If the player emoted, restart the timer and return false (continue emote) or return to prevent the emote.
  -- return of true prevents the emote, false allows it (zos logic)
  
  -- Should not emote if interacting, usually
  local interactiontype = GetInteractionType()
  if interactiontype ~= INTERACTION_NONE and interactiontype ~= INTERACTION_LOOT and interactiontype ~= INTERACTION_MAIL then return true end
  
  logdebug('onplayemotebyindex status isPlayerIdle ' .. tostring(isPlayerIdle) .. ' isSJIEmoting ' .. tostring(isIAEmoting) .. ' isEligible ' .. tostring(isEligible))

  -- An emote occurred, decide what to do if idle or not
  if isPlayerIdle then
    logdebug('and is idle')
    isPlayerIdle = true
  else
    logdebug('is not idle, not eligible')
    isEligible = false
  end

  -- Decide to allow the emote or not, depending on idle and script state.
  if isPlayerIdle and isIAEmoting then
    logdebug('player is idle and IA is emoting')
    return false
  elseif isPlayerIdle and not isIAEmoting then
    logdebug('player is no longer idle and emoting')
    isPlayerIdle = false
    isEligible = false
    -- update player location in case they just moved before emoting
    isPlayerMoving()
    return false
  elseif not isPlayerIdle and isIAEmoting then
    logdebug('not idle but script is running, do not emote')
    return true
  else
    logdebug('player not idle emoted again, do nothing')
    isEligible = false
    -- update player location in case they just moved before emoting
    isPlayerMoving()
    return false
  end
end
ZO_PreHook("PlayEmoteByIndex", OnPlayEmoteByIndex)


 -- Idle Detection
local function IdleAnimation()
  if not IA.SVC.IdleProfile then return end

  -- Are we idle?
  if isPlayerMoving() then
    logdebug("not idle, is moving")
    isPlayerIdle = false
    isEligible = true
  elseif isEligible then
    logdebug("player not moving, may be idle")
    isPlayerIdle = true
    logdebug('PlayEmote()')
    PlayEmote()
  end

  -- Decide when to check again
  logdebug('idleanimation status isPlayerIdle ' .. tostring(isPlayerIdle) .. ' isSJIEmoting ' .. tostring(isIAEmoting) .. ' isEligible ' .. tostring(isEligible))
  if isPlayerIdle and isEligible then
    logdebug('Continue in ' .. (IA.SVC.AnimTime + IA.SVC.AnimPause))
    IA.endTimer()
    IA.startTimer(IA.SVC.AnimTime + IA.SVC.AnimPause)
  else
    IA.endTimer()
    IA.startTimer(IA.SVC.IdleTime)
  end
end


-- Stealth Detection
local function OnStealthChange(eventCode, unitTag, stealthState) 
  -- When logging in stealthed, IA.SVC will be nil at this moment.
  if not IA.SVC then return end
  if not IA.SVC.IdleProfile then return end

  if unitTag ~= "player"  then return end
  
  if stealthState ~= STEALTH_STATE_NONE then
    -- in stealth
    isPlayerIdle = false
    isEligible = false
    IA.endTimer()
  else
    IA.endTimer()
    isEligible = true
    IA.startTimer(IA.SVC.IdleTime)
  end
end

EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_STEALTH_STATE_CHANGED, OnStealthChange)


-- Combat Detection
local function OnPlayerCombatState(event, inCombat)
  if inCombat then
    isEligible = false
    isPlayerIdle = false
    IA.endTimer()
  else
    IA.endTimer()
    isEligible = true
    IA.startTimer(IA.SVC.IdleTime)
  end
end

EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)

--Crafting Station Detection
local function OnCraftingStationStart(craftSkill, sameStation)
  IA.endTimer()
end

local function OnCraftingStationEnd()
  IA.endTimer()
  IA.startTimer(IA.SVC.IdleTime)
end

EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_CRAFTING_STATION_INTERACT, OnCraftingStationStart)
EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_END_CRAFTING_STATION_INTERACT, OnCraftingStationEnd)


local scenes = {}
function IA.noCameraSpin()
  -- Not going to lie, totally ripped off from "No Thank You".  Credits to Garkin.
  -- Would rather just use NTY, but people didn't want to load it and wanted this feature. Le sigh.
  local emotesFragments = {
    FRAME_PLAYER_FRAGMENT,
    FRAME_EMOTE_FRAGMENT_INVENTORY,
    FRAME_EMOTE_FRAGMENT_SKILLS,
    FRAME_EMOTE_FRAGMENT_JOURNAL,
    FRAME_EMOTE_FRAGMENT_MAP,
    FRAME_EMOTE_FRAGMENT_SOCIAL,
    FRAME_EMOTE_FRAGMENT_AVA,
    FRAME_EMOTE_FRAGMENT_SYSTEM,
    FRAME_EMOTE_FRAGMENT_LOOT,
    FRAME_EMOTE_FRAGMENT_CHAMPION,
  }
  
  local blacklistedScenes = {
    market = true,
    crownCrateGamepad = true,
    crownCrateKeyboard = true,
    keyboard_housing_furniture_scene = true,
    gamepad_housing_furniture_scene = true,
    dyeStampConfirmationGamepad = true,
    dyeStampConfirmationKeyboard = true,
	outfitStylesBook = true,
  }
  
  if IA.SVA.noCameraSpin then
    for name, scene in pairs(SCENE_MANAGER.scenes) do
      if not blacklistedScenes[name] then
        local sceneToSave = true
        for _, fragmentToRemove in ipairs(emotesFragments) do
          if scene:HasFragment(fragmentToRemove) then
            scene:RemoveFragment(fragmentToRemove)
            if sceneToSave then
              sceneToSave = false
              scenes[name] = scene
              scenes[name].toRestore = {}
            end
            table.insert(scenes[name].toRestore, fragmentToRemove)
          end
        end
      end
    end
	logdebug("Camera spinning disabled.")
  else
    for name, scene in pairs(scenes) do
      if scene.toRestore then
        for index, fragment in ipairs(scene.toRestore) do
          scene:AddFragment(fragment)
        end
      end
    end
	logdebug("Camera spinning enabled.")
  end
end


-- Functions for our Event Emotes
function IA.LevelUp(event)
  if IA.SVA.LevelUp then
    SLASH_COMMANDS["/cheer"]()
  end
end

function IA.AvARankUp()
  if IA.SVA.AvARankUp then
    SLASH_COMMANDS["/whistle"]()
  end
end

function IA.LoreBookCollection()
  if IA.SVA.LoreBookCollection then
    SLASH_COMMANDS["/clap"]()
  end
end

function IA.LoreBook()
  if IA.SVA.LoreBook then
    SLASH_COMMANDS["/approve"]()
  end
end

function IA.ChampionPoint()
  if IA.SVA.ChampionPoint then
    SLASH_COMMANDS["/cheer"]()
  end
end

function IA.PledgeMaraOffer()
  if IA.SVA.PledgeMaraOffer then
    SLASH_COMMANDS["/flirt"]()
  end
end

function IA.PledgeMaraResult()
  if IA.SVA.PledgeMaraResult then
    SLASH_COMMANDS["/blowkiss"]()
  end
end

function IA.BankBought()
  if IA.SVA.BankBought then
    SLASH_COMMANDS["/applaud"]()
  end
end

function IA.BagBought()
  if IA.SVA.BagBought then
    SLASH_COMMANDS["/applaud"]()
  end
end

function IA.Avenge()
  if IA.SVA.Avenge then
    SLASH_COMMANDS["/comehere"]()
  end
end

-- Initialization for Events
function IA:Initialize()
  -- math.random is bad, so let's try to do a good seed
  math.randomseed( tonumber(tostring(GetGameTimeMilliseconds()):reverse():sub(1,6)) )
  EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_LEVEL_UPDATE, IA.LevelUp)
  EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_VETERAN_RANK_UPDATE, IA.AvARankUp)
  EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_LORE_COLLECTION_COMPLETED , IA.LoreBookCollection)
  EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_CHAMPION_POINT_GAINED, IA.ChampionPoint)
  EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_PLEDGE_OF_MARA_OFFER, IA.PledgeMaraOffer)
  EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_PLEDGE_OF_MARA_RESULT, IA.PledgeMaraResult)
  EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_PLEDGE_OF_MARA_OFFER, IA.PledgeMaraOffer)
  EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_PLEDGE_OF_MARA_RESULT, IA.PledgeMaraResult)
  EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_INVENTORY_BOUGHT_BANK_SPACE, IA.BankBought)
  EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_INVENTORY_BOUGHT_BAG_SPACE, IA.BagBought)  
  EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_AVENGE_KILL, IA.Avenge)
  IA.startTimer(IA.SVC.IdleTime)
  --IA.noCameraSpin()
end


function IA.OnAddOnLoaded(event, addonName)
  -- Load our functions for Idle Status, LAM, and Saved Variables
  if addonName == IA.appName then
    local default = {
      Enabled = true,
      IdleProfile = "Normal",
      IdleTime = 25000,
      AnimTime = 30000,
      AnimPause = 0,
    }
    local defaults = {
      LevelUp = true,
      AvARankUp = true,
      LoreBookCollection = true,
      LoreBook = true,
      ChampionPoint = true,
      PledgeMaraOffer = true,
      PledgeMaraResult = true,
      BankBought = true,
      BagBought = true,
      Avenge = true,
      DisabledEmotesets = {},
      noCameraSpin = true,
    }
    IA.SVC = ZO_SavedVars:New("IdleAnimations_SavedVariables", 1, nil, default)
    IA.SVA = ZO_SavedVars:NewAccountWide("IdleAnimations_SavedVariables", 1, nil, defaults)
    IA.CreateSettingsMenu()
    IA:Initialize()
	-- force nocameraspin
	IA.noCameraSpin()
  end
end


function IA.startTimer(delay)
  logdebug('startTimer at ' .. delay .. ' en ' .. tostring(IA.SVC.Enabled))
  if IA.SVC.Enabled then
    EVENT_MANAGER:RegisterForUpdate("IdleAnimation", delay, function() IdleAnimation() end)
  else 
    IA.endTimer()
  end
end


function IA.endTimer()
  logdebug('endTimer')
  EVENT_MANAGER:UnregisterForUpdate("IdleAnimation")
end


local function setProfile(arg1)
  if arg1 == nil or arg1 == "" then
    if IA.SVC.Enabled then
      d("/ia <Profile Name, on, or off>.  Your current profile is: " .. IA.SVC.IdleProfile)
    else
      d("/ia <Profile Name, on, or off>.  Currently disabled.")
    end
    return
  end

  if arg1 == "on" then
    d(IA.appName .. ': Enabled with "' .. IA.SVC.IdleProfile .. '" profile.')
    IA.SVC.Enabled = true
    IA.startTimer(IA.SVC.IdleTime)
  elseif arg1 == "off" then
    d(IA.appName .. ': Disabled.  Use "/ia on" to turn back on.')
    IA.SVC.Enabled = false
    IA.endTimer()
  elseif arg1 == "random" then
    IA.SVC.IdleProfile = "Random"
    d(IA.appName .. ': Profile set to "' .. IA.SVC.IdleProfile .. '".')
    --reload
    IA.endTimer()
    IA.startTimer(IA.SVC.IdleTime)
  elseif arg1 == "debug" then
    if isDebugging then
      isDebugging = false
    else
      -- drink from the fire hose
      isDebugging = true
    end
  else
    for i, v in ipairs(Keys(emotes)) do
      if string.lower(arg1) == string.lower(v) then
        IA.SVC.IdleProfile = v
        d(IA.appName .. ': Profile set to "' .. IA.SVC.IdleProfile .. '".')
        --reload
        IA.endTimer()
        IA.startTimer(IA.SVC.IdleTime)
        break
      end
    end
  end
end

SLASH_COMMANDS["/ia"] = setProfile

EVENT_MANAGER:RegisterForEvent(IA.appName, EVENT_ADD_ON_LOADED, IA.OnAddOnLoaded)