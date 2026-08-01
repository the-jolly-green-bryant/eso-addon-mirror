-- textures are stored in Game.mnf, you can use ESO Extract to get them

local Set = function(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

local label_updates = 0

ButtonsManager = {
    name = "CustomGamepadButtons",

    Defaults = {
        current_platform = "xbox",
    },

    valid_texture_names = {
        xbox = Set{ "console_art_xb1", "leftarrow_down", "nav_xbone_a_hold_de", "nav_xbone_a_hold_en", "nav_xbone_a_hold_es", "nav_xbone_a_hold_fr", "nav_xbone_a_hold_greyedout_de", "nav_xbone_a_hold_greyedout_en", "nav_xbone_a_hold_greyedout_es", "nav_xbone_a_hold_greyedout_fr", "nav_xbone_a_hold_greyedout_jp", "nav_xbone_a_hold_greyedout_ru", "nav_xbone_a_hold_greyedout_zh", "nav_xbone_a_hold_jp", "nav_xbone_a_hold_ru", "nav_xbone_a_hold_zh", "nav_xbone_a_hold", "nav_xbone_a", "nav_xbone_b_hold_de", "nav_xbone_b_hold_en", "nav_xbone_b_hold_es", "nav_xbone_b_hold_fr", "nav_xbone_b_hold_greyedout_de", "nav_xbone_b_hold_greyedout_en", "nav_xbone_b_hold_greyedout_es", "nav_xbone_b_hold_greyedout_fr", "nav_xbone_b_hold_greyedout_jp", "nav_xbone_b_hold_greyedout_ru", "nav_xbone_b_hold_greyedout_zh", "nav_xbone_b_hold_jp", "nav_xbone_b_hold_ru", "nav_xbone_b_hold_zh", "nav_xbone_b_hold", "nav_xbone_b", "nav_xbone_dpad_down_hold_de", "nav_xbone_dpad_down_hold_en", "nav_xbone_dpad_down_hold_es", "nav_xbone_dpad_down_hold_fr", "nav_xbone_dpad_down_hold_greyedout_de", "nav_xbone_dpad_down_hold_greyedout_en", "nav_xbone_dpad_down_hold_greyedout_es", "nav_xbone_dpad_down_hold_greyedout_fr", "nav_xbone_dpad_down_hold_greyedout_jp", "nav_xbone_dpad_down_hold_greyedout_ru", "nav_xbone_dpad_down_hold_greyedout_zh", "nav_xbone_dpad_down_hold_jp", "nav_xbone_dpad_down_hold_ru", "nav_xbone_dpad_down_hold_zh", "nav_xbone_dpad_down_hold", "nav_xbone_dpad_left_hold_de", "nav_xbone_dpad_left_hold_en", "nav_xbone_dpad_left_hold_es", "nav_xbone_dpad_left_hold_fr", "nav_xbone_dpad_left_hold_greyedout_de", "nav_xbone_dpad_left_hold_greyedout_en", "nav_xbone_dpad_left_hold_greyedout_es", "nav_xbone_dpad_left_hold_greyedout_fr", "nav_xbone_dpad_left_hold_greyedout_jp", "nav_xbone_dpad_left_hold_greyedout_ru", "nav_xbone_dpad_left_hold_greyedout_zh", "nav_xbone_dpad_left_hold_jp", "nav_xbone_dpad_left_hold_ru", "nav_xbone_dpad_left_hold_zh", "nav_xbone_dpad_left_hold", "nav_xbone_dpad_right_hold_de", "nav_xbone_dpad_right_hold_en", "nav_xbone_dpad_right_hold_es", "nav_xbone_dpad_right_hold_fr", "nav_xbone_dpad_right_hold_greyedout_de", "nav_xbone_dpad_right_hold_greyedout_en", "nav_xbone_dpad_right_hold_greyedout_es", "nav_xbone_dpad_right_hold_greyedout_fr", "nav_xbone_dpad_right_hold_greyedout_jp", "nav_xbone_dpad_right_hold_greyedout_ru", "nav_xbone_dpad_right_hold_greyedout_zh", "nav_xbone_dpad_right_hold_jp", "nav_xbone_dpad_right_hold_ru", "nav_xbone_dpad_right_hold_zh", "nav_xbone_dpad_right_hold", "nav_xbone_dpad_up_hold_de", "nav_xbone_dpad_up_hold_en", "nav_xbone_dpad_up_hold_es", "nav_xbone_dpad_up_hold_fr", "nav_xbone_dpad_up_hold_greyedout_de", "nav_xbone_dpad_up_hold_greyedout_en", "nav_xbone_dpad_up_hold_greyedout_es", "nav_xbone_dpad_up_hold_greyedout_fr", "nav_xbone_dpad_up_hold_greyedout_jp", "nav_xbone_dpad_up_hold_greyedout_ru", "nav_xbone_dpad_up_hold_greyedout_zh", "nav_xbone_dpad_up_hold_jp", "nav_xbone_dpad_up_hold_ru", "nav_xbone_dpad_up_hold_zh", "nav_xbone_dpad_up_hold", "nav_xbone_dpad", "nav_xbone_dpaddown_hold_rs", "nav_xbone_dpaddown", "nav_xbone_dpadleft", "nav_xbone_dpadright", "nav_xbone_dpadrightb", "nav_xbone_dpadup", "nav_xbone_du", "nav_xbone_hold_lt_press_rt_de", "nav_xbone_hold_lt_press_rt_en", "nav_xbone_hold_lt_press_rt_es", "nav_xbone_hold_lt_press_rt_fr", "nav_xbone_hold_lt_press_rt_jp", "nav_xbone_hold_lt_press_rt_ru", "nav_xbone_hold_lt_press_rt_zh", "nav_xbone_hold_lt_press_rt", "nav_xbone_lb", "nav_xbone_lba", "nav_xbone_lbb", "nav_xbone_lbdpaddown", "nav_xbone_lbdpadleft", "nav_xbone_lbrb", "nav_xbone_lbrs_press", "nav_xbone_lbrs_right", "nav_xbone_lbrt", "nav_xbone_lbx", "nav_xbone_lby", "nav_xbone_left_shoulder_hold_de", "nav_xbone_left_shoulder_hold_en", "nav_xbone_left_shoulder_hold_es", "nav_xbone_left_shoulder_hold_fr", "nav_xbone_left_shoulder_hold_greyedout_de", "nav_xbone_left_shoulder_hold_greyedout_en", "nav_xbone_left_shoulder_hold_greyedout_es", "nav_xbone_left_shoulder_hold_greyedout_fr", "nav_xbone_left_shoulder_hold_greyedout_jp", "nav_xbone_left_shoulder_hold_greyedout_ru", "nav_xbone_left_shoulder_hold_greyedout_zh", "nav_xbone_left_shoulder_hold_jp", "nav_xbone_left_shoulder_hold_ru", "nav_xbone_left_shoulder_hold_zh", "nav_xbone_left_shoulder_hold", "nav_xbone_left_trigger_hold_de", "nav_xbone_left_trigger_hold_en", "nav_xbone_left_trigger_hold_es", "nav_xbone_left_trigger_hold_fr", "nav_xbone_left_trigger_hold_greyedout_de", "nav_xbone_left_trigger_hold_greyedout_en", "nav_xbone_left_trigger_hold_greyedout_es", "nav_xbone_left_trigger_hold_greyedout_fr", "nav_xbone_left_trigger_hold_greyedout_jp", "nav_xbone_left_trigger_hold_greyedout_ru", "nav_xbone_left_trigger_hold_greyedout_zh", "nav_xbone_left_trigger_hold_jp", "nav_xbone_left_trigger_hold_ru", "nav_xbone_left_trigger_hold_zh", "nav_xbone_left_trigger_hold", "nav_xbone_leftarrowrightarrow", "nav_xbone_ls_click", "nav_xbone_ls_down", "nav_xbone_ls_hold_de", "nav_xbone_ls_hold_en", "nav_xbone_ls_hold_es", "nav_xbone_ls_hold_fr", "nav_xbone_ls_hold_greyedout_de", "nav_xbone_ls_hold_greyedout_en", "nav_xbone_ls_hold_greyedout_es", "nav_xbone_ls_hold_greyedout_fr", "nav_xbone_ls_hold_greyedout_jp", "nav_xbone_ls_hold_greyedout_ru", "nav_xbone_ls_hold_greyedout_zh", "nav_xbone_ls_hold_jp", "nav_xbone_ls_hold_ru", "nav_xbone_ls_hold_zh", "nav_xbone_ls_hold", "nav_xbone_ls_left", "nav_xbone_ls_press", "nav_xbone_ls_right", "nav_xbone_ls_scroll", "nav_xbone_ls_slide_scroll", "nav_xbone_ls_slide", "nav_xbone_ls_up", "nav_xbone_ls", "nav_xbone_lsrs_click", "nav_xbone_lsrs_press", "nav_xbone_lsrs", "nav_xbone_lt_dim", "nav_xbone_lt", "nav_xbone_lta", "nav_xbone_ltb", "nav_xbone_ltrt", "nav_xbone_ltx", "nav_xbone_lty", "nav_xbone_menu_button_hold_de", "nav_xbone_menu_button_hold_en", "nav_xbone_menu_button_hold_es", "nav_xbone_menu_button_hold_fr", "nav_xbone_menu_button_hold_greyedout_de", "nav_xbone_menu_button_hold_greyedout_en", "nav_xbone_menu_button_hold_greyedout_es", "nav_xbone_menu_button_hold_greyedout_fr", "nav_xbone_menu_button_hold_greyedout_jp", "nav_xbone_menu_button_hold_greyedout_ru", "nav_xbone_menu_button_hold_greyedout_zh", "nav_xbone_menu_button_hold_jp", "nav_xbone_menu_button_hold_ru", "nav_xbone_menu_button_hold_zh", "nav_xbone_menu_button_hold", "nav_xbone_rb", "nav_xbone_rba", "nav_xbone_rbb", "nav_xbone_rbx", "nav_xbone_rby", "nav_xbone_right_shoulder_hold_de", "nav_xbone_right_shoulder_hold_en", "nav_xbone_right_shoulder_hold_es", "nav_xbone_right_shoulder_hold_fr", "nav_xbone_right_shoulder_hold_greyedout_de", "nav_xbone_right_shoulder_hold_greyedout_en", "nav_xbone_right_shoulder_hold_greyedout_es", "nav_xbone_right_shoulder_hold_greyedout_fr", "nav_xbone_right_shoulder_hold_greyedout_jp", "nav_xbone_right_shoulder_hold_greyedout_ru", "nav_xbone_right_shoulder_hold_greyedout_zh", "nav_xbone_right_shoulder_hold_jp", "nav_xbone_right_shoulder_hold_ru", "nav_xbone_right_shoulder_hold_zh", "nav_xbone_right_shoulder_hold", "nav_xbone_right_trigger_hold_de", "nav_xbone_right_trigger_hold_en", "nav_xbone_right_trigger_hold_es", "nav_xbone_right_trigger_hold_fr", "nav_xbone_right_trigger_hold_greyedout_de", "nav_xbone_right_trigger_hold_greyedout_en", "nav_xbone_right_trigger_hold_greyedout_es", "nav_xbone_right_trigger_hold_greyedout_fr", "nav_xbone_right_trigger_hold_greyedout_jp", "nav_xbone_right_trigger_hold_greyedout_ru", "nav_xbone_right_trigger_hold_greyedout_zh", "nav_xbone_right_trigger_hold_jp", "nav_xbone_right_trigger_hold_ru", "nav_xbone_right_trigger_hold_zh", "nav_xbone_right_trigger_hold", "nav_xbone_rs_click", "nav_xbone_rs_down", "nav_xbone_rs_hold_de", "nav_xbone_rs_hold_en", "nav_xbone_rs_hold_es", "nav_xbone_rs_hold_fr", "nav_xbone_rs_hold_greyedout_de", "nav_xbone_rs_hold_greyedout_en", "nav_xbone_rs_hold_greyedout_es", "nav_xbone_rs_hold_greyedout_fr", "nav_xbone_rs_hold_greyedout_jp", "nav_xbone_rs_hold_greyedout_ru", "nav_xbone_rs_hold_greyedout_zh", "nav_xbone_rs_hold_jp", "nav_xbone_rs_hold_ru", "nav_xbone_rs_hold_zh", "nav_xbone_rs_hold", "nav_xbone_rs_left", "nav_xbone_rs_menu", "nav_xbone_rs_press", "nav_xbone_rs_right", "nav_xbone_rs_scroll", "nav_xbone_rs_slide_scroll", "nav_xbone_rs_slide", "nav_xbone_rs_up", "nav_xbone_rs", "nav_xbone_rt_dim", "nav_xbone_rt", "nav_xbone_view_button_hold_de", "nav_xbone_view_button_hold_en", "nav_xbone_view_button_hold_es", "nav_xbone_view_button_hold_fr", "nav_xbone_view_button_hold_greyedout_de", "nav_xbone_view_button_hold_greyedout_en", "nav_xbone_view_button_hold_greyedout_es", "nav_xbone_view_button_hold_greyedout_fr", "nav_xbone_view_button_hold_greyedout_jp", "nav_xbone_view_button_hold_greyedout_ru", "nav_xbone_view_button_hold_greyedout_zh", "nav_xbone_view_button_hold_jp", "nav_xbone_view_button_hold_ru", "nav_xbone_view_button_hold_zh", "nav_xbone_view_button_hold", "nav_xbone_view", "nav_xbone_x_hold_de", "nav_xbone_x_hold_en", "nav_xbone_x_hold_es", "nav_xbone_x_hold_fr", "nav_xbone_x_hold_greyedout_de", "nav_xbone_x_hold_greyedout_en", "nav_xbone_x_hold_greyedout_es", "nav_xbone_x_hold_greyedout_fr", "nav_xbone_x_hold_greyedout_jp", "nav_xbone_x_hold_greyedout_ru", "nav_xbone_x_hold_greyedout_zh", "nav_xbone_x_hold_jp", "nav_xbone_x_hold_ru", "nav_xbone_x_hold_zh", "nav_xbone_x_hold", "nav_xbone_x", "nav_xbone_y_hold_de", "nav_xbone_y_hold_en", "nav_xbone_y_hold_es", "nav_xbone_y_hold_fr", "nav_xbone_y_hold_greyedout_de", "nav_xbone_y_hold_greyedout_en", "nav_xbone_y_hold_greyedout_es", "nav_xbone_y_hold_greyedout_fr", "nav_xbone_y_hold_greyedout_jp", "nav_xbone_y_hold_greyedout_ru", "nav_xbone_y_hold_greyedout_zh", "nav_xbone_y_hold_jp", "nav_xbone_y_hold_ru", "nav_xbone_y_hold_zh", "nav_xbone_y_hold", "nav_xbone_y", "nav_xbone_yb", "rightarrow_down", },
        scarlett = Set{ "console_art_scarlett", "leftarrow_down", "nav_scarlett_a_hold_de", "nav_scarlett_a_hold_en", "nav_scarlett_a_hold_es", "nav_scarlett_a_hold_fr", "nav_scarlett_a_hold_greyedout_de", "nav_scarlett_a_hold_greyedout_en", "nav_scarlett_a_hold_greyedout_es", "nav_scarlett_a_hold_greyedout_fr", "nav_scarlett_a_hold_greyedout_jp", "nav_scarlett_a_hold_greyedout_ru", "nav_scarlett_a_hold_greyedout_zh", "nav_scarlett_a_hold_jp", "nav_scarlett_a_hold_ru", "nav_scarlett_a_hold_zh", "nav_scarlett_a_hold", "nav_scarlett_a", "nav_scarlett_b_hold_de", "nav_scarlett_b_hold_en", "nav_scarlett_b_hold_es", "nav_scarlett_b_hold_fr", "nav_scarlett_b_hold_greyedout_de", "nav_scarlett_b_hold_greyedout_en", "nav_scarlett_b_hold_greyedout_es", "nav_scarlett_b_hold_greyedout_fr", "nav_scarlett_b_hold_greyedout_jp", "nav_scarlett_b_hold_greyedout_ru", "nav_scarlett_b_hold_greyedout_zh", "nav_scarlett_b_hold_jp", "nav_scarlett_b_hold_ru", "nav_scarlett_b_hold_zh", "nav_scarlett_b_hold", "nav_scarlett_b", "nav_scarlett_dpad_down_hold_de", "nav_scarlett_dpad_down_hold_en", "nav_scarlett_dpad_down_hold_es", "nav_scarlett_dpad_down_hold_fr", "nav_scarlett_dpad_down_hold_greyedout_de", "nav_scarlett_dpad_down_hold_greyedout_en", "nav_scarlett_dpad_down_hold_greyedout_es", "nav_scarlett_dpad_down_hold_greyedout_fr", "nav_scarlett_dpad_down_hold_greyedout_jp", "nav_scarlett_dpad_down_hold_greyedout_ru", "nav_scarlett_dpad_down_hold_greyedout_zh", "nav_scarlett_dpad_down_hold_jp", "nav_scarlett_dpad_down_hold_ru", "nav_scarlett_dpad_down_hold_zh", "nav_scarlett_dpad_down_hold", "nav_scarlett_dpad_left_hold_de", "nav_scarlett_dpad_left_hold_en", "nav_scarlett_dpad_left_hold_es", "nav_scarlett_dpad_left_hold_fr", "nav_scarlett_dpad_left_hold_greyedout_de", "nav_scarlett_dpad_left_hold_greyedout_en", "nav_scarlett_dpad_left_hold_greyedout_es", "nav_scarlett_dpad_left_hold_greyedout_fr", "nav_scarlett_dpad_left_hold_greyedout_jp", "nav_scarlett_dpad_left_hold_greyedout_ru", "nav_scarlett_dpad_left_hold_greyedout_zh", "nav_scarlett_dpad_left_hold_jp", "nav_scarlett_dpad_left_hold_ru", "nav_scarlett_dpad_left_hold_zh", "nav_scarlett_dpad_left_hold", "nav_scarlett_dpad_right_hold_de", "nav_scarlett_dpad_right_hold_en", "nav_scarlett_dpad_right_hold_es", "nav_scarlett_dpad_right_hold_fr", "nav_scarlett_dpad_right_hold_greyedout_de", "nav_scarlett_dpad_right_hold_greyedout_en", "nav_scarlett_dpad_right_hold_greyedout_es", "nav_scarlett_dpad_right_hold_greyedout_fr", "nav_scarlett_dpad_right_hold_greyedout_jp", "nav_scarlett_dpad_right_hold_greyedout_ru", "nav_scarlett_dpad_right_hold_greyedout_zh", "nav_scarlett_dpad_right_hold_jp", "nav_scarlett_dpad_right_hold_ru", "nav_scarlett_dpad_right_hold_zh", "nav_scarlett_dpad_right_hold", "nav_scarlett_dpad_up_hold_de", "nav_scarlett_dpad_up_hold_en", "nav_scarlett_dpad_up_hold_es", "nav_scarlett_dpad_up_hold_fr", "nav_scarlett_dpad_up_hold_greyedout_de", "nav_scarlett_dpad_up_hold_greyedout_en", "nav_scarlett_dpad_up_hold_greyedout_es", "nav_scarlett_dpad_up_hold_greyedout_fr", "nav_scarlett_dpad_up_hold_greyedout_jp", "nav_scarlett_dpad_up_hold_greyedout_ru", "nav_scarlett_dpad_up_hold_greyedout_zh", "nav_scarlett_dpad_up_hold_jp", "nav_scarlett_dpad_up_hold_ru", "nav_scarlett_dpad_up_hold_zh", "nav_scarlett_dpad_up_hold", "nav_scarlett_dpad", "nav_scarlett_dpaddown_hold_rs", "nav_scarlett_dpaddown", "nav_scarlett_dpadleft", "nav_scarlett_dpadright", "nav_scarlett_dpadrightb", "nav_scarlett_dpadup", "nav_scarlett_du", "nav_scarlett_hold_lt_press_rt_de", "nav_scarlett_hold_lt_press_rt_en", "nav_scarlett_hold_lt_press_rt_es", "nav_scarlett_hold_lt_press_rt_fr", "nav_scarlett_hold_lt_press_rt_jp", "nav_scarlett_hold_lt_press_rt_ru", "nav_scarlett_hold_lt_press_rt_zh", "nav_scarlett_hold_lt_press_rt", "nav_scarlett_home", "nav_scarlett_lb", "nav_scarlett_lba", "nav_scarlett_lbb", "nav_scarlett_lbdpaddown", "nav_scarlett_lbdpadleft", "nav_scarlett_lbrb", "nav_scarlett_lbrs_press", "nav_scarlett_lbrs_right", "nav_scarlett_lbrt", "nav_scarlett_lbx", "nav_scarlett_lby", "nav_scarlett_left_shoulder_hold_de", "nav_scarlett_left_shoulder_hold_en", "nav_scarlett_left_shoulder_hold_es", "nav_scarlett_left_shoulder_hold_fr", "nav_scarlett_left_shoulder_hold_greyedout_de", "nav_scarlett_left_shoulder_hold_greyedout_en", "nav_scarlett_left_shoulder_hold_greyedout_es", "nav_scarlett_left_shoulder_hold_greyedout_fr", "nav_scarlett_left_shoulder_hold_greyedout_jp", "nav_scarlett_left_shoulder_hold_greyedout_ru", "nav_scarlett_left_shoulder_hold_greyedout_zh", "nav_scarlett_left_shoulder_hold_jp", "nav_scarlett_left_shoulder_hold_ru", "nav_scarlett_left_shoulder_hold_zh", "nav_scarlett_left_shoulder_hold", "nav_scarlett_left_trigger_hold_de", "nav_scarlett_left_trigger_hold_en", "nav_scarlett_left_trigger_hold_es", "nav_scarlett_left_trigger_hold_fr", "nav_scarlett_left_trigger_hold_greyedout_de", "nav_scarlett_left_trigger_hold_greyedout_en", "nav_scarlett_left_trigger_hold_greyedout_es", "nav_scarlett_left_trigger_hold_greyedout_fr", "nav_scarlett_left_trigger_hold_greyedout_jp", "nav_scarlett_left_trigger_hold_greyedout_ru", "nav_scarlett_left_trigger_hold_greyedout_zh", "nav_scarlett_left_trigger_hold_jp", "nav_scarlett_left_trigger_hold_ru", "nav_scarlett_left_trigger_hold_zh", "nav_scarlett_left_trigger_hold", "nav_scarlett_leftarrowrightarrow", "nav_scarlett_ls_click", "nav_scarlett_ls_down", "nav_scarlett_ls_hold_de", "nav_scarlett_ls_hold_en", "nav_scarlett_ls_hold_es", "nav_scarlett_ls_hold_fr", "nav_scarlett_ls_hold_greyedout_de", "nav_scarlett_ls_hold_greyedout_en", "nav_scarlett_ls_hold_greyedout_es", "nav_scarlett_ls_hold_greyedout_fr", "nav_scarlett_ls_hold_greyedout_jp", "nav_scarlett_ls_hold_greyedout_ru", "nav_scarlett_ls_hold_greyedout_zh", "nav_scarlett_ls_hold_jp", "nav_scarlett_ls_hold_ru", "nav_scarlett_ls_hold_zh", "nav_scarlett_ls_hold", "nav_scarlett_ls_left", "nav_scarlett_ls_press", "nav_scarlett_ls_right", "nav_scarlett_ls_scroll", "nav_scarlett_ls_slide_scroll", "nav_scarlett_ls_slide", "nav_scarlett_ls_up", "nav_scarlett_ls", "nav_scarlett_lsrs_click", "nav_scarlett_lsrs_press", "nav_scarlett_lsrs", "nav_scarlett_lt_dim", "nav_scarlett_lt", "nav_scarlett_lta", "nav_scarlett_ltb", "nav_scarlett_ltrt", "nav_scarlett_ltx", "nav_scarlett_lty", "nav_scarlett_menu_button_hold_de", "nav_scarlett_menu_button_hold_en", "nav_scarlett_menu_button_hold_es", "nav_scarlett_menu_button_hold_fr", "nav_scarlett_menu_button_hold_greyedout_de", "nav_scarlett_menu_button_hold_greyedout_en", "nav_scarlett_menu_button_hold_greyedout_es", "nav_scarlett_menu_button_hold_greyedout_fr", "nav_scarlett_menu_button_hold_greyedout_jp", "nav_scarlett_menu_button_hold_greyedout_ru", "nav_scarlett_menu_button_hold_greyedout_zh", "nav_scarlett_menu_button_hold_jp", "nav_scarlett_menu_button_hold_ru", "nav_scarlett_menu_button_hold_zh", "nav_scarlett_menu_button_hold", "nav_scarlett_menu", "nav_scarlett_rb", "nav_scarlett_rba", "nav_scarlett_rbb", "nav_scarlett_rbrt", "nav_scarlett_rbx", "nav_scarlett_rby", "nav_scarlett_right_shoulder_hold_de", "nav_scarlett_right_shoulder_hold_en", "nav_scarlett_right_shoulder_hold_es", "nav_scarlett_right_shoulder_hold_fr", "nav_scarlett_right_shoulder_hold_greyedout_de", "nav_scarlett_right_shoulder_hold_greyedout_en", "nav_scarlett_right_shoulder_hold_greyedout_es", "nav_scarlett_right_shoulder_hold_greyedout_fr", "nav_scarlett_right_shoulder_hold_greyedout_jp", "nav_scarlett_right_shoulder_hold_greyedout_ru", "nav_scarlett_right_shoulder_hold_greyedout_zh", "nav_scarlett_right_shoulder_hold_jp", "nav_scarlett_right_shoulder_hold_ru", "nav_scarlett_right_shoulder_hold_zh", "nav_scarlett_right_shoulder_hold", "nav_scarlett_right_trigger_hold_de", "nav_scarlett_right_trigger_hold_en", "nav_scarlett_right_trigger_hold_es_02", "nav_scarlett_right_trigger_hold_es", "nav_scarlett_right_trigger_hold_fr", "nav_scarlett_right_trigger_hold_greyedout_de", "nav_scarlett_right_trigger_hold_greyedout_en", "nav_scarlett_right_trigger_hold_greyedout_es_02", "nav_scarlett_right_trigger_hold_greyedout_es", "nav_scarlett_right_trigger_hold_greyedout_fr", "nav_scarlett_right_trigger_hold_greyedout_jp", "nav_scarlett_right_trigger_hold_greyedout_ru", "nav_scarlett_right_trigger_hold_greyedout_zh", "nav_scarlett_right_trigger_hold_jp", "nav_scarlett_right_trigger_hold_ru", "nav_scarlett_right_trigger_hold_zh", "nav_scarlett_right_trigger_hold", "nav_scarlett_rightarrow_down", "nav_scarlett_rs_click", "nav_scarlett_rs_down", "nav_scarlett_rs_hold_de", "nav_scarlett_rs_hold_en", "nav_scarlett_rs_hold_es", "nav_scarlett_rs_hold_fr", "nav_scarlett_rs_hold_greyedout_de", "nav_scarlett_rs_hold_greyedout_en", "nav_scarlett_rs_hold_greyedout_es", "nav_scarlett_rs_hold_greyedout_fr", "nav_scarlett_rs_hold_greyedout_jp", "nav_scarlett_rs_hold_greyedout_ru", "nav_scarlett_rs_hold_greyedout_zh", "nav_scarlett_rs_hold_jp", "nav_scarlett_rs_hold_ru", "nav_scarlett_rs_hold_zh", "nav_scarlett_rs_hold", "nav_scarlett_rs_left", "nav_scarlett_rs_press", "nav_scarlett_rs_right", "nav_scarlett_rs_scroll", "nav_scarlett_rs_slide_scroll", "nav_scarlett_rs_slide", "nav_scarlett_rs_up", "nav_scarlett_rs", "nav_scarlett_rt_dim", "nav_scarlett_rt", "nav_scarlett_view_button_hold_de", "nav_scarlett_view_button_hold_en", "nav_scarlett_view_button_hold_es", "nav_scarlett_view_button_hold_fr", "nav_scarlett_view_button_hold_greyedout_de", "nav_scarlett_view_button_hold_greyedout_en", "nav_scarlett_view_button_hold_greyedout_es", "nav_scarlett_view_button_hold_greyedout_fr", "nav_scarlett_view_button_hold_greyedout_jp", "nav_scarlett_view_button_hold_greyedout_ru", "nav_scarlett_view_button_hold_greyedout_zh", "nav_scarlett_view_button_hold_jp", "nav_scarlett_view_button_hold_ru", "nav_scarlett_view_button_hold_zh", "nav_scarlett_view_button_hold", "nav_scarlett_view", "nav_scarlett_x_hold_de", "nav_scarlett_x_hold_en", "nav_scarlett_x_hold_es", "nav_scarlett_x_hold_fr", "nav_scarlett_x_hold_greyedout_de", "nav_scarlett_x_hold_greyedout_en", "nav_scarlett_x_hold_greyedout_es", "nav_scarlett_x_hold_greyedout_fr", "nav_scarlett_x_hold_greyedout_jp", "nav_scarlett_x_hold_greyedout_ru", "nav_scarlett_x_hold_greyedout_zh", "nav_scarlett_x_hold_jp", "nav_scarlett_x_hold_ru", "nav_scarlett_x_hold_zh", "nav_scarlett_x_hold", "nav_scarlett_x", "nav_scarlett_y_hold_de", "nav_scarlett_y_hold_en", "nav_scarlett_y_hold_es", "nav_scarlett_y_hold_fr", "nav_scarlett_y_hold_greyedout_de", "nav_scarlett_y_hold_greyedout_en", "nav_scarlett_y_hold_greyedout_es", "nav_scarlett_y_hold_greyedout_fr", "nav_scarlett_y_hold_greyedout_jp", "nav_scarlett_y_hold_greyedout_ru", "nav_scarlett_y_hold_greyedout_zh", "nav_scarlett_y_hold_jp", "nav_scarlett_y_hold_ru", "nav_scarlett_y_hold_zh", "nav_scarlett_y_hold", "nav_scarlett_y", "nav_scarlett_yb", "rightarrow_down",  },
        switchpro = Set{ "console_art_switchpro_agnostic", "leftarrow_down", "nav_switchpro_a_hold_de", "nav_switchpro_a_hold_en", "nav_switchpro_a_hold_es", "nav_switchpro_a_hold_fr", "nav_switchpro_a_hold_greyedout_de", "nav_switchpro_a_hold_greyedout_en", "nav_switchpro_a_hold_greyedout_es", "nav_switchpro_a_hold_greyedout_fr", "nav_switchpro_a_hold_greyedout_jp", "nav_switchpro_a_hold_greyedout_ru", "nav_switchpro_a_hold_greyedout_zh", "nav_switchpro_a_hold_jp", "nav_switchpro_a_hold_ru", "nav_switchpro_a_hold_zh", "nav_switchpro_a_hold", "nav_switchpro_a", "nav_switchpro_b_hold_de", "nav_switchpro_b_hold_en", "nav_switchpro_b_hold_es", "nav_switchpro_b_hold_fr", "nav_switchpro_b_hold_greyedout_de", "nav_switchpro_b_hold_greyedout_en", "nav_switchpro_b_hold_greyedout_es", "nav_switchpro_b_hold_greyedout_fr", "nav_switchpro_b_hold_greyedout_jp", "nav_switchpro_b_hold_greyedout_ru", "nav_switchpro_b_hold_greyedout_zh", "nav_switchpro_b_hold_jp", "nav_switchpro_b_hold_ru", "nav_switchpro_b_hold_zh", "nav_switchpro_b_hold", "nav_switchpro_b", "nav_switchpro_dpad_down_hold_de", "nav_switchpro_dpad_down_hold_en", "nav_switchpro_dpad_down_hold_es", "nav_switchpro_dpad_down_hold_fr", "nav_switchpro_dpad_down_hold_greyedout_de", "nav_switchpro_dpad_down_hold_greyedout_en", "nav_switchpro_dpad_down_hold_greyedout_es", "nav_switchpro_dpad_down_hold_greyedout_fr", "nav_switchpro_dpad_down_hold_greyedout_jp", "nav_switchpro_dpad_down_hold_greyedout_ru", "nav_switchpro_dpad_down_hold_greyedout_zh", "nav_switchpro_dpad_down_hold_jp", "nav_switchpro_dpad_down_hold_ru", "nav_switchpro_dpad_down_hold_zh", "nav_switchpro_dpad_down_hold", "nav_switchpro_dpad_left_hold_de", "nav_switchpro_dpad_left_hold_en", "nav_switchpro_dpad_left_hold_es", "nav_switchpro_dpad_left_hold_fr", "nav_switchpro_dpad_left_hold_greyedout_de", "nav_switchpro_dpad_left_hold_greyedout_en", "nav_switchpro_dpad_left_hold_greyedout_es", "nav_switchpro_dpad_left_hold_greyedout_fr", "nav_switchpro_dpad_left_hold_greyedout_jp", "nav_switchpro_dpad_left_hold_greyedout_ru", "nav_switchpro_dpad_left_hold_greyedout_zh", "nav_switchpro_dpad_left_hold_jp", "nav_switchpro_dpad_left_hold_ru", "nav_switchpro_dpad_left_hold_zh", "nav_switchpro_dpad_left_hold", "nav_switchpro_dpad_right_hold_de", "nav_switchpro_dpad_right_hold_en", "nav_switchpro_dpad_right_hold_es", "nav_switchpro_dpad_right_hold_fr", "nav_switchpro_dpad_right_hold_greyedout_de", "nav_switchpro_dpad_right_hold_greyedout_en", "nav_switchpro_dpad_right_hold_greyedout_es", "nav_switchpro_dpad_right_hold_greyedout_fr", "nav_switchpro_dpad_right_hold_greyedout_jp", "nav_switchpro_dpad_right_hold_greyedout_ru", "nav_switchpro_dpad_right_hold_greyedout_zh", "nav_switchpro_dpad_right_hold_jp", "nav_switchpro_dpad_right_hold_ru", "nav_switchpro_dpad_right_hold_zh", "nav_switchpro_dpad_right_hold", "nav_switchpro_dpad_up_hold_de", "nav_switchpro_dpad_up_hold_en", "nav_switchpro_dpad_up_hold_es", "nav_switchpro_dpad_up_hold_fr", "nav_switchpro_dpad_up_hold_greyedout_de", "nav_switchpro_dpad_up_hold_greyedout_en", "nav_switchpro_dpad_up_hold_greyedout_es", "nav_switchpro_dpad_up_hold_greyedout_fr", "nav_switchpro_dpad_up_hold_greyedout_jp", "nav_switchpro_dpad_up_hold_greyedout_ru", "nav_switchpro_dpad_up_hold_greyedout_zh", "nav_switchpro_dpad_up_hold_jp", "nav_switchpro_dpad_up_hold_ru", "nav_switchpro_dpad_up_hold_zh", "nav_switchpro_dpad_up_hold", "nav_switchpro_dpad", "nav_switchpro_dpaddown_hold_rs", "nav_switchpro_dpaddown", "nav_switchpro_dpadleft", "nav_switchpro_dpadright", "nav_switchpro_dpadrightb", "nav_switchpro_dpadup", "nav_switchpro_hold_zl_press_zr_de", "nav_switchpro_hold_zl_press_zr_en", "nav_switchpro_hold_zl_press_zr_es", "nav_switchpro_hold_zl_press_zr_fr", "nav_switchpro_hold_zl_press_zr_jp", "nav_switchpro_hold_zl_press_zr_ru", "nav_switchpro_hold_zl_press_zr_zh", "nav_switchpro_hold_zl_press_zr", "nav_switchpro_home_button_hold_de", "nav_switchpro_home_button_hold_en", "nav_switchpro_home_button_hold_es", "nav_switchpro_home_button_hold_fr", "nav_switchpro_home_button_hold_greyedout_de", "nav_switchpro_home_button_hold_greyedout_en", "nav_switchpro_home_button_hold_greyedout_es", "nav_switchpro_home_button_hold_greyedout_fr", "nav_switchpro_home_button_hold_greyedout_jp", "nav_switchpro_home_button_hold_greyedout_ru", "nav_switchpro_home_button_hold_greyedout_zh", "nav_switchpro_home_button_hold_jp", "nav_switchpro_home_button_hold_ru", "nav_switchpro_home_button_hold_zh", "nav_switchpro_home", "nav_switchpro_l", "nav_switchpro_la", "nav_switchpro_lb", "nav_switchpro_ldpaddown", "nav_switchpro_ldpadleft", "nav_switchpro_left_shoulder_hold_de", "nav_switchpro_left_shoulder_hold_en", "nav_switchpro_left_shoulder_hold_es", "nav_switchpro_left_shoulder_hold_fr", "nav_switchpro_left_shoulder_hold_greyedout_de", "nav_switchpro_left_shoulder_hold_greyedout_en", "nav_switchpro_left_shoulder_hold_greyedout_es", "nav_switchpro_left_shoulder_hold_greyedout_fr", "nav_switchpro_left_shoulder_hold_greyedout_jp", "nav_switchpro_left_shoulder_hold_greyedout_ru", "nav_switchpro_left_shoulder_hold_greyedout_zh", "nav_switchpro_left_shoulder_hold_jp", "nav_switchpro_left_shoulder_hold_ru", "nav_switchpro_left_shoulder_hold_zh", "nav_switchpro_left_shoulder_hold", "nav_switchpro_left_trigger_hold_de", "nav_switchpro_left_trigger_hold_en", "nav_switchpro_left_trigger_hold_es", "nav_switchpro_left_trigger_hold_fr", "nav_switchpro_left_trigger_hold_greyedout_de", "nav_switchpro_left_trigger_hold_greyedout_en", "nav_switchpro_left_trigger_hold_greyedout_es", "nav_switchpro_left_trigger_hold_greyedout_fr", "nav_switchpro_left_trigger_hold_greyedout_jp", "nav_switchpro_left_trigger_hold_greyedout_ru", "nav_switchpro_left_trigger_hold_greyedout_zh", "nav_switchpro_left_trigger_hold_jp", "nav_switchpro_left_trigger_hold_ru", "nav_switchpro_left_trigger_hold_zh", "nav_switchpro_left_trigger_hold", "nav_switchpro_leftarrowrightarrow", "nav_switchpro_lr", "nav_switchpro_lrs_press", "nav_switchpro_lrs_right", "nav_switchpro_ls_click_02", "nav_switchpro_ls_click", "nav_switchpro_ls_down", "nav_switchpro_ls_hold_de", "nav_switchpro_ls_hold_en", "nav_switchpro_ls_hold_es", "nav_switchpro_ls_hold_fr", "nav_switchpro_ls_hold_jp", "nav_switchpro_ls_hold_ru", "nav_switchpro_ls_hold_zh", "nav_switchpro_ls_hold", "nav_switchpro_ls_left", "nav_switchpro_ls_press", "nav_switchpro_ls_right", "nav_switchpro_ls_scroll", "nav_switchpro_ls_slide_scroll", "nav_switchpro_ls_slide", "nav_switchpro_ls_up", "nav_switchpro_ls", "nav_switchpro_lsrs_click_02", "nav_switchpro_lsrs_click", "nav_switchpro_lsrs_press", "nav_switchpro_lsrs", "nav_switchpro_lx", "nav_switchpro_ly", "nav_switchpro_lzr", "nav_switchpro_minus_button_hold_de", "nav_switchpro_minus_button_hold_en", "nav_switchpro_minus_button_hold_es", "nav_switchpro_minus_button_hold_fr", "nav_switchpro_minus_button_hold_greyedout_de", "nav_switchpro_minus_button_hold_greyedout_en", "nav_switchpro_minus_button_hold_greyedout_es", "nav_switchpro_minus_button_hold_greyedout_fr", "nav_switchpro_minus_button_hold_greyedout_jp", "nav_switchpro_minus_button_hold_greyedout_ru", "nav_switchpro_minus_button_hold_greyedout_zh", "nav_switchpro_minus_button_hold_jp", "nav_switchpro_minus_button_hold_ru", "nav_switchpro_minus_button_hold_zh", "nav_switchpro_minus_button_hold", "nav_switchpro_minus", "nav_switchpro_plus_button_hold_de", "nav_switchpro_plus_button_hold_en", "nav_switchpro_plus_button_hold_es", "nav_switchpro_plus_button_hold_fr", "nav_switchpro_plus_button_hold_greyedout_de", "nav_switchpro_plus_button_hold_greyedout_en", "nav_switchpro_plus_button_hold_greyedout_es", "nav_switchpro_plus_button_hold_greyedout_fr", "nav_switchpro_plus_button_hold_greyedout_jp", "nav_switchpro_plus_button_hold_greyedout_ru", "nav_switchpro_plus_button_hold_greyedout_zh", "nav_switchpro_plus_button_hold_jp", "nav_switchpro_plus_button_hold_ru", "nav_switchpro_plus_button_hold_zh", "nav_switchpro_plus_button_hold", "nav_switchpro_r", "nav_switchpro_ra", "nav_switchpro_rb", "nav_switchpro_right_shoulder_hold_de", "nav_switchpro_right_shoulder_hold_en", "nav_switchpro_right_shoulder_hold_es", "nav_switchpro_right_shoulder_hold_fr", "nav_switchpro_right_shoulder_hold_greyedout_de", "nav_switchpro_right_shoulder_hold_greyedout_en", "nav_switchpro_right_shoulder_hold_greyedout_es", "nav_switchpro_right_shoulder_hold_greyedout_fr", "nav_switchpro_right_shoulder_hold_greyedout_jp", "nav_switchpro_right_shoulder_hold_greyedout_ru", "nav_switchpro_right_shoulder_hold_greyedout_zh", "nav_switchpro_right_shoulder_hold_jp", "nav_switchpro_right_shoulder_hold_ru", "nav_switchpro_right_shoulder_hold_zh", "nav_switchpro_right_shoulder_hold", "nav_switchpro_right_trigger_hold_de", "nav_switchpro_right_trigger_hold_en", "nav_switchpro_right_trigger_hold_es", "nav_switchpro_right_trigger_hold_fr", "nav_switchpro_right_trigger_hold_greyedout_de", "nav_switchpro_right_trigger_hold_greyedout_en", "nav_switchpro_right_trigger_hold_greyedout_es", "nav_switchpro_right_trigger_hold_greyedout_fr", "nav_switchpro_right_trigger_hold_greyedout_jp", "nav_switchpro_right_trigger_hold_greyedout_ru", "nav_switchpro_right_trigger_hold_greyedout_zh", "nav_switchpro_right_trigger_hold_jp", "nav_switchpro_right_trigger_hold_ru", "nav_switchpro_right_trigger_hold_zh", "nav_switchpro_right_trigger_hold", "nav_switchpro_rs_click_02", "nav_switchpro_rs_click", "nav_switchpro_rs_down", "nav_switchpro_rs_hold_de", "nav_switchpro_rs_hold_en", "nav_switchpro_rs_hold_es", "nav_switchpro_rs_hold_fr", "nav_switchpro_rs_hold_jp", "nav_switchpro_rs_hold_ru", "nav_switchpro_rs_hold_zh", "nav_switchpro_rs_hold", "nav_switchpro_rs_left", "nav_switchpro_rs_plus", "nav_switchpro_rs_press", "nav_switchpro_rs_right", "nav_switchpro_rs_scroll", "nav_switchpro_rs_slide_scroll", "nav_switchpro_rs_slide", "nav_switchpro_rs_up", "nav_switchpro_rs", "nav_switchpro_rx", "nav_switchpro_ry", "nav_switchpro_share", "nav_switchpro_x_hold_de", "nav_switchpro_x_hold_en", "nav_switchpro_x_hold_es", "nav_switchpro_x_hold_fr", "nav_switchpro_x_hold_greyedout_de", "nav_switchpro_x_hold_greyedout_en", "nav_switchpro_x_hold_greyedout_es", "nav_switchpro_x_hold_greyedout_fr", "nav_switchpro_x_hold_greyedout_jp", "nav_switchpro_x_hold_greyedout_ru", "nav_switchpro_x_hold_greyedout_zh", "nav_switchpro_x_hold_jp", "nav_switchpro_x_hold_ru", "nav_switchpro_x_hold_zh", "nav_switchpro_x_hold", "nav_switchpro_x", "nav_switchpro_y_hold_de", "nav_switchpro_y_hold_en", "nav_switchpro_y_hold_es", "nav_switchpro_y_hold_fr", "nav_switchpro_y_hold_greyedout_de", "nav_switchpro_y_hold_greyedout_en", "nav_switchpro_y_hold_greyedout_es", "nav_switchpro_y_hold_greyedout_fr", "nav_switchpro_y_hold_greyedout_jp", "nav_switchpro_y_hold_greyedout_ru", "nav_switchpro_y_hold_greyedout_zh", "nav_switchpro_y_hold_jp", "nav_switchpro_y_hold_ru", "nav_switchpro_y_hold_zh", "nav_switchpro_y_hold", "nav_switchpro_y", "nav_switchpro_yb", "nav_switchpro_zl_dim", "nav_switchpro_zl", "nav_switchpro_zla", "nav_switchpro_zlb", "nav_switchpro_zlx", "nav_switchpro_zly", "nav_switchpro_zlzr", "nav_switchpro_zr_dim", "nav_switchpro_zr", "rightarrow_down",  },
        ps4 = Set{ "console_art_ps4", "nav_ps4_circle_hold_de", "nav_ps4_circle_hold_en", "nav_ps4_circle_hold_es", "nav_ps4_circle_hold_fr", "nav_ps4_circle_hold_greyedout_de", "nav_ps4_circle_hold_greyedout_en", "nav_ps4_circle_hold_greyedout_es", "nav_ps4_circle_hold_greyedout_fr", "nav_ps4_circle_hold_greyedout_jp", "nav_ps4_circle_hold_greyedout_ru", "nav_ps4_circle_hold_greyedout_zh", "nav_ps4_circle_hold_jp", "nav_ps4_circle_hold_ru", "nav_ps4_circle_hold_zh", "nav_ps4_circle_hold", "nav_ps4_circle", "nav_ps4_dpad_down_hold_de", "nav_ps4_dpad_down_hold_en", "nav_ps4_dpad_down_hold_es", "nav_ps4_dpad_down_hold_fr", "nav_ps4_dpad_down_hold_greyedout_de", "nav_ps4_dpad_down_hold_greyedout_en", "nav_ps4_dpad_down_hold_greyedout_es", "nav_ps4_dpad_down_hold_greyedout_fr", "nav_ps4_dpad_down_hold_greyedout_jp", "nav_ps4_dpad_down_hold_greyedout_ru", "nav_ps4_dpad_down_hold_greyedout_zh", "nav_ps4_dpad_down_hold_jp", "nav_ps4_dpad_down_hold_ru", "nav_ps4_dpad_down_hold_zh", "nav_ps4_dpad_down_hold", "nav_ps4_dpad_left_hold_de", "nav_ps4_dpad_left_hold_en", "nav_ps4_dpad_left_hold_es", "nav_ps4_dpad_left_hold_fr", "nav_ps4_dpad_left_hold_greyedout_de", "nav_ps4_dpad_left_hold_greyedout_en", "nav_ps4_dpad_left_hold_greyedout_es", "nav_ps4_dpad_left_hold_greyedout_fr", "nav_ps4_dpad_left_hold_greyedout_jp", "nav_ps4_dpad_left_hold_greyedout_ru", "nav_ps4_dpad_left_hold_greyedout_zh", "nav_ps4_dpad_left_hold_jp", "nav_ps4_dpad_left_hold_ru", "nav_ps4_dpad_left_hold_zh", "nav_ps4_dpad_left_hold", "nav_ps4_dpad_right_hold_de", "nav_ps4_dpad_right_hold_en", "nav_ps4_dpad_right_hold_es", "nav_ps4_dpad_right_hold_fr", "nav_ps4_dpad_right_hold_greyedout_de", "nav_ps4_dpad_right_hold_greyedout_en", "nav_ps4_dpad_right_hold_greyedout_es", "nav_ps4_dpad_right_hold_greyedout_fr", "nav_ps4_dpad_right_hold_greyedout_jp", "nav_ps4_dpad_right_hold_greyedout_ru", "nav_ps4_dpad_right_hold_greyedout_zh", "nav_ps4_dpad_right_hold_jp", "nav_ps4_dpad_right_hold_ru", "nav_ps4_dpad_right_hold_zh", "nav_ps4_dpad_right_hold", "nav_ps4_dpad_up_hold_de", "nav_ps4_dpad_up_hold_en", "nav_ps4_dpad_up_hold_es", "nav_ps4_dpad_up_hold_fr", "nav_ps4_dpad_up_hold_greyedout_de", "nav_ps4_dpad_up_hold_greyedout_en", "nav_ps4_dpad_up_hold_greyedout_es", "nav_ps4_dpad_up_hold_greyedout_fr", "nav_ps4_dpad_up_hold_greyedout_jp", "nav_ps4_dpad_up_hold_greyedout_ru", "nav_ps4_dpad_up_hold_greyedout_zh", "nav_ps4_dpad_up_hold_jp", "nav_ps4_dpad_up_hold_ru", "nav_ps4_dpad_up_hold_zh", "nav_ps4_dpad_up_hold", "nav_ps4_dpad", "nav_ps4_dpaddown_hold_rs", "nav_ps4_dpaddown", "nav_ps4_dpadleft", "nav_ps4_dpadright", "nav_ps4_dpadrightcircle", "nav_ps4_dpadup", "nav_ps4_hold_l2_press_r2_de", "nav_ps4_hold_l2_press_r2_en", "nav_ps4_hold_l2_press_r2_es", "nav_ps4_hold_l2_press_r2_fr", "nav_ps4_hold_l2_press_r2_jp", "nav_ps4_hold_l2_press_r2_ru", "nav_ps4_hold_l2_press_r2_zh", "nav_ps4_hold_l2_press_r2", "nav_ps4_l1", "nav_ps4_l1circle", "nav_ps4_l1dpaddown", "nav_ps4_l1dpadleft", "nav_ps4_l1r1", "nav_ps4_l1r2", "nav_ps4_l1rs_press", "nav_ps4_l1rs_right", "nav_ps4_l1square", "nav_ps4_l1triangle", "nav_ps4_l1x", "nav_ps4_l2_dim", "nav_ps4_l2", "nav_ps4_l2circle", "nav_ps4_l2r2", "nav_ps4_l2square", "nav_ps4_l2triangle", "nav_ps4_l2x", "nav_ps4_left_shoulder_hold_de", "nav_ps4_left_shoulder_hold_en", "nav_ps4_left_shoulder_hold_es", "nav_ps4_left_shoulder_hold_fr", "nav_ps4_left_shoulder_hold_greyedout_de", "nav_ps4_left_shoulder_hold_greyedout_en", "nav_ps4_left_shoulder_hold_greyedout_es", "nav_ps4_left_shoulder_hold_greyedout_fr", "nav_ps4_left_shoulder_hold_greyedout_jp", "nav_ps4_left_shoulder_hold_greyedout_ru", "nav_ps4_left_shoulder_hold_greyedout_zh", "nav_ps4_left_shoulder_hold_jp", "nav_ps4_left_shoulder_hold_ru", "nav_ps4_left_shoulder_hold_zh", "nav_ps4_left_shoulder_hold", "nav_ps4_left_trigger_hold_de", "nav_ps4_left_trigger_hold_en", "nav_ps4_left_trigger_hold_es", "nav_ps4_left_trigger_hold_fr", "nav_ps4_left_trigger_hold_greyedout_de", "nav_ps4_left_trigger_hold_greyedout_en", "nav_ps4_left_trigger_hold_greyedout_es", "nav_ps4_left_trigger_hold_greyedout_fr", "nav_ps4_left_trigger_hold_greyedout_jp", "nav_ps4_left_trigger_hold_greyedout_ru", "nav_ps4_left_trigger_hold_greyedout_zh", "nav_ps4_left_trigger_hold_jp", "nav_ps4_left_trigger_hold_ru", "nav_ps4_left_trigger_hold_zh", "nav_ps4_left_trigger_hold", "nav_ps4_ls_click", "nav_ps4_ls_down", "nav_ps4_ls_hold_de", "nav_ps4_ls_hold_en", "nav_ps4_ls_hold_es", "nav_ps4_ls_hold_fr", "nav_ps4_ls_hold_greyedout_de", "nav_ps4_ls_hold_greyedout_en", "nav_ps4_ls_hold_greyedout_es", "nav_ps4_ls_hold_greyedout_fr", "nav_ps4_ls_hold_greyedout_jp", "nav_ps4_ls_hold_greyedout_ru", "nav_ps4_ls_hold_greyedout_zh", "nav_ps4_ls_hold_jp", "nav_ps4_ls_hold_ru", "nav_ps4_ls_hold_zh", "nav_ps4_ls_hold", "nav_ps4_ls_left", "nav_ps4_ls_press", "nav_ps4_ls_right", "nav_ps4_ls_scroll", "nav_ps4_ls_slide_scroll", "nav_ps4_ls_slide", "nav_ps4_ls_up", "nav_ps4_ls", "nav_ps4_lsrs_click", "nav_ps4_lsrs_press", "nav_ps4_lsrs", "nav_ps4_options_hold_de", "nav_ps4_options_hold_en", "nav_ps4_options_hold_es", "nav_ps4_options_hold_fr", "nav_ps4_options_hold_greyedout_de", "nav_ps4_options_hold_greyedout_en", "nav_ps4_options_hold_greyedout_es", "nav_ps4_options_hold_greyedout_fr", "nav_ps4_options_hold_greyedout_jp", "nav_ps4_options_hold_greyedout_ru", "nav_ps4_options_hold_greyedout_zh", "nav_ps4_options_hold_jp", "nav_ps4_options_hold_ru", "nav_ps4_options_hold_zh", "nav_ps4_options_hold", "nav_ps4_options", "nav_ps4_r1", "nav_ps4_r1circle", "nav_ps4_r1square", "nav_ps4_r1triangle", "nav_ps4_r1x", "nav_ps4_r2_dim", "nav_ps4_r2", "nav_ps4_right_shoulder_hold_de", "nav_ps4_right_shoulder_hold_en", "nav_ps4_right_shoulder_hold_es", "nav_ps4_right_shoulder_hold_fr", "nav_ps4_right_shoulder_hold_greyedout_de", "nav_ps4_right_shoulder_hold_greyedout_en", "nav_ps4_right_shoulder_hold_greyedout_es", "nav_ps4_right_shoulder_hold_greyedout_fr", "nav_ps4_right_shoulder_hold_greyedout_jp", "nav_ps4_right_shoulder_hold_greyedout_ru", "nav_ps4_right_shoulder_hold_greyedout_zh", "nav_ps4_right_shoulder_hold_jp", "nav_ps4_right_shoulder_hold_ru", "nav_ps4_right_shoulder_hold_zh", "nav_ps4_right_shoulder_hold", "nav_ps4_right_trigger_hold_de", "nav_ps4_right_trigger_hold_en", "nav_ps4_right_trigger_hold_es", "nav_ps4_right_trigger_hold_fr", "nav_ps4_right_trigger_hold_greyedout_de", "nav_ps4_right_trigger_hold_greyedout_en", "nav_ps4_right_trigger_hold_greyedout_es", "nav_ps4_right_trigger_hold_greyedout_fr", "nav_ps4_right_trigger_hold_greyedout_jp", "nav_ps4_right_trigger_hold_greyedout_ru", "nav_ps4_right_trigger_hold_greyedout_zh", "nav_ps4_right_trigger_hold_jp", "nav_ps4_right_trigger_hold_ru", "nav_ps4_right_trigger_hold_zh", "nav_ps4_right_trigger_hold", "nav_ps4_rs_click", "nav_ps4_rs_down", "nav_ps4_rs_hold_de", "nav_ps4_rs_hold_en", "nav_ps4_rs_hold_es", "nav_ps4_rs_hold_fr", "nav_ps4_rs_hold_greyedout_de", "nav_ps4_rs_hold_greyedout_en", "nav_ps4_rs_hold_greyedout_es", "nav_ps4_rs_hold_greyedout_fr", "nav_ps4_rs_hold_greyedout_jp", "nav_ps4_rs_hold_greyedout_ru", "nav_ps4_rs_hold_greyedout_zh", "nav_ps4_rs_hold_jp", "nav_ps4_rs_hold_ru", "nav_ps4_rs_hold_zh", "nav_ps4_rs_hold", "nav_ps4_rs_left", "nav_ps4_rs_press", "nav_ps4_rs_right", "nav_ps4_rs_scroll", "nav_ps4_rs_slide_scroll", "nav_ps4_rs_slide", "nav_ps4_rs_up", "nav_ps4_rs", "nav_ps4_share_hold_de", "nav_ps4_share_hold_en", "nav_ps4_share_hold_es", "nav_ps4_share_hold_fr", "nav_ps4_share_hold_greyedout_de", "nav_ps4_share_hold_greyedout_en", "nav_ps4_share_hold_greyedout_es", "nav_ps4_share_hold_greyedout_fr", "nav_ps4_share_hold_greyedout_jp", "nav_ps4_share_hold_greyedout_ru", "nav_ps4_share_hold_greyedout_zh", "nav_ps4_share_hold_jp", "nav_ps4_share_hold_ru", "nav_ps4_share_hold_zh", "nav_ps4_share_hold", "nav_ps4_share", "nav_ps4_square_hold_de", "nav_ps4_square_hold_en", "nav_ps4_square_hold_es", "nav_ps4_square_hold_fr", "nav_ps4_square_hold_greyedout_de", "nav_ps4_square_hold_greyedout_en", "nav_ps4_square_hold_greyedout_es", "nav_ps4_square_hold_greyedout_fr", "nav_ps4_square_hold_greyedout_jp", "nav_ps4_square_hold_greyedout_ru", "nav_ps4_square_hold_greyedout_zh", "nav_ps4_square_hold_jp", "nav_ps4_square_hold_ru", "nav_ps4_square_hold_zh", "nav_ps4_square_hold", "nav_ps4_square", "nav_ps4_touchpad_hold_de", "nav_ps4_touchpad_hold_en", "nav_ps4_touchpad_hold_es", "nav_ps4_touchpad_hold_fr", "nav_ps4_touchpad_hold_greyedout_de", "nav_ps4_touchpad_hold_greyedout_en", "nav_ps4_touchpad_hold_greyedout_es", "nav_ps4_touchpad_hold_greyedout_fr", "nav_ps4_touchpad_hold_greyedout_jp", "nav_ps4_touchpad_hold_greyedout_ru", "nav_ps4_touchpad_hold_greyedout_zh", "nav_ps4_touchpad_hold_jp", "nav_ps4_touchpad_hold_ru", "nav_ps4_touchpad_hold_zh", "nav_ps4_touchpad_hold", "nav_ps4_trackpad_circle", "nav_ps4_trackpad_down", "nav_ps4_trackpad_left", "nav_ps4_trackpad_leftright", "nav_ps4_trackpad_lefttoright", "nav_ps4_trackpad_press", "nav_ps4_trackpad_right", "nav_ps4_trackpad_up", "nav_ps4_trackpad_updown", "nav_ps4_trackpadoptions", "nav_ps4_triangle_hold_de", "nav_ps4_triangle_hold_en", "nav_ps4_triangle_hold_es", "nav_ps4_triangle_hold_fr", "nav_ps4_triangle_hold_greyedout_de", "nav_ps4_triangle_hold_greyedout_en", "nav_ps4_triangle_hold_greyedout_es", "nav_ps4_triangle_hold_greyedout_fr", "nav_ps4_triangle_hold_greyedout_jp", "nav_ps4_triangle_hold_greyedout_ru", "nav_ps4_triangle_hold_greyedout_zh", "nav_ps4_triangle_hold_jp", "nav_ps4_triangle_hold_ru", "nav_ps4_triangle_hold_zh", "nav_ps4_triangle_hold", "nav_ps4_triangle", "nav_ps4_trianglecircle", "nav_ps4_x_hold_de", "nav_ps4_x_hold_en", "nav_ps4_x_hold_es", "nav_ps4_x_hold_fr", "nav_ps4_x_hold_greyedout_de", "nav_ps4_x_hold_greyedout_en", "nav_ps4_x_hold_greyedout_es", "nav_ps4_x_hold_greyedout_fr", "nav_ps4_x_hold_greyedout_jp", "nav_ps4_x_hold_greyedout_ru", "nav_ps4_x_hold_greyedout_zh", "nav_ps4_x_hold_jp", "nav_ps4_x_hold_ru", "nav_ps4_x_hold_zh", "nav_ps4_x_hold", "nav_ps4_x",  },
        ps5 = Set{ "console_art_ps5", "nav_ps5_broadcast_hold_de", "nav_ps5_broadcast_hold_en", "nav_ps5_broadcast_hold_es", "nav_ps5_broadcast_hold_fr", "nav_ps5_broadcast_hold_greyedout_de", "nav_ps5_broadcast_hold_greyedout_en", "nav_ps5_broadcast_hold_greyedout_es", "nav_ps5_broadcast_hold_greyedout_fr", "nav_ps5_broadcast_hold_greyedout_jp", "nav_ps5_broadcast_hold_greyedout_ru", "nav_ps5_broadcast_hold_greyedout_zh", "nav_ps5_broadcast_hold_jp", "nav_ps5_broadcast_hold_ru", "nav_ps5_broadcast_hold_zh", "nav_ps5_broadcast_hold", "nav_ps5_broadcast", "nav_ps5_broadcastoptions", "nav_ps5_circle_hold_de", "nav_ps5_circle_hold_en", "nav_ps5_circle_hold_es", "nav_ps5_circle_hold_fr", "nav_ps5_circle_hold_greyedout_de", "nav_ps5_circle_hold_greyedout_en", "nav_ps5_circle_hold_greyedout_es", "nav_ps5_circle_hold_greyedout_fr", "nav_ps5_circle_hold_greyedout_jp", "nav_ps5_circle_hold_greyedout_ru", "nav_ps5_circle_hold_greyedout_zh", "nav_ps5_circle_hold_greyedout", "nav_ps5_circle_hold_jp", "nav_ps5_circle_hold_ru", "nav_ps5_circle_hold_zh", "nav_ps5_circle_hold", "nav_ps5_circle", "nav_ps5_dpad_down_hold_de", "nav_ps5_dpad_down_hold_en", "nav_ps5_dpad_down_hold_es", "nav_ps5_dpad_down_hold_fr", "nav_ps5_dpad_down_hold_greyedout_de", "nav_ps5_dpad_down_hold_greyedout_en", "nav_ps5_dpad_down_hold_greyedout_es", "nav_ps5_dpad_down_hold_greyedout_fr", "nav_ps5_dpad_down_hold_greyedout_jp", "nav_ps5_dpad_down_hold_greyedout_ru", "nav_ps5_dpad_down_hold_greyedout_zh", "nav_ps5_dpad_down_hold_jp", "nav_ps5_dpad_down_hold_ru", "nav_ps5_dpad_down_hold_zh", "nav_ps5_dpad_down_hold", "nav_ps5_dpad_left_hold_de", "nav_ps5_dpad_left_hold_en", "nav_ps5_dpad_left_hold_es", "nav_ps5_dpad_left_hold_fr", "nav_ps5_dpad_left_hold_greyedout_de", "nav_ps5_dpad_left_hold_greyedout_en", "nav_ps5_dpad_left_hold_greyedout_es", "nav_ps5_dpad_left_hold_greyedout_fr", "nav_ps5_dpad_left_hold_greyedout_jp", "nav_ps5_dpad_left_hold_greyedout_ru", "nav_ps5_dpad_left_hold_greyedout_zh", "nav_ps5_dpad_left_hold_jp", "nav_ps5_dpad_left_hold_ru", "nav_ps5_dpad_left_hold_zh", "nav_ps5_dpad_left_hold", "nav_ps5_dpad_right_hold_de", "nav_ps5_dpad_right_hold_en", "nav_ps5_dpad_right_hold_es", "nav_ps5_dpad_right_hold_fr", "nav_ps5_dpad_right_hold_greyedout_de", "nav_ps5_dpad_right_hold_greyedout_en", "nav_ps5_dpad_right_hold_greyedout_es", "nav_ps5_dpad_right_hold_greyedout_fr", "nav_ps5_dpad_right_hold_greyedout_jp", "nav_ps5_dpad_right_hold_greyedout_ru", "nav_ps5_dpad_right_hold_greyedout_zh", "nav_ps5_dpad_right_hold_jp", "nav_ps5_dpad_right_hold_ru", "nav_ps5_dpad_right_hold_zh", "nav_ps5_dpad_right_hold", "nav_ps5_dpad_up_hold_de", "nav_ps5_dpad_up_hold_en", "nav_ps5_dpad_up_hold_es", "nav_ps5_dpad_up_hold_fr", "nav_ps5_dpad_up_hold_greyedout_de", "nav_ps5_dpad_up_hold_greyedout_en", "nav_ps5_dpad_up_hold_greyedout_es", "nav_ps5_dpad_up_hold_greyedout_fr", "nav_ps5_dpad_up_hold_greyedout_jp", "nav_ps5_dpad_up_hold_greyedout_ru", "nav_ps5_dpad_up_hold_greyedout_zh", "nav_ps5_dpad_up_hold_jp", "nav_ps5_dpad_up_hold_ru", "nav_ps5_dpad_up_hold_zh", "nav_ps5_dpad_up_hold", "nav_ps5_dpad", "nav_ps5_dpaddown_hold_rs", "nav_ps5_dpaddown", "nav_ps5_dpadleft", "nav_ps5_dpadright", "nav_ps5_dpadrightcircle", "nav_ps5_dpadup", "nav_ps5_hold_l2_press_r2_de", "nav_ps5_hold_l2_press_r2_en", "nav_ps5_hold_l2_press_r2_es", "nav_ps5_hold_l2_press_r2_fr", "nav_ps5_hold_l2_press_r2_jp", "nav_ps5_hold_l2_press_r2_ru", "nav_ps5_hold_l2_press_r2_zh", "nav_ps5_hold_l2_press_r2", "nav_ps5_l1", "nav_ps5_l1circle", "nav_ps5_l1dpaddown", "nav_ps5_l1dpadleft", "nav_ps5_l1r1", "nav_ps5_l1r2", "nav_ps5_l1rs_press", "nav_ps5_l1rs_right", "nav_ps5_l1square", "nav_ps5_l1triangle", "nav_ps5_l1x", "nav_ps5_l2_dim", "nav_ps5_l2", "nav_ps5_l2circle", "nav_ps5_l2r2", "nav_ps5_l2square", "nav_ps5_l2triangle", "nav_ps5_l2x", "nav_ps5_left_shoulder_hold_de", "nav_ps5_left_shoulder_hold_en", "nav_ps5_left_shoulder_hold_es", "nav_ps5_left_shoulder_hold_fr", "nav_ps5_left_shoulder_hold_greyedout_de", "nav_ps5_left_shoulder_hold_greyedout_en", "nav_ps5_left_shoulder_hold_greyedout_es", "nav_ps5_left_shoulder_hold_greyedout_fr", "nav_ps5_left_shoulder_hold_greyedout_jp", "nav_ps5_left_shoulder_hold_greyedout_ru", "nav_ps5_left_shoulder_hold_greyedout_zh", "nav_ps5_left_shoulder_hold_jp", "nav_ps5_left_shoulder_hold_ru", "nav_ps5_left_shoulder_hold_zh", "nav_ps5_left_shoulder_hold", "nav_ps5_left_trigger_hold_de", "nav_ps5_left_trigger_hold_en", "nav_ps5_left_trigger_hold_es", "nav_ps5_left_trigger_hold_fr", "nav_ps5_left_trigger_hold_greyedout_de", "nav_ps5_left_trigger_hold_greyedout_en", "nav_ps5_left_trigger_hold_greyedout_es", "nav_ps5_left_trigger_hold_greyedout_fr", "nav_ps5_left_trigger_hold_greyedout_jp", "nav_ps5_left_trigger_hold_greyedout_ru", "nav_ps5_left_trigger_hold_greyedout_zh", "nav_ps5_left_trigger_hold_jp", "nav_ps5_left_trigger_hold_ru", "nav_ps5_left_trigger_hold_zh", "nav_ps5_left_trigger_hold", "nav_ps5_ls_click", "nav_ps5_ls_down", "nav_ps5_ls_hold_de", "nav_ps5_ls_hold_en", "nav_ps5_ls_hold_es", "nav_ps5_ls_hold_fr", "nav_ps5_ls_hold_jp", "nav_ps5_ls_hold_ru", "nav_ps5_ls_hold_zh", "nav_ps5_ls_hold", "nav_ps5_ls_left", "nav_ps5_ls_press", "nav_ps5_ls_right", "nav_ps5_ls_scroll", "nav_ps5_ls_slide_scroll", "nav_ps5_ls_slide", "nav_ps5_ls_up", "nav_ps5_ls", "nav_ps5_lsrs_click", "nav_ps5_lsrs_press", "nav_ps5_lsrs", "nav_ps5_options_hold_de", "nav_ps5_options_hold_en", "nav_ps5_options_hold_es", "nav_ps5_options_hold_fr", "nav_ps5_options_hold_greyedout_de", "nav_ps5_options_hold_greyedout_en", "nav_ps5_options_hold_greyedout_es", "nav_ps5_options_hold_greyedout_fr", "nav_ps5_options_hold_greyedout_jp", "nav_ps5_options_hold_greyedout_ru", "nav_ps5_options_hold_greyedout_zh", "nav_ps5_options_hold_jp", "nav_ps5_options_hold_ru", "nav_ps5_options_hold_zh", "nav_ps5_options_hold", "nav_ps5_options", "nav_ps5_r1", "nav_ps5_r1circle", "nav_ps5_r1square", "nav_ps5_r1triangle", "nav_ps5_r1x", "nav_ps5_r2_dim", "nav_ps5_r2", "nav_ps5_right_shoulder_hold_de", "nav_ps5_right_shoulder_hold_en", "nav_ps5_right_shoulder_hold_es", "nav_ps5_right_shoulder_hold_fr", "nav_ps5_right_shoulder_hold_greyedout_de", "nav_ps5_right_shoulder_hold_greyedout_en", "nav_ps5_right_shoulder_hold_greyedout_es", "nav_ps5_right_shoulder_hold_greyedout_fr", "nav_ps5_right_shoulder_hold_greyedout_jp", "nav_ps5_right_shoulder_hold_greyedout_ru", "nav_ps5_right_shoulder_hold_greyedout_zh", "nav_ps5_right_shoulder_hold_jp", "nav_ps5_right_shoulder_hold_ru", "nav_ps5_right_shoulder_hold_zh", "nav_ps5_right_shoulder_hold", "nav_ps5_right_trigger_hold_de", "nav_ps5_right_trigger_hold_en", "nav_ps5_right_trigger_hold_es", "nav_ps5_right_trigger_hold_fr", "nav_ps5_right_trigger_hold_greyedout_de", "nav_ps5_right_trigger_hold_greyedout_en", "nav_ps5_right_trigger_hold_greyedout_es", "nav_ps5_right_trigger_hold_greyedout_fr", "nav_ps5_right_trigger_hold_greyedout_jp", "nav_ps5_right_trigger_hold_greyedout_ru", "nav_ps5_right_trigger_hold_greyedout_zh", "nav_ps5_right_trigger_hold_jp", "nav_ps5_right_trigger_hold_ru", "nav_ps5_right_trigger_hold_zh", "nav_ps5_right_trigger_hold", "nav_ps5_rs_click", "nav_ps5_rs_down", "nav_ps5_rs_hold_de", "nav_ps5_rs_hold_en", "nav_ps5_rs_hold_es", "nav_ps5_rs_hold_fr", "nav_ps5_rs_hold_jp", "nav_ps5_rs_hold_ru", "nav_ps5_rs_hold_zh", "nav_ps5_rs_hold", "nav_ps5_rs_left", "nav_ps5_rs_press", "nav_ps5_rs_right", "nav_ps5_rs_scroll", "nav_ps5_rs_slide_scroll", "nav_ps5_rs_slide", "nav_ps5_rs_up", "nav_ps5_rs", "nav_ps5_square_hold_de", "nav_ps5_square_hold_en", "nav_ps5_square_hold_es", "nav_ps5_square_hold_fr", "nav_ps5_square_hold_greyedout_de", "nav_ps5_square_hold_greyedout_en", "nav_ps5_square_hold_greyedout_es", "nav_ps5_square_hold_greyedout_fr", "nav_ps5_square_hold_greyedout_jp", "nav_ps5_square_hold_greyedout_ru", "nav_ps5_square_hold_greyedout_zh", "nav_ps5_square_hold_greyedout", "nav_ps5_square_hold_jp", "nav_ps5_square_hold_ru", "nav_ps5_square_hold_zh", "nav_ps5_square_hold", "nav_ps5_square", "nav_ps5_touchpad_hold_de", "nav_ps5_touchpad_hold_en", "nav_ps5_touchpad_hold_es", "nav_ps5_touchpad_hold_fr", "nav_ps5_touchpad_hold_greyedout_de", "nav_ps5_touchpad_hold_greyedout_en", "nav_ps5_touchpad_hold_greyedout_es", "nav_ps5_touchpad_hold_greyedout_fr", "nav_ps5_touchpad_hold_greyedout_jp", "nav_ps5_touchpad_hold_greyedout_ru", "nav_ps5_touchpad_hold_greyedout_zh", "nav_ps5_touchpad_hold_jp", "nav_ps5_touchpad_hold_ru", "nav_ps5_touchpad_hold_zh", "nav_ps5_touchpad_hold", "nav_ps5_trackpad_circle", "nav_ps5_trackpad_down", "nav_ps5_trackpad_hold", "nav_ps5_trackpad_left", "nav_ps5_trackpad_leftright", "nav_ps5_trackpad_lefttoright", "nav_ps5_trackpad_press", "nav_ps5_trackpad_right", "nav_ps5_trackpad_up", "nav_ps5_trackpad_updown", "nav_ps5_trackpadoptions", "nav_ps5_triangle_hold_de", "nav_ps5_triangle_hold_en", "nav_ps5_triangle_hold_es", "nav_ps5_triangle_hold_fr", "nav_ps5_triangle_hold_greyedout_de", "nav_ps5_triangle_hold_greyedout_en", "nav_ps5_triangle_hold_greyedout_es", "nav_ps5_triangle_hold_greyedout_fr", "nav_ps5_triangle_hold_greyedout_jp", "nav_ps5_triangle_hold_greyedout_ru", "nav_ps5_triangle_hold_greyedout_zh", "nav_ps5_triangle_hold_greyedout", "nav_ps5_triangle_hold_jp", "nav_ps5_triangle_hold_ru", "nav_ps5_triangle_hold_zh", "nav_ps5_triangle_hold", "nav_ps5_triangle", "nav_ps5_trianglecircle", "nav_ps5_x_hold_de", "nav_ps5_x_hold_en", "nav_ps5_x_hold_es", "nav_ps5_x_hold_fr", "nav_ps5_x_hold_greyedout_de", "nav_ps5_x_hold_greyedout_en", "nav_ps5_x_hold_greyedout_es", "nav_ps5_x_hold_greyedout_fr", "nav_ps5_x_hold_greyedout_jp", "nav_ps5_x_hold_greyedout_ru", "nav_ps5_x_hold_greyedout_zh", "nav_ps5_x_hold_jp", "nav_ps5_x_hold_ru", "nav_ps5_x_hold_zh", "nav_ps5_x_hold", "nav_ps5_x",  },
        heron = Set{ "console_art_heron", "leftarrow_down", "nav_heron_a_hold_de", "nav_heron_a_hold_en", "nav_heron_a_hold_es", "nav_heron_a_hold_fr", "nav_heron_a_hold_greyedout_de", "nav_heron_a_hold_greyedout_en", "nav_heron_a_hold_greyedout_es", "nav_heron_a_hold_greyedout_fr", "nav_heron_a_hold_greyedout_jp", "nav_heron_a_hold_greyedout_ru", "nav_heron_a_hold_greyedout_zh", "nav_heron_a_hold_jp", "nav_heron_a_hold_ru", "nav_heron_a_hold_zh", "nav_heron_a_hold", "nav_heron_a", "nav_heron_b_hold_de", "nav_heron_b_hold_en", "nav_heron_b_hold_es", "nav_heron_b_hold_fr", "nav_heron_b_hold_greyedout_de", "nav_heron_b_hold_greyedout_en", "nav_heron_b_hold_greyedout_es", "nav_heron_b_hold_greyedout_fr", "nav_heron_b_hold_greyedout_jp", "nav_heron_b_hold_greyedout_ru", "nav_heron_b_hold_greyedout_zh", "nav_heron_b_hold_jp", "nav_heron_b_hold_ru", "nav_heron_b_hold_zh", "nav_heron_b_hold", "nav_heron_b", "nav_heron_dpad_down_hold_de", "nav_heron_dpad_down_hold_en", "nav_heron_dpad_down_hold_es", "nav_heron_dpad_down_hold_fr", "nav_heron_dpad_down_hold_greyedout_de", "nav_heron_dpad_down_hold_greyedout_en", "nav_heron_dpad_down_hold_greyedout_es", "nav_heron_dpad_down_hold_greyedout_fr", "nav_heron_dpad_down_hold_greyedout_jp", "nav_heron_dpad_down_hold_greyedout_ru", "nav_heron_dpad_down_hold_greyedout_zh", "nav_heron_dpad_down_hold_jp", "nav_heron_dpad_down_hold_ru", "nav_heron_dpad_down_hold_zh", "nav_heron_dpad_down_hold", "nav_heron_dpad_left_hold_de", "nav_heron_dpad_left_hold_en", "nav_heron_dpad_left_hold_es", "nav_heron_dpad_left_hold_fr", "nav_heron_dpad_left_hold_greyedout_de", "nav_heron_dpad_left_hold_greyedout_en", "nav_heron_dpad_left_hold_greyedout_es", "nav_heron_dpad_left_hold_greyedout_fr", "nav_heron_dpad_left_hold_greyedout_jp", "nav_heron_dpad_left_hold_greyedout_ru", "nav_heron_dpad_left_hold_greyedout_zh", "nav_heron_dpad_left_hold_jp", "nav_heron_dpad_left_hold_ru", "nav_heron_dpad_left_hold_zh", "nav_heron_dpad_left_hold", "nav_heron_dpad_right_hold_de", "nav_heron_dpad_right_hold_en", "nav_heron_dpad_right_hold_es", "nav_heron_dpad_right_hold_fr", "nav_heron_dpad_right_hold_greyedout_de", "nav_heron_dpad_right_hold_greyedout_en", "nav_heron_dpad_right_hold_greyedout_es", "nav_heron_dpad_right_hold_greyedout_fr", "nav_heron_dpad_right_hold_greyedout_jp", "nav_heron_dpad_right_hold_greyedout_ru", "nav_heron_dpad_right_hold_greyedout_zh", "nav_heron_dpad_right_hold_jp", "nav_heron_dpad_right_hold_ru", "nav_heron_dpad_right_hold_zh", "nav_heron_dpad_right_hold", "nav_heron_dpad_up_hold_de", "nav_heron_dpad_up_hold_en", "nav_heron_dpad_up_hold_es", "nav_heron_dpad_up_hold_fr", "nav_heron_dpad_up_hold_greyedout_de", "nav_heron_dpad_up_hold_greyedout_en", "nav_heron_dpad_up_hold_greyedout_es", "nav_heron_dpad_up_hold_greyedout_fr", "nav_heron_dpad_up_hold_greyedout_jp", "nav_heron_dpad_up_hold_greyedout_ru", "nav_heron_dpad_up_hold_greyedout_zh", "nav_heron_dpad_up_hold_jp", "nav_heron_dpad_up_hold_ru", "nav_heron_dpad_up_hold_zh", "nav_heron_dpad_up_hold", "nav_heron_dpad", "nav_heron_dpaddown_hold_rs", "nav_heron_dpaddown", "nav_heron_dpadleft", "nav_heron_dpadright", "nav_heron_dpadrightb", "nav_heron_dpadup", "nav_heron_hold_l2_press_r2_de", "nav_heron_hold_l2_press_r2_en", "nav_heron_hold_l2_press_r2_es", "nav_heron_hold_l2_press_r2_fr", "nav_heron_hold_l2_press_r2_jp", "nav_heron_hold_l2_press_r2_ru", "nav_heron_hold_l2_press_r2_zh", "nav_heron_hold_l2_press_r2", "nav_heron_l1", "nav_heron_l1a", "nav_heron_l1b", "nav_heron_l1dpaddown", "nav_heron_l1dpadleft", "nav_heron_l1r1", "nav_heron_l1r2", "nav_heron_l1rs_press", "nav_heron_l1rs_right", "nav_heron_l1x", "nav_heron_l1y", "nav_heron_l2_dim", "nav_heron_l2", "nav_heron_l2a", "nav_heron_l2b", "nav_heron_l2r2", "nav_heron_l2x", "nav_heron_l2y", "nav_heron_l3_press", "nav_heron_l3", "nav_heron_l3r3_click", "nav_heron_l3r3_press", "nav_heron_l3r3", "nav_heron_left_shoulder_hold_de", "nav_heron_left_shoulder_hold_en", "nav_heron_left_shoulder_hold_es", "nav_heron_left_shoulder_hold_fr", "nav_heron_left_shoulder_hold_greyedout_de", "nav_heron_left_shoulder_hold_greyedout_en", "nav_heron_left_shoulder_hold_greyedout_es", "nav_heron_left_shoulder_hold_greyedout_fr", "nav_heron_left_shoulder_hold_greyedout_jp", "nav_heron_left_shoulder_hold_greyedout_ru", "nav_heron_left_shoulder_hold_greyedout_zh", "nav_heron_left_shoulder_hold_jp", "nav_heron_left_shoulder_hold_ru", "nav_heron_left_shoulder_hold_zh", "nav_heron_left_shoulder_hold", "nav_heron_left_trigger_hold_de", "nav_heron_left_trigger_hold_en", "nav_heron_left_trigger_hold_es", "nav_heron_left_trigger_hold_fr", "nav_heron_left_trigger_hold_greyedout_de", "nav_heron_left_trigger_hold_greyedout_en", "nav_heron_left_trigger_hold_greyedout_es", "nav_heron_left_trigger_hold_greyedout_fr", "nav_heron_left_trigger_hold_greyedout_jp", "nav_heron_left_trigger_hold_greyedout_ru", "nav_heron_left_trigger_hold_greyedout_zh", "nav_heron_left_trigger_hold_jp", "nav_heron_left_trigger_hold_ru", "nav_heron_left_trigger_hold_zh", "nav_heron_left_trigger_hold", "nav_heron_leftarrowrightarrow", "nav_heron_ls_down", "nav_heron_ls_hold_de", "nav_heron_ls_hold_en", "nav_heron_ls_hold_es", "nav_heron_ls_hold_fr", "nav_heron_ls_hold_greyedout_de", "nav_heron_ls_hold_greyedout_en", "nav_heron_ls_hold_greyedout_es", "nav_heron_ls_hold_greyedout_fr", "nav_heron_ls_hold_greyedout_jp", "nav_heron_ls_hold_greyedout_ru", "nav_heron_ls_hold_greyedout_zh", "nav_heron_ls_hold_jp", "nav_heron_ls_hold_ru", "nav_heron_ls_hold_zh", "nav_heron_ls_hold", "nav_heron_ls_left", "nav_heron_ls_right", "nav_heron_ls_scroll", "nav_heron_ls_slide_scroll", "nav_heron_ls_slide", "nav_heron_ls_up", "nav_heron_ls", "nav_heron_lsrs", "nav_heron_menu_button_hold_de", "nav_heron_menu_button_hold_en", "nav_heron_menu_button_hold_es", "nav_heron_menu_button_hold_fr", "nav_heron_menu_button_hold_greyedout_de", "nav_heron_menu_button_hold_greyedout_en", "nav_heron_menu_button_hold_greyedout_es", "nav_heron_menu_button_hold_greyedout_fr", "nav_heron_menu_button_hold_greyedout_jp", "nav_heron_menu_button_hold_greyedout_ru", "nav_heron_menu_button_hold_greyedout_zh", "nav_heron_menu_button_hold_jp", "nav_heron_menu_button_hold_ru", "nav_heron_menu_button_hold_zh", "nav_heron_menu_button_hold", "nav_heron_r1", "nav_heron_r1a", "nav_heron_r1b", "nav_heron_r1x", "nav_heron_r1y", "nav_heron_r2_dim", "nav_heron_r2", "nav_heron_r3", "nav_heron_right_shoulder_hold_de", "nav_heron_right_shoulder_hold_en", "nav_heron_right_shoulder_hold_es", "nav_heron_right_shoulder_hold_fr", "nav_heron_right_shoulder_hold_greyedout_de", "nav_heron_right_shoulder_hold_greyedout_en", "nav_heron_right_shoulder_hold_greyedout_es", "nav_heron_right_shoulder_hold_greyedout_fr", "nav_heron_right_shoulder_hold_greyedout_jp", "nav_heron_right_shoulder_hold_greyedout_ru", "nav_heron_right_shoulder_hold_greyedout_zh", "nav_heron_right_shoulder_hold_jp", "nav_heron_right_shoulder_hold_ru", "nav_heron_right_shoulder_hold_zh", "nav_heron_right_shoulder_hold", "nav_heron_right_trigger_hold_de", "nav_heron_right_trigger_hold_en", "nav_heron_right_trigger_hold_es", "nav_heron_right_trigger_hold_fr", "nav_heron_right_trigger_hold_greyedout_de", "nav_heron_right_trigger_hold_greyedout_en", "nav_heron_right_trigger_hold_greyedout_es", "nav_heron_right_trigger_hold_greyedout_fr", "nav_heron_right_trigger_hold_greyedout_jp", "nav_heron_right_trigger_hold_greyedout_ru", "nav_heron_right_trigger_hold_greyedout_zh", "nav_heron_right_trigger_hold_jp", "nav_heron_right_trigger_hold_ru", "nav_heron_right_trigger_hold_zh", "nav_heron_right_trigger_hold", "nav_heron_rs_down", "nav_heron_rs_hold_de", "nav_heron_rs_hold_en", "nav_heron_rs_hold_es", "nav_heron_rs_hold_fr", "nav_heron_rs_hold_greyedout_de", "nav_heron_rs_hold_greyedout_en", "nav_heron_rs_hold_greyedout_es", "nav_heron_rs_hold_greyedout_fr", "nav_heron_rs_hold_greyedout_jp", "nav_heron_rs_hold_greyedout_ru", "nav_heron_rs_hold_greyedout_zh", "nav_heron_rs_hold_jp", "nav_heron_rs_hold_ru", "nav_heron_rs_hold_zh", "nav_heron_rs_hold", "nav_heron_rs_left", "nav_heron_rs_menu", "nav_heron_rs_right", "nav_heron_rs_scroll", "nav_heron_rs_slide_scroll", "nav_heron_rs_slide", "nav_heron_rs_up", "nav_heron_rs", "nav_heron_view_button_hold_de", "nav_heron_view_button_hold_en", "nav_heron_view_button_hold_es", "nav_heron_view_button_hold_fr", "nav_heron_view_button_hold_greyedout_de", "nav_heron_view_button_hold_greyedout_en", "nav_heron_view_button_hold_greyedout_es", "nav_heron_view_button_hold_greyedout_fr", "nav_heron_view_button_hold_greyedout_jp", "nav_heron_view_button_hold_greyedout_ru", "nav_heron_view_button_hold_greyedout_zh", "nav_heron_view_button_hold_jp", "nav_heron_view_button_hold_ru", "nav_heron_view_button_hold_zh", "nav_heron_view_button_hold", "nav_heron_view", "nav_heron_x_hold_de", "nav_heron_x_hold_en", "nav_heron_x_hold_es", "nav_heron_x_hold_fr", "nav_heron_x_hold_greyedout_de", "nav_heron_x_hold_greyedout_en", "nav_heron_x_hold_greyedout_es", "nav_heron_x_hold_greyedout_fr", "nav_heron_x_hold_greyedout_jp", "nav_heron_x_hold_greyedout_ru", "nav_heron_x_hold_greyedout_zh", "nav_heron_x_hold_jp", "nav_heron_x_hold_ru", "nav_heron_x_hold_zh", "nav_heron_x_hold", "nav_heron_x", "nav_heron_y_hold_de", "nav_heron_y_hold_en", "nav_heron_y_hold_es", "nav_heron_y_hold_fr", "nav_heron_y_hold_greyedout_de", "nav_heron_y_hold_greyedout_en", "nav_heron_y_hold_greyedout_es", "nav_heron_y_hold_greyedout_fr", "nav_heron_y_hold_greyedout_jp", "nav_heron_y_hold_greyedout_ru", "nav_heron_y_hold_greyedout_zh", "nav_heron_y_hold_jp", "nav_heron_y_hold_ru", "nav_heron_y_hold_zh", "nav_heron_y_hold", "nav_heron_y", "nav_heron_yb", "rightarrow_down",  },
        stadia_ps4 = Set{ "console_art_stadiaps4_notouchpad", "console_art_stadiaps4", "nav_stadiaps4_circle_hold_de", "nav_stadiaps4_circle_hold_en", "nav_stadiaps4_circle_hold_es", "nav_stadiaps4_circle_hold_fr", "nav_stadiaps4_circle_hold_greyedout_de", "nav_stadiaps4_circle_hold_greyedout_en", "nav_stadiaps4_circle_hold_greyedout_es", "nav_stadiaps4_circle_hold_greyedout_fr", "nav_stadiaps4_circle_hold_greyedout_jp", "nav_stadiaps4_circle_hold_greyedout_ru", "nav_stadiaps4_circle_hold_greyedout_zh", "nav_stadiaps4_circle_hold_jp", "nav_stadiaps4_circle_hold_ru", "nav_stadiaps4_circle_hold_zh", "nav_stadiaps4_circle_hold", "nav_stadiaps4_circle", "nav_stadiaps4_dpad_down_hold_de", "nav_stadiaps4_dpad_down_hold_en", "nav_stadiaps4_dpad_down_hold_es", "nav_stadiaps4_dpad_down_hold_fr", "nav_stadiaps4_dpad_down_hold_greyedout_de", "nav_stadiaps4_dpad_down_hold_greyedout_en", "nav_stadiaps4_dpad_down_hold_greyedout_es", "nav_stadiaps4_dpad_down_hold_greyedout_fr", "nav_stadiaps4_dpad_down_hold_greyedout_jp", "nav_stadiaps4_dpad_down_hold_greyedout_ru", "nav_stadiaps4_dpad_down_hold_greyedout_zh", "nav_stadiaps4_dpad_down_hold_jp", "nav_stadiaps4_dpad_down_hold_ru", "nav_stadiaps4_dpad_down_hold_zh", "nav_stadiaps4_dpad_down_hold", "nav_stadiaps4_dpad_left_hold_de", "nav_stadiaps4_dpad_left_hold_en", "nav_stadiaps4_dpad_left_hold_es", "nav_stadiaps4_dpad_left_hold_fr", "nav_stadiaps4_dpad_left_hold_greyedout_de", "nav_stadiaps4_dpad_left_hold_greyedout_en", "nav_stadiaps4_dpad_left_hold_greyedout_es", "nav_stadiaps4_dpad_left_hold_greyedout_fr", "nav_stadiaps4_dpad_left_hold_greyedout_jp", "nav_stadiaps4_dpad_left_hold_greyedout_ru", "nav_stadiaps4_dpad_left_hold_greyedout_zh", "nav_stadiaps4_dpad_left_hold_jp", "nav_stadiaps4_dpad_left_hold_ru", "nav_stadiaps4_dpad_left_hold_zh", "nav_stadiaps4_dpad_left_hold", "nav_stadiaps4_dpad_right_hold_de", "nav_stadiaps4_dpad_right_hold_en", "nav_stadiaps4_dpad_right_hold_es", "nav_stadiaps4_dpad_right_hold_fr", "nav_stadiaps4_dpad_right_hold_greyedout_de", "nav_stadiaps4_dpad_right_hold_greyedout_en", "nav_stadiaps4_dpad_right_hold_greyedout_es", "nav_stadiaps4_dpad_right_hold_greyedout_fr", "nav_stadiaps4_dpad_right_hold_greyedout_jp", "nav_stadiaps4_dpad_right_hold_greyedout_ru", "nav_stadiaps4_dpad_right_hold_greyedout_zh", "nav_stadiaps4_dpad_right_hold_jp", "nav_stadiaps4_dpad_right_hold_ru", "nav_stadiaps4_dpad_right_hold_zh", "nav_stadiaps4_dpad_right_hold", "nav_stadiaps4_dpad_up_hold_de", "nav_stadiaps4_dpad_up_hold_en", "nav_stadiaps4_dpad_up_hold_es", "nav_stadiaps4_dpad_up_hold_fr", "nav_stadiaps4_dpad_up_hold_greyedout_de", "nav_stadiaps4_dpad_up_hold_greyedout_en", "nav_stadiaps4_dpad_up_hold_greyedout_es", "nav_stadiaps4_dpad_up_hold_greyedout_fr", "nav_stadiaps4_dpad_up_hold_greyedout_jp", "nav_stadiaps4_dpad_up_hold_greyedout_ru", "nav_stadiaps4_dpad_up_hold_greyedout_zh", "nav_stadiaps4_dpad_up_hold_jp", "nav_stadiaps4_dpad_up_hold_ru", "nav_stadiaps4_dpad_up_hold_zh", "nav_stadiaps4_dpad_up_hold", "nav_stadiaps4_dpad", "nav_stadiaps4_dpaddown_hold_rs", "nav_stadiaps4_dpaddown", "nav_stadiaps4_dpadleft", "nav_stadiaps4_dpadright", "nav_stadiaps4_dpadrightcircle", "nav_stadiaps4_dpadup", "nav_stadiaps4_hold_l2_press_r2_de", "nav_stadiaps4_hold_l2_press_r2_en", "nav_stadiaps4_hold_l2_press_r2_es", "nav_stadiaps4_hold_l2_press_r2_fr", "nav_stadiaps4_hold_l2_press_r2_jp", "nav_stadiaps4_hold_l2_press_r2_ru", "nav_stadiaps4_hold_l2_press_r2_zh", "nav_stadiaps4_hold_l2_press_r2", "nav_stadiaps4_l1", "nav_stadiaps4_l1circle", "nav_stadiaps4_l1dpaddown", "nav_stadiaps4_l1dpadleft", "nav_stadiaps4_l1r1", "nav_stadiaps4_l1r2", "nav_stadiaps4_l1rs_press", "nav_stadiaps4_l1rs_right", "nav_stadiaps4_l1square", "nav_stadiaps4_l1triangle", "nav_stadiaps4_l1x", "nav_stadiaps4_l2_dim", "nav_stadiaps4_l2", "nav_stadiaps4_l2circle", "nav_stadiaps4_l2r2", "nav_stadiaps4_l2square", "nav_stadiaps4_l2triangle", "nav_stadiaps4_l2x", "nav_stadiaps4_left_shoulder_hold_de", "nav_stadiaps4_left_shoulder_hold_en", "nav_stadiaps4_left_shoulder_hold_es", "nav_stadiaps4_left_shoulder_hold_fr", "nav_stadiaps4_left_shoulder_hold_greyedout_de", "nav_stadiaps4_left_shoulder_hold_greyedout_en", "nav_stadiaps4_left_shoulder_hold_greyedout_es", "nav_stadiaps4_left_shoulder_hold_greyedout_fr", "nav_stadiaps4_left_shoulder_hold_greyedout_jp", "nav_stadiaps4_left_shoulder_hold_greyedout_ru", "nav_stadiaps4_left_shoulder_hold_greyedout_zh", "nav_stadiaps4_left_shoulder_hold_jp", "nav_stadiaps4_left_shoulder_hold_ru", "nav_stadiaps4_left_shoulder_hold_zh", "nav_stadiaps4_left_shoulder_hold", "nav_stadiaps4_left_trigger_hold_de", "nav_stadiaps4_left_trigger_hold_en", "nav_stadiaps4_left_trigger_hold_es", "nav_stadiaps4_left_trigger_hold_fr", "nav_stadiaps4_left_trigger_hold_greyedout_de", "nav_stadiaps4_left_trigger_hold_greyedout_en", "nav_stadiaps4_left_trigger_hold_greyedout_es", "nav_stadiaps4_left_trigger_hold_greyedout_fr", "nav_stadiaps4_left_trigger_hold_greyedout_jp", "nav_stadiaps4_left_trigger_hold_greyedout_ru", "nav_stadiaps4_left_trigger_hold_greyedout_zh", "nav_stadiaps4_left_trigger_hold_jp", "nav_stadiaps4_left_trigger_hold_ru", "nav_stadiaps4_left_trigger_hold_zh", "nav_stadiaps4_left_trigger_hold", "nav_stadiaps4_ls_click", "nav_stadiaps4_ls_down", "nav_stadiaps4_ls_hold_de", "nav_stadiaps4_ls_hold_en", "nav_stadiaps4_ls_hold_es", "nav_stadiaps4_ls_hold_fr", "nav_stadiaps4_ls_hold_jp", "nav_stadiaps4_ls_hold_ru", "nav_stadiaps4_ls_hold_zh", "nav_stadiaps4_ls_hold", "nav_stadiaps4_ls_left", "nav_stadiaps4_ls_press", "nav_stadiaps4_ls_right", "nav_stadiaps4_ls_scroll", "nav_stadiaps4_ls_slide_scroll", "nav_stadiaps4_ls_slide", "nav_stadiaps4_ls_up", "nav_stadiaps4_ls", "nav_stadiaps4_lsrs_click", "nav_stadiaps4_lsrs_press", "nav_stadiaps4_lsrs", "nav_stadiaps4_options_hold", "nav_stadiaps4_options", "nav_stadiaps4_r1", "nav_stadiaps4_r1circle", "nav_stadiaps4_r1square", "nav_stadiaps4_r1triangle", "nav_stadiaps4_r1x", "nav_stadiaps4_r2_dim", "nav_stadiaps4_r2", "nav_stadiaps4_right_shoulder_hold_de", "nav_stadiaps4_right_shoulder_hold_en", "nav_stadiaps4_right_shoulder_hold_es", "nav_stadiaps4_right_shoulder_hold_fr", "nav_stadiaps4_right_shoulder_hold_greyedout_de", "nav_stadiaps4_right_shoulder_hold_greyedout_en", "nav_stadiaps4_right_shoulder_hold_greyedout_es", "nav_stadiaps4_right_shoulder_hold_greyedout_fr", "nav_stadiaps4_right_shoulder_hold_greyedout_jp", "nav_stadiaps4_right_shoulder_hold_greyedout_ru", "nav_stadiaps4_right_shoulder_hold_greyedout_zh", "nav_stadiaps4_right_shoulder_hold_jp", "nav_stadiaps4_right_shoulder_hold_ru", "nav_stadiaps4_right_shoulder_hold_zh", "nav_stadiaps4_right_shoulder_hold", "nav_stadiaps4_right_trigger_hold_de", "nav_stadiaps4_right_trigger_hold_en", "nav_stadiaps4_right_trigger_hold_es", "nav_stadiaps4_right_trigger_hold_fr", "nav_stadiaps4_right_trigger_hold_greyedout_de", "nav_stadiaps4_right_trigger_hold_greyedout_en", "nav_stadiaps4_right_trigger_hold_greyedout_es", "nav_stadiaps4_right_trigger_hold_greyedout_fr", "nav_stadiaps4_right_trigger_hold_greyedout_jp", "nav_stadiaps4_right_trigger_hold_greyedout_ru", "nav_stadiaps4_right_trigger_hold_greyedout_zh", "nav_stadiaps4_right_trigger_hold_jp", "nav_stadiaps4_right_trigger_hold_ru", "nav_stadiaps4_right_trigger_hold_zh", "nav_stadiaps4_right_trigger_hold", "nav_stadiaps4_rs_click", "nav_stadiaps4_rs_down", "nav_stadiaps4_rs_hold_de", "nav_stadiaps4_rs_hold_en", "nav_stadiaps4_rs_hold_es", "nav_stadiaps4_rs_hold_fr", "nav_stadiaps4_rs_hold_jp", "nav_stadiaps4_rs_hold_ru", "nav_stadiaps4_rs_hold_zh", "nav_stadiaps4_rs_hold", "nav_stadiaps4_rs_left", "nav_stadiaps4_rs_press", "nav_stadiaps4_rs_right", "nav_stadiaps4_rs_scroll", "nav_stadiaps4_rs_slide_scroll", "nav_stadiaps4_rs_slide", "nav_stadiaps4_rs_up", "nav_stadiaps4_rs", "nav_stadiaps4_share_hold_de", "nav_stadiaps4_share_hold_en", "nav_stadiaps4_share_hold_es", "nav_stadiaps4_share_hold_fr", "nav_stadiaps4_share_hold_greyedout_de", "nav_stadiaps4_share_hold_greyedout_en", "nav_stadiaps4_share_hold_greyedout_es", "nav_stadiaps4_share_hold_greyedout_fr", "nav_stadiaps4_share_hold_greyedout_jp", "nav_stadiaps4_share_hold_greyedout_ru", "nav_stadiaps4_share_hold_greyedout_zh", "nav_stadiaps4_share_hold_jp", "nav_stadiaps4_share_hold_ru", "nav_stadiaps4_share_hold_zh", "nav_stadiaps4_share_hold", "nav_stadiaps4_share", "nav_stadiaps4_shareoptions", "nav_stadiaps4_square_hold_de", "nav_stadiaps4_square_hold_en", "nav_stadiaps4_square_hold_es", "nav_stadiaps4_square_hold_fr", "nav_stadiaps4_square_hold_greyedout_de", "nav_stadiaps4_square_hold_greyedout_en", "nav_stadiaps4_square_hold_greyedout_es", "nav_stadiaps4_square_hold_greyedout_fr", "nav_stadiaps4_square_hold_greyedout_jp", "nav_stadiaps4_square_hold_greyedout_ru", "nav_stadiaps4_square_hold_greyedout_zh", "nav_stadiaps4_square_hold_jp", "nav_stadiaps4_square_hold_ru", "nav_stadiaps4_square_hold_zh", "nav_stadiaps4_square_hold", "nav_stadiaps4_square", "nav_stadiaps4_touchpad_hold_de", "nav_stadiaps4_touchpad_hold_en", "nav_stadiaps4_touchpad_hold_es", "nav_stadiaps4_touchpad_hold_fr", "nav_stadiaps4_touchpad_hold_greyedout_de", "nav_stadiaps4_touchpad_hold_greyedout_en", "nav_stadiaps4_touchpad_hold_greyedout_es", "nav_stadiaps4_touchpad_hold_greyedout_fr", "nav_stadiaps4_touchpad_hold_greyedout_jp", "nav_stadiaps4_touchpad_hold_greyedout_ru", "nav_stadiaps4_touchpad_hold_greyedout_zh", "nav_stadiaps4_touchpad_hold_jp", "nav_stadiaps4_touchpad_hold_ru", "nav_stadiaps4_touchpad_hold_zh", "nav_stadiaps4_touchpad_hold", "nav_stadiaps4_trackpad_circle", "nav_stadiaps4_trackpad_down", "nav_stadiaps4_trackpad_hold", "nav_stadiaps4_trackpad_left", "nav_stadiaps4_trackpad_leftright", "nav_stadiaps4_trackpad_lefttoright", "nav_stadiaps4_trackpad_press", "nav_stadiaps4_trackpad_right", "nav_stadiaps4_trackpad_up", "nav_stadiaps4_trackpad_updown", "nav_stadiaps4_trackpadoptions", "nav_stadiaps4_triangle_hold_de", "nav_stadiaps4_triangle_hold_en", "nav_stadiaps4_triangle_hold_es", "nav_stadiaps4_triangle_hold_fr", "nav_stadiaps4_triangle_hold_greyedout_de", "nav_stadiaps4_triangle_hold_greyedout_en", "nav_stadiaps4_triangle_hold_greyedout_es", "nav_stadiaps4_triangle_hold_greyedout_fr", "nav_stadiaps4_triangle_hold_greyedout_jp", "nav_stadiaps4_triangle_hold_greyedout_ru", "nav_stadiaps4_triangle_hold_greyedout_zh", "nav_stadiaps4_triangle_hold_jp", "nav_stadiaps4_triangle_hold_ru", "nav_stadiaps4_triangle_hold_zh", "nav_stadiaps4_triangle_hold", "nav_stadiaps4_triangle", "nav_stadiaps4_trianglecircle", "nav_stadiaps4_x_hold_de", "nav_stadiaps4_x_hold_en", "nav_stadiaps4_x_hold_es", "nav_stadiaps4_x_hold_fr", "nav_stadiaps4_x_hold_greyedout_de", "nav_stadiaps4_x_hold_greyedout_en", "nav_stadiaps4_x_hold_greyedout_es", "nav_stadiaps4_x_hold_greyedout_fr", "nav_stadiaps4_x_hold_greyedout_jp", "nav_stadiaps4_x_hold_greyedout_ru", "nav_stadiaps4_x_hold_greyedout_zh", "nav_stadiaps4_x_hold_jp", "nav_stadiaps4_x_hold_ru", "nav_stadiaps4_x_hold_zh", "nav_stadiaps4_x_hold", "nav_stadiaps4_x",  },
    },

    platform_desc   = {"Xbox One", "Xbox Series X||S", "Switch Pro", "DualShock 4", "DualSense", "Stadia", "Stadia on PlayStation"},
    -- /esoui/art/buttons/gamepad/xbox/nav_xbone_a_hold.dds
    texture_path_prefix = "/esoui/art/buttons/gamepad/",
    -- used in texture path
    texture_path_platform_list = {"xbox", "scarlett", "switchpro", "ps4", "ps5", "heron", "stadia_ps4"},
    -- used in filenames
    texture_name_platform_list   = {"xbone", "scarlett", "switchpro", "ps4", "ps5", "heron", "stadiaps4"},

    xbox_button_map = {
        console_art_xb1 = {
            scarlett = "console_art_scarlett",
            switchpro = "console_art_switchpro_agnostic",
            ps4 = "console_art_ps4",
            ps5 = "console_art_ps5",
            heron = "console_art_heron",
            stadia_ps4 = "console_art_stadiaps4_notouchpad"
        },
        leftarrow_down = {
            ps4 = "nav_ps4_trackpad_press",
            ps5 = "nav_ps5_broadcast",
            stadia_ps4 = "nav_stadiaps4_share"
        },
        a = {
            ps4 = "x",
            ps5 = "x",
            stadia_ps4 = "x"
        },
        b = {
            ps4 = "circle",
            ps5 = "circle",
            stadia_ps4 = "circle"
        },
        dpad_down_hold = {},
        dpad_left_hold = {},
        dpad_right_hold = {},
        dpad_up_hold = {},
        dpad = {},
        dpaddown_hold_rs = {},
        dpaddown = {},
        dpadleft = {},
        dpadright = {},
        dpadrightb = {
            ps4 = "dpadrightcircle",
            ps5 = "dpadrightcircle",
            stadia_ps4 = "dpadrightcircle"
        },
        dpadup = {},
        -- du = {},
        hold_lt_press_rt = {
            switchpro = "hold_zl_press_zr",
            ps4 = "hold_l2_press_r2",
            ps5 = "hold_l2_press_r2",
            heron = "hold_l2_press_r2",
            stadia_ps4 = "hold_l2_press_r2"
        },
        lb = {
            switchpro = "l",
            ps4 = "l1",
            ps5 = "l1",
            heron = "l1",
            stadia_ps4 = "l1"
        },
        lba = {
            switchpro = "la",
            ps4 = "l1x",
            ps5 = "l1x",
            heron = "l1a",
            stadia_ps4 = "l1x"
        },
        lbb = {
            scarlett = "nav_scarlett_lbb",
            switchpro = "lb",
            ps4 = "l1circle",
            ps5 = "l1circle",
            heron = "l1b",
            stadia_ps4 = "l1circle"
        },
        lbdpaddown = {
            switchpro = "ldpaddown",
            ps4 = "l1dpaddown",
            ps5 = "l1dpaddown",
            heron = "l1dpaddown",
            stadia_ps4 = "l1dpaddown"
        },
        lbdpadleft = {
            switchpro = "ldpadleft",
            ps4 = "l1dpadleft",
            ps5 = "l1dpadleft",
            heron = "l1dpadleft",
            stadia_ps4 = "l1dpadleft"
        },
        lbrb = {
            switchpro = "lr",
            ps4 = "l1r1",
            ps5 = "l1r1",
            heron = "l1r1",
            stadia_ps4 = "l1r1"
        },
        lbrs_press = {
            switchpro = "lrs_press",
            ps4 = "l1rs_press",
            ps5 = "l1rs_press",
            heron = "l1rs_press",
            stadia_ps4 = "l1rs_press"
        },
        lbrs_right = {
            switchpro = "lrs_right",
            ps4 = "l1rs_right",
            ps5 = "l1rs_right",
            heron = "l1rs_right",
            stadia_ps4 = "l1rs_right"
        },
        lbrt = {
            switchpro = "lzr",
            ps4 = "l1r2",
            ps5 = "l1r2",
            heron = "l1r2",
            stadia_ps4 = "l1r2"
        },
        lbx = {
            switchpro = "lx",
            ps4 = "l1square",
            ps5 = "l1square",
            heron = "l1x",
            stadia_ps4 = "l1square"
        },
        lby = {
            switchpro = "ly",
            ps4 = "l1triangle",
            ps5 = "l1triangle",
            heron = "l1y",
            stadia_ps4 = "l1triangle"
        },
        left_shoulder_hold = {},
        left_trigger_hold = {},
        leftarrowrightarrow = {
            ps4 = "trackpadoptions",
            ps5 = "broadcastoptions",
            stadia_ps4 = "shareoptions"
        },
        ls_click = {},
        ls_down = {},
        ls_left = {},
        ls_press = {},
        ls_right = {},
        ls_scroll = {},
        ls_slide_scroll = {},
        ls_slide = {},
        ls_up = {},
        ls = {},
        lsrs_click = {},
        lsrs_press = {},
        lsrs = {},
        lt_dim = {
            switchpro = "zl_dim",
            ps4 = "l2_dim",
            ps5 = "l2_dim",
            heron = "l2_dim",
            stadia_ps4 = "l2_dim"
        },
        lt = {
            switchpro = "zl",
            ps4 = "l2",
            ps5 = "l2",
            heron = "l2",
            stadia_ps4 = "l2"
        },
        lta = {
            switchpro = "zla",
            ps4 = "l2x",
            ps5 = "l2x",
            heron = "l2a",
            stadia_ps4 = "l2x"
        },
        ltb = {
            switchpro = "zlb",
            ps4 = "l2circle",
            ps5 = "l2circle",
            heron = "l2b",
            stadia_ps4 = "l2circle"
        },
        ltrt = {
            switchpro = "zlzr",
            ps4 = "l2r2",
            ps5 = "l2r2",
            heron = "l2r2",
            stadia_ps4 = "l2r2"
        },
        ltx = {
            switchpro = "zlx",
            ps4 = "l2square",
            ps5 = "l2square",
            heron = "l2x",
            stadia_ps4 = "l2square"
        },
        lty = {
            switchpro = "zly",
            ps4 = "l2triangle",
            ps5 = "l2triangle",
            heron = "l2y",
            stadia_ps4 = "l2triangle"
        },
        menu_button_hold = {
            switchpro = "plus_button_hold",
            ps4 = "options_hold",
            ps5 = "options_hold",
            stadia_ps4 = "options_hold" -- doesn't have localized textures
        },
        rb = {
            switchpro = "r",
            ps4 = "r1",
            ps5 = "r1",
            heron = "r1",
            stadia_ps4 = "r1"
        },
        rba = {
            switchpro = "ra",
            ps4 = "r1x",
            ps5 = "r1x",
            heron = "r1a",
            stadia_ps4 = "r1x"
        },
        rbb = {
            switchpro = "rb",
            ps4 = "r1circle",
            ps5 = "r1circle",
            heron = "r1b",
            stadia_ps4 = "r1circle"
        },
        rbx = {
            switchpro = "rx",
            ps4 = "r1square",
            ps5 = "r1square",
            heron = "r1x",
            stadia_ps4 = "r1square"
        },
        rby = {
            switchpro = "ry",
            ps4 = "r1triangle",
            ps5 = "r1triangle",
            heron = "r1y",
            stadia_ps4 = "r1triangle"
        },
        right_shoulder_hold = {},
        right_trigger_hold = {},
        rs_click = {},
        rs_down = {},
        rs_hold = {},
        rs_left = {},
        rs_menu = {
            switchpro = "rs_plus",
            ps4 = "options",
            ps5 = "options",
            stadia_ps4 = "options"
        },
        rs_press = {},
        rs_right = {},
        rs_scroll = {},
        rs_slide_scroll = {},
        rs_slide = {},
        rs_up = {},
        rs = {},
        rt_dim = {
            switchpro = "zr_dim",
            ps4 = "r2_dim",
            ps5 = "r2_dim",
            heron = "r2_dim",
            stadia_ps4 = "r2_dim"
        },
        rt = {
            switchpro = "zr",
            ps4 = "r2",
            ps5 = "r2",
            heron = "r2",
            stadia_ps4 = "r2"
        },
        view_button_hold = {
            switchpro = "minus_button_hold",
            ps4 = "touchpad_hold",
            ps5 = "broadcast_hold",
            stadia_ps4 = "share_hold"
        },
        view = {
            switchpro = "minus",
            ps4 = "trackpad_press",
            ps5 = "broadcast",
            stadia_ps4 = "share"
        },
        x = {
            ps4 = "square",
            ps5 = "square",
            stadia_ps4 = "square"
        },
        y = {
            ps4 = "triangle",
            ps5 = "triangle",
            stadia_ps4 = "triangle"
        },
        yb = {
            ps4 = "trianglecircle",
            ps5 = "trianglecircle",
            stadia_ps4 = "trianglecircle"
        },
        rightarrow_down = {
            ps4 = "nav_ps4_options",
            ps5 = "nav_ps5_options",
            stadia_ps4 = "nav_stadiaps4_options"
        },
    },

    generator = {
        -- try prefix nav_{platform}_
        -- try suffix _hold suffix, if exists
        -- for each hold try hold_XX and hold_greyedout_XX
        -- hold_lt_press_rt_XX
        prefixes = function(self, ui_platform1, ui_platform2)
            return {[""]="", ["nav_"..ui_platform1.."_"]="nav_"..ui_platform2.."_"}
        end,
        locales = {"en", "de", "es", "fr", "jp", "ru", "zh"},
        suffixes = function(self)
            local result = {}
            for _,s in ipairs({"", "_hold", "_hold_greyedout"}) do
                table.insert(result, s)
                for _,l in ipairs(self.locales) do
                    table.insert(result, s.."_"..l)
                end
            end
            return result
        end
    },

    GetCurrentPlatformDesc = function(self)
        return self.platform_desc[ZO_IndexOfElementInNumericallyIndexedTable(self.texture_path_platform_list, self.Settings.current_platform)]
    end,

    GenerateMap = function(self, platform)
        local texture_name_platform = self.texture_name_platform_list[ZO_IndexOfElementInNumericallyIndexedTable(self.texture_path_platform_list, platform)]
        local result = {}
        for k,v in pairs(self.xbox_button_map) do
            local o = v[platform]
            if (not o) then o = k end
            for pf,pt in pairs(self.generator:prefixes("xbone", texture_name_platform)) do
                for _,s in ipairs(self.generator:suffixes()) do
                    local src = pf..k..s
                    local dst = pt..o..s
                    if (self.valid_texture_names["xbox"][src] and self.valid_texture_names[platform][dst]) then
                        result[src] = dst
                    end
                end
            end
        end
        return result
    end,

    ChangeButtonsTo = function(self, platform)
        if (self.Settings.current_platform == platform) then
            return
        end

        if (self.Settings.current_platform ~= "xbox") then
            self:UnbindGlyphTextures()
            self.Settings.custom = false
        end

        if (platform ~= "xbox") then
            self:BindGlyphTextures(platform)
            self.Settings.custom = true
        end
    end,

    BindGlyphTextures = function(self, platform)
        for k,v in pairs(self:GenerateMap(platform)) do
            local src_path = self.texture_path_prefix.."xbox/"..k..".dds"
            local dst_path = self.texture_path_prefix..platform.."/"..v..".dds"
            RedirectTexture(src_path, dst_path)
        end
        self.Settings.current_platform = platform
    end,

    UnbindGlyphTextures = function(self)
        self:BindGlyphTextures("xbox")
    end,
}

function ButtonsManager:RegisterAddonSettings()
    local SettingsManager = LibHarvensAddonSettings or LibStub("LibHarvensAddonSettings-1.0")
    local options = {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = function()
            ButtonsManager:UnbindGlyphTextures()
        end,
    }
    local addonSettings = SettingsManager:AddAddon("Gamepad Button Glyphs", options)
    if not addonSettings then
        return
    end

    -- preview label
    local preview_prefix = "Preview for "..ButtonsManager:GetCurrentPlatformDesc()
    local preview_template = [[:


    |t128:64:/esoui/art/buttons/gamepad/xbox/nav_xbone_dpaddown_hold_rs.dds|t|t64:64:/esoui/art/buttons/gamepad/xbox/nav_xbone_a.dds|t|t64:64:/esoui/art/buttons/gamepad/xbox/nav_xbone_b.dds|t|t64:64:/esoui/art/buttons/gamepad/xbox/nav_xbone_x.dds|t|t64:64:/esoui/art/buttons/gamepad/xbox/nav_xbone_y.dds|t

    
    |t128:64:/esoui/art/buttons/gamepad/xbox/nav_xbone_lbrt.dds|t|t64:64:/esoui/art/buttons/gamepad/xbox/leftarrow_down.dds|t|t64:64:/esoui/art/buttons/gamepad/xbox/rightarrow_down.dds|t|t128:64:/esoui/art/buttons/gamepad/xbox/nav_xbone_lsrs_press.dds|t
    

    You may need to switch a few times to refresh the preview.]]
    local label = {
        type = SettingsManager.ST_LABEL,
        label = function()
            return preview_prefix..preview_template
        end,
    }
    -- combobox with mappings
    local dropdown = {
        type = SettingsManager.ST_DROPDOWN,
        label = "Button Style",
        tooltip = "Select the gamepad button style",
        setFunction = function(cb, name, item)
            ButtonsManager:ChangeButtonsTo(item.data)
            preview_prefix = "Preview for "..name
            addonSettings:UpdateControls()
            while label_updates < 2 do
                addonSettings:UpdateControls()
                label_updates = label_updates + 1
            end
        end,
        getFunction = function()
            return ButtonsManager:GetCurrentPlatformDesc()
        end,
        default = ButtonsManager.platform_desc[ZO_IndexOfElementInNumericallyIndexedTable(ButtonsManager.texture_path_platform_list, ButtonsManager.Defaults.current_platform)],
        items = {},
    }
    for i,v in ipairs(ButtonsManager.platform_desc) do
        table.insert(dropdown.items, {name=ButtonsManager.platform_desc[i], data=ButtonsManager.texture_path_platform_list[i]})
    end

    addonSettings:AddSettings({dropdown, label})
end

ButtonsManager.OnAddOnLoaded = function(event, addonName)
    if addonName ~= ButtonsManager.name then
        return
    end

    ButtonsManager.Settings = ZO_SavedVars:NewAccountWide("CustomGamepadButtonsVars", 1, nil, ButtonsManager.Defaults)
    d("[OnAddOnLoaded] settings: ")
    d(ButtonsManager.Settings)
    local platform = ButtonsManager.Settings.current_platform
    d("[OnAddOnLoaded] redirecting textures")
    if ButtonsManager.Settings.custom then
        ButtonsManager:BindGlyphTextures(platform)
    end
    d("[OnAddOnLoaded] registering addon settings")
    ButtonsManager:RegisterAddonSettings()
    EVENT_MANAGER:UnregisterForEvent(ButtonsManager.name, EVENT_ADD_ON_LOADED)
end


EVENT_MANAGER:RegisterForEvent(ButtonsManager.name, EVENT_ADD_ON_LOADED, ButtonsManager.OnAddOnLoaded)
