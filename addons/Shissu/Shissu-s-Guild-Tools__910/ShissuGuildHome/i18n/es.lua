-- Automatische Generierung
ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuGuildHome"] = {
  TITLE =           "Gremio: " .. GetString(SI_WINDOW_TITLE_GUILD_HOME),
  KIOSK =           "Tiempo hasta la próxima oferta del gremio de traficantes",
  KIOSK_TT =        "Muestra el tiempo hasta que el comerciante del PNJ cambia en la visión general del gremio. También muestra una ventana adicional con la siguiente información durante los últimos 15 minutos de la asignación del comerciante Última vez para la puja, fin de la puja, hora de reemplazar al vendedor.",

  LEFTTIME =        "Tiempo restante",
  
  TRADER =          "Guild NPC",
  NEWKIOSK =        "Nuevo distribuidor de",
  BIDEND =          "Fin de la subasta",
  REPLACE =         "Distribuidor de reemplazo de",        
  
  TEXT =            "DEINTEXTO",
  
  COLOR =           GetString(SI_GUILD_HERALDRY_COLOR),       -- Farbe
  COLOR_INFO =      "Mostrar botones adicionales para insertar códigos de color HTML.",
  COLOR_MOTD =      "Mensaje del día",
  COLOR_DESC =      "Información de fondo",
}