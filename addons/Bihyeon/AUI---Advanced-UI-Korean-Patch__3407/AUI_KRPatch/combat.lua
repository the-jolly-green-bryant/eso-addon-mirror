function AUI_KRPatch.setCombatFont(minimeterFontPath, scrollingTextFontPath)
  AUI.Settings.Combat.minimeter_font_art = minimeterFontPath
  AUI.Combat.Minimeter.UpdateUI()

  AUI.Settings.Combat.scrolling_text_damage_out_normal_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName)
  AUI.Settings.Combat.scrolling_text_damage_out_crit_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_out_crit_parent_panelName)
  AUI.Settings.Combat.scrolling_text_heal_out_normal_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_parent_panelName)
  AUI.Settings.Combat.scrolling_text_heal_out_crit_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_out_crit_parent_panelName)
  AUI.Settings.Combat.scrolling_text_damage_in_normal_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_parent_panelName)
  AUI.Settings.Combat.scrolling_text_damage_in_crit_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_damage_in_crit_parent_panelName)
  AUI.Settings.Combat.scrolling_text_heal_in_normal_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_parent_panelName)
  AUI.Settings.Combat.scrolling_text_heal_in_crit_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_heal_in_crit_parent_panelName)
  AUI.Settings.Combat.scrolling_text_exp_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_exp_parent_panelName)
  AUI.Settings.Combat.scrolling_text_cxp_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_cxp_parent_panelName)
  AUI.Settings.Combat.scrolling_text_telvar_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_telvar_parent_panelName)
  AUI.Settings.Combat.scrolling_text_ap_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_ap_parent_panelName)
  AUI.Settings.Combat.scrolling_text_combat_start_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_combat_start_parent_panelName)
  AUI.Settings.Combat.scrolling_text_combat_end_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_combat_end_panelName)
  AUI.Settings.Combat.scrolling_text_instant_cast_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_instant_cast_parent_panelName)
  AUI.Settings.Combat.scrolling_text_ultimate_ready_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_ultimate_ready_parent_panelName)
  AUI.Settings.Combat.scrolling_text_potion_ready_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_potion_ready_parent_panelName)
  AUI.Settings.Combat.scrolling_text_health_low_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_low_parent_panelName)
  AUI.Settings.Combat.scrolling_text_magicka_low_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_low_parent_panelName)
  AUI.Settings.Combat.scrolling_text_stamina_low_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_low_parent_panelName)
  AUI.Settings.Combat.scrolling_text_health_reg_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_reg_parent_panelName)
  AUI.Settings.Combat.scrolling_text_magicka_reg_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_reg_parent_panelName)
  AUI.Settings.Combat.scrolling_text_stamina_reg_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_reg_parent_panelName)
  AUI.Settings.Combat.scrolling_text_health_dereg_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_health_dereg_parent_panelName)
  AUI.Settings.Combat.scrolling_text_magicka_dereg_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_magicka_dereg_parent_panelName)
  AUI.Settings.Combat.scrolling_text_stamina_dereg_font_art = scrollingTextFontPath
  AUI.Combat.Text.UpdatePreview(AUI.Settings.Combat.scrolling_text_stamina_dereg_parent_panelName)
end