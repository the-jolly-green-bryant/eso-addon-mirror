QDRH = QDRH or {}
local QDRH = QDRH

QDRH.data    = {
  -- Trash
  swashbuckler_targeted = 170523,
  swashbuckler_aperture = 171004, --5s effect
  overseer_cascading_boot = 170188, -- ice and knockback not stoppable
  brewmaster_potion = 170547, -- targeted at one player, and then 3 players in a 45 degree cone towards that player.
  keelcutter_expelled_fire = 170136, -- cone targetting one player, then spreads little circles.
  -- Note this has absolutely nothing to do with drinking potions in combat - that's a debunked myth.

  -- Brewmaster empowering other adds.
  -- {EFFECT_GAINED_DURATION} Elixir of Augmentation (170806) : [3000]", -- add cannot do anything while growing.
  --  follwed by: {1} Augmented (170622) : [D=15]",
  
  -- Lylanar (fire)
  lylanar_cinder_surge = 166693, --  EFFECT_GAINED and EFFECT_FADED
  -- Imminent and Fragility are 168.. vs 166.. Not the same!
  lylanar_imminent_blister = 168525, -- EFFECT_GAINED_DURATION 10000 -> EFFECT_FADED
  lylanar_blistering_fragility = 166525, -- EFFECT_GAINED_DURATION 20000 -> EFFECT_FADED

  lylanar_firebrand = 166472, --  EFFECT_GAINED_DURATION, 5000 hitValue
  lylanar_imminent_duration = 10,
  lylanar_fragility_duration = 20,
  lylanar_broiling_hew = 167273, -- broiling hew (fire heavy)
  lylanar_scorching_hack = 166236, -- light attack
  lylanar_torrid_cleave = 167298, -- frontal cleave
  lylanar_pre_firebrand = 166355, -- cast 5s before rune mechanic on opposite boss
  lylanar_firebrand_player_debuff = 166472,
  lylanar_incendiary_axe = 168817, -- cast time cooldown: 40s
  lylanar_scalding_swell = 169587, -- 5500 hitValue on EFFECT_GAINED_DURATION
  rune_explosion_time = 5,
  lylanar_weapon_cd = 40, -- time between incendiary axe casts. also for swords.
  lylanar_charred_constriction = 167466,
  lylanar_magma_spike = 168646, -- cast 
  lylanar_magma_spike_debuff = 168657, -- debuff
  lylanar_spike_duration = 6.5,
  lylanar_hindered_effect = 165972,
  lylanar_charred_constriction_debuff = 167491,
  turlassil_frigidarium_debuff = 168630,
  -- correct ones, approximated.
  lylanar_brand_meeting_point = {
    [1] = {68548, 36124-50, 85175},
    [2] = {69510, 36125-50, 85172},
  },
  lylanar_phase3_left  =  {68518, 36121, 83710},
  lylanar_phase3_right =  {68480, 36115, 86913},
  summon_flame_hound = 169317, -- EFFECT_GAINED(hitValue=1) and EFFECT_GAINED_DURATION(hitValue=3600000 targetUnitId=new dog)
  summon_frost_hound = 169313,
  lylanar_summon_iron_atronach = {
    [168713] = true, -- Summon Iron Atronach (CombatAlerts alternate)
    [167763] = true, -- Summon Iron Atronach (confirmed)
  },
  lylanar_summon_frost_atronach = {
    [168722] = true, -- Summon Frost Atronach (CombatAlerts alternate)
    [167900] = true, -- Summon Frost Atronach (confirmed)
  },

  -- Turlassil (ice)
  turlassil_numbing_shards = 166735,  --  EFFECT_GAINED and EFFECT_FADED
  turlassil_imminent_chill = 168526,  -- EFFECT_GAINED_DURATION 10000 -> EFFECT_FADED
  turlassil_chilling_fragility = 166529,  -- EFFECT_GAINED_DURATION 20000 -> EFFECT_FADED
  turlassil_frostbrand = 166482,  --  EFFECT_GAINED_DURATION, 5000 hitValue
  turlassil_stinging_shear = 167280, -- stinging shear (ice heavy)
  turlassil_freezing_slash = 166229, -- light attack
  turlassil_brisk_rip = 167290,  -- frontal cleave
  turlassil_pre_frostbrand = 166364, -- cast 5s before rune mechanic on opposite boss
  turlassil_frostbrand_player_debuff = 166482,
  turlassil_calamitous_sword = 168912, -- cast time cooldown: 40s
  turlassil_biting_billow = 169594, -- 5500 hitValue on EFFECT_GAINED_DURATION
  turlassil_frigidarium = 167545,
  turlassil_glacial_spike = 168632, -- cast 
  turlassil_glacial_spike_debuff = 168635, -- debuff


  -- Bubbles
  pre_destructive_ember = 166209, -- happens just before destructive ember, 0 stacks
  destructive_ember = 166210,
  pre_piercing_hailstone = 166178, -- just before, 0 stacks
  piercing_hailstone = 166192,
  bubble_drop_cooldown = 15,
  bubble_drop_cooldown_hm = 20,

  -- Reef Guardian
  guardian_building_static_boss = 163575, -- debuff with stacks for boss?
  guardian_building_static_side_boss = 169688,  -- debuff with stacks works overworld but not boss. Tested.
  guardian_volatile_residue_boss = 174835, -- debuff with stacks. Tested.
  guardian_volatile_residue_side_boss = 174932, -- debuff with stacks
  guardian_coral_drift_bear_crackdown = 166586, -- heavy attack from bear
  guardian_crab_monstrous_claw = 166582, -- portal crab heavy 17k -- BEGIN
  guardian_crab_swipe = 166584, -- portal crab la -- BEGIN
  guardian_crab_water_jet = 166585, -- portal crap -- BEGIN
  guardian_heartburn = 163692, -- BEGIN
  guardian_heartburn_buff = 170481, -- buff does not work.
  guardian_heartburn_event_effect_changed = 166036, -- EFFECT_RESULT_GAINED. only id appearing in EVENT_EFFECT_CHANGED
  guardian_replication = 163701, -- cast
  guardian_heartburn_empowerment = 170046,
  guardian_heartburn_wipe_time = 60,
  guardian_heartburn_success = 166031,
  guardian_heartburn_fail = 166032,
  guardian_acid_reflux = 163702,
  guardian_acid_pool = 165987,
  guardian_king_orgnum_fire = 175831, -- begin cast
  guardian_king_orgnum_fire_debuff = 175832, -- buff/debuff
  guardian_crush = 166019,
  guardian_claw = 166020,
  guardian_sheltered = 163571,
  guardian_strat_pos = {
    [1] = {168086, 39803+300, 78498},
    [2] = {170923, 39803+300, 76668},
    [3] = {178382, 39803+300, 80799},
    [4] = {178529, 39803+300, 84004},
    [5] = {170739, 39803+300, 87925},
    [6] = {168173, 39803+300, 86532},
  },
  guardian_heart_pos = {
    [1] = {168691, 36100, 75880}, -- cross
    [2] = {175973, 36100, 76357}, -- skull
    [3] = {180368, 36101, 82435}, -- anchor
    [4] = {176277, 36100, 88741}, -- wheel
    [5] = {168340, 36100, 88884}, -- crown 
    [6] = {164661, 36100, 82008}, -- chalice
  },
  guardian_portal_y_threshold = 37000, -- on top 39k-40k, on portal 36k
  GUARDIAN_CROSS = 1,
  GUARDIAN_SKULL = 2,
  GUARDIAN_ANCHOR = 3,
  GUARDIAN_WHEEL = 4,
  GUARDIAN_CROWN = 5,
  GUARDIAN_CHALICE = 6,
  guardian_symbol_name = {
    [1] = "CROSS",
    [2] = "SKULL",
    [3] = "ANCHOR",
    [4] = "WHEEL",
    [5] = "CROWN",
    [6] = "CHALICE",
  },
  guardian_acidic_vulnerability = 174659,
  guardian_acidic_vulnerability_duration = 5, -- GetAbilityDuration(174659) = 5000

  -- Taleria
  taleria_rapid_deluge_normal = 174959,
  taleria_rapid_deluge = 174960,
  taleria_rapid_deluge_hm = 174961,
  taleria_deluge_duration = 6,
  taleria_deluge_range = 1950*1950, -- 19 to 19.5 meters
  taleria_crashing_wave_alert_radius = 3600*3600,

  taleria_barnacle_blade_1 = 174801, -- light attack (damage, it already hit)
  taleria_barnacle_blade_2 = 163901, -- light attack (damage, it already hit)
  taleria_barnacle_blade = 163901, -- {BEGIN} cast (also used for damage)
  taleria_coral_slam = 163987, -- heavy attack - used for alert
  taleria_summon_siren = 166929,
  taleria_summon_behemoth = 166928,
  taleria_summon_behemoth_cd = 60,
  taleria_summon_behemoth_cd_hm = 45, -- was 30s, patch 8.0.4 changed to 45s
  taleria_storm_wall_cw = 175447,
  taleria_storm_wall_ccw = 174866,
  taleria_ice_storm = 174928, -- cast on herself, does not determine direction
  taleria_storm_wall_cd = 120, -- needs more data. Seen one example with 110
  -- (wipe 10 on 21/04) 0:41, 2:31, 05:07
  -- 90s from the end of the cast
  -- GetAbilityCooldown(174928) = 90000
  taleria_storm_wall_duration = 45, -- needs further testing
  -- When platform fall happens, Winter Storm (wall) can't happen for ~60s.
  -- Probably can't happen from platform fall until the island debuff goes away?
  taleria_platform_fall_storm_wall_grace_period = 60,

  taleria_maelstrom_ability = 166292,
  taleria_maelstrom = 166299, -- damage abilityId
  taleria_maelstrom_cd = 35, -- how often it can cast maelstrom
  taleria_maelstrom_duration = 6, -- test if it's 6s or 6.6s

  taleria_crashing_wave_tank = 174943, -- cast from another entity, also at PLAYER/tank.
  taleria_crashing_wave_boss = 166353, -- Blue wave at tank. Also additional pink ones around the area.

  -- player buff to track when you're standing in the inside whirpool "ON POOL"
  taleria_whirpool = 163896,
  taleria_position = {169700, 36090, 29959},
  taleria_distance_meters = 36 + 1, -- radius of the donut is ~36. People outside are in portal.
  -- Portal shore (other side of the bridge) is at 83meters

  
  -- TODO: If behemoth sees you, activate seeing the slam (Arctic Annihilation)
  taleria_behemoth_crush = 164158,
  taleria_behemoth_hack = 164162,
  taleria_behemoth_strike = 164160, -- 26k unblocked to tank
  taleria_behemoth_arctic_annihilation = 165827, -- BEGIN with hitValue=2833. Cooldown=16s.
  taleria_behemoth_arctic_annihilation_cd = 17, -- GetAbilityCooldown is 15s. In reality, never seen before 17.
  taleria_behemoth_arctic_annihilation_cd_after_spawn = 10, -- first slam 10s after spawn.
  -- two EFFECT_GAINED events, one with hitValue=1, one with hitValue=1
  -- the targetUnitId is the id of the Sea Behemoth.
  -- It happens after Summon Behemoth (166928) where target is MT.
  taleria_summon_behemoth_boss = 10298, -- check hitValue=1 only.

  taleria_matron_lure_of_the_sea = 163952, -- Targets player, break free or go swim.

  -- Portal adds, also known as "Channelers"
  taleria_dreadsail_venom_evoker = 175132, -- PORTAL OPENS -- green
  taleria_dreadsail_sea_boiler = 175134, -- PORTAL OPENS -- yellow
  taleria_dreadsail_tidal_mage = 175136, -- PORTAL OPENS -- purple
  taleria_portal_done = 169933, -- add gains a buff shield from icy escape

  taleria_bridge_begin = 167704,

  taleria_bridge_1 = 166479, -- Cast when the first portal (any) is open.
  taleria_bridge_2 = 175279, -- Same for second,
  taleria_bridge_3 = 175291, -- Same for third.

  -- When these debuffs start, 60s for portal wipe. Only the island receives them!
  -- These 3 are NOT cast on players.
  taleria_dreadsail_venom_evoker_nematocyst_cloud = 166042,
  taleria_dreadsail_sea_boiler_sweltering_heat = 165994,
  taleria_dreadsail_tidal_mage_suffocating_waves = 166044,

  --[[
  _portal and _aoe debuffs are triggered twice per target and they all follow this pattern
    EFFECT_GAINED, hitValue=0
    EFFECT_GAINED, hitValue=1
    EFFECT_FADED, hitValue=0

  LOGIC:
  - when Island debuff is applied: if your position is <36m
  - when _portal debuff is applied: true
  - when _aoe debuff is applied: true
  - on wipe/reset: all false {what if island debuff starts, you die and res?}

  --]]

  -- Debuffs players going portal get, with their unique id.
  taleria_dreadsail_venom_evoker_nematocyst_cloud_portal = 174679,
  taleria_dreadsail_sea_boiler_sweltering_heat_portal = 174689,
  taleria_dreadsail_tidal_mage_suffocating_waves_portal = 174691,

  -- Debuff the group gets when standing inside the AOE of the landed channeler.
  taleria_dreadsail_venom_evoker_nematocyst_cloud_aoe = 169938,
  taleria_dreadsail_sea_boiler_sweltering_heat_aoe = 169936,
  taleria_dreadsail_tidal_mage_suffocating_waves_aoe = 169935,


  -- Any ids as long as they're different. Not 1-3 to avoid confusion.
  taleria_portal_type_green = 9001,
  taleria_portal_type_yellow = 9002,
  taleria_portal_type_purple = 9003,

  taleria_portal_fail = 175612, -- add gains a buff Enrage. Sea Boiler enrage
  taleria_portal_fail_2 = 175500, -- Enrage. Venom Evoker enrage? (to be confirmed)
  -- 167566
  taleria_portal_cd = 0, -- how often a portal/bridge is open -- this may be hp 50% since the first is at 50%
  -- TODO: Next Portal(1): X% (show only from 55% or so)
  taleria_portal_enrage_time = 60, -- how many seconds after opening does it take for an enrage

  taleria_dreadsail_ascension = 175502, -- DAMAGE type combat event
  taleria_sea_boiler_aspect_of_terror = 174697, -- Fear cast from Sea Boiler

  taleria_pivot_icon_pos = {166013, 36062 + 300, 29767},
  taleria_opposite_pivot_icon_pos = {173332, 36040 + 300, 29958},
  slaughterfish_pos_list = {
    [1] = {170164,35995,26179},
    [2] = {165760,35995,29756},
    [3] = {169826,35996,33581},
    [4] = {173560,35995,29866},
  },

  taleria_center_pos = {169700, 36090, 29959},
  -- Bridge start positions just outside the island.
  taleria_bridge_green_pos =  {169075, 36065 + 300, 26413},
  taleria_bridge_yellow_pos = {173190, 36056 + 300, 30917},
  taleria_bridge_purple_pos = {167530, 36039 + 300, 32757},

  -- Real coordinates
  -- Old green coordinates are a bit shifted
  --taleria_bridge_green_portal_outer =  {169977, 36123 + 300, 26688},
  --taleria_bridge_green_portal_inner =  {169841, 36118 + 100, 28139},

  -- Real coordinates
  taleria_bridge_green_portal_outer =  {170656, 36123 + 300, 26839},
  taleria_bridge_green_portal_inner =  {170251, 36117 + 100, 28270},
  taleria_bridge_purple_portal_outer = {166814, 36124 + 300, 31385},
  taleria_bridge_purple_portal_inner = {168115, 36119 + 100, 30772},
  taleria_bridge_yellow_portal_outer = {172280, 36124 + 300, 32026},
  taleria_bridge_yellow_portal_inner = {171322, 36124 + 100, 31287},

  -- test coordinates
  --[[taleria_bridge_green_portal_outer =  {27956, 15521, 171112},
  taleria_bridge_green_portal_inner =  {27134, 15510, 171294},
  taleria_bridge_purple_portal_outer = {28044, 15517, 172006},
  taleria_bridge_purple_portal_inner = {26845, 15519, 172245},
  taleria_bridge_yellow_portal_outer = {28114, 15510, 172597},
  taleria_bridge_yellow_portal_inner = {27135, 15510, 172808},--]]
  

  -- Credit: bitrock (NA) and Elm's Markers
  taleria_clock_pos = {
    -- fourth coordinate is the digit, each one appearing twice (in and out)
    [1] = {166276,36133,29775,6},
    [2] = {168005,36108,29851,6},
    [3] = {171569,36108,30066,12},
    [4] = {173169,36097,30171,12},
    [5] = {169573,36109,31836,3},
    [6] = {169349,36108,33277,3},
    [7] = {169907,36108,28228,9},
    [8] = {170090,36105,26550,9},
    [9] = {170640,36109,31648,2},
    [10] = {171298,36110,30965,1},
    [11] = {172712,36098,31771,1},
    [12] = {168693,36104,31418,4},
    [13] = {167646,36100,32627,4},
    [14] = {168197,36108,30710,5},
    [15] = {166551,36106,31289,5},
    [16] = {168339,36107,28984,7},
    [17] = {169071,36105,28389,8},
    [18] = {170744,36106,28621,10},
    [19] = {171733,36104,27238,10},
    [20] = {171281,36103,29279,11},
    [21] = {172807,36102,28607,11},
    [22] = {168318,36106,26754,8},
    [23] = {166857,36096,27988,7},
    [24] = {171274,36101,33145,2},
  },

  -- Side bosses
  -- Sail Ripper - Harpy
  sail_ripper_storm_cell = 169994, -- donut mechanic, cast on target
  -- Skills to ignore
  sail_ripper_talon = 169979, -- light attack
  sail_ripper_kick = 169978, -- light attack
  sail_ripper_bolt = 169980, -- ranged light attack
  -- Skills to ignore end
  sail_ripper_whirling_dervish = 169981, -- heavy attack. Already on CCA.
  -- TODO: Figure out what Coruscating Beam is.
  sail_ripper_coruscating_beam = 170036, -- jump or channel after jump??
  harpy_windcaller_wing_slice = 169991, -- harpy adds heavy attack 25k damage
  lightning_bounds = {
    124000, -- xmin
    175000, -- xmax
    151000, -- zmin
    181000 -- zmax
  },
  poison_bounds = {
    12000, -- xmin
    67000, -- xmax
    10000, -- zmin
    52000 -- zmax
  },

  -- Bow Breaker - Haj Mota
  -- Skills to ignore
  bow_breaker_shockwave = 169883,
  bow_breaker_devour = 169865,
  bow_breaker_toxic_spores = 169942,
  bow_breaker_claw = 169867,
  bow_breaker_bog_burst = 169897, -- 7.5k to DD
  -- Skills to ignore end
  -- Note it has two Horn strikes. This one deals 20k, the other one 5k
  bow_breaker_horn_strike_1 = 169869, -- heavy 20k to DDs with frontal cleave
  bow_breaker_horn_strike_2 = 169871, -- heavy 20k to DDs with frontal cleave
  bow_breaker_toxic_mucus = 169862, -- range loaded attack 10k to DDs

  -- TODO: Consider using UnpackRGBA(0xFFFFFFFF)
  -- Colors
  color = {
    ice       = {tonumber("0x99")/255, tonumber("0xCC")/255, tonumber("0xFF")/255}, -- #99CCFF
    fire      = {tonumber("0xFF")/255, tonumber("0x57")/255, tonumber("0x33")/255}, -- #FF5733
    lightning = {tonumber("0xFF")/255, tonumber("0xD6")/255, tonumber("0x66")/255}, -- #FFD666
    poison    = {tonumber("0x66")/255, tonumber("0xCC")/255, tonumber("0x66")/255}, -- #66CC66
    orange    = {tonumber("0xFF")/255, tonumber("0x85")/255, tonumber("0x00")/255}, -- #FF8500
    red       = {1, 0, 0},                                                          -- #FF0000
    green     = {tonumber("0x66")/255, tonumber("0xCC")/255, tonumber("0x66")/255}, -- #66CC66
    pink      = {tonumber("0xD6")/255, tonumber("0x72")/255, tonumber("0xF7")/255}, -- #D672F7
    teal      = {tonumber("0x03")/255, tonumber("0xC0")/255, tonumber("0xC1")/255}, -- #03C0C1
    cleave      = {tonumber("0xCC")/255, tonumber("0x00")/255, tonumber("0x00")/255}, -- #CC0000
    -- Taleria bridges colors
    taleria_green       = {tonumber("0x65")/255, tonumber("0xC9")/255, tonumber("0x66")/255}, -- #65c966
    taleria_yellow      = {tonumber("0xE8")/255, tonumber("0xDD")/255, tonumber("0x68")/255}, -- #e8dd68
    taleria_purple      = {tonumber("0xC1")/255, tonumber("0x5A")/255, tonumber("0xDB")/255}, -- #c15adb
  },

  -- Levers (x,y,z)
  -- towards North: z decreases
  -- towards West: x decreases
  levers = {
  	-- Poison
  	[1] = {22721, 36187, 26140},
  	[2] = {23556, 36188, 27631},
  	[3] = {13122, 37342, 30501},
  	[4] = {40750, 36737, 27427},
  	[5] = {36533, 36860, 22079},
  	[6] = {47614, 36239, 19973},
  	[7] = {53683, 36810, 27734},
  	[8] = {47919, 36828, 30261},
  	[9] = {51171, 36829, 36037},
  	-- Lightning
  	[10] = {128272, 38672, 178350},
  	[11] = {137433, 38416, 171494},
  	[12] = {140299, 38396, 166482},
  	[13] = {154579, 38717, 175626},
  	[14] = {154279, 38678, 171958},
  	[15] = {152676, 38558, 166055},
  	[16] = {156517, 38747, 162430},
  	[17] = {160597, 40740, 153309},
  	[18] = {150052, 40818, 153989},
  	-- Test values waiting room
  	--[[[19] = {27784, 15511, 175446},
  	[20] = {26302, 15519, 172229},
  	[21] = {28704, 15517, 171695},
    -- Test values ship outside
    [22] = {29407, 37729, 171449},
    [23] = {25683, 37729, 172277},
    [24] = {27891, 37719, 173234},--]]
  },

  -- Boss names.
  -- String lower, to make sure changes here keep strings in lowercase.
  lylanarName = string.lower("Lylanar"),
  turlassilName = string.lower("Turlassil"),
  reefGuardianName = string.lower("Reef Guardian"),
  taleriaName = string.lower("Tideborn Taleria"),

  --default_color = { 1, 0.7, 0, 0.5 },
  dodgeDuration = GetAbilityDuration(28549),
  maxDuration = 4000,
  holdBlock = "Hold Block!",
  dreadsailReefId = 1344,

  -- Taunt
  innerRage = 42056,
  pierceArmor = 38250,

  -- Reference ability used by Taleria tank detection.
  olms_swipe = 95428,
}
