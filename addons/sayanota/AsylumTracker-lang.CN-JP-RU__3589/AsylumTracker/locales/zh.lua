local AST = AsylumTracker
AST.lang.zh = {}

local locale_strings = {
     -- Settings Menu
     ["AST_SETT_HEADER"] = "Asylum Tracker 设置",
     ["AST_SETT_INFO"] = "Asylum Tracker 信息",
     ["AST_SETT_DESCRIPTION"] = "@sayanota汉化的庇护圣所机制插件",
     ["AST_SETT_NOTIFICATIONS"] = "通知",
     ["AST_SETT_LANGUAGE"] = "语言",
          --     ["AST_SETT_LANGUAGE_OVERRIDE"] = "Language Override",
          --     ["AST_SETT_LANGUAGE_OVERRIDE_DESC"] = "Ignore the game's locale and load a specific language to use for the addon",
          --     ["AST_SETT_LANGUAGE_DROPDOWN_TOOL"] = "Select Language to load.",

          --     ["AST_SETT_TIMERS"] = "Timer Settings (BETA)",
          --     ["AST_SETT_OLMS_ADJUST"] = "Adjust Olms' timers",
          --     ["AST_SETT_LLOTHIS_ADJUST"] = "Adjust Llothis' timers",
          --     ["AST_SETT_OLMS_ADJUST_DESC"] = "Adjust Olms' timers to account for other mechanics happening when a timer reaches 0",
          --     ["AST_SETT_LLOTHIS_ADJUST_DESC"] = "Adjust Oppressive Bolts timer to account for Defiling Blast happening when the oppressive bolts timer reaches 0",

     -- Unlock Button
     ["AST_SETT_UNLOCK"] = "解锁",
     ["AST_SETT_LOCK"] = "锁定",
     ["AST_SETT_UNLOCK_TOOL"] = "解锁界面",

     -- Generics
     ["AST_SETT_YOU"] = "你",
     ["AST_SETT_SOON"] = "准备",
     ["AST_SETT_NOW"] = "NOW",
     ["AST_SETT_COLOR"] = "颜色",
     ["AST_SETT_COLOR_1"] = "主色",
     ["AST_SETT_COLOR_2"] = "子颜色",
     ["AST_SETT_FONT_SIZE"] = "字体大小",
     ["AST_SETT_SCALE"] = "大小",
     ["AST_SETT_SCALE_WARN"] = "更改此设置会使通知模糊，请先设置字体大小",
          --     ["AST_SETT_TIMER_COLOR"] = "Timer Color",
          --     ["AST_SETT_TIMER_COLOR_TOOL"] = "The color for the countdown number displayed on timers",

     -- Center Notifications Button
          -- ["AST_SETT_CENTER_NOTIF"] = "Reset Positions",
          -- ["AST_SETT_CENTER_NOTIF_TOOL"] = "Resets the notifications to their default positions",

     -- Sound Effects
     ["AST_SETT_SOUND_EFFECT"] = "音效",
     ["AST_SETT_SOUND_EFFECT_TOOL"] = "喷毒和闪电圈的声音效果", -- I'm not sure what the official Japanese Translations are for Defiling Dye Blast or Storm the Heavens

     -- Mini Notifications
     ["AST_SETT_LLOTHIS_NOTIF"] = "毒法师通知", -- Notifications for Llothis
     ["AST_SETT_LLOTHIS_NOTIF_TOOL"] = "在以下情况下发出通知：毒法师被打倒时、复活接近时、复活时",
     ["AST_SETT_FELMS_NOTIF"] = "夜刃通知", -- Notifications for Felms
     ["AST_SETT_FELMS_NOTIF_TOOL"] = "在以下情况下发出通知：夜刃被打倒时、复活接近时、复活时",

     -- Olms' HP
     ["AST_SETT_OLMS_HP_SIZE"] = "主bossHP通知的字体大小", -- Font Size for Olms' HP Notification
     ["AST_SETT_OLMS_HP_SIZE_TOOL"] = "更改主boss的HP通知的字体大小",
     ["AST_SETT_OLMS_HP_SCALE"] = "主bossHP的通知大小",
     ["AST_SETT_OLMS_HP_SCALE_TOOL"] = "更改主bossHP的通知大小",
     ["AST_SETT_OLMS_HP_COLOR_1_TOOL"] = "主boss进行跳跃之前的HP为2%以上时和5%以下时的颜色",
     ["AST_SETT_OLMS_HP_COLOR_2_TOOL"] = "主boss进行跳跃之前的HP在2%以下时的颜色",

     -- Storm the Heavens
     ["AST_SETT_STORM"] = "闪电圈", -- I'm sure there's an official translation for the ability, but I'm not sure what it is.
     ["AST_SETT_STORM_TOOL"] = "boss飞起来，在每人脚下释放的闪电AOE",
     ["AST_SETT_STORM_SIZE_TOOL"] = "更改闪电圈通知的字体大小",
     ["AST_SETT_STORM_SCALE_TOOL"] = "更改闪电圈的通知大小",
     ["AST_SETT_STORM_COLOR_1_TOOL"] = "第一次闪电圈通知的颜色",
     ["AST_SETT_STORM_COLOR_2_TOOL"] = "第二次闪电圈通知的颜色",
          -- ["AST_SETT_STORM_SOUND_EFFECT"] = "声效",
          -- ["AST_SETT_STORM_SOUND_EFFECT_TOOL"] = "将用于闪电圈的声音效果.",
          -- ["AST_SETT_STORM_SOUND_EFFECT_VOLUME"] = "声效音量",
          -- ["AST_SETT_STORM_SOUND_EFFECT_VOLUME_TOOL"] = "闪电圈的声效音量",

     -- Defiling Dye Blast
     ["AST_SETT_BLAST"] = "毒法师的喷毒", -- I'm sure there's an official translation for the ability, but I'm not sure what it is.
     ["AST_SETT_BLAST_TOOL"] = "毒法师的喷毒攻击",
     ["AST_SETT_BLAST_SIZE_TOOL"] = "更改预览通知的字体大小",
     ["AST_SETT_BLAST_SCALE_TOOL"] = "更改喷毒通知的大小",
     ["AST_SETT_BLAST_COLOR_TOOL"] = "更改预览通知的颜色",
          -- ["AST_SETT_BLAST_SOUND_EFFECT"] = "声效",
          -- ["AST_SETT_BLAST_SOUND_EFFECT_TOOL"] = "将用于喷毒的声音效果.",
          -- ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME"] = "声效音量",
          -- ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME_TOOL"] = "喷毒的声效音量.",

     -- Protectors
     ["AST_SETT_PROTECT"] = "充能球", -- The little sphere's the shield Olms
     ["AST_SETT_PROTECT_TOOL"] = "给主boss上无敌的小球",
     ["AST_SETT_PROTECT_SIZE_TOOL"] = "更改有关充能球通知的字体大小",
     ["AST_SETT_PROTECT_SCALE_TOOL"] = "更改有关充能球通知的大小",
     ["AST_SETT_PROTECT_COLOR_1_TOOL"] = "当充能球给主boss上无敌时，通知的第一种颜色会闪烁",
     ["AST_SETT_PROTECT_COLOR_2_TOOL"] = "当充能球给主boss上无敌时，通知的第二种颜色会闪烁",
          -- ["AST_SETT_PROTECT_MESSAGE"] = "Sphere Text",
          -- ["AST_SETT_PROTECT_MESSAGE_TOOL"] = "Set Custom Sphere Text",

     -- Teleport Strike
     ["AST_SETT_JUMP"] = "夜刃跳斩", -- Felms' jumping mechanic
     ["AST_SETT_JUMP_TOOL"] = "夜刃跳斩",
     ["AST_SETT_JUMP_SIZE_TOOL"] = "更改夜刃跳斩通知的字体大小",
     ["AST_SETT_JUMP_SCALE_TOOL"] = "更改夜刃跳斩通知的大小",
     ["AST_SETT_JUMP_COLOR_TOOL"] = "更改夜刃跳斩通知的颜色",

     -- Oppressive Bolts
     ["AST_SETT_BOLTS"] = "发射毒螺栓", -- Llothis' attack that needs to be interrupted
     ["AST_SETT_BOLTS_TOOL"] = "直接举起武器，向所有小组成员发射螺栓",
     ["AST_SETT_BOLTS_SIZE_TOOL"] = "更改毒螺栓通知的字体大小",
     ["AST_SETT_BOLTS_SCALE_TOOL"] = "更改毒螺栓通知的大小",
     ["AST_SETT_BOLTS_COLOR_TOOL"] = "更改毒螺栓通知的颜色",
     ["AST_SETT_INTTERUPT"] = "打断通知",
     ["AST_SETT_INTTERUPT_TOOL"] = "需要打断毒法师时的信息",

     -- Steam Breath
     ["AST_SETT_STEAM"] = "主boss喷气", -- Olms' steam breath attack
     ["AST_SETT_STEAM_TOOL"] = "主boss锥形喷气",
     ["AST_SETT_STEAM_SIZE_TOOL"] = "更改主boss喷气通知的字体大小",
     ["AST_SETT_STEAM_SCALE_TOOL"] = "更改主boss喷气通知的大小",
     ["AST_SETT_STEAM_COLOR_TOOL"] = "更改主boss喷气通知的颜色",

     -- Exhaustive Charges
          -- ["AST_SETT_CHARGES"] = "吸蓝大圈",
          -- ["AST_SETT_CHARGES_TOOL"] = "主boss的吸蓝大圈",
          -- ["AST_SETT_CHARGES_SIZE_TOOL"] = "更改吸蓝大圈通知的字体大小",
          -- ["AST_SETT_CHARGES_SCALE_TOOL"] = "更改吸蓝大圈通知的大小",
          -- ["AST_SETT_CHARGES_COLOR_TOOL"] = "更改吸蓝大圈通知的颜色",

     -- Trial By Fire
     ["AST_SETT_FIRE"] = "大火圈", -- Olms' Fire mechanic below 25% HP
     ["AST_SETT_FIRE_TOOL"] = "主bossHP在25%以下时放出的火焰范围攻击",
     ["AST_SETT_FIRE_SIZE_TOOL"] = "更改大火圈通知的字体大小",
     ["AST_SETT_FIRE_SCALE_TOOL"] = "更改大火圈通知的大小",
     ["AST_SETT_FIRE_COLOR_TOOL"] = "改大火圈通知颜色",

     -- Maim
     ["AST_SETT_MAIM"] = "夜刃伤害降低", -- Felms' Maim debuff
     ["AST_SETT_MAIM_TOOL"] = "夜刃残废圈",
     ["AST_SETT_MAIM_SIZE_TOOL"] = "更改夜刃残废圈通知的字体大小",
     ["AST_SETT_MAIM_SCALE_TOOL"] = "更改夜刃残废圈通知的大小",
     ["AST_SETT_MAIM_COLOR_TOOL"] = "更改夜刃残废圈通知的颜色",

     -- In-Game Notifications
     ["AST_NOTIF_LLOTHIS_IN_10"] = "距离毒法师复活还有10秒", -- Llothis will be back up in 10 seconds (because when he gets killed in the fight, he doesn't die, he goes dormant and then gets back up after ~35s)
     ["AST_NOTIF_LLOTHIS_IN_5"] = "距离毒法师复活还有5秒",
     ["AST_NOTIF_LLOTHIS_UP"] = "毒法师复活", -- Llothis stands back up
     ["AST_NOTIF_LLOTHIS_DOWN"] = "毒法师入场", -- llothis goes dormant.
     ["AST_NOTIF_FELMS_IN_10"] = "距离夜刃复活还有10秒",
     ["AST_NOTIF_FELMS_IN_5"] = "距离夜刃复活还有５秒",
     ["AST_NOTIF_FELMS_UP"] = "夜刃复活",
     ["AST_NOTIF_FELMS_DOWN"] = "夜刃入场",

     -- On-screen Notifications
     ["AST_NOTIF_OLMS_JUMP"] = "大跳", -- For when Olms jumps at 90/75/50/25% HP
     ["AST_NOTIF_PROTECTOR"] = "充能球", -- Referring to the protectors
     ["AST_NOTIF_KITE"] = "KITE: ", -- Referring to Olms' Storm the Heavens mechanic. (Storm would probably be a better word to translate than Kite)
     ["AST_NOTIF_KITE_NOW"] = "KITE NOW", -- Referring to Olms' Storm the Heavens mechanic. (Storm would probably be a better word to translate than Kite)
     ["AST_NOTIF_BLAST"] = "喷毒: ", -- Referring to Llothis' Cone attack. (Cone would probably be a better word to translate than blast)
     ["AST_NOTIF_JUMP"] = "夜刃跳斩: ",
     ["AST_NOTIF_BOLTS"] = "打断: ", -- Referring to Llothis' Oppressive bolts attack
     ["AST_NOTIF_INTERRUPT"] = "打断", -- For when you need to Interrupt Llothis' oppressive bolts attack
     ["AST_NOTIF_FIRE"] = "大火圈: ",
     ["AST_NOTIF_STEAM"] = "锥形蒸汽: ", -- Referring to Olms' Steam breath
     ["AST_NOTIF_MAIM"] = "伤害降低: ", -- Referring to Felms' Maim
     ["AST_NOTIF_CHARGES"] = "吸蓝圈: ",

     -- Previewing Notifications
     ["AST_PREVIEW_OLMS_HP_1"] = "主boss",
     ["AST_PREVIEW_OLMS_HP_2"] = "血量",
     ["AST_PREVIEW_STORM_1"] = "闪电球",
     ["AST_PREVIEW_STORM_2"] = "NOW",
     ["AST_PREVIEW_SPHERE_1"] = "充能球",
     ["AST_PREVIEW_SPHERE_2"] = "球",
     ["AST_PREVIEW_BLAST"] = "喷毒",
     ["AST_PREVIEW_JUMP"] = "夜刃跳斩",
     ["AST_PREVIEW_BOLTS"] = "打断",
     ["AST_PREVIEW_FIRE"] = "大火圈",
     ["AST_PREVIEW_STEAM"] = "锥形蒸汽",
     ["AST_PREVIEW_MAIM"] = "伤害降低",
     ["AST_PREVIEW_CHARGES"] = "吸蓝圈",
}

function AST.lang.zh.LoadStrings()
     for k, v in pairs(locale_strings) do
          ZO_CreateStringId(k, v)
     end
end
