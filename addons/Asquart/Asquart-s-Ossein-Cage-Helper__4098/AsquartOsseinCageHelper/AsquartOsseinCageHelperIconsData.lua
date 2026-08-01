AOCH = AOCH or {}
local AOCH = AOCH

AOCH.icons_data = {
  -- Coordinates:
  pack_number_coords = 
  {
    {178937,35384,88878}, -- 1.1
    {169769,35131,80818}, -- 1.2
    {164920,35092,80732}, -- 1.3
    {154649,34814,75241}, -- 1.4
    {160400,34420,68019}, -- 1.5
    {162331,34847,59298}, -- 1.6
    {171610,35115,58177}, -- 1.7
    {174669,34705,62229}, -- 1.8
    {173204,35394,72337}, -- 1.9
    {182872,35214,60284}, -- 1.10
    {67646,30097,147045}, -- 2.1
    {70507,30048,141164}, -- 2.2 left portal
    {71853,30033,141474}, -- 2.2 right portal
    {73544,29999,134602}, -- 2.3
    {73801,29975,127375}, -- 2.4 left portal
    {76388,29996,127209}, -- 2.4 left portal
    {75084,29989,120540}, -- 2.5
    {194760,38128,168006}, -- 3.1
    {190540,38352,173418}, -- 3.2
    {186569,38022,185103}, -- 3.3
    {178526,38025,191894}, -- 3.4
    {171642,38122,188617}, -- 3.5
    {163821,38417,183190}, -- 3.6
    {164319,38013,172839}, -- 3.7
  },

  num_pack_coords = 24,

  trash_pack_left_portal_positions =
    {{70610,30037,140424}, -- 2.2 
    {73443,29975,127202}},  -- 2.4
  
  trash_pack_right_portal_positions =
    {{72134,30036,141094}, -- 2.2 
    {76696,29996,126984}},  -- 2.4

  trash_pack_stack_positions =
    {{176642,35425,90113}, -- 1.1
    {166940,35398,79240},  -- 1.2
    {154394,34984,82066},  -- 1.3 - in portal
    {154623,34960,70399},  -- 1.4
    {162835,34638,62831},  -- 1.5
    {169351,34884,51846},  -- 1.6 - in portal
    {162044,34759,60005},  -- 1.6 - outside portal
    {175592,34821,58206},  -- 1.7
    {173904,34830,66844},  -- 1.8
    {182908,36330,72660},  -- 1.9
    {189702,35348,64680},  -- 1.10
    {71260,30046,142176},  -- 2.1
    {66927,31168,138713},  -- 2.2
    {75270,31173,142747},  -- 2.2 additional pos
    {74934,29998,129211},  -- 2.3
    {75496,29791,112647},  -- 2.5
    {76258,29808,112583},  -- 2.5 additional pos
    {193495,38125,172796},  -- 3.1
    {183484,40010,182322},  -- 3.2
    {184556,38085,186469},  -- 3.3
    {175694,38120,191166},  -- 3.4
    {168551,40544,186402},  -- 3.5
    {160717,38021,179606},  -- 3.6
    {174956,35928,166738}}, -- 3.7

  trash_pack_ot_stack_positions =
    {{153349,34832,73883},  -- 1.4
    {174507,34670,62942},  -- 1.8
    {75253,30034,129353},  -- 2.3
    {184498,38028,184829},  -- 3.3
    {176329,38196,190932},  -- 3.4
    {164471,37971,176591},  -- 3.6
    {172770,36247,163102}}, -- 3.7

  trash_pack_left_slayer_positions =
    {{178348,35574,90219}, -- 1.1
    {167488,35407,79870},  -- 1.2
    {153935,34958,82267},  -- 1.3
    {154372,34985,70287},  -- 1.4
    {162127,34571,63459},  -- 1.5
    {168832,34877,51401},  -- 1.6
    {174856,34780,57949},  -- 1.7
    {174626,34841,66935},  -- 1.8
    {182781,36278,73240},  -- 1.9
    {189372,35241,63993},  -- 1.10
    {70710,30050,142612},  -- 2.1
    {74666,30027,130048},  -- 2.3
    {75457,29854,113353},  -- 2.5
    {193967,38149,172114},  -- 3.1
    {183077,39990,182677},  -- 3.2
    {185305,38059,186113},  -- 3.3
    {175928,38067,191716},  -- 3.4
    {169024,40487,186199},  -- 3.5
    {159989,38037,179597},  -- 3.6
    {175556,35923,166643}}, -- 3.7

  trash_pack_right_slayer_positions =
    {{178216,35491,89897}, -- 1.1
    {167589,35412,79189},  -- 1.2
    {154487,34984,82698},  -- 1.3
    {156386,34972,71508},  -- 1.4
    {162779,34595,63612},  -- 1.5
    {168683,34893,51867},  -- 1.6
    {174857,34815,58509},  -- 1.7
    {172979,34831,66739},  -- 1.8
    {183380,36288,73176},  -- 1.9
    {188963,35287,64579},  -- 1.10
    {71272,30054,142885},  -- 2.1
    {75180,30064,130036},  -- 2.3
    {76158,29890,113386},  -- 2.5
    {193327,38134,172025},  -- 3.1
    {183586,40014,182837},  -- 3.2
    {184881,38030,185576},  -- 3.3
    {176355,38126,191276},  -- 3.4
    {168576,40517,185857},  -- 3.5
    {161273,38003,179346},  -- 3.6
    {174244,35929,166819}}, -- 3.7

  mini_boss_left_slayer_positions =
    {{74634,29996,24670}}, -- witch

  mini_boss_right_slayer_positions =
    {{74960,29996,25300}}, -- witch

  mini_boss_stack_positions =
    {{75166,29996,24798}}, -- witch

  witch_phantom_left_front = {74894,30002,22864},
  witch_phantom_left_back = {72849,30005,25001},
  witch_phantom_right_front = {76833,30014,26279},
  witch_phantom_right_back = {74454,30012,27218},

  hall_of_flesh_stack_positions_arc =
    {{216238,32950,74480},
    {215144,32950,73815},
    {214107,32950,74121},
    {213956,32958,75899},
    {214532,32950,76164},
    {215571,32950,76270}},

  hall_of_flesh_left_slayer_positions_arc =
    {{217497,32909,74237},
    {216196,32900,72572},
    {213754,32895,72508},
    {212650,32899,76821},
    {213824,32901,77423},
    {216021,32901,77519}},

  hall_of_flesh_right_slayer_positions_arc =
    {{217361,32893,73607},
    {215669,32891,72237},
    {213155,32891,72765},
    {213134,32901,77268},
    {214385,32902,77716},
    {216581,32903,77307}},

    hall_of_flesh_stack_positions =
    {{217458,32893,73655},
    {215709,32890,72189},
    {213161,32891,72630},
    {213103,32901,77262},
    {214305,32901,77775},
    {216556,32902,77379}},

  hall_of_flesh_left_slayer_positions =
    {{216245,32950,73989},
    {214944,32917,72992},
    {213443,32902,73706},
    {213768,32926,76636},
    {214914,32943,76824},
    {216587,32936,76348}},

  hall_of_flesh_right_slayer_positions =
    {{216789,32932,74739},
    {215759,32946,73420},
    {214242,32947,73336},
    {213169,32915,76264},
    {214102,32948,76566},
    {215633,32950,76598}},
  
  hall_of_flesh_add_spawn_locations =
  {{213575,32950,75358}, -- entrance location
  {216617,32950,74932}}, -- exit location

  jynorah_blue_boss_positions =
    {{104556,26153,129135}, -- entrance pos
    {104560,26153,131493}}, -- exit pos

  jynorah_red_boss_positions =
    {{105634,26153,129199}, -- entrance pos
    {105638,26153,131557}}, -- exit pos

  jynorah_exit_position = {105093,26237,133606},

  jynorah_blue_healer_positions =
    {{104863,26150,128405}, -- entrance pos
    {104860,26156,132259}}, -- exit pos

  jynorah_red_healer_positions =
    {{105330,26152,128446}, -- entrance pos
    {105330,26154,132273}}, -- exit pos

  jynorah_blue_dd1_positions =
    {{104110,26157,128614}, -- entrance pos
    {104137,26148,131962}}, -- exit pos

  jynorah_blue_dd2_positions =
    {{104137,26158,128115}, -- entrance pos
    {104106,26147,132462}}, -- exit pos

  jynorah_blue_dd3_positions =
    {{104536,26150,128677}, -- entrance pos
    {104568,26157,131949}}, -- exit pos

  jynorah_blue_dd4_positions =
    {{104557,26149,128107}, -- entrance pos
    {104522,26157,132518}}, -- exit pos

  jynorah_red_dd1_positions =
    {{106063,26154,128701}, -- entrance pos
    {106087,26152,132105}}, -- exit pos

  jynorah_red_dd2_positions =
    {{106069,26154,128253}, -- entrance pos
    {106040,26152,132551}}, -- exit pos

  jynorah_red_dd3_positions =
    {{105652,26153,128729}, -- entrance pos
    {105682,26153,132030}}, -- exit pos

  jynorah_red_dd4_positions =
    {{105661,26153,128177}, -- entrance pos
    {105626,26153,132579}}, -- exit pos

  kazpian_entrance_stack_pos = {50846,35550,193365},
  kazpian_entrance_left_slayer_pos = {51170,35550,192760},
  kazpian_entrance_right_slayer_pos = {50527,35550,192740},

  kazpian_low_warden_boss_pos = {52136,35573,205958},
  kazpian_low_warden_add_pos = {49684,35599,207005},
  kazpian_low_warden_left_slayer_pos = {49557,35599,206586},
  kazpian_low_warden_right_slayer_pos = {49804,35599,207358},

  kazpian_molag_kena_boss_pos = {50924,35550,193170},
  kazpian_molag_kena_add_pos = {49985,35550,192464},
  kazpian_molag_kena_left_slayer_pos = {50197,35550,192167},
  kazpian_molag_kena_right_slayer_pos = {49724,35550,192725},

  kazpian_krogo_boss_pos = {50701,35599,208695},
  kazpian_krogo_add_pos = {49713,35599,206971},
  kazpian_krogo_left_slayer_pos = {51123,35599,208051},
  kazpian_krogo_right_slayer_pos = {50022,35599,208487},

  -- Icons:
  -- Trash
  stack_texture = "AsquartOsseinCageHelper/icons/stack.dds",
  ot_stack_texture = "AsquartOsseinCageHelper/icons/ot_stack.dds",
  left_slayer_texture = "AsquartOsseinCageHelper/icons/left_slayer.dds",
  right_slayer_texture = "AsquartOsseinCageHelper/icons/right_slayer.dds",
  pack_number_textures = 
  {
    "AsquartOsseinCageHelper/icons/pack_1_1.dds",
    "AsquartOsseinCageHelper/icons/pack_1_2.dds",
    "AsquartOsseinCageHelper/icons/pack_1_3.dds",
    "AsquartOsseinCageHelper/icons/pack_1_4.dds",
    "AsquartOsseinCageHelper/icons/pack_1_5.dds",
    "AsquartOsseinCageHelper/icons/pack_1_6.dds",
    "AsquartOsseinCageHelper/icons/pack_1_7.dds",
    "AsquartOsseinCageHelper/icons/pack_1_8.dds",
    "AsquartOsseinCageHelper/icons/pack_1_9.dds",
    "AsquartOsseinCageHelper/icons/pack_1_10.dds",
    "AsquartOsseinCageHelper/icons/pack_2_1.dds",
    "AsquartOsseinCageHelper/icons/pack_2_2.dds", -- 2.2 left portal
    "AsquartOsseinCageHelper/icons/pack_2_2.dds", -- 2.2 right portal
    "AsquartOsseinCageHelper/icons/pack_2_3.dds",
    "AsquartOsseinCageHelper/icons/pack_2_4.dds", -- 2.4 left portal
    "AsquartOsseinCageHelper/icons/pack_2_4.dds", -- 2.4 left portal
    "AsquartOsseinCageHelper/icons/pack_2_5.dds",
    "AsquartOsseinCageHelper/icons/pack_3_1.dds",
    "AsquartOsseinCageHelper/icons/pack_3_2.dds",
    "AsquartOsseinCageHelper/icons/pack_3_3.dds",
    "AsquartOsseinCageHelper/icons/pack_3_4.dds",
    "AsquartOsseinCageHelper/icons/pack_3_5.dds",
    "AsquartOsseinCageHelper/icons/pack_3_6.dds",
    "AsquartOsseinCageHelper/icons/pack_3_7.dds",
  },

  -- Mini Bosses
  phantom_left_back_texture = "AsquartOsseinCageHelper/icons/phantom_left_back.dds",
  phantom_left_front_texture = "AsquartOsseinCageHelper/icons/phantom_left_front.dds",
  phantom_right_back_texture = "AsquartOsseinCageHelper/icons/phantom_right_back.dds",
  phantom_right_front_texture = "AsquartOsseinCageHelper/icons/phantom_right_front.dds",

  -- Hall of Fleshcraft
  harvester_spawn_texture_1 = "AsquartOsseinCageHelper/icons/harvester_1.dds",
  harvester_spawn_texture_2 = "AsquartOsseinCageHelper/icons/harvester_2.dds",
  ogrim_texture = "AsquartOsseinCageHelper/icons/ogrim.dds",

  -- Jynorah and Skorknif
  jynorah_stack_texture = "AsquartOsseinCageHelper/icons/jynorah.dds",
  skorknif_stack_texture = "AsquartOsseinCageHelper/icons/skorknif.dds",
  healer_red_texture = "AsquartOsseinCageHelper/icons/healer_red.dds",
  healer_blue_texture = "AsquartOsseinCageHelper/icons/healer_blue.dds",
  dd_red_1_texture = "AsquartOsseinCageHelper/icons/dd_red_1.dds",
  dd_red_2_texture = "AsquartOsseinCageHelper/icons/dd_red_2.dds",
  dd_red_3_texture = "AsquartOsseinCageHelper/icons/dd_red_3.dds",
  dd_red_4_texture = "AsquartOsseinCageHelper/icons/dd_red_4.dds",
  dd_blue_1_texture = "AsquartOsseinCageHelper/icons/dd_blue_1.dds",
  dd_blue_2_texture = "AsquartOsseinCageHelper/icons/dd_blue_2.dds",
  dd_blue_3_texture = "AsquartOsseinCageHelper/icons/dd_blue_3.dds",
  dd_blue_4_texture = "AsquartOsseinCageHelper/icons/dd_blue_4.dds",
  exit_texture = "AsquartOsseinCageHelper/icons/exit.dds",

  -- Overfiend Kazpian
  kazpian_stack_texture = "AsquartOsseinCageHelper/icons/kazpian.dds",
  molag_kena_stack_texture = "AsquartOsseinCageHelper/icons/molag_kena.dds",
  low_warden_stack_texture = "AsquartOsseinCageHelper/icons/low_warden.dds",
  krogo_stack_texture = "AsquartOsseinCageHelper/icons/krogo.dds",
  bomb_1_texture = "AsquartOsseinCageHelper/icons/bomb_1.dds",
  bomb_2_texture = "AsquartOsseinCageHelper/icons/bomb_2.dds",
}