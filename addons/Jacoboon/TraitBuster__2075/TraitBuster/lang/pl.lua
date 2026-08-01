strings = {
  TBUST_TRAITBUSTER = "TraitBuster",
  TBUST_ACTIVATED = "Aktywowany. Użyj %s dla opcji.",
  TBUST_LONG_SINGULAR = "TraitBuster: 1 inny przedmiot z tą samą własnością, którą można zbadać.",
  TBUST_SHORT_SINGULAR = "1 możliwy do zbadania duplikat.",
  TBUST_LONG_PLURAL = "TraitBuster: %s innych przedmiotów o tej samej właściwości badawczej.",
  TBUST_SHORT_PLURAL = "%s możliwych do zbadania duplikatów.",
  TBUST_SLASH_TBUST = "/tbust",
  TBUST_SLASH_ON = "dziesięć",
  TBUST_SLASH_OFF = "wyłączony",
  TBUST_SLASH_LONG = "długi",
  TBUST_SLASH_SHORT = "krótki",
  TBUST_SLASH_GREET = "powitać",
  TBUST_SLASH_DEFAULT = "domyślny",
  TBUST_MENU_TITLE = " -=-=-= MENU GŁÓWNE =-=-=-",
  TBUST_MENU_ON = "= Włącza podpowiedzi dla tej postaci. [domyślny]",
  TBUST_MENU_OFF = "= Wyłącza podpowiedzi dla tej postaci.",
  TBUST_MENU_LONG = "= Dłuższe opisowe podpowiedzi. [domyślny]",
  TBUST_MENU_SHORT = "= Krótsze, bardziej zwięzłe podpowiedzi.",
  TBUST_MENU_GREET_ON = "= Włącza powitanie logowania. [domyślny]",
  TBUST_MENU_GREET_OFF = "= Powoduje wyłączenie powitania logowania.",
  TBUST_MENU_DEFAULT = "= Przywróć ustawienia domyślne.",
  TBUST_MENU_SELECT_ON = "Etykiety narzędzi włączone dla tej postaci.",
  TBUST_MENU_SELECT_OFF = "Etykiety narzędzi wyłączone dla tej postaci.",
  TBUST_MENU_SELECT_LONG = "Etykietki narzędzi będą dłuższe i bardziej opisowe.",
  TBUST_MENU_SELECT_SHORT = "Wskazówki na temat narzędzi będą krótkie i zwięzłe.",
  TBUST_MENU_SELECT_GREET_ON = "Zostanie wyświetlone powitanie logowania.",
  TBUST_MENU_SELECT_GREET_OFF = "Powitanie logowania nie będzie wyświetlane.",
  TBUST_MENU_SELECT_DEFAULT = "Załadowano ustawienia domyślne."
}

if GetString(TBUST_TRAITBUSTER):len() == 0 then
  for key,value in pairs(strings) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
  end
end