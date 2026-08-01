AOCH = AOCH or {}
local AOCH = AOCH

AOCH.name     = "AsquartOsseinCageHelper"
AOCH.version  = "1.8.4"
AOCH.author   = "|c24abfe@Asquart|r & |cbb00ff@Margorius|r"
AOCH.active   = false

AOCH.status = {
  verbose = false,
  currentBoss = "",
  is_Hall_of_Fleshcraft = false,
  is_hm_boss = false,
  is_normal_boss = false,
  is_jynorah_and_skorkhif = false,
  is_Gedna_Relvel = false,
  is_kazpian = false,
  is_Tortured_Ranyu = false,
  is_Blood_Drinker_Thisa = false,
  is_trash = true,
  inCombat = false,
  combat_start_time = 0,
  cast_alert_ids = {},
  abductor_cast_data = {},
  carrion_stacks_data = {},
  carrion_shield_blocked = false,
  carrion_stacks_num = 0,
  origQueueMessage = nil,

  -- Trash
  trash_numbers_enabled = false,
  trash_stacks_enabled = false,
  trash_slayers_enabled = false,
  trash_number_icons = {},
  trash_stacks_icons = {},
  trash_slayer_icons = {},
  abductor_spawned = false,
  abductor_notification_played = false,
  life_drain_alert_id = nil,
  corvid_swarm_alert_id = nil,

  -- Mini bosses
  mini_bosses_markers_enabled = false,
  mini_boss_icons = {},
  witch_last_phantasms_time = 0,
  witch_is_first_countdown = true,
  phantasmal_barrage_alert_playing = false,
  ranyu_last_jump_time = 0,
  ranyu_has_jumped = false,

  -- Hall of Fleshcraft
  fleshcraft_stacks_enabled = false,
  fleshcraft_add_markers_enabled = false,
  fleshcraft_slayers_enabled = false,
  fleshcraft_stack_icons = {},
  fleshcraft_slayer_icons = {},
  fleshcraft_add_icons = {},
  spawned_daedroths = {},
  fleshspawns_alive = {},
  channelers_alive = {},
  shapers_of_flesh = {},
  fleshcraft_portal_percent = 1,
  fleshcraft_portal_UI_hidden = false,
  initial_channeler_dead = false,
  current_channeler_max_hp = 2425644,
  current_channeler_hp = 2425644,
  harvesterAlertPlaying = false,
  num_fleshspawn = 0,
  channeler_immune = false,
  ogrim_charge_alerts = {},

  -- Jynorah and Skorkhif
  jynorah_next_portal = 0,
  jynorah_next_curse = 30,
  jynorah_stacks_enabled = false,
  jynorah_curse_markers_enabled = false,
  jynorah_exit_icon_enabled = false,
  jynorah_titanic_clash_ongoing = false,
  jynorah_titanic_clash_just_started = false,
  jynorah_titanic_clash_just_ended = false,
  jynorah_curse_ongoing = false,
  jynorah_got_blazing_enfeeblement = false,
  jynorah_got_sparking_enfeeblement = false,
  enfeeblement_swapped_while_dead = false,
  reflective_scales_valneer_playing = false,
  reflective_scales_myrinax_playing = false,
  titan_max_hp = 100000000,
  jynorah_stacks_icons = {},
  jynorah_curse_icons = {},
  jynorah_exit_icon = nil,
  jynorah_lost_portal = false,
  skorknif_lost_portal = false,
  valneer_ids = {},
  myrinax_ids = {},

  -- Overfiend Kazpian
  kazpian_entrance_stacks_enabled = false,
  kazpian_low_warden_stacks_enabled = false,
  kazpian_molag_kena_stacks_enabled = false,
  kazpian_krogo_stacks_enabled = false,
  kazpian_entrance_slayers_enabled = false,
  kazpian_low_warden_slayers_enabled = false,
  kazpian_molag_kena_slayers_enabled = false,
  kazpian_krogo_slayers_enabled = false,
  kazpian_entrance_stack_icons = {},
  kazpian_low_warden_stack_icons = {},
  kazpian_molag_kena_stack_icons = {},
  kazpian_krogo_stack_icons = {},
  kazpian_entrance_slayer_icons = {},
  kazpian_low_warden_slayer_icons = {},
  kazpian_molag_kena_slayer_icons = {},
  kazpian_krogo_slayer_icons = {},
  kazpian_next_portal = 0, -- Kazpian portal
  kazpian_portal_ongoing = false,
  got_link = false,
  kazpian_bombs_spawned = false,
  kazpian_curse_spawned = false,
  kazpian_new_arena_starting = false,
  kazpian_frenzy_alert_playing = false,
  kazpian_frenzy_alert_queued = false,
  kazpian_frenzy_alert_start = 0,
  kazpian_last_jump_time = 0,
  kazpian_last_enraged_jump_time = 0,
  is_kazpian_start_arena = true,
  is_low_warden_arena = false,
  is_molag_kena_arena = false,
  is_krogo_arena = false,
}

-- Default settings.
AOCH.settings = {
  -- Trash
  show_boss_carrion_stacks = true,
  block_carrion_synergy = true,
  carrion_synergy_block_time = 5700,
  hide_addon_version = false,

  show_trash_pack_icons = false,
  show_trash_stack_positions = true,
  show_trash_slayer_positions = false,
  show_deadraiser_spike_cage = true,
  show_deadraiser_cursed_terrain = true,
  show_deadraiser_spectral_revenant = true,
  show_soul_devourer_detonate_soul = true,
  show_soul_devourer_life_drain = true,
  show_carrion_reaper_corvid_swarm = true,
  show_channeler_heavy_alert = true,
  show_abduct_cast_alert = true,

  -- Mini bosses
  show_abductor_spawn = true,
  show_mini_boss_markers = false,
  show_witch_summon_phantasms_timer = true,
  show_witch_barrage_alert = true,
  show_ranyu_jump_timer = true,

  -- Hall of Fleshcraft
  show_effluvial_expellant_block = true,
  show_hall_of_flesh_stack_positions = false,
  show_hall_of_flesh_add_positions = true,
  show_hall_of_flesh_slayer_positions = false,
  show_hall_of_flesh_arcanist_positions = false,
  show_fleshspawn_counter = true,
  show_harvester_aggro = true,
  show_fleshcraft_portal_percent = true,
  show_daedroth_spawn = true,
  show_ogrim_charge_alert = true,

  -- Jynorah and Skorkhif
  show_curse_countdown = true,
  show_jynorah_boss_positions = true,
  show_jynorah_curse_positions = true,
  show_jynorah_portal_countdown = true,
  show_jynorah_surge = true,
  show_jynorah_boss_hp = true,
  show_jynorah_titan_hp = true,
  show_jynorah_curse_timer = true,
  show_jynorah_titanic_leap = true,
  show_jynorah_heatray = true,
  show_jynorah_target_boss = true,
  show_reflective_scales_alert = true,
  show_jynorah_enfeeblement_swap = true,
  show_jynorah_seeking_surge_alert = true,
  show_jynorah_portal_color = true,
  show_jynorah_titan_breath = true,
  show_jynorah_exit_icon = true,
  jynorah_exit_icon_size = 500,

  -- Overfiend Kazpian
  show_kazpian_stack_positions = false,
  show_kazpian_slayer_positions = false,
  show_kazpian_bomb_positions = false,
  show_kazpian_frenzy_alert = true,
  show_kazpian_frenzy_timer = true,
  show_kazpian_portal_countdown = true,
  show_kazpian_chains = true,
  show_kazpian_bombs = true,
  show_kazpian_curse_alert = true,
  show_kazpian_curse_alert_only_player = true,
  show_immolating_sphere = true,
  show_kazpian_jump = true,
  show_kazpian_jump_enraged_only = false,
}

AOCH.units = {}
AOCH.unitsTag = {}
AOCH.data    = {
  trifecta_achievement_id = 4272,

  carrion_shield_synergy_name = GetString(AOCH_CarrionShield),
  carrion_shield_synergy_icon = "/esoui/art/icons/u46_tri_bp_refresh.dds",

  osteon_archer_taking_aim = 239158,
  -- Deadraised
  deadraiser_spike_cage = 236477,
  deadraiser_cursed_terrain = 236386,
  deadraiser_cursed_terrain_debuff_id = 236571,

  spectral_revenant_toxic_ire = 160007,
  spectral_revenge_id = 236569,
  spectral_revenant_name = GetString(AOCH_SpectralRevenant),

  -- Tormented Soul Devourer
  soul_devourer_detonate_soul_debuff = 236778,
  soul_devourer_life_drain_debuff = 236751,

  -- Tormented Carrion Reaper
  carrion_reaper_corvid_swarm_debuff = 236947,
  carrion_reaper_corvid_swarm_cast = 236940,
  carrion_reaper_murder = 236957,

  -- Dreadful abductor
  dreadful_abductor_name = GetString(AOCH_Abductor),
  abduct_cast_id = 233762,
  abduct_cast_end_id = 236178,

  -- Bloodknight
  bloodknight_cross_swipe = 245485,

  -- Red Witch Gedna Relvel
  gedna_relvel_name = GetString(AOCH_GednaRelvel),
  phantasmal_barrage_id = 238800,
  summon_phantasms_id = 238806,
  witch_summon_phantasms_initial_countdown = 15,
  witch_summon_phantasms_consecutive_countdown = 30,

  carrion_shield_cast_ids = 
  {
    [237744] = true,
    [232748] = true,
    [232750] = true,
  },
  caustic_carrion_ids =
  {
    [240708] = true,
    [241089] = true,
  },

  -- Hall of Fleshcraft
  hall_of_fleshcraft_name = GetString(AOCH_ShaperOfFlesh),
	shaper_of_flesh_effluvial_expellant = 232397,
  shaper_of_flesh_shield_id = 232511,
  fleshspawn_name = GetString(AOCH_Fleshspawn),
  fleshspawn_fleshiplasm_buff_id = 231915,
  abomination_spawn_buff = 231977,
  daedroth_name = GetString(AOCH_Daedroth),
  harvester_name = GetString(AOCH_Harvester),
  channeler_name = GetString(AOCH_Channeler),
  harvester_ethereal_burst_1 = 236466,
  harvester_ethereal_burst_2 = 236458, -- Heavy !
  channeler_hp_hm = 2425644,
  channeler_hp_vet = 1940515,
  channeler_hp_nrm = 1056203,
  fleshspawn_hp_vet = 970258,
  fleshspawn_hp_nrm = 603546,
  channeler_id = 125666,
  channeler_coldfire_barrage = 241037,
  channeler_heavy_1 = 236871,
  channeler_heavy_2 = 240984,
  caustic_carrion = 240708,
  colony_collapse = 236403,
  daedroth_claw = 236357,
  sinewshot_true_shot = 236381,
  realm_shaper_smite = 236510,
  ogrim_charge = 236496,

  -- Tortured Ranyu
  tortured_ranyu_name = GetString(AOCH_TorturedRanyu),
  ranyu_jump_countdown = 15,
  ranyu_jump_id = 239694,
  kakhulet_strike = 239884,
  ranyu_sunburst = 239983,
  amakos_thrust = 239662,

  -- Jynorah and Skorkhif
  jynorah_name = GetString(AOCH_Jynorah),
  skorknif_name = GetString(AOCH_Skorknif),
  valneer_name = GetString(AOCH_Valneer),
  myrinax_name = GetString(AOCH_Myrinax),
  jynorah_curse_initial_countdown = 30,
  jynorah_curse_initial_countdown_hm = 15,
  jynorah_curse_consecutive_countdown = 50,
  jynorah_curse_duration = 5,
  jynorah_curse_cast_id = 234000,
  skorknif_curse_cast_id = 234276,
  jynorah_searing_blaze_damage_id = 234277,
  jynorah_searing_sparks_damage_id = 234277,
  jynorah_titans_jump_hm_countdown = 5,
  jynorah_titans_jump_countdown = 10,
  jynorah_titanic_clash_id = 232516,
  skorknif_titanic_clash_id = 232517,
  jynorah_coldflame_surge = 234321, -- channeling flame breath to a furhest person
  skorknif_brimstone_surge = 234330, -- channeling flame breath to a furhest person
  jyrohan_titan_hp_nrm = 35445864,
  jyrohan_titan_hp_vet = 151360288,
  jyrohan_titan_hp_hm = 242176464,
  jynorah_clash_end_effect_id = 235868,
  jynorah_blazing_enfeeblement = 233692,
  jynorah_sparkling_enfeeblement = 233644,
  reflective_scales_valneer = 233330,
  reflective_scales_myrinax = 233321,
  jynorah_sparking_heat_ray_cast_id = 234076,
  jynorah_blazing_heat_ray_cast_id = 234150,
  jynorah_seeking_flames_cast = 248043,
  aspect_spark_smash_1 = 245154,
  aspect_spark_smash_2 = 245161,
  aspect_spark_smash_3 = 245149,
  aspect_spark_smash_4 = 245154,
  aspect_bolt_1 = 245140,
  aspect_bolt_2 = 245131,
  aspect_bolt_3 = 245135,
  aspect_bolt_4 = 239378,
  tail_slam = 235805,
  valneer_breath_id = 234558,
  myrinax_breath_id = 234548,
  titanic_leap_ids =
  {
    [233477] = true,
    [234704] = true,
    [233452] = true,
    [233489] = true,
    [234722] = true,
    [233466] = true,
  },

  -- Blood Drinker Thisa
  blood_drinker_thisa_name = GetString(AOCH_BloodDrkinerThisa),
  thisa_cross_swipe = 239637,
  thisa_blood_dive = 238847,

  -- Overfiend Kazpian
  overfiend_kazpian_name = GetString(AOCH_Kazpian),
  kazpian_chains_cast = 232772,
  kazpian_chains_debuff_1 = 232773,
  kazpian_chains_debuff_2 = 232775,
  kazpian_frenzy_debuff_timer = 25,
  mage_terror = 245318,
  immolating_sphere = 237011,
  kazpian_jump = 235557,
  kazpian_jump_enraged = 245208,
  colossus_bone_saw = 245273,
  kazpian_frenzy_cast = 232722,
  agonizer_bomb_id = 128479,
  agonizer_bomb_name = GetString(AOCH_AgonizerBomb),
  agonizing_burden_debuff_id = 237163,
  agonizing_burden_timer = 6,
  agonizer_bomb_expiration_timer = 10,
  agonizer_bomb_targeting_id = 244769,
  agonizer_bomb_spawn_cast_id = 237149,
  kazpian_curse_cast_ids =
  { 
    [246009] = true,
    [235365] = true,
  },
  low_warden_teleport_hm_timer = 20,
  low_warden_teleport_timer = 50,
  molag_kena_hm_wipe_timer = 28,
  kazpian_portal_phase_buff_id = 233591,

  hpDamageActionResults =
  {
    [ACTION_RESULT_BLOCKED_DAMAGE] = true,
    [ACTION_RESULT_PRECISE_DAMAGE] = true,
    [ACTION_RESULT_WRECKING_DAMAGE] = true,
    [ACTION_RESULT_FALL_DAMAGE] = true,
    [ACTION_RESULT_DAMAGE] = true,
    [ACTION_RESULT_CRITICAL_DAMAGE] = true,
    [ACTION_RESULT_DOT_TICK] = true,
    [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
  },

  dodgeDuration = GetAbilityDuration(28549),
  maxDuration = 4000,
  ossein_cage_id = 1548,
}

function AOCH.IdentifyUnit(unitTag, unitName, unitId )
  --

	if not AOCH.units[unitId] then
    if (string.sub(unitTag, 1, 5) == "group" or string.sub(unitTag, 1, 6) == "player") then
      AOCH.units[unitId] = {
        tag = unitTag,
        name = GetUnitDisplayName(unitTag) or unitName,
      }
      AOCH.unitsTag[unitTag] = {
        id = unitId,
        name = GetUnitDisplayName(unitTag) or unitName,
      }
    end
  end

  if string.match(unitName, AOCH.data.dreadful_abductor_name) then ---------- collect Abductor tag
    AOCH.status.abductor_spawned = true
  end
end

-- [!] adjust label scale and draw order
function AOCH.AdjustLabelForIcon(icon)
    local order = icon.ctrl:GetDrawLevel() + 1
    icon.myLabel:SetDrawLevel( order )
end

-- check if osi is active and it supports positional icons
function AOCH.hasOSI()
  return OSI and OSI.CreatePositionIcon
end

function AOCH.hasLC()
  return LC
end

function AOCH.GetDist(x1, y1, z1, x2, y2, z2)
  local dx = x1 - x2
  local dy = y1 - y2
  local dz = z1 - z2
  return dx*dx + dy*dy + dz*dz
end

function AOCH.GetChannelerHP()
  if AOCH.status.is_hm_boss then
    return AOCH.data.channeler_hp_hm
  elseif AOCH.status.is_normal_boss then
    return AOCH.data.channeler_hp_nrm
  else
    return AOCH.data.channeler_hp_vet
  end
end

function AOCH.GetFleshspawnHP()
  if AOCH.status.is_normal_boss then
    return AOCH.data.fleshspawn_hp_nrm
  else
    return AOCH.data.fleshspawn_hp_vet
  end
end

function AOCH.GetTitanHP()
  if AOCH.status.is_hm_boss then
    return AOCH.data.jyrohan_titan_hp_hm
  elseif AOCH.status.is_normal_boss then
    return AOCH.data.jyrohan_titan_hp_nrm
  else
    return AOCH.data.jyrohan_titan_hp_vet
  end
end

function AOCH.DeathState(event, unitTag, isDead)

  if unitTag == "player" and not isDead and not IsUnitInCombat("player") then
    AOCH.ClearUIOutOfCombat()
  end
end

function AOCH.UpdateFleshspawnCounter()
  local txtNumFleshspawn = tostring(AOCH.status.num_fleshspawn)
  AOCHStatusFleshSpawnCounterLabelValue:SetText(txtNumFleshspawn)
  if AOCH.status.num_fleshspawn == 0 then
    AOCHStatusFleshSpawnCounterLabelValue:SetColor(0.125, 0.788, 0.078)
  elseif AOCH.status.num_fleshspawn < 3 then
    AOCHStatusFleshSpawnCounterLabelValue:SetColor(0.78, 0.513, 0.086)
  else
    AOCHStatusFleshSpawnCounterLabelValue:SetColor(0.768, 0.086, 0.086)
  end
end

function AOCH.UpdateCarrionCounter()
  local txtNumStacks = tostring(AOCH.status.carrion_stacks_num)
  AOCHStatusBossCarrionTrackerLabelValue:SetText(txtNumStacks)
  if AOCH.status.carrion_stacks_num < 3 then
    AOCHStatusBossCarrionTrackerLabelValue:SetColor(0.125, 0.788, 0.078)
  elseif AOCH.status.carrion_stacks_num < 5 then
    AOCHStatusBossCarrionTrackerLabelValue:SetColor(0.78, 0.513, 0.086)
  else
    AOCHStatusBossCarrionTrackerLabelValue:SetColor(0.768, 0.086, 0.086)
  end
end

function AOCH.CombatState(eventCode, inCombat)
  local _, maxTargetHP, _ = GetUnitPower("boss1", POWERTYPE_HEALTH)
  -- Do not change combat state if you are dead, or the boss is not full.

  -- Do not do anything outside of boss fights.
  if maxTargetHP == 0 or maxTargetHP == nil then
    -- TODO: TEST, this may break:
    AOCH.ClearUIOutOfCombat()
    return
  end

  if inCombat then
    AOCH.status.inCombat = true
    AOCH.status.combat_start_time = GetGameTimeSeconds()

    AOCHStatus:SetHidden(false)
    
    --------------------------- Gedna Relvel
    if AOCH.status.is_Gedna_Relvel then
      AOCH.status.witch_is_first_countdown = true
      AOCH.status.witch_last_phantasms_time = AOCH.status.combat_start_time
    end

    if AOCH.status.is_Tortured_Ranyu then
      AOCH.status.ranyu_last_jump_time = AOCH.status.combat_start_time
      AOCH.status.ranyu_has_jumped = false
    end

    --------------------------- Hall of Fleshcraft
    if AOCH.status.is_Hall_of_Fleshcraft then
      AOCH.status.fleshcraft_portal_UI_hidden = true
      AOCH.status.initial_channeler_dead = false
      AOCH.status.current_channeler_max_hp = AOCH.GetChannelerHP()
      AOCH.status.current_channeler_hp = AOCH.GetChannelerHP()
      AOCH.status.fleshcraft_portal_percent = 1
      AOCH.status.num_fleshspawn = 0
      AOCH.UpdateFleshspawnCounter()
      AOCH.status.spawned_daedroths = {}
      AOCH.status.fleshspawns_alive = {}
      AOCH.status.channeler_immune = false
    end

    if AOCH.status.is_jynorah_and_skorkhif then
      ----- Idk why buy it seems that OnBossesChanged doesn't set this up properly - so duplicate here
      local _, maxTargetHP, _ = GetUnitPower("boss1", POWERTYPE_HEALTH)
      if maxTargetHP > 37500000 then
        AOCH.status.is_hm_boss = true
      elseif maxTargetHP < 37250000 then
        AOCH.status.is_normal_boss = true
      end
      -- start curse timer
      if AOCH.status.is_hm_boss then
        AOCH.status.jynorah_next_curse = AOCH.status.combat_start_time + AOCH.data.jynorah_curse_initial_countdown_hm
      else
        AOCH.status.jynorah_next_curse = AOCH.status.combat_start_time + AOCH.data.jynorah_curse_initial_countdown
      end
      AOCH.status.jynorah_titanic_clash_ongoing = false
      AOCH.status.jynorah_curse_ongoing = false
      AOCH.status.jynorah_titanic_clash_just_started = false
      AOCH.status.jynorah_titanic_clash_just_ended = false
      AOCH.status.jynorah_got_blazing_enfeeblement = false
      AOCH.status.jynorah_got_sparking_enfeeblement = false
      AOCH.status.enfeeblement_swapped_while_dead = false
      AOCH.status.reflective_scales_myrinax_playing = false
      AOCH.status.reflective_scales_valneer_playing = false
      AOCH.status.jynorah_lost_portal = false
      AOCH.status.skorknif_lost_portal = false
      AOCH.status.valneer_ids = {}
      AOCH.status.myrinax_ids = {}
      AOCH.status.titan_max_hp = AOCH.GetTitanHP()
      AOCH.status.current_jyronah_percent = 1
      AOCH.status.current_skorknif_percent = 1
      
    end

    if AOCH.status.is_kazpian then
      AOCH.status.kazpian_bombs_spawned = false
      AOCH.status.kazpian_curse_spawned = false
      AOCH.status.kazpian_new_arena_starting = false
      AOCH.status.kazpian_portal_ongoing = false
      AOCH.status.kazpian_frenzy_alert_queued = false
      AOCH.status.kazpian_frenzy_alert_playing = false
    end
    
  else
    AOCH.ClearUIOutOfCombat()
    AOCH.status.abductor_spawned = false
    if AOCH.status.life_drain_alert_id ~= nil then
      CombatAlerts.DisableBanner(AOCH.status.life_drain_alert_id)
    end
    AOCH.status.corvid_swarm_alert_id = nil
    AOCH.status.life_drain_alert_id = nil
    AOCH.status.abductor_notification_played = false
    AOCH.status.cast_alert_ids = {}
    AOCH.status.fleshspawns_alive = {}
    AOCH.status.carrion_stacks_data = {}
    AOCH.status.carrion_stacks_num = 0
    AOCH.status.block_carrion_synergy = false
    AOCH.status.inCombat = false
    AOCH.status.num_fleshspawn = 0
    AOCH.status.jynorah_next_curse = 0
    AOCH.UpdateFleshspawnCounter()
  end
end

function AOCH.ClearUIOutOfCombat()
  AOCH.HideAllUI(true)
end

function AOCH.HideAllUI(hide)
  if AOCH.hasOSI then
    for alert, _ in pairs(AOCH.status.ogrim_charge_alerts) do
      OSI.DiscardPositionIcon(alert)
    end
    AOCH.status.ogrim_charge_alerts = {}
  end
  AOCHPurpleAlert:SetHidden(hide)
  AOCHRedAlert:SetHidden(hide)
  AOCHYellowAlert:SetHidden(hide)
  AOCHPurpleAlertLabel:SetHidden(hide)
  AOCHRedAlertLabel:SetHidden(hide)
  AOCHYellowAlertLabel:SetHidden(hide)
  AOCHSwapAlert:SetHidden(hide)
  AOCHSwapAlertLabel:SetHidden(hide)
  AOCHStatus:SetHidden(hide)
  -- Boss enrage
  AOCHStatusRedWarningLabel1:SetHidden(hide)
  -- Mini enrage
  AOCHStatusRedWarningLabel2:SetHidden(hide)
  -- Witch Phantasms Timer
  AOCHStatusGednaRelvelTimerLabel:SetHidden(hide)
  AOCHStatusGednaRelvelTimerLabelValue:SetHidden(hide)
  -- Fleshspawn counter
  AOCHStatusFleshSpawnCounterLabel:SetHidden(hide)
  AOCHStatusFleshSpawnCounterLabelValue:SetHidden(hide)

  -- Jynorah HP counter
  AOCHStatusJynorahHpCounterLabel:SetHidden(hide)
  AOCHStatusJynorahDamageIcon:SetHidden(hide)

  -- Skorknif HP counter
  AOCHStatusSkorknifHpCounterLabel:SetHidden(hide)
  AOCHStatusSkorknifDamageIcon:SetHidden(hide)

  AOCHStatusValneerHpCounterLabel:SetHidden(hide)
  AOCHStatusMyrinaxHpCounterLabel:SetHidden(hide)

  -- Jynorah curse timer
  AOCHStatusJynorahCurseTimerLabel:SetHidden(hide)
  AOCHStatusJynorahCurseTimerLabelValue:SetHidden(hide)
  AOCHStatusJynorahCurseTimerLabelValue:SetText("Pending")

  -- Boss Carrion tracker
  AOCHStatusBossCarrionTrackerLabel:SetHidden(hide)
  AOCHStatusBossCarrionTrackerLabelValue:SetHidden(hide)
end

function AOCH.BossesChanged()

  if AOCH.status.is_Hall_of_Fleshcraft then
    for i = 1, 6 do 
      local fleshBossName = GetUnitName("boss" .. tostring(i))
      if fleshBossName == AOCH.status.currentBoss then
        return
      end
    end
  end

  local bossName = GetUnitName("boss1")

  if bossName ~= AOCH.status.currentBoss then
    AOCH.status.currentBoss = bossName
  else
    return
  end

  if AOCH.data.is_jynorah_and_skorkhif then
    local secondBossName = GetUnitName("boss2")
    if secondBossName == AOCH.data.skorknif_name then
      return
    end
  end

  AOCH.status.is_trash = true
  AOCHStatus:SetHidden(true)
  
  AOCH.status.is_Gedna_Relvel = false
  AOCH.status.is_Hall_of_Fleshcraft = false
  AOCH.status.is_Tortured_Ranyu = false
  AOCH.status.is_jynorah_and_skorkhif = false
  AOCH.status.is_Blood_Drinker_Thisa = false
  AOCH.status.is_kazpian = false

  AOCH.status.is_normal_boss = false
  AOCH.status.is_hm_boss = false

  AOCH.status.carrion_stacks_data = {}
  AOCH.status.carrion_stacks_num = 0
  AOCH.status.block_carrion_synergy = false
  
  if string.match(bossName, AOCH.data.gedna_relvel_name) then
    AOCH.status.is_Gedna_Relvel = true
    AOCH.status.is_trash = false
    
    AOCH.SetGlobalMiniBossIcons()
    AOCHStatus:SetHidden(false)
    AOCHStatusGednaRelvelTimerLabel:SetHidden(false)
    AOCHStatusGednaRelvelTimerLabelValue:SetHidden(false)
  end
  if string.match(bossName, AOCH.data.hall_of_fleshcraft_name) then
    AOCH.status.is_Hall_of_Fleshcraft = true
    local _ , maxTargetHP, _ = GetUnitPower("boss1", POWERTYPE_HEALTH)
    if maxTargetHP > 6800000 then
      AOCH.status.is_hm_boss = true
    elseif maxTargetHP < 6700000 then
      AOCH.status.is_normal_boss = true
    end
    AOCH.status.is_trash = false
    AOCH.status.initial_channeler_dead = false
    AOCH.status.channeler_immune = false
    AOCH.status.current_channeler_hp = AOCH.GetChannelerHP()
    AOCH.status.current_channeler_max_hp = AOCH.GetChannelerHP()
    
    AOCHStatus:SetHidden(false)
    AOCHStatusFleshSpawnCounterLabel:SetHidden(not AOCH.savedVariables.show_fleshspawn_counter)
    AOCHStatusFleshSpawnCounterLabelValue:SetHidden(not AOCH.savedVariables.show_fleshspawn_counter)
    AOCH.SetHallOfFleshcraftIcons()
  end
  if string.match(bossName, AOCH.data.tortured_ranyu_name) then
    AOCH.status.is_Tortured_Ranyu = true
    AOCH.status.is_trash = false
    AOCH.SetGlobalMiniBossIcons()
  end
  if string.match(bossName, AOCH.data.jynorah_name) then
    AOCH.status.is_jynorah_and_skorkhif = true
    local _, maxTargetHP, _ = GetUnitPower("boss1", POWERTYPE_HEALTH)
    if maxTargetHP > 37500000 then
      AOCH.status.is_hm_boss = true
    elseif maxTargetHP < 37250000 then
      AOCH.status.is_normal_boss = true
    end
    AOCH.status.is_trash = false
    AOCHStatus:SetHidden(false)
      -- Jynorah HP counter
    AOCHStatusJynorahHpCounterLabel:SetHidden(not AOCH.savedVariables.show_jynorah_boss_hp)
    -- Skorknif HP counter
    AOCHStatusSkorknifHpCounterLabel:SetHidden(not AOCH.savedVariables.show_jynorah_boss_hp)
    -- Valneer HP counter
    AOCHStatusValneerHpCounterLabel:SetHidden(not AOCH.savedVariables.show_jynorah_titan_hp or AOCH.status.is_normal_boss)
    -- Skorknif HP counter
    AOCHStatusMyrinaxHpCounterLabel:SetHidden(not AOCH.savedVariables.show_jynorah_titan_hp or AOCH.status.is_normal_boss)
    -- Reset curse countdows text
    AOCHStatusJynorahCurseTimerLabelValue:SetText("Pending")

    AOCH.status.jynorah_titanic_clash_ongoing = false
    AOCH.status.jynorah_curse_ongoing = false
    AOCH.status.titan_max_hp = AOCH.GetTitanHP()
    AOCH.status.jynorah_titanic_clash_just_started = false
    AOCH.status.jynorah_titanic_clash_just_ended = false
    AOCH.status.reflective_scales_myrinax_playing = false
    AOCH.status.reflective_scales_valneer_playing = false
    AOCH.status.jynorah_got_blazing_enfeeblement = false
    AOCH.status.jynorah_got_sparking_enfeeblement = false
    AOCH.status.enfeeblement_swapped_while_dead = false
    AOCH.status.jynorah_lost_portal = false
    AOCH.status.skorknif_lost_portal = false
    AOCH.status.valneer_ids = {}
    AOCH.status.myrinax_ids = {}

    AOCHStatusJynorahCurseTimerLabelValue:SetHidden(not AOCH.savedVariables.show_jynorah_curse_timer)
    AOCHStatusJynorahCurseTimerLabel:SetHidden(not AOCH.savedVariables.show_jynorah_curse_timer)
    AOCH.SetJynorahIcons()
  end
  if string.match(bossName, AOCH.data.blood_drinker_thisa_name) then
    AOCH.status.is_Blood_Drinker_Thisa = true
    AOCH.status.is_trash = false
    AOCH.SetGlobalMiniBossIcons()
    AOCHStatus:SetHidden(false)
    return
  end
  if string.match(bossName, AOCH.data.overfiend_kazpian_name) then
    AOCH.status.is_kazpian = true
    AOCH.status.is_kazpian_start_arena = true
    AOCH.status.kazpian_last_jump_time = 0
    AOCH.status.kazpian_last_enraged_jump_time = 0
    AOCH.status.is_low_warden_arena = false
    AOCH.status.is_molag_kena_arena = false
    AOCH.status.is_krogo_arena = false
    AOCH.status.kazpian_bombs_spawned = false
    AOCH.status.kazpian_curse_spawned = false
    AOCH.status.kazpian_new_arena_starting = false
    AOCH.status.kazpian_portal_ongoing = false
    AOCH.status.kazpian_frenzy_alert_playing = false
    AOCH.status.kazpian_frenzy_alert_queued = false
    local _, maxTargetHP, _ = GetUnitPower("boss1", POWERTYPE_HEALTH)
    if maxTargetHP > 78000000 then
      AOCH.status.is_hm_boss = true
    end
    AOCH.status.is_trash = false
    AOCHStatus:SetHidden(false)
    AOCH.SetKazpianIcons()
  end

  AOCH.SetTrashIcons()
end

function AOCH.SetupSynergiesHook()
  ZO_PreHook(SYNERGY, 'OnSynergyAbilityChanged', function()
		local name, _ = GetSynergyInfo()
		if name == AOCH.data.carrion_shield_synergy_name then
      local bHidden = AOCH.savedVariables.block_carrion_synergy and (AOCH.status.carrion_shield_blocked or AOCH.status.carrion_stacks_num < 2)
      SHARED_INFORMATION_AREA:SetHidden(SYNERGY, bHidden)
      return true
		end
	end)
end

function AOCH.OnAOCHPurpleAlertMove()
  AOCH.savedVariables.purpleAlertLeft = AOCHPurpleAlert:GetLeft()
  AOCH.savedVariables.purpleAlertTop = AOCHPurpleAlert:GetTop()
end

function AOCH.OnAOCHRedAlertMove()
  AOCH.savedVariables.redAlertLeft = AOCHRedAlert:GetLeft()
  AOCH.savedVariables.redAlertTop = AOCHRedAlert:GetTop()
end

function AOCH.OnAOCHYellowAlertMove()
  AOCH.savedVariables.yellowAlertLeft = AOCHYellowAlert:GetLeft()
  AOCH.savedVariables.yellowAlertTop = AOCHYellowAlert:GetTop()
end

function AOCH.OnAOCHSwapAlertMove()
  AOCH.savedVariables.swapAlertLeft = AOCHSwapAlert:GetLeft()
  AOCH.savedVariables.swapAlertTop = AOCHSwapAlert:GetTop()
end

function AOCH.OnAOCHStatusMove()
  AOCH.savedVariables.statusLeft = AOCHStatus:GetLeft()
  AOCH.savedVariables.statusTop = AOCHStatus:GetTop()
end

function AOCH.DefaultPosition()
  AOCH.savedVariables.purpleAlertLeft = nil
  AOCH.savedVariables.purpleAlertTop = nil
  AOCH.savedVariables.redAlertLeft = nil
  AOCH.savedVariables.redAlertTop = nil
  AOCH.savedVariables.yellowAlertLeft = nil
  AOCH.savedVariables.yellowAlertTop = nil
  AOCH.savedVariables.swapAlertLeft = nil
  AOCH.savedVariables.swapAlertTop = nil
  AOCH.savedVariables.statusLeft = nil
  AOCH.savedVariables.statusTop = nil
end

function AOCH.RestorePosition()
  if AOCH.savedVariables.purpleAlertLeft ~= nil then
    AOCHPurpleAlert:ClearAnchors()
    AOCHPurpleAlert:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                       AOCH.savedVariables.purpleAlertLeft,
                       AOCH.savedVariables.purpleAlertop)
  end

  if AOCH.savedVariables.redAlertLeft ~= nil then
    AOCHRedAlert:ClearAnchors()
    AOCHRedAlert:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                       AOCH.savedVariables.redAlertLeft,
                       AOCH.savedVariables.redAlertTop)
  end

  if AOCH.savedVariables.yellowAlertLeft ~= nil then
    AOCHYellowAlert:ClearAnchors()
    AOCHYellowAlert:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                        AOCH.savedVariables.yellowAlertLeft,
                        AOCH.savedVariables.yellowAlertTop)
  end
  if AOCH.savedVariables.swapAlertLeft ~= nil then
    AOCHSwapAlert:ClearAnchors()
    AOCHSwapAlert:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                        AOCH.savedVariables.swapAlertLeft,
                        AOCH.savedVariables.swapAlertTop)
  end
  if AOCH.savedVariables.statusLeft ~= nil then
    AOCHStatus:ClearAnchors()
    AOCHStatus:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                       AOCH.savedVariables.statusLeft,
                       AOCH.savedVariables.statusTop)
  end
end

function AOCH.UnlockUI(unlock)
  AOCH.HideAllUI(not unlock)
  AOCHPurpleAlert:SetMouseEnabled(unlock)
  AOCHRedAlert:SetMouseEnabled(unlock)
  AOCHYellowAlert:SetMouseEnabled(unlock)
  AOCHStatus:SetMouseEnabled(unlock)
  
  AOCHPurpleAlert:SetMovable(unlock)
  AOCHRedAlert:SetMovable(unlock)
  AOCHYellowAlert:SetMovable(unlock)
  AOCHSwapAlert:SetMovable(unlock)
  AOCHStatus:SetMovable(unlock)
end

function AOCH.AchievementAwarded(_, _, _, id, _)
  if id == AOCH.data.trifecta_achievement_id then
    local messageParams1 = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.LEVEL_UP)
    messageParams1:SetQueuedOrder(11)
    messageParams1:SetText(GetString(AOCH_Tri1))
    messageParams1:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_POI_DISCOVERED)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams1)

    local messageParams2 = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.LEVEL_UP)
    messageParams2:SetQueuedOrder(12)
    messageParams2:SetText(GetString(AOCH_Tri2))
    messageParams2:SetSound(SOUNDS.ENLIGHTENED_STATE_GAINED)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams2)

    local messageParams3 = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.LEVEL_UP)
    messageParams3:SetQueuedOrder(13)
    messageParams3:SetText(GetString(AOCH_Tri3))
    messageParams3:SetSound(SOUNDS.ENLIGHTENED_STATE_LOST)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams3)
  end
end

function AOCH.OnDifficultyChanged()
  local _ , maxTargetHP, _ = GetUnitPower("boss1", POWERTYPE_HEALTH)
  if AOCH.status.is_Hall_of_Fleshcraft then
    if maxTargetHP > 6800000 then
      AOCH.status.is_hm_boss = true
    elseif maxTargetHP < 6700000 then
      AOCH.status.is_normal_boss = true
    end
    AOCH.status.current_channeler_hp = AOCH.GetChannelerHP()
    AOCH.status.current_channeler_max_hp = AOCH.GetChannelerHP()
  end

  if AOCH.status.is_jynorah_and_skorkhif then
    if maxTargetHP > 37500000 then
      AOCH.status.is_hm_boss = true
      AOCH.SetJynorahIcons()
    elseif maxTargetHP < 37250000 then
      AOCH.status.is_normal_boss = true
    else
      AOCH.status.is_hm_boss = false
      AOCH.HideJynorahCurseIcons()
    end
    AOCH.status.titan_max_hp = AOCH.GetTitanHP()
  end

  if AOCH.status.is_kazpian then
    if maxTargetHP > 78000000 then
      AOCH.status.is_hm_boss = true
    end
  end
end

function AOCH.OnResurrectResult(eventCode, targetCharacterName, result, targetDisplayName)
  -- Show alert which boss to move to on being ressurected
  if not AOCH.status.is_jynorah_and_skorkhif or not AOCH.status.is_hm_boss or not AOCH.status.inCombat then
    return
  end
  local isPlayer = targetDisplayName == GetDisplayName()
  local isDPS, _, _ = GetPlayerRoles()
  if isPlayer then
    -- Reset enfeeblement swap while dead functionality 
    AOCH.status.enfeeblement_swapped_while_dead = false

    if not AOCH.status.jynorah_titanic_clash_ongoing and isDPS and AOCH.savedVariables.show_jynorah_enfeeblement_swap and result == RESURRECT_RESULT_SUCCESS then
      if AOCH.status.jynorah_got_blazing_enfeeblement then
        CombatAlerts.Alert(nil, "Go to Blue Boss", 0x03AFFF, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
      elseif AOCH.status.jynorah_got_sparking_enfeeblement then
        CombatAlerts.Alert(nil, "Go to Red Boss", 0xCC3B0E, SOUNDS.CHAMPION_POINTS_COMMITTED, 3000)
      end
    end
  end
end

function AOCH.AddToCCADodgeList()
  if CombatAlertsData == nil then
    return
  end
  CombatAlertsData.dodge.ids[AOCH.data.colossus_bone_saw] = { -3, 1, false }
  CombatAlertsData.dodge.ids[AOCH.data.sinewshot_true_shot] = { -3, 1, true }
  CombatAlertsData.dodge.ids[AOCH.data.osteon_archer_taking_aim] = { -3, 1, true }
  CombatAlertsData.dodge.ids[AOCH.data.channeler_heavy_1] = { -2, 1}
  CombatAlertsData.dodge.ids[AOCH.data.channeler_heavy_2] = { -2, 1}
  CombatAlertsData.dodge.ids[AOCH.data.harvester_ethereal_burst_1] = { -3, 2, false}
  CombatAlertsData.dodge.ids[AOCH.data.harvester_ethereal_burst_2] = { -3, 1, false}
  CombatAlertsData.dodge.ids[AOCH.data.mage_terror] = { -3, 1, true}
  CombatAlertsData.dodge.ids[AOCH.data.aspect_spark_smash_1] = { -2, 1, offset = -400}
  CombatAlertsData.dodge.ids[AOCH.data.aspect_spark_smash_2] = { -2, 1, offset = -400}
  CombatAlertsData.dodge.ids[AOCH.data.aspect_spark_smash_3] = { -2, 1, offset = -400}
  CombatAlertsData.dodge.ids[AOCH.data.aspect_spark_smash_4] = { -2, 1, offset = -400}
  CombatAlertsData.dodge.ids[AOCH.data.aspect_bolt_1] = { -3, 2, offset = -1100}
  CombatAlertsData.dodge.ids[AOCH.data.aspect_bolt_2] = { -3, 2, offset = -1100}
  CombatAlertsData.dodge.ids[AOCH.data.aspect_bolt_3] = { -3, 2, offset = -1100}
  CombatAlertsData.dodge.ids[AOCH.data.aspect_bolt_4] = { -3, 2, offset = -1100}
  CombatAlertsData.dodge.ids[AOCH.data.tail_slam] = { -2, 1}
  CombatAlertsData.dodge.ids[AOCH.data.thisa_cross_swipe] = { -2, 1}
  CombatAlertsData.dodge.ids[AOCH.data.bloodknight_cross_swipe] = { -2, 1}
  CombatAlertsData.dodge.ids[AOCH.data.carrion_reaper_murder] = { -2, 1}
  CombatAlertsData.dodge.ids[AOCH.data.spectral_revenge_id] = { -2, 1}
  CombatAlertsData.dodge.ids[AOCH.data.kakhulet_strike] = { -2, 1}
  CombatAlertsData.dodge.ids[AOCH.data.ranyu_sunburst] = { -2, 1}
  CombatAlertsData.dodge.ids[AOCH.data.amakos_thrust] = { -2, 1}
  CombatAlertsData.dodge.ids[AOCH.data.realm_shaper_smite] = { -2, 1}
end

function AOCH.PlayerActivated()
  -- TODO: Check if the user reloaded in combat, and set it correctly.
  -- Disable all visible UI elements at startup.
  AOCH.HideAllUI(true)
  AOCH.UnlockUI(false)

  if GetZoneId(GetUnitZoneIndex("player")) ~= AOCH.data.ossein_cage_id then
    return
  else
    AOCH.units = {}
    AOCH.unitsTag = {}
  end

  if not AOCH.active and not AOCH.savedVariables.hideWelcome then
    d(GetString(AOCH_InitMSG))
    if not AOCH.hasOSI() then
      d(GetString(AOCH_OsiMSG))
    end
  end
  AOCH.active = true
  AOCHStatusLabelAddonName:SetText("Ossein Cage Helper " .. AOCH.version)

  EVENT_MANAGER:UnregisterForEvent(AOCH.name .. "CombatEvent", EVENT_COMBAT_EVENT )
  EVENT_MANAGER:RegisterForEvent(AOCH.name .. "CombatEvent", EVENT_COMBAT_EVENT, AOCH.CombatEvent )
  
  -- Bufs/debuffs
  EVENT_MANAGER:UnregisterForEvent(AOCH.name .. "Buffs", EVENT_EFFECT_CHANGED )
  EVENT_MANAGER:RegisterForEvent(AOCH.name .. "Buffs", EVENT_EFFECT_CHANGED, AOCH.EffectChanged)
  
  -- Boss change
  EVENT_MANAGER:UnregisterForEvent(AOCH.name .. "BossChange", EVENT_BOSSES_CHANGED, AOCH.BossesChanged)
  EVENT_MANAGER:RegisterForEvent(AOCH.name .. "BossChange", EVENT_BOSSES_CHANGED, AOCH.BossesChanged)
  
  -- Combat state
  EVENT_MANAGER:UnregisterForEvent(AOCH.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE , AOCH.CombatState)
  EVENT_MANAGER:RegisterForEvent(AOCH.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE , AOCH.CombatState)
  
  -- Death state
  EVENT_MANAGER:UnregisterForEvent(AOCH.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED , AOCH.DeathState)
  EVENT_MANAGER:RegisterForEvent(AOCH.name .. "DeathState", EVENT_UNIT_DEATH_STATE_CHANGED , AOCH.DeathState)

  -- Achievement awarded
  EVENT_MANAGER:UnregisterForEvent(AOCH.name .. "AchievementAwarded", EVENT_ACHIEVEMENT_AWARDED , AOCH.AchievementAwarded)
  EVENT_MANAGER:RegisterForEvent(AOCH.name .. "AchievementAwarded", EVENT_ACHIEVEMENT_AWARDED , AOCH.AchievementAwarded)

  -- Ressurect result
  EVENT_MANAGER:UnregisterForEvent(AOCH.name .. "RessurectResult", EVENT_RESURRECT_RESULT , AOCH.OnResurrectResult)
  EVENT_MANAGER:RegisterForEvent(AOCH.name .. "RessurectResult", EVENT_RESURRECT_RESULT, AOCH.OnResurrectResult)

  if (AOCH.status.origQueueMessage) then
      CENTER_SCREEN_ANNOUNCE.QueueMessage = AOCH.status.origQueueMessage
  end

  -- Hook into CSA display to get difficulty changed event
  AOCH.status.origQueueMessage = CENTER_SCREEN_ANNOUNCE.QueueMessage
  CENTER_SCREEN_ANNOUNCE.QueueMessage = function(s, messageParams)
      -- Call this a second later, because sometimes the health hasn't changed yet
      zo_callLater(function()
            AOCH.OnDifficultyChanged()
        end, 1000)
      return AOCH.status.origQueueMessage(s, messageParams)
  end

  -- Trigger initial "changes," in case a reload was done while at Lokk
  AOCH.BossesChanged()
  AOCH.OnDifficultyChanged()

  -- Set 2nd boss damage textures
  AOCHStatusJynorahDamageIcon:SetTexture(AOCH.icons_data.stack_texture)
  AOCHStatusSkorknifDamageIcon:SetTexture(AOCH.icons_data.stack_texture)

  -- Ticks
  EVENT_MANAGER:RegisterForUpdate(AOCH.name.."UpdateTick", 
    1000/10, function(gameTimeMs) AOCH.UpdateTick(gameTimeMs) end)
end

function AOCH.OnAddonLoaded( event, addonName )
	if addonName ~= AOCH.name then
		return
	end

  AOCH.savedVariables = ZO_SavedVars:NewAccountWide("AsquartOsseinCageHelperSavedVariables", 1, nil, AOCH.settings)
  AOCH.RestorePosition()
  AOCH.AddonMenu()

  AOCH.AddToCCADodgeList()

  AOCH.SetupSynergiesHook()

  AOCHStatusLabelAddonName:SetHidden(AOCH.savedVariables.hide_addon_version)
  AOCHStatusDivider:SetHidden(AOCH.savedVariables.hide_addon_version)

	EVENT_MANAGER:UnregisterForEvent( AOCH.name, EVENT_ADD_ON_LOADED )
	EVENT_MANAGER:RegisterForEvent(AOCH.name .. "PlayerActive", EVENT_PLAYER_ACTIVATED,
    AOCH.PlayerActivated)
end

EVENT_MANAGER:RegisterForEvent( AOCH.name, EVENT_ADD_ON_LOADED, AOCH.OnAddonLoaded )