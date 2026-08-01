FCOGamepadButtonTextures = {}
local fcogpbt = FCOGamepadButtonTextures

fcogpbt.addonVars = {}
local addonVars = fcogpbt.addonVars
addonVars.name = "FCOGamepadButtonTextures"
addonVars.author = "Baertram"
addonVars.version = '2.0'
local addonName = addonVars.name


local EM = EVENT_MANAGER
local clientLang = GetCVar("language.2")
local tos = tostring
local strformat = string.format


local buttonTexturesPossibilities = {
    [1] = "xbone",
    [2] = "ps4",
    [3] = "ps5",
    [4] = "xbsx",
}
local xbone =   buttonTexturesPossibilities[1]
local ps4 =     buttonTexturesPossibilities[2]
local ps5 =     buttonTexturesPossibilities[3]
local xbsx =	buttonTexturesPossibilities[4]

--SavedVariables
fcogpbt.settingsVars = {}
fcogpbt.settingsVars.svName = "FCOGamepadButtonTextures_SV"
fcogpbt.settingsVars.svVersion = 1
local defaultSVForAll = {
    saveMode     		    = 2, --Standard: Account wide settings
}
fcogpbt.settingsVars.settingsForAll = {}
local defaultSV = {
    lastChosenGamepadButtonTextures = 1,
    chosenGamepadButtonTextures = 1,
}
fcogpbt.settingsVars.settings = {}

--Textures and patterns
local prefixGamepadButtonsPath = "/esoui/art/buttons/gamepad"

--The texture folder and file name contents
--1st occurence of %s in string gamepadTexturesPatterns["xbonxone"] index 1 will be replaced with
--gamepadTexturesNames["xbone"]["folder"], 2nd with ["file"], 3rd with the client language
local gamepadTextureParts = {
    [ps4]   = {folder = "ps4",  file = "ps4",   language = clientLang, },
    [ps5]   = {folder = "ps5",  file = "ps5",   language = clientLang, },
    [xbone] = {folder = "xbox", file = "xbone", language = clientLang, },
    [xbsx]  = {folder = "scarlett", file = "scarlett", language = clientLang, },
}

--DO NOT CHANGE THE ORDER OF ENTRIES AS THEY WILL BE REPLACED FROM TOP TO BOTTOM
--(e.g. xbox index 15 against against ps4 index 15)!
local gamepadTexturesPatterns = {
    [ps4] = { 
        [1] = "%s/%s/console_art_%s.dds",
        [2] = "%s/%s/nav_%s_trackpad_press.dds",
        [3] = "%s/%s/nav_%s_x.dds",
        [4] = "%s/%s/nav_%s_x_hold.dds",
        [5] = "%s/%s/nav_%s_x_hold_%s.dds",
        [6] = "%s/%s/nav_%s_x_hold_greyedout_%s.dds",
        [7] = "%s/%s/nav_%s_circle.dds",
        [8] = "%s/%s/nav_%s_circle_hold.dds",
        [9] = "%s/%s/nav_%s_circle_hold_%s.dds",
        [10] = "%s/%s/nav_%s_circle_hold_greyedout_%s.dds",
        [11] = "%s/%s/nav_%s_dpad.dds",
        [12] = "%s/%s/nav_%s_dpad_down_hold.dds",
        [13] = "%s/%s/nav_%s_dpad_down_hold_%s.dds",
        [14] = "%s/%s/nav_%s_dpad_down_hold_greyedout_%s.dds",
        [15] = "%s/%s/nav_%s_dpad_left_hold.dds",
        [16] = "%s/%s/nav_%s_dpad_left_hold_%s.dds",
        [17] = "%s/%s/nav_%s_dpad_left_hold_greyedout_%s.dds",
        [18] = "%s/%s/nav_%s_dpad_right_hold.dds",
        [19] = "%s/%s/nav_%s_dpad_right_hold_%s.dds",
        [20] = "%s/%s/nav_%s_dpad_right_hold_greyedout_%s.dds",
        [21] = "%s/%s/nav_%s_dpad_up_hold.dds",
        [22] = "%s/%s/nav_%s_dpad_up_hold_%s.dds",
        [23] = "%s/%s/nav_%s_dpad_up_hold_greyedout_%s.dds",
        [24] = "%s/%s/nav_%s_dpaddown.dds",
        [25] = "%s/%s/nav_%s_dpaddown_hold.dds",
        [26] = "%s/%s/nav_%s_dpaddown_hold_rs.dds",
        [27] = "%s/%s/nav_%s_dpadleft.dds",
        [28] = "%s/%s/nav_%s_dpadleft_hold.dds",
        [29] = "%s/%s/nav_%s_dpadright.dds",
        [30] = "%s/%s/nav_%s_dpadright_hold.dds",
        [31] = "%s/%s/nav_%s_dpadrightcircle.dds",
        [32] = "%s/%s/nav_%s_dpadup.dds",
        [33] = "%s/%s/nav_%s_dpadup_hold.dds",
        [34] = "%s/%s/nav_%s_dpadup.dds",
        [35] = "%s/%s/nav_%s_hold_l2_press_r2.dds",
        [36] = "%s/%s/nav_%s_hold_l2_press_r2_%s.dds",
        [37] = "%s/%s/nav_%s_l1.dds",
        [38] = "%s/%s/nav_%s_l1_hold.dds",
        [39] = "%s/%s/nav_%s_l1x.dds",
        [40] = "%s/%s/nav_%s_l1circle.dds",
        [41] = "%s/%s/nav_%s_l1dpaddown.dds",
        [42] = "%s/%s/nav_%s_l1dpadleft.dds",
        [43] = "%s/%s/nav_%s_l1r1.dds",
        [44] = "%s/%s/nav_%s_l1rs_press.dds",
        [45] = "%s/%s/nav_%s_l1rs_right.dds",
        [46] = "%s/%s/nav_%s_l1r2.dds",
        [47] = "%s/%s/nav_%s_l1square.dds",
        [48] = "%s/%s/nav_%s_l1triangle.dds",
        [49] = "%s/%s/nav_%s_left_shoulder_hold.dds",
        [50] = "%s/%s/nav_%s_left_shoulder_hold_%s.dds",
        [51] = "%s/%s/nav_%s_left_shoulder_hold_greyedout_%s.dds",
        [52] = "%s/%s/nav_%s_left_trigger_hold.dds",
        [53] = "%s/%s/nav_%s_left_trigger_hold_%s.dds",
        [54] = "%s/%s/nav_%s_left_trigger_hold_greyedout_%s.dds",
        [55] = "%s/%s/nav_%s_touchpad_hold.dds",
        [56] = "%s/%s/nav_%s_trackpadoptions.dds",
        [57] = "%s/%s/nav_%s_ls.dds",
        [58] = "%s/%s/nav_%s_ls_click.dds",
        [59] = "%s/%s/nav_%s_ls_down.dds",
        [60] = "%s/%s/nav_%s_ls_hold.dds",
        [61] = "%s/%s/nav_%s_ls_hold_%s.dds",
        [62] = "%s/%s/nav_%s_ls_left.dds",
        [63] = "%s/%s/nav_%s_ls_press.dds",
        [64] = "%s/%s/nav_%s_ls_right.dds",
        [65] = "%s/%s/nav_%s_ls_scroll.dds",
        [66] = "%s/%s/nav_%s_ls_slide.dds",
        [67] = "%s/%s/nav_%s_ls_slide_scroll.dds",
        [68] = "%s/%s/nav_%s_ls_up.dds",
        [69] = "%s/%s/nav_%s_lsrs.dds",
        [70] = "%s/%s/nav_%s_lsrs_click.dds",
        [71] = "%s/%s/nav_%s_lsrs_press.dds",
        [72] = "%s/%s/nav_%s_l2.dds",
        [73] = "%s/%s/nav_%s_l2_dim.dds",
        [74] = "%s/%s/nav_%s_l2_hold.dds",
        [75] = "%s/%s/nav_%s_l2x.dds",
        [76] = "%s/%s/nav_%s_l2circle.dds",
        [77] = "%s/%s/nav_%s_l2r2.dds",
        [78] = "%s/%s/nav_%s_l2square.dds",
        [79] = "%s/%s/nav_%s_l2triangle.dds",
        [80] = "%s/%s/nav_%s_options_hold.dds",
        [81] = "%s/%s/nav_%s_options_hold.dds",
        [82] = "%s/%s/nav_%s_options_hold_greyedout_%s.dds",
        [83] = "%s/%s/nav_%s_r1.dds",
        [84] = "%s/%s/nav_%s_r1_hold.dds",
        [85] = "%s/%s/nav_%s_r1x.dds",
        [86] = "%s/%s/nav_%s_r1circle.dds",
        [87] = "%s/%s/nav_%s_r1square.dds",
        [88] = "%s/%s/nav_%s_r1triangle.dds",
        [89] = "%s/%s/nav_%s_right_shoulder_hold.dds",
        [90] = "%s/%s/nav_%s_right_shoulder_hold_%s.dds",
        [91] = "%s/%s/nav_%s_right_shoulder_hold_greyedout_%s.dds",
        [92] = "%s/%s/nav_%s_right_trigger_hold.dds",
        [93] = "%s/%s/nav_%s_right_trigger_hold_%s.dds",
        [94] = "%s/%s/nav_%s_right_trigger_hold_greyedout_%s.dds",
        [95] = "%s/%s/nav_%s_options_hold.dds",
        [96] = "%s/%s/nav_%s_rs.dds",
        [97] = "%s/%s/nav_%s_rs_click.dds",
        [98] = "%s/%s/nav_%s_rs_down.dds",
        [99] = "%s/%s/nav_%s_rs_hold.dds",
        [100] = "%s/%s/nav_%s_rs_hold_%s.dds",
        [101] = "%s/%s/nav_%s_rs_left.dds",
        [102] = "%s/%s/nav_%s_options.dds",
        [103] = "%s/%s/nav_%s_rs_press.dds",
        [104] = "%s/%s/nav_%s_rs_right.dds",
        [105] = "%s/%s/nav_%s_rs_scroll.dds",
        [106] = "%s/%s/nav_%s_rs_slide.dds",
        [107] = "%s/%s/nav_%s_rs_slide_scroll.dds",
        [108] = "%s/%s/nav_%s_rs_up.dds",
        [109] = "%s/%s/nav_%s_r2.dds",
        [110] = "%s/%s/nav_%s_r2_dim.dds",
        [111] = "%s/%s/nav_%s_r2_hold.dds",
        [112] = "%s/%s/nav_%s_trackpad_press.dds",
        [113] = "%s/%s/nav_%s_touchpad_hold.dds",
        [114] = "%s/%s/nav_%s_touchpad_hold_%s.dds",
        [115] = "%s/%s/nav_%s_touchpad_hold_greyedout_%s.dds",
        [116] = "%s/%s/nav_%s_square.dds",
        [117] = "%s/%s/nav_%s_square_hold.dds",
        [118] = "%s/%s/nav_%s_square_hold_%s.dds",
        [119] = "%s/%s/nav_%s_square_hold_greyedout_%s.dds",
        [120] = "%s/%s/nav_%s_triangle.dds",
        [121] = "%s/%s/nav_%s_triangle_hold.dds",
        [122] = "%s/%s/nav_%s_triangle_hold_%s.dds",
        [123] = "%s/%s/nav_%s_triangle_hold_greyedout_%s.dds",
        [124] = "%s/%s/nav_%s_trianglecircle.dds",
        [125] = "%s/%s/nav_%s_options.dds",
    },
    [ps5] = {
        [1] ="%s/%s/console_art_%s.dds",
        [2] ="%s/%s/nav_%s_trackpad_press.dds",
        [3] ="%s/%s/nav_%s_x.dds",
        [4] ="%s/%s/nav_%s_x_hold.dds",
        [5] ="%s/%s/nav_%s_x_hold_%s.dds",
        [6] ="%s/%s/nav_%s_x_hold_greyedout_%s.dds",
        [7] ="%s/%s/nav_%s_circle.dds",
        [8] ="%s/%s/nav_%s_circle_hold.dds",
        [9] ="%s/%s/nav_%s_circle_hold_%s.dds",
        [10] ="%s/%s/nav_%s_circle_hold_greyedout_%s.dds",
        [11] ="%s/%s/nav_%s_dpad.dds",
        [12] ="%s/%s/nav_%s_dpad_down_hold.dds",
        [13] ="%s/%s/nav_%s_dpad_down_hold_%s.dds",
        [14] ="%s/%s/nav_%s_dpad_down_hold_greyedout_%s.dds",
        [15] ="%s/%s/nav_%s_dpad_left_hold.dds",
        [16] ="%s/%s/nav_%s_dpad_left_hold_%s.dds",
        [17] ="%s/%s/nav_%s_dpad_left_hold_greyedout_%s.dds",
        [18] ="%s/%s/nav_%s_dpad_right_hold.dds",
        [19] ="%s/%s/nav_%s_dpad_right_hold_%s.dds",
        [20] ="%s/%s/nav_%s_dpad_right_hold_greyedout_%s.dds",
        [21] ="%s/%s/nav_%s_dpad_up_hold.dds",
        [22] ="%s/%s/nav_%s_dpad_up_hold_%s.dds",
        [23] ="%s/%s/nav_%s_dpad_up_hold_greyedout_%s.dds",
        [24] ="%s/%s/nav_%s_dpaddown.dds",
        [25] ="%s/%s/nav_%s_dpaddown_hold.dds",
        [26] ="%s/%s/nav_%s_dpaddown_hold_rs.dds",
        [27] ="%s/%s/nav_%s_dpadleft.dds",
        [28] ="%s/%s/nav_%s_dpadleft_hold.dds",
        [29] ="%s/%s/nav_%s_dpadright.dds",
        [30] ="%s/%s/nav_%s_dpadright_hold.dds",
        [31] ="%s/%s/nav_%s_dpadrightcircle.dds",
        [32] ="%s/%s/nav_%s_dpadup.dds",
        [33] ="%s/%s/nav_%s_dpadup_hold.dds",
        [34] ="%s/%s/nav_%s_dpadup.dds",
        [35] ="%s/%s/nav_%s_hold_l2_press_r2.dds",
        [36] ="%s/%s/nav_%s_hold_l2_press_r2_%s.dds",
        [37] ="%s/%s/nav_%s_l1.dds",
        [38] ="%s/%s/nav_%s_l1_hold.dds",
        [39] ="%s/%s/nav_%s_l1x.dds",
        [40] ="%s/%s/nav_%s_l1circle.dds",
        [41] ="%s/%s/nav_%s_l1dpaddown.dds",
        [42] ="%s/%s/nav_%s_l1dpadleft.dds",
        [43] ="%s/%s/nav_%s_l1r1.dds",
        [44] ="%s/%s/nav_%s_l1rs_press.dds",
        [45] ="%s/%s/nav_%s_l1rs_right.dds",
        [46] ="%s/%s/nav_%s_l1r2.dds",
        [47] ="%s/%s/nav_%s_l1square.dds",
        [48] ="%s/%s/nav_%s_l1triangle.dds",
        [49] ="%s/%s/nav_%s_left_shoulder_hold.dds",
        [50] ="%s/%s/nav_%s_left_shoulder_hold_%s.dds",
        [51] ="%s/%s/nav_%s_left_shoulder_hold_greyedout_%s.dds",
        [52] ="%s/%s/nav_%s_left_trigger_hold.dds",
        [53] ="%s/%s/nav_%s_left_trigger_hold_%s.dds",
        [54] ="%s/%s/nav_%s_left_trigger_hold_greyedout_%s.dds",
        [55] ="%s/%s/nav_%s_touchpad_hold.dds",
        [56] ="%s/%s/nav_%s_trackpadoptions.dds",
        [57] ="%s/%s/nav_%s_ls.dds",
        [58] ="%s/%s/nav_%s_ls_click.dds",
        [59] ="%s/%s/nav_%s_ls_down.dds",
        [60] ="%s/%s/nav_%s_ls_hold.dds",
        [61] ="%s/%s/nav_%s_ls_hold_%s.dds",
        [62] ="%s/%s/nav_%s_ls_left.dds",
        [63] ="%s/%s/nav_%s_ls_press.dds",
        [64] ="%s/%s/nav_%s_ls_right.dds",
        [65] ="%s/%s/nav_%s_ls_scroll.dds",
        [66] ="%s/%s/nav_%s_ls_slide.dds",
        [67] ="%s/%s/nav_%s_ls_slide_scroll.dds",
        [68] ="%s/%s/nav_%s_ls_up.dds",
        [69] ="%s/%s/nav_%s_lsrs.dds",
        [70] ="%s/%s/nav_%s_lsrs_click.dds",
        [71] ="%s/%s/nav_%s_lsrs_press.dds",
        [72] ="%s/%s/nav_%s_l2.dds",
        [73] ="%s/%s/nav_%s_l2_dim.dds",
        [74] ="%s/%s/nav_%s_l2_hold.dds", --does not exits at ps5?
        [75] ="%s/%s/nav_%s_l2x.dds",
        [76] ="%s/%s/nav_%s_l2circle.dds",
        [77] ="%s/%s/nav_%s_l2r2.dds",
        [78] ="%s/%s/nav_%s_l2square.dds",
        [79] ="%s/%s/nav_%s_l2triangle.dds",
        [80] ="%s/%s/nav_%s_options_hold.dds",
        [81] ="%s/%s/nav_%s_options_hold_%s.dds",
        [82] ="%s/%s/nav_%s_options_hold_greyedout_%s.dds",
        [83] ="%s/%s/nav_%s_r1.dds",
        [84] ="%s/%s/nav_%s_r1_hold.dds", --does not exits at ps5?
        [85] ="%s/%s/nav_%s_r1x.dds",
        [86] ="%s/%s/nav_%s_r1circle.dds",
        [87] ="%s/%s/nav_%s_r1square.dds",
        [88] ="%s/%s/nav_%s_r1triangle.dds",
        [89] ="%s/%s/nav_%s_right_shoulder_hold.dds",
        [90] ="%s/%s/nav_%s_right_shoulder_hold_%s.dds",
        [91] ="%s/%s/nav_%s_right_shoulder_hold_greyedout_%s.dds",
        [92] ="%s/%s/nav_%s_right_trigger_hold.dds",
        [93] ="%s/%s/nav_%s_right_trigger_hold_%s.dds",
        [94] ="%s/%s/nav_%s_right_trigger_hold_greyedout_%s.dds",
        [95] ="%s/%s/nav_%s_options_hold.dds",
        [96] ="%s/%s/nav_%s_rs.dds",
        [97] ="%s/%s/nav_%s_rs_click.dds",
        [98] ="%s/%s/nav_%s_rs_down.dds",
        [99] ="%s/%s/nav_%s_rs_hold.dds",
        [100] ="%s/%s/nav_%s_rs_hold_%s.dds",
        [101] ="%s/%s/nav_%s_rs_left.dds",
        [102] ="%s/%s/nav_%s_options.dds",
        [103] ="%s/%s/nav_%s_rs_press.dds",
        [104] ="%s/%s/nav_%s_rs_right.dds",
        [105] ="%s/%s/nav_%s_rs_scroll.dds",
        [106] ="%s/%s/nav_%s_rs_slide.dds",
        [107] ="%s/%s/nav_%s_rs_slide_scroll.dds",
        [108] ="%s/%s/nav_%s_rs_up.dds",
        [109] ="%s/%s/nav_%s_r2.dds",
        [110] ="%s/%s/nav_%s_r2_dim.dds",
        [111] ="%s/%s/nav_%s_r2_hold.dds", --does not exits at ps5?
        [112] ="%s/%s/nav_%s_trackpad_press.dds",
        [113] ="%s/%s/nav_%s_touchpad_hold.dds",
        [114] ="%s/%s/nav_%s_touchpad_hold_%s.dds",
        [115] ="%s/%s/nav_%s_touchpad_hold_greyedout_%s.dds",
        [116] ="%s/%s/nav_%s_square.dds",
        [117] ="%s/%s/nav_%s_square_hold.dds",
        [118] ="%s/%s/nav_%s_square_hold_%s.dds",
        [119] ="%s/%s/nav_%s_square_hold_greyedout_%s.dds",
        [120] ="%s/%s/nav_%s_triangle.dds",
        [121] ="%s/%s/nav_%s_triangle_hold.dds",
        [122] ="%s/%s/nav_%s_triangle_hold_%s.dds",
        [123] ="%s/%s/nav_%s_triangle_hold_greyedout_%s.dds",
        [124] ="%s/%s/nav_%s_trianglecircle.dds",
        [125] ="%s/%s/nav_%s_options.dds",
    },
    [xbone] = {
        [1] = "%s/%s/console_art_xb1.dds",
        [2] = "%s/%s/leftarrow_down.dds",
        [3] = "%s/%s/nav_%s_a.dds",
        [4] = "%s/%s/nav_%s_a_hold.dds",
        [5] = "%s/%s/nav_%s_a_hold_en.dds",
        [6] = "%s/%s/nav_%s_a_hold_greyedout_en.dds",
        [7] = "%s/%s/nav_%s_b.dds",
        [8] = "%s/%s/nav_%s_b_hold.dds",
        [9] = "%s/%s/nav_%s_b_hold_en.dds",
        [10] = "%s/%s/nav_%s_b_hold_greyedout_en.dds",
        [11] = "%s/%s/nav_%s_dpad.dds",
        [12] = "%s/%s/nav_%s_dpad_down_hold.dds",
        [13] = "%s/%s/nav_%s_dpad_down_hold_en.dds",
        [14] = "%s/%s/nav_%s_dpad_down_hold_greyedout_en.dds",
        [15] = "%s/%s/nav_%s_dpad_left_hold.dds",
        [16] = "%s/%s/nav_%s_dpad_left_hold_en.dds",
        [17] = "%s/%s/nav_%s_dpad_left_hold_greyedout_en.dds",
        [18] = "%s/%s/nav_%s_dpad_right_hold.dds",
        [19] = "%s/%s/nav_%s_dpad_right_hold_en.dds",
        [20] = "%s/%s/nav_%s_dpad_right_hold_greyedout_en.dds",
        [21] = "%s/%s/nav_%s_dpad_up_hold.dds",
        [22] = "%s/%s/nav_%s_dpad_up_hold_en.dds",
        [23] = "%s/%s/nav_%s_dpad_up_hold_greyedout_en.dds",
        [24] = "%s/%s/nav_%s_dpaddown.dds",
        [25] = "%s/%s/nav_%s_dpaddown_hold.dds",
        [26] = "%s/%s/nav_%s_dpaddown_hold_rs.dds",
        [27] = "%s/%s/nav_%s_dpadleft.dds",
        [28] = "%s/%s/nav_%s_dpadleft_hold.dds",
        [29] = "%s/%s/nav_%s_dpadright.dds",
        [30] = "%s/%s/nav_%s_dpadright_hold.dds",
        [31] = "%s/%s/nav_%s_dpadrightb.dds",
        [32] = "%s/%s/nav_%s_dpadup.dds",
        [33] = "%s/%s/nav_%s_dpadup_hold.dds",
        [34] = "%s/%s/nav_%s_du.dds",
        [35] = "%s/%s/nav_%s_hold_lt_press_rt.dds",
        [36] = "%s/%s/nav_%s_hold_lt_press_rt_en.dds",
        [37] = "%s/%s/nav_%s_lb.dds",
        [38] = "%s/%s/nav_%s_lb_hold.dds",
        [39] = "%s/%s/nav_%s_lba.dds",
        [40] = "%s/%s/nav_%s_lbb.dds",
        [41] = "%s/%s/nav_%s_lbdpaddown.dds",
        [42] = "%s/%s/nav_%s_lbdpadleft.dds",
        [43] = "%s/%s/nav_%s_lbrb.dds",
        [44] = "%s/%s/nav_%s_lbrs_press.dds",
        [45] = "%s/%s/nav_%s_lbrs_right.dds",
        [46] = "%s/%s/nav_%s_lbrt.dds",
        [47] = "%s/%s/nav_%s_lbx.dds",
        [48] = "%s/%s/nav_%s_lby.dds",
        [49] = "%s/%s/nav_%s_left_shoulder_hold.dds",
        [50] = "%s/%s/nav_%s_left_shoulder_hold_en.dds",
        [51] = "%s/%s/nav_%s_left_shoulder_hold_greyedout_en.dds",
        [52] = "%s/%s/nav_%s_left_trigger_hold.dds",
        [53] = "%s/%s/nav_%s_left_trigger_hold_en.dds",
        [54] = "%s/%s/nav_%s_left_trigger_hold_greyedout_en.dds",
        [55] = "%s/%s/nav_%s_leftarrow_down_hold.dds",
        [56] = "%s/%s/nav_%s_leftarrowrightarrow.dds",
        [57] = "%s/%s/nav_%s_ls.dds",
        [58] = "%s/%s/nav_%s_ls_click.dds",
        [59] = "%s/%s/nav_%s_ls_down.dds",
        [60] = "%s/%s/nav_%s_ls_hold.dds",
        [61] = "%s/%s/nav_%s_ls_hold_en.dds",
        [62] = "%s/%s/nav_%s_ls_left.dds",
        [63] = "%s/%s/nav_%s_ls_press.dds",
        [64] = "%s/%s/nav_%s_ls_right.dds",
        [65] = "%s/%s/nav_%s_ls_scroll.dds",
        [66] = "%s/%s/nav_%s_ls_slide.dds",
        [67] = "%s/%s/nav_%s_ls_slide_scroll.dds",
        [68] = "%s/%s/nav_%s_ls_up.dds",
        [69] = "%s/%s/nav_%s_lsrs.dds",
        [70] = "%s/%s/nav_%s_lsrs_click.dds",
        [71] = "%s/%s/nav_%s_lsrs_press.dds",
        [72] = "%s/%s/nav_%s_lt.dds",
        [73] = "%s/%s/nav_%s_lt_dim.dds",
        [74] = "%s/%s/nav_%s_lt_hold.dds",
        [75] = "%s/%s/nav_%s_lta.dds",
        [76] = "%s/%s/nav_%s_ltb.dds",
        [77] = "%s/%s/nav_%s_ltrt.dds",
        [78] = "%s/%s/nav_%s_ltx.dds",
        [79] = "%s/%s/nav_%s_lty.dds",
        [80] = "%s/%s/nav_%s_menu_button_hold.dds",
        [81] = "%s/%s/nav_%s_menu_button_hold_en.dds",
        [82] = "%s/%s/nav_%s_menu_button_hold_greyedout_en.dds",
        [83] = "%s/%s/nav_%s_rb.dds",
        [84] = "%s/%s/nav_%s_rb_hold.dds",
        [85] = "%s/%s/nav_%s_rba.dds",
        [86] = "%s/%s/nav_%s_rbb.dds",
        [87] = "%s/%s/nav_%s_rbx.dds",
        [88] = "%s/%s/nav_%s_rby.dds",
        [89] = "%s/%s/nav_%s_right_shoulder_hold.dds",
        [90] = "%s/%s/nav_%s_right_shoulder_hold_en.dds",
        [91] = "%s/%s/nav_%s_right_shoulder_hold_greyedout_en.dds",
        [92] = "%s/%s/nav_%s_right_trigger_hold.dds",
        [93] = "%s/%s/nav_%s_right_trigger_hold_en.dds",
        [94] = "%s/%s/nav_%s_right_trigger_hold_greyedout_en.dds",
        [95] = "%s/%s/nav_%s_rightarrow_down_hold.dds",
        [96] = "%s/%s/nav_%s_rs.dds",
        [97] = "%s/%s/nav_%s_rs_click.dds",
        [98] = "%s/%s/nav_%s_rs_down.dds",
        [99] = "%s/%s/nav_%s_rs_hold.dds",
        [100] = "%s/%s/nav_%s_rs_hold_en.dds",
        [101] = "%s/%s/nav_%s_rs_left.dds",
        [102] = "%s/%s/nav_%s_rs_menu.dds",
        [103] = "%s/%s/nav_%s_rs_press.dds",
        [104] = "%s/%s/nav_%s_rs_right.dds",
        [105] = "%s/%s/nav_%s_rs_scroll.dds",
        [106] = "%s/%s/nav_%s_rs_slide.dds",
        [107] = "%s/%s/nav_%s_rs_slide_scroll.dds",
        [108] = "%s/%s/nav_%s_rs_up.dds",
        [109] = "%s/%s/nav_%s_rt.dds",
        [110] = "%s/%s/nav_%s_rt_dim.dds",
        [111] = "%s/%s/nav_%s_rt_hold.dds",
        [112] = "%s/%s/nav_%s_view.dds",
        [113] = "%s/%s/nav_%s_view_button_hold.dds",
        [114] = "%s/%s/nav_%s_view_button_hold_en.dds",
        [115] = "%s/%s/nav_%s_view_button_hold_greyedout_en.dds",
        [116] = "%s/%s/nav_%s_x.dds",
        [117] = "%s/%s/nav_%s_x_hold.dds",
        [118] = "%s/%s/nav_%s_x_hold_en.dds",
        [119] = "%s/%s/nav_%s_x_hold_greyedout_en.dds",
        [120] = "%s/%s/nav_%s_y.dds",
        [121] = "%s/%s/nav_%s_y_hold.dds",
        [122] = "%s/%s/nav_%s_y_hold_en.dds",
        [123] = "%s/%s/nav_%s_y_hold_greyedout_en.dds",
        [124] = "%s/%s/nav_%s_yb.dds",
        [125] = "%s/%s/rightarrow_down.dds",
    },
    [xbsx] = {
        [1] = "%s/%s/console_art_xb1.dds",
        [2] = "%s/%s/leftarrow_down.dds",
        [3] = "%s/%s/nav_%s_a.dds",
        [4] = "%s/%s/nav_%s_a_hold.dds",
        [5] = "%s/%s/nav_%s_a_hold_en.dds",
        [6] = "%s/%s/nav_%s_a_hold_greyedout_en.dds",
        [7] = "%s/%s/nav_%s_b.dds",
        [8] = "%s/%s/nav_%s_b_hold.dds",
        [9] = "%s/%s/nav_%s_b_hold_en.dds",
        [10] = "%s/%s/nav_%s_b_hold_greyedout_en.dds",
        [11] = "%s/%s/nav_%s_dpad.dds",
        [12] = "%s/%s/nav_%s_dpad_down_hold.dds",
        [13] = "%s/%s/nav_%s_dpad_down_hold_en.dds",
        [14] = "%s/%s/nav_%s_dpad_down_hold_greyedout_en.dds",
        [15] = "%s/%s/nav_%s_dpad_left_hold.dds",
        [16] = "%s/%s/nav_%s_dpad_left_hold_en.dds",
        [17] = "%s/%s/nav_%s_dpad_left_hold_greyedout_en.dds",
        [18] = "%s/%s/nav_%s_dpad_right_hold.dds",
        [19] = "%s/%s/nav_%s_dpad_right_hold_en.dds",
        [20] = "%s/%s/nav_%s_dpad_right_hold_greyedout_en.dds",
        [21] = "%s/%s/nav_%s_dpad_up_hold.dds",
        [22] = "%s/%s/nav_%s_dpad_up_hold_en.dds",
        [23] = "%s/%s/nav_%s_dpad_up_hold_greyedout_en.dds",
        [24] = "%s/%s/nav_%s_dpaddown.dds",
        [25] = "%s/%s/nav_%s_dpaddown_hold.dds",
        [26] = "%s/%s/nav_%s_dpaddown_hold_rs.dds",
        [27] = "%s/%s/nav_%s_dpadleft.dds",
        [28] = "%s/%s/nav_%s_dpadleft_hold.dds",
        [29] = "%s/%s/nav_%s_dpadright.dds",
        [30] = "%s/%s/nav_%s_dpadright_hold.dds",
        [31] = "%s/%s/nav_%s_dpadrightb.dds",
        [32] = "%s/%s/nav_%s_dpadup.dds",
        [33] = "%s/%s/nav_%s_dpadup_hold.dds",
        [34] = "%s/%s/nav_%s_du.dds",
        [35] = "%s/%s/nav_%s_hold_lt_press_rt.dds",
        [36] = "%s/%s/nav_%s_hold_lt_press_rt_en.dds",
        [37] = "%s/%s/nav_%s_lb.dds",
        [38] = "%s/%s/nav_%s_lb_hold.dds",
        [39] = "%s/%s/nav_%s_lba.dds",
        [40] = "%s/%s/nav_%s_lbb.dds",
        [41] = "%s/%s/nav_%s_lbdpaddown.dds",
        [42] = "%s/%s/nav_%s_lbdpadleft.dds",
        [43] = "%s/%s/nav_%s_lbrb.dds",
        [44] = "%s/%s/nav_%s_lbrs_press.dds",
        [45] = "%s/%s/nav_%s_lbrs_right.dds",
        [46] = "%s/%s/nav_%s_lbrt.dds",
        [47] = "%s/%s/nav_%s_lbx.dds",
        [48] = "%s/%s/nav_%s_lby.dds",
        [49] = "%s/%s/nav_%s_left_shoulder_hold.dds",
        [50] = "%s/%s/nav_%s_left_shoulder_hold_en.dds",
        [51] = "%s/%s/nav_%s_left_shoulder_hold_greyedout_en.dds",
        [52] = "%s/%s/nav_%s_left_trigger_hold.dds",
        [53] = "%s/%s/nav_%s_left_trigger_hold_en.dds",
        [54] = "%s/%s/nav_%s_left_trigger_hold_greyedout_en.dds",
        [55] = "%s/%s/nav_%s_leftarrow_down_hold.dds",
        [56] = "%s/%s/nav_%s_leftarrowrightarrow.dds",
        [57] = "%s/%s/nav_%s_ls.dds",
        [58] = "%s/%s/nav_%s_ls_click.dds",
        [59] = "%s/%s/nav_%s_ls_down.dds",
        [60] = "%s/%s/nav_%s_ls_hold.dds",
        [61] = "%s/%s/nav_%s_ls_hold_en.dds",
        [62] = "%s/%s/nav_%s_ls_left.dds",
        [63] = "%s/%s/nav_%s_ls_press.dds",
        [64] = "%s/%s/nav_%s_ls_right.dds",
        [65] = "%s/%s/nav_%s_ls_scroll.dds",
        [66] = "%s/%s/nav_%s_ls_slide.dds",
        [67] = "%s/%s/nav_%s_ls_slide_scroll.dds",
        [68] = "%s/%s/nav_%s_ls_up.dds",
        [69] = "%s/%s/nav_%s_lsrs.dds",
        [70] = "%s/%s/nav_%s_lsrs_click.dds",
        [71] = "%s/%s/nav_%s_lsrs_press.dds",
        [72] = "%s/%s/nav_%s_lt.dds",
        [73] = "%s/%s/nav_%s_lt_dim.dds",
        [74] = "%s/%s/nav_%s_lt_hold.dds",
        [75] = "%s/%s/nav_%s_lta.dds",
        [76] = "%s/%s/nav_%s_ltb.dds",
        [77] = "%s/%s/nav_%s_ltrt.dds",
        [78] = "%s/%s/nav_%s_ltx.dds",
        [79] = "%s/%s/nav_%s_lty.dds",
        [80] = "%s/%s/nav_%s_menu_button_hold.dds",
        [81] = "%s/%s/nav_%s_menu_button_hold_en.dds",
        [82] = "%s/%s/nav_%s_menu_button_hold_greyedout_en.dds",
        [83] = "%s/%s/nav_%s_rb.dds",
        [84] = "%s/%s/nav_%s_rb_hold.dds",
        [85] = "%s/%s/nav_%s_rba.dds",
        [86] = "%s/%s/nav_%s_rbb.dds",
        [87] = "%s/%s/nav_%s_rbx.dds",
        [88] = "%s/%s/nav_%s_rby.dds",
        [89] = "%s/%s/nav_%s_right_shoulder_hold.dds",
        [90] = "%s/%s/nav_%s_right_shoulder_hold_en.dds",
        [91] = "%s/%s/nav_%s_right_shoulder_hold_greyedout_en.dds",
        [92] = "%s/%s/nav_%s_right_trigger_hold.dds",
        [93] = "%s/%s/nav_%s_right_trigger_hold_en.dds",
        [94] = "%s/%s/nav_%s_right_trigger_hold_greyedout_en.dds",
        [95] = "%s/%s/nav_%s_rightarrow_down_hold.dds",
        [96] = "%s/%s/nav_%s_rs.dds",
        [97] = "%s/%s/nav_%s_rs_click.dds",
        [98] = "%s/%s/nav_%s_rs_down.dds",
        [99] = "%s/%s/nav_%s_rs_hold.dds",
        [100] = "%s/%s/nav_%s_rs_hold_en.dds",
        [101] = "%s/%s/nav_%s_rs_left.dds",
        [102] = "%s/%s/nav_%s_rs_menu.dds",
        [103] = "%s/%s/nav_%s_rs_press.dds",
        [104] = "%s/%s/nav_%s_rs_right.dds",
        [105] = "%s/%s/nav_%s_rs_scroll.dds",
        [106] = "%s/%s/nav_%s_rs_slide.dds",
        [107] = "%s/%s/nav_%s_rs_slide_scroll.dds",
        [108] = "%s/%s/nav_%s_rs_up.dds",
        [109] = "%s/%s/nav_%s_rt.dds",
        [110] = "%s/%s/nav_%s_rt_dim.dds",
        [111] = "%s/%s/nav_%s_rt_hold.dds",
        [112] = "%s/%s/nav_%s_view.dds",
        [113] = "%s/%s/nav_%s_view_button_hold.dds",
        [114] = "%s/%s/nav_%s_view_button_hold_en.dds",
        [115] = "%s/%s/nav_%s_view_button_hold_greyedout_en.dds",
        [116] = "%s/%s/nav_%s_x.dds",
        [117] = "%s/%s/nav_%s_x_hold.dds",
        [118] = "%s/%s/nav_%s_x_hold_en.dds",
        [119] = "%s/%s/nav_%s_x_hold_greyedout_en.dds",
        [120] = "%s/%s/nav_%s_y.dds",
        [121] = "%s/%s/nav_%s_y_hold.dds",
        [122] = "%s/%s/nav_%s_y_hold_en.dds",
        [123] = "%s/%s/nav_%s_y_hold_greyedout_en.dds",
        [124] = "%s/%s/nav_%s_yb.dds",
        [125] = "%s/%s/rightarrow_down.dds",
    },
}

local function getGamepadButtonTextureName(patternStr, gamepadType)
    if patternStr ~= nil and patternStr ~= "" and gamepadType ~= nil then
        local gpTP = gamepadTextureParts[gamepadType]
        if gpTP ~= nil then
            local retStr = strformat(patternStr, prefixGamepadButtonsPath, gpTP.folder, gpTP.file, gpTP.language)
            if retStr ~= nil and retStr ~= "" then
                return retStr
            end
        end
    end
    return ""
end

local startUp = false
function fcogpbt.RedirectGamepadTextures(lastChosenGamepadButtonTexturesNr, chosenGamepadButtonTexturesNr)
d(strformat("[FCOGPBT]redirectGamepadTextures-lastChosenGamepadButtonTexturesNr: %s, chosenGamepadButtonTexturesNr: %s", tos(lastChosenGamepadButtonTexturesNr), tos(chosenGamepadButtonTexturesNr)))
    local settings = fcogpbt.settingsVars.settings
    lastChosenGamepadButtonTexturesNr = lastChosenGamepadButtonTexturesNr or settings.lastChosenGamepadButtonTextures
    chosenGamepadButtonTexturesNr = chosenGamepadButtonTexturesNr or settings.chosenGamepadButtonTextures

    local lastGamepadTextureType = buttonTexturesPossibilities[lastChosenGamepadButtonTexturesNr]
    local newGamepadTextureType = buttonTexturesPossibilities[chosenGamepadButtonTexturesNr]
    --Last and current are the same? Do nothing
    if lastGamepadTextureType ~= nil and newGamepadTextureType ~= nil and lastGamepadTextureType == newGamepadTextureType then
        if not startUp then
            local alertText = "[FCOGamepadButtonTextures]Currently chosen gamepad type already was \'" .. tos(newGamepadTextureType) .. "\'.\n|c3333FFIf textures are not shown properly, exit the game, delete the file|r \'/live/shader_cache.cooked\'!"
            d(alertText)
            local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.DUEL_START)
            params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT )
            params:SetText(alertText)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
            PlaySound(SOUNDS.DUEL_START)
        end
        return
    end

    local lastGamepadTextures = gamepadTexturesPatterns[lastGamepadTextureType]
    if lastGamepadTextures == nil then return end

    local newGamepadTextures =  gamepadTexturesPatterns[newGamepadTextureType]
    if newGamepadTextures == nil then return end
d(strformat(">lastGPType: %s, newGPType: %s", tos(lastGamepadTextureType), tos(newGamepadTextureType)))

    local changedTextureCount = 0
    for idx, lastGamePadTexturePattern in ipairs(lastGamepadTextures) do
        local newGamePadTexturePattern = newGamepadTextures[idx]
        if newGamePadTexturePattern ~= nil and newGamePadTexturePattern ~= "" then
            local oldGamepadButtonTextureName = getGamepadButtonTextureName(lastGamePadTexturePattern, lastGamepadTextureType)
            local newGamepadButtonTextureName = getGamepadButtonTextureName(newGamePadTexturePattern, newGamepadTextureType)
--d(strformat(">>idx: %s, oldPattern: %s, newPattern: %s, oldName: %s, newName: %s",
           --tos(idx), tos(lastGamePadTexturePattern), tos(newGamePadTexturePattern),
           --tos(oldGamepadButtonTextureName), tos(newGamepadButtonTextureName)))
            if oldGamepadButtonTextureName ~= nil and oldGamepadButtonTextureName ~= "" and newGamepadButtonTextureName ~= nil and newGamepadButtonTextureName ~= "" then
                changedTextureCount = changedTextureCount + 1
                RedirectTexture(oldGamepadButtonTextureName, newGamepadButtonTextureName)
            end
        end
    end
    if changedTextureCount > 0 then
        if not startUp then
            local alertText = strformat("[FCOGamepadButtonTextures]%s Gamepad textures changed to \'%s\'.\n|cFF0000Exit the game, and delete the file|r \'/live/shader_cache.cooked\'!", tos(changedTextureCount), tos(newGamepadTextureType))
            d(alertText)
            local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.DUEL_BOUNDARY_WARNING)
            params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT )
            params:SetText(alertText)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
            PlaySound(SOUNDS.DUEL_BOUNDARY_WARNING)
        else
            d(strformat("[FCOGamepadButtonTextures]%s Gamepad textures loaded for \'%s\'",  tos(changedTextureCount), tos(newGamepadTextureType)))
        end
    end
end
local redirectGamepadTextures = fcogpbt.RedirectGamepadTextures


local function applyChosenGamepadButtonTextures()
    local settings = fcogpbt.settingsVars.settings
    local choseGamepadType = settings.chosenGamepadButtonTextures
    --Not using PC's xbone default gamepad buttons?
    startUp = true
    redirectGamepadTextures(nil, choseGamepadType)
    startUp = false
end

local function loadSettings()
    local settingsVars = fcogpbt.settingsVars
    local svName = settingsVars.svName
    local svVersion = settingsVars.svVersion
    local worldName = GetWorldName()

    --=============================================================================================================
    --	LOAD USER SETTINGS
    --=============================================================================================================
    --Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
    settingsVars.settingsForAll = ZO_SavedVars:NewAccountWide(svName, 999, "SettingsForAll", defaultSVForAll, worldName, nil)
    --Character settings
    if (settingsVars.settingsForAll.saveMode == 1) then
        settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(svName, svVersion , "Settings", defaultSV, worldName)
    --Account wide settings
    elseif (settingsVars.settingsForAll.saveMode == 2) then
        settingsVars.settings = ZO_SavedVars:NewAccountWide(svName, svVersion, "Settings", defaultSV, worldName, nil)
    end
end

local function changeSavedVariablesLastAndChosenGamepadType(newChosenGamepadType)
    local settings = fcogpbt.settingsVars.settings
    local lastChosenGamepadButtonTextures =  settings.chosenGamepadButtonTextures
    settings.lastChosenGamepadButtonTextures = lastChosenGamepadButtonTextures
    settings.chosenGamepadButtonTextures = newChosenGamepadType
end

local function createSlashCommands()
    SLASH_COMMANDS["/fcogpbt_xbone"] = function()
        changeSavedVariablesLastAndChosenGamepadType(1)
        redirectGamepadTextures(nil, 1)
    end
    SLASH_COMMANDS["/fcogpbt_ps4"] = function()
        changeSavedVariablesLastAndChosenGamepadType(2)
        redirectGamepadTextures(nil, 2)
    end
    SLASH_COMMANDS["/fcogpbt_ps5"] = function()
        changeSavedVariablesLastAndChosenGamepadType(3)
        redirectGamepadTextures(nil, 3)
    end
	SLASH_COMMANDS["/fcogpbt_xbsx"] = function()
        changeSavedVariablesLastAndChosenGamepadType(4)
        redirectGamepadTextures(nil, 4)
    end
end

local function onAddOnLoaded(event, allOtherAddonName)
    if allOtherAddonName ~= addonName then return end
    EM:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

    loadSettings()
    applyChosenGamepadButtonTextures()
    createSlashCommands()
end

EM:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, onAddOnLoaded)
