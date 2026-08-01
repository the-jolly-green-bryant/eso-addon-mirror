-- Automatische Generierung
ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuGuildHome"] = {
  TITLE =           "Guilde: " .. GetString(SI_WINDOW_TITLE_GUILD_HOME),
  KIOSK =           "Délai jusqu'à la prochaine offre de la guilde des négociants",
  KIOSK_TT =        "Indique le délai avant que le négociant du PNJ ne change dans la vue d'ensemble de la guilde. Affiche également une fenêtre supplémentaire contenant les informations suivantes pendant les 15 dernières minutes de la mission du trader Dernière fois pour les enchères, fin des enchères, temps pour le remplacement du concessionnaire.",

  LEFTTIME =        "Temps restant",
  
  TRADER =          "Guilde NPC",
  NEWKIOSK =        "Nouveau concessionnaire en",
  BIDEND =          "Fin de la vente aux enchères",
  REPLACE =         "Remplaçant de",        
  
  TEXT =            "DEINTEXT",
  
  COLOR =           GetString(SI_GUILD_HERALDRY_COLOR),       -- Farbe
  COLOR_INFO =      "Afficher des boutons supplémentaires pour l'insertion de codes de couleur HTML.",
  COLOR_MOTD =      "Message du jour",
  COLOR_DESC =      "Informations générales",
}