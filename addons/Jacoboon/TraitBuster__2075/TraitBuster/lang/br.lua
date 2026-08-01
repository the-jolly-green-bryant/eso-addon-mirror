strings = {
  TBUST_TRAITBUSTER = "TraçoBuster",
  TBUST_ACTIVATED = "Ativado. Use %s para opções.",
  TBUST_LONG_SINGULAR = "TraitBuster: 1 outro item com a mesma característica de pesquisa de propriedade.",
  TBUST_SHORT_SINGULAR = "1 duplicata pesquisável.",
  TBUST_LONG_PLURAL = "TraitBuster: %s outros itens com o mesmo traço de propriedade de propriedade.",
  TBUST_SHORT_PLURAL = "%s researchable dupes.",
  TBUST_SLASH_TBUST = "/tbust",
  TBUST_SLASH_ON = "dez",
  TBUST_SLASH_OFF = "fora",
  TBUST_SLASH_LONG = "longo",
  TBUST_SLASH_SHORT = "curto",
  TBUST_SLASH_GREET = "cumprimentar",
  TBUST_SLASH_DEFAULT = "padrão",
  TBUST_MENU_TITLE = " -=-=-= MENU PRINCIPAL =-=-=-",
  TBUST_MENU_ON = "= Ativa as dicas de ferramentas para esse caractere. [PADRÃO]",
  TBUST_MENU_OFF = "= Desativa as dicas de ferramentas para este caractere.",
  TBUST_MENU_LONG = "= Dicas de ferramentas mais descritivas. [PADRÃO]",
  TBUST_MENU_SHORT = "= Dicas de ferramentas mais concisas e mais curtas.",
  TBUST_MENU_GREET_ON = "= Ativa a saudação de login. [DEFAULT]",
  TBUST_MENU_GREET_OFF = "= Desativa a saudação de login.",
  TBUST_MENU_DEFAULT = "= Redefinir para as configurações padrão.",
  TBUST_MENU_SELECT_ON = "Dicas de ferramentas habilitadas para este caractere.",
  TBUST_MENU_SELECT_OFF = "Dicas de ferramentas desativadas para este caractere.",
  TBUST_MENU_SELECT_LONG = "As dicas de ferramentas serão mais longas e descritivas.",
  TBUST_MENU_SELECT_SHORT = "As dicas de ferramentas serão curtas e concisas.",
  TBUST_MENU_SELECT_GREET_ON = "A saudação de login será mostrada.",
  TBUST_MENU_SELECT_GREET_OFF = "A saudação de login não será mostrada.",
  TBUST_MENU_SELECT_DEFAULT = "Configurações padrão carregadas."
}

if GetString(TBUST_TRAITBUSTER):len() == 0 then
  for key,value in pairs(strings) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
  end
end