SSEA = SSEA or {}
local SSEA = SSEA

SSEA.name     = "SlipsSanitysEdgeAssist"
SSEA.version  = "3.6.2"
SSEA.author   = "@SlipperySoap"
SSEA.active   = false

-- Notes: 

-- TODO: QoL   : Show addon text when players are pulled into the fight (reload, crash...)
-- TODO: BOSS 1: Predict poison based on distance to center of pools. Next poison will be in X and Y...
-- TODO: BOSS 2: Fix the number of players in portal.
-- TODO: BOSS 2: Health indicator for meteor.
-- TODO: BOSS 2: Duration of beam upstairs.
SSEA.status = {
  verbose = false,
  currentBoss = "",
  is_hm_boss = false,
  is_yaseyla = false,
  is_twelvane = false,
  is_chimera = false,
  is_ansuul = false,
  inCombat = false,
  -- TODO: Use consistently last or next, but not both.
     
  -- enabledOnNonHM = true,
  trashDisruptorCount = 1,
  previousWamasuChargedPlayerName = "", -- SSEA.status.previousWamasuChargedPlayerName
  timeSinceLastWamasuCharge = 0, -- SSEA.status.timeSinceLastWamasuCharge
  lastYaseylaFireBombs = 0, -- SSEA.status.lastYaseylaFireBombs
  firstFireBombThrown = false, -- SSEA.status.firstFireBombThrown
  lastYaseylaShrapnel = 0, -- SSEA.status.lastYaseylaShrapnel
  startYaseylaWamasuOverwhelmingLightning = 0, -- SSEA.status.startYaseylaWamasuOverwhelmingLightning
  lastYaseylaTombFrostBomb = 0, -- SSEA.status.lastYaseylaTombFrostBomb
  lastYaseylaVantonsClarity = 0, -- SSEA.status.lastYaseylaVantonsClarity
  yaseylaIsSeething = false, -- SSEA.status.yaseylaIsSeething
  chimeraActive = false, -- SSEA.status.chimeraActive
  nextChimeraChainCircuitNumber = 0, -- SSEA.status.nextChimeraChainCircuitNumber
  lastChimeraChainCircuitStartTime = 0, -- SSEA.status.lastChimeraChainCircuitStartTime
  lastTankToGetChainLightning = "", -- SSEA.status.lastTankToGetChainLightning
  lastArcticShredTime = 0, -- SSEA.status.lastArcticShredTime
  lastAnsuulManicPhobia = 0, -- SSEA.status.lastAnsuulManicPhobia
  lastAnsuulSunburst = 0, -- SSEA.status.lastAnsuulSunburst
  lastAnsuulWrack = 0, -- SSEA.status.lastAnsuulWrack
  AnsuulHowManyInfernoToInterrupt = 0, -- SSEA.status.AnsuulHowManyInfernoToInterrupt
  durationIconsForPreviousInstance = {}, -- SSEA.status.durationIconsForPreviousInstance
  yaseylaContramagisArcherCount = 0, -- SSEA.status.yaseylaContramagisArcherCount
  ansuulEnragedFragmentCount = 1, -- SSEA.status.ansuulEnragedFragmentCount

}
-- Default settings.
SSEA.settings = {
    hideWelcome = false,
    enabledOnNonHM = true,
    debugMode = false,
    showTrashDisruptorMarkers2 = true,
    showTrashDisruptorMarkersOverride2 = false,
    showYaseylaAlerts = true,
    showYaseylaPercentageNotifications = true,
    showYaseylaWamasuConeCountdown = true,
    showYaseylaFireBombs2 = false,
    showYaseylaFrostBombs = true,
    showYaseylaWamasuWarnings = true, -- 90, 70, 50, 30, 20, 10; Wamasus + Archers
    showYaseylaPortalWarnings = true, -- 60, 35; only spammables starting 5% before
    showYaseylaShrapnelWarnings = true, -- 80, 55, 25, 20, and 10; credits to @UnholyFrijole
    showYaseylaArcherTrueShotWarnings = false, 
    showYaseylaVengefulStrikeAlerts = true,
    showYaseylaEnragedAlert = true,
    showYaseylaContramagisArcherMarkers2 = true, -- SSEA.settings.showYaseylaContramagisArcherMarkers2
    showYaseylaContramagisArcherMarkersOverride2 = false, -- SSEA.settings.showYaseylaContramagisArcherMarkersOverride2

    showChimeraPanel2 = false,
    showChimeraArcticShredAlerts = true,
    showCombatAlertChimeraLionDoubleStrikes = true,
    showCombatAlertChimeraGryphonPeck = true,

    showAnsuulForesightPanel = true,
    showAnsuulPercentageNotifications = true,
    showAnsuulEssenceManifestationInfo = true,
    showAnsuulManicPhobiaInfo = true, 
    showAnsuulManicPhobiaWarnings = true, -- 90, 70, 50, 30, and 10
    showAnsuulMazeInfo = true,
    showAnsuulMazeWarnings = true, -- 80, 60, and 40
    showAnsuulWrackInfo = true,
    showAnsuulMazeWarnings = true,
    showAnsuulPoisonedMindNotification = false,
    showAnsuulEnragedAtroInfernoWarnings = false,
    showAnsuulEnragedAtroInfernoWarnings2 = false,
    showAnsuulEnragedAtroInfernoAlerts = false,
    showAnsuulEnragedFragmentMarkers2 = true,
    showAnsuulEnragedFragmentMarkersOverride2 = false,

    showCombatAlertWamasuCharges2 = false,
    showCombatAlertTimerBarWamasuCharges2 = false,
    showCombatAlertYaseylaFireBombToss2 = false,
    showCombatAlertYaseylaShrapnel = true,
    showCombatAlertYaseylaKnifeBlast = true,
    showCombatAlertChimeraChainLightning = true,
    showCombatAlertAnsuulWrack = false,
    showCombatAlertAnsuulCalamity = false,
    showCombatAlertAnsuulSunburst = true,
    showCombatAlertAnsuulWrathstorm2 = false,
    showCombatAlertAnsuulExecute = false,
    showCombatAlertAnsuulCorrupt2 = false,
    showCombatAlertAnsuulManicPhobia = true,

    showIconWamasuCharges2 = true,
    showIconChimeraChainLightning = true,
    showIconAnsuulPoisonedMind = false,
    showYaseylaVengefulStrikeHealAbsorption = false,

    panelUICustomScale = 1,
    alertUICustomScale = 0.5,
}
SSEA.units = {}
SSEA.unitsTag = {}
SSEA.data    = {
  -- String lower, to make sure changes here keep strings
  -- in lowercase.
  -- original
  --yaseyla_name = string.lower("Exarchanic Yaseyla"),
  --archdruidTwelvane_name = string.lower("Archwizard Twelvane"),
  --chimera_name = string.lower("Chimera"),
  --ansuul_name = string.lower("Ansuul the Tormentor"),

  trash_disruptor = {
		    ["Dynamagis Disruptor"]			= TARGET_MARKER_TYPE_ONE,
		    ["Ansuul's Disruptor"]			= TARGET_MARKER_TYPE_ONE,
	    }, -- SSEA.data.trash_disruptor

  -- multi language support
  yaseyla_name = string.lower(GetString(SSEA_Yaseyla)),				--modded
  archdruidTwelvane_name = string.lower(GetString(SSEA_Twelvane)),  --modded
  chimera_name = string.lower(GetString(SSEA_Chimera)),				--modded
  ansuul_name = string.lower(GetString(SSEA_Ansuul)),				--modded

  -- Yaseyla
  yaseyla_firebombtoss = 183660, -- Yaseyla: Fire Bomb Toss
  yaseyla_shrapnel = 199131, -- Yaseyla: Shrapnel
  yaseyla_knifeblast = 183803, -- Yaseyla: Knife Blast
  yaseyla_knifeblast2 = 183804, -- Yaseyla: Knife Blast 2
  yaseyla_vengefulstrike = 185071, -- Yaseyla: Vengeful Strike
  yaseyla_vantonsclarity = 184041, -- Yaseyla: Vanton's Clarity Portal Synergy
  yaseyla_seethe = 162783, -- Yaseyla: Seethe Enragement 

  yaseyla_wamasu_charge1 = 191133, -- Contramagis Wamasu: Charge 1 (primary)
  yaseyla_wamasu_charge2 = 191139, -- Contramagis Wamasu: Charge 2
  yaseyla_wamasu_charge3 = 191134, -- Contramagis Wamasu: Charge 3
  yaseyla_wamasu_charge4 = 200544, -- Contramagis Wamasu: Charge 4 (primary)
  yaseyla_wamasu_charge5 = 200558, -- Contramagis Wamasu: Charge 5
  yaseyla_wamasu_charge6 = 200559, -- Contramagis Wamasu: Charge 6

  yaseyla_wamasu_chargedheadbutt1 = 184999, -- Contramagis Wamasu: Charged Headbutt 1
  yaseyla_wamasu_chargedheadbutt2 = 185002, -- Contramagis Wamasu: Charged Headbutt 2
  yaseyla_wamasu_chargedheadbutt3 = 185000, -- Contramagis Wamasu: Charged Headbutt 3

  yaseyla_wamasu_overwhelminglightning1 = 183598, -- Contramagis Wamasu: Overwhelming Lightning 1
  yaseyla_wamasu_overwhelminglightning2 = 198510, -- Contramagis Wamasu: Overwhelming Lightning 2
  yaseyla_wamasu_overwhelminglightning3 = 183599, -- Contramagis Wamasu: Overwhelming Lightning 3

  yaseyla_tombfrostbomb1 = 183790, -- Yaseyla: Tomb (Frost Bomb) 1
  yaseyla_tombfrostbomb2 = 183783, -- Yaseyla: Tomb (Frost Bomb) 2
  yaseyla_tombfrostbomb3 = 192304, -- Yaseyla: Tomb (Frost Bomb) 3
  yaseyla_tombfrostbomb4 = 191049, -- Yaseyla: Tomb (Frost Bomb) 4
  yaseyla_tombfrostbomb5 = 188065, -- Yaseyla: Tomb (Frost Bomb) 5
  yaseyla_tombfrostbomb6 = 199254, -- Yaseyla: Tomb (Frost Bomb) 6
  yaseyla_tombfrostbomb7 = 185406, -- Yaseyla: Tomb (Frost Bomb) 7
  yaseyla_tombfrostbomb8 = 183768, -- Yaseyla: Tomb (Frost Bomb) 8 (Credit: Code)
  yaseyla_tombfrostbomb9 = 185392, -- Yaseyla: Tomb (Frost Bomb) 9 (Credit: Code)

  yaseyla_trueshot = 184802, -- Yaseyla: True Shot

  yaseyla_tombiceycollapse1 = 190538, -- Yaseyla: Tomb (Icey Collapse) 1
  yaseyla_tombiceycollapse2 = 192303, -- Yaseyla: Tomb (Icey Collapse) 2

  yaseyla_hindered = 165972, -- Yaseyla: Hindered Status Effect

  yaseyla_contramagis_archer = {
		    ["Contramagis Archer"]			= TARGET_MARKER_TYPE_ONE,
	    }, -- SSEA.data.yaseyla_contramagis_archer

  markers = {
		    [1]			= TARGET_MARKER_TYPE_ONE, -- One is the blue square
		    [2]		    = TARGET_MARKER_TYPE_TWO, -- two is the yellow star
		    [3]		    = TARGET_MARKER_TYPE_THREE, -- three is green circle
		    [4]			= TARGET_MARKER_TYPE_FOUR, -- four is purple moon
		    [5]		    = TARGET_MARKER_TYPE_FIVE,-- five is red triangle?
		    [6]			= TARGET_MARKER_TYPE_SIX, -- Rune letter
		    [7]			= TARGET_MARKER_TYPE_SEVEN,-- seven is crossed swords?
		    [8]	        = TARGET_MARKER_TYPE_EIGHT, -- Skull
		    -- [9]		= TARGET_MARKER_TYPE_NINE,
	    }, -- SSEA.data.markers

  -- Chimera
  chimera_chainlightning1 = 183858, -- Chimera: Chain Lightning Cast
  chimera_chainlightning2 = 183898, -- Chimera: Chain Lightning Cast
  chimera_chainlightning3 = 183911, -- Chimera: Chain Lightning Cast
  chimera_chainlightning4 = 183913, -- Chimera: Chain Lightning Cast
  chimera_chainlightning5 = 184033, -- Chimera: Chain Lightning Cast
  chimera_chainlightning6 = 184028, -- Chimera: Chain Lightning Cast
  chimera_chainlightning7 = 184036, -- Chimera: Chain Lightning Cast
  chimera_chainlightning8 = 184032, -- Chimera: Chain Lightning Cast
  chimera_chainlightning9 = 184029, -- Chimera: Chain Lightning Cast
  chimera_chainlightning10 = 184030, -- Chimera: Chain Lightning Cast
  chimera_chainlightning11 = 183915, -- Chimera: Chain Lightning Cast
  chimera_chainlightning12 = 183917, -- Chimera: Chain Lightning Cast
  chimera_chainlightning13 = 183885, -- Chimera: Chain Lightning Cast

  chimera_debuff_chaincircuit1 = 184063, -- Chimera: Chain Circuit Debuff on Players
  chimera_debuff_chaincircuit2 = 184068, -- Chimera: Chain Circuit Debuff on Players
  chimera_debuff_chaincircuit3 = 184066, -- Chimera: Chain Circuit Debuff on Players
  chimera_debuff_chaincircuit4 = 184067, -- Chimera: Chain Circuit Debuff on Players

  chimera_arcticshred = 184275, -- Chimera: Arctic Shred Cast 5.5 second cooldown, 0.5 second cast time

  chimera_vivify = 186000, -- Chimera: Vivify Cast, coming out of stone
  chimera_petrify = 185038, -- Chimera: Petrify Cast, going back into stone

  chimera_ascendantlion_doublestrike = 186969, -- SSEA.data.chimera_ascendantlion_doublestrike
  chimera_ascendantgryphon_peck = 187002, -- SSEA.data.chimera_ascendantgryphon_peck

  -- Ansuul the Tormentor
  ansuul_wrack = 184621, -- Ansuul: Wrack (Kite Lightning)
  ansuul_calamity = 186728, -- Ansuul: Calamity (Heavy attack cone)
  ansuul_sunburst = 199344, -- Ansuul: Sunburst (Fire explosion circle that spawns fire aoe's)
  ansuul_wrathstorm = 189163, -- Ansuul: Wrathstorm
  ansuul_execute = 198482, -- Ansuul: Execute
  ansuul_corrupt = 187091, -- Ansuul: Corrupt
  ansuul_poisonedmind1 = 184707, -- Ansuul: Poisoned Mind
  ansuul_poisonedmind2 = 184709, -- Ansuul: Poisoned Mind
  ansuul_poisonedmind3 = 199644, -- Ansuul: Poisoned Mind
  ansuul_poisonedmind4 = 184711, -- Ansuul: Poisoned Mind
  ansuul_manicphobia = 185117, -- Ansuul: Manic Phobia
  ansuul_manicphobia2 = 185123, -- Ansuul: Manic Phobia
  ansuul_manicphobia3 = 185171, -- Ansuul: Manic Phobia
  ansuul_manicphobia4 = 185251, -- Ansuul: Manic Phobia
  ansuul_enragedatronachinferno = 183778, -- Ansuul: Enraged Atronach Inferno
  ansuul_enragedatronachflare = 183784, -- Ansuul: Enraged Atronach Flare
  ansuul_enragedfragment = {
		    ["Enraged Fragment"]			= TARGET_MARKER_TYPE_ONE,
	    }, -- SSEA.data.ansuul_enragedfragment

  --default_color = { 1, 0.7, 0, 0.5 },
  dodgeDuration = GetAbilityDuration(28549),
  maxDuration = 4000,
  holdBlock = "Hold Block!",
  sanitysedge_id = 1427,
  
  -- Experimental
  innerRage = 42056,
  pierceArmor = 38250,
}

function SSEA.IdentifyUnit( unitTag, unitName, unitId )
  -- 
	if (not SSEA.units[unitId] and 
    (string.sub(unitTag, 1, 5) == "group" or string.sub(unitTag, 1, 6) == "player")) then
		SSEA.units[unitId] = {
			tag = unitTag,
			name = GetUnitDisplayName(unitTag) or unitName,
		}
    SSEA.unitsTag[unitTag] = {
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
function SSEA.hasOSI()
  return OSI and OSI.CreatePositionIcon
end

function SSEA.UpdateIconTextControls(changeType, unitTag, beginTime, endTime)
  -- check if OdySupportIcons is active and the affected unit is a player
  if SSEA.hasOSI() and IsUnitPlayer(unitTag) then
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

function SSEA.EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
  SSEA.IdentifyUnit(unitTag, unitName, unitId)

  -- ### BOSS 1: Yaseyla ###
  -- if changeType == EFFECT_RESULT_GAINED and 
    -- (abilityId == SSEA.data.yaseyla_wamasu_charge1
    -- or abilityId == SSEA.data.yaseyla_wamasu_charge4) then
    
    -- if SSEA.hasOSI() and SSEA.savedVariables.showIconWamasuCharges then
      -- local texture = "SlipsSanitysEdgeAssist/icons/wamasu_charge.dds"
      -- local displayName = string.lower(GetUnitDisplayName(unitTag))
      -- OSI.SetMechanicIconForUnit(displayName, texture, 2 * OSI.GetIconSize())
      -- SSEA.AddGroundIconOnPlayerForDuration(
        -- SSEA.units[unitId].tag,
        -- "SlipsSanitysEdgeAssist/icons/wamasu_charge.dds",
        -- 7000)
    -- end
    
    -- if (SSEA.savedVariables.showCombatAlertWamasuCharges) then
        -- local wamasuChargedPlayersName = SSEA.units[unitId].name
        -- commented out usually: CombatAlerts.Alert("", wamasuChargedPlayersName .. " has Wamasu Charge!", 0x00CC00D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
        -- CombatAlerts.Alert("", wamasuChargedPlayersName .. ", Charge!", 0x00CC00D9, SOUNDS.DUEL_START, 3000)
    -- end
  -- end

  -- SSEA.data.yaseyla_seethe
  if unitName == SSEA.data.yaseyla_name and 
    abilityId == SSEA.data.yaseyla_seethe then
    
    if changeType == EFFECT_RESULT_GAINED then
        SSEA.status.yaseylaIsSeething = true
    elseif changeType == EFFECT_RESULT_FADED then
        SSEA.status.yaseylaIsSeething = false
    end
    -- CombatAlerts.AlertCast(abilityId, "Overwhelming Lightning", 2000, { 10000, 1 })
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
  end

  -- if result == ACTION_RESULT_BEGIN and 
  if changeType == ACTION_RESULT_EFFECT_GAINED and 
    (abilityId == SSEA.data.yaseyla_tombfrostbomb8
     or abilityId == SSEA.data.yaseyla_tombfrostbomb9) then
    SSEA.status.lastYaseylaTombFrostBomb = GetGameTimeSeconds()
    -- CombatAlerts.AlertCast(abilityId, "Overwhelming Lightning", 2000, { 10000, 1 })
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
  end

  if changeType == ACTION_RESULT_EFFECT_GAINED and 
    (abilityId == SSEA.data.yaseyla_vantonsclarity) then
    SSEA.status.lastYaseylaVantonsClarity = GetGameTimeSeconds()
    -- CombatAlerts.AlertCast(abilityId, "Overwhelming Lightning", 2000, { 10000, 1 })
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
  end

  -- ### BOSS 2: Chimera ###
  if (changeType == ACTION_RESULT_EFFECT_GAINED or changeType == ACTION_RESULT_EFFECT_GAINED_DURATION)
    and (abilityId == SSEA.data.chimera_debuff_chaincircuit1
    or abilityId == SSEA.data.chimera_debuff_chaincircuit2
    or abilityId == SSEA.data.chimera_debuff_chaincircuit3
    or abilityId == SSEA.data.chimera_debuff_chaincircuit4) then
    
    local displayNameChainCircuit = string.lower(GetUnitDisplayName(unitTag))
    local atNameChainCircuit = SSEA.units[unitId].name

    if (SSEA.hasOSI() and SSEA.savedVariables.showIconChimeraChainLightning) then
      -- updates variable if latest occurence is later than 5 seconds after the start of the previous Chain Circuit
      
      if (GetGameTimeSeconds() > (SSEA.status.lastChimeraChainCircuitStartTime + 5)) then
        if (SSEA.status.nextChimeraChainCircuitNumber == 1) then
          SSEA.status.nextChimeraChainCircuitNumber = 2
        else
          SSEA.status.nextChimeraChainCircuitNumber = 1
        end
      end

      if (SSEA.status.nextChimeraChainCircuitNumber == 1) then
        local textureChainCircuit = "SlipsSanitysEdgeAssist/icons/chimera_chaincircuit1.dds"
      else
        local textureChainCircuit = "SlipsSanitysEdgeAssist/icons/chimera_chaincircuit2.dds"
      end

      
      -- local texture = "SlipsSanitysEdgeAssist/icons/chimera_chaincircuit1.dds"
      
      OSI.SetMechanicIconForUnit(displayNameChainCircuit, textureChainCircuit, 2 * OSI.GetIconSize())
      if SSEA.savedVariables.debugMode then
        d("Primary Chimera Chain Lightning Code Triggered")
      end
    end

    local isDPS, isHeal, isTank = GetGroupMemberRoles(unitTag)
    if isTank then
        if atNameChainCircuit == nil then
            SSEA.status.lastTankToGetChainLightning = displayNameChainCircuit
            if SSEA.savedVariables.debugMode then
                d("atName for lastTankToGetChainLightning was nil in primary location")
                CombatAlerts.Alert("", displayNameChainCircuit .. ", Charge!", 0x00CC00D9, SOUNDS.DUEL_START, 3000)
            end
        else
            SSEA.status.lastTankToGetChainLightning = atNameChainCircuit
            CombatAlerts.Alert("", atNameChainCircuit .. ", Charge!", 0x00CC00D9, SOUNDS.DUEL_START, 3000)
        end
        
    end

  end

  
  -- ### BOSS 3: Ansuul ###
  -- Poisoned Mind
  if changeType == EFFECT_RESULT_GAINED and 
    (abilityId == SSEA.data.ansuul_poisonedmind1
     or abilityId == SSEA.data.ansuul_poisonedmind2
     or abilityId == SSEA.data.ansuul_poisonedmind3
     or abilityId == SSEA.data.ansuul_poisonedmind4) then
    
    if SSEA.hasOSI() and SSEA.savedVariables.showIconAnsuulPoisonedMind then
      local texture = "SlipsSanitysEdgeAssist/icons/ansuul_poisonedmind.dds"
      local displayName = string.lower(GetUnitDisplayName(unitTag))
      OSI.SetMechanicIconForUnit(displayName, texture, 2 * OSI.GetIconSize())
    end
    
    if (SSEA.savedVariables.showAnsuulPoisonedMindNotification) then
      local poisonedMindPlayersName = SSEA.units[unitId].name
      CombatAlerts.Alert("", poisonedMindPlayersName .. " has Poisoned Mind.", 0x00CC00D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 5000)
    end
  end

  -- TODO: do I need to remove it after the duration? does everyone get the FADED event?
  --if changeType == EFFECT_RESULT_FADED and 
    --(abilityId == SSEA.data.yaseyla_wamasu_charge1
    --or abilityId == SSEA.data.yaseyla_wamasu_charge2
    --or abilityId == SSEA.data.yaseyla_wamasu_charge3
    --or abilityId == SSEA.data.yaseyla_wamasu_charge4
    --or abilityId == SSEA.data.yaseyla_wamasu_charge5
    --or abilityId == SSEA.data.yaseyla_wamasu_charge6
    --or abilityId == SSEA.data.ansuul_poisonedmind1
    --or abilityId == SSEA.data.ansuul_poisonedmind2
    --or abilityId == SSEA.data.ansuul_poisonedmind3
    --or abilityId == SSEA.data.ansuul_poisonedmind4) then

    -- abilityId == SSEA.data.chimera_debuff_chaincircuit1
    -- or abilityId == SSEA.data.chimera_debuff_chaincircuit2
    -- or abilityId == SSEA.data.chimera_debuff_chaincircuit3
    -- or abilityId == SSEA.data.chimera_debuff_chaincircuit4
    -- or 

    --if SSEA.hasOSI() then
      --local displayName = string.lower(GetUnitDisplayName(unitTag))
      --OSI.RemoveMechanicIconForUnit(displayName)
    --end
    -- i might have to also remove any icons on death. this will fix the bug of icons persisting beyond death without getting that an effect has faded.
  --end

  -- Shouldn't be necessary, since it will fade on its own.
  --if changeType == EFFECT_RESULT_FADED and abilityId == SSEA.data.debuff_bahsei_death_touch and unitTag == "player" then
    --CombatAlerts.AlertBorder(false, "blue")
  --end

  -- give icons with this
  -- if changeType == EFFECT_RESULT_GAINED and abilityId == SSEA.data.xalvakka_manifold_debuff then
    -- if SSEA.hasOSI() then
      -- local texture = "SlipsSanitysEdgeAssist/icons/curse00.dds"
      -- local displayName = string.lower(GetUnitDisplayName(unitTag))
      -- OSI.SetMechanicIconForUnit(displayName, texture, 2 * OSI.GetIconSize())
    -- end
  -- end

  -- TODO: Remove it after the duration, since some people don't get the FADED event?
  -- used to remove icons from players?
  -- if changeType == EFFECT_RESULT_FADED and (
    -- abilityId == SSEA.data.debuff_bahsei_death_touch
    -- or abilityId == SSEA.data.debuff_oaxiltso_sludge
    -- or abilityId == SSEA.data.xalvakka_manifold_debuff) then
    -- if SSEA.hasOSI() then
      -- local displayName = string.lower(GetUnitDisplayName(unitTag))
      -- OSI.RemoveMechanicIconForUnit(displayName)
    -- end
  -- end
  
  
  -- can be used to track if standing on Fire Bombs or other aoe's
  -- if changeType == EFFECT_RESULT_GAINED and abilityId == SSEA.data.xalvakka_unstable_charge_debuff and unitTag == "player" then
    -- CombatAlerts.AlertBorder(true, 15000, "red")
    -- SSEA.status.onBlob = true
  -- end
  
  -- if changeType == EFFECT_RESULT_FADED and abilityId == SSEA.data.xalvakka_unstable_charge_debuff and unitTag == "player" then
    -- CombatAlerts.AlertBorder(false)
    -- SSEA.status.onBlob = false
  -- end
end

function SSEA.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

  -- General settings.
  
  -- ### BOSS 1: Yaseyla ###
  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.yaseyla_wamasu_charge1
     or abilityId == SSEA.data.yaseyla_wamasu_charge4) then
    
    if SSEA.hasOSI() and SSEA.savedVariables.showIconWamasuCharges2 then
      local texture = "SlipsSanitysEdgeAssist/icons/wamasu_charge.dds"
      local targetUnitTag = SSEA.units[targetUnitId].tag
      local displayName = string.lower(GetUnitDisplayName(targetUnitTag))
      -- d("Should be adding wamasu charge ground markers.")
      if SSEA.status.is_yaseyla then
          SSEA.AddGroundIconOnPlayerForDuration(
                    SSEA.units[targetUnitId].tag,
                    "SlipsSanitysEdgeAssist/icons/wamasu_charge.dds",
                    7000) -- was 7000
          --if (GetGameTimeSeconds() > (SSEA.status.timeSinceLastWamasuCharge + 10)) then
            --SSEA.status.previousWamasuChargedPlayerName = ""
          --end
          -- OSI.SetMechanicIconForUnit(displayName, texture, 2 * OSI.GetIconSize())
          --if (SSEA.status.previousWamasuChargedPlayerName ~= displayName) then 
            --if (GetGameTimeSeconds() > (SSEA.status.timeSinceLastWamasuCharge + 2)) then
                --SSEA.AddGroundIconOnPlayerForDuration(
                    --SSEA.units[targetUnitId].tag,
                    --"SlipsSanitysEdgeAssist/icons/wamasu_charge.dds",
                    --3000) -- was 7000
            --end
          --end
          --SSEA.status.previousWamasuChargedPlayerName = displayName
          --SSEA.status.timeSinceLastWamasuCharge = GetGameTimeSeconds()
      end
    end
    if (SSEA.savedVariables.showCombatAlertWamasuCharges2) then
        local wamasuChargedPlayersName = SSEA.units[targetUnitId].name
        -- CombatAlerts.Alert("", wamasuChargedPlayersName .. " has Wamasu Charge!", 0x00CC00D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
        CombatAlerts.Alert("", wamasuChargedPlayersName .. ", Charge!", 0x00CC00D9, SOUNDS.DUEL_START, 3000)
    end
  end

  -- Update the lastYaseylaFireBombs timer
  if result == ACTION_RESULT_BEGIN and abilityId == SSEA.data.yaseyla_firebombtoss then
    if (SSEA.savedVariables.earliestFireBombs == nil) then
        SSEA.savedVariables.earliestFireBombs = 10.5
    else
        if (SSEA.status.lastYaseylaFireBombs ~= 0) then
            local mostRecentFirebombTossCooldown = GetGameTimeSeconds() - SSEA.status.lastYaseylaFireBombs
            if (mostRecentFirebombTossCooldown < SSEA.savedVariables.earliestFireBombs) then
                SSEA.savedVariables.earliestFireBombs = mostRecentFirebombTossCooldown
            end
        end
    end
    if SSEA.savedVariables.debugMode then
        d("Earliest Yaseyla Firebombs: " .. SSEA.savedVariables.earliestFireBombs .. " s")
    end
    SSEA.status.lastYaseylaFireBombs = GetGameTimeSeconds()
    -- CombatAlerts.Alert("", "Fire Bombs!", 0xB0E0E6D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    if SSEA.savedVariables.showCombatAlertYaseylaFireBombToss2 then
      CombatAlerts.Alert("", "Fire Bombs!", 0xCC0000D9, SOUNDS.DUEL_START, 3000)
    end
    if SSEA.status.firstFireBombThrown == false then
        SSEA.status.firstFireBombThrown = true
    end
  end

  -- if result == ACTION_RESULT_BEGIN and 
  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.yaseyla_tombfrostbomb8
     or abilityId == SSEA.data.yaseyla_tombfrostbomb9) then
    SSEA.status.lastYaseylaTombFrostBomb = GetGameTimeSeconds()
    -- CombatAlerts.AlertCast(abilityId, "Overwhelming Lightning", 2000, { 10000, 1 })
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
  end


  -- Update the lastYaseylaShrapnel timer
  if result == ACTION_RESULT_BEGIN and abilityId == SSEA.data.yaseyla_shrapnel then
    SSEA.status.lastYaseylaShrapnel = GetGameTimeSeconds()
    -- CombatAlerts.Alert("", "Fire Bombs!", 0xB0E0E6D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    if SSEA.savedVariables.showCombatAlertYaseylaShrapnel then
        CombatAlerts.Alert("", "Shrapnel!", 0xFF0000FF, SOUNDS.DUEL_START, 5000)
    end
  end

  if result == ACTION_RESULT_BEGIN and abilityId == SSEA.data.yaseyla_trueshot then
    -- CombatAlerts.Alert("", "Fire Bombs!", 0xB0E0E6D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    if SSEA.savedVariables.showYaseylaArcherTrueShotWarnings then
        --CombatAlerts.Alert("", "Shrapnel!", 0xFF0000FF, SOUNDS.DUEL_START, 5000)
        CombatAlerts.Alert("Interrupt", GetFormattedAbilityName(abilityId), 0x00CC00FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 7000)
    end
  end

  -- Will have to test this
  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.yaseyla_knifeblast
    or abilityId == SSEA.data.yaseyla_knifeblast2) and
    SSEA.savedVariables.showCombatAlertYaseylaKnifeBlast then
    CombatAlerts.AlertCast(abilityId, "Knife Blast", 1000, { -1, 1 })
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
  end

  -- if result == ACTION_RESULT_BEGIN and 
    -- (abilityId == SSEA.data.yaseyla_wamasu_chargedheadbutt1
    -- or abilityId == SSEA.data.yaseyla_wamasu_chargedheadbutt2
    -- or abilityId == SSEA.data.yaseyla_wamasu_chargedheadbutt3) then
    -- CombatAlerts.AlertCast(abilityId, "Charged Headbutt", 1000, { -1, 1 })
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
  -- end

  -- if result == ACTION_RESULT_BEGIN and 
    -- (abilityId == SSEA.data.yaseyla_wamasu_chargedheadbutt1
    -- or abilityId == SSEA.data.yaseyla_wamasu_chargedheadbutt2
    -- or abilityId == SSEA.data.yaseyla_wamasu_chargedheadbutt3) then
    -- CombatAlerts.AlertCast(abilityId, "Charged Headbutt", 1000, { -1, 1 })
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
  -- end

  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.yaseyla_wamasu_overwhelminglightning1
     or abilityId == SSEA.data.yaseyla_wamasu_overwhelminglightning2
     or abilityId == SSEA.data.yaseyla_wamasu_overwhelminglightning3) and
     SSEA.savedVariables.showYaseylaWamasuConeCountdown then
    SSEA.status.startYaseylaWamasuOverwhelmingLightning = GetGameTimeSeconds()
    -- CombatAlerts.AlertCast(abilityId, "Overwhelming Lightning", 2000, { 10000, 1 })
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
  end

  -- if I can get when the ACTION_RESULT_ENDs then I would put it right here. 

  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.yaseyla_wamasu_charge1
     or abilityId == SSEA.data.yaseyla_wamasu_charge4) and 
     SSEA.savedVariables.showCombatAlertTimerBarWamasuCharges2 then
    CombatAlerts.AlertCast(abilityId, "Charge", 1600, { -1, 1 }) -- average time 1.6s
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
  end

  -- SSEA.data.yaseyla_hindered
  -- SSEA.savedVariables.showYaseylaVengefulStrikeHealAbsorption

  -- ### BOSS 2: Chimera ###
  -- chimera_vivify
  if result == ACTION_RESULT_BEGIN and abilityId == SSEA.data.chimera_vivify then
    SSEA.status.lastTankToGetChainLightning = ""
    SSEA.status.chimeraActive = true
  end

  if result == ACTION_RESULT_BEGIN and 
     (abilityId == SSEA.data.chimera_chainlightning1
     or abilityId == SSEA.data.chimera_chainlightning2
     or abilityId == SSEA.data.chimera_chainlightning3
     or abilityId == SSEA.data.chimera_chainlightning4
     or abilityId == SSEA.data.chimera_chainlightning5
     or abilityId == SSEA.data.chimera_chainlightning6
     or abilityId == SSEA.data.chimera_chainlightning7
     or abilityId == SSEA.data.chimera_chainlightning8
     or abilityId == SSEA.data.chimera_chainlightning9
     or abilityId == SSEA.data.chimera_chainlightning10
     or abilityId == SSEA.data.chimera_chainlightning11
     or abilityId == SSEA.data.chimera_chainlightning12
     or abilityId == SSEA.data.chimera_chainlightning13) and 
     SSEA.savedVariables.showCombatAlertChimeraChainLightning then
    -- CombatAlerts.Alert("", "Fire Bombs!", 0xB0E0E6D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    CombatAlerts.Alert("", "Chain Lightning!", 0x00CCCCD9, SOUNDS.DUEL_START, 3000)
    SSEA.status.lastChimeraChainCircuitStartTime = GetGameTimeSeconds()
  end

  -- Secondary Chimera Chain Lightning Location if primary doesn't work
  if (result == EFFECT_RESULT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION) 
    and (abilityId == SSEA.data.chimera_debuff_chaincircuit1
    or abilityId == SSEA.data.chimera_debuff_chaincircuit2
    or abilityId == SSEA.data.chimera_debuff_chaincircuit3
    or abilityId == SSEA.data.chimera_debuff_chaincircuit4) then
    
    if (SSEA.hasOSI() and SSEA.savedVariables.showIconChimeraChainLightning) then
      -- updates variable if latest occurence is later than 5 seconds after the start of the previous Chain Circuit

      
      if (GetGameTimeSeconds() > (SSEA.status.lastChimeraChainCircuitStartTime + 5)) then
        if (SSEA.status.nextChimeraChainCircuitNumber == 1) then
          SSEA.status.nextChimeraChainCircuitNumber = 2
        else
          SSEA.status.nextChimeraChainCircuitNumber = 1
        end
      end

      if (SSEA.status.nextChimeraChainCircuitNumber == 1) then
        local textureChainCircuit = "SlipsSanitysEdgeAssist/icons/chimera_chaincircuit1.dds"
      else
        local textureChainCircuit = "SlipsSanitysEdgeAssist/icons/chimera_chaincircuit2.dds"
      end

      
      -- local texture = "SlipsSanitysEdgeAssist/icons/chimera_chaincircuit1.dds"
      local targetUnitTagChainCircuit = SSEA.units[targetUnitId].tag
      local displayNameChainCircuit = string.lower(GetUnitDisplayName(targetUnitTagChainCircuit))
      local atNameChainCircuit = SSEA.units[targetUnitId].name
      OSI.SetMechanicIconForUnit(displayNameChainCircuit, textureChainCircuit, 2 * OSI.GetIconSize())
      if SSEA.savedVariables.debugMode then
        d("Secondary Chimera Chain Lightning Code Triggered")
      end
    end
    local targetUnitTagChainCircuit = SSEA.units[targetUnitId].tag
    local isDPS, isHeal, isTank = GetGroupMemberRoles(targetUnitTagChainCircuit)
    if isTank then
        if atNameChainCircuit == nil and displayNameChainCircuit ~= nil then
            SSEA.status.lastTankToGetChainLightning = displayNameChainCircuit
            if SSEA.savedVariables.debugMode then
                d("atName for lastTankToGetChainLightning was nil in secondary location")
            end
            CombatAlerts.Alert("", displayNameChainCircuit .. ", Chained!", 0x00CC00D9, SOUNDS.DUEL_START, 3000)
        elseif atNameChainCircuit ~= nil and displayNameChainCircuit == nil then
            SSEA.status.lastTankToGetChainLightning = atNameChainCircuit
            if SSEA.savedVariables.debugMode then
                d("displayNameChainCircuit for lastTankToGetChainLightning was nil in secondary location")
            end
            CombatAlerts.Alert("", atNameChainCircuit .. ", Chained!", 0x00CC00D9, SOUNDS.DUEL_START, 3000)
        else 
            -- Slip: commenting out for now because might proc too many times
            --if SSEA.savedVariables.debugMode then
                --d("both atName and displayNameChainCircuit for lastTankToGetChainLightning was nil in secondary location")
            --end
        end
        
    end

  end

  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.chimera_ascendantlion_doublestrike) then
    -- CombatAlerts.AlertCast(abilityId, "Sunburst", 2000, { -1, 1 }) -- average time?
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
    if SSEA.savedVariables.showCombatAlertChimeraLionDoubleStrikes then
        local doublestrikePlayersName = SSEA.units[targetUnitId].name
        -- ffbe0a (Gold) CC0000D9 (red)
        local targetUnitTag = SSEA.units[targetUnitId].tag
        if targetUnitTag == "player" then
            CombatAlerts.Alert("", "Double Strike", 0xFFBE0AD9, SOUNDS.DUEL_START, 1500)
            CombatAlerts.AlertCast(abilityId, "Double Strike", 1500, { -1, 1 }) -- average time 1.5s
        end
    end
  end

  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.chimera_ascendantgryphon_peck) then
    -- CombatAlerts.AlertCast(abilityId, "Sunburst", 2000, { -1, 1 }) -- average time?
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
    if SSEA.savedVariables.showCombatAlertChimeraGryphonPeck then
        local doublestrikePlayersName = SSEA.units[targetUnitId].name
        -- ffbe0a (Gold) CC0000D9 (red) FFFFFF (white/blue)
        local targetUnitTag = SSEA.units[targetUnitId].tag
        if targetUnitTag == "player" then
            CombatAlerts.Alert("", "Peck", 0xFFFFFF, SOUNDS.DUEL_START, 500)
            --CombatAlerts.AlertCast(abilityId, "Peck", 500, { -1, 1 }) -- average time 0.5s
        end
    end
  end

  -- SSEA.data.chimera_arcticshred
  -- SSEA.status.lastArcticShredTime
  -- SSEA.savedVariables.showChimeraArcticShredAlerts
  if result == ACTION_RESULT_BEGIN and abilityId == SSEA.data.chimera_arcticshred then
    SSEA.status.lastArcticShredTime = GetGameTimeSeconds()
    -- CombatAlerts.Alert("", "Fire Bombs!", 0xB0E0E6D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    if SSEA.savedVariables.showChimeraArcticShredAlerts then
      CombatAlerts.Alert("", "Arctic Shred!", 0x00CCCCD9, SOUNDS.DUEL_START, 1000)
    end
  end

  -- chimera_petrify
  if result == ACTION_RESULT_BEGIN and abilityId == SSEA.data.chimera_petrify and SSEA.hasOSI() then
    SSEA.status.chimeraActive = false
    SSEA.status.lastTankToGetChainLightning = ""
    OSI.ResetMechanicIcons()
  end

  -- ### BOSS 3: Ansuul ###
  if result == ACTION_RESULT_BEGIN and 
    abilityId == SSEA.data.ansuul_wrack then
    -- CombatAlerts.Alert("", "Fire Bombs!", 0xB0E0E6D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    SSEA.status.lastAnsuulWrack = GetGameTimeSeconds()
    if SSEA.savedVariables.showCombatAlertAnsuulWrack then
        CombatAlerts.Alert("", "Wrack! Kite.", 0x00CCCCD9, SOUNDS.DUEL_START, 3000)
    end
  end

  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.ansuul_calamity) and 
    SSEA.savedVariables.showCombatAlertAnsuulCalamity then
    local targetUnitTag = SSEA.units[targetUnitId].tag
    if targetUnitTag == "player" then
        CombatAlerts.AlertCast(abilityId, "Calamity", 1750, { -1, 1 }) -- average time 1.75s
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
    end
  end

  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.ansuul_sunburst) then
    -- CombatAlerts.AlertCast(abilityId, "Sunburst", 2000, { -1, 1 }) -- average time?
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
    SSEA.status.lastAnsuulSunburst = GetGameTimeSeconds()
    if SSEA.savedVariables.showCombatAlertAnsuulSunburst then
        local sunburstPlayersName = SSEA.units[targetUnitId].name
        CombatAlerts.Alert("", "Sunburst (" .. sunburstPlayersName .. ")", 0xFFBE0AD9, SOUNDS.DUEL_START, 3000)
        -- ffbe0a (Gold) CC0000D9 (red)
        local targetUnitTag = SSEA.units[targetUnitId].tag
        if targetUnitTag == "player" then
            CombatAlerts.AlertCast(abilityId, "Sunburst", 3000, { -1, 1 }) -- average time 3s
        end
    end
  end

  --if result == ACTION_RESULT_BEGIN and 
    --(abilityId == SSEA.data.ansuul_wrathstorm) and
    --SSEA.savedVariables.showCombatAlertAnsuulWrathstorm then
    --CombatAlerts.AlertCast(abilityId, "Wrathstorm", 2000, { -1, 1 }) -- average time?
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
  --end

  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.yaseyla_vengefulstrike) then
    local targetUnitTag = SSEA.units[targetUnitId].tag
    if targetUnitTag == "player" then
        CombatAlerts.AlertCast(abilityId, "Vengeful Strike", 1900, { -1, 1 }) -- average time?
        -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
        -- or should i use something like this:
        -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
    end
  end

  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.yaseyla_vengefulstrike) then
    local targetUnitTag = SSEA.units[targetUnitId].tag
    local vengefulStrikePlayersName = SSEA.units[targetUnitId].name
    if SSEA.savedVariables.showYaseylaVengefulStrikeAlerts then
        CombatAlerts.Alert("", "Vengeful Strike (" .. vengefulStrikePlayersName .. ")", 0xFFBE0AD9, SOUNDS.DUEL_START, 5000)
    end
  end

  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.ansuul_execute) and
    SSEA.savedVariables.showCombatAlertAnsuulExecute then
    local targetUnitTag = SSEA.units[targetUnitId].tag
    if targetUnitTag == "player" then
        CombatAlerts.AlertCast(abilityId, "Execute", 2000, { -1, 1 }) -- average time?
        CombatAlerts.Alert("", "Interrupt", 0xCC0000D9, SOUNDS.DUEL_START, 3000)
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
    end
  end

  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.ansuul_corrupt) and 
    SSEA.savedVariables.showCombatAlertAnsuulCorrupt2 then
    local targetUnitTag = SSEA.units[targetUnitId].tag
        if targetUnitTag == "player" then
            CombatAlerts.AlertCast(abilityId, "Corrupt", 2000, { -1, 1 }) -- average time?
            CombatAlerts.Alert("", "Roll This", 0x00CC00D9, SOUNDS.DUEL_START, 3000)
    -- CombatAlerts.CastAlertsStart(abilityId, "Knife Blast" , 2750, 2750, { 0.8, 0, 0, 0.4 } )
    -- or should i use something like this:
    -- CombatAlerts.AlertCast(abilityId, sourceName, 2000, { -2, 2 })
    end
  end

  -- Old code
  if result == ACTION_RESULT_BEGIN and abilityId == SSEA.data.ansuul_enragedatronachinferno then
    -- CombatAlerts.Alert("", "Fire Bombs!", 0xB0E0E6D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    if SSEA.savedVariables.showAnsuulEnragedAtroInfernoWarnings then
        --CombatAlerts.Alert("", "Shrapnel!", 0xFF0000FF, SOUNDS.DUEL_START, 5000)
        --SSEA.status.AnsuulHowManyInfernoToInterrupt = SSEA.status.AnsuulHowManyInfernoToInterrupt + 1
        -- color used to be green: 0x00CC00FF
        CombatAlerts.Alert("Interrupt Atro", GetFormattedAbilityName(abilityId), 0xCC0000D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
        -- Ideally this notification is only shown when it's channeling, then if it's interrupted, it's hidden.
        -- it can go up to 10 seconds perhaps
    end
  end

  if result == ACTION_RESULT_BEGIN_CHANNEL and abilityId == SSEA.data.ansuul_enragedatronachinferno then
    -- CombatAlerts.Alert("", "Fire Bombs!", 0xB0E0E6D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    if SSEA.savedVariables.showAnsuulEnragedAtroInfernoWarnings2 then
        --CombatAlerts.Alert("", "Shrapnel!", 0xFF0000FF, SOUNDS.DUEL_START, 5000)
        SSEA.status.AnsuulHowManyInfernoToInterrupt = SSEA.status.AnsuulHowManyInfernoToInterrupt + 1
        -- color used to be green: 0x00CC00FF
        CombatAlerts.Alert("Interrupt Atro", GetFormattedAbilityName(abilityId), 0xCC0000D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
        -- Ideally this notification is only shown when it's channeling, then if it's interrupted, it's hidden.
        -- it can go up to 10 seconds perhaps
        -- in order to accomplish this, I can use an alert 
    end
  end

  if result == ACTION_RESULT_INTERRUPT and abilityId == SSEA.data.ansuul_enragedatronachinferno then
    if SSEA.savedVariables.showAnsuulEnragedAtroInfernoWarnings2 then
        SSEA.status.AnsuulHowManyInfernoToInterrupt = SSEA.status.AnsuulHowManyInfernoToInterrupt - 1
    end
  end

  -- counting how many Enraged Atronachs are alive
  -- there are a few ways of doing this:
  -- if an atro casts Flare or Inferno then it's alive. if it doesn't cast either then it's dead.
  -- sourceUnitId
  -- if an atro casts Flare with a SourceUnitID that hasn't been seen by a list, then i can add it to a list of atro's. then I can check if the object of SourceUnitID is dead with "isUnitDead(string unitTag)" maybe
  if result == ACTION_RESULT_BEGIN and abilityId == SSEA.data.ansuul_enragedatronachinferno then
    -- CombatAlerts.Alert("", "Fire Bombs!", 0xB0E0E6D9, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
    if SSEA.savedVariables.debugMode then
        -- d("Inferno cast from Enraged Atronach with Source Unit ID/Source Name of: " .. sourceUnitId .. "/" .. sourceName .. ".")
        --CombatAlerts.Alert("", "Shrapnel!", 0xFF0000FF, SOUNDS.DUEL_START, 5000)
        --SSEA.status.AnsuulHowManyInfernoToInterrupt = SSEA.status.AnsuulHowManyInfernoToInterrupt + 1
        -- CombatAlerts.Alert("Interrupt", GetFormattedAbilityName(abilityId), 0x00CC00FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
        -- Ideally this notification is only shown when it's channeling, then if it's interrupted, it's hidden.
        -- it can go up to 10 seconds perhaps
    end
  end

  if result == ACTION_RESULT_BEGIN and 
    (abilityId == SSEA.data.ansuul_manicphobia
    or abilityId == SSEA.data.ansuul_manicphobia2
    or abilityId == SSEA.data.ansuul_manicphobia3
    or abilityId == SSEA.data.ansuul_manicphobia4) then
    SSEA.status.lastAnsuulManicPhobia = GetGameTimeSeconds()
    if SSEA.savedVariables.showCombatAlertAnsuulManicPhobia then
        
        local manicPhobiaPlayersName = SSEA.units[targetUnitId].name
        CombatAlerts.Alert("", "Manic Phobia (" .. manicPhobiaPlayersName .. ")", 0xFFFFFF, SOUNDS.DUEL_START, 3000)
        -- Was Red: 0xCC0000D9
        -- Now white/blue: 0xFFFFFF
    end
  end

end

function SSEA.AddGroundIconOnPlayerForDuration(unitTag, texture, durationMillisec)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  local name = SSEA.name .. "AddGroundIconOnPlayerForDuration" .. unitTag

  local icon = SSEA.AddGroundCustomIcon(px, py, pz, texture)
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    SSEA.DiscardPositionIconList({icon})
    end )

  table.insert(SSEA.status.durationIconsForPreviousInstance, icon)
end

function SSEA.ClearZoneIcons()
    OSI.ResetMechanicIcons()
    SSEA.DiscardPositionIconList(SSEA.status.durationIconsForPreviousInstance)
    SSEA.status.durationIconsForPreviousInstance = {}
    if SSEA.savedVariables.debugMode then
        d("just ran SSEA.ClearZoneIcons()")
    end
end

function SSEA.AddGroundCustomIcon(x, y, z, filePath)
  if SSEA.hasOSI() then
      return OSI.CreatePositionIcon(
        x, y, z,
        filePath,
        2 * OSI.GetIconSize())
  end
  return nil
end

function SSEA.DiscardPositionIconList(iconList)
  if iconList == nil or not SSEA.hasOSI() then
    return
  end
  for k, v in pairs(iconList) do
    if v ~= nil then
      OSI.DiscardPositionIcon(v)
    end
  end
  -- NOTE THIS WILL NOT UPDATE BY REFERENCE THE PASSED LIST.
  iconList = {}
end

function SSEA.DiscardPositionIconListForInstanceUponPortingIn(iconList)
  if iconList == nil or not SSEA.hasOSI() then
    return
  end
  for k, v in pairs(iconList) do
    if v ~= nil then
      OSI.DiscardPositionIcon(v)
    end
  end
  -- NOTE THIS WILL NOT UPDATE BY REFERENCE THE PASSED LIST.
  iconList = {}
end

function SSEA.GetDist(x1, y1, z1, x2, y2, z2)
  local dx = x1 - x2
  local dy = y1 - y2
  local dz = z1 - z2
  return dx*dx + dy*dy + dz*dz
end

-- TODO: Split this into methods
--       UpdateOaxiltso(timeSec, isHardmode, hp, ...)
--       UpdateBahsei(timeSec, isHardmode, hp, ...)
--       UpdateXalvakka(timeSec, isHardmode, hp, ...)
function SSEA.UpdateTick(gameTimeMs)
  local timeSec = GetGameTimeSeconds()
  
  -- update icons even out of combat
  -- check if OdySupportIcons is active
  if SSEA.hasOSI() then
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
  end
  
  if IsUnitInCombat("boss1") then
    SSEA.status.inCombat = true
  end

  if SSEA.status.inCombat == false then
    -- Resetting trackers
    SSEA.status.lastYaseylaFireBombs = 0
    SSEA.status.firstFireBombThrown = false
    SSEA.status.lastYaseylaShrapnel = 0
    SSEA.status.startYaseylaWamasuOverwhelmingLightning = 0
    SSEA.status.lastYaseylaTombFrostBomb = 0
    SSEAStatusLabel1Value:SetText("Incoming")
    SSEAStatusLabel2Value:SetText("Incoming")
    SSEA.status.yaseylaIsSeething = false
    if SSEA.savedVariables.showYaseylaContramagisArcherMarkers2 then
        SSEA.status.yaseylaContramagisArcherCount = 1
    else
        SSEA.status.yaseylaContramagisArcherCount = 8
    end
    if SSEA.savedVariables.showTrashDisruptorMarkers2 then
        SSEA.status.trashDisruptorCount = 1
    else
        SSEA.status.trashDisruptorCount = 8
    end
    if SSEA.savedVariables.showAnsuulEnragedFragmentMarkers2 then
        SSEA.status.ansuulEnragedFragmentCount = 1
    else
        SSEA.status.ansuulEnragedFragmentCount = 8
    end
    if not SSEA.unlockedUI then
        SSEA.HideAllUI(true)
    end
    -- might need this hide all here
    return
  end

  -- might need to take this part out:
  local showPercentageNotiForYaseylaWamaArch = false
  local showPercentageNotiForYaseylaPortalArch = false
  local showPercentageNotiForYaseylaShrapnel = false
  local showPercentageNotiForAnsuulManicPhobia = false
  local showPercentageNotiForAnsuulMazes = false

  -- Boss 1: Exarchanic Yaseyla
  if SSEA.status.is_yaseyla then
    local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
    local bossPercentage = currentTargetHP / maxTargetHP
    
    if SSEA.status.is_hm_boss or SSEA.savedVariables.enabledOnNonHM then
        -- SSEAStatusLabel2:SetColor("00a8e1") --blue

        -- Wamasus + Archers
        local wamasuAndArchersIn = 0
        if 0.901 < bossPercentage and bossPercentage < 0.95  then
            wamasuAndArchersIn = (bossPercentage - 0.9)*100
        elseif 0.701 < bossPercentage and bossPercentage < 0.75 then
            wamasuAndArchersIn = (bossPercentage - 0.7)*100
        elseif 0.501 < bossPercentage and bossPercentage < 0.55 then
            wamasuAndArchersIn = (bossPercentage - 0.5)*100
        elseif 0.301 < bossPercentage and bossPercentage < 0.35 then
            wamasuAndArchersIn = (bossPercentage - 0.3)*100
        elseif 0.201 < bossPercentage and bossPercentage < 0.25 then
            wamasuAndArchersIn = (bossPercentage - 0.2)*100
        elseif 0.101 < bossPercentage and bossPercentage < 0.15 then
            wamasuAndArchersIn = (bossPercentage - 0.1)*100
        else
            wamasuAndArchersIn = 0
        end

        if wamasuAndArchersIn > 0 then
            local txtDuration = tostring(string.format("%.1f", wamasuAndArchersIn))
            SSEAPercentagesLabel:SetText("Wamasu + Archers in: " .. txtDuration .. "%")
            SSEAPercentages:SetHidden(not SSEA.savedVariables.showYaseylaPercentageNotifications)
            showPercentageNotiForYaseylaWamaArch = true
        else
            showPercentageNotiForYaseylaWamaArch = false
        end

        if 0.901 < bossPercentage and bossPercentage < 1  then
            SSEAStatusLabel3Value:SetText("90%")
            SSEAStatusLabel3Value:SetHidden(not SSEA.savedVariables.showYaseylaWamasuWarnings)
        elseif 0.701 < bossPercentage and bossPercentage < 0.90 then
            SSEAStatusLabel3Value:SetText("70%")
            SSEAStatusLabel3Value:SetHidden(not SSEA.savedVariables.showYaseylaWamasuWarnings)
        elseif 0.501 < bossPercentage and bossPercentage < 0.70 then
            SSEAStatusLabel3Value:SetText("50%")
            SSEAStatusLabel3Value:SetHidden(not SSEA.savedVariables.showYaseylaWamasuWarnings)
        elseif 0.301 < bossPercentage and bossPercentage < 0.50 then
            SSEAStatusLabel3Value:SetText("30%")
            SSEAStatusLabel3Value:SetHidden(not SSEA.savedVariables.showYaseylaWamasuWarnings)
        elseif 0.201 < bossPercentage and bossPercentage < 0.30 then
            SSEAStatusLabel3Value:SetText("20%")
            SSEAStatusLabel3Value:SetHidden(not SSEA.savedVariables.showYaseylaWamasuWarnings)
        elseif 0.101 < bossPercentage and bossPercentage < 0.20 then
            SSEAStatusLabel3Value:SetText("10%")
            SSEAStatusLabel3Value:SetHidden(not SSEA.savedVariables.showYaseylaWamasuWarnings)
        else
            SSEAStatusLabel3Value:SetText("None")
        end

        -- Archers and Portals
        local portalsIn = 0
        if 0.601 < bossPercentage and bossPercentage < 0.65  then
            wamasuAndArchersIn = (bossPercentage - 0.6)*100
        elseif 0.351 < bossPercentage and bossPercentage < 0.40 then
            wamasuAndArchersIn = (bossPercentage - 0.35)*100
        else
            wamasuAndArchersIn = 0
        end

        if wamasuAndArchersIn > 0 then
            local txtDuration = tostring(string.format("%.1f", wamasuAndArchersIn))
            SSEAPercentagesLabel:SetText("Portals + Archers in: " .. txtDuration .. "%")
            SSEAPercentages:SetHidden(not SSEA.savedVariables.showYaseylaPortalWarnings)
            showPercentageNotiForYaseylaPortalArch = true
        else
            showPercentageNotiForYaseylaPortalArch = false
        end

        if 0.601 < bossPercentage and bossPercentage < 1  then
            SSEAStatusLabel5Value:SetText("60%")
            SSEAStatusLabel5Value:SetHidden(not SSEA.savedVariables.showYaseylaPortalWarnings)
        elseif 0.351 < bossPercentage and bossPercentage < 0.60 then
            SSEAStatusLabel5Value:SetText("35%")
            SSEAStatusLabel5Value:SetHidden(not SSEA.savedVariables.showYaseylaPortalWarnings)
        else
            SSEAStatusLabel5Value:SetText("None")
            SSEAStatusLabel5Value:SetHidden(not SSEA.savedVariables.showYaseylaPortalWarnings)
        end

        -- Enraged Yaseyla Alert
        if SSEA.status.yaseylaIsSeething then
            SSEAAlerts3Label:SetText("Enraged Yaseyla!")
            SSEAAlerts3:SetHidden(not SSEA.savedVariables.showYaseylaEnragedAlert)
        else
            SSEAAlerts3:SetHidden(true)
        end

        -- Shrapnel
        -- Status Labels
        local nextShrapnelAt = 0
        if 0.801 < bossPercentage and bossPercentage < 1  then
            nextShrapnelAt = "80"
        elseif 0.551 < bossPercentage and bossPercentage < 0.80 then
            nextShrapnelAt = "55"
        elseif 0.251 < bossPercentage and bossPercentage < 0.55 then
            nextShrapnelAt = "25"
        elseif 0.201 < bossPercentage and bossPercentage < 0.25 then
            nextShrapnelAt = "20"
        elseif 0.101 < bossPercentage and bossPercentage < 0.20 then
            nextShrapnelAt = "10"
        elseif 0.10 >= bossPercentage and bossPercentage > 0 then
            nextShrapnelAt = (SSEA.status.lastYaseylaShrapnel + 60) - GetGameTimeSeconds()
        else
            nextShrapnelAt = 0
        end

        if (bossPercentage > 0.10) and SSEA.status.is_hm_boss then
            -- SSEAStatusLabel5:SetText("Next Shrapnel: ")
            SSEAStatusLabel4:SetText("Next Shrapnel: ")
            SSEAStatusLabel4:SetHidden(not SSEA.savedVariables.showYaseylaShrapnelWarnings)
            SSEAStatusLabel4Value:SetText(nextShrapnelAt .. "%")
            SSEAStatusLabel4Value:SetHidden(not SSEA.savedVariables.showYaseylaShrapnelWarnings)
        elseif (bossPercentage <= 0.10) and SSEA.status.is_hm_boss then
            local txtDuration = tostring(string.format("%.1f", nextShrapnelAt))
            -- SSEAStatusLabel5:SetText("Next Shrapnel: ")
            SSEAStatusLabel4:SetText("Next Shrapnel: ")
            SSEAStatusLabel4:SetHidden(not SSEA.savedVariables.showYaseylaShrapnelWarnings)
            SSEAStatusLabel4Value:SetText(txtDuration .. "s")
            SSEAStatusLabel4Value:SetHidden(not SSEA.savedVariables.showYaseylaShrapnelWarnings)
        else
            SSEAStatusLabel4:SetHidden(true)
            SSEAStatusLabel4Value:SetHidden(true)
        end

        -- Pop up notification
        if 0.801 < bossPercentage and bossPercentage < 0.85  then
            shrapnelIn = (bossPercentage - 0.8)*100
        elseif 0.551 < bossPercentage and bossPercentage < 0.60 then
            shrapnelIn = (bossPercentage - 0.55)*100
        elseif 0.251 < bossPercentage and bossPercentage < 0.30 then
            shrapnelIn = (bossPercentage - 0.25)*100
        elseif 0.201 < bossPercentage and bossPercentage < 0.25 then
            shrapnelIn = (bossPercentage - 0.25)*100
        elseif 0.201 < bossPercentage and bossPercentage < 0.25 then
            shrapnelIn = (bossPercentage - 0.2)*100
        elseif 0.101 < bossPercentage and bossPercentage < 0.15 then
            shrapnelIn = (bossPercentage - 0.1)*100
        elseif 0.10 > bossPercentage and bossPercentage > 0 then
            shrapnelIn = (SSEA.status.lastYaseylaShrapnel + 60) - GetGameTimeSeconds()
        else
            shrapnelIn = 0
        end

        -- might have to revisit this later
        if (shrapnelIn > 0  and bossPercentage > 0.10 and SSEA.status.is_hm_boss) then
            local txtDuration = tostring(string.format("%.1f", shrapnelIn))
            SSEAPercentagesLabel:SetText("Shrapnel in: " .. txtDuration .. "%")
            SSEAPercentages:SetHidden(not SSEA.savedVariables.showYaseylaPercentageNotifications)
            showPercentageNotiForYaseylaShrapnel = true
        elseif (bossPercentage > 0  and bossPercentage <= 0.10 and SSEA.status.is_hm_boss) then
            if shrapnelIn <= 10 and shrapnelIn > 0 then
                local txtDuration = tostring(string.format("%.1f", shrapnelIn))
                SSEAPercentagesLabel:SetText("Shrapnel in: " .. txtDuration .. "s")
                SSEAPercentages:SetHidden(not SSEA.savedVariables.showYaseylaPercentageNotifications)
                showPercentageNotiForYaseylaShrapnel = true
            elseif shrapnelIn <= 0 then
                SSEAPercentagesLabel:SetText("Shrapnel in: SOON")
                SSEAPercentages:SetHidden(not SSEA.savedVariables.showYaseylaPercentageNotifications)
                showPercentageNotiForYaseylaShrapnel = true
            end
        else
            showPercentageNotiForYaseylaShrapnel = false
        end

        if bossPercentage == 0 and SSEA.status.is_hm_boss then
                SSEAPercentagesLabel:SetText("Shrapnel in: ")
        end

        -- 20% 
        local twentyPercentMulti = 0
        if 0.201 < bossPercentage and bossPercentage < 0.25  then
            twentyPercentMulti = (bossPercentage - 0.2)*100
        else
            twentyPercentMulti = 0
        end

        if twentyPercentMulti > 0  and twentyPercentMulti ~= nil then
            local txtDuration = tostring(string.format("%.1f", twentyPercentMulti))
            if (showYaseylaWamasuWarnings and showYaseylaShrapnelWarnings and SSEA.status.is_hm_boss) then
                SSEAPercentagesLabel:SetText("Shrapnel + Wamasu in: " .. txtDuration .. "%")
                SSEAPercentages:SetHidden(not SSEA.savedVariables.showYaseylaPercentageNotifications)
                showPercentageNotiForYaseylaWamaArch = true
                showPercentageNotiForYaseylaShrapnel = true
            elseif showYaseylaWamasuWarnings and not showYaseylaShrapnelWarnings then
                SSEAPercentagesLabel:SetText("Wamasu in: " .. txtDuration .. "%")
                SSEAPercentages:SetHidden(not SSEA.savedVariables.showYaseylaPercentageNotifications)
                showPercentageNotiForYaseylaWamaArch = true
            elseif (not showYaseylaWamasuWarnings and showYaseylaShrapnelWarnings and SSEA.status.is_hm_boss) then
                SSEAPercentagesLabel:SetText("Shrapnel in: " .. txtDuration .. "%")
                SSEAPercentages:SetHidden(not SSEA.savedVariables.showYaseylaPercentageNotifications)
                showPercentageNotiForYaseylaShrapnel = true
            else
                showPercentageNotiForYaseylaWamaArch = false
                showPercentageNotiForYaseylaShrapnel = false
            end
        else
            showPercentageNotiForYaseylaWamaArch = false
            showPercentageNotiForYaseylaShrapnel = false
        end

        -- Fire Bombs
        --if timeUntilNextFireBombs == null then
            --local timeUntilNextFireBombs = 0 
        --end
        local timeUntilNextFireBombs = 0 
        if 0.99 < bossPercentage or SSEA.status.firstFireBombThrown == false then
            timeUntilNextFireBombs = (SSEA.status.lastYaseylaFireBombs + 7.5) - GetGameTimeSeconds()
            -- Initial Fire Bomb is 7.5s (Credits Sanity's Edge Helper)
        elseif 0.25 < bossPercentage and 0.99 > bossPercentage and SSEA.status.firstFireBombThrown == true then
            if (SSEA.status.lastYaseylaFireBombs + 0.05) > GetGameTimeSeconds() then
                timeUntilNextFireBombs = (SSEA.status.lastYaseylaFireBombs + 23.5) - GetGameTimeSeconds()
            -- updated to 23.5s from 20s (Credits Sanity's Edge Helper)
            end
        elseif 0.25 >= bossPercentage then
            if (SSEA.status.lastYaseylaFireBombs + 0.05) > GetGameTimeSeconds() then
                timeUntilNextFireBombs = (SSEA.status.lastYaseylaFireBombs + 10.5) - GetGameTimeSeconds()
            -- might be 12 (Sanity's Edge Helper), but seems to have a minimum of 10s
            end
        end
        -- local timeUntilNextFireBombs = (SSEA.status.lastYaseylaFireBombs + 20) - GetGameTimeSeconds()

        if timeUntilNextFireBombs > 0 then
            local txtDuration = tostring(string.format("%.1f", timeUntilNextFireBombs))
            SSEAStatusLabel1:SetText("Fire Bombs: ")
            SSEAStatusLabel1Value:SetText(txtDuration .. "s")
            SSEAStatusLabel1Value:SetHidden(not SSEA.savedVariables.showYaseylaFireBombs2)
        else
            SSEAStatusLabel1:SetText("Fire Bombs: ")
            SSEAStatusLabel1Value:SetText("Incoming")
            SSEAStatusLabel1Value:SetHidden(not SSEA.savedVariables.showYaseylaFireBombs2)
        end
        
        -- later can implement a feature where if the cone stops early then can cancel the notification
        local overwhelmingLightningDuration = (SSEA.status.startYaseylaWamasuOverwhelmingLightning + 10) - GetGameTimeSeconds()
        if overwhelmingLightningDuration > 0 and SSEA.savedVariables.showYaseylaWamasuConeCountdown then
            local txtDuration = tostring(string.format("%.1f", overwhelmingLightningDuration))
            -- SSEAAlertsLabel:SetText("Fire Bombs: ")
            SSEAAlertsLabel:SetText("Wamasu Cone: ~" .. txtDuration .. "s")
            SSEAAlerts:SetHidden(not SSEA.savedVariables.showYaseylaAlerts)
        else
            SSEAAlerts:SetHidden(true)
        end

        local timeUntilNextTombFrostBomb = (SSEA.status.lastYaseylaTombFrostBomb + 30) - GetGameTimeSeconds()
        if timeUntilNextTombFrostBomb > 25 and timeUntilNextTombFrostBomb < 30 then
            local txtDuration = tostring(string.format("%.1f", timeUntilNextTombFrostBomb))
            -- SSEAStatusLabel1:SetText("Fire Bombs: ")
            SSEAStatusLabel2Value:SetText(txtDuration .. "s")
            SSEAStatusLabel2Value:SetHidden(not SSEA.savedVariables.showYaseylaFrostBombs)
            SSEAAlerts2Label:SetText("Ice Tombs!")
            SSEAAlerts2:SetHidden(not SSEA.savedVariables.showYaseylaFrostBombs)
        elseif timeUntilNextTombFrostBomb < 25 and timeUntilNextTombFrostBomb > 0 then
            local txtDuration = tostring(string.format("%.1f", timeUntilNextTombFrostBomb))
            -- SSEAStatusLabel1:SetText("Fire Bombs: ")
            SSEAStatusLabel2Value:SetText(txtDuration .. "s")
            SSEAStatusLabel2Value:SetHidden(not SSEA.savedVariables.showYaseylaFrostBombs)
            SSEAAlerts2:SetHidden(true)
        else
            SSEAStatusLabel2Value:SetText("Incoming")
            SSEAStatusLabel2Value:SetHidden(not SSEA.savedVariables.showYaseylaFrostBombs)
        end
        -- local timeUntilNextFireBombs = (SSEA.status.lastYaseylaFireBombs + 20) - GetGameTimeSeconds()

        -- if timeUntilNextFireBombs > 0 then
            -- local txtDuration = tostring(string.format("%.1f", timeUntilNextFireBombs))
            -- SSEAStatusLabel1:SetText("Fire Bombs: ")
            -- SSEAStatusLabel1Value:SetText(txtDuration .. "s")
            -- SSEAStatusLabel1Value:SetHidden(not SSEA.savedVariables.showYaseylaFireBombs2)
        -- else
            -- SSEAStatusLabel1:SetText("Fire Bombs: ")
            -- SSEAStatusLabel1Value:SetText("Incoming")
            -- SSEAStatusLabel1Value:SetHidden(not SSEA.savedVariables.showYaseylaFireBombs2)
        -- end
            
    end

    -- End of Custom

    -- if SSEA.status.onBlob then
        -- SSEAPercentagesLabel:SetText("ON BLOB")
        -- SSEAPercentages:SetHidden(not SSEA.savedVariables.showXalvakkaOnBlob)
    -- else
        -- SSEAPercentages:SetHidden(true)
    -- end

    -- Status panel for Xalvakka
    SSEAStatus:SetHidden(false)
  end

   -- Boss 2: Chimera
  if SSEA.status.is_chimera or SSEA.status.is_twelvane or SSEA.status.chimeraActive then
    local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
    local bossPercentage = currentTargetHP / maxTargetHP
    
    -- if SSEA.status.is_hm_boss or SSEA.savedVariables.enabledOnNonHM then

    -- SSEA.data.chimera_arcticshred
    -- SSEA.status.lastArcticShredTime
    -- SSEA.savedVariables.showChimeraArcticShredAlerts
    if SSEA.savedVariables.showChimeraArcticShredAlerts then
        local timeUntilNextArcticShred = (SSEA.status.lastArcticShredTime + 5.5) - GetGameTimeSeconds()
        local arcticShredTxtDuration = ""
        if timeUntilNextArcticShred > 0 then
            arcticShredTxtDuration = tostring(string.format("%.1f", timeUntilNextArcticShred))
            SSEAAlerts2Label:SetText("Arctic Shred: " .. arcticShredTxtDuration .. "s")
            SSEAAlerts2:SetHidden(not SSEA.savedVariables.showChimeraArcticShredAlerts)
            -- SSEAStatusLabel2Value:SetText(arcticShredTxtDuration .. "s")
            -- SSEAStatusLabel2Value:SetHidden(not SSEA.savedVariables.showChimeraArcticShredAlerts)
        elseif timeUntilNextArcticShred > -5 and timeUntilNextArcticShred < 0 then
            -- arcticShredTxtDuration = tostring(string.format("%.1f", timeUntilNextArcticShred))
            SSEAAlerts2Label:SetText("Arctic Shred: Incoming")
            SSEAAlerts2:SetHidden(not SSEA.savedVariables.showChimeraArcticShredAlerts)
            -- SSEAStatusLabel2Value:SetText"Incoming")
            -- SSEAStatusLabel2Value:SetHidden(not SSEA.savedVariables.showChimeraArcticShredAlerts)
        else
            SSEAAlerts2:SetHidden(true)
            -- SSEAStatusLabel2Value:SetHidden(true)
        end
    end



    if SSEA.savedVariables.showChimeraPanel2 and SSEA.status.chimeraActive then
        if SSEA.status.lastTankToGetChainLightning ~= nil then
            SSEAStatusLabel41:SetText("Previous Chained Tank: ")
            SSEAStatusLabel41Value:SetText(SSEA.status.lastTankToGetChainLightning)
            SSEAStatusLabel41:SetHidden(not SSEA.savedVariables.showChimeraPanel2)
            SSEAStatusLabel41Value:SetHidden(not SSEA.savedVariables.showChimeraPanel2)
        else
            SSEAStatusLabel41:SetHidden(true)
            SSEAStatusLabel41Value:SetHidden(true)
        end
    end

    --end

    SSEAStatus:SetHidden(false)
  end

  -- Boss 3: Ansuul the Tormentor
  if SSEA.status.is_ansuul then
    local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
    local bossPercentage = currentTargetHP / maxTargetHP
    
    if SSEA.status.is_hm_boss or SSEA.savedVariables.enabledOnNonHM then
        -- Essence Manifestation
        -- changing showAnsuulManicPhobiaWarnings showAnsuulForesightPanel

        local manicPhobiaIn = 0
        local manicPhobiaUnit = "%"
        if 0.91 < bossPercentage and bossPercentage < 0.95  then
            manicPhobiaIn = (bossPercentage - 0.91)*100
        elseif 0.71 < bossPercentage and bossPercentage < 0.75 then
            manicPhobiaIn = (bossPercentage - 0.71)*100
        elseif 0.51 < bossPercentage and bossPercentage < 0.55 then
            manicPhobiaIn = (bossPercentage - 0.51)*100
        elseif 0.31 < bossPercentage and bossPercentage < 0.35 then
            manicPhobiaIn = (bossPercentage - 0.31)*100
        -- elseif 0.191 < bossPercentage and bossPercentage < 0.199 then
            -- manicPhobiaIn = (bossPercentage - 0.19)*100
        -- elseif 0.101 < bossPercentage and bossPercentage < 0.15 then
            -- manicPhobiaIn = (bossPercentage - 0.1)*100
        elseif 0.0 < bossPercentage and bossPercentage < 0.18 then
            manicPhobiaIn = (SSEA.status.lastAnsuulManicPhobia + 25) - GetGameTimeSeconds()
            manicPhobiaUnit = "s"
        else
            manicPhobiaIn = 0
        end
        if (SSEA.savedVariables.showAnsuulManicPhobiaWarnings) then
            
            if  manicPhobiaIn > 0 and manicPhobiaIn < 10 then
                local txtDuration = tostring(string.format("%.1f", manicPhobiaIn))
                SSEAPercentagesLabel:SetText("Manic Phobia in: ~" .. txtDuration .. manicPhobiaUnit)
                SSEAPercentages:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaWarnings)
                showPercentageNotiForAnsuulManicPhobia = true
            elseif manicPhobiaIn < 0 then
                if 0.0 < bossPercentage and bossPercentage < 0.099 then
                    SSEAPercentagesLabel:SetText("Manic Phobia in: SOON")
                    SSEAPercentages:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaWarnings)
                    showPercentageNotiForAnsuulManicPhobia = true
                end
            else
                showPercentageNotiForAnsuulManicPhobia = false
            end
            if ((SSEA.status.lastAnsuulManicPhobia + 3) >= GetGameTimeSeconds()) and showPercentageNotiForAnsuulManicPhobia then
                SSEAPercentages:SetHidden(true)
                showPercentageNotiForAnsuulManicPhobia = false
            end
        end

        local txtDuration = tostring(string.format("%.1f", manicPhobiaIn))
        if (SSEA.savedVariables.showAnsuulForesightPanel and SSEA.savedVariables.showAnsuulManicPhobiaInfo) then
            local manicPhobiaPercent = 0
            local manicPhobiaTextDuration = ""
            if 0.91 < bossPercentage and bossPercentage < 1  then
                manicPhobiaPercent = (bossPercentage - 0.91) * 100
                manicPhobiaTextDuration = tostring(string.format("%.1f", manicPhobiaPercent))
                SSEAStatusLabel4:SetText("Manic Phobia: ")
                SSEAStatusLabel4Value:SetText(manicPhobiaTextDuration .. "%")
                SSEAStatusLabel4:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
                SSEAStatusLabel4Value:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
            elseif 0.71 < bossPercentage and bossPercentage < 0.90 then
                manicPhobiaPercent = (bossPercentage - 0.71) * 100
                manicPhobiaTextDuration = tostring(string.format("%.1f", manicPhobiaPercent))
                SSEAStatusLabel4:SetText("Manic Phobia: ")
                SSEAStatusLabel4Value:SetText(manicPhobiaTextDuration .. "%")
                SSEAStatusLabel4:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
                SSEAStatusLabel4Value:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
            elseif 0.51 < bossPercentage and bossPercentage < 0.70 then
                manicPhobiaPercent = (bossPercentage - 0.51) * 100
                manicPhobiaTextDuration = tostring(string.format("%.1f", manicPhobiaPercent))
                SSEAStatusLabel4:SetText("Manic Phobia: ")
                SSEAStatusLabel4Value:SetText(manicPhobiaTextDuration .. "%")
                SSEAStatusLabel4:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
                SSEAStatusLabel4Value:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
            elseif 0.31 < bossPercentage and bossPercentage < 0.50 then
                manicPhobiaPercent = (bossPercentage - 0.31) * 100
                manicPhobiaTextDuration = tostring(string.format("%.1f", manicPhobiaPercent))
                SSEAStatusLabel4:SetText("Manic Phobia: ")
                SSEAStatusLabel4Value:SetText(manicPhobiaTextDuration .. "%")
                SSEAStatusLabel4:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
                SSEAStatusLabel4Value:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
            elseif 0.185 < bossPercentage and bossPercentage < 0.30 then
                SSEAStatusLabel4:SetText("Manic Phobia: ")
                SSEAStatusLabel4Value:SetText("20% After Split")
                SSEAStatusLabel4:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
                SSEAStatusLabel4Value:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
                -- bug here:
            elseif 0.125 < bossPercentage and bossPercentage < 0.18 then
                manicPhobiaPercent = (bossPercentage - 0.125) * 100
                manicPhobiaTextDuration = tostring(string.format("%.1f", manicPhobiaPercent))
                SSEAStatusLabel4:SetText("Manic Phobia: ")
                SSEAStatusLabel4Value:SetText(manicPhobiaTextDuration .. "% or " .. txtDuration .. "s")
                SSEAStatusLabel4:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
                SSEAStatusLabel4Value:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
            else
                SSEAStatusLabel4:SetText("Manic Phobia: ")
                SSEAStatusLabel4Value:SetText(txtDuration)
                SSEAStatusLabel4:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
                SSEAStatusLabel4Value:SetHidden(not SSEA.savedVariables.showAnsuulManicPhobiaInfo)
            end
        else
            SSEAStatusLabel4:SetHidden(true)
            SSEAStatusLabel4Value:SetHidden(true)
        end

        -- Maze
        if (SSEA.savedVariables.showAnsuulMazeWarnings) then
            local mazeIn = 0
            if 0.805 < bossPercentage and bossPercentage < 0.85  then
                mazeIn = (bossPercentage - 0.805)*100
            elseif 0.605 < bossPercentage and bossPercentage < 0.65 then
                mazeIn = (bossPercentage - 0.605)*100
            elseif 0.405 < bossPercentage and bossPercentage < 0.45 then
                mazeIn = (bossPercentage - 0.405)*100
            else
                mazeIn = 0
            end

            if mazeIn > 0 then
                local txtDuration = tostring(string.format("%.1f", mazeIn))
                SSEAPercentagesLabel:SetText("Maze in: " .. txtDuration .. "%")
                SSEAPercentages:SetHidden(not SSEA.savedVariables.showAnsuulMazeWarnings)
                showPercentageNotiForAnsuulMazes = true
            else
                showPercentageNotiForAnsuulMazes = false
            end
        end

        if (SSEA.savedVariables.showAnsuulForesightPanel and SSEA.savedVariables.showAnsuulMazeInfo) then
            -- SSEAStatusLabel2:SetColor("ffffff") -- white
            -- SSEAStatusLabel2:SetColor("ffcf40")
            local mazePercent = 0
            local mazeTextDuration = ""
            if 0.805 < bossPercentage and bossPercentage < 1  then
                mazePercent = (bossPercentage - 0.805) * 100
                mazeTextDuration = tostring(string.format("%.1f", mazePercent))
                SSEAStatusLabel23:SetText("Next Maze: ")
                SSEAStatusLabel23Value:SetText(mazeTextDuration .. "%")
                SSEAStatusLabel23:SetHidden(not SSEA.savedVariables.showAnsuulMazeInfo)
                SSEAStatusLabel23Value:SetHidden(not SSEA.savedVariables.showAnsuulMazeInfo)
            elseif 0.605 < bossPercentage and bossPercentage < 0.80 then
                mazePercent = (bossPercentage - 0.605) * 100
                mazeTextDuration = tostring(string.format("%.1f", mazePercent))
                SSEAStatusLabel23:SetText("Next Maze: ")
                SSEAStatusLabel23Value:SetText(mazeTextDuration .. "%")
                SSEAStatusLabel23:SetHidden(not SSEA.savedVariables.showAnsuulMazeInfo)
                SSEAStatusLabel23Value:SetHidden(not SSEA.savedVariables.showAnsuulMazeInfo)
            elseif 0.405 < bossPercentage and bossPercentage < 0.60 then
                mazePercent = (bossPercentage - 0.405) * 100
                mazeTextDuration = tostring(string.format("%.1f", mazePercent))
                SSEAStatusLabel23:SetText("Next Maze: ")
                SSEAStatusLabel23Value:SetText(mazeTextDuration .. "%")
                SSEAStatusLabel23:SetHidden(not SSEA.savedVariables.showAnsuulMazeInfo)
                SSEAStatusLabel23Value:SetHidden(not SSEA.savedVariables.showAnsuulMazeInfo)
            else
                SSEAStatusLabel23:SetText("Next Maze: ")
                SSEAStatusLabel23Value:SetText("None")
                SSEAStatusLabel23:SetHidden(not SSEA.savedVariables.showAnsuulMazeInfo)
                SSEAStatusLabel23Value:SetHidden(not SSEA.savedVariables.showAnsuulMazeInfo)
            end
        else
            SSEAStatusLabel23:SetHidden(true)
            SSEAStatusLabel23Value:SetHidden(true)
        end

        -- SSEA.status.lastAnsuulWrack
        -- Credits to HyperAlerts for the data on duration and change in duration at 20 percent
        if (SSEA.savedVariables.showAnsuulForesightPanel and SSEA.savedVariables.showAnsuulWrackInfo) then
            -- SSEAStatusLabel2:SetColor("ffffff") -- white
            -- SSEAStatusLabel2:SetColor("ffcf40")
            if 0.205 < bossPercentage and bossPercentage < 1  then
                local nextWrack = (SSEA.status.lastAnsuulWrack + 40) - GetGameTimeSeconds()
                local nextWrackTextDuration = tostring(string.format("%.1f", nextWrack))

                if 0 < nextWrack and nextWrack < 40 then
                    SSEAStatusLabel33:SetText("Wrack: ")
                    SSEAStatusLabel33Value:SetText(nextWrackTextDuration .. "s")
                    SSEAStatusLabel33:SetHidden(not SSEA.savedVariables.showAnsuulWrackInfo)
                    SSEAStatusLabel33Value:SetHidden(not SSEA.savedVariables.showAnsuulWrackInfo)
                elseif -30 < nextWrack and nextWrack < 0 then
                    SSEAStatusLabel33:SetText("Wrack: ")
                    SSEAStatusLabel33Value:SetText("Incoming")
                    SSEAStatusLabel33:SetHidden(not SSEA.savedVariables.showAnsuulWrackInfo)
                    SSEAStatusLabel33Value:SetHidden(not SSEA.savedVariables.showAnsuulWrackInfo)
                else
                    SSEAStatusLabel33:SetText("Wrack: ")
                    SSEAStatusLabel33Value:SetText("")
                    SSEAStatusLabel33:SetHidden(not SSEA.savedVariables.showAnsuulWrackInfo)
                    SSEAStatusLabel33Value:SetHidden(not SSEA.savedVariables.showAnsuulWrackInfo)
                end
            elseif 0 < bossPercentage and bossPercentage < 0.20 then
                local nextWrack = (SSEA.status.lastAnsuulWrack + 25) - GetGameTimeSeconds()
                local nextWrackTextDuration = tostring(string.format("%.1f", nextWrack))

                if 0 < nextWrack and nextWrack < 25 then
                    SSEAStatusLabel33:SetText("Wrack: ")
                    SSEAStatusLabel33Value:SetText(nextWrackTextDuration .. "s")
                    SSEAStatusLabel33:SetHidden(not SSEA.savedVariables.showAnsuulWrackInfo)
                    SSEAStatusLabel33Value:SetHidden(not SSEA.savedVariables.showAnsuulWrackInfo)
                elseif -30 < nextWrack and nextWrack < 0 then
                    SSEAStatusLabel33:SetText("Wrack: ")
                    SSEAStatusLabel33Value:SetText("Incoming")
                    SSEAStatusLabel33:SetHidden(not SSEA.savedVariables.showAnsuulWrackInfo)
                    SSEAStatusLabel33Value:SetHidden(not SSEA.savedVariables.showAnsuulWrackInfo)
                else
                    SSEAStatusLabel33:SetText("Wrack: ")
                    SSEAStatusLabel33Value:SetText("")
                    SSEAStatusLabel33:SetHidden(not SSEA.savedVariables.showAnsuulWrackInfo)
                    SSEAStatusLabel33Value:SetHidden(not SSEA.savedVariables.showAnsuulWrackInfo)
                end
            else
                SSEAStatusLabel33:SetHidden(true)
                SSEAStatusLabel33Value:SetHidden(true)
            end
        else
            SSEAStatusLabel33:SetHidden(true)
            SSEAStatusLabel33Value:SetHidden(true)
        end

        if SSEA.status.AnsuulHowManyInfernoToInterrupt > 0 and SSEA.savedVariables.showAnsuulEnragedAtroInfernoAlerts then
             local txtAtroInfernoCounter = tostring(string.format("%f", SSEA.status.AnsuulHowManyInfernoToInterrupt))
             SSEAAlertsLabel:SetText("Fire Bombs: ")
             SSEAAlertsLabel:SetText("Interrupt " .. SSEA.status.AnsuulHowManyInfernoToInterrupt .. "x Inferno")
            SSEAAlerts:SetHidden(not SSEA.savedVariables.showAnsuulEnragedAtroInfernoAlerts)
        else
            SSEAAlerts:SetHidden(true)
        end

    end

    SSEAStatus:SetHidden(false)

  end

  if (showPercentageNotiForYaseylaWamaArch or
      showPercentageNotiForYaseylaPortalArch or
      showPercentageNotiForYaseylaShrapnel or
      showPercentageNotiForAnsuulManicPhobia or
      showPercentageNotiForAnsuulMazes) then
    SSEAPercentages:SetHidden(false)
  else
    SSEAPercentages:SetHidden(true)
  end

end

-- Credits to andy.s for this feature from Infinite Archive Helper
-- Mark Contramagis Archer foes
-- EVENT_TARGET_MARKER_UPDATE
function SSEA.ReticleChanged()
    if not SSEA.status.is_yaseyla
    and not SSEA.status.is_twelvane
    and not SSEA.status.is_chimera
    and not SSEA.status.is_ansuul then
        --if not LC.savedVariables.orphicEliteAddMarker then return end
        if SSEA.savedVariables.showTrashDisruptorMarkers2 
        or SSEA.savedVariables.showTrashDisruptorMarkersOverride2 then
	        if IsUnitAttackable('reticleover') then
		        -- Mark attackable units in the list, but only as a group leader
		        if IsUnitSoloOrGroupLeader('player') or SSEA.savedVariables.showTrashDisruptorMarkersOverride2 then
			        local name = zo_strformat('<<1>>', GetUnitName('reticleover'))
			        if SSEA.data.trash_disruptor[name] then
                        --for i=1, 9 do
                        if GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[1]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[2]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[3]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[4]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[5]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[6]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[7]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[8] then
                            if SSEA.savedVariables.showTrashDisruptorMarkers2 
                            or SSEA.savedVariables.showTrashDisruptorMarkersOverride2 then
				                AssignTargetMarkerToReticleTarget(SSEA.data.markers[SSEA.status.trashDisruptorCount])
                            end
                            if SSEA.savedVariables.showTrashDisruptorMarkers2 then
                                if SSEA.status.trashDisruptorCount == 8 then
                                    SSEA.status.trashDisruptorCount = 1
                                else
                                    SSEA.status.trashDisruptorCount = SSEA.status.trashDisruptorCount + 1
                                end
                            else
                                if SSEA.status.trashDisruptorCount == 1 then
                                    SSEA.status.trashDisruptorCount = 8
                                else
                                    SSEA.status.trashDisruptorCount = SSEA.status.trashDisruptorCount - 1
                                end
                            end
                        end
			        end
                end
	        elseif GetUnitTargetMarkerType('reticleover') ~= TARGET_MARKER_TYPE_NONE then
		        -- Remove marker if it's on a wrong target (can happen to companions or group members)
		        AssignTargetMarkerToReticleTarget(GetUnitTargetMarkerType('reticleover'))
            else
		        AssignTargetMarkerToReticleTarget(GetUnitTargetMarkerType('reticleover'))
	        end
            if IsUnitFriendlyFollower("reticleover") then
                AssignTargetMarkerToReticleTarget(GetUnitTargetMarkerType('reticleover'))
	        end
        end
    elseif SSEA.status.is_yaseyla then
	    --if not LC.savedVariables.orphicEliteAddMarker then return end
        if SSEA.savedVariables.showYaseylaContramagisArcherMarkers2 
        or SSEA.savedVariables.showYaseylaContramagisArcherMarkersOverride2 then
	        if IsUnitAttackable('reticleover') then
		        -- Mark attackable units in the list, but only as a group leader
		        if IsUnitSoloOrGroupLeader('player') 
                or SSEA.savedVariables.showYaseylaContramagisArcherMarkersOverride2 then
			        local name = zo_strformat('<<1>>', GetUnitName('reticleover'))
			        if SSEA.data.yaseyla_contramagis_archer[name] then
                        --for i=1, 9 do
                        if GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[1]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[2]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[3]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[4]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[5]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[6]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[7]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[8] then
                            if SSEA.savedVariables.showYaseylaContramagisArcherMarkers2 
                            or SSEA.savedVariables.showYaseylaContramagisArcherMarkersOverride2 then
				                AssignTargetMarkerToReticleTarget(SSEA.data.markers[SSEA.status.yaseylaContramagisArcherCount])
                            end
                            if SSEA.savedVariables.showYaseylaContramagisArcherMarkers2 then
                                if SSEA.status.yaseylaContramagisArcherCount == 8 then
                                    SSEA.status.yaseylaContramagisArcherCount = 1
                                else
                                    SSEA.status.yaseylaContramagisArcherCount = SSEA.status.yaseylaContramagisArcherCount + 1
                                end
                            else
                                if SSEA.status.yaseylaContramagisArcherCount == 1 then
                                    SSEA.status.yaseylaContramagisArcherCount = 8
                                else
                                    SSEA.status.yaseylaContramagisArcherCount = SSEA.status.yaseylaContramagisArcherCount - 1
                                end
                            end
                        end
			        end
                end
	        elseif GetUnitTargetMarkerType('reticleover') ~= TARGET_MARKER_TYPE_NONE then
		        -- Remove marker if it's on a wrong target (can happen to companions or group members)
		        AssignTargetMarkerToReticleTarget(GetUnitTargetMarkerType('reticleover'))
            else
		        AssignTargetMarkerToReticleTarget(GetUnitTargetMarkerType('reticleover'))
	        end
            if IsUnitFriendlyFollower("reticleover") then
                AssignTargetMarkerToReticleTarget(GetUnitTargetMarkerType('reticleover'))
            end

        end
    elseif SSEA.status.is_ansuul then
        --if not LC.savedVariables.orphicEliteAddMarker then return end
        if SSEA.savedVariables.showAnsuulEnragedFragmentMarkers2 
        or SSEA.savedVariables.showAnsuulEnragedFragmentMarkersOverride2 then
	        if IsUnitAttackable('reticleover') then
		        -- Mark attackable units in the list, but only as a group leader
		        if IsUnitSoloOrGroupLeader('player') 
                or SSEA.savedVariables.showAnsuulEnragedFragmentMarkersOverride2 then
			        local name = zo_strformat('<<1>>', GetUnitName('reticleover'))
			        if SSEA.data.ansuul_enragedfragment[name] then
                        --for i=1, 9 do
                        if GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[1]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[2]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[3]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[4]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[5]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[6]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[7]
                        and GetUnitTargetMarkerType('reticleover') ~= SSEA.data.markers[8] then
                            if SSEA.savedVariables.showAnsuulEnragedFragmentMarkers2 
                            or SSEA.savedVariables.showAnsuulEnragedFragmentMarkersOverride2 then
				                AssignTargetMarkerToReticleTarget(SSEA.data.markers[SSEA.status.ansuulEnragedFragmentCount])
                            end
                            if SSEA.savedVariables.showAnsuulEnragedFragmentMarkers2 then
                                if SSEA.status.ansuulEnragedFragmentCount == 8 then
                                    SSEA.status.ansuulEnragedFragmentCount = 1
                                else
                                    SSEA.status.ansuulEnragedFragmentCount = SSEA.status.ansuulEnragedFragmentCount + 1
                                end
                            else
                                if SSEA.status.ansuulEnragedFragmentCount == 1 then
                                    SSEA.status.ansuulEnragedFragmentCount = 8
                                else
                                    SSEA.status.ansuulEnragedFragmentCount = SSEA.status.ansuulEnragedFragmentCount - 1
                                end
                            end
                        end
			        end
                end
	        elseif GetUnitTargetMarkerType('reticleover') ~= TARGET_MARKER_TYPE_NONE then
		        -- Remove marker if it's on a wrong target (can happen to companions or group members)
		        AssignTargetMarkerToReticleTarget(GetUnitTargetMarkerType('reticleover'))
            else
		        AssignTargetMarkerToReticleTarget(GetUnitTargetMarkerType('reticleover'))
	        end
            if IsUnitFriendlyFollower("reticleover") then
                AssignTargetMarkerToReticleTarget(GetUnitTargetMarkerType('reticleover'))
	        end
        end
    end

end
-- for now, only the group lead can mark elites. later, with data share, everyone will be able to mark

function SSEA.DeathState(event, unitTag, isDead)
  if unitTag == "player" and not isDead and not IsUnitInCombat("boss1") then
    -- I just resurrected, and it was a wipe or we killed the boss.
    -- Remove all UI
    SSEA.ClearUIOutOfCombat()
  end
  
  -- if isDead and portalTracker ~= nil and SSEA.unitsTag[unitTag] ~= nil then
    -- If a player dies, remove them from the portal counter.
    -- if portalTracker[SSEA.unitsTag[unitTag].id] then
    --   portalTracker[SSEA.unitsTag[unitTag].id] = false
    --   if SSEA.status.numPlayersInPortal > 0 then
        --d("[SSEA] numPlayersInPortal -1 due to death of " .. SSEA.unitsTag[unitTag].name)
    --     SSEA.status.numPlayersInPortal = SSEA.status.numPlayersInPortal - 1
    --   end
    -- end
   
    -- Slip: learned that this shouldn't be done here as it causes errors
    --if SSEA.status.is_chimera or SSEA.status.is_twelvane then
       --if isDead then 
           --local displayName = SSEA.unitsTag[unitTag].name
            -- deathTouchTracker[displayName] = 0
           --if SSEA.hasOSI() then
              --OSI.RemoveMechanicIconForUnit(displayName)
           --end
       --end 
   --end
  -- end

  if SSEA.status.chimeraActive then
    if unitTag == "player" and isDead then 
           if SSEA.hasOSI() then
              local displayName = SSEA.unitsTag[unitTag].name
              local texture = "SlipsSanitysEdgeAssist/icons/chimera_chaincircuit.dds"
              OSI.SetMechanicIconForUnit(displayName, texture, 2 * OSI.GetIconSize())
           end
     end
  end
end

function SSEA.CombatState(eventCode, inCombat)
  local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
  -- Do not change combat state if you are dead, or the boss is not full.

  -- Do not do anything outside of boss fights.
  if maxTargetHP == 0 or maxTargetHP == nil then
    -- TODO: TEST, this may break:
    SSEA.ClearUIOutOfCombat()
    return
  end
  if currentTargetHP < 0.99*maxTargetHP or IsUnitDead("player") then
    -- TODO: Set inCombat = true for when players get pulled.
    return
  end
  if inCombat then
    SSEA.status.inCombat = true
    -- have seen trackers reset here

    -- might need this line activated again
    --SSEA.status.lastYaseylaFireBombs = 0
    
    -- if SSEA.status.is_xalvakka then
    --  SSEA.status.xalvakka_volatile_last = GetGameTimeSeconds()
      -- First portal 30, others 35.
    --  SSEA.status.nextXalvakkaJump = GetGameTimeSeconds() + 30
    -- end
    
    -- if SSEA.status.is_oaxiltso then
      -- Next Blitz
    --   SSEAStatusLabel1:SetHidden(false)
    --   SSEAStatusLabel1Value:SetHidden(false)
      -- Next Poison
    --   SSEAStatusLabel2:SetHidden(false)
    --   SSEAStatusLabel2Value:SetHidden(false)
    -- end
    -- if SSEA.status.is_bahsei then
    --   SSEA.status.nextPortal = GetGameTimeSeconds() + 20
    -- end
    if SSEA.status.is_yaseyla then
      -- Next Wamasu
      SSEAStatusLabel1:SetHidden(false)
      SSEAStatusLabel1Value:SetHidden(false)
      -- Next Archers
      SSEAStatusLabel2:SetHidden(false)
      SSEAStatusLabel2Value:SetHidden(false)
      -- Next Portals
      SSEAStatusLabel3:SetHidden(false)
      SSEAStatusLabel3Value:SetHidden(false)
      -- Next Shrapnel
      SSEAStatusLabel4:SetHidden(false)
      SSEAStatusLabel4Value:SetHidden(false)
      -- Next Fire Bombs
      SSEAStatusLabel5:SetHidden(false)
      SSEAStatusLabel5Value:SetHidden(false)
      -- Hide everything else
      SSEAStatusLabel23:SetHidden(true)
      SSEAStatusLabel23Value:SetHidden(true)
      SSEAStatusLabel33:SetHidden(true)
      SSEAStatusLabel33Value:SetHidden(true)
      SSEAStatusLabelTitle1:SetHidden(true)
      SSEAStatusLabelTitle2:SetHidden(true)
      SSEAStatusLabel1b:SetHidden(true)
      SSEAStatusLabel1bValue:SetHidden(true)
      SSEAStatusLabel1b:SetHidden(true)
      SSEAStatusLabel1bValue:SetHidden(true)
      SSEAStatusLabel2b:SetHidden(true)
      SSEAStatusLabel2bValue:SetHidden(true)
      SSEAStatusLabel3b:SetHidden(true)
      SSEAStatusLabel3bValue:SetHidden(true)
      SSEAStatusLabel41:SetHidden(true)
      SSEAStatusLabel41Value:SetHidden(true)
    elseif SSEA.status.is_chimera or SSEA.status.chimeraActive then
      -- Previous Chain Lightning Tank
      SSEAStatusLabel41:SetHidden(false)
      SSEAStatusLabel41Value:SetHidden(false)
      -- Hide everything else
      SSEAStatusLabel1:SetHidden(true)
      SSEAStatusLabel1Value:SetHidden(true)
      SSEAStatusLabel23:SetHidden(true)
      SSEAStatusLabel23Value:SetHidden(true)
      SSEAStatusLabel33:SetHidden(true)
      SSEAStatusLabel33Value:SetHidden(true)
      SSEAStatusLabel3:SetHidden(true)
      SSEAStatusLabel3Value:SetHidden(true)
      SSEAStatusLabel4:SetHidden(true)
      SSEAStatusLabel4Value:SetHidden(true)
      SSEAStatusLabel5:SetHidden(true)
      SSEAStatusLabel5Value:SetHidden(true)
      SSEAStatusLabelTitle1:SetHidden(true)
      SSEAStatusLabelTitle2:SetHidden(true)
      SSEAStatusLabel1b:SetHidden(true)
      SSEAStatusLabel1bValue:SetHidden(true)
      SSEAStatusLabel1b:SetHidden(true)
      SSEAStatusLabel1bValue:SetHidden(true)
      SSEAStatusLabel2b:SetHidden(true)
      SSEAStatusLabel2bValue:SetHidden(true)
      SSEAStatusLabel3b:SetHidden(true)
      SSEAStatusLabel3bValue:SetHidden(true)
    elseif SSEA.status.is_ansuul then
      -- Next Manic Phobia -- Changing color so that red can be for flame atro mechs
      SSEAStatusLabel1:SetHidden(true)
      SSEAStatusLabel1Value:SetHidden(true)
      -- Next Maze
      SSEAStatusLabel23:SetHidden(false)
      SSEAStatusLabel23Value:SetHidden(false)
      -- Wrack
      SSEAStatusLabel33:SetHidden(false)
      SSEAStatusLabel33Value:SetHidden(false)
      -- Manic Phobia
      SSEAStatusLabel4:SetHidden(false)
      SSEAStatusLabel4Value:SetHidden(false)

      -- Hide everything else
      SSEAStatusLabel3:SetHidden(true)
      SSEAStatusLabel3Value:SetHidden(true)
      -- SSEAStatusLabel4:SetHidden(true)
      -- SSEAStatusLabel4Value:SetHidden(true)
      SSEAStatusLabel41:SetHidden(true)
      SSEAStatusLabel41Value:SetHidden(true)
      SSEAStatusLabel5:SetHidden(true)
      SSEAStatusLabel5Value:SetHidden(true)
      SSEAStatusLabelTitle1:SetHidden(true)
      SSEAStatusLabelTitle2:SetHidden(true)
      SSEAStatusLabel1b:SetHidden(true)
      SSEAStatusLabel1bValue:SetHidden(true)
      SSEAStatusLabel1b:SetHidden(true)
      SSEAStatusLabel1bValue:SetHidden(true)
      SSEAStatusLabel2b:SetHidden(true)
      SSEAStatusLabel2bValue:SetHidden(true)
      SSEAStatusLabel3b:SetHidden(true)
      SSEAStatusLabel3bValue:SetHidden(true)
    else
      -- Hide everything
      SSEAStatusLabel1:SetHidden(true)
      SSEAStatusLabel1Value:SetHidden(true)
      SSEAStatusLabel2:SetHidden(true)
      SSEAStatusLabel2Value:SetHidden(true)
      SSEAStatusLabel23:SetHidden(true)
      SSEAStatusLabel23Value:SetHidden(true)
      SSEAStatusLabel33:SetHidden(true)
      SSEAStatusLabel33Value:SetHidden(true)
      SSEAStatusLabel3:SetHidden(true)
      SSEAStatusLabel3Value:SetHidden(true)
      SSEAStatusLabel4:SetHidden(true)
      SSEAStatusLabel4Value:SetHidden(true)
      SSEAStatusLabel41:SetHidden(true)
      SSEAStatusLabel41Value:SetHidden(true)
      SSEAStatusLabel5:SetHidden(true)
      SSEAStatusLabel5Value:SetHidden(true)
      SSEAStatusLabelTitle1:SetHidden(true)
      SSEAStatusLabelTitle2:SetHidden(true)
      SSEAStatusLabel1b:SetHidden(true)
      SSEAStatusLabel1bValue:SetHidden(true)
      SSEAStatusLabel1b:SetHidden(true)
      SSEAStatusLabel1bValue:SetHidden(true)
      SSEAStatusLabel2b:SetHidden(true)
      SSEAStatusLabel2bValue:SetHidden(true)
      SSEAStatusLabel3b:SetHidden(true)
      SSEAStatusLabel3bValue:SetHidden(true)
    end
  else
    SSEA.ClearUIOutOfCombat()
    if not SSEA.unlockedUI then
        SSEA.HideAllUI() -- Fixing issue of Yaseyla Panel not hiding properly
    -- have seen trackers reset here
    end
    -- this can be done in another place
    if SSEA.status.AnsuulHowManyInfernoToInterrupt > 0 then
        SSEA.status.AnsuulHowManyInfernoToInterrupt = 0
    end
    
    -- When out of combat, need to clear the mechanic icons for everyone
    if SSEA.savedVariables.fixWamasuChargeIconsPersisting then
        OSI.ResetMechanicIcons()
        SSEA.ClearZoneIcons()
    end
  end
end

function SSEA.ClearYaseylaZoneIcons()
    SSEA.DiscardPositionIconList(SSEA.status.durationIconsForPreviousInstance)
    SSEA.status.durationIconsForPreviousInstance = {}
    
    if SSEA.savedVariables.debugMode then
        d("just ran SSEA.ClearYaseylaZoneIcons()")
    end
end

function SSEA.ClearUIOutOfCombat()
  SSEA.status.inCombat = false

  -- Resetting trackers
  SSEA.status.lastYaseylaFireBombs = 0
  SSEA.status.lastYaseylaShrapnel = 0
  SSEA.status.startYaseylaWamasuOverwhelmingLightning = 0
  SSEA.status.lastTankToGetChainLightning = ""
  SSEA.status.lastYaseylaTombFrostBomb = 0
  SSEA.status.AnsuulHowManyInfernoToInterrupt = 0
  SSEA.status.lastAnsuulWrack = 0
  -- SSEAStatusLabel1Value:SetText("Incoming")
  -- SEAStatusLabel2Value:SetText("Incoming")
  if SSEA.savedVariables.showYaseylaContramagisArcherMarkers2 then
        SSEA.status.yaseylaContramagisArcherCount = 1
  else
      SSEA.status.yaseylaContramagisArcherCount = 8
  end
  if SSEA.savedVariables.showTrashDisruptorMarkers2 then
      SSEA.status.trashDisruptorCount = 1
  else
      SSEA.status.trashDisruptorCount = 8
  end
  if SSEA.savedVariables.showAnsuulEnragedFragmentMarkers2 then
      SSEA.status.ansuulEnragedFragmentCount = 1
  else
      SSEA.status.ansuulEnragedFragmentCount = 8
  end

  -- Does this have to be enabled?
  SSEA.LoadSavedScale()
  SSEA.HideAllUI(true)

end

function SSEA.HideAllUI(hide)
  SSEAAlerts:SetHidden(hide)
  SSEAAlerts2:SetHidden(hide)
  SSEAAlerts3:SetHidden(hide)
  SSEAPercentages:SetHidden(hide)
  SSEAStatus:SetHidden(hide)
  -- should make 1 Fire Bombs, 2 Ice Tombs

  -- Next Wamasu + Archers -> Fire Bombs; Done
  SSEAStatusLabel1:SetHidden(hide)
  SSEAStatusLabel1Value:SetHidden(hide)
  -- Next Portals + Archers -> Ice Tombs
  SSEAStatusLabel2:SetHidden(hide)
  SSEAStatusLabel2Value:SetHidden(hide)
  SSEAStatusLabel23:SetHidden(hide)
  SSEAStatusLabel23Value:SetHidden(hide)
  -- Next Portals + Archers -> Wamasu + Archers; Done
  SSEAStatusLabel3:SetHidden(hide)
  SSEAStatusLabel3Value:SetHidden(hide)
  -- Next Shrapnel -> Portals + Archers; Done
  SSEAStatusLabel4:SetHidden(hide)
  SSEAStatusLabel4Value:SetHidden(hide)
  -- Last Chained Tank; Done
  SSEAStatusLabel41:SetHidden(hide)
  SSEAStatusLabel41Value:SetHidden(hide)
  -- Next Fire Bombs -> Shrapnel; Done
  SSEAStatusLabel5:SetHidden(hide)
  SSEAStatusLabel5Value:SetHidden(hide)
  -- Next Wrack
  SSEAStatusLabel33:SetHidden(hide)
  SSEAStatusLabel33Value:SetHidden(hide)
  -- Hide everything else
  SSEAStatusLabelTitle1:SetHidden(hide)
  SSEAStatusLabelTitle2:SetHidden(hide)
  SSEAStatusLabel1b:SetHidden(hide)
  SSEAStatusLabel1bValue:SetHidden(hide)
  SSEAStatusLabel1b:SetHidden(hide)
  SSEAStatusLabel1bValue:SetHidden(hide)
  SSEAStatusLabel2b:SetHidden(hide)
  SSEAStatusLabel2bValue:SetHidden(hide)
  SSEAStatusLabel3b:SetHidden(hide)
  SSEAStatusLabel3bValue:SetHidden(hide)

end

function SSEA.LoadSavedScale()
  -- Slip: disabling this because it was causing issues
  --SSEA.SetScale(SSEA.savedVariables.panelUICustomScale)
  --SSEA.SetScale(SSEA.savedVariables.alertUICustomScale)

  if SSEA.savedVariables.panelUICustomScale == nil then
    SSEA.savedVariables.panelUICustomScale = 1
  end
  if SSEA.savedVariables.alertUICustomScale == nil then
    SSEA.savedVariables.alertUICustomScale = 0.5
  end

  SSEA.SetPanelScale(SSEA.savedVariables.panelUICustomScale)
  SSEA.SetAlertScale(SSEA.savedVariables.alertUICustomScale)
end

-- Called when sliding the menu slider.
function SSEA.SetPanelScale(scale)
  SSEA.savedVariables.panelUICustomScale = scale

  -- Updating top controls scales all children.
  SSEAStatus:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel1:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel2:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel23:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel3:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel33:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel4:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel41:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel5:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabelTitle1:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabelTitle2:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel1b:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel2b:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel3b:SetScale(SSEA.savedVariables.panelUICustomScale)
  -- set scale for values
  SSEAStatusLabel1Value:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel2Value:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel23Value:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel3Value:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel33Value:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel4Value:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel41Value:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel5Value:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabelTitle1:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabelTitle2:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel1bValue:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel2bValue:SetScale(SSEA.savedVariables.panelUICustomScale)
  SSEAStatusLabel3bValue:SetScale(SSEA.savedVariables.panelUICustomScale)
end

-- Called when sliding the menu slider.
function SSEA.SetAlertScale(scale)
  SSEA.savedVariables.alertUICustomScale = scale

  -- Updating top controls scales all children.
  SSEAAlerts:SetScale(SSEA.savedVariables.alertUICustomScale)
  SSEAAlerts2:SetScale(SSEA.savedVariables.alertUICustomScale)
  SSEAAlerts3:SetScale(SSEA.savedVariables.alertUICustomScale)
  SSEAPercentages:SetScale(SSEA.savedVariables.alertUICustomScale)
end

function SSEA.BossesChanged()
	local bossName = string.lower(GetUnitName("boss1"))
  SSEA.status.currentBoss = bossName
  

  SSEA.status.is_yaseyla = false
  SSEA.status.is_twelvane = false
  SSEA.status.is_chimera = false
  SSEA.status.is_ansuul = false
  
  -- if string.match(bossName, SSEA.data.oaxiltso_name) then
  --   SSEA.status.is_oaxiltso = true
  -- end
  -- if string.match(bossName, SSEA.data.bahsei_name) then
  --   SSEA.status.is_bahsei = true
  -- end
  -- if string.match(bossName, SSEA.data.xalvakka_name) then
  --   SSEA.status.is_xalvakka = true
  -- end
  if string.match(bossName, SSEA.data.yaseyla_name) then
    SSEA.status.is_yaseyla = true
  end
  if string.match(bossName, SSEA.data.archdruidTwelvane_name) then
    SSEA.status.is_twelvane = true
  end
  if string.match(bossName, SSEA.data.chimera_name) then
    SSEA.status.is_chimera = true
  end
  if string.match(bossName, SSEA.data.ansuul_name) then
    SSEA.status.is_ansuul = true
  end
  
  local currentTargetHP, maxTargetHP, effmaxTargetHP = GetUnitPower("boss1", POWERTYPE_HEALTH)
  if maxTargetHP > 90000000 then
    SSEA.status.is_hm_boss = true
  else
    SSEA.status.is_hm_boss = false
  end
end

-- Shield update
-- function SSEA.OnShieldAdded(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
    -- if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        -- SSEA.UpdateShield(unitTag, value, maxValue)
    -- end
-- end

-- function SSEA.OnShieldRemoved(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
    -- if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        -- SSEA.UpdateShield(unitTag, 0, maxValue)
    -- end
-- end

-- function SSEA.OnShieldUpdated(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
    -- if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        -- SSEA.UpdateShield(unitTag, newValue, newMaxValue)
    -- end
-- end

-- function SSEA.UpdateShield(unitTag, value, maxValue)
  -- if unitTag ~= "reticleover" then
    -- return
  -- end
  -- SSEAShields[unitTag] = value
  
  -- local unitName = string.lower(GetUnitName(unitTag))

  -- if string.match(unitName, SSEA.data.xalvakka_volatile_shell_name) then
    -- SSEA.status.shellShield = value
  -- end
-- end

function SSEA.OnSSEAAlertsMove()
  SSEA.savedVariables.alertsLeft = SSEAAlerts:GetLeft()
  SSEA.savedVariables.alertsTop = SSEAAlerts:GetTop()
end

function SSEA.OnSSEAAlerts2Move()
  SSEA.savedVariables.alerts2Left = SSEAAlerts2:GetLeft()
  SSEA.savedVariables.alerts2Top = SSEAAlerts2:GetTop()
end

function SSEA.OnSSEAAlerts3Move()
  SSEA.savedVariables.alerts3Left = SSEAAlerts3:GetLeft()
  SSEA.savedVariables.alerts3Top = SSEAAlerts3:GetTop()
end

function SSEA.OnSSEAPercentagesMove()
  SSEA.savedVariables.percentagesLeft = SSEAPercentages:GetLeft()
  SSEA.savedVariables.percentagesTop = SSEAPercentages:GetTop()
end

function SSEA.OnSSEAStatusMove()
  SSEA.savedVariables.statusLeft = SSEAStatus:GetLeft()
  SSEA.savedVariables.statusTop = SSEAStatus:GetTop()
end

function SSEA.DefaultPosition()
  SSEA.savedVariables.alertsLeft = nil
  SSEA.savedVariables.alertsTop = nil
  SSEA.savedVariables.alerts2Left = nil
  SSEA.savedVariables.alerts2Top = nil
  SSEA.savedVariables.alerts3Left = nil
  SSEA.savedVariables.alerts3Top = nil
  SSEA.savedVariables.subtitleLeft = nil
  SSEA.savedVariables.subtitleTop = nil
  SSEA.savedVariables.statusLeft = nil
  SSEA.savedVariables.statusTop = nil
  SSEA.savedVariables.percentagesLeft = nil
  SSEA.savedVariables.percentagesTop = nil
end

function SSEA.RestorePosition()
  if SSEA.savedVariables.alertsLeft ~= nil then
    SSEAAlerts:ClearAnchors()
    SSEAAlerts:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                       SSEA.savedVariables.alertsLeft,
                       SSEA.savedVariables.alertsTop)
  end
  if SSEA.savedVariables.alerts2Left ~= nil then
    SSEAAlerts2:ClearAnchors()
    SSEAAlerts2:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                       SSEA.savedVariables.alerts2Left,
                       SSEA.savedVariables.alerts2Top)
  end
  if SSEA.savedVariables.alerts3Left ~= nil then
    SSEAAlerts3:ClearAnchors()
    SSEAAlerts3:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                       SSEA.savedVariables.alerts3Left,
                       SSEA.savedVariables.alerts3Top)
  end
  
  if SSEA.savedVariables.percentagesLeft ~= nil then
    SSEAPercentages:ClearAnchors()
    SSEAPercentages:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                       SSEA.savedVariables.percentagesLeft,
                       SSEA.savedVariables.percentagesTop)
  end
  if SSEA.savedVariables.statusLeft ~= nil then
    SSEAStatus:ClearAnchors()
    SSEAStatus:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                       SSEA.savedVariables.statusLeft,
                       SSEA.savedVariables.statusTop)
  end
end

function SSEA.UnlockUI(unlock)
  SSEA.unlockedUI = unlock
  SSEA.HideAllUI(not unlock)
  SSEAPercentages:SetMouseEnabled(unlock)
  SSEAPercentages:SetMouseEnabled(unlock)
  SSEAStatus:SetMouseEnabled(unlock)
  
  SSEAPercentages:SetMovable(unlock)
  SSEAPercentages:SetMovable(unlock)
  SSEAStatus:SetMovable(unlock)
end

function SSEA.PlayerActivated()
  -- TODO: Check if the user reloaded in combat, and set it correctly.
  -- Disable all visible UI elements at startup.
  SSEA.HideAllUI(true)
  SSEA.UnlockUI(false)
  SSEA.SetPanelScale(SSEA.savedVariables.panelUICustomScale)
  SSEA.SetAlertScale(SSEA.savedVariables.alertUICustomScale)

  if GetZoneId(GetUnitZoneIndex("player")) ~= SSEA.data.sanitysedge_id then
    SSEA.active = false
    return
  else
    SSEA.units = {}
    SSEA.unitsTag = {}
  end

  -- Clear Yaseyla Wamasu charge icons upon porting in
  if SSEA.savedVariables.fixWamasuChargeIconsPersisting 
    and SSEA.status.durationIconsForPreviousInstance ~= nil then
    SSEA.DiscardPositionIconListForInstanceUponPortingIn(SSEA.status.durationIconsForPreviousInstance)
    SSEA.status.durationIconsForPreviousInstance = {}
  end

  if not SSEA.active and not SSEA.savedVariables.hideWelcome then
    d(GetString(SSEA_InitMSG))
    --d("|cff71f9[SSEA] Thanks for using Slip's Sanity's Edge Assist " .. SSEA.version .. ". Please send issues through Discord to SlipperySoap#5719.|r")
    --d(SSEA.version)
    if not SSEA.hasOSI() then
      d("Please install |cff0000OdySupportIcons|r's latest version (optional dependency) to see all the addon features, including arrows on players with mechanics.")
    end
  end
  SSEA.active = true
  SSEAStatusLabelAddonName:SetText("Slip's Sanity's Edge Assist " .. SSEA.version)

  EVENT_MANAGER:UnregisterForEvent(SSEA.name .. "CombatEvent", EVENT_COMBAT_EVENT )
  EVENT_MANAGER:RegisterForEvent(SSEA.name .. "CombatEvent", EVENT_COMBAT_EVENT, SSEA.CombatEvent )
  
  -- Buffs/debuffs
  EVENT_MANAGER:UnregisterForEvent(SSEA.name .. "Buffs", EVENT_EFFECT_CHANGED )
  EVENT_MANAGER:RegisterForEvent(SSEA.name .. "Buffs", EVENT_EFFECT_CHANGED, SSEA.EffectChanged)
  
  -- Boss change
  EVENT_MANAGER:UnregisterForEvent(SSEA.name .. "BossChange", EVENT_BOSSES_CHANGED, SSEA.BossesChanged)
  EVENT_MANAGER:RegisterForEvent(SSEA.name .. "BossChange", EVENT_BOSSES_CHANGED, SSEA.BossesChanged)
  
  -- Combat state
  EVENT_MANAGER:UnregisterForEvent(SSEA.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE , SSEA.CombatState)
  EVENT_MANAGER:RegisterForEvent(SSEA.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE , SSEA.CombatState)
  
  -- Death state
  EVENT_MANAGER:UnregisterForEvent(SSEA.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED , SSEA.DeathState)
  EVENT_MANAGER:RegisterForEvent(SSEA.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED , SSEA.DeathState)
  
  -- Reticle change
  EVENT_MANAGER:UnregisterForEvent(SSEA.name .. "ReticleChanged", EVENT_RETICLE_TARGET_CHANGED)
  EVENT_MANAGER:RegisterForEvent(SSEA.name .. "ReticleChanged", EVENT_RETICLE_TARGET_CHANGED, SSEA.ReticleChanged)

  -- Ticks
  EVENT_MANAGER:RegisterForUpdate(SSEA.name.."UpdateTick", 
    1000/10, function(gameTimeMs) SSEA.UpdateTick(gameTimeMs) end)
  
end

function SSEA.OnAddonLoaded( event, addonName )
	if addonName ~= SSEA.name then
		return
	end
  
  SSEA.savedVariables = ZO_SavedVars:NewAccountWide("SlipsSanitysEdgeAssistSavedVariables", 1, nil, SSEA.settings)
  SSEA.RestorePosition()
  SSEA.AddonMenu()
  
	EVENT_MANAGER:UnregisterForEvent( SSEA.name, EVENT_ADD_ON_LOADED )
	EVENT_MANAGER:RegisterForEvent(SSEA.name .. "PlayerActive", EVENT_PLAYER_ACTIVATED,
    SSEA.PlayerActivated)
end

EVENT_MANAGER:RegisterForEvent( SSEA.name, EVENT_ADD_ON_LOADED, SSEA.OnAddonLoaded )
