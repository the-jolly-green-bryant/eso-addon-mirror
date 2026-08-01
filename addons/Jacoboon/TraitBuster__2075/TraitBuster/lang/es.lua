strings = {
  TBUST_TRAITBUSTER = "TraitBuster",
  TBUST_ACTIVATED = "Activado. Use %s para las opciones.",
  TBUST_LONG_SINGULAR = "TraitBuster: 1 otro artículo con el mismo rasgo investigable.",
  TBUST_SHORT_SINGULAR = "1 duplicado investigable.",
  TBUST_LONG_PLURAL = "TraitBuster: %s otros artículos con el mismo rasgo investigable.",
  TBUST_SHORT_PLURAL = "%s engaños investigables.",
  TBUST_SLASH_TBUST = "/tbust",
  TBUST_SLASH_ON = "diez",
  TBUST_SLASH_OFF = "apagado",
  TBUST_SLASH_LONG = "largo",
  TBUST_SLASH_SHORT = "corto",
  TBUST_SLASH_GREET = "saludar",
  TBUST_SLASH_DEFAULT = "predeterminado",
  TBUST_MENU_TITLE = " -=-=-= MENÚ PRINCIPAL =-=-=-",
  TBUST_MENU_ON = "= Habilita información sobre herramientas para este personaje. [POR DEFECTO]",
  TBUST_MENU_OFF = "= Desactiva la información sobre herramientas para este personaje.",
  TBUST_MENU_LONG = "= Más información descriptiva más larga. [POR DEFECTO]",
  TBUST_MENU_SHORT = "= Más breve y más breve información sobre herramientas.",
  TBUST_MENU_GREET_ON = "= Habilita el saludo de inicio de sesión. [DEFAULT]",
  TBUST_MENU_GREET_OFF = "= Desactiva el saludo de inicio de sesión.",
  TBUST_MENU_DEFAULT = "= Restablecer la configuración predeterminada.",
  TBUST_MENU_SELECT_ON = "Información sobre herramientas habilitada para este personaje.",
  TBUST_MENU_SELECT_OFF = "Información sobre herramientas deshabilitada para este personaje.",
  TBUST_MENU_SELECT_LONG = "La información sobre herramientas será más larga y más descriptiva.",
  TBUST_MENU_SELECT_SHORT = "La información sobre herramientas será breve y concisa.",
  TBUST_MENU_SELECT_GREET_ON = "El saludo de inicio de sesión se mostrará.",
  TBUST_MENU_SELECT_GREET_OFF = "El saludo de inicio de sesión no se mostrará.",
  TBUST_MENU_SELECT_DEFAULT = "Configuraciones predeterminadas cargadas."
}

if GetString(TBUST_TRAITBUSTER):len() == 0 then
  for key,value in pairs(strings) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
  end
end