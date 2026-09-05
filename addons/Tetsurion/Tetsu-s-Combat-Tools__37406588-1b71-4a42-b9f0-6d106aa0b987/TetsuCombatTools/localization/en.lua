TetsuCombatTools = TetsuCombatTools or {}

TetsuCombatTools.L = {
    TITLE = "|cFFD700Tetsu's|r Combat Tools",

    INFO_LABEL = "Info",
    INFO_TT = "Gamepad combat HUD. Skill history + GCD + combat status lamp.\nGold / bugs: mail @Tetsurion.",

    SKILL_ENABLE = "Skill Tracking",
    SKILL_ENABLE_TT = "Show the last pressed bar skills and a GCD bar. Ultimate is always included.",

    SKILL_SECTION = "Skill Tracking",
    SKILL_SECTION_TT = "History strip, size, position, visibility.",

    SKILL_SLOTS = "History slots",
    SKILL_SLOTS_TT = "How many recent skills to keep. 4–8. Default 6.",

    SKILL_SCALE = "Icon scale %",
    SKILL_SCALE_TT = "Size of the history icons.",

    SKILL_X = "Offset X",
    SKILL_X_TT = "0 = screen center. Negative left, positive right.",

    SKILL_Y = "Offset Y",
    SKILL_Y_TT = "0 = reticle / screen center. Default 330 sits above the action bar. Negative = up, positive = down.",

    SKILL_SHOW = "When to show",
    SKILL_SHOW_TT = "Combat = in fight, then hide after the delay. Always = stay up. After press = hide N seconds after the last skill.",

    SHOW_COMBAT = "In combat only",
    SHOW_ALWAYS = "Always",
    SHOW_IDLE = "After last press",

    SKILL_HIDE = "Hide after (sec)",
    SKILL_HIDE_TT = "Used after combat ends (combat mode) and after the last press (after-press mode). Default 8.",

    SKILL_GCD = "GCD bar",
    SKILL_GCD_TT = "Yellow/red bar under the icons. Off = icons only, weave frames stay.",

    SKILL_LA = "Show light attacks",
    SKILL_LA_TT = "Off by default. When on, weapon light attacks also appear as their own icons. Weave mark (green/red frame) works even if this is off. Heavy attacks, block, dodge and synergies stay out.",

    STATUS_ENABLE = "Combat Status",
    STATUS_ENABLE_TT = "Red in combat, green out of combat. Icon, text and start sound are separate.",
    STATUS_SECTION = "Combat Status",
    STATUS_SECTION_TT = "Icon, text and the sound played when a fight starts.",
    STATUS_ICON = "Icon",
    STATUS_ICON_TT = "On by default. Colored circle at the reticle. Position and size are independent from the text.",
    STATUS_ICON_X = "Icon offset X",
    STATUS_ICON_X_TT = "0 = screen center. Negative left, positive right.",
    STATUS_ICON_Y = "Icon offset Y",
    STATUS_ICON_Y_TT = "0 = reticle / screen center. Negative up, positive down.",
    STATUS_ICON_SCALE = "Icon scale %",
    STATUS_ICON_SCALE_TT = "Size of the combat lamp.",
    STATUS_TEXT = "Text",
    STATUS_TEXT_TT = "Off by default. Writes IN COMBAT / OUT OF COMBAT in the same red/green colors.",
    STATUS_TEXT_X = "Text offset X",
    STATUS_TEXT_X_TT = "0 = screen center.",
    STATUS_TEXT_Y = "Text offset Y",
    STATUS_TEXT_Y_TT = "Default 250 = below the reticle. Negative up, positive down.",
    STATUS_TEXT_SCALE = "Text scale %",
    STATUS_TEXT_SCALE_TT = "Size of the combat text.",
    STATUS_IN = "IN COMBAT",
    STATUS_OUT = "OUT OF COMBAT",
    STATUS_SOUND = "Sound on combat start",
    STATUS_SOUND_TT = "On by default. Plays only when you enter combat, never when you leave.",
    STATUS_SOUND_PICK = "Start sound",
    STATUS_SOUND_PICK_TT = "Built-in game sound. No custom files.",
    SOUND_DUEL = "Duel start",
    SOUND_ALERT = "Alert",
    SOUND_QUEST = "Quest tick",
    SOUND_NOTIFY = "Notification",
    SOUND_DISCOVER = "Objective found",
}
