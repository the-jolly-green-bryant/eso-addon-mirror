local ItemConditionAlert = {}
ItemConditionAlert = _G["ItemConditionAlert"]
ItemConditionAlert.enwordlib = {}

ItemConditionAlert.enwordlib = ZO_Object:Subclass()

function ItemConditionAlert.enwordlib:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function ItemConditionAlert.enwordlib:Initialize()

  self.valid = true --mark this wordlist as valid
  
  self.SETTINGS_HDR_SHOW                       = "Visibility"
  self.SETTINGS_LBL_SHOW_BTN                   = "Make visible"
  self.SETTINGS_DSCR_SHOW_BTN                  = "Per default Item Condition Alert is hidden when a menu is shown. Click here to make it visible for configuration purpose."
  self.SETTINGS_HDR_GENERAL                    = "General"
  self.SETTINGS_LBL_SHOWPERC_CHK               = "Show Percentage"
  self.SETTINGS_DSCR_SHOWPERC_CHK              = "Displays the items durability in percent within the icons."
  self.SETTINGS_LBL_THRESHOLD_CHK              = "Ignore thresholds"
  self.SETTINGS_DSCR_THRESHOLD_CHK             = "Displays all Items, independent of the configured threshold."
  self.SETTINGS_LBL_LAYOUT_DRP                 = "Layout"
  self.SETTINGS_DSCR_LAYOUT_DRP                = "Configure the layout of Item Condition Alert."
  self.SETTINGS_LBL_SCALE_SLD                  = "Scale %"
  self.SETTINGS_DSCR_SCALE_SLD                 = "Sets the scale of the alert icons"
  self.SETTINGS_LBL_ALPHA_SLD                  = "Standard Alpha %"
  self.SETTINGS_DSCR_ALPHA_SLD                 = "Sets the alpha value of the addon when the UI is is movement mode"
  self.SETTINGS_LBL_FADEALPHA_SLD              = "Cursormode Alpha %"
  self.SETTINGS_DSCR_FADEALPHA_SLD             = "Sets the alpha value of the addon when cursormode is active"
  
  self.SETTINGS_HDR_THRESHOLDS                 = "Thresholds"
  self.SETTINGS_DCSR_THRESHOLDS                = "You can configure the thresholds off when items should be shown. The sliders configure the lower bounds of the according range."
  self.SETTINGS_LBL_VISIBTHESHOLD_DRP          = "Armor visibility Threshold"
  self.SETTINGS_DSCR_VISIBTHRESHOLD_DRP        = "Configures the damage level from which on items shall be displayed"
  self.SETTINGS_LBL_WEAPONVISIBTHESHOLD_DRP    = "Weapon visibility Threshold"
  self.SETTINGS_DSCR_WEAPONVISIBTHRESHOLD_DRP  = "Configures the charge level from which on weapons shall be displayed"
  self.SETTINGS_LBL_OKTHESHOLD_SLD             = "OK"
  self.SETTINGS_DSCR_OKTHESHOLD_SLD            = "Defines the threshold above which items are marked as OK"
  self.SETTINGS_LBL_GOODTHESHOLD_SLD           = "GOOD"
  self.SETTINGS_DSCR_GOODTHESHOLD_SLD          = "Defines the threshold above which items are marked as GOOD"
  self.SETTINGS_LBL_MODTHESHOLD_SLD            = "MODERATE"
  self.SETTINGS_DSCR_MODTHESHOLD_SLD           = "Defines the threshold above which items are marked as MODERATE"
  
  self.SETTINGS_LBL_LOCK_BTN                   = "Lock/Unlock"
  self.SETTINGS_DSCR_LOCK_BTN                  = "Unlock the Item Condition Alert main frame makes it darker, and allows you to move it freely.\nWhen locked, it becomes transparent and access to the repair window is enabled."
  
  self.KEYBIND_SHOWADDON                       = "Show the addon"
  self.KEYBIND_TGL_THRESHOLD                   = "Toggle visibility of undamaged items"
  
  self.CMD_HELP                                = "This Help."
  self.CMD_LOCK                                = "Locks the position"
  self.CMD_UNLOCK                              = "Unlocks the position"
  self.CMD_PERCENT                             = "Toggles visibility of percentage values in items"
  self.CMD_THRESHOLD                           = "Toggles visibility of undamaged items"
  self.CMD_SHOW                                = "Makes the addon visible in menus where it is normally hidden."
  self.CMD_RESET                               = "Resets the addon to its default values"
  
end
