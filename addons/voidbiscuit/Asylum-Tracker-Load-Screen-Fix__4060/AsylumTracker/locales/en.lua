local AST = AsylumTracker
AST.lang.en = {}

local locale_strings = {
     -- Settings Menu
     ["AST_SETT_HEADER"] = "Asylum Tracker Settings",
     ["AST_SETT_INFO"] = "Asylum Tracker Information",
     ["AST_SETT_DESCRIPTION"] = "Provides Notifications and alerts to help with Asylum Sanctorium",
     ["AST_SETT_NOTIFICATIONS"] = "Notifications",
     ["AST_SETT_LANGUAGE"] = "Language",
     ["AST_SETT_LANGUAGE_OVERRIDE"] = "Language Override",
     ["AST_SETT_LANGUAGE_OVERRIDE_DESC"] = "Ignore the game's locale and load a specific language to use for the addon",
     ["AST_SETT_LANGUAGE_DROPDOWN_TOOL"] = "Select Language to load.",

     ["AST_SETT_TIMERS"] = "Timer Settings (BETA)",
     ["AST_SETT_OLMS_ADJUST"] = "Adjust Olms' timers",
     ["AST_SETT_LLOTHIS_ADJUST"] = "Adjust Llothis' timers",
     ["AST_SETT_OLMS_ADJUST_DESC"] = "Adjust Olms' timers to account for other mechanics happening when a timer reaches 0",
     ["AST_SETT_LLOTHIS_ADJUST_DESC"] = "Adjust Oppressive Bolts timer to account for Defiling Blast happening when the oppressive bolts timer reaches 0",

     -- Unlock Button
     ["AST_SETT_UNLOCK"] = "Unlock",
     ["AST_SETT_LOCK"] = "Lock",
     ["AST_SETT_UNLOCK_TOOL"] = "Unhides all elements and makes them moveable",

     -- Generics
     ["AST_SETT_YOU"] = "YOU",
     ["AST_SETT_SOON"] = "SOON",
     ["AST_SETT_NOW"] = "NOW",
     ["AST_SETT_COLOR"] = "Color",
     ["AST_SETT_COLOR_1"] = "Primary Color",
     ["AST_SETT_COLOR_2"] = "Secondary Color",
     ["AST_SETT_FONT_SIZE"] = "Font Size",
     ["AST_SETT_SCALE"] = "Scale",
     ["AST_SETT_SCALE_WARN"] = "Adjusting this setting will make the notification blurry, Adjust the font size setting first.",
     ["AST_SETT_TIMER_COLOR"] = "Timer Color",
     ["AST_SETT_TIMER_COLOR_TOOL"] = "The color for the countdown number displayed on timers",

     -- Center Notifications Button
     ["AST_SETT_CENTER_NOTIF"] = "Reset Positions",
     ["AST_SETT_CENTER_NOTIF_TOOL"] = "Resets the notifications to their default positions",

     -- Sound Effects
     ["AST_SETT_SOUND_EFFECT"] = "Sound Effects",
     ["AST_SETT_SOUND_EFFECT_TOOL"] = "Sound Effects for the Defiling Blast and Storm the Heavens mechanics",

     -- Mini Notifications
     ["AST_SETT_LLOTHIS_NOTIF"] = "Llothis Notifications", -- Notifications for Llothis
     ["AST_SETT_LLOTHIS_NOTIF_TOOL"] = "Provides notifications for when Llothis is about to get back up, when he gets up, and when he goes down",
     ["AST_SETT_FELMS_NOTIF"] = "Felms Notifications", -- Notifications for Felms
     ["AST_SETT_FELMS_NOTIF_TOOL"] = "Provides notifications for when Felms is about to get back up, when he gets up, and when he goes down",

     -- Olms' HP
     ["AST_SETT_OLMS_HP_SIZE"] = "Olms' HP Font Size", -- Font Size for Olms' HP Notification
     ["AST_SETT_OLMS_HP_SIZE_TOOL"] = "Change the Font Size for Olms' HP notification",
     ["AST_SETT_OLMS_HP_SCALE"] = "Olms' HP Notification Scale",
     ["AST_SETT_OLMS_HP_SCALE_TOOL"] = "Change the Scale for Olms' HP notification",
     ["AST_SETT_OLMS_HP_COLOR_1_TOOL"] = "Color while Olms' HP is greater than 2% and less than 5% until jump",
     ["AST_SETT_OLMS_HP_COLOR_2_TOOL"] = "Color while Olms' HP is less than 2% until jump",

     -- Storm the Heavens
     ["AST_SETT_STORM"] = "Storm the Heavens", -- I'm sure there's an official translation for the ability, but I'm not sure what it is.
     ["AST_SETT_STORM_TOOL"] = "Olms' kiting phase",
     ["AST_SETT_STORM_SIZE_TOOL"] = "Change the Font Size for Storm the Heavens",
     ["AST_SETT_STORM_SCALE_TOOL"] = "Change the Scale for Storm the Heavens",
     ["AST_SETT_STORM_COLOR_1_TOOL"] = "Storm the Heavens first flashing color",
     ["AST_SETT_STORM_COLOR_2_TOOL"] = "Storm the Heavens second flashing color",
     ["AST_SETT_STORM_SOUND_EFFECT"] = "Sound Effect",
     ["AST_SETT_STORM_SOUND_EFFECT_TOOL"] = "Sound Effect that will be used for Storm the Heavens.",
     ["AST_SETT_STORM_SOUND_EFFECT_VOLUME"] = "Sound Effect Volume",
     ["AST_SETT_STORM_SOUND_EFFECT_VOLUME_TOOL"] = "Volume of Storm the Heavens Sound Effect",

     -- Defiling Dye Blast
     ["AST_SETT_BLAST"] = "Defiling Blast", -- I'm sure there's an official translation for the ability, but I'm not sure what it is.
     ["AST_SETT_BLAST_TOOL"] = "Llothis' Defiling Dye Blast attack",
     ["AST_SETT_BLAST_SIZE_TOOL"] = "Change the Font Size for Defiling Dye Blast",
     ["AST_SETT_BLAST_SCALE_TOOL"] = "Change the Scale for Defiling Dye Blast",
     ["AST_SETT_BLAST_COLOR_TOOL"] = "Color for Llothis' Defiling Dye Blast attack",
     ["AST_SETT_BLAST_SOUND_EFFECT"] = "Sound Effect",
     ["AST_SETT_BLAST_SOUND_EFFECT_TOOL"] = "Sound Effect that will be used for Defiling Blast.",
     ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME"] = "Sound Effect Volume",
     ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME_TOOL"] = "Volume of Defiling Blast Sound Effect.",

     -- Protectors
     ["AST_SETT_PROTECT"] = "Protectors", -- The little sphere's the shield Olms
     ["AST_SETT_PROTECT_TOOL"] = "A Protector is shielding Olms",
     ["AST_SETT_PROTECT_SIZE_TOOL"] = "Change the Font Size for Protectors",
     ["AST_SETT_PROTECT_SCALE_TOOL"] = "Change the Scale for Protectors",
     ["AST_SETT_PROTECT_COLOR_1_TOOL"] = "First Color for Protector shielding Olms",
     ["AST_SETT_PROTECT_COLOR_2_TOOL"] = "Second Color for Protector shielding Olms",
     ["AST_SETT_PROTECT_MESSAGE"] = "Sphere Text",
     ["AST_SETT_PROTECT_MESSAGE_TOOL"] = "Set Custom text for the protector",

     -- Teleport Strike
     ["AST_SETT_JUMP"] = "Teleport Strike", -- Felms' jumping mechanic
     ["AST_SETT_JUMP_TOOL"] = "Felms' Jump Attack",
     ["AST_SETT_JUMP_SIZE_TOOL"] = "Change the Font Size for Telport Strike",
     ["AST_SETT_JUMP_SCALE_TOOL"] = "Change the Scale for Teleport Strike",
     ["AST_SETT_JUMP_COLOR_TOOL"] = "Color for Felms' Teleport Strike",

     -- Oppressive Bolts
     ["AST_SETT_BOLTS"] = "Oppressive Bolts", -- Llothis' attack that needs to be interrupted
     ["AST_SETT_BOLTS_TOOL"] = "Llothis' interruptable attack",
     ["AST_SETT_BOLTS_SIZE_TOOL"] = "Change the Font Size for Oppressive Bolts",
     ["AST_SETT_BOLTS_SCALE_TOOL"] = "Change the Scale for Oppressive Bolts",
     ["AST_SETT_BOLTS_COLOR_TOOL"] = "Color for Llothis' Oppressive Bolts attack",
     ["AST_SETT_INTTERUPT"] = "Interrupt Message",
     ["AST_SETT_INTTERUPT_TOOL"] = "Message displayed when Llothis is interrupted",

     -- Steam Breath
     ["AST_SETT_STEAM"] = "Steam Breath", -- Olms' steam breath attack
     ["AST_SETT_STEAM_TOOL"] = "Olms' Scalding Roar Attack",
     ["AST_SETT_STEAM_SIZE_TOOL"] = "Change the Font Size for Olms' Steam Breath",
     ["AST_SETT_STEAM_SCALE_TOOL"] = "Change the Scale for Olms' Steam Breath",
     ["AST_SETT_STEAM_COLOR_TOOL"] = "Color for Olms' Steam Breath",

     -- Exhaustive Charges
     ["AST_SETT_CHARGES"] = "Exhaustive Charges",
     ["AST_SETT_CHARGES_TOOL"] = "Olms' Exhaustive Charges Attack",
     ["AST_SETT_CHARGES_SIZE_TOOL"] = "Change the Font Size for Olms' Exhaustive Charges",
     ["AST_SETT_CHARGES_SCALE_TOOL"] = "Change the Scale for Olms' Exhaustive Charges",
     ["AST_SETT_CHARGES_COLOR_TOOL"] = "Color for Olms' Exhaustive Charges",

     -- Trial By Fire
     ["AST_SETT_FIRE"] = "Trial By Fire", -- Olms' Fire mechanic below 25% HP
     ["AST_SETT_FIRE_TOOL"] = "Olms' Fire Attack below 25% HP",
     ["AST_SETT_FIRE_SIZE_TOOL"] = "Change the Font Size for Fire",
     ["AST_SETT_FIRE_SCALE_TOOL"] = "Change the Scale for Fire",
     ["AST_SETT_FIRE_COLOR_TOOL"] = "Color for Olms' Fire attack",

     -- Maim
     ["AST_SETT_MAIM"] = "Maim", -- Felms' Maim debuff
     ["AST_SETT_MAIM_TOOL"] = "Felms' Maim",
     ["AST_SETT_MAIM_SIZE_TOOL"] = "Change the Font Size for Maim",
     ["AST_SETT_MAIM_SCALE_TOOL"] = "Change the Scale for Maim",
     ["AST_SETT_MAIM_COLOR_TOOL"] = "Color for Felms' Maim",

     -- In-Game Notifications
     ["AST_NOTIF_LLOTHIS_IN_10"] = "LLOTHIS IN 10 SECONDS", -- Llothis will be back up in 10 seconds (because when he gets killed in the fight, he doesn't die, he goes dormant and then gets back up after ~35s)
     ["AST_NOTIF_LLOTHIS_IN_5"] = "LLOTHIS IN 5 SECONDS",
     ["AST_NOTIF_LLOTHIS_UP"] = "LLOTHIS IS UP", -- Llothis stands back up
     ["AST_NOTIF_LLOTHIS_DOWN"] = "LLOTHIS IS DOWN", -- llothis goes dormant.
     ["AST_NOTIF_FELMS_IN_10"] = "FELMS IN 10 SECONDS",
     ["AST_NOTIF_FELMS_IN_5"] = "FELMS IN 5 SECONDS",
     ["AST_NOTIF_FELMS_UP"] = "FELMS IS UP",
     ["AST_NOTIF_FELMS_DOWN"] = "FELMS IS DOWN",

     -- On-screen Notifications
     ["AST_NOTIF_OLMS_JUMP"] = "JUMPING", -- For when Olms jumps at 90/75/50/25% HP
     ["AST_NOTIF_PROTECTOR"] = "SPHERE", -- Referring to the protectors
     ["AST_NOTIF_KITE"] = "KITE: ", -- Referring to Olms' Storm the Heavens mechanic. (Storm would probably be a better word to translate than Kite)
     ["AST_NOTIF_KITE_NOW"] = "KITE NOW", -- Referring to Olms' Storm the Heavens mechanic. (Storm would probably be a better word to translate than Kite)
     ["AST_NOTIF_BLAST"] = "BLAST: ", -- Referring to Llothis' Cone attack. (Cone would probably be a better word to translate than blast)
     ["AST_NOTIF_JUMP"] = "FELMS JUMP: ",
     ["AST_NOTIF_BOLTS"] = "BOLTS: ", -- Referring to Llothis' Oppressive bolts attack
     ["AST_NOTIF_INTERRUPT"] = "INTERRUPT", -- For when you need to Interrupt Llothis' oppressive bolts attack
     ["AST_NOTIF_FIRE"] = "FIRE: ",
     ["AST_NOTIF_STEAM"] = "STEAM: ", -- Referring to Olms' Steam breath
     ["AST_NOTIF_MAIM"] = "MAIM: ", -- Referring to Felms' Maim
     ["AST_NOTIF_CHARGES"] = "CHARGES: ",

     -- Previewing Notifications
     ["AST_PREVIEW_OLMS_HP_1"] = "OLMS",
     ["AST_PREVIEW_OLMS_HP_2"] = "HP",
     ["AST_PREVIEW_STORM_1"] = "KITE",
     ["AST_PREVIEW_STORM_2"] = "NOW",
     ["AST_PREVIEW_SPHERE_1"] = "SPH",
     ["AST_PREVIEW_SPHERE_2"] = "ERE",
     ["AST_PREVIEW_BLAST"] = "BLAST",
     ["AST_PREVIEW_JUMP"] = "FELMS JUMP",
     ["AST_PREVIEW_BOLTS"] = "BOLTS",
     ["AST_PREVIEW_FIRE"] = "FIRE",
     ["AST_PREVIEW_STEAM"] = "STEAM",
     ["AST_PREVIEW_MAIM"] = "MAIM",
     ["AST_PREVIEW_CHARGES"] = "CHARGES",
}

function AST.lang.en.LoadStrings()
     for k, v in pairs(locale_strings) do
          ZO_CreateStringId(k, v)
     end
end
