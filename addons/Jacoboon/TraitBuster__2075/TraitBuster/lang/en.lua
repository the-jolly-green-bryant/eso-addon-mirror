strings = {
  TBUST_TRAITBUSTER = "TraitBuster",
  TBUST_ACTIVATED = "Activated. Use %s for options.",
  TBUST_LONG_SINGULAR = "TraitBuster: 1 other item with the same researchable trait owned.",
  TBUST_SHORT_SINGULAR = "1 researchable dupe.",
  TBUST_LONG_PLURAL = "TraitBuster: %s other items with the same researchable trait owned.",
  TBUST_SHORT_PLURAL = "%s researchable dupes.",
  TBUST_SLASH_TBUST = "/tbust",
  TBUST_SLASH_ON = "on",
  TBUST_SLASH_OFF = "off",
  TBUST_SLASH_LONG = "long",
  TBUST_SLASH_SHORT = "short",
  TBUST_SLASH_GREET = "greet",
  TBUST_SLASH_DEFAULT = "default",
  TBUST_MENU_TITLE = " -=-=-= MAIN  MENU =-=-=-",
  TBUST_MENU_ON = "= Enables tooltips for this character. [DEFAULT]",
  TBUST_MENU_OFF = "= Disables tooltips for this character.",
  TBUST_MENU_LONG = "= Longer more descriptive tooltips. [DEFAULT]",
  TBUST_MENU_SHORT = "= Shorter more concise tooltips.",
  TBUST_MENU_GREET_ON = "= Enables the login greeting. [DEFAULT]",
  TBUST_MENU_GREET_OFF = "= Disables the login greeting.",
  TBUST_MENU_DEFAULT = "= Reset to default settings.",
  TBUST_MENU_SELECT_ON = "Tooltips enabled for this character.",
  TBUST_MENU_SELECT_OFF = "Tooltips disabled for this character.",
  TBUST_MENU_SELECT_LONG = "Tooltips will be longer and more descriptive.",
  TBUST_MENU_SELECT_SHORT = "Tooltips will be short and concise.",
  TBUST_MENU_SELECT_GREET_ON = "The login greeting will be shown.",
  TBUST_MENU_SELECT_GREET_OFF = "The login greeting will not be shown.",
  TBUST_MENU_SELECT_DEFAULT = "Default settings loaded."
}

if GetString(TBUST_TRAITBUSTER):len() == 0 then
  for key,value in pairs(strings) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
  end
end