local AST = AsylumTracker
AST.lang.fr = {}

local locale_strings = {
     -- Settings Menu
     ["AST_SETT_HEADER"] = "Asylum Tracker Paramètres",
     ["AST_SETT_INFO"] = "Asylum Tracker Information",
     ["AST_SETT_DESCRIPTION"] = "Affiche des notifications et des alerts pour vous aider sur l'Asile Sanctuaire",
     ["AST_SETT_NOTIFICATIONS"] = "Notifications",
     ["AST_SETT_LANGUAGE"] = "Langue",
          --     ["AST_SETT_LANGUAGE_OVERRIDE"] = "Language Override",
          --     ["AST_SETT_LANGUAGE_OVERRIDE_DESC"] = "Ignore the game's locale and load a specific language to use for the addon",
          --     ["AST_SETT_LANGUAGE_DROPDOWN_TOOL"] = "Select Language to load.",

          --     ["AST_SETT_TIMERS"] = "Timer Settings (BETA)",
          --     ["AST_SETT_OLMS_ADJUST"] = "Adjust Olms' timers",
          --     ["AST_SETT_LLOTHIS_ADJUST"] = "Adjust Llothis' timers",
          --     ["AST_SETT_OLMS_ADJUST_DESC"] = "Adjust Olms' timers to account for other mechanics happening when a timer reaches 0",
          --     ["AST_SETT_LLOTHIS_ADJUST_DESC"] = "Adjust Oppressive Bolts timer to account for Defiling Blast happening when the oppressive bolts timer reaches 0",

     -- Unlock Button
     ["AST_SETT_UNLOCK"] = "Déverrouiller",
     ["AST_SETT_LOCK"] = "Verrouiller",
     ["AST_SETT_UNLOCK_TOOL"] = "Affiche tous les éléments et les rends déplaçables.",

     -- Generics
     ["AST_SETT_YOU"] = "VOUS",
     ["AST_SETT_SOON"] = "BIENTÔT",
     ["AST_SETT_NOW"] = "MAINTENANT",
     ["AST_SETT_COLOR"] = "Couleur",
     ["AST_SETT_COLOR_1"] = "Couleur Primaire",
     ["AST_SETT_COLOR_2"] = "Couleur Secondaire",
     ["AST_SETT_FONT_SIZE"] = "Taille du Texte",
     ["AST_SETT_SCALE"] = "Taille Notification",
     ["AST_SETT_SCALE_WARN"] = "Ajuster ce paramètre rendra la notification floue. Réglez d'abord le paramètre de taille du texte.",
          --     ["AST_SETT_TIMER_COLOR"] = "Timer Color",
          --     ["AST_SETT_TIMER_COLOR_TOOL"] = "The color for the countdown number displayed on timers",

     -- Center Notifications Button
          -- ["AST_SETT_CENTER_NOTIF"] = "Reset Positions",
          -- ["AST_SETT_CENTER_NOTIF_TOOL"] = "Resets the notifications to their default positions",

     -- Sound Effects
     ["AST_SETT_SOUND_EFFECT"] = "Effets Sonores",
     ["AST_SETT_SOUND_EFFECT_TOOL"] = "Les effets sonores pour la mécanique Détonation Profanée, et Nuages de Vapeur.",

     -- Mini Notifications
     ["AST_SETT_LLOTHIS_NOTIF"] = "Llothis Notifications", -- Notifications for Llothis
     ["AST_SETT_LLOTHIS_NOTIF_TOOL"] = "Affiche des notification quand Llothis est sur le point de revenir, quand il revient, et quand il meurt.",
     ["AST_SETT_FELMS_NOTIF"] = "Felms Notifications", -- Notifications for Felms
     ["AST_SETT_FELMS_NOTIF_TOOL"] = "Affiche des notification quand Felms est sur le point de revenir, quand il revient, et quand il meurt.",

     -- Olms' HP
     ["AST_SETT_OLMS_HP_SIZE"] = "Taille Texte HP Olms", -- Font Size for Olms' HP Notification
     ["AST_SETT_OLMS_HP_SIZE_TOOL"] = "Modifie la taille du texte pour la notification de santé d'Olms.",
     ["AST_SETT_OLMS_HP_SCALE"] = "Taille Notification HP Olms",
     ["AST_SETT_OLMS_HP_SCALE_TOOL"] = "Modifie la taille de la notification de santé d'Olms.",
     ["AST_SETT_OLMS_HP_COLOR_1_TOOL"] = "Couleur quand les points de vie d'Olms sont entre 2% et 5% jusqu'au prochain saut.",
     ["AST_SETT_OLMS_HP_COLOR_2_TOOL"] = "Couleur quand les points de vie d'Olms sont en dessous de 2% avant le prochain saut.",

     -- Storm the Heavens
     ["AST_SETT_STORM"] = "Assaillir les Cieux", -- I'm sure there's an official translation for the ability, but I'm not sure what it is.
     ["AST_SETT_STORM_TOOL"] = "Phase de kite d'Olms.",
     ["AST_SETT_STORM_SIZE_TOOL"] = "Modifie la taille du texte pour Assaillir les Cieux.",
     ["AST_SETT_STORM_SCALE_TOOL"] = "Modifie la taille de la notification pour Assaillir les Cieux.",
     ["AST_SETT_STORM_COLOR_1_TOOL"] = "Première couleur d'Assaillir les Cieux.",
     ["AST_SETT_STORM_COLOR_2_TOOL"] = "Seconde couleur d'Assaillir les Cieux.",
          -- ["AST_SETT_STORM_SOUND_EFFECT"] = "Sound Effect",
          -- ["AST_SETT_STORM_SOUND_EFFECT_TOOL"] = "Sound Effect that will be used for Storm the Heavens.",
          -- ["AST_SETT_STORM_SOUND_EFFECT_VOLUME"] = "Sound Effect Volume",
          -- ["AST_SETT_STORM_SOUND_EFFECT_VOLUME_TOOL"] = "Volume of Storm the Heavens Sound Effect",

     -- Defiling Dye Blast
     ["AST_SETT_BLAST"] = "Détonation Profanée", -- I'm sure there's an official translation for the ability, but I'm not sure what it is.
     ["AST_SETT_BLAST_TOOL"] = "Attaque Détonation Profanée de Llothis (cône).",
     ["AST_SETT_BLAST_SIZE_TOOL"] = "Modifie la taille du texte pour la Détonation Profanée.",
     ["AST_SETT_BLAST_SCALE_TOOL"] = "Modifie la taille de la notification pour la Détonation Profanée.",
     ["AST_SETT_BLAST_COLOR_TOOL"] = "Couleur pour l'attaque Détonation Profanée.",
          -- ["AST_SETT_BLAST_SOUND_EFFECT"] = "Sound Effect",
          -- ["AST_SETT_BLAST_SOUND_EFFECT_TOOL"] = "Sound Effect that will be used for Defiling Blast.",
          -- ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME"] = "Sound Effect Volume",
          -- ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME_TOOL"] = "Volume of Defiling Blast Sound Effect.",

     -- Protectors
     ["AST_SETT_PROTECT"] = "Protecteurs", -- The little sphere's the shield Olms
     ["AST_SETT_PROTECT_TOOL"] = "Un protecteur immunise Olms.",
     ["AST_SETT_PROTECT_SIZE_TOOL"] = "Modifie la taille du texte pour les Protecteurs.",
     ["AST_SETT_PROTECT_SCALE_TOOL"] = "Modifie la taille de la notification pour les Protecteurs.",
     ["AST_SETT_PROTECT_COLOR_1_TOOL"] = "Première couleur d'un Protecteur immunisant Olms.",
     ["AST_SETT_PROTECT_COLOR_2_TOOL"] = "Seconde couleur d'un Protecteur immunisant Olms.",
          -- ["AST_SETT_PROTECT_MESSAGE"] = "Sphere Text",
          -- ["AST_SETT_PROTECT_MESSAGE_TOOL"] = "Set Custom Sphere Text",

     -- Teleport Strike
     ["AST_SETT_JUMP"] = "Téléportation", -- Felms' jumping mechanic
     ["AST_SETT_JUMP_TOOL"] = "Attaque Sautée de Felms.",
     ["AST_SETT_JUMP_SIZE_TOOL"] = "Modifie la taille du texte pour la Téléportation.",
     ["AST_SETT_JUMP_SCALE_TOOL"] = "Modifie la taille de la notification pour la Téléportation.",
     ["AST_SETT_JUMP_COLOR_TOOL"] = "Couleur pour la Téléportation.",

     -- Oppressive Bolts
     ["AST_SETT_BOLTS"] = "Rayons Oppresseurs", -- Llothis' attack that needs to be interrupted
     ["AST_SETT_BOLTS_TOOL"] = "L'attaque interrompable de Llothis.",
     ["AST_SETT_BOLTS_SIZE_TOOL"] = "Modifie la taille du texte pour les Rayons Oppresseurs.",
     ["AST_SETT_BOLTS_SCALE_TOOL"] = "Modifie la taille de la notification pour les Rayons Oppresseurs.",
     ["AST_SETT_BOLTS_COLOR_TOOL"] = "Couleur pour les Rayons Oppresseurs.",
     ["AST_SETT_INTTERUPT"] = "Message Interruption",
     ["AST_SETT_INTTERUPT_TOOL"] = "Message a afficher quand il faut interrompre Llothis.",

     -- Steam Breath
     ["AST_SETT_STEAM"] = "Souffle de Vapeur", -- Olms' steam breath attack
     ["AST_SETT_STEAM_TOOL"] = "Attaque Souffle de Vapeur d'Olms.",
     ["AST_SETT_STEAM_SIZE_TOOL"] = "Modifie la taille du texte pour Souffle de Vapeur.",
     ["AST_SETT_STEAM_SCALE_TOOL"] = "Modifie la taille de la notification pour le Souffle de Vapeur.",
     ["AST_SETT_STEAM_COLOR_TOOL"] = "Couleur pour le Souffle d'Olms.",

     -- Exhaustive Charges
          -- ["AST_SETT_CHARGES"] = "Exhaustive Charges",
          -- ["AST_SETT_CHARGES_TOOL"] = "Olms' Exhaustive Charges Attack",
          -- ["AST_SETT_CHARGES_SIZE_TOOL"] = "Change the Font Size for Olms' Exhaustive Charges",
          -- ["AST_SETT_CHARGES_SCALE_TOOL"] = "Change the Scale for Olms' Exhaustive Charges",
          -- ["AST_SETT_CHARGES_COLOR_TOOL"] = "Color for Olms' Exhaustive Charges",

     -- Trial By Fire
     ["AST_SETT_FIRE"] = "Épreuve du Feu", -- Olms' Fire mechanic below 25% HP
     ["AST_SETT_FIRE_TOOL"] = "L'attaque de feu d'Olms en dessous de 25% de santé.",
     ["AST_SETT_FIRE_SIZE_TOOL"] = "Modifie la taille du texte pour le Feu.",
     ["AST_SETT_FIRE_SCALE_TOOL"] = "Modifie la taille de la notification pour le Feu.",
     ["AST_SETT_FIRE_COLOR_TOOL"] = "Couleur pour l'attaque de Feu d'Olms.",

     -- Maim
     ["AST_SETT_MAIM"] = "Mutiler", -- Felms' Maim debuff
     ["AST_SETT_MAIM_TOOL"] = "Mutilement de Felms (debuff)",
     ["AST_SETT_MAIM_SIZE_TOOL"] = "Modifie la taille du texte pour le Mutilement.",
     ["AST_SETT_MAIM_SCALE_TOOL"] = "Modifie la taille de la notification pour le Mutilement.",
     ["AST_SETT_MAIM_COLOR_TOOL"] = "Couleur pour le Mutilement de Felms.",

     -- In-Game Notifications
     ["AST_NOTIF_LLOTHIS_IN_10"] = "LLOTHIS DANS 10 SECONDES", -- Llothis will be back up in 10 seconds (because when he gets killed in the fight, he doesn't die, he goes dormant and then gets back up after ~35s)
     ["AST_NOTIF_LLOTHIS_IN_5"] = "LLOTHIS DANS 5 SECONDES",
     ["AST_NOTIF_LLOTHIS_UP"] = "LLOTHIS EST DEBOUT", -- Llothis stands back up
     ["AST_NOTIF_LLOTHIS_DOWN"] = "LLOTHIS EST MORT", -- llothis goes dormant.
     ["AST_NOTIF_FELMS_IN_10"] = "FELMS DANS 10 SECONDES",
     ["AST_NOTIF_FELMS_IN_5"] = "FELMS DANS 5 SECONDES",
     ["AST_NOTIF_FELMS_UP"] = "FELMS EST DEBOUT",
     ["AST_NOTIF_FELMS_DOWN"] = "FELMS EST MORT",

     -- On-screen Notifications
     ["AST_NOTIF_OLMS_JUMP"] = "SAUTS", -- For when Olms jumps at 90/75/50/25% HP
     ["AST_NOTIF_PROTECTOR"] = "SPHERE", -- Referring to the protectors
     ["AST_NOTIF_KITE"] = "KITE: ", -- Referring to Olms' Storm the Heavens mechanic. (Storm would probably be a better word to translate than Kite)
     ["AST_NOTIF_KITE_NOW"] = "KITE MAINTENANT", -- Referring to Olms' Storm the Heavens mechanic. (Storm would probably be a better word to translate than Kite)
     ["AST_NOTIF_BLAST"] = "CÔNE: ", -- Referring to Llothis' Cone attack. (Cone would probably be a better word to translate than blast)
     ["AST_NOTIF_JUMP"] = "FELMS SAUT: ",
     ["AST_NOTIF_BOLTS"] = "RAYONS: ", -- Referring to Llothis' Oppressive bolts attack
     ["AST_NOTIF_INTERRUPT"] = "INTERRUPTION", -- For when you need to Interrupt Llothis' oppressive bolts attack
     ["AST_NOTIF_FIRE"] = "FEU: ",
     ["AST_NOTIF_STEAM"] = "SOUFFLE: ", -- Referring to Olms' Steam breath
     ["AST_NOTIF_MAIM"] = "MUTILER: ", -- Referring to Felms' Maim
          -- ["AST_NOTIF_CHARGES"] = "CHARGES: ",

     -- Previewing Notifications
     ["AST_PREVIEW_OLMS_HP_1"] = "OLMS",
     ["AST_PREVIEW_OLMS_HP_2"] = "HP",
     ["AST_PREVIEW_STORM_1"] = "KITE MAIN",
     ["AST_PREVIEW_STORM_2"] = "TENANT",
     ["AST_PREVIEW_SPHERE_1"] = "SPH",
     ["AST_PREVIEW_SPHERE_2"] = "ERE",
     ["AST_PREVIEW_BLAST"] = "CÔNE",
     ["AST_PREVIEW_JUMP"] = "FELMS SAUT",
     ["AST_PREVIEW_BOLTS"] = "RAYONS",
     ["AST_PREVIEW_FIRE"] = "FEU",
     ["AST_PREVIEW_STEAM"] = "SOUFFLE",
     ["AST_PREVIEW_MAIM"] = "MUTILER",
          -- ["AST_PREVIEW_CHARGES"] = "CHARGES",
}

function AST.lang.fr.LoadStrings()
     for k, v in pairs(locale_strings) do
          ZO_CreateStringId(k, v)
     end
end
