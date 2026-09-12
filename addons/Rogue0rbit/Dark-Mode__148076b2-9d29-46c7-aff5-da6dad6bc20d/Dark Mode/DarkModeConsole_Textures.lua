DarkModeConsole = DarkModeConsole or {}
local DMC = DarkModeConsole

DMC.ROLE_BORDER = 1
DMC.ROLE_BACKGROUND = 2

local BORDER = DMC.ROLE_BORDER
local BACKGROUND = DMC.ROLE_BACKGROUND

DMC.TEXTURE_ROLES =
{
    ["esoui/art/compass/gamepad/gp_compass.dds"] = BORDER,

    ["esoui/art/actionbar/gamepad/gp_abilityframe64.dds"] = BORDER,
    ["esoui/art/actionbar/gamepad/gp_abilityframe_buff.dds"] = BORDER,
    ["esoui/art/actionbar/gamepad/gp_backrow_abilityframe.dds"] = BORDER,
    ["esoui/art/actionbar/gamepad/gp_backrow_abilityframe_blank.dds"] = BACKGROUND,
    ["esoui/art/miscellaneous/gamepad/gp_tooltip_edge_semitrans_16.dds"] = BORDER,
    ["esoui/art/miscellaneous/gamepad/gp_tooltip_center_semitrans_16.dds"] = BACKGROUND,
    ["esoui/art/hud/gamepad/gp_ultimateframe_edge.dds"] = BORDER,

    ["esoui/art/unitattributevisualizer/gamepad/gp_attributebar_dynamic_frame.dds"] = BORDER,
    ["esoui/art/unitattributevisualizer/gamepad/gp_attributebar_dynamic_bg.dds"] = BACKGROUND,
    ["esoui/art/unitattributevisualizer/gamepad/gp_attributebar_small_frame.dds"] = BORDER,
    ["esoui/art/unitattributevisualizer/gamepad/gp_attributebar_small_frame_center.dds"] = BORDER,
    ["esoui/art/unitattributevisualizer/gamepad/gp_targetbar_dynamic_frame.dds"] = BORDER,
    ["esoui/art/unitattributevisualizer/gamepad/gp_targetbar_dynamic_bg.dds"] = BACKGROUND,
    ["esoui/art/miscellaneous/gamepad/gp_dynamicbar_medium_frame.dds"] = BORDER,
    ["esoui/art/miscellaneous/gamepad/gp_dynamicbar_medium_bg.dds"] = BACKGROUND,
    ["esoui/art/miscellaneous/gamepad/gp_dynamicbar_large_frame.dds"] = BORDER,
    ["esoui/art/miscellaneous/gamepad/gp_dynamicbar_large_bg.dds"] = BACKGROUND,
    ["esoui/art/miscellaneous/gamepad/gp_dynamicbar_extralarge_frame.dds"] = BORDER,
    ["esoui/art/miscellaneous/gamepad/gp_dynamicbar_extralarge_frame_bg.dds"] = BACKGROUND,
    ["esoui/art/bossbar/gamepad/gp_bossbar_bracket.dds"] = BORDER,
    ["esoui/art/hud/gamepad/loothistorybg.dds"] = BACKGROUND,

    ["esoui/art/hud/gamepad/gp_telvar_meter_frame.dds"] = BORDER,
    ["esoui/art/hud/gamepad/gp_infamy_meter-frame-generic.dds"] = BORDER,
    ["esoui/art/hud/gamepad/gp_daedrichunger_meter_frame.dds"] = BORDER,
    ["esoui/art/windows/gamepad/gp_hud_window.dds"] = BACKGROUND,

    ["esoui/art/chatwindow/gamepad/gp_hud_chatwindowbg_edge.dds"] = BORDER,
    ["esoui/art/chatwindow/gamepad/gp_hud_chatwindowbg_center.dds"] = BACKGROUND,

    ["esoui/art/windows/gamepad/gp_fullvertdiv.dds"] = BORDER,
    ["esoui/art/windows/gamepad/gp_windowpointer.dds"] = BORDER,
    ["esoui/art/windows/gamepad/panelbg_focus_512.dds"] = BACKGROUND,
    ["esoui/art/windows/gamepad/panelbg_nofocus_512.dds"] = BACKGROUND,

    ["esoui/art/windows/gamepad/gp_nav1_hordivider.dds"] = BORDER,
    ["esoui/art/windows/gamepad/gp_nav1_hordividerflat.dds"] = BORDER,

    ["esoui/art/tooltips/gamepad/gp_tooltip_edge_16.dds"] = BORDER,
    ["esoui/art/tooltips/gamepad/gp_tooltip_edge_grey_16.dds"] = BORDER,
    ["esoui/art/tooltips/gamepad/gp_tooltip_center_16.dds"] = BACKGROUND,
    ["esoui/art/miscellaneous/gamepad/gp_emptyframe_gold_edge.dds"] = BORDER,

    ["esoui/art/miscellaneous/gamepad/gp_passiveframe_44.dds"] = BORDER,
    ["esoui/art/miscellaneous/gamepad/gp_passiveframe_64.dds"] = BORDER,
    ["esoui/art/skillsadvisor/gamepad/gp_passivedoubleframe_64.dds"] = BORDER,
    ["esoui/art/crafting/gamepad/gp_smithing_temperchart_frame.dds"] = BORDER,

    ["esoui/art/antiquities/gamepad/gp_digging_1bar_border.dds"] = BORDER,
    ["esoui/art/antiquities/gamepad/gp_digging_2bar_border.dds"] = BORDER,
    ["esoui/art/antiquities/gamepad/gp_digging_1icon_border.dds"] = BORDER,
    ["esoui/art/antiquities/gamepad/gp_digging_2icon_border.dds"] = BORDER,
    ["esoui/art/antiquities/gamepad/gp_digging_1bar_border_bg.dds"] = BACKGROUND,
    ["esoui/art/antiquities/gamepad/gp_digging_2bar_border_bg.dds"] = BACKGROUND,
}
