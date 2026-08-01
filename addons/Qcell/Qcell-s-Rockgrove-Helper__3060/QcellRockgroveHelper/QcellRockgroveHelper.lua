QRH = QRH or {}
local QRH = QRH

QRH.name     = "QcellRockgroveHelper"
QRH.version  = "6.8.2"
QRH.author   = "@Qcell"
QRH.active   = false

-- Notes: 

-- TODO: QoL   : Show addon text when players are pulled into the fight (reload, crash...)
-- TODO: BOSS 1: Predict poison based on distance to center of pools. Next poison will be in X and Y...
-- TODO: BOSS 2: Fix the number of players in portal.
-- TODO: BOSS 2: Health indicator for meteor.
-- TODO: BOSS 2: Duration of beam upstairs.
QRH.status = {
  lastDeathTouch = 0,
  verbose = false,
  xalvakka_volatile_last = 0, -- last seconds where the volatile shell mechanic happened
  currentBoss = "",
  is_xalvakka = false,
  is_hm_boss = false,
  is_oaxiltso = false,
  is_bahsei = false,
  is_olms = false,
  inCombat = false,
  poolLabelsEnabled = false,
  xalvakkaSplitLabelsEnabled = false,
  xalvakkaSplitLabelsLastFloorEnabled = false,
  -- TODO: Use consistently last or next, but not both.
  lastSavageBlitz = 0,
  lastPoisonSludge = 0,
  lastPoisonTracker = 0, -- needed to avoid when the event fires 3x
  lastCursedGround = 0,
  sludgeTracker1 = 0,
  sludgeTracker2 = 0,
  nextPortal = 0, -- Bahsei portal opening time
  selfDoNotPortalTime = 0,
  portalNumber = 1, -- 1 or 2
  numPlayersInPortal = 0,
  lastPortalClockwise = true,
  nextSickle = 0, -- Sickle towards MT
  nextSun = 0, -- Meteor Swarm time
  oaxiltso_pool_icons = {nil, nil, nil, nil},
  xalvakka_split_icons = {nil, nil, nil},
  xalvakka_split_icons_3 = {nil, nil, nil},

  -- Xalvakka
  nextXalvakkaJump = 0, -- Xalvakka jump
  numXalvakkaJump = 0,
  soulResonanceStart = 0,
  shellShield = 0,
  onBlob = false,
  
  nextMtExplosion = 0,
  mt_name = "qcell",
  
}
-- Default settings.
QRH.settings = {
  showOaxiltsoBlitz = true,
  showOaxiltsoPoison = true,
  showOaxiltsoPoisonedPlayers = true,
  showOaxiltsoMeteorBlock = true,
  showOaxiltsoCleaveDodgeBar = true,
  showOaxiltsoPoolIcons = true,
  
  showBahseiNextCurse = true,
  showBahseiNextPortal = true,
  showBahseiPlayersInPortal = false,
  showBahseiPortalDebuff = true,
  showBahseiNextSickle = true,
  showBahseiNextSun = true,
  
  showBahseiInterruptForTanks = true,
  showBahseiSlamForTanks = true,
  showBahseiTankExploding = true,
  showBahseiDeathTouchCountdown = true,
  showBahseiSunProgressBar = true,
  
  showXalvakkaRunTimer = true,
  showXalvakkaJumpTimer = true,
  showXalvakkaShieldValue = true,
  showXalvakkaPurgeNowAlert = true,
  showXalvakkaPurgeSoulTimer = true,
  showXalvakkaOnBlob = true,
  showXalvakkaSplitIcons = true,
  
  showTrashEarthquake = true,
  showTrashSunProgressBar = true,
  showTrashMoltenRainBar = true,
}
local qrhShields = {}
local deathTouchTracker = {}
local portalTracker = {}
QRH.units = {}
QRH.unitsTag = {}
QRH.data    = {

  -- Reaver (2 hander)
  reaver_sundering = 149524, -- Sun-Xan Reaver: marked for death on the tank
  reaver_earthquake = 149535, -- Sun-Xan Reaver: AOE high dot on the floor
  
  -- Bloodseeker (archer)
  bloodseeker_spray = 152472, -- Interruptible that looks like taking aim, hits many.
  bloodseeker_jump = 157252, -- The archer jumps to a new position. It casts it twice, on anchor 1, then anchor 2. (go + arrive)
  bloodseeker_takingaim = 152496,  -- takign aim, multi target. does not target "player"
  bloodseeker_takingaim2 = 157248,  -- fake id, does not happen
  
  
  -- Soulweaver (mage)
  soulweaver_shield = 149089, -- Soulweaver casts a shield on targets 8m around it
  soulweaver_remnant = 157466, -- When the shield is destroyed, it throws projectiles to the party
   

  -- Oaxiltso
	oaxiltso_blitz  = 149414, -- Oaxiltso: Savage Blitz
  oaxiltso_blitz_hm  = 157932, -- Oaxiltso: Savage Blitz HM (after 50% HP)
  oaxiltso_sludge = 149190, -- Oaxiltso: Noxious Sludge
  oaxiltso_chomp  = 149648, -- Oaxiltso: Ravenous Chomp -- Already in CCA
  
  oaxiltso_moltenearth = 149232, -- Oaxiltso: AOE heavy on the floor (dodge)
  oaxiltso_meteorcrash = 152365, -- Oaxiltso: meteor spawning mini?
  oaxiltso_claw = 149647, -- Oaxiltso: light attack. No alert
  
  
  -- Light attacks, no Alert.
  oaxiltso_annihilator_hack = 1,
  oaxiltso_annihilator_crush = 1,
  oaxiltso_annihilator_strike = 1,
  
  oaxiltso_annihilator_sunburst = 153181, -- Heavy
  oaxiltso_annihilator_emberchains = 152699, -- Chain far target (to kiter)
  oaxiltso_annihilator_cindercleave = 152688,  -- Cone that follows like Llothis.
  
  oaxiltso_enrage_boss = 152502, -- effect gained/faded when boss enrages
  oaxiltso_enrage_mini = 152503, -- effect gained/faded when any mini enrages
  
  oaxiltso_so_fresh = 152456, -- so fresh, so clean. 20s buff after cleansing
  debuff_oaxiltso_sludge = 157860,
  
  oaxiltso_entrance_left = {92710,35746,78130},
  oaxiltso_entrance_right = {87910,35745,77796},
  oaxiltso_exit_left = {92772,35757,81495},
  oaxiltso_exit_right = {87875,35756,81755},

  oaxiltso_pools = {{91603,35767,78323}, -- entrance left (HM banner)
                   {88065,35768,78664},  -- entrance right
                   {91973,35751,81764},  -- exit left (typical DD position)
                   {87733,35772,81384}}, -- exit right (kite cleansing)

  -- testing coordinates
  --[[xalvakka_split = {{78643, 12369+500, 69090}, -- entrance
                   {79970,12380+500,71293},    -- middle (other one)
                   {81005,12392+500,69619}},   -- exit
  ]]--
                   
  -- floor 2
  xalvakka_split = {{161658, 34494+500, 161179}, -- entrance
                   {159807,34500+500,158763},    -- middle (other one)
                   {158659,34494+500,160797}},   -- exit

  xalvakka_split_3 = {{161943, 38509+500, 159268}, -- entrance
                 {159803,38506+500,161564},    -- middle (other one)
                 {158790,38507+500,158695}},   -- exit

  xalvakka_split_labels = {"A", "B", "C"},

  -- replace oaxiltso_pools[i][2] for ..._render_y
  oaxiltso_pools_render_y = 36200,
  
  butcher_strike = 149313, -- Butcher: Quick Strike (places dot)
  butcher_stomp  = 149316, -- Butcher: Emblazing Stomp (cast)
  butcher_uppercut = 157471,  -- Butcher: Uppercut (heavy). Included in CCA.
  
  barbarian_rending = 149238, -- Barbarian: Rending Slash, very fast low-damage attack. no alert
  barbarian_rampage = 149271, -- Barbarian: Rampaging fire. Channels, and sends a fire to adds. no alert
  barbarian_leap = 149244,    -- Barbarian: Serrated Leap / Serrated Strike. no alert
                                 -- Adds receive "Fiery Remnant" and get a buff "Rampage"  for 15s.
  barbarian_assault1 = 149268, -- Barbarian: Hasted Assault. Barbarian jumps on group, players need to block it.
  barbarian_assault2 = 149261, -- Barbarian: Hasted Assault 2. Another id for the same thing.
  

  -- Fire Behemoth
  -- Strike, Hack and Crush are regular attacks, blocking them is fine.
  fire_behem_strike = 152385, -- no alert
  fire_behem_hack = 153350, -- no alert
  fire_behem_crush = 152383, -- no alert
  
  
  fire_behem_scalding = 153175, -- Fire Behemoth: Scalding places a strong dot if it hits (dodge)
  fire_behem_sunburst = 156982, -- Fire Behemoth: Sunburst is a slow heavy that leaves a fire AOE on the floor.
  

  torchcaster_flare = 156917, -- Torchcaster: Unknown. No alert
  torchcaster_blaze = 149570, -- Torchcaster: Channeled fire beam. No alert
  torchcaster_rune = 157474, -- Torchcaster: Unknown. No alert
  
  torchcaster_meteorcall = 152414, -- Torchcaster: Spawns a Prime Meteor. If not killed in 10s, wipe.


  ashtitan_cleave = 156995,  -- Ash Titan: heavy attack on the tank. Already in CCA.
  ashtitan_moltenrain = 157482, -- Ash Titan: Fire rain that DDs need to block/kite.
  
  ashtitan_lavabolt = 157479,  -- Ash Titan: Ranged fire spit to the tank. No alert
  ashtitan_fireswarm = 156946, -- Ash Titan: Frontal fire wave.  No alert
  

  -- BOSS 2: Bahsei 
  bahsei_carve = 150047, -- Light attack, no alert
  bahsei_slice = 150048, -- Light attack, no alert
  bahsei_salvo1 = 157123,  -- this is noisy, not helpful
  
  bahsei_sickle = 150067, -- Rare cast. No alert, 3 aoe curses on floor that place dot on tank.
  bahsei_rendflesh = 150065, -- Heavy attack. Already in CCA
  
  bahsei_salvo2 = 152463, -- Channeled skill, cast before channel begins.
  bahsei_cursedground = 152475, -- Spawn crystals that spread curse
  
  debuff_bahsei_death_touch = 150078, -- correct death touch
  --debuff_bahsei_death_touch = 61662, -- minor brutality, for testing
  debuff_bahsei_malignant_marrow = 153421, -- AKA don't portal twice
  debuff_bahsei_bitter_marrow = 153423, -- When a player enters portal
  
  -- Bahsei's Flesh Abomination
  bahsei_flesh_bash = 153180, -- light attack
  bahsei_flesh_hemorrhage = 150008, -- places a strong dot
  bahsei_flesh_rancidhammer = 149922, -- places a big aoe on the floor
  
  -- Bahsei's Fire Behemoth: Hack, Strike and Crush are all regular light attacks -> no ids listed, and no warnings.
  bahsei_firebehem_scalding = 153175, -- Bahsei's Fire Behemoth - light attack that places strong dot. Each mob casts it only once.
  bahsei_firebehem_sunburst = 156982, -- Bahsei's Fire Behemoth - Heavy attack
  
  bahsei_archer_icy_salvo = 157167, -- Interruptible taking aim with aoe on player
  
  eye_cw = 153517,
  eye_ccw = 153518,

  meteor_swarm = 155357, -- buff gained
  meteor_swarm_buff1 = 152820, -- on logs, on prime meteors
  meteor_swarm_buff2 = 152819, -- on logs, on prime meteors


  -- BOSS 3: Xalvakka
  xalvakka_eviscerate = 153444, -- Xalvakka: Scathing Evisceration. Initial heavy strike. Strike 0.
  xalvakka_eviscerate1 = 149180, -- Xalvakka: Scathing Evisceration. Strike 1
  xalvakka_eviscerate2 = 153448, -- Xalvakka: Scathing Evisceration. Strike 2
  xalvakka_eviscerate3 = 153450, -- Xalvakka: Scathing Evisceration. Strike 3.
  
  -- Both deadstars are cast, and all go to players.
  xalvakka_deadstar1 = 149386, -- Going to group
  xalvakka_deadstar2 = 149075, -- Going to MT

  -- TODO: Escape cast not showing as RESULT = ACTION_RESULT_BEGIN. Detect it by HP % to warn in advance instead.
  xalvakka_escape = 150837, -- Xalvakka: Escape. At 70% and 40% when Xalvakka runs upstairs.
  
  xalvakka_volatileshell1 = 150529,
  xalvakka_volatileshell2 = 149294,
  
  xalvakka_flame_portal = 157390, -- 4x Jumps on first floor
  
  xalvakka_soul_resonance_debuff = 152993, -- Debuff gained by players with a stack counter.
  xalvakka_unstable_charge_debuff = 153164, -- Debuff while staying on blob
  
  xalvakka_goliath_powerbash = 150308,
  xalvakka_manifold = 157281, -- xalvakka casting it, lasts 10s
  xalvakka_manifold_debuff = 157290, -- on players
  
  xalvakka_watcher_tentacle_whip_1 = 152760,
  xalvakka_watcher_tentacle_whip_2 = 152761,
  
  -- String lower, to make sure changes here keep strings
  -- in lowercase.
  oaxiltso_name = string.lower("Oaxiltso"),
  bahsei_name = string.lower("Bahsei"),
  xalvakka_name = string.lower("Xalvakka"),
  xalvakka_volatile_shell_name = string.lower("Volatile Shell"), -- Volatile Shell
  xalvakka_volatile_timer = 80, -- Every 1:20, 3 copies are spawned.

  --default_color = { 1, 0.7, 0, 0.5 },
  dodgeDuration = GetAbilityDuration(28549),
  maxDuration = 4000,
  holdBlock = "Hold Block!",
  rockgrove_id = 1263,
  
  -- Experimental
  innerRage = 42056,
  pierceArmor = 38250,
}

function QRH.IdentifyUnit( unitTag, unitName, unitId )
  -- 
	if (not QRH.units[unitId] and 
    (string.sub(unitTag, 1, 5) == "group" or string.sub(unitTag, 1, 6) == "player")) then
		QRH.units[unitId] = {
			tag = unitTag,
			name = GetUnitDisplayName(unitTag) or unitName,
		}
    QRH.unitsTag[unitTag] = {
      id = unitId,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
	end
end

-- [!] adjust label scale and draw order
local function AdjustLabelForIcon(icon)
    local order = icon.ctrl:GetDrawLevel() + 1
    icon.myLabel:SetDrawLevel( order )
end

-- check if osi is active and it supports positional icons
function QRH.hasOSI()
  return OSI and OSI.CreatePositionIcon
end

function QRH.UpdateIconTextControls(changeType, unitTag, beginTime, endTime)
  -- check if OdySupportIcons is active and the affected unit is a player
  if QRH.hasOSI() and IsUnitPlayer(unitTag) then
    -- retrieve the displayname of the affected player
    local displayName = GetUnitDisplayName( unitTag )
    -- [!] retrieve the icon object for the affected player
    local icon = OSI.GetIconForPlayer( displayName )
    if icon then
      -- [!] create a label control if no custom control is available
      if not icon.myLabel then
        icon.myLabel = icon.ctrl:CreateControl( icon.ctrl:GetName() .. "Label", CT_LABEL )
        icon.myLabel:SetAnchor( CENTER, icon.ctrl, CENTER, 0, 0 )
        icon.myLabel:SetFont( "$(BOLD_FONT)|$(KB_54)|outline" )
        icon.myLabel:SetScale(3)
        icon.myLabel:SetDrawLayer( DL_BACKGROUND )
        icon.myLabel:SetDrawTier( DT_LOW )
        icon.myLabel:SetColor(0.9,0.9,0.9,0.85)
      end
      -- [!] adjust label for icon
      AdjustLabelForIcon(icon)
      -- if the player gained the mechanic effect...
      if changeType == EFFECT_RESULT_GAINED then
        -- assign your icon to the affected player
        OSI.SetMechanicIconForUnit( displayName, MY_ICON, 2 * OSI.GetIconSize())
        -- [!] update custom label and show it
        icon.myLabel:SetText(tostring(zo_floor(endTime - beginTime)))
        icon.myLabel:SetHidden(false)
        -- [!] update custom timer
        icon.myTimer = endTime
      -- if the player lost the mechanic effect...
      elseif changeType == EFFECT_RESULT_FADED then
        -- remove your icon from the formerly affected player
        OSI.RemoveMechanicIconForUnit(displayName)
        -- [!] hide custom label
        icon.myLabel:SetHidden(true)
      end
    end
  end
end

function QRH.EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
  QRH.IdentifyUnit(unitTag, unitName, unitId)

  if abilityId == QRH.data.debuff_bahsei_death_touch then
    QRH.UpdateIconTextControls(changeType, unitTag, beginTime, endTime)
  end

  -- Known issue: you get the debuff, then 2s later you get it again.
  -- blue will disappear 2s early.
  if changeType == EFFECT_RESULT_GAINED and abilityId == QRH.data.debuff_bahsei_death_touch and unitTag == "player" then
    QRH.status.lastDeathTouch = GetGameTimeSeconds()
    CombatAlerts.AlertBorder(true, 9000, "blue")
  end

  -- Shouldn't be necessary, since it will fade on its own.
  --if changeType == EFFECT_RESULT_FADED and abilityId == QRH.data.debuff_bahsei_death_touch and unitTag == "player" then
    --CombatAlerts.AlertBorder(false, "blue")
  --end

  -- TODO: Separate GAINED/FADED to a separate method to avoid duplicity.
  if changeType == EFFECT_RESULT_GAINED and abilityId == QRH.data.oaxiltso_enrage_boss then
    QRHStatusLabelTitle1:SetHidden(false)
    -- show ENRAGED BOSS
  end

  if changeType == EFFECT_RESULT_GAINED and abilityId == QRH.data.oaxiltso_enrage_mini then
    -- show ENRAGED MINI
    QRHStatusLabelTitle2:SetHidden(false)
  end
  
  if changeType == EFFECT_RESULT_FADED and abilityId == QRH.data.oaxiltso_enrage_boss then
    QRHStatusLabelTitle1:SetHidden(true)
    -- hide ENRAGED BOSS
  end
  
  if changeType == EFFECT_RESULT_FADED and abilityId == QRH.data.oaxiltso_enrage_mini then
    -- hide ENRAGED MINI
    QRHStatusLabelTitle2:SetHidden(true)
  end
  

  -- Someone exited portal
  -- This runs 3 times.
  if changeType == EFFECT_RESULT_GAINED and abilityId == QRH.data.debuff_bahsei_malignant_marrow then
    local portalNewTime = GetGameTimeSeconds() + 50
    
    -- This buff will show up to 3 times, but we should only update it once.
    -- I guess it happens 3 times, so I could switch portalNumber 3 times and it's the
    -- same as switching it once. But for the sake of correctness...
    if portalNewTime > QRH.status.nextPortal + 5 then
      QRH.status.nextPortal = portalNewTime
      QRH.status.portalNumber = 3 - QRH.status.portalNumber -- alternate 1 and 2
      --d("[QRH] resetting numplayersInportal = 0")
      QRH.status.numPlayersInPortal = 0
    end
    if unitTag == "player" then
      QRH.status.selfDoNotPortalTime = GetGameTimeSeconds() + 120
    end
  end
  
  if changeType == EFFECT_RESULT_FADED and abilityId == QRH.data.debuff_bahsei_malignant_marrow and unitTag == "player" then
    QRH.status.selfDoNotPortalTime = 0
  end

  
  -- Dot/debuff of entering portal
  if changeType == EFFECT_RESULT_GAINED and abilityId == QRH.data.debuff_bahsei_bitter_marrow then
    QRH.status.numPlayersInPortal = QRH.status.numPlayersInPortal + 1
    --d("[QRH] numplayersInportal + 1 = " .. tostring(QRH.status.numPlayersInPortal))
    QRHStatusLabel5Value:SetText(tostring(QRH.status.numPlayersInPortal))
    portalTracker[unitId] = true
  end
  if changeType == EFFECT_RESULT_FADED and abilityId == QRH.data.debuff_bahsei_bitter_marrow then
    -- In case the no-portal-twice debuff triggers before players losing this buff.
    if QRH.status.numPlayersInPortal > 0 then
      QRH.status.numPlayersInPortal = QRH.status.numPlayersInPortal - 1
      --d("[QRH] numplayersInportal - 1 = " .. tostring(QRH.status.numPlayersInPortal))
    end
    portalTracker[unitId] = false
    QRHStatusLabel5Value:SetText(tostring(QRH.status.numPlayersInPortal)) 
  end

  if changeType == EFFECT_RESULT_GAINED and abilityId == QRH.data.oaxiltso_so_fresh then
    local world, px, py, pz = GetUnitWorldPosition(unitTag)
    local poolId = QRH.FindPool(px,py,pz)
    -- If the pool is correct, put it on cooldown for 25s...
    if QRH.hasOSI() then
      if poolId >= 1 and poolId <= 4 and QRH.status.oaxiltso_pool_icons[poolId] ~= nil then
        QRH.status.oaxiltso_pool_icons[poolId].myTimer = GetGameTimeSeconds() + 25
      end
    end
  end

  -- Sludge arrows
  if changeType == EFFECT_RESULT_GAINED and abilityId == QRH.data.debuff_oaxiltso_sludge then
    if QRH.hasOSI() then
      local texture = "QcellRockgroveHelper/icons/curse00.dds"
      local displayName = string.lower(GetUnitDisplayName(unitTag))
      OSI.SetMechanicIconForUnit(displayName, texture, 2 * OSI.GetIconSize())
    end
    local timeSec = GetGameTimeSeconds()
    -- When YOU get the poison, the event triggers 3 times, and this would replace tracker1 and 50% of the times not work
    if QRH.status.sludgeTracker1 == 0 then
      if timeSec - QRH.status.lastPoisonTracker > 10 then
        QRH.status.lastPoisonTracker = timeSec
        QRH.status.sludgeTracker1 = unitId
      end
    elseif unitId ~= QRH.status.sludgeTracker1 then -- some times player 1 shows twice
    -- TODO: filter result since the same player can show more than once.
      QRH.status.sludgeTracker2 = unitId
      local leftPlayer =  QRH.units[QRH.status.sludgeTracker1].name
      local rightPlayer = QRH.units[QRH.status.sludgeTracker2].name
      
      -- logic for picking sides.
      local leftTag = QRH.units[QRH.status.sludgeTracker1].tag
      local rightTag = QRH.units[QRH.status.sludgeTracker2].tag
      local lw, lx, ly, lz = GetUnitWorldPosition(leftTag)
      local rw, rx, ry, rz = GetUnitWorldPosition(rightTag)
      -- Distance to exit-left pool.
      local dLeft = QRH.GetDist(lx,ly,lz,
        QRH.data.oaxiltso_pools[3][1],
        QRH.data.oaxiltso_pools[3][2],
        QRH.data.oaxiltso_pools[3][3])

      local dRight = QRH.GetDist(rx,ry,rz,
        QRH.data.oaxiltso_pools[3][1],
        QRH.data.oaxiltso_pools[3][2],
        QRH.data.oaxiltso_pools[3][3])
      -- END logic for picking sides.
      if dLeft > dRight then
        local tmpPlayer = leftPlayer
        leftPlayer = rightPlayer
        rightPlayer = tmpPlayer
      end
      if QRH.savedVariables.showOaxiltsoPoisonedPlayers then
        CombatAlerts.Alert("", "<< " .. leftPlayer .. " << || >> " .. rightPlayer .. " >>", 0x00CC00D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 5000)
      end
      
      QRH.status.sludgeTracker1 = 0
      QRH.status.sludgeTracker2 = 0
    end
  end

  -- Death touch arrows
  if changeType == EFFECT_RESULT_GAINED and abilityId == QRH.data.debuff_bahsei_death_touch then
    local displayName = GetUnitDisplayName(unitTag)
    if displayName ~= nil then
      deathTouchTracker[displayName] = GetGameTimeSeconds()
    end
    if QRH.hasOSI() then
      local texture = "QcellRockgroveHelper/icons/curse00.dds"
      OSI.SetMechanicIconForUnit(displayName, texture, 2 * OSI.GetIconSize())
    end

    if displayName ~= nil then
      if string.match(displayName, QRH.status.mt_name) then
        QRH.status.nextMtExplosion = GetGameTimeSeconds() + 9
      end

      -- TODO: Verify if it works WITHOUT this change.
      local playerName = string.lower(GetUnitDisplayName("player"))
      if displayName == playerName then -- Checking unitTag == "player" doesn't seem to work.
        CombatAlerts.AlertBorder(true, 9000, "blue")
      end
    end
  end
  
  if changeType == EFFECT_RESULT_GAINED and abilityId == QRH.data.xalvakka_manifold_debuff then
    if QRH.hasOSI() then
      local texture = "QcellRockgroveHelper/icons/curse00.dds"
      local displayName = string.lower(GetUnitDisplayName(unitTag))
      OSI.SetMechanicIconForUnit(displayName, texture, 2 * OSI.GetIconSize())
    end
  end

  -- TODO: Remove it after the duration, since some people don't get the FADED event?
  if changeType == EFFECT_RESULT_FADED and (
    abilityId == QRH.data.debuff_bahsei_death_touch
    or abilityId == QRH.data.debuff_oaxiltso_sludge
    or abilityId == QRH.data.xalvakka_manifold_debuff) then
    if QRH.hasOSI() then
      local displayName = string.lower(GetUnitDisplayName(unitTag))
      OSI.RemoveMechanicIconForUnit(displayName)
    end
  end
  
  -- TODO: when you gain Bitter Marrow (153423) (you entered portal), disable the addon arrows. (iterate through group size, disable)
  -- People in portal can see arrows from above.
  
  -- ### BOSS 3 ###
  --
  -- The longer you keep the wraith soul with you, the more the dot ticks. (14k dot after 12s)
  if QRH.savedVariables.showXalvakkaPurgeNowAlert then
    if changeType == EFFECT_RESULT_GAINED and abilityId == QRH.data.xalvakka_soul_resonance_debuff and unitTag == "player" then
      QRH.status.soulResonanceStart = GetGameTimeSeconds()
      CombatAlerts.Alert("", "Purge your soul!", 0xB0E0E6D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    end
  end

  if changeType == EFFECT_RESULT_FADED and abilityId == QRH.data.xalvakka_soul_resonance_debuff and unitTag == "player" then
    -- Hide the soul counter before it gets updated to a timestamp.
    QRHStatusLabel8:SetHidden(true)
    QRHStatusLabel8Value:SetHidden(true)
    
    QRH.status.soulResonanceStart = 0
  end
  
  -- Staying on top of a Blob
  if changeType == EFFECT_RESULT_GAINED and abilityId == QRH.data.xalvakka_unstable_charge_debuff and unitTag == "player" then
    CombatAlerts.AlertBorder(true, 15000, "green")
    QRH.status.onBlob = true
  end
  
  if changeType == EFFECT_RESULT_FADED and abilityId == QRH.data.xalvakka_unstable_charge_debuff and unitTag == "player" then
    CombatAlerts.AlertBorder(false)
    QRH.status.onBlob = false
  end
end

function QRH.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

  -- General settings.
  --if abilityId == QRH.data.pierceArmor and string.match(string.lower(targetName), QRH.data.bahsei_name) then
  if (abilityId == QRH.data.bahsei_carve
      or abilityId == QRH.data.bahsei_slice
      or abilityId == QRH.data.bahsei_rendflesh) then
    if targetUnitId ~= nil and QRH.units[targetUnitId] ~= nil then
      QRH.status.mt_name = QRH.units[targetUnitId].name
    end
  end
  

  -- ### BOSS 1 ###
  -- Update the lastBlitz timer
  if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.oaxiltso_blitz then
    QRH.status.lastSavageBlitz = GetGameTimeSeconds()
  end

  if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.oaxiltso_sludge then
    QRH.status.lastPoisonSludge = GetGameTimeSeconds()
  end

  -- Show the progress bar icon.
	if result == ACTION_RESULT_BEGIN and 
    (abilityId == QRH.data.oaxiltso_blitz
     or abilityId == QRH.data.oaxiltso_blitz_hm) then
    CombatAlerts.CastAlertsStart(abilityId, "Savage Blitz" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
	end
  
  if QRH.savedVariables.showOaxiltsoMeteorBlock then
    if (result == ACTION_RESULT_BEGIN and abilityId == QRH.data.oaxiltso_annihilator_sunburst) then
      EVENT_MANAGER:RegisterForUpdate(QRH.name .. "OaxiltsoMeteorBlock", 2500, function() 
        EVENT_MANAGER:UnregisterForUpdate(QRH.name .. "OaxiltsoMeteorBlock")
        CombatAlerts.Alert("", "Meteor. BLOCK!", 0xFF0000FF, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
        end )
    end
  end

  -- Poison, big AOE on the floor.
  if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.oaxiltso_sludge then 
    CombatAlerts.Alert("", "Noxious Sludge", 0x00CC00D9, SOUNDS.CHAMPION_POINTS_COMMITTED, hitValue)
    --CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 0 })
	end

  -- Cast from Oaxiltso, but it's an Annihilator spawning.
  if result == ACTION_RESULT_EFFECT_GAINED and abilityId == QRH.data.oaxiltso_meteorcrash then
    QRHCurseLabel:SetText("ADD SPAWNING!")
    QRHCurse:SetHidden(false)
    EVENT_MANAGER:RegisterForUpdate(QRH.name .. "HideText", 3000,
                                    function()
                                    EVENT_MANAGER:UnregisterForUpdate(QRH.name .. "HideText")
                                    QRHCurse:SetHidden(true)
                                    end )
    -- TODO: Add a visual message in the middle of the screen, for everyone.
    -- results = 2240, 2200, 2245
  end
 
  -- Annihilator cone
  if QRH.savedVariables.showOaxiltsoCleaveDodgeBar then
    if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QRH.data.oaxiltso_annihilator_cindercleave then
      -- hitValue returns 4s, but it's misaligned, 2s closer to the correct time.
      CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
    end
  end
  
  -- Annihilator chains
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QRH.data.oaxiltso_annihilator_emberchains then
    -- Very short warning, unclear if it can be blocked/dodged.
    CombatAlerts.AlertCast(abilityId, sourceName, 750, { -3, 2 })
  end

  -- ### BOSS 2 ###

  -- Boss 2: Bahsei
  if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.bahsei_salvo2 then
    local isDPS, isHeal, isTank = GetPlayerRoles()
    if isTank and QRH.savedVariables.showBahseiInterruptForTanks then 
      CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 2, true})
      CombatAlerts.Alert(GetFormattedAbilityName(abilityId), "Interrupt!", 0xFF0000FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    end
  end
  
  if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.bahsei_cursedground then
    QRH.status.lastCursedGround = GetGameTimeSeconds()
    CombatAlerts.Alert("", "Cursed Ground", 0xEE82EED9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
  end
  
  if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.bahsei_sickle then
    QRH.status.nextSickle = GetGameTimeSeconds() + 15
  end
  
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QRH.data.bahsei_sickle then
    -- Scythe can no longer be dodged (only on early PTS iterations).
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 2 })
  end
  
  
   -- TODO: Cursed ground blue, and count how many hit you.
  
  -- Bahsei heavy attack, already in CCA
  
  -- Boss 2 add: Flesh Abomination
    -- Targeted on Off-Tank
    -- Regular light attack
  -- Remove light attack from flesh atro, just leave hemorrage to dodge.
  --if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and
    --abilityId == QRH.data.bahsei_flesh_bash then
    --CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 2 })
  --end
  
  -- Places hemorrage dot.
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and
    abilityId == QRH.data.bahsei_flesh_hemorrhage then
    --CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 2 })
    -- No longer rolldodgeable
    -- Audible cue to know you got the dot, since some OT were using it.
    PlaySound(SOUNDS.DUEL_START)
    PlaySound(SOUNDS.DUEL_START)
    CombatAlerts.Alert("", "Bleeding", 0xCC0000D9, SOUNDS.DUEL_START, 9000)
  end
  -- On the floor. Only tanks can see it.
  if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.bahsei_flesh_rancidhammer then
    local isDPS, isHeal, isTank = GetPlayerRoles()
    if isTank and QRH.savedVariables.showBahseiSlamForTanks then 
      CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 2 })
    end
  end

  -- Boss 2 add: Fire Behemoth
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QRH.data.bahsei_firebehem_scalding then
    -- This may show twice?
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 2 })
    CombatAlerts.Alert("", "Scalding", 0xCC0000D9, SOUNDS.DUEL_START, 9000)
  end

  if result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == QRH.data.meteor_swarm then
    -- Meteor Swarm cast begin
    QRH.status.nextSun = GetGameTimeSeconds() + 26
    -- Cast lasts 3.5s, then in 10s the sun explodes.
    if QRH.savedVariables.showBahseiSunProgressBar then
      local color = { 1, 0.7, 0, 0.5 }
      local action = { 10000, "KILL SUN!", 0.8, 0, 0, 0.9, nil}
      CombatAlerts.CastAlertsStart(abilityId, "Prime Meteor", 13500, 13500, color, action )
      PlaySound(SOUNDS.DUEL_START)
    end
  end
  
  -- Boss 2 cone direction. Credit: code from CCA.
  if result == ACTION_RESULT_EFFECT_GAINED and abilityId == QRH.data.eye_cw then
    QRH.status.lastPortalClockwise = true
  end
  
  if result == ACTION_RESULT_EFFECT_GAINED and abilityId == QRH.data.eye_ccw then
    QRH.status.lastPortalClockwise = false
  end


  -- BOSS 2 Archer QRH.data.bahsei_archer_icy_salvo
  -- Disabled since it's too verbose during the fight. Visible fillign AOE, causes more harm than help.
  
  -- ### BOSS 3 ###

  -- Xavakka heavy only if it's targetted on you.
  -- abilityId == QRH.data.xalvakka_eviscerate1 2 and 3 included in CCA
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QRH.data.xalvakka_eviscerate then
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 2 })
  end

  -- Add that does ring of fire has a heavy attack. Already in CCA.
  --if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QRH.data.xalvakka_goliath_powerbash then
    --CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 2 })
  --end
  
  -- TODO: Detect distance from the player who gets it, maybe detect overlap like vKA meteors.
  if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.xalvakka_deadstar1 then
    CombatAlerts.Alert("", "Deadstar", 0xCCCC00D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
  end
  
  if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.xalvakka_deadstar2 then
    CombatAlerts.Alert("", "Deadstar!", 0xCCCC00D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
  end
  
  if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.xalvakka_flame_portal then
    -- This can be 35-40s. It can worst case get delayed 10s if Xalvakka is stuck
    -- casting Creeping Manifold.
    QRH.status.nextXalvakkaJump = GetGameTimeSeconds() + 35
    QRH.status.numXalvakkaJump = QRH.status.numXalvakkaJump + 1
  end
  
  -- Tentacle Whip warning is not useful to react to it.
  --[[
  if abilityId == QRH.data.xalvakka_watcher_tentacle_whip_1
     or abilityId == QRH.data.xalvakka_watcher_tentacle_whip_2 then
    CombatAlerts.Alert("", "Tentacle Whip", 0x0000CCD9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
  end]]--


  -- QRH.data.soulweaver_remnant shows the warning 4 times (event returns 4 times)
  -- even at full range, you need to preemtively rolldodge, if it's cast it's too late.
  -- ACTION_RESULT_EFFECT_GAINED x4
  -- ACTION_RESULT_BLOCKED_DAMAGE
  -- ACTION_RESULT_BLOCKED
  
  -- Reaver (2 hander)
  -- Bloodseeker (archer)
  -- Soulweaver (mage)

  -- Generic add warnings
  if result == ACTION_RESULT_BEGIN and 
    (abilityId == QRH.data.soulweaver_shield
    or abilityId == QRH.data.soulweaver_remnant) then
    --CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 2 })
    CombatAlerts.Alert("", "Astral Shield", 0x75E6DAD9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
  end
  
  if QRH.savedVariables.showTrashEarthquake then
    if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.reaver_earthquake then
      CombatAlerts.Alert("", "Earthquake", 0x00CC00D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    end
  end

  -- Do not filter by targetType == COMBAT_UNIT_TYPE_PLAYER. It is a multi-target taking aim.
  -- The DD beign targetted is included in CCA with (result == ACTION_RESULT_EFFECT_GAINED and targetType == COMBAT_UNIT_TYPE_PLAYER)
  
  if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.bloodseeker_takingaim then
    local isDPS, isHeal, isTank = GetPlayerRoles()
    if isTank then 
      CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 2, true})
      PlaySound(SOUNDS.DUEL_START)
    end
  end

  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QRH.data.reaver_sundering then
  CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 2 })
    PlaySound(SOUNDS.DUEL_START)
  end
  
  -- ### BUTCHER ###
  
  if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.butcher_strike and targetType == COMBAT_UNIT_TYPE_PLAYER then
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 2 })
	end
  
  -- Butcher heavy, Included in CCA
  -- Butcher stomp (dot), Included in CCA
  
  -- ### FIRE BEHEMOTH ###
  -- TODO: filter on other param, since it shows twice per hit now.
  if result == ACTION_RESULT_BEGIN and targetType == COMBAT_UNIT_TYPE_PLAYER and abilityId == QRH.data.fire_behem_scalding then
    CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 2 })
    PlaySound(SOUNDS.DUEL_START)
  end

  -- Fire Behemoth heavy. Add and boss 2, already in CCA.

  -- ### BARBARIAN ###
  if result == ACTION_RESULT_BEGIN and 
    (abilityId == QRH.data.barbarian_assault1 or abilityId == QRH.data.barbarian_assault2) then
    -- This default alert simply shows "Dodge". Customized it a bit more.
    local color = { 1, 0.7, 0, 0.5 }
    local action = { QRH.data.dodgeDuration, QRH.data.holdBlock, 0.8, 0, 0, 0.9, nil}
    CombatAlerts.CastAlertsStart(abilityId, "Hasted Assault (Barbarian)", hitValue, QRH.data.maxDuration, color, action )
    PlaySound(SOUNDS.DUEL_START)
  end

  
  -- ### TORCHCASTER ###
  if QRH.savedVariables.showTrashSunProgressBar then
    if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.torchcaster_meteorcall then
      -- Cast lasts 3.5s, then in 10s the sun explodes.
      local color = { 1, 0.7, 0, 0.5 }
      local action = { 10000, "KILL SUN!", 0.8, 0, 0, 0.9, nil}
      CombatAlerts.CastAlertsStart(abilityId, "Prime Meteor", 13500, 13500, color, action )
      PlaySound(SOUNDS.DUEL_START)
    end
  end
  

  -- ### ASH TITAN ###
  -- Cleave on tank. Already in CCA.
  
  -- Kite the rain.
  if QRH.savedVariables.showTrashMoltenRainBar then
    if result == ACTION_RESULT_BEGIN and abilityId == QRH.data.ashtitan_moltenrain then
      CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { -2, 0 })
    end
  end
end

-- TODO: Move to separate utils file.
function QRH.FindPool(x, y, z)
  -- Return
  -- 1: Entrance Left
  -- 2: Entrance Right
  -- 3: Exit Left
  -- 4: Exit Right
  
  local bestDist = 9999999999
  local ans = 0
  for i=1, 4 do
    local dist = QRH.GetDist(x,y,z,
      QRH.data.oaxiltso_pools[i][1],
      QRH.data.oaxiltso_pools[i][2],
      QRH.data.oaxiltso_pools[i][3])
    if dist < bestDist then
      bestDist = dist
      ans = i
    end
  end
  return ans
end

function QRH.GetDist(x1, y1, z1, x2, y2, z2)
  local dx = x1 - x2
  local dy = y1 - y2
  local dz = z1 - z2
  return dx*dx + dy*dy + dz*dz
end

-- TODO: Split this into methods
--       UpdateOaxiltso(timeSec, isHardmode, hp, ...)
--       UpdateBahsei(timeSec, isHardmode, hp, ...)
--       UpdateXalvakka(timeSec, isHardmode, hp, ...)
function QRH.UpdateTick(gameTimeMs)
  local timeSec = GetGameTimeSeconds()
  
  -- update icons even out of combat
  -- check if OdySupportIcons is active
  if QRH.hasOSI() then
      -- [!] search for group members with custom timer
      for i = 1, GROUP_SIZE_MAX do
          local name = GetUnitDisplayName( "group" .. i )
          local icon = OSI.GetIconForPlayer( name )
          -- [!] update custom label if icon and timer are available
          if icon and icon.myTimer and timeSec <= icon.myTimer then
            local timeLeft = icon.myTimer - timeSec
            if timeLeft < 3 then
              if math.fmod(zo_floor(timeLeft*10), 10) < 5 then
                icon.myLabel:SetColor(0.9,0.9,0.9,0.85)
              else
                icon.myLabel:SetColor(0.9,0,0,0.85)
              end
            end
            icon.myLabel:SetText(tostring(zo_floor(timeLeft)))
            AdjustLabelForIcon(icon)
          end
      end
      -- [!] search for custom "floor" icons/arrow
      for i = 1, 4 do
        local icon = QRH.status.oaxiltso_pool_icons[i]
        if icon then
          if icon.myTimer and timeSec <= icon.myTimer then
            local timeLeft = icon.myTimer - timeSec
            icon.myLabel:SetText(tostring(zo_floor(timeLeft)))
          else
            icon.myLabel:SetText("")
          end
          
          AdjustLabelForIcon(icon)
        end
      end

      for i = 1, 3 do
        local icon = QRH.status.xalvakka_split_icons[i]
        if icon then
          icon.myLabel:SetText(QRH.data.xalvakka_split_labels[i])
          AdjustLabelForIcon(icon)
        end
      end
      for i = 1, 3 do
        local icon = QRH.status.xalvakka_split_icons_3[i]
        if icon then
          icon.myLabel:SetText(QRH.data.xalvakka_split_labels[i])
          AdjustLabelForIcon(icon)
        end
      end
  end
  
  if IsUnitInCombat("boss1") then
    QRH.status.inCombat = true
  end

  if QRH.status.inCombat == false then
    return
  end

  -- Boss 1: Oaxiltso
  if QRH.status.is_oaxiltso then
    local deltaBlitz = 36 - (timeSec - QRH.status.lastSavageBlitz)
    if deltaBlitz > 0 then
      local txtDuration = tostring(string.format("%.0f", deltaBlitz))
      QRHStatusLabel1Value:SetText(txtDuration .. "s")
    else
      QRHStatusLabel1Value:SetText("INC")
    end
    
    local deltaPoison = 28 - (timeSec - QRH.status.lastPoisonSludge)
    if deltaPoison > 0 then
      local txtDuration = tostring(string.format("%.0f", deltaPoison))
      QRHStatusLabel2Value:SetText(txtDuration .. "s")
    else
      QRHStatusLabel2Value:SetText("INC")
    end

    if QRH.savedVariables.showOaxiltsoPoolIcons then
      QRH.SetOaxiltsoPoolsIcons()
    else
      QRH.HideOaxiltsoPoolsIcons()
    end
    --[[
    if QRH.hasOSI() then
      -- TODO: protect with "if QRH.status.oaxiltso_pool_icons[3].myTimer then"
      -- otherwise it throws null errors for some players.
      local deltaLeftPool =  QRH.status.oaxiltso_pool_icons[3].myTimer - timeSec
      if deltaLeftPool > 0 then
        local txtDuration = tostring(string.format("%.0f", deltaLeftPool))
        QRHStatusLabel2aValue:SetText(txtDuration .. "s")
      else
        QRHStatusLabel2aValue:SetText("OK")
      end
      
      local deltaRightPool =  QRH.status.oaxiltso_pool_icons[4].myTimer - timeSec
      if deltaRightPool > 0 then
        local txtDuration = tostring(string.format("%.0f", deltaRightPool))
        QRHStatusLabel2bValue:SetText(txtDuration .. "s")
      else
        QRHStatusLabel2bValue:SetText("OK")
      end
    end
    ]]--
    

    -- Status panel
    QRHStatus:SetHidden(false)
    -- Next Blitz
    QRHStatusLabel1:SetHidden(not QRH.savedVariables.showOaxiltsoBlitz)
    QRHStatusLabel1Value:SetHidden(not QRH.savedVariables.showOaxiltsoBlitz)
    -- Next Poison
    QRHStatusLabel2:SetHidden(not QRH.savedVariables.showOaxiltsoPoison)
    QRHStatusLabel2Value:SetHidden(not QRH.savedVariables.showOaxiltsoPoison)
    -- TODO: Add timers for all 4 pools.
    -- Hi! Feel free to play with this, but I don't want it enabled until I add coverage for all 4 pools.
    --[[
    if QRH.hasOSI() then
      QRHStatusLabel2a:SetHidden(not QRH.savedVariables.showOaxiltsoPoison)
      QRHStatusLabel2aValue:SetHidden(not QRH.savedVariables.showOaxiltsoPoison)
      QRHStatusLabel2b:SetHidden(not QRH.savedVariables.showOaxiltsoPoison)
      QRHStatusLabel2bValue:SetHidden(not QRH.savedVariables.showOaxiltsoPoison)
    end
    ]]--
  else
    QRH.HideOaxiltsoPoolsIcons()
  end
  
  -- Boss 2: Bahsei
  if QRH.status.is_bahsei then
    QRH.HideOaxiltsoPoolsIcons()
    QRH.HideXalvakkaSplitIcons()
    QRH.HideXalvakkaSplitIconsLastFloor()
    -- Curse on self
    local delta = timeSec - QRH.status.lastDeathTouch
    if (delta < 9) then
      local txtDuration = tostring(string.format("%.1f", 9-delta))
      QRHCurseLabel:SetText("Death Touch " .. txtDuration .. "s")
      -- Big text
      QRHCurse:SetHidden(not QRH.savedVariables.showBahseiDeathTouchCountdown)
    else
      QRHCurse:SetHidden(true)
    end
    
    local deltaGround = 28 - (timeSec - QRH.status.lastCursedGround)
    if deltaGround > 0 then
      local txtDuration = tostring(string.format("%.0f", deltaGround))
      QRHStatusLabel3Value:SetText(txtDuration .. "s")
    else
      QRHStatusLabel3Value:SetText("INC")
    end

    -- Status panel
    QRHStatus:SetHidden(false)
    -- Next Cursed Ground
    QRHStatusLabel3:SetHidden(not QRH.savedVariables.showBahseiNextCurse)
    QRHStatusLabel3Value:SetHidden(not QRH.savedVariables.showBahseiNextCurse)
    
    if QRH.status.is_hm_boss then
      local nextPortalDelta = QRH.status.nextPortal - timeSec
      if nextPortalDelta > 0 then
        local txtDuration = tostring(string.format("%.0f", nextPortalDelta))
        QRHStatusLabel4:SetText("Next Portal (" .. QRH.status.portalNumber .. "):")
        QRHStatusLabel4Value:SetText(txtDuration .. "s")

      else
        if QRH.status.lastPortalClockwise then
          QRHStatusLabel4Value:SetText("In progress... " .. zo_iconFormatInheritColor("QcellRockgroveHelper/icons/arrow-cw.dds", 48, 48))
        else
          QRHStatusLabel4Value:SetText("In progress... " .. zo_iconFormatInheritColor("QcellRockgroveHelper/icons/arrow-ccw.dds", 48, 48))
        end
      end

      local doNotPortalDelta = QRH.status.selfDoNotPortalTime - timeSec
      if doNotPortalDelta > 0 then
        local txtDuration = tostring(string.format("%.0f", doNotPortalDelta))
        QRHStatusLabel6Value:SetText(txtDuration .. "s")
        QRHStatusLabel6:SetHidden(not QRH.savedVariables.showBahseiPortalDebuff)
        QRHStatusLabel6Value:SetHidden(not QRH.savedVariables.showBahseiPortalDebuff)
      else
        QRHStatusLabel6:SetHidden(true)
        QRHStatusLabel6Value:SetHidden(true)
      end
      
      local nextTankExplosionDelta = QRH.status.nextMtExplosion - timeSec
      if nextTankExplosionDelta > 0 and nextTankExplosionDelta < 3 then
        local txtDuration = tostring(string.format("%.0f", nextTankExplosionDelta))
        QRHSubtitleLabel:SetText("TANK EXPLODING IN: " .. txtDuration .. "s")
        QRHSubtitle:SetHidden(not QRH.savedVariables.showBahseiTankExploding)
      else
        QRHSubtitle:SetHidden(true)
      end
      
      local nextSickleDelta = QRH.status.nextSickle - timeSec
      if nextSickleDelta > 0 and nextSickleDelta < 15 then
        local txtDuration = tostring(string.format("%.0f", nextSickleDelta))
        QRHStatusLabel65Value:SetText(txtDuration .. "s")
        QRHStatusLabel65:SetHidden(not QRH.savedVariables.showBahseiNextSickle)
        QRHStatusLabel65Value:SetHidden(not QRH.savedVariables.showBahseiNextSickle)
      elseif nextSickleDelta <= 0 then
        QRHStatusLabel65Value:SetText("INC")
        QRHStatusLabel65:SetHidden(not QRH.savedVariables.showBahseiNextSickle)
        QRHStatusLabel65Value:SetHidden(not QRH.savedVariables.showBahseiNextSickle)
      else
        -- delta more than 15, should not happen, indicates internal error.
        QRHStatusLabel65:SetHidden(true)
        QRHStatusLabel65Value:SetHidden(true)
      end

      local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
      local bossPercentage = currentTargetHP / maxTargetHP
      local nextSunDelta = QRH.status.nextSun - timeSec
      if bossPercentage < 0.31 then
        if nextSunDelta > 0 and nextSunDelta < 26 then
          local txtDuration = tostring(string.format("%.0f", nextSunDelta))
          QRHStatusLabel66Value:SetText(txtDuration .. "s")
          QRHStatusLabel66:SetHidden(not QRH.savedVariables.showBahseiNextSun)
          QRHStatusLabel66Value:SetHidden(not QRH.savedVariables.showBahseiNextSun)
        elseif nextSunDelta < 0 then
          QRHStatusLabel66Value:SetText("INC")
          QRHStatusLabel66:SetHidden(not QRH.savedVariables.showBahseiNextSun)
          QRHStatusLabel66Value:SetHidden(not QRH.savedVariables.showBahseiNextSun)
        else
          -- Internal error.
          QRHStatusLabel66:SetHidden(true)
          QRHStatusLabel66Value:SetHidden(true)
        end
      else
        -- Do not show the sun text before 30%
        QRHStatusLabel66:SetHidden(true)
        QRHStatusLabel66Value:SetHidden(true)
      end

      -- Next Portal
      QRHStatusLabel4:SetHidden(not QRH.savedVariables.showBahseiNextPortal)
      QRHStatusLabel4Value:SetHidden(not QRH.savedVariables.showBahseiNextPortal)
      -- Players in portal
      QRHStatusLabel5:SetHidden(not QRH.savedVariables.showBahseiPlayersInPortal)
      QRHStatusLabel5Value:SetHidden(not QRH.savedVariables.showBahseiPlayersInPortal)
    end
  end

  -- Boss 3: Xalvakka
  if QRH.status.is_xalvakka then
    QRH.HideOaxiltsoPoolsIcons()
    local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
    local bossPercentage = currentTargetHP / maxTargetHP
    local runLeft = 0
    if 0.701 < bossPercentage and bossPercentage < 0.75  then
      runLeft = (bossPercentage - 0.7)*100
    elseif 0.401 < bossPercentage and bossPercentage < 0.45 then
      runLeft = (bossPercentage - 0.4)*100
    else
      runLeft = 0
    end
    
    if QRH.savedVariables.showXalvakkaSplitIcons then
      if bossPercentage < 0.4 then
        QRH.HideXalvakkaSplitIcons()
        QRH.SetXalvakkaSplitIconsLastFloor()
      elseif bossPercentage < 0.7 then
        QRH.SetXalvakkaSplitIcons()
      else
        QRH.HideXalvakkaSplitIcons()
        QRH.HideXalvakkaSplitIconsLastFloor()
      end
    else
      QRH.HideXalvakkaSplitIcons()
      QRH.HideXalvakkaSplitIconsLastFloor()
    end

    if runLeft > 0 then
      local txtDuration = tostring(string.format("%.1f", runLeft))
      QRHCurseLabel:SetText("RUN IN: " .. txtDuration .. "%")
      QRHCurse:SetHidden(not QRH.savedVariables.showXalvakkaRunTimer)
    else
      QRHCurse:SetHidden(true)
    end

    if QRH.status.is_hm_boss then
      local nextJump = QRH.status.nextXalvakkaJump - timeSec
      if nextJump > 0 then
        local txtDuration = tostring(string.format("%.0f", nextJump))
        QRHStatusLabel7Value:SetText(txtDuration .. "s")
      else
        QRHStatusLabel7Value:SetText("INC")
      end
      
      -- Hide after 4 jumps.
      -- Note: If a group pushes 3 jumps this may bug. Force hide it after 70%.
      -- TODO: With low enough dps, can she jump more than 4 times or do you wipe before?
      --       Maybe simpler to just track HP?
      if QRH.status.numXalvakkaJump >= 4 or bossPercentage < 0.7 then
        QRHStatusLabel7:SetHidden(true)
        QRHStatusLabel7Value:SetHidden(true)
      else 
        QRHStatusLabel7:SetHidden(not QRH.savedVariables.showXalvakkaJumpTimer)
        QRHStatusLabel7Value:SetHidden(not QRH.savedVariables.showXalvakkaJumpTimer)
        
      end
    end
    
    -- TODO: Maybe guard the purge soul mech by HM?
    local timeWithSoul = timeSec - QRH.status.soulResonanceStart
    if QRH.status.soulResonanceStart > 0 then
      local txtDuration = tostring(string.format("%.0f", timeWithSoul))
      QRHStatusLabel8Value:SetText(txtDuration .. "s")
      QRHStatusLabel8:SetHidden(not QRH.savedVariables.showXalvakkaPurgeSoulTimer)
      QRHStatusLabel8Value:SetHidden(not QRH.savedVariables.showXalvakkaPurgeSoulTimer)
    else
      QRHStatusLabel8:SetHidden(true)
      QRHStatusLabel8Value:SetHidden(true)
    end
    
    -- TODO: The notification will remain if the player is not looking at the shield when it expires.
    -- TODO: Keep a 20-30s timer on the shield text showing?
    if QRH.status.shellShield > 0 then
      local shieldMillions = tostring(string.format("%.2f", QRH.status.shellShield/1000000))
      QRHStatusLabel9Value:SetText(shieldMillions .. " M")
      QRHStatusLabel9:SetHidden(not QRH.savedVariables.showXalvakkaShieldValue)
      QRHStatusLabel9Value:SetHidden(not QRH.savedVariables.showXalvakkaShieldValue)

      -- Experiment, also adding the shield value on the very middle.
      --QRHSubtitleLabel:SetText("SHIELD: " .. shieldMillions .. " M")
      --QRHSubtitle:SetHidden(false)
      --QRHSubtitleLabel:SetHidden(false)
      -- TODO: Remove it after a few seconds, in case it stays unupdated.
      --[[local unregisterName = QRH.name .. "ShieldSubtitle"
      EVENT_MANAGER:UnregisterForUpdate(unregisterName)
      EVENT_MANAGER:RegisterForUpdate(
        unregisterName,
        25000,
        function( )
          EVENT_MANAGER:UnregisterForUpdate(unregisterName)
          QRHSubtitle:SetHidden(true)
        end
      )--]]
    else
      QRHStatusLabel9:SetHidden(true)
      QRHStatusLabel9Value:SetHidden(true)
      QRHSubtitle:SetHidden(true)
    end
    
    if QRH.status.onBlob then
      QRHSubtitleLabel:SetText("ON BLOB")
      QRHSubtitle:SetHidden(not QRH.savedVariables.showXalvakkaOnBlob)
    else
      QRHSubtitle:SetHidden(true)
    end

    -- Status panel for Xalvakka
    QRHStatus:SetHidden(false)
    
  -- Volatile Shell mechanic is work in progress.
  --[[
    local volatileDelta = timeSec - QRH.status.xalvakka_volatile_last
    if volatileDelta < QRH.data.xalvakka_volatile_timer then
      local txtDuration = tostring(string.format("%.0f", QRH.data.xalvakka_volatile_timer-volatileDelta))
      QRHCurseLabel:SetText("Volatile Shell: " .. txtDuration .. "s")
      QRHCurse:SetHidden(false)
    else
      QRHCurseLabel:SetText("Volatile Shell: INC")
      QRHCurse:SetHidden(false)
    end
    --]]
  end
end

function QRH.DeathState(event, unitTag, isDead)
  if unitTag == "player" and not isDead and not IsUnitInCombat("boss1") then
    -- I just resurrected, and it was a wipe or we killed the boss.
    -- Remove all UI
    QRH.ClearUIOutOfCombat()
  end
  
  if isDead and portalTracker ~= nil and QRH.unitsTag[unitTag] ~= nil then
    -- If a player dies, remove them from the portal counter.
    if portalTracker[QRH.unitsTag[unitTag].id] then
      portalTracker[QRH.unitsTag[unitTag].id] = false
      if QRH.status.numPlayersInPortal > 0 then
        --d("[QRH] numPlayersInPortal -1 due to death of " .. QRH.unitsTag[unitTag].name)
        QRH.status.numPlayersInPortal = QRH.status.numPlayersInPortal - 1
      end
    end

    local displayName = QRH.unitsTag[unitTag].name
    deathTouchTracker[displayName] = 0
    if QRH.hasOSI() then
      OSI.RemoveMechanicIconForUnit(displayName)
    end
  end
end

function QRH.CombatState(eventCode, inCombat)
  local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
  -- Do not change combat state if you are dead, or the boss is not full.

  -- Do not do anything outside of boss fights.
  if maxTargetHP == 0 or maxTargetHP == nil then
    -- TODO: TEST, this may break:
    QRH.ClearUIOutOfCombat()
    return
  end
  if currentTargetHP < 0.99*maxTargetHP or IsUnitDead("player") then
    -- TODO: Set inCombat = true for when players get pulled.
    return
  end
  if inCombat then
    QRH.status.inCombat = true
    QRH.status.lastSavageBlitz = 0
    QRH.status.lastPoisonSludge = 0
    QRH.status.lastPoisonTracker = 0
    QRH.status.lastCursedGround = 0
    QRH.status.portalNumber = 1 -- Bahsei
    QRH.status.numXalvakkaJump = 0
    QRH.status.shellShield = 0
    QRH.status.numPlayersInPortal = 0
    QRH.status.nextSickle = 0
    QRH.status.sludgeTracker1 = 0
    QRH.status.sludgeTracker2 = 0
    
    if QRH.status.is_xalvakka then
      QRH.status.xalvakka_volatile_last = GetGameTimeSeconds()
      -- First portal 30, others 35.
      QRH.status.nextXalvakkaJump = GetGameTimeSeconds() + 30
    end
    
    if QRH.status.is_oaxiltso then
      -- Next Blitz
      QRHStatusLabel1:SetHidden(false)
      QRHStatusLabel1Value:SetHidden(false)
      -- Next Poison
      QRHStatusLabel2:SetHidden(false)
      QRHStatusLabel2Value:SetHidden(false)
    end
    if QRH.status.is_bahsei then
      QRH.status.nextPortal = GetGameTimeSeconds() + 20
    end
  else
    QRH.ClearUIOutOfCombat()
  end
end

function QRH.ClearUIOutOfCombat()
  QRH.status.inCombat = false

  QRH.HideOaxiltsoPoolsIcons()
  QRH.HideXalvakkaSplitIcons()
  QRH.HideXalvakkaSplitIconsLastFloor()

  QRH.status.lastSavageBlitz = 0
  QRH.status.lastPoisonSludge = 0
  QRH.status.lastPoisonTracker = 0
  QRH.status.lastCursedGround = 0
  QRH.status.portalNumber = 1 -- Bahsei
  QRH.status.numXalvakkaJump = 0
  QRH.status.shellShield = 0
  QRH.status.numPlayersInPortal = 0
  QRH.status.nextSickle = 0
  QRH.status.sludgeTracker1 = 0
  QRH.status.sludgeTracker2 = 0
  QRH.HideAllUI(true)
end

function QRH.HideAllUI(hide)
  QRHCurse:SetHidden(hide)
  QRHSubtitle:SetHidden(hide)
  QRHStatus:SetHidden(hide)
  -- Boss enrage
  QRHStatusLabelTitle1:SetHidden(hide)
  -- Mini enrage
  QRHStatusLabelTitle2:SetHidden(hide)
  -- Next Blitz
  QRHStatusLabel1:SetHidden(hide)
  QRHStatusLabel1Value:SetHidden(hide)
  -- Next Poison
  QRHStatusLabel2:SetHidden(hide)
  QRHStatusLabel2Value:SetHidden(hide)
  -- Left Pool
  QRHStatusLabel2a:SetHidden(hide)
  QRHStatusLabel2aValue:SetHidden(hide)
  -- Right Pool
  QRHStatusLabel2b:SetHidden(hide)
  QRHStatusLabel2bValue:SetHidden(hide)
  -- Next Curse
  QRHStatusLabel3:SetHidden(hide)
  QRHStatusLabel3Value:SetHidden(hide)
  -- Next Portal
  QRHStatusLabel4:SetHidden(hide)
  QRHStatusLabel4Value:SetHidden(hide)
  -- People in portal
  QRHStatusLabel5:SetHidden(hide)
  QRHStatusLabel5Value:SetHidden(hide)
  -- Do not portal
  QRHStatusLabel6:SetHidden(hide)
  QRHStatusLabel6Value:SetHidden(hide)
  -- Next Sickle
  QRHStatusLabel65:SetHidden(hide)
  QRHStatusLabel65Value:SetHidden(hide)
  -- Next Sun
  QRHStatusLabel66:SetHidden(hide)
  QRHStatusLabel66Value:SetHidden(hide)
  -- Xalvakka Jump
  QRHStatusLabel7:SetHidden(hide)
  QRHStatusLabel7Value:SetHidden(hide)
  -- Xalvakka Purge Soul
  QRHStatusLabel8:SetHidden(hide)
  QRHStatusLabel8Value:SetHidden(hide)
  -- Xalvakka Shield
  QRHStatusLabel9:SetHidden(hide)
  QRHStatusLabel9Value:SetHidden(hide)
end

function QRH.BossesChanged()
	local bossName = string.lower(GetUnitName("boss1"))
  QRH.status.currentBoss = bossName
  
  QRH.status.is_oaxiltso = false
  QRH.status.is_bahsei = false
  QRH.status.is_xalvakka = false
  QRH.status.is_hm_boss = false
  
  if string.match(bossName, QRH.data.oaxiltso_name) then
    QRH.status.is_oaxiltso = true
  end
  if string.match(bossName, QRH.data.bahsei_name) then
    QRH.status.is_bahsei = true
  end
  if string.match(bossName, QRH.data.xalvakka_name) then
    QRH.status.is_xalvakka = true
  end
  
  local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
  if maxTargetHP > 100000000 then
    QRH.status.is_hm_boss = true
  else
    QRH.status.is_hm_boss = false
  end
end

-- Shield update
function QRH.OnShieldAdded(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        QRH.UpdateShield(unitTag, value, maxValue)
    end
end

function QRH.OnShieldRemoved(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        QRH.UpdateShield(unitTag, 0, maxValue)
    end
end

function QRH.OnShieldUpdated(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        QRH.UpdateShield(unitTag, newValue, newMaxValue)
    end
end

function QRH.UpdateShield(unitTag, value, maxValue)
  if unitTag ~= "reticleover" then
    return
  end
  qrhShields[unitTag] = value
  
  local unitName = string.lower(GetUnitName(unitTag))

  if string.match(unitName, QRH.data.xalvakka_volatile_shell_name) then
    QRH.status.shellShield = value
  end
end

function QRH.OnQRHCurseMove()
  QRH.savedVariables.curseLeft = QRHCurse:GetLeft()
  QRH.savedVariables.curseTop = QRHCurse:GetTop()
end

function QRH.OnQRHSubtitleMove()
  QRH.savedVariables.subtitleLeft = QRHSubtitle:GetLeft()
  QRH.savedVariables.subtitleTop = QRHSubtitle:GetTop()
end

function QRH.OnQRHStatusMove()
  QRH.savedVariables.statusLeft = QRHStatus:GetLeft()
  QRH.savedVariables.statusTop = QRHStatus:GetTop()
end

function QRH.DefaultPosition()
  QRH.savedVariables.curseLeft = nil
  QRH.savedVariables.curseTop = nil
  QRH.savedVariables.subtitleLeft = nil
  QRH.savedVariables.subtitleTop = nil
  QRH.savedVariables.statusLeft = nil
  QRH.savedVariables.statusTop = nil
end

function QRH.RestorePosition()
  if QRH.savedVariables.curseLeft ~= nil then
    QRHCurse:ClearAnchors()
    QRHCurse:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                       QRH.savedVariables.curseLeft,
                       QRH.savedVariables.curseTop)
  end
  
  if QRH.savedVariables.subtitleLeft ~= nil then
    QRHSubtitle:ClearAnchors()
    QRHSubtitle:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                       QRH.savedVariables.subtitleLeft,
                       QRH.savedVariables.subtitleTop)
  end
  if QRH.savedVariables.statusLeft ~= nil then
    QRHStatus:ClearAnchors()
    QRHStatus:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                       QRH.savedVariables.statusLeft,
                       QRH.savedVariables.statusTop)
  end
end

function QRH.UnlockUI(unlock)
  QRH.HideAllUI(not unlock)
  QRHCurse:SetMouseEnabled(unlock)
  QRHSubtitle:SetMouseEnabled(unlock)
  QRHStatus:SetMouseEnabled(unlock)
  
  QRHCurse:SetMovable(unlock)
  QRHSubtitle:SetMovable(unlock)
  QRHStatus:SetMovable(unlock)
end

function QRH.PlayerActivated()
  -- TODO: Check if the user reloaded in combat, and set it correctly.
  -- Disable all visible UI elements at startup.
  QRH.HideAllUI(true)
  QRH.UnlockUI(false)
  QRH.HideXalvakkaSplitIcons()
  QRH.HideXalvakkaSplitIconsLastFloor()
  QRH.HideOaxiltsoPoolsIcons()

  if GetZoneId(GetUnitZoneIndex("player")) ~= QRH.data.rockgrove_id then
    return
  else
    QRH.units = {}
    QRH.unitsTag = {}
  end

  if not QRH.active and not QRH.savedVariables.hideWelcome then
    d("[QRH] Thanks for using Qcell's Rockgrove Helper. Please send issues on discord Qcell#0001")
    if not QRH.hasOSI() then
      d("Please install |cff0000OdySupportIcons|r's latest version (optional dependency) to see all the addon features, including arrows on players with mechanics.")
    end
  end
  QRH.active = true
  QRHStatusLabelAddonName:SetText("Rockgrove Helper " .. QRH.version)

  EVENT_MANAGER:UnregisterForEvent(QRH.name .. "CombatEvent", EVENT_COMBAT_EVENT )
  EVENT_MANAGER:RegisterForEvent(QRH.name .. "CombatEvent", EVENT_COMBAT_EVENT, QRH.CombatEvent )
  
  -- Bufs/debuffs
  EVENT_MANAGER:UnregisterForEvent(QRH.name .. "Buffs", EVENT_EFFECT_CHANGED )
  EVENT_MANAGER:RegisterForEvent(QRH.name .. "Buffs", EVENT_EFFECT_CHANGED, QRH.EffectChanged)
  
  -- Boss change
  EVENT_MANAGER:UnregisterForEvent(QRH.name .. "BossChange", EVENT_BOSSES_CHANGED, QRH.BossesChanged)
  EVENT_MANAGER:RegisterForEvent(QRH.name .. "BossChange", EVENT_BOSSES_CHANGED, QRH.BossesChanged)
  
  -- Combat state
  EVENT_MANAGER:UnregisterForEvent(QRH.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE , QRH.CombatState)
  EVENT_MANAGER:RegisterForEvent(QRH.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE , QRH.CombatState)
  
  -- Death state
  EVENT_MANAGER:UnregisterForEvent(QRH.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED , QRH.DeathState)
  EVENT_MANAGER:RegisterForEvent(QRH.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED , QRH.DeathState)
  
  -- Ticks
  EVENT_MANAGER:RegisterForUpdate(QRH.name.."UpdateTick", 
    1000/10, function(gameTimeMs) QRH.UpdateTick(gameTimeMs) end)
  
  -- Shields
  EVENT_MANAGER:RegisterForEvent(QRH.name.."ShieldAdded",   EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,   QRH.OnShieldAdded)
  EVENT_MANAGER:RegisterForEvent(QRH.name.."ShieldRemoved", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, QRH.OnShieldRemoved)
  EVENT_MANAGER:RegisterForEvent(QRH.name.."ShieldUpdated", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, QRH.OnShieldUpdated)
end

function QRH.OnAddonLoaded( event, addonName )
	if addonName ~= QRH.name then
		return
	end
  
  QRH.savedVariables = ZO_SavedVars:NewAccountWide("QcellRockgroveHelperSavedVariables", 1, nil, QRH.settings)
  QRH.RestorePosition()
  QRH.AddonMenu()
  
	EVENT_MANAGER:UnregisterForEvent( QRH.name, EVENT_ADD_ON_LOADED )
	EVENT_MANAGER:RegisterForEvent(QRH.name .. "PlayerActive", EVENT_PLAYER_ACTIVATED,
    QRH.PlayerActivated)
end

EVENT_MANAGER:RegisterForEvent( QRH.name, EVENT_ADD_ON_LOADED, QRH.OnAddonLoaded )
