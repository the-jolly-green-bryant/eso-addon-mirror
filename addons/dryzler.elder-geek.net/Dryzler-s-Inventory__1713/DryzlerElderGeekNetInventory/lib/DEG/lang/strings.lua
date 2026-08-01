DEGLIB_STRINGS_VERSION = 1
DEGLIB_STRINGS_ADDSTRING = function(k,v)
  if EsoStrings[k] == nil then
    ZO_CreateStringId(k, v, DEGLIB_STRINGS_VERSION)
  else
    _G.SafeAddString(k, v, DEGLIB_STRINGS_VERSION)
  end
end

DEGLIB_STRINGS_ADDSTRING('SI_DEG_SI_SETTINGS_THIS_CHAR', "Settings for the current character")
DEGLIB_STRINGS_ADDSTRING('SI_DEG_SI_SETTINGS_ACCOUNTWIDE', "Settings for the whole account")
DEGLIB_STRINGS_ADDSTRING('SI_DEG_SI_SETTINGS_SCALE', "Scale / Size")
DEGLIB_STRINGS_ADDSTRING('SI_DEG_SI_SETTINGS_OPACITY', "Opacity")

DEGLIB_STRINGS_ADDSTRING('SI_DEG_SI_AD1_HEADER', "|cEFEBBEA message from|r |c3f95ffDryzler|r")
DEGLIB_STRINGS_ADDSTRING('SI_DEG_SI_LBL2_HEADER', "Thanks for using my addon(s). |cEFEBBE:)|r")
DEGLIB_STRINGS_ADDSTRING('SI_DEG_SI_LBL3_HEADER', "Also checkout my other projects:")

DEGLIB_STRINGS_ADDSTRING('SI_DEG_SI_AD2_HEADER', "|cEFEBBEA message from|r |c3f95ffDryzler|r")
DEGLIB_STRINGS_ADDSTRING('SI_DEG_SI_AD2_LBL2_HEADER', "Thanks for using my addons. |cEFEBBE:)|r")
DEGLIB_STRINGS_ADDSTRING('SI_DEG_SI_AD2_LBL3_HEADER', "Support me on ko-fi.com/dryzler, thanks!")
DEGLIB_STRINGS_ADDSTRING('SI_DEG_SI_AD2_LBL4_HEADER', "I would appreciate a small donation \nso that I can buy myself a coffee or \npay for my web server(s).")

