local ItemConditionAlert = {}
ItemConditionAlert = _G["ItemConditionAlert"]
ItemConditionAlert.dewordlib = {}

ItemConditionAlert.dewordlib = ZO_Object:Subclass()

function ItemConditionAlert.dewordlib:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function ItemConditionAlert.dewordlib:Initialize()

  self.valid = true --mark this wordlist as valid
  
  self.SETTINGS_HDR_SHOW                       = "Sichtbarkeit"
  self.SETTINGS_LBL_SHOW_BTN                   = "Einblenden"
  self.SETTINGS_HDR_GENERAL                    = "Allgemein"
  self.SETTINGS_DSCR_SHOW_BTN                  = "Standardm\195\164\195\159ig ist Item Condition Alert unsichtbar wenn ein Menu eingeblendet wird. Klicken sie hier um es f\195\188r die Konfiguration sichtbar zu machen."
  self.SETTINGS_LBL_SHOWPERC_CHK               = "Zeige Prozentwerte"
  self.SETTINGS_DSCR_SHOWPERC_CHK              = "Zeigt die Haltbarkeit der Gegenst\195\164nde in prozent an."
  self.SETTINGS_LBL_THRESHOLD_CHK              = "Grenzwerte ignorieren"
  self.SETTINGS_DSCR_THRESHOLD_CHK             = "Zeigt alle Gegenst\195\164nde unabh\195\164ngig von ihrer Haltbarkeit oder Ladung an."
  self.SETTINGS_LBL_LAYOUT_DRP                 = "Layout"
  self.SETTINGS_DSCR_LAYOUT_DRP                = "Konfiguriert das Layout von Item Condition Alert."
  self.SETTINGS_LBL_SCALE_SLD                  = "Skalierung %"
  self.SETTINGS_DSCR_SCALE_SLD                 = "Konfiguriert die Skalierug des Addons."
  self.SETTINGS_LBL_ALPHA_SLD                  = "Standart Alpha %"
  self.SETTINGS_DSCR_ALPHA_SLD                 = "Setzt den Alphawert des Addons wenn sich das Interface im Bewegungsmodus befindet."
  self.SETTINGS_LBL_FADEALPHA_SLD              = "Cursormode Alpha %"
  self.SETTINGS_DSCR_FADEALPHA_SLD             = "Setzt den Alphawert des Addons wenn sich das Interface im Cursormodus befindet."
  
  self.SETTINGS_HDR_THRESHOLDS                 = "Grenzwerte"
  self.SETTINGS_DCSR_THRESHOLDS                = "Hier konfigurieren sie die Grenzwerte ab denen Gegenst\195\164nde Angezeigt werden. \195\156ber die Schieberegler k\195\182nnen sie die unteren Grenzen des jeweiligen Bereiches einstellen."
  self.SETTINGS_LBL_VISIBTHESHOLD_DRP          = "R\195\188stungs-Sichtbarkeit"
  self.SETTINGS_DSCR_VISIBTHRESHOLD_DRP        = "Konfiguriert den Grenzwert ab dem Besch\195\164digte R\195\188stungsteile eingeblendet werden."
  self.SETTINGS_LBL_WEAPONVISIBTHESHOLD_DRP    = "Waffen-Sichtbarkeit"
  self.SETTINGS_DSCR_WEAPONVISIBTHRESHOLD_DRP  = "Konfiguriert den Grenzwert Waffen mit wenig Ladungen eingeblendet werden."
  self.SETTINGS_LBL_OKTHESHOLD_SLD             = "OK"
  self.SETTINGS_DSCR_OKTHESHOLD_SLD            = "Legt den Grenzwert fest \195\188ber dem Gegenst\195\164nde als OK markiert werden"
  self.SETTINGS_LBL_GOODTHESHOLD_SLD           = "GOOD"
  self.SETTINGS_DSCR_GOODTHESHOLD_SLD          = "Legt den Grenzwert fest \195\188ber dem Gegenst\195\164nde als GOOD markiert werden"
  self.SETTINGS_LBL_MODTHESHOLD_SLD            = "MODERATE"
  self.SETTINGS_DSCR_MODTHESHOLD_SLD           = "Legt den Grenzwert fest \195\188ber dem Gegenst\195\164nde als MODERATE markiert werden"
  
  self.SETTINGS_LBL_LOCK_BTN                   = "Sperren/Entsperren"
  self.SETTINGS_DSCR_LOCK_BTN                  = "Durch das Entsperren wird Item Condition Alert mit einem dunklen Hintergrund hinterlegt, und es ist m\195\182glich das Addon zu verschieben.\nWenn das Addon Gesperrt ist wird der Hintergrund unsichtbar, dass Addon kann nicht verschoben werden und das Reparaturfenster kann durch klicken eingeblendet werden."
  
  self.KEYBIND_SHOWADDON                       = "Addon einblenden"
  self.KEYBIND_TGL_THRESHOLD                   = "Sichtbarkeit unbesch\195\164digter Gegenst\195\164nde umschalten"
  
  self.CMD_HELP                                = "Diese \195\156bersicht"
  self.CMD_LOCK                                = "Sperrt die Position"
  self.CMD_UNLOCK                              = "Entsperrt die Position"
  self.CMD_PERCENT                            = "Schaltet die Anzeige der Haltbarkeit in Prozent an oder aus"
  self.CMD_THRESHOLD                           = "Schaltet die Anzeige von unbesch\195\164digten Gegenst\195\164nden an oder aus"
  self.CMD_SHOW                                = "Blendet das Addon in Men\195\188s ein in denen es normalerweise nicht sichtbar ist"
  self.CMD_RESET                               = "Setzt das Addon auf die Standardwerte zur\195\188ck"
  
end
