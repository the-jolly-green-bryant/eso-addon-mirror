local AST = AsylumTracker
AST.lang.de = {}

local locale_strings = {
     -- Settings Menu
     ["AST_SETT_HEADER"] = "Asylum Tracker Einstellungen",
     ["AST_SETT_INFO"] = "Asylum Tracker Informationen",
     ["AST_SETT_DESCRIPTION"] = "Zeigt hilfreiche Benachrichtigungen in der Prüfung Die Anstalt Sanctorium an",
     ["AST_SETT_NOTIFICATIONS"] = "Benachrichtigungen",
     ["AST_SETT_LANGUAGE"] = "Sprache",
          --     ["AST_SETT_LANGUAGE_OVERRIDE"] = "Language Override",
          --     ["AST_SETT_LANGUAGE_OVERRIDE_DESC"] = "Ignore the game's locale and load a specific language to use for the addon",
          --     ["AST_SETT_LANGUAGE_DROPDOWN_TOOL"] = "Select Language to load.",

          --     ["AST_SETT_TIMERS"] = "Timer Settings (BETA)",
          --     ["AST_SETT_OLMS_ADJUST"] = "Adjust Olms' timers",
          --     ["AST_SETT_LLOTHIS_ADJUST"] = "Adjust Llothis' timers",
          --     ["AST_SETT_OLMS_ADJUST_DESC"] = "Adjust Olms' timers to account for other mechanics happening when a timer reaches 0",
          --     ["AST_SETT_LLOTHIS_ADJUST_DESC"] = "Adjust Oppressive Bolts timer to account for Defiling Blast happening when the oppressive bolts timer reaches 0",

     -- Unlock Button
     ["AST_SETT_UNLOCK"] = "Entsperren",
     ["AST_SETT_LOCK"] = "Sperren",
     ["AST_SETT_UNLOCK_TOOL"] = "Alle Elemente werden eingeblendet und sind verschiebbar",

     -- Generics
     ["AST_SETT_YOU"] = "DU",
     ["AST_SETT_SOON"] = "BALD",
     ["AST_SETT_NOW"] = "JETZT",
     ["AST_SETT_COLOR"] = "Farbe",
     ["AST_SETT_COLOR_1"] = "Primär Farbe",
     ["AST_SETT_COLOR_2"] = "Sekundäre Farbe",
     ["AST_SETT_FONT_SIZE"] = "Schriftgröße",
     ["AST_SETT_SCALE"] = "Maßstab",
     ["AST_SETT_SCALE_WARN"] = "Die Änderung dieser Einstellung macht diese Benachrichtigung verschwommen. Ändere zuerst die Schriftgröße.",
          --     ["AST_SETT_TIMER_COLOR"] = "Timer Color",
          --     ["AST_SETT_TIMER_COLOR_TOOL"] = "The color for the countdown number displayed on timers",

     -- Center Notifications Button
          -- ["AST_SETT_CENTER_NOTIF"] = "Reset Positions",
          -- ["AST_SETT_CENTER_NOTIF_TOOL"] = "Resets the notifications to their default positions",

     -- Sound Effects
     ["AST_SETT_SOUND_EFFECT"] = "Soundeffekt",
     ["AST_SETT_SOUND_EFFECT_TOOL"] = "Soundeffekt für die Angriffe Entweihende Farbexplosion und Erstürmung des Himmels",

     -- Mini Notifications
     ["AST_SETT_LLOTHIS_NOTIF"] = "Llothis Benachrichtigungen",
     ["AST_SETT_LLOTHIS_NOTIF_TOOL"] = "Zeigt Benachrichtigungen an bevor Llothis erwacht, sobald er erwacht und wenn er in den Ruhezustand geht.",
     ["AST_SETT_FELMS_NOTIF"] = "Felms Benachrichtigungen",
     ["AST_SETT_FELMS_NOTIF_TOOL"] = "Zeigt Benachrichtigungen an bevor Felms erwacht, sobald er erwacht und wenn er in den Ruhezustand geht.",

     -- Olms' HP
     ["AST_SETT_OLMS_HP_SIZE"] = "Olms' HP - Schriftgröße",
     ["AST_SETT_OLMS_HP_SIZE_TOOL"] = "Schriftgröße für Olms' HP",
     ["AST_SETT_OLMS_HP_SCALE"] = "Olms' HP Maßstab",
     ["AST_SETT_OLMS_HP_SCALE_TOOL"] = "Maßstab für Olms' HP",
     ["AST_SETT_OLMS_HP_COLOR_1_TOOL"] = "Farbeinstellung für die Benachrichtichtigung wenn Olms' HP zwischen 2% und 5% zum Dampfschwaden entfernt ist.",
     ["AST_SETT_OLMS_HP_COLOR_2_TOOL"] = "Farbeinstellung für die Benachrichtigung wenn Olms' HP unter 2% zum Dampfschwaden entfernt ist.",

     -- Storm the Heavens
     ["AST_SETT_STORM"] = "Erstürmung des Himmels",
     ["AST_SETT_STORM_TOOL"] = "Olms' Erstürmungsattacke",
     ["AST_SETT_STORM_SIZE_TOOL"] = "Schriftgröße für Erstürmung des Himmels",
     ["AST_SETT_STORM_SCALE_TOOL"] = "Maßstab für Erstürmung des Himmels",
     ["AST_SETT_STORM_COLOR_1_TOOL"] = "Erstürmung des Himmels - Erste blinkende Farbe",
     ["AST_SETT_STORM_COLOR_2_TOOL"] = "Erstürmung des Himmels - Zweite blinkende Farbe",
          -- ["AST_SETT_STORM_SOUND_EFFECT"] = "Sound Effect",
          -- ["AST_SETT_STORM_SOUND_EFFECT_TOOL"] = "Sound Effect that will be used for Storm the Heavens.",
          -- ["AST_SETT_STORM_SOUND_EFFECT_VOLUME"] = "Sound Effect Volume",
          -- ["AST_SETT_STORM_SOUND_EFFECT_VOLUME_TOOL"] = "Volume of Storm the Heavens Sound Effect",

     -- Defiling Dye Blast
     ["AST_SETT_BLAST"] = "Entweihende Farbexplosion",
     ["AST_SETT_BLAST_TOOL"] = "Llothis' kegelförmiger Explosionsangriff",
     ["AST_SETT_BLAST_SIZE_TOOL"] = "Schriftgröße für Entweihende Farbexplosion",
     ["AST_SETT_BLAST_SCALE_TOOL"] = "Maßstab für Entweihende Farbexplosion",
     ["AST_SETT_BLAST_COLOR_TOOL"] = "Farbeinstellung der Benachrichtigung für Entweihende Farbexplosion",
          -- ["AST_SETT_BLAST_SOUND_EFFECT"] = "Sound Effect",
          -- ["AST_SETT_BLAST_SOUND_EFFECT_TOOL"] = "Sound Effect that will be used for Defiling Blast.",
          -- ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME"] = "Sound Effect Volume",
          -- ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME_TOOL"] = "Volume of Defiling Blast Sound Effect.",

     -- Protectors
     ["AST_SETT_PROTECT"] = "Ordinierter Beschützer",
     ["AST_SETT_PROTECT_TOOL"] = "Sphäre beschützt Olms",
     ["AST_SETT_PROTECT_SIZE_TOOL"] = "Schriftgröße für Ordinierter Beschützer",
     ["AST_SETT_PROTECT_SCALE_TOOL"] = "Maßstab für Ordinierter Beschützer",
     ["AST_SETT_PROTECT_COLOR_1_TOOL"] = "Ordinierter Beschützer - Erste Farbe für die Benachrichtigung",
     ["AST_SETT_PROTECT_COLOR_2_TOOL"] = "Ordinierter Beschützer - Zweite Farbe für die Benachrichtigung",
          -- ["AST_SETT_PROTECT_MESSAGE"] = "Sphere Text",
          -- ["AST_SETT_PROTECT_MESSAGE_TOOL"] = "Set Custom Sphere Text",

     -- Teleport Strike
     ["AST_SETT_JUMP"] = "Teleportationsschlag",
     ["AST_SETT_JUMP_TOOL"] = "Felms Teleportationsschlag",
     ["AST_SETT_JUMP_SIZE_TOOL"] = "Schriftgröße für Teleportationsschlag",
     ["AST_SETT_JUMP_SCALE_TOOL"] = "Maßstab für Teleportationsschlag",
     ["AST_SETT_JUMP_COLOR_TOOL"] = "Farbeinstellung für Teleportationsschlag",

     -- Oppressive Bolts
     ["AST_SETT_BOLTS"] = "Erdrückender Stoß",
     ["AST_SETT_BOLTS_TOOL"] = "Llothis' unterbrechbarer Stoßangriff",
     ["AST_SETT_BOLTS_SIZE_TOOL"] = "Schriftgröße für Erdrückender Stoß",
     ["AST_SETT_BOLTS_SCALE_TOOL"] = "Maßstab für Erdrückender Stoß",
     ["AST_SETT_BOLTS_COLOR_TOOL"] = "Farbeinstellung für Erdrückender Stoß",
     ["AST_SETT_INTTERUPT"] = "Unterbrechungsbenachrichtigung",
     ["AST_SETT_INTTERUPT_TOOL"] = "Angezeigte Nachricht wenn Llothis' Stoß unterbrochen wurde",

     -- Steam Breath
     ["AST_SETT_STEAM"] = "Verbrühendes Brüllen",
     ["AST_SETT_STEAM_TOOL"] = "Olms' Brüllangriff",
     ["AST_SETT_STEAM_SIZE_TOOL"] = "Schriftgröße für Verbrühendes Brüllen",
     ["AST_SETT_STEAM_SCALE_TOOL"] = "Maßstab für Verbrühendes Brüllen",
     ["AST_SETT_STEAM_COLOR_TOOL"] = "Farbeinstellung für Verbrühendes Brüllen",

     -- Exhaustive Charges
          -- ["AST_SETT_CHARGES"] = "Exhaustive Charges",
          -- ["AST_SETT_CHARGES_TOOL"] = "Olms' Exhaustive Charges Attack",
          -- ["AST_SETT_CHARGES_SIZE_TOOL"] = "Change the Font Size for Olms' Exhaustive Charges",
          -- ["AST_SETT_CHARGES_SCALE_TOOL"] = "Change the Scale for Olms' Exhaustive Charges",
          -- ["AST_SETT_CHARGES_COLOR_TOOL"] = "Color for Olms' Exhaustive Charges",

     -- Trial By Fire
     ["AST_SETT_FIRE"] = "Feuertaufe",
     ["AST_SETT_FIRE_TOOL"] = "Olms' Feuerangriff ab 25% HP",
     ["AST_SETT_FIRE_SIZE_TOOL"] = "Schriftgröße für Feuertaufe",
     ["AST_SETT_FIRE_SCALE_TOOL"] = "Maßstab für Feuertaufe",
     ["AST_SETT_FIRE_COLOR_TOOL"] = "Farbeinstellung für Feuertaufe",

     -- Maim
     ["AST_SETT_MAIM"] = "Verkrüppeln",
     ["AST_SETT_MAIM_TOOL"] = "Felms' Schadensminderung",
     ["AST_SETT_MAIM_SIZE_TOOL"] = "Farbeineinstellung für Verkrüppeln",
     ["AST_SETT_MAIM_SCALE_TOOL"] = "Maßstab für Verkrüppeln",
     ["AST_SETT_MAIM_COLOR_TOOL"] = "Farbeinstellung für Verkrüppeln",

     -- In-Game Notifications
     ["AST_NOTIF_LLOTHIS_IN_10"] = "LLOTHIS IN 10 SEKUNDEN",
     ["AST_NOTIF_LLOTHIS_IN_5"] = "LLOTHIS IN 5 SEKUNDEN",
     ["AST_NOTIF_LLOTHIS_UP"] = "LLOTHIS IST ERWACHT",
     ["AST_NOTIF_LLOTHIS_DOWN"] = "LLOTHIS IST RUHEND",
     ["AST_NOTIF_FELMS_IN_10"] = "FELMS IN 10 SEKUNDEN",
     ["AST_NOTIF_FELMS_IN_5"] = "FELMS IN 5 SEKUNDEN",
     ["AST_NOTIF_FELMS_UP"] = "FELMS IST ERWACHT",
     ["AST_NOTIF_FELMS_DOWN"] = "FELMS IST RUHEND",

     -- On-screen Notifications
     ["AST_NOTIF_OLMS_JUMP"] = "DAMPFSCHWADEN",
     ["AST_NOTIF_PROTECTOR"] = "SPHÄRE",
     ["AST_NOTIF_KITE"] = "STURM: ",
     ["AST_NOTIF_KITE_NOW"] = "STURM: JETZT",
     ["AST_NOTIF_BLAST"] = "KEGEL: ",
     ["AST_NOTIF_JUMP"] = "FELMS SPRUNG: ",
     ["AST_NOTIF_BOLTS"] = "STOß: ",
     ["AST_NOTIF_INTERRUPT"] = "UNTERBRECHEN",
     ["AST_NOTIF_FIRE"] = "FEUER: ",
     ["AST_NOTIF_STEAM"] = "BRÜLLEN: ",
     ["AST_NOTIF_MAIM"] = "VERKRÜPPELN: ",
          -- ["AST_NOTIF_CHARGES"] = "CHARGES: ",

     -- Previewing Notifications
     ["AST_PREVIEW_OLMS_HP_1"] = "OLMS",
     ["AST_PREVIEW_OLMS_HP_2"] = "HP",
     ["AST_PREVIEW_STORM_1"] = "STU",
     ["AST_PREVIEW_STORM_2"] = "RM",
     ["AST_PREVIEW_SPHERE_1"] = "SPH",
     ["AST_PREVIEW_SPHERE_2"] = "ÄRE",
     ["AST_PREVIEW_BLAST"] = "KEGEL",
     ["AST_PREVIEW_JUMP"] = "FELMS SPRUNG",
     ["AST_PREVIEW_BOLTS"] = "STOß",
     ["AST_PREVIEW_FIRE"] = "FEUER",
     ["AST_PREVIEW_STEAM"] = "BRÜLLEN",
     ["AST_PREVIEW_MAIM"] = "VERKRÜPPELN",
          -- ["AST_PREVIEW_CHARGES"] = "CHARGES",
}

function AST.lang.de.LoadStrings()
     for k, v in pairs(locale_strings) do
          ZO_CreateStringId(k, v)
     end
end
